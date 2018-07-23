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

File  : compact_decomposition.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 11/2012
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

Description :  Cloude compact decomposition

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

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "C2"};
  char file_name[FilePathLength];
  char hybrid[10];
  
/* Flag Parameters */
  int Flag[18], Nout, NPara;
  FILE *OutFile2[18];
  char *FileOut2[18] = {
  "compact_l1.bin", "compact_l2.bin", 
  "compact_p1.bin", "compact_p2.bin",
  "compact_entropy.bin", "compact_deg_pol.bin",
  "compact_mv.bin", "compact_ms.bin", 
  "compact_alpha_s.bin", "compact_phi.bin",
  "compact_Ps.bin", "compact_Pd.bin", "compact_Pv.bin",
  "compact_sigma_hv.bin", "compact_RSoV.bin", "compact_cpr.bin",
  "compact_alpha.bin", "compact_tau.bin"};

  int FlagEigenvalues, FlagProbabilites;
  int FlagEntropy, FlagDegPol;
  int FlagMv, FlagMs, FlagAlphaS, FlagPhi;
  int FlagPsPdPv;
  int FlagSigmaHV, FlagRSoV, FlagCPR;
  int FlagAlpha, FlagTau;

  int Eigen1, Eigen2, Proba1, Proba2;
  int Entropy, DegPol;
  int Mv, Ms, AlphaS, Phi;
  int Ps, Pd, Pv;
  int SigmaHV, RSoV, CPR;
  int Alpha, Tau;

/* Internal variables */
  int ii, lig, col, k;

  float p[2];
  float G0, G1, G2, G3;
  float DP, alphas, alpha, rsov;

/* Matrix arrays */
  float ***M_avg;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncompact_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-hyb 	hybrid data format (RHC or LHC)\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-fl1 	Flag Eigenvalues (0/1)\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Probabilites (0/1)\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Entropy (0/1)\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Degree of Polarisation (0/1)\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Mv (0/1)\n");
strcat(UsageHelp," (int)   	-fl6 	Flag Ms (0/1)\n");
strcat(UsageHelp," (int)   	-fl7 	Flag Alpha_s (0/1)\n");
strcat(UsageHelp," (int)   	-fl8 	Flag Phi (0/1)\n");
strcat(UsageHelp," (int)   	-fl9 	Flag Ps, Pd, Pv (0/1)\n");
strcat(UsageHelp," (int)   	-fl10 	Flag Sigma_HV (0/1)\n");
strcat(UsageHelp," (int)   	-fl11 	Flag RSoV (0/1)\n");
strcat(UsageHelp," (int)   	-fl12 	Flag CPR (0/1)\n");
strcat(UsageHelp," (int)   	-fl13 	Flag Alpha (0/1)\n");
strcat(UsageHelp," (int)   	-fl14 	Flag Tau (0/1)\n");
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

