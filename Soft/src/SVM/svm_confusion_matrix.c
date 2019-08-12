/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File     : Confusion_Matrix.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 1.0
Creation : 07/2003
Update   :

*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
Description :  Evaluation of the confusion matrix over a classified image
from user provided testing areas defined by pixel coordinates

Inputs  : In in_dir directory
supervised_class_"Nwin".bin
supervised_class_rej_"Nwin".bin (if exists)
training_areas.txt

Outputs : In out_dir_svm directory
confusion_matrix_"Nwin".txt
confusion_matrix_rej_"Nwin".txt (if exists)
-------------------------------------------------------------------------------
Routines    :
struct Pix
struct Pix *Create_Pix(struct Pix *P, float x,float y);
struct Pix *Remove_Pix(struct Pix *P_top, struct Pix *P);
float my_round(float v);
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
void check_file(char *file);
char *vector_char(int nh);
void free_vector_char( char *v);
float *vector_float(int nh);
void free_vector_float( float *v);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
float ***matrix3d_float(int nz,int nrh,int nch);
void free_matrix3d_float(float ***m,int nz,int nrh);
void read_config(char *dir, int *Nlig, int *Ncol, char *PolarCase, char *PolarType);
void bmp_training_set(float **mat,int li,int co,char *nom,char *ColorMap16);
void read_coord(char *file_name);
void create_borders(float **border_map);
void create_areas(float **border_map,int Nlig,int Ncol);

*******************************************************************************/
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
#define Lig_nb   2
#define Col_nb   3

/* CONSTANTS  */

/* ROUTINES */
#include "../lib/graphics.h"
#include "../lib/matrix.h"
#include "../lib/processing.h"
#include "../lib/util.h"
void read_coord(char *file_name);
void create_borders(float **border_map);
void create_areas(float **border_map, int Nlig, int Ncol);
char *remove_extention(char* oldstr);

/* GLOBAL VARIABLES */
float *M_in;
float **im;
int N_class;
int *N_area;
int **N_t_pt;
float ***area_coord_l;
float ***area_coord_c;
float *class_map;

/*******************************************************************************
Routine  : main
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
-------------------------------------------------------------------------------
Description :  Evaluation of the confusion matrix over a classified image
from user provided testing areas defined by pixel coordinates

Inputs  : In in_dir directory
supervised_class_"Nwin".bin
supervised_class_rej_"Nwin".bin (if exists)
training_areas.txt

Outputs : In out_dir_svm directory
confusion_matrix_"Nwin".txt
confusion_matrix_rej_"Nwin".txt (if exists)
-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/


int main(int argc, char *argv[])
{
/* Input/Output file pointer arrays */
    FILE *in_file, *confusion_file;

/* Strings */
    char file_name[FilePathLength], file_name_tmp[FilePathLength], *file_name_tmp_ext;
    char in_dir_svm[FilePathLength], out_dir_svm[FilePathLength], area_file[FilePathLength];
    char file_name_in[FilePathLength];
    char PolarCase[20], PolarType[20];
    char ColorMapTrainingSet16[FilePathLength];

/* Input variables */
    int Nlig, Ncol;		/* Initial image nb of lines and rows */
    int Off_lig, Off_col;	/* Lines and rows offset values */
    int Sub_Nlig, Sub_Ncol;	/* Sub-image nb of lines and rows */
    int Bmp_flag;		/* Bitmap file creation flag */
    int Rej_flag;		/* Reject Class flag */

    int lig, col;
    int area;
    float *total;
    float **cpt_area;
    float **border_map;

/* PROGRAM START */


    if (argc < 12) {
	edit_error("confusion_matrix in_dir_svm out_dir_svm area_file classif_file offset_lig offset_col sub_nlig sub_ncol Bmp_flag Rej_flag ColorMap16\n","");
    } else {
	strcpy(in_dir_svm, argv[1]);
	strcpy(out_dir_svm, argv[2]);
	strcpy(area_file, argv[3]);
	strcpy(file_name_in, argv[4]);
	Off_lig = atoi(argv[5]);
	Off_col = atoi(argv[6]);
	Sub_Nlig = atoi(argv[7]);
	Sub_Ncol = atoi(argv[8]);
	Bmp_flag = atoi(argv[9]);
	Rej_flag = atoi(argv[10]);
	strcpy(ColorMapTrainingSet16, argv[11]);
    }

    if (Bmp_flag != 0)
	Bmp_flag = 1;

    check_dir(in_dir_svm);
    check_dir(out_dir_svm);
    check_file(area_file);
    check_file(file_name_in);
    check_file(ColorMapTrainingSet16);

