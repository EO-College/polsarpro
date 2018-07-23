/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : rawbinary_convert_ModPha_T3.c
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

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

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

/* T3 matrix */
#define T11m   0
#define T12m   1
#define T12p   2
#define T13m   3
#define T13p   4
#define T22m   5
#define T23m   6
#define T23p   7
#define T33m   8

/* ROUTINES DECLARATION */
#include "../lib/matrix.h"
#include "../lib/util.h"

/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* GLOBAL ARRAYS */
float **M_tmp;
float **M_in;
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
  char File7[FilePathLength],File8[FilePathLength],File9[FilePathLength];
  char DirOutput[FilePathLength],file_name[FilePathLength],DataFormat[10];
  char *FileOutputT3[9] = { "T11.bin", "T12_real.bin", "T12_imag.bin",
                "T13_real.bin", "T13_imag.bin", "T22.bin",
                "T23_real.bin", "T23_imag.bin", "T33.bin"};
  char *FileOutputC3[9] = { "C11.bin", "C12_real.bin", "C12_imag.bin",
                "C13_real.bin", "C13_imag.bin", "C22.bin",
                "C23_real.bin", "C23_imag.bin", "C33.bin"};
  char PolarCase[20], PolarType[20];

  int lig, col,l, np, ind;
  int Ncol;
  int Nligoffset, Ncoloffset;
  int Nligfin, Ncolfin;
  int SubSampRG, SubSampAZ;
//int  Symmetrisation;
  int IEEE, Npolar_in, Npolar_out;

  char *pc;
  float fl1;
  float *v;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 21) {
  strcpy(DirOutput, argv[1]);
  Ncol = atoi(argv[2]);
  Nligoffset = atoi(argv[3]);
  Ncoloffset = atoi(argv[4]);
  Nligfin = atoi(argv[5]);
  Ncolfin = atoi(argv[6]);
  IEEE = atoi(argv[7]);
//  Symmetrisation = atoi(argv[8]);
  strcpy(DataFormat, argv[9]);
   SubSampRG = atoi(argv[10]);
  SubSampAZ = atoi(argv[11]);
  strcpy(File1, argv[12]);
  strcpy(File2, argv[13]);
  strcpy(File3, argv[14]);
  strcpy(File4, argv[15]);
  strcpy(File5, argv[16]);
  strcpy(File6, argv[17]);
  strcpy(File7, argv[18]);
  strcpy(File8, argv[19]);
  strcpy(File9, argv[20]);
  } else {
  printf("TYPE: rawbinary_convert_ModPha_T3 DirOutput Ncol OffsetLig OffsetCol\n");
  printf("FinalNlig FinalNcol IEEEFormat_Convert (0/1) Symmetrisation OutputDataFormat\n");
  printf("SubSampRG SubSampAZ\n");
  printf("FileInput1 FileInput2 FileInput3 FileInput4 FileInput5 FileInput6\n");
  printf("FileInput7 FileInput8 FileInput9\n");
  exit(1);
  }

  check_file(File1);check_file(File2);
  check_file(File3);check_file(File4);
  check_file(File5);check_file(File6);
  check_file(File7);check_file(File8);
  check_file(File9);
  check_dir(DirOutput);

/* Nb of lines and rows sub-sampled image */
  Nligfin = (int) floor(Nligfin / SubSampAZ);
  Ncolfin = (int) floor(Ncolfin / SubSampRG);
  if (strcmp(DataFormat, "T3") == 0) strcpy(PolarCase, "monostatic");
  if (strcmp(DataFormat, "C3") == 0) strcpy(PolarCase, "monostatic");
  strcpy(PolarType, "full");
  write_config(DirOutput, Nligfin, Ncolfin, PolarCase, PolarType);

  Npolar_in = 9;
  if (strcmp(DataFormat, "T3") == 0) Npolar_out = 9;
  if (strcmp(DataFormat, "C3") == 0) Npolar_out = 9;

  M_tmp = matrix_float(Npolar_in, Ncol);
  M_in = matrix_float(9, Ncol);
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
  if ((in_file[6] = fopen(File7, "rb")) == NULL)
    edit_error("Could not open input file : ", File7);
  if ((in_file[7] = fopen(File8, "rb")) == NULL)
    edit_error("Could not open input file : ", File8);
  if ((in_file[8] = fopen(File9, "rb")) == NULL)
    edit_error("Could not open input file : ", File9);

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
  for (np = 0; np < Npolar_in; np++) {
    fread(&M_tmp[0][0], sizeof(float), Ncol, in_file[np]);
    }
  }

