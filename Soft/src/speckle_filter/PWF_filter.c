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

File   : PWF_filter.c
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

Description :  Polarimetric Whitening speckle filter

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

#define NPolType 7
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "C3", "C4", "T2", "T3", "T4"};

  FILE *out_file_pwf;
  char file_pwf[FilePathLength];

/* Internal variables */
  int ii, lig, col, k, l;
  int ligDone = 0;
  int idxY;

/* Matrix arrays */
  float ***M_in;
  float **M_out;
  float ***C;
  float ***cov;
  float ***cov_m1;
  float *mean;
  float *buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPWF_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
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

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"S2")==0) strcpy(PolType, "S2C3");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_pwf, "%s%s", out_dir, "PWF.bin");
  if ((out_file_pwf = fopen(file_pwf, "wb")) == NULL)
    edit_error("Could not open input file : ", file_pwf);

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

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* mean = NpolarOut */
  NBlockB += NpolarOut;
  /* C = 4x4x2 */
  NBlockB += 4*4*2;
  /* cov = 4x4x2 */
  NBlockB += 4*4*2;
  /* covm1 = 4x4x2 */
  NBlockB += 4*4*2;
  /* buffer = NpolarOut */
  NBlockB += NpolarOut;
  
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
  M_out = matrix_float(NligBlock[0], Sub_Ncol);
  /*
  mean = vector_float(NpolarOut);
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
    C = matrix3d_float(2, 2, 2);
    cov = matrix3d_float(2, 2, 2);
    cov_m1 = matrix3d_float(2, 2, 2);
    }                  
  if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
    C = matrix3d_float(2, 2, 2);
    cov = matrix3d_float(2, 2, 2);
    cov_m1 = matrix3d_float(2, 2, 2);
    }                  
  if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
    C = matrix3d_float(3, 3, 2);
    cov = matrix3d_float(3, 3, 2);
    cov_m1 = matrix3d_float(3, 3, 2);
    }                  
  if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    C = matrix3d_float(4, 4, 2);
    cov = matrix3d_float(4, 4, 2);
    cov_m1 = matrix3d_float(4, 4, 2);
    }                  

  buffer = vector_float(NpolarOut);
  */

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
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {

    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, Np, k, l, Nvalid, mean, buffer, idxY, cov, cov_m1, C) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    mean = vector_float(NpolarOut);
    buffer = vector_float(NpolarOut);
    if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
      C = matrix3d_float(2, 2, 2);
      cov = matrix3d_float(2, 2, 2);
      cov_m1 = matrix3d_float(2, 2, 2);
      }                  
    if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
      C = matrix3d_float(2, 2, 2);
      cov = matrix3d_float(2, 2, 2);
      cov_m1 = matrix3d_float(2, 2, 2);
      }                  
    if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
      C = matrix3d_float(3, 3, 2);
      cov = matrix3d_float(3, 3, 2);
      cov_m1 = matrix3d_float(3, 3, 2);
      }                  
    if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
      C = matrix3d_float(4, 4, 2);
      cov = matrix3d_float(4, 4, 2);
      cov_m1 = matrix3d_float(4, 4, 2);
      }                  
    Nvalid = 0.;
    for (col = 0; col < Sub_Ncol; col++) {
      if (col == 0) {
        Nvalid = 0.;
        //for (Np = 0; Np < NpolarOut; Np++) buffer[Np] = 0.;
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++) buffer[Np] += M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid += Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          idxY = NwinLM1S2+lig+k;
          for (Np = 0; Np < NpolarOut; Np++) {
            buffer[Np] = buffer[Np] - M_in[Np][idxY][col-1]*Valid[idxY][col-1];
            buffer[Np] = buffer[Np] + M_in[Np][idxY][NwinC-1+col]*Valid[idxY][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[idxY][col-1] + Valid[idxY][NwinC-1+col];
          }
        }
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) mean[Np] = buffer[Np]/Nvalid;

      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)
          ||(strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
          cov[0][0][0] = eps + mean[0]; cov[0][0][1] = 0.;
          cov[0][1][0] = eps + mean[1]; cov[0][1][1] = eps + mean[2];
          cov[1][0][0] = cov[0][1][0]; cov[1][0][1] = -cov[0][1][1];
          cov[1][1][0] = eps + mean[3]; cov[1][1][1] = 0.;

          InverseHermitianMatrix2(cov, cov_m1);

          /*BoxCar Pixel centre */
          C[0][0][0] = eps + M_in[0][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][0][1] = 0.;
          C[0][1][0] = eps + M_in[1][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][1][1] = eps + M_in[2][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][0][0] = C[0][1][0];
          C[1][0][1] = -C[0][1][1];
          C[1][1][0] = eps + M_in[3][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][1][1] = 0.;

          /* PWF Filter : Trace(Coh_m1*C) */
          M_out[lig][col] = Trace2_HM1xHM2(cov_m1, C);
          }
        if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
          cov[0][0][0] = eps + mean[0]; cov[0][0][1] = 0.;
          cov[0][1][0] = eps + mean[1]; cov[0][1][1] = eps + mean[2];
          cov[0][2][0] = eps + mean[3]; cov[0][2][1] = eps + mean[4];
          cov[1][0][0] = cov[0][1][0]; cov[1][0][1] = -cov[0][1][1];
          cov[1][1][0] = eps + mean[5]; cov[1][1][1] = 0.;
          cov[1][2][0] = eps + mean[6]; cov[1][2][1] = eps + mean[7];
          cov[2][0][0] = cov[0][2][0]; cov[2][0][1] = - cov[0][2][1];
          cov[2][1][0] = cov[1][2][0]; cov[2][1][1] = - cov[1][2][1];
          cov[2][2][0] = eps + mean[8]; cov[2][2][1] = 0.;

          InverseHermitianMatrix3(cov, cov_m1);

          /*BoxCar Pixel centre */
          C[0][0][0] = eps + M_in[0][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][0][1] = 0.;
          C[0][1][0] = eps + M_in[1][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][1][1] = eps + M_in[2][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][2][0] = eps + M_in[3][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][2][1] = eps + M_in[4][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][0][0] = C[0][1][0];
          C[1][0][1] = - C[0][1][1];
          C[1][1][0] = eps + M_in[5][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][1][1] = 0.; 
          C[1][2][0] = eps + M_in[6][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][2][1] = eps + M_in[7][NwinLM1S2+lig][NwinCM1S2+col];
          C[2][0][0] = C[0][2][0];
          C[2][0][1] = - C[0][2][1];
          C[2][1][0] = C[1][2][0];
          C[2][1][1] = - C[1][2][1];
          C[2][2][0] = eps + M_in[8][NwinLM1S2+lig][NwinCM1S2+col];
          C[2][2][1] = 0.;

          /* PWF Filter : Trace(Coh_m1*C) */
          M_out[lig][col] = Trace3_HM1xHM2(cov_m1, C);
          }
        if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
          cov[0][0][0] = eps + mean[0]; cov[0][0][1] = 0.;
          cov[0][1][0] = eps + mean[1]; cov[0][1][1] = eps + mean[2];
          cov[0][2][0] = eps + mean[3]; cov[0][2][1] = eps + mean[4];
          cov[0][3][0] = eps + mean[5]; cov[0][2][1] = eps + mean[6];
          cov[1][0][0] = cov[0][1][0]; cov[1][0][1] = -cov[0][1][1];
          cov[1][1][0] = eps + mean[7]; cov[1][1][1] = 0.;
          cov[1][2][0] = eps + mean[8]; cov[1][2][1] = eps + mean[9];
          cov[1][3][0] = eps + mean[10]; cov[1][2][1] = eps + mean[11];
          cov[2][0][0] = cov[0][2][0]; cov[2][0][1] = - cov[0][2][1];
          cov[2][1][0] = cov[1][2][0]; cov[2][1][1] = - cov[1][2][1];
          cov[2][2][0] = eps + mean[12]; cov[2][2][1] = 0.;
          cov[2][3][0] = eps + mean[13]; cov[2][2][1] = eps + mean[14];
          cov[3][0][0] = cov[0][3][0]; cov[3][0][1] = - cov[0][3][1];
          cov[3][1][0] = cov[1][3][0]; cov[3][1][1] = - cov[1][3][1];
          cov[3][2][0] = cov[2][3][0]; cov[3][2][1] = - cov[2][3][1];
          cov[3][3][0] = eps + mean[15]; cov[3][3][1] = 0.;

          InverseHermitianMatrix4(cov, cov_m1);

          /*BoxCar Pixel centre */
          C[0][0][0] = eps + M_in[0][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][0][1] = 0.;
          C[0][1][0] = eps + M_in[1][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][1][1] = eps + M_in[2][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][2][0] = eps + M_in[3][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][2][1] = eps + M_in[4][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][3][0] = eps + M_in[5][NwinLM1S2+lig][NwinCM1S2+col];
          C[0][3][1] = eps + M_in[6][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][0][0] = C[0][1][0];
          C[1][0][1] = - C[0][1][1];
          C[1][1][0] = eps + M_in[7][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][1][1] = 0.; 
          C[1][2][0] = eps + M_in[8][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][2][1] = eps + M_in[9][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][3][0] = eps + M_in[10][NwinLM1S2+lig][NwinCM1S2+col];
          C[1][3][1] = eps + M_in[11][NwinLM1S2+lig][NwinCM1S2+col];
          C[2][0][0] = C[0][2][0];
          C[2][0][1] = - C[0][2][1];
          C[2][1][0] = C[1][2][0];
          C[2][1][1] = - C[1][2][1];
          C[2][2][0] = eps + M_in[12][NwinLM1S2+lig][NwinCM1S2+col];
          C[2][2][1] = 0.;
          C[2][3][0] = eps + M_in[13][NwinLM1S2+lig][NwinCM1S2+col];
          C[2][3][1] = eps + M_in[14][NwinLM1S2+lig][NwinCM1S2+col];
          C[3][0][0] = C[0][3][0];
          C[3][0][1] = - C[0][3][1];
          C[3][1][0] = C[1][3][0];
          C[3][1][1] = - C[1][3][1];
          C[3][2][0] = C[2][3][0];
          C[3][2][1] = - C[2][3][1];
          C[3][3][0] = eps + M_in[15][NwinLM1S2+lig][NwinCM1S2+col];
          C[3][3][1] = 0.;

          /* PWF Filter : Trace(Coh_m1*C) */
          M_out[lig][col] = Trace4_HM1xHM2(cov_m1, C);
          } 
        } else {
        M_out[lig][col] = 0.;
        }
      }
    free_vector_float(buffer);
    free_vector_float(mean);      
    if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
      free_matrix3d_float(C, 2, 2);
      free_matrix3d_float(cov, 2, 2);
      free_matrix3d_float(cov_m1, 2, 2);
      }                  
    if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
      free_matrix3d_float(C, 2, 2);
      free_matrix3d_float(cov, 2, 2);
      free_matrix3d_float(cov_m1, 2, 2);
      }                  
    if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
      free_matrix3d_float(C, 3, 3);
      free_matrix3d_float(cov, 3, 3);
      free_matrix3d_float(cov_m1, 3, 3);
      }                  
    if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
      free_matrix3d_float(C, 4, 4);
      free_matrix3d_float(cov, 4, 4);
      free_matrix3d_float(cov_m1, 4, 4);
      }                    
    }

  write_block_matrix_float(out_file_pwf, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  free_vector_float(mean);
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)
    ||(strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
    free_matrix3d_float(C, 2, 2);
    free_matrix3d_float(cov, 2, 2);
    free_matrix3d_float(cov_m1, 2, 2);
    }                  
  if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
    free_matrix3d_float(C, 3, 3);
    free_matrix3d_float(cov, 3, 3);
    free_matrix3d_float(cov_m1, 3, 3);
    }                  
  if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    free_matrix3d_float(C, 4, 4);
    free_matrix3d_float(cov, 4, 4);
    free_matrix3d_float(cov_m1, 4, 4);
    }
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file_pwf);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


