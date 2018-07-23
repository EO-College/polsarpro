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
 * Module      : PolSARproSim_Structures.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Structures for PolSARproSim
 */
#ifndef __POLSARPROSIM_STRUCTURES_H__
#define __POLSARPROSIM_STRUCTURES_H__

#include	"SarIMage.h"
#include	"PolSARproSim_Definitions.h"
#include	"Perspective.h"
#include	"LightingMaterials.h"
#include	"d33Matrix.h"
#include	"Complex.h"

/****************************************/
/* Attenuation Map structure definition */
/****************************************/

typedef struct attnmap_tag {
 long			n;
 int			Nx;
 int			Ny;
 int			Nz;
 double			Ax;
 double			Ay;
 double			Az;
 double			dx;
 double			dy;
 double			dz;
 double			*pDirectH;
 double			*pDirectV;
 double			*pBounceH;
 double			*pBounceV;
 int			Nds;
 double			Ads;
 double			dds;
 double			*pDirectShortH;
 double			*pDirectShortV;
} AttenuationMap;

/********************************/
/* TreeLoc structure definition */
/********************************/

typedef struct treeloc_tag {
 double			x;
 double			y;
 double			height;
 double			radius;
} TreeLoc;

/**************************************/
/* Master record structure definition */
/**************************************/

