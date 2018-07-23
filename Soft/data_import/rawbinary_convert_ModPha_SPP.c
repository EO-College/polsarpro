/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : rawbinary_convert_ModPha_SPP.c
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

Output Format = SPP
Outputs : In Main directory
config.txt
mode pp1: s11.bin, s21.bin
mode pp2: s12.bin, s22.bin
mode pp3: s11.bin, s22.bin

Output Format = IPP
Outputs : In Main directory
config.txt
mode pp5: I11.bin, I21.bin
mode pp6: I12.bin, I22.bin
mode pp7: I11.bin, I22.bin

Output Format = C2
Outputs : In C3 directory
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

/* C2 matrix */
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
float **M_tmp;
float **M_in;
float **M_out;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------

Description :  Convert Raw Binary Data Files (Format SLC)

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

  char File1[FilePathLength],File2[FilePathLength],File3[FilePathLength],File4[FilePathLength];
  char DirOutput[FilePathLength],file_name[FilePathLength],DataFormat[10];
  char *FileOutputSPP1[2] = { "s11.bin", "s21.bin"};
  char *FileOutputSPP2[2] = { "s22.bin", "s12.bin"};
  char *FileOutputSPP3[2] = { "s11.bin", "s22.bin"};
  char *FileOutputIPP5[2] = { "I11.bin", "I21.bin"};
  char *FileOutputIPP6[2] = { "I22.bin", "I12.bin"};
  char *FileOutputIPP7[2] = { "I11.bin", "I22.bin"};
  char *FileOutputC2[4] = { "C11.bin", "C12_real.bin", "C12_imag.bin","C22.bin"};
  char PolarCase[20], PolarType[20], PolarPP[20];

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
  float k1r,k1i,k2r,k2i;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 17) {
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
  strcpy(PolarPP, argv[12]);
  strcpy(File1, argv[13]);
  strcpy(File2, argv[14]);
  strcpy(File3, argv[15]);
  strcpy(File4, argv[16]);
  } else {
  printf("TYPE: rawbinary_convert_ModPha_SPP DirOutput Ncol OffsetLig OffsetCol\n");
  printf("FinalNlig FinalNcol IEEEFormat_Convert (0/1) Symmetrisation OutputDataFormat\n");
  printf("SubSampRG SubSampAZ PolarType (PP1, PP2, PP3)\n");
  printf("FileInput1 FileInput2 FileInput3 FileInput4\n");
  exit(1);
  }

  check_file(File1);check_file(File2);
  check_file(File3);check_file(File4);
  check_dir(DirOutput);

