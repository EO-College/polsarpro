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

File   : matX_operand_out_matX.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 01/2013
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

Description :  MatX (operand) = MatX

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
/* LOCAL VARIABLES */
  FILE *file_matX;
  char operand[10], Tmp[100], MatXtype[10];
  char matXfile0[FilePathLength];
  char matXfile1[FilePathLength];
  
/* Internal variables */
  int lig, col;
  int MatXdim;
  int FlagF, FlagH, FlagSU;
  
/* Matrix arrays */
  float ***MatX1;
  float ***M_out;
  float *det;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmatX_operand_out_matX.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file matX\n");
strcat(UsageHelp," (string)	-of  	output file matX\n");
strcat(UsageHelp," (string)	-op  	operand\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 7) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,matXfile1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,matXfile0,1,UsageHelp);
  get_commandline_prm(argc,argv,"-op",str_cmd_prm,operand,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(matXfile0);
  check_file(matXfile1);
 
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
/* INPUT FILE OPENING*/
  if ((file_matX = fopen(matXfile1, "r")) == NULL)
      edit_error("Could not open input file : ", matXfile1);
  
  fgets(&Tmp[0], 100, file_matX);
  fscanf(file_matX, "%s\n", MatXtype);
  fscanf(file_matX, "%i\n", &MatXdim);
  MatX1 = matrix3d_float(MatXdim, MatXdim, 2); 
  if (MatXdim == 4) {
    if ((strcmp(MatXtype,"cmplx")==0)||(strcmp(MatXtype,"SU")==0)) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]);fscanf(file_matX, "%f\n", &MatX1[0][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]);fscanf(file_matX, "%f\n", &MatX1[0][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][2][0]);fscanf(file_matX, "%f\n", &MatX1[0][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][3][0]);fscanf(file_matX, "%f\n", &MatX1[0][3][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][0][0]);fscanf(file_matX, "%f\n", &MatX1[1][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]);fscanf(file_matX, "%f\n", &MatX1[1][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][2][0]);fscanf(file_matX, "%f\n", &MatX1[1][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][3][0]);fscanf(file_matX, "%f\n", &MatX1[1][3][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][0][0]);fscanf(file_matX, "%f\n", &MatX1[2][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][1][0]);fscanf(file_matX, "%f\n", &MatX1[2][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][2][0]);fscanf(file_matX, "%f\n", &MatX1[2][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][3][0]);fscanf(file_matX, "%f\n", &MatX1[2][3][1]);
      fscanf(file_matX, "%f\n", &MatX1[3][0][0]);fscanf(file_matX, "%f\n", &MatX1[3][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[3][1][0]);fscanf(file_matX, "%f\n", &MatX1[3][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[3][2][0]);fscanf(file_matX, "%f\n", &MatX1[3][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[3][3][0]);fscanf(file_matX, "%f\n", &MatX1[3][3][1]);
      }
    if (strcmp(MatXtype,"herm")==0) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]); MatX1[0][0][1]= 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]);fscanf(file_matX, "%f\n", &MatX1[0][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][2][0]);fscanf(file_matX, "%f\n", &MatX1[0][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][3][0]);fscanf(file_matX, "%f\n", &MatX1[0][3][1]);
      MatX1[1][0][0] = MatX1[0][1][0]; MatX1[1][0][1] = -MatX1[0][1][1];
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]); MatX1[1][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][2][0]);fscanf(file_matX, "%f\n", &MatX1[1][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][3][0]);fscanf(file_matX, "%f\n", &MatX1[1][3][1]);
      MatX1[2][0][0] = MatX1[0][2][0]; MatX1[2][0][1] = -MatX1[0][2][1];
      MatX1[2][1][0] = MatX1[1][2][0]; MatX1[2][1][1] = -MatX1[1][2][1];
      fscanf(file_matX, "%f\n", &MatX1[2][2][0]); MatX1[2][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][3][0]);fscanf(file_matX, "%f\n", &MatX1[2][3][1]);
      MatX1[3][0][0] = MatX1[0][3][0]; MatX1[3][0][1] = -MatX1[0][3][1];
      MatX1[3][1][0] = MatX1[1][3][0]; MatX1[3][1][1] = -MatX1[1][3][1];
      MatX1[3][2][0] = MatX1[2][3][0]; MatX1[3][2][1] = -MatX1[2][3][1];
      fscanf(file_matX, "%f\n", &MatX1[3][3][0]); MatX1[3][3][1] = 0.;
      }
    if (strcmp(MatXtype,"float")==0) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]); MatX1[0][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]); MatX1[0][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][2][0]); MatX1[0][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][3][0]); MatX1[0][3][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][0][0]); MatX1[1][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]); MatX1[1][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][2][0]); MatX1[1][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][3][0]); MatX1[1][3][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][0][0]); MatX1[2][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][1][0]); MatX1[2][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][2][0]); MatX1[2][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][3][0]); MatX1[2][3][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[3][0][0]); MatX1[3][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[3][1][0]); MatX1[3][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[3][2][0]); MatX1[3][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[3][3][0]); MatX1[3][3][1] = 0.;
      }
    }
  if (MatXdim == 3) {
    if ((strcmp(MatXtype,"cmplx")==0)||(strcmp(MatXtype,"SU")==0)) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]);fscanf(file_matX, "%f\n", &MatX1[0][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]);fscanf(file_matX, "%f\n", &MatX1[0][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][2][0]);fscanf(file_matX, "%f\n", &MatX1[0][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][0][0]);fscanf(file_matX, "%f\n", &MatX1[1][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]);fscanf(file_matX, "%f\n", &MatX1[1][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][2][0]);fscanf(file_matX, "%f\n", &MatX1[1][2][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][0][0]);fscanf(file_matX, "%f\n", &MatX1[2][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][1][0]);fscanf(file_matX, "%f\n", &MatX1[2][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[2][2][0]);fscanf(file_matX, "%f\n", &MatX1[2][2][1]);
      }
    if (strcmp(MatXtype,"herm")==0) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]); MatX1[0][0][1]= 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]);fscanf(file_matX, "%f\n", &MatX1[0][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][2][0]);fscanf(file_matX, "%f\n", &MatX1[0][2][1]);
      MatX1[1][0][0] = MatX1[0][1][0]; MatX1[1][0][1] = -MatX1[0][1][1];
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]); MatX1[1][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][2][0]);fscanf(file_matX, "%f\n", &MatX1[1][2][1]);
      MatX1[2][0][0] = MatX1[0][2][0]; MatX1[2][0][1] = -MatX1[0][2][1];
      MatX1[2][1][0] = MatX1[1][2][0]; MatX1[2][1][1] = -MatX1[1][2][1];
      fscanf(file_matX, "%f\n", &MatX1[2][2][0]); MatX1[2][2][1] = 0.;
      }
    if (strcmp(MatXtype,"float")==0) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]); MatX1[0][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]); MatX1[0][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][2][0]); MatX1[0][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][0][0]); MatX1[1][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]); MatX1[1][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][2][0]); MatX1[1][2][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][0][0]); MatX1[2][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][1][0]); MatX1[2][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[2][2][0]); MatX1[2][2][1] = 0.;
      }
    }
  if (MatXdim == 2) {
    if ((strcmp(MatXtype,"cmplx")==0)||(strcmp(MatXtype,"SU")==0)) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]);fscanf(file_matX, "%f\n", &MatX1[0][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]);fscanf(file_matX, "%f\n", &MatX1[0][1][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][0][0]);fscanf(file_matX, "%f\n", &MatX1[1][0][1]);
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]);fscanf(file_matX, "%f\n", &MatX1[1][1][1]);
      }
    if (strcmp(MatXtype,"herm")==0) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]); MatX1[0][0][1]= 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]);fscanf(file_matX, "%f\n", &MatX1[0][1][1]);
      MatX1[1][0][0] = MatX1[0][1][0]; MatX1[1][0][1] = -MatX1[0][1][1];
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]); MatX1[1][1][1] = 0.;
      }
    if (strcmp(MatXtype,"float")==0) {
      fscanf(file_matX, "%f\n", &MatX1[0][0][0]); MatX1[0][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[0][1][0]); MatX1[0][1][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][0][0]); MatX1[1][0][1] = 0.;
      fscanf(file_matX, "%f\n", &MatX1[1][1][0]); MatX1[1][1][1] = 0.;
      }
    }
  fclose(file_matX);
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  M_out = matrix3d_float(MatXdim, MatXdim, 2); 
  det = vector_float(2);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

   if (strcmp(operand,"conj") == 0 ) {
     for (lig = 0; lig < MatXdim; lig++) {
       for (col = 0; col < MatXdim; col++) {
         M_out[lig][col][0] = MatX1[lig][col][0];
         M_out[lig][col][1] = -MatX1[lig][col][1];
         }
      }
    }
   if (strcmp(operand,"inv") == 0 ) {
     if (MatXdim == 2) InverseHermitianMatrix2(MatX1,M_out);
     if (MatXdim == 3) InverseHermitianMatrix3(MatX1,M_out);
     if (MatXdim == 4) InverseHermitianMatrix4(MatX1,M_out);
     }

