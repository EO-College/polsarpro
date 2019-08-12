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
 * Module      : Perspective.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __PERSPECTIVE_H__
#define __PERSPECTIVE_H__

#include	<stdio.h>
#include	<stdlib.h>

#include	"d3Vector.h"

/************************************************************************************************/
/* In the global frame the view point is at the origin, and looks in the positive y-direction.	*/
/* In the perspective frame the view point is at the origin, but looks in the z-direction.		*/
/* Thus the global z-direction is the same as the perspective y-direction, and vice-versa.		*/
/* The x-direction is the same in both systems.													*/
/************************************************************************************************/

/*********************************/
/* Perspective projection record */
/*********************************/

typedef struct perspective_tag {
 double			Py;		/* Screen height					*/
 double			Px;		/* Screen width						*/
 double			Pz;		/* View volume depth (Zfar-Znear)	*/
 double			Znear;	/* Near plane (screen) distance		*/
 double			Zfar;	/* Far plane distance				*/
 unsigned int	nx;		/* Image width in pixels			*/
 unsigned int	ny;		/* Image height in pixels			*/
 double			dx;		/* Screen pixel width				*/
 double			dy;		/* Screen pixel height				*/
} Perspective;

/*****************************************/
/* Conversion from global to perspective */
/* projection screen coordinates         */
/*****************************************/

d3Vector	Perspective_Global2Screen	(Perspective *pPersR, d3Vector	rg);

/*********************/
/* Error return code */
/*********************/

#define NO_PERSPECTIVE_ERRORS          0

#endif
