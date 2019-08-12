/********************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : sub_aperture_decomposition.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL (v2.0 Eric POTTIER)
Version  : 1.0
Creation : 04/2005 (v2.0 05/2015)
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Waves and Signal department
SHINE Team 


UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Sub-Aperture Decomposition of a SAR image

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS  */
#define NpolarFull 4
#define Nsub_im_max 11

/*#define a_ham 0.54 */
#define a_ham 0.54

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void compensate_spectrum(FILE *in_file,float *correc,float **fft_im,int Nlig,int Ncol,int N,int Naz,int Nrg,int AzimutFlag,int offset_az);
void select_sub_spectrum0(float **fft_im,float **c_im,int offset,float *ham_win,int n_ham,float *vec1,int N,int Nrg);

void correction_function1(int Npolar,float **spectrum,float **correc,int weight,int *lim1,int *lim2,int N,int N_smooth,int offset_az);
void estimate_dopplershift(int Npolar,float **spectrum,int *offset_az,int N,int N_smooth);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
 FILE  *in_file[NpolarFull],*out_file[Nsub_im_max][NpolarFull];

/* Strings */
 char  file_name[FilePathLength];
 char *file_name_in[NpolarFull] = {"s11.bin","s12.bin","s21.bin","s22.bin"};
 char *file_name_out[NpolarFull] = {"s11.bin","s12.bin","s21.bin","s22.bin"};

/* Input variables */
 float Pct_res;
 int Nsub_im;
 int  weight;

/* Internal variables */
 int np,lim1,lim2,n_ham,offset;
 int N,N_smooth,nim;
 int AzimutFlag,az,rg,Naz,Nrg;
 int offset_az;
 float squint;
 int Npolar_in, Npolar_out;

/* Matrix arrays */
 float **fft_im,**c_im;      
 float **spectrum,*vec,*vec1,**correc,*ham_win;      

/* PROGRAM START */
 lim1 = -1;
 lim2 = -1;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsub_aperture_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (float) 	-pct 	percentage of resolution of output data\n");
strcat(UsageHelp," (int)   	-sub 	number of sub-apertures\n");
strcat(UsageHelp," (int)   	-wgh 	indicates if input data have been weighted\n");
strcat(UsageHelp," (int)   	-azf 	azimut flag\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (int)   	-lim1	limit 1 (if wgh = 0)\n");
strcat(UsageHelp," (int)   	-lim2	limit 2 (if wgh = 0)\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pct",flt_cmd_prm,&Pct_res,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sub",int_cmd_prm,&Nsub_im,1,UsageHelp);
  get_commandline_prm(argc,argv,"-wgh",int_cmd_prm,&weight,1,UsageHelp);
  get_commandline_prm(argc,argv,"-azf",int_cmd_prm,&AzimutFlag,1,UsageHelp);
  get_commandline_prm(argc,argv,"-lim1",int_cmd_prm,&lim1,0,UsageHelp);
  get_commandline_prm(argc,argv,"-lim2",int_cmd_prm,&lim2,0,UsageHelp);
  }

/********************************************************************
********************************************************************/

 check_dir(in_dir);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);
 
 if(weight != 0) weight = 1;
 
 Pct_res /= 100;

 check_dir(in_dir);

