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

File  : PolSARap_Cryosphere_Decomposition.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2014
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

Description :  PolSARap Cryosphere Showcase - Decomposition

*--------------------------------------------------------------------

Translated and adapted in c language from : IDL routine
$Id: pro decomposition_final, C, theta, winsz
;**************************************************************
; PURPOSE:   Perform  polarimetric decomposition using equations 
;            from the Covariance [C] matrix
;      Decompose into C = Cground + Csastrugi + Cvolume
;      -Account for transmissivities at the snow-ice interface 
;      -Account for ORIENTED SASTRUGI assuming
;   i)   fixed particle shape = dipole
;   ii)  fixed orientation nu0 mean value 
;        -  0 degs. [H-axis] when |HH|^2/|VV|^2 >= expected Beta
;        - 90 degs. [V-axis] when |HH|^2/|VV|^2, < expected Beta
;   iii) fix beta to SPM, do not model beta phase since models 
;        inadequate
;   iv) assumption of a uniform distribution of orientations until a 
;       certain cutoff +-dnu
;   v) in derivation of Csastrugi coefficients assumed that psi fixed
;      to 0 degs. 
;     
; USE IDL CONSTRAINED_MIN inversion procedure
;
; INPUTS:
;     C - Polarimetric 3x3 covariance matrix (monostatic case)
;     theta - Incidence angle image [rad]
;     winsz - window size (pixels [rng,az]) over which ensemble
;             averaging will be carried out
;
; OUTPUTs:
;     m - surface-to-volume ratio maps; matrix of 
;         rg_dim x az_dim x 3 double elements 
;         where m[*,*,0] = mhh, m[*,*,1] = mvv, m[*,*,2] = mhv
;     Pg - power of surface scattering contribution
;     Ps - power of sastrugi scattering component
;     Pv - power of volume scattering component
;
; Author: Jayanti Sharma
; Date: 20.01.2009
;
; Modified: Giuseppe Parrella
; Date: 13.06.2014
********************************************************************/
#include "../lib/alglib/stdafx.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include "../lib/alglib/optimization.h"

using namespace alglib;

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "PolSARap_Cryosphere_Decomp.h"
#include "PolSARap_Cryosphere_Decomp.c"

/* Global variables */
float Const[10];

/* Routine */
int CONSTRAINED_MIN(float *start);
void sastrugi_wtrans_fixbeta_constrmin(const real_1d_array &x, real_1d_array &fi, void *ptr);
float sastrugi_error(float *start);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 2
/* LOCAL VARIABLES */
  FILE *in_file_angle;
  FILE *in_fs, *in_fg, *in_fv;
  FILE *in_dnu, *in_nu0;
  FILE *out_fs, *out_fg, *out_fv;
  FILE *out_dnu, *out_nu0;
  FILE *out_mhh, *out_mhv, *out_mvv;
  FILE *out_Ps, *out_Pg, *out_Pv;
  int Config;
  const char *PolTypeConf[NPolType] = {"S2C3", "S2C4"};
  char file_name[FilePathLength], anglefile[FilePathLength];
  char msg[] = "Could not open input file : ";
 
/* Internal variables */
  int ii, lig, col, k, l;
  int Unit, status;
  
  float noise;
  float CC11, CC22, CC33;
  float CC12_re, CC12_im;
  float CC13_re, CC13_im;
  float CC23_re, CC23_im;

  float shh, shv, svv;
  float scj_re, scj_im, scj_mod;
  float span, per_err;
  float dielec1, dielec2, n1, n2;
  float n_ratio, ep_ratio;
  float dnu_init, fs_init, fv_init, fg_init;
  float Cs11, Cs22, Cs33;
  float theta_r, theta1, theta2;
  float rs_fres, rp_fres, Ts, Tp, Rs, Rp;
  float tau0, beta0;

  float fs0, mfs, nfs;
  float fg0, mfg, nfg;
  float fv0, mfv, nfv;

  float start[9];
  
