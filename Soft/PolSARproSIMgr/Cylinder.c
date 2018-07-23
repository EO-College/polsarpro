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
 * Module      : Cylinder.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Cylinder.h"

/**********************************/
/* Cylinder function implementations */
/**********************************/

void		Create_Cylinder	(Cylinder *p_c)
{
 p_c->length		= 0.0;
 p_c->radius		= 0.0;
 p_c->axis			= Zero_d3Vector ();
 p_c->x				= Zero_d3Vector ();
 p_c->y				= Zero_d3Vector ();
 p_c->base			= Zero_d3Vector ();
 p_c->permittivity	= xy_complex (0.0, 0.0);
 p_c->next			= NULL_PTR2CYLINDER;
 p_c->prev			= NULL_PTR2CYLINDER;
 return;
}

void		Destroy_Cylinder	(Cylinder *p_c)
{
 p_c->length		= 0.0;
 p_c->radius		= 0.0;
 p_c->axis			= Zero_d3Vector ();
 p_c->x				= Zero_d3Vector ();
 p_c->y				= Zero_d3Vector ();
 p_c->base			= Zero_d3Vector ();
 p_c->permittivity	= xy_complex (0.0, 0.0);
 p_c->next			= NULL_PTR2CYLINDER;
 p_c->prev			= NULL_PTR2CYLINDER;
 return;
}

void		Copy_Cylinder		(Cylinder *p_cCopy, Cylinder *p_cOriginal)
{
 p_cCopy->length		= p_cOriginal->length;
 p_cCopy->radius		= p_cOriginal->radius;
 Copy_d3Vector (&(p_cCopy->axis), &(p_cOriginal->axis));
 Copy_d3Vector (&(p_cCopy->x), &(p_cOriginal->x));
 Copy_d3Vector (&(p_cCopy->y), &(p_cOriginal->y));
 Copy_d3Vector (&(p_cCopy->base), &(p_cOriginal->base));
 p_cCopy->permittivity	= Copy_Complex (&(p_cOriginal->permittivity));
 p_cCopy->next			= p_cOriginal->next;
 p_cCopy->prev			= p_cOriginal->prev;
 return;
}

void		Print_Cylinder		(Cylinder *p_c)
{
 printf ("\n");
 printf ("%12.5e\n", p_c->length);
 printf ("%12.5e\n", p_c->radius);
 Print_d3Vector (&(p_c->axis));
 Print_d3Vector (&(p_c->x));
 Print_d3Vector (&(p_c->y));
 Print_d3Vector (&(p_c->base));
 Print_Complex (&(p_c->permittivity));
 printf ("\n");
 return;
}

