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
 * Module      : Cone.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __CONE_H__
#define __CONE_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "d3Vector.h"

/*****************************/
/* Cone structure definition */
/*****************************/

typedef struct cone_tag {
 double		height;				/* The height of the cone in metres						*/
 double		radius;				/* The base radius of the cone in metres				*/
 double		beta;				/* The cone internal half angle, atan(radius/height)	*/
 d3Vector	base;				/* A point in the centre of the base of the cone		*/
 d3Vector	axis;				/* A unit vector in the cone axial direction			*/
 d3Vector	x;					/* A unit vector normal to the axial direction			*/
 d3Vector	y;					/* A unit vector normal to both axis and x				*/
 struct		cone_tag *next;
 struct		cone_tag *prev;
} Cone;

/****************************/
/* Cone function prototypes */
/****************************/

void		Create_Cone		(Cone *p_c);
void		Destroy_Cone	(Cone *p_c);
void		Copy_Cone		(Cone *p_cCopy, Cone *p_cOriginal);
void		Print_Cone		(Cone *p_c);
void		Assign_Cone		(Cone *p_c, double height, double radius, d3Vector axis, d3Vector base);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct cone_list_tag {
 struct		cone_tag *head;
 struct		cone_tag *tail;
 long		n;
} Cone_List;

void		Cone_init_list			(Cone_List *p_cl);
int			Cone_head_add			(Cone_List *p_cl, Cone *p_c);
int			Cone_head_sub			(Cone_List *p_cl, Cone *p_c);
void		Cone_head_print			(Cone_List *p_cl);
int			Cone_tail_add			(Cone_List *p_cl, Cone *p_c);
int			Cone_tail_sub			(Cone_List *p_cl, Cone *p_c);
void		Cone_tail_print			(Cone_List *p_cl);
long		Cone_List_length		(Cone_List *p_cl);
Cone*		Cone_List_head			(Cone_List *p_cl);
Cone*		Cone_List_tail			(Cone_List *p_cl);
int			Cone_insert				(Cone_List *p_cl, Cone *p_c, long m);
int			Cone_delete				(Cone_List *p_cl, Cone *p_c, long m);
void		Cone_empty_list			(Cone_List *p_cl);

/********************/
/* Cone definitions */
/********************/

#define		NO_CONE_ERRORS		0
#define		NULL_PTR2CONE		0
#define		NULL_PTR2CONE_LIST	0

#endif
