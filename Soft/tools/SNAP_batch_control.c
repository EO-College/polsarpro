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

File     : SNAP_batch_control.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2011
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

Description :  Control the end of the SNAP Batch-Process

********************************************************************/

/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void wait ( int seconds );

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

  FILE *filename;
  
  char SNAPFile[FilePathLength];
  char tmp[100];
  int lentmp;
  int FlagStop;
  float valeur;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nSNAP_batch_control.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input SNAP batch process file name\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 3) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,SNAPFile,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(SNAPFile);

/*******************************************************************/
/*******************************************************************/

  FlagStop = 0;
  printf("%f\r", 0.);fflush(stdout);
  while (FlagStop == 0) {
    if ((filename = fopen(SNAPFile, "r")) == NULL)
      edit_error("Could not open output file : ", SNAPFile);
    if (fgets(tmp, 100, filename) != NULL) { 
      lentmp = strlen(tmp); tmp[lentmp] = '\0';
      if ((strstr(tmp,"10%") != NULL) || (strstr(tmp,"20%") != NULL) ||
          (strstr(tmp,"30%") != NULL) || (strstr(tmp,"40%") != NULL) ||
          (strstr(tmp,"50%") != NULL) || (strstr(tmp,"60%") != NULL) ||
          (strstr(tmp,"70%") != NULL) || (strstr(tmp,"80%") != NULL) ||
          (strstr(tmp,"90%") != NULL) || (strstr(tmp,"100%") != NULL)) {    
          if (strstr(tmp,"10%") != NULL) valeur = 10.;
          if (strstr(tmp,"20%") != NULL) valeur = 20.;
          if (strstr(tmp,"30%") != NULL) valeur = 30.;
          if (strstr(tmp,"40%") != NULL) valeur = 40.;
          if (strstr(tmp,"50%") != NULL) valeur = 50.;
          if (strstr(tmp,"60%") != NULL) valeur = 60.;
          if (strstr(tmp,"70%") != NULL) valeur = 70.;
          if (strstr(tmp,"80%") != NULL) valeur = 80.;
          if (strstr(tmp,"90%") != NULL) valeur = 90.;
          if (strstr(tmp,"100%") != NULL) valeur = 100.;
          printf("%f\r", valeur);fflush(stdout);
          if (strstr(tmp,"100%") != NULL) {
            fgets(tmp, 100, filename); lentmp = strlen(tmp);
            if (strncmp(tmp,"Processing",10) == 0) FlagStop = 1;
            }
          } else {
          FlagStop = 1;
          }
       }
    fclose(filename);
    wait(30);
    }

  return 1;
}

/********************************************************************
*********************************************************************
*********************************************************************
********************************************************************/
void wait ( int seconds )
{
  clock_t endwait;
  endwait = clock () + seconds * CLOCKS_PER_SEC ;
  while (clock() < endwait) {}

}
