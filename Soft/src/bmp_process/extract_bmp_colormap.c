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

File     : extract_bmp_colormap.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
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

Description :  Extract the image characteristics and the colormap if
               the image is a 8-bits BMP Image
 
Write the different files in the directory TMP

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
char *buffercolor;
char *bmpimage;
char *bmpimg;
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
  FILE *fileinput, *fileoutput;

  char FileInput[FilePathLength], FileHeader[FilePathLength], FileData[FilePathLength], File24Data[FilePathLength];
  char FileBmpColorMap[FilePathLength], FileBmpColorBar[FilePathLength], FileColorMapBmp[FilePathLength];
  char FileInputHdr[FilePathLength];
  
  int k, l, lig, col, Nbit, Nlig, Ncol, NbreColor, ExtraCol;
  int red[256], green[256], blue[256];
  int flagstop;

  float Max, Min;
  //unsigned int coeff, NMax, NMin;

  char Buf[65536];
  char Tmp[65536];
  char *p1;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nextract_bmp_colormap.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input BMP file\n");
strcat(UsageHelp," (string)	-ofh 	output header file\n");
strcat(UsageHelp," (string)	-ofd 	output data file\n");
strcat(UsageHelp," (string)	-ofd24	output data 24bits file\n");
strcat(UsageHelp," (string)	-ofcm	output BMP ColorMap file\n");
strcat(UsageHelp," (string)	-ofcb	output BMP ColorBar file\n");
strcat(UsageHelp," (string)	-ocf 	output ColorMap file\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofh",str_cmd_prm,FileHeader,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofd",str_cmd_prm,FileData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofd24",str_cmd_prm,File24Data,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofcm",str_cmd_prm,FileBmpColorMap,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofcb",str_cmd_prm,FileBmpColorBar,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,FileColorMapBmp,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileHeader);
  check_file(FileData);
  check_file(File24Data);
  check_file(FileBmpColorMap);
  check_file(FileBmpColorBar);
  check_file(FileColorMapBmp);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  buffercolor = vector_char(2000);

