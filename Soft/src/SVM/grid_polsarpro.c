/*
 *      grid_polsarpro.c
 *      
 *      This program run the cross validation of RBF kernel parameters (Cost C and Gamma g)
 *      
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation; either version 2 of the License, or
 *      (at your option) any later version.
 *      
 *      This program is distributed in the hope that it will be useful,
 *      but WITHOUT ANY WARRANTY; without even the implied warranty of
 *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *      GNU General Public License for more details.
 *      
 *      You should have received a copy of the GNU General Public License
 *      along with this program; if not, write to the Free Software
 *      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 *      MA 02110-1301, USA.
 */


/*
 * Ajouter dans le main un test des begin,end et step ppoour voir si cohérent :
 * begin < end : step > 0
 * begin > end : step < 0
 * 
 * 
 */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

/* ROUTINES */
#include "../lib/PolSARproLib.h"

void range_f(int *range_val, int nr, int begin, int end, int step);
void permute_sequence(int nr, int *seq);
void calculate_jobs(int **jobs ,int nr_c, int c_begin, int c_end, int c_step,
int nr_g, int g_begin, int g_end, int g_step);
char* extract_dir(char *path_file);
void write_gnuplot_script(char *script_gp_path, char *out_put_cv_txt_path,int nr_c, int c_begin, int c_end,
int nr_g, int g_begin, int g_end, int best_c, int best_g, float best_acc);
void write_gnuplot_script_png(char *script_gp_path, char *out_put_cv_txt_path, char *out_put_cv_png_path,int nr_c, int c_begin, int c_end,
int nr_g, int g_begin, int g_end, int best_c, int best_g, float best_acc);

/* GLOBAL VARIABLES */
int Max_Char = 1024;

