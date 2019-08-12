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

File   : airsar_header.c
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

Description :  Read Header of AIRSAR & TOPSAR Data Files (Format MLC)

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

/* ALIASES  */

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

char *check_nul(char *buf);

/* ACCESS FILE */
FILE *fileinput;
FILE *fileoutput;

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

  char FileInput[FilePathLength], ConfigFile[FilePathLength], HeaderFile[FilePathLength], ParaFile[FilePathLength];
  char CalibFile[FilePathLength], DEMFile[FilePathLength];
  char processor[100], dataformat[100], datatype[100];
  char tmp[100], buf[100], header[100];

  int i, Nlig, Ncol, Error;
  long unsigned int kl, OffsetOld, OffsetData, OffsetPar, OffsetCal, OffsetDem;
  float ProcessVer, GenFac;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nairsar_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-idf  input data file\n");
strcat(UsageHelp," (string)	-ocf  output config file\n");
strcat(UsageHelp," (string)	-ohf  output header file\n");
strcat(UsageHelp," (string)	-opf  output parameter file\n");
strcat(UsageHelp," (string)	-okf  output calibration file\n");
strcat(UsageHelp," (string)	-odf  output DEM file\n");
strcat(UsageHelp," (string)	-pro  processor\n");
strcat(UsageHelp," (string)	-df  data format\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help  displays this message\n");

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,ConfigFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ohf",str_cmd_prm,HeaderFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-opf",str_cmd_prm,ParaFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-okf",str_cmd_prm,CalibFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,DEMFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pro",str_cmd_prm,processor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-df",str_cmd_prm,dataformat,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);
  }

/********************************************************************
********************************************************************/

  check_file(FileInput);
  check_file(ConfigFile);
  check_file(HeaderFile);
  check_file(ParaFile);
  check_file(CalibFile);
  check_file(DEMFile);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
