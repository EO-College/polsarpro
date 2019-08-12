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

File  : edge_detector_black.c
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

Anisotropic Diffusion edge detector code:
-----------------------------------------

This file contains the source code for the Robust Anisotropic Diffusion
edge detector described in "Robust Anisotropic Diffusion", by M. Black, 
G. Sapiro, D. Marimont and D. Heeger, IEEE Trans. Image Processing, vol.7,
no. 3, pp. 421-432, Mar 1998. It was written by Christine Kranenburg
(kranenbu@bigpine.csee.usf.edu).

The implementation was verified by comparison of the MAD when run on the
Canal image. The detector was then supplemented with non-maximal
suppression to produce single pixel wide edges.

One other modification occurs in the function "spatial_disconts".
We threshold the intesity difference between the center pixel and its 4
neighbors. The original implementation only thresholded the top and left
neighbors. Using 4 neighbors instead of 2 produces thicker but more
continuous edges. The non-max then performs edge thinning.

Known issues:

Anything that causes sigma = 0 may produce unpredictable results because
of the division by sigma squared term in the tukey function. For this
reason, 0 is an invalid parameter to supply to the detector. The same
effect may appear on images in which a substantial part of the image is
the same color, causing the MAD function to return 0.

DISCLAIMER:
-----------
We are not responsible for any damages, material or otherwise,
created by the use/handling of this software. 

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

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void black(float *smooth, int rows, int cols, float sigma, float lambda);
float psi(float x, float sigma);
int find_median(int *grad, int N);
int MAD(float *smooth, int rows, int cols);
void spatial_disconts(unsigned char *image, unsigned char *nms, short int **edge, int rows, int cols, float sigma);
void non_max_supp(short int *mag, short int *gradx, short int *grady, int nrows, int ncols, unsigned char *result);
void magnitude_x_y(short int *delta_x, short int *delta_y, int rows, int cols, short int **magnitude);
void derrivative_x_y(short int *smoothedim, int rows, int cols, short int **delta_x, short int **delta_y);

/* GLOBAL VARIABLES */
#define NONMAX 1
#define NOEDGE 255
#define POSSIBLE_EDGE 128
#define EDGE 0

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

  unsigned char *image, *nms;
  short int *edge;
  int rows, cols;
  float sigma_e, sigma, slide = 1.0;
  float lambda;
  int i, k;
  short int *im_int, *dx, *dy, *mag;

