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

Description :  Create a scatter-plot file with borders

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

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
  int flagstop;

  float MinX, MaxX;
  float MinY, MaxY;
  float MinZ, MaxZ, MaxZZ;
  float XX[400], YY[200], dX, dY;

  int iMinX, iMaxX, iMinY, iMaxY;
//int iMinZ, iMaxZ;
  int Nctr = 10;
  float k, m, X;
  float NctrStart, NctrIncr, cc_coeff;
  float en1,al1,en2,al2,en3,al3,en4,al4,an1;
  float phi, tau, delta, psi;
  float pb, pc, pd, signe;
  float xp1, yp1, xp2, yp2, xp3, yp3, xp4, yp4, xp5, yp5;

  /* ARRAYS */
  float *bufferdataX;
  float *bufferdataY;
  float *buffermaskX;
  float *buffermaskY;

  float **dataout;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncreate_scatterplot_borders.exe\n");
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
  cc_coeff = 1.;
  if (strcmp(BorderType,"Poincare") == 0) cc_coeff = 2.;
  Ncc = (int)(200.*cc_coeff);
  
  dataout = matrix_float(Nll, Ncc);

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

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);
  
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
    
  dX = (MaxX - MinX) / (200.*cc_coeff - 1.);
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

if (strcmp(BorderType,"Poincare") == 0) {
/*** Non linear borders ***/
  if ((fileoutput = fopen(FileInputBinX, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinX);
  for (n = 0; n < 500; n++) {
    tau = -pi/4. + (float)n * pi/4./499.;
    phi = -pi/2.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp1 = 2.*pc*cos(pd)*signe;
    yp1 = pc*sin(pd);
    phi = -pi/4.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp2 = 2.*pc*cos(pd)*signe;
    yp2 = pc*sin(pd);
/*
    phi = 0.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp3 = 2.*pc*cos(pd)*signe;
    yp3 = pc*sin(pd);
*/
    xp3 = 0.;
    yp3 = -1. + (float)n / 499.;
    phi = pi/4.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp4 = 2.*pc*cos(pd)*signe;
    yp4 = pc*sin(pd);
    phi = pi/2.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp5 = 2.*pc*cos(pd)*signe;
    yp5 = pc*sin(pd);
    fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f\n",xp1,yp1,xp2,yp2,xp3,yp3,xp4,yp4,xp5,yp5);
    }
  for (n = 0; n < 500; n++) {
    tau = (float)n * pi/4./499.;
    phi = -pi/2.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp1 = 2.*pc*cos(pd)*signe;
    yp1 = pc*sin(pd);
    phi = -pi/4.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp2 = 2.*pc*cos(pd)*signe;
    yp2 = pc*sin(pd);
/*
    phi = 0.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp3 = 2.*pc*cos(pd)*signe;
    yp3 = pc*sin(pd);
*/
    xp3 = 0.;
    yp3 = (float)n / 499.;
    phi = pi/4.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp4 = 2.*pc*cos(pd)*signe;
    yp4 = pc*sin(pd);
    phi = pi/2.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp5 = 2.*pc*cos(pd)*signe;
    yp5 = pc*sin(pd);
    fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f\n",xp1,yp1,xp2,yp2,xp3,yp3,xp4,yp4,xp5,yp5);
    }
  fclose(fileoutput);

/*** Vertical Horizontal and borders ***/
  if ((fileoutput = fopen(FileInputBinY, "wb")) == NULL)
    edit_error("Could not open input file : ", FileInputBinY);
  for (n = 0; n < 500; n++) {
    phi = -pi/2. + (float)n * pi/2./499.;
    tau = -pi/6.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp1 = 2.*pc*cos(pd)*signe;
    yp1 = pc*sin(pd);
    tau = -pi/12.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp2 = 2.*pc*cos(pd)*signe;
    yp2 = pc*sin(pd);
/*
    tau = 0.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp3 = 2.*pc*cos(pd)*signe;
    yp3 = pc*sin(pd);
*/
    xp3 = -2. + (float)n * 2. / 499.;
    yp3 = 0.;
    tau = pi/12.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp4 = 2.*pc*cos(pd)*signe;
    yp4 = pc*sin(pd);
    tau = pi/6.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp5 = 2.*pc*cos(pd)*signe;
    yp5 = pc*sin(pd);
    fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f\n",xp1,yp1,xp2,yp2,xp3,yp3,xp4,yp4,xp5,yp5);
    }
  for (n = 0; n < 500; n++) {
    phi = (float)n * pi/2./499.;
    tau = -pi/6.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp1 = 2.*pc*cos(pd)*signe;
    yp1 = pc*sin(pd);
    tau = -pi/12.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp2 = 2.*pc*cos(pd)*signe;
    yp2 = pc*sin(pd);
/*
    tau = 0.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp3 = 2.*pc*cos(pd)*signe;
    yp3 = pc*sin(pd);
*/
    xp3 = (float)n * 2. / 499.;
    yp3 = 0.;
    tau = pi/12.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp4 = 2.*pc*cos(pd)*signe;
    yp4 = pc*sin(pd);
    tau = pi/6.;
    delta = 2.*tau; psi = 2.*phi;
    pb = acos(cos(psi/2.)*cos(delta)); pc = sqrt(2.)*sin(pb/2.); pd = asin(sin(delta)/sin(pb));
    signe = 1.; if (phi < 0.) { signe = -1.;}
    xp5 = 2.*pc*cos(pd)*signe;
    yp5 = pc*sin(pd);
    fprintf(fileoutput,"%f %f %f %f %f %f %f %f %f %f\n",xp1,yp1,xp2,yp2,xp3,yp3,xp4,yp4,xp5,yp5);
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
