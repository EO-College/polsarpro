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

File   : minmax_pauli_rgb_file_SPPIPPC2.c
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
  float *datatmpRGB;
  
/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 3
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = { "SPP", "C2", "IPP"};

  FILE *filebmp;
  char FileOutput[FilePathLength];
  char RGBFormat[10];
  
/* Internal variables */
  int lig, col, ii;
  int NptsRGB;
  float minred, maxred;
  float mingreen, maxgreen;
  float minblue, maxblue;

/* Matrix arrays */
  float ***S_in;
  float ***M_in;

  float *ValidMask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nminmax_pauli_rgb_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-rgbf	RGB format : RGB1, RGB2, RGB3 or RGB4\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
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

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rgbf",str_cmd_prm,RGBFormat,1,UsageHelp);

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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;

  //Sub_Ncol = Sub_Ncol - (int) fmod((float) Sub_Ncol, 4.);
  NcolBMP = Sub_Ncol;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP") == 0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
    
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
  if ((filebmp = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open output file : ", FileOutput);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   
 
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    S_in = matrix3d_float(NpolarIn, 1, 2*Ncol);
    }
  M_in = matrix3d_float(NpolarOut, 1, Ncol);
  ValidMask = vector_float(Ncol);
  datatmpRGB = vector_float(Sub_Nlig*Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0)  
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING RED CHANNEL */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

NptsRGB = -1;

/* OFFSET READING */
for (lig = 0; lig < Off_lig; lig++) {
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++)
      fread(&datatmpRGB[0], sizeof(float), 2 * Ncol, in_datafile[Np]);
    } else {
    for (Np = 0; Np < NpolarIn; Np++)
      fread(&datatmpRGB[0], sizeof(float), Ncol, in_datafile[Np]);
    }
  if (FlagValid == 1) fread(&datatmpRGB[0], sizeof(float), Ncol, in_valid);
  }

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);

  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++) {
      fread(&S_in[Np][0][0], sizeof(float), 2 * Ncol, in_datafile[Np]);
      }
    SPP_to_C2(S_in, M_in, 1, Ncol, 0, 0);
    } else {
    /* Case of C,T or I */
    for (Np = 0; Np < NpolarIn; Np++) {
      fread(&M_in[Np][0][0], sizeof(float), Ncol, in_datafile[Np]);
      }
    }
    
  if ((strcmp(PolTypeIn,"C2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col + Off_col] == 1.) {  
        NptsRGB++;
        if (strcmp(RGBFormat,"RGB1") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C222][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB2") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C211][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB3") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C222][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C211][0][col + Off_col]);
        if (datatmpRGB[NptsRGB] > eps) datatmpRGB[NptsRGB] = 10. * log10(datatmpRGB[NptsRGB]);
        else NptsRGB--;
        } /* valid */
      } /*col*/
    } else {
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col + Off_col] == 1.) {  
        NptsRGB++;
        if (strcmp(PolTypeIn,"IPPfull") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I422][0][col + Off_col]);
        if (strcmp(PolTypeIn,"IPPpp4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I322][0][col + Off_col]);
        if ((strcmp(PolTypeIn,"IPPpp5") == 0)||(strcmp(PolTypeIn,"IPPpp6") == 0)||(strcmp(PolTypeIn,"IPPpp7") == 0)) {
          if (strcmp(RGBFormat,"RGB1") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I212][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB2") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I211][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB3") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I212][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I211][0][col + Off_col]);
          }
        if (datatmpRGB[NptsRGB] > eps) datatmpRGB[NptsRGB] = 10. * log10(datatmpRGB[NptsRGB]);
        else NptsRGB--;
        } /* valid */
      } /*col*/
    }
 
  } /*lig*/
  NptsRGB++;
  
  minred = INIT_MINMAX; maxred = -minred;

/* DETERMINATION OF THE MIN / MAX OF THE RED CHANNEL */
  MinMaxContrastMedian(datatmpRGB, &minred, &maxred, NptsRGB);
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING GREEN CHANNEL */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

NptsRGB = -1;

/* OFFSET READING */
for (lig = 0; lig < Off_lig; lig++) {
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++)
      fread(&datatmpRGB[0], sizeof(float), 2 * Ncol, in_datafile[Np]);
    } else {
    for (Np = 0; Np < NpolarIn; Np++)
      fread(&datatmpRGB[0], sizeof(float), Ncol, in_datafile[Np]);
    }
  if (FlagValid == 1) fread(&datatmpRGB[0], sizeof(float), Ncol, in_valid);
  }
 
