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
 * Module      : Tree.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __TREE_H__
#define __TREE_H__

#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <float.h>
#include <string.h>

#include	"Branch.h"
#include	"Complex.h"
#include	"Crown.h"
#include	"Cylinder.h"
#include	"d3Vector.h"
#include	"Leaf.h"
#include	"MonteCarlo.h"
#include	"Trig.h"

/******************************/
/* Tree structure definition */
/******************************/

typedef struct tree_tag {
 int				species;			/* Species of tree													*/
 d3Vector			base;				/* Stem base position												*/
 double				height;				/* Length of stem in the stem direction								*/
 double				radius;				/* The nominal maximum crownn radius								*/
 Branch_List		Stem;				/* List of tree trunks, can be more than one						*/
 Branch_List		Primary;			/* List of living primary branches									*/
 Branch_List		Dry;				/* List of dry primary branches										*/
 Branch_List		Secondary;			/* List of secondary branches										*/
 Branch_List		Tertiary;			/* List of tertiary branches										*/
 Leaf_List			Foliage;			/* List of leaves													*/
 Crown_List			CrownVolume;		/* List of volumes occupied by tertiary branches and leaves			*/
 struct	tree_tag	*next;
 struct	tree_tag	*prev;
} Tree;

/*****************************/
/* Tree function prototypes */
/*****************************/

void		Create_Tree		(Tree *p_t);
void		Destroy_Tree	(Tree *p_t);
void		Copy_Tree		(Tree *p_tCopy, Tree *p_tOriginal);
void		Print_Tree		(Tree *p_t);

/*************************************/
/* Doubly linked list implementation */
/*************************************/

typedef struct tree_list_tag {
 struct		tree_tag *head;
 struct		tree_tag *tail;
 long		n;
} Tree_List;

void		Tree_init_list			(Tree_List *p_tl);
int			Tree_head_add			(Tree_List *p_tl, Tree *p_t);
int			Tree_head_sub			(Tree_List *p_tl, Tree *p_t);
void		Tree_head_print			(Tree_List *p_tl);
int			Tree_tail_add			(Tree_List *p_tl, Tree *p_t);
int			Tree_tail_sub			(Tree_List *p_tl, Tree *p_t);
void		Tree_tail_print			(Tree_List *p_tl);
long		Tree_List_length		(Tree_List *p_tl);
Tree*		Tree_List_head			(Tree_List *p_tl);
Tree*		Tree_List_tail			(Tree_List *p_tl);
int			Tree_insert				(Tree_List *p_tl, Tree *p_t, long m);
int			Tree_delete				(Tree_List *p_tl, Tree *p_t, long m);
void		Tree_empty_list			(Tree_List *p_tl);

/********************/
/* Tree definitions */
/********************/

#define		NO_TREE_ERRORS		0
#define		NULL_PTR2TREE		0
#define		NULL_PTR2TREE_LIST	0

#define		TREE_NULL_SPECIES	99

#endif
