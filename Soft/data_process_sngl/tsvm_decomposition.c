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

File  : tsvm_decomposition.c
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

Description :  Touzi TSVM Decomposition

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS  */
/* Decomposition parameters */
#define Alpha  0
#define Phi  1
#define Tau  2
#define Psi  3
#define Alpha1 4
#define Alpha2 5
#define Alpha3 6
#define Phi1  7
#define Phi2  8
#define Phi3  9
#define Tau1  10
#define Tau2  11
#define Tau3  12
#define Psi1  13
#define Psi2  14
#define Psi3  15

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/********************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  : 1
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 3
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
#define NPara 16
  int Flag[NPara], Nout;
  FILE *OutFile[NPara];
  char *FileOut[NPara] = {
  "TSVM_alpha_s.bin", "TSVM_phi_s.bin", "TSVM_tau_m.bin", "TSVM_psi.bin",
  "TSVM_alpha_s1.bin", "TSVM_alpha_s2.bin", "TSVM_alpha_s3.bin",
  "TSVM_phi_s1.bin", "TSVM_phi_s2.bin", "TSVM_phi_s3.bin",
  "TSVM_tau_m1.bin", "TSVM_tau_m2.bin", "TSVM_tau_m3.bin",
  "TSVM_psi1.bin", "TSVM_psi2.bin", "TSVM_psi3.bin"};

/* Internal variables */
  int ii, lig, col, k, l;
  int FlagAlpPhiTauPsi, FlagAlpha, FlagPhi, FlagTau, FlagPsi;

  float alpha[3], phi[3], tau[3], psi[3], phase[3], p[3];
  float x1r, x1i, x2r, x2i;

/* Matrix arrays */
  float ***M_avg;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntsvm_decomposition.exe\n");
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
strcat(UsageHelp," (int)   	-fl1 	Flag AlpPhiTauPsi\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Alpha\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Phi\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Tau\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Psi\n");
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

