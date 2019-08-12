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
 * Module      : SarIMage.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __SARIMAGE_H__
#define __SARIMAGE_H__

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*********************************/
/* Complex data type definitions */
/*********************************/

typedef struct sim_float_complex_tag {
 float x;
 float y;
} SIM_Complex_Float;

typedef struct sim_double_complex_tag {
 double x;
 double y;
} SIM_Complex_Double;

/********************/
/* Other data types */
/********************/

#define SIM_BYTE_TYPE			1		/* 8 bit pixels	 (unsigned char)									*/
#define SIM_WORD_TYPE			2		/* 16 bit pixels (unsigned short int)								*/
#define SIM_DWORD_TYPE			3		/* 32 bit pixels (int)												*/
#define SIM_FLOAT_TYPE			4		/* 32 bit float pixels (float)										*/
#define SIM_DOUBLE_TYPE			5		/* 64 bit double pixels (double)									*/
#define SIM_COMPLEX_FLOAT_TYPE	6		/* 64 bit float real and imaginary pixels (SIM_Complex_Float)		*/
#define SIM_COMPLEX_DOUBLE_TYPE	7		/* 128 bit double real and imaginary pixels	(SIM_Complex_Double)	*/

/****************/
/* SIM typedefs */
/****************/

typedef unsigned char			sim_byte;
typedef unsigned short int		sim_word;
typedef int						sim_dword;
typedef float					sim_float;
typedef double					sim_double;
typedef SIM_Complex_Float		sim_complex_float;
typedef SIM_Complex_Double		sim_complex_double;

/*********************************/
/* SIM library type definitions  */
/*********************************/

typedef union  sim_type_tag {
	sim_byte			b;
	sim_word			w;
	sim_dword			dw;
	sim_float			f;
	sim_double			d;
	sim_complex_float	cf;
	sim_complex_double	cd;
} sim_type;

/******************************/
/* SAR Image record structure */
/******************************/

typedef struct sim_record_tag {
 int		nx;				/* Image dimension in the x-dirn in pixels		*/
 int		ny;				/* Image dimension in the y-dirn in pixels		*/
 int		Ninfo;			/* Number of bytes of additional information	*/
 char		*pInfo;			/* ASCII information field						*/
 int		pixel_type;		/* Type of image pixels (1-7, defined below)	*/
 char		*filename;		/* Name of associated file						*/
 long		np;				/* Total number of pixels						*/
 double		Lx;				/* Image width in metres						*/
 double		Ly;				/* Image height in metres						*/
 double		dx;				/* Image pixel width in metres					*/
 double		dy;				/* Image pixel height in metres					*/
 void		*image;			/* Points to the data							*/
} SIM_Record;

typedef struct simpixel_tag {
 int			simpixeltype;
 sim_type		data;
} sim_pixel;

/***********************************/
/* SIM library function prototypes */
/***********************************/

void		Report_SIM_Type_Sizes		(FILE* fp);
FILE*		open_SIM_file_read			(const char *filename);
FILE*		open_SIM_file_write			(const char *filename);
void		close_SIM_file				(FILE* fp);
void		Create_SIM_Record			(SIM_Record *pSIMR);
void		Destroy_SIM_Record			(SIM_Record *pSIMR);
void		Initialise_SIM_Record		(SIM_Record *pSIMR, const char *filename, int nx, int ny, int pixel_type,
										double	Lx, double Ly, const char *comments);
int			Write_SIM_Record			(SIM_Record *pSIMR);
int			Read_SIM_Record				(SIM_Record *pSIMR, const char *filename);
void		Rename_SIM_Record			(SIM_Record *pSIMR, const char *new_filename);
sim_pixel	getSIMpixel					(SIM_Record *pSIMR, int i, int j);
void		putSIMpixel					(SIM_Record *pSIMR, sim_pixel p, int i, int j);
sim_pixel	getSIMpixel_periodic		(SIM_Record *pSIMR, int i, int j);
void		putSIMpixel_periodic		(SIM_Record *pSIMR, sim_pixel p, int i, int j);
void		Rescale_SIM_Record			(SIM_Record *pSIMR, double scale_factor);

/**********************/
/* Error return codes */
/**********************/

#define NO_SIMPRIMITIVE_ERRORS          0
#define	NULL_PTR2SIM_HEADER				0

/******************************************************/
/* Binary format output for compliance with PolSARPro */
/******************************************************/

int		Write_SIM_Record_As_BINARY	(SIM_Record *pSIMR);
int		Read_BINARY_As_SIM_Record	(SIM_Record *pSIMR, const char *filename, int nx, int ny);

/******************************************************/
/* Image rotation for testing binary image compliance */
/******************************************************/

int		Rotate_SIM_Record			(SIM_Record *pOrg, SIM_Record *pRot);

#endif
