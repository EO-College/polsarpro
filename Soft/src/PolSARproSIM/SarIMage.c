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
 * Module      : SarIMage.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "SarIMage.h"

/**************************************************/
/* SIM primitive library function implementations */
/**************************************************/

void	Report_SIM_Type_Sizes	(FILE* fp)
{
 fprintf (fp, "\n");
 fprintf (fp, "Type sim_byte is %2d bytes long\n", (int) sizeof (sim_byte));
 fprintf (fp, "Type sim_word is %2d bytes long\n", (int) sizeof (sim_word));
 fprintf (fp, "Type sim_dword is %2d bytes long\n", (int) sizeof (sim_dword));
 fprintf (fp, "Type sim_float is %2d bytes long\n", (int) sizeof (sim_float));
 fprintf (fp, "Type sim_double is %2d bytes long\n", (int) sizeof (sim_double));
 fprintf (fp, "Type sim_complex_float is %2d bytes long\n", (int) sizeof (sim_complex_float));
 fprintf (fp, "Type sim_complex_double is %2d bytes long\n", (int) sizeof (sim_complex_double));
 fprintf (fp, "\n");
 fflush (fp);
 return;
}

FILE*	open_SIM_file_read			(const char *filename)
{
 FILE	*fp;
 fp	= fopen (filename, "rb");
 return (fp);
}

FILE*	open_SIM_file_write			(const char *filename)
{
 FILE	*fp;
 fp	= fopen (filename, "wb");
 return (fp);
}

void	close_SIM_file				(FILE* fp)
{
 fclose (fp);
}

void	Create_SIM_Record			(SIM_Record *pSIMR)
{
 pSIMR->dx			= 0.0;
 pSIMR->dy			= 0.0;
 pSIMR->filename	= NULL;
 pSIMR->Lx			= 0.0;
 pSIMR->Ly			= 0.0;
 pSIMR->Ninfo		= 0;
 pSIMR->np			= 0L;
 pSIMR->nx			= 0;
 pSIMR->ny			= 0;
 pSIMR->pInfo		= NULL_PTR2SIM_HEADER;
 pSIMR->pixel_type	= 0;
 pSIMR->image		= NULL;
 return;
}

void	Destroy_SIM_Record			(SIM_Record *pSIMR)
{
 pSIMR->dx			= 0.0;
 pSIMR->dy			= 0.0;
 if (pSIMR->filename != NULL) {
	 free (pSIMR->filename);
 }
 pSIMR->filename		= NULL;
 pSIMR->Lx			= 0.0;
 pSIMR->Ly			= 0.0;
 pSIMR->Ninfo		= 0;
 pSIMR->np			= 0L;
 pSIMR->nx			= 0;
 pSIMR->ny			= 0;
 pSIMR->pixel_type	= 0;
 if (pSIMR->pInfo != NULL_PTR2SIM_HEADER) {
  free (pSIMR->pInfo);
 }
 pSIMR->pInfo			= NULL_PTR2SIM_HEADER;
 pSIMR->pixel_type	= 0;
 if (pSIMR->image != NULL) {
  free (pSIMR->image);
 }
 pSIMR->image		= NULL;
 return;
}

