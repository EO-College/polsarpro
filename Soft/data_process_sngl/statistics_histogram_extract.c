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

File   : statistics_histogram_extract.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2006
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

Description :  Extraction of binary data from a data file using
defined pixel coordinates

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
void FilePointerPosition(int PixLig,int Ncol);

/* GLOBAL VARIABLES */
FILE *in_file;
char inputformat[10];

float *S_in1;
int *S_in2;
float *S_out1;
int *S_out2;

float **im;
int N_class;
int *N_area;
int **N_t_pt;
float ***area_coord_l;
float ***area_coord_c;
float *class_map;
long CurrentPointerPosition;

char file_name[FilePathLength], in_dir[FilePathLength];
char statisticstxt[2048], statisticsbin[2048];

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
/* Input/Output file pointer arrays */
  FILE *statbin_file;

/* Strings */
  char PolarCase[20], PolarType[20];
  char Operation[20];

/* Input variables */
  int Nlig, Ncol;    /* Initial image nb of lines and rows */
  int Off_lig, Off_col;  /* Lines and rows offset values */
  int Sub_Nlig, Sub_Ncol;  /* Sub-image nb of lines and rows */

  int border_error_flag = 0;
  int N_zones, zone;
  int lig, col;
  int classe, area, t_pt;
  int FlagExit, FlagRead;

  float **border_map;
  int *cpt_zones;

/* PROGRAM START */

  if (argc == 3) {
    strcpy(statisticstxt, argv[1]);
    strcpy(statisticsbin, argv[2]);
    }
  else
  edit_error("statistics_histogram_extract File_Txt File_Bin\n","");

  check_file(statisticstxt);
  check_file(statisticsbin);

FlagExit = 0;
while (FlagExit == 0) {
scanf("%s",Operation);
if (strcmp(Operation, "") != 0) {

if (strcmp(Operation, "exit") == 0) {
  FlagExit = 1;
  printf("OKexit\r");fflush(stdout);
  }

if (strcmp(Operation, "closefile") == 0) {
  printf("OKclosefile\r");fflush(stdout);
  FlagRead = 0;
  while (FlagRead == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
      strcpy(inputformat,Operation);
      FlagRead = 1;
      printf("OKreadformat\r");fflush(stdout);
      }
    }
  if (strcmp(inputformat, "cmplx") == 0) free_vector_float(S_in1);
  if (strcmp(inputformat, "float") == 0) free_vector_float(S_in1);
  if (strcmp(inputformat, "int") == 0) free_vector_int(S_in2);
  free_matrix_float(im,Nlig);
  free_matrix_float(border_map,Nlig);
  printf("OKfinclosefile\r");fflush(stdout);
  }

if (strcmp(Operation, "openfile") == 0) {
  printf("OKopenfile\r");fflush(stdout);
  FlagRead = 0;
  while (FlagRead == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
      strcpy(in_dir,Operation);
      check_dir(in_dir);
      FlagRead = 1;
      printf("OKreaddir\r");fflush(stdout);
      }
    }
  FlagRead = 0;
  while (FlagRead == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
      strcpy(file_name,Operation);
      check_file(file_name);
      FlagRead = 1;
      printf("OKreadfile\r");fflush(stdout);
      }
    }
  FlagRead = 0;
  while (FlagRead == 0) {
    scanf("%s",Operation);
    if (strcmp(Operation, "") != 0) {
      strcpy(inputformat,Operation);
      FlagRead = 1;
      printf("OKreadformat\r");fflush(stdout);
      }
    }
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  im = matrix_float(Nlig, Ncol);
  border_map = matrix_float(Nlig, Ncol);
  if ((in_file = fopen(file_name, "rb")) == NULL) edit_error("Could not open input file : ", file_name);
  if (strcmp(inputformat, "cmplx") == 0) S_in1 = vector_float(2 * Ncol);
  if (strcmp(inputformat, "float") == 0) S_in1 = vector_float(Ncol);
  if (strcmp(inputformat, "int") == 0) S_in2 = vector_int(Ncol);
  FilePointerPosition(Nlig/2,Ncol);
  printf("OKfinopenfile\r");fflush(stdout);
  }