int main(int argc, char** argv)
{
	int **jobs = NULL,value,i,n_elts;
	int nr_c = 0, c_begin, c_end, c_step;
	int nr_g = 0, g_begin, g_end, g_step;
	int best_c, best_g;
	float best_acc = -1;
	float cost_tmp,gamma_tmp, accuracy;
	int fold=5;
	int Npolar;
	char cluster_file_norm[Max_Char], svm_model_file[Max_Char];
	char svm_train_path[Max_Char], gnuplot_path[Max_Char];
	char out_put_cv_txt_path[Max_Char],out_put_cv_png_path[Max_Char];
	char additional_svm_param[Max_Char];
	char command_line[Max_Char];
	char name_tmp_accuracy[Max_Char],name_script_gp[Max_Char];
	char* script_gp_path;
	char* tmp_dir;
	char buffer[Max_Char], gp_cmd[Max_Char];
	char tmp_crossval_txt[Max_Char], tmp_script_gp_path[Max_Char];

	FILE *file_out_CV, *tmp_accuracy, *gp;
	
	// Name of the file which contain the accuracy of on step (c,g) of the CV
	sprintf(name_tmp_accuracy, "tmp_crossval.txt");
	// Name of the gnuplot script file
	sprintf(name_script_gp, "script_gnuplot.gp");
	
	// parse options
	if (argc >= 16) {
	c_begin = atoi(argv[2]);
	c_end = atoi(argv[3]);
	c_step = atoi(argv[4]);
	
	g_begin = atoi(argv[6]);
	g_end = atoi(argv[7]);
	g_step = atoi(argv[8]);
	
	strcpy(out_put_cv_txt_path, argv[10]);
	strcpy(out_put_cv_png_path, argv[12]);
	
	strcpy(svm_train_path, argv[14]);
	strcpy(gnuplot_path, argv[16]);
	
    sprintf(additional_svm_param,"%s","");
	for(i=17;i<argc - 3;i++){
		sprintf(additional_svm_param, "%s %s", additional_svm_param,argv[i]);
	}	
	
	Npolar = atoi(argv[argc-1]);
	strcpy(svm_model_file, argv[argc-2]);
	strcpy(cluster_file_norm, argv[argc-3]);
	}else{
		fprintf(stderr,"The synntax is not good ! :\n");
		fprintf(stderr,"Usage: grid_polsarpro -log2c begin end step -log2g begin end step  -out cv_txt_path -png cv_png_path -svmtrain svm_train_path -gnuplot gnuplot_path [additional parameters for svm-train like wi] training_set_file model_file number_of_polarimetric_indices\n");
		exit(1);
	}
	
	//Loop to count the number of c test step
	value = c_begin;
	if(c_begin > c_end){
		while(value >= c_end){
			value = value + c_step;
			nr_c++;
		}
	}else{
		while(value <= c_end){
			value = value + c_step;
			nr_c++;
		}
	}
	
	//Loop to count the number of g test step
	value = g_begin;
	if(g_begin > g_end){
		while(value >= g_end){
			value = value + g_step;
			nr_g++;
		}
	}else{
		while(value <= g_end){
			value = value + g_step;
			nr_g++;
		}
	}
	
	n_elts = nr_c * nr_g; // Content the number of (c,g) to test
	jobs = malloc(n_elts*sizeof(int*));
	if (jobs == NULL){
		fprintf(stderr,"Not enough memory!\n");
		exit(1);
	}
	for(i=0;i<n_elts;i++){
		jobs[i] = malloc(2 * sizeof(int));
		if (jobs[i] == NULL){
			fprintf(stderr,"Not enough memory!\n");
			exit(1);
		}
	}

	// define the order to browse the CV grid (c,g)
	calculate_jobs(jobs,nr_c, c_begin, c_end, c_step,nr_g, g_begin, g_end, g_step);
	remove(out_put_cv_txt_path);
	
	//We build the path of the temporary accuracy file
	tmp_dir = extract_dir(cluster_file_norm);
	sprintf(tmp_crossval_txt, "%s%s", tmp_dir,name_tmp_accuracy);
	sprintf(tmp_script_gp_path, "%s%s", tmp_dir,name_script_gp);
	//We built the first command of gnuplot to call the gnuplot pipe
//	sprintf(gp_cmd, "%s\"%s\" -persist", gp_cmd,gnuplot_path);
//	gp=popen(gp_cmd, "w");
//	if (gp==NULL)
//           {
//             printf("Error opening pipe to GNU plot. Check if you have it! \n");
//             exit(0);
//           }
           
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
printf("File     : grid_polsarpro.c\n");fflush(stdout);
printf("Project  : ESA_POLSARPRO\n");fflush(stdout);
printf("Authors  : Cedric LARDEUX\n");fflush(stdout);
printf("Version  : 1.0\n");fflush(stdout);
printf("Creation : 01/2011\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("*--------------------------------------------------------------------\n");fflush(stdout);
printf("INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)\n");fflush(stdout);
printf("UMR CNRS 6164\n");fflush(stdout);
printf("Remote Sensing Group - SHINE Team \n");fflush(stdout);
printf("\n");fflush(stdout);
printf("UNIVERSITY OF RENNES I\n");fflush(stdout);
printf("Bat. 11D - Campus de Beaulieu\n");fflush(stdout);
printf("263 Avenue General Leclerc\n");fflush(stdout);
printf("35042 RENNES Cedex\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("*--------------------------------------------------------------------\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("Description :  cross validation of RBF kernel parameters\n");fflush(stdout);
printf("(Cost C and Gamma g)\n");fflush(stdout);
printf("\n");fflush(stdout);
printf("********************************************************************/\n");fflush(stdout);

	for(i=0;i<n_elts;i++) {	
		printf("Data Processing : %.2f %s\r", 100. * (i)/ n_elts,"%");fflush(stdout);
		cost_tmp = pow(2,jobs[i][0]);
		gamma_tmp = pow(2,jobs[i][1]);
		#ifndef _WIN32//We are on linux
			sprintf(command_line, "\"%s\" -c %f -g %f -v %d %s \"%s\" \"%s\" %d",
			svm_train_path,cost_tmp, gamma_tmp, fold, additional_svm_param,
			cluster_file_norm,svm_model_file, Npolar);
		#else //We are NOT on linux (probably Win32)
			sprintf(command_line, "CALL \"%s\" -c %f -g %f -v %d %s \"%s\" \"%s\" %d",
			svm_train_path,cost_tmp, gamma_tmp, fold, additional_svm_param,
			cluster_file_norm,svm_model_file, Npolar);
		#endif

		system(command_line);// We run the CV with (cost_tmp,gamma_tmp)
		//We open the txt file which contain the CV accuracy computed with (cost_tmp,gamma_tmp)
		if ((tmp_accuracy = fopen(tmp_crossval_txt, "rt")) == NULL) {
			fprintf(stderr,"Could not open temporary cross validation accuracy file : %s\n", tmp_crossval_txt);
			exit(1);
		}
		fscanf(tmp_accuracy,"%s",buffer);
		accuracy = atof(buffer);
		if(accuracy > best_acc){
			best_acc = accuracy;
			best_c = jobs[i][0];
			best_g = jobs[i][1];
		}
		fclose(tmp_accuracy);
			
		if ((file_out_CV = fopen(out_put_cv_txt_path, "at")) == NULL) {
			fprintf(stderr,"Could not open svm script file : %s\n", out_put_cv_txt_path);
			exit(1);
		}
		fprintf(file_out_CV, "%d %d %.4f\n",jobs[i][0], jobs[i][1],accuracy);
		fclose(file_out_CV);
		
		//We write the gnuplot script to plot the contour of the computed CV
//		write_gnuplot_script(tmp_script_gp_path, out_put_cv_txt_path, nr_c,
//			c_begin, c_end, nr_g, g_begin, g_end, best_c, best_g, best_acc);
//		fprintf(gp,"load '%s'\n",tmp_script_gp_path); // We plot into the pipe the Graph
//		fflush(gp);
	}

    //	pclose(gp);
	// New gnuplot pipe to build the png file of the CV contour
	sprintf(gp_cmd, "%s\"%s\"", gp_cmd,gnuplot_path);
	gp=popen(gp_cmd, "w");
	if (gp==NULL)
           {
             printf("Error opening pipe to GNU plot. Check if you have it! \n");
             exit(0);
           }
	write_gnuplot_script_png(tmp_script_gp_path, out_put_cv_txt_path,out_put_cv_png_path,
		nr_c, c_begin,  c_end, nr_g, g_begin, g_end, best_c, best_g, best_acc);
	fprintf(gp,"load '%s'\n",tmp_script_gp_path); // We plot into the pipe the Graph
	fflush(gp);
	pclose(gp);

	//remove(tmp_crossval_txt);
	//remove(script_gp_path);
	//free(jobs);
	return 0;
}


/*******************************************************************************
Routine  : range_f
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void range_f(int *range_val, int nr, int begin, int end, int step)
{
	int i;
	int value = begin; 
	
	value = begin;
	//Loop to write the content of range
	for(i= 0 ;i < nr; i++){
		range_val[i] = value;
		value = value + step;
	}
}


/*******************************************************************************
Routine  : permute_sequence
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  permute the different step of the interval to look through
step by step all the space

Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void permute_sequence(int nr, int *seq)
{
	int i,j,k,mid,nr_tmp = nr;
	int seq_perm[nr], seq_tmp[nr];
	for (i=0;i< nr;i++){
		seq_tmp[i] = seq[i];
	}
	i = 0;
	while(nr > 3){
		mid = nr/2;
		seq_perm[i++] = seq_tmp[mid];
		seq_perm[i++] = seq_tmp[mid/2];
		seq_perm[i++] = seq_tmp[mid + mid/2];

		k = 0;
		for(j=0;j<nr;j++) {// we save in seq the array without the save term (seq_perm)
			if((j != mid) && (j != mid/2) && (j != mid + mid/2)){
				seq[k] = seq_tmp[j];
				k++;
			}
		}
		nr = nr - 3;
		for(j=0;j<nr;j++) {
			seq_tmp[j] = seq[j];
		}
	}
	if ((nr==3)){

		seq_perm[i++] = seq_tmp[1];
		seq_perm[i++] = seq_tmp[0];
		seq_perm[i++] = seq_tmp[2];
	}

	if ((nr == 2)){
		seq_perm[i++] = seq_tmp[1];
		seq_perm[i++] = seq_tmp[0];	
	}
	
	if ((nr == 1)){
		seq_perm[i++] = seq_tmp[0];
	}
	
	for(i=0;i<nr_tmp;i++){
		seq[i] = seq_perm[i];
	}
}

/*******************************************************************************
Routine  : calculate_jobs
Authors  :
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  calcul the different step to optimize the course
of the C and Gamma space


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void calculate_jobs(int **jobs ,int nr_c, int c_begin, int c_end, int c_step,
int nr_g, int g_begin, int g_end, int g_step)
{
	int i ,j,k,l;
	int *c_seq;
	int *g_seq;
	
	c_seq = malloc(nr_c*sizeof(int*));
	if (c_seq == NULL){
		fprintf(stderr,"Not enough memory!\n");
		exit(1);
	}
	for(i=0;i<nr_c;i++){
		c_seq[i] = 0;
	}
	
	g_seq = malloc(nr_g*sizeof(int*));
	if (g_seq == NULL){
		fprintf(stderr,"Not enough memory!\n");
		exit(1);
	}
	for(i=0;i<nr_g;i++){
		g_seq[i] = 0;
	}
		
	range_f(c_seq,nr_c,c_begin,c_end,c_step);
	permute_sequence(nr_c,c_seq);
	
	range_f(g_seq,nr_g, g_begin,g_end,g_step);
	permute_sequence(nr_g,g_seq);

	i = 0;
	j = 0;
	l = 0;
	while( (i < nr_c) || (j < nr_g)){
		if((float)i/(float)nr_c < (float)j/(float)nr_g){
			for(k=0;k<j;k++){
				jobs[l][0] = c_seq[i];
				jobs[l][1] = g_seq[k];
				l++;
			}
			i++;
		}else{
			for(k=0;k<i;k++){
				jobs[l][0] = c_seq[k];
				jobs[l][1] = g_seq[j];
				l++;
			}
			j++;
		}		
	}

	free(c_seq);
	free(g_seq);
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
		index = position_dir - path_file;
		strncpy(directory,path_file,index+1);
		directory[index+1] = '\0';
	}else{
		index = position_dir - path_file;
		strncpy(directory,path_file,index+1);
		directory[index+1] = '\0';
	}	
	return directory;
}
/*******************************************************************************
Routine  : write_gnuplot_script
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  write the gnuplot script to plot in the SCREEN the CV results with iso accuracy edge


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void write_gnuplot_script(char *script_gp_path, char *out_put_cv_txt_path,int nr_c, int c_begin, int c_end,
int nr_g, int g_begin, int g_end, int best_c, int best_g, float best_acc)
{

	FILE *file_script_gp_path;
	float begin_level;
	
	begin_level = round(best_acc)-3;
	
	if ((file_script_gp_path = fopen(script_gp_path, "wt")) == NULL) {
		fprintf(stderr,"Could not open script gnuplot file : %s\n", script_gp_path);
		exit(1);
	}
	if(strncmp(script_gp_path,"/",1)==0){//We are on linux
		fprintf(file_script_gp_path,"set term x11  size 600 600\n");
	}else{//We are on Windows
		fprintf(file_script_gp_path,"set term windows size 800, 600\n");
	}
	
	fprintf(file_script_gp_path,"set xlabel \"log2(C)\"\n");
	fprintf(file_script_gp_path,"set ylabel \"log2(gamma)\"\n");
	fprintf(file_script_gp_path, "set xrange [%d:%d]\n",c_begin,c_end);
	fprintf(file_script_gp_path, "set yrange [%d:%d]\n",g_begin,g_end);
	fprintf(file_script_gp_path, "set contour\n");
	fprintf(file_script_gp_path, "set cntrparam levels incremental %.2f,0.5,100\n",begin_level);
	fprintf(file_script_gp_path, "unset surface\n");
	fprintf(file_script_gp_path, "unset ztics\n");
	fprintf(file_script_gp_path, "set view 0,0\n");
	fprintf(file_script_gp_path, "set title \"SVM Cross Validation\"\n");
	fprintf(file_script_gp_path, "unset label\n");
	fprintf(file_script_gp_path, "set label \"Best log2(C) = %d  log2(gamma) = %d  accuracy = %.2f\" at screen 0.5,0.85 center\n",
	best_c, best_g, best_acc);	
	fprintf(file_script_gp_path, "set label \"C = %f  gamma = %f\" at screen 0.5,0.8 center\n",pow(2,best_c),pow(2,best_g));
	fprintf(file_script_gp_path, "set dgrid3d %d,%d,1\n",nr_g,nr_c);
	fprintf(file_script_gp_path, "splot '%s' with lines\n",out_put_cv_txt_path);
	
	fclose(file_script_gp_path);
}

/*******************************************************************************
Routine  : write_gnuplot_script
Authors  : 
Creation : 
Update   : 
-------------------------------------------------------------------------------
Description :  write the gnuplot script to plot in PNG file the CV results with iso accuracy edge


Inputs  : 


Outputs : 

-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/
void write_gnuplot_script_png(char *script_gp_path, char *out_put_cv_txt_path, char *out_put_cv_png_path,int nr_c, int c_begin, int c_end,
int nr_g, int g_begin, int g_end, int best_c, int best_g, float best_acc)
{

	FILE *file_script_gp_path;
	float begin_level;
	
	begin_level = round(best_acc)-3;
	
	if ((file_script_gp_path = fopen(script_gp_path, "wt")) == NULL) {
		fprintf(stderr,"Could not open script gnuplot file : %s\n", script_gp_path);
		exit(1);
	}
	
	fprintf(file_script_gp_path,"set term png  small size 800,600\n");
	fprintf(file_script_gp_path,"set output '%s'\n",out_put_cv_png_path );
	
	fprintf(file_script_gp_path,"set xlabel \"log2(C)\"\n");
	fprintf(file_script_gp_path,"set ylabel \"log2(gamma)\"\n");
	fprintf(file_script_gp_path, "set xrange [%d:%d]\n",c_begin,c_end);
	fprintf(file_script_gp_path, "set yrange [%d:%d]\n",g_begin,g_end);
	fprintf(file_script_gp_path, "set contour\n");
	fprintf(file_script_gp_path, "set cntrparam levels incremental %.2f,0.5,100\n",begin_level);
	fprintf(file_script_gp_path, "unset surface\n");
	fprintf(file_script_gp_path, "unset ztics\n");
	fprintf(file_script_gp_path, "set view 0,0\n");
	fprintf(file_script_gp_path, "set title \"SVM Cross Validation\"\n");
	fprintf(file_script_gp_path, "unset label\n");
	fprintf(file_script_gp_path, "set label \"Best log2(C) = %d  log2(gamma) = %d  accuracy = %.2f\" at screen 0.5,0.85 center\n",
	best_c, best_g, best_acc);	
	fprintf(file_script_gp_path, "set label \"C = %f  gamma = %f\" at screen 0.5,0.8 center\n",pow(2,best_c),pow(2,best_g));
	fprintf(file_script_gp_path, "set dgrid3d %d,%d,1\n",nr_g,nr_c);
	fprintf(file_script_gp_path, "splot '%s' notitle with lines\n",out_put_cv_txt_path);
	
	fclose(file_script_gp_path);
}
