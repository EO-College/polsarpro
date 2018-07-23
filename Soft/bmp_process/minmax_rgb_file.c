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

File   : minmax_rgb_file.c
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

Description :  Determination of the Min and Max values to be coded

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
  FILE *filebmp;
  FILE *bluefileinput;
  FILE *greenfileinput;
  FILE *redfileinput;
  char BlueFileInput[FilePathLength], GreenFileInput[FilePathLength];
  char RedFileInput[FilePathLength], FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, Npts;
  float minred, maxred;
  float mingreen, maxgreen;
  float minblue, maxblue;

/* Matrix arrays */
  float *datatmp;
  float *bufferdatablue;
  float *bufferdatagreen;
  float *bufferdatared;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nminmax_rgb_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifb 	input binary file: blue channel\n");
strcat(UsageHelp," (string)	-ifr 	input binary file: red channel\n");
strcat(UsageHelp," (string)	-ifg 	input binary file: green channel\n");
strcat(UsageHelp," (string)	-of  	output file\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifb",str_cmd_prm,BlueFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifr",str_cmd_prm,RedFileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifg",str_cmd_prm,GreenFileInput,1,UsageHelp);
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

  check_file(BlueFileInput);
  check_file(GreenFileInput);
  check_file(RedFileInput);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  //Sub_Ncol = Sub_Ncol - (int) fmod((float) Sub_Ncol, 4.);
  NcolBMP = Sub_Ncol;

/* INPUT FILE OPENING */
  if ((bluefileinput = fopen(BlueFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", BlueFileInput);
  if ((redfileinput = fopen(RedFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", RedFileInput);
  if ((greenfileinput = fopen(GreenFileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", GreenFileInput);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }

/* OUTPUT FILE OPENING */
  if ((filebmp = fopen(FileOutput, "w")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutput);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bufferdatablue = vector_float(Ncol);
  bufferdatagreen = vector_float(Ncol);
  bufferdatared = vector_float(Ncol);

  ValidMask = vector_float(Ncol);

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Sub_Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING BLUE CHANNEL */

rewind(bluefileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatablue[0], sizeof(float), Ncol, bluefileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatablue[0], sizeof(float), Ncol, bluefileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatablue[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minblue = INIT_MINMAX; maxblue = -minblue;

/* DETERMINATION OF THE MIN / MAX OF THE BLUE CHANNEL */
  MinMaxContrastMedian(datatmp, &minblue, &maxblue, Npts);

/********************************************************************
********************************************************************/
/* DATA PROCESSING RED CHANNEL */

rewind(redfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatared[0], sizeof(float), Ncol, redfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatared[0], sizeof(float), Ncol, redfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatared[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minred = INIT_MINMAX; maxred = -minred;

/* DETERMINATION OF THE MIN / MAX OF THE RED CHANNEL */
  MinMaxContrastMedian(datatmp, &minred, &maxred, Npts);

/********************************************************************
********************************************************************/
/* DATA PROCESSING GREEN CHANNEL */

rewind(greenfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatagreen[0], sizeof(float), Ncol, greenfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatagreen[0], sizeof(float), Ncol, greenfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatagreen[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  mingreen = INIT_MINMAX; maxgreen = -mingreen;

/* DETERMINATION OF THE MIN / MAX OF THE GREEN CHANNEL */
  MinMaxContrastMedian(datatmp, &mingreen, &maxgreen, Npts);

/*******************************************************************/
/* OUTPUT FILE */
/*******************************************************************/

  fprintf(filebmp, "%f\n", minblue);
  fprintf(filebmp, "%f\n", maxblue);
  fprintf(filebmp, "%f\n", minred);
  fprintf(filebmp, "%f\n", maxred);
  fprintf(filebmp, "%f\n", mingreen);
  fprintf(filebmp, "%f\n", maxgreen);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(datatmp);
  free_vector_float(bufferdatablue);
  free_vector_float(bufferdatared);
  free_vector_float(bufferdatagreen);
  free_vector_float(ValidMask);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(bluefileinput);
  fclose(redfileinput);
  fclose(greenfileinput);

/********************************************************************
********************************************************************/

  return 1;
}


