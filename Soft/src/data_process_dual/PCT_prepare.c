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

File   : PCT_prepare.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Shane R. CLOUDE
Version  : 2.0
Creation : 12/2007
Update  : 08/2012
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

Description :  Polarization Coherence Tomography parameters estimation

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

#define NPolType 2
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  FILE *Kz_file;
  FILE *out_topo, *out_hest, *out_gamH, *out_gamL, *out_Kv;

/* Strings */
  char file_name[FilePathLength], file_kz[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l, ligg, Nligg;
  int Ph;
  float Pr, Lmin, Lmax, dcoh;
  float MinSep, Sep, mask;
  float plow, a, b, c, mu1, mu2, phi1, phi2;
  float hp, hp1, hp2;
  float hc, hc1, hc2;
  float pv, pv1, pv2;
  float he1, he2;
  float maskp, phiuse, epsilon;
//  float mu;
  cplx gmin, gmax, gamma_low, gamma_high, g1, g2;
  cplx dg, rat, topo1, topo2;

/* Matrix arrays */
  float *Kz;
  cplx **TT11,**TT12,**TT22,**TT;
  cplx **iTT,**Z12p,**Z12r,**hZ12p;
  cplx **Tmp11,**Tmp12,**Tmp;
  cplx **V,**hV,**Gvol,**Gsurf;
  float *L, *gammaH, *gammaL, *topo, *hest;
  float **Cohd, **Cohm;
  float *ValidMask;
  
/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float *Mean;
  float *Buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPCT_prepare.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-kz  	input kz file\n");
strcat(UsageHelp," (float) 	-eps 	epsilon\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "S2T6") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T6") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-kz",str_cmd_prm,file_kz,1,UsageHelp);
  get_commandline_prm(argc,argv,"-eps",flt_cmd_prm,&epsilon,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
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

/***********************************************************************
***********************************************************************/

  check_dir(in_dir1);
  if (strcmp(PolType, "S2T6") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(file_kz);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  if (strcmp(PolTypeIn,"S2")==0) file_name_in2 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  if (strcmp(PolTypeIn,"S2")==0) init_file_name(PolTypeIn, in_dir2, file_name_in2);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  if (strcmp(PolTypeIn,"S2")==0)
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s", file_kz);
  if ((Kz_file = fopen(file_name, "rb")) == NULL)
  edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_TopoPhase.bin");
  if ((out_topo = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_Height.bin");
  if ((out_hest = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "PCT_Kv.bin");
  if ((out_Kv = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "cmplx_coh_PCTgamHi.bin");
  if ((out_gamH = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "cmplx_coh_PCTgamLo.bin");
  if ((out_gamL = fopen(file_name, "wb")) == NULL)
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
  NBlockA += Sub_Ncol+NwinC; NBlockB += NwinL*(Sub_Ncol+NwinC);

  if (strcmp(PolTypeIn,"S2")==0) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 2*NpolarIn*2*(Ncol+NwinC); NBlockB += 2*NpolarIn*NwinL*2*(Ncol+NwinC);
    }

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Gvol, Gsurf, Cohd, Cohm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* Buffer = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut;
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

/* MATRIX ALLOCATION */
  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  if (strcmp(PolTypeIn,"S2")==0) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    }

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  Mean = vector_float(NpolarOut);

  Kz  = vector_float(Ncol);
  ValidMask = vector_float(Ncol);

  Gvol  = cplx_matrix(NligBlock[0],Sub_Ncol);
  Gsurf  = cplx_matrix(NligBlock[0],Sub_Ncol);
  Cohd  = matrix_float(NligBlock[0],Sub_Ncol);
  Cohm  = matrix_float(NligBlock[0],Sub_Ncol);

  TT11  = cplx_matrix(3,3);
  TT12  = cplx_matrix(3,3);
  TT22  = cplx_matrix(3,3);
  TT  = cplx_matrix(3,3);
  iTT  = cplx_matrix(3,3);
  Z12p  = cplx_matrix(3,3);
  Z12r  = cplx_matrix(3,3);
  hZ12p  = cplx_matrix(3,3);
  Tmp11  = cplx_matrix(3,3);
  Tmp12  = cplx_matrix(3,3);
  Tmp  = cplx_matrix(3,3);
  V  = cplx_matrix(3,3);
  hV  = cplx_matrix(3,3);
  L  = vector_float(3);
  gammaH = vector_float(2*Ncol);
  gammaL = vector_float(2*Ncol);
  topo  = vector_float(Ncol);
  hest  = vector_float(Ncol);

  Buffer = vector_float(NpolarOut);
  
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

// Calculate Two Optimum Coherences Using Phase Optimisation //
for (Ph = 0; Ph < 19; Ph++) {
  PrintfLine(Ph,19);
  Pr = Ph * 10. * pi/180.;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile1[Np]);
  if (strcmp(PolTypeIn,"S2")==0) 
    for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile2[Np]);
  if (FlagValid == 1) rewind(in_valid);

  Nligg = 0; ligg = 0;

/********************************************************************
********************************************************************/

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2_noavg(in_datafile1, S_in1, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_S2_noavg(in_datafile2, S_in2, "S2", 4, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    S2_to_T6(S_in1, S_in2, M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    } else {
    /* Case of T6 */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (col == 0) {
        Nvalid = 0.;
        for (Np = 0; Np < NpolarOut; Np++) Buffer[Np] = 0.; 
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++)
          for (l = -NwinCM1S2; l < 1 +NwinCM1S2; l++) {
            for (Np = 0; Np < NpolarOut; Np++)
              Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinCM1S2+col+l]*Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            Nvalid = Nvalid + Valid[NwinLM1S2+lig+k][NwinCM1S2+col+l];
            }
        } else {
        for (k = -NwinLM1S2; k < 1 + NwinLM1S2; k++) {
          for (Np = 0; Np < NpolarOut; Np++) {
            Buffer[Np] = Buffer[Np] - M_in[Np][NwinLM1S2+lig+k][col-1]*Valid[NwinLM1S2+lig+k][col-1];
            Buffer[Np] = Buffer[Np] + M_in[Np][NwinLM1S2+lig+k][NwinC-1+col]*Valid[NwinLM1S2+lig+k][NwinC-1+col];
            }
          Nvalid = Nvalid - Valid[NwinLM1S2+lig+k][col-1] + Valid[NwinLM1S2+lig+k][NwinC-1+col];
          }
        }      
      if (Nvalid != 0.) for (Np = 0; Np < NpolarOut; Np++) Mean[Np] = Buffer[Np]/Nvalid;

      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        TT11[0][0].re = Mean[T611];  TT11[0][0].im = 0.;
        TT11[0][1].re = Mean[T612_re];  TT11[0][1].im = Mean[T612_im];
        TT11[0][2].re = Mean[T613_re];  TT11[0][2].im = Mean[T613_im];
        TT11[1][0].re = Mean[T612_re];  TT11[1][0].im = -Mean[T612_im];
        TT11[1][1].re = Mean[T622];  TT11[1][1].im = 0.;
        TT11[1][2].re = Mean[T623_re];  TT11[1][2].im = Mean[T623_im];
        TT11[2][0].re = Mean[T613_re];  TT11[2][0].im = -Mean[T613_im];
        TT11[2][1].re = Mean[T623_re];  TT11[2][1].im = -Mean[T623_im];
        TT11[2][2].re = Mean[T633];  TT11[2][2].im = 0.;

        TT22[0][0].re = Mean[T644];  TT22[0][0].im = 0.;
        TT22[0][1].re = Mean[T645_re];  TT22[0][1].im = Mean[T645_im];
        TT22[0][2].re = Mean[T646_re];  TT22[0][2].im = Mean[T646_im];
        TT22[1][0].re = Mean[T645_re];  TT22[1][0].im = -Mean[T645_im];
        TT22[1][1].re = Mean[T655];  TT22[1][1].im = 0.;
        TT22[1][2].re = Mean[T656_re];  TT22[1][2].im = Mean[T656_im];
        TT22[2][0].re = Mean[T646_re];  TT22[2][0].im = -Mean[T646_im];
        TT22[2][1].re = Mean[T656_re];  TT22[2][1].im = -Mean[T656_im];
        TT22[2][2].re = Mean[T666];  TT22[2][2].im = 0.;

        TT12[0][0].re = Mean[T614_re];  TT12[0][0].im = Mean[T614_im];
        TT12[0][1].re = Mean[T615_re];  TT12[0][1].im = Mean[T615_im];
        TT12[0][2].re = Mean[T616_re];  TT12[0][2].im = Mean[T616_im];
        TT12[1][0].re = Mean[T624_re];  TT12[1][0].im = Mean[T624_im];
        TT12[1][1].re = Mean[T625_re];  TT12[1][1].im = Mean[T625_im];
        TT12[1][2].re = Mean[T626_re];  TT12[1][2].im = Mean[T626_im];
        TT12[2][0].re = Mean[T634_re];  TT12[2][0].im = Mean[T634_im];
        TT12[2][1].re = Mean[T635_re];  TT12[2][1].im = Mean[T635_im];
        TT12[2][2].re = Mean[T636_re];  TT12[2][2].im = Mean[T636_im];

        for (k = 0; k < 3; k++) {
          for (l = 0; l < 3; l++) {
            TT[k][l].re = 0.5 * (TT11[k][l].re + TT22[k][l].re);
            TT[k][l].im = 0.5 * (TT11[k][l].im + TT22[k][l].im);
            Z12p[k][l].re = TT12[k][l].re * cos(Pr) - TT12[k][l].im * sin(Pr);
            Z12p[k][l].im = TT12[k][l].re * sin(Pr) + TT12[k][l].im * cos(Pr);
            }
          }
        cplx_htransp_mat(Z12p,hZ12p,3,3);
        for (k = 0; k < 3; k++) {
          for (l = 0; l < 3; l++) {
            Z12r[k][l].re = 0.5 * (Z12p[k][l].re + hZ12p[k][l].re);
            Z12r[k][l].im = 0.5 * (Z12p[k][l].im + hZ12p[k][l].im);
            }
          }

        // Solve Eigenvalue Problem
        cplx_inv_mat(TT,iTT);
        cplx_mul_mat(iTT,Z12r,Tmp,3,3);
        cplx_diag_mat3(Tmp,V,L);

        // Calculate Optimum Coherences
        cplx_htransp_mat(V,hV,3,3);

        cplx_mul_mat(TT12,V,Tmp,3,3);
        cplx_mul_mat(hV,Tmp,Tmp12,3,3);

        cplx_mul_mat(TT,V,Tmp,3,3);
        cplx_mul_mat(hV,Tmp,Tmp11,3,3);

        Lmin=L[0];l=0;
        for (k=0; k<3; k++) {
          if (L[k] <= Lmin) {
            Lmin = L[k];
            l = k;
            }
          }
        gmin.re = Tmp12[l][l].re / cmod(Tmp11[l][l]);
        gmin.im = Tmp12[l][l].im / cmod(Tmp11[l][l]);

        Lmax=L[0];l=0;
        for (k=0; k<3; k++) {
          if (Lmax <= L[k]) {
            Lmax = L[k];
            l = k;
            }
          }
        gmax.re = Tmp12[l][l].re / cmod(Tmp11[l][l]);
        gmax.im = Tmp12[l][l].im / cmod(Tmp11[l][l]);

        // Keep Maximum Separation of Coherences
        dcoh = cmod(csub(gmax,gmin));
        if (dcoh > Cohd[ligg][col]) {
          Cohd[ligg][col] = dcoh;
          Gvol[ligg][col] = gmax;
          Gsurf[ligg][col] = gmin;
          }
        if (dcoh > Cohm[ligg][col]) Cohm[lig][col] = dcoh;
        } else {
        Cohd[ligg][col] = 0.; Cohm[ligg][col] = 0.;
        Gvol[ligg][col].re = 0.; Gvol[ligg][col].im = 0.;
        Gsurf[ligg][col].re = 0.; Gsurf[ligg][col].im = 0.;
        } // valid
      } // col
    } // lig 
  Nligg += NligBlock[Nb];
  } // NbBlock
} // Ph

/********************************************************************
********************************************************************/
  rewind(Kz_file);
  for (lig = 0; lig < Off_lig; lig++) fread(&Kz[0], sizeof(float), Ncol, Kz_file);

  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;
  if (FlagValid == 1) {
    rewind(in_valid);
    for (lig = 0; lig < Off_lig; lig++) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }    
/********************************************************************
********************************************************************/
MinSep = 1.; // Minimum Phase Centre Separation (in m) used to separate Surface and Volume scattering in scene
for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  fread(&Kz[0], sizeof(float), Ncol, Kz_file);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+Off_col] == 1.) {

      // Mask Out Surface Regions
      Sep = fabs(angle(cmul(Gvol[lig][col],cconj(Gsurf[lig][col])))) / Kz[col+Off_col];
      // Only keep areas with more than MinSep Phase Centre separation
      mask = 0.; if (Sep > MinSep) mask = 1.;

      // Topo Phase and Height Estimation
      gamma_low=Gsurf[lig][col];
      gamma_high=Gvol[lig][col];
      //use primary rank ordering of coherence
      plow=angle(gamma_low);
      g1=gamma_high;
      g2=gamma_low;
      dg=csub(g2,g1);
      a=cmod2(g1)-1;
      b=2.*crel(cmul(dg,cconj(g1)));
      c=cmod2(dg);
      mu1=-b-sqrt(b*b-4.*a*c);
      mu1=fabs(mu1/(2.*a));
      g1.re=g1.re*(1.-mu1);
      g1.im=g1.im*(1.-mu1);
      rat=csub(g2,g1);
      rat.re=rat.re/mu1;
      rat.im=rat.im/mu1;
      phi1=angle(rat);

      //switch ground and volume channels
      g1=gamma_low;
      g2=gamma_high;
      dg=csub(g2,g1);
      a=cmod2(g1)-1.;
      b=2.*crel(cmul(dg,cconj(g1)));
      c=cmod2(dg);
      mu2=-b-sqrt(b*b-4.*a*c);
      mu2=fabs(mu2/(2.*a));
      g1.re=g1.re*(1.-mu2);
      g1.im=g1.im*(1.-mu2);
      rat=csub(g2,g1);
      rat.re=rat.re/mu2;
      rat.im=rat.im/mu2;
      phi2=angle(rat);

      //two unit circle intersection points
      topo1.re=cos(phi1);//expected topographic phase
      topo1.im=sin(phi1);//expected topographic phase
      topo2.re=cos(phi2);//order reversed topography estimate
      topo2.im=sin(phi2);//order reversed topography estimate

      //use estimated ground
      hp1=angle(cmul(gamma_high,cconj(topo1))); //height component from phase
      hp2=angle(cmul(gamma_low,cconj(topo2))); //height component from phase

      //keep both solutions and choose smallest total height estimate
      if (hp1 < 0) hp1=hp1+2.*pi; //make all phase heights positive
      if (hp1 < 0) hp2=hp2+2.*pi; //make all phase heights positive

      hp1=hp1 / Kz[col]; //convert phase to height
      hp2=hp2 / Kz[col]; //convert phase to height

      //invert coherence amplitude for two channels
      pv1=1.0-asin(pow(cmod(gamma_high),0.8))*2./pi;
      hc1=(epsilon*pi*pv1)/fabs(Kz[col]);
  
      pv2=1.0-asin(pow(cmod(gamma_low),0.8))*2./pi;
      hc2=(epsilon*pi*pv2)/fabs(Kz[col]);

      he1=hp1+hc1;
      he2=hp2+hc2;

      //choose between pair of solutions for ground phase
      maskp=0.; if (he2 < he1) maskp = 1.; //mask to select point 1 or point 2
  
      phiuse=phi1+maskp*(phi2-phi1); //select topography phase
      gammaH[2*col]=gamma_high.re + maskp*(gamma_low.re-gamma_high.re); //new gamma_high component
      gammaH[2*col+1]=gamma_high.im + maskp*(gamma_low.im-gamma_high.im); //new gamma_high component
      if (sqrt(gammaH[2*col]*gammaH[2*col]+gammaH[2*col+1]*gammaH[2*col+1]) > 1.) {
        g1.re = gammaH[2*col]; g1.im = gammaH[2*col+1];
        gammaH[2*col] = cos(angle(g1)); gammaH[2*col+1] = sin(angle(g1));
        }
      gammaL[2*col]=gamma_low.re+maskp*(gamma_high.re-gamma_low.re); //new gamma_low component
      gammaL[2*col+1]=gamma_low.im+maskp*(gamma_high.im-gamma_low.im); //new gamma_low component
      if (sqrt(gammaL[2*col]*gammaL[2*col]+gammaL[2*col+1]*gammaL[2*col+1]) > 1.) {
        g1.re = gammaL[2*col]; g1.im = gammaL[2*col+1];
        gammaL[2*col] = cos(angle(g1)); gammaL[2*col+1] = sin(angle(g1));
        }
//      mu=mu1+maskp*(mu2-mu1);
      hp=hp1+maskp*(hp2-hp1); //height from phase

      //use polarimetric mask to isolate surface regions
      topo[col]=(plow+mask*(phiuse-plow))*180./pi;

      //height component from coherence amplitude for each pixel
      hc = sqrt(gammaH[2*col]*gammaH[2*col]+gammaH[2*col+1]*gammaH[2*col+1]);
      pv=1.0-asin(pow(hc,0.8))*2./pi;
      hc=(epsilon*pi*pv)/fabs(Kz[col]);

      //Final Height Estimate
      hest[col]=hp+hc; //estimate of total height combining phase and coherence heights
      hest[col]=hest[col]*mask; //sets height to zero in surface regions
      } else {
      gammaH[2*col] = 0.; gammaH[2*col+1] = 0.;
      gammaL[2*col] = 0.; gammaL[2*col+1] = 0.;
      topo[col] = 0.; hest[col] = 0.;
      }
    } /*col */
  
  fwrite(&gammaH[0],sizeof(float),2*Sub_Ncol,out_gamH);
  fwrite(&gammaL[0],sizeof(float),2*Sub_Ncol,out_gamL);
  fwrite(&topo[0],sizeof(float),Sub_Ncol,out_topo);
  fwrite(&hest[0],sizeof(float),Sub_Ncol,out_hest);

  //Kv coefficient determination
  for (col = 0; col < Sub_Ncol; col++) hest[col] = hest[col]*Kz[col+Off_col]/2.;
  fwrite(&hest[0],sizeof(float),Sub_Ncol,out_Kv);
  } /*lig */

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if (strcmp(PolTypeIn,"S2")==0) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + NwinL);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + NwinL);
    }

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_gamH); fclose(out_gamL);
  fclose(out_topo); fclose(out_hest);
  fclose(out_Kv);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if (strcmp(PolTypeIn,"S2")==0)
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}




