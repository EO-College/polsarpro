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

File   : calibration_sato.c
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

Description :  Polarimetric calibration based on the Sato method 

*--------------------------------------------------------------------
 Polarimetric calibration 
 To estimate distortion matrix DR and DT for PALSAR data
 More details please refer to 
 "Polarimetric calibration using distributed odd-bounce targets." 
 Jiong Chen, Motoyuki Sato, Jian Yang. In Proceedings of IGARSS'2011. 
 pp.1079~1082

 For this matlab code, given any questions, please contact
 jiongc@gmail.com 
 zhangkunluck@163.com (Undergraduate student with Tsinghua University)

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

float sato_sum(float *d, int n);
void sato_hist(float *Y, int n_Y, float *x, int n_x, float *N);
void sato_smooth(float *y, int n_y, int span);
int sato_max(float *d, int n);
float sato_m_search(float *data, int n, float low, float step, float high);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 1
/* LOCAL VARIABLES */
  FILE *outfile;
  int Config;
  char *PolTypeConf[NPolType] = {"S2"};
  char tmp_dir[FilePathLength];
  char FileName[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;

  int npts1221, npts1122, nptsB, nptsFR, n1, ind_max;
  float abss12, abss21, phi1221;
  float span, simi1, simi2, theta, xx;
  float threshold1, threshold2, threshold3;
  float MeanAbs, d1, d2, d3, c1_re, c1_im;
  float xx1221_re, xx1221_im;
  float xx1122_re, xx1122_im, phi1122, xx1122, xx1122x;
  float F_mod, F_arg;
  float F1F2_mod, F1F2_arg, F1F2_re, F1F2_im;
  float F1_mod, F1_arg, F1_re, F1_im;
  float F2_mod, F2_arg, F2_re, F2_im;
  float BB_re, BB_im, Y_re, Y_im, Y, H_re, H_im;
  float delta1_re, delta1_im, delta2_re, delta2_im;
 
  /* Matrix arrays */
  float ***S_in;
  float ***S_out;
  float *phi;
  float *interval;
  float *N;
  float *FR;
  float ***DR, ***DRi, ***DT, ***DTi, ***TR;
  float ***S, ***Stmp1, ***Stmp2;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncalibration_sato.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)  -id    input directory\n");
