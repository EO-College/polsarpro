/*******************************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File  : optimal_coherences_classifier.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 1.0
Creation : 12/2006
Update  : 12/2006 (Stephane MERIC)

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
Description :  Unsupervised classification of the complex optimal coherences

Inputs  : In in_dir directory
cmplx_coh_opt1.bin, cmplx_coh_opt2.bin, cmplx_coh_opt3.bin

Outputs : In out_dir directory
class_coh_opt.bin or class_coh_avg_opt.bin
class_coh_opt.bmp or class_coh_avg_opt.bmp
coh_opt_RGB.bmp or coh_avg_opt_RGB.bmp
A1.bin, A2.bin
A1_A2_occurence_plane.bmp
A1_A2_segmented_plane.bmp
seg_A1.bmp, seg_A2.bmp

-------------------------------------------------------------------------------
Routines  :
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
void check_file(char *file);
float *vector_float(int nh);
void free_vector_float( float *v);
float **matrix_float(int nrh,int nch);
void free_matrix_float(float **m,int nrh);
float ***matrix3d_float(int nz,int nrh,int nch);
void free_matrix3d_float(float ***m,int nz,int nrh);
void bmp_8bit(int nlig,int ncol,float Max,float Min,char *Colormap,float **DataBmp,char *name);
void  bmp_wishart(float **mat,int li,int co,char *nom,char *ColorMap);

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS  */

#define my_eps 1E-16

#define lim_a21 0.50  /* A1 and A2 decision boundaries */
#define lim_a22 0.20
#define lim_a11 0.25
#define lim_a12 0.05

#define N_pl  200  /*Width of the projection plane */

#define Nparam  3

/* ROUTINES */
#include "../lib/graphics.h"
#include "../lib/matrix.h"
#include "../lib/processing.h"
#include "../lib/util.h"

void bmp_occ_pl(float **mat, int li, int co, char *cmap, char *nom);
void bmp_seg_pl(float **mat, int li, int co, char *name, char *ColorMap);
void define_borders(float **quad_mat, int nlig, int ncol);
void bmp_24bit_opt_coh(float **mat_ch1,float **mat_ch2,float **mat_ch3, int li,int co,char *nom);

/*******************************************************************************
Routine  : main
Authors  : Laurent FERRO-FAMIL
Creation : 12/2006
Update  : 12/2006 (Stephane MERIC)
*-------------------------------------------------------------------------------
Description :  Unsupervised classification of the complex optimal coherences

Inputs  : In in_dir directory
coh_opt1.bin, coh_opt2.bin, coh_opt3.bin

Outputs : In out_dir directory
class_coh_opt.bin or class_coh_avg_opt.bin
class_coh_opt.bmp or class_coh_avg_opt.bmp
coh_opt_RGB.bmp or coh_avg_opt_RGB.bmp
A1.bin, A2.bin
A1_A2_occurence_plane.bmp
A1_A2_segmented_plane.bmp
seg_A1.bmp, seg_A2.bmp

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/


int main(int argc, char *argv[])
{
/* Input/Output file pointer arrays */
  FILE  *in_file[Nparam],*out_file;

/* Strings */
  char file_name[FilePathLength], in_dir[FilePathLength], out_dir[FilePathLength];
  char cohopt1file[FilePathLength], cohopt2file[FilePathLength], cohopt3file[FilePathLength];
  char PolarType[FilePathLength], PolarCase[FilePathLength];
  char ColorMap[FilePathLength];

/* Input variables */
  int Nlig, Ncol;  /* Initial image nb of lines and rows */
  int lig, col, np;
  int coh_avg;
  float gamma1, gamma2, gamma3;

  int l, c;
  float a11, a12, a21, a22;
  float r1, r2, r3, r4, r5, r6, r7, r8, r9;

/* Matrix arrays */
  float **seg_pl, **occ_pl;

  float **M_in;
  float **im_seg1;
  float **im_seg2;
  float **A1;
  float **A2;
  float **class_opt_coh;
  float **R, **G, **B;

