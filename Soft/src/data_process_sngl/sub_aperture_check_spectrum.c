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

File   : sub_aperture_check_spectrum.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Laurent FERRO-FAMIL (v2.0 Eric POTTIER, v3.0 Jacek STRZELCZYK)
Version  : 3.0
Creation : 04/2005 (v2.0 08/2011, v3.0 08/2015)
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

Description :  Check the Doppler Spectrum of a SAR image

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
#define Nsub_im_max 11

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

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
 FILE *ftmp;

/* Strings */
 char RawSpectrumTxt[FilePathLength], RawSpectrumBin[FilePathLength];
 char AvgSpectrumTxt[FilePathLength], AvgSpectrumBin[FilePathLength];
 
/* Internal variables */
 int lig,col,ii,jj,lim1,lim2;
 int N,N_smooth;
 int AzimutFlag,az,rg,Naz,Nrg;
 float mean,min,max;
 int Nmin, Nmax;

/* Matrix arrays */
 float **fft_im;
 float **spectrum,*vec,*M_in,*vec1,**correc; 

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsub_aperture_check_spectrum.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-azf 	azimut flag\n");
strcat(UsageHelp," (string)	-of1 	output file: raw_spectrum.txt\n");
strcat(UsageHelp," (string)	-of2 	output file: raw_spectrum.bin\n");
strcat(UsageHelp," (string)	-of3 	output file: avg_spectrum.txt\n");
strcat(UsageHelp," (string)	-of4 	output file: avg_spectrum.bin\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-azf",int_cmd_prm,&AzimutFlag,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of1",str_cmd_prm,RawSpectrumTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of2",str_cmd_prm,RawSpectrumBin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of3",str_cmd_prm,AvgSpectrumTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of4",str_cmd_prm,AvgSpectrumBin,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

 check_dir(in_dir);
 check_file(RawSpectrumTxt);
 check_file(RawSpectrumBin);
 check_file(AvgSpectrumTxt);
 check_file(AvgSpectrumBin);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

  if (AzimutFlag == 1) { Naz = Nlig; Nrg = Ncol; }
  else { Naz = Ncol; Nrg = Nlig; }
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

 /* Next higher power of two of the number of lines */
 N = ceil(pow(2.,ceil(log(Naz)/log(2))));
 /* Spectrum amplitude smoothing window size */
 N_smooth = 1 + ceil(0.005*N);
 if (N_smooth < 7) N_smooth = 7;

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */

 fft_im  = matrix_float(Nrg,2*N);
 M_in   = vector_float(2*Ncol);
 spectrum = matrix_float(NpolarIn,N);
 correc  = matrix_float(NpolarIn,N);

/********************************************************************
********************************************************************/

/*****************************************/
/*  READING AND SPECTRUM  ESTIMATION  */
/*****************************************/

/* READING */
  for (Np = 0; Np < NpolarIn; Np++) {
    for (az=0; az<2*N; az++) {
      spectrum[Np][az/2] = 0;
      for (rg=0; rg<Nrg; rg++) fft_im[rg][az] = 0;
      }  

    for (lig=0; lig<Nlig; lig++) {
      PrintfLine(lig,Nlig);
      fread(&M_in[0],sizeof(float),2*Ncol,in_datafile[Np]);

      if (AzimutFlag == 1) {
        /* Transpose the input image to perform the FFT over the lines */  
        for (col=0; col<Ncol; col++) {
          fft_im[col][2*lig]  = M_in[2*col];
          fft_im[col][2*lig+1] = M_in[2*col+1];
          }
        } else {
        for (col=0; col<Ncol; col++) {
          fft_im[lig][2*col]  = M_in[2*col];
          fft_im[lig][2*col+1] = M_in[2*col+1];
          }
        }
      } /*end lig */

    /* FORWARD FFT AND SPECTRUM AVERAGING IN RANGE*/
#pragma omp parallel for private(az)
    for(rg=0; rg<Nrg; rg++) {
      if (omp_get_thread_num() == 0) PrintfLine(rg,Nrg);
      Fft(fft_im[rg],N,+1);
      /* Now sum up in the range direction the amplitudes of the different azimuth spectra*/
      for(az=0; az<N; az++)
        spectrum[Np][az] += sqrt(fft_im[rg][2*az]*fft_im[rg][2*az]+fft_im[rg][2*az+1]*fft_im[rg][2*az+1])/Nrg;
      } 
    } /* end Np */

/********************************************************************
********************************************************************/

  min = INIT_MINMAX; max = -min;
  for (Np = 0; Np < NpolarIn; Np++) {
    for(az=0; az<N; az++) {
      PrintfLine(az,N);
      if(spectrum[Np][az]>eps) {
        if(spectrum[Np][az]>max) max = spectrum[Np][az];
        if(spectrum[Np][az]<min) min = spectrum[Np][az];
        }
      }
    }
   min = 20*log10(min+eps);
   Nmin = (int)floor(min - 0.5);
   max = 20*log10(max+eps);
   Nmax = (int)floor(max + 0.5);

   if ((ftmp = fopen(RawSpectrumTxt, "w")) == NULL)
     edit_error("Could not open input file : ", RawSpectrumTxt);
   fprintf(ftmp, "%i\n", N);
   fprintf(ftmp, "%i\n", Nmin);fprintf(ftmp, "%i\n", Nmax);
   fclose(ftmp);
   if ((ftmp = fopen(RawSpectrumBin, "w")) == NULL)
     edit_error("Could not open input file : ", RawSpectrumBin);
   for (az=0; az<N; az++) {
     if(NpolarIn == 2) fprintf(ftmp, "%i %f %f\n",az,20*log10(spectrum[0][az]+eps),20*log10(spectrum[1][az]+eps));
     if(NpolarIn == 4) fprintf(ftmp, "%i %f %f %f %f\n",az,20*log10(spectrum[0][az]+eps),20*log10(spectrum[1][az]+eps),20*log10(spectrum[2][az]+eps),20*log10(spectrum[3][az]+eps));
     }
   fclose(ftmp);

/********************************************************************
********************************************************************/

/************************************************/
/* AMPLITUDE AND CORRECTION FUNCTION ESTIMATION */
/************************************************/
  lim1 = 0;
  lim2 = 0;
#pragma omp parallel for private(az, lim1, lim2, max, mean, ii, vec, vec1)
  for (Np = 0; Np < NpolarIn; Np++) {
    vec = vector_float(2*N);
    vec1 = vector_float(2*N);
    /*fft circular shift in order to avoid dicontnuities at zero frequency */
    for(az=0; az<N; az++) {
      PrintfLine(az,N);
      vec1[az] = spectrum[Np][az];
      vec1[az+N] = spectrum[Np][az];
      } 

    /* smoothing from lim1 to lim2 to obtain a better estimate of the spectrum amplitude*/
    lim1 = (N_smooth-1)/2;
    lim2 = 2*N-(N_smooth-1)/2;

    max = 0; mean = 0;
    az=lim1;

    for(ii=-(N_smooth-1)/2;ii<(N_smooth-1)/2+1;ii++) mean += vec1[az+ii]/N_smooth;
  
    correc[Np][az] = mean;
    if(mean > max)  max = mean; 
    for(az=lim1+1;az<lim2;az++) {
      ii = -1-(N_smooth-1)/2; jj = (N_smooth-1)/2;
      mean  += (vec1[az+jj]-vec1[az+ii])/N_smooth;
      vec[az] = mean;
      if(mean > max) max = mean;
      }
    for(az=0; az<N; az++) correc[Np][az] = vec[az+N/2];
    free_vector_float(vec);
    free_vector_float(vec1);
    }

/********************************************************************
********************************************************************/

  min = INIT_MINMAX; max = -min;
  for (Np = 0; Np < NpolarIn; Np++) {
    for(az=0; az<N; az++) {
      PrintfLine(az,N);
      if(correc[Np][az]>eps) {
        if(correc[Np][az]>max) max = correc[Np][az];
        if(correc[Np][az]<min) min = correc[Np][az];
        }
      }
    }
  min = 20*log10(min+eps);
  Nmin = (int)floor(min - 0.5);
  max = 20*log10(max+eps);
  Nmax = (int)floor(max + 0.5);

  if ((ftmp = fopen(AvgSpectrumTxt, "w")) == NULL)
    edit_error("Could not open input file : ", AvgSpectrumTxt);
  fprintf(ftmp, "%i\n", N);
  fprintf(ftmp, "%i\n", Nmin);fprintf(ftmp, "%i\n", Nmax);
  fclose(ftmp);
  if ((ftmp = fopen(AvgSpectrumBin, "w")) == NULL)
    edit_error("Could not open input file : ", AvgSpectrumBin);
  for (az=0; az<N; az++) {
    if(NpolarIn == 2) fprintf(ftmp, "%i %f %f\n",az,20*log10(correc[0][az]+eps),20*log10(correc[1][az]+eps));
    if(NpolarIn == 4) fprintf(ftmp, "%i %f %f %f %f\n",az,20*log10(correc[0][az]+eps),20*log10(correc[1][az]+eps), 20*log10(correc[2][az]+eps),20*log10(correc[3][az]+eps));
    }
  fclose(ftmp);

/********************************************************************
********************************************************************/

 free_matrix_float(fft_im,Ncol);
 free_vector_float(M_in);
 free_matrix_float(spectrum,NpolarIn);
 free_matrix_float(correc,NpolarIn);

 return 1;
}


