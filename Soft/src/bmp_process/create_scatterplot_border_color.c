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

File     : create_scatterplot_border.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
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

Description :  Create a color scatter-plot file with borders

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS */
#define lim_al1 55.
#define lim_al2 50.
#define lim_al3 48.
#define lim_al4 42.
#define lim_al5 40.
#define lim_H1  0.9
#define lim_H2  0.5
#define lim_A   0.5

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
  FILE *fileinputmaskX, *fileinputmaskY;

  char FileOutputBin[FilePathLength], FileOutputTxt[FilePathLength];
  char FileInputBinX[FilePathLength], FileInputTxtX[FilePathLength];
  char FileInputBinY[FilePathLength], FileInputTxtY[FilePathLength];
  char FileInputMaskX[FilePathLength], FileInputMaskY[FilePathLength];
  char BorderType[100];

  int lig, col, ll, cc, n;
  int Nll, Ncc;

  float MinX, MaxX;
  float MinY, MaxY;
  float MinZ, MaxZ, MaxZZ;
  float XX[400], YY[200], dX, dY;

  int iMinX, iMaxX, iMinY, iMaxY;
//int iMinZ, iMaxZ;
  int Nctr;
  float k, m;
  float NctrStart, NctrIncr;
  float en1,al1,en2,al2,en3,al3,en4,al4,an1;

  /* ARRAYS */
  float *bufferdataX;
  float *bufferdataY;
  float *buffermaskX;
  float *buffermaskY;

  float **dataout;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_scatterplot_borders_color.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifbX	input binary file X\n");