for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}
    for (np = 0; np < Npolar_in; np++) {
     if (IEEE == 0)
      fread(&M_tmp[np][0], sizeof(float), Ncol, in_file[np]);
    if (IEEE == 1) {
      for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[np]);pc[2] = getc(in_file[np]);
        pc[1] = getc(in_file[np]);pc[0] = getc(in_file[np]);
        M_tmp[np][col] = fl1;
        }
      }
    }
   for (col = 0; col < Ncol; col++) {
     M_in[T311][col] = M_tmp[T11m][col];
     M_in[T312_re][col] = M_tmp[T12m][col]*cos(M_tmp[T12p][col]);
     M_in[T312_im][col] = M_tmp[T12m][col]*sin(M_tmp[T12p][col]);
     M_in[T313_re][col] = M_tmp[T13m][col]*cos(M_tmp[T13p][col]);
     M_in[T313_im][col] = M_tmp[T13m][col]*sin(M_tmp[T13p][col]);
     M_in[T322][col] = M_tmp[T22m][col];
     M_in[T323_re][col] = M_tmp[T23m][col]*cos(M_tmp[T23p][col]);
     M_in[T323_im][col] = M_tmp[T23m][col]*sin(M_tmp[T23p][col]);
     M_in[T333][col] = M_tmp[T33m][col];
     for (np = 0; np < 9; np++)  if (my_isfinite(M_in[np][col]) == 0) M_in[np][col] = eps;
     }

  if (strcmp(DataFormat, "T3") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    ind = col * SubSampRG + Ncoloffset;
    M_out[T311][col] = M_in[T311][ind];
    M_out[T312_re][col] = M_in[T312_re][ind];
    M_out[T312_im][col] = M_in[T312_im][ind];
    M_out[T313_re][col] = M_in[T313_re][ind];
    M_out[T313_im][col] = M_in[T313_im][ind];
    M_out[T322][col] = M_in[T322][ind];
    M_out[T323_re][col] = M_in[T323_re][ind];
    M_out[T323_im][col] = M_in[T323_im][ind];
    M_out[T333][col] = M_in[T333][ind];
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), Ncolfin, out_file[np]);
  }

  if (strcmp(DataFormat, "C3") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    ind = col * SubSampRG + Ncoloffset;
    M_out[C311][col] = (M_in[T311][ind] + 2 * M_in[T312_re][ind] + M_in[T322][ind]) / 2;
    M_out[C312_re][col] = (M_in[T313_re][ind] + M_in[T323_re][ind]) / sqrt(2);
    M_out[C312_im][col] = (M_in[T313_im][ind] + M_in[T323_im][ind]) / sqrt(2);
    M_out[C313_re][col] = (M_in[T311][ind] - M_in[T322][ind]) / 2;
    M_out[C313_im][col] = -M_in[T312_im][ind];
    M_out[C322][col] = M_in[T333][ind];
    M_out[C323_re][col] = (M_in[T313_re][ind] - M_in[T323_re][ind]) / sqrt(2);
    M_out[C323_im][col] = (-M_in[T313_im][ind] + M_in[T323_im][ind]) / sqrt(2);
    M_out[C333][col] = (M_in[T311][ind] - 2 * M_in[T312_re][ind] + M_in[T322][ind]) / 2;
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), Ncolfin, out_file[np]);
  }

  for (l = 1; l < SubSampAZ; l++) {
    for (np = 0; np < Npolar_in; np++) {
       fread(&M_tmp[0][0], sizeof(float), Ncol, in_file[np]);
       }
    }

  }

  for (np = 0; np < Npolar_in; np++)
  fclose(in_file[np]);
  for (np = 0; np < Npolar_out; np++)
  fclose(out_file[np]);

  free_matrix_float(M_out, Npolar_out);
  free_matrix_float(M_tmp, Npolar_in);
  free_matrix_float(M_in, 9);

  return 1;
}
