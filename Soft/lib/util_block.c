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

File   : util_block.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2010
Update  : 

*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team 
(SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

  Description :  UTIL Routines for Block Data Reading and Writing

*--------------------------------------------------------------------
Routines  :

int read_matrix_int(char *file_name, int **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix_float(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix_cmplx(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int write_matrix_int(char *file_name, int **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);
int write_matrix_float(char *file_name, float **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);
int write_matrix_cmplx(char *file_name, float **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);

int read_matrix3d_float(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int read_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol);
int write_matrix3d_float(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);
int write_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OOffLig, int OOffCol);

int read_block_matrix_int(FILE *in_file, int **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_float(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_matrix3d_float(FILE *in_file, float ***M_in, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_matrix_cmplx(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

int write_block_matrix_int(FILE *outfile, int **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_float(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_matrix3d_float(FILE *out_file, float ***M_out, int NNp, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix_cmplx(FILE *outfile, float **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix3d_float(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);
int write_block_matrix3d_cmplx(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol);

int read_block_S2_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_S2_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_S2T6_avg(FILE *datafile1[], FILE *datafile2[], float ***M_out, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_SPP_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_TCI_avg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);
int read_block_TCI_noavg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol);

int read_block_S2_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
int read_block_SPP_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"

/********************************************************************
Routine  : read_matrix_int
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a binary (int) file
********************************************************************/
int read_matrix_int(char *file_name, int **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol)
{
  FILE *in_file;
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;

  if ((in_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  for (lig = 0; lig < NNwinLigM1S2; lig++) 
    for (col = 0; col < NNcol + NNwinCol; col++) M_in[lig][col] = 0;

  for (lig = NNwinLigM1S2; lig < NNlig + NNwinLigM1S2; lig++) {
    for (col = 0; col < NNwinColM1S2; col++) M_in[lig][col] = 0;
    for (col = NNcol + NNwinColM1S2; col < NNcol + NNwinCol; col++) M_in[lig][col] = 0;
    fread(&M_in[lig][NNwinColM1S2], sizeof(int), NNcol, in_file);
  }

  if (NNwinLig > 1) {
    for (lig = NNlig + NNwinLigM1S2; lig < NNlig + NNwinLig; lig++) 
      for (col = 0; col < NNcol + NNwinCol; col++) M_in[lig][col] = 0;
    }
    
  fclose(in_file);

  return 1;
}

/********************************************************************
Routine  : read_matrix_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a binary (float) file
********************************************************************/
int read_matrix_float(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol)
{
  FILE *in_file;
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;

  if ((in_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  for (lig = 0; lig < NNwinLigM1S2; lig++) 
    for (col = 0; col < NNcol + NNwinCol; col++) M_in[lig][col] = 0.;

  for (lig = NNwinLigM1S2; lig < NNlig + NNwinLigM1S2; lig++) {
    for (col = 0; col < NNwinColM1S2; col++) M_in[lig][col] = 0.;
    for (col = NNcol + NNwinColM1S2; col < NNcol + NNwinCol; col++) M_in[lig][col] = 0.;
    fread(&M_in[lig][NNwinColM1S2], sizeof(float), NNcol, in_file); 
    }

  if (NNwinLig > 1) {
    for (lig = NNlig + NNwinLigM1S2; lig < NNlig + NNwinLig; lig++) 
      for (col = 0; col < NNcol + NNwinCol; col++) M_in[lig][col] = 0.;
    }

  fclose(in_file);

  return 1;
}

/********************************************************************
Routine  : read_matrix_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a binary (complex) file
********************************************************************/
int read_matrix_cmplx(char *file_name, float **M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol)
{
  FILE *in_file;
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;

  if ((in_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  for (lig = 0; lig < NNwinLigM1S2; lig++) 
    for (col = 0; col < 2*(NNcol + NNwinCol); col++) M_in[lig][col] = 0.;

  for (lig = NNwinLigM1S2; lig < NNlig + NNwinLigM1S2; lig++) {
    for (col = 0; col < 2*NNwinColM1S2; col++) M_in[lig][col] = 0.;
    for (col = 2*(NNcol + NNwinColM1S2); col < 2*(NNcol + NNwinCol); col++) M_in[lig][col] = 0.;
    fread(&M_in[lig][2*NNwinColM1S2], sizeof(float), 2*NNcol, in_file);
  }

  if (NNwinLig > 1) {
    for (lig = NNlig + NNwinLigM1S2; lig < NNlig + NNwinLig; lig++) 
      for (col = 0; col < 2*(NNcol + NNwinCol); col++) M_in[lig][col] = 0.;
    }
    
  fclose(in_file);

  return 1;
}

/********************************************************************
Routine  : write_matrix_int
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a binary (int) file
********************************************************************/
int write_matrix_int(char *file_name, int **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol)
{
  FILE *out_file;
  int lig;
//  int col;
  
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  for (lig = 0; lig < NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[OOffLig + lig][OOffCol + col]) == 0) M_out[OOffLig + lig][OOffCol + col] = 0;
//      }
    fwrite(&M_out[OOffLig + lig][OOffCol], sizeof(int), NNcol, out_file);
    }

  fclose(out_file);

  return 1;
}

/********************************************************************
Routine  : write_matrix_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a binary (float) file
********************************************************************/
int write_matrix_float(char *file_name, float **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol)
{
  FILE *out_file;
  int lig;
//  int col;
  
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  for (lig = 0; lig < NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[OOffLig + lig][OOffCol + col]) == 0) M_out[OOffLig + lig][OOffCol + col] = eps;
//      }
    fwrite(&M_out[OOffLig + lig][OOffCol], sizeof(float), NNcol, out_file);
    }

  fclose(out_file);

  return 1;
}

/********************************************************************
Routine  : write_matrix_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a binary (complex) file
********************************************************************/
int write_matrix_cmplx(char *file_name, float **M_out, int NNlig, int NNcol, int OOffLig, int OOffCol)
{
  FILE *out_file;
  int lig;
//  int col;
  
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  for (lig = 0; lig < NNlig; lig++) {
//    for (col = 0; col < 2*(OOffCol + NNcol); col++) {
//      if (my_isfinite(M_out[OOffLig + lig][col]) == 0) M_out[OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[OOffLig + lig][2*OOffCol], sizeof(float), 2*NNcol, out_file);
    }

  fclose(out_file);

  return 1;
}

/********************************************************************
Routine  : read_matrix3d_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a binary (float) file
********************************************************************/
int read_matrix3d_float(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol)
{
  FILE *in_file;
  int Np, lig, col;
  int NNwinLigM1S2, NNwinColM1S2;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;

for (Np = 0; Np < NNpolar; Np++) {
  if ((in_file = fopen(file_name[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name[Np]);
  
  for (lig = 0; lig < NNwinLigM1S2; lig++) 
    for (col = 0; col < NNcol + NNwinCol; col++) M_in[Np][lig][col] = 0.;

  for (lig = NNwinLigM1S2; lig < NNlig + NNwinLigM1S2; lig++) {
    for (col = 0; col < NNwinColM1S2; col++) M_in[Np][lig][col] = 0.;
    for (col = NNcol + NNwinColM1S2; col < NNcol + NNwinCol; col++) M_in[Np][lig][col] = 0.;
    fread(&M_in[Np][lig][NNwinColM1S2], sizeof(float), NNcol, in_file);
  }

  if (NNwinLig > 1) {
    for (lig = NNlig + NNwinLigM1S2; lig < NNlig + NNwinLig; lig++) 
      for (col = 0; col < NNcol + NNwinCol; col++) M_in[Np][lig][col] = 0.;
    }

  fclose(in_file);
  }

  return 1;
}

/********************************************************************
Routine  : read_matrix3d_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a binary (complex) file
********************************************************************/
int read_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_in, int NNlig, int NNcol, int NNwinLig, int NNwinCol)
{
  FILE *in_file;
  int Np, lig, col;
  int NNwinLigM1S2, NNwinColM1S2;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;

for (Np = 0; Np < NNpolar; Np++) {
  if ((in_file = fopen(file_name[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name[Np]);
  
  for (lig = 0; lig < NNwinLigM1S2; lig++) 
    for (col = 0; col < 2*(NNcol + NNwinCol); col++) M_in[Np][lig][col] = 0.;

  for (lig = NNwinLigM1S2; lig < NNlig + NNwinLigM1S2; lig++) {
    for (col = 0; col < 2*NNwinColM1S2; col++) M_in[Np][lig][col] = 0.;
    for (col = 2*(NNcol + NNwinColM1S2); col < 2*(NNcol + NNwinCol); col++) M_in[Np][lig][col] = 0.;
    fread(&M_in[Np][lig][2*NNwinColM1S2], sizeof(float), 2*NNcol, in_file);
  }

  if (NNwinLig > 1) {
    for (lig = NNlig + NNwinLigM1S2; lig < NNlig + NNwinLig; lig++) 
      for (col = 0; col < 2*(NNcol + NNwinCol); col++) M_in[Np][lig][col] = 0.;
    }
    
  fclose(in_file);
  }

  return 1;
}

/********************************************************************
Routine  : write_matrix3d_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a binary (float) file
********************************************************************/
int write_matrix3d_float(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OOffLig, int OOffCol)
{
  FILE *out_file;
  int Np;
  int lig;
//  int col;
  
for (Np = 0; Np < NNpolar; Np++) {
  if ((out_file = fopen(file_name[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name[Np]);

  for (lig = 0; lig < NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[Np][OOffLig + lig][OOffCol + col]) == 0) M_out[Np][OOffLig + lig][OOffCol + col] = eps;
//      }
    fwrite(&M_out[Np][OOffLig + lig][OOffCol], sizeof(float), NNcol, out_file);
    }

  fclose(out_file);
  }

  return 1;
}

/********************************************************************
Routine  : write_matrix3d_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a binary (complex) file
********************************************************************/
int write_matrix3d_cmplx(int NNpolar, char **file_name, float ***M_out, int NNlig, int NNcol, int OOffLig, int OOffCol)
{
  FILE *out_file;
  int Np;
  int lig;
//  int col;
  
for (Np = 0; Np < NNpolar; Np++) {
  if ((out_file = fopen(file_name[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name[Np]);

  for (lig = 0; lig < NNlig; lig++) {
//    for (col = 0; col < 2*(OOffCol + NNcol); col++) {
//      if (my_isfinite(M_out[Np][OOffLig + lig][col]) == 0) M_out[Np][OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[Np][OOffLig + lig][2*OOffCol], sizeof(float), 2*NNcol, out_file);
    }

  fclose(out_file);
  }

  return 1;
}

/********************************************************************
Routine  : read_block_matrix_int
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a block of a binary (int) file
********************************************************************/
int read_block_matrix_int(FILE *in_file, int **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {

    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      fread(&_VI_in[0], sizeof(int), NNcol, in_file);
  
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        M_in[lig][col] = 0;

    } else {

    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * NNcol) * sizeof(int);
    fseek(in_file, -PointerPosition, SEEK_CUR);

    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      fread(&_VI_in[0], sizeof(int), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[lig][col] = 0; 
      for (col = 0; col < Sub_NNcol; col++) M_in[lig][col + NNwinColM1S2] = _VI_in[col + OOff_col];
      }

    } /* NNblock == 0 */
      
  /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock <= 2) PrintfLine(lig,Sub_NNlig+NNwinLigM1S2);

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      fread(&_VI_in[0], sizeof(int), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0; 
      for (col = 0; col < Sub_NNcol; col++) M_in[NNwinLigM1S2+lig][col + NNwinColM1S2] = _VI_in[col + OOff_col];
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0;
        } else {
        fread(&_VF_in[0], sizeof(int), NNcol, in_file);
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0; 
        for (col = 0; col < Sub_NNcol; col++) M_in[NNwinLigM1S2+lig][col + NNwinColM1S2] = _VI_in[col + OOff_col];
        }
      }
      
    } /*lig */

  return 1;
}

/********************************************************************
Routine  : read_block_matrix_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a block of a binary (float) file
********************************************************************/
int read_block_matrix_float(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {

    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
  
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        M_in[lig][col] = 0.;

    } else {

    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * NNcol) * sizeof(float);
    fseek(in_file, -PointerPosition, SEEK_CUR);

    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[lig][col] = 0.; 
      for (col = 0; col < Sub_NNcol; col++) M_in[lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
      }

    } /* NNblock == 0 */
      
  /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock <= 2) PrintfLine(lig,Sub_NNlig+NNwinLigM1S2);

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0.; 
      for (col = 0; col < Sub_NNcol; col++) M_in[NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0.;
        } else {
        fread(&_VF_in[0], sizeof(float), NNcol, in_file);
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNwinLigM1S2+lig][col] = 0.; 
        for (col = 0; col < Sub_NNcol; col++) M_in[NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
        }
      }
      
    } /*lig */

  return 1;
}

/********************************************************************
Routine  : read_block_matrix_matrix3d_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a block of a binary (float) file
********************************************************************/
int read_block_matrix_matrix3d_float(FILE *in_file, float ***M_in, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {

    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
  
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        M_in[NNp][lig][col] = 0.;

    } else {

    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * NNcol) * sizeof(float);
    fseek(in_file, -PointerPosition, SEEK_CUR);

    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNp][lig][col] = 0.; 
      for (col = 0; col < Sub_NNcol; col++) M_in[NNp][lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
      }

    } /* NNblock == 0 */
      
  /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock <= 2) PrintfLine(lig,Sub_NNlig+NNwinLigM1S2);

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      fread(&_VF_in[0], sizeof(float), NNcol, in_file);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNp][NNwinLigM1S2+lig][col] = 0.; 
      for (col = 0; col < Sub_NNcol; col++) M_in[NNp][NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNp][NNwinLigM1S2+lig][col] = 0.;
        } else {
        fread(&_VF_in[0], sizeof(float), NNcol, in_file);
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_in[NNp][NNwinLigM1S2+lig][col] = 0.; 
        for (col = 0; col < Sub_NNcol; col++) M_in[NNp][NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
        }
      }
      
    } /*lig */

  return 1;
}

/********************************************************************
Routine  : read_block_matrix_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : read a block of a binary (complex) file
********************************************************************/
int read_block_matrix_cmplx(FILE *in_file, float **M_in, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int lig, col;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {

    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      fread(&_VC_in[0], sizeof(float), 2*NNcol, in_file);
  
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++)
        M_in[lig][col] = 0.;
        
    } else {
      
    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * 2*NNcol) * sizeof(float);
    fseek(in_file, -PointerPosition, SEEK_CUR);
        
    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      fread(&_VC_in[0], sizeof(float), 2*NNcol, in_file);
      for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++) M_in[lig][col]=0.;
      for (col = 0; col < Sub_NNcol; col++) {
        M_in[lig][2*(col + NNwinColM1S2)] = _VC_in[2*(col+OOff_col)];
        M_in[lig][2*(col + NNwinColM1S2)+1] = _VC_in[2*(col+OOff_col)+1];
        }
      }

    } /* NNblock == 0 */
      
  /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock <= 2) PrintfLine(lig,Sub_NNlig+NNwinLigM1S2);

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      fread(&_VC_in[0], sizeof(float), 2*NNcol, in_file);
      for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++) M_in[NNwinLigM1S2+lig][col]=0.;
      for (col = 0; col < Sub_NNcol; col++) {
        M_in[NNwinLigM1S2+lig][2*(col + NNwinColM1S2)] = _VC_in[2*(col+OOff_col)];
        M_in[NNwinLigM1S2+lig][2*(col + NNwinColM1S2)+1] = _VC_in[2*(col+OOff_col)+1];
        }
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++) M_in[NNwinLigM1S2+lig][col] = 0.;
        } else {
        fread(&_VC_in[0], sizeof(float), 2*NNcol, in_file);
        for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++) M_in[NNwinLigM1S2+lig][col]=0.;
        for (col = 0; col < Sub_NNcol; col++) {
          M_in[NNwinLigM1S2+lig][2*(col + NNwinColM1S2)] = _VC_in[2*(col+OOff_col)];
          M_in[NNwinLigM1S2+lig][2*(col + NNwinColM1S2)+1] = _VC_in[2*(col+OOff_col)+1];
          }
        }
      }
        
    } /*lig */

  return 1;
}

