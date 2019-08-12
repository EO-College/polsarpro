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

File     : create_world_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2016
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

 Create a World File to be read by a GIS software
 
 Convert lat/long to UTM coords.  Equations from USGS Bulletin 1532 

 East Longitudes are positive, West longitudes are negative. 
 North latitudes are positive, South latitudes are negative
 Lat and Long are in fractional degrees

 Written by Chuck Gantz- chuck.gantz@globalstar.com

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

// WGS84 Parameters
#define WGS84_A     6378137.0           // major axis
#define WGS84_B     6356752.31424518    // minor axis
#define WGS84_F     0.0033528107        // ellipsoid flattening
#define WGS84_E     0.0818191908        // first eccentricity
#define WGS84_EP    0.0820944379        // second eccentricity

// UTM Parameters
#define UTM_K0      0.9996              // scale factor
#define UTM_FE      500000.0            // false easting
#define UTM_FN_N    0.0                 // false northing, northern hemisphere
#define UTM_FN_S    10000000.0          // false northing, southern hemisphere
#define UTM_E2      (WGS84_E*WGS84_E)   // e^2
#define UTM_E4      (UTM_E2*UTM_E2)     // e^4
#define UTM_E6      (UTM_E4*UTM_E2)     // e^6
#define UTM_EP2     (UTM_E2/(1-UTM_E2)) // e'^2

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
  FILE *filename, *fileout;
  char FileOutput[FilePathLength];
  char FileGoogle[FilePathLength], FileConfAcq[FilePathLength];
  
  char LetterDesignator[2];
  //char UTMZone[10];
  const double RADIANS_PER_DEGREE = M_PI/180.0;
  
  char Tmp[1024];
  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;
  float PixelSize;
  
  double Lat, Long;
  double UTMEasting00, UTMNorthing00;
  double a = WGS84_A;
  double eccSquared = UTM_E2;
  double k0 = UTM_K0;
  double LongOrigin;
  double eccPrimeSquared;
  double N, T, C, A, M;
  double LongTemp, LatRad, LongRad, LongOriginRad;
  int    ZoneNumber;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_world_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifg  	input GEARTH POLY File\n");
strcat(UsageHelp," (string)	-ifa  	input CONFIG ACQUISITION File\n");
strcat(UsageHelp," (string)	-of   	output World File File\n");
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
  get_commandline_prm(argc,argv,"-ifg",str_cmd_prm,FileGoogle,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifa",str_cmd_prm,FileConfAcq,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileOutput);
  check_file(FileGoogle);
  check_file(FileConfAcq);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/
  if ((filename = fopen(FileGoogle, "r")) == NULL)
    edit_error("Could not open output file : ", FileGoogle);

  rewind(filename);

  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f\n", &LonCenter);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f\n", &LatCenter);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f,%f,8000.0\n", &Lon00,&Lat00);
  fscanf(filename, "%f,%f,8000.0\n", &LonN0,&LatN0);
  fscanf(filename, "%f,%f,8000.0\n", &LonNN,&LatNN);
  fscanf(filename, "%f,%f,8000.0\n", &Lon0N,&Lat0N);
  fclose(filename);
  
