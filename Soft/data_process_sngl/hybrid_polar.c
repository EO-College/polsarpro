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

File  : hybrid_polar.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Marco LAVALLE (ESA-ESRIN/U.Tor Vergata, Roma)
Version  : 2.0
Creation : 08/2010
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

Description :  From an Hybrid Polarisation Combination, estimates
               the Full Pol Covariance matrix 3x3

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
/* J matrix */
#define J11  0
#define J12re  1
#define J12im  2
#define J22  3

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
  FILE *out_file3[9];
  int Config;
  char *PolTypeConf[NPolType] = {"C3", "T3"};

  char out_dir2[FilePathLength], out_dir3[FilePathLength];
  char **file_name_out3;
  char mode[10], method[10];
  
/* Internal variables */
  int ii, lig, col;
  int FlagStop, Niteration;

  float c11,c12r,c12i,c13r,c13i,c22,c23r,c23i,c33;
  float rho_r, rho_i, rho_mod, X, Xnew;

/* Matrix arrays */
  float ***M_out2;
  float ***M_out3;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nhybrid_polar.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-iod 	input directory\n");
strcat(UsageHelp," (string)	-odf 	output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-mod 	Hybrid Polar mode (pi4 / lhv / rhv)\n");
strcat(UsageHelp," (string)	-recm	Reconstruction mode (polar / rotsym / rotrefsym)\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iod",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mod",str_cmd_prm,&mode,1,UsageHelp);
  get_commandline_prm(argc,argv,"-recm",str_cmd_prm,&method,1,UsageHelp);

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

  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  sprintf(out_dir2, "%s%s", out_dir, "C2");
  check_dir(out_dir2);

  if (strcmp(PolType,"C3") == 0) sprintf(out_dir3, "%s%s", out_dir, "C3");
  if (strcmp(PolType,"T3") == 0) sprintf(out_dir3, "%s%s", out_dir, "T3");
  check_dir(out_dir3);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(out_dir2, &Nlig, &Ncol, PolarCase, PolarType);

  strcpy(PolarCase, "monostatic"); strcpy(PolarType, "full");
  write_config(out_dir3, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  NpolarIn = 4; strcpy(PolTypeIn, "C2");
  NpolarOut = 9; strcpy(PolTypeOut, PolType);
  
  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_out3 = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, out_dir2, file_name_in);
  init_file_name(PolTypeOut, out_dir3, file_name_out3);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_file3[Np] = fopen(file_name_out3[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);
  
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

  /* Mout2 = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarIn*Sub_Ncol; NBlockB += 0;
  /* Mout3 = 9*Nlig*Sub_Ncol */
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
  M_out2 = matrix3d_float(NpolarIn, NligBlock[0], Sub_Ncol);
  M_out3 = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  
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

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_out2, NpolarIn, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {

        /* RECONSTRUCT PSEUDO QUAD-POL DATA */
        if (strcmp(method,"polar") == 0) {
          rho_r = M_out2[J12re][lig][col] / sqrt(M_out2[J11][lig][col] * M_out2[J22][lig][col]);
          rho_i = M_out2[J12im][lig][col] / sqrt(M_out2[J11][lig][col] * M_out2[J22][lig][col]);
          rho_mod = sqrt(rho_r * rho_r + rho_i * rho_i);
          X = 0.5*(M_out2[J11][lig][col] + M_out2[J22][lig][col]) * (1. - rho_mod) / (3. - rho_mod);
          FlagStop = 0; Niteration = 0;
          while (FlagStop == 0) {
            if (strcmp(mode,"pi4") == 0) { 
              rho_r = (M_out2[J12re][lig][col] - X ) / sqrt((M_out2[J11][lig][col]-X) * (M_out2[J22][lig][col]-X));
              rho_i = M_out2[J12im][lig][col] / sqrt((M_out2[J11][lig][col]-X) * (M_out2[J22][lig][col]-X));
              }
            if (strcmp(mode,"lhv") == 0) { 
              rho_r = (-M_out2[J12im][lig][col] - X ) / sqrt((M_out2[J11][lig][col]-X) * (M_out2[J22][lig][col]-X));
              rho_i = M_out2[J12re][lig][col] / sqrt((M_out2[J11][lig][col]-X) * (M_out2[J22][lig][col]-X));
              }
            if (strcmp(mode,"rhv") == 0) { 
              rho_r = (M_out2[J12im][lig][col] - X ) / sqrt((M_out2[J11][lig][col]-X) * (M_out2[J22][lig][col]-X));
              rho_i = -M_out2[J12re][lig][col] / sqrt((M_out2[J11][lig][col]-X) * (M_out2[J22][lig][col]-X));
              }
            rho_mod = sqrt(rho_r * rho_r + rho_i * rho_i);
            Xnew = 0.5*(M_out2[J11][lig][col] + M_out2[J22][lig][col]) * (1. - rho_mod) / (3. - rho_mod);
            if (Xnew < 0.) FlagStop = 1;
            if ((M_out2[J11][lig][col] - Xnew) <0.) FlagStop = 1;
            if ((M_out2[J22][lig][col] - Xnew) <0.) FlagStop = 1;
            if (fabs(Xnew-X) < 1.E-3) {
              FlagStop = 1; X = Xnew;
              }
            if (FlagStop == 0) {
              X = Xnew;
              Niteration++;
              if (Niteration == 10) FlagStop = 1;
              }
            }

          if (FlagStop == 2) {
            rho_mod = 1.; X = 0.;
            }
          if (strcmp(mode,"pi4") == 0) { 
            c11 = M_out2[J11][lig][col] - X; c22 = 2.*X; c33 = M_out2[J22][lig][col]-X;
            c13r = M_out2[J12re][lig][col] - X; c13i = M_out2[J12im][lig][col];
            c12r = c12i = c23r = c23i = 0.;
            }
          if (strcmp(mode,"lhv") == 0) { 
            c11 = M_out2[J11][lig][col] - X; c22 = 2.*X; c33 = M_out2[J22][lig][col]-X;
            c13r = -M_out2[J12im][lig][col] + X; c13i = M_out2[J12re][lig][col];
            c12r = c12i = c23r = c23i = 0.;
            }
          if (strcmp(mode,"rhv") == 0) { 
            c11 = M_out2[J11][lig][col] - X; c22 = 2.*X; c33 = M_out2[J22][lig][col]-X;
            c13r = M_out2[J12im][lig][col] + X; c13i = -M_out2[J12re][lig][col];
            c12r = c12i = c23r = c23i = 0.;
            }
          }

        if (strcmp(method,"rotsym") == 0) {
          if (strcmp(mode,"pi4") == 0) { 
            c11 = 0.25*(M_out2[J11][lig][col] + M_out2[J22][lig][col] + 2.*M_out2[J12re][lig][col]);
            c22 = 0.5*(M_out2[J11][lig][col] + M_out2[J22][lig][col] - 2.*M_out2[J12re][lig][col]);
            c33 = 0.25*(M_out2[J11][lig][col] + M_out2[J22][lig][col] + 2.*M_out2[J12re][lig][col]);
            c12r = 0.;
            c12i = 0.5*sqrt(2.)*M_out2[J12im][lig][col];
            c13r = 0.25*(-M_out2[J11][lig][col] - M_out2[J22][lig][col] + 6.*M_out2[J12re][lig][col]);
            c13i = 0.;
            c23r = c12r;
            c23i = c12i;
            }
          if (strcmp(mode,"lhv") == 0) { 
            c11 = 0.;
            c22 = 0.;
            c33 = 0.;
            c12r = 0.;
            c12i = 0.;
            c13r = 0.;
            c13i = 0.;
            c23r = c12r;
            c23i = c12i;
            }
          if (strcmp(mode,"rhv") == 0) { 
            c11 = 0.;
            c22 = 0.;
            c33 = 0.;
            c12r = 0.;
            c12i = 0.;
            c13r = 0.;
            c13i = 0.;
            c23r = c12r;
            c23i = c12i;
            }
          }

        if (strcmp(method,"rotrefsym") == 0) {
          if (strcmp(mode,"pi4") == 0) { 
            c11 = 0.125*(7.*M_out2[J11][lig][col] - M_out2[J22][lig][col] + 2.*M_out2[J12re][lig][col]);
            c22 = 0.25*(M_out2[J11][lig][col] + M_out2[J22][lig][col] - 2.*M_out2[J12re][lig][col]);
            c33 = 0.125*(-M_out2[J11][lig][col] + 7.*M_out2[J22][lig][col] + 2.*M_out2[J12re][lig][col]);
            c12r = 0.;
            c12i = 0.;
            c13r = 0.125*(-M_out2[J11][lig][col] - M_out2[J22][lig][col] + 6.*M_out2[J12re][lig][col]);
            c13i = 0.125*M_out2[J12im][lig][col];
            c23r = c12r;
            c23i = c12i;
            }
          if (strcmp(mode,"lhv") == 0) { 
            c11 = 0.125*(7.*M_out2[J11][lig][col] - M_out2[J22][lig][col] + 2.*M_out2[J12im][lig][col]);
            c22 = 0.125*(M_out2[J11][lig][col] + M_out2[J22][lig][col] + 2.*M_out2[J12im][lig][col]);
            c33 = 0.125*(-M_out2[J11][lig][col] + 7.*M_out2[J22][lig][col] - 2.*M_out2[J12im][lig][col]);
            c12r = 0.;
            c12i = 0.;
            c13r = 0.125*(M_out2[J11][lig][col] + M_out2[J22][lig][col] - 6.*M_out2[J12im][lig][col]);
            c13i = 0.5*M_out2[J12re][lig][col];
            c23r = c12r;
            c23i = c12i;
            }
          if (strcmp(mode,"rhv") == 0) { 
            c11 = 0.125*(7.*M_out2[J11][lig][col] - M_out2[J22][lig][col] - 2.*M_out2[J12im][lig][col]);
            c22 = 0.125*(M_out2[J11][lig][col] + M_out2[J22][lig][col] - 2.*M_out2[J12im][lig][col]);
            c33 = 0.125*(-M_out2[J11][lig][col] + 7.*M_out2[J22][lig][col] + 2.*M_out2[J12im][lig][col]);
            c12r = 0.;
            c12i = 0.;
            c13r = 0.125*(M_out2[J11][lig][col] + M_out2[J22][lig][col] + 6.*M_out2[J12im][lig][col]);
            c13i = -0.5*M_out2[J12re][lig][col];
            c23r = c12r;
            c23i = c12i;
            }
          }

        if (strcmp(PolType,"C3") == 0) {
          M_out3[C311][lig][col] = c11;M_out3[C322][lig][col] = c22;M_out3[C333][lig][col] = c33;
          M_out3[C312_re][lig][col] = c12r;M_out3[C312_im][lig][col] = c12i;
          M_out3[C313_re][lig][col] = c13r;M_out3[C313_im][lig][col] = c13i;
          M_out3[C323_re][lig][col] = c23r;M_out3[C323_im][lig][col] = c23i;
          }
        if (strcmp(PolType,"T3") == 0) {
          M_out3[T311][lig][col] = (c11 + 2 * c13r + c33) / 2;
          M_out3[T312_re][lig][col] = (c11 - c33) / 2;
          M_out3[T312_im][lig][col] = -c13i;
          M_out3[T313_re][lig][col] = (c12r + c23r) / sqrt(2);
          M_out3[T313_im][lig][col] = (c12i - c23i) / sqrt(2);
          M_out3[T322][lig][col] = (c11 - 2 * c13r + c33) / 2;
          M_out3[T323_re][lig][col] = (c12r - c23r) / sqrt(2);
          M_out3[T323_im][lig][col] = (c12i + c23i) / sqrt(2);
          M_out3[T333][lig][col] = c22;
          }
        } else {
        for (Np = 0; Np < NpolarOut; Np++) M_out3[Np][lig][col] = 0.;
        }
      }
    }
    
  write_block_matrix3d_float(out_file3, NpolarOut, M_out3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_out2, NpolarIn, NligBlock[0]);
  free_matrix3d_float(M_out3, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_file3[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}


