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

File   : minmax_hsv_cce_file.c
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
  FILE *huefileinput;
  FILE *satfileinput;
  FILE *valfileinput;
  char HueFileInput[FilePathLength], SatFileInput[FilePathLength];
  char ValFileInput[FilePathLength], FileOutput[FilePathLength];
  
/* Internal variables */
  int lig, col, Npts;
  float minmin, maxmax;
  float minval, maxval;
  float minsat, maxsat;
  float minhue, maxhue;

/* Matrix arrays */
  float *datatmp;
  float *bufferdatahue;
  float *bufferdatasat;
  float *bufferdataval;
  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nminmax_hsv_cce_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input binary file: hue channel\n");
strcat(UsageHelp," (string)	-ifv 	input binary file: val channel\n");
strcat(UsageHelp," (string)	-ifs 	input binary file: sat channel\n");
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

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

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

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Sub_Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING HUE CHANNEL */

rewind(huefileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatahue[0], sizeof(float), Ncol, huefileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatahue[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minhue = INIT_MINMAX; maxhue = -minhue;

/* DETERMINATION OF THE MIN / MAX OF THE HUE CHANNEL */
  MinMaxContrastMedian(datatmp, &minhue, &maxhue, Npts);

/********************************************************************
********************************************************************/
/* DATA PROCESSING VAL CHANNEL */

rewind(valfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdataval[0], sizeof(float), Ncol, valfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdataval[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minval = INIT_MINMAX; maxval = -minval;

/* DETERMINATION OF THE MIN / MAX OF THE VAL CHANNEL */
  MinMaxContrastMedian(datatmp, &minval, &maxval, Npts);

/********************************************************************
********************************************************************/
/* DATA PROCESSING SAT CHANNEL */

rewind(satfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

  Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bufferdatasat[0], sizeof(float), Ncol, satfileinput);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {
      Npts++;
      datatmp[Npts] = fabs(bufferdatasat[col + Off_col]);
      if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
      else Npts--;
      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

  minsat = INIT_MINMAX; maxsat = -minsat;

/* DETERMINATION OF THE MIN / MAX OF THE SAT CHANNEL */
  MinMaxContrastMedian(datatmp, &minsat, &maxsat, Npts);

/*******************************************************************/
/* OUTPUT FILE */
/*******************************************************************/
  minmin = INIT_MINMAX; maxmax = -minmin;

  if (minhue <= minmin) minmin = minhue;
  if (minval <= minmin) minmin = minval;
  if (minsat <= minmin) minmin = minsat;
  if (maxhue <= minmin) minmin = maxhue;
  if (maxval <= minmin) minmin = maxval;
  if (maxsat <= minmin) minmin = maxsat;
  
  if (maxmax <= minhue) maxmax = minhue;
  if (maxmax <= minval) maxmax = minval;
  if (maxmax <= minsat) maxmax = minsat;
  if (maxmax <= maxhue) maxmax = maxhue;
  if (maxmax <= maxval) maxmax = maxval;
  if (maxmax <= maxsat) maxmax = maxsat;

  minhue = minmin; minval = minmin; minsat = minmin;
  maxhue = maxmax; maxval = maxmax; maxsat = maxmax;

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


