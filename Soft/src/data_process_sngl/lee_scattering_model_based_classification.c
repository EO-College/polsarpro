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

File  : lee_scattering_model_based_classification.c
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

Description :  J.S. Lee Scattering Model Based Classification

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

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void MinMaxContrastMedianNN(float *mat,float *min,float *max,int Npts, int NN);

/* Matrix arrays */
  float *datatmpS;
  float *datatmpD;
  float *datatmpV;

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
  FILE *in_odd, *in_dbl, *in_vol;
  FILE *classif_file, *colormapS, *colormapD, *colormapV, *colormap;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "T3"};
  char file_name[FilePathLength], odd_file[FilePathLength], dbl_file[FilePathLength], vol_file[FilePathLength], Tmp[FilePathLength];
  char ColorMapSingle[FilePathLength], ColorMapDouble[FilePathLength], ColorMapRandom[FilePathLength], ColorMap[FilePathLength];

/* Internal variables */
  int odd = 0;
  int dbl = 1;
  int vol = 2;
  int ii, jj, k, l, lig, col;
  int ligDone = 0;

  int Ind, FlagStop, merging;
  int FlagDetermination, FlagDeterminationS;
  int FlagDeterminationD, FlagDeterminationV;
  int Ncluster, Ncluster100, NclusterS, NclusterD, NclusterV;
  int NclusterSfin, NclusterDfin, NclusterVfin;
  int NN, NNS, NND, NNV, NptS, NptD, NptV, NptsTot;
  int Area, AreaSsNc, AreaDsNc, AreaVsNc;
  int PsNptsTot, PdNptsTot, PvNptsTot; 
  float Power, PsMin, PsMax, PdMin, PdMax, PvMin, PvMax,dt[2];
  float mixed_threshold, dist;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float **M_odd;
  float **M_dbl;
  float **M_vol;
  float ***TT, ***TTm1;
  float *PsSeuil, *PdSeuil, *PvSeuil;
  float *PsNpts, *PdNpts, *PvNpts;
  float ***MM, ***MMm1;
  float **dett;
  float **Dist;
  int *PsHisto, *PdHisto, *PvHisto;

  int Bmp_flag;
  int Npp, Nligg, ligg;
  int zone, area, Narea;
  int Nit_max;
  int Flag_stop, Nit;
  float Pct_switch_min;
  float Modif, dist_min;

