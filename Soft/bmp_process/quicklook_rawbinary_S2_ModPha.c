/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : quicklook_rawbinary_S2_ModPha.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 2.0
Creation : 08/2004
Update  : 12/2006 (Stephane MERIC)

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

Description :  Creation of a QuickLook Pauli RGB BMP file of
        Raw Binary Data Files (Modulus-Phase data type)
with
Blue = 10log(T11)
Green = 10log(T33)
Red = 10log(T22)

*-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
void check_file(char *file);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
char *vector_char(int nrh);
void free_vector_char(char *v);
void header24(int nlig,int ncol,FILE *fbmp);
void header24Ras(int ncol,int nlig,FILE *fbmp);
void my_randomize(void);
float my_eps_random(void);
float my_round(float v);

*******************************************************************************/

/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* S matrix */
#define hhm 0
#define hhp 1
#define hvm 2
#define hvp 3
#define vhm 4
#define vhp 5
#define vvm 6
#define vvp 7


/* T matrix */
#define T11   0
#define T22   1
#define T33   2

/* CONSTANTS  */
#define Npolar_in  8  /* nb of input/output files */

/* ROUTINES DECLARATION */
#include "../lib/graphics.h"
#include "../lib/matrix.h"
#include "../lib/processing.h"
#include "../lib/util.h"
void header24_v4(int nlig, int ncol, FILE * fbmp);
void MinMaxContrastMedianBMP(float **mat,float *min,float *max,int nlig,int ncol);

/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* GLOBAL ARRAYS */
float **M_in;
float ***M_out;
float **databmp;
char *bmpimage;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  : 12/2006 (Stephane MERIC)
*-------------------------------------------------------------------------------

Description :  Creation of a QuickLook Pauli RGB BMP file of
        Raw Binary Data Files

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
void
*******************************************************************************/

int main(int argc, char *argv[])
/*                                      */
{

/* LOCAL VARIABLES */

  FILE *in_file[Npolar_in], *out_file;

  char File1[FilePathLength],File2[FilePathLength],File3[FilePathLength],File4[FilePathLength];
  char File5[FilePathLength],File6[FilePathLength],File7[FilePathLength],File8[FilePathLength];
  char FileOutput[FilePathLength];

  int lig, col,l,np,ind;
  int Ncol, Coeff;
  int Nligbmp, Ncolbmp;
  int Nligfin, Ncolfin;
  int IEEE;

  char *pc;
  float fl1;
  float *v;
  float k1r,k1i,k2r,k2i,k3r,k3i;

  float minred, maxred;
  float mingreen, maxgreen;
  float minblue, maxblue;
  float xx;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 15) {
  strcpy(File1, argv[1]);
  strcpy(File2, argv[2]);
  strcpy(File3, argv[3]);
  strcpy(File4, argv[4]);
  strcpy(File5, argv[5]);
  strcpy(File6, argv[6]);
  strcpy(File7, argv[7]);
  strcpy(File8, argv[8]);
  Ncol = atoi(argv[9]);
  Nligfin = atoi(argv[10]);
  Ncolfin = atoi(argv[11]);
  IEEE = atoi(argv[12]);
  Coeff = atoi(argv[13]);
  strcpy(FileOutput, argv[14]);
  } else {
  printf("TYPE: quicklook_rawbinary_S2_ModPha FileInput1 FileInput2 FileInput3 FileInput4\n");
  printf("FileInput5 FileInput6 FileInput7 FileInput8 Ncol FinalNlig FinalNcol\n");
  printf("IEEEFormat_Convert (0/1) CoeffSubSampling\n");
  printf("QuicklookOutputFile\n");
  exit(1);
  }

/* Nb of lines and rows sub-sampled image */
  Nligbmp = Nligfin;
  Ncolfin = Ncolfin - (int) fmod((float) Ncolfin, 4.);
  Ncolbmp = Ncolfin;

  bmpimage = vector_char(3 * Nligbmp * Ncolbmp);
  M_in = matrix_float(Npolar_in, Ncol);
  M_out = matrix3d_float(3, Nligfin, Ncolfin);
  databmp = matrix_float(Nligfin, Ncolfin);

/******************************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/******************************************************************************/
  check_file(File1);
  check_file(File2);
  check_file(File3);
  check_file(File4);
  check_file(File5);
  check_file(File6);
  check_file(File7);
  check_file(File8);
  check_file(FileOutput);

  if ((in_file[0] = fopen(File1, "rb")) == NULL)
    edit_error("Could not open input file : ", File1);
  if ((in_file[1] = fopen(File2, "rb")) == NULL)
    edit_error("Could not open input file : ", File2);
  if ((in_file[2] = fopen(File3, "rb")) == NULL)
    edit_error("Could not open input file : ", File3);
  if ((in_file[3] = fopen(File4, "rb")) == NULL)
    edit_error("Could not open input file : ", File4);
  if ((in_file[4] = fopen(File5, "rb")) == NULL)
    edit_error("Could not open input file : ", File5);
  if ((in_file[5] = fopen(File6, "rb")) == NULL)
    edit_error("Could not open input file : ", File6);
  if ((in_file[6] = fopen(File7, "rb")) == NULL)
    edit_error("Could not open input file : ", File7);
  if ((in_file[7] = fopen(File8, "rb")) == NULL)
    edit_error("Could not open input file : ", File8);

