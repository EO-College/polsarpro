/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : processing.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 09/2003
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
Description :  PROCESSING Routines
*-------------------------------------------------------------------------------
Routines  :
void ProductRealMatrix(float **M1, float **M2, float **M3, int N);
void InverseRealMatrix2(float **M, float **IM);
void InverseRealMatrix4(float **HM, float **IHM);
void ProductCmplxMatrix(float ***M1, float ***M2, float ***M3, int N);
void InverseCmplxMatrix2(float ***M, float ***IM);
void DeterminantCmplxMatrix2(float ***M, float *det);
void DeterminantCmplxMatrix3(float ***M, float *det);
void DeterminantCmplxMatrix4(float ***M, float *det);
void InverseHermitianMatrix2(float ***HM, float ***IHM);
float Trace2_HM1xHM2(float ***HM1, float ***HM2);
void ProductHermitianMatrix2(float ***HM1, float ***HM2, float ***HM3);
void DeterminantHermitianMatrix2(float ***HM, float *det);
void InverseHermitianMatrix3(float ***HM, float ***IHM);
float Trace3_HM1xHM2(float ***HM1, float ***HM2);
void DeterminantHermitianMatrix3(float ***HM, float *det);
void InverseHermitianMatrix4(float ***HM, float ***IHM);
void PseudoInverseHermitianMatrix4(float ***HM, float ***IHM);
float Trace4_HM1xHM2(float ***HM1, float ***HM2);
void DeterminantHermitianMatrix4(float ***HM, float *det);
void Fft(float *vect,int nb_pts,int inv);
void Diagonalisation(int MatrixDim, float ***HM, float ***EigenVect, float *EigenVal);
void MinMaxArray2D(float **mat,float *min,float *max,int nlig,int ncol);
void MinMaxContrastMedian(float *mat,float *min,float *max,int Npts);
float MinMaxContrastMedianArray(float array[], int npts);

void cplx_htransp_mat(cplx **mat,cplx **tmat,int nlig, int ncol);
void cplx_mul_mat(cplx **m1,cplx **m2,cplx **res,int nlig,int ncol);
void cplx_diag_mat2(cplx **T,cplx **V,float *L);
void cplx_diag_mat3(cplx **T,cplx **V,float *L);
void cplx_diag_mat6(cplx **T,cplx **V,float *L);
void cplx_inv_mat(cplx **mat,cplx **res);
void cplx_inv_mat2(cplx **mat,cplx **res);

float MedianArray(float array[], int n);

void cplx_mul_mat_val(cplx **m1,float value,cplx **res,int nlig,int ncol);
void cplx_mul_mat_cval(cplx **m1,cplx value,cplx **res,int nlig,int ncol);
void cplx_mul_mat_vect(cplx **m1,float *v2,cplx *res,int nlig,int ncol);
void cplx_mul_mat_cvect(cplx **m1,cplx *v2,cplx *res,int nlig,int ncol);
cplx cplx_quadratic_form(cplx **m1,cplx *v2,int nlig,int ncol);

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"

/*******************************************************************************
Routine  : ProductRealMatrix
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 03/2007
Update  :
*-------------------------------------------------------------------------------
Description :  computes the product of 2 NxN Real Matrices
*-------------------------------------------------------------------------------
Inputs arguments :
M1      : N*N Real Matrix n°1
M2      : N*N Real Matrix n°2
Returned values  :
M3      : N*N Real Matrix n°3 = M1xM2
*******************************************************************************/
void ProductRealMatrix(float **M1, float **M2, float **M3, int N)
{
  int i,j,k;

  for (i = 0; i < N; i++) {
    for (j = 0; j < N; j++) {
      M3[i][j] = 0.;
      for (k = 0; k < N; k++) M3[i][j] += M1[i][k] * M2[k][j];
    }
  }
}

/*******************************************************************************
Routine  : InverseRealMatrix2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2007
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Inverse of a 2x2 Real Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
M      : 2*2*2 Real Matrix
Returned values  :
IM      : 2*2*2 Inverse Real Matrix
*******************************************************************************/
void InverseRealMatrix2(float **M, float **IM)
{
  double det;

  det = M[0][0] * M[1][1] - M[0][1] * M[1][0] + eps;

  IM[0][0] = M[1][1] / det;
  IM[0][1] = -M[0][1] / det;
  IM[1][0] = -M[1][0] / det;
  IM[1][1] = M[0][0] / det;
}

/*******************************************************************************
Routine  : InverseRealMatrix4
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 03/2007
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Inverse of a 4x4 Real Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 4*4 Real Matrix
Returned values  :
IHM     : 4*4 Inverse Real Matrix
*******************************************************************************/
void InverseRealMatrix4(float **HM, float **IHM)
{
  float **A;
  float **B;
  float **C;
  float **D;
  float **Q;
  float **Am1;
  float **Dm1;
  float **Qm1;
  float **Tmp1;
  float **Tmp2;
  int i,j;

  A = matrix_float(2,2);
  B = matrix_float(2,2);
  C = matrix_float(2,2);
  D = matrix_float(2,2);
  Am1 = matrix_float(2,2);
  Dm1 = matrix_float(2,2);
  Q = matrix_float(2,2);
  Qm1 = matrix_float(2,2);
  Tmp1 = matrix_float(2,2);
  Tmp2 = matrix_float(2,2);

  A[0][0] = HM[0][0];
  A[0][1] = HM[0][1];
  A[1][0] = HM[1][0];
  A[1][1] = HM[1][1];
  B[0][0] = HM[0][2];
  B[0][1] = HM[0][3];
  B[1][0] = HM[1][2];
  B[1][1] = HM[1][3];
  C[0][0] = HM[2][0];
  C[0][1] = HM[2][1];
  C[1][0] = HM[3][0];
  C[1][1] = HM[3][1];
  D[0][0] = HM[2][2];
  D[0][1] = HM[2][3];
  D[1][0] = HM[3][2];
  D[1][1] = HM[3][3];

  InverseRealMatrix2(A,Am1);
  InverseRealMatrix2(D,Dm1);

  ProductRealMatrix(B,Dm1,Tmp1,2);
  ProductRealMatrix(Tmp1,C,Tmp2,2);

  for (i = 0; i < 2; i++)
    for (j = 0; j < 2; j++)
      Q[i][j] = A[i][j] - Tmp2[i][j];

  InverseRealMatrix2(Q,Qm1);

  IHM[0][0] = Qm1[0][0];
  IHM[0][1] = Qm1[0][1];
  IHM[1][0] = Qm1[1][0];
  IHM[1][1] = Qm1[1][1];

  ProductRealMatrix(Qm1,B,Tmp1,2);
  ProductRealMatrix(Tmp1,Dm1,Tmp2,2);
  IHM[0][2] = -Tmp2[0][0];
  IHM[0][3] = -Tmp2[0][1];
  IHM[1][2] = -Tmp2[1][0];
  IHM[1][3] = -Tmp2[1][1];
  
  ProductRealMatrix(C,Tmp2,Tmp1,2);
  Tmp1[0][0] = Tmp1[0][0] + 1.;
  Tmp1[1][1] = Tmp1[1][1] + 1.;
  ProductRealMatrix(Dm1,Tmp1,Tmp2,2);

  IHM[2][2] = Tmp2[0][0];
  IHM[2][3] = Tmp2[0][1];
  IHM[3][2] = Tmp2[1][0];
  IHM[3][3] = Tmp2[1][1];
  
  ProductRealMatrix(Dm1,C,Tmp1,2);
  ProductRealMatrix(Tmp1,Qm1,Tmp2,2);

  IHM[2][0] = -Tmp2[0][0];
  IHM[2][1] = -Tmp2[0][1];
  IHM[3][0] = -Tmp2[1][0];
  IHM[3][1] = -Tmp2[1][1];

  free_matrix_float(A,2);
  free_matrix_float(B,2);
  free_matrix_float(C,2);
  free_matrix_float(D,2);
  free_matrix_float(Am1,2);
  free_matrix_float(Dm1,2);
  free_matrix_float(Q,2);
  free_matrix_float(Qm1,2);
  free_matrix_float(Tmp1,2);
  free_matrix_float(Tmp2,2);
  
}


/*******************************************************************************
Routine  : ProductCmplxMatrix
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
void ProductCmplxMatrix(float ***M1, float ***M2, float ***M3, int N)
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
Routine  : InverseCmplxMatrix2
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
void InverseCmplxMatrix2(float ***M, float ***IM)
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
Routine  : DeterminantCmplxMatrix2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2007
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 2x2 Complex Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
M      : 2*2*2 Complex Matrix
Returned values  :
det     : Complex Determinant of the Complex Matrix
*******************************************************************************/
void DeterminantCmplxMatrix2(float ***M, float *det)
{
det[0] = M[0][0][0] * M[1][1][0] - M[0][0][1] * M[1][1][1];
det[0] = det[0] - (M[0][1][0] * M[1][0][0] - M[0][1][1] * M[1][0][1]) + eps;

det[1] = M[0][0][0] * M[1][1][1] + M[0][0][1] * M[1][1][0];
det[1] = det[1] - (M[0][1][0] * M[1][0][1] + M[0][1][1] * M[1][0][0]) + eps;
}

/*******************************************************************************
Routine  : DeterminantCmplxMatrix3
Authors  : Eric POTTIER
Creation : 01/2012
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 3x3 Complex Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
M      : 3*3*2 Complex Matrix
Returned values  :
det     : Complex Determinant of the Complex Matrix
*******************************************************************************/
void DeterminantCmplxMatrix3(float ***M, float *det)
{
float ***T;
float *dett;

T = matrix3d_float(2,2,2);
dett = vector_float(2);

det[0]=0.; det[1]=0.;

T[0][0][0] = M[1][1][0];T[0][0][1] = M[1][1][1];
T[0][1][0] = M[1][2][0];T[0][1][1] = M[1][2][1];
T[1][0][0] = M[2][1][0];T[1][0][1] = M[2][1][1];
T[1][1][0] = M[2][2][0];T[1][1][1] = M[2][2][1];
DeterminantCmplxMatrix2(T, dett);
det[0] = M[0][0][0] * dett[0] - M[0][0][1] * dett[1];
det[1] = M[0][0][0] * dett[1] + M[0][0][1] * dett[0];

T[0][0][0] = M[0][1][0];T[0][0][1] = M[0][1][1];
T[0][1][0] = M[0][2][0];T[0][1][1] = M[0][2][1];
T[1][0][0] = M[2][1][0];T[1][0][1] = M[2][1][1];
T[1][1][0] = M[2][2][0];T[1][1][1] = M[2][2][1];
DeterminantCmplxMatrix2(T, dett);
det[0] -= M[1][0][0] * dett[0] - M[1][0][1] * dett[1];
det[1] -= M[1][0][0] * dett[1] + M[1][0][1] * dett[0];

T[0][0][0] = M[0][1][0];T[0][0][1] = M[0][1][1];
T[0][1][0] = M[0][2][0];T[0][1][1] = M[0][2][1];
T[1][0][0] = M[1][1][0];T[1][0][1] = M[1][1][1];
T[1][1][0] = M[1][2][0];T[1][1][1] = M[1][2][1];
DeterminantCmplxMatrix2(T, dett);
det[0] += M[2][0][0] * dett[0] - M[2][0][1] * dett[1];
det[1] += M[2][0][0] * dett[1] + M[2][0][1] * dett[0];
}

