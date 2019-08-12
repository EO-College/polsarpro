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

File  : edge_detector_rothwell.c
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

* Program: Topology
* Purpose: This program contains an implementation of the Edge Detector
* described in the technical report: "Driving Vision by Topology" by Charlie
* Rothwell, Joe Mundy, Bill Hoffman and Van-Duc Nguyen. A shorter version of
* the report was published as a paper with the same name.
* This implementation of the program was also aided by the code Charlie Rothwell
* sent us. He sent us the edge detector modulules of a larger vision package
* that was coded in C++. This program just pulled together those modules into
* a complete edge detector program coded in 'C'. I tried to use as much of his
* code as possible to both simplify the coding task and to make sure that this
* implementation is consistent with theirs.
* Name: Mike Heath
* Date: 5/2/96
*
* The user must input three parameters: sigma, tlow and alpha.
*
* NAME: Mike Heath
*  Computer Vision Laboratory
*  University of South Floeida
*  heath@csee.usf.edu

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

typedef struct
{
  int x;
  int y;
  float thin;
}XYFLOAT;

/*******************************************************************
* This is the compare function for the quicksort function
* provided with 'C'.
********************************************************************/
static int cmp (void const *xyf1, void const *xyf2)
{
  XYFLOAT const *pxyf1 = xyf1;
  XYFLOAT const *pxyf2 = xyf2;
  if (pxyf1->thin < pxyf2->thin) return(-1);
  if(pxyf1->thin == pxyf2->thin) return(0);
  return 1;
}
/*******************************************************************/

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
int read_pgm_image(char *infilename, unsigned char **image, int *rows, int *cols);
int write_pgm_image(char *outfilename, unsigned char *image, int rows, int cols, char *comment, int maxval);
void Sub_pixel_interpolation(float **_grad, float **_dx, float **_dy, int cols, int rows, int kwidth, float _low, float ALPHA, float ***_thresh, int ***_dist, float ***_theta);
void Thicken_threshold(float **_thresh, int **_dist, int x, int y, float _low, int kwidth);
void Compute_gradient(float **dx, float **dy, int cols, int rows, int kwidth, float ***grad);
void Compute_x_gradient(float **smoothedimage, int cols, int rows, int kwidth, float ***dx);
void Compute_y_gradient(float **smoothedimage, int cols, int rows, int kwidth, float ***dy);
void Smooth_image(float **image, int cols, int rows, float ***smoothedimage, float sigma, int *kwidth, float gauss_tail);
void Set_kernel(float **kernel, float sigma, int width, int k_size);
int **Make_int_image(int x, int y);
void Set_int_image(int **image, int val, int cols, int rows);
void Copy_int_image(int **image1, int **image2, int cols, int rows);
void Free_int_image(int ***ptr);
float **Make_float_image(int x, int y);
void Set_float_image(float **image, float val, int cols, int rows);
void Copy_float_image(float **image1, float **image2, int cols, int rows);
void Free_float_image(float ***ptr);
void Set_thresholds(int **_dist, float **_grad, float **_thresh, float ***_thin, int cols, int rows, float _low);
void Forward_chamfer(int m, int n, int **dist, float **param);
void Backward_chamfer(int m, int n, int **dist, float **param);
void Alt1_chamfer(int m, int n, int **dist, float **param);
void Alt2_chamfer(int m, int n, int **dist, float **param);
int Minimum4(int a, int b, int c, int d);
int Minimum5(int a, int b, int c, int d, int e);
//int compare(XYFLOAT *xyf1, XYFLOAT *xyf2);
void Thin_edges(float **_thin, float **_thresh, int cols, int rows, int kwidth);

/* GLOBAL VARIABLES */
#define GAUSS_TAIL 0.015  /* As recommended in the technical report. */
#define FAR 65535
#define DUMMYTHETA 10000.0

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
  int kwidth;
  int **dist=NULL;
  float sigma, low=15.0, alpha=0.8;
  float **image=NULL, **smoothedimage=NULL;
  float **dx=NULL, **dy=NULL;
  float **grad=NULL, **thresh=NULL;
  float **theta=NULL, **thin=NULL;

