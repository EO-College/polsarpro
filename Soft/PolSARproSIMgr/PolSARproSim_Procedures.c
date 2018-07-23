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
 * Module      : PolSARproSim_Procedures.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Procedure implementations for PolSARproSim
 */
#include	"PolSARproSim_Procedures.h"

/*****************/
/* House keeping */
/*****************/

void	PolSARproSim_notice			(FILE *fp)
{
 fprintf (fp, "\n");
 fprintf (fp, "************************************************************************\n");
 fprintf (fp, "*                                                                      *\n");
 fprintf (fp, "* PolSARproSim Version C1b  Forest Synthetic Aperture Radar Simulation *\n");
 fprintf (fp, "* Copyright (C) 2007 Mark L. Williams (mark.williams@physics.org)      *\n");
 fprintf (fp, "*                                                                      *\n");
 fprintf (fp, "* PolSARproSim Version C1b  is free software; you may redistribute it  *\n");
 fprintf (fp, "* and/or modify it under the terms of the GNU General Public License   *\n");
 fprintf (fp, "* as published by the Free Software Foundation; either version 2       *\n");
 fprintf (fp, "* of the License, or (at your option) any later version.               *\n");
 fprintf (fp, "*                                                                      *\n");
 fprintf (fp, "* PolSARproSim Version C1b  is distributed in the hope that it will be *\n");
 fprintf (fp, "* useful,but WITHOUT ANY WARRANTY; without even the implied warranty   *\n");
 fprintf (fp, "* of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.              *\n");
 fprintf (fp, "* See the GNU General Public License for more details.                 *\n");
 fprintf (fp, "*                                                                      *\n");
 fprintf (fp, "* You should have received a copy of the GNU General Public License    *\n");
 fprintf (fp, "* along with this program; if not, write to the Free Software          *\n");
 fprintf (fp, "* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,           *\n");
 fprintf (fp, "* MA  02110-1301, USA. (http://www.gnu.org/copyleft/gpl.html)          *\n");
 fprintf (fp, "*                                                                      *\n");
 fprintf (fp, "************************************************************************\n");
 fprintf (fp, "\n");
 fflush  (fp);
 return;
}

