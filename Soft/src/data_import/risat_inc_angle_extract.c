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

File   : risat_inc_angle_extract.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 06/2013 - 03/2014
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

Description :  Extract RISAT Incidence Angle File

Routine adapted from a program provided by Dr Y.S. Rao
(ysrao@csre.iitb.ac.in)

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

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void nrerror(char error_text[]);
float **fmatrix(int nrow,int ncol);
double **dmatrix(int nrow,int ncol);
void free_fmatrix(float **m, int nrows, int ncols);
void free_dmatrix(double **m, int nrows, int ncols);
float **getofffile(FILE *inp_ptr, int *Nobs, int *grid_int);
void solvechol(double **A, int N, double **B);
void choles(double **A, int N);
void invertchol(double **A, int N);
double **matTxmat(double **mat1, int rows, int cols, double **mat2, int m, int n);
double **matxmatT(double **mat1, int rows, int cols, double **mat2, int m, int n);
double **mat_mult(double **A, int rows, int cols, double **B, int m, int n);
double **mat_sub(double **A, int rows, int cols, double **B, int m, int n);
double **mat_copy(double **A, int rows, int cols);
double **mat_unit(int rows, int cols);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
/* ACCESS FILE */
  FILE *gridfile;
  char file_name[FilePathLength];

  int ii, jj;
  int NligFin, NcolFin;

  int DEGREE =2;
  int Nunc=DEGREE+1;
  int Nobs, Nobs_t, Ngrid, index;
  float fam;

  double **Qx_unit, **Qx_diff, **Qx_hat;
  double **eP_hat, **rhsP, **Qx_hat_mul;
  double **yP, **A, **pix, pix_t;
  double **N;
  double **Qy_hat,  **yP_hat, **Qy_hat_tem;
  float **data;
  float *incangle;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nrisat_inc_angle_extract.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input RISAT file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&NligFin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&NcolFin,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(file_name);
  check_dir(out_dir);

  incangle=vector_float(NcolFin);  

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);
  
/********************************************************************
********************************************************************/

  if ((gridfile=fopen(file_name,"r")) == NULL)
  edit_error("Could not open input file : ", file_name);
  rewind(gridfile);

  data=getofffile(gridfile, &Nobs_t, &Ngrid);
  Nobs=Nobs_t;
  fclose(gridfile);
   
/********************************************************************
********************************************************************/
  /* Memory assignment */
  yP=dmatrix(Nobs,1);
  A=dmatrix(Nobs,Nunc);
  pix=dmatrix(Nobs,1); pix[0][0]=0.0;

  eP_hat=dmatrix(Nobs,1);
  rhsP=dmatrix(Nunc,1);

  Qx_hat=dmatrix(Nunc,Nunc);
  Qx_hat_mul=dmatrix(Nunc,Nunc);
  Qx_unit=dmatrix(Nunc,Nunc);
  Qx_diff=dmatrix(Nunc,Nunc);

  N=dmatrix(Nunc,Nunc);

  Qy_hat=dmatrix(Nobs, Nobs);
  Qy_hat_tem=dmatrix(Nunc, Nobs);
  yP_hat=dmatrix(Nobs,1);

/********************************************************************
********************************************************************/
  for(ii=1; ii<Nobs; ii++) pix[ii][0]=ii*Ngrid-1;
  
  for(ii=0; ii<Nobs; ii++) {
    yP[ii][0]= data[ii][0];
    index=0;
    for(jj=0; jj<=DEGREE; jj++) {
      pix_t=pix[ii][0];
      A[ii][index]=pow(pix_t,(double)(jj));
      if((pix[ii][0]==0.0)&&(jj==0)) A[ii][index]=1.0;
      index++;
      }
    }

