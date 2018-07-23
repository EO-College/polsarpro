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

File     : mapready_google_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 07/2010
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

Description :  Create the GEARTH_POLY.kml file from the MapReady
               Overlay file

********************************************************************/

/* C INCLUDES */
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

  FILE *filename, *foverlay;
  char FileOverlay[FilePathLength], MapReadyDir[FilePathLength], FileName[FilePathLength];
  char Tmp[FilePathLength];
    
  int ii;
  float GoogleNorth, GoogleSouth, GoogleWest, GoogleEast;
  float Lon00,Lat00,LonN0,LatN0,LonNN,LatNN,Lon0N,Lat0N,LonCenter,LatCenter; 

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmapready_google_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input MapReady overlay file name\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileOverlay,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,MapReadyDir,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileOverlay);
  check_dir(MapReadyDir);

/*******************************************************************/
/*******************************************************************/

  if ((foverlay = fopen(FileOverlay, "r")) == NULL)
    edit_error("Could not open input file : ", FileOverlay);

  while( !feof(foverlay) ) {
    fgets(Tmp,1024,foverlay);
    if (strstr(Tmp,"<LatLonBox>") != NULL) {
      for (ii = 0; ii < 4; ii++) {
        fgets(Tmp,1024,foverlay);
        if (strstr(Tmp,"<north>") != NULL) sscanf(Tmp, "      <north>%f<\\north>",&GoogleNorth);
        if (strstr(Tmp,"<south>") != NULL) sscanf(Tmp, "      <south>%f<\\south>",&GoogleSouth);
        if (strstr(Tmp,"<west>") != NULL) sscanf(Tmp, "      <west>%f<\\west>",&GoogleWest);
        if (strstr(Tmp,"<east>") != NULL) sscanf(Tmp, "      <east>%f<\\east>",&GoogleEast);
        }
      }
    }
  fclose(foverlay);

/* WRITE GOOGLE FILE */

  Lon00 = GoogleWest;
  Lat00 = GoogleNorth;
  LonN0 = GoogleEast;
  LatN0 = GoogleNorth;
  LonNN = GoogleEast;
  LatNN = GoogleSouth;
  Lon0N = GoogleWest;
  Lat0N = GoogleSouth;
  LonCenter = (GoogleWest + GoogleEast)*0.5;
  LatCenter = (GoogleNorth + GoogleSouth)*0.5;


  sprintf(FileName, "%s%s", MapReadyDir, "GEARTH_POLY.kml");
  if ((filename = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fprintf(filename,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
  fprintf(filename,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<name>\n");
  fprintf(filename, "Image\n");
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

  return 1;
}
