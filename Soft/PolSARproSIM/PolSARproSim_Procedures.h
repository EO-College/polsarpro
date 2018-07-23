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
 * Module      : PolSARproSim_Procedures.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Procedure prototypes for PolSARproSim
 */
#ifndef __POLSARPROSIM_PROCEDURES_H__
#define __POLSARPROSIM_PROCEDURES_H__

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

/****************/
/* Housekeeping */
/****************/

void		PolSARproSim_notice				(FILE *fp);
void		PolSARproSim_compile_options	(FILE *fp);

/*********************************/
/* Surface parameter calculation */
/*********************************/

void		Surface_Parameters				(PolSARproSim_Record *pPR, int DEM_model);

/***************************************/
/* Prototypes for top-level procedures */
/***************************************/

int			Input_PolSARproSim_Record		(const char *filename, PolSARproSim_Record *pPR);
void		Ground_Surface_Generation		(PolSARproSim_Record *pPR);
void		Tree_Location_Generation		(PolSARproSim_Record *pPR);
void		Forest_Graphic					(PolSARproSim_Record *pPR);
void		Effective_Permittivities		(PolSARproSim_Record *pPR);
void		Attenuation_Map					(PolSARproSim_Record *pPR);

/**************************/
/* Line input termination */
/**************************/

void		EndOfLine						(FILE *fp);

/*****************************/
/* SPM Scattering Amplitudes */
/*****************************/

Complex		Bhh								(double theta, Complex epsilon);
Complex		Bvv								(double theta, Complex epsilon);

/*************************/
/* SAR image calculation */
/*************************/

double		Accumulate_SAR_Contribution		(double focus_x, double focus_y, double focus_srange,
											 Complex Shh, Complex Shv, Complex Svv, PolSARproSim_Record *pPR);
int			Lookup_Direct_Attenuation		(d3Vector r, PolSARproSim_Record *pPR, double *gH, double *gV);
int			Lookup_Bounce_Attenuation		(d3Vector r, PolSARproSim_Record *pPR, double *gH, double *gV);
int			Polarisation_Vectors			(d3Vector k, d3Vector n, d3Vector *ph, d3Vector *pv);
c3Vector	d3V2c3V							(d3Vector v);
#ifndef POLSARPRO_CONVENTION
void		Create_SAR_Filenames			(PolSARproSim_Record *pPR, const char *master_directory, const char *slave_directory, const char *prefix);
#else
void		Create_SAR_Filenames			(PolSARproSim_Record *pPR, const char *master_directory, const char *slave_directory);
#endif
void		Clean_SAR_Images				(PolSARproSim_Record *pPR);
int			Cylinder_from_Branch			(Cylinder *pC, Branch *pB, int i_seg, int n_segments);
double		Estimate_SAR_Tertiaries			(Tree *pT, PolSARproSim_Record *pPR, long *nt, double *tbl, double *tbr);
double		Realise_SAR_Tertiaries			(Tree *pT, PolSARproSim_Record *pPR);
double		Estimate_SAR_Foliage			(Tree *pT, PolSARproSim_Record *pPR, long *nf);
double		Realise_SAR_Foliage				(Tree *pT, PolSARproSim_Record *pPR);
void		Write_SAR_Images				(PolSARproSim_Record *pPR);
void		Destroy_SAR_Images				(PolSARproSim_Record *pPR);

int			Realise_Tertiary_Branch			(Tree *pT, PolSARproSim_Record *pPR, Branch *pB, 
											 double tertiary_branch_length, double tertiary_branch_radius,
											 double moisture, Complex permittivity);

int			Realise_Foliage_Element			(Tree *pT, PolSARproSim_Record *pPR, Leaf *pL, 
											int species, double leaf_d1, double leaf_d2, double leaf_d3, 
											double moisture, Complex permittivity);

/************************/
/* TCLTK string parsing */
/************************/

void		tcltk_parser					(char *pString);

/****************************************/
/* Optional flat earth phase correction */
/****************************************/

#ifdef	POLSARPROSIM_FLATEARTH
void		Flat_Earth_Phase_Removal		(PolSARproSim_Record *pPR);
#endif

#endif

