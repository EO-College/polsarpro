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

File   : calibration_papathanassiou.c
Project  : ESA_POLSARPRO
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Creation : 06/2005
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

Description :  Relative polarimetric calibration based on the method 
of Kostantinos P. Papathanassiou

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
#define C11     0
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
float mean_value_re(float **Data, int Nlin, int Ncol);
float std_value_re(float **Data, int Nlin, int Ncol);
void PolyFit_3order(float **data_range, int Ncol, float *coef,int Ncol_final, float *data_range_final);
void ComplexProduct2(float Re1, float Im1, float Re2, float Im2, float *ReP, float *ImP);
void ComplexProduct3(float Re1, float Im1, float Re2, float Im2, float Re3, float Im3, float *ReP, float *ImP);
void ComplexProduct4(float Re1, float Im1, float Re2, float Im2, float Re3, float Im3, float Re4, float Im4, float *ReP, float *ImP);
double *vector_double(int nrh);
void free_vector_double(double *m);
double **matrix_double(int nrh, int nch);
void free_matrix_double(double **m, int nrh);
double ***matrix3d_double(int nz, int nrh, int nch);
void free_matrix3d_double(double ***m, int nz, int nrh);
void InverseHermitianMatrix4Double(double ***HM, double ***IHM);
void ProductCmplxMatrixDouble(double ***HM1, double ***HM2, double ***HM3, int N);
void InverseCmplxMatrix2Double(double ***HM, double ***IHM);
void PseudoInverseHermitianMatrix4Double(double ***HM, double ***IHM);
void DeterminantHermitianMatrix4Double(double ***HM, double *det);
void DeterminantCmplxMatrix2Double(double ***M, double *det);

/******************************************************************/

