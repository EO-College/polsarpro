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

File  : OPCE.c
Project  : ESA_POLSARPRO
Authors  : Yang LI - (Eric POTTIER v2.0)
Version  : 2.0
Creation : 08/2011
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
  laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Sampling of full polar coherency matrices from an 
               image using user defined pixel coordinates, then apply
               the OPCE procedure on the Target and Clutter cluster
               centers

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

/*Area parameters */
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
float **im;
int N_class;
int *N_area;
int **N_t_pt;
float ***area_coord_l;
float ***area_coord_c;
float *class_map;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 5
/* LOCAL VARIABLES */
  FILE *fbin, *fp;
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C3", "C4", "T3", "T4"};
  char file_name[FilePathLength], area_file[FilePathLength];
  
/* Internal variables */
  int ii, k, l, lig, col;

  int Off_lig_OPCE, Off_col_OPCE;
  int Sub_Nlig_OPCE, Sub_Ncol_OPCE;

  int border_error_flag = 0;
  int N_zones, zone, Np;
  int class, area, t_pt;
  int arret, iteration;

  float KT1, KT2, KT3, KT4, KT5, KT6, KT7, KT8, KT9, KT10;
  float KC1, KC2, KC3, KC4, KC5, KC6, KC7, KC8, KC9, KC10;
//  float g0p, h0p;
  float g1p, g2p, g3p, g0, g1, g2, g3;
  float h1p, h2p, h3p, h0, h1, h2, h3;
  float x0, x1, x2, x3;
  float A0, A1, A2, A3, B0, B1, B2, B3;
  float rm, z1, z2, z12, den, normg, normh;
  float epsilon, Pnum, Pden;

/* Matrix arrays */
  float ***M_avg;
  float **M_out;
  float ***S_tmp;
  float ***M_tmp;

  float **border_map;
  float *cpt_zones;
  float T[3][3][2];
  float *coh_area[3][3][2];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nOPCE.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-af  	area file\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig_OPCE,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col_OPCE,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig_OPCE,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol_OPCE,1,UsageHelp);
  get_commandline_prm(argc,argv,"-af",str_cmd_prm,area_file,1,UsageHelp);

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

  if (strcmp(PolType,"S2")==0) strcpy(PolType, "S2T3");

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(area_file);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

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

/* OUTPUT FILE OPENING*/

  sprintf(file_name, "%s%s", out_dir, "OPCE_results.txt");
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
  NBlockA += Sub_Ncol_OPCE; NBlockB += 0;

  /* Mavg = NpolarOut*Nlig*Sub_Ncol */
  NBlockA += NpolarOut*Sub_Ncol_OPCE; NBlockB += 0;
  /* im = Nlig*Ncol */
  NBlockA += 0; NBlockB += Nlig*Ncol;
  /* border = Nlig*Ncol */
  NBlockA += 0; NBlockB += Nlig*Ncol;
  /* Mout = Nlig*Sub_Ncol */
  NBlockA += Sub_Ncol_OPCE; NBlockB += 0;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig_OPCE, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol_OPCE);

  M_avg = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol_OPCE);
  M_out = matrix_float(NligBlock[0], Sub_Ncol_OPCE);

  im = matrix_float(Nlig, Ncol);
  border_map = matrix_float(Nlig, Ncol);

  S_tmp = matrix3d_float(4,2,2*Ncol);
  M_tmp = matrix3d_float(16,2,Ncol);

