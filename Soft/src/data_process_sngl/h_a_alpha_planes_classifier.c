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

File  : h_a_alpha_planes_classifier.c
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

Description :  Classification of a SAR image into regions from its
- alpha and entropy parameters    --> 8 classes
- alpha and anisotropy parameters  --> 6 classes
- anisotropy and entropy parameters --> 6 classes
Class assignation based on linear bondaries in polar planes

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

/* ALIASES */
#define Alpha 0
#define H     1
#define A     2
#define type_H_alpha 0
#define type_A_alpha 1
#define type_H_A     2

/* CONSTANTS */
#define lim_al1 55.  /* H, A and alpha decision boundaries */
#define lim_al2 50.
#define lim_al3 48.
#define lim_al4 42.
#define lim_al5 40.
#define lim_H1  0.9
#define lim_H2  0.5
#define lim_A   0.5

#define N_pl  200  /*Width of the projection plane */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void bmp_occ_pl(float **mat, int li, int co, char *cmap, char *nom, int type);
void bmp_seg_pl(float **mat, int li, int co, char *name, int type, char *ColorMap);
void define_borders(float **border_im, int type, int nlig, int ncol);

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
  FILE *fileH, *fileA, *fileAl;
  FILE *out_file;
  char filename[FilePathLength], ColorMap9[FilePathLength];

/* Internal variables */
  int lig, col, l, c;
  int Nligg, ligg;
  float a1, a2, a3, a4, a5, h1, h2, A1;
  float r1, r2, r3, r4, r5, r6, r7, r8, r9;
  int ligDone = 0;

  int flag_H_alpha, flag_A_alpha, flag_H_A;  

/* Matrix arrays */
  float **MH_in;
  float **MA_in;
  float **MAl_in;
  float **seg_im;
  float **seg_pl;
  float **occ_pl;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nh_a_alpha_planes_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-hal 	Flag Plane H-Alpha\n");
strcat(UsageHelp," (int)   	-han 	Flag Plane H-A\n");
strcat(UsageHelp," (int)   	-anal	Flag Plane A-Alpha\n");
strcat(UsageHelp," (string)	-clm 	Colormap 9 colors\n");
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

if(argc < 21) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-hal",int_cmd_prm,&flag_H_alpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-han",int_cmd_prm,&flag_H_A,1,UsageHelp);
  get_commandline_prm(argc,argv,"-anal",int_cmd_prm,&flag_A_alpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-clm",str_cmd_prm,ColorMap9,1,UsageHelp);

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
  check_file(ColorMap9);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);

