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
 * Module      : d3Vector.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "d3Vector.h"

void		Create_d3Vector		(d3Vector *p_d3v)
{
 *p_d3v	= Polar_Assign_d3Vector (0.0, 0.0, 0.0);
 Cartesian_d3Vector (p_d3v);
 p_d3v->next	= NULL_PTR2D3VECTOR;
 p_d3v->prev	= NULL_PTR2D3VECTOR;
 return;
}

void		Destroy_d3Vector	(d3Vector *p_d3v)
{
 *p_d3v	= Polar_Assign_d3Vector (0.0, 0.0, 0.0);
 Cartesian_d3Vector (p_d3v);
 p_d3v->next	= NULL_PTR2D3VECTOR;
 p_d3v->prev	= NULL_PTR2D3VECTOR;
 return;
}

void		Polar_d3Vector	(d3Vector *p_d3v)
{
 int	i;
 double	sphi, cphi, rsintheta;

 p_d3v->r	= 0.0;
 for (i=0; i<3; i++) {
  p_d3v->r	+= p_d3v->x[i]*p_d3v->x[i];
 }
 p_d3v->r	= sqrt(p_d3v->r);
 p_d3v->phi	= atan2 (p_d3v->x[1], p_d3v->x[0]);
 sphi		= sin(p_d3v->phi);
 cphi		= cos(p_d3v->phi);
 if (fabs(cphi) > fabs(sphi)) {
  rsintheta	= p_d3v->x[0]/cphi;
 } else {
  rsintheta	= p_d3v->x[1]/sphi;
 }
 p_d3v->theta	= atan2 (rsintheta, p_d3v->x[2]);
 return;
}

void		Cartesian_d3Vector		(d3Vector *p_d3v)
{
 p_d3v->x[0]	= p_d3v->r*sin(p_d3v->theta)*cos(p_d3v->phi);
 p_d3v->x[1]	= p_d3v->r*sin(p_d3v->theta)*sin(p_d3v->phi);
 p_d3v->x[2]	= p_d3v->r*cos(p_d3v->theta);
 return;
}

d3Vector	Polar_Assign_d3Vector		(double r, double theta, double phi)
{
 d3Vector	d3v;

 d3v.r		= r;
 d3v.theta	= theta;
 d3v.phi	= phi;
 Cartesian_d3Vector (&d3v);
 return (d3v);
}

d3Vector	Cartesian_Assign_d3Vector	(double x, double y, double z)
{
 d3Vector	d3v;

 d3v.x[0]	= x;
 d3v.x[1]	= y;
 d3v.x[2]	= z;
 Polar_d3Vector (&d3v);
 return (d3v);
}

void		Read_d3Vector		(FILE *pF, d3Vector *p_d3v)
{
 fread (&(p_d3v->r),		sizeof (double), 1, pF);
 fread (&(p_d3v->theta),	sizeof (double), 1, pF);
 fread (&(p_d3v->phi),		sizeof (double), 1, pF);
 Cartesian_d3Vector (p_d3v);
 p_d3v->next	= NULL_PTR2D3VECTOR;
 p_d3v->prev	= NULL_PTR2D3VECTOR;
 return;
}

void		Write_d3Vector		(FILE *pF, d3Vector *p_d3v)
{
 fwrite (&(p_d3v->r),		sizeof (double), 1, pF);
 fwrite (&(p_d3v->theta),	sizeof (double), 1, pF);
 fwrite (&(p_d3v->phi),		sizeof (double), 1, pF);
 return;
}

d3Vector	Zero_d3Vector		(void)
{
 d3Vector	d3v;
 Create_d3Vector (&d3v);
 return (d3v);
}

void		d3Vector_insitu_double_multiply	(d3Vector *p_d3v, double x)
{
 p_d3v->r		*= x;
 p_d3v->x[0]	*= x;
 p_d3v->x[1]	*= x;
 p_d3v->x[2]	*= x;
 return;
}

void		d3Vector_insitu_double_divide	(d3Vector *p_d3v, double x)
{
 p_d3v->r		/= x;
 p_d3v->x[0]	/= x;
 p_d3v->x[1]	/= x;
 p_d3v->x[2]	/= x;
 return;
}