if(argc < 29) {
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
  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagAlpPhiTauPsi,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagAlpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagPhi,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagTau,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagPsi,1,UsageHelp);

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
  for (k = 0; k < NPara; k++) Flag[k] = -1;

  Nout = 0;
  //Flag AlpPhiTauPsi
  if (FlagAlpPhiTauPsi == 1) {
    Flag[Alpha] = Nout; Nout++; Flag[Phi] = Nout; Nout++;
    Flag[Tau] = Nout; Nout++; Flag[Psi] = Nout; Nout++;
    }
  //Flag Alpha
  if (FlagAlpha == 1) {
    Flag[Alpha1] = Nout; Nout++; Flag[Alpha2] = Nout; Nout++;
    Flag[Alpha3] = Nout; Nout++;
    }
  //Flag Phi
  if (FlagPhi == 1) {
    Flag[Phi1] = Nout; Nout++; Flag[Phi2] = Nout; Nout++;
    Flag[Phi3] = Nout; Nout++;
    }
  //Flag Tau
  if (FlagTau == 1) {
    Flag[Tau1] = Nout; Nout++; Flag[Tau2] = Nout; Nout++;
    Flag[Tau3] = Nout; Nout++;
    }
  //Flag Psi
  if (FlagPsi == 1) {
    Flag[Psi1] = Nout; Nout++; Flag[Psi2] = Nout; Nout++;
    Flag[Psi3] = Nout; Nout++;
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      sprintf(file_name, "%s%s", out_dir, FileOut[k]);
      if ((OutFile[Flag[k]] = fopen(file_name, "wb")) == NULL)
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

  M = matrix3d_float(3, 3, 2);
  V = matrix3d_float(3, 3, 2);
  lambda = vector_float(3);
  
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

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        M[0][0][0] = eps + M_avg[0][lig][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][lig][col];
        M[0][1][1] = eps + M_avg[2][lig][col];
        M[0][2][0] = eps + M_avg[3][lig][col];
        M[0][2][1] = eps + M_avg[4][lig][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[5][lig][col];
        M[1][1][1] = 0.;
        M[1][2][0] = eps + M_avg[6][lig][col];
        M[1][2][1] = eps + M_avg[7][lig][col];
        M[2][0][0] =  M[0][2][0];
        M[2][0][1] = -M[0][2][1];
        M[2][1][0] =  M[1][2][0];
        M[2][1][1] = -M[1][2][1];
        M[2][2][0] = eps + M_avg[8][lig][col];
        M[2][2][1] = 0.;

        /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
        /* V complex eigenvecor matrix, lambda real vector*/
        Diagonalisation(3, M, V, lambda);

        for (k = 0; k < 3; k++)  if (lambda[k] < 0.) lambda[k] = 0.;

        for (k = 0; k < 3; k++) {
          /* Scattering mechanism probability of occurence */
          p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
          if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;

          /* Unitary eigenvectors */
          phase[k] = atan2(V[0][k][1], eps + V[0][k][0]);
          for (l = 0; l < 3; l++) {
            x1r = V[l][k][0]; x1i = V[l][k][1];
            V[l][k][0] = x1r * cos(phase[k]) + x1i * sin(phase[k]);
            V[l][k][1] = x1i * cos(phase[k]) - x1r * sin(phase[k]);
            }
    
          psi[k] = 0.5*atan2(V[2][k][0],(eps + V[1][k][0]));

          x1r = V[1][k][0]; x1i = V[1][k][1];
          x2r = V[2][k][0]; x2i = V[2][k][1];
          V[1][k][0] = x1r * cos(2.*psi[k]) + x2r * sin(2.*psi[k]); V[1][k][1] = x1i * cos(2.*psi[k]) + x2i * sin(2.*psi[k]);
          V[2][k][0] = -x1r * sin(2.*psi[k]) + x2r * cos(2.*psi[k]); V[2][k][1] = -x1i * sin(2.*psi[k]) + x2i * cos(2.*psi[k]);

          tau[k] = 0.5*atan2(-V[2][k][1],(eps + V[0][k][0]));

          phi[k] = atan2(V[1][k][1],(eps + V[1][k][0]));

          x1r = V[0][k][0]; x1i = V[0][k][1];
          x2r = V[2][k][0]; x2i = V[2][k][1];
          V[0][k][0] = x1r * cos(2.*tau[k]) - x2i * sin(2.*tau[k]); V[0][k][1] = x1i * cos(2.*tau[k]) + x2r * sin(2.*tau[k]);
          V[2][k][0] = -x1i * sin(2.*tau[k]) + x2r * cos(2.*tau[k]); V[2][k][1] = x1r * sin(2.*tau[k]) + x2i * cos(2.*tau[k]);
          alpha[k] = acos(V[0][k][0]);

          if ((psi[k] < -pi/4.)||(psi[k] > +pi/4.)) {
            tau[k] = -tau[k]; phi[k] = -phi[k];
            }
    
          }

        /* Mean scattering mechanism */
        for (k = 0; k < NPara; k++) if (Flag[k] != -1) M_out[Flag[k]][lig][col] = 0.;

        for (k = 0; k < 3; k++) {
          if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] += alpha[k] * p[k];
          if (Flag[Phi] != -1) M_out[Flag[Phi]][lig][col] += phi[k] * p[k];
          if (Flag[Tau] != -1) M_out[Flag[Tau]][lig][col] += tau[k] * p[k];
          if (Flag[Psi] != -1) M_out[Flag[Psi]][lig][col] += psi[k] * p[k];
          if (Flag[Alpha1+k] != -1) M_out[Flag[Alpha1+k]][lig][col] = alpha[k];
          if (Flag[Phi1+k] != -1) M_out[Flag[Phi1+k]][lig][col] = phi[k];
          if (Flag[Tau1+k] != -1) M_out[Flag[Tau1+k]][lig][col] = tau[k];
          if (Flag[Psi1+k] != -1) M_out[Flag[Psi1+k]][lig][col] = psi[k];
          }

        /* Scaling */
        for (k = 0; k < NPara; k++) if (Flag[k] != -1) M_out[Flag[k]][lig][col] *= 180. / pi;
        } else {
        for (k = 0; k < NPara; k++) if (Flag[k] != -1) M_out[Flag[k]][lig][col] = 0.;
        }
      }
    }

  for (k = 0; k < NPara; k++) 
    if (Flag[k] != -1) 
      write_block_matrix_matrix3d_float(OutFile[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

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
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
    if (Flag[Np] != -1) fclose(OutFile[Flag[Np]]);
  
/********************************************************************
********************************************************************/

  return 1;
}


