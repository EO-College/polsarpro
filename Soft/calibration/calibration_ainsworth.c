/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
File   : calibration_ainsworth.c
Project  : ESA_POLSARPRO
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Creation : 06/2005
Update  :

*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
Description :  Relative polarimetric calibration based on the method 
of Thomas Ainsworth

Inputs  : 

Outputs : 

*-------------------------------------------------------------------------------
Routines:
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
float ***matrix3d_float(int nz,int nrh,int nch);
void free_matrix3d_float(float ***m,int nz,int nrh);
void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType);

float AmplitudeComplex_v2(float Re, float Im);
void Gen_alpha(float **C,int dim, float **alpha);
void Gen_alpha2(float **C,int col, float **alpha);
void Gen_sigma1(float **C, int col, float **alpha, float **Sgm);
void Gen_sigma2(float **C, float **u_rg, float **v_rg, float **w_rg, float **z_rg, float ***alpha, int col, float **Sgm2);
void Rescale_cross_terms(float ***a1, float ***a2, float **Sgm2, int col);
void Prod_HM(float ***M1, float ***M2, int dim, float ***Mout);
void Gen_system(float **Sgm, float **A, float **B, int col, float **A8x8, float *X);
void Gen_A_B(float **Sgm, int col, float **A, float **B);
void ludcmp(float **a, int n, int *indx, float *d);
void lubksb(float **a, int n, int *indx, float b[]);
void Gen_calibration_matrix(float ***Cal, int col, float **u_rg, float **v_rg, float **w_rg, float **z_rg, float alpha_re, float alpha_im);
void Data_calibration(float ***S,float ***mcal_rg, int num_col);

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

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
#define C22   5
#define C23_re  6
#define C23_im  7
#define C33   8
#define C14_re  9
#define C14_im  10
#define C24_re  11
#define C24_im  12
#define C34_re  13
#define C34_im  14
#define C44   15

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

/* ROUTINES DECLARATION */
#include "../lib/graphics.h"
#include "../lib/matrix.h"
#include "../lib/processing.h"
#include "../lib/util.h"
#include "../lib/statistics.h"
#include "../lib/sub_aperture.h"
float AmplitudeComplex_v2(float Re, float Im);
void Gen_alpha(float **C,int dim, float **alpha);
void Gen_alpha2(float **C,int col, float **alpha);
void Gen_sigma1(float **C, int col, float **alpha, float **Sgm);
void Gen_sigma2(float **C, float **u_rg, float **v_rg, float **w_rg, float **z_rg, float ***alpha, int col, float **Sgm2);
void Rescale_cross_terms(float ***a1, float ***a2, float **Sgm2, int col);
void Prod_HM(float ***M1, float ***M2, int dim, float ***Mout);
void Gen_system(float **Sgm, float **A, float **B, int col, float **A8x8, float *X);
void Gen_A_B(float **Sgm, int col, float **A, float **B);
void ludcmp(float **a, int n, int *indx, float *d);
void lubksb(float **a, int n, int *indx, float b[]);
void Gen_calibration_matrix(float ***Cal, int col, float **u_rg, float **v_rg, float **w_rg, float **z_rg, float alpha_re, float alpha_im);
void Data_calibration(float ***S,float ***mcal_rg, int num_col);

/*******************************************************************************/

