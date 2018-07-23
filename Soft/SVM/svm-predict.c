/*
 * 
 * This function is based on the LIBSVM V2.29, and adapted to use binary file
 * 
 */
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "svm.h"
#include <unistd.h>
#include <math.h>
#include <time.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES */
#include "../lib/PolSARproLib.h"

const long memory = (long)250000000;
struct svm_node *x;
int max_nr_attr = 64;

struct svm_model* model;
int predict_probability=0;

static char *line = NULL;

double *feature_max;
double *feature_min;

double lower=-1.0,upper=1.0;

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

void check_file(char *file)
{
#ifdef _WIN32
    int i;
    i = 0;
    while (file[i] != '\0') {
	if (file[i] == '/')
	    file[i] = '\\';
	i++;
    }
#endif
}

void check_dir(char *dir)
{
#ifndef _WIN32
    strcat(dir, "/");
#else
    int i;
    i = 0;
    while (dir[i] != '\0') {
	if (dir[i] == '/')
	    dir[i] = '\\';
	i++;
    }
    strcat(dir, "\\");
#endif
}

void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType)
{
    char file_name[FilePathLength];
    char Tmp[FilePathLength];
    FILE *file;

    sprintf(file_name, "%sconfig.txt", dir);
    if ((file = fopen(file_name, "r")) == NULL) {
      printf("\n A processing error occured ! \n Could not open configuration file : %s\n", file_name);
      exit(1);
      }

    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%i\n", &*Nlig));
    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%i\n", &*Ncol));
    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%s\n", PolarCase));
    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%s\n", Tmp));
    if(fscanf(file, "%s\n", PolarType));

    fclose(file);
}

float *vector_float(int nrh)
{
    int ii;
    float *m;

    m = (float *) malloc((unsigned) (nrh + 1) * sizeof(float));
    if (!m) {
      printf("\n A processing error occured ! \n allocation failure 1 in vector_float()\n");
      exit(1);
      }

    for (ii = 0; ii < nrh; ii++)
	m[ii] = 0.;
    return m;
}

void free_vector_float(float *m)
{
    free((float *) m);
}

float **matrix_float(int nrh, int nch)
{
    int i, j;
    float **m;

    m = (float **) malloc((unsigned) (nrh) * sizeof(float *));
    if (!m) {
      printf("\n A processing error occured ! \n allocation failure 1 in matrix()\n");
      exit(1);
      }

    for (i = 0; i < nrh; i++) {
	m[i] = (float *) malloc((unsigned) (nch) * sizeof(float));
	if (!m[i]) {
      printf("\n A processing error occured ! \n allocation failure 2 in matrix()\n");
      exit(1);
      }
    }
    for (i = 0; i < nrh; i++)
	for (j = 0; j < nch; j++)
	    m[i][j] = 0.;
    return m;
}

void free_matrix_float(float **m, int nrh)
{
    int i;
    for (i = nrh - 1; i >= 0; i--)
	free((float *) (m[i]));
}

/**********************************************************************/
/**********************************************************************/
/**********************************************************************/

double scale(int index, double value);
void restore_scale_param(FILE *range_restore, int Npolar);

void exit_input_error(int line_num)
{
	fprintf(stderr,"Wrong input format at line %d\n", line_num);
	exit(1);
}

