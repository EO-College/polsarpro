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

File   : texture_statistics.c
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

Description :  Calculates the texture statistics of a binary data file

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

/* GLOBAL VARIABLES */
  float *datatmp;

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
  char TextStat[20];

/* Internal variables */
  int lig, col, i, j, k, l, Npts;
  int direction, Ncolor;

  float Npt, mean;
  float Min, Max;
  float xr, xi, xx;

/* Matrix arrays */
  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;
  float **datagray;
  float *data_out;
  float *ValidMask;
  float **Pij;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntexture_statistics.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-ta  	texture analysis (mean, homogeneity, contrast, dissimilarity, entropy, uniformity)\n");
strcat(UsageHelp," (string)	-idf 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-odf 	output data format (real, imag, mod, mod2, db, pha)\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-dir 	direction (0, 45, 90, 135)\n");
strcat(UsageHelp," (int)   	-col 	number of colors\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 29) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ta",str_cmd_prm,TextStat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dir",int_cmd_prm,&direction,1,UsageHelp);
  get_commandline_prm(argc,argv,"-col",int_cmd_prm,&Ncolor,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT FILE OPENING*/
  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);

  if (strcmp(InputFormat, "cmplx") == 0) bufferdatacmplx = vector_float(2 * Ncol);
  if (strcmp(InputFormat, "float") == 0) bufferdatafloat = vector_float(Ncol);
  if (strcmp(InputFormat, "int") == 0) bufferdataint = vector_int(Ncol);
  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

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
  MinMaxContrastMedian(datatmp, &Min, &Max, Npts);

/*******************************************************************/

  //if (strcmp(InputFormat,"cmplx")==0) free_vector_float(bufferdatacmplx);
  //if (strcmp(InputFormat,"float")==0) free_vector_float(bufferdatafloat);
  //if (strcmp(InputFormat,"int")==0) free_vector_int(bufferdataint);

  free_vector_float(datatmp);
  datagray = matrix_float(Sub_Nlig + NwinL, Sub_Ncol + NwinC);
  data_out = vector_float(Sub_Ncol);
  Pij = matrix_float(Ncolor +1, Ncolor +1);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/

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
          datagray[lig+NwinLM1S2][col+NwinCM1S2] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datagray[lig+NwinLM1S2][col+NwinCM1S2] = 0.;
        }

      xx = (datagray[lig+NwinLM1S2][col+NwinCM1S2] - Min) / (Max - Min);
      if (xx < 0.) xx = 0.;
      if (xx > 1.) xx = 1.;
      datagray[lig+NwinLM1S2][col+NwinCM1S2] = 1 + floor((Ncolor - 1) * xx);
      } else {
      datagray[lig+NwinLM1S2][col+NwinCM1S2] = 0.;     
      } /* valid */
    } /* col */
  } /* lig */

