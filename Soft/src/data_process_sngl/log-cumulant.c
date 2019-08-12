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

File  : log-cumulant.c
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

Description :  log cumulant plane

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

/* CONSTANTS */
#define N_lig  200
#define N_col  200

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void bmp_occ_pl(float **mat, int li, int co, char *cmap, char *nom);
void define_borders(float **border_im, int nlig, int ncol);

float minK2, maxK2, minK3, maxK3;

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
  FILE *infileK2, *infileK3;
  char fileinK2[FilePathLength], fileinK3[FilePathLength], fileout[FilePathLength];

/* Internal variables */
  int lig, col, l, c;
  int ligDone = 0;
  
/* Matrix arrays */
  float **MK2_in;
  float **MK3_in;
  float **occ_pl;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nlog-cumulant.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if1 	input file k2\n");
strcat(UsageHelp," (string)	-if2 	input file k3\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,fileinK2,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,fileinK3,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,fileout,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);

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
  check_file(fileinK2);
  check_file(fileinK3);
  check_file(fileout);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

  Nlig = Sub_Nlig;
  Ncol = Sub_Ncol;

/* INPUT FILE OPENING*/
  if ((infileK2 = fopen(fileinK2, "rb")) == NULL)
    edit_error("Could not open input file : ", fileinK2);

  if ((infileK3 = fopen(fileinK3, "rb")) == NULL)
    edit_error("Could not open input file : ", fileinK3);

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

  /* MK2in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MK3in = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  MK2_in = matrix_float(NligBlock[0], Sub_Ncol);
  MK3_in = matrix_float(NligBlock[0], Sub_Ncol);

  occ_pl = matrix_float(N_lig, N_col);

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
  if (FlagValid == 1) rewind(in_valid);
  rewind(infileK2);
  rewind(infileK3);

  minK2 = INIT_MINMAX; minK3 = minK2;
  maxK2 = -INIT_MINMAX; maxK3 = maxK2;
  
for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(infileK2, MK2_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(infileK3, MK3_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col) shared(ligDone, minK2, maxK2, minK3, maxK3)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        if (MK2_in[lig][col] <= minK2) minK2 = MK2_in[lig][col];
        if (MK2_in[lig][col] > maxK2) maxK2 = MK2_in[lig][col];
        if (MK3_in[lig][col] <= minK3) minK3 = MK3_in[lig][col];
        if (MK3_in[lig][col] > maxK3) maxK3 = MK3_in[lig][col];
        }
      }
    }
  } // NbBlock
  
  
/********************************************************************
********************************************************************/
/* DATA PROCESSING */
  if (FlagValid == 1) rewind(in_valid);
  rewind(infileK2);
  rewind(infileK3);

  for (lig = 0; lig < N_lig; lig++)
    for (col = 0; col < N_col; col++) {
      occ_pl[lig][col] = 0;
      }

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(infileK2, MK2_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(infileK3, MK3_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

#pragma omp parallel for private(col,c,l) shared(ligDone, occ_pl)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
      /*** Comparison to the alpha and h borders for each pixel ***/
        MK2_in[lig][col] = (MK2_in[lig][col] - minK2)/(maxK2 - minK2);
        MK3_in[lig][col] = (MK3_in[lig][col] - minK3)/(maxK3 - minK3);
        c = (int) (fabs(MK3_in[lig][col] * N_col - 0.1));
        l = (int) (fabs(MK2_in[lig][col] * N_lig - 0.1));
        if (l > (N_lig - 1)) l = (N_lig - 1);
        if (c > (N_col - 1)) c = (N_col - 1);
        occ_pl[l][c] = occ_pl[l][c] + 1.;
        }
      }
    }
  } // NbBlock

/* OUTPUT FILE CLOSING*/
  fclose(infileK2);
  fclose(infileK3);

  bmp_occ_pl(occ_pl, N_lig, N_col, "jet", fileout);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0] + NwinL);

  free_matrix_float(MK2_in, NligBlock[0]);
  free_matrix_float(MK3_in, NligBlock[0]);

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
void bmp_occ_pl(float **mat, int li, int co, char *cmap, char *nom)
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
  ncol = co - (int) fmod((double) co, (double) 4);
  bufimg = vector_char(nlig * ncol);
  bufcolor = vector_char(1024);

/* Boundaries definition */
  border_im = matrix_float(nlig, ncol);
  define_borders(border_im, nlig, ncol);

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
Routine  : define_borders
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002

*--------------------------------------------------------------------
Description :  Creates decision boundaries in a polar plane
********************************************************************/
void define_borders(float **border_im, int nlig, int ncol)
{
  int lig, i, l, c;
  float x, y, xx, yy;

/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * 0.5)] = 1;
    }

/*** Non linear borders ***/
  for (i = 0; i <= 1000; i++) {
    xx = (maxK3*i)/1000.; yy = 0.6*log(1.+6.44*xx); 
    x = (xx - minK3)/(maxK3 - minK3); y = (yy - minK2)/(maxK2 - minK2);
    c = (int) (fabs(x * ncol - 0.1));
    l = (int) (fabs(y * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;
if ((i == 0) || (i == 1000)) printf("i %i xx %f x %f c %i yy %f y %f l %i\n",i,xx,x,c,yy,y,l);
    }

  for (i = 0; i <= 1000; i++) {
    xx = (minK3*i)/1000.; yy = log(1.-5.77*xx); 
    x = (xx - minK3)/(maxK3 - minK3); y = (yy - minK2)/(maxK2 - minK2);
    c = (int) (fabs(x * ncol - 0.1));
    l = (int) (fabs(y * nlig - 0.1));
    if (l > (nlig - 1))  l = (nlig - 1);
    if (c > (ncol - 1))  c = (ncol - 1);
    border_im[l][c] = 1;
if ((i == 0) || (i == 1000)) printf("i %i xx %f x %f c %i yy %f y %f l %i\n",i,xx,x,c,yy,y,l);
    }

}
