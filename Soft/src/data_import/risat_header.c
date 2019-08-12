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

File   : risat_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 01/2013
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

Description :  Read Leader and Image CEOS files

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
unsigned long htonl( unsigned long x );


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
  char FileLeader[FilePathLength], FileImage[FilePathLength], FileOutput[FilePathLength];
  char Tmp[32768], CalibFactor[16];
  char DataRecordLength[6], PrefixRecordLength[4];
//  float FactorCalib;
  unsigned int LengthRecord, LengthRecordData, LengthRecordPrefix;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nrisat_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ilf 	input leader file\n");
strcat(UsageHelp," (string)	-iif 	input image file\n");
strcat(UsageHelp," (string)	-ocf 	output PolSARpro config file\n");
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
  get_commandline_prm(argc,argv,"-ilf",str_cmd_prm,FileLeader,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iif",str_cmd_prm,FileImage,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ocf",str_cmd_prm,FileOutput,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileLeader);
  check_file(FileImage);
  check_file(FileOutput);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/* INPUT LEADER FILE */
/*******************************************************************/

  if ((filename = fopen(FileLeader, "rb")) == NULL)
    edit_error("Could not open output file : ", FileLeader);

  //Description Record
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);
  
  //Data Set Summary
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Data Quality Summary
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Signal Data Histogram
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Processed Data
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Processing Parameters
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Map Projection Data
  //fread(&Tmp[0],sizeof(char), 8, filename);
  //fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  //fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Platform Position Data
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Altitude Data
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  fread(&Tmp[0],sizeof(char), htonl(LengthRecord) - 12, filename);

  //Radiometric Data
  fread(&Tmp[0],sizeof(char), 8332, filename);
  fread(&CalibFactor[0],sizeof(char), 16, filename);
//  FactorCalib = atof(CalibFactor);

  fclose(filename);

/*******************************************************************/
/* INPUT LEADER FILE */
/*******************************************************************/

  if ((filename = fopen(FileImage, "rb")) == NULL)
    edit_error("Could not open output file : ", FileImage);

  rewind(filename);
  fread(&Tmp[0],sizeof(char), 8, filename);
  fread(&LengthRecord,sizeof(unsigned int), 1, filename);
  LengthRecord = htonl(LengthRecord);
  
  rewind(filename);
  fread(&Tmp[0],sizeof(char), 186, filename);
  fread(&DataRecordLength[0],sizeof(char), 6, filename);
  LengthRecordData = atoi(DataRecordLength);

  rewind(filename);
  fread(&Tmp[0],sizeof(char), 276, filename);
  fread(&PrefixRecordLength[0],sizeof(char), 6, filename);
  LengthRecordPrefix = atoi(PrefixRecordLength);

  fclose(filename);
 
/*******************************************************************/
/* WRITE OUTPUT FILE */
/*******************************************************************/

  if ((filename = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open output file : ", FileOutput);

  fprintf(filename, "header_length\n");
  fprintf(filename, "%d\n", LengthRecord);
  fprintf(filename, "---------\n");
  fprintf(filename, "prefix_length\n");
  fprintf(filename, "%d\n", LengthRecordPrefix);
  fprintf(filename, "---------\n");
  fprintf(filename, "record_length\n");
  fprintf(filename, "%d\n", LengthRecordData);

  fclose(filename);
  
  return 1;
}

/*******************************************************************/
/*******************************************************************/

unsigned long htonl( unsigned long x )
{
  union {
    unsigned long x;
    unsigned char b[4];
  } y;
  unsigned char tmp;

  y.x = x;

  tmp = y.b[0];
  y.b[0] = y.b[3];
  y.b[3] = tmp;
  tmp = y.b[1];
  y.b[1] = y.b[2];
  y.b[2] = tmp;

  return ( y.x );
} /* End of htonl */