/* INPUT/OUPUT CONFIGURATIONS */
 read_config(in_dir,&Nlig,&Ncol,PolarCase,PolarType);
 
 /*open input S matrix files */
 if (strcmp(PolarType, "full") == 0) {
   Npolar_in = NpolarFull;
   for (np=0; np<Npolar_in; np++) {
     sprintf(file_name,"%s%s",in_dir,file_name_in[np]);
     if ((in_file[np]=fopen(file_name,"rb"))==NULL)
     edit_error("Could not open input file : ",file_name);
     }
   } else {
   Npolar_in = 2;  
   if (strcmp(PolarType, "pp1") == 0) {
     sprintf(file_name,"%s%s",in_dir,"s11.bin");
     if ((in_file[0]=fopen(file_name,"rb"))==NULL)
       edit_error("Could not open input file : ",file_name);
     sprintf(file_name,"%s%s",in_dir,"s21.bin");
     if ((in_file[1]=fopen(file_name,"rb"))==NULL)
       edit_error("Could not open input file : ",file_name);
     }
   if (strcmp(PolarType, "pp2") == 0) {
     sprintf(file_name,"%s%s",in_dir,"s22.bin");
     if ((in_file[0]=fopen(file_name,"rb"))==NULL)
       edit_error("Could not open input file : ",file_name);
     sprintf(file_name,"%s%s",in_dir,"s12.bin");
     if ((in_file[1]=fopen(file_name,"rb"))==NULL)
       edit_error("Could not open input file : ",file_name);
     }
   if (strcmp(PolarType, "pp3") == 0) {
     sprintf(file_name,"%s%s",in_dir,"s11.bin");
     if ((in_file[0]=fopen(file_name,"rb"))==NULL)
       edit_error("Could not open input file : ",file_name);
     sprintf(file_name,"%s%s",in_dir,"s22.bin");
     if ((in_file[1]=fopen(file_name,"rb"))==NULL)
       edit_error("Could not open input file : ",file_name);
     }
   }
 
 if (AzimutFlag == 1) { Naz = Nlig; Nrg = Ncol; }
 else { Naz = Ncol; Nrg = Nlig; }
 
 for(nim=0;nim<Nsub_im;nim++) {
   if (strcmp(PolarType, "full") == 0) {
     Npolar_out = NpolarFull;  
     for (np=0; np<Npolar_out; np++) {
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,file_name_out[np]);
       if ((out_file[nim][np]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
       }
	 } else {
     Npolar_out = 2;  
     if (strcmp(PolarType, "pp1") == 0) {
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,"s11.bin");
       if ((out_file[nim][0]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,"s21.bin");
       if ((out_file[nim][1]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
	   }
     if (strcmp(PolarType, "pp2") == 0) {
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,"s22.bin");
       if ((out_file[nim][0]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,"s12.bin");
       if ((out_file[nim][1]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
	   }
     if (strcmp(PolarType, "pp3") == 0) {
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,"s11.bin");
       if ((out_file[nim][0]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
       sprintf(file_name,"%s_sub_%d",out_dir,nim);
       check_dir(file_name);
       strcat(file_name,"s22.bin");
       if ((out_file[nim][1]=fopen(file_name,"wb"))==NULL)
         edit_error("Could not open output file : ",file_name);
	   }
	 }
   /* Equally spaced sub-apertures*/
   /* squint : ranging from (-100+Pct_res/2) up to (100-Pct_res/2)*/
   squint = 100.*((2-2*Pct_res)/(Nsub_im-1)*nim+(Pct_res-1));
   sprintf(file_name,"%s_sub_%d",out_dir,nim);
   check_dir(file_name);
   write_config_sub(file_name,Nlig,Ncol,PolarCase,PolarType,nim,Nsub_im,Pct_res*100.,squint);
   }
 
 /* Next higher power of two of the number of lines */
 N = ceil(pow(2.,ceil(log(Naz)/log(2))));
 /* Spectrum amplitude smoothing window size */
 N_smooth = 1 + (int)(0.005*N);
 if (N_smooth < 7) N_smooth = 7;

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */

 c_im   = matrix_float(Nrg,2*N);
 fft_im  = matrix_float(Nrg,2*N);
 vec    = vector_float(2*Nrg);
 vec1   = vector_float(N);
 spectrum = matrix_float(Npolar_in,N);
 correc  = matrix_float(Npolar_in,N);
 ham_win  = vector_float(N);

/********************************************************************
********************************************************************/

if(weight == 0) {
  if (lim2 != -1) lim2 = (N - 1) - lim2; 
  }

/*****************************************/;
/*    READING AND SPECTRUM  ESTIMATION */;
/*****************************************/;
 
 estimate_spectrum(in_file,Npolar_in,spectrum,fft_im,Nlig,Ncol,N,Naz,Nrg,AzimutFlag);

 estimate_dopplershift(Npolar_in,spectrum,&offset_az,N,N_smooth);

/**********************************/;
/* CORRECTION FUNCTION ESTIMATION */;
/**********************************/;

 correction_function(Npolar_in,spectrum,correc,weight,&lim1,&lim2,N,N_smooth,offset_az);

/* Hamming window definition */
/* Set the weighting window to the nearest multiple of two of the
  sub-aperture lenght */
 n_ham = floor((lim2-lim1)*Pct_res);
 n_ham = n_ham-1+(n_ham % 2);

 hamming(a_ham,ham_win,n_ham);

/* SUB APERTURE IMAGES CREATION */

/*******************************/;
/* SUB-APERTURE DECOMPOSITION  */;
/*******************************/;

 for(np=0;np<Npolar_in;np++) {
   compensate_spectrum(in_file[np],correc[np],fft_im,Nlig,Ncol,N,Naz,Nrg,AzimutFlag,offset_az);
   
   /*sub_aperture image at pct resolution with different squint*/
   for(nim=0;nim<Nsub_im;nim++) {
     /* Frequency offset in pixels */
     offset = floor((lim2-n_ham-lim1)/(Nsub_im-1)*nim+lim1);

     select_sub_spectrum(fft_im,c_im,offset,ham_win,n_ham,vec1,N,Nrg);

     if (AzimutFlag == 1) {
       for(az=0;az<Naz;az++) {
         for(rg=0;rg<Nrg;rg++) {
           vec[2*rg]  = c_im[rg][2*az];
           vec[2*rg+1] = c_im[rg][2*az+1];
           }
         fwrite(&vec[0],sizeof(float),2*Nrg,out_file[nim][np]);
         }
       } else {
       for (rg=0;rg<Nrg;rg++)
         fwrite(&c_im[rg][0],sizeof(float),2*Naz,out_file[nim][np]);
       }

     }/* nim */
   }/* np */

/********************************************************************
********************************************************************/

 free_matrix_float(c_im,Nrg);
 free_matrix_float(fft_im,Nrg);
 free_vector_float(vec);
 free_vector_float(vec1);
 free_matrix_float(spectrum,Npolar_in);
 free_matrix_float(correc,Npolar_in);
 free_vector_float(ham_win);

 return 1;
} 

