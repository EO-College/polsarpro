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
 * Module      : Spheroid.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Spheroid.h"

/*************************************/
/* Spheroid function implementations */
/*************************************/

void		Create_Spheroid	(Spheroid *p_s)
{
 p_s->a1			= 0.0;
 p_s->a2			= 0.0;
 p_s->h				= 0.0;
 p_s->beta			= 0.0;
 p_s->axis			= Zero_d3Vector ();
 p_s->x				= Zero_d3Vector ();
 p_s->y				= Zero_d3Vector ();
 p_s->base			= Zero_d3Vector ();
 p_s->next			= NULL_PTR2SPHEROID;
 p_s->prev			= NULL_PTR2SPHEROID;
 return;
}

void		Destroy_Spheroid	(Spheroid *p_s)
{
 p_s->a1			= 0.0;
 p_s->a2			= 0.0;
 p_s->h				= 0.0;
 p_s->beta			= 0.0;
 p_s->axis			= Zero_d3Vector ();
 p_s->x				= Zero_d3Vector ();
 p_s->y				= Zero_d3Vector ();
 p_s->base			= Zero_d3Vector ();
 p_s->next			= NULL_PTR2SPHEROID;
 p_s->prev			= NULL_PTR2SPHEROID;
 return;
}

void		Copy_Spheroid		(Spheroid *p_sCopy, Spheroid *p_sOriginal)
{
 p_sCopy->a1		= p_sOriginal->a1;
 p_sCopy->a2		= p_sOriginal->a2;
 p_sCopy->h			= p_sOriginal->h;
 p_sCopy->beta		= p_sOriginal->beta;
 Copy_d3Vector (&(p_sCopy->axis),	&(p_sOriginal->axis));
 Copy_d3Vector (&(p_sCopy->x),		&(p_sOriginal->x));
 Copy_d3Vector (&(p_sCopy->y),		&(p_sOriginal->y));
 Copy_d3Vector (&(p_sCopy->base),	&(p_sOriginal->base));
 p_sCopy->next			= p_sOriginal->next;
 p_sCopy->prev			= p_sOriginal->prev;
 return;
}

void		Print_Spheroid		(Spheroid *p_s)
{
 printf ("\n");
 printf ("%12.5e\n", p_s->a1);
 printf ("%12.5e\n", p_s->a2);
 printf ("%12.5e\n", p_s->h);
 printf ("%12.5e\n", p_s->beta);
 Print_d3Vector (&(p_s->axis));
 Print_d3Vector (&(p_s->x));
 Print_d3Vector (&(p_s->y));
 Print_d3Vector (&(p_s->base));
 printf ("\n");
 return;
}

