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
 * Module      : Spheroid.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __SPHEROID_H__
#define __SPHEROID_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "d3Vector.h"

/*****************************/
/* Spheroid structure definition */
/*****************************/

typedef struct spheroid_tag {
 double		a1;						/* The axial semi-axis in metres						*/
 double		a2;						/* The semi-minor-axis in metres						*/
 double		h;						/* The tip to base distance in metres					*/
 double		beta;					/* The internal half angle, atan(a2/a1)					*/
 d3Vector	base;					/* A point in the centre of the base of the spheroid	*/
 d3Vector	axis;					/* A unit vector in the spheroid axial direction		*/
 d3Vector	x;						/* A unit vector normal to the axial direction			*/
 d3Vector	y;						/* A unit vector normal to both axis and x				*/
 struct		spheroid_tag *next;
 struct		spheroid_tag *prev;
} Spheroid;

/****************************/
/* Spheroid function prototypes */
/****************************/

void		Create_Spheroid		(Spheroid *p_s);
void		Destroy_Spheroid	(Spheroid *p_s);
void		Copy_Spheroid		(Spheroid *p_sCopy, Spheroid *p_sOriginal);
void		Print_Spheroid		(Spheroid *p_s);
void		Assign_Spheroid		(Spheroid *p_s, double a1, double a2, double h, d3Vector axis, d3Vector base);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct spheroid_list_tag {
 struct		spheroid_tag *head;
 struct		spheroid_tag *tail;
 long		n;
} Spheroid_List;

void		Spheroid_init_list			(Spheroid_List *p_sl);
int			Spheroid_head_add			(Spheroid_List *p_sl, Spheroid *p_s);
int			Spheroid_head_sub			(Spheroid_List *p_sl, Spheroid *p_s);
void		Spheroid_head_print			(Spheroid_List *p_sl);
int			Spheroid_tail_add			(Spheroid_List *p_sl, Spheroid *p_s);
int			Spheroid_tail_sub			(Spheroid_List *p_sl, Spheroid *p_s);
void		Spheroid_tail_print			(Spheroid_List *p_sl);
long		Spheroid_List_length		(Spheroid_List *p_sl);
Spheroid*	Spheroid_List_head			(Spheroid_List *p_sl);
Spheroid*	Spheroid_List_tail			(Spheroid_List *p_sl);
int			Spheroid_insert				(Spheroid_List *p_sl, Spheroid *p_s, long m);
int			Spheroid_delete				(Spheroid_List *p_sl, Spheroid *p_s, long m);
void		Spheroid_empty_list			(Spheroid_List *p_sl);

/********************/
/* Spheroid definitions */
/********************/

#define		NO_SPHEROID_ERRORS		0
#define		NULL_PTR2SPHEROID		0
#define		NULL_PTR2SPHEROID_LIST	0

#endif
