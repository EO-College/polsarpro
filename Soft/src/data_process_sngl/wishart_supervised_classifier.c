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

File  : wishart_supervised_classifier.c
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

Description :  Supervised maximum likelihood classification of a
polarimetric image with a "don't know class"
- from the Wishart PDF of its coherency matrices
- from the Gaussian PDF of its target vectors
represented under the form of one look coherency matrices

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
void create_class_map(char *file_name, float *class_map);

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
  FILE *trn_file, *class_file, *fp;
  //FILE *tmpclass, *tmpdist;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "C3", "C4", "T3", "T4", "SPP", "IPP"};
  char file_name[FilePathLength];
  char area_file[FilePathLength], cluster_file[FilePathLength];
  char ColorMapTrainingSet16[FilePathLength];

/* Internal variables */
  int ii, lig, col, k, l;
  int Npp;
  int ligg, Nligg;
  int ligDone = 0;

  int Bmp_flag;
//  int Rej_flag;
  float std_coeff, dist_min;
  int area, Narea;
  float trace;

/* Matrix arrays */
  float ***M_in;
  float **M_avg;
  float ***M;
  float ***coh;
  float ***coh_m1;

  float **Class_Im;
  float **TMPclass_im;
  float **TMPdist_im;
  float *M_trn;
  float *class_map;
  float *det;

  float *coh_area[4][4][2];
  float *coh_area_m1[4][4][2];
  float *cov_area[4];
  float *cov_area_m1[4];
  float *det_area[4];

  float cpt_area[100];
  float mean_dist_area[100];
  float mean_dist_area2[100];
  float std_dist_area[100];
  float distance[100];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_supervised_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-af  	input area file\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-cf  	input cluster file\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (0/1)\n");
strcat(UsageHelp," (string)	-col 	input colormap file (valid if BMP flag = 1)\n");
//strcat(UsageHelp," (int)   	-rej 	rejection mode flag (0/1)\n");
//strcat(UsageHelp," (float) 	-std 	distance std value for rejection\n");
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

//if(argc < 27) {
if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-af",str_cmd_prm,area_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cf",str_cmd_prm,cluster_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&Bmp_flag,1,UsageHelp);
  if (Bmp_flag == 1)
    get_commandline_prm(argc,argv,"-col",str_cmd_prm,ColorMapTrainingSet16,1,UsageHelp);
//  get_commandline_prm(argc,argv,"-rej",int_cmd_prm,&Rej_flag,1,UsageHelp);
//  if (Rej_flag == 1)
//    get_commandline_prm(argc,argv,"-std",flt_cmd_prm,&std_coeff,1,UsageHelp);

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
  check_file(cluster_file);
  check_file(ColorMapTrainingSet16);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  if (Bmp_flag != 0) Bmp_flag = 1;
