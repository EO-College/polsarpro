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
 * Module      : Leaf.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Leaf.h"

/**********************************/
/* Leaf function implementations */
/**********************************/

void		Create_Leaf	(Leaf *pL)
{
 pL->species		= POLSARPROSIM_NON_LEAF;
 pL->d1				= 0.0;
 pL->d2				= 0.0;
 pL->d3				= 0.0;
 pL->theta			= 0.0;
 pL->phi			= 0.0;
 pL->moisture		= 0.0;
 pL->permittivity	= xy_complex (1.0, 0.0);
 pL->cl				= Zero_d3Vector ();
 pL->xl				= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
 pL->yl				= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
 pL->zl				= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
 pL->next			= NULL_PTR2LEAF;
 pL->prev			= NULL_PTR2LEAF;
 return;
}

void		Destroy_Leaf	(Leaf *pL)
{
 pL->species		= POLSARPROSIM_NON_LEAF;
 pL->d1				= 0.0;
 pL->d2				= 0.0;
 pL->d3				= 0.0;
 pL->theta			= 0.0;
 pL->phi			= 0.0;
 pL->moisture		= 0.0;
 pL->permittivity	= xy_complex (1.0, 0.0);
 pL->cl				= Zero_d3Vector ();
 pL->xl				= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
 pL->yl				= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
 pL->zl				= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
 pL->next			= NULL_PTR2LEAF;
 pL->prev			= NULL_PTR2LEAF;
 return;
}

void		Copy_Leaf		(Leaf *pLCopy, Leaf *pLOriginal)
{
 pLCopy->species		= pLOriginal->species;
 pLCopy->d1				= pLOriginal->d1;
 pLCopy->d2				= pLOriginal->d2;
 pLCopy->d3				= pLOriginal->d3;
 pLCopy->theta			= pLOriginal->theta;
 pLCopy->phi			= pLOriginal->phi;
 pLCopy->moisture		= pLOriginal->moisture;
 pLCopy->permittivity	= Copy_Complex (&(pLOriginal->permittivity));
 Copy_d3Vector (&(pLCopy->cl), &(pLOriginal->cl));
 Copy_d3Vector (&(pLCopy->xl), &(pLOriginal->xl));
 Copy_d3Vector (&(pLCopy->yl), &(pLOriginal->yl));
 Copy_d3Vector (&(pLCopy->zl), &(pLOriginal->zl));
 pLCopy->next			= pLOriginal->next;
 pLCopy->prev			= pLOriginal->prev;
 return;
}

void		Print_Leaf	(Leaf *pL)
{
 printf ("\n");
 printf ("%12d\n", pL->species);
 printf ("%12.5e\n", pL->d1);
 printf ("%12.5e\n", pL->d2);
 printf ("%12.5e\n", pL->d3);
 printf ("%12.5e\n", pL->theta);
 printf ("%12.5e\n", pL->phi);
 printf ("%12.5e\n", pL->moisture);
 Print_Complex (&(pL->permittivity));
 Print_d3Vector (&(pL->cl));
 Print_d3Vector (&(pL->xl));
 Print_d3Vector (&(pL->yl));
 Print_d3Vector (&(pL->zl));
 //printf ("%ld\n", (long) pL->next);
 //printf ("%ld\n", (long) pL->prev);
 printf ("\n");
 return;
}

void		Assign_Leaf		(Leaf *pL, int species, double d1, double d2, double d3, double theta, double phi,
							 double moisture, Complex permittivity, d3Vector cl)
{
 pL->species		= species;
 pL->d1				= d1;
 pL->d2				= d2;
 pL->d3				= d3;
 pL->theta			= theta;
 pL->phi			= phi;
 pL->moisture		= moisture;
 pL->permittivity	= Copy_Complex (&permittivity);
 Copy_d3Vector		(&(pL->cl), &cl);
 Leaf_Directions	(pL);
 pL->next			= NULL_PTR2LEAF;
 pL->prev			= NULL_PTR2LEAF;
 return;
}

/*************************************/
/* Doubly linked list implementation */
/*************************************/

void		Leaf_init_list	(Leaf_List *pLl)
{
 pLl->head	= NULL_PTR2LEAF_LIST;
 pLl->tail	= NULL_PTR2LEAF_LIST;
 pLl->n		= 0L;
 return;
}