int main(int argc, char *argv[])
{
  /*******************/  
  /* LOCAL VARIABLES */
  /*******************/
  
  /* Input/Output file pointer arrays*/
  FILE *in_fileS2[4];
  FILE *in_fileC4[16];
  FILE *out_file[4];

  char in_dir[FilePathLength],out_dir[FilePathLength],tmp_dir[FilePathLength],file_name[FilePathLength];
  char *FileInputS2[4]  = { "s11.bin", "s21.bin", "s12.bin", "s22.bin"};
  char *FileInputC4[16] = { "C11.bin", "C12_real.bin", "C12_imag.bin", "C13_real.bin", "C13_imag.bin",
          "C22.bin", "C23_real.bin", "C23_imag.bin",
          "C33.bin",
          "C14_real.bin", "C14_imag.bin",
          "C24_real.bin", "C24_imag.bin",
          "C34_real.bin", "C34_imag.bin",
          "C44.bin"};
  char *FileOutput[4]  = { "s11.bin", "s21.bin", "s12.bin", "s22.bin"};
  
  char PolarCase[20], PolarType[20];
  
  /* Input variables */
  int Nlig, Ncol;    /* Initial image nb of lines and rows */
  int Off_lig, Off_col;  /* Lines and rows offset values */
  int Sub_Nlig, Sub_Ncol;  /* Sub-image nb of lines and rows */
  
  /* Temporal matrices */
  int it,m,n;
  int *indx;
  
  float d, c_fact, v_tmp1, v_tmp2, span;
  float *Span, *C_ind, *X;
  float **M_tmp_ligne, **C_range, **C_temp, **Alpha1_range, **Alpha2_range, **Sigma_range, **A_range, **B_range, **uuu_range, **vvv_range, **www_range, **zzz_range, **M_system;
  float ***S_tmp_block, ***C_ligne, ***alpha1_matrix, ***alpha2_matrix, ***Mcal_range;
  
  /* Internal variables */
  int Npolar_S, Npolar_C, Npolar_C_full, np;
  int lig, col, ind;

  /******************/
  /* PROGRAM STARTS */
  /******************/
  
  if (argc == 8){
  strcpy(in_dir, argv[1]);
  strcpy(out_dir, argv[2]);
  strcpy(tmp_dir, argv[3]);
  Off_lig  = atoi(argv[4]);
  Off_col  = atoi(argv[5]);
  Sub_Nlig = atoi(argv[6]);
  Sub_Ncol = atoi(argv[7]);
  } else
  edit_error("calibration_ainsworth in_dir out_dir tmp_dir Off_lig Off_col Sub_Nlig Sub_Ncol\n","");
    
  check_dir(in_dir);
  check_dir(out_dir);
  check_dir(tmp_dir);

  /* Initialization of variables */
  Npolar_S    = 4;
  Npolar_C    = 16;
  Npolar_C_full = 28;

  /* Input/Output configurations */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
  /* Matrix Declarations */
  
  indx    = vector_int(8);
  
  Span    = vector_float(Sub_Ncol);
  C_ind    = vector_float(Sub_Ncol);
  X     = vector_float(8);
  
  C_range    = matrix_float(Sub_Ncol,Npolar_C_full);
  C_temp    = matrix_float(Sub_Ncol,Npolar_C_full);
  Alpha1_range  = matrix_float(Sub_Ncol,8);
  Alpha2_range  = matrix_float(Sub_Ncol,8);
  Sigma_range    = matrix_float(Sub_Ncol,Npolar_C_full);
  A_range    = matrix_float(Sub_Ncol,2);
  B_range    = matrix_float(Sub_Ncol,2);
  uuu_range    = matrix_float(Sub_Ncol,2);
  vvv_range    = matrix_float(Sub_Ncol,2);
  www_range    = matrix_float(Sub_Ncol,2);
  zzz_range    = matrix_float(Sub_Ncol,2);
  M_system   = matrix_float(8,8);
  M_tmp_ligne   = matrix_float(Npolar_S,2*Ncol);
  
  alpha1_matrix  = matrix3d_float(4,4,2);  
  alpha2_matrix  = matrix3d_float(4,4,2);
  Mcal_range   = matrix3d_float(Sub_Ncol,16,2);
  S_tmp_block   = matrix3d_float(Npolar_S,2,2*Sub_Ncol);
  C_ligne     = matrix3d_float(Npolar_C_full,1,Sub_Ncol);
  
  /* Input S2 files opening */
  for (np = 0; np < Npolar_S; np++) {
  sprintf(file_name, "%s%s", in_dir, FileInputS2[np]);
  if ((in_fileS2[np] = fopen(file_name, "rb")) == NULL)
     edit_error("Could not open input file : ", file_name);
  }
  
  /* Input C4 files opening */
  for (np = 0; np < Npolar_C; np++) {
  sprintf(file_name, "%s%s", tmp_dir, FileInputC4[np]);
  if ((in_fileC4[np] = fopen(file_name, "rb")) == NULL)
     edit_error("Could not open input file : ", file_name);
  }
  
  /* Input file sub-window reading */
  for (np = 0; np < Npolar_S; np++) rewind(in_fileS2[np]);
  for (np = 0; np < Npolar_C; np++) rewind(in_fileC4[np]);
  
  /* Jumps Off_lig S2 */
  for (lig = 0; lig < Off_lig ; lig++) {  
  for (np = 0; np < Npolar_S; np++) {
      fread(&M_tmp_ligne[0][0], sizeof(float), 2 * Ncol, in_fileS2[np]);
    }
  }
  
  /* Jumps Off_lig C4 */
  for (lig = 0; lig < Off_lig ; lig++) {  
  for (np = 0; np < Npolar_C; np++) {
      //fread(&M_tmp_ligne[0][0], sizeof(float), Ncol, in_fileC4[np]);
    }
  }

  /*****************************/
  /* Average covariance matrix */
  /*****************************/
  
  /* Span in range */
  for (col = 0; col < Sub_Ncol; col ++) Span[col] = 0.0;
  for (lig = 0; lig < Sub_Nlig; lig++){
   fread(&M_tmp_ligne[0][0], sizeof(float), Sub_Ncol, in_fileC4[0]);  /* HH */
   for (col = 0; col < Sub_Ncol; col ++) Span[col] += M_tmp_ligne[0][col + Off_col];
   fread(&M_tmp_ligne[0][0], sizeof(float), Sub_Ncol, in_fileC4[5]);  /* HV */
   for (col = 0; col < Sub_Ncol; col ++) Span[col] += M_tmp_ligne[0][col + Off_col];  
   fread(&M_tmp_ligne[0][0], sizeof(float), Sub_Ncol, in_fileC4[8]);  /* VH */
   for (col = 0; col < Sub_Ncol; col ++) Span[col] += M_tmp_ligne[0][col + Off_col];  
   fread(&M_tmp_ligne[0][0], sizeof(float), Sub_Ncol, in_fileC4[15]);  /* VV */
   for (col = 0; col < Sub_Ncol; col ++) Span[col] += M_tmp_ligne[0][col + Off_col];
  }
  for (col = 0; col < Sub_Ncol; col ++) Span[col] = Span[col] / Sub_Ncol;
  
  /* Puts files in the original situation */  
  for (np = 0; np < Npolar_C; np++) rewind(in_fileC4[np]);
  for (lig = 0; lig < Off_lig ; lig++) {  
  for (np = 0; np < Npolar_C; np++) {
      fread(&M_tmp_ligne[0][0], sizeof(float), Ncol, in_fileC4[np]);
    }
  }
  
  /* Initialization of C */
  for (col = 0; col < Sub_Ncol; col ++)
   C_ind[col] = 0.0;
  for (col = 0; col < Sub_Ncol; col++) 
   for (np = 0; np < Npolar_C_full; np++)
     C_range[col][np] = 0.0;
  
  /* Averages to create C matrix in range */
  for (lig = 0; lig < Sub_Nlig; lig++){
   /* Reads files with C */
  for (np = 0; np < Npolar_C; np++){
    fread(&M_tmp_ligne[0][0], sizeof(float), Sub_Ncol, in_fileC4[np]);
    for (col = 0; col < Sub_Ncol; col ++) C_temp[col][np] = M_tmp_ligne[0][col + Off_col];
  }
    
  /* Generates the Hermitian part of C */
   for ( col = 0; col < Sub_Ncol; col++) {
     C_temp[col][C21_re] = C_temp[col][C12_re];
    C_temp[col][C21_im] = (-1.0) * C_temp[col][C12_im];
    C_temp[col][C31_re] = C_temp[col][C13_re];
     C_temp[col][C31_im] = (-1.0) * C_temp[col][C13_im];  
     C_temp[col][C32_re] = C_temp[col][C23_re];
     C_temp[col][C32_im] = (-1.0) * C_temp[col][C23_im];
     C_temp[col][C41_re] = C_temp[col][C14_re];
     C_temp[col][C41_im] = (-1.0) * C_temp[col][C14_im];
      C_temp[col][C42_re] = C_temp[col][C24_re];
     C_temp[col][C42_im] = (-1.0) * C_temp[col][C24_im];
     C_temp[col][C43_re] = C_temp[col][C34_re];
     C_temp[col][C43_im] = (-1.0) * C_temp[col][C34_im];
  }
   /* Determines if the C matrix is included in the mean */
   for (col = 0; col < Sub_Ncol; col++) {
    span = C_temp[col][0] + C_temp[col][5] + C_temp[col][8] + C_temp[col][15];
    if (span <= 4.0 * Span[col]){
     C_ind[col] = C_ind[col] + 1.0;
     for (np = 0; np < Npolar_C_full; np++) C_range[col][np] += C_temp[col][np];
    }
  }
  }
  
  /* Normalizes for the average */
  for (col = 0; col < Sub_Ncol; col++){
  if (C_ind[col] > 0.0)
    for (np = 0; np < Npolar_C_full; np++) C_range[col][np] = C_range[col][np] / C_ind[col];
  }
   
   /* Generation of alpha parameter */
   Gen_alpha(C_range,Sub_Ncol,Alpha1_range);
   
  /*****************************************/
  /* Generates calibration matrix in range */
  /*****************************************/
  
  for (col = 0; col < Sub_Ncol; col++){
    uuu_range[col][cre] = 0.0; vvv_range[col][cre] = 0.0; www_range[col][cre] = 0.0; zzz_range[col][cre] = 0.0;
    uuu_range[col][cim] = 0.0; vvv_range[col][cim] = 0.0; www_range[col][cim] = 0.0; zzz_range[col][cim] = 0.0;
    
    /* Produces Sigma1 in range */
    Gen_sigma1(C_range,col,Alpha1_range,Sigma_range);
  }
  
  for (col = 0; col < Sub_Ncol; col++){
    if (col%(int)(Sub_Ncol/20) == 0) {printf("%f\r", 100. * col / (Sub_Ncol - 1));fflush(stdout);}
    
   /* Generation of the diagonal alpha matrix */
   for (m = 0; m < 4; m++){
    for (n = 0; n < 4; n++){
     alpha1_matrix[m][n][cre] = 0.0;  alpha1_matrix[m][n][cim] = 0.0;
    }
  }
   alpha1_matrix[0][0][cre] = Alpha1_range[col][cre+6];
   alpha1_matrix[0][0][cim] = Alpha1_range[col][cim+6];
   alpha1_matrix[1][1][cre] = Alpha1_range[col][cre+4];
   alpha1_matrix[1][1][cim] = Alpha1_range[col][cim+4];
   alpha1_matrix[2][2][cre] = Alpha1_range[col][cre+6];
   alpha1_matrix[2][2][cim] = Alpha1_range[col][cim+6];
   alpha1_matrix[3][3][cre] = Alpha1_range[col][cre+4];
   alpha1_matrix[3][3][cim] = Alpha1_range[col][cim+4];
   
   /* Adjustement factor */
   c_fact = 0.2;
     
    for(it = 0; it < 30; it++){ /* bucle for iterations */
    
    /* Produces the parameters A and B */
    Gen_A_B(Sigma_range,col,A_range,B_range);
    
    /* System to get the actualization of the cross-correlation terms */
    Gen_system(Sigma_range,A_range,B_range,col,M_system,X);
    ludcmp(M_system,8,indx,&d);
    lubksb(M_system,8,indx,X);
    uuu_range[col][cre] += X[0]*c_fact; vvv_range[col][cre] += X[1]*c_fact; www_range[col][cre] += X[2]*c_fact; zzz_range[col][cre] += X[3]*c_fact;
    uuu_range[col][cim] += X[4]*c_fact; vvv_range[col][cim] += X[5]*c_fact; www_range[col][cim] += X[6]*c_fact; zzz_range[col][cim] += X[7]*c_fact;
    c_fact = pow(c_fact,0.2);
    
    /* Produces the matrix sigma2 */
    Gen_sigma2(C_range,uuu_range,vvv_range,www_range,zzz_range,alpha1_matrix,col,Sigma_range);
    
    /* Produces alpha2 in range */    
    Gen_alpha2(Sigma_range,col,Alpha2_range); 
    
    /* Generation of the diagonal alpha2 matrix */
    for (m = 0; m < 4; m++){
     for (n = 0; n < 4; n++){
      alpha2_matrix[m][n][cre] = 0.0;  alpha2_matrix[m][n][cim] = 0.0;
    }
    }
    alpha2_matrix[0][0][cre] = Alpha2_range[col][cre+6];
    alpha2_matrix[0][0][cim] = Alpha2_range[col][cim+6];
    alpha2_matrix[1][1][cre] = Alpha2_range[col][cre+4];
    alpha2_matrix[1][1][cim] = Alpha2_range[col][cim+4];
    alpha2_matrix[2][2][cre] = Alpha2_range[col][cre+6];
    alpha2_matrix[2][2][cim] = Alpha2_range[col][cim+6];
    alpha2_matrix[3][3][cre] = Alpha2_range[col][cre+4];
    alpha2_matrix[3][3][cim] = Alpha2_range[col][cim+4];
    
    /* Rescales cross-correlation terms and alpha */
    Rescale_cross_terms(alpha1_matrix,alpha2_matrix,Sigma_range,col);  
    
    /* Updates vvv, zzz */
    v_tmp1 = vvv_range[col][cre] * Alpha2_range[col][cre+2] - vvv_range[col][cim] * Alpha2_range[col][cim+2];
    v_tmp2 = vvv_range[col][cre] * Alpha2_range[col][cim+2] + vvv_range[col][cim] * Alpha2_range[col][cre+2];
    vvv_range[col][cre] = v_tmp1;
    vvv_range[col][cim] = v_tmp2;
    v_tmp1 = zzz_range[col][cre] * Alpha2_range[col][cre] - zzz_range[col][cim] * Alpha2_range[col][cim];
    v_tmp2 = zzz_range[col][cre] * Alpha2_range[col][cim] + zzz_range[col][cim] * Alpha2_range[col][cre];
    zzz_range[col][cre] = v_tmp1;
    zzz_range[col][cim] = v_tmp2;
   }
   
   /* alpha parameter */
   v_tmp1 = AmplitudeComplex_v2(alpha1_matrix[3][3][cre],alpha1_matrix[3][3][cim]) * cos(atan2(alpha1_matrix[3][3][cim],alpha1_matrix[3][3][cre]));
   v_tmp2 = AmplitudeComplex_v2(alpha1_matrix[3][3][cre],alpha1_matrix[3][3][cim]) * sin(atan2(alpha1_matrix[3][3][cim],alpha1_matrix[3][3][cre]));
   
   Gen_calibration_matrix(Mcal_range,col,uuu_range,vvv_range,www_range,zzz_range,v_tmp1,v_tmp2);
   
  }
  
  /*********************/
  /* Final Calibration */
  /*********************/

  /* Output file opening */
  for (np = 0; np < Npolar_S; np++) {
  sprintf(file_name, "%s%s", out_dir, FileOutput[np]);
  if ((out_file[np] = fopen(file_name, "wb")) == NULL) 
    edit_error("Could not open output file : ", file_name);
  }

  /* Input file sub-window reading */
  for (np = 0; np < Npolar_S; np++) rewind(in_fileS2[np]);
  for (np = 0; np < Npolar_S; np++) rewind(out_file[np]);
  
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
    
    /* Final calibration */
    Data_calibration(S_tmp_block,Mcal_range,Sub_Ncol);
          
  /* Save a line of S of Sub_Ncol cols */
  for (np = 0; np < Npolar_S; np++)
    fwrite(&S_tmp_block[np][1][0], sizeof(float), 2 * Sub_Ncol, out_file[np]);
   }
    
  /* Close of Files */
  for (np = 0; np < Npolar_S; np++) fclose(in_fileS2[np]);
  for (np = 0; np < Npolar_C; np++) fclose(in_fileC4[np]);
  for (np = 0; np < Npolar_S; np++) fclose(out_file[np]);
   
  /* Memory Libertation */
  free_vector_int(indx);
  
  free_vector_float(Span);
  free_vector_float(C_ind);
  free_vector_float(X);
  
  free_matrix_float(C_range,Sub_Ncol);
  free_matrix_float(C_temp,Sub_Ncol);
  free_matrix_float(Alpha1_range,Sub_Ncol);
  free_matrix_float(Alpha2_range,Sub_Ncol);
  free_matrix_float(Sigma_range,Sub_Ncol);
  free_matrix_float(A_range,Sub_Ncol);
  free_matrix_float(B_range,Sub_Ncol);
  free_matrix_float(uuu_range,Sub_Ncol);
  free_matrix_float(vvv_range,Sub_Ncol);
  free_matrix_float(www_range,Sub_Ncol);
  free_matrix_float(zzz_range,Sub_Ncol);
  free_matrix_float(M_system,8);
  free_matrix_float(M_tmp_ligne,Npolar_S);
  
  free_matrix3d_float(alpha1_matrix,4,4);  
  free_matrix3d_float(alpha2_matrix,4,4);
  free_matrix3d_float(Mcal_range,Sub_Ncol,16);
  free_matrix3d_float(S_tmp_block,Npolar_S,2);
  free_matrix3d_float(C_ligne,Npolar_C_full,1);
  
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
Routine  : Gen_alpha
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates alpha parameter
*-------------------------------------------------------------------------------
Inputs arguments :
Re    : Input Real part
Im  : Input Imaginary part
Returned values  :
  : Amplitude