/* Matrix arrays */
  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;
  float *datatmp;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nedge_detector_rothwell.exe\n");
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
  image = Make_float_image(cols, rows);

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
    image[col][lig] = 1. + 254. * xx;
    }
  } /* lig */

  free_vector_float(datatmp);
  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_int(bufferdataint);

/********************************************************************
********************************************************************/

/* Perform the edge detection. All of the work takes place here */

  Smooth_image(image, cols, rows, &smoothedimage, sigma, &kwidth, GAUSS_TAIL);
  
  Compute_x_gradient(smoothedimage, cols, rows, kwidth, &dx);
  Compute_y_gradient(smoothedimage, cols, rows, kwidth, &dy);
  Free_float_image(&smoothedimage);
  Compute_gradient(dx, dy, cols, rows, kwidth, &grad);
  
  Sub_pixel_interpolation(grad, dx, dy, cols, rows, kwidth, low, alpha, &thresh, &dist, &theta);
  
  Free_float_image(&dx);
  Free_float_image(&dy);
  
  Set_thresholds(dist, grad, thresh, &thin, cols, rows, low);
  Thin_edges(thin, thresh, cols, rows, kwidth);

/********************************************************************
********************************************************************/

  bufferdatafloat = vector_float(Sub_Ncol);
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      if (thin[col][lig] != 0.0) bufferdatafloat[col] = 0.;
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

/*******************************************************************
* Method to thin the image using the variation of Tsai-Fu thinning
* used by Van-Duc Nguyen in Geo-Calc. This relies on computing the 
* genus of an edge location, and removing it if it is not a dangling
* chain as has genus zero. We also order the edges by strength and
* try to remove the weaker ones first. This accounts for non-maximal
* supression, and does it in a topology preserving way. Note that we
* are creating a CoolList with a large number of elements, and then
* sorting it -- this is likely to be quite slow.
* An alternative implementation would be better.
********************************************************************/
void Thin_edges(float **_thin, float **_thresh, int cols, int rows, int kwidth)
{
  /* Find all of the edgels with a strength > _low */
  int x, y, a, b, c, d, e, f, g, h, genus, count;
  XYFLOAT *edgel_array=NULL;
  int edgel_array_len = 0;
  int pos = 0;

  if((edgel_array = (XYFLOAT *) calloc(cols*rows, sizeof(XYFLOAT)))==NULL){
  printf("Error allocating the xyfloat array in Thin_edges().\n");
  exit(1);
  }

  count = 1;  /* count set to dummy value */
  while(count){  /* Thin until no Pixels are removed */
  count = 0;
  edgel_array_len = 0;
  for(x=kwidth;x<(cols-kwidth);x++){
   for(y=kwidth;y<(rows-kwidth);y++){
    if(_thin[x][y] > _thresh[x][y]){
    edgel_array[edgel_array_len].x = x;
    edgel_array[edgel_array_len].y = y;
    edgel_array[edgel_array_len].thin = _thin[x][y];
    edgel_array_len++;
    }
   }
  }

  /*************************************************************************
  * Now sort the list; this could be slow if we have a lot of potential.
  * edges - surely we have to do number of elements (not -1)?
  *  qsort(edgel_array, edgel_array_len-1, sizeof(xyfloat), compare);
  *************************************************************************/

  qsort(edgel_array, edgel_array_len, sizeof(XYFLOAT), cmp);

  /************************************************************************* 
  * Do the thinning taking the weakest edges first and works
  * up through the list strengthwise.
  **************************************************************************/
  for(pos=0;pos<edgel_array_len;pos++){
   x = edgel_array[pos].x;
   y = edgel_array[pos].y;
   
   if( _thin[x-1][y-1] > _thresh[x-1][y-1] )  a = 1; else a = 0;
   if( _thin[x][y-1]  > _thresh[x][y-1]  )  b = 1; else b = 0;
   if( _thin[x+1][y-1] > _thresh[x+1][y-1] )  c = 1; else c = 0;
   if( _thin[x+1][y]  > _thresh[x+1][y]  )  d = 1; else d = 0;
   if( _thin[x+1][y+1] > _thresh[x+1][y+1] )  e = 1; else e = 0;
   if( _thin[x][y+1]  > _thresh[x][y+1]  )  f = 1; else f = 0;
   if( _thin[x-1][y+1] > _thresh[x-1][y+1] )  g = 1; else g = 0;
   if( _thin[x-1][y]  > _thresh[x-1][y]  )  h = 1; else h = 0;
   
   genus = a+b+c+d+e+f+g+h;

   /* Continue if the pixel is not dangling. */

   if((genus!=1) && (genus!=8)){

    genus += h*a*b+b*c*d+d*e*f+f*g*h-a*b-b*c-c*d-d*e-e*f-f*g -
      g*h-h*a-h*b-b*d-d*f-f*h-1;

    /* If the genus is zero delete the edge */

    if(genus == 0){
    count++;
    _thin[x][y] = 0.0;
    }
   }
  }
  }

  free(edgel_array);
}