void		Assign_Cylinder	(Cylinder *p_c, double length, double radius, Complex permittivity, d3Vector axis,
							 d3Vector base)
{
 double				cos_theta, sin_theta;
 double				cos_phi, sin_phi;

 p_c->length		= length;
 p_c->radius		= radius;
 p_c->permittivity	= Copy_Complex (&permittivity);
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
 p_c->next		= NULL_PTR2CYLINDER;
 p_c->prev		= NULL_PTR2CYLINDER;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Cylinder_init_list	(Cylinder_List *p_cl)
{
 p_cl->head	= NULL_PTR2CYLINDER_LIST;
 p_cl->tail	= NULL_PTR2CYLINDER_LIST;
 p_cl->n	= 0L;
 return;
}

int			Cylinder_head_add	(Cylinder_List *p_cl, Cylinder *p_c)
{
 Cylinder	*old_head	= p_cl->head;
 Cylinder	*new_f		= (Cylinder*) calloc (1, sizeof (Cylinder));
 int	rtn_value	= NO_CYLINDER_ERRORS;

 if (new_f != NULL_PTR2CYLINDER) {
  Copy_Cylinder (new_f, p_c);
  if (old_head != NULL_PTR2CYLINDER) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2CYLINDER;
  p_cl->head	= new_f;
  if (p_cl->tail	== NULL_PTR2CYLINDER) {
   p_cl->tail	= new_f;
  }
  p_cl->n++;
 } else {
  rtn_value	= !NO_CYLINDER_ERRORS;
 }
 return (rtn_value);
}

void		Cylinder_head_print			(Cylinder_List *p_cl)
{
 Cylinder	*p_c	= p_cl->head;
 long		i;

 for (i=0; i<p_cl->n; i++) {
  Print_Cylinder (p_c);
  p_c	= p_c->next;
 }
 return;
}

int			Cylinder_tail_add			(Cylinder_List *p_cl, Cylinder *p_c)
{
 Cylinder	*old_tail	= p_cl->tail;
 Cylinder	*new_f	= (Cylinder*) calloc (1, sizeof (Cylinder));
 int		rtn_value	= NO_CYLINDER_ERRORS;

 if (new_f != NULL_PTR2CYLINDER) {
  Copy_Cylinder (new_f, p_c);
  if (old_tail != NULL_PTR2CYLINDER) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2CYLINDER;
  p_cl->tail	= new_f;
  if (p_cl->head	== NULL_PTR2CYLINDER) {
   p_cl->head	= new_f;
  }
  p_cl->n++;
 } else {
  rtn_value	= !NO_CYLINDER_ERRORS;
 }
 return (rtn_value);
}

void		Cylinder_tail_print			(Cylinder_List *p_cl)
{
 Cylinder	*p_c	= p_cl->tail;
 long		i;

 for (i=0; i<p_cl->n; i++) {
  Print_Cylinder (p_c);
  p_c	= p_c->prev;
 }
 return;
}

int			Cylinder_head_sub			(Cylinder_List *p_cl, Cylinder *p_c)
{
 int		rtn_value	= NO_CYLINDER_ERRORS;
 Cylinder	*old_head	= p_cl->head;

 if (p_cl->head != NULL_PTR2CYLINDER) {
  Copy_Cylinder (p_c, p_cl->head);
  p_cl->n--;
  if (p_cl->n	== 0L) {
   p_cl->head	=   NULL_PTR2CYLINDER;
   p_cl->tail	=   NULL_PTR2CYLINDER;
  } else {
   p_cl->head	= p_c->next;
   p_cl->head->prev	= NULL_PTR2CYLINDER;
  }
  free (old_head);
  p_c->next	= NULL_PTR2CYLINDER;
  p_c->prev	= NULL_PTR2CYLINDER;
 } else {
  rtn_value	= !NO_CYLINDER_ERRORS;
 }
 return (rtn_value);
}

int			Cylinder_tail_sub			(Cylinder_List *p_cl, Cylinder *p_c)
{
 int		rtn_value	= NO_CYLINDER_ERRORS;
 Cylinder	*old_tail	= p_cl->tail;

 if (p_cl->tail != NULL_PTR2CYLINDER) {
  Copy_Cylinder (p_c, p_cl->tail);
  p_cl->n--;
  if (p_cl->n	== 0L) {
   p_cl->head	=   NULL_PTR2CYLINDER;
   p_cl->tail	=   NULL_PTR2CYLINDER;
  } else {
   p_cl->tail	= p_c->prev;
   p_cl->tail->next	= NULL_PTR2CYLINDER;
  }
  free (old_tail);
  p_c->prev	= NULL_PTR2CYLINDER;
  p_c->next	= NULL_PTR2CYLINDER;
 } else {
  rtn_value	= !NO_CYLINDER_ERRORS;
 }
 return (rtn_value);
}

long		Cylinder_List_length		(Cylinder_List *p_cl)
{
 return (p_cl->n);
}

Cylinder*	Cylinder_List_head			(Cylinder_List *p_cl)
{
 return (p_cl->head);
}

Cylinder*	Cylinder_List_tail			(Cylinder_List *p_cl)
{
 return (p_cl->tail);
}

int			Cylinder_insert				(Cylinder_List *p_cl, Cylinder *p_c, long m)
{
 int		rtn_value	= NO_CYLINDER_ERRORS;
 Cylinder	*new_f;
 Cylinder	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Cylinder_head_add (p_cl, p_c);
 } else {
  if (m >= p_cl->n) {
   rtn_value	= Cylinder_tail_add (p_cl, p_c);
  } else {
   new_f		= (Cylinder*) calloc (1, sizeof (Cylinder));
   if (new_f != NULL_PTR2CYLINDER) {
    Copy_Cylinder (new_f, p_c);
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
    rtn_value	= !NO_CYLINDER_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Cylinder_delete				(Cylinder_List *p_cl, Cylinder *p_c, long m)
{
 int		rtn_value = NO_CYLINDER_ERRORS;
 Cylinder	*f_m;
 Cylinder	*f_mm1;
 Cylinder	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_cl->n) || (p_cl->n == 0L)) {
  rtn_value = !NO_CYLINDER_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Cylinder_head_sub (p_cl, p_c);
  } else {
   if (m == p_cl->n) {
    rtn_value	= Cylinder_tail_sub (p_cl, p_c);
   } else {
    f_m		= p_cl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Cylinder (p_c, f_m);
	p_c->next		= NULL_PTR2CYLINDER;
	p_c->prev		= NULL_PTR2CYLINDER;
	free (f_m);
	p_cl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Cylinder_empty_list			(Cylinder_List *p_cl)
{
 Cylinder	v;

 if (p_cl->n	== 0L) {
  p_cl->head	= NULL_PTR2CYLINDER;
  p_cl->tail	= NULL_PTR2CYLINDER;
 } else {
  while (p_cl->n > 0L) {
   Cylinder_head_sub (p_cl, &v);
  }
 }
 return;
}