int main(int argc, char *argv[])
{
  /*******************/  
  /* LOCAL VARIABLES */
  /*******************/
  
  /* Input/Output file pointer arrays*/
  FILE *in_fileS2[4];
  FILE *out_fileS2[4];
  FILE *falpha, *fuuu, *fvvv, *fwww, *fzzz, *fmask;

  char in_dirS2[FilePathLength],out_dirS2[FilePathLength],tmp_dir[FilePathLength],file_name[FilePathLength];
  char *FileInputS2[4]  = { "s11.bin", "s12.bin", "s21.bin", "s22.bin"};
  char *FileOutputS2[4] = { "s11.bin", "s12.bin", "s21.bin", "s22.bin"};
  
  /* Input variables */
  int Box_lig, Box_col;  /* Dimensions of the averaging box */
  
  /* Temporal matrices */
  float **M_tmp_ligne;
  float ***S_tmp_block;
  float **C_ligne;
  float *Cal_mask_rho;
  
  /* Calibration variables */
  float **alpha1, **alpha2, **alpha, **alpha_abs, **alpha_rg, *alpha_tmp, *alpha_tmp2;
  float **uuu, **vvv, **www, **zzz, **uuu_rg, **vvv_rg, **www_rg, **zzz_rg;
  float **alpha_cal_final, **uuu_cal_final, **vvv_cal_final, **www_cal_final, **zzz_cal_final;
  float *pol_coef;
  float ***cal_matrix;
   
  /* Internal variables */
  int Npolar_S, Npolar_C_full, np;
  int lig, col, sub_lig, sub_col, Averaged_Nlig, Averaged_Ncol, N_elem;
  int ind, indalp, induuu, indvvv, indwww, indzzz;
  float var1, var2, Cal_mask;
  
  /******************/
  /* PROGRAM STARTS */
  /******************/
  
  if (argc < 10){
  edit_error("calibration_papathanassiou in_dir out_dir tmp_dir nwin_row nwin_col Off_lig Off_col Sub_nlig Sub_ncol\n","");
  } else {
  strcpy(in_dirS2, argv[1]);
  strcpy(out_dirS2, argv[2]);
  strcpy(tmp_dir, argv[3]);
  Box_lig  = atoi(argv[4]);
  Box_col  = atoi(argv[5]);
  Off_lig  = atoi(argv[6]);
  Off_col  = atoi(argv[7]);
  Sub_Nlig = atoi(argv[8]);
  Sub_Ncol = atoi(argv[9]);
  }
  
  check_dir(in_dirS2);
  check_dir(out_dirS2);
  check_dir(tmp_dir);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  /* Initialization of variables */
  Npolar_S    = 4;
  Npolar_C_full = 28;
  N_elem  = Box_lig * Box_col;    /* Number of elements to obtain C */

  /* Input/Output configurations */
  read_config(in_dirS2, &Nlig, &Ncol, PolarCase, PolarType);
  
  /* Matrix Declarations */
  Averaged_Nlig = floor(Sub_Nlig/Box_lig);  /* Determines dimensions of calibrations parameters */
  Averaged_Ncol = floor(Sub_Ncol/Box_col);  /* Determines dimensions of calibrations parameters */
    
  alpha     = matrix_float(2,Averaged_Ncol);  /* Calibration parameters */
  alpha_rg  = matrix_float(4,Averaged_Ncol);
  alpha_cal_final = matrix_float(4,Sub_Ncol);
  alpha_abs = matrix_float(Averaged_Nlig,Averaged_Ncol);
  alpha_tmp = vector_float(Averaged_Ncol);
  alpha_tmp2= vector_float(Averaged_Ncol);
  alpha1    = matrix_float(2,Averaged_Ncol);
  alpha2    = matrix_float(2,Averaged_Ncol);
  
  uuu       = matrix_float(2,Averaged_Ncol); /* 0->R, 1->I */
  uuu_rg    = matrix_float(2,Averaged_Ncol);
  uuu_cal_final  = matrix_float(2,Sub_Ncol);
  vvv       = matrix_float(2,Averaged_Ncol); /* 0->R, 1->I */
  vvv_rg    = matrix_float(2,Averaged_Ncol);
  vvv_cal_final  = matrix_float(2,Sub_Ncol);
  www       = matrix_float(2,Averaged_Ncol); /* 0->R, 1->I */
  www_rg    = matrix_float(2,Averaged_Ncol);
  www_cal_final  = matrix_float(2,Sub_Ncol);
  zzz       = matrix_float(2,Averaged_Ncol); /* 0->R, 1->I */
  zzz_rg    = matrix_float(2,Averaged_Ncol);
  zzz_cal_final  = matrix_float(2,Sub_Ncol);
  
  pol_coef    = vector_float(4);
  
  M_tmp_ligne = matrix_float(Npolar_S,2*Ncol);
  S_tmp_block = matrix3d_float(Npolar_S,Box_lig,2*Sub_Ncol);
  C_ligne     = matrix_float(Npolar_C_full,Averaged_Ncol);
  
  Cal_mask_rho  = vector_float(Averaged_Ncol); //CHANGE

  cal_matrix  = matrix3d_float(2,4,4);
  
  /* Input file opening */
  for (np = 0; np < Npolar_S; np++) {
    sprintf(file_name, "%s%s", in_dirS2, FileInputS2[np]);
    if ((in_fileS2[np] = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open input file : ", file_name);
    }

  sprintf(file_name, "%salpha.bin", tmp_dir);
  if ((falpha = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%smask.bin", tmp_dir);
  if ((fmask = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%suuu.bin", tmp_dir);
  if ((fuuu = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%svvv.bin", tmp_dir);
  if ((fvvv = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%swww.bin", tmp_dir);
  if ((fwww = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%szzz.bin", tmp_dir);
  if ((fzzz = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  /* Input file sub-window reading */
  for (np = 0; np < Npolar_S; np++) rewind(in_fileS2[np]);
  
  /* Jumps Off_lig */
  for (lig = 0; lig < Off_lig ; lig++) {  
    for (np = 0; np < Npolar_S; np++) {
      fread(&M_tmp_ligne[0][0], sizeof(float), 2 * Ncol, in_fileS2[np]);
      }
    }

  /**********************************/
  /* Processing of a block of lines */
  /**********************************/
  
for (sub_lig = 0; sub_lig < Averaged_Nlig; sub_lig++) {
  if (sub_lig%(int)(Averaged_Nlig/20) == 0) {printf("%f\r", 100. * sub_lig / (Averaged_Nlig - 1));fflush(stdout);}

   /* Initialization of C */
   for (np = 0; np < Npolar_C_full; np++)
     for (col = 0; col < Averaged_Ncol; col++) C_ligne[np][col] = 0.0;
      
  /* Reads a block of S of Box_lig*Sub_Ncol */
  for (lig = 0; lig < Box_lig; lig++) {
    for (np = 0; np < Npolar_S; np++) {
      fread(&M_tmp_ligne[np][0], sizeof(float), 2 * Ncol, in_fileS2[np]);
      for (col = 0; col < Sub_Ncol; col++) {
        ind = 2 * (col + Off_col);
        S_tmp_block[np][lig][2*col]   = M_tmp_ligne[np][ind];
        S_tmp_block[np][lig][2*col + 1] = M_tmp_ligne[np][ind + 1];
        }
      }
    }
  
  /* Creates the C matrix from the block */
  for(lig = 0; lig < Box_lig; lig++) {
    for (sub_col = 0; sub_col < Averaged_Ncol; sub_col++) {
      for ( col = 0; col < Box_col; col++) {
        ind = 2 * (col + sub_col*Box_col);
        /* Kostas inverses cross-channels */
        C_ligne[C11][sub_col]  += ( (S_tmp_block[hh][lig][ind] * S_tmp_block[hh][lig][ind]) + (S_tmp_block[hh][lig][ind+1] * S_tmp_block[hh][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C22][sub_col]  += ( (S_tmp_block[vh][lig][ind] * S_tmp_block[vh][lig][ind]) + (S_tmp_block[vh][lig][ind+1] * S_tmp_block[vh][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C33][sub_col]  += ( (S_tmp_block[hv][lig][ind] * S_tmp_block[hv][lig][ind]) + (S_tmp_block[hv][lig][ind+1] * S_tmp_block[hv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C44][sub_col]  += ( (S_tmp_block[vv][lig][ind] * S_tmp_block[vv][lig][ind]) + (S_tmp_block[vv][lig][ind+1] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C12_re][sub_col] += ( (S_tmp_block[hh][lig][ind] * S_tmp_block[vh][lig][ind]) + (S_tmp_block[hh][lig][ind+1] * S_tmp_block[vh][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C12_im][sub_col] += ( (S_tmp_block[hh][lig][ind+1] * S_tmp_block[vh][lig][ind]) - (S_tmp_block[hh][lig][ind] * S_tmp_block[vh][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C13_re][sub_col] += ( (S_tmp_block[hh][lig][ind] * S_tmp_block[hv][lig][ind]) + (S_tmp_block[hh][lig][ind+1] * S_tmp_block[hv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C13_im][sub_col] += ( (S_tmp_block[hh][lig][ind+1] * S_tmp_block[hv][lig][ind]) - (S_tmp_block[hh][lig][ind] * S_tmp_block[hv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C14_re][sub_col] += ( (S_tmp_block[hh][lig][ind] * S_tmp_block[vv][lig][ind]) + (S_tmp_block[hh][lig][ind+1] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C14_im][sub_col] += ( (S_tmp_block[hh][lig][ind+1] * S_tmp_block[vv][lig][ind]) - (S_tmp_block[hh][lig][ind] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C23_re][sub_col] += ( (S_tmp_block[vh][lig][ind] * S_tmp_block[hv][lig][ind]) + (S_tmp_block[vh][lig][ind+1] * S_tmp_block[hv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C23_im][sub_col] += ( (S_tmp_block[vh][lig][ind+1] * S_tmp_block[hv][lig][ind]) - (S_tmp_block[vh][lig][ind] * S_tmp_block[hv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C24_re][sub_col] += ( (S_tmp_block[vh][lig][ind] * S_tmp_block[vv][lig][ind]) + (S_tmp_block[vh][lig][ind+1] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C24_im][sub_col] += ( (S_tmp_block[vh][lig][ind+1] * S_tmp_block[vv][lig][ind]) - (S_tmp_block[vh][lig][ind] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C34_re][sub_col] += ( (S_tmp_block[hv][lig][ind] * S_tmp_block[vv][lig][ind]) + (S_tmp_block[hv][lig][ind+1] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        C_ligne[C34_im][sub_col] += ( (S_tmp_block[hv][lig][ind+1] * S_tmp_block[vv][lig][ind]) - (S_tmp_block[hv][lig][ind] * S_tmp_block[vv][lig][ind+1]) ) * (1./N_elem);
        }
      }
    }
     
  for ( col = 0; col < Averaged_Ncol; col++) {
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
  for (col = 0; col < Averaged_Ncol; col++) Cal_mask_rho[col] = 1.0;
  for (col = 0; col < Averaged_Ncol; col++) {
    var1 = AmplitudeComplex_v2(C_ligne[C13_re][col],C_ligne[C13_im][col]) / sqrt( C_ligne[C11][col] * C_ligne[C33][col] );
    var2 = AmplitudeComplex_v2(C_ligne[C42_re][col],C_ligne[C42_im][col]) / sqrt( C_ligne[C44][col] * C_ligne[C22][col] );
    if ( (var1 > rho_cross_limit) || (var2 > rho_cross_limit)) Cal_mask_rho[col] = 0.0;
    }
  
  /* Calculation of calibration parameters */
      
  /* Calculation of DELTA */
  for ( col = 0; col < Averaged_Ncol; col++) {
    M_tmp_ligne[0][col] = ( C_ligne[C11][col] * C_ligne[C44][col] ) - ( C_ligne[C41_re][col]*C_ligne[C41_re][col] + C_ligne[C41_im][col]*C_ligne[C41_im][col] );
    if (M_tmp_ligne[0][col] == 0.0) M_tmp_ligne[0][col] = eps;  /* Problems with the determinant */
    }
    
  /* Cross-Talk ratio estimation uuu, vvv, www, zzz */
  for ( col = 0; col < Averaged_Ncol; col++) {
    uuu[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C12_re][col] ) - ( C_ligne[C14_re][col]* C_ligne[C42_re][col] - C_ligne[C14_im][col]*C_ligne[C42_im][col] ) );
    uuu[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C12_im][col] ) - ( C_ligne[C14_re][col]* C_ligne[C42_im][col] + C_ligne[C14_im][col]*C_ligne[C42_re][col] ) );
  
    vvv[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C42_re][col] ) - ( C_ligne[C12_re][col]* C_ligne[C41_re][col] - C_ligne[C12_im][col]*C_ligne[C41_im][col] ) );
    vvv[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C42_im][col] ) - ( C_ligne[C12_re][col]* C_ligne[C41_im][col] + C_ligne[C12_im][col]*C_ligne[C41_re][col] ) );
    
    www[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C13_re][col] ) - ( C_ligne[C14_re][col]* C_ligne[C43_re][col] - C_ligne[C14_im][col]*C_ligne[C43_im][col] ) );
    www[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C44][col] * C_ligne[C13_im][col] ) - ( C_ligne[C14_re][col]* C_ligne[C43_im][col] + C_ligne[C14_im][col]*C_ligne[C43_re][col] ) );
    
    zzz[cre][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C43_re][col] ) - ( C_ligne[C13_re][col]* C_ligne[C41_re][col] - C_ligne[C13_im][col]*C_ligne[C41_im][col] ) );
    zzz[cim][col] = (1.0 / M_tmp_ligne[0][col]) * ( ( C_ligne[C11][col] * C_ligne[C43_im][col] ) - ( C_ligne[C13_re][col]* C_ligne[C41_im][col] + C_ligne[C13_im][col]*C_ligne[C41_re][col] ) );
    }
    
  /* Calculation of X */
  for ( col = 0; col < Averaged_Ncol; col++) {
    M_tmp_ligne[cre+2][col] = C_ligne[C32_re][col] - ( zzz[cre][col]*C_ligne[C12_re][col] - zzz[cim][col]*C_ligne[C12_im][col] ) - ( www[cre][col]*C_ligne[C42_re][col] - www[cim][col]*C_ligne[C42_im][col] ); //CHANGE
    M_tmp_ligne[cim+2][col] = C_ligne[C32_im][col] - ( zzz[cre][col]*C_ligne[C12_im][col] + zzz[cim][col]*C_ligne[C12_re][col] ) - ( www[cre][col]*C_ligne[C42_im][col] + www[cim][col]*C_ligne[C42_re][col] );
    if ( (M_tmp_ligne[cre+2][col] == 0.0) && (M_tmp_ligne[cim+2][col] == 0.0) ){
      M_tmp_ligne[cre+2][col] = eps;
      M_tmp_ligne[cim+2][col] = eps;
      }
    }
    
  /* Calculation of alpha1 */
  for ( col = 0; col < Averaged_Ncol; col++) {
    M_tmp_ligne[cre][col] = C_ligne[C22][col] - ( uuu[cre][col]*C_ligne[C12_re][col] - uuu[cim][col]*C_ligne[C12_im][col] ) - ( vvv[cre][col]*C_ligne[C42_re][col] - vvv[cim][col]*C_ligne[C42_im][col] ); //CHANGE
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
  for ( col = 0; col < Averaged_Ncol; col++) {
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
  for ( col = 0; col < Averaged_Ncol; col++) {
    var1 = AmplitudeComplex_v2(alpha1[cre][col]*alpha2[cre][col]-alpha1[cim][col]*alpha2[cim][col],alpha1[cre][col]*alpha2[cim][col]+alpha1[cim][col]*alpha2[cre][col]);
    var2 = AmplitudeComplex_v2(alpha2[cre][col],alpha2[cim][col]);
    if ( var2 == 0 ) var2 = eps;
    alpha[cre][col] = (1.0 / (2 * var2)) * ( var1 - 1 + sqrt ( ( var1 - 1 )*( var1 - 1 ) + 4 * var2 * var2 ) ) * cos(atan2(alpha2[cim][col],alpha2[cre][col]));
    alpha[cim][col] = (1.0 / (2 * var2)) * ( var1 - 1 + sqrt ( ( var1 - 1 )*( var1 - 1 ) + 4 * var2 * var2 ) ) * sin(atan2(alpha2[cim][col],alpha2[cre][col]));
    alpha_abs[sub_lig][col] = AmplitudeComplex_v2(alpha[cre][col],alpha[cim][col]);
    }

  fwrite(&alpha[cre][0], sizeof(float), Averaged_Ncol, falpha);
  fwrite(&alpha[cim][0], sizeof(float), Averaged_Ncol, falpha);
  fwrite(&uuu[cre][0], sizeof(float), Averaged_Ncol, fuuu);
  fwrite(&uuu[cim][0], sizeof(float), Averaged_Ncol, fuuu);
  fwrite(&vvv[cre][0], sizeof(float), Averaged_Ncol, fvvv);
  fwrite(&vvv[cim][0], sizeof(float), Averaged_Ncol, fvvv);
  fwrite(&www[cre][0], sizeof(float), Averaged_Ncol, fwww);
  fwrite(&www[cim][0], sizeof(float), Averaged_Ncol, fwww);
  fwrite(&zzz[cre][0], sizeof(float), Averaged_Ncol, fzzz);
  fwrite(&zzz[cim][0], sizeof(float), Averaged_Ncol, fzzz);
  fwrite(&Cal_mask_rho[0], sizeof(float), Averaged_Ncol, fmask);
  } // sub_lig
  
  fclose(falpha);
  fclose(fuuu);
  fclose(fvvv);
  fclose(fwww);
  fclose(fzzz);
  fclose(fmask);
  
  /*********************************/
  /* Calculation of range profiles */
  /*********************************/

  sprintf(file_name, "%salpha.bin", tmp_dir);
  if ((falpha = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%smask.bin", tmp_dir);
  if ((fmask = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%suuu.bin", tmp_dir);
  if ((fuuu = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%svvv.bin", tmp_dir);
  if ((fvvv = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%swww.bin", tmp_dir);
  if ((fwww = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  sprintf(file_name, "%szzz.bin", tmp_dir);
  if ((fzzz = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  
  var1 = mean_value_re(alpha_abs,Averaged_Nlig,Averaged_Ncol);
  var2 = std_value_re(alpha_abs,Averaged_Nlig,Averaged_Ncol);

  for (col = 0; col < Averaged_Ncol; col++) {
    alpha_rg[cre][col] = 0.; alpha_rg[cim][col] = 0.;
    uuu_rg[cre][col] = 0.; uuu_rg[cim][col] = 0.;
    vvv_rg[cre][col] = 0.; vvv_rg[cim][col] = 0.;
    www_rg[cre][col] = 0.; www_rg[cim][col] = 0.;
    zzz_rg[cre][col] = 0.; zzz_rg[cim][col] = 0.;
    }
    
  indalp = 0; induuu = 0; indvvv = 0; indwww = 0; indzzz = 0;

  for (lig = 0; lig < Averaged_Nlig; lig++) {
    fread(&alpha[cre][0], sizeof(float), Averaged_Ncol, falpha);
    fread(&alpha[cim][0], sizeof(float), Averaged_Ncol, falpha);
    fread(&uuu[cre][0], sizeof(float), Averaged_Ncol, fuuu);
    fread(&uuu[cim][0], sizeof(float), Averaged_Ncol, fuuu);
    fread(&vvv[cre][0], sizeof(float), Averaged_Ncol, fvvv);
    fread(&vvv[cim][0], sizeof(float), Averaged_Ncol, fvvv);
    fread(&www[cre][0], sizeof(float), Averaged_Ncol, fwww);
    fread(&www[cim][0], sizeof(float), Averaged_Ncol, fwww);
    fread(&zzz[cre][0], sizeof(float), Averaged_Ncol, fzzz);
    fread(&zzz[cim][0], sizeof(float), Averaged_Ncol, fzzz);
    fread(&Cal_mask_rho[0], sizeof(float), Averaged_Ncol, fmask);

    for (col = 0; col < Averaged_Ncol; col++) {
      Cal_mask = 0.0;
      if ( (alpha_abs[lig][col] <= var1+0.5*var2) && (alpha_abs[lig][col] >= var1-0.5*var2) && (Cal_mask_rho[col] == 1.0) ) Cal_mask = 1.0;
      alpha[cre][col] = alpha[cre][col]* Cal_mask; alpha[cim][col] = alpha[cim][col] * Cal_mask;
      if (Cal_mask == 1.0) {
        alpha_rg[cre][col] += alpha[cre][col]; alpha_rg[cim][col] += alpha[cim][col]; indalp++;
        }
      if (Cal_mask_rho[col] == 1.0) {
        uuu_rg[cre][col] += uuu[cre][col]; uuu_rg[cim][col] += uuu[cim][col]; induuu++;
        vvv_rg[cre][col] += vvv[cre][col]; vvv_rg[cim][col] += vvv[cim][col]; indvvv++;
        www_rg[cre][col] += www[cre][col]; www_rg[cim][col] += www[cim][col]; indwww++;
        zzz_rg[cre][col] += zzz[cre][col]; zzz_rg[cim][col] += zzz[cim][col]; indzzz++;
        }
      }
    }
    
  for (col = 0; col < Averaged_Ncol; col++) {
    alpha_rg[cre][col] = alpha_rg[cre][col] / (float) ind;
    alpha_rg[cim][col] = alpha_rg[cim][col] / (float) ind;
    alpha_rg[cab][col] = AmplitudeComplex_v2(alpha_rg[cre][col],alpha_rg[cim][col]);
    alpha_rg[cph][col] = atan2(alpha_rg[cim][col],alpha_rg[cre][col]);
    }
  
  PolyFit_3order(alpha_rg, Averaged_Ncol, alpha_tmp, Sub_Ncol, alpha_tmp2);
  
  for (col = 0; col < Averaged_Ncol; col++) alpha_rg[cab][col] = alpha_tmp[col];
  for (col = 0; col < Sub_Ncol; col++) alpha_cal_final[cab][col] = alpha_tmp2[col];
  
  var1 = 0.0;
  for (col = 0; col < Averaged_Ncol; col++) var1 += alpha_rg[cph][col] / Averaged_Ncol;
  for (col = 0; col < Averaged_Ncol; col++) alpha_rg[cph][col] = var1;
  for (col = 0; col < Sub_Ncol; col++) alpha_cal_final[cph][col] = var1;
  
  for (col = 0; col < Averaged_Ncol; col++) {
    alpha_rg[cre][col] = alpha_rg[cab][col] * cos(alpha_rg[cph][col]);
    alpha_rg[cim][col] = alpha_rg[cab][col] * sin(alpha_rg[cph][col]);
    }
  for (col = 0; col < Sub_Ncol; col++) {
    alpha_cal_final[cre][col]  = alpha_cal_final[cab][col] * cos(alpha_cal_final[cph][col]);
    alpha_cal_final[cim][col]  = alpha_cal_final[cab][col] * sin(alpha_cal_final[cph][col]);
    alpha_cal_final[cre+2][col]  = (1.0 / alpha_cal_final[cab][col]) * cos(-1.0 * alpha_cal_final[cph][col]); /* Inverse of alpha real part*/
    alpha_cal_final[cim+2][col]  = (1.0 / alpha_cal_final[cab][col]) * sin(-1.0 * alpha_cal_final[cph][col]); /* Inverse of alpha imag part*/
    }
  
  /* Generation of uuu, vvv, www, zzz in range */
  for (col = 0; col < Averaged_Ncol; col++) {
    uuu_rg[cre][col] = uuu_rg[cre][col] / (float) induuu;
    uuu_rg[cim][col] = uuu_rg[cim][col] / (float) induuu;
    vvv_rg[cre][col] = vvv_rg[cre][col] / (float) indvvv;
    vvv_rg[cim][col] = vvv_rg[cim][col] / (float) indvvv;
    www_rg[cre][col] = www_rg[cre][col] / (float) indwww;
    www_rg[cim][col] = www_rg[cim][col] / (float) indwww;
    zzz_rg[cre][col] = zzz_rg[cre][col] / (float) indzzz;
    zzz_rg[cim][col] = zzz_rg[cim][col] / (float) indzzz;
    }
  
  var1 = 0.0; var2 = 0.0;
  for (col = 0; col < Averaged_Ncol; col++) {
    var1 += uuu_rg[cre][col] / Averaged_Ncol;
    var2 += uuu_rg[cim][col] / Averaged_Ncol;
    }
  for (col = 0; col < Sub_Ncol; col++) {
    uuu_cal_final[cre][col] = var1;
    uuu_cal_final[cim][col] = var2;
    }
  
  var1 = 0.0; var2 = 0.0;
  for (col = 0; col < Averaged_Ncol; col++) {
    var1 += vvv_rg[cre][col] / Averaged_Ncol;
    var2 += vvv_rg[cim][col] / Averaged_Ncol;
    }
  for (col = 0; col < Sub_Ncol; col++) {
    vvv_cal_final[cre][col] = var1;
    vvv_cal_final[cim][col] = var2;
    }
  
  var1 = 0.0; var2 = 0.0;
  for (col = 0; col < Averaged_Ncol; col++) {
    var1 += www_rg[cre][col] / Averaged_Ncol;
    var2 += www_rg[cim][col] / Averaged_Ncol;
    }
  for (col = 0; col < Sub_Ncol; col++) {
    www_cal_final[cre][col] = var1;
    www_cal_final[cim][col] = var2;
    }
 
  var1 = 0.0; var2 = 0.0;
  for (col = 0; col < Averaged_Ncol; col++) {
    var1 += zzz_rg[cre][col] / Averaged_Ncol;
    var2 += zzz_rg[cim][col] / Averaged_Ncol;
    }
  for (col = 0; col < Sub_Ncol; col++) {
    zzz_cal_final[cre][col] = var1;
    zzz_cal_final[cim][col] = var2;
    }
  
  /*********************/
  /* Final Calibration */
  /*********************/
      
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
for (lig = 0; lig <Sub_Nlig; lig++) {
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
    
    /* Generates the calibration matrix */
    cal_matrix[cre][0][0] = alpha_cal_final[cre+2][col];
    cal_matrix[cim][0][0] = alpha_cal_final[cim+2][col];
    
    ComplexProduct2(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],uuu_cal_final[cre][col],uuu_cal_final[cim][col],&cal_matrix[cre][0][1],&cal_matrix[cim][0][1]);
    cal_matrix[cre][0][1] =  -1.0 * cal_matrix[cre][0][1];
    cal_matrix[cim][0][1] =  -1.0 * cal_matrix[cim][0][1];
    
    ComplexProduct3(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],zzz_cal_final[cre][col],zzz_cal_final[cim][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][0][2],&cal_matrix[cim][0][2]);
    cal_matrix[cre][0][2] = -1.0 * cal_matrix[cre][0][2];
    cal_matrix[cim][0][2] = -1.0 * cal_matrix[cim][0][2];
    
    ComplexProduct4(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],zzz_cal_final[cre][col],zzz_cal_final[cim][col],uuu_cal_final[cre][col],uuu_cal_final[cim][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][0][3],&cal_matrix[cim][0][3]);
    
    ComplexProduct2(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],www_cal_final[cre][col],www_cal_final[cim][col],&cal_matrix[cre][1][0],&cal_matrix[cim][1][0]);
    cal_matrix[cre][1][0] =  -1.0 * cal_matrix[cre][1][0];
    cal_matrix[cim][1][0] =  -1.0 * cal_matrix[cim][1][0];
    
    cal_matrix[cre][1][1] = alpha_cal_final[cre+2][col];
    cal_matrix[cim][1][1] = alpha_cal_final[cim+2][col];
    
    ComplexProduct4(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],zzz_cal_final[cre][col],zzz_cal_final[cim][col],www_cal_final[cre][col],www_cal_final[cim][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][1][2],&cal_matrix[cim][1][2]);
    
    ComplexProduct3(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],zzz_cal_final[cre][col],zzz_cal_final[cim][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][1][3],&cal_matrix[cim][1][3]);
    cal_matrix[cre][1][3] = -1.0 * cal_matrix[cre][1][3];
    cal_matrix[cim][1][3] = -1.0 * cal_matrix[cim][1][3];
    
    ComplexProduct2(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],vvv_cal_final[cre][col],vvv_cal_final[cim][col],&cal_matrix[cre][2][0],&cal_matrix[cim][2][0]);
    cal_matrix[cre][2][0] =  -1.0 * cal_matrix[cre][2][0];
    cal_matrix[cim][2][0] =  -1.0 * cal_matrix[cim][2][0];
  
    ComplexProduct3(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],uuu_cal_final[cre][col],uuu_cal_final[cim][col],vvv_cal_final[cre][col],vvv_cal_final[cim][col],&cal_matrix[cre][2][1],&cal_matrix[cim][2][1]);
  
    ComplexProduct2(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][2][2],&cal_matrix[cim][2][2]);
    
    ComplexProduct3(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],uuu_cal_final[cre][col],uuu_cal_final[cim][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][2][3],&cal_matrix[cim][2][3]);
    cal_matrix[cre][2][3] = -1.0 * cal_matrix[cre][2][3];
    cal_matrix[cim][2][3] = -1.0 * cal_matrix[cim][2][3];
    
    ComplexProduct3(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],vvv_cal_final[cre][col],vvv_cal_final[cim][col],www_cal_final[cre][col],www_cal_final[cim][col],&cal_matrix[cre][3][0],&cal_matrix[cim][3][0]);
    
    ComplexProduct2(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],vvv_cal_final[cre][col],vvv_cal_final[cim][col],&cal_matrix[cre][3][1],&cal_matrix[cim][3][1]);
    cal_matrix[cre][3][1] =  -1.0 * cal_matrix[cre][3][1];
    cal_matrix[cim][3][1] =  -1.0 * cal_matrix[cim][3][1];
    
    ComplexProduct3(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],www_cal_final[cre][col],www_cal_final[cim][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][3][2],&cal_matrix[cim][3][2]);
    cal_matrix[cre][3][2] = -1.0 * cal_matrix[cre][3][2];
    cal_matrix[cim][3][2] = -1.0 * cal_matrix[cim][3][2];

    ComplexProduct2(alpha_cal_final[cre+2][col],alpha_cal_final[cim+2][col],alpha_cal_final[cre][col],alpha_cal_final[cim][col],&cal_matrix[cre][3][3],&cal_matrix[cim][3][3]);
    
    ind = 2 * (col + Off_col);
    
    /* Calibration of hh */
    S_tmp_block[hh][1][2*col]    = 0.;
    S_tmp_block[hh][1][2*col + 1]  = 0.;
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][0][0]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][0][0]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][0][0]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][0][0]);
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][1][0]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][1][0]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][1][0]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][1][0]);
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][2][0]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][2][0]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][2][0]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][2][0]);
    S_tmp_block[hh][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][3][0]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][3][0]);
    S_tmp_block[hh][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][3][0]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][3][0]);
    
    /* Calibration of vh */
    S_tmp_block[vh][1][2*col]    = 0.;
    S_tmp_block[vh][1][2*col + 1]  = 0.;
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][0][1]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][0][1]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][0][1]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][0][1]);
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][1][1]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][1][1]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][1][1]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][1][1]);
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][2][1]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][2][1]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][2][1]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][2][1]);
    S_tmp_block[vh][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][3][1]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][3][1]);
    S_tmp_block[vh][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][3][1]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][3][1]);
    
    /* Calibration of hv */
    S_tmp_block[hv][1][2*col]    = 0.;
    S_tmp_block[hv][1][2*col + 1]  = 0.;
    S_tmp_block[hv][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][0][2]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][0][2]);
    S_tmp_block[hv][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][0][2]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][0][2]);
    S_tmp_block[hv][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][1][2]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][1][2]);
    S_tmp_block[hv][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][1][2]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][1][2]);
    S_tmp_block[hv][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][2][2]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][2][2]);
    S_tmp_block[hv][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][2][2]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][2][2]);
    S_tmp_block[hv][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][3][2]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][3][2]);
    S_tmp_block[hv][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][3][2]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][3][2]);
    
    /* Calibration of VV */
    S_tmp_block[vv][1][2*col]    = 0.;
    S_tmp_block[vv][1][2*col + 1]  = 0.;
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[hh][0][2*col] * cal_matrix[cre][0][3]) - (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cim][0][3]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[hh][0][2*col] * cal_matrix[cim][0][3]) + (S_tmp_block[hh][0][2*col + 1] * cal_matrix[cre][0][3]);
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[vh][0][2*col] * cal_matrix[cre][1][3]) - (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cim][1][3]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[vh][0][2*col] * cal_matrix[cim][1][3]) + (S_tmp_block[vh][0][2*col + 1] * cal_matrix[cre][1][3]);
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[hv][0][2*col] * cal_matrix[cre][2][3]) - (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cim][2][3]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[hv][0][2*col] * cal_matrix[cim][2][3]) + (S_tmp_block[hv][0][2*col + 1] * cal_matrix[cre][2][3]);
    S_tmp_block[vv][1][2*col]   += (S_tmp_block[vv][0][2*col] * cal_matrix[cre][3][3]) - (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cim][3][3]);
    S_tmp_block[vv][1][2*col + 1] += (S_tmp_block[vv][0][2*col] * cal_matrix[cim][3][3]) + (S_tmp_block[vv][0][2*col + 1] * cal_matrix[cre][3][3]);
    
    /* Symmetrization of the cross-polar channels */
    S_tmp_block[vh][1][2*col] = ( S_tmp_block[vh][1][2*col] + S_tmp_block[hv][1][2*col] ) / 2.0;
    S_tmp_block[vh][1][2*col + 1] = ( S_tmp_block[vh][1][2*col + 1] + S_tmp_block[hv][1][2*col + 1] ) / 2.0;
    S_tmp_block[hv][1][2*col] = S_tmp_block[vh][1][2*col];
    S_tmp_block[hv][1][2*col + 1] = S_tmp_block[vh][1][2*col + 1];
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
  for (np = 0; np < Npolar_S; np++) fclose(out_fileS2[np]);
  fclose(falpha);
  fclose(fuuu);
  fclose(fvvv);
  fclose(fwww);
  fclose(fzzz);
  fclose(fmask);
   
  /* Memory Libertation */
  free_matrix_float(alpha,2);
  free_matrix_float(alpha_abs,Averaged_Nlig);
  free_vector_float(alpha_tmp);
  free_vector_float(alpha_tmp2);
  free_matrix_float(alpha_rg,4);
  free_matrix_float(alpha_cal_final,4);
  
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
  
  free_vector_float(pol_coef);
  
  free_matrix_float(M_tmp_ligne,Npolar_S);
  free_matrix3d_float(S_tmp_block,Npolar_S,Box_lig);
  free_matrix_float(C_ligne,Npolar_C_full);
  
  free_vector_float(Cal_mask_rho);  //CHANGE

  free_matrix3d_float(cal_matrix,2,4);
    
  return 1;
}


