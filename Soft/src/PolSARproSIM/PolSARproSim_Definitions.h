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
 * Module      : PolSARproSim_Definitions.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Definitions for PolSARproSim
 */
#ifndef __POLSARPROSIM_DEFINITIONS_H__
#define __POLSARPROSIM_DEFINITIONS_H__

#define	NO_POLSARPROSIM_ERRORS					0		/* Good result return value										*/
#define POLSARPROSIM_MAX_PROGRESS				15		/* Maximum value reached by the progress indicator accumulator	*/

#define	POLSARPRO_CONVENTION							/* Controls filenames, output format and calling convention		*/
#define	POLSARPROSIM_ROTATED_IMAGES						/* Rotates images if defined when POLSARPRO_CONVENTION is OFF	*/

/****************************/
/* Tree species enumeration */
/****************************/

#define	POLSARPROSIM_HEDGE						0		/* The "hedge" (deciduous, homogeneous cylinder)				*/
#define	POLSARPROSIM_PINE001					1		/* Homemade Scots Pine with Spheroidal crown					*/
#define	POLSARPROSIM_PINE002					2		/* Homemade Scots Pine with Conical crown						*/
#define	POLSARPROSIM_PINE003					3		/* Homemade Scots Pine with 50% pY Spheroidal/Conical crown		*/
#define	POLSARPROSIM_DECIDUOUS001				4		/* A Deciduous tree												*/
#define POLSARPROSIM_NULL_SPECIES				99		/* Not a tree type, just an initialisation value				*/

/**************************************/
/* Tree species allometric parameters */
/**************************************/

#define	TREE_STDDEV_FACTOR								0.050	/* Standard deviation as a fraction of the mean for Guassian variables	*/
#define	POLSARPROSIM_TERTIARY_STDEV_FACTOR				0.050
#define	POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH		1.500	/* 1.500 */
#define	POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS		0.011	/* 0.015 */

/*******************************/
/* Scene generation parameters */
/*******************************/

#define	RESOLUTION_GAP_SIZE						10.0	/* Amount of SAR image border specified in mean resolutions				*/

/*****************************************/
/* Large scale ground surface generation */
/*****************************************/

#define	POLSARPROSIM_GROUND_FOURIER_MOMENTS		10

/*********************************/
/* Surface parameter calculation */
/*********************************/

/*************************************/
/* New trial surface roughness model */
/*************************************/

#define	POLSARPROSIM_MINRDB						-0.4
#define	POLSARPROSIM_MIDRDB						-6.4
#define	POLSARPROSIM_MAXRDB						-22.4

/*#define	POLSARPROSIM_MINRDB						-6.4	*/
/* Increased this to -6.4 from -10.4 whilst debugging PolInSAR response */
/*#define	POLSARPROSIM_MAXRDB						-22.4	*/

#define	POLSARPROSIM_DEFAULT_SURFACE_ALPHA		 0.06
#define	POLSARPROSIM_DEFAULT_SIGMA0HH			-28.0

#define	POLSARPROSIM_SIGMA0HHL45				-28.0
#define	POLSARPROSIM_SIGMA0HHP45				-38.0
#define	POLSARPROSIM_LBAND						 1.3000
#define	POLSARPROSIM_PBAND						 0.4333
#define	POLSARPROSIM_DELTAS0HHDB				 3.00

/****************************/
/* Tree location generation */
/****************************/

#define	TREE_DISC_SHUFFLE_RADIUS_FACTOR			0.95
#define	TREE_LOCATION_NEAREST_NEIGHBOURS		6
#define	TREE_DISC_SHUFFLE_FACTOR				0.8
#define	TREE_DISC_ACCEPTANCE_RATE				0.90
#define	TREE_DISC_ILOOP_MAX						2000
#define TREE_DISC_JLOOP_MAX						1
#define	TREE_DISC_TEMP_FACTOR					1.0
#define	TREE_DISC_TEMP_ALPHA					9.0
#define	TREE_DISC_ROTATION_ANGLE				22.5
#define	TREE_DISC_NIMAGES						1

