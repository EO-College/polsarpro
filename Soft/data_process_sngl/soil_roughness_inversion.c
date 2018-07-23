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

File  : soil_roughness_inversion.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2012
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

Description :  Soil and Roughness parameter data inversion

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
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength];
  FILE *in_file_angle;
  
/* Flag Parameters */
  int Flag[12], Nout, NPara;
  FILE *OutFile3[12];
  char *FileOut3[12] = {
  "GtoVratio_surface.bin", "GtoVratio_dihedral.bin", "GtoVratio_combined.bin", 
  "roughness_gtov.bin", "roughness_anisotropy.bin", "roughness_circular_corr.bin", 
  "soil_xbragg.bin", "soil_surface.bin", "soil_dihedral.bin", "T11s.bin","T12s.bin","T22s.bin"};
  char anglefile[FilePathLength];

  int FlagGtoVS, FlagGtoVD, FlagGtoVC;
  int FlagRbyG, FlagRbyA, FlagRbyC;
  int FlagSfromX, FlagSfromS, FlagSfromD;

  int GtoVS, GtoVD, GtoVC;
  int RbyG, RbyA, RbyC;
  int SfromX, SfromS, SfromD;
  int fT11s, fT12s, fT22s;

/* Internal variables */
  int ii, lig, col, k, l;
  int Unit, VegModel;

  float p[4], Rho;
  float mu_s, mu_d, mu_c;
  float fv, x11, x12, x22;
  float P, T11s, T12s, T22s;
  float Gref[2000], x, delta;
  float RR, LL, LRre, LRim;
  float gamma_re, gamma_im;

/* Matrix arrays */
  float ***M_avg;
  float ***M_out;
  float **angle;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsoil_roughness_inversion.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-ang 	incidence angle file\n");
strcat(UsageHelp," (int)   	-un  	Angle Unit (0: deg, 1: rad)\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");

strcat(UsageHelp," (int)   	-fl1 	Flag GtoV ratio Surface\n");
strcat(UsageHelp," (int)   	-fl2 	Flag GtoV ratio Dihedral\n");
strcat(UsageHelp," (int)   	-fl3 	Flag GtoV ratio Combined\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Roughness by GtoV\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Roughness by Anisotropy\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Roughness by Circular Correlation\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Soil from Xbragg\n");
strcat(UsageHelp," (int)   	-fl8 	Flag Soil from Surface component\n");
strcat(UsageHelp," (int)   	-fl9 	Flag Soil from Dihedral component\n");
strcat(UsageHelp," (int)   	-fl10	Vegetation model (1 / 2 / 3)\n");
strcat(UsageHelp," (float) 	-fl11	Rho parameter\n");

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

