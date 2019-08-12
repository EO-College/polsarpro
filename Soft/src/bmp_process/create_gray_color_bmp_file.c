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

File   : create_gray_color_bmp_file.c
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

Description :  Create a 8-bits BMP file from a 8-bits Gray BMP file
               and a 8-bits Color BMP file

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
  FILE *fileinputdatagray, *fileinputdatacolor, *fileinputmask; 
  FILE *fileinput, *fileoutput, *fcolormap;

  char FileHeaderGray[FilePathLength], FileDataGray[FilePathLength], FileBmpColorMapGray[FilePathLength];
  char FileHeaderColor[FilePathLength], FileDataColor[FilePathLength], FileBmpColorMapColor[FilePathLength];
  char FileOutput[FilePathLength], FileMask[FilePathLength], FileBmpColorMapGrayColor[FilePathLength];
  char Tmp[20];

  int l, col, lig, InvMask;
  int NbreColor, NColorGray, NColorColor;
  int red[256], green[256], blue[256];
  int red_gray[256], green_gray[256], blue_gray[256];
  int red_color[256], green_color[256], blue_color[256];

  float Max, Min;

  char *bmpimage, *bmpimagegray;
  char *bufcolor, *bmpimagecolor;
  float *maskfile;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_gray_color_bmp_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-of  	bmp output file\n");