/* Matrix arrays */
  float ***coh;
  float ***coh_m1;
  float *coh_area[4][4][2];
  float *coh_area_m1[4][4][2];
  float *det_area[2];
  float *det;
  float **Class_im;
  float cpt_area[100];
  float distance[100];

  float *coh_area_S[4][4][2];
  float cpt_area_S[100];
  float *coh_area_D[4][4][2];
  float cpt_area_D[100];
  float *coh_area_V[4][4][2];
  float cpt_area_V[100];

  int NbreColor, red[256], green[256], blue[256];
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nlee_scattering_model_based_classification.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-isf 	input single bounce file\n");
strcat(UsageHelp," (string)	-idf 	input double bounce file\n");
strcat(UsageHelp," (string)	-irf 	input random bounce file\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ncl 	Cluster number\n");
strcat(UsageHelp," (int)   	-fscn	Final single bounce cluster number\n");
strcat(UsageHelp," (int)   	-fdcn	Final double bounce cluster number\n");
strcat(UsageHelp," (int)   	-fvcn	Final random bounce cluster number\n");
strcat(UsageHelp," (float) 	-mct 	Mixed Scattering Category threshold\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nit 	maximum interation number\n");
strcat(UsageHelp," (float) 	-pct 	maximum of pixel switching classes\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (0/1)\n");
strcat(UsageHelp," (string)	-cms 	input single bounce - colormap file (valid if BMP flag = 1)\n");
strcat(UsageHelp," (string)	-cmd 	input double bounce - colormap file (valid if BMP flag = 1)\n");
strcat(UsageHelp," (string)	-cmr 	input double bounce - colormap file (valid if BMP flag = 1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
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

if(argc < 41) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-isf",str_cmd_prm,odd_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,dbl_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-irf",str_cmd_prm,vol_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ncl",int_cmd_prm,&Ncluster,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fscn",int_cmd_prm,&NclusterSfin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fdcn",int_cmd_prm,&NclusterDfin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fvcn",int_cmd_prm,&NclusterVfin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mct",flt_cmd_prm,&mixed_threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nit",int_cmd_prm,&Nit_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pct",flt_cmd_prm,&Pct_switch_min,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&Bmp_flag,1,UsageHelp);
  if (Bmp_flag == 1) {
  get_commandline_prm(argc,argv,"-cms",str_cmd_prm,ColorMapSingle,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cmd",str_cmd_prm,ColorMapDouble,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cmr",str_cmd_prm,ColorMapRandom,1,UsageHelp);
  }

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

  if (strcmp(PolType,"S2")==0) strcpy(PolType,"S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  Ncluster100 = 100*Ncluster;
  
  Pct_switch_min = Pct_switch_min / 100.;
  if (Bmp_flag != 0) Bmp_flag = 1;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
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

  if ((in_odd = fopen(odd_file, "rb")) == NULL)
    edit_error("Could not open input file : ", odd_file);

  if ((in_dbl = fopen(dbl_file, "rb")) == NULL)
    edit_error("Could not open input file : ", dbl_file);

  if ((in_vol = fopen(vol_file, "rb")) == NULL)
    edit_error("Could not open input file : ", vol_file);
      
/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s%dx%d%s", out_dir, "scattering_model_based_classification_", NwinL, NwinC, ".bin");
  if ((classif_file = fopen(file_name, "wb")) == NULL)
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

  /* Modd = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mdbl = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  /* Mvol = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol; NBlockB += 0;
  
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;

  /* ClassIm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  
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
  M_odd = matrix_float(NligBlock[0], Sub_Ncol);
  M_dbl = matrix_float(NligBlock[0], Sub_Ncol);
  M_vol = matrix_float(NligBlock[0], Sub_Ncol);
  Class_im = matrix_float(Sub_Nlig, Sub_Ncol);
  
  TTm1 = matrix3d_float(3, 3, 2);
  
  datatmpS = vector_float(Sub_Nlig*Sub_Ncol);
  datatmpD = vector_float(Sub_Nlig*Sub_Ncol);
  datatmpV = vector_float(Sub_Nlig*Sub_Ncol);
  PsHisto = vector_int(Ncluster100+1);
  PdHisto = vector_int(Ncluster100+1);
  PvHisto = vector_int(Ncluster100+1);
  PsSeuil = vector_float(Ncluster+1);
  PdSeuil = vector_float(Ncluster+1);
  PvSeuil = vector_float(Ncluster+1);
  PsNpts = vector_float(Ncluster+1);
  PdNpts = vector_float(Ncluster+1);
  PvNpts = vector_float(Ncluster+1);
  MM = matrix3d_float(3,Ncluster+1,NpolarOut);
  MMm1 = matrix3d_float(3,Ncluster+1,NpolarOut);
  dett = matrix_float(3,Ncluster+1);
  Dist = matrix_float(Ncluster+1,Ncluster+1);
  
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
/* Odd Dbl and Vol */
FlagDetermination = 0; FlagDeterminationS = 0; 
FlagDeterminationD = 0; FlagDeterminationV = 0; 
NNS = 3; NND = 3; NNV = 3;

while (FlagDetermination == 0) {

/* Min/Max DETERMINATION */
rewind(in_odd); rewind(in_dbl); rewind(in_vol);
if (FlagValid == 1) rewind(in_valid);

NptS = -1; NptD = -1; NptV = -1;
PsMin = INIT_MINMAX; PsMax = -INIT_MINMAX;
PdMin = INIT_MINMAX; PdMax = -INIT_MINMAX;
PvMin = INIT_MINMAX; PvMax = -INIT_MINMAX;
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if (my_isfinite(Power) != 0) {
          if (FlagDeterminationS == 0) {
            if ((Power == M_odd[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
              NptS++;
              datatmpS[NptS] = M_odd[lig][col];
              }
            }
          if (FlagDeterminationD == 0) {
            if ((Power == M_dbl[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
              NptD++;
              datatmpD[NptD] = M_dbl[lig][col];
              }
            }
          if (FlagDeterminationV == 0) {
            if ((Power == M_vol[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
              NptV++;
              datatmpV[NptV] = M_vol[lig][col];
              }
            }
          }
        } /* valid */
      } /* col */
    } /* lig */
  } // NbBlock

  NptS++; NptD++; NptV++;

#pragma omp parallel sections
{
  #pragma omp section
  {
  if (FlagDeterminationS == 0) MinMaxContrastMedianNN(datatmpS, &PsMin, &PsMax, NptS, NNS);
  }
  #pragma omp section
  {
  if (FlagDeterminationD == 0) MinMaxContrastMedianNN(datatmpD, &PdMin, &PdMax, NptD, NND);
  }
  #pragma omp section
  {
  if (FlagDeterminationV  == 0) MinMaxContrastMedianNN(datatmpV, &PvMin, &PvMax, NptV, NNV);
  }
}
  
  if (FlagDeterminationS == 0) {
    PsMin = eps;
    AreaSsNc = (int)(NptS / Ncluster);
    }
  if (FlagDeterminationD == 0) {
    PdMin = eps;
    AreaDsNc = (int)(NptD / Ncluster);
    }
  if (FlagDeterminationV == 0) {
    PvMin = eps;
    AreaVsNc = (int)(NptV / Ncluster);
    }
  
/********************************************************************
********************************************************************/
/* Histograms Odd / Dbl / Vol DETERMINATION */
rewind(in_odd); rewind(in_dbl); rewind(in_vol);
if (FlagValid == 1) rewind(in_valid);

for (ii = 0; ii <= Ncluster100; ii++) {
  PsHisto[ii] = 0; PdHisto[ii] = 0; PvHisto[ii] = 0;
  }

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if (FlagDeterminationS == 0) {
          if ((Power == M_odd[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
            Ind = (int)(Ncluster100*(M_odd[lig][col]-PsMin)/(PsMax - PsMin));
            if (Ind < 0) Ind = 0; if (Ncluster100 <= Ind) Ind = Ncluster100;
            PsHisto[Ind]++;
            }
          }
        if (FlagDeterminationD == 0) {
          if ((Power == M_dbl[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
            Ind = (int)(Ncluster100*(M_dbl[lig][col]-PdMin)/(PdMax - PdMin));
            if (Ind < 0) Ind = 0; if (Ncluster100 <= Ind) Ind = Ncluster100;
            PdHisto[Ind]++;
            }
          }
        if (FlagDeterminationV == 0) {
          if ((Power == M_vol[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
            Ind = (int)(Ncluster100*(M_vol[lig][col]-PvMin)/(PvMax - PvMin));
            if (Ind < 0) Ind = 0; if (Ncluster100 <= Ind) Ind = Ncluster100;
            PvHisto[Ind]++;
            }
          }
        }
      }
    }
  } // NbBlock
  
  if (FlagDeterminationS == 0) {
    if (PsHisto[Ncluster100] <= (int)(0.05*NptS)) {
      FlagDeterminationS = 1;
      } else {
      NNS++;
      }
    }
  if (FlagDeterminationD == 0) {
    if (PdHisto[Ncluster100] <= (int)(0.05*NptD)) {
      FlagDeterminationD = 1;
      } else {
      NND++;
      }
    }
  if (FlagDeterminationV == 0) {
    if (PvHisto[Ncluster100] <= (int)(0.05*NptV)) {
      FlagDeterminationV = 1;
      } else {
      NNV++;
      }
    }
  FlagDetermination = FlagDeterminationS*FlagDeterminationD*FlagDeterminationV;  
  } // Flag Determination Histogram
 
/********************************************************************
********************************************************************/
/* Histogrammes - Thresholds DETERMINATION */

/* Single Bounce */
jj = 0; NN = 0;
for (ii = 0; ii < Ncluster; ii++) {
  Area = 0.; FlagStop = 0; 
  while (FlagStop == 0) {
    if (((Area + PsHisto[jj]) >= AreaSsNc)||(jj == Ncluster100)) {
      FlagStop = 1;
      } else {
      Area += PsHisto[jj];
      jj++;
      }
    }
  NN += Area;
  PsSeuil[ii] = PsMin + jj*(PsMax-PsMin)/(Ncluster100);
  }
PsSeuil[Ncluster] = PsMax;

/* Double Bounce */
jj = 0; NN = 0;
for (ii = 0; ii < Ncluster; ii++) {
  Area = 0.; FlagStop = 0; 
  while (FlagStop == 0) {
    if (((Area + PdHisto[jj]) >= AreaDsNc)||(jj == Ncluster100)) {
      FlagStop = 1;
      } else {
      Area += PdHisto[jj];
      jj++;
      }
    }
  NN += Area;
  PdSeuil[ii] = PdMin + jj*(PdMax-PdMin)/(Ncluster100);
  }
PdSeuil[Ncluster] = PdMax;

/* Random Bounce */
jj = 0; NN = 0;
for (ii = 0; ii < Ncluster; ii++) {
  Area = 0.; FlagStop = 0; 
  while (FlagStop == 0) {
    if (((Area + PvHisto[jj]) >= AreaVsNc)||(jj == Ncluster100)) {
      FlagStop = 1;
      } else {
      Area += PvHisto[jj];
      jj++;
      }
    }
  NN += Area;
  PvSeuil[ii] = PvMin + jj*(PvMax-PvMin)/(Ncluster100);
  }
PvSeuil[Ncluster] = PvMax;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
/* Center Cluster DETERMINATION */
for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
rewind(in_odd); rewind(in_dbl); rewind(in_vol);
if (FlagValid == 1) rewind(in_valid);

for (ii = 0; ii <= Ncluster; ii++) {
  PsNpts[ii] = 0.; PdNpts[ii] = 0.; PvNpts[ii] = 0.;
  for (Np = 0; Np < NpolarOut; Np++) {
    MM[odd][ii][Np] = 0.; MM[dbl][ii][Np] = 0.; MM[vol][ii][Np] = 0.;
    }
  }

M_avg = matrix_float(NpolarOut,Sub_Ncol);
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
  read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Sub_Ncol);
  }
  
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_odd[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          if (PsMax <= M_odd[lig][col]) {
            for (Np = 0; Np < NpolarOut; Np++) MM[odd][Ncluster][Np] += M_avg[Np][col];
            PsNpts[Ncluster] = PsNpts[Ncluster] + 1.;       
            } else {
            FlagStop = 0; ii = -1;
            while (FlagStop == 0) {
              ii++;
              if ((M_odd[lig][col] <= PsSeuil[ii])||(ii == Ncluster)) FlagStop = 1;
              }
            for (Np = 0; Np < NpolarOut; Np++) MM[odd][ii][Np] += M_avg[Np][col];
            PsNpts[ii] = PsNpts[ii] + 1.;       
            }
          }
          
        if ((Power == M_dbl[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          if (PdMax <= M_dbl[lig][col]) {
            for (Np = 0; Np < NpolarOut; Np++) MM[dbl][Ncluster][Np] += M_avg[Np][col];
            PdNpts[Ncluster] = PdNpts[Ncluster] + 1.;       
            } else {
            FlagStop = 0; ii = -1;
            while (FlagStop == 0) {
              ii++;
              if ((M_dbl[lig][col] <= PdSeuil[ii])||(ii == Ncluster)) FlagStop = 1;
              }
            for (Np = 0; Np < NpolarOut; Np++) MM[dbl][ii][Np] += M_avg[Np][col];
            PdNpts[ii] = PdNpts[ii] + 1.;       
            }
          }
          
        if ((Power == M_vol[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          if (PvMax <= M_vol[lig][col]) {
            for (Np = 0; Np < NpolarOut; Np++) MM[vol][Ncluster][Np] += M_avg[Np][col];
            PvNpts[Ncluster] = PvNpts[Ncluster] + 1.;       
            } else {
            FlagStop = 0; ii = -1;
            while (FlagStop == 0) {
              ii++;
              if ((M_vol[lig][col] <= PvSeuil[ii])||(ii == Ncluster)) FlagStop = 1;
              }
            for (Np = 0; Np < NpolarOut; Np++) MM[vol][ii][Np] += M_avg[Np][col];
            PvNpts[ii] = PvNpts[ii] + 1.;       
            }
          }
        } /* valid */
      } /* col */
    } /* lig */
  } // NbBlock

for (ii = 0; ii <= Ncluster; ii++) {
  for (Np = 0; Np < NpolarOut; Np++) {
    MM[odd][ii][Np] = MM[odd][ii][Np] / PsNpts[ii];
    MM[dbl][ii][Np] = MM[dbl][ii][Np] / PdNpts[ii];
    MM[vol][ii][Np] = MM[vol][ii][Np] / PvNpts[ii];
    }
  }    
  
free_matrix_float(M_avg,NpolarOut);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
/* Center Cluster MERGING */

TT = matrix3d_float(3, 3, 2);

/* Single Bounce */
FlagStop = 0; NclusterS = Ncluster;
while (FlagStop == 0) {
  merging = 0;
  for (ii = 0; ii <= NclusterS; ii++) {
    TT[0][0][0] = MM[odd][ii][T311];TT[0][0][1] = 0.;
    TT[0][1][0] = MM[odd][ii][T312_re];TT[0][1][1] = MM[odd][ii][T312_im];
    TT[0][2][0] = MM[odd][ii][T313_re];TT[0][2][1] = MM[odd][ii][T313_im];
    TT[1][0][0] = MM[odd][ii][T312_re];TT[1][0][1] = -MM[odd][ii][T312_im];
    TT[1][1][0] = MM[odd][ii][T322];TT[1][1][1] = 0.;
    TT[1][2][0] = MM[odd][ii][T323_re];TT[1][2][1] = MM[odd][ii][T323_im];
    TT[2][0][0] = MM[odd][ii][T313_re];TT[2][0][1] = -MM[odd][ii][T313_im];
    TT[2][1][0] = MM[odd][ii][T323_re];TT[2][1][1] = -MM[odd][ii][T323_im];
    TT[2][2][0] = MM[odd][ii][T333];TT[2][2][1] = 0.;
    InverseHermitianMatrix3(TT, TTm1);
    DeterminantHermitianMatrix3(TT, dt); dett[odd][ii] = dt[0];
    MMm1[odd][ii][T311] = TTm1[0][0][0];
    MMm1[odd][ii][T312_re] = TTm1[0][1][0]; MMm1[odd][ii][T312_im] = TTm1[0][1][1];
    MMm1[odd][ii][T313_re] = TTm1[0][2][0]; MMm1[odd][ii][T313_im] = TTm1[0][2][1];
    MMm1[odd][ii][T322] = TTm1[1][1][0];
    MMm1[odd][ii][T323_re] = TTm1[1][2][0]; MMm1[odd][ii][T323_im] = TTm1[1][2][1];
    MMm1[odd][ii][T333] = TTm1[2][2][0];
    }
    
  for (ii = 0; ii < NclusterS; ii++) {
    for (jj = ii+1; jj <= NclusterS; jj++) {
      Dist[ii][jj] = 0.5*(log(dett[odd][ii]+eps)+log(dett[odd][jj]+eps));
      
      TTm1[0][0][0] = MMm1[odd][ii][T311];TTm1[0][0][1] = 0.;
      TTm1[0][1][0] = MMm1[odd][ii][T312_re];TTm1[0][1][1] = MMm1[odd][ii][T312_im];
      TTm1[0][2][0] = MMm1[odd][ii][T313_re];TTm1[0][2][1] = MMm1[odd][ii][T313_im];
      TTm1[1][0][0] = MMm1[odd][ii][T312_re];TTm1[1][0][1] = -MMm1[odd][ii][T312_im];
      TTm1[1][1][0] = MMm1[odd][ii][T322];TTm1[1][1][1] = 0.;
      TTm1[1][2][0] = MMm1[odd][ii][T323_re];TTm1[1][2][1] = MMm1[odd][ii][T323_im];
      TTm1[2][0][0] = MMm1[odd][ii][T313_re];TTm1[2][0][1] = -MMm1[odd][ii][T313_im];
      TTm1[2][1][0] = MMm1[odd][ii][T323_re];TTm1[2][1][1] = -MMm1[odd][ii][T323_im];
      TTm1[2][2][0] = MMm1[odd][ii][T333];TTm1[2][2][1] = 0.;
      
      TT[0][0][0] = MM[odd][jj][T311];TT[0][0][1] = 0.;
      TT[0][1][0] = MM[odd][jj][T312_re];TT[0][1][1] = MM[odd][jj][T312_im];
      TT[0][2][0] = MM[odd][jj][T313_re];TT[0][2][1] = MM[odd][jj][T313_im];
      TT[1][0][0] = MM[odd][jj][T312_re];TT[1][0][1] = -MM[odd][jj][T312_im];
      TT[1][1][0] = MM[odd][jj][T322];TT[1][1][1] = 0.;
      TT[1][2][0] = MM[odd][jj][T323_re];TT[1][2][1] = MM[odd][jj][T323_im];
      TT[2][0][0] = MM[odd][jj][T313_re];TT[2][0][1] = -MM[odd][jj][T313_im];
      TT[2][1][0] = MM[odd][jj][T323_re];TT[2][1][1] = -MM[odd][jj][T323_im];
      TT[2][2][0] = MM[odd][jj][T333];TT[2][2][1] = 0.;
      Dist[ii][jj] = Dist[ii][jj] + 0.5*Trace3_HM1xHM2(TTm1,TT);
      
      TTm1[0][0][0] = MMm1[odd][jj][T311];TTm1[0][0][1] = 0.;
      TTm1[0][1][0] = MMm1[odd][jj][T312_re];TTm1[0][1][1] = MMm1[odd][jj][T312_im];
      TTm1[0][2][0] = MMm1[odd][jj][T313_re];TTm1[0][2][1] = MMm1[odd][jj][T313_im];
      TTm1[1][0][0] = MMm1[odd][jj][T312_re];TTm1[1][0][1] = -MMm1[odd][jj][T312_im];
      TTm1[1][1][0] = MMm1[odd][jj][T322];TTm1[1][1][1] = 0.;
      TTm1[1][2][0] = MMm1[odd][jj][T323_re];TTm1[1][2][1] = MMm1[odd][jj][T323_im];
      TTm1[2][0][0] = MMm1[odd][jj][T313_re];TTm1[2][0][1] = -MMm1[odd][jj][T313_im];
      TTm1[2][1][0] = MMm1[odd][jj][T323_re];TTm1[2][1][1] = -MMm1[odd][jj][T323_im];
      TTm1[2][2][0] = MMm1[odd][jj][T333];TTm1[2][2][1] = 0.;
      
      TT[0][0][0] = MM[odd][ii][T311];TT[0][0][1] = 0.;
      TT[0][1][0] = MM[odd][ii][T312_re];TT[0][1][1] = MM[odd][ii][T312_im];
      TT[0][2][0] = MM[odd][ii][T313_re];TT[0][2][1] = MM[odd][ii][T313_im];
      TT[1][0][0] = MM[odd][ii][T312_re];TT[1][0][1] = -MM[odd][ii][T312_im];
      TT[1][1][0] = MM[odd][ii][T322];TT[1][1][1] = 0.;
      TT[1][2][0] = MM[odd][ii][T323_re];TT[1][2][1] = MM[odd][ii][T323_im];
      TT[2][0][0] = MM[odd][ii][T313_re];TT[2][0][1] = -MM[odd][ii][T313_im];
      TT[2][1][0] = MM[odd][ii][T323_re];TT[2][1][1] = -MM[odd][ii][T323_im];
      TT[2][2][0] = MM[odd][ii][T333];TT[2][2][1] = 0.;
      Dist[ii][jj] = Dist[ii][jj] + 0.5*Trace3_HM1xHM2(TTm1,TT);
      }
    }    

  dist = INIT_MINMAX;
  for (ii = 0; ii < NclusterS; ii++) {
    for (jj = ii+1; jj <= NclusterS; jj++) {
      if (Dist[ii][jj] < dist) {
        NptsTot = PsNpts[ii] + PsNpts[jj];
        //if (NptsTot < (2.*Sub_Nlig*Sub_Ncol/NclusterSfin)) {
        if (NptsTot < (2.*NptS/NclusterSfin)) {
          dist = Dist[ii][jj];
          k = ii; l = jj;
          merging = 1;
          }
        }      
      }
    }    
  
  if (merging == 1) {
    for (Np = 0; Np < NpolarOut; Np++) 
      MM[odd][k][Np] = (PsNpts[k]*MM[odd][k][Np]+PsNpts[l]*MM[odd][l][Np])/(PsNpts[k]+PsNpts[l]);
    PsNpts[k] = PsNpts[k]+PsNpts[l];
    for (ii = l; ii < NclusterS; ii++) {
      for (Np = 0; Np < NpolarOut; Np++) MM[odd][ii][Np] = MM[odd][ii+1][Np];
      PsNpts[ii] = PsNpts[ii+1];
      }
    NclusterS = NclusterS -1;
    }
  if ((NclusterS == NclusterSfin-1)||(merging == 0)) FlagStop = 1;
  }

/* Double Bounce */
FlagStop = 0; NclusterD = Ncluster;
while (FlagStop == 0) {
  merging = 0;
  for (ii = 0; ii <= NclusterD; ii++) {
    TT[0][0][0] = MM[dbl][ii][T311];TT[0][0][1] = 0.;
    TT[0][1][0] = MM[dbl][ii][T312_re];TT[0][1][1] = MM[dbl][ii][T312_im];
    TT[0][2][0] = MM[dbl][ii][T313_re];TT[0][2][1] = MM[dbl][ii][T313_im];
    TT[1][0][0] = MM[dbl][ii][T312_re];TT[1][0][1] = -MM[dbl][ii][T312_im];
    TT[1][1][0] = MM[dbl][ii][T322];TT[1][1][1] = 0.;
    TT[1][2][0] = MM[dbl][ii][T323_re];TT[1][2][1] = MM[dbl][ii][T323_im];
    TT[2][0][0] = MM[dbl][ii][T313_re];TT[2][0][1] = -MM[dbl][ii][T313_im];
    TT[2][1][0] = MM[dbl][ii][T323_re];TT[2][1][1] = -MM[dbl][ii][T323_im];
    TT[2][2][0] = MM[dbl][ii][T333];TT[2][2][1] = 0.;
    InverseHermitianMatrix3(TT, TTm1);
    DeterminantHermitianMatrix3(TT, dt); dett[dbl][ii] = dt[0];
    MMm1[dbl][ii][T311] = TTm1[0][0][0];
    MMm1[dbl][ii][T312_re] = TTm1[0][1][0]; MMm1[dbl][ii][T312_im] = TTm1[0][1][1];
    MMm1[dbl][ii][T313_re] = TTm1[0][2][0]; MMm1[dbl][ii][T313_im] = TTm1[0][2][1];
    MMm1[dbl][ii][T322] = TTm1[1][1][0];
    MMm1[dbl][ii][T323_re] = TTm1[1][2][0]; MMm1[dbl][ii][T323_im] = TTm1[1][2][1];
    MMm1[dbl][ii][T333] = TTm1[2][2][0];
    }
    
  for (ii = 0; ii < NclusterD; ii++) {
    for (jj = ii+1; jj <= NclusterD; jj++) {
      Dist[ii][jj] = 0.5*(log(dett[dbl][ii]+eps)+log(dett[dbl][jj]+eps));
      
      TTm1[0][0][0] = MMm1[dbl][ii][T311];TTm1[0][0][1] = 0.;
      TTm1[0][1][0] = MMm1[dbl][ii][T312_re];TTm1[0][1][1] = MMm1[dbl][ii][T312_im];
      TTm1[0][2][0] = MMm1[dbl][ii][T313_re];TTm1[0][2][1] = MMm1[dbl][ii][T313_im];
      TTm1[1][0][0] = MMm1[dbl][ii][T312_re];TTm1[1][0][1] = -MMm1[dbl][ii][T312_im];
      TTm1[1][1][0] = MMm1[dbl][ii][T322];TTm1[1][1][1] = 0.;
      TTm1[1][2][0] = MMm1[dbl][ii][T323_re];TTm1[1][2][1] = MMm1[dbl][ii][T323_im];
      TTm1[2][0][0] = MMm1[dbl][ii][T313_re];TTm1[2][0][1] = -MMm1[dbl][ii][T313_im];
      TTm1[2][1][0] = MMm1[dbl][ii][T323_re];TTm1[2][1][1] = -MMm1[dbl][ii][T323_im];
      TTm1[2][2][0] = MMm1[dbl][ii][T333];TTm1[2][2][1] = 0.;
      
      TT[0][0][0] = MM[dbl][jj][T311];TT[0][0][1] = 0.;
      TT[0][1][0] = MM[dbl][jj][T312_re];TT[0][1][1] = MM[dbl][jj][T312_im];
      TT[0][2][0] = MM[dbl][jj][T313_re];TT[0][2][1] = MM[dbl][jj][T313_im];
      TT[1][0][0] = MM[dbl][jj][T312_re];TT[1][0][1] = -MM[dbl][jj][T312_im];
      TT[1][1][0] = MM[dbl][jj][T322];TT[1][1][1] = 0.;
      TT[1][2][0] = MM[dbl][jj][T323_re];TT[1][2][1] = MM[dbl][jj][T323_im];
      TT[2][0][0] = MM[dbl][jj][T313_re];TT[2][0][1] = -MM[dbl][jj][T313_im];
      TT[2][1][0] = MM[dbl][jj][T323_re];TT[2][1][1] = -MM[dbl][jj][T323_im];
      TT[2][2][0] = MM[dbl][jj][T333];TT[2][2][1] = 0.;
      Dist[ii][jj] = Dist[ii][jj] + 0.5*Trace3_HM1xHM2(TTm1,TT);
      
      TTm1[0][0][0] = MMm1[dbl][jj][T311];TTm1[0][0][1] = 0.;
      TTm1[0][1][0] = MMm1[dbl][jj][T312_re];TTm1[0][1][1] = MMm1[dbl][jj][T312_im];
      TTm1[0][2][0] = MMm1[dbl][jj][T313_re];TTm1[0][2][1] = MMm1[dbl][jj][T313_im];
      TTm1[1][0][0] = MMm1[dbl][jj][T312_re];TTm1[1][0][1] = -MMm1[dbl][jj][T312_im];
      TTm1[1][1][0] = MMm1[dbl][jj][T322];TTm1[1][1][1] = 0.;
      TTm1[1][2][0] = MMm1[dbl][jj][T323_re];TTm1[1][2][1] = MMm1[dbl][jj][T323_im];
      TTm1[2][0][0] = MMm1[dbl][jj][T313_re];TTm1[2][0][1] = -MMm1[dbl][jj][T313_im];
      TTm1[2][1][0] = MMm1[dbl][jj][T323_re];TTm1[2][1][1] = -MMm1[dbl][jj][T323_im];
      TTm1[2][2][0] = MMm1[dbl][jj][T333];TTm1[2][2][1] = 0.;
      
      TT[0][0][0] = MM[dbl][ii][T311];TT[0][0][1] = 0.;
      TT[0][1][0] = MM[dbl][ii][T312_re];TT[0][1][1] = MM[dbl][ii][T312_im];
      TT[0][2][0] = MM[dbl][ii][T313_re];TT[0][2][1] = MM[dbl][ii][T313_im];
      TT[1][0][0] = MM[dbl][ii][T312_re];TT[1][0][1] = -MM[dbl][ii][T312_im];
      TT[1][1][0] = MM[dbl][ii][T322];TT[1][1][1] = 0.;
      TT[1][2][0] = MM[dbl][ii][T323_re];TT[1][2][1] = MM[dbl][ii][T323_im];
      TT[2][0][0] = MM[dbl][ii][T313_re];TT[2][0][1] = -MM[dbl][ii][T313_im];
      TT[2][1][0] = MM[dbl][ii][T323_re];TT[2][1][1] = -MM[dbl][ii][T323_im];
      TT[2][2][0] = MM[dbl][ii][T333];TT[2][2][1] = 0.;
      Dist[ii][jj] = Dist[ii][jj] + 0.5*Trace3_HM1xHM2(TTm1,TT);
      }
    }    

  dist = INIT_MINMAX;
  for (ii = 0; ii < NclusterD; ii++) {
    for (jj = ii+1; jj <= NclusterD; jj++) {
      if (Dist[ii][jj] < dist) {
        NptsTot = PdNpts[ii] + PdNpts[jj];
        //if (NptsTot < (2.*Sub_Nlig*Sub_Ncol/NclusterDfin)) {
        if (NptsTot < (2.*NptD/NclusterDfin)) {
          dist = Dist[ii][jj];
          k = ii; l = jj;
          merging = 1;
          }
        }      
      }
    }    
  
  if (merging == 1) {
    for (Np = 0; Np < NpolarOut; Np++) 
      MM[dbl][k][Np] = (PdNpts[k]*MM[dbl][k][Np]+PdNpts[l]*MM[dbl][l][Np])/(PdNpts[k]+PdNpts[l]);
    PdNpts[k] = PdNpts[k]+PdNpts[l];
    for (ii = l; ii < NclusterD; ii++) {
      for (Np = 0; Np < NpolarOut; Np++) MM[dbl][ii][Np] = MM[dbl][ii+1][Np];
      PdNpts[ii] = PdNpts[ii+1];
      }
    NclusterD = NclusterD -1;
    }
  if ((NclusterD == NclusterDfin-1)||(merging == 0)) FlagStop = 1;
  }

/* Random Bounce */
FlagStop = 0; NclusterV = Ncluster;
while (FlagStop == 0) {
  merging = 0;
  for (ii = 0; ii <= NclusterV; ii++) {
    TT[0][0][0] = MM[vol][ii][T311];TT[0][0][1] = 0.;
    TT[0][1][0] = MM[vol][ii][T312_re];TT[0][1][1] = MM[vol][ii][T312_im];
    TT[0][2][0] = MM[vol][ii][T313_re];TT[0][2][1] = MM[vol][ii][T313_im];
    TT[1][0][0] = MM[vol][ii][T312_re];TT[1][0][1] = -MM[vol][ii][T312_im];
    TT[1][1][0] = MM[vol][ii][T322];TT[1][1][1] = 0.;
    TT[1][2][0] = MM[vol][ii][T323_re];TT[1][2][1] = MM[vol][ii][T323_im];
    TT[2][0][0] = MM[vol][ii][T313_re];TT[2][0][1] = -MM[vol][ii][T313_im];
    TT[2][1][0] = MM[vol][ii][T323_re];TT[2][1][1] = -MM[vol][ii][T323_im];
    TT[2][2][0] = MM[vol][ii][T333];TT[2][2][1] = 0.;
    InverseHermitianMatrix3(TT, TTm1);
    DeterminantHermitianMatrix3(TT, dt); dett[vol][ii] = dt[0];
    MMm1[vol][ii][T311] = TTm1[0][0][0];
    MMm1[vol][ii][T312_re] = TTm1[0][1][0]; MMm1[vol][ii][T312_im] = TTm1[0][1][1];
    MMm1[vol][ii][T313_re] = TTm1[0][2][0]; MMm1[vol][ii][T313_im] = TTm1[0][2][1];
    MMm1[vol][ii][T322] = TTm1[1][1][0];
    MMm1[vol][ii][T323_re] = TTm1[1][2][0]; MMm1[vol][ii][T323_im] = TTm1[1][2][1];
    MMm1[vol][ii][T333] = TTm1[2][2][0];
    }
    
  for (ii = 0; ii < NclusterV; ii++) {
    for (jj = ii+1; jj <= NclusterV; jj++) {
      Dist[ii][jj] = 0.5*(log(dett[vol][ii]+eps)+log(dett[vol][jj]+eps));
      
      TTm1[0][0][0] = MMm1[vol][ii][T311];TTm1[0][0][1] = 0.;
      TTm1[0][1][0] = MMm1[vol][ii][T312_re];TTm1[0][1][1] = MMm1[vol][ii][T312_im];
      TTm1[0][2][0] = MMm1[vol][ii][T313_re];TTm1[0][2][1] = MMm1[vol][ii][T313_im];
      TTm1[1][0][0] = MMm1[vol][ii][T312_re];TTm1[1][0][1] = -MMm1[vol][ii][T312_im];
      TTm1[1][1][0] = MMm1[vol][ii][T322];TTm1[1][1][1] = 0.;
      TTm1[1][2][0] = MMm1[vol][ii][T323_re];TTm1[1][2][1] = MMm1[vol][ii][T323_im];
      TTm1[2][0][0] = MMm1[vol][ii][T313_re];TTm1[2][0][1] = -MMm1[vol][ii][T313_im];
      TTm1[2][1][0] = MMm1[vol][ii][T323_re];TTm1[2][1][1] = -MMm1[vol][ii][T323_im];
      TTm1[2][2][0] = MMm1[vol][ii][T333];TTm1[2][2][1] = 0.;
      
      TT[0][0][0] = MM[vol][jj][T311];TT[0][0][1] = 0.;
      TT[0][1][0] = MM[vol][jj][T312_re];TT[0][1][1] = MM[vol][jj][T312_im];
      TT[0][2][0] = MM[vol][jj][T313_re];TT[0][2][1] = MM[vol][jj][T313_im];
      TT[1][0][0] = MM[vol][jj][T312_re];TT[1][0][1] = -MM[vol][jj][T312_im];
      TT[1][1][0] = MM[vol][jj][T322];TT[1][1][1] = 0.;
      TT[1][2][0] = MM[vol][jj][T323_re];TT[1][2][1] = MM[vol][jj][T323_im];
      TT[2][0][0] = MM[vol][jj][T313_re];TT[2][0][1] = -MM[vol][jj][T313_im];
      TT[2][1][0] = MM[vol][jj][T323_re];TT[2][1][1] = -MM[vol][jj][T323_im];
      TT[2][2][0] = MM[vol][jj][T333];TT[2][2][1] = 0.;
      Dist[ii][jj] = Dist[ii][jj] + 0.5*Trace3_HM1xHM2(TTm1,TT);
      
      TTm1[0][0][0] = MMm1[vol][jj][T311];TTm1[0][0][1] = 0.;
      TTm1[0][1][0] = MMm1[vol][jj][T312_re];TTm1[0][1][1] = MMm1[vol][jj][T312_im];
      TTm1[0][2][0] = MMm1[vol][jj][T313_re];TTm1[0][2][1] = MMm1[vol][jj][T313_im];
      TTm1[1][0][0] = MMm1[vol][jj][T312_re];TTm1[1][0][1] = -MMm1[vol][jj][T312_im];
      TTm1[1][1][0] = MMm1[vol][jj][T322];TTm1[1][1][1] = 0.;
      TTm1[1][2][0] = MMm1[vol][jj][T323_re];TTm1[1][2][1] = MMm1[vol][jj][T323_im];
      TTm1[2][0][0] = MMm1[vol][jj][T313_re];TTm1[2][0][1] = -MMm1[vol][jj][T313_im];
      TTm1[2][1][0] = MMm1[vol][jj][T323_re];TTm1[2][1][1] = -MMm1[vol][jj][T323_im];
      TTm1[2][2][0] = MMm1[vol][jj][T333];TTm1[2][2][1] = 0.;
      
      TT[0][0][0] = MM[vol][ii][T311];TT[0][0][1] = 0.;
      TT[0][1][0] = MM[vol][ii][T312_re];TT[0][1][1] = MM[vol][ii][T312_im];
      TT[0][2][0] = MM[vol][ii][T313_re];TT[0][2][1] = MM[vol][ii][T313_im];
      TT[1][0][0] = MM[vol][ii][T312_re];TT[1][0][1] = -MM[vol][ii][T312_im];
      TT[1][1][0] = MM[vol][ii][T322];TT[1][1][1] = 0.;
      TT[1][2][0] = MM[vol][ii][T323_re];TT[1][2][1] = MM[vol][ii][T323_im];
      TT[2][0][0] = MM[vol][ii][T313_re];TT[2][0][1] = -MM[vol][ii][T313_im];
      TT[2][1][0] = MM[vol][ii][T323_re];TT[2][1][1] = -MM[vol][ii][T323_im];
      TT[2][2][0] = MM[vol][ii][T333];TT[2][2][1] = 0.;
      Dist[ii][jj] = Dist[ii][jj] + 0.5*Trace3_HM1xHM2(TTm1,TT);
      }
    }    

  dist = INIT_MINMAX;
  for (ii = 0; ii < NclusterV; ii++) {
    for (jj = ii+1; jj <= NclusterV; jj++) {
      if (Dist[ii][jj] < dist) {
        NptsTot = PvNpts[ii] + PvNpts[jj];
        //if (NptsTot < (2.*Sub_Nlig*Sub_Ncol/NclusterVfin)) {
        if (NptsTot < (2.*NptV/NclusterVfin)) {
          dist = Dist[ii][jj];
          k = ii; l = jj;
          merging = 1;
          }
        }      
      }
    }    
  
  if (merging == 1) {
    for (Np = 0; Np < NpolarOut; Np++) 
      MM[vol][k][Np] = (PvNpts[k]*MM[vol][k][Np]+PvNpts[l]*MM[vol][l][Np])/(PvNpts[k]+PvNpts[l]);
    PvNpts[k] = PvNpts[k]+PvNpts[l];
    for (ii = l; ii < NclusterV; ii++) {
      for (Np = 0; Np < NpolarOut; Np++) MM[vol][ii][Np] = MM[vol][ii+1][Np];
      PvNpts[ii] = PvNpts[ii+1];
      }
    NclusterV = NclusterV -1;
    }
  if ((NclusterV == NclusterVfin-1)||(merging == 0)) FlagStop = 1;
  }

PsNptsTot = 0.; NclusterS++; 
for (ii = 0; ii < NclusterS; ii++) PsNptsTot += PsNpts[ii];
PdNptsTot = 0.; NclusterD++; 
for (ii = 0; ii < NclusterD; ii++) PdNptsTot += PdNpts[ii];
PvNptsTot = 0.; NclusterV++;
for (ii = 0; ii < NclusterV; ii++) PvNptsTot += PvNpts[ii];

free_matrix3d_float(TT, 3, 3);

/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
// WISHART CLASSIFICATION
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/* memory allocation */
  Npp = 3;
  Narea = Ncluster;

  det = vector_float(2);
  coh = matrix3d_float(Npp, Npp, 2);
  for (k = 0; k < Npp; k++) {
    for (l = 0; l < Npp; l++) {
      coh_area[k][l][0] = vector_float(Narea);
      coh_area[k][l][1] = vector_float(Narea);
      coh_area_m1[k][l][0] = vector_float(Narea);
      coh_area_m1[k][l][1] = vector_float(Narea);
      coh_area_S[k][l][0] = vector_float(Narea);
      coh_area_S[k][l][1] = vector_float(Narea);
      coh_area_D[k][l][0] = vector_float(Narea);
      coh_area_D[k][l][1] = vector_float(Narea);
      coh_area_V[k][l][0] = vector_float(Narea);
      coh_area_V[k][l][1] = vector_float(Narea);
      }
    }
  det_area[0] = vector_float(Narea);
  det_area[1] = vector_float(Narea);

  for (area = 1; area <= Narea; area++) cpt_area[area] = 0.;

  for (lig = 0; lig < Sub_Nlig; lig++) 
    for (col = 0; col < Sub_Ncol; col++) 
        Class_im[lig][col] = 0.;

/********************************************************************
********************************************************************/
/* Single Bounce */

/* Class center coherency matrices initialization
according to the cluster center merging results*/
  Narea = NclusterS;

  for (area = 1; area <= Narea; area++) cpt_area[area] = 0.;

  for (area = 1; area <= Narea; area++) {
    coh_area[0][0][0][area] = MM[odd][area-1][T311];coh_area[0][0][1][area] = 0.;
    coh_area[0][1][0][area] = MM[odd][area-1][T312_re];coh_area[0][1][1][area] = MM[odd][area-1][T312_im];
    coh_area[0][2][0][area] = MM[odd][area-1][T313_re];coh_area[0][2][1][area] = MM[odd][area-1][T313_im];
    coh_area[1][0][0][area] = MM[odd][area-1][T312_re];coh_area[1][0][1][area] = -MM[odd][area-1][T312_im];
    coh_area[1][1][0][area] = MM[odd][area-1][T322];coh_area[1][1][1][area] = 0.;
    coh_area[1][2][0][area] = MM[odd][area-1][T323_re];coh_area[1][2][1][area] = MM[odd][area-1][T323_im];
    coh_area[2][0][0][area] = MM[odd][area-1][T313_re];coh_area[2][0][1][area] = -MM[odd][area-1][T313_im];
    coh_area[2][1][0][area] = MM[odd][area-1][T323_re];coh_area[2][1][1][area] = -MM[odd][area-1][T323_im];
    coh_area[2][2][0][area] = MM[odd][area-1][T333];coh_area[2][2][1][area] = 0.;
    cpt_area[area] = PsNpts[area-1];
    }

  coh_m1 = matrix3d_float(Npp, Npp, 2);
  
/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }

  free_matrix3d_float(coh_m1, Npp, Npp);
    
/****************************************************/

Flag_stop = 0;
Nit = 0;

while (Flag_stop == 0) {
  Nit++;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
zone = 0;
dist_min = INIT_MINMAX; 
#pragma omp parallel for private(col, area, k, l, M_avg, TT, coh_m1) firstprivate(ligg, distance, dist_min, zone, Modif) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_odd[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          /*Seeking for the closest cluster center */
          for (area = 1; area <= Narea; area++) {
            for (k = 0; k < Npp; k++) {
              for (l = 0; l < Npp; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
                }
              }
            distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
            distance[area] = distance[area] + Trace3_HM1xHM2(coh_m1,TT);
            }
          dist_min = INIT_MINMAX;
          for (area = 1; area <= Narea; area++) {
            if (dist_min > distance[area]) {
              dist_min = distance[area];
              zone = area;
              }
            }
          if (zone != (int) Class_im[ligg][col]) Modif = Modif + 1.;
          Class_im[ligg][col] = (float) zone;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  Flag_stop = 0;
  if (Modif < Pct_switch_min * PsNptsTot) Flag_stop = 1;
  if (Nit == Nit_max) Flag_stop = 1;

  printf("%f\r", 100. * Nit / Nit_max);fflush(stdout);

  if (Flag_stop == 0) {
    /*Calcul des nouveaux centres de classe*/
    for (area = 1; area <= Narea; area++) {
      cpt_area[area] = 0.;
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = 0.;
          coh_area[k][l][1][area] = 0.;
          }
      }

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;
/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
area = 0;
#pragma omp parallel for private(col, k, l, M_avg, TT) firstprivate(ligg, area) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_odd[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          area = (int) Class_im[ligg][col];

          for (k = 0; k < Npp; k++)
            for (l = 0; l < Npp; l++) {
              coh_area[k][l][0][area] = coh_area[k][l][0][area] + TT[k][l][0];
              coh_area[k][l][1][area] = coh_area[k][l][1][area] + TT[k][l][1];
              }
          cpt_area[area] = cpt_area[area] + 1.;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock
  
/*****************************************************/
  for (area = 1; area <= Narea; area++)
    if (cpt_area[area] != 0.) {
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
          coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
          }
      }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }

  free_matrix3d_float(coh_m1, Npp, Npp);
  
/*****************************************************/

  } /* Flag Stop */

} /* while */

