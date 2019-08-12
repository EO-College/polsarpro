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
 * Module      : Crown.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __CROWN_H__
#define __CROWN_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "d3Vector.h"
#include "Trig.h"

/******************************/
/* Crown structure definition */
/******************************/

typedef struct crown_tag {
 int		shape;					/* Crown shape																						*/
 double		beta;					/* The angle between the crown axis and a line between the crown tip and a point on the base edge	*/
 double		d1;						/* The semi-major axis of the ellipsoid or cone/cylinder length in metres							*/
 double		d2;						/* The semi-minor axis of the ellipsoid or cone/cylinder base radius in metres						*/
 double		d3;						/* The truncation length from ellipsoid tip or cone/cylinder length in metres						*/
 double		volume;					/* Approximate crown volume (m^3) for non-sloping bounding planes.									*/
 d3Vector	base;					/* A point in the centre of the base of the crown volume											*/
 d3Vector	axis;					/* A unit vector in the major axial direction														*/
 d3Vector	x;						/* A unit vector normal to the major axial direction												*/
 d3Vector	y;						/* A unit vector normal to both axis and x															*/
 double		sx;						/* The slope in the global x direction of a bounding plane											*/
 double		sy;						/* The slope in the global y direction of a bounding plane											*/
 struct		crown_tag *next;
 struct		crown_tag *prev;
} Crown;

/*****************************/
/* Crown function prototypes */
/*****************************/

void		Create_Crown	(Crown *p_cwn);
void		Destroy_Crown	(Crown *p_cwn);
void		Copy_Crown		(Crown *p_cwnCopy, Crown *p_cwnOriginal);
void		Print_Crown		(Crown *p_cwn);
void		Assign_Crown	(Crown *p_cwn, int shape, double beta, double d1, double d2, double d3,
							 d3Vector base, d3Vector axis, double sx, double sy);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct crown_list_tag {
 struct		crown_tag *head;
 struct		crown_tag *tail;
 long		n;
} Crown_List;

void		Crown_init_list			(Crown_List *p_cwnl);
int			Crown_head_add			(Crown_List *p_cwnl, Crown *p_cwn);
int			Crown_head_sub			(Crown_List *p_cwnl, Crown *p_cwn);
void		Crown_head_print		(Crown_List *p_cwnl);
int			Crown_tail_add			(Crown_List *p_cwnl, Crown *p_cwn);
int			Crown_tail_sub			(Crown_List *p_cwnl, Crown *p_cwn);
void		Crown_tail_print		(Crown_List *p_cwnl);
long		Crown_List_length		(Crown_List *p_cwnl);
Crown*		Crown_List_head			(Crown_List *p_cwnl);
Crown*		Crown_List_tail			(Crown_List *p_cwnl);
int			Crown_insert			(Crown_List *p_cwnl, Crown *p_cwn, long m);
int			Crown_delete			(Crown_List *p_cwnl, Crown *p_cwn, long m);
void		Crown_empty_list		(Crown_List *p_cwnl);

void		Crown_List_Copy			(Crown_List *pCL_Copy, Crown_List *pCL_Org);

/*********************/
/* Crown definitions */
/*********************/

#define		NO_CROWN_ERRORS		0
#define		NULL_PTR2CROWN		0
#define		NULL_PTR2CROWN_LIST	0

/****************************/
/* Crown shape enumerations */
/****************************/

#define		CROWN_CYLINDER		0
#define		CROWN_CONE			1
#define		CROWN_SPHEROID		2
#define		CROWN_NULL_SHAPE	99

#endif
