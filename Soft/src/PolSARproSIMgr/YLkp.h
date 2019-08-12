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
 * Module      : YLkp.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __YLKP_H__
#define __YLKP_H__

#include	<float.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<math.h>

#include	"JLkp.h"

#define		NO_YLKP_ERRORS		0

typedef struct Yn_lookup_table {
 int		nmax;		/* Maximum ordinate number	*/
 double		dx;			/* Ordinate separation		*/
 double		*pY0;		/* Array of Y0 values		*/	
 double		*pY1;		/* Array of Y1 values		*/
 double		*pY2;		/* Array of Y2 values		*/	
 double		*pY3;		/* Array of Y3 values		*/
 double		*pY4;		/* Array of Y4 values		*/	
 double		*pY5;		/* Array of Y5 values		*/
 double		*pY6;		/* Array of Y6 values		*/	
 double		*pY7;		/* Array of Y7 values		*/
 double		*pY8;		/* Array of Y8 values		*/	
 double		*pY9;		/* Array of Y9 values		*/
 double		*pY[10];	/* Array of pointers		*/
} Yn_Lookup;

int			Initialise_Standard_Ynlookup	(Yn_Lookup *pYLkp);
int			Delete_Ynlookup					(Yn_Lookup *pYLkp);
int			Ylookup							(double x, int Nmax, double *pY, Yn_Lookup *pYLkp, Jn_Lookup *pJLkp);

#endif