/* Save Cluster Centers */
  for (area = 1; area <= Narea; area++) {
    for (k=0; k < Npp; k++) {
      for (l=0; l < Npp; l++) {
        coh_area_S[k][l][0][area] = coh_area[k][l][0][area];
        coh_area_S[k][l][1][area] = coh_area[k][l][1][area];
        }
      }
    cpt_area_S[area] = cpt_area[area];
    }

/********************************************************************
********************************************************************/
/* Double Bounce */

/* Class center coherency matrices initialization
according to the cluster center merging results*/
  Narea = NclusterD;
  
  for (area = 1; area <= Narea; area++) cpt_area[area] = 0.;

  for (area = 1; area <= Narea; area++) {
    coh_area[0][0][0][area] = MM[dbl][area-1][T311];coh_area[0][0][1][area] = 0.;
    coh_area[0][1][0][area] = MM[dbl][area-1][T312_re];coh_area[0][1][1][area] = MM[dbl][area-1][T312_im];
    coh_area[0][2][0][area] = MM[dbl][area-1][T313_re];coh_area[0][2][1][area] = MM[dbl][area-1][T313_im];
    coh_area[1][0][0][area] = MM[dbl][area-1][T312_re];coh_area[1][0][1][area] = -MM[dbl][area-1][T312_im];
    coh_area[1][1][0][area] = MM[dbl][area-1][T322];coh_area[1][1][1][area] = 0.;
    coh_area[1][2][0][area] = MM[dbl][area-1][T323_re];coh_area[1][2][1][area] = MM[dbl][area-1][T323_im];
    coh_area[2][0][0][area] = MM[dbl][area-1][T313_re];coh_area[2][0][1][area] = -MM[dbl][area-1][T313_im];
    coh_area[2][1][0][area] = MM[dbl][area-1][T323_re];coh_area[2][1][1][area] = -MM[dbl][area-1][T323_im];
    coh_area[2][2][0][area] = MM[dbl][area-1][T333];coh_area[2][2][1][area] = 0.;
    cpt_area[area] = PdNpts[area-1];
    }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }

  free_matrix3d_float(coh_m1, Npp, Npp);

