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
Version  : 1.0
Creation : 07/2003
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

Description :  Read Header of PISAR Files

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

void swap_end(unsigned char *data, int size);

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
  char PolarType[100];
  char PISARDataFormat[10];

  int ii, IEEE;
  int Nlig, Ncol, Offset;
  unsigned char fh[32];
  long rec_num, rec_len, rec_off;


/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\npisar_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-df  	PISAR data format (MGPC/MGPSSC)\n");
strcat(UsageHelp," (int)   	-iee 	IEEE data convert (no: 0, yes: 1)\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-df",str_cmd_prm,PISARDataFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iee",int_cmd_prm,&IEEE,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileOutput);

/*******************************************************************/
/* INPUT BINARY STK DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  if (IEEE == 0)
  fread(fh, 32L, 1L, fileinput);
  if (IEEE == 1) {
  for (ii = 0; ii < 32; ii++) {
    fread(&fh[ii], 1L, 1L, fileinput);
    swap_end(&fh[ii], 1L);
  }
  }

  strcpy(PolarType, "bad");
  if (strcmp(PISARDataFormat, "MGPC") == 0) {
  if ((fh[20] == 0x00) && (fh[21] == 0x02) &&
    (fh[22] == 0x02) && (fh[23] == 0x10)) {
    rec_len =
    (unsigned long) fh[16] * 256 * 256 * 256 +
    (unsigned long) fh[17] * 256 * 256 +
    (unsigned long) fh[18] * 256 + (unsigned long) fh[19];
    Ncol = (int) rec_len;
    rec_off =
    (unsigned long) fh[12] * 256 * 256 * 256 +
    (unsigned long) fh[13] * 256 * 256 +
    (unsigned long) fh[14] * 256 + (unsigned long) fh[15];
    Offset = (int) rec_off;
    rec_num =
    (unsigned long) fh[8] * 256 * 256 * 256 +
    (unsigned long) fh[9] * 256 * 256 +
    (unsigned long) fh[10] * 256 + (unsigned long) fh[11];
    Nlig = (int) rec_num;
    strcpy(PolarType, "good");
  }
  }
  if (strcmp(PISARDataFormat, "MGPSSC") == 0) {
  if ((fh[20] == 0x00) && (fh[21] == 0x00) &&
    (fh[22] == 0x02) && (fh[23] == 0x08)) {
    rec_len =
    (unsigned long) fh[16] * 256 * 256 * 256 +
    (unsigned long) fh[17] * 256 * 256 +
    (unsigned long) fh[18] * 256 + (unsigned long) fh[19];
    Ncol = (int) rec_len;
    rec_off =
    (unsigned long) fh[12] * 256 * 256 * 256 +
    (unsigned long) fh[13] * 256 * 256 +
    (unsigned long) fh[14] * 256 + (unsigned long) fh[15];
    Offset = (int) rec_off;
    rec_num =
    (unsigned long) fh[8] * 256 * 256 * 256 +
    (unsigned long) fh[9] * 256 * 256 +
    (unsigned long) fh[10] * 256 + (unsigned long) fh[11];
    Nlig = (int) rec_num;
    strcpy(PolarType, "good");
  }
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
  fprintf(fileoutput, "---------\n");
  fprintf(fileoutput, "offset\n");
  fprintf(fileoutput, "%i\n", Offset);
  fprintf(fileoutput, "---------\n");
  fprintf(fileoutput, "polartype\n");
  fprintf(fileoutput, "%s\n", PolarType);

  fclose(fileoutput);

  return 1;
}

/********************************************************************
Routine  : swap_end
Authors  : From NASDA/CRL Decompressing Procedure
Creation : 05/2002
Update  :
*--------------------------------------------------------------------
Description :  Swap Binary Data
*--------------------------------------------------------------------
Inputs arguments :
file  : string to be checked
Returned values  :
void
********************************************************************/
void swap_end(unsigned char *data, int size)
{
  unsigned char buf;
  unsigned char *head, *tail;

  int loop;

  head = data;
  tail = data + size - 1;

  for (loop = 1; loop <= (size / 2); loop++) {
  buf = *head;
  *head = *tail;
  *tail = buf;
  head++;
  tail--;
  }
}