/*******************************************************************************
Routine  : AmplitudeComplex_v2
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Calculates the amplitude of a complex number
*-------------------------------------------------------------------------------
Inputs arguments :
Re    : Input Real part
Im  : Input Imaginary part
Returned values  :
  : Amplitude
*******************************************************************************/
float AmplitudeComplex_v2(float Re, float Im)
{
  return(sqrt( (Re * Re) + (Im * Im) ) );
}

/*******************************************************************************
Routine  : PolyFit_3order
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Aproximates complex data with a polynomial of third order
*-------------------------------------------------------------------------------
Inputs arguments :
data_range  : Input complex data. 1st row is real the part. 2nd row is the 
    imaginary part. 3rd row is the amplitude. 4th row is the phase.  
Ncol   : Length of data-range
Returned values :
fit_pol    : Aproximated data 
Ncol_final  : Length of data without subsampling to calculate the covariance
      matrix
data_range_final: Aproximated data with interpolation for the final image
*******************************************************************************/
void PolyFit_3order(float **data_range, int Ncol, float *fit_pol, int Ncol_final, float *data_range_final) {
  
  int col;
  double col2;
  double *x_coeff, *y_coeff, *coeff;
  double **X, **PX;
  double ***X2, ***IX2;
    
  coeff   = vector_double(4);
  x_coeff  = vector_double(7);
  y_coeff  = vector_double(4);
  X     = matrix_double(4,4);
  PX    = matrix_double(4,4);
  X2    = matrix3d_double(4,4,2);
  IX2    = matrix3d_double(4,4,2);
  
  for (col = 0; col < Ncol; col++) {
  col2 = (double) col / (double) Ncol;
  x_coeff[0] += 1;
  x_coeff[1] += col2;
  x_coeff[2] += col2 * col2;
  x_coeff[3] += col2 * col2 * col2;
  x_coeff[4] += col2 * col2 * col2 * col2;
  x_coeff[5] += col2 * col2 * col2 * col2 * col2;
  x_coeff[6] += col2 * col2 * col2 * col2 * col2 * col2;
  y_coeff[0] += (double) data_range[cab][col];
  y_coeff[1] += col2 * (double) data_range[cab][col];
  y_coeff[2] += col2 * col2 * (double) data_range[cab][col];
  y_coeff[3] += col2 * col2 * col2 * (double) data_range[cab][col];
  }
  
  /* Matrix X */
  X[0][0] = x_coeff[0];
  X[0][1] = x_coeff[1];
  X[0][2] = x_coeff[2];
  X[0][3] = x_coeff[3];
  X[1][0] = x_coeff[1];
  X[1][1] = x_coeff[2];
  X[1][2] = x_coeff[3];
  X[1][3] = x_coeff[4];
  X[2][0] = x_coeff[2];
  X[2][1] = x_coeff[3];
  X[2][2] = x_coeff[4];
  X[2][3] = x_coeff[5];
  X[3][0] = x_coeff[3];
  X[3][1] = x_coeff[4];
  X[3][2] = x_coeff[5];
  X[3][3] = x_coeff[6];
  
  /* Matrix X'*X */ 
  X2[0][0][cre] = X[0][0] * X[0][0] + X[0][1] * X[1][0] + X[0][2] * X[2][0] + X[0][3] * X[3][0];
  X2[0][1][cre] = X[0][0] * X[0][1] + X[0][1] * X[1][1] + X[0][2] * X[2][1] + X[0][3] * X[3][1];
  X2[0][2][cre] = X[0][0] * X[0][2] + X[0][1] * X[1][2] + X[0][2] * X[2][2] + X[0][3] * X[3][2];
  X2[0][3][cre] = X[0][0] * X[0][3] + X[0][1] * X[1][3] + X[0][2] * X[2][3] + X[0][3] * X[3][3];
  X2[1][0][cre] = X[1][0] * X[0][0] + X[1][1] * X[1][0] + X[1][2] * X[2][0] + X[1][3] * X[3][0];
  X2[1][1][cre] = X[1][0] * X[0][1] + X[1][1] * X[1][1] + X[1][2] * X[2][1] + X[1][3] * X[3][1];
  X2[1][2][cre] = X[1][0] * X[0][2] + X[1][1] * X[1][2] + X[1][2] * X[2][2] + X[1][3] * X[3][2];
  X2[1][3][cre] = X[1][0] * X[0][3] + X[1][1] * X[1][3] + X[1][2] * X[2][3] + X[1][3] * X[3][3];
  X2[2][0][cre] = X[2][0] * X[0][0] + X[2][1] * X[1][0] + X[2][2] * X[2][0] + X[2][3] * X[3][0];
  X2[2][1][cre] = X[2][0] * X[0][1] + X[2][1] * X[1][1] + X[2][2] * X[2][1] + X[2][3] * X[3][1];
  X2[2][2][cre] = X[2][0] * X[0][2] + X[2][1] * X[1][2] + X[2][2] * X[2][2] + X[2][3] * X[3][2];
  X2[2][3][cre] = X[2][0] * X[0][3] + X[2][1] * X[1][3] + X[2][2] * X[2][3] + X[2][3] * X[3][3];
  X2[3][0][cre] = X[3][0] * X[0][0] + X[3][1] * X[1][0] + X[3][2] * X[2][0] + X[3][3] * X[3][0];
  X2[3][1][cre] = X[3][0] * X[0][1] + X[3][1] * X[1][1] + X[3][2] * X[2][1] + X[3][3] * X[3][1];
  X2[3][2][cre] = X[3][0] * X[0][2] + X[3][1] * X[1][2] + X[3][2] * X[2][2] + X[3][3] * X[3][2];
  X2[3][3][cre] = X[3][0] * X[0][3] + X[3][1] * X[1][3] + X[3][2] * X[2][3] + X[3][3] * X[3][3];
  
  InverseHermitianMatrix4Double(X2,IX2); 
  
  /* Product X2^-1*X */
  PX[0][0] = IX2[0][0][0] * X[0][0] + IX2[0][1][0] * X[1][0] + IX2[0][2][0] * X[2][0] + IX2[0][3][0] * X[3][0];
  PX[0][1] = IX2[0][0][0] * X[0][1] + IX2[0][1][0] * X[1][1] + IX2[0][2][0] * X[2][1] + IX2[0][3][0] * X[3][1];
  PX[0][2] = IX2[0][0][0] * X[0][2] + IX2[0][1][0] * X[1][2] + IX2[0][2][0] * X[2][2] + IX2[0][3][0] * X[3][2];
  PX[0][3] = IX2[0][0][0] * X[0][3] + IX2[0][1][0] * X[1][3] + IX2[0][2][0] * X[2][3] + IX2[0][3][0] * X[3][3];
  PX[1][0] = IX2[1][0][0] * X[0][0] + IX2[1][1][0] * X[1][0] + IX2[1][2][0] * X[2][0] + IX2[1][3][0] * X[3][0];
  PX[1][1] = IX2[1][0][0] * X[0][1] + IX2[1][1][0] * X[1][1] + IX2[1][2][0] * X[2][1] + IX2[1][3][0] * X[3][1];
  PX[1][2] = IX2[1][0][0] * X[0][2] + IX2[1][1][0] * X[1][2] + IX2[1][2][0] * X[2][2] + IX2[1][3][0] * X[3][2];
  PX[1][3] = IX2[1][0][0] * X[0][3] + IX2[1][1][0] * X[1][3] + IX2[1][2][0] * X[2][3] + IX2[1][3][0] * X[3][3];
  PX[2][0] = IX2[2][0][0] * X[0][0] + IX2[2][1][0] * X[1][0] + IX2[2][2][0] * X[2][0] + IX2[2][3][0] * X[3][0];
  PX[2][1] = IX2[2][0][0] * X[0][1] + IX2[2][1][0] * X[1][1] + IX2[2][2][0] * X[2][1] + IX2[2][3][0] * X[3][1];
  PX[2][2] = IX2[2][0][0] * X[0][2] + IX2[2][1][0] * X[1][2] + IX2[2][2][0] * X[2][2] + IX2[2][3][0] * X[3][2];
  PX[2][3] = IX2[2][0][0] * X[0][3] + IX2[2][1][0] * X[1][3] + IX2[2][2][0] * X[2][3] + IX2[2][3][0] * X[3][3];
  PX[3][0] = IX2[3][0][0] * X[0][0] + IX2[3][1][0] * X[1][0] + IX2[3][2][0] * X[2][0] + IX2[3][3][0] * X[3][0];
  PX[3][1] = IX2[3][0][0] * X[0][1] + IX2[3][1][0] * X[1][1] + IX2[3][2][0] * X[2][1] + IX2[3][3][0] * X[3][1];
  PX[3][2] = IX2[3][0][0] * X[0][2] + IX2[3][1][0] * X[1][2] + IX2[3][2][0] * X[2][2] + IX2[3][3][0] * X[3][2];
  PX[3][3] = IX2[3][0][0] * X[0][3] + IX2[3][1][0] * X[1][3] + IX2[3][2][0] * X[2][3] + IX2[3][3][0] * X[3][3];

  /* Coefficients */
  coeff[0] = PX[0][0] * y_coeff[0] + PX[0][1] * y_coeff[1] + PX[0][2] * y_coeff[2] + PX[0][3] * y_coeff[3];
  coeff[1] = PX[1][0] * y_coeff[0] + PX[1][1] * y_coeff[1] + PX[1][2] * y_coeff[2] + PX[1][3] * y_coeff[3];
  coeff[2] = PX[2][0] * y_coeff[0] + PX[2][1] * y_coeff[1] + PX[2][2] * y_coeff[2] + PX[2][3] * y_coeff[3];
  coeff[3] = PX[3][0] * y_coeff[0] + PX[3][1] * y_coeff[1] + PX[3][2] * y_coeff[2] + PX[3][3] * y_coeff[3];
  
  //printf("Coeff: %2.5f %2.5f %2.5f %2.5f",coeff[0],coeff[1],coeff[2],coeff[3]);
  
  /* Evaluation of the signal */
  for (col = 0; col < Ncol; col++) {
  col2 = (double) col / (double) Ncol;
  fit_pol[col] =  (float) (0.0);
  fit_pol[col] += (float) (coeff[0]);
  fit_pol[col] += (float) (coeff[1] * (col2));
  fit_pol[col] += (float) (coeff[2] * (col2 * col2));
  fit_pol[col] += (float) (coeff[3] * (col2 * col2 * col2));
  }
  
  /* Evaluation of the signal with the interpolation*/
  for (col = 0; col < Ncol_final; col++) {
  col2 = (double) col / (double) Ncol_final;
  data_range_final[col] =  (float) (0.0);
  data_range_final[col] += (float) (coeff[0]);
  data_range_final[col] += (float) (coeff[1] * (col2));
  data_range_final[col] += (float) (coeff[2] * (col2 * col2));
  data_range_final[col] += (float) (coeff[3] * (col2 * col2 * col2));
  }  
}