strcat(UsageHelp," (string)	-msk 	mask file\n");
strcat(UsageHelp," (int)   	-imsk	inverse mask (0/1)\n");
strcat(UsageHelp," (int)   	-nl  	Number of Lig\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (string)	-ifhg	input file: header gray\n");
strcat(UsageHelp," (string)	-ifhc	input file: header color\n");
strcat(UsageHelp," (string)	-ifdg	input file: data gray\n");
strcat(UsageHelp," (string)	-ifdc	input file: data color\n");
strcat(UsageHelp," (string)	-ifcg	input file: colormap gray\n");
strcat(UsageHelp," (string)	-ifcc	input file: colormap color\n");
strcat(UsageHelp," (string)	-ofcg	output file: colormap gray-color\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-msk",str_cmd_prm,FileMask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-imsk",int_cmd_prm,&InvMask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nl",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifhg",str_cmd_prm,FileHeaderGray,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifhc",str_cmd_prm,FileHeaderColor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifdg",str_cmd_prm,FileDataGray,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifdc",str_cmd_prm,FileDataColor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifcg",str_cmd_prm,FileBmpColorMapGray,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifcc",str_cmd_prm,FileBmpColorMapColor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofcg",str_cmd_prm,FileBmpColorMapGrayColor,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileOutput);
  check_file(FileMask);
  check_file(FileHeaderGray);
  check_file(FileHeaderGray);
  check_file(FileDataGray);
  check_file(FileDataColor);
  check_file(FileBmpColorMapGray);
  check_file(FileBmpColorMapColor);
  check_file(FileBmpColorMapGrayColor);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/

  if ((fileinput = fopen(FileHeaderGray, "r")) == NULL)
  edit_error("Could not open configuration file : ", FileHeaderGray);
  fscanf(fileinput, "%i\n", &Ncol);
  fscanf(fileinput, "%i\n", &Nlig);
  fscanf(fileinput, "%f\n", &Max);
  fscanf(fileinput, "%f\n", &Min);
  fscanf(fileinput, "%i\n", &NColorGray);
  fclose(fileinput);

  if ((fileinput = fopen(FileHeaderColor, "r")) == NULL)
  edit_error("Could not open configuration file : ", FileHeaderColor);
  fscanf(fileinput, "%i\n", &Ncol);
  fscanf(fileinput, "%i\n", &Nlig);
  fscanf(fileinput, "%f\n", &Max);
  fscanf(fileinput, "%f\n", &Min);
  fscanf(fileinput, "%i\n", &NColorColor);
  fclose(fileinput);

/*******************************************************************/

  if ((fileinputdatagray = fopen(FileDataGray, "rb")) == NULL)
    edit_error("Could not open configuration file : ", FileDataGray);
  bmpimagegray = vector_char(Ncol);

  if ((fileinputdatacolor = fopen(FileDataColor, "rb")) == NULL)
    edit_error("Could not open configuration file : ", FileDataColor);
  bmpimagecolor = vector_char(Ncol);

  if ((fileinputmask = fopen(FileMask, "rb")) == NULL)
    edit_error("Could not open configuration file : ", FileMask);
  maskfile = vector_float(Ncol);

/*******************************************************************/

  if ((fcolormap = fopen(FileBmpColorMapGray, "r")) == NULL)
  edit_error("Could not open the bitmap file ",FileBmpColorMapGray);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &NbreColor);
  for (col = 0; col < NbreColor; col++)
  fscanf(fcolormap, "%i %i %i\n", &red_gray[col], &green_gray[col], &blue_gray[col]);
  fclose(fcolormap);

  if ((fcolormap = fopen(FileBmpColorMapColor, "r")) == NULL)
  edit_error("Could not open the bitmap file ",FileBmpColorMapColor);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &NbreColor);
  for (col = 0; col < NbreColor; col++)
  fscanf(fcolormap, "%i %i %i\n", &red_color[col], &green_color[col], &blue_color[col]);
  fclose(fcolormap);

  bufcolor = vector_char(1024);
  if (NColorColor == 256) {
    for (col = 0; col < 128; col++) {
    red[col] = red_color[2*col]; red[col+128] = red_gray[2*col];
    green[col] = green_color[2*col]; green[col+128] = green_gray[2*col];
    blue[col] = blue_color[2*col]; blue[col+128] = blue_gray[2*col];
    }
  } else {
    for (col = 0; col <= NColorColor; col++) {
    red[col] = red_color[col];
    green[col] = green_color[col];
    blue[col] = blue_color[col];
    }
    for (col = NColorColor+1; col < 256; col++) {
    red[col] = red_gray[col];
    green[col] = green_gray[col];
    blue[col] = blue_gray[col];
    }
  }

  if ((fileoutput = fopen(FileBmpColorMapGrayColor, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileBmpColorMapGrayColor);
    fprintf(fileoutput, "JASC-PAL\n");
    fprintf(fileoutput, "0100\n");
    fprintf(fileoutput, "256\n");
    for (col = 0; col < 256; col++) fprintf(fileoutput, "%i %i %i\n", red[col], green[col], blue[col]);
    fclose(fileoutput);

/*******************************************************************/
/* OUTPUT BMP FILE CREATION */
/*******************************************************************/

/* BMP HDR FILE */
  write_bmp_hdr(Nlig, Ncol, 1., 0., 8, FileOutput);

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", FileOutput);

/* BMP HEADER */
  header(Nlig, Ncol, 1., 0., fileoutput);

/* COLORMAP */
  for (col = 0; col < 1024; col++)
    bufcolor[col] = (char) (0);

  for (col = 0; col < 256; col++) {  
    
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fileoutput);

/*******************************************************************/
  ExtraColBMP = (int) fmod(4 - (int) fmod(Ncol, 4), 4);
  NcolBMP = Ncol + ExtraColBMP;
  bmpimage = vector_char(NcolBMP);

  fseek(fileinputmask, 0L, SEEK_END);

  for (lig = 0; lig < Nlig; lig++) {
    my_fseek(fileinputmask, -1, Ncol, sizeof(float));
    fread(&maskfile[0], sizeof(float), Ncol, fileinputmask);
    my_fseek(fileinputmask, -1, Ncol, sizeof(float));

    fread(&bmpimagegray[0], sizeof(char), Ncol, fileinputdatagray);
    fread(&bmpimagecolor[0], sizeof(char), Ncol, fileinputdatacolor);


    if (NColorColor == 256) {
      for (col = 0; col < Ncol; col++) {
        if (((maskfile[col] == 1.)&&(InvMask ==0)) || ((maskfile[col] == 0.)&&(InvMask ==1))) {
          l = (int)bmpimagecolor[col]; if (l<0) l = l+256; l = floor(l/2);bmpimage[col]=(char)(l);
          } else {
          l = (int)bmpimagegray[col]; if (l<0) l = l+256; l = 128 + floor(l/2);bmpimage[col]=(char)(l);
          }
        }
      } else {
      for (col = 0; col < Ncol; col++) {
        if (((maskfile[col] == 1.)&&(InvMask ==0)) || ((maskfile[col] == 0.)&&(InvMask ==1))) {
          bmpimage[col] = bmpimagecolor[col];
          } else {
          l = (int)bmpimagegray[col];if (l<0) l = l+256; if (l <= NColorColor + 1) l = NColorColor + 1; 
          bmpimage[col]=(char)(l);
          }
        }
      }
    for (col = 0; col < ExtraColBMP; col++) {
      IntCharBMP = 0;
      bmpimage[Ncol + col] = (char) IntCharBMP;
      }      
    fwrite(&bmpimage[0], sizeof(char), NcolBMP, fileoutput);
    }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_char(bmpimage);
  free_vector_char(bmpimagegray);
  free_vector_char(bmpimagecolor);
  free_vector_char(bufcolor);
  free_vector_float(maskfile);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(fileoutput);

/* INPUT FILE CLOSING*/
  fclose(fileinputdatagray);
  fclose(fileinputdatacolor);
  fclose(fileinputmask);

/********************************************************************
********************************************************************/
  return 1;
}
