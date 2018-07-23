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

File  : krogager_decomposition.c
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

Description :  Krogager Decomposition

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

#define NPolType 3
/* LOCAL VARIABLES */
  FILE *out_odd, *out_dbl, *out_vol, *out_teta;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  float Tau;

/* Matrix arrays */
  float ***M_avg;
  float **M_KS;
  float **M_KD;
  float **M_KH;
  float **M_KTeta;

  cplx **Utau;
  cplx **UtauM1;
  cplx **Mtmp1, **Mtmp2;
  cplx **MtmpIn;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nkrogager_decomposition.exe\n");
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
  sprintf(file_name, "%s%s", out_dir, "Krogager_Ks.bin");
  if ((out_odd = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Krogager_Kd.bin");
  if ((out_dbl = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "Krogager_Kh.bin");
  if ((out_vol = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "Krogager_Teta.bin");
  if ((out_teta = fopen(file_name, "wb")) == NULL)
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
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Mks = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mkd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mkh = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mteta = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
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
  M_KS = matrix_float(NligBlock[0], Sub_Ncol);
  M_KD = matrix_float(NligBlock[0], Sub_Ncol);
  M_KH = matrix_float(NligBlock[0], Sub_Ncol);
  M_KTeta = matrix_float(NligBlock[0], Sub_Ncol);

  Utau = cplx_matrix(3,3); UtauM1 = cplx_matrix(3,3);
  Mtmp1 = cplx_matrix(3,3); Mtmp2 = cplx_matrix(3,3);
  MtmpIn = cplx_matrix(3,3);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* Transformation Basis (H,V) -> (R,L) definition */

  Tau = -45.0;
  Tau = Tau * 4. * atan(1.) / 180.;

  Utau[0][0].re = cos(2.*Tau); Utau[0][0].im = 0.;
  Utau[0][1].re = 0.; Utau[0][1].im = 0.;
  Utau[0][2].re = 0.; Utau[0][2].im = sin(2.*Tau);
  Utau[1][0].re = 0.; Utau[1][0].im = 0.;
  Utau[1][1].re = 1.; Utau[1][1].im = 0.;
  Utau[1][2].re = 0.; Utau[1][2].im = 0.;
  Utau[2][0].re = 0.; Utau[2][0].im = sin(2.*Tau);
  Utau[2][1].re = 0.; Utau[2][1].im = 0.;
  Utau[2][2].re = cos(2.*Tau); Utau[2][2].im = 0.;

  UtauM1[0][0].re = cos(2.*Tau); UtauM1[0][0].im = 0.;
  UtauM1[0][1].re = 0.; UtauM1[0][1].im = 0.;
  UtauM1[0][2].re = 0.; UtauM1[0][2].im = -sin(2.*Tau);
  UtauM1[1][0].re = 0.; UtauM1[1][0].im = 0.;
  UtauM1[1][1].re = 1.; UtauM1[1][1].im = 0.;
  UtauM1[1][2].re = 0.; UtauM1[1][2].im = 0.;
  UtauM1[2][0].re = 0.; UtauM1[2][0].im = -sin(2.*Tau);
  UtauM1[2][1].re = 0.; UtauM1[2][1].im = 0.;
  UtauM1[2][2].re = cos(2.*Tau); UtauM1[2][2].im = 0.;

/********************************************************************
********************************************************************/

/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

/* Transformation Basis (H,V) -> (R,L) */
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {  
        MtmpIn[0][0].re = M_avg[T311][lig][col]; MtmpIn[0][0].im = 0.;
        MtmpIn[0][1].re = M_avg[T312_re][lig][col]; MtmpIn[0][1].im = M_avg[T312_im][lig][col];
        MtmpIn[0][2].re = M_avg[T313_re][lig][col]; MtmpIn[0][2].im = M_avg[T313_im][lig][col];
        MtmpIn[1][0].re = MtmpIn[0][1].re; MtmpIn[1][0].im = -MtmpIn[0][1].im;
        MtmpIn[1][1].re = M_avg[T322][lig][col]; MtmpIn[1][1].im = 0.;
        MtmpIn[1][2].re = M_avg[T323_re][lig][col]; MtmpIn[1][2].im = M_avg[T323_im][lig][col];
        MtmpIn[2][0].re = MtmpIn[0][2].re; MtmpIn[2][0].im = -MtmpIn[0][2].im;
        MtmpIn[2][1].re = MtmpIn[1][2].re; MtmpIn[2][1].im = -MtmpIn[1][2].im;
        MtmpIn[2][2].re = M_avg[T333][lig][col]; MtmpIn[2][2].im = 0.;

        cplx_mul_mat(Utau,MtmpIn,Mtmp1,3,3);
        cplx_mul_mat(Mtmp1,UtauM1,Mtmp2,3,3);

        M_avg[T311][lig][col] = Mtmp2[0][0].re; 
        M_avg[T312_re][lig][col] = Mtmp2[0][1].re; M_avg[T312_im][lig][col] = Mtmp2[0][1].im;
        M_avg[T313_re][lig][col] = Mtmp2[0][2].re; M_avg[T313_im][lig][col] = Mtmp2[0][2].im;
        M_avg[T322][lig][col] = Mtmp2[1][1].re; 
        M_avg[T323_re][lig][col] = Mtmp2[1][2].re; M_avg[T323_im][lig][col] = Mtmp2[1][2].im;
        M_avg[T333][lig][col] = Mtmp2[2][2].re;
        }  /* valid */
      } /* col */
    } /* lig */

  T3_to_C3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

/* Krogager decomposition */
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        M_KTeta[lig][col] = 0.25*(atan2(M_avg[C313_im][lig][col],M_avg[C313_re][lig][col])+pi);
        M_KTeta[lig][col] = (M_KTeta[lig][col] * 180.) / pi;
        M_KS[lig][col] = sqrt(M_avg[C322][lig][col]/2.);
        if (sqrt(M_avg[C311][lig][col]) > sqrt(M_avg[C333][lig][col])) {
          M_KD[lig][col] = sqrt(M_avg[C333][lig][col]);
          M_KH[lig][col] = sqrt(M_avg[C311][lig][col])-sqrt(M_avg[C333][lig][col]);
          } else {
          M_KD[lig][col] = sqrt(M_avg[C311][lig][col]);
          M_KH[lig][col] = sqrt(M_avg[C333][lig][col])-sqrt(M_avg[C311][lig][col]);
          }
        } else {
        M_KTeta[lig][col] = 0.;
        M_KS[lig][col] = 0.;
        M_KD[lig][col] = 0.;
        M_KH[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(out_odd, M_KS, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_dbl, M_KD, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_vol, M_KH, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_teta, M_KTeta, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_KS, NligBlock[0]);
  free_matrix_float(M_KD, NligBlock[0]);
  free_matrix_float(M_KH, NligBlock[0]);
  free_matrix_float(M_KTeta, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_odd);
  fclose(out_dbl);
  fclose(out_vol);
  fclose(out_teta);
  
/********************************************************************
********************************************************************/

  return 1;
}


