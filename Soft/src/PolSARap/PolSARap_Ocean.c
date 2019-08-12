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

File   : PolSARap_Ocean.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 04/2014
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

Description :  PolSARap Ocean Showcase

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

#define NPolType 11
/* LOCAL VARIABLES */
  FILE *out_file_cohe, *out_file_mask;
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3",
    "C4", "T2", "T3", "T4", "SPP"};
  char file_name[FilePathLength];  
  
/* Internal variables */
  int ii, lig, col, k, l;
  int NwinTrainingL, NwinTrainingC;
  int NwinTestL, NwinTestC;
  float Psea, Psear, Pseai, Norma, Pt, Ptot;
  float Threshold, RedR;

/* Matrix arrays */
  float ***M_in;
  float ***M_out;
  float ***M_Train;
  float *M_Test;
  float **M_outCohe;
  float **M_outMask;
  float *mean;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Ocean.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-td  	tmp directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-wrtr	Nwin Row Training\n");
strcat(UsageHelp," (int)   	-wctr	Nwin Col Training\n");
strcat(UsageHelp," (int)   	-wrte	Nwin Row Test\n");
strcat(UsageHelp," (int)   	-wcte	Nwin Col Test\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-thr 	threshold\n");
strcat(UsageHelp," (float) 	-redr	reduction ratio\n");
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

