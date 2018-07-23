/*
 *      svm_classifier.c
 *      
 *      This program run the SVM classification with a svm_config_file (batch mode)
 * 		or with all the input parameters (Polsarpro mode)
 *      
 */

/*
 * 		Dans une autre version : inclure test pour controler que le modele a utiliser correspond bien aux mêmes indices
 * 		ET AJOUTER une commande spetiale pour générer un fichier config complet
 */


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES */
#include "../lib/PolSARproLib.h"

void tirage(int res[], int nr, int org[], int no);
void random_sampling(char *cluster_file, int Npolar, int N_class,int *Npt_classe, int Npt_max_classe);
void read_coord(char *file_name);
void create_borders(float **border_map);
void create_areas(float **border_map, int Nlig, int Ncol);

void write_svm_conf_file(char *config_file, char *in_dir_svm, char *out_dir_svm,
char *Npol, char **input_ind_pol, char *area_file,  char *cluster_file,
char *range_file, char *cluster_file_norm, char *svm_model_file,
char *classification_file,  char *Npt_max_classe,
char *unbalanced_training, char *new_model, char *cv, char *log2c_begin,
char *log2c_end,char *log2c_step, char *log2g_begin,char *log2g_end,
char *log2g_step, char *kernel_type, char *cost, char *degree, char *gamma,
char *prob_opt, char *dist_opt);

char **read_svm_conf_file(char *config_file, char *in_dir_svm, char *out_dir_svm,
char *Npol, char *area_file,  char *cluster_file, char *range_file,
char *cluster_file_norm, char *svm_model_file, char *classification_file, 
char *Npt_max_classe, char *unbalanced_training, char *new_model, char *cv,
char *log2c_begin, char *log2c_end,char *log2c_step, char *log2g_begin,
char *log2g_end,char *log2g_step,char *kernel_type, char *cost, 
char *degree, char *gamma,
char *prob_opt, char *dist_opt);

void write_svm_script(char *polsarpro_directory, char *script_svm, int svm_scale_opt, int svm_cv_grid_opt,
int svm_train_opt, int svm_predict_opt, char *in_dir_svm, char *out_dir_svm,
char *range_file, char *cluster_file, char *cluster_file_norm,
char *log2c_begin, char *log2c_end, char *log2c_step,
char *log2g_begin, char *log2g_end, char *log2g_step, char *kernel_type,
char *cost, char *degree, char *gamma, char *svm_model_file,
char *unbalanced_training, int *Npt_classe_out, char *classification_file,
char *Npol, char **input_ind_pol, char *prob_opt, char *dist_opt);

int *training_set_sampler_svm(char *in_dir_svm, char *out_dir_svm, char *area_file,
char *cluster_file, int Bmp_flag, char *ColorMapTrainingSet16,
int Npt_max_classe, int *Npt_classe, int Npolar, char **input_ind_pol);
int copy_file(char const * const input, char const * const output);

void help();
/* GLOBAL VARIABLES */
float ***M_in;
float **im;
float *M_trn;
int N_class;
int *N_area;
int **N_t_pt;
int Npolar;
float ***area_coord_l;
float ***area_coord_c;
float *class_map;
float **Class_im2;
float *ValidMask;
int Max_Char = 1024;

//Needed to svm_classif
char *config_file, *in_dir_svm, *out_dir_svm;
char *Npol,  **input_ind_pol,  *area_file,   *cluster_file;
char *range_file,  *cluster_file_norm,  *svm_model_file;
char *classification_file,   *Npt_max_classe;
char *unbalanced_training,  *new_model,  *cv,  *log2c_begin;
char *log2c_end, *log2c_step,  *log2g_begin, *log2g_end;
char *log2g_step,  *kernel_type,  *cost, *degree;
char *cost_arg,*gamma_arg;
char *file_script_svm, *directory_exec_svm;
char **input_ind_pol;

char *file_svm_grid;

FILE *class_file;
FILE *in_valid;

