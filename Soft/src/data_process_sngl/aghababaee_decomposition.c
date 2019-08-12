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

File  : aghababaee_decomposition.c
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

Description :  Aghababaee decomposition

Decomposition Procedure proposed in the paper entitled "Incoherent
Target Scattering Decomposition of Polarimetric SAR Data Based on
Vector Model Roll-Invariant Parameters" by Hossein Aghababaee and 
Mahmod Reza Sahebi.
Published in the IEEE TGRS, Aug. 2016, volume 54-8

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

#define NPolType 3
/* LOCAL VARIABLES */
  FILE *out_file1, *out_file2, *out_file3, *out_file4;
  FILE *out_file5, *out_file6, *out_file7, *out_file8;
  FILE *out_file9, *out_file10, *out_file11, *out_file12;
  FILE *out_file13, *out_file14, *out_file15, *out_file16;
  FILE *out_file17, *out_file18, *out_file19;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k;
  int ligDone = 0;

  float p[3];
  float orient_max[3], Mu1_abs[3], Mu1_angle[3], Mu2_abs[3], Mu2_angle[3], Mu3_abs[3];
  float hh_re, hh_im, vv_re, vv_im, hv_re, hv_im;
  float alpha_re, alpha_im, alpha_abs;
  float ro_re, ro_im, ro_abs, ro_angle;
  float landa_re, landa_im, landa_abs, landa_angle;
  float a, cos_taw, sin_taw;
  float R11, R12, R13, R14, R21, R22, R23, R24;
  float R31, R32, R33, R34, R41, R42, R43, R44;
  float value_re, value_im;
  float Sym_max1_re, Sym_max1_im, Sym_max2_re, Sym_max2_im, Sym_max3_re, Sym_max3_im, Sym_max4_re, Sym_max4_im, Sym_max_abs;
  float Mu1_re, Mu1_im, Mu2_re, Mu2_im, Mu3_re, Mu3_im;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_alphap_sm3, **M_alphap_sm2, **M_alphap_sm1, **M_alphap_mean;
  float **M_phip_sm3, **M_phip_sm2, **M_phip_sm1, **M_phip_mean;
  float **M_tawp_sm3, **M_tawp_sm2, **M_tawp_sm1, **M_tawp_mean;
  float **M_orient_sm3, **M_orient_sm2, **M_orient_sm1, **M_orient_mean;
  float **M_sm3, **M_sm2, **M_sm1;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\naghababaee_decomposition.exe\n");
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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

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
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Alphap_SM3.bin");
  if ((out_file1 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Alphap_SM2.bin");
  if ((out_file2 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Alphap_SM1.bin");
  if ((out_file3 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Alphap_mean.bin");
  if ((out_file4 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Phip_SM3.bin");
  if ((out_file5 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Phip_SM2.bin");
  if ((out_file6 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Phip_SM1.bin");
  if ((out_file7 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Phip_mean.bin");
  if ((out_file8 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Tawp_SM3.bin");
  if ((out_file9 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Tawp_SM2.bin");
  if ((out_file10 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Tawp_SM1.bin");
  if ((out_file11 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Tawp_mean.bin");
  if ((out_file12 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Orientation_max_SM3.bin");
  if ((out_file13 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Orientation_max_SM2.bin");
  if ((out_file14 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Orientation_max_SM1.bin");
  if ((out_file15 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_Orientation_max_mean.bin");
  if ((out_file16 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_M_SM3.bin");
  if ((out_file17 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_M_SM2.bin");
  if ((out_file18 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "Aghababaee_M_SM1.bin");
  if ((out_file19 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
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

  /* Mout = 19 * Nlig*Sub_Ncol */
  NBlockA += 19 * Sub_Ncol; NBlockB += 0;

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
  
  M_alphap_sm3 = matrix_float(NligBlock[0], Sub_Ncol);
  M_alphap_sm2 = matrix_float(NligBlock[0], Sub_Ncol);
  M_alphap_sm1 = matrix_float(NligBlock[0], Sub_Ncol);
  M_alphap_mean = matrix_float(NligBlock[0], Sub_Ncol);
  M_phip_sm3 = matrix_float(NligBlock[0], Sub_Ncol);
  M_phip_sm2 = matrix_float(NligBlock[0], Sub_Ncol);
  M_phip_sm1 = matrix_float(NligBlock[0], Sub_Ncol);
  M_phip_mean = matrix_float(NligBlock[0], Sub_Ncol);
  M_tawp_sm3 = matrix_float(NligBlock[0], Sub_Ncol);
  M_tawp_sm2 = matrix_float(NligBlock[0], Sub_Ncol);
  M_tawp_sm1 = matrix_float(NligBlock[0], Sub_Ncol);
  M_tawp_mean = matrix_float(NligBlock[0], Sub_Ncol);
  M_orient_sm3 = matrix_float(NligBlock[0], Sub_Ncol);
  M_orient_sm2 = matrix_float(NligBlock[0], Sub_Ncol);
  M_orient_sm1 = matrix_float(NligBlock[0], Sub_Ncol);
  M_orient_mean = matrix_float(NligBlock[0], Sub_Ncol);
  M_sm3 = matrix_float(NligBlock[0], Sub_Ncol);
  M_sm2 = matrix_float(NligBlock[0], Sub_Ncol);
  M_sm1 = matrix_float(NligBlock[0], Sub_Ncol);
  
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

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

hh_re = hh_im = vv_re = vv_im = hv_re = hv_im = 0.;
alpha_re = alpha_im = alpha_abs = 0.;
ro_re = ro_im = ro_abs = ro_angle = 0.;
landa_re = landa_im = landa_abs = landa_angle = 0.;
a = cos_taw = sin_taw = 0.;
R11 = R12 = R13 = R14 = R21 = R22 = R23 = R24 = 0.;
R31 = R32 = R33 = R34 = R41 = R42 = R43 = R44 = 0.;
value_re = value_im = 0.;
Sym_max1_re = Sym_max1_im = Sym_max2_re = Sym_max2_im = Sym_max3_re = Sym_max3_im = Sym_max4_re = Sym_max4_im = Sym_max_abs = 0.;
Mu1_re = Mu1_im = Mu2_re = Mu2_im = Mu3_re = Mu3_im = 0.;
#pragma omp parallel for private(col, k, Np, M, V, lambda, M_avg) firstprivate(p, orient_max, Mu1_abs, Mu1_angle, Mu2_abs, Mu2_angle, Mu3_abs, hh_re, hh_im, vv_re, vv_im, hv_re, hv_im, alpha_re, alpha_im, alpha_abs, ro_re, ro_im, ro_abs, ro_angle, landa_re, landa_im, landa_abs, landa_angle, a, cos_taw, sin_taw, R11, R12, R13, R14, R21, R22, R23, R24, R31, R32, R33, R34, R41, R42, R43, R44, value_re, value_im, Sym_max1_re, Sym_max1_im, Sym_max2_re, Sym_max2_im, Sym_max3_re, Sym_max3_im, Sym_max4_re, Sym_max4_im, Sym_max_abs, Mu1_re, Mu1_im, Mu2_re, Mu2_im, Mu3_re, Mu3_im) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
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

        for (k = 0; k < 3; k++) {
          if (lambda[k] < 0.) lambda[k] = 0.;
          p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
          if (p[k] < 0.) p[k] = 0.;
          if (p[k] > 1.) p[k] = 1.;
          }

        for (k = 0; k < 3; k++) {
          hh_re = (sqrt(lambda[k])*(V[0][k][0] + V[1][k][0]))/sqrt(2.);
          hh_im = (sqrt(lambda[k])*(V[0][k][1] + V[1][k][1]))/sqrt(2.);
          vv_re = (sqrt(lambda[k])*(V[0][k][0] - V[1][k][0]))/sqrt(2.);
          vv_im = (sqrt(lambda[k])*(V[0][k][1] - V[1][k][1]))/sqrt(2.);
          hv_re = (sqrt(lambda[k])*(V[2][k][0]))/sqrt(2.);
          hv_im = (sqrt(lambda[k])*(V[2][k][1]))/sqrt(2.);

          alpha_re = (hh_re + vv_re)/sqrt(2.);
          alpha_im = (hh_im + vv_im)/sqrt(2.);
          alpha_abs = sqrt(alpha_re * alpha_re + alpha_im * alpha_im);
          ro_re = hh_re - alpha_re/sqrt(2.) - hv_im;
          ro_im = hh_im - alpha_im/sqrt(2.) + hv_re;
          ro_abs = sqrt(ro_re * ro_re + ro_im * ro_im);
          ro_angle = atan2(ro_im, ro_re);
          landa_re = ro_re + 2.*hv_im;
          landa_im = ro_im - 2.*hv_re;
          landa_abs = sqrt(landa_re * landa_re + landa_im * landa_im);
          landa_angle = atan2(landa_im, landa_re);
          a = hh_re * hh_re + hh_im * hh_im;
          a += hv_re * hv_re + hv_im * hv_im;
          a += hv_re * hv_re + hv_im * hv_im;
          a += vv_re * vv_re + vv_im * vv_im;
          a = sqrt(a);
          cos_taw=sqrt((alpha_abs*alpha_abs+(landa_abs+ro_abs)*(landa_abs+ro_abs)/2.)/(alpha_abs*alpha_abs+landa_abs*landa_abs+ro_abs*ro_abs));
          sin_taw=((ro_abs-landa_abs)/sqrt(2.))/sqrt(alpha_abs*alpha_abs+landa_abs*landa_abs+ro_abs*ro_abs);
          orient_max[k] = (ro_angle-landa_angle)/4.;
          R11 = 0.5*(cos(2.*orient_max[k])+1.);
          R12 = 0.5*(-sin(2.*orient_max[k]));
          R13 = 0.5*(-sin(2.*orient_max[k]));
          R14 = 0.5*(1.-cos(2.*orient_max[k]));
          R21 = 0.5*(sin(2.*orient_max[k]));
          R22 = 0.5*(cos(2.*orient_max[k])+1.);
          R23 = 0.5*(cos(2.*orient_max[k])-1.);
          R24 = 0.5*(-sin(2.*orient_max[k]));
          R31 = 0.5*(sin(2.*orient_max[k]));
          R32 = 0.5*(cos(2.*orient_max[k])-1.);
          R33 = 0.5*(cos(2.*orient_max[k])+1.);
          R34 = 0.5*(-sin(2.*orient_max[k]));
          R41 = 0.5*(1.-cos(2.*orient_max[k]));
          R42 = 0.5*(sin(2.*orient_max[k]));
          R43 = 0.5*(sin(2.*orient_max[k]));
          R44 = 0.5*(cos(2.*orient_max[k])+1.);
          value_re = (cos((ro_angle+landa_angle)/2.)/sqrt(2.))*(landa_abs+ro_abs)*(1./sqrt(2.));
          value_im = (sin((ro_angle+landa_angle)/2.)/sqrt(2.))*(landa_abs+ro_abs)*(1./sqrt(2.));
          Sym_max1_re = alpha_re*(1./sqrt(2.))*(R11+R14)+value_re*(R11-R14);
          Sym_max1_im = alpha_im*(1./sqrt(2.))*(R11+R14)+value_im*(R11-R14);
          Sym_max2_re = alpha_re*(1./sqrt(2.))*(R21+R24)+value_re*(R21-R24);
          Sym_max2_im = alpha_im*(1./sqrt(2.))*(R21+R24)+value_im*(R21-R24);
          Sym_max3_re = alpha_re*(1./sqrt(2.))*(R31+R34)+value_re*(R31-R34);
          Sym_max3_im = alpha_im*(1./sqrt(2.))*(R31+R34)+value_im*(R31-R34);
          Sym_max4_re = alpha_re*(1./sqrt(2.))*(R41+R44)+value_re*(R41-R44);
          Sym_max4_im = alpha_im*(1./sqrt(2.))*(R41+R44)+value_im*(R41-R44);
          Sym_max_abs = Sym_max1_re * Sym_max1_re + Sym_max1_im * Sym_max1_im;
          Sym_max_abs += Sym_max2_re * Sym_max2_re + Sym_max2_im * Sym_max2_im;
          Sym_max_abs += Sym_max3_re * Sym_max3_re + Sym_max3_im * Sym_max3_im;
          Sym_max_abs += Sym_max4_re * Sym_max4_re + Sym_max4_im * Sym_max4_im;
          Sym_max_abs = sqrt(Sym_max_abs);
          Mu1_re = a*cos_taw*(1./Sym_max_abs)*alpha_re;
          Mu1_im = a*cos_taw*(1./Sym_max_abs)*alpha_im;
          Mu1_abs[k] = sqrt(Mu1_re * Mu1_re + Mu1_im * Mu1_im);
          Mu1_angle[k] = atan2(Mu1_im, Mu1_re);
          Mu2_re = a*cos_taw*(1./Sym_max_abs)*(cos((ro_angle + landa_angle)/2.)/sqrt(2.))*(landa_abs+ro_abs);
          Mu2_im = a*cos_taw*(1./Sym_max_abs)*(sin((ro_angle + landa_angle)/2.)/sqrt(2.))*(landa_abs+ro_abs);
          Mu2_abs[k] = sqrt(Mu2_re * Mu2_re + Mu2_im * Mu2_im);
          Mu2_angle[k] = atan2(Mu2_im, Mu2_re);
          Mu3_re = a*sin_taw*sin((ro_angle + landa_angle)/2);
          Mu3_im = -a*sin_taw*cos((ro_angle + landa_angle)/2);
          Mu3_abs[k] = sqrt(Mu3_re * Mu3_re + Mu3_im * Mu3_im);
          }

        M_alphap_sm3[lig][col] = (atan(Mu2_abs[0] / Mu1_abs[0]))*180./pi;
        M_alphap_sm2[lig][col] = (atan(Mu2_abs[1] / Mu1_abs[1]))*180./pi;
        M_alphap_sm1[lig][col] = (atan(Mu2_abs[2] / Mu1_abs[2]))*180./pi;
        M_alphap_mean[lig][col] = p[0]*M_alphap_sm3[lig][col] + p[1]*M_alphap_sm2[lig][col] + p[2]*M_alphap_sm1[lig][col];
        
        M_phip_sm3[lig][col] = (Mu2_angle[0] - Mu1_angle[0])*180./pi;
        M_phip_sm2[lig][col] = (Mu2_angle[1] - Mu1_angle[1])*180./pi;
        M_phip_sm1[lig][col] = (Mu2_angle[2] - Mu1_angle[2])*180./pi;
        M_phip_mean[lig][col] = p[0]*M_phip_sm3[lig][col] + p[1]*M_phip_sm2[lig][col] + p[2]*M_phip_sm1[lig][col];

        M_tawp_sm3[lig][col] = (asin(Mu3_abs[0]/sqrt(Mu1_abs[0]*Mu1_abs[0]+Mu2_abs[0]*Mu2_abs[0]+Mu3_abs[0]*Mu3_abs[0])))*180./pi;
        M_tawp_sm2[lig][col] = (asin(Mu3_abs[1]/sqrt(Mu1_abs[0]*Mu1_abs[0]+Mu2_abs[0]*Mu2_abs[0]+Mu3_abs[0]*Mu3_abs[0])))*180./pi;
        M_tawp_sm1[lig][col] = (asin(Mu3_abs[2]/sqrt(Mu1_abs[0]*Mu1_abs[0]+Mu2_abs[0]*Mu2_abs[0]+Mu3_abs[0]*Mu3_abs[0])))*180./pi;
        M_tawp_mean[lig][col] = p[0]*M_tawp_sm3[lig][col] + p[1]*M_tawp_sm2[lig][col] + p[2]*M_tawp_sm1[lig][col];

        M_orient_sm3[lig][col] = (orient_max[0])*180./pi;
        M_orient_sm2[lig][col] = (orient_max[1])*180./pi;
        M_orient_sm1[lig][col] = (orient_max[3])*180./pi;
        M_orient_mean[lig][col] = p[0]*M_orient_sm3[lig][col] + p[1]*M_orient_sm2[lig][col] + p[2]*M_orient_sm1[lig][col];

        M_sm3[lig][col] = sqrt(Mu1_abs[0] * Mu1_abs[0] + Mu2_abs[0] * Mu2_abs[0] + Mu3_abs[0] * Mu3_abs[0]);
        M_sm2[lig][col] = sqrt(Mu1_abs[1] * Mu1_abs[1] + Mu2_abs[1] * Mu2_abs[1] + Mu3_abs[1] * Mu3_abs[1]);
        M_sm1[lig][col] = sqrt(Mu1_abs[2] * Mu1_abs[2] + Mu2_abs[2] * Mu2_abs[2] + Mu3_abs[2] * Mu3_abs[2]);
        } else {
        M_alphap_sm3[lig][col] = 0.; M_alphap_sm2[lig][col] = 0.;
        M_alphap_sm1[lig][col] = 0.; M_alphap_mean[lig][col] = 0.;
        M_phip_sm3[lig][col] = 0.; M_phip_sm2[lig][col] = 0.;
        M_phip_sm1[lig][col] = 0.; M_phip_mean[lig][col] = 0.;
        M_tawp_sm3[lig][col] = 0.; M_tawp_sm2[lig][col] = 0.;
        M_tawp_sm1[lig][col] = 0.; M_tawp_mean[lig][col] = 0.;
        M_orient_sm3[lig][col] = 0.; M_orient_sm2[lig][col] = 0.;
        M_orient_sm1[lig][col] = 0.; M_orient_mean[lig][col] = 0.;
        M_sm3[lig][col] = 0.; M_sm2[lig][col] = 0.; M_sm1[lig][col] = 0.;
        }
      }
    free_matrix3d_float(M, 3, 3);
    free_matrix3d_float(V, 3, 3);
    free_vector_float(lambda);
    free_matrix_float(M_avg,NpolarOut);
    }

/* OUTPUT FILE OPENING*/
  write_block_matrix_float(out_file1, M_alphap_sm3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file2, M_alphap_sm2, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file3, M_alphap_sm1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file4, M_alphap_mean, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file5, M_phip_sm3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file6, M_phip_sm2, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file7, M_phip_sm1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file8, M_phip_mean, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file9, M_tawp_sm3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file10, M_tawp_sm2, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file11, M_tawp_sm1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file12, M_tawp_mean, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file13, M_orient_sm3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file14, M_orient_sm2, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file15, M_orient_sm1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file16, M_orient_mean, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file17, M_sm3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file18, M_sm2, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file19, M_sm1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);  
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE OPENING*/
  fclose(out_file1); fclose(out_file2); fclose(out_file3);
  fclose(out_file4); fclose(out_file5); fclose(out_file6);
  fclose(out_file7); fclose(out_file8); fclose(out_file9);
  fclose(out_file10); fclose(out_file11); fclose(out_file12);
  fclose(out_file13); fclose(out_file14); fclose(out_file15);
  fclose(out_file16); fclose(out_file17); fclose(out_file18);
  fclose(out_file19);
  
/********************************************************************
********************************************************************/

  return 1;
}