strcat(UsageHelp," (string)	-iftX	input text file X\n");
strcat(UsageHelp," (string)	-ifmX	input mask file X\n");
strcat(UsageHelp," (string)	-ifbY	input binary file Y\n");
strcat(UsageHelp," (string)	-iftY	input text file Y\n");
strcat(UsageHelp," (string)	-ifmY	input mask file Y\n");
strcat(UsageHelp," (string)	-ofb 	output binary file\n");
strcat(UsageHelp," (string)	-oft 	output text file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-bord	Border Type (HAlpha, HA, AAlpha, HAlphaDual, Poincare, Null)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifbX",str_cmd_prm,FileInputBinX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iftX",str_cmd_prm,FileInputTxtX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifmX",str_cmd_prm,FileInputMaskX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifbY",str_cmd_prm,FileInputBinY,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iftY",str_cmd_prm,FileInputTxtY,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ifmY",str_cmd_prm,FileInputMaskY,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofb",str_cmd_prm,FileOutputBin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-oft",str_cmd_prm,FileOutputTxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bord",str_cmd_prm,BorderType,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  Nll = 200;
  Ncc = 200;
  
  dataout = matrix_float(Nll, Ncc);
  for (ll = 0; ll < Nll; ll++) for (cc = 0; cc < Ncc; cc++) dataout[ll][cc] = 0.0;

  bufferdataX = vector_float(Ncol);
  bufferdataY = vector_float(Ncol);
  buffermaskX = vector_float(Ncol);
  buffermaskY = vector_float(Ncol);

  check_file(FileInputBinX);
  check_file(FileInputTxtX);
  check_file(FileInputMaskX);
  check_file(FileInputBinY);
  check_file(FileInputTxtY);
  check_file(FileInputMaskY);
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

  if ((fileinputmaskX = fopen(FileInputMaskX, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInputMaskX);

  if ((fileinputmaskY = fopen(FileInputMaskY, "rb")) == NULL)
    edit_error("Could not open input file : ", FileInputMaskY);
    
  dX = (MaxX - MinX) / 199.;
  for (cc = 0; cc < Ncc; cc++) XX[cc] = MinX + dX * (float)cc;

  dY = (MaxY - MinY) / 199.;
  for (ll = 0; ll < Nll; ll++) YY[ll] = MinY + dY * (float)ll;

/*******************************************************************/
/*******************************************************************/

  for (lig = 0; lig < Nlig; lig++) {
    if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
    fread(&bufferdataX[0], sizeof(float), Ncol, fileinputX);
    fread(&bufferdataY[0], sizeof(float), Ncol, fileinputY);
    fread(&buffermaskX[0], sizeof(float), Ncol, fileinputmaskX);
    fread(&buffermaskY[0], sizeof(float), Ncol, fileinputmaskY);

    for (col = 0; col < Ncol; col++) {
      if (buffermaskX[col] == 1.) {
        if (buffermaskY[col] == 1.) {
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
  fclose(fileinputmaskX);
  fclose(fileinputmaskY);

/*******************************************************************/
/* AUTOMATIC DETERMINATION OF MIN AND MAX */
if (strcmp(BorderType,"HAlpha") == 0) {
  MinZ = 0.0; MaxZ = 9.0; MaxZZ = MaxZ + 0.5;
  for (ll = 0; ll < Nll; ll++) {
    for (cc = 0; cc < Ncc; cc++) {
      if (dataout[ll][cc] != 0.0) {
        if (cc > (int) floor(199. * lim_H1)) {
          if (ll > (int) floor(199. * (lim_al1/90.))) dataout[ll][cc] = 1.0;
          if ((ll <= (int) floor(199. * (lim_al1/90.)))&&(ll > (int) floor(199. * (lim_al5/90.)))) dataout[ll][cc] = 2.0;
          if (ll <= (int) floor(199. * (lim_al5/90.))) dataout[ll][cc] = 3.0;
          }
        if ((cc <= (int) floor(199. * lim_H1))&&(cc > (int) floor(199. * lim_H2))) {
          if (ll > (int) floor(199. * (lim_al2/90.))) dataout[ll][cc] = 4.0;
          if ((ll <= (int) floor(199. * (lim_al2/90.)))&&(ll > (int) floor(199. * (lim_al5/90.)))) dataout[ll][cc] = 5.0;
          if (ll <= (int) floor(199. * (lim_al5/90.))) dataout[ll][cc] = 6.0;
          }
        if (cc <= (int) floor(199. * lim_H2)) {
          if (ll > (int) floor(199. * (lim_al3/90.))) dataout[ll][cc] = 7.0;
          if ((ll <= (int) floor(199. * (lim_al3/90.)))&&(ll > (int) floor(199. * (lim_al4/90.)))) dataout[ll][cc] = 8.0;
          if (ll <= (int) floor(199. * (lim_al4/90.))) dataout[ll][cc] = 9.0;
          }
        }
      }
    }
  }
if (strcmp(BorderType,"HA") == 0) {
  MinZ = 0.0; MaxZ = 6.0; MaxZZ = MaxZ + 0.5;
  for (ll = 0; ll < Nll; ll++) {
    for (cc = 0; cc < Ncc; cc++) {
      if (dataout[ll][cc] != 0.0) {
        if (cc > (int) floor(199. * lim_H1)) {
          if (ll > (int) floor(199. * lim_A)) dataout[ll][cc] = 1.0;
          if (ll <= (int) floor(199. * lim_A)) dataout[ll][cc] = 2.0;
          }
        if ((cc <= (int) floor(199. * lim_H1))&&(cc > (int) floor(199. * lim_H2))) {
          if (ll > (int) floor(199. * lim_A)) dataout[ll][cc] = 3.0;
          if (ll <= (int) floor(199. * lim_A)) dataout[ll][cc] = 4.0;
          }
        if (cc <= (int) floor(199. * lim_H2)) {
          if (ll > (int) floor(199. * lim_A)) dataout[ll][cc] = 5.0;
          if (ll <= (int) floor(199. * lim_A)) dataout[ll][cc] = 6.0;
          }
        }
      }
    }
  }
if (strcmp(BorderType,"AAlpha") == 0) {
  MinZ = 0.0; MaxZ = 6.0; MaxZZ = MaxZ + 0.5;
  for (ll = 0; ll < Nll; ll++) {
    for (cc = 0; cc < Ncc; cc++) {
      if (dataout[ll][cc] != 0.0) {
        if (cc > (int) floor(199. * lim_A)) {
          if (ll > (int) floor(199. * (lim_al1/90.))) dataout[ll][cc] = 1.0;
          if ((ll <= (int) floor(199. * (lim_al1/90.)))&&(ll > (int) floor(199. * (lim_al5/90.)))) dataout[ll][cc] = 2.0;
          if (ll <= (int) floor(199. * (lim_al5/90.))) dataout[ll][cc] = 3.0;
          }
        if (cc <= (int) floor(199. * lim_A)) {
          if (ll > (int) floor(199. * (lim_al1/90.))) dataout[ll][cc] = 4.0;
          if ((ll <= (int) floor(199. * (lim_al1/90.)))&&(ll > (int) floor(199. * (lim_al5/90.)))) dataout[ll][cc] = 5.0;
          if (ll <= (int) floor(199. * (lim_al5/90.))) dataout[ll][cc] = 6.0;
          }
        }
      }
    }
  }

/*******************************************************************/
/* WRITE BORDERS */
/*******************************************************************/ 

if (strcmp(BorderType,"HAlpha") == 0) {
/*** Non linear borders ***/
  if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);
  for (n = 0; n < 500; n++) {
    m = (float)n * 1E-3;
    en1 = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    al1 = (2 * m) / (1 + 2 * m);
    en2 = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(2 * m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    al2 = 1.;
    m = 0.5 + (float)n * 1E-3;
    en3 = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    al3 = (2 * m) / (1 + 2 * m);
    en4 = ((2 * m - 1) * log(2 * m - 1 + eps) - (2 * m + 1) * log(2 * m + 1)) * (-1 / (log(3) * (1 + 2 * m)));
    al4 = 2 / (1 + 2 * m);
    fprintf(fileoutput,"%f %f %f %f %f %f %f %f\n",en1,90.*al1,en2,90.*al2,en3,90.*al3,en4,90.*al4);
    }
  fclose(fileoutput);

/*** Vertical Horizontal and borders ***/
  if ((fileoutput = fopen(FileInputBinY, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);
  fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f %f %f\n",lim_H1,lim_H2,0.,0.,lim_al3,lim_al4,lim_H2,lim_al2,lim_al5,lim_H1,lim_al1,lim_al5);
  fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f %f %f\n",lim_H1,lim_H2,90.,lim_H2,lim_al3,lim_al4,lim_H1,lim_al2,lim_al5,1.,lim_al1,lim_al5);
  fclose(fileoutput);
  }
  
if (strcmp(BorderType,"HA") == 0) {
/*** Non linear borders ***/
  if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);
  for (n = 0; n < 1000; n++) {
    m = (float)n * 1E-3;
    an1 = (1 - m) / (1 + m);
    en1 = (-2 * log(2 + m) + m * log((m + eps) / (2 + m))) * (-1 / (log(3) * (2 + m)));
    fprintf(fileoutput,"%f %f\n",en1,an1);
    }
  fclose(fileoutput);

/*** Vertical Horizontal and borders ***/
  if ((fileoutput = fopen(FileInputBinY, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);
  fprintf(fileoutput,"%f %f %f %f %f\n",lim_H1,lim_H2,0.,0.,lim_A);
  fprintf(fileoutput,"%f %f %f %f %f\n",lim_H1,lim_H2,1.,1.,lim_A);
  fclose(fileoutput);
  }

if (strcmp(BorderType,"AAlpha") == 0) {
/*** Vertical Horizontal and borders ***/
  if ((fileoutput = fopen(FileInputBinY, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);
  fprintf(fileoutput,"%f %f %f %f %f\n",lim_A,0.,0.,lim_al1,lim_al5);
  fprintf(fileoutput,"%f %f %f %f %f\n",lim_A,90.,1.,lim_al1,lim_al5);
  fclose(fileoutput);
  }
  
if (strcmp(BorderType,"HAlphaDual") == 0) {
/*** Non linear borders ***/
  if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);
  for (n = 0; n < 1000; n++) {
    m = (float)n * 1E-3;
    al1 = m / (1 + m);
    en1 = ((1 + m) * log(1 + m) - m * log(m + eps)) / (log(2) * (1 + m));
    al2 = 1 / (1 + m);
    en2 = ((1 + m) * log(1 + m) - m * log(m + eps)) / (log(2) * (1 + m));
    fprintf(fileoutput,"%f %f %f %f\n",en1,90.*al1,en2,90.*al2);
    }
  fclose(fileoutput);

/*** Vertical Horizontal and borders ***/
  if ((fileoutput = fopen(FileInputBinY, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);
  fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f %f %f\n",lim_H1,lim_H2,0.,0.,lim_al3,lim_al4,lim_H2,lim_al2,lim_al5,lim_H1,lim_al1,lim_al5);
  fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f %f %f\n",lim_H1,lim_H2,90.,lim_H2,lim_al3,lim_al4,lim_H1,lim_al2,lim_al5,1.,lim_al1,lim_al5);
  fclose(fileoutput);
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
 NctrIncr = 1;
 
 if ((fileoutput = fopen(FileOutputTxt, "w")) == NULL)
  edit_error("Could not open input file : ", FileOutputTxt);
 fprintf(fileoutput, "%i\n", Ncc);
 fprintf(fileoutput, "%i\n", iMinX);fprintf(fileoutput, "%i\n", iMaxX);
 fprintf(fileoutput, "%i\n", Nll);
 fprintf(fileoutput, "%i\n", iMinY);fprintf(fileoutput, "%i\n", iMaxY);
 fprintf(fileoutput, "%f\n", MinZ);fprintf(fileoutput, "%f\n", MaxZZ);
 fprintf(fileoutput, "%f\n", MinZ);fprintf(fileoutput, "%f\n", MaxZ);
 if (strcmp(BorderType,"HAlpha") == 0) Nctr = 10;
 if (strcmp(BorderType,"HA") == 0) Nctr = 7;
 if (strcmp(BorderType,"AAlpha") == 0) Nctr = 7;
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