if(argc < 49) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hyb",str_cmd_prm,hybrid,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagEigenvalues,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagProbabilites,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagEntropy,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagDegPol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagMv,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagMs,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagAlphaS,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagPhi,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagPsPdPv,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl10",int_cmd_prm,&FlagSigmaHV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl11",int_cmd_prm,&FlagRSoV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl12",int_cmd_prm,&FlagCPR,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl13",int_cmd_prm,&FlagAlpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl14",int_cmd_prm,&FlagTau,1,UsageHelp);

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

  if (strcmp(PolType,"SPP")==0) strcpy(PolType,"SPPC2");

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
  /* Decomposition parameters */
  Eigen1 = 0; Eigen2 = 1; 
  Proba1 = 2; Proba2 = 3; 
  Entropy = 4; DegPol = 5;
  Mv = 6; Ms = 7; AlphaS = 8; Phi = 9;
  Ps = 10; Pd = 11; Pv = 12;
  SigmaHV = 13; RSoV = 14; CPR = 15;
  Alpha = 16; Tau = 17;

  M = matrix3d_float(2, 2, 2);
  V = matrix3d_float(2, 2, 2);
  lambda = vector_float(2);

  NPara = 18;
  for (k = 0; k < NPara; k++) Flag[k] = -1;
  Nout = 0;
  //Flag Eigenvalues
  if (FlagEigenvalues == 1) {
    Flag[Eigen1] = Nout; Nout++;
    Flag[Eigen2] = Nout; Nout++;
    }
  //Flag Probabilites
  if (FlagProbabilites == 1) {
    Flag[Proba1] = Nout; Nout++;
    Flag[Proba2] = Nout; Nout++;
    }
  //Flag Entropy
  if (FlagEntropy == 1) {
    Flag[Entropy] = Nout; Nout++;
    }
  //Flag Deg Pol
  if (FlagDegPol == 1) {
    Flag[DegPol] = Nout; Nout++;
    }
  //Flag Mv
  if (FlagMv == 1) {
    Flag[Mv] = Nout; Nout++;
    }
  //Flag Ms
  if (FlagMs == 1) {
    Flag[Ms] = Nout; Nout++;
    }
  //Flag AlphaS
  if (FlagAlphaS == 1) {
    Flag[AlphaS] = Nout; Nout++;
    }
  //Flag Phi
  if (FlagPhi == 1) {
    Flag[Phi] = Nout; Nout++;
    }
  //Flag PsPdPv
  if (FlagPsPdPv == 1) {
    Flag[Ps] = Nout; Nout++;
    Flag[Pd] = Nout; Nout++;
    Flag[Pv] = Nout; Nout++;
    }
  //Flag SigmaHV
  if (FlagSigmaHV == 1) {
    Flag[SigmaHV] = Nout; Nout++;
    }
  //Flag RSoV
  if (FlagRSoV == 1) {
    Flag[RSoV] = Nout; Nout++;
    }
  //Flag CPR
  if (FlagCPR == 1) {
    Flag[CPR] = Nout; Nout++;
    }
  //Flag Alpha
  if (FlagAlpha == 1) {
    Flag[Alpha] = Nout; Nout++;
    }
  //Flag Tau
  if (FlagTau == 1) {
    Flag[Tau] = Nout; Nout++;
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      sprintf(file_name, "%s%s", out_dir, FileOut2[k]);
      if ((OutFile2[Flag[k]] = fopen(file_name, "wb")) == NULL)
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
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
        if (Valid[lig][col] == 1.) {
      
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[3][lig][col];
          M[1][1][1] = 0.;

          /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
          /* V complex eigenvecor matrix, lambda real vector*/
          Diagonalisation(2, M, V, lambda);

          for (k = 0; k < 2; k++)  if (lambda[k] < 0.) lambda[k] = 0.;
          for (k = 0; k < 2; k++)  {
            /* Scattering mechanism probability of occurence */
            p[k] = lambda[k] / (eps + lambda[0] + lambda[1]);
            if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
            }

          DP = (p[0]-p[1])/(p[0]+p[1]+eps);
          G0 = M_avg[C211][lig][col] + M_avg[C222][lig][col];
          G1 = M_avg[C211][lig][col] - M_avg[C222][lig][col];
          G2 = M_avg[C212_re][lig][col];
          G3 = -M_avg[C212_im][lig][col];
          rsov = DP / (1.-DP);
          
          if (Flag[Eigen1] != -1) M_out[Flag[Eigen1]][lig][col] = lambda[0];
          if (Flag[Eigen2] != -1) M_out[Flag[Eigen2]][lig][col] = lambda[1];
          if (Flag[Proba1] != -1) M_out[Flag[Proba1]][lig][col] = p[0];
          if (Flag[Proba2] != -1) M_out[Flag[Proba2]][lig][col] = p[1];

          if (Flag[Entropy] != -1) {
            M_out[Flag[Entropy]][lig][col] = 0;
            for (k = 0; k < 2; k++) {
              M_out[Flag[Entropy]][lig][col] -= p[k] * log(p[k] + eps);
              }
            M_out[Flag[Entropy]][lig][col] /= log(2.);
            }
          
          if (Flag[Mv] != -1) M_out[Flag[Mv]][lig][col] = 0.5*G0*(1.-DP);
          if (Flag[Ms] != -1) M_out[Flag[Ms]][lig][col] = 2.*G0*DP;
          if (Flag[RSoV] != -1) M_out[Flag[RSoV]][lig][col] = rsov;
          if (Flag[SigmaHV] != -1) M_out[Flag[SigmaHV]][lig][col] = G0*(1.-DP)/8.;
          if (Flag[CPR] != -1) M_out[Flag[CPR]][lig][col] = (G0-G3)/(G0+G3);

          if (strcmp(hybrid,"RHC") == 0) {
            alphas = 0.5*atan2(-G3, sqrt(G1*G1+G2*G2));
            alpha = 0.5*acos(-G3/G0);
            if (Flag[AlphaS] != -1) M_out[Flag[AlphaS]][lig][col] = alphas*180./pi;
            if (Flag[Phi] != -1) M_out[Flag[Phi]][lig][col] = atan2(G2, G1)*180./pi;
            if (Flag[Ps] != -1) M_out[Flag[Ps]][lig][col] = 0.5*G0*DP*(1.+cos(2.*alphas));
            if (Flag[Pd] != -1) M_out[Flag[Pd]][lig][col] = 0.5*G0*DP*(1.-cos(2.*alphas));
            if (Flag[Pv] != -1) M_out[Flag[Pv]][lig][col] = G0*(1.-DP);
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = alpha*180./pi;
            if (Flag[Tau] != -1) M_out[Flag[Tau]][lig][col] = (2.*sqrt(G1*G1+G2*G2))/(G0*sin(2.*alpha)*sin(2.*alpha));     
            }
          if (strcmp(hybrid,"LHC") == 0) {
            alphas = 0.5*atan2(G3, sqrt(G1*G1+G2*G2));
            alpha = 0.5*acos(G3/G0);
            if (Flag[AlphaS] != -1) M_out[Flag[AlphaS]][lig][col] = alphas*180./pi;
            if (Flag[Phi] != -1) M_out[Flag[Phi]][lig][col] = atan2(G2, G1)*180./pi;
            if (Flag[Ps] != -1) M_out[Flag[Ps]][lig][col] = 0.5*G0*DP*(1.+cos(2.*alphas));
            if (Flag[Pd] != -1) M_out[Flag[Pd]][lig][col] = 0.5*G0*DP*(1.-cos(2.*alphas));
            if (Flag[Pv] != -1) M_out[Flag[Pv]][lig][col] = G0*(1.-DP);
            if (Flag[CPR] != -1) M_out[Flag[CPR]][lig][col] = (1.+2.*rsov*sin(alphas)*sin(alphas))/(1.+2.*rsov*cos(alphas)*cos(alphas));
            if (Flag[Alpha] != -1) M_out[Flag[Alpha]][lig][col] = alpha*180./pi;
            if (Flag[Tau] != -1) M_out[Flag[Tau]][lig][col] = (2.*sqrt(G1*G1+G2*G2))/(G0*sin(2.*alpha)*sin(2.*alpha));     
            }
          } /*valid*/
        }
      }
    }

  for (k = 0; k < NPara; k++) 
    if (Flag[k] != -1) 
        write_block_matrix_matrix3d_float(OutFile2[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
    if (Flag[Np] != -1) fclose(OutFile2[Flag[Np]]);

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


