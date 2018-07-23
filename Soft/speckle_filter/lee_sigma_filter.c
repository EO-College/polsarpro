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

File   : lee_sigma_filter.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2010
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

Description :  J.S. Lee sigma fully polarimetric speckle filter

Source: "Improved Sigma Filter for Speckle Filtering of SAR imagery"
J.S. Lee, J.H Wen, T. Ainsworth, K.S Chen, A.J Chen
IEEE GRS Letters - 2008

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
#define TargetSize 5

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* LOCAL PROCEDURES */
static int cmp (void const *a, void const *b)
{
  int ret = 0;
  float const *pa = a;
  float const *pb = b;
  float diff = *pa - *pb;
  if (diff > 0)
  {
    ret = 1;
  }
  else if (diff < 0)
  {
    ret = -1;
  }

  return ret;
}

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 11
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2",
    "C3", "C4", "T2", "T3", "T4", "SPP"};
  
/* Internal variables */
  int ii, lig, col, k, l;

  int total, Nlook, sigma, Nwin, NW, Npt;
  int MaxSize, Ind98;
  int NWm1s2, NwinM1S2;
  int TT, T11, T22, T33, T44;

  float ThresholdChx1, ThresholdChx2, ThresholdChx3, ThresholdChx4; 
  float mz3x3, varZ3x3, varX3x3, b3x3, mea;
  float totalT, mz, varz, varx, bb;
  float A1, A2, sigmaV, sigmaV0;

/* Matrix arrays */
  float ***S_in;
  float ***M_in;
  float ***M_out;
  float **det1, **det2, **det3, **det4;
  float **del1, **del2, **del3, **del4, **delT;
  float **span;
  float *mTT;
  float *Tmp_in;
  float **M_tmp;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nlee_sigma_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nlk 	Nlook\n");
strcat(UsageHelp," (int)   	-sig 	Sigma\n");
strcat(UsageHelp," (int)   	-nwe 	Nwin Row and Col - Environnement\n");
strcat(UsageHelp," (int)   	-nwt 	Nwin Row and Col - Target\n");
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

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&Nlook,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sig",int_cmd_prm,&sigma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwe",int_cmd_prm,&Nwin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwt",int_cmd_prm,&NW,1,UsageHelp);
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
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = Nwin; NwinC = Nwin;
  
  NWm1s2 = (NW - 1) / 2;
  NwinM1S2 = (Nwin - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);

/********************************************************************
********************************************************************/
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)
    ||(strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
    T11 = 0; T22 = 3;
    }
  if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
    T11 = 0; T22 = 5; T33 = 8;
    }                  
  if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    T11 = 0; T22 = 7; T33 = 12; T44 = 15;
    }                  

/********************************************************************
*********************************************************************
*************  CHANNEL 98 PERCENTILE DETERMINATION   ************
*********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* TmpIn = Sub_Nlig*Sub_Ncol */
  NBlockB += Sub_Nlig*Sub_Ncol;
  /* Mtmp = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol;
  /* Sin = NpolarIn*(Nlig+Nwin)*2*(Ncol+Nwin) */
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    NBlockA += NpolarIn*2*(Ncol+Nwin); NBlockB += NpolarIn*Nwin*2*(Ncol+Nwin);
    }
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, Nwin, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_tmp = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  Tmp_in = vector_float(Sub_Nlig*Sub_Ncol);
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
    }
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* COMPUTE 98 PERCENTILE OF Chx1 */
if (FlagValid == 1) rewind(in_valid);

if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  }
  
Npt = 0; TT = T11;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, S_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      if (strcmp(PolTypeOut,"C3")==0) S2_to_C3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C4")==0) S2_to_C4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T3")==0) S2_to_T3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T4")==0) S2_to_T4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      } else {
      read_block_SPP_noavg(in_datafile, S_in, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      SPP_to_C2elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    } else {

    /* Case of C,T or I */
    read_block_matrix_float(in_datafile[TT], M_tmp, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Tmp_in[Npt] = M_tmp[lig][col];
        Npt++;
        }
      }
    }
  } // NbBlock

  MaxSize = Npt;
  Ind98 = (int)floor(0.98*(float)MaxSize);

