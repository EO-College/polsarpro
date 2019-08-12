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

File   : lopez_filter.c
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

Description :  Lopez fully polarimetric speckle filter

*********************************************************************
PATENT LICENCE

UNIVERSITAT POLITÈCNICA DE CATALUNYA (UPC) whose registered office is
at C/ Jordi Girona, 31, Barcelona 08034 in SPAIN, is the owner of a 
Spanish patent application n° P200700430 filed on February 13th 2007
relating to a "PROCEDIMIENTO PARA LA ESTIMACIÓN DE MATRICES DE 
COVARIANZA Y COHERENCIA EN DATOS OBTENIDOS MEDIANTE SISTEMAS 
COHERENTES MULTICANAL"

It has been decided on November 20th 2008, between UNIVERSITAT 
POLITÈCNICA DE CATALUNYA (UPC) and INSTITUT D'ELECTRONIQUE ET DE 
TÉLÉCOMMUNICATIONS DE RENNES (IETR - UMR CNRS 6164) that such patent 
could be implemented as a part of the software for The Polarimetric 
SAR Data Processing and Educational Tool (PolSARpro).

UNIVERSITAT POLITÈCNICA DE CATALUNYA (UPC) does not warrant that the 
Patent is valid or that manufacture or sale of P200700430 under this 
Licence is not an infringement of any valid and subsisting patents 
not held by UNIVERSITAT POLITÈCNICA DE CATALUNYA (UPC).

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
int filtering(int Sub_Nlig, int Sub_Ncol, int C_re, int C_im, int C1, int C2, int R_re, int R_im, int NwL2, int NwC2);
int control(int Sub_Nlig, int Sub_Ncol, int C_re, int C_im, int C1, int C2, int R_re, int R_im, int NwL2, int NwC2);
int rh_bias_corrected(int Sub_Nlig, int Sub_Ncol, int R_re, int R_im, int NwinL, int NwinC, float fc_weight, float strg);
float ro2nc(float value);
float ro2bs(float value);
int read_ro_nc_bs();

/* GLOBAL VARIABLES  */

float ***M_in;
float ***M_out;
float ***R_out;
float **Tmp;
float **Bias;
float **nc_mod;
float **bs;

float ro_val[5100], nc_val[5100], bs_val[5100];

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
#define NPolType 11

/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3", "C4", "T2", "T3", "T4", "SPP"};
  
/* Internal variables */
  int ii, lig, col, k, l;
  int ligg, it, Nit, improved_rho;
  float fc_weight, strg, phi;
  int Ncorr;
  int  C11, C12_re, C12_im, C13_re, C13_im, C14_re, C14_im;
  int C22, C23_re, C23_im, C24_re, C24_im, C33;
  int C34_re, C34_im, C44;
  int  R12_re, R12_im, R13_re, R13_im, R14_re, R14_im;
  int  R23_re, R23_im, R24_re, R24_im, R34_re, R34_im; 
  int ligDone = 0;

/* Matrix arrays */

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nlopez_filter.exe\n");
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
strcat(UsageHelp," (int)   	-nit 	Number of Iterations\n");
strcat(UsageHelp," (int)   	-rho 	Improved Rho estimation (no 0 - yes 1)\n");
strcat(UsageHelp," (float) 	-fcw 	Fc Weight\n");
strcat(UsageHelp," (float) 	-str 	Strg\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
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

if(argc < 27) {
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
  get_commandline_prm(argc,argv,"-nit",int_cmd_prm,&Nit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rho",int_cmd_prm,&improved_rho,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fcw",flt_cmd_prm,&fc_weight,1,UsageHelp);
  get_commandline_prm(argc,argv,"-str",flt_cmd_prm,&strg,1,UsageHelp);

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
  
  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);

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

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) Ncorr = 2;
  if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) Ncorr = 2;
  if ((strcmp(PolTypeOut,"T3") == 0)||(strcmp(PolTypeOut,"C3") == 0)) Ncorr = 6;
  if ((strcmp(PolTypeOut,"T4") == 0)||(strcmp(PolTypeOut,"C4") == 0)) Ncorr = 12;

  NBlockA = 0; NBlockB = 0;
  /* Mout = NpolarOut*(Sub_Nlig+NwinL)*(Sub_Ncol+NwinC) */
  NBlockA += NpolarOut*(Sub_Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Sub_Ncol+NwinC);
  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Tmp = (Nlig+NwinL)*(Sub_Ncol+NwinC) */
  NBlockA += (Sub_Ncol+NwinC); NBlockB += NwinL*(Sub_Ncol+NwinC);
  /* Bias = (Nlig+NwinL)*(Sub_Ncol+NwinC) */
  NBlockA += (Sub_Ncol+NwinC); NBlockB += NwinL*(Sub_Ncol+NwinC);
  /* nc_mod = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* bs = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Rout = Ncorr*(Sub_Nlig+NwinL)*(Sub_Ncol+NwinC) */
  NBlockA += Ncorr*(Sub_Ncol+NwinC); NBlockB += Ncorr*NwinL*(Sub_Ncol+NwinC);
  
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

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  Tmp = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  Bias = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  nc_mod = matrix_float(NligBlock[0], Sub_Ncol);
  bs = matrix_float(NligBlock[0], Sub_Ncol);
  R_out = matrix3d_float(Ncorr, NligBlock[0] + NwinL, Sub_Ncol + NwinC);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

    if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);
    if (strcmp(PolTypeOut,"T4")==0) T4_to_C4(M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    read_ro_nc_bs();
  
#pragma omp parallel for private(col,ligg,Np,k,l) shared(ligDone) schedule(dynamic)
    for (lig =  0; lig < NligBlock[Nb]; lig++) {
      ligDone++;
      if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
      ligg = lig + NwinLM1S2;
      for (col = 0; col < Sub_Ncol; col++) {
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][ligg][NwinCM1S2+col] = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              M_out[Np][ligg][NwinCM1S2+col] += M_in[Np][NwinLM1S2+k+lig][NwinCM1S2+l+col];
              }
          M_out[Np][ligg][NwinCM1S2+col] /= (NwinL*NwinC);
          }
        }
      }

/********************************************************************
 * CASE Polar Type Out = C2 or T2
********************************************************************/
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)
    ||(strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
    C11 = 0; C12_re = 1; C12_im = 2; C22 = 3;
    R12_re = 0; R12_im = 1; 
    
#pragma omp parallel for private(col) shared(ligDone) schedule(dynamic)
    for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
      //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
      for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
        R_out[R12_re][lig][col] = M_out[C12_re][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C22][lig][col]);
        R_out[R12_im][lig][col] = M_out[C12_im][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C22][lig][col]);
        }
      }

  /* Calculating Improved Coherences */
    if (improved_rho == 1) {
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R12_re, R12_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R12_im][lig][col],R_out[R12_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R12_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R12_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      }

  /* Filtering */
    for (it = 0; it < Nit; it++) {
      filtering(NligBlock[Nb], Sub_Ncol, C12_re, C12_im, C11, C22, R12_re, R12_im, NwinLM1S2, NwinCM1S2);
      } 
  /* Final control of coherence */
    control(NligBlock[Nb], Sub_Ncol, C12_re, C12_im, C11, C22, R12_re, R12_im, NwinLM1S2, NwinCM1S2);
    }
    
/********************************************************************
 * CASE Polar Type Out = T3 or C3
********************************************************************/
  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) {
    C11 = 0; C12_re = 1; C12_im = 2; C13_re = 3; C13_im = 4;
    C22 = 5; C23_re = 6; C23_im = 7; C33 = 8;
    R12_re = 0; R12_im = 1; R13_re = 2; R13_im = 3; R23_re = 4; R23_im = 5;
    
#pragma omp parallel for private(col) shared(ligDone) schedule(dynamic)
    for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
      //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
      for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
        R_out[R12_re][lig][col] = M_out[C12_re][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C22][lig][col]);
        R_out[R12_im][lig][col] = M_out[C12_im][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C22][lig][col]);
        R_out[R13_re][lig][col] = M_out[C13_re][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C33][lig][col]);
        R_out[R13_im][lig][col] = M_out[C13_im][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C33][lig][col]);
        R_out[R23_re][lig][col] = M_out[C23_re][lig][col] / sqrt(M_out[C22][lig][col]*M_out[C33][lig][col]);
        R_out[R23_im][lig][col] = M_out[C23_im][lig][col] / sqrt(M_out[C22][lig][col]*M_out[C33][lig][col]);
        }
      }

  /* Calculating Improved Coherences */
    if (improved_rho == 1) {
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R12_re, R12_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R12_im][lig][col],R_out[R12_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R12_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R12_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R13_re, R13_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R13_im][lig][col],R_out[R13_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R13_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R13_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R23_re, R23_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R23_im][lig][col],R_out[R23_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R23_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R23_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      }

  /* Filtering */
    for (it = 0; it < Nit; it++) {
      filtering(NligBlock[Nb], Sub_Ncol, C12_re, C12_im, C11, C22, R12_re, R12_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C13_re, C13_im, C11, C33, R13_re, R13_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C23_re, C23_im, C22, C33, R23_re, R23_im, NwinLM1S2, NwinCM1S2);
      } 
  /* Final control of coherence */
    control(NligBlock[Nb], Sub_Ncol, C12_re, C12_im, C11, C22, R12_re, R12_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C13_re, C13_im, C11, C33, R13_re, R13_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C23_re, C23_im, C22, C33, R23_re, R23_im, NwinLM1S2, NwinCM1S2);
    
    if (strcmp(PolTypeOut,"T3")==0) C3_to_T3(M_out, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);
    }

/********************************************************************
 * CASE Polar Type Out = T4 or C4
********************************************************************/
  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) {
    C11 = 0; C12_re = 1; C12_im = 2; C13_re = 3; C13_im = 4;
    C14_re = 5; C14_im = 6; C22 = 7; C23_re = 8; C23_im = 9;
    C24_re = 10; C24_im = 11; C33 = 12; C34_re = 13; C34_im = 14; C44 = 15;
    R12_re = 0; R12_im = 1; R13_re = 2; R13_im = 3; R14_re = 4; R14_im = 5;
    R23_re = 6; R23_im = 7; R24_re = 8; R24_im = 9; R34_re = 10; R34_im = 11; 
    
#pragma omp parallel for private(col) shared(ligDone) schedule(dynamic)
    for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
      //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
      for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
        R_out[R12_re][lig][col] = M_out[C12_re][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C22][lig][col]);
        R_out[R12_im][lig][col] = M_out[C12_im][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C22][lig][col]);
        R_out[R13_re][lig][col] = M_out[C13_re][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C33][lig][col]);
        R_out[R13_im][lig][col] = M_out[C13_im][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C33][lig][col]);
        R_out[R14_re][lig][col] = M_out[C14_re][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C44][lig][col]);
        R_out[R14_im][lig][col] = M_out[C14_im][lig][col] / sqrt(M_out[C11][lig][col]*M_out[C44][lig][col]);
        R_out[R23_re][lig][col] = M_out[C23_re][lig][col] / sqrt(M_out[C22][lig][col]*M_out[C33][lig][col]);
        R_out[R23_im][lig][col] = M_out[C23_im][lig][col] / sqrt(M_out[C22][lig][col]*M_out[C33][lig][col]);
        R_out[R24_re][lig][col] = M_out[C24_re][lig][col] / sqrt(M_out[C22][lig][col]*M_out[C44][lig][col]);
        R_out[R24_im][lig][col] = M_out[C24_im][lig][col] / sqrt(M_out[C22][lig][col]*M_out[C44][lig][col]);
        R_out[R34_re][lig][col] = M_out[C34_re][lig][col] / sqrt(M_out[C33][lig][col]*M_out[C44][lig][col]);
        R_out[R34_im][lig][col] = M_out[C34_im][lig][col] / sqrt(M_out[C33][lig][col]*M_out[C44][lig][col]);
        }
      }

  /* Calculating Improved Coherences */
    if (improved_rho == 1) {
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R12_re, R12_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R12_im][lig][col],R_out[R12_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R12_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R12_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R13_re, R13_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R13_im][lig][col],R_out[R13_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R13_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R13_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R14_re, R14_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R14_im][lig][col],R_out[R14_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R14_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R14_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R23_re, R23_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R23_im][lig][col],R_out[R23_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R23_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R23_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R24_re, R24_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R24_im][lig][col],R_out[R24_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R24_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R24_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      rh_bias_corrected(NligBlock[Nb], Sub_Ncol, R34_re, R34_im, NwinL, NwinC, fc_weight, strg);
#pragma omp parallel for private(col,phi) shared(ligDone) schedule(dynamic)
      for (lig =  NwinLM1S2; lig < NligBlock[Nb] + NwinLM1S2; lig++) {
        //if (NbBlock <= 2) PrintfLine(lig - NwinLM1S2,NligBlock[Nb]);
        for (col = NwinCM1S2; col < Sub_Ncol + NwinCM1S2; col++) {
          phi = atan2(R_out[R34_im][lig][col],R_out[R34_re][lig][col]);
          if (Tmp[lig][col] <= 0.) Tmp[lig][col] = eps;
          R_out[R34_re][lig][col] = Tmp[lig][col]*cos(phi);
          R_out[R34_im][lig][col] = Tmp[lig][col]*sin(phi);
          }
        }
      }

  /* Filtering */
    for (it = 0; it < Nit; it++) {
      filtering(NligBlock[Nb], Sub_Ncol, C12_re, C12_im, C11, C22, R12_re, R12_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C13_re, C13_im, C11, C33, R13_re, R13_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C14_re, C14_im, C11, C44, R14_re, R14_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C23_re, C23_im, C22, C33, R23_re, R23_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C24_re, C24_im, C22, C44, R24_re, R24_im, NwinLM1S2, NwinCM1S2);
      filtering(NligBlock[Nb], Sub_Ncol, C34_re, C34_im, C33, C44, R34_re, R34_im, NwinLM1S2, NwinCM1S2);
      } 
  /* Final control of coherence */
    control(NligBlock[Nb], Sub_Ncol, C12_re, C12_im, C11, C22, R12_re, R12_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C13_re, C13_im, C11, C33, R13_re, R13_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C14_re, C14_im, C11, C44, R14_re, R14_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C23_re, C23_im, C22, C33, R23_re, R23_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C24_re, C24_im, C22, C44, R24_re, R24_im, NwinLM1S2, NwinCM1S2);
    control(NligBlock[Nb], Sub_Ncol, C34_re, C34_im, C33, C44, R34_re, R34_im, NwinLM1S2, NwinCM1S2);
    
    if (strcmp(PolTypeOut,"T4")==0) C4_to_T4(M_out, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);
    }

/********************************************************************
********************************************************************/

  write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, NwinLM1S2, NwinCM1S2, Sub_Ncol+NwinC);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0] + NwinL);
  free_matrix_float(Tmp, NligBlock[0] + NwinL);
  free_matrix3d_float(R_out, Ncorr, NligBlock[0] + NwinL);
  free_matrix_float(Bias, NligBlock[0] + NwinL);
  free_matrix_float(nc_mod, NligBlock[0]);
  free_matrix_float(bs, NligBlock[0]);
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
int filtering(int SubNlig, int SubNcol, int C_re, int C_im, int C1, int C2, int R_re, int R_im, int NwL2, int NwC2)
{

  int lig, col;
  int k, l, ligg;
  float rho_mod, phi, tmp, tmp_re, tmp_im, nc_re, nc_im;
  int ligDone = 0;

  ligDone = 0;
#pragma omp parallel for private(col,ligg,rho_mod) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < SubNlig; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,SubNlig);
    ligg = lig + NwL2;
    for (col = 0; col < SubNcol; col++) {
      rho_mod = sqrt(R_out[R_re][ligg][NwC2 + col]*R_out[R_re][ligg][NwC2 + col]+R_out[R_im][ligg][NwC2 + col]*R_out[R_im][ligg][NwC2 + col]);
      nc_mod[lig][col] = ro2nc(rho_mod); bs[lig][col] = ro2bs(rho_mod);
      }
    }

  ligDone = 0;
#pragma omp parallel for private(col,ligg,rho_mod,phi,nc_re,k,l,tmp_re,tmp_im,tmp) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < SubNlig; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,SubNlig);
    ligg = NwL2 + lig;
    for (col = 0; col < SubNcol; col++) {
    /*Within window statistics*/
      M_out[C_re][ligg][NwC2 + col] = 0.; M_out[C_im][ligg][NwC2 + col] = 0.;
      rho_mod = sqrt(R_out[R_re][ligg][NwC2 + col]*R_out[R_re][ligg][NwC2 + col]+R_out[R_im][ligg][NwC2 + col]*R_out[R_im][ligg][NwC2 + col]);
      phi = atan2(R_out[R_im][ligg][NwC2 + col],R_out[R_re][ligg][NwC2 + col]);
      nc_re = nc_mod[lig][col] * cos(phi); nc_im = nc_mod[lig][col] * sin(phi);
      for (k = -NwL2; k < 1 + NwL2; k++)
        for (l = -NwC2; l < 1 + NwC2; l++) {
          tmp_re = M_in[C_re][NwL2 + k + lig][NwC2 + col + l];
          tmp_im = M_in[C_im][NwL2 + k + lig][NwC2 + col + l];
          tmp = sqrt(tmp_re * tmp_re + tmp_im * tmp_im);
          tmp = (tmp * rho_mod) / nc_mod[lig][col]; tmp = (tmp * 4.) / pi; tmp = tmp / bs[lig][col];
          M_out[C_re][ligg][NwC2 + col] += nc_re * tmp;
          M_out[C_im][ligg][NwC2 + col] += nc_im * tmp;
        }
      M_out[C_re][ligg][NwC2 + col] /= ((2*NwL2+1) *(2*NwC2+1));
      M_out[C_im][ligg][NwC2 + col] /= ((2*NwL2+1) *(2*NwC2+1));
      } /*col */

    for (col = 0; col < Sub_Ncol; col++) {
      R_out[R_re][ligg][NwC2 + col] = M_out[C_re][ligg][NwC2 + col] / sqrt(M_out[C1][ligg][NwC2 + col] * M_out[C2][ligg][NwC2 + col]);
      R_out[R_im][ligg][NwC2 + col] = M_out[C_im][ligg][NwC2 + col] / sqrt(M_out[C1][ligg][NwC2 + col] * M_out[C2][ligg][NwC2 + col]);

      rho_mod = sqrt(R_out[R_re][ligg][NwC2 + col]*R_out[R_re][ligg][NwC2 + col]+R_out[R_im][ligg][NwC2 + col]*R_out[R_im][ligg][NwC2 + col]);
      phi = atan2(R_out[R_im][ligg][NwC2 + col],R_out[R_re][ligg][NwC2 + col]);

      if (rho_mod > 1.) {
        R_out[R_re][ligg][NwC2 + col] = cos(phi);
        R_out[R_im][ligg][NwC2 + col] = sin(phi);
        }
      if (rho_mod <= 0.) {
        R_out[R_re][ligg][NwC2 + col] = eps * cos(phi);
        R_out[R_im][ligg][NwC2 + col] = eps * sin(phi);
        }
      } /*col */

    } /*lig */

  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
int control(int SubNlig, int SubNcol, int C_re, int C_im, int C1, int C2, int R_re, int R_im, int NwL2, int NwC2)
{
  int lig, col;
  int ligg;
  float rho_mod, phi;
  int ligDone = 0;
  
  ligDone = 0;
#pragma omp parallel for private(col,ligg,rho_mod,phi) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < SubNlig; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,SubNlig);
    ligg = lig + NwL2;
    for (col = 0; col < SubNcol; col++) {
      R_out[R_re][ligg][NwC2 + col] = M_out[C_re][ligg][NwC2 + col] / sqrt(M_out[C1][ligg][NwC2 + col]*M_out[C2][ligg][NwC2 + col]);
      R_out[R_im][ligg][NwC2 + col] = M_out[C_im][ligg][NwC2 + col] / sqrt(M_out[C1][ligg][NwC2 + col]*M_out[C2][ligg][NwC2 + col]);
      rho_mod = sqrt(R_out[R_re][ligg][NwC2 + col]*R_out[R_re][ligg][NwC2 + col]+R_out[R_im][ligg][NwC2 + col]*R_out[R_im][ligg][NwC2 + col]);
      if (rho_mod > 1.) {
        phi = atan2(M_out[C_im][ligg][NwC2 + col],M_out[C_re][ligg][NwC2 + col]);
        rho_mod = sqrt(M_out[C1][ligg][NwC2 + col]*M_out[C2][ligg][NwC2 + col]);
        M_out[C_re][ligg][NwC2 + col] = rho_mod * cos(phi);
        M_out[C_im][ligg][NwC2 + col] = rho_mod * sin(phi);
        }
      }
    }
  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
int rh_bias_corrected(int SubNlig, int SubNcol, int R_re, int R_im, int NNwinL, int NNwinC, float fc_weight, float strg)
{
  int lig, col, k, l, it;
  int it_max, k_max;
  float fc, fct, ini_red;
  float power;
  int NwL2, NwC2;

  fc = fc_weight / (1.0 + (1.0 / (NNwinL * NNwinC)));
  ini_red = 0.5;
  it_max = 5;
  k_max = 5;

  for (lig = 0; lig < SubNlig + NNwinL; lig++) 
    for (col = 0; col < SubNcol + NNwinC; col++) {
      Tmp[lig][col]  = R_out[R_re][lig][col]*R_out[R_re][lig][col] + R_out[R_im][lig][col]*R_out[R_im][lig][col];
      }

  NwL2 = (NNwinL - 1)/2;
  NwC2 = (NNwinC - 1)/2;
  
  power = 1.32*sqrt(NNwinL*NNwinC);

  for (it = 0; it < it_max; it ++) {

#pragma omp parallel for private(col,k,l) schedule(dynamic)
    for (lig = 0; lig < SubNlig; lig++) 
      for (col = 0; col < SubNcol; col++) {
        Bias[NwL2 + lig][NwC2 + col] = 0.;
        for (k = -NwL2; k < 1 + NwL2; k++)
          for (l = -NwC2; l < 1 + NwC2; l++) {
            Bias[NwL2 + lig][NwC2 + col] += exp(power*log(1.-Tmp[NwL2 + lig][NwC2 + col])) * fc / (NNwinL*NNwinC);
            }
        }

#pragma omp parallel for private(k,l) schedule(dynamic)
    for (lig = NwL2; lig < SubNlig + NwL2; lig++) 
      for (col = NwC2; col < SubNcol + NwC2; col++) {
        Tmp[lig][col] = R_out[R_re][lig][col]*R_out[R_re][lig][col] + R_out[R_im][lig][col]*R_out[R_im][lig][col] - Bias[lig][col];
        }

    if (strg == 0.) {
      for (k = 0; k < k_max; k++) {
        fct = ini_red - k*(ini_red/k_max);
#pragma omp parallel for private(col) schedule(dynamic)
        for (lig = NwL2; lig < SubNlig + NwL2; lig++) 
          for (col = NwC2; col < SubNcol + NwC2; col++) {
            if (Tmp[lig][col] < 0.)  Tmp[lig][col] = R_out[R_re][lig][col]*R_out[R_re][lig][col] + R_out[R_im][lig][col]*R_out[R_im][lig][col] - fct*Bias[lig][col];
            }
        }
      } /* strg */

#pragma omp parallel for private(col) schedule(dynamic)
    for (lig = NwL2; lig < SubNlig + NwL2; lig++) 
      for (col = NwC2; col < SubNcol + NwC2; col++) {
        if (Tmp[lig][col] < 0.)  Tmp[lig][col] = R_out[R_re][lig][col]*R_out[R_re][lig][col] + R_out[R_im][lig][col]*R_out[R_im][lig][col] * (1. - strg);
      }

#pragma omp parallel for private(col) schedule(dynamic)
    for (lig = NwL2; lig < SubNlig + NwL2; lig++) 
      for (col = NwC2; col < SubNcol + NwC2; col++) 
        if (Tmp[lig][col] > 1.) Tmp[lig][col] = 1.;

    } /* it_max */

#pragma omp parallel for private(col) schedule(dynamic)
  for (lig = NwL2; lig < SubNlig + NwL2; lig++) 
    for (col = NwC2; col < SubNcol + NwC2; col++) 
      Tmp[lig][col] = sqrt(Tmp[lig][col]);

  return 1;
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
float ro2nc(float value)
{
  int k, flag;
  float ro1, ro2, nc1, nc2;

  flag = 0;
  k = 0;
  while (flag == 0) {
    if (ro_val[k] < value) k++;
    else flag = 1;
  }

  ro1 = ro_val[k-1]; ro2 = ro_val[k];
  nc1 = nc_val[k-1]; nc2 = nc_val[k];

  return (nc1 + (value - ro1)*(nc2 - nc1)/(ro2 - ro1));
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
float ro2bs(float value)
{
  int k, flag;
  float ro1, ro2, bs1, bs2;

  flag = 0;
  k = 0;
  while (flag == 0) {
    if (ro_val[k] < value) k++;
    else flag = 1;
  }

  ro1 = ro_val[k-1]; ro2 = ro_val[k];
  bs1 = bs_val[k-1]; bs2 = bs_val[k];

  return (bs1 + (value - ro1)*(bs2 - bs1)/(ro2 - ro1));
}

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
int read_ro_nc_bs()
{

ro_val[0] = 0.000000; ro_val[1] = 0.009091; ro_val[2] = 0.018182; ro_val[3] = 0.027273; ro_val[4] = 0.036364; ro_val[5] = 0.045455; ro_val[6] = 0.054545; ro_val[7] = 0.063636; ro_val[8] = 0.072727; ro_val[9] = 0.081818; 
ro_val[10] = 0.090909; ro_val[11] = 0.100000; ro_val[12] = 0.109091; ro_val[13] = 0.118182; ro_val[14] = 0.127273; ro_val[15] = 0.136364; ro_val[16] = 0.145455; ro_val[17] = 0.154545; ro_val[18] = 0.163636; ro_val[19] = 0.172727; 
ro_val[20] = 0.181818; ro_val[21] = 0.190909; ro_val[22] = 0.200000; ro_val[23] = 0.209091; ro_val[24] = 0.218182; ro_val[25] = 0.227273; ro_val[26] = 0.236364; ro_val[27] = 0.245455; ro_val[28] = 0.254545; ro_val[29] = 0.263636; 
ro_val[30] = 0.272727; ro_val[31] = 0.281818; ro_val[32] = 0.290909; ro_val[33] = 0.300000; ro_val[34] = 0.309091; ro_val[35] = 0.318182; ro_val[36] = 0.327273; ro_val[37] = 0.336364; ro_val[38] = 0.345455; ro_val[39] = 0.354545; 
ro_val[40] = 0.363636; ro_val[41] = 0.372727; ro_val[42] = 0.381818; ro_val[43] = 0.390909; ro_val[44] = 0.400000; ro_val[45] = 0.409091; ro_val[46] = 0.418182; ro_val[47] = 0.427273; ro_val[48] = 0.436364; ro_val[49] = 0.445455; 
ro_val[50] = 0.454545; ro_val[51] = 0.463636; ro_val[52] = 0.472727; ro_val[53] = 0.481818; ro_val[54] = 0.490909; ro_val[55] = 0.500000; ro_val[56] = 0.509091; ro_val[57] = 0.518182; ro_val[58] = 0.527273; ro_val[59] = 0.536364; 
ro_val[60] = 0.545455; ro_val[61] = 0.554545; ro_val[62] = 0.563636; ro_val[63] = 0.572727; ro_val[64] = 0.581818; ro_val[65] = 0.590909; ro_val[66] = 0.600000; ro_val[67] = 0.609091; ro_val[68] = 0.618182; ro_val[69] = 0.627273; 
ro_val[70] = 0.636364; ro_val[71] = 0.645455; ro_val[72] = 0.654545; ro_val[73] = 0.663636; ro_val[74] = 0.672727; ro_val[75] = 0.681818; ro_val[76] = 0.690909; ro_val[77] = 0.700000; ro_val[78] = 0.709091; ro_val[79] = 0.718182; 
ro_val[80] = 0.727273; ro_val[81] = 0.736364; ro_val[82] = 0.745455; ro_val[83] = 0.754545; ro_val[84] = 0.763636; ro_val[85] = 0.772727; ro_val[86] = 0.781818; ro_val[87] = 0.790909; ro_val[88] = 0.800000; ro_val[89] = 0.809091; 
ro_val[90] = 0.818182; ro_val[91] = 0.827273; ro_val[92] = 0.836364; ro_val[93] = 0.845455; ro_val[94] = 0.854545; ro_val[95] = 0.863636; ro_val[96] = 0.872727; ro_val[97] = 0.881818; ro_val[98] = 0.890909; ro_val[99] = 0.900000; 
ro_val[100] = 0.900100; ro_val[101] = 0.900120; ro_val[102] = 0.900140; ro_val[103] = 0.900160; ro_val[104] = 0.900180; ro_val[105] = 0.900200; ro_val[106] = 0.900220; ro_val[107] = 0.900240; ro_val[108] = 0.900260; ro_val[109] = 0.900280; 
ro_val[110] = 0.900300; ro_val[111] = 0.900320; ro_val[112] = 0.900340; ro_val[113] = 0.900360; ro_val[114] = 0.900380; ro_val[115] = 0.900400; ro_val[116] = 0.900420; ro_val[117] = 0.900440; ro_val[118] = 0.900460; ro_val[119] = 0.900480; 
ro_val[120] = 0.900500; ro_val[121] = 0.900520; ro_val[122] = 0.900540; ro_val[123] = 0.900560; ro_val[124] = 0.900580; ro_val[125] = 0.900600; ro_val[126] = 0.900620; ro_val[127] = 0.900640; ro_val[128] = 0.900660; ro_val[129] = 0.900680; 
ro_val[130] = 0.900700; ro_val[131] = 0.900720; ro_val[132] = 0.900739; ro_val[133] = 0.900759; ro_val[134] = 0.900779; ro_val[135] = 0.900799; ro_val[136] = 0.900819; ro_val[137] = 0.900839; ro_val[138] = 0.900859; ro_val[139] = 0.900879; 
ro_val[140] = 0.900899; ro_val[141] = 0.900919; ro_val[142] = 0.900939; ro_val[143] = 0.900959; ro_val[144] = 0.900979; ro_val[145] = 0.900999; ro_val[146] = 0.901019; ro_val[147] = 0.901039; ro_val[148] = 0.901059; ro_val[149] = 0.901079; 
ro_val[150] = 0.901099; ro_val[151] = 0.901119; ro_val[152] = 0.901139; ro_val[153] = 0.901159; ro_val[154] = 0.901179; ro_val[155] = 0.901199; ro_val[156] = 0.901219; ro_val[157] = 0.901239; ro_val[158] = 0.901259; ro_val[159] = 0.901279; 
ro_val[160] = 0.901299; ro_val[161] = 0.901319; ro_val[162] = 0.901339; ro_val[163] = 0.901359; ro_val[164] = 0.901379; ro_val[165] = 0.901399; ro_val[166] = 0.901419; ro_val[167] = 0.901439; ro_val[168] = 0.901459; ro_val[169] = 0.901479; 
ro_val[170] = 0.901499; ro_val[171] = 0.901519; ro_val[172] = 0.901539; ro_val[173] = 0.901559; ro_val[174] = 0.901579; ro_val[175] = 0.901599; ro_val[176] = 0.901619; ro_val[177] = 0.901639; ro_val[178] = 0.901659; ro_val[179] = 0.901679; 
ro_val[180] = 0.901699; ro_val[181] = 0.901719; ro_val[182] = 0.901739; ro_val[183] = 0.901759; ro_val[184] = 0.901779; ro_val[185] = 0.901799; ro_val[186] = 0.901819; ro_val[187] = 0.901839; ro_val[188] = 0.901859; ro_val[189] = 0.901879; 
ro_val[190] = 0.901899; ro_val[191] = 0.901919; ro_val[192] = 0.901939; ro_val[193] = 0.901959; ro_val[194] = 0.901978; ro_val[195] = 0.901998; ro_val[196] = 0.902018; ro_val[197] = 0.902038; ro_val[198] = 0.902058; ro_val[199] = 0.902078; 
ro_val[200] = 0.902098; ro_val[201] = 0.902118; ro_val[202] = 0.902138; ro_val[203] = 0.902158; ro_val[204] = 0.902178; ro_val[205] = 0.902198; ro_val[206] = 0.902218; ro_val[207] = 0.902238; ro_val[208] = 0.902258; ro_val[209] = 0.902278; 
ro_val[210] = 0.902298; ro_val[211] = 0.902318; ro_val[212] = 0.902338; ro_val[213] = 0.902358; ro_val[214] = 0.902378; ro_val[215] = 0.902398; ro_val[216] = 0.902418; ro_val[217] = 0.902438; ro_val[218] = 0.902458; ro_val[219] = 0.902478; 
ro_val[220] = 0.902498; ro_val[221] = 0.902518; ro_val[222] = 0.902538; ro_val[223] = 0.902558; ro_val[224] = 0.902578; ro_val[225] = 0.902598; ro_val[226] = 0.902618; ro_val[227] = 0.902638; ro_val[228] = 0.902658; ro_val[229] = 0.902678; 
ro_val[230] = 0.902698; ro_val[231] = 0.902718; ro_val[232] = 0.902738; ro_val[233] = 0.902758; ro_val[234] = 0.902778; ro_val[235] = 0.902798; ro_val[236] = 0.902818; ro_val[237] = 0.902838; ro_val[238] = 0.902858; ro_val[239] = 0.902878; 
ro_val[240] = 0.902898; ro_val[241] = 0.902918; ro_val[242] = 0.902938; ro_val[243] = 0.902958; ro_val[244] = 0.902978; ro_val[245] = 0.902998; ro_val[246] = 0.903018; ro_val[247] = 0.903038; ro_val[248] = 0.903058; ro_val[249] = 0.903078; 
ro_val[250] = 0.903098; ro_val[251] = 0.903118; ro_val[252] = 0.903138; ro_val[253] = 0.903158; ro_val[254] = 0.903178; ro_val[255] = 0.903198; ro_val[256] = 0.903218; ro_val[257] = 0.903237; ro_val[258] = 0.903257; ro_val[259] = 0.903277; 
ro_val[260] = 0.903297; ro_val[261] = 0.903317; ro_val[262] = 0.903337; ro_val[263] = 0.903357; ro_val[264] = 0.903377; ro_val[265] = 0.903397; ro_val[266] = 0.903417; ro_val[267] = 0.903437; ro_val[268] = 0.903457; ro_val[269] = 0.903477; 
ro_val[270] = 0.903497; ro_val[271] = 0.903517; ro_val[272] = 0.903537; ro_val[273] = 0.903557; ro_val[274] = 0.903577; ro_val[275] = 0.903597; ro_val[276] = 0.903617; ro_val[277] = 0.903637; ro_val[278] = 0.903657; ro_val[279] = 0.903677; 
ro_val[280] = 0.903697; ro_val[281] = 0.903717; ro_val[282] = 0.903737; ro_val[283] = 0.903757; ro_val[284] = 0.903777; ro_val[285] = 0.903797; ro_val[286] = 0.903817; ro_val[287] = 0.903837; ro_val[288] = 0.903857; ro_val[289] = 0.903877; 
ro_val[290] = 0.903897; ro_val[291] = 0.903917; ro_val[292] = 0.903937; ro_val[293] = 0.903957; ro_val[294] = 0.903977; ro_val[295] = 0.903997; ro_val[296] = 0.904017; ro_val[297] = 0.904037; ro_val[298] = 0.904057; ro_val[299] = 0.904077; 
ro_val[300] = 0.904097; ro_val[301] = 0.904117; ro_val[302] = 0.904137; ro_val[303] = 0.904157; ro_val[304] = 0.904177; ro_val[305] = 0.904197; ro_val[306] = 0.904217; ro_val[307] = 0.904237; ro_val[308] = 0.904257; ro_val[309] = 0.904277; 
ro_val[310] = 0.904297; ro_val[311] = 0.904317; ro_val[312] = 0.904337; ro_val[313] = 0.904357; ro_val[314] = 0.904377; ro_val[315] = 0.904397; ro_val[316] = 0.904417; ro_val[317] = 0.904437; ro_val[318] = 0.904457; ro_val[319] = 0.904476; 
ro_val[320] = 0.904496; ro_val[321] = 0.904516; ro_val[322] = 0.904536; ro_val[323] = 0.904556; ro_val[324] = 0.904576; ro_val[325] = 0.904596; ro_val[326] = 0.904616; ro_val[327] = 0.904636; ro_val[328] = 0.904656; ro_val[329] = 0.904676; 
ro_val[330] = 0.904696; ro_val[331] = 0.904716; ro_val[332] = 0.904736; ro_val[333] = 0.904756; ro_val[334] = 0.904776; ro_val[335] = 0.904796; ro_val[336] = 0.904816; ro_val[337] = 0.904836; ro_val[338] = 0.904856; ro_val[339] = 0.904876; 
ro_val[340] = 0.904896; ro_val[341] = 0.904916; ro_val[342] = 0.904936; ro_val[343] = 0.904956; ro_val[344] = 0.904976; ro_val[345] = 0.904996; ro_val[346] = 0.905016; ro_val[347] = 0.905036; ro_val[348] = 0.905056; ro_val[349] = 0.905076; 
ro_val[350] = 0.905096; ro_val[351] = 0.905116; ro_val[352] = 0.905136; ro_val[353] = 0.905156; ro_val[354] = 0.905176; ro_val[355] = 0.905196; ro_val[356] = 0.905216; ro_val[357] = 0.905236; ro_val[358] = 0.905256; ro_val[359] = 0.905276; 
ro_val[360] = 0.905296; ro_val[361] = 0.905316; ro_val[362] = 0.905336; ro_val[363] = 0.905356; ro_val[364] = 0.905376; ro_val[365] = 0.905396; ro_val[366] = 0.905416; ro_val[367] = 0.905436; ro_val[368] = 0.905456; ro_val[369] = 0.905476; 
ro_val[370] = 0.905496; ro_val[371] = 0.905516; ro_val[372] = 0.905536; ro_val[373] = 0.905556; ro_val[374] = 0.905576; ro_val[375] = 0.905596; ro_val[376] = 0.905616; ro_val[377] = 0.905636; ro_val[378] = 0.905656; ro_val[379] = 0.905676; 
ro_val[380] = 0.905696; ro_val[381] = 0.905716; ro_val[382] = 0.905735; ro_val[383] = 0.905755; ro_val[384] = 0.905775; ro_val[385] = 0.905795; ro_val[386] = 0.905815; ro_val[387] = 0.905835; ro_val[388] = 0.905855; ro_val[389] = 0.905875; 
ro_val[390] = 0.905895; ro_val[391] = 0.905915; ro_val[392] = 0.905935; ro_val[393] = 0.905955; ro_val[394] = 0.905975; ro_val[395] = 0.905995; ro_val[396] = 0.906015; ro_val[397] = 0.906035; ro_val[398] = 0.906055; ro_val[399] = 0.906075; 
ro_val[400] = 0.906095; ro_val[401] = 0.906115; ro_val[402] = 0.906135; ro_val[403] = 0.906155; ro_val[404] = 0.906175; ro_val[405] = 0.906195; ro_val[406] = 0.906215; ro_val[407] = 0.906235; ro_val[408] = 0.906255; ro_val[409] = 0.906275; 
ro_val[410] = 0.906295; ro_val[411] = 0.906315; ro_val[412] = 0.906335; ro_val[413] = 0.906355; ro_val[414] = 0.906375; ro_val[415] = 0.906395; ro_val[416] = 0.906415; ro_val[417] = 0.906435; ro_val[418] = 0.906455; ro_val[419] = 0.906475; 
ro_val[420] = 0.906495; ro_val[421] = 0.906515; ro_val[422] = 0.906535; ro_val[423] = 0.906555; ro_val[424] = 0.906575; ro_val[425] = 0.906595; ro_val[426] = 0.906615; ro_val[427] = 0.906635; ro_val[428] = 0.906655; ro_val[429] = 0.906675; 
ro_val[430] = 0.906695; ro_val[431] = 0.906715; ro_val[432] = 0.906735; ro_val[433] = 0.906755; ro_val[434] = 0.906775; ro_val[435] = 0.906795; ro_val[436] = 0.906815; ro_val[437] = 0.906835; ro_val[438] = 0.906855; ro_val[439] = 0.906875; 
ro_val[440] = 0.906895; ro_val[441] = 0.906915; ro_val[442] = 0.906935; ro_val[443] = 0.906955; ro_val[444] = 0.906974; ro_val[445] = 0.906994; ro_val[446] = 0.907014; ro_val[447] = 0.907034; ro_val[448] = 0.907054; ro_val[449] = 0.907074; 
ro_val[450] = 0.907094; ro_val[451] = 0.907114; ro_val[452] = 0.907134; ro_val[453] = 0.907154; ro_val[454] = 0.907174; ro_val[455] = 0.907194; ro_val[456] = 0.907214; ro_val[457] = 0.907234; ro_val[458] = 0.907254; ro_val[459] = 0.907274; 
ro_val[460] = 0.907294; ro_val[461] = 0.907314; ro_val[462] = 0.907334; ro_val[463] = 0.907354; ro_val[464] = 0.907374; ro_val[465] = 0.907394; ro_val[466] = 0.907414; ro_val[467] = 0.907434; ro_val[468] = 0.907454; ro_val[469] = 0.907474; 
ro_val[470] = 0.907494; ro_val[471] = 0.907514; ro_val[472] = 0.907534; ro_val[473] = 0.907554; ro_val[474] = 0.907574; ro_val[475] = 0.907594; ro_val[476] = 0.907614; ro_val[477] = 0.907634; ro_val[478] = 0.907654; ro_val[479] = 0.907674; 
ro_val[480] = 0.907694; ro_val[481] = 0.907714; ro_val[482] = 0.907734; ro_val[483] = 0.907754; ro_val[484] = 0.907774; ro_val[485] = 0.907794; ro_val[486] = 0.907814; ro_val[487] = 0.907834; ro_val[488] = 0.907854; ro_val[489] = 0.907874; 
ro_val[490] = 0.907894; ro_val[491] = 0.907914; ro_val[492] = 0.907934; ro_val[493] = 0.907954; ro_val[494] = 0.907974; ro_val[495] = 0.907994; ro_val[496] = 0.908014; ro_val[497] = 0.908034; ro_val[498] = 0.908054; ro_val[499] = 0.908074; 
ro_val[500] = 0.908094; ro_val[501] = 0.908114; ro_val[502] = 0.908134; ro_val[503] = 0.908154; ro_val[504] = 0.908174; ro_val[505] = 0.908194; ro_val[506] = 0.908214; ro_val[507] = 0.908233; ro_val[508] = 0.908253; ro_val[509] = 0.908273; 
ro_val[510] = 0.908293; ro_val[511] = 0.908313; ro_val[512] = 0.908333; ro_val[513] = 0.908353; ro_val[514] = 0.908373; ro_val[515] = 0.908393; ro_val[516] = 0.908413; ro_val[517] = 0.908433; ro_val[518] = 0.908453; ro_val[519] = 0.908473; 
ro_val[520] = 0.908493; ro_val[521] = 0.908513; ro_val[522] = 0.908533; ro_val[523] = 0.908553; ro_val[524] = 0.908573; ro_val[525] = 0.908593; ro_val[526] = 0.908613; ro_val[527] = 0.908633; ro_val[528] = 0.908653; ro_val[529] = 0.908673; 
ro_val[530] = 0.908693; ro_val[531] = 0.908713; ro_val[532] = 0.908733; ro_val[533] = 0.908753; ro_val[534] = 0.908773; ro_val[535] = 0.908793; ro_val[536] = 0.908813; ro_val[537] = 0.908833; ro_val[538] = 0.908853; ro_val[539] = 0.908873; 
ro_val[540] = 0.908893; ro_val[541] = 0.908913; ro_val[542] = 0.908933; ro_val[543] = 0.908953; ro_val[544] = 0.908973; ro_val[545] = 0.908993; ro_val[546] = 0.909013; ro_val[547] = 0.909033; ro_val[548] = 0.909053; ro_val[549] = 0.909073; 
ro_val[550] = 0.909093; ro_val[551] = 0.909113; ro_val[552] = 0.909133; ro_val[553] = 0.909153; ro_val[554] = 0.909173; ro_val[555] = 0.909193; ro_val[556] = 0.909213; ro_val[557] = 0.909233; ro_val[558] = 0.909253; ro_val[559] = 0.909273; 
ro_val[560] = 0.909293; ro_val[561] = 0.909313; ro_val[562] = 0.909333; ro_val[563] = 0.909353; ro_val[564] = 0.909373; ro_val[565] = 0.909393; ro_val[566] = 0.909413; ro_val[567] = 0.909433; ro_val[568] = 0.909453; ro_val[569] = 0.909472; 
ro_val[570] = 0.909492; ro_val[571] = 0.909512; ro_val[572] = 0.909532; ro_val[573] = 0.909552; ro_val[574] = 0.909572; ro_val[575] = 0.909592; ro_val[576] = 0.909612; ro_val[577] = 0.909632; ro_val[578] = 0.909652; ro_val[579] = 0.909672; 
ro_val[580] = 0.909692; ro_val[581] = 0.909712; ro_val[582] = 0.909732; ro_val[583] = 0.909752; ro_val[584] = 0.909772; ro_val[585] = 0.909792; ro_val[586] = 0.909812; ro_val[587] = 0.909832; ro_val[588] = 0.909852; ro_val[589] = 0.909872; 
ro_val[590] = 0.909892; ro_val[591] = 0.909912; ro_val[592] = 0.909932; ro_val[593] = 0.909952; ro_val[594] = 0.909972; ro_val[595] = 0.909992; ro_val[596] = 0.910012; ro_val[597] = 0.910032; ro_val[598] = 0.910052; ro_val[599] = 0.910072; 
ro_val[600] = 0.910092; ro_val[601] = 0.910112; ro_val[602] = 0.910132; ro_val[603] = 0.910152; ro_val[604] = 0.910172; ro_val[605] = 0.910192; ro_val[606] = 0.910212; ro_val[607] = 0.910232; ro_val[608] = 0.910252; ro_val[609] = 0.910272; 
ro_val[610] = 0.910292; ro_val[611] = 0.910312; ro_val[612] = 0.910332; ro_val[613] = 0.910352; ro_val[614] = 0.910372; ro_val[615] = 0.910392; ro_val[616] = 0.910412; ro_val[617] = 0.910432; ro_val[618] = 0.910452; ro_val[619] = 0.910472; 
ro_val[620] = 0.910492; ro_val[621] = 0.910512; ro_val[622] = 0.910532; ro_val[623] = 0.910552; ro_val[624] = 0.910572; ro_val[625] = 0.910592; ro_val[626] = 0.910612; ro_val[627] = 0.910632; ro_val[628] = 0.910652; ro_val[629] = 0.910672; 
ro_val[630] = 0.910692; ro_val[631] = 0.910712; ro_val[632] = 0.910731; ro_val[633] = 0.910751; ro_val[634] = 0.910771; ro_val[635] = 0.910791; ro_val[636] = 0.910811; ro_val[637] = 0.910831; ro_val[638] = 0.910851; ro_val[639] = 0.910871; 
ro_val[640] = 0.910891; ro_val[641] = 0.910911; ro_val[642] = 0.910931; ro_val[643] = 0.910951; ro_val[644] = 0.910971; ro_val[645] = 0.910991; ro_val[646] = 0.911011; ro_val[647] = 0.911031; ro_val[648] = 0.911051; ro_val[649] = 0.911071; 
ro_val[650] = 0.911091; ro_val[651] = 0.911111; ro_val[652] = 0.911131; ro_val[653] = 0.911151; ro_val[654] = 0.911171; ro_val[655] = 0.911191; ro_val[656] = 0.911211; ro_val[657] = 0.911231; ro_val[658] = 0.911251; ro_val[659] = 0.911271; 
ro_val[660] = 0.911291; ro_val[661] = 0.911311; ro_val[662] = 0.911331; ro_val[663] = 0.911351; ro_val[664] = 0.911371; ro_val[665] = 0.911391; ro_val[666] = 0.911411; ro_val[667] = 0.911431; ro_val[668] = 0.911451; ro_val[669] = 0.911471; 
ro_val[670] = 0.911491; ro_val[671] = 0.911511; ro_val[672] = 0.911531; ro_val[673] = 0.911551; ro_val[674] = 0.911571; ro_val[675] = 0.911591; ro_val[676] = 0.911611; ro_val[677] = 0.911631; ro_val[678] = 0.911651; ro_val[679] = 0.911671; 
ro_val[680] = 0.911691; ro_val[681] = 0.911711; ro_val[682] = 0.911731; ro_val[683] = 0.911751; ro_val[684] = 0.911771; ro_val[685] = 0.911791; ro_val[686] = 0.911811; ro_val[687] = 0.911831; ro_val[688] = 0.911851; ro_val[689] = 0.911871; 
ro_val[690] = 0.911891; ro_val[691] = 0.911911; ro_val[692] = 0.911931; ro_val[693] = 0.911951; ro_val[694] = 0.911970; ro_val[695] = 0.911990; ro_val[696] = 0.912010; ro_val[697] = 0.912030; ro_val[698] = 0.912050; ro_val[699] = 0.912070; 
ro_val[700] = 0.912090; ro_val[701] = 0.912110; ro_val[702] = 0.912130; ro_val[703] = 0.912150; ro_val[704] = 0.912170; ro_val[705] = 0.912190; ro_val[706] = 0.912210; ro_val[707] = 0.912230; ro_val[708] = 0.912250; ro_val[709] = 0.912270; 
ro_val[710] = 0.912290; ro_val[711] = 0.912310; ro_val[712] = 0.912330; ro_val[713] = 0.912350; ro_val[714] = 0.912370; ro_val[715] = 0.912390; ro_val[716] = 0.912410; ro_val[717] = 0.912430; ro_val[718] = 0.912450; ro_val[719] = 0.912470; 
ro_val[720] = 0.912490; ro_val[721] = 0.912510; ro_val[722] = 0.912530; ro_val[723] = 0.912550; ro_val[724] = 0.912570; ro_val[725] = 0.912590; ro_val[726] = 0.912610; ro_val[727] = 0.912630; ro_val[728] = 0.912650; ro_val[729] = 0.912670; 
ro_val[730] = 0.912690; ro_val[731] = 0.912710; ro_val[732] = 0.912730; ro_val[733] = 0.912750; ro_val[734] = 0.912770; ro_val[735] = 0.912790; ro_val[736] = 0.912810; ro_val[737] = 0.912830; ro_val[738] = 0.912850; ro_val[739] = 0.912870; 
ro_val[740] = 0.912890; ro_val[741] = 0.912910; ro_val[742] = 0.912930; ro_val[743] = 0.912950; ro_val[744] = 0.912970; ro_val[745] = 0.912990; ro_val[746] = 0.913010; ro_val[747] = 0.913030; ro_val[748] = 0.913050; ro_val[749] = 0.913070; 
ro_val[750] = 0.913090; ro_val[751] = 0.913110; ro_val[752] = 0.913130; ro_val[753] = 0.913150; ro_val[754] = 0.913170; ro_val[755] = 0.913190; ro_val[756] = 0.913210; ro_val[757] = 0.913229; ro_val[758] = 0.913249; ro_val[759] = 0.913269; 
ro_val[760] = 0.913289; ro_val[761] = 0.913309; ro_val[762] = 0.913329; ro_val[763] = 0.913349; ro_val[764] = 0.913369; ro_val[765] = 0.913389; ro_val[766] = 0.913409; ro_val[767] = 0.913429; ro_val[768] = 0.913449; ro_val[769] = 0.913469; 
ro_val[770] = 0.913489; ro_val[771] = 0.913509; ro_val[772] = 0.913529; ro_val[773] = 0.913549; ro_val[774] = 0.913569; ro_val[775] = 0.913589; ro_val[776] = 0.913609; ro_val[777] = 0.913629; ro_val[778] = 0.913649; ro_val[779] = 0.913669; 
ro_val[780] = 0.913689; ro_val[781] = 0.913709; ro_val[782] = 0.913729; ro_val[783] = 0.913749; ro_val[784] = 0.913769; ro_val[785] = 0.913789; ro_val[786] = 0.913809; ro_val[787] = 0.913829; ro_val[788] = 0.913849; ro_val[789] = 0.913869; 
ro_val[790] = 0.913889; ro_val[791] = 0.913909; ro_val[792] = 0.913929; ro_val[793] = 0.913949; ro_val[794] = 0.913969; ro_val[795] = 0.913989; ro_val[796] = 0.914009; ro_val[797] = 0.914029; ro_val[798] = 0.914049; ro_val[799] = 0.914069; 
ro_val[800] = 0.914089; ro_val[801] = 0.914109; ro_val[802] = 0.914129; ro_val[803] = 0.914149; ro_val[804] = 0.914169; ro_val[805] = 0.914189; ro_val[806] = 0.914209; ro_val[807] = 0.914229; ro_val[808] = 0.914249; ro_val[809] = 0.914269; 
ro_val[810] = 0.914289; ro_val[811] = 0.914309; ro_val[812] = 0.914329; ro_val[813] = 0.914349; ro_val[814] = 0.914369; ro_val[815] = 0.914389; ro_val[816] = 0.914409; ro_val[817] = 0.914429; ro_val[818] = 0.914449; ro_val[819] = 0.914468; 
ro_val[820] = 0.914488; ro_val[821] = 0.914508; ro_val[822] = 0.914528; ro_val[823] = 0.914548; ro_val[824] = 0.914568; ro_val[825] = 0.914588; ro_val[826] = 0.914608; ro_val[827] = 0.914628; ro_val[828] = 0.914648; ro_val[829] = 0.914668; 
ro_val[830] = 0.914688; ro_val[831] = 0.914708; ro_val[832] = 0.914728; ro_val[833] = 0.914748; ro_val[834] = 0.914768; ro_val[835] = 0.914788; ro_val[836] = 0.914808; ro_val[837] = 0.914828; ro_val[838] = 0.914848; ro_val[839] = 0.914868; 
ro_val[840] = 0.914888; ro_val[841] = 0.914908; ro_val[842] = 0.914928; ro_val[843] = 0.914948; ro_val[844] = 0.914968; ro_val[845] = 0.914988; ro_val[846] = 0.915008; ro_val[847] = 0.915028; ro_val[848] = 0.915048; ro_val[849] = 0.915068; 
ro_val[850] = 0.915088; ro_val[851] = 0.915108; ro_val[852] = 0.915128; ro_val[853] = 0.915148; ro_val[854] = 0.915168; ro_val[855] = 0.915188; ro_val[856] = 0.915208; ro_val[857] = 0.915228; ro_val[858] = 0.915248; ro_val[859] = 0.915268; 
ro_val[860] = 0.915288; ro_val[861] = 0.915308; ro_val[862] = 0.915328; ro_val[863] = 0.915348; ro_val[864] = 0.915368; ro_val[865] = 0.915388; ro_val[866] = 0.915408; ro_val[867] = 0.915428; ro_val[868] = 0.915448; ro_val[869] = 0.915468; 
ro_val[870] = 0.915488; ro_val[871] = 0.915508; ro_val[872] = 0.915528; ro_val[873] = 0.915548; ro_val[874] = 0.915568; ro_val[875] = 0.915588; ro_val[876] = 0.915608; ro_val[877] = 0.915628; ro_val[878] = 0.915648; ro_val[879] = 0.915668; 
ro_val[880] = 0.915688; ro_val[881] = 0.915708; ro_val[882] = 0.915727; ro_val[883] = 0.915747; ro_val[884] = 0.915767; ro_val[885] = 0.915787; ro_val[886] = 0.915807; ro_val[887] = 0.915827; ro_val[888] = 0.915847; ro_val[889] = 0.915867; 
ro_val[890] = 0.915887; ro_val[891] = 0.915907; ro_val[892] = 0.915927; ro_val[893] = 0.915947; ro_val[894] = 0.915967; ro_val[895] = 0.915987; ro_val[896] = 0.916007; ro_val[897] = 0.916027; ro_val[898] = 0.916047; ro_val[899] = 0.916067; 
ro_val[900] = 0.916087; ro_val[901] = 0.916107; ro_val[902] = 0.916127; ro_val[903] = 0.916147; ro_val[904] = 0.916167; ro_val[905] = 0.916187; ro_val[906] = 0.916207; ro_val[907] = 0.916227; ro_val[908] = 0.916247; ro_val[909] = 0.916267; 
ro_val[910] = 0.916287; ro_val[911] = 0.916307; ro_val[912] = 0.916327; ro_val[913] = 0.916347; ro_val[914] = 0.916367; ro_val[915] = 0.916387; ro_val[916] = 0.916407; ro_val[917] = 0.916427; ro_val[918] = 0.916447; ro_val[919] = 0.916467; 
ro_val[920] = 0.916487; ro_val[921] = 0.916507; ro_val[922] = 0.916527; ro_val[923] = 0.916547; ro_val[924] = 0.916567; ro_val[925] = 0.916587; ro_val[926] = 0.916607; ro_val[927] = 0.916627; ro_val[928] = 0.916647; ro_val[929] = 0.916667; 
ro_val[930] = 0.916687; ro_val[931] = 0.916707; ro_val[932] = 0.916727; ro_val[933] = 0.916747; ro_val[934] = 0.916767; ro_val[935] = 0.916787; ro_val[936] = 0.916807; ro_val[937] = 0.916827; ro_val[938] = 0.916847; ro_val[939] = 0.916867; 
ro_val[940] = 0.916887; ro_val[941] = 0.916907; ro_val[942] = 0.916927; ro_val[943] = 0.916947; ro_val[944] = 0.916966; ro_val[945] = 0.916986; ro_val[946] = 0.917006; ro_val[947] = 0.917026; ro_val[948] = 0.917046; ro_val[949] = 0.917066; 
ro_val[950] = 0.917086; ro_val[951] = 0.917106; ro_val[952] = 0.917126; ro_val[953] = 0.917146; ro_val[954] = 0.917166; ro_val[955] = 0.917186; ro_val[956] = 0.917206; ro_val[957] = 0.917226; ro_val[958] = 0.917246; ro_val[959] = 0.917266; 
ro_val[960] = 0.917286; ro_val[961] = 0.917306; ro_val[962] = 0.917326; ro_val[963] = 0.917346; ro_val[964] = 0.917366; ro_val[965] = 0.917386; ro_val[966] = 0.917406; ro_val[967] = 0.917426; ro_val[968] = 0.917446; ro_val[969] = 0.917466; 
ro_val[970] = 0.917486; ro_val[971] = 0.917506; ro_val[972] = 0.917526; ro_val[973] = 0.917546; ro_val[974] = 0.917566; ro_val[975] = 0.917586; ro_val[976] = 0.917606; ro_val[977] = 0.917626; ro_val[978] = 0.917646; ro_val[979] = 0.917666; 
ro_val[980] = 0.917686; ro_val[981] = 0.917706; ro_val[982] = 0.917726; ro_val[983] = 0.917746; ro_val[984] = 0.917766; ro_val[985] = 0.917786; ro_val[986] = 0.917806; ro_val[987] = 0.917826; ro_val[988] = 0.917846; ro_val[989] = 0.917866; 
ro_val[990] = 0.917886; ro_val[991] = 0.917906; ro_val[992] = 0.917926; ro_val[993] = 0.917946; ro_val[994] = 0.917966; ro_val[995] = 0.917986; ro_val[996] = 0.918006; ro_val[997] = 0.918026; ro_val[998] = 0.918046; ro_val[999] = 0.918066; 
ro_val[1000] = 0.918086; ro_val[1001] = 0.918106; ro_val[1002] = 0.918126; ro_val[1003] = 0.918146; ro_val[1004] = 0.918166; ro_val[1005] = 0.918186; ro_val[1006] = 0.918206; ro_val[1007] = 0.918225; ro_val[1008] = 0.918245; ro_val[1009] = 0.918265; 
ro_val[1010] = 0.918285; ro_val[1011] = 0.918305; ro_val[1012] = 0.918325; ro_val[1013] = 0.918345; ro_val[1014] = 0.918365; ro_val[1015] = 0.918385; ro_val[1016] = 0.918405; ro_val[1017] = 0.918425; ro_val[1018] = 0.918445; ro_val[1019] = 0.918465; 
ro_val[1020] = 0.918485; ro_val[1021] = 0.918505; ro_val[1022] = 0.918525; ro_val[1023] = 0.918545; ro_val[FilePathLength] = 0.918565; ro_val[1025] = 0.918585; ro_val[1026] = 0.918605; ro_val[1027] = 0.918625; ro_val[1028] = 0.918645; ro_val[1029] = 0.918665; 
ro_val[1030] = 0.918685; ro_val[1031] = 0.918705; ro_val[1032] = 0.918725; ro_val[1033] = 0.918745; ro_val[1034] = 0.918765; ro_val[1035] = 0.918785; ro_val[1036] = 0.918805; ro_val[1037] = 0.918825; ro_val[1038] = 0.918845; ro_val[1039] = 0.918865; 
ro_val[1040] = 0.918885; ro_val[1041] = 0.918905; ro_val[1042] = 0.918925; ro_val[1043] = 0.918945; ro_val[1044] = 0.918965; ro_val[1045] = 0.918985; ro_val[1046] = 0.919005; ro_val[1047] = 0.919025; ro_val[1048] = 0.919045; ro_val[1049] = 0.919065; 
ro_val[1050] = 0.919085; ro_val[1051] = 0.919105; ro_val[1052] = 0.919125; ro_val[1053] = 0.919145; ro_val[1054] = 0.919165; ro_val[1055] = 0.919185; ro_val[1056] = 0.919205; ro_val[1057] = 0.919225; ro_val[1058] = 0.919245; ro_val[1059] = 0.919265; 
ro_val[1060] = 0.919285; ro_val[1061] = 0.919305; ro_val[1062] = 0.919325; ro_val[1063] = 0.919345; ro_val[1064] = 0.919365; ro_val[1065] = 0.919385; ro_val[1066] = 0.919405; ro_val[1067] = 0.919425; ro_val[1068] = 0.919445; ro_val[1069] = 0.919464; 
ro_val[1070] = 0.919484; ro_val[1071] = 0.919504; ro_val[1072] = 0.919524; ro_val[1073] = 0.919544; ro_val[1074] = 0.919564; ro_val[1075] = 0.919584; ro_val[1076] = 0.919604; ro_val[1077] = 0.919624; ro_val[1078] = 0.919644; ro_val[1079] = 0.919664; 
ro_val[1080] = 0.919684; ro_val[1081] = 0.919704; ro_val[1082] = 0.919724; ro_val[1083] = 0.919744; ro_val[1084] = 0.919764; ro_val[1085] = 0.919784; ro_val[1086] = 0.919804; ro_val[1087] = 0.919824; ro_val[1088] = 0.919844; ro_val[1089] = 0.919864; 
ro_val[1090] = 0.919884; ro_val[1091] = 0.919904; ro_val[1092] = 0.919924; ro_val[1093] = 0.919944; ro_val[1094] = 0.919964; ro_val[1095] = 0.919984; ro_val[1096] = 0.920004; ro_val[1097] = 0.920024; ro_val[1098] = 0.920044; ro_val[1099] = 0.920064; 
ro_val[1100] = 0.920084; ro_val[1101] = 0.920104; ro_val[1102] = 0.920124; ro_val[1103] = 0.920144; ro_val[1104] = 0.920164; ro_val[1105] = 0.920184; ro_val[1106] = 0.920204; ro_val[1107] = 0.920224; ro_val[1108] = 0.920244; ro_val[1109] = 0.920264; 
ro_val[1110] = 0.920284; ro_val[1111] = 0.920304; ro_val[1112] = 0.920324; ro_val[1113] = 0.920344; ro_val[1114] = 0.920364; ro_val[1115] = 0.920384; ro_val[1116] = 0.920404; ro_val[1117] = 0.920424; ro_val[1118] = 0.920444; ro_val[1119] = 0.920464; 
ro_val[1120] = 0.920484; ro_val[1121] = 0.920504; ro_val[1122] = 0.920524; ro_val[1123] = 0.920544; ro_val[1124] = 0.920564; ro_val[1125] = 0.920584; ro_val[1126] = 0.920604; ro_val[1127] = 0.920624; ro_val[1128] = 0.920644; ro_val[1129] = 0.920664; 
ro_val[1130] = 0.920684; ro_val[1131] = 0.920704; ro_val[1132] = 0.920723; ro_val[1133] = 0.920743; ro_val[1134] = 0.920763; ro_val[1135] = 0.920783; ro_val[1136] = 0.920803; ro_val[1137] = 0.920823; ro_val[1138] = 0.920843; ro_val[1139] = 0.920863; 
ro_val[1140] = 0.920883; ro_val[1141] = 0.920903; ro_val[1142] = 0.920923; ro_val[1143] = 0.920943; ro_val[1144] = 0.920963; ro_val[1145] = 0.920983; ro_val[1146] = 0.921003; ro_val[1147] = 0.921023; ro_val[1148] = 0.921043; ro_val[1149] = 0.921063; 
ro_val[1150] = 0.921083; ro_val[1151] = 0.921103; ro_val[1152] = 0.921123; ro_val[1153] = 0.921143; ro_val[1154] = 0.921163; ro_val[1155] = 0.921183; ro_val[1156] = 0.921203; ro_val[1157] = 0.921223; ro_val[1158] = 0.921243; ro_val[1159] = 0.921263; 
ro_val[1160] = 0.921283; ro_val[1161] = 0.921303; ro_val[1162] = 0.921323; ro_val[1163] = 0.921343; ro_val[1164] = 0.921363; ro_val[1165] = 0.921383; ro_val[1166] = 0.921403; ro_val[1167] = 0.921423; ro_val[1168] = 0.921443; ro_val[1169] = 0.921463; 
ro_val[1170] = 0.921483; ro_val[1171] = 0.921503; ro_val[1172] = 0.921523; ro_val[1173] = 0.921543; ro_val[1174] = 0.921563; ro_val[1175] = 0.921583; ro_val[1176] = 0.921603; ro_val[1177] = 0.921623; ro_val[1178] = 0.921643; ro_val[1179] = 0.921663; 
ro_val[1180] = 0.921683; ro_val[1181] = 0.921703; ro_val[1182] = 0.921723; ro_val[1183] = 0.921743; ro_val[1184] = 0.921763; ro_val[1185] = 0.921783; ro_val[1186] = 0.921803; ro_val[1187] = 0.921823; ro_val[1188] = 0.921843; ro_val[1189] = 0.921863; 
ro_val[1190] = 0.921883; ro_val[1191] = 0.921903; ro_val[1192] = 0.921923; ro_val[1193] = 0.921943; ro_val[1194] = 0.921962; ro_val[1195] = 0.921982; ro_val[1196] = 0.922002; ro_val[1197] = 0.922022; ro_val[1198] = 0.922042; ro_val[1199] = 0.922062; 
ro_val[1200] = 0.922082; ro_val[1201] = 0.922102; ro_val[1202] = 0.922122; ro_val[1203] = 0.922142; ro_val[1204] = 0.922162; ro_val[1205] = 0.922182; ro_val[1206] = 0.922202; ro_val[1207] = 0.922222; ro_val[1208] = 0.922242; ro_val[1209] = 0.922262; 
ro_val[1210] = 0.922282; ro_val[1211] = 0.922302; ro_val[1212] = 0.922322; ro_val[1213] = 0.922342; ro_val[1214] = 0.922362; ro_val[1215] = 0.922382; ro_val[1216] = 0.922402; ro_val[1217] = 0.922422; ro_val[1218] = 0.922442; ro_val[1219] = 0.922462; 
ro_val[1220] = 0.922482; ro_val[1221] = 0.922502; ro_val[1222] = 0.922522; ro_val[1223] = 0.922542; ro_val[1224] = 0.922562; ro_val[1225] = 0.922582; ro_val[1226] = 0.922602; ro_val[1227] = 0.922622; ro_val[1228] = 0.922642; ro_val[1229] = 0.922662; 
ro_val[1230] = 0.922682; ro_val[1231] = 0.922702; ro_val[1232] = 0.922722; ro_val[1233] = 0.922742; ro_val[1234] = 0.922762; ro_val[1235] = 0.922782; ro_val[1236] = 0.922802; ro_val[1237] = 0.922822; ro_val[1238] = 0.922842; ro_val[1239] = 0.922862; 
ro_val[1240] = 0.922882; ro_val[1241] = 0.922902; ro_val[1242] = 0.922922; ro_val[1243] = 0.922942; ro_val[1244] = 0.922962; ro_val[1245] = 0.922982; ro_val[1246] = 0.923002; ro_val[1247] = 0.923022; ro_val[1248] = 0.923042; ro_val[1249] = 0.923062; 
ro_val[1250] = 0.923082; ro_val[1251] = 0.923102; ro_val[1252] = 0.923122; ro_val[1253] = 0.923142; ro_val[1254] = 0.923162; ro_val[1255] = 0.923182; ro_val[1256] = 0.923202; ro_val[1257] = 0.923221; ro_val[1258] = 0.923241; ro_val[1259] = 0.923261; 
ro_val[1260] = 0.923281; ro_val[1261] = 0.923301; ro_val[1262] = 0.923321; ro_val[1263] = 0.923341; ro_val[1264] = 0.923361; ro_val[1265] = 0.923381; ro_val[1266] = 0.923401; ro_val[1267] = 0.923421; ro_val[1268] = 0.923441; ro_val[1269] = 0.923461; 
ro_val[1270] = 0.923481; ro_val[1271] = 0.923501; ro_val[1272] = 0.923521; ro_val[1273] = 0.923541; ro_val[1274] = 0.923561; ro_val[1275] = 0.923581; ro_val[1276] = 0.923601; ro_val[1277] = 0.923621; ro_val[1278] = 0.923641; ro_val[1279] = 0.923661; 
ro_val[1280] = 0.923681; ro_val[1281] = 0.923701; ro_val[1282] = 0.923721; ro_val[1283] = 0.923741; ro_val[1284] = 0.923761; ro_val[1285] = 0.923781; ro_val[1286] = 0.923801; ro_val[1287] = 0.923821; ro_val[1288] = 0.923841; ro_val[1289] = 0.923861; 
ro_val[1290] = 0.923881; ro_val[1291] = 0.923901; ro_val[1292] = 0.923921; ro_val[1293] = 0.923941; ro_val[1294] = 0.923961; ro_val[1295] = 0.923981; ro_val[1296] = 0.924001; ro_val[1297] = 0.924021; ro_val[1298] = 0.924041; ro_val[1299] = 0.924061; 
ro_val[1300] = 0.924081; ro_val[1301] = 0.924101; ro_val[1302] = 0.924121; ro_val[1303] = 0.924141; ro_val[1304] = 0.924161; ro_val[1305] = 0.924181; ro_val[1306] = 0.924201; ro_val[1307] = 0.924221; ro_val[1308] = 0.924241; ro_val[1309] = 0.924261; 
ro_val[1310] = 0.924281; ro_val[1311] = 0.924301; ro_val[1312] = 0.924321; ro_val[1313] = 0.924341; ro_val[1314] = 0.924361; ro_val[1315] = 0.924381; ro_val[1316] = 0.924401; ro_val[1317] = 0.924421; ro_val[1318] = 0.924441; ro_val[1319] = 0.924460; 
ro_val[1320] = 0.924480; ro_val[1321] = 0.924500; ro_val[1322] = 0.924520; ro_val[1323] = 0.924540; ro_val[1324] = 0.924560; ro_val[1325] = 0.924580; ro_val[1326] = 0.924600; ro_val[1327] = 0.924620; ro_val[1328] = 0.924640; ro_val[1329] = 0.924660; 
ro_val[1330] = 0.924680; ro_val[1331] = 0.924700; ro_val[1332] = 0.924720; ro_val[1333] = 0.924740; ro_val[1334] = 0.924760; ro_val[1335] = 0.924780; ro_val[1336] = 0.924800; ro_val[1337] = 0.924820; ro_val[1338] = 0.924840; ro_val[1339] = 0.924860; 
ro_val[1340] = 0.924880; ro_val[1341] = 0.924900; ro_val[1342] = 0.924920; ro_val[1343] = 0.924940; ro_val[1344] = 0.924960; ro_val[1345] = 0.924980; ro_val[1346] = 0.925000; ro_val[1347] = 0.925020; ro_val[1348] = 0.925040; ro_val[1349] = 0.925060; 
ro_val[1350] = 0.925080; ro_val[1351] = 0.925100; ro_val[1352] = 0.925120; ro_val[1353] = 0.925140; ro_val[1354] = 0.925160; ro_val[1355] = 0.925180; ro_val[1356] = 0.925200; ro_val[1357] = 0.925220; ro_val[1358] = 0.925240; ro_val[1359] = 0.925260; 
ro_val[1360] = 0.925280; ro_val[1361] = 0.925300; ro_val[1362] = 0.925320; ro_val[1363] = 0.925340; ro_val[1364] = 0.925360; ro_val[1365] = 0.925380; ro_val[1366] = 0.925400; ro_val[1367] = 0.925420; ro_val[1368] = 0.925440; ro_val[1369] = 0.925460; 
ro_val[1370] = 0.925480; ro_val[1371] = 0.925500; ro_val[1372] = 0.925520; ro_val[1373] = 0.925540; ro_val[1374] = 0.925560; ro_val[1375] = 0.925580; ro_val[1376] = 0.925600; ro_val[1377] = 0.925620; ro_val[1378] = 0.925640; ro_val[1379] = 0.925660; 
ro_val[1380] = 0.925680; ro_val[1381] = 0.925699; ro_val[1382] = 0.925719; ro_val[1383] = 0.925739; ro_val[1384] = 0.925759; ro_val[1385] = 0.925779; ro_val[1386] = 0.925799; ro_val[1387] = 0.925819; ro_val[1388] = 0.925839; ro_val[1389] = 0.925859; 
ro_val[1390] = 0.925879; ro_val[1391] = 0.925899; ro_val[1392] = 0.925919; ro_val[1393] = 0.925939; ro_val[1394] = 0.925959; ro_val[1395] = 0.925979; ro_val[1396] = 0.925999; ro_val[1397] = 0.926019; ro_val[1398] = 0.926039; ro_val[1399] = 0.926059; 
ro_val[1400] = 0.926079; ro_val[1401] = 0.926099; ro_val[1402] = 0.926119; ro_val[1403] = 0.926139; ro_val[1404] = 0.926159; ro_val[1405] = 0.926179; ro_val[1406] = 0.926199; ro_val[1407] = 0.926219; ro_val[1408] = 0.926239; ro_val[1409] = 0.926259; 
ro_val[1410] = 0.926279; ro_val[1411] = 0.926299; ro_val[1412] = 0.926319; ro_val[1413] = 0.926339; ro_val[1414] = 0.926359; ro_val[1415] = 0.926379; ro_val[1416] = 0.926399; ro_val[1417] = 0.926419; ro_val[1418] = 0.926439; ro_val[1419] = 0.926459; 
ro_val[1420] = 0.926479; ro_val[1421] = 0.926499; ro_val[1422] = 0.926519; ro_val[1423] = 0.926539; ro_val[1424] = 0.926559; ro_val[1425] = 0.926579; ro_val[1426] = 0.926599; ro_val[1427] = 0.926619; ro_val[1428] = 0.926639; ro_val[1429] = 0.926659; 
ro_val[1430] = 0.926679; ro_val[1431] = 0.926699; ro_val[1432] = 0.926719; ro_val[1433] = 0.926739; ro_val[1434] = 0.926759; ro_val[1435] = 0.926779; ro_val[1436] = 0.926799; ro_val[1437] = 0.926819; ro_val[1438] = 0.926839; ro_val[1439] = 0.926859; 
ro_val[1440] = 0.926879; ro_val[1441] = 0.926899; ro_val[1442] = 0.926919; ro_val[1443] = 0.926939; ro_val[1444] = 0.926958; ro_val[1445] = 0.926978; ro_val[1446] = 0.926998; ro_val[1447] = 0.927018; ro_val[1448] = 0.927038; ro_val[1449] = 0.927058; 
ro_val[1450] = 0.927078; ro_val[1451] = 0.927098; ro_val[1452] = 0.927118; ro_val[1453] = 0.927138; ro_val[1454] = 0.927158; ro_val[1455] = 0.927178; ro_val[1456] = 0.927198; ro_val[1457] = 0.927218; ro_val[1458] = 0.927238; ro_val[1459] = 0.927258; 
ro_val[1460] = 0.927278; ro_val[1461] = 0.927298; ro_val[1462] = 0.927318; ro_val[1463] = 0.927338; ro_val[1464] = 0.927358; ro_val[1465] = 0.927378; ro_val[1466] = 0.927398; ro_val[1467] = 0.927418; ro_val[1468] = 0.927438; ro_val[1469] = 0.927458; 
ro_val[1470] = 0.927478; ro_val[1471] = 0.927498; ro_val[1472] = 0.927518; ro_val[1473] = 0.927538; ro_val[1474] = 0.927558; ro_val[1475] = 0.927578; ro_val[1476] = 0.927598; ro_val[1477] = 0.927618; ro_val[1478] = 0.927638; ro_val[1479] = 0.927658; 
ro_val[1480] = 0.927678; ro_val[1481] = 0.927698; ro_val[1482] = 0.927718; ro_val[1483] = 0.927738; ro_val[1484] = 0.927758; ro_val[1485] = 0.927778; ro_val[1486] = 0.927798; ro_val[1487] = 0.927818; ro_val[1488] = 0.927838; ro_val[1489] = 0.927858; 
ro_val[1490] = 0.927878; ro_val[1491] = 0.927898; ro_val[1492] = 0.927918; ro_val[1493] = 0.927938; ro_val[1494] = 0.927958; ro_val[1495] = 0.927978; ro_val[1496] = 0.927998; ro_val[1497] = 0.928018; ro_val[1498] = 0.928038; ro_val[1499] = 0.928058; 
ro_val[1500] = 0.928078; ro_val[1501] = 0.928098; ro_val[1502] = 0.928118; ro_val[1503] = 0.928138; ro_val[1504] = 0.928158; ro_val[1505] = 0.928178; ro_val[1506] = 0.928197; ro_val[1507] = 0.928217; ro_val[1508] = 0.928237; ro_val[1509] = 0.928257; 
ro_val[1510] = 0.928277; ro_val[1511] = 0.928297; ro_val[1512] = 0.928317; ro_val[1513] = 0.928337; ro_val[1514] = 0.928357; ro_val[1515] = 0.928377; ro_val[1516] = 0.928397; ro_val[1517] = 0.928417; ro_val[1518] = 0.928437; ro_val[1519] = 0.928457; 
ro_val[1520] = 0.928477; ro_val[1521] = 0.928497; ro_val[1522] = 0.928517; ro_val[1523] = 0.928537; ro_val[1524] = 0.928557; ro_val[1525] = 0.928577; ro_val[1526] = 0.928597; ro_val[1527] = 0.928617; ro_val[1528] = 0.928637; ro_val[1529] = 0.928657; 
ro_val[1530] = 0.928677; ro_val[1531] = 0.928697; ro_val[1532] = 0.928717; ro_val[1533] = 0.928737; ro_val[1534] = 0.928757; ro_val[1535] = 0.928777; ro_val[1536] = 0.928797; ro_val[1537] = 0.928817; ro_val[1538] = 0.928837; ro_val[1539] = 0.928857; 
ro_val[1540] = 0.928877; ro_val[1541] = 0.928897; ro_val[1542] = 0.928917; ro_val[1543] = 0.928937; ro_val[1544] = 0.928957; ro_val[1545] = 0.928977; ro_val[1546] = 0.928997; ro_val[1547] = 0.929017; ro_val[1548] = 0.929037; ro_val[1549] = 0.929057; 
ro_val[1550] = 0.929077; ro_val[1551] = 0.929097; ro_val[1552] = 0.929117; ro_val[1553] = 0.929137; ro_val[1554] = 0.929157; ro_val[1555] = 0.929177; ro_val[1556] = 0.929197; ro_val[1557] = 0.929217; ro_val[1558] = 0.929237; ro_val[1559] = 0.929257; 
ro_val[1560] = 0.929277; ro_val[1561] = 0.929297; ro_val[1562] = 0.929317; ro_val[1563] = 0.929337; ro_val[1564] = 0.929357; ro_val[1565] = 0.929377; ro_val[1566] = 0.929397; ro_val[1567] = 0.929417; ro_val[1568] = 0.929437; ro_val[1569] = 0.929456; 
ro_val[1570] = 0.929476; ro_val[1571] = 0.929496; ro_val[1572] = 0.929516; ro_val[1573] = 0.929536; ro_val[1574] = 0.929556; ro_val[1575] = 0.929576; ro_val[1576] = 0.929596; ro_val[1577] = 0.929616; ro_val[1578] = 0.929636; ro_val[1579] = 0.929656; 
ro_val[1580] = 0.929676; ro_val[1581] = 0.929696; ro_val[1582] = 0.929716; ro_val[1583] = 0.929736; ro_val[1584] = 0.929756; ro_val[1585] = 0.929776; ro_val[1586] = 0.929796; ro_val[1587] = 0.929816; ro_val[1588] = 0.929836; ro_val[1589] = 0.929856; 
ro_val[1590] = 0.929876; ro_val[1591] = 0.929896; ro_val[1592] = 0.929916; ro_val[1593] = 0.929936; ro_val[1594] = 0.929956; ro_val[1595] = 0.929976; ro_val[1596] = 0.929996; ro_val[1597] = 0.930016; ro_val[1598] = 0.930036; ro_val[1599] = 0.930056; 
ro_val[1600] = 0.930076; ro_val[1601] = 0.930096; ro_val[1602] = 0.930116; ro_val[1603] = 0.930136; ro_val[1604] = 0.930156; ro_val[1605] = 0.930176; ro_val[1606] = 0.930196; ro_val[1607] = 0.930216; ro_val[1608] = 0.930236; ro_val[1609] = 0.930256; 
ro_val[1610] = 0.930276; ro_val[1611] = 0.930296; ro_val[1612] = 0.930316; ro_val[1613] = 0.930336; ro_val[1614] = 0.930356; ro_val[1615] = 0.930376; ro_val[1616] = 0.930396; ro_val[1617] = 0.930416; ro_val[1618] = 0.930436; ro_val[1619] = 0.930456; 
ro_val[1620] = 0.930476; ro_val[1621] = 0.930496; ro_val[1622] = 0.930516; ro_val[1623] = 0.930536; ro_val[1624] = 0.930556; ro_val[1625] = 0.930576; ro_val[1626] = 0.930596; ro_val[1627] = 0.930616; ro_val[1628] = 0.930636; ro_val[1629] = 0.930656; 
ro_val[1630] = 0.930676; ro_val[1631] = 0.930695; ro_val[1632] = 0.930715; ro_val[1633] = 0.930735; ro_val[1634] = 0.930755; ro_val[1635] = 0.930775; ro_val[1636] = 0.930795; ro_val[1637] = 0.930815; ro_val[1638] = 0.930835; ro_val[1639] = 0.930855; 
ro_val[1640] = 0.930875; ro_val[1641] = 0.930895; ro_val[1642] = 0.930915; ro_val[1643] = 0.930935; ro_val[1644] = 0.930955; ro_val[1645] = 0.930975; ro_val[1646] = 0.930995; ro_val[1647] = 0.931015; ro_val[1648] = 0.931035; ro_val[1649] = 0.931055; 
ro_val[1650] = 0.931075; ro_val[1651] = 0.931095; ro_val[1652] = 0.931115; ro_val[1653] = 0.931135; ro_val[1654] = 0.931155; ro_val[1655] = 0.931175; ro_val[1656] = 0.931195; ro_val[1657] = 0.931215; ro_val[1658] = 0.931235; ro_val[1659] = 0.931255; 
ro_val[1660] = 0.931275; ro_val[1661] = 0.931295; ro_val[1662] = 0.931315; ro_val[1663] = 0.931335; ro_val[1664] = 0.931355; ro_val[1665] = 0.931375; ro_val[1666] = 0.931395; ro_val[1667] = 0.931415; ro_val[1668] = 0.931435; ro_val[1669] = 0.931455; 
ro_val[1670] = 0.931475; ro_val[1671] = 0.931495; ro_val[1672] = 0.931515; ro_val[1673] = 0.931535; ro_val[1674] = 0.931555; ro_val[1675] = 0.931575; ro_val[1676] = 0.931595; ro_val[1677] = 0.931615; ro_val[1678] = 0.931635; ro_val[1679] = 0.931655; 
ro_val[1680] = 0.931675; ro_val[1681] = 0.931695; ro_val[1682] = 0.931715; ro_val[1683] = 0.931735; ro_val[1684] = 0.931755; ro_val[1685] = 0.931775; ro_val[1686] = 0.931795; ro_val[1687] = 0.931815; ro_val[1688] = 0.931835; ro_val[1689] = 0.931855; 
ro_val[1690] = 0.931875; ro_val[1691] = 0.931895; ro_val[1692] = 0.931915; ro_val[1693] = 0.931935; ro_val[1694] = 0.931954; ro_val[1695] = 0.931974; ro_val[1696] = 0.931994; ro_val[1697] = 0.932014; ro_val[1698] = 0.932034; ro_val[1699] = 0.932054; 
ro_val[1700] = 0.932074; ro_val[1701] = 0.932094; ro_val[1702] = 0.932114; ro_val[1703] = 0.932134; ro_val[1704] = 0.932154; ro_val[1705] = 0.932174; ro_val[1706] = 0.932194; ro_val[1707] = 0.932214; ro_val[1708] = 0.932234; ro_val[1709] = 0.932254; 
ro_val[1710] = 0.932274; ro_val[1711] = 0.932294; ro_val[1712] = 0.932314; ro_val[1713] = 0.932334; ro_val[1714] = 0.932354; ro_val[1715] = 0.932374; ro_val[1716] = 0.932394; ro_val[1717] = 0.932414; ro_val[1718] = 0.932434; ro_val[1719] = 0.932454; 
ro_val[1720] = 0.932474; ro_val[1721] = 0.932494; ro_val[1722] = 0.932514; ro_val[1723] = 0.932534; ro_val[1724] = 0.932554; ro_val[1725] = 0.932574; ro_val[1726] = 0.932594; ro_val[1727] = 0.932614; ro_val[1728] = 0.932634; ro_val[1729] = 0.932654; 
ro_val[1730] = 0.932674; ro_val[1731] = 0.932694; ro_val[1732] = 0.932714; ro_val[1733] = 0.932734; ro_val[1734] = 0.932754; ro_val[1735] = 0.932774; ro_val[1736] = 0.932794; ro_val[1737] = 0.932814; ro_val[1738] = 0.932834; ro_val[1739] = 0.932854; 
ro_val[1740] = 0.932874; ro_val[1741] = 0.932894; ro_val[1742] = 0.932914; ro_val[1743] = 0.932934; ro_val[1744] = 0.932954; ro_val[1745] = 0.932974; ro_val[1746] = 0.932994; ro_val[1747] = 0.933014; ro_val[1748] = 0.933034; ro_val[1749] = 0.933054; 
ro_val[1750] = 0.933074; ro_val[1751] = 0.933094; ro_val[1752] = 0.933114; ro_val[1753] = 0.933134; ro_val[1754] = 0.933154; ro_val[1755] = 0.933174; ro_val[1756] = 0.933193; ro_val[1757] = 0.933213; ro_val[1758] = 0.933233; ro_val[1759] = 0.933253; 
ro_val[1760] = 0.933273; ro_val[1761] = 0.933293; ro_val[1762] = 0.933313; ro_val[1763] = 0.933333; ro_val[1764] = 0.933353; ro_val[1765] = 0.933373; ro_val[1766] = 0.933393; ro_val[1767] = 0.933413; ro_val[1768] = 0.933433; ro_val[1769] = 0.933453; 
ro_val[1770] = 0.933473; ro_val[1771] = 0.933493; ro_val[1772] = 0.933513; ro_val[1773] = 0.933533; ro_val[1774] = 0.933553; ro_val[1775] = 0.933573; ro_val[1776] = 0.933593; ro_val[1777] = 0.933613; ro_val[1778] = 0.933633; ro_val[1779] = 0.933653; 
ro_val[1780] = 0.933673; ro_val[1781] = 0.933693; ro_val[1782] = 0.933713; ro_val[1783] = 0.933733; ro_val[1784] = 0.933753; ro_val[1785] = 0.933773; ro_val[1786] = 0.933793; ro_val[1787] = 0.933813; ro_val[1788] = 0.933833; ro_val[1789] = 0.933853; 
ro_val[1790] = 0.933873; ro_val[1791] = 0.933893; ro_val[1792] = 0.933913; ro_val[1793] = 0.933933; ro_val[1794] = 0.933953; ro_val[1795] = 0.933973; ro_val[1796] = 0.933993; ro_val[1797] = 0.934013; ro_val[1798] = 0.934033; ro_val[1799] = 0.934053; 
ro_val[1800] = 0.934073; ro_val[1801] = 0.934093; ro_val[1802] = 0.934113; ro_val[1803] = 0.934133; ro_val[1804] = 0.934153; ro_val[1805] = 0.934173; ro_val[1806] = 0.934193; ro_val[1807] = 0.934213; ro_val[1808] = 0.934233; ro_val[1809] = 0.934253; 
ro_val[1810] = 0.934273; ro_val[1811] = 0.934293; ro_val[1812] = 0.934313; ro_val[1813] = 0.934333; ro_val[1814] = 0.934353; ro_val[1815] = 0.934373; ro_val[1816] = 0.934393; ro_val[1817] = 0.934413; ro_val[1818] = 0.934433; ro_val[1819] = 0.934452; 
ro_val[1820] = 0.934472; ro_val[1821] = 0.934492; ro_val[1822] = 0.934512; ro_val[1823] = 0.934532; ro_val[1824] = 0.934552; ro_val[1825] = 0.934572; ro_val[1826] = 0.934592; ro_val[1827] = 0.934612; ro_val[1828] = 0.934632; ro_val[1829] = 0.934652; 
ro_val[1830] = 0.934672; ro_val[1831] = 0.934692; ro_val[1832] = 0.934712; ro_val[1833] = 0.934732; ro_val[1834] = 0.934752; ro_val[1835] = 0.934772; ro_val[1836] = 0.934792; ro_val[1837] = 0.934812; ro_val[1838] = 0.934832; ro_val[1839] = 0.934852; 
ro_val[1840] = 0.934872; ro_val[1841] = 0.934892; ro_val[1842] = 0.934912; ro_val[1843] = 0.934932; ro_val[1844] = 0.934952; ro_val[1845] = 0.934972; ro_val[1846] = 0.934992; ro_val[1847] = 0.935012; ro_val[1848] = 0.935032; ro_val[1849] = 0.935052; 
ro_val[1850] = 0.935072; ro_val[1851] = 0.935092; ro_val[1852] = 0.935112; ro_val[1853] = 0.935132; ro_val[1854] = 0.935152; ro_val[1855] = 0.935172; ro_val[1856] = 0.935192; ro_val[1857] = 0.935212; ro_val[1858] = 0.935232; ro_val[1859] = 0.935252; 
ro_val[1860] = 0.935272; ro_val[1861] = 0.935292; ro_val[1862] = 0.935312; ro_val[1863] = 0.935332; ro_val[1864] = 0.935352; ro_val[1865] = 0.935372; ro_val[1866] = 0.935392; ro_val[1867] = 0.935412; ro_val[1868] = 0.935432; ro_val[1869] = 0.935452; 
ro_val[1870] = 0.935472; ro_val[1871] = 0.935492; ro_val[1872] = 0.935512; ro_val[1873] = 0.935532; ro_val[1874] = 0.935552; ro_val[1875] = 0.935572; ro_val[1876] = 0.935592; ro_val[1877] = 0.935612; ro_val[1878] = 0.935632; ro_val[1879] = 0.935652; 
ro_val[1880] = 0.935672; ro_val[1881] = 0.935691; ro_val[1882] = 0.935711; ro_val[1883] = 0.935731; ro_val[1884] = 0.935751; ro_val[1885] = 0.935771; ro_val[1886] = 0.935791; ro_val[1887] = 0.935811; ro_val[1888] = 0.935831; ro_val[1889] = 0.935851; 
ro_val[1890] = 0.935871; ro_val[1891] = 0.935891; ro_val[1892] = 0.935911; ro_val[1893] = 0.935931; ro_val[1894] = 0.935951; ro_val[1895] = 0.935971; ro_val[1896] = 0.935991; ro_val[1897] = 0.936011; ro_val[1898] = 0.936031; ro_val[1899] = 0.936051; 
ro_val[1900] = 0.936071; ro_val[1901] = 0.936091; ro_val[1902] = 0.936111; ro_val[1903] = 0.936131; ro_val[1904] = 0.936151; ro_val[1905] = 0.936171; ro_val[1906] = 0.936191; ro_val[1907] = 0.936211; ro_val[1908] = 0.936231; ro_val[1909] = 0.936251; 
ro_val[1910] = 0.936271; ro_val[1911] = 0.936291; ro_val[1912] = 0.936311; ro_val[1913] = 0.936331; ro_val[1914] = 0.936351; ro_val[1915] = 0.936371; ro_val[1916] = 0.936391; ro_val[1917] = 0.936411; ro_val[1918] = 0.936431; ro_val[1919] = 0.936451; 
ro_val[1920] = 0.936471; ro_val[1921] = 0.936491; ro_val[1922] = 0.936511; ro_val[1923] = 0.936531; ro_val[1924] = 0.936551; ro_val[1925] = 0.936571; ro_val[1926] = 0.936591; ro_val[1927] = 0.936611; ro_val[1928] = 0.936631; ro_val[1929] = 0.936651; 
ro_val[1930] = 0.936671; ro_val[1931] = 0.936691; ro_val[1932] = 0.936711; ro_val[1933] = 0.936731; ro_val[1934] = 0.936751; ro_val[1935] = 0.936771; ro_val[1936] = 0.936791; ro_val[1937] = 0.936811; ro_val[1938] = 0.936831; ro_val[1939] = 0.936851; 
ro_val[1940] = 0.936871; ro_val[1941] = 0.936891; ro_val[1942] = 0.936911; ro_val[1943] = 0.936931; ro_val[1944] = 0.936950; ro_val[1945] = 0.936970; ro_val[1946] = 0.936990; ro_val[1947] = 0.937010; ro_val[1948] = 0.937030; ro_val[1949] = 0.937050; 
ro_val[1950] = 0.937070; ro_val[1951] = 0.937090; ro_val[1952] = 0.937110; ro_val[1953] = 0.937130; ro_val[1954] = 0.937150; ro_val[1955] = 0.937170; ro_val[1956] = 0.937190; ro_val[1957] = 0.937210; ro_val[1958] = 0.937230; ro_val[1959] = 0.937250; 
ro_val[1960] = 0.937270; ro_val[1961] = 0.937290; ro_val[1962] = 0.937310; ro_val[1963] = 0.937330; ro_val[1964] = 0.937350; ro_val[1965] = 0.937370; ro_val[1966] = 0.937390; ro_val[1967] = 0.937410; ro_val[1968] = 0.937430; ro_val[1969] = 0.937450; 
ro_val[1970] = 0.937470; ro_val[1971] = 0.937490; ro_val[1972] = 0.937510; ro_val[1973] = 0.937530; ro_val[1974] = 0.937550; ro_val[1975] = 0.937570; ro_val[1976] = 0.937590; ro_val[1977] = 0.937610; ro_val[1978] = 0.937630; ro_val[1979] = 0.937650; 
ro_val[1980] = 0.937670; ro_val[1981] = 0.937690; ro_val[1982] = 0.937710; ro_val[1983] = 0.937730; ro_val[1984] = 0.937750; ro_val[1985] = 0.937770; ro_val[1986] = 0.937790; ro_val[1987] = 0.937810; ro_val[1988] = 0.937830; ro_val[1989] = 0.937850; 
ro_val[1990] = 0.937870; ro_val[1991] = 0.937890; ro_val[1992] = 0.937910; ro_val[1993] = 0.937930; ro_val[1994] = 0.937950; ro_val[1995] = 0.937970; ro_val[1996] = 0.937990; ro_val[1997] = 0.938010; ro_val[1998] = 0.938030; ro_val[1999] = 0.938050; 
ro_val[2000] = 0.938070; ro_val[2001] = 0.938090; ro_val[2002] = 0.938110; ro_val[2003] = 0.938130; ro_val[2004] = 0.938150; ro_val[2005] = 0.938170; ro_val[2006] = 0.938189; ro_val[2007] = 0.938209; ro_val[2008] = 0.938229; ro_val[2009] = 0.938249; 
ro_val[2010] = 0.938269; ro_val[2011] = 0.938289; ro_val[2012] = 0.938309; ro_val[2013] = 0.938329; ro_val[2014] = 0.938349; ro_val[2015] = 0.938369; ro_val[2016] = 0.938389; ro_val[2017] = 0.938409; ro_val[2018] = 0.938429; ro_val[2019] = 0.938449; 
ro_val[2020] = 0.938469; ro_val[2021] = 0.938489; ro_val[2022] = 0.938509; ro_val[2023] = 0.938529; ro_val[2024] = 0.938549; ro_val[2025] = 0.938569; ro_val[2026] = 0.938589; ro_val[2027] = 0.938609; ro_val[2028] = 0.938629; ro_val[2029] = 0.938649; 
ro_val[2030] = 0.938669; ro_val[2031] = 0.938689; ro_val[2032] = 0.938709; ro_val[2033] = 0.938729; ro_val[2034] = 0.938749; ro_val[2035] = 0.938769; ro_val[2036] = 0.938789; ro_val[2037] = 0.938809; ro_val[2038] = 0.938829; ro_val[2039] = 0.938849; 
ro_val[2040] = 0.938869; ro_val[2041] = 0.938889; ro_val[2042] = 0.938909; ro_val[2043] = 0.938929; ro_val[2044] = 0.938949; ro_val[2045] = 0.938969; ro_val[2046] = 0.938989; ro_val[2047] = 0.939009; ro_val[2048] = 0.939029; ro_val[2049] = 0.939049; 
ro_val[2050] = 0.939069; ro_val[2051] = 0.939089; ro_val[2052] = 0.939109; ro_val[2053] = 0.939129; ro_val[2054] = 0.939149; ro_val[2055] = 0.939169; ro_val[2056] = 0.939189; ro_val[2057] = 0.939209; ro_val[2058] = 0.939229; ro_val[2059] = 0.939249; 
ro_val[2060] = 0.939269; ro_val[2061] = 0.939289; ro_val[2062] = 0.939309; ro_val[2063] = 0.939329; ro_val[2064] = 0.939349; ro_val[2065] = 0.939369; ro_val[2066] = 0.939389; ro_val[2067] = 0.939409; ro_val[2068] = 0.939429; ro_val[2069] = 0.939448; 
ro_val[2070] = 0.939468; ro_val[2071] = 0.939488; ro_val[2072] = 0.939508; ro_val[2073] = 0.939528; ro_val[2074] = 0.939548; ro_val[2075] = 0.939568; ro_val[2076] = 0.939588; ro_val[2077] = 0.939608; ro_val[2078] = 0.939628; ro_val[2079] = 0.939648; 
ro_val[2080] = 0.939668; ro_val[2081] = 0.939688; ro_val[2082] = 0.939708; ro_val[2083] = 0.939728; ro_val[2084] = 0.939748; ro_val[2085] = 0.939768; ro_val[2086] = 0.939788; ro_val[2087] = 0.939808; ro_val[2088] = 0.939828; ro_val[2089] = 0.939848; 
ro_val[2090] = 0.939868; ro_val[2091] = 0.939888; ro_val[2092] = 0.939908; ro_val[2093] = 0.939928; ro_val[2094] = 0.939948; ro_val[2095] = 0.939968; ro_val[2096] = 0.939988; ro_val[2097] = 0.940008; ro_val[2098] = 0.940028; ro_val[2099] = 0.940048; 
ro_val[2100] = 0.940068; ro_val[2101] = 0.940088; ro_val[2102] = 0.940108; ro_val[2103] = 0.940128; ro_val[2104] = 0.940148; ro_val[2105] = 0.940168; ro_val[2106] = 0.940188; ro_val[2107] = 0.940208; ro_val[2108] = 0.940228; ro_val[2109] = 0.940248; 
ro_val[2110] = 0.940268; ro_val[2111] = 0.940288; ro_val[2112] = 0.940308; ro_val[2113] = 0.940328; ro_val[2114] = 0.940348; ro_val[2115] = 0.940368; ro_val[2116] = 0.940388; ro_val[2117] = 0.940408; ro_val[2118] = 0.940428; ro_val[2119] = 0.940448; 
ro_val[2120] = 0.940468; ro_val[2121] = 0.940488; ro_val[2122] = 0.940508; ro_val[2123] = 0.940528; ro_val[2124] = 0.940548; ro_val[2125] = 0.940568; ro_val[2126] = 0.940588; ro_val[2127] = 0.940608; ro_val[2128] = 0.940628; ro_val[2129] = 0.940648; 
ro_val[2130] = 0.940668; ro_val[2131] = 0.940687; ro_val[2132] = 0.940707; ro_val[2133] = 0.940727; ro_val[2134] = 0.940747; ro_val[2135] = 0.940767; ro_val[2136] = 0.940787; ro_val[2137] = 0.940807; ro_val[2138] = 0.940827; ro_val[2139] = 0.940847; 
ro_val[2140] = 0.940867; ro_val[2141] = 0.940887; ro_val[2142] = 0.940907; ro_val[2143] = 0.940927; ro_val[2144] = 0.940947; ro_val[2145] = 0.940967; ro_val[2146] = 0.940987; ro_val[2147] = 0.941007; ro_val[2148] = 0.941027; ro_val[2149] = 0.941047; 
ro_val[2150] = 0.941067; ro_val[2151] = 0.941087; ro_val[2152] = 0.941107; ro_val[2153] = 0.941127; ro_val[2154] = 0.941147; ro_val[2155] = 0.941167; ro_val[2156] = 0.941187; ro_val[2157] = 0.941207; ro_val[2158] = 0.941227; ro_val[2159] = 0.941247; 
ro_val[2160] = 0.941267; ro_val[2161] = 0.941287; ro_val[2162] = 0.941307; ro_val[2163] = 0.941327; ro_val[2164] = 0.941347; ro_val[2165] = 0.941367; ro_val[2166] = 0.941387; ro_val[2167] = 0.941407; ro_val[2168] = 0.941427; ro_val[2169] = 0.941447; 
ro_val[2170] = 0.941467; ro_val[2171] = 0.941487; ro_val[2172] = 0.941507; ro_val[2173] = 0.941527; ro_val[2174] = 0.941547; ro_val[2175] = 0.941567; ro_val[2176] = 0.941587; ro_val[2177] = 0.941607; ro_val[2178] = 0.941627; ro_val[2179] = 0.941647; 
ro_val[2180] = 0.941667; ro_val[2181] = 0.941687; ro_val[2182] = 0.941707; ro_val[2183] = 0.941727; ro_val[2184] = 0.941747; ro_val[2185] = 0.941767; ro_val[2186] = 0.941787; ro_val[2187] = 0.941807; ro_val[2188] = 0.941827; ro_val[2189] = 0.941847; 
ro_val[2190] = 0.941867; ro_val[2191] = 0.941887; ro_val[2192] = 0.941907; ro_val[2193] = 0.941927; ro_val[2194] = 0.941946; ro_val[2195] = 0.941966; ro_val[2196] = 0.941986; ro_val[2197] = 0.942006; ro_val[2198] = 0.942026; ro_val[2199] = 0.942046; 
ro_val[2200] = 0.942066; ro_val[2201] = 0.942086; ro_val[2202] = 0.942106; ro_val[2203] = 0.942126; ro_val[2204] = 0.942146; ro_val[2205] = 0.942166; ro_val[2206] = 0.942186; ro_val[2207] = 0.942206; ro_val[2208] = 0.942226; ro_val[2209] = 0.942246; 
ro_val[2210] = 0.942266; ro_val[2211] = 0.942286; ro_val[2212] = 0.942306; ro_val[2213] = 0.942326; ro_val[2214] = 0.942346; ro_val[2215] = 0.942366; ro_val[2216] = 0.942386; ro_val[2217] = 0.942406; ro_val[2218] = 0.942426; ro_val[2219] = 0.942446; 
ro_val[2220] = 0.942466; ro_val[2221] = 0.942486; ro_val[2222] = 0.942506; ro_val[2223] = 0.942526; ro_val[2224] = 0.942546; ro_val[2225] = 0.942566; ro_val[2226] = 0.942586; ro_val[2227] = 0.942606; ro_val[2228] = 0.942626; ro_val[2229] = 0.942646; 
ro_val[2230] = 0.942666; ro_val[2231] = 0.942686; ro_val[2232] = 0.942706; ro_val[2233] = 0.942726; ro_val[2234] = 0.942746; ro_val[2235] = 0.942766; ro_val[2236] = 0.942786; ro_val[2237] = 0.942806; ro_val[2238] = 0.942826; ro_val[2239] = 0.942846; 
ro_val[2240] = 0.942866; ro_val[2241] = 0.942886; ro_val[2242] = 0.942906; ro_val[2243] = 0.942926; ro_val[2244] = 0.942946; ro_val[2245] = 0.942966; ro_val[2246] = 0.942986; ro_val[2247] = 0.943006; ro_val[2248] = 0.943026; ro_val[2249] = 0.943046; 
ro_val[2250] = 0.943066; ro_val[2251] = 0.943086; ro_val[2252] = 0.943106; ro_val[2253] = 0.943126; ro_val[2254] = 0.943146; ro_val[2255] = 0.943166; ro_val[2256] = 0.943185; ro_val[2257] = 0.943205; ro_val[2258] = 0.943225; ro_val[2259] = 0.943245; 
ro_val[2260] = 0.943265; ro_val[2261] = 0.943285; ro_val[2262] = 0.943305; ro_val[2263] = 0.943325; ro_val[2264] = 0.943345; ro_val[2265] = 0.943365; ro_val[2266] = 0.943385; ro_val[2267] = 0.943405; ro_val[2268] = 0.943425; ro_val[2269] = 0.943445; 
ro_val[2270] = 0.943465; ro_val[2271] = 0.943485; ro_val[2272] = 0.943505; ro_val[2273] = 0.943525; ro_val[2274] = 0.943545; ro_val[2275] = 0.943565; ro_val[2276] = 0.943585; ro_val[2277] = 0.943605; ro_val[2278] = 0.943625; ro_val[2279] = 0.943645; 
ro_val[2280] = 0.943665; ro_val[2281] = 0.943685; ro_val[2282] = 0.943705; ro_val[2283] = 0.943725; ro_val[2284] = 0.943745; ro_val[2285] = 0.943765; ro_val[2286] = 0.943785; ro_val[2287] = 0.943805; ro_val[2288] = 0.943825; ro_val[2289] = 0.943845; 
ro_val[2290] = 0.943865; ro_val[2291] = 0.943885; ro_val[2292] = 0.943905; ro_val[2293] = 0.943925; ro_val[2294] = 0.943945; ro_val[2295] = 0.943965; ro_val[2296] = 0.943985; ro_val[2297] = 0.944005; ro_val[2298] = 0.944025; ro_val[2299] = 0.944045; 
ro_val[2300] = 0.944065; ro_val[2301] = 0.944085; ro_val[2302] = 0.944105; ro_val[2303] = 0.944125; ro_val[2304] = 0.944145; ro_val[2305] = 0.944165; ro_val[2306] = 0.944185; ro_val[2307] = 0.944205; ro_val[2308] = 0.944225; ro_val[2309] = 0.944245; 
ro_val[2310] = 0.944265; ro_val[2311] = 0.944285; ro_val[2312] = 0.944305; ro_val[2313] = 0.944325; ro_val[2314] = 0.944345; ro_val[2315] = 0.944365; ro_val[2316] = 0.944385; ro_val[2317] = 0.944405; ro_val[2318] = 0.944425; ro_val[2319] = 0.944444; 
ro_val[2320] = 0.944464; ro_val[2321] = 0.944484; ro_val[2322] = 0.944504; ro_val[2323] = 0.944524; ro_val[2324] = 0.944544; ro_val[2325] = 0.944564; ro_val[2326] = 0.944584; ro_val[2327] = 0.944604; ro_val[2328] = 0.944624; ro_val[2329] = 0.944644; 
ro_val[2330] = 0.944664; ro_val[2331] = 0.944684; ro_val[2332] = 0.944704; ro_val[2333] = 0.944724; ro_val[2334] = 0.944744; ro_val[2335] = 0.944764; ro_val[2336] = 0.944784; ro_val[2337] = 0.944804; ro_val[2338] = 0.944824; ro_val[2339] = 0.944844; 
ro_val[2340] = 0.944864; ro_val[2341] = 0.944884; ro_val[2342] = 0.944904; ro_val[2343] = 0.944924; ro_val[2344] = 0.944944; ro_val[2345] = 0.944964; ro_val[2346] = 0.944984; ro_val[2347] = 0.945004; ro_val[2348] = 0.945024; ro_val[2349] = 0.945044; 
ro_val[2350] = 0.945064; ro_val[2351] = 0.945084; ro_val[2352] = 0.945104; ro_val[2353] = 0.945124; ro_val[2354] = 0.945144; ro_val[2355] = 0.945164; ro_val[2356] = 0.945184; ro_val[2357] = 0.945204; ro_val[2358] = 0.945224; ro_val[2359] = 0.945244; 
ro_val[2360] = 0.945264; ro_val[2361] = 0.945284; ro_val[2362] = 0.945304; ro_val[2363] = 0.945324; ro_val[2364] = 0.945344; ro_val[2365] = 0.945364; ro_val[2366] = 0.945384; ro_val[2367] = 0.945404; ro_val[2368] = 0.945424; ro_val[2369] = 0.945444; 
ro_val[2370] = 0.945464; ro_val[2371] = 0.945484; ro_val[2372] = 0.945504; ro_val[2373] = 0.945524; ro_val[2374] = 0.945544; ro_val[2375] = 0.945564; ro_val[2376] = 0.945584; ro_val[2377] = 0.945604; ro_val[2378] = 0.945624; ro_val[2379] = 0.945644; 
ro_val[2380] = 0.945664; ro_val[2381] = 0.945683; ro_val[2382] = 0.945703; ro_val[2383] = 0.945723; ro_val[2384] = 0.945743; ro_val[2385] = 0.945763; ro_val[2386] = 0.945783; ro_val[2387] = 0.945803; ro_val[2388] = 0.945823; ro_val[2389] = 0.945843; 
ro_val[2390] = 0.945863; ro_val[2391] = 0.945883; ro_val[2392] = 0.945903; ro_val[2393] = 0.945923; ro_val[2394] = 0.945943; ro_val[2395] = 0.945963; ro_val[2396] = 0.945983; ro_val[2397] = 0.946003; ro_val[2398] = 0.946023; ro_val[2399] = 0.946043; 
ro_val[2400] = 0.946063; ro_val[2401] = 0.946083; ro_val[2402] = 0.946103; ro_val[2403] = 0.946123; ro_val[2404] = 0.946143; ro_val[2405] = 0.946163; ro_val[2406] = 0.946183; ro_val[2407] = 0.946203; ro_val[2408] = 0.946223; ro_val[2409] = 0.946243; 
ro_val[2410] = 0.946263; ro_val[2411] = 0.946283; ro_val[2412] = 0.946303; ro_val[2413] = 0.946323; ro_val[2414] = 0.946343; ro_val[2415] = 0.946363; ro_val[2416] = 0.946383; ro_val[2417] = 0.946403; ro_val[2418] = 0.946423; ro_val[2419] = 0.946443; 
ro_val[2420] = 0.946463; ro_val[2421] = 0.946483; ro_val[2422] = 0.946503; ro_val[2423] = 0.946523; ro_val[2424] = 0.946543; ro_val[2425] = 0.946563; ro_val[2426] = 0.946583; ro_val[2427] = 0.946603; ro_val[2428] = 0.946623; ro_val[2429] = 0.946643; 
ro_val[2430] = 0.946663; ro_val[2431] = 0.946683; ro_val[2432] = 0.946703; ro_val[2433] = 0.946723; ro_val[2434] = 0.946743; ro_val[2435] = 0.946763; ro_val[2436] = 0.946783; ro_val[2437] = 0.946803; ro_val[2438] = 0.946823; ro_val[2439] = 0.946843; 
ro_val[2440] = 0.946863; ro_val[2441] = 0.946883; ro_val[2442] = 0.946903; ro_val[2443] = 0.946923; ro_val[2444] = 0.946942; ro_val[2445] = 0.946962; ro_val[2446] = 0.946982; ro_val[2447] = 0.947002; ro_val[2448] = 0.947022; ro_val[2449] = 0.947042; 
ro_val[2450] = 0.947062; ro_val[2451] = 0.947082; ro_val[2452] = 0.947102; ro_val[2453] = 0.947122; ro_val[2454] = 0.947142; ro_val[2455] = 0.947162; ro_val[2456] = 0.947182; ro_val[2457] = 0.947202; ro_val[2458] = 0.947222; ro_val[2459] = 0.947242; 
ro_val[2460] = 0.947262; ro_val[2461] = 0.947282; ro_val[2462] = 0.947302; ro_val[2463] = 0.947322; ro_val[2464] = 0.947342; ro_val[2465] = 0.947362; ro_val[2466] = 0.947382; ro_val[2467] = 0.947402; ro_val[2468] = 0.947422; ro_val[2469] = 0.947442; 
ro_val[2470] = 0.947462; ro_val[2471] = 0.947482; ro_val[2472] = 0.947502; ro_val[2473] = 0.947522; ro_val[2474] = 0.947542; ro_val[2475] = 0.947562; ro_val[2476] = 0.947582; ro_val[2477] = 0.947602; ro_val[2478] = 0.947622; ro_val[2479] = 0.947642; 
ro_val[2480] = 0.947662; ro_val[2481] = 0.947682; ro_val[2482] = 0.947702; ro_val[2483] = 0.947722; ro_val[2484] = 0.947742; ro_val[2485] = 0.947762; ro_val[2486] = 0.947782; ro_val[2487] = 0.947802; ro_val[2488] = 0.947822; ro_val[2489] = 0.947842; 
ro_val[2490] = 0.947862; ro_val[2491] = 0.947882; ro_val[2492] = 0.947902; ro_val[2493] = 0.947922; ro_val[2494] = 0.947942; ro_val[2495] = 0.947962; ro_val[2496] = 0.947982; ro_val[2497] = 0.948002; ro_val[2498] = 0.948022; ro_val[2499] = 0.948042; 
ro_val[2500] = 0.948062; ro_val[2501] = 0.948082; ro_val[2502] = 0.948102; ro_val[2503] = 0.948122; ro_val[2504] = 0.948142; ro_val[2505] = 0.948162; ro_val[2506] = 0.948181; ro_val[2507] = 0.948201; ro_val[2508] = 0.948221; ro_val[2509] = 0.948241; 
ro_val[2510] = 0.948261; ro_val[2511] = 0.948281; ro_val[2512] = 0.948301; ro_val[2513] = 0.948321; ro_val[2514] = 0.948341; ro_val[2515] = 0.948361; ro_val[2516] = 0.948381; ro_val[2517] = 0.948401; ro_val[2518] = 0.948421; ro_val[2519] = 0.948441; 
ro_val[2520] = 0.948461; ro_val[2521] = 0.948481; ro_val[2522] = 0.948501; ro_val[2523] = 0.948521; ro_val[2524] = 0.948541; ro_val[2525] = 0.948561; ro_val[2526] = 0.948581; ro_val[2527] = 0.948601; ro_val[2528] = 0.948621; ro_val[2529] = 0.948641; 
ro_val[2530] = 0.948661; ro_val[2531] = 0.948681; ro_val[2532] = 0.948701; ro_val[2533] = 0.948721; ro_val[2534] = 0.948741; ro_val[2535] = 0.948761; ro_val[2536] = 0.948781; ro_val[2537] = 0.948801; ro_val[2538] = 0.948821; ro_val[2539] = 0.948841; 
ro_val[2540] = 0.948861; ro_val[2541] = 0.948881; ro_val[2542] = 0.948901; ro_val[2543] = 0.948921; ro_val[2544] = 0.948941; ro_val[2545] = 0.948961; ro_val[2546] = 0.948981; ro_val[2547] = 0.949001; ro_val[2548] = 0.949021; ro_val[2549] = 0.949041; 
ro_val[2550] = 0.949061; ro_val[2551] = 0.949081; ro_val[2552] = 0.949101; ro_val[2553] = 0.949121; ro_val[2554] = 0.949141; ro_val[2555] = 0.949161; ro_val[2556] = 0.949181; ro_val[2557] = 0.949201; ro_val[2558] = 0.949221; ro_val[2559] = 0.949241; 
ro_val[2560] = 0.949261; ro_val[2561] = 0.949281; ro_val[2562] = 0.949301; ro_val[2563] = 0.949321; ro_val[2564] = 0.949341; ro_val[2565] = 0.949361; ro_val[2566] = 0.949381; ro_val[2567] = 0.949401; ro_val[2568] = 0.949421; ro_val[2569] = 0.949440; 
ro_val[2570] = 0.949460; ro_val[2571] = 0.949480; ro_val[2572] = 0.949500; ro_val[2573] = 0.949520; ro_val[2574] = 0.949540; ro_val[2575] = 0.949560; ro_val[2576] = 0.949580; ro_val[2577] = 0.949600; ro_val[2578] = 0.949620; ro_val[2579] = 0.949640; 
ro_val[2580] = 0.949660; ro_val[2581] = 0.949680; ro_val[2582] = 0.949700; ro_val[2583] = 0.949720; ro_val[2584] = 0.949740; ro_val[2585] = 0.949760; ro_val[2586] = 0.949780; ro_val[2587] = 0.949800; ro_val[2588] = 0.949820; ro_val[2589] = 0.949840; 
ro_val[2590] = 0.949860; ro_val[2591] = 0.949880; ro_val[2592] = 0.949900; ro_val[2593] = 0.949920; ro_val[2594] = 0.949940; ro_val[2595] = 0.949960; ro_val[2596] = 0.949980; ro_val[2597] = 0.950000; ro_val[2598] = 0.950020; ro_val[2599] = 0.950040; 
ro_val[2600] = 0.950060; ro_val[2601] = 0.950080; ro_val[2602] = 0.950100; ro_val[2603] = 0.950120; ro_val[2604] = 0.950140; ro_val[2605] = 0.950160; ro_val[2606] = 0.950180; ro_val[2607] = 0.950200; ro_val[2608] = 0.950220; ro_val[2609] = 0.950240; 
ro_val[2610] = 0.950260; ro_val[2611] = 0.950280; ro_val[2612] = 0.950300; ro_val[2613] = 0.950320; ro_val[2614] = 0.950340; ro_val[2615] = 0.950360; ro_val[2616] = 0.950380; ro_val[2617] = 0.950400; ro_val[2618] = 0.950420; ro_val[2619] = 0.950440; 
ro_val[2620] = 0.950460; ro_val[2621] = 0.950480; ro_val[2622] = 0.950500; ro_val[2623] = 0.950520; ro_val[2624] = 0.950540; ro_val[2625] = 0.950560; ro_val[2626] = 0.950580; ro_val[2627] = 0.950600; ro_val[2628] = 0.950620; ro_val[2629] = 0.950640; 
ro_val[2630] = 0.950660; ro_val[2631] = 0.950679; ro_val[2632] = 0.950699; ro_val[2633] = 0.950719; ro_val[2634] = 0.950739; ro_val[2635] = 0.950759; ro_val[2636] = 0.950779; ro_val[2637] = 0.950799; ro_val[2638] = 0.950819; ro_val[2639] = 0.950839; 
ro_val[2640] = 0.950859; ro_val[2641] = 0.950879; ro_val[2642] = 0.950899; ro_val[2643] = 0.950919; ro_val[2644] = 0.950939; ro_val[2645] = 0.950959; ro_val[2646] = 0.950979; ro_val[2647] = 0.950999; ro_val[2648] = 0.951019; ro_val[2649] = 0.951039; 
ro_val[2650] = 0.951059; ro_val[2651] = 0.951079; ro_val[2652] = 0.951099; ro_val[2653] = 0.951119; ro_val[2654] = 0.951139; ro_val[2655] = 0.951159; ro_val[2656] = 0.951179; ro_val[2657] = 0.951199; ro_val[2658] = 0.951219; ro_val[2659] = 0.951239; 
ro_val[2660] = 0.951259; ro_val[2661] = 0.951279; ro_val[2662] = 0.951299; ro_val[2663] = 0.951319; ro_val[2664] = 0.951339; ro_val[2665] = 0.951359; ro_val[2666] = 0.951379; ro_val[2667] = 0.951399; ro_val[2668] = 0.951419; ro_val[2669] = 0.951439; 
ro_val[2670] = 0.951459; ro_val[2671] = 0.951479; ro_val[2672] = 0.951499; ro_val[2673] = 0.951519; ro_val[2674] = 0.951539; ro_val[2675] = 0.951559; ro_val[2676] = 0.951579; ro_val[2677] = 0.951599; ro_val[2678] = 0.951619; ro_val[2679] = 0.951639; 
ro_val[2680] = 0.951659; ro_val[2681] = 0.951679; ro_val[2682] = 0.951699; ro_val[2683] = 0.951719; ro_val[2684] = 0.951739; ro_val[2685] = 0.951759; ro_val[2686] = 0.951779; ro_val[2687] = 0.951799; ro_val[2688] = 0.951819; ro_val[2689] = 0.951839; 
ro_val[2690] = 0.951859; ro_val[2691] = 0.951879; ro_val[2692] = 0.951899; ro_val[2693] = 0.951919; ro_val[2694] = 0.951938; ro_val[2695] = 0.951958; ro_val[2696] = 0.951978; ro_val[2697] = 0.951998; ro_val[2698] = 0.952018; ro_val[2699] = 0.952038; 
ro_val[2700] = 0.952058; ro_val[2701] = 0.952078; ro_val[2702] = 0.952098; ro_val[2703] = 0.952118; ro_val[2704] = 0.952138; ro_val[2705] = 0.952158; ro_val[2706] = 0.952178; ro_val[2707] = 0.952198; ro_val[2708] = 0.952218; ro_val[2709] = 0.952238; 
ro_val[2710] = 0.952258; ro_val[2711] = 0.952278; ro_val[2712] = 0.952298; ro_val[2713] = 0.952318; ro_val[2714] = 0.952338; ro_val[2715] = 0.952358; ro_val[2716] = 0.952378; ro_val[2717] = 0.952398; ro_val[2718] = 0.952418; ro_val[2719] = 0.952438; 
ro_val[2720] = 0.952458; ro_val[2721] = 0.952478; ro_val[2722] = 0.952498; ro_val[2723] = 0.952518; ro_val[2724] = 0.952538; ro_val[2725] = 0.952558; ro_val[2726] = 0.952578; ro_val[2727] = 0.952598; ro_val[2728] = 0.952618; ro_val[2729] = 0.952638; 
ro_val[2730] = 0.952658; ro_val[2731] = 0.952678; ro_val[2732] = 0.952698; ro_val[2733] = 0.952718; ro_val[2734] = 0.952738; ro_val[2735] = 0.952758; ro_val[2736] = 0.952778; ro_val[2737] = 0.952798; ro_val[2738] = 0.952818; ro_val[2739] = 0.952838; 
ro_val[2740] = 0.952858; ro_val[2741] = 0.952878; ro_val[2742] = 0.952898; ro_val[2743] = 0.952918; ro_val[2744] = 0.952938; ro_val[2745] = 0.952958; ro_val[2746] = 0.952978; ro_val[2747] = 0.952998; ro_val[2748] = 0.953018; ro_val[2749] = 0.953038; 
ro_val[2750] = 0.953058; ro_val[2751] = 0.953078; ro_val[2752] = 0.953098; ro_val[2753] = 0.953118; ro_val[2754] = 0.953138; ro_val[2755] = 0.953158; ro_val[2756] = 0.953177; ro_val[2757] = 0.953197; ro_val[2758] = 0.953217; ro_val[2759] = 0.953237; 
ro_val[2760] = 0.953257; ro_val[2761] = 0.953277; ro_val[2762] = 0.953297; ro_val[2763] = 0.953317; ro_val[2764] = 0.953337; ro_val[2765] = 0.953357; ro_val[2766] = 0.953377; ro_val[2767] = 0.953397; ro_val[2768] = 0.953417; ro_val[2769] = 0.953437; 
ro_val[2770] = 0.953457; ro_val[2771] = 0.953477; ro_val[2772] = 0.953497; ro_val[2773] = 0.953517; ro_val[2774] = 0.953537; ro_val[2775] = 0.953557; ro_val[2776] = 0.953577; ro_val[2777] = 0.953597; ro_val[2778] = 0.953617; ro_val[2779] = 0.953637; 
ro_val[2780] = 0.953657; ro_val[2781] = 0.953677; ro_val[2782] = 0.953697; ro_val[2783] = 0.953717; ro_val[2784] = 0.953737; ro_val[2785] = 0.953757; ro_val[2786] = 0.953777; ro_val[2787] = 0.953797; ro_val[2788] = 0.953817; ro_val[2789] = 0.953837; 
ro_val[2790] = 0.953857; ro_val[2791] = 0.953877; ro_val[2792] = 0.953897; ro_val[2793] = 0.953917; ro_val[2794] = 0.953937; ro_val[2795] = 0.953957; ro_val[2796] = 0.953977; ro_val[2797] = 0.953997; ro_val[2798] = 0.954017; ro_val[2799] = 0.954037; 
ro_val[2800] = 0.954057; ro_val[2801] = 0.954077; ro_val[2802] = 0.954097; ro_val[2803] = 0.954117; ro_val[2804] = 0.954137; ro_val[2805] = 0.954157; ro_val[2806] = 0.954177; ro_val[2807] = 0.954197; ro_val[2808] = 0.954217; ro_val[2809] = 0.954237; 
ro_val[2810] = 0.954257; ro_val[2811] = 0.954277; ro_val[2812] = 0.954297; ro_val[2813] = 0.954317; ro_val[2814] = 0.954337; ro_val[2815] = 0.954357; ro_val[2816] = 0.954377; ro_val[2817] = 0.954397; ro_val[2818] = 0.954417; ro_val[2819] = 0.954436; 
ro_val[2820] = 0.954456; ro_val[2821] = 0.954476; ro_val[2822] = 0.954496; ro_val[2823] = 0.954516; ro_val[2824] = 0.954536; ro_val[2825] = 0.954556; ro_val[2826] = 0.954576; ro_val[2827] = 0.954596; ro_val[2828] = 0.954616; ro_val[2829] = 0.954636; 
ro_val[2830] = 0.954656; ro_val[2831] = 0.954676; ro_val[2832] = 0.954696; ro_val[2833] = 0.954716; ro_val[2834] = 0.954736; ro_val[2835] = 0.954756; ro_val[2836] = 0.954776; ro_val[2837] = 0.954796; ro_val[2838] = 0.954816; ro_val[2839] = 0.954836; 
ro_val[2840] = 0.954856; ro_val[2841] = 0.954876; ro_val[2842] = 0.954896; ro_val[2843] = 0.954916; ro_val[2844] = 0.954936; ro_val[2845] = 0.954956; ro_val[2846] = 0.954976; ro_val[2847] = 0.954996; ro_val[2848] = 0.955016; ro_val[2849] = 0.955036; 
ro_val[2850] = 0.955056; ro_val[2851] = 0.955076; ro_val[2852] = 0.955096; ro_val[2853] = 0.955116; ro_val[2854] = 0.955136; ro_val[2855] = 0.955156; ro_val[2856] = 0.955176; ro_val[2857] = 0.955196; ro_val[2858] = 0.955216; ro_val[2859] = 0.955236; 
ro_val[2860] = 0.955256; ro_val[2861] = 0.955276; ro_val[2862] = 0.955296; ro_val[2863] = 0.955316; ro_val[2864] = 0.955336; ro_val[2865] = 0.955356; ro_val[2866] = 0.955376; ro_val[2867] = 0.955396; ro_val[2868] = 0.955416; ro_val[2869] = 0.955436; 
ro_val[2870] = 0.955456; ro_val[2871] = 0.955476; ro_val[2872] = 0.955496; ro_val[2873] = 0.955516; ro_val[2874] = 0.955536; ro_val[2875] = 0.955556; ro_val[2876] = 0.955576; ro_val[2877] = 0.955596; ro_val[2878] = 0.955616; ro_val[2879] = 0.955636; 
ro_val[2880] = 0.955656; ro_val[2881] = 0.955675; ro_val[2882] = 0.955695; ro_val[2883] = 0.955715; ro_val[2884] = 0.955735; ro_val[2885] = 0.955755; ro_val[2886] = 0.955775; ro_val[2887] = 0.955795; ro_val[2888] = 0.955815; ro_val[2889] = 0.955835; 
ro_val[2890] = 0.955855; ro_val[2891] = 0.955875; ro_val[2892] = 0.955895; ro_val[2893] = 0.955915; ro_val[2894] = 0.955935; ro_val[2895] = 0.955955; ro_val[2896] = 0.955975; ro_val[2897] = 0.955995; ro_val[2898] = 0.956015; ro_val[2899] = 0.956035; 
ro_val[2900] = 0.956055; ro_val[2901] = 0.956075; ro_val[2902] = 0.956095; ro_val[2903] = 0.956115; ro_val[2904] = 0.956135; ro_val[2905] = 0.956155; ro_val[2906] = 0.956175; ro_val[2907] = 0.956195; ro_val[2908] = 0.956215; ro_val[2909] = 0.956235; 
ro_val[2910] = 0.956255; ro_val[2911] = 0.956275; ro_val[2912] = 0.956295; ro_val[2913] = 0.956315; ro_val[2914] = 0.956335; ro_val[2915] = 0.956355; ro_val[2916] = 0.956375; ro_val[2917] = 0.956395; ro_val[2918] = 0.956415; ro_val[2919] = 0.956435; 
ro_val[2920] = 0.956455; ro_val[2921] = 0.956475; ro_val[2922] = 0.956495; ro_val[2923] = 0.956515; ro_val[2924] = 0.956535; ro_val[2925] = 0.956555; ro_val[2926] = 0.956575; ro_val[2927] = 0.956595; ro_val[2928] = 0.956615; ro_val[2929] = 0.956635; 
ro_val[2930] = 0.956655; ro_val[2931] = 0.956675; ro_val[2932] = 0.956695; ro_val[2933] = 0.956715; ro_val[2934] = 0.956735; ro_val[2935] = 0.956755; ro_val[2936] = 0.956775; ro_val[2937] = 0.956795; ro_val[2938] = 0.956815; ro_val[2939] = 0.956835; 
ro_val[2940] = 0.956855; ro_val[2941] = 0.956875; ro_val[2942] = 0.956895; ro_val[2943] = 0.956915; ro_val[2944] = 0.956934; ro_val[2945] = 0.956954; ro_val[2946] = 0.956974; ro_val[2947] = 0.956994; ro_val[2948] = 0.957014; ro_val[2949] = 0.957034; 
ro_val[2950] = 0.957054; ro_val[2951] = 0.957074; ro_val[2952] = 0.957094; ro_val[2953] = 0.957114; ro_val[2954] = 0.957134; ro_val[2955] = 0.957154; ro_val[2956] = 0.957174; ro_val[2957] = 0.957194; ro_val[2958] = 0.957214; ro_val[2959] = 0.957234; 
ro_val[2960] = 0.957254; ro_val[2961] = 0.957274; ro_val[2962] = 0.957294; ro_val[2963] = 0.957314; ro_val[2964] = 0.957334; ro_val[2965] = 0.957354; ro_val[2966] = 0.957374; ro_val[2967] = 0.957394; ro_val[2968] = 0.957414; ro_val[2969] = 0.957434; 
ro_val[2970] = 0.957454; ro_val[2971] = 0.957474; ro_val[2972] = 0.957494; ro_val[2973] = 0.957514; ro_val[2974] = 0.957534; ro_val[2975] = 0.957554; ro_val[2976] = 0.957574; ro_val[2977] = 0.957594; ro_val[2978] = 0.957614; ro_val[2979] = 0.957634; 
ro_val[2980] = 0.957654; ro_val[2981] = 0.957674; ro_val[2982] = 0.957694; ro_val[2983] = 0.957714; ro_val[2984] = 0.957734; ro_val[2985] = 0.957754; ro_val[2986] = 0.957774; ro_val[2987] = 0.957794; ro_val[2988] = 0.957814; ro_val[2989] = 0.957834; 
ro_val[2990] = 0.957854; ro_val[2991] = 0.957874; ro_val[2992] = 0.957894; ro_val[2993] = 0.957914; ro_val[2994] = 0.957934; ro_val[2995] = 0.957954; ro_val[2996] = 0.957974; ro_val[2997] = 0.957994; ro_val[2998] = 0.958014; ro_val[2999] = 0.958034; 
ro_val[3000] = 0.958054; ro_val[3001] = 0.958074; ro_val[3002] = 0.958094; ro_val[3003] = 0.958114; ro_val[3004] = 0.958134; ro_val[3005] = 0.958154; ro_val[3006] = 0.958173; ro_val[3007] = 0.958193; ro_val[3008] = 0.958213; ro_val[3009] = 0.958233; 
ro_val[3010] = 0.958253; ro_val[3011] = 0.958273; ro_val[3012] = 0.958293; ro_val[3013] = 0.958313; ro_val[3014] = 0.958333; ro_val[3015] = 0.958353; ro_val[3016] = 0.958373; ro_val[3017] = 0.958393; ro_val[3018] = 0.958413; ro_val[3019] = 0.958433; 
ro_val[3020] = 0.958453; ro_val[3021] = 0.958473; ro_val[3022] = 0.958493; ro_val[3023] = 0.958513; ro_val[3024] = 0.958533; ro_val[3025] = 0.958553; ro_val[3026] = 0.958573; ro_val[3027] = 0.958593; ro_val[3028] = 0.958613; ro_val[3029] = 0.958633; 
ro_val[3030] = 0.958653; ro_val[3031] = 0.958673; ro_val[3032] = 0.958693; ro_val[3033] = 0.958713; ro_val[3034] = 0.958733; ro_val[3035] = 0.958753; ro_val[3036] = 0.958773; ro_val[3037] = 0.958793; ro_val[3038] = 0.958813; ro_val[3039] = 0.958833; 
ro_val[3040] = 0.958853; ro_val[3041] = 0.958873; ro_val[3042] = 0.958893; ro_val[3043] = 0.958913; ro_val[3044] = 0.958933; ro_val[3045] = 0.958953; ro_val[3046] = 0.958973; ro_val[3047] = 0.958993; ro_val[3048] = 0.959013; ro_val[3049] = 0.959033; 
ro_val[3050] = 0.959053; ro_val[3051] = 0.959073; ro_val[3052] = 0.959093; ro_val[3053] = 0.959113; ro_val[3054] = 0.959133; ro_val[3055] = 0.959153; ro_val[3056] = 0.959173; ro_val[3057] = 0.959193; ro_val[3058] = 0.959213; ro_val[3059] = 0.959233; 
ro_val[3060] = 0.959253; ro_val[3061] = 0.959273; ro_val[3062] = 0.959293; ro_val[3063] = 0.959313; ro_val[3064] = 0.959333; ro_val[3065] = 0.959353; ro_val[3066] = 0.959373; ro_val[3067] = 0.959393; ro_val[3068] = 0.959413; ro_val[3069] = 0.959432; 
ro_val[3070] = 0.959452; ro_val[3071] = 0.959472; ro_val[3072] = 0.959492; ro_val[3073] = 0.959512; ro_val[3074] = 0.959532; ro_val[3075] = 0.959552; ro_val[3076] = 0.959572; ro_val[3077] = 0.959592; ro_val[3078] = 0.959612; ro_val[3079] = 0.959632; 
ro_val[3080] = 0.959652; ro_val[3081] = 0.959672; ro_val[3082] = 0.959692; ro_val[3083] = 0.959712; ro_val[3084] = 0.959732; ro_val[3085] = 0.959752; ro_val[3086] = 0.959772; ro_val[3087] = 0.959792; ro_val[3088] = 0.959812; ro_val[3089] = 0.959832; 
ro_val[3090] = 0.959852; ro_val[3091] = 0.959872; ro_val[3092] = 0.959892; ro_val[3093] = 0.959912; ro_val[3094] = 0.959932; ro_val[3095] = 0.959952; ro_val[3096] = 0.959972; ro_val[3097] = 0.959992; ro_val[3098] = 0.960012; ro_val[3099] = 0.960032; 
ro_val[3100] = 0.960052; ro_val[3101] = 0.960072; ro_val[3102] = 0.960092; ro_val[3103] = 0.960112; ro_val[3104] = 0.960132; ro_val[3105] = 0.960152; ro_val[3106] = 0.960172; ro_val[3107] = 0.960192; ro_val[3108] = 0.960212; ro_val[3109] = 0.960232; 
ro_val[3110] = 0.960252; ro_val[3111] = 0.960272; ro_val[3112] = 0.960292; ro_val[3113] = 0.960312; ro_val[3114] = 0.960332; ro_val[3115] = 0.960352; ro_val[3116] = 0.960372; ro_val[3117] = 0.960392; ro_val[3118] = 0.960412; ro_val[3119] = 0.960432; 
ro_val[3120] = 0.960452; ro_val[3121] = 0.960472; ro_val[3122] = 0.960492; ro_val[3123] = 0.960512; ro_val[3124] = 0.960532; ro_val[3125] = 0.960552; ro_val[3126] = 0.960572; ro_val[3127] = 0.960592; ro_val[3128] = 0.960612; ro_val[3129] = 0.960632; 
ro_val[3130] = 0.960652; ro_val[3131] = 0.960671; ro_val[3132] = 0.960691; ro_val[3133] = 0.960711; ro_val[3134] = 0.960731; ro_val[3135] = 0.960751; ro_val[3136] = 0.960771; ro_val[3137] = 0.960791; ro_val[3138] = 0.960811; ro_val[3139] = 0.960831; 
ro_val[3140] = 0.960851; ro_val[3141] = 0.960871; ro_val[3142] = 0.960891; ro_val[3143] = 0.960911; ro_val[3144] = 0.960931; ro_val[3145] = 0.960951; ro_val[3146] = 0.960971; ro_val[3147] = 0.960991; ro_val[3148] = 0.961011; ro_val[3149] = 0.961031; 
ro_val[3150] = 0.961051; ro_val[3151] = 0.961071; ro_val[3152] = 0.961091; ro_val[3153] = 0.961111; ro_val[3154] = 0.961131; ro_val[3155] = 0.961151; ro_val[3156] = 0.961171; ro_val[3157] = 0.961191; ro_val[3158] = 0.961211; ro_val[3159] = 0.961231; 
ro_val[3160] = 0.961251; ro_val[3161] = 0.961271; ro_val[3162] = 0.961291; ro_val[3163] = 0.961311; ro_val[3164] = 0.961331; ro_val[3165] = 0.961351; ro_val[3166] = 0.961371; ro_val[3167] = 0.961391; ro_val[3168] = 0.961411; ro_val[3169] = 0.961431; 
ro_val[3170] = 0.961451; ro_val[3171] = 0.961471; ro_val[3172] = 0.961491; ro_val[3173] = 0.961511; ro_val[3174] = 0.961531; ro_val[3175] = 0.961551; ro_val[3176] = 0.961571; ro_val[3177] = 0.961591; ro_val[3178] = 0.961611; ro_val[3179] = 0.961631; 
ro_val[3180] = 0.961651; ro_val[3181] = 0.961671; ro_val[3182] = 0.961691; ro_val[3183] = 0.961711; ro_val[3184] = 0.961731; ro_val[3185] = 0.961751; ro_val[3186] = 0.961771; ro_val[3187] = 0.961791; ro_val[3188] = 0.961811; ro_val[3189] = 0.961831; 
ro_val[3190] = 0.961851; ro_val[3191] = 0.961871; ro_val[3192] = 0.961891; ro_val[3193] = 0.961911; ro_val[3194] = 0.961930; ro_val[3195] = 0.961950; ro_val[3196] = 0.961970; ro_val[3197] = 0.961990; ro_val[3198] = 0.962010; ro_val[3199] = 0.962030; 
ro_val[3200] = 0.962050; ro_val[3201] = 0.962070; ro_val[3202] = 0.962090; ro_val[3203] = 0.962110; ro_val[3204] = 0.962130; ro_val[3205] = 0.962150; ro_val[3206] = 0.962170; ro_val[3207] = 0.962190; ro_val[3208] = 0.962210; ro_val[3209] = 0.962230; 
ro_val[3210] = 0.962250; ro_val[3211] = 0.962270; ro_val[3212] = 0.962290; ro_val[3213] = 0.962310; ro_val[3214] = 0.962330; ro_val[3215] = 0.962350; ro_val[3216] = 0.962370; ro_val[3217] = 0.962390; ro_val[3218] = 0.962410; ro_val[3219] = 0.962430; 
ro_val[3220] = 0.962450; ro_val[3221] = 0.962470; ro_val[3222] = 0.962490; ro_val[3223] = 0.962510; ro_val[3224] = 0.962530; ro_val[3225] = 0.962550; ro_val[3226] = 0.962570; ro_val[3227] = 0.962590; ro_val[3228] = 0.962610; ro_val[3229] = 0.962630; 
ro_val[3230] = 0.962650; ro_val[3231] = 0.962670; ro_val[3232] = 0.962690; ro_val[3233] = 0.962710; ro_val[3234] = 0.962730; ro_val[3235] = 0.962750; ro_val[3236] = 0.962770; ro_val[3237] = 0.962790; ro_val[3238] = 0.962810; ro_val[3239] = 0.962830; 
ro_val[3240] = 0.962850; ro_val[3241] = 0.962870; ro_val[3242] = 0.962890; ro_val[3243] = 0.962910; ro_val[3244] = 0.962930; ro_val[3245] = 0.962950; ro_val[3246] = 0.962970; ro_val[3247] = 0.962990; ro_val[3248] = 0.963010; ro_val[3249] = 0.963030; 
ro_val[3250] = 0.963050; ro_val[3251] = 0.963070; ro_val[3252] = 0.963090; ro_val[3253] = 0.963110; ro_val[3254] = 0.963130; ro_val[3255] = 0.963150; ro_val[3256] = 0.963169; ro_val[3257] = 0.963189; ro_val[3258] = 0.963209; ro_val[3259] = 0.963229; 
ro_val[3260] = 0.963249; ro_val[3261] = 0.963269; ro_val[3262] = 0.963289; ro_val[3263] = 0.963309; ro_val[3264] = 0.963329; ro_val[3265] = 0.963349; ro_val[3266] = 0.963369; ro_val[3267] = 0.963389; ro_val[3268] = 0.963409; ro_val[3269] = 0.963429; 
ro_val[3270] = 0.963449; ro_val[3271] = 0.963469; ro_val[3272] = 0.963489; ro_val[3273] = 0.963509; ro_val[3274] = 0.963529; ro_val[3275] = 0.963549; ro_val[3276] = 0.963569; ro_val[3277] = 0.963589; ro_val[3278] = 0.963609; ro_val[3279] = 0.963629; 
ro_val[3280] = 0.963649; ro_val[3281] = 0.963669; ro_val[3282] = 0.963689; ro_val[3283] = 0.963709; ro_val[3284] = 0.963729; ro_val[3285] = 0.963749; ro_val[3286] = 0.963769; ro_val[3287] = 0.963789; ro_val[3288] = 0.963809; ro_val[3289] = 0.963829; 
ro_val[3290] = 0.963849; ro_val[3291] = 0.963869; ro_val[3292] = 0.963889; ro_val[3293] = 0.963909; ro_val[3294] = 0.963929; ro_val[3295] = 0.963949; ro_val[3296] = 0.963969; ro_val[3297] = 0.963989; ro_val[3298] = 0.964009; ro_val[3299] = 0.964029; 
ro_val[3300] = 0.964049; ro_val[3301] = 0.964069; ro_val[3302] = 0.964089; ro_val[3303] = 0.964109; ro_val[3304] = 0.964129; ro_val[3305] = 0.964149; ro_val[3306] = 0.964169; ro_val[3307] = 0.964189; ro_val[3308] = 0.964209; ro_val[3309] = 0.964229; 
ro_val[3310] = 0.964249; ro_val[3311] = 0.964269; ro_val[3312] = 0.964289; ro_val[3313] = 0.964309; ro_val[3314] = 0.964329; ro_val[3315] = 0.964349; ro_val[3316] = 0.964369; ro_val[3317] = 0.964389; ro_val[3318] = 0.964409; ro_val[3319] = 0.964428; 
ro_val[3320] = 0.964448; ro_val[3321] = 0.964468; ro_val[3322] = 0.964488; ro_val[3323] = 0.964508; ro_val[3324] = 0.964528; ro_val[3325] = 0.964548; ro_val[3326] = 0.964568; ro_val[3327] = 0.964588; ro_val[3328] = 0.964608; ro_val[3329] = 0.964628; 
ro_val[3330] = 0.964648; ro_val[3331] = 0.964668; ro_val[3332] = 0.964688; ro_val[3333] = 0.964708; ro_val[3334] = 0.964728; ro_val[3335] = 0.964748; ro_val[3336] = 0.964768; ro_val[3337] = 0.964788; ro_val[3338] = 0.964808; ro_val[3339] = 0.964828; 
ro_val[3340] = 0.964848; ro_val[3341] = 0.964868; ro_val[3342] = 0.964888; ro_val[3343] = 0.964908; ro_val[3344] = 0.964928; ro_val[3345] = 0.964948; ro_val[3346] = 0.964968; ro_val[3347] = 0.964988; ro_val[3348] = 0.965008; ro_val[3349] = 0.965028; 
ro_val[3350] = 0.965048; ro_val[3351] = 0.965068; ro_val[3352] = 0.965088; ro_val[3353] = 0.965108; ro_val[3354] = 0.965128; ro_val[3355] = 0.965148; ro_val[3356] = 0.965168; ro_val[3357] = 0.965188; ro_val[3358] = 0.965208; ro_val[3359] = 0.965228; 
ro_val[3360] = 0.965248; ro_val[3361] = 0.965268; ro_val[3362] = 0.965288; ro_val[3363] = 0.965308; ro_val[3364] = 0.965328; ro_val[3365] = 0.965348; ro_val[3366] = 0.965368; ro_val[3367] = 0.965388; ro_val[3368] = 0.965408; ro_val[3369] = 0.965428; 
ro_val[3370] = 0.965448; ro_val[3371] = 0.965468; ro_val[3372] = 0.965488; ro_val[3373] = 0.965508; ro_val[3374] = 0.965528; ro_val[3375] = 0.965548; ro_val[3376] = 0.965568; ro_val[3377] = 0.965588; ro_val[3378] = 0.965608; ro_val[3379] = 0.965628; 
ro_val[3380] = 0.965648; ro_val[3381] = 0.965667; ro_val[3382] = 0.965687; ro_val[3383] = 0.965707; ro_val[3384] = 0.965727; ro_val[3385] = 0.965747; ro_val[3386] = 0.965767; ro_val[3387] = 0.965787; ro_val[3388] = 0.965807; ro_val[3389] = 0.965827; 
ro_val[3390] = 0.965847; ro_val[3391] = 0.965867; ro_val[3392] = 0.965887; ro_val[3393] = 0.965907; ro_val[3394] = 0.965927; ro_val[3395] = 0.965947; ro_val[3396] = 0.965967; ro_val[3397] = 0.965987; ro_val[3398] = 0.966007; ro_val[3399] = 0.966027; 
ro_val[3400] = 0.966047; ro_val[3401] = 0.966067; ro_val[3402] = 0.966087; ro_val[3403] = 0.966107; ro_val[3404] = 0.966127; ro_val[3405] = 0.966147; ro_val[3406] = 0.966167; ro_val[3407] = 0.966187; ro_val[3408] = 0.966207; ro_val[3409] = 0.966227; 
ro_val[3410] = 0.966247; ro_val[3411] = 0.966267; ro_val[3412] = 0.966287; ro_val[3413] = 0.966307; ro_val[3414] = 0.966327; ro_val[3415] = 0.966347; ro_val[3416] = 0.966367; ro_val[3417] = 0.966387; ro_val[3418] = 0.966407; ro_val[3419] = 0.966427; 
ro_val[3420] = 0.966447; ro_val[3421] = 0.966467; ro_val[3422] = 0.966487; ro_val[3423] = 0.966507; ro_val[3424] = 0.966527; ro_val[3425] = 0.966547; ro_val[3426] = 0.966567; ro_val[3427] = 0.966587; ro_val[3428] = 0.966607; ro_val[3429] = 0.966627; 
ro_val[3430] = 0.966647; ro_val[3431] = 0.966667; ro_val[3432] = 0.966687; ro_val[3433] = 0.966707; ro_val[3434] = 0.966727; ro_val[3435] = 0.966747; ro_val[3436] = 0.966767; ro_val[3437] = 0.966787; ro_val[3438] = 0.966807; ro_val[3439] = 0.966827; 
ro_val[3440] = 0.966847; ro_val[3441] = 0.966867; ro_val[3442] = 0.966887; ro_val[3443] = 0.966907; ro_val[3444] = 0.966926; ro_val[3445] = 0.966946; ro_val[3446] = 0.966966; ro_val[3447] = 0.966986; ro_val[3448] = 0.967006; ro_val[3449] = 0.967026; 
ro_val[3450] = 0.967046; ro_val[3451] = 0.967066; ro_val[3452] = 0.967086; ro_val[3453] = 0.967106; ro_val[3454] = 0.967126; ro_val[3455] = 0.967146; ro_val[3456] = 0.967166; ro_val[3457] = 0.967186; ro_val[3458] = 0.967206; ro_val[3459] = 0.967226; 
ro_val[3460] = 0.967246; ro_val[3461] = 0.967266; ro_val[3462] = 0.967286; ro_val[3463] = 0.967306; ro_val[3464] = 0.967326; ro_val[3465] = 0.967346; ro_val[3466] = 0.967366; ro_val[3467] = 0.967386; ro_val[3468] = 0.967406; ro_val[3469] = 0.967426; 
ro_val[3470] = 0.967446; ro_val[3471] = 0.967466; ro_val[3472] = 0.967486; ro_val[3473] = 0.967506; ro_val[3474] = 0.967526; ro_val[3475] = 0.967546; ro_val[3476] = 0.967566; ro_val[3477] = 0.967586; ro_val[3478] = 0.967606; ro_val[3479] = 0.967626; 
ro_val[3480] = 0.967646; ro_val[3481] = 0.967666; ro_val[3482] = 0.967686; ro_val[3483] = 0.967706; ro_val[3484] = 0.967726; ro_val[3485] = 0.967746; ro_val[3486] = 0.967766; ro_val[3487] = 0.967786; ro_val[3488] = 0.967806; ro_val[3489] = 0.967826; 
ro_val[3490] = 0.967846; ro_val[3491] = 0.967866; ro_val[3492] = 0.967886; ro_val[3493] = 0.967906; ro_val[3494] = 0.967926; ro_val[3495] = 0.967946; ro_val[3496] = 0.967966; ro_val[3497] = 0.967986; ro_val[3498] = 0.968006; ro_val[3499] = 0.968026; 
ro_val[3500] = 0.968046; ro_val[3501] = 0.968066; ro_val[3502] = 0.968086; ro_val[3503] = 0.968106; ro_val[3504] = 0.968126; ro_val[3505] = 0.968146; ro_val[3506] = 0.968165; ro_val[3507] = 0.968185; ro_val[3508] = 0.968205; ro_val[3509] = 0.968225; 
ro_val[3510] = 0.968245; ro_val[3511] = 0.968265; ro_val[3512] = 0.968285; ro_val[3513] = 0.968305; ro_val[3514] = 0.968325; ro_val[3515] = 0.968345; ro_val[3516] = 0.968365; ro_val[3517] = 0.968385; ro_val[3518] = 0.968405; ro_val[3519] = 0.968425; 
ro_val[3520] = 0.968445; ro_val[3521] = 0.968465; ro_val[3522] = 0.968485; ro_val[3523] = 0.968505; ro_val[3524] = 0.968525; ro_val[3525] = 0.968545; ro_val[3526] = 0.968565; ro_val[3527] = 0.968585; ro_val[3528] = 0.968605; ro_val[3529] = 0.968625; 
ro_val[3530] = 0.968645; ro_val[3531] = 0.968665; ro_val[3532] = 0.968685; ro_val[3533] = 0.968705; ro_val[3534] = 0.968725; ro_val[3535] = 0.968745; ro_val[3536] = 0.968765; ro_val[3537] = 0.968785; ro_val[3538] = 0.968805; ro_val[3539] = 0.968825; 
ro_val[3540] = 0.968845; ro_val[3541] = 0.968865; ro_val[3542] = 0.968885; ro_val[3543] = 0.968905; ro_val[3544] = 0.968925; ro_val[3545] = 0.968945; ro_val[3546] = 0.968965; ro_val[3547] = 0.968985; ro_val[3548] = 0.969005; ro_val[3549] = 0.969025; 
ro_val[3550] = 0.969045; ro_val[3551] = 0.969065; ro_val[3552] = 0.969085; ro_val[3553] = 0.969105; ro_val[3554] = 0.969125; ro_val[3555] = 0.969145; ro_val[3556] = 0.969165; ro_val[3557] = 0.969185; ro_val[3558] = 0.969205; ro_val[3559] = 0.969225; 
ro_val[3560] = 0.969245; ro_val[3561] = 0.969265; ro_val[3562] = 0.969285; ro_val[3563] = 0.969305; ro_val[3564] = 0.969325; ro_val[3565] = 0.969345; ro_val[3566] = 0.969365; ro_val[3567] = 0.969385; ro_val[3568] = 0.969405; ro_val[3569] = 0.969424; 
ro_val[3570] = 0.969444; ro_val[3571] = 0.969464; ro_val[3572] = 0.969484; ro_val[3573] = 0.969504; ro_val[3574] = 0.969524; ro_val[3575] = 0.969544; ro_val[3576] = 0.969564; ro_val[3577] = 0.969584; ro_val[3578] = 0.969604; ro_val[3579] = 0.969624; 
ro_val[3580] = 0.969644; ro_val[3581] = 0.969664; ro_val[3582] = 0.969684; ro_val[3583] = 0.969704; ro_val[3584] = 0.969724; ro_val[3585] = 0.969744; ro_val[3586] = 0.969764; ro_val[3587] = 0.969784; ro_val[3588] = 0.969804; ro_val[3589] = 0.969824; 
ro_val[3590] = 0.969844; ro_val[3591] = 0.969864; ro_val[3592] = 0.969884; ro_val[3593] = 0.969904; ro_val[3594] = 0.969924; ro_val[3595] = 0.969944; ro_val[3596] = 0.969964; ro_val[3597] = 0.969984; ro_val[3598] = 0.970004; ro_val[3599] = 0.970024; 
ro_val[3600] = 0.970044; ro_val[3601] = 0.970064; ro_val[3602] = 0.970084; ro_val[3603] = 0.970104; ro_val[3604] = 0.970124; ro_val[3605] = 0.970144; ro_val[3606] = 0.970164; ro_val[3607] = 0.970184; ro_val[3608] = 0.970204; ro_val[3609] = 0.970224; 
ro_val[3610] = 0.970244; ro_val[3611] = 0.970264; ro_val[3612] = 0.970284; ro_val[3613] = 0.970304; ro_val[3614] = 0.970324; ro_val[3615] = 0.970344; ro_val[3616] = 0.970364; ro_val[3617] = 0.970384; ro_val[3618] = 0.970404; ro_val[3619] = 0.970424; 
ro_val[3620] = 0.970444; ro_val[3621] = 0.970464; ro_val[3622] = 0.970484; ro_val[3623] = 0.970504; ro_val[3624] = 0.970524; ro_val[3625] = 0.970544; ro_val[3626] = 0.970564; ro_val[3627] = 0.970584; ro_val[3628] = 0.970604; ro_val[3629] = 0.970624; 
ro_val[3630] = 0.970644; ro_val[3631] = 0.970663; ro_val[3632] = 0.970683; ro_val[3633] = 0.970703; ro_val[3634] = 0.970723; ro_val[3635] = 0.970743; ro_val[3636] = 0.970763; ro_val[3637] = 0.970783; ro_val[3638] = 0.970803; ro_val[3639] = 0.970823; 
ro_val[3640] = 0.970843; ro_val[3641] = 0.970863; ro_val[3642] = 0.970883; ro_val[3643] = 0.970903; ro_val[3644] = 0.970923; ro_val[3645] = 0.970943; ro_val[3646] = 0.970963; ro_val[3647] = 0.970983; ro_val[3648] = 0.971003; ro_val[3649] = 0.971023; 
ro_val[3650] = 0.971043; ro_val[3651] = 0.971063; ro_val[3652] = 0.971083; ro_val[3653] = 0.971103; ro_val[3654] = 0.971123; ro_val[3655] = 0.971143; ro_val[3656] = 0.971163; ro_val[3657] = 0.971183; ro_val[3658] = 0.971203; ro_val[3659] = 0.971223; 
ro_val[3660] = 0.971243; ro_val[3661] = 0.971263; ro_val[3662] = 0.971283; ro_val[3663] = 0.971303; ro_val[3664] = 0.971323; ro_val[3665] = 0.971343; ro_val[3666] = 0.971363; ro_val[3667] = 0.971383; ro_val[3668] = 0.971403; ro_val[3669] = 0.971423; 
ro_val[3670] = 0.971443; ro_val[3671] = 0.971463; ro_val[3672] = 0.971483; ro_val[3673] = 0.971503; ro_val[3674] = 0.971523; ro_val[3675] = 0.971543; ro_val[3676] = 0.971563; ro_val[3677] = 0.971583; ro_val[3678] = 0.971603; ro_val[3679] = 0.971623; 
ro_val[3680] = 0.971643; ro_val[3681] = 0.971663; ro_val[3682] = 0.971683; ro_val[3683] = 0.971703; ro_val[3684] = 0.971723; ro_val[3685] = 0.971743; ro_val[3686] = 0.971763; ro_val[3687] = 0.971783; ro_val[3688] = 0.971803; ro_val[3689] = 0.971823; 
ro_val[3690] = 0.971843; ro_val[3691] = 0.971863; ro_val[3692] = 0.971883; ro_val[3693] = 0.971903; ro_val[3694] = 0.971922; ro_val[3695] = 0.971942; ro_val[3696] = 0.971962; ro_val[3697] = 0.971982; ro_val[3698] = 0.972002; ro_val[3699] = 0.972022; 
ro_val[3700] = 0.972042; ro_val[3701] = 0.972062; ro_val[3702] = 0.972082; ro_val[3703] = 0.972102; ro_val[3704] = 0.972122; ro_val[3705] = 0.972142; ro_val[3706] = 0.972162; ro_val[3707] = 0.972182; ro_val[3708] = 0.972202; ro_val[3709] = 0.972222; 
ro_val[3710] = 0.972242; ro_val[3711] = 0.972262; ro_val[3712] = 0.972282; ro_val[3713] = 0.972302; ro_val[3714] = 0.972322; ro_val[3715] = 0.972342; ro_val[3716] = 0.972362; ro_val[3717] = 0.972382; ro_val[3718] = 0.972402; ro_val[3719] = 0.972422; 
ro_val[3720] = 0.972442; ro_val[3721] = 0.972462; ro_val[3722] = 0.972482; ro_val[3723] = 0.972502; ro_val[3724] = 0.972522; ro_val[3725] = 0.972542; ro_val[3726] = 0.972562; ro_val[3727] = 0.972582; ro_val[3728] = 0.972602; ro_val[3729] = 0.972622; 
ro_val[3730] = 0.972642; ro_val[3731] = 0.972662; ro_val[3732] = 0.972682; ro_val[3733] = 0.972702; ro_val[3734] = 0.972722; ro_val[3735] = 0.972742; ro_val[3736] = 0.972762; ro_val[3737] = 0.972782; ro_val[3738] = 0.972802; ro_val[3739] = 0.972822; 
ro_val[3740] = 0.972842; ro_val[3741] = 0.972862; ro_val[3742] = 0.972882; ro_val[3743] = 0.972902; ro_val[3744] = 0.972922; ro_val[3745] = 0.972942; ro_val[3746] = 0.972962; ro_val[3747] = 0.972982; ro_val[3748] = 0.973002; ro_val[3749] = 0.973022; 
ro_val[3750] = 0.973042; ro_val[3751] = 0.973062; ro_val[3752] = 0.973082; ro_val[3753] = 0.973102; ro_val[3754] = 0.973122; ro_val[3755] = 0.973142; ro_val[3756] = 0.973161; ro_val[3757] = 0.973181; ro_val[3758] = 0.973201; ro_val[3759] = 0.973221; 
ro_val[3760] = 0.973241; ro_val[3761] = 0.973261; ro_val[3762] = 0.973281; ro_val[3763] = 0.973301; ro_val[3764] = 0.973321; ro_val[3765] = 0.973341; ro_val[3766] = 0.973361; ro_val[3767] = 0.973381; ro_val[3768] = 0.973401; ro_val[3769] = 0.973421; 
ro_val[3770] = 0.973441; ro_val[3771] = 0.973461; ro_val[3772] = 0.973481; ro_val[3773] = 0.973501; ro_val[3774] = 0.973521; ro_val[3775] = 0.973541; ro_val[3776] = 0.973561; ro_val[3777] = 0.973581; ro_val[3778] = 0.973601; ro_val[3779] = 0.973621; 
ro_val[3780] = 0.973641; ro_val[3781] = 0.973661; ro_val[3782] = 0.973681; ro_val[3783] = 0.973701; ro_val[3784] = 0.973721; ro_val[3785] = 0.973741; ro_val[3786] = 0.973761; ro_val[3787] = 0.973781; ro_val[3788] = 0.973801; ro_val[3789] = 0.973821; 
ro_val[3790] = 0.973841; ro_val[3791] = 0.973861; ro_val[3792] = 0.973881; ro_val[3793] = 0.973901; ro_val[3794] = 0.973921; ro_val[3795] = 0.973941; ro_val[3796] = 0.973961; ro_val[3797] = 0.973981; ro_val[3798] = 0.974001; ro_val[3799] = 0.974021; 
ro_val[3800] = 0.974041; ro_val[3801] = 0.974061; ro_val[3802] = 0.974081; ro_val[3803] = 0.974101; ro_val[3804] = 0.974121; ro_val[3805] = 0.974141; ro_val[3806] = 0.974161; ro_val[3807] = 0.974181; ro_val[3808] = 0.974201; ro_val[3809] = 0.974221; 
ro_val[3810] = 0.974241; ro_val[3811] = 0.974261; ro_val[3812] = 0.974281; ro_val[3813] = 0.974301; ro_val[3814] = 0.974321; ro_val[3815] = 0.974341; ro_val[3816] = 0.974361; ro_val[3817] = 0.974381; ro_val[3818] = 0.974401; ro_val[3819] = 0.974420; 
ro_val[3820] = 0.974440; ro_val[3821] = 0.974460; ro_val[3822] = 0.974480; ro_val[3823] = 0.974500; ro_val[3824] = 0.974520; ro_val[3825] = 0.974540; ro_val[3826] = 0.974560; ro_val[3827] = 0.974580; ro_val[3828] = 0.974600; ro_val[3829] = 0.974620; 
ro_val[3830] = 0.974640; ro_val[3831] = 0.974660; ro_val[3832] = 0.974680; ro_val[3833] = 0.974700; ro_val[3834] = 0.974720; ro_val[3835] = 0.974740; ro_val[3836] = 0.974760; ro_val[3837] = 0.974780; ro_val[3838] = 0.974800; ro_val[3839] = 0.974820; 
ro_val[3840] = 0.974840; ro_val[3841] = 0.974860; ro_val[3842] = 0.974880; ro_val[3843] = 0.974900; ro_val[3844] = 0.974920; ro_val[3845] = 0.974940; ro_val[3846] = 0.974960; ro_val[3847] = 0.974980; ro_val[3848] = 0.975000; ro_val[3849] = 0.975020; 
ro_val[3850] = 0.975040; ro_val[3851] = 0.975060; ro_val[3852] = 0.975080; ro_val[3853] = 0.975100; ro_val[3854] = 0.975120; ro_val[3855] = 0.975140; ro_val[3856] = 0.975160; ro_val[3857] = 0.975180; ro_val[3858] = 0.975200; ro_val[3859] = 0.975220; 
ro_val[3860] = 0.975240; ro_val[3861] = 0.975260; ro_val[3862] = 0.975280; ro_val[3863] = 0.975300; ro_val[3864] = 0.975320; ro_val[3865] = 0.975340; ro_val[3866] = 0.975360; ro_val[3867] = 0.975380; ro_val[3868] = 0.975400; ro_val[3869] = 0.975420; 
ro_val[3870] = 0.975440; ro_val[3871] = 0.975460; ro_val[3872] = 0.975480; ro_val[3873] = 0.975500; ro_val[3874] = 0.975520; ro_val[3875] = 0.975540; ro_val[3876] = 0.975560; ro_val[3877] = 0.975580; ro_val[3878] = 0.975600; ro_val[3879] = 0.975620; 
ro_val[3880] = 0.975640; ro_val[3881] = 0.975659; ro_val[3882] = 0.975679; ro_val[3883] = 0.975699; ro_val[3884] = 0.975719; ro_val[3885] = 0.975739; ro_val[3886] = 0.975759; ro_val[3887] = 0.975779; ro_val[3888] = 0.975799; ro_val[3889] = 0.975819; 
ro_val[3890] = 0.975839; ro_val[3891] = 0.975859; ro_val[3892] = 0.975879; ro_val[3893] = 0.975899; ro_val[3894] = 0.975919; ro_val[3895] = 0.975939; ro_val[3896] = 0.975959; ro_val[3897] = 0.975979; ro_val[3898] = 0.975999; ro_val[3899] = 0.976019; 
ro_val[3900] = 0.976039; ro_val[3901] = 0.976059; ro_val[3902] = 0.976079; ro_val[3903] = 0.976099; ro_val[3904] = 0.976119; ro_val[3905] = 0.976139; ro_val[3906] = 0.976159; ro_val[3907] = 0.976179; ro_val[3908] = 0.976199; ro_val[3909] = 0.976219; 
ro_val[3910] = 0.976239; ro_val[3911] = 0.976259; ro_val[3912] = 0.976279; ro_val[3913] = 0.976299; ro_val[3914] = 0.976319; ro_val[3915] = 0.976339; ro_val[3916] = 0.976359; ro_val[3917] = 0.976379; ro_val[3918] = 0.976399; ro_val[3919] = 0.976419; 
ro_val[3920] = 0.976439; ro_val[3921] = 0.976459; ro_val[3922] = 0.976479; ro_val[3923] = 0.976499; ro_val[3924] = 0.976519; ro_val[3925] = 0.976539; ro_val[3926] = 0.976559; ro_val[3927] = 0.976579; ro_val[3928] = 0.976599; ro_val[3929] = 0.976619; 
ro_val[3930] = 0.976639; ro_val[3931] = 0.976659; ro_val[3932] = 0.976679; ro_val[3933] = 0.976699; ro_val[3934] = 0.976719; ro_val[3935] = 0.976739; ro_val[3936] = 0.976759; ro_val[3937] = 0.976779; ro_val[3938] = 0.976799; ro_val[3939] = 0.976819; 
ro_val[3940] = 0.976839; ro_val[3941] = 0.976859; ro_val[3942] = 0.976879; ro_val[3943] = 0.976898; ro_val[3944] = 0.976918; ro_val[3945] = 0.976938; ro_val[3946] = 0.976958; ro_val[3947] = 0.976978; ro_val[3948] = 0.976998; ro_val[3949] = 0.977018; 
ro_val[3950] = 0.977038; ro_val[3951] = 0.977058; ro_val[3952] = 0.977078; ro_val[3953] = 0.977098; ro_val[3954] = 0.977118; ro_val[3955] = 0.977138; ro_val[3956] = 0.977158; ro_val[3957] = 0.977178; ro_val[3958] = 0.977198; ro_val[3959] = 0.977218; 
ro_val[3960] = 0.977238; ro_val[3961] = 0.977258; ro_val[3962] = 0.977278; ro_val[3963] = 0.977298; ro_val[3964] = 0.977318; ro_val[3965] = 0.977338; ro_val[3966] = 0.977358; ro_val[3967] = 0.977378; ro_val[3968] = 0.977398; ro_val[3969] = 0.977418; 
ro_val[3970] = 0.977438; ro_val[3971] = 0.977458; ro_val[3972] = 0.977478; ro_val[3973] = 0.977498; ro_val[3974] = 0.977518; ro_val[3975] = 0.977538; ro_val[3976] = 0.977558; ro_val[3977] = 0.977578; ro_val[3978] = 0.977598; ro_val[3979] = 0.977618; 
ro_val[3980] = 0.977638; ro_val[3981] = 0.977658; ro_val[3982] = 0.977678; ro_val[3983] = 0.977698; ro_val[3984] = 0.977718; ro_val[3985] = 0.977738; ro_val[3986] = 0.977758; ro_val[3987] = 0.977778; ro_val[3988] = 0.977798; ro_val[3989] = 0.977818; 
ro_val[3990] = 0.977838; ro_val[3991] = 0.977858; ro_val[3992] = 0.977878; ro_val[3993] = 0.977898; ro_val[3994] = 0.977918; ro_val[3995] = 0.977938; ro_val[3996] = 0.977958; ro_val[3997] = 0.977978; ro_val[3998] = 0.977998; ro_val[3999] = 0.978018; 
ro_val[4000] = 0.978038; ro_val[4001] = 0.978058; ro_val[4002] = 0.978078; ro_val[4003] = 0.978098; ro_val[4004] = 0.978118; ro_val[4005] = 0.978138; ro_val[4006] = 0.978157; ro_val[4007] = 0.978177; ro_val[4008] = 0.978197; ro_val[4009] = 0.978217; 
ro_val[4010] = 0.978237; ro_val[4011] = 0.978257; ro_val[4012] = 0.978277; ro_val[4013] = 0.978297; ro_val[4014] = 0.978317; ro_val[4015] = 0.978337; ro_val[4016] = 0.978357; ro_val[4017] = 0.978377; ro_val[4018] = 0.978397; ro_val[4019] = 0.978417; 
ro_val[4020] = 0.978437; ro_val[4021] = 0.978457; ro_val[4022] = 0.978477; ro_val[4023] = 0.978497; ro_val[4024] = 0.978517; ro_val[4025] = 0.978537; ro_val[4026] = 0.978557; ro_val[4027] = 0.978577; ro_val[4028] = 0.978597; ro_val[4029] = 0.978617; 
ro_val[4030] = 0.978637; ro_val[4031] = 0.978657; ro_val[4032] = 0.978677; ro_val[4033] = 0.978697; ro_val[4034] = 0.978717; ro_val[4035] = 0.978737; ro_val[4036] = 0.978757; ro_val[4037] = 0.978777; ro_val[4038] = 0.978797; ro_val[4039] = 0.978817; 
ro_val[4040] = 0.978837; ro_val[4041] = 0.978857; ro_val[4042] = 0.978877; ro_val[4043] = 0.978897; ro_val[4044] = 0.978917; ro_val[4045] = 0.978937; ro_val[4046] = 0.978957; ro_val[4047] = 0.978977; ro_val[4048] = 0.978997; ro_val[4049] = 0.979017; 
ro_val[4050] = 0.979037; ro_val[4051] = 0.979057; ro_val[4052] = 0.979077; ro_val[4053] = 0.979097; ro_val[4054] = 0.979117; ro_val[4055] = 0.979137; ro_val[4056] = 0.979157; ro_val[4057] = 0.979177; ro_val[4058] = 0.979197; ro_val[4059] = 0.979217; 
ro_val[4060] = 0.979237; ro_val[4061] = 0.979257; ro_val[4062] = 0.979277; ro_val[4063] = 0.979297; ro_val[4064] = 0.979317; ro_val[4065] = 0.979337; ro_val[4066] = 0.979357; ro_val[4067] = 0.979377; ro_val[4068] = 0.979396; ro_val[4069] = 0.979416; 
ro_val[4070] = 0.979436; ro_val[4071] = 0.979456; ro_val[4072] = 0.979476; ro_val[4073] = 0.979496; ro_val[4074] = 0.979516; ro_val[4075] = 0.979536; ro_val[4076] = 0.979556; ro_val[4077] = 0.979576; ro_val[4078] = 0.979596; ro_val[4079] = 0.979616; 
ro_val[4080] = 0.979636; ro_val[4081] = 0.979656; ro_val[4082] = 0.979676; ro_val[4083] = 0.979696; ro_val[4084] = 0.979716; ro_val[4085] = 0.979736; ro_val[4086] = 0.979756; ro_val[4087] = 0.979776; ro_val[4088] = 0.979796; ro_val[4089] = 0.979816; 
ro_val[4090] = 0.979836; ro_val[4091] = 0.979856; ro_val[4092] = 0.979876; ro_val[4093] = 0.979896; ro_val[4094] = 0.979916; ro_val[4095] = 0.979936; ro_val[4096] = 0.979956; ro_val[4097] = 0.979976; ro_val[4098] = 0.979996; ro_val[4099] = 0.980016; 
ro_val[4100] = 0.980036; ro_val[4101] = 0.980056; ro_val[4102] = 0.980076; ro_val[4103] = 0.980096; ro_val[4104] = 0.980116; ro_val[4105] = 0.980136; ro_val[4106] = 0.980156; ro_val[4107] = 0.980176; ro_val[4108] = 0.980196; ro_val[4109] = 0.980216; 
ro_val[4110] = 0.980236; ro_val[4111] = 0.980256; ro_val[4112] = 0.980276; ro_val[4113] = 0.980296; ro_val[4114] = 0.980316; ro_val[4115] = 0.980336; ro_val[4116] = 0.980356; ro_val[4117] = 0.980376; ro_val[4118] = 0.980396; ro_val[4119] = 0.980416; 
ro_val[4120] = 0.980436; ro_val[4121] = 0.980456; ro_val[4122] = 0.980476; ro_val[4123] = 0.980496; ro_val[4124] = 0.980516; ro_val[4125] = 0.980536; ro_val[4126] = 0.980556; ro_val[4127] = 0.980576; ro_val[4128] = 0.980596; ro_val[4129] = 0.980616; 
ro_val[4130] = 0.980636; ro_val[4131] = 0.980655; ro_val[4132] = 0.980675; ro_val[4133] = 0.980695; ro_val[4134] = 0.980715; ro_val[4135] = 0.980735; ro_val[4136] = 0.980755; ro_val[4137] = 0.980775; ro_val[4138] = 0.980795; ro_val[4139] = 0.980815; 
ro_val[4140] = 0.980835; ro_val[4141] = 0.980855; ro_val[4142] = 0.980875; ro_val[4143] = 0.980895; ro_val[4144] = 0.980915; ro_val[4145] = 0.980935; ro_val[4146] = 0.980955; ro_val[4147] = 0.980975; ro_val[4148] = 0.980995; ro_val[4149] = 0.981015; 
ro_val[4150] = 0.981035; ro_val[4151] = 0.981055; ro_val[4152] = 0.981075; ro_val[4153] = 0.981095; ro_val[4154] = 0.981115; ro_val[4155] = 0.981135; ro_val[4156] = 0.981155; ro_val[4157] = 0.981175; ro_val[4158] = 0.981195; ro_val[4159] = 0.981215; 
ro_val[4160] = 0.981235; ro_val[4161] = 0.981255; ro_val[4162] = 0.981275; ro_val[4163] = 0.981295; ro_val[4164] = 0.981315; ro_val[4165] = 0.981335; ro_val[4166] = 0.981355; ro_val[4167] = 0.981375; ro_val[4168] = 0.981395; ro_val[4169] = 0.981415; 
ro_val[4170] = 0.981435; ro_val[4171] = 0.981455; ro_val[4172] = 0.981475; ro_val[4173] = 0.981495; ro_val[4174] = 0.981515; ro_val[4175] = 0.981535; ro_val[4176] = 0.981555; ro_val[4177] = 0.981575; ro_val[4178] = 0.981595; ro_val[4179] = 0.981615; 
ro_val[4180] = 0.981635; ro_val[4181] = 0.981655; ro_val[4182] = 0.981675; ro_val[4183] = 0.981695; ro_val[4184] = 0.981715; ro_val[4185] = 0.981735; ro_val[4186] = 0.981755; ro_val[4187] = 0.981775; ro_val[4188] = 0.981795; ro_val[4189] = 0.981815; 
ro_val[4190] = 0.981835; ro_val[4191] = 0.981855; ro_val[4192] = 0.981875; ro_val[4193] = 0.981894; ro_val[4194] = 0.981914; ro_val[4195] = 0.981934; ro_val[4196] = 0.981954; ro_val[4197] = 0.981974; ro_val[4198] = 0.981994; ro_val[4199] = 0.982014; 
ro_val[4200] = 0.982034; ro_val[4201] = 0.982054; ro_val[4202] = 0.982074; ro_val[4203] = 0.982094; ro_val[4204] = 0.982114; ro_val[4205] = 0.982134; ro_val[4206] = 0.982154; ro_val[4207] = 0.982174; ro_val[4208] = 0.982194; ro_val[4209] = 0.982214; 
ro_val[4210] = 0.982234; ro_val[4211] = 0.982254; ro_val[4212] = 0.982274; ro_val[4213] = 0.982294; ro_val[4214] = 0.982314; ro_val[4215] = 0.982334; ro_val[4216] = 0.982354; ro_val[4217] = 0.982374; ro_val[4218] = 0.982394; ro_val[4219] = 0.982414; 
ro_val[4220] = 0.982434; ro_val[4221] = 0.982454; ro_val[4222] = 0.982474; ro_val[4223] = 0.982494; ro_val[4224] = 0.982514; ro_val[4225] = 0.982534; ro_val[4226] = 0.982554; ro_val[4227] = 0.982574; ro_val[4228] = 0.982594; ro_val[4229] = 0.982614; 
ro_val[4230] = 0.982634; ro_val[4231] = 0.982654; ro_val[4232] = 0.982674; ro_val[4233] = 0.982694; ro_val[4234] = 0.982714; ro_val[4235] = 0.982734; ro_val[4236] = 0.982754; ro_val[4237] = 0.982774; ro_val[4238] = 0.982794; ro_val[4239] = 0.982814; 
ro_val[4240] = 0.982834; ro_val[4241] = 0.982854; ro_val[4242] = 0.982874; ro_val[4243] = 0.982894; ro_val[4244] = 0.982914; ro_val[4245] = 0.982934; ro_val[4246] = 0.982954; ro_val[4247] = 0.982974; ro_val[4248] = 0.982994; ro_val[4249] = 0.983014; 
ro_val[4250] = 0.983034; ro_val[4251] = 0.983054; ro_val[4252] = 0.983074; ro_val[4253] = 0.983094; ro_val[4254] = 0.983114; ro_val[4255] = 0.983134; ro_val[4256] = 0.983153; ro_val[4257] = 0.983173; ro_val[4258] = 0.983193; ro_val[4259] = 0.983213; 
ro_val[4260] = 0.983233; ro_val[4261] = 0.983253; ro_val[4262] = 0.983273; ro_val[4263] = 0.983293; ro_val[4264] = 0.983313; ro_val[4265] = 0.983333; ro_val[4266] = 0.983353; ro_val[4267] = 0.983373; ro_val[4268] = 0.983393; ro_val[4269] = 0.983413; 
ro_val[4270] = 0.983433; ro_val[4271] = 0.983453; ro_val[4272] = 0.983473; ro_val[4273] = 0.983493; ro_val[4274] = 0.983513; ro_val[4275] = 0.983533; ro_val[4276] = 0.983553; ro_val[4277] = 0.983573; ro_val[4278] = 0.983593; ro_val[4279] = 0.983613; 
ro_val[4280] = 0.983633; ro_val[4281] = 0.983653; ro_val[4282] = 0.983673; ro_val[4283] = 0.983693; ro_val[4284] = 0.983713; ro_val[4285] = 0.983733; ro_val[4286] = 0.983753; ro_val[4287] = 0.983773; ro_val[4288] = 0.983793; ro_val[4289] = 0.983813; 
ro_val[4290] = 0.983833; ro_val[4291] = 0.983853; ro_val[4292] = 0.983873; ro_val[4293] = 0.983893; ro_val[4294] = 0.983913; ro_val[4295] = 0.983933; ro_val[4296] = 0.983953; ro_val[4297] = 0.983973; ro_val[4298] = 0.983993; ro_val[4299] = 0.984013; 
ro_val[4300] = 0.984033; ro_val[4301] = 0.984053; ro_val[4302] = 0.984073; ro_val[4303] = 0.984093; ro_val[4304] = 0.984113; ro_val[4305] = 0.984133; ro_val[4306] = 0.984153; ro_val[4307] = 0.984173; ro_val[4308] = 0.984193; ro_val[4309] = 0.984213; 
ro_val[4310] = 0.984233; ro_val[4311] = 0.984253; ro_val[4312] = 0.984273; ro_val[4313] = 0.984293; ro_val[4314] = 0.984313; ro_val[4315] = 0.984333; ro_val[4316] = 0.984353; ro_val[4317] = 0.984373; ro_val[4318] = 0.984392; ro_val[4319] = 0.984412; 
ro_val[4320] = 0.984432; ro_val[4321] = 0.984452; ro_val[4322] = 0.984472; ro_val[4323] = 0.984492; ro_val[4324] = 0.984512; ro_val[4325] = 0.984532; ro_val[4326] = 0.984552; ro_val[4327] = 0.984572; ro_val[4328] = 0.984592; ro_val[4329] = 0.984612; 
ro_val[4330] = 0.984632; ro_val[4331] = 0.984652; ro_val[4332] = 0.984672; ro_val[4333] = 0.984692; ro_val[4334] = 0.984712; ro_val[4335] = 0.984732; ro_val[4336] = 0.984752; ro_val[4337] = 0.984772; ro_val[4338] = 0.984792; ro_val[4339] = 0.984812; 
ro_val[4340] = 0.984832; ro_val[4341] = 0.984852; ro_val[4342] = 0.984872; ro_val[4343] = 0.984892; ro_val[4344] = 0.984912; ro_val[4345] = 0.984932; ro_val[4346] = 0.984952; ro_val[4347] = 0.984972; ro_val[4348] = 0.984992; ro_val[4349] = 0.985012; 
ro_val[4350] = 0.985032; ro_val[4351] = 0.985052; ro_val[4352] = 0.985072; ro_val[4353] = 0.985092; ro_val[4354] = 0.985112; ro_val[4355] = 0.985132; ro_val[4356] = 0.985152; ro_val[4357] = 0.985172; ro_val[4358] = 0.985192; ro_val[4359] = 0.985212; 
ro_val[4360] = 0.985232; ro_val[4361] = 0.985252; ro_val[4362] = 0.985272; ro_val[4363] = 0.985292; ro_val[4364] = 0.985312; ro_val[4365] = 0.985332; ro_val[4366] = 0.985352; ro_val[4367] = 0.985372; ro_val[4368] = 0.985392; ro_val[4369] = 0.985412; 
ro_val[4370] = 0.985432; ro_val[4371] = 0.985452; ro_val[4372] = 0.985472; ro_val[4373] = 0.985492; ro_val[4374] = 0.985512; ro_val[4375] = 0.985532; ro_val[4376] = 0.985552; ro_val[4377] = 0.985572; ro_val[4378] = 0.985592; ro_val[4379] = 0.985612; 
ro_val[4380] = 0.985632; ro_val[4381] = 0.985651; ro_val[4382] = 0.985671; ro_val[4383] = 0.985691; ro_val[4384] = 0.985711; ro_val[4385] = 0.985731; ro_val[4386] = 0.985751; ro_val[4387] = 0.985771; ro_val[4388] = 0.985791; ro_val[4389] = 0.985811; 
ro_val[4390] = 0.985831; ro_val[4391] = 0.985851; ro_val[4392] = 0.985871; ro_val[4393] = 0.985891; ro_val[4394] = 0.985911; ro_val[4395] = 0.985931; ro_val[4396] = 0.985951; ro_val[4397] = 0.985971; ro_val[4398] = 0.985991; ro_val[4399] = 0.986011; 
ro_val[4400] = 0.986031; ro_val[4401] = 0.986051; ro_val[4402] = 0.986071; ro_val[4403] = 0.986091; ro_val[4404] = 0.986111; ro_val[4405] = 0.986131; ro_val[4406] = 0.986151; ro_val[4407] = 0.986171; ro_val[4408] = 0.986191; ro_val[4409] = 0.986211; 
ro_val[4410] = 0.986231; ro_val[4411] = 0.986251; ro_val[4412] = 0.986271; ro_val[4413] = 0.986291; ro_val[4414] = 0.986311; ro_val[4415] = 0.986331; ro_val[4416] = 0.986351; ro_val[4417] = 0.986371; ro_val[4418] = 0.986391; ro_val[4419] = 0.986411; 
ro_val[4420] = 0.986431; ro_val[4421] = 0.986451; ro_val[4422] = 0.986471; ro_val[4423] = 0.986491; ro_val[4424] = 0.986511; ro_val[4425] = 0.986531; ro_val[4426] = 0.986551; ro_val[4427] = 0.986571; ro_val[4428] = 0.986591; ro_val[4429] = 0.986611; 
ro_val[4430] = 0.986631; ro_val[4431] = 0.986651; ro_val[4432] = 0.986671; ro_val[4433] = 0.986691; ro_val[4434] = 0.986711; ro_val[4435] = 0.986731; ro_val[4436] = 0.986751; ro_val[4437] = 0.986771; ro_val[4438] = 0.986791; ro_val[4439] = 0.986811; 
ro_val[4440] = 0.986831; ro_val[4441] = 0.986851; ro_val[4442] = 0.986871; ro_val[4443] = 0.986890; ro_val[4444] = 0.986910; ro_val[4445] = 0.986930; ro_val[4446] = 0.986950; ro_val[4447] = 0.986970; ro_val[4448] = 0.986990; ro_val[4449] = 0.987010; 
ro_val[4450] = 0.987030; ro_val[4451] = 0.987050; ro_val[4452] = 0.987070; ro_val[4453] = 0.987090; ro_val[4454] = 0.987110; ro_val[4455] = 0.987130; ro_val[4456] = 0.987150; ro_val[4457] = 0.987170; ro_val[4458] = 0.987190; ro_val[4459] = 0.987210; 
ro_val[4460] = 0.987230; ro_val[4461] = 0.987250; ro_val[4462] = 0.987270; ro_val[4463] = 0.987290; ro_val[4464] = 0.987310; ro_val[4465] = 0.987330; ro_val[4466] = 0.987350; ro_val[4467] = 0.987370; ro_val[4468] = 0.987390; ro_val[4469] = 0.987410; 
ro_val[4470] = 0.987430; ro_val[4471] = 0.987450; ro_val[4472] = 0.987470; ro_val[4473] = 0.987490; ro_val[4474] = 0.987510; ro_val[4475] = 0.987530; ro_val[4476] = 0.987550; ro_val[4477] = 0.987570; ro_val[4478] = 0.987590; ro_val[4479] = 0.987610; 
ro_val[4480] = 0.987630; ro_val[4481] = 0.987650; ro_val[4482] = 0.987670; ro_val[4483] = 0.987690; ro_val[4484] = 0.987710; ro_val[4485] = 0.987730; ro_val[4486] = 0.987750; ro_val[4487] = 0.987770; ro_val[4488] = 0.987790; ro_val[4489] = 0.987810; 
ro_val[4490] = 0.987830; ro_val[4491] = 0.987850; ro_val[4492] = 0.987870; ro_val[4493] = 0.987890; ro_val[4494] = 0.987910; ro_val[4495] = 0.987930; ro_val[4496] = 0.987950; ro_val[4497] = 0.987970; ro_val[4498] = 0.987990; ro_val[4499] = 0.988010; 
ro_val[4500] = 0.988030; ro_val[4501] = 0.988050; ro_val[4502] = 0.988070; ro_val[4503] = 0.988090; ro_val[4504] = 0.988110; ro_val[4505] = 0.988130; ro_val[4506] = 0.988149; ro_val[4507] = 0.988169; ro_val[4508] = 0.988189; ro_val[4509] = 0.988209; 
ro_val[4510] = 0.988229; ro_val[4511] = 0.988249; ro_val[4512] = 0.988269; ro_val[4513] = 0.988289; ro_val[4514] = 0.988309; ro_val[4515] = 0.988329; ro_val[4516] = 0.988349; ro_val[4517] = 0.988369; ro_val[4518] = 0.988389; ro_val[4519] = 0.988409; 
ro_val[4520] = 0.988429; ro_val[4521] = 0.988449; ro_val[4522] = 0.988469; ro_val[4523] = 0.988489; ro_val[4524] = 0.988509; ro_val[4525] = 0.988529; ro_val[4526] = 0.988549; ro_val[4527] = 0.988569; ro_val[4528] = 0.988589; ro_val[4529] = 0.988609; 
ro_val[4530] = 0.988629; ro_val[4531] = 0.988649; ro_val[4532] = 0.988669; ro_val[4533] = 0.988689; ro_val[4534] = 0.988709; ro_val[4535] = 0.988729; ro_val[4536] = 0.988749; ro_val[4537] = 0.988769; ro_val[4538] = 0.988789; ro_val[4539] = 0.988809; 
ro_val[4540] = 0.988829; ro_val[4541] = 0.988849; ro_val[4542] = 0.988869; ro_val[4543] = 0.988889; ro_val[4544] = 0.988909; ro_val[4545] = 0.988929; ro_val[4546] = 0.988949; ro_val[4547] = 0.988969; ro_val[4548] = 0.988989; ro_val[4549] = 0.989009; 
ro_val[4550] = 0.989029; ro_val[4551] = 0.989049; ro_val[4552] = 0.989069; ro_val[4553] = 0.989089; ro_val[4554] = 0.989109; ro_val[4555] = 0.989129; ro_val[4556] = 0.989149; ro_val[4557] = 0.989169; ro_val[4558] = 0.989189; ro_val[4559] = 0.989209; 
ro_val[4560] = 0.989229; ro_val[4561] = 0.989249; ro_val[4562] = 0.989269; ro_val[4563] = 0.989289; ro_val[4564] = 0.989309; ro_val[4565] = 0.989329; ro_val[4566] = 0.989349; ro_val[4567] = 0.989369; ro_val[4568] = 0.989388; ro_val[4569] = 0.989408; 
ro_val[4570] = 0.989428; ro_val[4571] = 0.989448; ro_val[4572] = 0.989468; ro_val[4573] = 0.989488; ro_val[4574] = 0.989508; ro_val[4575] = 0.989528; ro_val[4576] = 0.989548; ro_val[4577] = 0.989568; ro_val[4578] = 0.989588; ro_val[4579] = 0.989608; 
ro_val[4580] = 0.989628; ro_val[4581] = 0.989648; ro_val[4582] = 0.989668; ro_val[4583] = 0.989688; ro_val[4584] = 0.989708; ro_val[4585] = 0.989728; ro_val[4586] = 0.989748; ro_val[4587] = 0.989768; ro_val[4588] = 0.989788; ro_val[4589] = 0.989808; 
ro_val[4590] = 0.989828; ro_val[4591] = 0.989848; ro_val[4592] = 0.989868; ro_val[4593] = 0.989888; ro_val[4594] = 0.989908; ro_val[4595] = 0.989928; ro_val[4596] = 0.989948; ro_val[4597] = 0.989968; ro_val[4598] = 0.989988; ro_val[4599] = 0.990008; 
ro_val[4600] = 0.990028; ro_val[4601] = 0.990048; ro_val[4602] = 0.990068; ro_val[4603] = 0.990088; ro_val[4604] = 0.990108; ro_val[4605] = 0.990128; ro_val[4606] = 0.990148; ro_val[4607] = 0.990168; ro_val[4608] = 0.990188; ro_val[4609] = 0.990208; 
ro_val[4610] = 0.990228; ro_val[4611] = 0.990248; ro_val[4612] = 0.990268; ro_val[4613] = 0.990288; ro_val[4614] = 0.990308; ro_val[4615] = 0.990328; ro_val[4616] = 0.990348; ro_val[4617] = 0.990368; ro_val[4618] = 0.990388; ro_val[4619] = 0.990408; 
ro_val[4620] = 0.990428; ro_val[4621] = 0.990448; ro_val[4622] = 0.990468; ro_val[4623] = 0.990488; ro_val[4624] = 0.990508; ro_val[4625] = 0.990528; ro_val[4626] = 0.990548; ro_val[4627] = 0.990568; ro_val[4628] = 0.990588; ro_val[4629] = 0.990608; 
ro_val[4630] = 0.990628; ro_val[4631] = 0.990647; ro_val[4632] = 0.990667; ro_val[4633] = 0.990687; ro_val[4634] = 0.990707; ro_val[4635] = 0.990727; ro_val[4636] = 0.990747; ro_val[4637] = 0.990767; ro_val[4638] = 0.990787; ro_val[4639] = 0.990807; 
ro_val[4640] = 0.990827; ro_val[4641] = 0.990847; ro_val[4642] = 0.990867; ro_val[4643] = 0.990887; ro_val[4644] = 0.990907; ro_val[4645] = 0.990927; ro_val[4646] = 0.990947; ro_val[4647] = 0.990967; ro_val[4648] = 0.990987; ro_val[4649] = 0.991007; 
ro_val[4650] = 0.991027; ro_val[4651] = 0.991047; ro_val[4652] = 0.991067; ro_val[4653] = 0.991087; ro_val[4654] = 0.991107; ro_val[4655] = 0.991127; ro_val[4656] = 0.991147; ro_val[4657] = 0.991167; ro_val[4658] = 0.991187; ro_val[4659] = 0.991207; 
ro_val[4660] = 0.991227; ro_val[4661] = 0.991247; ro_val[4662] = 0.991267; ro_val[4663] = 0.991287; ro_val[4664] = 0.991307; ro_val[4665] = 0.991327; ro_val[4666] = 0.991347; ro_val[4667] = 0.991367; ro_val[4668] = 0.991387; ro_val[4669] = 0.991407; 
ro_val[4670] = 0.991427; ro_val[4671] = 0.991447; ro_val[4672] = 0.991467; ro_val[4673] = 0.991487; ro_val[4674] = 0.991507; ro_val[4675] = 0.991527; ro_val[4676] = 0.991547; ro_val[4677] = 0.991567; ro_val[4678] = 0.991587; ro_val[4679] = 0.991607; 
ro_val[4680] = 0.991627; ro_val[4681] = 0.991647; ro_val[4682] = 0.991667; ro_val[4683] = 0.991687; ro_val[4684] = 0.991707; ro_val[4685] = 0.991727; ro_val[4686] = 0.991747; ro_val[4687] = 0.991767; ro_val[4688] = 0.991787; ro_val[4689] = 0.991807; 
ro_val[4690] = 0.991827; ro_val[4691] = 0.991847; ro_val[4692] = 0.991867; ro_val[4693] = 0.991886; ro_val[4694] = 0.991906; ro_val[4695] = 0.991926; ro_val[4696] = 0.991946; ro_val[4697] = 0.991966; ro_val[4698] = 0.991986; ro_val[4699] = 0.992006; 
ro_val[4700] = 0.992026; ro_val[4701] = 0.992046; ro_val[4702] = 0.992066; ro_val[4703] = 0.992086; ro_val[4704] = 0.992106; ro_val[4705] = 0.992126; ro_val[4706] = 0.992146; ro_val[4707] = 0.992166; ro_val[4708] = 0.992186; ro_val[4709] = 0.992206; 
ro_val[4710] = 0.992226; ro_val[4711] = 0.992246; ro_val[4712] = 0.992266; ro_val[4713] = 0.992286; ro_val[4714] = 0.992306; ro_val[4715] = 0.992326; ro_val[4716] = 0.992346; ro_val[4717] = 0.992366; ro_val[4718] = 0.992386; ro_val[4719] = 0.992406; 
ro_val[4720] = 0.992426; ro_val[4721] = 0.992446; ro_val[4722] = 0.992466; ro_val[4723] = 0.992486; ro_val[4724] = 0.992506; ro_val[4725] = 0.992526; ro_val[4726] = 0.992546; ro_val[4727] = 0.992566; ro_val[4728] = 0.992586; ro_val[4729] = 0.992606; 
ro_val[4730] = 0.992626; ro_val[4731] = 0.992646; ro_val[4732] = 0.992666; ro_val[4733] = 0.992686; ro_val[4734] = 0.992706; ro_val[4735] = 0.992726; ro_val[4736] = 0.992746; ro_val[4737] = 0.992766; ro_val[4738] = 0.992786; ro_val[4739] = 0.992806; 
ro_val[4740] = 0.992826; ro_val[4741] = 0.992846; ro_val[4742] = 0.992866; ro_val[4743] = 0.992886; ro_val[4744] = 0.992906; ro_val[4745] = 0.992926; ro_val[4746] = 0.992946; ro_val[4747] = 0.992966; ro_val[4748] = 0.992986; ro_val[4749] = 0.993006; 
ro_val[4750] = 0.993026; ro_val[4751] = 0.993046; ro_val[4752] = 0.993066; ro_val[4753] = 0.993086; ro_val[4754] = 0.993106; ro_val[4755] = 0.993126; ro_val[4756] = 0.993145; ro_val[4757] = 0.993165; ro_val[4758] = 0.993185; ro_val[4759] = 0.993205; 
ro_val[4760] = 0.993225; ro_val[4761] = 0.993245; ro_val[4762] = 0.993265; ro_val[4763] = 0.993285; ro_val[4764] = 0.993305; ro_val[4765] = 0.993325; ro_val[4766] = 0.993345; ro_val[4767] = 0.993365; ro_val[4768] = 0.993385; ro_val[4769] = 0.993405; 
ro_val[4770] = 0.993425; ro_val[4771] = 0.993445; ro_val[4772] = 0.993465; ro_val[4773] = 0.993485; ro_val[4774] = 0.993505; ro_val[4775] = 0.993525; ro_val[4776] = 0.993545; ro_val[4777] = 0.993565; ro_val[4778] = 0.993585; ro_val[4779] = 0.993605; 
ro_val[4780] = 0.993625; ro_val[4781] = 0.993645; ro_val[4782] = 0.993665; ro_val[4783] = 0.993685; ro_val[4784] = 0.993705; ro_val[4785] = 0.993725; ro_val[4786] = 0.993745; ro_val[4787] = 0.993765; ro_val[4788] = 0.993785; ro_val[4789] = 0.993805; 
ro_val[4790] = 0.993825; ro_val[4791] = 0.993845; ro_val[4792] = 0.993865; ro_val[4793] = 0.993885; ro_val[4794] = 0.993905; ro_val[4795] = 0.993925; ro_val[4796] = 0.993945; ro_val[4797] = 0.993965; ro_val[4798] = 0.993985; ro_val[4799] = 0.994005; 
ro_val[4800] = 0.994025; ro_val[4801] = 0.994045; ro_val[4802] = 0.994065; ro_val[4803] = 0.994085; ro_val[4804] = 0.994105; ro_val[4805] = 0.994125; ro_val[4806] = 0.994145; ro_val[4807] = 0.994165; ro_val[4808] = 0.994185; ro_val[4809] = 0.994205; 
ro_val[4810] = 0.994225; ro_val[4811] = 0.994245; ro_val[4812] = 0.994265; ro_val[4813] = 0.994285; ro_val[4814] = 0.994305; ro_val[4815] = 0.994325; ro_val[4816] = 0.994345; ro_val[4817] = 0.994365; ro_val[4818] = 0.994384; ro_val[4819] = 0.994404; 
ro_val[4820] = 0.994424; ro_val[4821] = 0.994444; ro_val[4822] = 0.994464; ro_val[4823] = 0.994484; ro_val[4824] = 0.994504; ro_val[4825] = 0.994524; ro_val[4826] = 0.994544; ro_val[4827] = 0.994564; ro_val[4828] = 0.994584; ro_val[4829] = 0.994604; 
ro_val[4830] = 0.994624; ro_val[4831] = 0.994644; ro_val[4832] = 0.994664; ro_val[4833] = 0.994684; ro_val[4834] = 0.994704; ro_val[4835] = 0.994724; ro_val[4836] = 0.994744; ro_val[4837] = 0.994764; ro_val[4838] = 0.994784; ro_val[4839] = 0.994804; 
ro_val[4840] = 0.994824; ro_val[4841] = 0.994844; ro_val[4842] = 0.994864; ro_val[4843] = 0.994884; ro_val[4844] = 0.994904; ro_val[4845] = 0.994924; ro_val[4846] = 0.994944; ro_val[4847] = 0.994964; ro_val[4848] = 0.994984; ro_val[4849] = 0.995004; 
ro_val[4850] = 0.995024; ro_val[4851] = 0.995044; ro_val[4852] = 0.995064; ro_val[4853] = 0.995084; ro_val[4854] = 0.995104; ro_val[4855] = 0.995124; ro_val[4856] = 0.995144; ro_val[4857] = 0.995164; ro_val[4858] = 0.995184; ro_val[4859] = 0.995204; 
ro_val[4860] = 0.995224; ro_val[4861] = 0.995244; ro_val[4862] = 0.995264; ro_val[4863] = 0.995284; ro_val[4864] = 0.995304; ro_val[4865] = 0.995324; ro_val[4866] = 0.995344; ro_val[4867] = 0.995364; ro_val[4868] = 0.995384; ro_val[4869] = 0.995404; 
ro_val[4870] = 0.995424; ro_val[4871] = 0.995444; ro_val[4872] = 0.995464; ro_val[4873] = 0.995484; ro_val[4874] = 0.995504; ro_val[4875] = 0.995524; ro_val[4876] = 0.995544; ro_val[4877] = 0.995564; ro_val[4878] = 0.995584; ro_val[4879] = 0.995604; 
ro_val[4880] = 0.995624; ro_val[4881] = 0.995643; ro_val[4882] = 0.995663; ro_val[4883] = 0.995683; ro_val[4884] = 0.995703; ro_val[4885] = 0.995723; ro_val[4886] = 0.995743; ro_val[4887] = 0.995763; ro_val[4888] = 0.995783; ro_val[4889] = 0.995803; 
ro_val[4890] = 0.995823; ro_val[4891] = 0.995843; ro_val[4892] = 0.995863; ro_val[4893] = 0.995883; ro_val[4894] = 0.995903; ro_val[4895] = 0.995923; ro_val[4896] = 0.995943; ro_val[4897] = 0.995963; ro_val[4898] = 0.995983; ro_val[4899] = 0.996003; 
ro_val[4900] = 0.996023; ro_val[4901] = 0.996043; ro_val[4902] = 0.996063; ro_val[4903] = 0.996083; ro_val[4904] = 0.996103; ro_val[4905] = 0.996123; ro_val[4906] = 0.996143; ro_val[4907] = 0.996163; ro_val[4908] = 0.996183; ro_val[4909] = 0.996203; 
ro_val[4910] = 0.996223; ro_val[4911] = 0.996243; ro_val[4912] = 0.996263; ro_val[4913] = 0.996283; ro_val[4914] = 0.996303; ro_val[4915] = 0.996323; ro_val[4916] = 0.996343; ro_val[4917] = 0.996363; ro_val[4918] = 0.996383; ro_val[4919] = 0.996403; 
ro_val[4920] = 0.996423; ro_val[4921] = 0.996443; ro_val[4922] = 0.996463; ro_val[4923] = 0.996483; ro_val[4924] = 0.996503; ro_val[4925] = 0.996523; ro_val[4926] = 0.996543; ro_val[4927] = 0.996563; ro_val[4928] = 0.996583; ro_val[4929] = 0.996603; 
ro_val[4930] = 0.996623; ro_val[4931] = 0.996643; ro_val[4932] = 0.996663; ro_val[4933] = 0.996683; ro_val[4934] = 0.996703; ro_val[4935] = 0.996723; ro_val[4936] = 0.996743; ro_val[4937] = 0.996763; ro_val[4938] = 0.996783; ro_val[4939] = 0.996803; 
ro_val[4940] = 0.996823; ro_val[4941] = 0.996843; ro_val[4942] = 0.996863; ro_val[4943] = 0.996882; ro_val[4944] = 0.996902; ro_val[4945] = 0.996922; ro_val[4946] = 0.996942; ro_val[4947] = 0.996962; ro_val[4948] = 0.996982; ro_val[4949] = 0.997002; 
ro_val[4950] = 0.997022; ro_val[4951] = 0.997042; ro_val[4952] = 0.997062; ro_val[4953] = 0.997082; ro_val[4954] = 0.997102; ro_val[4955] = 0.997122; ro_val[4956] = 0.997142; ro_val[4957] = 0.997162; ro_val[4958] = 0.997182; ro_val[4959] = 0.997202; 
ro_val[4960] = 0.997222; ro_val[4961] = 0.997242; ro_val[4962] = 0.997262; ro_val[4963] = 0.997282; ro_val[4964] = 0.997302; ro_val[4965] = 0.997322; ro_val[4966] = 0.997342; ro_val[4967] = 0.997362; ro_val[4968] = 0.997382; ro_val[4969] = 0.997402; 
ro_val[4970] = 0.997422; ro_val[4971] = 0.997442; ro_val[4972] = 0.997462; ro_val[4973] = 0.997482; ro_val[4974] = 0.997502; ro_val[4975] = 0.997522; ro_val[4976] = 0.997542; ro_val[4977] = 0.997562; ro_val[4978] = 0.997582; ro_val[4979] = 0.997602; 
ro_val[4980] = 0.997622; ro_val[4981] = 0.997642; ro_val[4982] = 0.997662; ro_val[4983] = 0.997682; ro_val[4984] = 0.997702; ro_val[4985] = 0.997722; ro_val[4986] = 0.997742; ro_val[4987] = 0.997762; ro_val[4988] = 0.997782; ro_val[4989] = 0.997802; 
ro_val[4990] = 0.997822; ro_val[4991] = 0.997842; ro_val[4992] = 0.997862; ro_val[4993] = 0.997882; ro_val[4994] = 0.997902; ro_val[4995] = 0.997922; ro_val[4996] = 0.997942; ro_val[4997] = 0.997962; ro_val[4998] = 0.997982; ro_val[4999] = 0.998002; 
ro_val[5000] = 0.998022; ro_val[5001] = 0.998042; ro_val[5002] = 0.998062; ro_val[5003] = 0.998082; ro_val[5004] = 0.998102; ro_val[5005] = 0.998122; ro_val[5006] = 0.998141; ro_val[5007] = 0.998161; ro_val[5008] = 0.998181; ro_val[5009] = 0.998201; 
ro_val[5010] = 0.998221; ro_val[5011] = 0.998241; ro_val[5012] = 0.998261; ro_val[5013] = 0.998281; ro_val[5014] = 0.998301; ro_val[5015] = 0.998321; ro_val[5016] = 0.998341; ro_val[5017] = 0.998361; ro_val[5018] = 0.998381; ro_val[5019] = 0.998401; 
ro_val[5020] = 0.998421; ro_val[5021] = 0.998441; ro_val[5022] = 0.998461; ro_val[5023] = 0.998481; ro_val[5024] = 0.998501; ro_val[5025] = 0.998521; ro_val[5026] = 0.998541; ro_val[5027] = 0.998561; ro_val[5028] = 0.998581; ro_val[5029] = 0.998601; 
ro_val[5030] = 0.998621; ro_val[5031] = 0.998641; ro_val[5032] = 0.998661; ro_val[5033] = 0.998681; ro_val[5034] = 0.998701; ro_val[5035] = 0.998721; ro_val[5036] = 0.998741; ro_val[5037] = 0.998761; ro_val[5038] = 0.998781; ro_val[5039] = 0.998801; 
ro_val[5040] = 0.998821; ro_val[5041] = 0.998841; ro_val[5042] = 0.998861; ro_val[5043] = 0.998881; ro_val[5044] = 0.998901; ro_val[5045] = 0.998921; ro_val[5046] = 0.998941; ro_val[5047] = 0.998961; ro_val[5048] = 0.998981; ro_val[5049] = 0.999001; 
ro_val[5050] = 0.999021; ro_val[5051] = 0.999041; ro_val[5052] = 0.999061; ro_val[5053] = 0.999081; ro_val[5054] = 0.999101; ro_val[5055] = 0.999121; ro_val[5056] = 0.999141; ro_val[5057] = 0.999161; ro_val[5058] = 0.999181; ro_val[5059] = 0.999201; 
ro_val[5060] = 0.999221; ro_val[5061] = 0.999241; ro_val[5062] = 0.999261; ro_val[5063] = 0.999281; ro_val[5064] = 0.999301; ro_val[5065] = 0.999321; ro_val[5066] = 0.999341; ro_val[5067] = 0.999361; ro_val[5068] = 0.999380; ro_val[5069] = 0.999400; 
ro_val[5070] = 0.999420; ro_val[5071] = 0.999440; ro_val[5072] = 0.999460; ro_val[5073] = 0.999480; ro_val[5074] = 0.999500; ro_val[5075] = 0.999520; ro_val[5076] = 0.999540; ro_val[5077] = 0.999560; ro_val[5078] = 0.999580; ro_val[5079] = 0.999600; 
ro_val[5080] = 0.999620; ro_val[5081] = 0.999640; ro_val[5082] = 0.999660; ro_val[5083] = 0.999680; ro_val[5084] = 0.999700; ro_val[5085] = 0.999720; ro_val[5086] = 0.999740; ro_val[5087] = 0.999760; ro_val[5088] = 0.999780; ro_val[5089] = 0.999800; 
ro_val[5090] = 0.999820; ro_val[5091] = 0.999840; ro_val[5092] = 0.999860; ro_val[5093] = 0.999880; ro_val[5094] = 0.999900; ro_val[5095] = 0.999920; ro_val[5096] = 0.999940; ro_val[5097] = 0.999960; ro_val[5098] = 0.999980; ro_val[5099] = 1.000000; 


nc_val[0] = 0.000000; nc_val[1] = 0.007140; nc_val[2] = 0.014281; nc_val[3] = 0.021422; nc_val[4] = 0.028565; nc_val[5] = 0.035709; nc_val[6] = 0.042856; nc_val[7] = 0.050005; nc_val[8] = 0.057158; nc_val[9] = 0.064314; 
nc_val[10] = 0.071474; nc_val[11] = 0.078638; nc_val[12] = 0.085808; nc_val[13] = 0.092983; nc_val[14] = 0.100163; nc_val[15] = 0.107350; nc_val[16] = 0.114544; nc_val[17] = 0.121745; nc_val[18] = 0.128954; nc_val[19] = 0.136171; 
nc_val[20] = 0.143397; nc_val[21] = 0.150632; nc_val[22] = 0.157877; nc_val[23] = 0.165132; nc_val[24] = 0.172398; nc_val[25] = 0.179675; nc_val[26] = 0.186964; nc_val[27] = 0.194265; nc_val[28] = 0.201579; nc_val[29] = 0.208907; 
nc_val[30] = 0.216249; nc_val[31] = 0.223605; nc_val[32] = 0.230977; nc_val[33] = 0.238364; nc_val[34] = 0.245768; nc_val[35] = 0.253189; nc_val[36] = 0.260627; nc_val[37] = 0.268084; nc_val[38] = 0.275560; nc_val[39] = 0.283056; 
nc_val[40] = 0.290572; nc_val[41] = 0.298109; nc_val[42] = 0.305668; nc_val[43] = 0.313249; nc_val[44] = 0.320854; nc_val[45] = 0.328483; nc_val[46] = 0.336138; nc_val[47] = 0.343818; nc_val[48] = 0.351524; nc_val[49] = 0.359259; 
nc_val[50] = 0.367022; nc_val[51] = 0.374814; nc_val[52] = 0.382637; nc_val[53] = 0.390491; nc_val[54] = 0.398378; nc_val[55] = 0.406299; nc_val[56] = 0.414254; nc_val[57] = 0.422245; nc_val[58] = 0.430274; nc_val[59] = 0.438341; 
nc_val[60] = 0.446447; nc_val[61] = 0.454595; nc_val[62] = 0.462785; nc_val[63] = 0.471019; nc_val[64] = 0.479299; nc_val[65] = 0.487626; nc_val[66] = 0.496002; nc_val[67] = 0.504428; nc_val[68] = 0.512907; nc_val[69] = 0.521440; 
nc_val[70] = 0.530030; nc_val[71] = 0.538679; nc_val[72] = 0.547388; nc_val[73] = 0.556161; nc_val[74] = 0.565000; nc_val[75] = 0.573907; nc_val[76] = 0.582886; nc_val[77] = 0.591939; nc_val[78] = 0.601070; nc_val[79] = 0.610282; 
nc_val[80] = 0.619579; nc_val[81] = 0.628964; nc_val[82] = 0.638443; nc_val[83] = 0.648019; nc_val[84] = 0.657698; nc_val[85] = 0.667485; nc_val[86] = 0.677385; nc_val[87] = 0.687405; nc_val[88] = 0.697551; nc_val[89] = 0.707832; 
nc_val[90] = 0.718255; nc_val[91] = 0.728830; nc_val[92] = 0.739567; nc_val[93] = 0.750477; nc_val[94] = 0.761574; nc_val[95] = 0.772871; nc_val[96] = 0.784385; nc_val[97] = 0.796135; nc_val[98] = 0.808143; nc_val[99] = 0.820436; 
nc_val[100] = 0.820573; nc_val[101] = 0.820601; nc_val[102] = 0.820628; nc_val[103] = 0.820655; nc_val[104] = 0.820683; nc_val[105] = 0.820710; nc_val[106] = 0.820737; nc_val[107] = 0.820765; nc_val[108] = 0.820792; nc_val[109] = 0.820820; 
nc_val[110] = 0.820847; nc_val[111] = 0.820874; nc_val[112] = 0.820902; nc_val[113] = 0.820929; nc_val[114] = 0.820957; nc_val[115] = 0.820984; nc_val[116] = 0.821011; nc_val[117] = 0.821039; nc_val[118] = 0.821066; nc_val[119] = 0.821093; 
nc_val[120] = 0.821121; nc_val[121] = 0.821148; nc_val[122] = 0.821176; nc_val[123] = 0.821203; nc_val[124] = 0.821230; nc_val[125] = 0.821258; nc_val[126] = 0.821285; nc_val[127] = 0.821313; nc_val[128] = 0.821340; nc_val[129] = 0.821367; 
nc_val[130] = 0.821395; nc_val[131] = 0.821422; nc_val[132] = 0.821450; nc_val[133] = 0.821477; nc_val[134] = 0.821505; nc_val[135] = 0.821532; nc_val[136] = 0.821559; nc_val[137] = 0.821587; nc_val[138] = 0.821614; nc_val[139] = 0.821642; 
nc_val[140] = 0.821669; nc_val[141] = 0.821697; nc_val[142] = 0.821724; nc_val[143] = 0.821751; nc_val[144] = 0.821779; nc_val[145] = 0.821806; nc_val[146] = 0.821834; nc_val[147] = 0.821861; nc_val[148] = 0.821889; nc_val[149] = 0.821916; 
nc_val[150] = 0.821943; nc_val[151] = 0.821971; nc_val[152] = 0.821998; nc_val[153] = 0.822026; nc_val[154] = 0.822053; nc_val[155] = 0.822081; nc_val[156] = 0.822108; nc_val[157] = 0.822136; nc_val[158] = 0.822163; nc_val[159] = 0.822190; 
nc_val[160] = 0.822218; nc_val[161] = 0.822245; nc_val[162] = 0.822273; nc_val[163] = 0.822300; nc_val[164] = 0.822328; nc_val[165] = 0.822355; nc_val[166] = 0.822383; nc_val[167] = 0.822410; nc_val[168] = 0.822438; nc_val[169] = 0.822465; 
nc_val[170] = 0.822493; nc_val[171] = 0.822520; nc_val[172] = 0.822548; nc_val[173] = 0.822575; nc_val[174] = 0.822602; nc_val[175] = 0.822630; nc_val[176] = 0.822657; nc_val[177] = 0.822685; nc_val[178] = 0.822712; nc_val[179] = 0.822740; 
nc_val[180] = 0.822767; nc_val[181] = 0.822795; nc_val[182] = 0.822822; nc_val[183] = 0.822850; nc_val[184] = 0.822877; nc_val[185] = 0.822905; nc_val[186] = 0.822932; nc_val[187] = 0.822960; nc_val[188] = 0.822987; nc_val[189] = 0.823015; 
nc_val[190] = 0.823042; nc_val[191] = 0.823070; nc_val[192] = 0.823097; nc_val[193] = 0.823125; nc_val[194] = 0.823152; nc_val[195] = 0.823180; nc_val[196] = 0.823207; nc_val[197] = 0.823235; nc_val[198] = 0.823262; nc_val[199] = 0.823290; 
nc_val[200] = 0.823317; nc_val[201] = 0.823345; nc_val[202] = 0.823372; nc_val[203] = 0.823400; nc_val[204] = 0.823428; nc_val[205] = 0.823455; nc_val[206] = 0.823483; nc_val[207] = 0.823510; nc_val[208] = 0.823538; nc_val[209] = 0.823565; 
nc_val[210] = 0.823593; nc_val[211] = 0.823620; nc_val[212] = 0.823648; nc_val[213] = 0.823675; nc_val[214] = 0.823703; nc_val[215] = 0.823730; nc_val[216] = 0.823758; nc_val[217] = 0.823785; nc_val[218] = 0.823813; nc_val[219] = 0.823841; 
nc_val[220] = 0.823868; nc_val[221] = 0.823896; nc_val[222] = 0.823923; nc_val[223] = 0.823951; nc_val[224] = 0.823978; nc_val[225] = 0.824006; nc_val[226] = 0.824033; nc_val[227] = 0.824061; nc_val[228] = 0.824089; nc_val[229] = 0.824116; 
nc_val[230] = 0.824144; nc_val[231] = 0.824171; nc_val[232] = 0.824199; nc_val[233] = 0.824226; nc_val[234] = 0.824254; nc_val[235] = 0.824282; nc_val[236] = 0.824309; nc_val[237] = 0.824337; nc_val[238] = 0.824364; nc_val[239] = 0.824392; 
nc_val[240] = 0.824419; nc_val[241] = 0.824447; nc_val[242] = 0.824475; nc_val[243] = 0.824502; nc_val[244] = 0.824530; nc_val[245] = 0.824557; nc_val[246] = 0.824585; nc_val[247] = 0.824613; nc_val[248] = 0.824640; nc_val[249] = 0.824668; 
nc_val[250] = 0.824695; nc_val[251] = 0.824723; nc_val[252] = 0.824751; nc_val[253] = 0.824778; nc_val[254] = 0.824806; nc_val[255] = 0.824833; nc_val[256] = 0.824861; nc_val[257] = 0.824889; nc_val[258] = 0.824916; nc_val[259] = 0.824944; 
nc_val[260] = 0.824971; nc_val[261] = 0.824999; nc_val[262] = 0.825027; nc_val[263] = 0.825054; nc_val[264] = 0.825082; nc_val[265] = 0.825109; nc_val[266] = 0.825137; nc_val[267] = 0.825165; nc_val[268] = 0.825192; nc_val[269] = 0.825220; 
nc_val[270] = 0.825248; nc_val[271] = 0.825275; nc_val[272] = 0.825303; nc_val[273] = 0.825330; nc_val[274] = 0.825358; nc_val[275] = 0.825386; nc_val[276] = 0.825413; nc_val[277] = 0.825441; nc_val[278] = 0.825469; nc_val[279] = 0.825496; 
nc_val[280] = 0.825524; nc_val[281] = 0.825552; nc_val[282] = 0.825579; nc_val[283] = 0.825607; nc_val[284] = 0.825635; nc_val[285] = 0.825662; nc_val[286] = 0.825690; nc_val[287] = 0.825718; nc_val[288] = 0.825745; nc_val[289] = 0.825773; 
nc_val[290] = 0.825800; nc_val[291] = 0.825828; nc_val[292] = 0.825856; nc_val[293] = 0.825883; nc_val[294] = 0.825911; nc_val[295] = 0.825939; nc_val[296] = 0.825966; nc_val[297] = 0.825994; nc_val[298] = 0.826022; nc_val[299] = 0.826050; 
nc_val[300] = 0.826077; nc_val[301] = 0.826105; nc_val[302] = 0.826133; nc_val[303] = 0.826160; nc_val[304] = 0.826188; nc_val[305] = 0.826216; nc_val[306] = 0.826243; nc_val[307] = 0.826271; nc_val[308] = 0.826299; nc_val[309] = 0.826326; 
nc_val[310] = 0.826354; nc_val[311] = 0.826382; nc_val[312] = 0.826409; nc_val[313] = 0.826437; nc_val[314] = 0.826465; nc_val[315] = 0.826493; nc_val[316] = 0.826520; nc_val[317] = 0.826548; nc_val[318] = 0.826576; nc_val[319] = 0.826603; 
nc_val[320] = 0.826631; nc_val[321] = 0.826659; nc_val[322] = 0.826686; nc_val[323] = 0.826714; nc_val[324] = 0.826742; nc_val[325] = 0.826770; nc_val[326] = 0.826797; nc_val[327] = 0.826825; nc_val[328] = 0.826853; nc_val[329] = 0.826880; 
nc_val[330] = 0.826908; nc_val[331] = 0.826936; nc_val[332] = 0.826964; nc_val[333] = 0.826991; nc_val[334] = 0.827019; nc_val[335] = 0.827047; nc_val[336] = 0.827075; nc_val[337] = 0.827102; nc_val[338] = 0.827130; nc_val[339] = 0.827158; 
nc_val[340] = 0.827186; nc_val[341] = 0.827213; nc_val[342] = 0.827241; nc_val[343] = 0.827269; nc_val[344] = 0.827297; nc_val[345] = 0.827324; nc_val[346] = 0.827352; nc_val[347] = 0.827380; nc_val[348] = 0.827408; nc_val[349] = 0.827435; 
nc_val[350] = 0.827463; nc_val[351] = 0.827491; nc_val[352] = 0.827519; nc_val[353] = 0.827546; nc_val[354] = 0.827574; nc_val[355] = 0.827602; nc_val[356] = 0.827630; nc_val[357] = 0.827657; nc_val[358] = 0.827685; nc_val[359] = 0.827713; 
nc_val[360] = 0.827741; nc_val[361] = 0.827768; nc_val[362] = 0.827796; nc_val[363] = 0.827824; nc_val[364] = 0.827852; nc_val[365] = 0.827880; nc_val[366] = 0.827907; nc_val[367] = 0.827935; nc_val[368] = 0.827963; nc_val[369] = 0.827991; 
nc_val[370] = 0.828018; nc_val[371] = 0.828046; nc_val[372] = 0.828074; nc_val[373] = 0.828102; nc_val[374] = 0.828130; nc_val[375] = 0.828157; nc_val[376] = 0.828185; nc_val[377] = 0.828213; nc_val[378] = 0.828241; nc_val[379] = 0.828269; 
nc_val[380] = 0.828296; nc_val[381] = 0.828324; nc_val[382] = 0.828352; nc_val[383] = 0.828380; nc_val[384] = 0.828408; nc_val[385] = 0.828436; nc_val[386] = 0.828463; nc_val[387] = 0.828491; nc_val[388] = 0.828519; nc_val[389] = 0.828547; 
nc_val[390] = 0.828575; nc_val[391] = 0.828602; nc_val[392] = 0.828630; nc_val[393] = 0.828658; nc_val[394] = 0.828686; nc_val[395] = 0.828714; nc_val[396] = 0.828742; nc_val[397] = 0.828769; nc_val[398] = 0.828797; nc_val[399] = 0.828825; 
nc_val[400] = 0.828853; nc_val[401] = 0.828881; nc_val[402] = 0.828909; nc_val[403] = 0.828936; nc_val[404] = 0.828964; nc_val[405] = 0.828992; nc_val[406] = 0.829020; nc_val[407] = 0.829048; nc_val[408] = 0.829076; nc_val[409] = 0.829104; 
nc_val[410] = 0.829131; nc_val[411] = 0.829159; nc_val[412] = 0.829187; nc_val[413] = 0.829215; nc_val[414] = 0.829243; nc_val[415] = 0.829271; nc_val[416] = 0.829299; nc_val[417] = 0.829326; nc_val[418] = 0.829354; nc_val[419] = 0.829382; 
nc_val[420] = 0.829410; nc_val[421] = 0.829438; nc_val[422] = 0.829466; nc_val[423] = 0.829494; nc_val[424] = 0.829522; nc_val[425] = 0.829549; nc_val[426] = 0.829577; nc_val[427] = 0.829605; nc_val[428] = 0.829633; nc_val[429] = 0.829661; 
nc_val[430] = 0.829689; nc_val[431] = 0.829717; nc_val[432] = 0.829745; nc_val[433] = 0.829772; nc_val[434] = 0.829800; nc_val[435] = 0.829828; nc_val[436] = 0.829856; nc_val[437] = 0.829884; nc_val[438] = 0.829912; nc_val[439] = 0.829940; 
nc_val[440] = 0.829968; nc_val[441] = 0.829996; nc_val[442] = 0.830024; nc_val[443] = 0.830052; nc_val[444] = 0.830079; nc_val[445] = 0.830107; nc_val[446] = 0.830135; nc_val[447] = 0.830163; nc_val[448] = 0.830191; nc_val[449] = 0.830219; 
nc_val[450] = 0.830247; nc_val[451] = 0.830275; nc_val[452] = 0.830303; nc_val[453] = 0.830331; nc_val[454] = 0.830359; nc_val[455] = 0.830387; nc_val[456] = 0.830414; nc_val[457] = 0.830442; nc_val[458] = 0.830470; nc_val[459] = 0.830498; 
nc_val[460] = 0.830526; nc_val[461] = 0.830554; nc_val[462] = 0.830582; nc_val[463] = 0.830610; nc_val[464] = 0.830638; nc_val[465] = 0.830666; nc_val[466] = 0.830694; nc_val[467] = 0.830722; nc_val[468] = 0.830750; nc_val[469] = 0.830778; 
nc_val[470] = 0.830806; nc_val[471] = 0.830834; nc_val[472] = 0.830862; nc_val[473] = 0.830890; nc_val[474] = 0.830917; nc_val[475] = 0.830945; nc_val[476] = 0.830973; nc_val[477] = 0.831001; nc_val[478] = 0.831029; nc_val[479] = 0.831057; 
nc_val[480] = 0.831085; nc_val[481] = 0.831113; nc_val[482] = 0.831141; nc_val[483] = 0.831169; nc_val[484] = 0.831197; nc_val[485] = 0.831225; nc_val[486] = 0.831253; nc_val[487] = 0.831281; nc_val[488] = 0.831309; nc_val[489] = 0.831337; 
nc_val[490] = 0.831365; nc_val[491] = 0.831393; nc_val[492] = 0.831421; nc_val[493] = 0.831449; nc_val[494] = 0.831477; nc_val[495] = 0.831505; nc_val[496] = 0.831533; nc_val[497] = 0.831561; nc_val[498] = 0.831589; nc_val[499] = 0.831617; 
nc_val[500] = 0.831645; nc_val[501] = 0.831673; nc_val[502] = 0.831701; nc_val[503] = 0.831729; nc_val[504] = 0.831757; nc_val[505] = 0.831785; nc_val[506] = 0.831813; nc_val[507] = 0.831841; nc_val[508] = 0.831869; nc_val[509] = 0.831897; 
nc_val[510] = 0.831925; nc_val[511] = 0.831953; nc_val[512] = 0.831981; nc_val[513] = 0.832009; nc_val[514] = 0.832037; nc_val[515] = 0.832065; nc_val[516] = 0.832093; nc_val[517] = 0.832121; nc_val[518] = 0.832149; nc_val[519] = 0.832177; 
nc_val[520] = 0.832205; nc_val[521] = 0.832234; nc_val[522] = 0.832262; nc_val[523] = 0.832290; nc_val[524] = 0.832318; nc_val[525] = 0.832346; nc_val[526] = 0.832374; nc_val[527] = 0.832402; nc_val[528] = 0.832430; nc_val[529] = 0.832458; 
nc_val[530] = 0.832486; nc_val[531] = 0.832514; nc_val[532] = 0.832542; nc_val[533] = 0.832570; nc_val[534] = 0.832598; nc_val[535] = 0.832626; nc_val[536] = 0.832654; nc_val[537] = 0.832682; nc_val[538] = 0.832710; nc_val[539] = 0.832739; 
nc_val[540] = 0.832767; nc_val[541] = 0.832795; nc_val[542] = 0.832823; nc_val[543] = 0.832851; nc_val[544] = 0.832879; nc_val[545] = 0.832907; nc_val[546] = 0.832935; nc_val[547] = 0.832963; nc_val[548] = 0.832991; nc_val[549] = 0.833019; 
nc_val[550] = 0.833047; nc_val[551] = 0.833075; nc_val[552] = 0.833104; nc_val[553] = 0.833132; nc_val[554] = 0.833160; nc_val[555] = 0.833188; nc_val[556] = 0.833216; nc_val[557] = 0.833244; nc_val[558] = 0.833272; nc_val[559] = 0.833300; 
nc_val[560] = 0.833328; nc_val[561] = 0.833356; nc_val[562] = 0.833385; nc_val[563] = 0.833413; nc_val[564] = 0.833441; nc_val[565] = 0.833469; nc_val[566] = 0.833497; nc_val[567] = 0.833525; nc_val[568] = 0.833553; nc_val[569] = 0.833581; 
nc_val[570] = 0.833610; nc_val[571] = 0.833638; nc_val[572] = 0.833666; nc_val[573] = 0.833694; nc_val[574] = 0.833722; nc_val[575] = 0.833750; nc_val[576] = 0.833778; nc_val[577] = 0.833806; nc_val[578] = 0.833835; nc_val[579] = 0.833863; 
nc_val[580] = 0.833891; nc_val[581] = 0.833919; nc_val[582] = 0.833947; nc_val[583] = 0.833975; nc_val[584] = 0.834003; nc_val[585] = 0.834032; nc_val[586] = 0.834060; nc_val[587] = 0.834088; nc_val[588] = 0.834116; nc_val[589] = 0.834144; 
nc_val[590] = 0.834172; nc_val[591] = 0.834200; nc_val[592] = 0.834229; nc_val[593] = 0.834257; nc_val[594] = 0.834285; nc_val[595] = 0.834313; nc_val[596] = 0.834341; nc_val[597] = 0.834369; nc_val[598] = 0.834398; nc_val[599] = 0.834426; 
nc_val[600] = 0.834454; nc_val[601] = 0.834482; nc_val[602] = 0.834510; nc_val[603] = 0.834539; nc_val[604] = 0.834567; nc_val[605] = 0.834595; nc_val[606] = 0.834623; nc_val[607] = 0.834651; nc_val[608] = 0.834679; nc_val[609] = 0.834708; 
nc_val[610] = 0.834736; nc_val[611] = 0.834764; nc_val[612] = 0.834792; nc_val[613] = 0.834820; nc_val[614] = 0.834849; nc_val[615] = 0.834877; nc_val[616] = 0.834905; nc_val[617] = 0.834933; nc_val[618] = 0.834961; nc_val[619] = 0.834990; 
nc_val[620] = 0.835018; nc_val[621] = 0.835046; nc_val[622] = 0.835074; nc_val[623] = 0.835102; nc_val[624] = 0.835131; nc_val[625] = 0.835159; nc_val[626] = 0.835187; nc_val[627] = 0.835215; nc_val[628] = 0.835244; nc_val[629] = 0.835272; 
nc_val[630] = 0.835300; nc_val[631] = 0.835328; nc_val[632] = 0.835356; nc_val[633] = 0.835385; nc_val[634] = 0.835413; nc_val[635] = 0.835441; nc_val[636] = 0.835469; nc_val[637] = 0.835498; nc_val[638] = 0.835526; nc_val[639] = 0.835554; 
nc_val[640] = 0.835582; nc_val[641] = 0.835611; nc_val[642] = 0.835639; nc_val[643] = 0.835667; nc_val[644] = 0.835695; nc_val[645] = 0.835724; nc_val[646] = 0.835752; nc_val[647] = 0.835780; nc_val[648] = 0.835808; nc_val[649] = 0.835837; 
nc_val[650] = 0.835865; nc_val[651] = 0.835893; nc_val[652] = 0.835921; nc_val[653] = 0.835950; nc_val[654] = 0.835978; nc_val[655] = 0.836006; nc_val[656] = 0.836034; nc_val[657] = 0.836063; nc_val[658] = 0.836091; nc_val[659] = 0.836119; 
nc_val[660] = 0.836148; nc_val[661] = 0.836176; nc_val[662] = 0.836204; nc_val[663] = 0.836232; nc_val[664] = 0.836261; nc_val[665] = 0.836289; nc_val[666] = 0.836317; nc_val[667] = 0.836346; nc_val[668] = 0.836374; nc_val[669] = 0.836402; 
nc_val[670] = 0.836430; nc_val[671] = 0.836459; nc_val[672] = 0.836487; nc_val[673] = 0.836515; nc_val[674] = 0.836544; nc_val[675] = 0.836572; nc_val[676] = 0.836600; nc_val[677] = 0.836629; nc_val[678] = 0.836657; nc_val[679] = 0.836685; 
nc_val[680] = 0.836714; nc_val[681] = 0.836742; nc_val[682] = 0.836770; nc_val[683] = 0.836798; nc_val[684] = 0.836827; nc_val[685] = 0.836855; nc_val[686] = 0.836883; nc_val[687] = 0.836912; nc_val[688] = 0.836940; nc_val[689] = 0.836968; 
nc_val[690] = 0.836997; nc_val[691] = 0.837025; nc_val[692] = 0.837053; nc_val[693] = 0.837082; nc_val[694] = 0.837110; nc_val[695] = 0.837138; nc_val[696] = 0.837167; nc_val[697] = 0.837195; nc_val[698] = 0.837223; nc_val[699] = 0.837252; 
nc_val[700] = 0.837280; nc_val[701] = 0.837309; nc_val[702] = 0.837337; nc_val[703] = 0.837365; nc_val[704] = 0.837394; nc_val[705] = 0.837422; nc_val[706] = 0.837450; nc_val[707] = 0.837479; nc_val[708] = 0.837507; nc_val[709] = 0.837535; 
nc_val[710] = 0.837564; nc_val[711] = 0.837592; nc_val[712] = 0.837620; nc_val[713] = 0.837649; nc_val[714] = 0.837677; nc_val[715] = 0.837706; nc_val[716] = 0.837734; nc_val[717] = 0.837762; nc_val[718] = 0.837791; nc_val[719] = 0.837819; 
nc_val[720] = 0.837848; nc_val[721] = 0.837876; nc_val[722] = 0.837904; nc_val[723] = 0.837933; nc_val[724] = 0.837961; nc_val[725] = 0.837989; nc_val[726] = 0.838018; nc_val[727] = 0.838046; nc_val[728] = 0.838075; nc_val[729] = 0.838103; 
nc_val[730] = 0.838131; nc_val[731] = 0.838160; nc_val[732] = 0.838188; nc_val[733] = 0.838217; nc_val[734] = 0.838245; nc_val[735] = 0.838273; nc_val[736] = 0.838302; nc_val[737] = 0.838330; nc_val[738] = 0.838359; nc_val[739] = 0.838387; 
nc_val[740] = 0.838416; nc_val[741] = 0.838444; nc_val[742] = 0.838472; nc_val[743] = 0.838501; nc_val[744] = 0.838529; nc_val[745] = 0.838558; nc_val[746] = 0.838586; nc_val[747] = 0.838615; nc_val[748] = 0.838643; nc_val[749] = 0.838671; 
nc_val[750] = 0.838700; nc_val[751] = 0.838728; nc_val[752] = 0.838757; nc_val[753] = 0.838785; nc_val[754] = 0.838814; nc_val[755] = 0.838842; nc_val[756] = 0.838871; nc_val[757] = 0.838899; nc_val[758] = 0.838927; nc_val[759] = 0.838956; 
nc_val[760] = 0.838984; nc_val[761] = 0.839013; nc_val[762] = 0.839041; nc_val[763] = 0.839070; nc_val[764] = 0.839098; nc_val[765] = 0.839127; nc_val[766] = 0.839155; nc_val[767] = 0.839184; nc_val[768] = 0.839212; nc_val[769] = 0.839241; 
nc_val[770] = 0.839269; nc_val[771] = 0.839297; nc_val[772] = 0.839326; nc_val[773] = 0.839354; nc_val[774] = 0.839383; nc_val[775] = 0.839411; nc_val[776] = 0.839440; nc_val[777] = 0.839468; nc_val[778] = 0.839497; nc_val[779] = 0.839525; 
nc_val[780] = 0.839554; nc_val[781] = 0.839582; nc_val[782] = 0.839611; nc_val[783] = 0.839639; nc_val[784] = 0.839668; nc_val[785] = 0.839696; nc_val[786] = 0.839725; nc_val[787] = 0.839753; nc_val[788] = 0.839782; nc_val[789] = 0.839810; 
nc_val[790] = 0.839839; nc_val[791] = 0.839867; nc_val[792] = 0.839896; nc_val[793] = 0.839924; nc_val[794] = 0.839953; nc_val[795] = 0.839981; nc_val[796] = 0.840010; nc_val[797] = 0.840038; nc_val[798] = 0.840067; nc_val[799] = 0.840096; 
nc_val[800] = 0.840124; nc_val[801] = 0.840153; nc_val[802] = 0.840181; nc_val[803] = 0.840210; nc_val[804] = 0.840238; nc_val[805] = 0.840267; nc_val[806] = 0.840295; nc_val[807] = 0.840324; nc_val[808] = 0.840352; nc_val[809] = 0.840381; 
nc_val[810] = 0.840409; nc_val[811] = 0.840438; nc_val[812] = 0.840467; nc_val[813] = 0.840495; nc_val[814] = 0.840524; nc_val[815] = 0.840552; nc_val[816] = 0.840581; nc_val[817] = 0.840609; nc_val[818] = 0.840638; nc_val[819] = 0.840666; 
nc_val[820] = 0.840695; nc_val[821] = 0.840724; nc_val[822] = 0.840752; nc_val[823] = 0.840781; nc_val[824] = 0.840809; nc_val[825] = 0.840838; nc_val[826] = 0.840866; nc_val[827] = 0.840895; nc_val[828] = 0.840924; nc_val[829] = 0.840952; 
nc_val[830] = 0.840981; nc_val[831] = 0.841009; nc_val[832] = 0.841038; nc_val[833] = 0.841066; nc_val[834] = 0.841095; nc_val[835] = 0.841124; nc_val[836] = 0.841152; nc_val[837] = 0.841181; nc_val[838] = 0.841209; nc_val[839] = 0.841238; 
nc_val[840] = 0.841267; nc_val[841] = 0.841295; nc_val[842] = 0.841324; nc_val[843] = 0.841352; nc_val[844] = 0.841381; nc_val[845] = 0.841410; nc_val[846] = 0.841438; nc_val[847] = 0.841467; nc_val[848] = 0.841496; nc_val[849] = 0.841524; 
nc_val[850] = 0.841553; nc_val[851] = 0.841581; nc_val[852] = 0.841610; nc_val[853] = 0.841639; nc_val[854] = 0.841667; nc_val[855] = 0.841696; nc_val[856] = 0.841725; nc_val[857] = 0.841753; nc_val[858] = 0.841782; nc_val[859] = 0.841810; 
nc_val[860] = 0.841839; nc_val[861] = 0.841868; nc_val[862] = 0.841896; nc_val[863] = 0.841925; nc_val[864] = 0.841954; nc_val[865] = 0.841982; nc_val[866] = 0.842011; nc_val[867] = 0.842040; nc_val[868] = 0.842068; nc_val[869] = 0.842097; 
nc_val[870] = 0.842126; nc_val[871] = 0.842154; nc_val[872] = 0.842183; nc_val[873] = 0.842212; nc_val[874] = 0.842240; nc_val[875] = 0.842269; nc_val[876] = 0.842298; nc_val[877] = 0.842326; nc_val[878] = 0.842355; nc_val[879] = 0.842384; 
nc_val[880] = 0.842412; nc_val[881] = 0.842441; nc_val[882] = 0.842470; nc_val[883] = 0.842498; nc_val[884] = 0.842527; nc_val[885] = 0.842556; nc_val[886] = 0.842584; nc_val[887] = 0.842613; nc_val[888] = 0.842642; nc_val[889] = 0.842670; 
nc_val[890] = 0.842699; nc_val[891] = 0.842728; nc_val[892] = 0.842756; nc_val[893] = 0.842785; nc_val[894] = 0.842814; nc_val[895] = 0.842843; nc_val[896] = 0.842871; nc_val[897] = 0.842900; nc_val[898] = 0.842929; nc_val[899] = 0.842957; 
nc_val[900] = 0.842986; nc_val[901] = 0.843015; nc_val[902] = 0.843044; nc_val[903] = 0.843072; nc_val[904] = 0.843101; nc_val[905] = 0.843130; nc_val[906] = 0.843158; nc_val[907] = 0.843187; nc_val[908] = 0.843216; nc_val[909] = 0.843245; 
nc_val[910] = 0.843273; nc_val[911] = 0.843302; nc_val[912] = 0.843331; nc_val[913] = 0.843360; nc_val[914] = 0.843388; nc_val[915] = 0.843417; nc_val[916] = 0.843446; nc_val[917] = 0.843475; nc_val[918] = 0.843503; nc_val[919] = 0.843532; 
nc_val[920] = 0.843561; nc_val[921] = 0.843589; nc_val[922] = 0.843618; nc_val[923] = 0.843647; nc_val[924] = 0.843676; nc_val[925] = 0.843705; nc_val[926] = 0.843733; nc_val[927] = 0.843762; nc_val[928] = 0.843791; nc_val[929] = 0.843820; 
nc_val[930] = 0.843848; nc_val[931] = 0.843877; nc_val[932] = 0.843906; nc_val[933] = 0.843935; nc_val[934] = 0.843963; nc_val[935] = 0.843992; nc_val[936] = 0.844021; nc_val[937] = 0.844050; nc_val[938] = 0.844079; nc_val[939] = 0.844107; 
nc_val[940] = 0.844136; nc_val[941] = 0.844165; nc_val[942] = 0.844194; nc_val[943] = 0.844223; nc_val[944] = 0.844251; nc_val[945] = 0.844280; nc_val[946] = 0.844309; nc_val[947] = 0.844338; nc_val[948] = 0.844367; nc_val[949] = 0.844395; 
nc_val[950] = 0.844424; nc_val[951] = 0.844453; nc_val[952] = 0.844482; nc_val[953] = 0.844511; nc_val[954] = 0.844539; nc_val[955] = 0.844568; nc_val[956] = 0.844597; nc_val[957] = 0.844626; nc_val[958] = 0.844655; nc_val[959] = 0.844683; 
nc_val[960] = 0.844712; nc_val[961] = 0.844741; nc_val[962] = 0.844770; nc_val[963] = 0.844799; nc_val[964] = 0.844828; nc_val[965] = 0.844856; nc_val[966] = 0.844885; nc_val[967] = 0.844914; nc_val[968] = 0.844943; nc_val[969] = 0.844972; 
nc_val[970] = 0.845001; nc_val[971] = 0.845029; nc_val[972] = 0.845058; nc_val[973] = 0.845087; nc_val[974] = 0.845116; nc_val[975] = 0.845145; nc_val[976] = 0.845174; nc_val[977] = 0.845203; nc_val[978] = 0.845231; nc_val[979] = 0.845260; 
nc_val[980] = 0.845289; nc_val[981] = 0.845318; nc_val[982] = 0.845347; nc_val[983] = 0.845376; nc_val[984] = 0.845405; nc_val[985] = 0.845434; nc_val[986] = 0.845462; nc_val[987] = 0.845491; nc_val[988] = 0.845520; nc_val[989] = 0.845549; 
nc_val[990] = 0.845578; nc_val[991] = 0.845607; nc_val[992] = 0.845636; nc_val[993] = 0.845665; nc_val[994] = 0.845693; nc_val[995] = 0.845722; nc_val[996] = 0.845751; nc_val[997] = 0.845780; nc_val[998] = 0.845809; nc_val[999] = 0.845838; 
nc_val[1000] = 0.845867; nc_val[1001] = 0.845896; nc_val[1002] = 0.845925; nc_val[1003] = 0.845954; nc_val[1004] = 0.845982; nc_val[1005] = 0.846011; nc_val[1006] = 0.846040; nc_val[1007] = 0.846069; nc_val[1008] = 0.846098; nc_val[1009] = 0.846127; 
nc_val[1010] = 0.846156; nc_val[1011] = 0.846185; nc_val[1012] = 0.846214; nc_val[1013] = 0.846243; nc_val[1014] = 0.846272; nc_val[1015] = 0.846301; nc_val[1016] = 0.846330; nc_val[1017] = 0.846358; nc_val[1018] = 0.846387; nc_val[1019] = 0.846416; 
nc_val[1020] = 0.846445; nc_val[1021] = 0.846474; nc_val[1022] = 0.846503; nc_val[1023] = 0.846532; nc_val[FilePathLength] = 0.846561; nc_val[1025] = 0.846590; nc_val[1026] = 0.846619; nc_val[1027] = 0.846648; nc_val[1028] = 0.846677; nc_val[1029] = 0.846706; 
nc_val[1030] = 0.846735; nc_val[1031] = 0.846764; nc_val[1032] = 0.846793; nc_val[1033] = 0.846822; nc_val[1034] = 0.846851; nc_val[1035] = 0.846880; nc_val[1036] = 0.846909; nc_val[1037] = 0.846938; nc_val[1038] = 0.846967; nc_val[1039] = 0.846996; 
nc_val[1040] = 0.847025; nc_val[1041] = 0.847053; nc_val[1042] = 0.847082; nc_val[1043] = 0.847111; nc_val[1044] = 0.847140; nc_val[1045] = 0.847169; nc_val[1046] = 0.847198; nc_val[1047] = 0.847227; nc_val[1048] = 0.847256; nc_val[1049] = 0.847285; 
nc_val[1050] = 0.847314; nc_val[1051] = 0.847343; nc_val[1052] = 0.847372; nc_val[1053] = 0.847401; nc_val[1054] = 0.847430; nc_val[1055] = 0.847459; nc_val[1056] = 0.847488; nc_val[1057] = 0.847517; nc_val[1058] = 0.847546; nc_val[1059] = 0.847575; 
nc_val[1060] = 0.847605; nc_val[1061] = 0.847634; nc_val[1062] = 0.847663; nc_val[1063] = 0.847692; nc_val[1064] = 0.847721; nc_val[1065] = 0.847750; nc_val[1066] = 0.847779; nc_val[1067] = 0.847808; nc_val[1068] = 0.847837; nc_val[1069] = 0.847866; 
nc_val[1070] = 0.847895; nc_val[1071] = 0.847924; nc_val[1072] = 0.847953; nc_val[1073] = 0.847982; nc_val[1074] = 0.848011; nc_val[1075] = 0.848040; nc_val[1076] = 0.848069; nc_val[1077] = 0.848098; nc_val[1078] = 0.848127; nc_val[1079] = 0.848156; 
nc_val[1080] = 0.848185; nc_val[1081] = 0.848214; nc_val[1082] = 0.848243; nc_val[1083] = 0.848272; nc_val[1084] = 0.848302; nc_val[1085] = 0.848331; nc_val[1086] = 0.848360; nc_val[1087] = 0.848389; nc_val[1088] = 0.848418; nc_val[1089] = 0.848447; 
nc_val[1090] = 0.848476; nc_val[1091] = 0.848505; nc_val[1092] = 0.848534; nc_val[1093] = 0.848563; nc_val[1094] = 0.848592; nc_val[1095] = 0.848621; nc_val[1096] = 0.848650; nc_val[1097] = 0.848680; nc_val[1098] = 0.848709; nc_val[1099] = 0.848738; 
nc_val[1100] = 0.848767; nc_val[1101] = 0.848796; nc_val[1102] = 0.848825; nc_val[1103] = 0.848854; nc_val[1104] = 0.848883; nc_val[1105] = 0.848912; nc_val[1106] = 0.848941; nc_val[1107] = 0.848971; nc_val[1108] = 0.849000; nc_val[1109] = 0.849029; 
nc_val[1110] = 0.849058; nc_val[1111] = 0.849087; nc_val[1112] = 0.849116; nc_val[1113] = 0.849145; nc_val[1114] = 0.849174; nc_val[1115] = 0.849204; nc_val[1116] = 0.849233; nc_val[1117] = 0.849262; nc_val[1118] = 0.849291; nc_val[1119] = 0.849320; 
nc_val[1120] = 0.849349; nc_val[1121] = 0.849378; nc_val[1122] = 0.849407; nc_val[1123] = 0.849437; nc_val[1124] = 0.849466; nc_val[1125] = 0.849495; nc_val[1126] = 0.849524; nc_val[1127] = 0.849553; nc_val[1128] = 0.849582; nc_val[1129] = 0.849611; 
nc_val[1130] = 0.849641; nc_val[1131] = 0.849670; nc_val[1132] = 0.849699; nc_val[1133] = 0.849728; nc_val[1134] = 0.849757; nc_val[1135] = 0.849786; nc_val[1136] = 0.849816; nc_val[1137] = 0.849845; nc_val[1138] = 0.849874; nc_val[1139] = 0.849903; 
nc_val[1140] = 0.849932; nc_val[1141] = 0.849962; nc_val[1142] = 0.849991; nc_val[1143] = 0.850020; nc_val[1144] = 0.850049; nc_val[1145] = 0.850078; nc_val[1146] = 0.850107; nc_val[1147] = 0.850137; nc_val[1148] = 0.850166; nc_val[1149] = 0.850195; 
nc_val[1150] = 0.850224; nc_val[1151] = 0.850253; nc_val[1152] = 0.850283; nc_val[1153] = 0.850312; nc_val[1154] = 0.850341; nc_val[1155] = 0.850370; nc_val[1156] = 0.850399; nc_val[1157] = 0.850429; nc_val[1158] = 0.850458; nc_val[1159] = 0.850487; 
nc_val[1160] = 0.850516; nc_val[1161] = 0.850545; nc_val[1162] = 0.850575; nc_val[1163] = 0.850604; nc_val[1164] = 0.850633; nc_val[1165] = 0.850662; nc_val[1166] = 0.850692; nc_val[1167] = 0.850721; nc_val[1168] = 0.850750; nc_val[1169] = 0.850779; 
nc_val[1170] = 0.850809; nc_val[1171] = 0.850838; nc_val[1172] = 0.850867; nc_val[1173] = 0.850896; nc_val[1174] = 0.850926; nc_val[1175] = 0.850955; nc_val[1176] = 0.850984; nc_val[1177] = 0.851013; nc_val[1178] = 0.851043; nc_val[1179] = 0.851072; 
nc_val[1180] = 0.851101; nc_val[1181] = 0.851130; nc_val[1182] = 0.851160; nc_val[1183] = 0.851189; nc_val[1184] = 0.851218; nc_val[1185] = 0.851247; nc_val[1186] = 0.851277; nc_val[1187] = 0.851306; nc_val[1188] = 0.851335; nc_val[1189] = 0.851364; 
nc_val[1190] = 0.851394; nc_val[1191] = 0.851423; nc_val[1192] = 0.851452; nc_val[1193] = 0.851482; nc_val[1194] = 0.851511; nc_val[1195] = 0.851540; nc_val[1196] = 0.851569; nc_val[1197] = 0.851599; nc_val[1198] = 0.851628; nc_val[1199] = 0.851657; 
nc_val[1200] = 0.851687; nc_val[1201] = 0.851716; nc_val[1202] = 0.851745; nc_val[1203] = 0.851774; nc_val[1204] = 0.851804; nc_val[1205] = 0.851833; nc_val[1206] = 0.851862; nc_val[1207] = 0.851892; nc_val[1208] = 0.851921; nc_val[1209] = 0.851950; 
nc_val[1210] = 0.851980; nc_val[1211] = 0.852009; nc_val[1212] = 0.852038; nc_val[1213] = 0.852068; nc_val[1214] = 0.852097; nc_val[1215] = 0.852126; nc_val[1216] = 0.852156; nc_val[1217] = 0.852185; nc_val[1218] = 0.852214; nc_val[1219] = 0.852244; 
nc_val[1220] = 0.852273; nc_val[1221] = 0.852302; nc_val[1222] = 0.852332; nc_val[1223] = 0.852361; nc_val[1224] = 0.852390; nc_val[1225] = 0.852420; nc_val[1226] = 0.852449; nc_val[1227] = 0.852478; nc_val[1228] = 0.852508; nc_val[1229] = 0.852537; 
nc_val[1230] = 0.852566; nc_val[1231] = 0.852596; nc_val[1232] = 0.852625; nc_val[1233] = 0.852655; nc_val[1234] = 0.852684; nc_val[1235] = 0.852713; nc_val[1236] = 0.852743; nc_val[1237] = 0.852772; nc_val[1238] = 0.852801; nc_val[1239] = 0.852831; 
nc_val[1240] = 0.852860; nc_val[1241] = 0.852890; nc_val[1242] = 0.852919; nc_val[1243] = 0.852948; nc_val[1244] = 0.852978; nc_val[1245] = 0.853007; nc_val[1246] = 0.853036; nc_val[1247] = 0.853066; nc_val[1248] = 0.853095; nc_val[1249] = 0.853125; 
nc_val[1250] = 0.853154; nc_val[1251] = 0.853183; nc_val[1252] = 0.853213; nc_val[1253] = 0.853242; nc_val[1254] = 0.853272; nc_val[1255] = 0.853301; nc_val[1256] = 0.853330; nc_val[1257] = 0.853360; nc_val[1258] = 0.853389; nc_val[1259] = 0.853419; 
nc_val[1260] = 0.853448; nc_val[1261] = 0.853478; nc_val[1262] = 0.853507; nc_val[1263] = 0.853536; nc_val[1264] = 0.853566; nc_val[1265] = 0.853595; nc_val[1266] = 0.853625; nc_val[1267] = 0.853654; nc_val[1268] = 0.853684; nc_val[1269] = 0.853713; 
nc_val[1270] = 0.853742; nc_val[1271] = 0.853772; nc_val[1272] = 0.853801; nc_val[1273] = 0.853831; nc_val[1274] = 0.853860; nc_val[1275] = 0.853890; nc_val[1276] = 0.853919; nc_val[1277] = 0.853949; nc_val[1278] = 0.853978; nc_val[1279] = 0.854008; 
nc_val[1280] = 0.854037; nc_val[1281] = 0.854066; nc_val[1282] = 0.854096; nc_val[1283] = 0.854125; nc_val[1284] = 0.854155; nc_val[1285] = 0.854184; nc_val[1286] = 0.854214; nc_val[1287] = 0.854243; nc_val[1288] = 0.854273; nc_val[1289] = 0.854302; 
nc_val[1290] = 0.854332; nc_val[1291] = 0.854361; nc_val[1292] = 0.854391; nc_val[1293] = 0.854420; nc_val[1294] = 0.854450; nc_val[1295] = 0.854479; nc_val[1296] = 0.854509; nc_val[1297] = 0.854538; nc_val[1298] = 0.854568; nc_val[1299] = 0.854597; 
nc_val[1300] = 0.854627; nc_val[1301] = 0.854656; nc_val[1302] = 0.854686; nc_val[1303] = 0.854715; nc_val[1304] = 0.854745; nc_val[1305] = 0.854774; nc_val[1306] = 0.854804; nc_val[1307] = 0.854833; nc_val[1308] = 0.854863; nc_val[1309] = 0.854892; 
nc_val[1310] = 0.854922; nc_val[1311] = 0.854951; nc_val[1312] = 0.854981; nc_val[1313] = 0.855010; nc_val[1314] = 0.855040; nc_val[1315] = 0.855070; nc_val[1316] = 0.855099; nc_val[1317] = 0.855129; nc_val[1318] = 0.855158; nc_val[1319] = 0.855188; 
nc_val[1320] = 0.855217; nc_val[1321] = 0.855247; nc_val[1322] = 0.855276; nc_val[1323] = 0.855306; nc_val[1324] = 0.855335; nc_val[1325] = 0.855365; nc_val[1326] = 0.855395; nc_val[1327] = 0.855424; nc_val[1328] = 0.855454; nc_val[1329] = 0.855483; 
nc_val[1330] = 0.855513; nc_val[1331] = 0.855542; nc_val[1332] = 0.855572; nc_val[1333] = 0.855602; nc_val[1334] = 0.855631; nc_val[1335] = 0.855661; nc_val[1336] = 0.855690; nc_val[1337] = 0.855720; nc_val[1338] = 0.855749; nc_val[1339] = 0.855779; 
nc_val[1340] = 0.855809; nc_val[1341] = 0.855838; nc_val[1342] = 0.855868; nc_val[1343] = 0.855897; nc_val[1344] = 0.855927; nc_val[1345] = 0.855957; nc_val[1346] = 0.855986; nc_val[1347] = 0.856016; nc_val[1348] = 0.856045; nc_val[1349] = 0.856075; 
nc_val[1350] = 0.856105; nc_val[1351] = 0.856134; nc_val[1352] = 0.856164; nc_val[1353] = 0.856193; nc_val[1354] = 0.856223; nc_val[1355] = 0.856253; nc_val[1356] = 0.856282; nc_val[1357] = 0.856312; nc_val[1358] = 0.856342; nc_val[1359] = 0.856371; 
nc_val[1360] = 0.856401; nc_val[1361] = 0.856430; nc_val[1362] = 0.856460; nc_val[1363] = 0.856490; nc_val[1364] = 0.856519; nc_val[1365] = 0.856549; nc_val[1366] = 0.856579; nc_val[1367] = 0.856608; nc_val[1368] = 0.856638; nc_val[1369] = 0.856668; 
nc_val[1370] = 0.856697; nc_val[1371] = 0.856727; nc_val[1372] = 0.856757; nc_val[1373] = 0.856786; nc_val[1374] = 0.856816; nc_val[1375] = 0.856846; nc_val[1376] = 0.856875; nc_val[1377] = 0.856905; nc_val[1378] = 0.856935; nc_val[1379] = 0.856964; 
nc_val[1380] = 0.856994; nc_val[1381] = 0.857024; nc_val[1382] = 0.857053; nc_val[1383] = 0.857083; nc_val[1384] = 0.857113; nc_val[1385] = 0.857142; nc_val[1386] = 0.857172; nc_val[1387] = 0.857202; nc_val[1388] = 0.857231; nc_val[1389] = 0.857261; 
nc_val[1390] = 0.857291; nc_val[1391] = 0.857320; nc_val[1392] = 0.857350; nc_val[1393] = 0.857380; nc_val[1394] = 0.857410; nc_val[1395] = 0.857439; nc_val[1396] = 0.857469; nc_val[1397] = 0.857499; nc_val[1398] = 0.857528; nc_val[1399] = 0.857558; 
nc_val[1400] = 0.857588; nc_val[1401] = 0.857618; nc_val[1402] = 0.857647; nc_val[1403] = 0.857677; nc_val[1404] = 0.857707; nc_val[1405] = 0.857736; nc_val[1406] = 0.857766; nc_val[1407] = 0.857796; nc_val[1408] = 0.857826; nc_val[1409] = 0.857855; 
nc_val[1410] = 0.857885; nc_val[1411] = 0.857915; nc_val[1412] = 0.857945; nc_val[1413] = 0.857974; nc_val[1414] = 0.858004; nc_val[1415] = 0.858034; nc_val[1416] = 0.858064; nc_val[1417] = 0.858093; nc_val[1418] = 0.858123; nc_val[1419] = 0.858153; 
nc_val[1420] = 0.858183; nc_val[1421] = 0.858212; nc_val[1422] = 0.858242; nc_val[1423] = 0.858272; nc_val[1424] = 0.858302; nc_val[1425] = 0.858331; nc_val[1426] = 0.858361; nc_val[1427] = 0.858391; nc_val[1428] = 0.858421; nc_val[1429] = 0.858451; 
nc_val[1430] = 0.858480; nc_val[1431] = 0.858510; nc_val[1432] = 0.858540; nc_val[1433] = 0.858570; nc_val[1434] = 0.858599; nc_val[1435] = 0.858629; nc_val[1436] = 0.858659; nc_val[1437] = 0.858689; nc_val[1438] = 0.858719; nc_val[1439] = 0.858748; 
nc_val[1440] = 0.858778; nc_val[1441] = 0.858808; nc_val[1442] = 0.858838; nc_val[1443] = 0.858868; nc_val[1444] = 0.858897; nc_val[1445] = 0.858927; nc_val[1446] = 0.858957; nc_val[1447] = 0.858987; nc_val[1448] = 0.859017; nc_val[1449] = 0.859047; 
nc_val[1450] = 0.859076; nc_val[1451] = 0.859106; nc_val[1452] = 0.859136; nc_val[1453] = 0.859166; nc_val[1454] = 0.859196; nc_val[1455] = 0.859226; nc_val[1456] = 0.859255; nc_val[1457] = 0.859285; nc_val[1458] = 0.859315; nc_val[1459] = 0.859345; 
nc_val[1460] = 0.859375; nc_val[1461] = 0.859405; nc_val[1462] = 0.859434; nc_val[1463] = 0.859464; nc_val[1464] = 0.859494; nc_val[1465] = 0.859524; nc_val[1466] = 0.859554; nc_val[1467] = 0.859584; nc_val[1468] = 0.859614; nc_val[1469] = 0.859644; 
nc_val[1470] = 0.859673; nc_val[1471] = 0.859703; nc_val[1472] = 0.859733; nc_val[1473] = 0.859763; nc_val[1474] = 0.859793; nc_val[1475] = 0.859823; nc_val[1476] = 0.859853; nc_val[1477] = 0.859883; nc_val[1478] = 0.859912; nc_val[1479] = 0.859942; 
nc_val[1480] = 0.859972; nc_val[1481] = 0.860002; nc_val[1482] = 0.860032; nc_val[1483] = 0.860062; nc_val[1484] = 0.860092; nc_val[1485] = 0.860122; nc_val[1486] = 0.860152; nc_val[1487] = 0.860182; nc_val[1488] = 0.860211; nc_val[1489] = 0.860241; 
nc_val[1490] = 0.860271; nc_val[1491] = 0.860301; nc_val[1492] = 0.860331; nc_val[1493] = 0.860361; nc_val[1494] = 0.860391; nc_val[1495] = 0.860421; nc_val[1496] = 0.860451; nc_val[1497] = 0.860481; nc_val[1498] = 0.860511; nc_val[1499] = 0.860541; 
nc_val[1500] = 0.860571; nc_val[1501] = 0.860600; nc_val[1502] = 0.860630; nc_val[1503] = 0.860660; nc_val[1504] = 0.860690; nc_val[1505] = 0.860720; nc_val[1506] = 0.860750; nc_val[1507] = 0.860780; nc_val[1508] = 0.860810; nc_val[1509] = 0.860840; 
nc_val[1510] = 0.860870; nc_val[1511] = 0.860900; nc_val[1512] = 0.860930; nc_val[1513] = 0.860960; nc_val[1514] = 0.860990; nc_val[1515] = 0.861020; nc_val[1516] = 0.861050; nc_val[1517] = 0.861080; nc_val[1518] = 0.861110; nc_val[1519] = 0.861140; 
nc_val[1520] = 0.861170; nc_val[1521] = 0.861200; nc_val[1522] = 0.861230; nc_val[1523] = 0.861260; nc_val[1524] = 0.861290; nc_val[1525] = 0.861320; nc_val[1526] = 0.861350; nc_val[1527] = 0.861380; nc_val[1528] = 0.861410; nc_val[1529] = 0.861440; 
nc_val[1530] = 0.861470; nc_val[1531] = 0.861500; nc_val[1532] = 0.861530; nc_val[1533] = 0.861560; nc_val[1534] = 0.861590; nc_val[1535] = 0.861620; nc_val[1536] = 0.861650; nc_val[1537] = 0.861680; nc_val[1538] = 0.861710; nc_val[1539] = 0.861740; 
nc_val[1540] = 0.861770; nc_val[1541] = 0.861800; nc_val[1542] = 0.861830; nc_val[1543] = 0.861860; nc_val[1544] = 0.861890; nc_val[1545] = 0.861920; nc_val[1546] = 0.861950; nc_val[1547] = 0.861980; nc_val[1548] = 0.862010; nc_val[1549] = 0.862040; 
nc_val[1550] = 0.862070; nc_val[1551] = 0.862100; nc_val[1552] = 0.862130; nc_val[1553] = 0.862160; nc_val[1554] = 0.862190; nc_val[1555] = 0.862220; nc_val[1556] = 0.862251; nc_val[1557] = 0.862281; nc_val[1558] = 0.862311; nc_val[1559] = 0.862341; 
nc_val[1560] = 0.862371; nc_val[1561] = 0.862401; nc_val[1562] = 0.862431; nc_val[1563] = 0.862461; nc_val[1564] = 0.862491; nc_val[1565] = 0.862521; nc_val[1566] = 0.862551; nc_val[1567] = 0.862581; nc_val[1568] = 0.862611; nc_val[1569] = 0.862642; 
nc_val[1570] = 0.862672; nc_val[1571] = 0.862702; nc_val[1572] = 0.862732; nc_val[1573] = 0.862762; nc_val[1574] = 0.862792; nc_val[1575] = 0.862822; nc_val[1576] = 0.862852; nc_val[1577] = 0.862882; nc_val[1578] = 0.862913; nc_val[1579] = 0.862943; 
nc_val[1580] = 0.862973; nc_val[1581] = 0.863003; nc_val[1582] = 0.863033; nc_val[1583] = 0.863063; nc_val[1584] = 0.863093; nc_val[1585] = 0.863123; nc_val[1586] = 0.863154; nc_val[1587] = 0.863184; nc_val[1588] = 0.863214; nc_val[1589] = 0.863244; 
nc_val[1590] = 0.863274; nc_val[1591] = 0.863304; nc_val[1592] = 0.863334; nc_val[1593] = 0.863364; nc_val[1594] = 0.863395; nc_val[1595] = 0.863425; nc_val[1596] = 0.863455; nc_val[1597] = 0.863485; nc_val[1598] = 0.863515; nc_val[1599] = 0.863545; 
nc_val[1600] = 0.863576; nc_val[1601] = 0.863606; nc_val[1602] = 0.863636; nc_val[1603] = 0.863666; nc_val[1604] = 0.863696; nc_val[1605] = 0.863726; nc_val[1606] = 0.863757; nc_val[1607] = 0.863787; nc_val[1608] = 0.863817; nc_val[1609] = 0.863847; 
nc_val[1610] = 0.863877; nc_val[1611] = 0.863908; nc_val[1612] = 0.863938; nc_val[1613] = 0.863968; nc_val[1614] = 0.863998; nc_val[1615] = 0.864028; nc_val[1616] = 0.864059; nc_val[1617] = 0.864089; nc_val[1618] = 0.864119; nc_val[1619] = 0.864149; 
nc_val[1620] = 0.864179; nc_val[1621] = 0.864210; nc_val[1622] = 0.864240; nc_val[1623] = 0.864270; nc_val[1624] = 0.864300; nc_val[1625] = 0.864330; nc_val[1626] = 0.864361; nc_val[1627] = 0.864391; nc_val[1628] = 0.864421; nc_val[1629] = 0.864451; 
nc_val[1630] = 0.864482; nc_val[1631] = 0.864512; nc_val[1632] = 0.864542; nc_val[1633] = 0.864572; nc_val[1634] = 0.864603; nc_val[1635] = 0.864633; nc_val[1636] = 0.864663; nc_val[1637] = 0.864693; nc_val[1638] = 0.864724; nc_val[1639] = 0.864754; 
nc_val[1640] = 0.864784; nc_val[1641] = 0.864814; nc_val[1642] = 0.864845; nc_val[1643] = 0.864875; nc_val[1644] = 0.864905; nc_val[1645] = 0.864935; nc_val[1646] = 0.864966; nc_val[1647] = 0.864996; nc_val[1648] = 0.865026; nc_val[1649] = 0.865056; 
nc_val[1650] = 0.865087; nc_val[1651] = 0.865117; nc_val[1652] = 0.865147; nc_val[1653] = 0.865178; nc_val[1654] = 0.865208; nc_val[1655] = 0.865238; nc_val[1656] = 0.865268; nc_val[1657] = 0.865299; nc_val[1658] = 0.865329; nc_val[1659] = 0.865359; 
nc_val[1660] = 0.865390; nc_val[1661] = 0.865420; nc_val[1662] = 0.865450; nc_val[1663] = 0.865481; nc_val[1664] = 0.865511; nc_val[1665] = 0.865541; nc_val[1666] = 0.865572; nc_val[1667] = 0.865602; nc_val[1668] = 0.865632; nc_val[1669] = 0.865662; 
nc_val[1670] = 0.865693; nc_val[1671] = 0.865723; nc_val[1672] = 0.865753; nc_val[1673] = 0.865784; nc_val[1674] = 0.865814; nc_val[1675] = 0.865844; nc_val[1676] = 0.865875; nc_val[1677] = 0.865905; nc_val[1678] = 0.865936; nc_val[1679] = 0.865966; 
nc_val[1680] = 0.865996; nc_val[1681] = 0.866027; nc_val[1682] = 0.866057; nc_val[1683] = 0.866087; nc_val[1684] = 0.866118; nc_val[1685] = 0.866148; nc_val[1686] = 0.866178; nc_val[1687] = 0.866209; nc_val[1688] = 0.866239; nc_val[1689] = 0.866269; 
nc_val[1690] = 0.866300; nc_val[1691] = 0.866330; nc_val[1692] = 0.866361; nc_val[1693] = 0.866391; nc_val[1694] = 0.866421; nc_val[1695] = 0.866452; nc_val[1696] = 0.866482; nc_val[1697] = 0.866513; nc_val[1698] = 0.866543; nc_val[1699] = 0.866573; 
nc_val[1700] = 0.866604; nc_val[1701] = 0.866634; nc_val[1702] = 0.866665; nc_val[1703] = 0.866695; nc_val[1704] = 0.866725; nc_val[1705] = 0.866756; nc_val[1706] = 0.866786; nc_val[1707] = 0.866817; nc_val[1708] = 0.866847; nc_val[1709] = 0.866877; 
nc_val[1710] = 0.866908; nc_val[1711] = 0.866938; nc_val[1712] = 0.866969; nc_val[1713] = 0.866999; nc_val[1714] = 0.867030; nc_val[1715] = 0.867060; nc_val[1716] = 0.867090; nc_val[1717] = 0.867121; nc_val[1718] = 0.867151; nc_val[1719] = 0.867182; 
nc_val[1720] = 0.867212; nc_val[1721] = 0.867243; nc_val[1722] = 0.867273; nc_val[1723] = 0.867304; nc_val[1724] = 0.867334; nc_val[1725] = 0.867364; nc_val[1726] = 0.867395; nc_val[1727] = 0.867425; nc_val[1728] = 0.867456; nc_val[1729] = 0.867486; 
nc_val[1730] = 0.867517; nc_val[1731] = 0.867547; nc_val[1732] = 0.867578; nc_val[1733] = 0.867608; nc_val[1734] = 0.867639; nc_val[1735] = 0.867669; nc_val[1736] = 0.867700; nc_val[1737] = 0.867730; nc_val[1738] = 0.867761; nc_val[1739] = 0.867791; 
nc_val[1740] = 0.867822; nc_val[1741] = 0.867852; nc_val[1742] = 0.867883; nc_val[1743] = 0.867913; nc_val[1744] = 0.867944; nc_val[1745] = 0.867974; nc_val[1746] = 0.868005; nc_val[1747] = 0.868035; nc_val[1748] = 0.868066; nc_val[1749] = 0.868096; 
nc_val[1750] = 0.868127; nc_val[1751] = 0.868157; nc_val[1752] = 0.868188; nc_val[1753] = 0.868218; nc_val[1754] = 0.868249; nc_val[1755] = 0.868279; nc_val[1756] = 0.868310; nc_val[1757] = 0.868340; nc_val[1758] = 0.868371; nc_val[1759] = 0.868401; 
nc_val[1760] = 0.868432; nc_val[1761] = 0.868463; nc_val[1762] = 0.868493; nc_val[1763] = 0.868524; nc_val[1764] = 0.868554; nc_val[1765] = 0.868585; nc_val[1766] = 0.868615; nc_val[1767] = 0.868646; nc_val[1768] = 0.868676; nc_val[1769] = 0.868707; 
nc_val[1770] = 0.868738; nc_val[1771] = 0.868768; nc_val[1772] = 0.868799; nc_val[1773] = 0.868829; nc_val[1774] = 0.868860; nc_val[1775] = 0.868890; nc_val[1776] = 0.868921; nc_val[1777] = 0.868952; nc_val[1778] = 0.868982; nc_val[1779] = 0.869013; 
nc_val[1780] = 0.869043; nc_val[1781] = 0.869074; nc_val[1782] = 0.869105; nc_val[1783] = 0.869135; nc_val[1784] = 0.869166; nc_val[1785] = 0.869196; nc_val[1786] = 0.869227; nc_val[1787] = 0.869258; nc_val[1788] = 0.869288; nc_val[1789] = 0.869319; 
nc_val[1790] = 0.869349; nc_val[1791] = 0.869380; nc_val[1792] = 0.869411; nc_val[1793] = 0.869441; nc_val[1794] = 0.869472; nc_val[1795] = 0.869503; nc_val[1796] = 0.869533; nc_val[1797] = 0.869564; nc_val[1798] = 0.869594; nc_val[1799] = 0.869625; 
nc_val[1800] = 0.869656; nc_val[1801] = 0.869686; nc_val[1802] = 0.869717; nc_val[1803] = 0.869748; nc_val[1804] = 0.869778; nc_val[1805] = 0.869809; nc_val[1806] = 0.869840; nc_val[1807] = 0.869870; nc_val[1808] = 0.869901; nc_val[1809] = 0.869932; 
nc_val[1810] = 0.869962; nc_val[1811] = 0.869993; nc_val[1812] = 0.870024; nc_val[1813] = 0.870054; nc_val[1814] = 0.870085; nc_val[1815] = 0.870116; nc_val[1816] = 0.870146; nc_val[1817] = 0.870177; nc_val[1818] = 0.870208; nc_val[1819] = 0.870238; 
nc_val[1820] = 0.870269; nc_val[1821] = 0.870300; nc_val[1822] = 0.870330; nc_val[1823] = 0.870361; nc_val[1824] = 0.870392; nc_val[1825] = 0.870422; nc_val[1826] = 0.870453; nc_val[1827] = 0.870484; nc_val[1828] = 0.870515; nc_val[1829] = 0.870545; 
nc_val[1830] = 0.870576; nc_val[1831] = 0.870607; nc_val[1832] = 0.870637; nc_val[1833] = 0.870668; nc_val[1834] = 0.870699; nc_val[1835] = 0.870730; nc_val[1836] = 0.870760; nc_val[1837] = 0.870791; nc_val[1838] = 0.870822; nc_val[1839] = 0.870853; 
nc_val[1840] = 0.870883; nc_val[1841] = 0.870914; nc_val[1842] = 0.870945; nc_val[1843] = 0.870976; nc_val[1844] = 0.871006; nc_val[1845] = 0.871037; nc_val[1846] = 0.871068; nc_val[1847] = 0.871099; nc_val[1848] = 0.871129; nc_val[1849] = 0.871160; 
nc_val[1850] = 0.871191; nc_val[1851] = 0.871222; nc_val[1852] = 0.871252; nc_val[1853] = 0.871283; nc_val[1854] = 0.871314; nc_val[1855] = 0.871345; nc_val[1856] = 0.871376; nc_val[1857] = 0.871406; nc_val[1858] = 0.871437; nc_val[1859] = 0.871468; 
nc_val[1860] = 0.871499; nc_val[1861] = 0.871529; nc_val[1862] = 0.871560; nc_val[1863] = 0.871591; nc_val[1864] = 0.871622; nc_val[1865] = 0.871653; nc_val[1866] = 0.871683; nc_val[1867] = 0.871714; nc_val[1868] = 0.871745; nc_val[1869] = 0.871776; 
nc_val[1870] = 0.871807; nc_val[1871] = 0.871838; nc_val[1872] = 0.871868; nc_val[1873] = 0.871899; nc_val[1874] = 0.871930; nc_val[1875] = 0.871961; nc_val[1876] = 0.871992; nc_val[1877] = 0.872022; nc_val[1878] = 0.872053; nc_val[1879] = 0.872084; 
nc_val[1880] = 0.872115; nc_val[1881] = 0.872146; nc_val[1882] = 0.872177; nc_val[1883] = 0.872208; nc_val[1884] = 0.872238; nc_val[1885] = 0.872269; nc_val[1886] = 0.872300; nc_val[1887] = 0.872331; nc_val[1888] = 0.872362; nc_val[1889] = 0.872393; 
nc_val[1890] = 0.872424; nc_val[1891] = 0.872454; nc_val[1892] = 0.872485; nc_val[1893] = 0.872516; nc_val[1894] = 0.872547; nc_val[1895] = 0.872578; nc_val[1896] = 0.872609; nc_val[1897] = 0.872640; nc_val[1898] = 0.872671; nc_val[1899] = 0.872701; 
nc_val[1900] = 0.872732; nc_val[1901] = 0.872763; nc_val[1902] = 0.872794; nc_val[1903] = 0.872825; nc_val[1904] = 0.872856; nc_val[1905] = 0.872887; nc_val[1906] = 0.872918; nc_val[1907] = 0.872949; nc_val[1908] = 0.872980; nc_val[1909] = 0.873010; 
nc_val[1910] = 0.873041; nc_val[1911] = 0.873072; nc_val[1912] = 0.873103; nc_val[1913] = 0.873134; nc_val[1914] = 0.873165; nc_val[1915] = 0.873196; nc_val[1916] = 0.873227; nc_val[1917] = 0.873258; nc_val[1918] = 0.873289; nc_val[1919] = 0.873320; 
nc_val[1920] = 0.873351; nc_val[1921] = 0.873382; nc_val[1922] = 0.873413; nc_val[1923] = 0.873444; nc_val[1924] = 0.873474; nc_val[1925] = 0.873505; nc_val[1926] = 0.873536; nc_val[1927] = 0.873567; nc_val[1928] = 0.873598; nc_val[1929] = 0.873629; 
nc_val[1930] = 0.873660; nc_val[1931] = 0.873691; nc_val[1932] = 0.873722; nc_val[1933] = 0.873753; nc_val[1934] = 0.873784; nc_val[1935] = 0.873815; nc_val[1936] = 0.873846; nc_val[1937] = 0.873877; nc_val[1938] = 0.873908; nc_val[1939] = 0.873939; 
nc_val[1940] = 0.873970; nc_val[1941] = 0.874001; nc_val[1942] = 0.874032; nc_val[1943] = 0.874063; nc_val[1944] = 0.874094; nc_val[1945] = 0.874125; nc_val[1946] = 0.874156; nc_val[1947] = 0.874187; nc_val[1948] = 0.874218; nc_val[1949] = 0.874249; 
nc_val[1950] = 0.874280; nc_val[1951] = 0.874311; nc_val[1952] = 0.874342; nc_val[1953] = 0.874373; nc_val[1954] = 0.874404; nc_val[1955] = 0.874435; nc_val[1956] = 0.874466; nc_val[1957] = 0.874497; nc_val[1958] = 0.874528; nc_val[1959] = 0.874559; 
nc_val[1960] = 0.874591; nc_val[1961] = 0.874622; nc_val[1962] = 0.874653; nc_val[1963] = 0.874684; nc_val[1964] = 0.874715; nc_val[1965] = 0.874746; nc_val[1966] = 0.874777; nc_val[1967] = 0.874808; nc_val[1968] = 0.874839; nc_val[1969] = 0.874870; 
nc_val[1970] = 0.874901; nc_val[1971] = 0.874932; nc_val[1972] = 0.874963; nc_val[1973] = 0.874994; nc_val[1974] = 0.875025; nc_val[1975] = 0.875057; nc_val[1976] = 0.875088; nc_val[1977] = 0.875119; nc_val[1978] = 0.875150; nc_val[1979] = 0.875181; 
nc_val[1980] = 0.875212; nc_val[1981] = 0.875243; nc_val[1982] = 0.875274; nc_val[1983] = 0.875305; nc_val[1984] = 0.875336; nc_val[1985] = 0.875368; nc_val[1986] = 0.875399; nc_val[1987] = 0.875430; nc_val[1988] = 0.875461; nc_val[1989] = 0.875492; 
nc_val[1990] = 0.875523; nc_val[1991] = 0.875554; nc_val[1992] = 0.875585; nc_val[1993] = 0.875617; nc_val[1994] = 0.875648; nc_val[1995] = 0.875679; nc_val[1996] = 0.875710; nc_val[1997] = 0.875741; nc_val[1998] = 0.875772; nc_val[1999] = 0.875803; 
nc_val[2000] = 0.875835; nc_val[2001] = 0.875866; nc_val[2002] = 0.875897; nc_val[2003] = 0.875928; nc_val[2004] = 0.875959; nc_val[2005] = 0.875990; nc_val[2006] = 0.876021; nc_val[2007] = 0.876053; nc_val[2008] = 0.876084; nc_val[2009] = 0.876115; 
nc_val[2010] = 0.876146; nc_val[2011] = 0.876177; nc_val[2012] = 0.876209; nc_val[2013] = 0.876240; nc_val[2014] = 0.876271; nc_val[2015] = 0.876302; nc_val[2016] = 0.876333; nc_val[2017] = 0.876364; nc_val[2018] = 0.876396; nc_val[2019] = 0.876427; 
nc_val[2020] = 0.876458; nc_val[2021] = 0.876489; nc_val[2022] = 0.876521; nc_val[2023] = 0.876552; nc_val[2024] = 0.876583; nc_val[2025] = 0.876614; nc_val[2026] = 0.876645; nc_val[2027] = 0.876677; nc_val[2028] = 0.876708; nc_val[2029] = 0.876739; 
nc_val[2030] = 0.876770; nc_val[2031] = 0.876802; nc_val[2032] = 0.876833; nc_val[2033] = 0.876864; nc_val[2034] = 0.876895; nc_val[2035] = 0.876926; nc_val[2036] = 0.876958; nc_val[2037] = 0.876989; nc_val[2038] = 0.877020; nc_val[2039] = 0.877051; 
nc_val[2040] = 0.877083; nc_val[2041] = 0.877114; nc_val[2042] = 0.877145; nc_val[2043] = 0.877177; nc_val[2044] = 0.877208; nc_val[2045] = 0.877239; nc_val[2046] = 0.877270; nc_val[2047] = 0.877302; nc_val[2048] = 0.877333; nc_val[2049] = 0.877364; 
nc_val[2050] = 0.877395; nc_val[2051] = 0.877427; nc_val[2052] = 0.877458; nc_val[2053] = 0.877489; nc_val[2054] = 0.877521; nc_val[2055] = 0.877552; nc_val[2056] = 0.877583; nc_val[2057] = 0.877615; nc_val[2058] = 0.877646; nc_val[2059] = 0.877677; 
nc_val[2060] = 0.877708; nc_val[2061] = 0.877740; nc_val[2062] = 0.877771; nc_val[2063] = 0.877802; nc_val[2064] = 0.877834; nc_val[2065] = 0.877865; nc_val[2066] = 0.877896; nc_val[2067] = 0.877928; nc_val[2068] = 0.877959; nc_val[2069] = 0.877990; 
nc_val[2070] = 0.878022; nc_val[2071] = 0.878053; nc_val[2072] = 0.878084; nc_val[2073] = 0.878116; nc_val[2074] = 0.878147; nc_val[2075] = 0.878178; nc_val[2076] = 0.878210; nc_val[2077] = 0.878241; nc_val[2078] = 0.878273; nc_val[2079] = 0.878304; 
nc_val[2080] = 0.878335; nc_val[2081] = 0.878367; nc_val[2082] = 0.878398; nc_val[2083] = 0.878429; nc_val[2084] = 0.878461; nc_val[2085] = 0.878492; nc_val[2086] = 0.878524; nc_val[2087] = 0.878555; nc_val[2088] = 0.878586; nc_val[2089] = 0.878618; 
nc_val[2090] = 0.878649; nc_val[2091] = 0.878680; nc_val[2092] = 0.878712; nc_val[2093] = 0.878743; nc_val[2094] = 0.878775; nc_val[2095] = 0.878806; nc_val[2096] = 0.878838; nc_val[2097] = 0.878869; nc_val[2098] = 0.878900; nc_val[2099] = 0.878932; 
nc_val[2100] = 0.878963; nc_val[2101] = 0.878995; nc_val[2102] = 0.879026; nc_val[2103] = 0.879057; nc_val[2104] = 0.879089; nc_val[2105] = 0.879120; nc_val[2106] = 0.879152; nc_val[2107] = 0.879183; nc_val[2108] = 0.879215; nc_val[2109] = 0.879246; 
nc_val[2110] = 0.879278; nc_val[2111] = 0.879309; nc_val[2112] = 0.879340; nc_val[2113] = 0.879372; nc_val[2114] = 0.879403; nc_val[2115] = 0.879435; nc_val[2116] = 0.879466; nc_val[2117] = 0.879498; nc_val[2118] = 0.879529; nc_val[2119] = 0.879561; 
nc_val[2120] = 0.879592; nc_val[2121] = 0.879624; nc_val[2122] = 0.879655; nc_val[2123] = 0.879687; nc_val[2124] = 0.879718; nc_val[2125] = 0.879750; nc_val[2126] = 0.879781; nc_val[2127] = 0.879813; nc_val[2128] = 0.879844; nc_val[2129] = 0.879876; 
nc_val[2130] = 0.879907; nc_val[2131] = 0.879939; nc_val[2132] = 0.879970; nc_val[2133] = 0.880002; nc_val[2134] = 0.880033; nc_val[2135] = 0.880065; nc_val[2136] = 0.880096; nc_val[2137] = 0.880128; nc_val[2138] = 0.880159; nc_val[2139] = 0.880191; 
nc_val[2140] = 0.880222; nc_val[2141] = 0.880254; nc_val[2142] = 0.880285; nc_val[2143] = 0.880317; nc_val[2144] = 0.880348; nc_val[2145] = 0.880380; nc_val[2146] = 0.880412; nc_val[2147] = 0.880443; nc_val[2148] = 0.880475; nc_val[2149] = 0.880506; 
nc_val[2150] = 0.880538; nc_val[2151] = 0.880569; nc_val[2152] = 0.880601; nc_val[2153] = 0.880632; nc_val[2154] = 0.880664; nc_val[2155] = 0.880696; nc_val[2156] = 0.880727; nc_val[2157] = 0.880759; nc_val[2158] = 0.880790; nc_val[2159] = 0.880822; 
nc_val[2160] = 0.880854; nc_val[2161] = 0.880885; nc_val[2162] = 0.880917; nc_val[2163] = 0.880948; nc_val[2164] = 0.880980; nc_val[2165] = 0.881011; nc_val[2166] = 0.881043; nc_val[2167] = 0.881075; nc_val[2168] = 0.881106; nc_val[2169] = 0.881138; 
nc_val[2170] = 0.881170; nc_val[2171] = 0.881201; nc_val[2172] = 0.881233; nc_val[2173] = 0.881264; nc_val[2174] = 0.881296; nc_val[2175] = 0.881328; nc_val[2176] = 0.881359; nc_val[2177] = 0.881391; nc_val[2178] = 0.881423; nc_val[2179] = 0.881454; 
nc_val[2180] = 0.881486; nc_val[2181] = 0.881518; nc_val[2182] = 0.881549; nc_val[2183] = 0.881581; nc_val[2184] = 0.881612; nc_val[2185] = 0.881644; nc_val[2186] = 0.881676; nc_val[2187] = 0.881707; nc_val[2188] = 0.881739; nc_val[2189] = 0.881771; 
nc_val[2190] = 0.881802; nc_val[2191] = 0.881834; nc_val[2192] = 0.881866; nc_val[2193] = 0.881897; nc_val[2194] = 0.881929; nc_val[2195] = 0.881961; nc_val[2196] = 0.881993; nc_val[2197] = 0.882024; nc_val[2198] = 0.882056; nc_val[2199] = 0.882088; 
nc_val[2200] = 0.882119; nc_val[2201] = 0.882151; nc_val[2202] = 0.882183; nc_val[2203] = 0.882214; nc_val[2204] = 0.882246; nc_val[2205] = 0.882278; nc_val[2206] = 0.882310; nc_val[2207] = 0.882341; nc_val[2208] = 0.882373; nc_val[2209] = 0.882405; 
nc_val[2210] = 0.882437; nc_val[2211] = 0.882468; nc_val[2212] = 0.882500; nc_val[2213] = 0.882532; nc_val[2214] = 0.882563; nc_val[2215] = 0.882595; nc_val[2216] = 0.882627; nc_val[2217] = 0.882659; nc_val[2218] = 0.882690; nc_val[2219] = 0.882722; 
nc_val[2220] = 0.882754; nc_val[2221] = 0.882786; nc_val[2222] = 0.882817; nc_val[2223] = 0.882849; nc_val[2224] = 0.882881; nc_val[2225] = 0.882913; nc_val[2226] = 0.882945; nc_val[2227] = 0.882976; nc_val[2228] = 0.883008; nc_val[2229] = 0.883040; 
nc_val[2230] = 0.883072; nc_val[2231] = 0.883103; nc_val[2232] = 0.883135; nc_val[2233] = 0.883167; nc_val[2234] = 0.883199; nc_val[2235] = 0.883231; nc_val[2236] = 0.883262; nc_val[2237] = 0.883294; nc_val[2238] = 0.883326; nc_val[2239] = 0.883358; 
nc_val[2240] = 0.883390; nc_val[2241] = 0.883422; nc_val[2242] = 0.883453; nc_val[2243] = 0.883485; nc_val[2244] = 0.883517; nc_val[2245] = 0.883549; nc_val[2246] = 0.883581; nc_val[2247] = 0.883613; nc_val[2248] = 0.883644; nc_val[2249] = 0.883676; 
nc_val[2250] = 0.883708; nc_val[2251] = 0.883740; nc_val[2252] = 0.883772; nc_val[2253] = 0.883804; nc_val[2254] = 0.883835; nc_val[2255] = 0.883867; nc_val[2256] = 0.883899; nc_val[2257] = 0.883931; nc_val[2258] = 0.883963; nc_val[2259] = 0.883995; 
nc_val[2260] = 0.884027; nc_val[2261] = 0.884059; nc_val[2262] = 0.884090; nc_val[2263] = 0.884122; nc_val[2264] = 0.884154; nc_val[2265] = 0.884186; nc_val[2266] = 0.884218; nc_val[2267] = 0.884250; nc_val[2268] = 0.884282; nc_val[2269] = 0.884314; 
nc_val[2270] = 0.884346; nc_val[2271] = 0.884377; nc_val[2272] = 0.884409; nc_val[2273] = 0.884441; nc_val[2274] = 0.884473; nc_val[2275] = 0.884505; nc_val[2276] = 0.884537; nc_val[2277] = 0.884569; nc_val[2278] = 0.884601; nc_val[2279] = 0.884633; 
nc_val[2280] = 0.884665; nc_val[2281] = 0.884697; nc_val[2282] = 0.884729; nc_val[2283] = 0.884761; nc_val[2284] = 0.884793; nc_val[2285] = 0.884824; nc_val[2286] = 0.884856; nc_val[2287] = 0.884888; nc_val[2288] = 0.884920; nc_val[2289] = 0.884952; 
nc_val[2290] = 0.884984; nc_val[2291] = 0.885016; nc_val[2292] = 0.885048; nc_val[2293] = 0.885080; nc_val[2294] = 0.885112; nc_val[2295] = 0.885144; nc_val[2296] = 0.885176; nc_val[2297] = 0.885208; nc_val[2298] = 0.885240; nc_val[2299] = 0.885272; 
nc_val[2300] = 0.885304; nc_val[2301] = 0.885336; nc_val[2302] = 0.885368; nc_val[2303] = 0.885400; nc_val[2304] = 0.885432; nc_val[2305] = 0.885464; nc_val[2306] = 0.885496; nc_val[2307] = 0.885528; nc_val[2308] = 0.885560; nc_val[2309] = 0.885592; 
nc_val[2310] = 0.885624; nc_val[2311] = 0.885656; nc_val[2312] = 0.885688; nc_val[2313] = 0.885720; nc_val[2314] = 0.885752; nc_val[2315] = 0.885784; nc_val[2316] = 0.885816; nc_val[2317] = 0.885848; nc_val[2318] = 0.885880; nc_val[2319] = 0.885912; 
nc_val[2320] = 0.885945; nc_val[2321] = 0.885977; nc_val[2322] = 0.886009; nc_val[2323] = 0.886041; nc_val[2324] = 0.886073; nc_val[2325] = 0.886105; nc_val[2326] = 0.886137; nc_val[2327] = 0.886169; nc_val[2328] = 0.886201; nc_val[2329] = 0.886233; 
nc_val[2330] = 0.886265; nc_val[2331] = 0.886297; nc_val[2332] = 0.886329; nc_val[2333] = 0.886361; nc_val[2334] = 0.886394; nc_val[2335] = 0.886426; nc_val[2336] = 0.886458; nc_val[2337] = 0.886490; nc_val[2338] = 0.886522; nc_val[2339] = 0.886554; 
nc_val[2340] = 0.886586; nc_val[2341] = 0.886618; nc_val[2342] = 0.886650; nc_val[2343] = 0.886683; nc_val[2344] = 0.886715; nc_val[2345] = 0.886747; nc_val[2346] = 0.886779; nc_val[2347] = 0.886811; nc_val[2348] = 0.886843; nc_val[2349] = 0.886875; 
nc_val[2350] = 0.886907; nc_val[2351] = 0.886940; nc_val[2352] = 0.886972; nc_val[2353] = 0.887004; nc_val[2354] = 0.887036; nc_val[2355] = 0.887068; nc_val[2356] = 0.887100; nc_val[2357] = 0.887133; nc_val[2358] = 0.887165; nc_val[2359] = 0.887197; 
nc_val[2360] = 0.887229; nc_val[2361] = 0.887261; nc_val[2362] = 0.887293; nc_val[2363] = 0.887326; nc_val[2364] = 0.887358; nc_val[2365] = 0.887390; nc_val[2366] = 0.887422; nc_val[2367] = 0.887454; nc_val[2368] = 0.887487; nc_val[2369] = 0.887519; 
nc_val[2370] = 0.887551; nc_val[2371] = 0.887583; nc_val[2372] = 0.887615; nc_val[2373] = 0.887648; nc_val[2374] = 0.887680; nc_val[2375] = 0.887712; nc_val[2376] = 0.887744; nc_val[2377] = 0.887776; nc_val[2378] = 0.887809; nc_val[2379] = 0.887841; 
nc_val[2380] = 0.887873; nc_val[2381] = 0.887905; nc_val[2382] = 0.887938; nc_val[2383] = 0.887970; nc_val[2384] = 0.888002; nc_val[2385] = 0.888034; nc_val[2386] = 0.888067; nc_val[2387] = 0.888099; nc_val[2388] = 0.888131; nc_val[2389] = 0.888163; 
nc_val[2390] = 0.888196; nc_val[2391] = 0.888228; nc_val[2392] = 0.888260; nc_val[2393] = 0.888292; nc_val[2394] = 0.888325; nc_val[2395] = 0.888357; nc_val[2396] = 0.888389; nc_val[2397] = 0.888422; nc_val[2398] = 0.888454; nc_val[2399] = 0.888486; 
nc_val[2400] = 0.888518; nc_val[2401] = 0.888551; nc_val[2402] = 0.888583; nc_val[2403] = 0.888615; nc_val[2404] = 0.888648; nc_val[2405] = 0.888680; nc_val[2406] = 0.888712; nc_val[2407] = 0.888745; nc_val[2408] = 0.888777; nc_val[2409] = 0.888809; 
nc_val[2410] = 0.888842; nc_val[2411] = 0.888874; nc_val[2412] = 0.888906; nc_val[2413] = 0.888939; nc_val[2414] = 0.888971; nc_val[2415] = 0.889003; nc_val[2416] = 0.889036; nc_val[2417] = 0.889068; nc_val[2418] = 0.889100; nc_val[2419] = 0.889133; 
nc_val[2420] = 0.889165; nc_val[2421] = 0.889197; nc_val[2422] = 0.889230; nc_val[2423] = 0.889262; nc_val[2424] = 0.889295; nc_val[2425] = 0.889327; nc_val[2426] = 0.889359; nc_val[2427] = 0.889392; nc_val[2428] = 0.889424; nc_val[2429] = 0.889456; 
nc_val[2430] = 0.889489; nc_val[2431] = 0.889521; nc_val[2432] = 0.889554; nc_val[2433] = 0.889586; nc_val[2434] = 0.889618; nc_val[2435] = 0.889651; nc_val[2436] = 0.889683; nc_val[2437] = 0.889716; nc_val[2438] = 0.889748; nc_val[2439] = 0.889780; 
nc_val[2440] = 0.889813; nc_val[2441] = 0.889845; nc_val[2442] = 0.889878; nc_val[2443] = 0.889910; nc_val[2444] = 0.889943; nc_val[2445] = 0.889975; nc_val[2446] = 0.890007; nc_val[2447] = 0.890040; nc_val[2448] = 0.890072; nc_val[2449] = 0.890105; 
nc_val[2450] = 0.890137; nc_val[2451] = 0.890170; nc_val[2452] = 0.890202; nc_val[2453] = 0.890235; nc_val[2454] = 0.890267; nc_val[2455] = 0.890300; nc_val[2456] = 0.890332; nc_val[2457] = 0.890364; nc_val[2458] = 0.890397; nc_val[2459] = 0.890429; 
nc_val[2460] = 0.890462; nc_val[2461] = 0.890494; nc_val[2462] = 0.890527; nc_val[2463] = 0.890559; nc_val[2464] = 0.890592; nc_val[2465] = 0.890624; nc_val[2466] = 0.890657; nc_val[2467] = 0.890689; nc_val[2468] = 0.890722; nc_val[2469] = 0.890754; 
nc_val[2470] = 0.890787; nc_val[2471] = 0.890819; nc_val[2472] = 0.890852; nc_val[2473] = 0.890885; nc_val[2474] = 0.890917; nc_val[2475] = 0.890950; nc_val[2476] = 0.890982; nc_val[2477] = 0.891015; nc_val[2478] = 0.891047; nc_val[2479] = 0.891080; 
nc_val[2480] = 0.891112; nc_val[2481] = 0.891145; nc_val[2482] = 0.891177; nc_val[2483] = 0.891210; nc_val[2484] = 0.891242; nc_val[2485] = 0.891275; nc_val[2486] = 0.891308; nc_val[2487] = 0.891340; nc_val[2488] = 0.891373; nc_val[2489] = 0.891405; 
nc_val[2490] = 0.891438; nc_val[2491] = 0.891470; nc_val[2492] = 0.891503; nc_val[2493] = 0.891536; nc_val[2494] = 0.891568; nc_val[2495] = 0.891601; nc_val[2496] = 0.891633; nc_val[2497] = 0.891666; nc_val[2498] = 0.891699; nc_val[2499] = 0.891731; 
nc_val[2500] = 0.891764; nc_val[2501] = 0.891796; nc_val[2502] = 0.891829; nc_val[2503] = 0.891862; nc_val[2504] = 0.891894; nc_val[2505] = 0.891927; nc_val[2506] = 0.891960; nc_val[2507] = 0.891992; nc_val[2508] = 0.892025; nc_val[2509] = 0.892058; 
nc_val[2510] = 0.892090; nc_val[2511] = 0.892123; nc_val[2512] = 0.892155; nc_val[2513] = 0.892188; nc_val[2514] = 0.892221; nc_val[2515] = 0.892253; nc_val[2516] = 0.892286; nc_val[2517] = 0.892319; nc_val[2518] = 0.892351; nc_val[2519] = 0.892384; 
nc_val[2520] = 0.892417; nc_val[2521] = 0.892449; nc_val[2522] = 0.892482; nc_val[2523] = 0.892515; nc_val[2524] = 0.892548; nc_val[2525] = 0.892580; nc_val[2526] = 0.892613; nc_val[2527] = 0.892646; nc_val[2528] = 0.892678; nc_val[2529] = 0.892711; 
nc_val[2530] = 0.892744; nc_val[2531] = 0.892776; nc_val[2532] = 0.892809; nc_val[2533] = 0.892842; nc_val[2534] = 0.892875; nc_val[2535] = 0.892907; nc_val[2536] = 0.892940; nc_val[2537] = 0.892973; nc_val[2538] = 0.893006; nc_val[2539] = 0.893038; 
nc_val[2540] = 0.893071; nc_val[2541] = 0.893104; nc_val[2542] = 0.893136; nc_val[2543] = 0.893169; nc_val[2544] = 0.893202; nc_val[2545] = 0.893235; nc_val[2546] = 0.893268; nc_val[2547] = 0.893300; nc_val[2548] = 0.893333; nc_val[2549] = 0.893366; 
nc_val[2550] = 0.893399; nc_val[2551] = 0.893431; nc_val[2552] = 0.893464; nc_val[2553] = 0.893497; nc_val[2554] = 0.893530; nc_val[2555] = 0.893563; nc_val[2556] = 0.893595; nc_val[2557] = 0.893628; nc_val[2558] = 0.893661; nc_val[2559] = 0.893694; 
nc_val[2560] = 0.893727; nc_val[2561] = 0.893759; nc_val[2562] = 0.893792; nc_val[2563] = 0.893825; nc_val[2564] = 0.893858; nc_val[2565] = 0.893891; nc_val[2566] = 0.893923; nc_val[2567] = 0.893956; nc_val[2568] = 0.893989; nc_val[2569] = 0.894022; 
nc_val[2570] = 0.894055; nc_val[2571] = 0.894088; nc_val[2572] = 0.894120; nc_val[2573] = 0.894153; nc_val[2574] = 0.894186; nc_val[2575] = 0.894219; nc_val[2576] = 0.894252; nc_val[2577] = 0.894285; nc_val[2578] = 0.894318; nc_val[2579] = 0.894351; 
nc_val[2580] = 0.894383; nc_val[2581] = 0.894416; nc_val[2582] = 0.894449; nc_val[2583] = 0.894482; nc_val[2584] = 0.894515; nc_val[2585] = 0.894548; nc_val[2586] = 0.894581; nc_val[2587] = 0.894614; nc_val[2588] = 0.894646; nc_val[2589] = 0.894679; 
nc_val[2590] = 0.894712; nc_val[2591] = 0.894745; nc_val[2592] = 0.894778; nc_val[2593] = 0.894811; nc_val[2594] = 0.894844; nc_val[2595] = 0.894877; nc_val[2596] = 0.894910; nc_val[2597] = 0.894943; nc_val[2598] = 0.894976; nc_val[2599] = 0.895009; 
nc_val[2600] = 0.895042; nc_val[2601] = 0.895075; nc_val[2602] = 0.895107; nc_val[2603] = 0.895140; nc_val[2604] = 0.895173; nc_val[2605] = 0.895206; nc_val[2606] = 0.895239; nc_val[2607] = 0.895272; nc_val[2608] = 0.895305; nc_val[2609] = 0.895338; 
nc_val[2610] = 0.895371; nc_val[2611] = 0.895404; nc_val[2612] = 0.895437; nc_val[2613] = 0.895470; nc_val[2614] = 0.895503; nc_val[2615] = 0.895536; nc_val[2616] = 0.895569; nc_val[2617] = 0.895602; nc_val[2618] = 0.895635; nc_val[2619] = 0.895668; 
nc_val[2620] = 0.895701; nc_val[2621] = 0.895734; nc_val[2622] = 0.895767; nc_val[2623] = 0.895800; nc_val[2624] = 0.895833; nc_val[2625] = 0.895866; nc_val[2626] = 0.895899; nc_val[2627] = 0.895932; nc_val[2628] = 0.895965; nc_val[2629] = 0.895998; 
nc_val[2630] = 0.896031; nc_val[2631] = 0.896064; nc_val[2632] = 0.896097; nc_val[2633] = 0.896131; nc_val[2634] = 0.896164; nc_val[2635] = 0.896197; nc_val[2636] = 0.896230; nc_val[2637] = 0.896263; nc_val[2638] = 0.896296; nc_val[2639] = 0.896329; 
nc_val[2640] = 0.896362; nc_val[2641] = 0.896395; nc_val[2642] = 0.896428; nc_val[2643] = 0.896461; nc_val[2644] = 0.896494; nc_val[2645] = 0.896527; nc_val[2646] = 0.896561; nc_val[2647] = 0.896594; nc_val[2648] = 0.896627; nc_val[2649] = 0.896660; 
nc_val[2650] = 0.896693; nc_val[2651] = 0.896726; nc_val[2652] = 0.896759; nc_val[2653] = 0.896792; nc_val[2654] = 0.896825; nc_val[2655] = 0.896859; nc_val[2656] = 0.896892; nc_val[2657] = 0.896925; nc_val[2658] = 0.896958; nc_val[2659] = 0.896991; 
nc_val[2660] = 0.897024; nc_val[2661] = 0.897057; nc_val[2662] = 0.897091; nc_val[2663] = 0.897124; nc_val[2664] = 0.897157; nc_val[2665] = 0.897190; nc_val[2666] = 0.897223; nc_val[2667] = 0.897256; nc_val[2668] = 0.897290; nc_val[2669] = 0.897323; 
nc_val[2670] = 0.897356; nc_val[2671] = 0.897389; nc_val[2672] = 0.897422; nc_val[2673] = 0.897455; nc_val[2674] = 0.897489; nc_val[2675] = 0.897522; nc_val[2676] = 0.897555; nc_val[2677] = 0.897588; nc_val[2678] = 0.897622; nc_val[2679] = 0.897655; 
nc_val[2680] = 0.897688; nc_val[2681] = 0.897721; nc_val[2682] = 0.897754; nc_val[2683] = 0.897788; nc_val[2684] = 0.897821; nc_val[2685] = 0.897854; nc_val[2686] = 0.897887; nc_val[2687] = 0.897921; nc_val[2688] = 0.897954; nc_val[2689] = 0.897987; 
nc_val[2690] = 0.898020; nc_val[2691] = 0.898054; nc_val[2692] = 0.898087; nc_val[2693] = 0.898120; nc_val[2694] = 0.898153; nc_val[2695] = 0.898187; nc_val[2696] = 0.898220; nc_val[2697] = 0.898253; nc_val[2698] = 0.898286; nc_val[2699] = 0.898320; 
nc_val[2700] = 0.898353; nc_val[2701] = 0.898386; nc_val[2702] = 0.898420; nc_val[2703] = 0.898453; nc_val[2704] = 0.898486; nc_val[2705] = 0.898519; nc_val[2706] = 0.898553; nc_val[2707] = 0.898586; nc_val[2708] = 0.898619; nc_val[2709] = 0.898653; 
nc_val[2710] = 0.898686; nc_val[2711] = 0.898719; nc_val[2712] = 0.898753; nc_val[2713] = 0.898786; nc_val[2714] = 0.898819; nc_val[2715] = 0.898853; nc_val[2716] = 0.898886; nc_val[2717] = 0.898919; nc_val[2718] = 0.898953; nc_val[2719] = 0.898986; 
nc_val[2720] = 0.899019; nc_val[2721] = 0.899053; nc_val[2722] = 0.899086; nc_val[2723] = 0.899120; nc_val[2724] = 0.899153; nc_val[2725] = 0.899186; nc_val[2726] = 0.899220; nc_val[2727] = 0.899253; nc_val[2728] = 0.899286; nc_val[2729] = 0.899320; 
nc_val[2730] = 0.899353; nc_val[2731] = 0.899387; nc_val[2732] = 0.899420; nc_val[2733] = 0.899453; nc_val[2734] = 0.899487; nc_val[2735] = 0.899520; nc_val[2736] = 0.899554; nc_val[2737] = 0.899587; nc_val[2738] = 0.899621; nc_val[2739] = 0.899654; 
nc_val[2740] = 0.899687; nc_val[2741] = 0.899721; nc_val[2742] = 0.899754; nc_val[2743] = 0.899788; nc_val[2744] = 0.899821; nc_val[2745] = 0.899855; nc_val[2746] = 0.899888; nc_val[2747] = 0.899921; nc_val[2748] = 0.899955; nc_val[2749] = 0.899988; 
nc_val[2750] = 0.900022; nc_val[2751] = 0.900055; nc_val[2752] = 0.900089; nc_val[2753] = 0.900122; nc_val[2754] = 0.900156; nc_val[2755] = 0.900189; nc_val[2756] = 0.900223; nc_val[2757] = 0.900256; nc_val[2758] = 0.900290; nc_val[2759] = 0.900323; 
nc_val[2760] = 0.900357; nc_val[2761] = 0.900390; nc_val[2762] = 0.900424; nc_val[2763] = 0.900457; nc_val[2764] = 0.900491; nc_val[2765] = 0.900524; nc_val[2766] = 0.900558; nc_val[2767] = 0.900591; nc_val[2768] = 0.900625; nc_val[2769] = 0.900658; 
nc_val[2770] = 0.900692; nc_val[2771] = 0.900725; nc_val[2772] = 0.900759; nc_val[2773] = 0.900793; nc_val[2774] = 0.900826; nc_val[2775] = 0.900860; nc_val[2776] = 0.900893; nc_val[2777] = 0.900927; nc_val[2778] = 0.900960; nc_val[2779] = 0.900994; 
nc_val[2780] = 0.901027; nc_val[2781] = 0.901061; nc_val[2782] = 0.901095; nc_val[2783] = 0.901128; nc_val[2784] = 0.901162; nc_val[2785] = 0.901195; nc_val[2786] = 0.901229; nc_val[2787] = 0.901263; nc_val[2788] = 0.901296; nc_val[2789] = 0.901330; 
nc_val[2790] = 0.901363; nc_val[2791] = 0.901397; nc_val[2792] = 0.901431; nc_val[2793] = 0.901464; nc_val[2794] = 0.901498; nc_val[2795] = 0.901532; nc_val[2796] = 0.901565; nc_val[2797] = 0.901599; nc_val[2798] = 0.901632; nc_val[2799] = 0.901666; 
nc_val[2800] = 0.901700; nc_val[2801] = 0.901733; nc_val[2802] = 0.901767; nc_val[2803] = 0.901801; nc_val[2804] = 0.901834; nc_val[2805] = 0.901868; nc_val[2806] = 0.901902; nc_val[2807] = 0.901935; nc_val[2808] = 0.901969; nc_val[2809] = 0.902003; 
nc_val[2810] = 0.902036; nc_val[2811] = 0.902070; nc_val[2812] = 0.902104; nc_val[2813] = 0.902138; nc_val[2814] = 0.902171; nc_val[2815] = 0.902205; nc_val[2816] = 0.902239; nc_val[2817] = 0.902272; nc_val[2818] = 0.902306; nc_val[2819] = 0.902340; 
nc_val[2820] = 0.902373; nc_val[2821] = 0.902407; nc_val[2822] = 0.902441; nc_val[2823] = 0.902475; nc_val[2824] = 0.902508; nc_val[2825] = 0.902542; nc_val[2826] = 0.902576; nc_val[2827] = 0.902610; nc_val[2828] = 0.902643; nc_val[2829] = 0.902677; 
nc_val[2830] = 0.902711; nc_val[2831] = 0.902745; nc_val[2832] = 0.902778; nc_val[2833] = 0.902812; nc_val[2834] = 0.902846; nc_val[2835] = 0.902880; nc_val[2836] = 0.902914; nc_val[2837] = 0.902947; nc_val[2838] = 0.902981; nc_val[2839] = 0.903015; 
nc_val[2840] = 0.903049; nc_val[2841] = 0.903083; nc_val[2842] = 0.903116; nc_val[2843] = 0.903150; nc_val[2844] = 0.903184; nc_val[2845] = 0.903218; nc_val[2846] = 0.903252; nc_val[2847] = 0.903285; nc_val[2848] = 0.903319; nc_val[2849] = 0.903353; 
nc_val[2850] = 0.903387; nc_val[2851] = 0.903421; nc_val[2852] = 0.903455; nc_val[2853] = 0.903488; nc_val[2854] = 0.903522; nc_val[2855] = 0.903556; nc_val[2856] = 0.903590; nc_val[2857] = 0.903624; nc_val[2858] = 0.903658; nc_val[2859] = 0.903692; 
nc_val[2860] = 0.903725; nc_val[2861] = 0.903759; nc_val[2862] = 0.903793; nc_val[2863] = 0.903827; nc_val[2864] = 0.903861; nc_val[2865] = 0.903895; nc_val[2866] = 0.903929; nc_val[2867] = 0.903963; nc_val[2868] = 0.903997; nc_val[2869] = 0.904030; 
nc_val[2870] = 0.904064; nc_val[2871] = 0.904098; nc_val[2872] = 0.904132; nc_val[2873] = 0.904166; nc_val[2874] = 0.904200; nc_val[2875] = 0.904234; nc_val[2876] = 0.904268; nc_val[2877] = 0.904302; nc_val[2878] = 0.904336; nc_val[2879] = 0.904370; 
nc_val[2880] = 0.904404; nc_val[2881] = 0.904438; nc_val[2882] = 0.904472; nc_val[2883] = 0.904506; nc_val[2884] = 0.904540; nc_val[2885] = 0.904574; nc_val[2886] = 0.904608; nc_val[2887] = 0.904641; nc_val[2888] = 0.904675; nc_val[2889] = 0.904709; 
nc_val[2890] = 0.904743; nc_val[2891] = 0.904777; nc_val[2892] = 0.904811; nc_val[2893] = 0.904845; nc_val[2894] = 0.904879; nc_val[2895] = 0.904913; nc_val[2896] = 0.904947; nc_val[2897] = 0.904981; nc_val[2898] = 0.905015; nc_val[2899] = 0.905050; 
nc_val[2900] = 0.905084; nc_val[2901] = 0.905118; nc_val[2902] = 0.905152; nc_val[2903] = 0.905186; nc_val[2904] = 0.905220; nc_val[2905] = 0.905254; nc_val[2906] = 0.905288; nc_val[2907] = 0.905322; nc_val[2908] = 0.905356; nc_val[2909] = 0.905390; 
nc_val[2910] = 0.905424; nc_val[2911] = 0.905458; nc_val[2912] = 0.905492; nc_val[2913] = 0.905526; nc_val[2914] = 0.905560; nc_val[2915] = 0.905594; nc_val[2916] = 0.905628; nc_val[2917] = 0.905663; nc_val[2918] = 0.905697; nc_val[2919] = 0.905731; 
nc_val[2920] = 0.905765; nc_val[2921] = 0.905799; nc_val[2922] = 0.905833; nc_val[2923] = 0.905867; nc_val[2924] = 0.905901; nc_val[2925] = 0.905935; nc_val[2926] = 0.905970; nc_val[2927] = 0.906004; nc_val[2928] = 0.906038; nc_val[2929] = 0.906072; 
nc_val[2930] = 0.906106; nc_val[2931] = 0.906140; nc_val[2932] = 0.906174; nc_val[2933] = 0.906209; nc_val[2934] = 0.906243; nc_val[2935] = 0.906277; nc_val[2936] = 0.906311; nc_val[2937] = 0.906345; nc_val[2938] = 0.906379; nc_val[2939] = 0.906414; 
nc_val[2940] = 0.906448; nc_val[2941] = 0.906482; nc_val[2942] = 0.906516; nc_val[2943] = 0.906550; nc_val[2944] = 0.906585; nc_val[2945] = 0.906619; nc_val[2946] = 0.906653; nc_val[2947] = 0.906687; nc_val[2948] = 0.906721; nc_val[2949] = 0.906756; 
nc_val[2950] = 0.906790; nc_val[2951] = 0.906824; nc_val[2952] = 0.906858; nc_val[2953] = 0.906893; nc_val[2954] = 0.906927; nc_val[2955] = 0.906961; nc_val[2956] = 0.906995; nc_val[2957] = 0.907030; nc_val[2958] = 0.907064; nc_val[2959] = 0.907098; 
nc_val[2960] = 0.907132; nc_val[2961] = 0.907167; nc_val[2962] = 0.907201; nc_val[2963] = 0.907235; nc_val[2964] = 0.907269; nc_val[2965] = 0.907304; nc_val[2966] = 0.907338; nc_val[2967] = 0.907372; nc_val[2968] = 0.907407; nc_val[2969] = 0.907441; 
nc_val[2970] = 0.907475; nc_val[2971] = 0.907510; nc_val[2972] = 0.907544; nc_val[2973] = 0.907578; nc_val[2974] = 0.907612; nc_val[2975] = 0.907647; nc_val[2976] = 0.907681; nc_val[2977] = 0.907715; nc_val[2978] = 0.907750; nc_val[2979] = 0.907784; 
nc_val[2980] = 0.907818; nc_val[2981] = 0.907853; nc_val[2982] = 0.907887; nc_val[2983] = 0.907922; nc_val[2984] = 0.907956; nc_val[2985] = 0.907990; nc_val[2986] = 0.908025; nc_val[2987] = 0.908059; nc_val[2988] = 0.908093; nc_val[2989] = 0.908128; 
nc_val[2990] = 0.908162; nc_val[2991] = 0.908197; nc_val[2992] = 0.908231; nc_val[2993] = 0.908265; nc_val[2994] = 0.908300; nc_val[2995] = 0.908334; nc_val[2996] = 0.908369; nc_val[2997] = 0.908403; nc_val[2998] = 0.908437; nc_val[2999] = 0.908472; 
nc_val[3000] = 0.908506; nc_val[3001] = 0.908541; nc_val[3002] = 0.908575; nc_val[3003] = 0.908610; nc_val[3004] = 0.908644; nc_val[3005] = 0.908678; nc_val[3006] = 0.908713; nc_val[3007] = 0.908747; nc_val[3008] = 0.908782; nc_val[3009] = 0.908816; 
nc_val[3010] = 0.908851; nc_val[3011] = 0.908885; nc_val[3012] = 0.908920; nc_val[3013] = 0.908954; nc_val[3014] = 0.908989; nc_val[3015] = 0.909023; nc_val[3016] = 0.909058; nc_val[3017] = 0.909092; nc_val[3018] = 0.909127; nc_val[3019] = 0.909161; 
nc_val[3020] = 0.909196; nc_val[3021] = 0.909230; nc_val[3022] = 0.909265; nc_val[3023] = 0.909299; nc_val[3024] = 0.909334; nc_val[3025] = 0.909368; nc_val[3026] = 0.909403; nc_val[3027] = 0.909437; nc_val[3028] = 0.909472; nc_val[3029] = 0.909506; 
nc_val[3030] = 0.909541; nc_val[3031] = 0.909575; nc_val[3032] = 0.909610; nc_val[3033] = 0.909645; nc_val[3034] = 0.909679; nc_val[3035] = 0.909714; nc_val[3036] = 0.909748; nc_val[3037] = 0.909783; nc_val[3038] = 0.909817; nc_val[3039] = 0.909852; 
nc_val[3040] = 0.909887; nc_val[3041] = 0.909921; nc_val[3042] = 0.909956; nc_val[3043] = 0.909990; nc_val[3044] = 0.910025; nc_val[3045] = 0.910060; nc_val[3046] = 0.910094; nc_val[3047] = 0.910129; nc_val[3048] = 0.910164; nc_val[3049] = 0.910198; 
nc_val[3050] = 0.910233; nc_val[3051] = 0.910267; nc_val[3052] = 0.910302; nc_val[3053] = 0.910337; nc_val[3054] = 0.910371; nc_val[3055] = 0.910406; nc_val[3056] = 0.910441; nc_val[3057] = 0.910475; nc_val[3058] = 0.910510; nc_val[3059] = 0.910545; 
nc_val[3060] = 0.910579; nc_val[3061] = 0.910614; nc_val[3062] = 0.910649; nc_val[3063] = 0.910683; nc_val[3064] = 0.910718; nc_val[3065] = 0.910753; nc_val[3066] = 0.910787; nc_val[3067] = 0.910822; nc_val[3068] = 0.910857; nc_val[3069] = 0.910892; 
nc_val[3070] = 0.910926; nc_val[3071] = 0.910961; nc_val[3072] = 0.910996; nc_val[3073] = 0.911031; nc_val[3074] = 0.911065; nc_val[3075] = 0.911100; nc_val[3076] = 0.911135; nc_val[3077] = 0.911169; nc_val[3078] = 0.911204; nc_val[3079] = 0.911239; 
nc_val[3080] = 0.911274; nc_val[3081] = 0.911309; nc_val[3082] = 0.911343; nc_val[3083] = 0.911378; nc_val[3084] = 0.911413; nc_val[3085] = 0.911448; nc_val[3086] = 0.911482; nc_val[3087] = 0.911517; nc_val[3088] = 0.911552; nc_val[3089] = 0.911587; 
nc_val[3090] = 0.911622; nc_val[3091] = 0.911656; nc_val[3092] = 0.911691; nc_val[3093] = 0.911726; nc_val[3094] = 0.911761; nc_val[3095] = 0.911796; nc_val[3096] = 0.911831; nc_val[3097] = 0.911865; nc_val[3098] = 0.911900; nc_val[3099] = 0.911935; 
nc_val[3100] = 0.911970; nc_val[3101] = 0.912005; nc_val[3102] = 0.912040; nc_val[3103] = 0.912074; nc_val[3104] = 0.912109; nc_val[3105] = 0.912144; nc_val[3106] = 0.912179; nc_val[3107] = 0.912214; nc_val[3108] = 0.912249; nc_val[3109] = 0.912284; 
nc_val[3110] = 0.912319; nc_val[3111] = 0.912353; nc_val[3112] = 0.912388; nc_val[3113] = 0.912423; nc_val[3114] = 0.912458; nc_val[3115] = 0.912493; nc_val[3116] = 0.912528; nc_val[3117] = 0.912563; nc_val[3118] = 0.912598; nc_val[3119] = 0.912633; 
nc_val[3120] = 0.912668; nc_val[3121] = 0.912703; nc_val[3122] = 0.912738; nc_val[3123] = 0.912773; nc_val[3124] = 0.912807; nc_val[3125] = 0.912842; nc_val[3126] = 0.912877; nc_val[3127] = 0.912912; nc_val[3128] = 0.912947; nc_val[3129] = 0.912982; 
nc_val[3130] = 0.913017; nc_val[3131] = 0.913052; nc_val[3132] = 0.913087; nc_val[3133] = 0.913122; nc_val[3134] = 0.913157; nc_val[3135] = 0.913192; nc_val[3136] = 0.913227; nc_val[3137] = 0.913262; nc_val[3138] = 0.913297; nc_val[3139] = 0.913332; 
nc_val[3140] = 0.913367; nc_val[3141] = 0.913402; nc_val[3142] = 0.913437; nc_val[3143] = 0.913472; nc_val[3144] = 0.913507; nc_val[3145] = 0.913542; nc_val[3146] = 0.913578; nc_val[3147] = 0.913613; nc_val[3148] = 0.913648; nc_val[3149] = 0.913683; 
nc_val[3150] = 0.913718; nc_val[3151] = 0.913753; nc_val[3152] = 0.913788; nc_val[3153] = 0.913823; nc_val[3154] = 0.913858; nc_val[3155] = 0.913893; nc_val[3156] = 0.913928; nc_val[3157] = 0.913963; nc_val[3158] = 0.913998; nc_val[3159] = 0.914034; 
nc_val[3160] = 0.914069; nc_val[3161] = 0.914104; nc_val[3162] = 0.914139; nc_val[3163] = 0.914174; nc_val[3164] = 0.914209; nc_val[3165] = 0.914244; nc_val[3166] = 0.914279; nc_val[3167] = 0.914315; nc_val[3168] = 0.914350; nc_val[3169] = 0.914385; 
nc_val[3170] = 0.914420; nc_val[3171] = 0.914455; nc_val[3172] = 0.914490; nc_val[3173] = 0.914525; nc_val[3174] = 0.914561; nc_val[3175] = 0.914596; nc_val[3176] = 0.914631; nc_val[3177] = 0.914666; nc_val[3178] = 0.914701; nc_val[3179] = 0.914737; 
nc_val[3180] = 0.914772; nc_val[3181] = 0.914807; nc_val[3182] = 0.914842; nc_val[3183] = 0.914877; nc_val[3184] = 0.914913; nc_val[3185] = 0.914948; nc_val[3186] = 0.914983; nc_val[3187] = 0.915018; nc_val[3188] = 0.915054; nc_val[3189] = 0.915089; 
nc_val[3190] = 0.915124; nc_val[3191] = 0.915159; nc_val[3192] = 0.915195; nc_val[3193] = 0.915230; nc_val[3194] = 0.915265; nc_val[3195] = 0.915300; nc_val[3196] = 0.915336; nc_val[3197] = 0.915371; nc_val[3198] = 0.915406; nc_val[3199] = 0.915441; 
nc_val[3200] = 0.915477; nc_val[3201] = 0.915512; nc_val[3202] = 0.915547; nc_val[3203] = 0.915583; nc_val[3204] = 0.915618; nc_val[3205] = 0.915653; nc_val[3206] = 0.915689; nc_val[3207] = 0.915724; nc_val[3208] = 0.915759; nc_val[3209] = 0.915795; 
nc_val[3210] = 0.915830; nc_val[3211] = 0.915865; nc_val[3212] = 0.915901; nc_val[3213] = 0.915936; nc_val[3214] = 0.915971; nc_val[3215] = 0.916007; nc_val[3216] = 0.916042; nc_val[3217] = 0.916077; nc_val[3218] = 0.916113; nc_val[3219] = 0.916148; 
nc_val[3220] = 0.916184; nc_val[3221] = 0.916219; nc_val[3222] = 0.916254; nc_val[3223] = 0.916290; nc_val[3224] = 0.916325; nc_val[3225] = 0.916361; nc_val[3226] = 0.916396; nc_val[3227] = 0.916431; nc_val[3228] = 0.916467; nc_val[3229] = 0.916502; 
nc_val[3230] = 0.916538; nc_val[3231] = 0.916573; nc_val[3232] = 0.916608; nc_val[3233] = 0.916644; nc_val[3234] = 0.916679; nc_val[3235] = 0.916715; nc_val[3236] = 0.916750; nc_val[3237] = 0.916786; nc_val[3238] = 0.916821; nc_val[3239] = 0.916857; 
nc_val[3240] = 0.916892; nc_val[3241] = 0.916928; nc_val[3242] = 0.916963; nc_val[3243] = 0.916999; nc_val[3244] = 0.917034; nc_val[3245] = 0.917070; nc_val[3246] = 0.917105; nc_val[3247] = 0.917141; nc_val[3248] = 0.917176; nc_val[3249] = 0.917212; 
nc_val[3250] = 0.917247; nc_val[3251] = 0.917283; nc_val[3252] = 0.917318; nc_val[3253] = 0.917354; nc_val[3254] = 0.917389; nc_val[3255] = 0.917425; nc_val[3256] = 0.917460; nc_val[3257] = 0.917496; nc_val[3258] = 0.917532; nc_val[3259] = 0.917567; 
nc_val[3260] = 0.917603; nc_val[3261] = 0.917638; nc_val[3262] = 0.917674; nc_val[3263] = 0.917709; nc_val[3264] = 0.917745; nc_val[3265] = 0.917781; nc_val[3266] = 0.917816; nc_val[3267] = 0.917852; nc_val[3268] = 0.917887; nc_val[3269] = 0.917923; 
nc_val[3270] = 0.917959; nc_val[3271] = 0.917994; nc_val[3272] = 0.918030; nc_val[3273] = 0.918066; nc_val[3274] = 0.918101; nc_val[3275] = 0.918137; nc_val[3276] = 0.918172; nc_val[3277] = 0.918208; nc_val[3278] = 0.918244; nc_val[3279] = 0.918279; 
nc_val[3280] = 0.918315; nc_val[3281] = 0.918351; nc_val[3282] = 0.918386; nc_val[3283] = 0.918422; nc_val[3284] = 0.918458; nc_val[3285] = 0.918493; nc_val[3286] = 0.918529; nc_val[3287] = 0.918565; nc_val[3288] = 0.918601; nc_val[3289] = 0.918636; 
nc_val[3290] = 0.918672; nc_val[3291] = 0.918708; nc_val[3292] = 0.918743; nc_val[3293] = 0.918779; nc_val[3294] = 0.918815; nc_val[3295] = 0.918851; nc_val[3296] = 0.918886; nc_val[3297] = 0.918922; nc_val[3298] = 0.918958; nc_val[3299] = 0.918994; 
nc_val[3300] = 0.919029; nc_val[3301] = 0.919065; nc_val[3302] = 0.919101; nc_val[3303] = 0.919137; nc_val[3304] = 0.919172; nc_val[3305] = 0.919208; nc_val[3306] = 0.919244; nc_val[3307] = 0.919280; nc_val[3308] = 0.919316; nc_val[3309] = 0.919351; 
nc_val[3310] = 0.919387; nc_val[3311] = 0.919423; nc_val[3312] = 0.919459; nc_val[3313] = 0.919495; nc_val[3314] = 0.919531; nc_val[3315] = 0.919566; nc_val[3316] = 0.919602; nc_val[3317] = 0.919638; nc_val[3318] = 0.919674; nc_val[3319] = 0.919710; 
nc_val[3320] = 0.919746; nc_val[3321] = 0.919782; nc_val[3322] = 0.919817; nc_val[3323] = 0.919853; nc_val[3324] = 0.919889; nc_val[3325] = 0.919925; nc_val[3326] = 0.919961; nc_val[3327] = 0.919997; nc_val[3328] = 0.920033; nc_val[3329] = 0.920069; 
nc_val[3330] = 0.920105; nc_val[3331] = 0.920140; nc_val[3332] = 0.920176; nc_val[3333] = 0.920212; nc_val[3334] = 0.920248; nc_val[3335] = 0.920284; nc_val[3336] = 0.920320; nc_val[3337] = 0.920356; nc_val[3338] = 0.920392; nc_val[3339] = 0.920428; 
nc_val[3340] = 0.920464; nc_val[3341] = 0.920500; nc_val[3342] = 0.920536; nc_val[3343] = 0.920572; nc_val[3344] = 0.920608; nc_val[3345] = 0.920644; nc_val[3346] = 0.920680; nc_val[3347] = 0.920716; nc_val[3348] = 0.920752; nc_val[3349] = 0.920788; 
nc_val[3350] = 0.920824; nc_val[3351] = 0.920860; nc_val[3352] = 0.920896; nc_val[3353] = 0.920932; nc_val[3354] = 0.920968; nc_val[3355] = 0.921004; nc_val[3356] = 0.921040; nc_val[3357] = 0.921076; nc_val[3358] = 0.921112; nc_val[3359] = 0.921148; 
nc_val[3360] = 0.921184; nc_val[3361] = 0.921220; nc_val[3362] = 0.921256; nc_val[3363] = 0.921292; nc_val[3364] = 0.921328; nc_val[3365] = 0.921364; nc_val[3366] = 0.921401; nc_val[3367] = 0.921437; nc_val[3368] = 0.921473; nc_val[3369] = 0.921509; 
nc_val[3370] = 0.921545; nc_val[3371] = 0.921581; nc_val[3372] = 0.921617; nc_val[3373] = 0.921653; nc_val[3374] = 0.921689; nc_val[3375] = 0.921726; nc_val[3376] = 0.921762; nc_val[3377] = 0.921798; nc_val[3378] = 0.921834; nc_val[3379] = 0.921870; 
nc_val[3380] = 0.921906; nc_val[3381] = 0.921942; nc_val[3382] = 0.921979; nc_val[3383] = 0.922015; nc_val[3384] = 0.922051; nc_val[3385] = 0.922087; nc_val[3386] = 0.922123; nc_val[3387] = 0.922160; nc_val[3388] = 0.922196; nc_val[3389] = 0.922232; 
nc_val[3390] = 0.922268; nc_val[3391] = 0.922304; nc_val[3392] = 0.922341; nc_val[3393] = 0.922377; nc_val[3394] = 0.922413; nc_val[3395] = 0.922449; nc_val[3396] = 0.922486; nc_val[3397] = 0.922522; nc_val[3398] = 0.922558; nc_val[3399] = 0.922594; 
nc_val[3400] = 0.922631; nc_val[3401] = 0.922667; nc_val[3402] = 0.922703; nc_val[3403] = 0.922739; nc_val[3404] = 0.922776; nc_val[3405] = 0.922812; nc_val[3406] = 0.922848; nc_val[3407] = 0.922885; nc_val[3408] = 0.922921; nc_val[3409] = 0.922957; 
nc_val[3410] = 0.922993; nc_val[3411] = 0.923030; nc_val[3412] = 0.923066; nc_val[3413] = 0.923102; nc_val[3414] = 0.923139; nc_val[3415] = 0.923175; nc_val[3416] = 0.923211; nc_val[3417] = 0.923248; nc_val[3418] = 0.923284; nc_val[3419] = 0.923321; 
nc_val[3420] = 0.923357; nc_val[3421] = 0.923393; nc_val[3422] = 0.923430; nc_val[3423] = 0.923466; nc_val[3424] = 0.923502; nc_val[3425] = 0.923539; nc_val[3426] = 0.923575; nc_val[3427] = 0.923612; nc_val[3428] = 0.923648; nc_val[3429] = 0.923684; 
nc_val[3430] = 0.923721; nc_val[3431] = 0.923757; nc_val[3432] = 0.923794; nc_val[3433] = 0.923830; nc_val[3434] = 0.923867; nc_val[3435] = 0.923903; nc_val[3436] = 0.923939; nc_val[3437] = 0.923976; nc_val[3438] = 0.924012; nc_val[3439] = 0.924049; 
nc_val[3440] = 0.924085; nc_val[3441] = 0.924122; nc_val[3442] = 0.924158; nc_val[3443] = 0.924195; nc_val[3444] = 0.924231; nc_val[3445] = 0.924268; nc_val[3446] = 0.924304; nc_val[3447] = 0.924341; nc_val[3448] = 0.924377; nc_val[3449] = 0.924414; 
nc_val[3450] = 0.924450; nc_val[3451] = 0.924487; nc_val[3452] = 0.924523; nc_val[3453] = 0.924560; nc_val[3454] = 0.924596; nc_val[3455] = 0.924633; nc_val[3456] = 0.924670; nc_val[3457] = 0.924706; nc_val[3458] = 0.924743; nc_val[3459] = 0.924779; 
nc_val[3460] = 0.924816; nc_val[3461] = 0.924852; nc_val[3462] = 0.924889; nc_val[3463] = 0.924926; nc_val[3464] = 0.924962; nc_val[3465] = 0.924999; nc_val[3466] = 0.925035; nc_val[3467] = 0.925072; nc_val[3468] = 0.925109; nc_val[3469] = 0.925145; 
nc_val[3470] = 0.925182; nc_val[3471] = 0.925219; nc_val[3472] = 0.925255; nc_val[3473] = 0.925292; nc_val[3474] = 0.925329; nc_val[3475] = 0.925365; nc_val[3476] = 0.925402; nc_val[3477] = 0.925438; nc_val[3478] = 0.925475; nc_val[3479] = 0.925512; 
nc_val[3480] = 0.925549; nc_val[3481] = 0.925585; nc_val[3482] = 0.925622; nc_val[3483] = 0.925659; nc_val[3484] = 0.925695; nc_val[3485] = 0.925732; nc_val[3486] = 0.925769; nc_val[3487] = 0.925805; nc_val[3488] = 0.925842; nc_val[3489] = 0.925879; 
nc_val[3490] = 0.925916; nc_val[3491] = 0.925952; nc_val[3492] = 0.925989; nc_val[3493] = 0.926026; nc_val[3494] = 0.926063; nc_val[3495] = 0.926099; nc_val[3496] = 0.926136; nc_val[3497] = 0.926173; nc_val[3498] = 0.926210; nc_val[3499] = 0.926247; 
nc_val[3500] = 0.926283; nc_val[3501] = 0.926320; nc_val[3502] = 0.926357; nc_val[3503] = 0.926394; nc_val[3504] = 0.926431; nc_val[3505] = 0.926467; nc_val[3506] = 0.926504; nc_val[3507] = 0.926541; nc_val[3508] = 0.926578; nc_val[3509] = 0.926615; 
nc_val[3510] = 0.926652; nc_val[3511] = 0.926689; nc_val[3512] = 0.926725; nc_val[3513] = 0.926762; nc_val[3514] = 0.926799; nc_val[3515] = 0.926836; nc_val[3516] = 0.926873; nc_val[3517] = 0.926910; nc_val[3518] = 0.926947; nc_val[3519] = 0.926984; 
nc_val[3520] = 0.927020; nc_val[3521] = 0.927057; nc_val[3522] = 0.927094; nc_val[3523] = 0.927131; nc_val[3524] = 0.927168; nc_val[3525] = 0.927205; nc_val[3526] = 0.927242; nc_val[3527] = 0.927279; nc_val[3528] = 0.927316; nc_val[3529] = 0.927353; 
nc_val[3530] = 0.927390; nc_val[3531] = 0.927427; nc_val[3532] = 0.927464; nc_val[3533] = 0.927501; nc_val[3534] = 0.927538; nc_val[3535] = 0.927575; nc_val[3536] = 0.927612; nc_val[3537] = 0.927649; nc_val[3538] = 0.927686; nc_val[3539] = 0.927723; 
nc_val[3540] = 0.927760; nc_val[3541] = 0.927797; nc_val[3542] = 0.927834; nc_val[3543] = 0.927871; nc_val[3544] = 0.927908; nc_val[3545] = 0.927945; nc_val[3546] = 0.927982; nc_val[3547] = 0.928019; nc_val[3548] = 0.928056; nc_val[3549] = 0.928093; 
nc_val[3550] = 0.928130; nc_val[3551] = 0.928167; nc_val[3552] = 0.928204; nc_val[3553] = 0.928242; nc_val[3554] = 0.928279; nc_val[3555] = 0.928316; nc_val[3556] = 0.928353; nc_val[3557] = 0.928390; nc_val[3558] = 0.928427; nc_val[3559] = 0.928464; 
nc_val[3560] = 0.928501; nc_val[3561] = 0.928539; nc_val[3562] = 0.928576; nc_val[3563] = 0.928613; nc_val[3564] = 0.928650; nc_val[3565] = 0.928687; nc_val[3566] = 0.928724; nc_val[3567] = 0.928761; nc_val[3568] = 0.928799; nc_val[3569] = 0.928836; 
nc_val[3570] = 0.928873; nc_val[3571] = 0.928910; nc_val[3572] = 0.928947; nc_val[3573] = 0.928985; nc_val[3574] = 0.929022; nc_val[3575] = 0.929059; nc_val[3576] = 0.929096; nc_val[3577] = 0.929134; nc_val[3578] = 0.929171; nc_val[3579] = 0.929208; 
nc_val[3580] = 0.929245; nc_val[3581] = 0.929283; nc_val[3582] = 0.929320; nc_val[3583] = 0.929357; nc_val[3584] = 0.929394; nc_val[3585] = 0.929432; nc_val[3586] = 0.929469; nc_val[3587] = 0.929506; nc_val[3588] = 0.929543; nc_val[3589] = 0.929581; 
nc_val[3590] = 0.929618; nc_val[3591] = 0.929655; nc_val[3592] = 0.929693; nc_val[3593] = 0.929730; nc_val[3594] = 0.929767; nc_val[3595] = 0.929805; nc_val[3596] = 0.929842; nc_val[3597] = 0.929879; nc_val[3598] = 0.929917; nc_val[3599] = 0.929954; 
nc_val[3600] = 0.929991; nc_val[3601] = 0.930029; nc_val[3602] = 0.930066; nc_val[3603] = 0.930104; nc_val[3604] = 0.930141; nc_val[3605] = 0.930178; nc_val[3606] = 0.930216; nc_val[3607] = 0.930253; nc_val[3608] = 0.930291; nc_val[3609] = 0.930328; 
nc_val[3610] = 0.930365; nc_val[3611] = 0.930403; nc_val[3612] = 0.930440; nc_val[3613] = 0.930478; nc_val[3614] = 0.930515; nc_val[3615] = 0.930553; nc_val[3616] = 0.930590; nc_val[3617] = 0.930628; nc_val[3618] = 0.930665; nc_val[3619] = 0.930703; 
nc_val[3620] = 0.930740; nc_val[3621] = 0.930778; nc_val[3622] = 0.930815; nc_val[3623] = 0.930853; nc_val[3624] = 0.930890; nc_val[3625] = 0.930928; nc_val[3626] = 0.930965; nc_val[3627] = 0.931003; nc_val[3628] = 0.931040; nc_val[3629] = 0.931078; 
nc_val[3630] = 0.931115; nc_val[3631] = 0.931153; nc_val[3632] = 0.931190; nc_val[3633] = 0.931228; nc_val[3634] = 0.931265; nc_val[3635] = 0.931303; nc_val[3636] = 0.931341; nc_val[3637] = 0.931378; nc_val[3638] = 0.931416; nc_val[3639] = 0.931453; 
nc_val[3640] = 0.931491; nc_val[3641] = 0.931529; nc_val[3642] = 0.931566; nc_val[3643] = 0.931604; nc_val[3644] = 0.931642; nc_val[3645] = 0.931679; nc_val[3646] = 0.931717; nc_val[3647] = 0.931754; nc_val[3648] = 0.931792; nc_val[3649] = 0.931830; 
nc_val[3650] = 0.931867; nc_val[3651] = 0.931905; nc_val[3652] = 0.931943; nc_val[3653] = 0.931980; nc_val[3654] = 0.932018; nc_val[3655] = 0.932056; nc_val[3656] = 0.932094; nc_val[3657] = 0.932131; nc_val[3658] = 0.932169; nc_val[3659] = 0.932207; 
nc_val[3660] = 0.932244; nc_val[3661] = 0.932282; nc_val[3662] = 0.932320; nc_val[3663] = 0.932358; nc_val[3664] = 0.932395; nc_val[3665] = 0.932433; nc_val[3666] = 0.932471; nc_val[3667] = 0.932509; nc_val[3668] = 0.932547; nc_val[3669] = 0.932584; 
nc_val[3670] = 0.932622; nc_val[3671] = 0.932660; nc_val[3672] = 0.932698; nc_val[3673] = 0.932736; nc_val[3674] = 0.932773; nc_val[3675] = 0.932811; nc_val[3676] = 0.932849; nc_val[3677] = 0.932887; nc_val[3678] = 0.932925; nc_val[3679] = 0.932962; 
nc_val[3680] = 0.933000; nc_val[3681] = 0.933038; nc_val[3682] = 0.933076; nc_val[3683] = 0.933114; nc_val[3684] = 0.933152; nc_val[3685] = 0.933190; nc_val[3686] = 0.933228; nc_val[3687] = 0.933266; nc_val[3688] = 0.933303; nc_val[3689] = 0.933341; 
nc_val[3690] = 0.933379; nc_val[3691] = 0.933417; nc_val[3692] = 0.933455; nc_val[3693] = 0.933493; nc_val[3694] = 0.933531; nc_val[3695] = 0.933569; nc_val[3696] = 0.933607; nc_val[3697] = 0.933645; nc_val[3698] = 0.933683; nc_val[3699] = 0.933721; 
nc_val[3700] = 0.933759; nc_val[3701] = 0.933797; nc_val[3702] = 0.933835; nc_val[3703] = 0.933873; nc_val[3704] = 0.933911; nc_val[3705] = 0.933949; nc_val[3706] = 0.933987; nc_val[3707] = 0.934025; nc_val[3708] = 0.934063; nc_val[3709] = 0.934101; 
nc_val[3710] = 0.934139; nc_val[3711] = 0.934177; nc_val[3712] = 0.934215; nc_val[3713] = 0.934253; nc_val[3714] = 0.934291; nc_val[3715] = 0.934329; nc_val[3716] = 0.934367; nc_val[3717] = 0.934405; nc_val[3718] = 0.934444; nc_val[3719] = 0.934482; 
nc_val[3720] = 0.934520; nc_val[3721] = 0.934558; nc_val[3722] = 0.934596; nc_val[3723] = 0.934634; nc_val[3724] = 0.934672; nc_val[3725] = 0.934710; nc_val[3726] = 0.934749; nc_val[3727] = 0.934787; nc_val[3728] = 0.934825; nc_val[3729] = 0.934863; 
nc_val[3730] = 0.934901; nc_val[3731] = 0.934939; nc_val[3732] = 0.934978; nc_val[3733] = 0.935016; nc_val[3734] = 0.935054; nc_val[3735] = 0.935092; nc_val[3736] = 0.935130; nc_val[3737] = 0.935169; nc_val[3738] = 0.935207; nc_val[3739] = 0.935245; 
nc_val[3740] = 0.935283; nc_val[3741] = 0.935322; nc_val[3742] = 0.935360; nc_val[3743] = 0.935398; nc_val[3744] = 0.935436; nc_val[3745] = 0.935475; nc_val[3746] = 0.935513; nc_val[3747] = 0.935551; nc_val[3748] = 0.935589; nc_val[3749] = 0.935628; 
nc_val[3750] = 0.935666; nc_val[3751] = 0.935704; nc_val[3752] = 0.935743; nc_val[3753] = 0.935781; nc_val[3754] = 0.935819; nc_val[3755] = 0.935858; nc_val[3756] = 0.935896; nc_val[3757] = 0.935934; nc_val[3758] = 0.935973; nc_val[3759] = 0.936011; 
nc_val[3760] = 0.936049; nc_val[3761] = 0.936088; nc_val[3762] = 0.936126; nc_val[3763] = 0.936165; nc_val[3764] = 0.936203; nc_val[3765] = 0.936241; nc_val[3766] = 0.936280; nc_val[3767] = 0.936318; nc_val[3768] = 0.936357; nc_val[3769] = 0.936395; 
nc_val[3770] = 0.936434; nc_val[3771] = 0.936472; nc_val[3772] = 0.936510; nc_val[3773] = 0.936549; nc_val[3774] = 0.936587; nc_val[3775] = 0.936626; nc_val[3776] = 0.936664; nc_val[3777] = 0.936703; nc_val[3778] = 0.936741; nc_val[3779] = 0.936780; 
nc_val[3780] = 0.936818; nc_val[3781] = 0.936857; nc_val[3782] = 0.936895; nc_val[3783] = 0.936934; nc_val[3784] = 0.936972; nc_val[3785] = 0.937011; nc_val[3786] = 0.937049; nc_val[3787] = 0.937088; nc_val[3788] = 0.937127; nc_val[3789] = 0.937165; 
nc_val[3790] = 0.937204; nc_val[3791] = 0.937242; nc_val[3792] = 0.937281; nc_val[3793] = 0.937320; nc_val[3794] = 0.937358; nc_val[3795] = 0.937397; nc_val[3796] = 0.937435; nc_val[3797] = 0.937474; nc_val[3798] = 0.937513; nc_val[3799] = 0.937551; 
nc_val[3800] = 0.937590; nc_val[3801] = 0.937629; nc_val[3802] = 0.937667; nc_val[3803] = 0.937706; nc_val[3804] = 0.937745; nc_val[3805] = 0.937783; nc_val[3806] = 0.937822; nc_val[3807] = 0.937861; nc_val[3808] = 0.937899; nc_val[3809] = 0.937938; 
nc_val[3810] = 0.937977; nc_val[3811] = 0.938015; nc_val[3812] = 0.938054; nc_val[3813] = 0.938093; nc_val[3814] = 0.938132; nc_val[3815] = 0.938170; nc_val[3816] = 0.938209; nc_val[3817] = 0.938248; nc_val[3818] = 0.938287; nc_val[3819] = 0.938325; 
nc_val[3820] = 0.938364; nc_val[3821] = 0.938403; nc_val[3822] = 0.938442; nc_val[3823] = 0.938481; nc_val[3824] = 0.938519; nc_val[3825] = 0.938558; nc_val[3826] = 0.938597; nc_val[3827] = 0.938636; nc_val[3828] = 0.938675; nc_val[3829] = 0.938714; 
nc_val[3830] = 0.938752; nc_val[3831] = 0.938791; nc_val[3832] = 0.938830; nc_val[3833] = 0.938869; nc_val[3834] = 0.938908; nc_val[3835] = 0.938947; nc_val[3836] = 0.938986; nc_val[3837] = 0.939025; nc_val[3838] = 0.939064; nc_val[3839] = 0.939102; 
nc_val[3840] = 0.939141; nc_val[3841] = 0.939180; nc_val[3842] = 0.939219; nc_val[3843] = 0.939258; nc_val[3844] = 0.939297; nc_val[3845] = 0.939336; nc_val[3846] = 0.939375; nc_val[3847] = 0.939414; nc_val[3848] = 0.939453; nc_val[3849] = 0.939492; 
nc_val[3850] = 0.939531; nc_val[3851] = 0.939570; nc_val[3852] = 0.939609; nc_val[3853] = 0.939648; nc_val[3854] = 0.939687; nc_val[3855] = 0.939726; nc_val[3856] = 0.939765; nc_val[3857] = 0.939804; nc_val[3858] = 0.939843; nc_val[3859] = 0.939882; 
nc_val[3860] = 0.939921; nc_val[3861] = 0.939960; nc_val[3862] = 0.940000; nc_val[3863] = 0.940039; nc_val[3864] = 0.940078; nc_val[3865] = 0.940117; nc_val[3866] = 0.940156; nc_val[3867] = 0.940195; nc_val[3868] = 0.940234; nc_val[3869] = 0.940273; 
nc_val[3870] = 0.940312; nc_val[3871] = 0.940352; nc_val[3872] = 0.940391; nc_val[3873] = 0.940430; nc_val[3874] = 0.940469; nc_val[3875] = 0.940508; nc_val[3876] = 0.940547; nc_val[3877] = 0.940587; nc_val[3878] = 0.940626; nc_val[3879] = 0.940665; 
nc_val[3880] = 0.940704; nc_val[3881] = 0.940744; nc_val[3882] = 0.940783; nc_val[3883] = 0.940822; nc_val[3884] = 0.940861; nc_val[3885] = 0.940900; nc_val[3886] = 0.940940; nc_val[3887] = 0.940979; nc_val[3888] = 0.941018; nc_val[3889] = 0.941058; 
nc_val[3890] = 0.941097; nc_val[3891] = 0.941136; nc_val[3892] = 0.941175; nc_val[3893] = 0.941215; nc_val[3894] = 0.941254; nc_val[3895] = 0.941293; nc_val[3896] = 0.941333; nc_val[3897] = 0.941372; nc_val[3898] = 0.941411; nc_val[3899] = 0.941451; 
nc_val[3900] = 0.941490; nc_val[3901] = 0.941530; nc_val[3902] = 0.941569; nc_val[3903] = 0.941608; nc_val[3904] = 0.941648; nc_val[3905] = 0.941687; nc_val[3906] = 0.941727; nc_val[3907] = 0.941766; nc_val[3908] = 0.941805; nc_val[3909] = 0.941845; 
nc_val[3910] = 0.941884; nc_val[3911] = 0.941924; nc_val[3912] = 0.941963; nc_val[3913] = 0.942003; nc_val[3914] = 0.942042; nc_val[3915] = 0.942082; nc_val[3916] = 0.942121; nc_val[3917] = 0.942161; nc_val[3918] = 0.942200; nc_val[3919] = 0.942240; 
nc_val[3920] = 0.942279; nc_val[3921] = 0.942319; nc_val[3922] = 0.942358; nc_val[3923] = 0.942398; nc_val[3924] = 0.942437; nc_val[3925] = 0.942477; nc_val[3926] = 0.942516; nc_val[3927] = 0.942556; nc_val[3928] = 0.942595; nc_val[3929] = 0.942635; 
nc_val[3930] = 0.942675; nc_val[3931] = 0.942714; nc_val[3932] = 0.942754; nc_val[3933] = 0.942793; nc_val[3934] = 0.942833; nc_val[3935] = 0.942873; nc_val[3936] = 0.942912; nc_val[3937] = 0.942952; nc_val[3938] = 0.942992; nc_val[3939] = 0.943031; 
nc_val[3940] = 0.943071; nc_val[3941] = 0.943111; nc_val[3942] = 0.943150; nc_val[3943] = 0.943190; nc_val[3944] = 0.943230; nc_val[3945] = 0.943269; nc_val[3946] = 0.943309; nc_val[3947] = 0.943349; nc_val[3948] = 0.943389; nc_val[3949] = 0.943428; 
nc_val[3950] = 0.943468; nc_val[3951] = 0.943508; nc_val[3952] = 0.943548; nc_val[3953] = 0.943587; nc_val[3954] = 0.943627; nc_val[3955] = 0.943667; nc_val[3956] = 0.943707; nc_val[3957] = 0.943747; nc_val[3958] = 0.943786; nc_val[3959] = 0.943826; 
nc_val[3960] = 0.943866; nc_val[3961] = 0.943906; nc_val[3962] = 0.943946; nc_val[3963] = 0.943986; nc_val[3964] = 0.944025; nc_val[3965] = 0.944065; nc_val[3966] = 0.944105; nc_val[3967] = 0.944145; nc_val[3968] = 0.944185; nc_val[3969] = 0.944225; 
nc_val[3970] = 0.944265; nc_val[3971] = 0.944305; nc_val[3972] = 0.944345; nc_val[3973] = 0.944385; nc_val[3974] = 0.944425; nc_val[3975] = 0.944464; nc_val[3976] = 0.944504; nc_val[3977] = 0.944544; nc_val[3978] = 0.944584; nc_val[3979] = 0.944624; 
nc_val[3980] = 0.944664; nc_val[3981] = 0.944704; nc_val[3982] = 0.944744; nc_val[3983] = 0.944784; nc_val[3984] = 0.944824; nc_val[3985] = 0.944864; nc_val[3986] = 0.944904; nc_val[3987] = 0.944945; nc_val[3988] = 0.944985; nc_val[3989] = 0.945025; 
nc_val[3990] = 0.945065; nc_val[3991] = 0.945105; nc_val[3992] = 0.945145; nc_val[3993] = 0.945185; nc_val[3994] = 0.945225; nc_val[3995] = 0.945265; nc_val[3996] = 0.945305; nc_val[3997] = 0.945345; nc_val[3998] = 0.945386; nc_val[3999] = 0.945426; 
nc_val[4000] = 0.945466; nc_val[4001] = 0.945506; nc_val[4002] = 0.945546; nc_val[4003] = 0.945586; nc_val[4004] = 0.945627; nc_val[4005] = 0.945667; nc_val[4006] = 0.945707; nc_val[4007] = 0.945747; nc_val[4008] = 0.945787; nc_val[4009] = 0.945828; 
nc_val[4010] = 0.945868; nc_val[4011] = 0.945908; nc_val[4012] = 0.945948; nc_val[4013] = 0.945989; nc_val[4014] = 0.946029; nc_val[4015] = 0.946069; nc_val[4016] = 0.946109; nc_val[4017] = 0.946150; nc_val[4018] = 0.946190; nc_val[4019] = 0.946230; 
nc_val[4020] = 0.946271; nc_val[4021] = 0.946311; nc_val[4022] = 0.946351; nc_val[4023] = 0.946392; nc_val[4024] = 0.946432; nc_val[4025] = 0.946472; nc_val[4026] = 0.946513; nc_val[4027] = 0.946553; nc_val[4028] = 0.946594; nc_val[4029] = 0.946634; 
nc_val[4030] = 0.946674; nc_val[4031] = 0.946715; nc_val[4032] = 0.946755; nc_val[4033] = 0.946796; nc_val[4034] = 0.946836; nc_val[4035] = 0.946876; nc_val[4036] = 0.946917; nc_val[4037] = 0.946957; nc_val[4038] = 0.946998; nc_val[4039] = 0.947038; 
nc_val[4040] = 0.947079; nc_val[4041] = 0.947119; nc_val[4042] = 0.947160; nc_val[4043] = 0.947200; nc_val[4044] = 0.947241; nc_val[4045] = 0.947281; nc_val[4046] = 0.947322; nc_val[4047] = 0.947363; nc_val[4048] = 0.947403; nc_val[4049] = 0.947444; 
nc_val[4050] = 0.947484; nc_val[4051] = 0.947525; nc_val[4052] = 0.947565; nc_val[4053] = 0.947606; nc_val[4054] = 0.947647; nc_val[4055] = 0.947687; nc_val[4056] = 0.947728; nc_val[4057] = 0.947768; nc_val[4058] = 0.947809; nc_val[4059] = 0.947850; 
nc_val[4060] = 0.947890; nc_val[4061] = 0.947931; nc_val[4062] = 0.947972; nc_val[4063] = 0.948013; nc_val[4064] = 0.948053; nc_val[4065] = 0.948094; nc_val[4066] = 0.948135; nc_val[4067] = 0.948175; nc_val[4068] = 0.948216; nc_val[4069] = 0.948257; 
nc_val[4070] = 0.948298; nc_val[4071] = 0.948338; nc_val[4072] = 0.948379; nc_val[4073] = 0.948420; nc_val[4074] = 0.948461; nc_val[4075] = 0.948501; nc_val[4076] = 0.948542; nc_val[4077] = 0.948583; nc_val[4078] = 0.948624; nc_val[4079] = 0.948665; 
nc_val[4080] = 0.948706; nc_val[4081] = 0.948746; nc_val[4082] = 0.948787; nc_val[4083] = 0.948828; nc_val[4084] = 0.948869; nc_val[4085] = 0.948910; nc_val[4086] = 0.948951; nc_val[4087] = 0.948992; nc_val[4088] = 0.949033; nc_val[4089] = 0.949074; 
nc_val[4090] = 0.949114; nc_val[4091] = 0.949155; nc_val[4092] = 0.949196; nc_val[4093] = 0.949237; nc_val[4094] = 0.949278; nc_val[4095] = 0.949319; nc_val[4096] = 0.949360; nc_val[4097] = 0.949401; nc_val[4098] = 0.949442; nc_val[4099] = 0.949483; 
nc_val[4100] = 0.949524; nc_val[4101] = 0.949565; nc_val[4102] = 0.949606; nc_val[4103] = 0.949647; nc_val[4104] = 0.949688; nc_val[4105] = 0.949730; nc_val[4106] = 0.949771; nc_val[4107] = 0.949812; nc_val[4108] = 0.949853; nc_val[4109] = 0.949894; 
nc_val[4110] = 0.949935; nc_val[4111] = 0.949976; nc_val[4112] = 0.950017; nc_val[4113] = 0.950058; nc_val[4114] = 0.950100; nc_val[4115] = 0.950141; nc_val[4116] = 0.950182; nc_val[4117] = 0.950223; nc_val[4118] = 0.950264; nc_val[4119] = 0.950305; 
nc_val[4120] = 0.950347; nc_val[4121] = 0.950388; nc_val[4122] = 0.950429; nc_val[4123] = 0.950470; nc_val[4124] = 0.950512; nc_val[4125] = 0.950553; nc_val[4126] = 0.950594; nc_val[4127] = 0.950635; nc_val[4128] = 0.950677; nc_val[4129] = 0.950718; 
nc_val[4130] = 0.950759; nc_val[4131] = 0.950801; nc_val[4132] = 0.950842; nc_val[4133] = 0.950883; nc_val[4134] = 0.950925; nc_val[4135] = 0.950966; nc_val[4136] = 0.951007; nc_val[4137] = 0.951049; nc_val[4138] = 0.951090; nc_val[4139] = 0.951131; 
nc_val[4140] = 0.951173; nc_val[4141] = 0.951214; nc_val[4142] = 0.951256; nc_val[4143] = 0.951297; nc_val[4144] = 0.951338; nc_val[4145] = 0.951380; nc_val[4146] = 0.951421; nc_val[4147] = 0.951463; nc_val[4148] = 0.951504; nc_val[4149] = 0.951546; 
nc_val[4150] = 0.951587; nc_val[4151] = 0.951629; nc_val[4152] = 0.951670; nc_val[4153] = 0.951712; nc_val[4154] = 0.951753; nc_val[4155] = 0.951795; nc_val[4156] = 0.951836; nc_val[4157] = 0.951878; nc_val[4158] = 0.951920; nc_val[4159] = 0.951961; 
nc_val[4160] = 0.952003; nc_val[4161] = 0.952044; nc_val[4162] = 0.952086; nc_val[4163] = 0.952128; nc_val[4164] = 0.952169; nc_val[4165] = 0.952211; nc_val[4166] = 0.952252; nc_val[4167] = 0.952294; nc_val[4168] = 0.952336; nc_val[4169] = 0.952377; 
nc_val[4170] = 0.952419; nc_val[4171] = 0.952461; nc_val[4172] = 0.952503; nc_val[4173] = 0.952544; nc_val[4174] = 0.952586; nc_val[4175] = 0.952628; nc_val[4176] = 0.952670; nc_val[4177] = 0.952711; nc_val[4178] = 0.952753; nc_val[4179] = 0.952795; 
nc_val[4180] = 0.952837; nc_val[4181] = 0.952878; nc_val[4182] = 0.952920; nc_val[4183] = 0.952962; nc_val[4184] = 0.953004; nc_val[4185] = 0.953046; nc_val[4186] = 0.953088; nc_val[4187] = 0.953129; nc_val[4188] = 0.953171; nc_val[4189] = 0.953213; 
nc_val[4190] = 0.953255; nc_val[4191] = 0.953297; nc_val[4192] = 0.953339; nc_val[4193] = 0.953381; nc_val[4194] = 0.953423; nc_val[4195] = 0.953465; nc_val[4196] = 0.953507; nc_val[4197] = 0.953549; nc_val[4198] = 0.953590; nc_val[4199] = 0.953632; 
nc_val[4200] = 0.953674; nc_val[4201] = 0.953716; nc_val[4202] = 0.953758; nc_val[4203] = 0.953800; nc_val[4204] = 0.953843; nc_val[4205] = 0.953885; nc_val[4206] = 0.953927; nc_val[4207] = 0.953969; nc_val[4208] = 0.954011; nc_val[4209] = 0.954053; 
nc_val[4210] = 0.954095; nc_val[4211] = 0.954137; nc_val[4212] = 0.954179; nc_val[4213] = 0.954221; nc_val[4214] = 0.954263; nc_val[4215] = 0.954306; nc_val[4216] = 0.954348; nc_val[4217] = 0.954390; nc_val[4218] = 0.954432; nc_val[4219] = 0.954474; 
nc_val[4220] = 0.954516; nc_val[4221] = 0.954559; nc_val[4222] = 0.954601; nc_val[4223] = 0.954643; nc_val[4224] = 0.954685; nc_val[4225] = 0.954728; nc_val[4226] = 0.954770; nc_val[4227] = 0.954812; nc_val[4228] = 0.954854; nc_val[4229] = 0.954897; 
nc_val[4230] = 0.954939; nc_val[4231] = 0.954981; nc_val[4232] = 0.955024; nc_val[4233] = 0.955066; nc_val[4234] = 0.955108; nc_val[4235] = 0.955151; nc_val[4236] = 0.955193; nc_val[4237] = 0.955235; nc_val[4238] = 0.955278; nc_val[4239] = 0.955320; 
nc_val[4240] = 0.955363; nc_val[4241] = 0.955405; nc_val[4242] = 0.955447; nc_val[4243] = 0.955490; nc_val[4244] = 0.955532; nc_val[4245] = 0.955575; nc_val[4246] = 0.955617; nc_val[4247] = 0.955660; nc_val[4248] = 0.955702; nc_val[4249] = 0.955745; 
nc_val[4250] = 0.955787; nc_val[4251] = 0.955830; nc_val[4252] = 0.955872; nc_val[4253] = 0.955915; nc_val[4254] = 0.955957; nc_val[4255] = 0.956000; nc_val[4256] = 0.956043; nc_val[4257] = 0.956085; nc_val[4258] = 0.956128; nc_val[4259] = 0.956170; 
nc_val[4260] = 0.956213; nc_val[4261] = 0.956256; nc_val[4262] = 0.956298; nc_val[4263] = 0.956341; nc_val[4264] = 0.956384; nc_val[4265] = 0.956426; nc_val[4266] = 0.956469; nc_val[4267] = 0.956512; nc_val[4268] = 0.956554; nc_val[4269] = 0.956597; 
nc_val[4270] = 0.956640; nc_val[4271] = 0.956683; nc_val[4272] = 0.956725; nc_val[4273] = 0.956768; nc_val[4274] = 0.956811; nc_val[4275] = 0.956854; nc_val[4276] = 0.956896; nc_val[4277] = 0.956939; nc_val[4278] = 0.956982; nc_val[4279] = 0.957025; 
nc_val[4280] = 0.957068; nc_val[4281] = 0.957111; nc_val[4282] = 0.957154; nc_val[4283] = 0.957196; nc_val[4284] = 0.957239; nc_val[4285] = 0.957282; nc_val[4286] = 0.957325; nc_val[4287] = 0.957368; nc_val[4288] = 0.957411; nc_val[4289] = 0.957454; 
nc_val[4290] = 0.957497; nc_val[4291] = 0.957540; nc_val[4292] = 0.957583; nc_val[4293] = 0.957626; nc_val[4294] = 0.957669; nc_val[4295] = 0.957712; nc_val[4296] = 0.957755; nc_val[4297] = 0.957798; nc_val[4298] = 0.957841; nc_val[4299] = 0.957884; 
nc_val[4300] = 0.957927; nc_val[4301] = 0.957970; nc_val[4302] = 0.958013; nc_val[4303] = 0.958056; nc_val[4304] = 0.958100; nc_val[4305] = 0.958143; nc_val[4306] = 0.958186; nc_val[4307] = 0.958229; nc_val[4308] = 0.958272; nc_val[4309] = 0.958315; 
nc_val[4310] = 0.958359; nc_val[4311] = 0.958402; nc_val[4312] = 0.958445; nc_val[4313] = 0.958488; nc_val[4314] = 0.958531; nc_val[4315] = 0.958575; nc_val[4316] = 0.958618; nc_val[4317] = 0.958661; nc_val[4318] = 0.958705; nc_val[4319] = 0.958748; 
nc_val[4320] = 0.958791; nc_val[4321] = 0.958834; nc_val[4322] = 0.958878; nc_val[4323] = 0.958921; nc_val[4324] = 0.958965; nc_val[4325] = 0.959008; nc_val[4326] = 0.959051; nc_val[4327] = 0.959095; nc_val[4328] = 0.959138; nc_val[4329] = 0.959182; 
nc_val[4330] = 0.959225; nc_val[4331] = 0.959268; nc_val[4332] = 0.959312; nc_val[4333] = 0.959355; nc_val[4334] = 0.959399; nc_val[4335] = 0.959442; nc_val[4336] = 0.959486; nc_val[4337] = 0.959529; nc_val[4338] = 0.959573; nc_val[4339] = 0.959616; 
nc_val[4340] = 0.959660; nc_val[4341] = 0.959704; nc_val[4342] = 0.959747; nc_val[4343] = 0.959791; nc_val[4344] = 0.959834; nc_val[4345] = 0.959878; nc_val[4346] = 0.959922; nc_val[4347] = 0.959965; nc_val[4348] = 0.960009; nc_val[4349] = 0.960052; 
nc_val[4350] = 0.960096; nc_val[4351] = 0.960140; nc_val[4352] = 0.960184; nc_val[4353] = 0.960227; nc_val[4354] = 0.960271; nc_val[4355] = 0.960315; nc_val[4356] = 0.960358; nc_val[4357] = 0.960402; nc_val[4358] = 0.960446; nc_val[4359] = 0.960490; 
nc_val[4360] = 0.960534; nc_val[4361] = 0.960577; nc_val[4362] = 0.960621; nc_val[4363] = 0.960665; nc_val[4364] = 0.960709; nc_val[4365] = 0.960753; nc_val[4366] = 0.960797; nc_val[4367] = 0.960841; nc_val[4368] = 0.960884; nc_val[4369] = 0.960928; 
nc_val[4370] = 0.960972; nc_val[4371] = 0.961016; nc_val[4372] = 0.961060; nc_val[4373] = 0.961104; nc_val[4374] = 0.961148; nc_val[4375] = 0.961192; nc_val[4376] = 0.961236; nc_val[4377] = 0.961280; nc_val[4378] = 0.961324; nc_val[4379] = 0.961368; 
nc_val[4380] = 0.961412; nc_val[4381] = 0.961456; nc_val[4382] = 0.961500; nc_val[4383] = 0.961545; nc_val[4384] = 0.961589; nc_val[4385] = 0.961633; nc_val[4386] = 0.961677; nc_val[4387] = 0.961721; nc_val[4388] = 0.961765; nc_val[4389] = 0.961809; 
nc_val[4390] = 0.961854; nc_val[4391] = 0.961898; nc_val[4392] = 0.961942; nc_val[4393] = 0.961986; nc_val[4394] = 0.962030; nc_val[4395] = 0.962075; nc_val[4396] = 0.962119; nc_val[4397] = 0.962163; nc_val[4398] = 0.962208; nc_val[4399] = 0.962252; 
nc_val[4400] = 0.962296; nc_val[4401] = 0.962341; nc_val[4402] = 0.962385; nc_val[4403] = 0.962429; nc_val[4404] = 0.962474; nc_val[4405] = 0.962518; nc_val[4406] = 0.962562; nc_val[4407] = 0.962607; nc_val[4408] = 0.962651; nc_val[4409] = 0.962696; 
nc_val[4410] = 0.962740; nc_val[4411] = 0.962785; nc_val[4412] = 0.962829; nc_val[4413] = 0.962874; nc_val[4414] = 0.962918; nc_val[4415] = 0.962963; nc_val[4416] = 0.963007; nc_val[4417] = 0.963052; nc_val[4418] = 0.963096; nc_val[4419] = 0.963141; 
nc_val[4420] = 0.963185; nc_val[4421] = 0.963230; nc_val[4422] = 0.963275; nc_val[4423] = 0.963319; nc_val[4424] = 0.963364; nc_val[4425] = 0.963409; nc_val[4426] = 0.963453; nc_val[4427] = 0.963498; nc_val[4428] = 0.963543; nc_val[4429] = 0.963587; 
nc_val[4430] = 0.963632; nc_val[4431] = 0.963677; nc_val[4432] = 0.963722; nc_val[4433] = 0.963766; nc_val[4434] = 0.963811; nc_val[4435] = 0.963856; nc_val[4436] = 0.963901; nc_val[4437] = 0.963946; nc_val[4438] = 0.963990; nc_val[4439] = 0.964035; 
nc_val[4440] = 0.964080; nc_val[4441] = 0.964125; nc_val[4442] = 0.964170; nc_val[4443] = 0.964215; nc_val[4444] = 0.964260; nc_val[4445] = 0.964305; nc_val[4446] = 0.964350; nc_val[4447] = 0.964395; nc_val[4448] = 0.964440; nc_val[4449] = 0.964485; 
nc_val[4450] = 0.964530; nc_val[4451] = 0.964575; nc_val[4452] = 0.964620; nc_val[4453] = 0.964665; nc_val[4454] = 0.964710; nc_val[4455] = 0.964755; nc_val[4456] = 0.964800; nc_val[4457] = 0.964845; nc_val[4458] = 0.964890; nc_val[4459] = 0.964935; 
nc_val[4460] = 0.964981; nc_val[4461] = 0.965026; nc_val[4462] = 0.965071; nc_val[4463] = 0.965116; nc_val[4464] = 0.965161; nc_val[4465] = 0.965207; nc_val[4466] = 0.965252; nc_val[4467] = 0.965297; nc_val[4468] = 0.965342; nc_val[4469] = 0.965388; 
nc_val[4470] = 0.965433; nc_val[4471] = 0.965478; nc_val[4472] = 0.965524; nc_val[4473] = 0.965569; nc_val[4474] = 0.965614; nc_val[4475] = 0.965660; nc_val[4476] = 0.965705; nc_val[4477] = 0.965751; nc_val[4478] = 0.965796; nc_val[4479] = 0.965841; 
nc_val[4480] = 0.965887; nc_val[4481] = 0.965932; nc_val[4482] = 0.965978; nc_val[4483] = 0.966023; nc_val[4484] = 0.966069; nc_val[4485] = 0.966114; nc_val[4486] = 0.966160; nc_val[4487] = 0.966205; nc_val[4488] = 0.966251; nc_val[4489] = 0.966297; 
nc_val[4490] = 0.966342; nc_val[4491] = 0.966388; nc_val[4492] = 0.966433; nc_val[4493] = 0.966479; nc_val[4494] = 0.966525; nc_val[4495] = 0.966571; nc_val[4496] = 0.966616; nc_val[4497] = 0.966662; nc_val[4498] = 0.966708; nc_val[4499] = 0.966753; 
nc_val[4500] = 0.966799; nc_val[4501] = 0.966845; nc_val[4502] = 0.966891; nc_val[4503] = 0.966937; nc_val[4504] = 0.966982; nc_val[4505] = 0.967028; nc_val[4506] = 0.967074; nc_val[4507] = 0.967120; nc_val[4508] = 0.967166; nc_val[4509] = 0.967212; 
nc_val[4510] = 0.967258; nc_val[4511] = 0.967304; nc_val[4512] = 0.967350; nc_val[4513] = 0.967396; nc_val[4514] = 0.967442; nc_val[4515] = 0.967488; nc_val[4516] = 0.967534; nc_val[4517] = 0.967580; nc_val[4518] = 0.967626; nc_val[4519] = 0.967672; 
nc_val[4520] = 0.967718; nc_val[4521] = 0.967764; nc_val[4522] = 0.967810; nc_val[4523] = 0.967856; nc_val[4524] = 0.967902; nc_val[4525] = 0.967948; nc_val[4526] = 0.967995; nc_val[4527] = 0.968041; nc_val[4528] = 0.968087; nc_val[4529] = 0.968133; 
nc_val[4530] = 0.968180; nc_val[4531] = 0.968226; nc_val[4532] = 0.968272; nc_val[4533] = 0.968318; nc_val[4534] = 0.968365; nc_val[4535] = 0.968411; nc_val[4536] = 0.968457; nc_val[4537] = 0.968504; nc_val[4538] = 0.968550; nc_val[4539] = 0.968597; 
nc_val[4540] = 0.968643; nc_val[4541] = 0.968689; nc_val[4542] = 0.968736; nc_val[4543] = 0.968782; nc_val[4544] = 0.968829; nc_val[4545] = 0.968875; nc_val[4546] = 0.968922; nc_val[4547] = 0.968968; nc_val[4548] = 0.969015; nc_val[4549] = 0.969061; 
nc_val[4550] = 0.969108; nc_val[4551] = 0.969155; nc_val[4552] = 0.969201; nc_val[4553] = 0.969248; nc_val[4554] = 0.969295; nc_val[4555] = 0.969341; nc_val[4556] = 0.969388; nc_val[4557] = 0.969435; nc_val[4558] = 0.969481; nc_val[4559] = 0.969528; 
nc_val[4560] = 0.969575; nc_val[4561] = 0.969622; nc_val[4562] = 0.969668; nc_val[4563] = 0.969715; nc_val[4564] = 0.969762; nc_val[4565] = 0.969809; nc_val[4566] = 0.969856; nc_val[4567] = 0.969903; nc_val[4568] = 0.969950; nc_val[4569] = 0.969996; 
nc_val[4570] = 0.970043; nc_val[4571] = 0.970090; nc_val[4572] = 0.970137; nc_val[4573] = 0.970184; nc_val[4574] = 0.970231; nc_val[4575] = 0.970278; nc_val[4576] = 0.970325; nc_val[4577] = 0.970372; nc_val[4578] = 0.970419; nc_val[4579] = 0.970467; 
nc_val[4580] = 0.970514; nc_val[4581] = 0.970561; nc_val[4582] = 0.970608; nc_val[4583] = 0.970655; nc_val[4584] = 0.970702; nc_val[4585] = 0.970750; nc_val[4586] = 0.970797; nc_val[4587] = 0.970844; nc_val[4588] = 0.970891; nc_val[4589] = 0.970939; 
nc_val[4590] = 0.970986; nc_val[4591] = 0.971033; nc_val[4592] = 0.971081; nc_val[4593] = 0.971128; nc_val[4594] = 0.971175; nc_val[4595] = 0.971223; nc_val[4596] = 0.971270; nc_val[4597] = 0.971317; nc_val[4598] = 0.971365; nc_val[4599] = 0.971412; 
nc_val[4600] = 0.971460; nc_val[4601] = 0.971507; nc_val[4602] = 0.971555; nc_val[4603] = 0.971602; nc_val[4604] = 0.971650; nc_val[4605] = 0.971698; nc_val[4606] = 0.971745; nc_val[4607] = 0.971793; nc_val[4608] = 0.971840; nc_val[4609] = 0.971888; 
nc_val[4610] = 0.971936; nc_val[4611] = 0.971984; nc_val[4612] = 0.972031; nc_val[4613] = 0.972079; nc_val[4614] = 0.972127; nc_val[4615] = 0.972174; nc_val[4616] = 0.972222; nc_val[4617] = 0.972270; nc_val[4618] = 0.972318; nc_val[4619] = 0.972366; 
nc_val[4620] = 0.972414; nc_val[4621] = 0.972462; nc_val[4622] = 0.972509; nc_val[4623] = 0.972557; nc_val[4624] = 0.972605; nc_val[4625] = 0.972653; nc_val[4626] = 0.972701; nc_val[4627] = 0.972749; nc_val[4628] = 0.972797; nc_val[4629] = 0.972845; 
nc_val[4630] = 0.972894; nc_val[4631] = 0.972942; nc_val[4632] = 0.972990; nc_val[4633] = 0.973038; nc_val[4634] = 0.973086; nc_val[4635] = 0.973134; nc_val[4636] = 0.973182; nc_val[4637] = 0.973231; nc_val[4638] = 0.973279; nc_val[4639] = 0.973327; 
nc_val[4640] = 0.973375; nc_val[4641] = 0.973424; nc_val[4642] = 0.973472; nc_val[4643] = 0.973520; nc_val[4644] = 0.973569; nc_val[4645] = 0.973617; nc_val[4646] = 0.973665; nc_val[4647] = 0.973714; nc_val[4648] = 0.973762; nc_val[4649] = 0.973811; 
nc_val[4650] = 0.973859; nc_val[4651] = 0.973908; nc_val[4652] = 0.973956; nc_val[4653] = 0.974005; nc_val[4654] = 0.974053; nc_val[4655] = 0.974102; nc_val[4656] = 0.974151; nc_val[4657] = 0.974199; nc_val[4658] = 0.974248; nc_val[4659] = 0.974297; 
nc_val[4660] = 0.974345; nc_val[4661] = 0.974394; nc_val[4662] = 0.974443; nc_val[4663] = 0.974492; nc_val[4664] = 0.974540; nc_val[4665] = 0.974589; nc_val[4666] = 0.974638; nc_val[4667] = 0.974687; nc_val[4668] = 0.974736; nc_val[4669] = 0.974785; 
nc_val[4670] = 0.974834; nc_val[4671] = 0.974883; nc_val[4672] = 0.974932; nc_val[4673] = 0.974980; nc_val[4674] = 0.975030; nc_val[4675] = 0.975079; nc_val[4676] = 0.975128; nc_val[4677] = 0.975177; nc_val[4678] = 0.975226; nc_val[4679] = 0.975275; 
nc_val[4680] = 0.975324; nc_val[4681] = 0.975373; nc_val[4682] = 0.975422; nc_val[4683] = 0.975472; nc_val[4684] = 0.975521; nc_val[4685] = 0.975570; nc_val[4686] = 0.975619; nc_val[4687] = 0.975669; nc_val[4688] = 0.975718; nc_val[4689] = 0.975767; 
nc_val[4690] = 0.975817; nc_val[4691] = 0.975866; nc_val[4692] = 0.975916; nc_val[4693] = 0.975965; nc_val[4694] = 0.976015; nc_val[4695] = 0.976064; nc_val[4696] = 0.976114; nc_val[4697] = 0.976163; nc_val[4698] = 0.976213; nc_val[4699] = 0.976262; 
nc_val[4700] = 0.976312; nc_val[4701] = 0.976361; nc_val[4702] = 0.976411; nc_val[4703] = 0.976461; nc_val[4704] = 0.976511; nc_val[4705] = 0.976560; nc_val[4706] = 0.976610; nc_val[4707] = 0.976660; nc_val[4708] = 0.976710; nc_val[4709] = 0.976759; 
nc_val[4710] = 0.976809; nc_val[4711] = 0.976859; nc_val[4712] = 0.976909; nc_val[4713] = 0.976959; nc_val[4714] = 0.977009; nc_val[4715] = 0.977059; nc_val[4716] = 0.977109; nc_val[4717] = 0.977159; nc_val[4718] = 0.977209; nc_val[4719] = 0.977259; 
nc_val[4720] = 0.977309; nc_val[4721] = 0.977359; nc_val[4722] = 0.977409; nc_val[4723] = 0.977460; nc_val[4724] = 0.977510; nc_val[4725] = 0.977560; nc_val[4726] = 0.977610; nc_val[4727] = 0.977661; nc_val[4728] = 0.977711; nc_val[4729] = 0.977761; 
nc_val[4730] = 0.977812; nc_val[4731] = 0.977862; nc_val[4732] = 0.977912; nc_val[4733] = 0.977963; nc_val[4734] = 0.978013; nc_val[4735] = 0.978064; nc_val[4736] = 0.978114; nc_val[4737] = 0.978165; nc_val[4738] = 0.978215; nc_val[4739] = 0.978266; 
nc_val[4740] = 0.978317; nc_val[4741] = 0.978367; nc_val[4742] = 0.978418; nc_val[4743] = 0.978469; nc_val[4744] = 0.978519; nc_val[4745] = 0.978570; nc_val[4746] = 0.978621; nc_val[4747] = 0.978672; nc_val[4748] = 0.978723; nc_val[4749] = 0.978773; 
nc_val[4750] = 0.978824; nc_val[4751] = 0.978875; nc_val[4752] = 0.978926; nc_val[4753] = 0.978977; nc_val[4754] = 0.979028; nc_val[4755] = 0.979079; nc_val[4756] = 0.979130; nc_val[4757] = 0.979181; nc_val[4758] = 0.979232; nc_val[4759] = 0.979284; 
nc_val[4760] = 0.979335; nc_val[4761] = 0.979386; nc_val[4762] = 0.979437; nc_val[4763] = 0.979488; nc_val[4764] = 0.979540; nc_val[4765] = 0.979591; nc_val[4766] = 0.979642; nc_val[4767] = 0.979694; nc_val[4768] = 0.979745; nc_val[4769] = 0.979797; 
nc_val[4770] = 0.979848; nc_val[4771] = 0.979900; nc_val[4772] = 0.979951; nc_val[4773] = 0.980003; nc_val[4774] = 0.980054; nc_val[4775] = 0.980106; nc_val[4776] = 0.980157; nc_val[4777] = 0.980209; nc_val[4778] = 0.980261; nc_val[4779] = 0.980313; 
nc_val[4780] = 0.980364; nc_val[4781] = 0.980416; nc_val[4782] = 0.980468; nc_val[4783] = 0.980520; nc_val[4784] = 0.980572; nc_val[4785] = 0.980624; nc_val[4786] = 0.980675; nc_val[4787] = 0.980727; nc_val[4788] = 0.980779; nc_val[4789] = 0.980831; 
nc_val[4790] = 0.980884; nc_val[4791] = 0.980936; nc_val[4792] = 0.980988; nc_val[4793] = 0.981040; nc_val[4794] = 0.981092; nc_val[4795] = 0.981144; nc_val[4796] = 0.981197; nc_val[4797] = 0.981249; nc_val[4798] = 0.981301; nc_val[4799] = 0.981353; 
nc_val[4800] = 0.981406; nc_val[4801] = 0.981458; nc_val[4802] = 0.981511; nc_val[4803] = 0.981563; nc_val[4804] = 0.981616; nc_val[4805] = 0.981668; nc_val[4806] = 0.981721; nc_val[4807] = 0.981773; nc_val[4808] = 0.981826; nc_val[4809] = 0.981879; 
nc_val[4810] = 0.981931; nc_val[4811] = 0.981984; nc_val[4812] = 0.982037; nc_val[4813] = 0.982090; nc_val[4814] = 0.982143; nc_val[4815] = 0.982195; nc_val[4816] = 0.982248; nc_val[4817] = 0.982301; nc_val[4818] = 0.982354; nc_val[4819] = 0.982407; 
nc_val[4820] = 0.982460; nc_val[4821] = 0.982513; nc_val[4822] = 0.982567; nc_val[4823] = 0.982620; nc_val[4824] = 0.982673; nc_val[4825] = 0.982726; nc_val[4826] = 0.982779; nc_val[4827] = 0.982833; nc_val[4828] = 0.982886; nc_val[4829] = 0.982939; 
nc_val[4830] = 0.982993; nc_val[4831] = 0.983046; nc_val[4832] = 0.983100; nc_val[4833] = 0.983153; nc_val[4834] = 0.983207; nc_val[4835] = 0.983260; nc_val[4836] = 0.983314; nc_val[4837] = 0.983367; nc_val[4838] = 0.983421; nc_val[4839] = 0.983475; 
nc_val[4840] = 0.983529; nc_val[4841] = 0.983582; nc_val[4842] = 0.983636; nc_val[4843] = 0.983690; nc_val[4844] = 0.983744; nc_val[4845] = 0.983798; nc_val[4846] = 0.983852; nc_val[4847] = 0.983906; nc_val[4848] = 0.983960; nc_val[4849] = 0.984014; 
nc_val[4850] = 0.984068; nc_val[4851] = 0.984123; nc_val[4852] = 0.984177; nc_val[4853] = 0.984231; nc_val[4854] = 0.984285; nc_val[4855] = 0.984340; nc_val[4856] = 0.984394; nc_val[4857] = 0.984448; nc_val[4858] = 0.984503; nc_val[4859] = 0.984557; 
nc_val[4860] = 0.984612; nc_val[4861] = 0.984667; nc_val[4862] = 0.984721; nc_val[4863] = 0.984776; nc_val[4864] = 0.984831; nc_val[4865] = 0.984885; nc_val[4866] = 0.984940; nc_val[4867] = 0.984995; nc_val[4868] = 0.985050; nc_val[4869] = 0.985105; 
nc_val[4870] = 0.985160; nc_val[4871] = 0.985215; nc_val[4872] = 0.985270; nc_val[4873] = 0.985325; nc_val[4874] = 0.985380; nc_val[4875] = 0.985435; nc_val[4876] = 0.985490; nc_val[4877] = 0.985545; nc_val[4878] = 0.985601; nc_val[4879] = 0.985656; 
nc_val[4880] = 0.985711; nc_val[4881] = 0.985767; nc_val[4882] = 0.985822; nc_val[4883] = 0.985878; nc_val[4884] = 0.985933; nc_val[4885] = 0.985989; nc_val[4886] = 0.986045; nc_val[4887] = 0.986100; nc_val[4888] = 0.986156; nc_val[4889] = 0.986212; 
nc_val[4890] = 0.986268; nc_val[4891] = 0.986324; nc_val[4892] = 0.986380; nc_val[4893] = 0.986436; nc_val[4894] = 0.986492; nc_val[4895] = 0.986548; nc_val[4896] = 0.986604; nc_val[4897] = 0.986660; nc_val[4898] = 0.986716; nc_val[4899] = 0.986772; 
nc_val[4900] = 0.986829; nc_val[4901] = 0.986885; nc_val[4902] = 0.986942; nc_val[4903] = 0.986998; nc_val[4904] = 0.987055; nc_val[4905] = 0.987111; nc_val[4906] = 0.987168; nc_val[4907] = 0.987224; nc_val[4908] = 0.987281; nc_val[4909] = 0.987338; 
nc_val[4910] = 0.987395; nc_val[4911] = 0.987452; nc_val[4912] = 0.987508; nc_val[4913] = 0.987565; nc_val[4914] = 0.987622; nc_val[4915] = 0.987680; nc_val[4916] = 0.987737; nc_val[4917] = 0.987794; nc_val[4918] = 0.987851; nc_val[4919] = 0.987908; 
nc_val[4920] = 0.987966; nc_val[4921] = 0.988023; nc_val[4922] = 0.988081; nc_val[4923] = 0.988138; nc_val[4924] = 0.988196; nc_val[4925] = 0.988253; nc_val[4926] = 0.988311; nc_val[4927] = 0.988369; nc_val[4928] = 0.988426; nc_val[4929] = 0.988484; 
nc_val[4930] = 0.988542; nc_val[4931] = 0.988600; nc_val[4932] = 0.988658; nc_val[4933] = 0.988716; nc_val[4934] = 0.988774; nc_val[4935] = 0.988833; nc_val[4936] = 0.988891; nc_val[4937] = 0.988949; nc_val[4938] = 0.989008; nc_val[4939] = 0.989066; 
nc_val[4940] = 0.989124; nc_val[4941] = 0.989183; nc_val[4942] = 0.989242; nc_val[4943] = 0.989300; nc_val[4944] = 0.989359; nc_val[4945] = 0.989418; nc_val[4946] = 0.989477; nc_val[4947] = 0.989536; nc_val[4948] = 0.989595; nc_val[4949] = 0.989654; 
nc_val[4950] = 0.989713; nc_val[4951] = 0.989772; nc_val[4952] = 0.989831; nc_val[4953] = 0.989891; nc_val[4954] = 0.989950; nc_val[4955] = 0.990010; nc_val[4956] = 0.990069; nc_val[4957] = 0.990129; nc_val[4958] = 0.990188; nc_val[4959] = 0.990248; 
nc_val[4960] = 0.990308; nc_val[4961] = 0.990368; nc_val[4962] = 0.990428; nc_val[4963] = 0.990488; nc_val[4964] = 0.990548; nc_val[4965] = 0.990608; nc_val[4966] = 0.990668; nc_val[4967] = 0.990729; nc_val[4968] = 0.990789; nc_val[4969] = 0.990849; 
nc_val[4970] = 0.990910; nc_val[4971] = 0.990971; nc_val[4972] = 0.991031; nc_val[4973] = 0.991092; nc_val[4974] = 0.991153; nc_val[4975] = 0.991214; nc_val[4976] = 0.991275; nc_val[4977] = 0.991336; nc_val[4978] = 0.991397; nc_val[4979] = 0.991458; 
nc_val[4980] = 0.991520; nc_val[4981] = 0.991581; nc_val[4982] = 0.991642; nc_val[4983] = 0.991704; nc_val[4984] = 0.991766; nc_val[4985] = 0.991827; nc_val[4986] = 0.991889; nc_val[4987] = 0.991951; nc_val[4988] = 0.992013; nc_val[4989] = 0.992075; 
nc_val[4990] = 0.992137; nc_val[4991] = 0.992200; nc_val[4992] = 0.992262; nc_val[4993] = 0.992325; nc_val[4994] = 0.992387; nc_val[4995] = 0.992450; nc_val[4996] = 0.992512; nc_val[4997] = 0.992575; nc_val[4998] = 0.992638; nc_val[4999] = 0.992701; 
nc_val[5000] = 0.992764; nc_val[5001] = 0.992828; nc_val[5002] = 0.992891; nc_val[5003] = 0.992954; nc_val[5004] = 0.993018; nc_val[5005] = 0.993082; nc_val[5006] = 0.993145; nc_val[5007] = 0.993209; nc_val[5008] = 0.993273; nc_val[5009] = 0.993337; 
nc_val[5010] = 0.993401; nc_val[5011] = 0.993466; nc_val[5012] = 0.993530; nc_val[5013] = 0.993595; nc_val[5014] = 0.993659; nc_val[5015] = 0.993724; nc_val[5016] = 0.993789; nc_val[5017] = 0.993854; nc_val[5018] = 0.993919; nc_val[5019] = 0.993984; 
nc_val[5020] = 0.994049; nc_val[5021] = 0.994115; nc_val[5022] = 0.994180; nc_val[5023] = 0.994246; nc_val[5024] = 0.994312; nc_val[5025] = 0.994378; nc_val[5026] = 0.994444; nc_val[5027] = 0.994510; nc_val[5028] = 0.994577; nc_val[5029] = 0.994643; 
nc_val[5030] = 0.994710; nc_val[5031] = 0.994777; nc_val[5032] = 0.994844; nc_val[5033] = 0.994911; nc_val[5034] = 0.994978; nc_val[5035] = 0.995045; nc_val[5036] = 0.995113; nc_val[5037] = 0.995181; nc_val[5038] = 0.995249; nc_val[5039] = 0.995317; 
nc_val[5040] = 0.995385; nc_val[5041] = 0.995453; nc_val[5042] = 0.995522; nc_val[5043] = 0.995590; nc_val[5044] = 0.995659; nc_val[5045] = 0.995728; nc_val[5046] = 0.995798; nc_val[5047] = 0.995867; nc_val[5048] = 0.995937; nc_val[5049] = 0.996007; 
nc_val[5050] = 0.996077; nc_val[5051] = 0.996147; nc_val[5052] = 0.996217; nc_val[5053] = 0.996288; nc_val[5054] = 0.996359; nc_val[5055] = 0.996430; nc_val[5056] = 0.996501; nc_val[5057] = 0.996573; nc_val[5058] = 0.996644; nc_val[5059] = 0.996716; 
nc_val[5060] = 0.996789; nc_val[5061] = 0.996861; nc_val[5062] = 0.996934; nc_val[5063] = 0.997007; nc_val[5064] = 0.997080; nc_val[5065] = 0.997154; nc_val[5066] = 0.997228; nc_val[5067] = 0.997302; nc_val[5068] = 0.997377; nc_val[5069] = 0.997451; 
nc_val[5070] = 0.997527; nc_val[5071] = 0.997602; nc_val[5072] = 0.997678; nc_val[5073] = 0.997754; nc_val[5074] = 0.997831; nc_val[5075] = 0.997908; nc_val[5076] = 0.997985; nc_val[5077] = 0.998063; nc_val[5078] = 0.998141; nc_val[5079] = 0.998220; 
nc_val[5080] = 0.998299; nc_val[5081] = 0.998379; nc_val[5082] = 0.998460; nc_val[5083] = 0.998540; nc_val[5084] = 0.998622; nc_val[5085] = 0.998704; nc_val[5086] = 0.998787; nc_val[5087] = 0.998871; nc_val[5088] = 0.998955; nc_val[5089] = 0.999041; 
nc_val[5090] = 0.999127; nc_val[5091] = 0.999215; nc_val[5092] = 0.999304; nc_val[5093] = 0.999394; nc_val[5094] = 0.999486; nc_val[5095] = 0.999580; nc_val[5096] = 0.999676; nc_val[5097] = 0.999776; nc_val[5098] = 0.999881; nc_val[5099] = 1.000000; 

bs_val[0] = 1.000000; bs_val[1] = 1.000021; bs_val[2] = 1.000083; bs_val[3] = 1.000186; bs_val[4] = 1.000331; bs_val[5] = 1.000517; bs_val[6] = 1.000744; bs_val[7] = 1.001013; bs_val[8] = 1.001323; bs_val[9] = 1.001674; 
bs_val[10] = 1.002067; bs_val[11] = 1.002502; bs_val[12] = 1.002977; bs_val[13] = 1.003495; bs_val[14] = 1.004054; bs_val[15] = 1.004654; bs_val[16] = 1.005296; bs_val[17] = 1.005980; bs_val[18] = 1.006705; bs_val[19] = 1.007473; 
bs_val[20] = 1.008282; bs_val[21] = 1.009133; bs_val[22] = 1.010025; bs_val[23] = 1.010960; bs_val[24] = 1.011937; bs_val[25] = 1.012955; bs_val[26] = 1.014016; bs_val[27] = 1.015120; bs_val[28] = 1.016265; bs_val[29] = 1.017453; 
bs_val[30] = 1.018683; bs_val[31] = 1.019956; bs_val[32] = 1.021271; bs_val[33] = 1.022630; bs_val[34] = 1.024030; bs_val[35] = 1.025474; bs_val[36] = 1.026961; bs_val[37] = 1.028491; bs_val[38] = 1.030064; bs_val[39] = 1.031681; 
bs_val[40] = 1.033341; bs_val[41] = 1.035044; bs_val[42] = 1.036791; bs_val[43] = 1.038582; bs_val[44] = 1.040417; bs_val[45] = 1.042296; bs_val[46] = 1.044219; bs_val[47] = 1.046187; bs_val[48] = 1.048199; bs_val[49] = 1.050256; 
bs_val[50] = 1.052357; bs_val[51] = 1.054504; bs_val[52] = 1.056696; bs_val[53] = 1.058933; bs_val[54] = 1.061216; bs_val[55] = 1.063544; bs_val[56] = 1.065919; bs_val[57] = 1.068339; bs_val[58] = 1.070806; bs_val[59] = 1.073320; 
bs_val[60] = 1.075880; bs_val[61] = 1.078488; bs_val[62] = 1.081142; bs_val[63] = 1.083844; bs_val[64] = 1.086594; bs_val[65] = 1.089392; bs_val[66] = 1.092239; bs_val[67] = 1.095134; bs_val[68] = 1.098077; bs_val[69] = 1.101070; 
bs_val[70] = 1.104113; bs_val[71] = 1.107206; bs_val[72] = 1.110348; bs_val[73] = 1.113542; bs_val[74] = 1.116786; bs_val[75] = 1.120082; bs_val[76] = 1.123429; bs_val[77] = 1.126829; bs_val[78] = 1.130281; bs_val[79] = 1.133786; 
bs_val[80] = 1.137345; bs_val[81] = 1.140958; bs_val[82] = 1.144625; bs_val[83] = 1.148348; bs_val[84] = 1.152126; bs_val[85] = 1.155961; bs_val[86] = 1.159853; bs_val[87] = 1.163802; bs_val[88] = 1.167810; bs_val[89] = 1.171876; 
bs_val[90] = 1.176003; bs_val[91] = 1.180190; bs_val[92] = 1.184439; bs_val[93] = 1.188751; bs_val[94] = 1.193126; bs_val[95] = 1.197567; bs_val[96] = 1.202073; bs_val[97] = 1.206646; bs_val[98] = 1.211288; bs_val[99] = 1.216001; 
bs_val[100] = 1.216053; bs_val[101] = 1.216064; bs_val[102] = 1.216074; bs_val[103] = 1.216084; bs_val[104] = 1.216095; bs_val[105] = 1.216105; bs_val[106] = 1.216116; bs_val[107] = 1.216126; bs_val[108] = 1.216137; bs_val[109] = 1.216147; 
bs_val[110] = 1.216158; bs_val[111] = 1.216168; bs_val[112] = 1.216178; bs_val[113] = 1.216189; bs_val[114] = 1.216199; bs_val[115] = 1.216210; bs_val[116] = 1.216220; bs_val[117] = 1.216231; bs_val[118] = 1.216241; bs_val[119] = 1.216252; 
bs_val[120] = 1.216262; bs_val[121] = 1.216272; bs_val[122] = 1.216283; bs_val[123] = 1.216293; bs_val[124] = 1.216304; bs_val[125] = 1.216314; bs_val[126] = 1.216325; bs_val[127] = 1.216335; bs_val[128] = 1.216346; bs_val[129] = 1.216356; 
bs_val[130] = 1.216366; bs_val[131] = 1.216377; bs_val[132] = 1.216387; bs_val[133] = 1.216398; bs_val[134] = 1.216408; bs_val[135] = 1.216419; bs_val[136] = 1.216429; bs_val[137] = 1.216440; bs_val[138] = 1.216450; bs_val[139] = 1.216461; 
bs_val[140] = 1.216471; bs_val[141] = 1.216481; bs_val[142] = 1.216492; bs_val[143] = 1.216502; bs_val[144] = 1.216513; bs_val[145] = 1.216523; bs_val[146] = 1.216534; bs_val[147] = 1.216544; bs_val[148] = 1.216555; bs_val[149] = 1.216565; 
bs_val[150] = 1.216576; bs_val[151] = 1.216586; bs_val[152] = 1.216596; bs_val[153] = 1.216607; bs_val[154] = 1.216617; bs_val[155] = 1.216628; bs_val[156] = 1.216638; bs_val[157] = 1.216649; bs_val[158] = 1.216659; bs_val[159] = 1.216670; 
bs_val[160] = 1.216680; bs_val[161] = 1.216691; bs_val[162] = 1.216701; bs_val[163] = 1.216712; bs_val[164] = 1.216722; bs_val[165] = 1.216732; bs_val[166] = 1.216743; bs_val[167] = 1.216753; bs_val[168] = 1.216764; bs_val[169] = 1.216774; 
bs_val[170] = 1.216785; bs_val[171] = 1.216795; bs_val[172] = 1.216806; bs_val[173] = 1.216816; bs_val[174] = 1.216827; bs_val[175] = 1.216837; bs_val[176] = 1.216848; bs_val[177] = 1.216858; bs_val[178] = 1.216868; bs_val[179] = 1.216879; 
bs_val[180] = 1.216889; bs_val[181] = 1.216900; bs_val[182] = 1.216910; bs_val[183] = 1.216921; bs_val[184] = 1.216931; bs_val[185] = 1.216942; bs_val[186] = 1.216952; bs_val[187] = 1.216963; bs_val[188] = 1.216973; bs_val[189] = 1.216984; 
bs_val[190] = 1.216994; bs_val[191] = 1.217005; bs_val[192] = 1.217015; bs_val[193] = 1.217026; bs_val[194] = 1.217036; bs_val[195] = 1.217046; bs_val[196] = 1.217057; bs_val[197] = 1.217067; bs_val[198] = 1.217078; bs_val[199] = 1.217088; 
bs_val[200] = 1.217099; bs_val[201] = 1.217109; bs_val[202] = 1.217120; bs_val[203] = 1.217130; bs_val[204] = 1.217141; bs_val[205] = 1.217151; bs_val[206] = 1.217162; bs_val[207] = 1.217172; bs_val[208] = 1.217183; bs_val[209] = 1.217193; 
bs_val[210] = 1.217204; bs_val[211] = 1.217214; bs_val[212] = 1.217225; bs_val[213] = 1.217235; bs_val[214] = 1.217246; bs_val[215] = 1.217256; bs_val[216] = 1.217266; bs_val[217] = 1.217277; bs_val[218] = 1.217287; bs_val[219] = 1.217298; 
bs_val[220] = 1.217308; bs_val[221] = 1.217319; bs_val[222] = 1.217329; bs_val[223] = 1.217340; bs_val[224] = 1.217350; bs_val[225] = 1.217361; bs_val[226] = 1.217371; bs_val[227] = 1.217382; bs_val[228] = 1.217392; bs_val[229] = 1.217403; 
bs_val[230] = 1.217413; bs_val[231] = 1.217424; bs_val[232] = 1.217434; bs_val[233] = 1.217445; bs_val[234] = 1.217455; bs_val[235] = 1.217466; bs_val[236] = 1.217476; bs_val[237] = 1.217487; bs_val[238] = 1.217497; bs_val[239] = 1.217508; 
bs_val[240] = 1.217518; bs_val[241] = 1.217529; bs_val[242] = 1.217539; bs_val[243] = 1.217550; bs_val[244] = 1.217560; bs_val[245] = 1.217571; bs_val[246] = 1.217581; bs_val[247] = 1.217592; bs_val[248] = 1.217602; bs_val[249] = 1.217613; 
bs_val[250] = 1.217623; bs_val[251] = 1.217633; bs_val[252] = 1.217644; bs_val[253] = 1.217654; bs_val[254] = 1.217665; bs_val[255] = 1.217675; bs_val[256] = 1.217686; bs_val[257] = 1.217696; bs_val[258] = 1.217707; bs_val[259] = 1.217717; 
bs_val[260] = 1.217728; bs_val[261] = 1.217738; bs_val[262] = 1.217749; bs_val[263] = 1.217759; bs_val[264] = 1.217770; bs_val[265] = 1.217780; bs_val[266] = 1.217791; bs_val[267] = 1.217801; bs_val[268] = 1.217812; bs_val[269] = 1.217822; 
bs_val[270] = 1.217833; bs_val[271] = 1.217843; bs_val[272] = 1.217854; bs_val[273] = 1.217864; bs_val[274] = 1.217875; bs_val[275] = 1.217885; bs_val[276] = 1.217896; bs_val[277] = 1.217906; bs_val[278] = 1.217917; bs_val[279] = 1.217927; 
bs_val[280] = 1.217938; bs_val[281] = 1.217948; bs_val[282] = 1.217959; bs_val[283] = 1.217969; bs_val[284] = 1.217980; bs_val[285] = 1.217990; bs_val[286] = 1.218001; bs_val[287] = 1.218011; bs_val[288] = 1.218022; bs_val[289] = 1.218032; 
bs_val[290] = 1.218043; bs_val[291] = 1.218053; bs_val[292] = 1.218064; bs_val[293] = 1.218074; bs_val[294] = 1.218085; bs_val[295] = 1.218095; bs_val[296] = 1.218106; bs_val[297] = 1.218117; bs_val[298] = 1.218127; bs_val[299] = 1.218138; 
bs_val[300] = 1.218148; bs_val[301] = 1.218159; bs_val[302] = 1.218169; bs_val[303] = 1.218180; bs_val[304] = 1.218190; bs_val[305] = 1.218201; bs_val[306] = 1.218211; bs_val[307] = 1.218222; bs_val[308] = 1.218232; bs_val[309] = 1.218243; 
bs_val[310] = 1.218253; bs_val[311] = 1.218264; bs_val[312] = 1.218274; bs_val[313] = 1.218285; bs_val[314] = 1.218295; bs_val[315] = 1.218306; bs_val[316] = 1.218316; bs_val[317] = 1.218327; bs_val[318] = 1.218337; bs_val[319] = 1.218348; 
bs_val[320] = 1.218358; bs_val[321] = 1.218369; bs_val[322] = 1.218379; bs_val[323] = 1.218390; bs_val[324] = 1.218400; bs_val[325] = 1.218411; bs_val[326] = 1.218421; bs_val[327] = 1.218432; bs_val[328] = 1.218442; bs_val[329] = 1.218453; 
bs_val[330] = 1.218463; bs_val[331] = 1.218474; bs_val[332] = 1.218485; bs_val[333] = 1.218495; bs_val[334] = 1.218506; bs_val[335] = 1.218516; bs_val[336] = 1.218527; bs_val[337] = 1.218537; bs_val[338] = 1.218548; bs_val[339] = 1.218558; 
bs_val[340] = 1.218569; bs_val[341] = 1.218579; bs_val[342] = 1.218590; bs_val[343] = 1.218600; bs_val[344] = 1.218611; bs_val[345] = 1.218621; bs_val[346] = 1.218632; bs_val[347] = 1.218642; bs_val[348] = 1.218653; bs_val[349] = 1.218663; 
bs_val[350] = 1.218674; bs_val[351] = 1.218684; bs_val[352] = 1.218695; bs_val[353] = 1.218706; bs_val[354] = 1.218716; bs_val[355] = 1.218727; bs_val[356] = 1.218737; bs_val[357] = 1.218748; bs_val[358] = 1.218758; bs_val[359] = 1.218769; 
bs_val[360] = 1.218779; bs_val[361] = 1.218790; bs_val[362] = 1.218800; bs_val[363] = 1.218811; bs_val[364] = 1.218821; bs_val[365] = 1.218832; bs_val[366] = 1.218842; bs_val[367] = 1.218853; bs_val[368] = 1.218864; bs_val[369] = 1.218874; 
bs_val[370] = 1.218885; bs_val[371] = 1.218895; bs_val[372] = 1.218906; bs_val[373] = 1.218916; bs_val[374] = 1.218927; bs_val[375] = 1.218937; bs_val[376] = 1.218948; bs_val[377] = 1.218958; bs_val[378] = 1.218969; bs_val[379] = 1.218979; 
bs_val[380] = 1.218990; bs_val[381] = 1.219000; bs_val[382] = 1.219011; bs_val[383] = 1.219022; bs_val[384] = 1.219032; bs_val[385] = 1.219043; bs_val[386] = 1.219053; bs_val[387] = 1.219064; bs_val[388] = 1.219074; bs_val[389] = 1.219085; 
bs_val[390] = 1.219095; bs_val[391] = 1.219106; bs_val[392] = 1.219116; bs_val[393] = 1.219127; bs_val[394] = 1.219137; bs_val[395] = 1.219148; bs_val[396] = 1.219159; bs_val[397] = 1.219169; bs_val[398] = 1.219180; bs_val[399] = 1.219190; 
bs_val[400] = 1.219201; bs_val[401] = 1.219211; bs_val[402] = 1.219222; bs_val[403] = 1.219232; bs_val[404] = 1.219243; bs_val[405] = 1.219253; bs_val[406] = 1.219264; bs_val[407] = 1.219275; bs_val[408] = 1.219285; bs_val[409] = 1.219296; 
bs_val[410] = 1.219306; bs_val[411] = 1.219317; bs_val[412] = 1.219327; bs_val[413] = 1.219338; bs_val[414] = 1.219348; bs_val[415] = 1.219359; bs_val[416] = 1.219370; bs_val[417] = 1.219380; bs_val[418] = 1.219391; bs_val[419] = 1.219401; 
bs_val[420] = 1.219412; bs_val[421] = 1.219422; bs_val[422] = 1.219433; bs_val[423] = 1.219443; bs_val[424] = 1.219454; bs_val[425] = 1.219464; bs_val[426] = 1.219475; bs_val[427] = 1.219486; bs_val[428] = 1.219496; bs_val[429] = 1.219507; 
bs_val[430] = 1.219517; bs_val[431] = 1.219528; bs_val[432] = 1.219538; bs_val[433] = 1.219549; bs_val[434] = 1.219559; bs_val[435] = 1.219570; bs_val[436] = 1.219581; bs_val[437] = 1.219591; bs_val[438] = 1.219602; bs_val[439] = 1.219612; 
bs_val[440] = 1.219623; bs_val[441] = 1.219633; bs_val[442] = 1.219644; bs_val[443] = 1.219655; bs_val[444] = 1.219665; bs_val[445] = 1.219676; bs_val[446] = 1.219686; bs_val[447] = 1.219697; bs_val[448] = 1.219707; bs_val[449] = 1.219718; 
bs_val[450] = 1.219728; bs_val[451] = 1.219739; bs_val[452] = 1.219750; bs_val[453] = 1.219760; bs_val[454] = 1.219771; bs_val[455] = 1.219781; bs_val[456] = 1.219792; bs_val[457] = 1.219802; bs_val[458] = 1.219813; bs_val[459] = 1.219824; 
bs_val[460] = 1.219834; bs_val[461] = 1.219845; bs_val[462] = 1.219855; bs_val[463] = 1.219866; bs_val[464] = 1.219876; bs_val[465] = 1.219887; bs_val[466] = 1.219897; bs_val[467] = 1.219908; bs_val[468] = 1.219919; bs_val[469] = 1.219929; 
bs_val[470] = 1.219940; bs_val[471] = 1.219950; bs_val[472] = 1.219961; bs_val[473] = 1.219971; bs_val[474] = 1.219982; bs_val[475] = 1.219993; bs_val[476] = 1.220003; bs_val[477] = 1.220014; bs_val[478] = 1.220024; bs_val[479] = 1.220035; 
bs_val[480] = 1.220045; bs_val[481] = 1.220056; bs_val[482] = 1.220067; bs_val[483] = 1.220077; bs_val[484] = 1.220088; bs_val[485] = 1.220098; bs_val[486] = 1.220109; bs_val[487] = 1.220119; bs_val[488] = 1.220130; bs_val[489] = 1.220141; 
bs_val[490] = 1.220151; bs_val[491] = 1.220162; bs_val[492] = 1.220172; bs_val[493] = 1.220183; bs_val[494] = 1.220194; bs_val[495] = 1.220204; bs_val[496] = 1.220215; bs_val[497] = 1.220225; bs_val[498] = 1.220236; bs_val[499] = 1.220246; 
bs_val[500] = 1.220257; bs_val[501] = 1.220268; bs_val[502] = 1.220278; bs_val[503] = 1.220289; bs_val[504] = 1.220299; bs_val[505] = 1.220310; bs_val[506] = 1.220321; bs_val[507] = 1.220331; bs_val[508] = 1.220342; bs_val[509] = 1.220352; 
bs_val[510] = 1.220363; bs_val[511] = 1.220373; bs_val[512] = 1.220384; bs_val[513] = 1.220395; bs_val[514] = 1.220405; bs_val[515] = 1.220416; bs_val[516] = 1.220426; bs_val[517] = 1.220437; bs_val[518] = 1.220448; bs_val[519] = 1.220458; 
bs_val[520] = 1.220469; bs_val[521] = 1.220479; bs_val[522] = 1.220490; bs_val[523] = 1.220500; bs_val[524] = 1.220511; bs_val[525] = 1.220522; bs_val[526] = 1.220532; bs_val[527] = 1.220543; bs_val[528] = 1.220553; bs_val[529] = 1.220564; 
bs_val[530] = 1.220575; bs_val[531] = 1.220585; bs_val[532] = 1.220596; bs_val[533] = 1.220606; bs_val[534] = 1.220617; bs_val[535] = 1.220628; bs_val[536] = 1.220638; bs_val[537] = 1.220649; bs_val[538] = 1.220659; bs_val[539] = 1.220670; 
bs_val[540] = 1.220681; bs_val[541] = 1.220691; bs_val[542] = 1.220702; bs_val[543] = 1.220712; bs_val[544] = 1.220723; bs_val[545] = 1.220733; bs_val[546] = 1.220744; bs_val[547] = 1.220755; bs_val[548] = 1.220765; bs_val[549] = 1.220776; 
bs_val[550] = 1.220786; bs_val[551] = 1.220797; bs_val[552] = 1.220808; bs_val[553] = 1.220818; bs_val[554] = 1.220829; bs_val[555] = 1.220839; bs_val[556] = 1.220850; bs_val[557] = 1.220861; bs_val[558] = 1.220871; bs_val[559] = 1.220882; 
bs_val[560] = 1.220892; bs_val[561] = 1.220903; bs_val[562] = 1.220914; bs_val[563] = 1.220924; bs_val[564] = 1.220935; bs_val[565] = 1.220945; bs_val[566] = 1.220956; bs_val[567] = 1.220967; bs_val[568] = 1.220977; bs_val[569] = 1.220988; 
bs_val[570] = 1.220999; bs_val[571] = 1.221009; bs_val[572] = 1.221020; bs_val[573] = 1.221030; bs_val[574] = 1.221041; bs_val[575] = 1.221052; bs_val[576] = 1.221062; bs_val[577] = 1.221073; bs_val[578] = 1.221083; bs_val[579] = 1.221094; 
bs_val[580] = 1.221105; bs_val[581] = 1.221115; bs_val[582] = 1.221126; bs_val[583] = 1.221136; bs_val[584] = 1.221147; bs_val[585] = 1.221158; bs_val[586] = 1.221168; bs_val[587] = 1.221179; bs_val[588] = 1.221189; bs_val[589] = 1.221200; 
bs_val[590] = 1.221211; bs_val[591] = 1.221221; bs_val[592] = 1.221232; bs_val[593] = 1.221243; bs_val[594] = 1.221253; bs_val[595] = 1.221264; bs_val[596] = 1.221274; bs_val[597] = 1.221285; bs_val[598] = 1.221296; bs_val[599] = 1.221306; 
bs_val[600] = 1.221317; bs_val[601] = 1.221327; bs_val[602] = 1.221338; bs_val[603] = 1.221349; bs_val[604] = 1.221359; bs_val[605] = 1.221370; bs_val[606] = 1.221381; bs_val[607] = 1.221391; bs_val[608] = 1.221402; bs_val[609] = 1.221412; 
bs_val[610] = 1.221423; bs_val[611] = 1.221434; bs_val[612] = 1.221444; bs_val[613] = 1.221455; bs_val[614] = 1.221465; bs_val[615] = 1.221476; bs_val[616] = 1.221487; bs_val[617] = 1.221497; bs_val[618] = 1.221508; bs_val[619] = 1.221519; 
bs_val[620] = 1.221529; bs_val[621] = 1.221540; bs_val[622] = 1.221550; bs_val[623] = 1.221561; bs_val[624] = 1.221572; bs_val[625] = 1.221582; bs_val[626] = 1.221593; bs_val[627] = 1.221604; bs_val[628] = 1.221614; bs_val[629] = 1.221625; 
bs_val[630] = 1.221635; bs_val[631] = 1.221646; bs_val[632] = 1.221657; bs_val[633] = 1.221667; bs_val[634] = 1.221678; bs_val[635] = 1.221689; bs_val[636] = 1.221699; bs_val[637] = 1.221710; bs_val[638] = 1.221721; bs_val[639] = 1.221731; 
bs_val[640] = 1.221742; bs_val[641] = 1.221752; bs_val[642] = 1.221763; bs_val[643] = 1.221774; bs_val[644] = 1.221784; bs_val[645] = 1.221795; bs_val[646] = 1.221806; bs_val[647] = 1.221816; bs_val[648] = 1.221827; bs_val[649] = 1.221837; 
bs_val[650] = 1.221848; bs_val[651] = 1.221859; bs_val[652] = 1.221869; bs_val[653] = 1.221880; bs_val[654] = 1.221891; bs_val[655] = 1.221901; bs_val[656] = 1.221912; bs_val[657] = 1.221923; bs_val[658] = 1.221933; bs_val[659] = 1.221944; 
bs_val[660] = 1.221954; bs_val[661] = 1.221965; bs_val[662] = 1.221976; bs_val[663] = 1.221986; bs_val[664] = 1.221997; bs_val[665] = 1.222008; bs_val[666] = 1.222018; bs_val[667] = 1.222029; bs_val[668] = 1.222040; bs_val[669] = 1.222050; 
bs_val[670] = 1.222061; bs_val[671] = 1.222071; bs_val[672] = 1.222082; bs_val[673] = 1.222093; bs_val[674] = 1.222103; bs_val[675] = 1.222114; bs_val[676] = 1.222125; bs_val[677] = 1.222135; bs_val[678] = 1.222146; bs_val[679] = 1.222157; 
bs_val[680] = 1.222167; bs_val[681] = 1.222178; bs_val[682] = 1.222189; bs_val[683] = 1.222199; bs_val[684] = 1.222210; bs_val[685] = 1.222220; bs_val[686] = 1.222231; bs_val[687] = 1.222242; bs_val[688] = 1.222252; bs_val[689] = 1.222263; 
bs_val[690] = 1.222274; bs_val[691] = 1.222284; bs_val[692] = 1.222295; bs_val[693] = 1.222306; bs_val[694] = 1.222316; bs_val[695] = 1.222327; bs_val[696] = 1.222338; bs_val[697] = 1.222348; bs_val[698] = 1.222359; bs_val[699] = 1.222370; 
bs_val[700] = 1.222380; bs_val[701] = 1.222391; bs_val[702] = 1.222402; bs_val[703] = 1.222412; bs_val[704] = 1.222423; bs_val[705] = 1.222434; bs_val[706] = 1.222444; bs_val[707] = 1.222455; bs_val[708] = 1.222465; bs_val[709] = 1.222476; 
bs_val[710] = 1.222487; bs_val[711] = 1.222497; bs_val[712] = 1.222508; bs_val[713] = 1.222519; bs_val[714] = 1.222529; bs_val[715] = 1.222540; bs_val[716] = 1.222551; bs_val[717] = 1.222561; bs_val[718] = 1.222572; bs_val[719] = 1.222583; 
bs_val[720] = 1.222593; bs_val[721] = 1.222604; bs_val[722] = 1.222615; bs_val[723] = 1.222625; bs_val[724] = 1.222636; bs_val[725] = 1.222647; bs_val[726] = 1.222657; bs_val[727] = 1.222668; bs_val[728] = 1.222679; bs_val[729] = 1.222689; 
bs_val[730] = 1.222700; bs_val[731] = 1.222711; bs_val[732] = 1.222721; bs_val[733] = 1.222732; bs_val[734] = 1.222743; bs_val[735] = 1.222753; bs_val[736] = 1.222764; bs_val[737] = 1.222775; bs_val[738] = 1.222785; bs_val[739] = 1.222796; 
bs_val[740] = 1.222807; bs_val[741] = 1.222817; bs_val[742] = 1.222828; bs_val[743] = 1.222839; bs_val[744] = 1.222849; bs_val[745] = 1.222860; bs_val[746] = 1.222871; bs_val[747] = 1.222881; bs_val[748] = 1.222892; bs_val[749] = 1.222903; 
bs_val[750] = 1.222913; bs_val[751] = 1.222924; bs_val[752] = 1.222935; bs_val[753] = 1.222945; bs_val[754] = 1.222956; bs_val[755] = 1.222967; bs_val[756] = 1.222977; bs_val[757] = 1.222988; bs_val[758] = 1.222999; bs_val[759] = 1.223009; 
bs_val[760] = 1.223020; bs_val[761] = 1.223031; bs_val[762] = 1.223041; bs_val[763] = 1.223052; bs_val[764] = 1.223063; bs_val[765] = 1.223073; bs_val[766] = 1.223084; bs_val[767] = 1.223095; bs_val[768] = 1.223105; bs_val[769] = 1.223116; 
bs_val[770] = 1.223127; bs_val[771] = 1.223137; bs_val[772] = 1.223148; bs_val[773] = 1.223159; bs_val[774] = 1.223169; bs_val[775] = 1.223180; bs_val[776] = 1.223191; bs_val[777] = 1.223202; bs_val[778] = 1.223212; bs_val[779] = 1.223223; 
bs_val[780] = 1.223234; bs_val[781] = 1.223244; bs_val[782] = 1.223255; bs_val[783] = 1.223266; bs_val[784] = 1.223276; bs_val[785] = 1.223287; bs_val[786] = 1.223298; bs_val[787] = 1.223308; bs_val[788] = 1.223319; bs_val[789] = 1.223330; 
bs_val[790] = 1.223340; bs_val[791] = 1.223351; bs_val[792] = 1.223362; bs_val[793] = 1.223372; bs_val[794] = 1.223383; bs_val[795] = 1.223394; bs_val[796] = 1.223405; bs_val[797] = 1.223415; bs_val[798] = 1.223426; bs_val[799] = 1.223437; 
bs_val[800] = 1.223447; bs_val[801] = 1.223458; bs_val[802] = 1.223469; bs_val[803] = 1.223479; bs_val[804] = 1.223490; bs_val[805] = 1.223501; bs_val[806] = 1.223511; bs_val[807] = 1.223522; bs_val[808] = 1.223533; bs_val[809] = 1.223543; 
bs_val[810] = 1.223554; bs_val[811] = 1.223565; bs_val[812] = 1.223576; bs_val[813] = 1.223586; bs_val[814] = 1.223597; bs_val[815] = 1.223608; bs_val[816] = 1.223618; bs_val[817] = 1.223629; bs_val[818] = 1.223640; bs_val[819] = 1.223650; 
bs_val[820] = 1.223661; bs_val[821] = 1.223672; bs_val[822] = 1.223682; bs_val[823] = 1.223693; bs_val[824] = 1.223704; bs_val[825] = 1.223715; bs_val[826] = 1.223725; bs_val[827] = 1.223736; bs_val[828] = 1.223747; bs_val[829] = 1.223757; 
bs_val[830] = 1.223768; bs_val[831] = 1.223779; bs_val[832] = 1.223789; bs_val[833] = 1.223800; bs_val[834] = 1.223811; bs_val[835] = 1.223822; bs_val[836] = 1.223832; bs_val[837] = 1.223843; bs_val[838] = 1.223854; bs_val[839] = 1.223864; 
bs_val[840] = 1.223875; bs_val[841] = 1.223886; bs_val[842] = 1.223896; bs_val[843] = 1.223907; bs_val[844] = 1.223918; bs_val[845] = 1.223929; bs_val[846] = 1.223939; bs_val[847] = 1.223950; bs_val[848] = 1.223961; bs_val[849] = 1.223971; 
bs_val[850] = 1.223982; bs_val[851] = 1.223993; bs_val[852] = 1.224004; bs_val[853] = 1.224014; bs_val[854] = 1.224025; bs_val[855] = 1.224036; bs_val[856] = 1.224046; bs_val[857] = 1.224057; bs_val[858] = 1.224068; bs_val[859] = 1.224078; 
bs_val[860] = 1.224089; bs_val[861] = 1.224100; bs_val[862] = 1.224111; bs_val[863] = 1.224121; bs_val[864] = 1.224132; bs_val[865] = 1.224143; bs_val[866] = 1.224153; bs_val[867] = 1.224164; bs_val[868] = 1.224175; bs_val[869] = 1.224186; 
bs_val[870] = 1.224196; bs_val[871] = 1.224207; bs_val[872] = 1.224218; bs_val[873] = 1.224228; bs_val[874] = 1.224239; bs_val[875] = 1.224250; bs_val[876] = 1.224261; bs_val[877] = 1.224271; bs_val[878] = 1.224282; bs_val[879] = 1.224293; 
bs_val[880] = 1.224303; bs_val[881] = 1.224314; bs_val[882] = 1.224325; bs_val[883] = 1.224336; bs_val[884] = 1.224346; bs_val[885] = 1.224357; bs_val[886] = 1.224368; bs_val[887] = 1.224379; bs_val[888] = 1.224389; bs_val[889] = 1.224400; 
bs_val[890] = 1.224411; bs_val[891] = 1.224421; bs_val[892] = 1.224432; bs_val[893] = 1.224443; bs_val[894] = 1.224454; bs_val[895] = 1.224464; bs_val[896] = 1.224475; bs_val[897] = 1.224486; bs_val[898] = 1.224496; bs_val[899] = 1.224507; 
bs_val[900] = 1.224518; bs_val[901] = 1.224529; bs_val[902] = 1.224539; bs_val[903] = 1.224550; bs_val[904] = 1.224561; bs_val[905] = 1.224572; bs_val[906] = 1.224582; bs_val[907] = 1.224593; bs_val[908] = 1.224604; bs_val[909] = 1.224614; 
bs_val[910] = 1.224625; bs_val[911] = 1.224636; bs_val[912] = 1.224647; bs_val[913] = 1.224657; bs_val[914] = 1.224668; bs_val[915] = 1.224679; bs_val[916] = 1.224690; bs_val[917] = 1.224700; bs_val[918] = 1.224711; bs_val[919] = 1.224722; 
bs_val[920] = 1.224732; bs_val[921] = 1.224743; bs_val[922] = 1.224754; bs_val[923] = 1.224765; bs_val[924] = 1.224775; bs_val[925] = 1.224786; bs_val[926] = 1.224797; bs_val[927] = 1.224808; bs_val[928] = 1.224818; bs_val[929] = 1.224829; 
bs_val[930] = 1.224840; bs_val[931] = 1.224851; bs_val[932] = 1.224861; bs_val[933] = 1.224872; bs_val[934] = 1.224883; bs_val[935] = 1.224893; bs_val[936] = 1.224904; bs_val[937] = 1.224915; bs_val[938] = 1.224926; bs_val[939] = 1.224936; 
bs_val[940] = 1.224947; bs_val[941] = 1.224958; bs_val[942] = 1.224969; bs_val[943] = 1.224979; bs_val[944] = 1.224990; bs_val[945] = 1.225001; bs_val[946] = 1.225012; bs_val[947] = 1.225022; bs_val[948] = 1.225033; bs_val[949] = 1.225044; 
bs_val[950] = 1.225055; bs_val[951] = 1.225065; bs_val[952] = 1.225076; bs_val[953] = 1.225087; bs_val[954] = 1.225098; bs_val[955] = 1.225108; bs_val[956] = 1.225119; bs_val[957] = 1.225130; bs_val[958] = 1.225141; bs_val[959] = 1.225151; 
bs_val[960] = 1.225162; bs_val[961] = 1.225173; bs_val[962] = 1.225184; bs_val[963] = 1.225194; bs_val[964] = 1.225205; bs_val[965] = 1.225216; bs_val[966] = 1.225227; bs_val[967] = 1.225237; bs_val[968] = 1.225248; bs_val[969] = 1.225259; 
bs_val[970] = 1.225270; bs_val[971] = 1.225280; bs_val[972] = 1.225291; bs_val[973] = 1.225302; bs_val[974] = 1.225313; bs_val[975] = 1.225323; bs_val[976] = 1.225334; bs_val[977] = 1.225345; bs_val[978] = 1.225356; bs_val[979] = 1.225366; 
bs_val[980] = 1.225377; bs_val[981] = 1.225388; bs_val[982] = 1.225399; bs_val[983] = 1.225409; bs_val[984] = 1.225420; bs_val[985] = 1.225431; bs_val[986] = 1.225442; bs_val[987] = 1.225452; bs_val[988] = 1.225463; bs_val[989] = 1.225474; 
bs_val[990] = 1.225485; bs_val[991] = 1.225495; bs_val[992] = 1.225506; bs_val[993] = 1.225517; bs_val[994] = 1.225528; bs_val[995] = 1.225538; bs_val[996] = 1.225549; bs_val[997] = 1.225560; bs_val[998] = 1.225571; bs_val[999] = 1.225581; 
bs_val[1000] = 1.225592; bs_val[1001] = 1.225603; bs_val[1002] = 1.225614; bs_val[1003] = 1.225624; bs_val[1004] = 1.225635; bs_val[1005] = 1.225646; bs_val[1006] = 1.225657; bs_val[1007] = 1.225668; bs_val[1008] = 1.225678; bs_val[1009] = 1.225689; 
bs_val[1010] = 1.225700; bs_val[1011] = 1.225711; bs_val[1012] = 1.225721; bs_val[1013] = 1.225732; bs_val[1014] = 1.225743; bs_val[1015] = 1.225754; bs_val[1016] = 1.225764; bs_val[1017] = 1.225775; bs_val[1018] = 1.225786; bs_val[1019] = 1.225797; 
bs_val[1020] = 1.225807; bs_val[1021] = 1.225818; bs_val[1022] = 1.225829; bs_val[1023] = 1.225840; bs_val[FilePathLength] = 1.225851; bs_val[1025] = 1.225861; bs_val[1026] = 1.225872; bs_val[1027] = 1.225883; bs_val[1028] = 1.225894; bs_val[1029] = 1.225904; 
bs_val[1030] = 1.225915; bs_val[1031] = 1.225926; bs_val[1032] = 1.225937; bs_val[1033] = 1.225948; bs_val[1034] = 1.225958; bs_val[1035] = 1.225969; bs_val[1036] = 1.225980; bs_val[1037] = 1.225991; bs_val[1038] = 1.226001; bs_val[1039] = 1.226012; 
bs_val[1040] = 1.226023; bs_val[1041] = 1.226034; bs_val[1042] = 1.226044; bs_val[1043] = 1.226055; bs_val[1044] = 1.226066; bs_val[1045] = 1.226077; bs_val[1046] = 1.226088; bs_val[1047] = 1.226098; bs_val[1048] = 1.226109; bs_val[1049] = 1.226120; 
bs_val[1050] = 1.226131; bs_val[1051] = 1.226141; bs_val[1052] = 1.226152; bs_val[1053] = 1.226163; bs_val[1054] = 1.226174; bs_val[1055] = 1.226185; bs_val[1056] = 1.226195; bs_val[1057] = 1.226206; bs_val[1058] = 1.226217; bs_val[1059] = 1.226228; 
bs_val[1060] = 1.226239; bs_val[1061] = 1.226249; bs_val[1062] = 1.226260; bs_val[1063] = 1.226271; bs_val[1064] = 1.226282; bs_val[1065] = 1.226292; bs_val[1066] = 1.226303; bs_val[1067] = 1.226314; bs_val[1068] = 1.226325; bs_val[1069] = 1.226336; 
bs_val[1070] = 1.226346; bs_val[1071] = 1.226357; bs_val[1072] = 1.226368; bs_val[1073] = 1.226379; bs_val[1074] = 1.226390; bs_val[1075] = 1.226400; bs_val[1076] = 1.226411; bs_val[1077] = 1.226422; bs_val[1078] = 1.226433; bs_val[1079] = 1.226443; 
bs_val[1080] = 1.226454; bs_val[1081] = 1.226465; bs_val[1082] = 1.226476; bs_val[1083] = 1.226487; bs_val[1084] = 1.226497; bs_val[1085] = 1.226508; bs_val[1086] = 1.226519; bs_val[1087] = 1.226530; bs_val[1088] = 1.226541; bs_val[1089] = 1.226551; 
bs_val[1090] = 1.226562; bs_val[1091] = 1.226573; bs_val[1092] = 1.226584; bs_val[1093] = 1.226595; bs_val[1094] = 1.226605; bs_val[1095] = 1.226616; bs_val[1096] = 1.226627; bs_val[1097] = 1.226638; bs_val[1098] = 1.226649; bs_val[1099] = 1.226659; 
bs_val[1100] = 1.226670; bs_val[1101] = 1.226681; bs_val[1102] = 1.226692; bs_val[1103] = 1.226703; bs_val[1104] = 1.226713; bs_val[1105] = 1.226724; bs_val[1106] = 1.226735; bs_val[1107] = 1.226746; bs_val[1108] = 1.226757; bs_val[1109] = 1.226767; 
bs_val[1110] = 1.226778; bs_val[1111] = 1.226789; bs_val[1112] = 1.226800; bs_val[1113] = 1.226811; bs_val[1114] = 1.226821; bs_val[1115] = 1.226832; bs_val[1116] = 1.226843; bs_val[1117] = 1.226854; bs_val[1118] = 1.226865; bs_val[1119] = 1.226875; 
bs_val[1120] = 1.226886; bs_val[1121] = 1.226897; bs_val[1122] = 1.226908; bs_val[1123] = 1.226919; bs_val[1124] = 1.226929; bs_val[1125] = 1.226940; bs_val[1126] = 1.226951; bs_val[1127] = 1.226962; bs_val[1128] = 1.226973; bs_val[1129] = 1.226983; 
bs_val[1130] = 1.226994; bs_val[1131] = 1.227005; bs_val[1132] = 1.227016; bs_val[1133] = 1.227027; bs_val[1134] = 1.227038; bs_val[1135] = 1.227048; bs_val[1136] = 1.227059; bs_val[1137] = 1.227070; bs_val[1138] = 1.227081; bs_val[1139] = 1.227092; 
bs_val[1140] = 1.227102; bs_val[1141] = 1.227113; bs_val[1142] = 1.227124; bs_val[1143] = 1.227135; bs_val[1144] = 1.227146; bs_val[1145] = 1.227156; bs_val[1146] = 1.227167; bs_val[1147] = 1.227178; bs_val[1148] = 1.227189; bs_val[1149] = 1.227200; 
bs_val[1150] = 1.227211; bs_val[1151] = 1.227221; bs_val[1152] = 1.227232; bs_val[1153] = 1.227243; bs_val[1154] = 1.227254; bs_val[1155] = 1.227265; bs_val[1156] = 1.227275; bs_val[1157] = 1.227286; bs_val[1158] = 1.227297; bs_val[1159] = 1.227308; 
bs_val[1160] = 1.227319; bs_val[1161] = 1.227330; bs_val[1162] = 1.227340; bs_val[1163] = 1.227351; bs_val[1164] = 1.227362; bs_val[1165] = 1.227373; bs_val[1166] = 1.227384; bs_val[1167] = 1.227394; bs_val[1168] = 1.227405; bs_val[1169] = 1.227416; 
bs_val[1170] = 1.227427; bs_val[1171] = 1.227438; bs_val[1172] = 1.227449; bs_val[1173] = 1.227459; bs_val[1174] = 1.227470; bs_val[1175] = 1.227481; bs_val[1176] = 1.227492; bs_val[1177] = 1.227503; bs_val[1178] = 1.227514; bs_val[1179] = 1.227524; 
bs_val[1180] = 1.227535; bs_val[1181] = 1.227546; bs_val[1182] = 1.227557; bs_val[1183] = 1.227568; bs_val[1184] = 1.227579; bs_val[1185] = 1.227589; bs_val[1186] = 1.227600; bs_val[1187] = 1.227611; bs_val[1188] = 1.227622; bs_val[1189] = 1.227633; 
bs_val[1190] = 1.227644; bs_val[1191] = 1.227654; bs_val[1192] = 1.227665; bs_val[1193] = 1.227676; bs_val[1194] = 1.227687; bs_val[1195] = 1.227698; bs_val[1196] = 1.227708; bs_val[1197] = 1.227719; bs_val[1198] = 1.227730; bs_val[1199] = 1.227741; 
bs_val[1200] = 1.227752; bs_val[1201] = 1.227763; bs_val[1202] = 1.227774; bs_val[1203] = 1.227784; bs_val[1204] = 1.227795; bs_val[1205] = 1.227806; bs_val[1206] = 1.227817; bs_val[1207] = 1.227828; bs_val[1208] = 1.227839; bs_val[1209] = 1.227849; 
bs_val[1210] = 1.227860; bs_val[1211] = 1.227871; bs_val[1212] = 1.227882; bs_val[1213] = 1.227893; bs_val[1214] = 1.227904; bs_val[1215] = 1.227914; bs_val[1216] = 1.227925; bs_val[1217] = 1.227936; bs_val[1218] = 1.227947; bs_val[1219] = 1.227958; 
bs_val[1220] = 1.227969; bs_val[1221] = 1.227979; bs_val[1222] = 1.227990; bs_val[1223] = 1.228001; bs_val[1224] = 1.228012; bs_val[1225] = 1.228023; bs_val[1226] = 1.228034; bs_val[1227] = 1.228045; bs_val[1228] = 1.228055; bs_val[1229] = 1.228066; 
bs_val[1230] = 1.228077; bs_val[1231] = 1.228088; bs_val[1232] = 1.228099; bs_val[1233] = 1.228110; bs_val[1234] = 1.228120; bs_val[1235] = 1.228131; bs_val[1236] = 1.228142; bs_val[1237] = 1.228153; bs_val[1238] = 1.228164; bs_val[1239] = 1.228175; 
bs_val[1240] = 1.228186; bs_val[1241] = 1.228196; bs_val[1242] = 1.228207; bs_val[1243] = 1.228218; bs_val[1244] = 1.228229; bs_val[1245] = 1.228240; bs_val[1246] = 1.228251; bs_val[1247] = 1.228262; bs_val[1248] = 1.228272; bs_val[1249] = 1.228283; 
bs_val[1250] = 1.228294; bs_val[1251] = 1.228305; bs_val[1252] = 1.228316; bs_val[1253] = 1.228327; bs_val[1254] = 1.228337; bs_val[1255] = 1.228348; bs_val[1256] = 1.228359; bs_val[1257] = 1.228370; bs_val[1258] = 1.228381; bs_val[1259] = 1.228392; 
bs_val[1260] = 1.228403; bs_val[1261] = 1.228413; bs_val[1262] = 1.228424; bs_val[1263] = 1.228435; bs_val[1264] = 1.228446; bs_val[1265] = 1.228457; bs_val[1266] = 1.228468; bs_val[1267] = 1.228479; bs_val[1268] = 1.228490; bs_val[1269] = 1.228500; 
bs_val[1270] = 1.228511; bs_val[1271] = 1.228522; bs_val[1272] = 1.228533; bs_val[1273] = 1.228544; bs_val[1274] = 1.228555; bs_val[1275] = 1.228566; bs_val[1276] = 1.228576; bs_val[1277] = 1.228587; bs_val[1278] = 1.228598; bs_val[1279] = 1.228609; 
bs_val[1280] = 1.228620; bs_val[1281] = 1.228631; bs_val[1282] = 1.228642; bs_val[1283] = 1.228652; bs_val[1284] = 1.228663; bs_val[1285] = 1.228674; bs_val[1286] = 1.228685; bs_val[1287] = 1.228696; bs_val[1288] = 1.228707; bs_val[1289] = 1.228718; 
bs_val[1290] = 1.228729; bs_val[1291] = 1.228739; bs_val[1292] = 1.228750; bs_val[1293] = 1.228761; bs_val[1294] = 1.228772; bs_val[1295] = 1.228783; bs_val[1296] = 1.228794; bs_val[1297] = 1.228805; bs_val[1298] = 1.228815; bs_val[1299] = 1.228826; 
bs_val[1300] = 1.228837; bs_val[1301] = 1.228848; bs_val[1302] = 1.228859; bs_val[1303] = 1.228870; bs_val[1304] = 1.228881; bs_val[1305] = 1.228892; bs_val[1306] = 1.228902; bs_val[1307] = 1.228913; bs_val[1308] = 1.228924; bs_val[1309] = 1.228935; 
bs_val[1310] = 1.228946; bs_val[1311] = 1.228957; bs_val[1312] = 1.228968; bs_val[1313] = 1.228979; bs_val[1314] = 1.228989; bs_val[1315] = 1.229000; bs_val[1316] = 1.229011; bs_val[1317] = 1.229022; bs_val[1318] = 1.229033; bs_val[1319] = 1.229044; 
bs_val[1320] = 1.229055; bs_val[1321] = 1.229066; bs_val[1322] = 1.229077; bs_val[1323] = 1.229087; bs_val[1324] = 1.229098; bs_val[1325] = 1.229109; bs_val[1326] = 1.229120; bs_val[1327] = 1.229131; bs_val[1328] = 1.229142; bs_val[1329] = 1.229153; 
bs_val[1330] = 1.229164; bs_val[1331] = 1.229174; bs_val[1332] = 1.229185; bs_val[1333] = 1.229196; bs_val[1334] = 1.229207; bs_val[1335] = 1.229218; bs_val[1336] = 1.229229; bs_val[1337] = 1.229240; bs_val[1338] = 1.229251; bs_val[1339] = 1.229262; 
bs_val[1340] = 1.229272; bs_val[1341] = 1.229283; bs_val[1342] = 1.229294; bs_val[1343] = 1.229305; bs_val[1344] = 1.229316; bs_val[1345] = 1.229327; bs_val[1346] = 1.229338; bs_val[1347] = 1.229349; bs_val[1348] = 1.229360; bs_val[1349] = 1.229370; 
bs_val[1350] = 1.229381; bs_val[1351] = 1.229392; bs_val[1352] = 1.229403; bs_val[1353] = 1.229414; bs_val[1354] = 1.229425; bs_val[1355] = 1.229436; bs_val[1356] = 1.229447; bs_val[1357] = 1.229458; bs_val[1358] = 1.229468; bs_val[1359] = 1.229479; 
bs_val[1360] = 1.229490; bs_val[1361] = 1.229501; bs_val[1362] = 1.229512; bs_val[1363] = 1.229523; bs_val[1364] = 1.229534; bs_val[1365] = 1.229545; bs_val[1366] = 1.229556; bs_val[1367] = 1.229567; bs_val[1368] = 1.229577; bs_val[1369] = 1.229588; 
bs_val[1370] = 1.229599; bs_val[1371] = 1.229610; bs_val[1372] = 1.229621; bs_val[1373] = 1.229632; bs_val[1374] = 1.229643; bs_val[1375] = 1.229654; bs_val[1376] = 1.229665; bs_val[1377] = 1.229676; bs_val[1378] = 1.229686; bs_val[1379] = 1.229697; 
bs_val[1380] = 1.229708; bs_val[1381] = 1.229719; bs_val[1382] = 1.229730; bs_val[1383] = 1.229741; bs_val[1384] = 1.229752; bs_val[1385] = 1.229763; bs_val[1386] = 1.229774; bs_val[1387] = 1.229785; bs_val[1388] = 1.229795; bs_val[1389] = 1.229806; 
bs_val[1390] = 1.229817; bs_val[1391] = 1.229828; bs_val[1392] = 1.229839; bs_val[1393] = 1.229850; bs_val[1394] = 1.229861; bs_val[1395] = 1.229872; bs_val[1396] = 1.229883; bs_val[1397] = 1.229894; bs_val[1398] = 1.229905; bs_val[1399] = 1.229915; 
bs_val[1400] = 1.229926; bs_val[1401] = 1.229937; bs_val[1402] = 1.229948; bs_val[1403] = 1.229959; bs_val[1404] = 1.229970; bs_val[1405] = 1.229981; bs_val[1406] = 1.229992; bs_val[1407] = 1.230003; bs_val[1408] = 1.230014; bs_val[1409] = 1.230025; 
bs_val[1410] = 1.230036; bs_val[1411] = 1.230046; bs_val[1412] = 1.230057; bs_val[1413] = 1.230068; bs_val[1414] = 1.230079; bs_val[1415] = 1.230090; bs_val[1416] = 1.230101; bs_val[1417] = 1.230112; bs_val[1418] = 1.230123; bs_val[1419] = 1.230134; 
bs_val[1420] = 1.230145; bs_val[1421] = 1.230156; bs_val[1422] = 1.230167; bs_val[1423] = 1.230177; bs_val[1424] = 1.230188; bs_val[1425] = 1.230199; bs_val[1426] = 1.230210; bs_val[1427] = 1.230221; bs_val[1428] = 1.230232; bs_val[1429] = 1.230243; 
bs_val[1430] = 1.230254; bs_val[1431] = 1.230265; bs_val[1432] = 1.230276; bs_val[1433] = 1.230287; bs_val[1434] = 1.230298; bs_val[1435] = 1.230308; bs_val[1436] = 1.230319; bs_val[1437] = 1.230330; bs_val[1438] = 1.230341; bs_val[1439] = 1.230352; 
bs_val[1440] = 1.230363; bs_val[1441] = 1.230374; bs_val[1442] = 1.230385; bs_val[1443] = 1.230396; bs_val[1444] = 1.230407; bs_val[1445] = 1.230418; bs_val[1446] = 1.230429; bs_val[1447] = 1.230440; bs_val[1448] = 1.230451; bs_val[1449] = 1.230461; 
bs_val[1450] = 1.230472; bs_val[1451] = 1.230483; bs_val[1452] = 1.230494; bs_val[1453] = 1.230505; bs_val[1454] = 1.230516; bs_val[1455] = 1.230527; bs_val[1456] = 1.230538; bs_val[1457] = 1.230549; bs_val[1458] = 1.230560; bs_val[1459] = 1.230571; 
bs_val[1460] = 1.230582; bs_val[1461] = 1.230593; bs_val[1462] = 1.230604; bs_val[1463] = 1.230614; bs_val[1464] = 1.230625; bs_val[1465] = 1.230636; bs_val[1466] = 1.230647; bs_val[1467] = 1.230658; bs_val[1468] = 1.230669; bs_val[1469] = 1.230680; 
bs_val[1470] = 1.230691; bs_val[1471] = 1.230702; bs_val[1472] = 1.230713; bs_val[1473] = 1.230724; bs_val[1474] = 1.230735; bs_val[1475] = 1.230746; bs_val[1476] = 1.230757; bs_val[1477] = 1.230768; bs_val[1478] = 1.230779; bs_val[1479] = 1.230789; 
bs_val[1480] = 1.230800; bs_val[1481] = 1.230811; bs_val[1482] = 1.230822; bs_val[1483] = 1.230833; bs_val[1484] = 1.230844; bs_val[1485] = 1.230855; bs_val[1486] = 1.230866; bs_val[1487] = 1.230877; bs_val[1488] = 1.230888; bs_val[1489] = 1.230899; 
bs_val[1490] = 1.230910; bs_val[1491] = 1.230921; bs_val[1492] = 1.230932; bs_val[1493] = 1.230943; bs_val[1494] = 1.230954; bs_val[1495] = 1.230965; bs_val[1496] = 1.230976; bs_val[1497] = 1.230986; bs_val[1498] = 1.230997; bs_val[1499] = 1.231008; 
bs_val[1500] = 1.231019; bs_val[1501] = 1.231030; bs_val[1502] = 1.231041; bs_val[1503] = 1.231052; bs_val[1504] = 1.231063; bs_val[1505] = 1.231074; bs_val[1506] = 1.231085; bs_val[1507] = 1.231096; bs_val[1508] = 1.231107; bs_val[1509] = 1.231118; 
bs_val[1510] = 1.231129; bs_val[1511] = 1.231140; bs_val[1512] = 1.231151; bs_val[1513] = 1.231162; bs_val[1514] = 1.231173; bs_val[1515] = 1.231184; bs_val[1516] = 1.231195; bs_val[1517] = 1.231206; bs_val[1518] = 1.231216; bs_val[1519] = 1.231227; 
bs_val[1520] = 1.231238; bs_val[1521] = 1.231249; bs_val[1522] = 1.231260; bs_val[1523] = 1.231271; bs_val[1524] = 1.231282; bs_val[1525] = 1.231293; bs_val[1526] = 1.231304; bs_val[1527] = 1.231315; bs_val[1528] = 1.231326; bs_val[1529] = 1.231337; 
bs_val[1530] = 1.231348; bs_val[1531] = 1.231359; bs_val[1532] = 1.231370; bs_val[1533] = 1.231381; bs_val[1534] = 1.231392; bs_val[1535] = 1.231403; bs_val[1536] = 1.231414; bs_val[1537] = 1.231425; bs_val[1538] = 1.231436; bs_val[1539] = 1.231447; 
bs_val[1540] = 1.231458; bs_val[1541] = 1.231469; bs_val[1542] = 1.231479; bs_val[1543] = 1.231490; bs_val[1544] = 1.231501; bs_val[1545] = 1.231512; bs_val[1546] = 1.231523; bs_val[1547] = 1.231534; bs_val[1548] = 1.231545; bs_val[1549] = 1.231556; 
bs_val[1550] = 1.231567; bs_val[1551] = 1.231578; bs_val[1552] = 1.231589; bs_val[1553] = 1.231600; bs_val[1554] = 1.231611; bs_val[1555] = 1.231622; bs_val[1556] = 1.231633; bs_val[1557] = 1.231644; bs_val[1558] = 1.231655; bs_val[1559] = 1.231666; 
bs_val[1560] = 1.231677; bs_val[1561] = 1.231688; bs_val[1562] = 1.231699; bs_val[1563] = 1.231710; bs_val[1564] = 1.231721; bs_val[1565] = 1.231732; bs_val[1566] = 1.231743; bs_val[1567] = 1.231754; bs_val[1568] = 1.231765; bs_val[1569] = 1.231776; 
bs_val[1570] = 1.231787; bs_val[1571] = 1.231798; bs_val[1572] = 1.231809; bs_val[1573] = 1.231820; bs_val[1574] = 1.231831; bs_val[1575] = 1.231842; bs_val[1576] = 1.231853; bs_val[1577] = 1.231863; bs_val[1578] = 1.231874; bs_val[1579] = 1.231885; 
bs_val[1580] = 1.231896; bs_val[1581] = 1.231907; bs_val[1582] = 1.231918; bs_val[1583] = 1.231929; bs_val[1584] = 1.231940; bs_val[1585] = 1.231951; bs_val[1586] = 1.231962; bs_val[1587] = 1.231973; bs_val[1588] = 1.231984; bs_val[1589] = 1.231995; 
bs_val[1590] = 1.232006; bs_val[1591] = 1.232017; bs_val[1592] = 1.232028; bs_val[1593] = 1.232039; bs_val[1594] = 1.232050; bs_val[1595] = 1.232061; bs_val[1596] = 1.232072; bs_val[1597] = 1.232083; bs_val[1598] = 1.232094; bs_val[1599] = 1.232105; 
bs_val[1600] = 1.232116; bs_val[1601] = 1.232127; bs_val[1602] = 1.232138; bs_val[1603] = 1.232149; bs_val[1604] = 1.232160; bs_val[1605] = 1.232171; bs_val[1606] = 1.232182; bs_val[1607] = 1.232193; bs_val[1608] = 1.232204; bs_val[1609] = 1.232215; 
bs_val[1610] = 1.232226; bs_val[1611] = 1.232237; bs_val[1612] = 1.232248; bs_val[1613] = 1.232259; bs_val[1614] = 1.232270; bs_val[1615] = 1.232281; bs_val[1616] = 1.232292; bs_val[1617] = 1.232303; bs_val[1618] = 1.232314; bs_val[1619] = 1.232325; 
bs_val[1620] = 1.232336; bs_val[1621] = 1.232347; bs_val[1622] = 1.232358; bs_val[1623] = 1.232369; bs_val[1624] = 1.232380; bs_val[1625] = 1.232391; bs_val[1626] = 1.232402; bs_val[1627] = 1.232413; bs_val[1628] = 1.232424; bs_val[1629] = 1.232435; 
bs_val[1630] = 1.232446; bs_val[1631] = 1.232457; bs_val[1632] = 1.232468; bs_val[1633] = 1.232479; bs_val[1634] = 1.232490; bs_val[1635] = 1.232501; bs_val[1636] = 1.232512; bs_val[1637] = 1.232523; bs_val[1638] = 1.232534; bs_val[1639] = 1.232545; 
bs_val[1640] = 1.232556; bs_val[1641] = 1.232567; bs_val[1642] = 1.232578; bs_val[1643] = 1.232589; bs_val[1644] = 1.232600; bs_val[1645] = 1.232611; bs_val[1646] = 1.232622; bs_val[1647] = 1.232633; bs_val[1648] = 1.232644; bs_val[1649] = 1.232655; 
bs_val[1650] = 1.232666; bs_val[1651] = 1.232677; bs_val[1652] = 1.232688; bs_val[1653] = 1.232699; bs_val[1654] = 1.232710; bs_val[1655] = 1.232721; bs_val[1656] = 1.232732; bs_val[1657] = 1.232743; bs_val[1658] = 1.232754; bs_val[1659] = 1.232765; 
bs_val[1660] = 1.232776; bs_val[1661] = 1.232787; bs_val[1662] = 1.232798; bs_val[1663] = 1.232809; bs_val[1664] = 1.232820; bs_val[1665] = 1.232831; bs_val[1666] = 1.232842; bs_val[1667] = 1.232853; bs_val[1668] = 1.232864; bs_val[1669] = 1.232875; 
bs_val[1670] = 1.232886; bs_val[1671] = 1.232897; bs_val[1672] = 1.232908; bs_val[1673] = 1.232919; bs_val[1674] = 1.232930; bs_val[1675] = 1.232941; bs_val[1676] = 1.232952; bs_val[1677] = 1.232963; bs_val[1678] = 1.232974; bs_val[1679] = 1.232985; 
bs_val[1680] = 1.232996; bs_val[1681] = 1.233007; bs_val[1682] = 1.233018; bs_val[1683] = 1.233029; bs_val[1684] = 1.233040; bs_val[1685] = 1.233051; bs_val[1686] = 1.233062; bs_val[1687] = 1.233073; bs_val[1688] = 1.233084; bs_val[1689] = 1.233095; 
bs_val[1690] = 1.233106; bs_val[1691] = 1.233117; bs_val[1692] = 1.233128; bs_val[1693] = 1.233139; bs_val[1694] = 1.233151; bs_val[1695] = 1.233162; bs_val[1696] = 1.233173; bs_val[1697] = 1.233184; bs_val[1698] = 1.233195; bs_val[1699] = 1.233206; 
bs_val[1700] = 1.233217; bs_val[1701] = 1.233228; bs_val[1702] = 1.233239; bs_val[1703] = 1.233250; bs_val[1704] = 1.233261; bs_val[1705] = 1.233272; bs_val[1706] = 1.233283; bs_val[1707] = 1.233294; bs_val[1708] = 1.233305; bs_val[1709] = 1.233316; 
bs_val[1710] = 1.233327; bs_val[1711] = 1.233338; bs_val[1712] = 1.233349; bs_val[1713] = 1.233360; bs_val[1714] = 1.233371; bs_val[1715] = 1.233382; bs_val[1716] = 1.233393; bs_val[1717] = 1.233404; bs_val[1718] = 1.233415; bs_val[1719] = 1.233426; 
bs_val[1720] = 1.233437; bs_val[1721] = 1.233448; bs_val[1722] = 1.233459; bs_val[1723] = 1.233470; bs_val[1724] = 1.233481; bs_val[1725] = 1.233492; bs_val[1726] = 1.233503; bs_val[1727] = 1.233514; bs_val[1728] = 1.233526; bs_val[1729] = 1.233537; 
bs_val[1730] = 1.233548; bs_val[1731] = 1.233559; bs_val[1732] = 1.233570; bs_val[1733] = 1.233581; bs_val[1734] = 1.233592; bs_val[1735] = 1.233603; bs_val[1736] = 1.233614; bs_val[1737] = 1.233625; bs_val[1738] = 1.233636; bs_val[1739] = 1.233647; 
bs_val[1740] = 1.233658; bs_val[1741] = 1.233669; bs_val[1742] = 1.233680; bs_val[1743] = 1.233691; bs_val[1744] = 1.233702; bs_val[1745] = 1.233713; bs_val[1746] = 1.233724; bs_val[1747] = 1.233735; bs_val[1748] = 1.233746; bs_val[1749] = 1.233757; 
bs_val[1750] = 1.233768; bs_val[1751] = 1.233779; bs_val[1752] = 1.233790; bs_val[1753] = 1.233802; bs_val[1754] = 1.233813; bs_val[1755] = 1.233824; bs_val[1756] = 1.233835; bs_val[1757] = 1.233846; bs_val[1758] = 1.233857; bs_val[1759] = 1.233868; 
bs_val[1760] = 1.233879; bs_val[1761] = 1.233890; bs_val[1762] = 1.233901; bs_val[1763] = 1.233912; bs_val[1764] = 1.233923; bs_val[1765] = 1.233934; bs_val[1766] = 1.233945; bs_val[1767] = 1.233956; bs_val[1768] = 1.233967; bs_val[1769] = 1.233978; 
bs_val[1770] = 1.233989; bs_val[1771] = 1.234000; bs_val[1772] = 1.234011; bs_val[1773] = 1.234023; bs_val[1774] = 1.234034; bs_val[1775] = 1.234045; bs_val[1776] = 1.234056; bs_val[1777] = 1.234067; bs_val[1778] = 1.234078; bs_val[1779] = 1.234089; 
bs_val[1780] = 1.234100; bs_val[1781] = 1.234111; bs_val[1782] = 1.234122; bs_val[1783] = 1.234133; bs_val[1784] = 1.234144; bs_val[1785] = 1.234155; bs_val[1786] = 1.234166; bs_val[1787] = 1.234177; bs_val[1788] = 1.234188; bs_val[1789] = 1.234199; 
bs_val[1790] = 1.234210; bs_val[1791] = 1.234222; bs_val[1792] = 1.234233; bs_val[1793] = 1.234244; bs_val[1794] = 1.234255; bs_val[1795] = 1.234266; bs_val[1796] = 1.234277; bs_val[1797] = 1.234288; bs_val[1798] = 1.234299; bs_val[1799] = 1.234310; 
bs_val[1800] = 1.234321; bs_val[1801] = 1.234332; bs_val[1802] = 1.234343; bs_val[1803] = 1.234354; bs_val[1804] = 1.234365; bs_val[1805] = 1.234376; bs_val[1806] = 1.234387; bs_val[1807] = 1.234399; bs_val[1808] = 1.234410; bs_val[1809] = 1.234421; 
bs_val[1810] = 1.234432; bs_val[1811] = 1.234443; bs_val[1812] = 1.234454; bs_val[1813] = 1.234465; bs_val[1814] = 1.234476; bs_val[1815] = 1.234487; bs_val[1816] = 1.234498; bs_val[1817] = 1.234509; bs_val[1818] = 1.234520; bs_val[1819] = 1.234531; 
bs_val[1820] = 1.234542; bs_val[1821] = 1.234554; bs_val[1822] = 1.234565; bs_val[1823] = 1.234576; bs_val[1824] = 1.234587; bs_val[1825] = 1.234598; bs_val[1826] = 1.234609; bs_val[1827] = 1.234620; bs_val[1828] = 1.234631; bs_val[1829] = 1.234642; 
bs_val[1830] = 1.234653; bs_val[1831] = 1.234664; bs_val[1832] = 1.234675; bs_val[1833] = 1.234686; bs_val[1834] = 1.234698; bs_val[1835] = 1.234709; bs_val[1836] = 1.234720; bs_val[1837] = 1.234731; bs_val[1838] = 1.234742; bs_val[1839] = 1.234753; 
bs_val[1840] = 1.234764; bs_val[1841] = 1.234775; bs_val[1842] = 1.234786; bs_val[1843] = 1.234797; bs_val[1844] = 1.234808; bs_val[1845] = 1.234819; bs_val[1846] = 1.234830; bs_val[1847] = 1.234842; bs_val[1848] = 1.234853; bs_val[1849] = 1.234864; 
bs_val[1850] = 1.234875; bs_val[1851] = 1.234886; bs_val[1852] = 1.234897; bs_val[1853] = 1.234908; bs_val[1854] = 1.234919; bs_val[1855] = 1.234930; bs_val[1856] = 1.234941; bs_val[1857] = 1.234952; bs_val[1858] = 1.234963; bs_val[1859] = 1.234975; 
bs_val[1860] = 1.234986; bs_val[1861] = 1.234997; bs_val[1862] = 1.235008; bs_val[1863] = 1.235019; bs_val[1864] = 1.235030; bs_val[1865] = 1.235041; bs_val[1866] = 1.235052; bs_val[1867] = 1.235063; bs_val[1868] = 1.235074; bs_val[1869] = 1.235085; 
bs_val[1870] = 1.235097; bs_val[1871] = 1.235108; bs_val[1872] = 1.235119; bs_val[1873] = 1.235130; bs_val[1874] = 1.235141; bs_val[1875] = 1.235152; bs_val[1876] = 1.235163; bs_val[1877] = 1.235174; bs_val[1878] = 1.235185; bs_val[1879] = 1.235196; 
bs_val[1880] = 1.235207; bs_val[1881] = 1.235219; bs_val[1882] = 1.235230; bs_val[1883] = 1.235241; bs_val[1884] = 1.235252; bs_val[1885] = 1.235263; bs_val[1886] = 1.235274; bs_val[1887] = 1.235285; bs_val[1888] = 1.235296; bs_val[1889] = 1.235307; 
bs_val[1890] = 1.235318; bs_val[1891] = 1.235330; bs_val[1892] = 1.235341; bs_val[1893] = 1.235352; bs_val[1894] = 1.235363; bs_val[1895] = 1.235374; bs_val[1896] = 1.235385; bs_val[1897] = 1.235396; bs_val[1898] = 1.235407; bs_val[1899] = 1.235418; 
bs_val[1900] = 1.235429; bs_val[1901] = 1.235441; bs_val[1902] = 1.235452; bs_val[1903] = 1.235463; bs_val[1904] = 1.235474; bs_val[1905] = 1.235485; bs_val[1906] = 1.235496; bs_val[1907] = 1.235507; bs_val[1908] = 1.235518; bs_val[1909] = 1.235529; 
bs_val[1910] = 1.235541; bs_val[1911] = 1.235552; bs_val[1912] = 1.235563; bs_val[1913] = 1.235574; bs_val[1914] = 1.235585; bs_val[1915] = 1.235596; bs_val[1916] = 1.235607; bs_val[1917] = 1.235618; bs_val[1918] = 1.235629; bs_val[1919] = 1.235640; 
bs_val[1920] = 1.235652; bs_val[1921] = 1.235663; bs_val[1922] = 1.235674; bs_val[1923] = 1.235685; bs_val[1924] = 1.235696; bs_val[1925] = 1.235707; bs_val[1926] = 1.235718; bs_val[1927] = 1.235729; bs_val[1928] = 1.235740; bs_val[1929] = 1.235752; 
bs_val[1930] = 1.235763; bs_val[1931] = 1.235774; bs_val[1932] = 1.235785; bs_val[1933] = 1.235796; bs_val[1934] = 1.235807; bs_val[1935] = 1.235818; bs_val[1936] = 1.235829; bs_val[1937] = 1.235841; bs_val[1938] = 1.235852; bs_val[1939] = 1.235863; 
bs_val[1940] = 1.235874; bs_val[1941] = 1.235885; bs_val[1942] = 1.235896; bs_val[1943] = 1.235907; bs_val[1944] = 1.235918; bs_val[1945] = 1.235929; bs_val[1946] = 1.235941; bs_val[1947] = 1.235952; bs_val[1948] = 1.235963; bs_val[1949] = 1.235974; 
bs_val[1950] = 1.235985; bs_val[1951] = 1.235996; bs_val[1952] = 1.236007; bs_val[1953] = 1.236018; bs_val[1954] = 1.236030; bs_val[1955] = 1.236041; bs_val[1956] = 1.236052; bs_val[1957] = 1.236063; bs_val[1958] = 1.236074; bs_val[1959] = 1.236085; 
bs_val[1960] = 1.236096; bs_val[1961] = 1.236107; bs_val[1962] = 1.236119; bs_val[1963] = 1.236130; bs_val[1964] = 1.236141; bs_val[1965] = 1.236152; bs_val[1966] = 1.236163; bs_val[1967] = 1.236174; bs_val[1968] = 1.236185; bs_val[1969] = 1.236197; 
bs_val[1970] = 1.236208; bs_val[1971] = 1.236219; bs_val[1972] = 1.236230; bs_val[1973] = 1.236241; bs_val[1974] = 1.236252; bs_val[1975] = 1.236263; bs_val[1976] = 1.236274; bs_val[1977] = 1.236286; bs_val[1978] = 1.236297; bs_val[1979] = 1.236308; 
bs_val[1980] = 1.236319; bs_val[1981] = 1.236330; bs_val[1982] = 1.236341; bs_val[1983] = 1.236352; bs_val[1984] = 1.236364; bs_val[1985] = 1.236375; bs_val[1986] = 1.236386; bs_val[1987] = 1.236397; bs_val[1988] = 1.236408; bs_val[1989] = 1.236419; 
bs_val[1990] = 1.236430; bs_val[1991] = 1.236441; bs_val[1992] = 1.236453; bs_val[1993] = 1.236464; bs_val[1994] = 1.236475; bs_val[1995] = 1.236486; bs_val[1996] = 1.236497; bs_val[1997] = 1.236508; bs_val[1998] = 1.236519; bs_val[1999] = 1.236531; 
bs_val[2000] = 1.236542; bs_val[2001] = 1.236553; bs_val[2002] = 1.236564; bs_val[2003] = 1.236575; bs_val[2004] = 1.236586; bs_val[2005] = 1.236597; bs_val[2006] = 1.236609; bs_val[2007] = 1.236620; bs_val[2008] = 1.236631; bs_val[2009] = 1.236642; 
bs_val[2010] = 1.236653; bs_val[2011] = 1.236664; bs_val[2012] = 1.236675; bs_val[2013] = 1.236687; bs_val[2014] = 1.236698; bs_val[2015] = 1.236709; bs_val[2016] = 1.236720; bs_val[2017] = 1.236731; bs_val[2018] = 1.236742; bs_val[2019] = 1.236754; 
bs_val[2020] = 1.236765; bs_val[2021] = 1.236776; bs_val[2022] = 1.236787; bs_val[2023] = 1.236798; bs_val[2024] = 1.236809; bs_val[2025] = 1.236820; bs_val[2026] = 1.236832; bs_val[2027] = 1.236843; bs_val[2028] = 1.236854; bs_val[2029] = 1.236865; 
bs_val[2030] = 1.236876; bs_val[2031] = 1.236887; bs_val[2032] = 1.236898; bs_val[2033] = 1.236910; bs_val[2034] = 1.236921; bs_val[2035] = 1.236932; bs_val[2036] = 1.236943; bs_val[2037] = 1.236954; bs_val[2038] = 1.236965; bs_val[2039] = 1.236977; 
bs_val[2040] = 1.236988; bs_val[2041] = 1.236999; bs_val[2042] = 1.237010; bs_val[2043] = 1.237021; bs_val[2044] = 1.237032; bs_val[2045] = 1.237044; bs_val[2046] = 1.237055; bs_val[2047] = 1.237066; bs_val[2048] = 1.237077; bs_val[2049] = 1.237088; 
bs_val[2050] = 1.237099; bs_val[2051] = 1.237111; bs_val[2052] = 1.237122; bs_val[2053] = 1.237133; bs_val[2054] = 1.237144; bs_val[2055] = 1.237155; bs_val[2056] = 1.237166; bs_val[2057] = 1.237178; bs_val[2058] = 1.237189; bs_val[2059] = 1.237200; 
bs_val[2060] = 1.237211; bs_val[2061] = 1.237222; bs_val[2062] = 1.237233; bs_val[2063] = 1.237245; bs_val[2064] = 1.237256; bs_val[2065] = 1.237267; bs_val[2066] = 1.237278; bs_val[2067] = 1.237289; bs_val[2068] = 1.237300; bs_val[2069] = 1.237312; 
bs_val[2070] = 1.237323; bs_val[2071] = 1.237334; bs_val[2072] = 1.237345; bs_val[2073] = 1.237356; bs_val[2074] = 1.237367; bs_val[2075] = 1.237379; bs_val[2076] = 1.237390; bs_val[2077] = 1.237401; bs_val[2078] = 1.237412; bs_val[2079] = 1.237423; 
bs_val[2080] = 1.237434; bs_val[2081] = 1.237446; bs_val[2082] = 1.237457; bs_val[2083] = 1.237468; bs_val[2084] = 1.237479; bs_val[2085] = 1.237490; bs_val[2086] = 1.237501; bs_val[2087] = 1.237513; bs_val[2088] = 1.237524; bs_val[2089] = 1.237535; 
bs_val[2090] = 1.237546; bs_val[2091] = 1.237557; bs_val[2092] = 1.237569; bs_val[2093] = 1.237580; bs_val[2094] = 1.237591; bs_val[2095] = 1.237602; bs_val[2096] = 1.237613; bs_val[2097] = 1.237624; bs_val[2098] = 1.237636; bs_val[2099] = 1.237647; 
bs_val[2100] = 1.237658; bs_val[2101] = 1.237669; bs_val[2102] = 1.237680; bs_val[2103] = 1.237692; bs_val[2104] = 1.237703; bs_val[2105] = 1.237714; bs_val[2106] = 1.237725; bs_val[2107] = 1.237736; bs_val[2108] = 1.237747; bs_val[2109] = 1.237759; 
bs_val[2110] = 1.237770; bs_val[2111] = 1.237781; bs_val[2112] = 1.237792; bs_val[2113] = 1.237803; bs_val[2114] = 1.237815; bs_val[2115] = 1.237826; bs_val[2116] = 1.237837; bs_val[2117] = 1.237848; bs_val[2118] = 1.237859; bs_val[2119] = 1.237871; 
bs_val[2120] = 1.237882; bs_val[2121] = 1.237893; bs_val[2122] = 1.237904; bs_val[2123] = 1.237915; bs_val[2124] = 1.237926; bs_val[2125] = 1.237938; bs_val[2126] = 1.237949; bs_val[2127] = 1.237960; bs_val[2128] = 1.237971; bs_val[2129] = 1.237982; 
bs_val[2130] = 1.237994; bs_val[2131] = 1.238005; bs_val[2132] = 1.238016; bs_val[2133] = 1.238027; bs_val[2134] = 1.238038; bs_val[2135] = 1.238050; bs_val[2136] = 1.238061; bs_val[2137] = 1.238072; bs_val[2138] = 1.238083; bs_val[2139] = 1.238094; 
bs_val[2140] = 1.238106; bs_val[2141] = 1.238117; bs_val[2142] = 1.238128; bs_val[2143] = 1.238139; bs_val[2144] = 1.238150; bs_val[2145] = 1.238162; bs_val[2146] = 1.238173; bs_val[2147] = 1.238184; bs_val[2148] = 1.238195; bs_val[2149] = 1.238206; 
bs_val[2150] = 1.238218; bs_val[2151] = 1.238229; bs_val[2152] = 1.238240; bs_val[2153] = 1.238251; bs_val[2154] = 1.238262; bs_val[2155] = 1.238274; bs_val[2156] = 1.238285; bs_val[2157] = 1.238296; bs_val[2158] = 1.238307; bs_val[2159] = 1.238318; 
bs_val[2160] = 1.238330; bs_val[2161] = 1.238341; bs_val[2162] = 1.238352; bs_val[2163] = 1.238363; bs_val[2164] = 1.238374; bs_val[2165] = 1.238386; bs_val[2166] = 1.238397; bs_val[2167] = 1.238408; bs_val[2168] = 1.238419; bs_val[2169] = 1.238431; 
bs_val[2170] = 1.238442; bs_val[2171] = 1.238453; bs_val[2172] = 1.238464; bs_val[2173] = 1.238475; bs_val[2174] = 1.238487; bs_val[2175] = 1.238498; bs_val[2176] = 1.238509; bs_val[2177] = 1.238520; bs_val[2178] = 1.238531; bs_val[2179] = 1.238543; 
bs_val[2180] = 1.238554; bs_val[2181] = 1.238565; bs_val[2182] = 1.238576; bs_val[2183] = 1.238587; bs_val[2184] = 1.238599; bs_val[2185] = 1.238610; bs_val[2186] = 1.238621; bs_val[2187] = 1.238632; bs_val[2188] = 1.238644; bs_val[2189] = 1.238655; 
bs_val[2190] = 1.238666; bs_val[2191] = 1.238677; bs_val[2192] = 1.238688; bs_val[2193] = 1.238700; bs_val[2194] = 1.238711; bs_val[2195] = 1.238722; bs_val[2196] = 1.238733; bs_val[2197] = 1.238745; bs_val[2198] = 1.238756; bs_val[2199] = 1.238767; 
bs_val[2200] = 1.238778; bs_val[2201] = 1.238789; bs_val[2202] = 1.238801; bs_val[2203] = 1.238812; bs_val[2204] = 1.238823; bs_val[2205] = 1.238834; bs_val[2206] = 1.238846; bs_val[2207] = 1.238857; bs_val[2208] = 1.238868; bs_val[2209] = 1.238879; 
bs_val[2210] = 1.238890; bs_val[2211] = 1.238902; bs_val[2212] = 1.238913; bs_val[2213] = 1.238924; bs_val[2214] = 1.238935; bs_val[2215] = 1.238947; bs_val[2216] = 1.238958; bs_val[2217] = 1.238969; bs_val[2218] = 1.238980; bs_val[2219] = 1.238992; 
bs_val[2220] = 1.239003; bs_val[2221] = 1.239014; bs_val[2222] = 1.239025; bs_val[2223] = 1.239036; bs_val[2224] = 1.239048; bs_val[2225] = 1.239059; bs_val[2226] = 1.239070; bs_val[2227] = 1.239081; bs_val[2228] = 1.239093; bs_val[2229] = 1.239104; 
bs_val[2230] = 1.239115; bs_val[2231] = 1.239126; bs_val[2232] = 1.239138; bs_val[2233] = 1.239149; bs_val[2234] = 1.239160; bs_val[2235] = 1.239171; bs_val[2236] = 1.239182; bs_val[2237] = 1.239194; bs_val[2238] = 1.239205; bs_val[2239] = 1.239216; 
bs_val[2240] = 1.239227; bs_val[2241] = 1.239239; bs_val[2242] = 1.239250; bs_val[2243] = 1.239261; bs_val[2244] = 1.239272; bs_val[2245] = 1.239284; bs_val[2246] = 1.239295; bs_val[2247] = 1.239306; bs_val[2248] = 1.239317; bs_val[2249] = 1.239329; 
bs_val[2250] = 1.239340; bs_val[2251] = 1.239351; bs_val[2252] = 1.239362; bs_val[2253] = 1.239374; bs_val[2254] = 1.239385; bs_val[2255] = 1.239396; bs_val[2256] = 1.239407; bs_val[2257] = 1.239419; bs_val[2258] = 1.239430; bs_val[2259] = 1.239441; 
bs_val[2260] = 1.239452; bs_val[2261] = 1.239464; bs_val[2262] = 1.239475; bs_val[2263] = 1.239486; bs_val[2264] = 1.239497; bs_val[2265] = 1.239509; bs_val[2266] = 1.239520; bs_val[2267] = 1.239531; bs_val[2268] = 1.239542; bs_val[2269] = 1.239554; 
bs_val[2270] = 1.239565; bs_val[2271] = 1.239576; bs_val[2272] = 1.239587; bs_val[2273] = 1.239599; bs_val[2274] = 1.239610; bs_val[2275] = 1.239621; bs_val[2276] = 1.239632; bs_val[2277] = 1.239644; bs_val[2278] = 1.239655; bs_val[2279] = 1.239666; 
bs_val[2280] = 1.239677; bs_val[2281] = 1.239689; bs_val[2282] = 1.239700; bs_val[2283] = 1.239711; bs_val[2284] = 1.239722; bs_val[2285] = 1.239734; bs_val[2286] = 1.239745; bs_val[2287] = 1.239756; bs_val[2288] = 1.239767; bs_val[2289] = 1.239779; 
bs_val[2290] = 1.239790; bs_val[2291] = 1.239801; bs_val[2292] = 1.239812; bs_val[2293] = 1.239824; bs_val[2294] = 1.239835; bs_val[2295] = 1.239846; bs_val[2296] = 1.239857; bs_val[2297] = 1.239869; bs_val[2298] = 1.239880; bs_val[2299] = 1.239891; 
bs_val[2300] = 1.239902; bs_val[2301] = 1.239914; bs_val[2302] = 1.239925; bs_val[2303] = 1.239936; bs_val[2304] = 1.239948; bs_val[2305] = 1.239959; bs_val[2306] = 1.239970; bs_val[2307] = 1.239981; bs_val[2308] = 1.239993; bs_val[2309] = 1.240004; 
bs_val[2310] = 1.240015; bs_val[2311] = 1.240026; bs_val[2312] = 1.240038; bs_val[2313] = 1.240049; bs_val[2314] = 1.240060; bs_val[2315] = 1.240071; bs_val[2316] = 1.240083; bs_val[2317] = 1.240094; bs_val[2318] = 1.240105; bs_val[2319] = 1.240117; 
bs_val[2320] = 1.240128; bs_val[2321] = 1.240139; bs_val[2322] = 1.240150; bs_val[2323] = 1.240162; bs_val[2324] = 1.240173; bs_val[2325] = 1.240184; bs_val[2326] = 1.240195; bs_val[2327] = 1.240207; bs_val[2328] = 1.240218; bs_val[2329] = 1.240229; 
bs_val[2330] = 1.240241; bs_val[2331] = 1.240252; bs_val[2332] = 1.240263; bs_val[2333] = 1.240274; bs_val[2334] = 1.240286; bs_val[2335] = 1.240297; bs_val[2336] = 1.240308; bs_val[2337] = 1.240319; bs_val[2338] = 1.240331; bs_val[2339] = 1.240342; 
bs_val[2340] = 1.240353; bs_val[2341] = 1.240365; bs_val[2342] = 1.240376; bs_val[2343] = 1.240387; bs_val[2344] = 1.240398; bs_val[2345] = 1.240410; bs_val[2346] = 1.240421; bs_val[2347] = 1.240432; bs_val[2348] = 1.240444; bs_val[2349] = 1.240455; 
bs_val[2350] = 1.240466; bs_val[2351] = 1.240477; bs_val[2352] = 1.240489; bs_val[2353] = 1.240500; bs_val[2354] = 1.240511; bs_val[2355] = 1.240523; bs_val[2356] = 1.240534; bs_val[2357] = 1.240545; bs_val[2358] = 1.240556; bs_val[2359] = 1.240568; 
bs_val[2360] = 1.240579; bs_val[2361] = 1.240590; bs_val[2362] = 1.240602; bs_val[2363] = 1.240613; bs_val[2364] = 1.240624; bs_val[2365] = 1.240635; bs_val[2366] = 1.240647; bs_val[2367] = 1.240658; bs_val[2368] = 1.240669; bs_val[2369] = 1.240681; 
bs_val[2370] = 1.240692; bs_val[2371] = 1.240703; bs_val[2372] = 1.240714; bs_val[2373] = 1.240726; bs_val[2374] = 1.240737; bs_val[2375] = 1.240748; bs_val[2376] = 1.240760; bs_val[2377] = 1.240771; bs_val[2378] = 1.240782; bs_val[2379] = 1.240794; 
bs_val[2380] = 1.240805; bs_val[2381] = 1.240816; bs_val[2382] = 1.240827; bs_val[2383] = 1.240839; bs_val[2384] = 1.240850; bs_val[2385] = 1.240861; bs_val[2386] = 1.240873; bs_val[2387] = 1.240884; bs_val[2388] = 1.240895; bs_val[2389] = 1.240907; 
bs_val[2390] = 1.240918; bs_val[2391] = 1.240929; bs_val[2392] = 1.240940; bs_val[2393] = 1.240952; bs_val[2394] = 1.240963; bs_val[2395] = 1.240974; bs_val[2396] = 1.240986; bs_val[2397] = 1.240997; bs_val[2398] = 1.241008; bs_val[2399] = 1.241020; 
bs_val[2400] = 1.241031; bs_val[2401] = 1.241042; bs_val[2402] = 1.241053; bs_val[2403] = 1.241065; bs_val[2404] = 1.241076; bs_val[2405] = 1.241087; bs_val[2406] = 1.241099; bs_val[2407] = 1.241110; bs_val[2408] = 1.241121; bs_val[2409] = 1.241133; 
bs_val[2410] = 1.241144; bs_val[2411] = 1.241155; bs_val[2412] = 1.241167; bs_val[2413] = 1.241178; bs_val[2414] = 1.241189; bs_val[2415] = 1.241200; bs_val[2416] = 1.241212; bs_val[2417] = 1.241223; bs_val[2418] = 1.241234; bs_val[2419] = 1.241246; 
bs_val[2420] = 1.241257; bs_val[2421] = 1.241268; bs_val[2422] = 1.241280; bs_val[2423] = 1.241291; bs_val[2424] = 1.241302; bs_val[2425] = 1.241314; bs_val[2426] = 1.241325; bs_val[2427] = 1.241336; bs_val[2428] = 1.241348; bs_val[2429] = 1.241359; 
bs_val[2430] = 1.241370; bs_val[2431] = 1.241381; bs_val[2432] = 1.241393; bs_val[2433] = 1.241404; bs_val[2434] = 1.241415; bs_val[2435] = 1.241427; bs_val[2436] = 1.241438; bs_val[2437] = 1.241449; bs_val[2438] = 1.241461; bs_val[2439] = 1.241472; 
bs_val[2440] = 1.241483; bs_val[2441] = 1.241495; bs_val[2442] = 1.241506; bs_val[2443] = 1.241517; bs_val[2444] = 1.241529; bs_val[2445] = 1.241540; bs_val[2446] = 1.241551; bs_val[2447] = 1.241563; bs_val[2448] = 1.241574; bs_val[2449] = 1.241585; 
bs_val[2450] = 1.241597; bs_val[2451] = 1.241608; bs_val[2452] = 1.241619; bs_val[2453] = 1.241631; bs_val[2454] = 1.241642; bs_val[2455] = 1.241653; bs_val[2456] = 1.241664; bs_val[2457] = 1.241676; bs_val[2458] = 1.241687; bs_val[2459] = 1.241698; 
bs_val[2460] = 1.241710; bs_val[2461] = 1.241721; bs_val[2462] = 1.241732; bs_val[2463] = 1.241744; bs_val[2464] = 1.241755; bs_val[2465] = 1.241766; bs_val[2466] = 1.241778; bs_val[2467] = 1.241789; bs_val[2468] = 1.241800; bs_val[2469] = 1.241812; 
bs_val[2470] = 1.241823; bs_val[2471] = 1.241834; bs_val[2472] = 1.241846; bs_val[2473] = 1.241857; bs_val[2474] = 1.241868; bs_val[2475] = 1.241880; bs_val[2476] = 1.241891; bs_val[2477] = 1.241902; bs_val[2478] = 1.241914; bs_val[2479] = 1.241925; 
bs_val[2480] = 1.241936; bs_val[2481] = 1.241948; bs_val[2482] = 1.241959; bs_val[2483] = 1.241970; bs_val[2484] = 1.241982; bs_val[2485] = 1.241993; bs_val[2486] = 1.242004; bs_val[2487] = 1.242016; bs_val[2488] = 1.242027; bs_val[2489] = 1.242039; 
bs_val[2490] = 1.242050; bs_val[2491] = 1.242061; bs_val[2492] = 1.242073; bs_val[2493] = 1.242084; bs_val[2494] = 1.242095; bs_val[2495] = 1.242107; bs_val[2496] = 1.242118; bs_val[2497] = 1.242129; bs_val[2498] = 1.242141; bs_val[2499] = 1.242152; 
bs_val[2500] = 1.242163; bs_val[2501] = 1.242175; bs_val[2502] = 1.242186; bs_val[2503] = 1.242197; bs_val[2504] = 1.242209; bs_val[2505] = 1.242220; bs_val[2506] = 1.242231; bs_val[2507] = 1.242243; bs_val[2508] = 1.242254; bs_val[2509] = 1.242265; 
bs_val[2510] = 1.242277; bs_val[2511] = 1.242288; bs_val[2512] = 1.242299; bs_val[2513] = 1.242311; bs_val[2514] = 1.242322; bs_val[2515] = 1.242334; bs_val[2516] = 1.242345; bs_val[2517] = 1.242356; bs_val[2518] = 1.242368; bs_val[2519] = 1.242379; 
bs_val[2520] = 1.242390; bs_val[2521] = 1.242402; bs_val[2522] = 1.242413; bs_val[2523] = 1.242424; bs_val[2524] = 1.242436; bs_val[2525] = 1.242447; bs_val[2526] = 1.242458; bs_val[2527] = 1.242470; bs_val[2528] = 1.242481; bs_val[2529] = 1.242492; 
bs_val[2530] = 1.242504; bs_val[2531] = 1.242515; bs_val[2532] = 1.242527; bs_val[2533] = 1.242538; bs_val[2534] = 1.242549; bs_val[2535] = 1.242561; bs_val[2536] = 1.242572; bs_val[2537] = 1.242583; bs_val[2538] = 1.242595; bs_val[2539] = 1.242606; 
bs_val[2540] = 1.242617; bs_val[2541] = 1.242629; bs_val[2542] = 1.242640; bs_val[2543] = 1.242652; bs_val[2544] = 1.242663; bs_val[2545] = 1.242674; bs_val[2546] = 1.242686; bs_val[2547] = 1.242697; bs_val[2548] = 1.242708; bs_val[2549] = 1.242720; 
bs_val[2550] = 1.242731; bs_val[2551] = 1.242742; bs_val[2552] = 1.242754; bs_val[2553] = 1.242765; bs_val[2554] = 1.242777; bs_val[2555] = 1.242788; bs_val[2556] = 1.242799; bs_val[2557] = 1.242811; bs_val[2558] = 1.242822; bs_val[2559] = 1.242833; 
bs_val[2560] = 1.242845; bs_val[2561] = 1.242856; bs_val[2562] = 1.242867; bs_val[2563] = 1.242879; bs_val[2564] = 1.242890; bs_val[2565] = 1.242902; bs_val[2566] = 1.242913; bs_val[2567] = 1.242924; bs_val[2568] = 1.242936; bs_val[2569] = 1.242947; 
bs_val[2570] = 1.242958; bs_val[2571] = 1.242970; bs_val[2572] = 1.242981; bs_val[2573] = 1.242993; bs_val[2574] = 1.243004; bs_val[2575] = 1.243015; bs_val[2576] = 1.243027; bs_val[2577] = 1.243038; bs_val[2578] = 1.243049; bs_val[2579] = 1.243061; 
bs_val[2580] = 1.243072; bs_val[2581] = 1.243084; bs_val[2582] = 1.243095; bs_val[2583] = 1.243106; bs_val[2584] = 1.243118; bs_val[2585] = 1.243129; bs_val[2586] = 1.243141; bs_val[2587] = 1.243152; bs_val[2588] = 1.243163; bs_val[2589] = 1.243175; 
bs_val[2590] = 1.243186; bs_val[2591] = 1.243197; bs_val[2592] = 1.243209; bs_val[2593] = 1.243220; bs_val[2594] = 1.243232; bs_val[2595] = 1.243243; bs_val[2596] = 1.243254; bs_val[2597] = 1.243266; bs_val[2598] = 1.243277; bs_val[2599] = 1.243288; 
bs_val[2600] = 1.243300; bs_val[2601] = 1.243311; bs_val[2602] = 1.243323; bs_val[2603] = 1.243334; bs_val[2604] = 1.243345; bs_val[2605] = 1.243357; bs_val[2606] = 1.243368; bs_val[2607] = 1.243380; bs_val[2608] = 1.243391; bs_val[2609] = 1.243402; 
bs_val[2610] = 1.243414; bs_val[2611] = 1.243425; bs_val[2612] = 1.243437; bs_val[2613] = 1.243448; bs_val[2614] = 1.243459; bs_val[2615] = 1.243471; bs_val[2616] = 1.243482; bs_val[2617] = 1.243494; bs_val[2618] = 1.243505; bs_val[2619] = 1.243516; 
bs_val[2620] = 1.243528; bs_val[2621] = 1.243539; bs_val[2622] = 1.243550; bs_val[2623] = 1.243562; bs_val[2624] = 1.243573; bs_val[2625] = 1.243585; bs_val[2626] = 1.243596; bs_val[2627] = 1.243607; bs_val[2628] = 1.243619; bs_val[2629] = 1.243630; 
bs_val[2630] = 1.243642; bs_val[2631] = 1.243653; bs_val[2632] = 1.243664; bs_val[2633] = 1.243676; bs_val[2634] = 1.243687; bs_val[2635] = 1.243699; bs_val[2636] = 1.243710; bs_val[2637] = 1.243721; bs_val[2638] = 1.243733; bs_val[2639] = 1.243744; 
bs_val[2640] = 1.243756; bs_val[2641] = 1.243767; bs_val[2642] = 1.243779; bs_val[2643] = 1.243790; bs_val[2644] = 1.243801; bs_val[2645] = 1.243813; bs_val[2646] = 1.243824; bs_val[2647] = 1.243836; bs_val[2648] = 1.243847; bs_val[2649] = 1.243858; 
bs_val[2650] = 1.243870; bs_val[2651] = 1.243881; bs_val[2652] = 1.243893; bs_val[2653] = 1.243904; bs_val[2654] = 1.243915; bs_val[2655] = 1.243927; bs_val[2656] = 1.243938; bs_val[2657] = 1.243950; bs_val[2658] = 1.243961; bs_val[2659] = 1.243972; 
bs_val[2660] = 1.243984; bs_val[2661] = 1.243995; bs_val[2662] = 1.244007; bs_val[2663] = 1.244018; bs_val[2664] = 1.244030; bs_val[2665] = 1.244041; bs_val[2666] = 1.244052; bs_val[2667] = 1.244064; bs_val[2668] = 1.244075; bs_val[2669] = 1.244087; 
bs_val[2670] = 1.244098; bs_val[2671] = 1.244109; bs_val[2672] = 1.244121; bs_val[2673] = 1.244132; bs_val[2674] = 1.244144; bs_val[2675] = 1.244155; bs_val[2676] = 1.244167; bs_val[2677] = 1.244178; bs_val[2678] = 1.244189; bs_val[2679] = 1.244201; 
bs_val[2680] = 1.244212; bs_val[2681] = 1.244224; bs_val[2682] = 1.244235; bs_val[2683] = 1.244246; bs_val[2684] = 1.244258; bs_val[2685] = 1.244269; bs_val[2686] = 1.244281; bs_val[2687] = 1.244292; bs_val[2688] = 1.244304; bs_val[2689] = 1.244315; 
bs_val[2690] = 1.244326; bs_val[2691] = 1.244338; bs_val[2692] = 1.244349; bs_val[2693] = 1.244361; bs_val[2694] = 1.244372; bs_val[2695] = 1.244384; bs_val[2696] = 1.244395; bs_val[2697] = 1.244406; bs_val[2698] = 1.244418; bs_val[2699] = 1.244429; 
bs_val[2700] = 1.244441; bs_val[2701] = 1.244452; bs_val[2702] = 1.244464; bs_val[2703] = 1.244475; bs_val[2704] = 1.244486; bs_val[2705] = 1.244498; bs_val[2706] = 1.244509; bs_val[2707] = 1.244521; bs_val[2708] = 1.244532; bs_val[2709] = 1.244544; 
bs_val[2710] = 1.244555; bs_val[2711] = 1.244566; bs_val[2712] = 1.244578; bs_val[2713] = 1.244589; bs_val[2714] = 1.244601; bs_val[2715] = 1.244612; bs_val[2716] = 1.244624; bs_val[2717] = 1.244635; bs_val[2718] = 1.244646; bs_val[2719] = 1.244658; 
bs_val[2720] = 1.244669; bs_val[2721] = 1.244681; bs_val[2722] = 1.244692; bs_val[2723] = 1.244704; bs_val[2724] = 1.244715; bs_val[2725] = 1.244727; bs_val[2726] = 1.244738; bs_val[2727] = 1.244749; bs_val[2728] = 1.244761; bs_val[2729] = 1.244772; 
bs_val[2730] = 1.244784; bs_val[2731] = 1.244795; bs_val[2732] = 1.244807; bs_val[2733] = 1.244818; bs_val[2734] = 1.244830; bs_val[2735] = 1.244841; bs_val[2736] = 1.244852; bs_val[2737] = 1.244864; bs_val[2738] = 1.244875; bs_val[2739] = 1.244887; 
bs_val[2740] = 1.244898; bs_val[2741] = 1.244910; bs_val[2742] = 1.244921; bs_val[2743] = 1.244933; bs_val[2744] = 1.244944; bs_val[2745] = 1.244955; bs_val[2746] = 1.244967; bs_val[2747] = 1.244978; bs_val[2748] = 1.244990; bs_val[2749] = 1.245001; 
bs_val[2750] = 1.245013; bs_val[2751] = 1.245024; bs_val[2752] = 1.245036; bs_val[2753] = 1.245047; bs_val[2754] = 1.245058; bs_val[2755] = 1.245070; bs_val[2756] = 1.245081; bs_val[2757] = 1.245093; bs_val[2758] = 1.245104; bs_val[2759] = 1.245116; 
bs_val[2760] = 1.245127; bs_val[2761] = 1.245139; bs_val[2762] = 1.245150; bs_val[2763] = 1.245162; bs_val[2764] = 1.245173; bs_val[2765] = 1.245184; bs_val[2766] = 1.245196; bs_val[2767] = 1.245207; bs_val[2768] = 1.245219; bs_val[2769] = 1.245230; 
bs_val[2770] = 1.245242; bs_val[2771] = 1.245253; bs_val[2772] = 1.245265; bs_val[2773] = 1.245276; bs_val[2774] = 1.245288; bs_val[2775] = 1.245299; bs_val[2776] = 1.245311; bs_val[2777] = 1.245322; bs_val[2778] = 1.245333; bs_val[2779] = 1.245345; 
bs_val[2780] = 1.245356; bs_val[2781] = 1.245368; bs_val[2782] = 1.245379; bs_val[2783] = 1.245391; bs_val[2784] = 1.245402; bs_val[2785] = 1.245414; bs_val[2786] = 1.245425; bs_val[2787] = 1.245437; bs_val[2788] = 1.245448; bs_val[2789] = 1.245460; 
bs_val[2790] = 1.245471; bs_val[2791] = 1.245482; bs_val[2792] = 1.245494; bs_val[2793] = 1.245505; bs_val[2794] = 1.245517; bs_val[2795] = 1.245528; bs_val[2796] = 1.245540; bs_val[2797] = 1.245551; bs_val[2798] = 1.245563; bs_val[2799] = 1.245574; 
bs_val[2800] = 1.245586; bs_val[2801] = 1.245597; bs_val[2802] = 1.245609; bs_val[2803] = 1.245620; bs_val[2804] = 1.245632; bs_val[2805] = 1.245643; bs_val[2806] = 1.245655; bs_val[2807] = 1.245666; bs_val[2808] = 1.245677; bs_val[2809] = 1.245689; 
bs_val[2810] = 1.245700; bs_val[2811] = 1.245712; bs_val[2812] = 1.245723; bs_val[2813] = 1.245735; bs_val[2814] = 1.245746; bs_val[2815] = 1.245758; bs_val[2816] = 1.245769; bs_val[2817] = 1.245781; bs_val[2818] = 1.245792; bs_val[2819] = 1.245804; 
bs_val[2820] = 1.245815; bs_val[2821] = 1.245827; bs_val[2822] = 1.245838; bs_val[2823] = 1.245850; bs_val[2824] = 1.245861; bs_val[2825] = 1.245873; bs_val[2826] = 1.245884; bs_val[2827] = 1.245896; bs_val[2828] = 1.245907; bs_val[2829] = 1.245919; 
bs_val[2830] = 1.245930; bs_val[2831] = 1.245942; bs_val[2832] = 1.245953; bs_val[2833] = 1.245965; bs_val[2834] = 1.245976; bs_val[2835] = 1.245987; bs_val[2836] = 1.245999; bs_val[2837] = 1.246010; bs_val[2838] = 1.246022; bs_val[2839] = 1.246033; 
bs_val[2840] = 1.246045; bs_val[2841] = 1.246056; bs_val[2842] = 1.246068; bs_val[2843] = 1.246079; bs_val[2844] = 1.246091; bs_val[2845] = 1.246102; bs_val[2846] = 1.246114; bs_val[2847] = 1.246125; bs_val[2848] = 1.246137; bs_val[2849] = 1.246148; 
bs_val[2850] = 1.246160; bs_val[2851] = 1.246171; bs_val[2852] = 1.246183; bs_val[2853] = 1.246194; bs_val[2854] = 1.246206; bs_val[2855] = 1.246217; bs_val[2856] = 1.246229; bs_val[2857] = 1.246240; bs_val[2858] = 1.246252; bs_val[2859] = 1.246263; 
bs_val[2860] = 1.246275; bs_val[2861] = 1.246286; bs_val[2862] = 1.246298; bs_val[2863] = 1.246309; bs_val[2864] = 1.246321; bs_val[2865] = 1.246332; bs_val[2866] = 1.246344; bs_val[2867] = 1.246355; bs_val[2868] = 1.246367; bs_val[2869] = 1.246378; 
bs_val[2870] = 1.246390; bs_val[2871] = 1.246401; bs_val[2872] = 1.246413; bs_val[2873] = 1.246424; bs_val[2874] = 1.246436; bs_val[2875] = 1.246447; bs_val[2876] = 1.246459; bs_val[2877] = 1.246470; bs_val[2878] = 1.246482; bs_val[2879] = 1.246493; 
bs_val[2880] = 1.246505; bs_val[2881] = 1.246516; bs_val[2882] = 1.246528; bs_val[2883] = 1.246539; bs_val[2884] = 1.246551; bs_val[2885] = 1.246562; bs_val[2886] = 1.246574; bs_val[2887] = 1.246585; bs_val[2888] = 1.246597; bs_val[2889] = 1.246608; 
bs_val[2890] = 1.246620; bs_val[2891] = 1.246631; bs_val[2892] = 1.246643; bs_val[2893] = 1.246654; bs_val[2894] = 1.246666; bs_val[2895] = 1.246677; bs_val[2896] = 1.246689; bs_val[2897] = 1.246700; bs_val[2898] = 1.246712; bs_val[2899] = 1.246724; 
bs_val[2900] = 1.246735; bs_val[2901] = 1.246747; bs_val[2902] = 1.246758; bs_val[2903] = 1.246770; bs_val[2904] = 1.246781; bs_val[2905] = 1.246793; bs_val[2906] = 1.246804; bs_val[2907] = 1.246816; bs_val[2908] = 1.246827; bs_val[2909] = 1.246839; 
bs_val[2910] = 1.246850; bs_val[2911] = 1.246862; bs_val[2912] = 1.246873; bs_val[2913] = 1.246885; bs_val[2914] = 1.246896; bs_val[2915] = 1.246908; bs_val[2916] = 1.246919; bs_val[2917] = 1.246931; bs_val[2918] = 1.246942; bs_val[2919] = 1.246954; 
bs_val[2920] = 1.246965; bs_val[2921] = 1.246977; bs_val[2922] = 1.246988; bs_val[2923] = 1.247000; bs_val[2924] = 1.247011; bs_val[2925] = 1.247023; bs_val[2926] = 1.247035; bs_val[2927] = 1.247046; bs_val[2928] = 1.247058; bs_val[2929] = 1.247069; 
bs_val[2930] = 1.247081; bs_val[2931] = 1.247092; bs_val[2932] = 1.247104; bs_val[2933] = 1.247115; bs_val[2934] = 1.247127; bs_val[2935] = 1.247138; bs_val[2936] = 1.247150; bs_val[2937] = 1.247161; bs_val[2938] = 1.247173; bs_val[2939] = 1.247184; 
bs_val[2940] = 1.247196; bs_val[2941] = 1.247207; bs_val[2942] = 1.247219; bs_val[2943] = 1.247231; bs_val[2944] = 1.247242; bs_val[2945] = 1.247254; bs_val[2946] = 1.247265; bs_val[2947] = 1.247277; bs_val[2948] = 1.247288; bs_val[2949] = 1.247300; 
bs_val[2950] = 1.247311; bs_val[2951] = 1.247323; bs_val[2952] = 1.247334; bs_val[2953] = 1.247346; bs_val[2954] = 1.247357; bs_val[2955] = 1.247369; bs_val[2956] = 1.247381; bs_val[2957] = 1.247392; bs_val[2958] = 1.247404; bs_val[2959] = 1.247415; 
bs_val[2960] = 1.247427; bs_val[2961] = 1.247438; bs_val[2962] = 1.247450; bs_val[2963] = 1.247461; bs_val[2964] = 1.247473; bs_val[2965] = 1.247484; bs_val[2966] = 1.247496; bs_val[2967] = 1.247507; bs_val[2968] = 1.247519; bs_val[2969] = 1.247531; 
bs_val[2970] = 1.247542; bs_val[2971] = 1.247554; bs_val[2972] = 1.247565; bs_val[2973] = 1.247577; bs_val[2974] = 1.247588; bs_val[2975] = 1.247600; bs_val[2976] = 1.247611; bs_val[2977] = 1.247623; bs_val[2978] = 1.247634; bs_val[2979] = 1.247646; 
bs_val[2980] = 1.247658; bs_val[2981] = 1.247669; bs_val[2982] = 1.247681; bs_val[2983] = 1.247692; bs_val[2984] = 1.247704; bs_val[2985] = 1.247715; bs_val[2986] = 1.247727; bs_val[2987] = 1.247738; bs_val[2988] = 1.247750; bs_val[2989] = 1.247762; 
bs_val[2990] = 1.247773; bs_val[2991] = 1.247785; bs_val[2992] = 1.247796; bs_val[2993] = 1.247808; bs_val[2994] = 1.247819; bs_val[2995] = 1.247831; bs_val[2996] = 1.247842; bs_val[2997] = 1.247854; bs_val[2998] = 1.247866; bs_val[2999] = 1.247877; 
bs_val[3000] = 1.247889; bs_val[3001] = 1.247900; bs_val[3002] = 1.247912; bs_val[3003] = 1.247923; bs_val[3004] = 1.247935; bs_val[3005] = 1.247946; bs_val[3006] = 1.247958; bs_val[3007] = 1.247970; bs_val[3008] = 1.247981; bs_val[3009] = 1.247993; 
bs_val[3010] = 1.248004; bs_val[3011] = 1.248016; bs_val[3012] = 1.248027; bs_val[3013] = 1.248039; bs_val[3014] = 1.248051; bs_val[3015] = 1.248062; bs_val[3016] = 1.248074; bs_val[3017] = 1.248085; bs_val[3018] = 1.248097; bs_val[3019] = 1.248108; 
bs_val[3020] = 1.248120; bs_val[3021] = 1.248131; bs_val[3022] = 1.248143; bs_val[3023] = 1.248155; bs_val[3024] = 1.248166; bs_val[3025] = 1.248178; bs_val[3026] = 1.248189; bs_val[3027] = 1.248201; bs_val[3028] = 1.248212; bs_val[3029] = 1.248224; 
bs_val[3030] = 1.248236; bs_val[3031] = 1.248247; bs_val[3032] = 1.248259; bs_val[3033] = 1.248270; bs_val[3034] = 1.248282; bs_val[3035] = 1.248293; bs_val[3036] = 1.248305; bs_val[3037] = 1.248317; bs_val[3038] = 1.248328; bs_val[3039] = 1.248340; 
bs_val[3040] = 1.248351; bs_val[3041] = 1.248363; bs_val[3042] = 1.248374; bs_val[3043] = 1.248386; bs_val[3044] = 1.248398; bs_val[3045] = 1.248409; bs_val[3046] = 1.248421; bs_val[3047] = 1.248432; bs_val[3048] = 1.248444; bs_val[3049] = 1.248456; 
bs_val[3050] = 1.248467; bs_val[3051] = 1.248479; bs_val[3052] = 1.248490; bs_val[3053] = 1.248502; bs_val[3054] = 1.248513; bs_val[3055] = 1.248525; bs_val[3056] = 1.248537; bs_val[3057] = 1.248548; bs_val[3058] = 1.248560; bs_val[3059] = 1.248571; 
bs_val[3060] = 1.248583; bs_val[3061] = 1.248595; bs_val[3062] = 1.248606; bs_val[3063] = 1.248618; bs_val[3064] = 1.248629; bs_val[3065] = 1.248641; bs_val[3066] = 1.248652; bs_val[3067] = 1.248664; bs_val[3068] = 1.248676; bs_val[3069] = 1.248687; 
bs_val[3070] = 1.248699; bs_val[3071] = 1.248710; bs_val[3072] = 1.248722; bs_val[3073] = 1.248734; bs_val[3074] = 1.248745; bs_val[3075] = 1.248757; bs_val[3076] = 1.248768; bs_val[3077] = 1.248780; bs_val[3078] = 1.248792; bs_val[3079] = 1.248803; 
bs_val[3080] = 1.248815; bs_val[3081] = 1.248826; bs_val[3082] = 1.248838; bs_val[3083] = 1.248850; bs_val[3084] = 1.248861; bs_val[3085] = 1.248873; bs_val[3086] = 1.248884; bs_val[3087] = 1.248896; bs_val[3088] = 1.248907; bs_val[3089] = 1.248919; 
bs_val[3090] = 1.248931; bs_val[3091] = 1.248942; bs_val[3092] = 1.248954; bs_val[3093] = 1.248965; bs_val[3094] = 1.248977; bs_val[3095] = 1.248989; bs_val[3096] = 1.249000; bs_val[3097] = 1.249012; bs_val[3098] = 1.249023; bs_val[3099] = 1.249035; 
bs_val[3100] = 1.249047; bs_val[3101] = 1.249058; bs_val[3102] = 1.249070; bs_val[3103] = 1.249081; bs_val[3104] = 1.249093; bs_val[3105] = 1.249105; bs_val[3106] = 1.249116; bs_val[3107] = 1.249128; bs_val[3108] = 1.249140; bs_val[3109] = 1.249151; 
bs_val[3110] = 1.249163; bs_val[3111] = 1.249174; bs_val[3112] = 1.249186; bs_val[3113] = 1.249198; bs_val[3114] = 1.249209; bs_val[3115] = 1.249221; bs_val[3116] = 1.249232; bs_val[3117] = 1.249244; bs_val[3118] = 1.249256; bs_val[3119] = 1.249267; 
bs_val[3120] = 1.249279; bs_val[3121] = 1.249290; bs_val[3122] = 1.249302; bs_val[3123] = 1.249314; bs_val[3124] = 1.249325; bs_val[3125] = 1.249337; bs_val[3126] = 1.249348; bs_val[3127] = 1.249360; bs_val[3128] = 1.249372; bs_val[3129] = 1.249383; 
bs_val[3130] = 1.249395; bs_val[3131] = 1.249407; bs_val[3132] = 1.249418; bs_val[3133] = 1.249430; bs_val[3134] = 1.249441; bs_val[3135] = 1.249453; bs_val[3136] = 1.249465; bs_val[3137] = 1.249476; bs_val[3138] = 1.249488; bs_val[3139] = 1.249500; 
bs_val[3140] = 1.249511; bs_val[3141] = 1.249523; bs_val[3142] = 1.249534; bs_val[3143] = 1.249546; bs_val[3144] = 1.249558; bs_val[3145] = 1.249569; bs_val[3146] = 1.249581; bs_val[3147] = 1.249592; bs_val[3148] = 1.249604; bs_val[3149] = 1.249616; 
bs_val[3150] = 1.249627; bs_val[3151] = 1.249639; bs_val[3152] = 1.249651; bs_val[3153] = 1.249662; bs_val[3154] = 1.249674; bs_val[3155] = 1.249685; bs_val[3156] = 1.249697; bs_val[3157] = 1.249709; bs_val[3158] = 1.249720; bs_val[3159] = 1.249732; 
bs_val[3160] = 1.249744; bs_val[3161] = 1.249755; bs_val[3162] = 1.249767; bs_val[3163] = 1.249779; bs_val[3164] = 1.249790; bs_val[3165] = 1.249802; bs_val[3166] = 1.249813; bs_val[3167] = 1.249825; bs_val[3168] = 1.249837; bs_val[3169] = 1.249848; 
bs_val[3170] = 1.249860; bs_val[3171] = 1.249872; bs_val[3172] = 1.249883; bs_val[3173] = 1.249895; bs_val[3174] = 1.249906; bs_val[3175] = 1.249918; bs_val[3176] = 1.249930; bs_val[3177] = 1.249941; bs_val[3178] = 1.249953; bs_val[3179] = 1.249965; 
bs_val[3180] = 1.249976; bs_val[3181] = 1.249988; bs_val[3182] = 1.250000; bs_val[3183] = 1.250011; bs_val[3184] = 1.250023; bs_val[3185] = 1.250034; bs_val[3186] = 1.250046; bs_val[3187] = 1.250058; bs_val[3188] = 1.250069; bs_val[3189] = 1.250081; 
bs_val[3190] = 1.250093; bs_val[3191] = 1.250104; bs_val[3192] = 1.250116; bs_val[3193] = 1.250128; bs_val[3194] = 1.250139; bs_val[3195] = 1.250151; bs_val[3196] = 1.250163; bs_val[3197] = 1.250174; bs_val[3198] = 1.250186; bs_val[3199] = 1.250197; 
bs_val[3200] = 1.250209; bs_val[3201] = 1.250221; bs_val[3202] = 1.250232; bs_val[3203] = 1.250244; bs_val[3204] = 1.250256; bs_val[3205] = 1.250267; bs_val[3206] = 1.250279; bs_val[3207] = 1.250291; bs_val[3208] = 1.250302; bs_val[3209] = 1.250314; 
bs_val[3210] = 1.250326; bs_val[3211] = 1.250337; bs_val[3212] = 1.250349; bs_val[3213] = 1.250361; bs_val[3214] = 1.250372; bs_val[3215] = 1.250384; bs_val[3216] = 1.250396; bs_val[3217] = 1.250407; bs_val[3218] = 1.250419; bs_val[3219] = 1.250431; 
bs_val[3220] = 1.250442; bs_val[3221] = 1.250454; bs_val[3222] = 1.250465; bs_val[3223] = 1.250477; bs_val[3224] = 1.250489; bs_val[3225] = 1.250500; bs_val[3226] = 1.250512; bs_val[3227] = 1.250524; bs_val[3228] = 1.250535; bs_val[3229] = 1.250547; 
bs_val[3230] = 1.250559; bs_val[3231] = 1.250570; bs_val[3232] = 1.250582; bs_val[3233] = 1.250594; bs_val[3234] = 1.250605; bs_val[3235] = 1.250617; bs_val[3236] = 1.250629; bs_val[3237] = 1.250640; bs_val[3238] = 1.250652; bs_val[3239] = 1.250664; 
bs_val[3240] = 1.250675; bs_val[3241] = 1.250687; bs_val[3242] = 1.250699; bs_val[3243] = 1.250710; bs_val[3244] = 1.250722; bs_val[3245] = 1.250734; bs_val[3246] = 1.250745; bs_val[3247] = 1.250757; bs_val[3248] = 1.250769; bs_val[3249] = 1.250780; 
bs_val[3250] = 1.250792; bs_val[3251] = 1.250804; bs_val[3252] = 1.250815; bs_val[3253] = 1.250827; bs_val[3254] = 1.250839; bs_val[3255] = 1.250850; bs_val[3256] = 1.250862; bs_val[3257] = 1.250874; bs_val[3258] = 1.250885; bs_val[3259] = 1.250897; 
bs_val[3260] = 1.250909; bs_val[3261] = 1.250920; bs_val[3262] = 1.250932; bs_val[3263] = 1.250944; bs_val[3264] = 1.250955; bs_val[3265] = 1.250967; bs_val[3266] = 1.250979; bs_val[3267] = 1.250990; bs_val[3268] = 1.251002; bs_val[3269] = 1.251014; 
bs_val[3270] = 1.251026; bs_val[3271] = 1.251037; bs_val[3272] = 1.251049; bs_val[3273] = 1.251061; bs_val[3274] = 1.251072; bs_val[3275] = 1.251084; bs_val[3276] = 1.251096; bs_val[3277] = 1.251107; bs_val[3278] = 1.251119; bs_val[3279] = 1.251131; 
bs_val[3280] = 1.251142; bs_val[3281] = 1.251154; bs_val[3282] = 1.251166; bs_val[3283] = 1.251177; bs_val[3284] = 1.251189; bs_val[3285] = 1.251201; bs_val[3286] = 1.251212; bs_val[3287] = 1.251224; bs_val[3288] = 1.251236; bs_val[3289] = 1.251247; 
bs_val[3290] = 1.251259; bs_val[3291] = 1.251271; bs_val[3292] = 1.251283; bs_val[3293] = 1.251294; bs_val[3294] = 1.251306; bs_val[3295] = 1.251318; bs_val[3296] = 1.251329; bs_val[3297] = 1.251341; bs_val[3298] = 1.251353; bs_val[3299] = 1.251364; 
bs_val[3300] = 1.251376; bs_val[3301] = 1.251388; bs_val[3302] = 1.251399; bs_val[3303] = 1.251411; bs_val[3304] = 1.251423; bs_val[3305] = 1.251435; bs_val[3306] = 1.251446; bs_val[3307] = 1.251458; bs_val[3308] = 1.251470; bs_val[3309] = 1.251481; 
bs_val[3310] = 1.251493; bs_val[3311] = 1.251505; bs_val[3312] = 1.251516; bs_val[3313] = 1.251528; bs_val[3314] = 1.251540; bs_val[3315] = 1.251552; bs_val[3316] = 1.251563; bs_val[3317] = 1.251575; bs_val[3318] = 1.251587; bs_val[3319] = 1.251598; 
bs_val[3320] = 1.251610; bs_val[3321] = 1.251622; bs_val[3322] = 1.251633; bs_val[3323] = 1.251645; bs_val[3324] = 1.251657; bs_val[3325] = 1.251669; bs_val[3326] = 1.251680; bs_val[3327] = 1.251692; bs_val[3328] = 1.251704; bs_val[3329] = 1.251715; 
bs_val[3330] = 1.251727; bs_val[3331] = 1.251739; bs_val[3332] = 1.251750; bs_val[3333] = 1.251762; bs_val[3334] = 1.251774; bs_val[3335] = 1.251786; bs_val[3336] = 1.251797; bs_val[3337] = 1.251809; bs_val[3338] = 1.251821; bs_val[3339] = 1.251832; 
bs_val[3340] = 1.251844; bs_val[3341] = 1.251856; bs_val[3342] = 1.251868; bs_val[3343] = 1.251879; bs_val[3344] = 1.251891; bs_val[3345] = 1.251903; bs_val[3346] = 1.251914; bs_val[3347] = 1.251926; bs_val[3348] = 1.251938; bs_val[3349] = 1.251950; 
bs_val[3350] = 1.251961; bs_val[3351] = 1.251973; bs_val[3352] = 1.251985; bs_val[3353] = 1.251996; bs_val[3354] = 1.252008; bs_val[3355] = 1.252020; bs_val[3356] = 1.252032; bs_val[3357] = 1.252043; bs_val[3358] = 1.252055; bs_val[3359] = 1.252067; 
bs_val[3360] = 1.252078; bs_val[3361] = 1.252090; bs_val[3362] = 1.252102; bs_val[3363] = 1.252114; bs_val[3364] = 1.252125; bs_val[3365] = 1.252137; bs_val[3366] = 1.252149; bs_val[3367] = 1.252160; bs_val[3368] = 1.252172; bs_val[3369] = 1.252184; 
bs_val[3370] = 1.252196; bs_val[3371] = 1.252207; bs_val[3372] = 1.252219; bs_val[3373] = 1.252231; bs_val[3374] = 1.252243; bs_val[3375] = 1.252254; bs_val[3376] = 1.252266; bs_val[3377] = 1.252278; bs_val[3378] = 1.252289; bs_val[3379] = 1.252301; 
bs_val[3380] = 1.252313; bs_val[3381] = 1.252325; bs_val[3382] = 1.252336; bs_val[3383] = 1.252348; bs_val[3384] = 1.252360; bs_val[3385] = 1.252372; bs_val[3386] = 1.252383; bs_val[3387] = 1.252395; bs_val[3388] = 1.252407; bs_val[3389] = 1.252418; 
bs_val[3390] = 1.252430; bs_val[3391] = 1.252442; bs_val[3392] = 1.252454; bs_val[3393] = 1.252465; bs_val[3394] = 1.252477; bs_val[3395] = 1.252489; bs_val[3396] = 1.252501; bs_val[3397] = 1.252512; bs_val[3398] = 1.252524; bs_val[3399] = 1.252536; 
bs_val[3400] = 1.252548; bs_val[3401] = 1.252559; bs_val[3402] = 1.252571; bs_val[3403] = 1.252583; bs_val[3404] = 1.252595; bs_val[3405] = 1.252606; bs_val[3406] = 1.252618; bs_val[3407] = 1.252630; bs_val[3408] = 1.252641; bs_val[3409] = 1.252653; 
bs_val[3410] = 1.252665; bs_val[3411] = 1.252677; bs_val[3412] = 1.252688; bs_val[3413] = 1.252700; bs_val[3414] = 1.252712; bs_val[3415] = 1.252724; bs_val[3416] = 1.252735; bs_val[3417] = 1.252747; bs_val[3418] = 1.252759; bs_val[3419] = 1.252771; 
bs_val[3420] = 1.252782; bs_val[3421] = 1.252794; bs_val[3422] = 1.252806; bs_val[3423] = 1.252818; bs_val[3424] = 1.252829; bs_val[3425] = 1.252841; bs_val[3426] = 1.252853; bs_val[3427] = 1.252865; bs_val[3428] = 1.252876; bs_val[3429] = 1.252888; 
bs_val[3430] = 1.252900; bs_val[3431] = 1.252912; bs_val[3432] = 1.252923; bs_val[3433] = 1.252935; bs_val[3434] = 1.252947; bs_val[3435] = 1.252959; bs_val[3436] = 1.252970; bs_val[3437] = 1.252982; bs_val[3438] = 1.252994; bs_val[3439] = 1.253006; 
bs_val[3440] = 1.253017; bs_val[3441] = 1.253029; bs_val[3442] = 1.253041; bs_val[3443] = 1.253053; bs_val[3444] = 1.253064; bs_val[3445] = 1.253076; bs_val[3446] = 1.253088; bs_val[3447] = 1.253100; bs_val[3448] = 1.253112; bs_val[3449] = 1.253123; 
bs_val[3450] = 1.253135; bs_val[3451] = 1.253147; bs_val[3452] = 1.253159; bs_val[3453] = 1.253170; bs_val[3454] = 1.253182; bs_val[3455] = 1.253194; bs_val[3456] = 1.253206; bs_val[3457] = 1.253217; bs_val[3458] = 1.253229; bs_val[3459] = 1.253241; 
bs_val[3460] = 1.253253; bs_val[3461] = 1.253264; bs_val[3462] = 1.253276; bs_val[3463] = 1.253288; bs_val[3464] = 1.253300; bs_val[3465] = 1.253312; bs_val[3466] = 1.253323; bs_val[3467] = 1.253335; bs_val[3468] = 1.253347; bs_val[3469] = 1.253359; 
bs_val[3470] = 1.253370; bs_val[3471] = 1.253382; bs_val[3472] = 1.253394; bs_val[3473] = 1.253406; bs_val[3474] = 1.253417; bs_val[3475] = 1.253429; bs_val[3476] = 1.253441; bs_val[3477] = 1.253453; bs_val[3478] = 1.253465; bs_val[3479] = 1.253476; 
bs_val[3480] = 1.253488; bs_val[3481] = 1.253500; bs_val[3482] = 1.253512; bs_val[3483] = 1.253523; bs_val[3484] = 1.253535; bs_val[3485] = 1.253547; bs_val[3486] = 1.253559; bs_val[3487] = 1.253571; bs_val[3488] = 1.253582; bs_val[3489] = 1.253594; 
bs_val[3490] = 1.253606; bs_val[3491] = 1.253618; bs_val[3492] = 1.253629; bs_val[3493] = 1.253641; bs_val[3494] = 1.253653; bs_val[3495] = 1.253665; bs_val[3496] = 1.253677; bs_val[3497] = 1.253688; bs_val[3498] = 1.253700; bs_val[3499] = 1.253712; 
bs_val[3500] = 1.253724; bs_val[3501] = 1.253735; bs_val[3502] = 1.253747; bs_val[3503] = 1.253759; bs_val[3504] = 1.253771; bs_val[3505] = 1.253783; bs_val[3506] = 1.253794; bs_val[3507] = 1.253806; bs_val[3508] = 1.253818; bs_val[3509] = 1.253830; 
bs_val[3510] = 1.253842; bs_val[3511] = 1.253853; bs_val[3512] = 1.253865; bs_val[3513] = 1.253877; bs_val[3514] = 1.253889; bs_val[3515] = 1.253900; bs_val[3516] = 1.253912; bs_val[3517] = 1.253924; bs_val[3518] = 1.253936; bs_val[3519] = 1.253948; 
bs_val[3520] = 1.253959; bs_val[3521] = 1.253971; bs_val[3522] = 1.253983; bs_val[3523] = 1.253995; bs_val[3524] = 1.254007; bs_val[3525] = 1.254018; bs_val[3526] = 1.254030; bs_val[3527] = 1.254042; bs_val[3528] = 1.254054; bs_val[3529] = 1.254066; 
bs_val[3530] = 1.254077; bs_val[3531] = 1.254089; bs_val[3532] = 1.254101; bs_val[3533] = 1.254113; bs_val[3534] = 1.254125; bs_val[3535] = 1.254136; bs_val[3536] = 1.254148; bs_val[3537] = 1.254160; bs_val[3538] = 1.254172; bs_val[3539] = 1.254184; 
bs_val[3540] = 1.254195; bs_val[3541] = 1.254207; bs_val[3542] = 1.254219; bs_val[3543] = 1.254231; bs_val[3544] = 1.254243; bs_val[3545] = 1.254254; bs_val[3546] = 1.254266; bs_val[3547] = 1.254278; bs_val[3548] = 1.254290; bs_val[3549] = 1.254302; 
bs_val[3550] = 1.254313; bs_val[3551] = 1.254325; bs_val[3552] = 1.254337; bs_val[3553] = 1.254349; bs_val[3554] = 1.254361; bs_val[3555] = 1.254373; bs_val[3556] = 1.254384; bs_val[3557] = 1.254396; bs_val[3558] = 1.254408; bs_val[3559] = 1.254420; 
bs_val[3560] = 1.254432; bs_val[3561] = 1.254443; bs_val[3562] = 1.254455; bs_val[3563] = 1.254467; bs_val[3564] = 1.254479; bs_val[3565] = 1.254491; bs_val[3566] = 1.254502; bs_val[3567] = 1.254514; bs_val[3568] = 1.254526; bs_val[3569] = 1.254538; 
bs_val[3570] = 1.254550; bs_val[3571] = 1.254562; bs_val[3572] = 1.254573; bs_val[3573] = 1.254585; bs_val[3574] = 1.254597; bs_val[3575] = 1.254609; bs_val[3576] = 1.254621; bs_val[3577] = 1.254632; bs_val[3578] = 1.254644; bs_val[3579] = 1.254656; 
bs_val[3580] = 1.254668; bs_val[3581] = 1.254680; bs_val[3582] = 1.254692; bs_val[3583] = 1.254703; bs_val[3584] = 1.254715; bs_val[3585] = 1.254727; bs_val[3586] = 1.254739; bs_val[3587] = 1.254751; bs_val[3588] = 1.254763; bs_val[3589] = 1.254774; 
bs_val[3590] = 1.254786; bs_val[3591] = 1.254798; bs_val[3592] = 1.254810; bs_val[3593] = 1.254822; bs_val[3594] = 1.254833; bs_val[3595] = 1.254845; bs_val[3596] = 1.254857; bs_val[3597] = 1.254869; bs_val[3598] = 1.254881; bs_val[3599] = 1.254893; 
bs_val[3600] = 1.254904; bs_val[3601] = 1.254916; bs_val[3602] = 1.254928; bs_val[3603] = 1.254940; bs_val[3604] = 1.254952; bs_val[3605] = 1.254964; bs_val[3606] = 1.254975; bs_val[3607] = 1.254987; bs_val[3608] = 1.254999; bs_val[3609] = 1.255011; 
bs_val[3610] = 1.255023; bs_val[3611] = 1.255035; bs_val[3612] = 1.255046; bs_val[3613] = 1.255058; bs_val[3614] = 1.255070; bs_val[3615] = 1.255082; bs_val[3616] = 1.255094; bs_val[3617] = 1.255106; bs_val[3618] = 1.255118; bs_val[3619] = 1.255129; 
bs_val[3620] = 1.255141; bs_val[3621] = 1.255153; bs_val[3622] = 1.255165; bs_val[3623] = 1.255177; bs_val[3624] = 1.255189; bs_val[3625] = 1.255200; bs_val[3626] = 1.255212; bs_val[3627] = 1.255224; bs_val[3628] = 1.255236; bs_val[3629] = 1.255248; 
bs_val[3630] = 1.255260; bs_val[3631] = 1.255271; bs_val[3632] = 1.255283; bs_val[3633] = 1.255295; bs_val[3634] = 1.255307; bs_val[3635] = 1.255319; bs_val[3636] = 1.255331; bs_val[3637] = 1.255343; bs_val[3638] = 1.255354; bs_val[3639] = 1.255366; 
bs_val[3640] = 1.255378; bs_val[3641] = 1.255390; bs_val[3642] = 1.255402; bs_val[3643] = 1.255414; bs_val[3644] = 1.255426; bs_val[3645] = 1.255437; bs_val[3646] = 1.255449; bs_val[3647] = 1.255461; bs_val[3648] = 1.255473; bs_val[3649] = 1.255485; 
bs_val[3650] = 1.255497; bs_val[3651] = 1.255508; bs_val[3652] = 1.255520; bs_val[3653] = 1.255532; bs_val[3654] = 1.255544; bs_val[3655] = 1.255556; bs_val[3656] = 1.255568; bs_val[3657] = 1.255580; bs_val[3658] = 1.255591; bs_val[3659] = 1.255603; 
bs_val[3660] = 1.255615; bs_val[3661] = 1.255627; bs_val[3662] = 1.255639; bs_val[3663] = 1.255651; bs_val[3664] = 1.255663; bs_val[3665] = 1.255675; bs_val[3666] = 1.255686; bs_val[3667] = 1.255698; bs_val[3668] = 1.255710; bs_val[3669] = 1.255722; 
bs_val[3670] = 1.255734; bs_val[3671] = 1.255746; bs_val[3672] = 1.255758; bs_val[3673] = 1.255769; bs_val[3674] = 1.255781; bs_val[3675] = 1.255793; bs_val[3676] = 1.255805; bs_val[3677] = 1.255817; bs_val[3678] = 1.255829; bs_val[3679] = 1.255841; 
bs_val[3680] = 1.255853; bs_val[3681] = 1.255864; bs_val[3682] = 1.255876; bs_val[3683] = 1.255888; bs_val[3684] = 1.255900; bs_val[3685] = 1.255912; bs_val[3686] = 1.255924; bs_val[3687] = 1.255936; bs_val[3688] = 1.255947; bs_val[3689] = 1.255959; 
bs_val[3690] = 1.255971; bs_val[3691] = 1.255983; bs_val[3692] = 1.255995; bs_val[3693] = 1.256007; bs_val[3694] = 1.256019; bs_val[3695] = 1.256031; bs_val[3696] = 1.256042; bs_val[3697] = 1.256054; bs_val[3698] = 1.256066; bs_val[3699] = 1.256078; 
bs_val[3700] = 1.256090; bs_val[3701] = 1.256102; bs_val[3702] = 1.256114; bs_val[3703] = 1.256126; bs_val[3704] = 1.256138; bs_val[3705] = 1.256149; bs_val[3706] = 1.256161; bs_val[3707] = 1.256173; bs_val[3708] = 1.256185; bs_val[3709] = 1.256197; 
bs_val[3710] = 1.256209; bs_val[3711] = 1.256221; bs_val[3712] = 1.256233; bs_val[3713] = 1.256244; bs_val[3714] = 1.256256; bs_val[3715] = 1.256268; bs_val[3716] = 1.256280; bs_val[3717] = 1.256292; bs_val[3718] = 1.256304; bs_val[3719] = 1.256316; 
bs_val[3720] = 1.256328; bs_val[3721] = 1.256340; bs_val[3722] = 1.256351; bs_val[3723] = 1.256363; bs_val[3724] = 1.256375; bs_val[3725] = 1.256387; bs_val[3726] = 1.256399; bs_val[3727] = 1.256411; bs_val[3728] = 1.256423; bs_val[3729] = 1.256435; 
bs_val[3730] = 1.256447; bs_val[3731] = 1.256459; bs_val[3732] = 1.256470; bs_val[3733] = 1.256482; bs_val[3734] = 1.256494; bs_val[3735] = 1.256506; bs_val[3736] = 1.256518; bs_val[3737] = 1.256530; bs_val[3738] = 1.256542; bs_val[3739] = 1.256554; 
bs_val[3740] = 1.256566; bs_val[3741] = 1.256577; bs_val[3742] = 1.256589; bs_val[3743] = 1.256601; bs_val[3744] = 1.256613; bs_val[3745] = 1.256625; bs_val[3746] = 1.256637; bs_val[3747] = 1.256649; bs_val[3748] = 1.256661; bs_val[3749] = 1.256673; 
bs_val[3750] = 1.256685; bs_val[3751] = 1.256696; bs_val[3752] = 1.256708; bs_val[3753] = 1.256720; bs_val[3754] = 1.256732; bs_val[3755] = 1.256744; bs_val[3756] = 1.256756; bs_val[3757] = 1.256768; bs_val[3758] = 1.256780; bs_val[3759] = 1.256792; 
bs_val[3760] = 1.256804; bs_val[3761] = 1.256816; bs_val[3762] = 1.256827; bs_val[3763] = 1.256839; bs_val[3764] = 1.256851; bs_val[3765] = 1.256863; bs_val[3766] = 1.256875; bs_val[3767] = 1.256887; bs_val[3768] = 1.256899; bs_val[3769] = 1.256911; 
bs_val[3770] = 1.256923; bs_val[3771] = 1.256935; bs_val[3772] = 1.256947; bs_val[3773] = 1.256959; bs_val[3774] = 1.256970; bs_val[3775] = 1.256982; bs_val[3776] = 1.256994; bs_val[3777] = 1.257006; bs_val[3778] = 1.257018; bs_val[3779] = 1.257030; 
bs_val[3780] = 1.257042; bs_val[3781] = 1.257054; bs_val[3782] = 1.257066; bs_val[3783] = 1.257078; bs_val[3784] = 1.257090; bs_val[3785] = 1.257102; bs_val[3786] = 1.257113; bs_val[3787] = 1.257125; bs_val[3788] = 1.257137; bs_val[3789] = 1.257149; 
bs_val[3790] = 1.257161; bs_val[3791] = 1.257173; bs_val[3792] = 1.257185; bs_val[3793] = 1.257197; bs_val[3794] = 1.257209; bs_val[3795] = 1.257221; bs_val[3796] = 1.257233; bs_val[3797] = 1.257245; bs_val[3798] = 1.257257; bs_val[3799] = 1.257268; 
bs_val[3800] = 1.257280; bs_val[3801] = 1.257292; bs_val[3802] = 1.257304; bs_val[3803] = 1.257316; bs_val[3804] = 1.257328; bs_val[3805] = 1.257340; bs_val[3806] = 1.257352; bs_val[3807] = 1.257364; bs_val[3808] = 1.257376; bs_val[3809] = 1.257388; 
bs_val[3810] = 1.257400; bs_val[3811] = 1.257412; bs_val[3812] = 1.257424; bs_val[3813] = 1.257435; bs_val[3814] = 1.257447; bs_val[3815] = 1.257459; bs_val[3816] = 1.257471; bs_val[3817] = 1.257483; bs_val[3818] = 1.257495; bs_val[3819] = 1.257507; 
bs_val[3820] = 1.257519; bs_val[3821] = 1.257531; bs_val[3822] = 1.257543; bs_val[3823] = 1.257555; bs_val[3824] = 1.257567; bs_val[3825] = 1.257579; bs_val[3826] = 1.257591; bs_val[3827] = 1.257603; bs_val[3828] = 1.257615; bs_val[3829] = 1.257627; 
bs_val[3830] = 1.257638; bs_val[3831] = 1.257650; bs_val[3832] = 1.257662; bs_val[3833] = 1.257674; bs_val[3834] = 1.257686; bs_val[3835] = 1.257698; bs_val[3836] = 1.257710; bs_val[3837] = 1.257722; bs_val[3838] = 1.257734; bs_val[3839] = 1.257746; 
bs_val[3840] = 1.257758; bs_val[3841] = 1.257770; bs_val[3842] = 1.257782; bs_val[3843] = 1.257794; bs_val[3844] = 1.257806; bs_val[3845] = 1.257818; bs_val[3846] = 1.257830; bs_val[3847] = 1.257842; bs_val[3848] = 1.257854; bs_val[3849] = 1.257865; 
bs_val[3850] = 1.257877; bs_val[3851] = 1.257889; bs_val[3852] = 1.257901; bs_val[3853] = 1.257913; bs_val[3854] = 1.257925; bs_val[3855] = 1.257937; bs_val[3856] = 1.257949; bs_val[3857] = 1.257961; bs_val[3858] = 1.257973; bs_val[3859] = 1.257985; 
bs_val[3860] = 1.257997; bs_val[3861] = 1.258009; bs_val[3862] = 1.258021; bs_val[3863] = 1.258033; bs_val[3864] = 1.258045; bs_val[3865] = 1.258057; bs_val[3866] = 1.258069; bs_val[3867] = 1.258081; bs_val[3868] = 1.258093; bs_val[3869] = 1.258105; 
bs_val[3870] = 1.258117; bs_val[3871] = 1.258129; bs_val[3872] = 1.258140; bs_val[3873] = 1.258152; bs_val[3874] = 1.258164; bs_val[3875] = 1.258176; bs_val[3876] = 1.258188; bs_val[3877] = 1.258200; bs_val[3878] = 1.258212; bs_val[3879] = 1.258224; 
bs_val[3880] = 1.258236; bs_val[3881] = 1.258248; bs_val[3882] = 1.258260; bs_val[3883] = 1.258272; bs_val[3884] = 1.258284; bs_val[3885] = 1.258296; bs_val[3886] = 1.258308; bs_val[3887] = 1.258320; bs_val[3888] = 1.258332; bs_val[3889] = 1.258344; 
bs_val[3890] = 1.258356; bs_val[3891] = 1.258368; bs_val[3892] = 1.258380; bs_val[3893] = 1.258392; bs_val[3894] = 1.258404; bs_val[3895] = 1.258416; bs_val[3896] = 1.258428; bs_val[3897] = 1.258440; bs_val[3898] = 1.258452; bs_val[3899] = 1.258464; 
bs_val[3900] = 1.258476; bs_val[3901] = 1.258488; bs_val[3902] = 1.258500; bs_val[3903] = 1.258512; bs_val[3904] = 1.258524; bs_val[3905] = 1.258536; bs_val[3906] = 1.258548; bs_val[3907] = 1.258560; bs_val[3908] = 1.258572; bs_val[3909] = 1.258583; 
bs_val[3910] = 1.258595; bs_val[3911] = 1.258607; bs_val[3912] = 1.258619; bs_val[3913] = 1.258631; bs_val[3914] = 1.258643; bs_val[3915] = 1.258655; bs_val[3916] = 1.258667; bs_val[3917] = 1.258679; bs_val[3918] = 1.258691; bs_val[3919] = 1.258703; 
bs_val[3920] = 1.258715; bs_val[3921] = 1.258727; bs_val[3922] = 1.258739; bs_val[3923] = 1.258751; bs_val[3924] = 1.258763; bs_val[3925] = 1.258775; bs_val[3926] = 1.258787; bs_val[3927] = 1.258799; bs_val[3928] = 1.258811; bs_val[3929] = 1.258823; 
bs_val[3930] = 1.258835; bs_val[3931] = 1.258847; bs_val[3932] = 1.258859; bs_val[3933] = 1.258871; bs_val[3934] = 1.258883; bs_val[3935] = 1.258895; bs_val[3936] = 1.258907; bs_val[3937] = 1.258919; bs_val[3938] = 1.258931; bs_val[3939] = 1.258943; 
bs_val[3940] = 1.258955; bs_val[3941] = 1.258967; bs_val[3942] = 1.258979; bs_val[3943] = 1.258991; bs_val[3944] = 1.259003; bs_val[3945] = 1.259015; bs_val[3946] = 1.259027; bs_val[3947] = 1.259039; bs_val[3948] = 1.259051; bs_val[3949] = 1.259063; 
bs_val[3950] = 1.259075; bs_val[3951] = 1.259087; bs_val[3952] = 1.259099; bs_val[3953] = 1.259111; bs_val[3954] = 1.259123; bs_val[3955] = 1.259135; bs_val[3956] = 1.259147; bs_val[3957] = 1.259159; bs_val[3958] = 1.259171; bs_val[3959] = 1.259183; 
bs_val[3960] = 1.259195; bs_val[3961] = 1.259207; bs_val[3962] = 1.259219; bs_val[3963] = 1.259231; bs_val[3964] = 1.259243; bs_val[3965] = 1.259255; bs_val[3966] = 1.259267; bs_val[3967] = 1.259279; bs_val[3968] = 1.259291; bs_val[3969] = 1.259303; 
bs_val[3970] = 1.259315; bs_val[3971] = 1.259327; bs_val[3972] = 1.259339; bs_val[3973] = 1.259351; bs_val[3974] = 1.259363; bs_val[3975] = 1.259375; bs_val[3976] = 1.259387; bs_val[3977] = 1.259399; bs_val[3978] = 1.259411; bs_val[3979] = 1.259423; 
bs_val[3980] = 1.259436; bs_val[3981] = 1.259448; bs_val[3982] = 1.259460; bs_val[3983] = 1.259472; bs_val[3984] = 1.259484; bs_val[3985] = 1.259496; bs_val[3986] = 1.259508; bs_val[3987] = 1.259520; bs_val[3988] = 1.259532; bs_val[3989] = 1.259544; 
bs_val[3990] = 1.259556; bs_val[3991] = 1.259568; bs_val[3992] = 1.259580; bs_val[3993] = 1.259592; bs_val[3994] = 1.259604; bs_val[3995] = 1.259616; bs_val[3996] = 1.259628; bs_val[3997] = 1.259640; bs_val[3998] = 1.259652; bs_val[3999] = 1.259664; 
bs_val[4000] = 1.259676; bs_val[4001] = 1.259688; bs_val[4002] = 1.259700; bs_val[4003] = 1.259712; bs_val[4004] = 1.259724; bs_val[4005] = 1.259736; bs_val[4006] = 1.259748; bs_val[4007] = 1.259760; bs_val[4008] = 1.259772; bs_val[4009] = 1.259784; 
bs_val[4010] = 1.259796; bs_val[4011] = 1.259808; bs_val[4012] = 1.259820; bs_val[4013] = 1.259832; bs_val[4014] = 1.259844; bs_val[4015] = 1.259856; bs_val[4016] = 1.259869; bs_val[4017] = 1.259881; bs_val[4018] = 1.259893; bs_val[4019] = 1.259905; 
bs_val[4020] = 1.259917; bs_val[4021] = 1.259929; bs_val[4022] = 1.259941; bs_val[4023] = 1.259953; bs_val[4024] = 1.259965; bs_val[4025] = 1.259977; bs_val[4026] = 1.259989; bs_val[4027] = 1.260001; bs_val[4028] = 1.260013; bs_val[4029] = 1.260025; 
bs_val[4030] = 1.260037; bs_val[4031] = 1.260049; bs_val[4032] = 1.260061; bs_val[4033] = 1.260073; bs_val[4034] = 1.260085; bs_val[4035] = 1.260097; bs_val[4036] = 1.260109; bs_val[4037] = 1.260121; bs_val[4038] = 1.260133; bs_val[4039] = 1.260145; 
bs_val[4040] = 1.260158; bs_val[4041] = 1.260170; bs_val[4042] = 1.260182; bs_val[4043] = 1.260194; bs_val[4044] = 1.260206; bs_val[4045] = 1.260218; bs_val[4046] = 1.260230; bs_val[4047] = 1.260242; bs_val[4048] = 1.260254; bs_val[4049] = 1.260266; 
bs_val[4050] = 1.260278; bs_val[4051] = 1.260290; bs_val[4052] = 1.260302; bs_val[4053] = 1.260314; bs_val[4054] = 1.260326; bs_val[4055] = 1.260338; bs_val[4056] = 1.260350; bs_val[4057] = 1.260362; bs_val[4058] = 1.260374; bs_val[4059] = 1.260387; 
bs_val[4060] = 1.260399; bs_val[4061] = 1.260411; bs_val[4062] = 1.260423; bs_val[4063] = 1.260435; bs_val[4064] = 1.260447; bs_val[4065] = 1.260459; bs_val[4066] = 1.260471; bs_val[4067] = 1.260483; bs_val[4068] = 1.260495; bs_val[4069] = 1.260507; 
bs_val[4070] = 1.260519; bs_val[4071] = 1.260531; bs_val[4072] = 1.260543; bs_val[4073] = 1.260555; bs_val[4074] = 1.260567; bs_val[4075] = 1.260580; bs_val[4076] = 1.260592; bs_val[4077] = 1.260604; bs_val[4078] = 1.260616; bs_val[4079] = 1.260628; 
bs_val[4080] = 1.260640; bs_val[4081] = 1.260652; bs_val[4082] = 1.260664; bs_val[4083] = 1.260676; bs_val[4084] = 1.260688; bs_val[4085] = 1.260700; bs_val[4086] = 1.260712; bs_val[4087] = 1.260724; bs_val[4088] = 1.260736; bs_val[4089] = 1.260749; 
bs_val[4090] = 1.260761; bs_val[4091] = 1.260773; bs_val[4092] = 1.260785; bs_val[4093] = 1.260797; bs_val[4094] = 1.260809; bs_val[4095] = 1.260821; bs_val[4096] = 1.260833; bs_val[4097] = 1.260845; bs_val[4098] = 1.260857; bs_val[4099] = 1.260869; 
bs_val[4100] = 1.260881; bs_val[4101] = 1.260893; bs_val[4102] = 1.260906; bs_val[4103] = 1.260918; bs_val[4104] = 1.260930; bs_val[4105] = 1.260942; bs_val[4106] = 1.260954; bs_val[4107] = 1.260966; bs_val[4108] = 1.260978; bs_val[4109] = 1.260990; 
bs_val[4110] = 1.261002; bs_val[4111] = 1.261014; bs_val[4112] = 1.261026; bs_val[4113] = 1.261038; bs_val[4114] = 1.261051; bs_val[4115] = 1.261063; bs_val[4116] = 1.261075; bs_val[4117] = 1.261087; bs_val[4118] = 1.261099; bs_val[4119] = 1.261111; 
bs_val[4120] = 1.261123; bs_val[4121] = 1.261135; bs_val[4122] = 1.261147; bs_val[4123] = 1.261159; bs_val[4124] = 1.261171; bs_val[4125] = 1.261184; bs_val[4126] = 1.261196; bs_val[4127] = 1.261208; bs_val[4128] = 1.261220; bs_val[4129] = 1.261232; 
bs_val[4130] = 1.261244; bs_val[4131] = 1.261256; bs_val[4132] = 1.261268; bs_val[4133] = 1.261280; bs_val[4134] = 1.261292; bs_val[4135] = 1.261305; bs_val[4136] = 1.261317; bs_val[4137] = 1.261329; bs_val[4138] = 1.261341; bs_val[4139] = 1.261353; 
bs_val[4140] = 1.261365; bs_val[4141] = 1.261377; bs_val[4142] = 1.261389; bs_val[4143] = 1.261401; bs_val[4144] = 1.261413; bs_val[4145] = 1.261426; bs_val[4146] = 1.261438; bs_val[4147] = 1.261450; bs_val[4148] = 1.261462; bs_val[4149] = 1.261474; 
bs_val[4150] = 1.261486; bs_val[4151] = 1.261498; bs_val[4152] = 1.261510; bs_val[4153] = 1.261522; bs_val[4154] = 1.261534; bs_val[4155] = 1.261547; bs_val[4156] = 1.261559; bs_val[4157] = 1.261571; bs_val[4158] = 1.261583; bs_val[4159] = 1.261595; 
bs_val[4160] = 1.261607; bs_val[4161] = 1.261619; bs_val[4162] = 1.261631; bs_val[4163] = 1.261643; bs_val[4164] = 1.261656; bs_val[4165] = 1.261668; bs_val[4166] = 1.261680; bs_val[4167] = 1.261692; bs_val[4168] = 1.261704; bs_val[4169] = 1.261716; 
bs_val[4170] = 1.261728; bs_val[4171] = 1.261740; bs_val[4172] = 1.261753; bs_val[4173] = 1.261765; bs_val[4174] = 1.261777; bs_val[4175] = 1.261789; bs_val[4176] = 1.261801; bs_val[4177] = 1.261813; bs_val[4178] = 1.261825; bs_val[4179] = 1.261837; 
bs_val[4180] = 1.261849; bs_val[4181] = 1.261862; bs_val[4182] = 1.261874; bs_val[4183] = 1.261886; bs_val[4184] = 1.261898; bs_val[4185] = 1.261910; bs_val[4186] = 1.261922; bs_val[4187] = 1.261934; bs_val[4188] = 1.261946; bs_val[4189] = 1.261959; 
bs_val[4190] = 1.261971; bs_val[4191] = 1.261983; bs_val[4192] = 1.261995; bs_val[4193] = 1.262007; bs_val[4194] = 1.262019; bs_val[4195] = 1.262031; bs_val[4196] = 1.262044; bs_val[4197] = 1.262056; bs_val[4198] = 1.262068; bs_val[4199] = 1.262080; 
bs_val[4200] = 1.262092; bs_val[4201] = 1.262104; bs_val[4202] = 1.262116; bs_val[4203] = 1.262128; bs_val[4204] = 1.262141; bs_val[4205] = 1.262153; bs_val[4206] = 1.262165; bs_val[4207] = 1.262177; bs_val[4208] = 1.262189; bs_val[4209] = 1.262201; 
bs_val[4210] = 1.262213; bs_val[4211] = 1.262226; bs_val[4212] = 1.262238; bs_val[4213] = 1.262250; bs_val[4214] = 1.262262; bs_val[4215] = 1.262274; bs_val[4216] = 1.262286; bs_val[4217] = 1.262298; bs_val[4218] = 1.262311; bs_val[4219] = 1.262323; 
bs_val[4220] = 1.262335; bs_val[4221] = 1.262347; bs_val[4222] = 1.262359; bs_val[4223] = 1.262371; bs_val[4224] = 1.262383; bs_val[4225] = 1.262396; bs_val[4226] = 1.262408; bs_val[4227] = 1.262420; bs_val[4228] = 1.262432; bs_val[4229] = 1.262444; 
bs_val[4230] = 1.262456; bs_val[4231] = 1.262468; bs_val[4232] = 1.262481; bs_val[4233] = 1.262493; bs_val[4234] = 1.262505; bs_val[4235] = 1.262517; bs_val[4236] = 1.262529; bs_val[4237] = 1.262541; bs_val[4238] = 1.262553; bs_val[4239] = 1.262566; 
bs_val[4240] = 1.262578; bs_val[4241] = 1.262590; bs_val[4242] = 1.262602; bs_val[4243] = 1.262614; bs_val[4244] = 1.262626; bs_val[4245] = 1.262639; bs_val[4246] = 1.262651; bs_val[4247] = 1.262663; bs_val[4248] = 1.262675; bs_val[4249] = 1.262687; 
bs_val[4250] = 1.262699; bs_val[4251] = 1.262712; bs_val[4252] = 1.262724; bs_val[4253] = 1.262736; bs_val[4254] = 1.262748; bs_val[4255] = 1.262760; bs_val[4256] = 1.262772; bs_val[4257] = 1.262784; bs_val[4258] = 1.262797; bs_val[4259] = 1.262809; 
bs_val[4260] = 1.262821; bs_val[4261] = 1.262833; bs_val[4262] = 1.262845; bs_val[4263] = 1.262857; bs_val[4264] = 1.262870; bs_val[4265] = 1.262882; bs_val[4266] = 1.262894; bs_val[4267] = 1.262906; bs_val[4268] = 1.262918; bs_val[4269] = 1.262930; 
bs_val[4270] = 1.262943; bs_val[4271] = 1.262955; bs_val[4272] = 1.262967; bs_val[4273] = 1.262979; bs_val[4274] = 1.262991; bs_val[4275] = 1.263004; bs_val[4276] = 1.263016; bs_val[4277] = 1.263028; bs_val[4278] = 1.263040; bs_val[4279] = 1.263052; 
bs_val[4280] = 1.263064; bs_val[4281] = 1.263077; bs_val[4282] = 1.263089; bs_val[4283] = 1.263101; bs_val[4284] = 1.263113; bs_val[4285] = 1.263125; bs_val[4286] = 1.263137; bs_val[4287] = 1.263150; bs_val[4288] = 1.263162; bs_val[4289] = 1.263174; 
bs_val[4290] = 1.263186; bs_val[4291] = 1.263198; bs_val[4292] = 1.263211; bs_val[4293] = 1.263223; bs_val[4294] = 1.263235; bs_val[4295] = 1.263247; bs_val[4296] = 1.263259; bs_val[4297] = 1.263271; bs_val[4298] = 1.263284; bs_val[4299] = 1.263296; 
bs_val[4300] = 1.263308; bs_val[4301] = 1.263320; bs_val[4302] = 1.263332; bs_val[4303] = 1.263345; bs_val[4304] = 1.263357; bs_val[4305] = 1.263369; bs_val[4306] = 1.263381; bs_val[4307] = 1.263393; bs_val[4308] = 1.263406; bs_val[4309] = 1.263418; 
bs_val[4310] = 1.263430; bs_val[4311] = 1.263442; bs_val[4312] = 1.263454; bs_val[4313] = 1.263466; bs_val[4314] = 1.263479; bs_val[4315] = 1.263491; bs_val[4316] = 1.263503; bs_val[4317] = 1.263515; bs_val[4318] = 1.263527; bs_val[4319] = 1.263540; 
bs_val[4320] = 1.263552; bs_val[4321] = 1.263564; bs_val[4322] = 1.263576; bs_val[4323] = 1.263588; bs_val[4324] = 1.263601; bs_val[4325] = 1.263613; bs_val[4326] = 1.263625; bs_val[4327] = 1.263637; bs_val[4328] = 1.263649; bs_val[4329] = 1.263662; 
bs_val[4330] = 1.263674; bs_val[4331] = 1.263686; bs_val[4332] = 1.263698; bs_val[4333] = 1.263710; bs_val[4334] = 1.263723; bs_val[4335] = 1.263735; bs_val[4336] = 1.263747; bs_val[4337] = 1.263759; bs_val[4338] = 1.263772; bs_val[4339] = 1.263784; 
bs_val[4340] = 1.263796; bs_val[4341] = 1.263808; bs_val[4342] = 1.263820; bs_val[4343] = 1.263833; bs_val[4344] = 1.263845; bs_val[4345] = 1.263857; bs_val[4346] = 1.263869; bs_val[4347] = 1.263881; bs_val[4348] = 1.263894; bs_val[4349] = 1.263906; 
bs_val[4350] = 1.263918; bs_val[4351] = 1.263930; bs_val[4352] = 1.263942; bs_val[4353] = 1.263955; bs_val[4354] = 1.263967; bs_val[4355] = 1.263979; bs_val[4356] = 1.263991; bs_val[4357] = 1.264004; bs_val[4358] = 1.264016; bs_val[4359] = 1.264028; 
bs_val[4360] = 1.264040; bs_val[4361] = 1.264052; bs_val[4362] = 1.264065; bs_val[4363] = 1.264077; bs_val[4364] = 1.264089; bs_val[4365] = 1.264101; bs_val[4366] = 1.264114; bs_val[4367] = 1.264126; bs_val[4368] = 1.264138; bs_val[4369] = 1.264150; 
bs_val[4370] = 1.264162; bs_val[4371] = 1.264175; bs_val[4372] = 1.264187; bs_val[4373] = 1.264199; bs_val[4374] = 1.264211; bs_val[4375] = 1.264224; bs_val[4376] = 1.264236; bs_val[4377] = 1.264248; bs_val[4378] = 1.264260; bs_val[4379] = 1.264273; 
bs_val[4380] = 1.264285; bs_val[4381] = 1.264297; bs_val[4382] = 1.264309; bs_val[4383] = 1.264321; bs_val[4384] = 1.264334; bs_val[4385] = 1.264346; bs_val[4386] = 1.264358; bs_val[4387] = 1.264370; bs_val[4388] = 1.264383; bs_val[4389] = 1.264395; 
bs_val[4390] = 1.264407; bs_val[4391] = 1.264419; bs_val[4392] = 1.264432; bs_val[4393] = 1.264444; bs_val[4394] = 1.264456; bs_val[4395] = 1.264468; bs_val[4396] = 1.264481; bs_val[4397] = 1.264493; bs_val[4398] = 1.264505; bs_val[4399] = 1.264517; 
bs_val[4400] = 1.264529; bs_val[4401] = 1.264542; bs_val[4402] = 1.264554; bs_val[4403] = 1.264566; bs_val[4404] = 1.264578; bs_val[4405] = 1.264591; bs_val[4406] = 1.264603; bs_val[4407] = 1.264615; bs_val[4408] = 1.264627; bs_val[4409] = 1.264640; 
bs_val[4410] = 1.264652; bs_val[4411] = 1.264664; bs_val[4412] = 1.264676; bs_val[4413] = 1.264689; bs_val[4414] = 1.264701; bs_val[4415] = 1.264713; bs_val[4416] = 1.264725; bs_val[4417] = 1.264738; bs_val[4418] = 1.264750; bs_val[4419] = 1.264762; 
bs_val[4420] = 1.264774; bs_val[4421] = 1.264787; bs_val[4422] = 1.264799; bs_val[4423] = 1.264811; bs_val[4424] = 1.264823; bs_val[4425] = 1.264836; bs_val[4426] = 1.264848; bs_val[4427] = 1.264860; bs_val[4428] = 1.264872; bs_val[4429] = 1.264885; 
bs_val[4430] = 1.264897; bs_val[4431] = 1.264909; bs_val[4432] = 1.264922; bs_val[4433] = 1.264934; bs_val[4434] = 1.264946; bs_val[4435] = 1.264958; bs_val[4436] = 1.264971; bs_val[4437] = 1.264983; bs_val[4438] = 1.264995; bs_val[4439] = 1.265007; 
bs_val[4440] = 1.265020; bs_val[4441] = 1.265032; bs_val[4442] = 1.265044; bs_val[4443] = 1.265056; bs_val[4444] = 1.265069; bs_val[4445] = 1.265081; bs_val[4446] = 1.265093; bs_val[4447] = 1.265105; bs_val[4448] = 1.265118; bs_val[4449] = 1.265130; 
bs_val[4450] = 1.265142; bs_val[4451] = 1.265155; bs_val[4452] = 1.265167; bs_val[4453] = 1.265179; bs_val[4454] = 1.265191; bs_val[4455] = 1.265204; bs_val[4456] = 1.265216; bs_val[4457] = 1.265228; bs_val[4458] = 1.265240; bs_val[4459] = 1.265253; 
bs_val[4460] = 1.265265; bs_val[4461] = 1.265277; bs_val[4462] = 1.265290; bs_val[4463] = 1.265302; bs_val[4464] = 1.265314; bs_val[4465] = 1.265326; bs_val[4466] = 1.265339; bs_val[4467] = 1.265351; bs_val[4468] = 1.265363; bs_val[4469] = 1.265376; 
bs_val[4470] = 1.265388; bs_val[4471] = 1.265400; bs_val[4472] = 1.265412; bs_val[4473] = 1.265425; bs_val[4474] = 1.265437; bs_val[4475] = 1.265449; bs_val[4476] = 1.265462; bs_val[4477] = 1.265474; bs_val[4478] = 1.265486; bs_val[4479] = 1.265498; 
bs_val[4480] = 1.265511; bs_val[4481] = 1.265523; bs_val[4482] = 1.265535; bs_val[4483] = 1.265548; bs_val[4484] = 1.265560; bs_val[4485] = 1.265572; bs_val[4486] = 1.265584; bs_val[4487] = 1.265597; bs_val[4488] = 1.265609; bs_val[4489] = 1.265621; 
bs_val[4490] = 1.265634; bs_val[4491] = 1.265646; bs_val[4492] = 1.265658; bs_val[4493] = 1.265670; bs_val[4494] = 1.265683; bs_val[4495] = 1.265695; bs_val[4496] = 1.265707; bs_val[4497] = 1.265720; bs_val[4498] = 1.265732; bs_val[4499] = 1.265744; 
bs_val[4500] = 1.265757; bs_val[4501] = 1.265769; bs_val[4502] = 1.265781; bs_val[4503] = 1.265793; bs_val[4504] = 1.265806; bs_val[4505] = 1.265818; bs_val[4506] = 1.265830; bs_val[4507] = 1.265843; bs_val[4508] = 1.265855; bs_val[4509] = 1.265867; 
bs_val[4510] = 1.265880; bs_val[4511] = 1.265892; bs_val[4512] = 1.265904; bs_val[4513] = 1.265917; bs_val[4514] = 1.265929; bs_val[4515] = 1.265941; bs_val[4516] = 1.265953; bs_val[4517] = 1.265966; bs_val[4518] = 1.265978; bs_val[4519] = 1.265990; 
bs_val[4520] = 1.266003; bs_val[4521] = 1.266015; bs_val[4522] = 1.266027; bs_val[4523] = 1.266040; bs_val[4524] = 1.266052; bs_val[4525] = 1.266064; bs_val[4526] = 1.266077; bs_val[4527] = 1.266089; bs_val[4528] = 1.266101; bs_val[4529] = 1.266114; 
bs_val[4530] = 1.266126; bs_val[4531] = 1.266138; bs_val[4532] = 1.266150; bs_val[4533] = 1.266163; bs_val[4534] = 1.266175; bs_val[4535] = 1.266187; bs_val[4536] = 1.266200; bs_val[4537] = 1.266212; bs_val[4538] = 1.266224; bs_val[4539] = 1.266237; 
bs_val[4540] = 1.266249; bs_val[4541] = 1.266261; bs_val[4542] = 1.266274; bs_val[4543] = 1.266286; bs_val[4544] = 1.266298; bs_val[4545] = 1.266311; bs_val[4546] = 1.266323; bs_val[4547] = 1.266335; bs_val[4548] = 1.266348; bs_val[4549] = 1.266360; 
bs_val[4550] = 1.266372; bs_val[4551] = 1.266385; bs_val[4552] = 1.266397; bs_val[4553] = 1.266409; bs_val[4554] = 1.266422; bs_val[4555] = 1.266434; bs_val[4556] = 1.266446; bs_val[4557] = 1.266459; bs_val[4558] = 1.266471; bs_val[4559] = 1.266483; 
bs_val[4560] = 1.266496; bs_val[4561] = 1.266508; bs_val[4562] = 1.266520; bs_val[4563] = 1.266533; bs_val[4564] = 1.266545; bs_val[4565] = 1.266557; bs_val[4566] = 1.266570; bs_val[4567] = 1.266582; bs_val[4568] = 1.266594; bs_val[4569] = 1.266607; 
bs_val[4570] = 1.266619; bs_val[4571] = 1.266631; bs_val[4572] = 1.266644; bs_val[4573] = 1.266656; bs_val[4574] = 1.266668; bs_val[4575] = 1.266681; bs_val[4576] = 1.266693; bs_val[4577] = 1.266705; bs_val[4578] = 1.266718; bs_val[4579] = 1.266730; 
bs_val[4580] = 1.266742; bs_val[4581] = 1.266755; bs_val[4582] = 1.266767; bs_val[4583] = 1.266779; bs_val[4584] = 1.266792; bs_val[4585] = 1.266804; bs_val[4586] = 1.266817; bs_val[4587] = 1.266829; bs_val[4588] = 1.266841; bs_val[4589] = 1.266854; 
bs_val[4590] = 1.266866; bs_val[4591] = 1.266878; bs_val[4592] = 1.266891; bs_val[4593] = 1.266903; bs_val[4594] = 1.266915; bs_val[4595] = 1.266928; bs_val[4596] = 1.266940; bs_val[4597] = 1.266952; bs_val[4598] = 1.266965; bs_val[4599] = 1.266977; 
bs_val[4600] = 1.266990; bs_val[4601] = 1.267002; bs_val[4602] = 1.267014; bs_val[4603] = 1.267027; bs_val[4604] = 1.267039; bs_val[4605] = 1.267051; bs_val[4606] = 1.267064; bs_val[4607] = 1.267076; bs_val[4608] = 1.267088; bs_val[4609] = 1.267101; 
bs_val[4610] = 1.267113; bs_val[4611] = 1.267125; bs_val[4612] = 1.267138; bs_val[4613] = 1.267150; bs_val[4614] = 1.267163; bs_val[4615] = 1.267175; bs_val[4616] = 1.267187; bs_val[4617] = 1.267200; bs_val[4618] = 1.267212; bs_val[4619] = 1.267224; 
bs_val[4620] = 1.267237; bs_val[4621] = 1.267249; bs_val[4622] = 1.267262; bs_val[4623] = 1.267274; bs_val[4624] = 1.267286; bs_val[4625] = 1.267299; bs_val[4626] = 1.267311; bs_val[4627] = 1.267323; bs_val[4628] = 1.267336; bs_val[4629] = 1.267348; 
bs_val[4630] = 1.267361; bs_val[4631] = 1.267373; bs_val[4632] = 1.267385; bs_val[4633] = 1.267398; bs_val[4634] = 1.267410; bs_val[4635] = 1.267422; bs_val[4636] = 1.267435; bs_val[4637] = 1.267447; bs_val[4638] = 1.267460; bs_val[4639] = 1.267472; 
bs_val[4640] = 1.267484; bs_val[4641] = 1.267497; bs_val[4642] = 1.267509; bs_val[4643] = 1.267522; bs_val[4644] = 1.267534; bs_val[4645] = 1.267546; bs_val[4646] = 1.267559; bs_val[4647] = 1.267571; bs_val[4648] = 1.267583; bs_val[4649] = 1.267596; 
bs_val[4650] = 1.267608; bs_val[4651] = 1.267621; bs_val[4652] = 1.267633; bs_val[4653] = 1.267645; bs_val[4654] = 1.267658; bs_val[4655] = 1.267670; bs_val[4656] = 1.267683; bs_val[4657] = 1.267695; bs_val[4658] = 1.267707; bs_val[4659] = 1.267720; 
bs_val[4660] = 1.267732; bs_val[4661] = 1.267745; bs_val[4662] = 1.267757; bs_val[4663] = 1.267769; bs_val[4664] = 1.267782; bs_val[4665] = 1.267794; bs_val[4666] = 1.267807; bs_val[4667] = 1.267819; bs_val[4668] = 1.267831; bs_val[4669] = 1.267844; 
bs_val[4670] = 1.267856; bs_val[4671] = 1.267869; bs_val[4672] = 1.267881; bs_val[4673] = 1.267893; bs_val[4674] = 1.267906; bs_val[4675] = 1.267918; bs_val[4676] = 1.267931; bs_val[4677] = 1.267943; bs_val[4678] = 1.267955; bs_val[4679] = 1.267968; 
bs_val[4680] = 1.267980; bs_val[4681] = 1.267993; bs_val[4682] = 1.268005; bs_val[4683] = 1.268017; bs_val[4684] = 1.268030; bs_val[4685] = 1.268042; bs_val[4686] = 1.268055; bs_val[4687] = 1.268067; bs_val[4688] = 1.268079; bs_val[4689] = 1.268092; 
bs_val[4690] = 1.268104; bs_val[4691] = 1.268117; bs_val[4692] = 1.268129; bs_val[4693] = 1.268142; bs_val[4694] = 1.268154; bs_val[4695] = 1.268166; bs_val[4696] = 1.268179; bs_val[4697] = 1.268191; bs_val[4698] = 1.268204; bs_val[4699] = 1.268216; 
bs_val[4700] = 1.268228; bs_val[4701] = 1.268241; bs_val[4702] = 1.268253; bs_val[4703] = 1.268266; bs_val[4704] = 1.268278; bs_val[4705] = 1.268291; bs_val[4706] = 1.268303; bs_val[4707] = 1.268315; bs_val[4708] = 1.268328; bs_val[4709] = 1.268340; 
bs_val[4710] = 1.268353; bs_val[4711] = 1.268365; bs_val[4712] = 1.268378; bs_val[4713] = 1.268390; bs_val[4714] = 1.268402; bs_val[4715] = 1.268415; bs_val[4716] = 1.268427; bs_val[4717] = 1.268440; bs_val[4718] = 1.268452; bs_val[4719] = 1.268465; 
bs_val[4720] = 1.268477; bs_val[4721] = 1.268489; bs_val[4722] = 1.268502; bs_val[4723] = 1.268514; bs_val[4724] = 1.268527; bs_val[4725] = 1.268539; bs_val[4726] = 1.268552; bs_val[4727] = 1.268564; bs_val[4728] = 1.268577; bs_val[4729] = 1.268589; 
bs_val[4730] = 1.268601; bs_val[4731] = 1.268614; bs_val[4732] = 1.268626; bs_val[4733] = 1.268639; bs_val[4734] = 1.268651; bs_val[4735] = 1.268664; bs_val[4736] = 1.268676; bs_val[4737] = 1.268688; bs_val[4738] = 1.268701; bs_val[4739] = 1.268713; 
bs_val[4740] = 1.268726; bs_val[4741] = 1.268738; bs_val[4742] = 1.268751; bs_val[4743] = 1.268763; bs_val[4744] = 1.268776; bs_val[4745] = 1.268788; bs_val[4746] = 1.268801; bs_val[4747] = 1.268813; bs_val[4748] = 1.268825; bs_val[4749] = 1.268838; 
bs_val[4750] = 1.268850; bs_val[4751] = 1.268863; bs_val[4752] = 1.268875; bs_val[4753] = 1.268888; bs_val[4754] = 1.268900; bs_val[4755] = 1.268913; bs_val[4756] = 1.268925; bs_val[4757] = 1.268937; bs_val[4758] = 1.268950; bs_val[4759] = 1.268962; 
bs_val[4760] = 1.268975; bs_val[4761] = 1.268987; bs_val[4762] = 1.269000; bs_val[4763] = 1.269012; bs_val[4764] = 1.269025; bs_val[4765] = 1.269037; bs_val[4766] = 1.269050; bs_val[4767] = 1.269062; bs_val[4768] = 1.269075; bs_val[4769] = 1.269087; 
bs_val[4770] = 1.269099; bs_val[4771] = 1.269112; bs_val[4772] = 1.269124; bs_val[4773] = 1.269137; bs_val[4774] = 1.269149; bs_val[4775] = 1.269162; bs_val[4776] = 1.269174; bs_val[4777] = 1.269187; bs_val[4778] = 1.269199; bs_val[4779] = 1.269212; 
bs_val[4780] = 1.269224; bs_val[4781] = 1.269237; bs_val[4782] = 1.269249; bs_val[4783] = 1.269262; bs_val[4784] = 1.269274; bs_val[4785] = 1.269287; bs_val[4786] = 1.269299; bs_val[4787] = 1.269312; bs_val[4788] = 1.269324; bs_val[4789] = 1.269336; 
bs_val[4790] = 1.269349; bs_val[4791] = 1.269361; bs_val[4792] = 1.269374; bs_val[4793] = 1.269386; bs_val[4794] = 1.269399; bs_val[4795] = 1.269411; bs_val[4796] = 1.269424; bs_val[4797] = 1.269436; bs_val[4798] = 1.269449; bs_val[4799] = 1.269461; 
bs_val[4800] = 1.269474; bs_val[4801] = 1.269486; bs_val[4802] = 1.269499; bs_val[4803] = 1.269511; bs_val[4804] = 1.269524; bs_val[4805] = 1.269536; bs_val[4806] = 1.269549; bs_val[4807] = 1.269561; bs_val[4808] = 1.269574; bs_val[4809] = 1.269586; 
bs_val[4810] = 1.269599; bs_val[4811] = 1.269611; bs_val[4812] = 1.269624; bs_val[4813] = 1.269636; bs_val[4814] = 1.269649; bs_val[4815] = 1.269661; bs_val[4816] = 1.269674; bs_val[4817] = 1.269686; bs_val[4818] = 1.269699; bs_val[4819] = 1.269711; 
bs_val[4820] = 1.269724; bs_val[4821] = 1.269736; bs_val[4822] = 1.269749; bs_val[4823] = 1.269761; bs_val[4824] = 1.269774; bs_val[4825] = 1.269786; bs_val[4826] = 1.269799; bs_val[4827] = 1.269811; bs_val[4828] = 1.269824; bs_val[4829] = 1.269836; 
bs_val[4830] = 1.269849; bs_val[4831] = 1.269861; bs_val[4832] = 1.269874; bs_val[4833] = 1.269886; bs_val[4834] = 1.269899; bs_val[4835] = 1.269911; bs_val[4836] = 1.269924; bs_val[4837] = 1.269936; bs_val[4838] = 1.269949; bs_val[4839] = 1.269961; 
bs_val[4840] = 1.269974; bs_val[4841] = 1.269986; bs_val[4842] = 1.269999; bs_val[4843] = 1.270011; bs_val[4844] = 1.270024; bs_val[4845] = 1.270036; bs_val[4846] = 1.270049; bs_val[4847] = 1.270061; bs_val[4848] = 1.270074; bs_val[4849] = 1.270086; 
bs_val[4850] = 1.270099; bs_val[4851] = 1.270111; bs_val[4852] = 1.270124; bs_val[4853] = 1.270136; bs_val[4854] = 1.270149; bs_val[4855] = 1.270162; bs_val[4856] = 1.270174; bs_val[4857] = 1.270187; bs_val[4858] = 1.270199; bs_val[4859] = 1.270212; 
bs_val[4860] = 1.270224; bs_val[4861] = 1.270237; bs_val[4862] = 1.270249; bs_val[4863] = 1.270262; bs_val[4864] = 1.270274; bs_val[4865] = 1.270287; bs_val[4866] = 1.270299; bs_val[4867] = 1.270312; bs_val[4868] = 1.270324; bs_val[4869] = 1.270337; 
bs_val[4870] = 1.270349; bs_val[4871] = 1.270362; bs_val[4872] = 1.270374; bs_val[4873] = 1.270387; bs_val[4874] = 1.270400; bs_val[4875] = 1.270412; bs_val[4876] = 1.270425; bs_val[4877] = 1.270437; bs_val[4878] = 1.270450; bs_val[4879] = 1.270462; 
bs_val[4880] = 1.270475; bs_val[4881] = 1.270487; bs_val[4882] = 1.270500; bs_val[4883] = 1.270512; bs_val[4884] = 1.270525; bs_val[4885] = 1.270538; bs_val[4886] = 1.270550; bs_val[4887] = 1.270563; bs_val[4888] = 1.270575; bs_val[4889] = 1.270588; 
bs_val[4890] = 1.270600; bs_val[4891] = 1.270613; bs_val[4892] = 1.270625; bs_val[4893] = 1.270638; bs_val[4894] = 1.270650; bs_val[4895] = 1.270663; bs_val[4896] = 1.270676; bs_val[4897] = 1.270688; bs_val[4898] = 1.270701; bs_val[4899] = 1.270713; 
bs_val[4900] = 1.270726; bs_val[4901] = 1.270738; bs_val[4902] = 1.270751; bs_val[4903] = 1.270763; bs_val[4904] = 1.270776; bs_val[4905] = 1.270789; bs_val[4906] = 1.270801; bs_val[4907] = 1.270814; bs_val[4908] = 1.270826; bs_val[4909] = 1.270839; 
bs_val[4910] = 1.270851; bs_val[4911] = 1.270864; bs_val[4912] = 1.270876; bs_val[4913] = 1.270889; bs_val[4914] = 1.270902; bs_val[4915] = 1.270914; bs_val[4916] = 1.270927; bs_val[4917] = 1.270939; bs_val[4918] = 1.270952; bs_val[4919] = 1.270964; 
bs_val[4920] = 1.270977; bs_val[4921] = 1.270990; bs_val[4922] = 1.271002; bs_val[4923] = 1.271015; bs_val[4924] = 1.271027; bs_val[4925] = 1.271040; bs_val[4926] = 1.271052; bs_val[4927] = 1.271065; bs_val[4928] = 1.271078; bs_val[4929] = 1.271090; 
bs_val[4930] = 1.271103; bs_val[4931] = 1.271115; bs_val[4932] = 1.271128; bs_val[4933] = 1.271140; bs_val[4934] = 1.271153; bs_val[4935] = 1.271166; bs_val[4936] = 1.271178; bs_val[4937] = 1.271191; bs_val[4938] = 1.271203; bs_val[4939] = 1.271216; 
bs_val[4940] = 1.271229; bs_val[4941] = 1.271241; bs_val[4942] = 1.271254; bs_val[4943] = 1.271266; bs_val[4944] = 1.271279; bs_val[4945] = 1.271291; bs_val[4946] = 1.271304; bs_val[4947] = 1.271317; bs_val[4948] = 1.271329; bs_val[4949] = 1.271342; 
bs_val[4950] = 1.271354; bs_val[4951] = 1.271367; bs_val[4952] = 1.271380; bs_val[4953] = 1.271392; bs_val[4954] = 1.271405; bs_val[4955] = 1.271417; bs_val[4956] = 1.271430; bs_val[4957] = 1.271443; bs_val[4958] = 1.271455; bs_val[4959] = 1.271468; 
bs_val[4960] = 1.271480; bs_val[4961] = 1.271493; bs_val[4962] = 1.271506; bs_val[4963] = 1.271518; bs_val[4964] = 1.271531; bs_val[4965] = 1.271543; bs_val[4966] = 1.271556; bs_val[4967] = 1.271569; bs_val[4968] = 1.271581; bs_val[4969] = 1.271594; 
bs_val[4970] = 1.271606; bs_val[4971] = 1.271619; bs_val[4972] = 1.271632; bs_val[4973] = 1.271644; bs_val[4974] = 1.271657; bs_val[4975] = 1.271669; bs_val[4976] = 1.271682; bs_val[4977] = 1.271695; bs_val[4978] = 1.271707; bs_val[4979] = 1.271720; 
bs_val[4980] = 1.271732; bs_val[4981] = 1.271745; bs_val[4982] = 1.271758; bs_val[4983] = 1.271770; bs_val[4984] = 1.271783; bs_val[4985] = 1.271796; bs_val[4986] = 1.271808; bs_val[4987] = 1.271821; bs_val[4988] = 1.271833; bs_val[4989] = 1.271846; 
bs_val[4990] = 1.271859; bs_val[4991] = 1.271871; bs_val[4992] = 1.271884; bs_val[4993] = 1.271897; bs_val[4994] = 1.271909; bs_val[4995] = 1.271922; bs_val[4996] = 1.271934; bs_val[4997] = 1.271947; bs_val[4998] = 1.271960; bs_val[4999] = 1.271972; 
bs_val[5000] = 1.271985; bs_val[5001] = 1.271998; bs_val[5002] = 1.272010; bs_val[5003] = 1.272023; bs_val[5004] = 1.272035; bs_val[5005] = 1.272048; bs_val[5006] = 1.272061; bs_val[5007] = 1.272073; bs_val[5008] = 1.272086; bs_val[5009] = 1.272099; 
bs_val[5010] = 1.272111; bs_val[5011] = 1.272124; bs_val[5012] = 1.272137; bs_val[5013] = 1.272149; bs_val[5014] = 1.272162; bs_val[5015] = 1.272174; bs_val[5016] = 1.272187; bs_val[5017] = 1.272200; bs_val[5018] = 1.272212; bs_val[5019] = 1.272225; 
bs_val[5020] = 1.272238; bs_val[5021] = 1.272250; bs_val[5022] = 1.272263; bs_val[5023] = 1.272276; bs_val[5024] = 1.272288; bs_val[5025] = 1.272301; bs_val[5026] = 1.272314; bs_val[5027] = 1.272326; bs_val[5028] = 1.272339; bs_val[5029] = 1.272352; 
bs_val[5030] = 1.272364; bs_val[5031] = 1.272377; bs_val[5032] = 1.272389; bs_val[5033] = 1.272402; bs_val[5034] = 1.272415; bs_val[5035] = 1.272427; bs_val[5036] = 1.272440; bs_val[5037] = 1.272453; bs_val[5038] = 1.272465; bs_val[5039] = 1.272478; 
bs_val[5040] = 1.272491; bs_val[5041] = 1.272503; bs_val[5042] = 1.272516; bs_val[5043] = 1.272529; bs_val[5044] = 1.272541; bs_val[5045] = 1.272554; bs_val[5046] = 1.272567; bs_val[5047] = 1.272579; bs_val[5048] = 1.272592; bs_val[5049] = 1.272605; 
bs_val[5050] = 1.272617; bs_val[5051] = 1.272630; bs_val[5052] = 1.272643; bs_val[5053] = 1.272655; bs_val[5054] = 1.272668; bs_val[5055] = 1.272681; bs_val[5056] = 1.272694; bs_val[5057] = 1.272706; bs_val[5058] = 1.272719; bs_val[5059] = 1.272732; 
bs_val[5060] = 1.272744; bs_val[5061] = 1.272757; bs_val[5062] = 1.272770; bs_val[5063] = 1.272782; bs_val[5064] = 1.272795; bs_val[5065] = 1.272808; bs_val[5066] = 1.272820; bs_val[5067] = 1.272833; bs_val[5068] = 1.272846; bs_val[5069] = 1.272858; 
bs_val[5070] = 1.272871; bs_val[5071] = 1.272884; bs_val[5072] = 1.272896; bs_val[5073] = 1.272909; bs_val[5074] = 1.272922; bs_val[5075] = 1.272935; bs_val[5076] = 1.272947; bs_val[5077] = 1.272960; bs_val[5078] = 1.272973; bs_val[5079] = 1.272985; 
bs_val[5080] = 1.272998; bs_val[5081] = 1.273011; bs_val[5082] = 1.273023; bs_val[5083] = 1.273036; bs_val[5084] = 1.273049; bs_val[5085] = 1.273062; bs_val[5086] = 1.273074; bs_val[5087] = 1.273087; bs_val[5088] = 1.273100; bs_val[5089] = 1.273112; 
bs_val[5090] = 1.273125; bs_val[5091] = 1.273138; bs_val[5092] = 1.273151; bs_val[5093] = 1.273163; bs_val[5094] = 1.273176; bs_val[5095] = 1.273189; bs_val[5096] = 1.273201; bs_val[5097] = 1.273214; bs_val[5098] = 1.273227; bs_val[5099] = 1.273240; 

  return 1;
}
