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
 * Module      : LightingMaterials.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __LIGHTINGMATERIALS_H__
#define __LIGHTINGMATERIALS_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

#include	"bmpDefinitions.h"
#include	"d3Vector.h"
#include	"GraphicIMage.h"

/*******************/
/* Lighting record */
/*******************/

typedef struct lighting_tag {
 double			Ia;		/* Ambient intensity					*/
 double			Ii;		/* Incident intensity					*/
 d3Vector		light;	/* Single light source model			*/
 d3Vector		view;	/* View vector							*/
 d3Vector		Hvec;	/* For efficient intensity calculation	*/
} Lighting_Record;

/********************************/
/* Material reflectivity record */
/********************************/

typedef struct material_reflectivity_tag {
 double			ka;		/* Ambient reflectivity		*/	
 double			kd;		/* Diffuse reflectivity		*/
 double			ks;		/* Specular reflectivity	*/
} Material_Reflectivity;

/**************************/
/* Material colour record */
/**************************/

typedef struct material_colour_tag {
 double			Sr;		/* Red scalefactor		*/	
 double			Sg;		/* Green scalefactor	*/
 double			Sb;		/* Blue scale factor	*/
} Material_Colour;

/*******************/
/* Material record */
/*******************/

typedef struct material_tag {
 Material_Reflectivity	mR;
 Material_Colour		mC;
} Material;

/************************************/
/* Lighting and Material Prototypes */
/************************************/

 void			Create_Lighting_Record	(Lighting_Record *pLR, double Ia, double Ii, 
										 d3Vector *pl, d3Vector *pv);
 double			intensity				(Lighting_Record *pLR, Material *pM, d3Vector n);
 graphic_pixel	colour					(Lighting_Record *pLR, Material *pM, d3Vector n);
 d3Vector		CalculateH				(d3Vector l, d3Vector v);
 void			Create_Material			(Material *pM, double ka, double kd, double ks,
										 double sr, double sg, double sb);
/*********************/
/* Error return code */
/*********************/

#define NO_LIGHTING_ERRORS          0

#endif
