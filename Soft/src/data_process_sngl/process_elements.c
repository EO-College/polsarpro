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

File  : process_elements.c
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

Description :  Process any Mxy parameters : Mod,dB,Pha,A,Adb,I,Idb 

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 9
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "C3", "C4", "T3", "T4", "T6", "SPP", "IPP"};
  FILE *in_file1, *in_file2, *out_file;
  char file_name[FilePathLength], Format[10];
  
/* Internal variables */
  int ii, lig, col;

  int is_complex, element_index;
  float xr, xi, xx;

/* Matrix arrays */
  float **M_in1;
  float **M_in2;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nprocess_elements.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-elt 	Element Index\n");
strcat(UsageHelp," (string)	-fmt 	Format :\n");
strcat(UsageHelp,"			S2, SPP, IPP : A, Adb, I, Idb, pha\n");
strcat(UsageHelp,"			C3, C4, T3, T4, T6 : mod, db, pha\n");
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
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-elt",int_cmd_prm,&element_index,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fmt",str_cmd_prm,Format,1,UsageHelp);

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

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
/* INPUT FILE OPENING*/
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    sprintf(file_name, "%ss%d.bin", in_dir, element_index);
    if ((in_file1 = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open output file : ", file_name);
    }
  if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)||(strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) {
    if ((element_index == 11) + (element_index == 22) + (element_index == 33) +  (element_index == 44) +  (element_index == 55) +  (element_index == 66)) is_complex = 0;
    else if ((element_index == 12) + (element_index == 13) + (element_index == 14) + (element_index == 15) + (element_index == 16)
           + (element_index == 23) + (element_index == 24) + (element_index == 25) + (element_index == 26) + (element_index == 34)
           + (element_index == 35) + (element_index == 36) + (element_index == 45) + (element_index == 46) + (element_index == 56)) is_complex = 1;
    if (is_complex == 0) {
      if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)) sprintf(file_name, "%sC%d.bin", in_dir, element_index);
      if ((strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) sprintf(file_name, "%sT%d.bin", in_dir, element_index);
      if ((in_file1 = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open output file : ", file_name);
      }
    if (is_complex == 1) {
      if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)) sprintf(file_name, "%sC%d_real.bin", in_dir, element_index);
      if ((strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) sprintf(file_name, "%sT%d_real.bin", in_dir, element_index);
      if ((in_file1 = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open output file : ", file_name);
      if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)) sprintf(file_name, "%sC%d_imag.bin", in_dir, element_index);
      if ((strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) sprintf(file_name, "%sT%d_imag.bin", in_dir, element_index);
      if ((in_file2 = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open output file : ", file_name);
      }
    }
  if (strcmp(PolTypeIn,"IPP")==0) {
  sprintf(file_name, "%sI%d.bin", in_dir, element_index);
  if ((in_file1 = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  }

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    if (strcmp(Format, "A") == 0) sprintf(file_name, "%sA%d.bin", out_dir, element_index);
    if (strcmp(Format, "Adb") == 0) sprintf(file_name, "%sA%d_db.bin", out_dir, element_index);
    if (strcmp(Format, "I") == 0) sprintf(file_name, "%sI%d.bin", out_dir, element_index);
    if (strcmp(Format, "Idb") == 0) sprintf(file_name, "%sI%d_db.bin", out_dir, element_index);
    if (strcmp(Format, "pha") == 0) sprintf(file_name, "%ss%d_pha.bin", out_dir, element_index);
    }
  if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)||(strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) {
    if ((element_index == 11) + (element_index == 22) + (element_index == 33) +  (element_index == 44) +  (element_index == 55) +  (element_index == 66)) is_complex = 0;
    else if ((element_index == 12) + (element_index == 13) + (element_index == 14) + (element_index == 15) + (element_index == 16)
           + (element_index == 23) + (element_index == 24) + (element_index == 25) + (element_index == 26) + (element_index == 34)
           + (element_index == 35) + (element_index == 36) + (element_index == 45) + (element_index == 46) + (element_index == 56)) is_complex = 1;
    if (strcmp(Format, "mod") == 0) {
      if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)) sprintf(file_name, "%sC%d_mod.bin", in_dir, element_index);
      if ((strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) sprintf(file_name, "%sT%d_mod.bin", in_dir, element_index);
      }
    if (strcmp(Format, "db") == 0) {
      if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)) sprintf(file_name, "%sC%d_db.bin", in_dir, element_index);
      if ((strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) sprintf(file_name, "%sT%d_db.bin", in_dir, element_index);
      }
    if ((strcmp(Format, "pha") == 0) * (is_complex == 1)) {
      if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)) sprintf(file_name, "%sC%d_pha.bin", in_dir, element_index);
      if ((strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) sprintf(file_name, "%sT%d_pha.bin", in_dir, element_index);
      }
    if ((strcmp(Format, "pha") == 0) * (is_complex == 0)) edit_error("Can't compute a phase from real data", "");
    }
  if (strcmp(PolTypeIn,"IPP")==0) {
    if (strcmp(Format, "A") == 0) sprintf(file_name, "%sA%d.bin", out_dir, element_index);
    if (strcmp(Format, "Adb") == 0) sprintf(file_name, "%sA%d_db.bin", out_dir, element_index);
    if (strcmp(Format, "Idb") == 0) sprintf(file_name, "%sI%d_db.bin", out_dir, element_index);
    }
  if ((out_file = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);
  
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

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  /* Sin = NpolarIn*Nlig*2*Ncol */
  NBlockA += 2*Ncol; NBlockB += 0;
  } else {
  /* Min1 = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* Min2 = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  }

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

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    M_in1 = matrix_float(NligBlock[0], 2*Ncol);
    }
  if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)||(strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) {
    if ((element_index == 11) + (element_index == 22) + (element_index == 33) +  (element_index == 44) +  (element_index == 55) +  (element_index == 66)) is_complex = 0;
    else if ((element_index == 12) + (element_index == 13) + (element_index == 14) + (element_index == 15) + (element_index == 16)
           + (element_index == 23) + (element_index == 24) + (element_index == 25) + (element_index == 26) + (element_index == 34)
           + (element_index == 35) + (element_index == 36) + (element_index == 45) + (element_index == 46) + (element_index == 56)) is_complex = 1;
  if (is_complex == 0) {
    M_in1 = matrix_float(NligBlock[0], Ncol);
    }
  if (is_complex == 1) {
    M_in1 = matrix_float(NligBlock[0], Ncol);
    M_in2 = matrix_float(NligBlock[0], Ncol);
    }
  }
  if (strcmp(PolTypeIn,"IPP")==0) {
  M_in1 = matrix_float(NligBlock[0], Ncol);
  }
  M_out = matrix_float(NligBlock[0], Sub_Ncol);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
#pragma omp parallel for private(col)
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_cmplx(in_file1, M_in1, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, xr, xi, xx)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        xr = M_in1[lig][2*col];
        xi = M_in1[lig][2*col + 1];
        if (strcmp(Format, "A") == 0) {
          M_out[lig][col] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(Format, "Adb") == 0) {
          xx = sqrt(xr * xr + xi * xi);
          if (xx <= eps) xx=eps;
          M_out[lig][col] = 20. * log10(xx);
          }
        if (strcmp(Format, "I") == 0) {
          M_out[lig][col] = xr * xr + xi * xi;
          }
        if (strcmp(Format, "Idb") == 0) {
          xx = xr * xr + xi * xi;
          if (xx <= eps) xx=eps;
          M_out[lig][col] = 10. * log10(xx);
          }
        if (strcmp(Format, "pha") == 0) {
          if ((xr == 0.0) && (xi == 0.0)) xr += eps;
          M_out[lig][col] = atan2(xi, xr) * 180. / pi;
          }
        } else {
        M_out[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock
}

/*******************************************************************/

if (strcmp(PolTypeIn,"IPP")==0) {

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file1, M_in1, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, xx)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (strcmp(Format, "A") == 0) {
          M_out[lig][col] = sqrt(fabs(M_in1[lig][col]));
          }
        if (strcmp(Format, "Adb") == 0) {
          xx = sqrt(fabs(M_in1[lig][col]));
          if (xx <= eps) xx=eps;
          M_out[lig][col] = 20. * log10(xx);
          }
        if (strcmp(Format, "Idb") == 0) {
          xx = fabs(M_in1[lig][col]);
          if (xx <= eps) xx=eps;
          M_out[lig][col] = 10. * log10(xx);
          }
        } else {
        M_out[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock
}

/*******************************************************************/

if ((strcmp(PolTypeIn,"C2")==0)||(strcmp(PolTypeIn,"C3")==0)||(strcmp(PolTypeIn,"C4")==0)||(strcmp(PolTypeIn,"T3")==0)||(strcmp(PolTypeIn,"T4")==0)||(strcmp(PolTypeIn,"T6")==0)) {
  if ((element_index == 11) + (element_index == 22) + (element_index == 33) +  (element_index == 44) +  (element_index == 55) +  (element_index == 66)) is_complex = 0;
  else if ((element_index == 12) + (element_index == 13) + (element_index == 14) + (element_index == 15) + (element_index == 16)
         + (element_index == 23) + (element_index == 24) + (element_index == 25) + (element_index == 26) + (element_index == 34)
         + (element_index == 35) + (element_index == 36) + (element_index == 45) + (element_index == 46) + (element_index == 56)) is_complex = 1;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file1, M_in1, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  if (is_complex == 1) read_block_matrix_float(in_file2, M_in2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 0, 0, Off_lig, Off_col, Ncol);
  
#pragma omp parallel for private(col, xr, xi, xx)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (is_complex == 0) {
          xx = fabs(M_in1[lig][col]);
          if (strcmp(Format, "mod") == 0) {
            M_out[lig][col] = xx;
            }
          if (strcmp(Format, "db") == 0) {
            if (xx <= eps) xx=eps;
            M_out[lig][col] = 10. * log10(xx);
            }
          }
        if (is_complex == 1) {
          xr = M_in1[lig][col];
          xi = M_in2[lig][col];
          if (strcmp(Format, "mod") == 0) {
            M_out[lig][col] = sqrt(xr * xr + xi * xi);
            }
          if (strcmp(Format, "db") == 0) {
            xx = xr * xr + xi * xi;
            if (xx <= eps) xx=eps;
            M_out[lig][col] = 10. * log10(xx);
            }
          if (strcmp(Format, "pha") == 0) {
            if ((xr == 0.0) * (xi == 0.0)) xr += eps;
            M_out[lig][col] = atan2(xi, xr) * 180. / pi;
            }
          }
        } else {
        M_out[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock
}


/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix_float(M_in1, NligBlock[0]);
  if (is_complex == 1) free_matrix_float(M_in2, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  fclose(in_file1);
  if (is_complex == 1) fclose(in_file2);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