/*******************************************************************************
Routine  : ComplexProduct2
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Product of two complex numbers
*-------------------------------------------------------------------------------
Inputs arguments :
Re1    : Input 1 Real part
Im1  : Input 1 Imaginary part
Re2    : Input 2 Real part
Im2  : Input 2 Imaginary part
Returned values  :
ReP   : Result Real part
ImP  : Result Imaginary part
*******************************************************************************/
void ComplexProduct2(float Re1, float Im1, float Re2, float Im2, float *ReP, float *ImP)
{
  *ReP = (Re1 * Re2) - (Im1 * Im2);
  *ImP = (Re1 * Im2) + (Im1 * Re2);
}

/*******************************************************************************
Routine  : ComplexProduct3
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Product of three complex numbers
*-------------------------------------------------------------------------------
Inputs arguments :
Re1    : Input 1 Real part
Im1  : Input 1 Imaginary part
Re2    : Input 2 Real part
Im2  : Input 2 Imaginary part
Re3    : Input 3 Real part
Im3  : Input 3 Imaginary part
Returned values  :
ReP   : Result Real part
ImP  : Result Imaginary part
*******************************************************************************/
void ComplexProduct3(float Re1, float Im1, float Re2, float Im2, float Re3, float Im3, float *ReP, float *ImP)
{
  float re1_tmp, im1_tmp,re2_tmp,im2_tmp;
  ComplexProduct2(Re1,Im1,Re2,Im2,&re1_tmp,&im1_tmp);
  ComplexProduct2(re1_tmp,im1_tmp,Re3,Im3,&re2_tmp,&im2_tmp);
  *ReP = re2_tmp;
  *ImP = im2_tmp;
}