/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol_OPCE; col++) 
        Valid[lig][col] = 1.;
 
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
  for (class = 0; class < N_class; class++) N_zones += N_area[class];

  for (k = 0; k < 3; k++) {
    for (l = 0; l < 3; l++) {
      coh_area[k][l][0] = vector_float(N_zones);
      coh_area[k][l][1] = vector_float(N_zones);
      }
    }
  cpt_zones = vector_float(N_zones);

  zone = -1;
  for (class = 0; class < N_class; class++) {
    for (area = 0; area < N_area[class]; area++) {
      zone++;
      Off_lig = 2 * Nlig;
      Off_col = 2 * Ncol;
      Sub_Nlig = -1;
      Sub_Ncol = -1;

      for (t_pt = 0; t_pt < N_t_pt[class][area]; t_pt++) {
        if (area_coord_l[class][area][t_pt] < Off_lig) Off_lig = area_coord_l[class][area][t_pt];
        if (area_coord_c[class][area][t_pt] < Off_col) Off_col = area_coord_c[class][area][t_pt];
        if (area_coord_l[class][area][t_pt] > Sub_Nlig) Sub_Nlig = area_coord_l[class][area][t_pt];
        if (area_coord_c[class][area][t_pt] > Sub_Ncol) Sub_Ncol = area_coord_c[class][area][t_pt];
        }
    
      Sub_Nlig = Sub_Nlig - Off_lig + 1;
      Sub_Ncol = Sub_Ncol - Off_col + 1;

      cpt_zones[zone] = 0;

      for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);

      for (lig = 0; lig < Off_lig; lig++) {
        if (strcmp(PolTypeIn,"S2")==0) {
          for (Np = 0; Np < NpolarIn; Np++) fread(&S_tmp[Np][0][0], sizeof(float), 2*Ncol, in_datafile[Np]);
          } else {
          for (Np = 0; Np < NpolarIn; Np++) fread(&M_tmp[Np][0][0], sizeof(float), Ncol, in_datafile[Np]);
          }
        }
        
      for (lig = 0; lig < Sub_Nlig; lig++) {
        if (strcmp(PolTypeIn,"S2")==0) {
          for (Np = 0; Np < NpolarIn; Np++) fread(&S_tmp[Np][0][0], sizeof(float), 2*Ncol, in_datafile[Np]);
          S2_to_T3(S_tmp, M_tmp, 1, Ncol, 0, 0);
          } else {
          for (Np = 0; Np < NpolarIn; Np++) fread(&M_tmp[Np][0][0], sizeof(float), Ncol, in_datafile[Np]);
          if (strcmp(PolTypeIn,"C3") == 0) C3_to_T3(M_tmp, 1, Ncol, 0, 0);
          if (strcmp(PolTypeIn,"C4") == 0) C4_to_T3(M_tmp, 1, Ncol, 0, 0);
          if (strcmp(PolTypeIn,"T4") == 0) T4_to_T3(M_tmp, 1, Ncol, 0, 0);
          }

        for (col = 0; col < Sub_Ncol; col++) {
          if (border_map[lig + Off_lig][col + Off_col] == zone) {
          /* Average complex coherency matrix determination*/
          T[0][0][0] = eps + M_tmp[T311][0][col + Off_col];
          T[0][0][1] = 0.;
          T[0][1][0] = eps + M_tmp[T312_re][0][col + Off_col];
          T[0][1][1] = eps + M_tmp[T312_im][0][col + Off_col];
          T[0][2][0] = eps + M_tmp[T313_re][0][col + Off_col];
          T[0][2][1] = eps + M_tmp[T313_im][0][col + Off_col];
          T[1][0][0] = eps + M_tmp[T312_re][0][col + Off_col];
          T[1][0][1] = eps - M_tmp[T312_im][0][col + Off_col];
          T[1][1][0] = eps + M_tmp[T322][0][col + Off_col];
          T[1][1][1] = 0.;
          T[1][2][0] = eps + M_tmp[T323_re][0][col + Off_col];
          T[1][2][1] = eps + M_tmp[T323_im][0][col + Off_col];
          T[2][0][0] = eps + M_tmp[T313_re][0][col + Off_col];
          T[2][0][1] = eps - M_tmp[T313_im][0][col + Off_col];
          T[2][1][0] = eps + M_tmp[T323_re][0][col + Off_col];
          T[2][1][1] = eps - M_tmp[T323_im][0][col + Off_col];
          T[2][2][0] = eps + M_tmp[T333][0][col + Off_col];
          T[2][2][1] = 0.;

          /*Assigning T to the corresponding training coherency matrix */
          for (k = 0; k < 3; k++)
            for (l = 0; l < 3; l++) {
              coh_area[k][l][0][zone] = coh_area[k][l][0][zone] + T[k][l][0];
              coh_area[k][l][1][zone] = coh_area[k][l][1][zone] + T[k][l][1];
              }
          cpt_zones[zone] = cpt_zones[zone] + 1.;

          //Check if the pixel has already been assigned to a previous class
          //Avoid overlapped classes
          if (im[lig + Off_lig][col + Off_col] != 0) border_error_flag = 1;
          im[lig + Off_lig][col + Off_col] = zone + 1;
          }
        }  /*col */
      }    /*lig */

    for (k = 0; k < 3; k++)
      for (l = 0; l < 3; l++) {
        coh_area[k][l][0][zone] = coh_area[k][l][0][zone] / cpt_zones[zone];
        coh_area[k][l][1][zone] = coh_area[k][l][1][zone] / cpt_zones[zone];
        }
    }    /*area */
  }    /* Class */

/********************************************************************
********************************************************************/

