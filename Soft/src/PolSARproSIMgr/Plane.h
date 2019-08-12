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
 * Module      : Plane.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __PLANE_H__
#define __PLANE_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "d3Vector.h"

/******************************/
/* Plane structure definition */
/******************************/

typedef struct plane_tag {
 d3Vector	p0;					/* A known point in the plane						*/
 double		sx;					/* The slope of the plane in the global x direction	*/
 double		sy;					/* The slope of the plane in the global y direction	*/
 d3Vector	np;					/* A unit vector normal to the plane 				*/
 d3Vector	xp;					/* A unit vector in the plane						*/
 d3Vector	yp;					/* A unit vector in the plane normal to xp and np	*/
 struct		plane_tag *next;
 struct		plane_tag *prev;
} Plane;

/*****************************/
/* Plane function prototypes */
/*****************************/

void		Create_Plane		(Plane *p_p);
void		Destroy_Plane		(Plane *p_p);
void		Copy_Plane			(Plane *p_pCopy, Plane *p_pOriginal);
void		Print_Plane			(Plane *p_p);
void		Assign_Plane		(Plane *p_p, d3Vector *p_p0, double sx, double sy);
void		Plane_Orthonormals	(Plane *p_p);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct plane_list_tag {
 struct		plane_tag *head;
 struct		plane_tag *tail;
 long		n;
} Plane_List;

void		Plane_init_list			(Plane_List *p_pl);
int			Plane_head_add			(Plane_List *p_pl, Plane *p_p);
int			Plane_head_sub			(Plane_List *p_pl, Plane *p_p);
void		Plane_head_print		(Plane_List *p_pl);
int			Plane_tail_add			(Plane_List *p_pl, Plane *p_p);
int			Plane_tail_sub			(Plane_List *p_pl, Plane *p_p);
void		Plane_tail_print		(Plane_List *p_pl);
long		Plane_List_length		(Plane_List *p_pl);
Plane*		Plane_List_head			(Plane_List *p_pl);
Plane*		Plane_List_tail			(Plane_List *p_pl);
int			Plane_insert			(Plane_List *p_pl, Plane *p_p, long m);
int			Plane_delete			(Plane_List *p_pl, Plane *p_p, long m);
void		Plane_empty_list		(Plane_List *p_pl);

/************************/
/* d3Vector definitions */
/************************/

#define		NO_PLANE_ERRORS		0
#define		NULL_PTR2PLANE		0
#define		NULL_PTR2PLANE_LIST	0

#endif