/*******************************************************************************
* Takes the _thresh image that contains threshold values near to where
* non-maximal suppression succeeded, and zero elsewhere, and extend the
* values to all areas of the image. This is done using chamfer masks so that
* the final threshold assigned at any one point (ie. a point that was initially
* zero) is functionally dependent on the the strengths of the nearest good
* edges. At present we linearly interpolate between the two (approximately)
* closest edges.
* 
* Try to do the same process using Delauney triangulation (CAR, March 1995), in
* an attempt to image the efficiency from a memeory management point of view.
* However, the triangulation becomes so complex that the computation time
* becomes incredibably long. Therefore putting up with the Chamfer method for
* the moment.
* 
* The histogram calculation was added to support
* Edgel change detection-JLM May 1995
*******************************************************************************/
void Set_thresholds(int **_dist, float **_grad, float **_thresh, float ***_thin, int cols, int rows, float _low)
{
  int **fdist=NULL, **bdist=NULL, **a1dist=NULL, **a2dist=NULL;
  float **fth=NULL, **bth=NULL, **a1th=NULL, **a2th=NULL;
  int x, y, option;
  float num, den;
  float max_gradient = _low;

  *_thin = Make_float_image(cols, rows);

  fdist = Make_int_image(cols, rows);
  bdist = Make_int_image(cols, rows);
  a1dist = Make_int_image(cols, rows);
  a2dist = Make_int_image(cols, rows);
  Copy_int_image(_dist, fdist, cols, rows);
  Copy_int_image(_dist, bdist, cols, rows);
  Copy_int_image(_dist, a1dist, cols, rows);
  Copy_int_image(_dist, a2dist, cols, rows);

  fth = Make_float_image(cols, rows);
  bth = Make_float_image(cols, rows);
  a1th = Make_float_image(cols, rows);
  a2th = Make_float_image(cols, rows);
  Copy_float_image(_thresh, fth, cols, rows);
  Copy_float_image(_thresh, bth, cols, rows);
  Copy_float_image(_thresh, a1th, cols, rows);
  Copy_float_image(_thresh, a2th, cols, rows);

  Forward_chamfer(cols, rows, fdist, fth);
  Backward_chamfer(cols, rows, bdist, bth);
  Alt1_chamfer(cols, rows, a1dist, a1th);
  Alt2_chamfer(cols, rows, a2dist, a2th);

  /****************************************************************************
  * The range of the effect of the smoothing kernel, including the scale
  * factor we have ignored up to now for the chamfer masks
  *  int range = 3*_width;
  ****************************************************************************/
  for(x=0;x<cols;x++){
  for(y=0;y<rows;y++){
   if(_thresh[x][y] == _low){

    /* Determine the two closest edge points. */

    option = Minimum4(fdist[x][y],bdist[x][y],a1dist[x][y],a2dist[x][y]);
    switch(option){
    case 1:
    case 2:
      den = (fdist[x][y]+bdist[x][y]);
      num = (bdist[x][y]*fth[x][y]+fdist[x][y]*bth[x][y]);
      break;

    case 3:
    case 4:
      den = (a1dist[x][y]+a2dist[x][y]);
      num = (a2dist[x][y]*a1th[x][y]+a1dist[x][y]*a2th[x][y]);
      break;

    default:
      den = num = 1.0; /* Dummy values */
      break;
    }
    if(den != 0.0)
    _thresh[x][y] = num / den;
    else if(_thresh[x][y] <= _low) _thresh[x][y] = _low;
   }

   if(_grad[x][y] > _thresh[x][y]){
    if(_grad[x][y] > max_gradient) max_gradient = _grad[x][y];
    (*_thin)[x][y] = _grad[x][y];
   }
  }
  }

  Free_int_image(&fdist);
  Free_int_image(&bdist);
  Free_int_image(&a1dist);
  Free_int_image(&a2dist);
  Free_float_image(&fth);
  Free_float_image(&bth);
  Free_float_image(&a1th);
  Free_float_image(&a2th);
}