int main(int argc, char** argv)
{
	/* Strings */
    char file_name[Max_Char];
	char file_script_svm[Max_Char];
	char polsarpro_directory[Max_Char];
	char PolarCase[20], PolarType[20];
	
    char file_valid[Max_Char];
    
	char batch[Max_Char];
	char config_file[Max_Char],in_dir_svm[Max_Char], out_dir_svm[Max_Char],Npol[Max_Char], area_file[Max_Char];
	char cluster_file[Max_Char], range_file[Max_Char], cluster_file_norm[Max_Char], svm_model_file[Max_Char];
	char classification_file[Max_Char],  Npt_max_classe[Max_Char], unbalanced_training[Max_Char];
	char new_model[Max_Char], cv[Max_Char], kernel_type[Max_Char], cost[Max_Char], degree[Max_Char], gamma[Max_Char];
	char prob_opt[Max_Char], dist_opt[Max_Char];
	int Npolar, i;
	char **input_ind_pol = NULL;
	char ColorMapTrainingSet16[Max_Char];
	int Bmp_flag;		/* Bitmap file creation flag */
	int num_class;
	
	int Nlig, Ncol, lig, col;		/* Initial image nb of lines and rows */
	
	int *Npt_classe = NULL;//Number of input training point
	int *Npt_classe_out = NULL; //first ligne will contain the number of class and after the number of training point per class
	
	char log2c_begin[Max_Char],log2c_end[Max_Char],log2c_step[Max_Char];
	char log2g_begin[Max_Char],log2g_end[Max_Char],log2g_step[Max_Char];
	
	int svm_scale_opt = 0;
	int svm_cv_grid_opt = 0;
	int svm_train_opt = 0;
	int svm_predict_opt = 0;
	
	if ((strcmp(argv[1],"-h")== 0) || (strcmp(argv[1],"-help")== 0)	|| (strcmp(argv[1],"--help")== 0) || (argc == 1)){
		help();
	}
	
	if ((strcmp(argv[1],"build_svm_config_file")== 0)){
		
		strcpy(config_file, argv[2]);
		sprintf(Npol, "3");
		Npolar = atoi(Npol);
		
		input_ind_pol = malloc(Npolar*sizeof(char*));		
		for(i=0;i<Npolar;i++){
			input_ind_pol[i] = malloc(Max_Char * sizeof(char));
		}
		sprintf(input_ind_pol[0], "T11.bin");
		sprintf(input_ind_pol[1], "T22.bin");
		sprintf(input_ind_pol[2], "T33.bin");
		
		sprintf(Npt_max_classe, "500");
		sprintf(unbalanced_training, "0");
		sprintf(new_model, "1");
		sprintf(cv, "0");
		sprintf(log2c_begin, "DISABLE");
		sprintf(log2c_end, "DISABLE");
		sprintf(log2c_step, "DISABLE");
		sprintf(log2g_begin, "DISABLE");
		sprintf(log2g_end, "DISABLE");
		sprintf(log2g_step, "DISABLE");
		sprintf(kernel_type, "2");
		sprintf(cost, "100");
		sprintf(degree, "DISABLE");
		sprintf(gamma, "1");
		sprintf(prob_opt, "1");
		sprintf(dist_opt, "1");
		
		#ifndef _WIN32//We are on linux
			sprintf(in_dir_svm, "/media/data/in_dir/T3/");
			sprintf(out_dir_svm, "/media/data/out_dir/");
			sprintf(area_file, "/media/data/in_dir/T3/training_areas_file.txt");
			sprintf(cluster_file, "/media/data/tmp/cluster_file.bin");
			sprintf(cluster_file_norm, "/media/data/tmp/cluster_norm_file.bin");
			sprintf(range_file, "/media/data/in_dir/T3/range_file.txt");
			sprintf(svm_model_file, "/media/data/in_dir/T3/svm_model_file.txt");
			sprintf(classification_file, "/media/data/in_dir/T3/classification_file.bin");
		#else //We are NOT on linux (probably Win32)
			sprintf(in_dir_svm, "d:\\data\\in_dir\\T3\\");
			sprintf(out_dir_svm, "d:\\data\\out_dir\\");
			sprintf(area_file, "d:\\data\\in_dir\\T3\\training_areas_file.txt");
			sprintf(cluster_file, "d:\\data\\tmp\\cluster_file.bin");
			sprintf(cluster_file_norm, "d:\\data\\tmp\\cluster_norm_file.bin");
			sprintf(range_file, "d:\\data\\in_dir\\T3\\range_file.txt");
			sprintf(svm_model_file, "d:\\data\\in_dir\\T3\\svm_model_file.txt");
			sprintf(classification_file, "d:\\data\\in_dir\\T3\\classification_file.bin");
		#endif
		write_svm_conf_file(config_file, in_dir_svm, out_dir_svm, Npol,
		input_ind_pol, area_file,  cluster_file, range_file,
		cluster_file_norm, svm_model_file, classification_file,
		Npt_max_classe, unbalanced_training, new_model, cv, log2c_begin,
		log2c_end, log2c_step,  log2g_begin, log2g_end, log2g_step,
		kernel_type, cost, degree, gamma,
		prob_opt, dist_opt);
		free(input_ind_pol);
		exit(1);
	}
	
	if (argc > 12) { // Case of BATCH OFF (Polsarpro Interface)
	strcpy(batch, argv[1]);
	strcpy(polsarpro_directory, argv[2]);
	strcpy(file_script_svm, argv[3]);
	strcpy(in_dir_svm, argv[4]);
	Bmp_flag = atoi(argv[5]);
	strcpy(ColorMapTrainingSet16, argv[6]);
	strcpy(config_file, argv[7]);
	strcpy(file_valid, argv[8]);
	strcpy(out_dir_svm, argv[9]);
	strcpy(area_file, argv[10]);
	strcpy(cluster_file, argv[11]);
	strcpy(range_file, argv[12]);
	strcpy(cluster_file_norm, argv[13]);
	strcpy(svm_model_file, argv[14]);
	strcpy(classification_file, argv[15]);
	strcpy(Npt_max_classe, argv[16]);
	strcpy(unbalanced_training, argv[17]);
	strcpy(new_model, argv[18]);
	strcpy(cv, argv[19]);
	strcpy(log2c_begin, argv[20]);
	strcpy(log2c_end, argv[21]);
	strcpy(log2c_step, argv[22]);
	strcpy(log2g_begin, argv[23]);
	strcpy(log2g_end, argv[24]);
	strcpy(log2g_step, argv[25]);
	strcpy(kernel_type, argv[26]);
	strcpy(cost, argv[27]);
	strcpy(degree, argv[28]);
	strcpy(gamma, argv[29]);
	strcpy(prob_opt, argv[30]);
	strcpy(dist_opt, argv[31]);

	strcpy(Npol, argv[32]);

	Npolar = atoi(Npol);
	input_ind_pol = malloc(Npolar*sizeof(char*));
	for(i=0;i<Npolar;i++){
		input_ind_pol[i] = malloc(Max_Char * sizeof(char));
		strcpy(input_ind_pol[i], argv[i+33]);
	}
	
	} else{// Case of BATCH ON (1)
		if( argc == 9 ){
			strcpy(batch, argv[1]);
			strcpy(polsarpro_directory, argv[2]);
			strcpy(file_script_svm, argv[3]);
			strcpy(in_dir_svm, argv[4]);
			Bmp_flag = atoi(argv[5]);
			strcpy(ColorMapTrainingSet16, argv[6]);
			strcpy(config_file, argv[7]);
            strcpy(file_valid, argv[8]);
		if( argc == 9 && strcmp(batch,"0")==0 ){
				edit_error("In this case : Batch parameter could not be 0 : Error in argument\n 'svm_classifier batch_parameter polsarpro_directory file_script_svm in_dir  Bmp_flag ColorMapTrainingSet16  svm_config_file'\n", "");
			}
		}else{
			edit_error("THE SYNTAX could be \n\n IF Batch equal to 1 :\n'svm_classifier batch_parameter polsarpro_directory file_script_svm in_dir Bmp_flag ColorMapTrainingSet16 svm_config_file' \nOR IF Batch equal to 0 :\n'svm_classifier batch_parameter file_script_svm in_dir Bmp_flag ColorMapTrainingSet16 svm_config_file cost gamma'\n OR\n\n'svm_classifier batch_parameter file_script_svm in_dir Bmp_flag ColorMapTrainingSet16 config_file out_dir area_file cluster_file  range_file cluster_file_norm svm_model_file classification_file Npt_max_classe  unbalanced_training new_model cv log2c_begin log2c_end log2c_step log2g_begin log2g_end log2g_step kernel_type cost degree gamma prob_opt dist_opt Npolar ind1 ind2 ...'\n", "");
		}
	} 

	
	char timing[256];	
	time_t timestamp = time(NULL); /* we register the exectuting time */	
	strftime(timing, sizeof(timing), "%d_%m_%Y_%H_%M_%S", localtime(&timestamp));
	
// Now different tests to select the different step of the asked classification
	if((strcmp(batch,"0")==0)){// Case of Polsarpro Interface : We writte the SVM configuration file
		write_svm_conf_file(config_file, in_dir_svm, out_dir_svm, Npol,
		input_ind_pol, area_file,  cluster_file, range_file,
		cluster_file_norm, svm_model_file, classification_file,
		Npt_max_classe, unbalanced_training, new_model, cv, log2c_begin,
		log2c_end, log2c_step,  log2g_begin, log2g_end, log2g_step,
		kernel_type, cost, degree, gamma, prob_opt, dist_opt);
	} else {
		input_ind_pol = read_svm_conf_file(config_file, in_dir_svm, out_dir_svm,
		Npol, area_file,  cluster_file, range_file, cluster_file_norm,
		svm_model_file, classification_file, Npt_max_classe,
		unbalanced_training, new_model, cv,log2c_begin, log2c_end,
		log2c_step, log2g_begin,log2g_end,log2g_step,kernel_type, cost, 
		degree, gamma, prob_opt, dist_opt);
	}
	
	Npolar = atoi(Npol);
	
	if(strcmp(new_model,"0")==0){ // OLD SVM model file

		svm_predict_opt = 1;
		write_svm_script(polsarpro_directory, file_script_svm, svm_scale_opt, svm_cv_grid_opt,
			svm_train_opt, svm_predict_opt, in_dir_svm, out_dir_svm,range_file,
			cluster_file, cluster_file_norm, log2c_begin,
			log2c_end, log2c_step, log2g_begin, log2g_end, log2g_step,
			kernel_type, cost, degree, gamma,svm_model_file,
			unbalanced_training, Npt_classe_out, classification_file,
			Npol, input_ind_pol,prob_opt, dist_opt);
	} else { // NEW SVM model file
		Npt_classe_out = training_set_sampler_svm(in_dir_svm, out_dir_svm, area_file, 
			cluster_file, Bmp_flag, ColorMapTrainingSet16,
			atoi(Npt_max_classe), Npt_classe, Npolar, input_ind_pol); // We build the training dataset
			num_class = Npt_classe_out[0];
				
		if(strcmp(kernel_type,"2")!=0){ // Case of Linear or Polynomial kernel
			svm_scale_opt = 1;
			svm_train_opt = 1;
			svm_predict_opt = 1;
			write_svm_script(polsarpro_directory, file_script_svm, svm_scale_opt, svm_cv_grid_opt,
				svm_train_opt, svm_predict_opt, in_dir_svm, out_dir_svm,range_file,
				cluster_file, cluster_file_norm, log2c_begin,
				log2c_end, log2c_step, log2g_begin, log2g_end, log2g_step,
				kernel_type, cost, degree, gamma,svm_model_file,
				unbalanced_training, Npt_classe_out, classification_file,
				Npol, input_ind_pol, prob_opt, dist_opt);
		} else{ // kernel type : RBF
			if(strcmp(cv,"0")==0){ // NO CV
				svm_scale_opt = 1;
				svm_train_opt = 1;
				svm_predict_opt = 1;
				write_svm_script(polsarpro_directory, file_script_svm, svm_scale_opt, svm_cv_grid_opt,
					svm_train_opt, svm_predict_opt, in_dir_svm, out_dir_svm,range_file,
					cluster_file, cluster_file_norm, log2c_begin,
					log2c_end, log2c_step, log2g_begin, log2g_end, log2g_step,
					kernel_type, cost, degree, gamma,svm_model_file,
					unbalanced_training, Npt_classe_out, classification_file,
					Npol, input_ind_pol, prob_opt, dist_opt);

			}else{ // If CV ON
				svm_scale_opt = 1;
				svm_cv_grid_opt = 1;
				write_svm_script(polsarpro_directory, file_script_svm, svm_scale_opt, svm_cv_grid_opt,
					svm_train_opt, svm_predict_opt, in_dir_svm, out_dir_svm,range_file,
					cluster_file, cluster_file_norm, log2c_begin,
					log2c_end, log2c_step, log2g_begin, log2g_end, log2g_step,
					kernel_type, cost, degree, gamma,svm_model_file,
					unbalanced_training, Npt_classe_out, classification_file,
					Npol, input_ind_pol, prob_opt, dist_opt);
			}						
		}
	}
	//execute the svm script
	#ifndef _WIN32
		sprintf(file_name, "sh \"%s\"",file_script_svm );
		system(file_name);
	#else
		sprintf(file_name, "\"%s\"",file_script_svm );
		system(file_name);
	#endif
	
	read_config(in_dir_svm, &Nlig, &Ncol, PolarCase, PolarType);
	if(strcmp(cv,"0")==0){
		if (Bmp_flag == 1) {
			if ((class_file = fopen(classification_file, "rb")) == NULL)
				edit_error("Could not open output file : ", classification_file);
			if ((in_valid = fopen(file_valid, "rb")) == NULL)
				edit_error("Could not open output file : ", file_valid);
	
				Class_im2 = matrix_float(Nlig, Ncol);
				ValidMask = vector_float(Ncol);
	 
			for (lig = 0; lig < Nlig; lig++) {
				fread(&Class_im2[lig][0], sizeof(float), Ncol, class_file);
				fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
                for (col = 0; col < Ncol; col++) Class_im2[lig][col] = Class_im2[lig][col]*ValidMask[col];
			}
			fclose(class_file);
			fclose(in_valid);
			bmp_training_set(Class_im2, Nlig, Ncol, classification_file, ColorMapTrainingSet16);
			free_matrix_float(Class_im2, Nlig);	 
			free_vector_float(ValidMask);	 
		}
	}
    
	free(input_ind_pol);
	free(Npt_classe);
	
	

return 1;
}
/**********************************
 ********** FONCTION **************
 * ********************************
 */
/*******************************************************************************
Routine  : permutation
Authors  : 
Creation : 
Update   :
*-------------------------------------------------------------------------------
Description : Random permutation of the array indices (no indices among nr)
*-------------------------------------------------------------------------------
Inputs arguments :
res : array wich content the random permuted indices
nr  ; size of the output arrays
org : array wich content the sorted initial indices of the input tab
no  : size of the input arrays

Returned values  :

*******************************************************************************/

void tirage(int res[], int nr, int org[], int no)
{
int i, k ;
for (i=0 ; i<nr ; i++)
{
k=rand()%no ; no-- ;
res[i]=org[k] ; org[k]=org[no] ; org[no]=res[i] ;
}
}

/*******************************************************************************
Routine  : Random subset of the initial training set
Authors  : 
Creation : 
Update   :
*-------------------------------------------------------------------------------
Description :  Random subset of the initial training set
*-------------------------------------------------------------------------------
Inputs arguments :
cluster_file : name of the output_binary file with the entire training dataset
Npolar : Number of polarimetric indices used for the classification
N_classe : Number of classes
Npt_classe : Initial number of training per each classes
Npt_max_classe : Max desired number of training point per each classes

Returned values  :

*******************************************************************************/