/* Sorting Array */
  qsort(Tmp_in, MaxSize, sizeof *Tmp_in, cmp);
/* Threshold for Chx1 */
  ThresholdChx1 = Tmp_in[Ind98];

/*******************************************************************/
/* COMPUTE 98 PERCENTILE OF Chx2 */
if (FlagValid == 1) rewind(in_valid);

if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  }
  
Npt = 0; TT = T22;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, S_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      if (strcmp(PolTypeOut,"C3")==0) S2_to_C3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C4")==0) S2_to_C4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T3")==0) S2_to_T3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T4")==0) S2_to_T4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      } else {
      read_block_SPP_noavg(in_datafile, S_in, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      SPP_to_C2elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    } else {

    /* Case of C,T or I */
    read_block_matrix_float(in_datafile[TT], M_tmp, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Tmp_in[Npt] = M_tmp[lig][col];
        Npt++;
        }
      }
    }
  } // NbBlock

  MaxSize = Npt;
  Ind98 = (int)floor(0.98*(float)MaxSize);
  
/* Sorting Array */
  qsort(Tmp_in, MaxSize, sizeof *Tmp_in, cmp);
/* Threshold for Chx2 */
  ThresholdChx2 = Tmp_in[Ind98];

/*******************************************************************/
if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"T6")==0)) {

/*******************************************************************/
/* COMPUTE 98 PERCENTILE OF Chx3 */
if (FlagValid == 1) rewind(in_valid);
if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  }
  
Npt = 0; TT = T33;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, S_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      if (strcmp(PolTypeOut,"C3")==0) S2_to_C3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C4")==0) S2_to_C4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T3")==0) S2_to_T3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T4")==0) S2_to_T4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      } else {
      read_block_SPP_noavg(in_datafile, S_in, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      SPP_to_C2elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    } else {

    /* Case of C,T or I */
    read_block_matrix_float(in_datafile[TT], M_tmp, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Tmp_in[Npt] = M_tmp[lig][col];
        Npt++;
        }
      }
    }
  } // NbBlock

  MaxSize = Npt;
  Ind98 = (int)floor(0.98*(float)MaxSize);
  
/* Sorting Array */
  qsort(Tmp_in, MaxSize, sizeof *Tmp_in, cmp);
/* Threshold for Chx3 */
  ThresholdChx3 = Tmp_in[Ind98];

/*******************************************************************/
if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"T6")==0)) {
/*******************************************************************/
/* COMPUTE 98 PERCENTILE OF Chx4 */
if (FlagValid == 1) rewind(in_valid);

if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  }
  
Npt = 0; TT = T44;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, S_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      if (strcmp(PolTypeOut,"C3")==0) S2_to_C3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C4")==0) S2_to_C4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T3")==0) S2_to_T3elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T4")==0) S2_to_T4elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      } else {
      read_block_SPP_noavg(in_datafile, S_in, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
      SPP_to_C2elt(TT, S_in, M_tmp, NligBlock[Nb], Sub_Ncol, 0, 0);
      }

    } else {

    /* Case of C,T or I */
    read_block_matrix_float(in_datafile[TT], M_tmp, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Tmp_in[Npt] = M_tmp[lig][col];
        Npt++;
        }
      }
    }
  } // NbBlock

  MaxSize = Npt;
  Ind98 = (int)floor(0.98*(float)MaxSize);
  
/* Sorting Array */
  qsort(Tmp_in, MaxSize, sizeof *Tmp_in, cmp);
/* Threshold for Chx4 */
  ThresholdChx4 = Tmp_in[Ind98];

/*******************************************************************/
} // C4,T4
} // C3,T3,C4,T4

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix_float(Valid,NligBlock[0] + NwinL);
  free_matrix_float(M_tmp, NligBlock[0] + NwinL);
  free_vector_float(Tmp_in);
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    free_matrix3d_float(S_in, NpolarIn, NligBlock[0]);
    }
    
