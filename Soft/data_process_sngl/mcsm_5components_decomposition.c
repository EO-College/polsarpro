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

File  : mcsm_5components_decomposition.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2014
Update  :
*--------------------------------------------------------------------
Dr. Lamei Zhang
Dept.of Information Engineering
Harbin Institute of Technology
POBox323#,No. 92,Xidazhi Street,150001,Harbin,China
Tel:+86-451-86413501-16
Email:lmzhang@hit.edu.cn
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

Description :  MCSM (Multiple Component Scattering Model)
               5 components Decomposition : single, volume, double
               helix and wire.
               
*--------------------------------------------------------------------
Translated and adapted in c language from : IDL routine
Y5component_2.pro
written by : Lamei Zhang
Calculate polarimetric decomposition based on Multiple-component 
scattering model
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
  FILE *out_odd, *out_dbl, *out_vol, *out_hlx, *out_wir, *out_dblhlx;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;

  float Span, SpanMin, SpanMax;
  float X, Y, Zre, Zim;
  float FV;
  float FS, FSre, FSim;
  float FD, FDre, FDim;
  float FH, FHim;
//float FHre;
  float FW, FWre, FWim;
  float ALPre, ALPim;
  float BETre, BETim;
  float GAM, GAMre, GAMim;
  float RHO, RHOre, RHOim;
  float HHHH,HVHV,VVVV;
  float HHVVre, HHVVim;
  float HHHVre, HHHVim;
  float HVVVre, HVVVim;
  float ratio;
  float numre, numim;
  float denre, denim, den;
 
