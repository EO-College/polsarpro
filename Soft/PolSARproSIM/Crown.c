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
 * Module      : Crown.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Crown.h"

/**********************************/
/* Crown function implementations */
/**********************************/

void		Create_Crown	(Crown *p_cwn)
{
 p_cwn->axis	= Zero_d3Vector ();
 p_cwn->base	= Zero_d3Vector ();
 p_cwn->beta	= 0.0;
 p_cwn->d1		= 0.0;
 p_cwn->d2		= 0.0;
 p_cwn->d3		= 0.0;
 p_cwn->volume	= 0.0;
 p_cwn->shape	= CROWN_NULL_SHAPE;
 p_cwn->x		= Zero_d3Vector ();
 p_cwn->y		= Zero_d3Vector ();
 p_cwn->sx		= 0.0;
 p_cwn->sy		= 0.0;
 p_cwn->next	= NULL_PTR2CROWN;
 p_cwn->prev	= NULL_PTR2CROWN;
 return;
}

void		Destroy_Crown	(Crown *p_cwn)
{
 p_cwn->axis	= Zero_d3Vector ();
 p_cwn->base	= Zero_d3Vector ();
 p_cwn->beta	= 0.0;
 p_cwn->d1		= 0.0;
 p_cwn->d2		= 0.0;
 p_cwn->d3		= 0.0;
 p_cwn->volume	= 0.0;
 p_cwn->shape	= CROWN_NULL_SHAPE;
 p_cwn->x		= Zero_d3Vector ();
 p_cwn->y		= Zero_d3Vector ();
 p_cwn->sx		= 0.0;
 p_cwn->sy		= 0.0;
 p_cwn->next	= NULL_PTR2CROWN;
 p_cwn->prev	= NULL_PTR2CROWN;
 return;
}

void		Copy_Crown		(Crown *p_cwnCopy, Crown *p_cwnOriginal)
{
 Copy_d3Vector (&(p_cwnCopy->axis), &(p_cwnOriginal->axis));
 Copy_d3Vector (&(p_cwnCopy->base), &(p_cwnOriginal->base));
 Copy_d3Vector (&(p_cwnCopy->x), &(p_cwnOriginal->x));
 Copy_d3Vector (&(p_cwnCopy->y), &(p_cwnOriginal->y));
 p_cwnCopy->beta		= p_cwnOriginal->beta;
 p_cwnCopy->d1			= p_cwnOriginal->d1;
 p_cwnCopy->d2			= p_cwnOriginal->d2;
 p_cwnCopy->d3			= p_cwnOriginal->d3;
 p_cwnCopy->volume		= p_cwnOriginal->volume;
 p_cwnCopy->shape		= p_cwnOriginal->shape;
 p_cwnCopy->sx			= p_cwnOriginal->sx;
 p_cwnCopy->sy			= p_cwnOriginal->sy;
 p_cwnCopy->next		= p_cwnOriginal->next;
 p_cwnCopy->prev		= p_cwnOriginal->prev;
 return;
}

void		Print_Crown		(Crown *p_cwn)
{
 printf ("\n");
 Print_d3Vector (&(p_cwn->base));
 Print_d3Vector (&(p_cwn->axis));
 Print_d3Vector (&(p_cwn->x));
 Print_d3Vector (&(p_cwn->y));
 printf ("%12.5e\n", p_cwn->beta);
 printf ("%12.5e\n", p_cwn->d1);
 printf ("%12.5e\n", p_cwn->d2);
 printf ("%12.5e\n", p_cwn->d3);
 printf ("%12.5e\n", p_cwn->volume);
 printf ("%12d\n", p_cwn->shape);
 printf ("%12.5e\n", p_cwn->sx);
 printf ("%12.5e\n", p_cwn->sy);
 printf ("\n");
 return;
}

