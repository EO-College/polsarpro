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
 * Module      : JLkp.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __JLKP_H__
#define __JLKP_H__

#include	<float.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<time.h>
#include	<math.h>

#define		NO_JLKP_ERRORS		0

typedef struct Jn_lookup_table {
 int		nmax;		/* Maximum ordinate number	*/
 double		dx;			/* Ordinate separation		*/
 double		*pJ0;		/* Array of J0 values		*/	
 double		*pJ1;		/* Array of J1 values		*/
 double		*pJ2;		/* Array of J2 values		*/	
 double		*pJ3;		/* Array of J3 values		*/
 double		*pJ4;		/* Array of J4 values		*/	
 double		*pJ5;		/* Array of J5 values		*/
 double		*pJ6;		/* Array of J6 values		*/	
 double		*pJ7;		/* Array of J7 values		*/
 double		*pJ8;		/* Array of J8 values		*/	
 double		*pJ9;		/* Array of J9 values		*/
 double		*pJ[10];	/* Array of pointers		*/
} Jn_Lookup;

int			Initialise_Standard_Jnlookup	(Jn_Lookup *pJLkp);
int			Delete_Jnlookup					(Jn_Lookup *pJLkp);
int			Jlookup							(double x, int Nmax, double *pJ, Jn_Lookup *pJLkp);

#endif
