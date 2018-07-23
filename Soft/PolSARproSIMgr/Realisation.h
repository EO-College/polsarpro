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
 * Module      : Realisation.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Procedure prototypes for PolSARproSim tree realisations
 */
#ifndef __REALISATION_H__
#define __REALISATION_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

#include	"Allometrics.h"
#include	"Attenuation.h"
#include	"bmpDefinitions.h"
#include	"Branch.h"
#include	"c33Matrix.h"
#include	"c3Vector.h"
#include	"Complex.h"
#include	"Cone.h"
#include	"Crown.h"
#include	"Cylinder.h"
#include	"d33Matrix.h"
#include	"d3Vector.h"
#include	"Facet.h"
#include	"GraphicIMage.h"
#include	"GrgCyl.h"
#include	"Ground.h"
#include	"InfCyl.h"
#include	"JLkp.h"
#include	"Jnz.h"
#include	"Leaf.h"
#include	"LightingMaterials.h"
#include	"MonteCarlo.h"
#include	"Perspective.h"
#include	"Plane.h"
#include	"PolSARproSim_Definitions.h"
#include	"PolSARproSim_Procedures.h"
#include	"PolSARproSim_Progress.h"
#include	"PolSARproSim_Structures.h"
#include	"Ray.h"
#include	"RayCrownIntersection.h"
#include	"SarIMage.h"
#include	"Sinc.h"
#include	"soilsurface.h"
#include	"Spheroid.h"
#include	"Tree.h"
#include	"Trig.h"
#include	"YLkp.h"

/***************************************/
/* Plant element polar angle generator */
/***************************************/

double		vegi_polar_angle				(void);

/*******************/
/* Tree generation */
/*******************/

void		Realise_Tree				(Tree *pT, int i, PolSARproSim_Record *pPR);			/* Generate the realisation of the ith tree at its location				*/
void		Realise_Tree_Crown_Only		(Tree *pT, int i, PolSARproSim_Record *pPR);			/* Generate the realisation of the ith tree without branches or foliage	*/

/************************************/
/* Random crown location generation */
/************************************/

int			Random_Crown_Location		(Crown *p_cwn, d3Vector *s);							/* Generate a random location within a tree crown						*/

#endif
