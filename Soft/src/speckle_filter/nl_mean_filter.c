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

File  : nl_mean_filter.c
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

Description :  Non Local Mean Filtering.
               
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
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3",
    "C4", "T2", "T3", "T4", "SPP"};
  char file_name_Mm[FilePathLength];
  char file_name_Dz[FilePathLength];
  char file_name_Dx[FilePathLength];
  char file_name_Det[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  int k,l;
  int Nlook, K;
  int NwinP, NwinPM1S2;
  int NwinS, NwinSM1S2;
  float sigma, sig, Cu, Cimax, det1, det2;
  float Dz1, Dx1, Mm1;
  float Dz2, Dx2, Mm2;
  float Dzij, Dxij, Mij;
  float kij, vcij, vc1, bij; 
  float vc2, temp, wk, Lee;
  int ligDone = 0;

/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  float ***M;
  float *det;
  float **MinMm;
  float **MinDz;
  float **MinDx;
  float **MinDet;
  float **Z;
  float **Wmax;
  double **Sd;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nnl_mean_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nws 	Nwin Row and Col\n");
strcat(UsageHelp," (int)   	-nwp 	Nwin Row and Col\n");
strcat(UsageHelp," (int)   	-nlk 	Nlook\n");
strcat(UsageHelp," (float) 	-k   	Threshold Coefficient\n");
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

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nws",int_cmd_prm,&NwinS,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwp",int_cmd_prm,&NwinP,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlk",int_cmd_prm,&Nlook,1,UsageHelp);
  get_commandline_prm(argc,argv,"-k",int_cmd_prm,&K,1,UsageHelp);
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

  NwinSM1S2 = (NwinS - 1) / 2;
  NwinPM1S2 = (NwinP - 1) / 2;

  /* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

//  if (FlagValid == 1) 
//    if ((in_valid = fopen(file_valid, "rb")) == NULL)
//      edit_error("Could not open input file : ", file_valid);

  sprintf(file_name_Mm, "%s%s", out_dir, "NL_mean_Mm.bin");
  sprintf(file_name_Dz, "%s%s", out_dir, "NL_mean_Dz.bin");
  sprintf(file_name_Dx, "%s%s", out_dir, "NL_mean_Dx.bin");
  sprintf(file_name_Det, "%s%s", out_dir, "NL_mean_Det.bin");

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

//  Valid = matrix_float(Sub_Nlig+NwinP, Sub_Ncol+NwinP);
  
  M_in = matrix3d_float(NpolarOut, Sub_Nlig+NwinS+NwinP, Sub_Ncol+NwinS+NwinP);
  M_out = matrix3d_float(NpolarOut, Sub_Nlig, Sub_Ncol);

/*
  if (NpolarOut == 4) M = matrix3d_float(2, 2, 2);
  if (NpolarOut == 9) M = matrix3d_float(3, 3, 2);
  if (NpolarOut == 16) M = matrix3d_float(4, 4, 2);
  det = vector_float(2);
*/

  MinMm = matrix_float(Sub_Nlig+NwinS, Sub_Ncol+NwinS);
  MinDz = matrix_float(Sub_Nlig+NwinS, Sub_Ncol+NwinS);
  MinDx = matrix_float(Sub_Nlig+NwinS, Sub_Ncol+NwinS);
  MinDet = matrix_float(Sub_Nlig+NwinS+NwinP, Sub_Ncol+NwinS+NwinP);
  Sd = matrix_double_float(Sub_Nlig+NwinP, Sub_Ncol+NwinP);
  Z = matrix_float(Sub_Nlig, Sub_Ncol);
  Wmax = matrix_float(Sub_Nlig, Sub_Ncol);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
//  if (FlagValid == 0) 
//    for (lig = 0; lig < Sub_Nlig+NwinP; lig++) 
//      for (col = 0; col < Sub_Ncol+NwinP; col++) 
//        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
  Cu = 1. / sqrt((float) Nlook);
  Cimax = 1.*Cu;
  sigma = NwinP*NwinP*sqrt( K / Nlook);
  sig = 1. / sqrt((float) Nlook);

/********************************************************************
********************************************************************/
/* READING DATA SETS */

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 2*(NwinSM1S2+NwinPM1S2)+1, 2*(NwinSM1S2+NwinPM1S2)+1, Off_lig, Off_col, Ncol);
    } else {
    read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 2*(NwinSM1S2+NwinPM1S2)+1, 2*(NwinSM1S2+NwinPM1S2)+1, Off_lig, Off_col, Ncol);
    }

  } else {

  /* Case of C,T or I */
  read_block_TCI_noavg(in_datafile, M_in, NpolarOut, 0, 1, Sub_Nlig, Sub_Ncol, 2*(NwinSM1S2+NwinPM1S2)+1, 2*(NwinSM1S2+NwinPM1S2)+1, Off_lig, Off_col, Ncol);
  }