//  if (Rej_flag != 0) Rej_flag = 1;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"S2")==0) {
    if (strcmp(PolarCase,"monostatic") == 0) strcpy(PolType, "S2T3");
    if (strcmp(PolarCase,"bistatic") == 0) strcpy(PolType, "S2T4");
    }
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

  strcpy(file_name, cluster_file);
  if ((trn_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open parameter file : ", file_name);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s%dx%d%s", out_dir, "wishart_supervised_class_", NwinL,NwinC,".bin");
  if ((class_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "wishart_training_cluster_centers.txt");
  if ((fp = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);

/*
  sprintf(file_name, "%s%s", out_dir, "TMPclass_im.bin");
  if ((tmpclass = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "TMPdist_im.bin");
  if ((tmpdist = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
*/
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

  /* ClassIm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* TMPclassIm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* TMPdistIm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* Min = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*(Ncol+NwinC); NBlockB += NpolarOut*NwinL*(Ncol+NwinC);
  /* Mavg = NpolarOut */
  NBlockA += 0; NBlockB += NpolarOut*Sub_Ncol;
  
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
  M_trn = vector_float(NpolarOut);
  Class_Im = matrix_float(Sub_Nlig, Sub_Ncol);
  TMPclass_im = matrix_float(Sub_Nlig, Sub_Ncol);
  TMPdist_im = matrix_float(Sub_Nlig, Sub_Ncol);
  
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

/* Number of learning clusters reading */
  fread(&M_trn[0], sizeof(float), 1, trn_file);
  Narea = (int) M_trn[0] + 1;
  class_map = vector_float(Narea + 1);

  create_class_map(area_file, class_map);

/*Training class matrix memory allocation */
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) Npp = 2;
  if (strcmp(PolTypeOut,"C3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"C4")==0) Npp = 4;
  if (strcmp(PolTypeOut,"T3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"T4")==0) Npp = 4;
  if (strcmp(PolTypeOut,"IPPpp4")==0) Npp = 3;
  if (strcmp(PolTypeOut,"IPPpp5")==0) Npp = 2;
  if (strcmp(PolTypeOut,"IPPpp6")==0) Npp = 2;
  if (strcmp(PolTypeOut,"IPPpp7")==0) Npp = 2;

  if (strcmp(PolType,"IPP")==0) {
    for (k = 0; k < Npp; k++) cov_area[k] = vector_float(Narea);
    for (k = 0; k < Npp; k++) cov_area_m1[k] = vector_float(Narea);
    } else {
    det = vector_float(2);
    coh = matrix3d_float(Npp, Npp, 2);
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area[k][l][0] = vector_float(Narea);
        coh_area[k][l][1] = vector_float(Narea);
        coh_area_m1[k][l][0] = vector_float(Narea);
        coh_area_m1[k][l][1] = vector_float(Narea);
        }
      }
    }
    det_area[0] = vector_float(Narea);
    det_area[1] = vector_float(Narea);

/****************************************************/
/* TRAINING CLUSTER CENTERS READING */
for (area = 1; area < Narea; area++) {
  if (strcmp(PolType,"IPP")==0) {
    fread(&M_trn[0], sizeof(float), Npp, trn_file);
    for (Np = 0; Np < Npp; Np++) cov_area[Np][area] = eps + M_trn[Np];
    } else {
    fread(&M_trn[0], sizeof(float), NpolarOut, trn_file);
    if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
      coh_area[0][0][0][area] = eps + M_trn[C211];
      coh_area[0][0][1][area] = 0.;
      coh_area[0][1][0][area] = eps + M_trn[C212_re];
      coh_area[0][1][1][area] = eps + M_trn[C212_im];
      coh_area[1][0][0][area] = eps + M_trn[C212_re];
      coh_area[1][0][1][area] = eps - M_trn[C212_im];
      coh_area[1][1][0][area] = eps + M_trn[C222];
      coh_area[1][1][1][area] = 0.;
      }
    if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
      coh_area[0][0][0][area] = eps + M_trn[X311];
      coh_area[0][0][1][area] = 0.;
      coh_area[0][1][0][area] = eps + M_trn[X312_re];
      coh_area[0][1][1][area] = eps + M_trn[X312_im];
      coh_area[0][2][0][area] = eps + M_trn[X313_re];
      coh_area[0][2][1][area] = eps + M_trn[X313_im];
      coh_area[1][0][0][area] = eps + M_trn[X312_re];
      coh_area[1][0][1][area] = eps - M_trn[X312_im];
      coh_area[1][1][0][area] = eps + M_trn[X322];
      coh_area[1][1][1][area] = 0.;
      coh_area[1][2][0][area] = eps + M_trn[X323_re];
      coh_area[1][2][1][area] = eps + M_trn[X323_im];
      coh_area[2][0][0][area] = eps + M_trn[X313_re];
      coh_area[2][0][1][area] = eps - M_trn[X313_im];
      coh_area[2][1][0][area] = eps + M_trn[X323_re];
      coh_area[2][1][1][area] = eps - M_trn[X323_im];
      coh_area[2][2][0][area] = eps + M_trn[X333];
      coh_area[2][2][1][area] = 0.;
      }
    if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
      coh_area[0][0][0][area] = eps + M_trn[X411];
      coh_area[0][0][1][area] = 0.;
      coh_area[0][1][0][area] = eps + M_trn[X412_re];
      coh_area[0][1][1][area] = eps + M_trn[X412_im];
      coh_area[0][2][0][area] = eps + M_trn[X413_re];
      coh_area[0][2][1][area] = eps + M_trn[X413_im];
      coh_area[0][3][0][area] = eps + M_trn[X414_re];
      coh_area[0][3][1][area] = eps + M_trn[X414_im];

      coh_area[1][0][0][area] = eps + M_trn[X412_re];
      coh_area[1][0][1][area] = eps - M_trn[X412_im];
      coh_area[1][1][0][area] = eps + M_trn[X422];
      coh_area[1][1][1][area] = 0.;
      coh_area[1][2][0][area] = eps + M_trn[X423_re];
      coh_area[1][2][1][area] = eps + M_trn[X423_im];
      coh_area[1][3][0][area] = eps + M_trn[X424_re];
      coh_area[1][3][1][area] = eps + M_trn[X424_im];

      coh_area[2][0][0][area] = eps + M_trn[X413_re];
      coh_area[2][0][1][area] = eps - M_trn[X413_im];
      coh_area[2][1][0][area] = eps + M_trn[X423_re];
      coh_area[2][1][1][area] = eps - M_trn[X423_im];
      coh_area[2][2][0][area] = eps + M_trn[X433];
      coh_area[2][2][1][area] = 0.;
      coh_area[2][3][0][area] = eps + M_trn[X434_re];
      coh_area[2][3][1][area] = eps + M_trn[X434_im];

      coh_area[3][0][0][area] = eps + M_trn[X414_re];
      coh_area[3][0][1][area] = eps - M_trn[X414_im];
      coh_area[3][1][0][area] = eps + M_trn[X424_re];
      coh_area[3][1][1][area] = eps - M_trn[X424_im];
      coh_area[3][2][0][area] = eps + M_trn[X434_re];
      coh_area[3][2][1][area] = eps - M_trn[X434_im];
      coh_area[3][3][0][area] = eps + M_trn[X444];
      coh_area[3][3][1][area] = 0.;
      }
    }
  mean_dist_area[area] = 0;
  mean_dist_area2[area] = 0;
  std_dist_area[area] = 0;
  }
/* save cluster center in text file */
  for (area = 1; area < Narea; area++) {
    fprintf(fp, "cluster centre # %i\n", area);
    if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
      fprintf(fp, "C11 = %e\n", coh_area[0][0][0][area]);
      fprintf(fp, "C12 = %e + j %e\n", coh_area[0][1][0][area], coh_area[0][1][1][area]);
      fprintf(fp, "C22 = %e\n", coh_area[1][1][0][area]);
      fprintf(fp, "\n");
      }
    if (strcmp(PolTypeOut,"C3")==0) {
      fprintf(fp, "C11 = %e\n", coh_area[0][0][0][area]);
      fprintf(fp, "C12 = %e + j %e\n", coh_area[0][1][0][area], coh_area[0][1][1][area]);
      fprintf(fp, "C13 = %e + j %e\n", coh_area[0][2][0][area], coh_area[0][2][1][area]);
      fprintf(fp, "C22 = %e\n", coh_area[1][1][0][area]);
      fprintf(fp, "C23 = %e + j %e\n", coh_area[1][2][0][area], coh_area[1][2][1][area]);
      fprintf(fp, "C33 = %e\n", coh_area[2][2][0][area]);
      fprintf(fp, "\n");
      }
    if (strcmp(PolTypeOut,"T3")==0) {
      fprintf(fp, "T11 = %e\n", coh_area[0][0][0][area]);
      fprintf(fp, "T12 = %e + j %e\n", coh_area[0][1][0][area], coh_area[0][1][1][area]);
      fprintf(fp, "T13 = %e + j %e\n", coh_area[0][2][0][area], coh_area[0][2][1][area]);
      fprintf(fp, "T22 = %e\n", coh_area[1][1][0][area]);
      fprintf(fp, "T23 = %e + j %e\n", coh_area[1][2][0][area], coh_area[1][2][1][area]);
      fprintf(fp, "T33 = %e\n", coh_area[2][2][0][area]);
      fprintf(fp, "\n");
      }
    if (strcmp(PolTypeOut,"C4")==0) {
      fprintf(fp, "C11 = %e\n", coh_area[0][0][0][area]);
      fprintf(fp, "C12 = %e + j %e\n", coh_area[0][1][0][area], coh_area[0][1][1][area]);
      fprintf(fp, "C13 = %e + j %e\n", coh_area[0][2][0][area], coh_area[0][2][1][area]);
      fprintf(fp, "C14 = %e + j %e\n", coh_area[0][3][0][area], coh_area[0][3][1][area]);
      fprintf(fp, "C22 = %e\n", coh_area[1][1][0][area]);
      fprintf(fp, "C23 = %e + j %e\n", coh_area[1][2][0][area], coh_area[1][2][1][area]);
      fprintf(fp, "C24 = %e + j %e\n", coh_area[1][3][0][area], coh_area[1][3][1][area]);
      fprintf(fp, "C33 = %e\n", coh_area[2][2][0][area]);
      fprintf(fp, "C34 = %e + j %e\n", coh_area[2][3][0][area], coh_area[2][3][1][area]);
      fprintf(fp, "C44 = %e\n", coh_area[3][3][0][area]);
      fprintf(fp, "\n");
      }
    if (strcmp(PolTypeOut,"T4")==0) {
      fprintf(fp, "T11 = %e\n", coh_area[0][0][0][area]);
      fprintf(fp, "T12 = %e + j %e\n", coh_area[0][1][0][area], coh_area[0][1][1][area]);
      fprintf(fp, "T13 = %e + j %e\n", coh_area[0][2][0][area], coh_area[0][2][1][area]);
      fprintf(fp, "T14 = %e + j %e\n", coh_area[0][3][0][area], coh_area[0][3][1][area]);
      fprintf(fp, "T22 = %e\n", coh_area[1][1][0][area]);
      fprintf(fp, "T23 = %e + j %e\n", coh_area[1][2][0][area], coh_area[1][2][1][area]);
      fprintf(fp, "T24 = %e + j %e\n", coh_area[1][3][0][area], coh_area[1][3][1][area]);
      fprintf(fp, "T33 = %e\n", coh_area[2][2][0][area]);
      fprintf(fp, "T34 = %e + j %e\n", coh_area[2][3][0][area], coh_area[2][3][1][area]);
      fprintf(fp, "T44 = %e\n", coh_area[3][3][0][area]);
      fprintf(fp, "\n");
      }
    if (strcmp(PolTypeOut, "IPPpp4") == 0) {
      fprintf(fp, "I11 = %e\n", cov_area[0][area]);
      fprintf(fp, "I12 = %e\n", cov_area[1][area]);
      fprintf(fp, "I22 = %e\n", cov_area[2][area]);
      }
    if (strcmp(PolTypeOut, "IPPpp5") == 0) {
      fprintf(fp, "I11 = %e\n", cov_area[0][area]);
      fprintf(fp, "I21 = %e\n", cov_area[1][area]);
      }
    if (strcmp(PolTypeOut, "IPPpp6") == 0) {
      fprintf(fp, "I12 = %e\n", cov_area[0][area]);
      fprintf(fp, "I22 = %e\n", cov_area[1][area]);
      }  
    if (strcmp(PolTypeOut, "IPPpp7") == 0) {
      fprintf(fp, "I11 = %e\n", cov_area[0][area]);
      fprintf(fp, "I22 = %e\n", cov_area[1][area]);
      }
    if (strcmp(PolTypeOut, "IPPfull") == 0) {
      fprintf(fp, "I11 = %e\n", cov_area[0][area]);
      fprintf(fp, "I12 = %e\n", cov_area[1][area]);
      fprintf(fp, "I21 = %e\n", cov_area[2][area]);
      fprintf(fp, "I22 = %e\n", cov_area[3][area]);
      }
    }
  fclose(fp);

  coh_m1 = matrix3d_float(Npp, Npp, 2);

