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

File   : PolSARap_Forest_Height_Estimation_Dual_Baseline.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2014
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

Description :  PolSARap Forest Showcase

Forest Height Estimation Single Baseline

*--------------------------------------------------------------------

Translated and adapted in c language from : IDL routine
; $Id: pro height_estimation_dual_baseline, Tm11_1, Tm22_1, Om12_1, $
kappa_zeta_1,lu_table_1, Tm11_2, Tm22_2, Om12_2, kappa_zeta_2, $
lu_table_2, height_ttt,sigma_ttt, height_est

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; K. PAPATHANASSIOU
;
********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
int get_gamma_v(cplx **txx, cplx **Omega12, float piece1, float piece2, float kappa_z, int phi_size);
int coh_boundary(cplx **T, cplx **O12, float piece1, float piece2, cplx *boundary_p, int phi_size);
int fit_the_line(cplx *boundary, int boundary_size);
int ground_point(float kappa_zeta);
int height_inversion_sk(float *sigma_ttt, int size_sigma, float *height_ttt, int size_height, float *deco_org, int size_deco_org, cplx **lu_table1, cplx gamma_v1);

/* GLOVAL VAR */ 
int new_size_sigma;
float ratio, line_slope, line_const;
float *heights, *sigma_r, *index_back;
cplx coh_first, coh_second, ccc_x1, ccc_x2; 
cplx ground, vol_only;

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
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  FILE *in_file_kz1, *in_file_kz2, *out_file;
  char file_kz1[FilePathLength], file_kz2[FilePathLength];
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l;
  int phi_size, xxx_index;
  int size_sigma, size_height, size_ddd, size_max;  
  int new_size_sigma1, new_size_sigma2;  
  float piece1, piece2;
  float max_height, min_height, delta_height;
  float max_sigma, min_sigma, delta_sigma;
  float diff_all_min;
  cplx ground_point_1, vol_only_1;
  cplx ground_point_2, vol_only_2;
  cplx z1, z2, AAA;
  float z0, BBB;

  
/* Matrix arrays */
  cplx **TT11,**TT12,**TT22, **TT;
  
/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***S_in3;
  float ***M_in1;
  float ***M_in2;
  
  float *Mean1;
  float *Mean2;
  float *Buffer1;
  float *Buffer2;

  float **M_kz1;
  float **M_kz2;

  float *height_ttt;
  float *sigma_ttt;
  float *ddd_ttt;
  cplx **lu_table;
  cplx **lu_table_1;
  cplx **lu_table_2;
  float *heights_1;
  float *heights_2;
  float *sigma_r_1;
  float *sigma_r_2;
  float *index_back_1;
  float *index_back_2;
  
  float **height1_2d;
  float **height2_2d;
  float **ext1_2d;
  float **ext2_2d;
  float **diff_h;
  float **diff_e;
  float **diff_all;
  int *xxx_k;
  int *xxx_l;
  
  float **M_out;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Forest_Height_Estimation_Dual_Baseline.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids1	input slave-1 directory\n");
strcat(UsageHelp," (string)	-ids2	input slave-2 directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id1 	input master-slave-1 directory\n");
strcat(UsageHelp," (string)	-id2 	input master-slave-2 directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-ikz1	input kz file\n");
strcat(UsageHelp," (string)	-ikz2	input kz file\n");
strcat(UsageHelp," (float) 	-hmin	minimal value of height\n");
strcat(UsageHelp," (float) 	-hmax	maximal value of height\n");
strcat(UsageHelp," (float) 	-hnum	height number of points\n");
strcat(UsageHelp," (float) 	-smin	minimal value of sigma\n");
strcat(UsageHelp," (float) 	-smax	maximal value of sigma\n");
strcat(UsageHelp," (float) 	-snum	sigma number of points\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
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

if(argc < 37) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "S2T6") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids1",str_cmd_prm,in_dir2,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids2",str_cmd_prm,in_dir3,1,UsageHelp);
    }
  if (strcmp(PolType, "T6") == 0) {
    get_commandline_prm(argc,argv,"-id1",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-id2",str_cmd_prm,in_dir2,1,UsageHelp);
    strcpy(in_dir3,in_dir2);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ikz1",str_cmd_prm,file_kz1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ikz2",str_cmd_prm,file_kz2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hmin",flt_cmd_prm,&min_height,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hmax",flt_cmd_prm,&max_height,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hnum",int_cmd_prm,&size_height,1,UsageHelp);
  get_commandline_prm(argc,argv,"-smin",flt_cmd_prm,&min_sigma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-smax",flt_cmd_prm,&max_sigma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-snum",int_cmd_prm,&size_sigma,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  
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

int nx, ny;
get_commandline_prm(argc,argv,"-nx",int_cmd_prm,&nx,1,UsageHelp);
get_commandline_prm(argc,argv,"-ny",int_cmd_prm,&ny,1,UsageHelp);

/***********************************************************************
***********************************************************************/

  check_file(file_kz1);
  check_file(file_kz2);
  check_dir(in_dir1);
  check_dir(in_dir2);
  if (strcmp(PolType, "S2T6") == 0) check_dir(in_dir3);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  file_name_in2 = matrix_char(NpolarIn,1024); 
  if (strcmp(PolTypeIn,"S2")==0) file_name_in3 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  init_file_name(PolTypeIn, in_dir2, file_name_in2);
  if (strcmp(PolTypeIn,"S2")==0) init_file_name(PolTypeIn, in_dir3, file_name_in3);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in2[Np]);

  if (strcmp(PolTypeIn,"S2")==0) {
    for (Np = 0; Np < NpolarIn; Np++) {
      if ((in_datafile3[Np] = fopen(file_name_in3[Np], "rb")) == NULL)
        edit_error("Could not open input file : ", file_name_in3[Np]);
      }
    }
    
  if ((in_file_kz1 = fopen(file_kz1, "rb")) == NULL)
    edit_error("Could not open input file : ", file_kz1);

  if ((in_file_kz2 = fopen(file_kz2, "rb")) == NULL)
    edit_error("Could not open input file : ", file_kz2);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%sForestHeights.bin", out_dir);
  if ((out_file = fopen(file_name, "wb")) == NULL)
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

  if (strcmp(PolTypeIn,"S2")==0) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 3*NpolarIn*2*(Ncol+NwinC); NBlockB += 3*NpolarIn*NwinL*2*(Ncol+NwinC);
    }

  /* Min1 = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Min2 = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mkz1 = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mkz2 = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Buffer1 = NpolarOut */
  NBlockA += 0; NBlockB += 2*NpolarOut;
  /* Mean1 = NpolarOut */
  NBlockA += 0; NBlockB += 2*NpolarOut;
  /* Buffer2 = NpolarOut */
  NBlockA += 0; NBlockB += 2*NpolarOut;
  /* Mean2 = NpolarOut */
  NBlockA += 0; NBlockB += 2*NpolarOut;
  
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

/* MATRIX ALLOCATION */
  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if (strcmp(PolTypeIn,"S2")==0) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in3 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    }

  M_in1 = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_in2 = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);

  M_kz1 = matrix_float(NligBlock[0], Sub_Ncol);
  M_kz2 = matrix_float(NligBlock[0], Sub_Ncol);
  
  M_out = matrix_float(NligBlock[0], Sub_Ncol);
  
  Mean1 = vector_float(NpolarOut);
  Buffer1 = vector_float(NpolarOut);
  Mean2 = vector_float(NpolarOut);
  Buffer2 = vector_float(NpolarOut);

  TT  = cplx_matrix(3,3);
  TT11  = cplx_matrix(3,3);
  TT12  = cplx_matrix(3,3);
  TT22  = cplx_matrix(3,3);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;
        