/* Matrix arrays */
  float ***M_avg;
  float **M_odd;
  float **M_dbl;
  float **M_vol;
  float **M_hlx;
  float **M_wir;
  float **M_dblhlx;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmcsm_5components_decomposition.exe\n");
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
  sprintf(file_name, "%s%s", out_dir, "MCSM_Odd.bin");
  if ((out_odd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "MCSM_Dbl.bin");
  if ((out_dbl = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "MCSM_Vol.bin");
  if ((out_vol = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "MCSM_Hlx.bin");
  if ((out_hlx = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "MCSM_Wire.bin");
  if ((out_wir = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "MCSM_DblHlx.bin");
  if ((out_dblhlx = fopen(file_name, "wb")) == NULL)
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
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Modd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mhlx = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mwir = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
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
  M_odd = matrix_float(NligBlock[0], Sub_Ncol);
  M_dbl = matrix_float(NligBlock[0], Sub_Ncol);
  M_vol = matrix_float(NligBlock[0], Sub_Ncol);
  M_hlx = matrix_float(NligBlock[0], Sub_Ncol);
  M_wir = matrix_float(NligBlock[0], Sub_Ncol);
  M_dblhlx = matrix_float(NligBlock[0], Sub_Ncol);

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
      if (Valid[lig][col] == 1.) {
        HHHH = M_avg[C311][lig][col];
        HHHVre = M_avg[C312_re][lig][col]/sqrt(2.);
        HHHVim = M_avg[C312_im][lig][col]/sqrt(2.);
        HHVVre = M_avg[C313_re][lig][col];
        HHVVim = M_avg[C313_im][lig][col];
        HVHV = M_avg[C322][lig][col]/2.;
        HVVVre = M_avg[C323_re][lig][col]/sqrt(2.);
        HVVVim = M_avg[C323_im][lig][col]/sqrt(2.);
        VVVV = M_avg[C333][lig][col];

        den = HVVVre*HVVVre+HVVVim*HVVVim;
        RHOre = (HVHV*HVVVre)/den; RHOim = (HVHV*HVVVim)/den;
        RHO = sqrt(RHOre*RHOre+RHOim*RHOim);
        GAMre = (HHHVre*HVVVre-HHHVim*HVVVim)/den; GAMim = (HHHVre*HVVVim+HHHVim*HVVVre)/den;
        GAM = sqrt(GAMre*GAMre+GAMim*GAMim);
        
        denre = GAMre*RHOre+GAMim*RHOim-GAMre;
        denim = GAMim*RHOre-GAMre*RHOim-GAMim;
        den = denre*denre+denim*denim;
        numre = HHHVre-HVVVre; numim = HHHVim-HVVVim;
        FWre = (numre*denre+numim*denim)/den;
        FWim = (numim*denre-numre*denim)/den;
        FW = sqrt(FWre*FWre+FWim*FWim);
        
//      FHre = HHHVre+HVVVre -FW*(GAMre*RHOre+GAMim*RHOim+RHOre);
        FHim = HHHVim+HVVVim -FW*(GAMim*RHOre-GAMre*RHOim+RHOim);
        FH = 2.*FHim;
  
        ratio = 10.*log10(VVVV/HHHH);
        if (ratio <= -2.) {
          if (2.*HVHV < HHHH) {
            FV = 7.5*(HVHV - (FH/4.) - FW*RHO*RHO);
            X = FV*(8./15.) + (FH/4.) + FW*GAM*GAM;
            Y = FV*(3./15.) + (FH/4.) + FW;
            Zre = FV*(2./15.) - (FH/4.) + FW*GAMre;
            Zim = FV*(2./15.) - (FH/4.) + FW*GAMim;
            } else {
            FV = 15.*HVHV/2.;
            X = FV*(8./15.);
            Y = FV*(3./15.);
            Zre = FV*(2./15.);
            Zim = 0.;
            }
          }
        if ((ratio > -2.)&&(ratio <= 2.)) {
          if (2.*HVHV < HHHH) {
            FV = 8.0*(HVHV - (FH/4.) - FW*RHO*RHO);
            X = FV*(3./8.) + (FH/4.) + FW*GAM*GAM;
            Y = FV*(3./8.) + (FH/4.) + FW;
            Zre = FV*(1./8.) - (FH/4.) + FW*GAMre;
            Zim = FV*(1./8.) - (FH/4.) + FW*GAMim;
            } else {
            FV = 16.*HVHV/2.;
            X = FV*(3./8.);
            Y = FV*(3./8.);
            Zre = FV*(1./8.);
            Zim = 0.;
            }
          }
        if (ratio > 2.) {
          if (2.*HVHV < HHHH) {
            FV = 7.5*(HVHV - (FH/4.) - FW*RHO*RHO);
            X = FV*(3./15.) + (FH/4.) + FW*GAM*GAM;
            Y = FV*(8./15.) + (FH/4.) + FW;
            Zre = FV*(2./15.) - (FH/4.) + FW*GAMre;
            Zim = FV*(2./15.) - (FH/4.) + FW*GAMim;
            } else {
            FV = 15.*HVHV/2.;
            X = FV*(3./15.);
            Y = FV*(8./15.);
            Zre = FV*(2./15.);
            Zim = 0.;
            }
          }

        if (HHVVre > 0.) {
          denre = VVVV - Y + HHVVre - Zre; denim = HHVVim - Zim;
          den = denre*denre+denim*denim;
          numre = HHHH - X + HHVVre - Zre; numim = HHVVim - Zim;
          BETre = (numre*denre-numim*denim)/den;
          BETim = (numre*denim+numim*denre)/den;
          denre = 1. + BETre; denim = BETim;
          den = denre*denre+denim*denim;
          numre = BETre*(VVVV - Y) - HHVVre + Zre;
          numim = BETim*(VVVV - Y) - HHVVim + Zim;
          FDre = (numre*denre+numim*denim)/den;
          FDim = (numim*denre-numre*denim)/den;
          FD = sqrt(FDre*FDre+FDim*FDim);
          M_dbl[lig][col] = 2.*FD;
          FS = fabs(VVVV - Y - FD);
          M_odd[lig][col] = FS * (1 + BETre*BETre + BETim*BETim);      
          } else {
          denre = VVVV - Y + HHVVre + Zre; denim = HHVVim + Zim;
          den = denre*denre+denim*denim;
          numre = X - HHHH + HHVVre - Zre; numim = HHVVim - Zim;
          ALPre = (numre*denre-numim*denim)/den;
          ALPim = (numre*denim+numim*denre)/den;
          denre = ALPre - 1.; denim = ALPim;
          den = denre*denre+denim*denim;
          numre = ALPre*(VVVV - Y) - HHVVre + Zre;
          numim = ALPim*(VVVV - Y) - HHVVim + Zim;
          FSre = (numre*denre+numim*denim)/den;
          FSim = (numim*denre-numre*denim)/den;
          FS = sqrt(FSre*FSre+FSim*FSim);
          M_odd[lig][col] = 2.*FS;
          FD = fabs(VVVV - Y - FS);
          M_dbl[lig][col] = FD * (1 + ALPre*ALPre + ALPim*ALPim);      
          }

        M_vol[lig][col] = fabs(FV);
        M_hlx[lig][col] = fabs(FH);
        M_wir[lig][col] = fabs(FW*(1. + GAM*GAM + RHO*RHO));
        M_dblhlx[lig][col] = M_dbl[lig][col] + M_hlx[lig][col];

        if (M_odd[lig][col] < 0.) M_odd[lig][col] = 0.;
        if (M_dbl[lig][col] < 0.) M_dbl[lig][col] = 0.;
        if (M_vol[lig][col] < 0.) M_vol[lig][col] = 0.;
        if (M_hlx[lig][col] < 0.) M_hlx[lig][col] = 0.;
        if (M_wir[lig][col] < 0.) M_wir[lig][col] = 0.;
        if (M_dblhlx[lig][col] < 0.) M_dblhlx[lig][col] = 0.;

        if (M_odd[lig][col] > SpanMax) M_odd[lig][col] = SpanMax;
        if (M_dbl[lig][col] > SpanMax) M_dbl[lig][col] = SpanMax;
        if (M_vol[lig][col] > SpanMax) M_vol[lig][col] = SpanMax;
        if (M_hlx[lig][col] > SpanMax) M_hlx[lig][col] = SpanMax;
        if (M_wir[lig][col] > SpanMax) M_wir[lig][col] = SpanMax;
        if (M_dblhlx[lig][col] > SpanMax) M_dblhlx[lig][col] = SpanMax;
        } else {
        M_odd[lig][col] = 0.;
        M_dbl[lig][col] = 0.;
        M_vol[lig][col] = 0.;
        M_hlx[lig][col] = 0.;
        M_wir[lig][col] = 0.;
        M_dblhlx[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_odd, M_odd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dbl, M_dbl, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_vol, M_vol, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_hlx, M_hlx, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_wir, M_wir, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dblhlx, M_dblhlx, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

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
  fclose(out_hlx);
  fclose(out_wir);
  fclose(out_dblhlx);
  
/********************************************************************
********************************************************************/

  return 1;
}


