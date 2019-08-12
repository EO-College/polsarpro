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

File   : change_detector.c
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

Description :  Statistical similarity measure for change detection
               between two float images

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
  FILE *fileinputX, *fileinputY, *fileoutput;
  char FileInputX[FilePathLength], FileInputY[FilePathLength], FileOutput[FilePathLength];
  char Detector[20];

/* Internal variables */
  int lig, col, k, l;
  int ligDone = 0;

  double muX1, muX2;
//double  muX3, muX4;
  double muY1, muY2;
//double  muY3, muY4;
  double MmuX1, MmuX2, MmuX3, MmuX4;
  double MmuY1, MmuY2, MmuY3, MmuY4;
  float kX1, kX2;
//float kX3, kX4;
  float kY1, kY2;
//float kY3, kY4;
  double muXp1, muXp2, muXp3, muXp4;
  double muYp1, muYp2, muYp3, muYp4;
  double MmuXp1, MmuXp2, MmuXp3, MmuXp4;
  double MmuYp1, MmuYp2, MmuYp3, MmuYp4;
//  float kXp1, kXp2;
  float kXp3, kXp4;
//  float kYp1, kYp2;
  float kYp3, kYp4;
  float alp, bet;
  float c2, c3, c4, c6;
  float a1, a2, a3;
  float KLXY, KLYX;  
  double Xvalid, Yvalid;
  double value;
  float Xp, Yp;

/* Matrix arrays */
  float **M_inX;
  float **M_inY;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nchange_detector_mult.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if1 	input file 1\n");