/*******************************************************************************
* Performs a forward chamfer convolution on the dist image and associates
* a send image (param) that reports on some parameter of the nearest pixel.
* The image sizes are mxn
*******************************************************************************/
void Forward_chamfer(int m, int n, int **dist, float **param)
{
  int i, j, val;

  for(i=1;i<(m-1);i++){
  for(j=1;j<(n-1);j++){

   val = Minimum5(dist[i-1][j-1]+4, dist[i-1][j]+3, dist[i-1][j+1]+4, dist[i][j-1]+3, dist[i][j]);

   switch(val){
    case 1:
    dist[i][j] = dist[i-1][j-1]+4;
    param[i][j] = param[i-1][j-1];
    break;

    case 2:
    dist[i][j] = dist[i-1][j]+3;
    param[i][j] = param[i-1][j];
    break;

    case 3:
    dist[i][j] = dist[i-1][j+1]+4;
    param[i][j] = param[i-1][j+1];
    break;

    case 4:
    dist[i][j] = dist[i][j-1]+3;
    param[i][j] = param[i][j-1];
    break;

    case 5:
    break;
   }
  }
  }
}

/*******************************************************************************
* Performs a backward chamfer convolution on the dist and param images.
*******************************************************************************/
void Backward_chamfer(int m, int n, int **dist, float **param)
{
  int i,j,val;

  for(i=m-2;i>0;i--){
  for(j=n-2;j>0;j--){

   val = Minimum5(dist[i][j], dist[i][j+1]+3, dist[i+1][j-1]+4, dist[i+1][j]+3, dist[i+1][j+1]+4 );

   switch(val){
    case 1:
    break;

    case 2:
    dist[i][j] = dist[i][j+1]+3;
    param[i][j] = param[i][j+1];
    break;

    case 3:
    dist[i][j] = dist[i+1][j-1]+4;
    param[i][j] = param[i+1][j-1];
    break;

    case 4:
    dist[i][j] = dist[i+1][j]+3;
    param[i][j] = param[i+1][j];
    break;

    case 5:
    dist[i][j] = dist[i+1][j+1]+4;
    param[i][j] = param[i+1][j+1];
    break;
   }
  }
  }
}

/*******************************************************************************
* Performs a chamfer convolution starting from (minx,maxy) on the dist image
* and associates a send image (param) that reports on some parameter of the
* nearest pixel. The image sizes are mxn
********************************************************************************/
void Alt1_chamfer(int m, int n, int **dist, float **param)
{
  int i,j,val;

  for(i=1;i<m-1;i++){
  for(j=n-2;j>0;j--){

   val = Minimum5(dist[i-1][j+1]+4, dist[i-1][j]+3, dist[i-1][j-1]+4, dist[i][j+1]+3, dist[i][j]);

   switch (val){

    case 1:
    dist[i][j] = dist[i-1][j+1]+4;
    param[i][j] = param[i-1][j+1];
    break;

    case 2:
    dist[i][j] = dist[i-1][j]+3;
    param[i][j] = param[i-1][j];
    break;

    case 3:
    dist[i][j] = dist[i-1][j-1]+4;
    param[i][j] = param[i-1][j-1];
    break;

    case 4:
    dist[i][j] = dist[i][j+1]+3;
    param[i][j] = param[i][j+1];
    break;

    case 5:
    break;
   }
  }
  }
}