/* INPUT BINARY STK DATA FILE */
/********************************************************************
********************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);
  if ((fileoutput = fopen(ConfigFile, "w")) == NULL)
  edit_error("Could not open configuration file : ",ConfigFile);

  OffsetOld = 0; OffsetData = 0; OffsetPar = 0; OffsetCal = 0; OffsetDem = 0;
  rewind(fileinput);
  fgets(header, 51, fileinput);
  strncpy(tmp, &header[0], 22);  tmp[22] = '\0';

  if (strcmp(tmp,"RECORD LENGTH IN BYTES") != 0)
    {
    fprintf(fileoutput, "NO_HEADER\n");
    fclose(fileoutput);
    } else {
    Error = 0;
    rewind(fileinput);
    fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
    fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
    fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
    strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; ProcessVer = atof(tmp);
    fgets(datatype, 51, fileinput); datatype[51] = '\0';

    if ((strcmp(processor,"old") == 0)&&(ProcessVer > 5.00)) Error = 1;
    if ((strcmp(processor,"old") != 0)&&(ProcessVer < 5.00)) Error = 1;

    if (strcmp(dataformat,"SLC") == 0)
      {
      if (strcmp(datatype,"DATA TYPE =           SCATTERING MATRIX COMPRESSED") != 0)
       {
       if (Error == 0) Error = 2;
       else Error = 3;
       }
      }
    if (strcmp(dataformat,"MLC") == 0)
      {
      if ((strcmp(datatype,"DATA TYPE =                             COMPRESSED") != 0) &&
          (strcmp(datatype,"DATA TYPE =                      AIRSAR COMPRESSED") != 0))
       {
       if (Error == 0) Error = 2;
       else Error = 3;
       }
      }
    if (Error != 0)
      {
      fprintf(fileoutput, "HEADER_ERROR\n");
      fprintf(fileoutput, "%i\n",Error);
      fprintf(fileoutput, "Processor Version %f (%s)\n",ProcessVer,processor);
      fprintf(fileoutput, "Data Format %s (%s)\n",datatype,dataformat);
      fclose(fileoutput);
      } else {
      fprintf(fileoutput, "HEADER_OK\n");
      rewind(fileinput);
      fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; Ncol = atoi(tmp);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; Nlig = atoi(tmp);
      fgets(buf, 51, fileinput); fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetOld = atol(tmp);
      fgets(buf, 51, fileinput);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetData = atol(tmp);
      fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetPar = atol(tmp);
      if (strcmp(processor,"old") != 0)
       {
       fgets(buf, 51, fileinput);
       fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetCal = atol(tmp);
       fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; OffsetDem = atol(tmp);
       }
      if (strcmp(processor,"old") == 0)
       {
       rewind(fileinput);
       if (strcmp(header,"RECORD LENGTH IN BYTES =                     10240") == 0) for (kl = 0; kl < 16640; kl++) fgets(buf, 2, fileinput);
       if (strcmp(header,"RECORD LENGTH IN BYTES =                      2560") == 0) for (kl = 0; kl < 8960; kl++) fgets(buf, 2, fileinput);
       fgets(buf, 51, fileinput); fgets(buf, 51, fileinput); fgets(buf, 51, fileinput); fgets(buf, 51, fileinput);
       fgets(buf, 51, fileinput); strncpy(tmp, &buf[30], 16); tmp[16] = '\0'; GenFac = atof(tmp);
       } else {
       rewind(fileinput);
       for (kl = 0; kl < OffsetCal; kl++) fgets(buf, 2, fileinput);
       fgets(buf, 51, fileinput);
       fgets(buf, 51, fileinput); strncpy(tmp, &buf[40], 10); tmp[10] = '\0'; GenFac = pow(10.,atof(tmp)/10.);
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
      fprintf(fileoutput, "Offset_Old\n");
      fprintf(fileoutput, "%li\n", OffsetOld);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "Offset_Para\n");
      fprintf(fileoutput, "%li\n", OffsetPar);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "Offset_Cal\n");
      fprintf(fileoutput, "%li\n", OffsetCal);
      fprintf(fileoutput, "---------\n");
      fprintf(fileoutput, "Offset_Dem\n");
      fprintf(fileoutput, "%li\n", OffsetDem);
      fclose(fileoutput);
      }
    }

  if (Error == 0)
    {
    rewind(fileinput);
    if ((fileoutput = fopen(HeaderFile, "w")) == NULL)
    edit_error("Could not open configuration file : ",HeaderFile);
    for (i=0; i<20; i++)
      {
      fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
      }
    fclose(fileoutput);
    if (strcmp(processor,"old") == 0)
      {
      if ((fileoutput = fopen(ParaFile, "w")) == NULL)
      edit_error("Could not open configuration file : ",ParaFile);
      rewind(fileinput);
      for (kl = 0; kl < OffsetOld; kl++) fgets(buf, 2, fileinput);
      if (strcmp(header,"RECORD LENGTH IN BYTES =                     10240") == 0)
       {
       for (i=0; i<64; i++)
         {
         fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
         }
       rewind(fileinput);
       for (kl = 0; kl < 16640; kl++) fgets(buf, 2, fileinput);
       }
      if (strcmp(header,"RECORD LENGTH IN BYTES =                      2560") == 0)
       {
       for (i=0; i<54; i++)
         {
         fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
         }
       rewind(fileinput);
       for (kl = 0; kl < 8960; kl++) fgets(buf, 2, fileinput);
       }
      fprintf(fileoutput,"**************************************************\n");
      for (i=0; i<9; i++)
       {
       fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
       }
      fclose(fileoutput);
      }

    if (strcmp(processor,"old") != 0)
      {
      if ((fileoutput = fopen(ParaFile, "w")) == NULL)
      edit_error("Could not open configuration file : ",ParaFile);
      rewind(fileinput);
      for (kl = 0; kl < OffsetPar; kl++) fgets(buf, 2, fileinput);
      for (i=0; i<100; i++)
       {
       fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
       }
      fclose(fileoutput);
      if (OffsetCal != 0)
       {
       if ((fileoutput = fopen(CalibFile, "w")) == NULL)
       edit_error("Could not open configuration file : ",CalibFile);
       rewind(fileinput);
       for (kl = 0; kl < OffsetCal; kl++) fgets(buf, 2, fileinput);
       for (i=0; i<17; i++)
        {
        fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
        }
       fclose(fileoutput);
       }
      if (OffsetDem != 0)
       {
       if ((fileoutput = fopen(DEMFile, "w")) == NULL)
       edit_error("Could not open configuration file : ",DEMFile);
       rewind(fileinput);
       for (kl = 0; kl < OffsetDem; kl++) fgets(buf, 2, fileinput);
       for (i=0; i<21; i++)
        {
        fread(&buf[0], sizeof(char), 50, fileinput); buf[50] = '\0'; check_nul(buf); fprintf(fileoutput,"%s\n",buf);
        }
       fclose(fileoutput);
       }
      }

    }

  return 1;
}

/********************************************************************
*********************************************************************
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