/********************************************************************
********************************************************************/
  piece1 = pi / 30.;
  piece2 = pi / 15.;
  
  phi_size = floor(0.5 + 2.*pi/piece1);
  printf("phi_size %i\n",phi_size);

/********************************************************************
********************************************************************/
/* HEIGHT Table (size_height)*/
delta_height = (max_height - min_height) / (size_height - 1.);
height_ttt = vector_float(size_height);
printf("delta %f size %i\n",delta_height,size_height);
for (k = 0; k < size_height; k++) {
  height_ttt[k] = min_height + k*delta_height;
  }

/* SIGMA Table (size_sigma)*/
delta_sigma = (max_sigma - min_sigma)/ (size_sigma - 1.);
sigma_ttt = vector_float(size_sigma);
//for (k = 0; k < size_sigma; k++) sigma_ttt[k] = min_sigma + k*delta_sigma;
sigma_ttt[0] = 0.0001/8.68;
sigma_ttt[1] = 0.03/8.68;
sigma_ttt[2] = 0.05/8.68;
sigma_ttt[3] = 0.072/8.68;
sigma_ttt[4] = 0.1/8.68;
sigma_ttt[5] = 0.124/8.68;
sigma_ttt[6] = 0.16/8.68;
sigma_ttt[7] = 0.2/8.68;
sigma_ttt[8] = 0.24/8.68;
sigma_ttt[9] = 0.3/8.68;
sigma_ttt[10] = 0.4/8.68;
sigma_ttt[11] = 0.5/8.68;
sigma_ttt[12] = 0.65/8.68;
sigma_ttt[13] = 0.80/8.68;
sigma_ttt[14] = 1./8.68;
sigma_ttt[15] = 1.4/8.68;
sigma_ttt[16] = 2./8.68;


//?????????????????????????
size_ddd = 30;
ddd_ttt = vector_float(size_ddd);
for (k = 0; k < size_ddd; k++) ddd_ttt[k] = (float)k/(size_ddd-1.);
//?????????????????????????

/* LUT_1 Table (size_height)*(size_sigma)*/
lu_table = cplx_matrix(size_height,size_sigma);
lu_table_1 = cplx_matrix(size_height,size_sigma);
lu_table_2 = cplx_matrix(size_height,size_sigma);
for (k = 0; k < size_height; k++) {
  for (l = 0; l < size_sigma; l++) {
    lu_table[k][l].re = 0.; lu_table[k][l].im = 0.;
    lu_table_1[k][l].re = 0.; lu_table_1[k][l].im = 0.;
    lu_table_2[k][l].re = 0.; lu_table_2[k][l].im = 0.;
    }
  }

/********************************************************************
********************************************************************/

if ((size_sigma > size_height)&&(size_sigma > size_ddd)) size_max = size_sigma;
if ((size_height > size_sigma)&&(size_height > size_ddd)) size_max = size_height;
if ((size_ddd > size_height)&&(size_ddd > size_sigma)) size_max = size_ddd;

