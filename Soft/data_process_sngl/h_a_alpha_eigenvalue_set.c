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

File  : h_a_alpha_eigenvalue_set.c
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
  int Flag[26], Nout, NPara;
  FILE *OutFile3[23], *OutFile4[26];
  char *FileOut3[23] = {
  "l1.bin", "l2.bin", "l3.bin", 
  "p1.bin", "p2.bin", "p3.bin", 
  "anisotropy.bin", "anisotropy12.bin", "asymetry.bin",
  "polarisation_fraction.bin", "serd.bin","derd.bin",
  "rvi.bin", "pedestal.bin",
  "entropy_shannon.bin", "entropy_shannon_I.bin", "entropy_shannon_P.bin",
  "anisotropy_lueneburg.bin", "serd_norm.bin","derd_norm.bin",
  "entropy_shannon_norm.bin", "entropy_shannon_I_norm.bin", "entropy_shannon_P_norm.bin"};
        
  char *FileOut4[26] = {
  "l1.bin", "l2.bin", "l3.bin", "l4.bin",
  "p1.bin", "p2.bin", "p3.bin", "p4.bin",
  "anisotropy.bin", "anisotropy12.bin", "anisotropy34.bin", "asymetry.bin",
  "polarisation_fraction.bin", "serd.bin","derd.bin",
  "rvi.bin", "pedestal.bin",
  "entropy_shannon.bin", "entropy_shannon_I.bin", "entropy_shannon_P.bin",
  "anisotropy_lueneburg.bin", "serd_norm.bin","derd_norm.bin",
  "entropy_shannon_norm.bin", "entropy_shannon_I_norm.bin", "entropy_shannon_P_norm.bin"};

  int FlagEigenvalues, FlagProbabilites;
  int FlagAnisotropy, FlagAnisotropy12, FlagAnisotropy34;
  int FlagAsymetry, FlagPolarisationFraction;
  int FlagErd, FlagRVI, FlagPedestal, FlagShannon, FlagLueneburg;

  int Eigen1, Eigen2, Eigen3, Eigen4;
  int  Proba1, Proba2, Proba3, Proba4;
  int A, A12, A34, AS, PF; 
  int Serd, Derd, RVI, PH, HS, HSI, HSP, LUN;
  int  SerdN, DerdN, HSN, HSIN, HSPN;

/* Internal variables */
  int ii, lig, col, k;

  float p[4];
  float rau_re, rau_im, nu, zeta, abs_rau_2, delta2;
  float CC11, CC13_re, CC13_im, CC22, CC33;
  float alpha1, alpha2, k1_re, k1_im, k2_re, k2_im, mask;
  float min, max;
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

strcpy(UsageHelp,"\nh_a_alpha_eigenvalue_set.exe\n");
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
strcat(UsageHelp," (int)   	-fl3 	Flag Anisotropy\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Anisotropy12\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Anisotropy34\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Asymetry\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Polarisation Fraction\n");
strcat(UsageHelp," (int)   	-fl8 	Flag Erd\n");
strcat(UsageHelp," (int)   	-fl9 	Flag RVI\n");
strcat(UsageHelp," (int)   	-fl10	Flag Pedestal\n");
strcat(UsageHelp," (int)   	-fl11	Flag Shannon\n");
strcat(UsageHelp," (int)   	-fl12	Flag Lueneburg\n");

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

