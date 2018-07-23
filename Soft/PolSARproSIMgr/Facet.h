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
 * Module      : Facet.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __FACET_H__
#define __FACET_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>

#include "d33Matrix.h"
#include "d3Vector.h"

/******************************/
/* Facet structure definition */
/******************************/

typedef struct facet_tag {
 d3Vector	r[4];				/* three corners and a centre	*/
 d3Vector	n;					/* facet normal					*/
 struct		facet_tag *next;
 struct		facet_tag *prev;
} Facet;

/*****************************/
/* Facet function prototypes */
/*****************************/

void		Create_Facet	(Facet *p_f);
void		Destroy_Facet	(Facet *p_f);
void		Copy_Facet		(Facet *p_fCopy, Facet *p_fOriginal);
void		Print_Facet		(Facet *p_f);
void		Assign_Facet	(Facet *p_f, d3Vector *p_r0, d3Vector *p_r1, d3Vector *p_r2);

void		facet_normal	(Facet *p_f);
void		facet_centre	(Facet *p_f);
double		facet_area		(Facet *p_f);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct facet_list_tag {
 struct		facet_tag *head;
 struct		facet_tag *tail;
 long		n;
} Facet_List;

void		Facet_init_list			(Facet_List *p_fl);
int			Facet_head_add			(Facet_List *p_fl, Facet *p_f);
int			Facet_head_sub			(Facet_List *p_fl, Facet *p_f);
void		Facet_head_print		(Facet_List *p_fl);
int			Facet_tail_add			(Facet_List *p_fl, Facet *p_f);
int			Facet_tail_sub			(Facet_List *p_fl, Facet *p_f);
void		Facet_tail_print		(Facet_List *p_fl);
long		Facet_List_length		(Facet_List *p_fl);
Facet*		Facet_List_head			(Facet_List *p_fl);
Facet*		Facet_List_tail			(Facet_List *p_fl);
int			Facet_insert			(Facet_List *p_fl, Facet *p_f, long m);
int			Facet_delete			(Facet_List *p_fl, Facet *p_f, long m);
void		Facet_empty_list		(Facet_List *p_fl);

/************************/
/* d3Vector definitions */
/************************/

#define		NO_FACET_ERRORS		0
#define		NULL_PTR2FACET		0
#define		NULL_PTR2FACET_LIST	0

#endif