/* PROGRAM START */

  if (argc < 8) {
  edit_error("opt_coh_classifier in_dir out_dir coh_opt1_file coh_opt2_file coh_opt3_file ColorMapA1_A2 coh_avg ( 0 / 1)\n","");
  } else {
  strcpy(in_dir, argv[1]);
  strcpy(out_dir, argv[2]);
  strcpy(cohopt1file, argv[3]);
  strcpy(cohopt2file, argv[4]);
  strcpy(cohopt3file, argv[5]);
  strcpy(ColorMap, argv[6]);
  coh_avg = atoi(argv[7]);
  }
  check_dir(in_dir);
  check_dir(out_dir);
  check_file(cohopt1file);
  check_file(cohopt2file);
  check_file(cohopt3file);
  check_file(ColorMap);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  read_config(in_dir,&Nlig,&Ncol,PolarCase,PolarType);
  
/* INPUT/OUPUT CONFIGURATIONS */
  seg_pl = matrix_float(N_pl, N_pl);
  occ_pl = matrix_float(N_pl, N_pl);

  M_in  = matrix_float(Nparam,Ncol*2);
  A1  = matrix_float(Nlig,Ncol);
  A2  = matrix_float(Nlig,Ncol);
  class_opt_coh = matrix_float(Nlig,Ncol);
  im_seg1 = matrix_float(Nlig,Ncol);
  im_seg2 = matrix_float(Nlig,Ncol);
  R  = matrix_float(Nlig,Ncol);
  G  = matrix_float(Nlig,Ncol);
  B  = matrix_float(Nlig,Ncol);

