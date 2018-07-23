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

File  : h_alpha_fcm_classifier.c
Project  : ESA_POLSARPRO
Authors  : Sang-Eun PARK
Version  : 2.0 - Eric POTTIER (08/2011)
Creation : 12/2008
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

Description :  Fuzzy C means Classification of a SAR image into 
regions from its alpha and entropy fuzzy parameters (8 classes)

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS  */
/* prm parameters */
#define Alpha  0
#define H  1

#define z1 0 // top left
#define z2 1 // mid left
#define z3 2 // bottem left
#define z4 3 // top center
#define z5 4 // mid center
#define z6 5 // bottom center
#define z7 6 // top right
#define z8 7 // mid right

#define Nmem  8 // nomber of zones

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

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *in_mem_file[Nmem], *FCM_H_alpha_file;  
  int Config;
  char *PolTypeConf[NPolType] = {"S2","C3", "C4", "T3", "T4"};
  char file_name[FilePathLength], Wei[10];
  char *file_name_mem[Nmem] = 
  { "Mu_Z1.bin", "Mu_Z2.bin", "Mu_Z3.bin", "Mu_Z4.bin", 
  "Mu_Z5.bin", "Mu_Z6.bin", "Mu_Z7.bin", "Mu_Z8.bin" };
  char ColorMap8[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l;
  int ligg, Nligg;

  int Nit_max;  /* Maximum number of iterations */
  float dV_max;  /* Termination criteria */
  float dV[Nmem];  /* For checking termination critera  */
  float Hw[Nmem];  /* For membership/cluster update  */
  float Vi[Nmem][16];  /* For membership/cluster update  */
  float V_norm[Nmem];  /* For membership/cluster update  */  
  float Vi_o[Nmem][16];  /* For membership/cluster update  */
  float wei_m;  /* Weighting exponents */  

  float max, det_T, det_V, c_n, c_d;
  int Flag_stop, Nit, mem;
  int Narea = 20;
  int Bmp_flag;

/* Matrix arrays */
  float ***M_avg;
  float **M_out;

  float Membership [Nmem];  /* Initial membership values  */
  
  float ***M;
  float ***coh;
  float ***coh_m1;
  float *det_area[2];
  float dist[Nmem], Sum[Nmem], Mu_n[Nmem];
  float *det;

  float *coh_area[4][4][2];
  float *coh_area_m1[4][4][2];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_alpha_fcm_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
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
strcat(UsageHelp," (string)	-wei 	Wei\n");
strcat(UsageHelp," (float) 	-wem 	wei_m\n");
strcat(UsageHelp," (float) 	-dV  	dV_max\n");
strcat(UsageHelp," (int)   	-nit 	Number of iterations\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (1/0)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");
strcat(UsageHelp," (string)	-clm 	ColorMap Wishart8 colors (if BMP flag = 1)\n");

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

if(argc < 29) {
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
  get_commandline_prm(argc,argv,"-wei",str_cmd_prm,Wei,1,UsageHelp);
  get_commandline_prm(argc,argv,"-wem",flt_cmd_prm,&wei_m,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dV",flt_cmd_prm,&dV_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nit",int_cmd_prm,&Nit_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&Bmp_flag,1,UsageHelp);
  if (Bmp_flag == 1)
    get_commandline_prm(argc,argv,"-clm",str_cmd_prm,ColorMap8,1,UsageHelp);

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
  if (strcmp(PolType,"S2")==0) {
    if (strcmp(PolarCase,"monostatic") == 0) strcpy(PolType, "S2T3");
    if (strcmp(PolarCase,"bistatic") == 0) strcpy(PolType, "S2T4");
    }
  if (strcmp(PolType,"C3")==0) strcpy(PolType, "C3T3");
  if (strcmp(PolType,"C4")==0) strcpy(PolType, "C4T4");

  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  for (Np = 0; Np < Nmem; Np++) {
  sprintf(file_name, "%s%s", in_dir, file_name_mem[Np]);
  if ((in_mem_file[Np] = fopen(file_name, "rb")) == NULL)
    printf("Could not open output file : %s", file_name);
  }

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s%s%s%dx%d%s", in_dir, "fcm_H_alpha_class_",Wei,"_",NwinL,NwinC,".bin");
  if ((FCM_H_alpha_file = fopen(file_name, "wb")) == NULL)
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

  /* Mout = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
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
  M_out = matrix_float(Sub_Nlig, Sub_Ncol);
  
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
if (strcmp(PolTypeOut,"T3")==0) {
  M = matrix3d_float(3, 3, 2);
  coh = matrix3d_float(3, 3, 2);
  coh_m1 = matrix3d_float(3, 3, 2);
  det = vector_float(2);
  for (k = 0; k < 3; k++) {
  for (l = 0; l < 3; l++) {
    coh_area[k][l][0] = vector_float(Narea);
    coh_area[k][l][1] = vector_float(Narea);
    coh_area_m1[k][l][0] = vector_float(Narea);
    coh_area_m1[k][l][1] = vector_float(Narea);
    }
  }
  }
if (strcmp(PolTypeOut,"T4")==0) {
  M = matrix3d_float(4, 4, 2);
  coh = matrix3d_float(4, 4, 2);
  coh_m1 = matrix3d_float(4, 4, 2);
  det = vector_float(2);
  for (k = 0; k < 4; k++) {
  for (l = 0; l < 4; l++) {
    coh_area[k][l][0] = vector_float(Narea);
    coh_area[k][l][1] = vector_float(Narea);
    coh_area_m1[k][l][0] = vector_float(Narea);
    coh_area_m1[k][l][1] = vector_float(Narea);
    }
  }
  }

  det_area[0] = vector_float(Narea);
  det_area[1] = vector_float(Narea);

/****************************************************
 Obtain initial cluster center
*****************************************************/
for (mem=0; mem<Nmem; mem++) {
  V_norm[mem]=0;
  for (Np = 0; Np < NpolarOut; Np++) Vi[mem][Np]=0;
  }

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T4(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        for (mem = 0; mem < Nmem; mem++) {
          fread(&Membership[mem], sizeof(float), 1, in_mem_file[mem]);
          V_norm[mem] =eps + V_norm[mem] + pow(Membership[mem],wei_m);
          }
        for (Np = 0; Np < NpolarOut; Np++) 
          for (mem = 0; mem < Nmem; mem++) 
            Vi[mem][Np] =eps + Vi[mem][Np] + (eps + M_avg[Np][lig][col])*pow(Membership[mem],wei_m);
        }
      }
    }

  } // NbBlock

