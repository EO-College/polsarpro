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

File   : matM_operand_matX_dist.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 08/2015
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

Description :  MatM (operand) MatX = File

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
#define NPolType 6
/* LOCAL VARIABLES */
  FILE *file_matX, *out_file;
  int Config;
  char *PolTypeConf[NPolType] = {
    "C2", "C3", "C4", "T2", "T3", "T4"};
  char Tmp[100];
  char matXfile[FilePathLength];
  char file_out[FilePathLength];  
  
/* Internal variables */
  int ii, lig, col, Npp;

/* Matrix arrays */
  float **MatX;
  float ***M_in;
  float **M_out;
  float ***M_m1;
  float ***M;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmatM_operand_matX_dist.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directroy\n");
strcat(UsageHelp," (string)	-if  	input file matX\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-of  	output file name\n");
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

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,matXfile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_file(matXfile);
  check_file(file_out);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;
 
/********************************************************************
********************************************************************/
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

  if ((file_matX = fopen(matXfile, "rb")) == NULL)
      edit_error("Could not open input file : ", matXfile);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
      
/* OUTPUT FILE OPENING*/
  if ((out_file = fopen(file_out, "wb")) == NULL)
    edit_error("Could not open input file : ", file_out);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask = (Nlig+NwinL)*(Ncol+NwinC) */ 
  NBlockA += Ncol+NwinC; NBlockB += NwinL*(Ncol+NwinC);

  /* Min1 = NpolarIn*Nlig*Ncol */
  NBlockA += NpolarIn*Ncol; NBlockB += 0;
  /* Mout = Nlig*Sub_Ncol */
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  MatX = matrix_float(NpolarIn, 2); 

  M_in = matrix3d_float(NpolarIn, NligBlock[0], Ncol);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

  if (strcmp(PolTypeOut,"C2")==0) Npp = 2;
  if (strcmp(PolTypeOut,"C3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"C4")==0) Npp = 4;
  if (strcmp(PolTypeOut,"T2")==0) Npp = 2;
  if (strcmp(PolTypeOut,"T3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"T4")==0) Npp = 4;
  M_m1 = matrix3d_float(Npp, Npp, 2);

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
/* READ matX DATA */

  fscanf(file_matX, "%s\n", Tmp);
  fscanf(file_matX, "%s\n", Tmp);
  fscanf(file_matX, "%s\n", Tmp);
  for (Np = 0; Np < NpolarOut; Np++) 
    fscanf(file_matX, "%f\n", &MatX[Np][0]);
  fclose(file_matX);

  M = matrix3d_float(Npp, Npp, 2);

  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"T2")==0)) {
    /* Average complex coherency matrix determination*/
    M[0][0][0] = eps + MatX[0][0];
    M[0][0][1] = 0.;
    M[0][1][0] = eps + MatX[1][0];
    M[0][1][1] = eps + MatX[2][0];
    M[1][0][0] =  M[0][1][0];
    M[1][0][1] = -M[0][1][1];
    M[1][1][0] = eps + MatX[3][0];
    M[1][1][1] = 0.;
    InverseHermitianMatrix2(M, M_m1);
    }
  if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
    /* Average complex coherency matrix determination*/
    M[0][0][0] = eps + MatX[0][0];
    M[0][0][1] = 0.;
    M[0][1][0] = eps + MatX[1][0];
    M[0][1][1] = eps + MatX[2][0];
    M[0][2][0] = eps + MatX[3][0];
    M[0][2][1] = eps + MatX[4][0];
    M[1][0][0] =  M[0][1][0];
    M[1][0][1] = -M[0][1][1];
    M[1][1][0] = eps + MatX[5][0];
    M[1][1][1] = 0.;
    M[1][2][0] = eps + MatX[6][0];
    M[1][2][1] = eps + MatX[7][0];
    M[2][0][0] =  M[0][2][0];
    M[2][0][1] = -M[0][2][1];
    M[2][1][0] =  M[1][2][0];
    M[2][1][1] = -M[1][2][1];
    M[2][2][0] = eps + MatX[8][0];
    M[2][2][1] = 0.;
    InverseHermitianMatrix3(M, M_m1);
    }
  if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
    /* Average complex coherency matrix determination*/
    M[0][0][0] = eps + MatX[0][0];
    M[0][0][1] = 0.;
    M[0][1][0] = eps + MatX[1][0];
    M[0][1][1] = eps + MatX[2][0];
    M[0][2][0] = eps + MatX[3][0];
    M[0][2][1] = eps + MatX[4][0];
    M[0][3][0] = eps + MatX[5][0];
    M[0][3][1] = eps + MatX[6][0];
    M[1][0][0] =  M[0][1][0];
    M[1][0][1] = -M[0][1][1];
    M[1][1][0] = eps + MatX[7][0];
    M[1][1][1] = 0.;
    M[1][2][0] = eps + MatX[8][0];
    M[1][2][1] = eps + MatX[9][0];
    M[1][3][0] = eps + MatX[10][0];
    M[1][3][1] = eps + MatX[11][0];
    M[2][0][0] =  M[0][2][0];
    M[2][0][1] = -M[0][2][1];
    M[2][1][0] =  M[1][2][0];
    M[2][1][1] = -M[1][2][1];
    M[2][2][0] = eps + MatX[12][0];
    M[2][2][1] = 0.;
    M[2][3][0] = eps + MatX[13][0];
    M[2][3][1] = eps + MatX[14][0];
    M[3][0][0] =  M[0][3][0];
    M[3][0][1] = -M[0][3][1];
    M[3][1][0] =  M[1][3][0];
    M[3][1][1] = -M[1][3][1];
    M[3][2][0] =  M[2][3][0];
    M[3][2][1] = -M[2][3][1];
    M[3][3][0] = eps + MatX[15][0];
    M[3][3][1] = 0.;
    InverseHermitianMatrix4(M, M_m1);
    }

  free_matrix3d_float(M, Npp, Npp);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, M)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out[lig][col] = 0.;
      if (Valid[lig][col] == 1.) {
        if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"T2")==0)) {
          /* Average complex coherency matrix determination*/
          M[0][0][0] = eps + M_in[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_in[1][lig][col];
          M[0][1][1] = eps + M_in[2][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_in[3][lig][col];
          M[1][1][1] = 0.;
          M_out[lig][col] = Trace2_HM1xHM2(M_m1,M);
          }
        if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
          /* Average complex coherency matrix determination*/
          M[0][0][0] = eps + M_in[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_in[1][lig][col];
          M[0][1][1] = eps + M_in[2][lig][col];
          M[0][2][0] = eps + M_in[3][lig][col];
          M[0][2][1] = eps + M_in[4][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_in[5][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_in[6][lig][col];
          M[1][2][1] = eps + M_in[7][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_in[8][lig][col];
          M[2][2][1] = 0.;
          M_out[lig][col] = Trace3_HM1xHM2(M_m1,M);
          }
        if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
          /* Average complex coherency matrix determination*/
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
          M_out[lig][col] = Trace4_HM1xHM2(M_m1,M);
          }
        }
      }
    free_matrix3d_float(M, Npp, Npp);
    }
  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(M_in1, NligBlock[0] + NwinL);
  free_matrix_float(M_in2, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0] + NwinL);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}