int			Leaf_head_add	(Leaf_List *pLl, Leaf *pL)
{
 Leaf	*old_head	= pLl->head;
 Leaf	*new_f		= (Leaf*) calloc (1, sizeof (Leaf));
 int	rtn_value	= NO_LEAF_ERRORS;

 if (new_f != NULL_PTR2LEAF) {
  Copy_Leaf (new_f, pL);
  if (old_head != NULL_PTR2LEAF) {
   old_head->prev	= new_f;
  }
  new_f->next	= old_head;
  new_f->prev	= NULL_PTR2LEAF;
  pLl->head	= new_f;
  if (pLl->tail	== NULL_PTR2LEAF) {
   pLl->tail	= new_f;
  }
  pLl->n++;
 } else {
  rtn_value	= !NO_LEAF_ERRORS;
 }
 return (rtn_value);
}

void		Leaf_head_print			(Leaf_List *pLl)
{
 Leaf	*pL	= pLl->head;
 long		i;

 for (i=0; i<pLl->n; i++) {
  Print_Leaf (pL);
  pL	= pL->next;
 }
 return;
}

int			Leaf_tail_add			(Leaf_List *pLl, Leaf *pL)
{
 Leaf	*old_tail	= pLl->tail;
 Leaf	*new_f	= (Leaf*) calloc (1, sizeof (Leaf));
 int		rtn_value	= NO_LEAF_ERRORS;

 if (new_f != NULL_PTR2LEAF) {
  Copy_Leaf (new_f, pL);
  if (old_tail != NULL_PTR2LEAF) {
   old_tail->next	= new_f;
  }
  new_f->prev	= old_tail;
  new_f->next	= NULL_PTR2LEAF;
  pLl->tail	= new_f;
  if (pLl->head	== NULL_PTR2LEAF) {
   pLl->head	= new_f;
  }
  pLl->n++;
 } else {
  rtn_value	= !NO_LEAF_ERRORS;
 }
 return (rtn_value);
}

void		Leaf_tail_print			(Leaf_List *pLl)
{
 Leaf	*pL	= pLl->tail;
 long		i;

 for (i=0; i<pLl->n; i++) {
  Print_Leaf (pL);
  pL	= pL->prev;
 }
 return;
}

int			Leaf_head_sub			(Leaf_List *pLl, Leaf *pL)
{
 int		rtn_value	= NO_LEAF_ERRORS;
 Leaf	*old_head	= pLl->head;

 if (pLl->head != NULL_PTR2LEAF) {
  Copy_Leaf (pL, pLl->head);
  pLl->n--;
  if (pLl->n	== 0L) {
   pLl->head	=   NULL_PTR2LEAF;
   pLl->tail	=   NULL_PTR2LEAF;
  } else {
   pLl->head	= pL->next;
   pLl->head->prev	= NULL_PTR2LEAF;
  }
  free (old_head);
  pL->next	= NULL_PTR2LEAF;
  pL->prev	= NULL_PTR2LEAF;
 } else {
  rtn_value	= !NO_LEAF_ERRORS;
 }
 return (rtn_value);
}

int			Leaf_tail_sub			(Leaf_List *pLl, Leaf *pL)
{
 int		rtn_value	= NO_LEAF_ERRORS;
 Leaf	*old_tail	= pLl->tail;

 if (pLl->tail != NULL_PTR2LEAF) {
  Copy_Leaf (pL, pLl->tail);
  pLl->n--;
  if (pLl->n	== 0L) {
   pLl->head	=   NULL_PTR2LEAF;
   pLl->tail	=   NULL_PTR2LEAF;
  } else {
   pLl->tail	= pL->prev;
   pLl->tail->next	= NULL_PTR2LEAF;
  }
  free (old_tail);
  pL->prev	= NULL_PTR2LEAF;
  pL->next	= NULL_PTR2LEAF;
 } else {
  rtn_value	= !NO_LEAF_ERRORS;
 }
 return (rtn_value);
}

long		Leaf_List_length		(Leaf_List *pLl)
{
 return (pLl->n);
}

Leaf*	Leaf_List_head			(Leaf_List *pLl)
{
 return (pLl->head);
}

Leaf*	Leaf_List_tail			(Leaf_List *pLl)
{
 return (pLl->tail);
}