/*****************************/
/* Tree realisation controls */
/*****************************/

#define	POLSARPROSIM_HEDGE_TERTIARY_FACTOR				10.0		/* Scale factors controlling the number of tertiary branch		*/
#define	POLSARPROSIM_PINE001_TERTIARY_FACTOR			10.0		/* elements generated during the realisation of a single tree	*/
#define	POLSARPROSIM_PINE002_TERTIARY_FACTOR			10.0
#define	POLSARPROSIM_PINE003_TERTIARY_FACTOR			10.0
#define	POLSARPROSIM_DECIDUOUS001_TERTIARY_FACTOR		10.0

#define	POLSARPROSIM_HEDGE_FOLIAGE_FACTOR				10.0		/* Scale factors controlling the number of leaves				*/
#define	POLSARPROSIM_PINE001_FOLIAGE_FACTOR				10.0		/* generated during the realisation of a single tree			*/
#define	POLSARPROSIM_PINE002_FOLIAGE_FACTOR				10.0
#define	POLSARPROSIM_PINE003_FOLIAGE_FACTOR				10.0
#define	POLSARPROSIM_DECIDUOUS001_FOLIAGE_FACTOR		10.0

/********************************************************/
/* Nominal tertiary and foliage realisation definitions */
/********************************************************/

#define	POLSARPROSIM_NOMINAL_TERTIARY_NUMBER			10
#define	POLSARPROSIM_NOMINAL_FOLIAGE_NUMBER				10

/*********************************************/
/* Short vegetation layer default parameters */
/*********************************************/

#define	DEFAULT_SHORT_VEGI_DEPTH				0.30
#define	DEFAULT_SHORT_VEGI_STEM_VOL_FRAC		0.004
#define	DEFAULT_SHORT_VEGI_LEAF_VOL_FRAC		0.0005

#define POLSARPROSIM_SHORTV_STEM_LENGTH			0.30
#define POLSARPROSIM_SHORTV_STEM_RADIUS			0.0025

#define POLSARPROSIM_SHORTV_LEAF_LENGTH			0.05
#define POLSARPROSIM_SHORTV_LEAF_WIDTH			0.033
#define POLSARPROSIM_SHORTV_LEAF_THICKNESS		0.002

/****************************************************/
/* Graphic image rendering (ground is always drawn) */
/****************************************************/

#define	FOREST_GRAPHIC_DRAW_STEM
/* Draw tree stems in graphic image if defined			*/
#define	FOREST_GRAPHIC_DRAW_CROWN
/* Draw tree crowns in graphic image if defined			*/

/************************************/
/* Graphic image rendering controls */
/************************************/

#define	FOREST_GRAPHIC_NY						512
#define	FOREST_NEAR_PLANE_FACTOR				3
#define	FOREST_GRAPHIC_IMAGE_SIZE_FACTOR		1.2
#define	FOREST_LIGHT_POLAR_ANGLE				30.0
#define	FOREST_LIGHT_AZIMUTH_ANGLE				45.0
#define	FOREST_GRAPHIC_AMBIENT_INTENSITY		0.2
#define	FOREST_GRAPHIC_INCIDENT_INTENSITY		0.8
#define	FOREST_GRAPHIC_DEPTH_CUE
#define	FOREST_GRAPHIC_MIN_CUE					0.5f
#define	FOREST_GRAPHIC_CROWN_ALPHA_BLEND		0.2
#define	FOREST_GRAPHIC_SHORTV_ALPHA_BLEND		0.2
#define	FOREST_GRAPHIC_SHORTV_FACTOR			10
#define	FOREST_GRAPHIC_SHORTV_STEM_FRACTION		0.5			/* Used in drawing of short vegetation layer elements	*/
#define FOREST_GRAPHIC_TERTIARY_NUMBER			200			/* The max number of tertiaries per crown drawing		*/
#define	FOREST_GRAPHIC_HEDGE_TERTIARY_SCALING	10			/* More if the hedge is being drawn						*/