for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);

  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++) {
      fread(&S_in[Np][0][0], sizeof(float), 2 * Ncol, in_datafile[Np]);
      }
    SPP_to_C2(S_in, M_in, 1, Ncol, 0, 0);
    } else {
    /* Case of C,T or I */
    for (Np = 0; Np < NpolarIn; Np++) {
      fread(&M_in[Np][0][0], sizeof(float), Ncol, in_datafile[Np]);
      }
    }
    
  if ((strcmp(PolTypeIn,"C2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col + Off_col] == 1.) {  
        NptsRGB++;
        if (strcmp(RGBFormat,"RGB1") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C211][0][col + Off_col] - 2.*M_in[C212_re][0][col + Off_col] + M_in[C222][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB2") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C222][0][col + Off_col] - 2.*M_in[C212_re][0][col + Off_col] + M_in[C211][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB3") == 0) datatmpRGB[NptsRGB] =  fabs((sqrt(M_in[C211][0][col + Off_col]) - sqrt(M_in[C222][0][col + Off_col]))*(sqrt(M_in[C211][0][col + Off_col]) - sqrt(M_in[C222][0][col + Off_col])));
        if (strcmp(RGBFormat,"RGB4") == 0) datatmpRGB[NptsRGB] =  fabs((sqrt(M_in[C211][0][col + Off_col]) - sqrt(M_in[C222][0][col + Off_col]))*(sqrt(M_in[C211][0][col + Off_col]) - sqrt(M_in[C222][0][col + Off_col])));
        if (datatmpRGB[NptsRGB] > eps) datatmpRGB[NptsRGB] = 10. * log10(datatmpRGB[NptsRGB]);
        else NptsRGB--;
        } /* valid */
      } /*col*/
    } else {
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col + Off_col] == 1.) {  
        NptsRGB++;
        if (strcmp(PolTypeIn,"IPPfull") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I412][0][col + Off_col]);
        if (strcmp(PolTypeIn,"IPPpp4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I312][0][col + Off_col]);
        if ((strcmp(PolTypeIn,"IPPpp5") == 0)||(strcmp(PolTypeIn,"IPPpp6") == 0)||(strcmp(PolTypeIn,"IPPpp7") == 0)) {
          if (strcmp(RGBFormat,"RGB1") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I211][0][col + Off_col]-M_in[I212][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB2") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I211][0][col + Off_col]-M_in[I212][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB3") == 0) datatmpRGB[NptsRGB] =  fabs((sqrt(M_in[I211][0][col + Off_col])-sqrt(M_in[I212][0][col + Off_col]))*(sqrt(M_in[I211][0][col + Off_col])-sqrt(M_in[I212][0][col + Off_col])));
          if (strcmp(RGBFormat,"RGB4") == 0) datatmpRGB[NptsRGB] =  fabs((sqrt(M_in[I211][0][col + Off_col])-sqrt(M_in[I212][0][col + Off_col]))*(sqrt(M_in[I211][0][col + Off_col])-sqrt(M_in[I212][0][col + Off_col])));
          }
        if (datatmpRGB[NptsRGB] > eps) datatmpRGB[NptsRGB] = 10. * log10(datatmpRGB[NptsRGB]);
        else NptsRGB--;
        } /* valid */
      } /*col*/
    }
 
  } /*lig*/
  NptsRGB++;

  mingreen = INIT_MINMAX; maxgreen = -mingreen;

/* DETERMINATION OF THE MIN / MAX OF THE GREEN CHANNEL */
  MinMaxContrastMedian(datatmpRGB, &mingreen, &maxgreen, NptsRGB);

/********************************************************************
********************************************************************/
/* DATA PROCESSING BLUE CHANNEL */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

NptsRGB = -1;

/* OFFSET READING */
for (lig = 0; lig < Off_lig; lig++) {
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++)
      fread(&datatmpRGB[0], sizeof(float), 2 * Ncol, in_datafile[Np]);
    } else {
    for (Np = 0; Np < NpolarIn; Np++)
      fread(&datatmpRGB[0], sizeof(float), Ncol, in_datafile[Np]);
    }
  if (FlagValid == 1) fread(&datatmpRGB[0], sizeof(float), Ncol, in_valid);
  }

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);

  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (Np = 0; Np < NpolarIn; Np++) {
      fread(&S_in[Np][0][0], sizeof(float), 2 * Ncol, in_datafile[Np]);
      }
    SPP_to_C2(S_in, M_in, 1, Ncol, 0, 0);
    } else {
    /* Case of C,T or I */
    for (Np = 0; Np < NpolarIn; Np++) {
      fread(&M_in[Np][0][0], sizeof(float), Ncol, in_datafile[Np]);
      }
    }
    
  if ((strcmp(PolTypeIn,"C2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col + Off_col] == 1.) {  
        NptsRGB++;
        if (strcmp(RGBFormat,"RGB1") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C211][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB2") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C222][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB3") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C211][0][col + Off_col]);
        if (strcmp(RGBFormat,"RGB4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[C222][0][col + Off_col]);
        if (datatmpRGB[NptsRGB] > eps) datatmpRGB[NptsRGB] = 10. * log10(datatmpRGB[NptsRGB]);
        else NptsRGB--;
        } /* valid */
      } /*col*/
    } else {
    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col + Off_col] == 1.) {  
        NptsRGB++;
        if (strcmp(PolTypeIn,"IPPfull") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I411][0][col + Off_col]);
        if (strcmp(PolTypeIn,"IPPpp4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I311][0][col + Off_col]);
        if ((strcmp(PolTypeIn,"IPPpp5") == 0)||(strcmp(PolTypeIn,"IPPpp6") == 0)||(strcmp(PolTypeIn,"IPPpp7") == 0)) {
          if (strcmp(RGBFormat,"RGB1") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I211][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB2") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I212][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB3") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I211][0][col + Off_col]);
          if (strcmp(RGBFormat,"RGB4") == 0) datatmpRGB[NptsRGB] =  fabs(M_in[I212][0][col + Off_col]);
          }
        if (datatmpRGB[NptsRGB] > eps) datatmpRGB[NptsRGB] = 10. * log10(datatmpRGB[NptsRGB]);
        else NptsRGB--;
        } /* valid */
      } /*col*/
    }
 
  } /*lig*/
  NptsRGB++;

  minblue = INIT_MINMAX; maxblue = -minblue;

/* DETERMINATION OF THE MIN / MAX OF THE BLUE CHANNEL */
  MinMaxContrastMedian(datatmpRGB, &minblue, &maxblue, NptsRGB);

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
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0]);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(filebmp);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


