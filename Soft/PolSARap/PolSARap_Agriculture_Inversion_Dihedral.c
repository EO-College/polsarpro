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

File  : PolSARap_Agriculture_Inversion_Dihedral.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2014
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

Description :  PolSARap Agriculture Showcase - Inversion

Inversion of dihedral scattering component for soil moisture

*--------------------------------------------------------------------

Translated and adapted in c language from : IDL routine
; $Id: mvdihedral_t.pro,v 1.00 2007/08/20
;
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
; thomas.jagdhuber.@dlr.de;

; NAME: MVDIHEDRAL_T
;
; PURPOSE: CALCULATION OF DIELECTRIC CONSTANT FOR SOIL AND TRUNK PLUS
; SOIL MOISTURE OF SOIL (TOPP-ANNAN) OUT OF DIHEDRAL COMPONENT OF
; THREE COMPONENT MODEL BASED DECOMPOSITION FOR T_MATRIX NOTATION
; (ALPHA,FD)
;
;PARAMETERS:
;ALPHA=1. DIHEDRAL COMPONENT OF THREE-COMPONENT DECOMPOSITION T-MATRIX
;         (SCATTERING MECHANISM)
;FD = 2. DIHEDRAL COMPONENT OF THREE-COMPONENT DECOMPOSITION T-MATRIX
;        (INTENSITY)
;MV_SOIL= CALCULATED SOIL MOISTURE
;DC_SOIL= CALCULATED DIELECTRIC CONSTANT OF SOIL
;DC_TRUNK= CALCULATED DIELECTRIC CONSTANT OF TRUNK
;
;EXAMPLE:
;mvdihedral_t,alpha,fd,theta,mv_soil, dc_soil, dc_trunk
;
;IMPORTANT
;DC_SOIL, DC_TRUNK VALUE RANGE: [2,41]
;
; MODIFICATION HISTORY:
;
; 1- T. JAGDHUBER 	08.2007   Written.
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
int FRESNEL(float *dieli, float *angle, float **Rs, float **Rp, int colsize, int rowsize);

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
  FILE *in_file_fd, *in_file_alpha, *in_file_theta, *in_file_mask, *in_file_ks;
  FILE *out_file_mv, *out_file_dc, *out_file_dt;
  char file_fd[FilePathLength], file_alpha[FilePathLength], file_theta[FilePathLength];
  char file_mask[FilePathLength], file_ks[FilePathLength], file_name[FilePathLength];
  
/* Internal variables */
  int lig, col, h, i, k, l;
  int FlagKs;
  int Unit, lutangle_size, esoil_size, etrunk_size;
  int t, pos1, pos2;
  int nelementepsoil, nelementeptrunk;
  float MinTheta, MaxTheta;
  float inca, lutangle_min, lutangle_max;
  float esoil_max, etrunk_max;
  float resulteqvmodel, resulteqhmodel;
  float scat;
  float MinAlphafresnel, MaxAlphafresnel;
  float MinFdsyn, MaxFdsyn;
  float Nmean, ep_soil_mean, ep_trunk_mean;  
  float fpos1, fpos2;
 
/* Matrix arrays */
  float **M_theta;
  float **M_fd;
  float **M_alpha;
  float **M_mask;
  float **M_dc;
  float **M_dt;
  float **M_mv;
  float **M_ks;
  
  float *lutangle;
  float *angle;
  float *esoil;
  float *etrunk;
  float **rssoil;
  float **rpsoil;
  float **rstrunk;
  float **rptrunk;
  float ***alphafresnel;
  float ***fdsyn;

//  int *colindalpha;
//  int *colindfd;        
  float *colindalpha;
  float *colindfd;        
  int *ep_soil;
  int *ep_trunk;
  float *colminalpha;
  float *colminfd;
  float *abscolsoil;

  float *Tmp;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Agriculture_Inversion_Dihedral.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-ifd 	input fd file\n");
