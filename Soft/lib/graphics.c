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

File   : graphics.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 09/2003
Update  : 12/2006 (Stephane MERIC)

*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR
(SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : 
eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------
Description :  GRAPHICS Routines
*--------------------------------------------------------------------
Routines  :
void header(int nlig,int ncol,float Max,float Min,FILE *fbmp);
void headerTiff(int nlig,int ncol,FILE *fbmp);
void footerTiff(short int nlig, short int ncol, FILE * fptr);
void colormap(int *red,int *green,int *blue,int comp);
void bmp_8bit(int nlig,int ncol,float Max,float Min,char *Colormap,float **DataBmp,char *name);
void bmp_8bit_char(int nlig,int ncol,float Max,float Min,char *Colormap,char *DataBmp,char *name);
void bmp_24bit(int nlig,int ncol,int mapgray,float **DataBmp,char *name);
void tiff_24bit(int nlig,int ncol,int mapgray,float **DataBmp,char *name);
void bmp_training_set(float **mat,int li,int co,char *nom,char *ColorMap16);
void bmp_wishart(float **mat,int li,int co,char *nom,char *ColorMap);
void bmp_h_alpha(float **mat, int li, int co, char *name, char *ColorMap);

void LoadColormap(int *red, int *green, int *blue, char *ColorMap);
void write_header_bmp_8bit(int nlig, int ncol, float Max, float Min, char *ColorMap, FILE *fbmp);
void write_header_bmp_8bit_mask(int nlig, int ncol, float Max, float Min, char *ColorMap, char *MaskCol, FILE *fbmp);
void write_header_bmp_24bit(int nlig, int ncol, FILE *fbmp);

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"
#include "rasterfile.h"

/********************************************************************
Routine  : header
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates and writes a bitmap file header
*--------------------------------------------------------------------
Inputs arguments :
nlig   : BMP image number of lines
ncol   : BMP image number of rows
Max    : Coded Maximum Value
Min    : Coded Minimum Value
*fbmp  : BMP file pointer
Returned values  :
void
********************************************************************/
void header(int nlig, int ncol, float Max, float Min, FILE * fbmp)
{
  int k;
  int extracol;
  unsigned int kk, coeff;
  float Maxmax;

/*Bitmap File Header*/
  k = 19778;
  fwrite(&k, sizeof(short int), 1, fbmp);
  extracol = (int) fmod(4 - (int) fmod(ncol, 4), 4);
  k = (ncol + extracol) * nlig + 1078;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 0;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 1078;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 40;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = ncol;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = nlig;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 1;
  fwrite(&k, sizeof(short int), 1, fbmp);
  k = 8;
  fwrite(&k, sizeof(short int), 1, fbmp);
  k = 0;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = ncol * nlig;
  fwrite(&k, sizeof(int), 1, fbmp);

  Maxmax = fabs(Min);
  if (Maxmax < fabs(Max)) Maxmax = fabs(Max);
  coeff = (unsigned int) floor(32768 / Maxmax);

  if (coeff < 65536) {
    kk = (unsigned int) (32768 + floor(Min * coeff));
    fwrite(&kk, sizeof(int), 1, fbmp);
    kk = (unsigned int) (32768 + floor(Max * coeff));
    fwrite(&kk, sizeof(int), 1, fbmp);
    //fwrite(&Max, sizeof(float), 1, fbmp);
    //fwrite(&Min, sizeof(float), 1, fbmp);
    k = 256;
    fwrite(&k, sizeof(int), 1, fbmp);
    //k = 256;
    //fwrite(&k, sizeof(int), 1, fbmp);
    fwrite(&coeff, sizeof(int), 1, fbmp);
    } else {
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 256;
    fwrite(&k, sizeof(int), 1, fbmp);
    k = 0;
    fwrite(&k, sizeof(int), 1, fbmp);
    }
  }

/********************************************************************
Routine  : headerTiff
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates and writes a 24 bit Tiff file header
*--------------------------------------------------------------------
Inputs arguments :
nlig  : TIFF image number of lines
ncol  : TIFF image number of rows
*fbmp  : TIFF file pointer
Returned values  :
void
********************************************************************/
void headerTiff(int nlig, int ncol, FILE * fptr)
{
  int offset;
  short int k = 18761;
  short int H42 = 42;

/*Tiff File Header*/
  /* Little endian & TIFF identifier */
  fwrite(&k, sizeof(short int), 1, fptr);
  fwrite(&H42, sizeof(short int), 1, fptr);

  offset = nlig * ncol * 3 + 8;
  fwrite(&offset, sizeof(int), 1, fptr);
  //putc((offset & 0xff000000) / 16777216,fptr);
  //putc((offset & 0x00ff0000) / 65536,fptr);
  //putc((offset & 0x0000ff00) / 256,fptr);
  //putc((offset & 0x000000ff),fptr);
  }

/********************************************************************
Routine  : footerTiff
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates and writes a 24 bit Tiff file footer
*--------------------------------------------------------------------
Inputs arguments :
nlig  : TIFF image number of lines
ncol  : TIFF image number of rows
*fbmp  : TIFF file pointer
Returned values  :
void
********************************************************************/
void footerTiff(short int nlig, short int ncol, FILE * fptr)
{
  int offset;
  short int kk;
  short int H0 = 0;
  short int H1 = 1;
  short int H2 = 2;
  short int H3 = 3;
  short int H4 = 4;
  short int H5 = 5;
  short int H8 = 8;
  short int H14 = 14;
  short int H255 = 255;

/*Tiff File Footer*/
  /* The number of directory entries (14) */
  fwrite(&H14, sizeof(short int), 1, fptr);

  /* Width tag, short int */
  kk=256;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&ncol, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Height tag, short int */
  kk=257;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&nlig, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Bits per sample tag, short int */
  kk=258;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  offset = nlig * ncol * 3 + 182;
  fwrite(&offset, sizeof(int), 1, fptr);

  /* Compression flag, short int */
  kk=259;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Photometric interpolation tag, short int */
  kk=262;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H2, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Strip offset tag, long int */
  kk=273;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H4, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H8, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Orientation flag, short int */
  kk=274;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Sample per pixel tag, short int */
  kk=277;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Rows per strip tag, short int */
  kk=278;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&nlig, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Strip byte count flag, long int */
  kk=279;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H4, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  offset = nlig * ncol * 3;
  fwrite(&offset, sizeof(int), 1, fptr);

  /* X Resolution, short int */
  kk=282;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H5, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  offset = nlig * ncol * 3 + 188;
  fwrite(&offset, sizeof(int), 1, fptr);

  /* Y Resolution, short int */
  kk=283;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H5, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  offset = (int)nlig * (int)ncol * 3 + 196;
  fwrite(&offset, sizeof(int), 1, fptr);

  /* Planar configuration tag, short int */
  kk=284;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Sample format tag, short int */
  kk=296;fwrite(&kk, sizeof(short int), 1, fptr);
  fwrite(&H3, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H2, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* End of the directory entry */
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Bits for each colour channel */
  fwrite(&H8, sizeof(short int), 1, fptr);
  fwrite(&H8, sizeof(short int), 1, fptr);
  fwrite(&H8, sizeof(short int), 1, fptr);

/////////////////////////////////////////////////////
  /* Minimum value for each component */
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);
  fwrite(&H0, sizeof(short int), 1, fptr);

  /* Maximum value per channel */
  fwrite(&H255, sizeof(short int), 1, fptr);
  fwrite(&H255, sizeof(short int), 1, fptr);
  fwrite(&H255, sizeof(short int), 1, fptr);

  /* Samples per pixel for each channel */
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
  fwrite(&H1, sizeof(short int), 1, fptr);
}

/********************************************************************
Routine  : colormap
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates a jet, hsv or gray 256 element colormap
*--------------------------------------------------------------------
Inputs arguments :
red   : red channel vector
green  : green channel vector
blue  : blue channel vector
comp  : colormap selector
Returned values  :
all color channels
********************************************************************/
void colormap(int *red, int *green, int *blue, int comp)
{
  int k;

  if (comp == 1) {
/*******************************************************************/
/*Definition of the Gray(256) Colormap*/
  for (k = 0; k < 256; k++) {
    red[k] = k;
    green[k] = k;
    blue[k] = k;
    }
  }

  if (comp == 2) {
/*******************************************************************/
/*Definition of the HSV(256) Colormap*/
  for (k = 0; k < 43; k++) {
    blue[k] = 255;
    green[k] = (int) (k * 0.0234 * 255);
    red[k] = 0;
    }
  for (k = 0; k < 43; k++) {
    blue[43 + k] = (int) (255 * (0.9922 - k * 0.0234));
    green[43 + k] = 255;
    red[43 + k] = 0;
    }
  for (k = 0; k < 42; k++) {
    blue[86 + k] = 0;
    green[86 + k] = 255;
    red[86 + k] = (int) (255 * (0.0156 + k * 0.0234));
    }
  for (k = 0; k < 43; k++) {
    blue[128 + k] = 0;
    green[128 + k] = (int) (255 * (1. - k * 0.0234));
    red[128 + k] = 255;
    }
  for (k = 0; k < 43; k++) {
    blue[171 + k] = (int) (255 * (0.0078 + k * 0.0234));
    green[171 + k] = 0;
    red[171 + k] = 255;
    }
  for (k = 0; k < 42; k++) {
    blue[214 + k] = 255;
    green[214 + k] = 0;
    red[214 + k] = (int) (255 * (0.9844 - k * 0.0234));
    }
  }

  if (comp == 3) {
/*******************************************************************/
/*Definition of the Jet(256) Colormap*/
  for (k = 0; k < 32; k++) {
    red[k] = 128 + 4 * k;
    green[k] = 0;
    blue[k] = 0;
    }
  for (k = 0; k < 64; k++) {
    red[32 + k] = 255;
    green[32 + k] = 4 * k;
    blue[32 + k] = 0;
    }
  for (k = 0; k < 64; k++) {
    red[96 + k] = 252 - 4 * k;
    green[96 + k] = 255;
    blue[96 + k] = 4 * k;
    }
  for (k = 0; k < 64; k++) {
    red[160 + k] = 0;
    green[160 + k] = 252 - 4 * k;
    blue[160 + k] = 255;
    }
  for (k = 0; k < 32; k++) {
    red[224 + k] = 0;
    green[224 + k] = 0;
    blue[224 + k] = 252 - 4 * k;
    }
  }

  red[0] = 125; green[0] = 125; blue[0] = 125;
}

/********************************************************************
Routine  : bmp_8bit
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  : 12/2006 (Stephane MERIC)
*--------------------------------------------------------------------
Description :  Creates a 8 bit BMP file
*--------------------------------------------------------------------
Inputs arguments :
nlig    : matrix number of lines
ncol    : matrix number of rows
Max    : Maximum value
Min    : Minimum value
*ColorMap : ColorMap name
**mat   : matrix containg float values
*name   : BMP file name (without the .bmp extension)
Returned values  :
void
********************************************************************/
void
bmp_8bit(int nlig, int ncol, float Max, float Min, char *ColorMap, float **DataBmp, char *name)
{
  FILE *fbmp;
  FILE *fcolormap;

  char *bufimg;
  char *bufcolor;
  char Tmp[FilePathLength];

  int lig, col, k, l;
  int ncolbmp, extracol, Ncolor;
  int red[256], green[256], blue[256];

  extracol = (int) fmod(4 - (int) fmod(ncol, 4), 4);
  ncolbmp = ncol + extracol;

  bufimg = vector_char(nlig * ncolbmp);
  bufcolor = vector_char(1024);

  if ((fbmp = fopen(name, "wb")) == NULL)
  edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", name);
/*******************************************************************/
/* Definition of the Header */

  header(nlig, ncol, Max, Min, fbmp);

/*******************************************************************/
/* Definition of the Colormap */
  if ((fcolormap = fopen(ColorMap, "r")) == NULL)
    edit_error("Could not open the bitmap file ",ColorMap);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
    fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  fclose(fcolormap);

/* Bitmap colormap and BMP writing */
  for (col = 0; col < 1024; col++) bufcolor[col] = (char) (0);

  for (col = 0; col < Ncolor; col++) {  
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);
  
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      l = (int) DataBmp[nlig - lig - 1][col];
      //if (l == 0) l = 1;
      bufimg[lig * ncolbmp + col] = (char) l;
      }
      
    for (col = 0; col < extracol; col++) {
      l = 0;
      bufimg[lig * ncolbmp + ncol + col] = (char) l;
      }
    }

  fwrite(&bufimg[0], sizeof(char), nlig * ncolbmp, fbmp);

  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  fclose(fbmp);
}

