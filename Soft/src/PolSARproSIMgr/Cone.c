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
 * Module      : Cone.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Cone.h"

/**********************************/
/* Cone function implementations */
/**********************************/

void		Create_Cone	(Cone *p_c)
{
 p_c->height		= 0.0;
 p_c->radius		= 0.0;
 p_c->beta			= 0.0;
 p_c->axis			= Zero_d3Vector ();
 p_c->x				= Zero_d3Vector ();
 p_c->y				= Zero_d3Vector ();
 p_c->base			= Zero_d3Vector ();
 p_c->next			= NULL_PTR2CONE;
 p_c->prev			= NULL_PTR2CONE;
 return;
}

void		Destroy_Cone	(Cone *p_c)
{
 p_c->height		= 0.0;
 p_c->radius		= 0.0;
 p_c->beta			= 0.0;
 p_c->axis			= Zero_d3Vector ();
 p_c->x				= Zero_d3Vector ();
 p_c->y				= Zero_d3Vector ();
 p_c->base			= Zero_d3Vector ();
 p_c->next			= NULL_PTR2CONE;
 p_c->prev			= NULL_PTR2CONE;
 return;
}

void		Copy_Cone		(Cone *p_cCopy, Cone *p_cOriginal)
{
 p_cCopy->height		= p_cOriginal->height;
 p_cCopy->radius		= p_cOriginal->radius;
 p_cCopy->beta			= p_cOriginal->beta;
 Copy_d3Vector (&(p_cCopy->axis),	&(p_cOriginal->axis));
 Copy_d3Vector (&(p_cCopy->x),		&(p_cOriginal->x));
 Copy_d3Vector (&(p_cCopy->y),		&(p_cOriginal->y));
 Copy_d3Vector (&(p_cCopy->base),	&(p_cOriginal->base));
 p_cCopy->next			= p_cOriginal->next;
 p_cCopy->prev			= p_cOriginal->prev;
 return;
}

void		Print_Cone		(Cone *p_c)
{
 printf ("\n");
 printf ("%12.5e\n", p_c->height);
 printf ("%12.5e\n", p_c->radius);
 printf ("%12.5e\n", p_c->beta);
 Print_d3Vector (&(p_c->axis));
 Print_d3Vector (&(p_c->x));
 Print_d3Vector (&(p_c->y));
 Print_d3Vector (&(p_c->base));
 printf ("\n");
 return;
}

