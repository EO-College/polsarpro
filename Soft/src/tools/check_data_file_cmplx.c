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

File   : check_data_file_cmplx.c
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

Description :  Check NaN or Infinity in a Complex Raw Binary Data File 

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

/* ACCESS FILE */
FILE *fileinput;
FILE *fileoutput;

/* GLOBAL ARRAYS */
float *bufferdata;

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

  char FileInput[FilePathLength], FileOutput[FilePathLength];

  int lig, col;
  int FlagCheck;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncheck_data_file_cmplx.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
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

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  bufferdata = vector_float(2 * Sub_Ncol);

  check_file(FileInput);
  check_file(FileOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);

  for (lig = 0; lig < Off_lig; lig++) 
    fread(&bufferdata[0], sizeof(float), 2 * Sub_Ncol, fileinput);

  FlagCheck = 0;
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    fread(&bufferdata[0], sizeof(float), 2 * Sub_Ncol, fileinput);
    for (col = 0; col < Sub_Ncol; col++)
      {
      if (my_isfinite(bufferdata[2 * (col + Off_col)]) == 0) FlagCheck = 1;
      if (my_isfinite(bufferdata[2 * (col + Off_col) + 1]) == 0) FlagCheck = 1;
      }
    }

  fclose(fileinput);

/*******************************************************************/
/* OUTPUT CHECK RESULT FILE */
/*******************************************************************/
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);
  if (FlagCheck == 0) fprintf(fileoutput, "No NaN or Infinity Detected\n");
  if (FlagCheck == 1) fprintf(fileoutput, "NaN or Infinity Detected\n");
  fclose(fileoutput);
  return 1;
}
