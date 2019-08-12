/********************************************************************
PolSARpro v5.0 is free software; you can valistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : minmax_hsv_file.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 04/2016
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

Description :  Determination of the Min and Max values to be coded

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

/* GLOBAL VARIABLES */
  float *datatmpHSV;

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
  FILE *filebmp;
  FILE *huefileinput;
  FILE *satfileinput;
  FILE *valfileinput;
  char HueFileInput[FilePathLength], SatFileInput[FilePathLength];
  char ValFileInput[FilePathLength], FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col;
  int NptsHSV;
  float minval, maxval;
  float minsat, maxsat;
  float minhue, maxhue;

/* Matrix arrays */
  float *bufferdatahue;
  float *bufferdatasat;
  float *bufferdataval;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nminmax_hsv_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input binary file: hue channel\n");
strcat(UsageHelp," (string)	-ifv 	input binary file: val channel\n");
strcat(UsageHelp," (string)	-ifs 	input binary file: sat channel\n");
strcat(UsageHelp," (string)	-of  	output RGB BMP file\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,HueFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifv",str_cmd_prm,ValFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifs",str_cmd_prm,SatFileInput,1,UsageHelp);
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

  check_file(HueFileInput);
  check_file(SatFileInput);
  check_file(ValFileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  Sub_Ncol = Sub_Ncol - (int) fmod((float) Sub_Ncol, 4.);
  NcolBMP = Sub_Ncol;

/* INPUT FILE OPENING */
  if ((huefileinput = fopen(HueFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", HueFileInput);
  if ((valfileinput = fopen(ValFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", ValFileInput);
  if ((satfileinput = fopen(SatFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", SatFileInput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }
 
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bufferdatahue = vector_float(Ncol);
  bufferdatasat = vector_float(Ncol);
  bufferdataval = vector_float(Ncol);

  ValidMask = vector_float(Ncol);

  datatmpHSV = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Sub_Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING HUE CHANNELS */
rewind(huefileinput);
rewind(satfileinput);
rewind(valfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  NptsHSV = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {
    if (ValidMask[col+ Off_col] == 1.) {
      NptsHSV++;
      datatmpHSV[NptsHSV] = fabs(bufferdatahue[col + Off_col]);
      if (datatmpHSV[NptsHSV] > eps) datatmpHSV[NptsHSV] = 10. * log10(datatmpHSV[NptsHSV]);
      else NptsHSV--;
      } /* valid */
    } /* col */
  } /* lig */

  NptsHSV++;
  minhue = INIT_MINMAX; maxhue = -minhue;
  MinMaxContrastMedian(datatmpHSV, &minhue, &maxhue, NptsHSV);

/* DATA PROCESSING SAT CHANNELS */
rewind(huefileinput);
rewind(satfileinput);
rewind(valfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  NptsHSV = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {
    if (ValidMask[col+ Off_col] == 1.) {
      NptsHSV++;
      datatmpHSV[NptsHSV] = fabs(bufferdatasat[col + Off_col]);
      if (datatmpHSV[NptsHSV] > eps) datatmpHSV[NptsHSV] = 10. * log10(datatmpHSV[NptsHSV]);
      else NptsHSV--;
      } /* valid */
    } /* col */
  } /* lig */

  NptsHSV++;
  minsat = INIT_MINMAX; maxsat = -minsat;
  MinMaxContrastMedian(datatmpHSV, &minsat, &maxsat, NptsHSV);

/* DATA PROCESSING VAL CHANNELS */
rewind(huefileinput);
rewind(satfileinput);
rewind(valfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  NptsHSV = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {
    if (ValidMask[col+ Off_col] == 1.) {
      NptsHSV++;
      datatmpHSV[NptsHSV] = fabs(bufferdataval[col + Off_col]);
      if (datatmpHSV[NptsHSV] > eps) datatmpHSV[NptsHSV] = 10. * log10(datatmpHSV[NptsHSV]);
      else NptsHSV--;
      } /* valid */
    } /* col */
  } /* lig */

  NptsHSV++;
  minval = INIT_MINMAX; maxval = -minval;
  MinMaxContrastMedian(datatmpHSV, &minval, &maxval, NptsHSV);

/*******************************************************************/
/* OUTPUT FILE */
/*******************************************************************/

  if ((filebmp = fopen(FileOutput, "w")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutput);

  fprintf(filebmp, "%f\n", minhue);
  fprintf(filebmp, "%f\n", maxhue);
  fprintf(filebmp, "%f\n", minval);
  fprintf(filebmp, "%f\n", maxval);
  fprintf(filebmp, "%f\n", minsat);
  fprintf(filebmp, "%f\n", maxsat);
  
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(datatmp);
  free_vector_float(bufferdatahue);
  free_vector_float(bufferdataval);
  free_vector_float(bufferdatasat);
  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(huefileinput);
  fclose(valfileinput);
  fclose(satfileinput);

/********************************************************************
********************************************************************/

  return 1;
}


