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

File  : surface_inversion_xbragg.c
Project  : ESA_POLSARPRO
Authors  : Sophie ALLAIN, Eric POTTIER (v2.0)
Version  : 2.0
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

Description :  Surface Parameter Data Inversion : Xbragg Procedure

*--------------------------------------------------------------------

Translated and adapted in c language from : IDL routine
$Id: xbragg_polsarpro.pro,v 1.00 2008/12/15
Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR) / German Aerospace Center (DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by: I. HAJNSEK
;
; CONTACT: irena.hajnsek@dlr.de
;
; NAME: XBRAGG_POLSARPRO
;
; PURPOSE: INITALIZATION ROUTINE FOR BLOCKPROCESSING OF X-BRAGG
; INVERSION MODEL FOR SOIL MOISTURE RETRIEVAL FROM REAL PART OF
; DIELECTRIC CONSTANT
;
;IMPORTANT:
;LOCAL INCIDENCE ANGLE (RADIAN) MUST BE ALLREADY CALCULATED as a
; f(Radar Geomertry & Topography)!
;
;PARAMETERS: NONE
;
;EXAMPLE: xbragg_polsarpro
;
; MODIFICATION HISTORY:
;
;1- T.JAGDHUBER/H.SCHOEN   8.12.2008  Written
;2- I.Hajnsek  20.02.2008   Modified, Adapted, Checked

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

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *in_file_angle;
  FILE *out_dc, *out_mv, *out_maskout, *out_maskinout;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength], anglefile[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, i, id, ib, k;
  int pos, valid, Unit;
  int Ndieli, Nbeta;
  float x, sinxx;

  float dielifactor, betafactor, max_dieli, braggs, braggp;
  float t11est, t12est, t22est, t33est;

/*
  float eigen1, eigen2, eigen3;
  float eigenvec1, eigenvec2, eigenvec3;
  float probaest1, probaest2, probaest3;

  float _eps, _tr, _dt; 
  float _s1, _s2, _f0, _f1, _f2r, _f2i, _f3r, _f3i, _p;
  float _ee1, _ee2r, _ee2i, _ee2, _ee3r, _ee3i, _ee3;
  float _eval1, _eval2, _eval3;
  float _norm;
  float _v2r, _v2i, _Nv2r, _Nv2i, _Dv2r, _Dv2i;
  float _v3r, _v3i, _Nv3r, _Nv3i, _Dv3r, _Dv3i;
  float _evec1, _evec2, _evec3;
  float probana1, probana2, probana3;
*/

  float se, al, minliadis, minimumdis, substraction;
  float entropyest, alphaest, epsilon;

  float *dieli, *beta1;
  float lia_blockrange[901], max_al[901], max_en[901];

/* Matrix arrays */
  float ***M_avg;
  float **Mdc_out;
  float **Mmv_out;
  float **mask_out;
  float **mask_in_out;
  float **angle;
  
  float ***T;
  float alpha[3], p[3];
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsurface_inversion_xbragg.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-ang 	incidence angle file\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
strcat(UsageHelp," (float) 	-dif 	dielectric factor\n");
strcat(UsageHelp," (float) 	-bef 	beta factor\n");
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

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ang",str_cmd_prm,anglefile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-un",int_cmd_prm,&Unit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dif",flt_cmd_prm,&dielifactor,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bef",flt_cmd_prm,&betafactor,1,UsageHelp);

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
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(anglefile);

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

  if ((in_file_angle = fopen(anglefile, "rb")) == NULL)
    edit_error("Could not open input file : ", anglefile);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "xbragg_dc.bin");
  if ((out_dc = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "xbragg_mv.bin");
  if ((out_mv = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "xbragg_mask_out.bin");
  if ((out_maskout = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "xbragg_mask_valid_in_out.bin");
  if ((out_maskinout = fopen(file_name, "wb")) == NULL)
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

  /* angle = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdc = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* maskout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* maskinout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
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

  angle = matrix_float(NligBlock[0], Sub_Ncol);
  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  Mdc_out = matrix_float(NligBlock[0], Sub_Ncol);
  Mmv_out = matrix_float(NligBlock[0], Sub_Ncol);
  mask_out = matrix_float(NligBlock[0], Sub_Ncol);
  mask_in_out = matrix_float(NligBlock[0], Sub_Ncol);

  T = matrix3d_float(3, 3, 2);
  V = matrix3d_float(3, 3, 2);
  lambda = vector_float(3);

/*******************************************************************
********************************************************************
********************************************************************/

//######  Xbragg-Model and Inversion 

  //dielifactor: step width for dielectric constant in inversion
  //betafactor: step width of roughness angle in inversion

  Ndieli = floor((44. - 2.) / dielifactor);
  Nbeta = floor((90. - 0.) / betafactor);

  dieli = vector_float(Ndieli+1);
  beta1 = vector_float(Nbeta+1);

  for (i=0; i<= Ndieli; i++) dieli[i]= (float)i*dielifactor+2.;
  for (i=0; i<= Nbeta; i++) beta1[i]= ((float)i*betafactor+0.1)*pi/180.;
  beta1[Nbeta]=89.999*pi/180.;

//##################  Calculation of entropy-alpha filter due to look-up table (LUT) of X-Bragg model

  for (i=0; i<901; i++) lia_blockrange[i] = (float)i*0.1*pi/180.; //lia in steps 0.1 degree
  max_dieli = -INIT_MINMAX;
  for (i=0; i<= Ndieli; i++) if (max_dieli <= dieli[i]) max_dieli = dieli[i];

/*******************************************************************
********************************************************************
********************************************************************
Translated and adapted in c language from : IDL routine
; $Id: MAX_EN_AL_POLSARPRO.pro,v 1.00 2008/12/15
;
; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR) / German Aerospace Center (DLR)
; Oberpfaffenhofen
; 82234 Wessling

; developed by:
; I. HAJNSEK
; H. SCHOEN
; T. JAGDHUBER
; K. PAPATHANASSIOU

; CONTACT: irena.hajnsek@dlr.de
;
; NAME: MAX_EN_AL_POLSARPRO
;
; PURPOSE: CALCULATION OF MAXIMUM ENTROPY AND ALPHA VALUES FOR THE
; GIVEN LOCAL INCIDENCE ANGLES 
;
; PARAMETERS:
;LIA= LOCAL INCIDENCE ANGLES [RADIAN]
;MAX_EN=MAXIMUM ENTROPY VALUE FOR THE GIVEN LOCAL INCIDENCE ANGLE [-]
;MAX_AL=MAXIMUM ALPHA VALUE FOR THE GIVEN LOCAL INCIDENCE ANGLE [RADIAN]
;MAX_DIELI=MAXIMUM VALUE OF DIELECTRIC CONSTANT CONSIDERED IN LOOK UP TABLE [-]
;
;EXAMPLE:
; max_en_al_polsarpro,lia,max_en=max_en,max_al=max_al
;
; MODIFICATION HISTORY:
;
; 1- T.JAGDHUBER/H.SCHOEN    12.2008  Written
********************************************************************/

//##################  Calculation of Bragg scattering for maximum soil moisture value

  for (i=0; i<901; i++) {
    braggs = cos(lia_blockrange[i]) - sqrt(max_dieli - sin(lia_blockrange[i])*sin(lia_blockrange[i]));
    braggs = braggs / (cos(lia_blockrange[i]) + sqrt(max_dieli - sin(lia_blockrange[i])*sin(lia_blockrange[i])));
    braggp = (max_dieli - 1.)*(sin(lia_blockrange[i])*sin(lia_blockrange[i]) - max_dieli*(1. + sin(lia_blockrange[i])*sin(lia_blockrange[i])));
    braggp = braggp / (max_dieli*cos(lia_blockrange[i]) + sqrt(max_dieli - sin(lia_blockrange[i])*sin(lia_blockrange[i])));
    braggp = braggp / (max_dieli*cos(lia_blockrange[i]) + sqrt(max_dieli - sin(lia_blockrange[i])*sin(lia_blockrange[i])));

//##################  Calculation of maximum alpha value (beta1=0°)

//##################  Calculation of eigenvalues and eigenvectors
    t11est=(braggs+braggp)*(braggs+braggp);
    t12est=(braggs+braggp)*(braggs-braggp);
    t22est=(braggs-braggp)*(braggs-braggp);
    t33est=0.;

// Eigen-values
    //eigen1=0.5*(t11est+t22est-sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est));
    //eigen2=0.5*(t11est+t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est));
    //if (eigen1 < 0.) eigen1 = 0.; if (eigen1 > 1.) eigen1 = 1.;
    //if (eigen2 < 0.) eigen2 = 0.; if (eigen2 > 1.) eigen2 = 1.;

// Eigen-vectors
    //eigenvec1=-1.*(t11est-t22est-sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est))/(t12est*sqrt(4.+fabs((-1*t11est+t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est))/t12est)*fabs((-1*t11est+t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est))/t12est)));
    //eigenvec2=(t11est-t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est))/(t12est*sqrt(4.+fabs((t11est-t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est))/t12est)*fabs((t11est-t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est))/t12est)));

//##################  Calculation of probabilities
    //probaest1=eigen1/(eigen1+eigen2);
    //probaest2=eigen2/(eigen1+eigen2);
  
//##################  Maximum alpha (beta1=0deg)
    //max_al[i]=probaest1*acos(fabs(eigenvec1))+probaest2*acos(fabs(eigenvec2));

    T[0][0][0] = eps + t11est;  T[0][0][1] = 0.;
    T[0][1][0] = eps + t12est;  T[0][1][1] = eps + 0.;
    T[0][2][0] = eps + 0.;    T[0][2][1] = eps + 0.;
    T[1][0][0] = eps + t12est;  T[1][0][1] = eps + 0.;
    T[1][1][0] = eps + t22est;  T[1][1][1] = 0.;
    T[1][2][0] = eps + 0.;    T[1][2][1] = eps + 0.;
    T[2][0][0] = eps + 0.;    T[2][0][1] = eps + 0.;
    T[2][1][0] = eps + 0.;    T[2][1][1] = eps + 0.;
    T[2][2][0] = eps + t33est;  T[2][2][1] = 0.;

/* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
/* V complex eigenvecor matrix, lambda real vector*/
    Diagonalisation(3, T, V, lambda);

    for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;

    for (k = 0; k < 3; k++) {
/* Unitary eigenvectors */
      alpha[k] = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
/* Scattering mechanism probability of occurence */
      p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
      if (p[k] < 0.) p[k] = 0.;
      if (p[k] > 1.) p[k] = 1.;
      }

/* Mean scattering mechanism */
    max_al[i] = 0;
    for (k = 0; k < 3; k++) {
      max_al[i] += alpha[k] * p[k];
      }

//##################  Calculation of maximum entropy value (beta1=90°)

//##################  Calculation of eigenvalues
    t11est=(braggs+braggp)*(braggs+braggp);
    t12est=0.;
    t22est=0.5*(braggs-braggp)*(braggs-braggp);
    t33est=0.5*(braggs-braggp)*(braggs-braggp);

// Eigen-values
    //eigen1=0.5*(t11est+t22est-sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est));
    //eigen2=0.5*(t11est+t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est));
    //eigen3=t33est;
    //if (eigen1 < 0.) eigen1 = 0.; if (eigen1 > 1.) eigen1 = 1.;
    //if (eigen2 < 0.) eigen2 = 0.; if (eigen2 > 1.) eigen2 = 1.;
    //if (eigen3 < 0.) eigen3 = 0.; if (eigen3 > 1.) eigen3 = 1.;
  
//##################  Calculation of probabilities
    //probaest1=eigen1/(eigen1+eigen2+eigen3+eps);
    //probaest2=eigen2/(eigen1+eigen2+eigen3+eps);
    //probaest3=eigen3/(eigen1+eigen2+eigen3+eps);
  
//##################  Maximum entropy (beta1=90°)
    //max_en[i]=-probaest1*log(probaest1)/log(3.)-probaest2*log(probaest2)/log(3.)-probaest3*log(probaest3)/log(3.);

    T[0][0][0] = eps + t11est;  T[0][0][1] = 0.;
    T[0][1][0] = eps + t12est;  T[0][1][1] = eps + 0.;
    T[0][2][0] = eps + 0.;    T[0][2][1] = eps + 0.;
    T[1][0][0] = eps + t12est;  T[1][0][1] = eps + 0.;
    T[1][1][0] = eps + t22est;  T[1][1][1] = 0.;
    T[1][2][0] = eps + 0.;    T[1][2][1] = eps + 0.;
    T[2][0][0] = eps + 0.;    T[2][0][1] = eps + 0.;
    T[2][1][0] = eps + 0.;    T[2][1][1] = eps + 0.;
    T[2][2][0] = eps + t33est;  T[2][2][1] = 0.;

/* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
/* V complex eigenvecor matrix, lambda real vector*/
    Diagonalisation(3, T, V, lambda);

    for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;

    for (k = 0; k < 3; k++) {
/* Scattering mechanism probability of occurence */
      p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
      if (p[k] < 0.) p[k] = 0.;
      if (p[k] > 1.) p[k] = 1.;
      }

/* Mean scattering mechanism */
    max_en[i] = 0;

    for (k = 0; k < 3; k++) {
      max_en[i] -= p[k] * log(p[k] + eps);
      }
/* Scaling */
    max_en[i] /= log(3.);

    }

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeOut,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeOut,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  read_block_matrix_float(in_file_angle, angle, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      Mdc_out[lig][col] = 0.;
      Mmv_out[lig][col] = 0.;
      mask_out[lig][col] = 0.;
      mask_in_out[lig][col] = 0.;
      
      if (Valid[lig][col] == 1.) {

        if (Unit == 0) angle[lig][col]=angle[lig][col]*pi/180;

        T[0][0][0] = eps + M_avg[0][lig][col];
        T[0][0][1] = 0.;
        T[0][1][0] = eps + M_avg[1][lig][col];
        T[0][1][1] = eps + M_avg[2][lig][col];
        T[0][2][0] = eps + M_avg[3][lig][col];
        T[0][2][1] = eps + M_avg[4][lig][col];
        T[1][0][0] =  T[0][1][0];
        T[1][0][1] = -T[0][1][1];
        T[1][1][0] = eps + M_avg[5][lig][col];
        T[1][1][1] = 0.;
        T[1][2][0] = eps + M_avg[6][lig][col];
        T[1][2][1] = eps + M_avg[7][lig][col];
        T[2][0][0] =  T[0][2][0];
        T[2][0][1] = -T[0][2][1];
        T[2][1][0] =  T[1][2][0];
        T[2][1][1] = -T[1][2][1];
        T[2][2][0] = eps + M_avg[8][lig][col];
        T[2][2][1] = 0.;

/* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
/*******************************************************************
********************************************************************
********************************************************************
Translated and adapted in c language from : IDL routine
$Id: calc_en_al_polsarpro.pro,v 1.00 2008/12/15

; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR) / German Aerospace Center (DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; I. HAJNSEK
; H. SCHOEN
; T. JAGDHUBER
; K. PAPATHANASSIOU

; CONTACT:
; irena.hajnsek@dlr.de
;
; NAME: CALC_EN_AL_POLSARPRO
;
; PURPOSE: Calculation of entropy and alpha from monostatic SAR data
;
; MODIFICATION HISTORY:
;1- T.JAGDHUBER/H.SCHOEN   12.2008    written
********************************************************************/
//###############  Calculate entropy and alpha

/*
    t11 = T[0][0][0]; t22 = T[1][1][0]; t33 = T[2][2][0];
    t12r = T[0][1][0]; t12i = T[0][1][1];
    t13r = T[0][2][0]; t13i = T[0][2][1];
    t23r = T[1][2][0]; t23i = T[1][2][1];
    
    //Eigen-analysis
    _eps = 10e-6;

    _tr = (t11+t22+t33)/3.;

    _dt = t11*t22*t33-t11*(t23r*t23r+t23i*t23i)-t22*(t13r*t13r+t13i*t13i)-t33*(t12r*t12r+t12i*t12i);
    _dt += 2.*t23r*(t12r*t13r+t12i*t13i) -2.*t23i*(t12i*t13r-t13i*t12r);

    _s1 = t11*t22+t11*t33+t22*t33-(t12r*t12r+t12i*t12i)-(t13r*t13r+t13i*t13i)-(t23r*t23r+t23i*t23i);
    _s2 = t11*t11+t22*t22+t33*t33-t11*t22-t11*t33-t22*t33+3.*(t12r*t12r+t12i*t12i)+3.*(t13r*t13r+t13i*t13i)+3.*(t23r*t23r+t23i*t23i);

    _f0= (27*_dt-27*_s1*_tr+54*_tr*_tr*_tr);

    _f1= _f0+sqrt(_f0*_f0-4.*_s2*_s2*_s2);

    _f2r=1.; _f2i=sqrt(3); 
    _f3r=1.; _f3i=-sqrt(3);

    _p=1/3.;

    //Eigen-values
    _ee1 = fabs(_tr+(pow(_f1,_p))/(3.*pow(2.,_p))+(_s2*pow(2.,_p)+_eps)/(3.*pow(_f1,_p)+_eps));
    _ee2r = _tr-(_f2r*_s2)/(3.*pow(_f1,_p)*pow(2.,(2.*_p))+_eps)-(_f3r*pow(_f1,_p)+_eps)/(6.*pow(2.,_p)+_eps);
    _ee2i = -(_f2i*_s2)/(3.*pow(_f1,_p)*pow(2.,(2.*_p))+_eps)-(_f3i*pow(_f1,_p)+_eps)/(6.*pow(2.,_p)+_eps);
    _ee2 = sqrt(_ee2r*_ee2r+_ee2i*_ee2i);
    _ee3r = _tr-(_f3r*_s2)/(3.*pow(_f1,_p)*pow(2.,(2.*_p))+_eps)-(_f2r*pow(_f1,_p)+_eps)/(6.*pow(2.,_p)+_eps);
    _ee3i = -(_f3i*_s2)/(3.*pow(_f1,_p)*pow(2.,(2.*_p))+_eps)-(_f2i*pow(_f1,_p)+_eps)/(6.*pow(2.,_p)+_eps);
    _ee3 = sqrt(_ee3r*_ee3r+_ee3i*_ee3i);

    //Sort
    _eval1 = _ee1; if (_eval1 < _ee2) _eval1 = _ee2; if (_eval1 < _ee3) _eval1 = _ee3;
    _eval3 = _ee1; if (_ee2 < _eval3) _eval3 = _ee2; if (_ee3 < _eval3) _eval3 = _ee3;
    _eval2 = _ee1 + _ee2 + _ee3 - _eval1 - _eval3;

    //Eigen-vectors
    _Dv2r = (t22-_eval1)*t13r-t12r*t23r+t12i*t23i;
    _Dv2i = (t22-_eval1)*t13i-t12r*t23i-t12i*t23r;
    _Nv2r = (t11-_eval1)*t23r-t12r*t13r-t12i*t13i;
    _Nv2i = (t11-_eval1)*t23i-t12r*t13i+t12i*t13r;
    _v2r = (_Nv2r*_Dv2r+_Nv2i*_Dv2i)/(_Dv2r*_Dv2r+_Dv2i*_Dv2i);
    _v2i = (_Nv2i*_Dv2r-_Nv2r*_Dv2i)/(_Dv2r*_Dv2r+_Dv2i*_Dv2i);
    
    _Dv3r = t13r;
    _Dv3i = t13i;
    _Nv3r = -(t11-_eval1)*t23r-t12r*_v2r+t12i*_v2i;
    _Nv3i = -t12i*_v2r-t12r*_v2i;
    _v3r = (_Nv3r*_Dv3r+_Nv3i*_Dv3i)/(_Dv3r*_Dv3r+_Dv3i*_Dv3i);
    _v3i = (_Nv3i*_Dv3r-_Nv3r*_Dv3i)/(_Dv3r*_Dv3r+_Dv3i*_Dv3i);
    
    _norm=sqrt(1.+_v2r*_v2r+_v2i*_v2i+_v3r*_v3r+_v3i*_v3i);

    _evec1 = 1. / (_norm+_eps);

    _Dv2r = (t22-_eval2)*t13r-t12r*t23r+t12i*t23i;
    _Dv2i = (t22-_eval2)*t13i-t12r*t23i-t12i*t23r;
    _Nv2r = (t11-_eval2)*t23r-t12r*t13r-t12i*t13i;
    _Nv2i = (t11-_eval2)*t23i-t12r*t13i+t12i*t13r;
    _v2r = (_Nv2r*_Dv2r+_Nv2i*_Dv2i)/(_Dv2r*_Dv2r+_Dv2i*_Dv2i);
    _v2i = (_Nv2i*_Dv2r-_Nv2r*_Dv2i)/(_Dv2r*_Dv2r+_Dv2i*_Dv2i);
    
    _Dv3r = t13r;
    _Dv3i = t13i;
    _Nv3r = -(t11-_eval2)*t23r-t12r*_v2r+t12i*_v2i;
    _Nv3i = -t12i*_v2r-t12r*_v2i;
    _v3r = (_Nv3r*_Dv3r+_Nv3i*_Dv3i)/(_Dv3r*_Dv3r+_Dv3i*_Dv3i);
    _v3i = (_Nv3i*_Dv3r-_Nv3r*_Dv3i)/(_Dv3r*_Dv3r+_Dv3i*_Dv3i);
    
    _norm=sqrt(1.+_v2r*_v2r+_v2i*_v2i+_v3r*_v3r+_v3i*_v3i);

    _evec2 = 1. / (_norm+_eps);

    _Dv2r = (t22-_eval3)*t13r-t12r*t23r+t12i*t23i;
    _Dv2i = (t22-_eval3)*t13i-t12r*t23i-t12i*t23r;
    _Nv2r = (t11-_eval3)*t23r-t12r*t13r-t12i*t13i;
    _Nv2i = (t11-_eval3)*t23i-t12r*t13i+t12i*t13r;
    _v2r = (_Nv2r*_Dv2r+_Nv2i*_Dv2i)/(_Dv2r*_Dv2r+_Dv2i*_Dv2i);
    _v2i = (_Nv2i*_Dv2r-_Nv2r*_Dv2i)/(_Dv2r*_Dv2r+_Dv2i*_Dv2i);
    
    _Dv3r = t13r;
    _Dv3i = t13i;
    _Nv3r = -(t11-_eval3)*t23r-t12r*_v2r+t12i*_v2i;
    _Nv3i = -t12i*_v2r-t12r*_v2i;
    _v3r = (_Nv3r*_Dv3r+_Nv3i*_Dv3i)/(_Dv3r*_Dv3r+_Dv3i*_Dv3i);
    _v3i = (_Nv3i*_Dv3r-_Nv3r*_Dv3i)/(_Dv3r*_Dv3r+_Dv3i*_Dv3i);
    
    _norm=sqrt(1.+_v2r*_v2r+_v2i*_v2i+_v3r*_v3r+_v3i*_v3i);

    _evec3 = 1. / (_norm+_eps);
    
    //Probabilities

    probana1=_eval1/(_eval1+_eval2+_eval3);
    probana2=_eval2/(_eval1+_eval2+_eval3);
    probana3=_eval3/(_eval1+_eval2+_eval3);

    //Entropy

    se = -probana1*log(probana1)/log(3.)-probana2*log(probana2)/log(3.)-probana3*log(probana3)/log(3.);

    //Alpha

    al = probana1*acos(fabs(_evec1))+probana2*acos(fabs(_evec2))+probana3*acos(fabs(_evec3));
*/

/* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
/* V complex eigenvecor matrix, lambda real vector*/
        Diagonalisation(3, T, V, lambda);

        for (k = 0; k < 3; k++)
          if (lambda[k] < 0.) lambda[k] = 0.;

        for (k = 0; k < 3; k++) {
/* Unitary eigenvectors */
          alpha[k] = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
/* Scattering mechanism probability of occurence */
          p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
          if (p[k] < 0.) p[k] = 0.;
          if (p[k] > 1.) p[k] = 1.;
          }

/* Mean scattering mechanism */
        al = 0;
        se = 0;

        for (k = 0; k < 3; k++) {
          al += alpha[k] * p[k];
          se -= p[k] * log(p[k] + eps);
          }
/* Scaling */
        se /= log(3.);

/*******************************************************************
********************************************************************
********************************************************************
Translated and adapted in c language from : IDL routine
; $Id: xbraggmodel_lia_polsarpro.pro,v 1.00 2008/12/15
;
; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR) / German Aerospace Center (DLR)
; Oberpfaffenhofen
; 82234 Wessling

; developed by:
; I. HAJNSEK
; H. SCHOEN
; T. JAGDHUBER
; K. PAPATHANASSIOU

; CONTACT: irena.hajnsek@dlr.de
;
; NAME: XBRAGGMODEL_LIA_POLSARPRO
;
; PURPOSE: CALCULATION OF XBRAGG-MODEL FOR INVERSION OF BETA_ROUGHNESS_ANGLE,DIELECTRIC CONSTANT OF SOIL AND SOIL MOISTURE BY COMPARING OF MEASURED ENTROPY AND ALPHA WITH CALCULATED ENTROPY AND ALPHA (X-BRAGG) USING LOCAL INCIDENCE ANGLE. 
;
; PARAMETERS:
;INIT= INTIALIZATION STRUCTURE
;DIELI=VECTOR OF POSSIBLE DIELECTRIC CONSTANT VALUES [-]
;DIELIFACTOR=SPACING OF THE LOOK-UP TABLE FOR THE DIELECTRIC CONSTANT [-]
;BETAFACTOR=SPACING OF THE LOOK-UP TABLE FOR THE ROUGHNESS ANGLE [-]
;BETA1= VECTOR OF ROUGHNESS ANGLES [RADIAN]
;
;EXAMPLE:
;xbraggmodel_lia_polsarpro,init,dieli,beta1,betafactor,dielifactor
;
; MODIFICATION HISTORY:
;
; 1- T.JAGDHUBER/H.SCHOEN    12.2008  Written
********************************************************************/

        minliadis= INIT_MINMAX; pos = 0; valid = 0;

        for (i=0; i<901; i++) {
          if (fabs(lia_blockrange[i]-angle[lig][col]) <= minliadis) {
            minliadis = fabs(lia_blockrange[i]-angle[lig][col]);
            pos = i;
            }
          }
        if ((se <= max_en[pos])&&(al <= max_al[pos])) valid = 1;

        if (valid == 1) {

          mask_out[lig][col] = 1.;
          mask_in_out[lig][col] = 1.;

          entropyest = 0.; alphaest = 0.;
          minimumdis = INIT_MINMAX; pos = 0;
          for (id=0; id<= Ndieli; id++) {
            //##################  Calculation of Bragg scattering
            braggs = cos(angle[lig][col]) - sqrt(dieli[id] - sin(angle[lig][col])*sin(angle[lig][col]));
            braggs = braggs / (cos(angle[lig][col]) + sqrt(dieli[id] - sin(angle[lig][col])*sin(angle[lig][col])));
            braggp = (dieli[id] - 1.)*(sin(angle[lig][col])*sin(angle[lig][col]) - dieli[id]*(1. + sin(angle[lig][col])*sin(angle[lig][col])));
            braggp = braggp / (dieli[id]*cos(angle[lig][col]) + sqrt(dieli[id] - sin(angle[lig][col])*sin(angle[lig][col])));
            braggp = braggp / (dieli[id]*cos(angle[lig][col]) + sqrt(dieli[id] - sin(angle[lig][col])*sin(angle[lig][col])));

            //##################  X-Bragg model
            for (ib=0; ib<= Nbeta; ib++) {
              t11est=(braggs+braggp)*(braggs+braggp);
              x = 2.*beta1[ib];
              if (x < eps) sinxx = 1.;
              else sinxx = sin(2.*beta1[ib])/(2.*beta1[ib]);
              t12est=(braggs+braggp)*(braggs-braggp)*sinxx;
              x = 4.*beta1[ib];
              if (x < eps) sinxx = 1.;
              else sinxx = sin(4.*beta1[ib])/(4.*beta1[ib]);
              t22est=0.5*(braggs-braggp)*(braggs-braggp)*(1.+sinxx);
              t33est=0.5*(braggs-braggp)*(braggs-braggp)*(1.-sinxx);

              //Eigen-values
              //eigen1=0.5*(t11est+t22est-sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est));
              //eigen2=0.5*(t11est+t22est+sqrt(t11est*t11est+4*t12est*t12est-2*t11est*t22est+t22est*t22est));
              //eigen3=t33est;

              //Eigen-vectors
              //eigenvec1 = -1.*(t11est-t22est-sqrt(t11est*t11est+4.*t12est*t12est-2.*t11est*t22est+t22est*t22est))/(t12est*sqrt(4.+fabs((-1*t11est+t22est+sqrt(t11est*t11est+4.*t12est*t12est-2.*t11est*t22est+t22est*t22est))/t12est)*fabs((-1*t11est+t22est+sqrt(t11est*t11est+4.*t12est*t12est-2.*t11est*t22est+t22est*t22est))/t12est)));
              //eigenvec2 = (t11est-t22est+sqrt(t11est*t11est+4.*t12est*t12est-2.*t11est*t22est+t22est*t22est))/(t12est*sqrt(4.+fabs((t11est-t22est+sqrt(t11est*t11est+4.*t12est*t12est-2.*t11est*t22est+t22est*t22est))/t12est)*fabs((t11est-t22est+sqrt(t11est*t11est+4.*t12est*t12est-2.*t11est*t22est+t22est*t22est))/t12est)));
              //eigenvec3 = 0.;

              //Probabilities  
              //probaest1=eigen1/(eigen1+eigen2+eigen3);
              //probaest2=eigen2/(eigen1+eigen2+eigen3);
              //probaest3=eigen3/(eigen1+eigen2+eigen3);

              //##################  Entropy
              //entropyest =-probaest1*log(probaest1)/log(3.)-probaest2*log(probaest2)/log(3.)-probaest3*log(probaest3)/log(3.);

              //##################  Alpha 
              //alphaest = probaest1*acos(fabs(eigenvec1))+probaest2*acos(fabs(eigenvec2))+probaest3*acos(fabs(eigenvec3));
        
              T[0][0][0] = eps + t11est;  T[0][0][1] = 0.;
              T[0][1][0] = eps + t12est;  T[0][1][1] = eps + 0.;
              T[0][2][0] = eps + 0.;      T[0][2][1] = eps + 0.;
              T[1][0][0] = eps + t12est;  T[1][0][1] = eps + 0.;
              T[1][1][0] = eps + t22est;  T[1][1][1] = 0.;
              T[1][2][0] = eps + 0.;      T[1][2][1] = eps + 0.;
              T[2][0][0] = eps + 0.;      T[2][0][1] = eps + 0.;
              T[2][1][0] = eps + 0.;      T[2][1][1] = eps + 0.;
              T[2][2][0] = eps + t33est;  T[2][2][1] = 0.;

              /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
              /* V complex eigenvecor matrix, lambda real vector*/
              Diagonalisation(3, T, V, lambda);

              for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
      
              for (k = 0; k < 3; k++) {
              /* Unitary eigenvectors */
                alpha[k] = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
              /* Scattering mechanism probability of occurence */
                p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
                if (p[k] < 0.) p[k] = 0.;
                if (p[k] > 1.) p[k] = 1.;
                }

              /* Mean scattering mechanism */
              alphaest = 0;
              entropyest = 0;

              for (k = 0; k < 3; k++) {
                alphaest += alpha[k] * p[k];
                entropyest -= p[k] * log(p[k] + eps);
                }
              /* Scaling */
              entropyest /= log(3.);
        
              //##################  Retrieval of minimum between entropy,alpha from (LUT) and entropy,alpha (data)
              substraction = sqrt((entropyest-se)*(entropyest-se)+(alphaest-al)*(alphaest-al));
              if (substraction < minimumdis) {
                minimumdis = substraction;
                pos = id;
                }
              }
            }

          //##################  Calculation of soil moisture (polynomial of Topp and Annan,1980)
          Mdc_out[lig][col] = 0.;
          Mmv_out[lig][col] = 0.;
          if (pos != Ndieli) {
            epsilon=pos*dielifactor+2.;
            Mdc_out[lig][col] =epsilon;
            Mmv_out[lig][col] = (-0.053+0.0292*epsilon-5.5e-4*epsilon*epsilon+4.3e-6*epsilon*epsilon*epsilon)*100.;
            }

          } /*valid_xbragg*/
        } /*valid_pixel*/
      }
    }


  write_block_matrix_float(out_dc, Mdc_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mv, Mmv_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_maskout, mask_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_maskinout, mask_in_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(angle, NligBlock[0]);
  free_matrix_float(Mdc_out, NligBlock[0]);
  free_matrix_float(Mmv_out, NligBlock[0]);
  free_matrix_float(mask_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  fclose(in_file_angle);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_dc); fclose(out_mv); fclose(out_maskout);
  
/********************************************************************
********************************************************************/

  return 1;
}