/* INPUT/OUPUT CONFIGURATIONS */
    read_config(in_dir_svm, &Nlig, &Ncol, PolarCase, PolarType);

    border_map = matrix_float(Nlig, Ncol);
    M_in = vector_float(Ncol);
    im = matrix_float(Nlig, Ncol);


/* INPUT/OUTPUT FILE OPENING*/
    sprintf(file_name, "%s%s", out_dir_svm, file_name_in);
    if (Rej_flag == 1)
      sprintf(file_name, "%s%s_rej.bin", out_dir_svm, file_name_in);
    if ((in_file = fopen(file_name, "rb")) == NULL)
      edit_error("Could not open input file : ", file_name);

    strcpy(file_name_tmp,"");
    strncpy(file_name_tmp, &file_name_in[24],19); file_name_tmp[19] = '\0';
    sprintf(file_name, "%ssvm_confusion_matrix_%s.txt", out_dir_svm, file_name_tmp);
    
    if ((confusion_file = fopen(file_name, "wt")) == NULL)
      edit_error("Could not open input file : ", file_name);

/* Training Area coordinates reading */
    read_coord(area_file);

    for (lig = 0; lig < Sub_Nlig; lig++)
	for (col = 0; col < Sub_Ncol; col++)
	    border_map[lig][col] = -1;

    create_borders(border_map);
    create_areas(border_map, Sub_Nlig, Sub_Ncol);

    for (lig = 0; lig < Sub_Nlig; lig++)
	for (col = 0; col < Sub_Ncol; col++)
	    border_map[lig][col] =
		class_map[(int) border_map[lig][col] + 1];

    total = vector_float(N_class + 1);
    cpt_area = matrix_float(N_class + 1, N_class + 1);

    for (lig = 0; lig < N_class + 1; lig++) {
	total[lig] = 0;
	for (col = 0; col < N_class + 1; col++)
	    cpt_area[lig][col] = 0;
    }

    for (lig = 0; lig < Off_lig; lig++)
	fread(&M_in[0], sizeof(float), Ncol, in_file);

    for (lig = 0; lig < Sub_Nlig; lig++) {
	fread(&M_in[0], sizeof(float), Ncol, in_file);
	for (col = 0; col < Sub_Ncol; col++) {
	    area = border_map[lig + Off_lig][col + Off_col];
	    if (area != 0) {
		total[area]++;
		cpt_area[area][(int) M_in[col + Off_col]]++;
		im[Off_lig + lig][Off_col + col] = M_in[col + Off_col];
	    }
	}
    }

/* COMPUTE CONFUSION STATISTICS */
    fprintf(confusion_file, "              CONFUSION MATRIX\n");
    fprintf(confusion_file,
	    "-----------------------------------------------------------------\n\n");
    fprintf(confusion_file, "Rows represent the user defined clusters\n");
    fprintf(confusion_file, "Columns represent the segmented clusters\n");
    fprintf(confusion_file,
	    "A number located at a postion IJ represents\n");
    fprintf(confusion_file,
	    "the amount of pixels in percent belonging to\n");
    fprintf(confusion_file,
	    "the user defined area I that were assigned to\n");
    fprintf(confusion_file,
	    "cluster J during the supervised classification\n\n");
    fprintf(confusion_file,
	    "-----------------------------------------------------------------\n\n");

    fprintf(confusion_file, "\t");
    for (lig = 1; lig < N_class + 1; lig++)
	fprintf(confusion_file, " C%d \t", lig);

    for (lig = 1; lig < N_class + 1; lig++) {
	fprintf(confusion_file, "\nC%d\t", lig);
	for (col = 1; col < N_class + 1; col++) {
	    if (total[lig] != 0)
		cpt_area[lig][col] /= total[lig];
	    fprintf(confusion_file, "%-.2f\t ", cpt_area[lig][col] * 100);
	}
    }
    fprintf(confusion_file, "\n\nClass populations\n");
    fprintf(confusion_file, "---------------------------\n");
    for (lig = 1; lig < N_class + 1; lig++)
	fprintf(confusion_file, "C%d\t%d\n", lig, (int) total[lig]);


    if (Bmp_flag == 1) {
	sprintf(file_name, "%s%s", out_dir_svm, "svm_classified_cluster_set");
	if (Rej_flag == 1)
	    sprintf(file_name, "%s%s_rej", out_dir_svm, "svm_classified_cluster_set");
	bmp_training_set(im, Nlig, Ncol, file_name, ColorMapTrainingSet16);
    }

    return 1;
}				/*Fin Main */

