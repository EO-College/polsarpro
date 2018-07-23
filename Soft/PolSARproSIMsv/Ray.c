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
 * Module      : Ray.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Ray.h"

/********************************/
/* Ray function implementations */
/********************************/

void		Create_Ray	(Ray *p_r)
{
 Create_d3Vector (&(p_r->s0));
 Create_d3Vector (&(p_r->a));
 p_r->theta	= 0.0;
 p_r->phi	= 0.0;
 p_r->next	= NULL_PTR2RAY;
 p_r->prev	= NULL_PTR2RAY;
 return;
}

void		Destroy_Ray	(Ray *p_r)
{
 Destroy_d3Vector (&(p_r->s0));
 Destroy_d3Vector (&(p_r->a));
 p_r->theta	= 0.0;
 p_r->phi	= 0.0;
 p_r->next	= NULL_PTR2RAY;
 p_r->prev	= NULL_PTR2RAY;
 return;
}

void		Copy_Ray		(Ray *p_rCopy, Ray *p_rOriginal)
{
 Copy_d3Vector (&(p_rCopy->s0), &(p_rOriginal->s0));
 p_rCopy->theta	= p_rOriginal->theta;
 p_rCopy->phi	= p_rOriginal->phi;
 Copy_d3Vector (&(p_rCopy->a), &(p_rOriginal->a));
 p_rCopy->next	= p_rOriginal->next;
 p_rCopy->prev	= p_rOriginal->prev;
 return;
}

void		Print_Ray		(Ray *p_r)
{
 printf ("\n");
 Print_d3Vector (&(p_r->s0));
 Print_d3Vector (&(p_r->a));
 printf ("%12.5e\n", p_r->theta);
 printf ("%12.5e\n", p_r->phi);
 printf ("\n");
 return;
}

void		Assign_Ray		(Ray *p_r, d3Vector *p_s0, double theta, double phi)
{
 Copy_d3Vector(&(p_r->s0), p_s0);
 p_r->theta	= theta;
 p_r->phi	= phi;
 p_r->a		= Cartesian_Assign_d3Vector (sin(theta)*cos(phi), sin(theta)*sin(phi),  cos(theta));
 p_r->next	= NULL_PTR2RAY;
 p_r->prev	= NULL_PTR2RAY;
 return;
}

