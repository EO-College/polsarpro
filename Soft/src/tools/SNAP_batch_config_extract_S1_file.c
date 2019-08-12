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

File     : SNAP_batch_config_extract_S1_file.c
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

Description :  Create the SNAP_Batch-Process config extract S1 file

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
  
  char SNAPParameterFile[FilePathLength];
  char SNAPBatchProcessFile[FilePathLength];
  char SNAPBatchOutputDir[FilePathLength];
  char SNAPSwath[10], SNAPChannel[10];
  int SNAPBurst;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nSNAP_batch_config_extract_S1_file.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ob  	output SNAP batch process config file name\n");
strcat(UsageHelp," (string)	-od  	SNAP batch output directory\n");
strcat(UsageHelp," (string)	-ilf 	input leader file\n");
strcat(UsageHelp," (string)	-sw  	S1 Swath\n");
strcat(UsageHelp," (int)	-bm  	S1 Burst Max\n");
strcat(UsageHelp," (string)	-ch  	S1 polarimetric channel\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ob",str_cmd_prm,SNAPBatchProcessFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,SNAPBatchOutputDir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ipf",str_cmd_prm,SNAPParameterFile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sw",str_cmd_prm,SNAPSwath,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bm",int_cmd_prm,&SNAPBurst,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ch",str_cmd_prm,SNAPChannel,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(SNAPBatchProcessFile);
  check_dir(SNAPBatchOutputDir);
  check_file(SNAPParameterFile);

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
  fprintf(filename,"      <file>"); fprintf(filename,"%s",SNAPParameterFile); fprintf(filename,"</file>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");

  fprintf(filename,"  <node id=\"TOPSAR-Split\">\n");
  fprintf(filename,"    <operator>TOPSAR-Split</operator>\n");
  fprintf(filename,"    <sources>\n");
  fprintf(filename,"      <sourceProduct refid=\"Read\"/>\n");
  fprintf(filename,"    </sources>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <subswath>"); fprintf(filename,"%s",SNAPSwath); fprintf(filename,"</subswath>\n");
  fprintf(filename,"      <selectedPolarisations>"); fprintf(filename,"%s",SNAPChannel); fprintf(filename,"</selectedPolarisations>\n");
  fprintf(filename,"      <firstBurstIndex>1</firstBurstIndex>\n");
  fprintf(filename,"      <lastBurstIndex>"); fprintf(filename,"%i",SNAPBurst); fprintf(filename,"</lastBurstIndex>\n");
  fprintf(filename,"      <wktAoi/>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");

  fprintf(filename,"  <node id=\"Apply-Orbit-File\">\n");
  fprintf(filename,"    <operator>Apply-Orbit-File</operator>\n");
  fprintf(filename,"    <sources>\n");
  fprintf(filename,"      <sourceProduct refid=\"TOPSAR-Split\"/>\n");
  fprintf(filename,"    </sources>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <orbitType>Sentinel Precise (Auto Download)</orbitType>\n");
  fprintf(filename,"      <polyDegree>3</polyDegree>\n");
  fprintf(filename,"      <continueOnFail>true</continueOnFail>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");

  fprintf(filename,"  <node id=\"Calibration\">\n");
  fprintf(filename,"    <operator>Calibration</operator>\n");
  fprintf(filename,"    <sources>\n");
  fprintf(filename,"      <sourceProduct refid=\"Apply-Orbit-File\"/>\n");
  fprintf(filename,"    </sources>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <sourceBands/>\n");
  fprintf(filename,"      <auxFile>Latest Auxiliary File</auxFile>\n");
  fprintf(filename,"      <externalAuxFile/>\n");
  fprintf(filename,"      <outputImageInComplex>true</outputImageInComplex>\n");
  fprintf(filename,"      <outputImageScaleInDb>false</outputImageScaleInDb>\n");
  fprintf(filename,"      <createGammaBand>false</createGammaBand>\n");
  fprintf(filename,"      <createBetaBand>false</createBetaBand>\n");
  fprintf(filename,"      <selectedPolarisations/>\n");
  fprintf(filename,"      <outputSigmaBand>true</outputSigmaBand>\n");
  fprintf(filename,"      <outputGammaBand>false</outputGammaBand>\n");
  fprintf(filename,"      <outputBetaBand>false</outputBetaBand>\n");
//  fprintf(filename,"      <outputDNBand>false</outputDNBand>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");

  fprintf(filename,"  <node id=\"TOPSAR-Deburst\">\n");
  fprintf(filename,"    <operator>TOPSAR-Deburst</operator>\n");
  fprintf(filename,"    <sources>\n");
  fprintf(filename,"      <sourceProduct refid=\"Calibration\"/>\n");
  fprintf(filename,"    </sources>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <selectedPolarisations/>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");

  fprintf(filename,"  <node id=\"Write\">\n");
  fprintf(filename,"    <operator>Write</operator>\n");
  fprintf(filename,"    <sources>\n");
  fprintf(filename,"      <sourceProduct refid=\"TOPSAR-Deburst\"/>\n");
  fprintf(filename,"    </sources>\n");
  fprintf(filename,"    <parameters class=\"com.bc.ceres.binding.dom.XppDomElement\">\n");
  fprintf(filename,"      <formatName>PolSARPro</formatName>\n");
  fprintf(filename,"      <file>"); fprintf(filename,"%s",SNAPBatchOutputDir); fprintf(filename,"S1_Extract</file>\n");
  fprintf(filename,"    </parameters>\n");
  fprintf(filename,"  </node>\n");  
  fprintf(filename,"</graph>\n");

  fclose(filename);

  return 1;
}
