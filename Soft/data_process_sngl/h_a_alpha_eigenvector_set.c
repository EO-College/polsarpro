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

File  : h_a_alpha_eigenvector_set.c
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

#define NPolType 10
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2T3", "S2C3", "S2T4", "S2C4", "C3", "C3T3", "C4", "C4T4", "T3", "T4"};
  char file_name[FilePathLength];
  
/* Flag Parameters */
  int Flag[30], Nout, NPara;
  FILE *OutFile3[16], *OutFile4[30];
  char *FileOut3[16] = {
  "alpha1.bin", "alpha2.bin", "alpha3.bin",
  "beta1.bin", "beta2.bin", "beta3.bin", 
  "delta1.bin", "delta2.bin", "delta3.bin", 
  "gamma1.bin", "gamma2.bin", "gamma3.bin", 
  "alpha.bin", "beta.bin", "delta.bin", "gamma.bin"};
        
  char *FileOut4[30] = {
  "alpha1.bin", "alpha2.bin", "alpha3.bin", "alpha4.bin",
  "beta1.bin", "beta2.bin", "beta3.bin", "beta4.bin",
  "epsilon1.bin", "epsilon2.bin", "epsilon3.bin", "epsilon4.bin",
  "delta1.bin", "delta2.bin", "delta3.bin", "delta4.bin",
  "gamma1.bin", "gamma2.bin", "gamma3.bin", "gamma4.bin",
  "nhu1.bin", "nhu2.bin", "nhu3.bin", "nhu4.bin",
  "alpha.bin", "beta.bin", "epsilon.bin", "delta.bin",
  "gamma.bin", "nhu.bin"};

  int FlagAll, FlagAlpha, FlagBeta, FlagDelta, FlagGamma, FlagEpsilon, FlagNhu;

  int Alpha1, Alpha2, Alpha3, Alpha4, Beta1, Beta2, Beta3, Beta4;
  int Epsi1, Epsi2, Epsi3, Epsi4, Delta1, Delta2, Delta3, Delta4;
  int Gamma1, Gamma2, Gamma3, Gamma4, Nhu1, Nhu2, Nhu3, Nhu4;
  int Alpha, Beta, Epsi, Delta, Gamma, Nhu;  

/* Internal variables */
  int ii, lig, col, k;

  float alpha[4], beta[4], epsilon[4], delta[4], gamma[4], nhu[4], phase[4], p[4];

/* Matrix arrays */
  float ***M_avg;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_a_alpha_eigenvector_set.exe\n");
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
strcat(UsageHelp," (int)   	-fl1 	Flag All Angles\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Alpha\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Beta\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Delta\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Gamma\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Epsilon (valid only for T4 or C4, set 0 otherwise)\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Nhu (valid only for T4 or C4, set 0 otherwise)\n");
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

