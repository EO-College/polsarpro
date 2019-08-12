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
 * Module	   : Perspective.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Perspective.h"

/*****************************************/
/* Conversion from global to perspective */
/* projection screen coordinates         */
/*****************************************/

d3Vector	Perspective_Global2Screen	(Perspective *pPersR, d3Vector	rg)
{
 d3Vector	v;
 double		alpha;
 double		x,y,z;

 z		= rg.x[1];
 Create_d3Vector (&v);
 d3Vector_insitu_normalise (&rg);
 alpha	= pPersR->Znear/rg.x[1];
 x		= alpha*rg.x[0];
 y		= alpha*rg.x[2];
 v		= Cartesian_Assign_d3Vector (x, y, z);
 return (v);
}