/*******************************************************************************
Routine  : DeterminantCmplxMatrix4
Authors  : Eric POTTIER
Creation : 01/2012
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 4x4 Complex Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
M      : 4*4*2 Complex Matrix
Returned values  :
det     : Complex Determinant of the Complex Matrix
*******************************************************************************/
void DeterminantCmplxMatrix4(float ***M, float *det)
{
float ***T;
float *dett;

T = matrix3d_float(3,3,2);
dett = vector_float(2);

det[0]=0.; det[1]=0.;

T[0][0][0] = M[1][1][0];T[0][0][1] = M[1][1][1];
T[0][1][0] = M[1][2][0];T[0][1][1] = M[1][2][1];
T[0][2][0] = M[1][3][0];T[0][2][1] = M[1][3][1];
T[1][0][0] = M[2][1][0];T[1][0][1] = M[2][1][1];
T[1][1][0] = M[2][2][0];T[1][1][1] = M[2][2][1];
T[1][2][0] = M[2][3][0];T[1][2][1] = M[2][3][1];
T[2][0][0] = M[3][1][0];T[2][0][1] = M[3][1][1];
T[2][1][0] = M[3][2][0];T[2][1][1] = M[3][2][1];
T[2][2][0] = M[3][3][0];T[2][2][1] = M[3][3][1];
DeterminantCmplxMatrix3(T, dett);
det[0] = M[0][0][0] * dett[0] - M[0][0][1] * dett[1];
det[1] = M[0][0][0] * dett[1] + M[0][0][1] * dett[0];

T[0][0][0] = M[0][1][0];T[0][0][1] = M[0][1][1];
T[0][1][0] = M[0][2][0];T[0][1][1] = M[0][2][1];
T[0][2][0] = M[0][3][0];T[0][2][1] = M[0][3][1];
T[1][0][0] = M[2][1][0];T[1][0][1] = M[2][1][1];
T[1][1][0] = M[2][2][0];T[1][1][1] = M[2][2][1];
T[1][2][0] = M[2][3][0];T[1][2][1] = M[2][3][1];
T[2][0][0] = M[3][1][0];T[2][0][1] = M[3][1][1];
T[2][1][0] = M[3][2][0];T[2][1][1] = M[3][2][1];
T[2][2][0] = M[3][3][0];T[2][2][1] = M[3][3][1];
DeterminantCmplxMatrix3(T, dett);
det[0] -= M[1][0][0] * dett[0] - M[1][0][1] * dett[1];
det[1] -= M[1][0][0] * dett[1] + M[1][0][1] * dett[0];

T[0][0][0] = M[0][1][0];T[0][0][1] = M[0][1][1];
T[0][1][0] = M[0][2][0];T[0][1][1] = M[0][2][1];
T[0][2][0] = M[0][3][0];T[0][2][1] = M[0][3][1];
T[1][0][0] = M[1][1][0];T[1][0][1] = M[1][1][1];
T[1][1][0] = M[1][2][0];T[1][1][1] = M[1][2][1];
T[1][2][0] = M[1][3][0];T[1][2][1] = M[1][3][1];
T[2][0][0] = M[3][1][0];T[2][0][1] = M[3][1][1];
T[2][1][0] = M[3][2][0];T[2][1][1] = M[3][2][1];
T[2][2][0] = M[3][3][0];T[2][2][1] = M[3][3][1];
DeterminantCmplxMatrix3(T, dett);
det[0] += M[2][0][0] * dett[0] - M[2][0][1] * dett[1];
det[1] += M[2][0][0] * dett[1] + M[2][0][1] * dett[0];

T[0][0][0] = M[0][1][0];T[0][0][1] = M[0][1][1];
T[0][1][0] = M[0][2][0];T[0][1][1] = M[0][2][1];
T[0][2][0] = M[0][3][0];T[0][2][1] = M[0][3][1];
T[1][0][0] = M[1][1][0];T[1][0][1] = M[1][1][1];
T[1][1][0] = M[1][2][0];T[1][1][1] = M[1][2][1];
T[1][2][0] = M[1][3][0];T[1][2][1] = M[1][3][1];
T[2][0][0] = M[2][1][0];T[2][0][1] = M[2][1][1];
T[2][1][0] = M[2][2][0];T[2][1][1] = M[2][2][1];
T[2][2][0] = M[2][3][0];T[2][2][1] = M[2][3][1];
DeterminantCmplxMatrix3(T, dett);
det[0] -= M[3][0][0] * dett[0] - M[3][0][1] * dett[1];
det[1] -= M[3][0][0] * dett[1] + M[3][0][1] * dett[0];
}

/*******************************************************************************
Routine  : InverseHermitianMatrix2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Inverse of a 2x2 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 2*2*2 Hermitian Matrix
Returned values  :
IHM     : 2*2*2 Inverse Hermitian Matrix
*******************************************************************************/
void InverseHermitianMatrix2(float ***HM, float ***IHM)
{
  double det[2];
  int k, l;

  IHM[0][0][0] = HM[1][1][0];
  IHM[0][0][1] = HM[1][1][1];

  IHM[0][1][0] = -HM[0][1][0];
  IHM[0][1][1] = -HM[0][1][1];

  IHM[1][0][0] = -HM[1][0][0];
  IHM[1][0][1] = -HM[1][0][1];

  IHM[1][1][0] = HM[0][0][0];
  IHM[1][1][1] = HM[0][0][1];


  det[0] = fabs(HM[0][0][0] * HM[1][1][0] - (HM[0][1][0] * HM[0][1][0] + HM[0][1][1] * HM[0][1][1])) + eps;
  det[1] = 0.;

  for (k = 0; k < 2; k++) {
  for (l = 0; l < 2; l++) {
    IHM[k][l][0] /= det[0];
    IHM[k][l][1] /= det[0];
  }
  }
}

/*******************************************************************************
Routine  : Trace2_HM1xHM2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  computes the trace of the product of 2 2x2 Hermitian Matrices
*-------------------------------------------------------------------------------
Inputs arguments :
HM1      : 2*2*2 Hermitian Matrix n°1
HM2      : 2*2*2 Hermitian Matrix n°2
Returned values  :
trace     : trace of the product
*******************************************************************************/
float Trace2_HM1xHM2(float ***HM1, float ***HM2)
{
  float trace;

  trace = HM1[0][0][0] * HM2[0][0][0] + HM1[1][1][0] * HM2[1][1][0];
  trace =  trace + 2 * (HM1[0][1][0] * HM2[0][1][0] + HM1[0][1][1] * HM2[0][1][1]);

  return trace;
}

/*******************************************************************************
Routine  : ProductHermitianMatrix2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  computes the product of 2 2x2 Hermitian Matrices
*-------------------------------------------------------------------------------
Inputs arguments :
HM1      : 2*2*2 Hermitian Matrix n°1
HM2      : 2*2*2 Hermitian Matrix n°2
Returned values  :
HM3      : 2*2*2 Hermitian Matrix n°3 = HM1xHM2
*******************************************************************************/
void ProductHermitianMatrix2(float ***HM1, float ***HM2, float ***HM3)
{
  int i,j,k;

  for (i = 0; i < 2; i++) {
    for (j = 0; j < 2; j++) {
      HM3[i][j][0] = 0.; HM3[i][j][1] = 0.;
      for (k = 0; k < 2; k++) {
        HM3[i][j][0] += HM1[i][k][0] * HM2[k][j][0] - HM1[i][k][1] * HM2[k][j][1];
        HM3[i][j][1] += HM1[i][k][0] * HM2[k][j][1] + HM1[i][k][1] * HM2[k][j][0];
      }
    }
  }
}

/*******************************************************************************
Routine  : DeterminantHermitianMatrix2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 2x2 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 2*2*2 Hermitian Matrix
Returned values  :
det     : Complex Determinant of the Hermitian Matrix
*******************************************************************************/
void DeterminantHermitianMatrix2(float ***HM, float *det)
{

  det[0] = HM[0][0][0] * HM[1][1][0] - (HM[0][1][0] * HM[0][1][0] + HM[0][1][1] * HM[0][1][1]) + eps;
  det[1] = 0.;

}

/*******************************************************************************
Routine  : InverseHermitianMatrix3
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the Inverse of a 3x3 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 3*3*2 Hermitian Matrix
Returned values  :
IHM     : 3*3*2 Inverse Hermitian Matrix
*******************************************************************************/
void InverseHermitianMatrix3(float ***HM, float ***IHM)
{
  float det[2];
  float re, im;
  int k, l;

  IHM[0][0][0] = (HM[1][1][0] * HM[2][2][0] - HM[1][1][1] * HM[2][2][1]) - (HM[1][2][0] * HM[2][1][0] - HM[1][2][1] * HM[2][1][1]);
  IHM[0][0][1] = (HM[1][1][0] * HM[2][2][1] + HM[1][1][1] * HM[2][2][0]) - (HM[1][2][0] * HM[2][1][1] + HM[1][2][1] * HM[2][1][0]);

  IHM[0][1][0] = -(HM[0][1][0] * HM[2][2][0] - HM[0][1][1] * HM[2][2][1]) + (HM[0][2][0] * HM[2][1][0] - HM[0][2][1] * HM[2][1][1]);
  IHM[0][1][1] = -(HM[0][1][0] * HM[2][2][1] + HM[0][1][1] * HM[2][2][0]) + (HM[0][2][0] * HM[2][1][1] + HM[0][2][1] * HM[2][1][0]);

  IHM[0][2][0] = (HM[0][1][0] * HM[1][2][0] - HM[0][1][1] * HM[1][2][1]) - (HM[1][1][0] * HM[0][2][0] - HM[1][1][1] * HM[0][2][1]);
  IHM[0][2][1] = (HM[0][1][0] * HM[1][2][1] + HM[0][1][1] * HM[1][2][0]) - (HM[1][1][0] * HM[0][2][1] + HM[1][1][1] * HM[0][2][0]);

  IHM[1][0][0] = -(HM[1][0][0] * HM[2][2][0] - HM[1][0][1] * HM[2][2][1]) + (HM[2][0][0] * HM[1][2][0] - HM[2][0][1] * HM[1][2][1]);
  IHM[1][0][1] = -(HM[1][0][0] * HM[2][2][1] + HM[1][0][1] * HM[2][2][0]) + (HM[2][0][0] * HM[1][2][1] + HM[2][0][1] * HM[1][2][0]);

  IHM[1][1][0] = (HM[0][0][0] * HM[2][2][0] - HM[0][0][1] * HM[2][2][1]) - (HM[0][2][0] * HM[2][0][0] - HM[0][2][1] * HM[2][0][1]);
  IHM[1][1][1] = (HM[0][0][0] * HM[2][2][1] + HM[0][0][1] * HM[2][2][0]) - (HM[0][2][0] * HM[2][0][1] + HM[0][2][1] * HM[2][0][0]);

  IHM[1][2][0] = -(HM[0][0][0] * HM[1][2][0] - HM[0][0][1] * HM[1][2][1]) + (HM[0][2][0] * HM[1][0][0] - HM[0][2][1] * HM[1][0][1]);
  IHM[1][2][1] = -(HM[0][0][0] * HM[1][2][1] + HM[0][0][1] * HM[1][2][0]) + (HM[0][2][0] * HM[1][0][1] + HM[0][2][1] * HM[1][0][0]);

  IHM[2][0][0] = (HM[1][0][0] * HM[2][1][0] - HM[1][0][1] * HM[2][1][1]) - (HM[1][1][0] * HM[2][0][0] - HM[1][1][1] * HM[2][0][1]);
  IHM[2][0][1] = (HM[1][0][0] * HM[2][1][1] + HM[1][0][1] * HM[2][1][0]) - (HM[1][1][0] * HM[2][0][1] + HM[1][1][1] * HM[2][0][0]);

  IHM[2][1][0] = -(HM[0][0][0] * HM[2][1][0] - HM[0][0][1] * HM[2][1][1]) + (HM[0][1][0] * HM[2][0][0] - HM[0][1][1] * HM[2][0][1]);
  IHM[2][1][1] = -(HM[0][0][0] * HM[2][1][1] + HM[0][0][1] * HM[2][1][0]) + (HM[0][1][0] * HM[2][0][1] + HM[0][1][1] * HM[2][0][0]);

  IHM[2][2][0] = (HM[0][0][0] * HM[1][1][0] - HM[0][0][1] * HM[1][1][1]) - (HM[0][1][0] * HM[1][0][0] - HM[0][1][1] * HM[1][0][1]);
  IHM[2][2][1] = (HM[0][0][0] * HM[1][1][1] + HM[0][0][1] * HM[1][1][0]) - (HM[0][1][0] * HM[1][0][1] + HM[0][1][1] * HM[1][0][0]);

  det[0] = HM[0][0][0] * IHM[0][0][0] - HM[0][0][1] * IHM[0][0][1] + HM[1][0][0] * IHM[0][1][0] - HM[1][0][1] * IHM[0][1][1] + HM[2][0][0] * IHM[0][2][0] - HM[2][0][1] * IHM[0][2][1];
  det[1] = HM[0][0][0] * IHM[0][0][1] + HM[0][0][1] * IHM[0][0][0] + HM[1][0][0] * IHM[0][1][1] + HM[1][0][1] * IHM[0][1][0] + HM[2][0][0] * IHM[0][2][1] + HM[2][0][1] * IHM[0][2][0];

  for (k = 0; k < 3; k++) {
  for (l = 0; l < 3; l++) {
    re = IHM[k][l][0]; im = IHM[k][l][1];
    IHM[k][l][0] = (re * det[0] + im * det[1]) / (det[0] * det[0] + det[1] * det[1]);
    IHM[k][l][1] = (im * det[0] - re * det[1]) / (det[0] * det[0] + det[1] * det[1]);
  }
  }

}