/******************************************************************************/

for (np = 0; np < Npolar_in; np++) rewind(in_file[np]);
 
for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}
  for (np = 0; np < Npolar_in; np++) {
    if (IEEE == 0)
      fread(&M_in[np][0], sizeof(float), Ncol, in_file[np]);
    if (IEEE == 1) {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[np]);pc[2] = getc(in_file[np]);
        pc[1] = getc(in_file[np]);pc[0] = getc(in_file[np]);
        M_in[np][col] = fl1;
        }
      }
    }
  for (col = 0; col < Ncolfin; col++) {
    ind = col * Coeff;
    k1r = (M_in[hhm][ind]*cos(M_in[hhp][ind]) + M_in[vvm][ind]*cos(M_in[vvp][ind])) / sqrt(2.);
    k1i = (M_in[hhm][ind]*sin(M_in[hhp][ind]) + M_in[vvm][ind]*sin(M_in[vvp][ind])) / sqrt(2.);
    k2r = (M_in[hhm][ind]*cos(M_in[hhp][ind]) - M_in[vvm][ind]*cos(M_in[vvp][ind])) / sqrt(2.);
    k2i = (M_in[hhm][ind]*sin(M_in[hhp][ind]) - M_in[vvm][ind]*sin(M_in[vvp][ind])) / sqrt(2.);
    k3r = (M_in[hvm][ind]*cos(M_in[hvp][ind]) + M_in[vhm][ind]*cos(M_in[vhp][ind])) / sqrt(2.);
    k3i = (M_in[hvm][ind]*sin(M_in[hvp][ind]) + M_in[vhm][ind]*sin(M_in[vhp][ind])) / sqrt(2.);
    M_out[T11][lig][col] = fabs(k1r * k1r + k1i * k1i);
    M_out[T22][lig][col] = fabs(k2r * k2r + k2i * k2i);
    M_out[T33][lig][col] = fabs(k3r * k3r + k3i * k3i);
    if (M_out[T11][lig][col] < eps) M_out[T11][lig][col] = eps;
    M_out[T11][lig][col] = 10. * log10(M_out[T11][lig][col]);
    if (M_out[T22][lig][col] < eps) M_out[T22][lig][col] = eps;
    M_out[T22][lig][col] = 10. * log10(M_out[T22][lig][col]);
    if (M_out[T33][lig][col] < eps) M_out[T33][lig][col] = eps;
    M_out[T33][lig][col] = 10. * log10(M_out[T33][lig][col]);
    }
  for (l = 1; l < Coeff; l++) {
    for (np = 0; np < Npolar_in; np++) {
       fread(&M_in[0][0], sizeof(float), Ncol, in_file[np]);
       }
    }

  }
  for (np = 0; np < Npolar_in; np++)
  fclose(in_file[np]);

/******************************************************************************/
/* DETERMINATION OF THE MIN / MAX OF THE RED CHANNEL */
  for (lig = 0; lig < Nligfin; lig++) for (col = 0; col < Ncolfin; col++) databmp[lig][col] = M_out[T22][lig][col];
  minred = INIT_MINMAX; maxred = -minred;
  MinMaxContrastMedianBMP(databmp, &minred, &maxred, Nligfin, Ncolfin);

/******************************************************************************/
/* DETERMINATION OF THE MIN / MAX OF THE GREEN CHANNEL */
  for (lig = 0; lig < Nligfin; lig++) for (col = 0; col < Ncolfin; col++) databmp[lig][col] = M_out[T33][lig][col];
  mingreen = INIT_MINMAX; maxgreen = -mingreen;
  MinMaxContrastMedianBMP(databmp, &mingreen, &maxgreen, Nligfin, Ncolfin);

/******************************************************************************/
/* DETERMINATION OF THE MIN / MAX OF THE BLUE CHANNEL */
  for (lig = 0; lig < Nligfin; lig++) for (col = 0; col < Ncolfin; col++) databmp[lig][col] = M_out[T11][lig][col];
  minblue = INIT_MINMAX; maxblue = -minblue;
  MinMaxContrastMedianBMP(databmp, &minblue, &maxblue, Nligfin, Ncolfin);
  