/********************************************************************
********************************************************************/
/* INPUT FILE REWIND*/
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  
/********************************************************************
*********************************************************************
*************      SIGMA SPECKLE FILTERING      ************
*********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Mout = NpolarOut*(Nlig+Nwin)*(Sub_Ncol+Nwin) */
  NBlockA += NpolarOut*(Sub_Ncol+Nwin); NBlockB += NpolarOut*Nwin*(Sub_Ncol+Nwin);
  /* Min = NpolarOut*(Nlig+Nwin)*(Ncol+Nwin) */
  NBlockA += NpolarOut*(Ncol+Nwin); NBlockB += NpolarOut*Nwin*(Ncol+Nwin);
  /* delT */ NBlockB += Nwin*Nwin;
  /* span */ NBlockB += Nwin*Nwin;
  /* mTT */  NBlockB += NpolarOut;
  /* det1 to det4 */ NBlockB += 4*NW*NW;
  /* del1 to del4 */ NBlockB += 4*Nwin*Nwin;
  
/* Reading Data */
  NBlockB += NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, Nwin, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + Nwin, Ncol + Nwin);
  M_out = matrix3d_float(NpolarOut, NligBlock[0] + Nwin, Sub_Ncol + Nwin);
  delT = matrix_float(Nwin,Nwin);
  span = matrix_float(Nwin,Nwin); 
  mTT = vector_float(NpolarOut);
  
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)
    ||(strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
    det1 = matrix_float(NW,NW); det2 = matrix_float(NW,NW);
    del1 = matrix_float(Nwin,Nwin); del2 = matrix_float(Nwin,Nwin);
    }
  if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
    det1 = matrix_float(NW,NW); det2 = matrix_float(NW,NW);
    det3 = matrix_float(NW,NW);
    del1 = matrix_float(Nwin,Nwin); del2 = matrix_float(Nwin,Nwin);
    del3 = matrix_float(Nwin,Nwin);
    }                  
  if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    det1 = matrix_float(NW,NW); det2 = matrix_float(NW,NW);
    det3 = matrix_float(NW,NW); det4 = matrix_float(NW,NW);
    del1 = matrix_float(Nwin,Nwin); del2 = matrix_float(Nwin,Nwin);
    del3 = matrix_float(Nwin,Nwin); del4 = matrix_float(Nwin,Nwin);
    }                  

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  if (Nlook <= 0) Nlook = 1;
  if (Nlook > 4) Nlook = 4;

  /* Speckle variance given by the input data number of looks */
  sigmaV0 = 1. / sqrt((float)Nlook);
  
  /* Sigma range calculation parameters */
  if (Nlook == 1) {
    if (sigma == 5 ) { A1 = 0.436; A2 = 1.920; sigmaV = 0.4057; }
    if (sigma == 6 ) { A1 = 0.343; A2 = 2.210; sigmaV = 0.4954; }
    if (sigma == 7 ) { A1 = 0.254; A2 = 2.582; sigmaV = 0.5911; }
    if (sigma == 8 ) { A1 = 0.168; A2 = 3.094; sigmaV = 0.6966; }
    if (sigma == 9 ) { A1 = 0.084; A2 = 3.941; sigmaV = 0.8191; }
  }
  if (Nlook == 2) {
    if (sigma == 5 ) { A1 = 0.582; A2 = 1.584; sigmaV = 0.2763; }
    if (sigma == 6 ) { A1 = 0.501; A2 = 1.755; sigmaV = 0.3388; }
    if (sigma == 7 ) { A1 = 0.418; A2 = 1.972; sigmaV = 0.4062; }
    if (sigma == 8 ) { A1 = 0.327; A2 = 2.260; sigmaV = 0.4810; }
    if (sigma == 9 ) { A1 = 0.221; A2 = 2.744; sigmaV = 0.5699; }
  }
  if (Nlook == 3) {
    if (sigma == 5 ) { A1 = 0.652; A2 = 1.458; sigmaV = 0.2222; }
    if (sigma == 6 ) { A1 = 0.580; A2 = 1.586; sigmaV = 0.2736; }
    if (sigma == 7 ) { A1 = 0.505; A2 = 1.751; sigmaV = 0.3280; }
    if (sigma == 8 ) { A1 = 0.419; A2 = 1.965; sigmaV = 0.3892; }
    if (sigma == 9 ) { A1 = 0.313; A2 = 2.320; sigmaV = 0.4624; }
  }
  if (Nlook == 4) {
    if (sigma == 5 ) { A1 = 0.694; A2 = 1.385; sigmaV = 0.1921; }
    if (sigma == 6 ) { A1 = 0.630; A2 = 1.495; sigmaV = 0.2348; }
    if (sigma == 7 ) { A1 = 0.560; A2 = 1.627; sigmaV = 0.2825; }
    if (sigma == 8 ) { A1 = 0.480; A2 = 1.804; sigmaV = 0.3354; }
    if (sigma == 9 ) { A1 = 0.378; A2 = 2.094; sigmaV = 0.3991; }
  }