heights = vector_float(size_max);
heights_1 = vector_float(size_max);
heights_2 = vector_float(size_max);
sigma_r = vector_float(size_max);
sigma_r_1 = vector_float(size_max);
sigma_r_2 = vector_float(size_max);
index_back = vector_float(size_max);
index_back_1 = vector_float(size_max);
index_back_2 = vector_float(size_max);
height1_2d = matrix_float(size_max,size_max);
height2_2d = matrix_float(size_max,size_max);
ext1_2d = matrix_float(size_max,size_max);
ext2_2d = matrix_float(size_max,size_max);
diff_h = matrix_float(size_max,size_max);
diff_e = matrix_float(size_max,size_max);
diff_all = matrix_float(size_max,size_max);
xxx_k = vector_int(size_max);
xxx_l = vector_int(size_max);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile1, S_in1, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_S2_noavg(in_datafile2, S_in2, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_S2_noavg(in_datafile3, S_in3, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    S2_to_T6(S_in1, S_in2, M_in1, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);
    S2_to_T6(S_in1, S_in3, M_in2, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    } else {
    /* Case of T6 */
    read_block_TCI_noavg(in_datafile1, M_in1, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_TCI_noavg(in_datafile2, M_in2, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_file_kz1, M_kz1, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_kz2, M_kz2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out[lig][col] = 0.;
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) Buffer1[Np] = 0.; 
        for (Np = 0; Np < NpolarOut; Np++) Buffer2[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++) {
              Buffer1[Np] = Buffer1[Np] + M_in1[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              Buffer2[Np] = Buffer2[Np] + M_in2[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            Buffer1[Np] = Buffer1[Np] - M_in1[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Buffer1[Np] = Buffer1[Np] + M_in1[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            Buffer2[Np] = Buffer2[Np] - M_in2[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Buffer2[Np] = Buffer2[Np] + M_in2[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }      
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) {
        Mean1[Np] = Buffer1[Np]/Nvalid;
        Mean2[Np] = Buffer2[Np]/Nvalid;
        }
        
    if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
      //######
      //###### T approximation for the first baseline
      //######
      TT11[0][0].re = Mean1[0];  TT11[0][0].im = 0;
      TT11[0][1].re = Mean1[1];  TT11[0][1].im = Mean1[2];
      TT11[0][2].re = Mean1[3];  TT11[0][2].im = Mean1[4];
      TT11[1][1].re = Mean1[11]; TT11[1][1].im = 0;
      TT11[1][2].re = Mean1[12]; TT11[1][2].im = Mean1[13];
      TT11[2][2].re = Mean1[20]; TT11[2][2].im = 0;
      TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
      TT11[2][0].re = TT11[0][2].re;  TT11[2][0].im = -TT11[0][2].im;
      TT11[2][1].re = TT11[1][2].re;  TT11[2][1].im = -TT11[1][2].im;

      TT22[0][0].re = Mean1[27]; TT22[0][0].im = 0;
      TT22[0][1].re = Mean1[28]; TT22[0][1].im = Mean1[29];
      TT22[0][2].re = Mean1[30]; TT22[0][2].im = Mean1[31];
      TT22[1][1].re = Mean1[32]; TT22[1][1].im = 0;
      TT22[1][2].re = Mean1[33]; TT22[1][2].im = Mean1[34];
      TT22[2][2].re = Mean1[35]; TT22[2][2].im = 0;
      TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
      TT22[2][0].re = TT22[0][2].re;  TT22[2][0].im = -TT22[0][2].im;
      TT22[2][1].re = TT22[1][2].re;  TT22[2][1].im = -TT22[1][2].im;
    
      TT12[0][0].re = Mean1[5];  TT12[0][0].im = Mean1[6];
      TT12[0][1].re = Mean1[7];  TT12[0][1].im = Mean1[8];
      TT12[0][2].re = Mean1[9];  TT12[0][2].im = Mean1[10];
      TT12[1][0].re = Mean1[14]; TT12[1][0].im = Mean1[15];
      TT12[1][1].re = Mean1[16]; TT12[1][1].im = Mean1[17];
      TT12[1][2].re = Mean1[18]; TT12[1][2].im = Mean1[19];
      TT12[2][0].re = Mean1[21]; TT12[2][0].im = Mean1[22];
      TT12[2][1].re = Mean1[23]; TT12[2][1].im = Mean1[24];
      TT12[2][2].re = Mean1[25]; TT12[2][2].im = Mean1[26];

      for(k=0; k<3; k++) { 
        for(l=0; l<3; l++) {
          TT[k][l].re = (TT11[k][l].re + TT22[k][l].re) / 2.;
          TT[k][l].im = (TT11[k][l].im + TT22[k][l].im) / 2.;
          }
        }

      //######
      //###### LUT 1 Generation
      //######
      for (k = 0; k < size_height; k++) {
        for (l = 0; l < size_sigma; l++) {
          lu_table_1[k][l].re = 0.; lu_table_1[k][l].im = 0.;
          z0 = 2.*sigma_ttt[l];
          z1.re = z0; z1.im = M_kz1[lig][col];
          BBB = (exp(z0*height_ttt[k])-1.)/z0;
          z2.re = z1.re*height_ttt[k]; z2.im = z1.im*height_ttt[k];
          AAA.re = exp(z2.re)*cos(z2.im) - 1.; AAA.im = exp(z2.re)*sin(z2.im);
          AAA = cdiv(AAA,z1);
          lu_table_1[k][l].re = AAA.re/(BBB + eps); lu_table_1[k][l].im = AAA.im/(BBB + eps);
          }
        }
      
      //######
      //###### get gamma_v for the baseline
      //######

      get_gamma_v(TT, TT12, piece1, piece2, M_kz1[lig][col], phi_size);
      ground_point_1 = ground;
      vol_only_1 = vol_only;

      //######
      //###### T approximation for the second baseline
      //######
      TT11[0][0].re = Mean2[0];  TT11[0][0].im = 0;
      TT11[0][1].re = Mean2[1];  TT11[0][1].im = Mean2[2];
      TT11[0][2].re = Mean2[3];  TT11[0][2].im = Mean2[4];
      TT11[1][1].re = Mean2[11]; TT11[1][1].im = 0;
      TT11[1][2].re = Mean2[12]; TT11[1][2].im = Mean2[13];
      TT11[2][2].re = Mean2[20]; TT11[2][2].im = 0;
      TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
      TT11[2][0].re = TT11[0][2].re;  TT11[2][0].im = -TT11[0][2].im;
      TT11[2][1].re = TT11[1][2].re;  TT11[2][1].im = -TT11[1][2].im;

      TT22[0][0].re = Mean2[27]; TT22[0][0].im = 0;
      TT22[0][1].re = Mean2[28]; TT22[0][1].im = Mean2[29];
      TT22[0][2].re = Mean2[30]; TT22[0][2].im = Mean2[31];
      TT22[1][1].re = Mean2[32]; TT22[1][1].im = 0;
      TT22[1][2].re = Mean2[33]; TT22[1][2].im = Mean2[34];
      TT22[2][2].re = Mean2[35]; TT22[2][2].im = 0;
      TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
      TT22[2][0].re = TT22[0][2].re;  TT22[2][0].im = -TT22[0][2].im;
      TT22[2][1].re = TT22[1][2].re;  TT22[2][1].im = -TT22[1][2].im;
    
      TT12[0][0].re = Mean2[5];  TT12[0][0].im = Mean2[6];
      TT12[0][1].re = Mean2[7];  TT12[0][1].im = Mean2[8];
      TT12[0][2].re = Mean2[9];  TT12[0][2].im = Mean2[10];
      TT12[1][0].re = Mean2[14]; TT12[1][0].im = Mean2[15];
      TT12[1][1].re = Mean2[16]; TT12[1][1].im = Mean2[17];
      TT12[1][2].re = Mean2[18]; TT12[1][2].im = Mean2[19];
      TT12[2][0].re = Mean2[21]; TT12[2][0].im = Mean2[22];
      TT12[2][1].re = Mean2[23]; TT12[2][1].im = Mean2[24];
      TT12[2][2].re = Mean2[25]; TT12[2][2].im = Mean2[26];

      for(k=0; k<3; k++) { 
        for(l=0; l<3; l++) {
          TT[k][l].re = (TT11[k][l].re + TT22[k][l].re) / 2.;
          TT[k][l].im = (TT11[k][l].im + TT22[k][l].im) / 2.;
          }
        }

      //######
      //###### LUT 1 Generation
      //######
      for (k = 0; k < size_height; k++) {
        for (l = 0; l < size_sigma; l++) {
          lu_table_2[k][l].re = 0.; lu_table_2[k][l].im = 0.;
          z0 = 2.*sigma_ttt[l];
          z1.re = z0; z1.im = M_kz2[lig][col];
          BBB = (exp(z0*height_ttt[k])-1.)/z0;
          z2.re = z1.re*height_ttt[k]; z2.im = z1.im*height_ttt[k];
          AAA.re = exp(z2.re)*cos(z2.im) - 1.; AAA.im = exp(z2.re)*sin(z2.im);
          AAA = cdiv(AAA,z1);
          lu_table_2[k][l].re = AAA.re/(BBB + eps); lu_table_2[k][l].im = AAA.im/(BBB + eps);
          }
        }

      //######
      //###### get gamma_v for the baseline
      //######

      get_gamma_v(TT, TT12, piece1, piece2, M_kz2[lig][col], phi_size);
      ground_point_2 = ground;
      vol_only_2 = vol_only;
      
      //#####################################################################  
      //####################  pixel by Pixel height estimation  #############
      //#####################################################################  
      
      //#####
      //#####  height evaluation
      //#####

      //###### get minimum of all lu tables

      //###### first baseline
      for(k=0; k<size_height; k++) { 
        for(l=0; l<size_sigma; l++) {
          lu_table[k][l] = cmul(lu_table_1[k][l],ground_point_1);
          }
        }
      height_inversion_sk(sigma_ttt,size_sigma,height_ttt,size_height,ddd_ttt,size_ddd,lu_table,vol_only_1);
      new_size_sigma1 = new_size_sigma;
      for(k=0; k<new_size_sigma1; k++) { 
        heights_1[k] = heights[k];
        sigma_r_1[k] = sigma_r[k];
        index_back_1[k] = index_back[k];
        }
      
      //###### second baseline
      for(k=0; k<size_height; k++) { 
        for(l=0; l<size_sigma; l++) {
          lu_table[k][l] = cmul(lu_table_2[k][l],ground_point_2);
          }
        }
      height_inversion_sk(sigma_ttt,size_sigma,height_ttt,size_height,ddd_ttt,size_ddd,lu_table,vol_only_2);
      new_size_sigma2 = new_size_sigma;
      for(k=0; k<new_size_sigma2; k++) { 
        heights_2[k] = heights[k];
        sigma_r_2[k] = sigma_r[k];
        index_back_2[k] = index_back[k];
        }

      //#########################
      //######  calculate norm of all solutions
      //#########################

      //height1_2d = heights_1 # (fltarr(n_elements(heights_2))+1);
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          height1_2d[k][l] = heights_1[l];
          
      //height2_2d = (fltarr(n_elements(heights_1))+1)# heights_2;
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          height2_2d[k][l] = heights_2[k];
          
      //diff_h = abs(height1_2d - height2_2d)
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          diff_h[k][l] = fabs(height1_2d[k][l] - height2_2d[k][l]);
          
      //ext1_2d = sigma_r_1 # (fltarr(n_elements(sigma_r_2))+1)
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          ext1_2d[k][l] = sigma_r_1[l];
      //ext2_2d = (fltarr(n_elements(sigma_r_1))+1)# sigma_r_2
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          ext2_2d[k][l] = sigma_r_2[k];
      //diff_e = abs(ext1_2d - ext2_2d)
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          diff_e[k][l] = fabs(ext1_2d[k][l] - ext2_2d[k][l]);

      //diff_all = diff_h^2 + diff_e^2
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          diff_all[k][l] = diff_h[k][l]*diff_h[k][l]+diff_e[k][l]*diff_e[k][l];
       
      //sol = where ( diff_all eq min(diff_all))
      diff_all_min = diff_all[0][0];
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          if (diff_all[k][l] <= diff_all_min) diff_all_min = diff_all[k][l];

      xxx_index = 0;
      for(k=0; k<new_size_sigma2; k++)  
        for(l=0; l<new_size_sigma1; l++)  
          if (diff_all[k][l] <= diff_all_min) {
            xxx_k[xxx_index] = k;
            xxx_l[xxx_index] = l;
            xxx_index++;
            }
      xxx_index = floor(xxx_index*0.333);

      M_out[lig][col] = (height1_2d[xxx_k[xxx_index]][xxx_l[xxx_index]] + height2_2d[xxx_k[xxx_index]][xxx_l[xxx_index]]) / 2.;     
      } else {
      M_out[lig][col] = 0.;
      } /* valid */
    } /*col */
  } /* lig */

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if (strcmp(PolTypeIn,"S2")==0) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + NwinL);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + NwinL);
    }

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix_float(M_out1, NligBlock[0]);
  free_matrix_float(M_out2, NligBlock[0]);
  free_matrix_float(M_out3, NligBlock[0]);
  free_vector_float(Mean);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file); 

/* INPUT FILE CLOSING*/
  fclose(in_file_kz1);
  fclose(in_file_kz2);
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);
  if (strcmp(PolTypeIn,"S2")==0)
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile3[Np]);