/*******************************************************************************
* Performs a chamfer convolution starting from (maxx,miny) on the dist image
* and associates a send image (param) that reports on some parameter of the
* nearest pixel. The image sizes are mxn
*******************************************************************************/
void Alt2_chamfer(int m, int n, int **dist, float **param)
{
  int i,j,val;

  for(i=m-2;i>0;i--){
  for(j=1;j<n-1;j++){

   val = Minimum5(dist[i][j], dist[i][j+1]+3, dist[i+1][j-1]+4, dist[i+1][j]+3, dist[i+1][j+1]+4);

   switch (val){

    case 1:
    break;

    case 2:
    dist[i][j] = dist[i][j+1]+3;
    param[i][j] = param[i][j+1];
    break;

    case 3:
    dist[i][j] = dist[i+1][j-1]+4;
    param[i][j] = param[i+1][j-1];
    break;

    case 4:
    dist[i][j] = dist[i+1][j]+3;
    param[i][j] = param[i+1][j];
    break;

    case 5:
    dist[i][j] = dist[i+1][j+1]+4;
    param[i][j] = param[i+1][j+1];
    break;
   }
  }
  }
}

/*******************************************************************************
* Determines the minimum of four ints.
*******************************************************************************/
int Minimum4(int a, int b, int c, int d)
{
  if((a<=b) && (a<=c) && (a<=d)) return(1);
  else if((b<=c) && (b<=d)) return(2);
  else if((c<=d)) return(3);
  else return(4);
}

/*******************************************************************************
* Determines the minimum of five ints.
*******************************************************************************/
int Minimum5(int a, int b, int c, int d, int e)
{
  if((a<=b) && (a<=c) && (a<=d) && (a<=e)) return(1);
  else if((b<=c) && (b<=d) && (b<=e)) return(2);
  else if((c<=d) && (c<=e)) return(3);
  else if(d<=e) return(4);
  else return(5);
}

