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

File   : wishart_confusion_matrix.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL (v2.0 Eric POTTIER)
Version  : 2.0
Creation : 07/2003 (v2.0 08/2011)
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

Description :  Evaluation of the confusion matrix over a classified image
from user provided testing areas defined by pixel coordinates

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */
  FILE *in_file, *confusion_file;
  char file_name[FilePathLength], area_file[FilePathLength];
  char PolarCase[20], PolarType[20];
  char ColorMapTrainingSet16[FilePathLength];

/* Internal variables */
  int lig, col;
  int Nligg, ligg;

  int Bmp_flag;
//int Rej_flag;
  int area;

/* Matrix arrays */
  float **M_in;
  float **im;
  float **border_map;
  float *total;
  float **cpt_area;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nwishart_confusion_matrix.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-af  	input area file\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-bmp 	BMP flag (0/1)\n");
//strcat(UsageHelp," (int)   	-rej 	Rejection flag (0/1)\n");
strcat(UsageHelp," (string)	-col 	input colormap file (valid if BMP flag = 1)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

//if(argc < 23) {
if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-af",str_cmd_prm,area_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&NwinL,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&NwinC,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bmp",int_cmd_prm,&Bmp_flag,1,UsageHelp);
//  get_commandline_prm(argc,argv,"-rej",int_cmd_prm,&Rej_flag,1,UsageHelp);
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
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);
  check_file(area_file);
  if (Bmp_flag == 1) check_file(ColorMapTrainingSet16);

  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  if (Bmp_flag != 0) Bmp_flag = 1;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT FILE OPENING*/
  sprintf(file_name, "%swishart_supervised_class_%dx%d.bin", out_dir, NwinL, NwinC);
//  if (Rej_flag == 1)
//    sprintf(file_name, "%swishart_supervised_class_rej_%dx%d.bin", out_dir, NwinL, NwinC);
  if ((in_file = fopen(file_name, "rb")) == NULL)
    edit_error("Could not open input file : ", file_name);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%swishart_confusion_matrix_%dx%d.txt", out_dir, NwinL, NwinC);
//  if (Rej_flag == 1)
//    sprintf(file_name, "%swishart_confusion_matrix_rej_%dx%d.txt", out_dir, NwinL, NwinC);
  if ((confusion_file = fopen(file_name, "wt")) == NULL)
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
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* im = Nlig*Ncol */
  NBlockA += 0; NBlockB += Nlig*Ncol;
  /* bordermap = Nlig*Ncol */
  NBlockA += 0; NBlockB += Nlig*Ncol;
  /* Min = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  
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

  M_in = matrix_float(NligBlock[0], Ncol);
  im = matrix_float(Nlig, Ncol);
  border_map = matrix_float(Nlig, Ncol);
  
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

/* Training Area coordinates reading */
  read_coord(area_file);

  for (lig = 0; lig < Sub_Nlig; lig++)
    for (col = 0; col < Sub_Ncol; col++)
      border_map[lig][col] = -1;

  create_borders(border_map);

  create_areas(border_map, Sub_Nlig, Sub_Ncol);

  for (lig = 0; lig < Nlig; lig++)
    for (col = 0; col < Ncol; col++)
      border_map[lig][col] = class_map[(int) border_map[lig][col] + 1];

  total = vector_float(N_class + 1);
  cpt_area = matrix_float(N_class + 1, N_class + 1);

  for (lig = 0; lig < N_class + 1; lig++) {
    total[lig] = 0;
    for (col = 0; col < N_class + 1; col++) cpt_area[lig][col] = 0;
    }

/****************************************************/
Nligg = 0; ligg = 0;
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(in_file, M_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        area = border_map[ligg + Off_lig][col + Off_col];
        if (area != 0) {
          total[area]++;
          cpt_area[area][(int) M_in[lig][col]]++;
          im[ligg + Off_lig][col + Off_col] = M_in[lig][col];
          }
        } else {
        im[ligg + Off_lig][col + Off_col] = 0;
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

/****************************************************
*****************************************************/
/* COMPUTE CONFUSION STATISTICS */
  fprintf(confusion_file, "        CONFUSION MATRIX\n");
  fprintf(confusion_file, "-----------------------------------------------------------------\n\n");
  fprintf(confusion_file, "Rows represent the user defined clusters\n");
  fprintf(confusion_file, "Columns represent the segmented clusters\n");
  fprintf(confusion_file, "A number located at a postion IJ represents\n");
  fprintf(confusion_file, "the amount of pixels in percent belonging to\n");
  fprintf(confusion_file, "the user defined area I that were assigned to\n");
  fprintf(confusion_file, "cluster J during the supervised classification\n\n");
  fprintf(confusion_file, "-----------------------------------------------------------------\n\n");

  fprintf(confusion_file, "\t");
  for (lig = 1; lig < N_class + 1; lig++)
  fprintf(confusion_file, " C%d \t", lig);

  for (lig = 1; lig < N_class + 1; lig++) {
    fprintf(confusion_file, "\nC%d\t", lig);
    for (col = 1; col < N_class + 1; col++) {
      if (total[lig] != 0) cpt_area[lig][col] /= total[lig];
      fprintf(confusion_file, "%-.2f\t ", cpt_area[lig][col] * 100);
      }
    }
  fprintf(confusion_file, "\n\nClass populations\n");
  fprintf(confusion_file, "---------------------------\n");
  for (lig = 1; lig < N_class + 1; lig++)
    fprintf(confusion_file, "C%d\t%d\n", lig, (int) total[lig]);

/****************************************************
*****************************************************/
/* Create BMP file*/
if (Bmp_flag == 1) {
  sprintf(file_name, "%s%s_%dx%d", out_dir, "wishart_classified_cluster_set", NwinL, NwinC);
//  if (Rej_flag == 1)
//    sprintf(file_name, "%s%s_rej_%dx%d", out_dir, "wishart_classified_cluster_set", NwinL, NwinC);
  bmp_training_set(im, Nlig, Ncol, file_name, ColorMapTrainingSet16);
  }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix_float(M_in, NligBlock[0]);
  free_matrix_float(im, Nlig);
  free_matrix_float(border_map, Nlig);
*/
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  fclose(in_file);
  if (FlagValid == 1) fclose(in_valid);

  fclose(confusion_file);
  
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


