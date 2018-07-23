/*******************************************************************************

	File	 : matrix.h
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
	Description :  MATRICES Routines
*-------------------------------------------------------------------------------
	Routines	:

				char *vector_char(int nrh);
				void free_vector_char(char *v);
				short int *vector_short_int(int nrh);
				void free_vector_short_int(short int *m);
				int *vector_int(int nrh);
				void free_vector_int(int *m);
				float *vector_float(int nrh);
				void free_vector_float(float *m);
				double *vector_double_float(int nrh);
				void free_vector_double_float(double *m);
				char **matrix_char(int nrh,int nch);
				void free_matrix_char(char **m,int nrh);
				short int **matrix_short_int(int nrh,int nch);
				void free_matrix_short_int(short int **m,int nrh);
				int **matrix_int(int nrh,int nch);
				void free_matrix_int(int **m,int nrh);
				float **matrix_float(int nrh,int nch);
				void free_matrix_float(float **m,int nrh);
				short int ***matrix3d_short_int(int nz,int nrh,int nch)
				void free_matrix3d_short_int(short int ***m,int nz,int nrh)
				int ***matrix3d_int(int nz,int nrh,int nch)
				void free_matrix3d_int(int ***m,int nz,int nrh)
				float ***matrix3d_float(int nz,int nrh,int nch)
				void free_matrix3d_float(float ***m,int nz,int nrh)
				cplx *cplx_vector(int nh)
				cplx **cplx_matrix(int nrh,int nch)
				cplx ***cplx_matrix3d(int nz,int nrh,int nch)
				void cplx_free_matrix( cplx **m,int nrh)
				double **matrix_double_float(int nrh,int nch);
				void free_matrix_double_float(float **m,int nrh);

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagMatrix
#define FlagMatrix

#include "PolSARproLib.h"

char *vector_char (int nrh);
void free_vector_char (char *v);

short int *vector_short_int (int nrh);
void free_vector_short_int (short int *m);

int *vector_int (int nrh);
void free_vector_int (int *m);

float *vector_float (int nrh);
void free_vector_float (float *m);

double *vector_double_float (int nrh);
void free_vector_double_float (double *m);

char **matrix_char (int nrh, int nch);
void free_matrix_char (char **m, int nrh);

short int **matrix_short_int (int nrh, int nch);
void free_matrix_short_int (short int **m, int nrh);

int **matrix_int (int nrh, int nch);
void free_matrix_int (int **m, int nrh);

float **matrix_float (int nrh, int nch);
void free_matrix_float (float **m, int nrh);

short int ***matrix3d_short_int(int nz,int nrh,int nch);
void free_matrix3d_short_int(short int ***m,int nz,int nrh);

int ***matrix3d_int(int nz,int nrh,int nch);
void free_matrix3d_int(int ***m,int nz,int nrh);

float ***matrix3d_float (int nz, int nrh, int nch);
void free_matrix3d_float (float ***m, int nz, int nrh);

double **matrix_double_float (int nrh, int nch);
void free_matrix_double_float (double **m, int nrh);

cplx *cplx_vector(int nh);
cplx **cplx_matrix(int nrh,int nch);
cplx ***cplx_matrix3d(int nz,int nrh,int nch);
void cplx_free_matrix( cplx **m,int nrh);

#endif