/*******************************************************************************
* A procedure that performs sub-pixel interpolation for all edges greater than
* the threshold by parabolic fitting. Writes edges into the _thresh image if they
* are maxima and above _low. This gives a good indication of the local edge
* strengths. Stores sub-pixel positions in _dx and _dy, and set the orientations
* in _theta.
*******************************************************************************/
void Sub_pixel_interpolation(float **_grad, float **_dx, float **_dy, int cols,
  int rows, int kwidth, float _low, float ALPHA, float ***_thresh,
  int ***_dist, float ***_theta)
{
  float *g0=NULL, *g1=NULL, *g2=NULL, *dx=NULL, *dy=NULL;
  float h1,h2;
  float k = 180.0/M_PI;
  int x, y, orient;
  float theta, grad;
  float fraction, dnewx, dnewy;

  *_thresh = Make_float_image(cols, rows);
  Set_float_image((*_thresh), _low, cols, rows);

  *_dist = Make_int_image(cols, rows);
  Set_int_image((*_dist), FAR, cols, rows);

  *_theta = Make_float_image(cols, rows);
  Set_float_image((*_theta), DUMMYTHETA, cols, rows);

  /* Add 1 to get rid of border effects. */
  for(x=(kwidth+1);x<(cols-kwidth-1);x++){
  g0 = _grad[x-1];  g1 = _grad[x];  g2 = _grad[x+1];
  dx = _dx[x];  dy = _dy[x];

  for(y=(kwidth+1);y<(rows-kwidth-1);y++){
   /* First check that we have a potential edge. */
   if(g1[y] > _low){
    theta = k*atan2(dy[y],dx[y]);

    /* Now work out which direction wrt the eight-way */
    /* neighbours the edge normal points */
    if(theta >= 0.0) orient = (int)(theta/45.0);
    else orient = (int)(theta/45.0+4);

    /* if theta == 180.0 we will have orient = 4 */
    orient = orient%4;

    /* And now compute the interpolated heights */
    switch(orient){
    case 0:
      grad = dy[y]/dx[y];
      h1 = grad*g0[y-1] + (1 - grad)*g0[y];
      h2 = grad*g2[y+1] + (1 - grad)*g2[y];
      break;

    case 1:
      grad = dx[y]/dy[y];
      h1 = grad*g0[y-1] + (1 - grad)*g1[y-1];
      h2 = grad*g2[y+1] + (1 - grad)*g1[y+1];
      break;

    case 2:
      grad = -dx[y]/dy[y];
      h1 = grad*g2[y-1] + (1 - grad)*g1[y-1];
      h2 = grad*g0[y+1] + (1 - grad)*g1[y+1];
      break;

    case 3:
      grad = -dy[y]/dx[y];
      h1 = grad*g2[y-1] + (1 - grad)*g2[y];
      h2 = grad*g0[y+1] + (1 - grad)*g0[y];
      break;

    default:
      h1 = h2 = 0.0;  /* Dummy value; */
      printf("*** ERROR ON SWITCH IN NMS ***\n");
    }

    /* Do subpixel interpolation by fitting a parabola */
    /* along the NMS line and finding its peak */

    fraction = (h1-h2)/(2.0*(h1-2.0*g1[y]+h2));
    switch(orient){
    case 0:
      dnewx = fraction;
      dnewy = dy[y]/dx[y]*fraction;
      break;

    case 1:
      dnewx = dx[y]/dy[y]*fraction;
      dnewy = fraction;
      break;

    case 2:
      dnewx = dx[y]/dy[y]*fraction;
      dnewy = fraction;
      break;

    case 3:
      dnewx = - fraction;
      dnewy = - dy[y]/dx[y]*fraction;
      break;

    default:
      dnewx = dnewy = 0.0; /* Dummy values */
      printf("*** ERROR ON SWITCH IN NMS ***\n");
    }

    /*******************************************************************
    * Now store the edge data, re-use _dx[][] and _dy[][]
    * for sub-pixel locations (don't worry about the junk
    * that is already in them). Use any edgels that get
    * non-maximal suppression to bootstrap the image
    * thresholds. The >= is used rather than > for reasons
    * involving non-generic images. Should this be interpolated
    * height -- = g1[y] + frac*(h2-h1)/4 ?
    *******************************************************************/
    if((g1[y]>=h1)&&(g1[y]>=h2)&&(fabs(dnewx)<=0.5)&&(fabs(dnewy)<=0.5)){
    if(g1[y]*ALPHA > _low) (*_thresh)[x][y] = ALPHA * g1[y]; /* Use a ALPHA% bound */

    Thicken_threshold((*_thresh), (*_dist), x, y, _low, kwidth);
    }
      
    /* + 0.5 is to account for targetjr display offset */

    if((fabs(dnewx)<=0.5) && (fabs(dnewy)<=0.5)){
    dx[y] = x + dnewx + 0.5;
    dy[y] = y + dnewy + 0.5;
    }
    else{
    dx[y] = x + 0.5;
    dy[y] = y + 0.5;
    }

    (*_theta)[x][y] = theta;
   }

   /* For consistency assign these values even though the */
   /* edge is below strength.        */

   else{
    dx[y] = x + 0.5;
    dy[y] = y + 0.5;
   }
  }
  }

  /****************************************************************************
  * Clean up around the border to ensure consistency in the _dx and _dy values.
  ****************************************************************************/
  for(x=0;x<cols;x++){
  for(y=0;y<=kwidth;y++){
   _dx[x][y] = x + 0.5;
   _dy[x][y] = y + 0.5;
  }
  for(y=(rows-kwidth-1);y<rows;y++){
   _dx[x][y] = x + 0.5;
   _dy[x][y] = y + 0.5;
  }
  }

  for(y=(kwidth+1);y<(rows-kwidth-1);y++){
  for(x=0;x<=kwidth;x++){
   _dx[x][y] = x + 0.5;
   _dy[x][y] = y + 0.5;
  }
  for(x=(cols-kwidth-1);x<cols;x++){
   _dx[x][y] = x + 0.5;
   _dy[x][y] = y + 0.5;
  }
  }
}