/*******************************************************************************
Routine  : Trace3_HM1xHM2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  computes the trace of the product of 2 3x3 Hermitian Matrices
*-------------------------------------------------------------------------------
Inputs arguments :
HM1      : 3*3*2 Hermitian Matrix n°1
HM2      : 3*3*2 Hermitian Matrix n°2
Returned values  :
trace     : trace of the product
*******************************************************************************/
float Trace3_HM1xHM2(float ***HM1, float ***HM2)
{
  float trace;

  trace = HM2[0][0][0] * HM1[0][0][0] - HM2[0][0][1] * HM1[0][0][1];
  trace =  trace + HM2[1][1][0] * HM1[1][1][0] - HM2[1][1][1] * HM1[1][1][1];
  trace =  trace + HM2[2][2][0] * HM1[2][2][0] - HM2[2][2][1] * HM1[2][2][1];
  trace =  trace + 2 * (HM2[0][1][0] * HM1[0][1][0] + HM2[0][1][1] * HM1[0][1][1]);
  trace =  trace + 2 * (HM2[0][2][0] * HM1[0][2][0] + HM2[0][2][1] * HM1[0][2][1]);
  trace =  trace + 2 * (HM2[1][2][0] * HM1[1][2][0] + HM2[1][2][1] * HM1[1][2][1]);

  return trace;
}


/*******************************************************************************
Routine  : DeterminantHermitianMatrix3
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 3x3 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 3*3*2 Hermitian Matrix
Returned values  :
det     : Complex Determinant of the Hermitian Matrix
*******************************************************************************/
void DeterminantHermitianMatrix3(float ***HM, float *det)
{
  float IHM[3][3][2];

  IHM[0][0][0] = (HM[1][1][0] * HM[2][2][0] - HM[1][1][1] * HM[2][2][1]) - (HM[1][2][0] * HM[2][1][0] - HM[1][2][1] * HM[2][1][1]);
  IHM[0][0][1] = (HM[1][1][0] * HM[2][2][1] + HM[1][1][1] * HM[2][2][0]) - (HM[1][2][0] * HM[2][1][1] + HM[1][2][1] * HM[2][1][0]);

  IHM[0][1][0] = -(HM[0][1][0] * HM[2][2][0] - HM[0][1][1] * HM[2][2][1]) + (HM[0][2][0] * HM[2][1][0] - HM[0][2][1] * HM[2][1][1]);
  IHM[0][1][1] = -(HM[0][1][0] * HM[2][2][1] + HM[0][1][1] * HM[2][2][0]) + (HM[0][2][0] * HM[2][1][1] + HM[0][2][1] * HM[2][1][0]);

  IHM[0][2][0] = (HM[0][1][0] * HM[1][2][0] - HM[0][1][1] * HM[1][2][1]) - (HM[1][1][0] * HM[0][2][0] - HM[1][1][1] * HM[0][2][1]);
  IHM[0][2][1] = (HM[0][1][0] * HM[1][2][1] + HM[0][1][1] * HM[1][2][0]) - (HM[1][1][0] * HM[0][2][1] + HM[1][1][1] * HM[0][2][0]);

  IHM[1][0][0] = -(HM[1][0][0] * HM[2][2][0] - HM[1][0][1] * HM[2][2][1]) + (HM[2][0][0] * HM[1][2][0] - HM[2][0][1] * HM[1][2][1]);
  IHM[1][0][1] = -(HM[1][0][0] * HM[2][2][1] + HM[1][0][1] * HM[2][2][0]) + (HM[2][0][0] * HM[1][2][1] + HM[2][0][1] * HM[1][2][0]);

  IHM[1][1][0] = (HM[0][0][0] * HM[2][2][0] - HM[0][0][1] * HM[2][2][1]) - (HM[0][2][0] * HM[2][0][0] - HM[0][2][1] * HM[2][0][1]);
  IHM[1][1][1] = (HM[0][0][0] * HM[2][2][1] + HM[0][0][1] * HM[2][2][0]) - (HM[0][2][0] * HM[2][0][1] + HM[0][2][1] * HM[2][0][0]);

  IHM[1][2][0] = -(HM[0][0][0] * HM[1][2][0] - HM[0][0][1] * HM[1][2][1]) + (HM[0][2][0] * HM[1][0][0] - HM[0][2][1] * HM[1][0][1]);
  IHM[1][2][1] = -(HM[0][0][0] * HM[1][2][1] + HM[0][0][1] * HM[1][2][0]) + (HM[0][2][0] * HM[1][0][1] + HM[0][2][1] * HM[1][0][0]);

  IHM[2][0][0] = (HM[1][0][0] * HM[2][1][0] - HM[1][0][1] * HM[2][1][1]) - (HM[1][1][0] * HM[2][0][0] - HM[1][1][1] * HM[2][0][1]);
  IHM[2][0][1] = (HM[1][0][0] * HM[2][1][1] + HM[1][0][1] * HM[2][1][0]) - (HM[1][1][0] * HM[2][0][1] + HM[1][1][1] * HM[2][0][0]);

  IHM[2][1][0] = -(HM[0][0][0] * HM[2][1][0] - HM[0][0][1] * HM[2][1][1]) + (HM[0][1][0] * HM[2][0][0] - HM[0][1][1] * HM[2][0][1]);
  IHM[2][1][1] = -(HM[0][0][0] * HM[2][1][1] + HM[0][0][1] * HM[2][1][0]) + (HM[0][1][0] * HM[2][0][1] + HM[0][1][1] * HM[2][0][0]);

  IHM[2][2][0] = (HM[0][0][0] * HM[1][1][0] - HM[0][0][1] * HM[1][1][1]) - (HM[0][1][0] * HM[1][0][0] - HM[0][1][1] * HM[1][0][1]);
  IHM[2][2][1] = (HM[0][0][0] * HM[1][1][1] + HM[0][0][1] * HM[1][1][0]) - (HM[0][1][0] * HM[1][0][1] + HM[0][1][1] * HM[1][0][0]);

  det[0] = HM[0][0][0] * IHM[0][0][0] - HM[0][0][1] * IHM[0][0][1] + HM[1][0][0] * IHM[0][1][0] - HM[1][0][1] * IHM[0][1][1] + HM[2][0][0] * IHM[0][2][0] - HM[2][0][1] * IHM[0][2][1];
  det[1] = HM[0][0][0] * IHM[0][0][1] + HM[0][0][1] * IHM[0][0][0] + HM[1][0][0] * IHM[0][1][1] + HM[1][0][1] * IHM[0][1][0] + HM[2][0][0] * IHM[0][2][1] + HM[2][0][1] * IHM[0][2][0];
  
  if (det[0] < eps) det[0] = eps;
  if (det[1] < eps) det[1] = eps;

}

/*******************************************************************************
Routine  : InverseHermitianMatrix4
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
void InverseHermitianMatrix4(float ***HM, float ***IHM)
{
  float ***A;
  float ***B;
  float ***C;
  float ***D;
  float ***Q;
  float ***Am1;
  float ***Dm1;
  float ***Qm1;
  float ***Tmp1;
  float ***Tmp2;
  int i,j,k;
  float *det, determinant;

  det = vector_float(2);
  DeterminantHermitianMatrix4(HM, det);
  determinant = sqrt(det[0]*det[0]+det[1]*det[1]);

  if (determinant < 1.E-10) {
    PseudoInverseHermitianMatrix4(HM,IHM);
  } else {

  A = matrix3d_float(2, 2, 2);
  B = matrix3d_float(2, 2, 2);
  C = matrix3d_float(2, 2, 2);
  D = matrix3d_float(2, 2, 2);
  Am1 = matrix3d_float(2, 2, 2);
  Dm1 = matrix3d_float(2, 2, 2);
  Q = matrix3d_float(2, 2, 2);
  Qm1 = matrix3d_float(2, 2, 2);
  Tmp1 = matrix3d_float(2, 2, 2);
  Tmp2 = matrix3d_float(2, 2, 2);

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

  InverseCmplxMatrix2(A,Am1);
  InverseCmplxMatrix2(D,Dm1);

  ProductCmplxMatrix(B,Dm1,Tmp1,2);
  ProductCmplxMatrix(Tmp1,C,Tmp2,2);

  for (i = 0; i < 2; i++)
    for (j = 0; j < 2; j++)
      for (k = 0; k < 2; k++)
        Q[i][j][k] = A[i][j][k] - Tmp2[i][j][k];

  InverseCmplxMatrix2(Q,Qm1);

  IHM[0][0][0] = Qm1[0][0][0];
  IHM[0][0][1] = Qm1[0][0][1];
  IHM[0][1][0] = Qm1[0][1][0];
  IHM[0][1][1] = Qm1[0][1][1];
  IHM[1][0][0] = Qm1[1][0][0];
  IHM[1][0][1] = Qm1[1][0][1];
  IHM[1][1][0] = Qm1[1][1][0];
  IHM[1][1][1] = Qm1[1][1][1];

  ProductCmplxMatrix(Qm1,B,Tmp1,2);
  ProductCmplxMatrix(Tmp1,Dm1,Tmp2,2);

  IHM[0][2][0] = -Tmp2[0][0][0];
  IHM[0][2][1] = -Tmp2[0][0][1];
  IHM[0][3][0] = -Tmp2[0][1][0];
  IHM[0][3][1] = -Tmp2[0][1][1];
  IHM[1][2][0] = -Tmp2[1][0][0];
  IHM[1][2][1] = -Tmp2[1][0][1];
  IHM[1][3][0] = -Tmp2[1][1][0];
  IHM[1][3][1] = -Tmp2[1][1][1];

  ProductCmplxMatrix(C,Tmp2,Tmp1,2);
  Tmp1[0][0][0] = Tmp1[0][0][0] + 1.;
  Tmp1[1][1][0] = Tmp1[1][1][0] + 1.;
  ProductCmplxMatrix(Dm1,Tmp1,Tmp2,2);

  IHM[2][2][0] = Tmp2[0][0][0];
  IHM[2][2][1] = Tmp2[0][0][1];
  IHM[2][3][0] = Tmp2[0][1][0];
  IHM[2][3][1] = Tmp2[0][1][1];
  IHM[3][2][0] = Tmp2[1][0][0];
  IHM[3][2][1] = Tmp2[1][0][1];
  IHM[3][3][0] = Tmp2[1][1][0];
  IHM[3][3][1] = Tmp2[1][1][1];

  ProductCmplxMatrix(Dm1,C,Tmp1,2);
  ProductCmplxMatrix(Tmp1,Qm1,Tmp2,2);

  IHM[2][0][0] = -Tmp2[0][0][0];
  IHM[2][0][1] = -Tmp2[0][0][1];
  IHM[2][1][0] = -Tmp2[0][1][0];
  IHM[2][1][1] = -Tmp2[0][1][1];
  IHM[3][0][0] = -Tmp2[1][0][0];
  IHM[3][0][1] = -Tmp2[1][0][1];
  IHM[3][1][0] = -Tmp2[1][1][0];
  IHM[3][1][1] = -Tmp2[1][1][1];
  
  free_matrix3d_float(A,2,2);
  free_matrix3d_float(B,2,2);
  free_matrix3d_float(C,2,2);
  free_matrix3d_float(D,2,2);
  free_matrix3d_float(Am1,2,2);
  free_matrix3d_float(Dm1,2,2);
  free_matrix3d_float(Q,2,2);
  free_matrix3d_float(Qm1,2,2);
  free_matrix3d_float(Tmp1,2,2);
  free_matrix3d_float(Tmp2,2,2);
  free_vector_float(det);

  }

}

/*******************************************************************************
Routine  : PseudoInverseHermitianMatrix4
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
void PseudoInverseHermitianMatrix4(float ***HM, float ***IHM)
{
  int k,l;
  float ***V;      /* 4*4 eigenvector matrix */
  float ***Vm1;    /* 4*4 eigenvector matrix */
  float ***VL;    /* 4*4 eigenvalue matrix */
  float *lambda;    /* 4 element eigenvalue vector */
  float ***Tmp1;

  V = matrix3d_float(4, 4, 2);
  Vm1 = matrix3d_float(4, 4, 2);
  VL = matrix3d_float(4, 4, 2);
  lambda = vector_float(4);
  Tmp1 = matrix3d_float(4, 4, 2);

  Diagonalisation(4, HM, V, lambda);

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
  ProductCmplxMatrix(Tmp1,Vm1,IHM,4);

  free_matrix3d_float(V, 4, 4);
  free_matrix3d_float(Vm1, 4, 4);
  free_matrix3d_float(VL, 4, 4);
  free_vector_float(lambda);
  free_matrix3d_float(Tmp1, 4, 4);
}

