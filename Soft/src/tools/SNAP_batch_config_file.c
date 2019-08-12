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

File     : SNAP_batch_config_file.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2011
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

Description :  Create the SNAP_Batch-Process config file

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
  
  char SNAPParameterName[FilePathLength], SNAPParameterFile[FilePathLength];
  char SNAPLeaderFile[FilePathLength], SNAPDEMFile[FilePathLength];
  char SNAPResamplingDEM[FilePathLength], SNAPResamplingIMG[FilePathLength];
  char SNAPBatchProcessFile[FilePathLength], SNAPBatchOutputDir[FilePathLength];
  char SNAPDEM[1000], SNAPRadioCorrec[1000], SNAPSensor[1000];
  float SNAPPixelSize, SNAPPixelSizeDeg;
  int SNAPMlkRgIn, SNAPMlkAzIn, SNAPMlkRgOut, SNAPMlkAzOut;
  int SNAPSaveDEM, SNAPSaveIncAng, SNAPSaveProjIncAng;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nSNAP_batch_config_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ob  	output SNAP batch process config file name\n");
strcat(UsageHelp," (string)	-od  	output SNAP batch output directory\n");
strcat(UsageHelp," (string)	-ilf 	input leader file\n");
strcat(UsageHelp," (string)	-img 	image resampling method\n");
strcat(UsageHelp," (string)	-dms 	DEM type\n");
strcat(UsageHelp," if DEM type = external\n");
strcat(UsageHelp," (string)	-dmf 	DEM file\n");
strcat(UsageHelp," (string)	-dmr 	DEM resampling method\n");
strcat(UsageHelp," (int)   	-sdm 	save DEM file (0/1)\n");
strcat(UsageHelp," (int)   	-sia 	save incidence angle file (0/1)\n");
strcat(UsageHelp," (int)   	-spi 	save projected incidence angle file (0/1)\n");
strcat(UsageHelp," (float) 	-pix 	pixel size\n");
strcat(UsageHelp," (string)	-ipf 	input parameter file name\n");
strcat(UsageHelp," (string)	-ipn 	input parameter name\n");
strcat(UsageHelp," (string)	-ss  	sensor\n");
strcat(UsageHelp," (int)   	-mrgi	input multilook in range\n");
strcat(UsageHelp," (int)   	-mazi	input multilook in azimut\n");
strcat(UsageHelp," (int)   	-mrgo	output multilook in range\n");
strcat(UsageHelp," (int)   	-mazo	output multilook in azimut\n");
strcat(UsageHelp," (string)	-rad 	radiometric correction type\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 37) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ob",str_cmd_prm,SNAPBatchProcessFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,SNAPBatchOutputDir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ilf",str_cmd_prm,SNAPLeaderFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-img",str_cmd_prm,SNAPResamplingIMG,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dms",str_cmd_prm,SNAPDEM,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dmr",str_cmd_prm,SNAPResamplingDEM,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sdm",int_cmd_prm,&SNAPSaveDEM,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sia",int_cmd_prm,&SNAPSaveIncAng,1,UsageHelp);
  get_commandline_prm(argc,argv,"-spi",int_cmd_prm,&SNAPSaveProjIncAng,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pix",flt_cmd_prm,&SNAPPixelSize,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ipf",str_cmd_prm,SNAPParameterFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ipn",str_cmd_prm,SNAPParameterName,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ss",str_cmd_prm,SNAPSensor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mrgi",int_cmd_prm,&SNAPMlkRgIn,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mazi",int_cmd_prm,&SNAPMlkAzIn,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mrgo",int_cmd_prm,&SNAPMlkRgOut,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mazo",int_cmd_prm,&SNAPMlkAzOut,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rad",str_cmd_prm,SNAPRadioCorrec,1,UsageHelp);

  if (strcmp(SNAPDEM,"external")==0)
    get_commandline_prm(argc,argv,"-dmf",str_cmd_prm,SNAPDEMFile,0,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(SNAPBatchProcessFile);
  check_file(SNAPLeaderFile);
  check_dir(SNAPBatchOutputDir);
  check_file(SNAPParameterFile);
  if (strcmp(SNAPDEM,"external")==0) check_file(SNAPDEMFile);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  if ((filename = fopen(SNAPBatchProcessFile, "w")) == NULL)
    edit_error("Could not open output file : ", SNAPBatchProcessFile);

  fprintf(filename,"<graph id=\"Graph\">\n");
  fprintf(filename,"  <version>1.0</version>\n");

  fprintf(filename,"  <node id=\"Read\">\n");
  fprintf(filename,"   <operator>Read</operator>\n");
  fprintf(filename,"    <sources/>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <file>"); fprintf(filename,"%s.hdr",SNAPParameterFile); fprintf(filename,"</file>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");

  if ((strcmp(SNAPSensor,"S1A")==0)||(strcmp(SNAPSensor,"S1B")==0)) {
    fprintf(filename,"  <node id=\"Multilook\">\n");
    fprintf(filename,"    <operator>Multilook</operator>\n");
    fprintf(filename,"    <sources>\n");
    fprintf(filename,"      <sourceProduct refid=\"Read\"/>\n");
    fprintf(filename,"    </sources>\n");
    fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
    fprintf(filename,"      <sourceBands>target.bin</sourceBands>\n");
    fprintf(filename,"      <nRgLooks>"); fprintf(filename,"%i",SNAPMlkRgOut); fprintf(filename,"</nRgLooks>\n");
    fprintf(filename,"      <nAzLooks>"); fprintf(filename,"%i",SNAPMlkAzOut); fprintf(filename,"</nAzLooks>\n");
    fprintf(filename,"      <outputIntensity>true</outputIntensity>\n");
    fprintf(filename,"      <grSquarePixel>false</grSquarePixel>\n");
    fprintf(filename,"    </parameters>\n");
    fprintf(filename,"  </node>\n");

    fprintf(filename,"  <node id=\"Terrain-Correction\">\n");
    fprintf(filename,"    <operator>Terrain-Correction</operator>\n");
    fprintf(filename,"    <sources>\n");
    fprintf(filename,"      <sourceProduct refid=\"Multilook\"/>\n");
    fprintf(filename,"    </sources>\n");
    } else {  
    fprintf(filename,"  <node id=\"Read(2)\">\n");
    fprintf(filename,"   <operator>Read</operator>\n");
    fprintf(filename,"    <sources/>\n");
    fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
    fprintf(filename,"      <file>"); fprintf(filename,"%s",SNAPLeaderFile); fprintf(filename,"</file>\n");
    fprintf(filename,"   </parameters>\n");
    fprintf(filename,"  </node>\n");

    fprintf(filename,"  <node id=\"Multilook\">\n");
    fprintf(filename,"    <operator>Multilook</operator>\n");
    fprintf(filename,"    <sources>\n");
    fprintf(filename,"      <sourceProduct refid=\"Read(2)\"/>\n");
    fprintf(filename,"    </sources>\n");
    fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
    fprintf(filename,"      <sourceBands/>\n");
    fprintf(filename,"      <nRgLooks>"); fprintf(filename,"%i",SNAPMlkRgIn); fprintf(filename,"</nRgLooks>\n");
    fprintf(filename,"      <nAzLooks>"); fprintf(filename,"%i",SNAPMlkAzIn); fprintf(filename,"</nAzLooks>\n");
    fprintf(filename,"      <outputIntensity>false</outputIntensity>\n");
    fprintf(filename,"      <grSquarePixel>false</grSquarePixel>\n");
    fprintf(filename,"    </parameters>\n");
    fprintf(filename,"  </node>\n");
  
    fprintf(filename,"  <node id=\"ReplaceMetadata\">\n");
    fprintf(filename,"    <operator>ReplaceMetadata</operator>\n");
    fprintf(filename,"    <sources>\n");
    fprintf(filename,"      <sourceProduct refid=\"Read\"/>\n");
    fprintf(filename,"      <sourceProduct.1 refid=\"Multilook\"/>\n");
    fprintf(filename,"    </sources>\n");
    fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
    fprintf(filename,"    </parameters>\n");
    fprintf(filename,"  </node>\n");

    fprintf(filename,"  <node id=\"Multilook(2)\">\n");
    fprintf(filename,"    <operator>Multilook</operator>\n");
    fprintf(filename,"    <sources>\n");
    fprintf(filename,"      <sourceProduct refid=\"ReplaceMetadata\"/>\n");
    fprintf(filename,"    </sources>\n");
    fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
    fprintf(filename,"      <sourceBands/>\n");
    fprintf(filename,"      <nRgLooks>"); fprintf(filename,"%i",SNAPMlkRgOut); fprintf(filename,"</nRgLooks>\n");
    fprintf(filename,"      <nAzLooks>"); fprintf(filename,"%i",SNAPMlkAzOut); fprintf(filename,"</nAzLooks>\n");
    fprintf(filename,"      <outputIntensity>false</outputIntensity>\n");
    fprintf(filename,"      <grSquarePixel>false</grSquarePixel>\n");
    fprintf(filename,"    </parameters>\n");
    fprintf(filename,"  </node>\n");
    
    fprintf(filename,"  <node id=\"Terrain-Correction\">\n");
    fprintf(filename,"    <operator>Terrain-Correction</operator>\n");
    fprintf(filename,"    <sources>\n");
    fprintf(filename,"      <sourceProduct refid=\"Multilook(2)\"/>\n");
    fprintf(filename,"    </sources>\n");
    }  
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <sourceBands/>\n");
  if (strcmp(SNAPDEM,"srtm")==0) {
    fprintf(filename,"      <demName>SRTM 3Sec</demName>\n");
    fprintf(filename,"      <externalDEMFile/>\n");
    }
  if (strcmp(SNAPDEM,"aster")==0) {
    fprintf(filename,"      <demName>ASTER 1sec GDEM</demName>\n");
    fprintf(filename,"      <externalDEMFile/>\n");
    }
  if (strcmp(SNAPDEM,"external")==0) {
    fprintf(filename,"      <demName>External</demName>\n");
    fprintf(filename,"      <externalDEMFile>"); fprintf(filename,"%s",SNAPDEMFile); fprintf(filename,"</externalDEMFile>\n");
    }
  fprintf(filename,"      <externalDEMNoDataValue>0.0</externalDEMNoDataValue>\n");
  fprintf(filename,"      <demResamplingMethod>"); fprintf(filename,"%s",SNAPResamplingDEM); fprintf(filename,"</demResamplingMethod>\n");
  fprintf(filename,"      <imgResamplingMethod>"); fprintf(filename,"%s",SNAPResamplingIMG); fprintf(filename,"</imgResamplingMethod>\n");
  fprintf(filename,"      <pixelSpacingInMeter>"); fprintf(filename,"%f",SNAPPixelSize); fprintf(filename,"</pixelSpacingInMeter>\n");
  SNAPPixelSizeDeg = (SNAPPixelSize / 6378137.0) * (180.0 / pi);
  fprintf(filename,"      <pixelSpacingInDegree>"); fprintf(filename,"%e",SNAPPixelSizeDeg); fprintf(filename,"</pixelSpacingInDegree>\n");
  fprintf(filename,"      <mapProjection>WGS84(DD)</mapProjection>\n");
  fprintf(filename,"      <nodataValueAtSea>false</nodataValueAtSea>\n");
  if (SNAPSaveDEM == 0) fprintf(filename,"      <saveDEM>false</saveDEM>\n");
  if (SNAPSaveDEM == 1) fprintf(filename,"      <saveDEM>true</saveDEM>\n");
  if (SNAPSaveIncAng == 0) fprintf(filename,"      <saveLocalIncidenceAngle>false</saveLocalIncidenceAngle>\n");
  if (SNAPSaveIncAng == 1) fprintf(filename,"      <saveLocalIncidenceAngle>true</saveLocalIncidenceAngle>\n");
  if (SNAPSaveProjIncAng == 0) fprintf(filename,"      <saveProjectedLocalIncidenceAngle>false</saveProjectedLocalIncidenceAngle>\n");
  if (SNAPSaveProjIncAng == 1) fprintf(filename,"      <saveProjectedLocalIncidenceAngle>true</saveProjectedLocalIncidenceAngle>\n");
  fprintf(filename,"      <saveSelectedSourceBand>true</saveSelectedSourceBand>\n");
  if (strcmp(SNAPRadioCorrec,"none")==0) {
    fprintf(filename,"      <applyRadiometricNormalization>false</applyRadiometricNormalization>\n");
    fprintf(filename,"      <saveSigmaNought>false</saveSigmaNought>\n");
    fprintf(filename,"      <saveGammaNought>false</saveGammaNought>\n");
    fprintf(filename,"      <saveBetaNought>false</saveBetaNought>\n");
    fprintf(filename,"      <incidenceAngleForSigma0>Use projected local incidence angle from DEM</incidenceAngleForSigma0>\n");
    fprintf(filename,"      <incidenceAngleForGamma0>Use projected local incidence angle from DEM</incidenceAngleForGamma0>\n");
    } else {
    fprintf(filename,"      <applyRadiometricNormalization>true</applyRadiometricNormalization>\n");
    fprintf(filename,"      <saveSigmaNought>true</saveSigmaNought>\n");
    fprintf(filename,"      <saveGammaNought>false</saveGammaNought>\n");
    fprintf(filename,"      <saveBetaNought>false</saveBetaNought>\n");
    if (strcmp(SNAPRadioCorrec,"projincang")==0) fprintf(filename,"      <incidenceAngleForSigma0>Use projected local incidence angle from DEM</incidenceAngleForSigma0>\n");
    if (strcmp(SNAPRadioCorrec,"incang")==0) fprintf(filename,"      <incidenceAngleForSigma0>Use local incidence angle from DEM</incidenceAngleForSigma0>\n");
    if (strcmp(SNAPRadioCorrec,"ellincang")==0) fprintf(filename,"      <incidenceAngleForSigma0>Use incidence angle from Ellipsoid</incidenceAngleForSigma0>\n");
    fprintf(filename,"      <incidenceAngleForGamma0>Use projected local incidence angle from DEM</incidenceAngleForGamma0>\n");
    }
  fprintf(filename,"      <auxFile>Latest Auxiliary File</auxFile>\n");
  fprintf(filename,"      <externalAuxFile/>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");
    
  fprintf(filename,"  <node id=\"Write\">\n");
  fprintf(filename,"    <operator>Write</operator>\n");
  fprintf(filename,"    <sources>\n");
  fprintf(filename,"      <sourceProduct refid=\"Terrain-Correction\"/>\n");
  fprintf(filename,"    </sources>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <formatName>PolSARPro</formatName>\n");
  fprintf(filename,"      <file>"); fprintf(filename,"%s",SNAPBatchOutputDir); fprintf(filename,"target</file>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");  
  fprintf(filename,"</graph>\n");

  fclose(filename);

  return 1;
}