void		d3Vector_insitu_normalise		(d3Vector *p_d3v)
{
 if (fabs(p_d3v->r) < DBL_EPSILON) {
  printf ("\nERROR: d3Vector_insitu_normalise attempted on null vector.\n");
 } else {
  p_d3v->x[0]	/= p_d3v->r;
  p_d3v->x[1]	/= p_d3v->r;
  p_d3v->x[2]	/= p_d3v->r;
  p_d3v->r		 = 1.0;
 }
 return;
}

d3Vector	d3Vector_double_multiply		(d3Vector d3v, double x)
{
 d3Vector	v;
 v	= Cartesian_Assign_d3Vector (d3v.x[0]*x, d3v.x[1]*x, d3v.x[2]*x);
 return (v);
}

d3Vector	d3Vector_double_divide			(d3Vector d3v, double x)
{
 d3Vector	v;
 v	= Cartesian_Assign_d3Vector (d3v.x[0]/x, d3v.x[1]/x, d3v.x[2]/x);
 return (v);
}

d3Vector	d3Vector_normalise				(d3Vector d3v)
{
 d3Vector	n;
 if (fabs(d3v.r) < DBL_EPSILON) {
  printf ("\nERROR: d3Vector_normalise attempted on null vector.\n");
  n	= Zero_d3Vector ();
 } else {
  n.x[0]	= d3v.x[0]/d3v.r;
  n.x[1]	= d3v.x[1]/d3v.r;
  n.x[2]	= d3v.x[2]/d3v.r;
  Polar_d3Vector (&n);
 }
 return (n);
}

double		d3Vector_scalar_product			(d3Vector d3v1, d3Vector d3v2)
{
 double		sp	= 0.0;
 int		i;
 for (i=0; i<3; i++) {
  sp += d3v1.x[i]*d3v2.x[i];
 }
 return (sp);
}

d3Vector	d3Vector_difference	(d3Vector d3v1, d3Vector d3v2)
{
 d3Vector	v;
 v.x[0]		= d3v1.x[0]-d3v2.x[0];
 v.x[1]		= d3v1.x[1]-d3v2.x[1];
 v.x[2]		= d3v1.x[2]-d3v2.x[2];
 Polar_d3Vector (&v);
 return (v);
}

d3Vector	d3Vector_cross_product	(d3Vector d3v1, d3Vector d3v2)
{
 d3Vector	v;
 Create_d3Vector (&v);
 v.x[0]	= d3v1.x[1]*d3v2.x[2] - d3v1.x[2]*d3v2.x[1];
 v.x[1]	= d3v1.x[2]*d3v2.x[0] - d3v1.x[0]*d3v2.x[2];
 v.x[2]	= d3v1.x[0]*d3v2.x[1] - d3v1.x[1]*d3v2.x[0];
 Polar_d3Vector (&v);
 return (v);
}

d3Vector	d3Vector_reflect	(d3Vector d3v, d3Vector n)
{
 double		d3vdotn	= d3Vector_scalar_product (d3v, n);
 d3Vector	v;

 Create_d3Vector (&v);
 Copy_d3Vector	(&v, &n);
 d3Vector_insitu_double_multiply (&v, 2.0*d3vdotn);
 v	= d3Vector_difference (d3v, v);
 Polar_d3Vector (&v);
 return (v);
}

