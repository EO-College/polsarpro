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

File   : apply_mask_valid_pixels.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2010
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

Description :  Apply a valid mask file on binary data

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
  FILE *file_in, *file_mask, *file_out;
  char EnviFile[FilePathLength], EnviMask[FilePathLength];

  int lig, col, EnviType;

/* Matrix arrays */
  int **MoutInt, *MinInt;
  float **MoutFlt, *MinFlt;
  float **MoutCmplx, *MinCmplx;
  float *Mask;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\napply_mask_valid_pixels.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-bf  	input/output binary data file\n");
strcat(UsageHelp," (string)	-mf  	mask file\n");
strcat(UsageHelp," (int)   	-iodf	input-output data format (2= int, 4=float, 6=cmplx)\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 11) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-bf",str_cmd_prm,EnviFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mf",str_cmd_prm,EnviMask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",int_cmd_prm,&EnviType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(EnviFile);
  check_file(EnviMask);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  if (EnviType == 2) {
    MoutInt = matrix_int(Nlig,Ncol);
    MinInt = vector_int(Ncol);
    }
  if (EnviType == 4) {
    MoutFlt = matrix_float(Nlig,Ncol);
    MinFlt = vector_float(Ncol);
    }
  if (EnviType == 6) {
    MoutCmplx = matrix_float(Nlig,2*Ncol);
    MinCmplx = vector_float(2*Ncol);
    }
  Mask = vector_float(Ncol);

/********************************************************************
********************************************************************/
  if ((file_in = fopen(EnviFile, "rb")) == NULL)
    edit_error("Could not open input file : ", EnviFile);
  if ((file_mask = fopen(EnviMask, "rb")) == NULL)
    edit_error("Could not open input file : ", EnviMask);

/********************************************************************
********************************************************************/

/* DATA PROCESSING */

  for (lig = 0; lig < Nlig; lig++) {
    PrintfLine(lig,Nlig);
    fread(&Mask[0], sizeof(float), Ncol, file_mask);
    if (EnviType == 2) {
      fread(&MinInt[0], sizeof(int), Ncol, file_in);
      for (col = 0; col < Ncol; col++) {
        MoutInt[lig][col] = 0;
        if (Mask[col] == 1.) MoutInt[lig][col] = MinInt[col];
        }
      }
    if (EnviType == 4) {
      fread(&MinFlt[0], sizeof(float), Ncol, file_in);
      for (col = 0; col < Ncol; col++) {
        MoutFlt[lig][col] = Mask[col] * MinFlt[col];
        }
      }
    if (EnviType == 6) {
      fread(&MinCmplx[0], sizeof(float), 2*Ncol, file_in);
      for (col = 0; col < Ncol; col++) {
        MoutCmplx[lig][2*col] = Mask[col] * MinCmplx[2*col];
        MoutCmplx[lig][2*col+1] = Mask[col] * MinCmplx[2*col+1];
        }
      }
    }  /*lig */

  fclose(file_in);
  fclose(file_mask);

/********************************************************************
********************************************************************/

/* DATA WRITING */

  if ((file_out = fopen(EnviFile, "wb")) == NULL)
    edit_error("Could not open input file : ", EnviFile);

  for (lig = 0; lig < Nlig; lig++) {
    PrintfLine(lig,Nlig);
    if (EnviType == 2) fwrite(&MoutInt[lig][0], sizeof(int), Ncol, file_out);
    if (EnviType == 4) fwrite(&MoutFlt[lig][0], sizeof(float), Ncol, file_out);
    if (EnviType == 6) fwrite(&MoutCmplx[lig][0], sizeof(float), 2*Ncol, file_out);
    }

  fclose(file_out);

/********************************************************************
********************************************************************/

  free_vector_float(Mask);
  if (EnviType == 2) free_matrix_int(MoutInt,Nlig);
  if (EnviType == 4) free_matrix_float(MoutFlt,Nlig);
  if (EnviType == 6) free_matrix_float(MoutCmplx,Nlig);
  if (EnviType == 2) free_vector_int(MinInt);
  if (EnviType == 4) free_vector_float(MinFlt);
  if (EnviType == 6) free_vector_float(MinCmplx);
  
/********************************************************************
********************************************************************/

  return 1;

}