/*******************************************************************************
Routine  : read_coord
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
*-------------------------------------------------------------------------------
Description :  Read training area coordinates
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
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
    area_coord_l =
	(float ***) malloc((unsigned) (N_class) * sizeof(float **));
    area_coord_c =
	(float ***) malloc((unsigned) (N_class) * sizeof(float **));

    zone = 0;
    for (classe = 0; classe < N_class; classe++) {
	fscanf(file, "%s\n", Tmp);
	fscanf(file, "%s\n", Tmp);
	fscanf(file, "%s\n", Tmp);
	fscanf(file, "%i\n", &N_area[classe]);

	N_t_pt[classe] = vector_int(N_area[classe]);
	area_coord_l[classe] =
	    (float **) malloc((unsigned) (N_area[classe]) *
			      sizeof(float *));
	area_coord_c[classe] =
	    (float **) malloc((unsigned) (N_area[classe]) *
			      sizeof(float *));

	for (area = 0; area < N_area[classe]; area++) {
	    zone++;
	    fscanf(file, "%s\n", Tmp);
	    fscanf(file, "%s\n", Tmp);
	    fscanf(file, "%i\n", &N_t_pt[classe][area]);
	    area_coord_l[classe][area] =
		vector_float(N_t_pt[classe][area] + 1);
	    area_coord_c[classe][area] =
		vector_float(N_t_pt[classe][area] + 1);
	    for (t_pt = 0; t_pt < N_t_pt[classe][area]; t_pt++) {
		fscanf(file, "%s\n", Tmp);
		fscanf(file, "%s\n", Tmp);
		fscanf(file, "%f\n", &area_coord_l[classe][area][t_pt]);
		fscanf(file, "%s\n", Tmp);
		fscanf(file, "%f\n", &area_coord_c[classe][area][t_pt]);
	    }
	    area_coord_l[classe][area][t_pt] =
		area_coord_l[classe][area][0];
	    area_coord_c[classe][area][t_pt] =
		area_coord_c[classe][area][0];
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

/*******************************************************************************
Routine  : create_borders
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
*-------------------------------------------------------------------------------
Description : Create borders
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
void create_borders(float **border_map)
{

    int classe, area, t_pt;
    float label_area, x, y, x0, y0, x1, y1, sig_x, sig_y, sig_y_sol, y_sol,
	A, B;

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
			A = (y1 - y0) / (x1 - x0);	/* Segment slope  */
			B = y0 - A * x0;	/* Segment offset */
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

