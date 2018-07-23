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

File   : uavsar_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Marco LAVALLE (JPL ipUAVSAR)
Version  : 1.0
Creation : 08/2010
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

Description :  Read Header (Annotation file) of JPL UAVSAR and write
               out the config and mkl files.

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


/* ALIASES  */

/* CONSTANTS  */

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
{

/* LOCAL VARIABLES */

/* Input/Output file pointer arrays */
  FILE *HeaderFile, *in_file, *AnnFile, *TmpFile, *GoogleFile;

/* Strings */
  char file_name[FilePathLength], out_dir[FilePathLength], in_dir[FilePathLength], header_file_name[FilePathLength], tmp_file_name[FilePathLength];
  char ch, str[256], name[256], value[256], data_format[10], strNlig[32], strNcol[32];
  char strHHHH[32],strHVHV[32],strVVVV[32],strHHHV[32],strHVVV[32],strHHVV[32],strDEM[32];
  char strLat00[50],strLatN0[50],strLat0N[50],strLatNN[50];
  char strLon00[50],strLonN0[50],strLon0N[50],strLonNN[50];
  char strROW[50], strCOL[50], strROWPIX[50], strCOLPIX[50];
  char file_name_in1[FilePathLength],file_name_in2[FilePathLength],file_name_in3[FilePathLength],file_name_in4[FilePathLength];
  char file_name_in5[FilePathLength],file_name_in6[FilePathLength],file_name_hgt[FilePathLength];
  char ann_file_name[32] = "annotation_file.txt";
  char google_file_name[32] = "GEARTH_POLY.kml";

/* Input variables */

/* Internal variables */
  int Nlig, Ncol, r, config, config_hgt;
  float Lat00,LatN0,Lat0N,LatNN;
  float Lon00,LonN0,Lon0N,LonNN;
  float LatPix, LonPix;
  char LatV[256], LonV[256], LatPixV[256], LonPixV[256];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nuavsar_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-hf  	UAVSAR header file\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-df  	data format (slc/mlc/grd)\n");
strcat(UsageHelp," (string)	-tf  	PSP tmp file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 11) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-hf",str_cmd_prm,header_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-df",str_cmd_prm,data_format,1,UsageHelp);
  get_commandline_prm(argc,argv,"-tf",str_cmd_prm,tmp_file_name,1,UsageHelp);
  }

 if ( strcmp(data_format, "slc") != 0 && strcmp(data_format, "mlc") != 0 && strcmp(data_format, "grd") != 0)
  edit_error("Wrong data format arguments\n Usage:\n",UsageHelp);

/********************************************************************
********************************************************************/

  check_file(header_file_name);
  check_dir(in_dir);
  check_dir(out_dir);
  check_file(tmp_file_name);

/********************************************************************
********************************************************************/

  /* Scan the header file */
  if ((HeaderFile = fopen(header_file_name, "rt")) == NULL)
  edit_error("Could not open input file : ", header_file_name);

  rewind(HeaderFile);  

  if (strcmp(data_format, "slc") == 0) {
    sprintf(strHHHH, "%s%s", data_format, "HH");
    sprintf(strHHHV, "%s%s", data_format, "HV");
    sprintf(strHVVV, "%s%s", data_format, "VH");
    sprintf(strVVVV, "%s%s", data_format, "VV");
    while ( !feof(HeaderFile)) {
      fgets(str, 256, HeaderFile);
      r = sscanf(str,"%s = %s ; %*[^\n]\n", name, value);
      if (r == 2 && strcmp(name, strHHHH) == 0) strcpy(file_name_in1, value); 
      if (r == 2 && strcmp(name, strHHHV) == 0) strcpy(file_name_in2, value); 
      if (r == 2 && strcmp(name, strHVVV) == 0) strcpy(file_name_in3, value); 
      if (r == 2 && strcmp(name, strVVVV) == 0) strcpy(file_name_in4, value); 
      }
    } else {
    sprintf(strHHHH, "%s%s", data_format, "HHHH");
    sprintf(strHHHV, "%s%s", data_format, "HHHV");
    sprintf(strHHVV, "%s%s", data_format, "HHVV");
    sprintf(strHVHV, "%s%s", data_format, "HVHV");
    sprintf(strHVVV, "%s%s", data_format, "HVVV");
    sprintf(strVVVV, "%s%s", data_format, "VVVV");
    if (strcmp(data_format, "grd") == 0) 
      sprintf(strDEM, "%s", "hgt");
    while ( !feof(HeaderFile)) {
      fgets(str, 256, HeaderFile);
      r = sscanf(str,"%s = %s ; %*[^\n]\n", name, value);
      if (r == 2 && strcmp(name, strHHHH) == 0) strcpy(file_name_in1, value); 
      if (r == 2 && strcmp(name, strHHHV) == 0) strcpy(file_name_in2, value); 
      if (r == 2 && strcmp(name, strHHVV) == 0) strcpy(file_name_in3, value); 
      if (r == 2 && strcmp(name, strHVHV) == 0) strcpy(file_name_in4, value); 
      if (r == 2 && strcmp(name, strHVVV) == 0) strcpy(file_name_in5, value); 
      if (r == 2 && strcmp(name, strVVVV) == 0) strcpy(file_name_in6, value); 
      if (strcmp(data_format, "grd") == 0) 
        if (r == 2 && strcmp(name, strDEM) == 0) strcpy(file_name_hgt, value); 
      }
    }
  
  sprintf(strNlig, "%s%s", data_format, "_mag.set_rows");
  sprintf(strNcol, "%s%s", data_format, "_mag.set_cols");
  rewind(HeaderFile);  
  while ( !feof(HeaderFile) ) {
    fgets(str, 256, HeaderFile);
    r = sscanf(str,"%s %*s = %s", name, value);
    if (r == 2 && strcmp(name, strNlig) == 0) Nlig = atoi(value);
    if (r == 2 && strcmp(name, strNcol) == 0) Ncol = atoi(value);
    }

  sprintf(strLat00, "%s", "Approximate Upper Left Latitude  ");
  sprintf(strLon00, "%s", "Approximate Upper Left Longitude ");
  sprintf(strLat0N, "%s", "Approximate Upper Right Latitude ");
  sprintf(strLon0N, "%s", "Approximate Upper Right Longitude");
  sprintf(strLatN0, "%s", "Approximate Lower Left Latitude  ");
  sprintf(strLonN0, "%s", "Approximate Lower Left Longitude ");
  sprintf(strLatNN, "%s", "Approximate Lower Right Latitude ");
  sprintf(strLonNN, "%s", "Approximate Lower Right Longitude");
  rewind(HeaderFile);  
  while ( !feof(HeaderFile) ) {
    fgets(str, 256, HeaderFile);
    strcpy(name, ""); strncat(name, &str[0], 33); 
    strcpy(value, ""); strncat(value, &str[55], strlen(str) - 55); 
    if (strcmp(name, strLat00) == 0) Lat00 = atof(value);
    if (strcmp(name, strLon00) == 0) Lon00 = atof(value);
    if (strcmp(name, strLat0N) == 0) Lat0N = atof(value);
    if (strcmp(name, strLon0N) == 0) Lon0N = atof(value);
    if (strcmp(name, strLatN0) == 0) LatN0 = atof(value);
    if (strcmp(name, strLonN0) == 0) LonN0 = atof(value);
    if (strcmp(name, strLatNN) == 0) LatNN = atof(value);
    if (strcmp(name, strLonNN) == 0) LonNN = atof(value);
    }

  sprintf(strROW, "%s", "grd_pwr.row_addr");
  sprintf(strCOL, "%s", "grd_pwr.col_addr");
  sprintf(strROWPIX, "%s", "grd_pwr.row_mult");
  sprintf(strCOLPIX, "%s", "grd_pwr.col_mult");
  rewind(HeaderFile);  
  while ( !feof(HeaderFile) ) {
    fgets(str, 256, HeaderFile);
    r = sscanf(str,"%s %*s = %s", name, value);
    if (r == 2 && strcmp(name, strROW) == 0) strcpy(LatV,value);
    if (r == 2 && strcmp(name, strCOL) == 0) strcpy(LonV,value);
    if (r == 2 && strcmp(name, strROWPIX) == 0) {
      LatPix = atof(value);
      if (LatPix > 0.) strcpy(LatPixV,value);
      else {
        strcpy(LatPixV, ""); strncat(LatPixV, &value[1], strlen(value)-1);           
        }
      }
    if (r == 2 && strcmp(name, strCOLPIX) == 0) {
      LonPix = atof(value);
      if (LonPix > 0.) strcpy(LonPixV,value);
      else {
        strcpy(LonPixV, ""); strncat(LonPixV, &value[1], strlen(value)-1);           
        }
      }
    }
    
/********************************************************************
********************************************************************/

  /* Create the header file (copy) */
  rewind(HeaderFile);

  sprintf(file_name, "%s%s", out_dir, ann_file_name);
  if ((AnnFile = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file :", file_name);


  while(!feof(HeaderFile)) {
    ch = getc(HeaderFile);
    putc(ch, AnnFile);
  }

  fclose(HeaderFile);
  fclose(AnnFile);

/********************************************************************
********************************************************************/

  /* Check if the data format exists, the data extraction will do a file-by-file check */
  config = 1;
  sprintf(file_name, "%s%s", in_dir, file_name_in1);
  if ((in_file = fopen(file_name, "rb")) == NULL) config = 0;
  sprintf(file_name, "%s%s", in_dir, file_name_in2);
  if ((in_file = fopen(file_name, "rb")) == NULL) config = 0;
  sprintf(file_name, "%s%s", in_dir, file_name_in3);
  if ((in_file = fopen(file_name, "rb")) == NULL) config = 0;
  sprintf(file_name, "%s%s", in_dir, file_name_in4);
  if ((in_file = fopen(file_name, "rb")) == NULL) config = 0;
  if (strcmp(data_format, "slc") != 0) {
    sprintf(file_name, "%s%s", in_dir, file_name_in5);
    if ((in_file = fopen(file_name, "rb")) == NULL) config = 0;
    sprintf(file_name, "%s%s", in_dir, file_name_in6);
    if ((in_file = fopen(file_name, "rb")) == NULL) config = 0;
    }

  config_hgt = 1;
  if (strcmp(data_format, "grd") == 0) {
    sprintf(file_name, "%s%s", in_dir, file_name_hgt);
    if ((in_file = fopen(file_name, "rb")) == NULL) config_hgt = 0;
    }
    
  if ((TmpFile = fopen(tmp_file_name, "w")) == NULL)
  edit_error("Could not open output file :", tmp_file_name);
  if (config == 1) {
    fprintf(TmpFile, "HEADER OK\n");
    fprintf(TmpFile, "%i\n", Nlig);
    fprintf(TmpFile, "%i\n", Ncol);
    fprintf(TmpFile, "%f\n", (Lat00+Lat0N+LatN0+LatNN)/4.);
    fprintf(TmpFile, "%f\n", (Lon00+Lon0N+LonN0+LonNN)/4.);
    fprintf(TmpFile, "%f\n", Lat00);
    fprintf(TmpFile, "%f\n", Lon00);
    fprintf(TmpFile, "%f\n", Lat0N);
    fprintf(TmpFile, "%f\n", Lon0N);
    fprintf(TmpFile, "%f\n", LatN0);
    fprintf(TmpFile, "%f\n", LonN0);
    fprintf(TmpFile, "%f\n", LatNN);
    fprintf(TmpFile, "%f\n", LonNN);
    fprintf(TmpFile, "%s\n", file_name_in1); 
    fprintf(TmpFile, "%s\n", file_name_in2); 
    fprintf(TmpFile, "%s\n", file_name_in3); 
    fprintf(TmpFile, "%s\n", file_name_in4); 
    if (strcmp(data_format, "slc") != 0) {
      fprintf(TmpFile, "%s\n", file_name_in5); 
      fprintf(TmpFile, "%s\n", file_name_in6); 
      }
    fprintf(TmpFile, "map info = {Geographic Lat/Lon, 1, 1, %s, %s, %s, %s, WGS-84}\n", LonV,LatV,LonPixV,LatPixV); 
    fprintf(TmpFile, "%s\n", LonV); 
    fprintf(TmpFile, "%s\n", LatV); 
    fprintf(TmpFile, "%s\n", LonPixV); 
    fprintf(TmpFile, "%s\n", LatPixV); 
    if (strcmp(data_format, "grd") == 0) {
      if (config_hgt == 1)
        fprintf(TmpFile, "%s\n", file_name_hgt); 
        else
        fprintf(TmpFile, "No DEM\n"); 
      }  
    fclose(TmpFile);
  
    sprintf(file_name, "%s%s", out_dir, google_file_name);
    if ((GoogleFile = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file :", file_name);

    fprintf(GoogleFile,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
    fprintf(GoogleFile,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
    fprintf(GoogleFile,"<Placemark>\n");
    fprintf(GoogleFile,"<name>\n");
    fprintf(GoogleFile, "Image UAVSAR\n");
    fprintf(GoogleFile,"</name>\n");
    fprintf(GoogleFile,"<LookAt>\n");
    fprintf(GoogleFile,"<longitude>\n");
    fprintf(GoogleFile, "%f\n", (Lon00+Lon0N+LonN0+LonNN)/4.);
    fprintf(GoogleFile,"</longitude>\n");
    fprintf(GoogleFile,"<latitude>\n");
    fprintf(GoogleFile, "%f\n", (Lat00+Lat0N+LatN0+LatNN)/4.);
    fprintf(GoogleFile,"</latitude>\n");
    fprintf(GoogleFile,"<range>\n");
    fprintf(GoogleFile,"250000.0\n");
    fprintf(GoogleFile,"</range>\n");
    fprintf(GoogleFile,"<tilt>0</tilt>\n");
    fprintf(GoogleFile,"<heading>0</heading>\n");
    fprintf(GoogleFile,"</LookAt>\n");
    fprintf(GoogleFile,"<Style>\n");
    fprintf(GoogleFile,"<LineStyle>\n");
    fprintf(GoogleFile,"<color>ff0000ff</color>\n");
    fprintf(GoogleFile,"<width>4</width>\n");
    fprintf(GoogleFile,"</LineStyle>\n");
    fprintf(GoogleFile,"</Style>\n");
    fprintf(GoogleFile,"<LineString>\n");
    fprintf(GoogleFile,"<coordinates>\n");
    fprintf(GoogleFile, "%f,%f,8000.0\n", Lon00,Lat00);
    fprintf(GoogleFile, "%f,%f,8000.0\n", LonN0,LatN0);
    fprintf(GoogleFile, "%f,%f,8000.0\n", LonNN,LatNN);
    fprintf(GoogleFile, "%f,%f,8000.0\n", Lon0N,Lat0N);
    fprintf(GoogleFile, "%f,%f,8000.0\n", Lon00,Lat00);
    fprintf(GoogleFile,"</coordinates>\n");
    fprintf(GoogleFile,"</LineString>\n");
    fprintf(GoogleFile,"</Placemark>\n");
    fprintf(GoogleFile,"</kml>\n");

    fclose(GoogleFile);
    } else {
    fprintf(TmpFile, "HEADER KO\n");
    fclose(TmpFile);
    }

  return 1;
}        /*main */