/****************************************************/

Flag_stop = 0;
Nit = 0;

while (Flag_stop == 0) {
  Nit++;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
zone = 0;
dist_min = INIT_MINMAX; 
#pragma omp parallel for private(col, area, k, l, M_avg, TT, coh_m1) firstprivate(ligg, distance, dist_min, zone, Modif) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_dbl[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          /*Seeking for the closest cluster center */
          for (area = 1; area <= Narea; area++) {
            for (k = 0; k < Npp; k++) {
              for (l = 0; l < Npp; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
                }
              }
            distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
            distance[area] = distance[area] + Trace3_HM1xHM2(coh_m1,TT);
            }
          dist_min = INIT_MINMAX;
          for (area = 1; area <= Narea; area++) {
            if (dist_min > distance[area]) {
              dist_min = distance[area];
              zone = area + NclusterS;
              }
            }
          if (zone != (int) Class_im[ligg][col]) Modif = Modif + 1.;
          Class_im[ligg][col] = (float) zone;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  Flag_stop = 0;
  if (Modif < Pct_switch_min * PdNptsTot) Flag_stop = 1;
  if (Nit == Nit_max) Flag_stop = 1;

  printf("%f\r", 100. * Nit / Nit_max);fflush(stdout);

  if (Flag_stop == 0) {
    /*Calcul des nouveaux centres de classe*/
    for (area = 1; area <= Narea; area++) {
      cpt_area[area] = 0.;
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = 0.;
          coh_area[k][l][1][area] = 0.;
          }
      }

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;
/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
area = 0;
#pragma omp parallel for private(col, k, l, M_avg, TT) firstprivate(ligg, area) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_dbl[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          area = (int) Class_im[ligg][col]; area = area - NclusterS;

          for (k = 0; k < Npp; k++)
            for (l = 0; l < Npp; l++) {
              coh_area[k][l][0][area] = coh_area[k][l][0][area] + TT[k][l][0];
              coh_area[k][l][1][area] = coh_area[k][l][1][area] + TT[k][l][1];
              }
          cpt_area[area] = cpt_area[area] + 1.;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock
  
/*****************************************************/
  for (area = 1; area <= Narea; area++)
    if (cpt_area[area] != 0.) {
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
          coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
          }
      }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }

  free_matrix3d_float(coh_m1, Npp, Npp);
  
