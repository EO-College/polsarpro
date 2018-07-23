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

File     : fsar_config.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 02/2012
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

Description :  extract information from a FSAR header file

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
  FILE *ftmp, *fconfig, *fgoogle;
  char FileTmp1[FilePathLength], FileTmp2[FilePathLength], FileConfig[FilePathLength], FileGoogle[FilePathLength];
  char FileName[FilePathLength], DirOutput[FilePathLength];
  char Buf[65536], Tmp[65536];
  char Frequency[FilePathLength], Calibration[FilePathLength], ResolRg[FilePathLength], ResolAz[FilePathLength];
  char PixRg[FilePathLength], PixAz[FilePathLength], Header[FilePathLength], Column[FilePathLength], Line[FilePathLength];
  
  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;
  float flt;
  char *p1;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfsar_config.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if1 	input product file\n");
strcat(UsageHelp," (string)	-if2 	input data hdr file\n");
strcat(UsageHelp," (string)	-ocf 	output config file\n");
strcat(UsageHelp," (string)	-ogf 	output google file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
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
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,FileTmp1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,FileTmp2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,FileConfig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ogf",str_cmd_prm,FileGoogle,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileTmp1);
  check_file(FileTmp2);
  check_file(FileConfig);
  check_file(FileGoogle);
  check_dir(DirOutput);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp1, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp1);

  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 

    if (strstr(Buf,"Centre Frequency") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(Frequency, ""); strncat(Frequency, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"type of calibration") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(Calibration, ""); strncat(Calibration, &p1[3], strlen(p1) - 4);
      if (strcmp(Calibration,"-1") == 0) strcpy(Calibration,"none");
      if (strcmp(Calibration,"0") == 0) strcpy(Calibration,"beta0 (ECS)");
      if (strcmp(Calibration,"1") == 0) strcpy(Calibration,"beta0");
      if (strcmp(Calibration,"2") == 0) strcpy(Calibration,"sigma0");
      if (strcmp(Calibration,"3") == 0) strcpy(Calibration,"gamma0");
      if (strcmp(Calibration,"4") == 0) strcpy(Calibration,"gamma0 w/o DEM slope");
      }
    if (strstr(Buf,"Processed azimuth resolution") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(ResolAz, ""); strncat(ResolAz, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"Processed range resolution") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(ResolRg, ""); strncat(ResolRg, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"Pixel spacing in azimuth") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(PixAz, ""); strncat(PixAz, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"Pixel spacing in range") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(PixRg, ""); strncat(PixRg, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"The geographic coordinates") != NULL) {
      fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 4);
      sscanf(Tmp, "[%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f]", &Lon00, &Lat00, &flt, &Lon0N, &Lat0N, &flt, &LonNN, &LatNN, &flt, &LonN0, &LatN0, &flt);
      LatCenter = (Lat00 + Lat0N + LatNN + LatN0)/4.;
      LonCenter = (Lon00 + Lon0N + LonNN + LonN0)/4.;     
      }
    }
    fclose(ftmp);

  if ((ftmp = fopen(FileTmp2, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp2);

  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); p1 = strstr(Buf," = ");

    if (strstr(Buf,"samples") != NULL) {
      strcpy(Column, ""); strncat(Column, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"lines") != NULL) {
      strcpy(Line, ""); strncat(Line, &p1[3], strlen(p1) - 4);
      }
    if (strstr(Buf,"header offset") != NULL) {
      strcpy(Header, ""); strncat(Header, &p1[3], strlen(p1) - 4);
      }
    }
    fclose(ftmp);
    
/*******************************************************************/
/*******************************************************************/

  if ((fconfig = fopen(FileConfig, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileConfig);

  fprintf(fconfig,"%s\n",Frequency);
  fprintf(fconfig,"%s\n",Calibration);
  fprintf(fconfig,"%s\n",ResolRg);
  fprintf(fconfig,"%s\n",ResolAz);
  fprintf(fconfig,"%s\n",PixRg);
  fprintf(fconfig,"%s\n",PixAz);
//  itoa(atoi(Column),Column,10);
  sprintf(Column,"%d",atoi(Column));
  fprintf(fconfig,"%s\n",Column);
//  itoa(atoi(Line),Line,10);
  sprintf(Line,"%d",atoi(Line));
  fprintf(fconfig,"%s\n",Line);
//  itoa(atoi(Header),Header,10);
  sprintf(Header,"%d",atoi(Header));
  fprintf(fconfig,"%s\n",Header);
  fclose(fconfig);

  
/*******************************************************************/
/*******************************************************************/
  sprintf(FileName, "%s%s", DirOutput, "GEARTH_POLY.kml");
  if ((ftmp = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fprintf(ftmp,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
  fprintf(ftmp,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
  fprintf(ftmp,"<Placemark>\n");
  fprintf(ftmp,"<name>\n");
  fprintf(ftmp, "Image FSAR\n");
  fprintf(ftmp,"</name>\n");
  fprintf(ftmp,"<LookAt>\n");
  fprintf(ftmp,"<longitude>\n");
  fprintf(ftmp, "%f\n", LonCenter);
  fprintf(ftmp,"</longitude>\n");
  fprintf(ftmp,"<latitude>\n");
  fprintf(ftmp, "%f\n", LatCenter);
  fprintf(ftmp,"</latitude>\n");
  fprintf(ftmp,"<range>\n");
  fprintf(ftmp,"250000.0\n");
  fprintf(ftmp,"</range>\n");
  fprintf(ftmp,"<tilt>0</tilt>\n");
  fprintf(ftmp,"<heading>0</heading>\n");
  fprintf(ftmp,"</LookAt>\n");
  fprintf(ftmp,"<Style>\n");
  fprintf(ftmp,"<LineStyle>\n");
  fprintf(ftmp,"<color>ff0000ff</color>\n");
  fprintf(ftmp,"<width>4</width>\n");
  fprintf(ftmp,"</LineStyle>\n");
  fprintf(ftmp,"</Style>\n");
  fprintf(ftmp,"<LineString>\n");
  fprintf(ftmp,"<coordinates>\n");
  fprintf(ftmp, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(ftmp, "%f,%f,8000.0\n", LonN0,LatN0);
  fprintf(ftmp, "%f,%f,8000.0\n", LonNN,LatNN);
  fprintf(ftmp, "%f,%f,8000.0\n", Lon0N,Lat0N);
  fprintf(ftmp, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(ftmp,"</coordinates>\n");
  fprintf(ftmp,"</LineString>\n");
  fprintf(ftmp,"</Placemark>\n");
  fprintf(ftmp,"</kml>\n");
  fclose(ftmp);

/*******************************************************************/
/*******************************************************************/

  if ((fgoogle = fopen(FileGoogle, "w")) == NULL)
    edit_error("Could not open output file : ", FileGoogle);
  fprintf(fgoogle, "%f\n", LatCenter);
  fprintf(fgoogle, "%f\n", LonCenter);
  fprintf(fgoogle, "%f\n", Lat00);
  fprintf(fgoogle, "%f\n", Lon00);
  fprintf(fgoogle, "%f\n", Lat0N);
  fprintf(fgoogle, "%f\n", Lon0N);
  fprintf(fgoogle, "%f\n", LatN0);
  fprintf(fgoogle, "%f\n", LonN0);
  fprintf(fgoogle, "%f\n", LatNN);
  fprintf(fgoogle, "%f\n", LonNN);
  fclose(fgoogle);

    
  return 1;
}
