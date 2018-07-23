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
 * Module      : Branch.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __BRANCH_H__
#define __BRANCH_H__

#include	<math.h>
#include	<stdlib.h>
#include	<stdio.h>
#include	<float.h>

#include	"Complex.h"
#include	"d3Vector.h"
#include	"MonteCarlo.h"
#include	"Trig.h"

/******************************/
/* Branch structure definition */
/******************************/

typedef struct branch_tag {
 double		l;					/* The length of the branch in metres						*/
 double		start_radius;		/* The start radius of the branch in metres					*/
 double		end_radius;			/* The end radius of the branch in metres					*/
 double		dp;					/* The tropism factor for the initial direction				*/
 double		dp_coeff;			/* The tropism coefficient for the initial direction		*/
 double		phix;				/* A curvature random angle									*/ 
 double		phiy;				/* A curvature random angle									*/
 double		phicx;				/* A curvature random angle									*/
 double		phicy;				/* A curvature random angle									*/
 double		lamdacx;			/* A curvature random wavelength							*/
 double		lamdacy;			/* A curvature random wavelength							*/
 double		gamma;				/* The curvature scaling									*/
 double		moisture;			/* Fractional moisture content of branch					*/
 Complex	permittivity;		/* The effective dielectric permittivity of the cylinder	*/
 d3Vector	b0;					/* The branch beginning										*/
 d3Vector	z0;					/* The initial branch direction								*/
 d3Vector	p;					/* The tropism direction for this branch					*/
 int		id;					/* Unique number for this branch in a tree					*/
 int		idorg;				/* The number of the parent branch for this branch			*/
 struct		branch_tag *next;
 struct		branch_tag *prev;
} Branch;

/*****************************/
/* Branch function prototypes */
/*****************************/

void		Create_Branch	(Branch *p_b);
void		Destroy_Branch	(Branch *p_b);
void		Copy_Branch		(Branch *p_bCopy, Branch *p_bOriginal);
void		Print_Branch	(Branch *p_b);
void		Assign_Branch	(Branch *p_b, double sr, double er, d3Vector b0, d3Vector z0, d3Vector p,
							 double dp, double phix, double phiy, double phicx, double phicy,
							 double lamdacx, double lamdacy, double gamma, double moisture,
							 double l, Complex permittivity, int id, int idorg);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct branch_list_tag {
 struct		branch_tag *head;
 struct		branch_tag *tail;
 long		n;
} Branch_List;

void		Branch_init_list		(Branch_List *p_bl);
int			Branch_head_add			(Branch_List *p_bl, Branch *p_b);
int			Branch_head_sub			(Branch_List *p_bl, Branch *p_b);
void		Branch_head_print		(Branch_List *p_bl);
int			Branch_tail_add			(Branch_List *p_bl, Branch *p_b);
int			Branch_tail_sub			(Branch_List *p_bl, Branch *p_b);
void		Branch_tail_print		(Branch_List *p_bl);
long		Branch_List_length		(Branch_List *p_bl);
Branch*		Branch_List_head		(Branch_List *p_bl);
Branch*		Branch_List_tail		(Branch_List *p_bl);
int			Branch_insert			(Branch_List *p_bl, Branch *p_b, long m);
int			Branch_delete			(Branch_List *p_bl, Branch *p_b, long m);
void		Branch_empty_list		(Branch_List *p_bl);

void		Branch_List_Copy		(Branch_List *pBL_Copy, Branch_List *pBL_Org);

/**********************/
/* Branch definitions */
/**********************/

#define		NO_BRANCH_ERRORS					0
#define		NULL_PTR2BRANCH						0
#define		NULL_PTR2BRANCH_LIST				0
#define		ALPHA_GOLDEN						1.61803399		/* Golden ratio for use with branch curvature					*/
#define		BRANCH_DIRECTION_ROUNDING_LIMIT		FLT_EPSILON

/***************************/
/* Other branch prototypes */
/***************************/

int			Branch_Directions	(Branch *pB, double t, d3Vector *pX, d3Vector *pY, d3Vector *pZ);
d3Vector	Branch_Crookedness	(Branch *pB, double t);
d3Vector	Branch_Centre		(Branch *pB, double t);
double		Branch_Radius		(Branch *pB, double t);

#endif