void	Initialise_SIM_Record		(SIM_Record *pSIMR, const char *filename, int nx, int ny, int pixel_type,
									 double	Lx, double Ly, const char *comments)
{
 pSIMR->dx			= Lx/(double)nx;
 pSIMR->dy			= Ly/(double)ny;
 pSIMR->filename	= (char*) calloc (strlen(filename)+1, sizeof(char));
 strcpy (pSIMR->filename, filename);
 pSIMR->Lx			= Lx;
 pSIMR->Ly			= Ly;
 pSIMR->Ninfo		= (int) (strlen (comments)+1);
 if (pSIMR->pInfo != NULL_PTR2SIM_HEADER) {
  free (pSIMR->pInfo);
 }
 pSIMR->pInfo		= (char*) calloc (pSIMR->Ninfo, sizeof(char));
 strcpy (pSIMR->pInfo, comments);
 pSIMR->nx			= nx;
 pSIMR->ny			= ny;
 pSIMR->np			= (long) nx * (long) ny;
 pSIMR->pixel_type	= pixel_type;
 switch (pixel_type) {
  case SIM_BYTE_TYPE:			pSIMR->image	= (sim_byte*)			calloc (pSIMR->np, sizeof (sim_byte)); break;
  case SIM_WORD_TYPE:			pSIMR->image	= (sim_word*)			calloc (pSIMR->np, sizeof (sim_word)); break;
  case SIM_DWORD_TYPE:			pSIMR->image	= (sim_dword*)			calloc (pSIMR->np, sizeof (sim_dword)); break;
  case SIM_FLOAT_TYPE:			pSIMR->image	= (sim_float*)			calloc (pSIMR->np, sizeof (sim_float)); break;
  case SIM_DOUBLE_TYPE:			pSIMR->image	= (sim_double*)			calloc (pSIMR->np, sizeof (sim_double)); break;
  case SIM_COMPLEX_FLOAT_TYPE:	pSIMR->image	= (sim_complex_float*)	calloc (pSIMR->np, sizeof (sim_complex_float)); break;
  case SIM_COMPLEX_DOUBLE_TYPE:	pSIMR->image	= (sim_complex_double*)	calloc (pSIMR->np, sizeof (sim_complex_double)); break;
  default:	pSIMR->image	= NULL; break;
 }
 return;
}

int		Write_SIM_Record			(SIM_Record *pSIMR)
{
 int			return_value	= NO_SIMPRIMITIVE_ERRORS;
 FILE			*pSF = open_SIM_file_write (pSIMR->filename);
 int			n;
 size_t			rtn;

 if ((rtn = fwrite (&(pSIMR->dx), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->dy), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 n	= (int) strlen (pSIMR->filename);
 if ((rtn = fwrite (&n, sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (pSIMR->filename, sizeof(char), n, pSF)) != (size_t) n) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->Lx), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->Ly), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 pSIMR->Ninfo	= (int) strlen (pSIMR->pInfo);
 if ((rtn = fwrite (&(pSIMR->Ninfo), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->np), sizeof(long), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->nx), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->ny), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (pSIMR->pInfo, sizeof(char), pSIMR->Ninfo, pSF)) != (size_t) pSIMR->Ninfo) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fwrite (&(pSIMR->pixel_type), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 switch (pSIMR->pixel_type) {
  case SIM_BYTE_TYPE:			n	= sizeof (sim_byte);			break;
  case SIM_WORD_TYPE:			n	= sizeof (sim_word);			break;
  case SIM_DWORD_TYPE:			n	= sizeof (sim_dword);			break;
  case SIM_FLOAT_TYPE:			n	= sizeof (sim_float);			break;
  case SIM_DOUBLE_TYPE:			n	= sizeof (sim_double);			break;
  case SIM_COMPLEX_FLOAT_TYPE:	n	= sizeof (sim_complex_float);	break;
  case SIM_COMPLEX_DOUBLE_TYPE:	n	= sizeof (sim_complex_double);	break;
  default:	n	= 0; break;
 }
 fwrite (pSIMR->image, n, pSIMR->np, pSF);
 close_SIM_file (pSF);
 return (return_value);
}

