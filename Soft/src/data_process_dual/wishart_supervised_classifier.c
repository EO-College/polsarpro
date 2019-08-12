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
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL (v2.0 Eric POTTIER)
Version  : 2.0
Creation : 12/2006
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
void cplx_det_inv_coh(cplx ***mat,cplx ***res,float *det,int nb_class);
float num_classe(cplx ***icoh_moy,float *det,cplx **T,int nb_class, float *dist_min);

/* GLOBAL VARIABLES */
 cplx **nT, **nV, **nmat1, **nmat2, **T;
 float *nL;

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
  FILE *trn_file, *class_file, *fp, *tmpclass, *tmpdist;
  int Config;
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  char file_name[FilePathLength];
  char area_file[FilePathLength], cluster_file[FilePathLength];
  char ColorMapTrainingSet16[FilePathLength];

/* Internal variables */
  int ii, lig, col, k, l;
  int Npp;
  int ligg, Nligg;

  int Bmp_flag;
  int Rej_flag;
  float std_coeff, dist_min;
  int area, Narea;

/* Matrix arrays */
  float ***M_avg;

  float **Class_Im;
  float *TMPclass_im;
  float *TMPdist_im;
  float *M_trn;
  float *class_map;

  cplx ***coh_area;
  cplx ***coh_area_m1;
  float *det_area;

  float cpt_area[100];
  float mean_dist_area[100];
  float mean_dist_area2[100];
  float std_dist_area[100];
  //float distance[100];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_supervised_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
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
strcat(UsageHelp," (int)   	-rej 	rejection mode flag (0/1)\n");
strcat(UsageHelp," (float) 	-std 	distance std value for rejection\n");
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