void		Assign_Spheroid		(Spheroid *p_s, double a1, double a2, double h, d3Vector axis, d3Vector base)
{
 double				cos_theta, sin_theta;
 double				cos_phi, sin_phi;

 p_s->a1			= a1;
 p_s->a2			= a2;
 p_s->beta			= atan2 (a2, a1);
 if (fabs(h) > 2.0*a1) {
  p_s->h			= 2.0*a1;
 } else {
  p_s->h			= h;
 }
 Copy_d3Vector (&(p_s->axis), &(axis));
 d3Vector_insitu_normalise (&(p_s->axis));
 p_s->x				= Zero_d3Vector ();
 p_s->y				= Zero_d3Vector ();
 cos_theta			= p_s->axis.x[2];
 sin_theta			= sqrt(1.0-cos_theta*cos_theta);
 if (sin_theta > FLT_EPSILON) {
  cos_phi			= p_s->axis.x[0]/sin_theta;
  sin_phi			= p_s->axis.x[1]/sin_theta;
 } else {
  cos_phi			= 1.0;
  sin_phi			= 0.0;
 }
 p_s->x				= Cartesian_Assign_d3Vector (cos_theta*cos_phi, cos_theta*sin_phi, -sin_theta);
 p_s->y				= Cartesian_Assign_d3Vector (-sin_phi, cos_phi, 0.0);
  Copy_d3Vector (&(p_s->base), &(base));
 p_s->next			= NULL_PTR2SPHEROID;
 p_s->prev			= NULL_PTR2SPHEROID;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Spheroid_init_list	(Spheroid_List *p_sl)
{
 p_sl->head	= NULL_PTR2SPHEROID_LIST;
 p_sl->tail	= NULL_PTR2SPHEROID_LIST;
 p_sl->n	= 0L;
 return;
}

int			Spheroid_head_add	(Spheroid_List *p_sl, Spheroid *p_s)
{
 Spheroid	*old_head	= p_sl->head;
 Spheroid	*new_f		= (Spheroid*) calloc (1, sizeof (Spheroid));
 int	rtn_value	= NO_SPHEROID_ERRORS;

 if (new_f != NULL_PTR2SPHEROID) {
  Copy_Spheroid (new_f, p_s);
  if (old_head != NULL_PTR2SPHEROID) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2SPHEROID;
  p_sl->head	= new_f;
  if (p_sl->tail	== NULL_PTR2SPHEROID) {
   p_sl->tail	= new_f;
  }
  p_sl->n++;
 } else {
  rtn_value	= !NO_SPHEROID_ERRORS;
 }
 return (rtn_value);
}

void		Spheroid_head_print			(Spheroid_List *p_sl)
{
 Spheroid	*p_s	= p_sl->head;
 long		i;

 for (i=0; i<p_sl->n; i++) {
  Print_Spheroid (p_s);
  p_s	= p_s->next;
 }
 return;
}

int			Spheroid_tail_add			(Spheroid_List *p_sl, Spheroid *p_s)
{
 Spheroid	*old_tail	= p_sl->tail;
 Spheroid	*new_f	= (Spheroid*) calloc (1, sizeof (Spheroid));
 int		rtn_value	= NO_SPHEROID_ERRORS;

 if (new_f != NULL_PTR2SPHEROID) {
  Copy_Spheroid (new_f, p_s);
  if (old_tail != NULL_PTR2SPHEROID) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2SPHEROID;
  p_sl->tail	= new_f;
  if (p_sl->head	== NULL_PTR2SPHEROID) {
   p_sl->head	= new_f;
  }
  p_sl->n++;
 } else {
  rtn_value	= !NO_SPHEROID_ERRORS;
 }
 return (rtn_value);
}

void		Spheroid_tail_print			(Spheroid_List *p_sl)
{
 Spheroid	*p_s	= p_sl->tail;
 long		i;

 for (i=0; i<p_sl->n; i++) {
  Print_Spheroid (p_s);
  p_s	= p_s->prev;
 }
 return;
}

int			Spheroid_head_sub			(Spheroid_List *p_sl, Spheroid *p_s)
{
 int		rtn_value	= NO_SPHEROID_ERRORS;
 Spheroid	*old_head	= p_sl->head;

 if (p_sl->head != NULL_PTR2SPHEROID) {
  Copy_Spheroid (p_s, p_sl->head);
  p_sl->n--;
  if (p_sl->n	== 0L) {
   p_sl->head	=   NULL_PTR2SPHEROID;
   p_sl->tail	=   NULL_PTR2SPHEROID;
  } else {
   p_sl->head	= p_s->next;
   p_sl->head->prev	= NULL_PTR2SPHEROID;
  }
  free (old_head);
  p_s->next	= NULL_PTR2SPHEROID;
  p_s->prev	= NULL_PTR2SPHEROID;
 } else {
  rtn_value	= !NO_SPHEROID_ERRORS;
 }
 return (rtn_value);
}

int			Spheroid_tail_sub			(Spheroid_List *p_sl, Spheroid *p_s)
{
 int		rtn_value	= NO_SPHEROID_ERRORS;
 Spheroid	*old_tail	= p_sl->tail;

 if (p_sl->tail != NULL_PTR2SPHEROID) {
  Copy_Spheroid (p_s, p_sl->tail);
  p_sl->n--;
  if (p_sl->n	== 0L) {
   p_sl->head	=   NULL_PTR2SPHEROID;
   p_sl->tail	=   NULL_PTR2SPHEROID;
  } else {
   p_sl->tail	= p_s->prev;
   p_sl->tail->next	= NULL_PTR2SPHEROID;
  }
  free (old_tail);
  p_s->prev	= NULL_PTR2SPHEROID;
  p_s->next	= NULL_PTR2SPHEROID;
 } else {
  rtn_value	= !NO_SPHEROID_ERRORS;
 }
 return (rtn_value);
}

long		Spheroid_List_length		(Spheroid_List *p_sl)
{
 return (p_sl->n);
}

Spheroid*	Spheroid_List_head			(Spheroid_List *p_sl)
{
 return (p_sl->head);
}

Spheroid*	Spheroid_List_tail			(Spheroid_List *p_sl)
{
 return (p_sl->tail);
}

int			Spheroid_insert				(Spheroid_List *p_sl, Spheroid *p_s, long m)
{
 int		rtn_value	= NO_SPHEROID_ERRORS;
 Spheroid	*new_f;
 Spheroid	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Spheroid_head_add (p_sl, p_s);
 } else {
  if (m >= p_sl->n) {
   rtn_value	= Spheroid_tail_add (p_sl, p_s);
  } else {
   new_f		= (Spheroid*) calloc (1, sizeof (Spheroid));
   if (new_f != NULL_PTR2SPHEROID) {
    Copy_Spheroid (new_f, p_s);
    f_m		= p_sl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_sl->n++;
   } else {
    rtn_value	= !NO_SPHEROID_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Spheroid_delete				(Spheroid_List *p_sl, Spheroid *p_s, long m)
{
 int		rtn_value = NO_SPHEROID_ERRORS;
 Spheroid	*f_m;
 Spheroid	*f_mm1;
 Spheroid	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_sl->n) || (p_sl->n == 0L)) {
  rtn_value = !NO_SPHEROID_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Spheroid_head_sub (p_sl, p_s);
  } else {
   if (m == p_sl->n) {
    rtn_value	= Spheroid_tail_sub (p_sl, p_s);
   } else {
    f_m		= p_sl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Spheroid (p_s, f_m);
	p_s->next		= NULL_PTR2SPHEROID;
	p_s->prev		= NULL_PTR2SPHEROID;
	free (f_m);
	p_sl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Spheroid_empty_list			(Spheroid_List *p_sl)
{
 Spheroid	v;

 if (p_sl->n	== 0L) {
  p_sl->head	= NULL_PTR2SPHEROID;
  p_sl->tail	= NULL_PTR2SPHEROID;
 } else {
  while (p_sl->n > 0L) {
   Spheroid_head_sub (p_sl, &v);
  }
 }
 return;
}
