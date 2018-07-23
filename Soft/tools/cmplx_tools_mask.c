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

File   : cmplx_tools_mask.c
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

Description :  Cmplx data file processing - Apply Mask

********************************************************************/
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
FILE *fileinput;
FILE *fileoutput;
FILE *filemask;

/* GLOBAL ARRAYS */
float *bufferdata;
float *buffermask;

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
  char DirInput[FilePathLength], DirOutput[FilePathLength];
  char FileInput[FilePathLength], FileOutput[FilePathLength], FileMask[FilePathLength];

  int lig, col;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncmplx_tools_mask.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-mf  	input mask file\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mf",str_cmd_prm,FileMask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput);
  check_dir(DirOutput);
  check_file(FileInput);
  check_file(FileOutput);
  check_file(FileMask);

  read_config(DirInput, &Nlig, &Ncol, PolarCase, PolarType);

  bufferdata = vector_float(2*Ncol);
  buffermask = vector_float(Ncol);

/*******************************************************************/
/* INPUT - OUTPUT BINARY DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInput);
  rewind(fileinput);

  if ((filemask = fopen(FileMask, "rb")) == NULL)
    edit_error("Could not open input file : ", FileMask);
  rewind(filemask);

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open input file : ", FileOutput);

/* READ INPUT DATA FILE AND CREATE DATATMP */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bufferdata[0], sizeof(float), 2*Ncol, fileinput);
    fread(&buffermask[0], sizeof(float), Ncol, filemask);
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    fread(&bufferdata[0], sizeof(float), 2*Ncol, fileinput);
    fread(&buffermask[0], sizeof(float), Ncol, filemask);

    for (col = 0; col < Sub_Ncol; col++) {
      bufferdata[2*col] = bufferdata[2*(col + Off_col)] * buffermask[col + Off_col];
      bufferdata[2*col+1] = bufferdata[2*(col + Off_col)+1] * buffermask[col + Off_col];
      }

    fwrite(&bufferdata[0], sizeof(float), 2*Sub_Ncol, fileoutput);
    }

  write_config(DirOutput, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

  fclose(fileinput);
  fclose(filemask);
  fclose(fileoutput);
  return 1;
}