/*******************************************************************************
Routine  : create_areas
Authors  : Laurent FERRO-FAMIL
Creation : 07/2003
Update   :
*-------------------------------------------------------------------------------
Description : Create areas
*-------------------------------------------------------------------------------
Inputs arguments :

Returned values  :

*******************************************************************************/
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
		if (x < x_min)
		    x_min = x;
		if (x > x_max)
		    x_max = x;
		if (y < y_min)
		    y_min = y;
		if (y > y_max)
		    y_max = y;
	    }
	    for (x = x_min; x <= x_max; x++)
		for (y = y_min; y <= y_max; y++)
		    tmp_map[(int) y][(int) x] = 0;

	    for (x = x_min; x <= x_max; x++) {
		tmp_map[(int) y_min][(int) x] =
		    -(border_map[(int) y_min][(int) x] != label_area);
		y = y_min;
		while ((y <= y_max)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    y++;
		}
		tmp_map[(int) y_max][(int) x] =
		    -(border_map[(int) y_max][(int) x] != label_area);
		y = y_max;
		while ((y >= y_min)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    y--;
		}
	    }
	    for (y = y_min; y <= y_max; y++) {
		tmp_map[(int) y][(int) x_min] =
		    -(border_map[(int) y][(int) x_min] != label_area);
		x = x_min;
		while ((x <= x_max)
		       && (border_map[(int) y][(int) x] != label_area)) {
		    tmp_map[(int) y][(int) x] = -1;
		    x++;
		}
		tmp_map[(int) y][(int) x_max] =
		    -(border_map[(int) y][(int) x_max] != label_area);
		x = x_max;
		while ((x >= x_min)
		       && (border_map[(int) y][(int) x] != label_area)) {
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
			    if ((tmp_map[(int) (y)][(int) (x - 1)] != 0)
				|| (border_map[(int) (y)][(int) (x - 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((x + 1) <= x_max) {
			    if ((tmp_map[(int) (y)][(int) (x + 1)] != 0)
				|| (border_map[(int) (y)][(int) (x + 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y - 1) >= y_min) {
			    if ((tmp_map[(int) (y - 1)][(int) (x)] != 0)
				|| (border_map[(int) (y - 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y + 1) <= y_max) {
			    if ((tmp_map[(int) (y + 1)][(int) (x)] != 0)
				|| (border_map[(int) (y + 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;
		    }
		    if ((border_map[(int) y][(int) x] != label_area)
			&& (change < 4)) {
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
			    if ((border_map[(int) y][(int) (x - 1)] !=
				 label_area)
				&& (tmp_map[(int) y][(int) (x - 1)] != -1)) {
				tmp_map[(int) y][(int) (x - 1)] = -1;
				change = 1;
			    }
			if ((x + 1) <= x_max)
			    if ((border_map[(int) y][(int) (x + 1)] !=
				 label_area)
				&& (tmp_map[(int) y][(int) (x + 1)] != -1)) {
				tmp_map[(int) y][(int) (x + 1)] = -1;
				change = 1;
			    }
			if ((y - 1) >= y_min)
			    if ((border_map[(int) (y - 1)][(int) (x)] !=
				 label_area)
				&& (tmp_map[(int) (y - 1)][(int) (x)] !=
				    -1)) {
				tmp_map[(int) (y - 1)][(int) (x)] = -1;
				change = 1;
			    }
			if ((y + 1) <= y_max)
			    if ((border_map[(int) (y + 1)][(int) (x)] !=
				 label_area)
				&& (tmp_map[(int) (y + 1)][(int) (x)] !=
				    -1)) {
				tmp_map[(int) (y + 1)][(int) (x)] = -1;
				change = 1;
			    }
			if (change == 1)
			    change_tot = 1;
			change = 0;

			if ((x - 1) >= x_min) {
			    if ((tmp_map[(int) (y)][(int) (x - 1)] != 0)
				|| (border_map[(int) (y)][(int) (x - 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((x + 1) <= x_max) {
			    if ((tmp_map[(int) (y)][(int) (x + 1)] != 0)
				|| (border_map[(int) (y)][(int) (x + 1)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y - 1) >= y_min) {
			    if ((tmp_map[(int) (y - 1)][(int) (x)] != 0)
				|| (border_map[(int) (y - 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;

			if ((y + 1) <= y_max) {
			    if ((tmp_map[(int) (y + 1)][(int) (x)] != 0)
				|| (border_map[(int) (y + 1)][(int) (x)] ==
				    label_area))
				change++;
			} else
			    change++;

			if (change == 4) {
			    change_tot = 1;
			    if (P_top == P1)
				P_top = Remove_Pix(P_top, P1);
			    else
				P1 = Remove_Pix(P_top, P1);
			}
		    }
		    P1 = P1->next;
		}		/*while P1 */
	    }			/*while change_tot */
	    for (x = x_min; x <= x_max; x++)
		for (y = y_min; y <= y_max; y++)
		    if (tmp_map[(int) (y)][(int) (x)] == 0)
			border_map[(int) (y)][(int) (x)] = label_area;
	}
    }
    free_matrix_float(tmp_map, Nlig);

}

char* remove_extention(char* oldstr) {
   int oldlen = 0;
   int i;
   while(&oldstr[oldlen] != NULL){
      ++oldlen;
   }
   int newlen = oldlen - 1;
   while(newlen > 0 && oldstr[newlen] != '.'){
      --newlen;
   }
   if (newlen == 0) {
      newlen = oldlen;
   }
   char* newstr;
   newstr = (char*)malloc(sizeof(char)*newlen);
   
   for (i = 0; i < newlen; ++i){
      newstr[i] = oldstr[i];
   }
   return newstr;
}