/********************************************************************
Routine  : write_block_matrix_int
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a block of binary (int) file
********************************************************************/
int write_block_matrix_int(FILE *out_file, int **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int lig;
//  int col;

  for (lig = 0; lig < Sub_NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[OOffLig + lig][col]) == 0) M_out[OOffLig + lig][col] = 0;
//      }
    fwrite(&M_out[OOffLig + lig][OOffCol], sizeof(int), Sub_NNcol, out_file);
    }

  return 1;
}

/********************************************************************
Routine  : write_block_matrix_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a block of binary (float) file
********************************************************************/
int write_block_matrix_float(FILE *out_file, float **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int lig;
//  int col;

  for (lig = 0; lig < Sub_NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[OOffLig + lig][col]) == 0) M_out[OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[OOffLig + lig][OOffCol], sizeof(float), Sub_NNcol, out_file);
    }

  return 1;
}

/********************************************************************
Routine  : write_block_matrix_matrix3d_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a block of binary (float) file
********************************************************************/
int write_block_matrix_matrix3d_float(FILE *out_file, float ***M_out, int NNp, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int lig;
//  int col;

  for (lig = 0; lig < Sub_NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[NNp][OOffLig + lig][col]) == 0) M_out[NNp][OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[NNp][OOffLig + lig][OOffCol], sizeof(float), Sub_NNcol, out_file);
    }

  return 1;
}

/********************************************************************
Routine  : write_block_matrix_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a block of binary (complex) file
********************************************************************/
int write_block_matrix_cmplx(FILE *out_file, float **M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int lig;
//  int col;
  
  for (lig = 0; lig < Sub_NNlig; lig++) {
//    for (col = 0; col < 2*NNcol; col++) {
//      if (my_isfinite(M_out[OOffLig + lig][col]) == 0) M_out[OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[OOffLig + lig][2*OOffCol], sizeof(float), 2*Sub_NNcol, out_file);
    }

  return 1;
}

/********************************************************************
Routine  : write_block_matrix3d_float
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a block of binary (float) file
********************************************************************/
int write_block_matrix3d_float(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int Np;
  int lig;
//  int col;
  
for (Np = 0; Np < NNpolar; Np++) {

  for (lig = 0; lig < Sub_NNlig; lig++) {
//    for (col = 0; col < NNcol; col++) {
//      if (my_isfinite(M_out[Np][OOffLig + lig][col]) == 0) M_out[Np][OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[Np][OOffLig + lig][OOffCol], sizeof(float), Sub_NNcol, datafile[Np]);
    }

  }

  return 1;
}

