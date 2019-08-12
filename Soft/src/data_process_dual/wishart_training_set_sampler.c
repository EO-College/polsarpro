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

File  : wishart_training_set_sampler.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL (v2.0 Eric POTTIER)
Version  : 2.0
Creation : 07/2003 (v2.0 08/2012)
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

Description :  Sampling of full polar coherency matrices from an 
image using user defined pixel coordinates

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

//*Area parameters */
#define Lig_init 0
#define Col_init 1
#define Lig_nb  2
#define Col_nb  3

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void read_coord(char *file_name);
void create_borders(float **border_map);
void create_areas(float **border_map, int Nlig, int Ncol);

/* GLOBAL VARIABLES */
int N_class;
int *N_area;
int **N_t_pt;
float ***area_coord_l;
float ***area_coord_c;
float *class_map;
float **im;

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
  FILE *trn_file;
  int Config;
  char *PolTypeConf[NPolType] = {"S2T6", "T6"};
  char file_name[FilePathLength];
  char area_file[FilePathLength], cluster_file[FilePathLength];
  char ColorMapTrainingSet16[FilePathLength];

/* Internal variables */
  int ii, lig, col, k, l;
  int Npp;

  int Bmp_flag;
  int border_error_flag = 0;
  int N_zones, zone;
  int classe, area, t_pt;

/* Matrix arrays */
  float **border_map;
  float ***M_in;
  float ***S_in1;
  float ***S_in2;
  float *M_trn;
  float *ValidMask;

  float M[6][6][2];
  float *coh_area[6][6][2];
  float *cpt_zones;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_training_set_sampler.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," if iodf = S2T6\n");
strcat(UsageHelp," (string)	-idm 	input master directory\n");
strcat(UsageHelp," (string)	-ids 	input slave directory\n");
strcat(UsageHelp," if iodf = T6\n");
strcat(UsageHelp," (string)	-id  	input master-slave directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-af  	input area file\n");
strcat(UsageHelp," (string)	-cf  	output cluster file\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (0/1)\n");
strcat(UsageHelp," (string)	-col 	input colormap file (valid if BMP flag = 1)\n");
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

if(argc < 13) {
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
  get_commandline_prm(argc,argv,"-cf",str_cmd_prm,cluster_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&Bmp_flag,1,UsageHelp);
  if (Bmp_flag == 1)
  get_commandline_prm(argc,argv,"-col",str_cmd_prm,ColorMapTrainingSet16,1,UsageHelp);

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
  check_file(area_file);
  check_file(cluster_file);
  if (Bmp_flag == 1) check_file(ColorMapTrainingSet16);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  if (Bmp_flag != 0) Bmp_flag = 1;

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

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  ValidMask = vector_float(Ncol);

  if (strcmp(PolTypeIn,"S2")==0) {
    S_in1 = matrix3d_float(NpolarIn, 2, Ncol);
    S_in2 = matrix3d_float(NpolarIn, 2, Ncol);
    }

  M_in = matrix3d_float(NpolarOut, 2, Ncol);
  im = matrix_float(Nlig, Ncol);
  border_map = matrix_float(Nlig, Ncol);
  M_trn = vector_float(NpolarOut);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) 
      ValidMask[col] = 1.;
 
/********************************************************************
********************************************************************/
/* DATA PROCESSING */

/* Training Area coordinates reading */
  read_coord(area_file);

  for (lig = 0; lig < Nlig; lig++)
    for (col = 0; col < Ncol; col++)
      border_map[lig][col] = -1;

  create_borders(border_map);

  create_areas(border_map, Nlig, Ncol);

/*Training class matrix memory allocation */
  N_zones = 0;
  for (classe = 0; classe < N_class; classe++) N_zones += N_area[classe];

  cpt_zones = vector_float(N_zones);

  Npp = 6;
  //M = matrix3d_float(Npp, Npp, 2);
  for (k = 0; k < Npp; k++) {
    for (l = 0; l < Npp; l++) {
      coh_area[k][l][0] = vector_float(N_zones);
      coh_area[k][l][1] = vector_float(N_zones);
      }
    }

