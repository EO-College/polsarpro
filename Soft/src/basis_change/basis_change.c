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

File   : basis_change.c
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

Description :  Polarimetric Basis Change

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

#define NPolType 3
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  
/* Internal variables */
  int ii, lig, col;
  float Phi, Tau;

/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  cplx **Uphi, **Utau;
  cplx **UphiM1, **UtauM1;
  cplx **Mtmp1, **Mtmp2;
  cplx **MtmpIn;
  cplx **U, **Um1;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nbasis_change.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (float) 	-phi 	phi (orientation angle) - deg\n");
strcat(UsageHelp," (float) 	-tau 	tau (ellipticity angle) - deg\n");
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

if(argc < 19) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-phi",flt_cmd_prm,&Phi,1,UsageHelp);
  get_commandline_prm(argc,argv,"-tau",flt_cmd_prm,&Tau,1,UsageHelp);
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

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
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

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
  
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
  /* Mout = NpolarOut*Nlig*2*Sub_Ncol */
  NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  } else {
  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Min = NpolarOut*Nlig*Ncol */
  NBlockA += NpolarIn*Ncol; NBlockB += 0;
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

if (strcmp(PolTypeIn,"S2")==0) {
  M_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
  Uphi = cplx_matrix(2,2); UphiM1 = cplx_matrix(2,2);
  Utau = cplx_matrix(2,2); UtauM1 = cplx_matrix(2,2);
  U = cplx_matrix(2,2); Um1 = cplx_matrix(2,2);
  } else {
  M_in = matrix3d_float(NpolarIn, NligBlock[0], Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  Uphi = cplx_matrix(3,3); UphiM1 = cplx_matrix(3,3);
  Utau = cplx_matrix(3,3); UtauM1 = cplx_matrix(3,3);
  U = cplx_matrix(3,3); Um1 = cplx_matrix(3,3);
  }

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

Phi = Phi * 4. * atan(1.) / 180.;
Tau = Tau * 4. * atan(1.) / 180.;
if (strcmp(PolTypeIn,"S2")==0) {
  Uphi[0][0].re = cos(Phi); Uphi[0][0].im = 0.;
  Uphi[0][1].re = -sin(Phi); Uphi[0][1].im = 0.;
  Uphi[1][0].re = sin(Phi); Uphi[1][0].im = 0.;
  Uphi[1][1].re = cos(Phi); Uphi[1][1].im = 0.;

  Utau[0][0].re = cos(Tau); Utau[0][0].im = 0.;
  Utau[0][1].re = 0.; Utau[0][1].im = sin(Tau);
  Utau[1][0].re = 0.; Utau[1][0].im = sin(Tau);
  Utau[1][1].re = cos(Tau); Utau[1][1].im = 0.;

  UphiM1[0][0].re = cos(Phi); UphiM1[0][0].im = 0.;
  UphiM1[0][1].re = sin(Phi); UphiM1[0][1].im = 0.;
  UphiM1[1][0].re = -sin(Phi); UphiM1[1][0].im = 0.;
  UphiM1[1][1].re = cos(Phi); UphiM1[1][1].im = 0.;

  UtauM1[0][0].re = cos(Tau); UtauM1[0][0].im = 0.;
  UtauM1[0][1].re = 0.; UtauM1[0][1].im = sin(Tau);
  UtauM1[1][0].re = 0.; UtauM1[1][0].im = sin(Tau);
  UtauM1[1][1].re = cos(Tau); UtauM1[1][1].im = 0.;
  
  cplx_mul_mat(Uphi,Utau,U,2,2);
  cplx_mul_mat(UtauM1,UphiM1,Um1,2,2);
  } else {
  Uphi[0][0].re = 1.; Uphi[0][0].im = 0.;
  Uphi[0][1].re = 0.; Uphi[0][1].im = 0.;
  Uphi[0][2].re = 0.; Uphi[0][2].im = 0.;
  Uphi[1][0].re = 0.; Uphi[1][0].im = 0.;
  Uphi[1][1].re = cos(2.*Phi); Uphi[1][1].im = 0.;
  Uphi[1][2].re = sin(2.*Phi); Uphi[1][2].im = 0.;
  Uphi[2][0].re = 0.; Uphi[2][0].im = 0.;
  Uphi[2][1].re = -sin(2.*Phi); Uphi[2][1].im = 0.;
  Uphi[2][2].re = cos(2.*Phi); Uphi[2][2].im = 0.;

  Utau[0][0].re = cos(2.*Tau); Utau[0][0].im = 0.;
  Utau[0][1].re = 0.; Utau[0][1].im = 0.;
  Utau[0][2].re = 0.; Utau[0][2].im = sin(2.*Tau);
  Utau[1][0].re = 0.; Utau[1][0].im = 0.;
  Utau[1][1].re = 1.; Utau[1][1].im = 0.;
  Utau[1][2].re = 0.; Utau[1][2].im = 0.;
  Utau[2][0].re = 0.; Utau[2][0].im = sin(2.*Tau);
  Utau[2][1].re = 0.; Utau[2][1].im = 0.;
  Utau[2][2].re = cos(2.*Tau); Utau[2][2].im = 0.;

  UphiM1[0][0].re = 1.; UphiM1[0][0].im = 0.;
  UphiM1[0][1].re = 0.; UphiM1[0][1].im = 0.;
  UphiM1[0][2].re = 0.; UphiM1[0][2].im = 0.;
  UphiM1[1][0].re = 0.; UphiM1[1][0].im = 0.;
  UphiM1[1][1].re = cos(2.*Phi); UphiM1[1][1].im = 0.;
  UphiM1[1][2].re = -sin(2.*Phi); UphiM1[1][2].im = 0.;
  UphiM1[2][0].re = 0.; UphiM1[2][0].im = 0.;
  UphiM1[2][1].re = sin(2.*Phi); UphiM1[2][1].im = 0.;
  UphiM1[2][2].re = cos(2.*Phi); UphiM1[2][2].im = 0.;

  UtauM1[0][0].re = cos(2.*Tau); UtauM1[0][0].im = 0.;
  UtauM1[0][1].re = 0.; UtauM1[0][1].im = 0.;
  UtauM1[0][2].re = 0.; UtauM1[0][2].im = -sin(2.*Tau);
  UtauM1[1][0].re = 0.; UtauM1[1][0].im = 0.;
  UtauM1[1][1].re = 1.; UtauM1[1][1].im = 0.;
  UtauM1[1][2].re = 0.; UtauM1[1][2].im = 0.;
  UtauM1[2][0].re = 0.; UtauM1[2][0].im = -sin(2.*Tau);
  UtauM1[2][1].re = 0.; UtauM1[2][1].im = 0.;
  UtauM1[2][2].re = cos(2.*Tau); UtauM1[2][2].im = 0.;

  cplx_mul_mat(Utau,Uphi,U,3,3);
  cplx_mul_mat(UphiM1,UtauM1,Um1,3,3);
  }

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col, Np, Mtmp1, Mtmp2, MtmpIn)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
      Mtmp1 = cplx_matrix(2,2);
	  Mtmp2 = cplx_matrix(2,2);
	  MtmpIn = cplx_matrix(2,2);
      for (col = 0; col < Sub_Ncol; col++) {
        for (Np = 0; Np < NpolarOut; Np++) { 
          M_out[Np][lig][2*col] = 0.;
          M_out[Np][lig][2*col+1] = 0.;
          }
        if (Valid[lig][col] == 1.) {  
          MtmpIn[0][0].re = M_in[s11][lig][2*col]; MtmpIn[0][0].im = M_in[s11][lig][2*col+1];
          MtmpIn[0][1].re = M_in[s12][lig][2*col]; MtmpIn[0][1].im = M_in[s12][lig][2*col+1];
          MtmpIn[1][0].re = M_in[s21][lig][2*col]; MtmpIn[1][0].im = M_in[s21][lig][2*col+1];
          MtmpIn[1][1].re = M_in[s22][lig][2*col]; MtmpIn[1][1].im = M_in[s22][lig][2*col+1];

          cplx_mul_mat(Um1,MtmpIn,Mtmp1,2,2);
          cplx_mul_mat(Mtmp1,U,Mtmp2,2,2);

          M_out[s11][lig][2*col] = Mtmp2[0][0].re; M_out[s11][lig][2*col+1] = Mtmp2[0][0].im;
          M_out[s12][lig][2*col] = Mtmp2[0][1].re; M_out[s12][lig][2*col+1] = Mtmp2[0][1].im;
          M_out[s21][lig][2*col] = Mtmp2[1][0].re; M_out[s21][lig][2*col+1] = Mtmp2[1][0].im;
          M_out[s22][lig][2*col] = Mtmp2[1][1].re; M_out[s22][lig][2*col+1] = Mtmp2[1][1].im;
          } /* valid */
        } /*col*/
      cplx_free_matrix(Mtmp1,2);
	  cplx_free_matrix(Mtmp2,2);
	  cplx_free_matrix(MtmpIn,2);
      } /*lig*/

    write_block_matrix3d_cmplx(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    
    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if ((strcmp(PolTypeOut,"C3")==0)) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);

