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

File  : h_a_alpha_decomposition.c
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

Description :  Cloude-Pottier eigenvector/eigenvalue based 
               decomposition

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

#define NPolType 12
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2T3", "S2C3", "S2T4", "S2C4", "SPPC2", "C2", "C3", "C3T3", "C4", "C4T4", "T3", "T4"};
  char file_name[FilePathLength];
  
/* Flag Parameters */
  int Flag[13], Nout, NPara;
  FILE *OutFile2[9], *OutFile3[11], *OutFile4[13];
  char *FileOut2[9] = {
  "alpha.bin", "delta.bin", "lambda.bin",
  "entropy.bin", "anisotropy.bin",
  "combination_HA.bin", "combination_H1mA.bin",
  "combination_1mHA.bin", "combination_1mH1mA.bin"};

  char *FileOut3[11] = {
  "alpha.bin", "beta.bin", "delta.bin",
  "gamma.bin", "lambda.bin",
  "entropy.bin", "anisotropy.bin",
  "combination_HA.bin", "combination_H1mA.bin",
  "combination_1mHA.bin", "combination_1mH1mA.bin"};
        
  char *FileOut4[13] = {
  "alpha.bin", "beta.bin", "epsilon.bin", "delta.bin",
  "gamma.bin", "nhu.bin", "lambda.bin",
  "entropy.bin", "anisotropy.bin",
  "combination_HA.bin", "combination_H1mA.bin",
  "combination_1mHA.bin", "combination_1mH1mA.bin" };

  int FlagPara, FlagLambda, FlagAlpha;
  int FlagEntropy, FlagAnisotropy;
  int FlagCombHA, FlagCombH1mA, FlagComb1mHA, FlagComb1mH1mA;

  int Alpha, Beta, Epsi, Delta, Gamma, Nhu, Lambda;
  int  H, A, CombHA, CombH1mA, Comb1mHA, Comb1mH1mA;

/* Internal variables */
  int ii, lig, col, k;
  int ligDone = 0;

  float alpha[4], beta[4], epsilon[4], delta[4], gamma[4], nhu[4], phase[4], p[4];

/* Matrix arrays */
  float **M_avg;
  float ***M_in;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_a_alpha_decomposition.exe\n");
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
strcat(UsageHelp," (int)   	-fl1 	Flag Parameters (0/1)\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Lambda (0/1)\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Alpha (0/1)\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Entropy (0/1)\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Anisotropy (0/1)\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Comb HA (0/1)\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Comb H1mA (0/1)\n");
strcat(UsageHelp," (int)   	-fl8 	Flag Comb 1mHA (0/1)\n");
strcat(UsageHelp," (int)   	-fl9 	Flag Comb 1mH1mA (0/1)\n");
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