/*******************************************************************************
* Thickens the threshold image around each good pixel to take account for the
* smoothing kernel (almost a dilation with a square structuring element).
*******************************************************************************/
void Thicken_threshold(float **_thresh, int **_dist, int x, int y, float _low, int kwidth)
{
  int i,j;

  /* Experimental change 13/4/95 by CAR */
  /* int width = _width; Changed back because not mentioned in the paper MH */
  int width = 0;

  for(i=(x-width);i<=(x+width);i++){
  for(j=(y-width);j<=(y+width);j++){
   _dist[i][j] = 0;
   if(_thresh[i][j] != _low){
    if(_thresh[x][y] < _thresh[i][j]) _thresh[i][j] = _thresh[x][y];
   }
   else _thresh[i][j] = _thresh[x][y];
  }
  }
}

/*******************************************************************************
* Compute the absolute intensity surface gradient, _grad[][].
*******************************************************************************/
void Compute_gradient(float **dx, float **dy, int cols, int rows, int kwidth, float ***grad)
{
  int x, y;

  *grad = Make_float_image(cols, rows);

  /****************************************************************************
  * JLM limits here are _width-1 because of _ksize being 2*_width + 1.
  * I don't understand why to use _width-1 but I will go along with it.
  *  - Mike Heath
  ****************************************************************************/

  for(x=kwidth;x<(cols-kwidth-1);x++){
  for(y=kwidth;y<(rows-kwidth-1);y++){
   (*grad)[x][y] = sqrt(dx[x][y]*dx[x][y] + dy[x][y]*dy[x][y]);
  }
  }
}

/*******************************************************************************
* Convolves with the kernel in the x direction, to compute the local derivative
* in that direction
*******************************************************************************/
void Compute_x_gradient(float **smoothedimage, int cols, int rows, int kwidth, float ***dx)
{
  int x, y;

  *dx = Make_float_image(cols, rows);

  for(y=(kwidth+1);y<(rows-kwidth-1);y++){
  for(x=(kwidth+1);x<(cols-kwidth-1);x++){
   (*dx)[x][y] = smoothedimage[x+1][y] - smoothedimage[x-1][y];
  }
  }
}

/*******************************************************************************
* Convolves the original image with the kernel in the y direction to give the
* local y derivative.
*******************************************************************************/
void Compute_y_gradient(float **smoothedimage, int cols, int rows, int kwidth, float ***dy)
{
  int x,y;

  *dy = Make_float_image(cols, rows);

  for(x=(kwidth+1);x<(cols-kwidth-1);x++){
  for(y=(kwidth+1);y<(rows-kwidth-1);y++){
   (*dy)[x][y] = smoothedimage[x][y+1] - smoothedimage[x][y-1];
  }
  }
}

/*******************************************************************************
* Convolves the image with the smoothing kernel.
*******************************************************************************/
void Smooth_image(float **image, int cols, int rows, float ***smoothedimage, float sigma, int *kwidth, float gauss_tail)
{
  int width = (int)(sigma*sqrt(2*log(1/gauss_tail))+1);
  int k_size = 2*width+ 1;
  float *kernel=NULL;
  float **tmp=NULL;
  int x,y,xx,yy,i;

  Set_kernel(&kernel, sigma, width, k_size);
  *kwidth = width;

  *smoothedimage = Make_float_image(cols, rows);
  tmp = Make_float_image(cols, rows);
  
  /****************************************************************************
  * x direction
  ****************************************************************************/
  for(y=0;y<rows;y++){
  for(x=width;x<(cols-width);x++){
   for(i=0,xx=(x-width);i<k_size;i++,xx++)
    tmp[x][y] += image[xx][y]*kernel[i];
  }
  }

  /****************************************************************************
  * y direction
  ****************************************************************************/
  for(y=width;y<(rows-width);y++){
  for(x=0;x<cols;x++){
   for(i=0,yy=(y-width);i<k_size;i++,yy++)
    (*smoothedimage)[x][y] += tmp[x][yy]*kernel[i];
  }
  }

  Free_float_image(&tmp);
  free(kernel);
}


