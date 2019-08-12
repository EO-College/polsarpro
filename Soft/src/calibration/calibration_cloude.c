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

File   : calibration_cloude.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 10/2014
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

Description :  Polarimetric calibration based on the S.R.Cloude method 

*--------------------------------------------------------------------
 "Calibration of Polarimetric Radar Data using the Sylvester
 Equation in a Pauli Basis" 
 S.R. Cloude in IEEE GRSL 2014

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <time.h>

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

#define NPolType 2
/* LOCAL VARIABLES */
  //FILE *outfile;
  int Config;
  char *PolTypeConf[NPolType] = {"S2","S2T3"};
  //char FileName[FilePathLength];
  
/* Internal variables */
  int ii, jj, lig, col;

  int npts;
  float span, simi1, simi2;
  float threshold;
  float xx1122_re, xx1122_im, phi1122;
  float x1r, x1i, x2r, x2i, x3r, x3i, x11r, x11i;
  float k2k4r, k2k4i, k3k4r, k3k4i;
  float k2k2r, k2k2i, k2k3r, k2k3i;
  float k3k2r, k3k2i, k3k3r, k3k3i;
  float det, alphar, alphai, betar, betai;  
  float c2r, c2i, c2m, c2p;
  float cr, ci, c1r, c1i;
  float StdSpan, AvgSpan;
  float mod, phi, phi1;

  /* Matrix arrays */
  float ***M;
  float ***V;
  float *lambda;
  float ***S_in;
  float ***M_out;
  float ***SCR, ***SCRi;
  float ***S, ***Sobs;
  float ***Ainv, ***Aconj;
  float ***Binv, ***Bconj;
  float ***T, ***Ttmp1, ***Ttmp2;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncalibration_cloude.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)  -id    input directory\n");
