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
 * Module      : Allometrics.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Allometric definitions for PolSARproSim
 */
#ifndef __ALLOMETRICS_H__
#define __ALLOMETRICS_H__

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

/***************************/
/* Good event return value */
/***************************/

#define	NO_ALLOMETRICS_ERRORS										0

/********************************/
/* PERMITTIVITY MODEL CONSTANTS */
/********************************/

#define		VTF0													7.5
#define		VDTF0													2.5
#define		TEMP													20.0
#define		EPSINF_FW												4.9
#define		SIGMA_FW												1.27
#define		TWOPIE0_INV												17.97548488
#define		EPSINF_BW												2.9
#define		E0_BW													57.9
#define		F0_BW													0.18
#define		E0_FW													80.0888
#define		TWOPITAU_FW												0.0582852
#define		F0_FW													17.15701413

/********************************/
/* Stem polar orientation angle */
/********************************/

#define	POLSARPROSIM_HEDGE_STEM_MIN_COS_POLAR						0.999999999
#define POLSARPROSIM_PINE001_STEM_MIN_COS_POLAR						0.999847695
#define POLSARPROSIM_PINE002_STEM_MIN_COS_POLAR						0.999847695
#define POLSARPROSIM_PINE003_STEM_MIN_COS_POLAR						0.999847695
#define POLSARPROSIM_DECIDUOUS001_STEM_MIN_COS_POLAR				0.984807753

/*************************************************/
/* Stem start radius as a fraction of the height */
/*************************************************/

#define	POLSARPROSIM_HEDGE_STEM_RADIUS_FACTOR						0.00
#define POLSARPROSIM_PINE001_STEM_RADIUS_FACTOR						0.5721
#define POLSARPROSIM_PINE002_STEM_RADIUS_FACTOR						0.5721
#define POLSARPROSIM_PINE003_STEM_RADIUS_FACTOR						0.5721
#define POLSARPROSIM_DECIDUOUS001_STEM_RADIUS_FACTOR				0.7925

/***********************************************/
/* Stem end radius as a fraction of the height */
/***********************************************/

#define	POLSARPROSIM_HEDGE_STEM_END_RADIUS_FACTOR					0.00
#define POLSARPROSIM_PINE001_STEM_END_RADIUS_FACTOR					0.5302
#define POLSARPROSIM_PINE002_STEM_END_RADIUS_FACTOR					0.5302
#define POLSARPROSIM_PINE003_STEM_END_RADIUS_FACTOR					0.5302
#define POLSARPROSIM_DECIDUOUS001_STEM_END_RADIUS_FACTOR			0.7345

/******************************************************************/
/* Deciduous tree model internal crown angle and dimension factor */
/******************************************************************/

#define	POLSARPROSIM_DECIDUOUS001_CROWN_BETA_AVG					0.785398163
#define	POLSARPROSIM_DECIDUOUS001_CROWN_ALPHA						0.410
#define POLSARPROSIM_DECIDUOUS001_CROWN_DEPTH_FACTOR				1.99

/***********************************************/
/* PINE001 primary branch realisation controls */
/***********************************************/

#define	POLSARPROSIM_PINE001_DRY_LAYER_DENSITY						4.015
#define	POLSARPROSIM_PINE001_DRY_AVG_SECTIONS						4
#define	POLSARPROSIM_PINE001_PRIMARY_LAYER_DENSITY					4.015
#define	POLSARPROSIM_PINE001_PRIMARY_AVG_SECTIONS					6
#define	POLSARPROSIM_PINE001_PRIMARY_MAX_POLAR_ANGLE				103.0
#define	POLSARPROSIM_PINE001_PRIMARY_AVG_POLAR_ANGLE				81.75
#define	POLSARPROSIM_PINE001_PRIMARY_DLT_POLAR_ANGLE				21.25
#define	POLSARPROSIM_PINE001_PRIMARY_RADIUS_FACTOR					0.5
#define	POLSARPROSIM_PINE001_PRIMARY_AZIMUTH_FACTOR					0.5

/*************************************************/
/* PINE001 secondary branch realisation controls */
/*************************************************/

