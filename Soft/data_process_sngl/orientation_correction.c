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

File   : orientation_correction.c
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

Description :  Polarimetric Orientation Angle Correction

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
  FILE *in_phi;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col;
  float Phi;

/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  float **M_phi;
  cplx **Uphi;
  cplx **UphiM1;
  cplx **Mtmp1, **Mtmp2;
  cplx **MtmpIn;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\norientation_correction.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-if  	orientation angle data file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
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
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
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

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  check_file(file_name);
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

  if ((in_phi = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);

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
  /* Mphi = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
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

if (strcmp(PolTypeIn,"S2")==0) {
  M_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
  Uphi = cplx_matrix(2,2); UphiM1 = cplx_matrix(2,2);
  Mtmp1 = cplx_matrix(2,2); Mtmp2 = cplx_matrix(2,2);
  MtmpIn = cplx_matrix(2,2);
  } else {
  M_in = matrix3d_float(NpolarIn, NligBlock[0], Ncol);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  Uphi = cplx_matrix(3,3); UphiM1 = cplx_matrix(3,3);
  Mtmp1 = cplx_matrix(3,3); Mtmp2 = cplx_matrix(3,3);
  MtmpIn = cplx_matrix(3,3);
  }

  M_phi = matrix_float(NligBlock[0], Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0] + NwinL; lig++) 
      for (col = 0; col < Sub_Ncol + NwinC; col++) 
        Valid[lig][col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_phi, M_phi, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, "S2", NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        for (Np = 0; Np < NpolarOut; Np++) { 
          M_out[Np][lig][2*col] = 0.;
          M_out[Np][lig][2*col+1] = 0.;
          }
        if (Valid[lig][col] == 1.) {  
          Phi = M_phi[lig][col] * pi / 180.;

          Uphi[0][0].re = cos(Phi); Uphi[0][0].im = 0.;
          Uphi[0][1].re = -sin(Phi); Uphi[0][1].im = 0.;
          Uphi[1][0].re = sin(Phi); Uphi[1][0].im = 0.;
          Uphi[1][1].re = cos(Phi); Uphi[1][1].im = 0.;

          UphiM1[0][0].re = cos(Phi); UphiM1[0][0].im = 0.;
          UphiM1[0][1].re = sin(Phi); UphiM1[0][1].im = 0.;
          UphiM1[1][0].re = -sin(Phi); UphiM1[1][0].im = 0.;
          UphiM1[1][1].re = cos(Phi); UphiM1[1][1].im = 0.;

          MtmpIn[0][0].re = M_in[s11][lig][2*col]; MtmpIn[0][0].im = M_in[s11][lig][2*col+1];
          MtmpIn[0][1].re = M_in[s12][lig][2*col]; MtmpIn[0][1].im = M_in[s12][lig][2*col+1];
          MtmpIn[1][0].re = M_in[s21][lig][2*col]; MtmpIn[1][0].im = M_in[s21][lig][2*col+1];
          MtmpIn[1][1].re = M_in[s22][lig][2*col]; MtmpIn[1][1].im = M_in[s22][lig][2*col+1];

          cplx_mul_mat(UphiM1,MtmpIn,Mtmp1,2,2);
          cplx_mul_mat(Mtmp1,Uphi,Mtmp2,2,2);

          M_out[s11][lig][2*col] = Mtmp2[0][0].re; M_out[s11][lig][2*col+1] = Mtmp2[0][0].im;
          M_out[s12][lig][2*col] = Mtmp2[0][1].re; M_out[s12][lig][2*col+1] = Mtmp2[0][1].im;
          M_out[s21][lig][2*col] = Mtmp2[1][0].re; M_out[s21][lig][2*col+1] = Mtmp2[1][0].im;
          M_out[s22][lig][2*col] = Mtmp2[1][1].re; M_out[s22][lig][2*col+1] = Mtmp2[1][1].im;
          } /* valid */
        } /*col*/
      } /*lig*/

    write_block_matrix3d_cmplx(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if ((strcmp(PolTypeOut,"C3")==0)) C3_to_T3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);

    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = 0.;
        if (Valid[lig][col] == 1.) {  
          Phi = M_phi[lig][col] * pi / 180.;
           
          Uphi[0][0].re = 1.; Uphi[0][0].im = 0.;
          Uphi[0][1].re = 0.; Uphi[0][1].im = 0.;
          Uphi[0][2].re = 0.; Uphi[0][2].im = 0.;
          Uphi[1][0].re = 0.; Uphi[1][0].im = 0.;
          Uphi[1][1].re = cos(2.*Phi); Uphi[1][1].im = 0.;
          Uphi[1][2].re = sin(2.*Phi); Uphi[1][2].im = 0.;
          Uphi[2][0].re = 0.; Uphi[2][0].im = 0.;
          Uphi[2][1].re = -sin(2.*Phi); Uphi[2][1].im = 0.;
          Uphi[2][2].re = cos(2.*Phi); Uphi[2][2].im = 0.;

          UphiM1[0][0].re = 1.; UphiM1[0][0].im = 0.;
          UphiM1[0][1].re = 0.; UphiM1[0][1].im = 0.;
          UphiM1[0][2].re = 0.; UphiM1[0][2].im = 0.;
          UphiM1[1][0].re = 0.; UphiM1[1][0].im = 0.;
          UphiM1[1][1].re = cos(2.*Phi); UphiM1[1][1].im = 0.;
          UphiM1[1][2].re = -sin(2.*Phi); UphiM1[1][2].im = 0.;
          UphiM1[2][0].re = 0.; UphiM1[2][0].im = 0.;
          UphiM1[2][1].re = sin(2.*Phi); UphiM1[2][1].im = 0.;
          UphiM1[2][2].re = cos(2.*Phi); UphiM1[2][2].im = 0.;

          MtmpIn[0][0].re = M_in[T311][lig][col]; MtmpIn[0][0].im = 0.;
          MtmpIn[0][1].re = M_in[T312_re][lig][col]; MtmpIn[0][1].im = M_in[T312_im][lig][col];
          MtmpIn[0][2].re = M_in[T313_re][lig][col]; MtmpIn[0][2].im = M_in[T313_im][lig][col];
          MtmpIn[1][0].re = MtmpIn[0][1].re; MtmpIn[1][0].im = -MtmpIn[0][1].im;
          MtmpIn[1][1].re = M_in[T322][lig][col]; MtmpIn[1][1].im = 0.;
          MtmpIn[1][2].re = M_in[T323_re][lig][col]; MtmpIn[1][2].im = M_in[T323_im][lig][col];
          MtmpIn[2][0].re = MtmpIn[0][2].re; MtmpIn[2][0].im = -MtmpIn[0][2].im;
          MtmpIn[2][1].re = MtmpIn[1][2].re; MtmpIn[2][1].im = -MtmpIn[1][2].im;
          MtmpIn[2][2].re = M_in[T333][lig][col]; MtmpIn[2][2].im = 0.;

          cplx_mul_mat(Uphi,MtmpIn,Mtmp1,3,3);
          cplx_mul_mat(Mtmp1,UphiM1,Mtmp2,3,3);

          M_out[T311][lig][col] = Mtmp2[0][0].re; 
          M_out[T312_re][lig][col] = Mtmp2[0][1].re; M_out[T312_im][lig][col] = Mtmp2[0][1].im;
          M_out[T313_re][lig][col] = Mtmp2[0][2].re; M_out[T313_im][lig][col] = Mtmp2[0][2].im;
          M_out[T322][lig][col] = Mtmp2[1][1].re; 
          M_out[T323_re][lig][col] = Mtmp2[1][2].re; M_out[T323_im][lig][col] = Mtmp2[1][2].im;
          M_out[T333][lig][col] = Mtmp2[2][2].re;
          }  /* valid */
        } /* col */
      } /* lig */

    if ((strcmp(PolTypeOut,"C3")==0)) T3_to_C3(M_out, NligBlock[Nb], Sub_Ncol, 0, 0);

    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
    }

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_in, NpolarIn, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
  free_matrix_float(M_phi, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  fclose(in_phi);

/********************************************************************
********************************************************************/

  return 1;
}


