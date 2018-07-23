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

File  : PolSARap_Agriculture_Decomposition.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
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

Description :  PolSARap Agriculture Showcase - Decomposition

Polarimetric, three-component, model-based decomposition

*--------------------------------------------------------------------

Translated and adapted in c language from : IDL routine
; $Id: fd3t_v07.pro,v 1.00 2007/11/16
;**************************************************************
; Copyright (c) Pol-InSAR Working Group - All rights reserved
; Microwaves and Radar Institute (DLR-HR)/German Aerospace Center(DLR)
; Oberpfaffenhofen
; 82234 Wessling
; 
; developed by:
; T. JAGDHUBER
; I. HAJNSEK
; K. PAPATHANASSIOU

; CONTACT:
; thomas.jagdhuber@dlr.de
;
; NAME: fd3t
;
; PURPOSE: CALCULATION OF THREE COMPONENT MODEL-BASED DECOMPOSITION ON
; THE T-MATRIX ELEMENTS AFTER YAMAGUCHI 2006 PAPER:A FOUR COMPONENT 
; DECOMPOSITION OF POLSAR IMAGES BASED ON THE COHERENCY MATRIX  PLUS 
; EIGENVALUE-BASED CORRECTION OF VOLUME POWER = MATHEMATICAL
; CONSTRAINT (VAN ZYL ET AL.,2008)
;
;PARAMETERS:
;
;INPUT:
;SHH=INPUTIMAGE WITH HH-POL
;SVV=INPUTIMAGE WITH VV-POL
;SXX=INPUTIMAGE WITH XX-POL
;XSB=BOX SIZE OF SMOOTH BOX IN X-DIRECTION
;YSB=BOX SIZE OF SMOOTH BOX IN Y-DIRECTION
;OUTPUT:
;ALPHA=DECOMPOSED SCATTERING MECHANISM: DIHEDRAL
;BETA=DECOMPOSED SCATTERING MECHANISM:SURFACE
;FD=DECOMPOSED INTENSITY:DIHEDRAL
;FS=DECOMPOSED INTENSITY:SURFACE
;FV=DECOMPOSED INTENSITY:VOLUME
;KEYWORDS:
;PD=POWER:DIHEDRAL
;PS=POWER:SURFACE
;PV=POWER:VOLUME
;MASK= BIT-MASK,WHICH SHOWS WHERE ARE DIHEDRAL (1) AND WHERE ARE 
;      SURFACE (0) AREAS
;LIA=LOCAL INCIDENCE ANGLE
;ZYL=FLAG FOR EIGENVALUE-BASED CORRECTION OF VOLUME POWER
;
; MODIFICATION HISTORY:
; 1- T. JAGDHUBER	06.2007   Written.
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
  FILE *out_alpha, *out_beta, *out_mask;
  FILE *out_fs, *out_fd, *out_fv;
  FILE *out_Ps, *out_Pd, *out_Pv;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  float T11, T22, T33, T12r, T12i;
  float fvcorr, T11sub, T22sub, HHVVre;