/*******************************************************************/
  for (lig = 0; lig < NligBlock[0] + Nwin; lig++) 
    for (col = 0; col < Sub_Ncol + Nwin; col++) 
      for (Np = 0; Np < NpolarOut; Np++)
        M_out[Np][lig][col] = 0.;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolType,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, Nwin, Nwin, Off_lig, Off_col, Ncol);

/* SIGMA FILTERING */
for (lig = 0; lig < NligBlock[Nb]; lig++) {
  PrintfLine(lig,NligBlock[Nb]);

  for (col = 0; col < Sub_Ncol; col++) {
    for (Np = 0; Np < NpolarOut; Np++) M_out[Np][NwinM1S2 + lig][NwinM1S2 + col] = 0.;
    if (Valid[NwinM1S2 + lig][NwinM1S2 + col] == 1.) {

    /* Step 0: Check if the Center Pixel in Channel 1 can been preserved as a point Target */
    if (M_in[T11][NwinM1S2 + lig][NwinM1S2 + col] <= ThresholdChx1) goto NEXTPOL1; 

    /* Step 1: Check if the Center Pixel in Channel 1 has been previously preserved as point Target */
    if (M_out[T11][NwinM1S2 + lig][NwinM1S2 + col] == M_in[T11][NwinM1S2 + lig][NwinM1S2 + col]) goto NEXTT;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
        det1[k + NWm1s2][l + NWm1s2] = 0.;
        if (M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= ThresholdChx1) det1[k + NWm1s2][l + NWm1s2] = 1.;
      }
    total = 0;
    for (k = 0; k < NW; k++) for (l = 0; l < NW; l++) if (det1[k][l] == 1) total++;
    if (total >= TargetSize) {
      for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
        for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
          if (det1[k + NWm1s2][l + NWm1s2] == 1.) 
            for (Np = 0; Np < NpolarOut; Np++) M_out[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l] = M_in[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l];
          }
      goto NEXTT;
      }

/*******************************************************************/
NEXTPOL1:
/*******************************************************************/
    /* Step 0: Check if the Center Pixel in Channel 2 can been preserved as a point Target */
    if (M_in[T22][NwinM1S2 + lig][NwinM1S2 + col] <= ThresholdChx2) goto NEXTPOL2; 

    /* Step 1: Check if the Center Pixel in Channel 2 has been previously preserved as point Target */
    if (M_out[T22][NwinM1S2 + lig][NwinM1S2 + col] == M_in[T22][NwinM1S2 + lig][NwinM1S2 + col]) goto NEXTT;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
        det2[k + NWm1s2][l + NWm1s2] = 0.;
        if (M_in[T22][NwinM1S2 + lig +k][NwinM1S2 + col +l] >= ThresholdChx2) det2[k + NWm1s2][l + NWm1s2] = 1.;
      }
    total = 0;
    for (k = 0; k < NW; k++) for (l = 0; l < NW; l++) if (det2[k][l] == 1) total++;
    if (total >= TargetSize) {
      for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
        for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
          if (det2[k + NWm1s2][l + NWm1s2] == 1.) 
            for (Np = 0; Np < NpolarOut; Np++) M_out[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l] = M_in[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l];
          }
      goto NEXTT;
      }
