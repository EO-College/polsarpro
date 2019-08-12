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

File  : edge_detector_marr.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

* PROGRAM: marr_hildreth_edge
* PURPOSE: This program implements a "Marr Hildreth" edge detector.
*
* The user must input the parameter:
*
*  sigma = The standard deviation of the gaussian smoothing filter.

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

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
float norm (float x, float y);
float distance (float a, float b, float c, float d);
void marr (float s, int **im, int nr, int nc);
float gauss(float x, float sigma);
float meanGauss (float x, float sigma);
float LoG (float x, float sigma);
float ** f2d (int nr, int nc);
void convolution (int **im, float **mask, int nr, int nc, float **res, int NR, int NC);
void zero_cross (float **lapim, int **im, int nr, int nc);
void dolap (float **x, int nr, int nc, float **y);

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
  FILE *fileinput, *fileoutput;
  char FileInput[FilePathLength], FileOutput[FilePathLength];
  char InputFormat[10], OutputFormat[10];
  
/* Internal variables */
  int ii, lig, col;

  int MinMaxBMP, Npts;

  float Min, Max;
  float xx, xr, xi;

  int rows, cols;
  float sigma;
  int **im1, **im2;

/* Matrix arrays */
  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;
  float *datatmp;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nedge_detector_marr.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-od  	output dir\n");
strcat(UsageHelp," (string)	-idf 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-odf 	output data format (real, imag, mod, mod2, pha)\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-det 	detector coefficient (0 = coarse scale, 1 = fine scale)\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-mmb 	MinMaxBmp flag (0,1,2,3)\n");
strcat(UsageHelp," (float) 	-min 	Min value (valid if MinMaxBMP = 0)\n");
strcat(UsageHelp," (float) 	-max 	Max value (valid if MinMaxBMP = 0)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help  displays this message\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-det",flt_cmd_prm,&sigma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mmb",int_cmd_prm,&MinMaxBMP,1,UsageHelp);
  if (MinMaxBMP == 0) {
    get_commandline_prm(argc,argv,"-min",flt_cmd_prm,&Min,1,UsageHelp);
    get_commandline_prm(argc,argv,"-max",flt_cmd_prm,&Max,1,UsageHelp);
    }

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileOutput);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  sigma = 3.0 - 1.5*sigma;

/* INPUT FILE OPENING*/
  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    rewind(in_valid);
    }

/* OUTPUT FILE OPENING*/
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

  if (strcmp(InputFormat, "cmplx") == 0) bufferdatacmplx = vector_float(2 * Ncol);
  if (strcmp(InputFormat, "float") == 0) bufferdatafloat = vector_float(Ncol);
  if (strcmp(InputFormat, "int") == 0) bufferdataint = vector_int(Ncol);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

rewind(fileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    if (strcmp(InputFormat, "cmplx") == 0)
      fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput);
    if (strcmp(InputFormat, "float") == 0)
      fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput);
    if (strcmp(InputFormat, "int") == 0)
      fread(&bufferdataint[0], sizeof(int), Ncol, fileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */

Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  if (strcmp(InputFormat, "cmplx") == 0)
    fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput);
  if (strcmp(InputFormat, "float") == 0)
    fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput);
  if (strcmp(InputFormat, "int") == 0)
    fread(&bufferdataint[0], sizeof(int), Ncol, fileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {

      Npts++;

      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + Off_col)];
        xi = bufferdatacmplx[2 * (col + Off_col) + 1];
        xx = sqrt(xr * xr + xi * xi);
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[Npts] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[Npts] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[Npts] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx > eps) datatmp[Npts] = 10. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx > eps) datatmp[Npts] = 20. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[Npts] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[Npts] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[Npts] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[Npts] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 10. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 20. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[Npts] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[Npts] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[Npts] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[Npts] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 10. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 20. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[Npts] = 0.;
        }

      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

/*******************************************************************/

/* AUTOMATIC DETERMINATION OF MIN AND MAX */
if ((MinMaxBMP == 1) || (MinMaxBMP == 3)) {
  if (strcmp(OutputFormat, "pha") != 0) { // case of real, imag, mod, db 
    Min = INIT_MINMAX; Max = -Min;
    for (ii = 0; ii < Npts; ii++) {
      if (my_isfinite(datatmp[ii]) != 0) {
        if (datatmp[ii] > Max) Max = datatmp[ii];
        if (datatmp[ii] < Min) Min = datatmp[ii];
        }
      }
    }
  if (strcmp(OutputFormat, "pha") == 0) {
    Max = 180.;
    Min = -180.;
    }
  }


/* ADAPT THE COLOR RANGE TO THE 95% DYNAMIC RANGE OF THE DATA */
  if ((MinMaxBMP == 1) || (MinMaxBMP == 2))
    MinMaxContrastMedian(datatmp, &Min, &Max, Npts);

/********************************************************************
********************************************************************/

/* CREATE THE CHAR IMAGE */
  rows = Sub_Nlig; cols = Sub_Ncol;
  im1 = matrix_int(rows,cols);
  im2 = matrix_int(rows,cols);