if(argc < 45) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ang",str_cmd_prm,anglefile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-un",int_cmd_prm,&Unit,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagGtoVS,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagGtoVD,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagGtoVC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagRbyG,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagRbyA,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagRbyC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagSfromX,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagSfromS,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagSfromD,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl10",int_cmd_prm,&VegModel,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl11",flt_cmd_prm,&Rho,1,UsageHelp);

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
  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");
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
  GtoVS = 0; GtoVD = 1; GtoVC = 2;
  RbyG = 3; RbyA = 4; RbyC = 5;
  SfromX = 6; SfromS = 7; SfromD = 8;
  fT11s = 9; fT12s = 10; fT22s = 11;
  
  M = matrix3d_float(3, 3, 2);
  V = matrix3d_float(3, 3, 2);
  lambda = vector_float(3);

  NPara = 12;
  for (k = 0; k < NPara; k++) Flag[k] = -1;
  Nout = 0;
  
  if (FlagGtoVS == 1) {
    Flag[GtoVS] = Nout; Nout++;
    }
  if (FlagGtoVD == 1) {
    Flag[GtoVD] = Nout; Nout++;
    }
  if (FlagGtoVC == 1) {
    Flag[GtoVC] = Nout; Nout++;
    }
  if (FlagRbyG == 1) {
    Flag[RbyG] = Nout; Nout++;
    }
  if (FlagRbyA == 1) {
    Flag[RbyA] = Nout; Nout++;
    }
  if (FlagRbyC == 1) {
    Flag[RbyC] = Nout; Nout++;
    }
  if (FlagSfromX == 1) {
    Flag[SfromX] = Nout; Nout++;
    }
  if (FlagSfromS == 1) {
    Flag[SfromS] = Nout; Nout++;
    }
  if (FlagSfromD == 1) {
    Flag[SfromD] = Nout; Nout++;
    }

  Flag[fT11s] = Nout; Nout++;
  Flag[fT12s] = Nout; Nout++;
  Flag[fT22s] = Nout; Nout++;

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      sprintf(file_name, "%s%s", out_dir, FileOut3[k]);
      if ((OutFile3[Flag[k]] = fopen(file_name, "wb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      }
    }


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
  /* Mout = Nout*Nlig*Sub_Ncol */
  NBlockA += Nout*Sub_Ncol; NBlockB += 0;
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
  M_out = matrix3d_float(Nout, NligBlock[0], Sub_Ncol);
  angle = matrix_float(NligBlock[0], Sub_Ncol);

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
Gref[0] = 1.;
for (k = 1; k < 1001; k++) {
  x = (float)(k*pi)/1000.;
  Gref[k] = sin(x) / (x);
  }


for (Nb = 0; Nb < NbBlock; Nb++) {
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file_angle, angle, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeOut,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeOut,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
      if (Valid[lig][col] == 1.) {
        mu_s = (M_avg[T311][lig][col] - M_avg[T333][lig][col]) / (M_avg[T311][lig][col] + M_avg[T333][lig][col] + eps);
        mu_d = (M_avg[T322][lig][col] - M_avg[T333][lig][col]) / (M_avg[T322][lig][col] + M_avg[T333][lig][col] + eps);
        mu_c = (M_avg[T311][lig][col] + M_avg[T322][lig][col] - 2.*M_avg[T333][lig][col]) / (M_avg[T311][lig][col] + M_avg[T322][lig][col] + 2.*M_avg[T333][lig][col] + eps);
      
        if (Flag[GtoVS] != -1) {
          M_out[Flag[GtoVS]][lig][col] = mu_s;
          if (M_out[Flag[GtoVS]][lig][col] < 0.) M_out[Flag[GtoVS]][lig][col] = 0.;
          if (M_out[Flag[GtoVS]][lig][col] > 1.) M_out[Flag[GtoVS]][lig][col] = 1.;
          }
        if (Flag[GtoVD] != -1) {
          M_out[Flag[GtoVD]][lig][col] = mu_d;
          if (M_out[Flag[GtoVD]][lig][col] < 0.) M_out[Flag[GtoVD]][lig][col] = 0.;
          if (M_out[Flag[GtoVD]][lig][col] > 1.) M_out[Flag[GtoVD]][lig][col] = 1.;
          }
        if (Flag[GtoVC] != -1) {
          M_out[Flag[GtoVC]][lig][col] = mu_c;
          if (M_out[Flag[GtoVC]][lig][col] < 0.) M_out[Flag[GtoVC]][lig][col] = 0.;
          if (M_out[Flag[GtoVC]][lig][col] > 1.) M_out[Flag[GtoVC]][lig][col] = 1.;
          }

        fv = 4.*M_avg[T333][lig][col];
        if (VegModel == 1) {
          x11 = 1. + Rho; x12 = 0.; x22 = 1. - Rho;
          }
        if (VegModel == 2) {
          P = 10.*log10((M_avg[T311][lig][col]+M_avg[T322][lig][col]-2.*M_avg[T312_re][lig][col])/(M_avg[T311][lig][col]+M_avg[T322][lig][col]+2.*M_avg[T312_re][lig][col]));
          if (P < -2.) {
            x11 = 15./30.; x12 = 5./30.; x22 = 7./30.;
            }
          if ((-2.<=P)&&(P<2.)) {
            x11 = 2./4.; x12 = 0.; x22 = 1./4.;
            }
          if (2.<=P) {
            x11 = 15./30.; x12 = -5./30.; x22 = 7./30.;
            }
          }
        if (VegModel == 3) {
          P = 10.*log10((M_avg[T311][lig][col]+M_avg[T322][lig][col]-2.*M_avg[T312_re][lig][col])/(M_avg[T311][lig][col]+M_avg[T322][lig][col]+2.*M_avg[T312_re][lig][col]));
          if (P < -2.) {
            x11 = 15./30.; x12 = 10./30.; x22 = 8./30.;
            }
          if ((-2.<=P)&&(P<2.)) {
            x11 = 2./4.; x12 = 0.; x22 = 1./4.;
            }
          if (2.<=P) {
            x11 = 15./30.; x12 = -10./30.; x22 = 8./30.;
            }
          }
        T11s = M_avg[T311][lig][col] - (1. - mu_s)*x11*fv;
        T12s = M_avg[T312_re][lig][col] - (1. - mu_c)*x12*fv;
        T22s = M_avg[T322][lig][col] - (1. - mu_d)*x22*fv;
        M_out[Flag[fT11s]][lig][col] = T11s;
        M_out[Flag[fT12s]][lig][col] = T12s;
        M_out[Flag[fT22s]][lig][col] = T22s;
//if ((lig == 100)&&(col == 50)) printf("\n\nT11 %f %f %f\n\n",M_avg[T311][lig][col],M_avg[T312_re][lig][col],M_avg[T322][lig][col]);
//if ((lig == 100)&&(col == 50)) printf("\n\nx11 %f %f %f %f\n\n",fv,x11,x12,x22);
//if ((lig == 100)&&(col == 50)) printf("\n\nmu %f %f %f \n\n",mu_s,mu_c,mu_d);
//if ((lig == 100)&&(col == 50)) printf("\n\nT11s %f %f %f\n\n",T11s,T12s,T22s);
        
        if (Flag[RbyG] != -1) {
          x = (T22s - mu_d*M_avg[T333][lig][col]) / (T22s + mu_d*M_avg[T333][lig][col]);
          l = 0;
          for (k = 1; k < 1001; k++) {
            if ((x < Gref[k-1])&&(Gref[k] <= x)) l = k;
            }
          delta = Gref[l] / 4.;
          M_out[Flag[RbyG]][lig][col] = 2.*delta / pi;
          if (M_out[Flag[RbyG]][lig][col] < 0.) M_out[Flag[RbyG]][lig][col] = 0.;
          if (M_out[Flag[RbyG]][lig][col] > 1.) M_out[Flag[RbyG]][lig][col] = 1.;
          }                    
        if (Flag[RbyA] != -1) {
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[0][2][0] = eps + M_avg[3][lig][col];
          M[0][2][1] = eps + M_avg[4][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][2][1] = eps + M_avg[7][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[1][1][0] = eps + M_avg[5][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[6][lig][col];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[8][lig][col];
          M[2][2][1] = 0.;

          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(3, M, V, lambda);
  
          for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 3; k++)  {
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          M_out[Flag[RbyA]][lig][col] = 1. - (p[1] - p[2]) / (p[1] + p[2] + eps);
          if (M_out[Flag[RbyA]][lig][col] < 0.) M_out[Flag[RbyA]][lig][col] = 0.;
          if (M_out[Flag[RbyA]][lig][col] > 1.) M_out[Flag[RbyA]][lig][col] = 1.;
          }
        if (Flag[RbyC] != -1) {
          /*
          RRre = M_avg[T322][lig][col]/2.; RRim = M_avg[T333][lig][col]/2.;
          LLre = -M_avg[T322][lig][col]/2.; LLim = M_avg[T333][lig][col]/2.;
          gamma_re = RRre*LLre + RRim*LLim;
          gamma_re = gamma_re / sqrt(RRre*RRre+RRim*RRim+eps);
          gamma_re = gamma_re / sqrt(LLre*LLre+LLim*LLim+eps);
          gamma_im = -RRre*LLim + RRim*LLre;
          gamma_im = gamma_im / sqrt(RRre*RRre+RRim*RRim+eps);
          gamma_im = gamma_im / sqrt(LLre*LLre+LLim*LLim+eps);
          M_out[Flag[RbyC]][lig][col] = 1. - sqrt(gamma_re*gamma_re+gamma_im*gamma_im);        
          */
          LL = 0.5*(M_avg[T333][lig][col] + M_avg[T322][lig][col] + 2.*M_avg[T323_im][lig][col]);
          RR = 0.5*(M_avg[T333][lig][col] + M_avg[T322][lig][col] - 2.*M_avg[T323_im][lig][col]);
          LRre = 0.5*(M_avg[T333][lig][col] - M_avg[T322][lig][col]);
          LRim = -M_avg[T323_re][lig][col];
          gamma_re = LRre / sqrt(LL * RR + eps);
          gamma_im = LRim / sqrt(LL * RR + eps);
          M_out[Flag[RbyC]][lig][col] = 1. - sqrt(gamma_re*gamma_re+gamma_im*gamma_im);              
          if (M_out[Flag[RbyC]][lig][col] < 0.) M_out[Flag[RbyC]][lig][col] = 0.;
          if (M_out[Flag[RbyC]][lig][col] > 1.) M_out[Flag[RbyC]][lig][col] = 1.;
          }        

        if (Flag[SfromX] != -1) {
          if ((T11s > 0.)&&(T22s > 0.)) {
            M_out[Flag[SfromX]][lig][col] = (T22s + (mu_c * M_avg[T333][lig][col])) / (T11s+eps);
//if ((lig == 100)&&(col == 50)) printf("\n\nSfromX %f\n\n",M_out[Flag[SfromX]][lig][col]);
            if (M_out[Flag[SfromX]][lig][col] < 0.) M_out[Flag[SfromX]][lig][col] = 0.;
            //if (M_out[Flag[SfromX]][lig][col] > 1.) M_out[Flag[SfromX]][lig][col] = 1.;
if (M_out[Flag[SfromX]][lig][col] > 100000.) {
printf("\n\nSfromX %f\n\n",M_out[Flag[SfromX]][lig][col]);
printf("\n\nT11 %f %f %f\n\n",M_avg[T311][lig][col],M_avg[T312_re][lig][col],M_avg[T322][lig][col]);
printf("\n\nx11 %f %f %f %f\n\n",fv,x11,x12,x22);
printf("\n\nmu %f %f %f \n\n",mu_s,mu_c,mu_d);
printf("\n\nT11s %f %f %f\n\n",T11s,T12s,T22s);
getchar();
}
            } else {
            M_out[Flag[SfromX]][lig][col] = 0.;
            }
          }                    
        if (Flag[SfromS] != -1) {
          if ((T11s > 0.)&&(T22s > 0.)) {
            x = (T22s - mu_d*M_avg[T333][lig][col]) / (T22s + mu_d*M_avg[T333][lig][col]);
            l = 0;
            for (k = 1; k < 1001; k++) {
              if ((x < Gref[k-1])&&(Gref[k] <= x)) l = k;
              }
            delta = Gref[l] / 4.;
            M_out[Flag[SfromS]][lig][col] = T12s / (T11s*(sin(2.*delta)/(2.*delta)));
//if ((lig == 100)&&(col == 50)) printf("\n\nSfromS %f\n\n",M_out[Flag[SfromS]][lig][col]);
            if (M_out[Flag[SfromS]][lig][col] < 0.) M_out[Flag[SfromS]][lig][col] = 0.;
            //if (M_out[Flag[SfromS]][lig][col] > 1.) M_out[Flag[SfromS]][lig][col] = 1.;
            } else {
            M_out[Flag[SfromS]][lig][col] = 0.;
            }
          }                    
        if (Flag[SfromD] != -1) {
          if ((T11s > 0.)&&(T22s > 0.)) {
            M_out[Flag[SfromD]][lig][col] = fabs(T12s) / T22s;
            if (M_out[Flag[SfromD]][lig][col] < 0.) M_out[Flag[SfromD]][lig][col] = 0.;
            //if (M_out[Flag[SfromD]][lig][col] > 1.) M_out[Flag[SfromD]][lig][col] = 1.;
if (M_out[Flag[SfromD]][lig][col] > 100000.) {
printf("\n\nSfromD %f\n\n",M_out[Flag[SfromD]][lig][col]);
printf("\n\nT11 %f %f %f\n\n",M_avg[T311][lig][col],M_avg[T312_re][lig][col],M_avg[T322][lig][col]);
printf("\n\nx11 %f %f %f %f\n\n",fv,x11,x12,x22);
printf("\n\nmu %f %f %f \n\n",mu_s,mu_c,mu_d);
printf("\n\nT11s %f %f %f\n\n",T11s,T12s,T22s);
getchar();
}
            } else {
            M_out[Flag[SfromD]][lig][col] = 0.;
            }
          }                    
          
        } /*valid*/
      }
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      write_block_matrix_matrix3d_float(OutFile3[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
      }
    }
    
  } // NbBlock

/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
  if (Flag[Np] != -1) {
    fclose(OutFile3[Flag[Np]]);
    }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, Nout, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/

  return 1;
}