#define	FOREST_GRAPHIC_BACKGROUND_RED			128
#define	FOREST_GRAPHIC_BACKGROUND_GREEN			128
#define	FOREST_GRAPHIC_BACKGROUND_BLUE			255

/*************************************/
/* Graphic image material properties */
/*************************************/

#define	FOREST_GRAPHIC_GROUND_KA				1.0
#define	FOREST_GRAPHIC_GROUND_KD				1.0
#define	FOREST_GRAPHIC_GROUND_KS				5.0
#define	FOREST_GRAPHIC_GROUND_SR				0.65
#define	FOREST_GRAPHIC_GROUND_SG				1.0
#define	FOREST_GRAPHIC_GROUND_SB				0.65

#define	FOREST_GRAPHIC_SHORTV_KA				1.0
#define	FOREST_GRAPHIC_SHORTV_KD				1.0
#define	FOREST_GRAPHIC_SHORTV_KS				5.0
#define	FOREST_GRAPHIC_SHORTV_SR				0.85
#define	FOREST_GRAPHIC_SHORTV_SG				0.65
#define	FOREST_GRAPHIC_SHORTV_SB				1.0

#define	FOREST_GRAPHIC_BRANCH_KA				1.0
#define	FOREST_GRAPHIC_BRANCH_KD				1.0
#define	FOREST_GRAPHIC_BRANCH_KS				5.0
#define	FOREST_GRAPHIC_BRANCH_SR				1.0
#define	FOREST_GRAPHIC_BRANCH_SG				0.95
#define	FOREST_GRAPHIC_BRANCH_SB				0.5

#define	FOREST_GRAPHIC_LCROWN_KA				1.0
#define	FOREST_GRAPHIC_LCROWN_KD				1.0
#define	FOREST_GRAPHIC_LCROWN_KS				1.0
#define	FOREST_GRAPHIC_LCROWN_SR				1.0
#define	FOREST_GRAPHIC_LCROWN_SG				0.5
#define	FOREST_GRAPHIC_LCROWN_SB				0.5

#define	FOREST_GRAPHIC_DCROWN_KA				1.0
#define	FOREST_GRAPHIC_DCROWN_KD				1.0
#define	FOREST_GRAPHIC_DCROWN_KS				5.0
#define	FOREST_GRAPHIC_DCROWN_SR				0.5
#define	FOREST_GRAPHIC_DCROWN_SG				0.5
#define	FOREST_GRAPHIC_DCROWN_SB				0.5

#define	FOREST_GRAPHIC_LEAF_KA					1.0
#define	FOREST_GRAPHIC_LEAF_KD					1.0
#define	FOREST_GRAPHIC_LEAF_KS					5.0
#define	FOREST_GRAPHIC_LEAF_SR					0.5
#define	FOREST_GRAPHIC_LEAF_SG					1.0
#define	FOREST_GRAPHIC_LEAF_SB					0.3

/*********************************/
/* Graphic image tree parameters */
/*********************************/

#define FOREST_GRAPHIC_MIN_BRANCH_SIDES			6
#define FOREST_GRAPHIC_MAX_BRANCH_SIDES			12
#define FOREST_GRAPHIC_MIN_BRANCH_SECTIONS		6
#define FOREST_GRAPHIC_MAX_BRANCH_SECTIONS		12
#define FOREST_GRAPHIC_MIN_CROWN_SIDES			12
#define FOREST_GRAPHIC_MAX_CROWN_SIDES			24
#define FOREST_GRAPHIC_MIN_CROWN_SECTIONS		12
#define FOREST_GRAPHIC_MAX_CROWN_SECTIONS		24

/*****************/
/* Miscellaneous */
/*****************/

#define	ROUNDING_ERROR							FLT_EPSILON			/* Used in the ray intersection routines for branch creation	*/
#define	LIGHT_SPEED								0.299792458			/* The speed of light in vacuum in convenient units of 10^9m/s	*/

/***************************************/
/* Ground surface description controls */
/***************************************/