void random_sampling(char *cluster_file, int Npolar, int N_class,int *Npt_classe, int Npt_max_classe)
{
    int i, j, k;
    FILE *trn_file, *trn_file_sampling;
    float pixel[Npolar+1];
    char cluster_file_sampling[FilePathLength];

    sprintf(cluster_file_sampling, "%s%s", cluster_file, "_sampling");
    if ((trn_file_sampling = fopen(cluster_file_sampling, "wb")) == NULL)
	    edit_error("Could not open output file : ", cluster_file_sampling);

    if ((trn_file = fopen(cluster_file, "rb")) == NULL)
	    edit_error("Could not open output file : ", cluster_file);

    for (i=0 ; i<N_class ; i++) {
      if(Npt_classe[i]>Npt_max_classe){
		int input_tab[Npt_classe[i]], output_tab[Npt_max_classe];
		for (j=0 ; j< Npt_classe[i]; j++) {
			input_tab[j]=j;
		}

		tirage(output_tab,Npt_max_classe,input_tab,Npt_classe[i]);

		for (j=0 ; j< Npt_classe[i]; j++){
			k=0;
			while(output_tab[k] != j && k< Npt_max_classe){
				k++;
			}
			if(output_tab[k] == j && k< Npt_max_classe){
				fread(&pixel, sizeof(float), Npolar + 1, trn_file);
				fwrite(&pixel, sizeof(float), Npolar + 1, trn_file_sampling);
			} else{
			fread(&pixel, sizeof(float), Npolar + 1, trn_file);
			} 
		}	  
		/*  We writte the new number of points per class*/
		Npt_classe[i] = Npt_max_classe;
      } else {
		for (j=0 ; j< Npt_classe[i]; j++) {
			fread(&pixel, sizeof(float), Npolar + 1, trn_file);
			fwrite(&pixel, sizeof(float), Npolar + 1, trn_file_sampling);
		}
      }	
    }
	fclose(trn_file);
	fclose(trn_file_sampling);

	remove(cluster_file);//Delete the temporary input cluster
	copy_file(cluster_file_sampling,cluster_file); // Copy the output cluster with the original input cluster name
	remove(cluster_file_sampling);//Delete the temporary ouput cluster
}