/********************************************************************
********************************************************************/
/* TYPE DETERMINATION */

  FlagF = 0;
  for (lig = 0; lig < MatXdim; lig++) {
    for (col = 0; col < MatXdim; col++) {
      if (M_out[lig][col][1] != 0.) FlagF = 1;
      }
    }
  FlagH = 0;
  for (lig = 0; lig < MatXdim; lig++) {
    for (col = 0; col < MatXdim; col++) {
      if (lig == col) {
        if (M_out[lig][lig][1] != 0.) FlagH = 1;
        } else {
        if (M_out[lig][col][1] != -M_out[col][lig][1]) FlagH = 1;
        }
      }
    }
  FlagSU = 0;
  if (MatXdim == 2) DeterminantCmplxMatrix2(M_out, det);
  if (MatXdim == 3) DeterminantCmplxMatrix3(M_out, det);
  if (MatXdim == 4) DeterminantCmplxMatrix4(M_out, det);
  if ((1. - eps <= det[0])&&(det[0] <= 1. + eps)&&(- eps <= det[1])&&(det[1] <= + eps)) FlagSU = 0;
  else FlagSU = 1;

  if (FlagF == 0) strcpy(MatXtype,"float");
  else if (FlagH == 0) strcpy(MatXtype,"herm");
       else if (FlagSU == 0) strcpy(MatXtype,"SU");
            else strcpy(MatXtype,"cmplx");