int			Leaf_insert				(Leaf_List *pLl, Leaf *pL, long m)
{
 int		rtn_value	= NO_LEAF_ERRORS;
 Leaf	*new_f;
 Leaf	*f_m;
 long		i;

 if (m <= 0L) {
  rtn_value	= Leaf_head_add (pLl, pL);
 } else {
  if (m >= pLl->n) {
   rtn_value	= Leaf_tail_add (pLl, pL);
  } else {
   new_f		= (Leaf*) calloc (1, sizeof (Leaf));
   if (new_f != NULL_PTR2LEAF) {
    Copy_Leaf (new_f, pL);
    f_m		= pLl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
	new_f->next		= f_m->next;
	new_f->prev		= f_m->next->prev;
	f_m->next->prev	= new_f;
	f_m->next			= new_f;
	pLl->n++;
   } else {
    rtn_value	= !NO_LEAF_ERRORS;
   }
  }
 }
 return (rtn_value);
}

int			Leaf_delete				(Leaf_List *pLl, Leaf *pL, long m)
{
 int		rtn_value = NO_LEAF_ERRORS;
 Leaf	*f_m;
 Leaf	*f_mm1;
 Leaf	*f_mp1;
 long		i;

 if ((m <=1L) || (m >pLl->n) || (pLl->n == 0L)) {
  rtn_value = !NO_LEAF_ERRORS;
 } else {
  if (m == 1L) {
   rtn_value	= Leaf_head_sub (pLl, pL);
  } else {
   if (m == pLl->n) {
    rtn_value	= Leaf_tail_sub (pLl, pL);
   } else {
    f_m		= pLl->head;
	for (i=0L; i<m-1L; i++) {
	 f_m		= f_m->next;
	}
    f_mm1			= f_m->prev;
	f_mp1			= f_m->next;
    f_mp1->prev	= f_mm1;
	f_mm1->next	= f_mp1;
	Copy_Leaf (pL, f_m);
	pL->next		= NULL_PTR2LEAF;
	pL->prev		= NULL_PTR2LEAF;
	free (f_m);
	pLl->n--;
   }
  }
 }
 return (rtn_value);
}

void		Leaf_empty_list			(Leaf_List *pLl)
{
 Leaf	v;

 if (pLl->n	== 0L) {
  pLl->head	= NULL_PTR2LEAF;
  pLl->tail	= NULL_PTR2LEAF;
 } else {
  while (pLl->n > 0L) {
   Leaf_head_sub (pLl, &v);
  }
 }
 return;
}

/***************************/
/* Other leaf prototypes */
/***************************/

int	Leaf_Directions	(Leaf *pL)
{
 int	rtn_value	= NO_LEAF_ERRORS;
 double	cos_theta	= cos(pL->theta);
 double	sin_theta	= sin(pL->theta);
 double	cos_phi		= cos(pL->phi);
 double	sin_phi		= sin(pL->phi);
 pL->xl				= Cartesian_Assign_d3Vector (cos_theta*cos_phi, cos_theta*sin_phi, -sin_theta);
 pL->yl				= Cartesian_Assign_d3Vector (-sin_phi, cos_phi, 0.0);
 pL->zl				= Cartesian_Assign_d3Vector (sin_theta*cos_phi, sin_theta*sin_phi, cos_theta);
 return (rtn_value);
}

double		Leaf_Volume			(Leaf *pL)
{
/****************************************************/
/* For needles (cylinders)         v = PI d1 d2 d2	*/
/* For leaves (rectangular slices) v = d1 d2 d3		*/
/****************************************************/
 double	v;
 switch (pL->species) {
  case POLSARPROSIM_PINE_NEEDLE:	v	= DPI_RAD*pL->d1*pL->d2*pL->d2;	break;
  case POLSARPROSIM_DECIDUOUS_LEAF:	v	= pL->d1*pL->d2*pL->d3;			break;
  default:							v	= 0.0;
 }
 return (v);
}

/**************************************/
/* Proper Leaf_List copying routine */
/**************************************/

void		Leaf_List_Copy		(Leaf_List *pLL_Copy, Leaf_List *pLL_Org)
{
 Leaf		b;
 long		i_leaf;
 Leaf_empty_list (pLL_Copy);
 for (i_leaf = 0L; i_leaf < pLL_Org->n; i_leaf++) {
  Leaf_head_sub (pLL_Org, &b);
  Leaf_tail_add (pLL_Org, &b);
  Leaf_tail_add (pLL_Copy, &b);
 }
 return;
}