/********************************************************************
********************************************************************/

  N=matTxmat(A,Nobs,Nunc, A, Nobs, Nunc); // 6x6 by ttrix
  rhsP=matTxmat(A,Nobs,Nunc,yP,Nobs,1); //6x1 matrix with P
  Qx_hat = mat_copy(N,Nunc,Nunc);
  choles(Qx_hat,Nunc);
  solvechol(Qx_hat,Nunc,rhsP);
  invertchol(Qx_hat, Nunc);

/********************************************************************
********************************************************************/

  for(ii=0; ii<Nunc; ii++) for(jj=0; jj<ii; jj++) Qx_hat[jj][ii]=Qx_hat[ii][jj];

  Qx_hat_mul=mat_mult(N,Nunc,Nunc,Qx_hat,Nunc,Nunc);
  Qx_unit = mat_unit(Nunc,Nunc);
  Qx_diff = mat_sub(Qx_hat_mul, Nunc, Nunc, Qx_unit, Nunc, Nunc);

  Qy_hat_tem=matxmatT(Qx_hat,Nunc, Nunc, A, Nobs, Nunc);
  Qy_hat=mat_mult(A,Nobs, Nunc, Qy_hat_tem, Nunc, Nobs);
  yP_hat = mat_mult(A, Nobs, Nunc, rhsP,  Nunc, 1);
  eP_hat = mat_sub(yP, Nobs, 1, yP_hat, Nobs, 1);

/********************************************************************
********************************************************************/
  /* Calculate angles at all pixels */
  for(ii=0; ii<NcolFin; ii++) {
    fam=(float)ii;
    incangle[ii]=rhsP[0][0]+rhsP[1][0]*fam+rhsP[2][0]*fam*fam;
    }
  