strcat(UsageHelp," (string)	-ial 	input alpha file\n");
strcat(UsageHelp," (string)	-itt 	input theta file\n");
strcat(UsageHelp," (string)	-imk 	input mask file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
strcat(UsageHelp," (float) 	-dis 	max soil dielectric constant\n");
strcat(UsageHelp," (float) 	-dit 	max trunk dielectric constant\n");
strcat(UsageHelp," (int)   	-inc 	increment inc angle LUT\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-iks 	input ks file\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
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
  get_commandline_prm(argc,argv,"-ifd",str_cmd_prm,file_fd,1,UsageHelp);
  get_commandline_prm(argc,argv,"-itt",str_cmd_prm,file_theta,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ial",str_cmd_prm,file_alpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-imk",str_cmd_prm,file_mask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-un",int_cmd_prm,&Unit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dis",flt_cmd_prm,&esoil_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dit",flt_cmd_prm,&etrunk_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",flt_cmd_prm,&inca,1,UsageHelp);
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

  FlagKs = 0;strcpy(file_ks,"");
  get_commandline_prm(argc,argv,"-iks",str_cmd_prm,file_ks,0,UsageHelp);
  if (strcmp(file_ks,"") != 0) FlagKs = 1;

  }

/********************************************************************
********************************************************************/

  check_file(file_fd);
  check_file(file_theta);
  check_file(file_alpha);
  check_file(file_mask);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid); 
  if (FlagKs == 1) check_file(file_ks);

  Ncol = Sub_Ncol;
  