*******************************************************************************/
void Gen_alpha(float **C,int dim, float **alpha)
{
  int col;
  float v1;
  for (col=0; col<dim; col++){
  v1 = sqrt(C[col][C33]/C[col][C22]);
  alpha[col][cre]  = v1 * cos(atan2(C[col][C32_im],C[col][C32_re]));
  alpha[col][cim]  = v1 * sin(atan2(C[col][C32_im],C[col][C32_re]));
  /* Inverse of alpha */
  alpha[col][cre+2] = (1.0 / v1) * cos(-1.0 * atan2(C[col][C32_im],C[col][C32_re]));
  alpha[col][cim+2] = (1.0 / v1) * sin(-1.0 * atan2(C[col][C32_im],C[col][C32_re]));
  }
  for (col=0; col<dim; col++){
  v1 = sqrt(sqrt(C[col][C33]/C[col][C22]));
  alpha[col][cre+4]  = v1 * cos(atan2(C[col][C32_im],C[col][C32_re])/2.0);
  alpha[col][cim+4]  = v1 * sin(atan2(C[col][C32_im],C[col][C32_re])/2.0);
  /* Inverse of alpha */
  alpha[col][cre+6] = (1.0 / v1) * cos(-1.0 * (atan2(C[col][C32_im],C[col][C32_re])/2.0));
  alpha[col][cim+6] = (1.0 / v1) * sin(-1.0 * (atan2(C[col][C32_im],C[col][C32_re])/2.0));
  }
}

/*******************************************************************************
Routine  : Gen_alpha2
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates alpha2 parameter
*-------------------------------------------------------------------------------
Inputs arguments :
Re    : Input Real part
Im  : Input Imaginary part
Returned values  :
  : Amplitude
*******************************************************************************/
void Gen_alpha2(float **C,int col, float **alpha)
{
  float v1;
  
  v1 = sqrt(C[col][C33]/C[col][C22]);
  alpha[col][cre]  = v1 * cos(atan2(C[col][C32_im],C[col][C32_re]));
  alpha[col][cim]  = v1 * sin(atan2(C[col][C32_im],C[col][C32_re]));
  /* Inverse of alpha */
  alpha[col][cre+2] = (1.0 / v1) * cos(-1.0 * atan2(C[col][C32_im],C[col][C32_re]));
  alpha[col][cim+2] = (1.0 / v1) * sin(-1.0 * atan2(C[col][C32_im],C[col][C32_re]));
  
  v1 = sqrt(sqrt(C[col][C33]/C[col][C22]));
  alpha[col][cre+4]  = v1 * cos(atan2(C[col][C32_im],C[col][C32_re])/2.0);
  alpha[col][cim+4]  = v1 * sin(atan2(C[col][C32_im],C[col][C32_re])/2.0);
  /* Inverse of alpha */
  alpha[col][cre+6] = (1.0 / v1) * cos(-1.0 * (atan2(C[col][C32_im],C[col][C32_re])/2.0));
  alpha[col][cim+6] = (1.0 / v1) * sin(-1.0 * (atan2(C[col][C32_im],C[col][C32_re])/2.0));
}