if(argc < 43) {
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
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagAnisotropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagAnisotropy12,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagAnisotropy34,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagAsymetry,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagPolarisationFraction,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagErd,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagRVI,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl10",int_cmd_prm,&FlagPedestal,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl11",int_cmd_prm,&FlagShannon,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl12",int_cmd_prm,&FlagLueneburg,1,UsageHelp);

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
    Eigen1 = 0; Eigen2 = 1; Eigen3 = 2;
    Proba1 = 3; Proba2 = 4; Proba3 = 5;
    A = 6; A12 = 7; AS = 8; PF = 9; 
    Serd = 10; Derd = 11; RVI = 12; PH = 13; HS = 14; HSI = 15; HSP = 16; LUN = 17;
    SerdN = 18; DerdN = 19; HSN = 20; HSIN = 21; HSPN = 22;
  
    M = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);

    NPara = 23;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Eigenvalues
    if (FlagEigenvalues == 1) {
      Flag[Eigen1] = Nout; Nout++; Flag[Eigen2] = Nout; Nout++;
      Flag[Eigen3] = Nout; Nout++;
      }
    }
  
  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
    /* Decomposition parameters */
    Eigen1 = 0; Eigen2 = 1; Eigen3 = 2; Eigen4 = 3;
    Proba1 = 4; Proba2 = 5; Proba3 = 6; Proba4 = 7;
    A = 8; A12 = 9; A34 = 10; AS = 11; PF = 12; 
    Serd = 13; Derd = 14; RVI = 15; PH = 16; HS = 17; HSI = 18; HSP = 19; LUN = 20;
    SerdN = 21; DerdN = 22; HSN = 23; HSIN = 24; HSPN = 25;

    M = matrix3d_float(4, 4, 2);
    V = matrix3d_float(4, 4, 2);
    lambda = vector_float(4);

    NPara = 26;
    for (k = 0; k < NPara; k++) Flag[k] = -1;
    Nout = 0;
    //Flag Eigenvalues
    if (FlagEigenvalues == 1) {
      Flag[Eigen1] = Nout; Nout++; Flag[Eigen2] = Nout; Nout++;
      Flag[Eigen3] = Nout; Nout++; Flag[Eigen4] = Nout; Nout++;
      }
    //Flag Anisotropy34
    if (FlagAnisotropy34 == 1) {
      Flag[A34] = Nout; Nout++;
      }
    }

  //Flag Probabilites
  if (FlagProbabilites == 1) {
    Flag[Proba1] = Nout; Nout++; Flag[Proba2] = Nout; Nout++;
    Flag[Proba3] = Nout; Nout++;
    }
  //Flag Anisotropy
  if (FlagAnisotropy == 1) {
    Flag[A] = Nout; Nout++;
    }
  //Flag Anisotropy12
  if (FlagAnisotropy12 == 1) {
    Flag[A12] = Nout; Nout++;
    }
  //Flag Asymetry
  if (FlagAsymetry == 1) {
    Flag[AS] = Nout; Nout++;
    }
  //Flag Polarisation_Fraction
  if (FlagPolarisationFraction == 1) {
    Flag[PF] = Nout; Nout++;
    }
  //Flag Erd
  if (FlagErd == 1) {
    Flag[Serd] = Nout; Nout++; Flag[Derd] = Nout; Nout++;
    Flag[SerdN] = Nout; Nout++;  Flag[DerdN] = Nout; Nout++;
    }
  //Flag RVI
  if (FlagRVI == 1) {
    Flag[RVI] = Nout; Nout++;
    }
  //Flag Pedestal
  if (FlagPedestal == 1) {
    Flag[PH] = Nout; Nout++;
    }
  //Flag Shannon
  if (FlagShannon == 1) {
    Flag[HS] = Nout; Nout++; Flag[HSI] = Nout; Nout++;
    Flag[HSP] = Nout; Nout++; Flag[HSN] = Nout; Nout++;
    Flag[HSIN] = Nout; Nout++; Flag[HSPN] = Nout; Nout++;
    }
  //Flag Lueneburg
  if (FlagLueneburg == 1) {
    Flag[LUN] = Nout; Nout++;
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
  minHS = INIT_MINMAX; maxHS = -minHS;
  minHSI = INIT_MINMAX; maxHSI = -minHS;
  minHSP = INIT_MINMAX; maxHSP = -minHS;

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
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          if (Flag[Eigen1] != -1) M_out[Flag[Eigen1]][lig][col] = lambda[0];
          if (Flag[Eigen2] != -1) M_out[Flag[Eigen2]][lig][col] = lambda[1];
          if (Flag[Eigen3] != -1) M_out[Flag[Eigen3]][lig][col] = lambda[2];
          if (Flag[Proba1] != -1) M_out[Flag[Proba1]][lig][col] = p[0];
          if (Flag[Proba2] != -1) M_out[Flag[Proba2]][lig][col] = p[1];
          if (Flag[Proba3] != -1) M_out[Flag[Proba3]][lig][col] = p[2];

          /* Scaling */
          if (Flag[A] != -1) M_out[Flag[A]][lig][col] = (p[1] - p[2]) / (p[1] + p[2] + eps);
          if (Flag[A12] != -1) M_out[Flag[A12]][lig][col] = (p[0] - p[1]) / (p[0] + p[1] + eps);
          if (Flag[AS] != -1) M_out[Flag[AS]][lig][col] = (p[0] - p[1]) / (1. - 3. * p[2]);
          if (Flag[PF] != -1) M_out[Flag[PF]][lig][col] = 1. - 3. * p[2];
          if (Flag[RVI] != -1) M_out[Flag[RVI]][lig][col] = 4. * p[2]/(p[0] + p[1] + p[2] + eps);
          min = p[0];  if (p[1] <= min) min = p[1]; if (p[2] <= min) min = p[2]; 
          max = p[0];  if (p[1] > max) max = p[1]; if (p[2] > max) max = p[2]; 
          if (Flag[PH] != -1) M_out[Flag[PH]][lig][col] = min / (max + eps);
          if (Flag[LUN] != -1) M_out[Flag[LUN]][lig][col] = sqrt(1.5 * (p[1]*p[1]+p[2]*p[2]) / (p[0]*p[0]+p[1]*p[1]+p[2]*p[2]+eps));

          /* Shannon */
          if (FlagShannon == 1) {
            D = lambda[0]*lambda[1]*lambda[2];
            I = lambda[0] + lambda[1] + lambda[2];
            DegPol = 1. - 27. * D / (I*I*I + eps);
            if ((1. - DegPol) < eps) M_out[Flag[HSP]][lig][col] = 0.;
            else M_out[Flag[HSP]][lig][col] = log(fabs(1. - DegPol));
            M_out[Flag[HSI]][lig][col] = 3. * log(exp(1.)*pi*I/3.);
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

          /* ERD */
          if (FlagErd == 1) {
            if (strcmp(PolTypeOut,"T3")==0) {
              CC11 = (M_avg[T311][lig][col] + 2 * M_avg[T312_re][lig][col] + M_avg[T322][lig][col]) / 2;
              CC13_re = (M_avg[T311][lig][col] - M_avg[T322][lig][col]) / 2;
              CC13_im = -M_avg[T312_im][lig][col];
              CC22 = M_avg[T333][lig][col];
              CC33 = (M_avg[T311][lig][col] - 2 * M_avg[T312_re][lig][col] + M_avg[T322][lig][col]) / 2;
              }
            if (strcmp(PolTypeOut,"C3")==0) {
              CC11 = M_avg[C311][lig][col];
              CC13_re = M_avg[C313_re][lig][col];
              CC13_im = M_avg[C313_im][lig][col];
              CC22 = M_avg[C322][lig][col];
              CC33 = M_avg[C333][lig][col];
              }

            rau_re  = CC13_re/CC11;
            rau_im  = CC13_im/CC11;
            nu  = CC22/CC11;
            zeta  = CC33/CC11;
            abs_rau_2 = rau_re*rau_re+rau_im*rau_im;
            delta2 = pow(zeta-1,2)+4*abs_rau_2;

            lambda[0] = CC11/2*(zeta+1+sqrt(delta2));
            lambda[1] = CC11/2*(zeta+1-sqrt(delta2));
            lambda[2] = CC11*nu;

            for (k = 0; k < 3; k++)
              p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);

            k1_re = 1/sqrt(2*((zeta-1+sqrt(delta2))*(zeta-1+sqrt(delta2))+4*abs_rau_2))*(2*rau_re+(zeta-1+sqrt(delta2)));
            k1_im = 1/sqrt(2*((zeta-1+sqrt(delta2))*(zeta-1+sqrt(delta2))+4*abs_rau_2))*(2*rau_im);
            k2_re = 1/sqrt(2*((zeta-1-sqrt(delta2))*(zeta-1-sqrt(delta2))+4*abs_rau_2))*(2*rau_re+(zeta-1-sqrt(delta2)));
            k2_im = 1/sqrt(2*((zeta-1-sqrt(delta2))*(zeta-1-sqrt(delta2))+4*abs_rau_2))*(2*rau_im);
            alpha1 = acos(sqrt(k1_re*k1_re+k1_im*k1_im));
            alpha2 = acos(sqrt(k2_re*k2_re+k2_im*k2_im));
  
            if (alpha2>alpha1)  mask = 1;
            else mask = 0;
  
            M_out[Flag[Serd]][lig][col] = (mask*p[0]+(1-mask)*p[1]-p[2])/(mask*p[0]+(1-mask)*p[1]+p[2]+eps);
            M_out[Flag[SerdN]][lig][col] = (M_out[Flag[Serd]][lig][col] + 1.) / 2.;
            M_out[Flag[Derd]][lig][col] = (mask*p[1]+(1-mask)*p[0]-p[2])/(mask*p[1]+(1-mask)*p[0]+p[2]+eps);
            M_out[Flag[DerdN]][lig][col] = (M_out[Flag[Derd]][lig][col] + 1.) / 2.;
            }
            
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
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2] + lambda[3]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          if (Flag[Eigen1] != -1) M_out[Flag[Eigen1]][lig][col] = lambda[0];
          if (Flag[Eigen2] != -1) M_out[Flag[Eigen2]][lig][col] = lambda[1];
          if (Flag[Eigen3] != -1) M_out[Flag[Eigen3]][lig][col] = lambda[2];
          if (Flag[Eigen4] != -1) M_out[Flag[Eigen4]][lig][col] = lambda[3];
          if (Flag[Proba1] != -1) M_out[Flag[Proba1]][lig][col] = p[0];
          if (Flag[Proba2] != -1) M_out[Flag[Proba2]][lig][col] = p[1];
          if (Flag[Proba3] != -1) M_out[Flag[Proba3]][lig][col] = p[2];
          if (Flag[Proba4] != -1) M_out[Flag[Proba4]][lig][col] = p[3];

          /* Scaling */
          if (Flag[A] != -1) M_out[Flag[A]][lig][col] = (p[1] - p[2]) / (p[1] + p[2] + eps);
          if (Flag[A12] != -1) M_out[Flag[A12]][lig][col] = (p[0] - p[1]) / (p[0] + p[1] + eps);
          if (Flag[A34] != -1) M_out[Flag[A34]][lig][col] = (p[2] - p[3]) / (p[2] + p[3] + eps);
          if (Flag[AS] != -1) M_out[Flag[AS]][lig][col] = (p[0] - p[1]) / (1. - 3. * (p[2] + p[3]));
          if (Flag[PF] != -1) M_out[Flag[PF]][lig][col] = 1. - 3. * (p[2] + p[3]);
          if (Flag[RVI] != -1) M_out[Flag[RVI]][lig][col] = 4. * p[2]/(p[0] + p[1] + p[2] + eps);
          min = p[0];  if (p[1] <= min) min = p[1]; if (p[2] <= min) min = p[2]; 
          max = p[0];  if (p[1] > max) max = p[1]; if (p[2] > max) max = p[2]; 
          if (Flag[PH] != -1) M_out[Flag[PH]][lig][col] = min / (max + eps);
          if (Flag[LUN] != -1) M_out[Flag[LUN]][lig][col] = sqrt(1.5 * (p[1]*p[1]+p[2]*p[2]) / (p[0]*p[0]+p[1]*p[1]+p[2]*p[2]+eps));

          /* Shannon */
          if (FlagShannon == 1) {
            D = lambda[0]*lambda[1]*lambda[2]*lambda[3];
            I = lambda[0] + lambda[1] + lambda[2] + lambda[3];
            DegPol = 1. - (4.*4.*4.*4.) * D / (I*I*I*I + eps);
            if ((1. - DegPol) < eps) M_out[Flag[HSP]][lig][col] = 0.;
            else M_out[Flag[HSP]][lig][col] = log(fabs(1. - DegPol));
            M_out[Flag[HSI]][lig][col] = 4. * log(exp(1.)*pi*I/4.);
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

          /* ERD */
          if (FlagErd == 1) {
            if (strcmp(PolTypeOut,"T4")==0) {
              CC11 = (M_avg[T411][lig][col] + 2 * M_avg[T412_re][lig][col] + M_avg[T422][lig][col]) / 2;
              CC13_re = (M_avg[T411][lig][col] - M_avg[T422][lig][col]) / 2;
              CC13_im = -M_avg[T412_im][lig][col];
              CC22 = M_avg[T433][lig][col];
              CC33 = (M_avg[T411][lig][col] - 2 * M_avg[T412_re][lig][col] + M_avg[T422][lig][col]) / 2;
              }
            if (strcmp(PolTypeOut,"C4")==0) {
              CC11 = M_avg[C411][lig][col];
              CC13_re = M_avg[C414_re][lig][col];
              CC13_im = M_avg[C414_im][lig][col];
              CC22 = (M_avg[C422][lig][col] + M_avg[C433][lig][col] + 2 * M_avg[C423_re][lig][col]) / 2.;
              CC33 = M_avg[C444][lig][col];
              }

            rau_re  = CC13_re/CC11;
            rau_im  = CC13_im/CC11;
            nu  = CC22/CC11;
            zeta  = CC33/CC11;
            abs_rau_2 = rau_re*rau_re+rau_im*rau_im;
            delta2 = pow(zeta-1,2)+4*abs_rau_2;

            lambda[0] = CC11/2*(zeta+1+sqrt(delta2));
            lambda[1] = CC11/2*(zeta+1-sqrt(delta2));
            lambda[2] = CC11*nu;

            for (k = 0; k < 3; k++)
              p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);

            k1_re = 1/sqrt(2*((zeta-1+sqrt(delta2))*(zeta-1+sqrt(delta2))+4*abs_rau_2))*(2*rau_re+(zeta-1+sqrt(delta2)));
            k1_im = 1/sqrt(2*((zeta-1+sqrt(delta2))*(zeta-1+sqrt(delta2))+4*abs_rau_2))*(2*rau_im);
            k2_re = 1/sqrt(2*((zeta-1-sqrt(delta2))*(zeta-1-sqrt(delta2))+4*abs_rau_2))*(2*rau_re+(zeta-1-sqrt(delta2)));
            k2_im = 1/sqrt(2*((zeta-1-sqrt(delta2))*(zeta-1-sqrt(delta2))+4*abs_rau_2))*(2*rau_im);
            alpha1 = acos(sqrt(k1_re*k1_re+k1_im*k1_im));
            alpha2 = acos(sqrt(k2_re*k2_re+k2_im*k2_im));
  
            if (alpha2>alpha1)  mask = 1;
            else mask = 0;
  
            M_out[Flag[Serd]][lig][col] = (mask*p[0]+(1-mask)*p[1]-p[2])/(mask*p[0]+(1-mask)*p[1]+p[2]+eps);
            M_out[Flag[SerdN]][lig][col] = (M_out[Flag[Serd]][lig][col] + 1.) / 2.;
            M_out[Flag[Derd]][lig][col] = (mask*p[1]+(1-mask)*p[0]-p[2])/(mask*p[1]+(1-mask)*p[0]+p[2]+eps);
            M_out[Flag[DerdN]][lig][col] = (M_out[Flag[Derd]][lig][col] + 1.) / 2.;
            }
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
  if (FlagShannon == 1) {

  sprintf(file_name, "%s%s", out_dir, "entropy_shannon.bin");
  if ((OutFile3[0] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_norm.bin");
  if ((OutFile3[1] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_I.bin");
  if ((OutFile3[2] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_I_norm.bin");
  if ((OutFile3[3] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_P.bin");
  if ((OutFile3[4] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "entropy_shannon_P_norm.bin");
  if ((OutFile3[5] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

  for (Nb = 0; Nb < NbBlock; Nb++) {

    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
    read_block_matrix_matrix3d_float(OutFile3[0], M_out, 0, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
    read_block_matrix_matrix3d_float(OutFile3[2], M_out, 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
    read_block_matrix_matrix3d_float(OutFile3[4], M_out, 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);

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

    write_block_matrix_matrix3d_float(OutFile3[1], M_out, 1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    write_block_matrix_matrix3d_float(OutFile3[3], M_out, 3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    write_block_matrix_matrix3d_float(OutFile3[5], M_out, 5, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

    } // NbBlock

  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < 6; Np++) fclose(OutFile3[Np]);

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


