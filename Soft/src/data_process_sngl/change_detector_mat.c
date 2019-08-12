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

File  : change_detector_mat.c
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

#define NPolType 8
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "C3", "C4", "T2", "T3", "T4", "SPP"};
  FILE *out_file;
  char file_out[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l, Npp;
  int ligDone = 0;

/* Matrix arrays */
  float **M_avg1;
  float **M_avg2;
  float ***M_in1;
  float ***M_in2;
  float **M_out;
  float ***M1;
  float *det1;
  float ***M2;
  float *det2;
  float ***M3;
  float *det3;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nchange_detector_mat.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id1 	input directory 1\n");
strcat(UsageHelp," (string)	-id2 	input directory 2\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-idf 	input data format\n");
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
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id1",str_cmd_prm,in_dir1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-id2",str_cmd_prm,in_dir2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,PolType,1,UsageHelp);
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
  check_file(file_out);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"S2")==0) strcpy(PolType, "S2T3");
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");

  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  file_name_in2 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  init_file_name(PolTypeIn, in_dir2, file_name_in2);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in1[Np]);

  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in2[Np]);

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
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min1 = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg1 = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  /* Min2 = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg2 = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;


  
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

  M_in1 = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  //M_avg1 = matrix_float(NpolarOut, Sub_Ncol);
  M_in2 = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  //M_avg2 = matrix_float(NpolarOut, Sub_Ncol);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

  if (strcmp(PolTypeOut,"C2")==0) Npp = 2;
  if (strcmp(PolTypeOut,"C3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"C4")==0) Npp = 4;
  if (strcmp(PolTypeOut,"T2")==0) Npp = 2;
  if (strcmp(PolTypeOut,"T3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"T4")==0) Npp = 4;

  //det1 = vector_float(2);
  //det2 = vector_float(2);
  //det3 = vector_float(2);
  //M1 = matrix3d_float(Npp, Npp, 2);
  //M2 = matrix3d_float(Npp, Npp, 2);
  //M3 = matrix3d_float(Npp, Npp, 2);
  
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

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in1, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      read_block_S2_noavg(in_datafile, M_in2, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in1, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      read_block_SPP_noavg(in_datafile, M_in2, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }
    } else {
    /* Case of C,T or I */
      read_block_TCI_noavg(in_datafile, M_in1, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      read_block_TCI_noavg(in_datafile, M_in2, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

#pragma omp parallel for private(col, k, l, M_avg1, M_avg2, det1, det2, det3, M1, M2, M3) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg1 = matrix_float(NpolarOut,Sub_Ncol);
    M_avg2 = matrix_float(NpolarOut,Sub_Ncol);
    det1 = vector_float(2);
    det2 = vector_float(2);
    det3 = vector_float(2);
    M1 = matrix3d_float(Npp, Npp, 2);
    M2 = matrix3d_float(Npp, Npp, 2);
    M3 = matrix3d_float(Npp, Npp, 2);
    average_TCI(M_in1, Valid, NpolarOut, M_avg1, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    average_TCI(M_in2, Valid, NpolarOut, M_avg2, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
          if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"T2")==0)) {
            M1[0][0][0] = eps + M_avg1[0][col];
            M1[0][0][1] = 0.;
            M1[0][1][0] = eps + M_avg1[1][col];
            M1[0][1][1] = eps + M_avg1[2][col];
            M1[1][0][0] =  M1[0][1][0];
            M1[1][0][1] = -M1[0][1][1];
            M1[1][1][0] = eps + M_avg1[3][col];
            M1[1][1][1] = 0.;
            DeterminantHermitianMatrix2(M1,det1);
            M2[0][0][0] = eps + M_avg2[0][col];
            M2[0][0][1] = 0.;
            M2[0][1][0] = eps + M_avg2[1][col];
            M2[0][1][1] = eps + M_avg2[2][col];
            M2[1][0][0] =  M2[0][1][0];
            M2[1][0][1] = -M2[0][1][1];
            M2[1][1][0] = eps + M_avg2[3][col];
            M2[1][1][1] = 0.;
            DeterminantHermitianMatrix2(M2,det2);
            for (k=0; k<Npp; k++) {
              for (l=0; l<Npp; l++) {
                M3[k][l][0] = M1[k][l][0] + M2[k][l][0];
                M3[k][l][1] = M1[k][l][1] + M2[k][l][1];
                }
              }
            DeterminantHermitianMatrix2(M3,det3);
            }
          if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
            M1[0][0][0] = eps + M_avg1[0][col];
            M1[0][0][1] = 0.;
            M1[0][1][0] = eps + M_avg1[1][col];
            M1[0][1][1] = eps + M_avg1[2][col];
            M1[0][2][0] = eps + M_avg1[3][col];
            M1[0][2][1] = eps + M_avg1[4][col];
            M1[1][0][0] =  M1[0][1][0];
            M1[1][0][1] = -M1[0][1][1];
            M1[1][1][0] = eps + M_avg1[5][col];
            M1[1][1][1] = 0.;
            M1[1][2][0] = eps + M_avg1[6][col];
            M1[1][2][1] = eps + M_avg1[7][col];
            M1[2][0][0] =  M1[0][2][0];
            M1[2][0][1] = -M1[0][2][1];
            M1[2][1][0] =  M1[1][2][0];
            M1[2][1][1] = -M1[1][2][1];
            M1[2][2][0] = eps + M_avg1[8][col];
            M1[2][2][1] = 0.;
            DeterminantHermitianMatrix3(M1,det1);
            M2[0][0][0] = eps + M_avg2[0][col];
            M2[0][0][1] = 0.;
            M2[0][1][0] = eps + M_avg2[1][col];
            M2[0][1][1] = eps + M_avg2[2][col];
            M2[0][2][0] = eps + M_avg2[3][col];
            M2[0][2][1] = eps + M_avg2[4][col];
            M2[1][0][0] =  M2[0][1][0];
            M2[1][0][1] = -M2[0][1][1];
            M2[1][1][0] = eps + M_avg2[5][col];
            M2[1][1][1] = 0.;
            M2[1][2][0] = eps + M_avg2[6][col];
            M2[1][2][1] = eps + M_avg2[7][col];
            M2[2][0][0] =  M2[0][2][0];
            M2[2][0][1] = -M2[0][2][1];
            M2[2][1][0] =  M2[1][2][0];
            M2[2][1][1] = -M2[1][2][1];
            M2[2][2][0] = eps + M_avg2[8][col];
            M2[2][2][1] = 0.;
            DeterminantHermitianMatrix3(M2,det2);
            for (k=0; k<Npp; k++) {
              for (l=0; l<Npp; l++) {
                M3[k][l][0] = M1[k][l][0] + M2[k][l][0];
                M3[k][l][1] = M1[k][l][1] + M2[k][l][1];
                }
              }
            DeterminantHermitianMatrix3(M3,det3);
            }
          if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
            M1[0][0][0] = eps + M_avg1[0][col];
            M1[0][0][1] = 0.;
            M1[0][1][0] = eps + M_avg1[1][col];
            M1[0][1][1] = eps + M_avg1[2][col];
            M1[0][2][0] = eps + M_avg1[3][col];
            M1[0][2][1] = eps + M_avg1[4][col];
            M1[0][3][0] = eps + M_avg1[5][col];
            M1[0][3][1] = eps + M_avg1[6][col];
            M1[1][0][0] =  M1[0][1][0];
            M1[1][0][1] = -M1[0][1][1];
            M1[1][1][0] = eps + M_avg1[7][col];
            M1[1][1][1] = 0.;
            M1[1][2][0] = eps + M_avg1[8][col];
            M1[1][2][1] = eps + M_avg1[9][col];
            M1[1][3][0] = eps + M_avg1[10][col];
            M1[1][3][1] = eps + M_avg1[11][col];
            M1[2][0][0] =  M1[0][2][0];
            M1[2][0][1] = -M1[0][2][1];
            M1[2][1][0] =  M1[1][2][0];
            M1[2][1][1] = -M1[1][2][1];
            M1[2][2][0] = eps + M_avg1[12][col];
            M1[2][2][1] = 0.;
            M1[2][3][0] = eps + M_avg1[13][col];
            M1[2][3][1] = eps + M_avg1[14][col];
            M1[3][0][0] =  M1[0][3][0];
            M1[3][0][1] = -M1[0][3][1];
            M1[3][1][0] =  M1[1][3][0];
            M1[3][1][1] = -M1[1][3][1];
            M1[3][2][0] =  M1[2][3][0];
            M1[3][2][1] = -M1[2][3][1];
            M1[3][3][0] = eps + M_avg1[15][col];
            M1[3][3][1] = 0.;
            DeterminantHermitianMatrix4(M1,det1);
            M2[0][0][0] = eps + M_avg2[0][col];
            M2[0][0][1] = 0.;
            M2[0][1][0] = eps + M_avg2[1][col];
            M2[0][1][1] = eps + M_avg2[2][col];
            M2[0][2][0] = eps + M_avg2[3][col];
            M2[0][2][1] = eps + M_avg2[4][col];
            M2[0][3][0] = eps + M_avg2[5][col];
            M2[0][3][1] = eps + M_avg2[6][col];
            M2[1][0][0] =  M2[0][1][0];
            M2[1][0][1] = -M2[0][1][1];
            M2[1][1][0] = eps + M_avg2[7][col];
            M2[1][1][1] = 0.;
            M2[1][2][0] = eps + M_avg2[8][col];
            M2[1][2][1] = eps + M_avg2[9][col];
            M2[1][3][0] = eps + M_avg2[10][col];
            M2[1][3][1] = eps + M_avg2[11][col];
            M2[2][0][0] =  M2[0][2][0];
            M2[2][0][1] = -M2[0][2][1];
            M2[2][1][0] =  M2[1][2][0];
            M2[2][1][1] = -M2[1][2][1];
            M2[2][2][0] = eps + M_avg2[12][col];
            M2[2][2][1] = 0.;
            M2[2][3][0] = eps + M_avg2[13][col];
            M2[2][3][1] = eps + M_avg2[14][col];
            M2[3][0][0] =  M2[0][3][0];
            M2[3][0][1] = -M2[0][3][1];
            M2[3][1][0] =  M2[1][3][0];
            M2[3][1][1] = -M2[1][3][1];
            M2[3][2][0] =  M2[2][3][0];
            M2[3][2][1] = -M2[2][3][1];
            M2[3][3][0] = eps + M_avg2[15][col];
            M2[3][3][1] = 0.;
            DeterminantHermitianMatrix4(M2,det2);
            for (k=0; k<Npp; k++) {
              for (l=0; l<Npp; l++) {
                M3[k][l][0] = M1[k][l][0] + M2[k][l][0];
                M3[k][l][1] = M1[k][l][1] + M2[k][l][1];
                }
              }
            DeterminantHermitianMatrix4(M3,det3);
            }
        M_out[lig][col] = 2.*Npp*log(2.);
        M_out[lig][col] += log(sqrt(det1[0]*det1[0]+det1[1]*det1[1]));
        M_out[lig][col] += log(sqrt(det2[0]*det2[0]+det2[1]*det2[1]));
        M_out[lig][col] += log(sqrt(det3[0]*det3[0]+det3[1]*det3[1]));
        M_out[lig][col] = exp(NwinL*NwinC*M_out[lig][col]);
        } else {
        M_out[lig][col] = 0.;
        }
      }
    free_matrix_float(M_avg1,NpolarOut);
    free_matrix_float(M_avg2,NpolarOut);
    free_vector_float(det1);
    free_vector_float(det2);
    free_vector_float(det3);
    free_matrix3d_float(M1,Npp,Npp);
    free_matrix3d_float(M2,Npp,Npp);
    free_matrix3d_float(M3,Npp,Npp);
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg1, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_avg2, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
*/
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