/* Matrix arrays */
  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;
  float *datatmp;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nedge_detector_black.exe\n");
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
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
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
  get_commandline_prm(argc,argv,"-det",flt_cmd_prm,&slide,1,UsageHelp);
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

  slide = 1. - slide;

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
          datatmp[lig*Sub_Ncol+col] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[lig*Sub_Ncol+col] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[lig*Sub_Ncol+col] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datatmp[lig*Sub_Ncol+col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datatmp[lig*Sub_Ncol+col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[lig*Sub_Ncol+col] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[lig*Sub_Ncol+col] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[lig*Sub_Ncol+col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[lig*Sub_Ncol+col] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[lig*Sub_Ncol+col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[lig*Sub_Ncol+col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[lig*Sub_Ncol+col] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[lig*Sub_Ncol+col] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[lig*Sub_Ncol+col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[lig*Sub_Ncol+col] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[lig*Sub_Ncol+col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[lig*Sub_Ncol+col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[lig*Sub_Ncol+col] = 0.;
        }
      } else {
      datatmp[lig*Sub_Ncol+col] = 0.;     
      } /* valid */    
    } /* col */
  } /* lig */

  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      if (xx <= eps) xx = eps;
      xx = (datatmp[lig*Sub_Ncol+col] - Min) / (Max - Min);
      if (xx < 0.) xx = 0.;
      if (xx > 1.) xx = 1.;
      datatmp[lig*Sub_Ncol+col] = 1. + 254. * xx;
      }
    }

  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_int(bufferdataint);

/********************************************************************
********************************************************************/

/* Perform the edge detection. All of the work takes place here */

  sigma_e = 1.4826 * (float)(MAD(datatmp, rows, cols));
  sigma_e = slide * sigma_e;
  sigma = sigma_e * sqrt(5.0);
  lambda = 1.0 / psi(sigma_e, sigma);

// Smooth iteratively 100 times
  
  for (k = 0; k < 100; k++) black(datatmp, rows, cols, sigma, lambda);

  //image = vector_char(rows*cols);
  if((image=(unsigned char *)calloc(rows*cols,sizeof(unsigned char))) == NULL){
    printf("Error allocating the image.\n");
    exit(1);
    }
  im_int = vector_short_int(rows*cols);
  //nms = vector_char(rows*cols);
  if((nms=(unsigned char *)calloc(rows*cols,sizeof(unsigned char))) == NULL){
    printf("Error allocating the nms.\n");
    exit(1);
    }
  
  for (i = 0; i < rows*cols; i++) {
  image[i] = (unsigned char) datatmp[i];
  im_int[i] = (short int) datatmp[i];
  }
  free_vector_float(datatmp);
  
  derrivative_x_y(im_int, rows, cols, &dx, &dy);
  magnitude_x_y(dx, dy, rows, cols, &mag);
  non_max_supp(mag, dx, dy, rows, cols, nms);

  if (!NONMAX)  memset(nms, 128, rows*cols);

  spatial_disconts(image, nms, &edge, rows, cols, sigma_e);

  for (i = 0; i < rows*cols; i++) image[i] = (unsigned char) edge[i];


/********************************************************************
********************************************************************/

  bufferdatafloat = vector_float(Sub_Ncol);
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      bufferdatafloat[col] =  (float)((int) image[lig*Sub_Ncol+col]) /255.;
      }
    fwrite(&bufferdatafloat[0], sizeof(float), Sub_Ncol,fileoutput);
  }

  free_vector_short_int(edge);
  free_vector_short_int(dx);
  free_vector_short_int(dy);
  free_vector_short_int(mag);
  free_vector_short_int(im_int);
  free(image);
  free(nms);
  free_vector_float(bufferdatafloat);

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

void black(float *smooth, int rows, int cols, float sigma, float lambda)
{
int i, j, index;
float north, south, east, west, delta_i;

// Divide pixels into checkerboard and update white and black pixels separately.

// Iterate over white sites (odd pixels)
  for(i = 1; i < rows-1; i++)
  for(j = 1; j < cols-1; j=j+2)
  {
  index = i * cols + j;
  north = smooth[index - cols] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  east = smooth[index + 1] - smooth[index];
  west = smooth[index - 1] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(south, sigma) + psi(east, sigma) + psi(west, sigma));
  smooth[index] = smooth[index] + delta_i;
  }


