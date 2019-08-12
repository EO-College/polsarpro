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
 * Module      : c3Vector.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __C3VECTOR_H__
#define __C3VECTOR_H__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>

#include	"Complex.h"

typedef struct c3vector_tag {
 Complex	z[3];
 struct		c3vector_tag *next;
 struct		c3vector_tag *prev;
} c3Vector;

/************************/
/* Fundamental routines */
/************************/

void		Create_c3Vector						(c3Vector *p_c3v);
void		Destroy_c3Vector					(c3Vector *p_c3v);
void		Read_c3Vector						(FILE *pF, c3Vector *p_c3v);
void		Write_c3Vector						(FILE *pF, c3Vector *p_c3v);
void		Print_c3Vector						(c3Vector *p_c3v);
void		Copy_c3Vector						(c3Vector *p_c3vCopy, c3Vector *p_c3vOriginal);
c3Vector	Assign_c3Vector						(Complex x, Complex y, Complex z);
c3Vector	Zero_c3Vector						(void);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct c3vector_list_tag {
 struct		c3vector_tag *head;
 struct		c3vector_tag *tail;
 long		n;
} c3Vector_List;

void		c3Vector_init_list			(c3Vector_List *p_c3vl);
int			c3Vector_head_add			(c3Vector_List *p_c3vl, c3Vector *p_c3v);
int			c3Vector_head_sub			(c3Vector_List *p_c3vl, c3Vector *p_c3v);
void		c3Vector_head_print			(c3Vector_List *p_c3vl);
int			c3Vector_tail_add			(c3Vector_List *p_c3vl, c3Vector *p_c3v);
int			c3Vector_tail_sub			(c3Vector_List *p_c3vl, c3Vector *p_c3v);
void		c3Vector_tail_print			(c3Vector_List *p_c3vl);
long		c3Vector_List_length		(c3Vector_List *p_c3vl);
c3Vector*	c3Vector_List_head			(c3Vector_List *p_c3vl);
c3Vector*	c3Vector_List_tail			(c3Vector_List *p_c3vl);
int			c3Vector_insert				(c3Vector_List *p_c3vl, c3Vector *p_c3v, long m);
int			c3Vector_delete				(c3Vector_List *p_c3vl, c3Vector *p_c3v, long m);
void		c3Vector_empty_list			(c3Vector_List *p_c3vl);

/************************/
/* c3Vector definitions */
/************************/

#define		NO_C3VECTOR_ERRORS		0
#define		NULL_PTR2C3VECTOR		0
#define		NULL_PTR2C3VECTOR_LIST	0

#define		C3VECTOR_SUPPRESS_ERROR_MESSAGES

/*****************/
/* Miscellaneous */
/*****************/

c3Vector	c3Vector_scalar_multiply			(c3Vector c3v, Complex z);
c3Vector	c3Vector_scalar_divide				(c3Vector c3v, Complex z);
c3Vector	c3Vector_normalise					(c3Vector c3v);
Complex		c3Vector_scalar_product				(c3Vector c3v1, c3Vector c3v2);
c3Vector	c3Vector_difference					(c3Vector c3v1, c3Vector c3v2);
c3Vector	c3Vector_cross_product				(c3Vector c3v1, c3Vector c3v2);
c3Vector	c3Vector_sum						(c3Vector c3v1, c3Vector c3v2);

#endif
