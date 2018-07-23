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

File     : mapready_check_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 10/2009
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

Description :  Check the pathname of the files in a MapReady
               Config file

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
FILE *ftmp;
FILE *fmp;

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

  char FileTmp[FilePathLength];
  char MapReadyName[FilePathLength];
  char Tmp[FilePathLength];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmapready_check_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input MapReady file name\n");
strcat(UsageHelp," (string)	-of  	output tmp file\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,MapReadyName,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileTmp,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(MapReadyName);
  check_file(FileTmp);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "w")) == NULL)
    edit_error("Could not open input file : ", FileTmp);
  if ((fmp = fopen(MapReadyName, "r")) == NULL)
    edit_error("Could not open input file : ", MapReadyName);
  while( !feof(fmp) ) {
    fgets(Tmp,1024,fmp);
    check_file(Tmp);
    fprintf(ftmp, "%s",Tmp);
    }
  fclose(ftmp);fclose(fmp);

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);
  if ((fmp = fopen(MapReadyName, "w")) == NULL)
    edit_error("Could not open input file : ", MapReadyName);
  while( !feof(ftmp) ) {
    fgets(Tmp,1024,ftmp);
    fprintf(fmp, "%s",Tmp);
    }
  fclose(ftmp);fclose(fmp);

  return 1;
}