/*****************************************************/

  } /* Flag Stop */

} /* while */

/* Save Cluster Centers */
  for (area = 1; area <= Narea; area++) {
    for (k=0; k < Npp; k++) {
      for (l=0; l < Npp; l++) {
        coh_area_D[k][l][0][area] = coh_area[k][l][0][area];
        coh_area_D[k][l][1][area] = coh_area[k][l][1][area];
        }
      }
    cpt_area_D[area] = cpt_area[area];
    }

/********************************************************************
********************************************************************/
/* Random Bounce */

/* Class center coherency matrices initialization
according to the cluster center merging results*/
  Narea = NclusterV;

  for (area = 1; area <= Narea; area++) {
    coh_area[0][0][0][area] = MM[vol][area-1][T311];coh_area[0][0][1][area] = 0.;
    coh_area[0][1][0][area] = MM[vol][area-1][T312_re];coh_area[0][1][1][area] = MM[vol][area-1][T312_im];
    coh_area[0][2][0][area] = MM[vol][area-1][T313_re];coh_area[0][2][1][area] = MM[vol][area-1][T313_im];
    coh_area[1][0][0][area] = MM[vol][area-1][T312_re];coh_area[1][0][1][area] = -MM[vol][area-1][T312_im];
    coh_area[1][1][0][area] = MM[vol][area-1][T322];coh_area[1][1][1][area] = 0.;
    coh_area[1][2][0][area] = MM[vol][area-1][T323_re];coh_area[1][2][1][area] = MM[vol][area-1][T323_im];
    coh_area[2][0][0][area] = MM[vol][area-1][T313_re];coh_area[2][0][1][area] = -MM[vol][area-1][T313_im];
    coh_area[2][1][0][area] = MM[vol][area-1][T323_re];coh_area[2][1][1][area] = -MM[vol][area-1][T323_im];
    coh_area[2][2][0][area] = MM[vol][area-1][T333];coh_area[2][2][1][area] = 0.;
    cpt_area[area] = PvNpts[area-1];
    }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }
    
  free_matrix3d_float(coh_m1, Npp, Npp);