/* INPUT FILE OPENING*/
  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

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

  /* MHin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MAin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MAlin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  
  /* seg_im = Sub_Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  
/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  MH_in = matrix_float(NligBlock[0], Sub_Ncol);
  MA_in = matrix_float(NligBlock[0], Sub_Ncol);
  MAl_in = matrix_float(NligBlock[0], Sub_Ncol);
  seg_im = matrix_float(Sub_Nlig, Sub_Ncol);

  seg_pl = matrix_float(N_pl, N_pl);
  occ_pl = matrix_float(N_pl, N_pl);

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
if (flag_H_alpha == 1) {
  if (FlagValid == 1) rewind(in_valid);

/* INPUT FILE OPENING*/
  sprintf(filename, "%sentropy.bin", in_dir);
  if ((fileH = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%salpha.bin", in_dir);
  if ((fileAl = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%sH_alpha_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  for (lig = 0; lig < N_pl; lig++)
    for (col = 0; col < N_pl; col++) {
      occ_pl[lig][col] = 0;
      seg_pl[lig][col] = 0;
      }

Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileH, MH_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileAl, MAl_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

a1 = a2 = a3 = a4 = a5 = h1 = h2 = A1 = 0.;
r1 = r2 = r3 = r4 = r5 = r6 = r7 = r8 = r9 = 0.;
#pragma omp parallel for private(col,c,l) firstprivate(ligg, a1, a2, a3, a4, a5, h1, h2, A1, r1, r2, r3, r4, r5, r6, r7, r8, r9) shared(ligDone, occ_pl, seg_pl)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      seg_im[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
      /*** Comparison to the alpha and h borders for each pixel ***/
        a1 = (MAl_in[lig][col] <= lim_al1);
        a2 = (MAl_in[lig][col] <= lim_al2);
        a3 = (MAl_in[lig][col] <= lim_al3);
        a4 = (MAl_in[lig][col] <= lim_al4);
        a5 = (MAl_in[lig][col] <= lim_al5);

        h1 = (MH_in[lig][col] <= lim_H1);
        h2 = (MH_in[lig][col] <= lim_H2);

        /* ZONE 1 (top right)*/
        r1 = !a1 * !h1;
        /* ZONE 2 (center right)*/
        r2 = a1 * !a5 * !h1;
        /* ZONE 3 (bottom right)*/
        r3 = a5 * !h1;
        /* ZONE 4 (top center)*/
        r4 = !a2 * h1 * !h2;
        /* ZONE 5 (center center)*/
        r5 = a2 * !a5 * h1 * !h2;
        /* ZONE 6 (bottom center)*/
        r6 = a5 * h1 * !h2;
        /* ZONE 7 (top left)*/
        r7 = !a3 * h2;
        /* ZONE 8 (center left)*/
        r8 = a3 * !a4 * h2;
        /* ZONE 9 (bottom left)*/
        r9 = a4 * h2;

        /* segment values ranging from 1 to 9 */
        seg_im[ligg][col] = (float) r1 + 2 * r2 + 3 * r3 + 4 * r4 + 5 * r5 + 6 * r6 + 7 * r7 + 8 * r8 + 9 * r9;

        c = (int) (fabs(MH_in[lig][col] * N_pl - 0.1));
        l = (int) (fabs(MAl_in[lig][col] * N_pl / 90. - 0.1));
        if (l > (N_pl - 1)) l = (N_pl - 1);
        if (c > (N_pl - 1)) c = (N_pl - 1);

        occ_pl[l][c] = occ_pl[l][c] + 1.;
        seg_pl[N_pl - 1 - l][c] = seg_im[ligg][col];
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  write_block_matrix_float(out_file, seg_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  fclose(fileH);
  fclose(fileAl);

  /*
  sprintf(filename, "%s%s", out_dir, "H_alpha_class");
  bmp_h_alpha(seg_im, Sub_Nlig, Sub_Ncol, filename, ColorMap9);

  sprintf(filename, "%s%s", out_dir, "H_alpha_occurence_plane");
  bmp_occ_pl(occ_pl, N_pl, N_pl, "jet", filename, type_H_alpha);

  sprintf(filename, "%s%s", out_dir, "H_alpha_segmented_plane");
  bmp_seg_pl(seg_pl, N_pl, N_pl, filename, type_H_alpha, ColorMap9);
  */
}
/********************************************************************
********************************************************************/
if (flag_A_alpha == 1) {
  if (FlagValid == 1) rewind(in_valid);

/* INPUT FILE OPENING*/
  sprintf(filename, "%sanisotropy.bin", in_dir);
  if ((fileA = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%salpha.bin", in_dir);
  if ((fileAl = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%sA_alpha_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  for (lig = 0; lig < N_pl; lig++)
    for (col = 0; col < N_pl; col++) {
      occ_pl[lig][col] = 0;
      seg_pl[lig][col] = 0;
      }

Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileA, MA_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileAl, MAl_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

a1 = a2 = a3 = a4 = a5 = h1 = h2 = A1 = 0.;
r1 = r2 = r3 = r4 = r5 = r6 = r7 = r8 = r9 = 0.;
#pragma omp parallel for private(col,c,l) firstprivate(ligg, a1, a5, A1, r1, r2, r3, r4, r5, r6) shared(ligDone, occ_pl, seg_pl)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      seg_im[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
      /*** Comparison to the alpha and h borders for each pixel ***/
        a1 = (MAl_in[lig][col] <= lim_al1);
        a5 = (MAl_in[lig][col] <= lim_al5);

        A1 = (MA_in[lig][col] <= lim_A);

        /* ZONE 1 (top right)*/
        r1 = !a1 * !A1;
        /* ZONE 2 (center right)*/
        r2 = a1 * !a5 * !A1;
        /* ZONE 3 (bottom right)*/
        r3 = a5 * !A1;
        /* ZONE 4 (top center)*/
        r4 = !a1 * A1;
        /* ZONE 5 (center center)*/
        r5 = a1 * !a5 * A1;
        /* ZONE 6 (bottom center)*/
        r6 = a5 * A1;

        /* segment values ranging from 1 to 9 */
        seg_im[ligg][col] = (float) 4 * r1 + 5 * r2 + 6 * r3 + 7 * r4 + 8 * r5 + 9 * r6;

        c = (int) (fabs(MA_in[lig][col] * N_pl - 0.1));
        l = (int) (fabs(MAl_in[lig][col] * N_pl / 90. - 0.1));
        if (l > (N_pl - 1)) l = (N_pl - 1);
        if (c > (N_pl - 1)) c = (N_pl - 1);

        occ_pl[l][c] = occ_pl[l][c] + 1.;
        seg_pl[N_pl - 1 - l][c] = seg_im[ligg][col];
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  write_block_matrix_float(out_file, seg_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  fclose(fileA);
  fclose(fileAl);

  /*
  sprintf(filename, "%s%s", out_dir, "A_alpha_class");
  bmp_h_alpha(seg_im, Sub_Nlig, Sub_Ncol, filename, ColorMap9);

  sprintf(filename, "%s%s", out_dir, "A_alpha_occurence_plane");
  bmp_occ_pl(occ_pl, N_pl, N_pl, "jet", filename, type_A_alpha);

  sprintf(filename, "%s%s", out_dir, "A_alpha_segmented_plane");
  bmp_seg_pl(seg_pl, N_pl, N_pl, filename, type_A_alpha, ColorMap9);
  */
}
/********************************************************************
********************************************************************/
if (flag_H_A == 1) {
  if (FlagValid == 1) rewind(in_valid);

/* INPUT FILE OPENING*/
  sprintf(filename, "%sentropy.bin", in_dir);
  if ((fileH = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sanisotropy.bin", in_dir);
  if ((fileA = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%sH_A_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  for (lig = 0; lig < N_pl; lig++)
    for (col = 0; col < N_pl; col++) {
      occ_pl[lig][col] = 0;
      seg_pl[lig][col] = 0;
      }

Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileH, MH_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileA, MA_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

a1 = a2 = a3 = a4 = a5 = h1 = h2 = A1 = 0.;
r1 = r2 = r3 = r4 = r5 = r6 = r7 = r8 = r9 = 0.;
#pragma omp parallel for private(col,c,l) firstprivate(ligg, h1, h2, A1, r1, r2, r3, r4, r5, r6) shared(ligDone, occ_pl, seg_pl)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      seg_im[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
      /*** Comparison to the alpha and h borders for each pixel ***/
        A1 = (MA_in[lig][col] <= lim_A);

        h1 = (MH_in[lig][col] <= lim_H1);
        h2 = (MH_in[lig][col] <= lim_H2);

        /* ZONE 1 (top right)*/
        r1 = !A1 * !h1;
        /* ZONE 2 (bottom right)*/
        r2 = A1 *  !h1;
        /* ZONE 3 (top center)*/
        r3 = !A1 * h1 * !h2;
        /* ZONE 4 (bottom center)*/
        r4 = A1 * h1 * !h2;
        /* ZONE 5 (top left)*/
        r5 = !A1 * h2;
        /* ZONE 6 (bottom right)*/
        r6 = A1 * h2;

        /* segment values ranging from 1 to 9 */
        seg_im[ligg][col] = (float) r1 * 2 + r2 * 1 + r3 * 5 + r4 * 4 + r5 * 8 + r6 * 7;

        c = (int) (fabs(MH_in[lig][col] * N_pl - 0.1));
        l = (int) (fabs(MA_in[lig][col] * N_pl - 0.1));
        if (l > (N_pl - 1)) l = (N_pl - 1);
        if (c > (N_pl - 1)) c = (N_pl - 1);

        occ_pl[l][c] = occ_pl[l][c] + 1.;
        seg_pl[N_pl - 1 - l][c] = seg_im[ligg][col];
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  write_block_matrix_float(out_file, seg_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  fclose(fileH);
  fclose(fileA);

  /*
  sprintf(filename, "%s%s", out_dir, "H_A_class");
  bmp_h_alpha(seg_im, Sub_Nlig, Sub_Ncol, filename, ColorMap9);

  sprintf(filename, "%s%s", out_dir, "H_A_occurence_plane");
  bmp_occ_pl(occ_pl, N_pl, N_pl, "jet", filename, type_H_A);

  sprintf(filename, "%s%s", out_dir, "H_A_segmented_plane");
  bmp_seg_pl(seg_pl, N_pl, N_pl, filename, type_H_A, ColorMap9);
  */
}
/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(MH_in, NligBlock[0]);
  free_matrix_float(MA_in, NligBlock[0]);
  free_matrix_float(MAl_in, NligBlock[0]);
  free_matrix_float(seg_im, Sub_Nlig);

*/  
/********************************************************************
********************************************************************/

/* INPUT FILE CLOSING*/
  if (FlagValid == 1) fclose(in_valid);

/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
Routine  : bmp_occ_pl
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002

*--------------------------------------------------------------------
Description :  Creates a bitmap file from an occurence matrix
               resulting from a polar plane segmentation. 
               Draws the class boundaries
********************************************************************/
void bmp_occ_pl(float **mat, int li, int co, char *cmap, char *nom, int type)
{
  FILE *fbmp;

  char *bufimg;
  char *bufcolor;
  float **border_im;

  int lig, col, l, nlig, ncol;
  int comp;
  int red[256], green[256], blue[256];

  float val, xx, min, max;

/* Colormap choice */
  comp = !strcmp(cmap,"gray") + (!strcmp(cmap, "hsv")) * 2 + (!strcmp(cmap,"jet")) *  3;

/* Looking for the max */
  max = -1E30;
  min = 1;
  for (lig = 0; lig < li; lig++)
  for (col = 0; col < co; col++) {
    if (mat[lig][col] <= min) mat[lig][col] = 0.0;
    else mat[lig][col] = 10 * log10(mat[lig][col]);
    if (mat[lig][col] > max) max = mat[lig][col];
    }

  nlig = li;
  ncol = co;
  bufimg = vector_char(nlig * ncol);
  bufcolor = vector_char(1024);

/* Boundaries definition */
  border_im = matrix_float(nlig, ncol);
  define_borders(border_im, type, nlig, ncol);

  strcat(nom, ".bmp");
  if ((fbmp = fopen(nom, "wb")) == NULL)
    edit_error("Could not open file", nom);

  header(nlig, ncol, max, min, fbmp);
  write_bmp_hdr(nlig, ncol, max, min, 8, nom);

/* The border color is the last of the colormap, here WHITE ***/

  colormap(red, green, blue, comp);
/*  couleur quadrillage = blanc */
  red[255] = 255;
  green[255] = 255;
  blue[255] = 255;

  for (col = 0; col < 256; col++) {
    bufcolor[4 * col] = (char) (red[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (blue[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }    /*fin col */
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

/* Mixing occurences and borders */
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      if (border_im[lig][col] == 0) {
        val = mat[lig][col];
        if (val > max) val = max;
        if (val < min) val = min;
        xx = (val - min) / (max - min + eps);
        if (xx > 1.) xx = 1.; 
        l = (int) (floor(254 * xx));
        } else
        l = 255;
      bufimg[lig * ncol + col] = (char) l;
      }
    }
    
  fwrite(&bufimg[0], sizeof(char), nlig * ncol, fbmp);
  free_matrix_float(border_im, nlig);
  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  fclose(fbmp);
}

/********************************************************************
Routine  : bmp_seg_pl
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002

*--------------------------------------------------------------------
Description :  Creates a bitmap file from a matrix resulting from a 
               polar plane segmentation. Draws the class boundaries
********************************************************************/
void bmp_seg_pl(float **mat, int li, int co, char *name, int type, char *ColorMap)
{
  FILE *fbmp;
  FILE *fcolormap;

  char *bufimg;
  char *bufcolor;
  char Tmp[FilePathLength];

  int lig, col, k, l, nlig, ncol, Ncolor;
  int red[256], green[256], blue[256];

  float **border_im;
  float MinBMP, MaxBMP;

  nlig = li;
  ncol = co;
  bufimg = vector_char(nlig * ncol);
  bufcolor = vector_char(1024);

  border_im = matrix_float(nlig, ncol);
  define_borders(border_im, type, nlig, ncol);

/* Bitmap file opening */
  strcat(name, ".bmp");
  if ((fbmp = fopen(name, "wb")) == NULL)
    edit_error("Could not open the bitmap file ", name);

/* Bitmap header writing */
  MinBMP = 1.;
  MaxBMP = 9.;

  header(nlig, ncol, MaxBMP, MinBMP, fbmp);
  write_bmp_hdr(nlig, ncol, MaxBMP, MinBMP, 8, name);

/* Colormap Definition  1 to 9*/
  if ((fcolormap = fopen(ColorMap, "r")) == NULL)
    edit_error("Could not open the file ", ColorMap);

/* Colormap Definition  */
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++) fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  red[255] = 255;
  green[255] = 255.;
  blue[255] = 255.;
  fclose(fcolormap);

/* Bitmap colormap writing */
  for (col = 0; col < 256; col++) {
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }    /*fin col */
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);
  
  /* Data conversion and writing */
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      if (border_im[lig][col] == 0) l = (int) mat[nlig - lig - 1][col];
      else l = 255;
      bufimg[lig * ncol + col] = (char) l;
      }
    }

  fwrite(&bufimg[0], sizeof(char), nlig * ncol, fbmp);

  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  free_matrix_float(border_im, nlig);
  fclose(fbmp);
}

/********************************************************************
Routine  : define_borders
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002

*--------------------------------------------------------------------
Description :  Creates decision boundaries in a polar plane
********************************************************************/
void define_borders(float **border_im, int type, int nlig, int ncol)
{
  int lig, col, l, c;
  float m, al, en, an;

/* type_A_alpha */
if (type == type_H_alpha) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * lim_H1)] = 1;
    border_im[lig][(int) floor(ncol * lim_H2)] = 1;
    }

/* Horizontal borders */
  for (col = 0; col < (int) (0.5 * nlig); col++) {
    l = (int) ((lim_al4 / 90) * nlig);
    border_im[l][col] = 1;
    l = (int) ((lim_al3 / 90) * nlig);
    border_im[l][col] = 1;
    }
  for (col = (lim_H2 * nlig + 1); col < (0.9 * nlig); col++) {
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = 1;
    l = (int) (lim_al2 / 90 * nlig);
    border_im[l][col] = 1;
    }

  for (col = (lim_H1 * nlig + 1); col < nlig; col++) {
    l = (int) (lim_al5 / 90 * nlig);
    border_im[l][col] = 1;
    l = (int) (lim_al1 / 90 * nlig);
    border_im[l][col] = 1;
    }

/*** Non linear borders ***/
  for (m = 0; m < 0.5; m = m + 1E-3) {
    al = (2 * m) / (1 + 2 * m);
    en = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;

    en = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(2 * m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;
    }
  for (m = 0.5; m < 1; m = m + 1E-3) {
    al = (2 * m) / (1 + 2 * m);
    en = (-(1 + 2 * m) * log(1 + 2 * m) + 2 * m * log(m + eps)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1)) l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;

    al = 2 / (1 + 2 * m);
    en = ((2 * m - 1) * log(2 * m - 1 + eps) - (2 * m + 1) * log(2 * m + 1)) * (-1 / (log(3) * (1 + 2 * m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(al * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;
    }
  }

/* type_A_alpha */
if (type == type_A_alpha) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++)
    border_im[lig][(int) floor(ncol * lim_A) - 1] = 1;

/* Horizontal borders */
  for (col = 0; col < ncol; col++) {
    l = (int) ((lim_al1 / 90) * nlig);
    border_im[l][col] = 1;
    l = (int) ((lim_al5 / 90) * nlig);
    border_im[l][col] = 1;
    }
  }

/* type_H_A */
if (type == type_H_A) {
/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * lim_H1)] = 1;
    border_im[lig][(int) floor(ncol * lim_H2)] = 1;
    }

/* Horizontal borders */
  for (col = 0; col < ncol; col++)
    border_im[(int) floor(nlig * lim_A)-1][col] = 1;

/*** Non linear borders ***/
  for (m = 0; m < 1; m = m + 1E-3) {
    an = (1 - m) / (1 + m);
    en = (-2 * log(2 + m) + m * log((m + eps) / (2 + m))) * (-1 / (log(3) * (2 + m)));
    c = (int) (fabs(en * ncol - 0.1));
    l = (int) (fabs(an * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;
    }
  }
}