#define	DEFAULT_GROUND_MV						0.25				/* Default soil volumetric warer content						*/
#define	INPUT_GROUND_MV												/* Read soil moisture model from input file if #defined			*/
#define	MIN_GROUND_MV							0.1					/* Minimum permissible soil moisture value						*/
#define	MAX_GROUND_MV							0.3					/* Maximum permissible soil moisture value						*/

/******************************/
/* Attenuation and scattering */
/******************************/

#define	POLSARPROSIM_SHORT_VEGI_NTHETA			51
#define	POLSARPROSIM_SHORT_VEGI_NPHI			101
#define	POLSARPROSIM_ATTENUATION_TREES			5
#define	POLSARPROSIM_TERTIARY_NTHETA			51
#define	POLSARPROSIM_TERTIARY_NPHI				101
#define	GRG_VALIDITY_FACTOR						0.1			/* Used to decide scattering model for tertiary branches		*/
#define	AMAP_RESOLUTION_FACTOR					1.0			/* Determines the size of the attenuation map grid				*/
#define	AMAP_SHORT_VEGI_NZ						10			/* Length of short vegi attenuation depth look-up table			*/
#define	NO_DIRECT_ATTENUATION_LOOKUP_ERRORS		0			/* Good return value when looking up direct attenuation values	*/

/*************************/
/* SAR image calculation */
/*************************/

#define DEFAULT_RESOLUTION_SAMPLING_FACTOR		0.6667			/* Ratio of pixel dimension to resolution, default 2/3	*/
#define	POWER_AT_PSF_EDGE						0.0001			/* Helps fix the extent to which the PSF is calculated	*/

/**********************************************/
/* Direct ground surface backscatter controls */
/**********************************************/

#define	POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR	2			/* Controls how many facets there are per resolution cell: n = 4f^2, f=2, n=16	*/
#define	POLSARPROSIM_DIRECTGROUND_DELTAB_FACTOR		15.0		/* Beta rotation angle factor for increased entropy	(range 0-100, default 33.0)	*/

/*****************************/
/* Short vegetation controls */
/*****************************/

#define	POLSARPROSIM_SHORT_VEGI_REALISATIONS		30			/* Number of short vegi elements realised in each resolution cell by species	*/

/***************************************/
/* Rayleigh reflection roughness model */
/***************************************/

#define	POLSARPROSIM_RAYLEIGH_ROUGHNESS_MODEL		2			/* 0: Large-scale only, 1: Small-sacle only, 2: Combined						*/

/*******************/
/* Forest controls */
/*******************/

#define	POLSARPROSIM_SAR_BRANCH_FACTOR					0.5			/* Controls the length of branch subdivisions in calculating SAR images			*/

#define	POLSARPROSIM_HEDGE_SAR_TERTIARY_FACTOR			120.0		/* Scale factors controlling the number of tertiary branch		*/
#define	POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR		120.0		/* elements generated during the realisation of a single tree	*/
#define	POLSARPROSIM_PINE002_SAR_TERTIARY_FACTOR		120.0		/* for the purposes of SAR image generation rather than simply	*/
#define	POLSARPROSIM_PINE003_SAR_TERTIARY_FACTOR		120.0		/* graphic rendering of the cartoon forest image.				*/
#define	POLSARPROSIM_DECIDUOUS001_SAR_TERTIARY_FACTOR	120.0		/* This is the number of realisations per pixel area for crowns	*/

#define	POLSARPROSIM_HEDGE_SAR_FOLIAGE_FACTOR			30.0		/* Scale factors controlling the number of foliage elements		*/
#define	POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR			30.0		/* generated during the realisation of a single tree			*/
#define	POLSARPROSIM_PINE002_SAR_FOLIAGE_FACTOR			30.0		/* for the purposes of SAR image generation rather than simply	*/
#define	POLSARPROSIM_PINE003_SAR_FOLIAGE_FACTOR			30.0		/* graphic rendering of the cartoon forest image.				*/
#define	POLSARPROSIM_DECIDUOUS001_SAR_FOLIAGE_FACTOR	30.0		/* This is the number of realisations per pixel area for crowns	*/

#define	POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES			0			/* Flag values for choice of scattering model					*/
#define	POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES			1

