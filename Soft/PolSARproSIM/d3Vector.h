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
 * Module      : d3Vector.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __D3VECTOR_H__
#define __D3VECTOR_H__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>

typedef struct d3vector_tag {
 double		x[3];
 double		r;
 double		theta;
 double		phi;
 struct		d3vector_tag *next;
 struct		d3vector_tag *prev;
} d3Vector;

void		Create_d3Vector						(d3Vector *p_d3v);
void		Destroy_d3Vector					(d3Vector *p_d3v);
void		Polar_d3Vector						(d3Vector *p_d3v);
void		Cartesian_d3Vector					(d3Vector *p_d3v);
void		Read_d3Vector						(FILE *pF, d3Vector *p_d3v);
void		Write_d3Vector						(FILE *pF, d3Vector *p_d3v);
void		Print_d3Vector						(d3Vector *p_d3v);
void		Copy_d3Vector						(d3Vector *p_d3vCopy, d3Vector *p_d3vOriginal);
d3Vector	Cartesian_Assign_d3Vector			(double x, double y, double z);
d3Vector	Polar_Assign_d3Vector				(double r, double theta, double phi);
d3Vector	Zero_d3Vector						(void);

void		d3Vector_insitu_double_multiply		(d3Vector *p_d3v, double x);
void		d3Vector_insitu_double_divide		(d3Vector *p_d3v, double x);
void		d3Vector_insitu_normalise			(d3Vector *p_d3v);
d3Vector	d3Vector_double_multiply			(d3Vector d3v, double x);
d3Vector	d3Vector_double_divide				(d3Vector d3v, double x);
d3Vector	d3Vector_normalise					(d3Vector d3v);
double		d3Vector_scalar_product				(d3Vector d3v1, d3Vector d3v2);
d3Vector	d3Vector_difference					(d3Vector d3v1, d3Vector d3v2);
d3Vector	d3Vector_cross_product				(d3Vector d3v1, d3Vector d3v2);
d3Vector	d3Vector_reflect					(d3Vector d3v,  d3Vector n);
d3Vector	d3Vector_sum						(d3Vector d3v1, d3Vector d3v2);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct d3vector_list_tag {
 struct		d3vector_tag *head;
 struct		d3vector_tag *tail;
 long		n;
} d3Vector_List;

void		d3Vector_init_list			(d3Vector_List *p_d3vl);
int			d3Vector_head_add			(d3Vector_List *p_d3vl, d3Vector *p_d3v);
int			d3Vector_head_sub			(d3Vector_List *p_d3vl, d3Vector *p_d3v);
void		d3Vector_head_print			(d3Vector_List *p_d3vl);
int			d3Vector_tail_add			(d3Vector_List *p_d3vl, d3Vector *p_d3v);
int			d3Vector_tail_sub			(d3Vector_List *p_d3vl, d3Vector *p_d3v);
void		d3Vector_tail_print			(d3Vector_List *p_d3vl);
long		d3Vector_List_length		(d3Vector_List *p_d3vl);
d3Vector*	d3Vector_List_head			(d3Vector_List *p_d3vl);
d3Vector*	d3Vector_List_tail			(d3Vector_List *p_d3vl);
int			d3Vector_insert				(d3Vector_List *p_d3vl, d3Vector *p_d3v, long m);
int			d3Vector_delete				(d3Vector_List *p_d3vl, d3Vector *p_d3v, long m);
void		d3Vector_empty_list			(d3Vector_List *p_d3vl);

/************************/
/* d3Vector definitions */
/************************/

#define		NO_D3VECTOR_ERRORS		0
#define		NULL_PTR2D3VECTOR		0
#define		NULL_PTR2D3VECTOR_LIST	0

#endif