if(argc < 27) {
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
  get_commandline_prm(argc,argv,"-rej",int_cmd_prm,&Rej_flag,1,UsageHelp);
  if (Rej_flag == 1)
    get_commandline_prm(argc,argv,"-std",flt_cmd_prm,&std_coeff,1,UsageHelp);

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

  check_dir(in_dir1);
  if (strcmp(PolType, "S2T6") == 0) check_dir(in_dir2);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(cluster_file);
  check_file(ColorMapTrainingSet16);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  if (Bmp_flag != 0) Bmp_flag = 1;
  if (Rej_flag != 0) Rej_flag = 1;

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

  sprintf(file_name, "%s%s", out_dir, "TMPclass_im.bin");
  if ((tmpclass = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  
  sprintf(file_name, "%s%s", out_dir, "TMPdist_im.bin");
  if ((tmpdist = fopen(file_name, "wb")) == NULL)
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
  _MC1_in = matrix_float(4,2*Ncol);
  _MC2_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
  M_trn = vector_float(NpolarOut);
  Class_Im = matrix_float(Sub_Nlig, Sub_Ncol);
  TMPclass_im = vector_float(Sub_Ncol);
  TMPdist_im = vector_float(Sub_Ncol);

  nT  = cplx_matrix(6,6);
  nV  = cplx_matrix(6,6);
  nmat1 = cplx_matrix(6,6);
  nmat2 = cplx_matrix(6,6);
  nL  = vector_float(6);
  T = cplx_matrix(6,6);
  
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
  Npp = 6;
  coh_area  = cplx_matrix3d(Npp,Npp,Narea);
  coh_area_m1  = cplx_matrix3d(Npp,Npp,Narea);
  det_area  = vector_float(Narea);

/****************************************************/
/* TRAINING CLUSTER CENTERS READING */
  for (area = 1; area < Narea; area++) {
    fread(&M_trn[0], sizeof(float), NpolarOut, trn_file);
    coh_area[0][0][area].re = eps + M_trn[+0];
    coh_area[0][1][area].re = eps + M_trn[+1];
    coh_area[0][1][area].im = eps + M_trn[+2];
    coh_area[0][2][area].re = eps + M_trn[+3];
    coh_area[0][2][area].im = eps + M_trn[+4];
    coh_area[0][3][area].re = eps + M_trn[+5];
    coh_area[0][3][area].im = eps + M_trn[+6];
    coh_area[0][4][area].re = eps + M_trn[+7];
    coh_area[0][4][area].im = eps + M_trn[+8];
    coh_area[0][5][area].re = eps + M_trn[+9];
    coh_area[0][5][area].im = eps + M_trn[+10];

    coh_area[1][1][area].re = eps + M_trn[+11];
    coh_area[1][2][area].re = eps + M_trn[+12];
    coh_area[1][2][area].im = eps + M_trn[+13];
    coh_area[1][3][area].re = eps + M_trn[+14];
    coh_area[1][3][area].im = eps + M_trn[+15];
    coh_area[1][4][area].re = eps + M_trn[+16];
    coh_area[1][4][area].im = eps + M_trn[+17];
    coh_area[1][5][area].re = eps + M_trn[+18];
    coh_area[1][5][area].im = eps + M_trn[+19];

    coh_area[2][2][area].re = eps + M_trn[+20];
    coh_area[2][3][area].re = eps + M_trn[+21];
    coh_area[2][3][area].im = eps + M_trn[+22];
    coh_area[2][4][area].re = eps + M_trn[+23];
    coh_area[2][4][area].im = eps + M_trn[+24];
    coh_area[2][5][area].re = eps + M_trn[+25];
    coh_area[2][5][area].im = eps + M_trn[+26];

    coh_area[3][3][area].re = eps + M_trn[+27];
    coh_area[3][4][area].re = eps + M_trn[+28];
    coh_area[3][4][area].im = eps + M_trn[+29];
    coh_area[3][5][area].re = eps + M_trn[+30];
    coh_area[3][5][area].im = eps + M_trn[+31];

    coh_area[4][4][area].re = eps + M_trn[+32];
    coh_area[4][5][area].re = eps + M_trn[+33];
    coh_area[4][5][area].im = eps + M_trn[+34];

    coh_area[5][5][area].re = eps + M_trn[+35];

    for (k = 0; k < 6; k++) {
      for (l = k; l < 6; l++) {
        coh_area[l][k][area].re = coh_area[k][l][area].re;
        coh_area[l][k][area].im = -coh_area[k][l][area].im;
        }
      }
    mean_dist_area[area] = 0;
    mean_dist_area[area] = 0;
    std_dist_area[area] = 0;
    }
/* save cluster center in text file */
  for (area = 1; area < Narea; area++) {
    fprintf(fp, "cluster centre # %i\n", area);
    fprintf(fp, "T11 = %e\n", coh_area[0][0][area].re);
    fprintf(fp, "T12 = %e + j %e\n", coh_area[0][1][area].re,coh_area[0][1][area].im);
    fprintf(fp, "T13 = %e + j %e\n", coh_area[0][2][area].re,coh_area[0][2][area].im);
    fprintf(fp, "T14 = %e + j %e\n", coh_area[0][3][area].re,coh_area[0][3][area].im);
    fprintf(fp, "T15 = %e + j %e\n", coh_area[0][4][area].re,coh_area[0][4][area].im);
    fprintf(fp, "T16 = %e + j %e\n", coh_area[0][5][area].re,coh_area[0][5][area].im);
    fprintf(fp, "T22 = %e\n", coh_area[1][1][area].re);
    fprintf(fp, "T23 = %e + j %e\n", coh_area[1][2][area].re,coh_area[1][2][area].im);
    fprintf(fp, "T24 = %e + j %e\n", coh_area[1][3][area].re,coh_area[1][3][area].im);
    fprintf(fp, "T25 = %e + j %e\n", coh_area[1][4][area].re,coh_area[1][4][area].im);
    fprintf(fp, "T26 = %e + j %e\n", coh_area[1][5][area].re,coh_area[1][5][area].im);
    fprintf(fp, "T33 = %e\n", coh_area[2][2][area].re);
    fprintf(fp, "T34 = %e + j %e\n", coh_area[2][3][area].re,coh_area[2][3][area].im);
    fprintf(fp, "T35 = %e + j %e\n", coh_area[2][4][area].re,coh_area[2][4][area].im);
    fprintf(fp, "T36 = %e + j %e\n", coh_area[2][5][area].re,coh_area[2][5][area].im);
    fprintf(fp, "T44 = %e\n", coh_area[3][3][area].re);
    fprintf(fp, "T45 = %e + j %e\n", coh_area[3][4][area].re,coh_area[3][4][area].im);
    fprintf(fp, "T46 = %e + j %e\n", coh_area[3][5][area].re,coh_area[3][5][area].im);
    fprintf(fp, "T55 = %e\n", coh_area[4][4][area].re);
    fprintf(fp, "T56 = %e + j %e\n", coh_area[4][5][area].re,coh_area[4][5][area].im);
    fprintf(fp, "T66 = %e\n", coh_area[5][5][area].re);
    fprintf(fp, "\n");
    }
  fclose(fp);

/* Inverse center coherency matrices computation */
  cplx_det_inv_coh(coh_area,coh_area_m1,det_area,Narea);

/****************************************************/
/****************************************************/
ligg = 0; Nligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  if (strcmp(PolTypeIn,"S2")==0) {
    read_block_S2T6_avg(in_datafile1, in_datafile2, M_avg, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    } else {
    /* Case of T6 */
    read_block_TCI_avg(in_datafile1, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, NwinL, NwinC, Off_lig, Off_col, Ncol);
    }

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        T[0][0].re = eps + M_avg[+0][lig][col];
        T[0][1].re = eps + M_avg[+1][lig][col];
        T[0][1].im = eps + M_avg[+2][lig][col];
        T[0][2].re = eps + M_avg[+3][lig][col];
        T[0][2].im = eps + M_avg[+4][lig][col];
        T[0][3].re = eps + M_avg[+5][lig][col];
        T[0][3].im = eps + M_avg[+6][lig][col];
        T[0][4].re = eps + M_avg[+7][lig][col];
        T[0][4].im = eps + M_avg[+8][lig][col];
        T[0][5].re = eps + M_avg[+9][lig][col];
        T[0][5].im = eps + M_avg[+10][lig][col];

        T[1][1].re = eps + M_avg[+11][lig][col];
        T[1][2].re = eps + M_avg[+12][lig][col];
        T[1][2].im = eps + M_avg[+13][lig][col];
        T[1][3].re = eps + M_avg[+14][lig][col];
        T[1][3].im = eps + M_avg[+15][lig][col];
        T[1][4].re = eps + M_avg[+16][lig][col];
        T[1][4].im = eps + M_avg[+17][lig][col];
        T[1][5].re = eps + M_avg[+18][lig][col];
        T[1][5].im = eps + M_avg[+19][lig][col];

        T[2][2].re = eps + M_avg[+20][lig][col];
        T[2][3].re = eps + M_avg[+21][lig][col];
        T[2][3].im = eps + M_avg[+22][lig][col];
        T[2][4].re = eps + M_avg[+23][lig][col];
        T[2][4].im = eps + M_avg[+24][lig][col];
        T[2][5].re = eps + M_avg[+25][lig][col];
        T[2][5].im = eps + M_avg[+26][lig][col];

        T[3][3].re = eps + M_avg[+27][lig][col];
        T[3][4].re = eps + M_avg[+28][lig][col];
        T[3][4].im = eps + M_avg[+29][lig][col];
        T[3][5].re = eps + M_avg[+30][lig][col];
        T[3][5].im = eps + M_avg[+31][lig][col];

        T[4][4].re = eps + M_avg[+32][lig][col];
        T[4][5].re = eps + M_avg[+33][lig][col];
        T[4][5].im = eps + M_avg[+34][lig][col];

        T[5][5].re = eps + M_avg[+35][lig][col];

        /*Seeking for the closest cluster center */
        TMPclass_im[col] = num_classe(coh_area_m1,det_area,T,Narea,&dist_min);
        TMPdist_im[col] = dist_min;
        mean_dist_area[(int) TMPclass_im[col]] += dist_min;
        mean_dist_area2[(int) TMPclass_im[col]] += dist_min * dist_min;
        cpt_area[(int) TMPclass_im[col]]++;

        Class_Im[ligg][col] = class_map[(int) TMPclass_im[col]];
        } else {
        Class_Im[ligg][col] = 0.;
        }
      }
    fwrite(&TMPclass_im[0], sizeof(float), Sub_Ncol, tmpclass);
    fwrite(&TMPdist_im[0], sizeof(float), Sub_Ncol, tmpdist);
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/****************************************************
*****************************************************/
  fclose(tmpclass);
  fclose(tmpdist);

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
if (Rej_flag == 1) {
  sprintf(file_name, "%s%s", out_dir, "TMPclass_im.bin");
  if ((tmpclass = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  sprintf(file_name, "%s%s", out_dir, "TMPdist_im.bin");
  if ((tmpdist = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  for (area = 1; area < Narea; area++) {
    if (cpt_area[area] != 0) {
      mean_dist_area[area] /= cpt_area[area];
      mean_dist_area2[area] /= cpt_area[area];
      }
    std_dist_area[area] = sqrt(fabs(mean_dist_area2[area] - mean_dist_area[area] * mean_dist_area[area]));
    }
  for (lig = 0; lig < Sub_Nlig; lig++) {
    fread(&TMPclass_im[0], sizeof(float), Sub_Ncol, tmpclass);
    fread(&TMPdist_im[0], sizeof(float), Sub_Ncol, tmpdist);
    for (col = 0; col < Sub_Ncol; col++)
      if (fabs(TMPdist_im[col] - mean_dist_area[(int) TMPclass_im[col]]) > (std_coeff * std_dist_area[(int) TMPclass_im[col]])) Class_Im[lig][col] = 0;
    }

/* Saving supervised classification results bin */
  sprintf(file_name, "%s%s%dx%d%s", out_dir, "wishart_supervised_class_rej_", NwinL,NwinC,".bin");
  if ((class_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);
  for (lig = 0; lig < Sub_Nlig; lig++)
    fwrite(&Class_Im[lig][0], sizeof(float), Sub_Ncol, class_file);
  fclose(class_file);

/* Create BMP file*/
  if (Bmp_flag == 1) {
    sprintf(file_name, "%s%s%dx%d", out_dir, "wishart_supervised_class_rej_", NwinL,NwinC);
    bmp_training_set(Class_Im, Sub_Nlig, Sub_Ncol, file_name, ColorMapTrainingSet16);
    }
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

/********************************************************************
********************************************************************/
float num_classe(cplx ***icoh_moy,float *det,cplx **T,int nb_class, float *dist_min)
{
 float min,dist,r;
 int cl;
/* int l,c;*/

min=INIT_MINMAX;
for(cl=1;cl<nb_class;cl++) {
  dist = log(det[cl])
  +icoh_moy[0][0][cl].re*T[0][0].re
  +icoh_moy[1][1][cl].re*T[1][1].re
  +icoh_moy[2][2][cl].re*T[2][2].re
  +icoh_moy[3][3][cl].re*T[3][3].re
  +icoh_moy[4][4][cl].re*T[4][4].re
  +icoh_moy[5][5][cl].re*T[5][5].re
  +2*(icoh_moy[0][1][cl].re*T[0][1].re+icoh_moy[0][1][cl].im*T[0][1].im)
  +2*(icoh_moy[0][2][cl].re*T[0][2].re+icoh_moy[0][2][cl].im*T[0][2].im)
  +2*(icoh_moy[0][3][cl].re*T[0][3].re+icoh_moy[0][3][cl].im*T[0][3].im)
  +2*(icoh_moy[0][4][cl].re*T[0][4].re+icoh_moy[0][4][cl].im*T[0][4].im)
  +2*(icoh_moy[0][5][cl].re*T[0][5].re+icoh_moy[0][5][cl].im*T[0][5].im)
  +2*(icoh_moy[1][2][cl].re*T[1][2].re+icoh_moy[1][2][cl].im*T[1][2].im)
  +2*(icoh_moy[1][3][cl].re*T[1][3].re+icoh_moy[1][3][cl].im*T[1][3].im)
  +2*(icoh_moy[1][4][cl].re*T[1][4].re+icoh_moy[1][4][cl].im*T[1][4].im)
  +2*(icoh_moy[1][5][cl].re*T[1][5].re+icoh_moy[1][5][cl].im*T[1][5].im)
  +2*(icoh_moy[2][3][cl].re*T[2][3].re+icoh_moy[2][3][cl].im*T[2][3].im)
  +2*(icoh_moy[2][4][cl].re*T[2][4].re+icoh_moy[2][4][cl].im*T[2][4].im)
  +2*(icoh_moy[2][5][cl].re*T[2][5].re+icoh_moy[2][5][cl].im*T[2][5].im)
  +2*(icoh_moy[3][4][cl].re*T[3][4].re+icoh_moy[3][4][cl].im*T[3][4].im)
  +2*(icoh_moy[3][5][cl].re*T[3][5].re+icoh_moy[3][5][cl].im*T[3][5].im)
  +2*(icoh_moy[4][5][cl].re*T[4][5].re+icoh_moy[4][5][cl].im*T[4][5].im);
  if(dist<min) {
    min = dist;
    r = cl;
    }
  }
  *dist_min = min;
  return(r);
}

/********************************************************************
********************************************************************/
void cplx_det_inv_coh(cplx ***mat,cplx ***res,float *det,int nb_class)
{
 int cl,l,c;

 for(cl=1;cl<nb_class;cl++) {

  for(l=0;l<6;l++)
    for(c=0;c<6;c++) {
      nT[l][c].re = mat[l][c][cl].re;
      nT[l][c].im = mat[l][c][cl].im;
      nmat1[l][c].re = 0;
      nmat1[l][c].im = 0;
      }

  cplx_diag_mat6(nT,nV,nL);

  det[cl]=1;
  for(l=0;l<6;l++) {
    det[cl] *= fabs(nL[l]);
    nmat1[l][l].re = 1/nL[l];
    }
  cplx_htransp_mat(nV,nT,6,6);
  cplx_mul_mat(nmat1,nT,nmat2,6,6);
  cplx_mul_mat(nV,nmat2,nmat1,6,6);

  for(l=0;l<6;l++)
    for(c=0;c<6;c++) {
      res[l][c][cl].re = nmat1[l][c].re;
      res[l][c][cl].im = nmat1[l][c].im;
      }
    }
}

