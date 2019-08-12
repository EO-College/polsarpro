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

File  : PolSARap_Agriculture_Inversion_Surface.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2014
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

Description :  PolSARap Agriculture Showcase - Inversion

Inversion of surface scattering component for soil moisture

*--------------------------------------------------------------------

Translated and adapted in c language from : IDL routine
; $Id: mvsurface_t.pro, v 1.00 2007/09/05
;
; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR) / German Aerospace Center (DLR)
; Oberpfaffenhofen
; 82234 Wessling

; developed by:
; T. JAGDHUBER
; I. HAJNSEK
; K. PAPATHANASSIOU
;
; CONTACT:
; Thomas.jagdhuber@dlr.de

; NAME: MVSURFACE_T
;
; PURPOSE: CALCULATION OF DIELECTRIC CONSTANT FOR SOIL PLUS SOIL 
; MOISTURE OF SOIL (TOPP-ANNAN) OUT OF SURFACE COMPONENT OF
; THREE-COMPONENT MODEL-BASED DECOMPOSITION FOR T_MATRIX NOTATION
; (BETA,FS)
;
;PARAMETERS:
;BETA=1. SURFACE COMPONENT OF THREE-COMPONENT DECOMPOSITION T-MATRIX
;        (SCATTERING MECHANISM)
;FS = 2. SURFACE COMPONENT OF THREE-COMPONENT DECOMPOSITION T-MATRIX
;        (INTENSITY)
;THETA= LOCAL INCIDENCE ANGLE IN RADIAN
;MV_SOIL= CALCULATED SOIL MOISTURE
;DC_SOIL= CALCULATED DIELECTRIC CONSTANT OF SOIL
;
;EXAMPLE:
;mvsurface_t,beta,fs,theta,mv_soil,dc_soil
;
;IMPORTANT
;DC_SOIL VALUE RANGE: [2,41]
;
; MODIFICATION HISTORY:
; 1- T. JAGDHUBER  	09.2007   Written.
; 2- T. JAGDHUBER  	04.2008   LIA processing enabled
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
int BRAGG(float *dieli, float *angle, float **braggs, float **braggp, int colsize, int rowsize);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */
  FILE *in_file_fs, *in_file_beta, *in_file_theta, *in_file_mask;
  FILE *out_file_mv, *out_file_dc;
  char file_fs[FilePathLength], file_beta[FilePathLength], file_theta[FilePathLength];
  char file_mask[FilePathLength], file_name[FilePathLength];
  
/* Internal variables */
  int lig, col, k;
  int Unit, t, lutangle_size, esoil_size, pos1;
  float MinTheta, MaxTheta;
  float MinBetabragg, MaxBetabragg;
  float inca, lutangle_min, lutangle_max;
  float colminbeta, ep_soil, esoil_max;

/* Matrix arrays */
  float **M_theta;
  float **M_fs;
  float **M_beta;
  float **M_mask;
  float **M_dc;
  float **M_mv;
  float *lutangle;
  float *dieli;
  float **braggs;
  float **braggp;
  float **betabragg;
  float *Tmp;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Agriculture_Inversion_Surface.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifs 	input fs file\n");
strcat(UsageHelp," (string)	-ibe 	input beta file\n");
strcat(UsageHelp," (string)	-itt 	input theta file\n");
strcat(UsageHelp," (string)	-imk 	input mask file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
strcat(UsageHelp," (float) 	-die 	max dielectric constant\n");
strcat(UsageHelp," (int)   	-inc 	increment inc angle LUT\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-ifs",str_cmd_prm,file_fs,1,UsageHelp);
  get_commandline_prm(argc,argv,"-itt",str_cmd_prm,file_theta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ibe",str_cmd_prm,file_beta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-imk",str_cmd_prm,file_mask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-un",int_cmd_prm,&Unit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-die",flt_cmd_prm,&esoil_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",flt_cmd_prm,&inca,1,UsageHelp);
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

  }

/********************************************************************
********************************************************************/

  check_file(file_fs);
  check_file(file_theta);
  check_file(file_beta);
  check_file(file_mask);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid); 

  Ncol = Sub_Ncol;
  
