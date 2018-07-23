/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : rawbinary_convert_Cmplx_MLK_SPP.c
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

Description :  Convert Raw Binary Data Files (Format SLC - PP)

Output Format = C2
Outputs : In C2 directory
config.txt
C11.bin, C12_real.bin, C12_imag.bin, C22.bin

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

/* C4 matrix */
#define C11   0
#define C12_re  1
#define C12_im  2
#define C22   3

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

Description :  Convert Raw Binary Data Files (Format SLC - PP)

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

  char File1[FilePathLength],File2[FilePathLength];
  char DirOutput[FilePathLength],file_name[FilePathLength],DataFormat[10];
  char *FileOutputC2[4] = { "C11.bin", "C12_real.bin", "C12_imag.bin","C22.bin"};
  char PolarCase[20], PolarType[20], PolarPP[20];

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
  float k1r,k1i,k2r,k2i;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 15) {
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
  strcpy(PolarPP, argv[12]);
  strcpy(File1, argv[13]);
  strcpy(File2, argv[14]);
  } else {
  printf("TYPE: rawbinary_convert_Cmplx_MLK_SPP DirOutput Ncol OffsetLig OffsetCol\n");
  printf("FinalNlig FinalNcol IEEEFormat_Convert (0/1) Symmetrisation OutputDataFormat\n");
  printf("Nlook_col Nlook_lig PolarType (PP1,PP2,PP3)\n");
  printf("FileInput1 FileInput2\n");
  exit(1);
  }

  check_file(File1);check_file(File2);
  check_dir(DirOutput);

/* Nb of lines and rows sub-sampled image */
  Nligfin = (int) floor(Nligfin / Nlook_lig);
  Ncolfin = (int) floor(Ncolfin / Nlook_col);
  strcpy(PolarCase, "monostatic");
  if (strcmp(DataFormat, "C2") == 0) {
    if (strcmp(PolarPP, "PP1") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolarPP, "PP2") == 0) strcpy(PolarType, "pp2");
    if (strcmp(PolarPP, "PP3") == 0) strcpy(PolarType, "pp3");
    }
  write_config(DirOutput, Nligfin, Ncolfin, PolarCase, PolarType);

  Npolar_in = 2;
  if (strcmp(DataFormat, "C2") == 0) Npolar_out = 4;

  M_tmp = matrix3d_float(Npolar_in, Nlook_lig, 2 * Ncol);
  M_in = matrix3d_float(2, Nlook_lig, 2 * Ncol);
  if (strcmp(DataFormat, "C2") == 0) M_out = matrix_float(Npolar_out, Ncolfin);

/******************************************************************************/
/* INPUT / OUTPUT BINARY DATA FILES */
/******************************************************************************/

  if ((in_file[0] = fopen(File1, "rb")) == NULL)
    edit_error("Could not open input file : ", File1);
  if ((in_file[1] = fopen(File2, "rb")) == NULL)
    edit_error("Could not open input file : ", File2);

  for (np = 0; np < Npolar_out; np++) {
  if (strcmp(DataFormat, "C2") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputC2[np]);
  if ((out_file[np] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  }



/******************************************************************************/
for (np = 0; np < Npolar_in; np++)
   rewind(in_file[np]);

for (lig = 0; lig < Nligoffset; lig++) {
  for (np = 0; np < Npolar_in; np++) {
    fread(&M_tmp[0][0][0], sizeof(float), 2 * Ncol, in_file[np]);
    }
  }

for (lig = 0; lig < Nligfin; lig++) {
  if (lig%(int)(Nligfin/20) == 0) {printf("%f\r", 100. * lig / (Nligfin - 1));fflush(stdout);}
  for (ii = 0; ii < Nlook_lig; ii++) {
    for (np = 0; np < Npolar_in; np++) {
       if (IEEE == 0)
      fread(&M_tmp[np][ii][0], sizeof(float), 2 * Ncol, in_file[np]);
      if (IEEE == 1) {
        for (col = 0; col < Ncol; col++) {
        v = &fl1;pc = (char *) v;
        pc[3] = getc(in_file[np]);pc[2] = getc(in_file[np]);
        pc[1] = getc(in_file[np]);pc[0] = getc(in_file[np]);
        v = &fl2;pc = (char *) v;
        pc[3] = getc(in_file[np]);pc[2] = getc(in_file[np]);
        pc[1] = getc(in_file[np]);pc[0] = getc(in_file[np]);
        M_tmp[np][ii][2 * col] = fl1;M_tmp[np][ii][2 * col + 1] = fl2;
        }
        }
      }

  for (np = 0; np < Npolar_in; np++) {
   for (col = 0; col < Ncol; col++) {
     M_in[np][ii][2 * col] = M_tmp[np][ii][2 * col];
     M_in[np][ii][2 * col + 1] = M_tmp[np][ii][2 * col +1];
     if (my_isfinite(M_in[np][ii][2 * col]) == 0) M_in[np][ii][2 * col] = eps;
     if (my_isfinite(M_in[np][ii][2 * col + 1]) == 0) M_in[np][ii][2 * col + 1] = eps;
     }
   }
  } //ii//

  if (strcmp(DataFormat, "C2") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    for (np = 0; np < Npolar_out; np++) M_out[np][col] = 0.;
    for (ii = 0; ii < Nlook_lig; ii++) {
      for (jj = 0; jj < Nlook_col; jj++) {
        ind = 2*(col * Nlook_col + jj + Ncoloffset);
        k1r = M_in[0][ii][ind]; k1i = M_in[0][ii][ind + 1];
        k2r = M_in[1][ii][ind]; k2i = M_in[1][ii][ind + 1];
        M_out[C11][col] += k1r * k1r + k1i * k1i;
        M_out[C12_re][col] += k1r * k2r + k1i * k2i;
        M_out[C12_im][col] += k1i * k2r - k1r * k2i;
        M_out[C22][col] += k2r * k2r + k2i * k2i;
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
  free_matrix3d_float(M_in, 2, Nlook_lig);

  return 1;
}