/* Nb of lines and rows sub-sampled image */
  Nligfin = (int) floor(Nligfin / SubSampAZ);
  Ncolfin = (int) floor(Ncolfin / SubSampRG);
  strcpy(PolarCase, "monostatic");
  if (strcmp(DataFormat, "SPP") == 0) {
    if (strcmp(PolarPP, "PP1") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolarPP, "PP2") == 0) strcpy(PolarType, "pp2");
    if (strcmp(PolarPP, "PP3") == 0) strcpy(PolarType, "pp3");
    }
  if (strcmp(DataFormat, "IPP") == 0) {
    strcpy(PolarCase, "intensities");
    if (strcmp(PolarPP, "PP1") == 0) strcpy(PolarType, "pp5");
    if (strcmp(PolarPP, "PP2") == 0) strcpy(PolarType, "pp6");
    if (strcmp(PolarPP, "PP3") == 0) strcpy(PolarType, "pp7");
    }
  if (strcmp(DataFormat, "C2") == 0) {
    if (strcmp(PolarPP, "PP1") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolarPP, "PP2") == 0) strcpy(PolarType, "pp2");
    if (strcmp(PolarPP, "PP3") == 0) strcpy(PolarType, "pp3");
    }
  write_config(DirOutput, Nligfin, Ncolfin, PolarCase, PolarType);

  Npolar_in = 4;
  if (strcmp(DataFormat, "SPP") == 0) Npolar_out = 2;
  if (strcmp(DataFormat, "IPP") == 0) Npolar_out = 2;
  if (strcmp(DataFormat, "C2") == 0) Npolar_out = 4;

  M_tmp = matrix_float(Npolar_in, Ncol);
  M_in = matrix_float(2, 2 * Ncol);
  if (strcmp(DataFormat, "SPP") == 0) M_out = matrix_float(Npolar_out, 2 * Ncolfin);
  if (strcmp(DataFormat, "IPP") == 0) M_out = matrix_float(Npolar_out, Ncolfin);
  if (strcmp(DataFormat, "C2") == 0) M_out = matrix_float(Npolar_out, Ncolfin);

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

  for (np = 0; np < Npolar_out; np++) {
  if (strcmp(DataFormat, "SPP") == 0) {
    if (strcmp(PolarPP, "PP1") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputSPP1[np]);
    if (strcmp(PolarPP, "PP2") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputSPP2[np]);
    if (strcmp(PolarPP, "PP3") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputSPP3[np]);
    }
  if (strcmp(DataFormat, "IPP") == 0) {
    if (strcmp(PolarPP, "PP1") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputIPP5[np]);
    if (strcmp(PolarPP, "PP2") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputIPP6[np]);
    if (strcmp(PolarPP, "PP3") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputIPP7[np]);
    }
  if (strcmp(DataFormat, "C2") == 0) sprintf(file_name, "%s%s", DirOutput, FileOutputC2[np]);
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
     M_in[0][2 * col] = M_tmp[0][col]*cos(M_tmp[1][col]);
     M_in[0][2 * col + 1] = M_tmp[0][col]*sin(M_tmp[1][col]);
     M_in[1][2 * col] = M_tmp[2][col]*cos(M_tmp[3][col]);
     M_in[1][2 * col + 1] = M_tmp[2][col]*sin(M_tmp[3][col]);
     for (np = 0; np < 2; np++) {
      if (my_isfinite(M_in[np][2 * col]) == 0) M_in[np][2 * col] = eps;
      if (my_isfinite(M_in[np][2 * col + 1]) == 0) M_in[np][2 * col + 1] = eps;
      }
     }
  if (strcmp(DataFormat, "SPP") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    ind = 2 * (col * SubSampRG + Ncoloffset);
    M_out[0][2*col] = M_in[0][ind];
    M_out[0][2*col + 1] = M_in[0][ind + 1];
    M_out[1][2*col] = M_in[1][ind];
    M_out[1][2*col + 1] = M_in[1][ind + 1];
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), 2 * Ncolfin, out_file[np]);
  }

  if (strcmp(DataFormat, "IPP") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    ind = 2 * (col * SubSampRG + Ncoloffset);
    M_out[0][col] = M_in[0][ind]*M_in[0][ind]+M_in[0][ind + 1]*M_in[0][ind + 1];
    M_out[1][col] = M_in[1][ind]*M_in[1][ind]+M_in[1][ind + 1]*M_in[1][ind + 1];
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), Ncolfin, out_file[np]);
  }

  if (strcmp(DataFormat, "C2") == 0) {
  for (col = 0; col < Ncolfin; col++) {
    ind = 2 * (col * SubSampRG + Ncoloffset);
    k1r = M_in[0][ind]; k1i = M_in[0][ind + 1];
    k2r = M_in[1][ind]; k2i = M_in[1][ind + 1];
    M_out[C11][col] = k1r * k1r + k1i * k1i;
    M_out[C12_re][col] = k1r * k2r + k1i * k2i;
    M_out[C12_im][col] = k1i * k2r - k1r * k2i;
    M_out[C22][col] = k2r * k2r + k2i * k2i;
    }
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), Ncolfin, out_file[np]);
  }

  for (l = 1; l < SubSampAZ; l++) {
    for (np = 0; np < Npolar_in; np++) {
       fread(&M_tmp[0][0], sizeof(float), 2 * Ncol, in_file[np]);
       }
    }

  }

  for (np = 0; np < Npolar_in; np++)
  fclose(in_file[np]);
  for (np = 0; np < Npolar_out; np++)
  fclose(out_file[np]);

  free_matrix_float(M_out, Npolar_out);
  free_matrix_float(M_tmp, Npolar_in);
  free_matrix_float(M_in, 2);

  return 1;
}
