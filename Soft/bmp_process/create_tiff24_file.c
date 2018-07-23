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

File   : create_tiff24_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team 
(SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Creation of a 24-bits TIFF file from a binary file
The input format of the binary file can be: cmplx,float,int
The output format of the BMP file represents one of the following
function: Real part, Imaginary part, Modulus, Decibel or
Phase of the input data
The colormap can be gray, jet or hsv
The Min/Max automatic procedure calculates automatically the
minimum and maximum range of the data to be color coded

Input  : Binary file
Output : TIFF file

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

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
  FILE *fileinput, *filebmp;

  char FileInput[FilePathLength], FileOutput[FilePathLength];
  char InputFormat[10], OutputFormat[10];
  char ColorMap[20];

  int lig, col, l;
  int MinMaxBMP, Npts, ii;
  int MapGray;

  float Min, Max;
  float xx, xr, xi;
  float hue, red, green, blue;
  float m1, m2, h;

  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;

  float *databmp;
  char *dataimg;

  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_tiff24_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	binary input file\n");
strcat(UsageHelp," (string)	-of  	output TIFF file\n");
strcat(UsageHelp," (string)	-ift 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-oft 	output data format (real, imag, mod, pha, db10, db20)\n");
strcat(UsageHelp," (string)	-clm 	ColorMap (gray, grayrev, jet, jetinv, jetrev, hsv, hsvinv, hsvrev)\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-mm  	Min-Max determination (0,1,2,3)\n");
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
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ift",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-clm",str_cmd_prm,ColorMap,1,UsageHelp); 
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
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  //Sub_Ncol = Sub_Ncol - (int) fmod((float) Sub_Ncol, 4.);
  NcolBMP = Sub_Ncol;

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);

  if (strcmp(InputFormat, "cmplx") == 0) bufferdatacmplx = vector_float(2 * Ncol);
  if (strcmp(InputFormat, "float") == 0) bufferdatafloat = vector_float(Ncol);
  if (strcmp(InputFormat, "int") == 0) bufferdataint = vector_int(Ncol);
  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

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

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

  databmp = vector_float(Sub_Ncol);

  dataimg = vector_char(3*NcolBMP);

  if ((filebmp = fopen(FileOutput, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutput);

/* TIFF HEADER */
  headerTiff(Sub_Nlig, NcolBMP, filebmp);
  
/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/

  rewind(fileinput);
  if (FlagValid == 1) rewind(in_valid);
  MapGray = 0;

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

  if (strcmp(InputFormat, "cmplx") == 0)
    fseek(fileinput, Sub_Nlig*Ncol*2*sizeof(float), SEEK_CUR);
  if (strcmp(InputFormat, "float") == 0)
    fseek(fileinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  if (strcmp(InputFormat, "int") == 0)
    fseek(fileinput, Sub_Nlig*Ncol*sizeof(int), SEEK_CUR);
  if (FlagValid == 1) fseek(in_valid, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  
  if (strcmp(InputFormat, "cmplx") == 0) {
    fseek(fileinput, -Ncol*2*sizeof(float), SEEK_CUR);
    fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fileinput);
    fseek(fileinput, -Ncol*2*sizeof(float), SEEK_CUR);
    }
  if (strcmp(InputFormat, "float") == 0) {
    fseek(fileinput, -Ncol*sizeof(float), SEEK_CUR);
    fread(&bufferdatafloat[0], sizeof(float), Ncol, fileinput);
    fseek(fileinput, -Ncol*sizeof(float), SEEK_CUR);
    }
  if (strcmp(InputFormat, "int") == 0) {
    fseek(fileinput, -Ncol*sizeof(int), SEEK_CUR);
    fread(&bufferdataint[0], sizeof(int), Ncol, fileinput);
    fseek(fileinput, -Ncol*sizeof(int), SEEK_CUR);
    }
  if (FlagValid == 1) {
    fseek(in_valid, -Ncol*sizeof(float), SEEK_CUR);
    fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    fseek(in_valid, -Ncol*sizeof(float), SEEK_CUR);
    }
    
  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {

      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + Off_col)];
        xi = bufferdatacmplx[2 * (col + Off_col) + 1];
        xx = sqrt(xr * xr + xi * xi);
        if (strcmp(OutputFormat, "real") == 0) 
          databmp[col] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          databmp[col] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          databmp[col] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          databmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          databmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          databmp[col] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          databmp[col] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          databmp[col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          databmp[col] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          databmp[col] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          databmp[col] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          databmp[col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          databmp[col] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          databmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          databmp[col] = 0.;
        }

      if ((strcmp(ColorMap, "gray") == 0)||(strcmp(ColorMap, "grayrev") == 0)) {
        MapGray = 1;
        xx = (databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;
        if (xx > 1.) xx = 1.;
        databmp[col] = 1. + 254. * xx;
        }

      if (strcmp(ColorMap, "jet") == 0) {
        xx = 270.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;
        if (xx > 270.) xx = 270.;
        databmp[col] = 270. - xx;
        }
    
      if (strcmp(ColorMap, "jetrev") == 0) {
        xx = 270.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;
        if (xx > 270.) xx = 270.;
        databmp[col] = xx;
        }

      if (strcmp(ColorMap, "jetinv") == 0) {
        xx = 270.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;
        if (xx > 270.) xx = 270.;
        if (xx < 60.) databmp[col] = 60. - xx;
        else databmp[col] = 420. - xx;
        }

      if (strcmp(ColorMap, "jetrevinv") == 0) {
        xx = 270.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;if (xx > 270.) xx = 270.;
        if (xx < 180.) databmp[col] = 180. + xx;
        else databmp[col] = xx - 180.;
        }

      if (strcmp(ColorMap, "hsv") == 0) {
        xx = 360.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;if (xx > 360.) xx = 360.;
        databmp[col] = xx;
        }
    
      if (strcmp(ColorMap, "hsvrev") == 0) {
        xx = 360.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;if (xx > 360.) xx = 360.;
        databmp[col] = 360. - xx;
        }
    
      if (strcmp(ColorMap, "hsvinv") == 0) {
        xx = 360.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;if (xx > 360.) xx = 360.;
        if (xx < 180.) databmp[col] = 180. + xx;
        else databmp[col] = xx - 180.;
        }
    
      if (strcmp(ColorMap, "hsvrevinv") == 0) {
        xx = 360.*(databmp[col] - Min) / (Max - Min);
        if (xx < 0.) xx = 0.;if (xx > 360.) xx = 360.;
        if (xx < 180.) databmp[col] = 180. - xx;
        else databmp[col] = (360. - xx) + 180.;
        }

      } else {
      databmp[col] = 0.;     
      } /* valid */
    } /* col */
    
/* CONVERSION HSV TO RGB with V=0.5 ans S=1 */
  m2 = 1.;
  m1 = 0.;
  for (col = 0; col < Sub_Ncol; col++) {
    hue = databmp[col];

    if (MapGray == 1) {
      red = hue/360.;
      green = hue/360.;
      blue = hue/360.;
      } else {
      h = hue + 120;
      if (h > 360.) h = h - 360.;
      else if (h < 0.) h = h + 360.;
      if (h < 60.) red = m1 + (m2 - m1) * h / 60.;
      else if (h < 180.) red = m2;
      else if (h < 240.) red = m1 + (m2 - m1) * (240. - h) / 60.;
      else red = m1;

      h = hue;
      if (h > 360.) h = h - 360.;
      else if (h < 0.) h = h + 360.;
      if (h < 60.) green = m1 + (m2 - m1) * h / 60.;
      else if (h < 180.) green = m2;
      else if (h < 240.) green = m1 + (m2 - m1) * (240. - h) / 60.;
      else green = m1;

      h = hue - 120;
      if (h > 360.) h = h - 360.;
      else if (h < 0.) h = h + 360.;
      if (h < 60.) blue = m1 + (m2 - m1) * h / 60.;
      else if (h < 180.) blue = m2;
      else if (h < 240.) blue = m1 + (m2 - m1) * (240. - h) / 60.;
      else blue = m1;
      }
 
    if (blue > 1.) blue = 1.;
    if (blue < 0.) blue = 0.;
    l = (int) (floor(255 * blue));
    dataimg[3 * col + 0] = (char) (l);
    if (green > 1.) green = 1.;
    if (green < 0.) green = 0.;
    l = (int) (floor(255 * green));
    dataimg[3 * col + 1] = (char) (l);
    if (red > 1.) red = 1.;
    if (red < 0.) red = 0.;
    l = (int) (floor(255 * red));
    dataimg[3 * col + 2] = (char) (l);
    }

  fwrite(&dataimg[0], sizeof(char), 3 * NcolBMP, filebmp);  
  } /* lig */

/********************************************************************
********************************************************************/

/* TIFF FOOTER */

  footerTiff(Sub_Nlig, NcolBMP, filebmp);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(databmp);
  free_vector_char(dataimg);

  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_int(bufferdataint);

  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  fclose(fileinput);
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}
