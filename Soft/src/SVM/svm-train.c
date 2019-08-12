/*
 * 
 * This function is based on the LIBSVM V2.29, and adapted to use binary file
 * 
 * The cross validtion condition (Global accuracy) is modified and applied with the MEAN accuracy
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <errno.h>
#include "svm.h"
#define Malloc(type,n) (type *)malloc((n)*sizeof(type))

void print_null(const char *s) {}

void exit_with_help()
{
	printf(
	"Usage: svm-train [options] training_set_file svm_model_file number_of_polarimetric_indices\n"
	"options:\n"
	"-s svm_type : set type of SVM (default 0)\n"
	"	0 -- C-SVC\n"
	"	1 -- nu-SVC\n"
	"	2 -- one-class SVM\n"
	"	3 -- epsilon-SVR\n"
	"	4 -- nu-SVR\n"
	"-t kernel_type : set type of kernel function (default 2)\n"
	"	0 -- linear: u'*v\n"
	"	1 -- polynomial: (gamma*u'*v + coef0)^degree\n"
	"	2 -- radial basis function: exp(-gamma*|u-v|^2)\n"
	"	3 -- sigmoid: tanh(gamma*u'*v + coef0)\n"
	"	4 -- precomputed kernel (kernel values in training_set_file)\n"
	"-d degree : set degree in kernel function (default 3)\n"
	"-g gamma : set gamma in kernel function (default 1/k)\n"
	"-r coef0 : set coef0 in kernel function (default 0)\n"
	"-c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)\n"
	"-n nu : set the parameter nu of nu-SVC, one-class SVM, and nu-SVR (default 0.5)\n"
	"-p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)\n"
	"-m cachesize : set cache memory size in MB (default 100)\n"
	"-e epsilon : set tolerance of termination criterion (default 0.001)\n"
	"-h shrinking : whether to use the shrinking heuristics, 0 or 1 (default 1)\n"
	"-b probability_estimates : whether to train a SVC or SVR model for probability estimates, 0 or 1 (default 0)\n"
	"-wi weight : set the parameter C of class i to weight*C, for C-SVC (default 1)\n"
	"-v n: n-fold cross validation mode\n"
	"-q : quiet mode (no outputs)\n"
	);
	exit(1);
}

void exit_input_error(int line_num)
{
	fprintf(stderr,"Wrong input format at line %d\n", line_num);
	exit(1);
}

int parse_command_line(int argc, char **argv, char *input_file_name, char *model_file_name);
void read_problem(const char *filename, int Npolar);
void do_cross_validation(char *file_tmp_accuracy);
char* extract_dir(char *path_file);

struct svm_parameter param;		// set by parse_command_line
struct svm_problem prob;		// set by read_problem
struct svm_model *model;
struct svm_node *x_space;
int cross_validation;
int nr_fold;

int main(int argc, char **argv)
{
	char input_file_name[1024];
	char name_tmp_accuracy[1024];
	char tmp_crossval_txt[1024];
	char* tmp_dir;
	char model_file_name[1024];
	const char *error_msg;
	int Npolar=0;
	
	/* Number of polarimetric indices used for the classification */
	Npolar = parse_command_line(argc, argv, input_file_name, model_file_name); 
	read_problem(input_file_name,Npolar);
	error_msg = svm_check_parameter(&prob,&param);
	
	sprintf(name_tmp_accuracy, "tmp_crossval.txt");
	tmp_dir = extract_dir(input_file_name);
	sprintf(tmp_crossval_txt, "%s%s", tmp_dir,name_tmp_accuracy);	
	
	if(error_msg)
	{
		fprintf(stderr,"Error: %s\n",error_msg);
		exit(1);
	}

	if(cross_validation)
	{
		do_cross_validation(tmp_crossval_txt);
	}
	else
	{
		model = svm_train(&prob,&param);
		svm_save_model(model_file_name,model);
		svm_destroy_model(model);
	}
	svm_destroy_param(&param);
	free(prob.y);
	free(prob.x);
	free(x_space);

	return 0;
}