/*******************************************************************************
Routine  : Trace4_HM1xHM2
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  computes the trace of the product of 2 4x4 Hermitian Matrices
*-------------------------------------------------------------------------------
Inputs arguments :
HM1      : 4*4*2 Hermitian Matrix n°1
HM2      : 4*4*2 Hermitian Matrix n°2
Returned values  :
trace     : trace of the product
*******************************************************************************/
float Trace4_HM1xHM2(float ***HM1, float ***HM2)
{
  float trace;

  trace = HM2[0][0][0] * HM1[0][0][0] - HM2[0][0][1] * HM1[0][0][1];
  trace = trace + HM2[1][1][0] * HM1[1][1][0] - HM2[1][1][1] * HM1[1][1][1];
  trace = trace + HM2[2][2][0] * HM1[2][2][0] - HM2[2][2][1] * HM1[2][2][1];
  trace = trace + HM2[3][3][0] * HM1[3][3][0] - HM2[3][3][1] * HM1[3][3][1];
  trace =  trace + 2 * (HM2[0][1][0] * HM1[0][1][0] + HM2[0][1][1] * HM1[0][1][1]);
  trace =  trace + 2 * (HM2[0][2][0] * HM1[0][2][0] + HM2[0][2][1] * HM1[0][2][1]);
  trace = trace + 2 * (HM2[0][3][0] * HM1[0][3][0] + HM2[0][3][1] * HM1[0][3][1]);
  trace =  trace + 2 * (HM2[1][2][0] * HM1[1][2][0] + HM2[1][2][1] * HM1[1][2][1]);
  trace =  trace + 2 * (HM2[1][3][0] * HM1[1][3][0] + HM2[1][3][1] * HM1[1][3][1]);
  trace =  trace + 2 * (HM2[2][3][0] * HM1[2][3][0] + HM2[2][3][1] * HM1[2][3][1]);

  return trace;
}

/*******************************************************************************
Routine  : DeterminantHermitianMatrix4
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the determinant of a 4x4 Hermitian Matrix
*-------------------------------------------------------------------------------
Inputs arguments :
HM      : 4*4*4 Hermitian Matrix
Returned values  :
det      : Complex Determinant of the Hermitian Matrix
*******************************************************************************/
void DeterminantHermitianMatrix4(float ***HM, float *det)
{
  float ***A;
  float ***B;
  float ***C;
  float ***D;
  float ***P;
  float ***Am1;
  float ***Tmp1;
  float ***Tmp2;
  float *det1;
  float *det2;

  int i,j,k;

  A = matrix3d_float(2, 2, 2);
  B = matrix3d_float(2, 2, 2);
  C = matrix3d_float(2, 2, 2);
  D = matrix3d_float(2, 2, 2);
  Am1 = matrix3d_float(2, 2, 2);
  P = matrix3d_float(2, 2, 2);
  Tmp1 = matrix3d_float(2, 2, 2);
  Tmp2 = matrix3d_float(2, 2, 2);
  det1 = vector_float(2);
  det2 = vector_float(2);

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

  InverseCmplxMatrix2(A,Am1);

  ProductCmplxMatrix(C,Am1,Tmp1,2);
  ProductCmplxMatrix(Tmp1,B,Tmp2,2);

  for (i = 0; i < 2; i++)
    for (j = 0; j < 2; j++)
      for (k = 0; k < 2; k++)
        P[i][j][k] = D[i][j][k] - Tmp2[i][j][k];

  DeterminantCmplxMatrix2(A,det1);
  DeterminantCmplxMatrix2(P,det2);

  det[0]=det1[0]*det2[0]-det1[1]*det2[1];
  det[1]=det1[0]*det2[1]+det1[1]*det2[0];

  if (det[0] < eps) det[0] = eps;
  if (det[1] < eps) det[1] = eps;

  free_matrix3d_float(A,2,2);
  free_matrix3d_float(B,2,2);
  free_matrix3d_float(C,2,2);
  free_matrix3d_float(D,2,2);
  free_matrix3d_float(Am1,2,2);
  free_matrix3d_float(P,2,2);
  free_matrix3d_float(Tmp1,2,2);
  free_matrix3d_float(Tmp2,2,2);
  free_vector_float(det1);
  free_vector_float(det2);
}

/*******************************************************************************
Routine  : Fft
Authors  : Eric POTTIER
Creation : 01/1998
Update  :
*-------------------------------------------------------------------------------
Description :  Fast Fourier Transform
*-------------------------------------------------------------------------------
Inputs arguments :
vect  : Input vector
nb_pts  : FFT size
inv   : Direct (+1) /Inverse (-1) Transform

Returned values : Fourier transform of the input vector
void
*******************************************************************************/

void Fft(float *vect, int nb_pts, int inv)
{
  int i, j, ind1, ind2, npt, npt2, bin;
  float reel_0, imag_0, reel_1, imag_1;
  float reel_2, imag_2, reel_3, imag_3;
  float tamp;

/* Entrelacement des donnees d'entree */
  j = 0;
  npt = (int) (nb_pts);
  npt2 = npt / 2;
  for (i = 1; i < npt; i++) {
  ind1 = npt2;
  while (ind1 <= j) {
    j -= ind1;
    ind1 /= 2;
  }
  j += ind1;
  if (i < j) {
    reel_0 = *(vect + (2 * j));
    imag_0 = *(vect + (2 * j) + 1);
    *(vect + (2 * j)) = *(vect + (2 * i));
    *(vect + (2 * j) + 1) = *(vect + (2 * i) + 1);
    *(vect + (2 * i)) = reel_0;
    *(vect + (2 * i) + 1) = imag_0;
  }
  }

  ind1 = 1;
  while (ind1 != npt) {
  ind2 = ind1 * 2;
  reel_0 = 1.0;
  imag_0 = 0.0;
  reel_1 = (float) (cos((float) (pi / ind1)));
  imag_1 = (float) (sin((float) (pi / ind1)));
  for (j = 0; j < ind1; j++) {
    for (i = j; i < npt; i += ind2) {
    reel_2 = *(vect + (2 * i));
    imag_2 = *(vect + (2 * i) + 1);
    bin = i + ind1;
    reel_3 =
      (*(vect + (2 * bin))) * reel_0 -
      (*(vect + (2 * bin) + 1)) * imag_0;
    imag_3 =
      (*(vect + (2 * bin))) * imag_0 +
      (*(vect + (2 * bin) + 1)) * reel_0;
    *(vect + (2 * bin)) = reel_2 - reel_3;
    *(vect + (2 * bin) + 1) = imag_2 - imag_3;
    *(vect + (2 * i)) = reel_2 + reel_3;
    *(vect + (2 * i) + 1) = imag_2 + imag_3;
    }
    tamp = reel_0 * reel_1 + imag_0 * imag_1 * inv;
    imag_0 = reel_1 * imag_0 - imag_1 * reel_0 * inv;
    reel_0 = tamp;
  }
  ind1 = ind2;
  }
/* Normalisation following direct or inverse FFT*/
  if (inv == -1L) {
  tamp = (float) (nb_pts);
  for (i = 0; i < npt; i++) {
    *(vect + (2 * i)) = *(vect + (2 * i)) / tamp;
    *(vect + (2 * i) + 1) = *(vect + (2 * i) + 1) / tamp;
  }
  }
}