/********************************************************************
********************************************************************/
  Lat = (double)Lat00;
  Long = (double)Lon00;
  
  //Make sure the longitude is between -180.00 .. 179.9
  LongTemp = (Long+180)-(int)((Long+180)/360)*360-180;

  LatRad = Lat*RADIANS_PER_DEGREE;
  LongRad = LongTemp*RADIANS_PER_DEGREE;

  ZoneNumber = (int)((LongTemp + 180)/6) + 1;
  
  if( Lat >= 56.0 && Lat < 64.0 && LongTemp >= 3.0 && LongTemp < 12.0 ) ZoneNumber = 32;

  // Special zones for Svalbard
  if( Lat >= 72.0 && Lat < 84.0 ) {
    if(      LongTemp >= 0.0  && LongTemp <  9.0 ) ZoneNumber = 31;
    else if( LongTemp >= 9.0  && LongTemp < 21.0 ) ZoneNumber = 33;
    else if( LongTemp >= 21.0 && LongTemp < 33.0 ) ZoneNumber = 35;
    else if( LongTemp >= 33.0 && LongTemp < 42.0 ) ZoneNumber = 37;
    }
  // +3 puts origin in middle of zone
  LongOrigin = (ZoneNumber - 1)*6 - 180 + 3; 
  LongOriginRad = LongOrigin * RADIANS_PER_DEGREE;

  eccPrimeSquared = (eccSquared)/(1-eccSquared);

  N = a/sqrt(1-eccSquared*sin(LatRad)*sin(LatRad));
  T = tan(LatRad)*tan(LatRad);
  C = eccPrimeSquared*cos(LatRad)*cos(LatRad);
  A = cos(LatRad)*(LongRad-LongOriginRad);

  M = a*((1 - eccSquared/4 - 3*eccSquared*eccSquared/64
      - 5*eccSquared*eccSquared*eccSquared/256) * LatRad 
      - (3*eccSquared/8 + 3*eccSquared*eccSquared/32
      + 45*eccSquared*eccSquared*eccSquared/1024)*sin(2*LatRad)
      + (15*eccSquared*eccSquared/256
      + 45*eccSquared*eccSquared*eccSquared/1024)*sin(4*LatRad) 
      - (35*eccSquared*eccSquared*eccSquared/3072)*sin(6*LatRad));

  UTMEasting00 = (double) (k0*N*(A+(1-T+C)*A*A*A/6
             + (5-18*T+T*T+72*C-58*eccPrimeSquared)*A*A*A*A*A/120)
             + 500000.0);

  UTMNorthing00 = (double) (k0*(M+N*tan(LatRad)
              *(A*A/2+(5-T+9*C+4*C*C)*A*A*A*A/24
              + (61-58*T+T*T+600*C-330*eccPrimeSquared)*A*A*A*A*A*A/720)));

  if(Lat < 0) {
  //10000000 meter offset for southern hemisphere
    UTMNorthing00 += 10000000.0;
    }

  //compute the UTM Zone from the latitude and longitude
  if     ((84 >= Lat) && (Lat >= 72))  strcpy(LetterDesignator,"X");
  else if ((72 > Lat) && (Lat >= 64))  strcpy(LetterDesignator,"W");
  else if ((64 > Lat) && (Lat >= 56))  strcpy(LetterDesignator,"V");
  else if ((56 > Lat) && (Lat >= 48))  strcpy(LetterDesignator,"U");
  else if ((48 > Lat) && (Lat >= 40))  strcpy(LetterDesignator,"T");
  else if ((40 > Lat) && (Lat >= 32))  strcpy(LetterDesignator,"S");
  else if ((32 > Lat) && (Lat >= 24))  strcpy(LetterDesignator,"R");
  else if ((24 > Lat) && (Lat >= 16))  strcpy(LetterDesignator,"Q");
  else if ((16 > Lat) && (Lat >= 8))   strcpy(LetterDesignator,"P");
  else if (( 8 > Lat) && (Lat >= 0))   strcpy(LetterDesignator,"N");
  else if (( 0 > Lat) && (Lat >= -8))  strcpy(LetterDesignator,"M");
  else if ((-8 > Lat) && (Lat >= -16)) strcpy(LetterDesignator,"L");
  else if((-16 > Lat) && (Lat >= -24)) strcpy(LetterDesignator,"K");
  else if((-24 > Lat) && (Lat >= -32)) strcpy(LetterDesignator,"J");
  else if((-32 > Lat) && (Lat >= -40)) strcpy(LetterDesignator,"H");
  else if((-40 > Lat) && (Lat >= -48)) strcpy(LetterDesignator,"G");
  else if((-48 > Lat) && (Lat >= -56)) strcpy(LetterDesignator,"F");
  else if((-56 > Lat) && (Lat >= -64)) strcpy(LetterDesignator,"E");
  else if((-64 > Lat) && (Lat >= -72)) strcpy(LetterDesignator,"D");
  else if((-72 > Lat) && (Lat >= -80)) strcpy(LetterDesignator,"C");
  // 'Z' is an error flag, the Latitude is outside the UTM limits
  else strcpy(LetterDesignator,"Z");

//  sprintf(UTMZone, "%d%s", ZoneNumber, LetterDesignator);  
  
//  printf("UTMZone = %s\n",UTMZone);
/********************************************************************
********************************************************************/

  if ((filename = fopen(FileConfAcq, "r")) == NULL)
    edit_error("Could not open output file : ", FileConfAcq);

  rewind(filename);

  fgets(&Tmp[0], 100, filename);
  fgets(&Tmp[0], 100, filename);
  fscanf(filename, "%f\n", &PixelSize);
  fclose(filename);
  
/********************************************************************
********************************************************************/
     
  if ((fileout = fopen(FileOutput, "w")) == NULL)
    edit_error("Could not open output file : ", FileOutput);

  fprintf(fileout, "%f\n", PixelSize);
  fprintf(fileout, "0\n");
  fprintf(fileout, "0\n");
  fprintf(fileout, "-%f\n", PixelSize);
  fprintf(fileout, "%f\n", UTMEasting00);
  fprintf(fileout, "%f\n", UTMNorthing00);
  
  fclose(fileout);
  
  return 1;
}