/*******************************************************************/
NEXTPOL2:
/*******************************************************************/
if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"T6")==0)) {
    /* Step 0: Check if the Center Pixel in Channel 3 can been preserved as a point Target */
    if (M_in[T33][NwinM1S2 + lig][NwinM1S2 + col] <= ThresholdChx3) goto NEXTPOL3; 

    /* Step 1: Check if the Center Pixel in Channel 3 has been previously preserved as point Target */
    if (M_out[T33][NwinM1S2 + lig][NwinM1S2 + col] == M_in[T33][NwinM1S2 + lig][NwinM1S2 + col]) goto NEXTT;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
        det3[k + NWm1s2][l + NWm1s2] = 0.;
        if (M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= ThresholdChx3) det3[k + NWm1s2][l + NWm1s2] = 1.;
      }
    total = 0;
    for (k = 0; k < NW; k++) for (l = 0; l < NW; l++) if (det3[k][l] == 1) total++;
    if (total >= TargetSize) {
      for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
        for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
          if (det3[k + NWm1s2][l + NWm1s2] == 1.) 
            for (Np = 0; Np < NpolarOut; Np++) M_out[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l] = M_in[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l];
          }
      goto NEXTT;
      }
    }      
/*******************************************************************/
NEXTPOL3:
/*******************************************************************/
if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    /* Step 0: Check if the Center Pixel in Channel 4 can been preserved as a point Target */
    if (M_in[T44][NwinM1S2 + lig][NwinM1S2 + col] <= ThresholdChx4) goto NEXTPOL4; 

    /* Step 1: Check if the Center Pixel in Channel 4 has been previously preserved as point Target */
    if (M_out[T44][NwinM1S2 + lig][NwinM1S2 + col] == M_in[T44][NwinM1S2 + lig][NwinM1S2 + col]) goto NEXTT;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
        det4[k + NWm1s2][l + NWm1s2] = 0.;
        if (M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= ThresholdChx4) det4[k + NWm1s2][l + NWm1s2] = 1.;
      }
    total = 0;
    for (k = 0; k < NW; k++) for (l = 0; l < NW; l++) if (det4[k][l] == 1) total++;
    if (total >= TargetSize) {
      for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
        for (l = -NWm1s2; l < 1 + NWm1s2; l++) {
          if (det4[k + NWm1s2][l + NWm1s2] == 1.) 
            for (Np = 0; Np < NpolarOut; Np++) M_out[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l] = M_in[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l];
          }
      goto NEXTT;
      }
    }
/*******************************************************************/
NEXTPOL4:
/*******************************************************************/
    
    /* Step 2: Pixel Selection within sigma range - Channel 1 */
    mz3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        mz3x3 = mz3x3 + M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] / (NW * NW);

    varZ3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        varZ3x3 = varZ3x3 + (M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3) * (M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3);
        varZ3x3 = varZ3x3 / (NW * NW);

    varX3x3 = (varZ3x3 - (mz3x3*sigmaV0)*(mz3x3*sigmaV0)) / (1. + sigmaV0*sigmaV0);
        
    if (varX3x3 <= 0.0) b3x3 = 0.0;
    else b3x3 = varX3x3 / varZ3x3;
    mea = (1. - b3x3)*mz3x3 + b3x3*M_in[T11][NwinM1S2 + lig][NwinM1S2 + col];

    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) del1[k][l] = 0.;
    /* select pixels in sigma range from 9x9 filter window */
    for (k = -NwinM1S2; k < 1 + NwinM1S2; k++) {
      for (l = -NwinM1S2; l < 1 + NwinM1S2; l++) {
        del1[k + NwinM1S2][l + NwinM1S2] = 0.;
        if ( (M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= A1*mea) && (M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] <= A2*mea) ) del1[k + NwinM1S2][l + NwinM1S2] = 1.;
        }
      }

    /* Step 2: Pixel Selection within sigma range - Channel 2 */
    mz3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        mz3x3 = mz3x3 + M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] / (NW * NW);

    varZ3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        varZ3x3 = varZ3x3 + (M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3) * (M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3);
        varZ3x3 = varZ3x3 / (NW * NW);

    varX3x3 = (varZ3x3 - (mz3x3*sigmaV0)*(mz3x3*sigmaV0)) / (1. + sigmaV0*sigmaV0);
        
    if (varX3x3 <= 0.0) b3x3 = 0.0;
    else b3x3 = varX3x3 / varZ3x3;
    mea = (1. - b3x3)*mz3x3 + b3x3*M_in[T22][NwinM1S2 + lig][NwinM1S2 + col];

    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) del2[k][l] = 0.;
    /* select pixels in sigma range from 9x9 filter window */
    for (k = -NwinM1S2; k < 1 + NwinM1S2; k++) {
      for (l = -NwinM1S2; l < 1 + NwinM1S2; l++) {
        del2[k + NwinM1S2][l + NwinM1S2] = 0.;
        if ( (M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= A1*mea) && (M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] <= A2*mea) ) del2[k + NwinM1S2][l + NwinM1S2] = 1.;
        }
      }

