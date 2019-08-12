/*******************************************************************************

	File	 : processing.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER, Laurent FERRO-FAMIL
	Version  : 1.0
	Creation : 09/2003
	Update	:

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
  Routines	:
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
  cplx cplx_quadratic_form(cplx **m1,cplx *v2,int nlig,int ncol)

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagProcessing
#define FlagProcessing

#include "PolSARproLib.h"
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
void Fft(float *vect, int nb_pts, int inv);
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

#define ELEM_SWAP(a,b) { register float t=(a); (a)=(b); (b)=t; }
float MedianArray(float array[], int n);

void cplx_mul_mat_val(cplx **m1,float value,cplx **res,int nlig,int ncol);
void cplx_mul_mat_cval(cplx **m1,cplx value,cplx **res,int nlig,int ncol);
void cplx_mul_mat_vect(cplx **m1,float *v2,cplx *res,int nlig,int ncol);
void cplx_mul_mat_cvect(cplx **m1,cplx *v2,cplx *res,int nlig,int ncol);
cplx cplx_quadratic_form(cplx **m1,cplx *v2,int nlig,int ncol);

#endif
