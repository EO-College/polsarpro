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

Description :  Create a scatter-plot file with borders

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
void define_borders(float **border_im, char *Type, int nlig, int ncol, float value);

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
  char BorderType[100];

  int lig, col, ll, cc, n;
  int Nll, Ncc;
  int flagstop;

  float MinX, MaxX;
  float MinY, MaxY;
  float MinZ, MaxZ, MaxZZ;
  float XX[200], YY[200], dX, dY;

  int iMinX, iMaxX, iMinY, iMaxY;
//int iMinZ, iMaxZ;
  int Nctr = 10;
  float k, m, X;
  float NctrStart, NctrIncr;
  float en1,al1,en2,al2,en3,al3,en4,al4,an1;

  /* ARRAYS */
  float *bufferdataX;
  float *bufferdataY;

  float **dataout;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_scatterplot_borders.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifbX	input binary file X\n");
strcat(UsageHelp," (string)	-iftX	input text file X\n");
strcat(UsageHelp," (string)	-ifbY	input binary file Y\n");
strcat(UsageHelp," (string)	-iftY	input text file Y\n");
strcat(UsageHelp," (string)	-ofb 	output binary file\n");
strcat(UsageHelp," (string)	-oft 	output text file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-bord	Border Type (HAlpha, HA, AAlpha, HAlphaDual)\n");
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
  get_commandline_prm(argc,argv,"-bord",str_cmd_prm,BorderType,1,UsageHelp);
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
/* WRITE BORDERS */
/*******************************************************************/ 
//  define_borders(dataout, BorderType, Nll, Ncc, ceil(MaxZ + 0.5));

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

if (strcmp(BorderType,"LogCumul") == 0) {
  float Y[151] = {
0.000000, 0.141536, 0.200325, 0.245529, 0.283738, 0.317453, 0.348005,
0.376162, 0.402420, 0.427169, 0.450612, 0.472910, 0.494303, 0.514837,
0.534529, 0.553656, 0.572295, 0.590136, 0.607833, 0.624663, 0.641423,
0.657582, 0.673409, 0.689236, 0.704214, 0.719114, 0.734014, 0.748346,
0.762325, 0.776305, 0.790284, 0.803733, 0.816799, 0.829864, 0.842930,
0.855996, 0.868540, 0.880699, 0.892859, 0.905018, 0.917177, 0.929337,
0.941248, 0.952510, 0.963772, 0.975034, 0.986295, 0.997557, 1.008819,
1.020081, 1.031153, 1.041527, 1.051901, 1.062275, 1.072650, 1.083024,
1.093398, 1.103772, 1.114146, 1.124520, 1.134894, 1.144663, 1.154160,
1.163657, 1.173155, 1.182652, 1.192149, 1.201646, 1.211144, 1.220641,
1.230138, 1.239635, 1.249133, 1.258630, 1.268127, 1.277070, 1.285702,
1.294335, 1.302967, 1.311600, 1.320233, 1.328865, 1.337498, 1.346130,
1.354763, 1.363395, 1.372028, 1.380661, 1.389293, 1.397926, 1.406558,
1.415191, 1.423823, 1.432456, 1.440763, 1.448544, 1.456326, 1.464107,
1.471889, 1.479670, 1.487452, 1.495233, 1.503015, 1.510796, 1.518578,
1.526359, 1.534141, 1.541922, 1.549704, 1.557485, 1.565267, 1.573048,
1.580830, 1.588611, 1.596393, 1.604174, 1.611956, 1.619737, 1.627519,
1.635300, 1.643082, 1.650745, 1.657690, 1.664636, 1.671581, 1.678527,
1.685472, 1.692418, 1.699364, 1.706309, 1.713255, 1.720200, 1.727146,
1.734091, 1.741037, 1.747982, 1.754928, 1.761873, 1.768819, 1.775765,
1.782710, 1.789656, 1.796601, 1.803547, 1.810492, 1.817438, 1.824383,
1.831329, 1.838274, 1.845220, 1.852165};

/*** Non linear borders ***/
  if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);
  for (n = 0; n < 151; n++) {
    X = n*0.02;
    fprintf(fileoutput,"%f %f %f\n",X,-X,Y[n]);
    }
  fclose(fileoutput);