/* INPUT FILE OPENING*/
  if ((in_file_fd = fopen(file_fd, "rb")) == NULL)
    edit_error("Could not open input file : ", file_fd);

  if ((in_file_alpha = fopen(file_alpha, "rb")) == NULL)
    edit_error("Could not open input file : ", file_alpha);

  if ((in_file_theta = fopen(file_theta, "rb")) == NULL)
    edit_error("Could not open input file : ", file_theta);
  
  if ((in_file_mask = fopen(file_mask, "rb")) == NULL)
    edit_error("Could not open input file : ", file_mask);
  
  if (FlagKs == 1) 
    if ((in_file_ks = fopen(file_ks, "rb")) == NULL)
      edit_error("Could not open input file : ", file_ks);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_dihed_dc_soil.bin");
  if ((out_file_dc = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_dihed_dc_trunk.bin");
  if ((out_file_dt = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_dihed_mv_soil.bin");
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
  /* Mfd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Malpha = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmask = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdc = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdt = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
 
  if (FlagKs == 1) {
    /* Mks = Nlig*Sub_Ncol */
    NBlockA += Sub_Ncol; NBlockB += 0;
    }

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

  M_fd = matrix_float(NligBlock[0], Sub_Ncol);
  M_alpha = matrix_float(NligBlock[0], Sub_Ncol);
  M_theta = matrix_float(NligBlock[0], Sub_Ncol);
  M_mask = matrix_float(NligBlock[0], Sub_Ncol);
  M_dc = matrix_float(NligBlock[0], Sub_Ncol);
  M_dt = matrix_float(NligBlock[0], Sub_Ncol);
  M_mv = matrix_float(NligBlock[0], Sub_Ncol);
  if (FlagKs == 1) M_ks = matrix_float(NligBlock[0], Sub_Ncol);
  
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
//---calculation of alpha and fd from Fresnel surface scattering model 

  esoil_size = ceil(esoil_max); //maximum value of the dc_soil in LUT
  esoil = vector_float(esoil_size);
  for (k =0; k < esoil_size; k++)
    esoil[k] = 2. + (float)k;

  etrunk_size = ceil(etrunk_max); //maximum value of the dc_trunk in LUT
  etrunk = vector_float(etrunk_size);
  for (k =0; k < etrunk_size; k++)
    etrunk[k] = 2. + (float)k;

//  colindalpha = vector_int(esoil_size);
//  colindfd = vector_int(esoil_size);
  colindalpha = vector_float(esoil_size);
  colindfd = vector_float(esoil_size);
  ep_soil = vector_int(esoil_size);
  ep_trunk = vector_int(esoil_size);
  colminalpha = vector_float(esoil_size);
  colminfd = vector_float(esoil_size);
  abscolsoil = vector_float(esoil_size);

/********************************************************************
********************************************************************/
//---calculation of FRESNEL scattering coefficients of soil and trunk plane

//---reflection of the trunk
  rstrunk = matrix_float(etrunk_size,lutangle_size);
  rptrunk = matrix_float(etrunk_size,lutangle_size);

  angle = vector_float(lutangle_size);
  for (h=0; h<lutangle_size; h++) angle[h] = 90. - lutangle[h];
  
  FRESNEL(etrunk,angle,rstrunk,rptrunk,etrunk_size,lutangle_size);

//---reflection of the soil
  rssoil = matrix_float(esoil_size,lutangle_size);
  rpsoil = matrix_float(esoil_size,lutangle_size);
 
  FRESNEL(esoil,lutangle,rssoil,rpsoil,esoil_size,lutangle_size);

//;---calculation of alpha and fd
  alphafresnel = matrix3d_float(esoil_size,etrunk_size,lutangle_size);
  fdsyn = matrix3d_float(esoil_size,etrunk_size,lutangle_size);
  for (h=0; h<lutangle_size; h++) {
    for (k=0; k<esoil_size; k++) {
      for (i=0; i<etrunk_size; i++) {
        resulteqvmodel = rptrunk[i][h]*rpsoil[k][h];
        resulteqhmodel = rstrunk[i][h]*rssoil[k][h];
        //---alpha [T-Matrix] (here a differential phase Phi for different propagation throught vegetation of different polarizations is neglegted)
        alphafresnel[k][i][h]=(resulteqhmodel-resulteqvmodel)/(resulteqhmodel+resulteqvmodel);
        //---fd [T-matrix] (here a differential phase Phi for different propagation throught vegetation of different polarizations is neglegted)
        fdsyn[k][i][h]=0.5*(resulteqhmodel+resulteqvmodel)*(resulteqhmodel+resulteqvmodel);
        }
      }
    }
      
/********************************************************************
********************************************************************/
/* DATA PROCESSING */
rewind(in_file_theta);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  read_block_matrix_float(in_file_fd, M_fd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_alpha, M_alpha, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_mask, M_mask, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_file_theta, M_theta, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if (FlagKs == 1) read_block_matrix_cmplx(in_file_ks, M_ks, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (M_mask[lig][col] == 2.) {
          if (Unit == 1) M_theta[lig][col] = M_theta[lig][col]*180./pi; //in deg
      
          if (FlagKs == 1) {
            //---modified fresnel scattering
            //---calculation of fd accounting for scattering loss
            //---calculation of scattering loss term (S) [see equation 7. in LEE,KHUU and ZANG]
            //gaussian scattering loss (after BECKMANN & SPIZZICHINO, 1961)
            scat = exp(-2.*M_ks[lig][col]*M_ks[lig][col]*cos(M_theta[lig][col]*pi/180.)*cos(M_theta[lig][col]*pi/180.));
            M_fd[lig][col] = M_fd[lig][col]/(scat*scat);
            }
          
          if (my_isfinite(M_theta[lig][col]) != 0) {
            t=round((M_theta[lig][col]-lutangle_min)/inca);
            MinAlphafresnel = alphafresnel[0][0][t]; MaxAlphafresnel = alphafresnel[0][0][t];
            MinFdsyn = fdsyn[0][0][t]; MaxFdsyn = fdsyn[0][0][t];
            for (k = 0; k < esoil_size; k++) 
              for (l = 0; l < etrunk_size; l++) {
                if (alphafresnel[k][l][t] <= MinAlphafresnel) MinAlphafresnel = alphafresnel[k][l][t];
                if (MaxAlphafresnel <= alphafresnel[k][l][t]) MaxAlphafresnel = alphafresnel[k][l][t];
                if (fdsyn[k][l][t] <= MinFdsyn) MinFdsyn = fdsyn[k][l][t];
                if (MaxFdsyn <= fdsyn[k][l][t]) MaxFdsyn = fdsyn[k][l][t];
                }
            if ((MinAlphafresnel < M_alpha[lig][col])&&(M_alpha[lig][col] != 0.)&&(M_alpha[lig][col] < MaxAlphafresnel)&&(MinFdsyn < M_fd[lig][col])&&(M_fd[lig][col] < MaxFdsyn)) {
              //;---calculation of minimum lines
              for (k = 0; k < esoil_size; k++) {
                pos1 = 0; colminalpha[k] = fabs(alphafresnel[k][0][t] - M_alpha[lig][col]);
                for (i = 0; i < etrunk_size; i++) {
                  if (fabs(alphafresnel[k][i][t] - M_alpha[lig][col]) <= colminalpha[k]) {
                    colminalpha[k] = fabs(alphafresnel[k][i][t] - M_alpha[lig][col]);
                    pos1 = i;
                    }
                  }             
                if ((pos1 == etrunk_size-1)||(pos1 == 0)) fpos1 = 0.f/0.f; else fpos1 = (float)pos1;
                colindalpha[k] = fpos1;
                pos2 = 0; colminfd[k] = fabs(fdsyn[k][0][t] - M_fd[lig][col]);
                for (i = 0; i < etrunk_size; i++) {
                  if (fabs(fdsyn[k][i][t] - M_fd[lig][col]) <= colminfd[k]) {
                    colminfd[k] = fabs(fdsyn[k][i][t] - M_fd[lig][col]);
                    pos2 = i;
                    }
                  }
                if ((pos2 == etrunk_size-1)||(pos2 == 0)) fpos2 = 0.f/0.f; else fpos2 = (float)pos2;
                colindfd[k] = fpos2;        
                }
              //---calculation of minimum
              for (k = 0; k < esoil_size; k++) 
                abscolsoil[k] = fabs(colindalpha[k]-colindfd[k]);
              //---find the ep_soil and ep_trunk values
              nelementepsoil = 0; ep_soil[0] = -1;
              for (k = 0; k < esoil_size; k++) {
                if (abscolsoil[k] < 1.1) {
                  ep_soil[nelementepsoil] = k;
                  nelementepsoil++;
                  }
                }
              if ((nelementepsoil == 0)||(nelementepsoil == 1)) {
                if ((my_isfinite(ep_soil[0]) == 0)||(ep_soil[0] == -1)) ep_trunk[0] = 0.i/0.i;
                else ep_trunk[0] = colindalpha[ep_soil[0]];
                if ((my_isfinite(ep_soil[0]) == 0)||(ep_soil[0] == -1)) ep_soil[0] = 0.i/0.i;
                } else {
                nelementeptrunk = 0;
                for (k = 0; k < nelementepsoil; k++) {
                  if (my_isfinite(ep_soil[k]) != 0) {
                    ep_trunk[nelementeptrunk] = colindalpha[ep_soil[k]];
                    nelementeptrunk++;
                    }
                  }
                }
              ep_soil_mean = 0.; Nmean = 0.;
              for (k = 0; k < nelementepsoil; k++) {
                if (my_isfinite(ep_soil[k]) != 0) {
                  ep_soil_mean += ep_soil[k];
                  Nmean += 1.;
                  }
                }
              if (Nmean != 0.) ep_soil_mean = 2. + ep_soil_mean/Nmean;  
              else ep_soil_mean = 0.f/0.f;
              
              ep_trunk_mean = 0.; Nmean = 0.;
              for (k = 0; k < nelementeptrunk; k++) {
                if (my_isfinite(ep_trunk[k]) != 0) {
                  ep_trunk_mean += ep_trunk[k];
                  Nmean += 1.;
                  }
                }
              if (Nmean != 0.) ep_trunk_mean = 2. + ep_trunk_mean/Nmean;  
              else ep_trunk_mean = 0.f/0.f;

              M_dc[lig][col] = ep_soil_mean;
              M_dt[lig][col] = ep_trunk_mean;
              M_mv[lig][col] = (-0.053 + 0.0292*ep_soil_mean - 5.5e-4*ep_soil_mean*ep_soil_mean + 4.3e-6*ep_soil_mean*ep_soil_mean*ep_soil_mean)*100.;
              } else {
              M_dc[lig][col] = 0.f/0.f;
              M_dt[lig][col] = 0.f/0.f;
              M_mv[lig][col] = 0.f/0.f;
              } // my_finite
            } else {
            M_dc[lig][col] = 0.f/0.f;
            M_dt[lig][col] = 0.f/0.f;
            M_mv[lig][col] = 0.f/0.f;
            } // my_finite
          } else {
          M_dc[lig][col] = 0.f/0.f;
          M_dt[lig][col] = 0.f/0.f;
          M_mv[lig][col] = 0.f/0.f;
          } // Mask
        } else {
        M_dc[lig][col] = 0.;
        M_dt[lig][col] = 0.;
        M_mv[lig][col] = 0.;
        } // valid
      } // col
    } // lig
  write_block_matrix_float(out_file_dc, M_dc, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file_dt, M_dt, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
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
  fclose(in_file_fd);
  fclose(in_file_alpha);
  fclose(in_file_theta);
  fclose(in_file_mask);

/* OUTPUT FILE CLOSING*/
  fclose(out_file_dc);
  fclose(out_file_dt);
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
; Thomas.jagdhuber@dlr.de
;
; NAME: FRESNEL
; 
; PURPOSE: This program calculates the Fresnel scattering coefficients
;          for different values of angle of incidence and different
;          values of dielectric constant of the surface (take care: no
;          intensity values are returned!)
; 
; SYNTAX: Fresnel,dieli,angle,Rs,Rp
; 
; PARAMETERS:
;ANGLE = ANGLE OF INCIDENCE [RADIAN]
;DIELI = DIELECTRIC CONSTANT OF SURFACE
;RS =FRESNEL SCATTERING COEFFICIENT PERPENDICULAR TO INICIDENCE
;    PLANE (HH)
;RP = FRESNEL SCATTERING COEFFICIENT PARALLEL TO INCIDENCE
;     PLANE (VV) 
;
; MODIFICATION HISTORY:
;
; 1- T.Jagdhuber	2007/08   Written.
********************************************************************/
int FRESNEL(float *dieli, float *angle, float **Rs, float **Rp, int colsize, int rowsize)
{
int h,i;
float ang;

if (colsize == 0) colsize = 1;
if (rowsize == 0) rowsize = 1;

if ((colsize > 1)&&(rowsize > 1)) { 
  for (h=0; h<colsize; h++) {
    for (i=0; i<rowsize; i++) {
      ang = angle[i]*pi/180.;
      Rs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
      Rp[h][i] = (dieli[h]*cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang))) / (dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
      }
    }
  }

if ((colsize == 1)&&(rowsize > 1)) { 
  h=0;
  for (i=0; i<rowsize; i++) {
    ang = angle[i]*pi/180.;
    Rs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    Rp[h][i] = (dieli[h]*cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang))) / (dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    }
 }

if ((colsize > 1)&&(rowsize == 1)) { 
  i=0;
  ang = angle[i]*pi/180.;
  for (h=0; h<colsize; h++) {
    Rs[h][i] = (cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang)))/(cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    Rp[h][i] = (dieli[h]*cos(ang)-sqrt(dieli[h]-sin(ang)*sin(ang))) / (dieli[h]*cos(ang)+sqrt(dieli[h]-sin(ang)*sin(ang)));
    }
  }

return 1;
}