/********************************************************************
********************************************************************/

  return 1;
}
/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routines
; $Id: get_gamma_v, txx, Omega12, piece1,piece2, kappa_z, ground,vol_only

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; K. PAPATHANASSIOU
;
********************************************************************/
//######### decision for ground point with comparision of angle'#####
int get_gamma_v(cplx **txx, cplx **Omega12, float piece1, float piece2, float kappa_z, int phi_size)
{
/* GLOVAL VAR */ 
//int new_size_sigma;
//float ratio, line_slope, line_const, index_back;
//float *heights, *sigma_r;
//cplx coh_first, coh_second, ccc_x1, ccc_x2; 
//cplx ground, vol_only;

  int k, boundary_size, pos;
  cplx ccc;
  float xxx;
  cplx *boundary, *boundary_alt;

  boundary_size = 2*phi_size;
  boundary = cplx_vector(boundary_size);
  boundary_alt = cplx_vector(boundary_size);

//###############  Field of Coherence  estimation  ###################

  coh_boundary(txx, Omega12, piece1, piece2, boundary, phi_size);

//###############  linfit through boundary ###########################

  for (k = 0; k < boundary_size; k++) boundary_alt[k] = boundary[k];

  fit_the_line(boundary, boundary_size);   

  for (k = 0; k < boundary_size; k++) boundary[k] = boundary_alt[k];

//#######  decision for ground point with comparision of angle #######

  ground_point(kappa_z);

//#################  Volume only point ###############################

  xxx = 0.; pos = 0;
  for (k = 0; k < boundary_size; k++) {
    ccc = csub(boundary[k], ground);
    if (xxx <= cmod(ccc)) {
      xxx = cmod(ccc);
      pos = k;
      }
    }
  vol_only = boundary[pos];

return 1;
}

