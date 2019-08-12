/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************


File   : asar_AP_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.2
Creation : 03/2003
Update  :


*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------

Description :  Read Header of ASAR-AP Files

*-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_file(char *file);
void check_dir(char *dir);

*******************************************************************************/
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
#include "../lib/graphics.h"
#include "../lib/matrix.h"
#include "../lib/processing.h"
#include "../lib/util.h"

void ReadHEADER_MPH_SPH(FILE * fileinput, FILE * fileoutput,
      FILE * fileoutput2);
void ReadHEADER_SQxADSRs(int channel, int Num_DSR, int RSize);
void ReadHEADER_MPP(int Num_DSR, int RSize);
void ReadHEADER_DCP(int Num_DSR, int RSize);
void ReadHEADER_CP(int Num_DSR, int RSize);
void ReadHEADER_GGA(int Num_DSR, int RSize);
void ReadHEADER_SRGR(int Num_DSR, int RSize);
void ReadHEADER_AEPxADSRs(int channel, int Num_DSR, int RSize);
void ReadHEADER_MPG(int Num_DSR, int RSize);

void Extract_HEADER(FILE * fileinput, unsigned int Offset, int Size);

void MJD_Date(unsigned int MJD, int *Day, int *Month, int *Year);
void MJD_Time(unsigned int MJD, int *Hour, int *Minute, int *Second);


/* CHARACTER STRINGS */
char CS_Texterreur[80];
char DirOutput[FilePathLength];
char FileAsarConfig[FilePathLength];
char FileAsarHeaderTxt[FilePathLength];
char FileAsarHeaderBin[FilePathLength];

/* ACCESS FILE */
FILE *fileinput;
FILE *fileheader;
FILE *fileheader2;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------

Description :  Read Header of ASAR-AP Files

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
void
*******************************************************************************/

int main(int argc, char *argv[])
/*                                      */
{

/* LOCAL VARIABLES */

  char FileInput[FilePathLength], FileHeader[FilePathLength], FileHeader2[FilePathLength], Buf[100];

  int ii;
  int NumHeader, Size, Num_DSR, RSize;
  unsigned int Offset;
  char DS_NAME[FilePathLength];

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 6) {
  strcpy(FileInput, argv[1]);
  strcpy(DirOutput, argv[2]);
  strcpy(FileAsarConfig, argv[3]);
  strcpy(FileAsarHeaderTxt, argv[4]);
  strcpy(FileAsarHeaderBin, argv[5]);
  } else {
  printf("TYPE: asar_AP_header  FileInput DirOutput ConfigFile HeaderTxtFile HeaderBinFile\n");
  exit(1);
  }

  check_file(FileInput);
  check_dir(DirOutput);
  check_file(FileAsarConfig);
  check_file(FileAsarHeaderTxt);
  check_file(FileAsarHeaderBin);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  if ((fileinput = fopen(FileInput, "r")) == NULL)
  edit_error("Could not open input file : ", FileInput);

/******************************************************************************/
/* EXTRACT MPH & SPH HEADERS and SAVE CONFIG PARAMETERS to TMP/Asar_Config.txt*/
/******************************************************************************/
  sprintf(FileHeader, "%s%s", DirOutput, "MPH.hdr");
  if ((fileheader = fopen(FileHeader, "w")) == NULL)
  edit_error("Could not open configuration file MPH : ", FileHeader);
  sprintf(FileHeader2, "%s%s", DirOutput, "SPH.hdr");
  if ((fileheader2 = fopen(FileHeader2, "w")) == NULL)
  edit_error("Could not open configuration file SPH : ", FileHeader2);
  ReadHEADER_MPH_SPH(fileinput, fileheader, fileheader2);
  fclose(fileheader);
  fclose(fileheader2);

  if ((fileheader = fopen(FileAsarConfig, "r")) == NULL)
  edit_error("Could not open configuration file CONFIG : ",FileAsarConfig);
  for (ii = 0; ii < 16; ii++)
  fgets(&Buf[0], 100, fileheader);
  fscanf(fileheader, "%i\n", &NumHeader);
  fclose(fileheader);

  if ((fileheader = fopen(FileAsarHeaderTxt, "r")) == NULL)
  edit_error("Could not open configuration file HEADER.TXT : ",FileAsarHeaderTxt);


  for (ii = 0; ii < NumHeader; ii++) {
  fgets(&DS_NAME[0], 28, fileheader);
  fscanf(fileheader, "%u\n", &Offset);
  fscanf(fileheader, "%i\n", &Size);
  fscanf(fileheader, "%i\n", &Num_DSR);
  fscanf(fileheader, "%i\n", &RSize);

  Extract_HEADER(fileinput, Offset, Size);

  if (strcmp(DS_NAME, "MDS1 SQ ADS        ") == 0)
    ReadHEADER_SQxADSRs(1, Num_DSR, RSize);
  if (strcmp(DS_NAME, "MDS2 SQ ADS        ") == 0)
    ReadHEADER_SQxADSRs(2, Num_DSR, RSize);
  if (strcmp(DS_NAME, "MAIN PROCESSING PARAMS ADS ") == 0)
    ReadHEADER_MPP(Num_DSR, RSize);
  if (strcmp(DS_NAME, "DOP CENTROID COEFFS ADS  ") == 0)
    ReadHEADER_DCP(Num_DSR, RSize);
  if (strcmp(DS_NAME, "CHIRP PARAMS ADS      ") == 0)
    ReadHEADER_CP(Num_DSR, RSize);
  if (strcmp(DS_NAME, "GEOLOCATION GRID ADS    ") == 0)
    ReadHEADER_GGA(Num_DSR, RSize);
  if (strcmp(DS_NAME, "SR GR ADS          ") == 0)
    ReadHEADER_SRGR(Num_DSR, RSize);
  if (strcmp(DS_NAME, "MDS1 ANTENNA ELEV PATT ADS ") == 0)
    ReadHEADER_AEPxADSRs(1, Num_DSR, RSize);
  if (strcmp(DS_NAME, "MDS2 ANTENNA ELEV PATT ADS ") == 0)
    ReadHEADER_AEPxADSRs(2, Num_DSR, RSize);
  if (strcmp(DS_NAME, "MAP PROJECTION GADS    ") == 0)
    ReadHEADER_MPG(Num_DSR, RSize);
  }

  fclose(fileinput);

  return 1;
}

