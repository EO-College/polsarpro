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

File     : bmp24_processing.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
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

Description :  Recreate a 24-BMP file after processing: 
               rotation +/-90 and flip

Input  : BMPheader, BMPdata files
Output : BMPtmp.bmp file

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
FILE *fileinput, *fileoutput;

/* GLOBAL ARRAYS */
char *bmpimage;
char *bmpfinal;

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
  char FileHeader[FilePathLength], FileData[FilePathLength], FileOutput[FilePathLength];
  char operation[10];

  int Nlig, Ncol, lig, col, l;
  int NligInit, NcolInit;
  int extracol;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nbmp24_processing.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input header file\n");
strcat(UsageHelp," (string)	-ifd 	input data file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-op  	operation (rot90 rot270 flipud fliplr)\n");
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
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,FileHeader,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,FileData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-op",str_cmd_prm,operation,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileHeader);
  check_file(FileData);
  check_file(FileOutput);
  
  if ((fileinput = fopen(FileHeader, "r")) == NULL)
  edit_error("Could not open configuration file : ", FileHeader);

  fscanf(fileinput, "%i\n", &NcolInit);
  fscanf(fileinput, "%i\n", &NligInit);
  fclose(fileinput);

  Ncol = NcolInit;
  Nlig = NligInit;
  if ((strcmp(operation, "rot90") == 0) || (strcmp(operation, "rot270") == 0)) {
    Ncol = NligInit;
    Nlig = NcolInit;
    }

  extracol = (int) fmod(4 - (int) fmod(3*Ncol, 4), 4);
  NcolBMP = 3*Ncol + extracol;

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bmpimage = vector_char(3 * NligInit * NcolInit);
  bmpfinal = vector_char(Nlig * NcolBMP);

/*******************************************************************/
/* INPUT FILES */
/*******************************************************************/

  if ((fileinput = fopen(FileData, "rb")) == NULL)
    edit_error("Could not open configuration file : ", FileData);
  fread(&bmpimage[0], sizeof(char), 3 * NligInit * NcolInit, fileinput);
  fclose(fileinput);
  
/*******************************************************************/
/* OUTPUT FILES */
/*******************************************************************/

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/* BMP HEADER */
  write_header_bmp_24bit(Nlig, Ncol, fileoutput);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (lig = 0; lig < Nlig; lig++) {
  if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
  
  if (strcmp(operation, "rot270") == 0)
    for (col = 0; col < Ncol; col++) {
      bmpfinal[lig * NcolBMP + 3*col + 0] = bmpimage[3*((NligInit - 1 - col) * NcolInit + lig) + 0];
      bmpfinal[lig * NcolBMP + 3*col + 1] = bmpimage[3*((NligInit - 1 - col) * NcolInit + lig) + 1];
      bmpfinal[lig * NcolBMP + 3*col + 2] = bmpimage[3*((NligInit - 1 - col) * NcolInit + lig) + 2];
      }
  if (strcmp(operation, "rot90") == 0)
    for (col = 0; col < Ncol; col++) {
      bmpfinal[lig * NcolBMP + 3*col + 0] = bmpimage[3*(col * NcolInit + (NcolInit - 1 - lig)) + 0];
      bmpfinal[lig * NcolBMP + 3*col + 1] = bmpimage[3*(col * NcolInit + (NcolInit - 1 - lig)) + 1];
      bmpfinal[lig * NcolBMP + 3*col + 2] = bmpimage[3*(col * NcolInit + (NcolInit - 1 - lig)) + 2];
      }
  if (strcmp(operation, "fliplr") == 0)
    for (col = 0; col < Ncol; col++) {
      bmpfinal[lig * NcolBMP + 3*col + 0] = bmpimage[3*(lig * NcolInit + (NcolInit - 1 - col)) + 0];
      bmpfinal[lig * NcolBMP + 3*col + 1] = bmpimage[3*(lig * NcolInit + (NcolInit - 1 - col)) + 1];
      bmpfinal[lig * NcolBMP + 3*col + 2] = bmpimage[3*(lig * NcolInit + (NcolInit - 1 - col)) + 2];
      }
  if (strcmp(operation, "flipud") == 0)
    for (col = 0; col < Ncol; col++) {
      bmpfinal[lig * NcolBMP + 3*col + 0] = bmpimage[3*((NligInit - 1 - lig) * NcolInit + col) + 0];
      bmpfinal[lig * NcolBMP + 3*col + 1] = bmpimage[3*((NligInit - 1 - lig) * NcolInit + col) + 1];
      bmpfinal[lig * NcolBMP + 3*col + 2] = bmpimage[3*((NligInit - 1 - lig) * NcolInit + col) + 2];
      }
  for (col = 0; col < extracol; col++) {
    l = (int) (floor(255 * 0.));
    bmpfinal[lig * NcolBMP + 3*Ncol + col] = (char) (l);
    } /*col*/
  } /* lig */
    
  fwrite(&bmpfinal[0], sizeof(char), Nlig*NcolBMP, fileoutput);  

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(bmpimage);
  free_matrix_char(bmpfinal,Nlig);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/* INPUT FILE CLOSING*/
  fclose(fileinput);

/********************************************************************
********************************************************************/

  return 1;
}
