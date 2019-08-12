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
 * Module      : Plane.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Plane.h"

/**********************************/
/* Plane function implementations */
/**********************************/

void		Create_Plane	(Plane *p_p)
{
 Create_d3Vector (&(p_p->p0));
 Create_d3Vector (&(p_p->np));
 Create_d3Vector (&(p_p->xp));
 Create_d3Vector (&(p_p->yp));
 p_p->sx	= 0.0;
 p_p->sy	= 0.0;
 p_p->next	= NULL_PTR2PLANE;
 p_p->prev	= NULL_PTR2PLANE;
 return;
}

void		Destroy_Plane	(Plane *p_p)
{
 Destroy_d3Vector (&(p_p->p0));
 Destroy_d3Vector (&(p_p->np));
 Destroy_d3Vector (&(p_p->xp));
 Destroy_d3Vector (&(p_p->yp));
 p_p->sx	= 0.0;
 p_p->sy	= 0.0;
 p_p->next	= NULL_PTR2PLANE;
 p_p->prev	= NULL_PTR2PLANE;
 return;
}

void		Copy_Plane		(Plane *p_pCopy, Plane *p_pOriginal)
{
 Copy_d3Vector (&(p_pCopy->p0), &(p_pOriginal->p0));
 p_pCopy->sx	= p_pOriginal->sx;
 p_pCopy->sy	= p_pOriginal->sy;
 Copy_d3Vector (&(p_pCopy->np), &(p_pOriginal->np));
 Copy_d3Vector (&(p_pCopy->xp), &(p_pOriginal->xp));
 Copy_d3Vector (&(p_pCopy->yp), &(p_pOriginal->yp));
 p_pCopy->next	= p_pOriginal->next;
 p_pCopy->prev	= p_pOriginal->prev;
 return;
}

void		Print_Plane		(Plane *p_p)
{
 printf ("\n");
 Print_d3Vector (&(p_p->p0));
 Print_d3Vector (&(p_p->np));
 Print_d3Vector (&(p_p->xp));
 Print_d3Vector (&(p_p->yp));
 printf ("%12.5e\n", p_p->sx);
 printf ("%12.5e\n", p_p->sy);
 printf ("\n");
 return;
}

void		Plane_Orthonormals	(Plane *p_p)
{
 double		sx			= p_p->sx;
 double		sy			= p_p->sy;
 double		alpha		= sqrt(1.0+sx*sx+sy*sy);
 double		cos_theta	= 1.0/alpha;
 double		sin_theta;
 double		phi			= atan2 (sy, sx);
 double		cos_phi		= cos(phi);
 double		sin_phi		= sin(phi);

 if (fabs(cos_phi) > fabs(sin_phi)) {
  sin_theta = -sx/(alpha*cos_phi);
 } else {
  sin_theta	= -sy/(alpha*sin_phi);
 }
 p_p->np  = Cartesian_Assign_d3Vector ( sin_theta*cos_phi, sin_theta*sin_phi,  cos_theta);
 p_p->xp  = Cartesian_Assign_d3Vector ( cos_theta*cos_phi, cos_theta*sin_phi, -sin_theta);
 p_p->yp  = Cartesian_Assign_d3Vector ( -sin_phi,           cos_phi,            0.0);
 return;
}