/*******************************************************************************
Routine  : diagonalisation
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the eigenvectors and eigenvalues of a N*N hermitian
matrix (with N < 10)
*-------------------------------------------------------------------------------
Inputs arguments :
MatrixDim : Dimension of the Hermitian Matrix (N)
HermitianMatrix : N*N*2 complex hermitian matrix
Returned values  :
EigenVect : N*N*2 complex eigenvector matrix
EigenVal  : N elements eigenvalue real vector
*******************************************************************************/
void Diagonalisation(int MatrixDim, float ***HM, float ***EigenVect, float *EigenVal)
{

  double a[10][10][2], v[10][10][2], d[10], z[10];
  //double b[10];
  double w[2], s[2], c[2], titi[2], gc[2], hc[2];
  double sm, tresh, x, toto, e, f, g, h, r, d1, d2;
  int n, pp, qq;
  int ii, i, j, k;

  n = MatrixDim;
  pp = 0; qq = 0;

  for (i = 1; i < n + 1; i++) {
    for (j = 1; j < n + 1; j++) {
      a[i][j][0] = HM[i - 1][j - 1][0];
      a[i][j][1] = HM[i - 1][j - 1][1];
      v[i][j][0] = 0.;
      v[i][j][1] = 0.;
    }
    v[i][i][0] = 1.;
    v[i][i][1] = 0.;
  }

  for (pp = 1; pp < n + 1; pp++) {
    d[pp] = a[pp][pp][0];
    //b[pp] = d[pp];
    z[pp] = 0.;
  }

  for (ii = 1; ii < 1000 * n * n; ii++) {
    sm = 0.;
    for (pp = 1; pp < n; pp++) {
      for (qq = pp + 1; qq < n + 1; qq++) {
        sm = sm + 2. * sqrt(a[pp][qq][0] * a[pp][qq][0] + a[pp][qq][1] * a[pp][qq][1]);
      }
    }
    sm = sm / (n * (n - 1));
    if (sm < 1.E-16) goto Sortie;
    tresh = 1.E-17;
    if (ii < 4) tresh = (long) 0.2 *sm / (n * n);
    x = -1.E-15;
    for (i = 1; i < n; i++) {
      for (j = i + 1; j < n + 1; j++) {
        toto = sqrt(a[i][j][0] * a[i][j][0] + a[i][j][1] * a[i][j][1]);
        if (x < toto) {
          x = toto;
          pp = i;
          qq = j;
        }
      }
    }
    toto = sqrt(a[pp][qq][0] * a[pp][qq][0] + a[pp][qq][1] * a[pp][qq][1]);
    if (toto > tresh) {
      e = d[pp] - d[qq];
      w[0] = a[pp][qq][0];
      w[1] = a[pp][qq][1];
      g = sqrt(w[0] * w[0] + w[1] * w[1]);
      g = g * g;
      f = sqrt(e * e + 4. * g);
      d1 = e + f;
      d2 = e - f;
      if (fabs(d2) > fabs(d1)) d1 = d2;
      r = fabs(d1) / sqrt(d1 * d1 + 4. * g);
      s[0] = r;
      s[1] = 0.;
      titi[0] = 2. * r / d1;
      titi[1] = 0.;
      c[0] = titi[0] * w[0] - titi[1] * w[1];
      c[1] = titi[0] * w[1] + titi[1] * w[0];
      r = sqrt(s[0] * s[0] + s[1] * s[1]);
      r = r * r;
      h = (d1 / 2. + 2. * g / d1) * r;
      d[pp] = d[pp] - h;
      z[pp] = z[pp] - h;
      d[qq] = d[qq] + h;
      z[qq] = z[qq] + h;
      a[pp][qq][0] = 0.;
      a[pp][qq][1] = 0.;

      for (j = 1; j < pp; j++) {
        gc[0] = a[j][pp][0];
        gc[1] = a[j][pp][1];
        hc[0] = a[j][qq][0];
        hc[1] = a[j][qq][1];
        a[j][pp][0] = c[0] * gc[0] - c[1] * gc[1] - s[0] * hc[0] - s[1] * hc[1];
        a[j][pp][1] = c[0] * gc[1] + c[1] * gc[0] - s[0] * hc[1] + s[1] * hc[0];
        a[j][qq][0] = s[0] * gc[0] - s[1] * gc[1] + c[0] * hc[0] + c[1] * hc[1];
        a[j][qq][1] = s[0] * gc[1] + s[1] * gc[0] + c[0] * hc[1] - c[1] * hc[0];
      }
      for (j = pp + 1; j < qq; j++) {
        gc[0] = a[pp][j][0];
        gc[1] = a[pp][j][1];
        hc[0] = a[j][qq][0];
        hc[1] = a[j][qq][1];
        a[pp][j][0] = c[0] * gc[0] + c[1] * gc[1] - s[0] * hc[0] - s[1] * hc[1];
        a[pp][j][1] = c[0] * gc[1] - c[1] * gc[0] + s[0] * hc[1] - s[1] * hc[0];
        a[j][qq][0] = s[0] * gc[0] + s[1] * gc[1] + c[0] * hc[0] + c[1] * hc[1];
        a[j][qq][1] = -s[0] * gc[1] + s[1] * gc[0] + c[0] * hc[1] - c[1] * hc[0];
      }
      for (j = qq + 1; j < n + 1; j++) {
        gc[0] = a[pp][j][0];
        gc[1] = a[pp][j][1];
        hc[0] = a[qq][j][0];
        hc[1] = a[qq][j][1];
        a[pp][j][0] = c[0] * gc[0] + c[1] * gc[1] - s[0] * hc[0] + s[1] * hc[1];
        a[pp][j][1] = c[0] * gc[1] - c[1] * gc[0] - s[0] * hc[1] - s[1] * hc[0];
        a[qq][j][0] = s[0] * gc[0] + s[1] * gc[1] + c[0] * hc[0] - c[1] * hc[1];
        a[qq][j][1] = s[0] * gc[1] - s[1] * gc[0] + c[0] * hc[1] + c[1] * hc[0];
      }
      for (j = 1; j < n + 1; j++) {
        gc[0] = v[j][pp][0];
        gc[1] = v[j][pp][1];
        hc[0] = v[j][qq][0];
        hc[1] = v[j][qq][1];
        v[j][pp][0] = c[0] * gc[0] - c[1] * gc[1] - s[0] * hc[0] - s[1] * hc[1];
        v[j][pp][1] = c[0] * gc[1] + c[1] * gc[0] - s[0] * hc[1] + s[1] * hc[0];
        v[j][qq][0] = s[0] * gc[0] - s[1] * gc[1] + c[0] * hc[0] + c[1] * hc[1];
        v[j][qq][1] = s[0] * gc[1] + s[1] * gc[0] + c[0] * hc[1] - c[1] * hc[0];
      }
    }
  }

  Sortie:

  for (k = 1; k < n + 1; k++) {
    d[k] = 0;
    for (i = 1; i < n + 1; i++) {
      for (j = 1; j < n + 1; j++) {
        d[k] = d[k] + v[i][k][0] * (HM[i - 1][j - 1][0] * v[j][k][0] - HM[i - 1][j - 1][1] * v[j][k][1]);
        d[k] = d[k] + v[i][k][1] * (HM[i - 1][j - 1][0] * v[j][k][1] + HM[i - 1][j - 1][1] * v[j][k][0]);
      }
    }
  }

  for (i = 1; i < n + 1; i++) {
    for (j = i + 1; j < n + 1; j++) {
      if (d[j] > d[i]) {
        x = d[i];
        d[i] = d[j];
        d[j] = x;
        for (k = 1; k < n + 1; k++) {
          c[0] = v[k][i][0];
          c[1] = v[k][i][1];
          v[k][i][0] = v[k][j][0];
          v[k][i][1] = v[k][j][1];
          v[k][j][0] = c[0];
          v[k][j][1] = c[1];
        }
      }
    }
  }

  for (i = 0; i < n; i++) {
    EigenVal[i] = d[i + 1];
    for (j = 0; j < n; j++) {
      EigenVect[i][j][0] = v[i + 1][j + 1][0];
      EigenVect[i][j][1] = v[i + 1][j + 1][1];
    }
  }

}

/*******************************************************************************
Routine  : MinMaxArray2D
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Return the min and the max values of an array of float
*-------------------------------------------------------------------------------
Inputs arguments :
mat : float array
nlig, ncol : size of the matrix in row and col
Returned values  :
min, max : minimum and maximum values
*******************************************************************************/
void MinMaxArray2D(float **mat,float *min,float *max,int nlig,int ncol)
{
int lig,col;

*max = -INIT_MINMAX;
*min = +INIT_MINMAX;
for(lig=0;lig<nlig;lig++)
  for(col=0;col<ncol;col++) {
    if (my_isfinite(mat[lig][col]) != 0) {
      if(mat[lig][col]>(*max)) *max=mat[lig][col];
      if(mat[lig][col]<(*min)) *min=mat[lig][col];
      }
    }
}

/*******************************************************************************
Routine  : cplx_htransp_mat
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the hermitian transpose of a complex matrix
*-------------------------------------------------------------------------------
Inputs arguments :
mat  : complex matrix
Returned values  :
tmat : complex matrix
*******************************************************************************/
void cplx_htransp_mat(cplx **mat,cplx **tmat,int nlig, int ncol)
{
int lig,col;

for(lig=0;lig<nlig;lig++)
  for(col=0;col<ncol;col++)
    tmat[col][lig]=cconj(mat[lig][col]);
}

/*******************************************************************************
Routine  : cplx_mul_mat
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the multiplication of two complex matrices
*-------------------------------------------------------------------------------
Inputs arguments :
m1  : complex matrix
m2  : complex matrix
Returned values  :
res : complex matrix
*******************************************************************************/
void cplx_mul_mat(cplx **m1,cplx **m2,cplx **res,int nlig,int ncol)
{
int lig,col,k;
cplx cplx0;

cplx0.re=0;
cplx0.im=0;

for(lig=0;lig<nlig;lig++)
  for(col=0;col<ncol;col++) {
    res[lig][col]=cplx0;
    for(k=0;k<nlig;k++) res[lig][col]=cadd(res[lig][col],cmul(m1[lig][k],m2[k][col]));
    }
}


/*******************************************************************************
Routine  : cplx_diag_mat2
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the eigenvectors and eigenvalues of a 2*2 hermitian
matrix (literal expressions)
*-------------------------------------------------------------------------------
Inputs arguments :
T : 2*2 complex hermitian matrix
Returned values  :
V : 2*2 complex eigenvector matrix
L : 2 elements eigenvalue real vector
*******************************************************************************/
void cplx_diag_mat2(cplx **T,cplx **V,float *L)
{

float my_rand,ep2,n,mod,ang;
cplx  z1,z1p,tra,tmp;
cplx  fac0,v1,v2,s1,s2;
cplx  e1,e2,a,b;

/*coherency matrix is [a z1;conj(z1) b]
but each element a b etc can be an m x n array i.e  an image
or part of an image*/

ep2=(T[0][0].re+T[1][1].re)*1e-6+eps;

my_rand = rand()/RAND_MAX*2; z1.re=T[0][1].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z1.im=T[0][1].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z1p.re=T[1][0].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z1p.im=T[1][0].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; a.re=T[0][0].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; a.im=T[0][0].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; b.re=T[1][1].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; b.im=T[1][1].im+ep2*my_rand;

tra.re=(a.re+b.re)/2;
tra.im=(a.im+b.im)/2;

fac0.re=z1.re*z1p.re-z1.im*z1p.im;
fac0.im=z1.re*z1p.im+z1.im*z1p.re;

tmp = cmul(a,b);
s1.re=tmp.re-fac0.re;
s1.im=tmp.im-fac0.im;

tmp = cmul(tra,tra);
s2.re = tmp.re - s1.re;
s2.im = tmp.im - s1.im;
mod = sqrt(s2.re*s2.re+s2.im*s2.im);
ang = atan2(s2.im,s2.re);
s1.re=sqrt(mod)*cos(ang/2.);
s1.im=sqrt(mod)*sin(ang/2.);

e1.re = tra.re+s1.re;
e1.im = tra.im+s1.im;
e2.re = tra.re-s1.re;
e2.im = tra.im-s1.im;

L[0]=e1.re;
L[1]=e2.re;

/*sorting of eigenvalues by amplitude*/
if(L[1]>L[0])
{
tmp.re = L[0]; L[0] = L[1]; L[1] = tmp.re;
}  

/*biggest eigenvector*/
v1.re = 1; v1.im = 0;
v2.re=L[0]-a.re;
v2.im=-a.im;
v2=cdiv(v2,z1);
n=sqrt(v1.re*v1.re+v1.im*v1.im+v2.re*v2.re+v2.im*v2.im);
V[0][0].re=v1.re/(n+eps);V[0][0].im=v1.im/(n+eps);
V[1][0].re=v2.re/(n+eps);V[1][0].im=v2.im/(n+eps);

/*smallest eigenvector*/
v1.re = 1; v1.im = 0;
v2.re=L[1]-a.re;
v2.im=-a.im;
v2=cdiv(v2,z1);
n=sqrt(v1.re*v1.re+v1.im*v1.im+v2.re*v2.re+v2.im*v2.im);
V[0][1].re=v1.re/(n+eps);V[0][1].im=v1.im/(n+eps);
V[1][1].re=v2.re/(n+eps);V[1][1].im=v2.im/(n+eps);

}