/*******************************************************************************
Routine  : write_svm_conf_file
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  Write a text file which contain all the classification parameters
Used only in the Case of the Polsarpro Interface

Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void write_svm_conf_file(char *config_file, char *in_dir_svm, char *out_dir_svm, 
char *Npol, char **input_ind_pol, char *area_file,  char *cluster_file, 
char *range_file, char *cluster_file_norm, char *svm_model_file, 
char *classification_file,  char *Npt_max_classe, 
char *unbalanced_training, char *new_model, char *cv, char *log2c_begin,
char *log2c_end,char *log2c_step, char *log2g_begin,char *log2g_end,
char *log2g_step,char *kernel_type, char *cost, char *degree, char *gamma,
char *prob_opt, char *dist_opt)
{
	int Npolar,i;
	FILE *conf_file;
	
	Npolar = atoi(Npol);
	
	if ((conf_file = fopen(config_file, "w")) == NULL) {
		fprintf(stderr,"Could not open svm configuration file : %s\n", config_file);
		exit(1);
	}
	
	fprintf(conf_file, "#########################################\n");
	fprintf(conf_file, "# SVM Classification Configuration File #\n");
	fprintf(conf_file, "#########################################\n");
	fprintf(conf_file, "# 'DISABLE' is the argument for All\n");
	fprintf(conf_file, "# UNUSED parameters\n");
	fprintf(conf_file, "\n");
	
	fprintf(conf_file, "#####################\n");
	fprintf(conf_file, "# Working directory #\n");
	fprintf(conf_file, "#####################\n");
	fprintf(conf_file, "in_dir %s\n",in_dir_svm); //Directory which content the input polarimetric indicators
	fprintf(conf_file, "out_dir %s\n",out_dir_svm); //Output Directory
	fprintf(conf_file, "\n");
	
	fprintf(conf_file, "###############\n");
	fprintf(conf_file, "# Input files #\n");
	fprintf(conf_file, "###############\n");
	fprintf(conf_file, "number_of_pol_indic %s\n",Npol); //Number of the input polarimetric indicators
	fprintf(conf_file, "name_of_pol_indic ");	//Name of the input polarimetric indicators
	for(i=0;i<Npolar;i++){
		fprintf(conf_file, "%s ",input_ind_pol[i]);
	}
	fprintf(conf_file, "\n");
	fprintf(conf_file, "\n");
	
	fprintf(conf_file, "########################\n");
	fprintf(conf_file, "# Name of working file #\n");
	fprintf(conf_file, "########################\n");
	fprintf(conf_file, "area_file %s\n", area_file); //Name of the text file which contain the Region of interest
	fprintf(conf_file, "training_file %s\n",cluster_file); //Name of the output training file
	fprintf(conf_file, "range_file %s\n", range_file); //Name of the file which contain the normalize parameters for each polarimetric indicator
	fprintf(conf_file, "training_file_norm %s\n",cluster_file_norm); //Name of the NORMALIZED output training file
	fprintf(conf_file, "svm_model_file %s\n",svm_model_file); //Name of the output SVM model file
	fprintf(conf_file, "output_file_classif %s\n", classification_file); //Name of the output classification
	fprintf(conf_file, "\n");
	
	fprintf(conf_file, "##################\n");
	fprintf(conf_file, "# SVM Parameters #\n");
	fprintf(conf_file, "##################\n");
	fprintf(conf_file, "max_number_of_training_points %s\n",Npt_max_classe ); // Max Number of training point among those in the area_file, 0 IF all the area_file points 
	fprintf(conf_file, "unbalanced_training_dataset %s\n", unbalanced_training); // Option to balance the Cost parameter of each classes in function of the class withe the max number of training point. 1 to ENABLE, 0 to DISABLE
	fprintf(conf_file, "new_model %s\n", new_model);// Option which alow to use an older SVM model file. 0 to create a New model, 1 to use an older model
	fprintf(conf_file, "CV %s\n",cv);	
	fprintf(conf_file, "CV_log2c_interval %s %s %s\n",log2c_begin,log2c_end, log2c_step);
	fprintf(conf_file, "CV_log2g_interval %s %s %s\n",log2g_begin,log2g_end, log2g_step);
	fprintf(conf_file, "kernel_type %s\n", kernel_type);	
	fprintf(conf_file, "cost %s\n", cost);
	fprintf(conf_file, "degree %s\n", degree);
	fprintf(conf_file, "gamma %s\n",gamma);	
	fprintf(conf_file, "max_prob_estimate %s\n",prob_opt);	
	fprintf(conf_file, "mean_distance %s\n",dist_opt);	
	fclose(conf_file);
}


/*******************************************************************************
Routine  : read_svm_conf_file
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  Read the svm configuration file and return their parameters


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
char **read_svm_conf_file(char *config_file, char *in_dir_svm, char *out_dir_svm,
char *Npol, char *area_file,  char *cluster_file, char *range_file,
char *cluster_file_norm, char *svm_model_file, char *classification_file, 
char *Npt_max_classe, char *unbalanced_training, char *new_model, char *cv,
char *log2c_begin, char *log2c_end,char *log2c_step, char *log2g_begin,
char *log2g_end,char *log2g_step,char *kernel_type, char *cost, 
char *degree, char *gamma,
char *prob_opt, char *dist_opt)
{
	FILE *conf_file;
	char buff_ligne[Max_Char];
	char **input_ind_pol=NULL;
	int i,Npolar;
	
	conf_file = fopen(config_file, "r");	
	
	for(i=0;i<9;i++){// Loop to skip the header of the svm configuration file and the Working directory header
		fgets(buff_ligne, Max_Char, conf_file);
	}
	fscanf(conf_file,"%s %s",buff_ligne,in_dir_svm);
	fscanf(conf_file,"%s %s",buff_ligne,out_dir_svm);
	
	for(i=0;i<5;i++){// Loop to skip the Input file header
	fgets(buff_ligne, Max_Char, conf_file);
	}
	fscanf(conf_file,"%s %s",buff_ligne,Npol);

	Npolar = atoi(Npol);
	
	input_ind_pol = malloc(Npolar*sizeof(char*));// Allocation of the input polarimetric indicators name table
	for(i=0;i<Npolar;i++){
		input_ind_pol[i] = malloc(Max_Char * sizeof(char));
	}
	fscanf(conf_file,"%s",buff_ligne); //To skip the 'name_of_pol_indic' flag
	for(i=0;i<Npolar;i++){ //Loop to write the name of the polarimetric indicators in the input_ind_pol tab
		fscanf(conf_file,"%s",input_ind_pol[i]);
	}
	
	for(i=0;i<5;i++){// Loop to skip the 'Name of working file' header
	fgets(buff_ligne, Max_Char, conf_file);
	}
	
	fscanf(conf_file,"%s %s",buff_ligne,area_file);
	fscanf(conf_file,"%s %s",buff_ligne,cluster_file);
	fscanf(conf_file,"%s %s",buff_ligne,range_file);
	fscanf(conf_file,"%s %s",buff_ligne,cluster_file_norm);
	fscanf(conf_file,"%s %s",buff_ligne,svm_model_file);
	fscanf(conf_file,"%s %s",buff_ligne,classification_file);	

	for(i=0;i<5;i++){// Loop to skip the 'SVM Parameters' header
	fgets(buff_ligne, Max_Char, conf_file);
	}

	fscanf(conf_file,"%s %s",buff_ligne,Npt_max_classe);
	fscanf(conf_file,"%s %s",buff_ligne,unbalanced_training);
	fscanf(conf_file,"%s %s",buff_ligne,new_model);
	fscanf(conf_file,"%s %s",buff_ligne,cv);	
	fscanf(conf_file,"%s %s %s %s",buff_ligne,log2c_begin, log2c_end, log2c_step);
	fscanf(conf_file,"%s %s %s %s",buff_ligne,log2g_begin, log2g_end, log2g_step);
	fscanf(conf_file,"%s %s",buff_ligne,kernel_type);
	fscanf(conf_file,"%s %s",buff_ligne,cost);	
	fscanf(conf_file,"%s %s",buff_ligne,degree);
	fscanf(conf_file,"%s %s",buff_ligne,gamma);	
	fscanf(conf_file,"%s %s",buff_ligne,prob_opt);	
	fscanf(conf_file,"%s %s",buff_ligne,dist_opt);	
	
	fclose(conf_file);
	
	return input_ind_pol;
}



/*******************************************************************************
Routine  : write_svm_script
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  Writte the script to "batch" the fifferent step of an svm classification


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void write_svm_script(char *polsarpro_directory, char *script_svm, int svm_scale_opt, int svm_cv_grid_opt,
int svm_train_opt, int svm_predict_opt, char *in_dir_svm, char *out_dir_svm,
char *range_file, char *cluster_file, char *cluster_file_norm,
char *log2c_begin, char *log2c_end, char *log2c_step,
char *log2g_begin, char *log2g_end, char *log2g_step, char *kernel_type,
char *cost, char *degree, char *gamma, char *svm_model_file,
char *unbalanced_training, int *Npt_classe_out, char *classification_file,
char *Npol, char **input_ind_pol, char *prob_opt, char *dist_opt)
{
	FILE *file_script;
	char out_put_cv_txt[Max_Char];
	char out_put_cv_png[Max_Char];
	char svm_train_path[Max_Char];
	char svm_gnuplot_path[Max_Char];
	char prefix_exec[Max_Char];
	char string_tmp[Max_Char];
	int Npolar,i, Max_pts = 0, num_class;
		#ifndef _WIN32//We are on linux
			sprintf(svm_gnuplot_path, "/usr/bin/gnuplot");
			sprintf(svm_train_path, "\"%sSoft/SVM/svm_train_polsarpro.exe\"", polsarpro_directory);
			sprintf(prefix_exec, "./");
		#else //We are NOT on linux (probably Win32)
			sprintf(svm_gnuplot_path, "\"%sSoft/lib/wgnuplot/pgnuplot.exe\"", polsarpro_directory);
			sprintf(svm_train_path, "\"%sSoft/SVM/svm_train_polsarpro.exe\"", polsarpro_directory);
			sprintf(prefix_exec, " ");
		#endif

	sprintf(out_put_cv_txt, "\"%ssvm_cross_val.txt\"", out_dir_svm);
	sprintf(out_put_cv_png, "\"%ssvm_cross_val.png\"", out_dir_svm);
	
	Npolar = atoi(Npol);
	
	if(strcmp(unbalanced_training,"1")== 0){// Unbalanced data ENABLE
		num_class = Npt_classe_out[0];
		for(i=1;i<num_class+1;i++){//We search the max(number of training point), used only for unbalanced training data
			if(Npt_classe_out[i] > Max_pts)Max_pts = Npt_classe_out[i];
		}	
	}

	if ((file_script = fopen(script_svm, "wt")) == NULL) {
		fprintf(stderr,"Could not open svm script file : %s\n", script_svm);
		exit(1);
	}
	
	#ifndef _WIN32
		fprintf(file_script,"#!/bin/sh\n");
		fprintf(file_script,"cd \"%sSoft/SVM\"\n", polsarpro_directory);
	#else
		char* delimiteur = "/" ; 
		char* p = strtok (polsarpro_directory, delimiteur); 
		sprintf(string_tmp, "");
		while (p != NULL) 
		{ 
			sprintf(string_tmp, "%s%s\\",string_tmp, p);
			p = strtok (NULL, delimiteur); 
			
		} 
		fprintf(file_script,"%c:\n", polsarpro_directory[0]);
		fprintf(file_script,"cd \"%sSoft\\SVM\\\"\n", string_tmp);
	#endif
	
	
	if(svm_scale_opt == 1){
		//We write the call of svm_scale_polsarpro : 'svm_scale_polsarpro	in_dir	out_dir	range_file	input_bin	output_bin	number_of_polarimetric_indices'
		fprintf(file_script, "%ssvm_scale_polsarpro.exe \"%s\" \"%s\" \"%s\" %s\n",
		prefix_exec, range_file, cluster_file, cluster_file_norm,Npol); //Name of the output classification
	}
	
	if(svm_cv_grid_opt == 1){
		//We write the call of grid_polsarpro.py : 'grid.py [-log2c begin,end,step] [-log2g begin,end,step] [-v fold] [-svmtrain pathname] [-gnuplot pathname] [-out pathname] [-png pathname] [additional parameters for svm-train] in_dir out_dir training_set_file model_file number_of_polarimetric_indices'
		if(strcmp(unbalanced_training,"0")== 0){// Unbalanced data DISABLE
		fprintf(file_script, "%sgrid_polsarpro.exe -log2c %s %s %s -log2g %s %s %s -out %s -png %s -svmtrain %s -gnuplot %s \"%s\" \"%s\" %s\n",
			prefix_exec,log2c_begin, log2c_end, log2c_step,log2g_begin,
			log2g_end, log2g_step,out_put_cv_txt,out_put_cv_png,svm_train_path,
		svm_gnuplot_path, cluster_file_norm, svm_model_file, Npol);
		}else{// Unbalanced data ENABLE
			fprintf(file_script, "%sgrid_polsarpro.exe -log2c %s %s %s -log2g %s %s %s -out %s -png %s -svmtrain %s -gnuplot %s",
				prefix_exec,log2c_begin, log2c_end, log2c_step,log2g_begin,
				log2g_end, log2g_step,out_put_cv_txt,out_put_cv_png, svm_train_path,svm_gnuplot_path);
			for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
				fprintf(file_script, " -w%d %f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
			}
			fprintf(file_script, " \"%s\" \"%s\" %s\n",cluster_file_norm, svm_model_file, Npol);
		}
	}
	
	if(svm_train_opt == 1){
		//We write the call of svm_train_polsarpro : 'svm-train_polsarpro	-t #	-c #	-d # -g #	in_dir	out_dir	training_set_file	svm_model_file	number_of_polarimetric_indices'
		
		if(strcmp(kernel_type,"0")==0){//Linear case
			if(strcmp(unbalanced_training,"0")== 0){// Unbalanced data DISABLE
				if(strcmp(prob_opt,"0")== 0){// Probability estimate DISABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -t 0 -c %s \"%s\" \"%s\" %s\n",
						prefix_exec,cost, cluster_file_norm, svm_model_file, Npol);
				}else{// Probability estimate ENABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -b 1 -t 0 -c %s \"%s\" \"%s\" %s\n",
						prefix_exec,cost, cluster_file_norm, svm_model_file, Npol);
				}
			}else{// Unbalanced data ENABLE
				if(strcmp(prob_opt,"0")== 0){// Probability estimate DISABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -t 0 -c %s",prefix_exec,cost);
					for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
						fprintf(file_script, " -w%d %.3f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
					}
					fprintf(file_script, " %s %s %s\n", cluster_file_norm, svm_model_file, Npol);
				}else{// Probability estimate ENABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -b 1 -t 0 -c %s",prefix_exec,cost);
					for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
						fprintf(file_script, " -w%d %.3f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
					}
					fprintf(file_script, " \"%s\" \"%s\" %s\n", cluster_file_norm, svm_model_file, Npol);
				}
			}
		}
		
		if(strcmp(kernel_type,"1")==0){//Polynomial case
			if(strcmp(unbalanced_training,"0")== 0){// Unbalanced data DISABLE
				if(strcmp(prob_opt,"0")== 0){// Probability estimate DISABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -t 1 -c %s -d %s \"%s\" \"%s\" %s\n",
						prefix_exec, cost, degree, cluster_file_norm, svm_model_file, Npol);
				}else{// Probability estimate ENABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -b 1 -t 1 -c %s -d %s \"%s\" \"%s\" %s\n",
						prefix_exec, cost, degree, cluster_file_norm, svm_model_file, Npol);
				}
			}else{
				if(strcmp(prob_opt,"0")== 0){// Probability estimate DISABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -t 1 -c %s -d %s", prefix_exec, cost, degree);
					for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
						fprintf(file_script, " -w%d %.3f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
					}
					fprintf(file_script, " %s %s %s\n", cluster_file_norm, svm_model_file, Npol);
				}else{// Probability estimate ENABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -b 1 -t 1 -c %s -d %s", prefix_exec, cost, degree);
					for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
						fprintf(file_script, " -w%d %.3f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
					}
					fprintf(file_script, " \"%s\" \"%s\" %s\n", cluster_file_norm, svm_model_file, Npol);
				}
			}
		}
		
		if(strcmp(kernel_type,"2")==0){//RBF case
			if(strcmp(unbalanced_training,"0")== 0){// Unbalanced data DISABLE
				if(strcmp(prob_opt,"0")== 0){// Probability estimate DISABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -t 2 -c %s -g %s \"%s\" \"%s\" %s\n",
						prefix_exec, cost, gamma, cluster_file_norm, svm_model_file, Npol);
				}else{
					fprintf(file_script, "%ssvm_train_polsarpro.exe -b 1 -t 2 -c %s -g %s \"%s\" \"%s\" %s\n",
						prefix_exec, cost, gamma, cluster_file_norm, svm_model_file, Npol);
				}
			}else{
				if(strcmp(prob_opt,"0")== 0){// Probability estimate DISABLE
					fprintf(file_script, "%ssvm_train_polsarpro.exe -t 2 -c %s -g %s",prefix_exec, cost, gamma);
					for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
						fprintf(file_script, " -w%d %.3f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
					}
					fprintf(file_script, " \"%s\" \"%s\" %s\n",
					cluster_file_norm, svm_model_file, Npol);
				}else{
					fprintf(file_script, "%ssvm_train_polsarpro.exe -b 1 -t 2 -c %s -g %s",prefix_exec, cost, gamma);
					for(i=0;i<num_class;i++){//Loop to add the unbalanced settings
						fprintf(file_script, " -w%d %.3f",i+1, (float)Max_pts/(float)Npt_classe_out[i+1]);
					}
					fprintf(file_script, " \"%s\" \"%s\" %s\n",
					cluster_file_norm, svm_model_file, Npol);
				}
			}
		}
	}
		
	if(svm_predict_opt == 1){
		//We write the call of svm_scale_polsarpro : 'svm-predict_polsarpro	in_dir	out_dir	svm_model_file	range_file	output_classif	number_of_pol_ind	input_ind1'
		if(strcmp(dist_opt,"0")== 0){// Average distance DISABLE
			if(strcmp(prob_opt,"0")== 0){// Prob estimate DISABLE
				fprintf(file_script, "%ssvm_predict_polsarpro.exe 0 0 \"%s\" \"%s\" \"%s\" \"%s\" %s",
					prefix_exec,in_dir_svm, svm_model_file, range_file, classification_file, Npol); //Name of the output classification
				for(i=0;i<Npolar;i++){
					fprintf(file_script," %s",input_ind_pol[i]);
				}
				fprintf(file_script,"\n");
			}else{
				fprintf(file_script, "%ssvm_predict_polsarpro.exe 0 1 %s %s %s %s %s",
					prefix_exec,in_dir_svm, svm_model_file, range_file, classification_file, Npol); //Name of the output classification
				for(i=0;i<Npolar;i++){
					fprintf(file_script," %s",input_ind_pol[i]);
				}
				fprintf(file_script,"\n");
			}
		}else{
			if(strcmp(prob_opt,"0")== 0){// Prob estimate DISABLE
				fprintf(file_script, "%ssvm_predict_polsarpro.exe 1 0 \"%s\" \"%s\" \"%s\" \"%s\" %s",
					prefix_exec,in_dir_svm, svm_model_file, range_file, classification_file, Npol); //Name of the output classification
				for(i=0;i<Npolar;i++){
					fprintf(file_script," %s",input_ind_pol[i]);
				}
				fprintf(file_script,"\n");
			}else{
				fprintf(file_script, "%ssvm_predict_polsarpro.exe 1 1 \"%s\" \"%s\" \"%s\" \"%s\" %s",
					prefix_exec,in_dir_svm, svm_model_file, range_file, classification_file, Npol); //Name of the output classification
				for(i=0;i<Npolar;i++){
					fprintf(file_script," %s",input_ind_pol[i]);
				}
				fprintf(file_script,"\n");
			}
		}
		
		
	}
	fclose(file_script);
}	

/*******************************************************************************
Routine  : copy_file
Authors  : http://c.developpez.com/faq/?page=fichiers#FICHIERS_copier
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  copy a file into an other new file


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
int copy_file(char const * const input, char const * const output)
{
    FILE* fSrc;
    FILE* fDest;
    char buffer[512];
    int NbLus;
    
    if ((fSrc = fopen(input, "rb")) == NULL)
    {
        return 1;
    }
    
    if ((fDest = fopen(output, "wb")) == NULL)
    {
        fclose(fSrc);
        return 2;
    }
    
    while ((NbLus = fread(buffer, 1, 512, fSrc)) != 0)
        fwrite(buffer, 1, NbLus, fDest);
    
    fclose(fDest);
    fclose(fSrc);
    
    return 0;
}

/*******************************************************************************
Routine  : help
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  Help file


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void help()
{
	printf("\n#################################################################\n");
	printf("################ BEGINING HELP of svm_classifier ################\n");
	printf("#################################################################\n");
	printf("COMMAND LINE:\n");
	printf("         'svm_classifier batch_parameter polsarpro_directory file_script_svm in_dir  Bmp_flag ColorMapTrainingSet16  svm_config_file'\n");
	printf("            Where:\n");
	printf("              --> 'batch_parameter'=1\n");
	printf("              --> 'polsarpro_directory' is the directory where polsapro is installed\n");
	printf("              --> 'file_script_svm' is the COMPLETE PATH of the output svm classification script file\n");
	printf("              --> 'Bmp_flag'=1 to produce an image of the training area, 0 if not\n");
	printf("              --> 'ColorMapTrainingSet16' the COMPLETE PATH of the classification colormap\n");
	printf("              --> 'svm_config_file' the COMPLETE PATH of the input svm configuration file\n\n");

	printf("// This is the starting point to use the svm classification\n");
	printf("// in BATCH mode !\n//\n");	
	printf("// This HELP FILE is structured as:\n" );
	printf("// 			I)   Different ways to make an SVM classification\n" );
	printf("// 			II)  The different classification STEPS\n" );
	printf("// 			III) How to write a typical svm configuration file and its description ?\n" );
	printf("// 			IV)  What are the appropriate FLAGS in the svm_config_file for MY way ?\n" );
	
	printf("\nPress 'Enter' to continue the help\n" );
	getchar();
	

	printf("// This routine read a text file called svm_config_file\n");
	printf("// which content all the necessary svm classification information\n// (path file, directory, svm parameters...).\n//\n");

	printf("########## I)  Different ways to make an SVM classification ##########\n");	
	printf("// In function of what way you use to make an svm classification\n");
	printf("// you will choose the appropriate value in the different svm_config_file FLAGS\n");
	printf("// (describe a bit after).\n//\n");
	printf("// YOU HAVE 2 BIG WAYS TO PRODUCE AN SVM CLASSIFICATION:\n");
	printf("//        I)  --> Use an existing svm model file (no training process, only prediction)\n");
	printf("//                 (only possible if the sensors and choosen polarimetric indicators\n");
	printf("//                  are exactly the same and also if your data are accurately calibrated!!!)\n");
	printf("//        II) --> Build a new svm model file (training process + prediction),\n");
	printf("//                by choosing a kernel and its parameters.\n");
	printf("//                 (In the RBF kernel case it is advisable to make a cross validation\n");
	printf("//                  to obtain a best (C,gamma) couple).\n//\n");
	
	printf("########## II) The different classification STEPS ##########\n");
	printf("\nPress 'Enter' to continue the help\n" );
	getchar();

	printf("//      1) WRITTE the svm_config_file with your appropriate FLAGS\n");
	printf("//      2) CALL this program with this command line:\n");
	printf("//          'svm_classifier batch_parameter polsarpro_directory file_script_svm in_dir  Bmp_flag ColorMapTrainingSet16  svm_config_file'\n");
	printf("//      3) RUN the file_script_svm\n");
	printf("//          In all the case, EXCEPT if you have choosen to make a cross validation by using the RBF kernel,\n");
	printf("//          YOU OBTAIN YOUR FINAL BINARY SVM CLASSIFICATION!!!\n");
	printf("//           (in the RBF cross validation case, the script make the cross validation\n");
	printf("//            and plot the iso accuracy curves in fonction of the (Cost, Gamma) parameters\n");
	printf("//          a) If you have choosen the cross validation step in the RBF kernel case\n");
	printf("//              you need to make OTHER STEPS:\n");
	printf("//                 1) If you are NOT SATISFIED by the cross validation results because,\n");
	printf("//                     for example, you don't find a true maximum of accuracy,\n");
	printf("//                     you must change the cross validation (Cost, Gamma) interval\n");
	printf("//                     in the svm_config_file and GO TO STEP 1. !\n");
	printf("//                 2) If you are SATISFIED by the cross validation results:\n");
	printf("//                     a) CALL the program 'write_best_cv_results' with this command line:\n");
	printf("//                         'write_best_cv_results in_dir svm_config_file'\n");
	printf("//                           --> 'in_dir'  DIRECTORY which contain the polarimetric indicators\n");
	printf("//                           --> 'svm_config_file' the COMPLETE PATH of the input svm configuration file\n");
	printf("//                     b) RUN STEP 2. and STEP 3. :\n");
	printf("//          			  YOU OBTAIN YOUR FINAL BINARY SVM CLASSIFICATION!!!\n//\n");

	
	printf("\n########## III) How to write a typical svm configuration file and its description ? ##########\n");
	printf("// TO WRITTE a typical svm_config_file EXAMPLE, type:\n// 'svm_classifier build_svm_config_file path_svm_config_file'\n");
	printf("// The created svm configuration file looks lke this:\n\n");
	printf("Press 'Enter' to continue the help\n" );
	getchar();
	
	printf("////////////////////// BEGINING of the file //////////////////////\n");
	printf("#########################################\n");
	printf("# SVM Classification Configuration File #\n");
	printf("#########################################\n");
	printf("# 'DISABLE' is the argument for All\n");
	printf("# UNUSED parameters\n");
	printf("\n");
	
	printf("#####################\n");
	printf("# Working directory #\n");
	printf("#####################\n");
	printf("in_dir d:\\data\\in_dir\\T3\\\n"); //Directory which content the input polarimetric indicators
	printf("out_dir d:\\data\\out_dir\\\n"); //Output Directory
	printf("\n");
	
	printf("###############\n");
	printf("# Input files #\n");
	printf("###############\n");
	printf("number_of_pol_indic 3\n"); //Number of the input polarimetric indicators
	printf("name_of_pol_indic ");	//Name of the input polarimetric indicators
	printf("T11.bin T22.bin T33.bin\n");
	printf("\n");
	
	printf("########################\n");
	printf("# Name of working file #\n");
	printf("########################\n");
	printf("area_file d:\\data\\in_dir\\T3\\training_areas_file.txt\n"); //Name of the text file which contain the Region of interest
	printf("training_file d:\\data\\tmp\\cluster_file.bin\n"); //Name of the output training file
	printf("range_file d:\\data\\in_dir\\T3\\range_file.txt\n"); //Name of the file which contain the normalize parameters for each polarimetric indicator
	printf("training_file_norm d:\\data\\tmp\\cluster_norm_file.bin\n"); //Name of the NORMALIZED output training file
	printf("svm_model_file d:\\data\\in_dir\\T3\\svm_model_file.txt\n"); //Name of the output SVM model file
	printf("output_file_classif d:\\data\\in_dir\\T3\\classification_file.bin\n"); //Name of the output classification
	printf("\n");
	
	printf("##################\n");
	printf("# SVM Parameters #\n");
	printf("##################\n");
	printf("max_number_of_training_points 500\n" ); // Max Number of training point among those in the area_file, 0 IF all the area_file points 
	printf("unbalanced_training_dataset 0\n"); // Option to balance the Cost parameter of each classes in function of the class withe the max number of training point. 1 to ENABLE, 0 to DISABLE
	printf("new_model 1\n");// Option which alow to use an older SVM model file. 0 to create a New model, 1 to use an older model
	printf("CV 0\n");	
	printf("CV_log2c_interval DISABLE DISABLE DISABLE\n");
	printf("CV_log2g_interval DISABLE DISABLE DISABLE\n");
	printf("kernel_type 2\n");	
	printf("cost 100\n");
	printf("degree DISABLE\n");
	printf("gamma 0.25\n");	
	printf("prob_estimate 1\n");	
	printf("mean_distance 1\n");	
	printf("////////////////////// END of the file //////////////////////\n");
	
	printf("\nPress 'Enter' to continue the help\n" );
	getchar();
	printf("// DESCRIPTION OF svm_config_file:\n");
	printf("// All the '#' are to comment the file and DON'T change it !!!\n");
	printf("// DON'T REMOVE any line !!!\n//\n");
	printf("// In function of the needed svm classification type\n");
	printf("// (random training point sampling, kernel...)\n");
	printf("// some of these parameters must be totaly disable by the word 'DISABLE'\n");
	
	printf("//\n// Description of the different FLAG:\n");
	printf("// 'in_dir'                        : DIRECTORY which contain the polarimetric indicators.\n// \n");
	printf("// 'out_dir'                       : DIRECTORY from the different output files.\n//\n//\n");
	
	printf("// 'number_of_pol_indic'           : the NUMBER of the polarimetric indicators used in the svm classification.\n//\n");
	printf("// 'name_of_pol_indic'             : the NAME of the polarimetric indicators used in the svm classification.\n//\n//\n");
	
	printf("// 'area_file'                     : the COMPLETE PATH of the INPUT training area file which contain\n");
	printf("//                                   the coordinate of training area.\n");
	printf("//                                   --> 'DISABLE' if 'new_model'=0\n//\n");
	printf("// 'training_file'                 : the COMPLETE PATH of the OUTPUT binary svm training file.\n");
	printf("//                                   --> 'DISABLE' if 'new_model'=0\n//\n");
	printf("// 'range_file'                    : the COMPLETE PATH of the svm range file which contain\n");
	printf("//                                   the data normalisation parameters.\n");
	printf("//                                   --> OUTPUT if 'new_model'=1 or INPUT if 'new_model'=0\n//\n");
	printf("// 'training_file_norm'            : the COMPLETE PATH of the normalised binary svm training file.\n");
	printf("//                                   --> OUTPUT if 'new_model'=1 or INPUT if 'new_model'=0\n//\n");
	printf("// 'svm_model_file'                : the COMPLETE PATH of the svm model file.\n");
	printf("//                                   --> OUTPUT if 'new_model'=1 or INPUT if 'new_model'=0\n//\n");
	printf("// 'output_file_classif'           : the COMPLETE PATH of the OUTPUT svm classification file.\n//\n//\n");
	
	printf("// 'max_number_of_training_points' : Maximum of random sampling training point number choosed\n");
	printf("//                                   among the input training area.\n" );
	printf("//                                   --> '0' value to disable the random sampling\n//\n");
	printf("// 'unbalanced_training_dataset'   : EXPERIMENTAL, unbalanced cost coefficient\n");
	printf("//                                   --> '1' to enable, '0' to disable\n//\n" );
	printf("// 'new_model'                     : Build a new svm model file or use an existing.\n");
	printf("//                                   --> '1' to build, '0' to use an existing\n//\n" );
	printf("// 'CV'                            : Activate the RBF cross validation\n");
	printf("//                                    (so RBF kernel only !!!).\n" );
	printf("//                                   --> '1' to enable, '0' to disable\n//\n" );
	printf("// 'CV_log2c_interval'             : Cross validation COST interval in log2 base\n");
	printf("//                                    (RBF kernel case only!!!).\n");
	printf("//                                   --> begining end step\n" );
	printf("//                                   --> if disable : DISABLE DISABLE DISABLE\n//\n" );
	printf("// 'CV_log2g_interval'             : Cross validation GAMMA interval in log2 base\n");
	printf("//                                    (RBF kernel case only!!!).\n");
	printf("//                                   --> begining end step\n" );
	printf("//                                   --> if disable : DISABLE DISABLE DISABLE\n//\n" );
	printf("// 'kernel_type'                   : kernel choosen for the classification.\n");
	printf("//                                   --> 'DISABLE' if 'new_model'=0\n" );
	printf("//                                   --> 'O' for linear kernel\n" );
	printf("//                                   --> '1' for polynomial kernel\n" );
	printf("//                                   --> '2' for RBF kernel\n//\n" );
	printf("// 'cost'                          : value of the svm COST parameter.\n");
	printf("//                                   --> 'DISABLE' if 'new_model'=0\n//\n");
	printf("// 'degree'                        : value of the svm kernel degree parameter\n");
	printf("//                                    (only for polynomial kernel!!!).\n");
	printf("//                                   --> 'DISABLE' if 'new_model'=0\n");
	printf("//                                   --> 'DISABLE' if linear or RBF kernel\n//\n");
	printf("// 'degree'                        : value of the svm kernel gamma parameter\n");
	printf("//                                    (only for RBF kernel!!!).\n");
	printf("//                                   --> 'DISABLE' if 'new_model'=0\n");
	printf("//                                   --> 'DISABLE' if linear or polynomial kernel\n//\n");
	
	printf("########## IV)  What are the appropriate FLAGS in the svm_config_file for MY way ? ##########\n");
	printf("\nPress 'Enter' to continue the help\n" );
	getchar();
	
	printf("// Whatever your SVM classification ways, you must specify these FLAGS\n");
	printf("//        --> 'in_dir'\n");
	printf("//        --> 'out_dir'\n");
	printf("//        --> 'number_of_pol_indic'\n");
	printf("//        --> 'svm_model_file'\n");
	printf("//        --> 'output_file_classif'\n");

	printf("//        I) IF you use an existing svm model file\n");
	printf("//            --> 'range_file'\n");
	printf("//            --> 'max_number_of_training_points'=0\n");
	printf("//            --> 'unbalanced_training_dataset'=0\n");
	printf("//            --> 'new_model'=0\n");
	printf("//            --> 'CV'=0\n");
	printf("//            --> OTHER FLAGS: 'DISABLE'\n");
	
	printf("//        II) IF you build a new svm model file\n");
	printf("//            --> 'area_file'\n");
	printf("//            --> 'training_file'\n");
	printf("//            --> 'training_file_norm'\n");
	printf("//            --> 'max_number_of_training_points'\n");
	printf("//            --> 'unbalanced_training_dataset'\n");
	printf("//            --> 'new_model'=1\n");
	printf("//            You must choose one kernel\n");
	printf("//            a) IF LINEAR kernel\n");
	printf("//               --> 'CV'=0\n");
	printf("//               --> All CV interval: 'DISABLE'\n");
	printf("//               --> 'kernel_type'=0\n");
	printf("//               --> 'cost'\n");
	printf("//               --> 'degree' and 'gamma': 'DISABLE'\n");
	printf("//            b) IF POLYNOMIAL kernel\n");
	printf("//               --> 'CV'=0\n");
	printf("//               --> All CV interval: 'DISABLE'\n");
	printf("//               --> 'kernel_type'=1\n");
	printf("//               --> 'cost'\n");
	printf("//               --> 'degree'\n");
	printf("//               --> 'gamma': 'DISABLE'\n");
	printf("//            c) IF RBF kernel\n");
	printf("//               1) IF NO cross validation\n");
	printf("//                  --> 'CV'=0\n");
	printf("//                  --> All CV interval: 'DISABLE'\n");
	printf("//                  --> 'kernel_type'=2\n");
	printf("//                  --> 'cost'\n");
	printf("//                  --> 'degree': 'DISABLE'\n");
	printf("//                  --> 'gamma'\n");	
	printf("//               2) IF cross validation\n");
	printf("//                  --> 'CV'=1\n");
	printf("//                  --> 'CV_log2c_interval'\n");
	printf("//                  --> 'CV_log2g_interval'\n");
	printf("//                  --> 'kernel_type'=2\n");
	printf("//                  --> 'cost': 'DISABLE'\n");
	printf("//                  --> 'degree': 'DISABLE'\n");
	printf("//                  --> 'gamma': 'DISABLE'\n");	
	
	
	printf("COMMAND LINE:\n");
	printf("         'svm_classifier batch_parameter polsarpro_directory file_script_svm in_dir  Bmp_flag ColorMapTrainingSet16  svm_config_file'\n");
	printf("            Where:\n");
	printf("              --> 'batch_parameter'=1\n");
	printf("              --> 'polsarpro_directory' is the directory where polsapro is installed\n");
	printf("              --> 'file_script_svm' is the COMPLETE PATH of the output svm classification script file\n");
	printf("              --> 'Bmp_flag'=1 to produce an image of the training area, 0 if not\n");
	printf("              --> 'ColorMapTrainingSet16' the COMPLETE PATH of the classification colormap\n");
	printf("              --> 'svm_config_file' the COMPLETE PATH of the input svm configuration file\n");
	
	printf("#################################################################\n");
	printf("################### END HELP of svm_classifier ##################\n");
	printf("#################################################################\n");
	exit(1);
}
/*******************************************************************************
Routine  : training_set_sampler_svm
Authors  : Laurent FERRO-FAMIL adapted to SVM problem by Cedric Lardeux
Creation : 12/2009
Update   : 
-------------------------------------------------------------------------------
Description :  Generate a binary file of the training samples of the selected
 polarimetric indicators

Inputs  : 

Outputs : 
-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
int *training_set_sampler_svm(char *in_dir_svm, char *out_dir_svm, char *area_file,
char *cluster_file, int Bmp_flag, char *ColorMapTrainingSet16,
int Npt_max_classe, int *Npt_classe, int Npolar, char **input_ind_pol)
{
	
	
/* Input/Output file pointer arrays */
    FILE *trn_file, *in_file[Npolar];