if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    /* Step 2: Pixel Selection within sigma range - Channel 3 */
    mz3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        mz3x3 = mz3x3 + M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] / (NW * NW);

    varZ3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        varZ3x3 = varZ3x3 + (M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3) * (M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3);
        varZ3x3 = varZ3x3 / (NW * NW);

    varX3x3 = (varZ3x3 - (mz3x3*sigmaV0)*(mz3x3*sigmaV0)) / (1. + sigmaV0*sigmaV0);
        
    if (varX3x3 <= 0.0) b3x3 = 0.0;
    else b3x3 = varX3x3 / varZ3x3;
    mea = (1. - b3x3)*mz3x3 + b3x3*M_in[T33][NwinM1S2 + lig][NwinM1S2 + col];

    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) del3[k][l] = 0.;
    /* select pixels in sigma range from 9x9 filter window */
    for (k = -NwinM1S2; k < 1 + NwinM1S2; k++) {
      for (l = -NwinM1S2; l < 1 + NwinM1S2; l++) {
        del3[k + NwinM1S2][l + NwinM1S2] = 0.;
        if ( (M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= A1*mea) && (M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] <= A2*mea) ) del3[k + NwinM1S2][l + NwinM1S2] = 1.;
        }
      }
    }
    
if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {  
    /* Step 2: Pixel Selection within sigma range - Channel 4 */
    mz3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        mz3x3 = mz3x3 + M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l] / (NW * NW);

    varZ3x3 = 0.;
    for (k = -NWm1s2; k < 1 + NWm1s2; k++) 
      for (l = -NWm1s2; l < 1 + NWm1s2; l++) 
        varZ3x3 = varZ3x3 + (M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3) * (M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l] - mz3x3);
        varZ3x3 = varZ3x3 / (NW * NW);

    varX3x3 = (varZ3x3 - (mz3x3*sigmaV0)*(mz3x3*sigmaV0)) / (1. + sigmaV0*sigmaV0);
        
    if (varX3x3 <= 0.0) b3x3 = 0.0;
    else b3x3 = varX3x3 / varZ3x3;
    mea = (1. - b3x3)*mz3x3 + b3x3*M_in[T44][NwinM1S2 + lig][NwinM1S2 + col];

    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) del4[k][l] = 0.;
    /* select pixels in sigma range from 9x9 filter window */
    for (k = -NwinM1S2; k < 1 + NwinM1S2; k++) {
      for (l = -NwinM1S2; l < 1 + NwinM1S2; l++) {
        del4[k + NwinM1S2][l + NwinM1S2] = 0.;
        if ( (M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l] >= A1*mea) && (M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l] <= A2*mea) ) del4[k + NwinM1S2][l + NwinM1S2] = 1.;
        }
      }
    }

    /* "AND" selected pixels */
    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) delT[k][l] = 0.;
    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) {
      if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) delT[k][l] = del1[k][l]*del2[k][l];
      if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) delT[k][l] = del1[k][l]*del2[k][l];
      if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) delT[k][l] = del1[k][l]*del2[k][l]*del3[k][l];
      if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) delT[k][l] = del1[k][l]*del2[k][l]*del3[k][l]*del4[k][l];
      }
    
    /* Step 3: Compute MMSE weight b */
    for (k = -NwinM1S2; k < 1 + NwinM1S2; k++) 
      for (l = -NwinM1S2; l < 1 + NwinM1S2; l++) {
        if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) span[k + NwinM1S2][l + NwinM1S2] = M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l];         
        if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) span[k + NwinM1S2][l + NwinM1S2] = M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l];         
        if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) span[k + NwinM1S2][l + NwinM1S2] = M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l]; 
        if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) span[k + NwinM1S2][l + NwinM1S2] = M_in[T11][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T22][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T33][NwinM1S2 + lig + k][NwinM1S2 + col + l] + M_in[T44][NwinM1S2 + lig + k][NwinM1S2 + col + l]; 
        }

    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) span[k][l] = span[k][l]*delT[k][l];

    totalT = 0.;
    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) if (delT[k][l] == 1.) totalT=totalT+1.;

    mz = 0.; varz = 0.;
    if (totalT < 2.) {
      mz = mea;
      varz = 10000.;
      } else {
      for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) mz = mz + span[k][l];
      mz = mz / totalT;
      for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) varz = varz + (span[k][l]-mz)*(span[k][l]-mz);
      varz = varz / totalT;
      }

    varx = (varz - (mz*sigmaV)*(mz*sigmaV)) / (1. + sigmaV*sigmaV);
    if (varx <= 0.0) bb = 0.;
    else bb = varx / varz;

    /* Step 4: Speckle filtering using selected pixels in a 9x9 window */
    for (Np = 0; Np < NpolarOut; Np++)  {
      if (totalT == 0.) {
        mTT[Np]=mea;
        } else {
        mTT[Np]=0.;
        for (k = -NwinM1S2; k < 1 + NwinM1S2; k++) 
          for (l = -NwinM1S2; l < 1 + NwinM1S2; l++) 
            mTT[Np] = mTT[Np] + M_in[Np][NwinM1S2 + lig + k][NwinM1S2 + col + l]*delT[NwinM1S2 + k][NwinM1S2 + l] / totalT;
        }
      }
    
    for (Np = 0; Np < NpolarOut; Np++)
      M_out[Np][NwinM1S2 + lig][NwinM1S2 + col] = (1. - bb)*mTT[Np] + bb*M_in[Np][NwinM1S2 + lig][NwinM1S2 + col];
    