#define	POLSARPROSIM_PINE001_SECONDARY_LAYER_DENSITY				6.723
#define	POLSARPROSIM_PINE001_SECONDARY_AVG_SECTIONS					2
#define	POLSARPROSIM_PINE001_SECONDARY_MAX_POLAR_ANGLE				90.0
#define	POLSARPROSIM_PINE001_SECONDARY_AVG_POLAR_ANGLE				70.0
#define	POLSARPROSIM_PINE001_SECONDARY_DLT_POLAR_ANGLE				20.0
#define	POLSARPROSIM_PINE001_SECONDARY_RADIUS_FACTOR				0.5
#define	POLSARPROSIM_PINE001_SECONDARY_AZIMUTH_FACTOR				0.5
#define POLSARPROSIM_PINE001_SECONDARY_TMIN							0.350
#define POLSARPROSIM_PINE001_SECONDARY_TMAX							0.950
#define POLSARPROSIM_PINE001_SECONDARY_CONE_RADIUS_FACTOR			0.268

/****************************************************/
/* DECIDUOUS001 primary branch realisation controls */
/****************************************************/

#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_LAYER_DENSITY				3.01
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_AVG_SECTIONS				4
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_MAX_POLAR_ANGLE			75.0
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_AVG_POLAR_ANGLE			50.0
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_DLT_POLAR_ANGLE			25.0
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_RADIUS_FACTOR				0.693
#define POLSARPROSIM_DECIDUOUS001_PRIMARY_TMIN						0.150
#define POLSARPROSIM_DECIDUOUS001_PRIMARY_TMAX						0.950
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_AZIMUTH_FACTOR			0.5

/******************************************************/
/* DECIDUOUS001 secondary branch realisation controls */
/******************************************************/

#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_LAYER_DENSITY			2.26125
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_AVG_SECTIONS			4
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_MAX_POLAR_ANGLE			65.0
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_AVG_POLAR_ANGLE			45.0
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_DLT_POLAR_ANGLE			20.0
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_RADIUS_FACTOR			0.714
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_AZIMUTH_FACTOR			0.5
#define POLSARPROSIM_DECIDUOUS001_SECONDARY_TMIN					0.350
#define POLSARPROSIM_DECIDUOUS001_SECONDARY_TMAX					0.950
#define POLSARPROSIM_DECIDUOUS001_SECONDARY_CONE_RADIUS_FACTOR		1.0
#define POLSARPROSIM_DECIDUOUS001_SECONDARY_SPHEROID_RADIUS_FACTOR	1.0
#define POLSARPROSIM_DECIDUOUS001_SECONDARY_SPHEROID_HEIGHT_FACTOR	2.0

/********************************/
/* Tertiary element definitions */
/********************************/

#define	POLSARPROSIM_HEDGE_TERTIARY_BRANCH_VOL_FRAC					0.004
#define	POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC				0.001
#define	POLSARPROSIM_DECIDUOUS001_TERTIARY_BRANCH_VOL_FRAC			0.001
#define	POLSARPROSIM_HEDGE_FOLIAGE_VOL_FRAC							0.000125
#define	POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC						0.00025
#define	POLSARPROSIM_DECIDUOUS001_FOLIAGE_VOL_FRAC					0.00025

/***********************************************************/
/* Foliage dimensions are in order descending d1 > d2 > d3 */
/***********************************************************/

#define	POLSARPROSIM_HEDGE_FOLIAGE_D1								0.060
#define	POLSARPROSIM_HEDGE_FOLIAGE_D2								0.040
#define	POLSARPROSIM_HEDGE_FOLIAGE_D3								0.001

#define	POLSARPROSIM_PINE001_FOLIAGE_D1								0.020
#define	POLSARPROSIM_PINE001_FOLIAGE_D2								0.001
#define	POLSARPROSIM_PINE001_FOLIAGE_D3								0.001

#define	POLSARPROSIM_DECIDUOUS001_FOLIAGE_D1						0.060
#define	POLSARPROSIM_DECIDUOUS001_FOLIAGE_D2						0.040
#define	POLSARPROSIM_DECIDUOUS001_FOLIAGE_D3						0.001

/*********************/
/* Moisture contents */
/*********************/