// Iterate over black sites (even pixels)
  for(i = 1; i < rows-1; i++)
  for(j = 2; j < cols-1; j=j+2)
  {
  index = i * cols + j;
  north = smooth[index - cols] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  east = smooth[index + 1] - smooth[index];
  west = smooth[index - 1] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(south, sigma) + psi(east, sigma) + psi(west, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

// Update edge pixels (3 neighbors)
// Top edge pixels
  i = 0;  
  for(j = 1; j < cols-1; j=j+2)
  {
  west = smooth[j - 1] - smooth[j];
  east = smooth[j + 1] - smooth[j];
  south = smooth[j + cols] - smooth[j];
  delta_i = 0.25 * lambda * (psi(south, sigma) + psi(east, sigma) + psi(west, sigma));
  smooth[j] = smooth[j] + delta_i;
  }

  for(j = 2; j < cols-1; j=j+2)
  {
  west = smooth[j - 1] - smooth[j];
  east = smooth[j + 1] - smooth[j];
  south = smooth[j + cols] - smooth[j];
  delta_i = 0.25 * lambda * (psi(south, sigma) + psi(east, sigma) + psi(west, sigma));
  smooth[j] = smooth[j] + delta_i;
  }

// Bottom edge pixels
  i = rows - 1;
  for(j = 1; j < cols-1; j=j+2)
  {
  index = i * cols + j;
  west = smooth[index - 1] - smooth[index];
  east = smooth[index + 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(east, sigma) + psi(west, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

  for(j = 2; j < cols-1; j=j+2)
  {
  index = i * cols + j;
  west = smooth[index - 1] - smooth[index];
  east = smooth[index + 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(east, sigma) + psi(west, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

// Left edge pixels
  j = 0;
  for(i = 1; i < rows-1; i=i+2)
  {
  index = i * cols + j;
  east = smooth[index + 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(south, sigma) + psi(east, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

  for(i = 2; i < rows-1; i=i+2)
  {
  index = i * cols + j;
  east = smooth[index + 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(south, sigma) + psi(east, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

// Right edge pixels
  j = cols - 1;
  for(i = 1; i < rows-1; i=i+2)
  {
  index = i * cols + j;
  west = smooth[index - 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(south, sigma) + psi(west, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

  for(i = 2; i < rows-1; i=i+2)
  {
  index = i * cols + j;
  west = smooth[index + 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(north, sigma) + psi(south, sigma) + psi(west, sigma));
  smooth[index] = smooth[index] + delta_i;
  }

// Update corner pixels
  i = 0;
  j = 0;
  index = i * cols + j;
  east = smooth[index + 1] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(east, sigma) + psi(south, sigma));
  smooth[index] = smooth[index] + delta_i;

  j = cols - 1;
  index = i * cols + j;
  west = smooth[index - 1] - smooth[index];
  south = smooth[index + cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(west, sigma) + psi(south, sigma));
  smooth[index] = smooth[index] + delta_i;

  i = rows - 1;
  j = 0;
  index = i * cols + j;
  east = smooth[index + 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(east, sigma) + psi(north, sigma));
  smooth[index] = smooth[index] + delta_i;

  j = cols - 1;
  index = i * cols + j;
  west = smooth[index - 1] - smooth[index];
  north = smooth[index - cols] - smooth[index];
  delta_i = 0.25 * lambda * (psi(west, sigma) + psi(north, sigma));
  smooth[index] = smooth[index] + delta_i;
}


float psi(float x, float sigma)
{
float tukey, temp;

if (fabs(x) <= sigma)
{
  temp = x / sigma;
  tukey = x * (1.0 - temp * temp) * (1.0 - temp * temp);
}
else
  tukey = 0.0;

return tukey;
}

void spatial_disconts(unsigned char *image, unsigned char *nms,  short int **edge, int rows, int cols, float sigma)
{
int i, j, index;

  if((*edge=(short int*)calloc((rows*cols),sizeof(short int)))==NULL)
  {
    printf("Error allocating the edge image.\n");
    exit(1);
  }

for (i = 0; i < rows*cols; i++) (*edge)[i] = 255;

for (i = 1; i < rows-1; i++)
  for (j = 1; j < cols-1; j++)
  {
  index = i * cols + j;
  if(nms[index] == 128 && 
  ((fabs(image[index] - image[index-cols]) >= sigma) ||
  (fabs(image[index] - image[index-1]) >= sigma) ||
  (fabs(image[index] - image[index+cols]) >= sigma) ||
  (fabs(image[index] - image[index+1]) >= sigma)))
  (*edge)[index] = 0;
  }
}

// Median absolute deviation function - used to calculate sigma_e
int MAD(float *smooth, int rows, int cols)
{
int *north, *south, *east, *west, *gm;
int median;
int i, j, index;

north=(int*)calloc((rows*cols),sizeof(int));
south=(int*)calloc((rows*cols),sizeof(int));
east=(int*)calloc((rows*cols),sizeof(int));
west=(int*)calloc((rows*cols),sizeof(int));
gm=(int*)calloc((rows*cols*4),sizeof(int));  // Gradient magnitude

if(north == NULL || south == NULL || east == NULL || west == NULL || gm == NULL)
  {
  printf("Error allocating the differences matrix.\n");
  exit(1);
  }

// Calculate the neighbor differences and store in 4 matricies
for (i = 1; i < rows; i++)
  for (j = 0; j < cols; j++)
   {
    index = i * cols + j;
    north[index] = (int)(smooth[index - cols] - smooth[index]);
   }
for (i = 0; i < rows-1; i++)
  for (j = 0; j < cols; j++)
   {
    index = i * cols + j;
    south[index] = (int)(smooth[index + cols] - smooth[index]);
   }
for (i = 0; i < rows; i++)
  for (j = 0; j < cols-1; j++)
   {
    index = i * cols + j;
    east[index] = (int)(smooth[index + 1] - smooth[index]);
   }
for (i = 0; i < rows; i++)
  for (j = 1; j < cols; j++)
   {
    index = i * cols + j;
    west[index] = (int)(smooth[index - 1] - smooth[index]);
   }

// Calcuate magnitude of the gradient
for (i = 0; i < rows*cols; i++)
  {
  gm[i * 4] = abs(north[i]);
  gm[i * 4 + 1] = abs(south[i]);
  gm[i * 4 + 2] = abs(east[i]);
  gm[i * 4 + 3] = abs(west[i]);
  }

// Find the median gradient across the entire image
median = find_median(gm, rows*cols*4);

// Normalize the neighbor differences w.r.t. the median
for(i = 1; i < rows-1; i++)
  for(j = 1; j < cols-1; j++)  
  {index = i * cols + j;
  north[index] -= median;
  south[index] -= median;
  east[index]  -= median;
  west[index]  -= median;
  }

// Recompute the gradient w/ the normalized differences
for (i = 0; i < rows*cols; i++)
  {
  gm[i * 4] = abs(north[i]);
  gm[i * 4 + 1] = abs(south[i]);
  gm[i * 4 + 2] = abs(east[i]);
  gm[i * 4 + 3] = abs(west[i]);
  }

median = find_median(gm, rows*cols*4);

free(north);
free(south);
free(east);
free(west);
free(gm);

return median;
}


// Modified quicksort to find median (see Sedgewick, pp 128)
int find_median(int *grad, int N)
{
int left, right, i, j, k;
int v, temp, median;
int *list;

if((list = (int*)calloc(N+1, sizeof(float)))==NULL)
{
  printf("Error allocating the smooth image.\n");
  exit(1);
}

// Copy the gradient matrix to temp storage for partial sort
for (i = 1; i <= N; i++) list[i] = grad[i-1];
  
left = 1;
right = N;
k = N/2;

while(right > left)
  {v = list[right];
  i = left - 1;
  j = right;
  for(;;)
  {
   while (list[++i] < v);
   while (list[--j] > v);
   if (i >= j) break;
   temp = list[i];
   list[i] = list[j];
   list[j] = temp;
  }

  temp = list[i];
  list[i] = list[right];
  list[right] = temp;
  if (i >= k) right = i - 1;
  if (i <= k) left = i + 1;
  }
median = list[k];
free(list);
return median;
}

/*******************************************************************************
* PROCEDURE: non_max_supp
* PURPOSE: This routine applies non-maximal suppression to the magnitude of
* the gradient image.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void non_max_supp(short int *mag, short int *gradx, short int *grady, int nrows, int ncols, unsigned char *result)
{
  int rowcount, colcount,count;
  short *magrowptr,*magptr;
  short *gxrowptr,*gxptr;
  short *gyrowptr,*gyptr,z1,z2;
  short m00,gx,gy;
  float mag1,mag2,xperp,yperp;
  unsigned char *resultrowptr, *resultptr;
  

  /****************************************************************************
  * Zero the edges of the result image.
  ****************************************************************************/
  for(count=0,resultrowptr=result,resultptr=result+ncols*(nrows-1); 
  count<ncols; resultptr++,resultrowptr++,count++){
  *resultrowptr = *resultptr = (unsigned char) 0;
  }

  for(count=0,resultptr=result,resultrowptr=result+ncols-1;
  count<nrows; count++,resultptr+=ncols,resultrowptr+=ncols){
  *resultptr = *resultrowptr = (unsigned char) 0;
  }

  /****************************************************************************
  * Suppress non-maximum points.
  ****************************************************************************/
  for(rowcount=1,magrowptr=mag+ncols+1,gxrowptr=gradx+ncols+1,
  gyrowptr=grady+ncols+1,resultrowptr=result+ncols+1;
  rowcount<nrows-2; 
  rowcount++,magrowptr+=ncols,gyrowptr+=ncols,gxrowptr+=ncols,
  resultrowptr+=ncols){  
  for(colcount=1,magptr=magrowptr,gxptr=gxrowptr,gyptr=gyrowptr,
   resultptr=resultrowptr;colcount<ncols-2; 
   colcount++,magptr++,gxptr++,gyptr++,resultptr++){  
   m00 = *magptr;
   if(m00 == 0){
    *resultptr = (unsigned char) NOEDGE;
   }
   else{
    xperp = -(gx = *gxptr)/((float)m00);
    yperp = (gy = *gyptr)/((float)m00);
   }

   if(gx >= 0){
    if(gy >= 0){
    if (gx >= gy)
      {  
      /* 111 */
      /* Left point */
      z1 = *(magptr - 1);
      z2 = *(magptr - ncols - 1);

      mag1 = (m00 - z1)*xperp + (z2 - z1)*yperp;
      
      /* Right point */
      z1 = *(magptr + 1);
      z2 = *(magptr + ncols + 1);

      mag2 = (m00 - z1)*xperp + (z2 - z1)*yperp;
      }
      else
      {  
      /* 110 */
      /* Left point */
      z1 = *(magptr - ncols);
      z2 = *(magptr - ncols - 1);

      mag1 = (z1 - z2)*xperp + (z1 - m00)*yperp;

      /* Right point */
      z1 = *(magptr + ncols);
      z2 = *(magptr + ncols + 1);

      mag2 = (z1 - z2)*xperp + (z1 - m00)*yperp; 
      }
    }
    else
    {
      if (gx >= -gy)
      {
      /* 101 */
      /* Left point */
      z1 = *(magptr - 1);
      z2 = *(magptr + ncols - 1);

      mag1 = (m00 - z1)*xperp + (z1 - z2)*yperp;
    
      /* Right point */
      z1 = *(magptr + 1);
      z2 = *(magptr - ncols + 1);

      mag2 = (m00 - z1)*xperp + (z1 - z2)*yperp;
      }
      else
      {  
      /* 100 */
      /* Left point */
      z1 = *(magptr + ncols);
      z2 = *(magptr + ncols - 1);

      mag1 = (z1 - z2)*xperp + (m00 - z1)*yperp;

      /* Right point */
      z1 = *(magptr - ncols);
      z2 = *(magptr - ncols + 1);

      mag2 = (z1 - z2)*xperp  + (m00 - z1)*yperp; 
      }
    }
    }
    else
    {
    if ((gy = *gyptr) >= 0)
    {
      if (-gx >= gy)
      {    
      /* 011 */
      /* Left point */
      z1 = *(magptr + 1);
      z2 = *(magptr - ncols + 1);

      mag1 = (z1 - m00)*xperp + (z2 - z1)*yperp;

      /* Right point */
      z1 = *(magptr - 1);
      z2 = *(magptr + ncols - 1);

      mag2 = (z1 - m00)*xperp + (z2 - z1)*yperp;
      }
      else
      {
      /* 010 */
      /* Left point */
      z1 = *(magptr - ncols);
      z2 = *(magptr - ncols + 1);

      mag1 = (z2 - z1)*xperp + (z1 - m00)*yperp;

      /* Right point */
      z1 = *(magptr + ncols);
      z2 = *(magptr + ncols - 1);

      mag2 = (z2 - z1)*xperp + (z1 - m00)*yperp;
      }
    }
    else
    {
      if (-gx > -gy)
      {
      /* 001 */
      /* Left point */
      z1 = *(magptr + 1);
      z2 = *(magptr + ncols + 1);

      mag1 = (z1 - m00)*xperp + (z1 - z2)*yperp;

      /* Right point */
      z1 = *(magptr - 1);
      z2 = *(magptr - ncols - 1);

      mag2 = (z1 - m00)*xperp + (z1 - z2)*yperp;
      }
      else
      {
      /* 000 */
      /* Left point */
      z1 = *(magptr + ncols);
      z2 = *(magptr + ncols + 1);

      mag1 = (z2 - z1)*xperp + (m00 - z1)*yperp;

      /* Right point */
      z1 = *(magptr - ncols);
      z2 = *(magptr - ncols - 1);

      mag2 = (z2 - z1)*xperp + (m00 - z1)*yperp;
      }
    }
    } 

    /* Now determine if the current point is a maximum point */

    if ((mag1 > 0.0) || (mag2 > 0.0))
    {
    *resultptr = (unsigned char) NOEDGE;
    }
    else
    {  
    if (mag2 == 0.0)
      *resultptr = (unsigned char) NOEDGE;
    else
      *resultptr = (unsigned char) POSSIBLE_EDGE;
    }
  } 
  }
}

/*******************************************************************************
* PROCEDURE: magnitude_x_y
* PURPOSE: Compute the magnitude of the gradient. This is the square root of
* the sum of the squared derivative values.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void magnitude_x_y(short int *delta_x, short int *delta_y, int rows, int cols, short int **magnitude)
{
  int r, c, pos, sq1, sq2;

  /****************************************************************************
  * Allocate an image to store the magnitude of the gradient.
  ****************************************************************************/
  if((*magnitude = (short *) calloc(rows*cols, sizeof(short))) == NULL) 
  {
  printf("Error allocating the magnitude image.\n");
  exit(1);
  }

  for(r=0,pos=0;r<rows;r++){
  for(c=0;c<cols;c++,pos++){
   sq1 = (int)delta_x[pos] * (int)delta_x[pos];
   sq2 = (int)delta_y[pos] * (int)delta_y[pos];
   (*magnitude)[pos] = (short)(0.5 + sqrt((float)sq1 + (float)sq2));
  }
  }
}

/*******************************************************************************
* PROCEDURE: derrivative_x_y
* PURPOSE: Compute the first derivative of the image in both the x any y
* directions. The differential filters that are used are:
*
*            -1
*   dx =  -1 0 +1  and  dy =  0
*            +1
*
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void derrivative_x_y(short int *smoothedim, int rows, int cols, short int **delta_x, short int **delta_y)
{
  int r, c, pos;

  /****************************************************************************
  * Allocate images to store the derivatives.
  ****************************************************************************/
  if(((*delta_x) = (short *) calloc(rows*cols, sizeof(short))) == NULL)
  {
  printf("Error allocating the delta_x image.\n");
  exit(1);
  }
  if(((*delta_y) = (short *) calloc(rows*cols, sizeof(short))) == NULL)
  {
  printf("Error allocating the delta_x image.\n");
  exit(1);
  }

  /****************************************************************************
  * Compute the x-derivative. Adjust the derivative at the borders to avoid
  * losing pixels.
  ****************************************************************************/
  for(r=0;r<rows;r++){
  pos = r * cols;
  (*delta_x)[pos] = smoothedim[pos+1] - smoothedim[pos];
  pos++;
  for(c=1;c<(cols-1);c++,pos++){
   (*delta_x)[pos] = smoothedim[pos+1] - smoothedim[pos-1];
  }
  (*delta_x)[pos] = smoothedim[pos] - smoothedim[pos-1];
  }

  /****************************************************************************
  * Compute the y-derivative. Adjust the derivative at the borders to avoid
  * losing pixels.
  ****************************************************************************/
  for(c=0;c<cols;c++){
  pos = c;
  (*delta_y)[pos] = smoothedim[pos+cols] - smoothedim[pos];
  pos += cols;
  for(r=1;r<(rows-1);r++,pos+=cols){
   (*delta_y)[pos] = smoothedim[pos+cols] - smoothedim[pos-cols];
  }
  (*delta_y)[pos] = smoothedim[pos] - smoothedim[pos-cols];
  }
}