/*******************************************************************************
Routine  : cplx_diag_mat3
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the eigenvectors and eigenvalues of a 3*3 hermitian
matrix (literal expressions)
*-------------------------------------------------------------------------------
Inputs arguments :
T : 3*3 complex hermitian matrix
Returned values  :
V : 3*3 complex eigenvector matrix
L : 3 elements eigenvalue real vector
*******************************************************************************/
void cplx_diag_mat3(cplx **T,cplx **V,float *L)
{
float my_rand,ep2,p2,n,mod,ang,tmp;
cplx  z1,z2,z3,z1p,z2p,z3p,tra,tmpc,tmpc1,tmpc2,tmpc3,tmpc4,tmpc5,tmpc6;
cplx  fac0,fac1,fac2,fac3,v1,v2,v3,tr3,pt3,s1,s2,deta;
cplx  e1,e2,e3,a,b,c;
float span;

/*coherency matrix is [a z1 z2;conj(z1) b z3;conj(z2) conj(z3) c]
but each element a b c etc can be an m x n array i.e  an image
or part of an image*/

ep2=(T[0][0].re+T[1][1].re+T[2][2].re)*1e-6+eps;

my_rand = rand()/RAND_MAX*2; z1.re=T[0][1].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z1.im=T[0][1].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z1p.re=T[1][0].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z1p.im=T[1][0].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z2.re=T[0][2].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z2.im=T[0][2].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z2p.re=T[2][0].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z2p.im=T[2][0].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z3.re=T[1][2].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z3.im=T[1][2].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z3p.re=T[2][1].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; z3p.im=T[2][1].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; a.re=T[0][0].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; a.im=T[0][0].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; b.re=T[1][1].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; b.im=T[1][1].im+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; c.re=T[2][2].re+ep2*my_rand;
my_rand = rand()/RAND_MAX*2; c.im=T[2][2].im+ep2*my_rand;

// normalisation
span = a.re+b.re+c.re;
z1.re /=span; z1.im /= span;
z1p.re /=span; z1p.im /= span;
z2.re /=span; z2.im /= span;
z2p.re /=span; z2p.im /= span;
z3.re /=span; z3.im /= span;
z3p.re /=span; z3p.im /= span;
a.re /=span; a.im /= span;
b.re /=span; b.im /= span;
c.re /=span; c.im /= span;


tra.re=(a.re+b.re+c.re)/3;
tra.im=(a.im+b.im+c.im)/3;

fac0.re=z1.re*z1p.re-z1.im*z1p.im+z2.re*z2p.re-z2.im*z2p.im+z3.re*z3p.re-z3.im*z3p.im;

fac0.im=z1.re*z1p.im+z1.im*z1p.re+z2.re*z2p.im+z2.im*z2p.re+z3.re*z3p.im+z3.im*z3p.re;

tmpc1 = cmul(a,b);
tmpc2 = cmul(a,c);
tmpc3 = cmul(b,c);
s1.re=tmpc1.re+tmpc2.re+tmpc3.re-fac0.re;
s1.im=tmpc1.im+tmpc2.im+tmpc3.im-fac0.im;

tmpc1 = cmul(z1,z1p);tmpc1 = cmul(c,tmpc1);
tmpc2 = cmul(z2,z2p);tmpc2 = cmul(b,tmpc2);
tmpc3 = cmul(z3,z3p);tmpc3 = cmul(a,tmpc3);
tmpc4 = cmul(z1,z2p);tmpc4 = cmul(tmpc4,z3);
tmpc5 = cmul(z1p,z2);tmpc5 = cmul(tmpc5,z3p);
tmpc4.re += tmpc5.re; tmpc4.im += tmpc5.im; 
tmpc5 = cmul(a,b); tmpc5 = cmul(tmpc5,c);

deta.re=tmpc5.re-tmpc1.re-tmpc2.re+tmpc4.re-tmpc3.re;
deta.im=tmpc5.im-tmpc1.im-tmpc2.im+tmpc4.im-tmpc3.im;

tmpc1 = cmul(a,a);
tmpc2 = cmul(a,b);
tmpc3 = cmul(b,b);
tmpc4 = cmul(a,c);
tmpc5 = cmul(b,c);
tmpc6 = cmul(c,c);
s2.re=tmpc1.re-tmpc2.re+tmpc3.re-tmpc4.re-tmpc5.re+tmpc6.re+3*fac0.re;
s2.im=tmpc1.im-tmpc2.im+tmpc3.im-tmpc4.im-tmpc5.im+tmpc6.im+3*fac0.im;

tmpc1 = cmul(s1,tra);
tmpc2 = cmul(tra,tra);tmpc2 = cmul(tra,tmpc2);
fac1.re=27*deta.re-27*tmpc1.re+54*tmpc2.re;
fac1.im=27*deta.im-27*tmpc1.im+54*tmpc2.im;

tmpc1 = cmul(fac1,fac1);
tmpc2 = cmul(s2,s2);tmpc2 = cmul(s2,tmpc2);
tmpc3.re = tmpc1.re-4*tmpc2.re;tmpc3.im = tmpc1.im-4*tmpc2.im;
mod = sqrt(tmpc3.re*tmpc3.re+tmpc3.im*tmpc3.im);
ang = atan2(tmpc3.im,tmpc3.re);

tr3.re=fac1.re+sqrt(mod)*cos(ang/2.);
tr3.im=fac1.im+sqrt(mod)*sin(ang/2.);

mod = sqrt(tr3.re*tr3.re+tr3.im*tr3.im);
ang = atan2(tr3.im,tr3.re);

pt3.re=pow(mod,1./3.)*cos(ang/3.);pt3.im=pow(mod,1./3.)*sin(ang/3.);
p2 = pow(2.,1./3.);

fac2.re=1;fac2.im=sqrt(3);
fac3.re=1;fac3.im=-sqrt(3);

tmpc1.re = s2.re*p2+eps;tmpc1.im = s2.im*p2+eps;
tmpc2.re = 3*pt3.re+eps;tmpc2.im = 3*pt3.im+eps; 
tmpc1 = cdiv(tmpc1,tmpc2);
e1.re = tra.re+pt3.re/(3*p2)+tmpc1.re;
e1.im = tra.im+pt3.im/(3*p2)+tmpc1.im;

tmpc1 = cmul(fac2,s2);
tmpc2.re = 3*pt3.re*p2*p2+eps ;tmpc2.im = 3*pt3.im*p2*p2+eps ;
tmpc1 = cdiv(tmpc1,tmpc2);
tmpc2 = cmul(fac3,pt3);
tmpc3.re = tmpc2.re/(6*p2+eps); tmpc3.im = tmpc2.im/(6*p2+eps); 
e2.re = tra.re-tmpc1.re-tmpc3.re;
e2.im = tra.im-tmpc1.im-tmpc3.im;

tmpc1 = cmul(fac3,s2);
tmpc2.re = 3*pt3.re*p2*p2+eps ;tmpc2.im = 3*pt3.im*p2*p2+eps ;
tmpc1 = cdiv(tmpc1,tmpc2);
tmpc2 = cmul(fac2,pt3);
tmpc3.re = tmpc2.re/(6*p2+eps); tmpc3.im = tmpc2.im/(6*p2+eps);
e3.re = tra.re-tmpc1.re-tmpc3.re;
e3.im = tra.im-tmpc1.im-tmpc3.im;

/*
L[0]=sqrt(e1.re*e1.re+e1.im*e1.im);
L[1]=sqrt(e2.re*e2.re+e2.im*e2.im);
L[2]=sqrt(e3.re*e3.re+e3.im*e3.im);
*/

L[0]=e1.re;
L[1]=e2.re;
L[2]=e3.re;

/*sorting of eigenvalues by amplitude*/

if(L[1]>L[0])
{
tmp = L[0]; L[0] = L[1]; L[1] = tmp;
}  
if(L[2]>L[0])
{
tmp = L[0]; L[0] = L[2]; L[2] = tmp;
}  
if(L[2]>L[1])
{
tmp = L[1]; L[1] = L[2]; L[2] = tmp;
}  

/*biggest eigenvector*/
tmpc1.re = b.re-L[0];tmpc1.im = b.im;
tmpc1 = cmul(tmpc1,z2);
tmpc2.re = a.re-L[0];tmpc2.im = a.im;
tmpc2 = cmul(tmpc2,z3);

tmpc.re = tmpc1.re-(z1.re*z3.re-z1.im*z3.im);
tmpc.im = tmpc1.im-(z3.re*z1.im+z3.im*z1.re);
v2.re=tmpc2.re-(z1p.re*z2.re-z1p.im*z2.im);
v2.im=tmpc2.im-(z1p.re*z2.im+z1p.im*z2.re);
v2=cdiv(v2,tmpc);
v1.re = 1; v1.im = 0;
v3.re=(L[0]-a.re-(z1.re*v2.re-z1.im*v2.im));
v3.im=-a.im-(z1.re*v2.im+z1.im*v2.re);
v3=cdiv(v3,z2);

n=sqrt(v1.re*v1.re+v1.im*v1.im+v2.re*v2.re+v2.im*v2.im+v3.re*v3.re+v3.im*v3.im);

V[0][0].re=v1.re/(n+eps);V[0][0].im=v1.im/(n+eps);
V[1][0].re=v2.re/(n+eps);V[1][0].im=v2.im/(n+eps);
V[2][0].re=v3.re/(n+eps);V[2][0].im=v3.im/(n+eps);

/*second eigenvector*/

tmpc1.re = b.re-L[1];tmpc1.im = b.im;
tmpc1 = cmul(tmpc1,z2);
tmpc2.re = a.re-L[1];tmpc2.im = a.im;
tmpc2 = cmul(tmpc2,z3);

tmpc.re = tmpc1.re-(z1.re*z3.re-z1.im*z3.im);
tmpc.im = tmpc1.im-(z3.re*z1.im+z3.im*z1.re);
v2.re=tmpc2.re-(z1p.re*z2.re-z1p.im*z2.im);
v2.im=tmpc2.im-(z1p.re*z2.im+z1p.im*z2.re);
v2=cdiv(v2,tmpc);
v1.re = 1; v1.im = 0;
v3.re=(L[1]-a.re-(z1.re*v2.re-z1.im*v2.im));
v3.im=-a.im-(z1.re*v2.im+z1.im*v2.re);
v3=cdiv(v3,z2);

n=sqrt(v1.re*v1.re+v1.im*v1.im+v2.re*v2.re+v2.im*v2.im+v3.re*v3.re+v3.im*v3.im);

V[0][1].re=v1.re/(n+eps);V[0][1].im=v1.im/(n+eps);
V[1][1].re=v2.re/(n+eps);V[1][1].im=v2.im/(n+eps);
V[2][1].re=v3.re/(n+eps);V[2][1].im=v3.im/(n+eps);

/*smallest eigenvector*/

tmpc1.re = b.re-L[2];tmpc1.im = b.im;
tmpc1 = cmul(tmpc1,z2);
tmpc2.re = a.re-L[2];tmpc2.im = a.im;
tmpc2 = cmul(tmpc2,z3);

tmpc.re = tmpc1.re-(z1.re*z3.re-z1.im*z3.im);
tmpc.im = tmpc1.im-(z3.re*z1.im+z3.im*z1.re);
v2.re=tmpc2.re-(z1p.re*z2.re-z1p.im*z2.im);
v2.im=tmpc2.im-(z1p.re*z2.im+z1p.im*z2.re);
v2=cdiv(v2,tmpc);
v1.re = 1; v1.im = 0;
v3.re=(L[2]-a.re-(z1.re*v2.re-z1.im*v2.im));
v3.im=-a.im-(z1.re*v2.im+z1.im*v2.re);
v3=cdiv(v3,z2);

n=sqrt(v1.re*v1.re+v1.im*v1.im+v2.re*v2.re+v2.im*v2.im+v3.re*v3.re+v3.im*v3.im);

V[0][2].re=v1.re/(n+eps);V[0][2].im=v1.im/(n+eps);
V[1][2].re=v2.re/(n+eps);V[1][2].im=v2.im/(n+eps);
V[2][2].re=v3.re/(n+eps);V[2][2].im=v3.im/(n+eps);

L[0] *= span; L[1] *= span; L[2] *= span; 
}