/*******************************************************************************
Routine  : ComplexProduct3
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Product of three complex numbers
*-------------------------------------------------------------------------------
Inputs arguments :
Re1    : Input 1 Real part
Im1  : Input 1 Imaginary part
Re2    : Input 2 Real part
Im2  : Input 2 Imaginary part
Re3    : Input 3 Real part
Im3  : Input 3 Imaginary part
Re4    : Input 4 Real part
Im4  : Input 4 Imaginary part
Returned values  :
ReP   : Result Real part
ImP  : Result Imaginary part
*******************************************************************************/
void ComplexProduct4(float Re1, float Im1, float Re2, float Im2, float Re3, float Im3, float Re4, float Im4, float *ReP, float *ImP)
{
  float re1_tmp, im1_tmp, re2_tmp, im2_tmp,re3_tmp, im3_tmp;
  ComplexProduct2(Re1,Im1,Re2,Im2,&re1_tmp,&im1_tmp);
  ComplexProduct2(re1_tmp,im1_tmp,Re3,Im3,&re2_tmp,&im2_tmp);
  ComplexProduct2(re2_tmp,im2_tmp,Re4,Im4,&re3_tmp,&im3_tmp);
  *ReP = re3_tmp;
  *ImP = im3_tmp;
}

/*******************************************************************************
Routine  : vector_double
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of double elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of double
Returned values  :
m   : vector pointer (double *)
*******************************************************************************/
double *vector_double(int nrh)
{
  int ii;
  double *m;

  m = (double *) malloc((unsigned) (nrh + 1) * sizeof(double));
  if (!m)
  edit_error("allocation failure 1 in vector_double()", "");

  for (ii = 0; ii < nrh; ii++)
  m[ii] = 0;
  return m;
}

