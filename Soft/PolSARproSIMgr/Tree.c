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
 * Module      : Tree.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"Tree.h"

/**********************************/
/* Tree function implementations */
/**********************************/

void		Create_Tree	(Tree *p_t)
{
 p_t->species		= TREE_NULL_SPECIES;
 p_t->height		= 0.0;
 p_t->radius		= 0.0;
 p_t->base			= Zero_d3Vector ();
 Branch_init_list	(&(p_t->Stem));
 Branch_init_list	(&(p_t->Primary));
 Branch_init_list	(&(p_t->Dry));
 Branch_init_list	(&(p_t->Secondary));
 Branch_init_list	(&(p_t->Tertiary));
 Leaf_init_list		(&(p_t->Foliage));
 Crown_init_list	(&(p_t->CrownVolume));
 p_t->next	= NULL_PTR2TREE;
 p_t->prev	= NULL_PTR2TREE;
 return;
}

void		Destroy_Tree	(Tree *p_t)
{
 p_t->species		= TREE_NULL_SPECIES;
 p_t->height		= 0.0;
 p_t->radius		= 0.0;
 p_t->base			= Zero_d3Vector ();
 Branch_empty_list	(&(p_t->Stem));
 Branch_empty_list	(&(p_t->Primary));
 Branch_empty_list	(&(p_t->Dry));
 Branch_empty_list	(&(p_t->Secondary));
 Branch_empty_list	(&(p_t->Tertiary));
 Leaf_empty_list	(&(p_t->Foliage));
 Crown_empty_list	(&(p_t->CrownVolume));
 p_t->next	= NULL_PTR2TREE;
 p_t->prev	= NULL_PTR2TREE;
 return;
}

void		Copy_Tree		(Tree *p_tCopy, Tree *p_tOriginal)
{
 p_tCopy->species	= p_tOriginal->species;
 p_tCopy->height	= p_tOriginal->height;
 p_tCopy->radius	= p_tOriginal->radius;
 Copy_d3Vector		(&(p_tCopy->base), &(p_tOriginal->base));
 Branch_List_Copy	(&(p_tCopy->Stem), &(p_tOriginal->Stem));
 Branch_List_Copy	(&(p_tCopy->Primary), &(p_tOriginal->Primary));
 Branch_List_Copy	(&(p_tCopy->Dry), &(p_tOriginal->Dry));
 Branch_List_Copy	(&(p_tCopy->Secondary), &(p_tOriginal->Secondary));
 Branch_List_Copy	(&(p_tCopy->Tertiary), &(p_tOriginal->Tertiary));
 Leaf_List_Copy		(&(p_tCopy->Foliage), &(p_tOriginal->Foliage));
 Crown_List_Copy	(&(p_tCopy->CrownVolume), &(p_tOriginal->CrownVolume));
 p_tCopy->next	= NULL_PTR2TREE;
 p_tCopy->prev	= NULL_PTR2TREE;
 return;
}