/* Strings */
    char PolarCase[20], PolarType[20];
	char file_name[Max_Char];

/* Input variables */
    int Nlig, Ncol;		/* Initial image nb of lines and rows */
    int Off_lig, Off_col;	/* Lines and rows offset values */
    int Sub_Nlig, Sub_Ncol;	/* Sub-image nb of lines and rows */

    int Nwin;			/* Analysis averaging window width */
//    int Bmp_flag;		/* Bitmap file creation flag */


    int border_error_flag = 0;
    int N_zones, zone;
    int lig, col, k, l, Np;
    int classe, area, t_pt;

    int i;
    float classe_tmp;
    int compt;

    float **border_map;
    float *cpt_zones;
	
	int *Npt_classe_tmp;

/* FUNCTION START */
/* INPUT/OUTPUT FILE OPENING*/
    for(i=0;i<Npolar;i++) {
		sprintf(file_name, "%s%s", in_dir_svm,input_ind_pol[i] );
		if ((in_file[i] = fopen(file_name, "rb")) == NULL) {
		fprintf(stderr,"Could not open input file : %s\n", input_ind_pol[i]);
		exit(1);
		}
    }

     if ((trn_file = fopen(cluster_file, "wb")) == NULL)
	    edit_error("Could not open output file : ", cluster_file);

    Nwin = 1;

    if (Bmp_flag != 0)
	Bmp_flag = 1;