strcat(UsageHelp," (string)  -od    output directory\n");
strcat(UsageHelp," (string)  -iodf  input-output data format\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)  -mask  mask file (valid pixels)\n");
strcat(UsageHelp," (string)  -errf  memory error file\n");
strcat(UsageHelp," (noarg)   -help  displays this message\n");
strcat(UsageHelp," (noarg)   -data  displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
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

if(argc < 7) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);

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

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

  Off_lig = 0; Off_col = 0;
  Sub_Nlig = Nlig; Sub_Ncol = Ncol;
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/TMP OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* TMP OUTPUT FILE OPENING*/
/*  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
*/  
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

  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M = matrix3d_float(4,4,2);
  V = matrix3d_float(4,4,2);
  lambda = vector_float(4);

  S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  SCR = matrix3d_float(2,2,2); SCRi = matrix3d_float(2,2,2);
  S = matrix3d_float(2,2,2); Sobs = matrix3d_float(2,2,2);
  Ainv = matrix3d_float(4,4,2); Aconj = matrix3d_float(4,4,2);
  Binv = matrix3d_float(4,4,2); Bconj = matrix3d_float(4,4,2);
  T = matrix3d_float(4,4,2); 
  Ttmp1 = matrix3d_float(4,4,2);
  Ttmp2 = matrix3d_float(4,4,2);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
  threshold = 0.1;
  
  //Estimation of the mean span
  npts = 0;
  AvgSpan = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          npts++;
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          AvgSpan += 10.*log10(fabs(span+eps));
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  AvgSpan /= npts;
  //Estimation of the std span
  npts = 0;
  StdSpan = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          npts++;
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          StdSpan += (10.*log10(fabs(span+eps))-AvgSpan)*(10.*log10(fabs(span+eps))-AvgSpan);
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  StdSpan = sqrt(StdSpan/npts);

  //Estimation of Corner Reflector type
  npts = 0;
  for (ii = 0; ii < 4; ii++) {
    for (jj = 0; jj < 4; jj++) {
      M[ii][jj][0] = 0.; M[ii][jj][1] = 0.;
      }
    }
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s12][lig][2*col]+S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s12][lig][2*col]-S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]-S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]))/span/2.;
          xx1122_re = S_in[s11][lig][2*col]*S_in[s22][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col+1];
          xx1122_im = S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col]-S_in[s11][lig][2*col]*S_in[s22][lig][2*col+1];
          phi1122 = fabs(atan2(xx1122_im,xx1122_re));
          if ((10.*log10(fabs(span+eps)) > AvgSpan + 4.*StdSpan)&&(simi1 < threshold)&&(simi2 < threshold)&&(phi1122 < pi/4.)) {
            npts++;
            k1r = S_in[s11][lig][2*col]; k1i = S_in[s11][lig][2*col+1];
            k2r = S_in[s12][lig][2*col]; k2i = S_in[s12][lig][2*col+1];
            k3r = S_in[s21][lig][2*col]; k3i = S_in[s21][lig][2*col+1];
            k4r = S_in[s22][lig][2*col]; k4i = S_in[s22][lig][2*col+1];
            M[0][0][0] += eps + k1r * k1r + k1i * k1i; M[0][0][1] += 0.;
            M[0][1][0] += eps + k1r * k2r + k1i * k2i; M[0][1][1] += eps + k1i * k2r - k1r * k2i;
            M[0][2][0] += eps + k1r * k3r + k1i * k3i; M[0][2][1] += eps + k1i * k3r - k1r * k3i;
            M[0][3][0] += eps + k1r * k4r + k1i * k4i; M[0][3][1] += eps + k1i * k4r - k1r * k4i;
            M[1][0][0] += eps + k1r * k2r + k1i * k2i; M[1][0][1] += eps -(k1i * k2r - k1r * k2i);
            M[1][1][0] += eps + k2r * k2r + k2i * k2i; M[1][1][1] += 0.;
            M[1][2][0] += eps + k2r * k3r + k2i * k3i; M[1][2][1] += eps + k2i * k3r - k2r * k3i;
            M[1][3][0] += eps + k2r * k4r + k2i * k4i; M[1][3][1] += eps + k2i * k4r - k2r * k4i;
            M[2][0][0] += eps + k1r * k3r + k1i * k3i; M[2][0][1] += eps -(k1i * k3r - k1r * k3i);
            M[2][1][0] += eps + k2r * k3r + k2i * k3i; M[2][1][1] += eps -(k2i * k3r - k2r * k3i);
            M[2][2][0] += eps + k3r * k3r + k3i * k3i; M[2][2][1] += 0.;
            M[2][3][0] += eps + k3r * k4r + k3i * k4i; M[2][3][1] += eps + k3i * k4r - k3r * k4i;
            M[3][0][0] += eps + k1r * k4r + k1i * k4i; M[3][0][1] += eps -(k1i * k4r - k1r * k4i);
            M[3][1][0] += eps + k2r * k4r + k2i * k4i; M[3][1][1] += eps -(k2i * k4r - k2r * k4i);
            M[3][2][0] += eps + k3r * k4r + k3i * k4i; M[3][2][1] += eps -(k3i * k4r - k3r * k4i);
            M[3][3][0] += eps + k4r * k4r + k4i * k4i; M[3][3][1] += 0.;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
    
  for (ii = 0; ii < 4; ii++) {
    for (jj = 0; jj < 4; jj++) {
      M[ii][jj][0] /= npts; M[ii][jj][1] /= npts;
      printf("MM(%i,%i) = (%f, %f)\n",ii,jj,M[ii][jj][0],M[ii][jj][1]);
      }
    }
  /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
  /* V complex eigenvecor matrix, lambda real vector*/
  Diagonalisation(4, M, V, lambda);
  lambda[0] = sqrt(lambda[0]);
  SCR[0][0][0] = lambda[0]*V[0][0][0]; SCR[0][0][1] = lambda[0]*V[0][0][1];
  SCR[0][1][0] = lambda[0]*V[1][0][0]; SCR[0][1][1] = lambda[0]*V[1][0][1];
  SCR[1][0][0] = lambda[0]*V[2][0][0]; SCR[1][0][1] = lambda[0]*V[2][0][1];
  SCR[1][1][0] = lambda[0]*V[3][0][0]; SCR[1][1][1] = lambda[0]*V[3][0][1];
  phi1 = atan2(SCR[0][0][1],SCR[0][0][0]);
  mod = sqrt(SCR[0][0][0]*SCR[0][0][0]+SCR[0][0][1]*SCR[0][0][1]);
  SCR[0][0][0]= mod; SCR[0][0][1] = 0.;
  phi = atan2(SCR[0][1][1],SCR[0][1][0]);
  mod = sqrt(SCR[0][1][0]*SCR[0][1][0]+SCR[0][1][1]*SCR[0][1][1]);
  SCR[0][1][0]= mod*cos(phi-phi1); SCR[0][1][1] = mod*sin(phi-phi1);
  phi = atan2(SCR[1][0][1],SCR[1][0][0]);
  mod = sqrt(SCR[1][0][0]*SCR[1][0][0]+SCR[1][0][1]*SCR[1][0][1]);
  SCR[1][0][0]= mod*cos(phi-phi1); SCR[1][0][1] = mod*sin(phi-phi1);
  phi = atan2(SCR[1][1][1],SCR[1][1][0]);
  mod = sqrt(SCR[1][1][0]*SCR[1][1][0]+SCR[1][1][1]*SCR[1][1][1]);
  SCR[1][1][0]= mod*cos(phi-phi1); SCR[1][1][1] = mod*sin(phi-phi1);
  
  InverseCmplxMatrix2(SCR,SCRi);
  for (ii = 0; ii<2; ii++) for (jj = 0; jj<2; jj++) printf("SCR(%i,%i) = (%f, %f)\n",ii,jj,SCR[ii][jj][0],SCR[ii][jj][1]);
  printf("\n");
  for (ii = 0; ii<2; ii++) for (jj = 0; jj<2; jj++) printf("SCRi(%i,%i) = (%f, %f)\n",ii,jj,SCRi[ii][jj][0],SCRi[ii][jj][1]);
  printf("\n");

  //ESTIMATION OF INV OF A = U(Ti x Tt)Ui
  //Estimation of x2=k3/k2 and x3=k4/k2
  npts = 0;
  x2r = 0.; x2i = 0.;
  x3r = 0.; x3i = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s12][lig][2*col]+S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s12][lig][2*col]-S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]-S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]))/span/2.;
          xx1122_re = S_in[s11][lig][2*col]*S_in[s22][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col+1];
          xx1122_im = S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col]-S_in[s11][lig][2*col]*S_in[s22][lig][2*col+1];
          phi1122 = fabs(atan2(xx1122_im,xx1122_re));
          if ((10.*log10(fabs(span+eps)) > AvgSpan + 2.*StdSpan)&&(simi1 < threshold)&&(simi2 < threshold)&&(phi1122 < pi/4.)) {
            npts++;
            S[0][0][0] = S_in[s11][lig][2*col]; S[0][0][1] = S_in[s11][lig][2*col+1]; 
            S[0][1][0] = S_in[s12][lig][2*col]; S[0][1][1] = S_in[s12][lig][2*col+1]; 
            S[1][0][0] = S_in[s21][lig][2*col]; S[1][0][1] = S_in[s21][lig][2*col+1]; 
            S[1][1][0] = S_in[s22][lig][2*col]; S[1][1][1] = S_in[s22][lig][2*col+1]; 
            ProductCmplxMatrix(SCRi,S,Sobs,2);
            k1r = (Sobs[0][0][0] + Sobs[1][1][0]) / sqrt(2.);
            k1i = (Sobs[0][0][1] + Sobs[1][1][1]) / sqrt(2.);
            k2r = (Sobs[0][0][0] - Sobs[1][1][0]) / sqrt(2.);
            k2i = (Sobs[0][0][1] - Sobs[1][1][1]) / sqrt(2.);
            k3r = (Sobs[0][1][0] + Sobs[1][0][0]) / sqrt(2.);
            k3i = (Sobs[0][1][1] + Sobs[1][0][1]) / sqrt(2.);
            k4r = (Sobs[1][0][1] - Sobs[0][1][1]) / sqrt(2.);
            k4i = (Sobs[0][1][0] - Sobs[1][0][0]) / sqrt(2.);
            x2r += (k3r*k2r+k3i*k2i)/(k2r*k2r+k2i*k2i);
            x2i += (k3i*k2r-k3r*k2i)/(k2r*k2r+k2i*k2i);
            x3r += (k4r*k2r+k4i*k2i)/(k2r*k2r+k2i*k2i);
            x3i += (k4i*k2r-k4r*k2i)/(k2r*k2r+k2i*k2i);
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
    
  x2r /= npts; x2i /= npts;
  x3r /= npts; x3i /= npts;
 
  //Estimation of the different ZiZj
  npts = 0;
  k2k4r = 0.; k2k4i = 0.;
  k3k4r = 0.; k3k4i = 0.;
  k2k2r = 0.; k2k2i = 0.;
  k2k3r = 0.; k2k3i = 0.;
  k3k2r = 0.; k3k2i = 0.;
  k3k3r = 0.; k3k3i = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          if (10.*log10(fabs(span+eps)) < AvgSpan + 2.*StdSpan) {
            npts++;
            S[0][0][0] = S_in[s11][lig][2*col]; S[0][0][1] = S_in[s11][lig][2*col+1]; 
            S[0][1][0] = S_in[s12][lig][2*col]; S[0][1][1] = S_in[s12][lig][2*col+1]; 
            S[1][0][0] = S_in[s21][lig][2*col]; S[1][0][1] = S_in[s21][lig][2*col+1]; 
            S[1][1][0] = S_in[s22][lig][2*col]; S[1][1][1] = S_in[s22][lig][2*col+1]; 
            ProductCmplxMatrix(SCRi,S,Sobs,2);
            k1r = (Sobs[0][0][0] + Sobs[1][1][0]) / sqrt(2.);
            k1i = (Sobs[0][0][1] + Sobs[1][1][1]) / sqrt(2.);
            k2r = (Sobs[0][0][0] - Sobs[1][1][0]) / sqrt(2.);
            k2i = (Sobs[0][0][1] - Sobs[1][1][1]) / sqrt(2.);
            k3r = (Sobs[0][1][0] + Sobs[1][0][0]) / sqrt(2.);
            k3i = (Sobs[0][1][1] + Sobs[1][0][1]) / sqrt(2.);
            k4r = (Sobs[1][0][1] - Sobs[0][1][1]) / sqrt(2.);
            k4i = (Sobs[0][1][0] - Sobs[1][0][0]) / sqrt(2.);
            k2k4r += -(k2r*k4r+k2i*k4i); k2k4i += k2i*k4r-k2r*k4i;
            k3k4r += -(k3r*k4r+k3i*k4i); k3k4i += k3i*k4r-k3r*k4i;
            k2k2r += k2r*k2r+k2i*k2i; k2k2i += k2r*k2i-k2i*k2r;
            k2k3r += k2r*k3r+k2i*k3i; k2k3i += k2r*k3i-k2i*k3r;
            k3k2r += k3r*k2r+k3i*k2i; k3k2i += k3r*k2i-k3i*k2r;
            k3k3r += k3r*k3r+k3i*k3i; k3k3i += k3r*k3i-k3i*k3r;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  k2k4r /= npts; k2k4i /= npts;
  k3k4r /= npts; k3k4i /= npts;
  k2k2r /= npts; k2k2i /= npts;
  k2k3r /= npts; k2k3i /= npts;
  k3k2r /= npts; k3k2i /= npts;
  k3k3r /= npts; k3k3i /= npts;

  det = k2k2r*k3k3r-(k2k3r*k3k2r-k2k3i*k3k2i);
  
  //Estimation of alpha = a42/(c1-x1x2)
  alphar = ((k3k3r*k2k4r-k3k3i*k2k4i)-(k2k3r*k3k4r-k2k3i*k3k4i))/det;  
  alphai = ((k3k3r*k2k4i+k3k3i*k2k4r)-(k2k3r*k3k4i+k2k3i*k3k4r))/det;  
    
  //Estimation of beta = a43/(c1-x1x2)
  betar = (-(k3k2r*k2k4r-k3k2i*k2k4i)+(k2k2r*k3k4r-k2k2i*k3k4i))/det;  
  betai = (-(k3k2r*k2k4i+k3k2i*k2k4r)+(k2k2r*k3k4i+k2k2i*k3k4r))/det;  
    
  //Estimation of c2 = (1-beta)/(1+beta)
  c2r = ((1.-betar)*(1.+betar) - betai*betai)/((1.+betar)*(1.+betar)+betai*betai);
  c2i = -((1.+betar)*betai + (1.-betar)*betai)/((1.+betar)*(1.+betar)+betai*betai);
  c2m = sqrt(c2r*c2r+c2i*c2i); c2p = atan2(c2i,c2r);
  cr = sqrt(c2m)*cos(c2p/2.); ci = sqrt(c2m)*sin(c2p/2.);

  //Estimation of x1 = (x2*(c2-1)-x2*(c2+1))/2c
  x11r = x3r*(c2r-1.) - x3i*c2i - x2r*(c2r+1.) + x2i*c2i;
  x11i = x3r*c2i + x3i*(c2r-1.) - x2r*c2i - x2i*(c2r+1.);
  x1r = (x11r*cr + x11i*ci) / (cr*cr + ci*ci) /2.;
  x1i = (x11i*cr - x11r*ci) / (cr*cr + ci*ci) /2.;
  
  //Estimation of c1 = 0.5(c + 1/c)
  c1r = ((1. + c2r)*cr + c2i*ci) / (cr*cr + ci*ci) /2.;
  c1i = (c2i*cr - (1. + c2r)*ci) / (cr*cr + ci*ci) /2.;

  //Estimation of c2 = 0.5(c - 1/c)
  c2r = ((c2r - 1.)*cr + c2i*ci) / (cr*cr + ci*ci) /2.;
  c2i = (c2i*cr - (c2r - 1.)*ci) / (cr*cr + ci*ci) /2.;
  
  //Estimation Inverse Matrix Ainv
  Ainv[0][0][0] = 1.; Ainv[0][0][1] = 0.;
  Ainv[0][1][0] = 0.; Ainv[0][1][1] = 0.;
  Ainv[0][2][0] = 0.; Ainv[0][2][1] = 0.;
  Ainv[0][3][0] = 0.; Ainv[0][3][1] = 0.;
  Ainv[1][0][0] = 0.; Ainv[1][0][1] = 0.;
  Ainv[1][1][0] = 1.; Ainv[1][1][1] = 0.;
  Ainv[1][2][0] = -(x1r*c1r + x1i*c1i)/(c1r*c1r+c1i*c1i); Ainv[1][2][1] = -(x1i*c1r - x1r*c1i)/(c1r*c1r+c1i*c1i);
  Ainv[1][3][0] = 0.; Ainv[1][3][1] = 0.;
  Ainv[2][0][0] = 0.; Ainv[2][0][1] = 0.;
  Ainv[2][1][0] = -(x2r*c1r + x2i*c1i)/(c1r*c1r+c1i*c1i); Ainv[2][1][1] = -(x2i*c1r - x2r*c1i)/(c1r*c1r+c1i*c1i);
  Ainv[2][2][0] = (1.*c1r + 0.*c1i)/(c1r*c1r+c1i*c1i); Ainv[2][2][1] = (0.*c1r - 1.*c1i)/(c1r*c1r+c1i*c1i);
  Ainv[2][3][0] = 0.; Ainv[2][3][1] = 0.;
  Ainv[3][0][0] = 0.; Ainv[3][0][1] = 0.;
  Ainv[3][1][0] = alphar; Ainv[3][1][1] = alphai;
  Ainv[3][2][0] = betar; Ainv[3][2][1] = betai;
  Ainv[3][3][0] = 1.; Ainv[3][3][1] = 0.;
  
  //Estimation Inverse Matrix Aconj
  Aconj[0][0][0] = 1.; Aconj[0][0][1] = 0.;
  Aconj[0][1][0] = 0.; Aconj[0][1][1] = 0.;
  Aconj[0][2][0] = 0.; Aconj[0][2][1] = 0.;
  Aconj[0][3][0] = 0.; Aconj[0][3][1] = 0.;
  Aconj[1][0][0] = 0.; Aconj[1][0][1] = 0.;
  Aconj[1][1][0] = 1.; Aconj[1][1][1] = 0.;
  Aconj[1][2][0] = x1r; Aconj[1][2][1] = -x1i;
  Aconj[1][3][0] = 0.; Aconj[1][3][1] = 0.;
  Aconj[2][0][0] = 0.; Aconj[2][0][1] = 0.;
  Aconj[2][1][0] = x2r; Aconj[2][1][1] = -x2i;
  Aconj[2][2][0] = c1r; Aconj[2][2][1] = -c1i;
  Aconj[2][3][0] = 0.; Aconj[2][3][1] = 0.;
  Aconj[3][0][0] = 0.; Aconj[3][0][1] = 0.;
  Aconj[3][1][0] = x3r; Aconj[3][1][1] = -x3i;
  Aconj[3][2][0] = c2r; Aconj[3][2][1] = -c2i;
  Aconj[3][3][0] = 1.; Aconj[3][3][1] = 0.;

  for (ii = 0; ii<4; ii++) for (jj = 0; jj<4; jj++) printf("Ainv(%i,%i) = (%f, %f) = %f\n",ii,jj,Ainv[ii][jj][0],Ainv[ii][jj][1],sqrt(Ainv[ii][jj][0]*Ainv[ii][jj][0]+Ainv[ii][jj][1]*Ainv[ii][jj][1]));
  printf("\n");
  for (ii = 0; ii<4; ii++) for (jj = 0; jj<4; jj++) printf("Aconj(%i,%i) = (%f, %f) = %f\n",ii,jj,Aconj[ii][jj][0],Aconj[ii][jj][1],sqrt(Aconj[ii][jj][0]*Aconj[ii][jj][0]+Aconj[ii][jj][1]*Aconj[ii][jj][1]));
  printf("\n");
getchar();

  //ESTIMATION OF INV OF B = U(R x Rit)Ui
  //Estimation of x2=k3/k2 and x3=k4/k2
  npts = 0;
  x2r = 0.; x2i = 0.;
  x3r = 0.; x3i = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s12][lig][2*col]+S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s12][lig][2*col]-S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]-S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]))/span/2.;
          xx1122_re = S_in[s11][lig][2*col]*S_in[s22][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col+1];
          xx1122_im = S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col]-S_in[s11][lig][2*col]*S_in[s22][lig][2*col+1];
          phi1122 = fabs(atan2(xx1122_im,xx1122_re));
          if ((10.*log10(fabs(span+eps)) > AvgSpan + 2.*StdSpan)&&(simi1 < threshold)&&(simi2 < threshold)&&(phi1122 < pi/4.)) {
            npts++;
            S[0][0][0] = S_in[s11][lig][2*col]; S[0][0][1] = S_in[s11][lig][2*col+1]; 
            S[0][1][0] = S_in[s12][lig][2*col]; S[0][1][1] = S_in[s12][lig][2*col+1]; 
            S[1][0][0] = S_in[s21][lig][2*col]; S[1][0][1] = S_in[s21][lig][2*col+1]; 
            S[1][1][0] = S_in[s22][lig][2*col]; S[1][1][1] = S_in[s22][lig][2*col+1]; 
            ProductCmplxMatrix(S,SCRi,Sobs,2);
            k1r = (Sobs[0][0][0] + Sobs[1][1][0]) / sqrt(2.);
            k1i = (Sobs[0][0][1] + Sobs[1][1][1]) / sqrt(2.);
            k2r = (Sobs[0][0][0] - Sobs[1][1][0]) / sqrt(2.);
            k2i = (Sobs[0][0][1] - Sobs[1][1][1]) / sqrt(2.);
            k3r = (Sobs[0][1][0] + Sobs[1][0][0]) / sqrt(2.);
            k3i = (Sobs[0][1][1] + Sobs[1][0][1]) / sqrt(2.);
            k4r = (Sobs[1][0][1] - Sobs[0][1][1]) / sqrt(2.);
            k4i = (Sobs[0][1][0] - Sobs[1][0][0]) / sqrt(2.);
            x2r += (k3r*k2r+k3i*k2i)/(k2r*k2r+k2i*k2i);
            x2i += (k3i*k2r-k3r*k2i)/(k2r*k2r+k2i*k2i);
            x3r += (k4r*k2r+k4i*k2i)/(k2r*k2r+k2i*k2i);
            x3i += (k4i*k2r-k4r*k2i)/(k2r*k2r+k2i*k2i);
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
    
  x2r /= npts; x2i /= npts;
  x3r /= npts; x3i /= npts;
 
  //Estimation of the different ZiZj
  npts = 0;
  k2k4r = 0.; k2k4i = 0.;
  k3k4r = 0.; k3k4i = 0.;
  k2k2r = 0.; k2k2i = 0.;
  k2k3r = 0.; k2k3i = 0.;
  k3k2r = 0.; k3k2i = 0.;
  k3k3r = 0.; k3k3i = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarIn; Np++) span += S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          if (10.*log10(fabs(span+eps)) < AvgSpan + 2.*StdSpan) {
            npts++;
            S[0][0][0] = S_in[s11][lig][2*col]; S[0][0][1] = S_in[s11][lig][2*col+1]; 
            S[0][1][0] = S_in[s12][lig][2*col]; S[0][1][1] = S_in[s12][lig][2*col+1]; 
            S[1][0][0] = S_in[s21][lig][2*col]; S[1][0][1] = S_in[s21][lig][2*col+1]; 
            S[1][1][0] = S_in[s22][lig][2*col]; S[1][1][1] = S_in[s22][lig][2*col+1]; 
            ProductCmplxMatrix(S,SCRi,Sobs,2);
            k1r = (Sobs[0][0][0] + Sobs[1][1][0]) / sqrt(2.);
            k1i = (Sobs[0][0][1] + Sobs[1][1][1]) / sqrt(2.);
            k2r = (Sobs[0][0][0] - Sobs[1][1][0]) / sqrt(2.);
            k2i = (Sobs[0][0][1] - Sobs[1][1][1]) / sqrt(2.);
            k3r = (Sobs[0][1][0] + Sobs[1][0][0]) / sqrt(2.);
            k3i = (Sobs[0][1][1] + Sobs[1][0][1]) / sqrt(2.);
            k4r = (Sobs[1][0][1] - Sobs[0][1][1]) / sqrt(2.);
            k4i = (Sobs[0][1][0] - Sobs[1][0][0]) / sqrt(2.);
            k2k4r += -(k2r*k4r+k2i*k4i); k2k4i += k2i*k4r-k2r*k4i;
            k3k4r += -(k3r*k4r+k3i*k4i); k3k4i += k3i*k4r-k3r*k4i;
            k2k2r += k2r*k2r+k2i*k2i; k2k2i += k2r*k2i-k2i*k2r;
            k2k3r += k2r*k3r+k2i*k3i; k2k3i += k2r*k3i-k2i*k3r;
            k3k2r += k3r*k2r+k3i*k2i; k3k2i += k3r*k2i-k3i*k2r;
            k3k3r += k3r*k3r+k3i*k3i; k3k3i += k3r*k3i-k3i*k3r;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  k2k4r /= npts; k2k4i /= npts;
  k3k4r /= npts; k3k4i /= npts;
  k2k2r /= npts; k2k2i /= npts;
  k2k3r /= npts; k2k3i /= npts;
  k3k2r /= npts; k3k2i /= npts;
  k3k3r /= npts; k3k3i /= npts;

  det = k2k2r*k3k3r-(k2k3r*k3k2r-k2k3i*k3k2i);
  
  //Estimation of alpha = a42/(c1-x1x2)
  alphar = ((k3k3r*k2k4r-k3k3i*k2k4i)-(k2k3r*k3k4r-k2k3i*k3k4i))/det;  
  alphai = ((k3k3r*k2k4i+k3k3i*k2k4r)-(k2k3r*k3k4i+k2k3i*k3k4r))/det;  
    
  //Estimation of beta = a43/(c1-x1x2)
  betar = (-(k3k2r*k2k4r-k3k2i*k2k4i)+(k2k2r*k3k4r-k2k2i*k3k4i))/det;  
  betai = (-(k3k2r*k2k4i+k3k2i*k2k4r)+(k2k2r*k3k4i+k2k2i*k3k4r))/det;  
    
  //Estimation of c2 = (1-beta)/(1+beta)
  c2r = ((1.-betar)*(1.+betar) - betai*betai)/((1.+betar)*(1.+betar)+betai*betai);
  c2i = -((1.+betar)*betai + (1.-betar)*betai)/((1.+betar)*(1.+betar)+betai*betai);
  c2m = sqrt(c2r*c2r+c2i*c2i); c2p = atan2(c2i,c2r);
  cr = sqrt(c2m)*cos(c2p/2.); ci = sqrt(c2m)*sin(c2p/2.);

  //Estimation of x1 = (x2*(c2-1)-x2*(c2+1))/2c
  x11r = x3r*(c2r-1.) - x3i*c2i - x2r*(c2r+1.) + x2i*c2i;
  x11i = x3r*c2i + x3i*(c2r-1.) - x2r*c2i - x2i*(c2r+1.);
  x1r = (x11r*cr + x11i*ci) / (cr*cr + ci*ci) /2.;
  x1i = (x11i*cr - x11r*ci) / (cr*cr + ci*ci) /2.;
  
  //Estimation of c1 = 0.5(c + 1/c)
  c1r = ((1. + c2r)*cr + c2i*ci) / (cr*cr + ci*ci) /2.;
  c1i = (c2i*cr - (1. + c2r)*ci) / (cr*cr + ci*ci) /2.;

  //Estimation of c2 = 0.5(c - 1/c)
  c2r = ((c2r - 1.)*cr + c2i*ci) / (cr*cr + ci*ci) /2.;
  c2i = (c2i*cr - (c2r - 1.)*ci) / (cr*cr + ci*ci) /2.;

  //Estimation Inverse Matrix Binv
  Binv[0][0][0] = 1.; Binv[0][0][1] = 0.;
  Binv[0][1][0] = 0.; Binv[0][1][1] = 0.;
  Binv[0][2][0] = 0.; Binv[0][2][1] = 0.;
  Binv[0][3][0] = 0.; Binv[0][3][1] = 0.;
  Binv[1][0][0] = 0.; Binv[1][0][1] = 0.;
  Binv[1][1][0] = 1.; Binv[1][1][1] = 0.;
  Binv[1][2][0] = -(x1r*c1r + x1i*c1i)/(c1r*c1r+c1i*c1i); Binv[1][2][1] = -(x1i*c1r - x1r*c1i)/(c1r*c1r+c1i*c1i);
  Binv[1][3][0] = 0.; Binv[1][3][1] = 0.;
  Binv[2][0][0] = 0.; Binv[2][0][1] = 0.;
  Binv[2][1][0] = -(x2r*c1r + x2i*c1i)/(c1r*c1r+c1i*c1i); Binv[2][1][1] = -(x2i*c1r - x2r*c1i)/(c1r*c1r+c1i*c1i);
  Binv[2][2][0] = (1.*c1r + 0.*c1i)/(c1r*c1r+c1i*c1i); Binv[2][2][1] = (0.*c1r - 1.*c1i)/(c1r*c1r+c1i*c1i);
  Binv[2][3][0] = 0.; Binv[2][3][1] = 0.;
  Binv[3][0][0] = 0.; Binv[3][0][1] = 0.;
  Binv[3][1][0] = alphar; Binv[3][1][1] = alphai;
  Binv[3][2][0] = betar; Binv[3][2][1] = betai;
  Binv[3][3][0] = 1.; Binv[3][3][1] = 0.;
  
  for (ii = 0; ii<4; ii++) for (jj = 0; jj<4; jj++) printf("Binv(%i,%i) = (%f, %f) = %f\n",ii,jj,Binv[ii][jj][0],Binv[ii][jj][1],sqrt(Binv[ii][jj][0]*Binv[ii][jj][0]+Binv[ii][jj][1]*Binv[ii][jj][1]));
  printf("\n");
  
  //Estimation Inverse Matrix Bconj
  Bconj[0][0][0] = 1.; Bconj[0][0][1] = 0.;
  Bconj[0][1][0] = 0.; Bconj[0][1][1] = 0.;
  Bconj[0][2][0] = 0.; Bconj[0][2][1] = 0.;
  Bconj[0][3][0] = 0.; Bconj[0][3][1] = 0.;
  Bconj[1][0][0] = 0.; Bconj[1][0][1] = 0.;
  Bconj[1][1][0] = 1.; Bconj[1][1][1] = 0.;
  Bconj[1][2][0] = x1r; Bconj[1][2][1] = -x1i;
  Bconj[1][3][0] = 0.; Bconj[1][3][1] = 0.;
  Bconj[2][0][0] = 0.; Bconj[2][0][1] = 0.;
  Bconj[2][1][0] = x2r; Bconj[2][1][1] = -x2i;
  Bconj[2][2][0] = c1r; Bconj[2][2][1] = -c1i;
  Bconj[2][3][0] = 0.; Bconj[2][3][1] = 0.;
  Bconj[3][0][0] = 0.; Bconj[3][0][1] = 0.;
  Bconj[3][1][0] = x3r; Bconj[3][1][1] = -x3i;
  Bconj[3][2][0] = c2r; Bconj[3][2][1] = -c2i;
  Bconj[3][3][0] = 1.; Bconj[3][3][1] = 0.;
  
  for (ii = 0; ii<4; ii++) for (jj = 0; jj<4; jj++) printf("Bconj(%i,%i) = (%f, %f) = %f\n",ii,jj,Bconj[ii][jj][0],Bconj[ii][jj][1],sqrt(Bconj[ii][jj][0]*Bconj[ii][jj][0]+Bconj[ii][jj][1]*Bconj[ii][jj][1]));

  //CALIBRATION
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(in_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          S[0][0][0] = S_in[s11][lig][2*col]; S[0][0][1] = S_in[s11][lig][2*col+1]; 
          S[0][1][0] = S_in[s12][lig][2*col]; S[0][1][1] = S_in[s12][lig][2*col+1]; 
          S[1][0][0] = S_in[s21][lig][2*col]; S[1][0][1] = S_in[s21][lig][2*col+1]; 
          S[1][1][0] = S_in[s22][lig][2*col]; S[1][1][1] = S_in[s22][lig][2*col+1]; 
          ProductCmplxMatrix(SCRi,S,Sobs,2);
if ((lig == 140)&&(col == 33)) {
for (Np = 0; Np < NpolarIn; Np++) printf("S_in(%i) = (%f, %f)\n",Np,S_in[Np][140][2*33],S_in[Np][140][2*33+1]);
for (ii = 0; ii<2; ii++) for (jj = 0; jj<2; jj++) printf("Sobs(%i,%i) = (%f, %f)\n",ii,jj,Sobs[ii][jj][0],Sobs[ii][jj][1]);
}
          k1r = (Sobs[0][0][0] + Sobs[1][1][0]) / sqrt(2.);
          k1i = (Sobs[0][0][1] + Sobs[1][1][1]) / sqrt(2.);
          k2r = (Sobs[0][0][0] - Sobs[1][1][0]) / sqrt(2.);
          k2i = (Sobs[0][0][1] - Sobs[1][1][1]) / sqrt(2.);
          k3r = (Sobs[0][1][0] + Sobs[1][0][0]) / sqrt(2.);
          k3i = (Sobs[0][1][1] + Sobs[1][0][1]) / sqrt(2.);
          k4r = (Sobs[1][0][1] - Sobs[0][1][1]) / sqrt(2.);
          k4i = (Sobs[0][1][0] - Sobs[1][0][0]) / sqrt(2.);
          M[0][0][0] = eps + k1r * k1r + k1i * k1i; M[0][0][1] = 0.;
          M[0][1][0] = eps + k1r * k2r + k1i * k2i; M[0][1][1] = eps + k1i * k2r - k1r * k2i;
          M[0][2][0] = eps + k1r * k3r + k1i * k3i; M[0][2][1] = eps + k1i * k3r - k1r * k3i;
          M[0][3][0] = eps + k1r * k4r + k1i * k4i; M[0][3][1] = eps + k1i * k4r - k1r * k4i;
          M[1][0][0] =  M[0][1][0]; M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + k2r * k2r + k2i * k2i; M[1][1][1] = 0.;
          M[1][2][0] = eps + k2r * k3r + k2i * k3i; M[1][2][1] = eps + k2i * k3r - k2r * k3i;
          M[1][3][0] = eps + k2r * k4r + k2i * k4i; M[1][3][1] = eps + k2i * k4r - k2r * k4i;
          M[2][0][0] =  M[0][2][0]; M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0]; M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + k3r * k3r + k3i * k3i; M[2][2][1] = 0.;
          M[2][3][0] = eps + k3r * k4r + k3i * k4i; M[2][3][1] = eps + k3i * k4r - k3r * k4i;
          M[3][0][0] =  M[0][3][0]; M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0]; M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0]; M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + k4r * k4r + k4i * k4i; M[3][3][1] = 0.;
          ProductCmplxMatrix(Ainv,M,T,4);
          ProductCmplxMatrix(T,Aconj,Ttmp1,4);
          M_out[T311][lig][col] = (Ttmp1[0][0][0]);
          M_out[T312_re][lig][col] = (Ttmp1[0][1][0]);
          M_out[T312_im][lig][col] = (Ttmp1[0][1][1]);
          M_out[T313_re][lig][col] = (Ttmp1[0][2][0]);
          M_out[T313_im][lig][col] = (Ttmp1[0][2][1]);
          M_out[T322][lig][col] = (Ttmp1[1][1][0]);
          M_out[T323_re][lig][col] = (Ttmp1[1][2][0]);
          M_out[T323_im][lig][col] = (Ttmp1[1][2][1]);
          M_out[T333][lig][col] = (Ttmp1[2][2][0]);
          
          ProductCmplxMatrix(S,SCRi,Sobs,2);
          k1r = (Sobs[0][0][0] + Sobs[1][1][0]) / sqrt(2.);
          k1i = (Sobs[0][0][1] + Sobs[1][1][1]) / sqrt(2.);
          k2r = (Sobs[0][0][0] - Sobs[1][1][0]) / sqrt(2.);
          k2i = (Sobs[0][0][1] - Sobs[1][1][1]) / sqrt(2.);
          k3r = (Sobs[0][1][0] + Sobs[1][0][0]) / sqrt(2.);
          k3i = (Sobs[0][1][1] + Sobs[1][0][1]) / sqrt(2.);
          k4r = (Sobs[1][0][1] - Sobs[0][1][1]) / sqrt(2.);
          k4i = (Sobs[0][1][0] - Sobs[1][0][0]) / sqrt(2.);
          M[0][0][0] = eps + k1r * k1r + k1i * k1i; M[0][0][1] = 0.;
          M[0][1][0] = eps + k1r * k2r + k1i * k2i; M[0][1][1] = eps + k1i * k2r - k1r * k2i;
          M[0][2][0] = eps + k1r * k3r + k1i * k3i; M[0][2][1] = eps + k1i * k3r - k1r * k3i;
          M[0][3][0] = eps + k1r * k4r + k1i * k4i; M[0][3][1] = eps + k1i * k4r - k1r * k4i;
          M[1][0][0] =  M[0][1][0]; M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + k2r * k2r + k2i * k2i; M[1][1][1] = 0.;
          M[1][2][0] = eps + k2r * k3r + k2i * k3i; M[1][2][1] = eps + k2i * k3r - k2r * k3i;
          M[1][3][0] = eps + k2r * k4r + k2i * k4i; M[1][3][1] = eps + k2i * k4r - k2r * k4i;
          M[2][0][0] =  M[0][2][0]; M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0]; M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + k3r * k3r + k3i * k3i; M[2][2][1] = 0.;
          M[2][3][0] = eps + k3r * k4r + k3i * k4i; M[2][3][1] = eps + k3i * k4r - k3r * k4i;
          M[3][0][0] =  M[0][3][0]; M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0]; M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0]; M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + k4r * k4r + k4i * k4i; M[3][3][1] = 0.;
          ProductCmplxMatrix(Binv,M,T,4);
          ProductCmplxMatrix(T,Bconj,Ttmp2,4);
          
          M_out[T311][lig][col] = 0.5*(Ttmp1[0][0][0] + Ttmp2[0][0][0]);
          M_out[T312_re][lig][col] = 0.5*(Ttmp1[0][1][0] + Ttmp2[0][1][0]);
          M_out[T312_im][lig][col] = 0.5*(Ttmp1[0][1][1] + Ttmp2[0][1][1]);
          M_out[T313_re][lig][col] = 0.5*(Ttmp1[0][2][0] + Ttmp2[0][2][0]);
          M_out[T313_im][lig][col] = 0.5*(Ttmp1[0][2][1] + Ttmp2[0][2][1]);
          M_out[T322][lig][col] = 0.5*(Ttmp1[1][1][0] + Ttmp2[1][1][0]);
          M_out[T323_re][lig][col] = 0.5*(Ttmp1[1][2][0] + Ttmp2[1][2][0]);
          M_out[T323_im][lig][col] = 0.5*(Ttmp1[1][2][1] + Ttmp2[1][2][1]);
          M_out[T333][lig][col] = 0.5*(Ttmp1[2][2][0] + Ttmp2[2][2][0]);
          } /* valid */
        } /*col*/
      } /*lig*/
    //write
    } // NbBlock
    
for (Np = 0; Np < NpolarOut; Np++) printf("Mout(%i) = %f\n",Np,M_out[Np][140][33]);
  
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarIn, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
//  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}

