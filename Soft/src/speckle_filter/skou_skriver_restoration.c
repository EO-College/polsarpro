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

File   : skou_skriver_restoration.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Skou Skriver restoration of coherency / covariance
               matrices

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

#define NPolType 11
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3",
    "C4", "T2", "T3", "T4", "SPP"};
  
/* Internal variables */
  int ii, lig, col, k, l;
  int Nlook;
  float coeff, coeffold, Ncoeff, Nvalid;
  float meanch1, meanch2,  meanch3, meanch4;
  float Mmeanch1, Mmeanch2, Mmeanch3, Mmeanch4;
  float mean2ch1, mean2ch2, mean2ch3, mean2ch4;
  float Mmean2ch1, Mmean2ch2, Mmean2ch3, Mmean2ch4;
  int ligDone = 0;

/* Matrix arrays */
  float ***M_in;
  float ***Z_in;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nskou_skriver_restoration.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-idtmp	input tmp directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nlk 	Nlook\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
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

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idtmp",str_cmd_prm,in_dir2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&Nlook,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir1);
  check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in1 = matrix_char(NpolarIn,1024); 
  file_name_in2 = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  init_file_name(PolTypeOut, in_dir2, file_name_in2);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);

  for (Np = 0; Np < NpolarOut; Np++)
    if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);