/*******************************************************************************
* Sets up the Gaussian convolution kernel.
*******************************************************************************/
void Set_kernel(float **kernel, float sigma, int width, int k_size)
{
  int i,x;
  float s2 = 2.0*sigma*sigma;
  float det = sigma*sqrt(2.0*M_PI);

  if(((*kernel) = (float *) calloc(k_size, sizeof(float))) == NULL){
  printf("Error allocating the smoothing filter array.\n");
  exit(1);
  }

  for(i=0,x=(-width);i<k_size;i++,x++) (*kernel)[i] = exp(-x*x/s2)/det;
}


/*******************************************************************************
* Returns an m*n array of ints
*******************************************************************************/
int **Make_int_image(int x, int y)
{
  int **image;
  int i;

  if((image = (int **) calloc(x, sizeof(int *))) == NULL){
  printf("Error allocating an array in Make_int_image().\n");
  exit(1);
  }
  if((image[0] = (int *) calloc(x*y, sizeof(int))) == NULL){
  printf("Error allocating an array in Make_int_image().\n");
  exit(1);
  }
  for(i=0;i<x;i++) image[i] = image[0] + (y * i);

  return(image);
}

/*******************************************************************************
* Sets an int image to val.
*******************************************************************************/
void Set_int_image(int **image, int val, int cols, int rows)
{
  int x, y;
  int *ptr = image[0];

  /* copy first col */
  for(y=0;y<rows;y++) ptr[y] = val;

  for(x=1;x<cols;x++){
  ptr = image[x];
  memcpy((char*)ptr, (char*)image[x-1], rows*sizeof(int));
  }
}

/*******************************************************************************
* Copies int image1 to image2.
*******************************************************************************/
void Copy_int_image(int **image1, int **image2, int cols, int rows)
{
  memcpy((char*)image2[0], (char*)image1[0], cols*rows*sizeof(int));
}

/*******************************************************************************
* Frees an m*n array of ints
*******************************************************************************/
void Free_int_image(int ***ptr)
{
  free((*ptr)[0]);
  free(*ptr);
  *ptr = NULL;
}

/*******************************************************************************
* Returns an m*n array of floats
*******************************************************************************/
float **Make_float_image(int x, int y)
{
  float **image;
  int i;

  if((image = (float **) calloc(x, sizeof(float *))) == NULL){
  printf("Error allocating an array in Make_float_image().\n");
  exit(1);
  }
  if((image[0] = (float *) calloc(x*y, sizeof(float))) == NULL){
  printf("Error allocating an array in Make_float_image().\n");
  exit(1);
  }
  for(i=0;i<x;i++) image[i] = image[0] + (y * i);

  return(image);
}

/*******************************************************************************
* Sets a floating point image to val.
*******************************************************************************/
void Set_float_image(float **image, float val, int cols, int rows)
{
  int x, y;
  float *ptr = image[0];

  /* copy first col */
  for(y=0;y<rows;y++) ptr[y] = val;

  for(x=1;x<cols;x++){
  ptr = image[x];
  memcpy((char*)ptr, (char*)image[x-1], rows*sizeof(float));
  }
}

/*******************************************************************************
* Copies float image1 to image2.
*******************************************************************************/
void Copy_float_image(float **image1, float **image2, int cols, int rows)
{
  memcpy((char*)image2[0], (char*)image1[0], cols*rows*sizeof(float));
}

/*******************************************************************************
* Frees an m*n array of floats
*******************************************************************************/
void Free_float_image(float ***ptr)
{
  free((*ptr)[0]);
  free(*ptr);
  *ptr = NULL;
}
