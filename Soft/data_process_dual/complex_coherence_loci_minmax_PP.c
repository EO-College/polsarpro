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

File   : complex_coherence_loci_minmax_PP.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Marco LAVALLE
Modified : Marco Lavalle
Version  : 2.0
Creation : 1/2008
Update  : 8/2012
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

Description : Min/Max of coherence phase and magnitude

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
  char *PolTypeConf[NPolType] = {"SPPT4", "T4"};
  FILE *out_file1, *out_file2, *out_file3, *out_file4;
  char file_name[FilePathLength];
  
/* Internal variables */
  int ii, lig, col, k, l;
  int i, ks, ls, kss, lss, p;
  float theta, coh_pha_max, coh_pha_min, coh_mag_max, coh_mag_min;
//  float  *theta0, *mod0;  
  
/* Matrix arrays */
  cplx **T, **iT;
  cplx **TT11,**TT12,**TT22, **TT12p, **hTT12p;
//  cplx **iTT11,**hTT12,**iTT22;
  cplx **Tmp11,**Tmp12, **Tmp;
//  cplx **Tmp22;
  cplx **V1, **hV1;
//  cplx **V2, **hV2, **iV1, **iV2;
  float *L;
//float *phi;
  float *coh_pha, *coh_mag, *gmax2, *gmin2;

/* Matrix arrays */
  float ***S_in1;
  float ***S_in2;
  float ***M_in;
  float *Mean;
  float **M_out1;
  float **M_out2;
  float **M_out3;
  float **M_out4;
  float *Buffer;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncomplex_coherence_loci_minmax_PP.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = SPPT4\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T4\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-p   	Number of points\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  if (strcmp(PolType, "SPPT4") == 0) {
    get_commandline_prm(argc,argv,"-idm",str_cmd_prm,in_dir1,1,UsageHelp);
    get_commandline_prm(argc,argv,"-ids",str_cmd_prm,in_dir2,1,UsageHelp);
    }
  if (strcmp(PolType, "T4") == 0) {
    get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir1,1,UsageHelp);
    strcpy(in_dir2,in_dir1);
    }
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-p",int_cmd_prm,&p,1,UsageHelp);

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