/*******************************************************************************
Routine  : Gen_sigma1
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates the covariance matrix Sigma1
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Gen_sigma1(float **C, int col, float **alpha, float **Sgm)
{
  float ***s, ***s2, ***a, ***a_herm, ***m1;
  int m,n;
  
  s    = matrix3d_float(4,4,2);
  s2   = matrix3d_float(4,4,2);
  a    = matrix3d_float(4,4,2);
  a_herm = matrix3d_float(4,4,2);
  m1   = matrix3d_float(4,4,2);
  
  /* Rearranges the covariance matrix */
  s[0][0][cre] = C[col][C11];   s[0][0][cim] = 0.0; 
  s[0][1][cre] = C[col][C12_re];  s[0][1][cim] = C[col][C12_im];
  s[0][2][cre] = C[col][C13_re];  s[0][2][cim] = C[col][C13_im];
  s[0][3][cre] = C[col][C14_re];  s[0][3][cim] = C[col][C14_im];
  s[1][0][cre] = C[col][C21_re];  s[1][0][cim] = C[col][C21_im]; 
  s[1][1][cre] = C[col][C22];   s[1][1][cim] = 0.0;
  s[1][2][cre] = C[col][C23_re];  s[1][2][cim] = C[col][C23_im];
  s[1][3][cre] = C[col][C24_re];  s[1][3][cim] = C[col][C24_im];
  s[2][0][cre] = C[col][C31_re];  s[2][0][cim] = C[col][C31_im]; 
  s[2][1][cre] = C[col][C32_re];  s[2][1][cim] = C[col][C32_im];
  s[2][2][cre] = C[col][C33];   s[2][2][cim] = 0.0;
  s[2][3][cre] = C[col][C34_re];  s[2][3][cim] = C[col][C34_im];
  s[3][0][cre] = C[col][C41_re];  s[3][0][cim] = C[col][C41_im]; 
  s[3][1][cre] = C[col][C42_re];  s[3][1][cim] = C[col][C42_im];
  s[3][2][cre] = C[col][C43_re];  s[3][2][cim] = C[col][C43_im];
  s[3][3][cre] = C[col][C44];   s[3][3][cim] = 0.0;
  
  /* Generates alpha matrix */
  for (m = 0; m < 4; m++){
   for (n = 0; n < 4; n++){
    a[m][n][cre] = 0.0;  a[m][n][cim] = 0.0;
  }
  }
  a[0][0][cre] = alpha[col][cre+6];
  a[0][0][cim] = alpha[col][cim+6];
  a[1][1][cre] = alpha[col][cre+4];
  a[1][1][cim] = alpha[col][cim+4];
  a[2][2][cre] = alpha[col][cre+6];
  a[2][2][cim] = alpha[col][cim+6];
  a[3][3][cre] = alpha[col][cre+4];
  a[3][3][cim] = alpha[col][cim+4];
  
  /* Generates hermitian alpha matrix */
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    a_herm[m][n][cre] = a[n][m][cre];
    a_herm[m][n][cim] = -1.0 * a[n][m][cim];
  }
  }
  
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre] = 0.0;
    m1[m][n][cim] = 0.0;
    s2[m][n][cre] = 0.0;
    s2[m][n][cim] = 0.0;
  }
  }
  
  /* m1=a*s */
  Prod_HM(a,s,4,m1);
  /* s2=m1*a_herm */
  Prod_HM(m1,a_herm,4,s2);
   
  /* Rearranges to create Sgm */
  Sgm[col][C11]  = s2[0][0][cre];
  Sgm[col][C12_re] = s2[0][1][cre];
  Sgm[col][C12_im] = s2[0][1][cim];
  Sgm[col][C13_re] = s2[0][2][cre];
  Sgm[col][C13_im] = s2[0][2][cim];
  Sgm[col][C14_re] = s2[0][3][cre];
  Sgm[col][C14_im] = s2[0][3][cim];
  Sgm[col][C22]  = s2[1][1][cre];
  Sgm[col][C23_re] = s2[1][2][cre];
  Sgm[col][C23_im] = s2[1][2][cim];
  Sgm[col][C24_re] = s2[1][3][cre];
  Sgm[col][C24_im] = s2[1][3][cim];
  Sgm[col][C33]  = s2[2][2][cre];
  Sgm[col][C34_re] = s2[2][3][cre];
  Sgm[col][C34_im] = s2[2][3][cim];
  Sgm[col][C44]  = s2[3][3][cre];
  Sgm[col][C21_re] = s2[1][0][cre];
  Sgm[col][C21_im] = s2[1][0][cim];
  Sgm[col][C31_re] = s2[2][0][cre];
  Sgm[col][C31_im] = s2[2][0][cim];  
  Sgm[col][C32_re] = s2[2][1][cre];
  Sgm[col][C32_im] = s2[2][1][cim];
  Sgm[col][C41_re] = s2[3][0][cre];
  Sgm[col][C41_im] = s2[3][0][cim];
  Sgm[col][C42_re] = s2[3][1][cre];
  Sgm[col][C42_im] = s2[3][1][cim];
  Sgm[col][C43_re] = s2[3][2][cre];
  Sgm[col][C43_im] = s2[3][2][cim];
  
  free_matrix3d_float(s,4,4);
  free_matrix3d_float(s2,4,4);
  free_matrix3d_float(a,4,4);
  free_matrix3d_float(a_herm,4,4);
  free_matrix3d_float(m1,4,4);
}

/*******************************************************************************
Routine  : Gen_sigma2
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates the covariance matrix Sigma1
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Gen_sigma2(float **C, float **u_rg, float **v_rg, float **w_rg, float **z_rg, float ***alpha, int col, float **Sgm2)
{
  float ***c, ***s2, ***m1, ***m2, ***m_tmp;
  float v1_re, v1_im, v2_re, v2_im, v3_re, v3_im;
  int m,n;
  
  c   = matrix3d_float(4,4,2);
  s2  = matrix3d_float(4,4,2);
  m1  = matrix3d_float(4,4,2);
  m2  = matrix3d_float(4,4,2);
  m_tmp = matrix3d_float(4,4,2);
  
  /* Rearranges C */
  c[0][0][cre] = C[col][C11];   c[0][0][cim] = 0.0; 
  c[0][1][cre] = C[col][C12_re];  c[0][1][cim] = C[col][C12_im];
  c[0][2][cre] = C[col][C13_re];  c[0][2][cim] = C[col][C13_im];
  c[0][3][cre] = C[col][C14_re];  c[0][3][cim] = C[col][C14_im];
  c[1][0][cre] = C[col][C21_re];  c[1][0][cim] = C[col][C21_im]; 
  c[1][1][cre] = C[col][C22];   c[1][1][cim] = 0.0;
  c[1][2][cre] = C[col][C23_re];  c[1][2][cim] = C[col][C23_im];
  c[1][3][cre] = C[col][C24_re];  c[1][3][cim] = C[col][C24_im];
  c[2][0][cre] = C[col][C31_re];  c[2][0][cim] = C[col][C31_im]; 
  c[2][1][cre] = C[col][C32_re];  c[2][1][cim] = C[col][C32_im];
  c[2][2][cre] = C[col][C33];   c[2][2][cim] = 0.0;
  c[2][3][cre] = C[col][C34_re];  c[2][3][cim] = C[col][C34_im];
  c[3][0][cre] = C[col][C41_re];  c[3][0][cim] = C[col][C41_im]; 
  c[3][1][cre] = C[col][C42_re];  c[3][1][cim] = C[col][C42_im];
  c[3][2][cre] = C[col][C43_re];  c[3][2][cim] = C[col][C43_im];
  c[3][3][cre] = C[col][C44];   c[3][3][cim] = 0.0;
  
  /* Creates m1 */
  v1_re = 1.0 - (v_rg[col][cre]*z_rg[col][cre] - v_rg[col][cim]*z_rg[col][cim]);
  v1_im = -1.0 * (v_rg[col][cre]*z_rg[col][cim] + v_rg[col][cim]*z_rg[col][cre]);
  v2_re = 1.0 - (w_rg[col][cre]*u_rg[col][cre] - w_rg[col][cim]*u_rg[col][cim]);
  v2_im = -1.0 * (w_rg[col][cre]*u_rg[col][cim] + w_rg[col][cim]*u_rg[col][cre]);
  v3_re = v1_re * v2_re - v1_im * v2_im;
  v3_im = v1_re * v2_im + v1_im * v2_re;
  v2_re = sqrt(AmplitudeComplex_v2(v3_re,v3_im)) * cos(atan2(v3_im,v3_re)/ 2.0);
  v2_im = sqrt(AmplitudeComplex_v2(v3_re,v3_im)) * sin(atan2(v3_im,v3_re)/ 2.0);
  v1_re = (1 / AmplitudeComplex_v2(v2_re,v2_im)) * cos(-1.0 * atan2(v2_im,v2_re));
  v1_im = (1 / AmplitudeComplex_v2(v2_re,v2_im)) * sin(-1.0 * atan2(v2_im,v2_re));

  m1[0][0][cre] = 1.0;                    m1[0][0][cim] = 0.0; 
  m1[0][1][cre] = -1.0*v_rg[col][cre];                    m1[0][1][cim] = -1.0*v_rg[col][cim];
  m1[0][2][cre] = -1.0*w_rg[col][cre];            m1[0][2][cim] = -1.0*w_rg[col][cim];
  m1[0][3][cre] = v_rg[col][cre]*w_rg[col][cre] - v_rg[col][cim]*w_rg[col][cim]; m1[0][3][cim] = v_rg[col][cre]*w_rg[col][cim] + v_rg[col][cim]*w_rg[col][cre];
  m1[1][0][cre] = -1.0*z_rg[col][cre];            m1[1][0][cim] = -1.0*z_rg[col][cim]; 
  m1[1][1][cre] = 1.0;                  m1[1][1][cim] = 0.0;
  m1[1][2][cre] = w_rg[col][cre]*z_rg[col][cre] - w_rg[col][cim]*z_rg[col][cim]; m1[1][2][cim] = w_rg[col][cre]*z_rg[col][cim] + w_rg[col][cim]*z_rg[col][cre];
  m1[1][3][cre] = -1.0*w_rg[col][cre];            m1[1][3][cim] = -1.0*w_rg[col][cim];
  m1[2][0][cre] = -1.0*u_rg[col][cre];            m1[2][0][cim] = -1.0*u_rg[col][cim]; 
  m1[2][1][cre] = u_rg[col][cre]*v_rg[col][cre] - u_rg[col][cim]*v_rg[col][cim]; m1[2][1][cim] = u_rg[col][cre]*v_rg[col][cim] + u_rg[col][cim]*v_rg[col][cre];
  m1[2][2][cre] = 1.0;                m1[2][2][cim] = 0.0;
  m1[2][3][cre] = -1.0*v_rg[col][cre];            m1[2][3][cim] = -1.0*v_rg[col][cim];
  m1[3][0][cre] = u_rg[col][cre]*z_rg[col][cre] - u_rg[col][cim]*z_rg[col][cim]; m1[3][0][cim] = u_rg[col][cre]*z_rg[col][cim] + u_rg[col][cim]*z_rg[col][cre]; 
  m1[3][1][cre] = -1.0*u_rg[col][cre];            m1[3][1][cim] = -1.0*u_rg[col][cim];
  m1[3][2][cre] = -1.0*z_rg[col][cre];            m1[3][2][cim] = -1.0*z_rg[col][cim];
  m1[3][3][cre] = 1.0;                m1[3][3][cim] = 0.0;
  
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre]  = m1[m][n][cre] * v1_re - m1[m][n][cim] * v1_im;  
    m1[m][n][cim]  = m1[m][n][cre] * v1_im + m1[m][n][cim] * v1_re;
    m_tmp[m][n][cre] = 0.0;  
    m_tmp[m][n][cim] = 0.0;
  }
  }
  
  /* Updating by alpha */
  Prod_HM(m1,alpha,4,m_tmp);
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre] = m_tmp[m][n][cre];
    m1[m][n][cim] = m_tmp[m][n][cim];
  }
  }
  
  /* Generates m2 (Transpose complex conjugate of m1) */
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m2[m][n][cre] = m1[n][m][cre];
    m2[m][n][cim] = -1.0 * m1[n][m][cim];
  }
  }
  
  /* Sigma2 = m1*c*m2 */
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m_tmp[m][n][cre] = 0.0;
    m_tmp[m][n][cim] = 0.0;
    s2[m][n][cre]  = 0.0;
    s2[m][n][cim]  = 0.0;
  }
  }
  
  /* m_tmp = m1*c */
  Prod_HM(m1,c,4,m_tmp);
  
  /* Sigma2 = m_tmp*m2 */
  Prod_HM(m_tmp,m2,4,s2);
  
  /* Creates Sgm2 */
  Sgm2[col][C11]  = s2[0][0][cre];
  Sgm2[col][C12_re] = s2[0][1][cre];
  Sgm2[col][C12_im] = s2[0][1][cim];
  Sgm2[col][C13_re] = s2[0][2][cre];
  Sgm2[col][C13_im] = s2[0][2][cim];
  Sgm2[col][C14_re] = s2[0][3][cre];
  Sgm2[col][C14_im] = s2[0][3][cim];
  Sgm2[col][C22]  = s2[1][1][cre];
  Sgm2[col][C23_re] = s2[1][2][cre];
  Sgm2[col][C23_im] = s2[1][2][cim];
  Sgm2[col][C24_re] = s2[1][3][cre];
  Sgm2[col][C24_im] = s2[1][3][cim];
  Sgm2[col][C33]  = s2[2][2][cre];
  Sgm2[col][C34_re] = s2[2][3][cre];
  Sgm2[col][C34_im] = s2[2][3][cim];
  Sgm2[col][C44]  = s2[3][3][cre];
  Sgm2[col][C21_re] = s2[1][0][cre];
  Sgm2[col][C21_im] = s2[1][0][cim];
  Sgm2[col][C31_re] = s2[2][0][cre];
  Sgm2[col][C31_im] = s2[2][0][cim];  
  Sgm2[col][C32_re] = s2[2][1][cre];
  Sgm2[col][C32_im] = s2[2][1][cim];
  Sgm2[col][C41_re] = s2[3][0][cre];
  Sgm2[col][C41_im] = s2[3][0][cim];
  Sgm2[col][C42_re] = s2[3][1][cre];
  Sgm2[col][C42_im] = s2[3][1][cim];
  Sgm2[col][C43_re] = s2[3][2][cre];
  Sgm2[col][C43_im] = s2[3][2][cim];
  
  free_matrix3d_float(m1,4,4);
  free_matrix3d_float(m2,4,4);
  free_matrix3d_float(c,4,4);
  free_matrix3d_float(s2,4,4);
  free_matrix3d_float(m_tmp,4,4);
}