/* INPUT FILE OPENING*/
  if ((in_file_fs = fopen(file_fs, "rb")) == NULL)
    edit_error("Could not open input file : ", file_fs);

  if ((in_file_beta = fopen(file_beta, "rb")) == NULL)
    edit_error("Could not open input file : ", file_beta);

  if ((in_file_theta = fopen(file_theta, "rb")) == NULL)
    edit_error("Could not open input file : ", file_theta);
  
  if ((in_file_mask = fopen(file_mask, "rb")) == NULL)
    edit_error("Could not open input file : ", file_mask);
  
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_surf_dc_soil.bin");
  if ((out_file_dc = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_surf_mv_soil.bin");
  if ((out_file_mv = fopen(file_name, "wb")) == NULL)
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

  /* Mtheta = Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mfs = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mbeta = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmask = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdc = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmv = Nlig*Sub_Ncol */
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

  M_fs = matrix_float(NligBlock[0], Sub_Ncol);
  M_beta = matrix_float(NligBlock[0], Sub_Ncol);
  M_theta = matrix_float(NligBlock[0], Sub_Ncol);
  M_mask = matrix_float(NligBlock[0], Sub_Ncol);
  M_dc = matrix_float(NligBlock[0], Sub_Ncol);
  M_mv = matrix_float(NligBlock[0], Sub_Ncol);

  Tmp = vector_float(Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
       
/********************************************************************
********************************************************************/
//---calculation of LUT incidence angle (out of Incidence angle array)
  for (lig =0; lig < Off_lig; lig++)
    fread(&Tmp[0], sizeof(float), Ncol, in_file_theta);
  MinTheta = 360.; MaxTheta = 0.;
  for (lig =0; lig < Sub_Nlig; lig++) {
    fread(&Tmp[0], sizeof(float), Ncol, in_file_theta);
    for (col =0; col < Sub_Ncol; col++) {
      if (Unit == 1) Tmp[col+Off_col] = Tmp[col+Off_col]*180./pi;
      if (Tmp[col+Off_col] <= MinTheta) MinTheta = Tmp[col+Off_col];
      if (MaxTheta <= Tmp[col+Off_col]) MaxTheta = Tmp[col+Off_col];
      }
    }

  lutangle_min=round(MinTheta/inca)*inca - inca; //deg
  lutangle_max=round(MaxTheta/inca)*inca + inca; //deg
  
//---generate an angle vector from minangle to maxangle with 0.1° increment
  lutangle_size = 1 + round((lutangle_max-lutangle_min)/inca);
  lutangle = vector_float(lutangle_size);
  for (k =0; k < lutangle_size; k++)
    lutangle[k]= lutangle_min + (float)k * inca; //deg

/********************************************************************
********************************************************************/
//---calculation of beta and fs from Bragg surface scattering model 

  esoil_size = ceil(esoil_max); //maximum value of the dc_soil in LUT
  dieli = vector_float(esoil_size);
  for (k =0; k < esoil_size; k++)
    dieli[k] = 2. + (float)k;
    
/********************************************************************
********************************************************************/
//---calculation of bragg coefficients
  braggs = matrix_float(esoil_size,lutangle_size);
  braggp = matrix_float(esoil_size,lutangle_size);
  betabragg = matrix_float(esoil_size,lutangle_size);
 
  BRAGG(dieli,lutangle,braggs,braggp,esoil_size,lutangle_size);

//;---beta T-Matrix notation
  for (lig = 0; lig < esoil_size; lig++)
    for (col = 0; col < lutangle_size; col++)
      betabragg[lig][col] = (braggs[lig][col]-braggp[lig][col]) / (braggs[lig][col]+braggp[lig][col]+eps);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
rewind(in_file_theta);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  read_block_matrix_float(in_file_fs, M_fs, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_beta, M_beta, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_mask, M_mask, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_theta, M_theta, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (M_mask[lig][col] == 1.) {
          if (Unit == 1) M_theta[lig][col] = M_theta[lig][col]*180./pi;
          if (my_isfinite(M_theta[lig][col]) != 0) {
            t=round((M_theta[lig][col]-lutangle_min)/inca);
            MinBetabragg = betabragg[0][t]; MaxBetabragg = betabragg[0][t];
            for (k = 0; k < esoil_size; k++) {
              if (betabragg[k][t] <= MinBetabragg) MinBetabragg = betabragg[k][t];
              if (MaxBetabragg <= betabragg[k][t]) MaxBetabragg = betabragg[k][t];
              }
            if ((MinBetabragg < M_beta[lig][col])&&(M_beta[lig][col] != 0.)&&(M_beta[lig][col] < MaxBetabragg)) {
              //;---calculation of minimum beta
              pos1 = 0; colminbeta = fabs(betabragg[0][t] - M_beta[lig][col]);
              for (k = 0; k < esoil_size; k++) {
                if (fabs(betabragg[k][t] - M_beta[lig][col]) <= colminbeta) {
                  colminbeta = fabs(betabragg[k][t] - M_beta[lig][col]);
                  pos1 = k;
                  }
                }
              //;---find the ep_soil and ep_trunk values
              if ((pos1 == esoil_size-1)||(pos1 == 0)) {
                M_dc[lig][col] = 0.f/0.f;
                M_mv[lig][col] = 0.f/0.f;
                } else {
                //;---calculation of soil moisture (polynomial of Topp and Annan,1980)
                ep_soil = (float)pos1 + 2.;          
                M_dc[lig][col] = ep_soil;
                M_mv[lig][col] = (-0.053 + 0.0292*ep_soil - 5.5e-4*ep_soil*ep_soil + 4.3e-6*ep_soil*ep_soil*ep_soil)*100.;
                }
              } else {
              M_dc[lig][col] = 0.f/0.f;
              M_mv[lig][col] = 0.f/0.f;
              } // Min/MaxBetabragg
            } else {
            M_dc[lig][col] = 0.f/0.f;
            M_mv[lig][col] = 0.f/0.f;
            } // my_finite
          } else {
          M_dc[lig][col] = 0.f/0.f;
          M_mv[lig][col] = 0.f/0.f;
          } // mask   
        } else {
        M_dc[lig][col] = 0.;
        M_mv[lig][col] = 0.;
        } // valid       
      } // col
    } // lig
  write_block_matrix_float(out_file_dc, M_dc, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file_mv, M_mv, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(M_theta);
  free_matrix_float(Valid, NligBlock[0]);
  free_matrix_float(M_fs, NligBlock[0]);
  free_matrix_float(M_beta, NligBlock[0]);
  free_matrix_float(M_mask, NligBlock[0]);
  free_matrix_float(M_dc, NligBlock[0]);
  free_matrix_float(M_mv, NligBlock[0]);
  
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  fclose(in_file_fs);
  fclose(in_file_beta);
  fclose(in_file_theta);
  fclose(in_file_mask);

/* OUTPUT FILE CLOSING*/
  fclose(out_file_dc);
  fclose(out_file_mv);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routine
$Id: BRAGG,dieli,angle,braggs,braggp
; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
;
; developed by:
; T. JAGDHUBER
; I. HAJNSEK
; K. PAPATHANASSIOU
;
; CONTACT:
; thomas.jagdhuber@dlr.de
;
; NAME: BRAGG
; 
; PURPOSE: This program calculates the bragg scattering coefficients
; for different values of angle of incidence and different values of
; dielectric constant of the surface (take care: no intensity values
; are returned!)
; 
; SYNTAX: BRAGG,dieli,angle,braggs,braggp
; 
; PARAMETERS:
;ANGLE = ANGLE OF INCIDENCE [RADIAN]
;DIELI = DIELECTRIC CONSTANT OF SURFACE
;BRAGGS =BRAGG SCATTERING COEFFICIENT PERPENDICULAR TO INICIDENCE
;        PLANE (HH)
;BRAGGP = BRAGG SCATTERING COEFFICIENT PARALLEL TO INCIDENCE
;         PLANE (VV) 
;
; MODIFICATION HISTORY:
; 1- T.Jagdhuber 	2007/05/07   Written.
********************************************************************/
int BRAGG(float *dieli, float *angle, float **braggs, float **braggp, int colsize, int rowsize)
{
int h,i;
float ang;

if (colsize == 0) colsize = 1;
if (rowsize == 0) rowsize = 1;

if ((colsize > 1)&&(rowsize > 1)) { 
  for (h=0; h<colsize; h++) {
    for (i=0; i<rowsize; i++) {
      ang = angle[i]*pi/180.;
      braggs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));    
      braggp[h][i] = ((dieli[h]-1.)*(sin(ang)*sin(ang)-dieli[h]*(1.+sin(ang)*sin(ang))));
      braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
      braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
      }
    }
  }

if ((colsize == 1)&&(rowsize > 1)) { 
  h=0;
  for (i=0; i<rowsize; i++) {
    ang = angle[i]*pi/180.;
    braggs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    braggp[h][i] = ((dieli[h]-1.)*(sin(ang)*sin(ang)-dieli[h]*(1.+sin(ang)*sin(ang))));
    braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    }
 }

if ((colsize > 1)&&(rowsize == 1)) { 
  i=0;
  ang = angle[i]*pi/180.;
  for (h=0; h<colsize; h++) {
    braggs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    braggp[h][i] = ((dieli[h]-1.)*(sin(ang)*sin(ang)-dieli[h]*(1.+sin(ang)*sin(ang))));
    braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    }
  }

if ((colsize == 1)&&(rowsize == 1)) { 
  h=0;
  i=0;
  ang = angle[i]*pi/180.;
  braggs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
  braggp[h][i] = ((dieli[h]-1.)*(sin(ang)*sin(ang)-dieli[h]*(1.+sin(ang)*sin(ang))));
  braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
  braggp[h][i] = braggp[h][i]/(dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
  }

return 1;
}