/* Matrix arrays */
  float ***M_in;
  float **M_fs;
  float **M_fg;
  float **M_fv;
  float **M_dnu;
  float **M_nu0;
  float **M_mhh;
  float **M_mhv;
  float **M_mvv;
  float **M_Ps;
  float **M_Pg;
  float **M_Pv;
  float **theta;
  
  float ***M;
  float ***V;
  float *lambda;
  

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Cryosphere_Decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-ang 	incidence angle file\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
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
char msg01[] = "-help";
if(get_commandline_prm(argc,argv,msg01,no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
char msg02[] = "-data";
if(get_commandline_prm(argc,argv,msg02,no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 21) {
char msg00[] = "Not enough input arguments\n Usage:\n";
  edit_error(msg00,UsageHelp);
  } else {
char msg03[] = "-id";
  get_commandline_prm(argc,argv,msg03,str_cmd_prm,in_dir,1,UsageHelp);
char msg04[] = "-od";
  get_commandline_prm(argc,argv,msg04,str_cmd_prm,out_dir,1,UsageHelp);
char msg05[] = "-ang";
  get_commandline_prm(argc,argv,msg05,str_cmd_prm,anglefile,1,UsageHelp);
char msg06[] = "-un";
  get_commandline_prm(argc,argv,msg06,int_cmd_prm,&Unit,1,UsageHelp);
char msg07[] = "-nwr";
  get_commandline_prm(argc,argv,msg07,int_cmd_prm,&NwinL,1,UsageHelp);
char msg08[] = "-nwc";
  get_commandline_prm(argc,argv,msg08,int_cmd_prm,&NwinC,1,UsageHelp);
char msg09[] = "-ofr";
  get_commandline_prm(argc,argv,msg09,int_cmd_prm,&Off_lig,1,UsageHelp);
char msg10[] = "-ofc";
  get_commandline_prm(argc,argv,msg10,int_cmd_prm,&Off_col,1,UsageHelp);
char msg11[] = "-fnr";
  get_commandline_prm(argc,argv,msg11,int_cmd_prm,&Sub_Nlig,1,UsageHelp);
char msg12[] = "-fnc";
  get_commandline_prm(argc,argv,msg12,int_cmd_prm,&Sub_Ncol,1,UsageHelp);

char msg13[] = "-errf";
  get_commandline_prm(argc,argv,msg13,str_cmd_prm,file_memerr,0,UsageHelp);

char msg14[] = "-mem";
  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
char msg15[] = "-mask";
  get_commandline_prm(argc,argv,msg15,str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(anglefile);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  if (strcmp(PolarCase,"monostatic") == 0) {
    strcpy(PolType,"S2C3");
    }
  if (strcmp(PolarCase,"bistatic") == 0) {
    strcpy(PolType,"S2C4");
    if (NwinL == 1) NwinL = 3; // minimum window size to apply
    if (NwinC == 1) NwinC = 3; // the additive noise removing
    }

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error(msg, file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error(msg, file_valid);

  if ((in_file_angle = fopen(anglefile, "rb")) == NULL)
    edit_error(msg, anglefile);
      
/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_stv_ratio_HH.bin");
  if ((out_mhh = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_stv_ratio_HV.bin");
  if ((out_mhv = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_stv_ratio_VV.bin");
  if ((out_mvv = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_fs.bin");
  if ((out_fs = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_fg.bin");
  if ((out_fg = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_fv.bin");
  if ((out_fv = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_nu0.bin");
  if ((out_nu0 = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_dnu.bin");
  if ((out_dnu = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);
    
  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_Ps.bin");
  if ((out_Ps = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_Pg.bin");
  if ((out_Pg = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_Pv.bin");
  if ((out_Pv = fopen(file_name, "wb")) == NULL)
    edit_error(msg, file_name);
    
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

  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mfs = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mfg = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mfv = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mdnu = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mnu0 = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* MPs = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* MPg = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* MPv = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mmhh = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mmhv = Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mmvv = Nlig*Sub_Ncol */
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

  M_in = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_fs = matrix_float(NligBlock[0]+NwinL, Sub_Ncol+NwinC);
  M_fg = matrix_float(NligBlock[0]+NwinL, Sub_Ncol+NwinC);
  M_fv = matrix_float(NligBlock[0]+NwinL, Sub_Ncol+NwinC);
  M_dnu = matrix_float(NligBlock[0], Sub_Ncol);
  M_nu0 = matrix_float(NligBlock[0], Sub_Ncol);
  M_mhh = matrix_float(NligBlock[0], Sub_Ncol);
  M_mhv = matrix_float(NligBlock[0], Sub_Ncol);
  M_mvv = matrix_float(NligBlock[0], Sub_Ncol);
  M_Ps = matrix_float(NligBlock[0], Sub_Ncol);
  M_Pg = matrix_float(NligBlock[0], Sub_Ncol);
  M_Pv = matrix_float(NligBlock[0], Sub_Ncol);

  theta = matrix_float(NligBlock[0], Sub_Ncol);
  
  M = matrix3d_float(4, 4, 2);
  V = matrix3d_float(4, 4, 2);
  lambda = vector_float(4);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
//**choose init params ***
//MEDIUM1 = snow --> use Maetzler87 with density = 0.4 g/cm^3
dielec1 = 1.7;   
//MEDIUM2 = firn --> use Maetzler87 with density = 0.8 g/cm^3
dielec2 = 2.8;   
//determine Fresnel reflectivity coefficients  
//Ulaby81, Microwave Remote Sensing Vol I, pg. 73-74 (although he gives ELECTRIC fields for one polarisation, MAGNETIC for the other)
//re-written here only for electric fields
n1 = sqrt(dielec1);
n2 = sqrt(dielec2);

//compute Bragg coefficients  for surface scattering at snow (dielec1) / firn (dielec2) interface
//compute ratio of dielectric constants
n_ratio = n2 / n1;
ep_ratio = dielec2 / dielec1;    //epsilon, ie. dielectric constant ratio
  
//Initial values for distribution width of orientation angle of sastrugi
dnu_init = 70.0*pi/180.; //put at higher value for better model conditioning

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);
rewind(in_file_angle);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file_angle, theta, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_S2_avg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (strcmp(PolTypeOut,"C4") == 0) {
          M[0][0][0] = eps + M_in[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_in[1][lig][col];
          M[0][1][1] = eps + M_in[2][lig][col];
          M[0][2][0] = eps + M_in[3][lig][col];
          M[0][2][1] = eps + M_in[4][lig][col];
          M[0][3][0] = eps + M_in[5][lig][col];
          M[0][3][1] = eps + M_in[6][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_in[7][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_in[8][lig][col];
          M[1][2][1] = eps + M_in[9][lig][col];
          M[1][3][0] = eps + M_in[10][lig][col];
          M[1][3][1] = eps + M_in[11][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_in[12][lig][col];
          M[2][2][1] = 0.;
          M[2][3][0] = eps + M_in[13][lig][col];
          M[2][3][1] = eps + M_in[14][lig][col];
          M[3][0][0] =  M[0][3][0];
          M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0];
          M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0];
          M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + M_in[15][lig][col];
          M[3][3][1] = 0.;
  
          /* ADDITIVE NOISE REMOVING */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(4, M, V, lambda);
          noise = lambda[3]; if (noise < 0.) noise = 0.;
          CC11 = M_in[C411][lig][col] - noise;
          CC12_re = M_in[C412_re][lig][col];
          CC12_im = M_in[C412_im][lig][col];
          CC13_re = M_in[C413_re][lig][col];
          CC13_im = M_in[C413_im][lig][col];
          CC22 = M_in[C422][lig][col] - noise;
          CC23_re = M_in[C423_re][lig][col];
          CC23_im = M_in[C423_im][lig][col];
          CC33 = M_in[C433][lig][col] - noise;
          }
          
        if (strcmp(PolTypeOut,"C3") == 0) {
          CC11 = M_in[C311][lig][col];
          CC12_re = M_in[C312_re][lig][col];
          CC12_im = M_in[C312_im][lig][col];
          CC13_re = M_in[C313_re][lig][col];
          CC13_im = M_in[C313_im][lig][col];
          CC22 = M_in[C322][lig][col];
          CC23_re = M_in[C323_re][lig][col];
          CC23_im = M_in[C323_im][lig][col];
          CC33 = M_in[C333][lig][col];
          }

        /* Decomposition */
        shh = CC11;
        shv = CC22/2.;
        svv = CC33;
        scj_re = CC13_re;
        scj_im = CC13_im;
        scj_mod = sqrt(scj_re*scj_re+scj_im*scj_im);
        span = shh + 2.*shv + svv;

        if (my_isfinite(shh) == 0) M_nu0[lig][col] = 0.f/0.f;
        if ((my_isfinite(shh) != 0)||(my_isfinite(shv) != 0)||(my_isfinite(svv) != 0)||(my_isfinite(scj_mod) != 0)) {

          if (Unit == 0) theta[lig][col] = theta[lig][col]*pi/180.;
        
          //account for refraction at air-snow (dielec1) interface 
          theta_r = asin( sin(theta[lig][col]) / sqrt(dielec1));
          //determine tilt angle tau (complement of incidence angle) (assume sastrugi on snow surface)
          tau0 = pi/2. - theta[lig][col];
  
          theta1 = theta_r;  
          theta2 = asin(n1*sin(theta1)/n2); //Snell's law
  
          rs_fres = (n1*cos(theta1) - n2*cos(theta2))/(n1*cos(theta1) + n2*cos(theta2));
          rp_fres = (n2*cos(theta1) - n1*cos(theta2))/(n1*cos(theta2) + n2*cos(theta1));

          //determine Fresnel transmissitivity coefficients  
          Ts = sqrt( (1.- rs_fres*rs_fres));
          Tp = sqrt( (1.- rp_fres*rp_fres));

          //compute Rs and Rp Bragg coeffs [hajnsek2001_thesis, eqn. 6.2]
          Rs = (cos(theta1) - sqrt(ep_ratio - sin(theta1)*sin(theta1) ) ) / (cos(theta1) + sqrt(ep_ratio - sin(theta1)*sin(theta1) ) );
          Rp = ( (ep_ratio-1.)*(sin(theta1)*(sin(theta1)) - ep_ratio*(1+ sin(theta1)*(sin(theta1))) ) ) / ( (ep_ratio * cos(theta1) + sqrt(ep_ratio - sin(theta1)*(sin(theta1))))*(ep_ratio * cos(theta1) + sqrt(ep_ratio - sin(theta1)*(sin(theta1)))));

          //set centre of sastrugi orientation distribution using hh/vv ratios 
          //default is 0 degrees (i.e. horz orientation) unless ratio suggests otherwise
          beta0 = Rs/Rp;
        
          M_nu0[lig][col] = 0.;
          if ((shh/svv) < beta0*beta0) M_nu0[lig][col] = pi/2.0;

          //Initial values for sastrugi intensity component
          fs_init = 0.0;
          
          //use HV power to estimate initial values of volume (fv) and surface (fg) intensity assuming fsastrugi = 0
          fv_init = 3.0 * shv/( Tp*Tp*Ts*Ts);
          fg_init = (shh - fv_init*Ts*Ts*Ts*Ts)/(beta0*beta0);
        
          //define constants/initial guesses for this pixel
          //save to global variable
          Const[0] = M_nu0[lig][col];
          Const[1] = beta0;   
          Const[2] = shh/span;
          Const[3] = svv/span;
          Const[4] = shv/span;
          Const[5] = scj_mod/span;
          Const[6] = Ts;
          Const[7] = Tp;
          Const[8] = tau0;
        
          //Set up a vector with the initial guesses of input params 
          start[0] = fg_init/span, start[1] = fs_init/span; start[2] = fv_init/span; start[3] = dnu_init/(pi/2.);     
        
          //constrained minimization procedure which uses the 'sastrugi_wtrans_fixbeta_constrmin' routine
          //CONSTRAINED_MIN, start, x_bounds, g_bounds, 4, 'sastrugi_wtrans_fixbeta_constrmin', STATUS, LIMSER=50.    
          status = CONSTRAINED_MIN(start);    

          if (status > 0) {
            //compute sum of square residuals
            //sastrugi_wtrans_fixbeta_constrmin(Cresids,start);
            //per_err = total(Cresids[0:3]/abs(Cobs))
            per_err = sastrugi_error(start);

            if ((start[0] < 0.)||(start[1] < 0.)||(start[2] < 0.)||(start[3] > pi/2.)||(100.*per_err > 100.0)) {
              M_fs[lig][col] = 0.f/0.f;
              M_fg[lig][col] = 0.f/0.f;
              M_fv[lig][col] = 0.f/0.f;
              M_dnu[lig][col] = 0.f/0.f;
              M_nu0[lig][col] = 0.f/0.f;
              M_Ps[lig][col] = 0.f/0.f;
              M_Pg[lig][col] = 0.f/0.f;
              M_Pv[lig][col] = 0.f/0.f;
              } else {
              M_fg[lig][col] = start[0]*span;
              M_fs[lig][col] = start[1]*span;
              M_fv[lig][col] = start[2]*span; 
              M_dnu[lig][col] = start[3]*pi/2.;
              //compute modelled oriented sastrugi Covariance matrix elements
              Cs11 = 12.*M_dnu[lig][col] + 8.*cos(2.*M_nu0[lig][col])*sin(2.*M_dnu[lig][col])+ cos(4.*M_nu0[lig][col]) *sin(4.*M_dnu[lig][col]);
              Cs22 = 2.*(4.*M_dnu[lig][col] -  cos(4.*M_nu0[lig][col])*sin(4.*M_dnu[lig][col]))*(sin(tau0)*sin(tau0));
              Cs33 = (12.*M_dnu[lig][col] - 8.*cos(2.*M_nu0[lig][col])*sin(2*M_dnu[lig][col]) + cos(4.*M_nu0[lig][col])*sin(4.*M_dnu[lig][col]))*(sin(tau0)*sin(tau0)*sin(tau0)*sin(tau0));
              //Compute Power contribution for surface (Pg), sastrugi (Ps) and volume (Pv) contributions
              M_Pg[lig][col] = M_fg[lig][col]*(1. + beta0*beta0); 
              M_Ps[lig][col] = M_fs[lig][col]*(Cs11 + Cs22 + Cs33);
              M_Pv[lig][col] = M_fv[lig][col]*(Ts*Ts*Ts*Ts + (2./3.)*Ts*Ts*Tp*Tp + Tp*Tp*Tp*Tp);
              }
            } else {
            //optimization Constrained_Min failed
            M_fs[lig][col] = 0.f/0.f;
            M_fg[lig][col] = 0.f/0.f;
            M_fv[lig][col] = 0.f/0.f;
            M_dnu[lig][col] = 0.f/0.f;
            M_nu0[lig][col] = 0.f/0.f;
            M_Ps[lig][col] = 0.f/0.f;
            M_Pg[lig][col] = 0.f/0.f;
            M_Pv[lig][col] = 0.f/0.f;
            }
          } else {
          M_fs[lig][col] = 0.f/0.f;
          M_fg[lig][col] = 0.f/0.f;
          M_fv[lig][col] = 0.f/0.f;
          M_dnu[lig][col] = 0.f/0.f;
          M_nu0[lig][col] = 0.f/0.f;
          M_Ps[lig][col] = 0.f/0.f;
          M_Pg[lig][col] = 0.f/0.f;
          M_Pv[lig][col] = 0.f/0.f;
          }
        } else {
        M_fs[lig][col] = 0.;
        M_fg[lig][col] = 0.;
        M_fv[lig][col] = 0.;
        M_dnu[lig][col] = 0.;
        M_nu0[lig][col] = 0.;
        M_Ps[lig][col] = 0.;
        M_Pg[lig][col] = 0.;
        M_Pv[lig][col] = 0.;
        } // valid
      } // col
    } // lig
    
  write_block_matrix_float(out_fs, M_fs, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_fg, M_fg, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_fv, M_fv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dnu, M_dnu, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_nu0, M_nu0, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Ps, M_Ps, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Pg, M_Pg, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_Pv, M_Pv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    
  } // NbBlock

  fclose(out_fs);
  fclose(out_fg);
  fclose(out_fv);
  fclose(out_dnu);
  fclose(out_nu0);
  fclose(out_Ps);
  fclose(out_Pg);
  fclose(out_Pv);

/********************************************************************
********************************************************************/
  
  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_fs.bin");
  if ((in_fs = fopen(file_name, "rb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_fg.bin");
  if ((in_fg = fopen(file_name, "rb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_fv.bin");
  if ((in_fv = fopen(file_name, "rb")) == NULL)
    edit_error(msg, file_name);
  
  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_nu0.bin");
  if ((in_nu0 = fopen(file_name, "rb")) == NULL)
    edit_error(msg, file_name);

  sprintf(file_name, "%s%s", out_dir, "showcase_cryo_dnu.bin");
  if ((in_dnu = fopen(file_name, "rb")) == NULL)
    edit_error(msg, file_name);

/********************************************************************/
/********************************************************************/
/********************************************************************/
/***  Compute and save ground-to-volume scattering matrix for use ***/ 
/***  in Pol-InSAR inversion                                      ***/
/********************************************************************/
/********************************************************************/
/* DATA PROCESSING */
if (FlagValid == 1) rewind(in_valid);
rewind(in_file_angle);

for (k = 0; k < NligBlock[0]+NwinL; k++) 
  for (l = 0; l < Sub_Ncol+NwinC; l++) {
    M_fs[k][l] = 0.; M_fg[k][l] = 0.; M_fv[k][l] = 0.;
    }

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_fs, M_fs, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, 0, 0, Sub_Ncol);
  read_block_matrix_float(in_fg, M_fg, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, 0, 0, Sub_Ncol);
  read_block_matrix_float(in_fv, M_fv, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, 0, 0, Sub_Ncol);
  read_block_matrix_float(in_dnu, M_dnu, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
  read_block_matrix_float(in_nu0, M_nu0, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, 0, 0, Sub_Ncol);
  read_block_matrix_float(in_file_angle, theta, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if ((my_isfinite(M_fs[NwinLM1S2+lig][NwinCM1S2+col]) != 0)&&(my_isfinite(M_fg[NwinLM1S2+lig][NwinCM1S2+col]) != 0)&&(my_isfinite(M_fv[NwinLM1S2+lig][NwinCM1S2+col]) != 0)) {      
          if (Unit == 0) theta[lig][col] = theta[lig][col]*pi/180.;
          //account for refraction at air-snow (dielec1) interface 
          theta_r = asin( sin(theta[lig][col]) / sqrt(dielec1));
          //determine tilt angle tau (complement of incidence angle) (assume sastrugi on snow surface)
          tau0 = pi/2. - theta[lig][col];
  
          theta1 = theta_r;  
          theta2 = asin(n1*sin(theta1)/n2); //Snell's law
  
          rs_fres = (n1*cos(theta1) - n2*cos(theta2))/(n1*cos(theta1) + n2*cos(theta2));
          rp_fres = (n2*cos(theta1) - n1*cos(theta2))/(n1*cos(theta2) + n2*cos(theta1));

          //determine Fresnel transmissitivity coefficients  
          Ts = sqrt( (1.- rs_fres*rs_fres));
          Tp = sqrt( (1.- rp_fres*rp_fres));

          //compute Rs and Rp Bragg coeffs [hajnsek2001_thesis, eqn. 6.2]
          Rs = (cos(theta1) - sqrt(ep_ratio - sin(theta1)*sin(theta1) ) ) / (cos(theta1) + sqrt(ep_ratio - sin(theta1)*sin(theta1) ) );
          Rp = ( (ep_ratio-1.)*(sin(theta1)*(sin(theta1)) - ep_ratio*(1+ sin(theta1)*(sin(theta1))) ) ) / ( (ep_ratio * cos(theta1) + sqrt(ep_ratio - sin(theta1)*(sin(theta1))))*(ep_ratio * cos(theta1) + sqrt(ep_ratio - sin(theta1)*(sin(theta1)))));

          //set centre of sastrugi orientation distribution using hh/vv ratios 
          //default is 0 degrees (i.e. horz orientation) unless ratio suggests otherwise
          beta0 = Rs/Rp;
      
          //compute modelled oriented sastrugi Covariance matrix elements
          Cs11 = 12.*M_dnu[lig][col] + 8.*cos(2.*M_nu0[lig][col])*sin(2.*M_dnu[lig][col])+ cos(4.*M_nu0[lig][col]) *sin(4.*M_dnu[lig][col]);
          Cs22 = 2.*(4.*M_dnu[lig][col] -  cos(4.*M_nu0[lig][col])*sin(4.*M_dnu[lig][col]))*(sin(tau0)*sin(tau0));
          Cs33 = (12.*M_dnu[lig][col] - 8.*cos(2.*M_nu0[lig][col])*sin(2*M_dnu[lig][col]) + cos(4.*M_nu0[lig][col])*sin(4.*M_dnu[lig][col]))*(sin(tau0)*sin(tau0)*sin(tau0)*sin(tau0));
        
          if (col == 0) {
            mfs = 0.; nfs = 0.;
            mfg = 0.; nfg = 0.;
            mfv = 0.; nfv = 0.;
            for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
              for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
                if (my_isfinite(M_fs[NwinLM1S2+lig+k][NwinCM1S2+col+l]) != 0) {
                  mfs = mfs + M_fs[NwinLM1S2+lig+k][NwinCM1S2+col+l];
                  nfs = nfs + 1.;
                  }
                if (my_isfinite(M_fg[NwinLM1S2+lig+k][NwinCM1S2+col+l]) != 0) {
                  mfg = mfg + M_fg[NwinLM1S2+lig+k][NwinCM1S2+col+l];
                  nfg = nfg + 1.;
                  }
                if (my_isfinite(M_fv[NwinLM1S2+lig+k][NwinCM1S2+col+l]) != 0) {
                  mfv = mfv + M_fv[NwinLM1S2+lig+k][NwinCM1S2+col+l];
                  nfv = nfv + 1.;
                  }
                }
            } else {
            for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
              if (my_isfinite(M_fs[NwinLM1S2+lig+k][col-1]) != 0) {
                mfs = mfs - M_fs[NwinLM1S2+lig+k][col-1];
                nfs = nfs - 1.;
                }
              if (my_isfinite(M_fs[NwinLM1S2+lig+k][NwinC-1+col]) != 0) {
                mfs = mfs + M_fs[NwinLM1S2+lig+k][NwinC-1+col];
                nfs = nfs + 1.;
                }
              if (my_isfinite(M_fg[NwinLM1S2+lig+k][col-1]) != 0) {
                mfg = mfg - M_fg[NwinLM1S2+lig+k][col-1];
                nfg = nfg - 1.;
                }
              if (my_isfinite(M_fg[NwinLM1S2+lig+k][NwinC-1+col]) != 0) {
                mfg = mfg + M_fg[NwinLM1S2+lig+k][NwinC-1+col];
                nfg = nfg + 1.;
                }
              if (my_isfinite(M_fv[NwinLM1S2+lig+k][col-1]) != 0) {
                mfv = mfv - M_fv[NwinLM1S2+lig+k][col-1];
                nfv = nfv - 1.;
                }
              if (my_isfinite(M_fv[NwinLM1S2+lig+k][NwinC-1+col]) != 0) {
                mfv = mfv + M_fv[NwinLM1S2+lig+k][NwinC-1+col];
                nfv = nfv + 1.;
                }
              }
            }
          if (nfs != 0.) fs0 = mfs/nfs; else fs0 = 0.f/0.f;
          if (nfg != 0.) fg0 = mfg/nfg; else fg0 = 0.f/0.f;
          if (nfv != 0.) fv0 = mfv/nfv; else fv0 = 0.f/0.f;
          
          if ((my_isfinite(fs0) != 0)&&(my_isfinite(fg0) != 0)&&(my_isfinite(fv0) != 0)) {
            //surf-to-vol ratios in the different polarimetric channels
            M_mhh[lig][col] = (fg0*beta0*beta0 + fs0*Cs11) / (fv0*Ts*Ts*Ts*Ts + eps);
            M_mvv[lig][col] = (fg0 + fs0*Cs33) / (fv0*Tp*Tp*Tp*Tp + eps);
            M_mhv[lig][col] = (fs0*Cs22) / (fv0*(2./3.)*Ts*Ts*Tp*Tp + eps);
            //set negative areas to NaN (non-physical)
            if (M_mhh[lig][col] < 0.) M_mhh[lig][col] = 0.f/0.f;
            if (M_mhv[lig][col] < 0.) M_mhv[lig][col] = 0.f/0.f;
            if (M_mvv[lig][col] < 0.) M_mvv[lig][col] = 0.f/0.f;      
            } else {
            M_mhh[lig][col] = 0.f/0.f;
            M_mhv[lig][col] = 0.f/0.f;
            M_mvv[lig][col] = 0.f/0.f;
            } // NaN
          } else {
          M_mhh[lig][col] = 0.f/0.f;
          M_mhv[lig][col] = 0.f/0.f;
          M_mvv[lig][col] = 0.f/0.f;
          } // NaN
        } else {
        M_mhh[lig][col] = 0.;
        M_mhv[lig][col] = 0.;
        M_mvv[lig][col] = 0.;
        } // valid
      } // col
    } // lig
    
  write_block_matrix_float(out_mhh, M_mhh, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mhv, M_mhv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_mvv, M_mvv, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix_float(M_fs, Sub_Nlig);
  free_matrix_float(M_fg, Sub_Nlig);
  free_matrix_float(M_fv, Sub_Nlig);
  free_matrix_float(M_dnu, Sub_Nlig);
  free_matrix_float(M_nu0, Sub_Nlig);
  free_matrix_float(M_Ps, Sub_Nlig);
  free_matrix_float(M_Pg, Sub_Nlig);
  free_matrix_float(M_Pv, Sub_Nlig);
  free_matrix_float(M_mhh, Sub_Nlig);
  free_matrix_float(M_mhv, Sub_Nlig);
  free_matrix_float(M_mvv, Sub_Nlig);
  
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);
  fclose(in_fs);
  fclose(in_fg);
  fclose(in_fv);
  fclose(in_nu0);
  fclose(in_dnu);

/* OUTPUT FILE CLOSING*/
  fclose(out_mhh);
  fclose(out_mhv);
  fclose(out_mvv);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************/
/********************************************************************/
/********************************************************************/
/********************************************************************/
int CONSTRAINED_MIN(float *start)
{
  int n;
  real_1d_array x = "[0,0,0,0]";
  real_1d_array bndl = "[0,0,0,0]";
  real_1d_array bndu = "[+1,+1,+1,+1]";
  double epsg = 0.0000000001;
  double epsf = 0.0000000001;
  double epsx = 0.0000000001;
  //double epsg = 0;
  //double epsf = 0;
  //double epsx = 0;
  ae_int_t maxits = 0;
  minlmstate state;
  minlmreport rep;

  for (n = 0; n <4; n++) x[n] = start[n];
  minlmcreatev(4, x, 0.000001, state);
  minlmsetbc(state, bndl, bndu);
  minlmsetcond(state, epsg, epsf, epsx, maxits);
  alglib::minlmoptimize(state, sastrugi_wtrans_fixbeta_constrmin);
  minlmresults(state, x, rep);
  for (n = 0; n <4; n++) start[n] = x[n];
 
  return int(rep.terminationtype);
}

/********************************************************************
*********************************************************************

Translated and adapted in c language from : IDL routine
$Id: function sastrugi_wtrans_fixbeta_constrmin, p
;**************************************************************
; FUNCTION:  sastrugi_wtrans_fixbeta_constrmin.pro
; PURPOSE:   Compute covariance matrix for modelled situation
;      of (ground + sastrugi + random volume contribution) where
;      sastrugi are assumed to have:
;   i)  constant shape parameter = dipole
;   ii) uniform distribution of nu angles between -dnu and +dnu,  
;       centred at nu0, where nu0 = 0 is a horz-scatterer (referenced
;       to the Earth's surface) aligned along the line of light 
;       and nu0=!PI/2 is a scatterer aligned perpendicular to the
;       line-of-flight on the ground
;   iii)fixed beta defined by SPM model
;
;     Called by IDL CONSTRAINED_MIN routine 
;
; PARAMS:
;
; x     parameters to estimate
; x[0]  fg    relative contribution of ground component
; x[1]  fs    relative contribution of sastrugi component
; x[2]  fv    relative contribution of volume component
; x[3]  dnu   width parameter of uniform distribution of nu angles
; 
;
; GLOBAL VAR
; !const    contains constant params (avoid definition of global vars)
; !const[0] nu0  centre of tilt orientation distribution
; !const[1] beta (theoretical Rs/Rp Bragg coefficients with 0 phase)
; !const[2] shh   <|S_{HH}|^2>
; !const[3] svv   <|S_{VV}|^2>
; !const[4] shv   <|S_{HV}|^2>
; !const[5] abs(scj)  |(<S_{HH} S^*_{VV}>)|
; !const[6] Ts    Fresnel transmissivity coeff (senkrecht, HH)
; !const[7] Tp    Fresnel transmissivity coeff (parallel, VV)
; !const[8] tau0  tilt angle (defined by radar: = !Pi/2 - theta_r
;
; RETURNS:
; Cobs : residual btw modelled/observ vector of covariance matrix 
;        elements: <|S_{HH}|^2>,  <|S_{VV}|^2>, <|S_{HV}|^2>, 
;                  abs(<S_{HH} S^*_{VV}>)
;
; Author: Jayanti Sharma
; Date: 16.01.2009
;
; Modified: Giuseppe Parrella
; Date: 13.06.2014
/********************************************************************
********************************************************************/
void sastrugi_wtrans_fixbeta_constrmin(const real_1d_array &x, real_1d_array &fi, void *ptr)
{
  float fg, fs, fv, dnu;
  float nu0, beta, Ts, Tp, tau0;
  float Cs11, Cs22, Cs33, Cs13;
  float shh, svv, shv, scj_abs;
  
  //extract parameters from x array
  fg = x[0];
  fs = x[1];
  fv = x[2];
  dnu = x[3]*pi/2.;
  
  //extract constants parameters from GLOBAL var
  nu0 = Const[0];
  beta = Const[1];
  //observed [shh, svv, shv, abs(scj)]  
  //Const[2] to Const[5] 
  Ts = Const[6];
  Tp = Const[7];
  tau0 = Const[8];

  //compute modelled oriented sastrugi Covariance matrix elements
  Cs11 = 12.*dnu + 8.*cos(2.*nu0)*sin(2.*dnu)+ cos(4.*nu0) *sin(4.*dnu);
  Cs22 = 2.*(4.*dnu -  cos(4.*nu0)*sin(4.*dnu))*(sin(tau0)*sin(tau0));
  Cs33 = (12.*dnu - 8.*cos(2.*nu0)*sin(2*dnu) + cos(4.*nu0)*sin(4.*dnu))*(sin(tau0)*sin(tau0)*sin(tau0)*sin(tau0));
  Cs13 =  (4.*dnu - cos(4.*nu0)*sin(4.*dnu))*(sin(tau0)*sin(tau0));

  //combine with ground and random volume contributions for total covariance matrix
  shh = fg*beta*beta + fs*Cs11 + fv*Ts*Ts*Ts*Ts;
  svv = fg + fs*Cs33 + fv*Tp*Tp*Tp*Tp;
  shv = (fs*Cs22 + fv*2./3.*Ts*Ts*Tp*Tp ) /2.;
  scj_abs = fabs( fg*beta + fs*Cs13 + fv*1./3.*Ts*Ts*Tp*Tp);

  //determine residuals
  fi[0] = shh-Const[2];
  fi[1] = svv-Const[3];
  fi[2] = shv-Const[4];
  fi[3] = scj_abs-Const[5];
  fi[4] = fabs(fi[0])*fabs(fi[0])+fabs(fi[1])*fabs(fi[1])+fabs(fi[2])*fabs(fi[2])+fabs(fi[3])*fabs(fi[3]);
}

/********************************************************************/
/********************************************************************/
/********************************************************************/
/********************************************************************/
float sastrugi_error(float *start)
{
  float fg, fs, fv, dnu;
  float nu0, beta, Ts, Tp, tau0;
  float Cs11, Cs22, Cs33, Cs13;
  float shh, svv, shv, scj_abs;
  float err0, err1, err2, err3, per_err;
  
  //extract parameters from x array
  fg = start[0];
  fs = start[1];
  fv = start[2];
  dnu = start[3]*pi/2.;
  
  //extract constants parameters from GLOBAL var
  nu0 = Const[0];
  beta = Const[1];
  //observed [shh, svv, shv, abs(scj)]  
  //Const[2] to Const[5] 
  Ts = Const[6];
  Tp = Const[7];
  tau0 = Const[8];

  //compute modelled oriented sastrugi Covariance matrix elements
  Cs11 = 12.*dnu + 8.*cos(2.*nu0)*sin(2.*dnu)+ cos(4.*nu0) *sin(4.*dnu);
  Cs22 = 2.*(4.*dnu -  cos(4.*nu0)*sin(4.*dnu))*(sin(tau0)*sin(tau0));
  Cs33 = (12.*dnu - 8.*cos(2.*nu0)*sin(2*dnu) + cos(4.*nu0)*sin(4.*dnu))*(sin(tau0)*sin(tau0)*sin(tau0)*sin(tau0));
  Cs13 =  (4.*dnu - cos(4.*nu0)*sin(4.*dnu))*(sin(tau0)*sin(tau0));

  //combine with ground and random volume contributions for total covariance matrix
  shh = fg*beta*beta + fs*Cs11 + fv*Ts*Ts*Ts*Ts;
  svv = fg + fs*Cs33 + fv*Tp*Tp*Tp*Tp;
  shv = (fs*Cs22 + fv*2./3.*Ts*Ts*Tp*Tp ) /2.;
  scj_abs = fabs( fg*beta + fs*Cs13 + fv*1./3.*Ts*Ts*Tp*Tp);

  //determine residuals
  err0 = (shh-Const[2])/ sqrt(Const[2]*Const[2]);
  err1 = (svv-Const[3])/ sqrt(Const[3]*Const[3]);
  err2 = (shv-Const[4])/ sqrt(Const[4]*Const[4]);
  err3 = (scj_abs-Const[5])/ sqrt(Const[5]*Const[5]);
  per_err = fabs(err0+err1+err2+err3);
  
  return per_err;
}
