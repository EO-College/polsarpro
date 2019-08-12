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

File   : file_nagao.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 08/2015
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

Description :  File (nagao) = File

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
  FILE *in_file, *out_file;
  char file_in[FilePathLength], file_out[FilePathLength];  
  
/* Internal variables */
  int k,l,lig, col;
  float Nvalid11, Nvalid12, Nvalid13;
  float Nvalid21, Nvalid22, Nvalid23;
  float Nvalid31, Nvalid32, Nvalid33;
  float mean11, mean211; float mean12, mean212; float mean13, mean213;
  float mean21, mean221; float mean22, mean222; float mean23, mean223;
  float mean31, mean231; float mean32, mean232; float mean33, mean233;
  float Mmean11, Mmean211; float Mmean12, Mmean212; float Mmean13, Mmean213;
  float Mmean21, Mmean221; float Mmean22, Mmean222; float Mmean23, Mmean223;
  float Mmean31, Mmean231; float Mmean32, Mmean232; float Mmean33, Mmean233;
  float mean, mean2;

  int NNwinLM1S2, NNwinL;
  int NNwinCM1S2, NNwinC;
  
/* Matrix arrays */
  float **M_in;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfile_nagao.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file name\n");
strcat(UsageHelp," (string)	-of  	output file name\n");
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

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
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
  }

/********************************************************************
********************************************************************/

  check_file(file_in);
  check_file(file_out);
  if (FlagValid == 1) check_file(file_valid);

  if (NwinL < 5) NwinL = 5;
  if (NwinC < 5) NwinC = 5;
  
  NNwinL = NwinL - 2;
  NNwinC = NwinC - 2;
  NNwinLM1S2 = (NNwinL - 1) / 2;
  NNwinCM1S2 = (NNwinC - 1) / 2;

  NpolarIn = 1; NpolarOut = 1;
  Nlig = Sub_Nlig; Ncol = Sub_Ncol;
  