void		Assign_Ray_d3V	(Ray *p_r, d3Vector *p_s0, d3Vector *p_a)
{
 Copy_d3Vector(&(p_r->s0), p_s0);
 Copy_d3Vector(&(p_r->a) , p_a);
 p_r->theta	= p_r->a.theta;
 p_r->phi	= p_r->a.phi;
 p_r->next	= NULL_PTR2RAY;
 p_r->prev	= NULL_PTR2RAY;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Ray_init_list	(Ray_List *p_rl)
{
 p_rl->head	= NULL_PTR2RAY_LIST;
 p_rl->tail	= NULL_PTR2RAY_LIST;
 p_rl->n	= 0L;
 return;
}

int			Ray_head_add	(Ray_List *p_rl, Ray *p_r)
{
 Ray	*old_head	= p_rl->head;
 Ray	*new_f		= (Ray*) calloc (1, sizeof (Ray));
 int	rtn_value	= NO_RAY_ERRORS;

 if (new_f != NULL_PTR2RAY) {
  Copy_Ray (new_f, p_r);
  if (old_head != NULL_PTR2RAY) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2RAY;
  p_rl->head	= new_f;
  if (p_rl->tail	== NULL_PTR2RAY) {
   p_rl->tail	= new_f;
  }
  p_rl->n++;
 } else {
  rtn_value	= !NO_RAY_ERRORS;
 }
 return (rtn_value);
}

void		Ray_head_print			(Ray_List *p_rl)
{
 Ray	*p_r	= p_rl->head;
 long		i;

 for (i=0; i<p_rl->n; i++) {
  Print_Ray (p_r);
  p_r	= p_r->next;
 }
 return;
}

int			Ray_tail_add			(Ray_List *p_rl, Ray *p_r)
{
 Ray	*old_tail	= p_rl->tail;
 Ray	*new_f	= (Ray*) calloc (1, sizeof (Ray));
 int		rtn_value	= NO_RAY_ERRORS;

 if (new_f != NULL_PTR2RAY) {
  Copy_Ray (new_f, p_r);
  if (old_tail != NULL_PTR2RAY) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2RAY;
  p_rl->tail	= new_f;
  if (p_rl->head	== NULL_PTR2RAY) {
   p_rl->head	= new_f;
  }
  p_rl->n++;
 } else {
  rtn_value	= !NO_RAY_ERRORS;
 }
 return (rtn_value);
}

void		Ray_tail_print			(Ray_List *p_rl)
{
 Ray	*p_r	= p_rl->tail;
 long		i;

 for (i=0; i<p_rl->n; i++) {
  Print_Ray (p_r);
  p_r	= p_r->prev;
 }
 return;
}

int			Ray_head_sub			(Ray_List *p_rl, Ray *p_r)
{
 int		rtn_value	= NO_RAY_ERRORS;
 Ray	*old_head	= p_rl->head;

 if (p_rl->head != NULL_PTR2RAY) {
  Copy_Ray (p_r, p_rl->head);
  p_rl->n--;
  if (p_rl->n	== 0L) {
   p_rl->head	=   NULL_PTR2RAY;
   p_rl->tail	=   NULL_PTR2RAY;
  } else {
   p_rl->head	= p_r->next;
   p_rl->head->prev	= NULL_PTR2RAY;
  }
  free (old_head);
  p_r->next	= NULL_PTR2RAY;
  p_r->prev	= NULL_PTR2RAY;
 } else {
  rtn_value	= !NO_RAY_ERRORS;
 }
 return (rtn_value);
}

int			Ray_tail_sub			(Ray_List *p_rl, Ray *p_r)
{
 int		rtn_value	= NO_RAY_ERRORS;
 Ray	*old_tail	= p_rl->tail;

 if (p_rl->tail != NULL_PTR2RAY) {
  Copy_Ray (p_r, p_rl->tail);
  p_rl->n--;
  if (p_rl->n	== 0L) {
   p_rl->head	=   NULL_PTR2RAY;
   p_rl->tail	=   NULL_PTR2RAY;
  } else {
   p_rl->tail	= p_r->prev;
   p_rl->tail->next	= NULL_PTR2RAY;
  }
  free (old_tail);
  p_r->prev	= NULL_PTR2RAY;
  p_r->next	= NULL_PTR2RAY;
 } else {
  rtn_value	= !NO_RAY_ERRORS;
 }
 return (rtn_value);
}

long		Ray_List_length		(Ray_List *p_rl)
{
 return (p_rl->n);
}

Ray*	Ray_List_head			(Ray_List *p_rl)
{
 return (p_rl->head);
}

Ray*	Ray_List_tail			(Ray_List *p_rl)
{
 return (p_rl->tail);
}

int			Ray_insert				(Ray_List *p_rl, Ray *p_r, long m)
{
 int		rtn_value	= NO_RAY_ERRORS;
 Ray	*new_f;
 Ray	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Ray_head_add (p_rl, p_r);
 } else {
  if (m >= p_rl->n) {
   rtn_value	= Ray_tail_add (p_rl, p_r);
  } else {
   new_f		= (Ray*) calloc (1, sizeof (Ray));
   if (new_f != NULL_PTR2RAY) {
    Copy_Ray (new_f, p_r);
    f_m		= p_rl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_rl->n++;
   } else {
    rtn_value	= !NO_RAY_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Ray_delete				(Ray_List *p_rl, Ray *p_r, long m)
{
 int		rtn_value = NO_RAY_ERRORS;
 Ray	*f_m;
 Ray	*f_mm1;
 Ray	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_rl->n) || (p_rl->n == 0L)) {
  rtn_value = !NO_RAY_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Ray_head_sub (p_rl, p_r);
  } else {
   if (m == p_rl->n) {
    rtn_value	= Ray_tail_sub (p_rl, p_r);
   } else {
    f_m		= p_rl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Ray (p_r, f_m);
	p_r->next		= NULL_PTR2RAY;
	p_r->prev		= NULL_PTR2RAY;
	free (f_m);
	p_rl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Ray_empty_list			(Ray_List *p_rl)
{
 Ray	v;

 if (p_rl->n	== 0L) {
  p_rl->head	= NULL_PTR2RAY;
  p_rl->tail	= NULL_PTR2RAY;
 } else {
  while (p_rl->n > 0L) {
   Ray_head_sub (p_rl, &v);
  }
 }
 return;
}
