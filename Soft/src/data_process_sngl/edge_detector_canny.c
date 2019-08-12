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

File  : edge_detector_canny.c
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
  laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

* (c) 2001 University of South Florida, Tampa
* Use, or copying without permission prohibited.
* PERMISSION TO USE
* In transmitting this software, permission to use for research and
* educational purposes is hereby granted.  This software may be copied for
* archival and backup purposes only.  This software may not be transmitted
* to a third party without prior permission of the copyright holder. This
* permission may be granted only by Mike Heath or Prof. Sudeep Sarkar of
* University of South Florida (sarkar@csee.usf.edu). Acknowledgment as
* appropriate is respectfully requested.
* 
*  Heath, M., Sarkar, S., Sanocki, T., and Bowyer, K. Comparison of edge
*  detectors: a methodology and initial study, Computer Vision and Image
*  Understanding 69 (1), 38-54, January 1998.
*  Heath, M., Sarkar, S., Sanocki, T. and Bowyer, K.W. A Robust Visual
*  Method for Assessing the Relative Performance of Edge Detection
*  Algorithms, IEEE Transactions on Pattern Analysis and Machine
*  Intelligence 19 (12),  1338-1359, December 1997.
*  ------------------------------------------------------
*
* PROGRAM: canny_edge
* PURPOSE: This program implements a "Canny" edge detector. The processing
* steps are as follows:
*
*  1) Convolve the image with a separable gaussian filter.
*  2) Take the dx and dy the first derivatives using [-1,0,1] and [1,0,-1]'.
*  3) Compute the magnitude: sqrt(dx*dx+dy*dy).
*  4) Perform non-maximal suppression.
*  5) Perform hysteresis.
*
* The user must input three parameters. These are as follows:
*
*  sigma = The standard deviation of the gaussian smoothing filter.
*  tlow  = Specifies the low value to use in hysteresis. This is a 
*    fraction (0-1) of the computed high threshold edge strength value.
*  thigh = Specifies the high value to use in hysteresis. This fraction (0-1)
*    specifies the percentage point in a histogram of the gradient of
*    the magnitude. Magnitude values of zero are not counted in the
*    histogram.
*
* NAME: Mike Heath
*  Computer Vision Laboratory
*  University of South Floeida
*  heath@csee.usf.edu
*
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
void canny(unsigned char *image, int rows, int cols, float sigma, float tlow, float thigh, unsigned char **edge);
void gaussian_smooth(unsigned char *image, int rows, int cols, float sigma, short int **smoothedim);
void make_gaussian_kernel(float sigma, float **kernel, int *windowsize);
void derrivative_x_y(short int *smoothedim, int rows, int cols, short int **delta_x, short int **delta_y);
void magnitude_x_y(short int *delta_x, short int *delta_y, int rows, int cols, short int **magnitude);
void follow_edges(unsigned char *edgemapptr, short *edgemagptr, short lowval, int cols);
void apply_hysteresis(short int *mag, unsigned char *nms, int rows, int cols, float tlow, float thigh, unsigned char *edge);
void non_max_supp(short *mag, short *gradx, short *grady, int nrows, int ncols, unsigned char *result);

/* GLOBAL VARIABLES */
#define BOOSTBLURFACTOR 90.0
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

  int rows, cols;
  unsigned char *image;
  unsigned char *edge;
  float sigma, tlow = 0.25, thigh = 0.75;

/* Matrix arrays */
  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;
  float *datatmp;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nedge_detector_canny.exe\n");
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

  sigma = 2. - sigma;

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
  //image = vector_char(rows*cols);
  if((image=(unsigned char *)calloc(rows*cols,sizeof(unsigned char))) == NULL){
    printf("Error allocating the edge image.\n");
    exit(1);
    }

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
    image[lig*Sub_Ncol+col] = (unsigned char) floor(1. + 254. * xx);    
    }
  } /* lig */
  
  free_vector_float(datatmp);
  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_int(bufferdataint);

/********************************************************************
********************************************************************/

/* Perform the edge detection. All of the work takes place here */

  canny(image, rows, cols, sigma, tlow, thigh, &edge);

/********************************************************************
********************************************************************/

  bufferdatafloat = vector_float(Sub_Ncol);
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      bufferdatafloat[col] =  (float)((int) edge[lig*Sub_Ncol+col]) /255.;
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

