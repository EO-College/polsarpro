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

File   : matS_operand_matXSU.c
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

Description :  MatS (operand) MatXSU = MatS

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
/* LOCAL VARIABLES */
  FILE *file_matX;
  char operand[10], Tmp[100];
  char matXfile[FilePathLength];
  
/* Internal variables */
  int lig, col;

/* Matrix arrays */
  float **MatX;
  float ***M_in;
  float ***M_out;
  float ***MM1;
  float ***MM2;
  float ***MM3;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nmatS_operand_matXSU.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directroy\n");
strcat(UsageHelp," (string)	-if  	input file matX\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-op  	operand\n");
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

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,matXfile,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-op",str_cmd_prm,operand,1,UsageHelp);
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

  check_dir(in_dir);
  check_file(matXfile);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;
 
/********************************************************************
********************************************************************/
/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  strcpy(PolType,"S2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, out_dir, file_name_out);

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
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open output file : ", file_name_out[Np]);
  
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

  /* Sin1 = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  /* Sout = NpolarOut*Nlig*2*Sub_Ncol */
  NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
  
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

  MatX = matrix_float(NpolarOut, 2); 

  M_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);

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
  fscanf(file_matX, "%f\n", &MatX[s11][0]);
  fscanf(file_matX, "%f\n", &MatX[s11][1]);
  fscanf(file_matX, "%f\n", &MatX[s12][0]);
  fscanf(file_matX, "%f\n", &MatX[s12][1]);
  fscanf(file_matX, "%f\n", &MatX[s21][0]);
  fscanf(file_matX, "%f\n", &MatX[s21][1]);
  fscanf(file_matX, "%f\n", &MatX[s22][0]);
  fscanf(file_matX, "%f\n", &MatX[s22][1]);
  fclose(file_matX);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_S2_noavg(in_datafile, M_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
#pragma omp parallel for private(col, Np, MM1, MM2, MM3)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    MM1 = matrix3d_float(2, 2, 2);
    MM2 = matrix3d_float(2, 2, 2);
    MM3 = matrix3d_float(2, 2, 2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        MM1[0][0][0] = M_in[s11][lig][2*col]; MM1[0][0][1] = M_in[s11][lig][2*col+1];
        MM1[0][1][0] = M_in[s12][lig][2*col]; MM1[0][1][1] = M_in[s12][lig][2*col+1];
        MM1[1][0][0] = M_in[s21][lig][2*col]; MM1[1][0][1] = M_in[s21][lig][2*col+1];
        MM1[1][1][0] = M_in[s22][lig][2*col]; MM1[1][1][1] = M_in[s22][lig][2*col+1];
        MM2[0][0][0] = MatX[s11][0]; MM2[0][0][1] = MatX[s11][1];
        MM2[0][1][0] = MatX[s12][0]; MM2[0][1][1] = MatX[s12][1];
        MM2[1][0][0] = MatX[s21][0]; MM2[1][0][1] = MatX[s21][1];
        MM2[1][1][0] = MatX[s22][0]; MM2[1][1][1] = MatX[s22][1];
        ProductCmplxMatrix(MM1,MM2,MM3,2);
        MM1[0][0][0] = MM2[0][0][0]; MM1[0][0][1] = MM2[0][0][1];
        MM1[0][1][0] = MM2[1][0][0]; MM1[0][1][1] = MM2[1][0][1];
        MM1[1][0][0] = MM2[0][1][0]; MM1[1][0][1] = MM2[0][1][1];
        MM1[1][1][0] = MM2[1][1][0]; MM1[1][1][1] = MM2[1][1][1];
        ProductCmplxMatrix(MM1,MM3,MM2,2);
        M_out[s11][lig][2*col] = MM2[0][0][0]; M_out[s11][lig][2*col+1] = MM2[0][0][1];
        M_out[s12][lig][2*col] = MM2[0][1][0]; M_out[s12][lig][2*col+1] = MM2[0][1][1];
        M_out[s21][lig][2*col] = MM2[1][0][0]; M_out[s21][lig][2*col+1] = MM2[1][0][1];
        M_out[s22][lig][2*col] = MM2[1][1][0]; M_out[s22][lig][2*col+1] = MM2[1][1][1];
        } else {
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][2*col] = 0.; M_out[Np][lig][2*col+1] = 0.;
          }
        }
      }
    free_matrix3d_float(MM1, 2, 2);
    free_matrix3d_float(MM2, 2, 2);
    free_matrix3d_float(MM3, 2, 2);
    }
  write_block_matrix3d_cmplx(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(M_in, NligBlock[0] + NwinL);
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