/********************************************************************
Routine  : write_block_matrix3d_cmplx
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : write a block of binary (complex) file
********************************************************************/
int write_block_matrix3d_cmplx(FILE *datafile[], int NNpolar, float ***M_out, int Sub_NNlig, int Sub_NNcol, int OOffLig, int OOffCol, int NNcol)
{
  int Np;
  int lig;
//  int col;
  
for (Np = 0; Np < NNpolar; Np++) {

  for (lig = 0; lig < Sub_NNlig; lig++) {
//    for (col = 0; col < 2*NNcol; col++) {
//      if (my_isfinite(M_out[Np][OOffLig + lig][col]) == 0) M_out[Np][OOffLig + lig][col] = eps;
//      }
    fwrite(&M_out[Np][OOffLig + lig][2*OOffCol], sizeof(float), 2*Sub_NNcol, datafile[Np]);
    }

  }

  return 1;
}

/********************************************************************
Routine  : read_block_S2_avg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read S2 Sinclair matrix and apply a spatial averaging
********************************************************************/
int read_block_S2_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col, k, l;
  int NNpolarIn=4;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if ((strcmp(PolType, "S2") == 0)||(strcmp(PolType,"SPPpp1")==0)||(strcmp(PolType,"SPPpp2")==0)||(strcmp(PolType,"SPPpp3")==0)) {

    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      }

    if (strcmp(PolType, "S2") == 0) {
      /* NLIG LINES READING */
      for (lig = 0; lig < Sub_NNlig; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) {
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          for (col = 0; col < 2* Sub_NNcol; col++) 
            M_out[Np][lig][col] = _MC_in[Np][col + 2 * OOff_col];
          }
        }
      } else {
      /* NLIG LINES READING */
      for (lig = 0; lig < Sub_NNlig; lig++) {
        if (strcmp(PolType, "SPPpp1") == 0) {
          fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
          fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vh]);
          }
        if (strcmp(PolType, "SPPpp2") == 0) {
          fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[vv]);
          fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[hv]);
          }
        if (strcmp(PolType, "SPPpp3") == 0) {
          fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
          fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vv]);
          }
        for (Np = 0; Np < NNpolar; Np++) 
          for (col = 0; col < 2* Sub_NNcol; col++) 
            M_out[Np][lig][col] = _MC_in[Np][col + 2 * OOff_col];
        }
      } 
  
    } else {
    
    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++) _MF_in[Np][lig][col] = 0.;

      /* FIRST (NNwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
      for (lig = NNwinLigM1S2; lig < NNwinLigM1; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolType, "IPPpp4") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[2][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          if (strcmp(PolType, "IPPpp5") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "IPPpp6") == 0) {
            k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
            k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "IPPpp7") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "T3") == 0) {
            k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
            k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
            k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
            k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
            k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

            _MF_in[T311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[T312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[T312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[T313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[T313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[T322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[T323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[T323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[T333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }    
          if (strcmp(PolType, "T4") == 0) {
            k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
            k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
            k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
            k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
            k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
            k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
            k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);
  
            _MF_in[T411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[T412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[T412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[T413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[T413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[T414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            _MF_in[T414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            _MF_in[T422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[T423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[T423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[T424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            _MF_in[T424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            _MF_in[T433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            _MF_in[T434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            _MF_in[T434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            _MF_in[T444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          if (strcmp(PolType, "C3") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col];
            k3i = _MC_in[vv][2*col + 1];

            _MF_in[C311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          
          if (strcmp(PolType, "C4") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[hv][2*col];
            k2i  = _MC_in[hv][2*col+1];
            k3r = _MC_in[vh][2*col];
            k3i = _MC_in[vh][2*col+1];
            k4r = _MC_in[vv][2*col];
            k4i = _MC_in[vv][2*col+1];

            _MF_in[C411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            _MF_in[C414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            _MF_in[C422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            _MF_in[C424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            _MF_in[C433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            _MF_in[C434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            _MF_in[C434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            _MF_in[C444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          }

        }
        
      } else {
      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);

      /* FIRST NNwin-1 LINES READING TO FILTER THE FIRST DATA LINE */
      for (lig = 0; lig < NNwinLigM1; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolType, "IPPpp4") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[2][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          if (strcmp(PolType, "IPPpp5") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "IPPpp6") == 0) {
            k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
            k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "IPPpp7") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
            _MF_in[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "T3") == 0) {
            k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
            k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
            k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
            k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
            k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

            _MF_in[T311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[T312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[T312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[T313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[T313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[T322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[T323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[T323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[T333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }    
          if (strcmp(PolType, "T4") == 0) {
            k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
            k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
            k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
            k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
            k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
            k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
            k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);
  
            _MF_in[T411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[T412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[T412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[T413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[T413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[T414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            _MF_in[T414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            _MF_in[T422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[T423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[T423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[T424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            _MF_in[T424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            _MF_in[T433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            _MF_in[T434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            _MF_in[T434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            _MF_in[T444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          if (strcmp(PolType, "C3") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col];
            k3i = _MC_in[vv][2*col + 1];

            _MF_in[C311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          
          if (strcmp(PolType, "C4") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[hv][2*col];
            k2i  = _MC_in[hv][2*col+1];
            k3r = _MC_in[vh][2*col];
            k3i = _MC_in[vh][2*col+1];
            k4r = _MC_in[vv][2*col];
            k4i = _MC_in[vv][2*col+1];

            _MF_in[C411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            _MF_in[C413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            _MF_in[C414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            _MF_in[C414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            _MF_in[C422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            _MF_in[C423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            _MF_in[C423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            _MF_in[C424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            _MF_in[C424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            _MF_in[C433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            _MF_in[C434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            _MF_in[C434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            _MF_in[C444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          }

        }
        
      } /* NNblock == 0 */
      
    /* READING AND AVERAGING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig; lig++) {
      if (NNbBlock == 1) if (lig%(int)(Sub_NNlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig - NNwinLigM1S2) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++)
            for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][NNwinLigM1][col] = 0.;

      /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolType, "IPPpp4") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
          _MF_in[0][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[1][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[2][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
        if (strcmp(PolType, "IPPpp5") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
          _MF_in[0][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[1][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "IPPpp6") == 0) {
          k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
          k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
          _MF_in[0][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[1][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "IPPpp7") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
          _MF_in[0][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[1][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }

        if (strcmp(PolType, "T3") == 0) {
          k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
          k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
          k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
          k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
          k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

          _MF_in[T311][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[T312_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[T312_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[T313_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          _MF_in[T313_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          _MF_in[T322][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[T323_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          _MF_in[T323_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          _MF_in[T333][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }

        if (strcmp(PolType, "T4") == 0) {
          k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
          k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
          k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
          k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
          k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
          k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
          k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);

          _MF_in[T411][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[T412_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[T412_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[T413_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          _MF_in[T413_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          _MF_in[T414_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          _MF_in[T414_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          _MF_in[T422][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[T423_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          _MF_in[T423_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          _MF_in[T424_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          _MF_in[T424_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          _MF_in[T433][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          _MF_in[T434_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          _MF_in[T434_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          _MF_in[T444][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }

        if (strcmp(PolType, "C3") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col];
          k3i = _MC_in[vv][2*col + 1];

          _MF_in[C311][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[C312_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[C312_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[C313_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          _MF_in[C313_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          _MF_in[C322][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[C323_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          _MF_in[C323_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          _MF_in[C333][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
          
        if (strcmp(PolType, "C4") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[hv][2*col];
          k2i = _MC_in[hv][2*col+1];
          k3r = _MC_in[vh][2*col];
          k3i = _MC_in[vh][2*col+1];
          k4r = _MC_in[vv][2*col];
          k4i = _MC_in[vv][2*col+1];

          _MF_in[C411][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[C412_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[C412_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[C413_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          _MF_in[C413_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          _MF_in[C414_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          _MF_in[C414_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          _MF_in[C422][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          _MF_in[C423_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          _MF_in[C423_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          _MF_in[C424_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          _MF_in[C424_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          _MF_in[C433][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          _MF_in[C434_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          _MF_in[C434_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          _MF_in[C444][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }

        }
  
      for (col = 0; col < Sub_NNcol; col++) {
        if (col == 0) {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++)
            for (l = -NNwinColM1S2; l < 1 + NNwinColM1S2; l++) {
              for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinColM1S2 + col + l] / (float) (NNwinLig * NNwinCol);
              }
          } else {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col-1];
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++) {
            for (Np = 0; Np < NNpolar; Np++) {
              M_out[Np][lig][col] = M_out[Np][lig][col] - _MF_in[Np][NNwinLigM1S2 + k][col - 1] / (float) (NNwinLig * NNwinCol);
              M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinCol - 1 + col] / (float) (NNwinLig * NNwinCol);
              }
            }
          }
        } /*col */
  
      /* Line-wise shift */
      for (l = 0; l < NNwinLigM1; l++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++)
            _MF_in[Np][l][col] = _MF_in[Np][l + 1][col];
            
      } /*lig */
   
    } /* else */

  return 1;
}

/********************************************************************
Routine  : read_block_S2_noavg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read S2 Sinclair matrix without applying a spatial
        averaging
********************************************************************/
int read_block_S2_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col;
  int NNpolarIn=4;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if ((strcmp(PolType, "S2") == 0)||(strcmp(PolType,"SPPpp1")==0)||(strcmp(PolType,"SPPpp2")==0)||(strcmp(PolType,"SPPpp3")==0)) {

    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++)
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
        
      } else {

      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);

      /* FIRST (NNwin+1)/2 LINES READING */
      for (lig = 0; lig < NNwinLigM1S2; lig++) {
        if (strcmp(PolType, "S2") == 0) {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          } else {
          if (strcmp(PolType, "SPPpp1") == 0) {
            fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
            fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vh]);
            }
          if (strcmp(PolType, "SPPpp2") == 0) {
            fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[vv]);
            fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[hv]);
            }
          if (strcmp(PolType, "SPPpp3") == 0) {
            fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
            fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vv]);
            }
          }

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][lig][col] = 0.;

        for (col = 0; col < 2*Sub_NNcol; col++) {
          for (Np = 0; Np < NNpolar; Np++) 
            M_out[Np][lig][col+2*NNwinColM1S2] = _MC_in[Np][col + 2 * OOff_col];
            }    
          
        }

      } /* NNblock == 0 */
      
    /* READING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
      if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig) {
        if (strcmp(PolType, "S2") == 0) {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          } else {
          if (strcmp(PolType, "SPPpp1") == 0) {
            fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
            fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vh]);
            }
          if (strcmp(PolType, "SPPpp2") == 0) {
            fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[vv]);
            fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[hv]);
            }
          if (strcmp(PolType, "SPPpp3") == 0) {
            fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
            fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vv]);
            }
          }
        } else {
        if (NNblock == (NNbBlock - 1)) {
          if (strcmp(PolType, "S2") == 0) {
            for (Np = 0; Np < NNpolarIn; Np++) for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
            } else {
            for (Np = 0; Np < 2; Np++) for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
            }
          } else {
          if (strcmp(PolType, "S2") == 0) {
            for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
            } else {
            if (strcmp(PolType, "SPPpp1") == 0) {
              fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
              fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vh]);
              }
            if (strcmp(PolType, "SPPpp2") == 0) {
              fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[vv]);
              fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[hv]);
              }
            if (strcmp(PolType, "SPPpp3") == 0) {
              fread(&_MC_in[0][0], sizeof(float), 2 * NNcol, datafile[hh]);
              fread(&_MC_in[1][0], sizeof(float), 2 * NNcol, datafile[vv]);
              }
            }
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.;

      /* Row-wise shift */
      for (col = 0; col < 2*Sub_NNcol; col++) {
        for (Np = 0; Np < NNpolar; Np++) 
          M_out[Np][NNwinLigM1S2+lig][col+2*NNwinColM1S2] = _MC_in[Np][col + 2 * OOff_col];
          }    
        
      } /*lig */

    } else {
    
    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < Sub_NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
        
      } else {

      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);

      /* FIRST (NNwin+1)/2 LINES READING */
      for (lig = 0; lig < NNwinLigM1S2; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolType, "IPPpp4") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
            M_out[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            M_out[2][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          if (strcmp(PolType, "IPPpp5") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
            M_out[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "IPPpp6") == 0) {
            k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
            k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
            M_out[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "IPPpp7") == 0) {
            k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
            M_out[0][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[1][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolType, "T3") == 0) {
            k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
            k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
            k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
            k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
            k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

            M_out[T311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[T312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            M_out[T312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            M_out[T313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            M_out[T313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            M_out[T322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            M_out[T323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            M_out[T323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            M_out[T333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }    
          if (strcmp(PolType, "T4") == 0) {
            k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
            k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
            k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
            k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
            k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
            k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
            k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);
  
            M_out[T411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[T412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            M_out[T412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            M_out[T413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            M_out[T413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            M_out[T414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            M_out[T414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            M_out[T422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            M_out[T423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            M_out[T423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            M_out[T424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            M_out[T424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            M_out[T433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            M_out[T434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            M_out[T434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            M_out[T444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          if (strcmp(PolType, "C3") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col + 1];
            k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
            k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
            k3r = _MC_in[vv][2*col];
            k3i = _MC_in[vv][2*col + 1];

            M_out[C311][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[C312_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            M_out[C312_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            M_out[C313_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            M_out[C313_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            M_out[C322][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            M_out[C323_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            M_out[C323_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            M_out[C333][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            }
          
          if (strcmp(PolType, "C4") == 0) {
            k1r = _MC_in[hh][2*col];
            k1i = _MC_in[hh][2*col+1];
            k2r = _MC_in[hv][2*col];
            k2i  = _MC_in[hv][2*col+1];
            k3r = _MC_in[vh][2*col];
            k3i = _MC_in[vh][2*col+1];
            k4r = _MC_in[vv][2*col];
            k4i = _MC_in[vv][2*col+1];

            M_out[C411][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[C412_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            M_out[C412_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            M_out[C413_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
            M_out[C413_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
            M_out[C414_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
            M_out[C414_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
            M_out[C422][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            M_out[C423_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
            M_out[C423_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
            M_out[C424_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
            M_out[C424_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
            M_out[C433][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
            M_out[C434_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
            M_out[C434_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
            M_out[C444][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
            }
          }

        }
        
      } /* NNblock == 0 */
      
    /* READING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
      if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++)
            for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.;

      /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolType, "IPPpp4") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
          M_out[0][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[1][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          M_out[2][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
        if (strcmp(PolType, "IPPpp5") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
          M_out[0][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[1][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "IPPpp6") == 0) {
          k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
          k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
          M_out[0][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[1][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "IPPpp7") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
          M_out[0][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[1][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }

        if (strcmp(PolType, "T3") == 0) {
          k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
          k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
          k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
          k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
          k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

          M_out[T311][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[T312_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          M_out[T312_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          M_out[T313_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          M_out[T313_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          M_out[T322][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          M_out[T323_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          M_out[T323_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          M_out[T333][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }

        if (strcmp(PolType, "T4") == 0) {
          k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
          k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
          k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
          k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
          k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
          k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
          k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);

          M_out[T411][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[T412_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          M_out[T412_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          M_out[T413_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          M_out[T413_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          M_out[T414_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          M_out[T414_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          M_out[T422][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          M_out[T423_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          M_out[T423_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          M_out[T424_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          M_out[T424_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          M_out[T433][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          M_out[T434_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          M_out[T434_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          M_out[T444][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }

        if (strcmp(PolType, "C3") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col];
          k3i = _MC_in[vv][2*col + 1];

          M_out[C311][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[C312_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          M_out[C312_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          M_out[C313_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          M_out[C313_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          M_out[C322][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          M_out[C323_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          M_out[C323_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          M_out[C333][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
          
        if (strcmp(PolType, "C4") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[hv][2*col];
          k2i = _MC_in[hv][2*col+1];
          k3r = _MC_in[vh][2*col];
          k3i = _MC_in[vh][2*col+1];
          k4r = _MC_in[vv][2*col];
          k4i = _MC_in[vv][2*col+1];

          M_out[C411][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[C412_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          M_out[C412_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          M_out[C413_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          M_out[C413_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          M_out[C414_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          M_out[C414_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          M_out[C422][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          M_out[C423_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          M_out[C423_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          M_out[C424_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          M_out[C424_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          M_out[C433][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          M_out[C434_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          M_out[C434_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          M_out[C444][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }

        }
        
      } /*lig */
    
    } /* else */

  return 1;
}

/********************************************************************
Routine  : read_block_SPP_avg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read SPP Partial Sinclair matrix and apply a spatial
        averaging
********************************************************************/
int read_block_SPP_avg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  char PolT[10];
  int Np, lig, col, k, l;
  int NNpolarIn=2;
  int Chx1=0;
  int Chx2=1;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i;
  
  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  strcpy(PolT,"SPP");
  if (strcmp(PolType, "SPPpp1") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "SPPpp2") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "SPPpp3") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "IPPpp5") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "IPPpp6") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "IPPpp7") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "C2") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp1") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp2") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp3") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "T2") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp1") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp2") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp3") == 0) strcpy(PolT, "T2");

  if (strcmp(PolT, "SPP") == 0) {

    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      }
  
    /* SUB_NLIG LINES READING */
    for (lig = 0; lig < Sub_NNlig; lig++) {
      for (Np = 0; Np < NNpolarIn; Np++) {
        fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        for (col = 0; col < 2* Sub_NNcol; col++) 
          M_out[Np][lig][col] = _MC_in[Np][col + 2 * OOff_col];
        }
      }
  
    } else {
    
    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++) _MF_in[Np][lig][col] = 0.;

      /* FIRST (NNwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
      for (lig = NNwinLigM1S2; lig < NNwinLigM1; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolT, "C2") == 0) {
            k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
            k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

            _MF_in[C211][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C212_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C212_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C222][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolT, "T2") == 0) {
            k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
            k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
            k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
            k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

            _MF_in[T211][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[T212_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[T212_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[T222][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolT, "IPP") == 0) {
            k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
            k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

            _MF_in[Chx1][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[Chx2][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          }

        }
        
      } else {
        
      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);
        
      /* FIRST NNwin-1 LINES READING TO FILTER THE FIRST DATA LINE */
      for (lig = 0; lig < NNwinLigM1; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolT, "C2") == 0) {
            k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
            k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

            _MF_in[C211][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[C212_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[C212_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[C222][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolT, "T2") == 0) {
            k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
            k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
            k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
            k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

            _MF_in[T211][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[T212_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            _MF_in[T212_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            _MF_in[T222][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolT, "IPP") == 0) {
            k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
            k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];
  
            _MF_in[Chx1][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            _MF_in[Chx2][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          }

        }
      
      } /* NNblock == 0 */
      
    /* READING AND AVERAGING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig; lig++) {
      if (NNbBlock == 1) if (lig%(int)(Sub_NNlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig - NNwinLigM1S2) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++)
            for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][NNwinLigM1][col] = 0.;

      /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolT, "C2") == 0) {
          k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
          k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

          _MF_in[C211][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[C212_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[C212_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[C222][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolT, "T2") == 0) {
          k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
          k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
          k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
          k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

          _MF_in[T211][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[T212_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          _MF_in[T212_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          _MF_in[T222][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolT, "IPP") == 0) {
          k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
          k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

          _MF_in[Chx1][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          _MF_in[Chx2][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        }
        
      for (col = 0; col < Sub_NNcol; col++) {
        if (col == 0) {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++)
            for (l = -NNwinColM1S2; l < 1 + NNwinColM1S2; l++) {
              for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinColM1S2 + col + l] / (float) (NNwinLig * NNwinCol);
              }
          } else {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col-1];
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++) {
            for (Np = 0; Np < NNpolar; Np++) {
              M_out[Np][lig][col] = M_out[Np][lig][col] - _MF_in[Np][NNwinLigM1S2 + k][col - 1] / (float) (NNwinLig * NNwinCol);
              M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinCol - 1 + col] / (float) (NNwinLig * NNwinCol);
              }
            }
          }
        } /*col */

      /* Line-wise shift */
      for (l = 0; l < NNwinLigM1; l++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++)
            _MF_in[Np][l][col] = _MF_in[Np][l + 1][col];
            
      } /*lig */

    } /* else SPP */
 
  return 1;
}

/********************************************************************
Routine  : read_block_SPP_noavg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read SPP Partial Sinclair matrix
        without applying a spatial averaging
********************************************************************/
int read_block_SPP_noavg(FILE *datafile[], float ***M_out, char *PolType, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  char PolT[10];
  int Np, lig, col;
  int NNpolarIn=2;
  int Chx1=0;
  int Chx2=1;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  strcpy(PolT,"SPP");
  if (strcmp(PolType, "SPP") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "SPPpp1") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "SPPpp2") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "SPPpp3") == 0) strcpy(PolT, "SPP");
  if (strcmp(PolType, "IPPpp5") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "IPPpp6") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "IPPpp7") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "C2") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp1") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp2") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp3") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "T2") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp1") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp2") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp3") == 0) strcpy(PolT, "T2");

  if (strcmp(PolT, "SPP") == 0) {

    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < 2*(Sub_NNcol + NNwinCol); col++)
          for (Np = 0; Np < NNpolarIn; Np++) M_out[Np][lig][col] = 0.;
        
      } else {

      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);

      /* FIRST (NNwin+1)/2 LINES READING */
      for (lig = 0; lig < NNwinLigM1S2; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolarIn; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][lig][col] = 0.;

        for (col = 0; col < 2*Sub_NNcol; col++) {
          for (Np = 0; Np < NNpolarIn; Np++) 
            M_out[Np][lig][col+2*NNwinColM1S2] = _MC_in[Np][col + 2 * OOff_col];
            }    
          
        }

      } /* NNblock == 0 */
      
    /* READING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
      if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++) for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          }
        }

      for (Np = 0; Np < NNpolarIn; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.;

      /* Row-wise shift */
      for (col = 0; col < 2*Sub_NNcol; col++) {
        for (Np = 0; Np < NNpolarIn; Np++) 
          M_out[Np][NNwinLigM1S2+lig][col+2*NNwinColM1S2] = _MC_in[Np][col + 2 * OOff_col];
          }    
        
      } /*lig */

    } else {
    
    if (NNblock == 0) {
      /* OFFSET LINES READING */
      for (lig = 0; lig < OOff_lig; lig++)
        for (Np = 0; Np < NNpolarIn; Np++)
          fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      /* Set the Tmp matrix to 0 */
      for (lig = 0; lig < NNwinLigM1S2; lig++) 
        for (col = 0; col < NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
        
      } else {
        
      /* FSEEK NNwinL LINES */
      PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
      for (Np = 0; Np < NNpolarIn; Np++)
        fseek(datafile[Np], -PointerPosition, SEEK_CUR);
        
      /* FIRST (NNwin+1)/2 LINES READING */
      for (lig = 0; lig < NNwinLigM1S2; lig++) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

        for (Np = 0; Np < NNpolar; Np++)
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][lig][col] = 0.;

        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
          if (strcmp(PolT, "C2") == 0) {
            k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
            k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

            M_out[C211][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[C212_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            M_out[C212_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            M_out[C222][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolT, "T2") == 0) {
            k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
            k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
            k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
            k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

            M_out[T211][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[T212_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
            M_out[T212_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
            M_out[T222][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          if (strcmp(PolT, "IPP") == 0) {
            k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
            k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];
  
            M_out[Chx1][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
            M_out[Chx2][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
            }
          }

        }
      
      } /* NNblock == 0 */
      
    /* READING AND AVERAGING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
      if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++)
            for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.;

      /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolT, "C2") == 0) {
          k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
          k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

          M_out[C211][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[C212_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          M_out[C212_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          M_out[C222][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolT, "T2") == 0) {
          k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
          k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
          k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
          k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

          M_out[T211][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[T212_re][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          M_out[T212_im][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          M_out[T222][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolT, "IPP") == 0) {
          k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
          k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

          M_out[Chx1][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          M_out[Chx2][NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        }
        
      } /*lig */

    } /* else SPP */

  return 1;
}

/********************************************************************
Routine  : read_block_TCI_avg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read T Coherency, C Covariance or I Intensity matrix
        and apply a spatial averaging
********************************************************************/
int read_block_TCI_avg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col, k, l;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  
  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {

    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      for (Np = 0; Np < NNpolar; Np++)
        fread(&_MF_in[0][0][0], sizeof(float), NNcol, datafile[Np]);
  
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < NNcol + NNwinCol; col++)
        for (Np = 0; Np < NNpolar; Np++) _MF_in[Np][lig][col] = 0.;

    /* FIRST (NNwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
    for (lig = NNwinLigM1S2; lig < NNwinLigM1; lig++) {
      for (Np = 0; Np < NNpolar; Np++) {
        fread(&_MF_in[Np][lig][NNwinColM1S2], sizeof(float), NNcol, datafile[Np]);
        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) _MF_in[Np][lig][col - OOff_col + NNwinColM1S2] = _MF_in[Np][lig][col + NNwinColM1S2];
        for (col = Sub_NNcol; col < Sub_NNcol + NNwinColM1S2; col++) _MF_in[Np][lig][col + NNwinColM1S2] = 0.;
        }
      }
    } else {
      
    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * NNcol) * sizeof(float);
    for (Np = 0; Np < NNpolar; Np++)
      fseek(datafile[Np], -PointerPosition, SEEK_CUR);
        
    /* FIRST NNwin-1 LINES READING TO FILTER THE FIRST DATA LINE */
    for (lig = 0; lig < NNwinLigM1; lig++) {
      for (Np = 0; Np < NNpolar; Np++) {
        fread(&_MF_in[Np][lig][NNwinColM1S2], sizeof(float), NNcol, datafile[Np]);
        for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) _MF_in[Np][lig][col - OOff_col + NNwinColM1S2] = _MF_in[Np][lig][col + NNwinColM1S2];
        for (col = Sub_NNcol; col < Sub_NNcol + NNwinColM1S2; col++) _MF_in[Np][lig][col + NNwinColM1S2] = 0.;
        }
      }

    } /* NNblock == 0 */
      
  /* READING AND AVERAGING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig; lig++) {
    if (NNbBlock == 1) if (lig%(int)(Sub_NNlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig - 1));fflush(stdout);}

    /* 1 line reading with zero padding */
    for (Np = 0; Np < NNpolar; Np++) {
      if (lig < Sub_NNlig - NNwinLigM1S2) {
        fread(&_MF_in[Np][NNwinLigM1][NNwinColM1S2], sizeof(float), NNcol, datafile[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (col = 0; col < NNcol + NNwinCol; col++) _MF_in[Np][NNwinLigM1][col] = 0.;
          } else {
          fread(&_MF_in[Np][NNwinLigM1][NNwinColM1S2], sizeof(float), NNcol, datafile[Np]);
          }
        }
          

    /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) _MF_in[Np][NNwinLigM1][col - OOff_col + NNwinColM1S2] = _MF_in[Np][NNwinLigM1][col + NNwinColM1S2];
      for (col = Sub_NNcol; col < Sub_NNcol + NNwinColM1S2; col++) _MF_in[Np][NNwinLigM1][col + NNwinColM1S2] = 0.;
      }

    for (col = 0; col < Sub_NNcol; col++) {
      if (col == 0) {
        for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
        /* Average matrix element calculation */
        for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++)
          for (l = -NNwinColM1S2; l < 1 + NNwinColM1S2; l++) {
            for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinColM1S2 + col + l] / (float) (NNwinLig * NNwinCol);
            }
        } else {
        for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col-1];
        /* Average matrix element calculation */
        for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++) {
          for (Np = 0; Np < NNpolar; Np++) {
            M_out[Np][lig][col] = M_out[Np][lig][col] - _MF_in[Np][NNwinLigM1S2 + k][col - 1] / (float) (NNwinLig * NNwinCol);
            M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinCol - 1 + col] / (float) (NNwinLig * NNwinCol);
            }
          }
        }
      } /*col */

    /* Line-wise shift */
    for (l = 0; l < NNwinLigM1; l++)
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        for (Np = 0; Np < NNpolar; Np++)
          _MF_in[Np][l][col] = _MF_in[Np][l + 1][col];
            
    } /*lig */
  
  return 1;
}

/********************************************************************
Routine  : read_block_TCI_noavg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read T Coherency, C Covariance or I Intensity matrix
        without applying a spatial averaging
********************************************************************/
int read_block_TCI_noavg(FILE *datafile[], float ***M_out, int NNpolar, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {
    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      for (Np = 0; Np < NNpolar; Np++)
        fread(&_VF_in[0], sizeof(float), NNcol, datafile[Np]);
  
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;

    } else {
      
    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * NNcol) * sizeof(float);
    for (Np = 0; Np < NNpolar; Np++)
      fseek(datafile[Np], -PointerPosition, SEEK_CUR);
        
    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      for (Np = 0; Np < NNpolar; Np++) {
        fread(&_VF_in[0], sizeof(float), NNcol, datafile[Np]);
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][lig][col] = 0.; 
        for (col = 0; col < Sub_NNcol; col++) M_out[Np][lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
        }
      }

    } /* NNblock == 0 */
      
  /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {

    if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

    /* 1 line reading with zero padding */
    for (Np = 0; Np < NNpolar; Np++) {
      if (lig < Sub_NNlig) {
        fread(&_VF_in[0], sizeof(float), NNcol, datafile[Np]);
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.; 
        for (col = 0; col < Sub_NNcol; col++) M_out[Np][NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.;
          } else {
          fread(&_VF_in[0], sizeof(float), NNcol, datafile[Np]);
          for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[Np][NNwinLigM1S2+lig][col] = 0.; 
          for (col = 0; col < Sub_NNcol; col++) M_out[Np][NNwinLigM1S2+lig][col + NNwinColM1S2] = _VF_in[col + OOff_col];
          }
        }
      }
    } /*lig */

  return 1;
}

/********************************************************************
Routine  : read_block_S2_TCIelt_noavg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read S2 Sinclair matrix without applying a spatial
        averaging
********************************************************************/
int read_block_S2_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col;
  int NNpolarIn=4;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  if (NNblock == 0) {
    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      for (Np = 0; Np < NNpolarIn; Np++)
        fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < Sub_NNcol + NNwinCol; col++)
        M_out[lig][col] = 0.;
      
    } else {

    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
    for (Np = 0; Np < NNpolarIn; Np++)
      fseek(datafile[Np], -PointerPosition, SEEK_CUR);

    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[lig][col] = 0.;

      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolType, "IPPpp4") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
          if (NNp == 0) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == 1) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          if (NNp == 2) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
        if (strcmp(PolType, "IPPpp5") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
          if (NNp == 0) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == 1) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "IPPpp6") == 0) {
          k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
          k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
          if (NNp == 0) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == 1) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "IPPpp7") == 0) {
          k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
          if (NNp == 0) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == 1) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolType, "T3") == 0) {
          k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
          k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
          k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
          k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
          k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

          if (NNp == T311) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == T312_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          if (NNp == T312_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          if (NNp == T313_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          if (NNp == T313_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          if (NNp == T322) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          if (NNp == T323_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          if (NNp == T323_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          if (NNp == T333) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }    
        if (strcmp(PolType, "T4") == 0) {
          k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
          k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
          k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
          k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
          k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
          k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
          k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);
  
          if (NNp == T411) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == T412_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          if (NNp == T412_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          if (NNp == T413_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          if (NNp == T413_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          if (NNp == T414_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          if (NNp == T414_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          if (NNp == T422) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          if (NNp == T423_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          if (NNp == T423_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          if (NNp == T424_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          if (NNp == T424_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          if (NNp == T433) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          if (NNp == T434_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          if (NNp == T434_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          if (NNp == T444) M_out[lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }
        if (strcmp(PolType, "C3") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col + 1];
          k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
          k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
          k3r = _MC_in[vv][2*col];
          k3i = _MC_in[vv][2*col + 1];

          if (NNp == C311) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == C312_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          if (NNp == C312_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          if (NNp == C313_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          if (NNp == C313_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          if (NNp == C322) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          if (NNp == C323_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          if (NNp == C323_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          if (NNp == C333) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          }
          
        if (strcmp(PolType, "C4") == 0) {
          k1r = _MC_in[hh][2*col];
          k1i = _MC_in[hh][2*col+1];
          k2r = _MC_in[hv][2*col];
          k2i  = _MC_in[hv][2*col+1];
          k3r = _MC_in[vh][2*col];
          k3i = _MC_in[vh][2*col+1];
          k4r = _MC_in[vv][2*col];
          k4i = _MC_in[vv][2*col+1];

          if (NNp == C411) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == C412_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          if (NNp == C412_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          if (NNp == C413_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
          if (NNp == C413_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
          if (NNp == C414_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
          if (NNp == C414_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
          if (NNp == C422) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          if (NNp == C423_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
          if (NNp == C423_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
          if (NNp == C424_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
          if (NNp == C424_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
          if (NNp == C433) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
          if (NNp == C434_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
          if (NNp == C434_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
          if (NNp == C444) M_out[lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
          }
        }

      }
       
    } /* NNblock == 0 */
      
    /* READING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (Np = 0; Np < NNpolarIn; Np++)
          for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
        } else {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        }
      }

    for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[NNwinLigM1S2+lig][col] = 0.;

    /* Row-wise shift */
    for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
      if (strcmp(PolType, "IPPpp4") == 0) {
        k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col + 1];
        k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
        k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
        k3r = _MC_in[vv][2*col]; k3i = _MC_in[vv][2*col + 1];
        if (NNp == 0) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == 1) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        if (NNp == 2) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        }
      if (strcmp(PolType, "IPPpp5") == 0) {
        k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
        k2r = _MC_in[vh][2*col]; k2i = _MC_in[vh][2*col+1];
        if (NNp == 0) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == 1) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        }
      if (strcmp(PolType, "IPPpp6") == 0) {
        k1r = _MC_in[vv][2*col]; k1i = _MC_in[vv][2*col+1];
        k2r = _MC_in[hv][2*col]; k2i = _MC_in[hv][2*col+1];
        if (NNp == 0) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == 1) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        }
      if (strcmp(PolType, "IPPpp7") == 0) {
        k1r = _MC_in[hh][2*col]; k1i = _MC_in[hh][2*col+1];
        k2r = _MC_in[vv][2*col]; k2i = _MC_in[vv][2*col+1];
        if (NNp == 0) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == 1) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        }

      if (strcmp(PolType, "T3") == 0) {
        k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
        k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
        k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
        k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
        k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
        k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);

        if (NNp == T311) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == T312_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        if (NNp == T312_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        if (NNp == T313_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        if (NNp == T313_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        if (NNp == T322) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        if (NNp == T323_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        if (NNp == T323_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        if (NNp == T333) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        }

      if (strcmp(PolType, "T4") == 0) {
        k1r = (_MC_in[hh][2*col] + _MC_in[vv][2*col]) / sqrt(2.);
        k1i = (_MC_in[hh][2*col+1] + _MC_in[vv][2*col+1]) / sqrt(2.);
        k2r = (_MC_in[hh][2*col] - _MC_in[vv][2*col]) / sqrt(2.);
        k2i = (_MC_in[hh][2*col+1] - _MC_in[vv][2*col+1]) / sqrt(2.);
        k3r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
        k3i = (_MC_in[hv][2*col+1] + _MC_in[vh][2*col+1]) / sqrt(2.);
        k4r = (_MC_in[vh][2*col+1] - _MC_in[hv][2*col+1]) / sqrt(2.);
        k4i = (_MC_in[hv][2*col] - _MC_in[vh][2*col]) / sqrt(2.);

        if (NNp == T411) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == T412_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        if (NNp == T412_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        if (NNp == T413_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        if (NNp == T413_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        if (NNp == T414_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
        if (NNp == T414_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
        if (NNp == T422) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        if (NNp == T423_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        if (NNp == T423_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        if (NNp == T424_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
        if (NNp == T424_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
        if (NNp == T433) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        if (NNp == T434_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
        if (NNp == T434_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
        if (NNp == T444) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
        }

      if (strcmp(PolType, "C3") == 0) {
        k1r = _MC_in[hh][2*col];
        k1i = _MC_in[hh][2*col + 1];
        k2r = (_MC_in[hv][2*col] + _MC_in[vh][2*col]) / sqrt(2.);
        k2i = (_MC_in[hv][2*col + 1] + _MC_in[vh][2*col + 1]) / sqrt(2.);
        k3r = _MC_in[vv][2*col];
        k3i = _MC_in[vv][2*col + 1];

        if (NNp == C311) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == C312_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        if (NNp == C312_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        if (NNp == C313_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        if (NNp == C313_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        if (NNp == C322) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        if (NNp == C323_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        if (NNp == C323_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        if (NNp == C333) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        }
          
      if (strcmp(PolType, "C4") == 0) {
        k1r = _MC_in[hh][2*col];
        k1i = _MC_in[hh][2*col+1];
        k2r = _MC_in[hv][2*col];
        k2i = _MC_in[hv][2*col+1];
        k3r = _MC_in[vh][2*col];
        k3i = _MC_in[vh][2*col+1];
        k4r = _MC_in[vv][2*col];
        k4i = _MC_in[vv][2*col+1];

        if (NNp == C411) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == C412_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        if (NNp == C412_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        if (NNp == C413_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        if (NNp == C413_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        if (NNp == C414_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
        if (NNp == C414_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
        if (NNp == C422) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        if (NNp == C423_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        if (NNp == C423_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        if (NNp == C424_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
        if (NNp == C424_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
        if (NNp == C433) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        if (NNp == C434_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
        if (NNp == C434_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
        if (NNp == C444) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
        }

      }
      
    } /*lig */
    
  return 1;
}

/********************************************************************
Routine  : read_block_SPP_TCIelt_noavg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read SPP Partial Sinclair matrix
        without applying a spatial averaging
********************************************************************/
int read_block_SPP_TCIelt_noavg(FILE *datafile[], float **M_out, char *PolType, int NNp, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  char PolT[10];
  int Np, lig, col;
  int NNpolarIn=2;
  int Chx1=0;
  int Chx2=1;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i;

  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);

  strcpy(PolT,"IPP");
  if (strcmp(PolType, "IPPpp5") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "IPPpp6") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "IPPpp7") == 0) strcpy(PolT, "IPP");
  if (strcmp(PolType, "C2") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp1") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp2") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "C2pp3") == 0) strcpy(PolT, "C2");
  if (strcmp(PolType, "T2") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp1") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp2") == 0) strcpy(PolT, "T2");
  if (strcmp(PolType, "T2pp3") == 0) strcpy(PolT, "T2");

  if (NNblock == 0) {
    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      for (Np = 0; Np < NNpolarIn; Np++)
        fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < NNcol + NNwinCol; col++)
        M_out[lig][col] = 0.;
        
    } else {
        
    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
    for (Np = 0; Np < NNpolarIn; Np++)
      fseek(datafile[Np], -PointerPosition, SEEK_CUR);
        
    /* FIRST (NNwin+1)/2 LINES READING */
    for (lig = 0; lig < NNwinLigM1S2; lig++) {
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);

      for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[lig][col] = 0.;

      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        if (strcmp(PolT, "C2") == 0) {
          k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
          k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

          if (NNp == C211) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == C212_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          if (NNp == C212_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          if (NNp == C222) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolT, "T2") == 0) {
          k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
          k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
          k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
          k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

          if (NNp == T211) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == T212_re) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
          if (NNp == T212_im) M_out[lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
          if (NNp == T222) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        if (strcmp(PolT, "IPP") == 0) {
          k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
          k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];
  
          if (NNp == Chx1) M_out[lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
          if (NNp == Chx2) M_out[lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
          }
        }

      }
      
    } /* NNblock == 0 */
      
  /* READING AND AVERAGING NLIG LINES */
  for (lig = 0; lig < Sub_NNlig+NNwinLigM1S2; lig++) {
    if (NNbBlock == 1) if (lig%(int)((Sub_NNlig+NNwinLigM1S2)/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig+NNwinLigM1S2 - 1));fflush(stdout);}

    /* 1 line reading with zero padding */
    if (lig < Sub_NNlig) {
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
      } else {
      if (NNblock == (NNbBlock - 1)) {
        for (Np = 0; Np < NNpolarIn; Np++)
          for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
        } else {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC_in[Np][0], sizeof(float), 2 * NNcol, datafile[Np]);
        }
      }

    for (col = 0; col < Sub_NNcol + NNwinCol; col++) M_out[NNwinLigM1S2+lig][col] = 0.;

    /* Row-wise shift */
    for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
      if (strcmp(PolT, "C2") == 0) {
        k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
        k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

        if (NNp == C211) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == C212_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        if (NNp == C212_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        if (NNp == C222) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        }
      if (strcmp(PolT, "T2") == 0) {
        k1r = (_MC_in[Chx1][2*col]+_MC_in[Chx2][2*col])/sqrt(2.);
        k1i = (_MC_in[Chx1][2*col+1]+_MC_in[Chx2][2*col+1])/sqrt(2.);
        k2r = (_MC_in[Chx1][2*col]-_MC_in[Chx2][2*col])/sqrt(2.);
        k2i = (_MC_in[Chx1][2*col+1]-_MC_in[Chx2][2*col+1])/sqrt(2.);

        if (NNp == T211) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == T212_re) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        if (NNp == T212_im) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        if (NNp == T222) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        }
      if (strcmp(PolT, "IPP") == 0) {
        k1r = _MC_in[Chx1][2*col]; k1i = _MC_in[Chx1][2*col+1];
        k2r = _MC_in[Chx2][2*col]; k2i = _MC_in[Chx2][2*col+1];

        if (NNp == Chx1) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        if (NNp == Chx2) M_out[NNwinLigM1S2+lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        }
      }
       
    } /*lig */

  return 1;
}

/********************************************************************
Routine  : read_block_S2T6_avg
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : Read S2 Sinclair matrix and apply a spatial averaging
********************************************************************/
int read_block_S2T6_avg(FILE *datafile1[], FILE *datafile2[], float ***M_out, int NNblock, int NNbBlock, int Sub_NNlig, int Sub_NNcol, int NNwinLig, int NNwinCol, int OOff_lig, int OOff_col, int NNcol)
{
  int Np, lig, col, k, l;
  int NNpolarIn=4;
  int NNpolar=36;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  int NNwinLigM1S2, NNwinColM1S2;
  int NNwinLigM1;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i, k5r, k5i, k6r, k6i;
  
  long PointerPosition;

  NNwinLigM1S2 = (NNwinLig - 1) / 2;
  NNwinColM1S2 = (NNwinCol - 1) / 2;
  NNwinLigM1 = (NNwinLig - 1);
    
  if (NNblock == 0) {
    /* OFFSET LINES READING */
    for (lig = 0; lig < OOff_lig; lig++)
      for (Np = 0; Np < NNpolarIn; Np++) {
        fread(&_MC1_in[Np][0], sizeof(float), 2 * NNcol, datafile1[Np]);
        fread(&_MC2_in[Np][0], sizeof(float), 2 * NNcol, datafile2[Np]);
        }
    /* Set the Tmp matrix to 0 */
    for (lig = 0; lig < NNwinLigM1S2; lig++) 
      for (col = 0; col < NNcol + NNwinCol; col++)
        for (Np = 0; Np < NNpolar; Np++) _MF_in[Np][lig][col] = 0.;

    /* FIRST (NNwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
    for (lig = NNwinLigM1S2; lig < NNwinLigM1; lig++) {
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC1_in[Np][0], sizeof(float), 2 * NNcol, datafile1[Np]);
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC2_in[Np][0], sizeof(float), 2 * NNcol, datafile2[Np]);

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        k1r = (_MC1_in[hh][2*col] + _MC1_in[vv][2*col]) / sqrt(2.);
        k1i = (_MC1_in[hh][2*col+1] + _MC1_in[vv][2*col+1]) / sqrt(2.);
        k2r = (_MC1_in[hh][2*col] - _MC1_in[vv][2*col]) / sqrt(2.);
        k2i = (_MC1_in[hh][2*col+1] - _MC1_in[vv][2*col+1]) / sqrt(2.);
        k3r = (_MC1_in[hv][2*col] + _MC1_in[vh][2*col]) / sqrt(2.);
        k3i = (_MC1_in[hv][2*col+1] + _MC1_in[vh][2*col+1]) / sqrt(2.);
        k4r = (_MC2_in[hh][2*col] + _MC2_in[vv][2*col]) / sqrt(2.);
        k4i = (_MC2_in[hh][2*col+1] + _MC2_in[vv][2*col+1]) / sqrt(2.);
        k5r = (_MC2_in[hh][2*col] - _MC2_in[vv][2*col]) / sqrt(2.);
        k5i = (_MC2_in[hh][2*col+1] - _MC2_in[vv][2*col+1]) / sqrt(2.);
        k6r = (_MC2_in[hv][2*col] + _MC2_in[vh][2*col]) / sqrt(2.);
        k6i = (_MC2_in[hv][2*col+1] + _MC2_in[vh][2*col+1]) / sqrt(2.);
  
        _MF_in[T611][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        _MF_in[T612_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        _MF_in[T612_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        _MF_in[T613_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        _MF_in[T613_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        _MF_in[T614_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
        _MF_in[T614_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
        _MF_in[T615_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k5r + k1i * k5i;
        _MF_in[T615_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k5r - k1r * k5i;
        _MF_in[T616_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k6r + k1i * k6i;
        _MF_in[T616_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k6r - k1r * k6i;
        _MF_in[T622][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        _MF_in[T623_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        _MF_in[T623_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        _MF_in[T624_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
        _MF_in[T624_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
        _MF_in[T625_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k5r + k2i * k5i;
        _MF_in[T625_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k5r - k2r * k5i;
        _MF_in[T626_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k6r + k2i * k6i;
        _MF_in[T626_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k6r - k2r * k6i;
        _MF_in[T633][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        _MF_in[T634_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
        _MF_in[T634_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
        _MF_in[T635_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k5r + k3i * k5i;
        _MF_in[T635_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k5r - k3r * k5i;
        _MF_in[T636_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k6r + k3i * k6i;
        _MF_in[T636_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k6r - k3r * k6i;
        _MF_in[T644][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
        _MF_in[T645_re][lig][col - OOff_col + NNwinColM1S2] = k4r * k5r + k4i * k5i;
        _MF_in[T645_im][lig][col - OOff_col + NNwinColM1S2] = k4i * k5r - k4r * k5i;
        _MF_in[T646_re][lig][col - OOff_col + NNwinColM1S2] = k4r * k6r + k4i * k6i;
        _MF_in[T646_im][lig][col - OOff_col + NNwinColM1S2] = k4i * k6r - k4r * k6i;
        _MF_in[T655][lig][col - OOff_col + NNwinColM1S2] = k5r * k5r + k5i * k5i;
        }

      }
        
    } else {
    /* FSEEK NNwinL LINES */
    PointerPosition = (NNwinLigM1 * 2 * NNcol) * sizeof(float);
    for (Np = 0; Np < NNpolarIn; Np++) {
      fseek(datafile1[Np], -PointerPosition, SEEK_CUR);
      fseek(datafile2[Np], -PointerPosition, SEEK_CUR);
      }

    /* FIRST NNwin-1 LINES READING TO FILTER THE FIRST DATA LINE */
    for (lig = 0; lig < NNwinLigM1; lig++) {
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC1_in[Np][0], sizeof(float), 2 * NNcol, datafile1[Np]);
      for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC2_in[Np][0], sizeof(float), 2 * NNcol, datafile2[Np]);

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][lig][col] = 0.;

      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        k1r = (_MC1_in[hh][2*col] + _MC1_in[vv][2*col]) / sqrt(2.);
        k1i = (_MC1_in[hh][2*col+1] + _MC1_in[vv][2*col+1]) / sqrt(2.);
        k2r = (_MC1_in[hh][2*col] - _MC1_in[vv][2*col]) / sqrt(2.);
        k2i = (_MC1_in[hh][2*col+1] - _MC1_in[vv][2*col+1]) / sqrt(2.);
        k3r = (_MC1_in[hv][2*col] + _MC1_in[vh][2*col]) / sqrt(2.);
        k3i = (_MC1_in[hv][2*col+1] + _MC1_in[vh][2*col+1]) / sqrt(2.);
        k4r = (_MC2_in[hh][2*col] + _MC2_in[vv][2*col]) / sqrt(2.);
        k4i = (_MC2_in[hh][2*col+1] + _MC2_in[vv][2*col+1]) / sqrt(2.);
        k5r = (_MC2_in[hh][2*col] - _MC2_in[vv][2*col]) / sqrt(2.);
        k5i = (_MC2_in[hh][2*col+1] - _MC2_in[vv][2*col+1]) / sqrt(2.);
        k6r = (_MC2_in[hv][2*col] + _MC2_in[vh][2*col]) / sqrt(2.);
        k6i = (_MC2_in[hv][2*col+1] + _MC2_in[vh][2*col+1]) / sqrt(2.);
  
        _MF_in[T611][lig][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        _MF_in[T612_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        _MF_in[T612_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        _MF_in[T613_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        _MF_in[T613_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        _MF_in[T614_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
        _MF_in[T614_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
        _MF_in[T615_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k5r + k1i * k5i;
        _MF_in[T615_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k5r - k1r * k5i;
        _MF_in[T616_re][lig][col - OOff_col + NNwinColM1S2] = k1r * k6r + k1i * k6i;
        _MF_in[T616_im][lig][col - OOff_col + NNwinColM1S2] = k1i * k6r - k1r * k6i;
        _MF_in[T622][lig][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        _MF_in[T623_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        _MF_in[T623_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        _MF_in[T624_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
        _MF_in[T624_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
        _MF_in[T625_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k5r + k2i * k5i;
        _MF_in[T625_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k5r - k2r * k5i;
        _MF_in[T626_re][lig][col - OOff_col + NNwinColM1S2] = k2r * k6r + k2i * k6i;
        _MF_in[T626_im][lig][col - OOff_col + NNwinColM1S2] = k2i * k6r - k2r * k6i;
        _MF_in[T633][lig][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        _MF_in[T634_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
        _MF_in[T634_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
        _MF_in[T635_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k5r + k3i * k5i;
        _MF_in[T635_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k5r - k3r * k5i;
        _MF_in[T636_re][lig][col - OOff_col + NNwinColM1S2] = k3r * k6r + k3i * k6i;
        _MF_in[T636_im][lig][col - OOff_col + NNwinColM1S2] = k3i * k6r - k3r * k6i;
        _MF_in[T644][lig][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
        _MF_in[T645_re][lig][col - OOff_col + NNwinColM1S2] = k4r * k5r + k4i * k5i;
        _MF_in[T645_im][lig][col - OOff_col + NNwinColM1S2] = k4i * k5r - k4r * k5i;
        _MF_in[T646_re][lig][col - OOff_col + NNwinColM1S2] = k4r * k6r + k4i * k6i;
        _MF_in[T646_im][lig][col - OOff_col + NNwinColM1S2] = k4i * k6r - k4r * k6i;
        _MF_in[T655][lig][col - OOff_col + NNwinColM1S2] = k5r * k5r + k5i * k5i;
        }

      }
        
    } /* NNblock == 0 */
      
    /* READING AND AVERAGING NLIG LINES */
    for (lig = 0; lig < Sub_NNlig; lig++) {
      if (NNbBlock == 1) if (lig%(int)(Sub_NNlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_NNlig - 1));fflush(stdout);}

      /* 1 line reading with zero padding */
      if (lig < Sub_NNlig - NNwinLigM1S2) {
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC1_in[Np][0], sizeof(float), 2 * NNcol, datafile1[Np]);
        for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC2_in[Np][0], sizeof(float), 2 * NNcol, datafile2[Np]);
        } else {
        if (NNblock == (NNbBlock - 1)) {
          for (Np = 0; Np < NNpolarIn; Np++)
            for (col = 0; col < 2 * NNcol; col++) _MC_in[Np][col] = 0.;
          } else {
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC1_in[Np][0], sizeof(float), 2 * NNcol, datafile1[Np]);
          for (Np = 0; Np < NNpolarIn; Np++) fread(&_MC2_in[Np][0], sizeof(float), 2 * NNcol, datafile2[Np]);
          }
        }

      for (Np = 0; Np < NNpolar; Np++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++) _MF_in[Np][NNwinLigM1][col] = 0.;

      /* Row-wise shift */
      for (col = OOff_col; col < Sub_NNcol + OOff_col; col++) {
        k1r = (_MC1_in[hh][2*col] + _MC1_in[vv][2*col]) / sqrt(2.);
        k1i = (_MC1_in[hh][2*col+1] + _MC1_in[vv][2*col+1]) / sqrt(2.);
        k2r = (_MC1_in[hh][2*col] - _MC1_in[vv][2*col]) / sqrt(2.);
        k2i = (_MC1_in[hh][2*col+1] - _MC1_in[vv][2*col+1]) / sqrt(2.);
        k3r = (_MC1_in[hv][2*col] + _MC1_in[vh][2*col]) / sqrt(2.);
        k3i = (_MC1_in[hv][2*col+1] + _MC1_in[vh][2*col+1]) / sqrt(2.);
        k4r = (_MC2_in[hh][2*col] + _MC2_in[vv][2*col]) / sqrt(2.);
        k4i = (_MC2_in[hh][2*col+1] + _MC2_in[vv][2*col+1]) / sqrt(2.);
        k5r = (_MC2_in[hh][2*col] - _MC2_in[vv][2*col]) / sqrt(2.);
        k5i = (_MC2_in[hh][2*col+1] - _MC2_in[vv][2*col+1]) / sqrt(2.);
        k6r = (_MC2_in[hv][2*col] + _MC2_in[vh][2*col]) / sqrt(2.);
        k6i = (_MC2_in[hv][2*col+1] + _MC2_in[vh][2*col+1]) / sqrt(2.);
  
        _MF_in[T611][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k1r + k1i * k1i;
        _MF_in[T612_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k2r + k1i * k2i;
        _MF_in[T612_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k2r - k1r * k2i;
        _MF_in[T613_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k3r + k1i * k3i;
        _MF_in[T613_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k3r - k1r * k3i;
        _MF_in[T614_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k4r + k1i * k4i;
        _MF_in[T614_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k4r - k1r * k4i;
        _MF_in[T615_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k5r + k1i * k5i;
        _MF_in[T615_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k5r - k1r * k5i;
        _MF_in[T616_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1r * k6r + k1i * k6i;
        _MF_in[T616_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k1i * k6r - k1r * k6i;
        _MF_in[T622][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k2r + k2i * k2i;
        _MF_in[T623_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k3r + k2i * k3i;
        _MF_in[T623_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k3r - k2r * k3i;
        _MF_in[T624_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k4r + k2i * k4i;
        _MF_in[T624_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k4r - k2r * k4i;
        _MF_in[T625_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k5r + k2i * k5i;
        _MF_in[T625_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k5r - k2r * k5i;
        _MF_in[T626_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2r * k6r + k2i * k6i;
        _MF_in[T626_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k2i * k6r - k2r * k6i;
        _MF_in[T633][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k3r + k3i * k3i;
        _MF_in[T634_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k4r + k3i * k4i;
        _MF_in[T634_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3i * k4r - k3r * k4i;
        _MF_in[T635_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k5r + k3i * k5i;
        _MF_in[T635_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3i * k5r - k3r * k5i;
        _MF_in[T636_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3r * k6r + k3i * k6i;
        _MF_in[T636_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k3i * k6r - k3r * k6i;
        _MF_in[T644][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4r * k4r + k4i * k4i;
        _MF_in[T645_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4r * k5r + k4i * k5i;
        _MF_in[T645_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4i * k5r - k4r * k5i;
        _MF_in[T646_re][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4r * k6r + k4i * k6i;
        _MF_in[T646_im][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k4i * k6r - k4r * k6i;
        _MF_in[T655][NNwinLigM1][col - OOff_col + NNwinColM1S2] = k5r * k5r + k5i * k5i;
        }
  
      for (col = 0; col < Sub_NNcol; col++) {
        if (col == 0) {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = 0.;
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++)
            for (l = -NNwinColM1S2; l < 1 + NNwinColM1S2; l++) {
              for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinColM1S2 + col + l] / (float) (NNwinLig * NNwinCol);
              }
          } else {
          for (Np = 0; Np < NNpolar; Np++) M_out[Np][lig][col] = M_out[Np][lig][col-1];
          /* Average matrix element calculation */
          for (k = -NNwinLigM1S2; k < 1 + NNwinLigM1S2; k++) {
            for (Np = 0; Np < NNpolar; Np++) {
              M_out[Np][lig][col] = M_out[Np][lig][col] - _MF_in[Np][NNwinLigM1S2 + k][col - 1] / (float) (NNwinLig * NNwinCol);
              M_out[Np][lig][col] = M_out[Np][lig][col] + _MF_in[Np][NNwinLigM1S2 + k][NNwinCol - 1 + col] / (float) (NNwinLig * NNwinCol);
              }
            }
          }
        } /*col */

      /* Line-wise shift */
      for (l = 0; l < NNwinLigM1; l++)
        for (col = 0; col < Sub_NNcol + NNwinCol; col++)
          for (Np = 0; Np < NNpolar; Np++)
            _MF_in[Np][l][col] = _MF_in[Np][l + 1][col];
            
      } /*lig */
   
  return 1;
}
