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

File  : arii_anned_3components_reconstruction.c
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

Description :  Arri - VanZyl 3 components Reconstruction
            ANNED : Adaptative Non Negative Eigenvalue Decomposition

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

#define NPolType 3
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  
/* Internal variables */
  int ii, jj, lig, col, iiopt, jjopt;
  int flagstop, NN;

  float Span, SpanMin, SpanMax;
  float ALPre, ALPim, BETre, BETim;
  float OMEGA1, OMEGA2, OMEGAodd, OMEGAdbl;
  float delta;
  float lambda1, lambda2;
  float gamma, epsilon, rho_re, rho_im, nhu;
  float hh1_re, hh1_im, vv1_re, vv1_im, hh2_re, hh2_im;
  float A0A0, B0pB;
  float sig, phi, psig, qsig;
  float xopt, xmin, xmax, xprevious, xx;
  float test, previous, Pmin;
 
  float x00, x0r, x0i;
  float x11, x1r, x1i;
  float x22, x2r, x2i;
  float x01r, x01i, x02r, x02i, x12r, x12i;

/* Matrix arrays */
  float ***M_avg;
  float ***M_odd;
  float ***M_dbl;
  float ***M_vol;
  float CV[100][100][9];
  float ***M;
  float ***V;
  float *lambda;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\narii_anned_3components_reconstruction.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od1 	output directory - ground\n");