/******************************************************************************/
/* CREATE THE BMP FILE */

  for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}

  for (col = 0; col < Ncolfin; col++) {
    xx = M_out[T11][lig][col];
    if (xx > maxblue) xx = maxblue;
    if (xx < minblue) xx = minblue;
    xx = (xx - minblue) / (maxblue - minblue);
    if (xx > 1.) xx = 1.;
    if (xx < 0.) xx = 0.;
    l = (int) (floor(255 * xx));
    bmpimage[3 * (Nligbmp - 1 - lig) * Ncolbmp + 3 * col + 0] =
  (char) (l);

    xx = M_out[T33][lig][col];
    if (xx > maxgreen) xx = maxgreen;
    if (xx < mingreen) xx = mingreen;
    xx = (xx - mingreen) / (maxgreen - mingreen);
    if (xx > 1.) xx = 1.;
    if (xx < 0.) xx = 0.;
    l = (int) (floor(255 * xx));
    bmpimage[3 * (Nligbmp - 1 - lig) * Ncolbmp + 3 * col + 1] =
  (char) (l);

    xx = M_out[T22][lig][col];
    if (xx > maxred) xx = maxred;
    if (xx < minred) xx = minred;
    xx = (xx - minred) / (maxred - minred);
    if (xx > 1.) xx = 1.;
    if (xx < 0.) xx = 0.;
    l = (int) (floor(255 * xx));
    bmpimage[3 * (Nligbmp - 1 - lig) * Ncolbmp + 3 * col + 2] =
  (char) (l);
  }    /*fin col */

  }    /*fin lig */

/******************************************************************************/
/* OUTPUT BMP FILE CREATION */
/******************************************************************************/
  if ((out_file = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/* BMP HEADER */
  header24_v4(Nligbmp, Ncolbmp, out_file);

  fwrite(&bmpimage[0], sizeof(char), 3 * Nligbmp * Ncolbmp, out_file);

  fclose(out_file);

  free_matrix_float(M_in, Npolar_in);
  free_matrix3d_float(M_out,3, Nligfin);

  return 1;
}

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

/*******************************************************************************
Routine  : header24_v4
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update   :
*-------------------------------------------------------------------------------
Description :  Creates and writes a 24 bit bitmap file header
*-------------------------------------------------------------------------------
Inputs arguments :
nlig   : BMP image number of lines
ncol   : BMP image number of rows
*fbmp  : BMP file pointer
Returned values  :
void
*******************************************************************************/
void header24_v4(int nlig, int ncol, FILE * fbmp)
{
    int k;

/*Bitmap File Header*/
    k = 19778;
    fwrite(&k, sizeof(short int), 1, fbmp);
    k = (int) ((3 * ncol * nlig + 54) / 2);
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 54;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 40;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = ncol;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = nlig;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 1;
    fwrite(&k, sizeof(short int), 1, fbmp);
    k = 24;
    fwrite(&k, sizeof(short int), 1, fbmp);
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 3 * ncol * nlig;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 2952;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 2952;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
}

/*******************************************************************************
Routine  : MinMaxContrastMedianBMP
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update   :
*-------------------------------------------------------------------------------
Description :  Return the min and the max values of an array of float

Detect the values = 10 log10(eps) and -9999.99

*-------------------------------------------------------------------------------
Inputs arguments :
mat : float array
nlig, ncol : size of the matrix in row and col
Returned values  :
min, max : minimum and maximum values
*******************************************************************************/
void MinMaxContrastMedianBMP(float **mat,float *min,float *max,int nlig,int ncol)
{
	float *tableau;
	float *mattab;
	float maxmax, minmin;
	float median, median0;
	float logeps;
	int ii,lig,col,npts;
	int np, validnpts;

	tableau = vector_float(nlig*ncol);
	mattab = vector_float(nlig*ncol);

	validnpts = 0;
	logeps = 10. *log10(eps);
	for(lig=0;lig<nlig;lig++)
	  	for(col=0;col<ncol;col++) {
            if (my_isfinite(mat[lig][col]) != 0.) {
                if ((mat[lig][col] > logeps)&&(mat[lig][col] < DATA_NULL)) {
                    mattab[validnpts] = mat[lig][col];
                    validnpts++;
                    }
                }
            }

   	*min = INIT_MINMAX; *max = -*min;
   	minmin = INIT_MINMAX; maxmax = -minmin;
	for(np=0;np<validnpts;np++) {
		tableau[np]=mattab[np];
		if (mattab[np] < minmin) minmin = mattab[np];
		if (mattab[np] > maxmax) maxmax = mattab[np];
		}

	median0 = MedianArray(tableau, validnpts);
	
	/*Recherche Valeur Min*/
	median = median0;
	*min = median0;
	for (ii=0; ii<3; ii++) {
		npts=-1;
		for(np=0;np<validnpts;np++)
			if (median0 == minmin) {
					if (mattab[np] <= median) {
						npts++;
						tableau[npts]=mattab[np];
					}
				} else {
					if (mattab[np] < median) {
						npts++;
						tableau[npts]=mattab[np];
					}
				}
		median = MedianArray(tableau, npts);
		if (median == minmin) median = *min;
		*min = median;
	}

	/*Recherche Valeur Max*/
	median = median0;
	*max = median0;
	for (ii=0; ii<3; ii++) {
		npts=-1;
		for(np=0;np<validnpts;np++)
				if (median0 == maxmax) {
					if (mattab[np] >= median) {
						npts++;
						tableau[npts]=mattab[np];
					}
				} else {
					if (mattab[np] > median) {
						npts++;
						tableau[npts]=mattab[np];
					}
				}
		median = MedianArray(tableau, npts);
		if (median == maxmax) median = *max;
		*max = median;
	}

	free_vector_float(tableau);
	free_vector_float(mattab);

}


