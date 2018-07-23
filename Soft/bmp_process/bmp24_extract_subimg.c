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

File     : bmp24_extract_subimg.c
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

Description :  Extract a sub-image from a 24-BMP image file

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

  int lig, col, l;
  int extracol;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nbmp24_extract_subimg.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input header file\n");
strcat(UsageHelp," (string)	-ifd 	input data file\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,FileHeader,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,FileData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileHeader);
  check_file(FileData);
  check_file(FileOutput);
  
  extracol = (int) fmod(4 - (int) fmod(3*Sub_Ncol, 4), 4);
  NcolBMP = 3*Sub_Ncol + extracol;

  if ((fileinput = fopen(FileHeader, "r")) == NULL)
  edit_error("Could not open configuration file : ", FileHeader);

  fscanf(fileinput, "%i\n", &Ncol);
  fscanf(fileinput, "%i\n", &Nlig);
  fclose(fileinput);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  bmpimage = vector_char(3 * Ncol);
  bmpfinal = vector_char(Sub_Nlig * NcolBMP);

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
  write_header_bmp_24bit(Sub_Nlig, Sub_Ncol, fileoutput);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    fread(&bmpimage[0], sizeof(char), 3 * Ncol, fileinput);
    }

for (lig = 0; lig < Sub_Nlig; lig++) {
  if (lig%(int)(Sub_Nlig/20) == 0) {printf("%f\r", 100. * lig / (Sub_Nlig - 1));fflush(stdout);}
  fread(&bmpimage[0], sizeof(char), 3 * Ncol, fileinput);
  for (col = 0; col < Sub_Ncol; col++) {
    bmpfinal[lig * NcolBMP + 3*col + 0] = bmpimage[3*(col + Off_col) + 0];
    bmpfinal[lig * NcolBMP + 3*col + 1] = bmpimage[3*(col + Off_col) + 1];
    bmpfinal[lig * NcolBMP + 3*col + 2] = bmpimage[3*(col + Off_col) + 2];
    } /* col */
  for (col = 0; col < extracol; col++) {
    l = (int) (floor(255 * 0.));
    bmpfinal[lig * NcolBMP + 3*Sub_Ncol + col] = (char) (l);
    } /*col*/
  } /* lig */
fwrite(&bmpfinal[0], sizeof(char), Sub_Nlig * NcolBMP, fileoutput);  

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(bmpimage);
  free_vector_char(bmpfinal);
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