/* Inverse center coherency matrices computation */
if (strcmp(PolType,"IPP")==0) {
  for (area = 1; area < Narea; area++) {
    for (Np = 0; Np < Npp; Np++) cov_area_m1[Np][area] = 1 / (cov_area[Np][area] + eps);
    det_area[0][area] = cov_area[0][area];
    for (Np = 1; Np < Npp; Np++) det_area[0][area] = det_area[0][area] * cov_area[Np][area];
    det_area[1][area] = 0.;
    }
  } else {
  for (area = 1; area < Narea; area++) {
    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh[k][l][0] = coh_area[k][l][0][area];
        coh[k][l][1] = coh_area[k][l][1][area];
        }
      }
      
    if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
      InverseHermitianMatrix2(coh, coh_m1);
      DeterminantHermitianMatrix2(coh, det);
      }
    if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
      InverseHermitianMatrix3(coh, coh_m1);
      DeterminantHermitianMatrix3(coh, det);
      }
    if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
      InverseHermitianMatrix4(coh, coh_m1);
      DeterminantHermitianMatrix4(coh, det);
      }

    for (k = 0; k < Npp; k++) {
      for (l = 0; l < Npp; l++) {
        coh_area_m1[k][l][0][area] = coh_m1[k][l][0];
        coh_area_m1[k][l][1][area] = coh_m1[k][l][1];
        }
      }
    det_area[0][area] = det[0];
    det_area[1][area] = det[1];
    }
  }

  free_matrix3d_float(coh_m1, Npp, Npp);

