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

File     : xu_jin_uvH_planes_classifier.c
Project  : ESA_POLSARPRO-SATIM
Authors  : Feng XU
Version  : 1.0
Creation : 12/2016
Update  :
*--------------------------------------------------------------------

Description :  Classification of a SAR image into regions from its
               u,v and H parameters
			   
Deorientation theory of Polarimetric scattering targets and 
application to terrain surface classifcation
Feg XU and Ya-Qiu JIN
IEEE TGRS Vol 43, n° 10, October 2005

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

/* CONSTANTS */
#define lim_v1 0.2
#define lim_v2 -0.2
#define lim_H1 0.8
#define lim_H2 0.5
#define lim_u1 0.7
#define lim_u2 0.3

#define N_pl  200  /*Width of the projection plane */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void bmp_occ_pl(float **mat, int li, int co, char *cmap, char *nom);
void bmp_seg_pl(float **mat, int li, int co, char *name, char *ColorMap);
void define_borders(float **border_im, int nlig, int ncol);

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
  FILE *fileH, *fileU, *fileV;
  FILE *out_file;
  char filename[FilePathLength], ColorMap9[FilePathLength];

/* Internal variables */
  int lig, col, l, c;
  int Nligg, ligg;
  float ttype, H, u, v;
  int ligDone = 0;

/* Matrix arrays */
  float **MH_in;
  float **MU_in;
  float **MV_in;
  float **seg_im;
  float **seg_pl1;
  float **occ_pl1;
  float **seg_pl2;
  float **occ_pl2;
  float **seg_pl3;
  float **occ_pl3;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nxu_jin_uvH_planes_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
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

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
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
  /* MUin = Nlig*Ncol */
  NBlockA += Ncol; NBlockB += 0;
  /* MVin = Nlig*Ncol */
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

  Valid = matrix_float(NligBlock[0] + NwinL, Sub_Ncol + NwinC);

  MH_in = matrix_float(NligBlock[0], Sub_Ncol);
  MU_in = matrix_float(NligBlock[0], Sub_Ncol);
  MV_in = matrix_float(NligBlock[0], Sub_Ncol);
  seg_im = matrix_float(Sub_Nlig, Sub_Ncol);

  seg_pl1 = matrix_float(N_pl, N_pl);
  occ_pl1 = matrix_float(N_pl, N_pl);
  seg_pl2 = matrix_float(N_pl, N_pl);
  occ_pl2 = matrix_float(N_pl, N_pl);
  seg_pl3 = matrix_float(N_pl, N_pl);
  occ_pl3 = matrix_float(N_pl, N_pl);

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

