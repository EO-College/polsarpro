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

File     : bmp_display.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Sub-sampling of a BMP file to be displayed

Input  : BMPheader, BMPcolormap, BMPdata files
Output : BMPdisptmp.bmp file

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

  char FileHeader[FilePathLength], FileData[FilePathLength];
  char FileOutput[FilePathLength], FileColorMap[FilePathLength];
  char Tmp[FilePathLength];

  int lig, col, k, l, ligg, coll;
  float Max, Min;
  int Ncolor, red[256], green[256], blue[256];
  int NligInit, NcolInit;
  int NligFin, NcolFin;
  int SubSamp;
  int Val;

  char **bmpimage;
  char **bmpfinal;
  char *bufcolor;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nbmp_display.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifh 	input header file\n");
strcat(UsageHelp," (string)	-ifd 	input data file\n");
strcat(UsageHelp," (string)	-ifc 	input colormap file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (string)	-ss  	sub-sampling value\n");
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
  get_commandline_prm(argc,argv,"-ss",int_cmd_prm,&SubSamp,1,UsageHelp);
  }

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);
  
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

  NcolFin = (int) floor(NcolInit / SubSamp);
  NligFin = (int) floor(NligInit / SubSamp);

  ExtraColBMP = (int) fmod(4 - (int) fmod(NcolFin, 4), 4);
  NcolBMP = NcolFin + ExtraColBMP;

  bmpimage = matrix_char(NligInit,NcolInit);
  bmpfinal = matrix_char(NligFin,NcolBMP);
  bufcolor = vector_char(1024);

/*******************************************************************/
/* INPUT FILES */
/*******************************************************************/

  if ((fileinput = fopen(FileData, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileData);

/*******************************************************************/
/* OUTPUT FILES */
/*******************************************************************/

  /* BMP HDR FILE */
  write_bmp_hdr(NligFin, NcolFin, Max, Min, 8, FileOutput);

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/* BMP HEADER */
  header(NligFin, NcolFin, Max, Min, fileoutput);

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
ligg = 0;
for (lig = 0; lig < NligInit; lig++) {
  fread(&bmpimage[lig][0], sizeof(char), NcolInit, fileinput);
  } /* lig */
#pragma omp parallel for private(col, ligg, coll, Val, k, l)
for (lig = 0; lig < NligFin; lig++) {
  if (omp_get_thread_num() == 0) if (lig%(int)(NligFin/20) == 0) {printf("%f\r", 100. * lig / (NligFin - 1));fflush(stdout);}
  ligg = lig * SubSamp;
  for (col = 0; col < NcolFin; col++) {
    coll = col * SubSamp;
    Val = 0;
    for (k = 0; k < SubSamp; k++)
        for (l = 0; l < SubSamp; l++) {
          if (bmpimage[ligg+k][coll+l] < 0) Val += 256 + bmpimage[ligg+k][coll+l];
          else Val += bmpimage[ligg+k][coll+l];
          }
    bmpfinal[lig][col] = (char) floor(Val / (SubSamp*SubSamp));
    }
  }
  
for (lig = 0; lig < NligFin; lig++) {
  if (lig%(int)(NligFin/20) == 0) {printf("%f\r", 100. * lig / (NligFin - 1));fflush(stdout);}
  for (col = 0; col < ExtraColBMP; col++) {
    bmpfinal[lig][NcolFin + col] = (char) (0);
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