void	PolSARproSim_compile_options (FILE *fp)
{
 int	i;
 double	d;
 float	f;
/********************************/
/* Housekeeping and conventions */
/********************************/
 fprintf (fp, "\nCompile options report ...\n\n");
 i		= NO_POLSARPROSIM_ERRORS;
 fprintf (fp, "NO_POLSARPROSIM_ERRORS\t%d\n", i);
#ifdef	VERBOSE_POLSARPROSIM
 fprintf (fp, "VERBOSE_POLSARPROSIM\n");
#endif
#ifdef POLSARPROSIM_MAX_PROGRESS
 i		= POLSARPROSIM_MAX_PROGRESS;
 fprintf (fp, "POLSARPROSIM_MAX_PROGRESS\t\t%d\n", i);
#endif
#ifdef POLSARPRO_CONVENTION
 fprintf (fp, "POLSARPRO_CONVENTION\n");
#endif
#ifdef POLSARPROSIM_ROTATED_IMAGES
 fprintf (fp, "POLSARPROSIM_ROTATED_IMAGES\n\n");
#endif
/****************************/
/* Tree species enumeration */
/****************************/
 i		= 	POLSARPROSIM_HEDGE;
 fprintf (fp, "POLSARPROSIM_HEDGE\t\t%d\n", i);
 i		= 	POLSARPROSIM_PINE001;
 fprintf (fp, "POLSARPROSIM_PINE001\t\t%d\n", i);
 i		= 	POLSARPROSIM_PINE002;
 fprintf (fp, "POLSARPROSIM_PINE002\t\t%d\n", i);
 i		= 	POLSARPROSIM_PINE003;
 fprintf (fp, "POLSARPROSIM_PINE003\t\t%d\n", i);
 i		= 	POLSARPROSIM_DECIDUOUS001;
 fprintf (fp, "POLSARPROSIM_DECIDUOUS001\t%d\n", i);
 i		=  POLSARPROSIM_NULL_SPECIES;
 fprintf (fp, "POLSARPROSIM_NULL_SPECIES\t%d\n\n", i);
/**************************************/
/* Tree species allometric parameters */
/**************************************/
 d		= 	TREE_STDDEV_FACTOR;
 fprintf (fp, "TREE_STDDEV_FACTOR\t\t\t\t\t%lf\n", d);
 d		= 	POLSARPROSIM_TERTIARY_STDEV_FACTOR;
 fprintf (fp, "POLSARPROSIM_TERTIARY_STDEV_FACTOR\t\t\t%lf\n", d);
 d		= 	POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH;
 fprintf (fp, "POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH\t\t%lf\n", d);
 d		= 	POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS;
 fprintf (fp, "POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS\t\t%lf\n\n", d);
/*******************************/
/* Scene generation parameters */
/*******************************/
 d		= 	RESOLUTION_GAP_SIZE;
 fprintf (fp, "RESOLUTION_GAP_SIZE\t%lf\n\n", d);
/*****************************************/
/* Large scale ground surface generation */
/*****************************************/
 i		= POLSARPROSIM_GROUND_FOURIER_MOMENTS;
 fprintf (fp, "POLSARPROSIM_GROUND_FOURIER_MOMENTS\t%d\n\n", i);
/*********************************/
/* Surface parameter calculation */
/*********************************/
 d		= 	POLSARPROSIM_MINRDB;
 fprintf (fp, "POLSARPROSIM_MINRDB\t%lf\n", d);
 d		= 	POLSARPROSIM_MAXRDB;
 fprintf (fp, "POLSARPROSIM_MAXRDB\t%lf\n", d);
 d		= 	POLSARPROSIM_DEFAULT_SURFACE_ALPHA;
 fprintf (fp, "POLSARPROSIM_DEFAULT_SURFACE_ALPHA\t%lf\n", d);
 d		= 	POLSARPROSIM_DEFAULT_SIGMA0HH;
 fprintf (fp, "POLSARPROSIM_DEFAULT_SIGMA0HH\t%lf\n", d);
 d		= 	POLSARPROSIM_SIGMA0HHL45;
 fprintf (fp, "POLSARPROSIM_SIGMA0HHL45\t%lf\n", d);
 d		= 	POLSARPROSIM_SIGMA0HHP45;
 fprintf (fp, "POLSARPROSIM_SIGMA0HHP45\t%lf\n", d);
 d		= 	POLSARPROSIM_LBAND;
 fprintf (fp, "POLSARPROSIM_LBAND\t%lf\n", d);
 d		= 	POLSARPROSIM_PBAND;
 fprintf (fp, "POLSARPROSIM_PBAND\t%lf\n", d);
 d		= 	POLSARPROSIM_DELTAS0HHDB;
 fprintf (fp, "POLSARPROSIM_DELTAS0HHDB\t%lf\n", d);
/****************************/
/* Tree location generation */
/****************************/
 d		= 	TREE_DISC_SHUFFLE_RADIUS_FACTOR;
 fprintf (fp, "TREE_DISC_SHUFFLE_RADIUS_FACTOR\t%lf\n", d);
 i		= 	TREE_LOCATION_NEAREST_NEIGHBOURS;
 fprintf (fp, "TREE_LOCATION_NEAREST_NEIGHBOURS\t%d\n", i);
 d		= 	TREE_DISC_SHUFFLE_FACTOR;
 fprintf (fp, "TREE_DISC_SHUFFLE_FACTOR\t\t%lf\n", d);
 d		= 	TREE_DISC_ACCEPTANCE_RATE;
 fprintf (fp, "TREE_DISC_ACCEPTANCE_RATE\t\t%lf\n", d);
 i		= 	TREE_DISC_ILOOP_MAX;
 fprintf (fp, "TREE_DISC_ILOOP_MAX\t\t\t%d\n", i);
 i		=	TREE_DISC_JLOOP_MAX;
 fprintf (fp, "TREE_DISC_JLOOP_MAX\t\t\t%d\n", i);
 d		= 	TREE_DISC_TEMP_FACTOR;
 fprintf (fp, "TREE_DISC_TEMP_FACTOR\t\t\t%lf\n", d);
 d		= 	TREE_DISC_TEMP_ALPHA;
 fprintf (fp, "TREE_DISC_TEMP_ALPHA\t\t\t%lf\n", d);
 d		= 	TREE_DISC_ROTATION_ANGLE;
 fprintf (fp, "TREE_DISC_ROTATION_ANGLE\t\t%lf\n", d);
 i		= 	TREE_DISC_NIMAGES;
 fprintf (fp, "TREE_DISC_NIMAGES\t\t\t\t%d\n\n", i);
/*****************************/
/* Tree realisation controls */
/*****************************/
 d		= 	POLSARPROSIM_HEDGE_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_HEDGE_TERTIARY_FACTOR\t\t%lf\n", d);
 d		= 	POLSARPROSIM_PINE001_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE001_TERTIARY_FACTOR\t%lf\n", d);
 d		= 	POLSARPROSIM_PINE002_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE002_TERTIARY_FACTOR\t%lf\n", d);
 d		= 	POLSARPROSIM_PINE003_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE003_TERTIARY_FACTOR\t%lf\n", d);
 d		= 	POLSARPROSIM_DECIDUOUS001_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_DECIDUOUS001_TERTIARY_FACTOR\t%lf\n", d);
 d		= 	POLSARPROSIM_HEDGE_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_HEDGE_FOLIAGE_FACTOR\t\t%lf\n", d);
 d		= 	POLSARPROSIM_PINE001_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE001_FOLIAGE_FACTOR\t\t%lf\n", d);
 d		= 	POLSARPROSIM_PINE002_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE002_FOLIAGE_FACTOR\t\t%lf\n", d);
 d		= 	POLSARPROSIM_PINE003_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE003_FOLIAGE_FACTOR\t\t%lf\n", d);
 d		= 	POLSARPROSIM_DECIDUOUS001_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_DECIDUOUS001_FOLIAGE_FACTOR\t%lf\n\n", d);
/*****************************************/
/* Short vegetation realisation controls */
/*****************************************/
 d		=	DEFAULT_SHORT_VEGI_DEPTH;
 fprintf (fp, "DEFAULT_SHORT_VEGI_DEPTH\t\t%lf\n", d);
 d		=	DEFAULT_SHORT_VEGI_STEM_VOL_FRAC;
 fprintf (fp, "DEFAULT_SHORT_VEGI_STEM_VOL_FRAC\t\t%lf\n", d);
 d		=	DEFAULT_SHORT_VEGI_LEAF_VOL_FRAC;
 fprintf (fp, "DEFAULT_SHORT_VEGI_LEAF_VOL_FRAC\t\t%lf\n", d);
 d		=	POLSARPROSIM_SHORTV_STEM_LENGTH;
 fprintf (fp, "POLSARPROSIM_SHORTV_STEM_LENGTH\t\t%lf\n", d);
 d		=	POLSARPROSIM_SHORTV_STEM_RADIUS;
 fprintf (fp, "POLSARPROSIM_SHORTV_STEM_RADIUS\t\t%lf\n", d);
 d		=	POLSARPROSIM_SHORTV_LEAF_LENGTH;
 fprintf (fp, "POLSARPROSIM_SHORTV_LEAF_LENGTH\t\t%lf\n", d);
 d		=	POLSARPROSIM_SHORTV_LEAF_WIDTH;
 fprintf (fp, "POLSARPROSIM_SHORTV_LEAF_WIDTH\t\t%lf\n", d);
 d		=	POLSARPROSIM_SHORTV_LEAF_THICKNESS;
 fprintf (fp, "POLSARPROSIM_SHORTV_LEAF_THICKNESS\t\t%lf\n\n", d);
/****************************************************/
/* Graphic image rendering (ground is always drawn) */
/****************************************************/
#ifdef	FOREST_GRAPHIC_DRAW_SHORTV_ELEMENTS
 fprintf (fp, "FOREST_GRAPHIC_DRAW_SHORTV_ELEMENTS\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_SHORTV_SURFACE
 fprintf (fp, "FOREST_GRAPHIC_DRAW_SHORTV_SURFACE\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_STEM
 fprintf (fp, "FOREST_GRAPHIC_DRAW_STEM\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_PRIMARY
 fprintf (fp, "FOREST_GRAPHIC_DRAW_PRIMARY\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_SECONDARY
 fprintf (fp, "FOREST_GRAPHIC_DRAW_SECONDARY\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_TERTIARY
 fprintf (fp, "FOREST_GRAPHIC_DRAW_TERTIARY\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_FOLIAGE
 fprintf (fp, "FOREST_GRAPHIC_DRAW_FOLIAGE\n");
#endif
#ifdef	FOREST_GRAPHIC_DRAW_CROWN
 fprintf (fp, "FOREST_GRAPHIC_DRAW_CROWN\n\n");
#endif
/************************************/
/* Graphic image rendering controls */
/************************************/
 i		=	FOREST_GRAPHIC_NY;
 fprintf (fp, "FOREST_GRAPHIC_NY\t%d\n", i);
 i		=	FOREST_NEAR_PLANE_FACTOR;
 fprintf (fp, "FOREST_NEAR_PLANE_FACTOR\t\t\t%d\n", i);
 d		=	FOREST_GRAPHIC_IMAGE_SIZE_FACTOR;
 fprintf (fp, "FOREST_GRAPHIC_IMAGE_SIZE_FACTOR\t\t%lf\n", d);
 d		=	FOREST_LIGHT_POLAR_ANGLE;
 fprintf (fp, "FOREST_LIGHT_POLAR_ANGLE\t\t\t%lf\n", d);
 d		=	FOREST_LIGHT_AZIMUTH_ANGLE;
 fprintf (fp, "FOREST_LIGHT_AZIMUTH_ANGLE\t\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_AMBIENT_INTENSITY;
 fprintf (fp, "FOREST_GRAPHIC_AMBIENT_INTENSITY\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_INCIDENT_INTENSITY;
 fprintf (fp, "FOREST_GRAPHIC_INCIDENT_INTENSITY\t\t%lf\n", d);
#ifdef	FOREST_GRAPHIC_DEPTH_CUE
 fprintf (fp, "FOREST_GRAPHIC_DEPTH_CUE\n");
#endif
 f		=	FOREST_GRAPHIC_MIN_CUE;
 fprintf (fp, "FOREST_GRAPHIC_MIN_CUE\t\t\t\t%f\n", f);
 d		=	FOREST_GRAPHIC_CROWN_ALPHA_BLEND;
 fprintf (fp, "FOREST_GRAPHIC_CROWN_ALPHA_BLEND\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_ALPHA_BLEND;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_ALPHA_BLEND\t\t%lf\n", d);
 i		=	FOREST_GRAPHIC_SHORTV_FACTOR;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_FACTOR\t\t\t%d\n", i);
 d		= 	FOREST_GRAPHIC_SHORTV_STEM_FRACTION;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_STEM_FRACTION\t\t%lf\n", d);
 i		=	FOREST_GRAPHIC_TERTIARY_NUMBER;
 fprintf (fp, "FOREST_GRAPHIC_TERTIARY_NUMBER\t\t%d\n", i);
 i		=	FOREST_GRAPHIC_HEDGE_TERTIARY_SCALING;
 fprintf (fp, "FOREST_GRAPHIC_HEDGE_TERTIARY_SCALING\t%d\n", i);
 i		=	FOREST_GRAPHIC_BACKGROUND_RED;
 fprintf (fp, "FOREST_GRAPHIC_BACKGROUND_RED\t\t\t%d\n", i);
 i		=	FOREST_GRAPHIC_BACKGROUND_GREEN;
 fprintf (fp, "FOREST_GRAPHIC_BACKGROUND_GREEN\t\t%d\n", i);
 i		=	FOREST_GRAPHIC_BACKGROUND_BLUE;
 fprintf (fp, "FOREST_GRAPHIC_BACKGROUND_BLUE\t\t%d\n\n", i);
/*************************************/
/* Graphic image material properties */
/*************************************/
 d		=	FOREST_GRAPHIC_GROUND_KA;
 fprintf (fp, "FOREST_GRAPHIC_GROUND_KA\t%lf\n", d);
 d		=	FOREST_GRAPHIC_GROUND_KD;
 fprintf (fp, "FOREST_GRAPHIC_GROUND_KD\t%lf\n", d);
 d		=	FOREST_GRAPHIC_GROUND_KS;
 fprintf (fp, "FOREST_GRAPHIC_GROUND_KS\t%lf\n", d);
 d		=	FOREST_GRAPHIC_GROUND_SR;
 fprintf (fp, "FOREST_GRAPHIC_GROUND_SR\t%lf\n", d);
 d		=	FOREST_GRAPHIC_GROUND_SG;
 fprintf (fp, "FOREST_GRAPHIC_GROUND_SG\t%lf\n", d);
 d		=	FOREST_GRAPHIC_GROUND_SB;
 fprintf (fp, "FOREST_GRAPHIC_GROUND_SB\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_KA;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_KA\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_KD;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_KD\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_KS;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_KS\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_SR;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_SR\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_SG;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_SG\t%lf\n", d);
 d		=	FOREST_GRAPHIC_SHORTV_SB;
 fprintf (fp, "FOREST_GRAPHIC_SHORTV_SB\t%lf\n", d);
 d		=	FOREST_GRAPHIC_BRANCH_KA;
 fprintf (fp, "FOREST_GRAPHIC_BRANCH_KA\t%lf\n", d);
 d		=	FOREST_GRAPHIC_BRANCH_KD;
 fprintf (fp, "FOREST_GRAPHIC_BRANCH_KD\t%lf\n", d);
 d		=	FOREST_GRAPHIC_BRANCH_KS;
 fprintf (fp, "FOREST_GRAPHIC_BRANCH_KS\t%lf\n", d);
 d		=	FOREST_GRAPHIC_BRANCH_SR;
 fprintf (fp, "FOREST_GRAPHIC_BRANCH_SR\t%lf\n", d);
 d		=	FOREST_GRAPHIC_BRANCH_SG;
 fprintf (fp, "FOREST_GRAPHIC_BRANCH_SG\t%lf\n", d);
 d		=	FOREST_GRAPHIC_BRANCH_SB;
 fprintf (fp, "FOREST_GRAPHIC_BRANCH_SB\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LCROWN_KA;
 fprintf (fp, "FOREST_GRAPHIC_LCROWN_KA\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LCROWN_KD;
 fprintf (fp, "FOREST_GRAPHIC_LCROWN_KD\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LCROWN_KS;
 fprintf (fp, "FOREST_GRAPHIC_LCROWN_KS\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LCROWN_SR;
 fprintf (fp, "FOREST_GRAPHIC_LCROWN_SR\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LCROWN_SG;
 fprintf (fp, "FOREST_GRAPHIC_LCROWN_SG\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LCROWN_SB;
 fprintf (fp, "FOREST_GRAPHIC_LCROWN_SB\t%lf\n", d);
 d		=	FOREST_GRAPHIC_DCROWN_KA;
 fprintf (fp, "FOREST_GRAPHIC_DCROWN_KA\t%lf\n", d);
 d		=	FOREST_GRAPHIC_DCROWN_KD;
 fprintf (fp, "FOREST_GRAPHIC_DCROWN_KD\t%lf\n", d);
 d		=	FOREST_GRAPHIC_DCROWN_KS;
 fprintf (fp, "FOREST_GRAPHIC_DCROWN_KS\t%lf\n", d);
 d		=	FOREST_GRAPHIC_DCROWN_SR;
 fprintf (fp, "FOREST_GRAPHIC_DCROWN_SR\t%lf\n", d);
 d		=	FOREST_GRAPHIC_DCROWN_SG;
 fprintf (fp, "FOREST_GRAPHIC_DCROWN_SG\t%lf\n", d);
 d		=	FOREST_GRAPHIC_DCROWN_SB;
 fprintf (fp, "FOREST_GRAPHIC_DCROWN_SB\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LEAF_KA;
 fprintf (fp, "FOREST_GRAPHIC_LEAF_KA\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LEAF_KD;
 fprintf (fp, "FOREST_GRAPHIC_LEAF_KD\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LEAF_KS;
 fprintf (fp, "FOREST_GRAPHIC_LEAF_KS\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LEAF_SR;
 fprintf (fp, "FOREST_GRAPHIC_LEAF_SR\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LEAF_SG;
 fprintf (fp, "FOREST_GRAPHIC_LEAF_SG\t\t%lf\n", d);
 d		=	FOREST_GRAPHIC_LEAF_SB;
 fprintf (fp, "FOREST_GRAPHIC_LEAF_SB\t\t%lf\n\n", d);
/*********************************/
/* Graphic image tree parameters */
/*********************************/
 i		=	FOREST_GRAPHIC_MIN_BRANCH_SIDES;
 fprintf (fp, "FOREST_GRAPHIC_MIN_BRANCH_SIDES\t%d\n", i);
 i		=	FOREST_GRAPHIC_MAX_BRANCH_SIDES;
 fprintf (fp, "FOREST_GRAPHIC_MAX_BRANCH_SIDES\t%d\n", i);
 i		=	FOREST_GRAPHIC_MIN_BRANCH_SECTIONS;
 fprintf (fp, "FOREST_GRAPHIC_MIN_BRANCH_SECTIONS\t%d\n", i);
 i		=	FOREST_GRAPHIC_MAX_BRANCH_SECTIONS;
 fprintf (fp, "FOREST_GRAPHIC_MAX_BRANCH_SECTIONS\t%d\n", i);
 i		=	FOREST_GRAPHIC_MIN_CROWN_SIDES;
 fprintf (fp, "FOREST_GRAPHIC_MIN_CROWN_SIDES\t%d\n", i);
 i		=	FOREST_GRAPHIC_MAX_CROWN_SIDES;
 fprintf (fp, "FOREST_GRAPHIC_MAX_CROWN_SIDES\t%d\n", i);
 i		=	FOREST_GRAPHIC_MIN_CROWN_SECTIONS;
 fprintf (fp, "FOREST_GRAPHIC_MIN_CROWN_SECTIONS\t%d\n", i);
 i		=	FOREST_GRAPHIC_MAX_CROWN_SECTIONS;
 fprintf (fp, "FOREST_GRAPHIC_MAX_CROWN_SECTIONS\t%d\n\n", i);
/********************************/
/* Ray intersection definitions */
/********************************/
 i		=	NO_RAYPLANE_ERRORS;
 fprintf (fp, "NO_RAYPLANE_ERRORS\t%d\n", i);
 i		=	NO_RAYCYLINDER_ERRORS;
 fprintf (fp, "NO_RAYCYLINDER_ERRORS\t%d\n", i);
 i		=	NO_RAYCONE_ERRORS;
 fprintf (fp, "NO_RAYCONE_ERRORS\t\t%d\n", i);
 i		=	NO_RAYSPHEROID_ERRORS;
 fprintf (fp, "NO_RAYSPHEROID_ERRORS\t%d\n", i);
 i		=	NO_RAYCROWN_ERRORS;
 fprintf (fp, "NO_RAYCROWN_ERRORS\t%d\n\n", i);
/*****************/
/* Miscellaneous */
/*****************/
 d		=	ROUNDING_ERROR;
 fprintf (fp, "ROUNDING_ERROR\t\t%13.6e\n", d);
 d		=	LIGHT_SPEED;
 fprintf (fp, "LIGHT_SPEED\t\t\t%lf\n\n", d);
/***************************************/
/* Ground surface description controls */
/***************************************/
 d		=	DEFAULT_GROUND_MV;
 fprintf (fp, "DEFAULT_GROUND_MV\t\t%lf\n", d);
#ifdef INPUT_GROUND_MV
 fprintf (fp, "INPUT_GROUND_MV\n");
#endif
 d		=	MIN_GROUND_MV;
 fprintf (fp, "MIN_GROUND_MV\t\t%lf\n", d);
 d		=	MAX_GROUND_MV;
 fprintf (fp, "MAX_GROUND_MV\t\t%lf\n\n", d);
/******************************/
/* Attenuation and scattering */
/******************************/
 i		=	POLSARPROSIM_SHORT_VEGI_NTHETA;
 fprintf (fp, "POLSARPROSIM_SHORT_VEGI_NTHETA\t%d\n", i);
 i		=	POLSARPROSIM_SHORT_VEGI_NPHI;
 fprintf (fp, "POLSARPROSIM_SHORT_VEGI_NPHI\t\t%d\n", i);
 i		=	POLSARPROSIM_ATTENUATION_TREES;
 fprintf (fp, "POLSARPROSIM_ATTENUATION_TREES\t%d\n", i);
 i		=	POLSARPROSIM_TERTIARY_NTHETA;
 fprintf (fp, "POLSARPROSIM_TERTIARY_NTHETA\t\t%d\n", i);
 i		=	POLSARPROSIM_TERTIARY_NPHI;
 fprintf (fp, "POLSARPROSIM_TERTIARY_NPHI\t\t%d\n", i);
 d		=	GRG_VALIDITY_FACTOR;
 fprintf (fp, "GRG_VALIDITY_FACTOR\t\t\t%lf\n", d);
 d		=	AMAP_RESOLUTION_FACTOR;
 fprintf (fp, "AMAP_RESOLUTION_FACTOR\t\t\t%lf\n", d);
 i		= AMAP_SHORT_VEGI_NZ;
 fprintf (fp, "AMAP_SHORT_VEGI_NZ\t\t\t%d\n", i);
 i		= NO_DIRECT_ATTENUATION_LOOKUP_ERRORS;
 fprintf (fp, "NO_DIRECT_ATTENUATION_LOOKUP_ERRORS\t%d\n\n", i);
/*************************/
/* SAR image calculation */
/*************************/
 d		=	DEFAULT_RESOLUTION_SAMPLING_FACTOR;
 fprintf (fp, "DEFAULT_RESOLUTION_SAMPLING_FACTOR\t\t%lf\n", d);
 d		=	POWER_AT_PSF_EDGE;
 fprintf (fp, "POWER_AT_PSF_EDGE\t\t\t\t\t%lf\n", d);
/**********************************************/
/* Direct ground surface backscatter controls */
/**********************************************/
 i		= POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR;
 fprintf (fp, "POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR\t%d\n", i);
 d		= POLSARPROSIM_DIRECTGROUND_DELTAB_FACTOR;
 fprintf (fp, "POLSARPROSIM_DIRECTGROUND_DELTAB_FACTOR\t%lf\n", d);
/*****************************/
/* Short vegetation controls */
/*****************************/
 i		=	POLSARPROSIM_SHORT_VEGI_REALISATIONS;
 fprintf (fp, "POLSARPROSIM_SHORT_VEGI_REALISATIONS\t%d\n", i);
/***************************************/
/* Rayleigh reflection roughness model */
/***************************************/
 i		=	POLSARPROSIM_RAYLEIGH_ROUGHNESS_MODEL;
 fprintf (fp, "POLSARPROSIM_RAYLEIGH_ROUGHNESS_MODEL\t%d\n\n", i);
/*******************/
/* Forest controls */
/*******************/
#ifdef	POLSARPROSIM_SAR_BRANCH_FACTOR
 d		= POLSARPROSIM_SAR_BRANCH_FACTOR;
 fprintf (fp, "POLSARPROSIM_SAR_BRANCH_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_HEDGE_SAR_TERTIARY_FACTOR
 d		= POLSARPROSIM_HEDGE_SAR_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_HEDGE_SAR_TERTIARY_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR
 d		= POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_PINE002_SAR_TERTIARY_FACTOR
 d		= POLSARPROSIM_PINE002_SAR_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE002_SAR_TERTIARY_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_PINE003_SAR_TERTIARY_FACTOR
 d		= POLSARPROSIM_PINE003_SAR_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE003_SAR_TERTIARY_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_DECIDUOUS001_SAR_TERTIARY_FACTOR
 d		= POLSARPROSIM_DECIDUOUS001_SAR_TERTIARY_FACTOR;
 fprintf (fp, "POLSARPROSIM_DECIDUOUS001_SAR_TERTIARY_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_HEDGE_SAR_FOLIAGE_FACTOR
 d		= POLSARPROSIM_HEDGE_SAR_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_HEDGE_SAR_FOLIAGE_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR
 d		= POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_PINE002_SAR_FOLIAGE_FACTOR
 d		= POLSARPROSIM_PINE002_SAR_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE002_SAR_FOLIAGE_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_PINE003_SAR_FOLIAGE_FACTOR
 d		= POLSARPROSIM_PINE003_SAR_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_PINE003_SAR_FOLIAGE_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_DECIDUOUS001_SAR_FOLIAGE_FACTOR
 d		= POLSARPROSIM_DECIDUOUS001_SAR_FOLIAGE_FACTOR;
 fprintf (fp, "POLSARPROSIM_DECIDUOUS001_SAR_FOLIAGE_FACTOR\t%lf\n", d);
#endif
#ifdef	POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES
 i		= POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES;
 fprintf (fp, "POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES\t%d\n", i);
#endif
#ifdef	POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES
 i		= POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES;
 fprintf (fp, "POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES\t%d\n", i);
#endif
#ifdef	POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (fp, "POLSARPROSIM_VERBOSE_TERTIARY\n");
#endif
#ifdef	POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (fp, "POLSARPROSIM_VERBOSE_FOLIAGE\n\n");
#endif
/*******************/
/* Debugging Flags */
/*******************/
#ifdef	SWITCH_ATTENUATION_ON
 fprintf (fp, "SWITCH_ATTENUATION_ON\n");
#endif
#ifdef	FLAT_DEM
 fprintf (fp, "FLAT_DEM\n");
#endif
#ifdef	NO_TREE_SHUFFLING
 fprintf (fp, "NO_TREE_SHUFFLING\n");
#endif
#ifdef	FORCE_GRG_CYLINDERS
 fprintf (fp, "FORCE_GRG_CYLINDERS\n");
#endif
#ifdef	RAYLEIGH_LEAF
 fprintf (fp, "RAYLEIGH_LEAF\n");
#endif
#ifdef	NO_SHORT_LEAVES
 fprintf (fp, "NO_SHORT_LEAVES\n");
#endif
#ifdef	NO_SHORT_STEMS
 fprintf (fp, "NO_SHORT_STEMS\n");
#endif
#ifdef	POLSARPROSIM_NO_SAR_STEMS
 fprintf (fp, "POLSARPROSIM_NO_SAR_STEMS\n");
#endif
#ifdef	POLSARPROSIM_NO_SAR_PRIMARIES
 fprintf (fp, "POLSARPROSIM_NO_SAR_PRIMARIES\n");
#endif
#ifdef	POLSARPROSIM_NO_SAR_SECONDARIES
 fprintf (fp, "POLSARPROSIM_NO_SAR_SECONDARIES\n");
#endif
#ifdef	POLSARPROSIM_NO_SAR_TERTIARIES
 fprintf (fp, "POLSARPROSIM_NO_SAR_TERTIARIES\n");
#endif
#ifdef	POLSARPROSIM_NO_SAR_FOLIAGE
 fprintf (fp, "POLSARPROSIM_NO_SAR_FOLIAGE\n");
#endif
#ifdef	POLSARPROSIM_STAGE3
 fprintf (fp, "POLSARPROSIM_STAGE3\n");
#endif
#ifdef	POLSARPROSIM_CROWN_OVERLAP_FACTOR
 d		= POLSARPROSIM_CROWN_OVERLAP_FACTOR;
 fprintf (fp, "POLSARPROSIM_CROWN_OVERLAP_FACTOR\t%lf\n", d);
#endif
 fprintf (fp, "\n");
 fflush (fp);
 return;
}

/*********************************/
/* Surface parameter calculation */
/*********************************/

double		ratio_from_delta	(double d)
{
 /*************************************************/
 /* Find r as a solution of r^2exp(1-r^2) - d = 0 */
 /*************************************************/
 double		x0	= d;
 double		f, fp, delta;
 int		i;
 const int	imax	= 5;
 for (i=0; i<imax; i++) {
  f			= x0*exp(1.0-x0) - d;
  fp		= (1.0-x0)*exp(1.0-x0);
  delta		= -f/fp;
  x0		= x0 + delta;
 }
 return (sqrt(fabs(x0)));
}

void		Surface_Parameters (PolSARproSim_Record *pPR, int DEM_model)
{
 double	alpha		= POLSARPROSIM_DEFAULT_SURFACE_ALPHA;
 double	minRdB		= POLSARPROSIM_MINRDB;
 double	midRdB		= POLSARPROSIM_MIDRDB;
 double	maxRdB		= POLSARPROSIM_MAXRDB;
 double	pi			= 4.0*atan(1.0);
 double	thetai		= pi/4.0;
 double	wavelength	= pPR->wavelength;
 double	cos_thetai	= cos(thetai);
 double	sin_thetai	= sin(thetai);
 double	k			= 2.0*pi/wavelength;
 double	sigma_s		= alpha/(k*cos_thetai);
 double	er			= pPR->ground_eps.r;
 double	Bhh			= (cos_thetai-sqrt(er-sin_thetai*sin_thetai))/(cos_thetai+sqrt(er-sin_thetai*sin_thetai));
 double	lamda_s_max	= 1.0/(k*sin_thetai);
 double	gamma		= 4.0*cos_thetai*cos_thetai*cos_thetai*cos_thetai*Bhh*Bhh;
 double	beta		= sin_thetai*sin_thetai;
 double	fs2			= k*k*sigma_s*sigma_s;
 double	flmax_2		= k*k*lamda_s_max*lamda_s_max;
 double	sigma0_max	= 10.0*log10(gamma*fs2*flmax_2*exp(-beta*flmax_2));
 double	delta;
 double	r;
 double	lamda_s;
 double	fl2;
 double	sigma0;
 double	Rt2dB, Rt2, sigma_l;
 double	deltaf;
 double	Sigma0HH;

 double	x, aRdB, bRdB;

/******************************************************/
/* Requested ground brightness is frequency dependent */
/******************************************************/

 if (pPR->frequency > POLSARPROSIM_LBAND) {
  deltaf	= 1.0;
 } else {
  if (pPR->frequency < POLSARPROSIM_PBAND) {
   deltaf	= 0.0;
  } else {
   deltaf	= (pPR->frequency-POLSARPROSIM_PBAND)/(POLSARPROSIM_LBAND-POLSARPROSIM_PBAND);
  }
 }
 Sigma0HH	= deltaf*POLSARPROSIM_SIGMA0HHL45 + (1.0-deltaf)*POLSARPROSIM_SIGMA0HHP45;

/****************************************************************/
/* Small-scale parameters may be influenced by DEM model choice */
/****************************************************************/

 Sigma0HH	+= ((DEM_model - 5)/5) * POLSARPROSIM_DELTAS0HHDB;

/***************************************************/
/* It may not be possible to realise the requested */
/* brightness and still satisfy SPM validity.      */
/***************************************************/

 if (Sigma0HH > sigma0_max) {
  delta		= 1.0;
  lamda_s	= lamda_s_max;
  fl2		= flmax_2;
 } else {
  delta		= sigma0_max - Sigma0HH;
  delta		= pow (10.0, -delta/10.0);
  r			= ratio_from_delta (delta);
  lamda_s	= r/(k*sin_thetai);
  fl2		= k*k*lamda_s*lamda_s;
 }
 sigma0		= 10.0*log10(gamma*fs2*fl2*exp(-beta*fl2));

/*************************/
/* Large scale roughness */
/*************************/

/*****************/
/* New model ... */
/*****************/
/*
 Rt2dB		= minRdB - ((double) DEM_model) * (minRdB - maxRdB) / 10.0;
 Rt2		= pow (10.0, Rt2dB/10.0);
 sigma_l	= sqrt (-log(Rt2))/(2.0*k*cos(pPR->incidence_angle[0])) - sigma_s;
*/
 x			= ((double) DEM_model)/10.0;
 bRdB		= 2.0*(maxRdB - 2.0*midRdB + minRdB);
 aRdB		= maxRdB - minRdB - bRdB;
 Rt2dB		= minRdB + aRdB*x + bRdB*x*x;
 Rt2		= pow (10.0, Rt2dB/10.0);
 sigma_l	= sqrt (-log(Rt2))/(2.0*k*cos(pPR->incidence_angle[0])) - sigma_s;
 if (sigma_l < 0.0) {
  sigma_l	= 0.0;
 }

#ifdef FLAT_DEM
 pPR->large_scale_height_stdev		= 0.0;
#else
 pPR->large_scale_height_stdev		= sigma_l;
#endif
 pPR->large_scale_length			= 3.0*Mean_Tree_Crown_Radius (POLSARPROSIM_PINE003, pPR->mean_tree_height);
 pPR->small_scale_height_stdev		= sigma_s;
 pPR->small_scale_length			= lamda_s;
 fprintf (pPR->pLogFile, "Small-scale RMS height\t= %lf\n", pPR->small_scale_height_stdev);
 fprintf (pPR->pLogFile, "Small-scale cor length\t= %lf\n", pPR->small_scale_length);
 fprintf (pPR->pLogFile, "Large-scale RMS height\t= %lf\n", pPR->large_scale_height_stdev);
 fprintf (pPR->pLogFile, "Large-scale cor length\t= %lf\n", pPR->large_scale_length);
 return;
}

/*************************************************/
/* Read the input file with the setup parameters */
/*************************************************/

int		Input_PolSARproSim_Record		(const char *filename, PolSARproSim_Record *pPR)
{
 const double	max_packing_fraction	= DPI_RAD/(2.0*sqrt(3.0));
 int			i;
 double			image_width, image_height;
 FILE			*pInputFile;

/*********************/
/* Ground properties */
/*********************/

 const double	sand_fraction	= 0.0502;
 const double	clay_fraction	= 0.4738;
 const double	dry_density		= 2.56;
 const double	ground_pf		= 0.50;
 int			DEM_model;
#ifdef INPUT_GROUND_MV
 int			GMV_model;
#endif
 double			ground_mv		= DEFAULT_GROUND_MV;
 double			psf_azextent;
 double			psf_srextent;

/**********************************/
/* Attempt to open the input file */
/**********************************/

 if ((pInputFile = fopen(filename, "r")) == NULL) {
  fprintf (pPR->pLogFile, "Unable to open input file %s.\n", filename);
  fprintf (pPR->pOutputFile, "Unable to open input file %s.\n", filename);
  fflush (pPR->pLogFile);
  fflush (pPR->pOutputFile);
  return (!NO_POLSARPROSIM_ERRORS);
 }

/********************/
/* Input parameters */
/********************/

 fscanf (pInputFile, "%d", &(pPR->Tracks));						EndOfLine (pInputFile);
 pPR->slant_range			= (double*) calloc (pPR->Tracks, sizeof (double));
 pPR->incidence_angle		= (double*) calloc (pPR->Tracks, sizeof (double));
 for (i = 0; i < pPR->Tracks; i++) {
  fscanf (pInputFile, "%lf", &(pPR->slant_range[i]));			EndOfLine (pInputFile);
  fscanf (pInputFile, "%lf", &(pPR->incidence_angle[i]));		EndOfLine (pInputFile);
  pPR->incidence_angle[i]	*= atan(1.0)/45.0;
 }
 fscanf (pInputFile, "%lf", &(pPR->frequency));					EndOfLine (pInputFile);
 fscanf (pInputFile, "%lf", &(pPR->azimuth_resolution));		EndOfLine (pInputFile);
 fscanf (pInputFile, "%lf", &(pPR->slant_range_resolution));	EndOfLine (pInputFile);
 fscanf (pInputFile, "%d",  &DEM_model);						EndOfLine (pInputFile);
 fscanf (pInputFile, "%lf", &(pPR->slope_x));					EndOfLine (pInputFile);
 fscanf (pInputFile, "%lf", &(pPR->slope_y));					EndOfLine (pInputFile);
 fscanf (pInputFile, "%d",  &(pPR->seed));						EndOfLine (pInputFile);
 fscanf (pInputFile, "%d",  &(pPR->species));					EndOfLine (pInputFile);
 fscanf (pInputFile, "%lf", &(pPR->mean_tree_height));			EndOfLine (pInputFile);
 fscanf (pInputFile, "%lf", &(pPR->Stand_Area));				EndOfLine (pInputFile);
 fscanf (pInputFile, "%d",  &(pPR->req_trees_per_hectare));		EndOfLine (pInputFile);
#ifdef INPUT_GROUND_MV
 fscanf (pInputFile, "%d",  &GMV_model);						EndOfLine (pInputFile);
#endif

/************************/
/* Close the input file */
/************************/

 fclose (pInputFile);

/***************************/
/* Report input parameters */
/***************************/

 fprintf (pPR->pLogFile, "\nInput parameter report ...\n\n");
 fprintf (pPR->pLogFile, "%d\t\t\t/* The number of requested tracks \t*/\n", pPR->Tracks);
 for (i = 0; i < pPR->Tracks; i++) {
  fprintf (pPR->pLogFile, "%lf\t\t/* Slant range (broadside platform to scene centre) in metres \t*/\n", pPR->slant_range[i]);
  fprintf (pPR->pLogFile, "%lf\t\t/* Incidence angle in degrees \t*/\n", 45.0*pPR->incidence_angle[i]/atan(1.0));
 }
 fprintf (pPR->pLogFile, "%lf\t\t/* Centre frequency in GHz \t*/\n", pPR->frequency);
 fprintf (pPR->pLogFile, "%lf\t\t/* Azimuth resolution (width at half-height power) in metres \t*/\n", pPR->azimuth_resolution);
 fprintf (pPR->pLogFile, "%lf\t\t/* Slant range resolution (width at half-height power) in metres \t*/\n", pPR->slant_range_resolution);
 fprintf (pPR->pLogFile, "%d\t\t\t/* Ground model: 0 = smoothest … 10 = roughest \t*/\n",  DEM_model);
 fprintf (pPR->pLogFile, "%lf\t\t/* Ground slope in azimuth direction (dimensionless) \t*/\n", pPR->slope_x);
 fprintf (pPR->pLogFile, "%lf\t\t/* Ground slope in ground range direction (dimensionless) \t*/\n", pPR->slope_y);
 fprintf (pPR->pLogFile, "%d\t\t\t/* Random number generator seed \t*/\n",  pPR->seed);
 fprintf (pPR->pLogFile, "%d\t\t\t/* Tree species: 0 = HEDGE, 1,2,3 = PINE, 4 = DECIDUOUS \t*/\n",  pPR->species);
 fprintf (pPR->pLogFile, "%lf\t\t/* Mean tree height in metres \t*/\n", pPR->mean_tree_height);
 fprintf (pPR->pLogFile, "%lf\t\t/* Area of the forest stand in square metres \t*/\n", pPR->Stand_Area);
 fprintf (pPR->pLogFile, "%d\t\t\t/* Desired stand density in stems per hectare \t*/\n",  pPR->req_trees_per_hectare);
#ifdef INPUT_GROUND_MV
 fprintf (pPR->pLogFile, "%d\t\t\t/* Ground moisture content model: 0 = dry ... 10  = wet \t*/\n\n", GMV_model);
#endif
 fflush (pPR->pLogFile);

 fprintf (pPR->pOutputFile, "\nInput parameter report ...\n\n");
 fprintf (pPR->pOutputFile, "%d\t\t\t/* The number of requested tracks \t*/\n", pPR->Tracks);
 for (i = 0; i < pPR->Tracks; i++) {
  fprintf (pPR->pOutputFile, "%lf\t\t/* Slant range (broadside platform to scene centre) in metres \t*/\n", pPR->slant_range[i]);
  fprintf (pPR->pOutputFile, "%lf\t\t/* Incidence angle in degrees \t*/\n", 45.0*pPR->incidence_angle[i]/atan(1.0));
 }
 fprintf (pPR->pOutputFile, "%lf\t\t/* Centre frequency in GHz \t*/\n", pPR->frequency);
 fprintf (pPR->pOutputFile, "%lf\t\t/* Azimuth resolution (width at half-height power) in metres \t*/\n", pPR->azimuth_resolution);
 fprintf (pPR->pOutputFile, "%lf\t\t/* Slant range resolution (width at half-height power) in metres \t*/\n", pPR->slant_range_resolution);
 fprintf (pPR->pOutputFile, "%d\t\t\t/* Ground model: 0 = smoothest … 10 = roughest \t*/\n",  DEM_model);
 fprintf (pPR->pOutputFile, "%lf\t\t/* Ground slope in azimuth direction (dimensionless) \t*/\n", pPR->slope_x);
 fprintf (pPR->pOutputFile, "%lf\t\t/* Ground slope in ground range direction (dimensionless) \t*/\n", pPR->slope_y);
 fprintf (pPR->pOutputFile, "%d\t\t\t/* Random number generator seed \t*/\n",  pPR->seed);
 fprintf (pPR->pOutputFile, "%d\t\t\t/* Tree species: 0 = HEDGE, 1,2,3 = PINE, 4 = DECIDUOUS \t*/\n",  pPR->species);
 fprintf (pPR->pOutputFile, "%lf\t\t/* Mean tree height in metres \t*/\n", pPR->mean_tree_height);
 fprintf (pPR->pOutputFile, "%lf\t\t/* Area of the forest stand in square metres \t*/\n", pPR->Stand_Area);
 fprintf (pPR->pOutputFile, "%d\t\t\t/* Desired stand density in stems per hectare \t*/\n",  pPR->req_trees_per_hectare);
#ifdef INPUT_GROUND_MV
 fprintf (pPR->pOutputFile, "%d\t\t\t/* Ground moisture content model: 0 = dry ... 10  = wet \t*/\n\n", GMV_model);
#endif
 fflush (pPR->pOutputFile);

/**************************************/
/* Initialise random number generator */
/**************************************/

 srand (pPR->seed);

/*************************************/
/* Central wavelength and wavenumber */
/*************************************/

 pPR->wavelength					= LIGHT_SPEED/pPR->frequency;
 pPR->k0							= 2.0*DPI_RAD/pPR->wavelength;

/******************************************************/
/* Resolution, sampling and impulse response function */
/******************************************************/

 pPR->f_azimuth						= DEFAULT_RESOLUTION_SAMPLING_FACTOR;
 pPR->deltax						= pPR->azimuth_resolution*pPR->f_azimuth;
 pPR->ground_range_resolution		= (double*) calloc (pPR->Tracks, sizeof (double));
 for (pPR->current_track = 0; pPR->current_track < pPR->Tracks; pPR->current_track++) {
  pPR->ground_range_resolution[pPR->current_track]	= pPR->slant_range_resolution/sin(pPR->incidence_angle[pPR->current_track]);
 }
 pPR->f_ground_range				= DEFAULT_RESOLUTION_SAMPLING_FACTOR;
 pPR->deltay						= pPR->ground_range_resolution[0]*pPR->f_ground_range;

 /******************************************************/
 /* User supplies area, for trees this is assumed much */
 /* greater than a crown area, but for the hedge ...   */
 /******************************************************/

 if (pPR->species == POLSARPROSIM_HEDGE) {
  pPR->mean_crown_radius			= sqrt(pPR->Stand_Area/DPI_RAD);
 } else {
  pPR->mean_crown_radius			= Mean_Tree_Crown_Radius (pPR->species, pPR->mean_tree_height);
 }

 pPR->Layover_Distance				= pPR->mean_tree_height / tan(pPR->incidence_angle[0]);
 pPR->Shadow_Distance				= pPR->mean_tree_height * tan(pPR->incidence_angle[0]);
 pPR->Gap_Distance					= RESOLUTION_GAP_SIZE * (pPR->azimuth_resolution + pPR->ground_range_resolution[0])/2.0;
 pPR->Stand_Radius					= sqrt(pPR->Stand_Area/DPI_RAD);
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pPR->Lx							= 2.0*(pPR->Stand_Radius+pPR->Gap_Distance+pPR->mean_crown_radius);
 } else {
  pPR->Lx							= 2.0*(pPR->Stand_Radius+pPR->Gap_Distance);
 }
 pPR->Ly							= pPR->Lx + pPR->Layover_Distance+pPR->Shadow_Distance;
 pPR->Area							= pPR->Lx*pPR->Ly;
 pPR->Hectares						= pPR->Area/10000.0;

/************************/
/* SAR image dimensions */
/************************/

 pPR->nx							= (int) (pPR->Lx / pPR->deltax) + 1;
 pPR->nx							= 2*((int)(pPR->nx/2))+1;
 pPR->deltax						= pPR->Lx/pPR->nx;
 pPR->ny							= (int) (pPR->Ly / pPR->deltay) + 1;
 pPR->ny							= 2*((int)(pPR->ny/2))+1;
 pPR->deltay						= pPR->Ly/pPR->ny;

/*********/
/* Trees */
/*********/

 pPR->max_tree_number				= (int) (max_packing_fraction*pPR->Area/(POLSARPROSIM_CROWN_OVERLAP_FACTOR*POLSARPROSIM_CROWN_OVERLAP_FACTOR*DPI_RAD*pPR->mean_crown_radius*pPR->mean_crown_radius));
 pPR->max_trees_per_hectare			= (int) ((double) pPR->max_tree_number/pPR->Hectares);
 if (pPR->species != POLSARPROSIM_HEDGE) {
  if (pPR->req_trees_per_hectare > pPR->max_trees_per_hectare) {
   fprintf (pPR->pLogFile, "\nRequested stand density of %d Trees/Ha is too great.\n", pPR->req_trees_per_hectare);
   fprintf (pPR->pLogFile, "Resetting stand density to %d Trees/Ha.\n\n", pPR->max_trees_per_hectare);
   fflush  (pPR->pLogFile);
   fprintf (pPR->pOutputFile, "\nRequested stand density of %d Trees/Ha is too great.\n", pPR->req_trees_per_hectare);
   fprintf (pPR->pOutputFile, "Resetting stand density to %d Trees/Ha.\n\n", pPR->max_trees_per_hectare);
   fflush  (pPR->pOutputFile);
   pPR->req_trees_per_hectare		= pPR->max_trees_per_hectare;
  }
  pPR->trees_per_100m				= sqrt((double)pPR->req_trees_per_hectare);
  pPR->nTreex						= (int) ((pPR->Lx*pPR->trees_per_100m/100.0)+1.0);
  pPR->nTreey						= (int) ((pPR->Ly*pPR->trees_per_100m/100.0)+1.0);
  pPR->Trees						= pPR->nTreex*pPR->nTreey;
  pPR->deltaTreex					= pPR->Lx/(double)pPR->nTreex;
  pPR->deltaTreey					= pPR->Ly/(double)pPR->nTreey;
 } else {
  pPR->trees_per_100m				= sqrt(1.0/(pPR->Hectares));
  pPR->nTreex						= (int) 1;
  pPR->nTreey						= (int) 1;
  pPR->Trees						= pPR->nTreex*pPR->nTreey;
  pPR->deltaTreex					= pPR->Lx/(double)pPR->nTreex;
  pPR->deltaTreey					= pPR->Ly/(double)pPR->nTreey;
 }
 pPR->close_packing_radius			= sqrt (max_packing_fraction*pPR->Area/(DPI_RAD*pPR->Trees));

/*************************************/
/* Initialise tree heights and radii */
/*************************************/

 pPR->Tree_Location		= (TreeLoc*) calloc (pPR->Trees, sizeof(TreeLoc));
 if (pPR->species != POLSARPROSIM_HEDGE) {
  for (i=0; i<pPR->Trees; i++) {
   pPR->Tree_Location[i].height	= Realise_Tree_Height(pPR->mean_tree_height);
   pPR->Tree_Location[i].radius	= Realise_Tree_Crown_Radius (pPR->species, pPR->Tree_Location[i].height);
   pPR->Tree_Location[i].x		= 0.0;
   pPR->Tree_Location[i].y		= 0.0;
  }
 } else {
  pPR->Tree_Location[0].height	= pPR->mean_tree_height;
  pPR->Tree_Location[0].radius	= pPR->mean_crown_radius;
  pPR->Tree_Location[0].x		= 0.0;
  pPR->Tree_Location[0].y		= pPR->Layover_Distance + pPR->Stand_Radius + pPR->Gap_Distance - pPR->Ly/2.0;
 }

/***************************/
/* Graphic image variables */
/***************************/

 image_height		= pPR->Ly*cos(pPR->incidence_angle[0]) + pPR->mean_tree_height*sin(pPR->incidence_angle[0]);
 image_width		= pPR->Lx;
 pPR->gny			= FOREST_GRAPHIC_NY;
 pPR->gnx			= (int) (((double)pPR->gny*image_width)/((double)image_height));

/***********************************************************/
/* Short vegetation layer variables not under user control */
/***********************************************************/

 pPR->shrt_vegi_depth			= DEFAULT_SHORT_VEGI_DEPTH;
 pPR->shrt_vegi_stem_vol_frac	= DEFAULT_SHORT_VEGI_STEM_VOL_FRAC;
 pPR->shrt_vegi_leaf_vol_frac	= DEFAULT_SHORT_VEGI_LEAF_VOL_FRAC;

/********************************/
/* Ground electrical properties */
/********************************/

#ifdef INPUT_GROUND_MV
 ground_mv			= MIN_GROUND_MV + ((double) GMV_model)*(MAX_GROUND_MV-MIN_GROUND_MV)/10.0;
#endif

 pPR->ground_eps = ground_permittivity (dry_density, ground_pf, sand_fraction, 
									clay_fraction, ground_mv, pPR->frequency);

/**************************************************/
/* Large scale and small scale surface parameters */
/**************************************************/

 Surface_Parameters (pPR, DEM_model);

/**********************************************/
/* Report derived simulation parameter vaules */
/**********************************************/

 fprintf (pPR->pLogFile, "Derived parameter values ...\n\n");
 fprintf (pPR->pLogFile, "Wavelength\t\t\t\t=\t%lf metres\n", pPR->wavelength);
 fprintf (pPR->pLogFile, "Wavenumber\t\t\t\t=\t%lf inv. metres\n", pPR->k0);
 fprintf (pPR->pLogFile, "Azimuth resolution\t\t=\t%lf metres\n", pPR->azimuth_resolution);
 for (pPR->current_track = 0; pPR->current_track < pPR->Tracks; pPR->current_track++) {
  fprintf (pPR->pLogFile, "Ground range resolution[%d]\t=\t%lf metres\n", pPR->current_track, pPR->ground_range_resolution[pPR->current_track]);
 }
 fprintf (pPR->pLogFile, "Large-scale height stdev\t=\t%lf metres\n", pPR->large_scale_height_stdev);
 fprintf (pPR->pLogFile, "Large-scale length\t\t=\t%lf metres\n", pPR->large_scale_length);
 fprintf (pPR->pLogFile, "Small-scale height stdev\t=\t%lf metres\n", pPR->small_scale_height_stdev);
 fprintf (pPR->pLogFile, "Small-scale length\t\t=\t%lf metres\n", pPR->small_scale_length);
 fprintf (pPR->pLogFile, "Layover distance\t\t\t=\t%lf metres\n", pPR->Layover_Distance);
 fprintf (pPR->pLogFile, "Shadow distance\t\t\t=\t%lf metres\n", pPR->Shadow_Distance);
 fprintf (pPR->pLogFile, "Gap distance\t\t\t=\t%lf metres\n", pPR->Gap_Distance);
 fprintf (pPR->pLogFile, "Stand radius\t\t\t=\t%lf metres\n", pPR->Stand_Radius);
 fprintf (pPR->pLogFile, "Lx\t\t\t\t\t=\t%lf metres\n", pPR->Lx);
 fprintf (pPR->pLogFile, "Ly\t\t\t\t\t=\t%lf metres\n", pPR->Ly);
 fprintf (pPR->pLogFile, "Area\t\t\t\t\t=\t%lf square metres\n", pPR->Area);
 fprintf (pPR->pLogFile, "Hectares\t\t\t\t=\t%lf Ha\n", pPR->Hectares);
 fprintf (pPR->pLogFile, "There are %d pixels in azimuth of width %lf metres\n", pPR->nx, pPR->deltax);
 fprintf (pPR->pLogFile, "There are %d pixels in ground range of width %lf metres\n", pPR->ny, pPR->deltay);
 switch (pPR->species) {
  case POLSARPROSIM_HEDGE:			fprintf (pPR->pLogFile, "Random hedge simulation\n"); break;
  case POLSARPROSIM_PINE001:		fprintf (pPR->pLogFile, "Pine forest simulation\n"); break;
  case POLSARPROSIM_PINE002:		fprintf (pPR->pLogFile, "Pine forest simulation\n"); break;
  case POLSARPROSIM_PINE003:		fprintf (pPR->pLogFile, "Pine forest simulation\n"); break;
  case POLSARPROSIM_DECIDUOUS001:	fprintf (pPR->pLogFile, "Deciduous forest simulation\n"); break;
  default:							fprintf (pPR->pLogFile, "WARNING: UNRECOGNISED TREE SPECIES\n"); break;
 }
 fprintf (pPR->pLogFile, "\n*******************************************************************\n\n");
 fflush  (pPR->pLogFile);

 fprintf (pPR->pOutputFile, "Derived parameter values ...\n\n");
 fprintf (pPR->pOutputFile, "Wavelength\t\t\t\t=\t%lf metres\n", pPR->wavelength);
 fprintf (pPR->pOutputFile, "Wavenumber\t\t\t\t=\t%lf inv. metres\n", pPR->k0);
 fprintf (pPR->pOutputFile, "Azimuth resolution\t\t=\t%lf metres\n", pPR->azimuth_resolution);
 for (pPR->current_track = 0; pPR->current_track < pPR->Tracks; pPR->current_track++) {
  fprintf (pPR->pOutputFile, "Ground range resolution[%d]\t=\t%lf metres\n", pPR->current_track, pPR->ground_range_resolution[pPR->current_track]);
 }
 fprintf (pPR->pOutputFile, "Large-scale height stdev\t=\t%lf metres\n", pPR->large_scale_height_stdev);
 fprintf (pPR->pOutputFile, "Large-scale length\t\t=\t%lf metres\n", pPR->large_scale_length);
 fprintf (pPR->pOutputFile, "Small-scale height stdev\t=\t%lf metres\n", pPR->small_scale_height_stdev);
 fprintf (pPR->pOutputFile, "Small-scale length\t\t=\t%lf metres\n", pPR->small_scale_length);
 fprintf (pPR->pOutputFile, "Layover distance\t\t\t=\t%lf metres\n", pPR->Layover_Distance);
 fprintf (pPR->pOutputFile, "Shadow distance\t\t\t=\t%lf metres\n", pPR->Shadow_Distance);
 fprintf (pPR->pOutputFile, "Gap distance\t\t\t=\t%lf metres\n", pPR->Gap_Distance);
 fprintf (pPR->pOutputFile, "Stand radius\t\t\t=\t%lf metres\n", pPR->Stand_Radius);
 fprintf (pPR->pOutputFile, "Lx\t\t\t\t\t=\t%lf metres\n", pPR->Lx);
 fprintf (pPR->pOutputFile, "Ly\t\t\t\t\t=\t%lf metres\n", pPR->Ly);
 fprintf (pPR->pOutputFile, "Area\t\t\t\t\t=\t%lf square metres\n", pPR->Area);
 fprintf (pPR->pOutputFile, "Hectares\t\t\t\t=\t%lf Ha\n", pPR->Hectares);
 fprintf (pPR->pOutputFile, "There are %d pixels in azimuth of width %lf metres\n", pPR->nx, pPR->deltax);
 fprintf (pPR->pOutputFile, "There are %d pixels in ground range of width %lf metres\n", pPR->ny, pPR->deltay);
 switch (pPR->species) {
  case POLSARPROSIM_HEDGE:			fprintf (pPR->pOutputFile, "Random hedge simulation\n"); break;
  case POLSARPROSIM_PINE001:		fprintf (pPR->pOutputFile, "Pine forest simulation\n"); break;
  case POLSARPROSIM_PINE002:		fprintf (pPR->pOutputFile, "Pine forest simulation\n"); break;
  case POLSARPROSIM_PINE003:		fprintf (pPR->pOutputFile, "Pine forest simulation\n"); break;
  case POLSARPROSIM_DECIDUOUS001:	fprintf (pPR->pOutputFile, "Deciduous forest simulation\n"); break;
  default:							fprintf (pPR->pOutputFile, "WARNING: UNRECOGNISED TREE SPECIES\n"); break;
 }
 fprintf (pPR->pOutputFile, "\n*******************************************************************\n\n");
 fflush  (pPR->pOutputFile);

/************************************/
/* Initialise SAR imagery variables */
/************************************/

 Create_SIM_Record (&(pPR->HHimage));
 Create_SIM_Record (&(pPR->HVimage));
 Create_SIM_Record (&(pPR->VVimage));

 Initialise_SIM_Record	(&(pPR->HHimage), "", pPR->nx, pPR->ny, SIM_COMPLEX_FLOAT_TYPE, pPR->Lx, pPR->Ly, 
						"PolSARproSim HH image file");
 Initialise_SIM_Record	(&(pPR->HVimage), "", pPR->nx, pPR->ny, SIM_COMPLEX_FLOAT_TYPE, pPR->Lx, pPR->Ly, 
						"PolSARproSim HV image file");
 Initialise_SIM_Record	(&(pPR->VVimage), "", pPR->nx, pPR->ny, SIM_COMPLEX_FLOAT_TYPE, pPR->Lx, pPR->Ly, 
						"PolSARproSim VV image file");

/******************************************************/
/* Store xmid and ymid in the master record structure */
/******************************************************/

 pPR->xmid		= (pPR->nx/2)*pPR->deltax;
 pPR->ymid		= (pPR->ny/2)*pPR->deltay;
 pPR->psfaaz	= 4.0*log(sqrt(2.0))/(pPR->azimuth_resolution*pPR->azimuth_resolution);
 pPR->psfagr	= (double*) calloc (pPR->Tracks, sizeof (double));
 for (pPR->current_track = 0; pPR->current_track < pPR->Tracks; pPR->current_track++) {
  pPR->psfagr[pPR->current_track]	= 4.0*log(sqrt(2.0))/(pPR->ground_range_resolution[pPR->current_track]*pPR->ground_range_resolution[pPR->current_track]);
 }
 pPR->psfasr	= 4.0*log(sqrt(2.0))/(pPR->slant_range_resolution*pPR->slant_range_resolution);
 psf_azextent	= sqrt(-log(sqrt(POWER_AT_PSF_EDGE))/pPR->psfaaz);
 psf_srextent	= sqrt(-log(sqrt(POWER_AT_PSF_EDGE))/pPR->psfasr);
 pPR->PSFnx		= (int) (psf_azextent/pPR->deltax) + 1;
 pPR->PSFnx		= 2*(pPR->PSFnx/2)+1;
 pPR->PSFny		= (int) (psf_srextent/(pPR->deltay*sin(pPR->incidence_angle[0]))) + 1;
 pPR->PSFny		= 2*(pPR->PSFny/2)+1;

/*********************************************/
/* Report SAR imaging parameters to log file */
/*********************************************/

 fprintf (pPR->pLogFile, "\nxmid is %lf metres\n", pPR->xmid);
 fprintf (pPR->pLogFile, "ymid is %lf metres\n", pPR->ymid);
 fprintf (pPR->pLogFile, "PSF azimuth factor is %lf metres^-2\n", pPR->psfaaz);
 for (pPR->current_track = 0; pPR->current_track < pPR->Tracks; pPR->current_track++) {
  fprintf (pPR->pLogFile, "PSF ground range factor for track %d is %lf metres^-2\n", pPR->current_track, pPR->psfagr[pPR->current_track]);
 }
 fprintf (pPR->pLogFile, "PSF slant range factor is %lf metres^-2\n", pPR->psfasr);
 fprintf (pPR->pLogFile, "PSF azimuth     extent is %lf metres\n", psf_azextent);
 fprintf (pPR->pLogFile, "PSF slant range extent is %lf metres\n", psf_srextent);
 fprintf (pPR->pLogFile, "PSF azimuth     extent is %d pixels\n", pPR->PSFnx);
 fprintf (pPR->pLogFile, "PSF slant range extent is %d pixels\n", pPR->PSFny);
 fflush  (pPR->pLogFile);

/***********************************/
/* Initialise PSF scaling to unity */
/***********************************/

 pPR->PSFamp	= 1.0;
 fprintf (pPR->pLogFile, "Initial PSF scaling is %lf\n", pPR->PSFamp);
 fflush  (pPR->pLogFile);

/*********************************/
/* Initialise progress indicator */
/*********************************/

 pPR->progress	= 0;

/**************************/
/* Return to main program */
/**************************/

 return (NO_POLSARPROSIM_ERRORS);
}

/***********************************************/
/* Generating the underlying ground height map */
/***********************************************/

void	Ground_Surface_Generation	(PolSARproSim_Record *pPR)
{
 double			Lx			= pPR->Lx;
 double			Ly			= pPR->Ly;
 int			nx			= pPR->nx;
 int			ny			= pPR->ny;
 double			sx			= pPR->slope_x;
 double			sy			= pPR->slope_y;
 double			length		= pPR->large_scale_length;
 double			height_std	= pPR->large_scale_height_stdev;
 SIM_Record		*pSR		= &(pPR->Ground_Height);
 int			N			= POLSARPROSIM_GROUND_FOURIER_MOMENTS;
 const double	PI			= DPI_RAD;
 double			alphax		= sqrt(1.0+sx*sx);
 double			alphay		= sqrt(1.0+sy*sy);
 double			alpha		= sqrt(1.0+sx*sx+sy*sy);
 double			deltax		= Lx/(double)nx;
 double			deltay		= Ly/(double)ny;
 double			Lxp			= alphax*Lx;
 double			Lyp			= alphay*Ly;
 double			deltaxp		= alphax*deltax;
 double			deltayp		= alphay*deltay;
 int			i,j;
 sim_pixel		p;
 double			xi, yj;
 double			mean_height;
 double			stdd_height;
 char			*ground_height_filename;
#ifndef	FLAT_DEM
 int			m,n;
 double			xip, yjp;
 double			arg;
 double			km, kn;
 double			height_factor;
 double			*C;
 Complex		*H;
 Complex		carg;
 Complex		hxy;
 Complex		*f;
 Complex		*F;
#endif

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to Ground_Surface_Generation ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to Ground_Surface_Generation ... \n");
 fflush  (pPR->pLogFile);

/********************************/
/* Seed random number generator */
/********************************/

 srand (pPR->seed);

/*****************************************/
/* Initialise ground height map variable */
/*****************************************/

 ground_height_filename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("ground_height.sim")+1, sizeof(char));
 strcpy  (ground_height_filename, pPR->pMasterDirectory);
 strcat  (ground_height_filename, "ground_height.sim");

 Destroy_SIM_Record (pSR);
 Create_SIM_Record (pSR);
 Initialise_SIM_Record (pSR, ground_height_filename, nx, ny, SIM_FLOAT_TYPE, 
						Lx, Ly, "PolSARproSim ground height map");
 p.simpixeltype	= pSR->pixel_type;
 free (ground_height_filename);

#ifndef FLAT_DEM

/**********************************/
/* Stage 1: generate random field */
/**********************************/

 f	= (Complex*) calloc (nx*ny, sizeof(Complex));
 for (m=0;m<nx;m++) {
  for (n=0;n<ny;n++) {
   f[n*nx+m]	= rp_complex(drand(), 2.0*PI*drand());
  }
 }

/**********************************************/
/* Stage 2: Calculate moments of random field */
/**********************************************/

 F	= (Complex*) calloc ((2*N+1)*(2*N+1), sizeof(Complex));
 for (m=0;m<=2*N;m++) {
  for (n=0;n<=2*N;n++) {
   F[n*(2*N+1)+m]	= xy_complex (0.0, 0.0);
   for (i=0; i<nx; i++) {
    xi	= i*deltaxp - (Lxp - deltaxp)/2.0;
	xip	= 2.0*PI*xi/Lxp;
	for (j=0; j<ny; j++) {
	 yj		= j*deltayp - (Lyp - deltayp)/2.0;
	 yj		= -yj;
	 yjp	= 2.0*PI*yj/Lyp;
	 arg	= -((m*xip)+(n*yjp));
	 carg	= rp_complex (1.0, arg);
     F[n*(2*N+1)+m]	= complex_add (F[n*(2*N+1)+m], complex_mul (carg, f[j*nx+i]));
	}
   }
  }
 }

/**********************************************/
/* Stage 3: Calculate the correlation moments */
/**********************************************/

 C	= (double*) calloc ((2*N+1)*(2*N+1), sizeof(double));
 for (m=0;m<=2*N;m++) {
  km	 = (double) m - (double) N;
  km	*= 2.0*PI/Lxp;
  for (n=0;n<=2*N;n++) {
   kn	 = (double) n - (double)N;
   kn	*= 2.0*PI/Lyp;
   C[n*(2*N+1)+m]	= 0.5*length*length*exp(-km*km*length*length/8.0)*exp(-kn*kn*length*length/8.0);
  }
 }

/*******************************************/
/* Stage 4: Multiply in the Fourier domain */
/*******************************************/

 H	= (Complex*) calloc ((2*N+1)*(2*N+1), sizeof(Complex));
 for (m=0;m<=2*N;m++) {
  for (n=0;n<=2*N;n++) {
   H[n*(2*N+1)+m]	= complex_rmul (F[n*(2*N+1)+m], C[n*(2*N+1)+m]);
  }
 }

/************************************************/
/* Stage 5: Form the surface in the real domain */
/************************************************/

 for (i=0; i<nx; i++) {
  xi	= i*deltaxp - (Lxp - deltaxp)/2.0;
  for (j=0; j<ny; j++) {
   yj	= j*deltayp - (Lyp - deltayp)/2.0;
   yj	= -yj;
   hxy	= xy_complex (0.0, 0.0);
   for (m=0;m<=2*N;m++) {
    km	 = (double) m - (double) N;
    km	*= 2.0*PI/Lxp;
    for (n=0;n<=2*N;n++) {
     kn		= (double) n - (double)N;
     kn		*= 2.0*PI/Lyp;
     arg	= km*xi+kn*yj;
     carg	= rp_complex (1.0, arg);
	 hxy	= complex_add (hxy, complex_mul (H[n*(2*N+1)+m], carg));
    }
   }
   p.data.f	= (float) complex_real (hxy);
   putSIMpixel_periodic (pSR, p, i, j);
  }
 }

/**********************************************************/
/* Stage 6: Zero mean height and scale standard deviation */
/**********************************************************/

 mean_height	= 0.0;
 stdd_height		= 0.0;
 for (i=0; i<nx; i++) {
  for (j=0; j<ny; j++) {
   p	= getSIMpixel_periodic (pSR, i, j);
   mean_height	+= (double) p.data.f;
  }
 }
 mean_height	/=	(double) (nx*ny);
 for (i=0; i<nx; i++) {
  for (j=0; j<ny; j++) {
   p			 = getSIMpixel_periodic (pSR, i, j);
   p.data.f		-= (float) mean_height;
   putSIMpixel_periodic (pSR, p, i, j);
   stdd_height	+= (double) p.data.f * p.data.f;
  }
 }
 stdd_height	/=	(double) (nx*ny);
 stdd_height	 = sqrt(stdd_height);
 height_factor	 = height_std/stdd_height;
 for (i=0; i<nx; i++) {
  for (j=0; j<ny; j++) {
   p			 = getSIMpixel_periodic (pSR, i, j);
   p.data.f		*= (float) height_factor;
   putSIMpixel_periodic (pSR, p, i, j);
  }
 }

/*************************************************/
/* Stage 7: Project into SAR image plane heights */
/*************************************************/

 for (i=0; i<nx; i++) {
  xi	= i*deltax - (Lx - deltax)/2.0;
  for (j=0; j<ny; j++) {
   yj	= j*deltay - (Ly - deltay)/2.0;
   yj	= -yj;
   p	= getSIMpixel_periodic (pSR, i, j);
   p.data.f	= (float) (sx*xi+sy*yj+p.data.f*alpha);
   putSIMpixel_periodic (pSR, p, i, j);
  }
 }

#else

 for (i=0; i<nx; i++) {
  xi	= i*deltax - (Lx - deltax)/2.0;
  for (j=0; j<ny; j++) {
   yj	= j*deltay - (Ly - deltay)/2.0;
   yj	= -yj;
   p.data.f	= (float) (sx*xi+sy*yj);
   putSIMpixel (pSR, p, i, j);
  }
 }

#endif

/***********************************************************/
/* Stage 8: Report the properties of the generated surface */
/***********************************************************/

 mean_height	= 0.0;
 stdd_height	= 0.0;
 for (i=0; i<nx; i++) {
  xi	= i*deltax - (Lx - deltax)/2.0;
  for (j=0; j<ny; j++) {
   yj	= j*deltay - (Ly - deltay)/2.0;
   yj	= -yj;
   p	= getSIMpixel_periodic (pSR, i, j);
   mean_height	+= ((double) p.data.f) - (sx*xi+sy*yj);
  }
 }
 mean_height	/= (double) (nx*ny);
 for (i=0; i<nx; i++) {
  xi	= i*deltax - (Lx - deltax)/2.0;
  for (j=0; j<ny; j++) {
   yj	= j*deltay - (Ly - deltay)/2.0;
   yj	= -yj;
   p	= getSIMpixel_periodic (pSR, i, j);
   stdd_height	+= (((double) p.data.f) - (sx*xi+sy*yj))*(((double) p.data.f) - (sx*xi+sy*yj));
  }
 }
 stdd_height	/= (double) (nx*ny);
 stdd_height	 = sqrt(stdd_height);

 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Ground surface mean height above terrain slope\t= %12.5em.\n", mean_height);
 fprintf (pPR->pLogFile, "Ground surface stdd height above terrain slope\t= %12.5em.\n", stdd_height);
 fprintf (pPR->pLogFile, "\n");
 fflush  (pPR->pLogFile);

/***********/
/* Tidy up */
/***********/

#ifndef FLAT_DEM
 free (f);
 free (F);
 free (C);
 free (H);
#endif

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to Ground_Surface_Generation\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to Ground_Surface_Generation\n\n");
 fflush  (pPR->pLogFile);

/********************************/
/* Increment progress indicator */
/********************************/

 pPR->progress++;

/********************************/
/* Report progress if requested */
/********************************/

#ifdef POLSARPROSIM_MAX_PROGRESS
 PolSARproSim_indicate_progress (pPR);
#endif

 return;
}

/**************************/
/* Line input termination */
/**************************/

void	EndOfLine		(FILE *fp)
{
 char ch;
 do {
  ch = (char) fgetc(fp);
 } while ((ch != '\n') && (ch != EOF));
 return;
}

/**************************************************/
/* Calculate various attenuation contributions    */
/* and generate spatial attenuation look-up table */
/**************************************************/

int			Cylinder_from_Branch		(Cylinder *pC, Branch *pB, int i_seg, int n_segments)
{
 double		length, radius, tm, tp, deltat;
 d3Vector	z, bm, bp;

 deltat		= 1.0/(double) n_segments;
 tm			= i_seg*deltat;
 tp			= (i_seg+1)*deltat;
 bm			= Branch_Centre (pB, tm);
 bp			= Branch_Centre (pB, tp);
 radius		= Branch_Radius (pB, 0.5*(tm+tp));
 z			= d3Vector_difference (bp, bm);
 length		= z.r;
 d3Vector_insitu_normalise (&z);
 Assign_Cylinder (pC, length, radius, pB->permittivity, z, bm);
 return (NO_POLSARPROSIM_ERRORS);
}

c33Matrix	CylinderPolarisability	(Cylinder *pC, d3Vector *pkix, d3Vector *pkiy, d3Vector *pkiz, Yn_Lookup *pYtable, Jn_Lookup *pJtable)
{
 c33Matrix		Alpha;
 const double	sfac	= 1.0/2.0;

#ifdef FORCE_GRG_CYLINDERS
       Alpha		= GrgCylP (pC, pkix);
       Alpha		= c33Matrix_sum (Alpha, GrgCylP (pC, pkiy));
       Alpha		= c33Matrix_sum (Alpha, GrgCylP (pC, pkiz));
       Alpha		= c33Matrix_Complex_product (Alpha, xy_complex (sfac, 0.0));
#else
       Alpha		= InfCylP (pC, pkix, pYtable, pJtable);
       Alpha		= c33Matrix_sum (Alpha, InfCylP (pC, pkiy, pYtable, pJtable));
       Alpha		= c33Matrix_sum (Alpha, InfCylP (pC, pkiz, pYtable, pJtable));
       Alpha		= c33Matrix_Complex_product (Alpha, xy_complex (sfac, 0.0));
#endif
 return (Alpha);
}

void		Effective_Permittivities	(PolSARproSim_Record *pPR)
{
 const double	bsecl	=	POLSARPROSIM_SAR_BRANCH_FACTOR*(pPR->azimuth_resolution + pPR->slant_range_resolution);
 double			dsecl;
 Leaf			leaf1;
 double			costheta, theta, phi;
 double			d_costheta, d_phi;
 int			i_costheta, i_phi;
 int			Ntheta, Nphi;
 d3Vector		leaf_centre	= Zero_d3Vector ();
 d3Vector		stem_centre	= Zero_d3Vector ();
 double			leaf_d1, leaf_d2, leaf_d3;
 int			leaf_species;
 double			leaf_moisture;
 Complex		leaf_permittivity, leaf_epsm1;
 double			stem_d1, stem_d2, stem_d3;
 int			stem_species;
 double			stem_moisture;
 Complex		stem_permittivity, stem_epsm1;
 c33Matrix		Alpha				= Zero_c33Matrix ();
 c33Matrix		Alpha_Stem_Sum		= Zero_c33Matrix ();
 c33Matrix		Alpha_Leaf_Sum		= Zero_c33Matrix ();
 Complex		scale_factor;
 c33Matrix		ShortVegi_EpsEff	= Idem_c33Matrix ();
 double			stemL1, stemL2, stemL3;
 double			leafL1, leafL2, leafL3;
 c33Matrix		CrownTert_EpsEff	= Idem_c33Matrix ();
 Tree			tree1;
 int			itree;
 int			Ntrees;
 double			primary_branch_length;
 double			primary_branch_radius;
 double			primary_branch_count;
 double			secondary_branch_length;
 double			secondary_branch_radius;
 double			secondary_branch_count;
 double			tertiary_branch_length;
 double			tertiary_branch_radius;
 Branch			*pB;
 long			iBranch;
 double			tertiary_branch_vol_frac;
 double			tertiary_leaf_vol_frac;
 c33Matrix		Alpha_Trunk_Sum				= Zero_c33Matrix ();
 c33Matrix		Alpha_Primary_Sum			= Zero_c33Matrix ();
 c33Matrix		Alpha_Secondary_Sum			= Zero_c33Matrix ();
 c33Matrix		Alpha_Dry_Sum				= Zero_c33Matrix ();
 c33Matrix		CrownTrunk_EpsEff			= Idem_c33Matrix ();
 c33Matrix		CrownPrimary_EpsEff			= Idem_c33Matrix ();
 c33Matrix		CrownSecondary_EpsEff		= Idem_c33Matrix ();
 c33Matrix		CrownDry_EpsEff				= Idem_c33Matrix ();
 c33Matrix		CrownLiving_EpsEff			= Idem_c33Matrix ();
 double			crown_trunk_vol_frac		= 0.0;
 double			crown_primary_vol_frac		= 0.0;
 double			crown_secondary_vol_frac	= 0.0;
 double			crown_dry_vol_frac			= 0.0;
 double			crown_volume, dry_crown_volume;
 double			trunk_length, trunk_count, trunk_volume, trunk_number_density;
 double			primary_length, primary_count, primary_volume, primary_number_density;
 double			secondary_length, secondary_count, secondary_volume, secondary_number_density;
 double			dry_length, dry_count, dry_volume, dry_number_density;
 int			n_segments, i_seg;
 int			rtn_value;
 Cylinder		Cyl1;
 d3Vector		ki, kix, ksx, kiy, ksy, kiz, ksz;
 double			thetai, phii, thetas, phis;
 Yn_Lookup		Ytable;
 Jn_Lookup		Jtable;
 Complex		e, ez;
 double			kro2;
 Complex		ko2, koz2, koz;
 Complex		ke2, kez2, kez;
 double			rfac, aoverlamda;
 d3Vector		t_axis, t_base;
 double			tertiary_branch_volume;
 Complex		tbvinv;

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to Effective_Permittivities ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to Effective_Permittivities ... \n");
 fflush  (pPR->pLogFile);
 /**************/
 /* Initialise */
 /**************/
 Create_Leaf		(&leaf1);
 Create_Tree		(&tree1);
 Create_Cylinder	(&Cyl1);
/*********************************************/
/* Initialise Bessel function look-up tables */
/*********************************************/
 rtn_value	= Initialise_Standard_Jnlookup (&Jtable);
 rtn_value	= Initialise_Standard_Ynlookup (&Ytable);
/**************************/
/* Establish wave vectors */
/**************************/
 ki			= Polar_Assign_d3Vector (pPR->k0, pPR->incidence_angle[0], 0.0);
 thetai		= 2.0*atan(1.0);
 phii		= 0.0;
 thetas		= thetai;
 phis		= phii;
 kix		= Polar_Assign_d3Vector (pPR->k0, thetai, phii);
 ksx		= Polar_Assign_d3Vector (pPR->k0, thetas, phis);
 thetai		= 2.0*atan(1.0);
 phii		= 2.0*atan(1.0);
 thetas		= thetai;
 phis		= phii;
 kiy		= Polar_Assign_d3Vector (pPR->k0, thetai, phii);
 ksy		= Polar_Assign_d3Vector (pPR->k0, thetas, phis);
 thetai		= 0.0;
 phii		= 0.0;
 thetas		= thetai;
 phis		= phii;
 kiz		= Polar_Assign_d3Vector (pPR->k0, thetai, phii);
 ksz		= Polar_Assign_d3Vector (pPR->k0, thetas, phis);
/****************************************************/
/* No trunks, primaries or secondaries in the HEDGE */
/****************************************************/
 if (pPR->species != POLSARPROSIM_HEDGE) {
 /*********************************************/
 /* Living crown trunk, primary and secondary */
 /*********************************************/
#ifdef VERBOSE_POLSARPROSIM
  printf ("\n");
  printf ("Calculating dry, trunk, primary and secondary effective permittivities  ... \n");
  printf ("\n");
#endif
  fprintf (pPR->pLogFile, "Calculating dry, trunk, primary and secondary effective permittivities  ... \n");
  fflush  (pPR->pLogFile);
  Ntrees			= POLSARPROSIM_ATTENUATION_TREES;
  trunk_count		= 0.0;
  primary_count		= 0.0;
  secondary_count	= 0.0;
  dry_count			= 0.0;
  crown_volume		= 0.0;
  dry_crown_volume	= 0.0;
  for (itree = 0; itree < Ntrees; itree++) {
   Realise_Tree	(&tree1, itree, pPR);
   /****************************/
   /* Stem subdivision control */
   /****************************/
   dsecl				 = POLSARPROSIM_SAR_BRANCH_FACTOR*tree1.CrownVolume.tail->d3;
   if (dsecl < FLT_EPSILON) {
    dsecl				 = bsecl;
   }
   if ((pPR->species != POLSARPROSIM_DECIDUOUS001) && (pPR->species != POLSARPROSIM_NULL_SPECIES)) {
    /**********************************/
    /* Stem contribution to dry crown */
    /**********************************/
	dry_crown_volume	+= tree1.CrownVolume.tail->volume;
    pB					 = tree1.Stem.head;
    trunk_length		 = pB->l;
	if (bsecl < dsecl) {
     n_segments			 = (int) (trunk_length / bsecl);
	} else {
	 n_segments			 = (int) (trunk_length / dsecl);
	}
    if (n_segments < POLSARPROSIM_MIN_STEM_SEG_NUM) {
	 n_segments	= POLSARPROSIM_MIN_STEM_SEG_NUM;
    }
    for (i_seg=0; i_seg<n_segments; i_seg++) {
     rtn_value	= Cylinder_from_Branch (&Cyl1, pB, i_seg, n_segments);
	 if (Cyl1.base.x[2] > tree1.CrownVolume.tail->base.x[2]) {
	  if (Cyl1.base.x[2] < tree1.CrownVolume.tail->base.x[2]+tree1.CrownVolume.tail->d3) {
  	   Alpha				= CylinderPolarisability (&Cyl1, &kix, &kiy, &kiz, &Ytable, &Jtable);
	   Alpha_Dry_Sum		= c33Matrix_sum (Alpha_Dry_Sum, Alpha);
	   dry_volume			= DPI_RAD*Cyl1.radius*Cyl1.radius*Cyl1.length;
       crown_dry_vol_frac	+= dry_volume;
	   dry_count			+= 1.0;
	  }
	 }
    }
	/*************************************/
	/* Primary contribution to dry crown */
	/*************************************/
	pB	= tree1.Dry.head;
    for (iBranch=0L; iBranch < tree1.Dry.n; iBranch++) {
     dry_length		= pB->l;
     n_segments		= (int) (dry_length / bsecl);
     if (n_segments < 1) {
	  n_segments	= 1;
     }
     for (i_seg=0; i_seg<n_segments; i_seg++) {
      rtn_value				 = Cylinder_from_Branch (&Cyl1, pB, i_seg, n_segments);
  	  Alpha					 = CylinderPolarisability (&Cyl1, &kix, &kiy, &kiz, &Ytable, &Jtable);
	  Alpha_Dry_Sum			 = c33Matrix_sum (Alpha_Dry_Sum, Alpha);
	  dry_volume			 = DPI_RAD*Cyl1.radius*Cyl1.radius*Cyl1.length;
      crown_dry_vol_frac	+= dry_volume;
	  dry_count				+= 1.0;
     }
     pB	= pB->next;
    }
   }
   /****************/
   /* Living crown */
   /****************/
   crown_volume		+= tree1.CrownVolume.head->volume;
   pB				 = tree1.Stem.head;
   trunk_length		 = pB->l;
   if (bsecl < dsecl) {
    n_segments			 = (int) (trunk_length / bsecl);
   } else {
    n_segments			 = (int) (trunk_length / dsecl);
   }
   if (n_segments < POLSARPROSIM_MIN_STEM_SEG_NUM) {
	n_segments	= POLSARPROSIM_MIN_STEM_SEG_NUM;
   }
   for (i_seg=0; i_seg<n_segments; i_seg++) {
    rtn_value	= Cylinder_from_Branch (&Cyl1, pB, i_seg, n_segments);
	if (Cyl1.base.x[2] > tree1.CrownVolume.head->base.x[2]) {
  	 Alpha					 = CylinderPolarisability (&Cyl1, &kix, &kiy, &kiz, &Ytable, &Jtable);
	 Alpha_Trunk_Sum		 = c33Matrix_sum (Alpha_Trunk_Sum, Alpha);
	 trunk_volume			 = DPI_RAD*Cyl1.radius*Cyl1.radius*Cyl1.length;
     crown_trunk_vol_frac	+= trunk_volume;
	 trunk_count			+= 1.0;
	}
   }
   pB	= tree1.Primary.head;
   for (iBranch=0L; iBranch < tree1.Primary.n; iBranch++) {
    primary_length	= pB->l;
    n_segments		= (int) (primary_length / bsecl);
    if (n_segments < 1) {
	 n_segments	= 1;
    }
    for (i_seg=0; i_seg<n_segments; i_seg++) {
     rtn_value				 = Cylinder_from_Branch (&Cyl1, pB, i_seg, n_segments);
   	 Alpha					 = CylinderPolarisability (&Cyl1, &kix, &kiy, &kiz, &Ytable, &Jtable);
	 Alpha_Primary_Sum		 = c33Matrix_sum (Alpha_Primary_Sum, Alpha);
	 primary_volume			 = DPI_RAD*Cyl1.radius*Cyl1.radius*Cyl1.length;
     crown_primary_vol_frac	+= primary_volume;
	 primary_count			+= 1.0;
    }
    pB	= pB->next;
   }
   pB	= tree1.Secondary.head;
   for (iBranch=0L; iBranch < tree1.Secondary.n; iBranch++) {
    secondary_length	= pB->l;
    n_segments		= (int) (secondary_length / bsecl);
    if (n_segments < 1) {
	 n_segments	= 1;
    }
    for (i_seg=0; i_seg<n_segments; i_seg++) {
     rtn_value					 = Cylinder_from_Branch (&Cyl1, pB, i_seg, n_segments);
  	 Alpha						 = CylinderPolarisability (&Cyl1, &kix, &kiy, &kiz, &Ytable, &Jtable);
	 Alpha_Secondary_Sum		 = c33Matrix_sum (Alpha_Secondary_Sum, Alpha);
	 secondary_volume			 = DPI_RAD*Cyl1.radius*Cyl1.radius*Cyl1.length;
     crown_secondary_vol_frac	+= secondary_volume;
	 secondary_count			+= 1.0;
    }
    pB	= pB->next;
   }
  }
  if ((pPR->species != POLSARPROSIM_DECIDUOUS001) && (pPR->species != POLSARPROSIM_NULL_SPECIES)) {
   crown_dry_vol_frac		/= dry_crown_volume;
   dry_number_density		 = dry_count / dry_crown_volume;
   scale_factor				 = xy_complex (dry_number_density/dry_count, 0.0);
   CrownDry_EpsEff			 = c33Matrix_sum (CrownDry_EpsEff, c33Matrix_Complex_product (Alpha_Dry_Sum, scale_factor));
  } else {
   crown_dry_vol_frac		= 0.0;
   dry_number_density		= 0.0;
   dry_count				= 0.0;
   dry_crown_volume			= 0.0;
  }
  crown_trunk_vol_frac		/= crown_volume;
  trunk_number_density		 = trunk_count / crown_volume;
  scale_factor				 = xy_complex (trunk_number_density/trunk_count, 0.0);
  CrownTrunk_EpsEff			 = c33Matrix_sum (CrownTrunk_EpsEff, c33Matrix_Complex_product (Alpha_Trunk_Sum, scale_factor));
  crown_primary_vol_frac	/= crown_volume;
  primary_number_density	 = primary_count / crown_volume;
  scale_factor				 = xy_complex (primary_number_density/primary_count, 0.0);
  CrownPrimary_EpsEff		 = c33Matrix_sum (CrownPrimary_EpsEff, c33Matrix_Complex_product (Alpha_Primary_Sum, scale_factor));
  crown_secondary_vol_frac	/= crown_volume;
  secondary_number_density	 = secondary_count / crown_volume;
  scale_factor				 = xy_complex (secondary_number_density/secondary_count, 0.0);
  CrownSecondary_EpsEff		 = c33Matrix_sum (CrownSecondary_EpsEff, c33Matrix_Complex_product (Alpha_Secondary_Sum, scale_factor));
/*****************************/
/* Output results to logfile */
/*****************************/
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "Crown trunk volume fraction\t\t= %10.3e\n", crown_trunk_vol_frac);
  fprintf (pPR->pLogFile, "Crown trunk segment number\t\t= %10.3e\n", trunk_count);
  fprintf (pPR->pLogFile, "Crown volume\t\t\t\t= %10.3e m^3\n", crown_volume);
  fprintf (pPR->pLogFile, "Crown trunk segment number density\t= %10.3e\n", trunk_number_density);
  fprintf (pPR->pLogFile, "Crown trunk effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownTrunk_EpsEff.m[0].x, fabs(CrownTrunk_EpsEff.m[0].y));
  fprintf (pPR->pLogFile, "Crown trunk effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownTrunk_EpsEff.m[4].x, fabs(CrownTrunk_EpsEff.m[4].y));
  fprintf (pPR->pLogFile, "Crown trunk effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownTrunk_EpsEff.m[8].x, fabs(CrownTrunk_EpsEff.m[8].y));
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "Crown primary volume fraction\t\t= %10.3e\n", crown_primary_vol_frac);
  fprintf (pPR->pLogFile, "Crown primary segment number\t\t= %10.3e\n", primary_count);
  fprintf (pPR->pLogFile, "Crown volume\t\t\t\t= %10.3e m^3\n", crown_volume);
  fprintf (pPR->pLogFile, "Crown primary segment number density\t= %10.3e\n", primary_number_density);
  fprintf (pPR->pLogFile, "Crown primary effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownPrimary_EpsEff.m[0].x, fabs(CrownPrimary_EpsEff.m[0].y));
  fprintf (pPR->pLogFile, "Crown primary effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownPrimary_EpsEff.m[4].x, fabs(CrownPrimary_EpsEff.m[4].y));
  fprintf (pPR->pLogFile, "Crown primary effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownPrimary_EpsEff.m[8].x, fabs(CrownPrimary_EpsEff.m[8].y));
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "Crown secondary volume fraction\t\t= %10.3e\n", crown_secondary_vol_frac);
  fprintf (pPR->pLogFile, "Crown secondary segment number\t\t= %10.3e\n", secondary_count);
  fprintf (pPR->pLogFile, "Crown volume\t\t\t\t= %10.3e m^3\n", crown_volume);
  fprintf (pPR->pLogFile, "Crown secondary segment number density\t= %10.3e\n", secondary_number_density);
  fprintf (pPR->pLogFile, "Crown secondary effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownSecondary_EpsEff.m[0].x, fabs(CrownSecondary_EpsEff.m[0].y));
  fprintf (pPR->pLogFile, "Crown secondary effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownSecondary_EpsEff.m[4].x, fabs(CrownSecondary_EpsEff.m[4].y));
  fprintf (pPR->pLogFile, "Crown secondary effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownSecondary_EpsEff.m[8].x, fabs(CrownSecondary_EpsEff.m[8].y));
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "\n");
  fprintf (pPR->pLogFile, "Crown dry volume fraction\t\t= %10.3e\n", crown_dry_vol_frac);
  fprintf (pPR->pLogFile, "Crown dry segment number\t\t= %10.3e\n", dry_count);
  fprintf (pPR->pLogFile, "Crown dry volume\t\t\t= %10.3e m^3\n", dry_crown_volume);
  fprintf (pPR->pLogFile, "Crown dry segment number density\t= %10.3e\n", dry_number_density);
  fprintf (pPR->pLogFile, "Crown dry effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownDry_EpsEff.m[0].x, fabs(CrownDry_EpsEff.m[0].y));
  fprintf (pPR->pLogFile, "Crown dry effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownDry_EpsEff.m[4].x, fabs(CrownDry_EpsEff.m[4].y));
  fprintf (pPR->pLogFile, "Crown dry effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownDry_EpsEff.m[8].x, fabs(CrownDry_EpsEff.m[8].y));
  fprintf (pPR->pLogFile, "\n");
 }
/*********************************************************/
/* Isotropic short vegetation layer: uses GRG model only */
/*********************************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Calculating short vegetation effective permittivity  ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Calculating short vegetation effective permittivity  ... \n");
 fflush  (pPR->pLogFile);
 theta				= 0.0;
 phi				= 0.0;
 /********************************************/
 /* Realise a stem (needle) to find L values */
 /********************************************/
 stem_species		= POLSARPROSIM_PINE_NEEDLE;
 stem_d1			= POLSARPROSIM_SHORTV_STEM_LENGTH;
 stem_d2			= POLSARPROSIM_SHORTV_STEM_RADIUS;
 stem_d3			= POLSARPROSIM_SHORTV_STEM_RADIUS;
 stem_moisture		= Leaf_Moisture	(pPR->species);
 stem_permittivity	= vegetation_permittivity (stem_moisture, pPR->frequency);
 Assign_Leaf		(&leaf1, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, stem_moisture, stem_permittivity, stem_centre);
 Leaf_Depolarization_Factors (&leaf1, &stemL1, &stemL2, &stemL3);
 pPR->ShortVegi_stemL1	= stemL1;
 pPR->ShortVegi_stemL2	= stemL2;
 pPR->ShortVegi_stemL3	= stemL3;
 /***********************************/
 /* Realise a leaf to find L values */
 /***********************************/
 leaf_species		= POLSARPROSIM_DECIDUOUS_LEAF;
 leaf_d1			= POLSARPROSIM_SHORTV_LEAF_LENGTH;
 leaf_d2			= POLSARPROSIM_SHORTV_LEAF_WIDTH;
 leaf_d3			= POLSARPROSIM_SHORTV_LEAF_THICKNESS;
 leaf_moisture		= Leaf_Moisture	(pPR->species);
 leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
 Assign_Leaf	(&leaf1, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, leaf_moisture, leaf_permittivity, leaf_centre);
 Leaf_Depolarization_Factors (&leaf1, &leafL1, &leafL2, &leafL3);
 pPR->ShortVegi_leafL1	= leafL1;
 pPR->ShortVegi_leafL2	= leafL2;
 pPR->ShortVegi_leafL3	= leafL3;
/****************************************************/
/* Average polarisabilities over orientation angles */
/****************************************************/
 Ntheta				= POLSARPROSIM_SHORT_VEGI_NTHETA;
 Nphi				= POLSARPROSIM_SHORT_VEGI_NPHI;
 d_costheta			= 2.0/Ntheta;
 d_phi				= 2.0*DPI_RAD/Nphi;
 for (i_costheta = 0; i_costheta < Ntheta; i_costheta++) {
  costheta	= i_costheta*d_costheta + d_costheta/2.0 - 1.0;
  theta		= acos(costheta);
  for (i_phi = 0; i_phi < Nphi; i_phi++) {
   phi	= i_phi*d_phi + d_phi/2.0;
   /**********************/
   /* Stem contribution  */
   /**********************/
   stem_moisture		= Leaf_Moisture	(pPR->species);
   stem_permittivity	= vegetation_permittivity (stem_moisture, pPR->frequency);
   stem_epsm1			= xy_complex (stem_permittivity.x-1.0, stem_permittivity.y);
   Assign_Leaf	(&leaf1, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, stem_moisture, stem_permittivity, stem_centre);
   Alpha				= Leaf_Polarisability (&leaf1, stemL1, stemL2, stemL3);
   Alpha_Stem_Sum		= c33Matrix_sum (Alpha_Stem_Sum, c33Matrix_Complex_product (Alpha, stem_epsm1));
   /*********************/
   /* Leaf contribution */
   /*********************/
   leaf_moisture		= Leaf_Moisture	(pPR->species);
   leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
   leaf_epsm1			= xy_complex (leaf_permittivity.x-1.0, leaf_permittivity.y);
   Assign_Leaf	(&leaf1, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, leaf_moisture, leaf_permittivity, leaf_centre);
   Alpha				= Leaf_Polarisability (&leaf1, leafL1, leafL2, leafL3);
   Alpha_Leaf_Sum		= c33Matrix_sum (Alpha_Leaf_Sum, c33Matrix_Complex_product (Alpha, leaf_epsm1));
  }
 }
 scale_factor			= xy_complex (pPR->shrt_vegi_stem_vol_frac/(Ntheta*Nphi), 0.0);
 ShortVegi_EpsEff		= c33Matrix_sum (ShortVegi_EpsEff, c33Matrix_Complex_product (Alpha_Stem_Sum, scale_factor));
 scale_factor			= xy_complex (pPR->shrt_vegi_leaf_vol_frac/(Ntheta*Nphi), 0.0);
 ShortVegi_EpsEff		= c33Matrix_sum (ShortVegi_EpsEff, c33Matrix_Complex_product (Alpha_Leaf_Sum, scale_factor));
 /******************************************************/
 /* Ensure perfect isotropy with this minor correction */
 /******************************************************/
 e						= complex_add (complex_add (ShortVegi_EpsEff.m[0], ShortVegi_EpsEff.m[4]), ShortVegi_EpsEff.m[8]);
 e						= complex_rmul (e, 1.0/3.0);
 ShortVegi_EpsEff		= Zero_c33Matrix ();
 ShortVegi_EpsEff.m[0]	= e;
 ShortVegi_EpsEff.m[4]	= e;
 ShortVegi_EpsEff.m[8]	= e;
/*****************************/
/* Output results to logfile */
/*****************************/
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Short vegetation effective permittivity = %10.3e + j %10.3e  ... \n", ShortVegi_EpsEff.m[0].x, fabs(ShortVegi_EpsEff.m[0].y));
 fprintf (pPR->pLogFile, "Short vegetation effective permittivity = %10.3e + j %10.3e  ... \n", ShortVegi_EpsEff.m[4].x, fabs(ShortVegi_EpsEff.m[4].y));
 fprintf (pPR->pLogFile, "Short vegetation effective permittivity = %10.3e + j %10.3e  ... \n", ShortVegi_EpsEff.m[8].x, fabs(ShortVegi_EpsEff.m[8].y));
 fprintf (pPR->pLogFile, "\n");
/*************************/
/* Living crown tertiary */
/*************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Calculating crown tertiary effective permittivity  ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Calculating crown tertiary effective permittivity  ... \n");
 fflush  (pPR->pLogFile);
/**************************************/
/* Establish the tertiary branch size */
/**************************************/
 if (pPR->species == POLSARPROSIM_HEDGE) {
  tertiary_branch_length		= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH;
  tertiary_branch_radius		= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS;
  pPR->primary_branch_length	= 0.0;
  pPR->primary_branch_radius	= 0.0;
  pPR->secondary_branch_length	= 0.0;
  pPR->secondary_branch_radius	= 0.0;
  pPR->tertiary_branch_length	= tertiary_branch_length;
  pPR->tertiary_branch_radius	= tertiary_branch_radius;
 } else {
  if (pPR->Trees > POLSARPROSIM_ATTENUATION_TREES) {
   Ntrees	= POLSARPROSIM_ATTENUATION_TREES;
  } else {
   Ntrees	= pPR->Trees;
  }
  primary_branch_length		= 0.0;
  primary_branch_radius		= 0.0;
  primary_branch_count		= 0.0;
  secondary_branch_length	= 0.0;
  secondary_branch_radius	= 0.0;
  secondary_branch_count	= 0.0;
  for (itree = 0; itree < Ntrees; itree++) {
   Realise_Tree	(&tree1, itree, pPR);
   pB	= tree1.Primary.head;
   for (iBranch=0L; iBranch < tree1.Primary.n; iBranch++) {
    primary_branch_length	+= pB->l;
    primary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
	primary_branch_count	+= 1.0;
    pB	= pB->next;
   }
   pB	= tree1.Secondary.head;
   for (iBranch=0L; iBranch < tree1.Secondary.n; iBranch++) {
    secondary_branch_length	+= pB->l;
    secondary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
	secondary_branch_count	+= 1.0;
    pB	= pB->next;
   }
  }
  primary_branch_length			/= primary_branch_count;
  primary_branch_radius			/= primary_branch_count;
  secondary_branch_length		/= secondary_branch_count;
  secondary_branch_radius		/= secondary_branch_count;
  tertiary_branch_length		 = secondary_branch_length*secondary_branch_length/primary_branch_length;
  tertiary_branch_radius		 = secondary_branch_radius*secondary_branch_radius/primary_branch_radius;
  pPR->primary_branch_length	 = primary_branch_length;
  pPR->primary_branch_radius	 = primary_branch_radius;
  pPR->secondary_branch_length	 = secondary_branch_length;
  pPR->secondary_branch_radius	 = secondary_branch_radius;
  pPR->tertiary_branch_length	 = tertiary_branch_length;
  pPR->tertiary_branch_radius	 = tertiary_branch_radius;
  }
/***************************************************************************/
/* Make a choice of scattering model for tertiary branches based upon size */
/***************************************************************************/
 pPR->Grg_Flag		= 0;
 aoverlamda			= pPR->tertiary_branch_radius / pPR->wavelength;
 stem_moisture		= Tertiary_Branch_Moisture	(pPR->species);
 stem_permittivity	= vegetation_permittivity	(stem_moisture, pPR->frequency);
 rfac				= GRG_VALIDITY_FACTOR/(4.0*DPI_RAD*sqrt(stem_permittivity.r));
 if (aoverlamda > rfac) {
  pPR->Grg_Flag		= 1;
 }
/*******************************************/
/* Report tertiary branch scattering model */
/*******************************************/
 if (pPR->Grg_Flag == 0) {
  fprintf (pPR->pLogFile, "\nUsing GRG model for tertiary branches.\n");
 } else {
  fprintf (pPR->pLogFile, "\nUsing INF model for tertiary branches.\n");
 }
/*******************************************************************************/
/* Now find effective permittivity by averaging polarisabilities as before ... */
/*******************************************************************************/
 Ntheta				= POLSARPROSIM_TERTIARY_NTHETA;
 Nphi				= POLSARPROSIM_TERTIARY_NPHI;
 d_costheta			= 2.0/Ntheta;
 d_phi				= 2.0*DPI_RAD/Nphi;
 stem_d1			= tertiary_branch_length;
 stem_d2			= tertiary_branch_radius;
 stem_d3			= stem_d2;
 stem_moisture		= Tertiary_Branch_Moisture	(pPR->species);
 stem_permittivity	= vegetation_permittivity	(stem_moisture, pPR->frequency);
 theta				= 0.0;
 phi				= 0.0;
 Assign_Leaf	(&leaf1, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, stem_moisture, stem_permittivity, stem_centre);
 Leaf_Depolarization_Factors (&leaf1, &stemL1, &stemL2, &stemL3);
 pPR->Tertiary_branchL1	= stemL1;
 pPR->Tertiary_branchL2	= stemL2;
 pPR->Tertiary_branchL3	= stemL3;
 Alpha_Stem_Sum			= Zero_c33Matrix ();
 t_base					= Cartesian_Assign_d3Vector (0.0, 0.0, 0.0);
 tertiary_branch_volume	= DPI_RAD*tertiary_branch_radius*tertiary_branch_radius*tertiary_branch_length;
 tbvinv					= xy_complex (1.0/tertiary_branch_volume, 0.0);
 /********************************/
 /* Tertiary branch contribution */
 /********************************/
 for (i_costheta = 0; i_costheta < Ntheta; i_costheta++) {
  costheta	= i_costheta*d_costheta + d_costheta/2.0 - 1.0;
  theta		= acos(costheta);
  for (i_phi = 0; i_phi < Nphi; i_phi++) {
   phi	= i_phi*d_phi + d_phi/2.0;
   stem_moisture		= Tertiary_Branch_Moisture	(pPR->species);
   stem_permittivity	= vegetation_permittivity	(stem_moisture, pPR->frequency);
   if (pPR->Grg_Flag == 0) {
    /*********************************/
    /* Small branches uses GRG model */
    /*********************************/
    stem_epsm1			= xy_complex (stem_permittivity.x-1.0, stem_permittivity.y);
    Assign_Leaf	(&leaf1, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, stem_moisture, stem_permittivity, stem_centre);
    Alpha				= Leaf_Polarisability (&leaf1, stemL1, stemL2, stemL3);
    Alpha_Stem_Sum		= c33Matrix_sum (Alpha_Stem_Sum, c33Matrix_Complex_product (Alpha, stem_epsm1));
   } else {
    /************************************************************/
    /* Large branches use the truncated infinite cylinder model */
    /************************************************************/
    t_axis				= Polar_Assign_d3Vector (1.0, theta, phi);
	Assign_Cylinder (&Cyl1, tertiary_branch_length, tertiary_branch_radius, stem_permittivity, t_axis, t_base);
  	Alpha				= CylinderPolarisability (&Cyl1, &kix, &kiy, &kiz, &Ytable, &Jtable);
	Alpha_Stem_Sum		= c33Matrix_sum (Alpha_Stem_Sum, c33Matrix_Complex_product (Alpha, tbvinv));
   }
  }
 }
 switch (pPR->species) {
  case POLSARPROSIM_HEDGE:			tertiary_branch_vol_frac	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_VOL_FRAC;			break;
  case POLSARPROSIM_PINE001:		tertiary_branch_vol_frac	= POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC;		break;
  case POLSARPROSIM_PINE002:		tertiary_branch_vol_frac	= POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC;		break;
  case POLSARPROSIM_PINE003:		tertiary_branch_vol_frac	= POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC;		break;
  case POLSARPROSIM_DECIDUOUS001:	tertiary_branch_vol_frac	= POLSARPROSIM_DECIDUOUS001_TERTIARY_BRANCH_VOL_FRAC;	break;
  default:							tertiary_branch_vol_frac	= 0.0;	break;
 }
 scale_factor			= xy_complex (tertiary_branch_vol_frac/(Ntheta*Nphi), 0.0);
 CrownTert_EpsEff		= c33Matrix_sum (CrownTert_EpsEff, c33Matrix_Complex_product (Alpha_Stem_Sum, scale_factor));
 /*********************/
 /* Leaf contribution */
 /*********************/
 leaf_species		= Leaf_Species		(pPR->species);
 leaf_d1			= Leaf_Dimension_1	(pPR->species);
 leaf_d2			= Leaf_Dimension_2	(pPR->species);
 leaf_d3			= Leaf_Dimension_3	(pPR->species);
 leaf_centre		= Cartesian_Assign_d3Vector (0.0, 0.0, 0.0);
 theta				= 0.0;
 phi				= 0.0;
 leaf_moisture		= Leaf_Moisture		(pPR->species);
 leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
 Assign_Leaf	(&leaf1, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, leaf_moisture, leaf_permittivity, leaf_centre);
 Leaf_Depolarization_Factors (&leaf1, &leafL1, &leafL2, &leafL3);
 pPR->Tertiary_leafL1	= leafL1;
 pPR->Tertiary_leafL2	= leafL2;
 pPR->Tertiary_leafL3	= leafL3;
 Alpha_Leaf_Sum		= Zero_c33Matrix ();
 for (i_costheta = 0; i_costheta < Ntheta; i_costheta++) {
  costheta	= i_costheta*d_costheta + d_costheta/2.0 - 1.0;
  theta		= acos(costheta);
  for (i_phi = 0; i_phi < Nphi; i_phi++) {
   phi	= i_phi*d_phi + d_phi/2.0;
   leaf_moisture		= Leaf_Moisture	(pPR->species);
   leaf_permittivity	= vegetation_permittivity	(leaf_moisture, pPR->frequency);
   leaf_epsm1			= xy_complex (leaf_permittivity.x-1.0, leaf_permittivity.y);
   Assign_Leaf	(&leaf1, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, leaf_moisture, leaf_permittivity, leaf_centre);
   Alpha				= Leaf_Polarisability (&leaf1, leafL1, leafL2, leafL3);
   Alpha_Leaf_Sum		= c33Matrix_sum (Alpha_Leaf_Sum, c33Matrix_Complex_product (Alpha, leaf_epsm1));
  }
 }
 switch (pPR->species) {
  case POLSARPROSIM_HEDGE:			tertiary_leaf_vol_frac	= POLSARPROSIM_HEDGE_FOLIAGE_VOL_FRAC;			break;
  case POLSARPROSIM_PINE001:		tertiary_leaf_vol_frac	= POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC;		break;
  case POLSARPROSIM_PINE002:		tertiary_leaf_vol_frac	= POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC;		break;
  case POLSARPROSIM_PINE003:		tertiary_leaf_vol_frac	= POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC;		break;
  case POLSARPROSIM_DECIDUOUS001:	tertiary_leaf_vol_frac	= POLSARPROSIM_DECIDUOUS001_FOLIAGE_VOL_FRAC;	break;
  default:							tertiary_leaf_vol_frac	= 0.0;	break;
 }
 scale_factor			= xy_complex (tertiary_leaf_vol_frac/(Ntheta*Nphi), 0.0);
 CrownTert_EpsEff		= c33Matrix_sum (CrownTert_EpsEff, c33Matrix_Complex_product (Alpha_Leaf_Sum, scale_factor));
 /********************/
 /* Enforce isotropy */
 /********************/
 e						= complex_add (complex_add (CrownTert_EpsEff.m[0], CrownTert_EpsEff.m[4]), CrownTert_EpsEff.m[8]);
 e						= complex_rmul (e, 1.0/3.0);
 CrownTert_EpsEff		= Zero_c33Matrix ();
 CrownTert_EpsEff.m[0]	= e;
 CrownTert_EpsEff.m[4]	= e;
 CrownTert_EpsEff.m[8]	= e;
/******************************/
/* Output results to log file */
/******************************/
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Crown tertiary effective permittivity = %10.3e + j %10.3e  ... \n", CrownTert_EpsEff.m[0].x, fabs(CrownTert_EpsEff.m[0].y));
 fprintf (pPR->pLogFile, "Crown tertiary effective permittivity = %10.3e + j %10.3e  ... \n", CrownTert_EpsEff.m[4].x, fabs(CrownTert_EpsEff.m[4].y));
 fprintf (pPR->pLogFile, "Crown tertiary effective permittivity = %10.3e + j %10.3e  ... \n", CrownTert_EpsEff.m[8].x, fabs(CrownTert_EpsEff.m[8].y));
 fprintf (pPR->pLogFile, "\n");
/******************************************/
/* Combine contributions for living crown */
/******************************************/
 CrownLiving_EpsEff		= c33Matrix_sum (CrownLiving_EpsEff, c33Matrix_difference (CrownTrunk_EpsEff, Idem_c33Matrix ()));
 CrownLiving_EpsEff		= c33Matrix_sum (CrownLiving_EpsEff, c33Matrix_difference (CrownPrimary_EpsEff, Idem_c33Matrix ()));
 CrownLiving_EpsEff		= c33Matrix_sum (CrownLiving_EpsEff, c33Matrix_difference (CrownSecondary_EpsEff, Idem_c33Matrix ()));
 CrownLiving_EpsEff		= c33Matrix_sum (CrownLiving_EpsEff, c33Matrix_difference (CrownTert_EpsEff, Idem_c33Matrix ()));
/************************************************/
/* Rationalise effective permittivity estimates */
/* Calculate and store effective wavenumbers.   */
/************************************************/
 e						 = complex_rmul (complex_add (CrownDry_EpsEff.m[0], CrownDry_EpsEff.m[4]), 0.5);
 ez						 = CrownDry_EpsEff.m[8];
 CrownDry_EpsEff		 = Idem_c33Matrix ();
 CrownDry_EpsEff.m[0]	 = e;
 CrownDry_EpsEff.m[4]	 = e;
 CrownDry_EpsEff.m[8]	 = ez;
 pPR->e11_dry			 = e;
 pPR->e33_dry			 = ez;
 kro2					 = pPR->k0*sin(pPR->incidence_angle[0]);
 kro2					*= kro2;
 ko2					 = complex_rmul (e, pPR->k0*pPR->k0);
 koz2					 = xy_complex (ko2.x-kro2, ko2.y);
 koz					 = complex_sqrt (koz2);
 ke2					 = complex_rmul (ez, pPR->k0*pPR->k0);
 kez2					 = xy_complex (ke2.x-kro2, ke2.y);
 kez2					 = complex_mul (kez2, complex_div (e ,ez));
 kez					 = complex_sqrt(kez2);
 ke2					 = complex_add (kez2, xy_complex (kro2, 0.0));
 pPR->ko2_dry			 = ko2;
 pPR->koz2_dry			 = koz2;
 pPR->koz_dry			 = koz;
 pPR->ke2_dry			 = ke2;
 pPR->kez2_dry			 = kez2;
 pPR->kez_dry			 = kez;
 e						 = complex_rmul (complex_add (CrownLiving_EpsEff.m[0], CrownLiving_EpsEff.m[4]), 0.5);
 ez						 = CrownLiving_EpsEff.m[8];
 CrownLiving_EpsEff		 = Idem_c33Matrix ();
 CrownLiving_EpsEff.m[0] = e;
 CrownLiving_EpsEff.m[4] = e;
 CrownLiving_EpsEff.m[8] = ez;
 pPR->e11_living		 = e;
 pPR->e33_living		 = ez;
 kro2					 = pPR->k0*sin(pPR->incidence_angle[0]);
 kro2					*= kro2;
 ko2					 = complex_rmul (e, pPR->k0*pPR->k0);
 koz2					 = xy_complex (ko2.x-kro2, ko2.y);
 koz					 = complex_sqrt (koz2);
 ke2					 = complex_rmul (ez, pPR->k0*pPR->k0);
 kez2					 = xy_complex (ke2.x-kro2, ke2.y);
 kez2					 = complex_mul (kez2, complex_div (e ,ez));
 kez					 = complex_sqrt(kez2);
 ke2					 = complex_add (kez2, xy_complex (kro2, 0.0));
 pPR->ko2_living		 = ko2;
 pPR->koz2_living		 = koz2;
 pPR->koz_living		 = koz;
 pPR->ke2_living		 = ke2;
 pPR->kez2_living		 = kez2;
 pPR->kez_living		 = kez;
 e						 = complex_rmul (complex_add (ShortVegi_EpsEff.m[0], ShortVegi_EpsEff.m[4]), 0.5);
 ez						 = ShortVegi_EpsEff.m[8];
 ShortVegi_EpsEff		 = Idem_c33Matrix ();
 ShortVegi_EpsEff.m[0]	 = e;
 ShortVegi_EpsEff.m[4]	 = e;
 ShortVegi_EpsEff.m[8]	 = ez;
 pPR->e11_short			 = e;
 pPR->e33_short			 = ez;
 kro2					 = pPR->k0*sin(pPR->incidence_angle[0]);
 kro2					*= kro2;
 ko2					 = complex_rmul (e, pPR->k0*pPR->k0);
 koz2					 = xy_complex (ko2.x-kro2, ko2.y);
 koz					 = complex_sqrt (koz2);
 ke2					 = complex_rmul (ez, pPR->k0*pPR->k0);
 kez2					 = xy_complex (ke2.x-kro2, ke2.y);
 kez2					 = complex_mul (kez2, complex_div (e ,ez));
 kez					 = complex_sqrt(kez2);
 ke2					 = complex_add (kez2, xy_complex (kro2, 0.0));
 pPR->ko2_short			 = ko2;
 pPR->koz2_short		 = koz2;
 pPR->koz_short			 = koz;
 pPR->ke2_short			 = ke2;
 pPR->kez2_short		 = kez2;
 pPR->kez_short			 = kez;
/******************************/
/* Output results to log file */
/******************************/
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Consolidated effective permittivities:");
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Crown dry effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownDry_EpsEff.m[0].x, fabs(CrownDry_EpsEff.m[0].y));
 fprintf (pPR->pLogFile, "Crown dry effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownDry_EpsEff.m[4].x, fabs(CrownDry_EpsEff.m[4].y));
 fprintf (pPR->pLogFile, "Crown dry effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownDry_EpsEff.m[8].x, fabs(CrownDry_EpsEff.m[8].y));
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Crown living effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownLiving_EpsEff.m[0].x, fabs(CrownLiving_EpsEff.m[0].y));
 fprintf (pPR->pLogFile, "Crown living effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownLiving_EpsEff.m[4].x, fabs(CrownLiving_EpsEff.m[4].y));
 fprintf (pPR->pLogFile, "Crown living effective permittivity\t= %10.3e + j %10.3e  ... \n", CrownLiving_EpsEff.m[8].x, fabs(CrownLiving_EpsEff.m[8].y));
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Short vegetation effective permittivity = %10.3e + j %10.3e  ... \n", ShortVegi_EpsEff.m[0].x, fabs(ShortVegi_EpsEff.m[0].y));
 fprintf (pPR->pLogFile, "Short vegetation effective permittivity = %10.3e + j %10.3e  ... \n", ShortVegi_EpsEff.m[4].x, fabs(ShortVegi_EpsEff.m[4].y));
 fprintf (pPR->pLogFile, "Short vegetation effective permittivity = %10.3e + j %10.3e  ... \n", ShortVegi_EpsEff.m[8].x, fabs(ShortVegi_EpsEff.m[8].y));
 fprintf (pPR->pLogFile, "\n");
/***********/
/* Tidy up */
/***********/
 Destroy_Tree		(&tree1);
 Destroy_Leaf		(&leaf1);
 Destroy_Cylinder	(&Cyl1);
 rtn_value	= Delete_Jnlookup		(&Jtable);
 rtn_value	= Delete_Ynlookup		(&Ytable);
/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to Effective_Permittivities\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to Effective_Permittivities\n\n");
 fflush  (pPR->pLogFile);
/********************************/
/* Increment progress indicator */
/********************************/
 pPR->progress++;
/********************************/
/* Report progress if requested */
/********************************/
#ifdef POLSARPROSIM_MAX_PROGRESS
 PolSARproSim_indicate_progress (pPR);
#endif
 return;
}

/*******************************/
/* Attenuation lookup routines */
/*******************************/

int			Lookup_Direct_Attenuation		(d3Vector r, PolSARproSim_Record *pPR, double *gH, double *gV)
{
 const double		x		= r.x[0];
 const double		y		= r.x[1];
 const double		z		= r.x[2];
 const double		Gxy		= ground_height (pPR, x, y);
 const double		Deltaz	= z - Gxy;
 int				i;
 int				j;
 int				k;
 int				invol;
 long				l;
 int				n;

 *gH	= 1.0;
 *gV	= 1.0;
 i		= (int) ((x + (pPR->Amap.Ax/2.0))/pPR->Amap.dx);
 j		= (int) (((pPR->Ly/2.0) - pPR->Gap_Distance - y)/pPR->Amap.dy);
 k		= (int) (Deltaz/pPR->Amap.dz);
 if (k < 0) {
  k = 0;
 }
 invol	= 0;
 if ((i >= 0) && (i < pPR->Amap.Nx)) {
  if ((j >= 0) && (j < pPR->Amap.Ny)) {
   if (k < pPR->Amap.Nz) {
    invol	= !invol;
   }
  }
 }
 if (invol != 0) {
  l		= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
  *gH	= pPR->Amap.pDirectH[l];
  *gV	= pPR->Amap.pDirectV[l];
 } else {
  if (Deltaz < pPR->Amap.Ads) {
   n	= (int) ((pPR->Amap.Ads - Deltaz)/pPR->Amap.dds);
   if (n < 0) {
	n	= 0;
   } else {
    if (n > pPR->Amap.Nds - 1) {
	 n	= pPR->Amap.Nds - 1;
	}
   }
   *gH	= pPR->Amap.pDirectShortH[n];
   *gV	= pPR->Amap.pDirectShortV[n];
  }
 }
 return (NO_DIRECT_ATTENUATION_LOOKUP_ERRORS);
}

int			Lookup_Bounce_Attenuation		(d3Vector r, PolSARproSim_Record *pPR, double *gH, double *gV)
{
 const double		x		= r.x[0];
 const double		y		= r.x[1];
 const double		z		= r.x[2];
 const double		Gxy		= ground_height (pPR, x, y);
 const double		Deltaz	= z - Gxy;
 int				i;
 int				j;
 int				k;
 int				invol;
 long				l;
 int				n;

 *gH	= 1.0;
 *gV	= 1.0;
 i		= (int) ((x + (pPR->Amap.Ax/2.0))/pPR->Amap.dx);
 j		= (int) (((pPR->Ly/2.0) - pPR->Gap_Distance - y)/pPR->Amap.dy);
 k		= (int) (Deltaz/pPR->Amap.dz);
 if (k < 0) {
  k = 0;
 }
 invol	= 0;
 if ((i >= 0) && (i < pPR->Amap.Nx)) {
  if ((j >= 0) && (j < pPR->Amap.Ny)) {
   if (k < pPR->Amap.Nz) {
    invol	= !invol;
   }
  }
 }
 if (invol != 0) {
  l		= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
  *gH	= pPR->Amap.pBounceH[l];
  *gV	= pPR->Amap.pBounceV[l];
 } else {
  n	= (int) (Deltaz/pPR->Amap.dds);
  if (n < 0) {
   n	= 0;
  } else {
   if (n > pPR->Amap.Nds - 1) {
    n	= pPR->Amap.Nds - 1;
   }
  }
  *gH	= pPR->Amap.pDirectShortH[n];
  *gV	= pPR->Amap.pDirectShortV[n];
 }
 return (NO_DIRECT_ATTENUATION_LOOKUP_ERRORS);
}

/************************************/
/* Attenuation grid mapping routine */
/************************************/

void		Attenuation_Map					(PolSARproSim_Record *pPR)
{
 double		GshortH		= fabs (cos(pPR->incidence_angle[0])*pPR->koz_short.y);
 double		GshortV		= fabs (cos(pPR->incidence_angle[0])*pPR->kez_short.y);
 double		GdryH		= fabs (cos(pPR->incidence_angle[0])*pPR->koz_dry.y);
 double		GdryV		= fabs (cos(pPR->incidence_angle[0])*pPR->kez_dry.y);
 double		GlivingH	= fabs (cos(pPR->incidence_angle[0])*pPR->koz_living.y);
 double		GlivingV	= fabs (cos(pPR->incidence_angle[0])*pPR->kez_living.y);
 int		i, j, k;
 double		Sr			= pPR->Stand_Radius;
 double		Cr			= pPR->mean_crown_radius;
 double		Ls			= pPR->Shadow_Distance;
 double		Hs			= pPR->mean_tree_height;
 double		Gp			= pPR->Gap_Distance;
 double		Ll			= pPR->Layover_Distance;
 double		Lx			= pPR->Lx;
 double		Ly			= pPR->Ly;
 double		x, y, z;
 d3Vector	r;
 d3Vector	a;
 Ray		ray1;
 double		G, zed;
 double		GammaH, GammaV;
 int		itree;
 Tree		tree1;
 Crown		*pC;
 d3Vector	sa1, sa2;
 double		alpha1, alpha2;
 int		rtn_value;
 double		path_length;
 double		cos_theta	= cos(pPR->incidence_angle[0]);
 double		sin_theta	= sin(pPR->incidence_angle[0]);
 long		l;
 double		gHmin, gHmax;
 double		gVmin, gVmax;
 double		f1, f2;
 SIM_Record	Amap_Image;
 sim_pixel	p;
 int		px, py;
 d3Vector	n;
 d3Vector	ar;
 d3Vector	kihat, krhat;
 double		kidotn;
 char		*AmapFilename;
 double		dk;

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to Attenuation_Map ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to Attenuation_Map ... \n");
 fflush  (pPR->pLogFile);

/****************************/
/* Report attenuation rates */
/****************************/

 fprintf (pPR->pLogFile, "\nOne-way amplitude attenuation rates:\n");
 fprintf (pPR->pLogFile, "\nShort vegetation:\n");
 fprintf (pPR->pLogFile, "H-pol:\t%12.5e\n", GshortH);
 fprintf (pPR->pLogFile, "V-pol:\t%12.5e\n", GshortV);
 fprintf (pPR->pLogFile, "\nDry crown:\n");
 fprintf (pPR->pLogFile, "H-pol:\t%12.5e\n", GdryH);
 fprintf (pPR->pLogFile, "V-pol:\t%12.5e\n", GdryV);
 fprintf (pPR->pLogFile, "\nLiving crown:\n");
 fprintf (pPR->pLogFile, "H-pol:\t%12.5e\n", GlivingH);
 fprintf (pPR->pLogFile, "V-pol:\t%12.5e\n", GlivingV);
 fflush  (pPR->pLogFile);

 pPR->Amap.Ax	= Lx - 2.0*Gp;
 pPR->Amap.Ay	= Ly - Ll - 2.0*Gp;
 pPR->Amap.Az	= Hs;
 pPR->Amap.Nx	= 2*(((int)(pPR->Amap.Ax / (AMAP_RESOLUTION_FACTOR*pPR->azimuth_resolution)))/2)+1;
 if (pPR->Amap.Nx < 3) {
  pPR->Amap.Nx	= 3;
 }
 pPR->Amap.Ny	= 2*(((int)(pPR->Amap.Ay / (AMAP_RESOLUTION_FACTOR*pPR->ground_range_resolution[0])))/2)+1;
 if (pPR->Amap.Ny < 3) {
  pPR->Amap.Ny	= 3;
 }
 pPR->Amap.dx	= pPR->Amap.Ax/(double)(pPR->Amap.Nx-1);
 pPR->Amap.dy	= pPR->Amap.Ay/(double)(pPR->Amap.Ny-1);
 pPR->Amap.dz	= 0.5*(pPR->Amap.dx+pPR->Amap.dy);
 pPR->Amap.Nz	= 2*(((int)(pPR->Amap.Az / pPR->Amap.dz))/2)+1;
 if (pPR->Amap.Nz < 3) {
  pPR->Amap.Nz	= 3;
 }
 pPR->Amap.dz	= pPR->Amap.Az/(double)(pPR->Amap.Nz-1);
 pPR->Amap.n	= pPR->Amap.Nx*pPR->Amap.Ny*pPR->Amap.Nz;

 pPR->Amap.Nds	= AMAP_SHORT_VEGI_NZ;
 pPR->Amap.Ads	= pPR->shrt_vegi_depth;
 pPR->Amap.dds	= pPR->Amap.Ads / (double) (pPR->Amap.Nds - 1);

/**********************************/
/* Report attenuation map details */
/**********************************/

 fprintf (pPR->pLogFile, "\n");
 fprintf (pPR->pLogFile, "Stand_Radius     \t=\t%12.5e\n", Sr);
 fprintf (pPR->pLogFile, "Mean_crown_radius\t=\t%12.5e\n", Cr);
 fprintf (pPR->pLogFile, "Shadow_Distance  \t=\t%12.5e\n", Ls);
 fprintf (pPR->pLogFile, "mean_tree_height \t=\t%12.5e\n", Hs);
 fprintf (pPR->pLogFile, "Attenuation map width \t=\t%12.5em\n", pPR->Amap.Ax);
 fprintf (pPR->pLogFile, "Attenuation map length\t=\t%12.5em\n", pPR->Amap.Ay);
 fprintf (pPR->pLogFile, "Attenuation map depth \t=\t%12.5em\n", pPR->Amap.Az);
 fprintf (pPR->pLogFile, "Attenuation map dimensions:\t%5d\t%5d\t%5d\n", pPR->Amap.Nx, pPR->Amap.Ny, pPR->Amap.Nz);
 fprintf (pPR->pLogFile, "\n");
 fflush  (pPR->pLogFile);

/***************************************/
/* Allocate attenuation factor storage */
/***************************************/

 pPR->Amap.pDirectH			= (double*) calloc (pPR->Amap.n, sizeof (double));
 pPR->Amap.pDirectV			= (double*) calloc (pPR->Amap.n, sizeof (double));
 pPR->Amap.pBounceH			= (double*) calloc (pPR->Amap.n, sizeof (double));
 pPR->Amap.pBounceV			= (double*) calloc (pPR->Amap.n, sizeof (double));
 pPR->Amap.pDirectShortH	= (double*) calloc (AMAP_SHORT_VEGI_NZ, sizeof(double));
 pPR->Amap.pDirectShortV	= (double*) calloc (AMAP_SHORT_VEGI_NZ, sizeof(double));

/*******************************************************************/
/* For each attenuation grid location calculate BOUNCE attenuation */
/*******************************************************************/

 gHmin	=  1.0e+30;
 gHmax	= -1.0e+30;
 gVmin	=  1.0e+30;
 gVmax	= -1.0e+30;
 Create_Tree (&tree1);
 kihat	= Cartesian_Assign_d3Vector (0.0, sin_theta, -cos_theta);
 n		= Cartesian_Assign_d3Vector (-pPR->slope_x, -pPR->slope_y, 1.0);
 d3Vector_insitu_normalise (&n);
 kidotn	= d3Vector_scalar_product (kihat, n);
 krhat	= d3Vector_difference (kihat, d3Vector_double_multiply (n, 2.0*kidotn));
 a		= d3Vector_double_multiply (kihat, -1.0);
 ar		= d3Vector_double_multiply (krhat, -1.0);
 for (i=0; i<pPR->Amap.Nx; i++) {
  x		= ((double)i*pPR->Amap.dx) - pPR->Amap.Ax/2.0;
  for (j=0; j<pPR->Amap.Ny; j++) {
   y	=  (Ly/2.0) - Gp - ((double)j*pPR->Amap.dy);
   for (k=0; k<pPR->Amap.Nz; k++) {
    G	= ground_height (pPR, x, y);
	zed	= ((double)k*pPR->Amap.dz);
    z	= G + zed;
    r	= Cartesian_Assign_d3Vector (x, y, z);
	Assign_Ray_d3V (&ray1, &r, &ar);
    /***************************************************/
    /* Calculate total attenuation for this grid point */
	/***************************************************/
	GammaH	= 1.0;
	GammaV	= 1.0;
	/*****************************/
	/* Short veggie contribution */
	/*****************************/
	if (zed < pPR->shrt_vegi_depth) {
     GammaH	*= exp(-fabs(pPR->koz_short.y)*zed);
     GammaV	*= exp(-fabs(pPR->kez_short.y)*zed);
	} else {
     GammaH	*= exp(-fabs(pPR->koz_short.y)*pPR->shrt_vegi_depth);
     GammaV	*= exp(-fabs(pPR->kez_short.y)*pPR->shrt_vegi_depth);
	 /*****************************/
	 /* Living crown contribution */
	 /*****************************/
	 for (itree=0; itree<pPR->Trees; itree++) {
	  if (fabs (x-pPR->Tree_Location[itree].x) <= Cr) {
 	   if (y > (pPR->Tree_Location[itree].y - Cr)) {
	    /***********************************************/
	    /* Look for ray intersection with living crown */
	    /***********************************************/
	    Realise_Tree_Crown_Only (&tree1, itree, pPR);
	    pC			= tree1.CrownVolume.head;
	    rtn_value	= RayCrownIntersection (&ray1, pC, &sa1, &alpha1, &sa2, &alpha2);
        /**********************************************************************/
        /* Additional check for solution above crown apex for conical crowns  */
        /**********************************************************************/
	    if ((rtn_value == NO_RAYCROWN_ERRORS) && (pC->shape == CROWN_CONE)) {
         f1	= d3Vector_scalar_product (pC->axis, d3Vector_difference (sa1, pC->base));
         f2	= d3Vector_scalar_product (pC->axis, d3Vector_difference (sa2, pC->base));
         if ((f1 > pC->d3) || (f2 > pC->d3)) {
          rtn_value = !NO_RAYCROWN_ERRORS;
         }
        }
	    path_length	= 0.0;
	    if (rtn_value == NO_RAYCROWN_ERRORS) {
	     if (alpha1 >= 0.0) {
	      if (alpha2 >= 0.0) {
		   path_length	= fabs(alpha1 - alpha2);
		  } else {
		   path_length	= fabs(alpha1);
		  }
		 } else {
	      if (alpha2 >= 0.0) {
		   path_length	= fabs(alpha2);
		  } else {
		   path_length	= 0.0;
		  }
		 }
        }
        GammaH	*= exp(-fabs(pPR->koz_living.y)*cos_theta*path_length);
        GammaV	*= exp(-fabs(pPR->kez_living.y)*cos_theta*path_length);
	   }
	  }
	 }
	 /**************************************/
	 /* Dry crown contribution if required */
	 /**************************************/
	 if (pPR->species != POLSARPROSIM_DECIDUOUS001) {
      if (pPR->species != POLSARPROSIM_NULL_SPECIES) {
       if (pPR->species != POLSARPROSIM_HEDGE) {
	    for (itree=0; itree<pPR->Trees; itree++) {
	     if (fabs (x-pPR->Tree_Location[itree].x) <= Cr) {
 	      if (y > (pPR->Tree_Location[itree].y - Cr)) {
	       /***********************************************/
	       /* Look for ray intersection with living crown */
	       /***********************************************/
	       Realise_Tree_Crown_Only (&tree1, itree, pPR);
		   pC			= tree1.CrownVolume.tail;
	       rtn_value	= RayCrownIntersection (&ray1, pC, &sa1, &alpha1, &sa2, &alpha2);
	       path_length	= 0.0;
	       if (rtn_value == NO_RAYCROWN_ERRORS) {
	        if (alpha1 >= 0.0) {
	         if (alpha2 >= 0.0) {
		      path_length	= fabs(alpha1 - alpha2);
		     } else {
		      path_length	= fabs(alpha1);
		     }
		    } else {
	         if (alpha2 >= 0.0) {
		      path_length	= fabs(alpha2);
		     } else {
		      path_length	= 0.0;
		     }
		    }
           }
           GammaH	*= exp(-fabs(pPR->koz_dry.y)*cos_theta*path_length);
           GammaV	*= exp(-fabs(pPR->kez_dry.y)*cos_theta*path_length);
	      }
	     }
	    }
	   }
	  }
	 }
	}
    /******************************************************/
	/* Store the attenuation factors in the look-up table */
	/******************************************************/
	l	= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
	pPR->Amap.pBounceH[l]		= GammaH;
    pPR->Amap.pBounceV[l]		= GammaV;
    if (GammaH < gHmin) gHmin	= GammaH;
	if (GammaH > gHmax) gHmax	= GammaH;
	if (GammaV < gVmin) gVmin	= GammaV;
	if (GammaV > gVmax) gVmax	= GammaV;
   }
  }
 }
 Destroy_Tree (&tree1);

/*********************************/
/* Report attenuation map values */
/*********************************/

 fprintf (pPR->pLogFile, "\nOne-way bounce amplitude attenuation extrema:\n\n"); 
 fprintf (pPR->pLogFile, "Min H-pol:\t%12.5e\n", gHmin);
 fprintf (pPR->pLogFile, "Min V-pol:\t%12.5e\n", gVmin);
 fprintf (pPR->pLogFile, "Max H-pol:\t%12.5e\n", gHmax);
 fprintf (pPR->pLogFile, "Max V-pol:\t%12.5e\n", gVmax);
 fflush  (pPR->pLogFile);

/*******************************************************************/
/* For each attenuation grid location calculate DIRECT attenuation */
/*******************************************************************/

 gHmin	=  1.0e+30;
 gHmax	= -1.0e+30;
 gVmin	=  1.0e+30;
 gVmax	= -1.0e+30;

 Create_Tree (&tree1);
 a	= Cartesian_Assign_d3Vector (0.0, -sin_theta, cos_theta);
 for (i=0; i<pPR->Amap.Nx; i++) {
  x		= ((double)i*pPR->Amap.dx) - pPR->Amap.Ax/2.0;
  for (j=0; j<pPR->Amap.Ny; j++) {
   y	=  (Ly/2.0) - Gp - ((double)j*pPR->Amap.dy);
   for (k=0; k<pPR->Amap.Nz; k++) {
    G	= ground_height (pPR, x, y);
	zed	= ((double)k*pPR->Amap.dz);
    z	= G + zed;
    r	= Cartesian_Assign_d3Vector (x, y, z);
	Assign_Ray_d3V (&ray1, &r, &a);
    /***************************************************/
    /* Calculate total attenuation for this grid point */
	/***************************************************/
	GammaH	= 1.0;
	GammaV	= 1.0;
	/*****************************/
	/* Short veggie contribution */
	/*****************************/
	if (zed < pPR->shrt_vegi_depth) {
     GammaH	*= exp(-fabs(pPR->koz_short.y)*(pPR->shrt_vegi_depth-zed));
     GammaV	*= exp(-fabs(pPR->kez_short.y)*(pPR->shrt_vegi_depth-zed));
	}
	/*****************************/
	/* Living crown contribution */
	/*****************************/
	for (itree=0; itree<pPR->Trees; itree++) {
	 if (fabs (x-pPR->Tree_Location[itree].x) <= Cr) {
 	  if (y > (pPR->Tree_Location[itree].y - Cr)) {
	   /***********************************************/
	   /* Look for ray intersection with living crown */
	   /***********************************************/
	   Realise_Tree_Crown_Only (&tree1, itree, pPR);
	   pC			= tree1.CrownVolume.head;
	   rtn_value	= RayCrownIntersection (&ray1, pC, &sa1, &alpha1, &sa2, &alpha2);
       /**********************************************************************/
       /* Additional check for solution above crown apex for conical crowns  */
       /**********************************************************************/
	   if ((rtn_value == NO_RAYCROWN_ERRORS) && (pC->shape == CROWN_CONE)) {
        f1	= d3Vector_scalar_product (pC->axis, d3Vector_difference (sa1, pC->base));
        f2	= d3Vector_scalar_product (pC->axis, d3Vector_difference (sa2, pC->base));
        if ((f1 > pC->d3) || (f2 > pC->d3)) {
         rtn_value = !NO_RAYCROWN_ERRORS;
        }
       }
	   path_length	= 0.0;
	   if (rtn_value == NO_RAYCROWN_ERRORS) {
	    if (alpha1 >= 0.0) {
	     if (alpha2 >= 0.0) {
		  path_length	= fabs(alpha1 - alpha2);
		 } else {
		  path_length	= fabs(alpha1);
		 }
		} else {
	     if (alpha2 >= 0.0) {
		  path_length	= fabs(alpha2);
		 } else {
		  path_length	= 0.0;
		 }
		}
       }
       GammaH	*= exp(-fabs(pPR->koz_living.y)*cos_theta*path_length);
       GammaV	*= exp(-fabs(pPR->kez_living.y)*cos_theta*path_length);
	  }
	 }
	}
	/**************************************/
	/* Dry crown contribution if required */
	/**************************************/
	if (pPR->species != POLSARPROSIM_DECIDUOUS001) {
     if (pPR->species != POLSARPROSIM_NULL_SPECIES) {
      if (pPR->species != POLSARPROSIM_HEDGE) {
	   for (itree=0; itree<pPR->Trees; itree++) {
	    if (fabs (x-pPR->Tree_Location[itree].x) <= Cr) {
 	     if (y > (pPR->Tree_Location[itree].y - Cr)) {
	      /***********************************************/
	      /* Look for ray intersection with living crown */
	      /***********************************************/
	      Realise_Tree_Crown_Only (&tree1, itree, pPR);
		  pC			= tree1.CrownVolume.tail;
	      rtn_value	= RayCrownIntersection (&ray1, pC, &sa1, &alpha1, &sa2, &alpha2);
	      path_length	= 0.0;
	      if (rtn_value == NO_RAYCROWN_ERRORS) {
	       if (alpha1 >= 0.0) {
	        if (alpha2 >= 0.0) {
		     path_length	= fabs(alpha1 - alpha2);
		    } else {
		     path_length	= fabs(alpha1);
		    }
		    } else {
	        if (alpha2 >= 0.0) {
		     path_length	= fabs(alpha2);
		    } else {
		     path_length	= 0.0;
		    }
		   }
          }
          GammaH	*= exp(-fabs(pPR->koz_dry.y)*cos_theta*path_length);
          GammaV	*= exp(-fabs(pPR->kez_dry.y)*cos_theta*path_length);
	     }
	    }
	   }
	  }
	 }
	}
	/******************************************************/
	/* Store the attenuation factors in the look-up table */
	/******************************************************/
	l	= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
	pPR->Amap.pDirectH[l]		= GammaH;
    pPR->Amap.pDirectV[l]		= GammaV;
	if (GammaH < gHmin) gHmin	= GammaH;
	if (GammaH > gHmax) gHmax	= GammaH;
	if (GammaV < gVmin) gVmin	= GammaV;
	if (GammaV > gVmax) gVmax	= GammaV;
   }
  }
 }
 Destroy_Tree (&tree1);

/*********************************/
/* Report attenuation map values */
/*********************************/

 fprintf (pPR->pLogFile, "\nOne-way direct amplitude attenuation extrema:\n\n"); 
 fprintf (pPR->pLogFile, "Min H-pol:\t%12.5e\n", gHmin);
 fprintf (pPR->pLogFile, "Min V-pol:\t%12.5e\n", gVmin);
 fprintf (pPR->pLogFile, "Max H-pol:\t%12.5e\n", gHmax);
 fprintf (pPR->pLogFile, "Max V-pol:\t%12.5e\n", gVmax);
 fflush  (pPR->pLogFile);

/****************************************************/
/* Short vegetation layer attenuation look up array */
/****************************************************/

 fprintf (pPR->pLogFile, "\nOne-way direct amplitude attenuation by depth in short vegetation ...\n\n"); 
 fprintf (pPR->pLogFile, "\tdepth\t\tGammaH\tGammaV\n\n");
 for (k=0; k<pPR->Amap.Nds; k++) {
  dk		= k*pPR->Amap.dds;
  GammaH	= exp(-fabs(pPR->koz_short.y)*dk);
  GammaV	= exp(-fabs(pPR->kez_short.y)*dk);
  pPR->Amap.pDirectShortH[k]	= GammaH;
  pPR->Amap.pDirectShortV[k]	= GammaV;
  fprintf (pPR->pLogFile, "\t%lf\t%lf\t%lf\n", dk, pPR->Amap.pDirectShortH[k], pPR->Amap.pDirectShortV[k]);
 }
 fprintf (pPR->pLogFile, "\n");
 fflush  (pPR->pLogFile);

/************************************************/
/* Create and ouptut attenuation map SIM images */
/************************************************/

 Create_SIM_Record	(&Amap_Image);

 AmapFilename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("AmapDirectH.sim")+1, sizeof(char));
 strcpy  (AmapFilename, pPR->pMasterDirectory);
 strcat  (AmapFilename, "AmapDirectH.sim");

 Initialise_SIM_Record (&Amap_Image, AmapFilename, pPR->Amap.Nx, pPR->Amap.Ny*pPR->Amap.Nz, SIM_FLOAT_TYPE, 
						pPR->Lx, pPR->Ly*pPR->Amap.Nz, "PolSARproSim attenuation map");
 p.simpixeltype	= Amap_Image.pixel_type;
 for (i=0; i<pPR->Amap.Nx; i++) {
  for (j=0; j<pPR->Amap.Ny; j++) {
   for (k=0; k<pPR->Amap.Nz; k++) {
	l			= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
	GammaH		= pPR->Amap.pDirectH[l];
	p.data.f	= (float) GammaH;
	px			= i;
	py			= j + pPR->Amap.Ny*k;
	putSIMpixel (&Amap_Image, p, px, py);
   }
  }
 }

#ifndef POLSARPROSIM_NOSIMOUTPUT
 Write_SIM_Record	(&Amap_Image);
#endif

 free (AmapFilename);
 AmapFilename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("AmapDirectV.sim")+1, sizeof(char));
 strcpy  (AmapFilename, pPR->pMasterDirectory);
 strcat  (AmapFilename, "AmapDirectV.sim");
 Rename_SIM_Record (&Amap_Image, AmapFilename);

 for (i=0; i<pPR->Amap.Nx; i++) {
  for (j=0; j<pPR->Amap.Ny; j++) {
   for (k=0; k<pPR->Amap.Nz; k++) {
	l			= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
	GammaV		= pPR->Amap.pDirectV[l];
	p.data.f	= (float) GammaV;
	px			= i;
	py			= j + pPR->Amap.Ny*k;
	putSIMpixel (&Amap_Image, p, px, py);
   }
  }
 }

#ifndef POLSARPROSIM_NOSIMOUTPUT
 Write_SIM_Record	(&Amap_Image);
#endif

 free (AmapFilename);
 AmapFilename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("AmapBounceH.sim")+1, sizeof(char));
 strcpy  (AmapFilename, pPR->pMasterDirectory);
 strcat  (AmapFilename, "AmapBounceH.sim");
 Rename_SIM_Record (&Amap_Image, AmapFilename);

 for (i=0; i<pPR->Amap.Nx; i++) {
  for (j=0; j<pPR->Amap.Ny; j++) {
   for (k=0; k<pPR->Amap.Nz; k++) {
	l			= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
	GammaV		= pPR->Amap.pBounceH[l];
	p.data.f	= (float) GammaV;
	px			= i;
	py			= j + pPR->Amap.Ny*k;
	putSIMpixel (&Amap_Image, p, px, py);
   }
  }
 }

#ifndef POLSARPROSIM_NOSIMOUTPUT
 Write_SIM_Record	(&Amap_Image);
#endif

 free (AmapFilename);
 AmapFilename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("AmapBounceV.sim")+1, sizeof(char));
 strcpy  (AmapFilename, pPR->pMasterDirectory);
 strcat  (AmapFilename, "AmapBounceV.sim");
 Rename_SIM_Record (&Amap_Image, AmapFilename);

 for (i=0; i<pPR->Amap.Nx; i++) {
  for (j=0; j<pPR->Amap.Ny; j++) {
   for (k=0; k<pPR->Amap.Nz; k++) {
	l			= i + j*pPR->Amap.Nx + k*pPR->Amap.Nx*pPR->Amap.Ny;
	GammaV		= pPR->Amap.pBounceV[l];
	p.data.f	= (float) GammaV;
	px			= i;
	py			= j + pPR->Amap.Ny*k;
	putSIMpixel (&Amap_Image, p, px, py);
   }
  }
 }

#ifndef POLSARPROSIM_NOSIMOUTPUT
 Write_SIM_Record	(&Amap_Image);
#endif

 free (AmapFilename);

 Destroy_SIM_Record (&Amap_Image);

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to Attenuation_Map\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to Attenuation_Map\n\n");
 fflush  (pPR->pLogFile);

/********************************/
/* Increment progress indicator */
/********************************/

 pPR->progress++;

/********************************/
/* Report progress if requested */
/********************************/

#ifdef POLSARPROSIM_MAX_PROGRESS
 PolSARproSim_indicate_progress (pPR);
#endif

 return;
}

/*****************************/
/* SPM Scattering Amplitudes */
/*****************************/

Complex Bhh (double theta, Complex epsilon)
{
 double		sintheta	= sin(theta);
 double		costheta	= cos(theta);
 Complex	w			= complex_sqrt	(xy_complex (epsilon.x-sintheta*sintheta, epsilon.y));
 Complex	Rhh			= xy_complex	(costheta-w.x, -w.y);
			Rhh			= complex_div	(Rhh, xy_complex (costheta+w.x, w.y));
 return (Rhh);
}

Complex Bvv (double theta, Complex epsilon)
{
 double		sintheta	= sin(theta);
 double		costheta	= cos(theta);
 Complex	u			= xy_complex	(epsilon.x-1.0, epsilon.y);
 Complex	v			= complex_sub	(xy_complex (sintheta*sintheta, 0.0), complex_rmul (epsilon, 1.0+sintheta*sintheta));
 Complex	w			= complex_rmul	(epsilon, costheta);
 Complex	z			= complex_sqrt	(xy_complex (epsilon.x-sintheta*sintheta, epsilon.y));
 Complex	Rvv			= complex_mul	(u, v);
			z			= complex_add	(w, z);
			z			= complex_mul	(z, z);
			Rvv			= complex_div	(Rvv, z);
 return (Rvv);
}

/*************************/
/* SAR image calculation */
/*************************/

double		Point_Spread_Function			(double dx, double dy, PolSARproSim_Record *pPR)
{
 /****************************************************************************/
 /* Note that dx is azimuth displacement and dy is ground range displacement */
 /****************************************************************************/
 double		ax		= pPR->psfaaz;
 double		ay		= pPR->psfagr[pPR->current_track];
 double		psf		= pPR->PSFamp * exp (-(ax*dx*dx+ay*dy*dy));
 return (psf);
}

double		Accumulate_SAR_Contribution		(double focus_x, double focus_y, double focus_srange,
											 Complex Shh, Complex Shv, Complex Svv, PolSARproSim_Record *pPR)
{
 double		dx		= pPR->deltax;
 double		dy		= pPR->deltay;
 double		xmid	= pPR->xmid;
 double		ymid	= pPR->ymid;
 double		k		= pPR->k0;
 /**************************************************************/
 /* Find pixel coordinates for pixel closest to point of focus */
 /**************************************************************/
 int		ix		= (int) ((xmid+focus_x)/dx);
 int		jy		= (int) ((ymid-focus_y)/dy);
 /***********************************************/
 /* Find extent of loop for pixel contributions */
 /***********************************************/
 int		nxmin	= ix - pPR->PSFnx;
 int		nxmax	= ix + pPR->PSFnx;
 int		nymin	= jy - pPR->PSFny;
 int		nymax	= jy + pPR->PSFny;
 int		ipx, jpy;
 double		px, py;
 double		daz;
 double		phi;
 double		weight;
 Complex	cweight;
 sim_pixel	spix;
 sim_pixel  gpix;
 Complex	cvalue;
 double		weight_sum	= 0.0;

 spix.simpixeltype	= pPR->HHimage.pixel_type;
 gpix.simpixeltype	= pPR->HHimage.pixel_type;
 /**************************************************/
 /* Add contribution if it overlaps the image area */
 /**************************************************/
 if (nxmax >= 0) {
  if (nxmin < pPR->nx) {
   if (nymax >= 0) {
    if (nymin < pPR->ny) {
	 /***************************************/
	 /* Determine the extent of the overlap */
	 /***************************************/
	 if (nxmin < 0) nxmin = 0;
	 if (nxmax > pPR->nx-1) nxmax = pPR->nx-1;
	 if (nymin < 0) nymin = 0;
	 if (nymax > pPR->ny-1) nymax = pPR->ny-1;
	 /********************/
	 /* Loop over pixels */
	 /********************/
	 for (ipx=nxmin; ipx<=nxmax; ipx++) {
	  px	= ipx * dx - xmid;
	  daz	= px - focus_x;
	  phi	= 2.0*k*focus_srange + k*daz*daz/focus_srange;
	  for (jpy=nymin; jpy<=nymax; jpy++) {
	   py				= ymid - jpy * dy;
	   weight			= Point_Spread_Function (daz, py-focus_y, pPR);
	   weight_sum		+= weight*weight;
	   Polar_Assign_Complex (&cweight, weight, phi);
	   cvalue			= complex_mul (cweight, Shh);
	   spix.data.cf.x	= (float) cvalue.x;
   	   spix.data.cf.y	= (float) cvalue.y;
	   gpix				= getSIMpixel (&(pPR->HHimage), ipx, jpy);
       spix.data.cf.x	+= gpix.data.cf.x;
       spix.data.cf.y	+= gpix.data.cf.y;
	   putSIMpixel (&(pPR->HHimage), spix, ipx, jpy);
       cvalue			= complex_mul (cweight, Shv);
	   spix.data.cf.x	= (float) cvalue.x;
   	   spix.data.cf.y	= (float) cvalue.y;
	   gpix				= getSIMpixel (&(pPR->HVimage), ipx, jpy);
       spix.data.cf.x	+= gpix.data.cf.x;
       spix.data.cf.y	+= gpix.data.cf.y;
	   putSIMpixel (&(pPR->HVimage), spix, ipx, jpy);
       cvalue			= complex_mul (cweight, Svv);
	   spix.data.cf.x	= (float) cvalue.x;
   	   spix.data.cf.y	= (float) cvalue.y;
	   gpix				= getSIMpixel (&(pPR->VVimage), ipx, jpy);
       spix.data.cf.x	+= gpix.data.cf.x;
       spix.data.cf.y	+= gpix.data.cf.y;
	   putSIMpixel (&(pPR->VVimage), spix, ipx, jpy);
	  }
	 }
    }
   }
  }
 }
 return (weight_sum);
}

int			Polarisation_Vectors			(d3Vector k, d3Vector n, d3Vector *ph, d3Vector *pv)
{
 double		ndotk;
 double		hx, hy, hz;
 double		vx, vy, vz;

 d3Vector_insitu_normalise (&k);
 d3Vector_insitu_normalise (&n);
 ndotk		= d3Vector_scalar_product (n, k);
 if (fabs(fabs(ndotk)-1.0) < FLT_EPSILON) {
  *ph		= Cartesian_Assign_d3Vector (-sin(k.phi), cos(k.phi), 0.0);
  *pv		= Cartesian_Assign_d3Vector (cos(k.theta)*cos(k.phi), cos(k.theta)*sin(k.phi), -sin(k.theta));
 } else {
  hx		= n.x[1]*k.x[2] - n.x[2]*k.x[1];
  hy		= n.x[2]*k.x[0] - n.x[0]*k.x[2];
  hz		= n.x[0]*k.x[1] - n.x[1]*k.x[0];
  *ph		= Cartesian_Assign_d3Vector (hx, hy, hz);
  d3Vector_insitu_normalise (ph);
  vx		= ph->x[1]*k.x[2] - ph->x[2]*k.x[1];
  vy		= ph->x[2]*k.x[0] - ph->x[0]*k.x[2];
  vz		= ph->x[0]*k.x[1] - ph->x[1]*k.x[0];
  *pv		= Cartesian_Assign_d3Vector (vx, vy, vz);
 }
 return (NO_POLSARPROSIM_ERRORS);
}

c3Vector	d3V2c3V	(d3Vector v)
{
 c3Vector	c;
 c	= Assign_c3Vector (xy_complex (v.x[0], 0.0), xy_complex (v.x[1], 0.0), xy_complex (v.x[2], 0.0)); 
 return (c);
}

#ifndef POLSARPRO_CONVENTION
void		Create_SAR_Filenames			(PolSARproSim_Record *pPR, const char *master_directory, const char *slave_directory, const char *prefix)
#else
void		Create_SAR_Filenames			(PolSARproSim_Record *pPR, const char *master_directory, const char *slave_directory)
#endif
{
#ifndef POLSARPRO_CONVENTION
 if (pPR->current_track == 0) {
  pPR->HH_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->HH_string, master_directory);
 } else {
  free (pPR->HH_string);
  pPR->HH_string	= (char*) calloc (strlen(slave_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->HH_string, slave_directory);
 }
 strncat (pPR->HH_string, prefix, strlen(prefix));
 strncat (pPR->HH_string, "HH.sim", 6);
 if (pPR->current_track == 0) {
  pPR->HV_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->HV_string, master_directory);
 } else {
  free (pPR->HV_string);
  pPR->HV_string	= (char*) calloc (strlen(slave_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->HV_string, slave_directory);
 }
 strncat (pPR->HV_string, prefix, strlen(prefix));
 strncat (pPR->HV_string, "HV.sim", 6);
 if (pPR->current_track == 0) {
  pPR->VV_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->VV_string, master_directory);
 } else {
  free (pPR->VV_string);
  pPR->VV_string	= (char*) calloc (strlen(slave_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->VV_string, slave_directory);
 }
 strncat (pPR->VV_string, prefix, strlen(prefix));
 strncat (pPR->VV_string, "VV.sim", 6);
 if (pPR->current_track == 0) {
  pPR->VH_string	= (char*) calloc (strlen(master_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->VH_string, master_directory);
 } else {
  free (pPR->VH_string);
  pPR->VH_string	= (char*) calloc (strlen(slave_directory)+strlen(prefix)+8, sizeof(char));
  strcpy  (pPR->VH_string, slave_directory);
 }
 strncat (pPR->VH_string, prefix, strlen(prefix));
 strncat (pPR->VH_string, "VH.sim", 6);
#else
 if (pPR->current_track == 0) {
  pPR->HH_string	= (char*) calloc (strlen(master_directory)+9, sizeof(char));
  strcpy  (pPR->HH_string, master_directory);
 } else {
  free (pPR->HH_string);
  pPR->HH_string	= (char*) calloc (strlen(slave_directory)+9, sizeof(char));
  strcpy  (pPR->HH_string, slave_directory);
 }
 strncat (pPR->HH_string, "s11.bin", 7);
 if (pPR->current_track == 0) {
  pPR->HV_string	= (char*) calloc (strlen(master_directory)+9, sizeof(char));
  strcpy  (pPR->HV_string, master_directory);
 } else {
  free (pPR->HV_string);
  pPR->HV_string	= (char*) calloc (strlen(slave_directory)+9, sizeof(char));
  strcpy  (pPR->HV_string, slave_directory);
 }
 strncat (pPR->HV_string, "s12.bin", 7);
 if (pPR->current_track == 0) {
  pPR->VV_string	= (char*) calloc (strlen(master_directory)+9, sizeof(char));
  strcpy  (pPR->VV_string, master_directory);
 } else {
  free (pPR->VV_string);
  pPR->VV_string	= (char*) calloc (strlen(slave_directory)+9, sizeof(char));
  strcpy  (pPR->VV_string, slave_directory);
 }
 strncat (pPR->VV_string, "s22.bin", 7);
 if (pPR->current_track == 0) {
  pPR->VH_string	= (char*) calloc (strlen(master_directory)+9, sizeof(char));
  strcpy  (pPR->VH_string, master_directory);
 } else {
  free (pPR->VH_string);
  pPR->VH_string	= (char*) calloc (strlen(slave_directory)+9, sizeof(char));
  strcpy  (pPR->VH_string, slave_directory);
 }
 strncat (pPR->VH_string, "s21.bin", 7);
#endif
 return;
}

void		Clean_SAR_Images				(PolSARproSim_Record *pPR)
{
 Destroy_SIM_Record (&(pPR->HHimage));
 Destroy_SIM_Record (&(pPR->HVimage));
 Destroy_SIM_Record (&(pPR->VVimage));
 Initialise_SIM_Record	(&(pPR->HHimage), pPR->HH_string, pPR->nx, pPR->ny, SIM_COMPLEX_FLOAT_TYPE,
					pPR->Lx, pPR->Ly, "PolSARproSim HH image file");
 Initialise_SIM_Record	(&(pPR->HVimage), pPR->HV_string, pPR->nx, pPR->ny, SIM_COMPLEX_FLOAT_TYPE,
					pPR->Lx, pPR->Ly, "PolSARproSim HV image file");
 Initialise_SIM_Record	(&(pPR->VVimage), pPR->VV_string, pPR->nx, pPR->ny, SIM_COMPLEX_FLOAT_TYPE,
					pPR->Lx, pPR->Ly, "PolSARproSim VV image file");
 return;
}

/***********************************************************/
/* SAR imaging algorithm crown tertiary branch realisation */
/***********************************************************/

double		Estimate_SAR_Tertiaries			(Tree *pT, PolSARproSim_Record *pPR, long *nt, double *tbl, double *tbr)
{
 double						primary_branch_length, secondary_branch_length, tertiary_branch_length;
 double						primary_branch_radius, secondary_branch_radius, tertiary_branch_radius;
 double						tertiary_branch_volume;
 double						tertiary_branch_vf;
 long						tertiary_branch_number;
 int						stbn;
 Crown						*pC;
 Branch						*pB;
 long						iBranch;
 double						stbn_factor;
 double						crown_area;
 double						Sa_scaling;

 /********************************/
 /* Initialise the crown pointer */
 /********************************/
 pC							= pT->CrownVolume.head;
 crown_area					= 4.0*atan(1.0)*pC->d2*pC->d2;
 /***********************************/
 /* Empty the current tertiary list */
 /***********************************/
 Branch_empty_list (&(pT->Tertiary));
 /*********************************************/
 /* Determine dimensions of tertiary branches */
 /*********************************************/
 if (pT->species == POLSARPROSIM_HEDGE) {
  tertiary_branch_length	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH;
  tertiary_branch_radius	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS;
 } else {
  primary_branch_length		= 0.0;
  primary_branch_radius		= 0.0;
  pB	= pT->Primary.head;
  for (iBranch=0L; iBranch < pT->Primary.n; iBranch++) {
   primary_branch_length	+= pB->l;
   primary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
   pB	= pB->next;
  }
  primary_branch_length		/= (double) pT->Primary.n;
  primary_branch_radius		/= (double) pT->Primary.n;
  secondary_branch_length	= 0.0;
  secondary_branch_radius	= 0.0;
  pB	= pT->Secondary.head;
  for (iBranch=0L; iBranch < pT->Secondary.n; iBranch++) {
   secondary_branch_length	+= pB->l;
   secondary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
   pB	= pB->next;
  }
  secondary_branch_length	/= (double) pT->Secondary.n;
  secondary_branch_radius	/= (double) pT->Secondary.n;
  tertiary_branch_length	= secondary_branch_length*secondary_branch_length/primary_branch_length;
  tertiary_branch_radius	= secondary_branch_radius*secondary_branch_radius/primary_branch_radius;
 }
 /***********************************************************/
 /* Determine the actual number of tertiaries in this crown */
 /***********************************************************/
 tertiary_branch_volume		= DPI_RAD*tertiary_branch_radius*tertiary_branch_radius*tertiary_branch_length;
 tertiary_branch_vf			= Tertiary_Branch_Volume_Fraction (pT->species);
 tertiary_branch_number		= (long) (tertiary_branch_vf*pC->volume/tertiary_branch_volume);
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "\nTertiary branch number for this crown is %ld\n", tertiary_branch_number);
#endif
 /*********************************************************/
 /* Determine the number of desired tertiary realisations */
 /*********************************************************/
 switch (pT->species) {
  case	POLSARPROSIM_HEDGE:			stbn_factor	= POLSARPROSIM_HEDGE_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE001:		stbn_factor	= POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE002:		stbn_factor	= POLSARPROSIM_PINE002_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE003:		stbn_factor	= POLSARPROSIM_PINE003_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_DECIDUOUS001:	stbn_factor	= POLSARPROSIM_DECIDUOUS001_SAR_TERTIARY_FACTOR;	break;
  default:							stbn_factor	= POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR;			break;
 }
 stbn						= (int) (stbn_factor*crown_area/(pPR->azimuth_resolution*pPR->ground_range_resolution[0]));
 stbn++;
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "Tertiary branch realisations for this crown: %ld\n", stbn);
#endif
 /*****************************************/
 /* Choose the smaller of the two numbers */
 /*****************************************/
 if (stbn > tertiary_branch_number) {
  stbn	= tertiary_branch_number;
 }
 /******************************************************************/
 /* Determine the scattering amplitude scale factor for this crown */
 /******************************************************************/
 Sa_scaling					= sqrt (((double)tertiary_branch_number)/((double)stbn));
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "Tertiary branch scattering amplitude scaling =  %lf\n", Sa_scaling);
#endif
 /*****************************/
 /* Pass relevant information */
 /*****************************/
 *nt						= (long) stbn;
 *tbl						= tertiary_branch_length;
 *tbr						= tertiary_branch_radius;
 /*******************************************/
 /* Return to caller with amplitude scaling */
 /*******************************************/
 return (Sa_scaling);
}

int		Realise_Tertiary_Branch			(Tree *pT, PolSARproSim_Record *pPR, Branch *pB, 
										 double tertiary_branch_length, double tertiary_branch_radius,
										 double moisture, Complex permittivity)
{
 Crown			*pC;
 d3Vector		 b0, p0, z0;
 double			 theta, phi;
 int			 rtn_value;

 pC				= pT->CrownVolume.head;
 Destroy_Branch (pB);
 rtn_value		= Random_Crown_Location (pC, &b0);
 if (rtn_value == NO_RAYCROWN_ERRORS) {
  phi			= 2.0*DPI_RAD*drand();
  theta			= vegi_polar_angle ();
  z0			= Polar_Assign_d3Vector (1.0, theta, phi);
  p0			= Polar_Assign_d3Vector (1.0, theta, phi);
  b0			= d3Vector_sum (b0, d3Vector_double_multiply (z0, -tertiary_branch_length/2.0));
  Assign_Branch (pB, tertiary_branch_radius, tertiary_branch_radius, b0, z0, p0, 0.0, 0.0, 0.0, 0.0, 0.0, 
				 1.0, 1.0, 0.0, moisture, tertiary_branch_length, permittivity, 0, 0);
 }
 return (rtn_value);
}

double		Realise_SAR_Tertiaries			(Tree *pT, PolSARproSim_Record *pPR)
{
 double				primary_branch_length, secondary_branch_length, tertiary_branch_length;
 double				primary_branch_radius, secondary_branch_radius, tertiary_branch_radius;
 double				tertiary_branch_volume;
 double				tertiary_branch_vf;
 long				tertiary_branch_number;
 int				stbn;
 Branch				tertiary_branch;
 double				theta, phi;
 d3Vector			z0;
 double				sr, er;
 double				dp;
 double				lamdacx, lamdacy, gamma;
 double				phix, phiy, phicx, phicy;
 Complex			permittivity;
 d3Vector			p0;
 double				moisture;
 Crown				*pC;
 Branch				*pB;
 long				iBranch;
 int				rtn_value;
 d3Vector			b0;
 double				stbn_factor;
 double				crown_area;
 double				Sa_scaling;

 /********************************/
 /* Initialise the crown pointer */
 /********************************/
 pC							= pT->CrownVolume.head;
 crown_area					= 4.0*atan(1.0)*pC->d2*pC->d2;
 /***********************************/
 /* Empty the current tertiary list */
 /***********************************/
 Branch_empty_list (&(pT->Tertiary));
 /*********************************************/
 /* Determine dimensions of tertiary branches */
 /*********************************************/
 if (pT->species == POLSARPROSIM_HEDGE) {
  tertiary_branch_length	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH;
  tertiary_branch_radius	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS;
 } else {
  primary_branch_length		= 0.0;
  primary_branch_radius		= 0.0;
  pB	= pT->Primary.head;
  for (iBranch=0L; iBranch < pT->Primary.n; iBranch++) {
   primary_branch_length	+= pB->l;
   primary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
   pB	= pB->next;
  }
  primary_branch_length		/= (double) pT->Primary.n;
  primary_branch_radius		/= (double) pT->Primary.n;
  secondary_branch_length	= 0.0;
  secondary_branch_radius	= 0.0;
  pB	= pT->Secondary.head;
  for (iBranch=0L; iBranch < pT->Secondary.n; iBranch++) {
   secondary_branch_length	+= pB->l;
   secondary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
   pB	= pB->next;
  }
  secondary_branch_length	/= (double) pT->Secondary.n;
  secondary_branch_radius	/= (double) pT->Secondary.n;
  tertiary_branch_length	= secondary_branch_length*secondary_branch_length/primary_branch_length;
  tertiary_branch_radius	= secondary_branch_radius*secondary_branch_radius/primary_branch_radius;
 }
 /***********************************************************/
 /* Determine the actual number of tertiaries in this crown */
 /***********************************************************/
 tertiary_branch_volume		= DPI_RAD*tertiary_branch_radius*tertiary_branch_radius*tertiary_branch_length;
 tertiary_branch_vf			= Tertiary_Branch_Volume_Fraction (pT->species);
 tertiary_branch_number		= (long) (tertiary_branch_vf*pC->volume/tertiary_branch_volume);
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "\nTertiary branch number for this crown is %ld\n", tertiary_branch_number);
#endif
 /********************************************************/
 /* Determine the number of actual tertiary realisations */
 /********************************************************/
 switch (pT->species) {
  case	POLSARPROSIM_HEDGE:			stbn_factor	= POLSARPROSIM_HEDGE_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE001:		stbn_factor	= POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE002:		stbn_factor	= POLSARPROSIM_PINE002_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE003:		stbn_factor	= POLSARPROSIM_PINE003_SAR_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_DECIDUOUS001:	stbn_factor	= POLSARPROSIM_DECIDUOUS001_SAR_TERTIARY_FACTOR;	break;
  default:							stbn_factor	= POLSARPROSIM_PINE001_SAR_TERTIARY_FACTOR;			break;
 }
 stbn						= (int) (stbn_factor*crown_area/(pPR->azimuth_resolution*pPR->ground_range_resolution[0]));
 stbn++;
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "Tertiary branch realisations for this crown: %ld\n", stbn);
#endif
 /******************************************************************/
 /* Determine the scattering amplitude scale factor for this crown */
 /******************************************************************/
 Sa_scaling					= sqrt (((double)tertiary_branch_number)/((double)stbn));
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "Tertiary branch scattering amplitude scaling =  %lf\n", Sa_scaling);
#endif
 /***************************************/
 /* Loop to create tertiary branch list */
 /***************************************/
 Create_Branch (&tertiary_branch);
 dp							= 0.0;
 lamdacx					= 1.0;
 lamdacy					= 1.0;
 gamma						= 0.0;
 phix						= 0.0;
 phiy						= 0.0;
 phicx						= 0.0;
 phicy						= 0.0;
 sr							= tertiary_branch_radius;
 er							= tertiary_branch_radius;
 for (iBranch=0L; iBranch < stbn; iBranch++) {
  /************************************/
  /* Create and store random branches */
  /************************************/
  rtn_value		= Random_Crown_Location (pC, &b0);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   phi			= 2.0*DPI_RAD*drand();
   theta		= vegi_polar_angle ();
   z0			= Polar_Assign_d3Vector (1.0, theta, phi);
   p0			= Polar_Assign_d3Vector (1.0, theta, phi);
   b0			= d3Vector_sum (b0, d3Vector_double_multiply (z0, -tertiary_branch_length/2.0));
   moisture		= Tertiary_Branch_Moisture (pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   Assign_Branch (&tertiary_branch, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, 
				  lamdacx, lamdacy, gamma, moisture, tertiary_branch_length, permittivity,
				  (int) (pT->Stem.n + pT->Dry.n + pT->Primary.n + pT->Secondary.n + pT->Tertiary.n + 1L), 0);
   Branch_head_add (&(pT->Tertiary), &tertiary_branch);
  }
 }
 Destroy_Branch (&tertiary_branch);
#ifdef POLSARPROSIM_VERBOSE_TERTIARY
 fprintf (pPR->pLogFile, "Created %ld tertiary branches for this crown.\n\n", pT->Tertiary.n);
#endif
 return (Sa_scaling);
}

/***************************************************/
/* SAR imaging algorithm crown foliage realisation */
/***************************************************/

double		Estimate_SAR_Foliage (Tree *pT, PolSARproSim_Record *pPR, long *nf)
{
 int			species;
 Crown			*pC;
 double			leaf_d1, leaf_d2, leaf_d3;
 double			theta, phi;
 double			moisture;
 d3Vector		cl;
 Complex		permittivity;
 double			leafvol;
 Leaf			leaf1;
 double			leaf_vf;
 long			leaf_number;
 double			Sa_scaling	= 1.0;
 double			crown_area;
 long			sfgn;
 double			sfgn_factor;
/********************************/
/* Initialise the crown pointer */
/********************************/
 pC							= pT->CrownVolume.head;
 crown_area					= 4.0*atan(1.0)*pC->d2*pC->d2;
/***********************************/
/* Empty the existing foliage list */
/***********************************/
 Leaf_empty_list (&(pT->Foliage));
/***************************************/
/* Find the foliage element dimensions */
/***************************************/
 species		= Leaf_Species		(pT->species);
 leaf_d1		= Leaf_Dimension_1	(pT->species);
 leaf_d2		= Leaf_Dimension_2	(pT->species);
 leaf_d3		= Leaf_Dimension_3	(pT->species);
 cl				= Cartesian_Assign_d3Vector (0.0, 0.0, 0.0);
 theta			= 0.0;
 phi			= 0.0;
 moisture		= Leaf_Moisture		(pT->species);
 permittivity	= vegetation_permittivity (moisture, pPR->frequency);
 Create_Leaf (&leaf1);
 Assign_Leaf	(&leaf1, species, leaf_d1, leaf_d2, leaf_d3, theta, phi, moisture, permittivity, cl);
 leafvol		= Leaf_Volume (&leaf1);
 leaf_vf		= Leaf_Volume_Fraction (pT->species);
/*****************************************************************/
/* Determine the actual number of foliage elements in this crown */
/*****************************************************************/
 leaf_number	= (long) (leaf_vf*pC->volume/leafvol);
#ifdef POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (pPR->pLogFile, "\nFoliage element number for this crown is %ld\n", leaf_number);
#endif
/****************************************************************/
/* Determine the number of desired foliage element realisations */
/****************************************************************/
 switch (pT->species) {
  case	POLSARPROSIM_HEDGE:			sfgn_factor	= POLSARPROSIM_HEDGE_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE001:		sfgn_factor	= POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE002:		sfgn_factor	= POLSARPROSIM_PINE002_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE003:		sfgn_factor	= POLSARPROSIM_PINE003_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_DECIDUOUS001:	sfgn_factor	= POLSARPROSIM_DECIDUOUS001_SAR_FOLIAGE_FACTOR;		break;
  default:							sfgn_factor	= POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR;			break;
 }
 sfgn			= (long) (sfgn_factor*crown_area/(pPR->azimuth_resolution*pPR->ground_range_resolution[0]));
 sfgn++;
#ifdef POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (pPR->pLogFile, "Foliage element realisations for this crown: %ld\n", sfgn);
#endif
/*****************************************/
/* Choose the smaller of the two numbers */
/*****************************************/
 if (sfgn > leaf_number) {
  sfgn	= leaf_number;
 }
/******************************************************************/
/* Determine the scattering amplitude scale factor for this crown */
/******************************************************************/
 Sa_scaling		= sqrt (((double)leaf_number)/((double)sfgn));
#ifdef POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (pPR->pLogFile, "Foliage element scattering amplitude scaling =  %lf\n\n", Sa_scaling);
#endif
/*****************************/
/* Pass relevant information */
/*****************************/
 *nf			= (long) sfgn;
/*******************************************/
/* Return to caller with amplitude scaling */
/*******************************************/
 Destroy_Leaf (&leaf1);
 return (Sa_scaling);
}

int		Realise_Foliage_Element			(Tree *pT, PolSARproSim_Record *pPR, Leaf *pL, 
										 int species, double leaf_d1, double leaf_d2, double leaf_d3, 
										 double moisture, Complex permittivity)
{
 Crown			*pC;
 d3Vector		 cl;
 int			 rtn_value;
 double			 theta, phi;

 Destroy_Leaf (pL);
 pC				= pT->CrownVolume.head;
 rtn_value		= Random_Crown_Location (pC, &cl);
 if (rtn_value == NO_RAYCROWN_ERRORS) {
   phi			= 2.0*DPI_RAD*drand();
   theta		= vegi_polar_angle ();
   Assign_Leaf	(pL, species, leaf_d1, leaf_d2, leaf_d3, theta, phi, moisture, permittivity, cl);
 }
 return (rtn_value);
}

double		Realise_SAR_Foliage (Tree *pT, PolSARproSim_Record *pPR)
{
 int			species;
 Crown			*pC;
 double			leaf_d1, leaf_d2, leaf_d3;
 double			theta, phi;
 double			moisture;
 d3Vector		cl;
 Complex		permittivity;
 double			leafvol;
 Leaf			leaf1;
 double			leaf_vf;
 long			leaf_number;
 int			iLeaf;
 int			rtn_value;
 double			Sa_scaling	= 1.0;
 double			crown_area;
 long			sfgn;
 double			sfgn_factor;
/********************************/
/* Initialise the crown pointer */
/********************************/
 pC							= pT->CrownVolume.head;
 crown_area					= 4.0*atan(1.0)*pC->d2*pC->d2;
/***********************************/
/* Empty the existing foliage list */
/***********************************/
 Leaf_empty_list (&(pT->Foliage));
/***************************************/
/* Find the foliage element dimensions */
/***************************************/
 species		= Leaf_Species		(pT->species);
 leaf_d1		= Leaf_Dimension_1	(pT->species);
 leaf_d2		= Leaf_Dimension_2	(pT->species);
 leaf_d3		= Leaf_Dimension_3	(pT->species);
 cl				= Cartesian_Assign_d3Vector (0.0, 0.0, 0.0);
 theta			= 0.0;
 phi			= 0.0;
 moisture		= Leaf_Moisture		(pT->species);
 permittivity	= vegetation_permittivity (moisture, pPR->frequency);
 Create_Leaf (&leaf1);
 Assign_Leaf	(&leaf1, species, leaf_d1, leaf_d2, leaf_d3, theta, phi, moisture, permittivity, cl);
 leafvol		= Leaf_Volume (&leaf1);
 leaf_vf		= Leaf_Volume_Fraction (pT->species);
/*****************************************************************/
/* Determine the actual number of foliage elements in this crown */
/*****************************************************************/
 leaf_number	= (long) (leaf_vf*pC->volume/leafvol);
#ifdef POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (pPR->pLogFile, "\nFoliage element number for this crown is %ld\n", leaf_number);
#endif
/********************************************************/
/* Determine the number of foliage element realisations */
/********************************************************/
 switch (pT->species) {
  case	POLSARPROSIM_HEDGE:			sfgn_factor	= POLSARPROSIM_HEDGE_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE001:		sfgn_factor	= POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE002:		sfgn_factor	= POLSARPROSIM_PINE002_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE003:		sfgn_factor	= POLSARPROSIM_PINE003_SAR_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_DECIDUOUS001:	sfgn_factor	= POLSARPROSIM_DECIDUOUS001_SAR_FOLIAGE_FACTOR;		break;
  default:							sfgn_factor	= POLSARPROSIM_PINE001_SAR_FOLIAGE_FACTOR;			break;
 }
 sfgn			= (long) (sfgn_factor*crown_area/(pPR->azimuth_resolution*pPR->ground_range_resolution[0]));
 sfgn++;
#ifdef POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (pPR->pLogFile, "Foliage element realisations for this crown: %ld\n", sfgn);
#endif
/******************************************************************/
/* Determine the scattering amplitude scale factor for this crown */
/******************************************************************/
 Sa_scaling		= sqrt (((double)leaf_number)/((double)sfgn));
#ifdef POLSARPROSIM_VERBOSE_FOLIAGE
 fprintf (pPR->pLogFile, "Foliage element scattering amplitude scaling =  %lf\n\n", Sa_scaling);
#endif
/***************************************/
/* Loop to create foliage element list */
/***************************************/
 for (iLeaf=0L; iLeaf < sfgn; iLeaf++) {
  rtn_value		= Random_Crown_Location (pC, &cl);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   phi			= 2.0*DPI_RAD*drand();
   theta		= vegi_polar_angle ();
   moisture		= Leaf_Moisture		(pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   Assign_Leaf	(&leaf1, species, leaf_d1, leaf_d2, leaf_d3, theta, phi, moisture, permittivity, cl);
   Leaf_head_add (&(pT->Foliage), &leaf1);
  }
 }
 Destroy_Leaf (&leaf1);
 return (Sa_scaling);
}

/**********************************************************/
/* SAR image output routine for compliance with PolSARPro */
/**********************************************************/

/*************************************************/
/* Binary format output for POLSARPro compliance */
/*************************************************/

int		Write_SIM_Record_As_POLSARPRO_BINARY	(SIM_Record *pSIMR)
{
 SIM_Complex_Float	*column	= (SIM_Complex_Float*) calloc (pSIMR->ny, sizeof (SIM_Complex_Float));
 FILE				*pSBF;
 int				i, j;
 sim_pixel			sp;

 pSBF	= fopen (pSIMR->filename, "wb");
 for (i=0; i<pSIMR->nx; i++) {
  for (j=0; j<pSIMR->ny; j++) {
   sp	= getSIMpixel (pSIMR, i, pSIMR->ny-j-1);
   switch (sp.simpixeltype) {
    case SIM_BYTE_TYPE:				column[j].x	= (float) sp.data.b;		column[j].y	= 0.0f;		break;
	case SIM_WORD_TYPE:				column[j].x	= (float) sp.data.w;		column[j].y	= 0.0f;		break;
	case SIM_DWORD_TYPE:			column[j].x	= (float) sp.data.dw;		column[j].y	= 0.0f;		break;
	case SIM_FLOAT_TYPE:			column[j].x	= (float) sp.data.f;		column[j].y	= 0.0f;		break;
	case SIM_DOUBLE_TYPE:			column[j].x	= (float) sp.data.d;		column[j].y	= 0.0f;		break;
	case SIM_COMPLEX_FLOAT_TYPE:	column[j].x	= (float) sp.data.cf.x;		column[j].y	= (float) -sp.data.cf.y;		break;
	case SIM_COMPLEX_DOUBLE_TYPE:	column[j].x	= (float) sp.data.cd.x;		column[j].y	= (float) -sp.data.cd.y;		break;
   }
  }
  fwrite (column, sizeof (SIM_Complex_Float), pSIMR->ny, pSBF);
 }
 fclose (pSBF);
 free (column);
 return (NO_SIMPRIMITIVE_ERRORS);
}

/***************************************************************/
/* SAR image output with optional choice of SIM format imagery */
/***************************************************************/

void		Write_SAR_Images				(PolSARproSim_Record *pPR)
{
#ifndef POLSARPRO_CONVENTION
#ifdef POLSARPROSIM_ROTATED_IMAGES
 SIM_Record			RotImage;
 Create_SIM_Record	(&RotImage);
 Rotate_SIM_Record	(&(pPR->HHimage), &RotImage);
 Write_SIM_Record	(&RotImage);
 Rotate_SIM_Record	(&(pPR->HVimage), &RotImage);
 Write_SIM_Record	(&RotImage);
 Rename_SIM_Record	(&RotImage, pPR->VH_string);
 Write_SIM_Record	(&RotImage);
 Rotate_SIM_Record	(&(pPR->VVimage), &RotImage);
 Write_SIM_Record	(&RotImage);
 Destroy_SIM_Record	(&RotImage);
#else
 Write_SIM_Record	(&(pPR->HHimage));
 Write_SIM_Record	(&(pPR->HVimage));
 Write_SIM_Record	(&(pPR->VVimage));
 Rename_SIM_Record	(&(pPR->HVimage), pPR->VH_string);
 Write_SIM_Record	(&(pPR->HVimage));
 Rename_SIM_Record	(&(pPR->HVimage), pPR->HV_string);
#endif
#else
 Write_SIM_Record_As_POLSARPRO_BINARY (&(pPR->HHimage));
 Write_SIM_Record_As_POLSARPRO_BINARY (&(pPR->HVimage));
 Write_SIM_Record_As_POLSARPRO_BINARY (&(pPR->VVimage));
 Rename_SIM_Record (&(pPR->HVimage), pPR->VH_string);
 Write_SIM_Record_As_POLSARPRO_BINARY (&(pPR->HVimage));
 Rename_SIM_Record (&(pPR->HVimage), pPR->HV_string);
#endif
 return;
}

void		Destroy_SAR_Images				(PolSARproSim_Record *pPR)
{
 Destroy_SIM_Record (&(pPR->HHimage));
 Destroy_SIM_Record (&(pPR->HVimage));
 Destroy_SIM_Record (&(pPR->VVimage));
 return;
}

/************************/
/* TCLTK string parsing */
/************************/

void		tcltk_parser					(char *pString)
{
#ifdef _WIN32
 const char	good	= '\\';
 const char	bad		= '/';
#else 
 const char	good	= '/';
 const char	bad		= '\\';
#endif
 int i = 0;
 while (pString[i] != '\0') {
  if (pString[i] == bad) {
   pString[i] = good;
  }
  i++;
 }
 return;
}

/****************************************/
/* Optional flat earth phase correction */
/****************************************/

#ifdef	POLSARPROSIM_FLATEARTH

void		Flat_Earth_Phase_Removal		(PolSARproSim_Record *pPR)
{
 double			dx			= pPR->deltax;
 double			dy			= pPR->deltay;
 double			xmid		= pPR->xmid;
 double			ymid		= pPR->ymid;
 double			k			= pPR->k0;
 const double	p_srange	= pPR->slant_range[pPR->current_track];
 const double	thetai		= pPR->incidence_angle[pPR->current_track];
 const double	p_height	= p_srange*cos(thetai);
 const double	p_height2	= p_height*p_height;
 const double	p_grange	= p_srange*sin(thetai);
 int			i, j;
 double			x, y, gr, sr;
 double			phase;
 Complex		c_phase;
 sim_pixel		s;
 Complex		cs;

 for (j = 0; j < pPR->ny; j++) {

  y		= ymid - j * dy;

  gr	= p_grange + y;
  sr	= sqrt (gr*gr + p_height2);
  phase	= 2.0*k*sr;
  Polar_Assign_Complex (&c_phase, 1.0, -phase);

  for (i = 0; i < pPR->nx; i++) {

   x			= i * dx - xmid;

   s			= getSIMpixel (&(pPR->HHimage), i, j);
   cs			= xy_complex (s.data.cf.x, s.data.cf.y);
   cs			= complex_mul (cs, c_phase);
   s.data.cf.x	= (float) cs.x;
   s.data.cf.y	= (float) cs.y;
   putSIMpixel (&(pPR->HHimage), s, i, j);

   s			= getSIMpixel (&(pPR->HVimage), i, j);
   cs			= xy_complex (s.data.cf.x, s.data.cf.y);
   cs			= complex_mul (cs, c_phase);
   s.data.cf.x	= (float) cs.x;
   s.data.cf.y	= (float) cs.y;
   putSIMpixel (&(pPR->HVimage), s, i, j);

   s			= getSIMpixel (&(pPR->VVimage), i, j);
   cs			= xy_complex (s.data.cf.x, s.data.cf.y);
   cs			= complex_mul (cs, c_phase);
   s.data.cf.x	= (float) cs.x;
   s.data.cf.y	= (float) cs.y;
   putSIMpixel (&(pPR->VVimage), s, i, j);

  }

 }

 return;
}

#endif

