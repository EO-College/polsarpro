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
 * Module      : Branch.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Branch.h"

/**********************************/
/* Branch function implementations */
/**********************************/

void		Create_Branch	(Branch *p_b)
{
 p_b->l				= 0.0;
 p_b->start_radius	= 0.0;
 p_b->end_radius	= 0.0;
 p_b->dp			= 0.0;
 p_b->dp_coeff		= 0.0;
 p_b->gamma			= 0.0;
 p_b->lamdacx		= 0.0;
 p_b->lamdacy		= 0.0;
 p_b->phicx			= 0.0;
 p_b->phicy			= 0.0;
 p_b->phix			= 0.0;
 p_b->phiy			= 0.0;
 p_b->moisture		= 0.0;
 p_b->permittivity	= xy_complex (1.0, 0.0);
 p_b->b0			= Zero_d3Vector ();
 p_b->z0			= Zero_d3Vector ();
 p_b->p				= Zero_d3Vector ();
 p_b->id			= 0;
 p_b->idorg			= 0;
 p_b->next			= NULL_PTR2BRANCH;
 p_b->prev			= NULL_PTR2BRANCH;
 return;
}

void		Destroy_Branch	(Branch *p_b)
{
 p_b->l				= 0.0;
 p_b->start_radius	= 0.0;
 p_b->end_radius	= 0.0;
 p_b->dp			= 0.0;
 p_b->dp_coeff		= 0.0;
 p_b->gamma			= 0.0;
 p_b->lamdacx		= 0.0;
 p_b->lamdacy		= 0.0;
 p_b->phicx			= 0.0;
 p_b->phicy			= 0.0;
 p_b->phix			= 0.0;
 p_b->phiy			= 0.0;
 p_b->moisture		= 0.0;
 p_b->permittivity	= xy_complex (1.0, 0.0);
 p_b->b0			= Zero_d3Vector ();
 p_b->z0			= Zero_d3Vector ();
 p_b->p				= Zero_d3Vector ();
 p_b->id			= 0;
 p_b->idorg			= 0;
 p_b->next			= NULL_PTR2BRANCH;
 p_b->prev			= NULL_PTR2BRANCH;
 return;
}

void		Copy_Branch		(Branch *p_bCopy, Branch *p_bOriginal)
{
 p_bCopy->l				= p_bOriginal->l;
 p_bCopy->start_radius	= p_bOriginal->start_radius;
 p_bCopy->end_radius	= p_bOriginal->end_radius;
 p_bCopy->dp			= p_bOriginal->dp;
 p_bCopy->dp_coeff		= p_bOriginal->dp_coeff;
 p_bCopy->gamma			= p_bOriginal->gamma;
 p_bCopy->lamdacx		= p_bOriginal->lamdacx;
 p_bCopy->lamdacy		= p_bOriginal->lamdacy;
 p_bCopy->phicx			= p_bOriginal->phicx;
 p_bCopy->phicy			= p_bOriginal->phicy;
 p_bCopy->phix			= p_bOriginal->phix;
 p_bCopy->phiy			= p_bOriginal->phiy;
 p_bCopy->moisture		= p_bOriginal->moisture;
 p_bCopy->permittivity	= Copy_Complex (&(p_bOriginal->permittivity));
 Copy_d3Vector (&(p_bCopy->b0), &(p_bOriginal->b0));
 Copy_d3Vector (&(p_bCopy->z0), &(p_bOriginal->z0));
 Copy_d3Vector (&(p_bCopy->p),  &(p_bOriginal->p) );
 p_bCopy->id			= p_bOriginal->id;
 p_bCopy->idorg			= p_bOriginal->idorg;
 p_bCopy->next			= p_bOriginal->next;
 p_bCopy->prev			= p_bOriginal->prev;
 return;
}

