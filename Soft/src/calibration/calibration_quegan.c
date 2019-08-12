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

File   : calibration_quegan.c
Project  : ESA_POLSARPRO
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 2.0
Creation : 06/2005
Update  : 08/2008
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

Description :  Relative polarimetric calibration based on the method 
of Shaun Quegan

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

/* Real and Imaginary parts */
#define cre 0
#define cim 1
#define cab 2
#define cph 3

/* S matrix */
#define hh 0
#define hv 1
#define vh 2
#define vv 3

/* C matrix */
#define C11   0
#define C12_re  1
#define C12_im  2
#define C13_re  3
#define C13_im  4
#define C22     5
#define C23_re  6
#define C23_im  7
#define C33     8
#define C14_re  9
#define C14_im  10
#define C24_re  11
#define C24_im  12
#define C34_re  13
#define C34_im  14
#define C44     15

#define C21_re  16
#define C21_im  17
#define C31_re  18
#define C31_im  19
#define C32_re  20
#define C32_im  21
#define C41_re  22
#define C41_im  23
#define C42_re  24
#define C42_im  25
#define C43_re  26
#define C43_im  27

/* CONSTANTS  */
#define rho_cross_limit 0.3

/* GLOBAL ARRAYS */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
float AmplitudeComplex_v2(float Re, float Im);
void ComplexProduct2(float Re1, float Im1, float Re2, float Im2, float *ReP, float *ImP);

/******************************************************************/

