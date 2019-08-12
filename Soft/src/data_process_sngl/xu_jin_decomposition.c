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

File     : xu-jin_decomposition.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Feng XU
Version  : 1.0
Creation : 12/2016
Update  :
*--------------------------------------------------------------------

Description :  Xu & Jin decomposition

Deorientation theory of Polarimetric scattering targets and 
application to terrain surface classifcation
Feg XU and Ya-Qiu JIN
IEEE TGRS Vol 43, n° 10, October 2005

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
float calpsim(float beta, float fee2, float fee3);

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
  int Config;
  char *PolTypeConf[NPolType] = {"S2T3", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Flag Parameters */
  int Nout;
  FILE *OutFile3[7];

  char *FileOut3[7] = {
  "xu-jin_H.bin", "xu-jin_U.bin", "xu-jin_V.bin",
  "xu-jin_W.bin", "xu-jin_psi.bin",
  "xu-jin_1mVs2.bin", "xu-jin_1mU.bin"};

/* Internal variables */
  int ii, lig, col, k;
  int ligDone = 0;
  int Hidx, uidx, vidx, widx, psiidx;

  float beta0, delta0, gamma0;
  float psim, p[3];
  float a,b,c,u,v,w,psi;

/* Matrix arrays */
  float **M_avg;
  float ***M_in;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;
  
  float ***kp;
  float ***kl;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nxu_jin_decomposition.exe\n");
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
strcat(UsageHelp," (int)   	-fl1 	Flag Parameters (0/1)\n");
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
  Hidx = 0; uidx = 1; vidx = 2; widx = 3; psiidx = 4;
  
  //M = matrix3d_float(3, 3, 2);
  //V = matrix3d_float(3, 3, 2);
  //lambda = vector_float(3);

  Nout = 7;
  for (k = 0; k < Nout; k++) {
    sprintf(file_name, "%s%s", out_dir, FileOut3[k]);
    if ((OutFile3[k] = fopen(file_name, "wb")) == NULL)
      edit_error("Could not open input file : ", file_name);
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
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Mout = Nout*Nlig*Sub_Ncol */
  NBlockA += Nout*Sub_Ncol; NBlockB += 0;
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
  M_out = matrix3d_float(Nout, NligBlock[0], Sub_Ncol);

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
/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol + NwinC, 0, 0);

beta0 = delta0 = gamma0 = 0.;
psim = a = b = c = u = v = w = psi = 0.;
#pragma omp parallel for private(col, k, ii, M, V, lambda, kp, kl, M_avg) firstprivate(beta0, delta0, gamma0, psim, a, b, c, u, v, w, psi, p) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);
    kp = matrix3d_float(3, 1, 2);
    kl = matrix3d_float(3, 1, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
  
    for (col = 0; col < Sub_Ncol; col++) {
      for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        M[0][0][0] = eps + M_avg[0][col];
        M[0][0][1] = 0.;
        M[0][1][0] = eps + M_avg[1][col];
        M[0][1][1] = eps + M_avg[2][col];
        M[0][2][0] = eps + M_avg[3][col];
        M[0][2][1] = eps + M_avg[4][col];
        M[1][0][0] =  M[0][1][0];
        M[1][0][1] = -M[0][1][1];
        M[1][1][0] = eps + M_avg[5][col];
        M[1][1][1] = 0.;
        M[1][2][0] = eps + M_avg[6][col];
        M[1][2][1] = eps + M_avg[7][col];
        M[2][0][0] =  M[0][2][0];
        M[2][0][1] = -M[0][2][1];
        M[2][1][0] =  M[1][2][0];
        M[2][1][1] = -M[1][2][1];
        M[2][2][0] = eps + M_avg[8][col];
        M[2][2][1] = 0.;

        /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
        /* V complex eigenvecor matrix, lambda real vector*/
        Diagonalisation(3, M, V, lambda);
  
        for (k = 0; k < 3; k++) if (lambda[k] < 0.) lambda[k] = 0.;
        for (k = 0; k < 3; k++) {
          p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
          if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
          }

        M_out[Hidx][lig][col] = 0;
        for (k = 0; k < 3; k++) M_out[Hidx][lig][col] -= p[k] * log(p[k] + eps);
        M_out[Hidx][lig][col] /= log(3.);

        //seek primary eigenvector
        k = 0;
        for (ii = 1; ii < 3; ii++)	 k = lambda[ii] > lambda[k] ? ii : k;
        beta0 =  atan2((float)sqrt(V[2][k][0] * V[2][k][0] + V[2][k][1] * V[2][k][1]), (float)eps + sqrt(V[1][k][0] * V[1][k][0] + V[1][k][1] * V[1][k][1]));
        delta0 = atan2((float)V[1][k][1],(float) eps + V[1][k][0]);
        gamma0= atan2((float)V[2][k][1], (float)eps + V[2][k][0]);

        psim = calpsim(beta0, delta0, gamma0);
        kp[0][0][0] = V[0][k][0];
        kp[0][0][1] = V[0][k][1];
        kp[1][0][0] = V[1][k][0]*cos(2*psim)+V[2][k][0]*sin(2*psim);
        kp[1][0][1] = V[1][k][1]*cos(2*psim)+V[2][k][1]*sin(2*psim);
        kp[2][0][0] = -V[1][k][0]*sin(2*psim)+V[2][k][0]*cos(2*psim);
        kp[2][0][1] = -V[1][k][1]*sin(2*psim)+V[2][k][1]*cos(2*psim);
        kl[0][0][0] = 0.5*kp[0][0][0]+0.5*kp[1][0][0];
        kl[0][0][1] = 0.5*kp[0][0][1]+0.5*kp[1][0][1];
        kl[1][0][0] = 0.707*kp[2][0][0];
        kl[1][0][1] = 0.707*kp[2][0][1];
        kl[2][0][0] = 0.5*kp[0][0][0]-0.5*kp[1][0][0];
        kl[2][0][1] = 0.5*kp[0][0][1]-0.5*kp[1][0][1];

        a = atan2(sqrt(kl[2][0][0]*kl[2][0][0] + kl[2][0][1]*kl[2][0][1]), sqrt(kl[0][0][0]*kl[0][0][0] + kl[0][0][1]*kl[0][0][1]));
        b = atan2((kl[0][0][0]*kl[2][0][1]-kl[0][0][1]*kl[2][0][0]), (kl[0][0][0]*kl[2][0][0]+kl[0][0][1]*kl[2][0][1])) / 2;
        c = fmod((double)atan2(sqrt(kl[0][0][0]*kl[0][0][0] + kl[0][0][1]*kl[0][0][1] + kl[2][0][0]*kl[2][0][0] + kl[2][0][1]*kl[2][0][1]),
                               sqrt(kl[1][0][0]*kl[1][0][0] + kl[1][0][1]*kl[1][0][1])), pi);
        w = cos(c);
        u = cos(2*a);
        v = cos(2*b);
        psi = psim*180./pi;
        if (u < 0) psi = psi+90.;
        u = fabs(u);

        M_out[uidx][lig][col] = u;
        M_out[vidx][lig][col] = v; 
        M_out[widx][lig][col] = w;
        M_out[psiidx][lig][col] = psi;
        M_out[5][lig][col] = (1. - v)/2.;
        M_out[6][lig][col] = 1. - u;
        } /*valid*/
      }
    free_matrix3d_float(M, 3, 3);
    free_matrix3d_float(V, 3, 3);
    free_vector_float(lambda);
    free_matrix3d_float(kp, 3, 1);
    free_matrix3d_float(kl, 3, 1);
    free_matrix_float(M_avg,NpolarOut);
    }

  for (k = 0; k < Nout; k++)    write_block_matrix_matrix3d_float(OutFile3[k], M_out, k, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

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
  for (Np = 0; Np < Nout; Np++) fclose(OutFile3[Np]);

/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
float calpsim(float beta, float fee2, float fee3)
{
  float cdp = cos(fee2-fee3);
  float x, psim, sign;

  x = atan(tan(2.*beta)*fabs(cdp));
  x = 2.*beta-fmod((double)(2.*beta+2.*pi),pi) + fmod((double)(x+2.*pi),pi);

  if (cdp > 0)
    sign = 1.;
  else if (cdp < 0)
    sign = -1.;
  else
    sign = 0.;
  psim = fmod((double)(x*sign/4 + 2.*pi),pi/2);

return psim;
}

