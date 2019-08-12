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

File   : create_polar2_hsv_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 07/2011
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

Description :  Creation of the POLAR HSV BMP file (Tuo Tuo representation)
Hue = 3*(90-alpha)
Sat = 1. - Entropy
Val = Anisotropy

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
  int lig, col, l;
  float hue, sat, val, red, green, blue;
  float m1, m2, h;

/* Matrix arrays */
  char *dataimg;
  float *bufferHUE;
  float *bufferSAT;
  float *bufferVAL;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_polar2_hsv_file.exe\n");
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

  check_dir(HSVDirInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  ExtraColBMP = (int) fmod(4 - (int) fmod(3*Sub_Ncol, 4), 4);
  NcolBMP = 3*Sub_Ncol + ExtraColBMP;
  ExtraColBMP = (int) fmod(4 - (int) fmod(Sub_Ncol, 4), 4);
  Sub_NcolBMP = Sub_Ncol + ExtraColBMP;

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
  strcat(FileInput, "anisotropy.bin");
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

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Sub_Ncol; col++) ValidMask[col] = 1.;

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

/* BMP HDR FILE */
  write_bmp_hdr(Sub_Nlig, Sub_Ncol, 0., 0., 24, FileOutput);

  dataimg = vector_char(NcolBMP);

/* BMP HEADER */
  write_header_bmp_24bit(Sub_Nlig, Sub_Ncol, fileoutput);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  rewind(HUEinput);
  rewind(SATinput);
  rewind(VALinput);
  if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  my_fseek(HUEinput, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));    
  my_fseek(SATinput, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));    
  my_fseek(VALinput, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));    
  if (FlagValid == 1) my_fseek(in_valid, 1, Off_lig + Sub_Nlig, Ncol*sizeof(float));

/********************************************************************
********************************************************************/

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  
  my_fseek(HUEinput, -1, Ncol, sizeof(float));
  fread(&bufferHUE[0], sizeof(float), Ncol, HUEinput);
  my_fseek(HUEinput, -1, Ncol, sizeof(float));

  my_fseek(SATinput, -1, Ncol, sizeof(float));
  fread(&bufferSAT[0], sizeof(float), Ncol, SATinput);
  my_fseek(SATinput, -1, Ncol, sizeof(float));

  my_fseek(VALinput, -1, Ncol, sizeof(float));
  fread(&bufferVAL[0], sizeof(float), Ncol, VALinput);
  my_fseek(VALinput, -1, Ncol, sizeof(float));

  if (FlagValid == 1) {
    my_fseek(in_valid, -1, Ncol, sizeof(float));
    fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    my_fseek(in_valid, -1, Ncol, sizeof(float));
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
      if (val > 1.) val = 1.;
      if (val < 0.) val = 0.;

      /* CONVERSION HSL TO RGB */
      if (val <= 0.5)
        m2 = val * (1. + sat);
      else
        m2 = val + sat - val * sat;
  
      m1 = 2 * val - m2;

      if (sat == 0.) {
        red = val;
        green = val;
        blue = val;
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
      } else {
      dataimg[3 * col + 0] = (char) (0);
      dataimg[3 * col + 1] = (char) (1);
      dataimg[3 * col + 2] = (char) (0);
      } /* valid */
    } /*col*/
  for (col = 0; col < ExtraColBMP; col++) {
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