/*******************************************************************************
* PROCEDURE: canny
* PURPOSE: To perform canny edge detection.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void canny(unsigned char *image, int rows, int cols, float sigma, float tlow, float thigh, unsigned char **edge)
{
  unsigned char *nms;  /* Points that are local maximal magnitude. */
  short int *smoothedim,  /* The image after gaussian smoothing.  */
    *delta_x,  /* The first devivative image, x-direction. */
    *delta_y,  /* The first derivative image, y-direction. */
    *magnitude;  /* The magnitude of the gadient image.  */

  /****************************************************************************
  * Perform gaussian smoothing on the image using the input standard
  * deviation.
  ****************************************************************************/
  gaussian_smooth(image, rows, cols, sigma, &smoothedim);

  /****************************************************************************
  * Compute the first derivative in the x and y directions.
  ****************************************************************************/
  derrivative_x_y(smoothedim, rows, cols, &delta_x, &delta_y);

  /****************************************************************************
  * Compute the magnitude of the gradient.
  ****************************************************************************/
  magnitude_x_y(delta_x, delta_y, rows, cols, &magnitude);

  /****************************************************************************
  * Perform non-maximal suppression.
  ****************************************************************************/
  if((nms = (unsigned char *) calloc(rows*cols,sizeof(unsigned char)))==NULL){
  printf("Error allocating the nms image.\n");
  exit(1);
  }

  non_max_supp(magnitude, delta_x, delta_y, rows, cols, nms);

  /****************************************************************************
  * Use hysteresis to mark the edge pixels.
  ****************************************************************************/
  if((*edge=(unsigned char *)calloc(rows*cols,sizeof(unsigned char))) ==NULL){
  printf("Error allocating the edge image.\n");
  exit(1);
  }

  apply_hysteresis(magnitude, nms, rows, cols, tlow, thigh, *edge);

  /****************************************************************************
  * Free all of the memory that we allocated except for the edge image that
  * is still being used to store out result.
  ****************************************************************************/
  free(smoothedim);
  free(delta_x);
  free(delta_y);
  free(magnitude);
  free(nms);
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
  if((*magnitude = (short *) calloc(rows*cols, sizeof(short))) == NULL){
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
  if(((*delta_x) = (short *) calloc(rows*cols, sizeof(short))) == NULL){
  printf("Error allocating the delta_x image.\n");
  exit(1);
  }
  if(((*delta_y) = (short *) calloc(rows*cols, sizeof(short))) == NULL){
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

/*******************************************************************************
* PROCEDURE: gaussian_smooth
* PURPOSE: Blur an image with a gaussian filter.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void gaussian_smooth(unsigned char *image, int rows, int cols, float sigma, short int **smoothedim)
{
  int r, c, rr, cc,  /* Counter variables. */
  windowsize,  /* Dimension of the gaussian kernel. */
  center;    /* Half of the windowsize. */
  float *tempim,  /* Buffer for separable filter gaussian smoothing. */
   *kernel,  /* A one dimensional gaussian kernel. */
   dot,    /* Dot product summing variable. */
   sum;    /* Sum of the kernel weights variable. */

  /****************************************************************************
  * Create a 1-dimensional gaussian smoothing kernel.
  ****************************************************************************/
  make_gaussian_kernel(sigma, &kernel, &windowsize);
  center = windowsize / 2;

  /****************************************************************************
  * Allocate a temporary buffer image and the smoothed image.
  ****************************************************************************/
  if((tempim = (float *) calloc(rows*cols, sizeof(float))) == NULL){
  printf("Error allocating the buffer image.\n");
  exit(1);
  }
  if(((*smoothedim) = (short int *) calloc(rows*cols, sizeof(short int))) == NULL){
  printf("Error allocating the smoothed image.\n");
  exit(1);
  }

  /****************************************************************************
  * Blur in the x - direction.
  ****************************************************************************/
  for(r=0;r<rows;r++){
  for(c=0;c<cols;c++){
   dot = 0.0;
   sum = 0.0;
   for(cc=(-center);cc<=center;cc++){
    if(((c+cc) >= 0) && ((c+cc) < cols)){
    dot += (float)image[r*cols+(c+cc)] * kernel[center+cc];
    sum += kernel[center+cc];
    }
   }
   tempim[r*cols+c] = dot/sum;
  }
  }

  /****************************************************************************
  * Blur in the y - direction.
  ****************************************************************************/
  for(c=0;c<cols;c++){
  for(r=0;r<rows;r++){
   sum = 0.0;
   dot = 0.0;
   for(rr=(-center);rr<=center;rr++){
    if(((r+rr) >= 0) && ((r+rr) < rows)){
    dot += tempim[(r+rr)*cols+c] * kernel[center+rr];
    sum += kernel[center+rr];
    }
   }
   (*smoothedim)[r*cols+c] = (short int)(dot*BOOSTBLURFACTOR/sum + 0.5);
  }
  }

  free(tempim);
  free(kernel);
}

/*******************************************************************************
* PROCEDURE: make_gaussian_kernel
* PURPOSE: Create a one dimensional gaussian kernel.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void make_gaussian_kernel(float sigma, float **kernel, int *windowsize)
{
  int i, center;
  float x, fx, sum=0.0;

  *windowsize = 1 + 2 * ceil(2.5 * sigma);
  center = (*windowsize) / 2;

  if((*kernel = (float *) calloc((*windowsize), sizeof(float))) == NULL){
  printf("Error callocing the gaussian kernel array.\n");
  exit(1);
  }

  for(i=0;i<(*windowsize);i++){
  x = (float)(i - center);
  fx = pow(2.71828, -0.5*x*x/(sigma*sigma)) / (sigma * sqrt(6.2831853));
  (*kernel)[i] = fx;
  sum += fx;
  }

  for(i=0;i<(*windowsize);i++) (*kernel)[i] /= sum;

}

/*******************************************************************************
* PROCEDURE: follow_edges
* PURPOSE: This procedure edges is a recursive routine that traces edgs along
* all paths whose magnitude values remain above some specifyable lower
* threshhold.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void follow_edges(unsigned char *edgemapptr, short *edgemagptr, short lowval, int cols)
{
  short *tempmagptr;
  unsigned char *tempmapptr;
  int i;
  int x[8] = {1,1,0,-1,-1,-1,0,1},
  y[8] = {0,1,1,1,0,-1,-1,-1};

  for(i=0;i<8;i++){
  tempmapptr = edgemapptr - y[i]*cols + x[i];
  tempmagptr = edgemagptr - y[i]*cols + x[i];

  if((*tempmapptr == POSSIBLE_EDGE) && (*tempmagptr > lowval)){
   *tempmapptr = (unsigned char) EDGE;
   follow_edges(tempmapptr,tempmagptr, lowval, cols);
  }
  }
}

/*******************************************************************************
* PROCEDURE: apply_hysteresis
* PURPOSE: This routine finds edges that are above some high threshhold or
* are connected to a high pixel by a path of pixels greater than a low
* threshold.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void apply_hysteresis(short int *mag, unsigned char *nms, int rows, int cols, float tlow, float thigh, unsigned char *edge)
{
  int r, c, pos, numedges, highcount, lowthreshold, highthreshold, hist[32768];
  short int maximum_mag;

  /****************************************************************************
  * Initialize the edge map to possible edges everywhere the non-maximal
  * suppression suggested there could be an edge except for the border. At
  * the border we say there can not be an edge because it makes the
  * follow_edges algorithm more efficient to not worry about tracking an
  * edge off the side of the image.
  ****************************************************************************/
  for(r=0,pos=0;r<rows;r++){
  for(c=0;c<cols;c++,pos++){
    if(nms[pos] == POSSIBLE_EDGE) edge[pos] = POSSIBLE_EDGE;
    else edge[pos] = NOEDGE;
  }
  }

  for(r=0,pos=0;r<rows;r++,pos+=cols){
  edge[pos] = NOEDGE;
  edge[pos+cols-1] = NOEDGE;
  }
  pos = (rows-1) * cols;
  for(c=0;c<cols;c++,pos++){
  edge[c] = NOEDGE;
  edge[pos] = NOEDGE;
  }

  /****************************************************************************
  * Compute the histogram of the magnitude image. Then use the histogram to
  * compute hysteresis thresholds.
  ****************************************************************************/
  for(r=0;r<32768;r++) hist[r] = 0;
  for(r=0,pos=0;r<rows;r++){
  for(c=0;c<cols;c++,pos++){
    if(edge[pos] == POSSIBLE_EDGE) hist[mag[pos]]++;
  }
  }

  /****************************************************************************
  * Compute the number of pixels that passed the nonmaximal suppression.
  ****************************************************************************/
  for(r=1,numedges=0;r<32768;r++){
  if(hist[r] != 0) maximum_mag = r;
  numedges += hist[r];
  }

  highcount = (int)(numedges * thigh + 0.5);

  /****************************************************************************
  * Compute the high threshold value as the (100 * thigh) percentage point
  * in the magnitude of the gradient histogram of all the pixels that passes
  * non-maximal suppression. Then calculate the low threshold as a fraction
  * of the computed high threshold value. John Canny said in his paper
  * "A Computational Approach to Edge Detection" that "The ratio of the
  * high to low threshold in the implementation is in the range two or three
  * to one." That means that in terms of this implementation, we should
  * choose tlow ~= 0.5 or 0.33333.
  ****************************************************************************/
  r = 1;
  numedges = hist[1];
  while((r<(maximum_mag-1)) && (numedges < highcount)){
  r++;
  numedges += hist[r];
  }
  highthreshold = r;
  lowthreshold = (int)(highthreshold * tlow + 0.5);

  /****************************************************************************
  * This loop looks for pixels above the highthreshold to locate edges and
  * then calls follow_edges to continue the edge.
  ****************************************************************************/
  for(r=0,pos=0;r<rows;r++){
  for(c=0;c<cols;c++,pos++){
    if((edge[pos] == POSSIBLE_EDGE) && (mag[pos] >= highthreshold)){
    edge[pos] = EDGE;
    follow_edges((edge+pos), (mag+pos), lowthreshold, cols);
    }
  }
  }

  /****************************************************************************
  * Set all the remaining possible edges to non-edges.
  ****************************************************************************/
  for(r=0,pos=0;r<rows;r++){
  for(c=0;c<cols;c++,pos++) if(edge[pos] != EDGE) edge[pos] = NOEDGE;
  }
}

/*******************************************************************************
* PROCEDURE: non_max_supp
* PURPOSE: This routine applies non-maximal suppression to the magnitude of
* the gradient image.
* NAME: Mike Heath
* DATE: 2/15/96
*******************************************************************************/
void non_max_supp(short *mag, short *gradx, short *grady, int nrows, int ncols, unsigned char *result)
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


