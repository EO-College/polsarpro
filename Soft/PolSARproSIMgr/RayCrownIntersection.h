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
 * Module      : RayCrownIntersection.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Procedure prototypes for Ray intersection location
 */
#ifndef __RAYCROWNINTERSECTION_H__
#define __RAYCROWNINTERSECTION_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

#include	"Complex.h"
#include	"Cone.h"
#include	"Crown.h"
#include	"Cylinder.h"
#include	"d3Vector.h"
#include	"Plane.h"
#include	"Ray.h"
#include	"Spheroid.h"
#include	"Trig.h"

/********************************/
/* Ray intersection definitions */
/********************************/

#define		NO_RAYPLANE_ERRORS				1
#define		NO_RAYCYLINDER_ERRORS			2
#define		NO_RAYCONE_ERRORS				2
#define		NO_RAYSPHEROID_ERRORS			2
#define		NO_RAYCROWN_ERRORS				2

/*******************************/
/* Ray intersection prototypes */
/*******************************/

int			RayPlaneIntersection			(Ray *pR, Plane *pP,	d3Vector *pS,	double *alpha);
int			RayCylinderIntersection			(Ray *pR, Cylinder *pC,	d3Vector *pS1,	double *alpha1, 
											 d3Vector *pS2, double *alpha2);
int			RayConeIntersection				(Ray *pR, Cone *pC,		d3Vector *pS1,	double *alpha1, 
											 d3Vector *pS2, double *alpha2);
int			RaySpheroidIntersection			(Ray *pR, Spheroid *pS,	d3Vector *pS1,	double *alpha1, 
											 d3Vector *pS2, double *alpha2);
int			RayCrownIntersection			(Ray *pR, Crown *pC,	d3Vector *pS1,	double *alpha1, 
											 d3Vector *pS2, double *alpha2);
int			RayCrownCylinderIntersection	(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2);
int			RayCrownConeIntersection		(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2);
int			RayCrownSpheroidIntersection	(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2);
#endif
