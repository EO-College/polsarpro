/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : matrix.c
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

Description :  MATRICES Routines

*-------------------------------------------------------------------------------
Routines  :

char *vector_char(int nrh);
void free_vector_char(char *v);
short int *vector_short_int(int nrh);
void free_vector_short_int(int *m);
int *vector_int(int nrh);
void free_vector_int(int *m);
float *vector_float(int nrh);
void free_vector_float(float *m);
double *vector_double_float(int nrh);
void free_vector_double_float(double *m);
char **matrix_char(int nrh,int nch);
void free_matrix_char(char **m,int nrh);
short int **matrix_short_int (int nrh, int nch);
void free_matrix_short_int (short int **m, int nrh);
int **matrix_int (int nrh, int nch);
void free_matrix_int (int **m, int nrh);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
short int ***matrix3d_short_int(int nz,int nrh,int nch)
void free_matrix3d_short_int(short int ***m,int nz,int nrh)
int ***matrix3d_int(int nz,int nrh,int nch)
void free_matrix3d_int(int ***m,int nz,int nrh)
float ***matrix3d_float(int nz,int nrh,int nch)
void free_matrix3d_float(float ***m,int nz,int nrh)
double **matrix_double_float (int nrh, int nch);
void free_matrix_double_float (double **m, int nrh);
cplx *cplx_vector(int nh)
cplx **cplx_matrix(int nrh,int nch)
cplx ***cplx_matrix3d(int nz,int nrh,int nch)
void cplx_free_matrix( cplx **m,int nrh)

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
Routine  : vector_char
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of char elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of char
Returned values  :
m   : vector pointer (char *)
*******************************************************************************/
char *vector_char(int nrh)
{
  char *v;

  v = (char *) malloc((unsigned) (nrh + 1) * sizeof(char));
  if (!v)
  edit_error("allocation failure in vector_char()", "");
  return v;
}

/*******************************************************************************
Routine  : free_vector_char
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a vector and disallocates memory for a vector
of char elements
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
void free_vector_char(char *v)
{
  free((char *) v);
  v = NULL;
}

/*******************************************************************************
Routine  : vector_short_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of short int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of short int
Returned values  :
m   : vector pointer (float *)
*******************************************************************************/
short int *vector_short_int(int nrh)
{
  int ii;
  short int *m;

  m = (short int *) malloc((unsigned) (nrh + 1) * sizeof(short int));
  if (!m)
  edit_error("allocation failure 1 in vector_short_int()", "");

  for (ii = 0; ii < nrh; ii++)
  m[ii] = 0;
  return m;
}

/*******************************************************************************
Routine  : free_vector_short_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a vector and disallocates memory for a vector
of short int elements
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
void free_vector_short_int(short int *m)
{
  free((short int *) m);
  m = NULL;
}

/*******************************************************************************
Routine  : vector_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of int
Returned values  :
m   : vector pointer (float *)
*******************************************************************************/
int *vector_int(int nrh)
{
  int ii;
  int *m;

  m = (int *) malloc((unsigned) (nrh + 1) * sizeof(int));
  if (!m)
  edit_error("allocation failure 1 in vector_int()", "");

  for (ii = 0; ii < nrh; ii++)
  m[ii] = 0;
  return m;
}

/*******************************************************************************
Routine  : free_vector_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a vector and disallocates memory for a vector
of int elements
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
void free_vector_int(int *m)
{
  free((int *) m);
  m = NULL;
}

/*******************************************************************************
Routine  : vector_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of float
Returned values  :
m   : vector pointer (float *)
*******************************************************************************/
float *vector_float(int nrh)
{
  int ii;
  float *m;

  m = (float *) malloc((unsigned) (nrh + 1) * sizeof(float));
  if (!m)
  edit_error("allocation failure 1 in vector_float()", "");

  for (ii = 0; ii < nrh; ii++)
  m[ii] = 0.;
  return m;
}

/*******************************************************************************
Routine  : free_vector_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a vector and disallocates memory for a vector
of float elements
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
void free_vector_float(float *m)
{
  free((float *) m);
  m = NULL;
}

/*******************************************************************************
Routine  : vector_double_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of float
Returned values  :
m   : vector pointer (float *)
*******************************************************************************/
double *vector_double_float(int nrh)
{
  int ii;
  double *m;

  m = (double *) malloc((unsigned) (nrh + 1) * sizeof(double));
  if (!m)
  edit_error("allocation failure 1 in vector_float()", "");

  for (ii = 0; ii < nrh; ii++)
  m[ii] = 0.;
  return m;
}