/*******************************************************************************
Routine  : free_vector_double
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a vector and disallocates memory for a vector
of double elements
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
void free_vector_double(double *m)
{
  free((double *) m);
}


/*******************************************************************************
Routine  : mean_value_re
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Mean value
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
float mean_value_re(float **Data,int Nlin, int Ncol)
{
  int mm, nn;
  float m_value;
  
  m_value = 0.0;
  
  for (mm = 0; mm < Nlin; mm++)
  for (nn = 0; nn < Ncol; nn++)
    m_value += Data[mm][nn];
    
  m_value = m_value / (Nlin * Ncol);
  
  return(m_value);
}

/*******************************************************************************
Routine  : matrix_double
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of double elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
nch  : number of rows
Returned values  :
m   : matrix pointer (double **)
*******************************************************************************/
double **matrix_double(int nrh, int nch)
{
  int i, j;
  double **m;

  m = (double **) malloc((unsigned) (nrh) * sizeof(double *));
  if (!m)
  edit_error("allocation failure 1 in matrix()", "");

  for (i = 0; i < nrh; i++) {
  m[i] = (double *) malloc((unsigned) (nch) * sizeof(double));
  if (!m[i])
    edit_error("allocation failure 2 in matrix()", "");
  }
  for (i = 0; i < nrh; i++)
  for (j = 0; j < nch; j++)
    m[i][j] = (double) 0.;
  return m;
}

/*******************************************************************************
Routine  : free_matrix_double
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of double elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
Returned values  :
void
*******************************************************************************/
void free_matrix_double(double **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--)
  free((double *) (m[i]));
}

