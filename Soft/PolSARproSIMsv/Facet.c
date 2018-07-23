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
 * Module      : Facet.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Facet.h"

/**********************************/
/* Facet function implementations */
/**********************************/

void		Create_Facet	(Facet *p_f)
{
 int	i;

 for (i=0;i<4;i++) {
  p_f->r[i]	= Zero_d3Vector ();
 }
 p_f->n	= Zero_d3Vector ();
 p_f->next	= NULL_PTR2FACET;
 p_f->prev	= NULL_PTR2FACET;
 return;
}

void		Destroy_Facet	(Facet *p_f)
{
 int	i;

 for (i=0;i<4;i++) {
  p_f->r[i]	= Zero_d3Vector ();
 }
 p_f->n	= Zero_d3Vector ();
 p_f->next	= NULL_PTR2FACET;
 p_f->prev	= NULL_PTR2FACET;
 return;
}

void		Copy_Facet		(Facet *p_fCopy, Facet *p_fOriginal)
{
 p_fCopy->r[0]	= p_fOriginal->r[0];
 p_fCopy->r[1]	= p_fOriginal->r[1];
 p_fCopy->r[2]	= p_fOriginal->r[2];
 p_fCopy->r[3]	= p_fOriginal->r[3];
 p_fCopy->n		= p_fOriginal->n;
 p_fCopy->next	= p_fOriginal->next;
 p_fCopy->prev	= p_fOriginal->prev;
 return;
}

void		Print_Facet		(Facet *p_f)
{
 printf ("\n");
 Print_d3Vector (&(p_f->r[0]));
 Print_d3Vector (&(p_f->r[1]));
 Print_d3Vector (&(p_f->r[2]));
 Print_d3Vector (&(p_f->r[3]));
 Print_d3Vector (&(p_f->n));
 printf ("\n");
 return;
}

void		Assign_Facet	(Facet *p_f, d3Vector *p_r0, d3Vector *p_r1, d3Vector *p_r2)
{
 Copy_d3Vector(&(p_f->r[0]), p_r0);
 Copy_d3Vector(&(p_f->r[1]), p_r1);
 Copy_d3Vector(&(p_f->r[2]), p_r2);
 facet_normal (p_f);
 facet_centre (p_f);
 p_f->next	= NULL_PTR2FACET;
 p_f->prev	= NULL_PTR2FACET;
 return;
}

void		facet_normal	(Facet *p_f)
{
 d3Vector d3v1;
 d3Vector d3v2;

 d3v1	= d3Vector_difference (p_f->r[1], p_f->r[0]);
 d3v2	= d3Vector_difference (p_f->r[2], p_f->r[0]);
 p_f->n	= d3Vector_cross_product (d3v1, d3v2);
 d3Vector_insitu_normalise (&(p_f->n));
 return;
}

void		facet_centre	(Facet *p_f)
{
 p_f->r[3] = d3Vector_sum (p_f->r[1], p_f->r[0]);
 p_f->r[3] = d3Vector_sum (p_f->r[2], p_f->r[3]);
 p_f->r[3] = d3Vector_double_divide (p_f->r[3], 3.0);
 return;
}