/****************************************************/
 zone = -1;
 for (classe = 0; classe < N_class; classe++) {
  //printf("%f\r", 100. * (classe +1)/ N_class);fflush(stdout);
  for (area = 0; area < N_area[classe]; area++) {
  zone++;
  Off_lig = 2 * Nlig;
  Off_col = 2 * Ncol;
  Sub_Nlig = -1;
  Sub_Ncol = -1;

  for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
    if (area_coord_l[classe][area][t_pt] < Off_lig) Off_lig = area_coord_l[classe][area][t_pt];
    if (area_coord_c[classe][area][t_pt] < Off_col) Off_col = area_coord_c[classe][area][t_pt];
    if (area_coord_l[classe][area][t_pt] > Sub_Nlig) Sub_Nlig = area_coord_l[classe][area][t_pt];
    if (area_coord_c[classe][area][t_pt] > Sub_Ncol) Sub_Ncol = area_coord_c[classe][area][t_pt];
    }
  Sub_Nlig = Sub_Nlig - Off_lig + 1;
  Sub_Ncol = Sub_Ncol - Off_col + 1;

  cpt_zones[zone] = 0;

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);

/****************************************************/

  for (lig = 0; lig < Off_lig; lig++) {
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    for (Np = 0; Np < NpolarIn; Np++) {
      if (strcmp(PolTypeIn,"S2")==0) {
        fread(&S_in1[Np][0][0], sizeof(float), 2*Ncol, in_datafile1[Np]);
        fread(&S_in2[Np][0][0], sizeof(float), 2*Ncol, in_datafile2[Np]);
        } else {
        fread(&M_in[Np][0][0], sizeof(float), Ncol, in_datafile1[Np]);
        }
      }
    }

  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

    if (strcmp(PolTypeIn,"S2")==0) {
      for (Np = 0; Np < NpolarIn; Np++) fread(&S_in1[Np][0][0], sizeof(float), 2*Ncol, in_datafile1[Np]);
      for (Np = 0; Np < NpolarIn; Np++) fread(&S_in2[Np][0][0], sizeof(float), 2*Ncol, in_datafile2[Np]);
      S2_to_T6(S_in1, S_in2, M_in, 1, Ncol, 0, 0);
      } else {
      for (Np = 0; Np < NpolarIn; Np++) fread(&M_in[Np][0][0], sizeof(float), Ncol, in_datafile1[Np]);
      }

    for (col = 0; col < Sub_Ncol; col++) {
      if (ValidMask[col] == 1.) {
        if (border_map[lig + Off_lig][col + Off_col] == zone) {
          /* Average complex coherency matrix determination*/
          M[0][0][0] = eps + M_in[+0][0][col + Off_col];
          M[0][1][0] = eps + M_in[+1][0][col + Off_col];
          M[0][1][1] = eps + M_in[+2][0][col + Off_col];
          M[0][2][0] = eps + M_in[+3][0][col + Off_col];
          M[0][2][1] = eps + M_in[+4][0][col + Off_col];
          M[0][3][0] = eps + M_in[+5][0][col + Off_col];
          M[0][3][1] = eps + M_in[+6][0][col + Off_col];
          M[0][4][0] = eps + M_in[+7][0][col + Off_col];
          M[0][4][1] = eps + M_in[+8][0][col + Off_col];
          M[0][5][0] = eps + M_in[+9][0][col + Off_col];
          M[0][5][1] = eps + M_in[+10][0][col + Off_col];

          M[1][1][0] = eps + M_in[+11][0][col + Off_col];
          M[1][2][0] = eps + M_in[+12][0][col + Off_col];
          M[1][2][1] = eps + M_in[+13][0][col + Off_col];
          M[1][3][0] = eps + M_in[+14][0][col + Off_col];
          M[1][3][1] = eps + M_in[+15][0][col + Off_col];
          M[1][4][0] = eps + M_in[+16][0][col + Off_col];
          M[1][4][1] = eps + M_in[+17][0][col + Off_col];
          M[1][5][0] = eps + M_in[+18][0][col + Off_col];
          M[1][5][1] = eps + M_in[+19][0][col + Off_col];

          M[2][2][0] = eps + M_in[+20][0][col + Off_col];
          M[2][3][0] = eps + M_in[+21][0][col + Off_col];
          M[2][3][1] = eps + M_in[+22][0][col + Off_col];
          M[2][4][0] = eps + M_in[+23][0][col + Off_col];
          M[2][4][1] = eps + M_in[+24][0][col + Off_col];
          M[2][5][0] = eps + M_in[+25][0][col + Off_col];
          M[2][5][1] = eps + M_in[+26][0][col + Off_col];

          M[3][3][0] = eps + M_in[+27][0][col + Off_col];
          M[3][4][0] = eps + M_in[+28][0][col + Off_col];
          M[3][4][1] = eps + M_in[+29][0][col + Off_col];
          M[3][5][0] = eps + M_in[+30][0][col + Off_col];
          M[3][5][1] = eps + M_in[+31][0][col + Off_col];

          M[4][4][0] = eps + M_in[+32][0][col + Off_col];
          M[4][5][0] = eps + M_in[+33][0][col + Off_col];
          M[4][5][1] = eps + M_in[+34][0][col + Off_col];

          M[5][5][0] = eps + M_in[+35][0][col + Off_col];
          
          /*Assigning M to the corresponding training coherency matrix */
          for (k = 0; k < Npp; k++)
            for (l = 0; l < Npp; l++) {
              coh_area[k][l][0][zone] = coh_area[k][l][0][zone] + M[k][l][0];
              coh_area[k][l][1][zone] = coh_area[k][l][1][zone] + M[k][l][1];
              }
          cpt_zones[zone] = cpt_zones[zone] + 1.;

          //Check if the pixel has already been assigned to a previous class
          //Avoid overlapped classes
          if (im[lig+Off_lig][col+Off_col] != 0) border_error_flag = 1;
          im[lig+Off_lig][col+Off_col] = zone + 1;
          }
        } else {
        im[lig+Off_lig][col+Off_col] = 0;
        }
      }
    }

  for (k = 0; k < Npp; k++)
    for (l = 0; l < Npp; l++) {
      coh_area[k][l][0][zone] = coh_area[k][l][0][zone] / cpt_zones[zone];
      coh_area[k][l][1][zone] = coh_area[k][l][1][zone] / cpt_zones[zone];
      }
  