d3Vector	d3Vector_sum				(d3Vector d3v1, d3Vector d3v2)
{
 d3Vector	v;
 v.x[0]		= d3v1.x[0]+d3v2.x[0];
 v.x[1]		= d3v1.x[1]+d3v2.x[1];
 v.x[2]		= d3v1.x[2]+d3v2.x[2];
 Polar_d3Vector (&v);
 return (v);
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Copy_d3Vector				(d3Vector *p_d3vCopy, d3Vector *p_d3vOriginal)
{
 p_d3vCopy->x[0]	= p_d3vOriginal->x[0];
 p_d3vCopy->x[1]	= p_d3vOriginal->x[1];
 p_d3vCopy->x[2]	= p_d3vOriginal->x[2];
 p_d3vCopy->r		= p_d3vOriginal->r;
 p_d3vCopy->theta	= p_d3vOriginal->theta;
 p_d3vCopy->phi		= p_d3vOriginal->phi;
 p_d3vCopy->next	= p_d3vOriginal->next;
 p_d3vCopy->prev	= p_d3vOriginal->prev;
 return;
}

void		Print_d3Vector	(d3Vector *p_d3v)
{
 printf ("\n");
 printf ("x\t=\t%12.5e\n", p_d3v->x[0]);
 printf ("y\t=\t%12.5e\n", p_d3v->x[1]);
 printf ("z\t=\t%12.5e\n", p_d3v->x[2]);
 printf ("r\t=\t%12.5e\n", p_d3v->r);
 printf ("theta\t=\t%12.5e\n", p_d3v->theta);
 printf ("phi\t=\t%12.5e\n", p_d3v->phi);
 printf ("\n");
 return;
}

void		d3Vector_init_list	(d3Vector_List *p_d3vl)
{
 p_d3vl->head	= NULL_PTR2D3VECTOR_LIST;
 p_d3vl->tail	= NULL_PTR2D3VECTOR_LIST;
 p_d3vl->n		= 0L;
 return;
}

int			d3Vector_head_add			(d3Vector_List *p_d3vl, d3Vector *p_d3v)
{
 d3Vector	*old_head	= p_d3vl->head;
 d3Vector	*new_d3v	= (d3Vector*) calloc (1, sizeof (d3Vector));
 int		rtn_value	= NO_D3VECTOR_ERRORS;

 if (new_d3v != NULL_PTR2D3VECTOR) {
  Copy_d3Vector (new_d3v, p_d3v);
  if (old_head != NULL_PTR2D3VECTOR) {
   old_head->prev	= new_d3v;
  }
  new_d3v->next	= old_head;
  new_d3v->prev	= NULL_PTR2D3VECTOR;
  p_d3vl->head	= new_d3v;
  if (p_d3vl->tail	== NULL_PTR2D3VECTOR) {
   p_d3vl->tail	= new_d3v;
  }
  p_d3vl->n++;
 } else {
  rtn_value	= !NO_D3VECTOR_ERRORS;
 }
 return (rtn_value);
}

void		d3Vector_head_print			(d3Vector_List *p_d3vl)
{
 d3Vector	*p_d3v	= p_d3vl->head;
 long		i;

 for (i=0; i<p_d3vl->n; i++) {
  Print_d3Vector (p_d3v);
  p_d3v	= p_d3v->next;
 }
 return;
}

int			d3Vector_tail_add			(d3Vector_List *p_d3vl, d3Vector *p_d3v)
{
 d3Vector	*old_tail	= p_d3vl->tail;
 d3Vector	*new_d3v	= (d3Vector*) calloc (1, sizeof (d3Vector));
 int		rtn_value	= NO_D3VECTOR_ERRORS;

 if (new_d3v != NULL_PTR2D3VECTOR) {
  Copy_d3Vector (new_d3v, p_d3v);
  if (old_tail != NULL_PTR2D3VECTOR) {
   old_tail->next	= new_d3v;
  }
  new_d3v->prev	= old_tail;
  new_d3v->next	= NULL_PTR2D3VECTOR;
  p_d3vl->tail	= new_d3v;
  if (p_d3vl->head	== NULL_PTR2D3VECTOR) {
   p_d3vl->head	= new_d3v;
  }
  p_d3vl->n++;
 } else {
  rtn_value	= !NO_D3VECTOR_ERRORS;
 }
 return (rtn_value);
}

void		d3Vector_tail_print			(d3Vector_List *p_d3vl)
{
 d3Vector	*p_d3v	= p_d3vl->tail;
 long		i;

 for (i=0; i<p_d3vl->n; i++) {
  Print_d3Vector (p_d3v);
  p_d3v	= p_d3v->prev;
 }
 return;
}

int			d3Vector_head_sub			(d3Vector_List *p_d3vl, d3Vector *p_d3v)
{
 int		rtn_value	= NO_D3VECTOR_ERRORS;
 d3Vector	*old_head	= p_d3vl->head;

 if (p_d3vl->head != NULL_PTR2D3VECTOR) {
  Copy_d3Vector (p_d3v, p_d3vl->head);
  p_d3vl->n--;
  if (p_d3vl->n	== 0L) {
   p_d3vl->head	=   NULL_PTR2D3VECTOR;
   p_d3vl->tail	=   NULL_PTR2D3VECTOR;
  } else {
   p_d3vl->head	= p_d3v->next;
   p_d3vl->head->prev	= NULL_PTR2D3VECTOR;
  }
  free (old_head);
  p_d3v->next	= NULL_PTR2D3VECTOR;
  p_d3v->prev	= NULL_PTR2D3VECTOR;
 } else {
  rtn_value	= !NO_D3VECTOR_ERRORS;
 }
 return (rtn_value);
}

int			d3Vector_tail_sub			(d3Vector_List *p_d3vl, d3Vector *p_d3v)
{
 int		rtn_value	= NO_D3VECTOR_ERRORS;
 d3Vector	*old_tail	= p_d3vl->tail;

 if (p_d3vl->tail != NULL_PTR2D3VECTOR) {
  Copy_d3Vector (p_d3v, p_d3vl->tail);
  p_d3vl->n--;
  if (p_d3vl->n	== 0L) {
   p_d3vl->head	=   NULL_PTR2D3VECTOR;
   p_d3vl->tail	=   NULL_PTR2D3VECTOR;
  } else {
   p_d3vl->tail	= p_d3v->prev;
   p_d3vl->tail->next	= NULL_PTR2D3VECTOR;
  }
  free (old_tail);
  p_d3v->prev	= NULL_PTR2D3VECTOR;
  p_d3v->next	= NULL_PTR2D3VECTOR;
 } else {
  rtn_value	= !NO_D3VECTOR_ERRORS;
 }
 return (rtn_value);
}

long		d3Vector_List_length		(d3Vector_List *p_d3vl)
{
 return (p_d3vl->n);
}

d3Vector*	d3Vector_List_head			(d3Vector_List *p_d3vl)
{
 return (p_d3vl->head);
}

d3Vector*	d3Vector_List_tail			(d3Vector_List *p_d3vl)
{
 return (p_d3vl->tail);
}

int			d3Vector_insert				(d3Vector_List *p_d3vl, d3Vector *p_d3v, long m)
{
 int		rtn_value	= NO_D3VECTOR_ERRORS;
 d3Vector	*new_d3v;
 d3Vector	*d3v_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= d3Vector_head_add (p_d3vl, p_d3v);
 } else {
  if (m >= p_d3vl->n) {
   rtn_value	= d3Vector_tail_add (p_d3vl, p_d3v);
  } else {
   new_d3v		= (d3Vector*) calloc (1, sizeof (d3Vector));
   if (new_d3v != NULL_PTR2D3VECTOR) {
    Copy_d3Vector (new_d3v, p_d3v);
    d3v_m		= p_d3vl->head;
	for (i=0L; i<m-1L; i++) {
	 d3v_m		= d3v_m->next;
	}
	new_d3v->next		= d3v_m->next;
	new_d3v->prev		= d3v_m->next->prev;
	d3v_m->next->prev	= new_d3v;
	d3v_m->next			= new_d3v;
	p_d3vl->n++;
   } else {
    rtn_value	= !NO_D3VECTOR_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			d3Vector_delete				(d3Vector_List *p_d3vl, d3Vector *p_d3v, long m)
{
 int		rtn_value = NO_D3VECTOR_ERRORS;
 d3Vector	*d3v_m;
 d3Vector	*d3v_mm1;
 d3Vector	*d3v_mp1;
 long		i;

 if ((m <=1L) || (m >p_d3vl->n) || (p_d3vl->n == 0L)) {
  rtn_value = !NO_D3VECTOR_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= d3Vector_head_sub (p_d3vl, p_d3v);
  } else {
   if (m == p_d3vl->n) {
    rtn_value	= d3Vector_tail_sub (p_d3vl, p_d3v);
   } else {
    d3v_m		= p_d3vl->head;
	for (i=0L; i<m-1L; i++) {
	 d3v_m		= d3v_m->next;
	}
    d3v_mm1			= d3v_m->prev;
	d3v_mp1			= d3v_m->next;
    d3v_mp1->prev	= d3v_mm1;
	d3v_mm1->next	= d3v_mp1;
	Copy_d3Vector (p_d3v, d3v_m);
	p_d3v->next		= NULL_PTR2D3VECTOR;
	p_d3v->prev		= NULL_PTR2D3VECTOR;
	free (d3v_m);
	p_d3vl->n--;
   }
  }
 }
 return (rtn_value);
}

void		d3Vector_empty_list			(d3Vector_List *p_d3vl)
{
 d3Vector	v;

 if (p_d3vl->n	== 0L) {
  p_d3vl->head	= NULL_PTR2D3VECTOR;
  p_d3vl->tail	= NULL_PTR2D3VECTOR;
 } else {
  while (p_d3vl->n > 0L) {
   d3Vector_head_sub (p_d3vl, &v);
  }
 }
 return;
}
