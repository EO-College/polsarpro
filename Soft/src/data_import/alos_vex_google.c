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

File   : alos_vex_google.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 11/2008
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

Description :  Create a Google Kml File

********************************************************************/
/* C INCLUDES */
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
char *my_strrev(char *buf);

/* ACCESS FILE */
FILE *filename;

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

  char DirOutput[FilePathLength], FileInput[FilePathLength];
  char FileName[FilePathLength], FileGoogle[FilePathLength];

  char Buf[100],Tmp[100];
  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;
  char *pstr;
  int Flag, index;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nalos_vex_google.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-of  	output google file\n");
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
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileGoogle,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_dir(DirOutput);
  check_file(FileGoogle);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* INPUT FILE */
/*******************************************************************/

  if ((filename = fopen(FileInput, "r")) == NULL)
    edit_error("Could not open output file : ", FileInput);

  rewind(filename);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"SLCProduct {");
    if (pstr != NULL) Flag = 1;
  }

//Point 0,0
  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"first_line_first_pixel");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, ":") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - (index+1));

  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Buf, ""); strncat(Buf, &Tmp[index], 1);
    if (strcmp(Buf, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Buf, ""); strncat(Buf, &Tmp[0], index); Lat00 = atof(Buf);
  strcpy(Buf, ""); strncat(Buf, &Tmp[index+1], strlen(Buf) - index);
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[0], index); Lon00 = atof(Tmp);

//Point 0,N
  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"first_line_last_pixel");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, ":") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - (index+1));

  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Buf, ""); strncat(Buf, &Tmp[index], 1);
    if (strcmp(Buf, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Buf, ""); strncat(Buf, &Tmp[0], index); Lat0N = atof(Buf);
  strcpy(Buf, ""); strncat(Buf, &Tmp[index+1], strlen(Buf) - index);
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[0], index); Lon0N = atof(Tmp);

//Point N,0
  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"last_line_first_pixel");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, ":") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - (index+1));

  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Buf, ""); strncat(Buf, &Tmp[index], 1);
    if (strcmp(Buf, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Buf, ""); strncat(Buf, &Tmp[0], index); LatN0 = atof(Buf);
  strcpy(Buf, ""); strncat(Buf, &Tmp[index+1], strlen(Buf) - index);
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[0], index); LonN0 = atof(Tmp);

//Point N,N
  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"last_line_last_pixel");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, ":") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - (index+1));

  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Buf, ""); strncat(Buf, &Tmp[index], 1);
    if (strcmp(Buf, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Buf, ""); strncat(Buf, &Tmp[0], index); LatNN = atof(Buf);
  strcpy(Buf, ""); strncat(Buf, &Tmp[index+1], strlen(Buf) - index);
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[0], index); LonNN = atof(Tmp);

//Point Center
  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"center_line_center_pixel");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, ":") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - (index+1));

  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Buf, ""); strncat(Buf, &Tmp[index], 1);
    if (strcmp(Buf, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Buf, ""); strncat(Buf, &Tmp[0], index); LatCenter = atof(Buf);
  strcpy(Buf, ""); strncat(Buf, &Tmp[index+1], strlen(Buf) - index);
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, " ") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[0], index); LonCenter = atof(Tmp);

  fclose(filename);

/*******************************************************************/
/* WRITE GOOGLE FILE */
/*******************************************************************/

  sprintf(FileName, "%s%s", DirOutput, "GEARTH_POLY.kml");
  if ((filename = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fprintf(filename,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
  fprintf(filename,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<name>\n");
  fprintf(filename, "Image ALOS PALSAR\n");
  fprintf(filename,"</name>\n");
  fprintf(filename,"<LookAt>\n");
  fprintf(filename,"<longitude>\n");
  fprintf(filename, "%f\n", LonCenter);
  fprintf(filename,"</longitude>\n");
  fprintf(filename,"<latitude>\n");
  fprintf(filename, "%f\n", LatCenter);
  fprintf(filename,"</latitude>\n");
  fprintf(filename,"<range>\n");
  fprintf(filename,"250000.0\n");
  fprintf(filename,"</range>\n");
  fprintf(filename,"<tilt>0</tilt>\n");
  fprintf(filename,"<heading>0</heading>\n");
  fprintf(filename,"</LookAt>\n");
  fprintf(filename,"<Style>\n");
  fprintf(filename,"<LineStyle>\n");
  fprintf(filename,"<color>ff0000ff</color>\n");
  fprintf(filename,"<width>4</width>\n");
  fprintf(filename,"</LineStyle>\n");
  fprintf(filename,"</Style>\n");
  fprintf(filename,"<LineString>\n");
  fprintf(filename,"<coordinates>\n");
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename, "%f,%f,8000.0\n", LonN0,LatN0);
  fprintf(filename, "%f,%f,8000.0\n", LonNN,LatNN);
  fprintf(filename, "%f,%f,8000.0\n", Lon0N,Lat0N);
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename,"</coordinates>\n");
  fprintf(filename,"</LineString>\n");
  fprintf(filename,"</Placemark>\n");
  fprintf(filename,"</kml>\n");

  fclose(filename);

  if ((filename = fopen(FileGoogle, "w")) == NULL)
    edit_error("Could not open output file : ", FileGoogle);
  fprintf(filename, "%f\n", LatCenter);
  fprintf(filename, "%f\n", LonCenter);
  fprintf(filename, "%f\n", Lat00);
  fprintf(filename, "%f\n", Lon00);
  fprintf(filename, "%f\n", Lat0N);
  fprintf(filename, "%f\n", Lon0N);
  fprintf(filename, "%f\n", LatN0);
  fprintf(filename, "%f\n", LonN0);
  fprintf(filename, "%f\n", LatNN);
  fprintf(filename, "%f\n", LonNN);
  fclose(filename);

  return 1;
}



