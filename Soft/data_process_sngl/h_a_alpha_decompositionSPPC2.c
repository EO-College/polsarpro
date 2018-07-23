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

File  : h_a_alpha_decompositionSPPC2.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Cloude-Pottier eigenvector/eigenvalue based decomposition

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

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

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "C2"};
  char file_name[FilePathLength];
  
/* Flag Parameters */
  int Flag[23], Nout, NPara;
  FILE *OutFile2[23];
  char *FileOut2[23] = {
  "l1.bin", "l2.bin", "p1.bin", "p2.bin",
  "alpha1.bin", "alpha2.bin",
  "delta1.bin", "delta2.bin",
  "alpha.bin", "delta.bin", "lambda.bin",
  "entropy.bin", "anisotropy.bin",
  "combination_HA.bin", "combination_H1mA.bin",
  "combination_1mHA.bin", "combination_1mH1mA.bin",
  "entropy_shannon.bin", "entropy_shannon_I.bin", "entropy_shannon_P.bin",
  "entropy_shannon_norm.bin", "entropy_shannon_I_norm.bin", "entropy_shannon_P_norm.bin"};

  int FlagPara;
  int FlagEigenvalues, FlagProbabilites;
  int FlagAlpha12, FlagDelta12;
  int FlagAlpha, FlagDelta, FlagLambda;
  int FlagEntropy, FlagAnisotropy;
  int FlagCombHA, FlagCombH1mA, FlagComb1mHA, FlagComb1mH1mA;
  int FlagShannon;

  int Eigen1, Eigen2, Proba1, Proba2;
  int Alpha1, Alpha2, Delta1, Delta2;
  int Alpha, Delta, Lambda;
  int H, A, CombHA, CombH1mA, Comb1mHA, Comb1mH1mA;
  int HS, HSI, HSP, HSN, HSIN, HSPN;

/* Internal variables */
  int ii, lig, col, k;

  float alpha[2], delta[2], phase[2], p[2];
  float D, I, DegPol;
  float minHS, maxHS, minHSI, maxHSI, minHSP, maxHSP;