/*******************************************************************************
Routine  : matrix3d_double
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 3D matrix of double elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
nch  : number of elements 3rd dimension
Returned values  :
m   : 3D matrix pointer (double ***)
*******************************************************************************/
double ***matrix3d_double(int nz, int nrh, int nch)
{
  int ii, jj, dd;
  double ***m;


  m = (double ***) malloc((unsigned) (nz + 1) * sizeof(double **));
  if (m == NULL)
  edit_error("D'ALLOCATION No.1 DANS MATRIX()", "");
  for (jj = 0; jj < nz; jj++) {
  m[jj] = (double **) malloc((unsigned) (nrh + 1) * sizeof(double *));
  if (m[jj] == NULL)
    edit_error("D'ALLOCATION No.2 DANS MATRIX()", "");
  for (ii = 0; ii < nrh; ii++) {
    m[jj][ii] =
  (double *) malloc((unsigned) (nch + 1) * sizeof(double));
    if (m[jj][ii] == NULL)
  edit_error("D'ALLOCATION No.3 DANS MATRIX()", "");
  }
  }
  for (dd = 0; dd < nz; dd++)
  for (jj = 0; jj < nrh; jj++)
    for (ii = 0; ii < nch; ii++)
  m[dd][jj][ii] = (double) (0.);
  return m;
}

/*******************************************************************************
Routine  : free_matrix3d_double
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 3D matrix of double elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
Returned values  :
void
*******************************************************************************/
void free_matrix3d_double(double ***m, int nz, int nrh)
{
  int ii, jj;

  for (jj = nz - 1; jj >= 0; jj--)
  for (ii = nrh - 1; ii >= 0; ii--)
    free((double *) (m[jj][ii]));
  free((double *) (m));
}

/*******************************************************************************
Routine  : std_value_re
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Mean value
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
float std_value_re(float **Data, int Nlin, int Ncol)
{
  int mm, nn;
  float m_value,s_value;
  
  m_value = 0.0;
  s_value = 0.0;
  
  for (mm = 0; mm < Nlin; mm++)
  for (nn = 0; nn < Ncol; nn++)
    m_value += Data[mm][nn];
  
    m_value = m_value / (Nlin * Ncol);
  
  for (mm = 0; mm < Nlin; mm++)
  for (nn = 0; nn < Ncol; nn++)
    s_value += (Data[mm][nn] - m_value)*(Data[mm][nn] - m_value);
  
  s_value = sqrt( s_value / ( (Nlin * Ncol) - 1) );
  
  return(s_value);
}

/*******************************************************************************
Routine  : InverseCmplxMatrix2Double
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2007
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Inverse of a 2x2 Complex Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
M      : 2*2*2 Complex Matrix
Returned values  :
IM      : 2*2*2 Inverse Complex Matrix
*******************************************************************************/
void InverseCmplxMatrix2Double(double ***M, double ***IM)
{
  double re,im,det[2];
  int k, l;

  IM[0][0][0] = M[1][1][0];
  IM[0][0][1] = M[1][1][1];

  IM[0][1][0] = -M[0][1][0];
  IM[0][1][1] = -M[0][1][1];

  IM[1][0][0] = -M[1][0][0];
  IM[1][0][1] = -M[1][0][1];

  IM[1][1][0] = M[0][0][0];
  IM[1][1][1] = M[0][0][1];


  det[0] = M[0][0][0] * M[1][1][0] - M[0][0][1] * M[1][1][1];
  det[0] = det[0] - (M[0][1][0] * M[1][0][0] - M[0][1][1] * M[1][0][1]) + eps;

  det[1] = M[0][0][0] * M[1][1][1] + M[0][0][1] * M[1][1][0];
  det[1] = det[1] - (M[0][1][0] * M[1][0][1] + M[0][1][1] * M[1][0][0]) + eps;

  for (k = 0; k < 2; k++) {
  for (l = 0; l < 2; l++) {
    re = IM[k][l][0];
    im = IM[k][l][1];
    IM[k][l][0] = (re * det[0] + im * det[1]) / (det[0] * det[0] + det[1] * det[1]);
    IM[k][l][1] = (im * det[0] - re * det[1]) / (det[0] * det[0] + det[1] * det[1]);
  }
  }
}

/*******************************************************************************
Routine  : ProductCmplxMatrixDouble
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2007
Update  :
*-------------------------------------------------------------------------------
Description :  computes the product of 2 NxN Complex Matrices
*-------------------------------------------------------------------------------
Inputs arguments :
M1      : N*N*2 Cmplx Matrix n°1
M2      : N*N*2 Cmplx Matrix n°2
Returned values  :
M3      : N*N*2 Cmplx Matrix n°3 = M1xM2
*******************************************************************************/
void ProductCmplxMatrixDouble(double ***M1, double ***M2, double ***M3, int N)
{
  int i,j,k;

  for (i = 0; i < N; i++) {
  for (j = 0; j < N; j++) {
    M3[i][j][0] = 0.; M3[i][j][1] = 0.;
    for (k = 0; k < N; k++) {
    M3[i][j][0] += M1[i][k][0] * M2[k][j][0] - M1[i][k][1] * M2[k][j][1];
    M3[i][j][1] += M1[i][k][0] * M2[k][j][1] + M1[i][k][1] * M2[k][j][0];
    }
  }
  }
}

/*******************************************************************************
Routine  : InverseHermitianMatrix4Double
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Inverse of a 4x4 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 4*4*2 Hermitian Matrix
Returned values  :
IHM     : 4*4*2 Inverse Hermitian Matrix
*******************************************************************************/
void InverseHermitianMatrix4Double(double ***HM, double ***IHM)
{
  double ***A;
  double ***B;
  double ***C;
  double ***D;
  double ***Q;
  double ***Am1;
  double ***Dm1;
  double ***Qm1;
  double ***Tmp1;
  double ***Tmp2;
  int i,j,k;
  double *det, determinant;

  det = vector_double(2);
  DeterminantHermitianMatrix4Double(HM, det);
  determinant = sqrt(det[0]*det[0]+det[1]*det[1]);
  
  if (determinant < 1.E-10) {
  PseudoInverseHermitianMatrix4Double(HM,IHM);
  } else {

  A = matrix3d_double(2, 2, 2);
  B = matrix3d_double(2, 2, 2);
  C = matrix3d_double(2, 2, 2);
  D = matrix3d_double(2, 2, 2);
  Am1 = matrix3d_double(2, 2, 2);
  Dm1 = matrix3d_double(2, 2, 2);
  Q = matrix3d_double(2, 2, 2);
  Qm1 = matrix3d_double(2, 2, 2);
  Tmp1 = matrix3d_double(2, 2, 2);
  Tmp2 = matrix3d_double(2, 2, 2);

  A[0][0][0] = HM[0][0][0];
  A[0][0][1] = HM[0][0][1];
  A[0][1][0] = HM[0][1][0];
  A[0][1][1] = HM[0][1][1];
  A[1][0][0] = HM[1][0][0];
  A[1][0][1] = HM[1][0][1];
  A[1][1][0] = HM[1][1][0];
  A[1][1][1] = HM[1][1][1];
  B[0][0][0] = HM[0][2][0];
  B[0][0][1] = HM[0][2][1];
  B[0][1][0] = HM[0][3][0];
  B[0][1][1] = HM[0][3][1];
  B[1][0][0] = HM[1][2][0];
  B[1][0][1] = HM[1][2][1];
  B[1][1][0] = HM[1][3][0];
  B[1][1][1] = HM[1][3][1];
  C[0][0][0] = HM[2][0][0];
  C[0][0][1] = HM[2][0][1];
  C[0][1][0] = HM[2][1][0];
  C[0][1][1] = HM[2][1][1];
  C[1][0][0] = HM[3][0][0];
  C[1][0][1] = HM[3][0][1];
  C[1][1][0] = HM[3][1][0];
  C[1][1][1] = HM[3][1][1];
  D[0][0][0] = HM[2][2][0];
  D[0][0][1] = HM[2][2][1];
  D[0][1][0] = HM[2][3][0];
  D[0][1][1] = HM[2][3][1];
  D[1][0][0] = HM[3][2][0];
  D[1][0][1] = HM[3][2][1];
  D[1][1][0] = HM[3][3][0];
  D[1][1][1] = HM[3][3][1];

  InverseCmplxMatrix2Double(A,Am1);
  InverseCmplxMatrix2Double(D,Dm1);

  ProductCmplxMatrixDouble(B,Dm1,Tmp1,2);
  ProductCmplxMatrixDouble(Tmp1,C,Tmp2,2);

  for (i = 0; i < 2; i++)
    for (j = 0; j < 2; j++)
      for (k = 0; k < 2; k++)
        Q[i][j][k] = A[i][j][k] - Tmp2[i][j][k];

  InverseCmplxMatrix2Double(Q,Qm1);

  IHM[0][0][0] = Qm1[0][0][0];
  IHM[0][0][1] = Qm1[0][0][1];
  IHM[0][1][0] = Qm1[0][1][0];
  IHM[0][1][1] = Qm1[0][1][1];
  IHM[1][0][0] = Qm1[1][0][0];
  IHM[1][0][1] = Qm1[1][0][1];
  IHM[1][1][0] = Qm1[1][1][0];
  IHM[1][1][1] = Qm1[1][1][1];

  ProductCmplxMatrixDouble(Qm1,B,Tmp1,2);
  ProductCmplxMatrixDouble(Tmp1,Dm1,Tmp2,2);
  IHM[0][2][0] = -Tmp2[0][0][0];
  IHM[0][2][1] = -Tmp2[0][0][1];
  IHM[0][3][0] = -Tmp2[0][1][0];
  IHM[0][3][1] = -Tmp2[0][1][1];
  IHM[1][2][0] = -Tmp2[1][0][0];
  IHM[1][2][1] = -Tmp2[1][0][1];
  IHM[1][3][0] = -Tmp2[1][1][0];
  IHM[1][3][1] = -Tmp2[1][1][1];

  ProductCmplxMatrixDouble(C,Tmp2,Tmp1,2);
  Tmp1[0][0][0] = Tmp1[0][0][0] + 1.;
  Tmp1[1][1][0] = Tmp1[1][1][0] + 1.;
  ProductCmplxMatrixDouble(Dm1,Tmp1,Tmp2,2);

  IHM[2][2][0] = Tmp2[0][0][0];
  IHM[2][2][1] = Tmp2[0][0][1];
  IHM[2][3][0] = Tmp2[0][1][0];
  IHM[2][3][1] = Tmp2[0][1][1];
  IHM[3][2][0] = Tmp2[1][0][0];
  IHM[3][2][1] = Tmp2[1][0][1];
  IHM[3][3][0] = Tmp2[1][1][0];
  IHM[3][3][1] = Tmp2[1][1][1];

  ProductCmplxMatrixDouble(Dm1,C,Tmp1,2);
  ProductCmplxMatrixDouble(Tmp1,Qm1,Tmp2,2);

  IHM[2][0][0] = -Tmp2[0][0][0];
  IHM[2][0][1] = -Tmp2[0][0][1];
  IHM[2][1][0] = -Tmp2[0][1][0];
  IHM[2][1][1] = -Tmp2[0][1][1];
  IHM[3][0][0] = -Tmp2[1][0][0];
  IHM[3][0][1] = -Tmp2[1][0][1];
  IHM[3][1][0] = -Tmp2[1][1][0];
  IHM[3][1][1] = -Tmp2[1][1][1];
  }

}

