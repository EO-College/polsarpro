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

File   : statistics_histogram.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2006
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

Description :  Create the histograms of a binary float 1D-file

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

/* ALIASES  */

/*Area parameters */
#define Lig_init 0
#define Col_init 1
#define Lig_nb  2
#define Col_nb  3

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* GLOBAL ARRAYS */
float *tmpcmplx;
float *tmpfloat;
int *tmpint;

float *tmp_elem;
float *Xhist, *Yhist;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
  /*******************/  
  /* LOCAL VARIABLES */
  /*******************/
  
  /* Input/Output file pointer arrays*/
  FILE *in_file;
  FILE *out_file;
  
  char file_data[FilePathLength],file_hist[FilePathLength], file_stat[FilePathLength];
  char inputformat[10],outputformat[10];
  
  /* Internal variables */
  int np, npts, nbins, minmaxauto;
  float xr, xi, xx;
  float min, max, maxmin, tmp;
  float maxhisto;

  /******************/
  /* PROGRAM STARTS */
  /******************/
  
  if (argc < 10) {
    edit_error("statistics_histogram file_data file_hist file_stat input_format output_format nbins minmaxauto (0/1) min max\n","");
    } else {
    strcpy(file_data, argv[1]);
    strcpy(file_hist, argv[2]);
    strcpy(file_stat, argv[3]);
    strcpy(inputformat, argv[4]);
    strcpy(outputformat, argv[5]);
    nbins = atoi(argv[6]);
    minmaxauto = atoi(argv[7]);
    min = atof(argv[8]);
    max = atof(argv[9]);
    }
  check_file(file_data);
  check_file(file_hist);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  /* Input file opening & reading */
  if ((in_file = fopen(file_data, "rb")) == NULL)
    edit_error("Could not open input file : ", file_data);
  fread(&npts, sizeof(int), 1 , in_file);

  /* Matrix Declarations */
  tmp_elem  = vector_float(npts);
  Xhist    = vector_float(nbins);
  Yhist    = vector_float(nbins);
  if (strcmp(inputformat, "cmplx") == 0) tmpcmplx = vector_float(2 * npts);
  if (strcmp(inputformat, "float") == 0) tmpfloat = vector_float(npts);
  if (strcmp(inputformat, "int") == 0) tmpint = vector_int(npts);

  if (strcmp(inputformat, "cmplx") == 0) fread(&tmpcmplx[0], sizeof(float), 2*npts , in_file);
  if (strcmp(inputformat, "float") == 0) fread(&tmpfloat[0], sizeof(float), npts , in_file);
  if (strcmp(inputformat, "int") == 0) fread(&tmpint[0], sizeof(int), npts , in_file);
  fclose(in_file);

  for (np = 0; np < npts; np++) {
    if (strcmp(outputformat, "real") == 0) {
      if (strcmp(inputformat, "cmplx") == 0) tmp_elem[np] = tmpcmplx[2 * np];
      if (strcmp(inputformat, "float") == 0) tmp_elem[np] = tmpfloat[np];
      if (strcmp(inputformat, "int") == 0)  tmp_elem[np] = (float) tmpint[np];
      }

    if (strcmp(outputformat, "imag") == 0) {
      if (strcmp(inputformat, "cmplx") == 0) tmp_elem[np] = tmpcmplx[2 * np + 1];
      if (strcmp(inputformat, "float") == 0) tmp_elem[np] = 0.;
      if (strcmp(inputformat, "int") == 0)  tmp_elem[np] = 0.;
      }

    if (strcmp(outputformat, "mod") == 0) {
      if (strcmp(inputformat, "cmplx") == 0) {
        xr = tmpcmplx[2 * np]; xi = tmpcmplx[2 * np + 1];
        tmp_elem[np] = sqrt(xr * xr + xi * xi);
        }
      if (strcmp(inputformat, "float") == 0)
        tmp_elem[np] =  fabs(tmpfloat[np]);
      if (strcmp(inputformat, "int") == 0)
        tmp_elem[np] =  fabs((float) tmpint[np]);
      }

    if (strcmp(outputformat, "db10") == 0) {
      if (strcmp(inputformat, "cmplx") == 0) {
        xr = tmpcmplx[2 * np]; xi = tmpcmplx[2 * np + 1];
        xx = sqrt(xr * xr + xi * xi);
        }
      if (strcmp(inputformat, "float") == 0)
        xx = fabs(tmpfloat[np]);
      if (strcmp(inputformat, "int") == 0)
        xx = fabs((float) tmpint[np]);
      if (xx < eps) xx = eps;
        tmp_elem[np] = 10. * log10(xx);
      }

    if (strcmp(outputformat, "db20") == 0) {
      if (strcmp(inputformat, "cmplx") == 0) {
        xr = tmpcmplx[2 * np]; xi = tmpcmplx[2 * np + 1];
        xx = sqrt(xr * xr + xi * xi);
        }
      if (strcmp(inputformat, "float") == 0)
        xx = fabs(tmpfloat[np]);
      if (strcmp(inputformat, "int") == 0)
        xx = fabs((float) tmpint[np]);
      if (xx < eps) xx = eps;
        tmp_elem[np] = 20. * log10(xx);
      }

    if (strcmp(outputformat, "pha") == 0) {
      if (strcmp(inputformat, "cmplx") == 0) {
        xr = tmpcmplx[2 * np]; xi = tmpcmplx[2 * np + 1];
        tmp_elem[np] = atan2(xi, xr + eps) * 180. / pi;
        }
      if (strcmp(inputformat, "float") == 0) tmp_elem[np] = 0.;
      if (strcmp(inputformat, "int") == 0) tmp_elem[np] = 0.;
      }
    }

  /*********************/
  /* STATS CALCULATION */
  /*********************/

  if (minmaxauto == 1) {
    tmp = SecondOrderCenteredVectorReal(tmp_elem,npts);
    maxmin = sqrt(tmp);
    min = -2.0 * maxmin + MeanVectorReal(tmp_elem,npts);
    max =  2.0 * maxmin + MeanVectorReal(tmp_elem,npts);
    }
      
  HistogramVectorReal(tmp_elem,npts,min,max,nbins,Xhist,Yhist);

  maxhisto = -10000.00;
  for(np = 0; np < nbins; np++) 
    if (maxhisto <= Yhist[np]) maxhisto = Yhist[np];
  for(np = 0; np < nbins; np++) Yhist[np] = Yhist[np] / maxhisto;
  
  /* Output histogram file opening */
  if ((out_file = fopen(file_hist, "wb")) == NULL)
    edit_error("Could not open input file : ", file_hist);

  /* Histograms files */
  for(np = 0; np < nbins; np++) {
    fprintf(out_file,"%f ",Xhist[np]);
    fprintf(out_file,"%f ",Yhist[np]);
    fprintf(out_file,"\n");
    }
  fclose(out_file);

  /* Output histogram file opening */
  if ((out_file = fopen(file_stat, "w")) == NULL)
    edit_error("Could not open input file : ", file_hist);

  /* Maximum Histogram */
  fprintf(out_file,"%i ",(int) floor(maxhisto));
  fclose(out_file);
  
  /* Matrix closing */
  free_vector_float(tmp_elem);
  free_vector_float(Xhist);
  free_vector_float(Yhist);
  
   return 1;
}


