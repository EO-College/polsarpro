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

File   : envi_bmp_config_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2018
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

Description :  Create the ENVI Config File associated to a 
               bmp (8 or 24 bytes) data file

*********************************************************************/
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
  FILE *fp;
  char EnviFile[FilePathLength];
  int Nlig, Ncol, Ncolor;
  float Max, Min;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nenvi_bmp_config_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-bmp 	binary data file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-col 	Number of Color (8 or 24 bytes)\n");
strcat(UsageHelp," (float) 	-max 	Maximum Value\n");
strcat(UsageHelp," (float) 	-min 	Minimum Value\n");
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
  get_commandline_prm(argc,argv,"-bmp",str_cmd_prm,EnviFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-col",int_cmd_prm,&Ncolor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-max",flt_cmd_prm,&Max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-min",flt_cmd_prm,&Min,1,UsageHelp);
  }

/********************************************************************
********************************************************************/
  strcat(EnviFile, ".hdr");
  check_file(EnviFile);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  if ((fp = fopen(EnviFile, "w")) == NULL)
    edit_error("Could not open input file : ", EnviFile);

  fprintf(fp, "ENVI\n");
  fprintf(fp, "description = {\n");
  fprintf(fp, "PolSARpro File Imported to ENVI}\n");
  fprintf(fp, "samples = %i\n", Ncol);
  fprintf(fp, "lines   = %i\n", Nlig);
  fprintf(fp, "max val = %f\n", Max);
  fprintf(fp, "min val = %f\n", Min);
  fprintf(fp, "color   = %i bytes\n", Ncolor);

  fclose(fp);

  return 1;
}
