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

File  : nl_mean_sigma_pre_filter.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
Update  :
*--------------------------------------------------------------------
Pr. Hua Zhong
Key Laboratory of Intelligent Perception and Image Understanding
Ministery of Education of China
Xidian University, China
Email:hzhong@mail.xisidan.edu.cn
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

Description :  Non Local Mean Sigma Pre Filtering.
               
*--------------------------------------------------------------------
Translated and adapted in c language from : matlab routine
written by : Hua Zhong et al.
Robust Polarimetric SAR Despeckling Based on Nonlocal means
and distributed Lee filter
IEEE TGRS vol 52, n°7, july 2014
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

#define NPolType 11
/* LOCAL VARIABLES */
  FILE *out_Mm, *out_Dz, *out_Dx, *out_Det;
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3",
    "C4", "T2", "T3", "T4", "SPP"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  int k,l;
  int Nlook, NWtgtM1S2, NWtgt;
  int NumOne;
  int ligDone = 0;
  
  float sigma, newsigma, AI1, AI2;
  float m1, v1, k1;
  float meanW1, meanW2, meanW3, meanW4, Nmean;
  float varW1, varW2, varW3, varW4;
  float varx, b;
  float estimator1, estimator2, estimator3, estimator4;
  float T11IA1, T11IA2, T22IA1, T22IA2, T33IA1, T33IA2, T44IA1, T44IA2;
  float W11, W22, W33, W44;
 