#pragma omp parallel for private(col, Np, Mtmp1, Mtmp2, MtmpIn)
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
      Mtmp1 = cplx_matrix(3,3);
	  Mtmp2 = cplx_matrix(3,3);
	  MtmpIn = cplx_matrix(3,3);
      for (col = 0; col < Sub_Ncol; col++) {
        for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
        if (Valid[lig][col] == 1.) {  
          MtmpIn[0][0].re = M_in[T311][lig][col]; MtmpIn[0][0].im = 0.;
          MtmpIn[0][1].re = M_in[T312_re][lig][col]; MtmpIn[0][1].im = M_in[T312_im][lig][col];
          MtmpIn[0][2].re = M_in[T313_re][lig][col]; MtmpIn[0][2].im = M_in[T313_im][lig][col];
          MtmpIn[1][0].re = MtmpIn[0][1].re; MtmpIn[1][0].im = -MtmpIn[0][1].im;
          MtmpIn[1][1].re = M_in[T322][lig][col]; MtmpIn[1][1].im = 0.;
          MtmpIn[1][2].re = M_in[T323_re][lig][col]; MtmpIn[1][2].im = M_in[T323_im][lig][col];
          MtmpIn[2][0].re = MtmpIn[0][2].re; MtmpIn[2][0].im = -MtmpIn[0][2].im;
          MtmpIn[2][1].re = MtmpIn[1][2].re; MtmpIn[2][1].im = -MtmpIn[1][2].im;
          MtmpIn[2][2].re = M_in[T333][lig][col]; MtmpIn[2][2].im = 0.;

          cplx_mul_mat(U,MtmpIn,Mtmp1,3,3);
          cplx_mul_mat(Mtmp1,Um1,Mtmp2,3,3);

          M_out[T311][lig][col] = Mtmp2[0][0].re; 
          M_out[T312_re][lig][col] = Mtmp2[0][1].re; M_out[T312_im][lig][col] = Mtmp2[0][1].im;
          M_out[T313_re][lig][col] = Mtmp2[0][2].re; M_out[T313_im][lig][col] = Mtmp2[0][2].im;
          M_out[T322][lig][col] = Mtmp2[1][1].re; 
          M_out[T323_re][lig][col] = Mtmp2[1][2].re; M_out[T323_im][lig][col] = Mtmp2[1][2].im;
          M_out[T333][lig][col] = Mtmp2[2][2].re;
          }  /* valid */
        } /* col */
      cplx_free_matrix(Mtmp1,3);
	  cplx_free_matrix(Mtmp2,3);
	  cplx_free_matrix(MtmpIn,3);
      } /* lig */

    if ((strcmp(PolTypeOut,"C3")==0)) T3_to_C3(M_out, NligBlock[Nb], Sub_Ncol, 0, 0);

    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    }

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarIn, NligBlock[0]);
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