if(argc < 33) {
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

  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagAll,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagAlpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagBeta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagDelta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagGamma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagEpsilon,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagNhu,1,UsageHelp);

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
  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) {
    /* Decomposition parameters */
    Alpha1 = 0; Alpha2 = 1; Alpha3 = 2; 
    Beta1 = 3; Beta2 = 4; Beta3 = 5; 
    Delta1 = 6; Delta2 = 7; Delta3 = 8;
    Gamma1 = 9; Gamma2 = 10; Gamma3 = 11;
    Alpha = 12; Beta = 13; Delta = 14; Gamma = 15;
  
    M = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);

    NPara = 16;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Alpha
    if (FlagAlpha == 1) {
      Flag[Alpha1] = Nout; Nout++;
      Flag[Alpha2] = Nout; Nout++;
      Flag[Alpha3] = Nout; Nout++;
      }
    //Flag Beta
    if (FlagBeta == 1) {
      Flag[Beta1] = Nout; Nout++;
      Flag[Beta2] = Nout; Nout++;
      Flag[Beta3] = Nout; Nout++;
      }
    //Flag Delta
    if (FlagDelta == 1) {
      Flag[Delta1] = Nout; Nout++;
      Flag[Delta2] = Nout; Nout++;
      Flag[Delta3] = Nout; Nout++;
      }
    //Flag Gamma
    if (FlagGamma == 1) {
      Flag[Gamma1] = Nout; Nout++;
      Flag[Gamma2] = Nout; Nout++;
      Flag[Gamma3] = Nout; Nout++;
      }
    //Flag All Angles
    if (FlagAll == 1) {
      Flag[Alpha] = Nout; Nout++;
      Flag[Beta] = Nout; Nout++;
      Flag[Delta] = Nout; Nout++;
      Flag[Gamma] = Nout; Nout++;
      }
    }

  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
    /* Decomposition parameters */
    Alpha1 = 0; Alpha2 = 1; Alpha3 = 2; Alpha4 = 3;
    Beta1 = 4; Beta2 = 5; Beta3 = 6; Beta4 = 7;
    Epsi1 = 8; Epsi2 = 9; Epsi3 = 10; Epsi4 = 11;
    Delta1 = 12; Delta2 = 13; Delta3 = 14; Delta4 = 15;
    Gamma1 = 16; Gamma2 = 17; Gamma3 = 18; Gamma4 = 19;
    Nhu1 = 20; Nhu2 = 21; Nhu3 = 22; Nhu4 = 23;
    Alpha = 24; Beta = 25; Epsi = 26; Delta = 27; Gamma = 28; Nhu = 29;

    M = matrix3d_float(4, 4, 2);
    V = matrix3d_float(4, 4, 2);
    lambda = vector_float(4);

    NPara = 30;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Alpha
    if (FlagAlpha == 1) {
      Flag[Alpha1] = Nout; Nout++;
      Flag[Alpha2] = Nout; Nout++;
      Flag[Alpha3] = Nout; Nout++;
      Flag[Alpha4] = Nout; Nout++;
      }
    //Flag Beta
    if (FlagBeta == 1) {
      Flag[Beta1] = Nout; Nout++;
      Flag[Beta2] = Nout; Nout++;
      Flag[Beta3] = Nout; Nout++;
      Flag[Beta4] = Nout; Nout++;
      }
    //Flag Delta
    if (FlagDelta == 1) {
      Flag[Delta1] = Nout; Nout++;
      Flag[Delta2] = Nout; Nout++;
      Flag[Delta3] = Nout; Nout++;
      Flag[Delta4] = Nout; Nout++;
      }
    //Flag Gamma
    if (FlagGamma == 1) {
      Flag[Gamma1] = Nout; Nout++;
      Flag[Gamma2] = Nout; Nout++;
      Flag[Gamma3] = Nout; Nout++;
      Flag[Gamma4] = Nout; Nout++;
      }
    //Flag Epsilon
    if (FlagEpsilon == 1) {
      Flag[Epsi1] = Nout; Nout++;
      Flag[Epsi2] = Nout; Nout++;
      Flag[Epsi3] = Nout; Nout++;
      Flag[Epsi4] = Nout; Nout++;
      }
    //Flag Nhu
    if (FlagNhu == 1) {
      Flag[Nhu1] = Nout; Nout++;
      Flag[Nhu2] = Nout; Nout++;
      Flag[Nhu3] = Nout; Nout++;
      Flag[Nhu4] = Nout; Nout++;
      }
    //Flag All Angles
    if (FlagAll == 1) {
      Flag[Alpha] = Nout; Nout++;
      Flag[Beta] = Nout; Nout++;
      Flag[Epsi] = Nout; Nout++;
      Flag[Delta] = Nout; Nout++;
      Flag[Gamma] = Nout; Nout++;
      Flag[Nhu] = Nout; Nout++;
      }
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
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
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"T3")==0)) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"T4")==0)) C4_to_T4(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) {
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[lig][col] == 1.) {
      
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[0][2][0] = eps + M_avg[3][lig][col];
          M[0][2][1] = eps + M_avg[4][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[5][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[6][lig][col];
          M[1][2][1] = eps + M_avg[7][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[8][lig][col];
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

          if (Flag[Alpha1] != -1) M_out[Flag[Alpha1]][lig][col] = alpha[0] * 180. / pi;
          if (Flag[Alpha2] != -1) M_out[Flag[Alpha2]][lig][col] = alpha[1] * 180. / pi;
          if (Flag[Alpha3] != -1) M_out[Flag[Alpha3]][lig][col] = alpha[2] * 180. / pi;
          if (Flag[Beta1] != -1) M_out[Flag[Beta1]][lig][col] = beta[0] * 180. / pi; 
          if (Flag[Beta2] != -1) M_out[Flag[Beta2]][lig][col] = beta[1] * 180. / pi; 
          if (Flag[Beta3] != -1) M_out[Flag[Beta3]][lig][col] = beta[2] * 180. / pi; 
          if (Flag[Delta1] != -1) M_out[Flag[Delta1]][lig][col] = delta[0] * 180. / pi;
          if (Flag[Delta2] != -1) M_out[Flag[Delta2]][lig][col] = delta[1] * 180. / pi;
          if (Flag[Delta3] != -1) M_out[Flag[Delta3]][lig][col] = delta[2] * 180. / pi;
          if (Flag[Gamma1] != -1) M_out[Flag[Gamma1]][lig][col] = gamma[0] * 180. / pi; 
          if (Flag[Gamma2] != -1) M_out[Flag[Gamma2]][lig][col] = gamma[1] * 180. / pi; 
          if (Flag[Gamma3] != -1) M_out[Flag[Gamma3]][lig][col] = gamma[2] * 180. / pi; 

          /* Mean scattering mechanism */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = 0;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] = 0; 
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] = 0;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] = 0; 
      
          for (k = 0; k < 3; k++) {
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] += alpha[k] * p[k];
            if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] += beta[k] * p[k];
            if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] += delta[k] * p[k];
            if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] += gamma[k] * p[k];
            }

          /* Scaling */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] *= 180. / pi;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] *= 180. / pi;
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] *= 180. / pi;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] *= 180. / pi;
      
          } /*valid*/
        }
      }
    }

  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[lig][col] == 1.) {

          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[0][2][0] = eps + M_avg[3][lig][col];
          M[0][2][1] = eps + M_avg[4][lig][col];
          M[0][3][0] = eps + M_avg[5][lig][col];
          M[0][3][1] = eps + M_avg[6][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[7][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[8][lig][col];
          M[1][2][1] = eps + M_avg[9][lig][col];
          M[1][3][0] = eps + M_avg[10][lig][col];
          M[1][3][1] = eps + M_avg[11][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[12][lig][col];
          M[2][2][1] = 0.;
          M[2][3][0] = eps + M_avg[13][lig][col];
          M[2][3][1] = eps + M_avg[14][lig][col];
          M[3][0][0] =  M[0][3][0];
          M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0];
          M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0];
          M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + M_avg[15][lig][col];
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

          if (Flag[Alpha1] != -1) M_out[Flag[Alpha1]][lig][col] = alpha[0] * 180. / pi;
          if (Flag[Alpha2] != -1) M_out[Flag[Alpha2]][lig][col] = alpha[1] * 180. / pi;
          if (Flag[Alpha3] != -1) M_out[Flag[Alpha3]][lig][col] = alpha[2] * 180. / pi;
          if (Flag[Alpha4] != -1) M_out[Flag[Alpha4]][lig][col] = alpha[3] * 180. / pi;
          if (Flag[Beta1] != -1) M_out[Flag[Beta1]][lig][col] = beta[0] * 180. / pi; 
          if (Flag[Beta2] != -1) M_out[Flag[Beta2]][lig][col] = beta[1] * 180. / pi; 
          if (Flag[Beta3] != -1) M_out[Flag[Beta3]][lig][col] = beta[2] * 180. / pi; 
          if (Flag[Beta4] != -1) M_out[Flag[Beta4]][lig][col] = beta[3] * 180. / pi; 
          if (Flag[Epsi1] != -1) M_out[Flag[Epsi1]][lig][col] = epsilon[0] * 180. / pi; 
          if (Flag[Epsi2] != -1) M_out[Flag[Epsi2]][lig][col] = epsilon[1] * 180. / pi; 
          if (Flag[Epsi3] != -1) M_out[Flag[Epsi3]][lig][col] = epsilon[2] * 180. / pi; 
          if (Flag[Epsi4] != -1) M_out[Flag[Epsi4]][lig][col] = epsilon[3] * 180. / pi; 
          if (Flag[Delta1] != -1) M_out[Flag[Delta1]][lig][col] = delta[0] * 180. / pi;
          if (Flag[Delta2] != -1) M_out[Flag[Delta2]][lig][col] = delta[1] * 180. / pi;
          if (Flag[Delta3] != -1) M_out[Flag[Delta3]][lig][col] = delta[2] * 180. / pi;
          if (Flag[Delta4] != -1) M_out[Flag[Delta4]][lig][col] = delta[3] * 180. / pi;
          if (Flag[Gamma1] != -1) M_out[Flag[Gamma1]][lig][col] = gamma[0] * 180. / pi; 
          if (Flag[Gamma2] != -1) M_out[Flag[Gamma2]][lig][col] = gamma[1] * 180. / pi; 
          if (Flag[Gamma3] != -1) M_out[Flag[Gamma3]][lig][col] = gamma[2] * 180. / pi; 
          if (Flag[Gamma4] != -1) M_out[Flag[Gamma4]][lig][col] = gamma[3] * 180. / pi; 
          if (Flag[Nhu1] != -1) M_out[Flag[Nhu1]][lig][col] = nhu[0] * 180. / pi; 
          if (Flag[Nhu2] != -1) M_out[Flag[Nhu2]][lig][col] = nhu[1] * 180. / pi; 
          if (Flag[Nhu3] != -1) M_out[Flag[Nhu3]][lig][col] = nhu[2] * 180. / pi; 
          if (Flag[Nhu4] != -1) M_out[Flag[Nhu4]][lig][col] = nhu[3] * 180. / pi; 

          /* Mean scattering mechanism */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = 0;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] = 0; 
          if (Flag[Epsi] != -1) M_out[Flag[Epsi]][lig][col] = 0; 
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] = 0;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] = 0; 
          if (Flag[Nhu] != -1) M_out[Flag[Nhu]][lig][col] = 0; 
      
          for (k = 0; k < 4; k++) {
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] += alpha[k] * p[k];
            if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] += beta[k] * p[k];
            if (Flag[Epsi] != -1) M_out[Flag[Epsi]][lig][col] += epsilon[k] * p[k];
            if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] += delta[k] * p[k];
            if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] += gamma[k] * p[k];
            if (Flag[Nhu] != -1) M_out[Flag[Nhu]][lig][col] += nhu[k] * p[k];
            }
      
          /* Scaling */
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] *= 180. / pi;
          if (Flag[Beta] != -1) M_out[Flag[Beta]][lig][col] *= 180. / pi;
          if (Flag[Epsi] != -1) M_out[Flag[Epsi]][lig][col] *= 180. / pi;
          if (Flag[Delta] != -1) M_out[Flag[Delta]][lig][col] *= 180. / pi;
          if (Flag[Gamma] != -1) M_out[Flag[Gamma]][lig][col] *= 180. / pi;
          if (Flag[Nhu] != -1) M_out[Flag[Nhu]][lig][col] *= 180. / pi;

          } /*valid*/
        }
      }
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
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
    if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) fclose(OutFile3[Flag[Np]]);
    if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) fclose(OutFile4[Flag[Np]]);
    }
/********************************************************************
********************************************************************/

  return 1;
}