/*******************************************************************************
Routine  : Rescale_cross_terms
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Reescales the cross-correlation terms with alpha2
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Rescale_cross_terms(float ***a1, float ***a2, float **Sgm, int col)
{
  float ***s1, ***s2, ***m1, ***a2_herm;
  int m,n;
  
  s1    = matrix3d_float(4,4,2);
  s2    = matrix3d_float(4,4,2);
  m1    = matrix3d_float(4,4,2);
  a2_herm = matrix3d_float(4,4,2);
  
  /* Rearranges Sgm */
  s2[0][0][cre] = Sgm[col][C11];  s2[0][0][cim] = 0.0; 
  s2[0][1][cre] = Sgm[col][C12_re];  s2[0][1][cim] = Sgm[col][C12_im];
  s2[0][2][cre] = Sgm[col][C13_re];  s2[0][2][cim] = Sgm[col][C13_im];
  s2[0][3][cre] = Sgm[col][C14_re];  s2[0][3][cim] = Sgm[col][C14_im];
  s2[1][0][cre] = Sgm[col][C21_re];  s2[1][0][cim] = Sgm[col][C21_im]; 
  s2[1][1][cre] = Sgm[col][C22];   s2[1][1][cim] = 0.0;
  s2[1][2][cre] = Sgm[col][C23_re];  s2[1][2][cim] = Sgm[col][C23_im];
  s2[1][3][cre] = Sgm[col][C24_re];  s2[1][3][cim] = Sgm[col][C24_im];
  s2[2][0][cre] = Sgm[col][C31_re];  s2[2][0][cim] = Sgm[col][C31_im]; 
  s2[2][1][cre] = Sgm[col][C32_re];  s2[2][1][cim] = Sgm[col][C32_im];
  s2[2][2][cre] = Sgm[col][C33];   s2[2][2][cim] = 0.0;
  s2[2][3][cre] = Sgm[col][C34_re];  s2[2][3][cim] = Sgm[col][C34_im];
  s2[3][0][cre] = Sgm[col][C41_re];  s2[3][0][cim] = Sgm[col][C41_im]; 
  s2[3][1][cre] = Sgm[col][C42_re];  s2[3][1][cim] = Sgm[col][C42_im];
  s2[3][2][cre] = Sgm[col][C43_re];  s2[3][2][cim] = Sgm[col][C43_im];
  s2[3][3][cre] = Sgm[col][C44];   s2[3][3][cim] = 0.0;
  
  /* Updating of alpha a1=a1*a2 */
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre] = 0.0;
    m1[m][n][cim] = 0.0;
  }
  }
  Prod_HM(a1,a2,4,m1);
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    a1[m][n][cre] = m1[m][n][cre];
    a1[m][n][cim] = m1[m][n][cim];
  }
  }
  
  /* Updating of covariance matrix s1=a2*s2*a2_herm*/
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    a2_herm[m][n][cre] = a2[n][m][cre];
    a2_herm[m][n][cim] = -1.0 * a2[n][m][cim];
  }
  }
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre] = 0.0;
    m1[m][n][cim] = 0.0;
    s1[m][n][cre] = 0.0;
    s1[m][n][cim] = 0.0;
  }
  }
  /* m1=a2*s2 */
  Prod_HM(a2,s2,4,m1);
  /* s1=m1*a2_herm */
  Prod_HM(m1,a2_herm,4,s1);
  
  /* Updates Sgm */
  Sgm[col][C11]  = s1[0][0][cre];
  Sgm[col][C12_re] = s1[0][1][cre];
  Sgm[col][C12_im] = s1[0][1][cim];
  Sgm[col][C13_re] = s1[0][2][cre];
  Sgm[col][C13_im] = s1[0][2][cim];
  Sgm[col][C14_re] = s1[0][3][cre];
  Sgm[col][C14_im] = s1[0][3][cim];
  Sgm[col][C22]  = s1[1][1][cre];
  Sgm[col][C23_re] = s1[1][2][cre];
  Sgm[col][C23_im] = s1[1][2][cim];
  Sgm[col][C24_re] = s1[1][3][cre];
  Sgm[col][C24_im] = s1[1][3][cim];
  Sgm[col][C33]  = s1[2][2][cre];
  Sgm[col][C34_re] = s1[2][3][cre];
  Sgm[col][C34_im] = s1[2][3][cim];
  Sgm[col][C44]  = s1[3][3][cre];
  Sgm[col][C21_re] = s1[1][0][cre];
  Sgm[col][C21_im] = s1[1][0][cim];
  Sgm[col][C31_re] = s1[2][0][cre];
  Sgm[col][C31_im] = s1[2][0][cim];  
  Sgm[col][C32_re] = s1[2][1][cre];
  Sgm[col][C32_im] = s1[2][1][cim];
  Sgm[col][C41_re] = s1[3][0][cre];
  Sgm[col][C41_im] = s1[3][0][cim];
  Sgm[col][C42_re] = s1[3][1][cre];
  Sgm[col][C42_im] = s1[3][1][cim];
  Sgm[col][C43_re] = s1[3][2][cre];
  Sgm[col][C43_im] = s1[3][2][cim];
  
  free_matrix3d_float(s1,4,4);
  free_matrix3d_float(s2,4,4);
  free_matrix3d_float(m1,4,4);
  free_matrix3d_float(a2_herm,4,4);
}