void		Print_Tree		(Tree *p_t)
{
 printf ("\n");
 printf ("Tree species:\t%12d\n",   p_t->species);
 printf ("Tree height: \t%12.5e\n", p_t->height);
 printf ("Tree radius: \t%12.5e\n", p_t->radius);
 printf ("Tree location: \n"); Print_d3Vector (&(p_t->base));
 printf ("Primaries:   \t%12ld\n", p_t->Primary.n);
 printf ("Secondaries: \t%12ld\n", p_t->Secondary.n);
 printf ("Tertiaries:  \t%12ld\n", p_t->Tertiary.n);
 printf ("Leaves:      \t%12ld\n", p_t->Foliage.n);
 printf ("\n");
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Tree_init_list	(Tree_List *p_tl)
{
 p_tl->head	= NULL_PTR2TREE_LIST;
 p_tl->tail	= NULL_PTR2TREE_LIST;
 p_tl->n		= 0L;
 return;
}

int			Tree_head_add	(Tree_List *p_tl, Tree *p_t)
{
 Tree	*old_head	= p_tl->head;
 Tree	*new_f		= (Tree*) calloc (1, sizeof (Tree));
 int	rtn_value	= NO_TREE_ERRORS;

 if (new_f != NULL_PTR2TREE) {
  Copy_Tree (new_f, p_t);
  if (old_head != NULL_PTR2TREE) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2TREE;
  p_tl->head	= new_f;
  if (p_tl->tail	== NULL_PTR2TREE) {
   p_tl->tail	= new_f;
  }
  p_tl->n++;
 } else {
  rtn_value	= !NO_TREE_ERRORS;
 }
 return (rtn_value);
}

void		Tree_head_print			(Tree_List *p_tl)
{
 Tree	*p_t	= p_tl->head;
 long		i;

 for (i=0; i<p_tl->n; i++) {
  Print_Tree (p_t);
  p_t	= p_t->next;
 }
 return;
}

int			Tree_tail_add			(Tree_List *p_tl, Tree *p_t)
{
 Tree	*old_tail	= p_tl->tail;
 Tree	*new_f	= (Tree*) calloc (1, sizeof (Tree));
 int		rtn_value	= NO_TREE_ERRORS;

 if (new_f != NULL_PTR2TREE) {
  Copy_Tree (new_f, p_t);
  if (old_tail != NULL_PTR2TREE) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2TREE;
  p_tl->tail	= new_f;
  if (p_tl->head	== NULL_PTR2TREE) {
   p_tl->head	= new_f;
  }
  p_tl->n++;
 } else {
  rtn_value	= !NO_TREE_ERRORS;
 }
 return (rtn_value);
}

void		Tree_tail_print			(Tree_List *p_tl)
{
 Tree	*p_t	= p_tl->tail;
 long		i;

 for (i=0; i<p_tl->n; i++) {
  Print_Tree (p_t);
  p_t	= p_t->prev;
 }
 return;
}

int			Tree_head_sub			(Tree_List *p_tl, Tree *p_t)
{
 int		rtn_value	= NO_TREE_ERRORS;
 Tree	*old_head	= p_tl->head;

 if (p_tl->head != NULL_PTR2TREE) {
  Copy_Tree (p_t, p_tl->head);
  p_tl->n--;
  if (p_tl->n	== 0L) {
   p_tl->head	=   NULL_PTR2TREE;
   p_tl->tail	=   NULL_PTR2TREE;
  } else {
   p_tl->head	= p_t->next;
   p_tl->head->prev	= NULL_PTR2TREE;
  }
  free (old_head);
  p_t->next	= NULL_PTR2TREE;
  p_t->prev	= NULL_PTR2TREE;
 } else {
  rtn_value	= !NO_TREE_ERRORS;
 }
 return (rtn_value);
}

int			Tree_tail_sub			(Tree_List *p_tl, Tree *p_t)
{
 int		rtn_value	= NO_TREE_ERRORS;
 Tree	*old_tail	= p_tl->tail;

 if (p_tl->tail != NULL_PTR2TREE) {
  Copy_Tree (p_t, p_tl->tail);
  p_tl->n--;
  if (p_tl->n	== 0L) {
   p_tl->head	=   NULL_PTR2TREE;
   p_tl->tail	=   NULL_PTR2TREE;
  } else {
   p_tl->tail	= p_t->prev;
   p_tl->tail->next	= NULL_PTR2TREE;
  }
  free (old_tail);
  p_t->prev	= NULL_PTR2TREE;
  p_t->next	= NULL_PTR2TREE;
 } else {
  rtn_value	= !NO_TREE_ERRORS;
 }
 return (rtn_value);
}

long		Tree_List_length		(Tree_List *p_tl)
{
 return (p_tl->n);
}

Tree*	Tree_List_head			(Tree_List *p_tl)
{
 return (p_tl->head);
}

Tree*	Tree_List_tail			(Tree_List *p_tl)
{
 return (p_tl->tail);
}

int			Tree_insert				(Tree_List *p_tl, Tree *p_t, long m)
{
 int		rtn_value	= NO_TREE_ERRORS;
 Tree	*new_f;
 Tree	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Tree_head_add (p_tl, p_t);
 } else {
  if (m >= p_tl->n) {
   rtn_value	= Tree_tail_add (p_tl, p_t);
  } else {
   new_f		= (Tree*) calloc (1, sizeof (Tree));
   if (new_f != NULL_PTR2TREE) {
    Copy_Tree (new_f, p_t);
    f_m		= p_tl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_tl->n++;
   } else {
    rtn_value	= !NO_TREE_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Tree_delete				(Tree_List *p_tl, Tree *p_t, long m)
{
 int		rtn_value = NO_TREE_ERRORS;
 Tree	*f_m;
 Tree	*f_mm1;
 Tree	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_tl->n) || (p_tl->n == 0L)) {
  rtn_value = !NO_TREE_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Tree_head_sub (p_tl, p_t);
  } else {
   if (m == p_tl->n) {
    rtn_value	= Tree_tail_sub (p_tl, p_t);
   } else {
    f_m		= p_tl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Tree (p_t, f_m);
	p_t->next		= NULL_PTR2TREE;
	p_t->prev		= NULL_PTR2TREE;
	free (f_m);
	p_tl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Tree_empty_list			(Tree_List *p_tl)
{
 Tree	v;

 if (p_tl->n	== 0L) {
  p_tl->head	= NULL_PTR2TREE;
  p_tl->tail	= NULL_PTR2TREE;
 } else {
  while (p_tl->n > 0L) {
   Tree_head_sub (p_tl, &v);
  }
 }
 return;
}