/****************************************************/

Flag_stop = 0;
Nit = 0;

while (Flag_stop == 0) {
  Nit++;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
zone = 0;
dist_min = INIT_MINMAX; 
#pragma omp parallel for private(col, area, k, l, M_avg, TT, coh_m1) firstprivate(ligg, distance, dist_min, zone, Modif) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_vol[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          /*Seeking for the closest cluster center */
          for (area = 1; area <= Narea; area++) {
            for (k = 0; k < Npp; k++) {
              for (l = 0; l < Npp; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
                }
              }
            distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
            distance[area] = distance[area] + Trace3_HM1xHM2(coh_m1,TT);
            }
          dist_min = INIT_MINMAX;
          for (area = 1; area <= Narea; area++) {
            if (dist_min > distance[area]) {
              dist_min = distance[area];
              zone = area + NclusterS + NclusterD;
              }
            }
          if (zone != (int) Class_im[ligg][col]) Modif = Modif + 1.;
          Class_im[ligg][col] = (float) zone;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/*****************************************************/
  Flag_stop = 0;
  if (Modif < Pct_switch_min * PvNptsTot) Flag_stop = 1;
  if (Nit == Nit_max) Flag_stop = 1;

  printf("%f\r", 100. * Nit / Nit_max);fflush(stdout);

  if (Flag_stop == 0) {
    /*Calcul des nouveaux centres de classe*/
    for (area = 1; area <= Narea; area++) {
      cpt_area[area] = 0.;
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = 0.;
          coh_area[k][l][1][area] = 0.;
          }
      }

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

  Modif = 0.;
/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
area = 0;
#pragma omp parallel for private(col, k, l, M_avg, TT) firstprivate(ligg, area) shared(ligDone, coh_area, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if ((Power == M_vol[lig][col])&&((Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col])) > mixed_threshold)) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          area = (int) Class_im[ligg][col]; area = area - NclusterS -  NclusterD;

          for (k = 0; k < Npp; k++)
            for (l = 0; l < Npp; l++) {
              coh_area[k][l][0][area] = coh_area[k][l][0][area] + TT[k][l][0];
              coh_area[k][l][1][area] = coh_area[k][l][1][area] + TT[k][l][1];
              }
          cpt_area[area] = cpt_area[area] + 1.;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock
  
/*****************************************************/
  for (area = 1; area <= Narea; area++)
    if (cpt_area[area] != 0.) {
      for (k = 0; k < Npp; k++)
        for (l = 0; l < Npp; l++) {
          coh_area[k][l][0][area] = coh_area[k][l][0][area] / cpt_area[area];
          coh_area[k][l][1][area] = coh_area[k][l][1][area] / cpt_area[area];
          }
      }

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }

  free_matrix3d_float(coh_m1, Npp, Npp);