/*******************************************************************************
Routine  : Prod_HM
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Product of 2 hermitian matrices
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Prod_HM(float ***M1, float ***M2, int dim, float ***Mout)
{
  int m,n,k;
  
  for (m = 0; m < dim; m++){
  for (n = 0; n < dim; n++){
    Mout[m][n][cre] = 0.0;
    Mout[m][n][cim] = 0.0;
  }
  }
  
  for (m = 0; m < dim; m++){
  for (n = 0; n < dim; n++){  
    for (k = 0; k < dim; k++){
    Mout[m][n][cre] += M1[m][k][cre] * M2[k][n][cre] - M1[m][k][cim] * M2[k][n][cim];
    Mout[m][n][cim] += M1[m][k][cre] * M2[k][n][cim] + M1[m][k][cim] * M2[k][n][cre];
    }
  }
  }
}

/*******************************************************************************
Routine  : Gen_A_B
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates the parameters A and B
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Gen_A_B(float **Sgm, int col, float **A, float **B)
{
  A[col][cre] = (Sgm[col][C21_re] + Sgm[col][C31_re]) / 2.0;
  A[col][cim] = (Sgm[col][C21_im] + Sgm[col][C31_im]) / 2.0;
  
  B[col][cre] = (Sgm[col][C24_re] + Sgm[col][C34_re]) / 2.0;
  B[col][cim] = (Sgm[col][C24_im] + Sgm[col][C34_im]) / 2.0;
}

/*******************************************************************************
Routine  : Gen_system
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates the systems to calculate the actualization of u, v, w 
and z
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Gen_system(float **Sgm, float **A, float **B, int col, float **A8x8, float *X)
{
  
  float **zeta_re, **zeta_im, **tau_re, **tau_im;
  int m,n;
  
  zeta_re = matrix_float(4,4);
  zeta_im = matrix_float(4,4);
  tau_re  = matrix_float(4,4);
  tau_im  = matrix_float(4,4);
  
  /* Generates the vector X */
  X[0] = Sgm[col][C21_re] - A[col][cre];
  X[1] = Sgm[col][C31_re] - A[col][cre];
  X[2] = Sgm[col][C24_re] - B[col][cre];
  X[3] = Sgm[col][C34_re] - B[col][cre];
  X[4] = Sgm[col][C21_im] - A[col][cim];
  X[5] = Sgm[col][C31_im] - A[col][cim];
  X[6] = Sgm[col][C24_im] - B[col][cim];
  X[7] = Sgm[col][C34_im] - B[col][cim];
  
  /* Generates the matrix zeta */
  zeta_re[0][0] = 0.0;      zeta_im[0][0] = 0.0; 
  zeta_re[0][1] = 0.0;      zeta_im[0][1] = 0.0;
  zeta_re[0][2] = Sgm[col][C41_re];   zeta_im[0][2] = Sgm[col][C41_im];
  zeta_re[0][3] = Sgm[col][C11];    zeta_im[0][3] = 0.0;
  zeta_re[1][0] = Sgm[col][C11];    zeta_im[1][0] = 0.0; 
  zeta_re[1][1] = Sgm[col][C41_re];  zeta_im[1][1] = Sgm[col][C41_im];
  zeta_re[1][2] = 0.0;      zeta_im[1][2] = 0.0;
  zeta_re[1][3] = 0.0;      zeta_im[1][3] = 0.0;
  zeta_re[2][0] = 0.0;      zeta_im[2][0] = 0.0; 
  zeta_re[2][1] = 0.0;      zeta_im[2][1] = 0.0;
  zeta_re[2][2] = Sgm[col][C44];    zeta_im[2][2] = 0.0;
  zeta_re[2][3] = Sgm[col][C14_re];  zeta_im[2][3] = Sgm[col][C14_im];
  zeta_re[3][0] = Sgm[col][C14_re];   zeta_im[3][0] = Sgm[col][C14_im]; 
  zeta_re[3][1] = Sgm[col][C44];    zeta_im[3][1] = 0.0;
  zeta_re[3][2] = 0.0;      zeta_im[3][2] = 0.0;
  zeta_re[3][3] = 0.0;      zeta_im[3][3] = 0.0;
  
  /* Generates the matrix tau */
  tau_re[0][0] = 0.0;        tau_im[0][0] = 0.0; 
  tau_re[0][1] = Sgm[col][C22];    tau_im[0][1] = 0.0;
  tau_re[0][2] = Sgm[col][C23_re];    tau_im[0][2] = Sgm[col][C23_im];
  tau_re[0][3] = 0.0;      tau_im[0][3] = 0.0;
  tau_re[1][0] = 0.0;      tau_im[1][0] = 0.0; 
  tau_re[1][1] = Sgm[col][C32_re];  tau_im[1][1] = Sgm[col][C32_im];
  tau_re[1][2] = Sgm[col][C33];    tau_im[1][2] = 0.0;
  tau_re[1][3] = 0.0;      tau_im[1][3] = 0.0;
  tau_re[2][0] = Sgm[col][C22];    tau_im[2][0] = 0.0; 
  tau_re[2][1] = 0.0;      tau_im[2][1] = 0.0;
  tau_re[2][2] = 0.0;      tau_im[2][2] = 0.0;
  tau_re[2][3] = Sgm[col][C23_re];  tau_im[2][3] = Sgm[col][C23_im];
  tau_re[3][0] = Sgm[col][C32_re];   tau_im[3][0] = Sgm[col][C32_im]; 
  tau_re[3][1] = 0.0;      tau_im[3][1] = 0.0;
  tau_re[3][2] = 0.0;        tau_im[3][2] = 0.0;
  tau_re[3][3] = Sgm[col][C33];    tau_im[3][3] = 0.0;
  
  /* Generates the matrix A8 */

  /* A8_OO */
  for (m = 0; m < 4; m++)
  for (n = 0; n < 4; n++)
    A8x8[m][n] = zeta_re[m][n] + tau_re[m][n]; 
  
  /* A8_O1 */
  for (m = 0; m < 4; m++)
  for (n = 0; n < 4; n++)
    A8x8[m][n+4] = -1.0 * (zeta_im[m][n] - tau_im[m][n]); 
    
  /* A8_1O */
  for (m = 0; m < 4; m++)
  for (n = 0; n < 4; n++)
    A8x8[m+4][n] = zeta_im[m][n] + tau_im[m][n]; 
  
  /* A8_11 */
  for (m = 0; m < 4; m++)
  for (n = 0; n < 4; n++)
    A8x8[m+4][n+4] = zeta_re[m][n] - tau_re[m][n]; 
}