/****************************************************/

  } /*area */
  } /* Class */

/****************************************************
*****************************************************/
/* Saving training data sets*/
if (border_error_flag == 0) {

  strcpy(file_name, cluster_file);
  if ((trn_file = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  M_trn[0] = (float) N_zones;
  fwrite(&M_trn[0], sizeof(float), 1, trn_file);

  for (zone = 0; zone < N_zones; zone++) {
    M_trn[+0] = coh_area[0][0][0][zone];
    M_trn[+1] = coh_area[0][1][0][zone];
    M_trn[+2] = coh_area[0][1][1][zone];
    M_trn[+3] = coh_area[0][2][0][zone];
    M_trn[+4] = coh_area[0][2][1][zone];
    M_trn[+5] = coh_area[0][3][0][zone];
    M_trn[+6] = coh_area[0][3][1][zone];
    M_trn[+7] = coh_area[0][4][0][zone];
    M_trn[+8] = coh_area[0][4][1][zone];
    M_trn[+9] = coh_area[0][5][0][zone];
    M_trn[+10] = coh_area[0][5][1][zone];

    M_trn[+11] = coh_area[1][1][0][zone];
    M_trn[+12] = coh_area[1][2][0][zone];
    M_trn[+13] = coh_area[1][2][1][zone];
    M_trn[+14] = coh_area[1][3][0][zone];
    M_trn[+15] = coh_area[1][3][1][zone];
    M_trn[+16] = coh_area[1][4][0][zone];
    M_trn[+17] = coh_area[1][4][1][zone];
    M_trn[+18] = coh_area[1][5][0][zone];
    M_trn[+19] = coh_area[1][5][1][zone];

    M_trn[+20] = coh_area[2][2][0][zone];
    M_trn[+21] = coh_area[2][3][0][zone];
    M_trn[+22] = coh_area[2][3][1][zone];
    M_trn[+23] = coh_area[2][4][0][zone];
    M_trn[+24] = coh_area[2][4][1][zone];
    M_trn[+25] = coh_area[2][5][0][zone];
    M_trn[+26] = coh_area[2][5][1][zone];

    M_trn[+27] = coh_area[3][3][0][zone];
    M_trn[+28] = coh_area[3][4][0][zone];
    M_trn[+29] = coh_area[3][4][1][zone];
    M_trn[+30] = coh_area[3][5][0][zone];
    M_trn[+31] = coh_area[3][5][1][zone];

    M_trn[+32] = coh_area[4][4][0][zone];
    M_trn[+33] = coh_area[4][5][0][zone];
    M_trn[+34] = coh_area[4][5][1][zone];

    M_trn[+35] = coh_area[5][5][0][zone];
    fwrite(&M_trn[0], sizeof(float), NpolarOut, trn_file);
    }
  }

/****************************************************
*****************************************************/
/* Create BMP file*/
if (Bmp_flag == 1) {
  for (lig = 0; lig < Nlig; lig++)
    for (col = 0; col < Ncol; col++)
      im[lig][col] = class_map[(int) im[lig][col]];
  sprintf(file_name, "%s%s", out_dir, "wishart_training_cluster_set");
  bmp_training_set(im, Nlig, Ncol, file_name, ColorMapTrainingSet16);
  }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_vector_float(ValidMask);

  if (strcmp(PolTypeIn,"S2")==0) {
    free_matrix3d_float(S_in1, NpolarIn, 2);
    free_matrix3d_float(S_in2, NpolarIn, 2);
    }

  free_matrix3d_float(M_in, NpolarOut, 2);
  free_matrix_float(im, Nlig);
  free_matrix_float(border_map, Nlig);
*/
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

  fclose(trn_file);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/

/*******************************************************************
Routine  : read_coord
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update  :
*-------------------------------------------------------------------
Description :  Read training area coordinates
*-------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************/
void read_coord(char *file_name)
{

  int classe, area, t_pt, zone;
  char Tmp[FilePathLength];
  FILE *file;

  if ((file = fopen(file_name, "r")) == NULL)
  edit_error("Could not open configuration file : ", file_name);

  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &N_class);

  N_area = vector_int(N_class);

  N_t_pt = (int **) malloc((unsigned) (N_class) * sizeof(int *));
  area_coord_l = (float ***) malloc((unsigned) (N_class) * sizeof(float **));
  area_coord_c = (float ***) malloc((unsigned) (N_class) * sizeof(float **));

  zone = 0;

  for (classe = 0; classe < N_class; classe++) {
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%s\n", Tmp);
  fscanf(file, "%i\n", &N_area[classe]);

  N_t_pt[classe] = vector_int(N_area[classe]);
  area_coord_l[classe] = (float **) malloc((unsigned) (N_area[classe]) * sizeof(float *));
  area_coord_c[classe] = (float **) malloc((unsigned) (N_area[classe]) * sizeof(float *));

  for (area = 0; area < N_area[classe]; area++) {
    zone++;
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%s\n", Tmp);
    fscanf(file, "%i\n", &N_t_pt[classe][area]);
    area_coord_l[classe][area] = vector_float(N_t_pt[classe][area] + 1);
    area_coord_c[classe][area] = vector_float(N_t_pt[classe][area] + 1);
    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
      fscanf(file, "%s\n", Tmp);
      fscanf(file, "%s\n", Tmp);
      fscanf(file, "%f\n", &area_coord_l[classe][area][t_pt]);
      fscanf(file, "%s\n", Tmp);
      fscanf(file, "%f\n", &area_coord_c[classe][area][t_pt]);
      }
    area_coord_l[classe][area][t_pt] = area_coord_l[classe][area][0];
    area_coord_c[classe][area][t_pt] = area_coord_c[classe][area][0];
    }
  }
  class_map = vector_float(zone + 1);
  class_map[0] = 0;
  zone = 0;
  for (classe = 0; classe < N_class; classe++)
  for (area = 0; area < N_area[classe]; area++) {
    zone++;
    class_map[zone] = (float) classe + 1.;
    }
  fclose(file);

}

