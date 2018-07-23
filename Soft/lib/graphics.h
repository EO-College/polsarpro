/*******************************************************************

File	 : graphics.h
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 09/2004
Update	:

*-------------------------------------------------------------------
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
*-------------------------------------------------------------------

Description :  GRAPHICS Routines

*-------------------------------------------------------------------
Routines	:

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

*******************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagGraphics
#define FlagGraphics
void header (int nlig, int ncol, float Max, float Min, FILE * fbmp);
void headerTiff (int nlig, int ncol, FILE * fbmp);
void footerTiff(short int nlig, short int ncol, FILE * fptr);
void colormap (int *red, int *green, int *blue, int comp);
void bmp_8bit (int nlig, int ncol, float Max, float Min, char *Colormap, float **DataBmp, char *name);
void bmp_8bit_char (int nlig, int ncol, float Max, float Min, char *Colormap, char *DataBmp, char *name);
void bmp_24bit(int nlig,int ncol,int mapgray,float **DataBmp,char *name);
void tiff_24bit(int nlig,int ncol,int mapgray,float **DataBmp,char *name);
void bmp_training_set (float **mat, int li, int co, char *nom, char *ColorMap16);
void bmp_wishart (float **mat, int li, int co, char *nom, char *ColorMap);
void bmp_h_alpha(float **mat, int li, int co, char *name, char *ColorMap);

void LoadColormap(int *red, int *green, int *blue, char *ColorMap);
void write_header_bmp_8bit(int nlig, int ncol, float Max, float Min, char *ColorMap, FILE *fbmp);
void write_header_bmp_8bit_mask(int nlig, int ncol, float Max, float Min, char *ColorMap, char *MaskCol, FILE *fbmp);
void write_header_bmp_24bit(int nlig, int ncol, FILE *fbmp);

#endif