/*** Vertical Horizontal and borders ***/
  if ((fileoutput = fopen(FileInputBinY, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);
  fprintf(fileoutput,"%f %f\n",0.,0.);
  fprintf(fileoutput,"%f %f\n",0.,3.);
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

/********************************************************************
Routine  : define_borders
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002

*--------------------------------------------------------------------
Description :  Creates decision boundaries in a polar plane
********************************************************************/
void define_borders(float **border_im, char *Type, int nlig, int ncol, float value)
{
  int lig, col, l, c, n;
  float m, al, en, an;
  float X, LCminX, LCmaxX, LCminY, LCmaxY;

/* type_H_alpha */
if (strcmp(Type,"HAlpha") == 0) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * lim_H1)] = value;
    border_im[lig][(int) floor(ncol * lim_H2)] = value;
    }

/* Horizontal borders */
  for (col = 0; col < (int) (0.5 * ncol); col++) {
    l = (int) ((lim_al4 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al3 / 90) * nlig);
    border_im[l][col] = value;
    }
  for (col = (lim_H2 * ncol + 1); col < (0.9 * ncol); col++) {
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al2 / 90) * nlig);
    border_im[l][col] = value;
    }

  for (col = (lim_H1 * ncol + 1); col < ncol; col++) {
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al1 / 90) * nlig);
    border_im[l][col] = value;
    }

/*** Non linear borders ***/
  for (m = 0; m < 0.5; m = m + 1E-3) {
    al = (2 * m) / (1 + 2 * m);
    en = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;

    en = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(2 * m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;
    }
  for (m = 0.5; m < 1; m = m + 1E-3) {
    al = (2 * m) / (1 + 2 * m);
    en = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1)) l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;

    al = 2 / (1 + 2 * m);
    en = ((2 * m - 1) * log(2 * m - 1 + eps) - (2 * m + 1) * log(2 * m + 1)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;
    }
  }

/* type_H_A */
if (strcmp(Type,"HA") == 0) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * lim_H1)] = value;
    border_im[lig][(int) floor(ncol * lim_H2)] = value;
    }

/* Horizontal borders */
  for (col = 0; col < ncol; col++)
    border_im[(int) floor(nlig * lim_A) - 1][col] = value;

/*** Non linear borders ***/
  for (m = 0; m < 1; m = m + 1E-3) {
    an = (1 - m) / (1 + m);
    en = (-2 * log(2 + m) + m * log((m + eps) / (2 + m))) * (-1 / (log(3) * (2 + m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(an * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;
    }
  }

/* type_A_alpha */
if (strcmp(Type,"AAlpha") == 0) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++)
    border_im[lig][(int) floor(ncol * lim_A) - 1] = value;

/* Horizontal borders */
  for (col = 0; col < ncol; col++) {
    l = (int) ((lim_al1 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = value;
    }
  }

/* type_H_alpha_Dual */
if (strcmp(Type,"HAlphaDual") == 0) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * lim_H1)] = value;
    border_im[lig][(int) floor(ncol * lim_H2)] = value;
    }

/* Horizontal borders */
  for (col = 0; col < (int) (0.5 * ncol); col++) {
    l = (int) ((lim_al4 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al3 / 90) * nlig);
    border_im[l][col] = value;
    }
  for (col = (lim_H2 * ncol + 1); col < (0.9 * ncol); col++) {
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al2 / 90) * nlig);
    border_im[l][col] = value;
    }

  for (col = (lim_H1 * ncol + 1); col < ncol; col++) {
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = value;
    l = (int) ((lim_al1 / 90) * nlig);
    border_im[l][col] = value;
    }