/*******************************************************************/
/*******************************************************************/

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  for (col = 0; col < Sub_Ncol; col++) {
  /* GLCM statistics */
    if (col == 0) {
      for (i = 1; i <= Ncolor; i++)
        for (j = 1; j <= Ncolor; j++) {
          Pij[i][j] = 0.;
          }
      }

    if (direction == 0) {
      if (col == 0) {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 + NwinCM1S2 - 1; l++) {
            i = (int)datagray[NwinLM1S2 + lig + k][NwinCM1S2+ col + l];
            j = (int)datagray[NwinLM1S2 + lig + k][NwinCM1S2 + col + l + 1];
            Pij[i][j] = Pij[i][j] + 1.;
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          i = (int)datagray[NwinLM1S2 + lig + k][col-1];
          j = (int)datagray[NwinLM1S2 + lig + k][col];
          Pij[i][j] = Pij[i][j] - 1.;
          i = (int)datagray[NwinLM1S2 + lig + k][NwinC-1+col];
          j = (int)datagray[NwinLM1S2 + lig + k][NwinC+col];
          Pij[i][j] = Pij[i][j] + 1.;
          }
        }
      }
    if (direction == 90) {
      if (col == 0) {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2 - 1; k++)
          for (l = -NwinCM1S2; l < 1 + NwinCM1S2; l++) {
            i = (int)datagray[NwinLM1S2 + lig + k][NwinCM1S2 + col + l];
            j = (int)datagray[NwinLM1S2 + lig + k + 1][NwinCM1S2 + col + l];
            Pij[i][j] = Pij[i][j] + 1.;
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2 - 1; k++) {
          i = (int)datagray[NwinLM1S2 + lig + k][col-1];
          j = (int)datagray[NwinLM1S2 + lig + k + 1][col-1];
          Pij[i][j] = Pij[i][j] - 1.;
          i = (int)datagray[NwinLM1S2 + lig + k][NwinC-1+col];
          j = (int)datagray[NwinLM1S2 + lig + k + 1][NwinC-1+col];
          Pij[i][j] = Pij[i][j] + 1.;
          }
        }
      }
    if (direction == 45) {
      if (col == 0) {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2 - 1; k++)
          for (l = -NwinCM1S2; l < 1 + NwinCM1S2 - 1; l++) {
            i = (int)datagray[NwinLM1S2 + lig + k][NwinCM1S2 + col + l];
            j = (int)datagray[NwinLM1S2 + lig + k + 1][NwinCM1S2 + col + l + 1];
            Pij[i][j] = Pij[i][j] + 1.;
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2 - 1; k++) {
          i = (int)datagray[NwinLM1S2 + lig + k][col-1];
          j = (int)datagray[NwinLM1S2 + lig + k + 1][col];
          Pij[i][j] = Pij[i][j] - 1.;
          i = (int)datagray[NwinLM1S2 + lig + k][NwinC-1+col];
          j = (int)datagray[NwinLM1S2 + lig + k + 1][NwinC+col];
          Pij[i][j] = Pij[i][j] + 1.;
          }
        }
      }
    if (direction == 135) {
      if (col == 0) {
        for (k = -NwinLM1S2 +1; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 + NwinCM1S2 - 1; l++) {
            i = (int)datagray[NwinLM1S2 + lig + k][NwinCM1S2 + col + l];
            j = (int)datagray[NwinLM1S2 + lig + k - 1][NwinCM1S2 + col + l + 1];
            Pij[i][j] = Pij[i][j] + 1.;
            }
        } else {
        for (k = -NwinLM1S2 +1; k < 1 + NwinLM1S2; k++) {
          i = (int)datagray[NwinLM1S2 + lig + k][col-1];
          j = (int)datagray[NwinLM1S2 + lig + k - 1][col];
          Pij[i][j] = Pij[i][j] - 1.;
          i = (int)datagray[NwinLM1S2 + lig + k][NwinC-1+col];
          j = (int)datagray[NwinLM1S2 + lig + k - 1][NwinC+col];
          Pij[i][j] = Pij[i][j] + 1.;
          }
        }
      }

    //Npt = 0.;
    //for (i = 1; i <= Ncolor; i++) for (j = 1; j <= Ncolor; j++) Npt += Pij[i][j];
    //for (i = 1; i <= Ncolor; i++) for (j = 1; j <= Ncolor; j++) Pij[i][j] = Pij[i][j] / Npt;

    if (strcmp(TextStat,"homogeneity") == 0) {
      mean = 0.; Npt = 0.;
      for (i = 1; i <= Ncolor; i++) 
        for (j = 1; j <= Ncolor; j++) {
          if (Pij[i][j] != 0.) {
            Npt += Pij[i][j];
            mean += (i-j)*(i-j)*Pij[i][j];
            }
          }
      data_out[col] = mean / Npt;
      }
    if (strcmp(TextStat,"contrast") == 0) {
      mean = 0.; Npt = 0.;
      for (i = 1; i <= Ncolor; i++) 
        for (j = 1; j <= Ncolor; j++) {
          if (Pij[i][j] != 0.) {
            Npt += Pij[i][j];
            mean += Pij[i][j] / (1 + (i-j)*(i-j));
            }
          }
      data_out[col] = mean/Npt;
      }
    if (strcmp(TextStat,"dissimilarity") == 0) {
      mean = 0.; Npt = 0.;
      for (i = 1; i <= Ncolor; i++) 
        for (j = 1; j <= Ncolor; j++) {
          if (Pij[i][j] != 0.) {
            Npt += Pij[i][j];
            mean += fabs(i-j)*Pij[i][j];
            }
          }
      data_out[col] = mean/Npt;
      }
    if (strcmp(TextStat,"entropy") == 0) {
      mean = 0.; Npt = 0.;
      for (i = 1; i <= Ncolor; i++) 
        for (j = 1; j <= Ncolor; j++) {
          if (Pij[i][j] > 0.) {
            Npt += Pij[i][j];
            mean += -Pij[i][j] * log(Pij[i][j] + eps);
            }
          }
      data_out[col] = (mean/Npt) + log(Npt);
      }
    if (strcmp(TextStat,"uniformity") == 0) {
      mean = 0.; Npt = 0.;
      for (i = 1; i <= Ncolor; i++) 
        for (j = 1; j <= Ncolor; j++) {
          if (Pij[i][j] != 0.) {
            Npt += Pij[i][j];
            mean += Pij[i][j]*Pij[i][j];
            }
          }
      data_out[col] = mean/(Npt*Npt);
      }
    if (strcmp(TextStat,"mean") == 0) {
      mean = 0.; Npt = 0.;
      for (i = 1; i <= Ncolor; i++) 
        for (j = 1; j <= Ncolor; j++) {
          if (Pij[i][j] != 0.) {
            Npt += Pij[i][j];
            mean += i*j*Pij[i][j];
            }
          }
      data_out[col] = mean/Npt;
      }
    }

/* DATA WRITING */
    fwrite(&data_out[0], sizeof(float), Sub_Ncol, fileoutput);
  } /* lig */

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(ValidMask);
  free_matrix_float(datagray, Sub_Nlig + NwinL);
  free_vector_float(dataout);
  free_matrix_float(Pij,Ncolor +1);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
   fclose(fileoutput);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(fileinput);

/********************************************************************
********************************************************************/

  return 1;
}