/*******************************/
/* Acceptance testing controls */
/*******************************/

#define	SWITCH_ATTENUATION_ON
/* No attenuation effects if undefined							*/
/*#define	RAYLEIGH_LEAF										*/
/* Rayleigh scattering for short vegi and foliage if defined	*/

/*****************************************************************/
/* Commented-out definitions collected here to ease compilation  */
/*****************************************************************/

/*#define	VERBOSE_POLSARPROSIM								*/
/* Lots of output to stdout if this is defined					*/

/****************************************************/
/* Graphic image rendering (ground is always drawn) */
/****************************************************/

/*#define	FOREST_GRAPHIC_DRAW_SHORTV_ELEMENTS					*/
/* Draw a few leaves and stems in the understorey				*/
/*#define	FOREST_GRAPHIC_DRAW_SHORTV_SURFACE					*/
/* Draw the surface of the short vegetation layer				*/
/*#define	FOREST_GRAPHIC_DRAW_PRIMARY							*/
/* Draw primary branches in graphic image if defined			*/
/*#define	FOREST_GRAPHIC_DRAW_SECONDARY						*/
/* Draw secondary branches in graphic image if defined			*/
/*#define	FOREST_GRAPHIC_DRAW_TERTIARY						*/
/* Draw tertiary elements in graphic image if defined			*/
/*#define	FOREST_GRAPHIC_DRAW_FOLIAGE							*/
/* Draw foliage elements in graphic image if defined			*/

/*******************/
/* Forest controls */
/*******************/

/*#define	POLSARPROSIM_VERBOSE_TERTIARY						*/
/* Details hybrid method RCS scalings if defined				*/
/*#define	POLSARPROSIM_VERBOSE_FOLIAGE						*/
/* Details hybrid method RCS scalings if defined				*/

/*******************/
/* DEBUGGING FLAGS */
/*******************/

/*#define	FLAT_DEM											*/
/* Leaves the ground tilted but flat if defined					*/
/*#define	NO_TREE_SHUFFLING									*/
/* Leaves the tree locations on the initial grid if defined		*/
/*#define	FORCE_GRG_CYLINDERS									*/
/* Much faster when debugging									*/
/*#define	NO_SHORT_LEAVES										*/
/* Switch off short vegi leaf contribution						*/
/*#define	NO_SHORT_STEMS										*/
/* Switch off short vegi leaf contribution						*/
/*#define	POLSARPROSIM_NO_SAR_STEMS							*/
/* No stem scattering if defined								*/
/*#define	POLSARPROSIM_NO_SAR_PRIMARIES						*/
/* No primary scattering if defined								*/
/*#define	POLSARPROSIM_NO_SAR_SECONDARIES						*/
/* No secondary scattering if defined							*/
/*#define	POLSARPROSIM_NO_SAR_TERTIARIES						*/
/* No tertiary scattering if defined							*/
/*#define	POLSARPROSIM_NO_SAR_FOLIAGE							*/
/* No foliage scattering if defined								*/

/*****************************/
/* Stage 3 development flags */
/*****************************/

/*#define		POLSARPROSIM_STAGE3								*/
/* Required when setting up tree parameters						*/

#define		POLSARPROSIM_CROWN_OVERLAP_FACTOR		0.892489		
/* Increases the maximum permissible number of trees and permits crowns to overlap					*/
/* Note there is a link between this parameter and POLSARPROSIM_PINE001_TCRSCALE in Allometrics.h	*/

#define		POLSARPROSIM_NOGRIOUTPUT
/* Will turn off the facility to ouput GRI format images if defined */
#define		POLSARPROSIM_NOSIMOUTPUT
/* Will turn off the facility to ouput SIM format images if defined */

/****************************************/
/* Optional flat earth phase correction */
/****************************************/

/*#define		POLSARPROSIM_FLATEARTH								*/
/* Will scale images by exp (-j 2kr) if defined						*/

/***********************************************/
/* Stem subdivision control for low-resolution */
/***********************************************/

#define	POLSARPROSIM_MIN_STEM_SEG_NUM			10

#endif