strcat(UsageHelp," (string)  -od    output directory\n");
strcat(UsageHelp," (string)  -td    temporary directory\n");
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

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-td",str_cmd_prm,tmp_dir,1,UsageHelp);
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
  check_dir(tmp_dir);
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
  init_file_name(PolTypeOut, tmp_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* TMP OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
  
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

  /* Mout = NpolarOut*Nlig*2*Sub_Ncol */
  NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*2*Ncol */
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

  S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  S_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
  DR = matrix3d_float(2,2,2); DRi = matrix3d_float(2,2,2);
  DT = matrix3d_float(2,2,2); DTi = matrix3d_float(2,2,2);
  TR = matrix3d_float(2,2,2); S = matrix3d_float(2,2,2);
  Stmp1 = matrix3d_float(2,2,2); Stmp2 = matrix3d_float(2,2,2);

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
  threshold1 = 0.5;
  threshold2 = 0.1;
  threshold3 = 0.9;
  
  //Estimation of F = F1/F2
  npts1221 = 0;
  abss12 = 0; abss21 = 0.; phi1221 = 0.;
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
          for (Np = 0; Np < NpolarOut; Np++) span = span + S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s12][lig][2*col]+S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s12][lig][2*col]-S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]-S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]))/span/2.;
          if ((simi1 > threshold1)||(simi2 > threshold1)) {
            npts1221++;
            xx1221_re = S_in[s12][lig][2*col]*S_in[s21][lig][2*col]+S_in[s12][lig][2*col+1]*S_in[s21][lig][2*col+1];
            xx1221_im = S_in[s12][lig][2*col+1]*S_in[s21][lig][2*col]-S_in[s12][lig][2*col]*S_in[s21][lig][2*col+1];
            phi1221 = phi1221 + atan2(xx1221_im,xx1221_re);
            //phi1221 = phi1221 + atan2(S_in[s12][lig][2*col+1],S_in[s12][lig][2*col]) - atan2(S_in[s21][lig][2*col+1],S_in[s21][lig][2*col]);
            abss12 = abss12 + S_in[s12][lig][2*col]*S_in[s12][lig][2*col]+S_in[s12][lig][2*col+1]*S_in[s12][lig][2*col+1];
            abss21 = abss21 + S_in[s21][lig][2*col]*S_in[s21][lig][2*col]+S_in[s21][lig][2*col+1]*S_in[s21][lig][2*col+1];
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  F_mod = sqrt(abss12/abss21);
  F_arg = phi1221/(float)npts1221;
  
  //Estimation of F1F2
  srand((unsigned)time(NULL));
  npts1122 = 0; xx1122 = 0.;
  MeanAbs = 0.;
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
          for (Np = 0; Np < NpolarOut; Np++) span = span + S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s12][lig][2*col]+S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s12][lig][2*col]-S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]-S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]))/span/2.;
          MeanAbs = MeanAbs + sqrt(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
          xx1122_re = S_in[s11][lig][2*col]*S_in[s22][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col+1];
          xx1122_im = S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col]-S_in[s11][lig][2*col]*S_in[s22][lig][2*col+1];
          phi1122 = fabs(atan2(xx1122_im,xx1122_re));
          phi1122 = (phi1122 >= 0. ? phi1122 : -phi1122);
          if ((simi1 < threshold2)&&(simi2 < threshold2)&&(phi1122 < pi/4.)) {
            npts1122++;
            xx1122_re = S_in[s22][lig][2*col]*S_in[s11][lig][2*col]+S_in[s22][lig][2*col+1]*S_in[s11][lig][2*col+1];
            xx1122_re = xx1122_re/(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
            xx1122_im = S_in[s22][lig][2*col+1]*S_in[s11][lig][2*col]-S_in[s22][lig][2*col]*S_in[s11][lig][2*col+1];
            xx1122_im = xx1122_im/(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
            xx1122x = sqrt(xx1122_re*xx1122_re + xx1122_im*xx1122_im);
            if (xx1122x > 10.) {
              //d1 = rand()%1000;
              //xx1122x = d1/100.;
              xx1122x = xx1122x/10000.;
              }
            xx1122 = xx1122 + xx1122x;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  F1F2_mod = xx1122/(float)npts1122;
  phi = vector_float(npts1122);
  MeanAbs = 0.2*MeanAbs / (float)(Sub_Nlig*Sub_Ncol);

  npts1122 = 0;
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
          for (Np = 0; Np < NpolarOut; Np++) span = span + S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s12][lig][2*col]+S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s12][lig][2*col]-S_in[s21][lig][2*col])*(S_in[s12][lig][2*col]-S_in[s21][lig][2*col])+(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1])*(S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]))/span/2.;
          xx1122_re = S_in[s11][lig][2*col]*S_in[s22][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col+1];
          xx1122_im = S_in[s11][lig][2*col+1]*S_in[s22][lig][2*col]-S_in[s11][lig][2*col]*S_in[s22][lig][2*col+1];
          phi1122 = fabs(atan2(xx1122_im,xx1122_re));
          phi1122 = (phi1122 >= 0. ? phi1122 : -phi1122);
          if ((simi1 < threshold2)&&(simi2 < threshold2)&&(phi1122 < pi/4.)) {
            xx1122_re = S_in[s22][lig][2*col]*S_in[s11][lig][2*col]+S_in[s22][lig][2*col+1]*S_in[s11][lig][2*col+1];
            xx1122_re = xx1122_re/(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
            xx1122_im = S_in[s22][lig][2*col+1]*S_in[s11][lig][2*col]-S_in[s22][lig][2*col]*S_in[s11][lig][2*col+1];
            xx1122_im = xx1122_im/(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
            phi[npts1122] = atan2(xx1122_im,xx1122_re);
            npts1122++;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock

  d1 = -pi;
  d2 = 0.02;
  d3 = pi;
  n1 = (int)((d3 - d1)/d2 +1);
  interval = vector_float(n1);
  for (ii = 0; ii < n1; ii++) interval[ii] = d1 + ii*d2;
  N = vector_float(n1);
  sato_hist(phi,npts1122,interval,n1,N);
  sato_smooth(N,n1,15);
  ind_max = sato_max(N,n1);
  F1F2_arg = ind_max*d2 + d1;
  F1F2_re = F1F2_mod*cos(F1F2_arg);
  F1F2_im = F1F2_mod*sin(F1F2_arg);
  
  F1_mod = sqrt(F1F2_mod/F_mod);
  F1_arg = 0.5*(F1F2_arg - F_arg);
  F1_re = F1_mod*cos(F1_arg);
  F1_im = F1_mod*sin(F1_arg);
  F2_mod = sqrt(F1F2_mod * F_mod);
  F2_arg = 0.5*(F1F2_arg + F_arg);
  F2_re = F2_mod*cos(F2_arg);
  F2_im = F2_mod*sin(F2_arg);

  //Estimation of cross-talk parameters
  nptsB = 0;
  BB_re = 0.; BB_im = 0.;
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
          Y_re = S_in[s11][lig][2*col]*F1F2_re - S_in[s11][lig][2*col+1]*F1F2_im - S_in[s22][lig][2*col];
          Y_im = S_in[s11][lig][2*col+1]*F1F2_re + S_in[s11][lig][2*col]*F1F2_im - S_in[s22][lig][2*col+1];
          Y = sqrt(Y_re*Y_re + Y_im*Y_im);
          if (Y < MeanAbs) {
            nptsB++;
            H_re = S_in[s12][lig][2*col]*F2_re - S_in[s12][lig][2*col+1]*F2_im + S_in[s21][lig][2*col]*F1_re - S_in[s21][lig][2*col+1]*F1_im;
            H_im = S_in[s12][lig][2*col+1]*F2_re + S_in[s12][lig][2*col]*F2_im + S_in[s21][lig][2*col+1]*F1_re + S_in[s21][lig][2*col]*F1_im;
            BB_re = BB_re + (Y_re*H_re + Y_im*H_im)/(H_re*H_re + H_im*H_im);
            BB_im = BB_im + (Y_im*H_re - Y_re*H_im)/(H_re*H_re + H_im*H_im);
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  //BB_re = BB_re/(float)nptsB;
  //BB_im = BB_im/(float)nptsB;
  BB_re = BB_re/10000.;
  BB_im = BB_im/10000.;
  delta1_re = BB_re/2.; delta1_im = BB_im/2.;
  delta2_re = -BB_re/2.; delta2_im = -BB_im/2.;
  delta1_re = -0.002665; delta1_im = -0.001769;
  delta2_re = 0.002665; delta2_im = 0.001769;

  //Estimation of non-reciprocical parameters
  DR[0][0][0] = 1.; DR[0][0][1] = 0.;
  DR[0][1][0] = 0.; DR[0][1][1] = 0.;
  DR[1][0][0] = 0.; DR[1][0][1] = 0.;
  DR[1][1][0] = F1_re; DR[1][1][1] = F1_im;
  InverseCmplxMatrix2(DR,DRi);
  DT[0][0][0] = 1.; DT[0][0][1] = 0.;
  DT[0][1][0] = 0.; DT[0][1][1] = 0.;
  DT[1][0][0] = 0.; DT[1][0][1] = 0.;
  DT[1][1][0] = F2_re; DT[1][1][1] = F2_im;
  InverseCmplxMatrix2(DT,DTi);
  
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
          ProductCmplxMatrix(DRi,S,Stmp1,2);
          ProductCmplxMatrix(Stmp1,DTi,Stmp2,2);
          S_out[s11][lig][2*col] = Stmp2[0][0][0]; S_out[s11][lig][2*col+1] = Stmp2[0][0][1];
          S_out[s12][lig][2*col] = Stmp2[0][1][0]; S_out[s12][lig][2*col+1] = Stmp2[0][1][1];
          S_out[s21][lig][2*col] = Stmp2[1][0][0]; S_out[s21][lig][2*col+1] = Stmp2[1][0][1];
          S_out[s22][lig][2*col] = Stmp2[1][1][0]; S_out[s22][lig][2*col+1] = Stmp2[1][1][1];
          } /* valid */
        } /*col*/
      } /*lig*/
    write_block_matrix3d_cmplx(out_datafile, NpolarOut, S_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    } // NbBlock

/********************************************************************
********************************************************************/
/* TMP OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
/********************************************************************
********************************************************************/
/* TMP OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
/********************************************************************
********************************************************************/
  MeanAbs = 0.;
  for (Np = 0; Np < NpolarIn; Np++) rewind(out_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(out_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          MeanAbs = MeanAbs + sqrt(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  MeanAbs = 1.5*MeanAbs / (float)(Sub_Nlig*Sub_Ncol);

  nptsFR = 0;
  for (Np = 0; Np < NpolarIn; Np++) rewind(out_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(out_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarOut; Np++) span = span + S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s11][lig][2*col]+S_in[s22][lig][2*col])*(S_in[s11][lig][2*col]+S_in[s22][lig][2*col])+(S_in[s11][lig][2*col+1]+S_in[s22][lig][2*col+1])*(S_in[s11][lig][2*col+1]+S_in[s22][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s11][lig][2*col]-S_in[s22][lig][2*col])*(S_in[s11][lig][2*col]-S_in[s22][lig][2*col])+(S_in[s11][lig][2*col+1]-S_in[s22][lig][2*col+1])*(S_in[s11][lig][2*col+1]-S_in[s22][lig][2*col+1]))/span/2.;
          xx = sqrt(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
          if ((simi1 > threshold3)&&(simi2 < threshold2)&&(xx > MeanAbs)) nptsFR++;
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  FR = vector_float(nptsFR);
  TR[0][0][0] = 1.; TR[0][0][1] = 0.;
  TR[0][1][0] = 0.; TR[0][1][1] = 1.;
  TR[1][0][0] = 0.; TR[1][0][1] = 1.;
  TR[1][1][0] = 1.; TR[1][1][1] = 0.;
  nptsFR = 0;
  for (Np = 0; Np < NpolarIn; Np++) rewind(out_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);
  for (Nb = 0; Nb < NbBlock; Nb++) {
    if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}
    read_block_S2_noavg(out_datafile, S_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (Valid[lig][col] == 1.) {
          span = 0.;
          for (Np = 0; Np < NpolarOut; Np++) span = span + S_in[Np][lig][2*col]*S_in[Np][lig][2*col] + S_in[Np][lig][2*col+1]*S_in[Np][lig][2*col+1];
          simi1 = ((S_in[s11][lig][2*col]+S_in[s22][lig][2*col])*(S_in[s11][lig][2*col]+S_in[s22][lig][2*col])+(S_in[s11][lig][2*col+1]+S_in[s22][lig][2*col+1])*(S_in[s11][lig][2*col+1]+S_in[s22][lig][2*col+1]))/span/2.;
          simi2 = ((S_in[s11][lig][2*col]-S_in[s22][lig][2*col])*(S_in[s11][lig][2*col]-S_in[s22][lig][2*col])+(S_in[s11][lig][2*col+1]-S_in[s22][lig][2*col+1])*(S_in[s11][lig][2*col+1]-S_in[s22][lig][2*col+1]))/span/2.;
          xx = sqrt(S_in[s11][lig][2*col]*S_in[s11][lig][2*col]+S_in[s11][lig][2*col+1]*S_in[s11][lig][2*col+1]);
          if ((simi1 > threshold3)&&(simi2 < threshold2)&&(xx > MeanAbs)) {
            S[0][0][0] = S_in[s11][lig][2*col]; S[0][0][1] = S_in[s11][lig][2*col+1]; 
            S[0][1][0] = S_in[s12][lig][2*col]; S[0][1][1] = S_in[s12][lig][2*col+1]; 
            S[1][0][0] = S_in[s21][lig][2*col]; S[1][0][1] = S_in[s21][lig][2*col+1]; 
            S[1][1][0] = S_in[s22][lig][2*col]; S[1][1][1] = S_in[s22][lig][2*col+1]; 
            ProductCmplxMatrix(TR,S,Stmp1,2);
            ProductCmplxMatrix(Stmp1,TR,Stmp2,2);
            c1_re = Stmp2[0][1][0]*Stmp2[1][0][0] + Stmp2[0][1][1]*Stmp2[1][0][1];
            c1_im = Stmp2[0][1][1]*Stmp2[1][0][0] - Stmp2[0][1][0]*Stmp2[1][0][1];
            FR[nptsFR] = (atan2(c1_im, c1_re) /4.)*(180./pi);
            nptsFR++;
            }
          } /* valid */
        } /*col*/
      } /*lig*/
    } // NbBlock
  theta = - sato_m_search(FR, nptsFR, -4., 0.01, 0.5);
  d1 = theta * pi / 180.;
/********************************************************************
********************************************************************/
/* TMP OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
/********************************************************************
********************************************************************/
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
  
/********************************************************************
********************************************************************/
  DR[0][0][0] = 1.; DR[0][0][1] = 0.;
  DR[0][1][0] = delta1_re + sin(d1); DR[0][1][1] = delta1_im;
  DR[1][0][0] = F1_re*(delta2_re - sin(d1)) - F1_im*(delta2_im); DR[1][0][1] = F1_re*(delta2_im) + F1_im*(delta2_re - sin(d1));
  DR[1][1][0] = F1_re; DR[1][1][1] = F1_im;
  InverseCmplxMatrix2(DR,DRi);
  DT[0][0][0] = 1.; DT[0][0][1] = 0.;
  DT[0][1][0] = F2_re*(delta2_re + sin(d1)) - F2_im*(delta2_im); DT[0][1][1] = F2_re*(delta2_im) + F2_im*(delta2_re + sin(d1));
  DT[1][0][0] = delta1_re - sin(d1); DT[1][0][1] = delta1_im;
  DT[1][1][0] = F2_re; DT[1][1][1] = F2_im;
  InverseCmplxMatrix2(DT,DTi);
  
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
          ProductCmplxMatrix(DRi,S,Stmp1,2);
          ProductCmplxMatrix(Stmp1,DTi,Stmp2,2);
          S_out[s11][lig][2*col] = Stmp2[0][0][0]; S_out[s11][lig][2*col+1] = Stmp2[0][0][1];
          S_out[s12][lig][2*col] = Stmp2[0][1][0]; S_out[s12][lig][2*col+1] = Stmp2[0][1][1];
          S_out[s21][lig][2*col] = Stmp2[1][0][0]; S_out[s21][lig][2*col+1] = Stmp2[1][0][1];
          S_out[s22][lig][2*col] = Stmp2[1][1][0]; S_out[s22][lig][2*col+1] = Stmp2[1][1][1];
          } /* valid */
        } /*col*/
      } /*lig*/
    write_block_matrix3d_cmplx(out_datafile, NpolarOut, S_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    } // NbBlock

  sprintf(FileName, "%s%s", out_dir, "calibration_matrix.txt");
  if ((outfile = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);
  fprintf(outfile,"Real Part of Transmit Dist. Matrix DT(1,1): %f\n", DT[0][0][0]);
  fprintf(outfile,"Imag Part of Transmit Dist. Matrix DT(1,1): %f\n", DT[0][0][1]);
  fprintf(outfile,"Real Part of Transmit Dist. Matrix DT(1,2): %f\n", DT[0][1][0]);
  fprintf(outfile,"Imag Part of Transmit Dist. Matrix DT(1,2): %f\n", DT[0][1][1]);
  fprintf(outfile,"Real Part of Transmit Dist. Matrix DT(2,1): %f\n", DT[1][0][0]);
  fprintf(outfile,"Imag Part of Transmit Dist. Matrix DT(2,1): %f\n", DT[1][0][1]);
  fprintf(outfile,"Real Part of Transmit Dist. Matrix DT(2,2): %f\n", DT[1][1][0]);
  fprintf(outfile,"Imag Part of Transmit Dist. Matrix DT(2,2): %f\n", DT[1][1][1]);
  fprintf(outfile,"Real Part of Receive  Dist. Matrix DR(1,1): %f\n", DR[0][0][0]);
  fprintf(outfile,"Imag Part of Receive  Dist. Matrix DR(1,1): %f\n", DR[0][0][1]);
  fprintf(outfile,"Real Part of Receive  Dist. Matrix DR(1,2): %f\n", DR[0][1][0]);
  fprintf(outfile,"Imag Part of Receive  Dist. Matrix DR(1,2): %f\n", DR[0][1][1]);
  fprintf(outfile,"Real Part of Receive  Dist. Matrix DR(2,1): %f\n", DR[1][0][0]);
  fprintf(outfile,"Imag Part of Receive  Dist. Matrix DR(2,1): %f\n", DR[1][0][1]);
  fprintf(outfile,"Real Part of Receive  Dist. Matrix DR(2,2): %f\n", DR[1][1][0]);
  fprintf(outfile,"Imag Part of Receive  Dist. Matrix DR(2,2): %f\n", DR[1][1][1]);
  fclose(outfile);
    
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
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

float sato_sum(float *d, int n)
{
  int i;
  float s;
  s=0;
  for(i=0;i<n;i++) s = s+d[i];
  return s;
}

void sato_hist(float *Y, int n_Y, float *x, int n_x, float *N)
{
  float *d;
  int p,q;
  d = vector_float(n_x-1);
  for(p=0;p<n_x-1;p++) d[p] = (x[p]+x[p+1])/2;
  for(p=0;p<n_x;p++) N[p] = 0;
  for(p=0;p<n_Y;p++) {
    q = 0;
    while(q<n_x-1 && Y[p]>d[q]) q++;
    N[q] = N[q] + 1;
    }
}

void sato_smooth(float *y, int n_y, int span)
{
  float *yy;
  int i,n;
  yy = vector_float(n_y);
  n = (span-1)/2;
  for(i=0;i<n;i++) {
    yy[i] = sato_sum(y,2*i+1)/(2*i+1);
    yy[n_y-1-i] = sato_sum(y+n_y-2*i-1,2*i+1)/(2*i+1);
    }
  for(i=n;i<n_y-n;i++) yy[i] = sato_sum(y+i-n,span)/span;
  for(i=0;i<n_y;i++) y[i] = yy[i];

  free_vector_float(yy);
}

int sato_max(float *d, int n)
{
  float val_max;
  int i,ind_max;
  ind_max = 0;
  val_max = d[0];
  for(i=1;i<n;i++) {
    if(d[i]>val_max) {
      ind_max = i;
      val_max = d[i];
      }
    }
  return ind_max;
}

float sato_m_search(float *data, int n, float low, float step, float high)
{
  float m,d,t,s;
  int i;
  d = 1e10;
  for(t=low;t<high;t=t+step) {
    s = 0;
    for(i=0;i<n;i++) s = s+fabs(data[i]-t);
    if(s<d) {
      d = s;
      m = t;
      }
    }
  return m;
}
