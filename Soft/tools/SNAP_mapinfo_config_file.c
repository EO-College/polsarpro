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

File     : SNAP_mapinfo_config_file.c
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
  FILE *file, *fdata;
  char FileData[FilePathLength], SNAPDir[FilePathLength], file_name[FilePathLength];
  char PolarType[10], sensor[FilePathLength], mapinfo[FilePathLength]; 
  char Buf[FilePathLength];
  
  int Ncol, Nlig;
  float f1, f2;
  double f3,f4,f5,f6;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nSNAP_mapinfo_config_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input SNAP dir\n");
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
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,SNAPDir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileData,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ss",str_cmd_prm,sensor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pp",str_cmd_prm,PolarType,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileData);
  check_dir(SNAPDir);

/*******************************************************************/
/*******************************************************************/

  if ((fdata = fopen(FileData, "r")) == NULL)
    edit_error("Could not open input file : ", FileData);

  while( !feof(fdata) ) {
    fgets(&Buf[0], 1024, fdata); 
    if (strstr(Buf,"map info") != NULL) {
      strcpy(mapinfo, Buf);
      sscanf(Buf, "map info = {Geographic Lat/Lon,%f,%f,%lf,%lf,%le,%le,WGS-84, units=Degrees}",&f1,&f2,&f3,&f4,&f5,&f6);
      }
    if (strstr(Buf,"samples") != NULL) {
      sscanf(Buf, "samples = %i\n",&Ncol);
      }
    if (strstr(Buf,"lines") != NULL) {
      sscanf(Buf, "lines = %i\n",&Nlig);
      }
    }
  
  fclose(fdata);

  write_config(SNAPDir, Nlig, Ncol, "monostatic", PolarType);

  sprintf(file_name, "%sconfig_mapinfo.txt", SNAPDir);
  if ((file = fopen(file_name, "w")) == NULL)
    edit_error("Could not open configuration file : ", file_name);

  fprintf(file, "Sensor\n");
  fprintf(file, "%s\n", sensor);
  fprintf(file, "---------\n");
  fprintf(file, "MapInfo\n");
  fprintf(file, "%s", mapinfo);
  fprintf(file, "---------\n");
  fprintf(file, "MapProj\n");
  fprintf(file, "Geographic Lat/Lon\n");
  fprintf(file, "%f\n", f1);
  fprintf(file, "%f\n", f2);
  fprintf(file, "%lf\n", f3);
  fprintf(file, "%lf\n", f4);
  fprintf(file, "%le\n", f5);
  fprintf(file, "%le\n", f6);
  fprintf(file, "WGS-84\n");
  fprintf(file, "units=Degrees\n");
  fclose(file);
    
  return 1;
}
