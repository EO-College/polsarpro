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

File  : yamaguchi_4components_decomposition.c
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

Description :  Yamaguchi 4 components Decomposition

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
int unitary_rotation(float *TT, float teta);

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
  FILE *out_odd, *out_dbl, *out_vol, *out_hlx;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  char YamMode[5];
  
/* Internal variables */
  int ii, lig, col;
  int HV_type;
  int ligDone = 0;

  float Span, SpanMin, SpanMax;
  float FS, FD, FV;
  float ALPre, ALPim, BETre, BETim;
  float HHHH,HVHV,VVVV;
  float HHVVre,HHVVim;
  float rtemp, ratio;
  float S, D, Cre, Cim, CO, C1;
  float teta;
  float Ps, Pd, Pv, Pc, TP;
  
/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_odd;
  float **M_dbl;
  float **M_vol;
  float **M_hlx;
  float *TT;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nyamaguchi_4components_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-mod 	decomposition mode (Y4O, Y4R, S4R)\n");
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
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mod",str_cmd_prm,YamMode,1,UsageHelp);
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
  sprintf(file_name, "%sYamaguchi4_%s_Odd.bin", out_dir, YamMode);
  if ((out_odd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%sYamaguchi4_%s_Dbl.bin", out_dir, YamMode);
  if ((out_dbl = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%sYamaguchi4_%s_Vol.bin", out_dir, YamMode);
  if ((out_vol = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%sYamaguchi4_%s_Hlx.bin", out_dir, YamMode);
  if ((out_hlx = fopen(file_name, "wb")) == NULL)
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
  /* Mhlx = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB = 0;
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
  M_hlx = matrix_float(NligBlock[0], Sub_Ncol);

  //TT = vector_float(NpolarOut);
  
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
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

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
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

HV_type = 0;
FS = FD = FV = ALPre = ALPim = BETre = BETim = 0.;
HHHH = HVHV = VVVV = HHVVre = HHVVim = 0.;
rtemp = ratio = S = D = Cre = Cim = CO = C1 = teta = 0.;
Ps = Pd = Pv = Pc = TP = 0.;
#pragma omp parallel for private(col, Np, TT, M_avg) firstprivate(HV_type, FS, FD, FV, ALPre, ALPim, BETre, BETim, HHHH, HVHV, VVVV, HHVVre, HHVVim, rtemp, ratio, S, D, Cre, Cim, CO, C1, teta, Ps, Pd, Pv, Pc, TP) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = vector_float(NpolarOut);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        for (Np = 0; Np < NpolarOut; Np++) TT[Np] = M_avg[Np][col];
        teta = 0.;        
        if ((strcmp(YamMode,"Y4R")==0)||(strcmp(YamMode,"S4R")==0)) {
          teta = 0.5 * atan(2*TT[T323_re]/(TT[T322]-TT[T333]));
          unitary_rotation(TT,teta);
          }
          
        Pc = 2. * fabs(TT[T323_im]);

        HV_type = 1; /* Surface scattering */
        
        if (strcmp(YamMode,"S4R")==0) {
          C1 = TT[T311] - TT[T322] + (7./8.)*TT[T333] + (Pc/16.);
          if (C1 > 0.) {
            HV_type = 1; /* Surface scattering */
            } else {
            HV_type = 2; /* Double bounce scattering */
            }
          }
          
        /* Surface scattering */
        if (HV_type == 1) {
          ratio = 10.*log10((TT[T311] + TT[T322]-2.*TT[T312_re])/(TT[T311] + TT[T322]+2.*TT[T312_re]));
          if ((ratio > -2.)&&(ratio <= 2.)) Pv = 2.*(2.*TT[T333] - Pc); 
          else Pv = (15./8.)*(2.*TT[T333] - Pc); 
          }
        /* Double bounce scattering */
        if (HV_type == 2) {
          Pv = (15./16.)*(2.*TT[T333] - Pc); 
          }

        TP = TT[T311] + TT[T322] + TT[T333];

        if (Pv < 0.) {
        /********************************************/
        /*Freeman - Yamaguchi 3-components algorithm*/
        /********************************************/

          HHHH = (TT[T311] + 2 * TT[T312_re] + TT[T322]) / 2.;
          HHVVre = (TT[T311] - TT[T322]) / 2.;
          HHVVim = -TT[T312_im];
          HVHV = TT[T333] / 2.;
          VVVV = (TT[T311] - 2. * TT[T312_re] + TT[T322]) / 2.;

          ratio = 10.*log10(VVVV/HHHH);
          if (ratio <= -2.) {
            FV = 15. * (HVHV / 4.);
            HHHH = HHHH - 8.*(FV/15.);
            VVVV = VVVV - 3.*(FV/15.);
            HHVVre = HHVVre - 2.*(FV/15.);
            }
          if (ratio > 2.) {
            FV = 15. * (HVHV/4.);
            HHHH = HHHH - 3.*(FV/15.);
            VVVV = VVVV - 8.*(FV/15.);
            HHVVre = HHVVre - 2.*(FV/15.);
            }
          if ((ratio > -2.)&&(ratio <= 2.)) {
            FV = 8. * (HVHV/2.);
            HHHH = HHHH - 3.*(FV/8.);
            VVVV = VVVV - 3.*(FV/8.);
            HHVVre = HHVVre - 1.*(FV/8.);
            }

          /*Case 1: Volume Scatter > Total*/
          if ((HHHH <= eps) || (VVVV <= eps)) {
            FD = 0.; FS = 0.;
            if ((ratio > -2.)&&(ratio <= 2.)) FV = (HHHH + 3.*(FV/8.)) + HVHV + (VVVV + 3.*(FV/8.));
            if (ratio <= -2.) FV = (HHHH + 8.*(FV/15.)) + HVHV + (VVVV + 3.*(FV/15.));
            if (ratio > 2.) FV = (HHHH + 3.*(FV/15.)) + HVHV + (VVVV + 8.*(FV/15.));
    
            } else {

            /*Data conditionning for non realizable ShhSvv* term*/
            if ((HHVVre * HHVVre + HHVVim * HHVVim) > HHHH * VVVV) {
              rtemp = HHVVre * HHVVre + HHVVim * HHVVim;
              HHVVre = HHVVre * sqrt((HHHH * VVVV) / rtemp);
              HHVVim = HHVVim * sqrt((HHHH * VVVV )/ rtemp);
              }
            /*Odd Bounce*/
            if (HHVVre >= 0.) {
              ALPre = -1.; ALPim = 0.;
              FD = (HHHH * VVVV - HHVVre * HHVVre - HHVVim * HHVVim) / (HHHH + VVVV + 2 * HHVVre);
              FS = VVVV - FD;
              BETre = (FD + HHVVre) / FS;
              BETim = HHVVim / FS;
              }
            /*Even Bounce*/
            if (HHVVre < 0.) {
              BETre = 1.; BETim = 0.;
              FS = (HHHH * VVVV - HHVVre * HHVVre - HHVVim * HHVVim) / (HHHH + VVVV - 2 * HHVVre);
              FD = VVVV - FS;
              ALPre = (HHVVre - FS) / FD;
              ALPim = HHVVim / FD;
              }
            }

          M_odd[lig][col] = FS * (1. + BETre * BETre + BETim * BETim);
          M_dbl[lig][col] = FD * (1. + ALPre * ALPre + ALPim * ALPim);
          M_vol[lig][col] = FV;
          M_hlx[lig][col] = 0.;

          if (M_odd[lig][col] < SpanMin) M_odd[lig][col] = SpanMin;
          if (M_dbl[lig][col] < SpanMin) M_dbl[lig][col] = SpanMin;
          if (M_vol[lig][col] < SpanMin) M_vol[lig][col] = SpanMin;

          if (M_odd[lig][col] > SpanMax) M_odd[lig][col] = SpanMax;
          if (M_dbl[lig][col] > SpanMax) M_dbl[lig][col] = SpanMax;
          if (M_vol[lig][col] > SpanMax) M_vol[lig][col] = SpanMax;

          } else {
    
          /********************************************/
          /*Yamaguchi 4-Components algorithm*/
          /********************************************/
          
          /* Surface scattering */
          if (HV_type == 1) {
            S = TT[T311] - (Pv / 2.);
            D = TP - Pv - Pc - S;
            Cre = TT[T312_re] + TT[T313_re];
            Cim = TT[T312_im] + TT[T313_im];
            if (ratio <= -2.) Cre = Cre - (Pv / 6.);
            if (ratio > 2.) Cre = Cre + (Pv / 6.);
            
            if ((Pv + Pc) > TP) {
              Ps = 0.;
              Pd = 0.;
              Pv = TP - Pc;
              } else {
              CO = 2.*TT[T311] + Pc - TP;
              if (CO > 0.) {
                Ps = S + (Cre*Cre + Cim*Cim)/S;
                Pd = D - (Cre*Cre + Cim*Cim)/S;
                } else {
                Pd = D + (Cre*Cre + Cim*Cim)/D;
                Ps = S - (Cre*Cre + Cim*Cim)/D;
                }
              }
            if (Ps < 0.) {
              if (Pd < 0.) {
                Ps = 0.; Pd = 0.;
                Pv = TP - Pc;
                } else {
                Ps = 0.;
                Pd = TP - Pv - Pc;
                }
              } else {
              if (Pd < 0.) {
                Pd = 0.;
                Ps = TP - Pv - Pc;
                }
              }
            }
            
          /* Double bounce scattering */
          if (HV_type == 2) {
            S = TT[T311];
            D = TP - Pv - Pc - S;
            Cre = TT[T312_re] + TT[T313_re];
            Cim = TT[T312_im] + TT[T313_im];

            Pd = D + (Cre*Cre + Cim*Cim)/D;
            Ps = S - (Cre*Cre + Cim*Cim)/D;
            
            if (Ps < 0.) {
              if (Pd < 0.) {
                Ps = 0.; Pd = 0.;
                Pv = TP - Pc;
                } else {
                Ps = 0.;
                Pd = TP - Pv - Pc;
                }
              } else {
              if (Pd < 0.) {
                Pd = 0.;
                Ps = TP - Pv - Pc;
                }
              }
            }
            
          if (Ps < SpanMin) Ps = SpanMin;
          if (Pd < SpanMin) Pd = SpanMin;
          if (Pv < SpanMin) Pv = SpanMin;
          if (Pc < SpanMin) Pc = SpanMin;

          if (Ps > SpanMax) Ps = SpanMax;
          if (Pd > SpanMax) Pd = SpanMax;
          if (Pv > SpanMax) Pv = SpanMax;
          if (Pc > SpanMax) Pc = SpanMax;

          M_odd[lig][col] = Ps;
          M_dbl[lig][col] = Pd;
          M_vol[lig][col] = Pv;
          M_hlx[lig][col] = Pc;

          }
        } else {
        M_odd[lig][col] = 0.;
        M_dbl[lig][col] = 0.;
        M_vol[lig][col] = 0.;
        M_hlx[lig][col] = 0.;
        }
      }
    free_matrix_float(M_avg,NpolarOut);
    free_vector_float(TT);
    }

  write_block_matrix_float(out_odd, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dbl, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_vol, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_hlx, M_hlx, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

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
  free_matrix_float(M_hlx, NligBlock[0]);
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
  fclose(out_hlx);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

int unitary_rotation(float *TT, float teta)
{
  float T11, T12_re, T12_im, T13_re, T13_im;
  float T22, T23_re, T23_im;
  float T33;
  
  T11 = TT[T311]; 
  T12_re = TT[T312_re]; T12_im = TT[T312_im];
  T13_re = TT[T313_re]; T13_im = TT[T313_im];
  T22 = TT[T322]; 
  T23_re = TT[T323_re]; T23_im = TT[T323_im];
  T33 = TT[T333]; 

  TT[T311] = T11;
  TT[T312_re] = T12_re*cos(teta)+T13_re*sin(teta);
  TT[T312_im] = T12_im*cos(teta)+T13_im*sin(teta);
  TT[T313_re] = -T12_re*sin(teta)+T13_re*cos(teta);
  TT[T313_im] = -T12_im*sin(teta)+T13_im*cos(teta);
  TT[T322] = T22*cos(teta)*cos(teta)+2.*T23_re*cos(teta)*sin(teta)+T33*sin(teta)*sin(teta);
  TT[T323_re] = -T22*cos(teta)*sin(teta)+T23_re*cos(teta)*cos(teta)-T23_re*sin(teta)*sin(teta)+T33*cos(teta)*sin(teta);
  TT[T323_im] = T23_im*cos(teta)*cos(teta)+T23_im*sin(teta)*sin(teta);
  TT[T333] = T22*sin(teta)*sin(teta)+T33*cos(teta)*cos(teta) - 2.*T23_re*cos(teta)*sin(teta);
  
  return 1;
}