void		Print_Branch	(Branch *p_b)
{
 printf ("\n");
 printf ("%12.5e\n", p_b->l);
 printf ("%12.5e\n", p_b->start_radius);
 printf ("%12.5e\n", p_b->end_radius);
 printf ("%12.5e\n", p_b->dp);
 printf ("%12.5e\n", p_b->dp_coeff);
 printf ("%12.5e\n", p_b->gamma);
 printf ("%12.5e\n", p_b->lamdacx);
 printf ("%12.5e\n", p_b->lamdacy);
 printf ("%12.5e\n", p_b->moisture);
 Print_Complex (&(p_b->permittivity));
 printf ("%12.5e\n", p_b->phicx);
 printf ("%12.5e\n", p_b->phicy);
 printf ("%12.5e\n", p_b->phix);
 printf ("%12.5e\n", p_b->phiy);
 Print_d3Vector (&(p_b->b0));
 Print_d3Vector (&(p_b->z0));
 Print_d3Vector (&(p_b->p));
 printf ("%12d\n", p_b->id);
 printf ("%12d\n", p_b->idorg);
 //printf ("%ld\n", (long) p_b->next);
 //printf ("%ld\n", (long) p_b->prev);
 printf ("\n");
 return;
}

void		Assign_Branch	(Branch *p_b, double sr, double er, d3Vector b0, d3Vector z0, d3Vector p,
							 double dp, double phix, double phiy, double phicx, double phicy,
							 double lamdacx, double lamdacy, double gamma, double moisture,
							 double l, Complex permittivity, int id, int idorg)
{
 p_b->l				= l;
 p_b->start_radius	= sr;
 p_b->end_radius	= er;
 p_b->dp			= dp;
 p_b->dp_coeff		= dp/(2.0*sqrt(1.0-dp*dp));
 p_b->gamma			= gamma;
 p_b->lamdacx		= lamdacx;
 p_b->lamdacy		= lamdacy;
 p_b->phicx			= phicx;
 p_b->phicy			= phicy;
 p_b->phix			= phix;
 p_b->phiy			= phiy;
 p_b->moisture		= moisture;
 p_b->permittivity	= Copy_Complex (&permittivity);
 Copy_d3Vector (&(p_b->b0), &b0);
 Copy_d3Vector (&(p_b->z0), &z0);
 Copy_d3Vector (&(p_b->p), &p);
 p_b->id			= id;
 p_b->idorg			= idorg;
 p_b->next			= NULL_PTR2BRANCH;
 p_b->prev			= NULL_PTR2BRANCH;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Branch_init_list	(Branch_List *p_bl)
{
 p_bl->head	= NULL_PTR2BRANCH_LIST;
 p_bl->tail	= NULL_PTR2BRANCH_LIST;
 p_bl->n		= 0L;
 return;
}

int			Branch_head_add	(Branch_List *p_bl, Branch *p_b)
{
 Branch	*old_head	= p_bl->head;
 Branch	*new_f		= (Branch*) calloc (1, sizeof (Branch));
 int	rtn_value	= NO_BRANCH_ERRORS;

 if (new_f != NULL_PTR2BRANCH) {
  Copy_Branch (new_f, p_b);
  if (old_head != NULL_PTR2BRANCH) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2BRANCH;
  p_bl->head	= new_f;
  if (p_bl->tail	== NULL_PTR2BRANCH) {
   p_bl->tail	= new_f;
  }
  p_bl->n++;
 } else {
  rtn_value	= !NO_BRANCH_ERRORS;
 }
 return (rtn_value);
}

void		Branch_head_print			(Branch_List *p_bl)
{
 Branch	*p_b	= p_bl->head;
 long		i;

 for (i=0; i<p_bl->n; i++) {
  Print_Branch (p_b);
  p_b	= p_b->next;
 }
 return;
}

int			Branch_tail_add			(Branch_List *p_bl, Branch *p_b)
{
 Branch	*old_tail	= p_bl->tail;
 Branch	*new_f	= (Branch*) calloc (1, sizeof (Branch));
 int		rtn_value	= NO_BRANCH_ERRORS;

 if (new_f != NULL_PTR2BRANCH) {
  Copy_Branch (new_f, p_b);
  if (old_tail != NULL_PTR2BRANCH) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2BRANCH;
  p_bl->tail	= new_f;
  if (p_bl->head	== NULL_PTR2BRANCH) {
   p_bl->head	= new_f;
  }
  p_bl->n++;
 } else {
  rtn_value	= !NO_BRANCH_ERRORS;
 }
 return (rtn_value);
}

void		Branch_tail_print			(Branch_List *p_bl)
{
 Branch	*p_b	= p_bl->tail;
 long		i;

 for (i=0; i<p_bl->n; i++) {
  Print_Branch (p_b);
  p_b	= p_b->prev;
 }
 return;
}

int			Branch_head_sub			(Branch_List *p_bl, Branch *p_b)
{
 int		rtn_value	= NO_BRANCH_ERRORS;
 Branch	*old_head	= p_bl->head;

 if (p_bl->head != NULL_PTR2BRANCH) {
  Copy_Branch (p_b, p_bl->head);
  p_bl->n--;
  if (p_bl->n	== 0L) {
   p_bl->head	=   NULL_PTR2BRANCH;
   p_bl->tail	=   NULL_PTR2BRANCH;
  } else {
   p_bl->head	= p_b->next;
   p_bl->head->prev	= NULL_PTR2BRANCH;
  }
  free (old_head);
  p_b->next	= NULL_PTR2BRANCH;
  p_b->prev	= NULL_PTR2BRANCH;
 } else {
  rtn_value	= !NO_BRANCH_ERRORS;
 }
 return (rtn_value);
}

int			Branch_tail_sub			(Branch_List *p_bl, Branch *p_b)
{
 int		rtn_value	= NO_BRANCH_ERRORS;
 Branch	*old_tail	= p_bl->tail;

 if (p_bl->tail != NULL_PTR2BRANCH) {
  Copy_Branch (p_b, p_bl->tail);
  p_bl->n--;
  if (p_bl->n	== 0L) {
   p_bl->head	=   NULL_PTR2BRANCH;
   p_bl->tail	=   NULL_PTR2BRANCH;
  } else {
   p_bl->tail	= p_b->prev;
   p_bl->tail->next	= NULL_PTR2BRANCH;
  }
  free (old_tail);
  p_b->prev	= NULL_PTR2BRANCH;
  p_b->next	= NULL_PTR2BRANCH;
 } else {
  rtn_value	= !NO_BRANCH_ERRORS;
 }
 return (rtn_value);
}

long		Branch_List_length		(Branch_List *p_bl)
{
 return (p_bl->n);
}

Branch*	Branch_List_head			(Branch_List *p_bl)
{
 return (p_bl->head);
}

Branch*	Branch_List_tail			(Branch_List *p_bl)
{
 return (p_bl->tail);
}

int			Branch_insert				(Branch_List *p_bl, Branch *p_b, long m)
{
 int		rtn_value	= NO_BRANCH_ERRORS;
 Branch	*new_f;
 Branch	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Branch_head_add (p_bl, p_b);
 } else {
  if (m >= p_bl->n) {
   rtn_value	= Branch_tail_add (p_bl, p_b);
  } else {
   new_f		= (Branch*) calloc (1, sizeof (Branch));
   if (new_f != NULL_PTR2BRANCH) {
    Copy_Branch (new_f, p_b);
    f_m		= p_bl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	p_bl->n++;
   } else {
    rtn_value	= !NO_BRANCH_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Branch_delete				(Branch_List *p_bl, Branch *p_b, long m)
{
 int		rtn_value = NO_BRANCH_ERRORS;
 Branch	*f_m;
 Branch	*f_mm1;
 Branch	*f_mp1;
 long		i;

 if ((m <=1L) || (m >p_bl->n) || (p_bl->n == 0L)) {
  rtn_value = !NO_BRANCH_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Branch_head_sub (p_bl, p_b);
  } else {
   if (m == p_bl->n) {
    rtn_value	= Branch_tail_sub (p_bl, p_b);
   } else {
    f_m		= p_bl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Branch (p_b, f_m);
	p_b->next		= NULL_PTR2BRANCH;
	p_b->prev		= NULL_PTR2BRANCH;
	free (f_m);
	p_bl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Branch_empty_list			(Branch_List *p_bl)
{
 Branch	v;

 if (p_bl->n	== 0L) {
  p_bl->head	= NULL_PTR2BRANCH;
  p_bl->tail	= NULL_PTR2BRANCH;
 } else {
  while (p_bl->n > 0L) {
   Branch_head_sub (p_bl, &v);
  }
 }
 return;
}

/***************************/
/* Other branch prototypes */
/***************************/

int	Branch_Directions	(Branch *pB, double t, d3Vector *pX, d3Vector *pY, d3Vector *pZ)
{
 int	rtn_value	= NO_BRANCH_ERRORS;
 double	a			= sqrt(1.0-pB->dp*pB->dp);
 double	b			= pB->dp*t;
 d3Vector			zg	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);

 *pZ				= d3Vector_double_multiply (pB->z0, a);
 *pZ				= d3Vector_sum (*pZ, d3Vector_double_multiply (pB->p, b));
 d3Vector_insitu_normalise (pZ);
 if (fabs(1.0-fabs(d3Vector_scalar_product (*pZ, zg))) < BRANCH_DIRECTION_ROUNDING_LIMIT) {
  *pX	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
  *pY	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
 } else {
  *pX	= d3Vector_cross_product (zg, *pZ);
   d3Vector_insitu_normalise (pX);
  *pY	= d3Vector_cross_product (*pX, *pZ);
 }
 return (rtn_value);
}

d3Vector	Branch_Crookedness	(Branch *pB, double t)
{
 double		a1x	= -pB->gamma*pB->lamdacx/(2.0*DPI_RAD);
 double		a2x	= ALPHA_GOLDEN*a1x;
 double		c1x	= cos(2.0*DPI_RAD*t/pB->lamdacx+pB->phix);
 double		c2x	= cos(pB->phix);
 double		c3x	= cos(2.0*DPI_RAD*ALPHA_GOLDEN*t/pB->lamdacx+pB->phicx);
 double		c4x	= cos(pB->phicx);
 double		a1y	= -pB->gamma*pB->lamdacy/(2.0*DPI_RAD);
 double		a2y	= ALPHA_GOLDEN*a1y;
 double		c1y	= cos(2.0*DPI_RAD*t/pB->lamdacy+pB->phiy);
 double		c2y	= cos(pB->phiy);
 double		c3y	= cos(2.0*DPI_RAD*ALPHA_GOLDEN*t/pB->lamdacy+pB->phicy);
 double		c4y	= cos(pB->phicy);
 double		ax	= a1x*(c1x-c2x)+a2x*(c3x-c4x);
 double		ay	= a1y*(c1y-c2y)+a2y*(c3y-c4y);
 d3Vector	xt, yt, zt;
 int		rv;
 d3Vector	c	= Zero_d3Vector ();

 rv	= Branch_Directions (pB, t, &xt, &yt, &zt);
 if (rv == NO_BRANCH_ERRORS) {
  c	= d3Vector_double_multiply (xt, ax);
  c	= d3Vector_sum (c, d3Vector_double_multiply (yt, ay));
 }
 c	= d3Vector_double_multiply (c, (1.0-t));
 return (c);
}

d3Vector	Branch_Centre		(Branch *pB, double t)
{
 d3Vector	bt;
 d3Vector	ct;

 Create_d3Vector (&bt);
 Create_d3Vector (&ct);
 ct			= Branch_Crookedness (pB, t);
 bt			= d3Vector_double_multiply (pB->z0, t);
 bt			= d3Vector_sum (bt, d3Vector_double_multiply (pB->p, pB->dp_coeff*t*t));
 bt			= d3Vector_sum (bt, ct);
 bt			= d3Vector_sum (pB->b0, d3Vector_double_multiply (bt, pB->l));
 return (bt);
}

double		Branch_Radius		(Branch *pB, double t)
{
 return (t*(pB->end_radius-pB->start_radius) + pB->start_radius);
}

/**************************************/
/* Proper Branch_List copying routine */
/**************************************/

void		Branch_List_Copy		(Branch_List *pBL_Copy, Branch_List *pBL_Org)
{
 Branch		b;
 long		i_branch;
 Branch_empty_list (pBL_Copy);
 for (i_branch = 0L; i_branch < pBL_Org->n; i_branch++) {
  Branch_head_sub (pBL_Org, &b);
  Branch_tail_add (pBL_Org, &b);
  Branch_tail_add (pBL_Copy, &b);
 }
 return;
}