/* Matrix arrays */
  float ***M_avg;
  float **M_alpha;
  float **M_beta;
  float **M_mask;
  float **M_fs;
  float **M_fd;
  float **M_fv;
  float **M_Ps;
  float **M_Pd;
  float **M_Pv;
 
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Agriculture_Decomposition.exe\n");
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
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_alpha.bin");
  if ((out_alpha = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_agri_beta.bin");
  if ((out_beta = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_agri_fs.bin");
  if ((out_fs = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_fd.bin");
  if ((out_fd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_fv.bin");
  if ((out_fv = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_Ps.bin");
  if ((out_Ps = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_Pd.bin");
  if ((out_Pd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_agri_Pv.bin");
  if ((out_Pv = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_agri_mask.bin");
  if ((out_mask = fopen(file_name, "wb")) == NULL)
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

  /* Malpha = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mbeta = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mmask = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mfs = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mfd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mfv = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MPs = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MPd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MPv = Nlig*Sub_Ncol */
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
  M_alpha = matrix_float(NligBlock[0], Sub_Ncol);
  M_beta = matrix_float(NligBlock[0], Sub_Ncol);
  M_mask = matrix_float(NligBlock[0], Sub_Ncol);
  M_fs = matrix_float(NligBlock[0], Sub_Ncol);
  M_fd = matrix_float(NligBlock[0], Sub_Ncol);
  M_fv = matrix_float(NligBlock[0], Sub_Ncol);
  M_Ps = matrix_float(NligBlock[0], Sub_Ncol);
  M_Pd = matrix_float(NligBlock[0], Sub_Ncol);
  M_Pv = matrix_float(NligBlock[0], Sub_Ncol);

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
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Sub_Ncol);
  }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        T11 = M_avg[T311][lig][col];
        T22 = M_avg[T322][lig][col];
        T33 = M_avg[T333][lig][col];
        T12r = M_avg[T312_re][lig][col];
        T12i = M_avg[T312_im][lig][col];
        
        //;---substraction of fv(t33) from t11 and t22
        M_fv[lig][col] = 4.*T33;
        //;---eigenvalue-based correction of volume power (van Zyl et al., 2008)
        fvcorr = fabs(T11 + 2.*T22 - sqrt(T11*T11 +8.*(T12r*T12r+T12i*T12i) -4.*T11*T22 +4.*T22*T22));
        if (fvcorr < M_fv[lig][col]) M_fv[lig][col] = fvcorr;

        T11sub = T11 - M_fv[lig][col]/2.;
        T22sub = T22 - M_fv[lig][col]/4.;
        
        //;---C-matrix criterium for decision wether dihedral or surface dominance
        HHVVre = (T11 - T22)/2.;
        HHVVre = HHVVre - M_fv[lig][col]/8.;
        
        //;---decision on dominant scattering type (dihedral or surface)

        //;---surface dominant
        if (HHVVre > 0.) {
          M_mask[lig][col]=1.;
          M_alpha[lig][col]=0.; 
          M_fs[lig][col] = T11sub;
          M_beta[lig][col] = -1*sqrt(T12r*T12r+T12i*T12i)/M_fs[lig][col];
          M_fd[lig][col] = T22sub - M_fs[lig][col]*M_beta[lig][col]*M_beta[lig][col];
          M_Ps[lig][col] = M_fs[lig][col]*(1. + M_beta[lig][col]*M_beta[lig][col]);
          M_Pd[lig][col] = M_fd[lig][col];
          }
        
        //;---dihedral dominant
        if (HHVVre <= 0.) {
          M_mask[lig][col]=2.;
          M_beta[lig][col]=0.;
          M_fd[lig][col] = T22sub;
          M_alpha[lig][col] = sqrt(T12r*T12r+T12i*T12i)/M_fd[lig][col];
          M_fs[lig][col] = T11sub - M_fd[lig][col]*M_alpha[lig][col]*M_alpha[lig][col];
          M_Pd[lig][col] = M_fd[lig][col]*(1. + M_alpha[lig][col]*M_alpha[lig][col]);
          M_Ps[lig][col] = M_fs[lig][col];
          }

        M_Pv[lig][col] = M_fv[lig][col];
        } else {
        M_alpha[lig][col] = 0.;
        M_beta[lig][col] = 0.;
        M_mask[lig][col] = 0.;
        M_fs[lig][col] = 0.;
        M_fd[lig][col] = 0.;
        M_fv[lig][col] = 0.;
        M_Ps[lig][col] = 0.;
        M_Pd[lig][col] = 0.;
        M_Pv[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_alpha, M_alpha, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_beta, M_beta, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mask, M_mask, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_fs, M_fs, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_fd, M_fd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_fv, M_fv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Ps, M_Ps, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Pd, M_Pd, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Pv, M_Pv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_alpha, NligBlock[0]);
  free_matrix_float(M_beta, NligBlock[0]);
  free_matrix_float(M_mask, NligBlock[0]);
  free_matrix_float(M_fs, NligBlock[0]);
  free_matrix_float(M_fd, NligBlock[0]);
  free_matrix_float(M_fv, NligBlock[0]);
  free_matrix_float(M_Ps, NligBlock[0]);
  free_matrix_float(M_Pd, NligBlock[0]);
  free_matrix_float(M_Pv, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_alpha);
  fclose(out_beta);
  fclose(out_mask);
  fclose(out_fs);
  fclose(out_fd);
  fclose(out_fv);
  fclose(out_Ps);
  fclose(out_Pd);
  fclose(out_Pv);
  
/********************************************************************
********************************************************************/

  return 1;
}