/*******************************************************************************
Routine  : ludcmp
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Given a matrix a[1..n][1..n], this routine replaces it by the LU 
decomposition of a rowwise permutation of itself. a and n are input. a is output, 
arranged as in equation (2.3.14) above; indx[1..n] is an output vector that records 
the row permutation e.ected by the partial pivoting; d is output as ±1 depending
on whether the number of row interchanges was even or odd, respectively. 
This routine is used in combination with lubksb to solve linear equations
or invert a matrix.
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void ludcmp(float **a, int n, int *indx, float *d)
{
  int i,imax,j,k,singular;
  float big,dum,sum,temp;
  float *vvv;
  
  vvv = vector_float(n);
  singular = 0;
  
  *d = 1.0; 
  for (i = 1;i<=n;i++) { 
  big = 0.0;
  for (j = 1;j<=n;j++)
    if ((temp = fabs(a[i-1][j-1])) > big) big = temp;
  if (big == 0.0){
    printf("Singular matrix in routine ludcmp \n");
    singular = 1;
  }
  vvv[i-1] = 1.0/big; 
  }
  
  if (singular == 0){
  for (j = 1;j<=n;j++) { 
  for (i = 1;i<j;i++) { 
    sum = a[i-1][j-1];
    for (k = 1;k<i;k++) sum -= a[i-1][k-1]*a[k-1][j-1];
    a[i-1][j-1] = sum;
  }
  big = 0.0; 
  for (i = j;i<=n;i++) { 
    sum = a[i-1][j-1];
    for (k = 1;k<j;k++)
    sum -= a[i-1][k-1]*a[k-1][j-1];
    a[i-1][j-1] = sum;
    if ( (dum = vvv[i-1]*fabs(sum)) >= big) {
    big = dum;
    imax = i;
    }
  }
  if (j != imax) { 
    for (k = 1;k<=n;k++) { 
    dum = a[imax-1][k-1];
    a[imax-1][k-1] = a[j-1][k-1];
    a[j-1][k-1] = dum;
    }
    *d  =  -(*d); 
    vvv[imax-1] = vvv[j-1]; 
  }
  indx[j-1] = imax;
  if (a[j-1][j-1] == 0.0) a[j-1][j-1] = 1.0e-20;
  if (j != n) { 
    dum = 1.0/(a[j-1][j-1]);
    for (i = j+1;i<=n;i++) a[i-1][j-1] *= dum;
  }
  }
  }
  else
  for (j = 1;j<=n;j++)  
    for (i = 1;i<j;i++) 
    a[i-1][j-1] = 0.0;
    
  free_vector_float(vvv);
}


/*******************************************************************************
Routine  : ludksp
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Solves the set of n linear equations A·X = B. Here a[1..n][1..n] 
is input, not as the matrix A but rather as its LU decomposition, determined by 
the routine ludcmp. indx[1..n] is input as the permutation vector returned by 
ludcmp. b[1..n] is input as the right-hand side vector B, and returns with the 
solution vector X. a, n, and indx are not modi.ed by this routine and can be left 
in place for successive calls with di.erent right-hand sides b. This routine takes
into account the possibility that b will begin with many zero elements, 
so it is effcient for use in matrix inversion.
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void lubksb(float **a, int n, int *indx, float *b)
{
  int i,ii = 0,ip,j;
  float sum;
  
  for (i = 1;i<=n;i++) { 
  ip = indx[i-1];
  sum = b[ip-1];
  b[ip-1] = b[i-1];
  if (ii)
    for (j = ii;j<=i-1;j++) sum -= a[i-1][j-1]*b[j-1];
  else if (sum) ii = i;  
  b[i-1] = sum;
  }
  for (i = n;i>=1;i--) { 
  sum = b[i-1];
  for (j = i+1;j<=n;j++) sum -= a[i-1][j-1]*b[j-1];
  b[i-1] = sum/a[i-1][i-1]; 
  } 
}

/*******************************************************************************
Routine  : Gen_calibration_matrix
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Generates the calibration matrix
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Gen_calibration_matrix(float ***Cal, int col, float **u_rg, float **v_rg, float **w_rg, float **z_rg, float alpha_re, float alpha_im)
{
  float v1_re, v1_im, v2_re, v2_im, v3_re, v3_im, alpha_inv_re, alpha_inv_im;
  float ***m1, ***a, ***m_tmp;
  int m, n;
  
  m1  = matrix3d_float(4,4,2);
  m_tmp = matrix3d_float(4,4,2);
  a  = matrix3d_float(4,4,2);

  /* Creates the calibration matrix */
  v1_re = 1.0 - (v_rg[col][cre]*z_rg[col][cre] - v_rg[col][cim]*z_rg[col][cim]);
  v1_im = -1.0 * (v_rg[col][cre]*z_rg[col][cim] + v_rg[col][cim]*z_rg[col][cre]);
  v2_re = 1.0 - (w_rg[col][cre]*u_rg[col][cre] - w_rg[col][cim]*u_rg[col][cim]);
  v2_im = -1.0 * (w_rg[col][cre]*u_rg[col][cim] + w_rg[col][cim]*u_rg[col][cre]);
  v3_re = v1_re * v2_re - v1_im * v2_im;
  v3_im = v1_re * v2_im + v1_im * v2_re;
  v2_re = sqrt(AmplitudeComplex_v2(v3_re,v3_im)) * cos(atan2(v3_im,v3_re)/ 2.0);
  v2_im = sqrt(AmplitudeComplex_v2(v3_re,v3_im)) * sin(atan2(v3_im,v3_re)/ 2.0);
  v1_re = (1 / AmplitudeComplex_v2(v2_re,v2_im)) * cos(-1.0 * atan2(v2_im,v2_re));
  v1_im = (1 / AmplitudeComplex_v2(v2_re,v2_im)) * sin(-1.0 * atan2(v2_im,v2_re));

  m1[0][0][cre] = 1.0;                    m1[0][0][cim] = 0.0; 
  m1[0][1][cre] = -1.0*v_rg[col][cre];                      m1[0][1][cim] = -1.0*v_rg[col][cim];
  m1[0][2][cre] = -1.0*w_rg[col][cre];            m1[0][2][cim] = -1.0*w_rg[col][cim];
  m1[0][3][cre] = v_rg[col][cre]*w_rg[col][cre] - v_rg[col][cim]*w_rg[col][cim]; m1[0][3][cim] = v_rg[col][cre]*w_rg[col][cim] + v_rg[col][cim]*w_rg[col][cre];
  m1[1][0][cre] = -1.0*z_rg[col][cre];            m1[1][0][cim] = -1.0*z_rg[col][cim]; 
  m1[1][1][cre] = 1.0;                  m1[1][1][cim] = 0.0;
  m1[1][2][cre] = w_rg[col][cre]*z_rg[col][cre] - w_rg[col][cim]*z_rg[col][cim]; m1[1][2][cim] = w_rg[col][cre]*z_rg[col][cim] + w_rg[col][cim]*z_rg[col][cre];
  m1[1][3][cre] = -1.0*w_rg[col][cre];            m1[1][3][cim] = -1.0*w_rg[col][cim];
  m1[2][0][cre] = -1.0*u_rg[col][cre];            m1[2][0][cim] = -1.0*u_rg[col][cim]; 
  m1[2][1][cre] = u_rg[col][cre]*v_rg[col][cre] - u_rg[col][cim]*v_rg[col][cim]; m1[2][1][cim] = u_rg[col][cre]*v_rg[col][cim] + u_rg[col][cim]*v_rg[col][cre];
  m1[2][2][cre] = 1.0;                m1[2][2][cim] = 0.0;
  m1[2][3][cre] = -1.0*v_rg[col][cre];            m1[2][3][cim] = -1.0*v_rg[col][cim];
  m1[3][0][cre] = u_rg[col][cre]*z_rg[col][cre] - u_rg[col][cim]*z_rg[col][cim]; m1[3][0][cim] = u_rg[col][cre]*z_rg[col][cim] + u_rg[col][cim]*z_rg[col][cre]; 
  m1[3][1][cre] = -1.0*u_rg[col][cre];            m1[3][1][cim] = -1.0*u_rg[col][cim];
  m1[3][2][cre] = -1.0*z_rg[col][cre];            m1[3][2][cim] = -1.0*z_rg[col][cim];
  m1[3][3][cre] = 1.0;                m1[3][3][cim] = 0.0;
  
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre] = m1[m][n][cre] * v1_re - m1[m][n][cim] * v1_im;  
    m1[m][n][cim] = m1[m][n][cre] * v1_im + m1[m][n][cim] * v1_re;
  }
  }
  
  /* Generation of the alpha matrix for updating */
  alpha_inv_re = (1 / AmplitudeComplex_v2(alpha_re,alpha_im)) * cos(-1.0 * atan2(alpha_im,alpha_re));
  alpha_inv_im = (1 / AmplitudeComplex_v2(alpha_re,alpha_im)) * sin(-1.0 * atan2(alpha_im,alpha_re));
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    a[m][n][cre] = 0.0; a[m][n][cim] = 0.0;
  }
  }
  a[0][0][cre] = alpha_inv_re; a[0][0][cim] = alpha_inv_im; 
  a[1][1][cre] = alpha_re; a[1][1][cim] = alpha_im; 
  a[2][2][cre] = alpha_inv_re; a[2][2][cim] = alpha_inv_im; 
  a[3][3][cre] = alpha_re; a[3][3][cim] = alpha_im; 
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m_tmp[m][n][cre] = 0.0; m_tmp[m][n][cim] = 0.0;
  }
  }
  Prod_HM(m1,a,4,m_tmp);
  for (m = 0; m < 4; m++){
  for (n = 0; n < 4; n++){
    m1[m][n][cre] = m_tmp[m][n][cre];
    m1[m][n][cim] = m_tmp[m][n][cim];
  }
  }
  
  Cal[col][0][cre]  = m1[0][0][cre];  Cal[col][0][cim]  = m1[0][0][cim];
  Cal[col][1][cre]  = m1[0][1][cre];  Cal[col][1][cim]  = m1[0][1][cim];
  Cal[col][2][cre]  = m1[0][2][cre];  Cal[col][2][cim]  = m1[0][2][cim];
  Cal[col][3][cre]  = m1[0][3][cre];  Cal[col][3][cim]  = m1[0][3][cim];
  Cal[col][4][cre]  = m1[1][0][cre];  Cal[col][4][cim]  = m1[1][0][cim];
  Cal[col][5][cre]  = m1[1][1][cre];  Cal[col][5][cim]  = m1[1][1][cim];
  Cal[col][6][cre]  = m1[1][2][cre];  Cal[col][6][cim]  = m1[1][2][cim];
  Cal[col][7][cre]  = m1[1][3][cre];  Cal[col][7][cim]  = m1[1][3][cim];
  Cal[col][8][cre]  = m1[2][0][cre];  Cal[col][8][cim]  = m1[2][0][cim];
  Cal[col][9][cre]  = m1[2][1][cre];  Cal[col][9][cim]  = m1[2][1][cim];
  Cal[col][10][cre] = m1[2][2][cre];  Cal[col][10][cim] = m1[2][2][cim];
  Cal[col][11][cre] = m1[2][3][cre];  Cal[col][11][cim] = m1[2][3][cim];
  Cal[col][12][cre] = m1[3][0][cre];  Cal[col][12][cim] = m1[3][0][cim];
  Cal[col][13][cre] = m1[3][1][cre];  Cal[col][13][cim] = m1[3][1][cim];
  Cal[col][14][cre] = m1[3][2][cre];  Cal[col][14][cim] = m1[3][2][cim];
  Cal[col][15][cre] = m1[3][3][cre];  Cal[col][15][cim] = m1[3][3][cim];
  
  free_matrix3d_float(m1,4,4);

}

