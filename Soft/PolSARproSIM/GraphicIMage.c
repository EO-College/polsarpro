/************************************************************************/
/*																		*/
/* PolSARproSim Version C1b  Forest Synthetic Aperture Radar Simulation	*/
/* Copyright (C) 2007 Mark L. Williams									*/
/*																		*/
/* This program is free software; you may redistribute it and/or		*/
/* modify it under the terms of the GNU General Public License			*/
/* as published by the Free Software Foundation; either version 2		*/
/* of the License, or (at your option) any later version.				*/
/*																		*/
/* This program is distributed in the hope that it will be useful,		*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of		*/
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.					*/
/* See the GNU General Public License for more details.					*/
/*																		*/
/* You should have received a copy of the GNU General Public License	*/
/* along with this program; if not, write to the Free Software			*/
/* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,			*/
/* MA  02110-1301, USA. (http://www.gnu.org/copyleft/gpl.html)			*/
/*																		*/
/************************************************************************/
/* 
 * Author      : Mark L. Williams
 * Module	   : GraphicIMage.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "GraphicIMage.h"

/********************************************/
/* Graphic library function implementations */
/********************************************/

FILE*	open_graphic_file_read			(const char *filename)
{
 FILE	*fp;
 fp	= fopen (filename, "rb");
 return (fp);
}

FILE*	open_graphic_file_write			(const char *filename)
{
 FILE	*fp;
 fp	= fopen (filename, "wb");
 return (fp);
}

void	close_graphic_file				(FILE* fp)
{
 fclose (fp);
}

void	Create_Graphic_Record			(Graphic_Record *pGR)
{
 pGR->filename		= NULL;
 pGR->Ninfo			= 0;
 pGR->np			= 0L;
 pGR->nx			= 0;
 pGR->ny			= 0;
 pGR->pInfo			= NULL_PTR2GIM_HEADER;
 pGR->image			= NULL;
 return;
}

void	Destroy_Graphic_Record			(Graphic_Record *pGR)
{
 if (pGR->filename != NULL) {
	 free (pGR->filename);
 }
 pGR->filename		= NULL;
 pGR->Ninfo			= 0;
 pGR->np			= 0L;
 pGR->nx			= 0;
 pGR->ny			= 0;
 if (pGR->pInfo != NULL_PTR2GIM_HEADER) {
  free (pGR->pInfo);
 }
 pGR->pInfo			= NULL_PTR2GIM_HEADER;
 if (pGR->image != NULL) {
  free (pGR->image);
 }
 pGR->image		= NULL;
 return;
}

void	Initialise_Graphic_Record		(Graphic_Record *pGR, const char *filename, int nx, int ny, const char *comments)
{
 pGR->filename	= (char*) calloc (strlen(filename)+1, sizeof(char));
 strcpy (pGR->filename, filename);
 pGR->Ninfo		= strlen (comments)+1;
 if (pGR->pInfo != NULL_PTR2GIM_HEADER) {
  free (pGR->pInfo);
 }
 pGR->pInfo		= (char*) calloc (pGR->Ninfo, sizeof(char));
 strcpy (pGR->pInfo, comments);
 pGR->nx			= nx;
 pGR->ny			= ny;
 pGR->np			= (long) nx * (long) ny;
 pGR->image			= (graphic_pixel*)	calloc (pGR->np, sizeof (graphic_pixel));
 return;
}