void		Assign_Plane		(Plane *p_p, d3Vector *p_p0, double sx, double sy)
{
 Copy_d3Vector(&(p_p->p0), p_p0);
 p_p->sx	= sx;
 p_p->sy	= sy;
 Plane_Orthonormals (p_p);
 p_p->next	= NULL_PTR2PLANE;
 p_p->prev	= NULL_PTR2PLANE;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Plane_init_list	(Plane_List *p_pl)
{
 p_pl->head	= NULL_PTR2PLANE_LIST;
 p_pl->tail	= NULL_PTR2PLANE_LIST;
 p_pl->n		= 0L;
 return;
}

int			Plane_head_add	(Plane_List *p_pl, Plane *p_p)
{
 Plane	*old_head	= p_pl->head;
 Plane	*new_f		= (Plane*) calloc (1, sizeof (Plane));
 int	rtn_value	= NO_PLANE_ERRORS;

 if (new_f != NULL_PTR2PLANE) {
  Copy_Plane (new_f, p_p);
  if (old_head != NULL_PTR2PLANE) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2PLANE;
  p_pl->head	= new_f;
  if (p_pl->tail	== NULL_PTR2PLANE) {
   p_pl->tail	= new_f;
  }
  p_pl->n++;
 } else {
  rtn_value	= !NO_PLANE_ERRORS;
 }
 return (rtn_value);
}

void		Plane_head_print			(Plane_List *p_pl)
{
 Plane	*p_p	= p_pl->head;
 long		i;

 for (i=0; i<p_pl->n; i++) {
  Print_Plane (p_p);
  p_p	= p_p->next;
 }
 return;
}

int			Plane_tail_add			(Plane_List *p_pl, Plane *p_p)
{
 Plane	*old_tail	= p_pl->tail;
 Plane	*new_f	= (Plane*) calloc (1, sizeof (Plane));
 int		rtn_value	= NO_PLANE_ERRORS;

 if (new_f != NULL_PTR2PLANE) {
  Copy_Plane (new_f, p_p);
  if (old_tail != NULL_PTR2PLANE) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2PLANE;
  p_pl->tail	= new_f;
  if (p_pl->head	== NULL_PTR2PLANE) {
   p_pl->head	= new_f;
  }
  p_pl->n++;
 } else {
  rtn_value	= !NO_PLANE_ERRORS;
 }
 return (rtn_value);
}

void		Plane_tail_print			(Plane_List *p_pl)
{
 Plane	*p_p	= p_pl->tail;
 long		i;

 for (i=0; i<p_pl->n; i++) {
  Print_Plane (p_p);
  p_p	= p_p->prev;
 }
 return;
}

int			Plane_head_sub			(Plane_List *p_pl, Plane *p_p)
{
 int		rtn_value	= NO_PLANE_ERRORS;
 Plane	*old_head	= p_pl->head;

 if (p_pl->head != NULL_PTR2PLANE) {
  Copy_Plane (p_p, p_pl->head);
  p_pl->n--;
  if (p_pl->n	== 0L) {
   p_pl->head	=   NULL_PTR2PLANE;
   p_pl->tail	=   NULL_PTR2PLANE;
  } else {
   p_pl->head	= p_p->next;
   p_pl->head->prev	= NULL_PTR2PLANE;
  }
  free (old_head);
  p_p->next	= NULL_PTR2PLANE;
  p_p->prev	= NULL_PTR2PLANE;
 } else {
  rtn_value	= !NO_PLANE_ERRORS;
 }
 return (rtn_value);
}

int			Plane_tail_sub			(Plane_List *p_pl, Plane *p_p)
{
 int		rtn_value	= NO_PLANE_ERRORS;
 Plane	*old_tail	= p_pl->tail;

 if (p_pl->tail != NULL_PTR2PLANE) {
  Copy_Plane (p_p, p_pl->tail);
  p_pl->n--;
  if (p_pl->n	== 0L) {
   p_pl->head	=   NULL_PTR2PLANE;
   p_pl->tail	=   NULL_PTR2PLANE;
  } else {
   p_pl->tail	= p_p->prev;
   p_pl->tail->next	= NULL_PTR2PLANE;
  }
  free (old_tail);
  p_p->prev	= NULL_PTR2PLANE;
  p_p->next	= NULL_PTR2PLANE;
 } else {
  rtn_value	= !NO_PLANE_ERRORS;
 }
 return (rtn_value);
}

long		Plane_List_length		(Plane_List *p_pl)
{
 return (p_pl->n);
}

Plane*	Plane_List_head			(Plane_List *p_pl)
{
 return (p_pl->head);
}

Plane*	Plane_List_tail			(Plane_List *p_pl)
{
 return (p_pl->tail);
}

int			Plane_insert				(Plane_List *p_pl, Plane *p_p, long m)
{
 int		rtn_value	= NO_PLANE_ERRORS;
 Plane	*new_f;
 Plane	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Plane_head_add (p_pl, p_p);
 } else {
  if (m >= p_pl->n) {
   rtn_value	= Plane_tail_add (p_pl, p_p);
  } else {
   new_f		= (Plane*) calloc (1, sizeof (Plane));
   if (new_f != NULL_PTR2PLANE) {
    Copy_Plane (new_f, p_p);
    f_m		= p_pl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_pl->n++;
   } else {
    rtn_value	= !NO_PLANE_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Plane_delete				(Plane_List *p_pl, Plane *p_p, long m)
{
 int		rtn_value = NO_PLANE_ERRORS;
 Plane	*f_m;
 Plane	*f_mm1;
 Plane	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_pl->n) || (p_pl->n == 0L)) {
  rtn_value = !NO_PLANE_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Plane_head_sub (p_pl, p_p);
  } else {
   if (m == p_pl->n) {
    rtn_value	= Plane_tail_sub (p_pl, p_p);
   } else {
    f_m		= p_pl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Plane (p_p, f_m);
	p_p->next		= NULL_PTR2PLANE;
	p_p->prev		= NULL_PTR2PLANE;
	free (f_m);
	p_pl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Plane_empty_list			(Plane_List *p_pl)
{
 Plane	v;

 if (p_pl->n	== 0L) {
  p_pl->head	= NULL_PTR2PLANE;
  p_pl->tail	= NULL_PTR2PLANE;
 } else {
  while (p_pl->n > 0L) {
   Plane_head_sub (p_pl, &v);
  }
 }
 return;
}
