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

File     : rgb24_to_bmp8.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2013
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

Description :  Convert a 24-bits RGB image to a 8-bits BMP Image
 
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

/* GLOBAL ARRAYS */
char *bmpimg24;
float **bmpbin;
char *bufcolor;

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
  FILE *fileinput, *fileoutput;
  
  char FileInput[FilePathLength];
  char FileData[FilePathLength];
  char FileBmpColorMap[FilePathLength];

  int k, n, lig, col, Nlig, Ncol, ExtraCol;
//int Nbit;  
  int r, g, b, red[256], green[256], blue[256];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nrgb24_to_bmp8.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input 24bit RGB file\n");
strcat(UsageHelp," (string)	-ofb 	output binary data file\n");
strcat(UsageHelp," (string)	-ofc 	output BMP ColorMap file\n");
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
  get_commandline_prm(argc,argv,"-ofb",str_cmd_prm,FileData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",str_cmd_prm,FileBmpColorMap,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileData);
  check_file(FileBmpColorMap);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* OUTPUT COLORMAP BMP FILE */
/*******************************************************************/

  for (r = 0; r < 6; r++) {
    for (g = 0; g < 6; g++) {
      for (b = 0; b < 6; b++) {
        n = 36*r + 6*g + b;
        red[n] = 51 * r;
        green[n] = 51 * g;
        blue[n] = 51 * b;
        }  
      }  
    }  
  for (n = 216; n < 256; n++) {
    red[n] = 125; green[n] = 125; blue[n] = 125;
    }

  if ((fileoutput = fopen(FileBmpColorMap, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileBmpColorMap);
  /* Colormap Definition  */
  fprintf(fileoutput, "JASC-PAL\n");
  fprintf(fileoutput, "0100\n");
  fprintf(fileoutput, "256\n");
  for (k = 0; k < 256; k++) fprintf(fileoutput, "%i %i %i\n", red[k], green[k], blue[k]);
  fclose(fileoutput);

/*******************************************************************/
/* INPUT FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInput);

  /* Reading BMP file header */
  rewind(fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  Ncol = k;
  fread(&k, sizeof(int), 1, fileinput);
  Nlig = k;
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
//  Nbit = k;
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);

  ExtraCol = (int) fmod(4 - (int) fmod(3*Ncol, 4), 4);

  bmpimg24 = vector_char(3 * Ncol + ExtraCol);
  bmpbin = matrix_float(Nlig,Ncol);

/********************************************************************
********************************************************************/

  for (lig = 0; lig < Nlig; lig++) {
    fread(&bmpimg24[0], sizeof(char), 3 * Ncol + ExtraCol, fileinput);
    for (col = 0; col < Ncol; col++) {
      n = bmpimg24[3*col]; if (n < 0) n = n + 256; b = floor(6*n/256);
      n = bmpimg24[3*col+1]; if (n < 0) n = n + 256; g = floor(6*n/256);
      n = bmpimg24[3*col+2]; if (n < 0) n = n + 256; r = floor(6*n/256);
      bmpbin[Nlig-1-lig][col] = 36.*r + 6.*g + 1.*b;
      }
    }

  fclose(fileinput);

/*******************************************************************/
/* OUTPUT BINARY DATA FILE */
/*******************************************************************/
  
  if ((fileoutput = fopen(FileData, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileData);

  for (lig = 0; lig < Nlig; lig++) {
    fwrite(&bmpbin[lig][0], sizeof(float), Ncol, fileoutput);
    }

  fclose(fileoutput);

/********************************************************************
********************************************************************/

  return 1;
}