/*******************************************************************************
Routine  : cplx_inv_mat2
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the inverse of a complex matrix
*-------------------------------------------------------------------------------
Inputs arguments :
mat  : complex matrix
Returned values  :
res  : complex matrix
*******************************************************************************/
void cplx_inv_mat2(cplx **mat,cplx **res)
{
  float det;

  det = mat[0][0].re*mat[1][1].re - (mat[0][1].re*mat[0][1].re+mat[0][1].im*mat[0][1].im);
  det = fabs(det)+eps;

  res[0][0].re = mat[1][1].re/det;
  res[0][0].im = 0;
  res[0][1].re = -mat[0][1].re/det;
  res[0][1].im = -mat[0][1].im/det;
  res[1][0].re =  res[0][1].re;
  res[1][0].im = -res[0][1].im;
  res[1][1].re = mat[0][0].re/det;
  res[1][1].im = 0;
}

/*******************************************************************************
Routine  : cplx_inv_mat
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the inverse of a complex matrix
*-------------------------------------------------------------------------------
Inputs arguments :
mat  : complex matrix
Returned values  :
res  : complex matrix
*******************************************************************************/
void cplx_inv_mat(cplx **mat,cplx **res)
{
  float det;

  det =
  mat[0][0].re*mat[1][1].re*mat[2][2].re
  -mat[0][0].re*(mat[1][2].re*mat[1][2].re+mat[1][2].im*mat[1][2].im)
  -mat[2][2].re*(mat[0][1].re*mat[0][1].re+mat[0][1].im*mat[0][1].im)
  -mat[1][1].re*(mat[0][2].re*mat[0][2].re+mat[0][2].im*mat[0][2].im)
  +2*(mat[0][2].re*(mat[1][2].re*mat[0][1].re-mat[1][2].im*mat[0][1].im)
  +mat[0][2].im*(mat[1][2].re*mat[0][1].im+mat[1][2].im*mat[0][1].re));
  det = fabs(det)+eps;

  res[0][0].re = -(-mat[1][1].re*mat[2][2].re+mat[1][2].re*mat[1][2].re+mat[1][2].im*mat[1][2].im)/det;
  res[0][0].im = 0;
  res[0][1].re = (-mat[2][2].re*mat[0][1].re+mat[0][2].re*mat[1][2].re+mat[0][2].im*mat[1][2].im)/det;
  res[0][1].im = (-mat[2][2].re*mat[0][1].im-mat[0][2].re*mat[1][2].im+mat[0][2].im*mat[1][2].re)/det;
  res[0][2].re = (mat[0][1].re*mat[1][2].re-mat[0][1].im*mat[1][2].im-mat[0][2].re*mat[1][1].re)/det;
  res[0][2].im = (mat[0][1].re*mat[1][2].im+mat[0][1].im*mat[1][2].re-mat[0][2].im*mat[1][1].re)/det;
  res[1][0].re =  res[0][1].re;
  res[1][0].im = -res[0][1].im;
  res[1][1].re = -(-mat[0][0].re*mat[2][2].re+mat[0][2].re*mat[0][2].re+mat[0][2].im*mat[0][2].im)/det;
  res[1][1].im = 0;
  res[1][2].re = -(mat[0][0].re*mat[1][2].re-mat[0][2].re*mat[0][1].re-mat[0][2].im*mat[0][1].im)/det;
  res[1][2].im = -(mat[0][0].re*mat[1][2].im+mat[0][2].re*mat[0][1].im-mat[0][2].im*mat[0][1].re)/det;
  res[2][0].re =  res[0][2].re;
  res[2][0].im = -res[0][2].im;
  res[2][1].re =  res[1][2].re;
  res[2][1].im = -res[1][2].im;
  res[2][2].re = -(-mat[0][0].re*mat[1][1].re+mat[0][1].re*mat[0][1].re+mat[0][1].im*mat[0][1].im)/det;
  res[2][2].im = 0;
}

/*******************************************************************************
Routine  : cplx_diag_mat6
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the eigenvectors and eigenvalues of a 6*6 hermitian
matrix
*-------------------------------------------------------------------------------
Inputs arguments :
T : 6*6 complex hermitian matrix
Returned values  :
V : 6*6 complex eigenvector matrix
L : 6 elements eigenvalue real vector
*******************************************************************************/
void cplx_diag_mat6(cplx **T,cplx **V,float *L)
{

double a[7][7][2],v[7][7][2],d[4];
//double b[7];
double z[7],w[2],s[2],c[2],titi[2],gc[2],hc[2];
double sm,tresh,x,toto,e,f,g,h,r,d1,d2;
double rT[6][6],iT[6][6];
int n,p,q,ii,i,j,k;


for(i=0;i<6;i++)
  for(j=0;j<6;j++) {
    rT[i][j]=(double)T[i][j].re;
    iT[i][j]=(double)T[i][j].im;
    }
n=6;

for (i=1; i<n+1; i++) {
  for (j=1; j<n+1; j++) {
    a[i][j][0]=rT[i-1][j-1];a[i][j][1]=iT[i-1][j-1];
    v[i][j][0]=0.;v[i][j][1]=0.;
    }
  v[i][i][0]=1.;v[i][i][1]=0.;
  }

for (p=1; p<n+1; p++) {
  d[p]=a[p][p][0];
  //b[p]=d[p];
  z[p]=0.;
  }

for (ii=1; ii<1000*n*n; ii++) {
  sm=0.;
  for (p=1; p<n; p++) {
    for (q=p+1; q<n+1; q++) {
      sm=sm+2.*sqrt(a[p][q][0]*a[p][q][0]+a[p][q][1]*a[p][q][1]);
      }
    }
  sm=sm/(n*(n-1));
  if (sm < 1.E-16) goto Sortie;
  tresh=1.E-17;
  if (ii < 4) tresh=(long)0.2*sm/(n*n);
  x= -1.E-15;
  for (i=1; i<n; i++) {
    for (j=i+1; j<n+1; j++) {
      toto=sqrt(a[i][j][0]*a[i][j][0]+a[i][j][1]*a[i][j][1]);
      if (x < toto) {
        x=toto;
        p=i; q=j;
        }
      }
    }
  toto=sqrt(a[p][q][0]*a[p][q][0]+a[p][q][1]*a[p][q][1]);
  if (toto > tresh) {
    e=d[p]-d[q];
    w[0]=a[p][q][0];w[1]=a[p][q][1];
    g=sqrt(w[0]*w[0]+w[1]*w[1]);
    g = g*g;
    f=sqrt(e*e+4.*g);
    d1=e+f;d2=e-f;
    if (fabs(d2) > fabs(d1)) d1=d2;
    r=fabs(d1)/sqrt(d1*d1+4.*g);
    s[0]=r;s[1]=0.;
    titi[0]=2.*r/d1; titi[1]=0.;
    c[0]=titi[0]*w[0]-titi[1]*w[1];
    c[1]=titi[0]*w[1]+titi[1]*w[0];
    r=sqrt(s[0]*s[0]+s[1]*s[1]);
    r=r*r;
    h=(d1/2. + 2.*g/d1)*r;
    d[p]=d[p]-h;
    z[p]=z[p]-h;
    d[q]=d[q]+h;
    z[q]=z[q]+h;
    a[p][q][0]=0.;a[p][q][1]=0.;

    for (j=1; j<p; j++) {
      gc[0]=a[j][p][0];gc[1]=a[j][p][1];
      hc[0]=a[j][q][0];hc[1]=a[j][q][1];
      a[j][p][0] = c[0]*gc[0]-c[1]*gc[1]-s[0]*hc[0]-s[1]*hc[1];
      a[j][p][1] = c[0]*gc[1]+c[1]*gc[0]-s[0]*hc[1]+s[1]*hc[0];
      a[j][q][0] = s[0]*gc[0]-s[1]*gc[1]+c[0]*hc[0]+c[1]*hc[1];
      a[j][q][1] = s[0]*gc[1]+s[1]*gc[0]+c[0]*hc[1]-c[1]*hc[0];
      }
    for (j=p+1; j<q; j++) {
      gc[0]=a[p][j][0];gc[1]=a[p][j][1];
      hc[0]=a[j][q][0];hc[1]=a[j][q][1];
      a[p][j][0] = c[0]*gc[0]+c[1]*gc[1]-s[0]*hc[0]-s[1]*hc[1];
      a[p][j][1] = c[0]*gc[1]-c[1]*gc[0]+s[0]*hc[1]-s[1]*hc[0];
      a[j][q][0] = s[0]*gc[0]+s[1]*gc[1]+c[0]*hc[0]+c[1]*hc[1];
      a[j][q][1] = -s[0]*gc[1]+s[1]*gc[0]+c[0]*hc[1]-c[1]*hc[0];
      }
    for (j=q+1; j<n+1; j++) {
      gc[0]=a[p][j][0];gc[1]=a[p][j][1];
      hc[0]=a[q][j][0];hc[1]=a[q][j][1];
      a[p][j][0] = c[0]*gc[0]+c[1]*gc[1]-s[0]*hc[0]+s[1]*hc[1];
      a[p][j][1] = c[0]*gc[1]-c[1]*gc[0]-s[0]*hc[1]-s[1]*hc[0];
      a[q][j][0] = s[0]*gc[0]+s[1]*gc[1]+c[0]*hc[0]-c[1]*hc[1];
      a[q][j][1] = s[0]*gc[1]-s[1]*gc[0]+c[0]*hc[1]+c[1]*hc[0];
      }
    for (j=1; j<n+1; j++) {
      gc[0]=v[j][p][0];gc[1]=v[j][p][1];
      hc[0]=v[j][q][0];hc[1]=v[j][q][1];
      v[j][p][0] = c[0]*gc[0]-c[1]*gc[1]-s[0]*hc[0]-s[1]*hc[1];
      v[j][p][1] = c[0]*gc[1]+c[1]*gc[0]-s[0]*hc[1]+s[1]*hc[0];
      v[j][q][0] = s[0]*gc[0]-s[1]*gc[1]+c[0]*hc[0]+c[1]*hc[1];
      v[j][q][1] = s[0]*gc[1]+s[1]*gc[0]+c[0]*hc[1]-c[1]*hc[0];
      }
    }
  }

Sortie:

for (k=1; k<n+1; k++) {
  d[k]=0;
  for (i=1; i<n+1; i++) {
    for (j=1; j<n+1; j++) {
      d[k]=d[k]+v[i][k][0]*(rT[i-1][j-1]*v[j][k][0]-iT[i-1][j-1]*v[j][k][1]);
      d[k]=d[k]+v[i][k][1]*(rT[i-1][j-1]*v[j][k][1]+iT[i-1][j-1]*v[j][k][0]);
      }
    }
  }


for (i=1; i<n+1; i++) {
  for (j=i+1; j<n+1; j++) {
    if (d[j]>d[i]) {
      x=d[i];
      d[i]=d[j];
      d[j]=x;
      for (k=1; k<n+1; k++) {
        c[0]=v[k][i][0];c[1]=v[k][i][1];
        v[k][i][0]=v[k][j][0];v[k][i][1]=v[k][j][1];
        v[k][j][0]=c[0];v[k][j][1]=c[1];
        }
      }
    }
  }

for (i=0; i<n; i++) {
  L[i]=(float)d[i+1];
  for (j=0; j<n; j++) {
    V[i][j].re=(float)v[i+1][j+1][0];V[i][j].im=(float)v[i+1][j+1][1];
    }
  }
}