/* Matrix arrays */
  float ***M_avg;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_a_alpha_decompositionSPPC2.exe\n");
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
strcat(UsageHelp," (int)   	-fl1 	Flag Eigenvalues\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Probabilites\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Alpha1-2 (0/1)\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Delta1-2 (0/1)\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Parameters (0/1)\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Alpha (0/1)\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Delta (0/1)\n");
strcat(UsageHelp," (int)   	-fl8 	Flag Lambda (0/1)\n");
strcat(UsageHelp," (int)   	-fl9 	Flag Entropy (0/1)\n");
strcat(UsageHelp," (int)   	-fl10 	Flag Anisotropy (0/1)\n");
strcat(UsageHelp," (int)   	-fl11 	Flag Comb HA (0/1)\n");
strcat(UsageHelp," (int)   	-fl12 	Flag Comb H1mA (0/1)\n");
strcat(UsageHelp," (int)   	-fl13 	Flag Comb 1mHA (0/1)\n");
strcat(UsageHelp," (int)   	-fl14 	Flag Comb 1mH1mA (0/1)\n");
strcat(UsageHelp," (int)   	-fl15	Flag Shannon\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
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

if(argc < 49) {
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
  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagEigenvalues,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagProbabilites,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagAlpha12,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagDelta12,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagPara,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagAlpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagDelta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagLambda,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagEntropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl10",int_cmd_prm,&FlagAnisotropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl11",int_cmd_prm,&FlagCombHA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl12",int_cmd_prm,&FlagCombH1mA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl13",int_cmd_prm,&FlagComb1mHA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl14",int_cmd_prm,&FlagComb1mH1mA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl15",int_cmd_prm,&FlagShannon,1,UsageHelp);

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

  if (strcmp(PolType,"SPP")==0) strcpy(PolType,"SPPC2");

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
  /* Decomposition parameters */
  Eigen1 = 0; Eigen2 = 1; 
  Proba1 = 2; Proba2 = 3; 
  Alpha1 = 4; Alpha2 = 5;
  Delta1 = 6; Delta2 = 7;
  Alpha = 8; Delta = 9; Lambda = 10;
  H = 11; A = 12; CombHA = 13; CombH1mA = 14; Comb1mHA = 15; Comb1mH1mA = 16;
  HS = 17; HSI = 18; HSP = 19;
  HSN = 20; HSIN = 21; HSPN = 22;
  
  M = matrix3d_float(2, 2, 2);
  V = matrix3d_float(2, 2, 2);
  lambda = vector_float(2);

  NPara = 23;
  for (k = 0; k < NPara; k++) Flag[k] = -1;
  Nout = 0;
  //Flag Eigenvalues
  if (FlagEigenvalues == 1) {
    Flag[Eigen1] = Nout; Nout++;
    Flag[Eigen2] = Nout; Nout++;
    }
  //Flag Probabilites
  if (FlagProbabilites == 1) {
    Flag[Proba1] = Nout; Nout++;
    Flag[Proba2] = Nout; Nout++;
    }
  
  //Flag Alpha
  if (FlagAlpha12 == 1) {
    Flag[Alpha1] = Nout; Nout++;
    Flag[Alpha2] = Nout; Nout++;
    }
  //Flag Delta
  if (FlagDelta12 == 1) {
    Flag[Delta1] = Nout; Nout++;
    Flag[Delta2] = Nout; Nout++;
    }

  //Flag Parameters
  if (FlagPara == 1) {
    Flag[Alpha] = Nout; Nout++; Flag[Delta] = Nout; Nout++;
    Flag[Lambda] = Nout; Nout++;
    }

  //Flag Alpha  (must keep the previous selection)
  if (FlagAlpha == 1) {
    if (Flag[Alpha] == -1) { Flag[Alpha] = Nout; Nout++; }
    }
  //Flag Delta  (must keep the previous selection)
  if (FlagDelta == 1) {
    if (Flag[Delta] == -1) { Flag[Delta] = Nout; Nout++; }
    }
  //Flag Lambda  (must keep the previous selection)
  if (FlagLambda == 1) {
    if (Flag[Lambda] == -1) { Flag[Lambda] = Nout; Nout++; }
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

  //Flag Shannon
  if (FlagShannon == 1) {
    Flag[HS] = Nout; Nout++; Flag[HSI] = Nout; Nout++;
    Flag[HSP] = Nout; Nout++; Flag[HSN] = Nout; Nout++;
    Flag[HSIN] = Nout; Nout++; Flag[HSPN] = Nout; Nout++;
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      sprintf(file_name, "%s%s", out_dir, FileOut2[k]);
      if ((OutFile2[Flag[k]] = fopen(file_name, "wb")) == NULL)
        edit_error("Could not open input file : ", file_name);
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
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Mout = Nout*Nlig*Sub_Ncol */
  NBlockA += Nout*Sub_Ncol; NBlockB += 0;
  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
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

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_out = matrix3d_float(Nout, NligBlock[0], Sub_Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

minHS = INIT_MINMAX; maxHS = -INIT_MINMAX;
minHSI = INIT_MINMAX; maxHSI = -INIT_MINMAX;
minHSP = INIT_MINMAX; maxHSP = -INIT_MINMAX;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[lig][col] == 1.) {
      
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[3][lig][col];
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

          if (Flag[Eigen1] != -1) M_out[Flag[Eigen1]][lig][col] = lambda[0];
          if (Flag[Eigen2] != -1) M_out[Flag[Eigen2]][lig][col] = lambda[1];
          if (Flag[Proba1] != -1) M_out[Flag[Proba1]][lig][col] = p[0];
          if (Flag[Proba2] != -1) M_out[Flag[Proba2]][lig][col] = p[1];

          if (Flag[Alpha1] != -1) M_out[Flag[Alpha1]][lig][col] = alpha[0] * 180. / pi;
          if (Flag[Alpha2] != -1) M_out[Flag[Alpha2]][lig][col] = alpha[1] * 180. / pi;
          if (Flag[Delta1] != -1) M_out[Flag[Delta1]][lig][col] = delta[0] * 180. / pi;
          if (Flag[Delta2] != -1) M_out[Flag[Delta2]][lig][col] = delta[1] * 180. / pi;

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

          /* Shannon */
          if (FlagShannon == 1) {
            D = lambda[0]*lambda[1];
            I = lambda[0] + lambda[1];
            DegPol = 1. - 4.* D / (I*I + eps);
            if ((1. - DegPol) < eps) M_out[Flag[HSP]][lig][col] = 0.;
            else M_out[Flag[HSP]][lig][col] = log(fabs(1. - DegPol));
            M_out[Flag[HSI]][lig][col] = 2. * log(exp(1.)*pi*I/2.);
            M_out[Flag[HS]][lig][col] = M_out[Flag[HSP]][lig][col] + M_out[Flag[HSI]][lig][col];
            if (M_out[Flag[HS]][lig][col] != -INIT_MINMAX) {
              if (maxHS < M_out[Flag[HS]][lig][col]) maxHS = M_out[Flag[HS]][lig][col];
              if (M_out[Flag[HS]][lig][col] < minHS) minHS = M_out[Flag[HS]][lig][col];
              }
            if (M_out[Flag[HSI]][lig][col] != -INIT_MINMAX) {
              if (maxHSI < M_out[Flag[HSI]][lig][col]) maxHSI = M_out[Flag[HSI]][lig][col];
              if (M_out[Flag[HSI]][lig][col] < minHSI) minHSI = M_out[Flag[HSI]][lig][col];
              }
            if (M_out[Flag[HSP]][lig][col] != -INIT_MINMAX) {
              if (maxHSP < M_out[Flag[HSP]][lig][col]) maxHSP = M_out[Flag[HSP]][lig][col];
              if (M_out[Flag[HSP]][lig][col] < minHSP) minHSP = M_out[Flag[HSP]][lig][col];
              }
            }
      
          } /*valid*/
        }
      }
    }

  for (k = 0; k < NPara; k++) 
    if (Flag[k] != -1) 
        write_block_matrix_matrix3d_float(OutFile2[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
    if (Flag[Np] != -1) fclose(OutFile2[Flag[Np]]);

/********************************************************************
********************************************************************/
    
  if (FlagShannon == 1) {

  sprintf(file_name, "%s%s", out_dir, "entropy_shannon.bin");
  if ((OutFile2[0] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_norm.bin");
  if ((OutFile2[1] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_I.bin");
  if ((OutFile2[2] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_I_norm.bin");
  if ((OutFile2[3] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_P.bin");
  if ((OutFile2[4] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_P_norm.bin");
  if ((OutFile2[5] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

  for (Nb = 0; Nb < NbBlock; Nb++) {

    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
    read_block_matrix_matrix3d_float(OutFile2[0], M_out, 0, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
    read_block_matrix_matrix3d_float(OutFile2[2], M_out, 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
    read_block_matrix_matrix3d_float(OutFile2[4], M_out, 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);

    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          M_out[1][lig][col] = (M_out[0][lig][col] - minHS) / (maxHS - minHS); 
          M_out[3][lig][col] = (M_out[2][lig][col] - minHSI) / (maxHSI - minHSI); 
          M_out[5][lig][col] = (M_out[4][lig][col] - minHSP) / (maxHSP - minHSP); 
          } else {
          M_out[1][lig][col] = 0.; 
          M_out[3][lig][col] = 0.; 
          M_out[5][lig][col] = 0.; 
          } /*valid*/

        }
      }

    write_block_matrix_matrix3d_float(OutFile2[1], M_out, 1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    write_block_matrix_matrix3d_float(OutFile2[3], M_out, 3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    write_block_matrix_matrix3d_float(OutFile2[5], M_out, 5, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

    } // NbBlock

  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < 6; Np++) fclose(OutFile2[Np]);

  }

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

  return 1;
}