#define	POLSARPROSIM_HEDGE_STEM_MOISTURE							0.370
#define	POLSARPROSIM_PINE001_STEM_MOISTURE							0.370
#define	POLSARPROSIM_DECIDUOUS001_STEM_MOISTURE						0.370

#define	POLSARPROSIM_HEDGE_PRIMARY_MOISTURE							0.424
#define	POLSARPROSIM_PINE001_PRIMARY_MOISTURE						0.424
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_MOISTURE					0.424

#define	POLSARPROSIM_HEDGE_PRIMARY_DRY_MOISTURE						0.100
#define	POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE					0.100
#define	POLSARPROSIM_DECIDUOUS001_PRIMARY_DRY_MOISTURE				0.100

#define	POLSARPROSIM_HEDGE_SECONDARY_MOISTURE						0.4735
#define	POLSARPROSIM_PINE001_SECONDARY_MOISTURE						0.4735
#define	POLSARPROSIM_DECIDUOUS001_SECONDARY_MOISTURE				0.4735

#define	POLSARPROSIM_HEDGE_TERTIARY_MOISTURE						0.4735
#define	POLSARPROSIM_PINE001_TERTIARY_MOISTURE						0.4735
#define	POLSARPROSIM_DECIDUOUS001_TERTIARY_MOISTURE					0.4735

#define	POLSARPROSIM_HEDGE_LEAF_MOISTURE							0.550
#define	POLSARPROSIM_PINE001_LEAF_MOISTURE							0.550
#define	POLSARPROSIM_DECIDUOUS001_LEAF_MOISTURE						0.550

/***********************************/
/* Tree allometric implementations */
/***********************************/

int			Number_of_Secondaries			(int species, double primary_length);

double		Primary_Minimum_Polar_Angle		(int species, double height);
double		Primary_Maximum_Polar_Angle		(int species, double height);

double		Crown_Fractional_Living_Depth	(int species, double height);
double		Crown_Fractional_Radius			(int species, double height);
double		Crown_Fractional_Dry_Depth		(int species, double height);

double		Mean_Living_Crown_Depth			(int species, double height);		/* Returns the depth of the layer of living branches					*/
double		Realise_Living_Crown_Depth		(int species, double height);		/* Generates living crown depth from a normal distribution				*/
double		Mean_Dry_Crown_Depth			(int species, double height);		/* Returns the depth of the layer of dry branches						*/
double		Mean_Crown_Edge_Length			(int species, double height);		/* Returns the distance along a line from apex to crown base			*/
double		Mean_Crown_Angle_Beta			(int species, double height);		/* Returns the crown angle, beta										*/
double		Mean_Tree_Crown_Radius			(int species, double height);		/* Returns the mean tree crown radius according to species allometric	*/
double		Realise_Tree_Crown_Radius		(int species, double height);		/* Generate a tree crown radius estimate based on species allometric	*/
double		Realise_Tree_Height				(double mean_height);				/* Generate a tree height from a truncated normal distribution			*/

double		Stem_Start_Radius				(int species, double height);
double		Stem_End_Radius					(int species, double height);
d3Vector	Stem_Direction					(int species);
double		Stem_Tropism_Factor				(int species);
d3Vector	Stem_Tropism_Direction			(int species);
double		Stem_Lamdacx					(int species);
double		Stem_Lamdacy					(int species);
double		Stem_Gamma						(int species);
double		Stem_Moisture					(int species);

Complex		vegetation_permittivity			(double moisture, double frequency);

double		Primary_Radius					(int species, double height, double t);

double		Primary_Tropism_Factor			(int species);
d3Vector	Primary_Tropism_Direction		(int species);
double		Primary_Lamdacx					(int species);
double		Primary_Lamdacy					(int species);
double		Primary_Gamma					(int species);
double		Primary_Moisture				(int species);
double		Primary_Dry_Moisture			(int species);

double		Secondary_Tropism_Factor		(int species);
d3Vector	Secondary_Tropism_Direction		(int species);
double		Secondary_Lamdacx				(int species);
double		Secondary_Lamdacy				(int species);
double		Secondary_Gamma					(int species);
double		Secondary_Moisture				(int species);
double		Secondary_Dry_Moisture			(int species);

