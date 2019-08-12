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

File   : stat_extract.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 1.0
Creation : 05/2005
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

Description :  Extraction of full polar matrices from an image using
user defined pixel coordinates

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
void FilePointerPosition(int PixLig,int PixCol,int Ncol,char *TypePol);

/* GLOBAL VARIABLES */

float **M_in;
float **M_out;

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
#define NPolType 7
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2", "C2", "C3", "T3", "C4", "T4", "SPP"};
  FILE *statbin_file, *statres_file;

/* Strings */
  char file_name[FilePathLength];
  char statisticstxt[FilePathLength], statisticsbin[FilePathLength], statresultstxt[FilePathLength];
  char Operation[FilePathLength];

/* Input variables */
  int border_error_flag = 0;
  int N_zones, zone;
  int ii, lig, col, Np;
  int classe, area, t_pt;
  int FlagExit;

  float **border_map;
  int *cpt_zones;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nstat_extract.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (string)	-fist	input statistics txt file\n");
strcat(UsageHelp," (string)	-fisb	input statistics bin file\n");
strcat(UsageHelp," (string)	-fost	output statistics txt file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
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

if(argc < 11) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fist",str_cmd_prm,statisticstxt,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fisb",str_cmd_prm,statisticsbin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fost",str_cmd_prm,statresultstxt,1,UsageHelp);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_file(statisticstxt);
  check_file(statisticsbin);
  check_file(statresultstxt);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

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
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */

if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
  M_in = matrix_float(NpolarIn, 2*Ncol);
  } else {
  M_in = matrix_float(NpolarIn, Ncol);
  }
im = matrix_float(Nlig, Ncol);
border_map = matrix_float(Nlig, Ncol);

/********************************************************************
********************************************************************/

FilePointerPosition(Nlig/2,Ncol/2,Ncol, PolType);