/*******************************************************************************
Routine  : ReadHEADER_MPH_SPH
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the MPH and SPH Headers of a ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void
ReadHEADER_MPH_SPH(FILE * fileinput, FILE * fileoutput, FILE * fileoutput2)
{
  int ii;
  int Num_DSD, Num_DSR, Size, RSize, NumHeader;
  unsigned int Offset;
  char Buf[FilePathLength], Tmp[FilePathLength];
  char DS_NAME[FilePathLength], DS_OFFSET[FilePathLength], DS_SIZE[FilePathLength], DS_NUM_DSR[FilePathLength],
  DSR_SIZE[FilePathLength];

  FILE *fileconfig, *fileheader;

  if ((fileconfig = fopen(FileAsarConfig, "w")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarConfig);
  if ((fileheader = fopen(FileAsarHeaderTxt, "w")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderTxt);

  rewind(fileinput);
//"*****************************************************************");
//"              M.P.H HEADER              ");
//"*****************************************************************");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 62);
  fprintf(fileoutput, "PRODUCT = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 1);
  fprintf(fileoutput, "PROC_STAGE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 23);
  fprintf(fileoutput, "REF_DOC = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[21], 20);
  fprintf(fileoutput, "ACQUISITION_STATION = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[13], 6);
  fprintf(fileoutput, "PROC_CENTER = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 27);
  fprintf(fileoutput, "PROC_TIME = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 14);
  fprintf(fileoutput, "SOFTWARE_VERSION = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 27);
  fprintf(fileoutput, "SENSING_START = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 27);
  fprintf(fileoutput, "SENSING_STOP = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[6], 1);
  fprintf(fileoutput, "PHASE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[6], 4);
  fprintf(fileoutput, "CYCLE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[10], 6);
  fprintf(fileoutput, "REL_ORBIT = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[10], 6);
  fprintf(fileoutput, "ABS_ORBIT = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[19], 27);
  fprintf(fileoutput, "STATE_VECTOR_TIME = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[10], 8);
  fprintf(fileoutput, "DELTA_UT1 = %s (s)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 12);
  fprintf(fileoutput, "X_POSITION = %s (m)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 12);
  fprintf(fileoutput, "Y_POSITION = %s (m)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 12);
  fprintf(fileoutput, "Z_POSITION = %s (m)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 12);
  fprintf(fileoutput, "X_VELOCITY = %s (m/s)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 12);
  fprintf(fileoutput, "Y_VELOCITY = %s (m/s)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 12);
  fprintf(fileoutput, "Z_VELOCITY = %s (m/s)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 2);
  fprintf(fileoutput, "VECTOR_SOURCE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 27);
  fprintf(fileoutput, "UTC_SBT_TIME = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[16], 11);
  fprintf(fileoutput, "SAT_BINARY_TIME = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 11);
  fprintf(fileoutput, "CLOCK_STEP = %s (ps)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[10], 27);
  fprintf(fileoutput, "LEAP_UTC = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[10], 4);
  fprintf(fileoutput, "LEAP_SIGN = %s (s)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 1);
  fprintf(fileoutput, "LEAP_ERR = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[12], 1);
  fprintf(fileoutput, "PRODUCT_ERR = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 21);
  fprintf(fileoutput, "TOT_SIZE = %s (bytes)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 11);
  fprintf(fileoutput, "SPH_SIZE = %s (bytes)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[8], 11);
  fprintf(fileoutput, "NUM_DSD = %s\n", Tmp);
  strncpy(Tmp, &Buf[10], 10);
  Num_DSD = atoi(Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[9], 11);
  fprintf(fileoutput, "DSD_SIZE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 11);
  fprintf(fileoutput, "NUM_DATA_SETS = %s\n", Tmp);

  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");

//"*****************************************************************");
//"              S.P.H HEADER              ");
//"*****************************************************************");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[16], 28);
  fprintf(fileoutput2, "SPH_DESCRIPTOR = %s\n", Tmp);
  fprintf(fileconfig, "%s", &Buf[0]);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[31], 4);
  fprintf(fileoutput2, "STRIPLINE_CONTINUITY_INDICATOR = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 4);
  fprintf(fileoutput2, "SLICE_POSITION = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 4);
  fprintf(fileoutput2, "NUM_SLICES = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[17], 27);
  fprintf(fileoutput2, "FIRST_LINE_TIME = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[16], 27);
  fprintf(fileoutput2, "LAST_LINE_TIME = %s (UTC)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 11);
  fprintf(fileoutput2, "FIRST_NEAR_LAT = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[16], 11);
  fprintf(fileoutput2, "FIRST_NEAR_LONG = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 11);
  fprintf(fileoutput2, "FIRST_MID_LAT = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 11);
  fprintf(fileoutput2, "FIRST_MID_LONG = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 11);
  fprintf(fileoutput2, "FIRST_FAR_LAT = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 11);
  fprintf(fileoutput2, "FIRST_FAR_LONG = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 11);
  fprintf(fileoutput2, "LAST_NEAR_LAT = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[15], 11);
  fprintf(fileoutput2, "LAST_NEAR_LONG = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[13], 11);
  fprintf(fileoutput2, "LAST_MID_LAT = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 11);
  fprintf(fileoutput2, "LAST_MID_LONG = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[13], 11);
  fprintf(fileoutput2, "LAST_FAR_LAT = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 11);
  fprintf(fileoutput2, "LAST_FAR_LONG = %s (micro deg)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput2, "\n");
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[7], 3);
  fprintf(fileoutput2, "SWATH = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[6], 10);
  fprintf(fileoutput2, "PASS = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[13], 8);
  fprintf(fileoutput2, "SAMPLE_TYPE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 7);
  fprintf(fileoutput2, "ALGORITHM = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[18], 3);
  fprintf(fileoutput2, "MDS1_TX_RX_POLAR = %s\n", Tmp);
  fprintf(fileconfig, "%s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[18], 3);
  fprintf(fileoutput2, "MDS2_TX_RX_POLAR = %s\n", Tmp);
  fprintf(fileconfig, "%s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[13], 5);
  fprintf(fileoutput2, "COMPRESSION = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 4);
  fprintf(fileoutput2, "AZIMUTH_LOOKS = %s (Looks)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[12], 4);
  fprintf(fileoutput2, "RANGE_LOOKS = %s (Looks)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[14], 15);
  fprintf(fileoutput2, "RANGE_SPACING = %s (m)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[16], 15);
  fprintf(fileoutput2, "AZIMUTH_SPACING = %s (m)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[19], 15);
  fprintf(fileoutput2, "LINE_TIME_INTERVAL = %s (s)\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[12], 6);
  fprintf(fileoutput2, "LINE_LENGTH = %s (samples)\n", Tmp);
  fprintf(fileconfig, "Ncol\n");
  fprintf(fileconfig, "%i\n", atoi(Tmp));
  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[11], 5);
  fprintf(fileoutput2, "DATA_TYPE = %s\n", Tmp);
  fgets(&Buf[0], 100, fileinput);
  fprintf(fileoutput, "\n");

  NumHeader = 0;
  for (ii = 0; ii < Num_DSD; ii++) {
  strcpy(DS_NAME, "");
  strcpy(DS_OFFSET, "");
  strcpy(DS_SIZE, "");
  strcpy(DS_NUM_DSR, "");
  strcpy(DSR_SIZE, "");
  Offset = 0;
  Size = 0;
  Num_DSR = 0;
  RSize = 0;

  fgets(&Buf[0], 100, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], strlen(Buf) - strlen(strchr(Buf, '=')));
  strcpy(DS_NAME, "");
  strncat(DS_NAME, &Buf[strlen(Buf) - strlen(strchr(Buf, '=')) + 2],
    28);

  fgets(&Buf[0], 100, fileinput);
  fgets(&Buf[0], 100, fileinput);

  fgets(&Buf[0], 100, fileinput);
  strcpy(DS_OFFSET, "");
  strncat(DS_OFFSET,
    &Buf[strlen(Buf) - strlen(strchr(Buf, '=')) + 1],
    strlen(strchr(Buf, '=')) - strlen(strchr(Buf, '=')) - 1);
  Offset = atoi(DS_OFFSET);

  fgets(&Buf[0], 100, fileinput);
  strcpy(DS_SIZE, "");
  strncat(DS_SIZE, &Buf[strlen(Buf) - strlen(strchr(Buf, '=')) + 1],
    strlen(strchr(Buf, '=')) - strlen(strchr(Buf, '=')) - 1);
  Size = atoi(DS_SIZE);

  fgets(&Buf[0], 100, fileinput);
  strcpy(DS_NUM_DSR, "");
  strncat(DS_NUM_DSR,
    &Buf[strlen(Buf) - strlen(strchr(Buf, '=')) + 1], 11);
  Num_DSR = atol(DS_NUM_DSR);

  fgets(&Buf[0], 100, fileinput);
  strcpy(DSR_SIZE, "");
  strncat(DSR_SIZE, &Buf[strlen(Buf) - strlen(strchr(Buf, '=')) + 1],
    strlen(strchr(Buf, '=')) - strlen(strchr(Buf, '=')) - 1);
  RSize = atoi(DSR_SIZE);

  fgets(&Buf[0], 100, fileinput);

  if (Offset != 0) {
    if ((strcmp(DS_NAME, "MDS1            ") == 0)
    || (strcmp(DS_NAME, "MDS2            ") == 0)) {
    fprintf(fileconfig, "%s\n", DS_NAME);
    fprintf(fileconfig, "Offset\n");
    fprintf(fileconfig, "%u\n", Offset);
    fprintf(fileconfig, "Nlig\n");
    fprintf(fileconfig, "%i\n", Num_DSR);
    } else {
    NumHeader++;
    fprintf(fileheader, "%s\n", DS_NAME);
    fprintf(fileheader, "%u\n", Offset);
    fprintf(fileheader, "%i\n", Size);
    fprintf(fileheader, "%i\n", Num_DSR);
    fprintf(fileheader, "%i\n", RSize);
    }
  }
  }
  fprintf(fileconfig, "NumHeader\n%i\n", NumHeader);
  fclose(fileconfig);
  fclose(fileheader);

}

/*******************************************************************************
Routine  : ReadHEADER_SQxADSRs
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the SQxADSRs Header of a ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_SQxADSRs(int channel, int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii;
  char Buf[FilePathLength];
  char *BufF;
  char *BufI;
  int BufFlag;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1) {
    if (channel == 1)
    sprintf(FileOutput, "%s%s", DirOutput, "SQ1ADSRs.hdr");
    if (channel == 2)
    sprintf(FileOutput, "%s%s", DirOutput, "SQ2ADSRs.hdr");
  } else {
    if (channel == 1)
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"SQ1ADSRs_Record", ii + 1, ".hdr");
    if (channel == 2)
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"SQ2ADSRs_Record", ii + 1, ".hdr");
  }

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"****************************************************************");
//"             SQx ADSRs HEADER            ");
//"****************************************************************");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\tZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tATTACH_FLAG = %i\n", BufFlag);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "PRODUCT CONFIDENCE FLAGS\n");
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_MEAN_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_STD_DEV_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_GAPS_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_MISSING_LINES_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tDOP_CEN_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tDOP_AMB_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tOUTPUT_MEAN_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tOUTPUT_STD_DEV_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tCHIRP_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tMISSING_DATA_SETS_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tINVALID_DOWNLINK_FLAG = %i\n", BufFlag);
  fgets(&Buf[0], 8, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "THRESHOLD INFORMATION\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_CHIRP_BROADENING = %6.2f\n",
    BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_CHIRP_SIDELOBE = %6.2f (dB)\n",
    BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_CHIRP_ISLR = %6.2f (dB)\n",
    BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_INPUT_MEAN = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tEXP_INPUT_MEAN = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_INPUT_STD_DEV = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tEXP_INPUT_STD_DEV = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_DOP_CEN = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_DOP_AMB = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_OUTPUT_MEAN = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tEXP_OUTPUT_MEAN = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_OUTPUT_STD_DEV = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tEXP_OUTPUT_STD_DEV = %6.2f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_INPUT_MISSING_LINES = %6.2f\n",
    BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTHRESH_INPUT_GAPS = %6.2f\n", BufFloat);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\tLINES_PER_GAPS = %u (lines)\n", BufInt);
  fgets(&Buf[0], 16, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "OTHER QUALITY INFORMATION\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_MEAN_I = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_MEAN_Q = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_STD_DEV_I = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tINPUT_STD_DEV_Q = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tNUM_GAPS = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tNUM_MISSING_LINES = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tOUTPUT_MEAN_I = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tOUTPUT_MEAN_Q = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tOUTPUT_STD_DEV_I = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tOUTPUT_STD_DEV_Q = %f\n", BufFloat);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\tTOT_ERRORS = %u\n", BufInt);
  fgets(&Buf[0], 17, fileinput);

  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_MPP
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Main Processing Parameters (MPP) Header of a
ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_MPP(int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii, k, l;
  char Buf[FilePathLength], Tmp[FilePathLength];
  char *BufF, *BufI, *BufFl;
  int BufFlag, BufI0, BufI1;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;
  BufFl = (char *) &BufFlag;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1)
    sprintf(FileOutput, "%s%s", DirOutput,"MainProcessingParameters.hdr");
  else
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"MainProcessingParameters_Record", ii + 1, ".hdr");

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"****************************************************************");
//"*        MAIN PROCESSING PARAMETERS HEADER        ");
//"****************************************************************");
  fprintf(fileoutput, "GENERAL SUMMARY\n");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "FIRST_ZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
   BufFlag = getc(fileinput);
  fprintf(fileoutput, "ATTACH_FLAG = %i\n", BufFlag);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "LAST_ZERO_DOPPLER_TIME Seconds= %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  fgets(&Buf[0], 13, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 12);
  fprintf(fileoutput, "WORK_ORDER_ID = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "TIME_DIFF = %f\n", BufFloat);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "SWATH_ID = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "RANGE_SPACING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "AZIMUTH_SPACING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "LINE_TIME_INTERVAL = %f\n", BufFloat);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "NUM_OUTPUT_LINES = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "NUM_SAMPLES_PER_LINE = %u\n", BufInt);
  fgets(&Buf[0], 6, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 5);
  fprintf(fileoutput, "DATA_TYPE = %s\n", Tmp);
  fgets(&Buf[0], 52, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "IMAGE PROCESSING SUMMARY\n");
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tDATA_ANALYSIS_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tANT_ELEV_CORR_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tCHIRP_EXTRACT_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tSRGR_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tDOP_CEN_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tDOP_AMB_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tRANGE_SPREAD_COMP_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tDETECTED_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tLOOK_SUM_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tRMS_EQUAL_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tANT_SCAL_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tVGA_COM_ECHO_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tVGA_COM_CAL_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tVGA_COM_NOM_TIME_FLAG = %i\n", BufFlag);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tGM_RANGE_COMP_INV_FILT_FLAG = %i\n",
    BufFlag);
  fgets(&Buf[0], 7, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "RAW DATA ANALYSIS INFORMATION\n");
  for (k = 0; k < 2; k++) {
    fprintf(fileoutput, "\tRAW_DATA_ANALYSIS[%i]\n", k);
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tNUM_GAPS = %u\n", BufInt);
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tNUM_MISSING_LINES = %u\n", BufInt);
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tRANGE_SAMP_SKIP = %u\n", BufInt);
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tRANGE_LINES_SKIP = %u\n", BufInt);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tCALC_I_BIAS = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tCALC_Q_BIAS = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tCALC_I_STD_DEV = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tCALC_Q_STD_DEV = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tCALC_GAIN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tCALC_QUAD = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tI_BIAS_MAX = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tI_BIAS_MIN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tQ_BIAS_MAX = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tQ_BIAS_MIN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tGAIN_MIN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tGAIN_MAX = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tQUAD_MIN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tQUAD_MAX = %f\n", BufFloat);
    BufFlag = getc(fileinput);
    fprintf(fileoutput, "\t\tI_BIAS_FLAG = %i\n", BufFlag);
    BufFlag = getc(fileinput);
    fprintf(fileoutput, "\t\tQ_BIAS_FLAG = %i\n", BufFlag);
    BufFlag = getc(fileinput);
    fprintf(fileoutput, "\t\tGAIN_FLAG = %i\n", BufFlag);
    BufFlag = getc(fileinput);
    fprintf(fileoutput, "\t\tQUAD_FLAG = %i\n", BufFlag);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tUSED_I_BIAS = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tUSED_Q_BIAS = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tUSED_GAIN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tUSED_QUAD = %f\n", BufFloat);
  }
  fgets(&Buf[0], 33, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "DOWNLINK HEADER INFORMATION\n");
  for (k = 0; k < 2; k++) {
    fprintf(fileoutput, "\tSTART_TIME[%i]\n", k);
    for (l = 0; l < 2; l++) {
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tFIRST_OBT[%i] = %u\n", l, BufInt);
    }
    BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
    MJD_Date(BufInt,&Day,&Month,&Year);
    BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
    MJD_Time(BufInt,&Hour,&Minute,&Second);
    BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tFIRST_MJD = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  }
  fprintf(fileoutput, "\tPARAMETERS_CODES\n");
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tSWST_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tLAST_SWST_CODE[%i] = %u\n", k,
      BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tPRI_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tTX_PULSE_LEN_CODE[%i] = %u\n", k,
      BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tTX_BW_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tECHO_WIN_LEN_CODE[%i] = %u\n", k,
      BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tUP_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tDOWN_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tRESAMP_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tBEAM_ADJ_CODE[%i] = %u\n", k, BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tBEAM_SET_NUM_CODE[%i] = %u\n", k,
      BufInt);
  }
  for (k = 0; k < 5; k++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tTX_MONITOR_CODE[%i] = %u\n", k,
      BufInt);
  }
  fgets(&Buf[0], 61, fileinput);
  fprintf(fileoutput, "\tERROR_COUNTERS\n");
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_SWST = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_PRI = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_TX_PULSE_LEN = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_TX_PULSE_BW = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_ECHO_WIN_LEN = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_UP = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_DOWN = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_RESAMP = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_BEAM_ADJ = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\t\tNUM_ERR_BEAM_SET_NUM = %u\n", BufInt);
  fgets(&Buf[0], 27, fileinput);
  fprintf(fileoutput, "\tIMAGE_PARAMETERS\n");
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tSWST_VALUE[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tLAST_SWST_VALUE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tSWST_CHANGES[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tPRF_VALUE[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tTX_PULSE_LEN_VALUE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tTX_PULSE_BW_VALUE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tECHO_WIN_LEN_VALUE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tUP_VALUE[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tDOWN_VALUE[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tRESAMP_VALUE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tBEAM_ADJ_VALUE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufI1 = getc(fileinput);
    BufI0 = getc(fileinput);
    BufInt = 256 * BufI1 + BufI0;
    fprintf(fileoutput, "\t\tBEAM_SET_VALUE[%i] = %u\n", l,
      BufInt);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tTX_MONITOR_VALUE[%i] = %f\n", l,
      BufFloat);
  }

  fgets(&Buf[0], 83, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "RANGE PROCESSING INFORMATION\n");
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\tFIRST_PROC_RANGE_SAMP = %u\n", BufInt);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tRANGE_REF = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tRANGE_SAMP_RATE = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tRADAR_FREQ = %f\n", BufFloat);
  BufI1 = getc(fileinput);
  BufI0 = getc(fileinput);
  BufInt = 256 * BufI1 + BufI0;
  fprintf(fileoutput, "\tNUM_LOOKS_RANGE = %u\n", BufInt);
  fgets(&Buf[0], 8, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 7);
  fprintf(fileoutput, "\tFILTER_RANGE = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tFILTER_COEF_RANGE = %f\n", BufFloat);
  fprintf(fileoutput, "\tBANDWIDTH\n");
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tLOOK_BW_RANGE[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tTOT_BW_RANGE[%i] = %f\n", l,
      BufFloat);
  }

  for (k = 0; k < 5; k++) {
    fprintf(fileoutput, "\tNOMINAL_CHIRP[%i]\n", k);
    for (l = 0; l < 4; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tNOM_CHIRP_AMP[%i] = %f\n", l,
      BufFloat);
    }
    for (l = 0; l < 4; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tNOM_CHIRP_PHS[%i] = %f\n", l,
      BufFloat);
    }
  }

  fgets(&Buf[0], 61, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "AZIMUTH PROCESSING INFORMATION\n");
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\tNUM_LINES_PROC = %u\n", BufInt);
  BufI1 = getc(fileinput);
  BufI0 = getc(fileinput);
  BufInt = 256 * BufI1 + BufI0;
  fprintf(fileoutput, "\tNUM_LOOK_AZ = %u\n", BufInt);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tLOOK_BW_AZ = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTO_BW_AZ = %f\n", BufFloat);
  fgets(&Buf[0], 8, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 7);
  fprintf(fileoutput, "\tFILTER_AZ = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tFILTER_COEF_AZ = %f\n", BufFloat);
  for (l = 0; l < 3; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tAZ_FM_RATE[%i] = %f\n", l, BufFloat);
  }
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tAX_FM_ORIGIN = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tDOP_AMB_CONF = %f\n", BufFloat);

  fgets(&Buf[0], 69, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "CALIBRATION INFORMATION\n");
  for (k = 0; k < 2; k++) {
    fprintf(fileoutput, "\tCALIBRATION_FACTORS[%i]\n", k);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tPROC_SCALING_FACT = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tEXT_CAL_FACT = %f\n", BufFloat);
  }
  fprintf(fileoutput, "\tNOISE_ESTIMATION\n");
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tNOISE_POWER_CORR[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tNUM_NOISE_LINES[%i] = %u\n", l,
      BufInt);
  }

  fgets(&Buf[0], 65, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "OTHER PROCESSING INFORMATION\n");
  fgets(&Buf[0], 13, fileinput);
  for (k = 0; k < 2; k++) {
    fprintf(fileoutput, "\tOUTPUT_STATISTICS[%i]\n", k);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tOUT_MEAN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tOUT_IMAG_MEAN = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tOUT_STD_DEV = %f\n", BufFloat);
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tOUT_IMAG_STD_DEV = %f\n", BufFloat);
  }

  fgets(&Buf[0], 53, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "DATA COMPRESSION INFORMATION\n");
  fgets(&Buf[0], 5, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 4);
  fprintf(fileoutput, "\tECHO_COMP = %s\n", Tmp);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "\tECHO_COMP_RATIO = %s\n", Tmp);
  fgets(&Buf[0], 5, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 4);
  fprintf(fileoutput, "\tINIT_CAL_COMP = %s\n", Tmp);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "\tINIT_CAL_RATIO = %s\n", Tmp);
  fgets(&Buf[0], 5, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 4);
  fprintf(fileoutput, "\tPER_CAL_COMP = %s\n", Tmp);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "\tPER_CAL_RATIO = %s\n", Tmp);
  fgets(&Buf[0], 5, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 4);
  fprintf(fileoutput, "\tNOISE_COMP = %s\n", Tmp);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "\tNOISE_COMP_RATIO = %s\n", Tmp);

  fgets(&Buf[0], 65, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "DATA COMPRESSION INFORMATION\n");
  for (l = 0; l < 4; l++) {
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\tBEAM_OVERLAP[%i] = %u\n", l, BufInt);
  }
  for (l = 0; l < 4; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tBEAM_PARAM[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 5; l++) {
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\tLINES_PER_BURST[%i] = %u\n", l, BufInt);
  }

  fgets(&Buf[0], 29, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "ORBIT STATE VECTORS\n");
  for (k = 0; k < 5; k++) {
    fprintf(fileoutput, "\tOUTPUT_STATE_VECTORS[%i]\n", k);
    BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
    MJD_Date(BufInt,&Day,&Month,&Year);
    BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
    MJD_Time(BufInt,&Hour,&Minute,&Second);
    BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tSTATE_VECT_TIME_1 = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
    BufFl[3] = getc(fileinput);
    BufFl[2] = getc(fileinput);
    BufFl[1] = getc(fileinput);
    BufFl[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tX_POS_1 = %i\n", BufFlag);
    BufFl[3] = getc(fileinput);
    BufFl[2] = getc(fileinput);
    BufFl[1] = getc(fileinput);
    BufFl[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tY_POS_1 = %i\n", BufFlag);
    BufFl[3] = getc(fileinput);
    BufFl[2] = getc(fileinput);
    BufFl[1] = getc(fileinput);
    BufFl[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tZ_POS_1 = %i\n", BufFlag);
    BufFl[3] = getc(fileinput);
    BufFl[2] = getc(fileinput);
    BufFl[1] = getc(fileinput);
    BufFl[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tX_VEL_1 = %i\n", BufFlag);
    BufFl[3] = getc(fileinput);
    BufFl[2] = getc(fileinput);
    BufFl[1] = getc(fileinput);
    BufFl[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tY_VEL_1 = %i\n", BufFlag);
    BufFl[3] = getc(fileinput);
    BufFl[2] = getc(fileinput);
    BufFl[1] = getc(fileinput);
    BufFl[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tZ_VEL_1 = %i\n", BufFlag);
  }
  fgets(&Buf[0], 65, fileinput);

  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_DCP
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Doppler Centroid Parameters (DCP) Header of
a ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_DCP(int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii;
  char Buf[FilePathLength];
  char *BufF;
  char *BufI;
  int BufFlag;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1)
    sprintf(FileOutput, "%s%s", DirOutput,"DopplerCentroidCoefficients.hdr");
  else
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"DopplerCentroidCoefficients_Record", ii + 1, ".hdr");

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"****************************************************************");
//"*        DOPPLER CENTROID PARAMETERS HEADER        ");
//"****************************************************************");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "ZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "ATTACH_FLAG = %i\n", BufFlag);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SLANT_RANGE_TIME = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "DOPPLER_COEFF_D0 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "DOPPLER_COEFF_D1 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "DOPPLER_COEFF_D2 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "DOPPLER_COEFF_D3 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "DOPPLER_COEFF_D4 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "DOPPLER_CONF = %f\n", BufFloat);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "DOP_CONF_BELOW_THRESH_FLAG = %i\n", BufFlag);
  fgets(&Buf[0], 14, fileinput);

  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_CP
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Chirp Parameters (DCP) Header of a ASAR-AP
Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_CP(int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii, k, l;
  char Buf[FilePathLength], Tmp[FilePathLength];
  char *BufF;
  char *BufI;
  int BufFlag;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1)
    sprintf(FileOutput, "%s%s", DirOutput, "ChirpParameters.hdr");
  else
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"ChirpParameters_Record", ii + 1, ".hdr");

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"***************************************************************");
//"           CHIRP PARAMETERS HEADER          ");
//"***************************************************************");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "ZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "ATTACH_FLAG = %i\n", BufFlag);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "SWATCH = %s\n", Tmp);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "POLAR = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CHIRP_WIDTH = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CHIRP_SIDELOBES = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CHIRP_ISLR = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CHIRP_PEAK_LOC = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CHIRP_POWER = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "ELEV_CORR_FACTOR = %f\n", BufFloat);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "CHIRP_QUALITY_FLAG = %i\n", BufFlag);
  fgets(&Buf[0], 16, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput,
    "CALIBRATION PULSE RECONSTRUCTION INFORMATION\n");
  for (k = 0; k < 32; k++) {
    fprintf(fileoutput, "\tCAL_PULSE_INFO[%i]\n", k);
    for (l = 0; l < 3; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tMAX_CAL[%i] = %f\n", l, BufFloat);
    }
    for (l = 0; l < 3; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tAVG_CAL[%i] = %f\n", l, BufFloat);
    }
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tAVG_CAL_1a = %f\n", BufFloat);
    for (l = 0; l < 4; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\t\tPHS_CAL[%i] = %f\n", l, BufFloat);
    }
  }
  fgets(&Buf[0], 17, fileinput);

  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_GGA
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Geolocation Grid ADSRs (GGA) Header of a
ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_GGA(int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii, l;
  char Buf[FilePathLength];
  char *BufF, *BufI;
  int BufFlag;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1)
    sprintf(FileOutput, "%s%s", DirOutput,"GeolocationGridADSRs.hdr");
  else
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"GeolocationGridADSRs_Record", ii + 1, ".hdr");

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"***************************************************************");
//"          GEOLOCATION GRID ADSRs HEADER        ");
//"***************************************************************");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "FIRST_ZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "ATTACH_FLAG = %i\n", BufFlag);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "LINE_NUM = %u\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "NUM_LINES = %u\n", BufInt);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SUB_SAT_TRACK = %f\n", BufFloat);
  fprintf(fileoutput, "FIRST_LINE_TIE_POINTS\n");
  for (l = 0; l < 11; l++) {
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\tSAMP_NUMBERS[%i] = %u\n", l, BufInt);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tSLANT_RANGE_TIMES[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tANGLES[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tLATS[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tLONGS[%i] = %f\n", l, BufFloat);
  }
  fgets(&Buf[0], 23, fileinput);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "LAST_ZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  fprintf(fileoutput, "LAST_LINE_TIE_POINTS\n");
  for (l = 0; l < 11; l++) {
    BufI[3] = getc(fileinput);
    BufI[2] = getc(fileinput);
    BufI[1] = getc(fileinput);
    BufI[0] = getc(fileinput);
    fprintf(fileoutput, "\tSAMP_NUMBERS[%i] = %u\n", l, BufInt);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tSLANT_RANGE_TIMES[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tANGLES[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tLATS[%i] = %f\n", l, BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tLONGS[%i] = %f\n", l, BufFloat);
  }
  fgets(&Buf[0], 23, fileinput);

  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_SRGR
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Slant Range to Ground Range (SRGR) Header of a
ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_SRGR(int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii, l;
  char *BufF, *BufI;
  int BufFlag;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1)
    sprintf(FileOutput, "%s%s", DirOutput,"SlantRange2GroundRange.hdr");
  else
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"SlantRange2GroundRange_Record", ii + 1, ".hdr");

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"***************************************************************");
//"        SLANT RANGE to GROUND RANGE HEADER        ");
//"***************************************************************");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "ZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "ATTACH_FLAG = %i\n", BufFlag);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SLANT RANGE TIME = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "GROUND RANGE ORIGIN = %f\n", BufFloat);
  fprintf(fileoutput, "SRGR COEFFICIENTS\n");
  for (l = 0; l < 5; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tS%i = %f\n", l, BufFloat);
  }
  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_AEPxADSRs
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Antenna Elevation Pattern (AEPxADSRs) Header of
a ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_AEPxADSRs(int channel, int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii, l;
  char Buf[FilePathLength], Tmp[FilePathLength];
  char *BufF;
  char *BufI;
  int BufFlag;
  unsigned int BufInt;
  float BufFloat;

  int Day,Month,Year,Hour,Minute,Second;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1) {
    if (channel == 1)
    sprintf(FileOutput, "%s%s", DirOutput, "AEP1ADSRs.hdr");
    if (channel == 2)
    sprintf(FileOutput, "%s%s", DirOutput, "AEP2ADSRs.hdr");
  } else {
    if (channel == 1)
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"AEP1ADSRs_Record", ii + 1, ".hdr");
    if (channel == 2)
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"AEP2ADSRs_Record", ii + 1, ".hdr");
  }

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"****************************************************************");
//"             AEPx ADSRs HEADER            ");
//"****************************************************************");
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Date(BufInt,&Day,&Month,&Year);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  MJD_Time(BufInt,&Hour,&Minute,&Second);
  BufI[3] = getc(fileinput);BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);BufI[0] = getc(fileinput);
  fprintf(fileoutput, "\tZERO_DOPPLER_TIME = %i/%i/%i %i:%i:%i.%i\n", Day,Month,Year,Hour,Minute,Second,BufInt);
  BufFlag = getc(fileinput);
  fprintf(fileoutput, "\tATTACH_FLAG = %i\n", BufFlag);
  fgets(&Buf[0], 4, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 3);
  fprintf(fileoutput, "\tSWATH = %s\n", Tmp);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "ELEVATION PATTERN\n");
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tSLANT_RANGE_TIME[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tELEVATION_ANGLES[%i] = %f\n", l,
      BufFloat);
  }
  for (l = 0; l < 11; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tANTENNA_PATTERN[%i] = %f\n", l,
      BufFloat);
  }
  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : ReadHEADER_MPG
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Read and Save the Map Projection Gads (MPG) Header of a
ASAR-AP Data File
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void ReadHEADER_MPG(int Num_DSR, int RSize)
{
  FILE *fileinput, *fileoutput;

  int ii, l;
  char Buf[FilePathLength], Tmp[FilePathLength];
  char *BufF, *BufI;
  unsigned int BufInt;
  float BufFloat;

  char FileOutput[FilePathLength];

  if ((fileinput = fopen(FileAsarHeaderBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ", FileAsarHeaderBin);

  BufI = (char *) &BufInt;
  BufF = (char *) &BufFloat;

  for (ii = 0; ii < Num_DSR; ii++) {
  rewind(fileinput);
  fseek(fileinput, ii * RSize, SEEK_SET);

  if (Num_DSR == 1)
    sprintf(FileOutput, "%s%s", DirOutput, "MapProjection.hdr");
  else
    sprintf(FileOutput, "%s%s%d%s", DirOutput,"MapProjection_Record", ii + 1, ".hdr");

  check_file(FileOutput);
  if ((fileoutput = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileOutput);

//"***************************************************************");
//"            MAP PROJECTION HEADER          ");
//"***************************************************************");
  fgets(&Buf[0], 33, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 32);
  fprintf(fileoutput, "MAP_DESCRIPTOR = %s\n", Tmp);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "SAMPLES = %i\n", BufInt);
  BufI[3] = getc(fileinput);
  BufI[2] = getc(fileinput);
  BufI[1] = getc(fileinput);
  BufI[0] = getc(fileinput);
  fprintf(fileoutput, "LINES = %i\n", BufInt);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SAMPLE_SPACING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "LINE_SPACING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "ORIENTATION = %f\n", BufFloat);
  fgets(&Buf[0], 41, fileinput);
  fprintf(fileoutput, "\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "HEADING = %f\n", BufFloat);
  fgets(&Buf[0], 33, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 32);
  fprintf(fileoutput, "ELLIPSOID_NAME = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SEMI_MAJOR = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SEMI_MINOR = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SHIFT_DX = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SHIFT_DY = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "SHIFT_DZ = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "AVG_HEIGHT = %f\n", BufFloat);
  fgets(&Buf[0], 13, fileinput);
  fprintf(fileoutput, "\n");
  fgets(&Buf[0], 33, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 32);
  fprintf(fileoutput, "PROJECTION_DESCRIPTION = %s\n", Tmp);
  fgets(&Buf[0], 33, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 32);
  fprintf(fileoutput, "UTM_DESCRIPTOR = %s\n", Tmp);
  fgets(&Buf[0], 5, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 4);
  fprintf(fileoutput, "UTM_ZONE = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_ORIGIN_EASTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_ORIGIN_NORTHTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_CENTER_LONG = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_CENTER_LAT = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_PARA1 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_PARA2 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UTM_SCALE = %f\n", BufFloat);
  fgets(&Buf[0], 33, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 32);
  fprintf(fileoutput, "UPS_DESCRIPTOR = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UPS_CENTER_LONG = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UPS_CENTER_LAT = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "UPS_SCALE = %f\n", BufFloat);
  fgets(&Buf[0], 33, fileinput);
  strcpy(Tmp, "");
  strncat(Tmp, &Buf[0], 32);
  fprintf(fileoutput, "NSP_DESCRIPTOR = %s\n", Tmp);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "ORIGIN_EASTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "ORIGIN_NORTHTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CENTER_LONG = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "CENTER_LAT = %f\n", BufFloat);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "STANDARD_PARALLEL_PARAMETERS\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tPARA1 = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tPARA2 = %f\n", BufFloat);
  fgets(&Buf[0], 9, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "CENTRAL_MERIDIAN_PARAMETERS\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tCENTRAL_M1 = %f\n", BufFloat);
  fgets(&Buf[0], 9, fileinput);
  fprintf(fileoutput, "PROJECTION_PARAMETERS\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tPROJ1 = %f\n", BufFloat);
  fgets(&Buf[0], 13, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "POSITION_NORTHINGS_EASTINGS\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTL_NORTHING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTL_EASTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTR_NORTHING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTR_EASTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBR_NORTHING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBR_EASTING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBL_NORTHING = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBL_EASTING = %f\n", BufFloat);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "POSITION_LAT_LONG\n");
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTL_LAT = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTL_LONG = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTR_LAT = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tTR_LONG = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBR_LAT = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBR_LONG = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBL_LAT = %f\n", BufFloat);
  BufF[3] = getc(fileinput);
  BufF[2] = getc(fileinput);
  BufF[1] = getc(fileinput);
  BufF[0] = getc(fileinput);
  fprintf(fileoutput, "\tBL_LONG = %f\n", BufFloat);
  fgets(&Buf[0], 33, fileinput);
  fprintf(fileoutput, "\n");
  fprintf(fileoutput, "IMAGE_TO_MAP_COEFFS\n");
  for (l = 0; l < 8; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tCOEFF[%i] = %f\n", l, BufFloat);
  }
  fprintf(fileoutput, "MAP_TO_IMAGE_COEFFS\n");
  for (l = 0; l < 8; l++) {
    BufF[3] = getc(fileinput);
    BufF[2] = getc(fileinput);
    BufF[1] = getc(fileinput);
    BufF[0] = getc(fileinput);
    fprintf(fileoutput, "\tCOEFF[%i] = %f\n", l, BufFloat);
  }

  fclose(fileoutput);
  }
  fclose(fileinput);

}

/*******************************************************************************
Routine  : Extract_HEADER
Authors  : Eric POTTIER
Creation : 11/2003
Update  :
*-------------------------------------------------------------------------------
Description :  Extract Header and save in a temporary file
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void Extract_HEADER(FILE * fileinput, unsigned int Offset, int RSize)
{
  FILE *fileoutput;
  char *Buf;

  if ((fileoutput = fopen(FileAsarHeaderBin, "wb")) == NULL)
  edit_error("Could not open configuration file HEADER.BIN: ", FileAsarHeaderBin);

  rewind(fileinput);
  fseek(fileinput, Offset, SEEK_SET);
  Buf = vector_char(RSize);
  fread(&Buf[0], sizeof(char), RSize, fileinput);
  fwrite(&Buf[0], sizeof(char), RSize, fileoutput);
  fclose(fileoutput);
  free_vector_char(Buf);

}

/*******************************************************************************
Routine  : MJD_Date
Authors  : Eric POTTIER
Creation : 06/2004
Update  :
*-------------------------------------------------------------------------------
Description :  Convert Number of Days (MJD2000 Format) in Day:Month:Year
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/
void MJD_Date(unsigned int MJD, int *Day, int *Month, int *Year)
{
 int tmpday,bissect;

 (*Year) = 0;
 (*Day) = 0;
 (*Month) = 0;
 if (MJD > 0) {
 while ((*Day) < MJD)
  {
  tmpday = 365;
  if (fmod((*Year),4)==0) tmpday = 366;
  (*Day)=(*Day)+tmpday;
  (*Year)++;
  }
 (*Year)--;(*Year)=(*Year)+2000;
 MJD = MJD - (*Day) + tmpday;
 bissect = 0;
 if (fmod((*Year),4)==0) bissect = 1;
 (*Month) = 1;
 (*Day) = 0;
 while ((*Day) < MJD)
  {
  if (fmod((*Month),2) != 0) tmpday = 31;
  if (fmod((*Month),2) == 0)
    {
    tmpday = 30;
    if ((*Month)==2)
     {
     if (bissect == 0) tmpday = 28;
     if (bissect == 1) tmpday = 29;
     }
    }
  (*Day)=(*Day)+tmpday;
  (*Month)++;
  }
 (*Month)--;
 (*Day) = MJD - (*Day) + tmpday + 1;
 }
}
/*******************************************************************************
Routine  : MJD_Time
Authors  : Eric POTTIER
Creation : 06/2004
Update  :
*-------------------------------------------------------------------------------
Description :  Convert Number of Seconds (MJD2000 Format) in Hour:Minute:Second
*-------------------------------------------------------------------------------
Inputs arguments :
FileHEADER  : Output File
fileinput   : Input File
Returned values  :
void
*******************************************************************************/

void MJD_Time(unsigned int MJD, int *Hour, int *Minute, int *Second)
{
 (*Hour) = 0;
 (*Minute) = 0;
 (*Second) = 0;
 if (MJD > 0) {
  *Hour=(int) floor(MJD/3600.);
  MJD=MJD-3600*(*Hour);
  *Minute=(int) floor(MJD/60.);
  *Second=MJD-60*(*Minute);
  }
}