int		Write_Graphic_Record			(Graphic_Record *pGR)
{
 int		return_value	= NO_GRAPHIC_ERRORS;
 FILE		*pGF			= open_graphic_file_write (pGR->filename);
 int		n;
 size_t		rtn;

if ((rtn = fwrite (&(pGR->np), sizeof(long), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fwrite (&(pGR->nx), sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fwrite (&(pGR->ny), sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 n	= strlen (pGR->filename);
 if ((rtn = fwrite (&n, sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fwrite (pGR->filename, sizeof(char), n, pGF)) != (size_t) n) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 pGR->Ninfo	= strlen (pGR->pInfo);
 if ((rtn = fwrite (&(pGR->Ninfo), sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fwrite (pGR->pInfo, sizeof(char), pGR->Ninfo, pGF)) != (size_t) pGR->Ninfo) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 n	= sizeof (graphic_pixel);
 fwrite (pGR->image, n, pGR->np, pGF);
 close_graphic_file (pGF);
 return (return_value);
}

int		Read_Graphic_Record				(Graphic_Record *pGR, const char *filename)
{
 int		return_value	= NO_GRAPHIC_ERRORS;
 FILE		*pGF			= open_graphic_file_read (filename);
 int		n;
 size_t		rtn;
 
 Destroy_Graphic_Record (pGR);
 Create_Graphic_Record (pGR);

 if ((rtn = fread (&(pGR->np), sizeof(long), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fread (&(pGR->nx), sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fread (&(pGR->ny), sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 if ((rtn = fread (&n, sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 pGR->filename	= (char*) calloc (n+1, sizeof(char));
 if ((rtn = fread (pGR->filename, sizeof(char), n, pGF)) != (size_t) n) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 (pGR->filename)[n] = '\0';
 if ((rtn = fread (&(pGR->Ninfo), sizeof(int), 1, pGF)) != 1) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 pGR->pInfo		= (char*) calloc (pGR->Ninfo+1, sizeof(char));
 if ((rtn = fread (pGR->pInfo, sizeof(char), pGR->Ninfo, pGF)) != (size_t) pGR->Ninfo) {
  return_value	= !NO_GRAPHIC_ERRORS;
 }
 (pGR->pInfo)[pGR->Ninfo] = '\0';
 n	= sizeof (graphic_pixel);
 pGR->image	= (graphic_pixel*)	calloc (pGR->np, n);
 fread (pGR->image, n, pGR->np, pGF);
 close_graphic_file (pGF);
 return (return_value);
}

void Rename_Graphic_Record (Graphic_Record *pGR, const char *new_filename)
{
 if (pGR->filename  != NULL) {
  free (pGR->filename);
 }
 pGR->filename = (char*) calloc (strlen(new_filename)+1, sizeof(char));
 strcpy (pGR->filename, new_filename);
 return;
}

graphic_pixel getGraphicpixel (Graphic_Record *pGR, int i, int j)
{
 graphic_pixel	p;
 long			k;
 if ((i >= pGR->nx) || (j >= pGR->ny)) {
  p.red		= 0;
  p.green	= 0;
  p.blue	= 0;
 } else { 
  k = (long) i + (long) j * (long) pGR->nx;
  p	= ((graphic_pixel*)	pGR->image)[k];
 }
 return (p);
}

void putGraphicpixel (Graphic_Record *pGR, graphic_pixel p, int i, int j)
{
 long	k;

 if ((i < pGR->nx) && (j < pGR->ny)) {
  k = (long) i + (long) j * (long) pGR->nx;
  ((graphic_pixel*)	pGR->image)[k]	= p;
 }
 return;
}

graphic_pixel getGraphicpixel_periodic (Graphic_Record *pGR, int i, int j)
{
 graphic_pixel	p;
 long			k;

 if (i >= (int) pGR->nx) {
  while (i >= (int) pGR->nx) {
   i	-= (int) pGR->nx;
  }
 } else {
  if (i < 0) {
   while (i < 0) {
    i	+= (int) pGR->nx;
   }
  }
 }
 if (j >= (int) pGR->ny) {
  while (j >= (int) pGR->ny) {
   j	-= (int) pGR->ny;
  }
 } else {
  if (j < 0) {
   while (j < 0) {
    j	+= (int) pGR->ny;
   }
  }
 }
 k = (long) i + (long) j * (long) pGR->nx;
 p	= ((graphic_pixel*)	pGR->image)[k];
 return (p);
}

void putGraphicpixel_periodic (Graphic_Record *pGR, graphic_pixel p, int i, int j)
{
 long	k;

 if (i >= (int) pGR->nx) {
  while (i >= (int) pGR->nx) {
   i	-= (int) pGR->nx;
  }
 } else {
  if (i < 0) {
   while (i < 0) {
    i	+= (int) pGR->nx;
   }
  }
 }
 if (j >= (int) pGR->ny) {
  while (j >= (int) pGR->ny) {
   j	-= (int) pGR->ny;
  }
 } else {
  if (j < 0) {
   while (j < 0) {
    j	+= (int) pGR->ny;
   }
  }
 }
 k = (long) i + (long) j * (long) pGR->nx;
 ((graphic_pixel*)	pGR->image)[k]	= p;
 return;
}

void			Background_Graphic_Record		(Graphic_Record *pGR, unsigned char red, unsigned char green, unsigned char blue)
{
 int	ix, iy;
 graphic_pixel	gp;

 gp.red		= red;
 gp.green	= green;
 gp.blue	= blue;
 for (ix=0; ix<pGR->nx; ix++) {
  for (iy=0; iy<pGR->ny; iy++) {
   putGraphicpixel (pGR, gp, ix, iy);
  }
 }
 return;
}

/******************/
/* Alpha blending */
/******************/

void			putGraphicpixel_alphab				(Graphic_Record *pGR, graphic_pixel p, int i, int j, double alpha)
{
 graphic_pixel	q	= getGraphicpixel (pGR, i, j);
 graphic_pixel	r;
 r.red		= (unsigned char) (((double)p.red)*alpha   + ((double)q.red)*(1.0-alpha));
 r.green	= (unsigned char) (((double)p.green)*alpha + ((double)q.green)*(1.0-alpha));
 r.blue		= (unsigned char) (((double)p.blue)*alpha  + ((double)q.blue)*(1.0-alpha));
 putGraphicpixel (pGR, r, i, j);
 return;
}

void			putGraphicpixel_periodic_alphab		(Graphic_Record *pGR, graphic_pixel p, int i, int j, double alpha)
{
 graphic_pixel	q	= getGraphicpixel_periodic (pGR, i, j);
 graphic_pixel	r;
 r.red		= (unsigned char) (((double)p.red)*alpha   + ((double)q.red)*(1.0-alpha));
 r.green	= (unsigned char) (((double)p.green)*alpha + ((double)q.green)*(1.0-alpha));
 r.blue		= (unsigned char) (((double)p.blue)*alpha  + ((double)q.blue)*(1.0-alpha));
 putGraphicpixel_periodic (pGR, r, i, j);
 return;
}

void	GRI_endian_reverse	(void *pData, size_t Nbytes, long Ndata)
{
 long	n;
 int	i,j;
 char	*pByte = pData;
 char	b;

 if (Nbytes > (size_t) 1) {
  for (n=0L; n<Ndata; n++) {
   i	= 0;
   j	= (int) Nbytes - 1; 
   while (i < j) {
    b			= pByte[i];
    pByte[i]	= pByte[j];
    pByte[j]	= b;
    i++;
    j--;
   }
   pByte	+= Nbytes;
  }
 }
 return;
}

int		GRI_quad_boundary	(int nx)
{
 int	nx3	= 3*nx;
 int	r;
 r		= nx3 % 4;
 if (r != 0) {
  nx3	= 4*((nx3/4)+1);
 }
 return (nx3);
}

void	Write_GRIasRGBbmp	(const char *s, Graphic_Record *pGR)
{
 int			dwnx			= GRI_quad_boundary ((int) pGR->nx);
 int			dwny			= (int) pGR->ny;
 BMP_WORD		bfType			= (BMP_WORD)  0x4D42;
 BMP_DWORD		bfSize			= (BMP_DWORD) (54 + dwnx * dwny);
 BMP_WORD		bfReserved1		= (BMP_WORD)  0;
 BMP_WORD		bfReserved2		= (BMP_WORD)  0;
 BMP_DWORD		bfOffBits		= (BMP_DWORD) 54;
 BMP_DWORD		biSize          = 0x28;
 BMP_LONG		biWidth         = (BMP_LONG) pGR->nx;
 BMP_LONG		biHeight        = (BMP_LONG) pGR->ny;
 BMP_WORD		biPlanes        = 1;
 BMP_WORD		biBitCount      = 24;
 BMP_DWORD		biCompression   = 0;
 BMP_DWORD		biSizeImage     = (BMP_DWORD) (dwnx * dwny);
 BMP_LONG		biXPelsPerMeter = 2835;
 BMP_LONG		biYPelsPerMeter = 2835;
 BMP_DWORD		biClrUsed       = 0;
 BMP_DWORD		biClrImportant  = 0;
 FILE			*fp;
 int			ix,iy;
 Rgbquad		rgb;
 graphic_pixel	gp;
/***********************************/
/* Attempt to open the output file */
/***********************************/
 if ((fp = fopen(s, "wb")) == NULL) {
  printf ("Error opening file %s\n", s);
  exit (3);
 }
/************/
/* 14 bytes */
/************/
#ifdef GRI_SWAP_BMP
 GRI_endian_reverse (&bfType,		sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&bfSize,		sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&bfReserved1,	sizeof(BMP_WORD),	1L); 
 GRI_endian_reverse (&bfReserved2,	sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&bfOffBits,	sizeof(BMP_DWORD),	1L);
#endif
 fwrite(&bfType,		sizeof (BMP_WORD),	1,	fp);
 fwrite(&bfSize,		sizeof (BMP_DWORD),	1,	fp);
 fwrite(&bfReserved1,	sizeof (BMP_WORD),	1,	fp);
 fwrite(&bfReserved2,	sizeof (BMP_WORD),	1,	fp);
 fwrite(&bfOffBits,		sizeof (BMP_DWORD),	1,	fp);
#ifdef GRI_SWAP_BMP
 GRI_endian_reverse (&bfType,		sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&bfSize,		sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&bfReserved1,	sizeof(BMP_WORD),	1L); 
 GRI_endian_reverse (&bfReserved2,	sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&bfOffBits,	sizeof(BMP_DWORD),	1L);
#endif
/************************/
/* followed by 40 bytes */
/************************/
#ifdef GRI_SWAP_BMP
 GRI_endian_reverse (&biSize,			sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biWidth,			sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biHeight,			sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biPlanes,			sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&biBitCount,		sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&biCompression,	sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biSizeImage,		sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biXPelsPerMeter,	sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biYPelsPerMeter,	sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biClrUsed,		sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biClrImportant,	sizeof(BMP_DWORD),	1L);
#endif
 fwrite (&biSize,			sizeof(BMP_DWORD),	1, fp);
 fwrite (&biWidth,			sizeof(BMP_LONG),	1, fp);
 fwrite (&biHeight,			sizeof(BMP_LONG),	1, fp);
 fwrite (&biPlanes,			sizeof(BMP_WORD),	1, fp);
 fwrite (&biBitCount,		sizeof(BMP_WORD),	1, fp);
 fwrite (&biCompression,	sizeof(BMP_DWORD),	1, fp);
 fwrite (&biSizeImage,		sizeof(BMP_DWORD),	1, fp);
 fwrite (&biXPelsPerMeter,	sizeof(BMP_LONG),	1, fp);
 fwrite (&biYPelsPerMeter,	sizeof(BMP_LONG),	1, fp);
 fwrite (&biClrUsed,		sizeof(BMP_DWORD),	1, fp);
 fwrite (&biClrImportant,	sizeof(BMP_DWORD),	1, fp); 
#ifdef GRI_SWAP_BMP
 GRI_endian_reverse (&biSize,			sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biWidth,			sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biHeight,			sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biPlanes,			sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&biBitCount,		sizeof(BMP_WORD),	1L);
 GRI_endian_reverse (&biCompression,	sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biSizeImage,		sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biXPelsPerMeter,	sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biYPelsPerMeter,	sizeof(BMP_LONG),	1L);
 GRI_endian_reverse (&biClrUsed,		sizeof(BMP_DWORD),	1L);
 GRI_endian_reverse (&biClrImportant,	sizeof(BMP_DWORD),	1L);
#endif
/***************************************/
/* followed by dwnx * ny bytes of data */
/***************************************/
 for (iy = pGR->ny-1; iy >= 0; iy--) {
  for (ix=0; ix < pGR->nx; ix++) {
   gp				= getGraphicpixel (pGR, ix, iy);
   rgb.rgbBlue		= (BMP_BYTE) gp.blue;
   rgb.rgbGreen		= (BMP_BYTE) gp.green;
   rgb.rgbRed		= (BMP_BYTE) gp.red;
   fwrite (&(rgb.rgbBlue), sizeof(BMP_BYTE), 1, fp);
   fwrite (&(rgb.rgbGreen), sizeof(BMP_BYTE), 1, fp);
   fwrite (&(rgb.rgbRed), sizeof(BMP_BYTE), 1, fp);
  }
  rgb.rgbBlue		= (BMP_BYTE) 0;
  for (ix=0; ix < dwnx-3*pGR->nx; ix++) {
   fwrite (&(rgb.rgbBlue), sizeof(BMP_BYTE), 1, fp);
  }
 }
/*************************/
/* Close the output file */
/*************************/
 fclose(fp);
/*******************************/
/* Return to calling procedure */
/*******************************/
 return;
}

