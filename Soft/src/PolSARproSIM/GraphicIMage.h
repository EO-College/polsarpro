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
 * Module      : GraphicIMage.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __GRAPHICIMAGE_H__
#define __GRAPHICIMAGE_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>

#include	"bmpDefinitions.h"

/**********************************/
/* Graphic pixel type definitions */
/**********************************/

typedef struct graphic_pixel_tab  {
 unsigned char	red;
 unsigned char	green;
 unsigned char	blue;
} graphic_pixel;

/**********************************/
/* Graphic Image record structure */
/**********************************/

typedef struct graphic_record_tag {
 int			nx;				/* Image dimension in the x-dirn in pixels		*/
 int			ny;				/* Image dimension in the y-dirn in pixels		*/
 int			Ninfo;			/* Number of bytes of additional information	*/
 char			*pInfo;			/* ASCII information field						*/
 char			*filename;		/* Name of associated file						*/
 long			np;				/* Total number of pixels						*/
 graphic_pixel	*image;			/* Points to the data							*/
} Graphic_Record;

/***************************************/
/* Graphic library function prototypes */
/***************************************/
	
FILE*			open_graphic_file_read			(const char *filename);
FILE*			open_graphic_file_write			(const char *filename);
void			close_graphic_file				(FILE* fp);
void			Create_Graphic_Record			(Graphic_Record *pGR);
void			Destroy_Graphic_Record			(Graphic_Record *pGR);
void			Initialise_Graphic_Record		(Graphic_Record *pGR, const char *filename, int nx, int ny, const char *comments);
int				Write_Graphic_Record			(Graphic_Record *pGR);
int				Read_Graphic_Record				(Graphic_Record *pGR, const char *filename);
void			Rename_Graphic_Record			(Graphic_Record *pGR, const char *new_filename);
graphic_pixel	getGraphicpixel					(Graphic_Record *pGR, int i, int j);
void			putGraphicpixel					(Graphic_Record *pGR, graphic_pixel p, int i, int j);
graphic_pixel	getGraphicpixel_periodic		(Graphic_Record *pGR, int i, int j);
void			putGraphicpixel_periodic		(Graphic_Record *pGR, graphic_pixel p, int i, int j);
void			Background_Graphic_Record		(Graphic_Record *pGR, unsigned char red, char unsigned green, unsigned char blue);

/******************/
/* Alpha blending */
/******************/

void			putGraphicpixel_alphab				(Graphic_Record *pGR, graphic_pixel p, int i, int j, double alpha);
void			putGraphicpixel_periodic_alphab		(Graphic_Record *pGR, graphic_pixel p, int i, int j, double alpha);

/**********************/
/* Error return codes */
/**********************/

#define			NO_GRAPHIC_ERRORS					0
#define			NULL_PTR2GIM_HEADER					0

/******************************/
/* BITMAP image format output */
/******************************/

#ifndef _WIN32
#define			GRI_SWAP_BMP
#endif

void			Write_GRIasRGBbmp					(const char *s, Graphic_Record *pGR);

#endif