/*******************************************************************/
NEXTT:
/*******************************************************************/
    for (k = 0; k < Nwin; k++) for (l = 0; l < Nwin; l++) delT[k][l] = 0.0;
        
      } /*Valid*/
    } /*col */
  } /*lig */

/* FILTERED DATA WRITING */
  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, NwinM1S2, NwinM1S2, Sub_Ncol+Nwin);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + Nwin);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + Nwin);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0] + Nwin);
  free_matrix_float(delT,Nwin);
  free_matrix_float(span,Nwin); 
  free_vector_float(mTT);

  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)
    ||(strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
    free_matrix_float(det1,NW); free_matrix_float(det2,NW);
    free_matrix_float(del1,Nwin); free_matrix_float(del2,Nwin);
    }
  if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
    free_matrix_float(det1,NW); free_matrix_float(det2,NW);
    free_matrix_float(det3,NW);
    free_matrix_float(del1,Nwin); free_matrix_float(del2,Nwin);
    free_matrix_float(del3,Nwin); 
    }                  
  if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    free_matrix_float(det1,NW); free_matrix_float(det2,NW);
    free_matrix_float(det3,NW); free_matrix_float(det4,NW);
    free_matrix_float(del1,Nwin); free_matrix_float(del2,Nwin);
    free_matrix_float(del3,Nwin); free_matrix_float(del4,Nwin);
    }                  
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  
/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


