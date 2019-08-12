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
 * Module      : Ray.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __RAY_H__
#define __RAY_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "d3Vector.h"

/******************************/
/* Ray structure definition */
/******************************/

typedef struct ray_tag {
 d3Vector	s0;					/* The starting point of the ray					*/
 double		theta;				/* The polar angle of the ray direction				*/
 double		phi;				/* The azimuth angle of the ray direction			*/
 d3Vector	a;					/* The unit vector in the ray direction 			*/
 struct		ray_tag *next;
 struct		ray_tag *prev;
} Ray;

/*****************************/
/* Ray function prototypes */
/*****************************/

void		Create_Ray		(Ray *p_r);
void		Destroy_Ray		(Ray *p_r);
void		Copy_Ray		(Ray *p_rCopy, Ray *p_rOriginal);
void		Print_Ray		(Ray *p_r);
void		Assign_Ray		(Ray *p_r, d3Vector *p_s0, double theta, double phi);
void		Assign_Ray_d3V	(Ray *p_r, d3Vector *p_s0, d3Vector *p_a);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct ray_list_tag {
 struct		ray_tag *head;
 struct		ray_tag *tail;
 long		n;
} Ray_List;

void		Ray_init_list		(Ray_List *p_rl);
int			Ray_head_add		(Ray_List *p_rl, Ray *p_r);
int			Ray_head_sub		(Ray_List *p_rl, Ray *p_r);
void		Ray_head_print		(Ray_List *p_rl);
int			Ray_tail_add		(Ray_List *p_rl, Ray *p_r);
int			Ray_tail_sub		(Ray_List *p_rl, Ray *p_r);
void		Ray_tail_print		(Ray_List *p_rl);
long		Ray_List_length		(Ray_List *p_rl);
Ray*		Ray_List_head		(Ray_List *p_rl);
Ray*		Ray_List_tail		(Ray_List *p_rl);
int			Ray_insert			(Ray_List *p_rl, Ray *p_r, long m);
int			Ray_delete			(Ray_List *p_rl, Ray *p_r, long m);
void		Ray_empty_list		(Ray_List *p_rl);

/************************/
/* d3Vector definitions */
/************************/

#define		NO_RAY_ERRORS		0
#define		NULL_PTR2RAY		0
#define		NULL_PTR2RAY_LIST	0

#endif