/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routines
; $Id: coh_boundary, T, omega12, piece1, piece2, boundary_p

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; K. PAPATHANASSIOU
;
********************************************************************/
//#######################  Boundary  #################################
int coh_boundary(cplx **T, cplx **O12, float piece1, float piece2, cplx *boundary_p, int phi_size)
{
/* GLOVAL VAR */ 
//int new_size_sigma;
//float ratio, line_slope, line_const, index_back;
//float *heights, *sigma_r;
//cplx coh_first, coh_second, ccc_x1, ccc_x2; 
//cplx ground, vol_only;

  int i, j, k, index;
  cplx ccc, gtmp;
  cplx pt1aa, pt2aa, pt3aa;
  cplx gamma1t, gamma2t, gamma3t;
  cplx gamma1, gamma2, gamma3;
  float limit, tmp;

  cplx **omega12;
  cplx **homega12;
  cplx **A;
  cplx **evec;
  cplx **tra_vet;
  cplx **d_inv;
  cplx **inv_T;
  cplx **inv_Tt;
  cplx *vect;
  cplx **Z;
  cplx **w;
  cplx *gamma;

  float *phi;
  float *eval;
  float *g;

  omega12 = cplx_matrix(3,3);
  homega12 = cplx_matrix(3,3);
  A = cplx_matrix(3,3);
  evec = cplx_matrix(3,3);
  tra_vet = cplx_matrix(3,3);
  d_inv = cplx_matrix(3,3);
  inv_T = cplx_matrix(3,3);
  inv_Tt = cplx_matrix(3,3);
  vect = cplx_vector(3);
  Z = cplx_matrix(3,3);
  w = cplx_matrix(3,3);
  phi = vector_float(phi_size);
  eval = vector_float(3);
  g = vector_float(3);
  gamma = cplx_vector(3);
 
//###################### Range of phi define by piece1

  limit = 1e-14;
  index = 0;

  for (k = 0; k < phi_size; k++) phi[k] = 2.*pi*k / phi_size;
  phi[phi_size-1] = phi[phi_size-1]-limit;

//###################### Approximation for the algorithm

  for (k = 0; k < phi_size; k++) {
    ccc.re = cos(phi[k]); ccc.im = sin(phi[k]); 
    cplx_mul_mat_cval(O12,ccc,omega12,3,3);
    cplx_htransp_mat(omega12,homega12,3,3);
    for (i = 0; i < 3; i++) 
      for (j = 0; j < 3; j++) {
        A[i][j].re = (omega12[i][j].re + homega12[i][j].re)/ 2.;
        A[i][j].im = (omega12[i][j].im + homega12[i][j].im)/ 2.;
        }

//########################## INVERSE A ###############################

    cplx_diag_mat3(T,evec,eval);  
          
//########################### Control if the eigenvalues are zero 

    d_inv[0][0].re = 1./eval[0];
    d_inv[1][1].re = 1./eval[1];
    d_inv[2][2].re = 1./eval[2];

//########### inv_T=vet#(d^(-1.))#transpose(conj(vet)) ###############

    cplx_mul_mat(evec, d_inv, inv_Tt, 3, 3);
    
    cplx_htransp_mat(evec, tra_vet, 3, 3);
    
    cplx_mul_mat(inv_Tt, tra_vet, inv_T, 3, 3);
    
    cplx_mul_mat(inv_T, A, Z, 3, 3);
    
    cplx_diag_mat3(Z,w,eval);  
    
    ccc.re = cos(phi[k]); ccc.im = sin(-phi[k]); 

    for (i = 0; i < 3; i++) vect[i] = w[i][0];
    pt1aa = cplx_quadratic_form(T, vect, 3, 3);
    gamma1t = cplx_quadratic_form(omega12, vect, 3, 3);
    pt1aa.re = pt1aa.re + limit;
    gamma1 = cdiv(gamma1t, pt1aa);
    gamma1 = cmul(gamma1, ccc);

    for (i = 0; i < 3; i++) vect[i] = w[i][1];
    pt2aa = cplx_quadratic_form(T, vect, 3, 3);
    gamma2t = cplx_quadratic_form(omega12, vect, 3, 3);
    pt2aa.re = pt2aa.re + limit;
    gamma2 = cdiv(gamma2t, pt2aa);
    gamma2 = cmul(gamma2, ccc);

    for (i = 0; i < 3; i++) vect[i] = w[i][2];
    pt3aa = cplx_quadratic_form(T, vect, 3, 3);
    gamma3t = cplx_quadratic_form(omega12, vect, 3, 3);
    pt3aa.re = pt3aa.re + limit;
    gamma3 = cdiv(gamma3t, pt3aa);
    gamma3 = cmul(gamma3, ccc);

    /* sorting ascending order*/
    g[0]=cmod(gamma1); g[1]=cmod(gamma2); g[2]=cmod(gamma3);
    gamma[0] = gamma1; gamma[1] = gamma2; gamma[2] = gamma3; 

    if(g[1]>g[0]) {
      tmp = g[0]; g[0] = g[1]; g[1] = tmp;
      gtmp = gamma[0]; gamma[0] = gamma[1]; gamma[1] = gtmp;
      }  
    if(g[2]>g[0]) {
      tmp = g[0]; g[0] = g[2]; g[2] = tmp;
      gtmp = gamma[0]; gamma[0] = gamma[2]; gamma[2] = gtmp;
      }  
    if(g[2]>g[1]) {
      tmp = g[1]; g[1] = g[2]; g[2] = tmp;
      gtmp = gamma[1]; gamma[1] = gamma[2]; gamma[2] = gtmp;
      }  

    boundary_p[index] = gamma[0];
    index++;
    boundary_p[index] = gamma[2];
    index++;
    }
return 1;
}
    