printf("/********************************************************************\n");fflush(stdout);
printf("PolSARpro v5.0 is free software; you can redistribute it and/or \n");fflush(stdout);
printf("modify it under the terms of the GNU General Public License as \n");fflush(stdout);
printf("published by the Free Software Foundation; either version 2 (1991) of\n");fflush(stdout);
printf("the License, or any later version. This program is distributed in the\n");fflush(stdout);
printf("hope that it will be useful, but WITHOUT ANY WARRANTY; without even \n");fflush(stdout);
printf("the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR\n");fflush(stdout);
printf("PURPOSE. \n");fflush(stdout);
printf("\n");fflush(stdout);
printf("See the GNU General Public License (Version 2, 1991) for more details\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("*********************************************************************\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("File     : svm_classifier.c - training_set_sampler_svm\n");fflush(stdout);
printf("Project  : ESA_POLSARPRO\n");fflush(stdout);
printf("Authors  : Laurent FERRO-FAMIL, Cedric LARDEUX\n");fflush(stdout);
printf("Version  : 1.0\n");fflush(stdout);
printf("Creation : 01/2011\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("*--------------------------------------------------------------------\n");fflush(stdout);
printf("INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)\n");fflush(stdout);
printf("UMR CNRS 6164\n");fflush(stdout);
printf("Remote Sensing Group - SAPHIR Team \n");fflush(stdout);
printf("\n");fflush(stdout);
printf("UNIVERSITY OF RENNES I\n");fflush(stdout);
printf("Bat. 11D - Campus de Beaulieu\n");fflush(stdout);
printf("263 Avenue General Leclerc\n");fflush(stdout);
printf("35042 RENNES Cedex\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("*--------------------------------------------------------------------\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("Description :  Generate a binary file of the training samples of the\n");fflush(stdout);
printf("selected polarimetric indicators\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("********************************************************************/\n");fflush(stdout);

/* INPUT/OUPUT CONFIGURATIONS */
    read_config(in_dir_svm, &Nlig, &Ncol, PolarCase, PolarType);

    M_in = matrix3d_float(Npolar, Nwin, Ncol + Nwin);
    im = matrix_float(Nlig, Ncol);
    border_map = matrix_float(Nlig, Ncol);
    M_trn = vector_float(Npolar);


/* Training Area coordinates reading */
    read_coord(area_file);

    for (lig = 0; lig < Nlig; lig++)
	for (col = 0; col < Ncol; col++)
	    border_map[lig][col] = -1;

    create_borders(border_map);

    create_areas(border_map, Nlig, Ncol);
	Npt_classe = (int *) malloc((N_class) * sizeof(int));
	for (classe = 0; classe < N_class; classe++){
		Npt_classe[classe] = 0;
	}
/*Training class matrix memory allocation */
    N_zones = 0;
    for (classe = 0; classe < N_class; classe++)
	N_zones += N_area[classe];

    cpt_zones = vector_float(N_zones);

    zone = -1;
    for (classe = 0; classe < N_class; classe++) {
	compt = 0;
	classe_tmp = (float)(classe + 1);
	printf("Data Processing :  %.2f \r", 100. * (classe +1)/ N_class);fflush(stdout);
	for (area = 0; area < N_area[classe]; area++) {
	    zone++;
	    Off_lig = 2 * Nlig;
	    Off_col = 2 * Ncol;
	    Sub_Nlig = -1;
	    Sub_Ncol = -1;

	    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
		if (area_coord_l[classe][area][t_pt] < Off_lig)
		    Off_lig = area_coord_l[classe][area][t_pt];
		if (area_coord_c[classe][area][t_pt] < Off_col)
		    Off_col = area_coord_c[classe][area][t_pt];
		if (area_coord_l[classe][area][t_pt] > Sub_Nlig)
		    Sub_Nlig = area_coord_l[classe][area][t_pt];
		if (area_coord_c[classe][area][t_pt] > Sub_Ncol)
		    Sub_Ncol = area_coord_c[classe][area][t_pt];
	    }
	    Sub_Nlig = Sub_Nlig - Off_lig + 1;
	    Sub_Ncol = Sub_Ncol - Off_col + 1;

	    cpt_zones[zone] = 0;

	    for (Np = 0; Np < Npolar; Np++)
		rewind(in_file[Np]);

/* OFFSET LINES READING */
	    for (lig = 0; lig < Off_lig; lig++)
		for (Np = 0; Np < Npolar; Np++)
		    fread(&M_in[0][0][0], sizeof(float), Ncol, in_file[Np]);


/* Set the input matrix to 0 */
	    for (col = 0; col < Ncol + Nwin; col++)
		M_in[0][0][col] = 0.;


/* FIRST (Nwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
	    for (Np = 0; Np < Npolar; Np++)
		for (lig = (Nwin - 1) / 2; lig < Nwin - 1; lig++) {
		    fread(&M_in[Np][lig][(Nwin - 1) / 2], sizeof(float), Ncol, in_file[Np]);
		    for (col = Off_col; col < Sub_Ncol + Off_col; col++)
			M_in[Np][lig][col - Off_col + (Nwin - 1) / 2] = M_in[Np][lig][col + (Nwin - 1) / 2];
		    for (col = Sub_Ncol; col < Sub_Ncol + (Nwin - 1) / 2; col++)
			M_in[Np][lig][col + (Nwin - 1) / 2] = 0.;
		}


/* READING AVERAGING AND DECOMPOSITION */
	    for (lig = 0; lig < Sub_Nlig; lig++) {

		for (Np = 0; Np < Npolar; Np++) {
/* 1 line reading with zero padding */
		    if (lig < Sub_Nlig - (Nwin - 1) / 2)
			fread(&M_in[Np][Nwin - 1][(Nwin - 1) / 2], sizeof(float), Ncol, in_file[Np]);
		    else
			for (col = 0; col < Ncol + Nwin; col++)
			    M_in[Np][Nwin - 1][col] = 0.;


/* Row-wise shift */
		    for (col = Off_col; col < Sub_Ncol + Off_col; col++)
			M_in[Np][Nwin - 1][col - Off_col + (Nwin - 1) / 2] = M_in[Np][Nwin - 1][col + (Nwin - 1) / 2];
		    for (col = Sub_Ncol; col < Sub_Ncol + (Nwin - 1) / 2; col++)
			M_in[Np][Nwin - 1][col + (Nwin - 1) / 2] = 0.;
		}


		for (col = 0; col < Sub_Ncol; col++) {
		    if (border_map[lig + Off_lig][col + Off_col] == zone) {


/* Average coherency matrix element calculation */
			for (k = -(Nwin - 1) / 2; k < 1 + (Nwin - 1) / 2; k++)
			    for (l = -(Nwin - 1) / 2; l < 1 + (Nwin - 1) / 2; l++){
				fwrite(&classe_tmp, sizeof(float), 1, trn_file);
				Npt_classe[classe]++;
				for (Np = 0; Np < Npolar; Np++)
				    fwrite(&M_in[Np][(Nwin - 1) / 2 + k][(Nwin - 1) / 2 + col + l], sizeof(float), 1, trn_file);
				 }

			if (im[lig + Off_lig][col + Off_col] != 0)
			    border_error_flag = 1;
			im[lig + Off_lig][col + Off_col] = zone + 1;
		    }
		}		/*col */
/* Line-wise shift */
		for (l = 0; l < (Nwin - 1); l++)
		    for (col = 0; col < Sub_Ncol; col++)
			for (Np = 0; Np < Npolar; Np++)
			    M_in[Np][l][(Nwin - 1) / 2 + col] = M_in[Np][l + 1][(Nwin - 1) / 2 + col];
	    }			/*lig */

	}			/*area */
    }				/* Class */

    compt = 0;
    for (classe = 0; classe < N_class; classe++) {
      if (Npt_classe[classe] > Npt_max_classe){
      compt++;
      }
	}

    if(compt > 0 && Npt_max_classe!=0){		
    random_sampling(cluster_file, Npolar, N_class,Npt_classe, Npt_max_classe);
    }


    if (Bmp_flag == 1) {
	for (lig = 0; lig < Nlig; lig++)
	    for (col = 0; col < Ncol; col++)
		im[lig][col] = class_map[(int) im[lig][col]];
	sprintf(file_name, "%s%s", out_dir_svm, "svm_training_cluster_set");
	bmp_training_set(im, Nlig, Ncol, file_name, ColorMapTrainingSet16);
    }

    free_matrix3d_float(M_in, Npolar, Nwin);
	Npt_classe_tmp = (int *) malloc((N_class+1) * sizeof(int));
	Npt_classe_tmp[0] = N_class;
	for(i=1;i<N_class+1;i++){
		Npt_classe_tmp[i] = Npt_classe[i-1];
	}
	
	for(i=0;i<Npolar;i++) {
		fclose(in_file[i]);
    }

	return Npt_classe_tmp;
}


/*******************************************************************************
Routine  : read_coord
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
*-------------------------------------------------------------------------------
Description :  Read training area coordinates
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void read_coord(char *file_name)
{

    int classe, area, t_pt, zone;
    char Tmp[FilePathLength];
    FILE *file;

    if ((file = fopen(file_name, "r")) == NULL)
	edit_error("Could not open configuration file : ", file_name);

    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%i\n", &N_class);

    N_area = vector_int(N_class);

    N_t_pt = (int **) malloc((unsigned) (N_class) * sizeof(int *));
    area_coord_l =
	(float ***) malloc((unsigned) (N_class) * sizeof(float **));
    area_coord_c =
	(float ***) malloc((unsigned) (N_class) * sizeof(float **));

    zone = 0;
    for (classe = 0; classe < N_class; classe++) {
	fscanf(file, "%s\n", Tmp);
	fscanf(file, "%s\n", Tmp);
	fscanf(file, "%s\n", Tmp);
	fscanf(file, "%i\n", &N_area[classe]);

	N_t_pt[classe] = vector_int(N_area[classe]);
	area_coord_l[classe] =
	    (float **) malloc((unsigned) (N_area[classe]) *
			      sizeof(float *));
	area_coord_c[classe] =
	    (float **) malloc((unsigned) (N_area[classe]) *
			      sizeof(float *));

	for (area = 0; area < N_area[classe]; area++) {
	    zone++;
	    fscanf(file, "%s\n", Tmp);
	    fscanf(file, "%s\n", Tmp);
	    fscanf(file, "%i\n", &N_t_pt[classe][area]);
	    area_coord_l[classe][area] =
		vector_float(N_t_pt[classe][area] + 1);
	    area_coord_c[classe][area] =
		vector_float(N_t_pt[classe][area] + 1);
	    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
		fscanf(file, "%s\n", Tmp);
		fscanf(file, "%s\n", Tmp);
		fscanf(file, "%f\n", &area_coord_l[classe][area][t_pt]);
		fscanf(file, "%s\n", Tmp);
		fscanf(file, "%f\n", &area_coord_c[classe][area][t_pt]);
	    }
	    area_coord_l[classe][area][t_pt] =
		area_coord_l[classe][area][0];
	    area_coord_c[classe][area][t_pt] =
		area_coord_c[classe][area][0];
	}
    }
    class_map = vector_float(zone + 1);
    class_map[0] = 0;
    zone = 0;
    for (classe = 0; classe < N_class; classe++)
	for (area = 0; area < N_area[classe]; area++) {
	    zone++;
	    class_map[zone] = (float) classe + 1.;
	}
    fclose(file);

}

/*******************************************************************************
Routine  : create_borders
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
*-------------------------------------------------------------------------------
Description : Create borders
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void create_borders(float **border_map)
{

    int classe, area, t_pt;
    float label_area, x, y, x0, y0, x1, y1, sig_x, sig_y, sig_y_sol, y_sol,
	A, B;

    label_area = -1;

    for (classe = 0; classe < N_class; classe++) {
	for (area = 0; area < N_area[classe]; area++) {
	    label_area++;
	    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
		x0 = area_coord_c[classe][area][t_pt];
		y0 = area_coord_l[classe][area][t_pt];
		x1 = area_coord_c[classe][area][t_pt + 1];
		y1 = area_coord_l[classe][area][t_pt + 1];
		x = x0;
		y = y0;
		sig_x = (x1 > x0) - (x1 < x0);
		sig_y = (y1 > y0) - (y1 < y0);
		border_map[(int) y][(int) x] = label_area;
		if (x0 == x1) {
/* Vertical segment */
		    while (y != y1) {
			y += sig_y;
			border_map[(int) y][(int) x] = label_area;
		    }
		} else {
		    if (y0 == y1) {
/* Horizontal segment */
			while (x != x1) {
			    x += sig_x;
			    border_map[(int) y][(int) x] = label_area;
			}
		    } else {
/* Non horizontal & Non vertical segment */
			A = (y1 - y0) / (x1 - x0);	/* Segment slope  */
			B = y0 - A * x0;	/* Segment offset */
			while ((x != x1) || (y != y1)) {
			    y_sol = my_round(A * (x + sig_x) + B);
			    if (fabs(y_sol - y) > 1) {
				sig_y_sol = (y_sol > y) - (y_sol < y);
				while (y != y_sol) {
				    y += sig_y_sol;
				    x = my_round((y - B) / A);
				    border_map[(int) y][(int) x] =
					label_area;
				}
			    } else {
				y = y_sol;
				x += sig_x;
			    }
			    border_map[(int) y][(int) x] = label_area;
			}
		    }
		}
	    }
	}
    }
}

