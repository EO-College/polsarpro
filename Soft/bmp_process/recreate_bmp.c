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

File     : recreate_bmp.c
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

Description :  Recreate a BMP file with a new colormap

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
FILE *fileinput, *fileoutput, *fcolormap;

/* GLOBAL ARRAYS */
char *buffercolor;
char *bmpimage;
char *bmpimg;

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
  char FileHeader[FilePathLength], FileData[FilePathLength], FileTmp[FilePathLength];
  char FileBmpColorMap[FilePathLength], FileBmpColorBar[FilePathLength], Tmp[20];

  int l, col, lig, Nlig, Ncol, NbreColor;
  int red[256], green[256], blue[256];
  int flagstop;

  float Max, Min;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nrecreate_bmp.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input header file\n");
strcat(UsageHelp," (string)	-ifd 	input data file\n");
strcat(UsageHelp," (string)	-oft	output tmp file\n");
strcat(UsageHelp," (string)	-ifcm	input BMP ColorMap file\n");
strcat(UsageHelp," (string)	-ofcb	output BMP ColorBar file\n");
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
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,FileTmp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifcm",str_cmd_prm,FileBmpColorMap,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofcb",str_cmd_prm,FileBmpColorBar,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileHeader);
  check_file(FileData);
  check_file(FileTmp);
  check_file(FileBmpColorMap);
  check_file(FileBmpColorBar);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  buffercolor = vector_char(2000);

/*******************************************************************/
/* INPUT FILES */
/*******************************************************************/

  if ((fileinput = fopen(FileHeader, "r")) == NULL)
    edit_error("Could not open configuration file : ", FileHeader);

  fscanf(fileinput, "%i\n", &Ncol);
  fscanf(fileinput, "%i\n", &Nlig);
  fscanf(fileinput, "%f\n", &Max);
  fscanf(fileinput, "%f\n", &Min);
  fclose(fileinput);

  if ((fcolormap = fopen(FileBmpColorMap, "r")) == NULL)
   edit_error("Could not open the bitmap file ",FileBmpColorMap);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &NbreColor);
  for (col = 0; col < NbreColor; col++)
  fscanf(fcolormap, "%i %i %i\n", &red[col], &green[col], &blue[col]);
  fclose(fcolormap);

  if ((fileinput = fopen(FileData, "rb")) == NULL)
    edit_error("Could not open configuration file : ", FileData);
  bmpimage = vector_char(Nlig * Ncol);
  fread(&bmpimage[0], sizeof(char), Nlig * Ncol, fileinput);
  fclose(fileinput);
  
/*******************************************************************/
/* OUTPUT FILES */
/*******************************************************************/

if ((fileoutput = fopen(FileTmp, "wb")) == NULL)
  edit_error("Could not open configuration file : ", FileTmp);

/* BMP HEADER */
  header(Nlig, Ncol, Max, Min, fileoutput);

/* COLORMAP */
  for (col = 0; col < 1024; col++)
    buffercolor[col] = (char) (0);

  for (col = 0; col < NbreColor; col++) {  
    
    buffercolor[4 * col] = (char) (blue[col]);
    buffercolor[4 * col + 1] = (char) (green[col]);
    buffercolor[4 * col + 2] = (char) (red[col]);
    buffercolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&buffercolor[0], sizeof(char), 1024, fileoutput);

  fwrite(&bmpimage[0], sizeof(char), Nlig * Ncol, fileoutput);

  fclose(fileoutput);
    
/********************************************************************
********************************************************************/

  if ((fileoutput = fopen(FileBmpColorBar, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileBmpColorBar);

  NbreColor = 0;
  flagstop = 0;
  col = 1;
  while (flagstop == 0) {
    col++;
    if ((red[col] == 1) && (blue[col] == 1) && (green[col] == 1)) flagstop = 1;
    if (col == 257) flagstop = 1;
    }
  NbreColor = col-1;

  Ncol = 128;
  Nlig = 20;
  bmpimg = vector_char(Nlig * Ncol);
  header(Nlig, Ncol, 0., 0., fileoutput);
  fwrite(&buffercolor[0], sizeof(char), 1024, fileoutput);
  
  for (lig = 0; lig < Nlig; lig++) {
    for (col = 0; col < Ncol; col++) {
    l = 1 + (int) (NbreColor * col / (Ncol-1));
    if (l >= (1+NbreColor)) l = 1+NbreColor;
    if (l < 0) l = 0;
    bmpimg[(Nlig - 1 - lig) * Ncol + col] = (char) (l);
    }
    }
  fwrite(&bmpimg[0], sizeof(char), Nlig * Ncol, fileoutput);
  fclose(fileoutput);

/********************************************************************
********************************************************************/

  return 1;
}
