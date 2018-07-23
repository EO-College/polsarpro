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

File  : sub_aperture_CV.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL (v2.0 Eric POTTIER)
Version  : 1.0
Creation : 07/2005 (v2.0 08/2011)
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

Description :  Determination of the Coefficient of Variation (CV) of
               the parameters : entropy, anisotropy, alpha, span
               along the sub-apertures

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS */
#define Npara 4

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
  FILE *in_file[20], *out_file;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char in_file_name[FilePathLength], out_file_name[FilePathLength];
  char *file_in[Npara] = { "entropy.bin", "anisotropy.bin", "alpha.bin", "span.bin"};
  char *file_out[Npara] = { "CVentropy.bin", "CVanisotropy.bin", "CValpha.bin", "CVspan.bin"};
  
/* Internal variables */
  int ii, lig, col, k, l, sub;
  int sub_init, sub_number, Para[Npara];
  
  double value, mean, mean2;
  double Mmean, Mmean2;

/* Matrix arrays */
  float **M_in;
  float **M_moy;
  float **M_var;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsub_aperture_CV.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-subi	initial sub-aperture number\n");
strcat(UsageHelp," (int)   	-subn	number of sub-apertures\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-fh  	Flag entropy\n");
strcat(UsageHelp," (int)   	-fa  	Flag anisotropy\n");
strcat(UsageHelp," (int)   	-fal 	Flag alpha\n");
strcat(UsageHelp," (int)   	-fs  	Flag span\n");
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

if(argc < 27) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-subi",int_cmd_prm,&sub_init,1,UsageHelp);
  get_commandline_prm(argc,argv,"-subn",int_cmd_prm,&sub_number,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fh",int_cmd_prm,&Para[0],1,UsageHelp);
  get_commandline_prm(argc,argv,"-fa",int_cmd_prm,&Para[1],1,UsageHelp);
  get_commandline_prm(argc,argv,"-fal",int_cmd_prm,&Para[2],1,UsageHelp);
  get_commandline_prm(argc,argv,"-fs",int_cmd_prm,&Para[3],1,UsageHelp);

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

  if (FlagValid == 1) check_file(file_valid);
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  Off_lig = 0; Off_col = 0;
  Nlig = Sub_Nlig; Ncol = Sub_Ncol;

/* INPUT FILE OPENING*/
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

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

  /* Min = (Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += (Sub_Ncol+NwinC); NBlockB += NwinL*(Sub_Ncol+NwinC);
  /* Mmoy = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mvar = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VI_in = vector_int(Ncol);
  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  M_in = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  M_moy = matrix_float(NligBlock[0], Sub_Ncol);
  M_var = matrix_float(NligBlock[0], Sub_Ncol);
  M_out = matrix_float(NligBlock[0], Sub_Ncol);

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

for (Np = 0; Np < Npara; Np++) {

/********************************************************************
********************************************************************/
if (FlagValid == 1) rewind(in_valid);

if (Para[Np] == 1) {
/* INPUT FILE OPENING*/
  for (sub = sub_init; sub < sub_number; sub++) {
    if (strcmp(PolType,"S2")==0) sprintf(in_file_name, "%s%i/%s", in_dir, sub, file_in[Np]);
    if (strcmp(PolType,"T3")==0) sprintf(in_file_name, "%s%i/T3/%s", in_dir, sub, file_in[Np]);
    if (strcmp(PolType,"C3")==0) sprintf(in_file_name, "%s%i/C3/%s", in_dir, sub, file_in[Np]);
    check_file(in_file_name);
    if ((in_file[sub] = fopen(in_file_name, "rb")) == NULL) edit_error("Could not open output file : ", in_file_name);
    }

/* OUTPUT FILE OPENING*/
  if (strcmp(PolType,"S2")==0) sprintf(out_file_name, "%s%i/%s", out_dir, sub_init, file_out[Np]);
  if (strcmp(PolType,"T3")==0) sprintf(out_file_name, "%s%i/T3/%s", out_dir, sub_init, file_out[Np]);
  if (strcmp(PolType,"C3")==0) sprintf(out_file_name, "%s%i/C3/%s", out_dir, sub_init, file_out[Np]);
  check_file(out_file_name);
  if ((out_file = fopen(out_file_name, "wb")) == NULL) edit_error("Could not open output file : ", out_file_name);

/********************************************************************
********************************************************************/

for (Nb = 0; Nb < NbBlock; Nb++) {

/* Set the output matrix to 0 */
  for (lig = 0; lig < NligBlock[Nb]; lig++)
    for (col = 0; col < Ncol; col++) {
      M_var[lig][col] = 0.;
      M_moy[lig][col] = 0.;
      M_out[lig][col] = 0.;
      }

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (sub = sub_init; sub < sub_number; sub++) {
    read_block_matrix_float(in_file[sub], M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    for (lig = 0; lig < NligBlock[Nb]; lig++) {
      PrintfLine(lig,NligBlock[Nb]);
      for (col = 0; col < Sub_Ncol; col++) {
        if (col == 0) {
          Nvalid = 0.; Mmean = 0.; Mmean2 = 0.;
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
            for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
              value = M_in[NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              Mmean += value; Mmean2 = value*value;
              Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
              }
          } else {
          for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
            value = M_in[NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Mmean -= value; Mmean2 -= value*value;
            value = M_in[NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            Mmean += value; Mmean2 += value*value;
            Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          }
        if (Nvalid != 0.) mean = Mmean/Nvalid; else mean = INIT_MINMAX;
        if (Nvalid != 0.) mean2 = (Mmean2/Nvalid) - mean*mean; else mean2 = INIT_MINMAX;
        M_moy[lig][col] += mean;
        M_var[lig][col] += mean2;
        }
      }
    }
    
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        M_moy[lig][col] = M_moy[lig][col]/sub_number;
        M_var[lig][col] = M_var[lig][col]/sub_number;
        M_out[lig][col] = sqrt(M_var[lig][col]) / (M_moy[lig][col] + eps);
        }
      }
    }
  
  write_block_matrix_float(out_file, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* if Para */
/* INPUT FILE CLOSING*/
  for (sub = sub_init; sub < sub_number; sub++) fclose(in_file[sub]);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
}
/********************************************************************
********************************************************************/
/* Npara */
} 
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(M_in, NligBlock[0] + NwinL);
  free_matrix_float(M_out, NligBlock[0]);
  free_matrix_float(M_moy, NligBlock[0]);
  free_matrix_float(M_var, NligBlock[0]);

*/  
/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}