//  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, 0, 1, Sub_Nlig, Sub_Ncol, NwinP, NwinP, Off_lig, Off_col, Ncol);

  read_matrix_float(file_name_Mm, MinMm, Sub_Nlig, Sub_Ncol, NwinS, NwinS);
  read_matrix_float(file_name_Dz, MinDz, Sub_Nlig, Sub_Ncol, NwinS, NwinS);
  read_matrix_float(file_name_Dx, MinDx, Sub_Nlig, Sub_Ncol, NwinS, NwinS);
  read_matrix_float(file_name_Det, MinDet, Sub_Nlig, Sub_Ncol, 2*(NwinSM1S2+NwinPM1S2)+1, 2*(NwinSM1S2+NwinPM1S2)+1);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
  ii = -1;
  for (k = -NwinSM1S2; k < 1 + NwinSM1S2; k++) {
    for (l = -NwinSM1S2; l < 1 +NwinSM1S2; l++) {
      ii++; PrintfLine(ii,NwinS*NwinS); 
      if ((k == 0)&& (l ==0)) {
        } else {
		ligDone = 0;
#pragma omp parallel for private(col,det1,det2,det,M) shared(ligDone) schedule(dynamic)
        for (lig = 0; lig < Sub_Nlig + 2*NwinPM1S2; lig++) {
          ligDone++;
          if (omp_get_thread_num() == 0) PrintfLine(ligDone,Sub_Nlig + 2*NwinPM1S2);
          if (NpolarOut == 4) M = matrix3d_float(2, 2, 2);
          if (NpolarOut == 9) M = matrix3d_float(3, 3, 2);
          if (NpolarOut == 16) M = matrix3d_float(4, 4, 2);
          det = vector_float(2);
          for (col = 0; col < Sub_Ncol + 2*NwinPM1S2; col++) {
            det1 = MinDet[NwinSM1S2+lig][NwinSM1S2+col];
            det2 = MinDet[NwinSM1S2+lig+k][NwinSM1S2+col+l];
            if (NpolarOut == 4) {
              M[0][0][0] = eps + M_in[0][NwinM1S2+lig][NwinM1S2+col]+M_in[0][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][0][1] = 0.;
              M[0][1][0] = eps + M_in[1][NwinM1S2+lig][NwinM1S2+col]+M_in[1][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][1][1] = eps + M_in[2][NwinM1S2+lig][NwinM1S2+col]+M_in[2][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][0][0] =  M[0][1][0];
              M[1][0][1] = -M[0][1][1];
              M[1][1][0] = eps + M_in[3][NwinM1S2+lig][NwinM1S2+col]+M_in[3][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][1][1] = 0.;
              DeterminantHermitianMatrix2(M, det);       
              }                 
            if (NpolarOut == 9) {
              M[0][0][0] = eps + M_in[0][NwinSM1S2+lig][NwinSM1S2+col]+M_in[0][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][0][1] = 0.;
              M[0][1][0] = eps + M_in[1][NwinSM1S2+lig][NwinSM1S2+col]+M_in[1][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][1][1] = eps + M_in[2][NwinSM1S2+lig][NwinSM1S2+col]+M_in[2][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][2][0] = eps + M_in[3][NwinSM1S2+lig][NwinSM1S2+col]+M_in[3][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][2][1] = eps + M_in[4][NwinSM1S2+lig][NwinSM1S2+col]+M_in[4][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][0][0] =  M[0][1][0];
              M[1][0][1] = -M[0][1][1];
              M[1][1][0] = eps + M_in[5][NwinSM1S2+lig][NwinSM1S2+col]+M_in[5][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][1][1] = 0.;
              M[1][2][0] = eps + M_in[6][NwinSM1S2+lig][NwinSM1S2+col]+M_in[6][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][2][1] = eps + M_in[7][NwinSM1S2+lig][NwinSM1S2+col]+M_in[7][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[2][0][0] =  M[0][2][0];
              M[2][0][1] = -M[0][2][1];
              M[2][1][0] =  M[1][2][0];
              M[2][1][1] = -M[1][2][1];
              M[2][2][0] = eps + M_in[8][NwinSM1S2+lig][NwinSM1S2+col]+M_in[8][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[2][2][1] = 0.;
              DeterminantHermitianMatrix3(M, det);
              }
            if (NpolarOut == 16) {
              M[0][0][0] = eps + M_in[0][NwinM1S2+lig][NwinM1S2+col]+M_in[0][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][0][1] = 0.;
              M[0][1][0] = eps + M_in[1][NwinM1S2+lig][NwinM1S2+col]+M_in[1][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][1][1] = eps + M_in[2][NwinM1S2+lig][NwinM1S2+col]+M_in[2][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][2][0] = eps + M_in[3][NwinM1S2+lig][NwinM1S2+col]+M_in[3][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][2][1] = eps + M_in[4][NwinM1S2+lig][NwinM1S2+col]+M_in[4][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][3][0] = eps + M_in[5][NwinM1S2+lig][NwinM1S2+col]+M_in[5][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[0][3][1] = eps + M_in[6][NwinM1S2+lig][NwinM1S2+col]+M_in[6][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][0][0] =  M[0][1][0];
              M[1][0][1] = -M[0][1][1];
              M[1][1][0] = eps + M_in[7][NwinM1S2+lig][NwinM1S2+col]+M_in[7][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][1][1] = 0.;
              M[1][2][0] = eps + M_in[8][NwinM1S2+lig][NwinM1S2+col]+M_in[8][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][2][1] = eps + M_in[9][NwinM1S2+lig][NwinM1S2+col]+M_in[9][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][3][0] = eps + M_in[10][NwinM1S2+lig][NwinM1S2+col]+M_in[10][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[1][3][1] = eps + M_in[11][NwinM1S2+lig][NwinM1S2+col]+M_in[11][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[2][0][0] =  M[0][2][0];
              M[2][0][1] = -M[0][2][1];
              M[2][1][0] =  M[1][2][0];
              M[2][1][1] = -M[1][2][1];
              M[2][2][0] = eps + M_in[12][NwinM1S2+lig][NwinM1S2+col]+M_in[12][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[2][2][1] = 0.;
              M[2][3][0] = eps + M_in[13][NwinM1S2+lig][NwinM1S2+col]+M_in[13][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[2][3][1] = eps + M_in[14][NwinM1S2+lig][NwinM1S2+col]+M_in[14][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[3][0][0] =  M[0][3][0];
              M[3][0][1] = -M[0][3][1];
              M[3][1][0] =  M[1][3][0];
              M[3][1][1] = -M[1][3][1];
              M[3][2][0] =  M[2][3][0];
              M[3][2][1] = -M[2][3][1];
              M[3][3][0] = eps + M_in[15][NwinM1S2+lig][NwinM1S2+col]+M_in[15][NwinSM1S2+lig+k][NwinSM1S2+col+l];
              M[3][3][1] = 0.;
              DeterminantHermitianMatrix4(M, det);        
              }      
              
            Sd[lig+1][col+1] = 6.*log(2.) + log((det1*det2+eps)/(det[0]*det[0]+eps));
            }
          if (NpolarOut == 4) free_matrix3d_float(M, 2, 2);
          if (NpolarOut == 9) free_matrix3d_float(M, 3, 3);
          if (NpolarOut == 16) free_matrix3d_float(M, 4, 4);
          free_vector_float(det);
          }
        //cumsum
#pragma omp parallel for private(lig) shared(ligDone) schedule(dynamic)
        for (col = 0; col < Sub_Ncol + NwinP; col++) {
          for (lig = 1; lig < Sub_Nlig + NwinP; lig++) {
            Sd[lig][col] = Sd[lig][col]+Sd[lig-1][col];
            }
          }
#pragma omp parallel for private(col) shared(ligDone) schedule(dynamic)
        for (lig = 0; lig < Sub_Nlig + NwinP; lig++) {
          for (col = 1; col < Sub_Ncol + NwinP; col++) {
            Sd[lig][col] = Sd[lig][col]+Sd[lig][col-1];
            }
          }

		ligDone = 0;
#pragma omp parallel for private(col,Np,Dz1,Dx1,Mm1,Dz2,Dx2,Mm2,Dzij,Mij,Dxij,kij,vcij,vc1,bij,vc2,temp,wk,Lee) shared(ligDone) schedule(dynamic)
        for (lig = 0; lig < Sub_Nlig; lig++) {
          ligDone++;
          if (omp_get_thread_num() == 0) PrintfLine(ligDone,Sub_Nlig);
          for (col = 0; col < Sub_Ncol; col++) {
            Dz1 = MinDz[NwinSM1S2+lig][NwinSM1S2+col];
            Dx1 = MinDx[NwinSM1S2+lig][NwinSM1S2+col];
            Mm1 = MinMm[NwinSM1S2+lig][NwinSM1S2+col];
            Dz2 = MinDz[NwinSM1S2+lig+k][NwinSM1S2+col+l];
            Dx2 = MinDx[NwinSM1S2+lig+k][NwinSM1S2+col+l];
            Mm2 = MinMm[NwinSM1S2+lig+k][NwinSM1S2+col+l];
            Dzij = ((Dz1+Dz2)/2.) + ((Mm1-Mm2)/2.)*((Mm1-Mm2)/2.);
            Mij = (Mm1+Mm2)/2.;
            Dxij = (Dzij - Mij*Mij*sig*sig)/(1. + sig*sig);
            if (Dxij < 0.) Dxij = 0.;
            kij = fabs((Dxij-((Dx1+Dx2)/2.)) / (Dzij-((Dx1+Dx2)/2.)));
            vcij = fabs(sqrt(fabs(Dzij-((Dx1+Dx2)/2.))) / Mij);
            if (vcij < Cimax) kij = 0.;
            vc1 = 1.;
            if (vcij > 0.7*sqrt(3./(float)Nlook)) vc1 = 0.;
            bij = Mm2 / (Mm1+eps);
            if ((Mm1 / (Mm2+eps)) <= bij) bij = Mm1 / (Mm2+eps);
            vc2 = 1.;
            if (bij < 0.65) vc2 = 0.;
            temp = Sd[NwinP+lig][NwinP+col]+Sd[lig][col]-Sd[NwinP+lig][col]-Sd[lig][NwinP+col];
            wk = 0.;
            if (temp > -sigma) wk = exp(temp/sigma);
            wk = wk*vc1*vc2;
            Z[lig][col] += wk;
            if (Wmax[lig][col] <= wk) Wmax[lig][col] = wk;
            for (Np = 0; Np < NpolarOut; Np++) {
               Lee = M_in[Np][NwinSM1S2+NwinPM1S2+lig+k][NwinSM1S2+NwinPM1S2+col+l]+kij*(M_in[Np][NwinSM1S2+NwinPM1S2+lig][NwinSM1S2+NwinPM1S2+col]-M_in[Np][NwinSM1S2+NwinPM1S2+lig+k][NwinSM1S2+NwinPM1S2+col+l]);
               M_out[Np][lig][col] = M_out[Np][lig][col] + wk*Lee;
              }
            }
          }
        }
      } //l
    } //k

  ligDone = 0;
#pragma omp parallel for private(col,Np) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < Sub_Nlig; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Wmax[lig][col] == 0.) Wmax[lig][col] = 1.;
      Z[lig][col] += Wmax[lig][col];
      for (Np = 0; Np < NpolarOut; Np++) {
        M_out[Np][lig][col] = (M_out[Np][lig][col] + Wmax[lig][col]*M_in[Np][NwinSM1S2+NwinPM1S2+lig][NwinSM1S2+NwinPM1S2+col])/(Z[lig][col]+eps);   
        }
      }
    }
      
  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
  
  free_matrix_float(MinMn, NligBlock[0]);
  free_matrix_float(MinDz, NligBlock[0]);
  free_matrix_float(MinDx, NligBlock[0]);
  free_matrix_float(MinDet, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}
