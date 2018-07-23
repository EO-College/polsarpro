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

File   : compare_binary_data_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

*--------------------------------------------------------------------

Description :  Compare 2 binary data files

********************************************************************/
/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

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
  FILE *file_in1, *file_in2, *file_out;
  char FileIn1[FilePathLength], FileIn2[FilePathLength], FileOut[FilePathLength];
  char FileOutTxt[FilePathLength], FileOutBin[FilePathLength];
  char Type[10];

  int lig, col, Ncol;
  int OffLig, OffCol, SubNlig, SubNcol;

  int *Min1Int, *Min2Int;
  float *Min1Flt, *Min2Flt;
  float *Min1Cmplx, *Min2Cmplx;
  float *Mout;
  float Result;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncompare_binary_data_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if1 	input data file 1\n");
strcat(UsageHelp," (string)	-if2 	input data file 2\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-idf 	input data format (int, float, cmplx)\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,FileIn1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,FileIn2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOut,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,Type,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&OffLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&OffCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&SubNlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&SubNcol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileIn1);
  check_file(FileIn2);
  sprintf(FileOutBin, "%s.bin", FileOut);
  sprintf(FileOutTxt, "%s.txt", FileOut);
  check_file(FileOutBin);
  check_file(FileOutTxt);

  if (strcmp(Type,"int") == 0) {
    Min1Int = vector_int(Ncol);
    Min2Int = vector_int(Ncol);
    }
  if (strcmp(Type,"float") == 0) {
    Min1Flt = vector_float(Ncol);
    Min2Flt = vector_float(Ncol);
    }
  if (strcmp(Type,"cmplx") == 0) {
    Min1Cmplx = vector_float(2*Ncol);
    Min2Cmplx = vector_float(2*Ncol);
    }

  Mout = vector_float(SubNcol);

  if ((file_in1 = fopen(FileIn1, "rb")) == NULL)
  edit_error("Could not open input file : ", FileIn1);
  if ((file_in2 = fopen(FileIn2, "rb")) == NULL)
  edit_error("Could not open input file : ", FileIn2);

  for (lig = 0; lig < OffLig; lig++) {
    if (strcmp(Type,"int") == 0) {
      fread(&Min1Int[0], sizeof(int), Ncol, file_in1);
      fread(&Min2Int[0], sizeof(int), Ncol, file_in2);
      }
    if (strcmp(Type,"float") == 0) {
      fread(&Min1Flt[0], sizeof(float), Ncol, file_in1);
      fread(&Min2Flt[0], sizeof(float), Ncol, file_in2);
      }
    if (strcmp(Type,"cmplx") == 0) {
      fread(&Min1Cmplx[0], sizeof(float), 2*Ncol, file_in1);
      fread(&Min2Cmplx[0], sizeof(float), 2*Ncol, file_in2);
      }
    }  /*lig */

  if ((file_out = fopen(FileOutBin, "wb")) == NULL)
  edit_error("Could not open input file : ", FileOutBin);

  Result = 0.;
  for (lig = 0; lig < SubNlig; lig++) {
  if (lig%(int)(SubNlig/20) == 0) {printf("%f\r", 100. * lig / (SubNlig - 1));fflush(stdout);}
    if (strcmp(Type,"int") == 0) {
      fread(&Min1Int[0], sizeof(int), Ncol, file_in1);
      fread(&Min2Int[0], sizeof(int), Ncol, file_in2);
      for (col = 0; col < SubNcol; col++) {
        Mout[col] = 1.;
        if (fabs(Min1Int[col+OffCol] - Min2Int[col+OffCol]) > 1.E-5) Mout[col] = 0.;
        if (fabs(Min1Int[col+OffCol] - Min2Int[col+OffCol]) > 1.E-5) Result = Result + 1.;
        }
      }
    if (strcmp(Type,"float") == 0) {
      fread(&Min1Flt[0], sizeof(float), Ncol, file_in1);
      fread(&Min2Flt[0], sizeof(float), Ncol, file_in2);
      for (col = 0; col < SubNcol; col++) {
        Mout[col] = 1.;
//        if (fabs(Min1Flt[col+OffCol] - Min2Flt[col+OffCol]) > 1.E-5) Mout[col] = 0.;
        Mout[col] = Min1Flt[col+OffCol] - Min2Flt[col+OffCol];
        if (fabs(Min1Flt[col+OffCol] - Min2Flt[col+OffCol]) > 1.E-5) Result = Result + 1.;
        }
      }
    if (strcmp(Type,"cmplx") == 0) {
      fread(&Min1Cmplx[0], sizeof(float), 2*Ncol, file_in1);
      fread(&Min2Cmplx[0], sizeof(float), 2*Ncol, file_in2);
      for (col = 0; col < SubNcol; col++) {
        Mout[col] = 1.;
        if (fabs(Min1Cmplx[2*(col+OffCol)] - Min2Cmplx[2*(col+OffCol)]) > 1.E-5) Mout[col] = 0.;
        if (fabs(Min1Cmplx[2*(col+OffCol)+1] - Min2Cmplx[2*(col+OffCol)+1]) > 1.E-5) Mout[col] = 0.;
        if (fabs(Min1Cmplx[2*(col+OffCol)] - Min2Cmplx[2*(col+OffCol)]) > 1.E-5) Result = Result + 0.5;
        if (fabs(Min1Cmplx[2*(col+OffCol)+1] - Min2Cmplx[2*(col+OffCol)+1]) > 1.E-5) Result = Result + 0.5;
        }
      }
    fwrite(&Mout[0],sizeof(float),SubNcol,file_out);
    }  /*lig */

  fclose(file_out);
  fclose(file_in1);
  fclose(file_in2);

/* DATA WRITING */

  if ((file_out = fopen(FileOutTxt, "w")) == NULL)
  edit_error("Could not open input file : ", FileOutTxt);
  if (Result <= 0.05*SubNlig*SubNcol) fprintf(file_out,"1\n");
  else fprintf(file_out,"0\n");
  fclose(file_out);

  return 1;
}
