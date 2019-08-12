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
 * Module      : d33Matrix.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __D33MATRIX_H__
#define __D33MATRIX_H__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>

#include "d3Vector.h"

typedef struct d33matrix_tag {
 double  m[9];
} d33Matrix;

void		Create_d33Matrix			(d33Matrix *p_d33m);
void		Destroy_d33Matrix			(d33Matrix *p_d33m);
d33Matrix	Zero_d33Matrix				(void);
d33Matrix	Idem_d33Matrix				(void);
void		Print_d33Matrix				(d33Matrix d33m);
d33Matrix	d33Matrix_double_product	(d33Matrix d33m,	double x);
d3Vector	d33Matrix_d3Vector_product	(d33Matrix d33m,	d3Vector d3v);
d33Matrix	d3vector_dyadic_product		(d3Vector d3v1,		d3Vector d3v2);
d33Matrix	d33Matrix_product			(d33Matrix d33m1,	d33Matrix d33m2);
d33Matrix	d33Matrix_sum				(d33Matrix d33m1,	d33Matrix d33m2);
d33Matrix	d33Matrix_difference		(d33Matrix d33m1,	d33Matrix d33m2);
d33Matrix	d33Matrix_xRotation			(double theta);
d33Matrix	d33Matrix_yRotation			(double theta);
d33Matrix	d33Matrix_zRotation			(double theta);

#endif