void do_cross_validation(char *file_tmp_accuracy)
{
	int i,j;
	int num_class = 0;
	FILE *tmp_accuracy;
	double total_error = 0;
	double sumv = 0, sumy = 0, sumvv = 0, sumyy = 0, sumvy = 0;
	double *target = Malloc(double,prob.l);
	
	if ((tmp_accuracy = fopen(file_tmp_accuracy, "wt")) == NULL) {
		fprintf(stderr,"Could not open temporary cross validation accuracy file : %s\n", file_tmp_accuracy);
		exit(1);
	}

	svm_cross_validation(&prob,&param,nr_fold,target);

	if(param.svm_type == EPSILON_SVR ||
	   param.svm_type == NU_SVR)
	{
		for(i=0;i<prob.l;i++)
		{
			double y = prob.y[i];
			double v = target[i];
			total_error += (v-y)*(v-y);
			sumv += v;
			sumy += y;
			sumvv += v*v;
			sumyy += y*y;
			sumvy += v*y;
		}
		//printf("Cross Validation Mean squared error = %g\n",total_error/prob.l);
		//printf("Cross Validation Squared correlation coefficient = %g\n",
		//	((prob.l*sumvy-sumv*sumy)*(prob.l*sumvy-sumv*sumy))/
		//	((prob.l*sumvv-sumv*sumv)*(prob.l*sumyy-sumy*sumy))
		//	);
	}
	else
	{
		for(i=0;i<prob.l;i++)
		{
		if(prob.y[i]> num_class)
			num_class = (int)prob.y[i];
		}
		double *prob_classes = Malloc(double,num_class);/* Number of points per each classe */
		double *target_classes = Malloc(double,num_class);/* Number of points good classify per each classe */
		double mean_accuracy = 0.;/* Mean accuracy */

		for(i=0;i < num_class;i++)
		{
		prob_classes[i]=0;
		target_classes[i]=0;
		}
		for(i=0;i<prob.l;i++)
		{
			if(target[i] == prob.y[i])
			{
				++target_classes[(int)prob.y[i]-1];
			}
			++prob_classes[(int)prob.y[i]-1];
		}
		for (j=0;j<num_class;j++)
		{
			mean_accuracy = target_classes[j] / (prob_classes[j] * (double)num_class) + mean_accuracy;
		}
		fprintf(tmp_accuracy, "%g",100.0*mean_accuracy);
		
		free(prob_classes);
		free(target_classes);
	}
	free(target);
	fclose(tmp_accuracy);
}

int parse_command_line(int argc, char **argv, char *input_file_name, char *model_file_name)
{
	int i;
	int Npolar;/* Number of polarimetric indices used in the classification */

	char file_name[1024], input_bin[1024] , output_model[1024];
	// default values
	param.svm_type = C_SVC;
	param.kernel_type = RBF;
	param.degree = 3;
	param.gamma = 0;	// 1/k
	param.coef0 = 0;
	param.nu = 0.5;
	param.cache_size = 100;
	param.C = 1;
	param.eps = 1e-3;
	param.p = 0.1;
	param.shrinking = 1;
	param.probability = 0;
	param.nr_weight = 0;
	param.weight_label = NULL;
	param.weight = NULL;
	cross_validation = 0;

	// parse options
	for(i=1;i<argc;i++)
	{
		if(argv[i][0] != '-') break;
		if(++i>=argc)
			exit_with_help();
		switch(argv[i-1][1])
		{
			case 's':
				param.svm_type = atoi(argv[i]);
				break;
			case 't':
				param.kernel_type = atoi(argv[i]);
				break;
			case 'd':
				param.degree = atoi(argv[i]);
				break;
			case 'g':
				param.gamma = atof(argv[i]);
				break;
			case 'r':
				param.coef0 = atof(argv[i]);
				break;
			case 'n':
				param.nu = atof(argv[i]);
				break;
			case 'm':
				param.cache_size = atof(argv[i]);
				break;
			case 'c':
				param.C = atof(argv[i]);
				break;
			case 'e':
				param.eps = atof(argv[i]);
				break;
			case 'p':
				param.p = atof(argv[i]);
				break;
			case 'h':
				param.shrinking = atoi(argv[i]);
				break;
			case 'b':
				param.probability = atoi(argv[i]);
				break;
/*			case 'q':
				svm_print_string = &print_null;
				i--;
				break; */
			case 'v':
				cross_validation = 1;
				nr_fold = atoi(argv[i]);
				if(nr_fold < 2)
				{
					fprintf(stderr,"n-fold cross validation: n must >= 2\n");
					exit_with_help();
				}
				break;
			case 'w':
				++param.nr_weight;
				param.weight_label = (int *)realloc(param.weight_label,sizeof(int)*param.nr_weight);
				param.weight = (double *)realloc(param.weight,sizeof(double)*param.nr_weight);
				param.weight_label[param.nr_weight-1] = atoi(&argv[i-1][2]);
				param.weight[param.nr_weight-1] = atof(argv[i]);
				break;
			default:
				fprintf(stderr,"Unknown option: -%c\n", argv[i-1][1]);
				exit_with_help();
		}
	}

	if(i>=argc)
		exit_with_help();


	strcpy(input_bin, argv[argc - 3]);
	strcpy(output_model, argv[argc - 2]);
	Npolar = atoi(argv[argc - 1]);

	sprintf(input_file_name, "%s", input_bin);
	if(input_file_name==NULL)
	{
		fprintf(stderr,"can't open input file %s\n", input_file_name);
		exit(1);
	}

	sprintf(model_file_name, "%s", output_model);
	if(model_file_name==NULL)
	{
		fprintf(stderr,"can't open model file %s\n", file_name);
	}

	if(Npolar<1)
	{
		fprintf(stderr,"the number of polarimetric indices is missing or to low\n");
		exit(1);
	}

return Npolar;
}

