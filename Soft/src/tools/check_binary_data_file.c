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

File   : check_binary_data_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 10/2012
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

Description :  Check size of a binary data file

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
  char FileIn[FilePathLength], FileOut[FilePathLength], FileOutTxt[FilePathLength], Sensor[100];

  int NNcol, NNrow, header;
  fpos_t size;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncheck_binary_data_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-ss  	sensor (terrasarx)\n");
strcat(UsageHelp," (int)   	-inc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileIn,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOut,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ss",str_cmd_prm,Sensor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&NNcol,1,UsageHelp);
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

  if ((file_in = fopen(FileIn, "rb")) == NULL)
  edit_error("Could not open input file : ", FileIn);

  rewind(file_in);
//  fseek(file_in, 0, SEEK_END);
//  size = ftell(file_in);
  fgetpos(file_in, &size);
  fclose(file_in);
  
  if (strcmp(Sensor,"terrasarx_ssc") == 0) {
    header = 4*(4*(NNcol+2));
#ifdef _WIN32
    NNrow = (int)((size - header) / (4*(NNcol+2)));
#else
    NNrow = (int)((size.__pos - header) / (4*(NNcol+2)));
#endif
    }


/* DATA WRITING */
  if ((file_out = fopen(FileOutTxt, "w")) == NULL)
  edit_error("Could not open input file : ", FileOutTxt);
  fprintf(file_out,"%lu\n",size);
  fprintf(file_out,"%i\n",header);
  fprintf(file_out,"%i\n",NNrow);
  fprintf(file_out,"%i\n",NNcol);
  fclose(file_out);

  return 1;
}