/*******************************************************************************
Routine  : PseudoInverseHermitianMatrix4Double
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2007
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Pseudo-Inverse of a 4x4 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 4*4*2 Hermitian Matrix
Returned values  :
IHM     : 4*4*2 Pseudo Inverse Hermitian Matrix
*******************************************************************************/
void PseudoInverseHermitianMatrix4Double(double ***HM, double ***IHM)
{
  int k,l;
  float ***V;    /* 4*4 eigenvector matrix */
  float ***Vm1;  /* 4*4 eigenvector matrix */
  float ***VL;  /* 4*4 eigenvalue matrix */
  float *lambda;  /* 4 element eigenvalue vector */
  float ***Tmp1;
  float ***M;
  float ***IM;

  V = matrix3d_float(4, 4, 2);
  Vm1 = matrix3d_float(4, 4, 2);
  VL = matrix3d_float(4, 4, 2);
  lambda = vector_float(4);
  Tmp1 = matrix3d_float(4, 4, 2);
  M = matrix3d_float(4, 4, 2);
  IM = matrix3d_float(4, 4, 2);

   for (k = 0; k < 4; k++) {
  for (l = 0; l < 4; l++) {
    M[k][l][0]= (float)HM[k][l][0]; M[k][l][1] = (float)HM[k][l][1];
  }
  }

  Diagonalisation(4, M, V, lambda);

   for (k = 0; k < 4; k++) {
  for (l = 0; l < 4; l++) {
    VL[k][l][0]=0.; VL[k][l][1]=0.;
  }
  }
   for (k = 0; k < 4; k++) 
  if (lambda[k] > 1.E-10) VL[k][k][0] = 1./lambda[k];

  // Transpose Conjugate Matrix
  for (k = 0; k < 4; k++) {
  for (l = 0; l < 4; l++) {
    Vm1[k][l][0] =  V[l][k][0];
    Vm1[k][l][1] = -V[l][k][1];
  }
  }

  ProductCmplxMatrix(V,VL,Tmp1,4);
  ProductCmplxMatrix(Tmp1,Vm1,IM,4);

   for (k = 0; k < 4; k++) {
  for (l = 0; l < 4; l++) {
    IHM[k][l][0]= (double)IM[k][l][0]; IHM[k][l][1] = (double)IM[k][l][1];
  }
  }
}

/*******************************************************************************
Routine  : DeterminantHermitianMatrix4Double
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 4x4 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM    : 4*4*4 Hermitian Matrix
Returned values  :
det      : Complex Determinant of the Hermitian Matrix
*******************************************************************************/
void DeterminantHermitianMatrix4Double(double ***HM, double *det)
{
  double ***A;
  double ***B;
  double ***C;
  double ***D;
  double ***P;
  double ***Am1;
  double ***Tmp1;
  double ***Tmp2;
  double *det1;
  double *det2;

  int i,j,k;

  A = matrix3d_double(2, 2, 2);
  B = matrix3d_double(2, 2, 2);
  C = matrix3d_double(2, 2, 2);
  D = matrix3d_double(2, 2, 2);
  Am1 = matrix3d_double(2, 2, 2);
  P = matrix3d_double(2, 2, 2);
  Tmp1 = matrix3d_double(2, 2, 2);
  Tmp2 = matrix3d_double(2, 2, 2);
  det1 = vector_double(2);
  det2 = vector_double(2);

  A[0][0][0] = HM[0][0][0];
  A[0][0][1] = HM[0][0][1];
  A[0][1][0] = HM[0][1][0];
  A[0][1][1] = HM[0][1][1];
  A[1][0][0] = HM[1][0][0];
  A[1][0][1] = HM[1][0][1];
  A[1][1][0] = HM[1][1][0];
  A[1][1][1] = HM[1][1][1];
  B[0][0][0] = HM[0][2][0];
  B[0][0][1] = HM[0][2][1];
  B[0][1][0] = HM[0][3][0];
  B[0][1][1] = HM[0][3][1];
  B[1][0][0] = HM[1][2][0];
  B[1][0][1] = HM[1][2][1];
  B[1][1][0] = HM[1][3][0];
  B[1][1][1] = HM[1][3][1];
  C[0][0][0] = HM[2][0][0];
  C[0][0][1] = HM[2][0][1];
  C[0][1][0] = HM[2][1][0];
  C[0][1][1] = HM[2][1][1];
  C[1][0][0] = HM[3][0][0];
  C[1][0][1] = HM[3][0][1];
  C[1][1][0] = HM[3][1][0];
  C[1][1][1] = HM[3][1][1];
  D[0][0][0] = HM[2][2][0];
  D[0][0][1] = HM[2][2][1];
  D[0][1][0] = HM[2][3][0];
  D[0][1][1] = HM[2][3][1];
  D[1][0][0] = HM[3][2][0];
  D[1][0][1] = HM[3][2][1];
  D[1][1][0] = HM[3][3][0];
  D[1][1][1] = HM[3][3][1];

  InverseCmplxMatrix2Double(A,Am1);

  ProductCmplxMatrixDouble(C,Am1,Tmp1,2);
  ProductCmplxMatrixDouble(Tmp1,B,Tmp2,2);

  for (i = 0; i < 2; i++)
    for (j = 0; j < 2; j++)
      for (k = 0; k < 2; k++)
        P[i][j][k] = D[i][j][k] - Tmp2[i][j][k];

  DeterminantCmplxMatrix2Double(A,det1);
  DeterminantCmplxMatrix2Double(P,det2);

  det[0]=det1[0]*det2[0]-det1[1]*det2[1];
  det[1]=det1[0]*det2[1]+det1[1]*det2[0];

  if (det[0] < eps) det[0] = eps;
  if (det[1] < eps) det[1] = eps;

}

/*******************************************************************************
Routine  : DeterminantCmplxMatrix2Double
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2007
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 2x2 Complex Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
M    : 2*2*2 Complex Matrix
Returned values  :
det     : Complex Determinant of the Complex Matrix
*******************************************************************************/
void DeterminantCmplxMatrix2Double(double ***M, double *det)
{
det[0] = M[0][0][0] * M[1][1][0] - M[0][0][1] * M[1][1][1];
det[0] = det[0] - (M[0][1][0] * M[1][0][0] - M[0][1][1] * M[1][0][1]) + eps;

det[1] = M[0][0][0] * M[1][1][1] + M[0][0][1] * M[1][1][0];
det[1] = det[1] - (M[0][1][0] * M[1][0][1] + M[0][1][1] * M[1][0][0]) + eps;
}