/*******************************************************************************
Routine  : Data_calibration
Authors  : Carlos LOPEZ - MARTINEZ
Version  : 1.0
Update  :
*-------------------------------------------------------------------------------
Description :  Final Calibration
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void Data_calibration(float ***S,float ***mcal_rg, int num_col)
{
  int col;
  float ***Mcal;

  Mcal = matrix3d_float(4,4,2);

  for (col = 0; col < num_col; col++){
      
  /* Generates the calibration matrix */
  Mcal[0][0][cre] = mcal_rg[col][0][cre];
  Mcal[0][0][cim] = mcal_rg[col][0][cim];
    Mcal[0][1][cre] = mcal_rg[col][1][cre];
  Mcal[0][1][cim] = mcal_rg[col][1][cim];
  Mcal[0][2][cre] = mcal_rg[col][2][cre];
  Mcal[0][2][cim] = mcal_rg[col][2][cim];
  Mcal[0][3][cre] = mcal_rg[col][3][cre];
  Mcal[0][3][cim] = mcal_rg[col][3][cim];
  Mcal[1][0][cre] = mcal_rg[col][4][cre];
  Mcal[1][0][cim] = mcal_rg[col][4][cim];
  Mcal[1][1][cre] = mcal_rg[col][5][cre];
  Mcal[1][1][cim] = mcal_rg[col][5][cim];
  Mcal[1][2][cre] = mcal_rg[col][6][cre];
  Mcal[1][2][cim] = mcal_rg[col][6][cim];
  Mcal[1][3][cre] = mcal_rg[col][7][cre];
  Mcal[1][3][cim] = mcal_rg[col][7][cim];
  Mcal[2][0][cre] = mcal_rg[col][8][cre];
  Mcal[2][0][cim] = mcal_rg[col][8][cim];
  Mcal[2][1][cre] = mcal_rg[col][9][cre];
  Mcal[2][1][cim] = mcal_rg[col][9][cim];
  Mcal[2][2][cre] = mcal_rg[col][10][cre];
  Mcal[2][2][cim] = mcal_rg[col][10][cim];
  Mcal[2][3][cre] = mcal_rg[col][11][cre];
  Mcal[2][3][cim] = mcal_rg[col][11][cim];
  Mcal[3][0][cre] = mcal_rg[col][12][cre];
  Mcal[3][0][cim] = mcal_rg[col][12][cim];
  Mcal[3][1][cre] = mcal_rg[col][13][cre];
  Mcal[3][1][cim] = mcal_rg[col][13][cim];
  Mcal[3][2][cre] = mcal_rg[col][14][cre];
  Mcal[3][2][cim] = mcal_rg[col][14][cim];
  Mcal[3][3][cre] = mcal_rg[col][15][cre];
  Mcal[3][3][cim] = mcal_rg[col][15][cim];
          
  /* Calibration of hh */
  S[hh][1][2*col]    = 0.;
  S[hh][1][2*col + 1]  = 0.;
  S[hh][1][2*col]   += (S[hh][0][2*col] * Mcal[0][0][cre]) - (S[hh][0][2*col + 1] * Mcal[0][0][cim]);
  S[hh][1][2*col + 1] += (S[hh][0][2*col] * Mcal[0][0][cim]) + (S[hh][0][2*col + 1] * Mcal[0][0][cre]);
  S[hh][1][2*col]   += (S[hv][0][2*col] * Mcal[0][1][cre]) - (S[hv][0][2*col + 1] * Mcal[0][1][cim]);
  S[hh][1][2*col + 1] += (S[hv][0][2*col] * Mcal[0][1][cim]) + (S[hv][0][2*col + 1] * Mcal[0][1][cre]);
  S[hh][1][2*col]   += (S[vh][0][2*col] * Mcal[0][2][cre]) - (S[vh][0][2*col + 1] * Mcal[0][2][cim]);
  S[hh][1][2*col + 1] += (S[vh][0][2*col] * Mcal[0][2][cim]) + (S[vh][0][2*col + 1] * Mcal[0][2][cre]);
  S[hh][1][2*col]   += (S[vv][0][2*col] * Mcal[0][3][cre]) - (S[vv][0][2*col + 1] * Mcal[0][3][cim]);
  S[hh][1][2*col + 1] += (S[vv][0][2*col] * Mcal[0][3][cim]) + (S[vv][0][2*col + 1] * Mcal[0][3][cre]);
  
  /* Calibration of hv */
  S[hv][1][2*col]    = 0.;
  S[hv][1][2*col + 1]  = 0.;
  S[hv][1][2*col]   += (S[hh][0][2*col] * Mcal[1][0][cre]) - (S[hh][0][2*col + 1] * Mcal[1][0][cim]);
  S[hv][1][2*col + 1] += (S[hh][0][2*col] * Mcal[1][0][cim]) + (S[hh][0][2*col + 1] * Mcal[1][0][cre]);
  S[hv][1][2*col]   += (S[hv][0][2*col] * Mcal[1][1][cre]) - (S[hv][0][2*col + 1] * Mcal[1][1][cim]);
  S[hv][1][2*col + 1] += (S[hv][0][2*col] * Mcal[1][1][cim]) + (S[hv][0][2*col + 1] * Mcal[1][1][cre]);
  S[hv][1][2*col]   += (S[vh][0][2*col] * Mcal[1][2][cre]) - (S[vh][0][2*col + 1] * Mcal[1][2][cim]);
  S[hv][1][2*col + 1] += (S[vh][0][2*col] * Mcal[1][2][cim]) + (S[vh][0][2*col + 1] * Mcal[1][2][cre]);
  S[hv][1][2*col]   += (S[vv][0][2*col] * Mcal[1][3][cre]) - (S[vv][0][2*col + 1] * Mcal[1][3][cim]);
  S[hv][1][2*col + 1] += (S[vv][0][2*col] * Mcal[1][3][cim]) + (S[vv][0][2*col + 1] * Mcal[1][3][cre]);
  
  /* Calibration of vh */
  S[vh][1][2*col]    = 0.;
  S[vh][1][2*col + 1]  = 0.;
  S[vh][1][2*col]   += (S[hh][0][2*col] * Mcal[2][0][cre]) - (S[hh][0][2*col + 1] * Mcal[2][0][cim]);
  S[vh][1][2*col + 1] += (S[hh][0][2*col] * Mcal[2][0][cim]) + (S[hh][0][2*col + 1] * Mcal[2][0][cre]);
  S[vh][1][2*col]   += (S[hv][0][2*col] * Mcal[2][1][cre]) - (S[hv][0][2*col + 1] * Mcal[2][1][cim]);
  S[vh][1][2*col + 1] += (S[hv][0][2*col] * Mcal[2][1][cim]) + (S[hv][0][2*col + 1] * Mcal[2][1][cre]);
  S[vh][1][2*col]   += (S[vh][0][2*col] * Mcal[2][2][cre]) - (S[vh][0][2*col + 1] * Mcal[2][2][cim]);
  S[vh][1][2*col + 1] += (S[vh][0][2*col] * Mcal[2][2][cim]) + (S[vh][0][2*col + 1] * Mcal[2][2][cre]);
  S[vh][1][2*col]   += (S[vv][0][2*col] * Mcal[2][3][cre]) - (S[vv][0][2*col + 1] * Mcal[2][3][cim]);
  S[vh][1][2*col + 1] += (S[vv][0][2*col] * Mcal[2][3][cim]) + (S[vv][0][2*col + 1] * Mcal[2][3][cre]);
    
  /* Calibration of vv */
  S[vv][1][2*col]    = 0.;
  S[vv][1][2*col + 1]  = 0.;
  S[vv][1][2*col]   += (S[hh][0][2*col] * Mcal[3][0][cre]) - (S[hh][0][2*col + 1] * Mcal[3][0][cim]);
  S[vv][1][2*col + 1] += (S[hh][0][2*col] * Mcal[3][0][cim]) + (S[hh][0][2*col + 1] * Mcal[3][0][cre]);
  S[vv][1][2*col]   += (S[hv][0][2*col] * Mcal[3][1][cre]) - (S[hv][0][2*col + 1] * Mcal[3][1][cim]);
  S[vv][1][2*col + 1] += (S[hv][0][2*col] * Mcal[3][1][cim]) + (S[hv][0][2*col + 1] * Mcal[3][1][cre]);
  S[vv][1][2*col]   += (S[vh][0][2*col] * Mcal[3][2][cre]) - (S[vh][0][2*col + 1] * Mcal[3][2][cim]);
  S[vv][1][2*col + 1] += (S[vh][0][2*col] * Mcal[3][2][cim]) + (S[vh][0][2*col + 1] * Mcal[3][2][cre]);
  S[vv][1][2*col]   += (S[vv][0][2*col] * Mcal[3][3][cre]) - (S[vv][0][2*col + 1] * Mcal[3][3][cim]);
  S[vv][1][2*col + 1] += (S[vv][0][2*col] * Mcal[3][3][cim]) + (S[vv][0][2*col + 1] * Mcal[3][3][cre]);
  }
  
  free_matrix3d_float(Mcal,4,4);
  
}