FlagExit = 0;
while (FlagExit == 0) {
  scanf("%s",Operation);
  if (strcmp(Operation, "") != 0) {
    if (strcmp(Operation, "exit") == 0) {
      FlagExit = 1;
      printf("OKexit\r");fflush(stdout);
      }
    if (strcmp(Operation, "stat") == 0) {

      strcpy(file_name, statisticsbin);
      if ((statbin_file = fopen(file_name, "wb")) == NULL) edit_error("Could not open output file : ", file_name);

      /* Training Area coordinates reading */
      read_coord(statisticstxt);
  
      for (lig = 0; lig < Nlig; lig++)
        for (col = 0; col < Ncol; col++) {
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
          if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
            || (strcmp(PolTypeIn,"SPPpp1") == 0)
            || (strcmp(PolTypeIn,"SPPpp2") == 0)
            || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
            M_out = matrix_float(NpolarIn, 2*Sub_Nlig*Sub_Ncol);
            } else {
            M_out = matrix_float(NpolarIn, Sub_Nlig*Sub_Ncol);
            }
          cpt_zones[zone] = -1;

          FilePointerPosition(Off_lig,Off_col,Ncol,PolType);

          if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
            || (strcmp(PolTypeIn,"SPPpp1") == 0)
            || (strcmp(PolTypeIn,"SPPpp2") == 0)
            || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
            for (lig = 0; lig < Sub_Nlig; lig++) {
              for (Np = 0; Np < NpolarIn; Np++) fread(&M_in[Np][0], sizeof(float), 2*Ncol, in_datafile[Np]);
              for (col = 0; col < Sub_Ncol; col++) {
                if (border_map[lig + Off_lig][col + Off_col] == zone) {
                  cpt_zones[zone]++;
                  for (Np = 0; Np < NpolarIn; Np++) {
                    M_out[Np][2*cpt_zones[zone]] = M_in[Np][2*(col + Off_col)];
                    M_out[Np][2*cpt_zones[zone]+1] = M_in[Np][2*(col + Off_col)+1];
                    }
                  if (im[lig + Off_lig][col + Off_col] != 0) border_error_flag = 1;
                  im[lig + Off_lig][col + Off_col] = zone + 1;
                  }
                }/*col */
              }/*lig */
            } else {
            for (lig = 0; lig < Sub_Nlig; lig++) {
              for (Np = 0; Np < NpolarIn; Np++) fread(&M_in[Np][0], sizeof(float), Ncol, in_datafile[Np]);
              for (col = 0; col < Sub_Ncol; col++) {
                if (border_map[lig + Off_lig][col + Off_col] == zone) {
                  cpt_zones[zone]++;
                  for (Np = 0; Np < NpolarIn; Np++) M_out[Np][cpt_zones[zone]] = M_in[Np][col + Off_col];
                  if (im[lig + Off_lig][col + Off_col] != 0) border_error_flag = 1;
                  im[lig + Off_lig][col + Off_col] = zone + 1;
                  }
                }/*col */
              }/*lig */
            }
          if (border_error_flag == 0) {
            cpt_zones[zone]++;
            if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
              || (strcmp(PolTypeIn,"SPPpp1") == 0)
              || (strcmp(PolTypeIn,"SPPpp2") == 0)
              || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
              for (Np = 0; Np < NpolarIn; Np++) fwrite(&M_out[Np][0], sizeof(float), 2*cpt_zones[zone], statbin_file);
              } else {  
              for (Np = 0; Np < NpolarIn; Np++) fwrite(&M_out[Np][0], sizeof(float), cpt_zones[zone], statbin_file);
              }
            }
          free_matrix_float(M_out, NpolarIn);
          }/*area */
        }/* Class */

      fclose(statbin_file);

      if (border_error_flag == 0) {
        strcpy(file_name, statresultstxt);
        if ((statres_file = fopen(file_name, "w")) == NULL) edit_error("Could not open output file : ", file_name);
        fprintf(statres_file,"%i\n",cpt_zones[0]);
        if ((strcmp(PolTypeIn,"S2")==0) || (strcmp(PolTypeIn,"SPP") == 0) 
          || (strcmp(PolTypeIn,"SPPpp1") == 0)
          || (strcmp(PolTypeIn,"SPPpp2") == 0)
          || (strcmp(PolTypeIn,"SPPpp3") == 0)) {
          if (strcmp(PolarType, "full") == 0) fprintf(statres_file,"0\n");
          if (strcmp(PolarType, "pp1") == 0) fprintf(statres_file,"1\n");
          if (strcmp(PolarType, "pp2") == 0) fprintf(statres_file,"2\n");
          if (strcmp(PolarType, "pp3") == 0) fprintf(statres_file,"3\n");
          } else {
          if (strcmp(PolTypeIn, "C2") == 0) fprintf(statres_file,"0\n");
          if (strcmp(PolTypeIn, "C3") == 0) fprintf(statres_file,"0\n");
          if (strcmp(PolTypeIn, "T3") == 0) fprintf(statres_file,"1\n");
          if (strcmp(PolTypeIn, "C4") == 0) fprintf(statres_file,"0\n");
          if (strcmp(PolTypeIn, "T4") == 0) fprintf(statres_file,"1\n");
          }
        fclose(statres_file);
        }

      printf("OKstat\r");fflush(stdout);
      }
    }
  } /*while */

free_matrix_float(M_in, NpolarIn);

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
  //fscanf(file, "%s\n", Tmp);

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

/*******************************************************************************
  Routine  : FilePointerPosition
  Authors  : Eric POTTIER, Laurent FERRO-FAMIL
  Creation : 04/2005
  Update  :
*-------------------------------------------------------------------------------
  Description :  Update the Pointer position of the data files
*-------------------------------------------------------------------------------
  Inputs arguments :
    PixLig : Line position of the pixel [0 ... Nlig-1]
    PixCol : Row position of the pixel  [0 ... Ncol-1]
    Ncol  : Number of rows
  Returned values  :
    void
*******************************************************************************/
void FilePointerPosition(int PixLig,int PixCol,int Ncol,char *TypePol)
{
long int PointerPosition;
int np;
if (strcmp(TypePol,"S2") == 0) {
  PointerPosition = (PixLig * Ncol + PixCol) * 2 * sizeof(float);
  for (np=0; np < 4; np++) my_fseek_position(in_datafile[np], PointerPosition);
  } else {
  PointerPosition = (PixLig * Ncol + PixCol) * sizeof(float);
  for (np=0; np < 9; np++) my_fseek_position(in_datafile[np], PointerPosition);
  }
}
