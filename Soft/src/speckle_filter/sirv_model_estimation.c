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

File   : sirv_model_estimation.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2012
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

Description :  Normalised (or not) Coherency / Covariance matrix
               estimation with the SIRV Model

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

/* ALIASES  */

/* CONSTANTS  */

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

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *out_span;
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "SPP"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l, kk, ll;
  int M, NormFlag, FlagStop, NwinLC;
  float Criterion, CriterionDen, Denom;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
/* Matrix arrays */
  float ***S_in;
  float **M_out;
  float *span;
  float ***Tn, ***Tn_m1, ***Tnp1, ***TT;
  float *det;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsirv_model_estimation.exe\n");
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
strcat(UsageHelp," (int)   	-norm	Normalisation flag (1/0)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

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

if(argc < 21) {
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
  get_commandline_prm(argc,argv,"-norm",int_cmd_prm,&NormFlag,1,UsageHelp);

  MemoryAlloc = -1;

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
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
      
  sprintf(file_name, "%s%s", out_dir, "span.bin");
  if ((out_span = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
      
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  Valid = matrix_float(NwinL, Ncol + NwinC);

  span = vector_float(Sub_Ncol);

  S_in = matrix3d_float(NpolarIn,NwinL,2*(Ncol+NwinC));
  M_out = matrix_float(NpolarOut,Sub_Ncol);

  if (strcmp(PolTypeOut,"C2")==0) M = 2;
  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) M = 3;
  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) M = 4;

  det = vector_float(2);
  TT = matrix3d_float(M, M, 2);
  Tn = matrix3d_float(M, M, 2);
  Tn_m1 = matrix3d_float(M, M, 2);
  Tnp1 = matrix3d_float(M, M, 2);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NwinL; lig++) 
      for (col = 0; col < Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    for (Np = 0; Np < NpolarIn; Np++) fread(&S_in[0][0][0], sizeof(float), 2 * Ncol, in_datafile[Np]);
    if (FlagValid == 1) fread(&Valid[0][0], sizeof(float), Ncol, in_valid);
    }

/* Set the input matrix to 0 */
  for (lig = 0; lig < NwinLM1S2; lig++) {
    for (Np = 0; Np < NpolarIn; Np++) 
      for (col = 0; col < 2*(Ncol + NwinC); col++) S_in[Np][lig][col] = 0.;
    if (FlagValid == 1) 
      for (col = 0; col < Ncol + NwinC; col++) Valid[lig][col] = 0.;
    }
    
/*******************************************************************/
/* FIRST (Nwin+1)/2 LINES READING TO FILTER THE FIRST DATA LINE */
  for (Np = 0; Np < NpolarIn; Np++)
    for (lig = NwinLM1S2; lig < NwinL - 1; lig++) {
      fread(&S_in[Np][lig][2*NwinCM1S2], sizeof(float), 2*Ncol, in_datafile[Np]);
      for (col = Off_col; col < Sub_Ncol + Off_col; col++) {
        S_in[Np][lig][2*(col - Off_col + NwinCM1S2)] = S_in[Np][lig][2*(col + NwinCM1S2)];
        S_in[Np][lig][2*(col - Off_col + NwinCM1S2)+1] = S_in[Np][lig][2*(col + NwinCM1S2)+1];
        }
      for (col = Sub_Ncol; col < Sub_Ncol + NwinCM1S2; col++) {
        S_in[Np][lig][2*(col + NwinCM1S2)] = 0.; S_in[Np][lig][2*(col + NwinCM1S2)+1] = 0.;
        }
    }
  if (FlagValid == 1) {
    for (lig = NwinLM1S2; lig < NwinL - 1; lig++) {
      fread(&Valid[lig][NwinCM1S2], sizeof(float), Ncol, in_valid);
      for (col = Off_col; col < Sub_Ncol + Off_col; col++)
        Valid[lig][col - Off_col + NwinCM1S2] = Valid[lig][col + NwinCM1S2];
      for (col = Sub_Ncol; col < Sub_Ncol + NwinCM1S2; col++) Valid[lig][col + NwinCM1S2] = 0.;
      }
    }
    
/********************************************************************
********************************************************************/
  for (kk=0; kk<M; kk++) {
    for (ll=0; ll<M; ll++) {
      Tn[kk][ll][0] = 0.; Tn[kk][ll][1]=0.;
      Tn_m1[kk][ll][0] = 0.; Tn_m1[kk][ll][1]=0.;
      Tnp1[kk][ll][0] = 0.; Tnp1[kk][ll][1]=0.;
      }
    Tn[kk][kk][0] = 1.;
    Tn_m1[kk][kk][0] = 1.;
    Tnp1[kk][kk][0] = 1.;
    }
  
/********************************************************************
********************************************************************/

  for (lig = 0; lig < Sub_Nlig; lig++) {
  
    PrintfLine(lig,Sub_Nlig);

    for (Np = 0; Np < NpolarIn; Np++) {
/* 1 line reading with zero padding */
      if (lig < Sub_Nlig - NwinLM1S2)
        fread(&S_in[Np][NwinL - 1][NwinCM1S2], sizeof(float), 2*Ncol, in_datafile[Np]);
      else
        for (col = 0; col < Ncol + NwinC; col++) {
          S_in[Np][NwinL - 1][2*col] = 0.; S_in[Np][NwinL - 1][2*col+1] = 0.;
          }
/* Row-wise shift */
      for (col = Off_col; col < Sub_Ncol + Off_col; col++) {
        S_in[Np][NwinL - 1][2*(col - Off_col + NwinCM1S2)] = S_in[Np][NwinL - 1][2*(col + NwinCM1S2)];
        S_in[Np][NwinL - 1][2*(col - Off_col + NwinCM1S2)+1] = S_in[Np][NwinL - 1][2*(col + NwinCM1S2)+1];
        }
      for (col = Sub_Ncol; col < Sub_Ncol + NwinCM1S2; col++) {
        S_in[Np][NwinL - 1][2*(col + NwinCM1S2)] = 0.; S_in[Np][NwinL - 1][2*(col + NwinCM1S2)+1] = 0.;
        }
     }

/*******************************************************************/
    if (FlagValid == 1) {
      if (lig < Sub_Nlig - NwinLM1S2)
        fread(&Valid[NwinL - 1][NwinCM1S2], sizeof(float), Ncol, in_valid);
      else
        for (col = 0; col < Ncol + NwinC; col++) Valid[NwinL - 1][col] = 0.;
/* Row-wise shift */
      for (col = Off_col; col < Sub_Ncol + Off_col; col++)
        Valid[NwinL - 1][col - Off_col + NwinCM1S2] = Valid[NwinL - 1][col + NwinCM1S2];
      for (col = Sub_Ncol; col < Sub_Ncol + NwinCM1S2; col++) Valid[NwinL - 1][col + NwinCM1S2] = 0.;
      }
/*******************************************************************/

    for (col = 0; col < Sub_Ncol; col++) {
      for (Np=0; Np < NpolarOut; Np++) M_out[Np][col] = 0.;
      span[col] = 0.;
      if (Valid[NwinLM1S2][NwinCM1S2+col] == 1.) {

        /* Initialisation Id */
        for (kk=0; kk<M; kk++) {
          for (ll=0; ll<M; ll++) {
            Tn[kk][ll][0] = 0.; Tn[kk][ll][1]=0.;
            Tn_m1[kk][ll][0] = 0.; Tn_m1[kk][ll][1]=0.;
            Tnp1[kk][ll][0] = 0.; Tnp1[kk][ll][1]=0.;
            }
          Tn[kk][kk][0] = 1.;
          Tn_m1[kk][kk][0] = 1.;
          Tnp1[kk][kk][0] = 1.;
          }

        FlagStop = 0; Denom = 0.;
        while (FlagStop == 0) {
          for (kk=0; kk<M; kk++) {
            for (ll=0; ll<M; ll++) {
              Tn[kk][ll][0] = Tnp1[kk][ll][0]; Tn[kk][ll][1] = Tnp1[kk][ll][1];
              Tnp1[kk][ll][0] = 0.; Tnp1[kk][ll][1] = 0.;
              }
            }
          if (strcmp(PolTypeOut,"C2")==0) {
            InverseHermitianMatrix2(Tn, Tn_m1);
            DeterminantHermitianMatrix2(Tn, det);
            }
          if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
            InverseHermitianMatrix3(Tn, Tn_m1);
            DeterminantHermitianMatrix3(Tn, det);
            }
          if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
            InverseHermitianMatrix4(Tn, Tn_m1);
            DeterminantHermitianMatrix4(Tn, det);
            }
          CriterionDen = fabs(det[0]);

          NwinLC = 0;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              if (strcmp(PolTypeOut,"C2")==0) {
                k1r = S_in[0][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                k1i = S_in[0][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                k2r = S_in[1][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                k2i = S_in[1][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                TT[0][0][0] = k1r * k1r + k1i * k1i; TT[0][0][1] = 0.;
                TT[0][1][0] = k1r * k2r + k1i * k2i; TT[0][1][1] = k1i * k2r - k1r * k2i;
                TT[1][0][0] = TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
                TT[1][1][0] = k2r * k2r + k2i * k2i; TT[1][1][1] = 0.;
                Denom = Tn_m1[0][0][0]*TT[0][0][0]+Tn_m1[1][1][0]*TT[1][1][0];
                Denom += 2*Tn_m1[0][1][0]*TT[0][1][0]+2*Tn_m1[0][1][1]*TT[0][1][1];
                }

              if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
                if (strcmp(PolTypeOut,"T3")==0) {
                  k1r = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k1i = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k2r = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)] - S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k2i = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] - S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k3r = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k3i = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  }
                if (strcmp(PolTypeOut,"C3")==0) {
                  k1r = S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                  k1i = S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                  k2r = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k2i = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k3r = S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                  k3i = S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                  }
                TT[0][0][0] = k1r * k1r + k1i * k1i; TT[0][0][1] = 0.;
                TT[0][1][0] = k1r * k2r + k1i * k2i; TT[0][1][1] = k1i * k2r - k1r * k2i;
                TT[0][2][0] = k1r * k3r + k1i * k3i; TT[0][2][1] = k1i * k3r - k1r * k3i;
                TT[1][0][0] = TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
                TT[1][1][0] = k2r * k2r + k2i * k2i; TT[1][1][1] = 0.;
                TT[1][2][0] = k2r * k3r + k2i * k3i; TT[1][2][1] = k2i * k3r - k2r * k3i;
                TT[2][0][0] = TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
                TT[2][1][0] = TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
                TT[2][2][0] = k3r * k3r + k3i * k3i; TT[2][2][1] = 0.;
                Denom = Tn_m1[0][0][0]*TT[0][0][0]+Tn_m1[1][1][0]*TT[1][1][0]+Tn_m1[2][2][0]*TT[2][2][0];
                Denom += 2*Tn_m1[0][1][0]*TT[0][1][0]+2*Tn_m1[0][1][1]*TT[0][1][1];
                Denom += 2*Tn_m1[0][2][0]*TT[0][2][0]+2*Tn_m1[0][2][1]*TT[0][2][1];
                Denom += 2*Tn_m1[1][2][0]*TT[1][2][0]+2*Tn_m1[1][2][1]*TT[1][2][1];
                }
                
              if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
                if (strcmp(PolTypeOut,"T4")==0) {
                  k1r = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k1i = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k2r = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)] - S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k2i = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] - S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k3r = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  k3i = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k4r = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] - S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
                  k4i = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
                  }
                if (strcmp(PolTypeOut,"C4")==0) {
                  k1r = S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                  k1i = S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                  k2r = S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                  k2i = S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                  k3r = S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                  k3i = S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                  k4r = S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
                  k4i = S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
                  }
                TT[0][0][0] = k1r * k1r + k1i * k1i; TT[0][0][1] = 0.;
                TT[0][1][0] = k1r * k2r + k1i * k2i; TT[0][1][1] = k1i * k2r - k1r * k2i;
                TT[0][2][0] = k1r * k3r + k1i * k3i; TT[0][2][1] = k1i * k3r - k1r * k3i;
                TT[0][3][0] = k1r * k4r + k1i * k4i; TT[0][3][1] = k1i * k4r - k1r * k4i;
                TT[1][0][0] = TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
                TT[1][1][0] = k2r * k2r + k2i * k2i; TT[1][1][1] = 0.;
                TT[1][2][0] = k2r * k3r + k2i * k3i; TT[1][2][1] = k2i * k3r - k2r * k3i;
                TT[1][3][0] = k2r * k4r + k2i * k4i; TT[1][3][1] = k2i * k4r - k2r * k4i;
                TT[2][0][0] = TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
                TT[2][1][0] = TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
                TT[2][2][0] = k3r * k3r + k3i * k3i; TT[2][2][1] = 0.;
                TT[2][3][0] = k3r * k4r + k3i * k4i; TT[2][3][1] = k3i * k4r - k3r * k4i;
                TT[3][0][0] = TT[0][3][0]; TT[3][0][1] = -TT[0][3][1];
                TT[3][1][0] = TT[1][3][0]; TT[3][1][1] = -TT[1][3][1];
                TT[3][2][0] = TT[2][3][0]; TT[3][2][1] = -TT[2][3][1];
                TT[3][3][0] = k4r * k4r + k4i * k4i; TT[3][3][1] = 0.;
                Denom = Tn_m1[0][0][0]*TT[0][0][0]+Tn_m1[1][1][0]*TT[1][1][0]+Tn_m1[2][2][0]*TT[2][2][0]+Tn_m1[3][3][0]*TT[3][3][0];
                Denom += 2*Tn_m1[0][1][0]*TT[0][1][0]+2*Tn_m1[0][1][1]*TT[0][1][1];
                Denom += 2*Tn_m1[0][2][0]*TT[0][2][0]+2*Tn_m1[0][2][1]*TT[0][2][1];
                Denom += 2*Tn_m1[0][3][0]*TT[0][3][0]+2*Tn_m1[0][3][1]*TT[0][3][1];
                Denom += 2*Tn_m1[1][2][0]*TT[1][2][0]+2*Tn_m1[1][2][1]*TT[1][2][1];
                Denom += 2*Tn_m1[1][3][0]*TT[1][3][0]+2*Tn_m1[1][3][1]*TT[1][3][1];
                Denom += 2*Tn_m1[2][3][0]*TT[2][3][0]+2*Tn_m1[2][3][1]*TT[2][3][1];
                }

              if (Denom != 0.0) {
                NwinLC++;
                for (kk=0; kk<M; kk++) {
                  for (ll=0; ll<M; ll++) {
                    Tnp1[kk][ll][0] += TT[kk][ll][0]/Denom;
                    Tnp1[kk][ll][1] += TT[kk][ll][1]/Denom;
                    }
                  }
                }
              } /* l */
            } /* k */          

          for (kk=0; kk<M; kk++) {
            for (ll=0; ll<M; ll++) {
              Tnp1[kk][ll][0] = (M*Tnp1[kk][ll][0]) / NwinLC;
              Tnp1[kk][ll][1] = (M*Tnp1[kk][ll][1]) / NwinLC;
              }
            }
          for (kk=0; kk<M; kk++) {
            for (ll=0; ll<M; ll++) {
              TT[kk][ll][0] = Tnp1[kk][ll][0] - Tn[kk][ll][0];
              TT[kk][ll][1] = Tnp1[kk][ll][1] - Tn[kk][ll][1];
              }
            }

          if (strcmp(PolTypeOut,"C2")==0) {
            DeterminantHermitianMatrix2(TT, det);
            }
          if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
            DeterminantHermitianMatrix3(TT, det);
            }
          if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
            DeterminantHermitianMatrix4(TT, det);
            }
          Criterion = fabs(det[0]) / CriterionDen;
          if (Criterion <= 1.E-6) FlagStop = 1;
          } /* while */
          
        if (strcmp(PolTypeOut,"C2")==0) {
          M_out[C211][col] = Tnp1[0][0][0];
          M_out[C212_re][col] = Tnp1[0][1][0]; M_out[C212_im][col] = Tnp1[0][1][1];
          M_out[C222][col] = Tnp1[1][1][0];
          }
        if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
          M_out[T311][col] = Tnp1[0][0][0];
          M_out[T312_re][col] = Tnp1[0][1][0]; M_out[T312_im][col] = Tnp1[0][1][1];
          M_out[T313_re][col] = Tnp1[0][2][0]; M_out[T313_im][col] = Tnp1[0][2][1];
          M_out[T322][col] = Tnp1[1][1][0];
          M_out[T323_re][col] = Tnp1[1][2][0]; M_out[T323_im][col] = Tnp1[1][2][1];
          M_out[T333][col] = Tnp1[2][2][0];
          }
        if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
          M_out[T411][col] = Tnp1[0][0][0];
          M_out[T412_re][col] = Tnp1[0][1][0]; M_out[T412_im][col] = Tnp1[0][1][1];
          M_out[T413_re][col] = Tnp1[0][2][0]; M_out[T413_im][col] = Tnp1[0][2][1];
          M_out[T414_re][col] = Tnp1[0][3][0]; M_out[T414_im][col] = Tnp1[0][3][1];
          M_out[T422][col] = Tnp1[1][1][0];
          M_out[T423_re][col] = Tnp1[1][2][0]; M_out[T423_im][col] = Tnp1[1][2][1];
          M_out[T424_re][col] = Tnp1[1][3][0]; M_out[T424_im][col] = Tnp1[1][3][1];
          M_out[T433][col] = Tnp1[2][2][0];
          M_out[T434_re][col] = Tnp1[2][3][0]; M_out[T434_im][col] = Tnp1[2][3][1];
          M_out[T444][col] = Tnp1[3][3][0];
          }
        
        /* Span */
        span[col] = 0.; 
        if (strcmp(PolTypeOut,"C2")==0) {
          k1r = S_in[0][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
          k1i = S_in[0][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
          k2r = S_in[1][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
          k2i = S_in[1][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
          TT[0][0][0] = k1r * k1r + k1i * k1i; TT[0][0][1] = 0.;
          TT[0][1][0] = k1r * k2r + k1i * k2i; TT[0][1][1] = k1i * k2r - k1r * k2i;
          TT[1][0][0] = TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = k2r * k2r + k2i * k2i; TT[1][1][1] = 0.;
          span[col] = Tn_m1[0][0][0]*TT[0][0][0]+Tn_m1[1][1][0]*TT[1][1][0];
          span[col] += 2*Tn_m1[0][1][0]*TT[0][1][0]+2*Tn_m1[0][1][1]*TT[0][1][1];
          }

        if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
          if (strcmp(PolTypeOut,"T3")==0) {
            k1r = (S_in[s11][NwinLM1S2][2*(NwinCM1S2+col)] + S_in[s22][NwinLM1S2][2*(NwinCM1S2+col)]) / sqrt(2.);
            k1i = (S_in[s11][NwinLM1S2][2*(NwinCM1S2+col)+1] + S_in[s22][NwinLM1S2][2*(NwinCM1S2+col)+1]) / sqrt(2.);
            k2r = (S_in[s11][NwinLM1S2][2*(NwinCM1S2+col)] - S_in[s22][NwinLM1S2][2*(NwinCM1S2+col)]) / sqrt(2.);
            k2i = (S_in[s11][NwinLM1S2][2*(NwinCM1S2+col)+1] - S_in[s22][NwinLM1S2][2*(NwinCM1S2+col)+1]) / sqrt(2.);
            k3r = (S_in[s12][NwinLM1S2][2*(NwinCM1S2+col)] + S_in[s21][NwinLM1S2][2*(NwinCM1S2+col)]) / sqrt(2.);
            k3i = (S_in[s12][NwinLM1S2][2*(NwinCM1S2+col)+1] + S_in[s21][NwinLM1S2][2*(NwinCM1S2+col)+1]) / sqrt(2.);
            }
          if (strcmp(PolTypeOut,"C3")==0) {
            k1r = S_in[s11][NwinLM1S2][2*(NwinCM1S2+col)];
            k1i = S_in[s11][NwinLM1S2][2*(NwinCM1S2+col)+1];
            k2r = (S_in[s12][NwinLM1S2][2*(NwinCM1S2+col)] + S_in[s21][NwinLM1S2][2*(NwinCM1S2+col)]) / sqrt(2.);
            k2i = (S_in[s12][NwinLM1S2][2*(NwinCM1S2+col)+1] + S_in[s21][NwinLM1S2][2*(NwinCM1S2+col)+1]) / sqrt(2.);
            k3r = S_in[s22][NwinLM1S2][2*(NwinCM1S2+col)];
            k3i = S_in[s22][NwinLM1S2][2*(NwinCM1S2+col)+1];
            }
          TT[0][0][0] = k1r * k1r + k1i * k1i; TT[0][0][1] = 0.;
          TT[0][1][0] = k1r * k2r + k1i * k2i; TT[0][1][1] = k1i * k2r - k1r * k2i;
          TT[0][2][0] = k1r * k3r + k1i * k3i; TT[0][2][1] = k1i * k3r - k1r * k3i;
          TT[1][0][0] = TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = k2r * k2r + k2i * k2i; TT[1][1][1] = 0.;
          TT[1][2][0] = k2r * k3r + k2i * k3i; TT[1][2][1] = k2i * k3r - k2r * k3i;
          TT[2][0][0] = TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] = TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = k3r * k3r + k3i * k3i; TT[2][2][1] = 0.;
          span[col] = Tn_m1[0][0][0]*TT[0][0][0]+Tn_m1[1][1][0]*TT[1][1][0]+Tn_m1[2][2][0]*TT[2][2][0];
          span[col] += 2*Tn_m1[0][1][0]*TT[0][1][0]+2*Tn_m1[0][1][1]*TT[0][1][1];
          span[col] += 2*Tn_m1[0][2][0]*TT[0][2][0]+2*Tn_m1[0][2][1]*TT[0][2][1];
          span[col] += 2*Tn_m1[1][2][0]*TT[1][2][0]+2*Tn_m1[1][2][1]*TT[1][2][1];
          }

        if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
          if (strcmp(PolTypeOut,"T4")==0) {
            k1r = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
            k1i = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
            k2r = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)] - S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
            k2i = (S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] - S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
            k3r = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
            k3i = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
            k4r = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1] - S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1]) / sqrt(2.);
            k4i = (S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)] + S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)]) / sqrt(2.);
            }
          if (strcmp(PolTypeOut,"C4")==0) {
            k1r = S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
            k1i = S_in[s11][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
            k2r = S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
            k2i = S_in[s12][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
            k3r = S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
            k3i = S_in[s21][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
            k4r = S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)];
            k4i = S_in[s22][NwinLM1S2+k][2*(NwinCM1S2+col+l)+1];
            }
          TT[0][0][0] = k1r * k1r + k1i * k1i; TT[0][0][1] = 0.;
          TT[0][1][0] = k1r * k2r + k1i * k2i; TT[0][1][1] = k1i * k2r - k1r * k2i;
          TT[0][2][0] = k1r * k3r + k1i * k3i; TT[0][2][1] = k1i * k3r - k1r * k3i;
          TT[0][3][0] = k1r * k4r + k1i * k4i; TT[0][3][1] = k1i * k4r - k1r * k4i;
          TT[1][0][0] = TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = k2r * k2r + k2i * k2i; TT[1][1][1] = 0.;
          TT[1][2][0] = k2r * k3r + k2i * k3i; TT[1][2][1] = k2i * k3r - k2r * k3i;
          TT[1][3][0] = k2r * k4r + k2i * k4i; TT[1][3][1] = k2i * k4r - k2r * k4i;
          TT[2][0][0] = TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] = TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = k3r * k3r + k3i * k3i; TT[2][2][1] = 0.;
          TT[2][3][0] = k3r * k4r + k3i * k4i; TT[2][3][1] = k3i * k4r - k3r * k4i;
          TT[3][0][0] = TT[0][3][0]; TT[3][0][1] = -TT[0][3][1];
          TT[3][1][0] = TT[1][3][0]; TT[3][1][1] = -TT[1][3][1];
          TT[3][2][0] = TT[2][3][0]; TT[3][2][1] = -TT[2][3][1];
          TT[3][3][0] = k4r * k4r + k4i * k4i; TT[3][3][1] = 0.;
          span[col] = Tn_m1[0][0][0]*TT[0][0][0]+Tn_m1[1][1][0]*TT[1][1][0]+Tn_m1[2][2][0]*TT[2][2][0]+Tn_m1[3][3][0]*TT[3][3][0];
          span[col] += 2*Tn_m1[0][1][0]*TT[0][1][0]+2*Tn_m1[0][1][1]*TT[0][1][1];
          span[col] += 2*Tn_m1[0][2][0]*TT[0][2][0]+2*Tn_m1[0][2][1]*TT[0][2][1];
          span[col] += 2*Tn_m1[0][3][0]*TT[0][3][0]+2*Tn_m1[0][3][1]*TT[0][3][1];
          span[col] += 2*Tn_m1[1][2][0]*TT[1][2][0]+2*Tn_m1[1][2][1]*TT[1][2][1];
          span[col] += 2*Tn_m1[1][3][0]*TT[1][3][0]+2*Tn_m1[1][3][1]*TT[1][3][1];
          span[col] += 2*Tn_m1[2][3][0]*TT[2][3][0]+2*Tn_m1[2][3][1]*TT[2][3][1];
          }
          
        if (NormFlag == 0)
          for (Np=0; Np < NpolarOut; Np++) M_out[Np][col] *= (span[col] / M);
        } /*Valid */
      } /* col */
    for (Np=0; Np < NpolarOut; Np++) fwrite(&M_out[Np][0], sizeof(float), Sub_Ncol, out_datafile[Np]);
    fwrite(&span[0], sizeof(float), Sub_Ncol, out_span); 

    /* Line-wise shift */
    for (l = 0; l < (NwinL - 1); l++)
      for (col = 0; col < Sub_Ncol; col++) {
        for (Np = 0; Np < NpolarIn; Np++) {
          S_in[Np][l][2*(NwinCM1S2 + col)] = S_in[Np][l + 1][2*(NwinCM1S2 + col)];
          S_in[Np][l][2*(NwinCM1S2 + col)+1] = S_in[Np][l + 1][2*(NwinCM1S2 + col)+1];
          }
      Valid[l][NwinCM1S2 + col] = Valid[l + 1][NwinCM1S2 + col];
      }
    } /* lig */
    
    
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  fclose(out_span);
  
/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


