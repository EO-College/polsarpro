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

File     : mapinfo_config_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 10/2010
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

Description :  Create the config_mapinfo.txt file

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
  FILE *file, *fhdr;
  char FileHdr[FilePathLength], MapInfoDir[FilePathLength], file_name[FilePathLength];
  char Tmp[FilePathLength], Val[FilePathLength], PolarType[10];
  char sensor[FilePathLength], mapinfo[FilePathLength], projinfo[FilePathLength], waveunit[FilePathLength]; 

  int Ncol, Nlig;
//int FlagMapInfo;
  int FlagProjInfo, FlagWaveUnit, FlagUTM, FlagLatLong;
  float f1,f2,f3,f4,f5,f6;
  int i1;
  char s1[100],s2[100];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmapinfo_config_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input MapReady dir\n");
strcat(UsageHelp," (string)	-if  	input hdr file\n");
strcat(UsageHelp," (string)	-ss  	sensor name\n");
strcat(UsageHelp," (string)	-pp  	polar type (full, pp1, pp2, pp3)\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,MapInfoDir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileHdr,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ss",str_cmd_prm,sensor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pp",str_cmd_prm,PolarType,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileHdr);
  check_dir(MapInfoDir);

/*******************************************************************/
/*******************************************************************/

  if ((fhdr = fopen(FileHdr, "r")) == NULL)
    edit_error("Could not open input file : ", FileHdr);

//  FlagMapInfo = 0;
  FlagProjInfo = 0; FlagWaveUnit = 0; FlagUTM = 0; FlagLatLong = 0;

  while( !feof(fhdr) ) {
    fgets(Tmp,1024,fhdr);
    if (strstr(Tmp,"samples") != NULL) {
      strncpy(&Val[0],&Tmp[9], strlen(Tmp)-9);
      Ncol = atoi(Val);
      }
    if (strstr (Tmp,"lines") != NULL) {
      strncpy(&Val[0],&Tmp[9], strlen(Tmp)-9);
      Nlig = atoi(Val);
      }
    if (strstr (Tmp,"map info") != NULL) {
//      FlagMapInfo = 1;
      strncpy(&mapinfo[0], &Tmp[0], strlen(Tmp)-1);
      mapinfo[strlen(Tmp)-1] = '\0';
      if (strstr (Tmp,"UTM") != NULL) {
        FlagUTM = 1;
        sscanf(Tmp, "map info = {UTM, 1, 1, %f, %f, %f, %f, %i, %s, %s}",&f1,&f2,&f3,&f4,&i1,s1,s2); 
        }
      if (strstr (Tmp,"Geographic Lat/Lon") != NULL) {
        FlagLatLong = 1;
        sscanf(Tmp, "map info = {Geographic Lat/Lon,%f,%f,%f,%f,%f,%f,%s,%s}",&f1,&f2,&f3,&f4,&f5,&f6,s1,s2); 
        }
      }

    if (strstr (Tmp,"projection info") != NULL) {
      FlagProjInfo = 1;
      strncpy(&projinfo[0], &Tmp[0], strlen(Tmp)-1);
      projinfo[strlen(Tmp)-1] = '\0';
      }
    if (strstr (Tmp,"wavelength units") != NULL) {
      FlagWaveUnit = 1;
      strncpy(&waveunit[0], &Tmp[0], strlen(Tmp)-1);
      waveunit[strlen(Tmp)-1] = '\0';
      }
    }
  fclose(fhdr);

  write_config(MapInfoDir, Nlig, Ncol, "monostatic", PolarType);

  sprintf(file_name, "%sconfig_mapinfo.txt", MapInfoDir);
  if ((file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open configuration file : ", file_name);

  fprintf(file, "Sensor\n");
  fprintf(file, "%s\n", sensor);
  fprintf(file, "---------\n");
  fprintf(file, "MapInfo\n");
  fprintf(file, "%s\n", mapinfo);
  fprintf(file, "---------\n");
  if (FlagProjInfo == 1) {
    fprintf(file, "ProjInfo\n");
    fprintf(file, "%s\n", projinfo);
    fprintf(file, "---------\n");
    }
  if (FlagWaveUnit == 1) {
    fprintf(file, "WaveUnit\n");
    fprintf(file, "%s\n", waveunit);
    fprintf(file, "---------\n");
    }
  fprintf(file, "MapProj\n");
  if ((FlagUTM == 0)&&(FlagLatLong == 0)) fprintf(file, "NO UTM - NO Lat/Long\n");
  if (FlagUTM == 1) {
    fprintf(file, "UTM\n");
    fprintf(file, "%f\n", f1);
    fprintf(file, "%f\n", f2);
    fprintf(file, "%f\n", f3);
    fprintf(file, "%f\n", f4);
    fprintf(file, "%i\n", i1);
    fprintf(file, "%s\n", s1);
    fprintf(file, "%s\n", s2);
    }
  if (FlagLatLong == 1) {
    fprintf(file, "Geographic Lat/Lon\n");
    fprintf(file, "%f\n", f1);
    fprintf(file, "%f\n", f2);
    fprintf(file, "%f\n", f3);
    fprintf(file, "%f\n", f4);
    fprintf(file, "%f\n", f5);
    fprintf(file, "%f\n", f6);
    fprintf(file, "%s\n", s1);
    fprintf(file, "%s\n", s2);
    }
  fclose(file);
    
  return 1;
}