/*****************************************************/

  } /* Flag Stop */

} /* while */
  
/* Save Cluster Centers */
  for (area = 1; area <= Narea; area++) {
    for (k=0; k < Npp; k++) {
      for (l=0; l < Npp; l++) {
        coh_area_V[k][l][0][area] = coh_area[k][l][0][area];
        coh_area_V[k][l][1][area] = coh_area[k][l][1][area];
        }
      }
    cpt_area_V[area] = cpt_area[area];
    }

/********************************************************************
********************************************************************/
/* Classification of the MIXED pixels */

/* Class center coherency matrices initialization
according to the wishart segmentation results*/
  Narea = NclusterS + NclusterD + NclusterV;

  for (area = 1; area <= Narea; area++) cpt_area[area] = 0.;

  for (area = 1; area <= NclusterS; area++) {
    for (k=0; k < Npp; k++) {
      for (l=0; l < Npp; l++) {
        coh_area[k][l][0][area] = coh_area_S[k][l][0][area];
        coh_area[k][l][1][area] = coh_area_S[k][l][1][area];
        }
      }
    cpt_area[area] = cpt_area_S[area];
    }
  for (area = 1; area <= NclusterD; area++) {
    for (k=0; k < Npp; k++) {
      for (l=0; l < Npp; l++) {
        coh_area[k][l][0][area+NclusterS] = coh_area_D[k][l][0][area];
        coh_area[k][l][1][area+NclusterS] = coh_area_D[k][l][1][area];
        }
      }
    cpt_area[area+NclusterS] = cpt_area_D[area];
    }
  for (area = 1; area <= NclusterV; area++) {
    for (k=0; k < Npp; k++) {
      for (l=0; l < Npp; l++) {
        coh_area[k][l][0][area+NclusterS+NclusterD] = coh_area_V[k][l][0][area];
        coh_area[k][l][1][area+NclusterS+NclusterD] = coh_area_V[k][l][1][area];
        }
      }
    cpt_area[area+NclusterS+NclusterD] = cpt_area_V[area];
    }

/****************************************************/

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
  for (area = 1; area <= Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
    InverseHermitianMatrix3(coh, coh_m1);
    DeterminantHermitianMatrix3(coh, det);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }
    
  free_matrix3d_float(coh_m1, Npp, Npp);