if(argc < 37) {
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

  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagPara,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagLambda,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagAlpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagEntropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagAnisotropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagCombHA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagCombH1mA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagComb1mHA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagComb1mH1mA,1,UsageHelp);

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
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
    /* Decomposition parameters */
    Alpha = 0; Delta = 1; Lambda = 2;
    H = 3; A = 4; CombHA = 5; CombH1mA = 6; Comb1mHA = 7; Comb1mH1mA = 8;
  
    //M = matrix3d_float(2, 2, 2);
    //V = matrix3d_float(2, 2, 2);
    //lambda = vector_float(2);

    NPara = 9;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Parameters
    if (FlagPara == 1) {
      Flag[Alpha] = Nout; Nout++; Flag[Delta] = Nout; Nout++;
      Flag[Lambda] = Nout; Nout++;
      }
    }

  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) {
    /* Decomposition parameters */
    Alpha = 0; Beta = 1; Delta = 2; Gamma = 3; Lambda = 4;
    H = 5; A = 6; CombHA = 7; CombH1mA = 8; Comb1mHA = 9; Comb1mH1mA = 10;
  
    //M = matrix3d_float(3, 3, 2);
    //V = matrix3d_float(3, 3, 2);
    //lambda = vector_float(3);

    NPara = 11;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Parameters
    if (FlagPara == 1) {
      Flag[Alpha] = Nout; Nout++; Flag[Beta] = Nout; Nout++;
      Flag[Delta] = Nout; Nout++; Flag[Gamma] = Nout; Nout++;
      Flag[Lambda] = Nout; Nout++;
      }
    }

  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
    /* Decomposition parameters */
    Alpha = 0; Beta = 1; Epsi = 2; Delta = 3; Gamma = 4; Nhu = 5; Lambda = 6;
    H = 7; A = 8; CombHA = 9; CombH1mA = 10; Comb1mHA = 11; Comb1mH1mA = 12;

    //M = matrix3d_float(4, 4, 2);
    //V = matrix3d_float(4, 4, 2);
    //lambda = vector_float(4);

    NPara = 13;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Parameters
    if (FlagPara == 1) {
      Flag[Alpha] = Nout; Nout++; Flag[Beta] = Nout; Nout++; Flag[Epsi] = Nout; Nout++;
      Flag[Delta] = Nout; Nout++; Flag[Gamma] = Nout; Nout++; Flag[Nhu] = Nout; Nout++;
      Flag[Lambda] = Nout; Nout++;
      }
    }

  //Flag Lambda  (must keep the previous selection)
  if (FlagLambda == 1) {
    if (Flag[Lambda] == -1) { Flag[Lambda] = Nout; Nout++; }
    }
  //Flag Alpha  (must keep the previous selection)
  if (FlagAlpha == 1) {
    if (Flag[Alpha] == -1) { Flag[Alpha] = Nout; Nout++; }
    }
  //Flag Entropy
  if (FlagEntropy == 1) {
    Flag[H] = Nout; Nout++;
    }
  //Flag Anisotropy
  if (FlagAnisotropy == 1) {
    Flag[A] = Nout; Nout++;
    }
  //Flag Combinations HA
  if (FlagCombHA == 1) {
    Flag[CombHA] = Nout; Nout++;
    }
  if (FlagCombH1mA == 1) {
    Flag[CombH1mA] = Nout; Nout++;
    }
  if (FlagComb1mHA == 1) {
    Flag[Comb1mHA] = Nout; Nout++;
    }
  if (FlagComb1mH1mA == 1) {
    Flag[Comb1mH1mA] = Nout; Nout++;
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
        sprintf(file_name, "%s%s", out_dir, FileOut2[k]);
        if ((OutFile2[Flag[k]] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) {
        sprintf(file_name, "%s%s", out_dir, FileOut3[k]);
        if ((OutFile3[Flag[k]] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
        sprintf(file_name, "%s%s", out_dir, FileOut4[k]);
        if ((OutFile4[Flag[k]] = fopen(file_name, "wb")) == NULL)
          edit_error("Could not open input file : ", file_name);
        }
      }
    }

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

  /* Mout = Nout*Nlig*Sub_Ncol */
  NBlockA += Nout*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
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

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  //M_avg = matrix_float(NpolarOut, Sub_Ncol);
  M_out = matrix3d_float(Nout, NligBlock[0], Sub_Ncol);

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
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"T3")==0)) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);
  if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"T4")==0)) C4_to_T4(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
#pragma omp parallel for private(col, k, M, V, lambda, M_avg) firstprivate(alpha, delta, phase, p) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      M = matrix3d_float(2, 2, 2);
      V = matrix3d_float(2, 2, 2);
      lambda = vector_float(2);
      M_avg = matrix_float(NpolarOut,Sub_Ncol);
      average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
  
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
      
          M[0][0][0] = eps + M_avg[0][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][col];
          M[0][1][1] = eps + M_avg[2][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[3][col];
          M[1][1][1] = 0.;

          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(2, M, V, lambda);
  
          for (k = 0; k < 2; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 2; k++)  {
            alpha[k] = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
            phase[k] = atan2(V[0][k][1], eps + V[0][k][0]);
            delta[k] = atan2(V[1][k][1], eps + V[1][k][0]) - phase[k];
            delta[k] = atan2(sin(delta[k]), cos(delta[k]) + eps);
            /* Scattering mechanism probability of occurence */
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          /* Mean scattering mechanism */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = 0;
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] = 0;
          if (Flag[Lambda] != -1) M_out[Flag[Lambda]][lig][col] = 0; 
          if (Flag[H] != -1) M_out[Flag[H]][lig][col] = 0;
      
          for (k = 0; k < 2; k++) {
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] += alpha[k] * p[k];
            if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] += delta[k] * p[k];
            if (Flag[Lambda] != -1) M_out[Flag[Lambda]][lig][col] += lambda[k] * p[k];
            if (Flag[H] != -1) M_out[Flag[H]][lig][col] -= p[k] * log(p[k] + eps);
            }

          /* Scaling */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] *= 180. / pi;
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] *= 180. / pi;
          if (Flag[H] != -1) M_out[Flag[H]][lig][col] /= log(2.);

          if (Flag[A] != -1) M_out[Flag[A]][lig][col] = (p[0] - p[1]) / (p[0] + p[1] + eps);
  
          if (Flag[CombHA] != -1) M_out[Flag[CombHA]][lig][col] = M_out[Flag[H]][lig][col] * M_out[Flag[A]][lig][col];
          if (Flag[CombH1mA] != -1) M_out[Flag[CombH1mA]][lig][col] = M_out[Flag[H]][lig][col] * (1. - M_out[Flag[A]][lig][col]);
          if (Flag[Comb1mHA] != -1) M_out[Flag[Comb1mHA]][lig][col] = (1. - M_out[Flag[H]][lig][col]) * M_out[Flag[A]][lig][col];
          if (Flag[Comb1mH1mA] != -1) M_out[Flag[Comb1mH1mA]][lig][col] = (1. - M_out[Flag[H]][lig][col]) * (1. - M_out[Flag[A]][lig][col]);
      
          } /*valid*/
        }
      free_matrix3d_float(M, 2, 2);
      free_matrix3d_float(V, 2, 2);
      free_vector_float(lambda);
      free_matrix_float(M_avg,NpolarOut);
      }
    }

  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) {
#pragma omp parallel for private(col, k, M, V, lambda, M_avg) firstprivate(alpha, beta, delta, gamma, phase, p) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      M = matrix3d_float(3, 3, 2);
      V = matrix3d_float(3, 3, 2);
      lambda = vector_float(3);
      M_avg = matrix_float(NpolarOut,Sub_Ncol);
      average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
  
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
      
          M[0][0][0] = eps + M_avg[0][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][col];
          M[0][1][1] = eps + M_avg[2][col];
          M[0][2][0] = eps + M_avg[3][col];
          M[0][2][1] = eps + M_avg[4][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[5][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[6][col];
          M[1][2][1] = eps + M_avg[7][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[8][col];
          M[2][2][1] = 0.;

          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(3, M, V, lambda);
  
          for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 3; k++)  {
            alpha[k] = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
            phase[k] = atan2(V[0][k][1], eps + V[0][k][0]);
            beta[k] =  atan2(sqrt(V[2][k][0] * V[2][k][0] + V[2][k][1] * V[2][k][1]), eps + sqrt(V[1][k][0] * V[1][k][0] + V[1][k][1] * V[1][k][1]));
            delta[k] = atan2(V[1][k][1], eps + V[1][k][0]) - phase[k];
            delta[k] = atan2(sin(delta[k]), cos(delta[k]) + eps);
            gamma[k] = atan2(V[2][k][1], eps + V[2][k][0]) - phase[k];
            gamma[k] = atan2(sin(gamma[k]), cos(gamma[k]) + eps);
            /* Scattering mechanism probability of occurence */
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          /* Mean scattering mechanism */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = 0;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] = 0; 
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] = 0;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] = 0; 
          if (Flag[Lambda] != -1) M_out[Flag[Lambda]][lig][col] = 0; 
          if (Flag[H] != -1) M_out[Flag[H]][lig][col] = 0;
      
          for (k = 0; k < 3; k++) {
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] += alpha[k] * p[k];
            if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] += beta[k] * p[k];
            if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] += delta[k] * p[k];
            if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] += gamma[k] * p[k];
            if (Flag[Lambda] != -1) M_out[Flag[Lambda]][lig][col] += lambda[k] * p[k];
            if (Flag[H] != -1) M_out[Flag[H]][lig][col] -= p[k] * log(p[k] + eps);
            }

          /* Scaling */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] *= 180. / pi;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] *= 180. / pi;
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] *= 180. / pi;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] *= 180. / pi;
          if (Flag[H] != -1) M_out[Flag[H]][lig][col] /= log(3.);

          if (Flag[A] != -1) M_out[Flag[A]][lig][col] = (p[1] - p[2]) / (p[1] + p[2] + eps);
  
          if (Flag[CombHA] != -1) M_out[Flag[CombHA]][lig][col] = M_out[Flag[H]][lig][col] * M_out[Flag[A]][lig][col];
          if (Flag[CombH1mA] != -1) M_out[Flag[CombH1mA]][lig][col] = M_out[Flag[H]][lig][col] * (1. - M_out[Flag[A]][lig][col]);
          if (Flag[Comb1mHA] != -1) M_out[Flag[Comb1mHA]][lig][col] = (1. - M_out[Flag[H]][lig][col]) * M_out[Flag[A]][lig][col];
          if (Flag[Comb1mH1mA] != -1) M_out[Flag[Comb1mH1mA]][lig][col] = (1. - M_out[Flag[H]][lig][col]) * (1. - M_out[Flag[A]][lig][col]);
      
          } /*valid*/
        }
      free_matrix3d_float(M, 3, 3);
      free_matrix3d_float(V, 3, 3);
      free_vector_float(lambda);
      free_matrix_float(M_avg,NpolarOut);
      }
    }

  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
