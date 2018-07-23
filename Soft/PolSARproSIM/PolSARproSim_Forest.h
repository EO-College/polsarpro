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
 * Module      : PolSARproSim_Forest.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Forest interferometric SAR image calculation for PolSARproSim
 */
#ifndef __POLSARPROSIM_FOREST_H__
#define __POLSARPROSIM_FOREST_H__

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
#include	"Realisation.h"
#include	"SarIMage.h"
#include	"Sinc.h"
#include	"soilsurface.h"
#include	"Spheroid.h"
#include	"Tree.h"
#include	"Trig.h"
#include	"YLkp.h"

/**********************************/
/* SAR Geometry Record definition */
/**********************************/

typedef struct sargeometry_tag {
/*********************************/
/* Direct backscatter quantities */
/*********************************/
 double			Pi;
 double			thetai;
 double			cos_thetai;
 double			sin_thetai;
 double			p_srange;
 double			p_thetai;
 double			p_height;
 double			p_grange;
 Yn_Lookup		Ytable;
 Jn_Lookup		Jtable;
 d3Vector		ki, ks;
 c3Vector		ch, cv;
/*********************************/
/* Bounce backscatter quantities */
/*********************************/
 d3Vector		n, z;
 d3Vector		kr, krm;
 d3Vector		hi,  vi,  hs,  vs,  hr,  vr,  hrm,  vrm;
 d3Vector		hil, vil, hsl, vsl, hrl, vrl, hrlm, vrlm;
 c3Vector		chi,  cvi,  chs,  cvs,  chr,  cvr,  chrm,  cvrm;
 c3Vector		chil, cvil, chsl, cvsl, chrl, cvrl, chrlm, cvrlm;
 c33Matrix		R1, R2;
/************************/
/* Performance monitors */
/************************/
 double			Sigma0HH;
 double			Sigma0HV;
 double			Sigma0VH;
 double			Sigma0VV;
 Complex		AvgShhvv, zhhvv;
 double			Sigma0_count;
} SarGeometry;

/*************************/
/* SAR geometry routines */
/*************************/

int		Initialise_SAR_Geometry			(SarGeometry *pSG, PolSARproSim_Record *pPR);
int		Delete_SAR_Geometry				(SarGeometry *pSG);

/********************************************************************/
/* Short vegetation interferometric SAR image calculation prototype */
/********************************************************************/

int		PolSARproSim_Forest_Direct		(PolSARproSim_Record *pPR);
int		PolSARproSim_Forest_Bounce		(PolSARproSim_Record *pPR);

#define	NO_POLSARPROSIM_FOREST_ERRORS			0

#endif
