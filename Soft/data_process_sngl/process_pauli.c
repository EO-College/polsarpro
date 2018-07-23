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

File   : process_pauli.c
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

Description :  Process Pauli parameters : Cmplx,Mod,dB,Pha

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ALIASES  */
/* Pauli */
#define hhpvv  0
#define hhmvv  1
#define hvpvh  2
#define hvmvh  3

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
  char Format[10], file_name[FilePathLength];
  char *file_name_out_cmplx[4] = { "s11ps22.bin", "s11ms22.bin", "s12ps21.bin", "s12ms21.bin" };
  char *file_name_out_mod[4] = { "s11ps22_mod.bin", "s11ms22_mod.bin", "s12ps21_mod.bin", "s12ms21_mod.bin" };
  char *file_name_out_db[4] = { "s11ps22_db.bin", "s11ms22_db.bin", "s12ps21_db.bin", "s12ms21_db.bin" };
  char *file_name_out_pha[4] = { "s11ps22_pha.bin", "s11ms22_pha.bin", "s12ps21_pha.bin", "s12ms21_pha.bin" };
  
/* Internal variables */
  int lig, col;
  float hhpvvr, hhpvvi;
  float hhmvvr, hhmvvi;
  float hvpvhr, hvpvhi;
  float hvmvhr, hvmvhi;

/* Matrix arrays */
  float ***S_in;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nprocess_pauli.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-fmt 	Output Format (cmplx, mod, db, pha)\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fmt",str_cmd_prm,Format,1,UsageHelp);
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
  }

  strcpy(PolType,"S2");
  
/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  
  NwinL = 1; NwinC = 1;
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
  for (Np = 0; Np < NpolarOut; Np++) {
    if (strcmp(Format, "cmplx") == 0)
      sprintf(file_name, "%s%s", out_dir, file_name_out_cmplx[Np]);
    if (strcmp(Format, "mod") == 0)
      sprintf(file_name, "%s%s", out_dir, file_name_out_mod[Np]);
    if (strcmp(Format, "db") == 0)
      sprintf(file_name, "%s%s", out_dir, file_name_out_db[Np]);
    if (strcmp(Format, "pha") == 0)
      sprintf(file_name, "%s%s", out_dir, file_name_out_pha[Np]);
    if ((out_datafile[Np] = fopen(file_name, "wb")) == NULL)
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
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Sin = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  if (strcmp(Format, "cmplx") == 0) {
    NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
    } else {
    NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
    }

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  if (strcmp(Format, "cmplx") == 0) {
    M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
    } else {
    M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
    }
    
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

  read_block_S2_noavg(in_datafile, S_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        hhpvvr = (S_in[s11][lig][2*col]+S_in[s22][lig][2*col]) / sqrt(2.);
        hhpvvi = (S_in[s11][lig][2*col+1]+S_in[s22][lig][2*col+1]) / sqrt(2.);
        hhmvvr = (S_in[s11][lig][2*col]-S_in[s22][lig][2*col]) / sqrt(2.);
        hhmvvi = (S_in[s11][lig][2*col+1]-S_in[s22][lig][2*col+1]) / sqrt(2.);
        hvpvhr = (S_in[s12][lig][2*col]+S_in[s21][lig][2*col]) / sqrt(2.);
        hvpvhi = (S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]) / sqrt(2.);
        hvmvhr = (S_in[s12][lig][2*col]-S_in[s21][lig][2*col]) / sqrt(2.);
        hvmvhi = (S_in[s12][lig][2*col+1]-S_in[s21][lig][2*col+1]) / sqrt(2.);
        if (strcmp(Format, "cmplx") == 0) {
          M_out[hhpvv][lig][2*col] = hhpvvr; M_out[hhpvv][lig][2*col+1] = hhpvvi;
          M_out[hhmvv][lig][2*col] = hhmvvr; M_out[hhmvv][lig][2*col+1] = hhmvvi;
          M_out[hvpvh][lig][2*col] = hvpvhr; M_out[hvpvh][lig][2*col+1] = hvpvhi;
          M_out[hvmvh][lig][2*col] = hvmvhr; M_out[hvmvh][lig][2*col+1] = hvmvhi;
          }
        if (strcmp(Format, "mod") == 0) {
          M_out[hhpvv][lig][col] = sqrt(hhpvvr*hhpvvr+hhpvvi*hhpvvi);
          M_out[hhmvv][lig][col] = sqrt(hhmvvr*hhmvvr+hhmvvi*hhmvvi);
          M_out[hvpvh][lig][col] = sqrt(hvpvhr*hvpvhr+hvpvhi*hvpvhi);
          M_out[hvmvh][lig][col] = sqrt(hvmvhr*hvmvhr+hvmvhi*hvmvhi);
          }
        if (strcmp(Format, "db") == 0) {
          M_out[hhpvv][lig][col] = sqrt(hhpvvr*hhpvvr+hhpvvi*hhpvvi);
          if (M_out[hhpvv][lig][col] < eps) M_out[hhpvv][lig][col] = eps;
          M_out[hhpvv][lig][col] = 20.*log10(M_out[hhpvv][lig][col]);
          M_out[hhmvv][lig][col] = sqrt(hhmvvr*hhmvvr+hhmvvi*hhmvvi);
          if (M_out[hhmvv][lig][col] < eps) M_out[hhmvv][lig][col] = eps;
          M_out[hhmvv][lig][col] = 20.*log10(M_out[hhmvv][lig][col]);
          M_out[hvpvh][lig][col] = sqrt(hvpvhr*hvpvhr+hvpvhi*hvpvhi);
          if (M_out[hvpvh][lig][col] < eps) M_out[hvpvh][lig][col] = eps;
          M_out[hvpvh][lig][col] = 20.*log10(M_out[hvpvh][lig][col]);
          M_out[hvmvh][lig][col] = sqrt(hvmvhr*hvmvhr+hvmvhi*hvmvhi);
          if (M_out[hvmvh][lig][col] < eps) M_out[hvmvh][lig][col] = eps;
          M_out[hvmvh][lig][col] = 20.*log10(M_out[hvmvh][lig][col]);
          }
        if (strcmp(Format, "pha") == 0) {
          M_out[hhpvv][lig][col] = atan2(hhpvvi,hhpvvr) * 180. / pi;
          M_out[hhmvv][lig][col] = atan2(hhmvvi,hhmvvr) * 180. / pi;
          M_out[hvpvh][lig][col] = atan2(hvpvhi,hvpvhr) * 180. / pi;
          M_out[hvmvh][lig][col] = atan2(hvmvhi,hvmvhr) * 180. / pi;
          }
        } else {
        for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.; 
        }
      }
    }

  if (strcmp(Format, "cmplx") == 0) {
    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, 2*Sub_Ncol);
    } else {
    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    }
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(S_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);

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


