/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : rawbinary_convert_Cmplx_MLK_T3.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 11/2004
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

Description :  Convert Raw Binary Data Files (Format 3x3 coherency matrix)

Output Format = T3
Outputs : In T3 directory
config.txt
T11.bin, T12_real.bin, T12_imag.bin, T13_real.bin, T13_imag.bin
T22.bin, T23_real.bin, T23_imag.bin
T33.bin

Output Format = C3
Outputs : In C3 directory
config.txt
C11.bin, C12_real.bin, C12_imag.bin, C13_real.bin, C13_imag.bin
C22.bin, C23_real.bin, C23_imag.bin
C33.bin

*-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
void check_file(char *file);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
void write_config(char *dir, int Nlig, int Ncol, char *PolarCase, char *PolarType);

*******************************************************************************/
/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* T3 matrix */
#define T11   0
#define T12   1
#define T13   2
#define T22   3
#define T23   4
#define T33   5

/* T3 matrix */
#define T311   0
#define T312_re  1
#define T312_im  2
#define T313_re  3
#define T313_im  4
#define T322   5
#define T323_re  6
#define T323_im  7
#define T333   8
/* C3 matrix */
#define C311   0
#define C312_re  1
#define C312_im  2
#define C313_re  3
#define C313_im  4
#define C322   5
#define C323_re  6
#define C323_im  7
#define C333   8

/* ROUTINES DECLARATION */
#include "../lib/matrix.h"
#include "../lib/util.h"

/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* GLOBAL ARRAYS */
float ***M_tmp;
float ***M_in;
float **M_out;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------

Description :  Convert Raw Binary Data Files (Format 3x3 coherency matrix)

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

  FILE *in_file[16], *out_file[16];

  char File1[FilePathLength],File2[FilePathLength],File3[FilePathLength],File4[FilePathLength],File5[FilePathLength],File6[FilePathLength];
  char DirOutput[FilePathLength],file_name[FilePathLength],DataFormat[10];
  char *FileOutputT3[9] = { "T11.bin", "T12_real.bin", "T12_imag.bin",
                "T13_real.bin", "T13_imag.bin", "T22.bin",
                "T23_real.bin", "T23_imag.bin", "T33.bin"};
  char *FileOutputC3[9] = { "C11.bin", "C12_real.bin", "C12_imag.bin",
                "C13_real.bin", "C13_imag.bin", "C22.bin",
                "C23_real.bin", "C23_imag.bin", "C33.bin"};
  char PolarCase[20], PolarType[20];

  int lig, col,ii,jj,np,ind;
  int Ncol;
  int Nligoffset, Ncoloffset;
  int Nligfin, Ncolfin;
  int Nlook_col, Nlook_lig;
