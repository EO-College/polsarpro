/*
 *      write_best_cv_results.c
 *      
 * 		This program change the svm_configuration_file to take the best Cost and Gamma
 * 		parameters from the CV of the RBF kernel
 */


/* ROUTINES */
#include "../lib/PolSARproLib.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>


/* GLOBAL VARIABLES */
char *config_file, *in_dir_svm,  *out_dir_svm;
char *Npol,  *area_file,   *cluster_file,  *range_file;
char *cluster_file_norm,  *svm_model_file,  *classification_file;
char *Npt_max_classe,  *unbalanced_training,  *new_model,  *cv;
char *log2c_begin,  *log2c_end, *log2c_step,  *log2g_begin;
char *log2g_end, *log2g_step, *kernel_type,  *cost;
char *degree;//,  *gamma;
int Max_Char = 1024;

float *read_cv_file(char *cv_file, float *line_tab_cv);

int main(int argc, char** argv)
{
	char file_name[Max_Char];
	char disable_word[Max_Char];
	sprintf(disable_word, "DISABLE");
	
	char out_dir_svm[Max_Char];

	char best_c_g_path_file[Max_Char];

	FILE* file_best_cv;
	
	float *best_tab_cv;	
	
	if (argc == 3) {
		strcpy(out_dir_svm, argv[1]);	
		strcpy(best_c_g_path_file, argv[2]);
	} else{
			edit_error("write_best_cv_results out_dir  output_best_c_g_path_file\n", "");
	} 

	best_tab_cv = calloc(3,sizeof(float));
	sprintf(file_name, "%ssvm_cross_val.txt", out_dir_svm);
	best_tab_cv = read_cv_file(file_name,best_tab_cv);//We read the best C and Gamma value
	
	//Copy the best (c,g) parameter into a file
	if ((file_best_cv = fopen(best_c_g_path_file, "w")) == NULL) {
		fprintf(stderr,"Could not open output best cross validation file: %s\n", file_name);
		exit(1);
	}
	fprintf(file_best_cv, "%f\n", best_tab_cv[0]);
	fprintf(file_best_cv, "%f\n", best_tab_cv[1]);
	fclose(file_best_cv);
	
	free(best_tab_cv);

	
	return 0;
}

/***************************
**********FONCTIONS*********
 ***************************/


/*******************************************************************************
Routine  : read_cv_file
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  read the file which contain the accuracies of the CV


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
float *read_cv_file(char *cv_file, float *line_tab_cv)
{
    FILE* file_cv;
	float *line_tab_cv_tmp;
	char buff_1[Max_Char];
	char buff_2[Max_Char];
	char buff_3[Max_Char];
	
	line_tab_cv_tmp = calloc(3,sizeof(float));

	if ((file_cv = fopen(cv_file, "r")) == NULL) {
		fprintf(stderr,"Could not open svm  file : %s\n", cv_file);
		exit(1);
	}

	while(fscanf(file_cv,"%s %s %s",buff_1,buff_2,buff_3)!=EOF){
		if(atof(buff_3) > line_tab_cv[2]){
			line_tab_cv[0] = atof(buff_1);
			line_tab_cv[1] = atof(buff_2);
			line_tab_cv[2] = atof(buff_3);
		}
	}

	fclose(file_cv);
	line_tab_cv[0] = pow(2,line_tab_cv[0]);
	line_tab_cv[1] = pow(2,line_tab_cv[1]);

    free(line_tab_cv_tmp);
    return line_tab_cv;
}