/*** Non linear borders ***/
  for (m = 0; m < 1; m = m + 1E-3) {
    al = m / (1 + m);
    en = ((1 + m) * log(1 + m) - m * log(m + eps)) / (log(2) * (1 + m));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;
    }
  for (m = 0; m < 1; m = m + 1E-3) {
    al = 1 / (1 + m);
    en = ((1 + m) * log(1 + m) - m * log(m + eps)) / (log(2) * (1 + m));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = value;
    }
  }
  
/* type_log_cumulant */
if (strcmp(Type,"LogCumul") == 0) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * 0.5)] = value;
    }

/*** Non linear borders ***/
  LCminX = -3.; LCmaxX = 3.; LCminY = 0.; LCmaxY = 3.;
  float Y[151] = {
0.000000, 0.141536, 0.200325, 0.245529, 0.283738, 0.317453, 0.348005,
0.376162, 0.402420, 0.427169, 0.450612, 0.472910, 0.494303, 0.514837,
0.534529, 0.553656, 0.572295, 0.590136, 0.607833, 0.624663, 0.641423,
0.657582, 0.673409, 0.689236, 0.704214, 0.719114, 0.734014, 0.748346,
0.762325, 0.776305, 0.790284, 0.803733, 0.816799, 0.829864, 0.842930,
0.855996, 0.868540, 0.880699, 0.892859, 0.905018, 0.917177, 0.929337,
0.941248, 0.952510, 0.963772, 0.975034, 0.986295, 0.997557, 1.008819,
1.020081, 1.031153, 1.041527, 1.051901, 1.062275, 1.072650, 1.083024,
1.093398, 1.103772, 1.114146, 1.124520, 1.134894, 1.144663, 1.154160,
1.163657, 1.173155, 1.182652, 1.192149, 1.201646, 1.211144, 1.220641,
1.230138, 1.239635, 1.249133, 1.258630, 1.268127, 1.277070, 1.285702,
1.294335, 1.302967, 1.311600, 1.320233, 1.328865, 1.337498, 1.346130,
1.354763, 1.363395, 1.372028, 1.380661, 1.389293, 1.397926, 1.406558,
1.415191, 1.423823, 1.432456, 1.440763, 1.448544, 1.456326, 1.464107,
1.471889, 1.479670, 1.487452, 1.495233, 1.503015, 1.510796, 1.518578,
1.526359, 1.534141, 1.541922, 1.549704, 1.557485, 1.565267, 1.573048,
1.580830, 1.588611, 1.596393, 1.604174, 1.611956, 1.619737, 1.627519,
1.635300, 1.643082, 1.650745, 1.657690, 1.664636, 1.671581, 1.678527,
1.685472, 1.692418, 1.699364, 1.706309, 1.713255, 1.720200, 1.727146,
1.734091, 1.741037, 1.747982, 1.754928, 1.761873, 1.768819, 1.775765,
1.782710, 1.789656, 1.796601, 1.803547, 1.810492, 1.817438, 1.824383,
1.831329, 1.838274, 1.845220, 1.852165};

  for (n = 0; n < 151; n++) {
    X = n*0.02;
    c = (int) (ncol*(X-LCminX)/(LCmaxX-LCminX));
    l = (int) (nlig*(Y[n]-LCminY)/(LCmaxY-LCminY));
    if (c < 0) c = 0; if (c > ncol - 1) c = ncol - 1;
    if (l < 0) l = 0; if (l > nlig - 1) l = nlig - 1;
    border_im[l][c] = value;
    c = (int) (ncol*(-X-LCminX)/(LCmaxX-LCminX));
    l = (int) (nlig*(Y[n]-LCminY)/(LCmaxY-LCminY));
    if (c < 0) c = 0; if (c > ncol - 1) c = ncol - 1;
    if (l < 0) l = 0; if (l > nlig - 1) l = nlig - 1;
    border_im[l][c] = value;
    }
  }
}