/*******************************************************************************
Routine  : MedianArray
Authors  : 
  This Quickselect routine is based on the algorithm described in
  "Numerical recipes in C", Second Edition,
  Cambridge University Press, 1992, Section 8.5, ISBN 0-521-43108-5
  This code by Nicolas Devillard - 1998. Public domain.
Creation : 11/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the median value of an array of size n
*-------------------------------------------------------------------------------
Inputs arguments :
arr : float array
n : size of the array
Returned values  :
median : median value
*******************************************************************************/
float MedianArray(float array[], int n)
{
  int low, high ;
  int median, npts;
  int middle, ll, hh;
  float medianval;
  float *arr;
  
  arr = vector_float(n);
  npts = 0;
  /* Check NaN and Inf values */
  for (ll = 0; ll < n; ll++) {
    if (my_isfinite(array[ll]) != 0) {
      arr[npts] = array[ll];
      npts++;
      }
    }

  low = 0 ; high = npts-1 ; median = (low + high) / 2;
  for (;;) {
    if (high <= low) {/* One element only */
      if (npts & 1) {
        medianval = arr[median];
        } else {
        medianval = (arr[median]+arr[median+1])/2;
        }
      return medianval ;
      }

    if (high == low + 1) {  /* Two elements only */
      if (arr[low] > arr[high])
        ELEM_SWAP(arr[low], arr[high]) ;
      if (npts & 1) {
        medianval = arr[median];
        } else {
        medianval = (arr[median]+arr[median+1])/2;
        }
      return medianval ;
    }

  /* Find median of low, middle and high items; swap into position low */
  middle = (low + high) / 2;
  if (arr[middle] > arr[high])  ELEM_SWAP(arr[middle], arr[high]) ;
  if (arr[low] > arr[high])    ELEM_SWAP(arr[low], arr[high]) ;
  if (arr[middle] > arr[low])   ELEM_SWAP(arr[middle], arr[low]) ;

  /* Swap low item (now in position middle) into position (low+1) */
  ELEM_SWAP(arr[middle], arr[low+1]) ;

  /* Nibble from each end towards middle, swapping items when stuck */
  ll = low + 1;
  hh = high;
  for (;;) {
    do ll++; while (arr[low] > arr[ll]) ;
    do hh--; while (arr[hh]  > arr[low]) ;

    if (hh < ll)
    break;

    ELEM_SWAP(arr[ll], arr[hh]) ;
  }

  /* Swap middle item (in position low) back into correct position */
  ELEM_SWAP(arr[low], arr[hh]) ;

  /* Re-set active partition */
  if (hh <= median) low = ll;
  if (hh >= median) high = hh - 1;
  
  }
  free_vector_float(arr);
}

/********************************************************************
Routine  : MinMaxContrastMedian
Authors  : Eric POTTIER
Creation : 07/2011
Update  :
*--------------------------------------------------------------------
Description :  Return the min and the max values of an array of float
*--------------------------------------------------------------------
Inputs arguments :
mat : float array
nlig, ncol : size of the matrix in row and col
Returned values  :
min, max : minimum and maximum values
********************************************************************/
void MinMaxContrastMedian(float *mat,float *min,float *max,int Npts)
{
  float maxmax, minmin;
  float median, median0;
  float xx;
  int ii,nn,npts,nnpts;
  float *array;

  array = vector_float(Npts);
  *min = INIT_MINMAX; *max = -*min;
  minmin = INIT_MINMAX; maxmax = -minmin;

  for(nn=0;nn<Npts;nn++) {
    if (my_isfinite(mat[nn]) != 0.) {
      if (mat[nn] < minmin) minmin = mat[nn];
      if (mat[nn] > maxmax) maxmax = mat[nn];
      }
    }
  nnpts = 0;
  /* Check NaN and Inf values */
  for(nn=0;nn<Npts;nn++) {
    if (my_isfinite(mat[nn]) != 0) {
      array[nnpts] = mat[nn];
      nnpts++;
      }
    }
  median0 = MinMaxContrastMedianArray(array, nnpts);
  
  /*Recherche Valeur Min*/
  median = median0;
  *min = median0;
  for (ii=0; ii<3; ii++) {
    npts=-1;
    for(nn=0;nn<Npts;nn++) {
      if (median0 == minmin) {
        if (mat[nn] <= median) {
          npts++;
          xx = mat[npts];
          mat[npts]=mat[nn];
          mat[nn] = xx;
          }
        } else {
        if (mat[nn] < median) {
          npts++;
          xx = mat[npts];
          mat[npts]=mat[nn];
          mat[nn] = xx;
          }
        }
      }
    nnpts = 0;
    /* Check NaN and Inf values */
    for(nn=0;nn<npts;nn++) {
      if (my_isfinite(mat[nn]) != 0) {
        array[nnpts] = mat[nn];
        nnpts++;
        }
      }
    median = MinMaxContrastMedianArray(array, nnpts);
    if (median == minmin) median = *min;
    *min = median;
    }

  /*Recherche Valeur Max*/
  median = median0;
  *max = median0;
  for (ii=0; ii<3; ii++) {
    npts=-1;
    for(nn=0;nn<Npts;nn++) {
      if (median0 == maxmax) {
        if (mat[nn] >= median) {
          npts++;
          xx = mat[npts];
          mat[npts]=mat[nn];
          mat[nn] = xx;
          }
        } else {
        if (mat[nn] > median) {
          npts++;
          xx = mat[npts];
          mat[npts]=mat[nn];
          mat[nn] = xx;
          }
        }
      }
    nnpts = 0;
    /* Check NaN and Inf values */
    for(nn=0;nn<npts;nn++) {
      if (my_isfinite(mat[nn]) != 0) {
        array[nnpts] = mat[nn];
        nnpts++;
        }
      }
    median = MinMaxContrastMedianArray(array, nnpts);
    if (median == maxmax) median = *max;
    *max = median;
    }
  free_vector_float(array);
}

/*******************************************************************************
Routine  : MinMaxContrastMedianArray
Authors  : 
  This Quickselect routine is based on the algorithm described in
  "Numerical recipes in C", Second Edition,
  Cambridge University Press, 1992, Section 8.5, ISBN 0-521-43108-5
  This code by Nicolas Devillard - 1998. Public domain.
Creation : 11/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the median value of an array of size n
*-------------------------------------------------------------------------------
Inputs arguments :
arr : float array
n : size of the array
Returned values  :
median : median value
*******************************************************************************/
float MinMaxContrastMedianArray(float arr[], int npts)
{
  int low, high ;
  int median;
  int middle, ll, hh;
  float medianval;
 
  low = 0 ; high = npts-1 ; median = (low + high) / 2;
  for (;;) {
    if (high <= low) {/* One element only */
      if (npts & 1) {
        medianval = arr[median];
        } else {
        medianval = (arr[median]+arr[median+1])/2;
        }
      return medianval ;
      }

    if (high == low + 1) {  /* Two elements only */
      if (arr[low] > arr[high])
        ELEM_SWAP(arr[low], arr[high]) ;
      if (npts & 1) {
        medianval = arr[median];
        } else {
        medianval = (arr[median]+arr[median+1])/2;
        }
      return medianval ;
    }

  /* Find median of low, middle and high items; swap into position low */
  middle = (low + high) / 2;
  if (arr[middle] > arr[high])  ELEM_SWAP(arr[middle], arr[high]) ;
  if (arr[low] > arr[high])    ELEM_SWAP(arr[low], arr[high]) ;
  if (arr[middle] > arr[low])   ELEM_SWAP(arr[middle], arr[low]) ;

  /* Swap low item (now in position middle) into position (low+1) */
  ELEM_SWAP(arr[middle], arr[low+1]) ;

  /* Nibble from each end towards middle, swapping items when stuck */
  ll = low + 1;
  hh = high;
  for (;;) {
    do ll++; while (arr[low] > arr[ll]) ;
    do hh--; while (arr[hh]  > arr[low]) ;

    if (hh < ll)
    break;

    ELEM_SWAP(arr[ll], arr[hh]) ;
  }

  /* Swap middle item (in position low) back into correct position */
  ELEM_SWAP(arr[low], arr[hh]) ;

  /* Re-set active partition */
  if (hh <= median) low = ll;
  if (hh >= median) high = hh - 1;
  }
}

/*******************************************************************************
Routine  : cplx_mul_mat_val
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the multiplication of a complex matrice with
               a float value
*-------------------------------------------------------------------------------
Inputs arguments :
m1  : complex matrix
m2  : float value
Returned values  :
res : complex matrix
*******************************************************************************/
void cplx_mul_mat_val(cplx **m1,float value,cplx **res,int nlig,int ncol)
{
int lig,col;
cplx cplx0;

cplx0.re=value;
cplx0.im=0;

for(lig=0;lig<nlig;lig++)
  for(col=0;col<ncol;col++) {
    res[lig][col] = cmul(m1[lig][col],cplx0);
    }
}

/*******************************************************************************
Routine  : cplx_mul_mat_cval
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the multiplication of a complex matrice with
               a complex value
*-------------------------------------------------------------------------------
Inputs arguments :
m1  : complex matrix
m2  : float value
Returned values  :
res : complex matrix
*******************************************************************************/
void cplx_mul_mat_cval(cplx **m1,cplx value,cplx **res,int nlig,int ncol)
{
int lig,col;

for(lig=0;lig<nlig;lig++)
  for(col=0;col<ncol;col++) {
    res[lig][col] = cmul(m1[lig][col],value);
    }
}


/*******************************************************************************
Routine  : cplx_mul_mat_vect
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the multiplication of a complex matrix with
               a float vector
*-------------------------------------------------------------------------------
Inputs arguments :
m1  : complex matrix (nlig, ncol)
v2  : float vector (ncol,1)
Returned values  :
res : complex vector (nlig,1)
*******************************************************************************/
void cplx_mul_mat_vect(cplx **m1,float *v2,cplx *res,int nlig,int ncol)
{
int lig,k;
cplx cplx0;
cplx *v;

v = cplx_vector(ncol);
for(k=0;k<ncol;k++) {
  v[k].re = v2[k];
  v[k].im = 0.;
  }
  
cplx0.re=0;
cplx0.im=0;

for(lig=0;lig<nlig;lig++) {
  res[lig]=cplx0;
  for(k=0;k<ncol;k++) res[lig]=cadd(res[lig],cmul(m1[lig][k],v[k]));
  }
}

/*******************************************************************************
Routine  : cplx_mul_mat_cvect
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the multiplication of a complex matrix with
               a complex vector
*-------------------------------------------------------------------------------
Inputs arguments :
m1  : complex matrix (nlig, ncol)
v2  : complex vector (ncol,1)
Returned values  :
res : complex vector (nlig,1)
*******************************************************************************/
void cplx_mul_mat_cvect(cplx **m1,cplx *v2,cplx *res,int nlig,int ncol)
{
int lig,k;
cplx cplx0;

cplx0.re=0;
cplx0.im=0;

for(lig=0;lig<nlig;lig++) {
  res[lig]=cplx0;
  for(k=0;k<ncol;k++) res[lig]=cadd(res[lig],cmul(m1[lig][k],v2[k]));
  }
}


/*******************************************************************************
Routine  : cplx_quadratic_form
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Computes the quadratic form XtQX of a complex matrix
               with a complex vector
*-------------------------------------------------------------------------------
Inputs arguments :
m1  : complex matrix (nlig, ncol)
v2  : complex vector (ncol,1)
Returned values  :
res : complex value
*******************************************************************************/
cplx cplx_quadratic_form(cplx **m1,cplx *v2,int nlig,int ncol)
{
int lig,k;
cplx cplx0, res;
cplx *v;

v = cplx_vector(ncol);

cplx0.re=0;
cplx0.im=0;

for(lig=0;lig<nlig;lig++) {
  v[lig]=cplx0;
  for(k=0;k<ncol;k++) v[lig]=cadd(v[lig],cmul(m1[lig][k],v2[k]));
  }
for(lig=0;lig<nlig;lig++) {
  res=cplx0;
  for(k=0;k<ncol;k++) res=cadd(res,cmul(cconj(v2[k]),v[k]));
  }
return res;
}