/****************************************************/

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  rewind(in_odd); rewind(in_dbl); rewind(in_vol);
  if (FlagValid == 1) rewind(in_valid);

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) PrintfLine(Nb,NbBlock);

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

  if (strcmp(PolType,"S2")==0) {
    read_block_S2_noavg(in_datafile, M_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of C,T or I */
    read_block_TCI_noavg(in_datafile, M_in, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  read_block_matrix_float(in_odd, M_odd, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_dbl, M_dbl, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(in_vol, M_vol, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  
zone = 0;
dist_min = INIT_MINMAX; 
#pragma omp parallel for private(col, area, k, l, M_avg, TT, coh_m1) firstprivate(ligg, distance, dist_min, zone, Modif) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    TT = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        Power = my_max(my_max(M_odd[lig][col],M_dbl[lig][col]),M_vol[lig][col]);
        if (Power / (M_odd[lig][col]+M_dbl[lig][col]+M_vol[lig][col]) <= mixed_threshold) {
          /* Average complex coherency matrix determination*/
          TT[0][0][0] = eps + M_avg[0][col]; TT[0][0][1] = 0.;
          TT[0][1][0] = eps + M_avg[1][col]; TT[0][1][1] = eps + M_avg[2][col];
          TT[0][2][0] = eps + M_avg[3][col]; TT[0][2][1] = eps + M_avg[4][col];
          TT[1][0][0] =  TT[0][1][0]; TT[1][0][1] = -TT[0][1][1];
          TT[1][1][0] = eps + M_avg[5][col]; TT[1][1][1] = 0.;
          TT[1][2][0] = eps + M_avg[6][col]; TT[1][2][1] = eps + M_avg[7][col];
          TT[2][0][0] =  TT[0][2][0]; TT[2][0][1] = -TT[0][2][1];
          TT[2][1][0] =  TT[1][2][0]; TT[2][1][1] = -TT[1][2][1];
          TT[2][2][0] = eps + M_avg[8][col]; TT[2][2][1] = 0.;

          /*Seeking for the closest cluster center */
          for (area = 1; area <= Narea; area++) {
            for (k = 0; k < Npp; k++) {
              for (l = 0; l < Npp; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
                }
              }
            distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
            distance[area] = distance[area] + Trace3_HM1xHM2(coh_m1,TT);
            }
          dist_min = INIT_MINMAX;
          for (area = 1; area <= Narea; area++) {
            if (dist_min > distance[area]) {
              dist_min = distance[area];
              zone = area;
              }
            }
          Class_im[ligg][col] = (float) zone;
          } /* odd */
        } /*valid*/
      }
    free_matrix3d_float(TT, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/********************************************************************
********************************************************************/
/* Saving wishart classification results bin and bitmap*/
  Class_im[0][0] = 1.; Class_im[1][1] = (float) (NclusterS + NclusterD + NclusterV);

  write_block_matrix_float(classif_file, Class_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);
  
  if (Bmp_flag == 1) {
    /* ColorMap determination */
    sprintf(ColorMap, "%s%s", out_dir, "scattering_model_based_colormap.pal");
    if ((colormap = fopen(ColorMap, "w")) == NULL)
      edit_error("Could not open input file : ", ColorMap);
    fprintf(colormap, "JASC-PAL\n");
    fprintf(colormap, "0100\n");
    fprintf(colormap, "256\n");
    fprintf(colormap, "125 125 125\n");
  
    check_file(ColorMapSingle);
    if ((colormapS = fopen(ColorMapSingle, "rb")) == NULL)
      edit_error("Could not open input file : ", ColorMapSingle);
    fscanf(colormapS, "%s\n", Tmp);
    fscanf(colormapS, "%s\n", Tmp);
    fscanf(colormapS, "%i\n", &NbreColor);
    fscanf(colormapS, "%i %i %i\n", &red[0], &green[0], &blue[0]);
    for (col = 0; col < NbreColor-1; col++)
      fscanf(colormapS, "%i %i %i\n", &red[col], &green[col], &blue[col]);
    fclose(colormapS);
    NN = (int)(NbreColor / (NclusterS + 1));
    for (col = 1; col <= NclusterS; col++) fprintf(colormap, "%i %i %i\n", red[col*NN], green[col*NN], blue[col*NN]);
    
    check_file(ColorMapDouble);
    if ((colormapD = fopen(ColorMapDouble, "rb")) == NULL)
      edit_error("Could not open input file : ", ColorMapDouble);
    fscanf(colormapD, "%s\n", Tmp);
    fscanf(colormapD, "%s\n", Tmp);
    fscanf(colormapD, "%i\n", &NbreColor);
    fscanf(colormapD, "%i %i %i\n", &red[0], &green[0], &blue[0]);
    for (col = 0; col < NbreColor-1; col++)
      fscanf(colormapD, "%i %i %i\n", &red[col], &green[col], &blue[col]);
    fclose(colormapD);
    NN = (int)(NbreColor / (NclusterD + 1));
    for (col = 1; col <= NclusterD; col++) fprintf(colormap, "%i %i %i\n", red[col*NN], green[col*NN], blue[col*NN]);
        
    check_file(ColorMapRandom);
    if ((colormapV = fopen(ColorMapRandom, "rb")) == NULL)
      edit_error("Could not open input file : ", ColorMapRandom);
    fscanf(colormapV, "%s\n", Tmp);
    fscanf(colormapV, "%s\n", Tmp);
    fscanf(colormapV, "%i\n", &NbreColor);
    fscanf(colormapV, "%i %i %i\n", &red[0], &green[0], &blue[0]);
    for (col = 0; col < NbreColor-1; col++)
      fscanf(colormapV, "%i %i %i\n", &red[col], &green[col], &blue[col]);
    fclose(colormapV);
    NN = (int)(NbreColor / (NclusterV + 1));
    for (col = 1; col <= NclusterV; col++) fprintf(colormap, "%i %i %i\n", red[col*NN], green[col*NN], blue[col*NN]);
      
    for (col = NclusterS+NclusterD+NclusterV + 1; col < NbreColor; col++) fprintf(colormap, "1 1 1\n");
    fclose(colormap);
    
    sprintf(file_name, "%s%s%dx%d", out_dir, "scattering_model_based_classification_", NwinL, NwinC);
    bmp_wishart(Class_im, Sub_Nlig, Sub_Ncol, file_name, ColorMap);
    }

/********************************************************************
//END OF THE WISHART  CLASSIFICATION
********************************************************************/
  
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_odd, NligBlock[0]);
  free_matrix_float(M_dbl, NligBlock[0]);
  free_matrix_float(M_vol, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);
  fclose(in_odd); fclose(in_dbl); fclose(in_vol);

/* OUTPUT FILE CLOSING*/
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

void MinMaxContrastMedianNN(float *mat,float *min,float *max,int Npts, int NN)
{
  float maxmax, minmin;
  float median, median0;
  float xx;
  int ii,nn,npts;


  *min = INIT_MINMAX; *max = -*min;
  minmin = INIT_MINMAX; maxmax = -minmin;

  for(nn=0;nn<Npts;nn++) {
    if (my_isfinite(mat[nn]) != 0) {
      if (mat[nn] < minmin) minmin = mat[nn];
      if (mat[nn] > maxmax) maxmax = mat[nn];
      }
    }

  median0 = MedianArray(mat, Npts);
  
  /*Recherche Valeur Min*/
  median = median0;
  *min = median0;
  for (ii=0; ii<NN; ii++) {
  npts=-1;
  for(nn=0;nn<Npts;nn++) {
    if (median0 == minmin) {
      if (mat[nn] <= median) {
        npts++;
        xx = mat[npts];
        mat[npts]=mat[nn];
        mat[nn] = xx;
        }
      } else {
      if (mat[nn] < median) {
        npts++;
        xx = mat[npts];
        mat[npts]=mat[nn];
        mat[nn] = xx;
        }
      }
    }
  median = MedianArray(mat, npts);
  if (median == minmin) median = *min;
  *min = median;
  }

  /*Recherche Valeur Max*/
  median = median0;
  *max = median0;
  for (ii=0; ii<NN; ii++) {
    npts=-1;
    for(nn=0;nn<Npts;nn++) {
      if (median0 == maxmax) {
        if (mat[nn] >= median) {
          npts++;
          xx = mat[npts];
          mat[npts]=mat[nn];
          mat[nn] = xx;
          }
        } else {
        if (mat[nn] > median) {
          npts++;
          xx = mat[npts];
          mat[npts]=mat[nn];
          mat[nn] = xx;
          }
        }
      }
    median = MedianArray(mat, npts);
    if (median == maxmax) median = *max;
    *max = median;
    }
}