if (border_error_flag == 0) {
  sprintf(file_name, "%s%s", out_dir, "OPCE_results.txt");
  if ((fp = fopen(file_name, "w")) == NULL)
    edit_error("Could not open output file : ", file_name);

  fprintf(fp, "Target cluster centre\n");
  fprintf(fp, "T11 = %e\n", coh_area[0][0][0][0]);
  fprintf(fp, "T12 = %e + j %e\n", coh_area[0][1][0][0], coh_area[0][1][1][0]);
  fprintf(fp, "T13 = %e + j %e\n", coh_area[0][2][0][0], coh_area[0][2][1][0]);
  fprintf(fp, "T22 = %e\n", coh_area[1][1][0][0]);
  fprintf(fp, "T23 = %e + j %e\n", coh_area[1][2][0][0], coh_area[1][2][1][0]);
  fprintf(fp, "T33 = %e\n", coh_area[2][2][0][0]);
  fprintf(fp, "\n");
  fprintf(fp, "Clutter cluster centre\n");
  fprintf(fp, "T11 = %e\n", coh_area[0][0][0][1]);
  fprintf(fp, "T12 = %e + j %e\n", coh_area[0][1][0][1], coh_area[0][1][1][1]);
  fprintf(fp, "T13 = %e + j %e\n", coh_area[0][2][0][1], coh_area[0][2][1][1]);
  fprintf(fp, "T22 = %e\n", coh_area[1][1][0][1]);
  fprintf(fp, "T23 = %e + j %e\n", coh_area[1][2][0][1], coh_area[1][2][1][1]);
  fprintf(fp, "T33 = %e\n", coh_area[2][2][0][1]);
  fprintf(fp, "\n");

//OPCE PROCEDURE
// Maximise the ratio (ht.KT.g)/(ht.KC.g)

//Target Kennaugh Matrix Elements
  zone = 0;
  KT1 = 0.5 * (coh_area[0][0][0][zone] + coh_area[1][1][0][zone] + coh_area[2][2][0][zone]);
  KT2 = coh_area[0][1][0][zone];
  KT3 = coh_area[0][2][0][zone];
  KT4 = coh_area[1][2][1][zone];
  KT5 = 0.5 * (coh_area[0][0][0][zone] + coh_area[1][1][0][zone] - coh_area[2][2][0][zone]);
  KT6 = coh_area[1][2][0][zone];
  KT7 = coh_area[0][2][1][zone];
  KT8 = 0.5 * (coh_area[0][0][0][zone] - coh_area[1][1][0][zone] + coh_area[2][2][0][zone]);
  KT9 = -coh_area[0][1][1][zone];
  KT10 = 0.5 * (-coh_area[0][0][0][zone] + coh_area[1][1][0][zone] + coh_area[2][2][0][zone]);

//Clutter Kennaugh Matrix Elements
  zone = 1;
  KC1 = 0.5 * (coh_area[0][0][0][zone] + coh_area[1][1][0][zone] + coh_area[2][2][0][zone]);
  KC2 = coh_area[0][1][0][zone];
  KC3 = coh_area[0][2][0][zone];
  KC4 = coh_area[1][2][1][zone];
  KC5 = 0.5 * (coh_area[0][0][0][zone] + coh_area[1][1][0][zone] - coh_area[2][2][0][zone]);
  KC6 = coh_area[1][2][0][zone];
  KC7 = coh_area[0][2][1][zone];
  KC8 = 0.5 * (coh_area[0][0][0][zone] - coh_area[1][1][0][zone] + coh_area[2][2][0][zone]);
  KC9 = -coh_area[0][1][1][zone];
  KC10 = 0.5 * (-coh_area[0][0][0][zone] + coh_area[1][1][0][zone] + coh_area[2][2][0][zone]);

//Transmission / Reception Stokes Vector Initialisation
//  g0p = 1.;
  g1p = 0.;
  g2p = 0.;
  g3p = 1.;
  g0 = 1.;
  g1 = 1.;
  g2 = 0.;
  g3 = 0.;
//  h0p = 1.;
  h1p = 0.;
  h2p = 0.;
  h3p = 1.;
  h0 = 1.;
  h1 = 1.;
  h2 = 0.;
  h3 = 0.;

//Initial Contrast
  A0 = g0 * KT1 + g1 * KT2 + g2 * KT3 + g3 * KT4;
  A1 = g0 * KT2 + g1 * KT5 + g2 * KT6 + g3 * KT7;
  A2 = g0 * KT3 + g1 * KT6 + g2 * KT8 + g3 * KT9;
  A3 = g0 * KT4 + g1 * KT7 + g2 * KT9 + g3 * KT10;
  Pnum = h0 * A0 + h1 * A1 + h2 * A2 + h3 * A3;
  B0 = g0 * KC1 + g1 * KC2 + g2 * KC3 + g3 * KC4;
  B1 = g0 * KC2 + g1 * KC5 + g2 * KC6 + g3 * KC7;
  B2 = g0 * KC3 + g1 * KC6 + g2 * KC8 + g3 * KC9;
  B3 = g0 * KC4 + g1 * KC7 + g2 * KC9 + g3 * KC10;
  Pden = h0 * B0 + h1 * B1 + h2 * B2 + h3 * B3;
  fprintf(fp, "Initial Target Power = %e\n", Pnum);
  fprintf(fp, "Initial Clutter Power = %e\n", Pden);
  fprintf(fp, "Initial Contrast = %e\n", Pnum / Pden);
  fprintf(fp, "\n");

  x0 = g0;
  x1 = g1;
  x2 = g2;
  x3 = g3;

  arret = 0;
  iteration = 0;
  epsilon = 1.E-05;
  while (arret == 0) {
    PrintfLine(iteration,100);
    h1p = h1;
    h2p = h2;
    h3p = h3;
    g1p = g1;
    g2p = g2;
    g3p = g3;

    iteration++;

    A0 = x0 * KT1 + x1 * KT2 + x2 * KT3 + x3 * KT4;
    A1 = x0 * KT2 + x1 * KT5 + x2 * KT6 + x3 * KT7;
    A2 = x0 * KT3 + x1 * KT6 + x2 * KT8 + x3 * KT9;
    A3 = x0 * KT4 + x1 * KT7 + x2 * KT9 + x3 * KT10;
    B0 = x0 * KC1 + x1 * KC2 + x2 * KC3 + x3 * KC4;
    B1 = x0 * KC2 + x1 * KC5 + x2 * KC6 + x3 * KC7;
    B2 = x0 * KC3 + x1 * KC6 + x2 * KC8 + x3 * KC9;
    B3 = x0 * KC4 + x1 * KC7 + x2 * KC9 + x3 * KC10;
    z1 = A0 * A0 - A1 * A1 - A2 * A2 - A3 * A3;
    z2 = B0 * B0 - B1 * B1 - B2 * B2 - B3 * B3;
    z12 = A0 * B0 - A1 * B1 - A2 * B2 - A3 * B3;
    rm = (z12 + sqrt(z12 * z12 - z1 * z2)) / z2;
    den = sqrt((A1 - rm * B1) * (A1 - rm * B1) + (A2 - rm * B2) * (A2 - rm * B2) + (A3 - rm * B3) * (A3 - rm * B3));
    if (fmod(iteration, 2) == 1) {
      h1 = (A1 - rm * B1) / den;
      h2 = (A2 - rm * B2) / den;
      h3 = (A3 - rm * B3) / den;
      x0 = h0;
      x1 = h1;
      x2 = h2;
      x3 = h3;
      } else {
      g1 = (A1 - rm * B1) / den;
      g2 = (A2 - rm * B2) / den;
      g3 = (A3 - rm * B3) / den;
      x0 = g0;
      x1 = g1;
      x2 = g2;
      x3 = g3;
      }

    normh = fabs(h1 - h1p) + fabs(h2 - h2p) + fabs(h3 - h3p);
    normg = fabs(g1 - g1p) + fabs(g2 - g2p) + fabs(g3 - g3p);
//if ((normh < epsilon)&&(normg < epsilon)) arret = 1;
    arret = 1;
    if (normg > epsilon) arret = 0;
    else if (normh > epsilon) arret = 0;

    if (iteration == 100)
    arret = 1;
    }

//Save results
  fprintf(fp, "Optimal Transmit Polarization\n");
  fprintf(fp, "g0 = %e\n", g0);
  fprintf(fp, "g1 = %e\n", g1);
  fprintf(fp, "g2 = %e\n", g2);
  fprintf(fp, "g3 = %e\n", g3);
  fprintf(fp, "\n");
  fprintf(fp, "Optimal Receive Polarization\n");
  fprintf(fp, "h0 = %e\n", h0);
  fprintf(fp, "h1 = %e\n", h1);
  fprintf(fp, "h2 = %e\n", h2);
  fprintf(fp, "h3 = %e\n", h3);
  fprintf(fp, "\n");
  fprintf(fp, "iteration = %i\n", iteration);
  fprintf(fp, "\n");

//Final Contrast
  A0 = g0 * KT1 + g1 * KT2 + g2 * KT3 + g3 * KT4;
  A1 = g0 * KT2 + g1 * KT5 + g2 * KT6 + g3 * KT7;
  A2 = g0 * KT3 + g1 * KT6 + g2 * KT8 + g3 * KT9;
  A3 = g0 * KT4 + g1 * KT7 + g2 * KT9 + g3 * KT10;
  Pnum = h0 * A0 + h1 * A1 + h2 * A2 + h3 * A3;
  B0 = g0 * KC1 + g1 * KC2 + g2 * KC3 + g3 * KC4;
  B1 = g0 * KC2 + g1 * KC5 + g2 * KC6 + g3 * KC7;
  B2 = g0 * KC3 + g1 * KC6 + g2 * KC8 + g3 * KC9;
  B3 = g0 * KC4 + g1 * KC7 + g2 * KC9 + g3 * KC10;
  Pden = h0 * B0 + h1 * B1 + h2 * B2 + h3 * B3;
  fprintf(fp, "Final Target Power = %e\n", Pnum);
  fprintf(fp, "Final Clutter Power = %e\n", Pden);
  fprintf(fp, "Final Contrast = %e\n", Pnum / Pden);
  fclose(fp);
  
/********************************************************************
********************************************************************/
//Determine the OPCE Puissance

  sprintf(file_name, "%s%s", out_dir, "OPCE.bin");
  if ((fbin = fopen(file_name, "wb")) == NULL)
    edit_error("Could not open output file : ", file_name);

  for (Np = 0; Np < NpolarIn; Np++) rewind(in_datafile[Np]);
  if (FlagValid == 1) rewind(in_valid);

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol_OPCE, 1, 1, Off_lig_OPCE, Off_col_OPCE, Ncol);

  if (strcmp(PolTypeIn,"S2")==0) {
  read_block_S2_avg(in_datafile, M_avg, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol_OPCE, NwinL, NwinC, Off_lig_OPCE, Off_col_OPCE, Ncol);
  } else {
  /* Case of C,T or I */
  read_block_TCI_avg(in_datafile, M_avg, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol_OPCE, NwinL, NwinC, Off_lig_OPCE, Off_col_OPCE, Ncol);
  }
  if (strcmp(PolTypeOut,"C3")==0) C3_to_T3(M_avg, NligBlock[Nb], Sub_Ncol_OPCE, 0, 0);
  if (strcmp(PolTypeOut,"C4")==0) C4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol_OPCE, 0, 0);
  if (strcmp(PolTypeOut,"T4")==0) T4_to_T3(M_avg, NligBlock[Nb], Sub_Ncol_OPCE, 0, 0);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol_OPCE; col++) {
      if (Valid[lig][col] == 1.) {
        /* Average Kennaugh matrix determination*/
        KT1 = eps + 0.5 * (M_avg[T311][lig][col] + M_avg[T322][lig][col] + M_avg[T333][lig][col]);
        KT2 = eps + M_avg[T312_re][lig][col];
        KT3 = eps + M_avg[T313_re][lig][col];
        KT4 = eps + M_avg[T323_im][lig][col];
        KT5 = eps + 0.5 * (M_avg[T311][lig][col] + M_avg[T322][lig][col] - M_avg[T333][lig][col]);
        KT6 = eps + M_avg[T323_re][lig][col];
        KT7 = eps + M_avg[T313_im][lig][col];
        KT8 = eps + 0.5 * (M_avg[T311][lig][col] - M_avg[T322][lig][col] + M_avg[T333][lig][col]);
        KT9 = eps - M_avg[T312_im][lig][col];
        KT10 = eps + 0.5 * (-M_avg[T311][lig][col] + M_avg[T322][lig][col] + M_avg[T333][lig][col]);

        A0 = g0 * KT1 + g1 * KT2 + g2 * KT3 + g3 * KT4;
        A1 = g0 * KT2 + g1 * KT5 + g2 * KT6 + g3 * KT7;
        A2 = g0 * KT3 + g1 * KT6 + g2 * KT8 + g3 * KT9;
        A3 = g0 * KT4 + g1 * KT7 + g2 * KT9 + g3 * KT10;
        M_out[lig][col] = h0 * A0 + h1 * A1 + h2 * A2 + h3 * A3;
        } else {
        M_out[lig][col] = 0.;
        }
      }
    }

  write_block_matrix_float(fbin, M_out, NligBlock[Nb], Sub_Ncol_OPCE, 0, 0, Sub_Ncol_OPCE);

  } // NbBlock
}
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(M_avg, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
  free_matrix_float(im, Nlig);
  free_matrix_float(border_map, Nlig);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(fbin);
  
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