/********************************************************************
********************************************************************/
  sprintf(file_name, "%s%s", out_dir, "incidence_angle.bin");
  if ((gridfile = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  for(ii=0; ii<NligFin; ii++)
    fwrite(&incangle[0], sizeof(float), NcolFin, gridfile);
  fclose(gridfile);

/********************************************************************
********************************************************************/

  free_dmatrix(eP_hat, Nobs,1);
  free_dmatrix(Qx_hat,Nunc,Nunc);
  free_dmatrix(Qx_hat_mul,Nunc,Nunc);
  free_dmatrix(Qx_unit,Nunc,Nunc);
  free_dmatrix(Qx_diff,Nunc,Nunc);
  free_dmatrix(yP, Nobs,1);
  free_dmatrix(A,Nobs, Nunc);
  free_dmatrix(N,Nunc,Nunc);
  free_dmatrix(Qy_hat,Nobs,Nobs);
  free_dmatrix(Qy_hat_tem,Nunc, Nobs);
  free_dmatrix(yP_hat,Nobs,1);
  free_dmatrix(rhsP, Nunc,1);
  free_dmatrix(pix,Nobs,1);

  return 1;
  
}//Main()

//*********************************************************
//*********************************************************

void nrerror(char error_text[])
/* Numerical Recipes standard error handler */
{
  printf("Numerical Recipes run-time error...\n");
  printf("%s\n",error_text);
  printf("...now exiting to system...\n");
  exit(1);
}

/* ********************** fmatrix NRC routine ********************* */
float **fmatrix(int nrow,int ncol)
{
  int i;
  float **m;
  /* allocate pointers to rows */
  m=(float **) malloc(nrow*sizeof(float*));
  if (!m) nrerror("allocation failure 1 in matrix()");
  /* allocate rows and set pointers to them */
  for(i=0; i<nrow; i++) {
    m[i]=(float *) malloc(ncol*sizeof(float));
    if (!m[i]) nrerror("allocation failure 2 in matrix()");
    }
  /* return pointer to array of pointers to rows */
  return m;
}

/* ************************** double matrix NRC routine ****** */
double **dmatrix(int nrow,int ncol)
{
  int i;
  double **m;
  /* allocate pointers to rows */
  m=(double **) malloc(nrow*sizeof(double*));
  if (!m) nrerror("allocation failure 1 in matrix()");
  /* allocate rows and set pointers to them */
  for(i=0; i<nrow; i++) {
    m[i]=(double *) malloc(ncol*sizeof(double));
    if (!m[i]) nrerror("allocation failure 2 in matrix()");
    }
  /* return pointer to array of pointers to rows */
  return m;
}

/********* Free one dimentional float matrix ***********/
void free_fmatrix(float **m, int nrows, int ncols)
{
  int i;
  for(i=(nrows-1); i>=0; i--) free((float *) (m[i]));
  free((float*) m);
}

/*****************Free one dimentional double matrix****/
void free_dmatrix(double **m, int nrows, int ncols)
{
  int i;
  for(i=(nrows-1); i>=0; i--) free((double *) (m[i]));
  free((double*) m);
}

//*********************************************************
//*********************************************************
float **getofffile(FILE *inp_ptr, int *Nobs, int *grid_int)
{
  int i, N_temp;
  float **data;
  char ch1[50], ch2[50], ch3[50], ch4[50], ch5[50],ch6[50];

  fscanf(inp_ptr, "%s %s %s %s %s %s", ch1, ch2, ch3, ch4, ch5, ch6); //records
  fscanf(inp_ptr, "%s %s %s %s %s %s", ch1, ch2, ch3, ch4, ch5, ch6); //samples
  *Nobs=atoi(ch6);
  fscanf(inp_ptr, "%s %s %s %s %s %s", ch1, ch2, ch3, ch4, ch5, ch6); //interval Line
  fscanf(inp_ptr, "%s %s %s %s %s %s", ch1, ch2, ch3, ch4, ch5, ch6); //interval Pix
  *grid_int=atoi(ch6);
  fscanf(inp_ptr, "%s %s %s %s %s", ch1, ch2, ch3, ch4, ch5); //reading comment
  N_temp=*Nobs;
  data = fmatrix(N_temp,1);
  for (i=0; i<N_temp; i++) {
    fscanf(inp_ptr, "%s %s %s %s", ch1, ch2, ch3, ch4);
    data[i][0]=atof(ch4);
    }
  return data;
}

/****************************************************************
 * solvechol(A,rhs); solution of AX=rhs                         *
 *  cholesky factorisation internal implemetnation              *
 * A contains cholesky factorisation of A                       *
 * rhs contains estimated X on output                           *
 * there may be more efficient implementations.                 *
 *    Bert Kampes, 11-Oct-1999                                  *
 ****************************************************************/
void solvechol(double **A, int N, double **B)
{
// const int32 N = A.lines();
register double sum;
register int i,j;
// ______ Solve Ly=b, use B to store y ______
  for (i=0; i<N; ++i) {
    sum = B[i][0];
    for (j=i-1; j>=0; --j) {
      sum -= A[i][j]*B[j][0];
      }
    B[i][0] = sum/A[i][i];
    }
// ______ Solve Ux=y, use B to store unknowns ______
  for (i=N-1; i>=0; --i) {
    sum = B[i][0];
    for (j=i+1; j<N; ++j) {
      sum -= A[j][i]*B[j][0];
      }
    B[i][0] = sum/A[i][i];
    }
  } // END solvechol

/* Choles function from Berth campus */
void choles(double **A, int N)
{
  register int i,j,k;
  register double sum;
  for (i=0; i<N; ++i) {
    for (j=i; j<N; ++j) {
      sum = A[i][j];
      for ( k=i-1; k>=0; --k) {
        sum -= A[i][k] * A[j][k];
        }
      if (i == j) {
        if (sum <= 0.) {printf("choles: internal: A not pos. def.");}
        A[i][i] = sqrt(sum);
        } else {
        A[j][i] = sum/A[i][i];
        }
      }
    }
  } // END choles internal, self bk

/****************** Invert cholesky matrix *******/
void invertchol(double **A, int N)
{
  double sum;
  int i,j,k;
// ______ Compute inv(L) store in lower of A ______
  for (i=0; i<N; ++i) {
    A[i][i] = 1./A[i][i];
    for (j=i+1; j<N; ++j) {
      sum = 0.;
      for (k=i; k<j; ++k) {
        sum -= A[j][k]*A[k][i];
        }
      A[j][i]=sum/A[j][j];
      }
    }
// ______ Compute inv(A)=inv(LtL) store in lower of A ______
  for (i=0; i<N; ++i) {
    for (j=i; j<N; ++j) {
      sum = 0.;
      for (k=j; k<N; ++k) {
        sum += A[k][i]*A[k][j]; // transpose
        }
      A[j][i] = sum;
      }
    }
}
// END invertchol BK

//*********************************************************
//*********************************************************

/*********** (mat)T*mat *Transpose*mat ***********/
double **matTxmat(double **mat1, int rows, int cols, double **mat2, int m, int n)
{
  int i,j,k;
  double **T_mat, **NN;
  T_mat= dmatrix(cols, rows);
  NN = dmatrix(cols,n);
  for (i=0; i<rows; i++)
    for(j=0; j<cols; j++) T_mat[j][i]=mat1[i][j];
  for(i=0;i<cols; i++)
    for(j=0; j<n; j++) NN[i][j]=0.0;
  for(i=0; i<cols; i++)
    for(j=0; j<n; j++)
      for(k=0; k<rows; k++)
        NN[i][j]=NN[i][j]+T_mat[i][k]*mat2[k][j];

  return NN;
}

/*********** (mat)T*mat *Transpose*mat ***********/
double **matxmatT(double **mat1, int rows, int cols, double **mat2, int m, int n)
{
  int i,j,k;
  double **T_mat, **NN;
  T_mat= dmatrix(n, m);
  NN = dmatrix(rows,m);
  for (i=0; i<m; i++)
    for(j=0; j<n; j++) T_mat[j][i]=mat2[i][j];
  for(i=0; i<rows; i++)
    for(j=0; j<m; j++) NN[i][j]=0.0;
  for(i=0; i<rows; i++) {
    for(j=0; j<m; j++) {
      for(k=0;k<cols;k++) NN[i][j]=NN[i][j]+mat1[i][k]*T_mat[k][j];
      }
    }
  return NN;
}

/*********** matrix multiplication ***************/
double **mat_mult(double **A, int rows, int cols, double **B, int m, int n)
{
  int i,j,k;
  double **NN;
  NN = dmatrix(rows,n);
  for(i=0; i<rows; i++)
    for(j=0; j<n; j++) NN[i][j]=0.0;
  for(i=0; i<rows; i++) {
    for(j=0; j<n; j++) {
      for(k=0;k<cols;k++) NN[i][j]=NN[i][j]+A[i][k]*B[k][j];
      }
    }
  return NN;
}

/*******************Matrix substraction *******************/
double **mat_sub(double **A, int rows, int cols, double **B, int m, int n)
{
  int i,j;
  double **NN;
  NN=dmatrix(rows,cols);
  for(i=0; i<rows; i++)
    for(j=0; j<cols; j++)
      NN[i][j]=A[i][j]-B[i][j];
  return NN;
}

/******************* matrix copying to another matrix ********/
double **mat_copy(double **A, int rows, int cols)
{
  int i,j;
  double **NN;
  NN=dmatrix(rows,cols);
  for(i=0; i<rows; i++)
    for(j=0; j<cols; j++)
      NN[i][j]=A[i][j];
  return NN;
}

/******************* unit matrix creation ********************/
double **mat_unit(int rows, int cols)
{
  int i,j;
  double **N;
  N=dmatrix(rows,cols);
  for(i=0; i<rows; i++)
    for(j=0; j<cols; j++) {
      N[i][j]=(double)0.0;
      if(i==j) {
        N[i][j]=(double)1.0;
        }
    }
  return N;
}
