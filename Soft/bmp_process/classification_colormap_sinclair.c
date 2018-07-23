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

File   : classification_colormap_sinclair.c
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

Description :  Creation of the BMP File of a Classification Bin File
using a COLOR CODED COLORMAP from SINCLAIR RGB

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

#define NPolType 5
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3", "C4", "T4"};

  FILE *filebmp;
  FILE *classfileinput;
  char FileOutput[FilePathLength], ClassificationFile[FilePathLength];
  
/* Internal variables */
  int lig, col, ii, k, Npts;
  float xx;
  float minred, maxred;
  float mingreen, maxgreen;
  float minblue, maxblue;

  int Nclass;
  int red[256], green[256], blue[256];
  float xr,xg,xb,xl,xt,xs,xq,xp,tk,tr,tg,tb,minx,maxx;

/* Matrix arrays */
  float *datatmp;
  char *dataimg;
  float ***M_in;

  char *bufcolor;
  float **buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nclassification_colormap_sinclair.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-if  	input classification file\n");
strcat(UsageHelp," (string)	-of  	output BMP file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,ClassificationFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_file(ClassificationFile);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  NpolarOut = 9; strcpy(PolTypeOut,"C3");
    
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    }

/* OUTPUT FILE OPENING*/
  if ((filebmp = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open output file : ", FileOutput);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;

  /* Mask */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* DataTmp = Sub_Nlig*Sub_Ncol */
  NBlockB += Sub_Nlig*Sub_Ncol;

  /* Min = NpolarOut*Nlig*Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;

  /* Buffer */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   
 
  M_in = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  Valid = matrix_float(NligBlock[0], Sub_Ncol);
  datatmp = vector_float(Sub_Nlig*Sub_Ncol);
  buffer = matrix_float(NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) { 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
    }

/********************************************************************
********************************************************************/
/* CLASSIFICATION INFORMATION */

if ((classfileinput = fopen(ClassificationFile, "rb")) == NULL)
  edit_error("Could not open input file : ", ClassificationFile);

if (FlagValid == 1) rewind(in_valid);

Nclass = -20;

rewind(classfileinput);
for (Nb = 0; Nb < NbBlock; Nb++) {
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(classfileinput, buffer, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {  
        if ((int) buffer[lig][col] > Nclass) Nclass = (int) buffer[lig][col];
        } /* valid */
      } /*col*/
    } /*lig*/
  } // NbBlock

/********************************************************************
********************************************************************/
/* CREATE THE COLOMAP FILE */

  for (k = 0; k < 256; k++) {
  red[k] = 1;
  green[k] = 1;
  blue[k] = 1;
  }
  red[0] = 125;
  green[0] = 125;
  blue[0] = 125;

/********************************************************************
********************************************************************/
/* DATA PROCESSING BLUE CHANNEL */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Npts = -1;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, "C3", 9, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if (strcmp(PolTypeIn,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    if (strcmp(PolTypeIn,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    if (strcmp(PolTypeIn,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {  
        Npts++;
        datatmp[Npts] =  fabs(M_in[C311][lig][col]);
        if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
        else Npts--;
        } /* valid */
      } /*col*/
    } /*lig*/
  
  } // NbBlock

  Npts++;
  
  minblue = INIT_MINMAX; maxblue = -minblue;

/* DETERMINATION OF THE MIN / MAX OF THE BLUE CHANNEL */
  MinMaxContrastMedian(datatmp, &minblue, &maxblue, Npts);

/*******************************************************************/

for (k = 1; k <= Nclass; k++) {
  printf("%f\r", 100. * k / Nclass);fflush(stdout);

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  rewind(classfileinput);

  Npts = -1;

  for (Nb = 0; Nb < NbBlock; Nb++) {

    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    read_block_matrix_float(classfileinput, buffer, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, "C3", 9, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

      } else {

      /* Case of C,T or I */
      read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

      if (strcmp(PolTypeIn,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeIn,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeIn,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {  
          if (k == (int) buffer[lig][col]) {
            Npts++;
            datatmp[Npts] =  fabs(M_in[C311][lig][col]);
            if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
            else Npts--;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock

  Npts++;
  xx = MedianArray(datatmp, Npts);
  if (xx > maxblue) xx = maxblue;
  if (xx < minblue) xx = minblue;
  xx = (xx - minblue) / (maxblue - minblue);
  if (xx > 1.) xx = 1.;
  if (xx < 0.) xx = 0.;
  blue[k] = (int) (floor(255 * xx));
  } /* Nclass */

/********************************************************************
********************************************************************/
/* DATA PROCESSING RED CHANNEL */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Npts = -1;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, "C3", 9, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if (strcmp(PolTypeIn,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    if (strcmp(PolTypeIn,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    if (strcmp(PolTypeIn,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {  
        Npts++;
        datatmp[Npts] =  fabs(M_in[C333][lig][col]);
        if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
        else Npts--;
        } /* valid */
      } /*col*/
    } /*lig*/
  
  } // NbBlock
  
  Npts++;

  minred = INIT_MINMAX; maxred = -minred;

/* DETERMINATION OF THE MIN / MAX OF THE RED CHANNEL */
  MinMaxContrastMedian(datatmp, &minred, &maxred, Npts);

/*******************************************************************/

for (k = 1; k <= Nclass; k++) {
  printf("%f\r", 100. * k / Nclass);fflush(stdout);

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  rewind(classfileinput);

  Npts = -1;

  for (Nb = 0; Nb < NbBlock; Nb++) {

    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    read_block_matrix_float(classfileinput, buffer, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, "C3", 9, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

      } else {

      /* Case of C,T or I */
      read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

      if (strcmp(PolTypeIn,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeIn,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeIn,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {  
          if (k == (int) buffer[lig][col]) {
            Npts++;
            datatmp[Npts] =  fabs(M_in[C333][lig][col]);
            if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
            else Npts--;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock

  Npts++;
  xx = MedianArray(datatmp, Npts);
  if (xx > maxred) xx = maxred;
  if (xx < minred) xx = minred;
  xx = (xx - minred) / (maxred - minred);
  if (xx > 1.) xx = 1.;
  if (xx < 0.) xx = 0.;
  red[k] = (int) (floor(255 * xx));
  } /* Nclass */

/********************************************************************
********************************************************************/
/* DATA PROCESSING GREEN CHANNEL */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Npts = -1;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, "C3", 9, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if (strcmp(PolTypeIn,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    if (strcmp(PolTypeIn,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    if (strcmp(PolTypeIn,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {  
        Npts++;
        datatmp[Npts] =  fabs(M_in[C322][lig][col]);
        if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
        else Npts--;
        } /* valid */
      } /*col*/
    } /*lig*/
  
  } // NbBlock
  
  Npts++;

  mingreen = INIT_MINMAX; maxgreen = -mingreen;

/* DETERMINATION OF THE MIN / MAX OF THE BLUE CHANNEL */
  MinMaxContrastMedian(datatmp, &mingreen, &maxgreen, Npts);
  
/*******************************************************************/

for (k = 1; k <= Nclass; k++) {
  printf("%f\r", 100. * k / Nclass);fflush(stdout);

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  rewind(classfileinput);

  Npts = -1;

  for (Nb = 0; Nb < NbBlock; Nb++) {

    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    read_block_matrix_float(classfileinput, buffer, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, "C3", 9, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

      } else {

      /* Case of C,T or I */
      read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

      if (strcmp(PolTypeIn,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeIn,"C4")==0) C4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeIn,"T4")==0) T4_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {  
          if (k == (int) buffer[lig][col]) {
            Npts++;
            datatmp[Npts] =  fabs(M_in[C322][lig][col]);
            if (datatmp[Npts] > eps) datatmp[Npts] = 10. * log10(datatmp[Npts]);
            else Npts--;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock

  Npts++;
  xx = MedianArray(datatmp, Npts);
  if (xx > maxgreen) xx = maxgreen;
  if (xx < mingreen) xx = mingreen;
  xx = (xx - mingreen) / (maxgreen - mingreen);
  if (xx > 1.) xx = 1.;
  if (xx < 0.) xx = 0.;
  green[k] = (int) (floor(255 * xx));
  } /* Nclass */

/*******************************************************************/
/* INTENSITY AND CONTRAST MODIFICATION */
/*******************************************************************/
//Contrast
  for (k = 1; k <= Nclass; k++) {
    xx = (float)red[k]/255;
    xx = 1.5*(xx - 0.5) + 0.5;
    if (xx > 1.) xx = 1.;
    if (xx < 0.) xx = 0.;
    red[k] = (int) (floor(255 * xx));
    xx = (float)green[k]/255;
    xx = 1.5*(xx - 0.5) + 0.5;
    if (xx > 1.) xx = 1.;
    if (xx < 0.) xx = 0.;
    green[k] = (int) (floor(255 * xx));
    xx = (float)blue[k]/255;
    xx = 1.5*(xx - 0.5) + 0.5;
    if (xx > 1.) xx = 1.;
    if (xx < 0.) xx = 0.;
    blue[k] = (int) (floor(255 * xx));
    }
  
//Intensity
//RGB->HSL
  for (k = 1; k <= Nclass; k++) {
    xr = (float)red[k]/255;
    xg = (float)green[k]/255;
    xb = (float)blue[k]/255;
    minx = xr; if (minx <= xg) minx = xg; if (minx <= xb) minx = xb; 
    maxx = xr; if (xg <= maxx) maxx = xg; if (xb <= maxx) maxx = xb; 
    if (minx == maxx) xt=0.;
    if (maxx == xr) {
      xt = 360.0 + 60.0*(xg-xb)/(maxx-minx);
      if (xt <= 0.0) xt = xt + 360.0;
      if (xt >= 360.0) xt = xt - 360.0;
      }
    if (maxx == xg) xt = 120.0 + 60.0*(xb-xr)/(maxx-minx);
    if (maxx == xb) xt = 240.0 + 60.0*(xr-xg)/(maxx-minx); 
    xl = 0.5*(maxx+minx);
    if (minx == maxx) xs = 0.0;
    if (xl <= 0.5) xs = (maxx-minx)/(maxx+minx);
    if (xl > 0.5) xs = (maxx-minx)/(2.0-(maxx+minx));
  
    xl = 0.8*xl; //Modif Lum
    if (xl > 1.0) xl = 1.0;
  
//HSL->RGB
    if (xl < 0.5) xq = xl * (1.0 + xs);
    if (0.5 <= xl) xq = xl + xs - (xl * xs);
    xp = 2.0*xl - xq;
    tk = xt / 360.;
    tr = tk + 1./3.; if (tr < 0.0) tr = tr + 1.0; if (tr > 1.0) tr = tr - 1.0;
    tg = tk; if (tg < 0.0) tg = tg + 1.0; if (tg > 1.0) tg = tg - 1.0;
    tb = tk - 1./3.; if (tb < 0.0) tb = tb + 1.0; if (tb > 1.0) tb = tb - 1.0;
  
    if (tr <= 1./6.) xr = xp + 6.*tr*(xq-xp);
    if ((1./6. < tr)&&(tr <= 1./2.)) xr = xq;
    if ((1./2. < tr)&&(tr <= 2./3.)) xr = xp + 6.*((2./3.) - tr)*(xq-xp);
    if (2./3. < tr) xr = xp;

    if (tg <= 1./6.) xg = xp + 6.*tg*(xq-xp);
    if ((1./6. < tg)&&(tg <= 1./2.)) xg = xq;
    if ((1./2. < tg)&&(tg <= 2./3.)) xg = xp + 6.*((2./3.) - tg)*(xq-xp);
    if (2./3. < tg) xg = xp;

    if (tb <= 1./6.) xb = xp + 6.*tb*(xq-xp);
    if ((1./6. < tb)&&(tb <= 1./2.)) xb = xq;
    if ((1./2. < tb)&&(tb <= 2./3.)) xb = xp + 6.*((2./3.) - tb)*(xq-xp);
    if (2./3. < tb) xb = xp;
  
    if (xr > 1.) xr = 1.;
    if (xr < 0.) xr = 0.;
    red[k] = (int) (floor(255 * xr));
    if (xg > 1.) xg = 1.;
    if (xg < 0.) xg = 0.;
    green[k] = (int) (floor(255 * xg));
    if (xb > 1.) xb = 1.;
    if (xb < 0.) xb = 0.;
    blue[k] = (int) (floor(255 * xb));
    }

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

  header(Sub_Nlig, Sub_Ncol, (float) Nclass, 1., filebmp);

  bufcolor = vector_char(1024);
  
  for (col = 0; col < 256; col++) {
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }    /*fin col */
    
  fwrite(&bufcolor[0], sizeof(char), 1024, filebmp);

  ExtraColBMP = (int) fmod(4 - (int) fmod(Sub_Ncol, 4), 4);
  NcolBMP = Sub_Ncol + ExtraColBMP;
  dataimg = vector_char(NcolBMP);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

rewind(classfileinput);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&datatmp[0], sizeof(float), Ncol, classfileinput);
    if (FlagValid == 1) fread(&datatmp[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */
  fseek(classfileinput, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);
  if (FlagValid == 1) fseek(in_valid, Sub_Nlig*Ncol*sizeof(float), SEEK_CUR);

/********************************************************************
********************************************************************/

for (Nb = 0; Nb < NbBlock; Nb++) {

  fseek(classfileinput, -NligBlock[Nb]*Ncol*sizeof(float), SEEK_CUR);
  read_block_matrix_float(classfileinput, buffer, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, Off_col, Ncol);
  fseek(classfileinput, -NligBlock[Nb]*Ncol*sizeof(float), SEEK_CUR);

  if (FlagValid == 1) {
    fseek(in_valid, -NligBlock[Nb]*Ncol*sizeof(float), SEEK_CUR);
    read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, Off_col, Ncol);
    fseek(in_valid, -NligBlock[Nb]*Ncol*sizeof(float), SEEK_CUR);
    }
    
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NligBlock[Nb] - 1 - lig][col] == 1.) {  
        IntCharBMP = (int) buffer[NligBlock[Nb] - 1 - lig][col];
        dataimg[col] = (char) IntCharBMP;
        } else {
        IntCharBMP = 0;
        dataimg[col] = (char) IntCharBMP;
        } /* valid */
      } /*col*/
    for (col = 0; col < ExtraColBMP; col++) {
      IntCharBMP = 0;
      dataimg[Sub_Ncol + col] = (char) IntCharBMP;
      }
    fwrite(&dataimg[0], sizeof(char), NcolBMP, filebmp);
    } /*lig*/
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(dataimg);
  free_vector_char(bufcolor);
  free_vector_int(PointClass);
  free_vector_float(datatmp);
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0]);
  free_matrix_float(buffer, NligBlock[0]);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  fclose(classfileinput);
  
/********************************************************************
********************************************************************/

  return 1;
}