if(argc < 29) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-td",str_cmd_prm,tmp_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-wrtr",int_cmd_prm,&NwinTrainingL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-wctr",int_cmd_prm,&NwinTrainingC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-wrte",int_cmd_prm,&NwinTestL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-wcte",int_cmd_prm,&NwinTestC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-thr",flt_cmd_prm,&Threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-redr",flt_cmd_prm,&RedR,1,UsageHelp);

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
  check_dir(tmp_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

  file_name_in = matrix_char(NpolarIn,1024); 
  file_name_tmp = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);
  init_file_name(PolTypeOut, tmp_dir, file_name_tmp);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* TMP OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((tmp_datafile[Np] = fopen(file_name_tmp[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_tmp[Np]);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%socean_coherence.bin", out_dir);
  if ((out_file_cohe = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%socean_mask.bin", out_dir);
  if ((out_file_mask = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

/********************************************************************
***** TRAINING *****
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 
  NwinL = NwinTrainingL;
  NwinC = NwinTrainingC;

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* Mtest = NpolarOut */
  NBlockB += NpolarOut;

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mouttmp = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  /* Mean = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
  
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  mean = vector_float(NpolarOut);

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

printf("Training Nb %i Lig %i\n",NbBlock,NligBlock[0]);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) mean[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++) 
              mean[Np] = mean[Np] + M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            mean[Np] = mean[Np] - M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            mean[Np] = mean[Np] + M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) M_out[Np][lig][col] = mean[Np]/Nvalid;
      }
    }

  write_block_matrix3d_float(tmp_datafile, NpolarOut, M_out, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0] + NwinL);
  free_matrix3d_float(_MF_in, NpolarOut, NwinL);
/********************************************************************
********************************************************************/

  if (FlagValid == 1) rewind(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
/* TMP OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(tmp_datafile[Np]);
/* TMP OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((tmp_datafile[Np] = fopen(file_name_tmp[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_tmp[Np]);

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
/********************************************************************
***** TESTING *****
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 
  NwinL = NwinTestL;
  NwinC = NwinTestC;

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  /* MoutCohe = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* MoutMask = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mtrain = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);
  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_Train = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
  M_Test = vector_float(NpolarOut);
  M_outCohe = matrix_float(NligBlock[0], Sub_Ncol);
  M_outMask = matrix_float(NligBlock[0], Sub_Ncol);

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

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      } else {
      read_block_SPP_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_TCI_noavg(tmp_datafile, M_Train, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Sub_Ncol);
  
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) mean[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++) 
              mean[Np] = mean[Np] + M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            mean[Np] = mean[Np] - M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            mean[Np] = mean[Np] + M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) M_Test[Np] = mean[Np]/Nvalid;
            
      M_outCohe[lig][col] = 0.; M_outMask[lig][col] = 0.;
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        if (NpolarOut == 4) {
          Ptot = M_Test[X211]*M_Test[X211]+M_Test[X222]*M_Test[X222];
          Ptot += M_Test[X212_re]*M_Test[X212_re]+M_Test[X212_im]*M_Test[X212_im];
          Norma = M_Train[X211][lig][col]*M_Train[X211][lig][col]+M_Train[X222][lig][col]*M_Train[X222][lig][col];
          Norma += M_Train[X212_re][lig][col]*M_Train[X212_re][lig][col]+M_Train[X212_im][lig][col]*M_Train[X212_im][lig][col];
          Psear = M_Test[X211]*M_Train[X211][lig][col]+M_Test[X222]*M_Train[X222][lig][col];
          Psear += M_Test[X212_re]*M_Train[X212_re][lig][col]+M_Test[X212_im]*M_Train[X212_im][lig][col];
          Pseai  = M_Test[X212_im]*M_Train[X212_re][lig][col]-M_Test[X212_re]*M_Train[X212_im][lig][col];
          }
        if (NpolarOut == 9) {
          Ptot = M_Test[X311]*M_Test[X311]+M_Test[X322]*M_Test[X322]+M_Test[X333]*M_Test[X333];
          Ptot += M_Test[X312_re]*M_Test[X312_re]+M_Test[X312_im]*M_Test[X312_im];
          Ptot += M_Test[X313_re]*M_Test[X313_re]+M_Test[X313_im]*M_Test[X313_im];
          Ptot += M_Test[X323_re]*M_Test[X323_re]+M_Test[X323_im]*M_Test[X323_im];
          Norma = M_Train[X311][lig][col]*M_Train[X311][lig][col]+M_Train[X322][lig][col]*M_Train[X322][lig][col]+M_Train[X333][lig][col]*M_Train[X333][lig][col];
          Norma += M_Train[X312_re][lig][col]*M_Train[X312_re][lig][col]+M_Train[X312_im][lig][col]*M_Train[X312_im][lig][col];
          Norma += M_Train[X313_re][lig][col]*M_Train[X313_re][lig][col]+M_Train[X313_im][lig][col]*M_Train[X313_im][lig][col];
          Norma += M_Train[X323_re][lig][col]*M_Train[X323_re][lig][col]+M_Train[X323_im][lig][col]*M_Train[X323_im][lig][col];
          Psear = M_Test[X311]*M_Train[X311][lig][col]+M_Test[X322]*M_Train[X322][lig][col]+M_Test[X333]*M_Train[X333][lig][col];
          Psear += M_Test[X312_re]*M_Train[X312_re][lig][col]+M_Test[X312_im]*M_Train[X312_im][lig][col];
          Psear += M_Test[X313_re]*M_Train[X313_re][lig][col]+M_Test[X313_im]*M_Train[X313_im][lig][col];
          Psear += M_Test[X323_re]*M_Train[X323_re][lig][col]+M_Test[X323_im]*M_Train[X323_im][lig][col];
          Pseai  = M_Test[X312_im]*M_Train[X312_re][lig][col]-M_Test[X312_re]*M_Train[X312_im][lig][col];
          Pseai += M_Test[X313_im]*M_Train[X313_re][lig][col]-M_Test[X313_re]*M_Train[X313_im][lig][col];
          Pseai += M_Test[X323_im]*M_Train[X323_re][lig][col]-M_Test[X323_re]*M_Train[X323_im][lig][col];
          }
        if (NpolarOut == 16) {
          Ptot = M_Test[X411]*M_Test[X411]+M_Test[X422]*M_Test[X422]+M_Test[X433]*M_Test[X433]+M_Test[X444]*M_Test[X444];
          Ptot += M_Test[X412_re]*M_Test[X412_re]+M_Test[X412_im]*M_Test[X412_im];
          Ptot += M_Test[X413_re]*M_Test[X413_re]+M_Test[X413_im]*M_Test[X413_im];
          Ptot += M_Test[X414_re]*M_Test[X414_re]+M_Test[X414_im]*M_Test[X414_im];
          Ptot += M_Test[X423_re]*M_Test[X423_re]+M_Test[X423_im]*M_Test[X423_im];
          Ptot += M_Test[X424_re]*M_Test[X424_re]+M_Test[X424_im]*M_Test[X424_im];
          Ptot += M_Test[X434_re]*M_Test[X434_re]+M_Test[X434_im]*M_Test[X434_im];
          Norma = M_Train[X411][lig][col]*M_Train[X411][lig][col]+M_Train[X422][lig][col]*M_Train[X422][lig][col]+M_Train[X433][lig][col]*M_Train[X433][lig][col]+M_Train[X444][lig][col]*M_Train[X444][lig][col];
          Norma += M_Train[X412_re][lig][col]*M_Train[X412_re][lig][col]+M_Train[X412_im][lig][col]*M_Train[X412_im][lig][col];
          Norma += M_Train[X413_re][lig][col]*M_Train[X413_re][lig][col]+M_Train[X413_im][lig][col]*M_Train[X413_im][lig][col];
          Norma += M_Train[X414_re][lig][col]*M_Train[X414_re][lig][col]+M_Train[X414_im][lig][col]*M_Train[X414_im][lig][col];
          Norma += M_Train[X423_re][lig][col]*M_Train[X423_re][lig][col]+M_Train[X423_im][lig][col]*M_Train[X423_im][lig][col];
          Norma += M_Train[X424_re][lig][col]*M_Train[X424_re][lig][col]+M_Train[X424_im][lig][col]*M_Train[X424_im][lig][col];
          Norma += M_Train[X434_re][lig][col]*M_Train[X434_re][lig][col]+M_Train[X434_im][lig][col]*M_Train[X434_im][lig][col];
          Psear = M_Test[X411]*M_Train[X411][lig][col]+M_Test[X422]*M_Train[X422][lig][col]+M_Test[X433]*M_Train[X433][lig][col]+M_Test[X444]*M_Train[X444][lig][col];
          Psear += M_Test[X412_re]*M_Train[X412_re][lig][col]+M_Test[X412_im]*M_Train[X412_im][lig][col];
          Psear += M_Test[X413_re]*M_Train[X413_re][lig][col]+M_Test[X413_im]*M_Train[X413_im][lig][col];
          Psear += M_Test[X414_re]*M_Train[X414_re][lig][col]+M_Test[X414_im]*M_Train[X414_im][lig][col];
          Psear += M_Test[X423_re]*M_Train[X423_re][lig][col]+M_Test[X423_im]*M_Train[X423_im][lig][col];
          Psear += M_Test[X424_re]*M_Train[X424_re][lig][col]+M_Test[X424_im]*M_Train[X424_im][lig][col];
          Psear += M_Test[X434_re]*M_Train[X434_re][lig][col]+M_Test[X434_im]*M_Train[X434_im][lig][col];
          Pseai  = M_Test[X412_im]*M_Train[X412_re][lig][col]-M_Test[X412_re]*M_Train[X412_im][lig][col];
          Pseai += M_Test[X413_im]*M_Train[X413_re][lig][col]-M_Test[X413_re]*M_Train[X413_im][lig][col];
          Pseai += M_Test[X414_im]*M_Train[X414_re][lig][col]-M_Test[X414_re]*M_Train[X414_im][lig][col];
          Pseai += M_Test[X423_im]*M_Train[X423_re][lig][col]-M_Test[X423_re]*M_Train[X423_im][lig][col];
          Pseai += M_Test[X424_im]*M_Train[X424_re][lig][col]-M_Test[X424_re]*M_Train[X424_im][lig][col];
          Pseai += M_Test[X434_im]*M_Train[X434_re][lig][col]-M_Test[X434_re]*M_Train[X434_im][lig][col];
          }
        Psea = (Psear*Psear + Pseai*Pseai)/Norma;
        Pt = Ptot - Psea;
        M_outCohe[lig][col] = 1./(sqrt(1.+RedR/(Pt+eps)));
        if (M_outCohe[lig][col] > Threshold) M_outMask[lig][col] = 1.;
        }
      }
    }
  write_block_matrix_float(out_file_cohe, M_outCohe, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(out_file_mask, M_outMask, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_Train, NpolarOut, NligBlock[0]);
  free_matrix_float(Valid, NligBlock[0] + NwinL);
  free_matrix_float(M_outCohe, NligBlock[0]);
  free_matrix_float(M_outMask, NligBlock[0]);
  free_matrix3d_float(_MF_in, NpolarOut, NwinL);
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  for (Np = 0; Np < NpolarOut; Np++) fclose(tmp_datafile[Np]);
  
/* OUTPUT FILE CLOSING*/
  fclose(out_file_cohe);
  fclose(out_file_mask);

  return 1;
}