/********************************************************************
********************************************************************/
/* OUTPUT FILE OPENING*/
  if ((file_matX = fopen(matXfile0, "w")) == NULL)
      edit_error("Could not open input file : ", matXfile0);
  
  fprintf(file_matX, "%s\n", "PolSARpro Calculator v1.0");
  fprintf(file_matX, "%s\n", MatXtype);
  fprintf(file_matX, "%i\n", MatXdim);
  if (MatXdim == 4) {
    if ((strcmp(MatXtype,"cmplx")==0)||(strcmp(MatXtype,"SU")==0)) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]);fprintf(file_matX, "%f\n", M_out[0][0][1]);
      fprintf(file_matX, "%f\n", M_out[0][1][0]);fprintf(file_matX, "%f\n", M_out[0][1][1]);
      fprintf(file_matX, "%f\n", M_out[0][2][0]);fprintf(file_matX, "%f\n", M_out[0][2][1]);
      fprintf(file_matX, "%f\n", M_out[0][3][0]);fprintf(file_matX, "%f\n", M_out[0][3][1]);
      fprintf(file_matX, "%f\n", M_out[1][0][0]);fprintf(file_matX, "%f\n", M_out[1][0][1]);
      fprintf(file_matX, "%f\n", M_out[1][1][0]);fprintf(file_matX, "%f\n", M_out[1][1][1]);
      fprintf(file_matX, "%f\n", M_out[1][2][0]);fprintf(file_matX, "%f\n", M_out[1][2][1]);
      fprintf(file_matX, "%f\n", M_out[1][3][0]);fprintf(file_matX, "%f\n", M_out[1][3][1]);
      fprintf(file_matX, "%f\n", M_out[2][0][0]);fprintf(file_matX, "%f\n", M_out[2][0][1]);
      fprintf(file_matX, "%f\n", M_out[2][1][0]);fprintf(file_matX, "%f\n", M_out[2][1][1]);
      fprintf(file_matX, "%f\n", M_out[2][2][0]);fprintf(file_matX, "%f\n", M_out[2][2][1]);
      fprintf(file_matX, "%f\n", M_out[2][3][0]);fprintf(file_matX, "%f\n", M_out[2][3][1]);
      fprintf(file_matX, "%f\n", M_out[3][0][0]);fprintf(file_matX, "%f\n", M_out[3][0][1]);
      fprintf(file_matX, "%f\n", M_out[3][1][0]);fprintf(file_matX, "%f\n", M_out[3][1][1]);
      fprintf(file_matX, "%f\n", M_out[3][2][0]);fprintf(file_matX, "%f\n", M_out[3][2][1]);
      fprintf(file_matX, "%f\n", M_out[3][3][0]);fprintf(file_matX, "%f\n", M_out[3][3][1]);
      }
    if (strcmp(MatXtype,"herm")==0) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]);
      fprintf(file_matX, "%f\n", M_out[0][1][0]);fprintf(file_matX, "%f\n", M_out[0][1][1]);
      fprintf(file_matX, "%f\n", M_out[0][2][0]);fprintf(file_matX, "%f\n", M_out[0][2][1]);
      fprintf(file_matX, "%f\n", M_out[0][3][0]);fprintf(file_matX, "%f\n", M_out[0][3][1]);
      fprintf(file_matX, "%f\n", M_out[1][1][0]);
      fprintf(file_matX, "%f\n", M_out[1][2][0]);fprintf(file_matX, "%f\n", M_out[1][2][1]);
      fprintf(file_matX, "%f\n", M_out[1][3][0]);fprintf(file_matX, "%f\n", M_out[1][3][1]);
      fprintf(file_matX, "%f\n", M_out[2][2][0]);
      fprintf(file_matX, "%f\n", M_out[2][3][0]);fprintf(file_matX, "%f\n", M_out[2][3][1]);
      fprintf(file_matX, "%f\n", M_out[3][3][0]);
      }
    if (strcmp(MatXtype,"float")==0) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]); 
      fprintf(file_matX, "%f\n", M_out[0][1][0]); 
      fprintf(file_matX, "%f\n", M_out[0][2][0]); 
      fprintf(file_matX, "%f\n", M_out[0][3][0]); 
      fprintf(file_matX, "%f\n", M_out[1][0][0]); 
      fprintf(file_matX, "%f\n", M_out[1][1][0]); 
      fprintf(file_matX, "%f\n", M_out[1][2][0]); 
      fprintf(file_matX, "%f\n", M_out[1][3][0]); 
      fprintf(file_matX, "%f\n", M_out[2][0][0]); 
      fprintf(file_matX, "%f\n", M_out[2][1][0]); 
      fprintf(file_matX, "%f\n", M_out[2][2][0]); 
      fprintf(file_matX, "%f\n", M_out[2][3][0]); 
      fprintf(file_matX, "%f\n", M_out[3][0][0]); 
      fprintf(file_matX, "%f\n", M_out[3][1][0]); 
      fprintf(file_matX, "%f\n", M_out[3][2][0]); 
      fprintf(file_matX, "%f\n", M_out[3][3][0]); 
      }
    }
  if (MatXdim == 3) {
    if ((strcmp(MatXtype,"cmplx")==0)||(strcmp(MatXtype,"SU")==0)) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]);fprintf(file_matX, "%f\n", M_out[0][0][1]);
      fprintf(file_matX, "%f\n", M_out[0][1][0]);fprintf(file_matX, "%f\n", M_out[0][1][1]);
      fprintf(file_matX, "%f\n", M_out[0][2][0]);fprintf(file_matX, "%f\n", M_out[0][2][1]);
      fprintf(file_matX, "%f\n", M_out[1][0][0]);fprintf(file_matX, "%f\n", M_out[1][0][1]);
      fprintf(file_matX, "%f\n", M_out[1][1][0]);fprintf(file_matX, "%f\n", M_out[1][1][1]);
      fprintf(file_matX, "%f\n", M_out[1][2][0]);fprintf(file_matX, "%f\n", M_out[1][2][1]);
      fprintf(file_matX, "%f\n", M_out[2][0][0]);fprintf(file_matX, "%f\n", M_out[2][0][1]);
      fprintf(file_matX, "%f\n", M_out[2][1][0]);fprintf(file_matX, "%f\n", M_out[2][1][1]);
      fprintf(file_matX, "%f\n", M_out[2][2][0]);fprintf(file_matX, "%f\n", M_out[2][2][1]);
      }
    if (strcmp(MatXtype,"herm")==0) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]);
      fprintf(file_matX, "%f\n", M_out[0][1][0]);fprintf(file_matX, "%f\n", M_out[0][1][1]);
      fprintf(file_matX, "%f\n", M_out[0][2][0]);fprintf(file_matX, "%f\n", M_out[0][2][1]);
      fprintf(file_matX, "%f\n", M_out[1][1][0]);
      fprintf(file_matX, "%f\n", M_out[1][2][0]);fprintf(file_matX, "%f\n", M_out[1][2][1]);
      fprintf(file_matX, "%f\n", M_out[2][2][0]);
      }
    if (strcmp(MatXtype,"float")==0) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]); 
      fprintf(file_matX, "%f\n", M_out[0][1][0]); 
      fprintf(file_matX, "%f\n", M_out[0][2][0]); 
      fprintf(file_matX, "%f\n", M_out[1][0][0]); 
      fprintf(file_matX, "%f\n", M_out[1][1][0]); 
      fprintf(file_matX, "%f\n", M_out[1][2][0]); 
      fprintf(file_matX, "%f\n", M_out[2][0][0]); 
      fprintf(file_matX, "%f\n", M_out[2][1][0]); 
      fprintf(file_matX, "%f\n", M_out[2][2][0]); 
      }
    }
  if (MatXdim == 2) {
    if ((strcmp(MatXtype,"cmplx")==0)||(strcmp(MatXtype,"SU")==0)) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]);fprintf(file_matX, "%f\n", M_out[0][0][1]);
      fprintf(file_matX, "%f\n", M_out[0][1][0]);fprintf(file_matX, "%f\n", M_out[0][1][1]);
      fprintf(file_matX, "%f\n", M_out[1][0][0]);fprintf(file_matX, "%f\n", M_out[1][0][1]);
      fprintf(file_matX, "%f\n", M_out[1][1][0]);fprintf(file_matX, "%f\n", M_out[1][1][1]);
      }
    if (strcmp(MatXtype,"herm")==0) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]);
      fprintf(file_matX, "%f\n", M_out[0][1][0]);fprintf(file_matX, "%f\n", M_out[0][1][1]);
      fprintf(file_matX, "%f\n", M_out[1][1][0]);
      }
    if (strcmp(MatXtype,"float")==0) {
      fprintf(file_matX, "%f\n", M_out[0][0][0]); 
      fprintf(file_matX, "%f\n", M_out[0][1][0]); 
      fprintf(file_matX, "%f\n", M_out[1][0][0]); 
      fprintf(file_matX, "%f\n", M_out[1][1][0]); 
      }
    }
  fclose(file_matX);
    
/********************************************************************
********************************************************************/

  return 1;
}