/* Matrix arrays */
  float ***M_in;
  float **W;
  float **SS;
  float **MoutMm;
  float **MoutDz;
  float **MoutDx;
  float **MoutDet;
  float ***M;
  float *det;
  float **block1;
  float **block2;
  float **block3;
  float **block4;
         
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nnl_mean_sigma_pre_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nw 	Nwin Row and Col - Analysis\n");
strcat(UsageHelp," (int)   	-nwt 	Nwin Row and Col - Target\n");
strcat(UsageHelp," (int)   	-nlk 	Nlook\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nw",int_cmd_prm,&Nwin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwt",int_cmd_prm,&NWtgt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&Nlook,1,UsageHelp);
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

  NwinM1S2 = (Nwin - 1) / 2;
  NwinL = Nwin; NwinC = Nwin;
  NWtgtM1S2 = (NWtgt - 1) / 2;

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
  sprintf(file_name, "%s%s", out_dir, "NL_mean_Mm.bin");
  if ((out_Mm = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "NL_mean_Dz.bin");
  if ((out_Dz = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "NL_mean_Dx.bin");
  if ((out_Dx = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "NL_mean_Det.bin");
  if ((out_Det= fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

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

  /* Mm = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Dz = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Dx = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Det = Nlig*Sub_Ncol */
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

  Valid = matrix_float(NligBlock[0]+Nwin, Sub_Ncol+Nwin);

  M_in = matrix3d_float(NpolarOut, NligBlock[0]+Nwin, Sub_Ncol+Nwin);
  MoutMm = matrix_float(NligBlock[0], Sub_Ncol);
  MoutDz = matrix_float(NligBlock[0], Sub_Ncol);
  MoutDx = matrix_float(NligBlock[0], Sub_Ncol);
  MoutDet = matrix_float(NligBlock[0], Sub_Ncol);
/*
  if (NpolarOut == 4) M = matrix3d_float(2, 2, 2);
  if (NpolarOut == 9) M = matrix3d_float(3, 3, 2);
  if (NpolarOut == 16) M = matrix3d_float(4, 4, 2);
  det = vector_float(2);
  W = matrix_float(Nwin, Nwin);
  SS = matrix_float(Nwin, Nwin);
  block1 = matrix_float(NWtgt, NWtgt);
  block2 = matrix_float(NWtgt, NWtgt);
  block3 = matrix_float(NWtgt, NWtgt);
  block4 = matrix_float(NWtgt, NWtgt);
*/  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < Sub_Nlig+Nwin; lig++) 
      for (col = 0; col < Sub_Ncol+Nwin; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
  sigma = 1. / sqrt((float) Nlook);

  if (Nlook == 1) {
    newsigma = 0.8191; AI1 = 0.084; AI2 = 3.941;
    }
  if (Nlook == 2) {
    newsigma = 0.5699; AI1 = 0.221; AI2 = 2.744;
    }
  if (Nlook == 3) {
    newsigma = 0.4624; AI1 = 0.313; AI2 = 2.320;
    }
  if (Nlook == 4) {
    newsigma = 0.3991; AI1 = 0.378; AI2 = 2.094;
    }
  if (Nlook > 4) {
    newsigma = 0.2478; AI1 = 0.548; AI2 = 1.5820;
    }
    
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

#pragma omp parallel for private(col,M,det,k,l,block1,block2,block3,block4,meanW1,meanW2,meanW3,meanW4,Nmean,varW1,varW2,varW3,varW4,varx,b,estimator1,T11IA1,T11IA2,estimator2,T22IA1,T22IA2,NumOne,SS,W11,W22,W33,estimator3,T33IA1,T33IA2,estimator4,T44IA1,T44IA2,W,m1,v1,k1) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    if (NpolarOut == 4) M = matrix3d_float(2, 2, 2);
    if (NpolarOut == 9) M = matrix3d_float(3, 3, 2);
    if (NpolarOut == 16) M = matrix3d_float(4, 4, 2);
    det = vector_float(2);
    W = matrix_float(Nwin, Nwin);
    SS = matrix_float(Nwin, Nwin);
    block1 = matrix_float(NWtgt, NWtgt);
    block2 = matrix_float(NWtgt, NWtgt);
    block3 = matrix_float(NWtgt, NWtgt);
    block4 = matrix_float(NWtgt, NWtgt);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinM1S2+lig][NwinM1S2+col] == 1.) {
        if (NpolarOut == 4) {
          M[0][0][0] = eps + M_in[0][NwinM1S2+lig][NwinM1S2+col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_in[1][NwinM1S2+lig][NwinM1S2+col];
          M[0][1][1] = eps + M_in[2][NwinM1S2+lig][NwinM1S2+col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_in[3][NwinM1S2+lig][NwinM1S2+col];
          M[1][1][1] = 0.;
          DeterminantHermitianMatrix2(M, det);       
          }      
        if (NpolarOut == 9) {
          M[0][0][0] = eps + M_in[0][NwinM1S2+lig][NwinM1S2+col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_in[1][NwinM1S2+lig][NwinM1S2+col];
          M[0][1][1] = eps + M_in[2][NwinM1S2+lig][NwinM1S2+col];
          M[0][2][0] = eps + M_in[3][NwinM1S2+lig][NwinM1S2+col];
          M[0][2][1] = eps + M_in[4][NwinM1S2+lig][NwinM1S2+col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_in[5][NwinM1S2+lig][NwinM1S2+col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_in[6][NwinM1S2+lig][NwinM1S2+col];
          M[1][2][1] = eps + M_in[7][NwinM1S2+lig][NwinM1S2+col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_in[8][NwinM1S2+lig][NwinM1S2+col];
          M[2][2][1] = 0.;
          DeterminantHermitianMatrix3(M, det);
          }
        if (NpolarOut == 16) {
          M[0][0][0] = eps + M_in[0][NwinM1S2+lig][NwinM1S2+col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_in[1][NwinM1S2+lig][NwinM1S2+col];
          M[0][1][1] = eps + M_in[2][NwinM1S2+lig][NwinM1S2+col];
          M[0][2][0] = eps + M_in[3][NwinM1S2+lig][NwinM1S2+col];
          M[0][2][1] = eps + M_in[4][NwinM1S2+lig][NwinM1S2+col];
          M[0][3][0] = eps + M_in[5][NwinM1S2+lig][NwinM1S2+col];
          M[0][3][1] = eps + M_in[6][NwinM1S2+lig][NwinM1S2+col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_in[7][NwinM1S2+lig][NwinM1S2+col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_in[8][NwinM1S2+lig][NwinM1S2+col];
          M[1][2][1] = eps + M_in[9][NwinM1S2+lig][NwinM1S2+col];
          M[1][3][0] = eps + M_in[10][NwinM1S2+lig][NwinM1S2+col];
          M[1][3][1] = eps + M_in[11][NwinM1S2+lig][NwinM1S2+col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_in[12][NwinM1S2+lig][NwinM1S2+col];
          M[2][2][1] = 0.;
          M[2][3][0] = eps + M_in[13][NwinM1S2+lig][NwinM1S2+col];
          M[2][3][1] = eps + M_in[14][NwinM1S2+lig][NwinM1S2+col];
          M[3][0][0] =  M[0][3][0];
          M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0];
          M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0];
          M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + M_in[15][NwinM1S2+lig][NwinM1S2+col];
          M[3][3][1] = 0.;
          DeterminantHermitianMatrix4(M, det);        
          }      
          
        MoutDet[lig][col] = det[0];

        for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
          for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
            if (NpolarOut == 4) {
              block1[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X211][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              block2[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X222][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              }
            if (NpolarOut == 9) {
              block1[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X311][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              block2[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X322][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              block3[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X333][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              }
            if (NpolarOut == 16) {
              block1[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X411][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              block2[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X422][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              block3[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X433][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              block4[NWtgtM1S2+k][NWtgtM1S2+l] = M_in[X433][NwinM1S2+lig+k][NwinM1S2+col+l]*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              }
            }
        meanW1 = 0.; meanW2 = 0.; meanW3 = 0.; meanW4 = 0.; Nmean = 0.;
        varW1 = 0.; varW2 = 0.; varW3 = 0.; varW4 = 0.;

        if (NpolarOut == 4) {
          for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
            for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
              Nmean += Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              meanW1 += block1[NWtgtM1S2+k][NWtgtM1S2+l];
              meanW2 += block2[NWtgtM1S2+k][NWtgtM1S2+l];
              }
          meanW1 /= Nmean; meanW2 /= Nmean;
          for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
            for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
              varW1 += (block1[NWtgtM1S2+k][NWtgtM1S2+l]-meanW1)*(block1[NWtgtM1S2+k][NWtgtM1S2+l]-meanW1);
              varW2 += (block2[NWtgtM1S2+k][NWtgtM1S2+l]-meanW2)*(block2[NWtgtM1S2+k][NWtgtM1S2+l]-meanW2);
              }
          varW1 /= (Nmean-1); varW2 /= (Nmean-1);
        
          varx = (varW1 - (meanW1*sigma)*(meanW1*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW1 != 0.) {
            b = varx / varW1;
            estimator1 = (1. - b)*meanW1 + b*M_in[X211][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator1 = meanW1;
            }
          T11IA1 = AI1*estimator1; T11IA2 = AI2*estimator1;
          varx = (varW2 - (meanW2*sigma)*(meanW2*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW2 != 0.) {
            b = varx / varW2;
            estimator2 = (1. - b)*meanW2 + b*M_in[X222][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator2 = meanW2;
            }
          T22IA1 = AI1*estimator2; T22IA2 = AI2*estimator2;
        
          NumOne = 0;
          for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
            for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
              SS[NwinM1S2+k][NwinM1S2+l] = 0.;
              W11 = M_in[X211][NwinM1S2+lig+k][NwinM1S2+col+l];
              W22 = M_in[X222][NwinM1S2+lig+k][NwinM1S2+col+l];
              if ((W11 >= T11IA1)&&(W11 <= T11IA2)&&(W22 >= T22IA1)&&(W22 <= T22IA2)) {
                SS[NwinM1S2+k][NwinM1S2+l] = 1.;
                NumOne++;
                }
              }
          }
        
        if (NpolarOut == 9) {
          for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
            for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
              Nmean += Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              meanW1 += block1[NWtgtM1S2+k][NWtgtM1S2+l];
              meanW2 += block2[NWtgtM1S2+k][NWtgtM1S2+l];
              meanW3 += block3[NWtgtM1S2+k][NWtgtM1S2+l];
              }
          meanW1 /= Nmean; meanW2 /= Nmean; meanW3 /= Nmean; 
          for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
            for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
              varW1 += (block1[NWtgtM1S2+k][NWtgtM1S2+l]-meanW1)*(block1[NWtgtM1S2+k][NWtgtM1S2+l]-meanW1);
              varW2 += (block2[NWtgtM1S2+k][NWtgtM1S2+l]-meanW2)*(block2[NWtgtM1S2+k][NWtgtM1S2+l]-meanW2);
              varW3 += (block3[NWtgtM1S2+k][NWtgtM1S2+l]-meanW3)*(block3[NWtgtM1S2+k][NWtgtM1S2+l]-meanW3);
              }
          varW1 /= (Nmean-1); varW2 /= (Nmean-1); varW3 /= (Nmean-1); 
        
          varx = (varW1 - (meanW1*sigma)*(meanW1*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW1 != 0.) {
            b = varx / varW1;
            estimator1 = (1. - b)*meanW1 + b*M_in[X311][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator1 = meanW1;
            }
          T11IA1 = AI1*estimator1; T11IA2 = AI2*estimator1;
          varx = (varW2 - (meanW2*sigma)*(meanW2*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW2 != 0.) {
            b = varx / varW2;
            estimator2 = (1. - b)*meanW2 + b*M_in[X322][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator2 = meanW2;
            }
          T22IA1 = AI1*estimator2; T22IA2 = AI2*estimator2;
          varx = (varW3 - (meanW3*sigma)*(meanW3*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW3 != 0.) {
            b = varx / varW3;
            estimator3 = (1. - b)*meanW3 + b*M_in[X333][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator3 = meanW3;
            }
          T33IA1 = AI1*estimator3; T33IA2 = AI2*estimator3;
        
          NumOne = 0;
          for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
            for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
              SS[NwinM1S2+k][NwinM1S2+l] = 0.;
              W11 = M_in[X311][NwinM1S2+lig+k][NwinM1S2+col+l];
              W22 = M_in[X322][NwinM1S2+lig+k][NwinM1S2+col+l];
              W33 = M_in[X333][NwinM1S2+lig+k][NwinM1S2+col+l];
              if ((W11 >= T11IA1)&&(W11 <= T11IA2)&&(W22 >= T22IA1)&&(W22 <= T22IA2)&&(W33 >= T33IA1)&&(W33 <= T33IA2)) {
                SS[NwinM1S2+k][NwinM1S2+l] = 1.;
                NumOne++;
                }
              }
          }
            
        if (NpolarOut == 16) {
          for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
            for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
              Nmean += Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
              meanW1 += block1[NWtgtM1S2+k][NWtgtM1S2+l];
              meanW2 += block2[NWtgtM1S2+k][NWtgtM1S2+l];
              meanW3 += block3[NWtgtM1S2+k][NWtgtM1S2+l];
              meanW4 += block4[NWtgtM1S2+k][NWtgtM1S2+l];
              }
          meanW1 /= Nmean; meanW2 /= Nmean; meanW3 /= Nmean; meanW4 /= Nmean; 
          for (k = -NWtgtM1S2; k < 1 + NWtgtM1S2; k++)
            for (l = -NWtgtM1S2; l < 1 +NWtgtM1S2; l++) {
              varW1 += (block1[NWtgtM1S2+k][NWtgtM1S2+l]-meanW1)*(block1[NWtgtM1S2+k][NWtgtM1S2+l]-meanW1);
              varW2 += (block2[NWtgtM1S2+k][NWtgtM1S2+l]-meanW2)*(block2[NWtgtM1S2+k][NWtgtM1S2+l]-meanW2);
              varW3 += (block3[NWtgtM1S2+k][NWtgtM1S2+l]-meanW3)*(block3[NWtgtM1S2+k][NWtgtM1S2+l]-meanW3);
              varW4 += (block4[NWtgtM1S2+k][NWtgtM1S2+l]-meanW4)*(block4[NWtgtM1S2+k][NWtgtM1S2+l]-meanW4);
              }
          varW1 /= (Nmean-1); varW2 /= (Nmean-1); varW3 /= (Nmean-1); varW4 /= (Nmean-1); 
        
          varx = (varW1 - (meanW1*sigma)*(meanW1*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW1 != 0.) {
            b = varx / varW1;
            estimator1 = (1. - b)*meanW1 + b*M_in[X411][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator1 = meanW1;
            }
          T11IA1 = AI1*estimator1; T11IA2 = AI2*estimator1;
          varx = (varW2 - (meanW2*sigma)*(meanW2*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW2 != 0.) {
            b = varx / varW2;
            estimator2 = (1. - b)*meanW2 + b*M_in[X422][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator2 = meanW2;
            }
          T22IA1 = AI1*estimator2; T22IA2 = AI2*estimator2;
          varx = (varW3 - (meanW3*sigma)*(meanW3*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW3 != 0.) {
            b = varx / varW3;
            estimator3 = (1. - b)*meanW3 + b*M_in[X433][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator3 = meanW3;
            }
          T33IA1 = AI1*estimator3; T33IA2 = AI2*estimator3;
          varx = (varW4 - (meanW4*sigma)*(meanW4*newsigma)) / (1. + newsigma*newsigma);
          if (varx < 0.) varx = 0.;
          if (varW4 != 0.) {
            b = varx / varW4;
            estimator4 = (1. - b)*meanW4 + b*M_in[X444][NwinM1S2+lig][NwinM1S2+col];
            } else {
            estimator4 = meanW4;
            }
          T44IA1 = AI1*estimator4; T44IA2 = AI2*estimator4;
        
          NumOne = 0;
          for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
            for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
              SS[NwinM1S2+k][NwinM1S2+l] = 0.;
              W11 = M_in[X411][NwinM1S2+lig+k][NwinM1S2+col+l];
              W22 = M_in[X422][NwinM1S2+lig+k][NwinM1S2+col+l];
              W33 = M_in[X433][NwinM1S2+lig+k][NwinM1S2+col+l];
              W44 = M_in[X444][NwinM1S2+lig+k][NwinM1S2+col+l];
              if ((W11 >= T11IA1)&&(W11 <= T11IA2)&&(W22 >= T22IA1)&&(W22 <= T22IA2)&&(W33 >= T33IA1)&&(W33 <= T33IA2)&&(W44 >= T44IA1)&&(W44 <= T44IA2)) {
                SS[NwinM1S2+k][NwinM1S2+l] = 1.;
                NumOne++;
                }
              }
          }
            

        if (NumOne == 0) {
          SS[NwinM1S2][NwinM1S2] = 1.;
          NumOne = 1;
          }
   
        for (k = -NwinM1S2; k < 1 + NwinM1S2; k++)
          for (l = -NwinM1S2; l < 1 +NwinM1S2; l++) {
            if (NpolarOut == 4) W[NwinM1S2+k][NwinM1S2+l] = (M_in[X211][NwinM1S2+lig+k][NwinM1S2+col+l]+M_in[X222][NwinM1S2+lig+k][NwinM1S2+col+l])*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
            if (NpolarOut == 9) W[NwinM1S2+k][NwinM1S2+l] = (M_in[X311][NwinM1S2+lig+k][NwinM1S2+col+l]+M_in[X322][NwinM1S2+lig+k][NwinM1S2+col+l]+M_in[X333][NwinM1S2+lig+k][NwinM1S2+col+l])*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
            if (NpolarOut == 16) W[NwinM1S2+k][NwinM1S2+l] = (M_in[X411][NwinM1S2+lig+k][NwinM1S2+col+l]+M_in[X422][NwinM1S2+lig+k][NwinM1S2+col+l]+M_in[X433][NwinM1S2+lig+k][NwinM1S2+col+l]+M_in[X444][NwinM1S2+lig+k][NwinM1S2+col+l])*Valid[NwinM1S2+lig+k][NwinM1S2+col+l];
            }

        m1 = 0.;
        for (k = 0; k < Nwin; k++)
          for (l = 0; l < Nwin; l++) {
            m1 += SS[k][l]*W[k][l];
            }
        m1 /= NumOne;
        v1 = 0.;
        for (k = 0; k < Nwin; k++)
          for (l = 0; l < Nwin; l++) {
            if ((SS[k][l]*W[k][l]) != 0.) v1 += (SS[k][l]*W[k][l]-m1)*(SS[k][l]*W[k][l]-m1);
            }
        v1 /= Nwin*(NwinM1S2+1);
        k1 = (v1 - m1*m1*sigma*sigma)/(1.+sigma*sigma);
        if (k1 < 0.) k1 = 0.;

        MoutMm[lig][col] = m1;
        MoutDz[lig][col] = v1;
        MoutDx[lig][col] = k1;     
        } else {
        MoutMm[lig][col] = 0.;
        MoutDz[lig][col] = 0.;
        MoutDx[lig][col] = 0.;
        MoutDet[lig][col] = 0.;
        }
      }
    if (NpolarOut == 4) free_matrix3d_float(M,2,2);
    if (NpolarOut == 9) free_matrix3d_float(M,3,3);
    if (NpolarOut == 16) free_matrix3d_float(M,4,4);
    free_vector_float(det);	  
    free_matrix_float(W, Nwin);
    free_matrix_float(SS, Nwin);
    free_matrix_float(block1, NWtgt);
    free_matrix_float(block2, NWtgt);
    free_matrix_float(block3, NWtgt);
    free_matrix_float(block4, NWtgt);
    }
  write_block_matrix_float(out_Mm, MoutMm, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Dz, MoutDz, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Dx, MoutDx, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Det, MoutDet, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  
  free_matrix_float(MoutMn, NligBlock[0]);
  free_matrix_float(MoutDz, NligBlock[0]);
  free_matrix_float(MoutDx, NligBlock[0]);
  free_matrix_float(MoutDet, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_Mm);
  fclose(out_Dz);
  fclose(out_Dx);
  fclose(out_Det);
  
/********************************************************************
********************************************************************/

  return 1;
}