/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routines
; $Id: pro fit_the_line, boundary, ratio, coh_first, coh_second, ccc_x1, ccc_x2, $
line_slope, line_const

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; K. PAPATHANASSIOU
;
********************************************************************/
//################### line_fit and ground points   ###################
int fit_the_line(cplx *boundary, int boundary_size)
{
/* GLOVAL VAR */ 
//int new_size_sigma;
//float ratio, line_slope, line_const, index_back;
//float *heights, *sigma_r;
//cplx coh_first, coh_second, ccc_x1, ccc_x2; 
//cplx ground, vol_only;

  int k;
  int pos_ma, pos_mma, indmax, indmin;
  cplx media, ccc;
  float Nmedia;
  float xxx_ma, xxx_mma, phi_shift, xxx, yyy;
  float xx1, xx2, yy1, yy2;
  float int_xxx[2], int_yyy[2];
  cplx *Boundary_shift;

  Boundary_shift = cplx_vector(boundary_size);
  
  media.re = 0.; media.im = 0.; Nmedia = 0.;
  for (k = 0; k < boundary_size; k++) {
    if (my_isfinite(cmod(boundary[k])) !=0) {
      media = cadd(media, boundary[k]);
      Nmedia += 1.;
      }
    }
  media.re /= Nmedia; media.im /= Nmedia;

  for (k = 0; k < boundary_size; k++) 
    boundary[k] = csub(boundary[k], media);
    
  xxx_ma = cmod(boundary[0]); pos_ma = 0;
  for (k = 0; k < boundary_size; k++) {
    if (my_isfinite(cmod(boundary[k])) !=0) {
      if (xxx_ma <= cmod(boundary[k])) {
        xxx_ma = cmod(boundary[k]);
        pos_ma = k;
        }
      }
    }

  coh_first = boundary[pos_ma];
  xxx_mma = cmod(csub(boundary[0],coh_first)); pos_mma = 0;
  for (k = 0; k < boundary_size; k++) {
    if (my_isfinite(cmod(boundary[k])) !=0) {
      if (xxx_mma <= cmod(csub(boundary[k], coh_first))) {
        xxx_mma = cmod(csub(boundary[k], coh_first));
        pos_mma = k;
        }
      }
    }
  coh_second = boundary[pos_mma];

  phi_shift = atan2(coh_first.im - coh_second.im, coh_first.re - coh_second.re);

  ccc.re = cos(-1.*phi_shift); ccc.im = sin(-1.*phi_shift); 
  for (k = 0; k < boundary_size; k++)
    Boundary_shift[k] = cmul(boundary[k], ccc);

    
  xxx = Boundary_shift[0].im; indmax = 0;
  yyy = Boundary_shift[0].im; indmin = 0;
  for (k = 0; k < boundary_size; k++) {
    if (my_isfinite(cmod(Boundary_shift[k])) !=0) {
      if (xxx <= Boundary_shift[k].im) {
        xxx = Boundary_shift[k].im;
        indmax = k;
        }
      if (Boundary_shift[k].im <= yyy) {
        yyy = Boundary_shift[k].im;
        indmin = k;
        }
      }
    }
    
  ratio = cmod(csub(coh_first, coh_second)) / (Boundary_shift[indmax].im - Boundary_shift[indmin].im);

  coh_first  = cadd(coh_first, media);
  coh_second = cadd(coh_second, media);

  //####### linfit mit axis

  xx1 = coh_first.re;
  xx2 = coh_second.re;
  yy1 = coh_first.im;
  yy2 = coh_second.im;

  line_slope = (yy2-yy1)/(xx2-xx1);
  line_const = yy1-line_slope*xx1;

  //################# Line Circle Intersections ########################

  int_xxx[0] = (-line_const*line_slope - sqrt(line_slope*line_slope-line_const*line_const+1.))/(1.+line_slope*line_slope);
  int_xxx[1] = (-line_const*line_slope + sqrt(line_slope*line_slope-line_const*line_const+1.))/(1.+line_slope*line_slope);

  int_yyy[0] = line_const+line_slope*int_xxx[0];
  int_yyy[1] = line_const+line_slope*int_xxx[1];

  ccc_x1.re = int_xxx[0];
  ccc_x1.im = int_yyy[0];
  ccc_x2.re = int_xxx[1];
  ccc_x2.im = int_yyy[1];

  return 1;
}