double		facet_area		(Facet *p_f)
{
 double		a, b, c, area;
 d3Vector	r10, r21;
 r10 = d3Vector_difference (p_f->r[1], p_f->r[0]);
 r21 = d3Vector_difference (p_f->r[2], p_f->r[1]);
 a = d3Vector_scalar_product (r10, r10);
 b = d3Vector_scalar_product (r21, r21);
 c = d3Vector_scalar_product (r10, r21);
 area = sqrt ((a*b-c*c)/4.0);
 return (area);
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Facet_init_list	(Facet_List *p_fl)
{
 p_fl->head	= NULL_PTR2FACET_LIST;
 p_fl->tail	= NULL_PTR2FACET_LIST;
 p_fl->n		= 0L;
 return;
}

int			Facet_head_add	(Facet_List *p_fl, Facet *p_f)
{
 Facet	*old_head	= p_fl->head;
 Facet	*new_f		= (Facet*) calloc (1, sizeof (Facet));
 int	rtn_value	= NO_FACET_ERRORS;

 if (new_f != NULL_PTR2FACET) {
  Copy_Facet (new_f, p_f);
  if (old_head != NULL_PTR2FACET) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2FACET;
  p_fl->head	= new_f;
  if (p_fl->tail	== NULL_PTR2FACET) {
   p_fl->tail	= new_f;
  }
  p_fl->n++;
 } else {
  rtn_value	= !NO_FACET_ERRORS;
 }
 return (rtn_value);
}

void		Facet_head_print			(Facet_List *p_fl)
{
 Facet	*p_f	= p_fl->head;
 long		i;

 for (i=0; i<p_fl->n; i++) {
  Print_Facet (p_f);
  p_f	= p_f->next;
 }
 return;
}

int			Facet_tail_add			(Facet_List *p_fl, Facet *p_f)
{
 Facet	*old_tail	= p_fl->tail;
 Facet	*new_f	= (Facet*) calloc (1, sizeof (Facet));
 int		rtn_value	= NO_FACET_ERRORS;

 if (new_f != NULL_PTR2FACET) {
  Copy_Facet (new_f, p_f);
  if (old_tail != NULL_PTR2FACET) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2FACET;
  p_fl->tail	= new_f;
  if (p_fl->head	== NULL_PTR2FACET) {
   p_fl->head	= new_f;
  }
  p_fl->n++;
 } else {
  rtn_value	= !NO_FACET_ERRORS;
 }
 return (rtn_value);
}

void		Facet_tail_print			(Facet_List *p_fl)
{
 Facet	*p_f	= p_fl->tail;
 long		i;

 for (i=0; i<p_fl->n; i++) {
  Print_Facet (p_f);
  p_f	= p_f->prev;
 }
 return;
}

int			Facet_head_sub			(Facet_List *p_fl, Facet *p_f)
{
 int		rtn_value	= NO_FACET_ERRORS;
 Facet	*old_head	= p_fl->head;

 if (p_fl->head != NULL_PTR2FACET) {
  Copy_Facet (p_f, p_fl->head);
  p_fl->n--;
  if (p_fl->n	== 0L) {
   p_fl->head	=   NULL_PTR2FACET;
   p_fl->tail	=   NULL_PTR2FACET;
  } else {
   p_fl->head	= p_f->next;
   p_fl->head->prev	= NULL_PTR2FACET;
  }
  free (old_head);
  p_f->next	= NULL_PTR2FACET;
  p_f->prev	= NULL_PTR2FACET;
 } else {
  rtn_value	= !NO_FACET_ERRORS;
 }
 return (rtn_value);
}

int			Facet_tail_sub			(Facet_List *p_fl, Facet *p_f)
{
 int		rtn_value	= NO_FACET_ERRORS;
 Facet	*old_tail	= p_fl->tail;

 if (p_fl->tail != NULL_PTR2FACET) {
  Copy_Facet (p_f, p_fl->tail);
  p_fl->n--;
  if (p_fl->n	== 0L) {
   p_fl->head	=   NULL_PTR2FACET;
   p_fl->tail	=   NULL_PTR2FACET;
  } else {
   p_fl->tail	= p_f->prev;
   p_fl->tail->next	= NULL_PTR2FACET;
  }
  free (old_tail);
  p_f->prev	= NULL_PTR2FACET;
  p_f->next	= NULL_PTR2FACET;
 } else {
  rtn_value	= !NO_FACET_ERRORS;
 }
 return (rtn_value);
}

long		Facet_List_length		(Facet_List *p_fl)
{
 return (p_fl->n);
}

Facet*	Facet_List_head			(Facet_List *p_fl)
{
 return (p_fl->head);
}

Facet*	Facet_List_tail			(Facet_List *p_fl)
{
 return (p_fl->tail);
}

int			Facet_insert				(Facet_List *p_fl, Facet *p_f, long m)
{
 int		rtn_value	= NO_FACET_ERRORS;
 Facet	*new_f;
 Facet	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Facet_head_add (p_fl, p_f);
 } else {
  if (m >= p_fl->n) {
   rtn_value	= Facet_tail_add (p_fl, p_f);
  } else {
   new_f		= (Facet*) calloc (1, sizeof (Facet));
   if (new_f != NULL_PTR2FACET) {
    Copy_Facet (new_f, p_f);
    f_m		= p_fl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_fl->n++;
   } else {
    rtn_value	= !NO_FACET_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Facet_delete				(Facet_List *p_fl, Facet *p_f, long m)
{
 int		rtn_value = NO_FACET_ERRORS;
 Facet	*f_m;
 Facet	*f_mm1;
 Facet	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_fl->n) || (p_fl->n == 0L)) {
  rtn_value = !NO_FACET_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Facet_head_sub (p_fl, p_f);
  } else {
   if (m == p_fl->n) {
    rtn_value	= Facet_tail_sub (p_fl, p_f);
   } else {
    f_m		= p_fl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Facet (p_f, f_m);
	p_f->next		= NULL_PTR2FACET;
	p_f->prev		= NULL_PTR2FACET;
	free (f_m);
	p_fl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Facet_empty_list			(Facet_List *p_fl)
{
 Facet	v;

 if (p_fl->n	== 0L) {
  p_fl->head	= NULL_PTR2FACET;
  p_fl->tail	= NULL_PTR2FACET;
 } else {
  while (p_fl->n > 0L) {
   Facet_head_sub (p_fl, &v);
  }
 }
 return;
}