double		Tertiary_Branch_Volume_Fraction	(int species);
double		Tertiary_Branch_Moisture		(int species);

/***********/
/* Foliage */
/***********/

int			Leaf_Species					(int species);
double		Leaf_Volume_Fraction			(int species);
double		Leaf_Dimension_1				(int species);
double		Leaf_Dimension_2				(int species);
double		Leaf_Dimension_3				(int species);
double		Leaf_Moisture					(int species);

/***********************************/
/* NEW PARAMETRIC MODEL PARAMETERS */
/***********************************/

#define		POLSARPROSIM_HEDGE_TCRSCALE			1.00
#define		POLSARPROSIM_PINE001_TCRSCALE		0.90
#define		POLSARPROSIM_DECIDUOUS001_TCRSCALE	1.00

#define		POLSARPROSIM_PINE001_FR0		 0.24
#define		POLSARPROSIM_PINE001_DFR		-0.042
#define		POLSARPROSIM_PINE001_HFR		 9.00
#define		POLSARPROSIM_PINE001_DHFR		 5.00

#define		POLSARPROSIM_PINE001_FL0		 1.0
#define		POLSARPROSIM_PINE001_DFL		-0.27
#define		POLSARPROSIM_PINE001_HFL		 10.3
#define		POLSARPROSIM_PINE001_DHFL		 4.80

#define		POLSARPROSIM_PINE001_FD0		 0.855
#define		POLSARPROSIM_PINE001_DFD		-0.252
#define		POLSARPROSIM_PINE001_HFD		 14.2
#define		POLSARPROSIM_PINE001_DHFD		 6.00

#define		POLSARPROSIM_PINE001_FPMN0		 40.0
#define		POLSARPROSIM_PINE001_DFPMN		 6.40
#define		POLSARPROSIM_PINE001_HFPMN		 5.60
#define		POLSARPROSIM_PINE001_DHFPMN		 2.50

#define		POLSARPROSIM_PINE001_FPMX0		 63.0
#define		POLSARPROSIM_PINE001_DFPMX		 19.5
#define		POLSARPROSIM_PINE001_HFPMX		 8.25
#define		POLSARPROSIM_PINE001_DHFPMX		 3.50

/********************************************************************/
/* Change these values to increase secondary branch volume fraction */
/********************************************************************/
/*
#define		POLSARPROSIM_PINE001_MNS		15.94225
#define		POLSARPROSIM_PINE001_CNS		-4.26094
*/
#define		POLSARPROSIM_PINE001_MNS		18.95864
#define		POLSARPROSIM_PINE001_CNS		-4.26094

#define		POLSARPROSIM_PINE001_PGAMMA		0.08
#define		POLSARPROSIM_PINE001_PALPHA		0.55
#define		POLSARPROSIM_PINE001_PBETA		2.00
#define		POLSARPROSIM_PINE001_PL0		0.33
#define		POLSARPROSIM_PINE001_PT			0.935
#define		POLSARPROSIM_PINE001_PBETAP		4.0

#define		POLSARPROSIM_PINE001_THETAS_AVG	1.078614
#define		POLSARPROSIM_PINE001_THETAS_STD	0.228638

#define		POLSARPROSIM_PINE001_MLS		0.3902
#define		POLSARPROSIM_PINE001_CLS		0.3910

/************************************************************************************/
/* This value introduced after correcting secondary branch radius parametric coding */
/************************************************************************************/
#define		POLSARPROSIM_PINE001_SBLSCALING	1.419899

#define		POLSARPROSIM_PINE001_FSRA0		0.513767
#define		POLSARPROSIM_PINE001_FSRA1		-0.12397
#define		POLSARPROSIM_PINE001_FSRA2		-0.07023
#define		POLSARPROSIM_PINE001_FSRA3		-0.30297

/*********************************************************************************/
/* This value changed after correcting secondary branch radius parametric coding */
/*********************************************************************************/
/*
#define		POLSARPROSIM_PINE001_FSRB0		1.000000
*/
#define		POLSARPROSIM_PINE001_FSRB0		1.30328

#endif
