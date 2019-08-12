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

File   : h_a_alpha_decomposition.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Cloude-Pottier eigenvector/eigenvalue based 
               decomposition

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

/* ALIASES  */

/* CONSTANTS  */
#define Alpha  0
#define H  1
#define A  2
#define Alpha1 3
#define Alpha2 4
#define Beta1  5
#define Beta2  6
#define P1  7
#define P2  8

#define NPara 9

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
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  char file_name[FilePathLength];
  FILE *OutFile3[9];

  char *FileOut3[9] = {
  "alpha.bin", "entropy.bin", "anisotropy.bin",
  "alpha1.bin", "alpha2.bin", "beta1.bin", "beta2.bin",
  "p1.bin", "p2.bin"
  };
  
/* Internal variables */
  int ii, lig, col, k, l;
  int MasterSlave;
  float alpha[3], beta[3], p[3];

/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float *mean;
  float ***M_out;

  float ***T;
  float ***V;
  float *lambda;

  float *Buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_a_alpha_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-ms  	Master (1) - Slave (2) \n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "S2T6") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T6") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ms",int_cmd_prm,&MasterSlave,1,UsageHelp);

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

/***********************************************************************
***********************************************************************/

  check_dir(in_dir1);
  if (strcmp(PolType, "S2T6") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  if (strcmp(PolTypeIn,"S2")==0) file_name_in2 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  if (strcmp(PolTypeIn,"S2")==0) init_file_name(PolTypeIn, in_dir2, file_name_in2);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  if (strcmp(PolTypeIn,"S2")==0)
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (k = 0; k < NPara; k++) {
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

  if (strcmp(PolTypeIn,"S2")==0) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 2*NpolarIn*2*(Ncol+NwinC); NBlockB += 2*NpolarIn*NwinL*2*(Ncol+NwinC);
    }

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mout = NPara*Nlig*Sub_Ncol */
  NBlockA += NPara*Sub_Ncol; NBlockB += 0;
  /* Buffer = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
  
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

/* MATRIX ALLOCATION */
  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if (strcmp(PolTypeIn,"S2")==0) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    }

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out = matrix3d_float(NPara, NligBlock[0], Sub_Ncol);
  
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

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile1, S_in1, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_S2_noavg(in_datafile2, S_in2, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    S2_to_T6(S_in1, S_in2, M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    } else {
    /* Case of T6 */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

Nvalid = 0.;
#pragma omp parallel for private(col, Np, k, T, V, lambda, mean, Buffer) firstprivate(Nvalid, alpha, beta, p)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    mean = vector_float(NpolarOut);
    T = matrix3d_float(3, 3, 2);
    V = matrix3d_float(3, 3, 2);
    lambda = vector_float(3);
    Buffer = vector_float(NpolarOut);
    for (col = 0; col < Sub_Ncol; col++) {
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) Buffer[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++)
              Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            Buffer[Np] = Buffer[Np] - M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }      
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) mean[Np] = Buffer[Np]/Nvalid;

      for (k = 0; k < NPara; k++) M_out[k][lig][col] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        if ( MasterSlave == 1) {
          T[0][0][0] = eps + mean[T611];
          T[0][0][1] = 0.;
          T[0][1][0] = eps + mean[T612_re];
          T[0][1][1] = eps + mean[T612_im];
          T[0][2][0] = eps + mean[T613_re];
          T[0][2][1] = eps + mean[T613_im];
          T[1][0][0] = eps + mean[T612_re];
          T[1][0][1] = eps - mean[T612_im];
          T[1][1][0] = eps + mean[T622];
          T[1][1][1] = 0.;
          T[1][2][0] = eps + mean[T623_re];
          T[1][2][1] = eps + mean[T623_im];
          T[2][0][0] = eps + mean[T613_re];
          T[2][0][1] = eps - mean[T613_im];
          T[2][1][0] = eps + mean[T623_re];
          T[2][1][1] = eps - mean[T623_im];
          T[2][2][0] = eps + mean[T633];
          T[2][2][1] = 0.;
          } else {
          T[0][0][0] = eps + mean[T644];
          T[0][0][1] = 0.;
          T[0][1][0] = eps + mean[T645_re];
          T[0][1][1] = eps + mean[T645_im];
          T[0][2][0] = eps + mean[T646_re];
          T[0][2][1] = eps + mean[T646_im];
          T[1][0][0] = eps + mean[T645_re];
          T[1][0][1] = eps - mean[T645_im];
          T[1][1][0] = eps + mean[T655];
          T[1][1][1] = 0.;
          T[1][2][0] = eps + mean[T656_re];
          T[1][2][1] = eps + mean[T656_im];
          T[2][0][0] = eps + mean[T646_re];
          T[2][0][1] = eps - mean[T646_im];
          T[2][1][0] = eps + mean[T656_re];
          T[2][1][1] = eps - mean[T656_im];
          T[2][2][0] = eps + mean[T666];
          T[2][2][1] = 0.;
          }

        /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
        /* V complex eigenvecor matrix, lambda real vector*/
        Diagonalisation(3, T, V, lambda);

        for (k = 0; k < 3; k++)
          if (lambda[k] < 0.) lambda[k] = 0.;

        for (k = 0; k < 3; k++) {
        /* Unitary eigenvectors */
          alpha[k] = acos(sqrt(V[0][k][0] * V[0][k][0] + V[0][k][1] * V[0][k][1]));
          beta[k] =  atan2(sqrt(V[2][k][0] * V[2][k][0] + V[2][k][1] * V[2][k][1]), eps + sqrt(V[1][k][0] * V[1][k][0] + V[1][k][1] * V[1][k][1]));
        /* Scattering mechanism probability of occurence */
          p[k] = lambda[k] / (eps + lambda[0] + lambda[1] + lambda[2]);
          if (p[k] < 0.) p[k] = 0.; if (p[k] > 1.) p[k] = 1.;
          }

        /* Mean scattering mechanism */
        M_out[Alpha][lig][col] = 0;
        M_out[H][lig][col] = 0;
        for (k = 0; k < 3; k++) {
          M_out[Alpha][lig][col] += alpha[k] * p[k];
          M_out[H][lig][col] -= p[k] * log(p[k] + eps);
          }
        /* Scaling */
        M_out[Alpha][lig][col] *= 180. / pi;
        M_out[H][lig][col] /= log(3.);

        M_out[P1][lig][col] = p[0];
        M_out[P2][lig][col] = p[1];

        M_out[Alpha1][lig][col] = alpha[0] * 180. / pi;
        M_out[Alpha2][lig][col] = alpha[1] * 180. / pi;

        M_out[Beta1][lig][col] = beta[0] * 180. / pi;
        M_out[Beta2][lig][col] = beta[1] * 180. / pi;

        M_out[A][lig][col] = (p[1] - p[2]) / (p[1] + p[2] + eps);
        } /*valid*/
      }
    free_vector_float(mean);
    free_matrix3d_float(T, 3, 3);
    free_matrix3d_float(V, 3, 3);
    free_vector_float(lambda);
    free_vector_float(Buffer);
    }

  for (k = 0; k < NPara; k++)
    write_block_matrix_matrix3d_float(OutFile3[k], M_out, k, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if (strcmp(PolTypeIn,"S2")==0) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + NwinL);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + NwinL);
    }

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NPara, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) fclose(OutFile3[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if (strcmp(PolTypeIn,"S2")==0)
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}




