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
 * Module      : c33Matrix.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __C33MATRIX_H__
#define __C33MATRIX_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>
#include	<float.h>

#include	"c3Vector.h"
#include	"Complex.h"

typedef struct c33matrix_tag {
 Complex  m[9];
} c33Matrix;

void		Create_c33Matrix			(c33Matrix *p_c33m);
void		Destroy_c33Matrix			(c33Matrix *p_c33m);
c33Matrix	Zero_c33Matrix				(void);
c33Matrix	Idem_c33Matrix				(void);
void		Print_c33Matrix				(c33Matrix c33m);
c33Matrix	c33Matrix_Complex_product	(c33Matrix c33m,	Complex x);
c3Vector	c33Matrix_c3Vector_product	(c33Matrix c33m,	c3Vector c3v);
c33Matrix	c3Vector_dyadic_product		(c3Vector c3v1,		c3Vector c3v2);
c33Matrix	c33Matrix_product			(c33Matrix c33m1,	c33Matrix c33m2);
c33Matrix	c33Matrix_sum				(c33Matrix c33m1,	c33Matrix c33m2);
c33Matrix	c33Matrix_difference		(c33Matrix c33m1,	c33Matrix c33m2);

#endif

