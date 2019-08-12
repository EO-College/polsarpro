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

File     : csk_config.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 02/2012
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

Description :  extract information from a CSK header file

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
  FILE *ftmp, *fconfig, *fgoogle;
  char FileTmp[FilePathLength], FileConfig[FilePathLength], FileGoogle[FilePathLength];
  char FileName[FilePathLength], DirOutput[FilePathLength];
  char Buf[FilePathLength], Tmp[FilePathLength];
  char Station[FilePathLength], LookSide[FilePathLength], Orbit[FilePathLength];
  char Frequency[FilePathLength], IncAngle[FilePathLength], Satellite[FilePathLength], SceneStart[FilePathLength], SceneStop[FilePathLength];
  char Polar1[FilePathLength], Polar2[FilePathLength], Column[FilePathLength], Line[FilePathLength];
  
  int Ncol, Nlig;
  int ii, FlagChar, FlagGroup, GroupFlag;
  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;
  float flt;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncsk_config.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input header tmp\n");
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

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileTmp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,FileConfig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ogf",str_cmd_prm,FileGoogle,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileTmp);
  check_file(FileConfig);
  check_file(FileGoogle);
  check_dir(DirOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);

  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 

    if (strstr(Buf,"Acquisition Station ID") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(Station, ""); strncat(Station, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }

    if (strstr(Buf,"Look Side") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(LookSide, ""); strncat(LookSide, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }
/*
    if (strstr(Buf,"Mission ID") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(Mission, ""); strncat(Mission, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }
*/
    if (strstr(Buf,"Orbit Direction") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(Orbit, ""); strncat(Orbit, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }

    if (strstr(Buf,"Radar Frequency") != NULL) {
      for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == ':') FlagChar = 1;
        }
      ii++;
      strcpy(Frequency, ""); strncat(Frequency, &Buf[ii], strlen(Buf) - ii - 1);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }

    if (strstr(Buf,"Reference Incidence Angle") != NULL) {
      for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == ':') FlagChar = 1;
        }
      ii++;
      strcpy(IncAngle, ""); strncat(IncAngle, &Buf[ii], strlen(Buf) - ii - 1);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }

    if (strstr(Buf,"Satellite ID") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(Satellite, ""); strncat(Satellite, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }

    if (strstr(Buf,"Scene Sensing Start UTC") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(SceneStart, ""); strncat(SceneStart, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }

    if (strstr(Buf,"Scene Sensing Stop UTC") != NULL) {
      for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
      FlagChar = 0; ii = -1;
      while (FlagChar == 0) {
        ii++;
        if (Buf[ii] == '"') FlagChar = 1;
        }
      ii++;
      strcpy(SceneStop, ""); strncat(SceneStop, &Buf[ii], strlen(Buf) - ii - 2);
      for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
      }
      
    if (strstr(Buf,"GROUP \"S01\"") != NULL) {
      FlagGroup = 0; GroupFlag = 0;
      while (FlagGroup == 0) {
        fgets(&Buf[0], 1024, ftmp); 

        if (strstr(Buf,"DATASET \"SBI") != NULL) {
          fgets(&Buf[0], 1024, ftmp); 
          fgets(&Buf[0], 1024, ftmp); 
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == 'D') FlagChar = 1;
            }
          strcpy(Tmp, ""); strncat(Tmp, &Buf[ii], strlen(Buf) - ii - 1);
          sscanf(Tmp, "DATASPACE  SIMPLE { ( %i, %i, %i ) / ( %i, %i, %i ) }", &Nlig, &Ncol, &ii, &Nlig, &Ncol, &ii);
          }

        if (strstr(Buf,"Centre Geodetic Coordinates") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Tmp, ""); strncat(Tmp, &Buf[ii], strlen(Buf) - ii - 1);
          sscanf(Tmp, "%f, %f, %f", &LatCenter, &LonCenter, &flt);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"Bottom Left Geodetic Coordinates") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Tmp, ""); strncat(Tmp, &Buf[ii], strlen(Buf) - ii - 1);
          sscanf(Tmp, "%f, %f, %f", &LatN0, &LonN0, &flt);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"Bottom Right Geodetic Coordinates") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Tmp, ""); strncat(Tmp, &Buf[ii], strlen(Buf) - ii - 1);
          sscanf(Tmp, "%f, %f, %f", &LatNN, &LonNN, &flt);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"Top Left Geodetic Coordinates") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Tmp, ""); strncat(Tmp, &Buf[ii], strlen(Buf) - ii - 1);
          sscanf(Tmp, "%f, %f, %f", &Lat00, &Lon00, &flt);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"Top Right Geodetic Coordinates") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Tmp, ""); strncat(Tmp, &Buf[ii], strlen(Buf) - ii - 1);
          sscanf(Tmp, "%f, %f, %f", &Lat0N, &Lon0N, &flt);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"Polarisation") != NULL) {
          for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == '"') FlagChar = 1;
            }
          ii++;
          strcpy(Polar1, ""); strncat(Polar1, &Buf[ii], strlen(Buf) - ii - 2);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"ATTRIBUTE \"Column Spacing") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Column, ""); strncat(Column, &Buf[ii], strlen(Buf) - ii - 1);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }

        if (strstr(Buf,"ATTRIBUTE \"Line Spacing") != NULL) {
          for (ii=0; ii<4; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == ':') FlagChar = 1;
            }
          ii++;
          strcpy(Line, ""); strncat(Line, &Buf[ii], strlen(Buf) - ii - 1);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          GroupFlag++;
          }
        if (GroupFlag == 8) FlagGroup = 1;
        }
      }      

    if (strstr(Buf,"GROUP \"S02\"") != NULL) {
      FlagGroup = 0;
      while (FlagGroup == 0) {
        fgets(&Buf[0], 1024, ftmp); 

        if (strstr(Buf,"Polarisation") != NULL) {
          for (ii=0; ii<9; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagChar = 0; ii = -1;
          while (FlagChar == 0) {
            ii++;
            if (Buf[ii] == '"') FlagChar = 1;
            }
          ii++;
          strcpy(Polar2, ""); strncat(Polar2, &Buf[ii], strlen(Buf) - ii - 2);
          for (ii=0; ii<2; ii++) fgets(&Buf[0], 1024, ftmp);
          FlagGroup = 1;
          }
        }
      }      
    }
    fclose(ftmp);
    
/*******************************************************************/
/*******************************************************************/

  if ((fconfig = fopen(FileConfig, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileConfig);

  fprintf(fconfig,"%s\n",Station);
  fprintf(fconfig,"%s\n",LookSide);
  fprintf(fconfig,"%s\n",Orbit);
  fprintf(fconfig,"%s\n",Frequency);
  fprintf(fconfig,"%s\n",IncAngle);
  fprintf(fconfig,"%s\n",Satellite);
  fprintf(fconfig,"%s\n",SceneStart);
  fprintf(fconfig,"%s\n",SceneStop);
  fprintf(fconfig,"%s\n",Polar1);
  fprintf(fconfig,"%s\n",Polar2);
  fprintf(fconfig,"%s\n",Column);
  fprintf(fconfig,"%s\n",Line);
  fprintf(fconfig,"%i\n",Nlig);
  fprintf(fconfig,"%i\n",Ncol);
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
  fprintf(ftmp, "Image COSMO-SKYMED\n");
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
