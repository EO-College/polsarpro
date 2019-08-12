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
 * Module      : Cylinder.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __CYLINDER_H__
#define __CYLINDER_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "Complex.h"
#include "d3Vector.h"

/******************************/
/* Cylinder structure definition */
/******************************/

typedef struct cylinder_tag {
 double		length;			/* The length of the cylinder in metres						*/
 double		radius;			/* The radius of the cylinder in metres						*/
 d3Vector	base;			/* A point in the centre of the end of the cylinder			*/
 d3Vector	axis;			/* A unit vector in the cylinder axial direction			*/
 d3Vector	x;				/* A unit vector normal to the axial direction				*/
 d3Vector	y;				/* A unit vector normal to both axis and x					*/
 Complex	permittivity;	/* The effective dielectric permittivity of the cylinder	*/
 struct		cylinder_tag *next;
 struct		cylinder_tag *prev;
} Cylinder;

/*****************************/
/* Cylinder function prototypes */
/*****************************/

void		Create_Cylinder		(Cylinder *p_c);
void		Destroy_Cylinder	(Cylinder *p_c);
void		Copy_Cylinder		(Cylinder *p_cCopy, Cylinder *p_cOriginal);
void		Print_Cylinder		(Cylinder *p_c);
void		Assign_Cylinder		(Cylinder *p_c, double length, double radius, Complex permittivity, d3Vector axis,
								 d3Vector base);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct cylinder_list_tag {
 struct		cylinder_tag *head;
 struct		cylinder_tag *tail;
 long		n;
} Cylinder_List;

void		Cylinder_init_list			(Cylinder_List *p_cl);
int			Cylinder_head_add			(Cylinder_List *p_cl, Cylinder *p_c);
int			Cylinder_head_sub			(Cylinder_List *p_cl, Cylinder *p_c);
void		Cylinder_head_print			(Cylinder_List *p_cl);
int			Cylinder_tail_add			(Cylinder_List *p_cl, Cylinder *p_c);
int			Cylinder_tail_sub			(Cylinder_List *p_cl, Cylinder *p_c);
void		Cylinder_tail_print			(Cylinder_List *p_cl);
long		Cylinder_List_length		(Cylinder_List *p_cl);
Cylinder*	Cylinder_List_head			(Cylinder_List *p_cl);
Cylinder*	Cylinder_List_tail			(Cylinder_List *p_cl);
int			Cylinder_insert				(Cylinder_List *p_cl, Cylinder *p_c, long m);
int			Cylinder_delete				(Cylinder_List *p_cl, Cylinder *p_c, long m);
void		Cylinder_empty_list			(Cylinder_List *p_cl);

/************************/
/* Cylinder definitions */
/************************/

#define		NO_CYLINDER_ERRORS		0
#define		NULL_PTR2CYLINDER		0
#define		NULL_PTR2CYLINDER_LIST	0

#endif
