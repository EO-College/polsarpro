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

File  : gpf_supervised_classifier.c
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

Description :  Supervised maximum likelihood classification based on
               the use of the Geometric Perturbation Filter
               (Armando Marino)

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
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "C3", "C4", "T2", "T3", "T4", "SPP"};
  char file_name[FilePathLength], output_file[FilePathLength];
  char area_file[FilePathLength], cluster_file[FilePathLength];
  char ColorMapTrainingSet16[FilePathLength];

/* Internal variables */
  int ii, lig, col, k;
  int Npp;
  int ligg, Nligg;

  int Bmp_flag;
  float dist_min;
  int area, Narea;
  float threshold, RedR;
  float norm, Ptgt;
  float PtgtclassRe, PtgtclassIm, Ptgtclass;

/* Matrix arrays */
  float ***M_avg;
  float **Class_Im;
  float *M_trn;
  float *class_map;
  float **Tclass;
  float *Ttgt;
  float *distance;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ngpf_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-af  	input area file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-cf  	input cluster file\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (0/1)\n");
strcat(UsageHelp," (string)	-col 	input colormap file (valid if BMP flag = 1)\n");
strcat(UsageHelp," (float) 	-thr 	threshold\n");
strcat(UsageHelp," (float) 	-redr	reduction ratio\n");
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