/* INPUT/OUTPUT FILE OPENING*/
  if ((in_file[0]=fopen(cohopt1file, "rb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",cohopt1file);
  if ((in_file[1]=fopen(cohopt2file, "rb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",cohopt2file);
  if ((in_file[2]=fopen(cohopt3file, "rb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",cohopt3file);

/* READING AVERAGING AND DECOMPOSITION */
  for (lig = 0; lig < Nlig; lig++) {
  if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
  for(np=0;np<Nparam;np++) fread(M_in[np],sizeof(float),Ncol*2,in_file[np]);

  for (col=0; col<Ncol; col++) {

    for(np=0;np<Nparam;np++)
    if(isnan(M_in[np][2*col])+isnan(M_in[np][2*col+1])) {
      M_in[np][2*col]=1; M_in[np][2*col+1]=0;
      } 
    
    gamma1 = sqrt(M_in[0][2*col]*M_in[0][2*col]+M_in[0][2*col+1]*M_in[0][2*col+1]);
    gamma2 = sqrt(M_in[1][2*col]*M_in[1][2*col]+M_in[1][2*col+1]*M_in[1][2*col+1]);
    gamma3 = sqrt(M_in[2][2*col]*M_in[2][2*col]+M_in[2][2*col+1]*M_in[2][2*col+1]);
  
    gamma1 = (gamma1>1) ? 1:gamma1;
    gamma2 = (gamma2>1) ? 1:gamma2;
    gamma3 = (gamma3>1) ? 1:gamma3;

    gamma3 = (gamma3>gamma2) ? gamma2:gamma3;
  
    R[lig][col] = gamma2;
    G[lig][col] = gamma1;
    B[lig][col] = gamma3;

    A1[lig][col] = (gamma1-gamma2)/(gamma1+my_eps);
    A2[lig][col] = (gamma1-gamma3)/(gamma1+my_eps);

    a11 = (A1[lig][col] <= lim_a11);
    a12 = (A1[lig][col] <= lim_a12);
    a21 = (A2[lig][col] <= lim_a21);
    a22 = (A2[lig][col] <= lim_a22);

/* ZONE 1 (top right)*/
    r1 = !a11 * !a21;
/* ZONE 2 (center right)*/
    r2 = !a11 * a21 * !a22;
/* ZONE 3 (bottom right)*/
    r3 = !a11 * a22;
/* ZONE 4 (top center)*/
    r4 = a11 * !a12 * !a21;
/* ZONE 5 (center center)*/
    r5 = a11 * !a12 * a21 * !a22;
/* ZONE 6 (bottom center)*/
    r6 = a11 * !a12 * a22;
/* ZONE 7 (top left)*/
    r7 = a12 * !a21;
/* ZONE 8 (center left)*/
    r8 = a12 * a21 * !a22;
/* ZONE 9 (bottom right)*/
    r9 = a12 * a22;
/* segment values ranging from 1 to 9 */
    class_opt_coh[lig][col] = r9 + 2 * r6 + 3 * r3 + 4 * r8 + 5 * r5 + 6 * r2 + 7 * r7 + 8 * r4 + 9 * r1;
    im_seg1[lig][col]= 9 * !a11 + 5*(a11 * !a12) + a12;
    im_seg2[lig][col]= 9 * !a21 + 5*(a21 * !a22) + a22;

    c = (int) (fabs(A1[lig][col] * N_pl - 0.1));
    l = (int) (fabs(A2[lig][col] * N_pl - 0.1));
    if (l > (N_pl - 1)) l = (N_pl - 1);
    if (c > (N_pl - 1)) c = (N_pl - 1);
    occ_pl[l][c]++;
    seg_pl[N_pl - 1 - l][c] = class_opt_coh[lig][col];
  
  }/*col*/
  }/*lig */

  if (coh_avg == 0) sprintf(file_name,"%s%s",out_dir,"class_coh_opt.bin");
  if (coh_avg == 1) sprintf(file_name,"%s%s",out_dir,"class_coh_avg_opt.bin");
  if ((out_file=fopen(file_name, "wb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",file_name);
  for(lig=0;lig<Nlig;lig++) fwrite(&class_opt_coh[lig][0],sizeof(float),Ncol,out_file);
  fclose(out_file);

  sprintf(file_name, "%s%s", out_dir, "A1_A2_occurence_plane");
  bmp_occ_pl(occ_pl, N_pl, N_pl, "jet", file_name);

  sprintf(file_name, "%s%s", out_dir, "A1_A2_segmented_plane");
  bmp_seg_pl(seg_pl, N_pl, N_pl, file_name, ColorMap);

  sprintf(file_name,"%s%s",out_dir,"seg_A1");
  bmp_wishart(im_seg2,Nlig,Ncol,file_name,ColorMap);

  sprintf(file_name,"%s%s",out_dir,"seg_A2");
  bmp_wishart(im_seg1,Nlig,Ncol,file_name,ColorMap);
 
  if (coh_avg == 0) sprintf(file_name,"%s%s",out_dir,"class_coh_opt");
  if (coh_avg == 1) sprintf(file_name,"%s%s",out_dir,"class_coh_avg_opt");
  bmp_wishart(class_opt_coh,Nlig,Ncol,file_name,ColorMap);
  
  R[0][0]=1;R[0][1]=0;
  G[0][0]=1;G[0][1]=0;
  B[0][0]=1;B[0][1]=0;
  if (coh_avg == 0) sprintf(file_name,"%s%s",out_dir,"coh_opt_RGB.bmp");
  if (coh_avg == 1) sprintf(file_name,"%s%s",out_dir,"coh_avg_opt_RGB.bmp");
  bmp_24bit_opt_coh(R,G,B,Nlig,Ncol,file_name);

  sprintf(file_name,"%s%s",out_dir,"A1.bin");
  if ((out_file=fopen(file_name, "wb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",file_name);
  for(lig=0;lig<Nlig;lig++) fwrite(&A1[lig][0],sizeof(float),Ncol,out_file);
  fclose(out_file);

  sprintf(file_name,"%s%s",out_dir,"A2.bin");
  if ((out_file=fopen(file_name, "wb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",file_name);
  for(lig=0;lig<Nlig;lig++) fwrite(&A2[lig][0],sizeof(float),Ncol,out_file);
  fclose(out_file);

  return 1;
}    /*Fin Main */


/*******************************************************************************
Routine  : bmp_occ_pl
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates a bitmap file from an occurence matrix resulting from a polar
plane segmentation. Draws the class boundaries
*-------------------------------------------------------------------------------
Inputs arguments :
mat  : matrix to be displayed containing float values
li  : matrix number of lines
co  : matrix number of rows
*name : BMP file name (without the .bmp extension)
Returned values  :
void
*******************************************************************************/
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
  if (mat[lig][col] <= min)
  mat[lig][col] = 0.0;
  else
  mat[lig][col] = 10 * log10(mat[lig][col]);
  if (mat[lig][col] > max)
  max = mat[lig][col];
  }

  nlig = li;
  ncol = co - (int) fmod((double) co, (double) 4);  /* The number of rows has tobe a factor of 4 */
  bufimg = vector_char(nlig * ncol);
  bufcolor = vector_char(1024);

/* Boundaries definition */
  border_im = matrix_float(nlig, ncol);
  define_borders(border_im, nlig, ncol);

  strcat(nom, ".bmp");
  if ((fbmp = fopen(nom, "wb")) == NULL)
  edit_error("Could not open file", nom);

  #if defined(__sun)||(__sun__)
  headerRas(ncol, nlig, max, min, fbmp);
  #else
  header(nlig, ncol, max, min, fbmp);
  #endif

  /* BMP HDR FILE */
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

/*******************************************************************************
Routine  : bmp_seg_pl
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates a bitmap file from a matrix resulting from a polar
plane segmentation. Draws the class boundaries
*-------------------------------------------------------------------------------
Inputs arguments :
mat  : matrix to be displayed containing float values
li  : matrix number of lines
co  : matrixnumber of rows
*name : BMP file name (without the .bmp extension)
Returned values  :
void
*******************************************************************************/
void bmp_seg_pl(float **mat, int li, int co, char *name, char *ColorMap)
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
  ncol = co - (int) fmod((double) co, (double) 4);  /* The number of rows has tobe a factor of 4 */
  bufimg = vector_char(nlig * ncol);
  bufcolor = vector_char(1024);

  border_im = matrix_float(nlig, ncol);
  define_borders(border_im, nlig, ncol);

/* Bitmap file opening */
  strcat(name, ".bmp");
  if ((fbmp = fopen(name, "wb")) == NULL)
  edit_error("Could not open the bitmap file ", name);

/* Bitmap header writing */
  MinBMP = 1.;
  MaxBMP = 9.;
  #if defined(__sun)||defined(__sun__)
  headerRas(ncol, nlig, MaxBMP, MinBMP, fbmp);
  #else
  header(nlig, ncol, MaxBMP, MinBMP, fbmp);
  #endif

  /* BMP HDR FILE */
  write_bmp_hdr(nlig, ncol, MaxBMP, MinBMP, 8, name);

/* Colormap Definition  1 to 9*/
  if ((fcolormap = fopen(ColorMap, "r")) == NULL)
  edit_error("Could not open the file ", ColorMap);

/* Colormap Definition  */
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
  fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
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
  if (border_im[lig][col] == 0)
  l = (int) mat[nlig - lig - 1][col];
  else
  l = 255;
  bufimg[lig * ncol + col] = (char) l;
  }
  }
  fwrite(&bufimg[0], sizeof(char), nlig * ncol, fbmp);

  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  free_matrix_float(border_im, nlig);
  fclose(fbmp);
}

/*******************************************************************************
Routine  : define_borders
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*-------------------------------------------------------------------------------
Description :  Creates decision boundaries in a polar plane
*-------------------------------------------------------------------------------
Inputs arguments :
nlig  : matrix number of lines
ncol  : matrix number of rows
Returned values  :
border_mat  : matrix containing a map of the borders
*******************************************************************************/
void define_borders(float **border_im, int nlig, int ncol)
{
  int lig, col;

/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
  border_im[lig][(int) floor(ncol * lim_a11)] = 1;
  border_im[lig][(int) floor(ncol * lim_a12)] = 1;
  border_im[lig][(int) floor(ncol * lim_a11)-1] = 1;
  border_im[lig][(int) floor(ncol * lim_a12)-1] = 1;
  }

/* Horizontal borders */
  for (col = 0; col < ncol; col++) {
  border_im[(int) floor(nlig * lim_a21)][col] = 1;
  border_im[(int) floor(nlig * lim_a22)][col] = 1;
  border_im[(int) floor(nlig * lim_a21)-1][col] = 1;
  border_im[(int) floor(nlig * lim_a22)-1][col] = 1;
  }


}

/*******************************************************************************
Routine  : bmp_24bit_opt_coh
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 12/2006
Update  :
*-------------------------------------------------------------------------------
Description :  Creates a 24 bit BMP Image using the Optimal Coherences
*-------------------------------------------------------------------------------
Inputs arguments :
nlig  : matrix number of lines
ncol  : matrix number of rows
*******************************************************************************/
void bmp_24bit_opt_coh(float **mat_ch1,float **mat_ch2,float **mat_ch3, int nlig,int ncol,char *nom)
{
  FILE *fbmp;
  char *bufimg;
  
  float val1,val2,val3,xx;
  float maxch1,maxch2,maxch3;
  float minch1,minch2,minch3;
  
  int lig,col,l,extracol,ncolbmp;

  extracol = (int) fmod(4 - (int) fmod(3*ncol, 4), 4);
  ncolbmp = 3*ncol + extracol;
  bufimg = vector_char(nlig * ncolbmp);
  
  if ((fbmp=fopen(nom,"wb"))==NULL)
  edit_error("ERREUR DANS L'OUVERTURE DU FICHIER",nom);

/*****************************************************************************/
/* Definition of the Header */

  write_header_bmp_24bit(nlig, ncol, fbmp);

  /* BMP HDR FILE */
  write_bmp_hdr(nlig, ncol, 0., 0., 24, nom);
  
/*****************************************************************************/

/*TRAITEMENT CANAL CH1*/
  MinMaxArray2D(mat_ch1,&minch1,&maxch1,nlig,ncol);
  if (maxch1 == 0) maxch1=eps;
  if (minch1 == 0) minch1=eps;

/**********************************************************************/
/*TRAITEMENT CANAL CH2*/

  MinMaxArray2D(mat_ch2,&minch2,&maxch2,nlig,ncol);
  if (maxch2 == 0) maxch2=eps;
  if (minch2 == 0) minch2=eps;

/**********************************************************************/
/*TRAITEMENT CANAL CH3*/

  MinMaxArray2D(mat_ch3,&minch3,&maxch3,nlig,ncol);
  if (maxch3 == 0) maxch3=eps;
  if (minch3 == 0) minch3=eps;

/**********************************************************************/

  for (lig=0; lig<nlig; lig++) {
  for (col=0; col<ncol; col++) {
    val1 =  mat_ch1[nlig-lig-1][col];
    val2 =  mat_ch2[nlig-lig-1][col];
    val3 =  mat_ch3[nlig-lig-1][col];
    
    if (val1 > maxch1) val1=maxch1;
    if (val1 < minch1) val1=minch1;
    xx=(val1-minch1)/(maxch1-minch1);
    if (xx > 1.) xx=1.;
    l=(int)(floor(255*xx));
    bufimg[lig*ncolbmp + 3*col +2]=(char)(l);
    
    if (val2 > maxch2) val2=maxch2;
    if (val2 < minch2) val2=minch2;
    xx=(val2-minch2)/(maxch2-minch2);
    if (xx > 1.) xx=1.;
    l=(int)(floor(255*xx));
    bufimg[lig*ncolbmp + 3*col +1]=(char)(l);
    
    if (val3 > maxch3) val3=maxch3;
    if (val3 < minch3) val3=minch3;
    xx=(val3-minch3)/(maxch3-minch3);
    if (xx > 1.) xx=1.;
    l=(int)(floor(255*xx));
    bufimg[lig*ncolbmp + 3*col +0]=(char)(l);
    } /*fin col*/
  } /*fin lig */

  fwrite(&bufimg[0],sizeof(char),nlig*ncolbmp,fbmp);

  fclose(fbmp);
}


