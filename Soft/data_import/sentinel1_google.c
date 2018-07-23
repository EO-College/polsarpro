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

File     : sentinel1_google.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 09/2014
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

Description :  extract information from Sentinel1 header file

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
  FILE *ftmp, *filename;
  char DirInput[FilePathLength];
  char FileName[FilePathLength];
  char FileGoogle[FilePathLength];
  char FileTmp[FilePathLength];
  char Buf[65536];
  char Tmp[65536];
  char *p1;

  int FlagGrid, burstList, geolocationGridPointList;
//  int numberOfLines, numberOfSamples;
  int BurstNum;
  
  int ii, M;
  float Lat00,LatN0,Lat0N,LatNN;
  float Lon00,LonN0,Lon0N,LonNN;
  float LatCenter, LonCenter;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsentinel1_google.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input header file\n");
strcat(UsageHelp," (string)	-of  	output config file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-bn  	burst number\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileTmp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileGoogle,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bn",int_cmd_prm,&BurstNum,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput);
  check_file(FileGoogle);
  check_file(FileTmp);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);
 
  rewind(ftmp);
  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 
//    if (strstr(Buf,"numberOfSamples") != NULL) {
//      p1 = strstr(Buf,".: ");
//      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
//      numberOfSamples = atoi(Tmp);
//      }
//    if (strstr(Buf,"numberOfLines") != NULL) {
//      p1 = strstr(Buf,".: ");
//      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
//      numberOfLines = atoi(Tmp);
//      }
    if (strstr(Buf,"burstList") != NULL) {
      p1 = strstr(Buf,": ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - 3);      
      burstList = atoi(Tmp);
      }
    if (strstr(Buf,"geolocationGridPointList") != NULL) {
      p1 = strstr(Buf,": ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - 3);      
      geolocationGridPointList = atoi(Tmp);
      }
    }
   
  FlagGrid = 0;  
  M = geolocationGridPointList / (burstList + 1);
  rewind(ftmp);

  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 

    if (FlagGrid == 1) {
      if (strstr(Buf,"geolocationGridPointList") != NULL) {
        if (BurstNum != 0) {
          for (ii = 0; ii < (BurstNum-1)*M; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);            
            }
          // (0,0)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lat00 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lon00 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          for (ii = 0; ii < M-2; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);            
            }
          // (0,N)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lat0N = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lon0N = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          // (N,0)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LatN0 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LonN0 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          for (ii = 0; ii < M-2; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);            
            }
          // (N,N)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LatNN = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LonNN = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp);           
          } else {
          // (0,0)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lat00 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lon00 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          for (ii = 0; ii < M-2; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);            
            }
          // (0,N)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lat0N = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            Lon0N = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          for (ii = 0; ii < (burstList-1)*M; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);            
            }
          // (N,0)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LatN0 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LonN0 = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          for (ii = 0; ii < M-2; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);            
            }
          // (N,N)
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);          
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp);
          if (strstr(Buf,"latitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LatNN = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); 
          if (strstr(Buf,"longitude") != NULL) {
            p1 = strstr(Buf,".: ");
            strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
            LonNN = atof(Tmp);
            }
          fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
          fgets(&Buf[0], 1024, ftmp);                     
          }     
        }
      }

    if (strstr(Buf,"geolocationGrid") != NULL) FlagGrid = 1; 
    }    

  fclose(ftmp);

  LonCenter = (Lon00 + Lon0N + LonN0 + LonNN)/4.;
  LatCenter = (Lat00 + Lat0N + LatN0 + LatNN)/4.;
  
/*******************************************************************/
/*******************************************************************/

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

/*******************************************************************/
/* WRITE GOOGLE FILE */
/*******************************************************************/

  sprintf(FileName, "%s%s", DirInput, "GEARTH_POLY.kml");
  if ((filename = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fprintf(filename,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
  fprintf(filename,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<name>\n");
  fprintf(filename, "Image SENTINEL 1\n");
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
 