/*******************************************************************************
Routine  : create_areas
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
*-------------------------------------------------------------------------------
Description : Create areas
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void create_areas(float **border_map, int Nlig, int Ncol)
{

/* Avoid recursive algorithm due to problems encountered under Windows */
    int change_tot, change, classe, area, t_pt;
    float x, y, x_min, x_max, y_min, y_max, label_area;
    float **tmp_map;
    struct Pix *P_top, *P1, *P2;

    tmp_map = matrix_float(Nlig, Ncol);

    label_area = -1;

    for (classe = 0; classe < N_class; classe++) {
	for (area = 0; area < N_area[classe]; area++) {
	    label_area++;
	    x_min = Ncol;
	    y_min = Nlig;
	    x_max = -1;
	    y_max = -1;
/* Determine a square zone containing the area under study*/
	    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
		x = area_coord_c[classe][area][t_pt];
		y = area_coord_l[classe][area][t_pt];
		if (x < x_min)
		    x_min = x;
		if (x > x_max)
		    x_max = x;
		if (y < y_min)
		    y_min = y;
		if (y > y_max)
		    y_max = y;
	    }
	    for (x = x_min; x <= x_max; x++)
		for (y = y_min; y <= y_max; y++)
		    tmp_map[(int) y][(int) x] = 0;

	    for (x = x_min; x <= x_max; x++) {
		tmp_map[(int) y_min][(int) x] =
		    -(border_map[(int) y_min][(int) x] != label_area);
		y = y_min;
		while ((y <= y_max)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    y++;
		}
		tmp_map[(int) y_max][(int) x] =
		    -(border_map[(int) y_max][(int) x] != label_area);
		y = y_max;
		while ((y >= y_min)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    y--;
		}
	    }
	    for (y = y_min; y <= y_max; y++) {
		tmp_map[(int) y][(int) x_min] =
		    -(border_map[(int) y][(int) x_min] != label_area);
		x = x_min;
		while ((x <= x_max)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    x++;
		}
		tmp_map[(int) y][(int) x_max] =
		    -(border_map[(int) y][(int) x_max] != label_area);
		x = x_max;
		while ((x >= x_min)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    x--;
		}
	    }

	    change = 0;
	    for (x = x_min; x <= x_max; x++)
		for (y = y_min; y <= y_max; y++) {
		    change = 0;
		    if (tmp_map[(int) y][(int) (x)] == -1) {
			if ((x - 1) >= x_min) {
			    if ((tmp_map[(int) (y)][(int) (x - 1)] != 0)
				|| (border_map[(int) (y)][(int) (x - 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((x + 1) <= x_max) {
			    if ((tmp_map[(int) (y)][(int) (x + 1)] != 0)
				|| (border_map[(int) (y)][(int) (x + 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y - 1) >= y_min) {
			    if ((tmp_map[(int) (y - 1)][(int) (x)] != 0)
				|| (border_map[(int) (y - 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y + 1) <= y_max) {
			    if ((tmp_map[(int) (y + 1)][(int) (x)] != 0)
				|| (border_map[(int) (y + 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;
		    }
		    if ((border_map[(int) y][(int) x] != label_area)
			&& (change < 4)) {
			P2 = NULL;
			P2 = Create_Pix(P2, x, y);
			if (change == 0) {
			    P_top = P2;
			    P1 = P_top;
			    change = 1;
			} else {
			    P1->next = P2;
			    P1 = P2;
			}
		    }
		}
	    change_tot = 1;
	    while (change_tot == 1) {
		change_tot = 0;
		P1 = P_top;
		while (P1 != NULL) {
		    x = P1->x;
		    y = P1->y;
		    change = 0;
		    if (tmp_map[(int) y][(int) (x)] == -1) {
			if ((x - 1) >= x_min)
			    if ((border_map[(int) y][(int) (x - 1)] !=
				 label_area)
				&& (tmp_map[(int) y][(int) (x - 1)] != -1)) {
				tmp_map[(int) y][(int) (x - 1)] = -1;
				change = 1;
			    }
			if ((x + 1) <= x_max)
			    if ((border_map[(int) y][(int) (x + 1)] !=
				 label_area)
				&& (tmp_map[(int) y][(int) (x + 1)] != -1)) {
				tmp_map[(int) y][(int) (x + 1)] = -1;
				change = 1;
			    }
			if ((y - 1) >= y_min)
			    if ((border_map[(int) (y - 1)][(int) (x)] !=
				 label_area)
				&& (tmp_map[(int) (y - 1)][(int) (x)] !=
				    -1)) {
				tmp_map[(int) (y - 1)][(int) (x)] = -1;
				change = 1;
			    }
			if ((y + 1) <= y_max)
			    if ((border_map[(int) (y + 1)][(int) (x)] !=
				 label_area)
				&& (tmp_map[(int) (y + 1)][(int) (x)] !=
				    -1)) {
				tmp_map[(int) (y + 1)][(int) (x)] = -1;
				change = 1;
			    }
			if (change == 1)
			    change_tot = 1;
			change = 0;

			if ((x - 1) >= x_min) {
			    if ((tmp_map[(int) (y)][(int) (x - 1)] != 0)
				|| (border_map[(int) (y)][(int) (x - 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((x + 1) <= x_max) {
			    if ((tmp_map[(int) (y)][(int) (x + 1)] != 0)
				|| (border_map[(int) (y)][(int) (x + 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y - 1) >= y_min) {
			    if ((tmp_map[(int) (y - 1)][(int) (x)] != 0)
				|| (border_map[(int) (y - 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y + 1) <= y_max) {
			    if ((tmp_map[(int) (y + 1)][(int) (x)] != 0)
				|| (border_map[(int) (y + 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;

			if (change == 4) {
			    change_tot = 1;
			    if (P_top == P1)
				P_top = Remove_Pix(P_top, P1);
			    else
				P1 = Remove_Pix(P_top, P1);
			}
		    }
		    P1 = P1->next;
		}		/*while P1 */
	    }			/*while change_tot */
	    for (x = x_min; x <= x_max; x++)
		for (y = y_min; y <= y_max; y++)
		    if (tmp_map[(int) (y)][(int) (x)] == 0)
			border_map[(int) (y)][(int) (x)] = label_area;
	}
    }
    free_matrix_float(tmp_map, Nlig);

}
