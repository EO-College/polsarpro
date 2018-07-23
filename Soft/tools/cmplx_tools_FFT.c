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

File   : cmplx_tools_FFT.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  FFT Cmplx data file processing

********************************************************************/
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
FILE *fileinput;
FILE *fileoutput;

/* GLOBAL ARRAYS */
float *bufferdata;
float *datatmp;

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
  char DirInput[FilePathLength], DirOutput[FilePathLength];
  char FileInput[FilePathLength], FileOutput[FilePathLength];

  int lig, col;
  int Nfft, Nffts2;
  int Sub_NcolS2;
  int InputFFTShift, OutputFFTShift;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncmplx_tools_FFT.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nfft	Nfft\n");
strcat(UsageHelp," (int)   	-ifft	Input FFT shift (1=yes, 0=no)\n");
strcat(UsageHelp," (int)   	-offt	Output FFT shift (1=yes, 0=no)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,DirInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,DirOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileInput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileOutput,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nfft",int_cmd_prm,&Nfft,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifft",int_cmd_prm,&InputFFTShift,1,UsageHelp);
  get_commandline_prm(argc,argv,"-offt",int_cmd_prm,&OutputFFTShift,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(DirInput);
  check_dir(DirOutput);
  check_file(FileInput);
  check_file(FileOutput);

  read_config(DirInput, &Nlig, &Ncol, PolarCase, PolarType);

  bufferdata = vector_float(2 * Nfft);
  datatmp = vector_float(2 * Nfft);

  Nffts2 = floor(Nfft / 2);
  Sub_NcolS2 = floor(Sub_Ncol / 2);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);

/*******************************************************************/
/* OUTPUT BINARY DATA FILE */
/*******************************************************************/

/* WRITE OUTPUT DATA FILE */
  if ((fileoutput = fopen(FileOutput, "wb")) == NULL)
    edit_error("Could not open input file : ", FileOutput);

  write_config(DirOutput, Sub_Nlig, Nfft, PolarCase, PolarType);

/*******************************************************************/

  for (lig = 0; lig < Off_lig; lig++)
    fread(&bufferdata[0], sizeof(float), 2 * Ncol, fileinput);

  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    fread(&bufferdata[0], sizeof(float), 2 * Ncol, fileinput);

    for (col = 0; col < Sub_Ncol; col++) {
      datatmp[2 * col] = bufferdata[2 * (col + Off_col)];
      datatmp[2 * col + 1] = bufferdata[2 * (col + Off_col) + 1];
      }
    for (col = 0; col < 2 * Nfft; col++) bufferdata[col] = 0.;

    if (InputFFTShift == 1) {
      for (col = 0; col < Sub_NcolS2; col++) {
        bufferdata[2 * col] = datatmp[2 * (col + Sub_NcolS2)];
        bufferdata[2 * col + 1] = datatmp[2 * (col + Sub_NcolS2) + 1];
        bufferdata[2 * (col + Nfft - Sub_NcolS2)] = datatmp[2 * col];
        bufferdata[2 * (col + Nfft - Sub_NcolS2) + 1] = datatmp[2 * col + 1];
        }
      } else {
      for (col = 0; col < 2 * Sub_Ncol; col++) bufferdata[col] = datatmp[col];
      }

    Fft(&bufferdata[0], Nfft, +1L);

    if (OutputFFTShift == 1) {
      for (col = 0; col < 2 * Nfft; col++) datatmp[col] = bufferdata[col];
      for (col = 0; col < Nffts2; col++) {
        bufferdata[2 * col] = datatmp[2 * (col + Nffts2)];
        bufferdata[2 * col + 1] = datatmp[2 * (col + Nffts2) + 1];
        bufferdata[2 * (col + Nffts2)] = datatmp[2 * col];
        bufferdata[2 * (col + Nffts2) + 1] = datatmp[2 * col + 1];
        }
      }
    fwrite(&bufferdata[0], sizeof(float), 2 * Nfft, fileoutput);
    }

  fclose(fileinput);
  fclose(fileoutput);

  return 1;
}
