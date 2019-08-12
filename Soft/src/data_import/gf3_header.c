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

File   : gef3_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2017
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

Description :  Read Header of GF3 GEOTIFF Files

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

char *my_strrev(char *buf);

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

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset;
  short int Ndir, Flag, Type;
  int Count, Value;
  int Nlig, Ncol, IEEEFormat;

  char *pc;
  int il;
  int *v;
  short int is;
  short int *vv;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ngf3_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 5) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
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
/* INPUT BINARY DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  Ncol = 0;
  Nlig = 0;
  rewind(fileinput);
/*Tiff File Header*/
  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEEFormat = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEEFormat = 1;
  
  if (IEEEFormat == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEEFormat == 1) {
      v = &il;pc = (char *) v;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
  }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
  edit_error("Could not open configuration file : ", FileOutput);

  if (IEEEFormat == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEEFormat == 1) {
    vv = &is;pc = (char *) vv;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
  }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEEFormat == 0) {
      fread(&Flag, sizeof(short int), 1, fileinput);
      fread(&Type, sizeof(short int), 1, fileinput);
      fread(&Count, sizeof(int), 1, fileinput);
      if (Type == 3) {
        fread(&Value, sizeof(short int), 1, fileinput);
        fread(&k, sizeof(short int), 1, fileinput);
      }
      if (Type == 4) fread(&Value, sizeof(int), 1, fileinput);
      if ((Type != 3) && (Type != 4)) fread(&Value, sizeof(int), 1, fileinput);
    }
    if (IEEEFormat == 1) {
      vv = &is;pc = (char *) vv;
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Flag = is;
      vv = &is;pc = (char *) vv;
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Type = is;
      v = &il;pc = (char *) v;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Count = il;
      if (Type == 3) {
        vv = &is;pc = (char *) vv;
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        Value = is;
        fread(&k, sizeof(short int), 1, fileinput);
      }
      if (Type == 4) {
        v = &il;pc = (char *) v;
        pc[3] = getc(fileinput);pc[2] = getc(fileinput);
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        Value = il;
      }
      if ((Type != 3) && (Type != 4)) fread(&Value, sizeof(int), 1, fileinput);
    }

    if (Flag == 256) Ncol = Value;
    if (Flag == 257) Nlig = Value;
    }

  fprintf(fileoutput, "nlig\n");
  fprintf(fileoutput, "%i\n", Nlig);
  fprintf(fileoutput, "---------\n");
  fprintf(fileoutput, "ncol\n");
  fprintf(fileoutput, "%i\n", Ncol);
  fprintf(fileoutput, "---------\n");
  fprintf(fileoutput, "IEEE\n");
  fprintf(fileoutput, "%i\n", IEEEFormat);
  fprintf(fileoutput, "---------\n");
  fprintf(fileoutput, "Offset\n");
  fprintf(fileoutput, "%li\n", offset);

  fclose(fileinput);
  fclose(fileoutput);

  return 1;
}



