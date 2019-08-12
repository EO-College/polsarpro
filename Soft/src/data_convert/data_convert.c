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

File   : data_convert.c
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
    laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Convert Raw Binary Data Files

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

#define NPolType 85
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {
    "S2", "S2C3", "S2C4", "S2T3", "S2T4", 
    "S2SPPpp1", "S2SPPpp2","S2SPPpp3","S2IPPpp4", 
    "S2IPPpp5","S2IPPpp6", "S2IPPpp7","S2IPPfull",
    "S2C2pp1", "S2C2pp2","S2C2pp3",
    "S2C2lhv", "S2C2rhv","S2C2pi4",
    "S2SPPlhv", "S2SPPrhv","S2SPPpi4", 
    "C2", "C2IPPpp5", "C2IPPpp6", "C2IPPpp7",
    "C3", "C3T3", "C3C2pp1", "C3C2pp2", "C3C2pp3",
    "C3C2lhv", "C3C2rhv", "C3C2pi4",
    "C3IPPpp4", "C3IPPpp5","C3IPPpp6", "C3IPPpp7",
    "T3", "T3C3", "T3C2pp1", "T3C2pp2", "T3C2pp3",
    "T3C2lhv", "T3C2rhv", "T3C2pi4",
    "T3IPPpp4", "T3IPPpp5","T3IPPpp6", "T3IPPpp7",
    "C4", "C4T4", "C4C3", "C4T3",
    "C4C2pp1", "C4C2pp2", "C4C2pp3",
    "C4C2lhv", "C4C2rhv", "C4C2pi4",
    "C4IPPpp4", "C4IPPpp5","C4IPPpp6", "C4IPPpp7", "C4IPPfull",
    "T4", "T4C4", "T4C3", "T4T3",
    "T4C2pp1", "T4C2pp2", "T4C2pp3",
    "T4C2lhv", "T4C2rhv", "T4C2pi4",
    "T4IPPpp4", "T4IPPpp5","T4IPPpp6", "T4IPPpp7", "T4IPPfull",
    "T6", "SPP", "SPPIPP", "SPPC2", "IPP"};
  
/* Internal variables */
  int ii, lig, col, k, l;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
  int Symmetrisation;
  float xx;

  int NligBlockFinal;

