/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File   : Ipp_to_Ipp_mlk.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 2.0
Creation : 08/2006
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
Description :  Conversion from Partial Intensity elements to Intensity Elements

Range and azimut multilooking

Inputs  :
PP5 -> I11.bin, I21.bin
PP6 -> I12.bin, I22.bin
PP7 -> I11.bin, I22.bin

PP4 -> I11.bin, I12.bin, I22.bin
full -> I11.bin, I12.bin, I21.bin, I22.bin

Outputs : config.txt
PP5 -> I11.bin, I21.bin
PP6 -> I12.bin, I22.bin
PP7 -> I11.bin, I22.bin

PP4 -> I11.bin, I12.bin, I22.bin
full -> I11.bin, I12.bin, I21.bin, I22.bin

*-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
float ***matrix3d_float(int nz,int nrh,int nch);
void free_matrix3d_float(float ***m,int nz,int nrh);
void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType);
void write_config(char *dir, int Nlig, int Ncol, char *PolarCase, char *PolarType);
*******************************************************************************/


#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* I matrix */
#define I11  0
#define I21  1
#define I12  2
#define I22  3

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/matrix.h"
#include "../lib/util.h"


/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Conversion from Partial Intensity elements to Intensity Elements

Range and azimut multilooking

Inputs  :
PP4 -> I11.bin, I12.bin, I22.bin
PP5 -> I11.bin, I21.bin
PP6 -> I12.bin, I22.bin
PP7 -> I11.bin, I22.bin

PP4 -> I11.bin, I12.bin, I22.bin
full -> I11.bin, I12.bin, I21.bin, I22.bin

Outputs : config.txt
PP5 -> I11.bin, I21.bin
PP6 -> I12.bin, I22.bin
PP7 -> I11.bin, I22.bin

PP4 -> I11.bin, I12.bin, I22.bin
full -> I11.bin, I12.bin, I21.bin, I22.bin

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/


int main(int argc, char *argv[])
{


/* LOCAL VARIABLES */


/* Input/Output file pointer arrays */
  FILE *in_file[4], *out_file[4];


/* Strings */
  char file_name[FilePathLength], in_dir[FilePathLength], out_dir[FilePathLength];
  char *file_name_inout[4] = { "I11.bin", "I21.bin", "I12.bin", "I22.bin" };

  char PolarCase[20], PolarType[20];


/* Input variables */
  int Nlig, Ncol;    /* Initial image nb of lines and rows */
  int Off_lig, Off_col;  /* Lines and rows offset values */
  int Sub_Nlig, Sub_Ncol;  /* Sub-image nb of lines and rows */
  int Nlook_lig, Nlook_col;  /* Number of looks in azimuth and range */


/* Output variables */
  int M_Nlig, M_Ncol;    /* Nb of lines and rows multilooked image */


/* Internal variables */
  int np, i, j, ii, jj, ind;
  int PolInOut[2];
  int Npolar_in, Npolar_out;

/* Matrix arrays */
  float ***M_in;    /* S matrix 3D array (lig,col,element) */
  float **M_out;    /* C matrix 2D array (col,element) */

/* PROGRAM START */

  if (argc == 9) {
  strcpy(in_dir, argv[1]);
  strcpy(out_dir, argv[2]);
  Off_lig = atoi(argv[3]);
  Off_col = atoi(argv[4]);
  Sub_Nlig = atoi(argv[5]);
  Sub_Ncol = atoi(argv[6]);
  Nlook_col = atoi(argv[7]);
  Nlook_lig = atoi(argv[8]);
  } else
  edit_error("Ipp_to_Ipp_mlk in_dir out_dir offset_lig offset_col sub_nlig sub_ncol n_look_rg n_look_az","");


  check_dir(in_dir);
  check_dir(out_dir);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* Nb of lines and rows multilooked image */
  M_Nlig = (int) floor(Sub_Nlig / Nlook_lig);
  M_Ncol = (int) floor(Sub_Ncol / Nlook_col);

  Npolar_in = 2; Npolar_out = 2;
  PolInOut[0] = 9999;
  if (strcmp(PolarType, "pp5") == 0) {
  PolInOut[0] = I11;
  PolInOut[1] = I21;
  }
  if (strcmp(PolarType, "pp6") == 0) {
  PolInOut[0] = I22;
  PolInOut[1] = I12;
  }
  if (strcmp(PolarType, "pp7") == 0) {
  PolInOut[0] = I11;
  PolInOut[1] = I22;
  }
  if (strcmp(PolarType, "pp4") == 0) {
  Npolar_in = 3; Npolar_out = 3;
  PolInOut[0] = I11;
  PolInOut[1] = I12;
  PolInOut[2] = I22;
  }
  if (strcmp(PolarType, "full") == 0) {
  Npolar_in = 4; Npolar_out = 4;
  PolInOut[0] = I11;
  PolInOut[1] = I12;
  PolInOut[2] = I21;
  PolInOut[3] = I22;
  }
  if (PolInOut[0] == 9999) edit_error("Not a correct PolarType","");

  M_in = matrix3d_float(Npolar_in, Nlook_lig, Ncol);
  M_out = matrix_float(Npolar_out, M_Ncol);

/* INPUT/OUTPUT FILE OPENING*/

  for (np = 0; np < Npolar_in; np++) {
  sprintf(file_name, "%s%s", in_dir, file_name_inout[PolInOut[np]]);
  if ((in_file[np] = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  }


  for (np = 0; np < Npolar_out; np++) {
  sprintf(file_name, "%s%s", out_dir, file_name_inout[PolInOut[np]]);
  if ((out_file[np] = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  }


/* OFFSET LINES READING */
  for (i = 0; i < Off_lig; i++)
  for (np = 0; np < Npolar_in; np++)
    fread(&M_in[0][0][0], sizeof(float), Ncol, in_file[np]);


/* READING AND MULTILOOKING */
  for (i = 0; i < M_Nlig; i++) {
  if (i%(int)(M_Nlig/20) == 0) {printf("%f\r", 100. * i / (M_Nlig - 1));fflush(stdout);}

/* Read Nlook_lig in each polarisation */
  for (np = 0; np < Npolar_in; np++)
    for (ii = 0; ii < Nlook_lig; ii++)
    fread(&M_in[np][ii][0], sizeof(float), Ncol, in_file[np]);


  for (j = 0; j < M_Ncol; j++) {
    for (np = 0; np < Npolar_out; np++) M_out[np][j] = 0;

/* Conversion and averaging over the Nlook_lig lines and Nlook_col rows */
    for (ii = 0; ii < Nlook_lig; ii++) {
    for (jj = 0; jj < Nlook_col; jj++) {
      ind = (j * Nlook_col + jj + Off_col);
      for (np = 0; np < Npolar_out; np++) M_out[np][j] += M_in[np][ii][ind];
    }  /*jj */
    }  /*ii */
/* Normalization */
    for (np = 0; np < Npolar_out; np++)
    M_out[np][j] /= Nlook_lig * Nlook_col;
  }  /*j */
/* OUPUT DATA WRITING */
  for (np = 0; np < Npolar_out; np++)
    fwrite(&M_out[np][0], sizeof(float), M_Ncol, out_file[np]);
  }  /*i */


/* FILE CLOSING */
  for (np = 0; np < Npolar_in; np++)
  fclose(in_file[np]);
  for (np = 0; np < Npolar_out; np++)
  fclose(out_file[np]);

  free_matrix_float(M_out, Npolar_out);
  free_matrix3d_float(M_in, Npolar_in, Nlook_lig);

  return 1;
}        /*main */