/********************************************************************
Routine  : bmp_8bit_char
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  ReCreates a 8 bit BMP file
*--------------------------------------------------------------------
Inputs arguments :
nlig    : matrix number of lines
ncol    : matrix number of rows
Max    : Maximum value
Min    : Minimum value
*ColorMap : ColorMap name
*mat   : vector containg char values
*name   : BMP file name (without the .bmp extension)
Returned values  :
void
********************************************************************/
void bmp_8bit_char(int nlig, int ncol, float Max, float Min, char *ColorMap, char *DataBmp, char *name)
{
  FILE *fbmp;
  FILE *fcolormap;

  char *bufimg;
  char *bufcolor;
  char Tmp[FilePathLength];

  int lig, col, k, l;
  int ncolbmp, extracol, Ncolor;
  int red[256], green[256], blue[256];

  extracol = (int) fmod(4 - (int) fmod(ncol, 4), 4);
  ncolbmp = ncol + extracol;

  bufimg = vector_char(nlig * ncolbmp);
  bufcolor = vector_char(1024);

  if ((fbmp = fopen(name, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", name);
/*******************************************************************/
/* Definition of the Header */

  header(nlig, ncol, Max, Min, fbmp);

/*******************************************************************/
/* Definition of the Colormap */
  if ((fcolormap = fopen(ColorMap, "r")) == NULL)
    edit_error("Could not open the bitmap file ",ColorMap);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
    fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  fclose(fcolormap);

/* Bitmap colormap and BMP writing */
  for (col = 0; col < 1024; col++) bufcolor[col] = (char) (0);

  for (col = 0; col < Ncolor; col++) {  
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);
          
/*******************************************************************/
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      bufimg[lig * ncolbmp + col] = DataBmp[lig * ncol + col];
      }
    for (col = 0; col < extracol; col++) {
      l = 0;
      bufimg[lig * ncolbmp + ncol + col] = (char) l;
      }
    }
  fwrite(&bufimg[0], sizeof(char), nlig * ncolbmp, fbmp);

  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  fclose(fbmp);
}

/********************************************************************
Routine  : bmp_24bit
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  : 12/2006 (Stephane MERIC)
*--------------------------------------------------------------------
Description :  Creates a 24 bit BMP file
*--------------------------------------------------------------------
Inputs arguments :
nlig    : matrix number of lines
ncol    : matrix number of rows
mapgray  : ColorMap Gray or not (0/1)
**mat   : matrix containg float values
*name   : BMP file name (without the .bmp extension)
Returned values  :
void
********************************************************************/
void bmp_24bit(int nlig, int ncol, int mapgray, float **DataBmp, char *name)
{
  FILE *fbmp;

  char *bmpimg;

  int lig, col, l;
  int ncolbmp;
  int extracol;

  float hue, red, green, blue;
  float m1, m2, h;

  extracol = (int) fmod(4 - (int) fmod(3*ncol, 4), 4);
  ncolbmp = 3*ncol + extracol;
  bmpimg = vector_char(nlig * ncolbmp);

  if ((fbmp = fopen(name, "wb")) == NULL)
  edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", name);
/*******************************************************************/
/* Definition of the Header */

  write_header_bmp_24bit(nlig, ncol, fbmp);

/*******************************************************************/
// CONVERSION HSV TO RGB with V=0.5 ans S=1
  m2 = 1.;
  m1 = 0.;
  for (lig = 0; lig < nlig; lig++) {
  for (col = 0; col < ncol; col++) {
    hue = DataBmp[lig][col];

    if (mapgray == 1) {
    red = hue/360.;
    green = hue/360.;
    blue = hue/360.;
    } else {
    h = hue + 120;
    if (h > 360.) h = h - 360.;
    else if (h < 0.) h = h + 360.;
    if (h < 60.) red = m1 + (m2 - m1) * h / 60.;
    else if (h < 180.) red = m2;
    else if (h < 240.) red = m1 + (m2 - m1) * (240. - h) / 60.;
    else red = m1;

    h = hue;
    if (h > 360.) h = h - 360.;
    else if (h < 0.) h = h + 360.;
    if (h < 60.) green = m1 + (m2 - m1) * h / 60.;
    else if (h < 180.) green = m2;
    else if (h < 240.) green = m1 + (m2 - m1) * (240. - h) / 60.;
    else green = m1;

    h = hue - 120;
    if (h > 360.) h = h - 360.;
    else if (h < 0.) h = h + 360.;
    if (h < 60.) blue = m1 + (m2 - m1) * h / 60.;
    else if (h < 180.) blue = m2;
    else if (h < 240.) blue = m1 + (m2 - m1) * (240. - h) / 60.;
    else blue = m1;

    }
      
    if (blue > 1.) blue = 1.;
    if (blue < 0.) blue = 0.;
    l = (int) (floor(255 * blue));
    bmpimg[(nlig - lig - 1) * ncolbmp + 3 * col + 0] = (char) (l);
    if (green > 1.) green = 1.;
    if (green < 0.) green = 0.;
    l = (int) (floor(255 * green));
    bmpimg[(nlig - lig - 1) * ncolbmp + 3 * col + 1] =  (char) (l);
    if (red > 1.) red = 1.;
    if (red < 0.) red = 0.;
    l = (int) (floor(255 * red));
    bmpimg[(nlig - lig - 1) * ncolbmp + 3 * col + 2] =  (char) (l);
    }
  }

  fwrite(&bmpimg[0], sizeof(char), nlig * ncolbmp, fbmp);

  free_vector_char(bmpimg);
  fclose(fbmp);
}

/********************************************************************
Routine  : tiff_24bit
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates a 24 bit TIFF file
*--------------------------------------------------------------------
Inputs arguments :
nlig    : matrix number of lines
ncol    : matrix number of rows
mapgray  : ColorMap Gray or not (0/1)
**mat   : matrix containg float values
*name   : TIFF file name (without the .tif extension)
Returned values  :
void
********************************************************************/
void tiff_24bit(int nlig, int ncol, int mapgray, float **DataBmp, char *name)
{
  FILE *fptr;

  char *bmpimg;

  int lig, col, l;
  int ncolbmp;

  float hue, red, green, blue;
  float m1, m2, h;

  //ncolbmp = ncol - (int) fmod((float) ncol, 4.);
  ncolbmp = 3*ncol;
  bmpimg = vector_char(nlig * ncolbmp);

  if ((fptr = fopen(name, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", name);
/*******************************************************************/
/* Definition of the Header */

  headerTiff(nlig, ncol, fptr);

/*******************************************************************/
// CONVERSION HSV TO RGB with V=0.5 ans S=1
  m2 = 1.;
  m1 = 0.;

for (lig = 0; lig < nlig; lig++) {
  for (col = 0; col < ncol; col++) {
    hue = DataBmp[lig][col];

    if (mapgray == 1) {
    red = hue/360.;
    green = hue/360.;
    blue = hue/360.;
    } else {
    h = hue + 120;
    if (h > 360.) h = h - 360.;
    else if (h < 0.) h = h + 360.;
    if (h < 60.) red = m1 + (m2 - m1) * h / 60.;
    else if (h < 180.) red = m2;
    else if (h < 240.) red = m1 + (m2 - m1) * (240. - h) / 60.;
    else red = m1;

    h = hue;
    if (h > 360.) h = h - 360.;
    else if (h < 0.) h = h + 360.;
    if (h < 60.) green = m1 + (m2 - m1) * h / 60.;
    else if (h < 180.) green = m2;
    else if (h < 240.) green = m1 + (m2 - m1) * (240. - h) / 60.;
    else green = m1;

    h = hue - 120;
    if (h > 360.) h = h - 360.;
    else if (h < 0.) h = h + 360.;
    if (h < 60.) blue = m1 + (m2 - m1) * h / 60.;
    else if (h < 180.) blue = m2;
    else if (h < 240.) blue = m1 + (m2 - m1) * (240. - h) / 60.;
    else blue = m1;
    }

    if (blue > 1.) blue = 1.;
    if (blue < 0.) blue = 0.;
    l = (int) (floor(255 * blue));
    bmpimg[lig * ncolbmp + 3 * col + 2] = (char) (l);
    if (green > 1.) green = 1.;
    if (green < 0.) green = 0.;
    l = (int) (floor(255 * green));
    bmpimg[lig * ncolbmp + 3 * col + 1] =  (char) (l);
    if (red > 1.) red = 1.;
    if (red < 0.) red = 0.;
    l = (int) (floor(255 * red));
    bmpimg[lig * ncolbmp + 3 * col + 0] =  (char) (l);
    }
  }

  fwrite(&bmpimg[0], sizeof(char), nlig * ncolbmp, fptr);

/*******************************************************************/
/* Definition of the Footer */

  footerTiff(nlig, ncol, fptr);

/*******************************************************************/

  free_vector_char(bmpimg);
  fclose(fptr);
}

/********************************************************************
Routine  : bmp_training_set
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates a bitmap file of the training areas
*--------------------------------------------------------------------
Inputs arguments :
mat  : matrix containg float values
nlig  : matrix number of lines
ncol  : matrixnumber of rows
*name : BMP file name (without the .bmp extension)
Returned values  :
void
********************************************************************/
void bmp_training_set(float **mat, int nlig, int ncol, char *nom, char *ColorMap16)
{
  FILE *fbmp;
  FILE *fcolormap;

  char *bufimg;
  char *bufcolor;
  char Tmp[FilePathLength];

  float min, max;
  int lig, col, k, l, extracol, ncolbmp, Ncolor;
  int red[256], green[256], blue[256];

  extracol = (int) fmod(4 - (int) fmod(ncol, 4), 4);
  ncolbmp = ncol + extracol;
  bufimg = vector_char(nlig * ncolbmp);
  bufcolor = vector_char(1024);

  strcat(nom, ".bmp");
  if ((fbmp = fopen(nom, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", nom);

  min = 1;
  max = -20;
  for (lig = 0; lig < nlig; lig++)
    for (col = 0; col < ncol; col++)
      if (mat[lig][col] > max)
  max = mat[lig][col];

  header(nlig, ncol, max, min, fbmp);

/* Definition of the Colormap */
  if ((fcolormap = fopen(ColorMap16, "r")) == NULL)
    edit_error("Could not open the bitmap file ", ColorMap16);

/* Colormap Definition  */
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
    fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  fclose(fcolormap);

/* Bitmap colormap writing */
  for (k = 0; k < Ncolor; k++) {
    bufcolor[4 * k] = (char) (1);
    bufcolor[4 * k + 1] = (char) (1);
    bufcolor[4 * k + 2] = (char) (1);
    bufcolor[4 * k + 3] = (char) (0);
    }    

  for (k = 0; k <= floor(max); k++) {
    bufcolor[4 * k] = (char) (blue[k]);
    bufcolor[4 * k + 1] = (char) (green[k]);
    bufcolor[4 * k + 2] = (char) (red[k]);
    bufcolor[4 * k + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

  /* Image writing */
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      l = (int) mat[nlig - lig - 1][col];
      bufimg[lig * ncolbmp + col] = (char) l;
      }
    }
    
  fwrite(&bufimg[0], sizeof(char), nlig * ncolbmp, fbmp);
  
  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  fclose(fbmp);
  }

/********************************************************************
Routine  : bmp_wishart
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates a bitmap file from a matrix resulting from the wishart
H / A / Alpha classification
*--------------------------------------------------------------------
Inputs arguments :
mat  : matrix containg float values
nlig  : matrix number of lines
ncol  : matrixnumber of rows
*name : BMP file name (without the .bmp extension)
Returned values  :
void
********************************************************************/
void bmp_wishart(float **mat, int nlig, int ncol, char *nom, char *ColorMap)
{
  FILE *fbmp;
  FILE *fcolormap;

  char *bufimg;
  char *bufcolor;
  char Tmp[10];

  float min, max;
  int lig, col, k, l, extracol, ncolbmp, Ncolor;
  int red[256], green[256], blue[256];

  extracol = (int) fmod(4 - (int) fmod(ncol, 4), 4);
  ncolbmp = ncol + extracol;
  bufimg = vector_char(nlig * ncolbmp);
  bufcolor = vector_char(1024);

  strcat(nom, ".bmp");
  if ((fbmp = fopen(nom, "wb")) == NULL)
    edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", nom);

  min = 1;
  max = -20;
  for (lig = 0; lig < nlig; lig++)
    for (col = 0; col < ncol; col++)
      if (mat[lig][col] > max)
  max = mat[lig][col];

  header(nlig, ncol, max, min, fbmp);

/* Definition of the Colormap */
  if ((fcolormap = fopen(ColorMap, "r")) == NULL)
    edit_error("Could not open the bitmap file ", ColorMap);

/* Colormap Definition  */
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
    fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  fclose(fcolormap);

  /* Bitmap colormap writing */  
  for (col = 0; col < 256; col++) {
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

  /* Image writing */
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      l = (int) mat[nlig - lig - 1][col];
      bufimg[lig * ncolbmp + col] = (char) l;
      }
    }
    
  fwrite(&bufimg[0], sizeof(char), nlig * ncolbmp, fbmp);
  
  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  fclose(fbmp);
  }

/********************************************************************
Routine  : bmp_h_alpha
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update  :
*--------------------------------------------------------------------
Description :  Creates a bitmap file from a matrix resulting from the H-Alpha classification
*--------------------------------------------------------------------
Inputs arguments :
mat  : matrix containg float values ranging from 1 to 9
nlig  : matrix number of lines
ncol  : matrixnumber of rows
*name : BMP file name (without the .bmp extension)
Returned values  :
void
********************************************************************/
void bmp_h_alpha(float **mat, int nlig, int ncol, char *name, char *ColorMap)
{
  FILE *fbmp;
  FILE *fcolormap;

  char *bufimg;
  char *bufcolor;
  char Tmp[FilePathLength];

  int lig, col, k, l, extracol, ncolbmp, Ncolor;
  int red[256], green[256], blue[256];

  float MinBMP, MaxBMP;

  extracol = (int) fmod(4 - (int) fmod(ncol, 4), 4);
  ncolbmp = ncol + extracol;
  bufimg = vector_char(nlig * ncolbmp);
  bufcolor = vector_char(1024);

/* Bitmap file opening */
  strcat(name, ".bmp");
  if ((fbmp = fopen(name, "wb")) == NULL)
    edit_error("Could not open the bitmap file ", name);

/* Bitmap header writing */
  MinBMP = 1.;
  MaxBMP = 9.;
  header(nlig, ncol, MaxBMP, MinBMP, fbmp);

/* Colormap Definition  1 to 9*/
  if ((fcolormap = fopen(ColorMap, "r")) == NULL)
    edit_error("Could not open the file ", ColorMap);

/* Colormap Definition  */
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%s\n", Tmp);
  fscanf(fcolormap, "%i\n", &Ncolor);
  for (k = 0; k < Ncolor; k++)
    fscanf(fcolormap, "%i %i %i\n", &red[k], &green[k], &blue[k]);
  fclose(fcolormap);

  /* Bitmap colormap writing */  
  for (col = 0; col < 256; col++) {
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

  /* Image writing */
  for (lig = 0; lig < nlig; lig++) {
    for (col = 0; col < ncol; col++) {
      l = (int) mat[nlig - lig - 1][col];
      bufimg[lig * ncolbmp + col] = (char) l;
      }
    }

  fwrite(&bufimg[0], sizeof(char), nlig * ncolbmp, fbmp);

  free_vector_char(bufcolor);
  free_vector_char(bufimg);
  fclose(fbmp);
  }

/********************************************************************
Routine  : LoadColormap
Authors  : Eric POTTIER
Creation : 07/2011
Update  :
*--------------------------------------------------------------------
Description :  Creates a 256 element colormap
*--------------------------------------------------------------------
Inputs arguments :
red   : red channel vector
green  : green channel vector
blue  : blue channel vector
colormap  : colormap selector
Returned values  :
all color channels
********************************************************************/
void LoadColormap(int *red, int *green, int *blue, char *ColorMap)
{

if (strcmp(ColorMap, "gray") == 0) {
/*******************************************************************/
/*Definition of the Gray(256) Colormap*/
red[0]=0; green[0]=0; blue[0]=0;
red[1]=1; green[1]=1; blue[1]=1;
red[2]=2; green[2]=2; blue[2]=2;
red[3]=3; green[3]=3; blue[3]=3;
red[4]=4; green[4]=4; blue[4]=4;
red[5]=5; green[5]=5; blue[5]=5;
red[6]=6; green[6]=6; blue[6]=6;
red[7]=7; green[7]=7; blue[7]=7;
red[8]=8; green[8]=8; blue[8]=8;
red[9]=9; green[9]=9; blue[9]=9;
red[10]=10; green[10]=10; blue[10]=10;
red[11]=11; green[11]=11; blue[11]=11;
red[12]=12; green[12]=12; blue[12]=12;
red[13]=13; green[13]=13; blue[13]=13;
red[14]=14; green[14]=14; blue[14]=14;
red[15]=15; green[15]=15; blue[15]=15;
red[16]=16; green[16]=16; blue[16]=16;
red[17]=17; green[17]=17; blue[17]=17;
red[18]=18; green[18]=18; blue[18]=18;
red[19]=19; green[19]=19; blue[19]=19;
red[20]=20; green[20]=20; blue[20]=20;
red[21]=21; green[21]=21; blue[21]=21;
red[22]=22; green[22]=22; blue[22]=22;
red[23]=23; green[23]=23; blue[23]=23;
red[24]=24; green[24]=24; blue[24]=24;
red[25]=25; green[25]=25; blue[25]=25;
red[26]=26; green[26]=26; blue[26]=26;
red[27]=27; green[27]=27; blue[27]=27;
red[28]=28; green[28]=28; blue[28]=28;
red[29]=29; green[29]=29; blue[29]=29;
red[30]=30; green[30]=30; blue[30]=30;
red[31]=31; green[31]=31; blue[31]=31;
red[32]=32; green[32]=32; blue[32]=32;
red[33]=33; green[33]=33; blue[33]=33;
red[34]=34; green[34]=34; blue[34]=34;
red[35]=35; green[35]=35; blue[35]=35;
red[36]=36; green[36]=36; blue[36]=36;
red[37]=37; green[37]=37; blue[37]=37;
red[38]=38; green[38]=38; blue[38]=38;
red[39]=39; green[39]=39; blue[39]=39;
red[40]=40; green[40]=40; blue[40]=40;
red[41]=41; green[41]=41; blue[41]=41;
red[42]=42; green[42]=42; blue[42]=42;
red[43]=43; green[43]=43; blue[43]=43;
red[44]=44; green[44]=44; blue[44]=44;
red[45]=45; green[45]=45; blue[45]=45;
red[46]=46; green[46]=46; blue[46]=46;
red[47]=47; green[47]=47; blue[47]=47;
red[48]=48; green[48]=48; blue[48]=48;
red[49]=49; green[49]=49; blue[49]=49;
red[50]=50; green[50]=50; blue[50]=50;
red[51]=51; green[51]=51; blue[51]=51;
red[52]=52; green[52]=52; blue[52]=52;
red[53]=53; green[53]=53; blue[53]=53;
red[54]=54; green[54]=54; blue[54]=54;
red[55]=55; green[55]=55; blue[55]=55;
red[56]=56; green[56]=56; blue[56]=56;
red[57]=57; green[57]=57; blue[57]=57;
red[58]=58; green[58]=58; blue[58]=58;
red[59]=59; green[59]=59; blue[59]=59;
red[60]=60; green[60]=60; blue[60]=60;
red[61]=61; green[61]=61; blue[61]=61;
red[62]=62; green[62]=62; blue[62]=62;
red[63]=63; green[63]=63; blue[63]=63;
red[64]=64; green[64]=64; blue[64]=64;
red[65]=65; green[65]=65; blue[65]=65;
red[66]=66; green[66]=66; blue[66]=66;
red[67]=67; green[67]=67; blue[67]=67;
red[68]=68; green[68]=68; blue[68]=68;
red[69]=69; green[69]=69; blue[69]=69;
red[70]=70; green[70]=70; blue[70]=70;
red[71]=71; green[71]=71; blue[71]=71;
red[72]=72; green[72]=72; blue[72]=72;
red[73]=73; green[73]=73; blue[73]=73;
red[74]=74; green[74]=74; blue[74]=74;
red[75]=75; green[75]=75; blue[75]=75;
red[76]=76; green[76]=76; blue[76]=76;
red[77]=77; green[77]=77; blue[77]=77;
red[78]=78; green[78]=78; blue[78]=78;
red[79]=79; green[79]=79; blue[79]=79;
red[80]=80; green[80]=80; blue[80]=80;
red[81]=81; green[81]=81; blue[81]=81;
red[82]=82; green[82]=82; blue[82]=82;
red[83]=83; green[83]=83; blue[83]=83;
red[84]=84; green[84]=84; blue[84]=84;
red[85]=85; green[85]=85; blue[85]=85;
red[86]=86; green[86]=86; blue[86]=86;
red[87]=87; green[87]=87; blue[87]=87;
red[88]=88; green[88]=88; blue[88]=88;
red[89]=89; green[89]=89; blue[89]=89;
red[90]=90; green[90]=90; blue[90]=90;
red[91]=91; green[91]=91; blue[91]=91;
red[92]=92; green[92]=92; blue[92]=92;
red[93]=93; green[93]=93; blue[93]=93;
red[94]=94; green[94]=94; blue[94]=94;
red[95]=95; green[95]=95; blue[95]=95;
red[96]=96; green[96]=96; blue[96]=96;
red[97]=97; green[97]=97; blue[97]=97;
red[98]=98; green[98]=98; blue[98]=98;
red[99]=99; green[99]=99; blue[99]=99;
red[100]=100; green[100]=100; blue[100]=100;
red[101]=101; green[101]=101; blue[101]=101;
red[102]=102; green[102]=102; blue[102]=102;
red[103]=103; green[103]=103; blue[103]=103;
red[104]=104; green[104]=104; blue[104]=104;
red[105]=105; green[105]=105; blue[105]=105;
red[106]=106; green[106]=106; blue[106]=106;
red[107]=107; green[107]=107; blue[107]=107;
red[108]=108; green[108]=108; blue[108]=108;
red[109]=109; green[109]=109; blue[109]=109;
red[110]=110; green[110]=110; blue[110]=110;
red[111]=111; green[111]=111; blue[111]=111;
red[112]=112; green[112]=112; blue[112]=112;
red[113]=113; green[113]=113; blue[113]=113;
red[114]=114; green[114]=114; blue[114]=114;
red[115]=115; green[115]=115; blue[115]=115;
red[116]=116; green[116]=116; blue[116]=116;
red[117]=117; green[117]=117; blue[117]=117;
red[118]=118; green[118]=118; blue[118]=118;
red[119]=119; green[119]=119; blue[119]=119;
red[120]=120; green[120]=120; blue[120]=120;
red[121]=121; green[121]=121; blue[121]=121;
red[122]=122; green[122]=122; blue[122]=122;
red[123]=123; green[123]=123; blue[123]=123;
red[124]=124; green[124]=124; blue[124]=124;
red[125]=125; green[125]=125; blue[125]=125;
red[126]=126; green[126]=126; blue[126]=126;
red[127]=127; green[127]=127; blue[127]=127;
red[128]=128; green[128]=128; blue[128]=128;
red[129]=129; green[129]=129; blue[129]=129;
red[130]=130; green[130]=130; blue[130]=130;
red[131]=131; green[131]=131; blue[131]=131;
red[132]=132; green[132]=132; blue[132]=132;
red[133]=133; green[133]=133; blue[133]=133;
red[134]=134; green[134]=134; blue[134]=134;
red[135]=135; green[135]=135; blue[135]=135;
red[136]=136; green[136]=136; blue[136]=136;
red[137]=137; green[137]=137; blue[137]=137;
red[138]=138; green[138]=138; blue[138]=138;
red[139]=139; green[139]=139; blue[139]=139;
red[140]=140; green[140]=140; blue[140]=140;
red[141]=141; green[141]=141; blue[141]=141;
red[142]=142; green[142]=142; blue[142]=142;
red[143]=143; green[143]=143; blue[143]=143;
red[144]=144; green[144]=144; blue[144]=144;
red[145]=145; green[145]=145; blue[145]=145;
red[146]=146; green[146]=146; blue[146]=146;
red[147]=147; green[147]=147; blue[147]=147;
red[148]=148; green[148]=148; blue[148]=148;
red[149]=149; green[149]=149; blue[149]=149;
red[150]=150; green[150]=150; blue[150]=150;
red[151]=151; green[151]=151; blue[151]=151;
red[152]=152; green[152]=152; blue[152]=152;
red[153]=153; green[153]=153; blue[153]=153;
red[154]=154; green[154]=154; blue[154]=154;
red[155]=155; green[155]=155; blue[155]=155;
red[156]=156; green[156]=156; blue[156]=156;
red[157]=157; green[157]=157; blue[157]=157;
red[158]=158; green[158]=158; blue[158]=158;
red[159]=159; green[159]=159; blue[159]=159;
red[160]=160; green[160]=160; blue[160]=160;
red[161]=161; green[161]=161; blue[161]=161;
red[162]=162; green[162]=162; blue[162]=162;
red[163]=163; green[163]=163; blue[163]=163;
red[164]=164; green[164]=164; blue[164]=164;
red[165]=165; green[165]=165; blue[165]=165;
red[166]=166; green[166]=166; blue[166]=166;
red[167]=167; green[167]=167; blue[167]=167;
red[168]=168; green[168]=168; blue[168]=168;
red[169]=169; green[169]=169; blue[169]=169;
red[170]=170; green[170]=170; blue[170]=170;
red[171]=171; green[171]=171; blue[171]=171;
red[172]=172; green[172]=172; blue[172]=172;
red[173]=173; green[173]=173; blue[173]=173;
red[174]=174; green[174]=174; blue[174]=174;
red[175]=175; green[175]=175; blue[175]=175;
red[176]=176; green[176]=176; blue[176]=176;
red[177]=177; green[177]=177; blue[177]=177;
red[178]=178; green[178]=178; blue[178]=178;
red[179]=179; green[179]=179; blue[179]=179;
red[180]=180; green[180]=180; blue[180]=180;
red[181]=181; green[181]=181; blue[181]=181;
red[182]=182; green[182]=182; blue[182]=182;
red[183]=183; green[183]=183; blue[183]=183;
red[184]=184; green[184]=184; blue[184]=184;
red[185]=185; green[185]=185; blue[185]=185;
red[186]=186; green[186]=186; blue[186]=186;
red[187]=187; green[187]=187; blue[187]=187;
red[188]=188; green[188]=188; blue[188]=188;
red[189]=189; green[189]=189; blue[189]=189;
red[190]=190; green[190]=190; blue[190]=190;
red[191]=191; green[191]=191; blue[191]=191;
red[192]=192; green[192]=192; blue[192]=192;
red[193]=193; green[193]=193; blue[193]=193;
red[194]=194; green[194]=194; blue[194]=194;
red[195]=195; green[195]=195; blue[195]=195;
red[196]=196; green[196]=196; blue[196]=196;
red[197]=197; green[197]=197; blue[197]=197;
red[198]=198; green[198]=198; blue[198]=198;
red[199]=199; green[199]=199; blue[199]=199;
red[200]=200; green[200]=200; blue[200]=200;
red[201]=201; green[201]=201; blue[201]=201;
red[202]=202; green[202]=202; blue[202]=202;
red[203]=203; green[203]=203; blue[203]=203;
red[204]=204; green[204]=204; blue[204]=204;
red[205]=205; green[205]=205; blue[205]=205;
red[206]=206; green[206]=206; blue[206]=206;
red[207]=207; green[207]=207; blue[207]=207;
red[208]=208; green[208]=208; blue[208]=208;
red[209]=209; green[209]=209; blue[209]=209;
red[210]=210; green[210]=210; blue[210]=210;
red[211]=211; green[211]=211; blue[211]=211;
red[212]=212; green[212]=212; blue[212]=212;
red[213]=213; green[213]=213; blue[213]=213;
red[214]=214; green[214]=214; blue[214]=214;
red[215]=215; green[215]=215; blue[215]=215;
red[216]=216; green[216]=216; blue[216]=216;
red[217]=217; green[217]=217; blue[217]=217;
red[218]=218; green[218]=218; blue[218]=218;
red[219]=219; green[219]=219; blue[219]=219;
red[220]=220; green[220]=220; blue[220]=220;
red[221]=221; green[221]=221; blue[221]=221;
red[222]=222; green[222]=222; blue[222]=222;
red[223]=223; green[223]=223; blue[223]=223;
red[224]=224; green[224]=224; blue[224]=224;
red[225]=225; green[225]=225; blue[225]=225;
red[226]=226; green[226]=226; blue[226]=226;
red[227]=227; green[227]=227; blue[227]=227;
red[228]=228; green[228]=228; blue[228]=228;
red[229]=229; green[229]=229; blue[229]=229;
red[230]=230; green[230]=230; blue[230]=230;
red[231]=231; green[231]=231; blue[231]=231;
red[232]=232; green[232]=232; blue[232]=232;
red[233]=233; green[233]=233; blue[233]=233;
red[234]=234; green[234]=234; blue[234]=234;
red[235]=235; green[235]=235; blue[235]=235;
red[236]=236; green[236]=236; blue[236]=236;
red[237]=237; green[237]=237; blue[237]=237;
red[238]=238; green[238]=238; blue[238]=238;
red[239]=239; green[239]=239; blue[239]=239;
red[240]=240; green[240]=240; blue[240]=240;
red[241]=241; green[241]=241; blue[241]=241;
red[242]=242; green[242]=242; blue[242]=242;
red[243]=243; green[243]=243; blue[243]=243;
red[244]=244; green[244]=244; blue[244]=244;
red[245]=245; green[245]=245; blue[245]=245;
red[246]=246; green[246]=246; blue[246]=246;
red[247]=247; green[247]=247; blue[247]=247;
red[248]=248; green[248]=248; blue[248]=248;
red[249]=249; green[249]=249; blue[249]=249;
red[250]=250; green[250]=250; blue[250]=250;
red[251]=251; green[251]=251; blue[251]=251;
red[252]=252; green[252]=252; blue[252]=252;
red[253]=253; green[253]=253; blue[253]=253;
red[254]=254; green[254]=254; blue[254]=254;
red[255]=255; green[255]=255; blue[255]=255;
}
if (strcmp(ColorMap, "grayrev") == 0) {
/*******************************************************************/
/*Definition of the GrayRev(256) Colormap*/
red[0]=255; green[0]=255; blue[0]=255;
red[1]=254; green[1]=254; blue[1]=254;
red[2]=253; green[2]=253; blue[2]=253;
red[3]=252; green[3]=252; blue[3]=252;
red[4]=251; green[4]=251; blue[4]=251;
red[5]=250; green[5]=250; blue[5]=250;
red[6]=249; green[6]=249; blue[6]=249;
red[7]=248; green[7]=248; blue[7]=248;
red[8]=247; green[8]=247; blue[8]=247;
red[9]=246; green[9]=246; blue[9]=246;
red[10]=245; green[10]=245; blue[10]=245;
red[11]=244; green[11]=244; blue[11]=244;
red[12]=243; green[12]=243; blue[12]=243;
red[13]=242; green[13]=242; blue[13]=242;
red[14]=241; green[14]=241; blue[14]=241;
red[15]=240; green[15]=240; blue[15]=240;
red[16]=239; green[16]=239; blue[16]=239;
red[17]=238; green[17]=238; blue[17]=238;
red[18]=237; green[18]=237; blue[18]=237;
red[19]=236; green[19]=236; blue[19]=236;
red[20]=235; green[20]=235; blue[20]=235;
red[21]=234; green[21]=234; blue[21]=234;
red[22]=233; green[22]=233; blue[22]=233;
red[23]=232; green[23]=232; blue[23]=232;
red[24]=231; green[24]=231; blue[24]=231;
red[25]=230; green[25]=230; blue[25]=230;
red[26]=229; green[26]=229; blue[26]=229;
red[27]=228; green[27]=228; blue[27]=228;
red[28]=227; green[28]=227; blue[28]=227;
red[29]=226; green[29]=226; blue[29]=226;
red[30]=225; green[30]=225; blue[30]=225;
red[31]=224; green[31]=224; blue[31]=224;
red[32]=223; green[32]=223; blue[32]=223;
red[33]=222; green[33]=222; blue[33]=222;
red[34]=221; green[34]=221; blue[34]=221;
red[35]=220; green[35]=220; blue[35]=220;
red[36]=219; green[36]=219; blue[36]=219;
red[37]=218; green[37]=218; blue[37]=218;
red[38]=217; green[38]=217; blue[38]=217;
red[39]=216; green[39]=216; blue[39]=216;
red[40]=215; green[40]=215; blue[40]=215;
red[41]=214; green[41]=214; blue[41]=214;
red[42]=213; green[42]=213; blue[42]=213;
red[43]=212; green[43]=212; blue[43]=212;
red[44]=211; green[44]=211; blue[44]=211;
red[45]=210; green[45]=210; blue[45]=210;
red[46]=209; green[46]=209; blue[46]=209;
red[47]=208; green[47]=208; blue[47]=208;
red[48]=207; green[48]=207; blue[48]=207;
red[49]=206; green[49]=206; blue[49]=206;
red[50]=205; green[50]=205; blue[50]=205;
red[51]=204; green[51]=204; blue[51]=204;
red[52]=203; green[52]=203; blue[52]=203;
red[53]=202; green[53]=202; blue[53]=202;
red[54]=201; green[54]=201; blue[54]=201;
red[55]=200; green[55]=200; blue[55]=200;
red[56]=199; green[56]=199; blue[56]=199;
red[57]=198; green[57]=198; blue[57]=198;
red[58]=197; green[58]=197; blue[58]=197;
red[59]=196; green[59]=196; blue[59]=196;
red[60]=195; green[60]=195; blue[60]=195;
red[61]=194; green[61]=194; blue[61]=194;
red[62]=193; green[62]=193; blue[62]=193;
red[63]=192; green[63]=192; blue[63]=192;
red[64]=191; green[64]=191; blue[64]=191;
red[65]=190; green[65]=190; blue[65]=190;
red[66]=189; green[66]=189; blue[66]=189;
red[67]=188; green[67]=188; blue[67]=188;
red[68]=187; green[68]=187; blue[68]=187;
red[69]=186; green[69]=186; blue[69]=186;
red[70]=185; green[70]=185; blue[70]=185;
red[71]=184; green[71]=184; blue[71]=184;
red[72]=183; green[72]=183; blue[72]=183;
red[73]=182; green[73]=182; blue[73]=182;
red[74]=181; green[74]=181; blue[74]=181;
red[75]=180; green[75]=180; blue[75]=180;
red[76]=179; green[76]=179; blue[76]=179;
red[77]=178; green[77]=178; blue[77]=178;
red[78]=177; green[78]=177; blue[78]=177;
red[79]=176; green[79]=176; blue[79]=176;
red[80]=175; green[80]=175; blue[80]=175;
red[81]=174; green[81]=174; blue[81]=174;
red[82]=173; green[82]=173; blue[82]=173;
red[83]=172; green[83]=172; blue[83]=172;
red[84]=171; green[84]=171; blue[84]=171;
red[85]=170; green[85]=170; blue[85]=170;
red[86]=169; green[86]=169; blue[86]=169;
red[87]=168; green[87]=168; blue[87]=168;
red[88]=167; green[88]=167; blue[88]=167;
red[89]=166; green[89]=166; blue[89]=166;
red[90]=165; green[90]=165; blue[90]=165;
red[91]=164; green[91]=164; blue[91]=164;
red[92]=163; green[92]=163; blue[92]=163;
red[93]=162; green[93]=162; blue[93]=162;
red[94]=161; green[94]=161; blue[94]=161;
red[95]=160; green[95]=160; blue[95]=160;
red[96]=159; green[96]=159; blue[96]=159;
red[97]=158; green[97]=158; blue[97]=158;
red[98]=157; green[98]=157; blue[98]=157;
red[99]=156; green[99]=156; blue[99]=156;
red[100]=155; green[100]=155; blue[100]=155;
red[101]=154; green[101]=154; blue[101]=154;
red[102]=153; green[102]=153; blue[102]=153;
red[103]=152; green[103]=152; blue[103]=152;
red[104]=151; green[104]=151; blue[104]=151;
red[105]=150; green[105]=150; blue[105]=150;
red[106]=149; green[106]=149; blue[106]=149;
red[107]=148; green[107]=148; blue[107]=148;
red[108]=147; green[108]=147; blue[108]=147;
red[109]=146; green[109]=146; blue[109]=146;
red[110]=145; green[110]=145; blue[110]=145;
red[111]=144; green[111]=144; blue[111]=144;
red[112]=143; green[112]=143; blue[112]=143;
red[113]=142; green[113]=142; blue[113]=142;
red[114]=141; green[114]=141; blue[114]=141;
red[115]=140; green[115]=140; blue[115]=140;
red[116]=139; green[116]=139; blue[116]=139;
red[117]=138; green[117]=138; blue[117]=138;
red[118]=137; green[118]=137; blue[118]=137;
red[119]=136; green[119]=136; blue[119]=136;
red[120]=135; green[120]=135; blue[120]=135;
red[121]=134; green[121]=134; blue[121]=134;
red[122]=133; green[122]=133; blue[122]=133;
red[123]=132; green[123]=132; blue[123]=132;
red[124]=131; green[124]=131; blue[124]=131;
red[125]=130; green[125]=130; blue[125]=130;
red[126]=129; green[126]=129; blue[126]=129;
red[127]=128; green[127]=128; blue[127]=128;
red[128]=127; green[128]=127; blue[128]=127;
red[129]=126; green[129]=126; blue[129]=126;
red[130]=125; green[130]=125; blue[130]=125;
red[131]=124; green[131]=124; blue[131]=124;
red[132]=123; green[132]=123; blue[132]=123;
red[133]=122; green[133]=122; blue[133]=122;
red[134]=121; green[134]=121; blue[134]=121;
red[135]=120; green[135]=120; blue[135]=120;
red[136]=119; green[136]=119; blue[136]=119;
red[137]=118; green[137]=118; blue[137]=118;
red[138]=117; green[138]=117; blue[138]=117;
red[139]=116; green[139]=116; blue[139]=116;
red[140]=115; green[140]=115; blue[140]=115;
red[141]=114; green[141]=114; blue[141]=114;
red[142]=113; green[142]=113; blue[142]=113;
red[143]=112; green[143]=112; blue[143]=112;
red[144]=111; green[144]=111; blue[144]=111;
red[145]=110; green[145]=110; blue[145]=110;
red[146]=109; green[146]=109; blue[146]=109;
red[147]=108; green[147]=108; blue[147]=108;
red[148]=107; green[148]=107; blue[148]=107;
red[149]=106; green[149]=106; blue[149]=106;
red[150]=105; green[150]=105; blue[150]=105;
red[151]=104; green[151]=104; blue[151]=104;
red[152]=103; green[152]=103; blue[152]=103;
red[153]=102; green[153]=102; blue[153]=102;
red[154]=101; green[154]=101; blue[154]=101;
red[155]=100; green[155]=100; blue[155]=100;
red[156]=99; green[156]=99; blue[156]=99;
red[157]=98; green[157]=98; blue[157]=98;
red[158]=97; green[158]=97; blue[158]=97;
red[159]=96; green[159]=96; blue[159]=96;
red[160]=95; green[160]=95; blue[160]=95;
red[161]=94; green[161]=94; blue[161]=94;
red[162]=93; green[162]=93; blue[162]=93;
red[163]=92; green[163]=92; blue[163]=92;
red[164]=91; green[164]=91; blue[164]=91;
red[165]=90; green[165]=90; blue[165]=90;
red[166]=89; green[166]=89; blue[166]=89;
red[167]=88; green[167]=88; blue[167]=88;
red[168]=87; green[168]=87; blue[168]=87;
red[169]=86; green[169]=86; blue[169]=86;
red[170]=85; green[170]=85; blue[170]=85;
red[171]=84; green[171]=84; blue[171]=84;
red[172]=83; green[172]=83; blue[172]=83;
red[173]=82; green[173]=82; blue[173]=82;
red[174]=81; green[174]=81; blue[174]=81;
red[175]=80; green[175]=80; blue[175]=80;
red[176]=79; green[176]=79; blue[176]=79;
red[177]=78; green[177]=78; blue[177]=78;
red[178]=77; green[178]=77; blue[178]=77;
red[179]=76; green[179]=76; blue[179]=76;
red[180]=75; green[180]=75; blue[180]=75;
red[181]=74; green[181]=74; blue[181]=74;
red[182]=73; green[182]=73; blue[182]=73;
red[183]=72; green[183]=72; blue[183]=72;
red[184]=71; green[184]=71; blue[184]=71;
red[185]=70; green[185]=70; blue[185]=70;
red[186]=69; green[186]=69; blue[186]=69;
red[187]=68; green[187]=68; blue[187]=68;
red[188]=67; green[188]=67; blue[188]=67;
red[189]=66; green[189]=66; blue[189]=66;
red[190]=65; green[190]=65; blue[190]=65;
red[191]=64; green[191]=64; blue[191]=64;
red[192]=63; green[192]=63; blue[192]=63;
red[193]=62; green[193]=62; blue[193]=62;
red[194]=61; green[194]=61; blue[194]=61;
red[195]=60; green[195]=60; blue[195]=60;
red[196]=59; green[196]=59; blue[196]=59;
red[197]=58; green[197]=58; blue[197]=58;
red[198]=57; green[198]=57; blue[198]=57;
red[199]=56; green[199]=56; blue[199]=56;
red[200]=55; green[200]=55; blue[200]=55;
red[201]=54; green[201]=54; blue[201]=54;
red[202]=53; green[202]=53; blue[202]=53;
red[203]=52; green[203]=52; blue[203]=52;
red[204]=51; green[204]=51; blue[204]=51;
red[205]=50; green[205]=50; blue[205]=50;
red[206]=49; green[206]=49; blue[206]=49;
red[207]=48; green[207]=48; blue[207]=48;
red[208]=47; green[208]=47; blue[208]=47;
red[209]=46; green[209]=46; blue[209]=46;
red[210]=45; green[210]=45; blue[210]=45;
red[211]=44; green[211]=44; blue[211]=44;
red[212]=43; green[212]=43; blue[212]=43;
red[213]=42; green[213]=42; blue[213]=42;
red[214]=41; green[214]=41; blue[214]=41;
red[215]=40; green[215]=40; blue[215]=40;
red[216]=39; green[216]=39; blue[216]=39;
red[217]=38; green[217]=38; blue[217]=38;
red[218]=37; green[218]=37; blue[218]=37;
red[219]=36; green[219]=36; blue[219]=36;
red[220]=35; green[220]=35; blue[220]=35;
red[221]=34; green[221]=34; blue[221]=34;
red[222]=33; green[222]=33; blue[222]=33;
red[223]=32; green[223]=32; blue[223]=32;
red[224]=31; green[224]=31; blue[224]=31;
red[225]=30; green[225]=30; blue[225]=30;
red[226]=29; green[226]=29; blue[226]=29;
red[227]=28; green[227]=28; blue[227]=28;
red[228]=27; green[228]=27; blue[228]=27;
red[229]=26; green[229]=26; blue[229]=26;
red[230]=25; green[230]=25; blue[230]=25;
red[231]=24; green[231]=24; blue[231]=24;
red[232]=23; green[232]=23; blue[232]=23;
red[233]=22; green[233]=22; blue[233]=22;
red[234]=21; green[234]=21; blue[234]=21;
red[235]=20; green[235]=20; blue[235]=20;
red[236]=19; green[236]=19; blue[236]=19;
red[237]=18; green[237]=18; blue[237]=18;
red[238]=17; green[238]=17; blue[238]=17;
red[239]=16; green[239]=16; blue[239]=16;
red[240]=15; green[240]=15; blue[240]=15;
red[241]=14; green[241]=14; blue[241]=14;
red[242]=13; green[242]=13; blue[242]=13;
red[243]=12; green[243]=12; blue[243]=12;
red[244]=11; green[244]=11; blue[244]=11;
red[245]=10; green[245]=10; blue[245]=10;
red[246]=9; green[246]=9; blue[246]=9;
red[247]=8; green[247]=8; blue[247]=8;
red[248]=7; green[248]=7; blue[248]=7;
red[249]=6; green[249]=6; blue[249]=6;
red[250]=5; green[250]=5; blue[250]=5;
red[251]=4; green[251]=4; blue[251]=4;
red[252]=3; green[252]=3; blue[252]=3;
red[253]=2; green[253]=2; blue[253]=2;
red[254]=1; green[254]=1; blue[254]=1;
red[255]=0; green[255]=0; blue[255]=0;
}
if (strcmp(ColorMap, "jet") == 0) {
/*******************************************************************/
/*Definition of the Jet(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=0; green[1]=0; blue[1]=132;
red[2]=0; green[2]=0; blue[2]=136;
red[3]=0; green[3]=0; blue[3]=140;
red[4]=0; green[4]=0; blue[4]=144;
red[5]=0; green[5]=0; blue[5]=148;
red[6]=0; green[6]=0; blue[6]=152;
red[7]=0; green[7]=0; blue[7]=156;
red[8]=0; green[8]=0; blue[8]=160;
red[9]=0; green[9]=0; blue[9]=164;
red[10]=0; green[10]=0; blue[10]=168;
red[11]=0; green[11]=0; blue[11]=172;
red[12]=0; green[12]=0; blue[12]=176;
red[13]=0; green[13]=0; blue[13]=180;
red[14]=0; green[14]=0; blue[14]=184;
red[15]=0; green[15]=0; blue[15]=188;
red[16]=0; green[16]=0; blue[16]=192;
red[17]=0; green[17]=0; blue[17]=196;
red[18]=0; green[18]=0; blue[18]=200;
red[19]=0; green[19]=0; blue[19]=204;
red[20]=0; green[20]=0; blue[20]=208;
red[21]=0; green[21]=0; blue[21]=212;
red[22]=0; green[22]=0; blue[22]=216;
red[23]=0; green[23]=0; blue[23]=220;
red[24]=0; green[24]=0; blue[24]=224;
red[25]=0; green[25]=0; blue[25]=228;
red[26]=0; green[26]=0; blue[26]=232;
red[27]=0; green[27]=0; blue[27]=236;
red[28]=0; green[28]=0; blue[28]=240;
red[29]=0; green[29]=0; blue[29]=244;
red[30]=0; green[30]=0; blue[30]=248;
red[31]=0; green[31]=0; blue[31]=252;
red[32]=0; green[32]=0; blue[32]=255;
red[33]=0; green[33]=4; blue[33]=255;
red[34]=0; green[34]=8; blue[34]=255;
red[35]=0; green[35]=12; blue[35]=255;
red[36]=0; green[36]=16; blue[36]=255;
red[37]=0; green[37]=20; blue[37]=255;
red[38]=0; green[38]=24; blue[38]=255;
red[39]=0; green[39]=28; blue[39]=255;
red[40]=0; green[40]=32; blue[40]=255;
red[41]=0; green[41]=36; blue[41]=255;
red[42]=0; green[42]=40; blue[42]=255;
red[43]=0; green[43]=44; blue[43]=255;
red[44]=0; green[44]=48; blue[44]=255;
red[45]=0; green[45]=52; blue[45]=255;
red[46]=0; green[46]=56; blue[46]=255;
red[47]=0; green[47]=60; blue[47]=255;
red[48]=0; green[48]=64; blue[48]=255;
red[49]=0; green[49]=68; blue[49]=255;
red[50]=0; green[50]=72; blue[50]=255;
red[51]=0; green[51]=76; blue[51]=255;
red[52]=0; green[52]=80; blue[52]=255;
red[53]=0; green[53]=84; blue[53]=255;
red[54]=0; green[54]=88; blue[54]=255;
red[55]=0; green[55]=92; blue[55]=255;
red[56]=0; green[56]=96; blue[56]=255;
red[57]=0; green[57]=100; blue[57]=255;
red[58]=0; green[58]=104; blue[58]=255;
red[59]=0; green[59]=108; blue[59]=255;
red[60]=0; green[60]=112; blue[60]=255;
red[61]=0; green[61]=116; blue[61]=255;
red[62]=0; green[62]=120; blue[62]=255;
red[63]=0; green[63]=124; blue[63]=255;
red[64]=0; green[64]=128; blue[64]=255;
red[65]=0; green[65]=132; blue[65]=255;
red[66]=0; green[66]=136; blue[66]=255;
red[67]=0; green[67]=140; blue[67]=255;
red[68]=0; green[68]=144; blue[68]=255;
red[69]=0; green[69]=148; blue[69]=255;
red[70]=0; green[70]=152; blue[70]=255;
red[71]=0; green[71]=156; blue[71]=255;
red[72]=0; green[72]=160; blue[72]=255;
red[73]=0; green[73]=164; blue[73]=255;
red[74]=0; green[74]=168; blue[74]=255;
red[75]=0; green[75]=172; blue[75]=255;
red[76]=0; green[76]=176; blue[76]=255;
red[77]=0; green[77]=180; blue[77]=255;
red[78]=0; green[78]=184; blue[78]=255;
red[79]=0; green[79]=188; blue[79]=255;
red[80]=0; green[80]=192; blue[80]=255;
red[81]=0; green[81]=196; blue[81]=255;
red[82]=0; green[82]=200; blue[82]=255;
red[83]=0; green[83]=204; blue[83]=255;
red[84]=0; green[84]=208; blue[84]=255;
red[85]=0; green[85]=212; blue[85]=255;
red[86]=0; green[86]=216; blue[86]=255;
red[87]=0; green[87]=220; blue[87]=255;
red[88]=0; green[88]=224; blue[88]=255;
red[89]=0; green[89]=228; blue[89]=255;
red[90]=0; green[90]=232; blue[90]=255;
red[91]=0; green[91]=236; blue[91]=255;
red[92]=0; green[92]=240; blue[92]=255;
red[93]=0; green[93]=244; blue[93]=255;
red[94]=0; green[94]=248; blue[94]=255;
red[95]=0; green[95]=252; blue[95]=255;
red[96]=0; green[96]=255; blue[96]=252;
red[97]=4; green[97]=255; blue[97]=248;
red[98]=8; green[98]=255; blue[98]=244;
red[99]=12; green[99]=255; blue[99]=240;
red[100]=16; green[100]=255; blue[100]=236;
red[101]=20; green[101]=255; blue[101]=232;
red[102]=24; green[102]=255; blue[102]=228;
red[103]=28; green[103]=255; blue[103]=224;
red[104]=32; green[104]=255; blue[104]=220;
red[105]=36; green[105]=255; blue[105]=216;
red[106]=40; green[106]=255; blue[106]=212;
red[107]=44; green[107]=255; blue[107]=208;
red[108]=48; green[108]=255; blue[108]=204;
red[109]=52; green[109]=255; blue[109]=200;
red[110]=56; green[110]=255; blue[110]=196;
red[111]=60; green[111]=255; blue[111]=192;
red[112]=64; green[112]=255; blue[112]=188;
red[113]=68; green[113]=255; blue[113]=184;
red[114]=72; green[114]=255; blue[114]=180;
red[115]=76; green[115]=255; blue[115]=176;
red[116]=80; green[116]=255; blue[116]=172;
red[117]=84; green[117]=255; blue[117]=168;
red[118]=88; green[118]=255; blue[118]=164;
red[119]=92; green[119]=255; blue[119]=160;
red[120]=96; green[120]=255; blue[120]=156;
red[121]=100; green[121]=255; blue[121]=152;
red[122]=104; green[122]=255; blue[122]=148;
red[123]=108; green[123]=255; blue[123]=144;
red[124]=112; green[124]=255; blue[124]=140;
red[125]=116; green[125]=255; blue[125]=136;
red[126]=120; green[126]=255; blue[126]=132;
red[127]=124; green[127]=255; blue[127]=128;
red[128]=128; green[128]=255; blue[128]=124;
red[129]=132; green[129]=255; blue[129]=120;
red[130]=136; green[130]=255; blue[130]=116;
red[131]=140; green[131]=255; blue[131]=112;
red[132]=144; green[132]=255; blue[132]=108;
red[133]=148; green[133]=255; blue[133]=104;
red[134]=152; green[134]=255; blue[134]=100;
red[135]=156; green[135]=255; blue[135]=96;
red[136]=160; green[136]=255; blue[136]=92;
red[137]=164; green[137]=255; blue[137]=88;
red[138]=168; green[138]=255; blue[138]=84;
red[139]=172; green[139]=255; blue[139]=80;
red[140]=176; green[140]=255; blue[140]=76;
red[141]=180; green[141]=255; blue[141]=72;
red[142]=184; green[142]=255; blue[142]=68;
red[143]=188; green[143]=255; blue[143]=64;
red[144]=192; green[144]=255; blue[144]=60;
red[145]=196; green[145]=255; blue[145]=56;
red[146]=200; green[146]=255; blue[146]=52;
red[147]=204; green[147]=255; blue[147]=48;
red[148]=208; green[148]=255; blue[148]=44;
red[149]=212; green[149]=255; blue[149]=40;
red[150]=216; green[150]=255; blue[150]=36;
red[151]=220; green[151]=255; blue[151]=32;
red[152]=224; green[152]=255; blue[152]=28;
red[153]=228; green[153]=255; blue[153]=24;
red[154]=232; green[154]=255; blue[154]=20;
red[155]=236; green[155]=255; blue[155]=16;
red[156]=240; green[156]=255; blue[156]=12;
red[157]=244; green[157]=255; blue[157]=8;
red[158]=248; green[158]=255; blue[158]=4;
red[159]=252; green[159]=255; blue[159]=0;
red[160]=255; green[160]=252; blue[160]=0;
red[161]=255; green[161]=248; blue[161]=0;
red[162]=255; green[162]=244; blue[162]=0;
red[163]=255; green[163]=240; blue[163]=0;
red[164]=255; green[164]=236; blue[164]=0;
red[165]=255; green[165]=232; blue[165]=0;
red[166]=255; green[166]=228; blue[166]=0;
red[167]=255; green[167]=224; blue[167]=0;
red[168]=255; green[168]=220; blue[168]=0;
red[169]=255; green[169]=216; blue[169]=0;
red[170]=255; green[170]=212; blue[170]=0;
red[171]=255; green[171]=208; blue[171]=0;
red[172]=255; green[172]=204; blue[172]=0;
red[173]=255; green[173]=200; blue[173]=0;
red[174]=255; green[174]=196; blue[174]=0;
red[175]=255; green[175]=192; blue[175]=0;
red[176]=255; green[176]=188; blue[176]=0;
red[177]=255; green[177]=184; blue[177]=0;
red[178]=255; green[178]=180; blue[178]=0;
red[179]=255; green[179]=176; blue[179]=0;
red[180]=255; green[180]=172; blue[180]=0;
red[181]=255; green[181]=168; blue[181]=0;
red[182]=255; green[182]=164; blue[182]=0;
red[183]=255; green[183]=160; blue[183]=0;
red[184]=255; green[184]=156; blue[184]=0;
red[185]=255; green[185]=152; blue[185]=0;
red[186]=255; green[186]=148; blue[186]=0;
red[187]=255; green[187]=144; blue[187]=0;
red[188]=255; green[188]=140; blue[188]=0;
red[189]=255; green[189]=136; blue[189]=0;
red[190]=255; green[190]=132; blue[190]=0;
red[191]=255; green[191]=128; blue[191]=0;
red[192]=255; green[192]=124; blue[192]=0;
red[193]=255; green[193]=120; blue[193]=0;
red[194]=255; green[194]=116; blue[194]=0;
red[195]=255; green[195]=112; blue[195]=0;
red[196]=255; green[196]=108; blue[196]=0;
red[197]=255; green[197]=104; blue[197]=0;
red[198]=255; green[198]=100; blue[198]=0;
red[199]=255; green[199]=96; blue[199]=0;
red[200]=255; green[200]=92; blue[200]=0;
red[201]=255; green[201]=88; blue[201]=0;
red[202]=255; green[202]=84; blue[202]=0;
red[203]=255; green[203]=80; blue[203]=0;
red[204]=255; green[204]=76; blue[204]=0;
red[205]=255; green[205]=72; blue[205]=0;
red[206]=255; green[206]=68; blue[206]=0;
red[207]=255; green[207]=64; blue[207]=0;
red[208]=255; green[208]=60; blue[208]=0;
red[209]=255; green[209]=56; blue[209]=0;
red[210]=255; green[210]=52; blue[210]=0;
red[211]=255; green[211]=48; blue[211]=0;
red[212]=255; green[212]=44; blue[212]=0;
red[213]=255; green[213]=40; blue[213]=0;
red[214]=255; green[214]=36; blue[214]=0;
red[215]=255; green[215]=32; blue[215]=0;
red[216]=255; green[216]=28; blue[216]=0;
red[217]=255; green[217]=24; blue[217]=0;
red[218]=255; green[218]=20; blue[218]=0;
red[219]=255; green[219]=16; blue[219]=0;
red[220]=255; green[220]=12; blue[220]=0;
red[221]=255; green[221]=8; blue[221]=0;
red[222]=255; green[222]=4; blue[222]=0;
red[223]=255; green[223]=0; blue[223]=0;
red[224]=252; green[224]=0; blue[224]=0;
red[225]=248; green[225]=0; blue[225]=0;
red[226]=244; green[226]=0; blue[226]=0;
red[227]=240; green[227]=0; blue[227]=0;
red[228]=236; green[228]=0; blue[228]=0;
red[229]=232; green[229]=0; blue[229]=0;
red[230]=228; green[230]=0; blue[230]=0;
red[231]=224; green[231]=0; blue[231]=0;
red[232]=220; green[232]=0; blue[232]=0;
red[233]=216; green[233]=0; blue[233]=0;
red[234]=212; green[234]=0; blue[234]=0;
red[235]=208; green[235]=0; blue[235]=0;
red[236]=204; green[236]=0; blue[236]=0;
red[237]=200; green[237]=0; blue[237]=0;
red[238]=196; green[238]=0; blue[238]=0;
red[239]=192; green[239]=0; blue[239]=0;
red[240]=188; green[240]=0; blue[240]=0;
red[241]=184; green[241]=0; blue[241]=0;
red[242]=180; green[242]=0; blue[242]=0;
red[243]=176; green[243]=0; blue[243]=0;
red[244]=172; green[244]=0; blue[244]=0;
red[245]=168; green[245]=0; blue[245]=0;
red[246]=164; green[246]=0; blue[246]=0;
red[247]=160; green[247]=0; blue[247]=0;
red[248]=156; green[248]=0; blue[248]=0;
red[249]=152; green[249]=0; blue[249]=0;
red[250]=148; green[250]=0; blue[250]=0;
red[251]=144; green[251]=0; blue[251]=0;
red[252]=140; green[252]=0; blue[252]=0;
red[253]=136; green[253]=0; blue[253]=0;
red[254]=132; green[254]=0; blue[254]=0;
red[255]=128; green[255]=0; blue[255]=0;
}
if (strcmp(ColorMap, "jetrev") == 0) {
/*******************************************************************/
/*Definition of the JetRev(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=132; green[1]=0; blue[1]=0;
red[2]=136; green[2]=0; blue[2]=0;
red[3]=140; green[3]=0; blue[3]=0;
red[4]=144; green[4]=0; blue[4]=0;
red[5]=148; green[5]=0; blue[5]=0;
red[6]=152; green[6]=0; blue[6]=0;
red[7]=156; green[7]=0; blue[7]=0;
red[8]=160; green[8]=0; blue[8]=0;
red[9]=164; green[9]=0; blue[9]=0;
red[10]=168; green[10]=0; blue[10]=0;
red[11]=172; green[11]=0; blue[11]=0;
red[12]=176; green[12]=0; blue[12]=0;
red[13]=180; green[13]=0; blue[13]=0;
red[14]=184; green[14]=0; blue[14]=0;
red[15]=188; green[15]=0; blue[15]=0;
red[16]=192; green[16]=0; blue[16]=0;
red[17]=196; green[17]=0; blue[17]=0;
red[18]=200; green[18]=0; blue[18]=0;
red[19]=204; green[19]=0; blue[19]=0;
red[20]=208; green[20]=0; blue[20]=0;
red[21]=212; green[21]=0; blue[21]=0;
red[22]=216; green[22]=0; blue[22]=0;
red[23]=220; green[23]=0; blue[23]=0;
red[24]=224; green[24]=0; blue[24]=0;
red[25]=228; green[25]=0; blue[25]=0;
red[26]=232; green[26]=0; blue[26]=0;
red[27]=236; green[27]=0; blue[27]=0;
red[28]=240; green[28]=0; blue[28]=0;
red[29]=244; green[29]=0; blue[29]=0;
red[30]=248; green[30]=0; blue[30]=0;
red[31]=252; green[31]=0; blue[31]=0;
red[32]=255; green[32]=0; blue[32]=0;
red[33]=255; green[33]=4; blue[33]=0;
red[34]=255; green[34]=8; blue[34]=0;
red[35]=255; green[35]=12; blue[35]=0;
red[36]=255; green[36]=16; blue[36]=0;
red[37]=255; green[37]=20; blue[37]=0;
red[38]=255; green[38]=24; blue[38]=0;
red[39]=255; green[39]=28; blue[39]=0;
red[40]=255; green[40]=32; blue[40]=0;
red[41]=255; green[41]=36; blue[41]=0;
red[42]=255; green[42]=40; blue[42]=0;
red[43]=255; green[43]=44; blue[43]=0;
red[44]=255; green[44]=48; blue[44]=0;
red[45]=255; green[45]=52; blue[45]=0;
red[46]=255; green[46]=56; blue[46]=0;
red[47]=255; green[47]=60; blue[47]=0;
red[48]=255; green[48]=64; blue[48]=0;
red[49]=255; green[49]=68; blue[49]=0;
red[50]=255; green[50]=72; blue[50]=0;
red[51]=255; green[51]=76; blue[51]=0;
red[52]=255; green[52]=80; blue[52]=0;
red[53]=255; green[53]=84; blue[53]=0;
red[54]=255; green[54]=88; blue[54]=0;
red[55]=255; green[55]=92; blue[55]=0;
red[56]=255; green[56]=96; blue[56]=0;
red[57]=255; green[57]=100; blue[57]=0;
red[58]=255; green[58]=104; blue[58]=0;
red[59]=255; green[59]=108; blue[59]=0;
red[60]=255; green[60]=112; blue[60]=0;
red[61]=255; green[61]=116; blue[61]=0;
red[62]=255; green[62]=120; blue[62]=0;
red[63]=255; green[63]=124; blue[63]=0;
red[64]=255; green[64]=128; blue[64]=0;
red[65]=255; green[65]=132; blue[65]=0;
red[66]=255; green[66]=136; blue[66]=0;
red[67]=255; green[67]=140; blue[67]=0;
red[68]=255; green[68]=144; blue[68]=0;
red[69]=255; green[69]=148; blue[69]=0;
red[70]=255; green[70]=152; blue[70]=0;
red[71]=255; green[71]=156; blue[71]=0;
red[72]=255; green[72]=160; blue[72]=0;
red[73]=255; green[73]=164; blue[73]=0;
red[74]=255; green[74]=168; blue[74]=0;
red[75]=255; green[75]=172; blue[75]=0;
red[76]=255; green[76]=176; blue[76]=0;
red[77]=255; green[77]=180; blue[77]=0;
red[78]=255; green[78]=184; blue[78]=0;
red[79]=255; green[79]=188; blue[79]=0;
red[80]=255; green[80]=192; blue[80]=0;
red[81]=255; green[81]=196; blue[81]=0;
red[82]=255; green[82]=200; blue[82]=0;
red[83]=255; green[83]=204; blue[83]=0;
red[84]=255; green[84]=208; blue[84]=0;
red[85]=255; green[85]=212; blue[85]=0;
red[86]=255; green[86]=216; blue[86]=0;
red[87]=255; green[87]=220; blue[87]=0;
red[88]=255; green[88]=224; blue[88]=0;
red[89]=255; green[89]=228; blue[89]=0;
red[90]=255; green[90]=232; blue[90]=0;
red[91]=255; green[91]=236; blue[91]=0;
red[92]=255; green[92]=240; blue[92]=0;
red[93]=255; green[93]=244; blue[93]=0;
red[94]=255; green[94]=248; blue[94]=0;
red[95]=255; green[95]=252; blue[95]=0;
red[96]=252; green[96]=255; blue[96]=0;
red[97]=248; green[97]=255; blue[97]=4;
red[98]=244; green[98]=255; blue[98]=8;
red[99]=240; green[99]=255; blue[99]=12;
red[100]=236; green[100]=255; blue[100]=16;
red[101]=232; green[101]=255; blue[101]=20;
red[102]=228; green[102]=255; blue[102]=24;
red[103]=224; green[103]=255; blue[103]=28;
red[104]=220; green[104]=255; blue[104]=32;
red[105]=216; green[105]=255; blue[105]=36;
red[106]=212; green[106]=255; blue[106]=40;
red[107]=208; green[107]=255; blue[107]=44;
red[108]=204; green[108]=255; blue[108]=48;
red[109]=200; green[109]=255; blue[109]=52;
red[110]=196; green[110]=255; blue[110]=56;
red[111]=192; green[111]=255; blue[111]=60;
red[112]=188; green[112]=255; blue[112]=64;
red[113]=184; green[113]=255; blue[113]=68;
red[114]=180; green[114]=255; blue[114]=72;
red[115]=176; green[115]=255; blue[115]=76;
red[116]=172; green[116]=255; blue[116]=80;
red[117]=168; green[117]=255; blue[117]=84;
red[118]=164; green[118]=255; blue[118]=88;
red[119]=160; green[119]=255; blue[119]=92;
red[120]=156; green[120]=255; blue[120]=96;
red[121]=152; green[121]=255; blue[121]=100;
red[122]=148; green[122]=255; blue[122]=104;
red[123]=144; green[123]=255; blue[123]=108;
red[124]=140; green[124]=255; blue[124]=112;
red[125]=136; green[125]=255; blue[125]=116;
red[126]=132; green[126]=255; blue[126]=120;
red[127]=128; green[127]=255; blue[127]=124;
red[128]=124; green[128]=255; blue[128]=128;
red[129]=120; green[129]=255; blue[129]=132;
red[130]=116; green[130]=255; blue[130]=136;
red[131]=112; green[131]=255; blue[131]=140;
red[132]=108; green[132]=255; blue[132]=144;
red[133]=104; green[133]=255; blue[133]=148;
red[134]=100; green[134]=255; blue[134]=152;
red[135]=96; green[135]=255; blue[135]=156;
red[136]=92; green[136]=255; blue[136]=160;
red[137]=88; green[137]=255; blue[137]=164;
red[138]=84; green[138]=255; blue[138]=168;
red[139]=80; green[139]=255; blue[139]=172;
red[140]=76; green[140]=255; blue[140]=176;
red[141]=72; green[141]=255; blue[141]=180;
red[142]=68; green[142]=255; blue[142]=184;
red[143]=64; green[143]=255; blue[143]=188;
red[144]=60; green[144]=255; blue[144]=192;
red[145]=56; green[145]=255; blue[145]=196;
red[146]=52; green[146]=255; blue[146]=200;
red[147]=48; green[147]=255; blue[147]=204;
red[148]=44; green[148]=255; blue[148]=208;
red[149]=40; green[149]=255; blue[149]=212;
red[150]=36; green[150]=255; blue[150]=216;
red[151]=32; green[151]=255; blue[151]=220;
red[152]=28; green[152]=255; blue[152]=224;
red[153]=24; green[153]=255; blue[153]=228;
red[154]=20; green[154]=255; blue[154]=232;
red[155]=16; green[155]=255; blue[155]=236;
red[156]=12; green[156]=255; blue[156]=240;
red[157]=8; green[157]=255; blue[157]=244;
red[158]=4; green[158]=255; blue[158]=248;
red[159]=0; green[159]=255; blue[159]=252;
red[160]=0; green[160]=252; blue[160]=255;
red[161]=0; green[161]=248; blue[161]=255;
red[162]=0; green[162]=244; blue[162]=255;
red[163]=0; green[163]=240; blue[163]=255;
red[164]=0; green[164]=236; blue[164]=255;
red[165]=0; green[165]=232; blue[165]=255;
red[166]=0; green[166]=228; blue[166]=255;
red[167]=0; green[167]=224; blue[167]=255;
red[168]=0; green[168]=220; blue[168]=255;
red[169]=0; green[169]=216; blue[169]=255;
red[170]=0; green[170]=212; blue[170]=255;
red[171]=0; green[171]=208; blue[171]=255;
red[172]=0; green[172]=204; blue[172]=255;
red[173]=0; green[173]=200; blue[173]=255;
red[174]=0; green[174]=196; blue[174]=255;
red[175]=0; green[175]=192; blue[175]=255;
red[176]=0; green[176]=188; blue[176]=255;
red[177]=0; green[177]=184; blue[177]=255;
red[178]=0; green[178]=180; blue[178]=255;
red[179]=0; green[179]=176; blue[179]=255;
red[180]=0; green[180]=172; blue[180]=255;
red[181]=0; green[181]=168; blue[181]=255;
red[182]=0; green[182]=164; blue[182]=255;
red[183]=0; green[183]=160; blue[183]=255;
red[184]=0; green[184]=156; blue[184]=255;
red[185]=0; green[185]=152; blue[185]=255;
red[186]=0; green[186]=148; blue[186]=255;
red[187]=0; green[187]=144; blue[187]=255;
red[188]=0; green[188]=140; blue[188]=255;
red[189]=0; green[189]=136; blue[189]=255;
red[190]=0; green[190]=132; blue[190]=255;
red[191]=0; green[191]=128; blue[191]=255;
red[192]=0; green[192]=124; blue[192]=255;
red[193]=0; green[193]=120; blue[193]=255;
red[194]=0; green[194]=116; blue[194]=255;
red[195]=0; green[195]=112; blue[195]=255;
red[196]=0; green[196]=108; blue[196]=255;
red[197]=0; green[197]=104; blue[197]=255;
red[198]=0; green[198]=100; blue[198]=255;
red[199]=0; green[199]=96; blue[199]=255;
red[200]=0; green[200]=92; blue[200]=255;
red[201]=0; green[201]=88; blue[201]=255;
red[202]=0; green[202]=84; blue[202]=255;
red[203]=0; green[203]=80; blue[203]=255;
red[204]=0; green[204]=76; blue[204]=255;
red[205]=0; green[205]=72; blue[205]=255;
red[206]=0; green[206]=68; blue[206]=255;
red[207]=0; green[207]=64; blue[207]=255;
red[208]=0; green[208]=60; blue[208]=255;
red[209]=0; green[209]=56; blue[209]=255;
red[210]=0; green[210]=52; blue[210]=255;
red[211]=0; green[211]=48; blue[211]=255;
red[212]=0; green[212]=44; blue[212]=255;
red[213]=0; green[213]=40; blue[213]=255;
red[214]=0; green[214]=36; blue[214]=255;
red[215]=0; green[215]=32; blue[215]=255;
red[216]=0; green[216]=28; blue[216]=255;
red[217]=0; green[217]=24; blue[217]=255;
red[218]=0; green[218]=20; blue[218]=255;
red[219]=0; green[219]=16; blue[219]=255;
red[220]=0; green[220]=12; blue[220]=255;
red[221]=0; green[221]=8; blue[221]=255;
red[222]=0; green[222]=4; blue[222]=255;
red[223]=0; green[223]=0; blue[223]=255;
red[224]=0; green[224]=0; blue[224]=252;
red[225]=0; green[225]=0; blue[225]=248;
red[226]=0; green[226]=0; blue[226]=244;
red[227]=0; green[227]=0; blue[227]=240;
red[228]=0; green[228]=0; blue[228]=236;
red[229]=0; green[229]=0; blue[229]=232;
red[230]=0; green[230]=0; blue[230]=228;
red[231]=0; green[231]=0; blue[231]=224;
red[232]=0; green[232]=0; blue[232]=220;
red[233]=0; green[233]=0; blue[233]=216;
red[234]=0; green[234]=0; blue[234]=212;
red[235]=0; green[235]=0; blue[235]=208;
red[236]=0; green[236]=0; blue[236]=204;
red[237]=0; green[237]=0; blue[237]=200;
red[238]=0; green[238]=0; blue[238]=196;
red[239]=0; green[239]=0; blue[239]=192;
red[240]=0; green[240]=0; blue[240]=188;
red[241]=0; green[241]=0; blue[241]=184;
red[242]=0; green[242]=0; blue[242]=180;
red[243]=0; green[243]=0; blue[243]=176;
red[244]=0; green[244]=0; blue[244]=172;
red[245]=0; green[245]=0; blue[245]=168;
red[246]=0; green[246]=0; blue[246]=164;
red[247]=0; green[247]=0; blue[247]=160;
red[248]=0; green[248]=0; blue[248]=156;
red[249]=0; green[249]=0; blue[249]=152;
red[250]=0; green[250]=0; blue[250]=148;
red[251]=0; green[251]=0; blue[251]=144;
red[252]=0; green[252]=0; blue[252]=140;
red[253]=0; green[253]=0; blue[253]=136;
red[254]=0; green[254]=0; blue[254]=132;
red[255]=0; green[255]=0; blue[255]=128;
}
if (strcmp(ColorMap, "jetinv") == 0) {
/*******************************************************************/
/*Definition of the JetInv(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=255; green[1]=255; blue[1]=123;
red[2]=255; green[2]=255; blue[2]=119;
red[3]=255; green[3]=255; blue[3]=115;
red[4]=255; green[4]=255; blue[4]=111;
red[5]=255; green[5]=255; blue[5]=107;
red[6]=255; green[6]=255; blue[6]=103;
red[7]=255; green[7]=255; blue[7]=99;
red[8]=255; green[8]=255; blue[8]=95;
red[9]=255; green[9]=255; blue[9]=91;
red[10]=255; green[10]=255; blue[10]=87;
red[11]=255; green[11]=255; blue[11]=83;
red[12]=255; green[12]=255; blue[12]=79;
red[13]=255; green[13]=255; blue[13]=75;
red[14]=255; green[14]=255; blue[14]=71;
red[15]=255; green[15]=255; blue[15]=67;
red[16]=255; green[16]=255; blue[16]=63;
red[17]=255; green[17]=255; blue[17]=59;
red[18]=255; green[18]=255; blue[18]=55;
red[19]=255; green[19]=255; blue[19]=51;
red[20]=255; green[20]=255; blue[20]=47;
red[21]=255; green[21]=255; blue[21]=43;
red[22]=255; green[22]=255; blue[22]=39;
red[23]=255; green[23]=255; blue[23]=35;
red[24]=255; green[24]=255; blue[24]=31;
red[25]=255; green[25]=255; blue[25]=27;
red[26]=255; green[26]=255; blue[26]=23;
red[27]=255; green[27]=255; blue[27]=19;
red[28]=255; green[28]=255; blue[28]=15;
red[29]=255; green[29]=255; blue[29]=11;
red[30]=255; green[30]=255; blue[30]=7;
red[31]=255; green[31]=255; blue[31]=3;
red[32]=255; green[32]=255; blue[32]=0;
red[33]=255; green[33]=251; blue[33]=0;
red[34]=255; green[34]=247; blue[34]=0;
red[35]=255; green[35]=243; blue[35]=0;
red[36]=255; green[36]=239; blue[36]=0;
red[37]=255; green[37]=235; blue[37]=0;
red[38]=255; green[38]=231; blue[38]=0;
red[39]=255; green[39]=227; blue[39]=0;
red[40]=255; green[40]=223; blue[40]=0;
red[41]=255; green[41]=219; blue[41]=0;
red[42]=255; green[42]=215; blue[42]=0;
red[43]=255; green[43]=211; blue[43]=0;
red[44]=255; green[44]=207; blue[44]=0;
red[45]=255; green[45]=203; blue[45]=0;
red[46]=255; green[46]=199; blue[46]=0;
red[47]=255; green[47]=195; blue[47]=0;
red[48]=255; green[48]=191; blue[48]=0;
red[49]=255; green[49]=187; blue[49]=0;
red[50]=255; green[50]=183; blue[50]=0;
red[51]=255; green[51]=179; blue[51]=0;
red[52]=255; green[52]=175; blue[52]=0;
red[53]=255; green[53]=171; blue[53]=0;
red[54]=255; green[54]=167; blue[54]=0;
red[55]=255; green[55]=163; blue[55]=0;
red[56]=255; green[56]=159; blue[56]=0;
red[57]=255; green[57]=155; blue[57]=0;
red[58]=255; green[58]=151; blue[58]=0;
red[59]=255; green[59]=147; blue[59]=0;
red[60]=255; green[60]=143; blue[60]=0;
red[61]=255; green[61]=139; blue[61]=0;
red[62]=255; green[62]=135; blue[62]=0;
red[63]=255; green[63]=131; blue[63]=0;
red[64]=255; green[64]=127; blue[64]=0;
red[65]=255; green[65]=123; blue[65]=0;
red[66]=255; green[66]=119; blue[66]=0;
red[67]=255; green[67]=115; blue[67]=0;
red[68]=255; green[68]=111; blue[68]=0;
red[69]=255; green[69]=107; blue[69]=0;
red[70]=255; green[70]=103; blue[70]=0;
red[71]=255; green[71]=99; blue[71]=0;
red[72]=255; green[72]=95; blue[72]=0;
red[73]=255; green[73]=91; blue[73]=0;
red[74]=255; green[74]=87; blue[74]=0;
red[75]=255; green[75]=83; blue[75]=0;
red[76]=255; green[76]=79; blue[76]=0;
red[77]=255; green[77]=75; blue[77]=0;
red[78]=255; green[78]=71; blue[78]=0;
red[79]=255; green[79]=67; blue[79]=0;
red[80]=255; green[80]=63; blue[80]=0;
red[81]=255; green[81]=59; blue[81]=0;
red[82]=255; green[82]=55; blue[82]=0;
red[83]=255; green[83]=51; blue[83]=0;
red[84]=255; green[84]=47; blue[84]=0;
red[85]=255; green[85]=43; blue[85]=0;
red[86]=255; green[86]=39; blue[86]=0;
red[87]=255; green[87]=35; blue[87]=0;
red[88]=255; green[88]=31; blue[88]=0;
red[89]=255; green[89]=27; blue[89]=0;
red[90]=255; green[90]=23; blue[90]=0;
red[91]=255; green[91]=19; blue[91]=0;
red[92]=255; green[92]=15; blue[92]=0;
red[93]=255; green[93]=11; blue[93]=0;
red[94]=255; green[94]=7; blue[94]=0;
red[95]=255; green[95]=3; blue[95]=0;
red[96]=255; green[96]=0; blue[96]=3;
red[97]=251; green[97]=0; blue[97]=7;
red[98]=247; green[98]=0; blue[98]=11;
red[99]=243; green[99]=0; blue[99]=15;
red[100]=239; green[100]=0; blue[100]=19;
red[101]=235; green[101]=0; blue[101]=23;
red[102]=231; green[102]=0; blue[102]=27;
red[103]=227; green[103]=0; blue[103]=31;
red[104]=223; green[104]=0; blue[104]=35;
red[105]=219; green[105]=0; blue[105]=39;
red[106]=215; green[106]=0; blue[106]=43;
red[107]=211; green[107]=0; blue[107]=47;
red[108]=207; green[108]=0; blue[108]=51;
red[109]=203; green[109]=0; blue[109]=55;
red[110]=199; green[110]=0; blue[110]=59;
red[111]=195; green[111]=0; blue[111]=63;
red[112]=191; green[112]=0; blue[112]=67;
red[113]=187; green[113]=0; blue[113]=71;
red[114]=183; green[114]=0; blue[114]=75;
red[115]=179; green[115]=0; blue[115]=79;
red[116]=175; green[116]=0; blue[116]=83;
red[117]=171; green[117]=0; blue[117]=87;
red[118]=167; green[118]=0; blue[118]=91;
red[119]=163; green[119]=0; blue[119]=95;
red[120]=159; green[120]=0; blue[120]=99;
red[121]=155; green[121]=0; blue[121]=103;
red[122]=151; green[122]=0; blue[122]=107;
red[123]=147; green[123]=0; blue[123]=111;
red[124]=143; green[124]=0; blue[124]=115;
red[125]=139; green[125]=0; blue[125]=119;
red[126]=135; green[126]=0; blue[126]=123;
red[127]=131; green[127]=0; blue[127]=127;
red[128]=127; green[128]=0; blue[128]=131;
red[129]=123; green[129]=0; blue[129]=135;
red[130]=119; green[130]=0; blue[130]=139;
red[131]=115; green[131]=0; blue[131]=143;
red[132]=111; green[132]=0; blue[132]=147;
red[133]=107; green[133]=0; blue[133]=151;
red[134]=103; green[134]=0; blue[134]=155;
red[135]=99; green[135]=0; blue[135]=159;
red[136]=95; green[136]=0; blue[136]=163;
red[137]=91; green[137]=0; blue[137]=167;
red[138]=87; green[138]=0; blue[138]=171;
red[139]=83; green[139]=0; blue[139]=175;
red[140]=79; green[140]=0; blue[140]=179;
red[141]=75; green[141]=0; blue[141]=183;
red[142]=71; green[142]=0; blue[142]=187;
red[143]=67; green[143]=0; blue[143]=191;
red[144]=63; green[144]=0; blue[144]=195;
red[145]=59; green[145]=0; blue[145]=199;
red[146]=55; green[146]=0; blue[146]=203;
red[147]=51; green[147]=0; blue[147]=207;
red[148]=47; green[148]=0; blue[148]=211;
red[149]=43; green[149]=0; blue[149]=215;
red[150]=39; green[150]=0; blue[150]=219;
red[151]=35; green[151]=0; blue[151]=223;
red[152]=31; green[152]=0; blue[152]=227;
red[153]=27; green[153]=0; blue[153]=231;
red[154]=23; green[154]=0; blue[154]=235;
red[155]=19; green[155]=0; blue[155]=239;
red[156]=15; green[156]=0; blue[156]=243;
red[157]=11; green[157]=0; blue[157]=247;
red[158]=7; green[158]=0; blue[158]=251;
red[159]=3; green[159]=0; blue[159]=255;
red[160]=0; green[160]=3; blue[160]=255;
red[161]=0; green[161]=7; blue[161]=255;
red[162]=0; green[162]=11; blue[162]=255;
red[163]=0; green[163]=15; blue[163]=255;
red[164]=0; green[164]=19; blue[164]=255;
red[165]=0; green[165]=23; blue[165]=255;
red[166]=0; green[166]=27; blue[166]=255;
red[167]=0; green[167]=31; blue[167]=255;
red[168]=0; green[168]=35; blue[168]=255;
red[169]=0; green[169]=39; blue[169]=255;
red[170]=0; green[170]=43; blue[170]=255;
red[171]=0; green[171]=47; blue[171]=255;
red[172]=0; green[172]=51; blue[172]=255;
red[173]=0; green[173]=55; blue[173]=255;
red[174]=0; green[174]=59; blue[174]=255;
red[175]=0; green[175]=63; blue[175]=255;
red[176]=0; green[176]=67; blue[176]=255;
red[177]=0; green[177]=71; blue[177]=255;
red[178]=0; green[178]=75; blue[178]=255;
red[179]=0; green[179]=79; blue[179]=255;
red[180]=0; green[180]=83; blue[180]=255;
red[181]=0; green[181]=87; blue[181]=255;
red[182]=0; green[182]=91; blue[182]=255;
red[183]=0; green[183]=95; blue[183]=255;
red[184]=0; green[184]=99; blue[184]=255;
red[185]=0; green[185]=103; blue[185]=255;
red[186]=0; green[186]=107; blue[186]=255;
red[187]=0; green[187]=111; blue[187]=255;
red[188]=0; green[188]=115; blue[188]=255;
red[189]=0; green[189]=119; blue[189]=255;
red[190]=0; green[190]=123; blue[190]=255;
red[191]=0; green[191]=127; blue[191]=255;
red[192]=0; green[192]=131; blue[192]=255;
red[193]=0; green[193]=135; blue[193]=255;
red[194]=0; green[194]=139; blue[194]=255;
red[195]=0; green[195]=143; blue[195]=255;
red[196]=0; green[196]=147; blue[196]=255;
red[197]=0; green[197]=151; blue[197]=255;
red[198]=0; green[198]=155; blue[198]=255;
red[199]=0; green[199]=159; blue[199]=255;
red[200]=0; green[200]=163; blue[200]=255;
red[201]=0; green[201]=167; blue[201]=255;
red[202]=0; green[202]=171; blue[202]=255;
red[203]=0; green[203]=175; blue[203]=255;
red[204]=0; green[204]=179; blue[204]=255;
red[205]=0; green[205]=183; blue[205]=255;
red[206]=0; green[206]=187; blue[206]=255;
red[207]=0; green[207]=191; blue[207]=255;
red[208]=0; green[208]=195; blue[208]=255;
red[209]=0; green[209]=199; blue[209]=255;
red[210]=0; green[210]=203; blue[210]=255;
red[211]=0; green[211]=207; blue[211]=255;
red[212]=0; green[212]=211; blue[212]=255;
red[213]=0; green[213]=215; blue[213]=255;
red[214]=0; green[214]=219; blue[214]=255;
red[215]=0; green[215]=223; blue[215]=255;
red[216]=0; green[216]=227; blue[216]=255;
red[217]=0; green[217]=231; blue[217]=255;
red[218]=0; green[218]=235; blue[218]=255;
red[219]=0; green[219]=239; blue[219]=255;
red[220]=0; green[220]=243; blue[220]=255;
red[221]=0; green[221]=247; blue[221]=255;
red[222]=0; green[222]=251; blue[222]=255;
red[223]=0; green[223]=255; blue[223]=255;
red[224]=3; green[224]=255; blue[224]=255;
red[225]=7; green[225]=255; blue[225]=255;
red[226]=11; green[226]=255; blue[226]=255;
red[227]=15; green[227]=255; blue[227]=255;
red[228]=19; green[228]=255; blue[228]=255;
red[229]=23; green[229]=255; blue[229]=255;
red[230]=27; green[230]=255; blue[230]=255;
red[231]=31; green[231]=255; blue[231]=255;
red[232]=35; green[232]=255; blue[232]=255;
red[233]=39; green[233]=255; blue[233]=255;
red[234]=43; green[234]=255; blue[234]=255;
red[235]=47; green[235]=255; blue[235]=255;
red[236]=51; green[236]=255; blue[236]=255;
red[237]=55; green[237]=255; blue[237]=255;
red[238]=59; green[238]=255; blue[238]=255;
red[239]=63; green[239]=255; blue[239]=255;
red[240]=67; green[240]=255; blue[240]=255;
red[241]=71; green[241]=255; blue[241]=255;
red[242]=75; green[242]=255; blue[242]=255;
red[243]=79; green[243]=255; blue[243]=255;
red[244]=83; green[244]=255; blue[244]=255;
red[245]=87; green[245]=255; blue[245]=255;
red[246]=91; green[246]=255; blue[246]=255;
red[247]=95; green[247]=255; blue[247]=255;
red[248]=99; green[248]=255; blue[248]=255;
red[249]=103; green[249]=255; blue[249]=255;
red[250]=107; green[250]=255; blue[250]=255;
red[251]=111; green[251]=255; blue[251]=255;
red[252]=115; green[252]=255; blue[252]=255;
red[253]=119; green[253]=255; blue[253]=255;
red[254]=123; green[254]=255; blue[254]=255;
red[255]=127; green[255]=255; blue[255]=255;
}
if (strcmp(ColorMap, "jetrevinv") == 0) {
/*******************************************************************/
/*Definition of the JetRevInv(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=123; green[1]=255; blue[1]=255;
red[2]=119; green[2]=255; blue[2]=255;
red[3]=115; green[3]=255; blue[3]=255;
red[4]=111; green[4]=255; blue[4]=255;
red[5]=107; green[5]=255; blue[5]=255;
red[6]=103; green[6]=255; blue[6]=255;
red[7]=99; green[7]=255; blue[7]=255;
red[8]=95; green[8]=255; blue[8]=255;
red[9]=91; green[9]=255; blue[9]=255;
red[10]=87; green[10]=255; blue[10]=255;
red[11]=83; green[11]=255; blue[11]=255;
red[12]=79; green[12]=255; blue[12]=255;
red[13]=75; green[13]=255; blue[13]=255;
red[14]=71; green[14]=255; blue[14]=255;
red[15]=67; green[15]=255; blue[15]=255;
red[16]=63; green[16]=255; blue[16]=255;
red[17]=59; green[17]=255; blue[17]=255;
red[18]=55; green[18]=255; blue[18]=255;
red[19]=51; green[19]=255; blue[19]=255;
red[20]=47; green[20]=255; blue[20]=255;
red[21]=43; green[21]=255; blue[21]=255;
red[22]=39; green[22]=255; blue[22]=255;
red[23]=35; green[23]=255; blue[23]=255;
red[24]=31; green[24]=255; blue[24]=255;
red[25]=27; green[25]=255; blue[25]=255;
red[26]=23; green[26]=255; blue[26]=255;
red[27]=19; green[27]=255; blue[27]=255;
red[28]=15; green[28]=255; blue[28]=255;
red[29]=11; green[29]=255; blue[29]=255;
red[30]=7; green[30]=255; blue[30]=255;
red[31]=3; green[31]=255; blue[31]=255;
red[32]=0; green[32]=255; blue[32]=255;
red[33]=0; green[33]=251; blue[33]=255;
red[34]=0; green[34]=247; blue[34]=255;
red[35]=0; green[35]=243; blue[35]=255;
red[36]=0; green[36]=239; blue[36]=255;
red[37]=0; green[37]=235; blue[37]=255;
red[38]=0; green[38]=231; blue[38]=255;
red[39]=0; green[39]=227; blue[39]=255;
red[40]=0; green[40]=223; blue[40]=255;
red[41]=0; green[41]=219; blue[41]=255;
red[42]=0; green[42]=215; blue[42]=255;
red[43]=0; green[43]=211; blue[43]=255;
red[44]=0; green[44]=207; blue[44]=255;
red[45]=0; green[45]=203; blue[45]=255;
red[46]=0; green[46]=199; blue[46]=255;
red[47]=0; green[47]=195; blue[47]=255;
red[48]=0; green[48]=191; blue[48]=255;
red[49]=0; green[49]=187; blue[49]=255;
red[50]=0; green[50]=183; blue[50]=255;
red[51]=0; green[51]=179; blue[51]=255;
red[52]=0; green[52]=175; blue[52]=255;
red[53]=0; green[53]=171; blue[53]=255;
red[54]=0; green[54]=167; blue[54]=255;
red[55]=0; green[55]=163; blue[55]=255;
red[56]=0; green[56]=159; blue[56]=255;
red[57]=0; green[57]=155; blue[57]=255;
red[58]=0; green[58]=151; blue[58]=255;
red[59]=0; green[59]=147; blue[59]=255;
red[60]=0; green[60]=143; blue[60]=255;
red[61]=0; green[61]=139; blue[61]=255;
red[62]=0; green[62]=135; blue[62]=255;
red[63]=0; green[63]=131; blue[63]=255;
red[64]=0; green[64]=127; blue[64]=255;
red[65]=0; green[65]=123; blue[65]=255;
red[66]=0; green[66]=119; blue[66]=255;
red[67]=0; green[67]=115; blue[67]=255;
red[68]=0; green[68]=111; blue[68]=255;
red[69]=0; green[69]=107; blue[69]=255;
red[70]=0; green[70]=103; blue[70]=255;
red[71]=0; green[71]=99; blue[71]=255;
red[72]=0; green[72]=95; blue[72]=255;
red[73]=0; green[73]=91; blue[73]=255;
red[74]=0; green[74]=87; blue[74]=255;
red[75]=0; green[75]=83; blue[75]=255;
red[76]=0; green[76]=79; blue[76]=255;
red[77]=0; green[77]=75; blue[77]=255;
red[78]=0; green[78]=71; blue[78]=255;
red[79]=0; green[79]=67; blue[79]=255;
red[80]=0; green[80]=63; blue[80]=255;
red[81]=0; green[81]=59; blue[81]=255;
red[82]=0; green[82]=55; blue[82]=255;
red[83]=0; green[83]=51; blue[83]=255;
red[84]=0; green[84]=47; blue[84]=255;
red[85]=0; green[85]=43; blue[85]=255;
red[86]=0; green[86]=39; blue[86]=255;
red[87]=0; green[87]=35; blue[87]=255;
red[88]=0; green[88]=31; blue[88]=255;
red[89]=0; green[89]=27; blue[89]=255;
red[90]=0; green[90]=23; blue[90]=255;
red[91]=0; green[91]=19; blue[91]=255;
red[92]=0; green[92]=15; blue[92]=255;
red[93]=0; green[93]=11; blue[93]=255;
red[94]=0; green[94]=7; blue[94]=255;
red[95]=0; green[95]=3; blue[95]=255;
red[96]=3; green[96]=0; blue[96]=255;
red[97]=7; green[97]=0; blue[97]=251;
red[98]=11; green[98]=0; blue[98]=247;
red[99]=15; green[99]=0; blue[99]=243;
red[100]=19; green[100]=0; blue[100]=239;
red[101]=23; green[101]=0; blue[101]=235;
red[102]=27; green[102]=0; blue[102]=231;
red[103]=31; green[103]=0; blue[103]=227;
red[104]=35; green[104]=0; blue[104]=223;
red[105]=39; green[105]=0; blue[105]=219;
red[106]=43; green[106]=0; blue[106]=215;
red[107]=47; green[107]=0; blue[107]=211;
red[108]=51; green[108]=0; blue[108]=207;
red[109]=55; green[109]=0; blue[109]=203;
red[110]=59; green[110]=0; blue[110]=199;
red[111]=63; green[111]=0; blue[111]=195;
red[112]=67; green[112]=0; blue[112]=191;
red[113]=71; green[113]=0; blue[113]=187;
red[114]=75; green[114]=0; blue[114]=183;
red[115]=79; green[115]=0; blue[115]=179;
red[116]=83; green[116]=0; blue[116]=175;
red[117]=87; green[117]=0; blue[117]=171;
red[118]=91; green[118]=0; blue[118]=167;
red[119]=95; green[119]=0; blue[119]=163;
red[120]=99; green[120]=0; blue[120]=159;
red[121]=103; green[121]=0; blue[121]=155;
red[122]=107; green[122]=0; blue[122]=151;
red[123]=111; green[123]=0; blue[123]=147;
red[124]=115; green[124]=0; blue[124]=143;
red[125]=119; green[125]=0; blue[125]=139;
red[126]=123; green[126]=0; blue[126]=135;
red[127]=127; green[127]=0; blue[127]=131;
red[128]=131; green[128]=0; blue[128]=127;
red[129]=135; green[129]=0; blue[129]=123;
red[130]=139; green[130]=0; blue[130]=119;
red[131]=143; green[131]=0; blue[131]=115;
red[132]=147; green[132]=0; blue[132]=111;
red[133]=151; green[133]=0; blue[133]=107;
red[134]=155; green[134]=0; blue[134]=103;
red[135]=159; green[135]=0; blue[135]=99;
red[136]=163; green[136]=0; blue[136]=95;
red[137]=167; green[137]=0; blue[137]=91;
red[138]=171; green[138]=0; blue[138]=87;
red[139]=175; green[139]=0; blue[139]=83;
red[140]=179; green[140]=0; blue[140]=79;
red[141]=183; green[141]=0; blue[141]=75;
red[142]=187; green[142]=0; blue[142]=71;
red[143]=191; green[143]=0; blue[143]=67;
red[144]=195; green[144]=0; blue[144]=63;
red[145]=199; green[145]=0; blue[145]=59;
red[146]=203; green[146]=0; blue[146]=55;
red[147]=207; green[147]=0; blue[147]=51;
red[148]=211; green[148]=0; blue[148]=47;
red[149]=215; green[149]=0; blue[149]=43;
red[150]=219; green[150]=0; blue[150]=39;
red[151]=223; green[151]=0; blue[151]=35;
red[152]=227; green[152]=0; blue[152]=31;
red[153]=231; green[153]=0; blue[153]=27;
red[154]=235; green[154]=0; blue[154]=23;
red[155]=239; green[155]=0; blue[155]=19;
red[156]=243; green[156]=0; blue[156]=15;
red[157]=247; green[157]=0; blue[157]=11;
red[158]=251; green[158]=0; blue[158]=7;
red[159]=255; green[159]=0; blue[159]=3;
red[160]=255; green[160]=3; blue[160]=0;
red[161]=255; green[161]=7; blue[161]=0;
red[162]=255; green[162]=11; blue[162]=0;
red[163]=255; green[163]=15; blue[163]=0;
red[164]=255; green[164]=19; blue[164]=0;
red[165]=255; green[165]=23; blue[165]=0;
red[166]=255; green[166]=27; blue[166]=0;
red[167]=255; green[167]=31; blue[167]=0;
red[168]=255; green[168]=35; blue[168]=0;
red[169]=255; green[169]=39; blue[169]=0;
red[170]=255; green[170]=43; blue[170]=0;
red[171]=255; green[171]=47; blue[171]=0;
red[172]=255; green[172]=51; blue[172]=0;
red[173]=255; green[173]=55; blue[173]=0;
red[174]=255; green[174]=59; blue[174]=0;
red[175]=255; green[175]=63; blue[175]=0;
red[176]=255; green[176]=67; blue[176]=0;
red[177]=255; green[177]=71; blue[177]=0;
red[178]=255; green[178]=75; blue[178]=0;
red[179]=255; green[179]=79; blue[179]=0;
red[180]=255; green[180]=83; blue[180]=0;
red[181]=255; green[181]=87; blue[181]=0;
red[182]=255; green[182]=91; blue[182]=0;
red[183]=255; green[183]=95; blue[183]=0;
red[184]=255; green[184]=99; blue[184]=0;
red[185]=255; green[185]=103; blue[185]=0;
red[186]=255; green[186]=107; blue[186]=0;
red[187]=255; green[187]=111; blue[187]=0;
red[188]=255; green[188]=115; blue[188]=0;
red[189]=255; green[189]=119; blue[189]=0;
red[190]=255; green[190]=123; blue[190]=0;
red[191]=255; green[191]=127; blue[191]=0;
red[192]=255; green[192]=131; blue[192]=0;
red[193]=255; green[193]=135; blue[193]=0;
red[194]=255; green[194]=139; blue[194]=0;
red[195]=255; green[195]=143; blue[195]=0;
red[196]=255; green[196]=147; blue[196]=0;
red[197]=255; green[197]=151; blue[197]=0;
red[198]=255; green[198]=155; blue[198]=0;
red[199]=255; green[199]=159; blue[199]=0;
red[200]=255; green[200]=163; blue[200]=0;
red[201]=255; green[201]=167; blue[201]=0;
red[202]=255; green[202]=171; blue[202]=0;
red[203]=255; green[203]=175; blue[203]=0;
red[204]=255; green[204]=179; blue[204]=0;
red[205]=255; green[205]=183; blue[205]=0;
red[206]=255; green[206]=187; blue[206]=0;
red[207]=255; green[207]=191; blue[207]=0;
red[208]=255; green[208]=195; blue[208]=0;
red[209]=255; green[209]=199; blue[209]=0;
red[210]=255; green[210]=203; blue[210]=0;
red[211]=255; green[211]=207; blue[211]=0;
red[212]=255; green[212]=211; blue[212]=0;
red[213]=255; green[213]=215; blue[213]=0;
red[214]=255; green[214]=219; blue[214]=0;
red[215]=255; green[215]=223; blue[215]=0;
red[216]=255; green[216]=227; blue[216]=0;
red[217]=255; green[217]=231; blue[217]=0;
red[218]=255; green[218]=235; blue[218]=0;
red[219]=255; green[219]=239; blue[219]=0;
red[220]=255; green[220]=243; blue[220]=0;
red[221]=255; green[221]=247; blue[221]=0;
red[222]=255; green[222]=251; blue[222]=0;
red[223]=255; green[223]=255; blue[223]=0;
red[224]=255; green[224]=255; blue[224]=3;
red[225]=255; green[225]=255; blue[225]=7;
red[226]=255; green[226]=255; blue[226]=11;
red[227]=255; green[227]=255; blue[227]=15;
red[228]=255; green[228]=255; blue[228]=19;
red[229]=255; green[229]=255; blue[229]=23;
red[230]=255; green[230]=255; blue[230]=27;
red[231]=255; green[231]=255; blue[231]=31;
red[232]=255; green[232]=255; blue[232]=35;
red[233]=255; green[233]=255; blue[233]=39;
red[234]=255; green[234]=255; blue[234]=43;
red[235]=255; green[235]=255; blue[235]=47;
red[236]=255; green[236]=255; blue[236]=51;
red[237]=255; green[237]=255; blue[237]=55;
red[238]=255; green[238]=255; blue[238]=59;
red[239]=255; green[239]=255; blue[239]=63;
red[240]=255; green[240]=255; blue[240]=67;
red[241]=255; green[241]=255; blue[241]=71;
red[242]=255; green[242]=255; blue[242]=75;
red[243]=255; green[243]=255; blue[243]=79;
red[244]=255; green[244]=255; blue[244]=83;
red[245]=255; green[245]=255; blue[245]=87;
red[246]=255; green[246]=255; blue[246]=91;
red[247]=255; green[247]=255; blue[247]=95;
red[248]=255; green[248]=255; blue[248]=99;
red[249]=255; green[249]=255; blue[249]=103;
red[250]=255; green[250]=255; blue[250]=107;
red[251]=255; green[251]=255; blue[251]=111;
red[252]=255; green[252]=255; blue[252]=115;
red[253]=255; green[253]=255; blue[253]=119;
red[254]=255; green[254]=255; blue[254]=123;
red[255]=255; green[255]=255; blue[255]=127;
}
if (strcmp(ColorMap, "hsv") == 0) {
/*******************************************************************/
/*Definition of the HSV(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=255; green[1]=5; blue[1]=0;
red[2]=255; green[2]=11; blue[2]=0;
red[3]=255; green[3]=17; blue[3]=0;
red[4]=255; green[4]=23; blue[4]=0;
red[5]=255; green[5]=29; blue[5]=0;
red[6]=255; green[6]=35; blue[6]=0;
red[7]=255; green[7]=41; blue[7]=0;
red[8]=255; green[8]=47; blue[8]=0;
red[9]=255; green[9]=53; blue[9]=0;
red[10]=255; green[10]=59; blue[10]=0;
red[11]=255; green[11]=65; blue[11]=0;
red[12]=255; green[12]=71; blue[12]=0;
red[13]=255; green[13]=77; blue[13]=0;
red[14]=255; green[14]=83; blue[14]=0;
red[15]=255; green[15]=89; blue[15]=0;
red[16]=255; green[16]=95; blue[16]=0;
red[17]=255; green[17]=101; blue[17]=0;
red[18]=255; green[18]=107; blue[18]=0;
red[19]=255; green[19]=113; blue[19]=0;
red[20]=255; green[20]=119; blue[20]=0;
red[21]=255; green[21]=125; blue[21]=0;
red[22]=255; green[22]=131; blue[22]=0;
red[23]=255; green[23]=137; blue[23]=0;
red[24]=255; green[24]=143; blue[24]=0;
red[25]=255; green[25]=149; blue[25]=0;
red[26]=255; green[26]=155; blue[26]=0;
red[27]=255; green[27]=161; blue[27]=0;
red[28]=255; green[28]=167; blue[28]=0;
red[29]=255; green[29]=173; blue[29]=0;
red[30]=255; green[30]=179; blue[30]=0;
red[31]=255; green[31]=184; blue[31]=0;
red[32]=255; green[32]=190; blue[32]=0;
red[33]=255; green[33]=196; blue[33]=0;
red[34]=255; green[34]=202; blue[34]=0;
red[35]=255; green[35]=208; blue[35]=0;
red[36]=255; green[36]=214; blue[36]=0;
red[37]=255; green[37]=220; blue[37]=0;
red[38]=255; green[38]=226; blue[38]=0;
red[39]=255; green[39]=232; blue[39]=0;
red[40]=255; green[40]=238; blue[40]=0;
red[41]=255; green[41]=244; blue[41]=0;
red[42]=255; green[42]=250; blue[42]=0;
red[43]=253; green[43]=255; blue[43]=0;
red[44]=247; green[44]=255; blue[44]=0;
red[45]=241; green[45]=255; blue[45]=0;
red[46]=235; green[46]=255; blue[46]=0;
red[47]=229; green[47]=255; blue[47]=0;
red[48]=223; green[48]=255; blue[48]=0;
red[49]=217; green[49]=255; blue[49]=0;
red[50]=211; green[50]=255; blue[50]=0;
red[51]=205; green[51]=255; blue[51]=0;
red[52]=199; green[52]=255; blue[52]=0;
red[53]=193; green[53]=255; blue[53]=0;
red[54]=187; green[54]=255; blue[54]=0;
red[55]=181; green[55]=255; blue[55]=0;
red[56]=175; green[56]=255; blue[56]=0;
red[57]=169; green[57]=255; blue[57]=0;
red[58]=163; green[58]=255; blue[58]=0;
red[59]=157; green[59]=255; blue[59]=0;
red[60]=151; green[60]=255; blue[60]=0;
red[61]=145; green[61]=255; blue[61]=0;
red[62]=139; green[62]=255; blue[62]=0;
red[63]=133; green[63]=255; blue[63]=0;
red[64]=127; green[64]=255; blue[64]=0;
red[65]=121; green[65]=255; blue[65]=0;
red[66]=115; green[66]=255; blue[66]=0;
red[67]=109; green[67]=255; blue[67]=0;
red[68]=103; green[68]=255; blue[68]=0;
red[69]=97; green[69]=255; blue[69]=0;
red[70]=91; green[70]=255; blue[70]=0;
red[71]=85; green[71]=255; blue[71]=0;
red[72]=79; green[72]=255; blue[72]=0;
red[73]=74; green[73]=255; blue[73]=0;
red[74]=68; green[74]=255; blue[74]=0;
red[75]=62; green[75]=255; blue[75]=0;
red[76]=56; green[76]=255; blue[76]=0;
red[77]=50; green[77]=255; blue[77]=0;
red[78]=44; green[78]=255; blue[78]=0;
red[79]=38; green[79]=255; blue[79]=0;
red[80]=32; green[80]=255; blue[80]=0;
red[81]=26; green[81]=255; blue[81]=0;
red[82]=20; green[82]=255; blue[82]=0;
red[83]=14; green[83]=255; blue[83]=0;
red[84]=8; green[84]=255; blue[84]=0;
red[85]=2; green[85]=255; blue[85]=0;
red[86]=0; green[86]=255; blue[86]=3;
red[87]=0; green[87]=255; blue[87]=9;
red[88]=0; green[88]=255; blue[88]=15;
red[89]=0; green[89]=255; blue[89]=21;
red[90]=0; green[90]=255; blue[90]=27;
red[91]=0; green[91]=255; blue[91]=33;
red[92]=0; green[92]=255; blue[92]=39;
red[93]=0; green[93]=255; blue[93]=45;
red[94]=0; green[94]=255; blue[94]=51;
red[95]=0; green[95]=255; blue[95]=57;
red[96]=0; green[96]=255; blue[96]=63;
red[97]=0; green[97]=255; blue[97]=69;
red[98]=0; green[98]=255; blue[98]=75;
red[99]=0; green[99]=255; blue[99]=81;
red[100]=0; green[100]=255; blue[100]=87;
red[101]=0; green[101]=255; blue[101]=93;
red[102]=0; green[102]=255; blue[102]=99;
red[103]=0; green[103]=255; blue[103]=105;
red[104]=0; green[104]=255; blue[104]=111;
red[105]=0; green[105]=255; blue[105]=117;
red[106]=0; green[106]=255; blue[106]=123;
red[107]=0; green[107]=255; blue[107]=129;
red[108]=0; green[108]=255; blue[108]=135;
red[109]=0; green[109]=255; blue[109]=141;
red[110]=0; green[110]=255; blue[110]=147;
red[111]=0; green[111]=255; blue[111]=153;
red[112]=0; green[112]=255; blue[112]=159;
red[113]=0; green[113]=255; blue[113]=165;
red[114]=0; green[114]=255; blue[114]=171;
red[115]=0; green[115]=255; blue[115]=177;
red[116]=0; green[116]=255; blue[116]=182;
red[117]=0; green[117]=255; blue[117]=188;
red[118]=0; green[118]=255; blue[118]=194;
red[119]=0; green[119]=255; blue[119]=200;
red[120]=0; green[120]=255; blue[120]=206;
red[121]=0; green[121]=255; blue[121]=212;
red[122]=0; green[122]=255; blue[122]=218;
red[123]=0; green[123]=255; blue[123]=224;
red[124]=0; green[124]=255; blue[124]=230;
red[125]=0; green[125]=255; blue[125]=236;
red[126]=0; green[126]=255; blue[126]=242;
red[127]=0; green[127]=255; blue[127]=248;
red[128]=0; green[128]=255; blue[128]=255;
red[129]=0; green[129]=249; blue[129]=255;
red[130]=0; green[130]=243; blue[130]=255;
red[131]=0; green[131]=237; blue[131]=255;
red[132]=0; green[132]=231; blue[132]=255;
red[133]=0; green[133]=225; blue[133]=255;
red[134]=0; green[134]=219; blue[134]=255;
red[135]=0; green[135]=213; blue[135]=255;
red[136]=0; green[136]=207; blue[136]=255;
red[137]=0; green[137]=201; blue[137]=255;
red[138]=0; green[138]=195; blue[138]=255;
red[139]=0; green[139]=189; blue[139]=255;
red[140]=0; green[140]=183; blue[140]=255;
red[141]=0; green[141]=177; blue[141]=255;
red[142]=0; green[142]=171; blue[142]=255;
red[143]=0; green[143]=165; blue[143]=255;
red[144]=0; green[144]=159; blue[144]=255;
red[145]=0; green[145]=153; blue[145]=255;
red[146]=0; green[146]=147; blue[146]=255;
red[147]=0; green[147]=141; blue[147]=255;
red[148]=0; green[148]=135; blue[148]=255;
red[149]=0; green[149]=129; blue[149]=255;
red[150]=0; green[150]=123; blue[150]=255;
red[151]=0; green[151]=117; blue[151]=255;
red[152]=0; green[152]=111; blue[152]=255;
red[153]=0; green[153]=105; blue[153]=255;
red[154]=0; green[154]=99; blue[154]=255;
red[155]=0; green[155]=93; blue[155]=255;
red[156]=0; green[156]=87; blue[156]=255;
red[157]=0; green[157]=81; blue[157]=255;
red[158]=0; green[158]=75; blue[158]=255;
red[159]=0; green[159]=70; blue[159]=255;
red[160]=0; green[160]=64; blue[160]=255;
red[161]=0; green[161]=58; blue[161]=255;
red[162]=0; green[162]=52; blue[162]=255;
red[163]=0; green[163]=46; blue[163]=255;
red[164]=0; green[164]=40; blue[164]=255;
red[165]=0; green[165]=34; blue[165]=255;
red[166]=0; green[166]=28; blue[166]=255;
red[167]=0; green[167]=22; blue[167]=255;
red[168]=0; green[168]=16; blue[168]=255;
red[169]=0; green[169]=10; blue[169]=255;
red[170]=0; green[170]=4; blue[170]=255;
red[171]=1; green[171]=0; blue[171]=255;
red[172]=7; green[172]=0; blue[172]=255;
red[173]=13; green[173]=0; blue[173]=255;
red[174]=19; green[174]=0; blue[174]=255;
red[175]=25; green[175]=0; blue[175]=255;
red[176]=31; green[176]=0; blue[176]=255;
red[177]=37; green[177]=0; blue[177]=255;
red[178]=43; green[178]=0; blue[178]=255;
red[179]=49; green[179]=0; blue[179]=255;
red[180]=55; green[180]=0; blue[180]=255;
red[181]=61; green[181]=0; blue[181]=255;
red[182]=67; green[182]=0; blue[182]=255;
red[183]=73; green[183]=0; blue[183]=255;
red[184]=79; green[184]=0; blue[184]=255;
red[185]=85; green[185]=0; blue[185]=255;
red[186]=91; green[186]=0; blue[186]=255;
red[187]=97; green[187]=0; blue[187]=255;
red[188]=103; green[188]=0; blue[188]=255;
red[189]=109; green[189]=0; blue[189]=255;
red[190]=115; green[190]=0; blue[190]=255;
red[191]=121; green[191]=0; blue[191]=255;
red[192]=127; green[192]=0; blue[192]=255;
red[193]=133; green[193]=0; blue[193]=255;
red[194]=139; green[194]=0; blue[194]=255;
red[195]=145; green[195]=0; blue[195]=255;
red[196]=151; green[196]=0; blue[196]=255;
red[197]=157; green[197]=0; blue[197]=255;
red[198]=163; green[198]=0; blue[198]=255;
red[199]=169; green[199]=0; blue[199]=255;
red[200]=175; green[200]=0; blue[200]=255;
red[201]=180; green[201]=0; blue[201]=255;
red[202]=186; green[202]=0; blue[202]=255;
red[203]=192; green[203]=0; blue[203]=255;
red[204]=198; green[204]=0; blue[204]=255;
red[205]=204; green[205]=0; blue[205]=255;
red[206]=210; green[206]=0; blue[206]=255;
red[207]=216; green[207]=0; blue[207]=255;
red[208]=222; green[208]=0; blue[208]=255;
red[209]=228; green[209]=0; blue[209]=255;
red[210]=234; green[210]=0; blue[210]=255;
red[211]=240; green[211]=0; blue[211]=255;
red[212]=246; green[212]=0; blue[212]=255;
red[213]=252; green[213]=0; blue[213]=255;
red[214]=255; green[214]=0; blue[214]=251;
red[215]=255; green[215]=0; blue[215]=245;
red[216]=255; green[216]=0; blue[216]=239;
red[217]=255; green[217]=0; blue[217]=233;
red[218]=255; green[218]=0; blue[218]=227;
red[219]=255; green[219]=0; blue[219]=221;
red[220]=255; green[220]=0; blue[220]=215;
red[221]=255; green[221]=0; blue[221]=209;
red[222]=255; green[222]=0; blue[222]=203;
red[223]=255; green[223]=0; blue[223]=197;
red[224]=255; green[224]=0; blue[224]=191;
red[225]=255; green[225]=0; blue[225]=185;
red[226]=255; green[226]=0; blue[226]=179;
red[227]=255; green[227]=0; blue[227]=173;
red[228]=255; green[228]=0; blue[228]=167;
red[229]=255; green[229]=0; blue[229]=161;
red[230]=255; green[230]=0; blue[230]=155;
red[231]=255; green[231]=0; blue[231]=149;
red[232]=255; green[232]=0; blue[232]=143;
red[233]=255; green[233]=0; blue[233]=137;
red[234]=255; green[234]=0; blue[234]=131;
red[235]=255; green[235]=0; blue[235]=125;
red[236]=255; green[236]=0; blue[236]=119;
red[237]=255; green[237]=0; blue[237]=113;
red[238]=255; green[238]=0; blue[238]=107;
red[239]=255; green[239]=0; blue[239]=101;
red[240]=255; green[240]=0; blue[240]=95;
red[241]=255; green[241]=0; blue[241]=89;
red[242]=255; green[242]=0; blue[242]=83;
red[243]=255; green[243]=0; blue[243]=77;
red[244]=255; green[244]=0; blue[244]=72;
red[245]=255; green[245]=0; blue[245]=66;
red[246]=255; green[246]=0; blue[246]=60;
red[247]=255; green[247]=0; blue[247]=54;
red[248]=255; green[248]=0; blue[248]=48;
red[249]=255; green[249]=0; blue[249]=42;
red[250]=255; green[250]=0; blue[250]=36;
red[251]=255; green[251]=0; blue[251]=30;
red[252]=255; green[252]=0; blue[252]=24;
red[253]=255; green[253]=0; blue[253]=18;
red[254]=255; green[254]=0; blue[254]=12;
red[255]=255; green[255]=0; blue[255]=6;
}
if (strcmp(ColorMap, "hsvrev") == 0) {
/*******************************************************************/
/*Definition of the HSVRev(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=255; green[1]=0; blue[1]=12;
red[2]=255; green[2]=0; blue[2]=18;
red[3]=255; green[3]=0; blue[3]=24;
red[4]=255; green[4]=0; blue[4]=30;
red[5]=255; green[5]=0; blue[5]=36;
red[6]=255; green[6]=0; blue[6]=42;
red[7]=255; green[7]=0; blue[7]=48;
red[8]=255; green[8]=0; blue[8]=54;
red[9]=255; green[9]=0; blue[9]=60;
red[10]=255; green[10]=0; blue[10]=66;
red[11]=255; green[11]=0; blue[11]=72;
red[12]=255; green[12]=0; blue[12]=77;
red[13]=255; green[13]=0; blue[13]=83;
red[14]=255; green[14]=0; blue[14]=89;
red[15]=255; green[15]=0; blue[15]=95;
red[16]=255; green[16]=0; blue[16]=101;
red[17]=255; green[17]=0; blue[17]=107;
red[18]=255; green[18]=0; blue[18]=113;
red[19]=255; green[19]=0; blue[19]=119;
red[20]=255; green[20]=0; blue[20]=125;
red[21]=255; green[21]=0; blue[21]=131;
red[22]=255; green[22]=0; blue[22]=137;
red[23]=255; green[23]=0; blue[23]=143;
red[24]=255; green[24]=0; blue[24]=149;
red[25]=255; green[25]=0; blue[25]=155;
red[26]=255; green[26]=0; blue[26]=161;
red[27]=255; green[27]=0; blue[27]=167;
red[28]=255; green[28]=0; blue[28]=173;
red[29]=255; green[29]=0; blue[29]=179;
red[30]=255; green[30]=0; blue[30]=185;
red[31]=255; green[31]=0; blue[31]=191;
red[32]=255; green[32]=0; blue[32]=197;
red[33]=255; green[33]=0; blue[33]=203;
red[34]=255; green[34]=0; blue[34]=209;
red[35]=255; green[35]=0; blue[35]=215;
red[36]=255; green[36]=0; blue[36]=221;
red[37]=255; green[37]=0; blue[37]=227;
red[38]=255; green[38]=0; blue[38]=233;
red[39]=255; green[39]=0; blue[39]=239;
red[40]=255; green[40]=0; blue[40]=245;
red[41]=255; green[41]=0; blue[41]=251;
red[42]=252; green[42]=0; blue[42]=255;
red[43]=246; green[43]=0; blue[43]=255;
red[44]=240; green[44]=0; blue[44]=255;
red[45]=234; green[45]=0; blue[45]=255;
red[46]=228; green[46]=0; blue[46]=255;
red[47]=222; green[47]=0; blue[47]=255;
red[48]=216; green[48]=0; blue[48]=255;
red[49]=210; green[49]=0; blue[49]=255;
red[50]=204; green[50]=0; blue[50]=255;
red[51]=198; green[51]=0; blue[51]=255;
red[52]=192; green[52]=0; blue[52]=255;
red[53]=186; green[53]=0; blue[53]=255;
red[54]=180; green[54]=0; blue[54]=255;
red[55]=175; green[55]=0; blue[55]=255;
red[56]=169; green[56]=0; blue[56]=255;
red[57]=163; green[57]=0; blue[57]=255;
red[58]=157; green[58]=0; blue[58]=255;
red[59]=151; green[59]=0; blue[59]=255;
red[60]=145; green[60]=0; blue[60]=255;
red[61]=139; green[61]=0; blue[61]=255;
red[62]=133; green[62]=0; blue[62]=255;
red[63]=127; green[63]=0; blue[63]=255;
red[64]=121; green[64]=0; blue[64]=255;
red[65]=115; green[65]=0; blue[65]=255;
red[66]=109; green[66]=0; blue[66]=255;
red[67]=103; green[67]=0; blue[67]=255;
red[68]=97; green[68]=0; blue[68]=255;
red[69]=91; green[69]=0; blue[69]=255;
red[70]=85; green[70]=0; blue[70]=255;
red[71]=79; green[71]=0; blue[71]=255;
red[72]=73; green[72]=0; blue[72]=255;
red[73]=67; green[73]=0; blue[73]=255;
red[74]=61; green[74]=0; blue[74]=255;
red[75]=55; green[75]=0; blue[75]=255;
red[76]=49; green[76]=0; blue[76]=255;
red[77]=43; green[77]=0; blue[77]=255;
red[78]=37; green[78]=0; blue[78]=255;
red[79]=31; green[79]=0; blue[79]=255;
red[80]=25; green[80]=0; blue[80]=255;
red[81]=19; green[81]=0; blue[81]=255;
red[82]=13; green[82]=0; blue[82]=255;
red[83]=7; green[83]=0; blue[83]=255;
red[84]=1; green[84]=0; blue[84]=255;
red[85]=0; green[85]=4; blue[85]=255;
red[86]=0; green[86]=10; blue[86]=255;
red[87]=0; green[87]=16; blue[87]=255;
red[88]=0; green[88]=22; blue[88]=255;
red[89]=0; green[89]=28; blue[89]=255;
red[90]=0; green[90]=34; blue[90]=255;
red[91]=0; green[91]=40; blue[91]=255;
red[92]=0; green[92]=46; blue[92]=255;
red[93]=0; green[93]=52; blue[93]=255;
red[94]=0; green[94]=58; blue[94]=255;
red[95]=0; green[95]=64; blue[95]=255;
red[96]=0; green[96]=70; blue[96]=255;
red[97]=0; green[97]=75; blue[97]=255;
red[98]=0; green[98]=81; blue[98]=255;
red[99]=0; green[99]=87; blue[99]=255;
red[100]=0; green[100]=93; blue[100]=255;
red[101]=0; green[101]=99; blue[101]=255;
red[102]=0; green[102]=105; blue[102]=255;
red[103]=0; green[103]=111; blue[103]=255;
red[104]=0; green[104]=117; blue[104]=255;
red[105]=0; green[105]=123; blue[105]=255;
red[106]=0; green[106]=129; blue[106]=255;
red[107]=0; green[107]=135; blue[107]=255;
red[108]=0; green[108]=141; blue[108]=255;
red[109]=0; green[109]=147; blue[109]=255;
red[110]=0; green[110]=153; blue[110]=255;
red[111]=0; green[111]=159; blue[111]=255;
red[112]=0; green[112]=165; blue[112]=255;
red[113]=0; green[113]=171; blue[113]=255;
red[114]=0; green[114]=177; blue[114]=255;
red[115]=0; green[115]=183; blue[115]=255;
red[116]=0; green[116]=189; blue[116]=255;
red[117]=0; green[117]=195; blue[117]=255;
red[118]=0; green[118]=201; blue[118]=255;
red[119]=0; green[119]=207; blue[119]=255;
red[120]=0; green[120]=213; blue[120]=255;
red[121]=0; green[121]=219; blue[121]=255;
red[122]=0; green[122]=225; blue[122]=255;
red[123]=0; green[123]=231; blue[123]=255;
red[124]=0; green[124]=237; blue[124]=255;
red[125]=0; green[125]=243; blue[125]=255;
red[126]=0; green[126]=249; blue[126]=255;
red[127]=0; green[127]=255; blue[127]=255;
red[128]=0; green[128]=255; blue[128]=248;
red[129]=0; green[129]=255; blue[129]=242;
red[130]=0; green[130]=255; blue[130]=236;
red[131]=0; green[131]=255; blue[131]=230;
red[132]=0; green[132]=255; blue[132]=224;
red[133]=0; green[133]=255; blue[133]=218;
red[134]=0; green[134]=255; blue[134]=212;
red[135]=0; green[135]=255; blue[135]=206;
red[136]=0; green[136]=255; blue[136]=200;
red[137]=0; green[137]=255; blue[137]=194;
red[138]=0; green[138]=255; blue[138]=188;
red[139]=0; green[139]=255; blue[139]=182;
red[140]=0; green[140]=255; blue[140]=177;
red[141]=0; green[141]=255; blue[141]=171;
red[142]=0; green[142]=255; blue[142]=165;
red[143]=0; green[143]=255; blue[143]=159;
red[144]=0; green[144]=255; blue[144]=153;
red[145]=0; green[145]=255; blue[145]=147;
red[146]=0; green[146]=255; blue[146]=141;
red[147]=0; green[147]=255; blue[147]=135;
red[148]=0; green[148]=255; blue[148]=129;
red[149]=0; green[149]=255; blue[149]=123;
red[150]=0; green[150]=255; blue[150]=117;
red[151]=0; green[151]=255; blue[151]=111;
red[152]=0; green[152]=255; blue[152]=105;
red[153]=0; green[153]=255; blue[153]=99;
red[154]=0; green[154]=255; blue[154]=93;
red[155]=0; green[155]=255; blue[155]=87;
red[156]=0; green[156]=255; blue[156]=81;
red[157]=0; green[157]=255; blue[157]=75;
red[158]=0; green[158]=255; blue[158]=69;
red[159]=0; green[159]=255; blue[159]=63;
red[160]=0; green[160]=255; blue[160]=57;
red[161]=0; green[161]=255; blue[161]=51;
red[162]=0; green[162]=255; blue[162]=45;
red[163]=0; green[163]=255; blue[163]=39;
red[164]=0; green[164]=255; blue[164]=33;
red[165]=0; green[165]=255; blue[165]=27;
red[166]=0; green[166]=255; blue[166]=21;
red[167]=0; green[167]=255; blue[167]=15;
red[168]=0; green[168]=255; blue[168]=9;
red[169]=0; green[169]=255; blue[169]=3;
red[170]=2; green[170]=255; blue[170]=0;
red[171]=8; green[171]=255; blue[171]=0;
red[172]=14; green[172]=255; blue[172]=0;
red[173]=20; green[173]=255; blue[173]=0;
red[174]=26; green[174]=255; blue[174]=0;
red[175]=32; green[175]=255; blue[175]=0;
red[176]=38; green[176]=255; blue[176]=0;
red[177]=44; green[177]=255; blue[177]=0;
red[178]=50; green[178]=255; blue[178]=0;
red[179]=56; green[179]=255; blue[179]=0;
red[180]=62; green[180]=255; blue[180]=0;
red[181]=68; green[181]=255; blue[181]=0;
red[182]=74; green[182]=255; blue[182]=0;
red[183]=79; green[183]=255; blue[183]=0;
red[184]=85; green[184]=255; blue[184]=0;
red[185]=91; green[185]=255; blue[185]=0;
red[186]=97; green[186]=255; blue[186]=0;
red[187]=103; green[187]=255; blue[187]=0;
red[188]=109; green[188]=255; blue[188]=0;
red[189]=115; green[189]=255; blue[189]=0;
red[190]=121; green[190]=255; blue[190]=0;
red[191]=127; green[191]=255; blue[191]=0;
red[192]=133; green[192]=255; blue[192]=0;
red[193]=139; green[193]=255; blue[193]=0;
red[194]=145; green[194]=255; blue[194]=0;
red[195]=151; green[195]=255; blue[195]=0;
red[196]=157; green[196]=255; blue[196]=0;
red[197]=163; green[197]=255; blue[197]=0;
red[198]=169; green[198]=255; blue[198]=0;
red[199]=175; green[199]=255; blue[199]=0;
red[200]=181; green[200]=255; blue[200]=0;
red[201]=187; green[201]=255; blue[201]=0;
red[202]=193; green[202]=255; blue[202]=0;
red[203]=199; green[203]=255; blue[203]=0;
red[204]=205; green[204]=255; blue[204]=0;
red[205]=211; green[205]=255; blue[205]=0;
red[206]=217; green[206]=255; blue[206]=0;
red[207]=223; green[207]=255; blue[207]=0;
red[208]=229; green[208]=255; blue[208]=0;
red[209]=235; green[209]=255; blue[209]=0;
red[210]=241; green[210]=255; blue[210]=0;
red[211]=247; green[211]=255; blue[211]=0;
red[212]=253; green[212]=255; blue[212]=0;
red[213]=255; green[213]=250; blue[213]=0;
red[214]=255; green[214]=244; blue[214]=0;
red[215]=255; green[215]=238; blue[215]=0;
red[216]=255; green[216]=232; blue[216]=0;
red[217]=255; green[217]=226; blue[217]=0;
red[218]=255; green[218]=220; blue[218]=0;
red[219]=255; green[219]=214; blue[219]=0;
red[220]=255; green[220]=208; blue[220]=0;
red[221]=255; green[221]=202; blue[221]=0;
red[222]=255; green[222]=196; blue[222]=0;
red[223]=255; green[223]=190; blue[223]=0;
red[224]=255; green[224]=184; blue[224]=0;
red[225]=255; green[225]=179; blue[225]=0;
red[226]=255; green[226]=173; blue[226]=0;
red[227]=255; green[227]=167; blue[227]=0;
red[228]=255; green[228]=161; blue[228]=0;
red[229]=255; green[229]=155; blue[229]=0;
red[230]=255; green[230]=149; blue[230]=0;
red[231]=255; green[231]=143; blue[231]=0;
red[232]=255; green[232]=137; blue[232]=0;
red[233]=255; green[233]=131; blue[233]=0;
red[234]=255; green[234]=125; blue[234]=0;
red[235]=255; green[235]=119; blue[235]=0;
red[236]=255; green[236]=113; blue[236]=0;
red[237]=255; green[237]=107; blue[237]=0;
red[238]=255; green[238]=101; blue[238]=0;
red[239]=255; green[239]=95; blue[239]=0;
red[240]=255; green[240]=89; blue[240]=0;
red[241]=255; green[241]=83; blue[241]=0;
red[242]=255; green[242]=77; blue[242]=0;
red[243]=255; green[243]=71; blue[243]=0;
red[244]=255; green[244]=65; blue[244]=0;
red[245]=255; green[245]=59; blue[245]=0;
red[246]=255; green[246]=53; blue[246]=0;
red[247]=255; green[247]=47; blue[247]=0;
red[248]=255; green[248]=41; blue[248]=0;
red[249]=255; green[249]=35; blue[249]=0;
red[250]=255; green[250]=29; blue[250]=0;
red[251]=255; green[251]=23; blue[251]=0;
red[252]=255; green[252]=17; blue[252]=0;
red[253]=255; green[253]=11; blue[253]=0;
red[254]=255; green[254]=5; blue[254]=0;
red[255]=255; green[255]=0; blue[255]=0;
}
if (strcmp(ColorMap, "hsvinv") == 0) {
/*******************************************************************/
/*Definition of the HSVInv(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=0; green[1]=250; blue[1]=255;
red[2]=0; green[2]=244; blue[2]=255;
red[3]=0; green[3]=238; blue[3]=255;
red[4]=0; green[4]=232; blue[4]=255;
red[5]=0; green[5]=226; blue[5]=255;
red[6]=0; green[6]=220; blue[6]=255;
red[7]=0; green[7]=214; blue[7]=255;
red[8]=0; green[8]=208; blue[8]=255;
red[9]=0; green[9]=202; blue[9]=255;
red[10]=0; green[10]=196; blue[10]=255;
red[11]=0; green[11]=190; blue[11]=255;
red[12]=0; green[12]=184; blue[12]=255;
red[13]=0; green[13]=178; blue[13]=255;
red[14]=0; green[14]=172; blue[14]=255;
red[15]=0; green[15]=166; blue[15]=255;
red[16]=0; green[16]=160; blue[16]=255;
red[17]=0; green[17]=154; blue[17]=255;
red[18]=0; green[18]=148; blue[18]=255;
red[19]=0; green[19]=142; blue[19]=255;
red[20]=0; green[20]=136; blue[20]=255;
red[21]=0; green[21]=130; blue[21]=255;
red[22]=0; green[22]=124; blue[22]=255;
red[23]=0; green[23]=118; blue[23]=255;
red[24]=0; green[24]=112; blue[24]=255;
red[25]=0; green[25]=106; blue[25]=255;
red[26]=0; green[26]=100; blue[26]=255;
red[27]=0; green[27]=94; blue[27]=255;
red[28]=0; green[28]=88; blue[28]=255;
red[29]=0; green[29]=82; blue[29]=255;
red[30]=0; green[30]=76; blue[30]=255;
red[31]=0; green[31]=71; blue[31]=255;
red[32]=0; green[32]=65; blue[32]=255;
red[33]=0; green[33]=59; blue[33]=255;
red[34]=0; green[34]=53; blue[34]=255;
red[35]=0; green[35]=47; blue[35]=255;
red[36]=0; green[36]=41; blue[36]=255;
red[37]=0; green[37]=35; blue[37]=255;
red[38]=0; green[38]=29; blue[38]=255;
red[39]=0; green[39]=23; blue[39]=255;
red[40]=0; green[40]=17; blue[40]=255;
red[41]=0; green[41]=11; blue[41]=255;
red[42]=0; green[42]=5; blue[42]=255;
red[43]=2; green[43]=0; blue[43]=255;
red[44]=8; green[44]=0; blue[44]=255;
red[45]=14; green[45]=0; blue[45]=255;
red[46]=20; green[46]=0; blue[46]=255;
red[47]=26; green[47]=0; blue[47]=255;
red[48]=32; green[48]=0; blue[48]=255;
red[49]=38; green[49]=0; blue[49]=255;
red[50]=44; green[50]=0; blue[50]=255;
red[51]=50; green[51]=0; blue[51]=255;
red[52]=56; green[52]=0; blue[52]=255;
red[53]=62; green[53]=0; blue[53]=255;
red[54]=68; green[54]=0; blue[54]=255;
red[55]=74; green[55]=0; blue[55]=255;
red[56]=80; green[56]=0; blue[56]=255;
red[57]=86; green[57]=0; blue[57]=255;
red[58]=92; green[58]=0; blue[58]=255;
red[59]=98; green[59]=0; blue[59]=255;
red[60]=104; green[60]=0; blue[60]=255;
red[61]=110; green[61]=0; blue[61]=255;
red[62]=116; green[62]=0; blue[62]=255;
red[63]=122; green[63]=0; blue[63]=255;
red[64]=128; green[64]=0; blue[64]=255;
red[65]=134; green[65]=0; blue[65]=255;
red[66]=140; green[66]=0; blue[66]=255;
red[67]=146; green[67]=0; blue[67]=255;
red[68]=152; green[68]=0; blue[68]=255;
red[69]=158; green[69]=0; blue[69]=255;
red[70]=164; green[70]=0; blue[70]=255;
red[71]=170; green[71]=0; blue[71]=255;
red[72]=176; green[72]=0; blue[72]=255;
red[73]=181; green[73]=0; blue[73]=255;
red[74]=187; green[74]=0; blue[74]=255;
red[75]=193; green[75]=0; blue[75]=255;
red[76]=199; green[76]=0; blue[76]=255;
red[77]=205; green[77]=0; blue[77]=255;
red[78]=211; green[78]=0; blue[78]=255;
red[79]=217; green[79]=0; blue[79]=255;
red[80]=223; green[80]=0; blue[80]=255;
red[81]=229; green[81]=0; blue[81]=255;
red[82]=235; green[82]=0; blue[82]=255;
red[83]=241; green[83]=0; blue[83]=255;
red[84]=247; green[84]=0; blue[84]=255;
red[85]=253; green[85]=0; blue[85]=255;
red[86]=255; green[86]=0; blue[86]=252;
red[87]=255; green[87]=0; blue[87]=246;
red[88]=255; green[88]=0; blue[88]=240;
red[89]=255; green[89]=0; blue[89]=234;
red[90]=255; green[90]=0; blue[90]=228;
red[91]=255; green[91]=0; blue[91]=222;
red[92]=255; green[92]=0; blue[92]=216;
red[93]=255; green[93]=0; blue[93]=210;
red[94]=255; green[94]=0; blue[94]=204;
red[95]=255; green[95]=0; blue[95]=198;
red[96]=255; green[96]=0; blue[96]=192;
red[97]=255; green[97]=0; blue[97]=186;
red[98]=255; green[98]=0; blue[98]=180;
red[99]=255; green[99]=0; blue[99]=174;
red[100]=255; green[100]=0; blue[100]=168;
red[101]=255; green[101]=0; blue[101]=162;
red[102]=255; green[102]=0; blue[102]=156;
red[103]=255; green[103]=0; blue[103]=150;
red[104]=255; green[104]=0; blue[104]=144;
red[105]=255; green[105]=0; blue[105]=138;
red[106]=255; green[106]=0; blue[106]=132;
red[107]=255; green[107]=0; blue[107]=126;
red[108]=255; green[108]=0; blue[108]=120;
red[109]=255; green[109]=0; blue[109]=114;
red[110]=255; green[110]=0; blue[110]=108;
red[111]=255; green[111]=0; blue[111]=102;
red[112]=255; green[112]=0; blue[112]=96;
red[113]=255; green[113]=0; blue[113]=90;
red[114]=255; green[114]=0; blue[114]=84;
red[115]=255; green[115]=0; blue[115]=78;
red[116]=255; green[116]=0; blue[116]=73;
red[117]=255; green[117]=0; blue[117]=67;
red[118]=255; green[118]=0; blue[118]=61;
red[119]=255; green[119]=0; blue[119]=55;
red[120]=255; green[120]=0; blue[120]=49;
red[121]=255; green[121]=0; blue[121]=43;
red[122]=255; green[122]=0; blue[122]=37;
red[123]=255; green[123]=0; blue[123]=31;
red[124]=255; green[124]=0; blue[124]=25;
red[125]=255; green[125]=0; blue[125]=19;
red[126]=255; green[126]=0; blue[126]=13;
red[127]=255; green[127]=0; blue[127]=7;
red[128]=255; green[128]=0; blue[128]=0;
red[129]=255; green[129]=6; blue[129]=0;
red[130]=255; green[130]=12; blue[130]=0;
red[131]=255; green[131]=18; blue[131]=0;
red[132]=255; green[132]=24; blue[132]=0;
red[133]=255; green[133]=30; blue[133]=0;
red[134]=255; green[134]=36; blue[134]=0;
red[135]=255; green[135]=42; blue[135]=0;
red[136]=255; green[136]=48; blue[136]=0;
red[137]=255; green[137]=54; blue[137]=0;
red[138]=255; green[138]=60; blue[138]=0;
red[139]=255; green[139]=66; blue[139]=0;
red[140]=255; green[140]=72; blue[140]=0;
red[141]=255; green[141]=78; blue[141]=0;
red[142]=255; green[142]=84; blue[142]=0;
red[143]=255; green[143]=90; blue[143]=0;
red[144]=255; green[144]=96; blue[144]=0;
red[145]=255; green[145]=102; blue[145]=0;
red[146]=255; green[146]=108; blue[146]=0;
red[147]=255; green[147]=114; blue[147]=0;
red[148]=255; green[148]=120; blue[148]=0;
red[149]=255; green[149]=126; blue[149]=0;
red[150]=255; green[150]=132; blue[150]=0;
red[151]=255; green[151]=138; blue[151]=0;
red[152]=255; green[152]=144; blue[152]=0;
red[153]=255; green[153]=150; blue[153]=0;
red[154]=255; green[154]=156; blue[154]=0;
red[155]=255; green[155]=162; blue[155]=0;
red[156]=255; green[156]=168; blue[156]=0;
red[157]=255; green[157]=174; blue[157]=0;
red[158]=255; green[158]=180; blue[158]=0;
red[159]=255; green[159]=185; blue[159]=0;
red[160]=255; green[160]=191; blue[160]=0;
red[161]=255; green[161]=197; blue[161]=0;
red[162]=255; green[162]=203; blue[162]=0;
red[163]=255; green[163]=209; blue[163]=0;
red[164]=255; green[164]=215; blue[164]=0;
red[165]=255; green[165]=221; blue[165]=0;
red[166]=255; green[166]=227; blue[166]=0;
red[167]=255; green[167]=233; blue[167]=0;
red[168]=255; green[168]=239; blue[168]=0;
red[169]=255; green[169]=245; blue[169]=0;
red[170]=255; green[170]=251; blue[170]=0;
red[171]=254; green[171]=255; blue[171]=0;
red[172]=248; green[172]=255; blue[172]=0;
red[173]=242; green[173]=255; blue[173]=0;
red[174]=236; green[174]=255; blue[174]=0;
red[175]=230; green[175]=255; blue[175]=0;
red[176]=224; green[176]=255; blue[176]=0;
red[177]=218; green[177]=255; blue[177]=0;
red[178]=212; green[178]=255; blue[178]=0;
red[179]=206; green[179]=255; blue[179]=0;
red[180]=200; green[180]=255; blue[180]=0;
red[181]=194; green[181]=255; blue[181]=0;
red[182]=188; green[182]=255; blue[182]=0;
red[183]=182; green[183]=255; blue[183]=0;
red[184]=176; green[184]=255; blue[184]=0;
red[185]=170; green[185]=255; blue[185]=0;
red[186]=164; green[186]=255; blue[186]=0;
red[187]=158; green[187]=255; blue[187]=0;
red[188]=152; green[188]=255; blue[188]=0;
red[189]=146; green[189]=255; blue[189]=0;
red[190]=140; green[190]=255; blue[190]=0;
red[191]=134; green[191]=255; blue[191]=0;
red[192]=128; green[192]=255; blue[192]=0;
red[193]=122; green[193]=255; blue[193]=0;
red[194]=116; green[194]=255; blue[194]=0;
red[195]=110; green[195]=255; blue[195]=0;
red[196]=104; green[196]=255; blue[196]=0;
red[197]=98; green[197]=255; blue[197]=0;
red[198]=92; green[198]=255; blue[198]=0;
red[199]=86; green[199]=255; blue[199]=0;
red[200]=80; green[200]=255; blue[200]=0;
red[201]=75; green[201]=255; blue[201]=0;
red[202]=69; green[202]=255; blue[202]=0;
red[203]=63; green[203]=255; blue[203]=0;
red[204]=57; green[204]=255; blue[204]=0;
red[205]=51; green[205]=255; blue[205]=0;
red[206]=45; green[206]=255; blue[206]=0;
red[207]=39; green[207]=255; blue[207]=0;
red[208]=33; green[208]=255; blue[208]=0;
red[209]=27; green[209]=255; blue[209]=0;
red[210]=21; green[210]=255; blue[210]=0;
red[211]=15; green[211]=255; blue[211]=0;
red[212]=9; green[212]=255; blue[212]=0;
red[213]=3; green[213]=255; blue[213]=0;
red[214]=0; green[214]=255; blue[214]=4;
red[215]=0; green[215]=255; blue[215]=10;
red[216]=0; green[216]=255; blue[216]=16;
red[217]=0; green[217]=255; blue[217]=22;
red[218]=0; green[218]=255; blue[218]=28;
red[219]=0; green[219]=255; blue[219]=34;
red[220]=0; green[220]=255; blue[220]=40;
red[221]=0; green[221]=255; blue[221]=46;
red[222]=0; green[222]=255; blue[222]=52;
red[223]=0; green[223]=255; blue[223]=58;
red[224]=0; green[224]=255; blue[224]=64;
red[225]=0; green[225]=255; blue[225]=70;
red[226]=0; green[226]=255; blue[226]=76;
red[227]=0; green[227]=255; blue[227]=82;
red[228]=0; green[228]=255; blue[228]=88;
red[229]=0; green[229]=255; blue[229]=94;
red[230]=0; green[230]=255; blue[230]=100;
red[231]=0; green[231]=255; blue[231]=106;
red[232]=0; green[232]=255; blue[232]=112;
red[233]=0; green[233]=255; blue[233]=118;
red[234]=0; green[234]=255; blue[234]=124;
red[235]=0; green[235]=255; blue[235]=130;
red[236]=0; green[236]=255; blue[236]=136;
red[237]=0; green[237]=255; blue[237]=142;
red[238]=0; green[238]=255; blue[238]=148;
red[239]=0; green[239]=255; blue[239]=154;
red[240]=0; green[240]=255; blue[240]=160;
red[241]=0; green[241]=255; blue[241]=166;
red[242]=0; green[242]=255; blue[242]=172;
red[243]=0; green[243]=255; blue[243]=178;
red[244]=0; green[244]=255; blue[244]=183;
red[245]=0; green[245]=255; blue[245]=189;
red[246]=0; green[246]=255; blue[246]=195;
red[247]=0; green[247]=255; blue[247]=201;
red[248]=0; green[248]=255; blue[248]=207;
red[249]=0; green[249]=255; blue[249]=213;
red[250]=0; green[250]=255; blue[250]=219;
red[251]=0; green[251]=255; blue[251]=225;
red[252]=0; green[252]=255; blue[252]=231;
red[253]=0; green[253]=255; blue[253]=237;
red[254]=0; green[254]=255; blue[254]=243;
red[255]=0; green[255]=255; blue[255]=249;
}
if (strcmp(ColorMap, "hsvrevinv") == 0) {
/*******************************************************************/
/*Definition of the HSVRevInv(256) Colormap*/
red[0]=125; green[0]=125; blue[0]=125;
red[1]=0; green[1]=255; blue[1]=243;
red[2]=0; green[2]=255; blue[2]=237;
red[3]=0; green[3]=255; blue[3]=231;
red[4]=0; green[4]=255; blue[4]=225;
red[5]=0; green[5]=255; blue[5]=219;
red[6]=0; green[6]=255; blue[6]=213;
red[7]=0; green[7]=255; blue[7]=207;
red[8]=0; green[8]=255; blue[8]=201;
red[9]=0; green[9]=255; blue[9]=195;
red[10]=0; green[10]=255; blue[10]=189;
red[11]=0; green[11]=255; blue[11]=183;
red[12]=0; green[12]=255; blue[12]=178;
red[13]=0; green[13]=255; blue[13]=172;
red[14]=0; green[14]=255; blue[14]=166;
red[15]=0; green[15]=255; blue[15]=160;
red[16]=0; green[16]=255; blue[16]=154;
red[17]=0; green[17]=255; blue[17]=148;
red[18]=0; green[18]=255; blue[18]=142;
red[19]=0; green[19]=255; blue[19]=136;
red[20]=0; green[20]=255; blue[20]=130;
red[21]=0; green[21]=255; blue[21]=124;
red[22]=0; green[22]=255; blue[22]=118;
red[23]=0; green[23]=255; blue[23]=112;
red[24]=0; green[24]=255; blue[24]=106;
red[25]=0; green[25]=255; blue[25]=100;
red[26]=0; green[26]=255; blue[26]=94;
red[27]=0; green[27]=255; blue[27]=88;
red[28]=0; green[28]=255; blue[28]=82;
red[29]=0; green[29]=255; blue[29]=76;
red[30]=0; green[30]=255; blue[30]=70;
red[31]=0; green[31]=255; blue[31]=64;
red[32]=0; green[32]=255; blue[32]=58;
red[33]=0; green[33]=255; blue[33]=52;
red[34]=0; green[34]=255; blue[34]=46;
red[35]=0; green[35]=255; blue[35]=40;
red[36]=0; green[36]=255; blue[36]=34;
red[37]=0; green[37]=255; blue[37]=28;
red[38]=0; green[38]=255; blue[38]=22;
red[39]=0; green[39]=255; blue[39]=16;
red[40]=0; green[40]=255; blue[40]=10;
red[41]=0; green[41]=255; blue[41]=4;
red[42]=3; green[42]=255; blue[42]=0;
red[43]=9; green[43]=255; blue[43]=0;
red[44]=15; green[44]=255; blue[44]=0;
red[45]=21; green[45]=255; blue[45]=0;
red[46]=27; green[46]=255; blue[46]=0;
red[47]=33; green[47]=255; blue[47]=0;
red[48]=39; green[48]=255; blue[48]=0;
red[49]=45; green[49]=255; blue[49]=0;
red[50]=51; green[50]=255; blue[50]=0;
red[51]=57; green[51]=255; blue[51]=0;
red[52]=63; green[52]=255; blue[52]=0;
red[53]=69; green[53]=255; blue[53]=0;
red[54]=75; green[54]=255; blue[54]=0;
red[55]=80; green[55]=255; blue[55]=0;
red[56]=86; green[56]=255; blue[56]=0;
red[57]=92; green[57]=255; blue[57]=0;
red[58]=98; green[58]=255; blue[58]=0;
red[59]=104; green[59]=255; blue[59]=0;
red[60]=110; green[60]=255; blue[60]=0;
red[61]=116; green[61]=255; blue[61]=0;
red[62]=122; green[62]=255; blue[62]=0;
red[63]=128; green[63]=255; blue[63]=0;
red[64]=134; green[64]=255; blue[64]=0;
red[65]=140; green[65]=255; blue[65]=0;
red[66]=146; green[66]=255; blue[66]=0;
red[67]=152; green[67]=255; blue[67]=0;
red[68]=158; green[68]=255; blue[68]=0;
red[69]=164; green[69]=255; blue[69]=0;
red[70]=170; green[70]=255; blue[70]=0;
red[71]=176; green[71]=255; blue[71]=0;
red[72]=182; green[72]=255; blue[72]=0;
red[73]=188; green[73]=255; blue[73]=0;
red[74]=194; green[74]=255; blue[74]=0;
red[75]=200; green[75]=255; blue[75]=0;
red[76]=206; green[76]=255; blue[76]=0;
red[77]=212; green[77]=255; blue[77]=0;
red[78]=218; green[78]=255; blue[78]=0;
red[79]=224; green[79]=255; blue[79]=0;
red[80]=230; green[80]=255; blue[80]=0;
red[81]=236; green[81]=255; blue[81]=0;
red[82]=242; green[82]=255; blue[82]=0;
red[83]=248; green[83]=255; blue[83]=0;
red[84]=254; green[84]=255; blue[84]=0;
red[85]=255; green[85]=251; blue[85]=0;
red[86]=255; green[86]=245; blue[86]=0;
red[87]=255; green[87]=239; blue[87]=0;
red[88]=255; green[88]=233; blue[88]=0;
red[89]=255; green[89]=227; blue[89]=0;
red[90]=255; green[90]=221; blue[90]=0;
red[91]=255; green[91]=215; blue[91]=0;
red[92]=255; green[92]=209; blue[92]=0;
red[93]=255; green[93]=203; blue[93]=0;
red[94]=255; green[94]=197; blue[94]=0;
red[95]=255; green[95]=191; blue[95]=0;
red[96]=255; green[96]=185; blue[96]=0;
red[97]=255; green[97]=180; blue[97]=0;
red[98]=255; green[98]=174; blue[98]=0;
red[99]=255; green[99]=168; blue[99]=0;
red[100]=255; green[100]=162; blue[100]=0;
red[101]=255; green[101]=156; blue[101]=0;
red[102]=255; green[102]=150; blue[102]=0;
red[103]=255; green[103]=144; blue[103]=0;
red[104]=255; green[104]=138; blue[104]=0;
red[105]=255; green[105]=132; blue[105]=0;
red[106]=255; green[106]=126; blue[106]=0;
red[107]=255; green[107]=120; blue[107]=0;
red[108]=255; green[108]=114; blue[108]=0;
red[109]=255; green[109]=108; blue[109]=0;
red[110]=255; green[110]=102; blue[110]=0;
red[111]=255; green[111]=96; blue[111]=0;
red[112]=255; green[112]=90; blue[112]=0;
red[113]=255; green[113]=84; blue[113]=0;
red[114]=255; green[114]=78; blue[114]=0;
red[115]=255; green[115]=72; blue[115]=0;
red[116]=255; green[116]=66; blue[116]=0;
red[117]=255; green[117]=60; blue[117]=0;
red[118]=255; green[118]=54; blue[118]=0;
red[119]=255; green[119]=48; blue[119]=0;
red[120]=255; green[120]=42; blue[120]=0;
red[121]=255; green[121]=36; blue[121]=0;
red[122]=255; green[122]=30; blue[122]=0;
red[123]=255; green[123]=24; blue[123]=0;
red[124]=255; green[124]=18; blue[124]=0;
red[125]=255; green[125]=12; blue[125]=0;
red[126]=255; green[126]=6; blue[126]=0;
red[127]=255; green[127]=0; blue[127]=0;
red[128]=255; green[128]=0; blue[128]=7;
red[129]=255; green[129]=0; blue[129]=13;
red[130]=255; green[130]=0; blue[130]=19;
red[131]=255; green[131]=0; blue[131]=25;
red[132]=255; green[132]=0; blue[132]=31;
red[133]=255; green[133]=0; blue[133]=37;
red[134]=255; green[134]=0; blue[134]=43;
red[135]=255; green[135]=0; blue[135]=49;
red[136]=255; green[136]=0; blue[136]=55;
red[137]=255; green[137]=0; blue[137]=61;
red[138]=255; green[138]=0; blue[138]=67;
red[139]=255; green[139]=0; blue[139]=73;
red[140]=255; green[140]=0; blue[140]=78;
red[141]=255; green[141]=0; blue[141]=84;
red[142]=255; green[142]=0; blue[142]=90;
red[143]=255; green[143]=0; blue[143]=96;
red[144]=255; green[144]=0; blue[144]=102;
red[145]=255; green[145]=0; blue[145]=108;
red[146]=255; green[146]=0; blue[146]=114;
red[147]=255; green[147]=0; blue[147]=120;
red[148]=255; green[148]=0; blue[148]=126;
red[149]=255; green[149]=0; blue[149]=132;
red[150]=255; green[150]=0; blue[150]=138;
red[151]=255; green[151]=0; blue[151]=144;
red[152]=255; green[152]=0; blue[152]=150;
red[153]=255; green[153]=0; blue[153]=156;
red[154]=255; green[154]=0; blue[154]=162;
red[155]=255; green[155]=0; blue[155]=168;
red[156]=255; green[156]=0; blue[156]=174;
red[157]=255; green[157]=0; blue[157]=180;
red[158]=255; green[158]=0; blue[158]=186;
red[159]=255; green[159]=0; blue[159]=192;
red[160]=255; green[160]=0; blue[160]=198;
red[161]=255; green[161]=0; blue[161]=204;
red[162]=255; green[162]=0; blue[162]=210;
red[163]=255; green[163]=0; blue[163]=216;
red[164]=255; green[164]=0; blue[164]=222;
red[165]=255; green[165]=0; blue[165]=228;
red[166]=255; green[166]=0; blue[166]=234;
red[167]=255; green[167]=0; blue[167]=240;
red[168]=255; green[168]=0; blue[168]=246;
red[169]=255; green[169]=0; blue[169]=252;
red[170]=253; green[170]=0; blue[170]=255;
red[171]=247; green[171]=0; blue[171]=255;
red[172]=241; green[172]=0; blue[172]=255;
red[173]=235; green[173]=0; blue[173]=255;
red[174]=229; green[174]=0; blue[174]=255;
red[175]=223; green[175]=0; blue[175]=255;
red[176]=217; green[176]=0; blue[176]=255;
red[177]=211; green[177]=0; blue[177]=255;
red[178]=205; green[178]=0; blue[178]=255;
red[179]=199; green[179]=0; blue[179]=255;
red[180]=193; green[180]=0; blue[180]=255;
red[181]=187; green[181]=0; blue[181]=255;
red[182]=181; green[182]=0; blue[182]=255;
red[183]=176; green[183]=0; blue[183]=255;
red[184]=170; green[184]=0; blue[184]=255;
red[185]=164; green[185]=0; blue[185]=255;
red[186]=158; green[186]=0; blue[186]=255;
red[187]=152; green[187]=0; blue[187]=255;
red[188]=146; green[188]=0; blue[188]=255;
red[189]=140; green[189]=0; blue[189]=255;
red[190]=134; green[190]=0; blue[190]=255;
red[191]=128; green[191]=0; blue[191]=255;
red[192]=122; green[192]=0; blue[192]=255;
red[193]=116; green[193]=0; blue[193]=255;
red[194]=110; green[194]=0; blue[194]=255;
red[195]=104; green[195]=0; blue[195]=255;
red[196]=98; green[196]=0; blue[196]=255;
red[197]=92; green[197]=0; blue[197]=255;
red[198]=86; green[198]=0; blue[198]=255;
red[199]=80; green[199]=0; blue[199]=255;
red[200]=74; green[200]=0; blue[200]=255;
red[201]=68; green[201]=0; blue[201]=255;
red[202]=62; green[202]=0; blue[202]=255;
red[203]=56; green[203]=0; blue[203]=255;
red[204]=50; green[204]=0; blue[204]=255;
red[205]=44; green[205]=0; blue[205]=255;
red[206]=38; green[206]=0; blue[206]=255;
red[207]=32; green[207]=0; blue[207]=255;
red[208]=26; green[208]=0; blue[208]=255;
red[209]=20; green[209]=0; blue[209]=255;
red[210]=14; green[210]=0; blue[210]=255;
red[211]=8; green[211]=0; blue[211]=255;
red[212]=2; green[212]=0; blue[212]=255;
red[213]=0; green[213]=5; blue[213]=255;
red[214]=0; green[214]=11; blue[214]=255;
red[215]=0; green[215]=17; blue[215]=255;
red[216]=0; green[216]=23; blue[216]=255;
red[217]=0; green[217]=29; blue[217]=255;
red[218]=0; green[218]=35; blue[218]=255;
red[219]=0; green[219]=41; blue[219]=255;
red[220]=0; green[220]=47; blue[220]=255;
red[221]=0; green[221]=53; blue[221]=255;
red[222]=0; green[222]=59; blue[222]=255;
red[223]=0; green[223]=65; blue[223]=255;
red[224]=0; green[224]=71; blue[224]=255;
red[225]=0; green[225]=76; blue[225]=255;
red[226]=0; green[226]=82; blue[226]=255;
red[227]=0; green[227]=88; blue[227]=255;
red[228]=0; green[228]=94; blue[228]=255;
red[229]=0; green[229]=100; blue[229]=255;
red[230]=0; green[230]=106; blue[230]=255;
red[231]=0; green[231]=112; blue[231]=255;
red[232]=0; green[232]=118; blue[232]=255;
red[233]=0; green[233]=124; blue[233]=255;
red[234]=0; green[234]=130; blue[234]=255;
red[235]=0; green[235]=136; blue[235]=255;
red[236]=0; green[236]=142; blue[236]=255;
red[237]=0; green[237]=148; blue[237]=255;
red[238]=0; green[238]=154; blue[238]=255;
red[239]=0; green[239]=160; blue[239]=255;
red[240]=0; green[240]=166; blue[240]=255;
red[241]=0; green[241]=172; blue[241]=255;
red[242]=0; green[242]=178; blue[242]=255;
red[243]=0; green[243]=184; blue[243]=255;
red[244]=0; green[244]=190; blue[244]=255;
red[245]=0; green[245]=196; blue[245]=255;
red[246]=0; green[246]=202; blue[246]=255;
red[247]=0; green[247]=208; blue[247]=255;
red[248]=0; green[248]=214; blue[248]=255;
red[249]=0; green[249]=220; blue[249]=255;
red[250]=0; green[250]=226; blue[250]=255;
red[251]=0; green[251]=232; blue[251]=255;
red[252]=0; green[252]=238; blue[252]=255;
red[253]=0; green[253]=244; blue[253]=255;
red[254]=0; green[254]=250; blue[254]=255;
red[255]=0; green[255]=255; blue[255]=255;
}

}

/********************************************************************
Routine  : write_header_bmp_8bit
Authors  : Eric POTTIER
Creation : 07/2011
Update   : 
*--------------------------------------------------------------------
Description :  Write the header of a 8 bit BMP file
*--------------------------------------------------------------------
Inputs arguments :
nlig    : matrix number of lines
ncol    : matrix number of rows
Max    : Maximum value
Min    : Minimum value
*ColorMap : ColorMap name
*fbmp   : Pointer to the BMP file
Returned values  :
void
********************************************************************/
void write_header_bmp_8bit(int nlig, int ncol, float Max, float Min, char *ColorMap, FILE *fbmp)
{
  FILE *fcolormap;
  char *bufcolor;
  char Tmp[FilePathLength];

  int Ncolor, col;
  int red[256], green[256], blue[256];

  bufcolor = vector_char(1024);

/*******************************************************************/
/* Definition of the Header */

  header(nlig, ncol, Max, Min, fbmp);

/*******************************************************************/
/* Definition of the Colormap */


  if ((strcmp(ColorMap, "gray") == 0) ||
      (strcmp(ColorMap, "grayrev") == 0) ||
      (strcmp(ColorMap, "jet") == 0) ||
      (strcmp(ColorMap, "jetrev") == 0) ||
      (strcmp(ColorMap, "jetinv") == 0) ||
      (strcmp(ColorMap, "jetrevinv") == 0) ||
      (strcmp(ColorMap, "hsv") == 0) ||
      (strcmp(ColorMap, "hsvrev") == 0) ||
      (strcmp(ColorMap, "hsvinv") == 0) ||
      (strcmp(ColorMap, "hsvrevinv") == 0)) {
        LoadColormap(red,green,blue,ColorMap);
        } else {
        if ((fcolormap = fopen(ColorMap, "r")) == NULL)
          edit_error("Could not open the bitmap file ",ColorMap);
        fscanf(fcolormap, "%s\n", Tmp);
        fscanf(fcolormap, "%s\n", Tmp);
        fscanf(fcolormap, "%i\n", &Ncolor);
        for (col = 0; col < Ncolor; col++)
          fscanf(fcolormap, "%i %i %i\n", &red[col], &green[col], &blue[col]);
        fclose(fcolormap);
        }

/* Bitmap colormap writing */
  for (col = 0; col < 1024; col++)
    bufcolor[col] = (char) (0);

  for (col = 0; col < 256; col++) {  
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

  free_vector_char(bufcolor);
}

/********************************************************************
Routine  : write_header_bmp_8bit_mask
Authors  : Eric POTTIER
Creation : 12/2012
Update   : 
*--------------------------------------------------------------------
Description :  Write the header of a 8 bit BMP file + Color of the Mask
*--------------------------------------------------------------------
Inputs arguments :
nlig    : matrix number of lines
ncol    : matrix number of rows
Max    : Maximum value
Min    : Minimum value
*ColorMap : ColorMap name
*fbmp   : Pointer to the BMP file
Returned values  :
void
********************************************************************/
void write_header_bmp_8bit_mask(int nlig, int ncol, float Max, float Min, char *ColorMap, char *MaskCol, FILE *fbmp)
{
  FILE *fcolormap;
  char *bufcolor;
  char Tmp[FilePathLength];

  int Ncolor, col;
  int red[256], green[256], blue[256];

  bufcolor = vector_char(1024);

/*******************************************************************/
/* Definition of the Header */

  header(nlig, ncol, Max, Min, fbmp);

/*******************************************************************/
/* Definition of the Colormap */


  if ((strcmp(ColorMap, "gray") == 0) ||
      (strcmp(ColorMap, "grayrev") == 0) ||
      (strcmp(ColorMap, "jet") == 0) ||
      (strcmp(ColorMap, "jetrev") == 0) ||
      (strcmp(ColorMap, "jetinv") == 0) ||
      (strcmp(ColorMap, "jetrevinv") == 0) ||
      (strcmp(ColorMap, "hsv") == 0) ||
      (strcmp(ColorMap, "hsvrev") == 0) ||
      (strcmp(ColorMap, "hsvinv") == 0) ||
      (strcmp(ColorMap, "hsvrevinv") == 0)) {
        LoadColormap(red,green,blue,ColorMap);
        } else {
        if ((fcolormap = fopen(ColorMap, "r")) == NULL)
          edit_error("Could not open the bitmap file ",ColorMap);
        fscanf(fcolormap, "%s\n", Tmp);
        fscanf(fcolormap, "%s\n", Tmp);
        fscanf(fcolormap, "%i\n", &Ncolor);
        for (col = 0; col < Ncolor; col++)
          fscanf(fcolormap, "%i %i %i\n", &red[col], &green[col], &blue[col]);
        fclose(fcolormap);
        }

  if (strcmp(MaskCol, "white") == 0) {
    blue[0] = 255; green[0] = 255; red[0] = 255;
    }
  if (strcmp(MaskCol, "gray") == 0) {
    blue[0] = 125; green[0] = 125; red[0] = 125;
    }
  if (strcmp(MaskCol, "black") == 0) {
    blue[0] = 0; green[0] = 0; red[0] = 0;
    }

/* Bitmap colormap writing */
  for (col = 0; col < 1024; col++)
    bufcolor[col] = (char) (0);

  for (col = 0; col < 256; col++) {  
    bufcolor[4 * col] = (char) (blue[col]);
    bufcolor[4 * col + 1] = (char) (green[col]);
    bufcolor[4 * col + 2] = (char) (red[col]);
    bufcolor[4 * col + 3] = (char) (0);
    }
    
  fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

  free_vector_char(bufcolor);
}
  
/********************************************************************
Routine  : write_header_bmp_24bit
Authors  : Eric POTTIER
Creation : 07/2011
Update  :
*--------------------------------------------------------------------
Description :  Creates and writes a 24 bit bitmap file header
*--------------------------------------------------------------------
Inputs arguments :
nlig  : BMP image number of lines
ncol  : BMP image number of rows
*fbmp  : BMP file pointer
Returned values  :
void
********************************************************************/
void write_header_bmp_24bit(int nlig, int ncol, FILE * fbmp)
{
  int k;
  int extracol;

/*Bitmap File Header*/
  k = 19778;
  fwrite(&k, sizeof(short int), 1, fbmp);
  extracol = (int) fmod(4 - (int) fmod(3*ncol, 4), 4);
  k = (int) (((3 * ncol + extracol) * nlig + 54) / 2);
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 0;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 54;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 40;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = ncol;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = nlig;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 1;
  fwrite(&k, sizeof(short int), 1, fbmp);
  k = 24;
  fwrite(&k, sizeof(short int), 1, fbmp);
  k = 0;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 3 * ncol * nlig;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 2952;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 2952;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 0;
  fwrite(&k, sizeof(int), 1, fbmp);
  k = 0;
  fwrite(&k, sizeof(int), 1, fbmp);
}


 