int main(int argc, char *argv[])
{
  /*******************/  
  /* LOCAL VARIABLES */
  /*******************/
  
  /* Input/Output file pointer arrays*/
  FILE *in_fileS2[4];
  FILE *in_fileC4[16];
  FILE *out_fileS2[4];

  char in_dirS2[FilePathLength],out_dirS2[FilePathLength],tmp_dirC4[FilePathLength],file_name[FilePathLength];
  char *FileInputS2[4]  = { "s11.bin", "s21.bin", "s12.bin", "s22.bin"};  /* Change of the order */
  char *FileInputC4[16] = { "C11.bin", "C12_real.bin", "C12_imag.bin", "C13_real.bin", "C13_imag.bin",
                            "C22.bin", "C23_real.bin", "C23_imag.bin", "C33.bin",
                            "C14_real.bin", "C14_imag.bin", "C24_real.bin", "C24_imag.bin",
                            "C34_real.bin", "C34_imag.bin", "C44.bin"};
  char *FileOutputS2[4]  = { "s11.bin", "s21.bin", "s12.bin", "s22.bin"}; /* Change of the order */
  
  /* Temporal matrices */
  float **M_tmp_ligne;
  float ***S_tmp_block;
  float **C_ligne;
  float **Cal_mask, **Cal_mask_rho;
  
  /* Calibration variables */
  float **alpha1, **alpha2, **alpha1_rg, **alpha2_rg;
  float **alpha, **alpha_rg;
  float **uuu, **vvv, **www, **zzz, **uuu_rg, **vvv_rg, **www_rg, **zzz_rg;
  float **alpha_cal_final, **uuu_cal_final, **vvv_cal_final, **www_cal_final, **zzz_cal_final;
  float ***cal_matrix;
   
  /* Internal variables */
  int Npolar_S, Npolar_C, Npolar_C_full;
  int lig, col, np;
  int ind, indalp1, indalp2, induuu, indvvv, indwww, indzzz;
  float var1, var2, var3, var4, var5, var6;
  float D_inv,P01_re, P01_im, P02_re, P02_im, P21_re, P21_im, P22_re, P22_im;
  
  /******************/
  /* PROGRAM STARTS */
  /******************/
  
  if (argc < 8){
  edit_error("calibration_quegan in_dir out_dir tmp_dir Off_lig Off_col Sub_Nlig Sub_Ncol\n","");
  } else {
  strcpy(in_dirS2, argv[1]);
  strcpy(out_dirS2, argv[2]);
  strcpy(tmp_dirC4, argv[3]);
  Off_lig  = atoi(argv[4]);
  Off_col  = atoi(argv[5]);
  Sub_Nlig = atoi(argv[6]);
  Sub_Ncol = atoi(argv[7]);
  }
  
  check_dir(in_dirS2);
  check_dir(out_dirS2);
  check_dir(tmp_dirC4);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  /* Initialization of variables */
  Npolar_S    = 4;
  Npolar_C    = 16;
  Npolar_C_full = 28;

  /* Input/Output configurations */
  read_config(in_dirS2, &Nlig, &Ncol, PolarCase, PolarType);
  
  /* Matrix Declarations */

  alpha      = matrix_float(2,Sub_Ncol);  /* Calibration parameters */
  alpha_rg   = matrix_float(4,Sub_Ncol);
  alpha_cal_final = matrix_float(4,Sub_Ncol);
  alpha1     = matrix_float(2,Sub_Ncol);
  alpha1_rg  = matrix_float(2,Sub_Ncol);
  alpha2     = matrix_float(2,Sub_Ncol);
  alpha2_rg  = matrix_float(2,Sub_Ncol);
  
  uuu        = matrix_float(2,Sub_Ncol); /* 0->R, 1->I */
  uuu_rg     = matrix_float(2,Sub_Ncol);
  uuu_cal_final = matrix_float(2,Sub_Ncol);
  vvv        = matrix_float(2,Sub_Ncol); /* 0->R, 1->I */
  vvv_rg     = matrix_float(2,Sub_Ncol);
  vvv_cal_final = matrix_float(2,Sub_Ncol);
  www        = matrix_float(2,Sub_Ncol); /* 0->R, 1->I */
  www_rg     = matrix_float(2,Sub_Ncol);
  www_cal_final = matrix_float(2,Sub_Ncol);
  zzz        = matrix_float(2,Sub_Ncol); /* 0->R, 1->I */
  zzz_rg     = matrix_float(2,Sub_Ncol);
  zzz_cal_final = matrix_float(2,Sub_Ncol);
  
  M_tmp_ligne = matrix_float(Npolar_S,2*Sub_Ncol);
  S_tmp_block = matrix3d_float(Npolar_S,2,2*Sub_Ncol);
  C_ligne     = matrix_float(Npolar_C_full,Sub_Ncol);
  
  Cal_mask     = matrix_float(Sub_Nlig,Sub_Ncol);
  Cal_mask_rho = matrix_float(Sub_Nlig,Sub_Ncol);

  cal_matrix   = matrix3d_float(2,3,4);
  
  /* Input C4 files opening */
  for (np = 0; np < Npolar_C; np++) {
    sprintf(file_name, "%s%s", tmp_dirC4, FileInputC4[np]);
    if ((in_fileC4[np] = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open input file : ", file_name);
    }
  
  /* Input file sub-window reading */
  for (np = 0; np < Npolar_C; np++) rewind(in_fileC4[np]);
  
/***********************/
/* Processing of lines */
/***********************/

for (col = 0; col < Sub_Ncol; col++) {
  alpha[cre][col] = 0.0; alpha[cim][col] = 0.0;
  alpha1[cre][col] = 0.0; alpha1[cim][col] = 0.0;
  alpha2[cre][col] = 0.0; alpha2[cim][col] = 0.0;
  uuu_rg[cre][col] = 0.0; uuu_rg[cim][col] = 0.0;
  vvv_rg[cre][col] = 0.0; vvv_rg[cim][col] = 0.0;
  www_rg[cre][col] = 0.0; www_rg[cim][col] = 0.0;
  zzz_rg[cre][col] = 0.0; zzz_rg[cim][col] = 0.0;
  }
  
for (lig = 0; lig < Sub_Nlig; lig++){
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
   
  /* Creates the C4 matrix reading the files */
  for (np = 0; np < Npolar_C; np++) {
    fread(&M_tmp_ligne[0][0], sizeof(float), Sub_Ncol, in_fileC4[np]);
    for (col = 0; col < Sub_Ncol; col ++) C_ligne[np][col] = M_tmp_ligne[0][col];
    }  
    
  /* Creates the complex conjugate part of the matrix C4 */
  for ( col = 0; col < Sub_Ncol; col++) {
    C_ligne[C21_re][col] = C_ligne[C12_re][col];
    C_ligne[C21_im][col] = (-1.0) * C_ligne[C12_im][col];
    C_ligne[C31_re][col] = C_ligne[C13_re][col];
    C_ligne[C31_im][col] = (-1.0) * C_ligne[C13_im][col];  
    C_ligne[C32_re][col] = C_ligne[C23_re][col];
    C_ligne[C32_im][col] = (-1.0) * C_ligne[C23_im][col];
    C_ligne[C41_re][col] = C_ligne[C14_re][col];
    C_ligne[C41_im][col] = (-1.0) * C_ligne[C14_im][col];
    C_ligne[C42_re][col] = C_ligne[C24_re][col];
    C_ligne[C42_im][col] = (-1.0) * C_ligne[C24_im][col];
    C_ligne[C43_re][col] = C_ligne[C34_re][col];
    C_ligne[C43_im][col] = (-1.0) * C_ligne[C34_im][col];
    }
  
  /* Mask for high coherences */
  for (col = 0; col < Sub_Ncol; col++) Cal_mask_rho[lig][col] = 1.0;

  /* Calculation of calibration parameters */
      
  /* Calculation of DELTA */
  for ( col = 0; col < Sub_Ncol; col++) {
    M_tmp_ligne[0][col] = ( C_ligne[C11][col] * C_ligne[C44][col] ) - ( C_ligne[C41_re][col]*C_ligne[C41_re][col] + C_ligne[C41_im][col]*C_ligne[C41_im][col] );
    if (M_tmp_ligne[0][col] == 0.0) M_tmp_ligne[0][col] = eps;  /* Problems with the determinant */
    }
    
  /* Cross-Talk ratio estimation uuu, vvv, www, zzz */
  for ( col = 0; col < Sub_Ncol; col++) {
    uuu[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C21_re][col] ) - ( C_ligne[C41_re][col]* C_ligne[C24_re][col] - C_ligne[C41_im][col]*C_ligne[C24_im][col] ) );
    uuu[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C21_im][col] ) - ( C_ligne[C41_re][col]* C_ligne[C24_im][col] + C_ligne[C41_im][col]*C_ligne[C24_re][col] ) );
    
    vvv[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C24_re][col] ) - ( C_ligne[C21_re][col]* C_ligne[C14_re][col] - C_ligne[C21_im][col]*C_ligne[C14_im][col] ) );
    vvv[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C24_im][col] ) - ( C_ligne[C21_re][col]* C_ligne[C14_im][col] + C_ligne[C21_im][col]*C_ligne[C14_re][col] ) );
    
    zzz[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C31_re][col] ) - ( C_ligne[C41_re][col]* C_ligne[C34_re][col] - C_ligne[C41_im][col]*C_ligne[C34_im][col] ) );
    zzz[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C31_im][col] ) - ( C_ligne[C41_re][col]* C_ligne[C34_im][col] + C_ligne[C41_im][col]*C_ligne[C34_re][col] ) );
    
    www[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C34_re][col] ) - ( C_ligne[C31_re][col]* C_ligne[C14_re][col] - C_ligne[C31_im][col]*C_ligne[C14_im][col] ) );
    www[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C34_im][col] ) - ( C_ligne[C31_re][col]* C_ligne[C14_im][col] + C_ligne[C31_im][col]*C_ligne[C14_re][col] ) );
    }
    
  /* Calculation of X */
  for ( col = 0; col < Sub_Ncol; col++) {
    M_tmp_ligne[cre+2][col] = C_ligne[C32_re][col] - ( zzz[cre][col]*C_ligne[C12_re][col] - zzz[cim][col]*C_ligne[C12_im][col] ) - ( www[cre][col]*C_ligne[C42_re][col] - www[cim][col]*C_ligne[C42_im][col] );
    M_tmp_ligne[cim+2][col] = C_ligne[C32_im][col] - ( zzz[cre][col]*C_ligne[C12_im][col] + zzz[cim][col]*C_ligne[C12_re][col] ) - ( www[cre][col]*C_ligne[C42_im][col] + www[cim][col]*C_ligne[C42_re][col] );
    if ( (M_tmp_ligne[cre+2][col] == 0.0) && (M_tmp_ligne[cim+2][col] == 0.0) ){
      M_tmp_ligne[cre+2][col] = eps;
      M_tmp_ligne[cim+2][col] = eps;
      }
    }
    
  /* Calculation of alpha1 */
  for ( col = 0; col < Sub_Ncol; col++) {
    M_tmp_ligne[cre][col] = C_ligne[C22][col] - ( uuu[cre][col]*C_ligne[C12_re][col] - uuu[cim][col]*C_ligne[C12_im][col] ) - ( vvv[cre][col]*C_ligne[C42_re][col] - vvv[cim][col]*C_ligne[C42_im][col] );
    M_tmp_ligne[cim][col] = (-1.0) * ( ( uuu[cre][col]*C_ligne[C12_im][col] + uuu[cim][col]*C_ligne[C12_re][col] ) + ( vvv[cre][col]*C_ligne[C42_im][col] + vvv[cim][col]*C_ligne[C42_re][col] ) );
    if ( (M_tmp_ligne[cre][col] == 0.0) && (M_tmp_ligne[cim][col] == 0.0) ){
      M_tmp_ligne[cre][col] = eps;
      M_tmp_ligne[cim][col] = eps;
      }
      
    /* Inverse of X */
    var1 = (1.0 / sqrt( M_tmp_ligne[cre+2][col]*M_tmp_ligne[cre+2][col] + M_tmp_ligne[cim+2][col]*M_tmp_ligne[cim+2][col] )) * cos(-1.0 * atan2(M_tmp_ligne[cim+2][col],M_tmp_ligne[cre+2][col]));
    var2 = (1.0 / sqrt( M_tmp_ligne[cre+2][col]*M_tmp_ligne[cre+2][col] + M_tmp_ligne[cim+2][col]*M_tmp_ligne[cim+2][col] )) * sin(-1.0 * atan2(M_tmp_ligne[cim+2][col],M_tmp_ligne[cre+2][col]));
      
    alpha1[cre][col] = M_tmp_ligne[cre][col] * var1 - M_tmp_ligne[cim][col] * var2;
    alpha1[cim][col] = M_tmp_ligne[cre][col] * var2 + M_tmp_ligne[cim][col] * var1;
    }
    
  /* Calculation of alpha2 */
  for ( col = 0; col < Sub_Ncol; col++) {
    M_tmp_ligne[cre][col] = C_ligne[C33][col] - ( zzz[cre][col]*C_ligne[C31_re][col] + www[cim][col]*C_ligne[C34_im][col] ) - ( www[cre][col]*C_ligne[C43_re][col] + www[cim][col]*C_ligne[C34_im][col] );
    M_tmp_ligne[cim][col] =( ( zzz[cim][col]*C_ligne[C31_re][col] - zzz[cre][col]*C_ligne[C31_im][col] ) + ( www[cim][col]*C_ligne[C34_re][col] - www[cre][col]*C_ligne[C34_im][col] ) );
    if ( (M_tmp_ligne[cre][col] == 0.0) && (M_tmp_ligne[cim][col] == 0.0) ){
      M_tmp_ligne[cre][col] = eps;
      M_tmp_ligne[cim][col] = eps;
      }

    /* Inverse */
    var1 = (1.0 / sqrt( M_tmp_ligne[cre][col]*M_tmp_ligne[cre][col] + M_tmp_ligne[cim][col]*M_tmp_ligne[cim][col] )) * cos(-1.0 * atan2(M_tmp_ligne[cim][col],M_tmp_ligne[cre][col]));
    var2 = (1.0 / sqrt( M_tmp_ligne[cre][col]*M_tmp_ligne[cre][col] + M_tmp_ligne[cim][col]*M_tmp_ligne[cim][col] )) * sin(-1.0 * atan2(M_tmp_ligne[cim][col],M_tmp_ligne[cre][col]));
      
    alpha2[cre][col] = M_tmp_ligne[cre+2][col] * var1 + M_tmp_ligne[cim+2][col] * var2;
    alpha2[cim][col] = M_tmp_ligne[cre+2][col] * var2 - M_tmp_ligne[cim+2][col] * var1;
    }
    
  /* Calculation of alpha */
  for ( col = 0; col < Sub_Ncol; col++) {
    var1 = AmplitudeComplex_v2(alpha1[cre][col]*alpha2[cre][col]-alpha1[cim][col]*alpha2[cim][col],alpha1[cre][col]*alpha2[cim][col]+alpha1[cim][col]*alpha2[cre][col]);
    var2 = AmplitudeComplex_v2(alpha2[cre][col],alpha2[cim][col]);
    if ( var2 == 0 ) var2 = eps;
    alpha[cre][col] = (1.0 / (2 * var2)) * ( var1 - 1 + sqrt ( ( var1 - 1 )*( var1 - 1 ) + 4 * var2 * var2 ) ) * cos(atan2(alpha2[cim][col],alpha2[cre][col]));
    alpha[cim][col] = (1.0 / (2 * var2)) * ( var1 - 1 + sqrt ( ( var1 - 1 )*( var1 - 1 ) + 4 * var2 * var2 ) ) * sin(atan2(alpha2[cim][col],alpha2[cre][col]));
    }

  /*********************************/
  /* Calculation of range profiles */
  /*********************************/
  for (col = 0; col < Sub_Ncol; col++) {
  /* Calculation of alpha in range */
    alpha_rg[cre][col] += alpha[cre][col];
    alpha_rg[cim][col] += alpha[cim][col];
  /* Calculation of alpha1 in range */
    if (Cal_mask[lig][col] == 1.0) {
      alpha1_rg[cre][col] += alpha1[cre][col];
      alpha1_rg[cim][col] += alpha1[cim][col];
      indalp1 ++;
      }
  /* Calculation of alpha2 in range */
    if (Cal_mask[lig][col] == 1.0) {
      alpha2_rg[cre][col] += alpha2[cre][col];
      alpha2_rg[cim][col] += alpha2[cim][col];
      indalp2 ++;
      }
  /* Generation of uuu in range */
    if (Cal_mask_rho[lig][col] == 1.0) {
      uuu_rg[cre][col] += uuu[cre][col];
      uuu_rg[cim][col] += uuu[cim][col];
      induuu ++;
      }
  /* Generation of vvv in range */
    if (Cal_mask_rho[lig][col] == 1.0) {
      vvv_rg[cre][col] += vvv[cre][col];
      vvv_rg[cim][col] += vvv[cim][col];
      indvvv ++;
      }
  /* Generation of www in range */
    if (Cal_mask_rho[lig][col] == 1.0) {
      www_rg[cre][col] += www[cre][col];
      www_rg[cim][col] += www[cim][col];
      indwww ++;
      }
  /* Generation of zzz in range */
    if (Cal_mask_rho[lig][col] == 1.0) {
      zzz_rg[cre][col] += zzz[cre][col];
      zzz_rg[cim][col] += zzz[cim][col];
      indzzz ++;
      }
    }      
  } // lig

  /*********************************/
  /* Calculation of range profiles */
  /*********************************/
  
  /* Inisialization of the mask */
  for (lig = 0; lig < Sub_Nlig; lig++)
    for (col = 0; col < Sub_Ncol; col++) Cal_mask[lig][col] = 0.0;
  
  /* Calculation of parameters in range */
  for (col = 0; col < Sub_Ncol; col++) {
    alpha_rg[cre][col] = alpha_rg[cre][col] / (float) Sub_Ncol;
    alpha_rg[cim][col] = alpha_rg[cim][col] / (float) Sub_Ncol;
    alpha_rg[cab][col] = AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]);
    alpha_rg[cph][col] = atan2(alpha_rg[cim][col],alpha_rg[cre][col]);
  
    alpha_cal_final[cre][col]  = alpha_rg[cre][col];
    alpha_cal_final[cim][col]  = alpha_rg[cim][col];
    alpha_cal_final[cre+2][col]  = (1.0 / alpha_rg[cab][col]) * cos(-1.0 * alpha_rg[cph][col]); /* Inverse of alpha real part*/
    alpha_cal_final[cim+2][col]  = (1.0 / alpha_rg[cab][col]) * sin(-1.0 * alpha_rg[cph][col]); /* Inverse of alpha imag part*/
  
    alpha1_rg[cre][col] = alpha1_rg[cre][col] / (float) indalp1;
    alpha1_rg[cim][col] = alpha1_rg[cim][col] / (float) indalp1;
  
    alpha2_rg[cre][col] = alpha2_rg[cre][col] / (float) indalp2;
    alpha2_rg[cim][col] = alpha2_rg[cim][col] / (float) indalp2;
  
    uuu_cal_final[cre][col] = uuu_rg[cre][col] / (float) induuu;
    uuu_cal_final[cim][col] = uuu_rg[cim][col] / (float) induuu;
    vvv_cal_final[cre][col] = vvv_rg[cre][col] / (float) indvvv;
    vvv_cal_final[cim][col] = vvv_rg[cim][col] / (float) indvvv;
    www_cal_final[cre][col] = www_rg[cre][col] / (float) indwww;
    www_cal_final[cim][col] = www_rg[cim][col] / (float) indwww;
    zzz_cal_final[cre][col] = zzz_rg[cre][col] / (float) indzzz;
    zzz_cal_final[cim][col] = zzz_rg[cim][col] / (float) indzzz;
    }
  
  /*********************/
  /* Final Calibration */
  /*********************/
      
  /* Input S2 files opening */
  for (np = 0; np < Npolar_S; np++) {
    sprintf(file_name, "%s%s", in_dirS2, FileInputS2[np]);
    if ((in_fileS2[np] = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open input file : ", file_name);
    }
  
  /* Output file opening */
  for (np = 0; np < Npolar_S; np++) {
  sprintf(file_name, "%s%s", out_dirS2, FileOutputS2[np]);
  if ((out_fileS2[np] = fopen(file_name, "wb")) == NULL)
     edit_error("Could not open output file : ", file_name);
  }

  /* Input file sub-window reading */
  for (np = 0; np < Npolar_S; np++) rewind(in_fileS2[np]);
  for (np = 0; np < Npolar_S; np++) rewind(out_fileS2[np]);
  
  /* Jumps Off_lig in input files */
  for (lig = 0; lig < Off_lig ; lig++) {  
    for (np = 0; np < Npolar_S; np++) {
      fread(&M_tmp_ligne[0][0], sizeof(float), 2 * Ncol, in_fileS2[np]);
      }
    }
  
/* calibrates in a line by line basis */
for (lig = 0; lig < Sub_Nlig; lig++){
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  
  /* Reads a line of S of Sub_Ncol cols */
  for (np = 0; np < Npolar_S; np++) {
    fread(&M_tmp_ligne[np][0], sizeof(float), 2 * Ncol, in_fileS2[np]);
      for (col = 0; col < Sub_Ncol; col++) {
        ind = 2 * (col + Off_col);
        S_tmp_block[np][0][2*col]   = M_tmp_ligne[np][ind];
        S_tmp_block[np][0][2*col + 1] = M_tmp_ligne[np][ind + 1];
        }
    }
  for (col = 0; col < Sub_Ncol; col++){
    
    /* Calibration matrix */
    D_inv = 1.0 / (1.0 + AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]));
    
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],zzz_cal_final[cre][col],-1.0*zzz_cal_final[cim][col],&var1,&var2);
    var1 = uuu_cal_final[cre][col] - var1;
    var2 = -1.0*uuu_cal_final[cim][col] - var2;
    ComplexProduct2(alpha_cal_final[cre][col],alpha_cal_final[cim][col],www_cal_final[cre][col],www_cal_final[cim][col],&var3,&var4);
    var3 = var3 + vvv_cal_final[cre][col];
    var4 = var4 + vvv_cal_final[cim][col];
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],var3,var4,&var5,&var6);
    var1 = var1 - var5;
    var2 = var2 - var6;
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],var1,var2,&P01_re,&P01_im);
    
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],zzz_cal_final[cre][col],-1.0*zzz_cal_final[cim][col],&var1,&var2);
    var1 = uuu_cal_final[cre][col] - var1;
    var2 = -1.0*uuu_cal_final[cim][col] - var2;
    ComplexProduct2(alpha_cal_final[cre][col],alpha_cal_final[cim][col],var1,var2,&var5,&var6);
    ComplexProduct2(alpha_cal_final[cre][col],alpha_cal_final[cim][col],www_cal_final[cre][col],www_cal_final[cim][col],&var3,&var4);
    var3 = var3 + vvv_cal_final[cre][col];
    var4 = var4 + vvv_cal_final[cim][col];
    var1 = -1.0*var3 - var5;
    var2 = -1.0*var4 - var6;
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],var1,var2,&P02_re,&P02_im);
    
    var1 = uuu_cal_final[cre][col] + (alpha_cal_final[cre][col]*zzz_cal_final[cre][col] - alpha_cal_final[cim][col]*zzz_cal_final[cim][col]);
    var2 = uuu_cal_final[cim][col] + (alpha_cal_final[cre][col]*zzz_cal_final[cim][col] + alpha_cal_final[cim][col]*zzz_cal_final[cre][col]);
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],var1,var2,&var3,&var4);
    var1 = vvv_cal_final[cre][col] - (alpha_cal_final[cre][col]*www_cal_final[cre][col] - alpha_cal_final[cim][col]*www_cal_final[cim][col]);
    var2 = (alpha_cal_final[cre][col]*www_cal_final[cim][col] + alpha_cal_final[cim][col]*www_cal_final[cre][col]) - vvv_cal_final[cim][col];
    P21_re = AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col])*(var1 - var3);
    P21_im = AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col])*(var2 - var4);
      
    ComplexProduct2(alpha_cal_final[cre][col],alpha_cal_final[cim][col],zzz_cal_final[cre][col],zzz_cal_final[cim][col],&var1,&var2);
    var1 = uuu_cal_final[cre][col] + var1;
    var2 = uuu_cal_final[cim][col] + var2;
    ComplexProduct2(alpha_cal_final[cre][col],-1.0*alpha_cal_final[cim][col],www_cal_final[cre][col],-1.0*www_cal_final[cim][col],&var3,&var4);
    var3 = vvv_cal_final[cre][col]-var3;
    var4 = -1.0*vvv_cal_final[cim][col]-var4;
    ComplexProduct2(alpha_cal_final[cre][col],alpha_cal_final[cim][col],var3,var4,&var5,&var6);
    P22_re = AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * (-var1-var3);
    P22_im = AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]) * (-var2-var4);
    
    cal_matrix[cre][0][0] = alpha_cal_final[cre+2][col]; cal_matrix[cim][0][0] = alpha_cal_final[cim+2][col];
    cal_matrix[cre][0][1] = P01_re; cal_matrix[cim][0][1] = P01_im;
    cal_matrix[cre][0][2] = P02_re; cal_matrix[cim][0][2] = P02_im;
    cal_matrix[cre][0][3] = 0.; cal_matrix[cim][0][3] = 0.;
    
    cal_matrix[cre][1][0] = -1.0 * D_inv * (alpha_cal_final[cre][col]*uuu_cal_final[cre][col] + alpha_cal_final[cim][col]*uuu_cal_final[cim][col]);
    cal_matrix[cim][1][0] = -1.0 * D_inv * (alpha_cal_final[cre][col]*uuu_cal_final[cim][col] - alpha_cal_final[cim][col]*uuu_cal_final[cre][col]);
    cal_matrix[cre][1][1] = D_inv * alpha_cal_final[cre][col]; cal_matrix[cim][1][1] = -1.0 * D_inv * alpha_cal_final[cim][col];
    cal_matrix[cre][1][2] = D_inv ; cal_matrix[cim][1][2] = 0.;
    cal_matrix[cre][1][3] = -1.0 * D_inv * (alpha_cal_final[cre][col]*vvv_cal_final[cre][col] + alpha_cal_final[cim][col]*vvv_cal_final[cim][col]);
    cal_matrix[cim][1][3] = -1.0 * D_inv * (alpha_cal_final[cre][col]*vvv_cal_final[cim][col] - alpha_cal_final[cim][col]*vvv_cal_final[cre][col]);
    
    cal_matrix[cre][2][0] = 0.; cal_matrix[cim][2][0] = 0.;
    cal_matrix[cre][2][1] = P21_re; cal_matrix[cim][2][1] = P21_im;
    cal_matrix[cre][2][2] = P22_re; cal_matrix[cim][2][2] = P22_im;
    cal_matrix[cre][2][3] = 1.; cal_matrix[cim][2][3] = 0.;
    
    ind = 2 * (col + Off_col);
    
    /* Calibration of hh */
    S_tmp_block[hh][1][2*col]    = 0.;
    S_tmp_block[hh][1][2*col + 1]  = 0.;
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][0][0]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][0][0]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][0][0]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][0][0]);
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][0][1]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][0][1]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][0][1]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][0][1]);
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][0][2]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][0][2]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][0][2]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][0][2]);
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][0][3]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][0][3]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][0][3]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][0][3]);
    
    /* Calibration of vh */
    S_tmp_block[vh][1][2*col]    = 0.;
    S_tmp_block[vh][1][2*col + 1]  = 0.;
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][1][0]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][1][0]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][1][0]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][1][0]);
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][1][1]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][1][1]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][1][1]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][1][1]);
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][1][2]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][1][2]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][1][2]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][1][2]);
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][1][3]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][1][3]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][1][3]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][1][3]);
    
    /* Calibration of hv */
    S_tmp_block[hv][1][2*col]    = S_tmp_block[vh][1][2*col];
    S_tmp_block[hv][1][2*col + 1]  = S_tmp_block[vh][1][2*col + 1];
    
    /* Calibration of vv */
    S_tmp_block[vv][1][2*col]    = 0.;
    S_tmp_block[vv][1][2*col + 1]  = 0.;
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][2][0]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][2][0]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][2][0]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][2][0]);
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][2][1]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][2][1]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][2][1]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][2][1]);
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][2][2]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][2][2]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][2][2]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][2][2]);
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][2][3]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][2][3]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][2][3]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][2][3]);
    
  }
  
  /* Save a line of S of Sub_Ncol cols */
  for (np = 0; np < Npolar_S; np++) {
    fwrite(&S_tmp_block[np][1][0], sizeof(float), 2 * Sub_Ncol, out_fileS2[np]);
     for (col = 0; col < Sub_Ncol; col++) {
       ind = 2 * (col + Off_col);
       S_tmp_block[np][0][2*col]   = M_tmp_ligne[np][ind];
       S_tmp_block[np][0][2*col + 1] = M_tmp_ligne[np][ind + 1];
       }
    }
  }
  
  /* Close of Files */
  for (np = 0; np < Npolar_S; np++) fclose(in_fileS2[np]);
  for (np = 0; np < Npolar_C; np++) fclose(in_fileC4[np]);
  for (np = 0; np < Npolar_S; np++) fclose(out_fileS2[np]);
   
  /* Memory Libertation */
  free_matrix_float(alpha,2);
  free_matrix_float(alpha_rg,4);
  free_matrix_float(alpha_cal_final,4);
  free_matrix_float(alpha1,2);
  free_matrix_float(alpha1_rg,2);
  free_matrix_float(alpha2,2);
  free_matrix_float(alpha2_rg,2);
  
  free_matrix_float(uuu,2);
  free_matrix_float(uuu_rg,2);
  free_matrix_float(uuu_cal_final,2);
  free_matrix_float(vvv,2);
  free_matrix_float(vvv_rg,2);
  free_matrix_float(vvv_cal_final,2);
  free_matrix_float(www,2); 
  free_matrix_float(www_rg,2);
  free_matrix_float(www_cal_final,2);
  free_matrix_float(zzz,2); 
  free_matrix_float(zzz_rg,2);
  free_matrix_float(zzz_cal_final,2);
  
  free_matrix_float(M_tmp_ligne,Npolar_S);
  free_matrix3d_float(S_tmp_block,Npolar_S,2);
  free_matrix_float(C_ligne,Npolar_C_full);
  
  free_matrix_float(Cal_mask,Sub_Nlig);
  free_matrix_float(Cal_mask_rho,Sub_Nlig);

  free_matrix3d_float(cal_matrix,2,3);
    
  return 1;
}

/*******************************************************************
Routine  : AmplitudeComplex_v2
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  : 
*-------------------------------------------------------------------
Description :  Calculates the amplitude of a complex number
*-------------------------------------------------------------------
Inputs arguments :
Re    : Input Real part
Im  : Input Imaginary part
Returned values  :
  : Amplitude
*******************************************************************/
float AmplitudeComplex_v2(float Re, float Im)
{
  return(sqrt( (Re * Re) + (Im * Im) ) );
}

/*******************************************************************
Routine  : ComplexProduct2
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------
Description :  Product of two complex numbers
*-------------------------------------------------------------------
Inputs arguments :
Re1    : Input 1 Real part
Im1  : Input 1 Imaginary part
Re2    : Input 2 Real part
Im2  : Input 2 Imaginary part
Returned values  :
ReP   : Result Real part
ImP  : Result Imaginary part
*******************************************************************/
void ComplexProduct2(float Re1, float Im1, float Re2, float Im2, float *ReP, float *ImP)
{
  *ReP = (Re1 * Re2) - (Im1 * Im2);
  *ImP = (Re1 * Im2) + (Im1 * Re2);
}
