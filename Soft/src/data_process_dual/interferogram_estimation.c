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

File   : interferogram_estimation.c
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

Description :  Interferogram determination

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

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  FILE *out_file;
  char file_name[FilePathLength], Im1[10], Im2[10];
  
/* Internal variables */
  int ii, lig, col;
  float w1r1, w1i1, w2r1, w2i1, w3r1, w3i1;
  float w1r2, w1i2, w2r2, w2i2, w3r2, w3i2;
  float ar, ai, br, bi, cr, ci, xre, xim;

/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ninterferogram_estimation.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp,"     (string)	-idm 	input master directory\n");
strcat(UsageHelp,"     (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp,"     (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-im1 	Image 1 : HH, HV, VV, HHpVV, HHmVV, HVpVH, LL, LR, RR\n");
strcat(UsageHelp," (string)	-im2 	Image 2 : HH, HV, VV, HHpVV, HHmVV, HVpVH, LL, LR, RR\n");
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

if(argc < 19) {
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
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-im1",str_cmd_prm,Im1,1,UsageHelp);
  get_commandline_prm(argc,argv,"-im2",str_cmd_prm,Im2,1,UsageHelp);

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
  if (FlagValid == 1) check_file(file_valid);
  check_dir(out_dir);

  NwinL = 1;
  NwinC = 1;
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
  sprintf(file_name, "%scmplx_coh_%s_%s.bin", out_dir, Im1, Im2);
  check_file(file_name);
  if ((out_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
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
  /* Mout = Nlig*2*Sub_Ncol */
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  
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
  M_out = matrix_float(NligBlock[0], 2*Sub_Ncol);

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

/* Polarisation Vector */
if (strcmp(Im1,"HH") == 0) {
  w1r1 = 1./sqrt(2.); w1i1 = 0.; w2r1 = 1./sqrt(2.); w2i1 = 0.; w3r1 = 0.; w3i1 = 0.;
  }
if (strcmp(Im1,"HV") == 0) {
  w1r1 = 0.; w1i1 = 0.; w2r1 = 0.; w2i1 = 0.; w3r1 = 0.; w3i1 = 1.;
  }
if (strcmp(Im1,"VV") == 0) {
  w1r1 = 1./sqrt(2.); w1i1 = 0.; w2r1 = -1./sqrt(2.); w2i1 = 0.; w3r1 = 0.; w3i1 = 0.;
  }
if (strcmp(Im1,"HHpVV") == 0) {
  w1r1 = 1.; w1i1 = 0.; w2r1 = 0.; w2i1 = 0.; w3r1 = 0.; w3i1 = 0.;
  }
if (strcmp(Im1,"HHmVV") == 0) {
  w1r1 = 0.; w1i1 = 0.; w2r1 = 1.; w2i1 = 0.; w3r1 = 0.; w3i1 = 0.;
  }
if (strcmp(Im1,"LL") == 0) {
  w1r1 = 0.; w1i1 = 0.; w2r1 = 1./sqrt(2.); w2i1 = 0.; w3r1 = 0.; w3i1 = -1./sqrt(2.);
  }
if (strcmp(Im1,"LR") == 0) {
  w1r1 = 1.; w1i1 = 0.; w2r1 = 0.; w2i1 = 0.; w3r1 = 0.; w3i1 = 0.;
  }
if (strcmp(Im1,"RR") == 0) {
  w1r1 = 0.; w1i1 = 0.; w2r1 = 1./sqrt(2.); w2i1 = 0.; w3r1 = 0.; w3i1 = +1./sqrt(2.);
  }

if (strcmp(Im2,"HH") == 0) {
  w1r2 = 1./sqrt(2.); w1i2 = 0.; w2r2 = 1./sqrt(2.); w2i2 = 0.; w3r2 = 0.; w3i2 = 0.;
  }
if (strcmp(Im2,"HV") == 0) {
  w1r2 = 0.; w1i2 = 0.; w2r2 = 0.; w2i2 = 0.; w3r2 = 0.; w3i2 = 1.;
  }
if (strcmp(Im2,"VV") == 0) {
  w1r2 = 1./sqrt(2.); w1i2 = 0.; w2r2 = -1./sqrt(2.); w2i2 = 0.; w3r2 = 0.; w3i2 = 0.;
  }
if (strcmp(Im2,"HHpVV") == 0) {
  w1r2 = 1.; w1i2 = 0.; w2r2 = 0.; w2i2 = 0.; w3r2 = 0.; w3i2 = 0.;
  }
if (strcmp(Im2,"HHmVV") == 0) {
  w1r2 = 0.; w1i2 = 0.; w2r2 = 1.; w2i2 = 0.; w3r2 = 0.; w3i2 = 0.;
  }
if (strcmp(Im2,"LL") == 0) {
  w1r2 = 0.; w1i2 = 0.; w2r2 = 1./sqrt(2.); w2i2 = 0.; w3r2 = 0.; w3i2 = -1./sqrt(2.);
  }
if (strcmp(Im2,"LR") == 0) {
  w1r2 = 1.; w1i2 = 0.; w2r2 = 0.; w2i2 = 0.; w3r2 = 0.; w3i2 = 0.;
  }
if (strcmp(Im2,"RR") == 0) {
  w1r2 = 0.; w1i2 = 0.; w2r2 = 1./sqrt(2.); w2i2 = 0.; w3r2 = 0.; w3i2 = +1./sqrt(2.);
  }

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

ar = ai = br = bi = cr = ci = xre = xim = 0.;
#pragma omp parallel for private(col) firstprivate(ar, ai, br, bi, cr, ci, xre, xim)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out[lig][2*col] = 0.; M_out[lig][2*col+1] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        ar = (w1r1*M_in[5][lig][col]+w1i1*M_in[6][lig][col]) + (w2r1*M_in[14][lig][col]+w2i1*M_in[15][lig][col]) + (w3r1*M_in[21][lig][col]+w3i1*M_in[21][lig][col]);
        ai = (w1r1*M_in[6][lig][col]-w1i1*M_in[5][lig][col]) + (w2r1*M_in[15][lig][col]-w2i1*M_in[14][lig][col]) + (w3r1*M_in[22][lig][col]-w3i1*M_in[22][lig][col]);
        br = (w1r1*M_in[7][lig][col]+w1i1*M_in[8][lig][col]) + (w2r1*M_in[16][lig][col]+w2i1*M_in[17][lig][col]) + (w3r1*M_in[23][lig][col]+w3i1*M_in[24][lig][col]);
        bi = (w1r1*M_in[8][lig][col]-w1i1*M_in[7][lig][col]) + (w2r1*M_in[17][lig][col]-w2i1*M_in[16][lig][col]) + (w3r1*M_in[24][lig][col]-w3i1*M_in[23][lig][col]);
        cr = (w1r1*M_in[9][lig][col]+w1i1*M_in[10][lig][col]) + (w2r1*M_in[18][lig][col]+w2i1*M_in[19][lig][col]) + (w3r1*M_in[25][lig][col]+w3i1*M_in[26][lig][col]);
        ci = (w1r1*M_in[10][lig][col]-w1i1*M_in[9][lig][col]) + (w2r1*M_in[19][lig][col]-w2i1*M_in[18][lig][col]) + (w3r1*M_in[26][lig][col]-w3i1*M_in[25][lig][col]);

        xre = (ar * w1r2 - ai * w1i2) + (br * w2r2 - bi * w2i2) + (cr * w3r2 - ci * w3i2);
        xim = (ar * w1i2 + ai * w1r2) + (br * w2i2 + bi * w2r2) + (cr * w3i2 + ci * w3r2);

        M_out[lig][2*col]  = cos(atan2(xim,xre));
        M_out[lig][2*col+1] = sin(atan2(xim,xre));
        }
      }
    }

  write_block_matrix_float(out_file, M_out, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);

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
  free_matrix_float(M_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if (strcmp(PolTypeIn,"S2")==0)
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}