if(argc < 31) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-af",str_cmd_prm,area_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,output_file,1,UsageHelp);
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
  get_commandline_prm(argc,argv,"-thr",flt_cmd_prm,&threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-redr",flt_cmd_prm,&RedR,1,UsageHelp);

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
  check_file(cluster_file);
  check_file(ColorMapTrainingSet16);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  if (Bmp_flag != 0) Bmp_flag = 1;

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
  sprintf(file_name, "%s.bin", output_file);
  check_file(file_name);
  if ((class_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  sprintf(file_name, "%s%s", out_dir, "gpf_training_cluster_centers.txt");
  if ((fp = fopen(file_name, "w")) == NULL)
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

  /* ClassIm = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* Mavg = NpolarOut*Nlig*Ncol */
  NBlockA += NpolarOut*Ncol; NBlockB += 0;
  
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

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
  M_trn = vector_float(NpolarOut);
  Class_Im = matrix_float(Sub_Nlig, Sub_Ncol);
    
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

/* Number of learning clusters reading */
  fread(&M_trn[0], sizeof(float), 1, trn_file);
  Narea = (int) M_trn[0] + 1;
  class_map = vector_float(Narea + 1);

  create_class_map(area_file, class_map);

/*Training class matrix memory allocation */
  if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) Npp = 2;
  if (strcmp(PolTypeOut,"C3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"C4")==0) Npp = 4;
  if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) Npp = 2;
  if (strcmp(PolTypeOut,"T3")==0) Npp = 3;
  if (strcmp(PolTypeOut,"T4")==0) Npp = 4;

  distance = vector_float(Narea+1);
  Tclass = matrix_float(Narea, Npp*Npp);
  Ttgt = vector_float(Npp*Npp);

/****************************************************/
/* TRAINING CLUSTER CENTERS READING */
  for (area = 1; area < Narea; area++) {
    fread(&M_trn[0], sizeof(float), NpolarOut, trn_file);
    if (Npp == 2) {
      Tclass[area][0] = M_trn[X211]; Tclass[area][1] = M_trn[X222];
      Tclass[area][2] = M_trn[X212_re]; Tclass[area][3] = M_trn[X212_im];
      norm = 0.;
      for (k=0; k<Npp*Npp; k++) norm += Tclass[area][k]*Tclass[area][k];
      for (k=0; k<Npp*Npp; k++) Tclass[area][k] = Tclass[area][k]/sqrt(norm);
      }
    if (Npp == 3) {
      Tclass[area][0] = M_trn[X311]; Tclass[area][1] = M_trn[X322]; Tclass[area][2] = M_trn[X333];
      Tclass[area][3] = M_trn[X312_re]; Tclass[area][4] = M_trn[X312_im];
      Tclass[area][5] = M_trn[X313_re]; Tclass[area][6] = M_trn[X313_im];
      Tclass[area][7] = M_trn[X323_re]; Tclass[area][8] = M_trn[X323_im];
      norm = 0.;
      for (k=0; k<Npp*Npp; k++) norm += Tclass[area][k]*Tclass[area][k];
      for (k=0; k<Npp*Npp; k++) Tclass[area][k] = Tclass[area][k]/sqrt(norm);
      }
    if (Npp == 4) {
      Tclass[area][0] = M_trn[X411]; Tclass[area][1] = M_trn[X422];
      Tclass[area][2] = M_trn[X433]; Tclass[area][3] = M_trn[X444];
      Tclass[area][4] = M_trn[X412_re]; Tclass[area][5] = M_trn[X412_im];
      Tclass[area][6] = M_trn[X413_re]; Tclass[area][7] = M_trn[X413_im];
      Tclass[area][8] = M_trn[X414_re]; Tclass[area][9] = M_trn[X414_im];
      Tclass[area][10] = M_trn[X423_re]; Tclass[area][11] = M_trn[X423_im];
      Tclass[area][12] = M_trn[X424_re]; Tclass[area][13] = M_trn[X424_im];
      Tclass[area][14] = M_trn[X434_re]; Tclass[area][15] = M_trn[X434_im];
      norm = 0.;
      for (k=0; k<Npp*Npp; k++) norm += Tclass[area][k]*Tclass[area][k];
      for (k=0; k<Npp*Npp; k++) Tclass[area][k] = Tclass[area][k]/sqrt(norm);
      }
    }
/* save cluster center in text file */
  for (area = 1; area < Narea; area++) {
    fprintf(fp, "cluster centre # %i\n", area);
    if (Npp == 2) {
      fprintf(fp, "C11 = %e\n", Tclass[area][0]);
      fprintf(fp, "C12 = %e + j %e\n", Tclass[area][2], Tclass[area][3]);
      fprintf(fp, "C22 = %e\n", Tclass[area][1]);
      fprintf(fp, "\n");
      }
    if (Npp == 3) {
      fprintf(fp, "T11 = %e\n", Tclass[area][0]);
      fprintf(fp, "T12 = %e + j %e\n", Tclass[area][3], Tclass[area][4]);
      fprintf(fp, "T13 = %e + j %e\n", Tclass[area][5], Tclass[area][6]);
      fprintf(fp, "T22 = %e\n", Tclass[area][1]);
      fprintf(fp, "T23 = %e + j %e\n", Tclass[area][7], Tclass[area][8]);
      fprintf(fp, "T33 = %e\n", Tclass[area][2]);
      fprintf(fp, "\n");
      }
    if (Npp == 4) {
      fprintf(fp, "T11 = %e\n", Tclass[area][0]);
      fprintf(fp, "T12 = %e + j %e\n", Tclass[area][4], Tclass[area][5]);
      fprintf(fp, "T13 = %e + j %e\n", Tclass[area][6], Tclass[area][7]);
      fprintf(fp, "T14 = %e + j %e\n", Tclass[area][8], Tclass[area][9]);
      fprintf(fp, "T22 = %e\n", Tclass[area][1]);
      fprintf(fp, "T23 = %e + j %e\n", Tclass[area][10], Tclass[area][11]);
      fprintf(fp, "T24 = %e + j %e\n", Tclass[area][12], Tclass[area][13]);
      fprintf(fp, "T33 = %e\n", Tclass[area][2]);
      fprintf(fp, "T34 = %e + j %e\n", Tclass[area][14], Tclass[area][15]);
      fprintf(fp, "T44 = %e\n", Tclass[area][3]);
      fprintf(fp, "\n");
      }
    }
  fclose(fp);

/****************************************************/
/****************************************************/
ligg = 0; Nligg = 0;

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
  if (strcmp(PolTypeOut,"T2")==0) T2_to_C2(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0); 
  if (strcmp(PolTypeOut,"C4")==0) C4_to_T4(M_avg, NligBlock[Nb], Sub_Ncol, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (Npp == 2) {
          Ttgt[0] = M_avg[X211][lig][col]; Ttgt[1] = M_avg[X222][lig][col];
          Ttgt[2] = M_avg[X212_re][lig][col]; Ttgt[3] = M_avg[X212_im][lig][col];
          Ptgt = 0.;
          for (k=0; k<Npp*Npp; k++) Ptgt += Ttgt[k]*Ttgt[k];
          for (area = 1; area < Narea; area++) {
            Ptgtclass = 0.; PtgtclassRe = 0.; PtgtclassIm = 0.;
            PtgtclassRe += Tclass[area][X211]*Ttgt[X211];
            PtgtclassRe += Tclass[area][X222]*Ttgt[X222];
            PtgtclassRe += Tclass[area][X212_re]*Ttgt[X212_re]+Tclass[area][X212_im]*Ttgt[X212_im];
            PtgtclassIm += -Tclass[area][X212_re]*Ttgt[X212_im]+Tclass[area][X212_im]*Ttgt[X212_re];
            Ptgtclass = PtgtclassRe * PtgtclassRe + PtgtclassIm * PtgtclassIm;
            distance[area] = 1. / sqrt(1. + RedR*((Ptgt/(Ptgtclass+eps)) - 1.));
            if (distance[area] <= threshold) distance[area] = 0.;
            }
          }
        if (Npp == 3) {
          Ttgt[0] = M_avg[X311][lig][col]; Ttgt[1] = M_avg[X322][lig][col]; Ttgt[2] = M_avg[X333][lig][col];
          Ttgt[3] = M_avg[X312_re][lig][col]; Ttgt[4] = M_avg[X312_im][lig][col];
          Ttgt[5] = M_avg[X313_re][lig][col]; Ttgt[6] = M_avg[X313_im][lig][col];
          Ttgt[7] = M_avg[X323_re][lig][col]; Ttgt[8] = M_avg[X323_im][lig][col];
          Ptgt = 0.;
          for (k=0; k<Npp*Npp; k++) Ptgt += Ttgt[k]*Ttgt[k];
          for (area = 1; area < Narea; area++) {
            Ptgtclass = 0.; PtgtclassRe = 0.; PtgtclassIm = 0.;
            PtgtclassRe += Tclass[area][X311]*Ttgt[X311];
            PtgtclassRe += Tclass[area][X322]*Ttgt[X322];
            PtgtclassRe += Tclass[area][X333]*Ttgt[X333];
            PtgtclassRe += Tclass[area][X312_re]*Ttgt[X312_re]+Tclass[area][X312_im]*Ttgt[X312_im];
            PtgtclassIm += -Tclass[area][X312_re]*Ttgt[X312_im]+Tclass[area][X312_im]*Ttgt[X312_re];
            PtgtclassRe += Tclass[area][X313_re]*Ttgt[X313_re]+Tclass[area][X313_im]*Ttgt[X313_im];
            PtgtclassIm += -Tclass[area][X313_re]*Ttgt[X313_im]+Tclass[area][X313_im]*Ttgt[X313_re];
            PtgtclassRe += Tclass[area][X323_re]*Ttgt[X323_re]+Tclass[area][X323_im]*Ttgt[X323_im];
            PtgtclassIm += -Tclass[area][X323_re]*Ttgt[X323_im]+Tclass[area][X323_im]*Ttgt[X323_re];
            Ptgtclass = PtgtclassRe * PtgtclassRe + PtgtclassIm * PtgtclassIm;
            distance[area] = 1. / sqrt(1. + RedR*((Ptgt/(Ptgtclass+eps)) - 1.));
            if (distance[area] <= threshold) distance[area] = 0.;
            }
          }
        if (Npp == 4) {
          Ttgt[0] = M_avg[X411][lig][col]; Ttgt[1] = M_avg[X422][lig][col];
          Ttgt[2] = M_avg[X433][lig][col]; Ttgt[3] = M_avg[X444][lig][col];
          Ttgt[4] = M_avg[X412_re][lig][col]; Ttgt[5] = M_avg[X412_im][lig][col];
          Ttgt[6] = M_avg[X413_re][lig][col]; Ttgt[7] = M_avg[X413_im][lig][col];
          Ttgt[8] = M_avg[X414_re][lig][col]; Ttgt[9] = M_avg[X414_im][lig][col];
          Ttgt[10] = M_avg[X423_re][lig][col]; Ttgt[11] = M_avg[X423_im][lig][col];
          Ttgt[12] = M_avg[X424_re][lig][col]; Ttgt[13] = M_avg[X424_im][lig][col];
          Ttgt[14] = M_avg[X434_re][lig][col]; Ttgt[15] = M_avg[X434_im][lig][col];
          Ptgt = 0.;
          for (k=0; k<Npp*Npp; k++) Ptgt += Ttgt[k]*Ttgt[k];
          for (area = 1; area < Narea; area++) {
            Ptgtclass = 0.; PtgtclassRe = 0.; PtgtclassIm = 0.;
            PtgtclassRe += Tclass[area][X411]*Ttgt[X411];
            PtgtclassRe += Tclass[area][X422]*Ttgt[X422];
            PtgtclassRe += Tclass[area][X433]*Ttgt[X433];
            PtgtclassRe += Tclass[area][X412_re]*Ttgt[X412_re]+Tclass[area][X412_im]*Ttgt[X412_im];
            PtgtclassIm += -Tclass[area][X412_re]*Ttgt[X412_im]+Tclass[area][X412_im]*Ttgt[X412_re];
            PtgtclassRe += Tclass[area][X413_re]*Ttgt[X413_re]+Tclass[area][X413_im]*Ttgt[X413_im];
            PtgtclassIm += -Tclass[area][X413_re]*Ttgt[X413_im]+Tclass[area][X413_im]*Ttgt[X413_re];
            PtgtclassRe += Tclass[area][X414_re]*Ttgt[X414_re]+Tclass[area][X414_im]*Ttgt[X414_im];
            PtgtclassIm += -Tclass[area][X414_re]*Ttgt[X414_im]+Tclass[area][X414_im]*Ttgt[X414_re];
            PtgtclassRe += Tclass[area][X423_re]*Ttgt[X423_re]+Tclass[area][X423_im]*Ttgt[X423_im];
            PtgtclassIm += -Tclass[area][X423_re]*Ttgt[X423_im]+Tclass[area][X423_im]*Ttgt[X423_re];
            PtgtclassRe += Tclass[area][X424_re]*Ttgt[X424_re]+Tclass[area][X424_im]*Ttgt[X424_im];
            PtgtclassIm += -Tclass[area][X424_re]*Ttgt[X424_im]+Tclass[area][X424_im]*Ttgt[X424_re];
            PtgtclassRe += Tclass[area][X434_re]*Ttgt[X434_re]+Tclass[area][X434_im]*Ttgt[X434_im];
            PtgtclassIm += -Tclass[area][X434_re]*Ttgt[X434_im]+Tclass[area][X434_im]*Ttgt[X434_re];
            Ptgtclass = PtgtclassRe * PtgtclassRe + PtgtclassIm * PtgtclassIm;
            distance[area] = 1. / sqrt(1. + RedR*((Ptgt/(Ptgtclass+eps)) - 1.));
            if (distance[area] <= threshold) distance[area] = 0.;
            }
          }

        /*Seeking for the closest cluster center */
        dist_min = distance[1];
        for (area = 1; area < Narea; area++)
          if (dist_min <= distance[area]) {
            dist_min = distance[area];
            Class_Im[ligg][col] = class_map[area];
            }
        if (dist_min == 0.) Class_Im[ligg][col] = 0.;
        } else {
        Class_Im[ligg][col] = 0.;
        }
      }
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
  bmp_training_set(Class_Im, Sub_Nlig, Sub_Ncol, output_file, ColorMapTrainingSet16);
  }

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