strcat(UsageHelp," (string)	-od2 	output directory - double\n");
strcat(UsageHelp," (string)	-od3 	output directory - volume\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 23) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od1",str_cmd_prm,out_dir1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od2",str_cmd_prm,out_dir2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od3",str_cmd_prm,out_dir3,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir1);
  check_dir(out_dir2);
  check_dir(out_dir3);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out1 = matrix_char(NpolarOut,1024); 
  file_name_out2 = matrix_char(NpolarOut,1024); 
  file_name_out3 = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir1, file_name_out1);
  init_file_name(PolTypeOut, out_dir2, file_name_out2);
  init_file_name(PolTypeOut, out_dir3, file_name_out3);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
  if ((out_datafile1[Np] = fopen(file_name_out1[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out1[Np]);
  
  for (Np = 0; Np < NpolarOut; Np++)
  if ((out_datafile2[Np] = fopen(file_name_out2[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out2[Np]);
  
  for (Np = 0; Np < NpolarOut; Np++)
  if ((out_datafile3[Np] = fopen(file_name_out3[Np], "wb")) == NULL)
    edit_error("Could not open input file : ", file_name_out3[Np]);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Modd = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_odd = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_dbl = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_vol = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);

  M = matrix3d_float(3, 3, 2);
  V = matrix3d_float(3, 3, 2);
  lambda = vector_float(3);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* SPANMIN / SPANMAX DETERMINATION */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

SpanMin = INIT_MINMAX;
SpanMax = -INIT_MINMAX;
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Span = M_avg[C311][lig][col]+M_avg[C322][lig][col]+M_avg[C333][lig][col];
        if (Span >= SpanMax) SpanMax = Span;
        if (Span <= SpanMin) SpanMin = Span;
        }
      }
    }
  } // NbBlock

  if (SpanMin < eps) SpanMin = eps;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
NN = 10;
for (ii = 0; ii < NN; ii++) {
  sig = (float)ii/NN;
  psig = 2.0806*sig*sig*sig*sig*sig*sig - 6.3350*sig*sig*sig*sig*sig;
  psig += 6.3864*sig*sig*sig*sig - 0.4431*sig*sig*sig;
  psig += -3.9638*sig*sig - 0.0008*sig + 2.;
  qsig = 9.0166*sig*sig*sig*sig*sig*sig - 18.7790*sig*sig*sig*sig*sig;
  qsig += 4.9590*sig*sig*sig*sig + 14.5629*sig*sig*sig;
  qsig += -10.8034*sig*sig + 0.1902*sig + 1.;
  for (jj = 0; jj < NN; jj++) {
    phi = (float)(jj/NN)*pi/2.;
    CV[ii][jj][C311] = (3. - psig*2.*cos(2.*phi) + qsig*cos(4.*phi))/8.;
    CV[ii][jj][C312_re] = (0. + psig*sqrt(2.)*sin(2.*phi) - qsig*sqrt(2.)*sin(4.*phi))/8.;
    CV[ii][jj][C312_im] = 0.;
    CV[ii][jj][C313_re] = (1. + 0. - qsig*cos(4.*phi))/8.;
    CV[ii][jj][C313_im] = 0.;
    CV[ii][jj][C322] = (2. + 0. - qsig*2.*cos(4.*phi))/8.;
    CV[ii][jj][C323_re] = (0. + psig*sqrt(2.)*sin(2.*phi) + qsig*sqrt(2.)*sin(4.*phi))/8.;
    CV[ii][jj][C323_im] = 0.;
    CV[ii][jj][C333] = (3. + psig*2.*cos(2.*phi) + qsig*cos(4.*phi))/8.;
    }
  }

//Vector to test the sign of Xt*MX > 0
x0r = ((rand() % 200) - 100.) / 100.;
x0i = ((rand() % 200) - 100.) / 100.;
x1r = ((rand() % 200) - 100.) / 100.;
x1i = ((rand() % 200) - 100.) / 100.;
x2r = ((rand() % 200) - 100.) / 100.;
x2i = ((rand() % 200) - 100.) / 100.;
x00 = x0r*x0r + x0i*x0i;
x11 = x1r*x1r + x1i*x1i;
x22 = x2r*x2r + x2i*x2i;
x01r = x0r*x1r + x0i*x1i;
x01i = x0i*x1r - x0r*x1i;
x02r = x0r*x2r + x0i*x2i;
x02i = x0i*x2r - x0r*x2i;
x12r = x1r*x2r + x1i*x2i;
x12i = x1i*x2r - x1r*x2i;

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) M_odd[Np][lig][col] = 0.;
      for (Np = 0; Np < NpolarOut; Np++) M_dbl[Np][lig][col] = 0.;
      for (Np = 0; Np < NpolarOut; Np++) M_vol[Np][lig][col] = 0.;
      if (Valid[lig][col] == 1.) {
        iiopt = 0; jjopt = 0; xopt = 0.; Pmin = SpanMax;
        nhu = M_avg[C322][lig][col];
        for (ii = 0; ii < NN; ii++) {
          for (jj = 0; jj < NN; jj++) {
            xmin = 0.; xmax = 4.*nhu;
            flagstop = 0; xprevious = 0.; test = 0.; previous = 0.;
            while (flagstop == 0) {
              xx = (xmax - xmin)/2.;
              
              /*
              M[0][0][0] = eps + M_avg[0][lig][col] - xx*CV[ii][jj][0];
              M[0][0][1] = 0.;
              M[0][1][0] = eps + M_avg[1][lig][col] - xx*CV[ii][jj][1];
              M[0][1][1] = eps + M_avg[2][lig][col] - xx*CV[ii][jj][2];
              M[0][2][0] = eps + M_avg[3][lig][col] - xx*CV[ii][jj][3];
              M[0][2][1] = eps + M_avg[4][lig][col] - xx*CV[ii][jj][4];
              M[1][0][0] =  M[0][1][0];
              M[1][0][1] = -M[0][1][1];
              M[1][1][0] = eps + M_avg[5][lig][col] - xx*CV[ii][jj][5];
              M[1][1][1] = 0.;
              M[1][2][0] = eps + M_avg[6][lig][col] - xx*CV[ii][jj][6];
              M[1][2][1] = eps + M_avg[7][lig][col] - xx*CV[ii][jj][7];
              M[2][0][0] =  M[0][2][0];
              M[2][0][1] = -M[0][2][1];
              M[2][1][0] =  M[1][2][0];
              M[2][1][1] = -M[1][2][1];
              M[2][2][0] = eps + M_avg[8][lig][col] - xx*CV[ii][jj][8];
              M[2][2][1] = 0.;
              
              Diagonalisation(3, M, V, lambda);
              if ((0. < lambda[0])&&(0. < lambda[1])&&(0. < lambda[2])) test = +1.;
              else test = -1.;              
              */
              
              test = 0.;
              test += (M_avg[0][lig][col] - xx*CV[ii][jj][0])*x00;
              test += (M_avg[5][lig][col] - xx*CV[ii][jj][5])*x11;
              test += (M_avg[8][lig][col] - xx*CV[ii][jj][8])*x22;
              test += 2.*(M_avg[1][lig][col] - xx*CV[ii][jj][1])*x01r;
              test += 2.*(M_avg[2][lig][col] - xx*CV[ii][jj][2])*x01i;
              test += 2.*(M_avg[3][lig][col] - xx*CV[ii][jj][3])*x02r;
              test += 2.*(M_avg[4][lig][col] - xx*CV[ii][jj][4])*x02i;
              test += 2.*(M_avg[6][lig][col] - xx*CV[ii][jj][6])*x12r;
              test += 2.*(M_avg[7][lig][col] - xx*CV[ii][jj][7])*x12i;
              if (test > 0.) test = +1.;
              else test = -1.;              
              
              if (test == -1.) {
                xmax = xx; xmin = xmin; previous = -1.;
                } else {
                xmax = xmax; xmin = xx; xprevious = xx;
                if (previous == +1.) {
                  xx = (xmax - xmin)/2.;
                  if (fabs(xx - xprevious) < (nhu / 100.)) {
                    flagstop = 1;
                    xx = xprevious;
                    }
                  }
                previous = +1.;                
                }
              }

            M[0][0][0] = eps + M_avg[0][lig][col] - xx*CV[ii][jj][0];
            M[0][0][1] = 0.;
            M[0][1][0] = eps + M_avg[1][lig][col] - xx*CV[ii][jj][1];
            M[0][1][1] = eps + M_avg[2][lig][col] - xx*CV[ii][jj][2];
            M[0][2][0] = eps + M_avg[3][lig][col] - xx*CV[ii][jj][3];
            M[0][2][1] = eps + M_avg[4][lig][col] - xx*CV[ii][jj][4];
            M[1][0][0] =  M[0][1][0];
            M[1][0][1] = -M[0][1][1];
            M[1][1][0] = eps + M_avg[5][lig][col] - xx*CV[ii][jj][5];
            M[1][1][1] = 0.;
            M[1][2][0] = eps + M_avg[6][lig][col] - xx*CV[ii][jj][6];
            M[1][2][1] = eps + M_avg[7][lig][col] - xx*CV[ii][jj][7];
            M[2][0][0] =  M[0][2][0];
            M[2][0][1] = -M[0][2][1];
            M[2][1][0] =  M[1][2][0];
            M[2][1][1] = -M[1][2][1];
            M[2][2][0] = eps + M_avg[8][lig][col] - xx*CV[ii][jj][8];
            M[2][2][1] = 0.;
            Diagonalisation(3, M, V, lambda);
            if (lambda[2] < Pmin) {
              Pmin = lambda[2];
              iiopt = ii; jjopt = jj;
              xopt = xx;
              }
            }
          }
        /*
        M[0][0][0] = eps + M_avg[0][lig][col] - xopt*CV[iiopt][jjopt][0];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][lig][col] - xopt*CV[iiopt][jjopt][1];
        M[0][1][1] = eps + M_avg[2][lig][col] - xopt*CV[iiopt][jjopt][2];
        M[0][2][0] = eps + M_avg[3][lig][col] - xopt*CV[iiopt][jjopt][3];
        M[0][2][1] = eps + M_avg[4][lig][col] - xopt*CV[iiopt][jjopt][4];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[5][lig][col] - xopt*CV[iiopt][jjopt][5];
        M[1][1][1] = 0.;
        M[1][2][0] = eps + M_avg[6][lig][col] - xopt*CV[iiopt][jjopt][6];
        M[1][2][1] = eps + M_avg[7][lig][col] - xopt*CV[iiopt][jjopt][7];
        M[2][0][0] =  M[0][2][0];
        M[2][0][1] = -M[0][2][1];
        M[2][1][0] =  M[1][2][0];
        M[2][1][1] = -M[1][2][1];
        M[2][2][0] = eps + M_avg[8][lig][col] - xopt*CV[iiopt][jjopt][8];
        M[2][2][1] = 0.;
        Diagonalisation(3, M, V, lambda);
        
        */
        
        /* C reminder */
        epsilon = M_avg[C311][lig][col] - xopt*CV[iiopt][jjopt][C311];
        rho_re = M_avg[C313_re][lig][col] - xopt*CV[iiopt][jjopt][C313_re];
        rho_im = M_avg[C313_im][lig][col] - xopt*CV[iiopt][jjopt][C313_im];
        nhu = M_avg[C322][lig][col] - xopt*CV[iiopt][jjopt][C322];
        gamma = M_avg[C333][lig][col] - xopt*CV[iiopt][jjopt][C333];

        /*Van Zyl algorithm*/
        delta = (epsilon - gamma)*(epsilon - gamma) + 4.*(rho_re*rho_re + rho_im*rho_im);

        lambda1 = 0.5*(epsilon + gamma + sqrt(delta));
        lambda2 = 0.5*(epsilon + gamma - sqrt(delta));
        
        OMEGA1 = lambda1*(gamma - epsilon + sqrt(delta))*(gamma - epsilon + sqrt(delta));
        OMEGA1 = OMEGA1 / ((gamma - epsilon + sqrt(delta))*(gamma - epsilon + sqrt(delta)) + 4.*(rho_re*rho_re + rho_im*rho_im));

        OMEGA2 = lambda2*(gamma - epsilon - sqrt(delta))*(gamma - epsilon - sqrt(delta));
        OMEGA2 = OMEGA2 / ((gamma - epsilon - sqrt(delta))*(gamma - epsilon - sqrt(delta)) + 4.*(rho_re*rho_re + rho_im*rho_im));

        hh1_re = 2.*rho_re / (gamma - epsilon + sqrt(delta));
        hh1_im = 2.*rho_im / (gamma - epsilon + sqrt(delta));
        vv1_re = 1.; vv1_im = 0.;

        hh2_re = 2.*rho_re / (gamma - epsilon - sqrt(delta));
        hh2_im = 2.*rho_im / (gamma - epsilon - sqrt(delta));

        A0A0 = (hh1_re+vv1_re)*(hh1_re+vv1_re) + (hh1_im+vv1_im)*(hh1_im+vv1_im);
        B0pB = (hh1_re-vv1_re)*(hh1_re-vv1_re) + (hh1_im-vv1_im)*(hh1_im-vv1_im);
        
        if (A0A0 > B0pB) {
          ALPre = hh1_re; ALPim = hh1_im; OMEGAodd = OMEGA1;
          BETre = hh2_re; BETim = hh2_im; OMEGAdbl = OMEGA2;  
          } else {
          ALPre = hh2_re; ALPim = hh2_im; OMEGAodd = OMEGA2;
          BETre = hh1_re; BETim = hh1_im; OMEGAdbl = OMEGA1;  
          }

        M_odd[C311][lig][col] = OMEGAodd * (ALPre * ALPre + ALPim * ALPim);
        M_odd[C312_re][lig][col] = 0.; M_odd[C312_im][lig][col] = 0.;
        M_odd[C313_re][lig][col] = OMEGAodd * ALPre; M_odd[C313_im][lig][col] = OMEGAodd * ALPim;
        M_odd[C322][lig][col] = 0.;
        M_odd[C323_re][lig][col] = 0.; M_odd[C323_im][lig][col] = 0.;
        M_odd[C333][lig][col] = OMEGAodd;

        M_dbl[C311][lig][col] = OMEGAdbl * (BETre * BETre + BETim * BETim);
        M_dbl[C312_re][lig][col] = 0.; M_dbl[C312_im][lig][col] = 0.;
        M_dbl[C313_re][lig][col] = OMEGAdbl * BETre; M_dbl[C313_im][lig][col] = OMEGAdbl * BETim;
        M_dbl[C322][lig][col] = 0.;
        M_dbl[C323_re][lig][col] = 0.; M_dbl[C323_im][lig][col] = 0.;
        M_dbl[C333][lig][col] = OMEGAdbl;

        M_vol[C311][lig][col] = xopt * CV[iiopt][jjopt][C311];
        M_vol[C312_re][lig][col] = xopt * CV[iiopt][jjopt][C312_re]; M_vol[C312_im][lig][col] = 0.;
        M_vol[C313_re][lig][col] = xopt * CV[iiopt][jjopt][C313_re]; M_vol[C313_im][lig][col] = 0.;
        M_vol[C322][lig][col] = xopt * CV[iiopt][jjopt][C322];
        M_vol[C323_re][lig][col] = xopt * CV[iiopt][jjopt][C323_re]; M_vol[C323_im][lig][col] = 0.;
        M_vol[C333][lig][col] = xopt * CV[iiopt][jjopt][C333];

        for (Np = 0; Np < NpolarOut; Np++) {
          if (M_odd[Np][lig][col] < 0.) M_odd[Np][lig][col] = 0.;
          if (M_odd[Np][lig][col] > SpanMax) M_odd[Np][lig][col] = SpanMax;
          if (M_dbl[Np][lig][col] < 0.) M_dbl[Np][lig][col] = 0.;
          if (M_dbl[Np][lig][col] > SpanMax) M_dbl[Np][lig][col] = SpanMax;
          if (M_vol[Np][lig][col] < 0.) M_vol[Np][lig][col] = 0.;
          if (M_vol[Np][lig][col] > SpanMax) M_vol[Np][lig][col] = SpanMax;
          }
        }
      }
    }

  if (strcmp(PolTypeOut,"T3")==0) {
    C3_to_T3(M_odd, NligBlock[Nb], Sub_Ncol, 0, 0);
    C3_to_T3(M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0);
    C3_to_T3(M_vol, NligBlock[Nb], Sub_Ncol, 0, 0);
    }

  write_block_matrix3d_float(out_datafile1, NpolarOut, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix3d_float(out_datafile2, NpolarOut, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix3d_float(out_datafile3, NpolarOut, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_odd, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_dbl, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_vol, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile1[Np]);
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile2[Np]);
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile3[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}