void predict(FILE **input, FILE *output, FILE *output_dist, FILE *output_prob,int predict_probability, int dist_opt, int Ncol, int Nlig, int Npolar)
{
	int svm_type=svm_get_svm_type(model);
	int nr_class=svm_get_nr_class(model);
	double *prob_estimates=NULL;
	int i,j,k,l,p,n;
	long max_num_pixel, num_pixel_block, compt_pixel,num_rest_pixel;
	int max_num_line, num_block, num_rest_line, count;
	int lig, col, ind, total_pixel, compt;
	float **V_pol_block, **V_pol_rest; /* Vector of polarimetrics indicators  for one line */
	double *w2_predict=NULL;
	float **w2_predict_out=NULL;
	float *mean_dist=NULL;
	float *max_prob=NULL;
	float **prob_estimates_out=NULL;
	float *output_label=NULL;

	// We compute the necessary number of block and remaining pixel	
	max_num_pixel = (long)floor(memory /((long)4 *(Npolar + 3 + nr_class * (nr_class - 1.)/2. + nr_class)));
//	max_num_line = (int)floor(max_num_pixel / (long)Ncol);
	max_num_line = floor(((int)max_num_pixel) / Ncol);
	
	num_pixel_block = (long)max_num_line * (long)Ncol;
	num_block = (int)floor(Nlig / max_num_line);
	num_rest_line = Nlig - max_num_line * num_block;
	num_rest_pixel = num_rest_line * Ncol;
	total_pixel = Nlig * Ncol;

	l = 0; count = 0;
	
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
printf("File     : svm-predict.c\n");fflush(stdout);
printf("Project  : ESA_POLSARPRO\n");fflush(stdout);
printf("Authors  : Cedric LARDEUX\n");fflush(stdout);
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
printf("Description :  This function is based on the LIBSVM V2.29 and adapted\n");fflush(stdout);
printf("to process PolSARpro binary file\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("********************************************************************/\n");fflush(stdout);

	if(predict_probability)
	{
		if (svm_type==NU_SVR || svm_type==EPSILON_SVR)
			printf("Prob. model for test data: target value = predicted value + z,\nz: Laplace distribution e^(-|z|/sigma)/(2sigma),sigma=%g\n",svm_get_svr_probability(model));
		else
		{
			int *labels=(int *) malloc(nr_class*sizeof(int));
			svm_get_labels(model,labels);
			prob_estimates = (double *) malloc(nr_class*sizeof(double));
			free(labels);
		}
	}

	compt = 0;
	if(num_block > 0){//Loop on the LINE block	
		V_pol_block = matrix_float((int)num_pixel_block,(int)Npolar);
		output_label = vector_float((int)num_pixel_block);
		
		if (dist_opt){
			mean_dist = vector_float((int)num_pixel_block);
			w2_predict_out = matrix_float((int)num_pixel_block,nr_class*(nr_class-1)/2);
		}
		
		if (predict_probability){
			prob_estimates_out = matrix_float((int)num_pixel_block,nr_class);
			max_prob = vector_float((int)num_pixel_block);
		}	
		
		for (i=0; i<num_block; i++){
			for (ind = 0; ind < Npolar; ind++){
			compt_pixel = 0;
				for (lig = i * max_num_line; lig < i * max_num_line + max_num_line; lig++){
					for (col = 0; col < Ncol; col++){
						if(fread(&V_pol_block[compt_pixel][ind], sizeof(float), 1, input[ind]));
						compt_pixel++;
					}
				}			
			}/* Lig */	

			for (j=0; j< num_pixel_block; j++){
				for (k=0; k<Npolar; k++){
					if(k>=max_nr_attr-1)	// need one more for index = -1
					{
						max_nr_attr *= 2;
						x = (struct svm_node *) realloc(x,max_nr_attr*sizeof(struct svm_node));
					}
					x[k].index = k+1;
					x[k].value = scale(k, (double)V_pol_block[j][k]);
				}
				x[k].index = -1;
				double predict_label;
				
				if (predict_probability && (svm_type==C_SVC || svm_type==NU_SVC)){
				predict_label = svm_predict_probability(model,x,prob_estimates);
				
				if(dist_opt){// Mean map distance enable	
					w2_predict = svm_w2(model,x);
					mean_dist[j] = 0.;
					count = 0;
					l=0;
				}
				output_label[j] = (float)predict_label;
				max_prob[j] = 0.;
				for(p=0;p<nr_class;p++){
					if(dist_opt){// Mean map distance enable
						for(n=p+1;n<nr_class;n++){
							w2_predict_out[j][l] =(float)w2_predict[l];
							if(p+1 == output_label[j] || n+1 == output_label[j]){
								mean_dist[j] = mean_dist[j] + w2_predict_out[j][l];
								count = count + 1;
							}
							l++;
						}
					}
					prob_estimates_out[j][p] = (float)prob_estimates[p];
					if(max_prob[j] < prob_estimates_out[j][p] ){
						max_prob[j] = prob_estimates_out[j][p];
					}
				}
				if(dist_opt){// Mean map distance enable
					mean_dist[j] = mean_dist[j] / (float)count;
				}
			}
			else// No probability estimate
			{
				predict_label = svm_predict(model,x);
				output_label[j] = (float)predict_label;
				
				
				if(dist_opt){// Mean map distance enable
					w2_predict = svm_w2(model,x);
					mean_dist[j] = 0.;
					count = 0;
					l=0;
					for(p=0;p<nr_class;p++){
						for(n=p+1;n<nr_class;n++){
							w2_predict_out[j][l] =(float)w2_predict[l];
						
							if(p+1 == output_label[j] || n+1 == output_label[j]){
								mean_dist[j] = mean_dist[j] + w2_predict_out[j][l];
								count = count + 1;
							}
							l++;
						}
					}
					mean_dist[j] = mean_dist[j] / (float)count;
				}					
			}
				printf("Data Processing : %.2f %s\r", (100. * (float)compt)/((float)total_pixel),"%");fflush(stdout);
				compt++;
			}/* pixels block */
				
			for(k=0;k<num_pixel_block;k++){
				fwrite(&output_label[k], sizeof(float), 1, output);
			}

			if(dist_opt){
				for(k=0;k<num_pixel_block;k++){
					fwrite(&mean_dist[k], sizeof(float), 1, output_dist);
				}
			}
			if(predict_probability){
				for(k=0;k<num_pixel_block;k++){
					fwrite(&max_prob[k], sizeof(float), 1, output_prob);
				}
			}			
		}//END Loop on the LINE block
		free_matrix_float(V_pol_block, (int)num_pixel_block);
		free_vector_float(output_label);
		if(dist_opt){
			free_matrix_float(w2_predict_out, (int)num_pixel_block);
			free_vector_float(mean_dist);
		}
		
		if(predict_probability){
			free_matrix_float(prob_estimates_out, (int)num_pixel_block);
			free_vector_float(max_prob);
		}				
	}	
	
	if(num_rest_line > 0){// Loop on the remaining line
		V_pol_rest = matrix_float((int)num_rest_pixel,(int)Npolar);
		output_label = vector_float((int)num_rest_pixel);
		
		if (dist_opt){
			mean_dist = vector_float((int)num_rest_pixel);
			w2_predict_out = matrix_float((int)num_rest_pixel,nr_class*(nr_class-1)/2);
		}
		
		if (predict_probability){
			prob_estimates_out = matrix_float((int)num_rest_pixel,nr_class);
			max_prob = vector_float((int)num_rest_pixel);
		}
		compt_pixel = 0;

		for (ind = 0; ind < Npolar; ind++){
			compt_pixel = 0;
			for (lig = num_block * max_num_line; lig < num_block * max_num_line + num_rest_line; lig++){
				for (col = 0; col < Ncol; col++){
					if(fread(&V_pol_rest[compt_pixel][ind], sizeof(float), 1, input[ind]));
					compt_pixel++;
				}
			}
		}		

		for (j=0; j< num_rest_pixel; j++){
			for (k=0; k<Npolar; k++){
				
				if(k>=max_nr_attr-1)	// need one more for index = -1
				{
					max_nr_attr *= 2;
					x = (struct svm_node *) realloc(x,max_nr_attr*sizeof(struct svm_node));
				}
				x[k].index = k+1;
				x[k].value = scale(k, (double)V_pol_rest[j][k]);
			}
			x[k].index = -1;
			double predict_label;
			
			if (predict_probability && (svm_type==C_SVC || svm_type==NU_SVC)){
				predict_label = svm_predict_probability(model,x,prob_estimates);
				
				if(dist_opt){// Mean map distance enable	
					w2_predict = svm_w2(model,x);
					mean_dist[j] = 0.;
					count = 0;
					l=0;
				}
				output_label[j] = (float)predict_label;
				max_prob[j] = 0.;
				for(p=0;p<nr_class;p++){
					if(dist_opt){// Mean map distance enable
						for(n=p+1;n<nr_class;n++){
							w2_predict_out[j][l] =(float)w2_predict[l];
							if(p+1 == output_label[j] || n+1 == output_label[j]){
								mean_dist[j] = mean_dist[j] + w2_predict_out[j][l];
								count = count + 1;
							}
							l++;
						}
					}
					prob_estimates_out[j][p] = (float)prob_estimates[p];
					if(max_prob[j] < prob_estimates_out[j][p] ){
						max_prob[j] = prob_estimates_out[j][p];
					}
				}
				if(dist_opt){// Mean map distance enable
					mean_dist[j] = mean_dist[j] / (float)count;
				}
			}
			else// No probability estimate
			{
				predict_label = svm_predict(model,x);
				output_label[j] = (float)predict_label;
				
				
				if(dist_opt){// Mean map distance enable
					w2_predict = svm_w2(model,x);
					mean_dist[j] = 0.;
					count = 0;
					l=0;
					for(p=0;p<nr_class;p++){
						for(n=p+1;n<nr_class;n++){
							w2_predict_out[j][l] =(float)w2_predict[l];
						
							if(p+1 == output_label[j] || n+1 == output_label[j]){
								mean_dist[j] = mean_dist[j] + w2_predict_out[j][l];
								count = count + 1;
							}
							l++;
						}
					}
					mean_dist[j] = mean_dist[j] / (float)count;
				}					
			}
			printf("Data Processing : %.2f %s\r", (100. * (float)compt)/((float)total_pixel),"%");fflush(stdout);
			compt++;
		}/* pixels block */
				
		for(j=0;j<num_rest_pixel;j++){
			fwrite(&output_label[j], sizeof(float), 1, output);
		}
		
		if(dist_opt){
			for(j=0;j<num_rest_pixel;j++){
				fwrite(&mean_dist[j], sizeof(float), 1, output_dist);
			}
			free_vector_float(mean_dist);
			free_matrix_float(w2_predict_out, (int)num_rest_pixel);
		 }
		if(predict_probability){
			for(j=0;j<num_rest_pixel;j++){
				fwrite(&max_prob[j], sizeof(float), 1, output_prob);
			}
			free_vector_float(max_prob);
			free_matrix_float(prob_estimates_out, (int)num_rest_pixel);
			free(prob_estimates);
		}			
		free_matrix_float(V_pol_rest, (int)num_rest_pixel);		
		free_vector_float(output_label);
	}	
}

void restore_scale_param(FILE *range_restore, int Npolar)
{
	int idx;
	double fmin, fmax;
	
	feature_max = (double *)malloc((Npolar)* sizeof(double));
	feature_min = (double *)malloc((Npolar)* sizeof(double));

	if (fgetc(range_restore) == 'x') {
	  if(fscanf(range_restore, "%lf %lf\n", &lower, &upper));


	while(fscanf(range_restore,"%d %lf %lf\n",&idx,&fmin,&fmax)==3)
	{
		if(idx<=Npolar)
		{
			feature_min[idx-1] = fmin;
			feature_max[idx-1] = fmax;
		}
	}
}
	fclose(range_restore);
}

double scale(int index, double value)
{
	/* skip single-valued attribute */
	if(feature_max[index] == feature_min[index])
		return 0;
	if(value == feature_min[index])
		value = lower;
	else if(value == feature_max[index])
		value = upper;
	else
		value = lower + (upper-lower) * 
			(value-feature_min[index])/
			(feature_max[index]-feature_min[index]);
return value;
}

void exit_with_help()
{
	printf(
	"Usage: svm-predict  dist_opt prob_opt in_dir_svm svm_model_file range_file output_classif number_of_pol_ind input_ind1 input_ind_2 ...\n"
	"options:\n"
	"-b probability_estimates: whether to predict probability estimates, 0 or 1 (default 0); for one-class SVM only 0 is supported\n"
	);
	exit(1);
}

int main(int argc, char **argv)
{
/* Polsarpro Variables */
	char PolarCase[20], PolarType[20], in_dir_svm[FilePathLength], range_file[FilePathLength], output_classif[FilePathLength];
	char file_name[FilePathLength];
	int Nlig, Ncol,dist_opt, predict_probability;		/* Initial image nb of lines and rows */
	FILE *class_file, *range_restore;
	FILE *output_dist_file=NULL, *prob_file=NULL;
	int Npolar; /* Number of polarimetrics indicators */

/* Libsvm Variables */
	int i;    

	if (argc >= 8) {
		dist_opt = atoi(argv[1]);
		predict_probability = atoi(argv[2]);
		strcpy(in_dir_svm, argv[3]);
		sprintf(file_name, "%s", argv[4]);
		if((model=svm_load_model(file_name))==0)
			{
			fprintf(stderr,"can't open model file %s\n",file_name);
			exit(1);
			}
		strcpy(range_file, argv[5]);
		strcpy(output_classif, argv[6]);
		Npolar = atoi(argv[7]);
		} else {
		fprintf(stderr,"svm-predict dist_opt prob_opt in_dir_svm svm_model_file range_file output_classif number_of_pol_ind input_ind1 input_ind_2 ...\n");
		exit(1);
		}

	sprintf(file_name, "%s", output_classif);
	if ((class_file = fopen(file_name, "wb")) == NULL)
		{
			fprintf(stderr,"Could not open output file : %s",file_name);
			exit(1);
		}

	check_dir(in_dir_svm);
	read_config(in_dir_svm, &Nlig, &Ncol, PolarCase, PolarType);

	FILE *in_file[Npolar];

	for(i=8;i<argc;i++)
	{
	  sprintf(file_name, "%s%s", in_dir_svm, argv[i]);
	  if ((in_file[i-8] = fopen(file_name, "rb")) == NULL) {
	  fprintf(stderr,"Could not open input file : %s\n", file_name);
	  	
		exit(1);
	  }
	}
	
	if(dist_opt){
		sprintf(file_name, "%s_dist", output_classif);
		if ((output_dist_file = fopen(file_name, "wb")) == NULL){
			fprintf(stderr,"Could not open output distance file : %s\n",file_name);
			exit(1);
		}
	}
	
	sprintf(file_name, "%s", range_file);
	range_restore = fopen(file_name, "r");
	restore_scale_param(range_restore,Npolar);

	x = (struct svm_node *) malloc(max_nr_attr*sizeof(struct svm_node));
	if(predict_probability){
		sprintf(file_name, "%s_prob", output_classif);
		if ((prob_file = fopen(file_name, "wb")) == NULL){
			fprintf(stderr,"Could not open prob file : %s\n",file_name);
			exit(1);
		}
		
		if(svm_check_probability_model(model)==0)
		{
			fprintf(stderr,"Model does not support probabiliy estimates\n");
			exit(1);
		}
	}
	else
	{
		if(svm_check_probability_model(model)!=0)
			printf("Model supports probability estimates, but disabled in prediction.\n");
	}

	predict(in_file,class_file, output_dist_file,prob_file,predict_probability, dist_opt,Ncol, Nlig, Npolar);
	svm_destroy_model(model);
	free(x);
	free(line);
	
	for(i=0;i<Npolar;i++){
		fclose(in_file[i]);
	}
	fclose(class_file);
	
	if(dist_opt){
		fclose(output_dist_file);
	}
	
	if(predict_probability){
		fclose(prob_file);
	}
	return 0;
}
