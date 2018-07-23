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

File  : diversity_index.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 11/2012
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

Description :  diversity index based on eigenvalues

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

#define NPolType 7
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "SPP", "C2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength];
  
/* Flag Parameters */
  int Flag[13], Nout, NPara;
  FILE *OutFile[13];
  char *FileOut[13] = {
  "shannon_index.bin", "simpson_index.bin", "simpson_index_norm.bin", 
  "inverse_simpson_index.bin", "inverse_simpson_index_norm.bin",
  "gini_simpson_index.bin", "gini_simpson_index_norm.bin",
  "reyni_entropy2.bin", "reyni_entropy3.bin", "reyni_entropy4.bin",
  "index_qualitative_variation.bin", "perplexity.bin","perplexity_norm.bin"};

  int FlagShannon, FlagSimpson, FlagSimpsonInv, FlagGini;
  int FlagReyni2, FlagReyni3, FlagReyni4;
  int FlagIQV, FlagPerplexity;

  int Shannon, Simpson, SimpsonNorm, SimpsonInv, SimpsonInvNorm, Gini, GiniNorm;
  int Reyni2, Reyni3, Reyni4; 
  int IQV, Perplex, PerplexNorm;

/* Internal variables */
  int ii, lig, col, k;
  int Npp;

  float p[4];
  float xx, yy;

/* Matrix arrays */
  float ***M_avg;
  float ***M_out;

  float ***M;
  float ***V;
  float *lambda;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ndiversity_index.exe\n");
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

strcat(UsageHelp," (int)   	-fl1 	Flag Shannon index\n");
strcat(UsageHelp," (int)   	-fl2 	Flag Simpson index\n");
strcat(UsageHelp," (int)   	-fl3 	Flag Inverse Simpson index\n");
strcat(UsageHelp," (int)   	-fl4 	Flag Gini Simpson index\n");
strcat(UsageHelp," (int)   	-fl5 	Flag Reyni entropy 2\n");
strcat(UsageHelp," (int)   	-fl6	Flag Reyni entropy 3\n");
strcat(UsageHelp," (int)   	-fl7	Flag Reyni entropy 4\n");
strcat(UsageHelp," (int)   	-fl8	Flag Index of Qualitative Variation\n");
strcat(UsageHelp," (int)   	-fl9	Flag Perplexity\n");

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

