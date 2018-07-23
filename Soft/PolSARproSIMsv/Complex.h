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
 * Module      : Complex.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __COMPLEX_H__
#define __COMPLEX_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

#define COMPLEX_PI_DEG  180.0f
#define COMPLEX_DPI_DEG 180.0
#define COMPLEX_PI_RAD  3.14159265f
#define COMPLEX_DPI_RAD 3.14159265358979

#define COMPLEX_SQRT_PI_DEG		13.41640786f
#define COMPLEX_SQRT_DPI_DEG	13.4164078649987
#define COMPLEX_SQRT_PI_RAD		1.772453851f
#define COMPLEX_SQRT_DPI_RAD	1.77245385090552

typedef struct complex_tag {
 double x;
 double y;
 double	r;
 double	phi;
} Complex;

void		Create_Complex				(Complex *p_c);
void		Destroy_Complex				(Complex *p_c);
void		Zero_Complex				(Complex *p_c);
void		Polar_Complex				(Complex *p_c);
void		Cartesian_Complex			(Complex *p_c);
void		Cartesian_Assign_Complex	(Complex *p_c, double x, double y);
void		Polar_Assign_Complex		(Complex *p_c, double r, double phi);
void		Print_Complex				(Complex *p_c);
void		Read_Complex				(FILE *pF, Complex *p_c);
void		Write_Complex				(FILE *pF, Complex *p_c);
Complex		Copy_Complex				(Complex *p_z);
Complex		xy_complex					(double x, double y);
Complex		rp_complex					(double r, double phi);
double		complex_modulus				(Complex z);
double		complex_argument			(Complex z);
double		complex_real				(Complex z);
double		complex_imaginary			(Complex z);
Complex		complex_add					(Complex z1, Complex z2);
Complex		complex_sub					(Complex z1, Complex z2);
Complex		complex_mul					(Complex z1, Complex z2);
Complex		complex_div					(Complex z1, Complex z2);
Complex		complex_rmul				(Complex z1, double x);
Complex		complex_conjugate			(Complex z);
Complex		complex_sqrt				(Complex z);
Complex		complex_exp					(Complex z);
Complex		complex_cube_root			(Complex z);
Complex		complex_log					(Complex z);
Complex		complex_cos					(Complex z);
Complex		complex_sin					(Complex z);

#endif
