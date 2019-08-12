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

File   : topsar_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Read Header of TOPSAR Auxiliary Data Files

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
char *check_nul(char *buf);

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
  FILE *fileinput, *fileoutput;
  char FileInput[FilePathLength], ConfigFile[FilePathLength];
  char tmp[100], buf[100], header[100];

  int Nlig, Ncol;
  long unsigned int kl, OffsetData, OffsetCal, OffsetDem;
  float ProcessVer, GenFac, DEMIncr, DEMOffset;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntopsar_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input data file\n");
strcat(UsageHelp," (string)	-of  	output config file\n");
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
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,ConfigFile,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(ConfigFile);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* INPUT BINARY STK DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);
  if ((fileoutput = fopen(ConfigFile, "w")) == NULL)
  edit_error("Could not open configuration file : ",ConfigFile);

  OffsetData = 0; OffsetCal = 0; OffsetDem = 0;
  rewind(fileinput);
  fgets(header, 51, fileinput);
   strncpy(tmp, &header[0], 22);  tmp[22] = '\0';
  if (strcmp(tmp,"RECORD LENGTH IN BYTES") != 0)
    {
    fprintf(fileoutput, "NO_HEADER\n");
    fclose(fileoutput);
    } else {
    rewind(fileinput);
    fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
    fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
    fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
    strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; ProcessVer = atof(tmp);
    if (ProcessVer < 5.00) 
      {
      fprintf(fileoutput, "HEADER_ERROR\n");
      fclose(fileoutput);
      } else {
      fprintf(fileoutput, "HEADER_OK\n");
      rewind(fileinput);
      fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; Ncol = atoi(tmp);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; Nlig = atoi(tmp);
      fgets(buf, 51, fileinput); fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); 
      fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetData = atol(tmp);
      fgets(buf, 51, fileinput); 
      fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetCal = atol(tmp);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetDem = atol(tmp);
      GenFac = 1.;
      if (OffsetCal != 0) 
      {      rewind(fileinput);
          for (kl = 0; kl < OffsetCal; kl++) fgets(buf, 2, fileinput);
          fgets(buf, 51, fileinput);
          fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; GenFac = pow(10.,atof(tmp)/10.);
      }
      DEMIncr = 1.; DEMOffset = 0.;
      if (OffsetDem != 0) 
      {      rewind(fileinput);
          for (kl = 0; kl < OffsetDem; kl++) fgets(buf, 2, fileinput);
          fgets(buf, 51, fileinput);fgets(buf, 51, fileinput);fgets(buf, 51, fileinput);
          fgets(buf, 51, fileinput);fgets(buf, 51, fileinput);fgets(buf, 51, fileinput);
          fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; DEMIncr = atof(tmp);
          fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; DEMOffset = atof(tmp);
      }

      fprintf(fileoutput, "nlig\n");
      fprintf(fileoutput, "%i\n", Nlig);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "ncol\n");
      fprintf(fileoutput, "%i\n", Ncol);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "gen_fac\n");
      fprintf(fileoutput, "%f\n", GenFac);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "Offset_Data\n");
      fprintf(fileoutput, "%li\n", OffsetData);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "DEM_Increment\n");
      fprintf(fileoutput, "%f\n", DEMIncr);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "DEM_Offset\n");
      fprintf(fileoutput, "%f\n", DEMOffset);
      fclose(fileoutput);
      }
    }

  return 1;
}

/******************************************************************/
/******************************************************************/
/*                ROUTINES DECLARATION              */
/******************************************************************/
/******************************************************************/

/*******************************************************************
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  check if there exists a "nul" and change it to "space"
*--------------------------------------------------------------------
Inputs arguments :
buf : string to be checked
Returned values  :
buf : string checked
********************************************************************/
char *check_nul(char *buf)
{
  int N, i;

  N = 50;
  for (i = 0; i < N; i++)
    if ( buf[i] == '\0' ) buf[i] = '\x20';
  return (buf);
}