/********************************************************************
********************************************************************/
/* INPUT FILE OPENING*/
  if ((in_file = fopen(file_in, "rb")) == NULL)
    edit_error("Could not open input file : ", file_in);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((out_file = fopen(file_out, "wb")) == NULL)
    edit_error("Could not open input file : ", file_out);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask = (Nlig+NwinL)*(Ncol+NwinC) */ 
  NBlockA += Ncol+NwinC; NBlockB += NwinL*(Ncol+NwinC);

  /* Min1 = (Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += (Ncol+NwinC); NBlockB += NwinL*(Ncol+NwinC);
  /* Mout = Sub_Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
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

  M_in = matrix_float(NligBlock[0] + NwinL, Ncol + NwinC);
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

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file, M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

Nvalid11 = Nvalid12 = Nvalid13 = 0.;
Nvalid21 = Nvalid22 = Nvalid23 = 0.;
Nvalid31 = Nvalid32 = Nvalid33 = 0.;
mean11 = mean211 = mean12 = mean212 = mean13 = mean213 = 0.;
mean21 = mean221 = mean22 = mean222 = mean23 = mean223 = 0.;
mean31 = mean231 = mean32 = mean232 = mean33 = mean233 = 0.;
Mmean11 = Mmean211 = Mmean12 = Mmean212 = Mmean13 = Mmean213 = 0.;
Mmean21 = Mmean221 = Mmean22 = Mmean222 = Mmean23 = Mmean223 = 0.;
Mmean31 = Mmean231 = Mmean32 = Mmean232 = Mmean33 = Mmean233 = 0.;
mean = mean2 = 0.;
#pragma omp parallel for private(col, k, l) firstprivate(Nvalid11, Nvalid12, Nvalid13, Nvalid21, Nvalid22, Nvalid23, Nvalid31, Nvalid32, Nvalid33, mean11, mean211, mean12, mean212, mean13, mean213, mean21, mean221, mean22, mean222, mean23, mean223, mean31, mean231, mean32, mean232, mean33, mean233, Mmean11, Mmean211, Mmean12, Mmean212, Mmean13, Mmean213, Mmean21, Mmean221, Mmean22, Mmean222, Mmean23, Mmean223, Mmean31, Mmean231, Mmean32, Mmean232, Mmean33, Mmean233, mean, mean2)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (col == 0) {
        Nvalid11 = 0., Nvalid12 = 0., Nvalid13 = 0.;
        Nvalid21 = 0., Nvalid22 = 0., Nvalid23 = 0.;
        Nvalid31 = 0., Nvalid32 = 0., Nvalid33 = 0.;
        mean11 = 0.; mean211 = 0.; mean12 = 0.; mean212 = 0.; mean13 = 0.; mean213 = 0.;
        mean21 = 0.; mean221 = 0.; mean22 = 0.; mean222 = 0.; mean23 = 0.; mean223 = 0.;
        mean31 = 0.; mean231 = 0.; mean32 = 0.; mean232 = 0.; mean33 = 0.; mean233 = 0.;
        Mmean11 = 0.; Mmean211 = 0.; Mmean12 = 0.; Mmean212 = 0.; Mmean13 = 0.; Mmean213 = 0.;
        Mmean21 = 0.; Mmean221 = 0.; Mmean22 = 0.; Mmean222 = 0.; Mmean23 = 0.; Mmean223 = 0.;
        Mmean31 = 0.; Mmean231 = 0.; Mmean32 = 0.; Mmean232 = 0.; Mmean33 = 0.; Mmean233 = 0.;
        for (k = -NNwinLM1S2; k < 1 + NNwinLM1S2; k++)
          for (l = -NNwinCM1S2; l < 1 +NNwinCM1S2; l++) {
            mean11 = mean11 + M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col)+l]*Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col)+l];
            Nvalid11 = Nvalid11 + Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col)+l];
            mean12 = mean12 + M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+1)+l]*Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+1)+l];
            Nvalid12 = Nvalid12 + Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+1)+l];
            mean13 = mean13 + M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+2)+l]*Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+2)+l];
            Nvalid13 = Nvalid13 + Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+2)+l];

            mean21 = mean21 + M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col)+l]*Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col)+l];
            Nvalid21 = Nvalid21 + Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col)+l];
            mean22 = mean22 + M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+1)+l]*Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+1)+l];
            Nvalid22 = Nvalid22 + Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+1)+l];
            mean23 = mean23 + M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+2)+l]*Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+2)+l];
            Nvalid23 = Nvalid23 + Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+2)+l];

            mean31 = mean31 + M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col)+l]*Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col)+l];
            Nvalid31 = Nvalid31 + Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col)+l];
            mean32 = mean32 + M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+1)+l]*Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+1)+l];
            Nvalid32 = Nvalid32 + Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+1)+l];
            mean33 = mean33 + M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+2)+l]*Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+2)+l];
            Nvalid33 = Nvalid33 + Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+2)+l];
            }
        Mmean11 = mean11 / Nvalid11; Mmean12 = mean12 / Nvalid12; Mmean13 = mean13 / Nvalid13; 
        Mmean21 = mean21 / Nvalid21; Mmean22 = mean22 / Nvalid22; Mmean23 = mean23 / Nvalid23; 
        Mmean31 = mean31 / Nvalid31; Mmean32 = mean32 / Nvalid32; Mmean33 = mean33 / Nvalid33; 
        for (k = -NNwinLM1S2; k < 1 + NNwinLM1S2; k++)
          for (l = -NNwinCM1S2; l < 1 +NNwinCM1S2; l++) {
            mean211 = mean211 + (M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col)+l]-Mmean11)*(M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col)+l]-Mmean11)*Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col)+l];
            mean212 = mean212 + (M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+1)+l]-Mmean12)*(M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+1)+l]-Mmean12)*Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+1)+l];
            mean213 = mean213 + (M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+2)+l]-Mmean13)*(M_in[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+2)+l]-Mmean13)*Valid[NNwinLM1S2+(lig)+k][NNwinCM1S2+(col+2)+l];

            mean221 = mean221 + (M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col)+l]-Mmean21)*(M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col)+l]-Mmean21)*Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col)+l];
            mean222 = mean222 + (M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+1)+l]-Mmean22)*(M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+1)+l]-Mmean22)*Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+1)+l];
            mean223 = mean223 + (M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+2)+l]-Mmean23)*(M_in[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+2)+l]-Mmean23)*Valid[NNwinLM1S2+(lig+1)+k][NNwinCM1S2+(col+2)+l];

            mean231 = mean231 + (M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col)+l]-Mmean31)*(M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col)+l]-Mmean31)*Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col)+l];
            mean232 = mean232 + (M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+1)+l]-Mmean32)*(M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+1)+l]-Mmean32)*Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+1)+l];
            mean233 = mean233 + (M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+2)+l]-Mmean33)*(M_in[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+2)+l]-Mmean33)*Valid[NNwinLM1S2+(lig+2)+k][NNwinCM1S2+(col+2)+l];
            }
        if (Nvalid11 != 1.) Mmean211 = mean211 / (Nvalid11-1); else Mmean211 = INIT_MINMAX;
        if (Nvalid12 != 1.) Mmean212 = mean212 / (Nvalid12-1); else Mmean212 = INIT_MINMAX;
        if (Nvalid13 != 1.) Mmean213 = mean213 / (Nvalid13-1); else Mmean213 = INIT_MINMAX;
        if (Nvalid21 != 1.) Mmean221 = mean221 / (Nvalid21-1); else Mmean221 = INIT_MINMAX;
        if (Nvalid22 != 1.) Mmean222 = mean222 / (Nvalid22-1); else Mmean222 = INIT_MINMAX;
        if (Nvalid23 != 1.) Mmean223 = mean223 / (Nvalid23-1); else Mmean223 = INIT_MINMAX;
        if (Nvalid31 != 1.) Mmean231 = mean231 / (Nvalid31-1); else Mmean231 = INIT_MINMAX;
        if (Nvalid32 != 1.) Mmean232 = mean232 / (Nvalid32-1); else Mmean232 = INIT_MINMAX;
        if (Nvalid33 != 1.) Mmean233 = mean233 / (Nvalid33-1); else Mmean233 = INIT_MINMAX;
        } else {
        Mmean11 = Mmean12; Mmean211 = Mmean212; Nvalid11 = Nvalid12; Mmean12 = Mmean13; Mmean212 = Mmean213; Nvalid12 = Nvalid13; 
        Mmean21 = Mmean22; Mmean221 = Mmean222; Nvalid21 = Nvalid22; Mmean22 = Mmean23; Mmean222 = Mmean223; Nvalid22 = Nvalid23; 
        Mmean31 = Mmean32; Mmean231 = Mmean232; Nvalid31 = Nvalid32; Mmean32 = Mmean33; Mmean232 = Mmean233; Nvalid32 = Nvalid33; 
        mean213 += mean13*Mmean13;
        mean223 += mean23*Mmean23;
        mean233 += mean33*Mmean33;
        for (k = -NNwinLM1S2; k < 1 + NNwinLM1S2; k++) {
          mean213 -= M_in[NNwinLM1S2+(lig)+k][(col+2)-1]*M_in[NNwinLM1S2+(lig)+k][(col+2)-1]*Valid[NNwinLM1S2+(lig)+k][(col+2)-1];
          mean223 -= M_in[NNwinLM1S2+(lig+1)+k][(col+2)-1]*M_in[NNwinLM1S2+(lig+1)+k][(col+2)-1]*Valid[NNwinLM1S2+(lig+1)+k][(col+2)-1];
          mean233 -= M_in[NNwinLM1S2+(lig+2)+k][(col+2)-1]*M_in[NNwinLM1S2+(lig+2)+k][(col+2)-1]*Valid[NNwinLM1S2+(lig+2)+k][(col+2)-1];
          }
        for (k = -NNwinLM1S2; k < 1 + NNwinLM1S2; k++) {
          mean13 -= M_in[NNwinLM1S2+(lig)+k][(col+2)-1]*Valid[NNwinLM1S2+(lig)+k][(col+2)-1];
          mean13 += M_in[NNwinLM1S2+(lig)+k][NNwinC-1+(col+2)]*Valid[NNwinLM1S2+(lig)+k][NNwinC-1+(col+2)];
          Nvalid13 = Nvalid13 - Valid[NNwinLM1S2+(lig)+k][(col+2)-1] + Valid[NNwinLM1S2+(lig)+k][NNwinC-1+(col+2)];
          mean23 -= M_in[NNwinLM1S2+(lig+1)+k][(col+2)-1]*Valid[NNwinLM1S2+(lig+1)+k][(col+2)-1];
          mean23 += M_in[NNwinLM1S2+(lig+1)+k][NNwinC-1+(col+2)]*Valid[NNwinLM1S2+(lig+1)+k][NNwinC-1+(col+2)];
          Nvalid23 = Nvalid23 - Valid[NNwinLM1S2+(lig+1)+k][(col+2)-1] + Valid[NNwinLM1S2+(lig+1)+k][NNwinC-1+(col+2)];
          mean33 -= M_in[NNwinLM1S2+(lig+2)+k][(col+2)-1]*Valid[NNwinLM1S2+(lig+2)+k][(col+2)-1];
          mean33 += M_in[NNwinLM1S2+(lig+2)+k][NNwinC-1+(col+2)]*Valid[NNwinLM1S2+(lig+2)+k][NNwinC-1+(col+2)];
          Nvalid33 = Nvalid13 - Valid[NNwinLM1S2+(lig+2)+k][(col+2)-1] + Valid[NNwinLM1S2+(lig+2)+k][NNwinC-1+(col+2)];
          }
        Mmean13 = mean13 / Nvalid13; 
        Mmean23 = mean23 / Nvalid23; 
        Mmean33 = mean33 / Nvalid33; 
        for (k = -NNwinLM1S2; k < 1 + NNwinLM1S2; k++) {
          mean213 += M_in[NNwinLM1S2+(lig)+k][NNwinC-1+(col+2)]*M_in[NNwinLM1S2+(lig)+k][NNwinC-1+(col+2)]*Valid[NNwinLM1S2+(lig)+k][NNwinC-1+(col+2)];
          mean223 += M_in[NNwinLM1S2+(lig+1)+k][NNwinC-1+(col+2)]*M_in[NNwinLM1S2+(lig+1)+k][NNwinC-1+(col+2)]*Valid[NNwinLM1S2+(lig+1)+k][NNwinC-1+(col+2)];
          mean233 += M_in[NNwinLM1S2+(lig+2)+k][NNwinC-1+(col+2)]*M_in[NNwinLM1S2+(lig+2)+k][NNwinC-1+(col+2)]*Valid[NNwinLM1S2+(lig+2)+k][NNwinC-1+(col+2)];
          }
        mean213 -= mean13*Mmean13;
        mean223 -= mean23*Mmean23;
        mean233 -= mean33*Mmean33;
        if (Nvalid13 != 1.) Mmean213 = mean213 / (Nvalid13-1); else Mmean213 = INIT_MINMAX;
        if (Nvalid23 != 1.) Mmean223 = mean223 / (Nvalid23-1); else Mmean223 = INIT_MINMAX;
        if (Nvalid33 != 1.) Mmean233 = mean233 / (Nvalid33-1); else Mmean233 = INIT_MINMAX;
        }
      mean = Mmean11; mean2 = Mmean211;
      if (Mmean212 < mean2) { mean = Mmean12; mean2 = Mmean212;}
      if (Mmean213 < mean2) { mean = Mmean13; mean2 = Mmean213;}
      if (Mmean221 < mean2) { mean = Mmean21; mean2 = Mmean221;}
      if (Mmean222 < mean2) { mean = Mmean22; mean2 = Mmean222;}
      if (Mmean223 < mean2) { mean = Mmean23; mean2 = Mmean223;}
      if (Mmean231 < mean2) { mean = Mmean31; mean2 = Mmean231;}
      if (Mmean232 < mean2) { mean = Mmean32; mean2 = Mmean232;}
      if (Mmean233 < mean2) { mean = Mmean33; mean2 = Mmean233;}
      M_out[lig][col] = mean;
      }
    }
  
  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(M_in, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0] + NwinL);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(in_file);
/********************************************************************
********************************************************************/

  return 1;
}


