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

File   : geometrical_perturbation_filter.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Eric POTTIER, Jacek STRZELCZYK
Version  : 2.0
Creation : 07/2015
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

Description :  Geometrical Perturbation Filter

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

#define NPolType 8
/* LOCAL VARIABLES */
  FILE *OutFile1, *OutFile2, *OutFile3;
  int Config;
  char *PolTypeConf[NPolType] = { "S2", "C2", "C3", "C4", "T2", "T3", "T4", "SPP"};
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l;
  int NwinLtM1S2, NwinLt, NwinCtM1S2, NwinCt;
  int ligDone = 0;

  float Threshold, gamma, ptt, ptc, RedR, SCR, sigma_t, sigma_c;
  float Nvalidt;

/* Matrix arrays */
  float ***M_in;
  float **M_out1;
  float **M_out2;
  float **M_out3;
  //float *Vt, *Vc;
  //float *VtBuf, *VcBuf;
  float Vt[NpolarOutMax];
  float Vc[NpolarOutMax];
  float VtBuf[NpolarOutMax];
  float VcBuf[NpolarOutMax];
  

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ngeometrical_perturbation_filter.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (float) 	-thr 	Detection threshold\n");
strcat(UsageHelp," (int)   	-nwrt	Nwin Target Row\n");
strcat(UsageHelp," (int)   	-nwct	Nwin Target Col\n");
strcat(UsageHelp," (int)   	-nwrc	Nwin Clutter Row\n");
strcat(UsageHelp," (int)   	-nwcc	Nwin Clutter Col\n");
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

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-thr",flt_cmd_prm,&Threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwrc",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwcc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwrt",int_cmd_prm,&NwinLt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwct",int_cmd_prm,&NwinCt,1,UsageHelp);
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
  
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;
  NwinLtM1S2 = (NwinLt - 1) / 2;
  NwinCtM1S2 = (NwinCt - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"S2")==0) strcpy(PolType, "S2C3");
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
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
  sprintf(file_name, "%s%s%.3f%s", out_dir, "geometrical_perturbation_filter_", Threshold,".bin");
  if ((OutFile1 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s%.3f%s", out_dir, "geometrical_perturbation_filter_detect_", Threshold,".bin");
  if ((OutFile2 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s%.3f%s", out_dir, "geometrical_perturbation_filter_bin_detect_", Threshold,".bin");
  if ((OutFile3 = fopen(file_name, "wb")) == NULL)
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

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mout1 = Sub_Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mout2 = Sub_Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mout3 = Sub_Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
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
  M_out1 = matrix_float(NligBlock[0], Sub_Ncol);
  M_out2 = matrix_float(NligBlock[0], Sub_Ncol);
  M_out3 = matrix_float(NligBlock[0], Sub_Ncol);
/*  
  Vt = vector_float(NpolarOut);
  Vc = vector_float(NpolarOut);
  VtBuf = vector_float(NpolarOut);
  VcBuf = vector_float(NpolarOut);
*/
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

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
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

  if (strcmp(PolTypeOut,"T2")==0) T2_to_C2(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeOut,"T3")==0) T3_to_C3(M_in, NligBlock[Nb], Sub_Ncol, 0, 0); 
  if (strcmp(PolTypeOut,"T4")==0) T4_to_C4(M_in, NligBlock[Nb], Sub_Ncol, 0, 0);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col,Np,k,l,Nvalid,Nvalidt,sigma_t,sigma_c,SCR,RedR,ptt,ptc,gamma) firstprivate(Vt,Vc,VcBuf,VtBuf) shared(ligDone) schedule(dynamic)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
	ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out1[lig][col] = 0.; M_out2[lig][col] = 0.; M_out3[lig][col] = 0.; 
      for (Np = 0; Np < NpolarOut; Np++) Vt[Np] = 0.;
      for (Np = 0; Np < NpolarOut; Np++) Vc[Np] = 0.;
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) VcBuf[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++) VcBuf[Np] += M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) Vc[Np] = VcBuf[Np]/Nvalid;
        Nvalidt = 0.;
        for (Np = 0; Np < NpolarOut; Np++) VtBuf[Np] = 0.; 
        for (k = -NwinLtM1S2; k < 1 + NwinLtM1S2; k++)
          for (l = -NwinCtM1S2; l < 1 +NwinCtM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++) VtBuf[Np] += M_in[Np][NwinLtM1S2+lig+k][NwinCtM1S2+col+l]*Valid[NwinLtM1S2+lig+k][NwinCtM1S2+col+l];
            Nvalidt = Nvalidt + Valid[NwinLtM1S2+lig+k][NwinCtM1S2+col+l];
            }
        if (Nvalidt != 0.) for (Np = 0; Np < NpolarOut; Np++) Vt[Np] = VtBuf[Np]/Nvalidt;
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            VcBuf[Np] -= M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            VcBuf[Np] += M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) Vc[Np] = VcBuf[Np]/Nvalid;
        for (k = -NwinLtM1S2; k < 1 + NwinLtM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            VtBuf[Np] -= M_in[Np][NwinLtM1S2+lig+k][col-1]*Valid[NwinLtM1S2+lig+k][col-1];
            VtBuf[Np] += M_in[Np][NwinLtM1S2+lig+k][NwinCt-1+col]*Valid[NwinLtM1S2+lig+k][NwinCt-1+col];
            }
          Nvalidt = Nvalidt - Valid[NwinLtM1S2+lig+k][col-1] + Valid[NwinLtM1S2+lig+k][NwinCt-1+col];
          }
        if (Nvalidt != 0.) for (Np = 0; Np < NpolarOut; Np++) Vt[Np] = VtBuf[Np]/Nvalidt;
        }

      sigma_t = 0.; sigma_c = 0.;
      for (Np = 0; Np < NpolarOut; Np++) {
        sigma_t += Vt[Np]*Vt[Np]; sigma_c += Vc[Np]*Vc[Np];
        }      
      for (Np = 0; Np < NpolarOut; Np++) Vc[Np] = Vc[Np] / sqrt(sigma_c);
              
      //sigma_t = sqrt(sigma_t); sigma_c = sqrt(sigma_c);
      SCR = sigma_t / sigma_c;
      RedR = SCR / ((1. / (Threshold + eps)) - 1.);
      ptt = 0.; ptc = 0.;
      if (NpolarOut == 4) {
        ptt += Vt[C211]*Vt[C211]+Vt[C222]*Vt[C222];
        ptt += Vt[C212_re]*Vt[C212_re]+Vt[C212_im]*Vt[C212_im];
        ptc += Vt[C211]*Vc[C211]+Vt[C222]*Vc[C222];
        ptc += Vt[C212_re]*Vc[C212_re]+Vt[C212_im]*Vc[C212_im];
        ptc += Vt[C212_re]*Vc[C212_im]-Vt[C212_re]*Vc[C212_im];
        }
      if (NpolarOut == 9) {
        ptt += Vt[C311]*Vt[C311]+Vt[C322]*Vt[C322]+Vt[C333]*Vt[C333];
        ptt += Vt[C312_re]*Vt[C312_re]+Vt[C312_im]*Vt[C312_im];
        ptt += Vt[C313_re]*Vt[C313_re]+Vt[C313_im]*Vt[C313_im];
        ptt += Vt[C323_re]*Vt[C323_re]+Vt[C323_im]*Vt[C323_im];
        ptc += Vt[C311]*Vc[C311]+Vt[C322]*Vc[C322]+Vt[C333]*Vc[C333];
        ptc += Vt[C312_re]*Vc[C312_re]+Vt[C312_im]*Vc[C312_im];
        ptc += Vt[C312_re]*Vc[C312_im]-Vt[C312_re]*Vc[C312_im];
        ptc += Vt[C313_re]*Vc[C313_re]+Vt[C313_im]*Vc[C313_im];
        ptc += Vt[C313_re]*Vc[C313_im]-Vt[C313_re]*Vc[C313_im];
        ptc += Vt[C323_re]*Vc[C323_re]+Vt[C323_im]*Vc[C323_im];
        ptc += Vt[C323_re]*Vc[C323_im]-Vt[C323_re]*Vc[C323_im];
        }
      if (NpolarOut == 16) {
        ptt += Vt[C411]*Vt[C411]+Vt[C422]*Vt[C422]+Vt[C433]*Vt[C433]+Vt[C444]*Vt[C444];
        ptt += Vt[C412_re]*Vt[C412_re]+Vt[C412_im]*Vt[C412_im];
        ptt += Vt[C413_re]*Vt[C413_re]+Vt[C413_im]*Vt[C413_im];
        ptt += Vt[C414_re]*Vt[C414_re]+Vt[C414_im]*Vt[C414_im];
        ptt += Vt[C423_re]*Vt[C423_re]+Vt[C423_im]*Vt[C423_im];
        ptt += Vt[C424_re]*Vt[C424_re]+Vt[C424_im]*Vt[C424_im];
        ptt += Vt[C434_re]*Vt[C434_re]+Vt[C434_im]*Vt[C434_im];
        ptc += Vt[C411]*Vc[C411]+Vt[C422]*Vc[C422]+Vt[C433]*Vc[C433]+Vt[C444]*Vc[C444];
        ptc += Vt[C412_re]*Vc[C412_re]+Vt[C412_im]*Vc[C412_im];
        ptc += Vt[C412_re]*Vc[C412_im]-Vt[C412_re]*Vc[C412_im];
        ptc += Vt[C413_re]*Vc[C413_re]+Vt[C413_im]*Vc[C413_im];
        ptc += Vt[C413_re]*Vc[C413_im]-Vt[C413_re]*Vc[C413_im];
        ptc += Vt[C414_re]*Vc[C414_re]+Vt[C414_im]*Vc[C414_im];
        ptc += Vt[C414_re]*Vc[C414_im]-Vt[C414_re]*Vc[C414_im];
        ptc += Vt[C423_re]*Vc[C423_re]+Vt[C423_im]*Vc[C423_im];
        ptc += Vt[C423_re]*Vc[C423_im]-Vt[C423_re]*Vc[C423_im];
        ptc += Vt[C424_re]*Vc[C424_re]+Vt[C424_im]*Vc[C424_im];
        ptc += Vt[C424_re]*Vc[C424_im]-Vt[C424_re]*Vc[C424_im];
        ptc += Vt[C434_re]*Vc[C434_re]+Vt[C434_im]*Vc[C434_im];
        ptc += Vt[C434_re]*Vc[C434_im]-Vt[C434_re]*Vc[C434_im];
        }
      gamma = 1. / (1. + RedR*((ptt/(ptc*ptc)) - 1.));

      M_out1[lig][col] = gamma*Valid[NwinLM1S2+lig][NwinCM1S2+col];
      if (Threshold <= gamma) {
        M_out2[lig][col] = gamma*Valid[NwinLM1S2+lig][NwinCM1S2+col];
        M_out3[lig][col] = 1.*Valid[NwinLM1S2+lig][NwinCM1S2+col];
        } else {
        M_out2[lig][col] = 0.;
        M_out3[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(OutFile1, M_out1, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(OutFile2, M_out2, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);
  write_block_matrix_float(OutFile3, M_out3, NligBlock[Nb], Sub_Ncol, 0, 0, Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(OutFile1); fclose(OutFile2); fclose(OutFile3);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);

/********************************************************************
********************************************************************/

  return 1;
}
