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

File     : create_scatterplot.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
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

Description :  Create a scatter-plot file

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

  /* ACCESS FILE */
  FILE *fileinput, *fileoutput;
  FILE *fileinputX, *fileinputY;

  char FileOutputBin[FilePathLength], FileOutputTxt[FilePathLength];
  char FileInputBinX[FilePathLength], FileInputTxtX[FilePathLength];
  char FileInputBinY[FilePathLength], FileInputTxtY[FilePathLength];

  int lig, col, ll, cc;
  int Nll, Ncc;
  int flagstop;

  float MinX, MaxX;
  float MinY, MaxY;
  float MinZ, MaxZ, MaxZZ;
  float XX[200], YY[200], dX, dY;

  int iMinX, iMaxX, iMinY, iMaxY;
//int iMinZ, iMaxZ;
  int Nctr = 10;
  float k;
  float NctrStart, NctrIncr;

  /* ARRAYS */
  float *bufferdataX;
  float *bufferdataY;

  float **dataout;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_scatterplot.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifbX	input binary file X\n");
strcat(UsageHelp," (string)	-iftX	input text file X\n");
strcat(UsageHelp," (string)	-ifbY	input binary file Y\n");
strcat(UsageHelp," (string)	-iftY	input text file Y\n");
strcat(UsageHelp," (string)	-ofb 	output binary file\n");
strcat(UsageHelp," (string)	-oft 	output text file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifbX",str_cmd_prm,FileInputBinX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iftX",str_cmd_prm,FileInputTxtX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifbY",str_cmd_prm,FileInputBinY,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iftY",str_cmd_prm,FileInputTxtY,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofb",str_cmd_prm,FileOutputBin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,FileOutputTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  Nll = 200;
  Ncc = 200;
  
  dataout = matrix_float(Nll, Ncc);

  bufferdataX = vector_float(Ncol);
  bufferdataY = vector_float(Ncol);

  check_file(FileInputBinX);
  check_file(FileInputTxtX);
  check_file(FileInputBinY);
  check_file(FileInputTxtY);
  check_file(FileOutputBin);
  check_file(FileOutputTxt);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/
  if ((fileinput = fopen(FileInputTxtX, "r")) == NULL)
    edit_error("Could not open input file : ", FileInputTxtX);
  fscanf(fileinput,"%f\n",&MinX);
  fscanf(fileinput,"%f\n",&MaxX);
  fclose(fileinput);

  if ((fileinput = fopen(FileInputTxtY, "r")) == NULL)
    edit_error("Could not open input file : ", FileInputTxtX);
  fscanf(fileinput,"%f\n",&MinY);
  fscanf(fileinput,"%f\n",&MaxY);
  fclose(fileinput);

  if ((fileinputX = fopen(FileInputBinX, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);

  if ((fileinputY = fopen(FileInputBinY, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);

  dX = (MaxX - MinX) / 199.;
  for (ll = 0; ll < Nll; ll++) XX[ll] = MinX + dX * (float)ll;

  dY = (MaxY - MinY) / 199.;
  for (ll = 0; ll < Nll; ll++) YY[ll] = MinY + dY * (float)ll;

/*******************************************************************/
/*******************************************************************/

  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&bufferdataX[0], sizeof(float), Ncol, fileinputX);
    fread(&bufferdataY[0], sizeof(float), Ncol, fileinputY);

    for (col = 0; col < Ncol; col++) {
      if (bufferdataX[col] < DATA_NULL) {
        if (bufferdataY[col] < DATA_NULL) {
        cc = (int) floor(bufferdataX[col]);
        if (cc < 0) cc = 0; if (cc > Ncc - 1) cc = Ncc - 1;
        ll = (int) floor(bufferdataY[col]);
        if (ll < 0) ll = 0; if (ll > Nll - 1) ll = Nll - 1;
        dataout[ll][cc] = dataout[ll][cc] + 1.;
        }
      }
    }
  }

  fclose(fileinputX);
  fclose(fileinputY);

/*******************************************************************/

/* AUTOMATIC DETERMINATION OF MIN AND MAX */
  MaxZ = -INIT_MINMAX; MinZ = 0.0;
  for (ll = 0; ll < Nll; ll++) {
    for (cc = 0; cc < Ncc; cc++) {
      if (dataout[ll][cc] <= 1.0) dataout[ll][cc] = 0.0;
      else dataout[ll][cc] = log10(dataout[ll][cc]);
      if (dataout[ll][cc] > MaxZ) MaxZ = dataout[ll][cc];
      }
    }

  flagstop = 0;
  MaxZZ = floor(MaxZ);
  while (flagstop == 0) {
    MaxZZ = MaxZZ + 0.5;
    if (MaxZZ > MaxZ) flagstop = 1;
    }

/*******************************************************************/
/* OUTPUT FILE CREATION */
/*******************************************************************/

 iMinX = (int) floor(MinX + 0.5);
 iMaxX = (int) floor(MaxX + 0.5);
 iMinY = (int) floor(MinY + 0.5);
 iMaxY = (int) floor(MaxY + 0.5);
// iMinZ = 0; iMaxZ = (int) MaxZZ;
 NctrStart = MinZ;
 NctrIncr = (float)(MaxZZ-MinZ)/((float)Nctr-1);
 
 if ((fileoutput = fopen(FileOutputTxt, "w")) == NULL)
  edit_error("Could not open input file : ", FileOutputTxt);
 fprintf(fileoutput, "%i\n", Ncc);
 fprintf(fileoutput, "%i\n", iMinX);fprintf(fileoutput, "%i\n", iMaxX);
 fprintf(fileoutput, "%i\n", Nll);
 fprintf(fileoutput, "%i\n", iMinY);fprintf(fileoutput, "%i\n", iMaxY);
 fprintf(fileoutput, "%f\n", MinZ);fprintf(fileoutput, "%f\n", MaxZZ);
 fprintf(fileoutput, "%f\n", MinZ);fprintf(fileoutput, "%f\n", exp(MaxZ*log(10.)));
 fprintf(fileoutput, "%i\n", Nctr);
 fprintf(fileoutput, "%f\n", NctrStart);fprintf(fileoutput, "%f\n", NctrIncr);
 fclose(fileoutput);
 if ((fileoutput = fopen(FileOutputBin, "wb")) == NULL)
  edit_error("Could not open input file : ", FileOutputBin);
 k = (float)Ncc;
 fwrite(&k,sizeof(float),1,fileoutput);
 fwrite(&XX[0],sizeof(float),Ncc,fileoutput);
 for (ll=0 ; ll<Nll; ll++) {
   fwrite(&YY[ll],sizeof(float),1,fileoutput);
   fwrite(&dataout[ll][0],sizeof(float),Ncc,fileoutput);
   }
 fclose(fileoutput);

  return 1;
}