if (strcmp(Operation, "histo") == 0) {

  if ((statbin_file = fopen(statisticsbin, "wb")) == NULL) edit_error("Could not open output file : ", statisticsbin);

  /* Training Area coordinates reading */
  read_coord(statisticstxt);

  for (lig = 0; lig < Nlig; lig++)
    for (col = 0; col < Ncol; col++)
    {
      border_map[lig][col] = -1;
      im[lig][col] = 0;
    }

  create_borders(border_map);
  create_areas(border_map, Nlig, Ncol);

  /*Training class matrix memory allocation */
  N_zones = 0;
  for (classe = 0; classe < N_class; classe++) N_zones += N_area[classe];

  cpt_zones = vector_int(N_zones);
  zone = -1;

  for (classe = 0; classe < N_class; classe++) {
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
      cpt_zones[zone] = -1;

      /* READING AVERAGING AND DECOMPOSITION */
      for (lig = 0; lig < Sub_Nlig; lig++) {
        for (col = 0; col < Sub_Ncol; col++) {
          if (border_map[lig + Off_lig][col + Off_col] == zone) {
            cpt_zones[zone]++;
            if (im[lig + Off_lig][col + Off_col] != 0) border_error_flag = 1;
            im[lig + Off_lig][col + Off_col] = zone + 1;
            }
          }/*col */
        }/*lig */
      if (border_error_flag == 0) cpt_zones[zone]++;
      }/*area */
    }/* Class */

  if (border_error_flag == 0) {
    fwrite(&cpt_zones[0], sizeof(int), 1, statbin_file);

    for (lig = 0; lig < Nlig; lig++)
      for (col = 0; col < Ncol; col++)
      {
        border_map[lig][col] = -1;
        im[lig][col] = 0;
      }

    create_borders(border_map);
    create_areas(border_map, Nlig, Ncol);

    /*Training class matrix memory allocation */
    N_zones = 0;
    for (classe = 0; classe < N_class; classe++) N_zones += N_area[classe];

    cpt_zones[0] = 0;
    zone = -1;

    for (classe = 0; classe < N_class; classe++) {
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
        if (strcmp(inputformat, "cmplx") == 0) S_out1 = vector_float(2*Sub_Nlig*Sub_Ncol);
        if (strcmp(inputformat, "float") == 0) S_out1 = vector_float(Sub_Nlig*Sub_Ncol);
        if (strcmp(inputformat, "int") == 0) S_out2 = vector_int(Sub_Nlig*Sub_Ncol);
        cpt_zones[zone] = -1;

        FilePointerPosition(Off_lig,Ncol);

        /* READING AVERAGING AND DECOMPOSITION */
        for (lig = 0; lig < Sub_Nlig; lig++) {
          if (strcmp(inputformat, "cmplx") == 0) fread(&S_in1[0], sizeof(float), 2 * Ncol, in_file);
          if (strcmp(inputformat, "float") == 0) fread(&S_in1[0], sizeof(float), Ncol, in_file);
          if (strcmp(inputformat, "int") == 0) fread(&S_in2[0], sizeof(int), Ncol, in_file);
          for (col = 0; col < Sub_Ncol; col++) {
            if (border_map[lig + Off_lig][col + Off_col] == zone) {
              cpt_zones[zone]++;
              if (strcmp(inputformat, "cmplx") == 0) {
                S_out1[2*cpt_zones[zone]] = S_in1[2*(col + Off_col)];
                S_out1[2*cpt_zones[zone]+1] = S_in1[2*(col + Off_col)+1];
                }
              if (strcmp(inputformat, "float") == 0) {
                S_out1[cpt_zones[zone]] = S_in1[col + Off_col];
                }
              if (strcmp(inputformat, "int") == 0) {
                S_out2[cpt_zones[zone]] = S_in2[col + Off_col];
                }
              if (im[lig + Off_lig][col + Off_col] != 0) border_error_flag = 1;
              im[lig + Off_lig][col + Off_col] = zone + 1;
              }
            }/*col */
          }/*lig */
        cpt_zones[zone]++;
        if (strcmp(inputformat, "cmplx") == 0) fwrite(&S_out1[0], sizeof(float), 2*cpt_zones[zone], statbin_file);
        if (strcmp(inputformat, "float") == 0) fwrite(&S_out1[0], sizeof(float), cpt_zones[zone], statbin_file);
        if (strcmp(inputformat, "int") == 0) fwrite(&S_out2[0], sizeof(int), cpt_zones[zone], statbin_file);
        if (strcmp(inputformat, "cmplx") == 0) free_vector_float(S_out1);
        if (strcmp(inputformat, "float") == 0) free_vector_float(S_out1);
        if (strcmp(inputformat, "int") == 0) free_vector_int(S_out2);
        } /*area */
      } /* Class */
    } /* border_error_flag */
  fclose(statbin_file);

  printf("OKhisto\r");fflush(stdout);
  } /*Operation stat*/
  } /*Operation*/
  } /*while */

if (strcmp(inputformat, "cmplx") == 0) free_vector_float(S_in1);
if (strcmp(inputformat, "float") == 0) free_vector_float(S_in1);
if (strcmp(inputformat, "int") == 0) free_vector_int(S_in2);

return 1;
}        /*Fin Main */

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

  N_class = 1;

  N_area = vector_int(N_class);

  N_t_pt = (int **) malloc((unsigned) (N_class) * sizeof(int *));
  area_coord_l =
  (float ***) malloc((unsigned) (N_class) * sizeof(float **));
  area_coord_c =
  (float ***) malloc((unsigned) (N_class) * sizeof(float **));

  zone = 0;
  fscanf(file, "%s\n", Tmp);

  classe = 0;
  N_area[classe]=1;

  N_t_pt[classe] = vector_int(N_area[classe]);
  area_coord_l[classe] = (float **) malloc((unsigned) (N_area[classe]) * sizeof(float *));
  area_coord_c[classe] = (float **) malloc((unsigned) (N_area[classe]) * sizeof(float *));

  for (area = 0; area < N_area[classe]; area++) {
    zone++;
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

/********************************************************************
  Routine  : FilePointerPosition
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*--------------------------------------------------------------------
  Description :  Update the Pointer position of the data files
*--------------------------------------------------------------------
  Inputs arguments :
    PixLig : Line position of the pixel [0 ... Nlig-1]
    Ncol  : Number of rows
  Returned values  :
    void
********************************************************************/
void FilePointerPosition(int PixLig,int Ncol)
{
long PointerPosition;
CurrentPointerPosition = ftell(in_file);
if (strcmp(inputformat, "cmplx") == 0) PointerPosition = 2 * PixLig* Ncol * sizeof(float);
if (strcmp(inputformat, "float") == 0) PointerPosition = PixLig* Ncol * sizeof(float);
if (strcmp(inputformat, "int") == 0) PointerPosition = PixLig* Ncol * sizeof(int);
fseek(in_file, (PointerPosition - CurrentPointerPosition), SEEK_CUR);
}