rewind(fileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    if (strcmp(InputFormat, "cmplx") == 0)
      fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput);
    if (strcmp(InputFormat, "float") == 0)
      fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput);
    if (strcmp(InputFormat, "int") == 0)
      fread(&bufferdataint[0], sizeof(int), Ncol, fileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  if (strcmp(InputFormat, "cmplx") == 0)
    fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput);
  if (strcmp(InputFormat, "float") == 0)
    fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput);
  if (strcmp(InputFormat, "int") == 0)
    fread(&bufferdataint[0], sizeof(int), Ncol, fileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {

      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + Off_col)];
        xi = bufferdatacmplx[2 * (col + Off_col) + 1];
        xx = sqrt(xr * xr + xi * xi);
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[col] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[col] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[col] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datatmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datatmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[col] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[col] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[col] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[col] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[col] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[col] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[col] = 0.;
        }
      } else {
      datatmp[col] = 0.;     
      } /* valid */    
    } /* col */
  for (col = 0; col < Sub_Ncol; col++) {
    if (xx <= eps) xx = eps;
    xx = (datatmp[col] - Min) / (Max - Min);
    if (xx < 0.) xx = 0.;
    if (xx > 1.) xx = 1.;
    im1[lig][col] = floor(1. + 254. * xx);
    im2[lig][col] = floor(1. + 254. * xx);
    }
  } /* lig */

  free_vector_float(datatmp);
  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_int(bufferdataint);

/********************************************************************
********************************************************************/

/* Perform the edge detection. All of the work takes place here */

  marr(sigma-0.8, im1, rows, cols);
  marr(sigma+0.8, im2, rows, cols);

/********************************************************************
********************************************************************/

  bufferdatafloat = vector_float(Sub_Ncol);
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      if (im1[lig][col] > 0 && im2[lig][col] > 0) bufferdatafloat[col] = 0.;
      else bufferdatafloat[col] = 1.;
      }
    fwrite(&bufferdatafloat[0], sizeof(float), Sub_Ncol,fileoutput);
    }

/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  fclose(fileinput);

/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/********************************************************************
********************************************************************/

  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/

float norm (float x, float y)
{
  return (float) sqrt ( (double)(x*x + y*y) );
}

float distance (float a, float b, float c, float d)
{
  return norm ( (a-c), (b-d) );
}

void marr (float s, int **im, int nr, int nc)
{
  int width;
  float **smx;
  int i,j,n;
  float **lgau;
  
  /* Create a Gaussian and a derivative of Gaussian filter mask */
  width = 3.35*s + 0.33;
  n = width+width + 1;
  lgau = f2d (n, n);
  for (i=0; i<n; i++)
  for (j=0; j<n; j++)
    lgau[i][j] = LoG (distance ((float)i, (float)j, (float)width, (float)width), s);

  /* Convolution of source image with a Gaussian in X and Y directions */
  smx = f2d (nr, nc);
  convolution (im, lgau, n, n, smx, nr, nc);
  
  /* Locate the zero crossings */
  zero_cross (smx, im, nr, nc);
  
  /* Clear the boundary */
  for (i=0; i<nr; i++)
  {
  for (j=0; j<=width; j++) im[i][j] = 0;
  for (j=nc-width-1; j<nc; j++) im[i][j] = 0;
  }
  for (j=0; j<nc; j++)
  {
  for (i=0; i<= width; i++) im[i][j] = 0;
  for (i=nr-width-1; i<nr; i++) im[i][j] = 0;
  }
  
  free(smx[0]); free(smx);
  free(lgau[0]); free(lgau);
}

/* Gaussian*/
float gauss(float x, float sigma)
{
  return (float)exp((double) ((-x*x)/(2*sigma*sigma)));
}
float meanGauss (float x, float sigma)
{
  float z;
  z = (gauss(x,sigma)+gauss(x+0.5,sigma)+gauss(x-0.5,sigma))/3.0;
  z = z/(pi*2.0*sigma*sigma);
  return z;
}

float LoG (float x, float sigma)
{
  float x1;
  x1 = gauss (x, sigma);
  return (x*x-2*sigma*sigma)/(sigma*sigma*sigma*sigma) * x1;
}


float ** f2d (int nr, int nc)
{
  float **x, *y;
  int i;
  x = (float **)calloc ( nr, sizeof (float *) );
  y = (float *) calloc ( nr*nc, sizeof (float) );
  if ( (x==0) || (y==0) )
  {
  printf("Out of storage: F2D.\n");
  exit (1);
  }
  for (i=0; i<nr; i++) x[i] = y+i*nc;
  return x;
}
  
void convolution (int **im, float **mask, int nr, int nc, float **res, int NR, int NC)
{
  int i,j,ii,jj, n, m, k, kk;
  float x;
  k = nr/2; kk = nc/2;
  for (i=0; i<NR; i++)
  for (j=0; j<NC; j++)
  {
    x = 0.0;
    for (ii=0; ii<nr; ii++)
    {
    n = i - k + ii;
    if (n<0 || n>=NR) continue;
    for (jj=0; jj<nc; jj++)
    {
      m = j - kk + jj;
      if (m<0 || m>=NC) continue;
      x += mask[ii][jj] * (float)(im[n][m]);
    }
    }
    res[i][j] = x;
  }
}

void zero_cross (float **lapim, int **im, int nr, int nc)
{
  int i,j;
  
  for (i=1; i<nr-1; i++)
  for (j=1; j<nc-1; j++)
  {
    im[i][j] = 0;
    if(lapim[i-1][j]*lapim[i+1][j]<0) {im[i][j]=255; continue;}
    if(lapim[i][j-1]*lapim[i][j+1]<0) {im[i][j]=255; continue;}
    if(lapim[i+1][j-1]*lapim[i-1][j+1]<0) {im[i][j]=255; continue;}
    if(lapim[i-1][j-1]*lapim[i+1][j+1]<0) {im[i][j]=255; continue;}
  }
}

/* An alternative way to compute a Laplacian*/
void dolap (float **x, int nr, int nc, float **y)
{
  int i,j;
  float u,v;
  
  for (i=1; i<nr-1; i++)
  for (j=1; j<nc-1; j++)
  {
    y[i][j] = (x[i][j+1]+x[i][j-1]+x[i-1][j]+x[i+1][j]) - 4*x[i][j];
    if (u>y[i][j]) u = y[i][j];
    if (v<y[i][j]) v = y[i][j];
  }
}



