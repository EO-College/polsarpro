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

File   : prepare_tomo_display.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2014
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

Description :  Prepare a Tomo Display file

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

  char FileInput[FilePathLength], FileOutputBin[FilePathLength], FileOutputTxt[FilePathLength];
  char InputFormat[10], OutputFormat[10];

  int lig, col;
  int MinMaxBMP, Npts, ii;

  float Min, Max;
  float xx, xr, xi;

  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;

  float **databmp;

  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nprepare_tomo_display.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input binary file\n");
strcat(UsageHelp," (string)	-obf 	output binary file\n");
strcat(UsageHelp," (string)	-otf 	output text file\n");
strcat(UsageHelp," (string)	-ift 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-oft 	output data format (real, imag, mod, pha, db10, db20)\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-mm  	Min-Max determination (0,1,2,3,4)\n");
strcat(UsageHelp," (float) 	-min 	Value of the Minimum\n");
strcat(UsageHelp," (float) 	-max 	Value of the Maximum\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-obf",str_cmd_prm,FileOutputBin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-otf",str_cmd_prm,FileOutputTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ift",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mm",int_cmd_prm,&MinMaxBMP,1,UsageHelp);
  get_commandline_prm(argc,argv,"-min",flt_cmd_prm,&Min,1,UsageHelp);
  get_commandline_prm(argc,argv,"-max",flt_cmd_prm,&Max,1,UsageHelp);
  }

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileOutputBin);
  check_file(FileOutputTxt);

  if (FlagValid == 1) check_file(file_valid);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);

  if (strcmp(InputFormat, "cmplx") == 0) bufferdatacmplx = vector_float(2 * Ncol);
  if (strcmp(InputFormat, "float") == 0) bufferdatafloat = vector_float(Ncol);
  if (strcmp(InputFormat, "int") == 0) bufferdataint = vector_int(Ncol);

/*******************************************************************/
/* INPUT FILES */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);
  rewind(fileinput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    rewind(in_valid);
    }
    
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
if ((MinMaxBMP == 1)||(MinMaxBMP == 2)||(MinMaxBMP == 3)) {

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

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
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
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

/******************************************************************************/

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

free_vector_float(datatmp);
}

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

  databmp = matrix_float(Sub_Nlig,Sub_Ncol);

  if ((fileoutput = fopen(FileOutputBin, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutputBin);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/

  rewind(fileinput);
  if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
if (strcmp(InputFormat, "cmplx") == 0) my_fseek(fileinput, 1, Off_lig + Sub_Nlig, 2*Ncol*sizeof(float));
if (strcmp(InputFormat, "float") == 0) my_fseek(fileinput, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));
if (strcmp(InputFormat, "int") == 0) my_fseek(fileinput, 1, Off_lig + Sub_Nlig, Ncol*sizeof(int));
if (FlagValid == 1) my_fseek(in_valid, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  
  if (strcmp(InputFormat, "cmplx") == 0) {
    my_fseek(fileinput, -1, Ncol, 2*sizeof(float));
    fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput);
    my_fseek(fileinput, -1, Ncol, 2*sizeof(float));
    }
  if (strcmp(InputFormat, "float") == 0) {
    my_fseek(fileinput, -1, Ncol, sizeof(float));
    fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput);
    my_fseek(fileinput, -1, Ncol, sizeof(float));
    }
  if (strcmp(InputFormat, "int") == 0) {
    my_fseek(fileinput, -1, Ncol, sizeof(int));
    fread(&bufferdataint[0], sizeof(int), Ncol, fileinput);
    my_fseek(fileinput, -1, Ncol, sizeof(int));
    }
  if (FlagValid == 1) {
    my_fseek(in_valid, -1, Ncol, sizeof(float));
    fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    my_fseek(in_valid, -1, Ncol, sizeof(float));
    }
    
  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {

      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + Off_col)];
        xi = bufferdatacmplx[2 * (col + Off_col) + 1];
        xx = sqrt(xr * xr + xi * xi);
        if (strcmp(OutputFormat, "real") == 0) 
          databmp[lig][col] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          databmp[lig][col] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          databmp[lig][col] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          databmp[lig][col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          databmp[lig][col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          databmp[lig][col] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          databmp[lig][col] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          databmp[lig][col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          databmp[lig][col] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[lig][col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[lig][col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          databmp[lig][col] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          databmp[lig][col] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          databmp[lig][col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          databmp[lig][col] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[lig][col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[lig][col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          databmp[lig][col] = 0.;
        }
      } else {
      databmp[lig][col] = DATA_NULL;     
      } /* valid */
    } /* col */
  } /* lig */

  if ((MinMaxBMP == 1)||(MinMaxBMP == 2)||(MinMaxBMP == 3)) {
    for (lig = 0; lig < Sub_Nlig; lig++) {
      for (col = 0; col < Sub_Ncol; col++) {
        if (my_isfinite(databmp[lig][col]) != 0) {
          if (databmp[lig][col] > Max) databmp[lig][col] = Max;
          if (databmp[lig][col] < Min) databmp[lig][col] = Min;
          }
        }
      }
    }  
  if (MinMaxBMP == 4) {
    for (col = 0; col < Sub_Ncol; col++) {
      Min = INIT_MINMAX; Max = -Min;
      for (lig = 0; lig < Sub_Nlig; lig++) {
        if (my_isfinite(databmp[lig][col]) != 0) {
          if (databmp[lig][col] > Max) Max = databmp[lig][col];
          if (databmp[lig][col] < Min) Min = databmp[lig][col];
          }
        }
      for (lig = 0; lig < Sub_Nlig; lig++) { 
        xx = (databmp[lig][col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;
        if (xx > 1.) xx = 1.;
        databmp[lig][col] = xx;
        }
      }
    }

  for (lig = 0; lig < Sub_Nlig; lig++)     
    fwrite(&databmp[lig][0], sizeof(float), Sub_Ncol, fileoutput);
  fclose(fileoutput);

/********************************************************************
********************************************************************/
  if ((fileoutput = fopen(FileOutputTxt, "w")) == NULL)
    edit_error("Could not open input file : ", FileOutputTxt);
  fprintf(fileoutput,"%f\n",Min);
  fprintf(fileoutput,"%f\n",Max);
  fclose(fileoutput);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(databmp);

  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_float(bufferdataint);

  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/* INPUT FILE CLOSING*/
  fclose(fileinput);
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}
