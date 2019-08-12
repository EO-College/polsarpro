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
 * Module      : c3Vector.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "c3Vector.h"

void		Create_c3Vector		(c3Vector *p_c3v)
{
 int i;
 for (i=0;i<3;i++) {
  p_c3v->z[i]	= xy_complex (0.0,0.0);
 }
 p_c3v->next	= NULL_PTR2C3VECTOR;
 p_c3v->prev	= NULL_PTR2C3VECTOR;
 return;
}

void		Destroy_c3Vector	(c3Vector *p_c3v)
{
 int i;
 for (i=0;i<3;i++) {
  p_c3v->z[i]	= xy_complex (0.0,0.0);
 }
 p_c3v->next	= NULL_PTR2C3VECTOR;
 p_c3v->prev	= NULL_PTR2C3VECTOR;
 return;
}

c3Vector	Assign_c3Vector	(Complex x, Complex y, Complex z)
{
 c3Vector	c3v;
 c3v.z[0]	= x;
 c3v.z[1]	= y;
 c3v.z[2]	= z;
 c3v.next	= NULL_PTR2C3VECTOR;
 c3v.prev	= NULL_PTR2C3VECTOR;
 return (c3v);
}

void		Read_c3Vector		(FILE *pF, c3Vector *p_c3v)
{
 fread (&(p_c3v->z[0]),	sizeof (Complex), 1, pF);
 fread (&(p_c3v->z[1]),	sizeof (Complex), 1, pF);
 fread (&(p_c3v->z[2]),	sizeof (Complex), 1, pF);
 p_c3v->next	= NULL_PTR2C3VECTOR;
 p_c3v->prev	= NULL_PTR2C3VECTOR;
 return;
}

void		Write_c3Vector		(FILE *pF, c3Vector *p_c3v)
{
 fwrite (&(p_c3v->z[0]),	sizeof (Complex), 1, pF);
 fwrite (&(p_c3v->z[1]),	sizeof (Complex), 1, pF);
 fwrite (&(p_c3v->z[2]),	sizeof (Complex), 1, pF);
 return;
}

c3Vector	Zero_c3Vector		(void)
{
 c3Vector	c3v;
 Create_c3Vector (&c3v);
 return (c3v);
}

void		Copy_c3Vector				(c3Vector *p_c3vCopy, c3Vector *p_c3vOriginal)
{
 p_c3vCopy->z[0]	= p_c3vOriginal->z[0];
 p_c3vCopy->z[1]	= p_c3vOriginal->z[1];
 p_c3vCopy->z[2]	= p_c3vOriginal->z[2];
 p_c3vCopy->next	= p_c3vOriginal->next;
 p_c3vCopy->prev	= p_c3vOriginal->prev;
 return;
}

