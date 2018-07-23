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

File   : read_gearth_poly.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Extract Latitude / Longitude Parameters from a Google 
GEARTH_POLY Kml File

********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

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

  char FileInput[FilePathLength];
  char FileGoogle[FilePathLength];

  char Tmp[100];
  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nread_gearth_poly.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-of  	output TMP file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 5) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileGoogle,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(FileGoogle);

/*******************************************************************/
/* INPUT FILE */
/*******************************************************************/

  if ((filename = fopen(FileInput, "r")) == NULL)
    edit_error("Could not open output file : ", FileInput);

  rewind(filename);

  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f\n", &LonCenter);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f\n", &LatCenter);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f,%f,8000.0\n", &Lon00,&Lat00);
  fscanf(filename, "%f,%f,8000.0\n", &LonN0,&LatN0);
  fscanf(filename, "%f,%f,8000.0\n", &LonNN,&LatNN);
  fscanf(filename, "%f,%f,8000.0\n", &Lon0N,&Lat0N);
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



