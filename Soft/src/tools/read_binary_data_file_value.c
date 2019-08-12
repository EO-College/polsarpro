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

File   : read_binary_data_file_value.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Read a binary data file value

********************************************************************/
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

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* ACCESS FILE */

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
/*                                      */
{

/* LOCAL VARIABLES */
  FILE *file_in, *file_out;
  char FileIn[FilePathLength], FileOut[FilePathLength];
  char FileOutTxt[FilePathLength];
  char Type[10];

  int lig, Ncol, OffLig, OffCol;

  int *MinInt;
  float *MinFlt;
  float *MinCmplx;
  
  int ValueInt,ValueIntMod;
  float ValueFlt,ValueFltMod;
  float ValueCmpxReal,ValueCmpxImag,ValueCmplxMod,ValueCmplxArg;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nread_binary_data_file_value.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-idf 	input data format (int, float, cmplx)\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ir  	Row\n");
strcat(UsageHelp," (int)   	-ic  	Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileIn,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOut,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,Type,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ir",int_cmd_prm,&OffLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ic",int_cmd_prm,&OffCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileIn);
  sprintf(FileOutTxt, "%s.txt", FileOut);
  check_file(FileOutTxt);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  OffLig--;
  OffCol--;
  
  if (strcmp(Type,"int") == 0) {
    MinInt = vector_int(Ncol);
    }
  if (strcmp(Type,"float") == 0) {
    MinFlt = vector_float(Ncol);
    }
  if (strcmp(Type,"cmplx") == 0) {
    MinCmplx = vector_float(2*Ncol);
    }

  if ((file_in = fopen(FileIn, "rb")) == NULL)
  edit_error("Could not open input file : ", FileIn);

  for (lig = 0; lig < OffLig+1; lig++) {
    if (strcmp(Type,"int") == 0) {
      fread(&MinInt[0], sizeof(int), Ncol, file_in);
      }
    if (strcmp(Type,"float") == 0) {
      fread(&MinFlt[0], sizeof(float), Ncol, file_in);
      }
    if (strcmp(Type,"cmplx") == 0) {
      fread(&MinCmplx[0], sizeof(float), 2*Ncol, file_in);
      }
    }  /*lig */


  if (strcmp(Type,"int") == 0) {
    ValueInt = MinInt[OffCol];
    ValueIntMod = abs(MinInt[OffCol]);
    }
  if (strcmp(Type,"float") == 0) {
    ValueFlt = MinFlt[OffCol];
    ValueFltMod = fabs(MinFlt[OffCol]);
    }
  if (strcmp(Type,"cmplx") == 0) {
    ValueCmpxReal = MinCmplx[2*OffCol];
    ValueCmpxImag = MinCmplx[2*OffCol+1];
    ValueCmplxMod = sqrt(ValueCmpxReal*ValueCmpxReal + ValueCmpxImag*ValueCmpxImag);
    ValueCmplxArg = atan2(ValueCmpxImag,ValueCmpxReal) * 180. / pi;
    }

  fclose(file_in);

/* DATA WRITING */

  if ((file_out = fopen(FileOutTxt, "w")) == NULL)
  edit_error("Could not open input file : ", FileOutTxt);

  if (strcmp(Type,"int") == 0) {
    fprintf(file_out,"%i\n",ValueInt);
    fprintf(file_out,"%i\n",ValueIntMod);
    }
  if (strcmp(Type,"float") == 0) {
    fprintf(file_out,"%f\n",ValueFlt);
    fprintf(file_out,"%f\n",ValueFltMod);
    }
  if (strcmp(Type,"cmplx") == 0) {
    fprintf(file_out,"%f\n",ValueCmpxReal);
    fprintf(file_out,"%f\n",ValueCmpxImag);
    fprintf(file_out,"%f\n",ValueCmplxMod);
    fprintf(file_out,"%f\n",ValueCmplxArg);
    }

  fclose(file_out);

  return 1;
}