strcat(UsageHelp," (string)	-if2 	input file 1\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-det 	detector (mrd, gkld, ckld)\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
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

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,FileInputX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,FileInputY,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-det",str_cmd_prm,Detector,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
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

  check_file(FileInputX);
  check_file(FileInputY);
  check_file(FileOutput);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT FILE OPENING*/
  if ((fileinputX = fopen(FileInputX, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInputX);

  if ((fileinputY = fopen(FileInputY, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInputY);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
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
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Min1 = (Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
  /* Min2 = (Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VI_in = vector_int(Ncol);
  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_inX = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  M_inY = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

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

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileinputX, M_inX, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileinputY, M_inY, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(Detector,"mrd")==0) {
    ligDone = 0;
#pragma omp parallel for private(col,k,l,Xvalid,Yvalid,MmuX1,MmuY1,muX1,muY1) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        M_out[lig][col] = 0.;
        if (col == 0) {
          Xvalid = 0.; MmuX1 = 0.;
          Yvalid = 0.; MmuY1 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              MmuX1 += M_inX[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              Xvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuY1 += M_inY[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              Yvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            MmuX1 -= M_inX[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            MmuX1 += M_inX[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            Xvalid = Xvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuY1 -= M_inY[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            MmuY1 += M_inY[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            Yvalid = Yvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          }
        if (Xvalid != 0.) muX1 = MmuX1/Xvalid;
        if (Yvalid != 0.) muY1 = MmuY1/Yvalid;
        if ((muX1/muY1) <= (muY1/muX1)) M_out[lig][col] = 1. - (muX1/muY1);
        else M_out[lig][col] = 1. - (muY1/muX1);
        }
      }
    }

  if (strcmp(Detector,"gkld")==0) {
    ligDone = 0;
#pragma omp parallel for private(col,k,l,Xvalid,Yvalid,MmuX1,MmuY1,muX1,muY1,MmuX2,MmuY2,muX2,muY2) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        M_out[lig][col] = 0.;
        if (col == 0) {
          Xvalid = 0.; MmuX1 = 0.; MmuX2 = 0.;
          Yvalid = 0.; MmuY1 = 0.; MmuY2 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              value = M_inX[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuX1 += value; MmuX2 += value*value;
              Xvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              value = M_inY[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuY1 += value; MmuY2 += value*value;
              Yvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            value = M_inX[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            MmuX1 -= value; MmuX2 -= value*value;
            value = M_inX[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuX1 += value; MmuX2 += value*value;
            Xvalid = Xvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
            value = M_inY[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            MmuY1 -= value; MmuY2 -= value*value;
            value = M_inY[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuY1 += value; MmuY2 += value*value;
            Yvalid = Yvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          }
        if (Xvalid != 0.) muX1 = MmuX1/Xvalid;
        if (Yvalid != 0.) muY1 = MmuY1/Yvalid;
        if (Xvalid != 0.) muX2 = (MmuX2/Xvalid) - muX1*muX1;
        if (Yvalid != 0.) muY2 = (MmuY2/Yvalid) - muY1*muY1;          
        M_out[lig][col] = ((muX2*muX2+muY2*muY2+(muX1-muY1)*(muX1-muY1)*(muX2+muY2))/(2.*muX2*muY2 + eps)) - 1.;    
        }
      }
    }

  if (strcmp(Detector,"ckld")==0) {
    ligDone = 0;
#pragma omp parallel for private(col,k,l,Xvalid,MmuX1,MmuX2,MmuX3,MmuX4,Yvalid,MmuY1,MmuY2,MmuY3,MmuY4,value,muX1,muY1,muX2,muY2,MmuXp1,MmuXp2,MmuXp3,MmuXp4,MmuYp1,MmuYp2,MmuYp3,MmuYp4,Xp,Yp,kX1,kY1,kX2,kY2,kXp3,kYp3,kXp4,kYp4,alp,c2,c3,c4,c6,a1,a2,a3,KLXY,KLYX) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        M_out[lig][col] = 0.;
        if (col == 0) {
          Xvalid = 0.; MmuX1 = 0.; MmuX2 = 0.; MmuX3 = 0.; MmuX4 = 0.;
          Yvalid = 0.; MmuY1 = 0.; MmuY2 = 0.; MmuY3 = 0.; MmuY4 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              value = M_inX[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuX1 += value; MmuX2 += value*value; MmuX3 += value*value*value; MmuX4 += value*value*value*value;
              Xvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              value = M_inY[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuY1 += value; MmuY2 += value*value; MmuY3 += value*value*value; MmuY4 += value*value*value*value;
              Yvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
          if (Xvalid != 0.) muX1 = (MmuX1/Xvalid);
          if (Yvalid != 0.) muY1 = (MmuY1/Yvalid);
          if (Xvalid != 0.) {
            muX2 = (MmuX2/Xvalid) - muX1*muX1;
//            muX3 = (MmuX3/Xvalid) - 3.*muX1*(MmuX2/Xvalid) + 2.*muX1*muX1*muX1;
//            muX4 = (MmuX4/Xvalid) - 4.*muX1*(MmuX3/Xvalid) + 6.*muX1*muX1*(MmuX2/Xvalid) - 3.*muX1*muX1*muX1*muX1;
            muY2 = (MmuY2/Yvalid) - muY1*muY1;
//            muY3 = (MmuY3/Yvalid) - 3.*muY1*(MmuY2/Yvalid) + 2.*muY1*muY1*muY1;
//            muY4 = (MmuY4/Yvalid) - 4.*muY1*(MmuY3/Yvalid) + 6.*muY1*muY1*(MmuY2/Yvalid) - 3.*muY1*muY1*muY1*muY1;
            }
          MmuXp1 = 0.; MmuXp2 = 0.; MmuXp3 = 0.; MmuXp4 = 0.;
          MmuYp1 = 0.; MmuYp2 = 0.; MmuYp3 = 0.; MmuYp4 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              Xp = (M_inX[NwinLM1S2+lig+k][NwinCM1S2+col+l] - muX1)/sqrt(muX2+eps);
              MmuXp1 += Xp*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              Yp = (M_inY[NwinLM1S2+lig+k][NwinCM1S2+col+l] - muY1)/sqrt(muY2+eps);
              MmuYp1 += Yp*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
          if (Xvalid != 0.) muXp1 = MmuXp1/Xvalid;
          if (Yvalid != 0.) muYp1 = MmuYp1/Yvalid;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              Xp = (M_inX[NwinLM1S2+lig+k][NwinCM1S2+col+l] - muX1)/sqrt(muX2+eps);
              MmuXp2 += (Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuXp3 += (Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuXp4 += (Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              Yp = (M_inY[NwinLM1S2+lig+k][NwinCM1S2+col+l] - muY1)/sqrt(muY2+eps);
              MmuYp2 += (Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuYp3 += (Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              MmuYp4 += (Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
          if (Xvalid != 0.) {muXp2 = MmuXp2/Xvalid; muXp3 = MmuXp3/Xvalid; muXp4 = MmuXp4/Xvalid;}
          if (Yvalid != 0.) {muYp2 = MmuYp2/Yvalid; muYp3 = MmuYp3/Yvalid; muYp4 = MmuYp4/Yvalid;}
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            Xp = (M_inX[NwinLM1S2+lig+k][col-1] - muX1)/sqrt(muX2+eps);
            MmuXp2 -= (Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][col-1];
            MmuXp3 -= (Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][col-1];
            MmuXp4 -= (Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][col-1];
            Yp = (M_inY[NwinLM1S2+lig+k][col-1] - muY1)/sqrt(muY2+eps);
            MmuYp2 -= (Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][col-1];
            MmuYp3 -= (Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][col-1];
            MmuYp4 -= (Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][col-1];
            }
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            Xp = (M_inX[NwinLM1S2+lig+k][col-1] - muX1)/sqrt(muX2+eps);
            MmuXp1 -= Xp*Valid[NwinLM1S2+lig+k][col-1];
            Yp = (M_inY[NwinLM1S2+lig+k][col-1] - muY1)/sqrt(muY2+eps);
            MmuYp1 -= Yp*Valid[NwinLM1S2+lig+k][col-1];
            }
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            value = M_inX[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            MmuX1 -= value; MmuX2 -= value*value; MmuX3 -= value*value*value; MmuX4 -= value*value*value*value;
            Xvalid -= Valid[NwinLM1S2+lig+k][col-1];
            value = M_inY[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            MmuY1 -= value; MmuY2 -= value*value; MmuY3 -= value*value*value; MmuY4 -= value*value*value*value;
            Yvalid += Valid[NwinLM1S2+lig+k][col-1];
            value = M_inX[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuX1 += value; MmuX2 += value*value; MmuX3 += value*value*value; MmuX4 += value*value*value*value;
            Xvalid += Valid[NwinLM1S2+lig+k][NwinC-1+col];
            value = M_inY[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuY1 += value; MmuY2 += value*value; MmuY3 += value*value*value; MmuY4 += value*value*value*value;
            Yvalid += Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          if (Xvalid != 0.) muX1 = (MmuX1/Xvalid);
          if (Yvalid != 0.) muY1 = (MmuY1/Yvalid);
          if (Xvalid != 0.) {
            muX2 = (MmuX2/Xvalid) - muX1*muX1;
//            muX3 = (MmuX3/Xvalid) - 3.*muX1*(MmuX2/Xvalid) + 2.*muX1*muX1*muX1;
//            muX4 = (MmuX4/Xvalid) - 4.*muX1*(MmuX3/Xvalid) + 6.*muX1*muX1*(MmuX2/Xvalid) - 3.*muX1*muX1*muX1*muX1;
            muY2 = (MmuY2/Yvalid) - muY1*muY1;
//            muY3 = (MmuY3/Yvalid) - 3.*muY1*(MmuY2/Yvalid) + 2.*muY1*muY1*muY1;
//            muY4 = (MmuY4/Yvalid) - 4.*muY1*(MmuY3/Yvalid) + 6.*muY1*muY1*(MmuY2/Yvalid) - 3.*muY1*muY1*muY1*muY1;
            }
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            Xp = (M_inX[NwinLM1S2+lig+k][NwinC-1+col] - muX1)/sqrt(muX2+eps);
            MmuXp1 -= Xp*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            Yp = (M_inY[NwinLM1S2+lig+k][NwinC-1+col] - muY1)/sqrt(muY2+eps);
            MmuYp1 -= Yp*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          if (Xvalid != 0.) muXp1 = MmuXp1/Xvalid;
          if (Yvalid != 0.) muYp1 = MmuYp1/Yvalid;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            Xp = (M_inX[NwinLM1S2+lig+k][NwinC-1+col] - muX1)/sqrt(muX2+eps);
            MmuXp2 -= (Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuXp3 -= (Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuXp4 -= (Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*(Xp-muXp1)*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            Yp = (M_inY[NwinLM1S2+lig+k][NwinC-1+col] - muY1)/sqrt(muY2+eps);
            MmuYp2 -= (Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuYp3 -= (Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            MmuYp4 -= (Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*(Yp-muYp1)*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          if (Xvalid != 0.) {muXp2 = MmuXp2/Xvalid; muXp3 = MmuXp3/Xvalid; muXp4 = MmuXp4/Xvalid;}
          if (Yvalid != 0.) {muYp2 = MmuYp2/Yvalid; muYp3 = MmuYp3/Yvalid; muYp4 = MmuYp4/Yvalid;}          
          }

        kX1 = muX1;
        kY1 = muY1;
        kX2 = muX2 - muX1*muX1;
        kY2 = muY2 - muY1*muY1;
//        kX3 = muX3 - 3.*muX2*muX1 + 2.*muX1*muX1*muX1;
//        kY3 = muY3 - 3.*muY2*muY1 + 2.*muY1*muY1*muY1;
//        kX4 = muX4 - 4.*muX3*muX1 - 3.*muX2*muX2 + 12.*muX2*muX1*muX1 - 6.*muX1*muX1*muX1*muX1;
//        kY4 = muY4 - 4.*muY3*muY1 - 3.*muY2*muY2 + 12.*muY2*muY1*muY1 - 6.*muY1*muY1*muY1*muY1;

//        kXp1 = muXp1;
//        kYp1 = muYp1;
//        kXp2 = muXp2 - muXp1*muXp1;
//        kYp2 = muYp2 - muYp1*muYp1;
        kXp3 = muXp3 - 3.*muXp2*muXp1 + 2.*muXp1*muXp1*muXp1;
        kYp3 = muYp3 - 3.*muYp2*muYp1 + 2.*muYp1*muYp1*muYp1;
        kXp4 = muXp4 - 4.*muXp3*muXp1 - 3.*muXp2*muXp2 + 12.*muXp2*muXp1*muXp1 - 6.*muXp1*muXp1*muXp1*muXp1;
        kYp4 = muYp4 - 4.*muYp3*muYp1 - 3.*muYp2*muYp2 + 12.*muYp2*muYp1*muYp1 - 6.*muYp1*muYp1*muYp1*muYp1;
        
        // Calcul de KLXY 
        alp = (kX1-kY1)/kY2; bet = sqrt(kX2)/kY2;
        
        c2 = alp*alp+bet*bet;
        c3 = alp*alp*alp+3.*alp*bet*bet;
        c4 = alp*alp*alp*alp+6.*alp*alp*bet*bet+3.*bet*bet*bet*bet;
        c6 = alp*alp*alp*alp*alp*alp+15.*alp*alp*alp*alp*bet*bet+45.*alp*alp*bet*bet*bet*bet+15.*bet*bet*bet*bet*bet*bet;

        a1 = c3 - 3.*alp/kY2;
        a2 = c4 - 6.*(c2/kY2) + 3./(kY2*kY2);
        a3 = c6 - 15.*(c4/kY2) + 45.*c2/(kY2*kY2) - 15./(kY2*kY2*kY2);

        KLXY = (1./12.)*kXp3*kXp3/(kX2*kX2);
        KLXY += 0.5*(log(kY2/kX2)-1.-(kX1-kY1+sqrt(kX2))*(kX1-kY1+sqrt(kX2))/kY2);
        KLXY += -(a1*kYp3/6. + a2*kYp4/24. + a3*kYp3*kYp3/72.);
        KLXY += -0.5*(kYp3*kYp3/36.)*(c6 - 6.*c4/kX2 + 9.*c2/(kY2*kY2));
        KLXY += -10.*kXp3*kYp3*(kX1-kY1)*(kX2-kY2)/(kY2*kY2*kY2*kY2*kY2*kY2);

        // Calcul de KLYX 
        alp = (kY1-kX1)/kX2; bet = sqrt(kY2)/kX2;
        
        c2 = alp*alp+bet*bet;
        c3 = alp*alp*alp+3.*alp*bet*bet;
        c4 = alp*alp*alp*alp+6.*alp*alp*bet*bet+3.*bet*bet*bet*bet;
        c6 = alp*alp*alp*alp*alp*alp+15.*alp*alp*alp*alp*bet*bet+45.*alp*alp*bet*bet*bet*bet+15.*bet*bet*bet*bet*bet*bet;

        a1 = c3 - 3.*alp/kX2;
        a2 = c4 - 6.*(c2/kX2) + 3./(kX2*kX2);
        a3 = c6 - 15.*(c4/kX2) + 45.*c2/(kX2*kX2) - 15./(kX2*kX2*kX2);

        KLYX = (1./12.)*kYp3*kYp3/(kY2*kY2);
        KLYX += 0.5*(log(kX2/kY2)-1.-(kY1-kX1+sqrt(kY2))*(kY1-kX1+sqrt(kY2))/kX2);
        KLYX += -(a1*kXp3/6. + a2*kXp4/24. + a3*kXp3*kXp3/72.);
        KLYX += -0.5*(kXp3*kXp3/36.)*(c6 - 6.*c4/kY2 + 9.*c2/(kX2*kX2));
        KLYX += -10.*kYp3*kXp3*(kY1-kX1)*(kY2-kX2)/(kX2*kX2*kX2*kX2*kX2*kX2);

        M_out[lig][col] = KLXY + KLYX;    
        }
      }
    }

  write_block_matrix_float(fileoutput, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(M_in, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  if (strcmp(InputFormat,"cmplx")==0) free_matrix_float(bufferdatacmplx,NligBlock[0] + NwinL);
  if (strcmp(InputFormat,"float")==0) free_matrix_float(bufferdatafloat,NligBlock[0] + NwinL);
  if (strcmp(InputFormat,"int")==0) free_matrix_int(bufferdataint,NligBlock[0] + NwinL);
  free_vector_float(mediandata);

*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
   fclose(fileoutput);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(fileinputX);
  fclose(fileinputY);

/********************************************************************
********************************************************************/

  return 1;
}