void		Assign_Crown	(Crown *p_cwn, int shape, double beta, double d1, double d2, double d3,
							 d3Vector base, d3Vector axis, double sx, double sy)
{
 double				cos_theta, sin_theta;
 double				cos_phi, sin_phi;

 Copy_d3Vector(&(p_cwn->axis), &axis);
 d3Vector_insitu_normalise (&(p_cwn->axis));
 p_cwn->x			= Zero_d3Vector ();
 p_cwn->y			= Zero_d3Vector ();
 cos_theta			= p_cwn->axis.x[2];
 sin_theta			= sqrt(1.0-cos_theta*cos_theta);
 if (sin_theta > FLT_EPSILON) {
  cos_phi			= p_cwn->axis.x[0]/sin_theta;
  sin_phi			= p_cwn->axis.x[1]/sin_theta;
 } else {
  cos_phi			= 1.0;
  sin_phi			= 0.0;
 }
 p_cwn->x		= Cartesian_Assign_d3Vector (cos_theta*cos_phi, cos_theta*sin_phi, -sin_theta);
 p_cwn->y		= Cartesian_Assign_d3Vector (-sin_phi, cos_phi, 0.0);
 Copy_d3Vector(&(p_cwn->base), &base);
 p_cwn->shape	= shape;
 p_cwn->d1		= d1;
 p_cwn->d2		= d2;
 p_cwn->d3		= d3;
 switch (shape) {
  case CROWN_CYLINDER:	p_cwn->volume	= DPI_RAD*d2*d2*d3;		break;
  case CROWN_CONE:		p_cwn->volume	= DPI_RAD*d2*d2*d3/3.0; break;
  case CROWN_SPHEROID:	p_cwn->volume	= DPI_RAD*d2*d2*((2.0*d1/3.0) + (d3-d1) + (d1-d3)*(d1-d3)*(d1-d3)/(3.0*d1*d1)); break;
  default:				p_cwn->volume	= 0.0; break;
 }
 p_cwn->beta	= beta;
 p_cwn->sx		= sx;
 p_cwn->sy		= sy;
 p_cwn->next	= NULL_PTR2CROWN;
 p_cwn->prev	= NULL_PTR2CROWN;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Crown_init_list	(Crown_List *p_cwnl)
{
 p_cwnl->head	= NULL_PTR2CROWN_LIST;
 p_cwnl->tail	= NULL_PTR2CROWN_LIST;
 p_cwnl->n		= 0L;
 return;
}

int			Crown_head_add	(Crown_List *p_cwnl, Crown *p_cwn)
{
 Crown	*old_head	= p_cwnl->head;
 Crown	*new_f		= (Crown*) calloc (1, sizeof (Crown));
 int	rtn_value	= NO_CROWN_ERRORS;

 if (new_f != NULL_PTR2CROWN) {
  Copy_Crown (new_f, p_cwn);
  if (old_head != NULL_PTR2CROWN) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2CROWN;
  p_cwnl->head	= new_f;
  if (p_cwnl->tail	== NULL_PTR2CROWN) {
   p_cwnl->tail	= new_f;
  }
  p_cwnl->n++;
 } else {
  rtn_value	= !NO_CROWN_ERRORS;
 }
 return (rtn_value);
}

void		Crown_head_print			(Crown_List *p_cwnl)
{
 Crown	*p_cwn	= p_cwnl->head;
 long		i;

 for (i=0; i<p_cwnl->n; i++) {
  Print_Crown (p_cwn);
  p_cwn	= p_cwn->next;
 }
 return;
}

int			Crown_tail_add			(Crown_List *p_cwnl, Crown *p_cwn)
{
 Crown	*old_tail	= p_cwnl->tail;
 Crown	*new_f	= (Crown*) calloc (1, sizeof (Crown));
 int		rtn_value	= NO_CROWN_ERRORS;

 if (new_f != NULL_PTR2CROWN) {
  Copy_Crown (new_f, p_cwn);
  if (old_tail != NULL_PTR2CROWN) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2CROWN;
  p_cwnl->tail	= new_f;
  if (p_cwnl->head	== NULL_PTR2CROWN) {
   p_cwnl->head	= new_f;
  }
  p_cwnl->n++;
 } else {
  rtn_value	= !NO_CROWN_ERRORS;
 }
 return (rtn_value);
}

void		Crown_tail_print			(Crown_List *p_cwnl)
{
 Crown	*p_cwn	= p_cwnl->tail;
 long		i;

 for (i=0; i<p_cwnl->n; i++) {
  Print_Crown (p_cwn);
  p_cwn	= p_cwn->prev;
 }
 return;
}

int			Crown_head_sub			(Crown_List *p_cwnl, Crown *p_cwn)
{
 int		rtn_value	= NO_CROWN_ERRORS;
 Crown	*old_head	= p_cwnl->head;

 if (p_cwnl->head != NULL_PTR2CROWN) {
  Copy_Crown (p_cwn, p_cwnl->head);
  p_cwnl->n--;
  if (p_cwnl->n	== 0L) {
   p_cwnl->head	=   NULL_PTR2CROWN;
   p_cwnl->tail	=   NULL_PTR2CROWN;
  } else {
   p_cwnl->head	= p_cwn->next;
   p_cwnl->head->prev	= NULL_PTR2CROWN;
  }
  free (old_head);
  p_cwn->next	= NULL_PTR2CROWN;
  p_cwn->prev	= NULL_PTR2CROWN;
 } else {
  rtn_value	= !NO_CROWN_ERRORS;
 }
 return (rtn_value);
}

int			Crown_tail_sub			(Crown_List *p_cwnl, Crown *p_cwn)
{
 int		rtn_value	= NO_CROWN_ERRORS;
 Crown	*old_tail	= p_cwnl->tail;

 if (p_cwnl->tail != NULL_PTR2CROWN) {
  Copy_Crown (p_cwn, p_cwnl->tail);
  p_cwnl->n--;
  if (p_cwnl->n	== 0L) {
   p_cwnl->head	=   NULL_PTR2CROWN;
   p_cwnl->tail	=   NULL_PTR2CROWN;
  } else {
   p_cwnl->tail	= p_cwn->prev;
   p_cwnl->tail->next	= NULL_PTR2CROWN;
  }
  free (old_tail);
  p_cwn->prev	= NULL_PTR2CROWN;
  p_cwn->next	= NULL_PTR2CROWN;
 } else {
  rtn_value	= !NO_CROWN_ERRORS;
 }
 return (rtn_value);
}

long		Crown_List_length		(Crown_List *p_cwnl)
{
 return (p_cwnl->n);
}

Crown*	Crown_List_head			(Crown_List *p_cwnl)
{
 return (p_cwnl->head);
}

Crown*	Crown_List_tail			(Crown_List *p_cwnl)
{
 return (p_cwnl->tail);
}

int			Crown_insert				(Crown_List *p_cwnl, Crown *p_cwn, long m)
{
 int		rtn_value	= NO_CROWN_ERRORS;
 Crown	*new_f;
 Crown	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Crown_head_add (p_cwnl, p_cwn);
 } else {
  if (m >= p_cwnl->n) {
   rtn_value	= Crown_tail_add (p_cwnl, p_cwn);
  } else {
   new_f		= (Crown*) calloc (1, sizeof (Crown));
   if (new_f != NULL_PTR2CROWN) {
    Copy_Crown (new_f, p_cwn);
    f_m		= p_cwnl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_cwnl->n++;
   } else {
    rtn_value	= !NO_CROWN_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Crown_delete				(Crown_List *p_cwnl, Crown *p_cwn, long m)
{
 int		rtn_value = NO_CROWN_ERRORS;
 Crown	*f_m;
 Crown	*f_mm1;
 Crown	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_cwnl->n) || (p_cwnl->n == 0L)) {
  rtn_value = !NO_CROWN_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Crown_head_sub (p_cwnl, p_cwn);
  } else {
   if (m == p_cwnl->n) {
    rtn_value	= Crown_tail_sub (p_cwnl, p_cwn);
   } else {
    f_m		= p_cwnl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Crown (p_cwn, f_m);
	p_cwn->next		= NULL_PTR2CROWN;
	p_cwn->prev		= NULL_PTR2CROWN;
	free (f_m);
	p_cwnl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Crown_empty_list			(Crown_List *p_cwnl)
{
 Crown	v;

 if (p_cwnl->n	== 0L) {
  p_cwnl->head	= NULL_PTR2CROWN;
  p_cwnl->tail	= NULL_PTR2CROWN;
 } else {
  while (p_cwnl->n > 0L) {
   Crown_head_sub (p_cwnl, &v);
  }
 }
 return;
}

/**************************************/
/* Proper Crown_List copying routine */
/**************************************/

void		Crown_List_Copy		(Crown_List *pCL_Copy, Crown_List *pCL_Org)
{
 Crown		b;
 long		i_crown;
 Crown_empty_list (pCL_Copy);
 for (i_crown = 0L; i_crown < pCL_Org->n; i_crown++) {
  Crown_head_sub (pCL_Org, &b);
  Crown_tail_add (pCL_Org, &b);
  Crown_tail_add (pCL_Copy, &b);
 }
 return;
}
