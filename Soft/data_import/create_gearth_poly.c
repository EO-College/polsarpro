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

File   : create_gearth_poly.c
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

Description :  Create a Google GEARTH_POLY Kml File from Latitude
               and Longitude Parameters

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
  FILE *filename;

  char FileOutput[FilePathLength];

  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_gearth_poly.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (float) 	-lac 	latitude center\n");
strcat(UsageHelp," (float) 	-loc 	longitude center\n");
strcat(UsageHelp," (float) 	-la00	latitude top left\n");
strcat(UsageHelp," (float) 	-lo00	longitude top left\n");
strcat(UsageHelp," (float) 	-la0N	latitude top right\n");
strcat(UsageHelp," (float) 	-lo0N	longitude top right\n");
strcat(UsageHelp," (float) 	-laN0	latitude bottom left\n");
strcat(UsageHelp," (float) 	-loN0	longitude bottom left\n");
strcat(UsageHelp," (float) 	-laNN	latitude bottom right\n");
strcat(UsageHelp," (float) 	-loNN	longitude bottom right\n");
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
  get_commandline_prm(argc,argv,"-lac",flt_cmd_prm,&LatCenter,1,UsageHelp);
  get_commandline_prm(argc,argv,"-loc",flt_cmd_prm,&LonCenter,1,UsageHelp);
  get_commandline_prm(argc,argv,"-laOO",flt_cmd_prm,&Lat00,1,UsageHelp);
  get_commandline_prm(argc,argv,"-loOO",flt_cmd_prm,&Lon00,1,UsageHelp);
  get_commandline_prm(argc,argv,"-laON",flt_cmd_prm,&Lat0N,1,UsageHelp);
  get_commandline_prm(argc,argv,"-loON",flt_cmd_prm,&Lon0N,1,UsageHelp);
  get_commandline_prm(argc,argv,"-laNO",flt_cmd_prm,&LatN0,1,UsageHelp);
  get_commandline_prm(argc,argv,"-loNO",flt_cmd_prm,&LonN0,1,UsageHelp);
  get_commandline_prm(argc,argv,"-laNN",flt_cmd_prm,&LatNN,1,UsageHelp);
  get_commandline_prm(argc,argv,"-loNN",flt_cmd_prm,&LonNN,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileOutput);

/*******************************************************************/
/* OUTPUT FILE */
/*******************************************************************/

  if ((filename = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open output file : ", FileOutput);

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
  
  return 1;
}