/****************************************************/
/****************************************************/
ligg = 0; Nligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);

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

trace = 0.; dist_min = INIT_MINMAX;
#pragma omp parallel for private(col, k, l, area, M_avg, M, coh_m1) firstprivate(ligg, distance, trace, dist_min) shared(ligDone, mean_dist_area, mean_dist_area2, cpt_area)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    M = matrix3d_float(Npp, Npp, 2);
    coh_m1 = matrix3d_float(Npp, Npp, 2);
    M_avg = matrix_float(NpolarOut,Sub_Ncol);
    average_TCI(M_in, Valid, NpolarOut, M_avg, lig, Sub_Ncol, NwinL, NwinC, NwinLM1S2, NwinCM1S2);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[NwinLM1S2+lig][NwinCM1S2+col] == 1.) {
        if (strcmp(PolType,"IPP")==0) {
          for (area = 1; area < Narea; area++) {
            trace = 0;
            for (k = 0; k < Npp; k++) trace += cov_area_m1[k][area] * M_avg[k][col];
            distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
            distance[area] = distance[area] + trace;
            }
          } else {
          if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
            /* Average complex coherency matrix determination*/
            M[0][0][0] = eps + M_avg[0][col];
            M[0][0][1] = 0.;
            M[0][1][0] = eps + M_avg[1][col];
            M[0][1][1] = eps + M_avg[2][col];
            M[1][0][0] =  M[0][1][0];
            M[1][0][1] = -M[0][1][1];
            M[1][1][0] = eps + M_avg[3][col];
            M[1][1][1] = 0.;
            }
          if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) {
            /* Average complex coherency matrix determination*/
            M[0][0][0] = eps + M_avg[0][col];
            M[0][0][1] = 0.;
            M[0][1][0] = eps + M_avg[1][col];
            M[0][1][1] = eps + M_avg[2][col];
            M[0][2][0] = eps + M_avg[3][col];
            M[0][2][1] = eps + M_avg[4][col];
            M[1][0][0] =  M[0][1][0];
            M[1][0][1] = -M[0][1][1];
            M[1][1][0] = eps + M_avg[5][col];
            M[1][1][1] = 0.;
            M[1][2][0] = eps + M_avg[6][col];
            M[1][2][1] = eps + M_avg[7][col];
            M[2][0][0] =  M[0][2][0];
            M[2][0][1] = -M[0][2][1];
            M[2][1][0] =  M[1][2][0];
            M[2][1][1] = -M[1][2][1];
            M[2][2][0] = eps + M_avg[8][col];
            M[2][2][1] = 0.;
            }
          if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) {
            /* Average complex coherency matrix determination*/
            M[0][0][0] = eps + M_avg[0][col];
            M[0][0][1] = 0.;
            M[0][1][0] = eps + M_avg[1][col];
            M[0][1][1] = eps + M_avg[2][col];
            M[0][2][0] = eps + M_avg[3][col];
            M[0][2][1] = eps + M_avg[4][col];
            M[0][3][0] = eps + M_avg[5][col];
            M[0][3][1] = eps + M_avg[6][col];
            M[1][0][0] =  M[0][1][0];
            M[1][0][1] = -M[0][1][1];
            M[1][1][0] = eps + M_avg[7][col];
            M[1][1][1] = 0.;
            M[1][2][0] = eps + M_avg[8][col];
            M[1][2][1] = eps + M_avg[9][col];
            M[1][3][0] = eps + M_avg[10][col];
            M[1][3][1] = eps + M_avg[11][col];
            M[2][0][0] =  M[0][2][0];
            M[2][0][1] = -M[0][2][1];
            M[2][1][0] =  M[1][2][0];
            M[2][1][1] = -M[1][2][1];
            M[2][2][0] = eps + M_avg[12][col];
            M[2][2][1] = 0.;
            M[2][3][0] = eps + M_avg[13][col];
            M[2][3][1] = eps + M_avg[14][col];
            M[3][0][0] =  M[0][3][0];
            M[3][0][1] = -M[0][3][1];
            M[3][1][0] =  M[1][3][0];
            M[3][1][1] = -M[1][3][1];
            M[3][2][0] =  M[2][3][0];
            M[3][2][1] = -M[2][3][1];
            M[3][3][0] = eps + M_avg[15][col];
            M[3][3][1] = 0.;
            }

          /*Seeking for the closest cluster center */
          for (area = 1; area < Narea; area++) {
            for (k = 0; k < Npp; k++) {
              for (l = 0; l < Npp; l++) {
                coh_m1[k][l][0] = coh_area_m1[k][l][0][area];
                coh_m1[k][l][1] = coh_area_m1[k][l][1][area];
                }
              }
            distance[area] = log(sqrt(det_area[0][area] * det_area[0][area] + det_area[1][area] * det_area[1][area]));
            if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) distance[area] = distance[area] + Trace2_HM1xHM2(coh_m1,M);
            if ((strcmp(PolTypeOut,"C3")==0)||(strcmp(PolTypeOut,"T3")==0)) distance[area] = distance[area] + Trace3_HM1xHM2(coh_m1,M);
            if ((strcmp(PolTypeOut,"C4")==0)||(strcmp(PolTypeOut,"T4")==0)) distance[area] = distance[area] + Trace4_HM1xHM2(coh_m1,M);
            }
          }
        dist_min = INIT_MINMAX;
        for (area = 1; area < Narea; area++)
          if (dist_min > distance[area]) {
            dist_min = distance[area];
            TMPclass_im[ligg][col] = area;
            }
        TMPdist_im[ligg][col] = dist_min;
        mean_dist_area[(int) TMPclass_im[ligg][col]] += dist_min;
        mean_dist_area2[(int) TMPclass_im[ligg][col]] += dist_min * dist_min;
        cpt_area[(int) TMPclass_im[ligg][col]]++;

        Class_Im[ligg][col] = class_map[(int) TMPclass_im[ligg][col]];
        } else {
        Class_Im[ligg][col] = 0.;
        }
      }
    free_matrix3d_float(M, Npp, Npp);
    free_matrix3d_float(coh_m1, Npp, Npp);
    free_matrix_float(M_avg,NpolarOut);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/****************************************************
*****************************************************/