/*******************************************************************************
Routine  : free_vector_double_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a vector and disallocates memory for a vector
of float elements
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :
void
*******************************************************************************/
void free_vector_double_float(double *m)
{
  free((double *) m);
  m = NULL;
}

/*******************************************************************************
Routine  : matrix_char
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of char elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
nch  : number of rows
Returned values  :
m   : matrix pointer (char **)
*******************************************************************************/
char **matrix_char(int nrh, int nch)
{
  int i;
  char **m;

  m = (char **) malloc((unsigned) (nrh + 1) * sizeof(char *));
  if (!m)
  edit_error("allocation failure 1 in matrix_char()", "");

  for (i = 0; i < nrh; i++) {
  m[i] = (char *) malloc((unsigned) (nch + 1) * sizeof(char));
  if (!m[i])
    edit_error("allocation failure 2 in matrix_char()", "");
  }
  return m;
}

/*******************************************************************************
Routine  : free_matrix_char
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of char elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
Returned values  :
void
*******************************************************************************/
void free_matrix_char(char **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--) free((char *) (m[i]));
  free((char **) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : matrix_short_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of short int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
nch  : number of rows
Returned values  :
m   : matrix pointer (short int **)
*******************************************************************************/
short int **matrix_short_int(int nrh, int nch)
{
  int i, j;
  short int **m;

  m = (short int **) malloc((unsigned) (nrh) * sizeof(short int *));
  if (!m)
  edit_error("allocation failure 1 in matrix()", "");

  for (i = 0; i < nrh; i++) {
  m[i] = (short int *) malloc((unsigned) (nch) * sizeof(short int));
  if (!m[i])
    edit_error("allocation failure 2 in matrix()", "");
  }
  for (i = 0; i < nrh; i++)
  for (j = 0; j < nch; j++)
    m[i][j] = 0;
  return m;
}

/*******************************************************************************
Routine  : free_matrix_short_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of short int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
Returned values  :
void
*******************************************************************************/
void free_matrix_short_int(short int **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--) free((short int *) (m[i]));
  free((short int **) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : matrix_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
nch  : number of rows
Returned values  :
m   : matrix pointer (short int **)
*******************************************************************************/
int **matrix_int(int nrh, int nch)
{
  int i, j;
  int **m;

  m = (int **) malloc((unsigned) (nrh) * sizeof(int *));
  if (!m)
  edit_error("allocation failure 1 in matrix()", "");

  for (i = 0; i < nrh; i++) {
  m[i] = (int *) malloc((unsigned) (nch) * sizeof(int));
  if (!m[i])
    edit_error("allocation failure 2 in matrix()", "");
  }
  for (i = 0; i < nrh; i++)
  for (j = 0; j < nch; j++)
    m[i][j] = 0;
  return m;
}

/*******************************************************************************
Routine  : free_matrix_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
Returned values  :
void
*******************************************************************************/
void free_matrix_int(int **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--) free((int *) (m[i]));
  free((int **) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : matrix_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
nch  : number of rows
Returned values  :
m   : matrix pointer (float **)
*******************************************************************************/
float **matrix_float(int nrh, int nch)
{
  int i, j;
  float **m;

  m = (float **) malloc((unsigned) (nrh) * sizeof(float *));
  if (!m)
  edit_error("allocation failure 1 in matrix()", "");

  for (i = 0; i < nrh; i++) {
  m[i] = (float *) malloc((unsigned) (nch) * sizeof(float));
  if (!m[i])
    edit_error("allocation failure 2 in matrix()", "");
  }
  for (i = 0; i < nrh; i++)
  for (j = 0; j < nch; j++)
    m[i][j] = 0.;
  return m;
}

/*******************************************************************************
Routine  : free_matrix_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
Returned values  :
void
*******************************************************************************/
void free_matrix_float(float **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--) free((float *) (m[i]));
  free((float **) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : matrix3d_short_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 02/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 3D matrix of short int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
nch  : number of elements 3rd dimension
Returned values  :
m   : 3D matrix pointer (short int ***)
*******************************************************************************/
short int ***matrix3d_short_int(int nz, int nrh, int nch)
{
  int ii, jj, dd;
  short int ***m;


  m = (short int ***) malloc((unsigned) (nz + 1) * sizeof(short int **));
  if (m == NULL)
  edit_error("D'ALLOCATION No.1 DANS MATRIX()", "");
  for (jj = 0; jj < nz; jj++) {
  m[jj] = (short int **) malloc((unsigned) (nrh + 1) * sizeof(short int *));
  if (m[jj] == NULL)
    edit_error("D'ALLOCATION No.2 DANS MATRIX()", "");
  for (ii = 0; ii < nrh; ii++) {
    m[jj][ii] =
    (short int *) malloc((unsigned) (nch + 1) * sizeof(short int));
    if (m[jj][ii] == NULL)
    edit_error("D'ALLOCATION No.3 DANS MATRIX()", "");
  }
  }
  for (dd = 0; dd < nz; dd++)
  for (jj = 0; jj < nrh; jj++)
  for (ii = 0; ii < nch; ii++)
    m[dd][jj][ii] = 0;

  return m;
}

/*******************************************************************************
Routine  : free_matrix3d_short_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 02/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 3D matrix of short int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
Returned values  :
void
*******************************************************************************/
void free_matrix3d_short_int(short int ***m, int nz, int nrh)
{
  int ii, jj;

  for (jj = nz - 1; jj >= 0; jj--) {
    for (ii = nrh - 1; ii >= 0; ii--) free((short int *) (m[jj][ii]));
    free((short int **) (m[jj]));
    }    
  free((short int ***) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : matrix3d_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 02/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 3D matrix of int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
nch  : number of elements 3rd dimension
Returned values  :
m   : 3D matrix pointer (short int ***)
*******************************************************************************/
int ***matrix3d_int(int nz, int nrh, int nch)
{
  int ii, jj, dd;
  int ***m;


  m = (int ***) malloc((unsigned) (nz + 1) * sizeof(int **));
  if (m == NULL)
  edit_error("D'ALLOCATION No.1 DANS MATRIX()", "");
  for (jj = 0; jj < nz; jj++) {
  m[jj] = (int **) malloc((unsigned) (nrh + 1) * sizeof(int *));
  if (m[jj] == NULL)
    edit_error("D'ALLOCATION No.2 DANS MATRIX()", "");
  for (ii = 0; ii < nrh; ii++) {
    m[jj][ii] =  (int *) malloc((unsigned) (nch + 1) * sizeof(int));
    if (m[jj][ii] == NULL)
    edit_error("D'ALLOCATION No.3 DANS MATRIX()", "");
  }
  }
  for (dd = 0; dd < nz; dd++)
  for (jj = 0; jj < nrh; jj++)
  for (ii = 0; ii < nch; ii++)
    m[dd][jj][ii] = 0;

  return m;
}

/*******************************************************************************
Routine  : free_matrix3d_int
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 02/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 3D matrix of int elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
Returned values  :
void
*******************************************************************************/
void free_matrix3d_int(int ***m, int nz, int nrh)
{
  int ii, jj;

  for (jj = nz - 1; jj >= 0; jj--) {
    for (ii = nrh - 1; ii >= 0; ii--) free((int *) (m[jj][ii]));
    free((int **) (m[jj]));
    }    
  free((int ***) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : matrix3d_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 3D matrix of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
nch  : number of elements 3rd dimension
Returned values  :
m   : 3D matrix pointer (float ***)
*******************************************************************************/
float ***matrix3d_float(int nz, int nrh, int nch)
{
  int ii, jj, dd;
  float ***m;


  m = (float ***) malloc((unsigned) (nz + 1) * sizeof(float **));
  if (m == NULL)
  edit_error("D'ALLOCATION No.1 DANS MATRIX()", "");
  for (jj = 0; jj < nz; jj++) {
  m[jj] = (float **) malloc((unsigned) (nrh + 1) * sizeof(float *));
  if (m[jj] == NULL)
    edit_error("D'ALLOCATION No.2 DANS MATRIX()", "");
  for (ii = 0; ii < nrh; ii++) {
    m[jj][ii] =
    (float *) malloc((unsigned) (nch + 1) * sizeof(float));
    if (m[jj][ii] == NULL)
    edit_error("D'ALLOCATION No.3 DANS MATRIX()", "");
  }
  }
  for (dd = 0; dd < nz; dd++)
  for (jj = 0; jj < nrh; jj++)
  for (ii = 0; ii < nch; ii++)
    m[dd][jj][ii] = (0.);
  return m;
}

/*******************************************************************************
Routine  : free_matrix3d_float
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 3D matrix of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nz  : number of elements 1st dimension
nrh  : number of elements 2nd dimension
Returned values  :
void
*******************************************************************************/
void free_matrix3d_float(float ***m, int nz, int nrh)
{
  int ii, jj;

  for (jj = nz - 1; jj >= 0; jj--) {
    for (ii = nrh - 1; ii >= 0; ii--) free((float *) (m[jj][ii]));
    free((float **) (m[jj]));
    }    
  free((float ***) (m));
  m = NULL;
}


/*******************************************************************************
Routine  : matrix_double_float
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
nch  : number of rows
Returned values  :
m   : matrix pointer (float **)
*******************************************************************************/
double **matrix_double_float(int nrh, int nch)
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
    m[i][j] = 0.;
  return m;
}

/*******************************************************************************
Routine  : free_matrix_double_float
Authors  : Eric POTTIER
Creation : 08/2014
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of float elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of lines
Returned values  :
void
*******************************************************************************/
void free_matrix_double_float(double **m, int nrh)
{
  int i;
  for (i = nrh - 1; i >= 0; i--) free((double *) (m[i]));
  free((double **) (m));
  m = NULL;
}

/*******************************************************************************
Routine  : cplx_vector
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a vector of complex elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of float
Returned values  :
m   : vector pointer (cplx *)
*******************************************************************************/
cplx *cplx_vector(int nh)
{
  int i;
  cplx *v,cplx0;

  v=( cplx *)malloc((unsigned) (nh+1)*sizeof( cplx));
  if (!v)
  edit_error("allocation failure 1 in cplx_vector()","");
  cplx0.re=0;cplx0.im=0;
  for(i=0;i<nh;i++) v[i]=cplx0;
  return v;
}

/*******************************************************************************
Routine  : cplx_matrix
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of complex elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of elements 1st dimension
nch  : number of elements 2nd dimension
Returned values  :
m   : 2D matrix pointer (cplx **)
*******************************************************************************/
cplx **cplx_matrix(int nrh,int nch)
{
  int i,j;
   cplx **m,cplx0;

  m=( cplx **) malloc((unsigned) (nrh+1)*sizeof( cplx*));
  if (!m) edit_error("allocation failure 1 in cplx_matrix()","");

  for(i=0;i<nrh;i++) {
    m[i]=( cplx *) malloc((unsigned) (nch+1)*sizeof( cplx));
    if (!m[i]) edit_error("allocation failure 2 in cplx_matrix()","");
  }
  cplx0.re=0;cplx0.im=0;
    for(i=0;i<nrh;i++) for(j=0;j<nch;j++) m[i][j]=cplx0;

  return m;
}

/*******************************************************************************
Routine  : cplx_matrix3d
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Creates and allocates memory for a 2D matrix of complex elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of elements 1st dimension
nch  : number of elements 2nd dimension
Returned values  :
m   : 2D matrix pointer (cplx **)
*******************************************************************************/
cplx ***cplx_matrix3d(int nz,int nrh,int nch)
{
int  ii,jj,dd;
cplx ***m,cplx0;

m=( cplx ***) malloc((unsigned) (nz+1)*sizeof( cplx**));
if (m==NULL) edit_error("allocation failure 1 in cplx_matrix3d()","");
for(jj=0;jj<nz;jj++) {
  m[jj]=( cplx **) malloc((unsigned) (nrh+1)*sizeof( cplx*));
  if (m[jj]==NULL) edit_error("allocation failure 2 in cplx_matrix3d()","");
  for(ii=0;ii<nrh;ii++) {
    m[jj][ii]=( cplx *) malloc((unsigned) (nch+1)*sizeof( cplx));
    if (m[jj][ii]==NULL) edit_error("allocation failure 3 in cplx_matrix3d()","");
    }
  }
cplx0.re=0;cplx0.im=0;
for (dd=0; dd<nz; dd++) for (jj=0; jj<nrh; jj++) for (ii=0; ii<nch; ii++)
  m[dd][jj][ii] = cplx0;

  return m;
}

/*******************************************************************************
Routine  : cplx_free_matrix
Authors  : Laurent FERRO-FAMIL
Creation : 08/2005
Update  :
*-------------------------------------------------------------------------------
Description :  Erases a matrix and disallocates memory for a 2D matrix of complex elements
*-------------------------------------------------------------------------------
Inputs arguments :
nrh  : number of elements 1st dimension
Returned values  :
void
*******************************************************************************/
void cplx_free_matrix( cplx **m,int nrh)
{
  int i;

  for(i=nrh-1;i>=0;i--) free((char*) (m[i]));
  free((cplx*)m);
}