/*******************************************************************
Routine  : create_borders
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update  :
*-------------------------------------------------------------------
Description : Create borders
*-------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************/
void create_borders(float **border_map)
{

  int classe, area, t_pt;
  float label_area, x, y, x0, y0, x1, y1, sig_x, sig_y, sig_y_sol, y_sol, A, B;

  label_area = -1;

  for (classe = 0; classe < N_class; classe++) {
    for (area = 0; area < N_area[classe]; area++) {
      label_area++;
      for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
        x0 = area_coord_c[classe][area][t_pt];
        y0 = area_coord_l[classe][area][t_pt];
        x1 = area_coord_c[classe][area][t_pt + 1];
        y1 = area_coord_l[classe][area][t_pt + 1];
        x = x0;
        y = y0;
        sig_x = (x1 > x0) - (x1 < x0);
        sig_y = (y1 > y0) - (y1 < y0);
        border_map[(int) y][(int) x] = label_area;
        if (x0 == x1) {
/* Vertical segment */
          while (y != y1) {
            y += sig_y;
            border_map[(int) y][(int) x] = label_area;
            }
          } else {
          if (y0 == y1) {
/* Horizontal segment */
            while (x != x1) {
              x += sig_x;
              border_map[(int) y][(int) x] = label_area;
              }
            } else {
/* Non horizontal & Non vertical segment */
            A = (y1 - y0) / (x1 - x0);  /* Segment slope  */
            B = y0 - A * x0;  /* Segment offset */
            while ((x != x1) || (y != y1)) {
              y_sol = my_round(A * (x + sig_x) + B);
              if (fabs(y_sol - y) > 1) {
                sig_y_sol = (y_sol > y) - (y_sol < y);
                while (y != y_sol) {
                  y += sig_y_sol;
                  x = my_round((y - B) / A);
                  border_map[(int) y][(int) x] =
                  label_area;
                  }
                } else {
                y = y_sol;
                x += sig_x;
                }
              border_map[(int) y][(int) x] = label_area;
              }
            }
          }
        }
      }
    }
}