/* Saving supervised classification results bin */
  for (lig = 0; lig < Sub_Nlig; lig++)
    fwrite(&Class_Im[lig][0], sizeof(float), Sub_Ncol, class_file);
  fclose(class_file);

/****************************************************
*****************************************************/
/* Create BMP file*/
if (Bmp_flag == 1) {
  sprintf(file_name, "%s%s%dx%d", out_dir, "wishart_supervised_class_", NwinL,NwinC);
  bmp_training_set(Class_Im, Sub_Nlig, Sub_Ncol, file_name, ColorMapTrainingSet16);
  }

/********************************************************************
********************************************************************/
/* REJECTION ACCORDING TO EACH CLASS STANDARD DEVIATION */
/*
if (Rej_flag == 1) {

  for (area = 1; area < Narea; area++) {
    if (cpt_area[area] != 0) {
      mean_dist_area[area] /= cpt_area[area];
      mean_dist_area2[area] /= cpt_area[area];
      }
    std_dist_area[area] = sqrt(fabs(mean_dist_area2[area] - mean_dist_area[area] * mean_dist_area[area]));
    }
  for (lig = 0; lig < Sub_Nlig; lig++) {
    for (col = 0; col < Sub_Ncol; col++)
      if (fabs(TMPdist_im[lig][col] - mean_dist_area[(int) TMPclass_im[lig][col]]) > (std_coeff * std_dist_area[(int) TMPclass_im[lig][col]])) Class_Im[lig][col] = 0;
    }

// Saving supervised classification results bin
  sprintf(file_name, "%s%s%dx%d%s", out_dir, "wishart_supervised_class_rej_", NwinL,NwinC,".bin");
  if ((class_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  for (lig = 0; lig < Sub_Nlig; lig++)
    fwrite(&Class_Im[lig][0], sizeof(float), Sub_Ncol, class_file);
  fclose(class_file);

// Create BMP file
  if (Bmp_flag == 1) {
    sprintf(file_name, "%s%s%dx%d", out_dir, "wishart_supervised_class_rej_", NwinL,NwinC);
    bmp_training_set(Class_Im, Sub_Nlig, Sub_Ncol, file_name, ColorMapTrainingSet16);
    }
  }
*/

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(Class_Im, Sub_Nlig);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

void create_class_map(char *file_name, float *class_map)
{
  int classe, area, t_pt;
  int Nclass, Narea, Ntpt;
  float areacoord_l, areacoord_c;
  int zone;
  char Tmp[FilePathLength];
  FILE *file;

  if ((file = fopen(file_name, "r")) == NULL)
  edit_error("Could not open configuration file : ", file_name);

  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &Nclass);

  zone = 0;
  for (classe = 0; classe < Nclass; classe++) {
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%i\n", &Narea);
    for (area = 0; area < Narea; area++) {
      zone++;
      class_map[zone] = (float) classe + 1;
      fscanf(file, "%s\n", Tmp);
      fscanf(file, "%s\n", Tmp);
      fscanf(file, "%i\n", &Ntpt);
      for (t_pt = 0; t_pt < Ntpt; t_pt++) {
        fscanf(file, "%s\n", Tmp);
        fscanf(file, "%s\n", Tmp);
        fscanf(file, "%f\n", &areacoord_l);
        fscanf(file, "%s\n", Tmp);
        fscanf(file, "%f\n", &areacoord_c);
        }
      }
    }
  fclose(file);
}


