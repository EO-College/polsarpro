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

File     : bmp_processing.c
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

Description :  Recreate a BMP file after processing: 
               rotation +/-90 and flip

Input  : BMPheader, BMPcolormap, BMPdata files
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
  FILE *fileinput, *fileoutput, *fcolormap;

  char FileHeader[FilePathLength], FileData[FilePathLength], FileOutput[FilePathLength], FileColorMap[FilePathLength];
  char Tmp[FilePathLength], operation[10];

  int lig, col, k;
  float Max, Min;
  int Ncolor, red[256], green[256], blue[256];
  int NligInit, NcolInit;

  char *bmpimage;
  char **bmpfinal;
  char *bufcolor;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nbmp_processing.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input header file\n");
strcat(UsageHelp," (string)	-ifd 	input data file\n");
strcat(UsageHelp," (string)	-ifc 	input colormap file\n");
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

if(argc < 11) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,FileHeader,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,FileData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifc",str_cmd_prm,FileColorMap,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-op",str_cmd_prm,operation,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileHeader);
  check_file(FileData);
  check_file(FileColorMap);
  check_file(FileOutput);

  if ((fileinput = fopen(FileHeader, "r")) == NULL)
  edit_error("Could not open configuration file : ", FileHeader);

  fscanf(fileinput, "%i\n", &NcolInit);
  fscanf(fileinput, "%i\n", &NligInit);
  fscanf(fileinput, "%f\n", &Max);
  fscanf(fileinput, "%f\n", &Min);
  fclose(fileinput);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  Ncol = NcolInit;
  Nlig = NligInit;
  if ((strcmp(operation, "rot90") == 0) || (strcmp(operation, "rot270") == 0)) {
    Ncol = NligInit;
    Nlig = NcolInit;
    }

  ExtraColBMP = (int) fmod(4 - (int) fmod(Ncol, 4), 4);
  NcolBMP = Ncol + ExtraColBMP;

  bmpimage = vector_char(NcolInit);
  bmpfinal = matrix_char(Nlig,NcolBMP);
  bufcolor = vector_char(1024);

/*******************************************************************/
/* INPUT FILES */
/*******************************************************************/

  if ((fileinput = fopen(FileData, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileData);

/*******************************************************************/
/* OUTPUT FILES */
/*******************************************************************/

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/* BMP HEADER */
  header(Nlig, Ncol, Max, Min, fileoutput);

/* COLOR MAP */
  if ((fcolormap = fopen(FileColorMap, "r")) == NULL)
    edit_error("Could not open the bitmap file ",FileColorMap);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
    fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  fclose(fcolormap);

  for (col = 0; col < 1024; col++)
    bufcolor[col] = (char) (0);

  for (col = 0; col < Ncolor; col++) {  
    
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fileoutput);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (lig = 0; lig < NligInit; lig++) {
  if (lig%(int)(NligInit/20) == 0) {printf("%f\r", 100. * lig / (NligInit - 1));fflush(stdout);}
  fread(&bmpimage[0], sizeof(char), NcolInit, fileinput);
  
  for (col = 0; col < NcolInit; col++) {
    if (strcmp(operation, "rot270") == 0)
      bmpfinal[col][NligInit-1-lig] = bmpimage[col];
    if (strcmp(operation, "rot90") == 0)
      bmpfinal[NcolInit-1-col][lig] = bmpimage[col];
    if (strcmp(operation, "fliplr") == 0)
      bmpfinal[lig][NcolInit-1-col] = bmpimage[col];
    if (strcmp(operation, "flipud") == 0)
      bmpfinal[NligInit-1-lig][col] = bmpimage[col];
    } /* col */
  } /* lig */
    
for (lig = 0; lig < Nlig; lig++) {
  if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
  for (col = 0; col < ExtraColBMP; col++) {
    bmpfinal[lig][Ncol + col] = (char) (0);
    }
  fwrite(&bmpfinal[lig][0], sizeof(char), NcolBMP, fileoutput);  
  } /* lig */

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(bmpimage);
  free_matrix_char(bmpfinal,Nlig);
  free_vector_char(bufcolor);
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