/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routines
; $Id: ground_point, kappa_zeta, ccc_x1, ccc_x2, ground

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; K. PAPATHANASSIOU
;
********************************************************************/
//######### decision for ground point with comparision of angle'######
int ground_point(float kappa_zeta)
{
/* GLOVAL VAR */ 
//int new_size_sigma;
//float ratio, line_slope, line_const, index_back;
//float *heights, *sigma_r;
//cplx coh_first, coh_second, ccc_x1, ccc_x2; 
//cplx ground, vol_only;

  float beta;
  cplx ccc;

  ccc = cmul(ccc_x2, cconj(ccc_x1));
  beta = angle(ccc);
  
  if (kappa_zeta < 0.) {
    if (beta < 0.) ground = ccc_x1; else ground = ccc_x2;
    if (beta < -pi) ground = ccc_x2;
    if (beta > pi) ground = ccc_x1;
    } else {
    if (beta < 0.) ground = ccc_x2; else ground = ccc_x1;
    if (beta < -pi) ground = ccc_x1;
    if (beta > pi) ground = ccc_x2;
    }

  return 1;
}

/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routines
; $Id: height_inversion_sk,sigma_ttt,height_ttt,deco_org,lu_table1, $
gamma_v1, heights,sigma, sigma_r, index_back,i,j, right

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; K. PAPATHANASSIOU
;
********************************************************************/
//#####  Procedure height inversion for several deco solutions  ######
int height_inversion_sk(float *sigma_ttt, int size_sigma, float *height_ttt, int size_height, float *deco_org, int size_deco_org, cplx **lu_table1, cplx gamma_v1)
{
/* GLOVAL VAR */ 
//int new_size_sigma;
//float ratio, line_slope, line_const, index_back;
//float *heights, *sigma_r;
//cplx coh_first, coh_second, ccc_x1, ccc_x2; 
//cplx ground, vol_only;

//right = 0;
  int k, de, pos, pos_org;
  int xxx_index, sig_index, hhh_index;
  int dim_lu_s, dim_lu_h;
  int size_max;
  cplx g_v;
  float h_max, a_sl, aux, diff_a;
  float sigma_est, s_rank, heights_est;
  int *xxx;
  float *sigma_ranks;
  float *deco_ttt;
  float *deco;
  float *aux_dist;
  float *im_line;
  float *ddd_lu_1;

  if ((size_sigma > size_height)&&(size_sigma > size_deco_org)) size_max = size_sigma;
  if ((size_height > size_sigma)&&(size_height > size_deco_org)) size_max = size_height;
  if ((size_deco_org > size_height)&&(size_deco_org > size_sigma)) size_max = size_deco_org;
  
  //heights = vector_float(size_sigma); VAR GLOBAL
  //sigma = vector_float(size_sigma); VAR GLOBAL
  //gamma_v1 = gamma_v1[0]; volume coherence
  //index_back = vector_float(size_max); VAR GLOBAL
  //sigma_r = vector_float(size_sigma); VAR GLOBAL
  deco = vector_float(size_max);
  aux_dist = vector_float(size_max);
  im_line = vector_float(size_max);
  ddd_lu_1 = vector_float(size_max);
  xxx = vector_int(size_max);

  gamma_v1.re = 0.8*gamma_v1.re; gamma_v1.im = 0.8*gamma_v1.im;
  
  sigma_ranks = vector_float(size_sigma+1);
  for (k=0; k < size_sigma+1; k++) sigma_ranks[k] =  (float)(1.+ k);

  h_max = height_ttt[0];
  for (k=0; k <size_height; k++) 
    if (h_max <= height_ttt[k]) h_max = height_ttt[k];
    
  dim_lu_s = size_sigma;
  dim_lu_h = size_height;

  //ds = n_elements(deco_org)
  xxx_index = 0;
  for (k=0; k <size_deco_org; k++) 
    if (deco_org[k] >= cmod(gamma_v1)) {
      xxx[xxx_index] = k;
      xxx_index++;
      }
  
  if (xxx_index == 0) {
    deco_ttt = vector_float(1);
    deco_ttt[0] = deco_org[size_deco_org-1];
    }  else {
    deco_ttt = vector_float(xxx_index);
    for (k=0; k <xxx_index; k++) 
      deco_ttt[k] = deco_org[xxx[k]];
    }

  a_sl = gamma_v1.im / gamma_v1.re;

  for (de = 0; de < size_sigma; de++) {

    for (k=0; k <size_height; k++) 
      im_line[k] = lu_table1[k][de].re * a_sl;

    for (k=0; k <size_height; k++) 
      ddd_lu_1[k] = fabs(im_line[k] - lu_table1[k][de].im);
    
    aux = ddd_lu_1[0]; pos = 0;
    for (k=0; k <size_height; k++) 
      if (ddd_lu_1[k] <= aux) {
        aux = ddd_lu_1[k];
        pos = k;
        }

    g_v =  lu_table1[pos][de];
    diff_a = fabs(angle(cmul(gamma_v1,cconj(g_v))));
    pos_org = pos;

    while (diff_a > pi/9) {
      ddd_lu_1[pos] = 100;
      aux = ddd_lu_1[0]; pos = 0;
      for (k=0; k <size_height; k++) 
        if (ddd_lu_1[k] <= aux) {
          aux = ddd_lu_1[k];
          pos = k;
          }
      g_v = lu_table1[pos][de];
      diff_a = fabs(angle(cmul(gamma_v1,cconj(g_v))));
      if (ddd_lu_1[pos] == 100) {
        diff_a = 0;
        pos = size_height-1;
        }
      }

    sig_index = de;
    hhh_index = pos;

    sigma_est = sigma_ttt[sig_index];
    s_rank = sigma_ranks[sig_index];
    heights_est = height_ttt[hhh_index];

  //sigma[de] = sigma_est*8.68 //not used
    sigma_r[de] = s_rank;
    heights[de] = heights_est;
    index_back[de] = pos;
    deco[de] = cmod(gamma_v1)/cmod(lu_table1[pos][de]);
    }
  
  xxx_index = 0;
  new_size_sigma = size_sigma;
  for (k=0; k <new_size_sigma; k++) 
    if (heights[k] < h_max) {
      xxx[xxx_index] = k;
      xxx_index++;
      }
  
  if (xxx_index != 0) {
    new_size_sigma = xxx_index;
    for (k=0; k <new_size_sigma; k++) {
      //sigma = sigma[xxx] // not used
      sigma_r[k] = sigma_r[xxx[k]];
      heights[k] = heights[xxx[k]];
      index_back[k] = index_back[xxx[k]];
      }
    }
    
  xxx_index = 0;
  for (k=0; k <new_size_sigma; k++) 
    if (heights[k] != h_max) {
      xxx[xxx_index] = k;
      xxx_index++;
      }
  
  if (xxx_index != 0) {
    new_size_sigma = xxx_index;
    for (k=0; k <new_size_sigma; k++) {
      //sigma = sigma[xxx] // not used
      sigma_r[k] = sigma_r[xxx[k]];
      heights[k] = heights[xxx[k]];
      index_back[k] = index_back[xxx[k]];
      }
    }

  //if n_elements(heights) gt 4 then right = heights[4] //right not used

return 1;
}