/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Zin = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  Z_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile1, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile1, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_TCI_noavg(in_datafile2, Z_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col,Np,k,l,coeff,meanch1,meanch2,meanch3,meanch4,Mmeanch1,Mmeanch2,Mmeanch3,Mmeanch4,mean2ch1,mean2ch2,mean2ch3,mean2ch4,Mmean2ch1,Mmean2ch2,Mmean2ch3,Mmean2ch4,Nvalid,Ncoeff,coeffold) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
      if (col == 0) {
        coeff = 0.;
        meanch1 = 0.; meanch2 = 0.;  meanch3 = 0.; meanch4 = 0.;
        Mmeanch1 = 0.; Mmeanch2 = 0.;  Mmeanch3 = 0.; Mmeanch4 = 0.;
        mean2ch1 = 0.; mean2ch2 = 0.;  mean2ch3 = 0.; mean2ch4 = 0.;
        Mmean2ch1 = 0.; Mmean2ch2 = 0.;  Mmean2ch3 = 0.; Mmean2ch4 = 0.;
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            Nvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            /* Channel 1 */
            meanch1 += M_in[0][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            /* Channel 2 */
            if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"T2") == 0)) meanch2 += M_in[C222][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) meanch2 += M_in[C322][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) meanch2 += M_in[C422][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            /* Channel 3 */
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0) || (strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
              if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) meanch3 += M_in[C333][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) meanch3 += M_in[C433][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
            /* Channel 4 */
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
              meanch4 += M_in[C444][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
            /* Channel 1 */
            mean2ch1 += (M_in[0][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[0][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            /* Channel 2 */
            if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"T2") == 0)) mean2ch2 += (M_in[C222][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[C222][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) mean2ch2 += (M_in[C322][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[C322][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) mean2ch2 += (M_in[C422][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[C422][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            /* Channel 3 */
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0) || (strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
              if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) mean2ch3 += (M_in[C333][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[C333][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) mean2ch3 += (M_in[C433][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[C433][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
            /* Channel 4 */
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
              mean2ch4 += (M_in[C444][NwinLM1S2+lig+k][NwinCM1S2+col+l])*(M_in[C444][NwinLM1S2+lig+k][NwinCM1S2+col+l])*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];;
              }
            }

        if (Nvalid != 0.) Mmeanch1 = meanch1/Nvalid; else Mmeanch1 = INIT_MINMAX;
        if (Nvalid != 0.) Mmeanch2 = meanch2/Nvalid; else Mmeanch2 = INIT_MINMAX;
        if (Nvalid != 0.) Mmeanch3 = meanch3/Nvalid; else Mmeanch3 = INIT_MINMAX;
        if (Nvalid != 0.) Mmeanch4 = meanch4/Nvalid; else Mmeanch4 = INIT_MINMAX;

        Ncoeff = 2.;
        if (Nvalid != 0.) Mmean2ch1 = (mean2ch1/Nvalid) - Mmeanch1*Mmeanch1; else Mmean2ch1 = INIT_MINMAX;
        coeff = (Mmeanch1*Mmeanch1) / (Mmean2ch1 + eps);
        if (Nvalid != 0.) Mmean2ch2 = (mean2ch2/Nvalid) - Mmeanch2*Mmeanch2; else Mmean2ch2 = INIT_MINMAX;
        coeff += (Mmeanch2*Mmeanch2) / (Mmean2ch2 + eps);
        if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0) || (strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
          Ncoeff = 3.;
          if (Nvalid != 0.) Mmean2ch3 = (mean2ch3/Nvalid) - Mmeanch3*Mmeanch3; else Mmean2ch3 = INIT_MINMAX;
          coeff += (Mmeanch3*Mmeanch3) / (Mmean2ch3 + eps);
          }
        if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
          Ncoeff = 4.;
          if (Nvalid != 0.) Mmean2ch4 = (mean2ch4/Nvalid) - Mmeanch4*Mmeanch4; else Mmean2ch4 = INIT_MINMAX;
          coeff += (Mmeanch4*Mmeanch4) / (Mmean2ch4 + eps);
          }
        coeff = coeff / (Ncoeff * (float) Nlook);          

        for (Np = 0; Np < NpolarOut; Np++) {       
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              M_out[Np][lig][col] += coeff*Z_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
            }
          M_out[Np][lig][col] += M_in[Np][NwinLM1S2+lig][NwinCM1S2+col]*Valid[NwinLM1S2+lig][NwinCM1S2+col];
          M_out[Np][lig][col] /= (1. + Nvalid*coeff);
          } /* Np */
        coeffold = coeff;

        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          /* Channel 1 */
          meanch1 -= M_in[0][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          meanch1 += M_in[0][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          /* Channel 2 */
          if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"T2") == 0)) meanch2 -= M_in[C222][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) meanch2 -= M_in[C322][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) meanch2 -= M_in[C422][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"T2") == 0)) meanch2 += M_in[C222][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) meanch2 += M_in[C322][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) meanch2 += M_in[C422][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          /* Channel 3 */
          if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0) || (strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) meanch3 -= M_in[C333][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) meanch3 -= M_in[C433][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) meanch3 += M_in[C333][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) meanch3 += M_in[C433][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          /* Channel 4 */
          if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
            meanch4 -= M_in[C444][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            meanch4 += M_in[C444][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }

          /* Channel 1 */
          mean2ch1 -= M_in[0][NwinLM1S2+lig+k][col-1]*M_in[0][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          mean2ch1 += M_in[0][NwinLM1S2+lig+k][NwinC-1+col]*M_in[0][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          /* Channel 2 */
          if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"T2") == 0)) mean2ch2 -= M_in[C222][NwinLM1S2+lig+k][col-1]*M_in[C222][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) mean2ch2 -= M_in[C322][NwinLM1S2+lig+k][col-1]*M_in[C322][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) mean2ch2 -= M_in[C422][NwinLM1S2+lig+k][col-1]*M_in[C422][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
          if ((strcmp(PolTypeOut,"C2")==0) || (strcmp(PolTypeOut,"T2") == 0)) mean2ch2 += M_in[C222][NwinLM1S2+lig+k][NwinC-1+col]*M_in[C222][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) mean2ch2 += M_in[C322][NwinLM1S2+lig+k][NwinC-1+col]*M_in[C322][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) mean2ch2 += M_in[C422][NwinLM1S2+lig+k][NwinC-1+col]*M_in[C422][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
          /* Channel 3 */
          if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0) || (strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) mean2ch3 -= M_in[C333][NwinLM1S2+lig+k][col-1]*M_in[C333][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) mean2ch3 -= M_in[C433][NwinLM1S2+lig+k][col-1]*M_in[C433][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0)) mean2ch3 += M_in[C333][NwinLM1S2+lig+k][NwinC-1+col]*M_in[C333][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) mean2ch3 += M_in[C433][NwinLM1S2+lig+k][NwinC-1+col]*M_in[C433][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          /* Channel 4 */
          if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
            mean2ch4 -= M_in[C444][NwinLM1S2+lig+k][col-1]*M_in[C444][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];;
            mean2ch4 += M_in[C444][NwinLM1S2+lig+k][NwinC-1+col]*M_in[C444][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];;
            }
          }

        if (Nvalid != 0.) Mmeanch1 = meanch1/Nvalid; else Mmeanch1 = INIT_MINMAX;
        if (Nvalid != 0.) Mmeanch2 = meanch2/Nvalid; else Mmeanch2 = INIT_MINMAX;
        if (Nvalid != 0.) Mmeanch3 = meanch3/Nvalid; else Mmeanch3 = INIT_MINMAX;
        if (Nvalid != 0.) Mmeanch4 = meanch4/Nvalid; else Mmeanch4 = INIT_MINMAX;

        Ncoeff = 2.;
        if (Nvalid != 0.) Mmean2ch1 = (mean2ch1/Nvalid) - Mmeanch1*Mmeanch1; else Mmean2ch1 = INIT_MINMAX;
        coeff = (Mmeanch1*Mmeanch1) / (Mmean2ch1 + eps);
        if (Nvalid != 0.) Mmean2ch2 = (mean2ch2/Nvalid) - Mmeanch2*Mmeanch2; else Mmean2ch2 = INIT_MINMAX;
        coeff += (Mmeanch2*Mmeanch2) / (Mmean2ch2 + eps);
        if ((strcmp(PolTypeOut,"C3")==0) || (strcmp(PolTypeOut,"T3") == 0) || (strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
          Ncoeff = 3.;
          if (Nvalid != 0.) Mmean2ch3 = (mean2ch3/Nvalid) - Mmeanch3*Mmeanch3; else Mmean2ch3 = INIT_MINMAX;
          coeff += (Mmeanch3*Mmeanch3) / (Mmean2ch3 + eps);
          }
        if ((strcmp(PolTypeOut,"C4")==0) || (strcmp(PolTypeOut,"T4") == 0)) {
          Ncoeff = 4.;
          if (Nvalid != 0.) Mmean2ch4 = (mean2ch4/Nvalid) - Mmeanch4*Mmeanch4; else Mmean2ch4 = INIT_MINMAX;
          coeff += (Mmeanch4*Mmeanch4) / (Mmean2ch4 + eps);
          }
        coeff = coeff / (Ncoeff * (float) Nlook);          

        for (Np = 0; Np < NpolarOut; Np++) {       
          M_out[Np][lig][col] = (1. + Nvalid*coeffold)*M_out[Np][lig][col-1]-M_in[Np][NwinLM1S2+lig][NwinCM1S2+col-1]*Valid[NwinLM1S2+lig][NwinCM1S2+col-1];
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            M_out[Np][lig][col] -= coeffold*Z_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig][col-1];
            M_out[Np][lig][col] += coeff*Z_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig][NwinC-1+col];
            }
          M_out[Np][lig][col] += M_in[Np][NwinLM1S2+lig][NwinCM1S2+col]*Valid[NwinLM1S2+lig][NwinCM1S2+col];
          M_out[Np][lig][col] /= (1. + Nvalid*coeff);
          } /* Np */
        coeffold = coeff;
        }  
/*******************************************************************/
      } /* col */
    } /* lig */

  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(Z_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  for (Np = 0; Np < NpolarOut; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}
