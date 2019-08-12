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

File  : freeman_2components_reconstruction.c
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

Description :  Freeman 2 Components reconstruction

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
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  
/* Internal variables */
  int ii, lig, col;
  int ligDone = 0;

  float Span, SpanMin, SpanMax;
  float CC11, CC13_re, CC13_im, CC22, CC33;
  float HHHH,HVHV,VVVV;
  float HHVVre,HHVVim;
  float FV, FG, RHO;
  float x,y,z1,z2r,z2i,z3r,z3i;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float ***M_grd;
  float ***M_vol;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nfreeman_2components_reconstruction.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od1 	output directory - ground\n");
strcat(UsageHelp," (string)	-od2 	output directory - volume\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od1",str_cmd_prm,out_dir1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od2",str_cmd_prm,out_dir2,1,UsageHelp);
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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir1);
  check_dir(out_dir2);
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

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir1, file_name_out1);
  init_file_name(PolTypeOut, out_dir2, file_name_out2);

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

  /* Mgrd = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
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
  M_grd = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_vol = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);

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

CC11 = CC13_re = CC13_im = CC22 = CC33 = 0.;
HHHH = HVHV = VVVV = HHVVre = HHVVim = FV = FG = RHO = 0.;
x = y = z1 = z2r = z2i = z3r = z3i = 0.; 
#pragma omp parallel for private(col, Np, M_avg) firstprivate(CC11, CC13_re, CC13_im, CC22, CC33, HHHH,HVHV,VVVV, HHVVre,HHVVim, FV, FG, RHO, x,y,z1,z2r,z2i,z3r,z3i) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      for (Np = 0; Np < NpolarOut; Np++) M_grd[Np][lig][col] = 0.;
      for (Np = 0; Np < NpolarOut; Np++) M_vol[Np][lig][col] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        CC11 = M_avg[C311][col];
        CC13_re = M_avg[C313_re][col];
        CC13_im = M_avg[C313_im][col];
        CC22 = M_avg[C322][col];
        CC33 = M_avg[C333][col];

        HHHH = CC11; HVHV = CC22 / 2.; VVVV = CC33;
        HHVVre = CC13_re; HHVVim = CC13_im;

        /*Freeman - 2 Components algorithm*/

        z1 = HHHH - VVVV;
        z2r = 2.*HVHV + HHVVre - HHHH;
        z2i = HHVVim;

        if (z1 == 0.) z1 = eps;
        z3r = z2r / z1; z3i = z2i / z1;
        if (z3r == 0.) {
          z3r = eps; z3i = 0.;
          }

        y = -(z3i*(1. + 2.*z3r)) / (z3r*z3r + z3i*z3i);
        x = 1. + (y*z3r / z3i);
    
        FG = z1 / (1. - x*x - y*y);
        FV = HHHH - FG;
        RHO = 1. - (2.*HVHV / FV);

        M_grd[C311][lig][col] = FG;
        M_grd[C312_re][lig][col] = 0.; M_grd[C312_im][lig][col] = 0.;
        M_grd[C313_re][lig][col] = FG * x; M_grd[C313_im][lig][col] = FG * y;
        M_grd[C322][lig][col] = 0.;
        M_grd[C323_re][lig][col] = 0.; M_grd[C323_im][lig][col] = 0.;
        M_grd[C333][lig][col] = FG * (x*x + y*y);

        M_vol[C311][lig][col] = FV;
        M_vol[C312_re][lig][col] = 0.; M_vol[C312_im][lig][col] = 0.;
        M_vol[C313_re][lig][col] = FV * RHO; M_vol[C313_im][lig][col] = 0.;
        M_vol[C322][lig][col] = FV * (1. - RHO);
        M_vol[C323_re][lig][col] = 0.; M_vol[C323_im][lig][col] = 0.;
        M_vol[C333][lig][col] = FV;

        for (Np = 0; Np < NpolarOut; Np++) {
          if (M_grd[Np][lig][col] < SpanMin) M_grd[Np][lig][col] = SpanMin;
          if (M_grd[Np][lig][col] > SpanMax) M_grd[Np][lig][col] = SpanMax;

          if (M_vol[Np][lig][col] < SpanMin) M_vol[Np][lig][col] = SpanMin;
          if (M_vol[Np][lig][col] > SpanMax) M_vol[Np][lig][col] = SpanMax;
          }
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    }

  if (strcmp(PolTypeOut,"T3")==0) {
    C3_to_T3(M_grd, NligBlock[Nb], Sub_Ncol, 0, 0);
    C3_to_T3(M_vol, NligBlock[Nb], Sub_Ncol, 0, 0);
    }

  write_block_matrix3d_float(out_datafile1, NpolarOut, M_grd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix3d_float(out_datafile2, NpolarOut, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_grd, NpolarOut, NligBlock[0]);
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
  
/********************************************************************
********************************************************************/

  return 1;
}