/*******************************************************************/
/* INPUT HEADER FILE */
/*******************************************************************/

  sprintf(FileInputHdr, "%s.hdr", FileInput);
  if ((fileinput = fopen(FileInputHdr, "r")) == NULL)
    edit_error("Could not open input file : ", FileInputHdr);

  rewind(fileinput);
  while( !feof(fileinput) ) {
    fgets(&Buf[0], 1024, fileinput); 
    if (strstr(Buf,"samples") != NULL) {
      p1 = strstr(Buf," = ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      Ncol = atoi(Tmp);
      }
    if (strstr(Buf,"lines") != NULL) {
      p1 = strstr(Buf," = ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      Nlig = atoi(Tmp);
      }
    if (strstr(Buf,"max val") != NULL) {
      p1 = strstr(Buf," = ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3); 
      Max = atof(Tmp);
      }
    if (strstr(Buf,"min val") != NULL) {
      p1 = strstr(Buf," = ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3); 
      Min = atof(Tmp);
      }
    if (strstr(Buf,"color") != NULL) {
      if (strstr(Buf,"8") != NULL) Nbit = 8; 
      if (strstr(Buf,"24") != NULL) Nbit = 24; 
      }
    }

fclose(fileinput);

/*******************************************************************/
/* OUTPUT HEADER FILE */
/*******************************************************************/

if ((fileoutput = fopen(FileHeader, "w")) == NULL)
  edit_error("Could not open configuration file : ", FileHeader);

  fprintf(fileoutput, "%i\n", Ncol);
  fprintf(fileoutput, "%i\n", Nlig);
  fprintf(fileoutput, "%f\n", Max);
  fprintf(fileoutput, "%f\n", Min);

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
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(short int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);
  fread(&k, sizeof(int), 1, fileinput);
  fread(&k, sizeof(unsigned int), 1, fileinput);

  if (Nbit == 8) {
    fread(&buffercolor[0], sizeof(char), 1024, fileinput);
    for (col = 0; col < 256; col++) {
      red[col] = buffercolor[4 * col + 2];
      if (red[col] < 0) red[col] = red[col] + 256;
      green[col] = buffercolor[4 * col + 1];
      if (green[col] < 0) green[col] = green[col] + 256;
      blue[col] = buffercolor[4 * col];
      if (blue[col] < 0) blue[col] = blue[col] + 256;
      }
    NbreColor = 0;
    if (((red[0] == 0) && (blue[0] == 1) && (green[0] == 0)) 
     || ((red[0] == 124) && (blue[0] == 125) && (green[0] == 124))
     || ((red[0] == 124) && (blue[0] == 125) && (green[0] == 124))) {
      flagstop = 0;
      col = 0;
      while (flagstop == 0) {
        col++;
        if ((red[col] == 1) && (blue[col] == 0) && (green[col] == 1)) flagstop = 1;
        if (col == 257) flagstop = 1;
        }
      NbreColor = col-1;
      } else {
      NbreColor = 256;
      }
    fprintf(fileoutput, "%i\n", NbreColor);
    ExtraCol = (int) fmod(4 - (int) fmod(Ncol, 4), 4);
    }

  if (Nbit == 24) {
    fprintf(fileoutput, "BMP 24 Bits\n");
    ExtraCol = (int) fmod(4 - (int) fmod(3*Ncol, 4), 4);
    }

  fprintf(fileoutput, "%i\n", ExtraCol);
  fclose(fileoutput);

/*******************************************************************/
/* OUTPUT COLORMAP BMP AND DATA FILES */
/*******************************************************************/
if (Nbit == 8) {
  if ((fileoutput = fopen(FileColorMapBmp, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileColorMapBmp);

  /* Colormap Definition  */
  fprintf(fileoutput, "JASC-PAL\n");
  fprintf(fileoutput, "0100\n");
  fprintf(fileoutput, "256\n");
  for (k = 0; k < 256; k++) fprintf(fileoutput, "%i %i %i\n", red[k], green[k], blue[k]);

  fclose(fileoutput);

  if ((fileoutput = fopen(FileBmpColorMap, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileBmpColorMap);

  /* Colormap Definition  */
  fprintf(fileoutput, "JASC-PAL\n");
  fprintf(fileoutput, "0100\n");
  fprintf(fileoutput, "256\n");
  for (k = 0; k < 256; k++) fprintf(fileoutput, "%i %i %i\n", red[k], green[k], blue[k]);

  fclose(fileoutput);

  if ((fileoutput = fopen(FileData, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileData);

  bmpimage = vector_char(Nlig * (Ncol + ExtraCol));
  bmpfinal = vector_char(Nlig * Ncol);
  fread(&bmpimage[0], sizeof(char), Nlig * (Ncol + ExtraCol), fileinput);

  for (lig = 0; lig < Nlig; lig++)
    for (col = 0; col < Ncol; col++)
      bmpfinal[lig * Ncol + col] = bmpimage[lig * (Ncol + ExtraCol) + col];

  fwrite(&bmpfinal[0], sizeof(char), Nlig * Ncol, fileoutput);
  fclose(fileoutput);

  /* BMP ColorBar Definition */
  if ((fileoutput = fopen(FileBmpColorBar, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileBmpColorBar);

  Ncol = 128;
  Nlig = 20;
  bmpimg = vector_char(Nlig * Ncol);
  header(Nlig, Ncol, 0., 0., fileoutput);
  write_bmp_hdr(Nlig, Ncol, 0., 0., 8, FileBmpColorBar);
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
  }

if (Nbit == 24) {
  if ((fileoutput = fopen(File24Data, "wb")) == NULL)
    edit_error("Could not open configuration file : ", File24Data);

  bmpimage = vector_char(Nlig * (3*Ncol + ExtraCol));
  bmpfinal = vector_char(3 * Nlig * Ncol);
  fread(&bmpimage[0], sizeof(char), Nlig * (3*Ncol + ExtraCol), fileinput);

  for (lig = 0; lig < Nlig; lig++)
    for (col = 0; col < Ncol; col++) {
      bmpfinal[3 * lig * Ncol + 3*col] = bmpimage[lig * (3*Ncol + ExtraCol) + 3*col];
      bmpfinal[3 * lig * Ncol + 3*col+1] = bmpimage[lig * (3*Ncol + ExtraCol) + 3*col+1];
      bmpfinal[3 * lig * Ncol + 3*col+2] = bmpimage[lig * (3*Ncol + ExtraCol) + 3*col+2];
      }
  
  fwrite(&bmpfinal[0], sizeof(char), 3 * Nlig * Ncol, fileoutput);
  fclose(fileoutput);
  }

/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  fclose(fileinput);

/********************************************************************
********************************************************************/

  return 1;
}