int		Read_SIM_Record				(SIM_Record *pSIMR, const char *filename)
{
 int	return_value	= NO_SIMPRIMITIVE_ERRORS;
 FILE	*pSF = open_SIM_file_read (filename);
 int	n;
 size_t			rtn;
 
 Destroy_SIM_Record (pSIMR);
 Create_SIM_Record (pSIMR);

 if ((rtn = fread (&(pSIMR->dx), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&(pSIMR->dy), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&n, sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 pSIMR->filename	= (char*) calloc (n+1, sizeof(char));
 if ((rtn = fread (pSIMR->filename, sizeof(char), n, pSF)) != (size_t) n) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 (pSIMR->filename)[n] = '\0';
 if ((rtn = fread (&(pSIMR->Lx), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&(pSIMR->Ly), sizeof(double), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&(pSIMR->Ninfo), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&(pSIMR->np), sizeof(long), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&(pSIMR->nx), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 if ((rtn = fread (&(pSIMR->ny), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 pSIMR->pInfo		= (char*) calloc (pSIMR->Ninfo+1, sizeof(char));
 if ((rtn = fread (pSIMR->pInfo, sizeof(char), pSIMR->Ninfo, pSF)) != (size_t) pSIMR->Ninfo) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 (pSIMR->pInfo)[pSIMR->Ninfo] = '\0';
 if ((rtn = fread (&(pSIMR->pixel_type), sizeof(int), 1, pSF)) != 1) {
  return_value	= !NO_SIMPRIMITIVE_ERRORS;
 }
 switch (pSIMR->pixel_type) {
  case SIM_BYTE_TYPE:			n	= sizeof (sim_byte);			break;
  case SIM_WORD_TYPE:			n	= sizeof (sim_word);			break;
  case SIM_DWORD_TYPE:			n	= sizeof (sim_dword);			break;
  case SIM_FLOAT_TYPE:			n	= sizeof (sim_float);			break;
  case SIM_DOUBLE_TYPE:			n	= sizeof (sim_double);			break;
  case SIM_COMPLEX_FLOAT_TYPE:	n	= sizeof (sim_complex_float);	break;
  case SIM_COMPLEX_DOUBLE_TYPE:	n	= sizeof (sim_complex_double);	break;
  default:	n	= 0; break;
 }
 switch (pSIMR->pixel_type) {
  case 1:	pSIMR->image	= (sim_byte*)			calloc (pSIMR->np, sizeof (sim_byte)); break;
  case 2:	pSIMR->image	= (sim_word*)			calloc (pSIMR->np, sizeof (sim_word)); break;
  case 3:	pSIMR->image	= (sim_dword*)			calloc (pSIMR->np, sizeof (sim_dword)); break;
  case 4:	pSIMR->image	= (sim_float*)			calloc (pSIMR->np, sizeof (sim_float)); break;
  case 5:	pSIMR->image	= (sim_double*)			calloc (pSIMR->np, sizeof (sim_double)); break;
  case 6:	pSIMR->image	= (sim_complex_float*)	calloc (pSIMR->np, sizeof (sim_complex_float)); break;
  case 7:	pSIMR->image	= (sim_complex_double*)	calloc (pSIMR->np, sizeof (sim_complex_double)); break;
  default:	pSIMR->image	= NULL; break;
 }
 fread (pSIMR->image, n, pSIMR->np, pSF);
 close_SIM_file (pSF);
 return (return_value);
}

void Rename_SIM_Record (SIM_Record *pSIMR, const char *new_filename)
{
 if (pSIMR->filename  != NULL) {
  free (pSIMR->filename);
 }
 pSIMR->filename = (char*) calloc (strlen(new_filename)+1, sizeof(char));
 strcpy (pSIMR->filename, new_filename);
 return;
}

sim_pixel getSIMpixel (SIM_Record *pSIMR, int i, int j)
{
 sim_pixel	p;
 long		k;

 p.simpixeltype = pSIMR->pixel_type;

 if ((i >= pSIMR->nx) || (j >= pSIMR->ny)) {
  switch (p.simpixeltype) {
   case SIM_BYTE_TYPE:				p.data.b	= (sim_byte)	0;			break;
   case SIM_WORD_TYPE:				p.data.w	= (sim_word)	0;			break;
   case SIM_DWORD_TYPE:				p.data.dw	= (sim_dword)	0;			break;
   case SIM_FLOAT_TYPE:				p.data.f	= 0.0f;						break;
   case SIM_DOUBLE_TYPE:			p.data.d	= 0.0;						break;
   case SIM_COMPLEX_FLOAT_TYPE:		p.data.cf.x	= 0.0f;	p.data.cf.y	= 0.0f;	break;
   case SIM_COMPLEX_DOUBLE_TYPE:	p.data.cd.x	= 0.0; p.data.cd.y	= 0.0;	break;
   default:	p.data.cd.x	= 0.0; p.data.cd.y	= 0.0; break;
  }
 } else { 
  k = (long) i + (long) j * (long) pSIMR->nx;
  switch (p.simpixeltype) {
   case SIM_BYTE_TYPE:				p.data.b	= ((sim_byte*)				pSIMR->image)[k];	break;
   case SIM_WORD_TYPE:				p.data.w	= ((sim_word*)				pSIMR->image)[k];	break;
   case SIM_DWORD_TYPE:				p.data.dw	= ((sim_dword*)				pSIMR->image)[k];	break;
   case SIM_FLOAT_TYPE:				p.data.f	= ((sim_float*)				pSIMR->image)[k];	break;
   case SIM_DOUBLE_TYPE:			p.data.d	= ((sim_double*)			pSIMR->image)[k];	break;
   case SIM_COMPLEX_FLOAT_TYPE:		p.data.cf	= ((sim_complex_float*)		pSIMR->image)[k];	break;
   case SIM_COMPLEX_DOUBLE_TYPE:	p.data.cd	= ((sim_complex_double*)	pSIMR->image)[k];	break;
  }
 }

 return (p);
}

void putSIMpixel (SIM_Record *pSIMR, sim_pixel p, int i, int j)
{
 long	k;

 if ((i < pSIMR->nx) && (j < pSIMR->ny)) {
  if (p.simpixeltype == pSIMR->pixel_type) {
   k = (long) i + (long) j * (long) pSIMR->nx;
   switch (p.simpixeltype) {
    case SIM_BYTE_TYPE:				((sim_byte*)			pSIMR->image)[k]	= p.data.b;		break;
    case SIM_WORD_TYPE:				((sim_word*)			pSIMR->image)[k]	= p.data.w;		break;
    case SIM_DWORD_TYPE:			((sim_dword*)			pSIMR->image)[k]	= p.data.dw;	break;
    case SIM_FLOAT_TYPE:			((sim_float*)			pSIMR->image)[k]	= p.data.f;		break;
    case SIM_DOUBLE_TYPE:			((sim_double*)			pSIMR->image)[k]	= p.data.d;		break;
    case SIM_COMPLEX_FLOAT_TYPE:	((sim_complex_float*)	pSIMR->image)[k]	= p.data.cf;	break;
    case SIM_COMPLEX_DOUBLE_TYPE:	((sim_complex_double*)	pSIMR->image)[k]	= p.data.cd;	break;
   }
  }
 }
 return;
}

sim_pixel getSIMpixel_periodic (SIM_Record *pSIMR, int i, int j)
{
 sim_pixel	p;
 long		k;

 p.simpixeltype = pSIMR->pixel_type;
 if (i >= (int) pSIMR->nx) {
  while (i >= (int) pSIMR->nx) {
   i	-= (int) pSIMR->nx;
  }
 } else {
  if (i < 0) {
   while (i < 0) {
    i	+= (int) pSIMR->nx;
   }
  }
 }
 if (j >= (int) pSIMR->ny) {
  while (j >= (int) pSIMR->ny) {
   j	-= (int) pSIMR->ny;
  }
 } else {
  if (j < 0) {
   while (j < 0) {
    j	+= (int) pSIMR->ny;
   }
  }
 }
 k = (long) i + (long) j * (long) pSIMR->nx;
 switch (p.simpixeltype) {
  case SIM_BYTE_TYPE:			p.data.b	= ((sim_byte*)				pSIMR->image)[k];	break;
  case SIM_WORD_TYPE:			p.data.w	= ((sim_word*)				pSIMR->image)[k];	break;
  case SIM_DWORD_TYPE:			p.data.dw	= ((sim_dword*)				pSIMR->image)[k];	break;
  case SIM_FLOAT_TYPE:			p.data.f	= ((sim_float*)				pSIMR->image)[k];	break;
  case SIM_DOUBLE_TYPE:			p.data.d	= ((sim_double*)			pSIMR->image)[k];	break;
  case SIM_COMPLEX_FLOAT_TYPE:	p.data.cf	= ((sim_complex_float*)		pSIMR->image)[k];	break;
  case SIM_COMPLEX_DOUBLE_TYPE:	p.data.cd	= ((sim_complex_double*)	pSIMR->image)[k];	break;
 }
 return (p);
}

void putSIMpixel_periodic (SIM_Record *pSIMR, sim_pixel p, int i, int j)
{
 long	k;

 if (p.simpixeltype == pSIMR->pixel_type) {
 if (i >= (int) pSIMR->nx) {
  while (i >= (int) pSIMR->nx) {
   i	-= (int) pSIMR->nx;
  }
 } else {
  if (i < 0) {
   while (i < 0) {
    i	+= (int) pSIMR->nx;
   }
  }
 }
 if (j >= (int) pSIMR->ny) {
  while (j >= (int) pSIMR->ny) {
   j	-= (int) pSIMR->ny;
  }
 } else {
  if (j < 0) {
   while (j < 0) {
    j	+= (int) pSIMR->ny;
   }
  }
 }
 k = (long) i + (long) j * (long) pSIMR->nx;
  switch (p.simpixeltype) {
   case SIM_BYTE_TYPE:			((sim_byte*)			pSIMR->image)[k]	= p.data.b;		break;
   case SIM_WORD_TYPE:			((sim_word*)			pSIMR->image)[k]	= p.data.w;		break;
   case SIM_DWORD_TYPE:			((sim_dword*)			pSIMR->image)[k]	= p.data.dw;	break;
   case SIM_FLOAT_TYPE:			((sim_float*)			pSIMR->image)[k]	= p.data.f;		break;
   case SIM_DOUBLE_TYPE:		((sim_double*)			pSIMR->image)[k]	= p.data.d;		break;
   case SIM_COMPLEX_FLOAT_TYPE:	((sim_complex_float*)	pSIMR->image)[k]	= p.data.cf;	break;
   case SIM_COMPLEX_DOUBLE_TYPE:((sim_complex_double*)	pSIMR->image)[k]	= p.data.cd;	break;
  }
 }
 return;
}

void		Rescale_SIM_Record			(SIM_Record *pSIMR, double scale_factor)
{
 int		i,j;
 sim_pixel	p;

 for (i = 0; i < pSIMR->nx; i++) {
  for (j = 0; j < pSIMR->ny; j++) {
   p	= getSIMpixel (pSIMR, i, j);
   switch (p.simpixeltype) {
    case SIM_BYTE_TYPE:				p.data.b	= (sim_byte)	(p.data.b * scale_factor);		break;
    case SIM_WORD_TYPE:				p.data.w	= (sim_word)	(p.data.w * scale_factor);		break;
    case SIM_DWORD_TYPE:			p.data.dw	= (sim_dword)	(p.data.dw * scale_factor);		break;
    case SIM_FLOAT_TYPE:			p.data.f	= (sim_float)	(p.data.f * scale_factor);		break;
    case SIM_DOUBLE_TYPE:			p.data.d	= (sim_double)	(p.data.d * scale_factor);		break;
    case SIM_COMPLEX_FLOAT_TYPE:	p.data.cf.x	= (sim_float)	(p.data.cf.x * scale_factor);
									p.data.cf.y	= (sim_float)	(p.data.cf.y * scale_factor);	break;
    case SIM_COMPLEX_DOUBLE_TYPE:	p.data.cd.x	= (sim_double)	(p.data.cd.x * scale_factor);
									p.data.cd.y	= (sim_double)	(p.data.cd.y * scale_factor);	break;
   }
   putSIMpixel (pSIMR, p, i, j);
  }
 }
 return;
}

/************************/
/* Binary format output */
/************************/

int		Write_SIM_Record_As_BINARY	(SIM_Record *pSIMR)
{
 SIM_Complex_Float	*column	= (SIM_Complex_Float*) calloc (pSIMR->ny, sizeof (SIM_Complex_Float));
 FILE				*pSBF;
 int				i, j;
 sim_pixel			sp;

 pSBF	= fopen (pSIMR->filename, "wb");
 for (i=0; i<pSIMR->nx; i++) {
  for (j=0; j<pSIMR->ny; j++) {
   sp	= getSIMpixel (pSIMR, i, pSIMR->ny-j-1);
   switch (sp.simpixeltype) {
    case SIM_BYTE_TYPE:				column[j].x	= (float) sp.data.b;		column[j].y	= 0.0f;		break;
	case SIM_WORD_TYPE:				column[j].x	= (float) sp.data.w;		column[j].y	= 0.0f;		break;
	case SIM_DWORD_TYPE:			column[j].x	= (float) sp.data.dw;		column[j].y	= 0.0f;		break;
	case SIM_FLOAT_TYPE:			column[j].x	= (float) sp.data.f;		column[j].y	= 0.0f;		break;
	case SIM_DOUBLE_TYPE:			column[j].x	= (float) sp.data.d;		column[j].y	= 0.0f;		break;
	case SIM_COMPLEX_FLOAT_TYPE:	column[j].x	= (float) sp.data.cf.x;		column[j].y	= (float) sp.data.cf.y;		break;
	case SIM_COMPLEX_DOUBLE_TYPE:	column[j].x	= (float) sp.data.cd.x;		column[j].y	= (float) sp.data.cd.y;		break;
   }
  }
  fwrite (column, sizeof (SIM_Complex_Float), pSIMR->ny, pSBF);
 }
 fclose (pSBF);
 free (column);
 return (NO_SIMPRIMITIVE_ERRORS);
}

/***********************/
/* Binary format input */
/***********************/

int		Read_BINARY_As_SIM_Record	(SIM_Record *pSIMR, const char *filename, int nx, int ny)
{
 SIM_Complex_Float	*column	= (SIM_Complex_Float*) calloc (ny, sizeof (SIM_Complex_Float));
 FILE				*pSBF;
 int				i, j;
 sim_pixel			sp;
 size_t				socf	= sizeof (SIM_Complex_Float);

 Destroy_SIM_Record (pSIMR);
 Initialise_SIM_Record (pSIMR, filename, nx, ny, SIM_COMPLEX_FLOAT_TYPE, 1.0, 1.0, "Binary input"); 
 sp.simpixeltype	= pSIMR->pixel_type;
 pSBF	= fopen (pSIMR->filename, "rb");
 for (i=0; i<pSIMR->nx; i++) {
  fread (column, socf, ny, pSBF);
  for (j=0; j<pSIMR->ny; j++) {
   switch (sp.simpixeltype) {
    case SIM_BYTE_TYPE:				sp.data.b		= (sim_byte) column[j].x;		break;
	case SIM_WORD_TYPE:				sp.data.w		= (sim_word) column[j].x;		break;
	case SIM_DWORD_TYPE:			sp.data.dw		= (sim_dword) column[j].x;		break;
	case SIM_FLOAT_TYPE:			sp.data.f		= (sim_float) column[j].x;		break;
	case SIM_DOUBLE_TYPE:			sp.data.d		= (sim_double) column[j].x;		break;
	case SIM_COMPLEX_FLOAT_TYPE:	sp.data.cf.x	= (sim_float) column[j].x;
									sp.data.cf.y	= (sim_float) column[j].y;
									break;
	case SIM_COMPLEX_DOUBLE_TYPE:	sp.data.cd.x	= (sim_double) column[j].x;
									sp.data.cd.y	= (sim_double) column[j].y;
									break;
   }
   putSIMpixel (pSIMR, sp, i, pSIMR->ny-j-1);
  }
 }
 fclose (pSBF);
 free (column);
 return (NO_SIMPRIMITIVE_ERRORS);
}

/*********************************************************/
/* Image rotation for POLSARPRO range-azimuth convention */
/*********************************************************/

int		Rotate_SIM_Record			(SIM_Record *pOrg, SIM_Record *pRot)
{
 int				i,j;
 sim_pixel			sp;
 Destroy_SIM_Record (pRot);
 Initialise_SIM_Record (pRot, pOrg->filename, pOrg->ny, pOrg->nx, pOrg->pixel_type, pOrg->Ly, pOrg->Lx, pOrg->pInfo);
 for (i=0; i<pOrg->nx; i++) {
  for (j=0; j<pOrg->ny; j++) {
   sp	= getSIMpixel (pOrg, i, j);
   putSIMpixel (pRot, sp, pOrg->ny-1-j, i);
  }
 }
 return (NO_SIMPRIMITIVE_ERRORS);
}