/*******************************************************************
Routine  : create_areas
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update  :
*-------------------------------------------------------------------
Description : Create areas
*-------------------------------------------------------------------
Inputs arguments :

Returned values  :

********************************************************************/
void create_areas(float **border_map, int Nlig, int Ncol)
{

/* Avoid recursive algorithm due to problems encountered under Windows */
  int change_tot, change, classe, area, t_pt;
  float x, y, x_min, x_max, y_min, y_max, label_area;
  float **tmp_map;
  struct Pix *P_top, *P1, *P2;

  tmp_map = matrix_float(Nlig, Ncol);

  label_area = -1;

  for (classe = 0; classe < N_class; classe++) {
  for (area = 0; area < N_area[classe]; area++) {
    label_area++;
    x_min = Ncol;
    y_min = Nlig;
    x_max = -1;
    y_max = -1;
/* Determine a square zone containing the area under study*/
    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
      x = area_coord_c[classe][area][t_pt];
      y = area_coord_l[classe][area][t_pt];
      if (x < x_min) x_min = x;
      if (x > x_max) x_max = x;
      if (y < y_min) y_min = y;
      if (y > y_max) y_max = y;
      }
    for (x = x_min; x <= x_max; x++)
      for (y = y_min; y <= y_max; y++)
        tmp_map[(int) y][(int) x] = 0;

    for (x = x_min; x <= x_max; x++) {
      tmp_map[(int) y_min][(int) x] = -(border_map[(int) y_min][(int) x] != label_area);
      y = y_min;
      while ((y <= y_max) && (border_map[(int) y][(int) x] != label_area)) {
        tmp_map[(int) y][(int) x] = -1;
        y++;
        }
      tmp_map[(int) y_max][(int) x] = -(border_map[(int) y_max][(int) x] != label_area);
      y = y_max;
      while ((y >= y_min) && (border_map[(int) y][(int) x] != label_area)) {
        tmp_map[(int) y][(int) x] = -1;
        y--;
        }
      }
    for (y = y_min; y <= y_max; y++) {
      tmp_map[(int) y][(int) x_min] = -(border_map[(int) y][(int) x_min] != label_area);
      x = x_min;
      while ((x <= x_max) && (border_map[(int) y][(int) x] != label_area)) {
        tmp_map[(int) y][(int) x] = -1;
        x++;
        }
      tmp_map[(int) y][(int) x_max] = -(border_map[(int) y][(int) x_max] != label_area);
      x = x_max;
      while ((x >= x_min) && (border_map[(int) y][(int) x] != label_area)) {
        tmp_map[(int) y][(int) x] = -1;
        x--;
        }
      }

    change = 0;
    for (x = x_min; x <= x_max; x++)
      for (y = y_min; y <= y_max; y++) {
        change = 0;
        if (tmp_map[(int) y][(int) (x)] == -1) {
          if ((x - 1) >= x_min) {
            if ((tmp_map[(int) (y)][(int) (x - 1)] != 0) || (border_map[(int) (y)][(int) (x - 1)] == label_area)) change++;
            } else change++;

          if ((x + 1) <= x_max) {
            if ((tmp_map[(int) (y)][(int) (x + 1)] != 0) || (border_map[(int) (y)][(int) (x + 1)] == label_area)) change++;
            } else change++;

          if ((y - 1) >= y_min) {
            if ((tmp_map[(int) (y - 1)][(int) (x)] != 0) || (border_map[(int) (y - 1)][(int) (x)] == label_area)) change++;
            } else change++;

          if ((y + 1) <= y_max) {
            if ((tmp_map[(int) (y + 1)][(int) (x)] != 0) || (border_map[(int) (y + 1)][(int) (x)] == label_area)) change++;
            } else change++;
          }
        if ((border_map[(int) y][(int) x] != label_area) && (change < 4)) {
          P2 = NULL;
          P2 = Create_Pix(P2, x, y);
          if (change == 0) {
            P_top = P2;
            P1 = P_top;
            change = 1;
            } else {
            P1->next = P2;
            P1 = P2;
            }
          }
      }
    change_tot = 1;
    while (change_tot == 1) {
      change_tot = 0;
      P1 = P_top;
      while (P1 != NULL) {
        x = P1->x;
        y = P1->y;
        change = 0;
        if (tmp_map[(int) y][(int) (x)] == -1) {
          if ((x - 1) >= x_min)
            if ((border_map[(int) y][(int) (x - 1)] != label_area) && (tmp_map[(int) y][(int) (x - 1)] != -1)) {
              tmp_map[(int) y][(int) (x - 1)] = -1;
              change = 1;
              }
          if ((x + 1) <= x_max)
            if ((border_map[(int) y][(int) (x + 1)] != label_area) && (tmp_map[(int) y][(int) (x + 1)] != -1)) {
              tmp_map[(int) y][(int) (x + 1)] = -1;
              change = 1;
              }
          if ((y - 1) >= y_min)
            if ((border_map[(int) (y - 1)][(int) (x)] != label_area) && (tmp_map[(int) (y - 1)][(int) (x)] != -1)) {
              tmp_map[(int) (y - 1)][(int) (x)] = -1;
              change = 1;
              }
          if ((y + 1) <= y_max)
            if ((border_map[(int) (y + 1)][(int) (x)] != label_area) && (tmp_map[(int) (y + 1)][(int) (x)] != -1)) {
              tmp_map[(int) (y + 1)][(int) (x)] = -1;
              change = 1;
              }
          if (change == 1) change_tot = 1;
          change = 0;

          if ((x - 1) >= x_min) {
            if ((tmp_map[(int) (y)][(int) (x - 1)] != 0)|| (border_map[(int) (y)][(int) (x - 1)] == label_area)) change++;
              } else change++;

          if ((x + 1) <= x_max) {
            if ((tmp_map[(int) (y)][(int) (x + 1)] != 0)|| (border_map[(int) (y)][(int) (x + 1)] == label_area)) change++;
              } else change++;

          if ((y - 1) >= y_min) {
            if ((tmp_map[(int) (y - 1)][(int) (x)] != 0) || (border_map[(int) (y - 1)][(int) (x)] == label_area)) change++;
              } else change++;

          if ((y + 1) <= y_max) {
            if ((tmp_map[(int) (y + 1)][(int) (x)] != 0) || (border_map[(int) (y + 1)][(int) (x)] == label_area)) change++;
              } else change++;

          if (change == 4) {
            change_tot = 1;
            if (P_top == P1) P_top = Remove_Pix(P_top, P1);
            else P1 = Remove_Pix(P_top, P1);
            }
          }
        P1 = P1->next;
        }  /*while P1 */
      }    /*while change_tot */
    for (x = x_min; x <= x_max; x++)
      for (y = y_min; y <= y_max; y++)
        if (tmp_map[(int) (y)][(int) (x)] == 0)
          border_map[(int) (y)][(int) (x)] = label_area;
    }
  }
  free_matrix_float(tmp_map, Nlig);

}


