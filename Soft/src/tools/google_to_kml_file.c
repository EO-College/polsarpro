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

File     : google_to_kml_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2016
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

Description :  Create a Kml File

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/

int main(int argc, char *argv[])
/*                                                                            */
{

/* LOCAL VARIABLES */
  FILE *filename;
  char FileGoogle[FilePathLength], FileKML[FilePathLength], FilePNG[FilePathLength];
  char Tmp[FilePathLength];
  
  float Lon00,Lat00,LonN0,LatN0,LonNN,LatNN,Lon0N,Lat0N,LonCenter,LatCenter; 
  float MinLat, MaxLat, MinLon, MaxLon;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ngoogle_to_kml_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifg 	input google file\n");
strcat(UsageHelp," (string)	-ofk 	output kml file\n");
strcat(UsageHelp," (string)	-ifp 	input PNG file name\n");
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
  get_commandline_prm(argc,argv,"-ifg",str_cmd_prm,FileGoogle,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifp",str_cmd_prm,FilePNG,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofk",str_cmd_prm,FileKML,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileGoogle);
  check_file(FileKML);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  if ((filename = fopen(FileGoogle, "r")) == NULL)
    edit_error("Could not open output file : ", FileGoogle);

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

  MinLat = Lat00;
  if (LatN0 <= MinLat) MinLat = LatN0;
  if (LatNN <= MinLat) MinLat = LatNN;
  if (Lat0N <= MinLat) MinLat = Lat0N;
  MinLon = Lon00;
  if (LonN0 <= MinLon) MinLon = LonN0;
  if (LonNN <= MinLon) MinLon = LonNN;
  if (Lon0N <= MinLon) MinLon = Lon0N;
  MaxLat = Lat00;
  if (MaxLat <= LatN0) MaxLat = LatN0;
  if (MaxLat <= LatNN) MaxLat = LatNN;
  if (MaxLat <= Lat0N) MaxLat = Lat0N;
  MaxLon = Lon00;
  if (MaxLon <= LonN0) MaxLon = LonN0;
  if (MaxLon <= LonNN) MaxLon = LonNN;
  if (MaxLon <= Lon0N) MaxLon = Lon0N;
  
/*******************************************************************/
/*******************************************************************/

  if ((filename = fopen(FileKML, "w")) == NULL)
    edit_error("Could not open output file : ", FileKML);

  fprintf(filename,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(filename,"<kml xmlns=\"http://earth.google.com/kml/2.2\">\n");
  fprintf(filename,"<Document>\n");
  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<LookAt>\n");
  fprintf(filename,"<longitude>\n"); fprintf(filename,"%f", LonCenter); fprintf(filename,"</longitude>\n");
  fprintf(filename,"<latitude>\n"); fprintf(filename,"%f", LatCenter); fprintf(filename,"</latitude>\n");
  fprintf(filename,"<range>\n"); fprintf(filename,"400000.0\n"); fprintf(filename,"</range>\n");
  fprintf(filename,"</LookAt>\n");
  fprintf(filename,"<visibility>1</visibility>\n");
  fprintf(filename,"<open>1</open>\n");
  fprintf(filename,"<Style>\n");
  fprintf(filename,"<LineStyle>\n");
  fprintf(filename,"<color>ffff9900</color>\n");
  fprintf(filename,"<width>2</width>\n");
  fprintf(filename,"</LineStyle>\n");
  fprintf(filename,"<PolyStyle>\n");
  fprintf(filename,"<color>1fff5500</color>\n");
  fprintf(filename,"</PolyStyle>\n");
  fprintf(filename,"</Style>\n");
  fprintf(filename,"<LineString>\n");
  fprintf(filename,"<altitudeMode>clampToGround</altitudeMode>\n");
  fprintf(filename,"<extrude>1</extrude>\n");
  fprintf(filename,"<tesselate>1</tesselate>\n");
  fprintf(filename,"<coordinates>\n");
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename, "%f,%f,8000.0\n", LonN0,LatN0);
  fprintf(filename, "%f,%f,8000.0\n", LonNN,LatNN);
  fprintf(filename, "%f,%f,8000.0\n", Lon0N,Lat0N);
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename,"</coordinates>\n");
  fprintf(filename,"</LineString>\n");
  fprintf(filename,"</Placemark>\n");
  fprintf(filename,"<GroundOverlay>\n");
  fprintf(filename,"<color>ffffffff</color>\n");
  fprintf(filename,"<Icon>\n");
  fprintf(filename,"<href>"); fprintf(filename,"%s",FilePNG); fprintf(filename,"</href>\n");
  fprintf(filename,"<viewBoundScale>0.75</viewBoundScale>\n");
  fprintf(filename,"</Icon>\n");
  fprintf(filename,"<LatLonBox>\n");
  fprintf(filename,"<north>"); fprintf(filename,"%f",MaxLat); fprintf(filename,"</north>\n");
  fprintf(filename,"<south>"); fprintf(filename,"%f",MinLat); fprintf(filename,"</south>\n");
  fprintf(filename,"<east>"); fprintf(filename,"%f",MinLon); fprintf(filename,"</east>\n");
  fprintf(filename,"<west>"); fprintf(filename,"%f",MaxLon); fprintf(filename,"</west>\n");
  fprintf(filename,"</LatLonBox>\n");
  fprintf(filename,"</GroundOverlay>\n");
  fprintf(filename,"</Document>\n");
  fprintf(filename,"</kml>\n");

  fclose(filename);
    
  return 1;
}