// read in a problem (in svmlight format)
/* Modify to read a binary data contrary to .txt, initialy */

void read_problem(const char *filename, int Npolar)
{
	int elements, max_index, i, j, k;
	FILE *fp = fopen(filename,"rb");

	float pixel[Npolar + 1];

	max_index = Npolar;

	if(fp == NULL)
	{
		fprintf(stderr,"can't open input file %s\n",filename);
		exit(1);
	}

	prob.l = 0;
	elements = 0;

	while(fread(&pixel, sizeof(float), Npolar +1, fp)!=0)
	{
	  elements = elements + Npolar + 1;
	  ++prob.l;
	}
	rewind(fp);

	prob.y = Malloc(double,prob.l);
	prob.x = Malloc(struct svm_node *,prob.l);
	x_space = Malloc(struct svm_node,elements);

	j=0;
	for(i=0;i<prob.l;i++)
	{
	  for (k = 0; k < Npolar + 1; k++) 
	  {
	  if(fread(&pixel[k], sizeof(float), 1, fp));
	  }		

	  prob.x[i] = &x_space[j];

	  prob.y[i] = (double)pixel[0];

	  for (k = 1; k < Npolar + 1; k++) 
	  {
	  x_space[j].index = k;
	  x_space[j].value = pixel[k];
	  ++j;
	  }

	  x_space[j++].index = -1;
	}

	if(param.gamma == 0 && max_index > 0)
		param.gamma = 1.0/max_index;

	if(param.kernel_type == PRECOMPUTED)
		for(i=0;i<prob.l;i++)
		{
			if (prob.x[i][0].index != 0)
			{
				fprintf(stderr,"Wrong input format: first column must be 0:sample_serial_number\n");
				exit(1);
			}
			if ((int)prob.x[i][0].value <= 0 || (int)prob.x[i][0].value > max_index)
			{
				fprintf(stderr,"Wrong input format: sample_serial_number out of range\n");
				exit(1);
			}
		}

	fclose(fp);
}

/*******************************************************************************
Routine  : extract_dir
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  extract the directory from a path of a file


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
char* extract_dir(char *path_file)
{
	int index = -1;
	char *position_dir;
	char *directory=NULL;
	
	directory=(char*)malloc(strlen(path_file));
	
	position_dir = strrchr(path_file,'/');// correspond to unix system
	if(position_dir==NULL){//Si windows file path
		position_dir = strrchr(path_file,'\\');
		index = (int)(position_dir - path_file);
		strncpy(directory,path_file,index+1);
		directory[index+1] = '\0';
	}else{
		index = (int)(position_dir - path_file);
		strncpy(directory,path_file,index+1);
		directory[index+1] = '\0';
	}	
	return directory;
}