void		Print_c3Vector	(c3Vector *p_c3v)
{
 printf ("\n");
 Print_Complex (&(p_c3v->z[0]));
 Print_Complex (&(p_c3v->z[1]));
 Print_Complex (&(p_c3v->z[2]));
 printf ("\n");
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		c3Vector_init_list	(c3Vector_List *p_c3vl)
{
 p_c3vl->head	= NULL_PTR2C3VECTOR_LIST;
 p_c3vl->tail	= NULL_PTR2C3VECTOR_LIST;
 p_c3vl->n		= 0L;
 return;
}

int			c3Vector_head_add			(c3Vector_List *p_c3vl, c3Vector *p_c3v)
{
 c3Vector	*old_head	= p_c3vl->head;
 c3Vector	*new_c3v	= (c3Vector*) calloc (1, sizeof (c3Vector));
 int		rtn_value	= NO_C3VECTOR_ERRORS;

 if (new_c3v != NULL_PTR2C3VECTOR) {
  Copy_c3Vector (new_c3v, p_c3v);
  if (old_head != NULL_PTR2C3VECTOR) {
   old_head->prev	= new_c3v;
  }
  new_c3v->next	= old_head;
  new_c3v->prev	= NULL_PTR2C3VECTOR;
  p_c3vl->head	= new_c3v;
  if (p_c3vl->tail	== NULL_PTR2C3VECTOR) {
   p_c3vl->tail	= new_c3v;
  }
  p_c3vl->n++;
 } else {
  rtn_value	= !NO_C3VECTOR_ERRORS;
 }
 return (rtn_value);
}

void		c3Vector_head_print			(c3Vector_List *p_c3vl)
{
 c3Vector	*p_c3v	= p_c3vl->head;
 long		i;

 for (i=0; i<p_c3vl->n; i++) {
  Print_c3Vector (p_c3v);
  p_c3v	= p_c3v->next;
 }
 return;
}

int			c3Vector_tail_add			(c3Vector_List *p_c3vl, c3Vector *p_c3v)
{
 c3Vector	*old_tail	= p_c3vl->tail;
 c3Vector	*new_c3v	= (c3Vector*) calloc (1, sizeof (c3Vector));
 int		rtn_value	= NO_C3VECTOR_ERRORS;

 if (new_c3v != NULL_PTR2C3VECTOR) {
  Copy_c3Vector (new_c3v, p_c3v);
  if (old_tail != NULL_PTR2C3VECTOR) {
   old_tail->next	= new_c3v;
  }
  new_c3v->prev	= old_tail;
  new_c3v->next	= NULL_PTR2C3VECTOR;
  p_c3vl->tail	= new_c3v;
  if (p_c3vl->head	== NULL_PTR2C3VECTOR) {
   p_c3vl->head	= new_c3v;
  }
  p_c3vl->n++;
 } else {
  rtn_value	= !NO_C3VECTOR_ERRORS;
 }
 return (rtn_value);
}

void		c3Vector_tail_print			(c3Vector_List *p_c3vl)
{
 c3Vector	*p_c3v	= p_c3vl->tail;
 long		i;

 for (i=0; i<p_c3vl->n; i++) {
  Print_c3Vector (p_c3v);
  p_c3v	= p_c3v->prev;
 }
 return;
}

int			c3Vector_head_sub			(c3Vector_List *p_c3vl, c3Vector *p_c3v)
{
 int		rtn_value	= NO_C3VECTOR_ERRORS;
 c3Vector	*old_head	= p_c3vl->head;

 if (p_c3vl->head != NULL_PTR2C3VECTOR) {
  Copy_c3Vector (p_c3v, p_c3vl->head);
  p_c3vl->n--;
  if (p_c3vl->n	== 0L) {
   p_c3vl->head	=   NULL_PTR2C3VECTOR;
   p_c3vl->tail	=   NULL_PTR2C3VECTOR;
  } else {
   p_c3vl->head	= p_c3v->next;
   p_c3vl->head->prev	= NULL_PTR2C3VECTOR;
  }
  free (old_head);
  p_c3v->next	= NULL_PTR2C3VECTOR;
  p_c3v->prev	= NULL_PTR2C3VECTOR;
 } else {
  rtn_value	= !NO_C3VECTOR_ERRORS;
 }
 return (rtn_value);
}

int			c3Vector_tail_sub			(c3Vector_List *p_c3vl, c3Vector *p_c3v)
{
 int		rtn_value	= NO_C3VECTOR_ERRORS;
 c3Vector	*old_tail	= p_c3vl->tail;

 if (p_c3vl->tail != NULL_PTR2C3VECTOR) {
  Copy_c3Vector (p_c3v, p_c3vl->tail);
  p_c3vl->n--;
  if (p_c3vl->n	== 0L) {
   p_c3vl->head	=   NULL_PTR2C3VECTOR;
   p_c3vl->tail	=   NULL_PTR2C3VECTOR;
  } else {
   p_c3vl->tail	= p_c3v->prev;
   p_c3vl->tail->next	= NULL_PTR2C3VECTOR;
  }
  free (old_tail);
  p_c3v->prev	= NULL_PTR2C3VECTOR;
  p_c3v->next	= NULL_PTR2C3VECTOR;
 } else {
  rtn_value	= !NO_C3VECTOR_ERRORS;
 }
 return (rtn_value);
}

long		c3Vector_List_length		(c3Vector_List *p_c3vl)
{
 return (p_c3vl->n);
}

c3Vector*	c3Vector_List_head			(c3Vector_List *p_c3vl)
{
 return (p_c3vl->head);
}

c3Vector*	c3Vector_List_tail			(c3Vector_List *p_c3vl)
{
 return (p_c3vl->tail);
}

int			c3Vector_insert				(c3Vector_List *p_c3vl, c3Vector *p_c3v, long m)
{
 int		rtn_value	= NO_C3VECTOR_ERRORS;
 c3Vector	*new_c3v;
 c3Vector	*c3v_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= c3Vector_head_add (p_c3vl, p_c3v);
 } else {
  if (m >= p_c3vl->n) {
   rtn_value	= c3Vector_tail_add (p_c3vl, p_c3v);
  } else {
   new_c3v		= (c3Vector*) calloc (1, sizeof (c3Vector));
   if (new_c3v != NULL_PTR2C3VECTOR) {
    Copy_c3Vector (new_c3v, p_c3v);
    c3v_m		= p_c3vl->head;
	for (i=0L; i<m-1L; i++) {
	 c3v_m		= c3v_m->next;
	}
	new_c3v->next		= c3v_m->next;
	new_c3v->prev		= c3v_m->next->prev;
	c3v_m->next->prev	= new_c3v;
	c3v_m->next			= new_c3v;
	p_c3vl->n++;
   } else {
    rtn_value	= !NO_C3VECTOR_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			c3Vector_delete				(c3Vector_List *p_c3vl, c3Vector *p_c3v, long m)
{
 int		rtn_value = NO_C3VECTOR_ERRORS;
 c3Vector	*c3v_m;
 c3Vector	*c3v_mm1;
 c3Vector	*c3v_mp1;
 long		i;

 if ((m <=1L) || (m >p_c3vl->n) || (p_c3vl->n == 0L)) {
  rtn_value = !NO_C3VECTOR_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= c3Vector_head_sub (p_c3vl, p_c3v);
  } else {
   if (m == p_c3vl->n) {
    rtn_value	= c3Vector_tail_sub (p_c3vl, p_c3v);
   } else {
    c3v_m		= p_c3vl->head;
	for (i=0L; i<m-1L; i++) {
	 c3v_m		= c3v_m->next;
	}
    c3v_mm1			= c3v_m->prev;
	c3v_mp1			= c3v_m->next;
    c3v_mp1->prev	= c3v_mm1;
	c3v_mm1->next	= c3v_mp1;
	Copy_c3Vector (p_c3v, c3v_m);
	p_c3v->next		= NULL_PTR2C3VECTOR;
	p_c3v->prev		= NULL_PTR2C3VECTOR;
	free (c3v_m);
	p_c3vl->n--;
   }
  }
 }
 return (rtn_value);
}

void		c3Vector_empty_list			(c3Vector_List *p_c3vl)
{
 c3Vector	v;

 if (p_c3vl->n	== 0L) {
  p_c3vl->head	= NULL_PTR2C3VECTOR;
  p_c3vl->tail	= NULL_PTR2C3VECTOR;
 } else {
  while (p_c3vl->n > 0L) {
   c3Vector_head_sub (p_c3vl, &v);
  }
 }
 return;
}

/*****************/
/* Miscellaneous */
/*****************/

c3Vector	c3Vector_scalar_multiply			(c3Vector c3v, Complex z)
{
 int i;
 for (i=0;i<3;i++) {
  c3v.z[i]	= complex_mul (c3v.z[i], z);
 }
 c3v.next	= NULL_PTR2C3VECTOR;
 c3v.prev	= NULL_PTR2C3VECTOR;
 return (c3v);
}

c3Vector	c3Vector_scalar_divide				(c3Vector c3v, Complex z)
{
 int i;
 for (i=0;i<3;i++) {
  c3v.z[i]	= complex_div (c3v.z[i], z);
 }
 c3v.next	= NULL_PTR2C3VECTOR;
 c3v.prev	= NULL_PTR2C3VECTOR;
 return (c3v);
}

Complex		c3Vector_scalar_product				(c3Vector c3v1, c3Vector c3v2)
{
 int		i;
 Complex	z = xy_complex (0.0, 0.0);
 for (i=0;i<3;i++) {
  z	= complex_add (z, complex_mul (c3v1.z[i], c3v2.z[i]));
 }
 return (z);
}

c3Vector	c3Vector_normalise					(c3Vector c3v)
{
 int		i;
 Complex	z = xy_complex (0.0, 0.0);
 for (i=0;i<3;i++) {
  z	= complex_add (z, complex_mul (c3v.z[i], c3v.z[i]));
 }
 if (z.r > FLT_EPSILON) {
  for (i=0; i<3; i++) {
   c3v.z[i]	= complex_div (c3v.z[i], z);
  }
 } else {
#ifndef		C3VECTOR_SUPPRESS_ERROR_MESSAGES
  printf ("ERROR: c3Vector_normalise called on null vector.\n");
#endif
 }
 c3v.next	= NULL_PTR2C3VECTOR;
 c3v.prev	= NULL_PTR2C3VECTOR;
 return (c3v);
}

c3Vector	c3Vector_difference					(c3Vector c3v1, c3Vector c3v2)
{
 int		i;
 c3Vector	d;
 for (i=0; i<3; i++) {
  d.z[i]	= complex_sub (c3v1.z[i], c3v2.z[i]);
 }
 d.next	= NULL_PTR2C3VECTOR;
 d.prev	= NULL_PTR2C3VECTOR;
 return (d);
}

c3Vector	c3Vector_cross_product				(c3Vector c3v1, c3Vector c3v2)
{
 c3Vector	c3x;
 c3x.z[0] = complex_sub(complex_mul(c3v1.z[1],c3v2.z[2]),complex_mul(c3v1.z[2],c3v2.z[1]));
 c3x.z[1] = complex_sub(complex_mul(c3v1.z[2],c3v2.z[0]),complex_mul(c3v1.z[0],c3v2.z[2]));
 c3x.z[2] = complex_sub(complex_mul(c3v1.z[0],c3v2.z[1]),complex_mul(c3v1.z[1],c3v2.z[0]));
 c3x.next	= NULL_PTR2C3VECTOR;
 c3x.prev	= NULL_PTR2C3VECTOR;
 return (c3x);
}

c3Vector	c3Vector_sum					(c3Vector c3v1, c3Vector c3v2)
{
 int		i;
 c3Vector	s;
 for (i=0; i<3; i++) {
  s.z[i]	= complex_add (c3v1.z[i], c3v2.z[i]);
 }
 s.next	= NULL_PTR2C3VECTOR;
 s.prev	= NULL_PTR2C3VECTOR;
 return (s);
}
