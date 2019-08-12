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

File   : esar_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.2
Creation : 04/2002
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

Description :  Read Header of ESAR Files (Format SLC)

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
FILE *fileinput;
FILE *fileoutput;

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

  char FileInput[FilePathLength];
  char FileOutput[FilePathLength];

  int Nlig, Ncol;
  int IEEE;

  int *vv;
  char *pc;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nesar_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-iee 	IEEE data convert (no: 0, yes: 1)\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iee",int_cmd_prm,&IEEE,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

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
/* INPUT BINARY STK DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);

  if (IEEE == 0) {    /*IEEE Convert */
  vv = &Ncol;
  pc = (char *) vv;
  pc[0] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[3] = getc(fileinput);
  vv = &Nlig;
  pc = (char *) vv;
  pc[0] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[3] = getc(fileinput);
  }
  if (IEEE == 1) {    /*IEEE Convert */
  vv = &Ncol;
  pc = (char *) vv;
  pc[3] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[0] = getc(fileinput);
  vv = &Nlig;
  pc = (char *) vv;
  pc[3] = getc(fileinput);
  pc[2] = getc(fileinput);
  pc[1] = getc(fileinput);
  pc[0] = getc(fileinput);
  }
  fclose(fileinput);

/*******************************************************************/
/* WRITE Nlig/Ncol to TMP/Config.txt */
/*******************************************************************/

  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
  edit_error("Could not open configuration file : ", FileOutput);

  fprintf(fileoutput, "nlig\n");
  fprintf(fileoutput, "%i\n", Nlig);
  fprintf(fileoutput, "---------\n");
  fprintf(fileoutput, "ncol\n");
  fprintf(fileoutput, "%i\n", Ncol);

  fclose(fileoutput);

  return 1;
}
