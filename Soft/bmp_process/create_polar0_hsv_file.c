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

File   : create_polar0_hsv_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
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

Description :  Creation of the POLAR HSV BMP file (Tuo Tuo representation)
Hue = 3*(90-alpha)
Sat = 1. - Entropy
Val = Lambda_dB=10log(Lambda)

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

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
  FILE *HUEinput;
  FILE *SATinput;
  FILE *VALinput;
  FILE *fileoutput;
  
  char HSVDirInput[FilePathLength];
  char FileInput[FilePathLength], FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, l, Npts;
  float minval, maxval;
  float hue, sat, val, red, green, blue;
  float m1, m2, h;
  int extracol;

/* Matrix arrays */
  float *datatmp;
  char *dataimg;
  float *bufferHUE;
  float *bufferSAT;
  float *bufferVAL;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_polar0_hsv_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-of  	output HSV BMP file\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,HSVDirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_dir(HSVDirInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  extracol = (int) fmod(4 - (int) fmod(3*Sub_Ncol, 4), 4);
  //Sub_Ncol = Sub_Ncol - (int) fmod((float) Sub_Ncol, 4.);
  NcolBMP = 3*Sub_Ncol + extracol;

/* INPUT FILE OPENING */
  strcpy(FileInput, HSVDirInput);
  strcat(FileInput, "alpha.bin");
  if ((HUEinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, HSVDirInput);
  strcat(FileInput, "entropy.bin");
  if ((SATinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  strcpy(FileInput, HSVDirInput);
  strcat(FileInput, "lambda.bin");
  if ((VALinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }

/* OUTPUT FILE OPENING */
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open output file : ", FileOutput);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bufferHUE = vector_float(Ncol);
  bufferSAT = vector_float(Ncol);
  bufferVAL = vector_float(Ncol);

  ValidMask = vector_float(Ncol);

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Sub_Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING VAL CHANNEL */

rewind(VALinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferVAL[0], sizeof(float), Ncol, VALinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferVAL[0], sizeof(float), Ncol, VALinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferVAL[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minval = INIT_MINMAX; maxval = -minval;

/* DETERMINATION OF THE MIN / MAX OF THE BLUE CHANNEL */
  MinMaxContrastMedian(datatmp, &minval, &maxval, Npts);

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

  dataimg = vector_char(NcolBMP);

/* BMP HEADER */
  //write_header_bmp_24bit(Sub_Nlig, NcolBMP, fileoutput);
  write_header_bmp_24bit(Sub_Nlig, Sub_Ncol, fileoutput);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  rewind(HUEinput);
  rewind(SATinput);
  rewind(VALinput);
  if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferHUE[0], sizeof(float), Ncol, HUEinput);
    fread(&bufferSAT[0], sizeof(float), Ncol, SATinput);
    fread(&bufferVAL[0], sizeof(float), Ncol, VALinput);
    if (FlagValid == 1) fread(&datatmp[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */
     
  fseek(HUEinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  fseek(SATinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  fseek(VALinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  if (FlagValid == 1) fseek(in_valid, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);

/********************************************************************
********************************************************************/

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  
  fseek(HUEinput, -Ncol*sizeof(float), SEEK_CUR);
  fread(&bufferHUE[0], sizeof(float), Ncol, HUEinput);
  fseek(HUEinput, -Ncol*sizeof(float), SEEK_CUR);

  fseek(SATinput, -Ncol*sizeof(float), SEEK_CUR);
  fread(&bufferSAT[0], sizeof(float), Ncol, SATinput);
  fseek(SATinput, -Ncol*sizeof(float), SEEK_CUR);

  fseek(VALinput, -Ncol*sizeof(float), SEEK_CUR);
  fread(&bufferVAL[0], sizeof(float), Ncol, VALinput);
  fseek(VALinput, -Ncol*sizeof(float), SEEK_CUR);

  if (FlagValid == 1) {
    fseek(in_valid, -Ncol*sizeof(float), SEEK_CUR);
    fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    fseek(in_valid, -Ncol*sizeof(float), SEEK_CUR);
    }
    
  for (col = 0; col < Sub_Ncol; col++) {
    if (ValidMask[col+ Off_col] == 1.) {
      hue = 4 * (90. - bufferHUE[col + Off_col]) - 60.;
      if (hue > 360.) hue = hue - 360.;
      if (hue < 0.) hue = hue + 360.;
      sat = 1. - bufferSAT[col + Off_col];
      if (sat > 1.) sat = 1.;
      if (sat < 0.) sat = 0.;
      val = fabs(bufferVAL[col + Off_col]);
      if (val <= eps) val = eps;
      val = 10. * log10(val);
      if (val > maxval) val = maxval;
      if (val < minval) val = minval;
      val = (val - minval) / (maxval - minval);
      if (val > 1.) val = 1.;
      if (val < 0.) val = 0.;

      /* CONVERSION IHSL TO RGB */

      if (sat == 0.) {
        red = val;
        green = val;
        blue = val;
        } else {
        hue = hue * pi / 180.;
        h = floor(hue / (pi / 3.));
        h = hue - h * (pi / 3.);
        h = sqrt(3.) * sat / (2.*sin(-h + 2.*pi/3.));
        m1 = h*cos(hue);
        m2 = -h*sin(hue);
        red = val + 0.7875*m1 + 0.3714*m2;
        green = val - 0.2125*m1 - 0.2059*m2;
        blue = val - 0.2125*m1 + 0.9488*m2;
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
      } else {
      l = (int) (floor(255 * 0.));
      dataimg[3 * col + 0] = (char) (l);
      dataimg[3 * col + 1] = (char) (l);
      dataimg[3 * col + 2] = (char) (l);
      } /* valid */
    } /*col*/
  for (col = 0; col < extracol; col++) {
    l = (int) (floor(255 * 0.));
    dataimg[3 * Sub_Ncol + col] = (char) (l);
    } /*col*/
  fwrite(&dataimg[0], sizeof(char), NcolBMP, fileoutput);
  } /*lig*/

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(dataimg);
  free_vector_float(datatmp);
  free_vector_float(bufferHUE);
  free_vector_float(bufferSAT);
  free_vector_float(bufferVAL);
  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(HUEinput);
  fclose(SATinput);
  fclose(VALinput);

/********************************************************************
********************************************************************/

  return 1;
}