/* Matrix arrays */
  float ***S_in;
  float ***M_in;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ndata_convert.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-sym 	symmetrisation (no: 0, yes: 1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlr",int_cmd_prm,&NLookLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlc",int_cmd_prm,&NLookCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssr",int_cmd_prm,&SubSampLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssc",int_cmd_prm,&SubSampCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-sym",int_cmd_prm,&Symmetrisation,1,UsageHelp);

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

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);

  if (NLookLig == 0) edit_error("\nWrong argument in the Nlook Row parameter\n",UsageHelp);
  if (NLookCol == 0) edit_error("\nWrong argument in the Nlook Col parameter\n",UsageHelp);
  if (SubSampLig == 0) edit_error("\nWrong argument in the Sub Sampling Row parameter\n",UsageHelp);
  if (SubSampCol == 0) edit_error("\nWrong argument in the Sub Sampling Col parameter\n",UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);

  NwinL = 1; NwinC = 1;

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

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open output file : ", file_name_out[Np]);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
NBlockA = 0; NBlockB = 0;
if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  /* Sin = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  } 

if ((strcmp(PolTypeOut,"S2")==0) || (strcmp(PolTypeOut,"SPP") == 0) 
  || (strcmp(PolTypeOut,"SPPpp1") == 0)
  || (strcmp(PolTypeOut,"SPPpp2") == 0)
  || (strcmp(PolTypeOut,"SPPpp3") == 0)
  || (strcmp(PolTypeOut,"SPPlhv") == 0)
  || (strcmp(PolTypeOut,"SPPrhv") == 0)
  || (strcmp(PolTypeOut,"SPPpi4") == 0)) {
  /* Mout = NpolarOut*Nlig*2*Sub_Ncol */
  NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
  } else {
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    /* Min = NpolarOut*Nlig*Ncol */
    NBlockA += NpolarOut*Ncol; NBlockB += 0;
    } else { 
    /* Min = NpolarIn*Nlig*Ncol */
    NBlockA += NpolarIn*Ncol; NBlockB += 0;
    }
  /* Mout = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
  }
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

  if (NbBlock != 1) block_alloc(NligBlock, SubSampLig, NLookLig, Sub_Nlig, &NbBlock);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
    } 
  if ((strcmp(PolTypeOut,"S2")==0) || (strcmp(PolTypeOut,"SPP") == 0) 
    || (strcmp(PolTypeOut,"SPPpp1") == 0)
    || (strcmp(PolTypeOut,"SPPpp2") == 0)
    || (strcmp(PolTypeOut,"SPPpp3") == 0)
    || (strcmp(PolTypeOut,"SPPlhv") == 0)
    || (strcmp(PolTypeOut,"SPPrhv") == 0)
    || (strcmp(PolTypeOut,"SPPpi4") == 0)) {
    M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
    } else {
    if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
      || (strcmp(PolTypeIn,"SPPpp1") == 0)
      || (strcmp(PolTypeIn,"SPPpp2") == 0)
      || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
      M_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
      } else { 
      M_in = matrix3d_float(NpolarIn, NligBlock[0], Ncol);
      }
    M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
    }

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

    if (strcmp(PolTypeIn,"S2")==0) {
      read_block_S2_noavg(in_datafile, S_in, "S2", 4, Nb, NbBlock, NligBlock[Nb], Ncol, 1, 1, Off_lig, Off_col, Ncol);

      if (strcmp(PolTypeOut,"C2pp1")==0) S2_to_C2(S_in, M_in, 1, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2pp2")==0) S2_to_C2(S_in, M_in, 2, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2pp3")==0) S2_to_C2(S_in, M_in, 3, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2lhv")==0) S2_to_C2(S_in, M_in, 4, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2rhv")==0) S2_to_C2(S_in, M_in, 5, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2pi4")==0) S2_to_C2(S_in, M_in, 6, NligBlock[Nb], Ncol, 0, 0);

      if (strcmp(PolTypeOut,"C3")==0) S2_to_C3(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C4")==0) S2_to_C4(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T3")==0) S2_to_T3(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"T4")==0) S2_to_T4(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);

      if (strcmp(PolTypeOut,"SPPpp1")==0) S2_to_SPP(S_in, 1, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"SPPpp2")==0) S2_to_SPP(S_in, 2, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"SPPpp3")==0) S2_to_SPP(S_in, 3, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"SPPlhv")==0) S2_to_SPP(S_in, 4, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"SPPrhv")==0) S2_to_SPP(S_in, 5, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"SPPpi4")==0) S2_to_SPP(S_in, 6, NligBlock[Nb], Ncol, 0, 0);

      if (strcmp(PolTypeOut,"IPPpp4")==0) S2_to_IPP(S_in, M_in, 4, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"IPPpp5")==0) S2_to_IPP(S_in, M_in, 5, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"IPPpp6")==0) S2_to_IPP(S_in, M_in, 6, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"IPPpp7")==0) S2_to_IPP(S_in, M_in, 7, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"IPPfull")==0) S2_to_IPP(S_in, M_in, 0, NligBlock[Nb], Ncol, 0, 0);

      } else {

      read_block_SPP_noavg(in_datafile, S_in, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Ncol, 1, 1, Off_lig, Off_col, Ncol);
      if (strcmp(PolTypeOut,"C2pp1")==0) SPP_to_C2(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2pp2")==0) SPP_to_C2(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"C2pp3")==0) SPP_to_C2(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      if (strcmp(PolTypeOut,"IPP")==0) SPP_to_IPP(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
      }

    } else {

    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarIn, Nb, NbBlock, NligBlock[Nb], Ncol, 1, 1, Off_lig, Off_col, Ncol);

    if ((strcmp(PolTypeIn,"C2")==0)&&(strcmp(PolTypeOut,"IPPpp5")==0)) C2_to_IPP(M_in, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C2")==0)&&(strcmp(PolTypeOut,"IPPpp6")==0)) C2_to_IPP(M_in, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C2")==0)&&(strcmp(PolTypeOut,"IPPpp7")==0)) C2_to_IPP(M_in, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"T3")==0)) C3_to_T3(M_in, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"C2pp1")==0)) C3_to_C2(M_in, 1, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"C2pp2")==0)) C3_to_C2(M_in, 2, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"C2pp3")==0)) C3_to_C2(M_in, 3, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"C2lhv")==0)) C3_to_C2(M_in, 4, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"C2rhv")==0)) C3_to_C2(M_in, 5, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"C2pi4")==0)) C3_to_C2(M_in, 6, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"IPPpp4")==0)) C3_to_IPP(M_in, 4, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"IPPpp5")==0)) C3_to_IPP(M_in, 5, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"IPPpp6")==0)) C3_to_IPP(M_in, 6, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C3")==0)&&(strcmp(PolTypeOut,"IPPpp7")==0)) C3_to_IPP(M_in, 7, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C3")==0)) T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C2pp1")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_C2(M_in, 1, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C2pp2")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_C2(M_in, 2, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C2pp3")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_C2(M_in, 3, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C2lhv")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_C2(M_in, 4, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C2rhv")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_C2(M_in, 5, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"C2pi4")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_C2(M_in, 6, NligBlock[Nb], Ncol, 0, 0); }

    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"IPPpp4")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_IPP(M_in, 4, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"IPPpp5")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_IPP(M_in, 5, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"IPPpp6")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_IPP(M_in, 6, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T3")==0)&&(strcmp(PolTypeOut,"IPPpp7")==0)) {
      T3_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0); C3_to_IPP(M_in, 7, NligBlock[Nb], Ncol, 0, 0); }

    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"T4")==0)) C4_to_T4(M_in, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"T3")==0)) C4_to_T3(M_in, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C3")==0)) C4_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C2pp1")==0)) C4_to_C2(M_in, 1, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C2pp2")==0)) C4_to_C2(M_in, 2, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C2pp3")==0)) C4_to_C2(M_in, 3, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C2lhv")==0)) C4_to_C2(M_in, 4, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C2rhv")==0)) C4_to_C2(M_in, 5, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"C2pi4")==0)) C4_to_C2(M_in, 6, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"IPPpp4")==0)) C4_to_IPP(M_in, 4, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"IPPpp5")==0)) C4_to_IPP(M_in, 5, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"IPPpp6")==0)) C4_to_IPP(M_in, 6, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"IPPpp7")==0)) C4_to_IPP(M_in, 7, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"C4")==0)&&(strcmp(PolTypeOut,"IPPfull")==0)) C4_to_IPP(M_in, 0, NligBlock[Nb], Ncol, 0, 0);

    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C4")==0)) T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"T3")==0)) T4_to_T3(M_in, NligBlock[Nb], Ncol, 0, 0);
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C3")==0)) T4_to_C3(M_in, NligBlock[Nb], Ncol, 0, 0);
    
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C2pp1")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_C2(M_in, 1, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C2pp2")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_C2(M_in, 2, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C2pp3")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_C2(M_in, 3, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C2lhv")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_C2(M_in, 4, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C2rhv")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_C2(M_in, 5, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"C2pi4")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_C2(M_in, 6, NligBlock[Nb], Ncol, 0, 0); }

    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"IPPpp4")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_IPP(M_in, 4, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"IPPpp5")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_IPP(M_in, 5, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"IPPpp6")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_IPP(M_in, 6, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"IPPpp7")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_IPP(M_in, 7, NligBlock[Nb], Ncol, 0, 0); }
    if ((strcmp(PolTypeIn,"T4")==0)&&(strcmp(PolTypeOut,"IPPfull")==0)) {
      T4_to_C4(M_in, NligBlock[Nb], Ncol, 0, 0); C4_to_IPP(M_in, 0, NligBlock[Nb], Ncol, 0, 0); }
    }

  if ((strcmp(PolTypeOut,"S2")==0) || (strcmp(PolTypeOut,"SPP") == 0) 
    || (strcmp(PolTypeOut,"SPPpp1") == 0)
    || (strcmp(PolTypeOut,"SPPpp2") == 0)
    || (strcmp(PolTypeOut,"SPPpp3") == 0)
    || (strcmp(PolTypeOut,"SPPlhv") == 0)
    || (strcmp(PolTypeOut,"SPPrhv") == 0)
    || (strcmp(PolTypeOut,"SPPpi4") == 0)) {
    if ((strcmp(PolTypeOut,"S2")==0)&&(Symmetrisation == 1)) {
	  xx = 0.;
#pragma omp parallel for private(col) firstprivate(xx)
      for (lig = 0; lig < NligBlock[Nb]; lig++) {
        if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlock[Nb]);
        for (col = 0; col < Sub_Ncol; col++) {
          xx = (S_in[s12][lig][2*col]+S_in[s21][lig][2*col])/2.;
          S_in[s12][lig][2*col] = xx; S_in[s21][lig][2*col] = xx;
          xx = (S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1])/2.;
          S_in[s12][lig][2*col+1] = xx; S_in[s21][lig][2*col+1] = xx;
          }
        }
      }
    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig));
	indlig = indcol = 0;
#pragma omp parallel for private(col, Np) firstprivate(indlig, indcol)
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol;
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][2*col] = S_in[Np][indlig][2*indcol];
          M_out[Np][lig][2*col+1] = S_in[Np][indlig][2*indcol+1];
          }
        }
      }

    write_block_matrix3d_cmplx(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);

    } else {
    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig*NLookLig));
	indlig = indcol = 0;
#pragma omp parallel for private(col, Np, k, l) firstprivate(indlig, indcol)
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) if (omp_get_thread_num() == 0) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig * NLookLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol * NLookCol;
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][col] = 0.;
          for (k = 0; k < NLookLig; k++)
            for (l = 0; l < NLookCol; l++)
              M_out[Np][lig][col] += M_in[Np][indlig+k][indcol+l];
          M_out[Np][lig][col] /= (NLookLig*NLookCol);
          }
        }
      }
    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);
    }
  
  } // NbBlock
  
  if ((strcmp(PolTypeOut,"S2")==0) || (strcmp(PolTypeOut,"SPP") == 0) 
    || (strcmp(PolTypeOut,"SPPpp1") == 0)
    || (strcmp(PolTypeOut,"SPPpp2") == 0)
    || (strcmp(PolTypeOut,"SPPpp3") == 0)
    || (strcmp(PolTypeOut,"SPPlhv") == 0)
    || (strcmp(PolTypeOut,"SPPrhv") == 0)
    || (strcmp(PolTypeOut,"SPPpi4") == 0)) {
    if ((strcmp(PolTypeOut,"S2")==0)) {
      if (Symmetrisation == 1) strcpy(PolarCase, "monostatic");
      if (Symmetrisation == 0) strcpy(PolarCase, "bistatic");
      strcpy(PolarType, "full");
      } else {
      strcpy(PolarCase, "monostatic");
      if (strcmp(PolTypeOut, "SPPpp1") == 0) strcpy(PolarType, "pp1");
      if (strcmp(PolTypeOut, "SPPpp2") == 0) strcpy(PolarType, "pp2");
      if (strcmp(PolTypeOut, "SPPpp3") == 0) strcpy(PolarType, "pp3");
      if (strcmp(PolTypeOut, "SPPlhv") == 0) strcpy(PolarType, "pp1");
      if (strcmp(PolTypeOut, "SPPrhv") == 0) strcpy(PolarType, "pp1");
      if (strcmp(PolTypeOut, "SPPpi4") == 0) strcpy(PolarType, "pp1");
      }

    } else {

    if (strcmp(PolTypeOut, "T3") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "T4") == 0) strcpy(PolarCase, "bistatic");
    if (strcmp(PolTypeOut, "C2pp1") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C2pp2") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C2pp3") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C2lhv") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C2rhv") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C2pi4") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C3") == 0) strcpy(PolarCase, "monostatic");
    if (strcmp(PolTypeOut, "C4") == 0) strcpy(PolarCase, "bistatic");
    if (strcmp(PolTypeOut, "IPPpp4") == 0) strcpy(PolarCase, "intensities");
    if (strcmp(PolTypeOut, "IPPpp5") == 0) strcpy(PolarCase, "intensities");
    if (strcmp(PolTypeOut, "IPPpp6") == 0) strcpy(PolarCase, "intensities");
    if (strcmp(PolTypeOut, "IPPpp7") == 0) strcpy(PolarCase, "intensities");
    if (strcmp(PolTypeOut, "IPPfull") == 0) strcpy(PolarCase, "intensities");

    strcpy(PolarType, "full");
    if (strcmp(PolTypeOut, "C2pp1") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolTypeOut, "C2pp2") == 0) strcpy(PolarType, "pp2");
    if (strcmp(PolTypeOut, "C2pp3") == 0) strcpy(PolarType, "pp3");
    if (strcmp(PolTypeOut, "C2lhv") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolTypeOut, "C2rhv") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolTypeOut, "C2pi4") == 0) strcpy(PolarType, "pp1");
    if (strcmp(PolTypeOut, "IPPpp4") == 0) strcpy(PolarType, "pp4");
    if (strcmp(PolTypeOut, "IPPpp5") == 0) strcpy(PolarType, "pp5");
    if (strcmp(PolTypeOut, "IPPpp6") == 0) strcpy(PolarType, "pp6");
    if (strcmp(PolTypeOut, "IPPpp7 ") == 0) strcpy(PolarType, "pp7");
    if (strcmp(PolTypeOut, "IPPfull") == 0) strcpy(PolarType, "full");

    }
  write_config(out_dir, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    free_matrix3d_float(S_in, NpolarIn, NligBlock[0]);
    } 
  if ((strcmp(PolTypeOut,"S2")==0) || (strcmp(PolTypeOut,"SPP") == 0) 
    || (strcmp(PolTypeOut,"SPPpp1") == 0)
    || (strcmp(PolTypeOut,"SPPpp2") == 0)
    || (strcmp(PolTypeOut,"SPPpp3") == 0)
    || (strcmp(PolTypeOut,"SPPlhv") == 0)
    || (strcmp(PolTypeOut,"SPPrhv") == 0)
    || (strcmp(PolTypeOut,"SPPpi4") == 0)) {
    free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
    } else {
    if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
      || (strcmp(PolTypeIn,"SPPpp1") == 0)
      || (strcmp(PolTypeIn,"SPPpp2") == 0)
      || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
      free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
      } else { 
      free_matrix3d_float(M_in, NpolarIn, NligBlock[0]);
      }
    free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
    }
*/
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}


