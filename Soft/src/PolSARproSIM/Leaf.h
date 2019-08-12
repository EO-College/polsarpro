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
 * Module      : Leaf.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __LEAF_H__
#define __LEAF_H__

#include	<math.h>
#include	<stdlib.h>
#include	<stdio.h>
#include	<float.h>

#include	"Complex.h"
#include	"d3Vector.h"
#include	"MonteCarlo.h"
#include	"Trig.h"

/*****************************/
/* Leaf structure definition */
/*****************************/

typedef struct leaf_tag {
 int		species;			/* The type fo leaf (needle or deciduous)					*/
 double		d1;					/* Leaf dimension #1 in metres								*/
 double		d2;					/* Leaf dimension #2 in metres								*/
 double		d3;					/* Leaf dimension #3 in metres								*/
 double		theta;				/* Leaf polar angle	in radians								*/
 double		phi;				/* Leaf azimuth angle in radians							*/
 double		moisture;			/* Fractional moisture content of the leaf					*/
 Complex	permittivity;		/* The effective dielectric permittivity of the cylinder	*/
 d3Vector	cl;					/* The leaf centre											*/
 d3Vector	xl;					/* The leaf local coordinate sytem vector					*/
 d3Vector	yl;					/* The leaf local coordinate sytem vector					*/
 d3Vector	zl;					/* The leaf local coordinate sytem vector					*/
 struct		leaf_tag *next;
 struct		leaf_tag *prev;
} Leaf;

/****************************/
/* Leaf function prototypes */
/****************************/

void		Create_Leaf		(Leaf *pL);
void		Destroy_Leaf	(Leaf *pL);
void		Copy_Leaf		(Leaf *pLCopy, Leaf *pLOriginal);
void		Print_Leaf		(Leaf *pL);
void		Assign_Leaf		(Leaf *pL, int species, double d1, double d2, double d3, double theta, double phi,
							 double moisture, Complex permittivity, d3Vector cl);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct leaf_list_tag {
 struct		leaf_tag *head;
 struct		leaf_tag *tail;
 long		n;
} Leaf_List;

void		Leaf_init_list		(Leaf_List *pLl);
int			Leaf_head_add		(Leaf_List *pLl, Leaf *pL);
int			Leaf_head_sub		(Leaf_List *pLl, Leaf *pL);
void		Leaf_head_print		(Leaf_List *pLl);
int			Leaf_tail_add		(Leaf_List *pLl, Leaf *pL);
int			Leaf_tail_sub		(Leaf_List *pLl, Leaf *pL);
void		Leaf_tail_print		(Leaf_List *pLl);
long		Leaf_List_length	(Leaf_List *pLl);
Leaf*		Leaf_List_head		(Leaf_List *pLl);
Leaf*		Leaf_List_tail		(Leaf_List *pLl);
int			Leaf_insert			(Leaf_List *pLl, Leaf *pL, long m);
int			Leaf_delete			(Leaf_List *pLl, Leaf *pL, long m);
void		Leaf_empty_list		(Leaf_List *pLl);
void		Leaf_List_Copy		(Leaf_List *pLL_Copy, Leaf_List *pLL_Org);

/********************/
/* Leaf definitions */
/********************/

#define		NO_LEAF_ERRORS						0
#define		NULL_PTR2LEAF						0
#define		NULL_PTR2LEAF_LIST					0
#define		LEAF_DIRECTION_ROUNDING_LIMIT		FLT_EPSILON

/****************************/
/* Leaf species enumeration */
/****************************/

#define		POLSARPROSIM_PINE_NEEDLE			0
#define		POLSARPROSIM_DECIDUOUS_LEAF			1
#define		POLSARPROSIM_NON_LEAF				99

/*************************/
/* Other leaf prototypes */
/*************************/

int			Leaf_Directions		(Leaf *pL);
double		Leaf_Volume			(Leaf *pL);

#endif