if(argc < 37) {
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

  get_commandline_prm(argc,argv,"-fl1",int_cmd_prm,&FlagShannon,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl2",int_cmd_prm,&FlagSimpson,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl3",int_cmd_prm,&FlagSimpsonInv,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl4",int_cmd_prm,&FlagGini,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl5",int_cmd_prm,&FlagReyni2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl6",int_cmd_prm,&FlagReyni3,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl7",int_cmd_prm,&FlagReyni4,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl8",int_cmd_prm,&FlagIQV,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fl9",int_cmd_prm,&FlagPerplexity,1,UsageHelp);

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
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  if (strcmp(PolType,"S2")==0) strcpy(PolType, "S2T3");
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
  Shannon = 0; Simpson = 1; SimpsonNorm = 2; SimpsonInv = 3; 
  SimpsonInvNorm = 4; Gini = 5; GiniNorm = 6;
  Reyni2 = 7; Reyni3 = 8; Reyni4 = 9; 
  IQV = 10; Perplex = 11; PerplexNorm = 12;

  NPara = 13;
  for (k = 0; k < NPara; k++) Flag[k] = -1;
  Nout = 0;

  //Flag Shannon
  if (FlagShannon == 1) {
    Flag[Shannon] = Nout; Nout++;
    }
  //Flag Simpson
  if (FlagSimpson == 1) {
    Flag[Simpson] = Nout; Nout++;
    Flag[SimpsonNorm] = Nout; Nout++;
    }
  //Flag Simpson Inverse
  if (FlagSimpsonInv == 1) {
    Flag[SimpsonInv] = Nout; Nout++;
    Flag[SimpsonInvNorm] = Nout; Nout++;
    }
  //Flag Gini
  if (FlagGini == 1) {
    Flag[Gini] = Nout; Nout++;
    Flag[GiniNorm] = Nout; Nout++;
    }
  //Flag Reyni2
  if (FlagReyni2 == 1) {
    Flag[Reyni2] = Nout; Nout++;
    }
  //Flag Reyni3
  if (FlagReyni3 == 1) {
    Flag[Reyni3] = Nout; Nout++;
    }
  //Flag Reyni4
  if (FlagReyni4 == 1) {
    Flag[Reyni4] = Nout; Nout++;
    }
  //Flag IQV
  if (FlagIQV == 1) {
    Flag[IQV] = Nout; Nout++;
    }
  //Flag Perplex
  if (FlagPerplexity == 1) {
    Flag[Perplex] = Nout; Nout++;
    Flag[PerplexNorm] = Nout; Nout++;
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      sprintf(file_name, "%s%s", out_dir, FileOut[k]);
      if ((OutFile[Flag[k]] = fopen(file_name, "wb")) == NULL)
        edit_error("Could not open input file : ", file_name);
      }
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

  /* Mout = Nout*Nlig*Sub_Ncol */
  NBlockA += Nout*Sub_Ncol; NBlockB += 0;
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
  M_out = matrix3d_float(Nout, NligBlock[0], Sub_Ncol);

  if (strcmp(PolTypeOut,"C2")==0) Npp = 2;
  if ((strcmp(PolTypeOut,"T3")==0)||(strcmp(PolTypeOut,"C3")==0)) Npp = 3;
  if ((strcmp(PolTypeOut,"T4")==0)||(strcmp(PolTypeOut,"C4")==0)) Npp = 4;
  
  M = matrix3d_float(Npp, Npp, 2);
  V = matrix3d_float(Npp, Npp, 2);
  lambda = vector_float(Npp);

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

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
    
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      for (k = 0; k < Nout; k++) M_out[k][lig][col] = 0.;
      if (Valid[lig][col] == 1.) {
      
        if (Npp == 2) {
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[4][lig][col];
          M[1][1][1] = 0.;
          }
        if (Npp == 3) {
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[0][2][0] = eps + M_avg[3][lig][col];
          M[0][2][1] = eps + M_avg[4][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[5][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[6][lig][col];
          M[1][2][1] = eps + M_avg[7][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[8][lig][col];
          M[2][2][1] = 0.;
          }
        if (Npp == 4) {
          M[0][0][0] = eps + M_avg[0][lig][col];
          M[0][0][1] = 0.;
          M[0][1][0] = eps + M_avg[1][lig][col];
          M[0][1][1] = eps + M_avg[2][lig][col];
          M[0][2][0] = eps + M_avg[3][lig][col];
          M[0][2][1] = eps + M_avg[4][lig][col];
          M[0][3][0] = eps + M_avg[5][lig][col];
          M[0][3][1] = eps + M_avg[6][lig][col];
          M[1][0][0] =  M[0][1][0];
          M[1][0][1] = -M[0][1][1];
          M[1][1][0] = eps + M_avg[7][lig][col];
          M[1][1][1] = 0.;
          M[1][2][0] = eps + M_avg[8][lig][col];
          M[1][2][1] = eps + M_avg[9][lig][col];
          M[1][3][0] = eps + M_avg[10][lig][col];
          M[1][3][1] = eps + M_avg[11][lig][col];
          M[2][0][0] =  M[0][2][0];
          M[2][0][1] = -M[0][2][1];
          M[2][1][0] =  M[1][2][0];
          M[2][1][1] = -M[1][2][1];
          M[2][2][0] = eps + M_avg[12][lig][col];
          M[2][2][1] = 0.;
          M[2][3][0] = eps + M_avg[13][lig][col];
          M[2][3][1] = eps + M_avg[14][lig][col];
          M[3][0][0] =  M[0][3][0];
          M[3][0][1] = -M[0][3][1];
          M[3][1][0] =  M[1][3][0];
          M[3][1][1] = -M[1][3][1];
          M[3][2][0] =  M[2][3][0];
          M[3][2][1] = -M[2][3][1];
          M[3][3][0] = eps + M_avg[15][lig][col];
          M[3][3][1] = 0.;
          }

        /* EIGENVECTOR/EIGENVALUE DECOMPOSITION */
        /* V complex eigenvecor matrix, lambda real vector*/
        Diagonalisation(Npp, M, V, lambda);
  
        for (k = 0; k < Npp; k++)  if (lambda[k] <= 0.) lambda[k] = eps;
        span = 0.;
        for (k = 0; k < Npp; k++)  span += lambda[k];
        for (k = 0; k < Npp; k++)  {
          p[k] = lambda[k] / (eps + span);
          if (p[k] <= 0.) p[k] = eps; if (p[k] > 1.) p[k] = 1.;
          }

        if (Flag[Shannon] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx -= p[k]*log(p[k])/log(Npp);
          M_out[Flag[Shannon]][lig][col] = xx;       
          }
        if (Flag[Simpson] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k];
          M_out[Flag[Simpson]][lig][col] = xx;
          M_out[Flag[SimpsonNorm]][lig][col] = (Npp*xx - 1.)/(Npp - 1.);       
          }
        if (Flag[SimpsonInv] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k];
          yy = 1. / (xx + eps);
          M_out[Flag[SimpsonInv]][lig][col] = yy;
          M_out[Flag[SimpsonInvNorm]][lig][col] = (yy - 1.)/(Npp - 1.);       
          }
        if (Flag[Gini] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k];
          M_out[Flag[Gini]][lig][col] = 1. - xx;
          M_out[Flag[GiniNorm]][lig][col] = Npp*(1. - xx)/(Npp - 1.);       
          }
        if (Flag[Reyni2] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k];
          xx = (-1./1.)*log(xx)/log(Npp);
          M_out[Flag[Reyni2]][lig][col] = xx;       
          }
        if (Flag[Reyni3] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k]*p[k];
          xx = (-1./2.)*log(xx)/log(Npp);
          M_out[Flag[Reyni3]][lig][col] = xx;       
          }
        if (Flag[Reyni4] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k]*p[k]*p[k];
          xx = (-1./3.)*log(xx)/log(Npp);
          M_out[Flag[Reyni4]][lig][col] = xx;       
          }
        if (Flag[IQV] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx += p[k]*p[k];
          xx = Npp*(1. - xx)/(Npp - 1.);
          M_out[Flag[IQV]][lig][col] = xx;       
          }
        if (Flag[Perplex] != -1) {
          xx = 0.;
          for (k = 0; k < Npp; k++)  xx -= p[k]*log(p[k])/log(Npp);
          yy = exp(xx * log(Npp));
          M_out[Flag[Perplex]][lig][col] = yy;       
          M_out[Flag[PerplexNorm]][lig][col] = (yy - 1.)/(Npp - 1.);       
          }         
        } /*valid*/
      }
    }

  for (k = 0; k < NPara; k++) {
    if (Flag[k] != -1) {
      write_block_matrix_matrix3d_float(OutFile[Flag[k]], M_out, Flag[k], NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
      }
    }
    
  } // NbBlock

/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NPara; Np++) 
    if (Flag[Np] != -1) fclose(OutFile[Flag[Np]]);


/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, Nout, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/

  return 1;
}