/***********************************************************************
***********************************************************************/

  check_dir(in_dir1);
  if (strcmp(PolType, "SPPT4") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir1, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in1 = matrix_char(NpolarIn,1024); 
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) file_name_in2 = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir1, file_name_in1);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) init_file_name(PolTypeIn, in_dir2, file_name_in2);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
    if ((in_datafile1[Np] = fopen(file_name_in1[Np], "rb")) == NULL)
      edit_error("Could not open input file : ", file_name_in1[Np]);
      
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0))
    for (Np = 0; Np < NpolarIn; Np++)
      if ((in_datafile2[Np] = fopen(file_name_in2[Np], "rb")) == NULL)
        edit_error("Could not open input file : ", file_name_in2[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%scmplx_coh_MinMag.bin", out_dir);
  if ((out_file1 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%scmplx_coh_MaxMag.bin", out_dir);
  if ((out_file2 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%scmplx_coh_MinPha.bin", out_dir);
  if ((out_file3 = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  sprintf(file_name, "%scmplx_coh_MaxPha.bin", out_dir);
  if ((out_file4 = fopen(file_name, "wb")) == NULL)
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

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    /* Sin = NpolarIn*Nlig*2*Ncol */
    NBlockA += 2*NpolarIn*2*(Ncol+NwinC); NBlockB += 2*NpolarIn*NwinL*2*(Ncol+NwinC);
    }

  /* Min = NpolarOut*(Nlig+NwinL)*(Ncol+NwinC) */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mout = Nlig*2*Sub_Ncol : 1 to 4*/
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
  NBlockA += 2*Sub_Ncol; NBlockB += 0;
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

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    S_in1 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    S_in2 = matrix3d_float(NpolarIn, NligBlock[0] + NwinL, 2*(Ncol + NwinC));
    }

  M_in = matrix3d_float(NpolarOut, NligBlock[0] + NwinL, Ncol + NwinC);
  M_out1 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_out2 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_out3 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  M_out4 = matrix_float(NligBlock[0], 2*Sub_Ncol);
  Mean = vector_float(NpolarOut);

  coh_pha = vector_float(2*p);
  coh_mag = vector_float(2*p);
  gmin2  = vector_float(2*p);
  gmax2  = vector_float(2*p);
//  theta0 = vector_float(1);
//  mod0  = vector_float(1);
  T  = cplx_matrix(2,2);
  iT  = cplx_matrix(2,2);
  TT11  = cplx_matrix(2,2);
  TT12  = cplx_matrix(2,2);
  TT22  = cplx_matrix(2,2);
//  iTT11  = cplx_matrix(2,2);
//  hTT12  = cplx_matrix(2,2);
  TT12p  = cplx_matrix(2,2);
  hTT12p = cplx_matrix(2,2);
//  iTT22  = cplx_matrix(2,2);
  Tmp11  = cplx_matrix(2,2);
  Tmp12  = cplx_matrix(2,2);
//  Tmp22  = cplx_matrix(2,2);
  Tmp  = cplx_matrix(2,2);
  V1  = cplx_matrix(2,2);
//  iV1  = cplx_matrix(2,2);
  hV1  = cplx_matrix(2,2);
//  V2  = cplx_matrix(2,2);
//  iV2  = cplx_matrix(2,2);
//  hV2  = cplx_matrix(2,2);

  L  = vector_float(2);
//  phi  = vector_float(2);
  
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

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    read_block_SPP_noavg(in_datafile1, S_in1, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    read_block_SPP_noavg(in_datafile2, S_in2, "SPP", 2, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

    SPP_to_T4(S_in1, S_in2, M_in, NligBlock[Nb] + NwinL, Sub_Ncol + NwinC, 0, 0);

    } else {
    /* Case of T4 */
    read_block_TCI_noavg(in_datafile1, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      M_out1[lig][2*col] = 0.; M_out1[lig][2*col+1] = 0.;
      M_out2[lig][2*col] = 0.; M_out2[lig][2*col+1] = 0.;
      M_out3[lig][2*col] = 0.; M_out3[lig][2*col+1] = 0.;
      M_out4[lig][2*col] = 0.; M_out4[lig][2*col+1] = 0.;
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
      TT11[0][0].re = Mean[0];  TT11[0][0].im = 0;
      TT11[0][1].re = Mean[1];  TT11[0][1].im = Mean[2];
      TT11[1][0].re = TT11[0][1].re;  TT11[1][0].im = -TT11[0][1].im;
      TT11[1][1].re = Mean[7]; TT11[1][1].im = 0;

      TT22[0][0].re = Mean[12]; TT22[0][0].im = 0;
      TT22[0][1].re = Mean[13]; TT22[0][1].im = Mean[14];
      TT22[1][0].re = TT22[0][1].re;  TT22[1][0].im = -TT22[0][1].im;
      TT22[1][1].re = Mean[15]; TT22[1][1].im = 0;
    
      TT12[0][0].re = Mean[3];  TT12[0][0].im = Mean[4];
      TT12[0][1].re = Mean[5];  TT12[0][1].im = Mean[6];
      TT12[1][0].re = Mean[8]; TT12[1][0].im = Mean[9];
      TT12[1][1].re = Mean[10]; TT12[1][1].im = Mean[11];
  
      /* Computing Loci Min/Max (Max is numerical radius) */
      for(k=0; k<2; k++) { 
        for(l=0; l<2; l++) {
          T[k][l].re = (TT11[k][l].re + TT22[k][l].re) / 2.;
          T[k][l].im = (TT11[k][l].im + TT22[k][l].im) / 2.;
          }
        }
  
      cplx_inv_mat2(T,iT);

      for(i=0; i<p; i++) {
        theta = (float)i * pi / 180.;
        for(k=0; k<2; k++) {
          for(l=0; l<2; l++) {
            Tmp[k][l].re = 0.;
            Tmp[k][l].im = 0.;
            }
          Tmp[k][k].re = cos(theta);
          Tmp[k][k].im = sin(theta);
          }
    
        cplx_mul_mat(TT12,Tmp,TT12p,2,2);
        cplx_htransp_mat(TT12p,hTT12p,2,2);
    
        for(k=0; k<2; k++) {
          for(l=0; l<2; l++) {
            Tmp12[k][l].re = (TT12p[k][l].re + hTT12p[k][l].re) / 2.;
            Tmp12[k][l].im = (TT12p[k][l].im + hTT12p[k][l].im) / 2.;
            }
          }

        cplx_mul_mat(iT,Tmp12,Tmp,2,2);
        cplx_diag_mat2(Tmp,V1,L);
  
        cplx_htransp_mat(V1,hV1,2,2);
  
        cplx_mul_mat(TT12,V1,Tmp,2,2);
        cplx_mul_mat(hV1,Tmp,Tmp12,2,2);
    
        cplx_mul_mat(T,V1,Tmp,2,2);
        cplx_mul_mat(hV1,Tmp,Tmp11,2,2);
  
        gmax2[2*i]  = Tmp12[0][0].re / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp11[0][0]));
        gmax2[2*i+1] = Tmp12[0][0].im / sqrt(cmod(Tmp11[0][0]) * cmod(Tmp11[0][0]));
        gmin2[2*i]  = Tmp12[1][1].re / sqrt(cmod(Tmp11[1][1]) * cmod(Tmp11[1][1]));
        gmin2[2*i+1] = Tmp12[1][1].im / sqrt(cmod(Tmp11[1][1]) * cmod(Tmp11[1][1]));
        }

      for (k=0; k<p; k++) {
        coh_pha[k]  = atan2(gmax2[2*k+1], gmax2[2*k]);
        coh_pha[k+p] = atan2(gmin2[2*k+1], gmin2[2*k]);
        coh_mag[k]  = sqrt(gmax2[2*k]*gmax2[2*k] + gmax2[2*k+1]*gmax2[2*k+1]);
        coh_mag[k+p] = sqrt(gmin2[2*k]*gmin2[2*k] + gmin2[2*k+1]*gmin2[2*k+1]);
        }

      coh_mag_min = 1.;
      coh_mag_max = 0.;
      coh_pha_min =  pi;
      coh_pha_max = -pi;
  
      for (k=0; k<2*p; k++) {
        if (coh_mag[k]<coh_mag_min) { coh_mag_min = coh_mag[k]; lss=k; }
        if (coh_mag[k]>coh_mag_max) { coh_mag_max = coh_mag[k]; kss=k; }
        if (coh_pha[k]<coh_pha_min) { coh_pha_min = coh_pha[k]; ls=k;  }
        if (coh_pha[k]>coh_pha_max) { coh_pha_max = coh_pha[k]; ks=k;  }
        }
    
      M_out1[lig][2*col] = coh_mag[lss]*cos(coh_pha[lss]);
      M_out1[lig][2*col+1] = coh_mag[lss]*sin(coh_pha[lss]);
      if(isnan(M_out1[lig][2*col])+isnan(M_out1[lig][2*col+1])) {
        M_out1[lig][2*col]=1.; M_out1[lig][2*col+1]=0.;
        }

      M_out2[lig][2*col] = coh_mag[kss]*cos(coh_pha[kss]);
      M_out2[lig][2*col+1] = coh_mag[kss]*sin(coh_pha[kss]);
      if(isnan(M_out2[lig][2*col])+isnan(M_out2[lig][2*col+1])) {
        M_out2[lig][2*col]=1.; M_out2[lig][2*col+1]=0.;
        }
    
      M_out3[lig][2*col] = coh_mag[ls]*cos(coh_pha[ls]);
      M_out3[lig][2*col+1] = coh_mag[ls]*sin(coh_pha[ls]);
      if(isnan(M_out3[lig][2*col])+isnan(M_out3[lig][2*col+1])) {
        M_out3[lig][2*col]=1.; M_out3[lig][2*col+1]=0.;
        }

      M_out4[lig][2*col] = coh_mag[ks]*cos(coh_pha[ks]);
      M_out4[lig][2*col+1] = coh_mag[ks]*sin(coh_pha[ks]);
      if(isnan(M_out4[lig][2*col])+isnan(M_out4[lig][2*col+1])) {
        M_out4[lig][2*col]=1.; M_out4[lig][2*col+1]=0.;
        }
        }
      }    /*col */
    }

  write_block_matrix_float(out_file1, M_out1, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);
  write_block_matrix_float(out_file2, M_out2, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);
  write_block_matrix_float(out_file3, M_out3, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);
  write_block_matrix_float(out_file4, M_out4, NligBlock[Nb], 2*Sub_Ncol, 0, 0, 2*Sub_Ncol);

  } // NbBlock

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
    free_matrix3d_float(S_in1, NpolarIn, NligBlock[0] + NwinL);
    free_matrix3d_float(S_in2, NpolarIn, NligBlock[0] + NwinL);
    }

  free_matrix3d_float(M_in, NpolarOut, NligBlock[0] + NwinL);
  free_matrix_float(M_out1, NligBlock[0]);
  free_matrix_float(M_out2, NligBlock[0]);
  free_matrix_float(M_out3, NligBlock[0]);
  free_matrix_float(M_out4, NligBlock[0]);
  free_vector_float(Mean);
*/  
/********************************************************************
********************************************************************/
/* OUTPUT FILE CLOSING*/
  fclose(out_file1); fclose(out_file2);
  fclose(out_file3); fclose(out_file4);

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile1[Np]);
  if ((strcmp(PolTypeIn,"SPP") == 0) 
    || (strcmp(PolTypeIn,"SPPpp1") == 0)
    || (strcmp(PolTypeIn,"SPPpp2") == 0)
    || (strcmp(PolTypeIn,"SPPpp3") == 0))
    for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile2[Np]);

/********************************************************************
********************************************************************/

  return 1;
}