/* INPUT FILE OPENING*/
  sprintf(filename, "%sxu-jin_H.bin", in_dir);
  if ((fileH = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sxu-jin_U.bin", in_dir);
  if ((fileU = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

  sprintf(filename, "%sxu-jin_V.bin", in_dir);
  if ((fileV = fopen(filename, "rb")) == NULL)
    edit_error("Could not open input file : ", filename);

/* OUTPUT FILE OPENING*/
  sprintf(filename, "%sxu-jin_uvH_class.bin", out_dir);
  if ((out_file = fopen(filename, "wb")) == NULL)
    edit_error("Could not open input file : ", filename);

  for (lig = 0; lig < N_pl; lig++)
    for (col = 0; col < N_pl; col++) {
      occ_pl1[lig][col] = 0; occ_pl2[lig][col] = 0; occ_pl3[lig][col] = 0;
      seg_pl1[lig][col] = 0; seg_pl2[lig][col] = 0; seg_pl3[lig][col] = 0;
      }

Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {
  ligDone = 0;
  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_matrix_float(fileH, MH_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileU, MU_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);
  read_block_matrix_float(fileV, MV_in, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

ttype = H = u = v = 0.;
#pragma omp parallel for private(col,c,l) firstprivate(ligg, ttype, H, u, v, occ_pl1, seg_pl1, occ_pl2, seg_pl2, occ_pl3, seg_pl3) shared(ligDone)
  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligDone++;
    if (omp_get_thread_num() == 0) PrintfLine(ligDone,NligBlock[Nb]);
    ligg = lig + Nligg;
    for (col = 0; col < Sub_Ncol; col++) {
      seg_im[ligg][col] = 0.;
      if (Valid[lig][col] == 1.) {
        H = MH_in[lig][col];
        u = MU_in[lig][col];
        v = MV_in[lig][col];
/*
		if (H > lim_H1 || (v < lim_v1 && v > lim_v2) )
			ttype = 4; //%--timber
		else if( v <= lim_v2 )
		{
			if( H < lim_H2 )
			{
				if( u > lim_u1 )
					ttype = 9; //%--urban3
				else
					ttype = 8; //%--urban2
			}
			else
			{
				ttype = 7; //%--urban1
			}
		}
		else
		{
			if( H < lim_H2)
			{
				if( u > lim_u1 )
					ttype=1; //%--surface1
				else if( u > lim_u2 )
					ttype=2; //%--surface2
				else
					ttype=3; //%--surface3
			}
			else
			{
				if( u > lim_u1 )
					ttype=6; //%--canopy2
				else
					ttype=5; //%--canopy1
			}
		}
*/
        if ((H < lim_H1) && (v < lim_v2 || v > lim_v1)) {
          if (v <= lim_v2) {
            if (u > lim_u1) {
              ttype = 7;
              } else {
              ttype = 8;
              }
            } else {
            if (H <= lim_H2) {
              if (u <= lim_u1) {
                if (u <= lim_u2) {
                  ttype = 3;
                  } else {
                  ttype = 2;
                  }
                } else {
                ttype = 1;
                }
              } else {
              if (u <= lim_u1) {
                ttype = 5;
                } else {
                ttype = 6;
                }
              }
            }
          } else {
          ttype = 4;
          }
               
        /* segment values ranging from 1 to 9 */
        seg_im[ligg][col] = ttype;

        c = (int) (fabs(H * N_pl - 0.1));
        l = (int) (fabs(u * N_pl - 0.1));
        if (l > (N_pl - 1)) l = (N_pl - 1);
        if (c > (N_pl - 1)) c = (N_pl - 1);
		
		if (v < -0.2) {
          occ_pl1[l][c] = occ_pl1[l][c] + 1.;
          seg_pl1[N_pl - 1 - l][c] = seg_im[ligg][col];
		  }
		if ((v > -0.2)&&(v < 0.2)) {
          occ_pl2[l][c] = occ_pl2[l][c] + 1.;
          seg_pl2[N_pl - 1 - l][c] = seg_im[ligg][col];
		  }
		if (v > 0.2) {
          occ_pl3[l][c] = occ_pl3[l][c] + 1.;
          seg_pl3[N_pl - 1 - l][c] = seg_im[ligg][col];
		  }
		  
        }
      }
    }
  Nligg += NligBlock[Nb];
  } // NbBlock

  write_block_matrix_float(out_file, seg_im, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  fclose(fileH);
  fclose(fileU);
  fclose(fileV);

  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_class");
  bmp_h_alpha(seg_im, Sub_Nlig, Sub_Ncol, filename, ColorMap9);
/*
  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_occurence_plane1");
  bmp_occ_pl(occ_pl1, N_pl, N_pl, "jet", filename);
  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_segmented_plane1");
  bmp_seg_pl(seg_pl1, N_pl, N_pl, filename, ColorMap9);

  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_occurence_plane2");
  bmp_occ_pl(occ_pl2, N_pl, N_pl, "jet", filename);
  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_segmented_plane2");
  bmp_seg_pl(seg_pl2, N_pl, N_pl, filename, ColorMap9);
  
  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_occurence_plane3");
  bmp_occ_pl(occ_pl3, N_pl, N_pl, "jet", filename);
  sprintf(filename, "%s%s", out_dir, "xu-jin_H_u_segmented_plane3");
  bmp_seg_pl(seg_pl3, N_pl, N_pl, filename, ColorMap9);
*/

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
  ncol = co;
  bufimg = vector_char(nlig * ncol);
  bufcolor = vector_char(1024);

/* Boundaries definition */
  border_im = matrix_float(nlig, ncol);
  define_borders(border_im, nlig, ncol);

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
  ncol = co;
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
void define_borders(float **border_im, int nlig, int ncol)
{
  int lig, col;

/* Vertical borders */
  for (lig = 0; lig < nlig; lig++) {
    border_im[lig][(int) floor(ncol * lim_u1)] = 1;
    border_im[lig][(int) floor(ncol * lim_u2)] = 1;
    }

/* Horizontal borders */
  for (col = 0; col < ncol; col++) {
    border_im[(int) floor(nlig * lim_H1)-1][col] = 1;
    border_im[(int) floor(nlig * lim_H2)-1][col] = 1;
    }

}