typedef struct polsarprosim_record_tag {
/****************/
/* File handles */
/****************/
 FILE			*pOutputFile;				/* User required output goes here								*/
 FILE			*pLogFile;					/* Log file debugging output goes here							*/
/*******************************/
/* Random number sequence seed */
/*******************************/
 int			seed;						/* From which all else follows									*/
/***************************************************/
/* Variables governing SAR image area and geometry */
/***************************************************/
 int			Tracks;						/* Number of tracks requested for interferometry				*/
 double			*slant_range;				/* Slant range from aperture centre to scene centre in metres	*/
 double			*incidence_angle;			/* Global incidence angle stored in radians (input in degrees)	*/
 int			current_track;				/* Current track number											*/
 double			Lx;							/* Extent of SAR image area in azimuth in metres				*/
 double			Ly;							/* Extent of SAR image area in ground range in metres			*/
 double			Area;						/* SAR image area in square metres								*/
 double			Stand_Area;					/* Area of forest stand in square metres < LxLy					*/
 double			Layover_Distance;			/* L = h/tan_thetai, layover of forest towards radar in metres	*/
 double			Shadow_Distance;			/* S = h*tan_thetai, Shadow distance behind forest in metres	*/
 double			Gap_Distance;				/* This distance in metres leaves a border in the images		*/
 double			Stand_Radius;				/* SA = PIR^2, the radius of the area containing trees in m.	*/
 double			Hectares;					/* SAR image area in Hectares									*/
 int			nx;							/* SAR image dimension in azimuth in pixels						*/
 int			ny;							/* SAR image dimension in ground range in pixels				*/
 double			deltax;						/* Azimuth pixel dimension in metres							*/
 double			deltay;						/* Ground range pixel dimension in metres						*/
/***********************************/
/* Other SAR instrument properties */
/***********************************/
 double			wavelength;					/* Wavelength in metres at centre frequency						*/
 double			frequency;					/* Centre frequency in Gigahertz.								*/
 double			k0;							/* Free space wavenumber in rads. inverse metres				*/
 double			azimuth_resolution;			/* Width at half height power of PSF in azimuth in metres		*/
 double			slant_range_resolution;		/* Width at half height power of PSF in slant range in metres	*/
 double			*ground_range_resolution;	/* Width at half height power of PSF in ground range in metres	*/
 double			f_azimuth;					/* Azimuth sampling frequency (ratio < 1.0)						*/
 double			f_ground_range;				/* Ground range sampling frequency (ratio < 1.0)				*/
/**************************************************/
/* Variables governing large-scale ground surface */
/**************************************************/
 double			large_scale_length;			/* Correlation length of large scale surface in metres			*/
 double			large_scale_height_stdev;	/* Height standard deviation for large scale ground surface (m)	*/
 double			slope_x;					/* Underlying mean terrain slope in azimuth (ratio)				*/
 double			slope_y;					/* Underlying mean terrain slope in ground range (ratio)		*/
 SIM_Record		Ground_Height;				/* Float image of ground heights in the SAR frame in metres		*/
/**************************************************/
/* Variables governing small-scale ground surface */
/**************************************************/
 double			small_scale_length;			/* Correlation length of small-scale surface in metres			*/
 double			small_scale_height_stdev;	/* Height standard deviation for small-scale ground surface (m)	*/
 Complex		ground_eps;					/* Soil dielectric permittivity									*/
/******************************************/
/* Variables governing forest description */
/******************************************/
 int			species;					/* Species of tree (see PolSARproSim_Definitions.h)				*/
 double			mean_tree_height;			/* User requested mean height of trees (allometric basis)		*/
 double			mean_crown_radius;			/* Estimated using allometric and mean tree height				*/
 double			close_packing_radius;		/* Fractional coverage is 0.907 with this radius				*/
 int			max_tree_number;			/* Estimated from close packing fraction						*/
 int			max_trees_per_hectare;		/* Calculated from max_stem_number								*/
 int			req_trees_per_hectare;		/* Stand density requested by the user							*/
 double			trees_per_100m;				/* Number of trees per unit 100m length of forest				*/
 TreeLoc		*Tree_Location;				/* List of tree locations, heights and crown radii in forest	*/
 int			nTreex;						/* Number of trees in azimuth direction							*/
 int			nTreey;						/* Number of trees in ground range direction					*/
 int			Trees;						/* Number of trees in the SAR image area						*/
 double			deltaTreex;					/* Azimuth tree separation in metres							*/
 double			deltaTreey;					/* Ground range tree separation in metres						*/
/**********************************************/
/* Variables governing short vegetation layer */
/**********************************************/
 double			shrt_vegi_depth;			/* Depth of short vegetation layer in metres					*/
 double			shrt_vegi_stem_vol_frac;	/* Volume fraction of short vegetation layer stems (ratio)		*/
 double			shrt_vegi_leaf_vol_frac;	/* Volume fraction of short vegetation layer stems (ratio)		*/
/********************************************/
/* Variables governing forest graphic image */
/********************************************/
 int			gnx;
 int			gny;
/*******************************/
/* Recovered forest properties */
/*******************************/
 double			primary_branch_length;		/* Mean primary branch length estimate in metres				*/
 double			primary_branch_radius;		/* Mean primary branch radius estimate in metres				*/
 double			secondary_branch_length;	/* Mean secondary branch length estimate in metres				*/
 double			secondary_branch_radius;	/* Mean secondary branch radius estimate in metres				*/
 double			tertiary_branch_length;		/* Mean tertiary branch length estimate in metres				*/
 double			tertiary_branch_radius;		/* Mean tertiary branch radius estimate in metres				*/
 double			ShortVegi_stemL1;			/* Short vegetation depolarization factors for stems			*/
 double			ShortVegi_stemL2;
 double			ShortVegi_stemL3;
 double			ShortVegi_leafL1;			/* Short vegetation depolarization factors for stems			*/
 double			ShortVegi_leafL2;
 double			ShortVegi_leafL3;
 double			Tertiary_branchL1;			/* Tertiary branch depolarization factors						*/
 double			Tertiary_branchL2;
 double			Tertiary_branchL3;
 double			Tertiary_leafL1;			/* Tertiary leaf depolarization factors							*/
 double			Tertiary_leafL2;
 double			Tertiary_leafL3;
/****************************/
/* Effective permittivities */
/****************************/
 Complex		e11_dry;
 Complex		e33_dry;
 Complex		e11_living;
 Complex		e33_living;
 Complex		e11_short;
 Complex		e33_short;
/**************************/
/* Effective wave vectors */
/**************************/
 double			kro2;
 double			kro;
 Complex		ko2_living;
 Complex		koz2_living;
 Complex		koz_living;
 Complex		ke2_living;
 Complex		kez2_living;
 Complex		kez_living;
 Complex		ko2_dry;
 Complex		koz2_dry;
 Complex		koz_dry;
 Complex		ke2_dry;
 Complex		kez2_dry;
 Complex		kez_dry;
 Complex		ko2_short;
 Complex		koz2_short;
 Complex		koz_short;
 Complex		ke2_short;
 Complex		kez2_short;
 Complex		kez_short;
/***********************************************************/
/* Tertiary branch scattering model flag: 0 = GRG, 1 = INF */
/***********************************************************/
 int			Grg_Flag;
/*****************************/
/* Attenuation lookup table  */
/*****************************/
 AttenuationMap	Amap;
/***************/
/* SAR imagery */
/***************/
 SIM_Record		HHimage;				/* HH SAR images are stored here									*/
 SIM_Record		HVimage;				/* HV SAR images are stored here									*/
 SIM_Record		VVimage;				/* VV SAR images are stored here									*/
 double			xmid;					/* Used to calculate image array indices							*/
 double			ymid;					/* Used to calculate image array indices							*/
 double			psfaaz;					/* Point spread function azimuth parameter							*/
 double			*psfagr;				/* Point spread function ground range parameter						*/
 double			psfasr;					/* Point spread function slant range parameter						*/
 int			PSFnx;					/* Number of azimuth pixels either side of centre in PSF image		*/
 int			PSFny;					/* Number of range   pixels either side of centre in PSF image		*/
 double			HHsf;					/* Normalisation factor recovered from HH DG image					*/
 double			HVsf;					/* Normalisation factor recovered from HH DG image					*/
 double			VVsf;					/* Normalisation factor recovered from HH DG image					*/
 double			PSFamp;					/* Scaling for the PSF to yield m.sq.pxl as backscattering coeff.	*/
/***********************/
/* File name variables */
/***********************/
 char			*pInputDirectory;		/* Name of directory in which input parameter file is located		*/
 char			*pMasterDirectory;		/* Name of directory in which track0 output is written				*/
 char			*pSlaveDirectory;		/* Name of directory in which track1 output is written				*/
 char			*pFilenamePrefix;		/* Filename prefix for input, output and log files					*/
 char			*HH_string;				/* Full filename for current track									*/
 char			*HV_string;				/* Full filename for current track									*/
 char			*VH_string;				/* Full filename for current track									*/
 char			*VV_string;				/* Full filename for current track									*/
/**********************/
/* Progress indicator */
/**********************/
 int			progress;				/* Indicates progress of simulation on stdout						*/
} PolSARproSim_Record;

/*********************************/
/* TreeDisc structure definition */
/*********************************/

typedef struct treedisc_tag {
 TreeLoc		t;
 double			cost;
 int			nnlist[TREE_LOCATION_NEAREST_NEIGHBOURS];
} TreeDisc;

/**********************************************************/
/* Information for graphic drawing in a drawing structure */
/**********************************************************/

typedef struct drawing_record_tag {
 Perspective		*pP;
 Lighting_Record	*pL;
 d33Matrix			*pRx;
 d3Vector			*pTzy;
} Drawing_Record;

#endif
