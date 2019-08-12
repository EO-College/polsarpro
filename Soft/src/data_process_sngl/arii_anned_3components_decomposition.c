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

File  : arii_anned_3components_decomposition.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Arri - VanZyl 3 components Decomposition
            ANNED : Adaptative Non Negative Eigenvalue Decomposition

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
  FILE *out_odd, *out_dbl, *out_vol;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, jj, lig, col, iiopt, jjopt;
  int flagstop, NN;
  int ligDone = 0;

  float Span, SpanMin, SpanMax;
  float ALPre, ALPim, BETre, BETim;
  float OMEGA1, OMEGA2, OMEGAodd, OMEGAdbl;
  float delta;
  float lambda1, lambda2;
  float gamma, epsilon, rho_re, rho_im;
//float  nhu;
  float hh1_re, hh1_im, vv1_re, vv1_im, hh2_re, hh2_im;
  float A0A0, B0pB;
  float sig, phi, psig, qsig;
  float xopt, xmin, xmax, xprevious, xx;
  float test, previous, Pmin;
 
  float amax, a11, a22, a33;
  float a12, a13, a23, b, c, d;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_odd;
  float **M_dbl;
  float **M_vol;
  float CV[100][100][9];
  float ***M;
  float ***V;
  float *lambda;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\narii_anned_3components_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2C3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "Arii3_ANNED_Odd.bin");
  if ((out_odd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Arii3_ANNED_Dbl.bin");
  if ((out_dbl = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Arii3_ANNED_Vol.bin");
  if ((out_vol = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Modd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  //M_avg = matrix_float(NpolarOut, Sub_Ncol);
  M_odd = matrix_float(NligBlock[0], Sub_Ncol);
  M_dbl = matrix_float(NligBlock[0], Sub_Ncol);
  M_vol = matrix_float(NligBlock[0], Sub_Ncol);
 
  //M = matrix3d_float(3, 3, 2);
  //V = matrix3d_float(3, 3, 2);
  //lambda = vector_float(3);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* SPANMIN / SPANMAX DETERMINATION */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

Span = 0.;
SpanMin = INIT_MINMAX;
SpanMax = -INIT_MINMAX;
  
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

#pragma omp parallel for private(col, M_avg) firstprivate(Span) shared(ligDone, SpanMin, SpanMax)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Span = M_avg[C311][col]+M_avg[C322][col]+M_avg[C333][col];
        if (Span >= SpanMax) SpanMax = Span;
        if (Span <= SpanMin) SpanMin = Span;
        }       
      }
    free_matrix_float(M_avg,NpolarOut);
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

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
  /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

iiopt = jjopt = flagstop = 0;
ALPre = ALPim = BETre = BETim = OMEGA1 = OMEGA2 = OMEGAodd = OMEGAdbl = 0.;
delta = lambda1 = lambda2 = gamma = epsilon = rho_re = rho_im = 0.;
hh1_re = hh1_im = vv1_re = vv1_im = hh2_re = hh2_im = A0A0 = B0pB = 0.;
sig = phi = psig = qsig = xopt = xmin = xmax = xprevious = xx = test = previous = Pmin = 0.;
amax = a11 = a22 = a33 = a12 = a13 = a23 = b = c = d = 0.;
#pragma omp parallel for private(col, ii, jj, M_avg, M, V, lambda) firstprivate(iiopt, jjopt, flagstop, ALPre, ALPim, BETre, BETim, OMEGA1, OMEGA2, OMEGAodd, OMEGAdbl, delta, lambda1, lambda2, gamma, epsilon, rho_re, rho_im, hh1_re, hh1_im, vv1_re, vv1_im, hh2_re, hh2_im, A0A0, B0pB, sig, phi, psig, qsig, xopt, xmin, xmax, xprevious, xx, test, previous, Pmin, amax, a11, a22, a33, a12, a13, a23, b, c, d) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);  
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        iiopt = 0; jjopt = 0; xopt = 0.; Pmin = SpanMax;
        for (ii = 0; ii < NN; ii++) {
          for (jj = 0; jj < NN; jj++) {
            //Determine xmax
            a11 = M_avg[C311][col]/CV[ii][jj][C311];
            a22 = M_avg[C322][col]/CV[ii][jj][C322];
            a33 = M_avg[C333][col]/CV[ii][jj][C333];
            //a12
            b = M_avg[C311][col]*CV[ii][jj][C322]+M_avg[C322][col]*CV[ii][jj][C311];
            b = b - 2.*(M_avg[C312_re][col]*CV[ii][jj][C312_re]+M_avg[C312_im][col]*CV[ii][jj][C312_im]);
            c = M_avg[C311][col]*M_avg[C322][col]-M_avg[C312_re][col]*M_avg[C312_re][col]-M_avg[C312_im][col]*M_avg[C312_im][col];
            d = CV[ii][jj][C311]*CV[ii][jj][C322]-CV[ii][jj][C312_re]*CV[ii][jj][C312_re]-CV[ii][jj][C312_im]*CV[ii][jj][C312_im];
            a12 = (b-sqrt(b*b-4.*c*d))/(2.*d);
            //a13
            b = M_avg[C311][col]*CV[ii][jj][C333]+M_avg[C333][col]*CV[ii][jj][C311];
            b = b - 2.*(M_avg[C313_re][col]*CV[ii][jj][C313_re]+M_avg[C313_im][col]*CV[ii][jj][C313_im]);
            c = M_avg[C311][col]*M_avg[C333][col]-M_avg[C313_re][col]*M_avg[C313_re][col]-M_avg[C313_im][col]*M_avg[C313_im][col];
            d = CV[ii][jj][C311]*CV[ii][jj][C333]-CV[ii][jj][C313_re]*CV[ii][jj][C313_re]-CV[ii][jj][C313_im]*CV[ii][jj][C313_im];
            a13 = (b-sqrt(b*b-4.*c*d))/(2.*d);
            //a23
            b = M_avg[C322][col]*CV[ii][jj][C333]+M_avg[C333][col]*CV[ii][jj][C322];
            b = b - 2.*(M_avg[C323_re][col]*CV[ii][jj][C323_re]+M_avg[C323_im][col]*CV[ii][jj][C323_im]);
            c = M_avg[C322][col]*M_avg[C333][col]-M_avg[C323_re][col]*M_avg[C323_re][col]-M_avg[C323_im][col]*M_avg[C323_im][col];
            d = CV[ii][jj][C322]*CV[ii][jj][C333]-CV[ii][jj][C323_re]*CV[ii][jj][C323_re]-CV[ii][jj][C323_im]*CV[ii][jj][C323_im];
            a23 = (b-sqrt(b*b-4.*c*d))/(2.*d);

            xmin = 0.; 
            xmax = a11; if (a22 <= xmax) xmax = a22; if (a33 <= xmax) xmax = a33;
            amax = xmax;
            if (a12 <= xmax) xmax = a12; if (a13 <= xmax) xmax = a13; if (a23 <= xmax) xmax = a23;
            flagstop = 0; xprevious = 0.; test = 0.; previous = 0.;

            while (flagstop == 0) {
              xx = (xmax - xmin)/2.;

              /*Test if Reminder matrix is semi-definite positive*/
              M[0][0][0] = eps + M_avg[0][col] - xx*CV[ii][jj][0];
              M[0][0][1] = 0.;
              M[0][1][0] = eps + M_avg[1][col] - xx*CV[ii][jj][1];
              M[0][1][1] = eps + M_avg[2][col] - xx*CV[ii][jj][2];
              M[0][2][0] = eps + M_avg[3][col] - xx*CV[ii][jj][3];
              M[0][2][1] = eps + M_avg[4][col] - xx*CV[ii][jj][4];
              M[1][0][0] =  M[0][1][0];
              M[1][0][1] = -M[0][1][1];
              M[1][1][0] = eps + M_avg[5][col] - xx*CV[ii][jj][5];
              M[1][1][1] = 0.;
              M[1][2][0] = eps + M_avg[6][col] - xx*CV[ii][jj][6];
              M[1][2][1] = eps + M_avg[7][col] - xx*CV[ii][jj][7];
              M[2][0][0] =  M[0][2][0];
              M[2][0][1] = -M[0][2][1];
              M[2][1][0] =  M[1][2][0];
              M[2][1][1] = -M[1][2][1];
              M[2][2][0] = eps + M_avg[8][col] - xx*CV[ii][jj][8];
              M[2][2][1] = 0.;

              a11 = M[0][0][0]*M[1][1][0]*M[2][2][0] + 2.*M[0][2][0]*(M[0][1][0]*M[1][2][0]-M[0][1][1]*M[1][2][1]);
              a11 = a11 + 2.*M[0][2][1]*(M[0][1][1]*M[1][2][0]+M[0][1][0]*M[1][2][1]);
              a11 = a11 - M[0][0][0]*(M[1][2][0]*M[1][2][0]+M[1][2][1]*M[1][2][1]);
              a11 = a11 - M[1][1][0]*(M[0][2][0]*M[0][2][0]+M[0][2][1]*M[0][2][1]);
              a11 = a11 - M[2][2][0]*(M[0][1][0]*M[0][1][0]+M[0][1][1]*M[0][1][1]);

              a22 = M[0][0][0]*M[1][1][0]-(M[0][1][0]*M[0][1][0]+M[0][1][1]*M[0][1][1]);
              a22 = a22 + M[0][0][0]*M[2][2][0]-(M[0][2][0]*M[0][2][0]+M[0][2][1]*M[0][2][1]);
              a22 = a22 + M[1][1][0]*M[2][2][0]-(M[1][2][0]*M[1][2][0]+M[1][2][1]*M[1][2][1]);

              a33 = M[0][0][0] + M[1][1][0] + M[2][2][0];

              test = -1;
              if ((a11 > 0.)&&(a22 > 0.)&&(a33 > 0.)) test = +1.;
              
              if (test == -1.) {
                xmax = xx; xmin = xmin;
                previous = -1.;
                } else {
                xmax = xmax; xmin = xx; xprevious = xx;
                if (previous == +1.) {
                  xx = (xmax - xmin)/2.;
                  if (fabs(xx - xprevious) < (amax / 100.)) {
                    flagstop = 1;
                    xx = xprevious;
                    }
                  }
                previous = +1.;                
                }
              }

            M[0][0][0] = eps + M_avg[0][col] - xx*CV[ii][jj][0];
            M[0][0][1] = 0.;
            M[0][1][0] = eps + M_avg[1][col] - xx*CV[ii][jj][1];
            M[0][1][1] = eps + M_avg[2][col] - xx*CV[ii][jj][2];
            M[0][2][0] = eps + M_avg[3][col] - xx*CV[ii][jj][3];
            M[0][2][1] = eps + M_avg[4][col] - xx*CV[ii][jj][4];
            M[1][0][0] =  M[0][1][0];
            M[1][0][1] = -M[0][1][1];
            M[1][1][0] = eps + M_avg[5][col] - xx*CV[ii][jj][5];
            M[1][1][1] = 0.;
            M[1][2][0] = eps + M_avg[6][col] - xx*CV[ii][jj][6];
            M[1][2][1] = eps + M_avg[7][col] - xx*CV[ii][jj][7];
            M[2][0][0] =  M[0][2][0];
            M[2][0][1] = -M[0][2][1];
            M[2][1][0] =  M[1][2][0];
            M[2][1][1] = -M[1][2][1];
            M[2][2][0] = eps + M_avg[8][col] - xx*CV[ii][jj][8];
            M[2][2][1] = 0.;
            Diagonalisation(3, M, V, lambda);
            if (lambda[2] < Pmin) {
              Pmin = lambda[2];
              iiopt = ii; jjopt = jj;
              xopt = xx;
              }
            }
          }
        
        /* C reminder */
        epsilon = M_avg[C311][col] - xopt*CV[iiopt][jjopt][C311];
        rho_re = M_avg[C313_re][col] - xopt*CV[iiopt][jjopt][C313_re];
        rho_im = M_avg[C313_im][col] - xopt*CV[iiopt][jjopt][C313_im];
//        nhu = M_avg[C322][col] - xopt*CV[iiopt][jjopt][C322];
        gamma = M_avg[C333][col] - xopt*CV[iiopt][jjopt][C333];

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

        M_odd[lig][col] = OMEGAodd * (1. + ALPre * ALPre + ALPim * ALPim);
        M_dbl[lig][col] = OMEGAdbl * (1. + BETre * BETre + BETim * BETim);
        M_vol[lig][col] = xopt * (CV[iiopt][jjopt][C311]+CV[iiopt][jjopt][C322]+CV[iiopt][jjopt][C333]);

        if (M_odd[lig][col] < SpanMin) M_odd[lig][col] = SpanMin;
        if (M_dbl[lig][col] < SpanMin) M_dbl[lig][col] = SpanMin;
        if (M_vol[lig][col] < SpanMin) M_vol[lig][col] = SpanMin;

        if (M_odd[lig][col] > SpanMax) M_odd[lig][col] = SpanMax;
        if (M_dbl[lig][col] > SpanMax) M_dbl[lig][col] = SpanMax;
        if (M_vol[lig][col] > SpanMax) M_vol[lig][col] = SpanMax;
        } else {
        M_odd[lig][col] = 0.;
        M_dbl[lig][col] = 0.;
        M_vol[lig][col] = 0.;
        }
      }
    free_matrix3d_float(M, 3, 3);
    free_matrix3d_float(V, 3, 3);
    free_vector_float(lambda);  
    free_matrix_float(M_avg,NpolarOut);
    }

  write_block_matrix_float(out_odd, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dbl, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_vol, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_odd, NligBlock[0]);
  free_matrix_float(M_dbl, NligBlock[0]);
  free_matrix_float(M_vol, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_odd);
  fclose(out_dbl);
  fclose(out_vol);
  
/********************************************************************
********************************************************************/

  return 1;
}

