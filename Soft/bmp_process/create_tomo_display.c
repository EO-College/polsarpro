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

File     : create_tomo_display.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2014
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

Description :  Create a Tomo Display file

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

  char FileOutputBin[FilePathLength], FileOutputTxt[FilePathLength];
  char FileInputBinX[FilePathLength], FileInputTxtX[FilePathLength];
  char FileInputGrdZ[FilePathLength], FileInputTopZ[FilePathLength];

  int lig, col, ll, cc;
  int Nll, Ncc;
  int flagstop;
  int flagtop, flaggrd;

  float MinX, MaxX;
  float MinY, MaxY;
  double MinZ, MaxZ, MinZZ, MaxZZ;
  float XX[400], YY[200], dX, dY;

  int iMinX, iMaxX, iMinY, iMaxY;
//  int iMinZ, iMaxZ;
  int Nctr = 100;
  float k;
  float NctrStart, NctrIncr;

  /* ARRAYS */
  float **bufferdataX;
  float **dataout;
  float *profilegrd;
  float *profiletop;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_tomo_display.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifb 	input data binary file\n");
strcat(UsageHelp," (string)	-ift 	input data text file\n");
strcat(UsageHelp," (string)	-igf 	input ground binary file\n");
strcat(UsageHelp," (string)	-itf 	input top binary file\n");
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
  get_commandline_prm(argc,argv,"-ifb",str_cmd_prm,FileInputBinX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ift",str_cmd_prm,FileInputTxtX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-igf",str_cmd_prm,FileInputGrdZ,1,UsageHelp);
  get_commandline_prm(argc,argv,"-itf",str_cmd_prm,FileInputTopZ,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofb",str_cmd_prm,FileOutputBin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,FileOutputTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  }
  
  flagtop = 0;
  if (strcmp(FileInputTopZ, "nofile") != 0) flagtop = 1;
  flaggrd = 0;
  if (strcmp(FileInputGrdZ, "nofile") != 0) flaggrd = 1;

/********************************************************************
********************************************************************/

  Nll = 200;
  Ncc = 400;
  
  dataout = matrix_float(Nll, Ncc);

  bufferdataX = matrix_float(Nlig,Ncol);
  profilegrd = vector_float(Ncol);
  profiletop = vector_float(Ncol);

  check_file(FileInputBinX);
  check_file(FileInputTxtX);
  if (flaggrd == 1) check_file(FileInputGrdZ);
  if (flagtop == 1) check_file(FileInputTopZ);
  check_file(FileOutputBin);
  check_file(FileOutputTxt);

/*******************************************************************/
/* INPUT BINARY DATA FILE */
/*******************************************************************/
  if ((fileinput = fopen(FileInputTxtX, "r")) == NULL)
    edit_error("Could not open input file : ", FileInputTxtX);
  fscanf(fileinput,"%f\n",&MinX);
  fscanf(fileinput,"%f\n",&MaxX);
  fscanf(fileinput,"%f\n",&MinY);
  fscanf(fileinput,"%f\n",&MaxY);
  fclose(fileinput);

  dX = (MaxX - MinX) / 399.;
  for (cc = 0; cc < Ncc; cc++) XX[cc] = MinX + dX * (float)cc;

  dY = (MaxY - MinY) / 199.;
  for (ll = 0; ll < Nll; ll++) YY[ll] = MinY + dY * (float)ll;

/*******************************************************************/
/*******************************************************************/

  if ((fileinput = fopen(FileInputBinX, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);
  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&bufferdataX[lig][0], sizeof(float), Ncol, fileinput);
    }
  fclose(fileinput);
  for (ll = 0; ll < Nll; ll++) {
    for (cc = 0; cc < Ncc; cc++) {
      lig = ceil((Nlig-1)*ll/(Nll-1));
      if (lig < 0) lig = 0; if (lig > Nlig - 1) lig = Nlig - 1;
      col = ceil((Ncol-1)*cc/(Ncc-1));
      if (col < 0) col = 0; if (col > Ncol - 1) col = Ncol - 1;
      dataout[ll][cc] = bufferdataX[lig][col];
      }
    }

/*******************************************************************/

/* AUTOMATIC DETERMINATION OF MIN AND MAX */
  MinZ = INIT_MINMAX; MaxZ = -MinZ;
  for (ll = 0; ll < Nll; ll++) {
    for (cc = 0; cc < Ncc; cc++) {
      if (dataout[ll][cc] > MaxZ) MaxZ = dataout[ll][cc];
      if (dataout[ll][cc] < MinZ) MinZ = dataout[ll][cc];
      }
    }

  flagstop = 0;
  MaxZZ = floor(MaxZ);
  while (flagstop == 0) {
    MaxZZ = MaxZZ + 0.5;
    if (MaxZZ > MaxZ) flagstop = 1;
    }

  flagstop = 0;
  MinZZ = floor(MinZ);
  while (flagstop == 0) {
    MinZZ = MinZZ - 0.5;
    if (MinZZ < MinZ) flagstop = 1;
    }

/*******************************************************************/
/* GROUND & TOP Profiles */
/*******************************************************************/
  if ((flagtop == 1)&&(flaggrd == 1)) {
    if ((fileinput = fopen(FileInputGrdZ, "rb")) == NULL)
      edit_error("Could not open input file : ", FileInputGrdZ);
    fread(&profilegrd[0], sizeof(float), Ncol, fileinput);
    fclose(fileinput);

    if ((fileinput = fopen(FileInputTopZ, "rb")) == NULL)
      edit_error("Could not open input file : ", FileInputTopZ);
    fread(&profiletop[0], sizeof(float), Ncol, fileinput);
    fclose(fileinput);
    
    if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
      edit_error("Could not open input file : ", FileInputBinX);
    for (cc = 0; cc < Ncc; cc++) {
      col = ceil(cc*(Ncol-1)/(Ncc-1)); 
      if (col < 0) col = 0; if (col > Ncol-1) col = Ncol - 1;
      fprintf(fileoutput, "%f %f %f\n",XX[cc],profilegrd[col],profiletop[col]);
      }
    fclose(fileoutput);
    }
  if ((flagtop == 1)&&(flaggrd == 0)) {
    if ((fileinput = fopen(FileInputTopZ, "rb")) == NULL)
      edit_error("Could not open input file : ", FileInputTopZ);
    fread(&profiletop[0], sizeof(float), Ncol, fileinput);
    fclose(fileinput);
    
    if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
      edit_error("Could not open input file : ", FileInputBinX);
    for (cc = 0; cc < Ncc; cc++) {
      col = ceil(cc*(Ncol-1)/(Ncc-1)); 
      if (col < 0) col = 0; if (col > Ncol-1) col = Ncol - 1;
      fprintf(fileoutput, "%f %f\n",XX[cc],profiletop[col]);
      }
    fclose(fileoutput);
    }
  if ((flagtop == 0)&&(flaggrd == 1)) {
    if ((fileinput = fopen(FileInputGrdZ, "rb")) == NULL)
      edit_error("Could not open input file : ", FileInputGrdZ);
    fread(&profilegrd[0], sizeof(float), Ncol, fileinput);
    fclose(fileinput);
    
    if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
      edit_error("Could not open input file : ", FileInputBinX);
    for (cc = 0; cc < Ncc; cc++) {
      col = ceil(cc*(Ncol-1)/(Ncc-1)); 
      if (col < 0) col = 0; if (col > Ncol-1) col = Ncol - 1;
      fprintf(fileoutput, "%f %f\n",XX[cc],profilegrd[col]);
      }
    fclose(fileoutput);
    }
    
/*******************************************************************/
/* OUTPUT FILE CREATION */
/*******************************************************************/

 iMinX = (int) floor(MinX + 0.5);
 iMaxX = (int) floor(MaxX + 0.5);
 iMinY = (int) floor(MinY + 0.5);
 iMaxY = (int) floor(MaxY + 0.5);
// iMinZ = (int) MinZZ; iMaxZ = (int) MaxZZ;
 NctrStart = MinZ;
 NctrIncr = (float)(MaxZZ-MinZZ)/((float)Nctr-1);
 
 if ((fileoutput = fopen(FileOutputTxt, "w")) == NULL)
  edit_error("Could not open input file : ", FileOutputTxt);
 fprintf(fileoutput, "%i\n", Ncc);
 fprintf(fileoutput, "%i\n", iMinX);fprintf(fileoutput, "%i\n", iMaxX);
 fprintf(fileoutput, "%i\n", Nll);
 fprintf(fileoutput, "%i\n", iMinY);fprintf(fileoutput, "%i\n", iMaxY);
 fprintf(fileoutput, "%f\n", MinZZ);fprintf(fileoutput, "%f\n", MaxZZ);
 fprintf(fileoutput, "%f\n", MinZ);fprintf(fileoutput, "%f\n", MaxZ);
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
