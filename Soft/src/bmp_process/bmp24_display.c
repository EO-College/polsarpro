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

File     : bmp24_display.c
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
  FILE *fileinput, *fileoutput;

  char FileHeader[FilePathLength], FileData[FilePathLength];
  char FileOutput[FilePathLength], FileColorMap[FilePathLength];

  int lig, col, k, l, ligg, coll;
  int NligInit, NcolInit;
  int NligFin, NcolFin;
  int SubSamp;
  int ValR, ValG, ValB;

  char *bmpimage;
  char *bmpfinal;

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

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifh",str_cmd_prm,FileHeader,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,FileData,1,UsageHelp);
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
  fclose(fileinput);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  NcolFin = (int) floor(NcolInit / SubSamp);
  NligFin = (int) floor(NligInit / SubSamp);

  ExtraColBMP = (int) fmod(4 - (int) fmod(3*NcolFin, 4), 4);
  NcolBMP = 3*NcolFin + ExtraColBMP;

  bmpimage = vector_char(3 * NligInit * NcolInit);
  bmpfinal = vector_char(NligFin * NcolBMP);

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

  /* BMP HDR FILE */
  write_bmp_hdr(NligFin, NcolFin, 0, 0, 24, FileOutput);

  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
  edit_error("Could not open output file : ", FileOutput);

/* BMP HEADER */
  write_header_bmp_24bit(NligFin, NcolFin, fileoutput);

  /********************************************************************
********************************************************************/
/* DATA PROCESSING */
ligg = coll = 0;
#pragma omp parallel for private(col, ligg, coll, ValR, ValG, ValB, k, l)
for (lig = 0; lig < NligFin; lig++) {
  if (omp_get_thread_num() == 0) if (lig%(int)(NligFin/20) == 0) {printf("%f\r", 100. * lig / (NligFin - 1));fflush(stdout);}
  ligg = lig * SubSamp;
  for (col = 0; col < NcolFin; col++) {
    coll = col * SubSamp;
    ValR = 0; ValG = 0; ValB = 0;
    for (k = 0; k < SubSamp; k++)
        for (l = 0; l < SubSamp; l++) {
          if (bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 0] < 0) ValR += 256 + bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 0];
          else ValR += bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 0];
          if (bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 1] < 0) ValG += 256 + bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 1];
          else ValG += bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 1];
          if (bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 2] < 0) ValB += 256 + bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 2];
          else ValB += bmpimage[3*((ligg+k) * NcolInit + (coll+l)) + 2];
          }
    bmpfinal[lig * NcolBMP + 3*col + 0] = (char) floor(ValR / (SubSamp*SubSamp));
    bmpfinal[lig * NcolBMP + 3*col + 1] = (char) floor(ValG / (SubSamp*SubSamp));
    bmpfinal[lig * NcolBMP + 3*col + 2] = (char) floor(ValB / (SubSamp*SubSamp));
    }
  for (col = 0; col < ExtraColBMP; col++) {
    l = (int) (floor(255 * 0.));
    bmpfinal[lig * NcolBMP + 3*NcolFin + col] = (char) (l);
    }
  } /* lig */

  fwrite(&bmpfinal[0], sizeof(char), NligFin*NcolBMP, fileoutput);  

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