for (mem = 0; mem < Nmem; mem++)
  for (Np=0; Np<NpolarOut; Np++)
    Vi[mem][Np]=Vi[mem][Np]/V_norm[mem];

/********************************************************************
********************************************************************/

/****************************************************
START FCM iteration...
*****************************************************/
Flag_stop = 0;
  Nit = 0;

while (Flag_stop == 0) {
  Nit++;
  
  for(mem=0; mem<Nmem; mem++) for (Np=0; Np<NpolarOut; Np++) Vi_o[mem][Np]=Vi[mem][Np];
  
// Cluster center Coherency matrix
  if (strcmp(PolTypeOut,"T3")==0) {
  for (mem = 0; mem < Nmem; mem++) {  
    coh_area[0][0][0][mem] = Vi[mem][T311];
    coh_area[0][0][1][mem] = 0.;
    coh_area[0][1][0][mem] = Vi[mem][T312_re];
    coh_area[0][1][1][mem] = Vi[mem][T312_im];
    coh_area[0][2][0][mem] = Vi[mem][T313_re];
    coh_area[0][2][1][mem] = Vi[mem][T313_im];
    coh_area[1][0][0][mem] = Vi[mem][T312_re];
    coh_area[1][0][1][mem] = -Vi[mem][T312_im];
    coh_area[1][1][0][mem] = Vi[mem][T322];
    coh_area[1][1][1][mem] = 0.;
    coh_area[1][2][0][mem] = Vi[mem][T323_re];
    coh_area[1][2][1][mem] = Vi[mem][T323_im];
    coh_area[2][0][0][mem] = Vi[mem][T313_re];
    coh_area[2][0][1][mem] = -Vi[mem][T313_im];
    coh_area[2][1][0][mem] = Vi[mem][T323_re];
    coh_area[2][1][1][mem] = -Vi[mem][T323_im];
    coh_area[2][2][0][mem] = Vi[mem][T333];
    coh_area[2][2][1][mem] = 0.;  
    }

  /* Inverse center coherency matrices computation */
  for (mem = 0; mem < Nmem; mem++) {
    for (k = 0; k < 3; k++) {
    for (l = 0; l < 3; l++) {
      coh[k][l][0] = coh_area[k][l][0][mem];
      coh[k][l][1] = coh_area[k][l][1][mem];
      }
    }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < 3; k++) {
    for (l = 0; l < 3; l++) {
      coh_area_m1[k][l][0][mem] = coh_m1[k][l][0];
      coh_area_m1[k][l][1][mem] = coh_m1[k][l][1];
      }
    }
    det_area[0][mem] = det[0];
    det_area[1][mem] = det[1];
    }
  }

  if (strcmp(PolTypeOut,"T4")==0) {
  for (mem = 0; mem < Nmem; mem++) {  
    coh_area[0][0][0][mem] = Vi[mem][T411];
    coh_area[0][0][1][mem] = 0.;
    coh_area[0][1][0][mem] = Vi[mem][T412_re];
    coh_area[0][1][1][mem] = Vi[mem][T412_im];
    coh_area[0][2][0][mem] = Vi[mem][T413_re];
    coh_area[0][2][1][mem] = Vi[mem][T413_im];
    coh_area[0][3][0][mem] = Vi[mem][T414_re];
    coh_area[0][3][1][mem] = Vi[mem][T414_im];

    coh_area[1][0][0][mem] = Vi[mem][T412_re];
    coh_area[1][0][1][mem] = -Vi[mem][T412_im];
    coh_area[1][1][0][mem] = Vi[mem][T422];
    coh_area[1][1][1][mem] = 0.;
    coh_area[1][2][0][mem] = Vi[mem][T423_re];
    coh_area[1][2][1][mem] = Vi[mem][T423_im];
    coh_area[1][3][0][mem] = Vi[mem][T424_re];
    coh_area[1][3][1][mem] = Vi[mem][T424_im];

    coh_area[2][0][0][mem] = Vi[mem][T413_re];
    coh_area[2][0][1][mem] = -Vi[mem][T413_im];
    coh_area[2][1][0][mem] = Vi[mem][T423_re];
    coh_area[2][1][1][mem] = -Vi[mem][T423_im];
    coh_area[2][2][0][mem] = Vi[mem][T433];
    coh_area[2][2][1][mem] = 0.;  
    coh_area[2][3][0][mem] = Vi[mem][T434_re];
    coh_area[2][3][1][mem] = Vi[mem][T434_im];

    coh_area[3][0][0][mem] = Vi[mem][T414_re];
    coh_area[3][0][1][mem] = -Vi[mem][T414_im];
    coh_area[3][1][0][mem] = Vi[mem][T424_re];
    coh_area[3][1][1][mem] = -Vi[mem][T424_im];
    coh_area[3][2][0][mem] = Vi[mem][T434_re];
    coh_area[3][2][1][mem] = -Vi[mem][T434_im];
    coh_area[3][3][0][mem] = Vi[mem][T444];
    coh_area[3][3][1][mem] = 0.;  
    }

  /* Inverse center coherency matrices computation */
  for (mem = 0; mem < Nmem; mem++) {
    for (k = 0; k < 4; k++) {
    for (l = 0; l < 4; l++) {
      coh[k][l][0] = coh_area[k][l][0][mem];
      coh[k][l][1] = coh_area[k][l][1][mem];
      }
    }
    InverseHermitianMatrix4(coh, coh_m1);
    DeterminantHermitianMatrix4(coh, det);
    for (k = 0; k < 4; k++) {
    for (l = 0; l < 4; l++) {
      coh_area_m1[k][l][0][mem] = coh_m1[k][l][0];
      coh_area_m1[k][l][1][mem] = coh_m1[k][l][1];
      }
    }
    det_area[0][mem] = det[0];
    det_area[1][mem] = det[1];
    }

  }