//int  Symmetrisation;
  int IEEE, Npolar_in, Npolar_out;

  char *pc;
  float fl1, fl2;
  float *v;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc < 18) {
  printf("TYPE: rawbinary_convert_Cmplx_MLK_T3 DirOutput Ncol OffsetLig OffsetCol\n");
  printf("FinalNlig FinalNcol IEEEFormat_Convert (0/1) Symmetrisation OutputDataFormat\n");
  printf("Nlook_col Nlook_lig\n");
  printf("FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6\n");
  exit(1);
  } else {
  strcpy(DirOutput, argv[1]);
  Ncol = atoi(argv[2]);
  Nligoffset = atoi(argv[3]);
  Ncoloffset = atoi(argv[4]);
  Nligfin = atoi(argv[5]);
  Ncolfin = atoi(argv[6]);
  IEEE = atoi(argv[7]);
//  Symmetrisation = atoi(argv[8]);
  strcpy(DataFormat, argv[9]);
   Nlook_col = atoi(argv[10]);
  Nlook_lig = atoi(argv[11]);
  strcpy(File1, argv[12]);
  strcpy(File2, argv[13]);
  strcpy(File3, argv[14]);
  strcpy(File4, argv[15]);
  strcpy(File5, argv[16]);
  strcpy(File6, argv[17]);
  }

  check_file(File1);check_file(File2);
  check_file(File3);check_file(File4);
  check_file(File5);check_file(File6);
  check_dir(DirOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* Nb of lines and rows sub-sampled image */
  Nligfin = (int) floor(Nligfin / Nlook_lig);
  Ncolfin = (int) floor(Ncolfin / Nlook_col);
  if (strcmp(DataFormat, "T3") == 0) strcpy(PolarCase, "monostatic");
  if (strcmp(DataFormat, "C3") == 0) strcpy(PolarCase, "monostatic");
  strcpy(PolarType, "full");
  write_config(DirOutput, Nligfin, Ncolfin, PolarCase, PolarType);

  Npolar_in = 6;
  if (strcmp(DataFormat, "T3") == 0) Npolar_out = 9;
  if (strcmp(DataFormat, "C3") == 0) Npolar_out = 9;

  M_tmp = matrix3d_float(Npolar_in, Nlook_lig, 2 * Ncol);
  M_in = matrix3d_float(9, Nlook_lig, Ncol);
  if (strcmp(DataFormat, "T3") == 0) M_out = matrix_float(Npolar_out, Ncolfin);
  if (strcmp(DataFormat, "C3") == 0) M_out = matrix_float(Npolar_out, Ncolfin);

/******************************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/******************************************************************************/

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

  for (np = 0; np < Npolar_out; np++) {
  if (strcmp(DataFormat, "T3") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputT3[np]);
  if (strcmp(DataFormat, "C3") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputC3[np]);
  if ((out_file[np] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  }

/******************************************************************************/
for (np = 0; np < Npolar_in; np++)
   rewind(in_file[np]);
 
for (lig = 0; lig < Nligoffset; lig++) {
  fread(&M_tmp[0][0][0], sizeof(float), Ncol, in_file[T11]);
  fread(&M_tmp[0][0][0], sizeof(float), 2*Ncol, in_file[T12]);
  fread(&M_tmp[0][0][0], sizeof(float), 2*Ncol, in_file[T13]);
  fread(&M_tmp[0][0][0], sizeof(float), Ncol, in_file[T22]);
  fread(&M_tmp[0][0][0], sizeof(float), 2*Ncol, in_file[T23]);
  fread(&M_tmp[0][0][0], sizeof(float), Ncol, in_file[T33]);
  }

for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}
  for (ii = 0; ii < Nlook_lig; ii++) {
     if (IEEE == 0) {
      fread(&M_tmp[T11][ii][0], sizeof(float), Ncol, in_file[T11]);
      fread(&M_tmp[T12][ii][0], sizeof(float), 2 * Ncol, in_file[T12]);
      fread(&M_tmp[T13][ii][0], sizeof(float), 2 * Ncol, in_file[T13]);
      fread(&M_tmp[T22][ii][0], sizeof(float), Ncol, in_file[T22]);
      fread(&M_tmp[T23][ii][0], sizeof(float), 2 * Ncol, in_file[T23]);
      fread(&M_tmp[T33][ii][0], sizeof(float), Ncol, in_file[T33]);
      }
    if (IEEE == 1) {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[T11]);pc[2] = getc(in_file[T11]);
        pc[1] = getc(in_file[T11]);pc[0] = getc(in_file[T11]);
        M_tmp[T11][ii][2 * col] = fl1;M_tmp[T11][ii][2 * col +1] = 0.;
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[T12]);pc[2] = getc(in_file[T12]);
        pc[1] = getc(in_file[T12]);pc[0] = getc(in_file[T12]);
        v = &fl2;pc = (char *) v;
        pc[3] = getc(in_file[T12]);pc[2] = getc(in_file[T12]);
        pc[1] = getc(in_file[T12]);pc[0] = getc(in_file[T12]);
        M_tmp[T12][ii][2 * col] = fl1;M_tmp[T12][ii][2 * col + 1] = fl2;
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[T13]);pc[2] = getc(in_file[T13]);
        pc[1] = getc(in_file[T13]);pc[0] = getc(in_file[T13]);
        v = &fl2;pc = (char *) v;
        pc[3] = getc(in_file[T13]);pc[2] = getc(in_file[T13]);
        pc[1] = getc(in_file[T13]);pc[0] = getc(in_file[T13]);
        M_tmp[T13][ii][2 * col] = fl1;M_tmp[T13][ii][2 * col + 1] = fl2;
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[T22]);pc[2] = getc(in_file[T22]);
        pc[1] = getc(in_file[T22]);pc[0] = getc(in_file[T22]);
        M_tmp[T22][ii][2 * col] = fl1;M_tmp[T22][ii][2 * col +1] = 0.;
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[T23]);pc[2] = getc(in_file[T23]);
        pc[1] = getc(in_file[T23]);pc[0] = getc(in_file[T23]);
        v = &fl2;pc = (char *) v;
        pc[3] = getc(in_file[T23]);pc[2] = getc(in_file[T23]);
        pc[1] = getc(in_file[T23]);pc[0] = getc(in_file[T23]);
        M_tmp[T23][ii][2 * col] = fl1;M_tmp[T23][ii][2 * col + 1] = fl2;
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[T33]);pc[2] = getc(in_file[T33]);
        pc[1] = getc(in_file[T33]);pc[0] = getc(in_file[T33]);
        M_tmp[T33][ii][2 * col] = fl1;M_tmp[T33][ii][2 * col +1] = 0.;
        }
      }
    for (col = 0; col < Ncol; col++) {
      M_in[T311][ii][col] = M_tmp[T11][ii][2 * col];
      M_in[T312_re][ii][col] = M_tmp[T12][ii][2 * col];
      M_in[T312_im][ii][col] = M_tmp[T12][ii][2 * col + 1];
      M_in[T313_re][ii][col] = M_tmp[T13][ii][2 * col];
      M_in[T313_im][ii][col] = M_tmp[T13][ii][2 * col + 1];
      M_in[T322][ii][col] = M_tmp[T22][ii][2 * col];
      M_in[T323_re][ii][col] = M_tmp[T23][ii][2 * col];
      M_in[T323_im][ii][col] = M_tmp[T23][ii][2 * col + 1];
      M_in[T333][ii][col] = M_tmp[T33][ii][2 * col];
      for (np = 0; np < 9; np++) if (my_isfinite(M_in[np][ii][col]) == 0) M_in[np][ii][col] = eps;
      }
    } /* ii */

  if (strcmp(DataFormat, "T3") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    for (np = 0; np < Npolar_out; np++) M_out[np][col] = 0.;
    for (ii = 0; ii < Nlook_lig; ii++) {
      for (jj = 0; jj < Nlook_col; jj++) {
        ind = col * Nlook_col + jj + Ncoloffset;
        M_out[T311][col] += M_in[T311][ii][ind];
        M_out[T312_re][col] += M_in[T312_re][ii][ind];
        M_out[T312_im][col] += M_in[T312_im][ii][ind];
        M_out[T313_re][col] += M_in[T313_re][ii][ind];
        M_out[T313_im][col] += M_in[T313_im][ii][ind];
        M_out[T322][col] += M_in[T322][ii][ind];
        M_out[T323_re][col] += M_in[T323_re][ii][ind];
        M_out[T323_im][col] += M_in[T323_im][ii][ind];
        M_out[T333][col] += M_in[T333][ii][ind];
        }
      }
    for (np = 0; np < Npolar_out; np++) M_out[np][col] /= Nlook_lig * Nlook_col;
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), Ncolfin, out_file[np]);
  }

  if (strcmp(DataFormat, "C3") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    for (np = 0; np < Npolar_out; np++) M_out[np][col] = 0.;
    for (ii = 0; ii < Nlook_lig; ii++) {
      for (jj = 0; jj < Nlook_col; jj++) {
        ind = col * Nlook_col + jj + Ncoloffset;
        M_out[C311][col] = (M_in[T311][ii][ind] + 2 * M_in[T312_re][ii][ind] + M_in[T322][ii][ind]) / 2;
        M_out[C312_re][col] = (M_in[T313_re][ii][ind] + M_in[T323_re][ii][ind]) / sqrt(2);
        M_out[C312_im][col] = (M_in[T313_im][ii][ind] + M_in[T323_im][ii][ind]) / sqrt(2);
        M_out[C313_re][col] = (M_in[T311][ii][ind] - M_in[T322][ii][ind]) / 2;
        M_out[C313_im][col] = -M_in[T312_im][ii][ind];
        M_out[C322][col] = M_in[T333][ii][ind];
        M_out[C323_re][col] = (M_in[T313_re][ii][ind] - M_in[T323_re][ii][ind]) / sqrt(2);
        M_out[C323_im][col] = (-M_in[T313_im][ii][ind] + M_in[T323_im][ii][ind]) / sqrt(2);
        M_out[C333][col] = (M_in[T311][ii][ind] - 2 * M_in[T312_re][ii][ind] + M_in[T322][ii][ind]) / 2;
        }
      }
    for (np = 0; np < Npolar_out; np++) M_out[np][col] /= Nlook_lig * Nlook_col;
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), Ncolfin, out_file[np]);
  }

  }

  for (np = 0; np < Npolar_in; np++)
  fclose(in_file[np]);
  for (np = 0; np < Npolar_out; np++)
  fclose(out_file[np]);

  free_matrix_float(M_out, Npolar_out);
  free_matrix3d_float(M_tmp, Npolar_in, Nlook_lig);
  free_matrix3d_float(M_in, 9, Nlook_lig);

  return 1;
}