void		Assign_Cone	(Cone *p_c, double height, double radius, d3Vector axis, d3Vector base)
{
 double				cos_theta, sin_theta;
 double				cos_phi, sin_phi;

 p_c->height		= height;
 p_c->radius		= radius;
 Copy_d3Vector (&(p_c->axis), &(axis));
 d3Vector_insitu_normalise (&(p_c->axis));
 p_c->x				= Zero_d3Vector ();
 p_c->y				= Zero_d3Vector ();
 cos_theta			= p_c->axis.x[2];
 sin_theta			= sqrt(1.0-cos_theta*cos_theta);
 if (sin_theta > FLT_EPSILON) {
  cos_phi			= p_c->axis.x[0]/sin_theta;
  sin_phi			= p_c->axis.x[1]/sin_theta;
 } else {
  cos_phi			= 1.0;
  sin_phi			= 0.0;
 }
 p_c->x				= Cartesian_Assign_d3Vector (cos_theta*cos_phi, cos_theta*sin_phi, -sin_theta);
 p_c->y				= Cartesian_Assign_d3Vector (-sin_phi, cos_phi, 0.0);
 Copy_d3Vector (&(p_c->base), &(base));
 p_c->beta			= atan2 (radius, height);
 p_c->next			= NULL_PTR2CONE;
 p_c->prev			= NULL_PTR2CONE;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Cone_init_list	(Cone_List *p_cl)
{
 p_cl->head	= NULL_PTR2CONE_LIST;
 p_cl->tail	= NULL_PTR2CONE_LIST;
 p_cl->n	= 0L;
 return;
}

int			Cone_head_add	(Cone_List *p_cl, Cone *p_c)
{
 Cone	*old_head	= p_cl->head;
 Cone	*new_f		= (Cone*) calloc (1, sizeof (Cone));
 int	rtn_value	= NO_CONE_ERRORS;

 if (new_f != NULL_PTR2CONE) {
  Copy_Cone (new_f, p_c);
  if (old_head != NULL_PTR2CONE) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2CONE;
  p_cl->head	= new_f;
  if (p_cl->tail	== NULL_PTR2CONE) {
   p_cl->tail	= new_f;
  }
  p_cl->n++;
 } else {
  rtn_value	= !NO_CONE_ERRORS;
 }
 return (rtn_value);
}

void		Cone_head_print			(Cone_List *p_cl)
{
 Cone	*p_c	= p_cl->head;
 long		i;

 for (i=0; i<p_cl->n; i++) {
  Print_Cone (p_c);
  p_c	= p_c->next;
 }
 return;
}

int			Cone_tail_add			(Cone_List *p_cl, Cone *p_c)
{
 Cone	*old_tail	= p_cl->tail;
 Cone	*new_f	= (Cone*) calloc (1, sizeof (Cone));
 int		rtn_value	= NO_CONE_ERRORS;

 if (new_f != NULL_PTR2CONE) {
  Copy_Cone (new_f, p_c);
  if (old_tail != NULL_PTR2CONE) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2CONE;
  p_cl->tail	= new_f;
  if (p_cl->head	== NULL_PTR2CONE) {
   p_cl->head	= new_f;
  }
  p_cl->n++;
 } else {
  rtn_value	= !NO_CONE_ERRORS;
 }
 return (rtn_value);
}

void		Cone_tail_print			(Cone_List *p_cl)
{
 Cone	*p_c	= p_cl->tail;
 long		i;

 for (i=0; i<p_cl->n; i++) {
  Print_Cone (p_c);
  p_c	= p_c->prev;
 }
 return;
}

int			Cone_head_sub			(Cone_List *p_cl, Cone *p_c)
{
 int		rtn_value	= NO_CONE_ERRORS;
 Cone	*old_head	= p_cl->head;

 if (p_cl->head != NULL_PTR2CONE) {
  Copy_Cone (p_c, p_cl->head);
  p_cl->n--;
  if (p_cl->n	== 0L) {
   p_cl->head	=   NULL_PTR2CONE;
   p_cl->tail	=   NULL_PTR2CONE;
  } else {
   p_cl->head	= p_c->next;
   p_cl->head->prev	= NULL_PTR2CONE;
  }
  free (old_head);
  p_c->next	= NULL_PTR2CONE;
  p_c->prev	= NULL_PTR2CONE;
 } else {
  rtn_value	= !NO_CONE_ERRORS;
 }
 return (rtn_value);
}

int			Cone_tail_sub			(Cone_List *p_cl, Cone *p_c)
{
 int		rtn_value	= NO_CONE_ERRORS;
 Cone	*old_tail	= p_cl->tail;

 if (p_cl->tail != NULL_PTR2CONE) {
  Copy_Cone (p_c, p_cl->tail);
  p_cl->n--;
  if (p_cl->n	== 0L) {
   p_cl->head	=   NULL_PTR2CONE;
   p_cl->tail	=   NULL_PTR2CONE;
  } else {
   p_cl->tail	= p_c->prev;
   p_cl->tail->next	= NULL_PTR2CONE;
  }
  free (old_tail);
  p_c->prev	= NULL_PTR2CONE;
  p_c->next	= NULL_PTR2CONE;
 } else {
  rtn_value	= !NO_CONE_ERRORS;
 }
 return (rtn_value);
}

long		Cone_List_length		(Cone_List *p_cl)
{
 return (p_cl->n);
}

Cone*	Cone_List_head			(Cone_List *p_cl)
{
 return (p_cl->head);
}

Cone*	Cone_List_tail			(Cone_List *p_cl)
{
 return (p_cl->tail);
}

int			Cone_insert				(Cone_List *p_cl, Cone *p_c, long m)
{
 int		rtn_value	= NO_CONE_ERRORS;
 Cone	*new_f;
 Cone	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Cone_head_add (p_cl, p_c);
 } else {
  if (m >= p_cl->n) {
   rtn_value	= Cone_tail_add (p_cl, p_c);
  } else {
   new_f		= (Cone*) calloc (1, sizeof (Cone));
   if (new_f != NULL_PTR2CONE) {
    Copy_Cone (new_f, p_c);
    f_m		= p_cl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_cl->n++;
   } else {
    rtn_value	= !NO_CONE_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Cone_delete				(Cone_List *p_cl, Cone *p_c, long m)
{
 int		rtn_value = NO_CONE_ERRORS;
 Cone	*f_m;
 Cone	*f_mm1;
 Cone	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_cl->n) || (p_cl->n == 0L)) {
  rtn_value = !NO_CONE_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Cone_head_sub (p_cl, p_c);
  } else {
   if (m == p_cl->n) {
    rtn_value	= Cone_tail_sub (p_cl, p_c);
   } else {
    f_m		= p_cl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Cone (p_c, f_m);
	p_c->next		= NULL_PTR2CONE;
	p_c->prev		= NULL_PTR2CONE;
	free (f_m);
	p_cl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Cone_empty_list			(Cone_List *p_cl)
{
 Cone	v;

 if (p_cl->n	== 0L) {
  p_cl->head	= NULL_PTR2CONE;
  p_cl->tail	= NULL_PTR2CONE;
 } else {
  while (p_cl->n > 0L) {
   Cone_head_sub (p_cl, &v);
  }
 }
 return;
}