/****************************************************/
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
if (FlagValid == 1) rewind(in_valid);

for (mem=0; mem<Nmem; mem++) {
  V_norm[mem]=0;
  for (Np = 0; Np < NpolarOut; Np++) Vi[mem][Np]=0;
  }

ligg = 0; Nligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }
  if (strcmp(PolTypeIn,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeIn,"C4")==0) C4_to_T4(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (strcmp(PolTypeOut,"T3")==0) {
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

          DeterminantHermitianMatrix3(M, det);
          det_T=sqrt(det[0] * det[0] + det[1] * det[1]);
  
          for (mem=0; mem<Nmem; mem++) {
    
            det_V=sqrt(det_area[0][mem] * det_area[0][mem] + det_area[1][mem] * det_area[1][mem]);
    
            for (k = 0; k < 3; k++) 
              for (l = 0; l < 3; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][mem];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][mem];
                }

            dist[mem]=log(det_V / det_T) + Trace3_HM1xHM2(coh_m1, M) - 3.;
          
            if (dist[mem] < 1) { 
              Hw[mem]=1;
              dist[mem]=pow(dist[mem],2)/2.;
              } else {
              Hw[mem]=1.0/fabs(dist[mem]);
              dist[mem]=fabs(dist[mem]) - 0.5;
              }
            }
          }
          
        if (strcmp(PolTypeOut,"T4")==0) {
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

          DeterminantHermitianMatrix4(M, det);
          det_T=sqrt(det[0] * det[0] + det[1] * det[1]);
  
          for (mem=0; mem<Nmem; mem++) {
    
            det_V=sqrt(det_area[0][mem] * det_area[0][mem] + det_area[1][mem] * det_area[1][mem]);

            for (k = 0; k < 4; k++) 
              for (l = 0; l < 4; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][mem];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][mem];
                }

            dist[mem]=log(det_V / det_T) + Trace4_HM1xHM2(coh_m1, M) - 4.;
    
            if (dist[mem] < 1) { 
              Hw[mem]=1;
              dist[mem]=pow(dist[mem],2)/2.;
              } else {
              Hw[mem]=1.0/fabs(dist[mem]);
              dist[mem]=fabs(dist[mem]) - 0.5;
              }
            }
          }

        for (mem=0; mem<Nmem; mem++) {
          Sum[mem]=0.;
          for (k=0; k<Nmem; k++) Sum[mem] = Sum[mem] + pow( dist[mem]/dist[k]  ,  1./(wei_m - 1.) );
          Mu_n[mem]= 1./Sum[mem];
          Membership[mem]=pow(Mu_n[mem],wei_m)*Hw[mem];
          }
  
        max=Mu_n[0]; M_out[ligg][col]=1;
        for(mem=1;mem < Nmem; mem++) {
          if (max < Mu_n[mem]) {
            max=Mu_n[mem]; 
            M_out[ligg][col] = mem+1.;
            }
          }
  
        // New cluster center
        for (mem = 0; mem < Nmem; mem++) {
          V_norm[mem] =eps + V_norm[mem] + Membership[mem];
          for (Np = 0; Np < NpolarOut; Np++) Vi[mem][Np] =eps + Vi[mem][Np] + M_avg[Np][lig][col]*Membership[mem];
          }
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/****************************************************/
// Check termination
  for (mem = 0; mem < Nmem; mem++) {
    c_n=0.;  c_d=0;
    for (Np = 0; Np < NpolarOut; Np++)  {
      Vi[mem][Np] = Vi[mem][Np] / V_norm[mem];
      c_n=c_n+fabs(Vi[mem][Np]-Vi_o[mem][Np]);
      c_d=c_d+fabs(Vi_o[mem][Np]);
      }
    dV[mem]=100.*c_n/c_d; 
    }
  for(mem=0;mem < Nmem; mem++) 
    for (k=mem+1; k <Nmem; k++) 
      if (dV[mem] > dV[k]) {
        max=dV[mem]; 
        dV[mem]=dV[k];
        dV[k]=max;
        } 

  if (dV[0] < 2.) Flag_stop =1;
  
  if (dV[Nmem-1] < dV_max) Flag_stop =1;  
  if (Nit == Nit_max) Flag_stop = 1;
  
  //rewind(FCM_H_alpha_file);

  } // end while

/****************************************************/

/* Saving fcm_H_alpha classification results*/
  M_out[0][0] = 1.; M_out[1][1] = 8.;

  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    fwrite(&M_out[lig][0], sizeof(float), Sub_Ncol, FCM_H_alpha_file);
    }

/* Creating fcm_H_alpha classification results bitmap*/
  if (Bmp_flag == 1) {
    sprintf(file_name, "%s%s%s%s%dx%d", out_dir, "fcm_H_alpha_class_",Wei,"_",NwinL,NwinC);
    bmp_wishart(M_out, Sub_Nlig, Sub_Ncol, file_name, ColorMap8);
    }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, Sub_Nlig);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < Nmem; Np++) fclose(in_mem_file[Np]);
  fclose(FCM_H_alpha_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