#pragma omp parallel for private(col, k, M, V, lambda, M_avg) firstprivate(alpha, beta, delta, gamma, epsilon, phase,nhu, p) shared(ligDone)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      M = matrix3d_float(4, 4, 2);
      V = matrix3d_float(4, 4, 2);
      lambda = vector_float(4);
      M_avg = matrix_float(NpolarOut,Sub_Ncol);
      average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
  
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {

          M[0][0][0] = eps + M_avg[0][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][col];
          M[0][1][1] = eps + M_avg[2][col];
          M[0][2][0] = eps + M_avg[3][col];
          M[0][2][1] = eps + M_avg[4][col];
          M[0][3][0] = eps + M_avg[5][col];
          M[0][3][1] = eps + M_avg[6][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[7][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[8][col];
          M[1][2][1] = eps + M_avg[9][col];
          M[1][3][0] = eps + M_avg[10][col];
          M[1][3][1] = eps + M_avg[11][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[12][col];
          M[2][2][1] = 0.;
          M[2][3][0] = eps + M_avg[13][col];
          M[2][3][1] = eps + M_avg[14][col];
          M[3][0][0] =  M[0][3][0];
          M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0];
          M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0];
          M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + M_avg[15][col];
          M[3][3][1] = 0.;
  
          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(4, M, V, lambda);
  
          for (k = 0; k < 4; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 4; k++)  {
            alpha[k] =  acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
            phase[k] = atan2(V[0][k][1], eps + V[0][k][0]);
            beta[k] =  atan2(sqrt(V[2][k][0] * V[2][k][0] + V[2][k][1] * V[2][k][1] + V[3][k][0] * V[3][k][0] + V[3][k][1] * V[3][k][1]), eps + sqrt(V[1][k][0] * V[1][k][0] +  V[1][k][1] * V[1][k][1]));
            epsilon[k] = atan2(sqrt(V[3][k][0] * V[3][k][0] + V[3][k][1] * V[3][k][1]), eps + sqrt(V[2][k][0] * V[2][k][0] + V[2][k][1] * V[2][k][1]));
            delta[k] = atan2(V[1][k][1], eps + V[1][k][0]) - phase[k];
            delta[k] = atan2(sin(delta[k]), cos(delta[k]) + eps);
            gamma[k] = atan2(V[2][k][1], eps + V[2][k][0]) - phase[k];
            gamma[k] = atan2(sin(gamma[k]), cos(gamma[k]) + eps);
            nhu[k] = atan2(V[3][k][1], eps + V[3][k][0]) - phase[k];
            nhu[k] = atan2(sin(nhu[k]), cos(nhu[k]) + eps);
            /* Scattering mechanism probability of occurence */
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2] + lambda[3]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          /* Mean scattering mechanism */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = 0;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] = 0; 
          if (Flag[Epsi] != -1) M_out[Flag[Epsi]][lig][col] = 0; 
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] = 0;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] = 0; 
          if (Flag[Nhu] != -1) M_out[Flag[Nhu]][lig][col] = 0; 
          if (Flag[Lambda] != -1) M_out[Flag[Lambda]][lig][col] = 0; 
          if (Flag[H] != -1) M_out[Flag[H]][lig][col] = 0;
      
          for (k = 0; k < 4; k++) {
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] += alpha[k] * p[k];
            if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] += beta[k] * p[k];
            if (Flag[Epsi] != -1) M_out[Flag[Epsi]][lig][col] += epsilon[k] * p[k];
            if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] += delta[k] * p[k];
            if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] += gamma[k] * p[k];
            if (Flag[Nhu] != -1) M_out[Flag[Nhu]][lig][col] += nhu[k] * p[k];
            if (Flag[Lambda] != -1) M_out[Flag[Lambda]][lig][col] += lambda[k] * p[k];
            if (Flag[H] != -1) M_out[Flag[H]][lig][col] -= p[k] * log(p[k] + eps);
            }
      
          /* Scaling */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] *= 180. / pi;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] *= 180. / pi;
          if (Flag[Epsi] != -1) M_out[Flag[Epsi]][lig][col] *= 180. / pi;
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] *= 180. / pi;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] *= 180. / pi;
          if (Flag[Nhu] != -1) M_out[Flag[Nhu]][lig][col] *= 180. / pi;
          if (Flag[H] != -1) M_out[Flag[H]][lig][col] /= log(4.);

          if (Flag[A] != -1) M_out[Flag[A]][lig][col] = (p[1] - p[2]) / (p[1] + p[2] + eps);
  
          if (Flag[CombHA] != -1) M_out[Flag[CombHA]][lig][col] = M_out[Flag[H]][lig][col] * M_out[Flag[A]][lig][col];
          if (Flag[CombH1mA] != -1) M_out[Flag[CombH1mA]][lig][col] = M_out[Flag[H]][lig][col] * (1. - M_out[Flag[A]][lig][col]);
          if (Flag[Comb1mHA] != -1) M_out[Flag[Comb1mHA]][lig][col] = (1. - M_out[Flag[H]][lig][col]) * M_out[Flag[A]][lig][col];
          if (Flag[Comb1mH1mA] != -1) M_out[Flag[Comb1mH1mA]][lig][col] = (1. - M_out[Flag[H]][lig][col]) * (1. - M_out[Flag[A]][lig][col]);
          } /*valid*/
        }
      free_matrix3d_float(M, 4, 4);
      free_matrix3d_float(V, 4, 4);
      free_vector_float(lambda);
      free_matrix_float(M_avg,NpolarOut);
      }
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) 
        write_block_matrix_matrix3d_float(OutFile2[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
      if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) 
        write_block_matrix_matrix3d_float(OutFile3[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
      if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) 
        write_block_matrix_matrix3d_float(OutFile4[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
      }
    }

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, Nout, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
  if (Flag[Np] != -1) {
    if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) fclose(OutFile2[Flag[Np]]);
    if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) fclose(OutFile3[Flag[Np]]);
    if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) fclose(OutFile4[Flag[Np]]);
    }
/********************************************************************
********************************************************************/

  return 1;
}


