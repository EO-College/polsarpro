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
 * Module      : Complex.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "Complex.h"

void		Create_Complex						(Complex *p_c)
{
 p_c->x		= 0.0;
 p_c->y		= 0.0;
 p_c->r		= 0.0;
 p_c->phi	= 0.0;
 return;
}

void		Destroy_Complex						(Complex *p_c)
{
 p_c->x		= 0.0;
 p_c->y		= 0.0;
 p_c->r		= 0.0;
 p_c->phi	= 0.0;
 return;
}

void		Zero_Complex						(Complex *p_c)
{
 p_c->x		= 0.0;
 p_c->y		= 0.0;
 p_c->r		= 0.0;
 p_c->phi	= 0.0;
 return;
}

void		Polar_Complex						(Complex *p_c)
{
 p_c->r		= sqrt (p_c->x*p_c->x+p_c->y*p_c->y);
 p_c->phi	= atan2 (p_c->y, p_c->x);
 return;
}

void		Cartesian_Complex					(Complex *p_c)
{
 p_c->x		= p_c->r*cos(p_c->phi);
 p_c->y		= p_c->r*sin(p_c->phi);
 return;
}

void		Cartesian_Assign_Complex			(Complex *p_c, double x, double y)
{
 p_c->x		= x;
 p_c->y		= y;
 Polar_Complex (p_c);
 return;
}

void		Polar_Assign_Complex				(Complex *p_c, double r, double phi)
{
 p_c->r		= r;
 p_c->phi	= phi;
 Cartesian_Complex (p_c);
 return;
}

void		Print_Complex						(Complex *p_c)
{
 printf ("%10.3e\t%10.3e\t%10.3e\t%10.3e\t", p_c->x, p_c->y, p_c->r, p_c->phi);
 return;
}

void		Read_Complex						(FILE *pF, Complex *p_c)
{
 fread (&(p_c->x), sizeof(double), 1, pF);
 fread (&(p_c->y), sizeof(double), 1, pF);
 Polar_Complex (p_c);
 return;
}

void		Write_Complex						(FILE *pF, Complex *p_c)
{
 fwrite (&(p_c->x), sizeof(double), 1, pF);
 fwrite (&(p_c->y), sizeof(double), 1, pF);
 return;
}

Complex		Copy_Complex	(Complex *p_z)
{
 Complex	w;
 w.x		= p_z->x;
 w.y		= p_z->y;
 w.r		= p_z->r;
 w.phi		= p_z->phi;
 return (w);
}

Complex		xy_complex		(double x, double y)
{
 Complex	w;
 w.x		= x;
 w.y		= y;
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex		rp_complex		(double r, double phi)
{
 Complex	w;
 w.r		= r;
 w.phi		= phi;
 w.x		= w.r*cos(w.phi);
 w.y		= w.r*sin(w.phi);
 return (w);
}

double	complex_modulus		(Complex z)
{
 return (z.r);
}

double	complex_argument	(Complex z)
{
 return (z.phi);
}

double	complex_real		(Complex z)
{
 return (z.x);
}

double	complex_imaginary	(Complex z)
{
 return (z.y);
}

Complex complex_add (Complex z1, Complex z2)
{
 Complex	w;
 w.x		= z1.x+z2.x;
 w.y		= z1.y+z2.y;
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex complex_sub (Complex z1, Complex z2)
{
 Complex	w;
 w.x		= z1.x-z2.x;
 w.y		= z1.y-z2.y;
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex complex_mul (Complex z1, Complex z2)
{
 Complex	w;
 w.r		= z1.r*z2.r;
 w.phi		= z1.phi+z2.phi;
 w.x		= w.r*cos(w.phi);
 w.y		= w.r*sin(w.phi);
 return (w);
}

Complex complex_div (Complex z1, Complex z2)
{
 Complex	w;
 w.r		= z1.r/z2.r;
 w.phi		= z1.phi-z2.phi;
 w.x		= w.r*cos(w.phi);
 w.y		= w.r*sin(w.phi);
 return (w);
}

Complex complex_rmul (Complex z1, double x)
{
 Complex	w;
 w.x		= z1.x*x;
 w.y		= z1.y*x;
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex	complex_conjugate	(Complex z)
{
 Complex	w;
 w.x		=  z.x;
 w.y		= -z.y;
 w.r		=  z.r;
 w.phi		= -z.phi;
 return (w);
}

Complex	complex_sqrt		(Complex z)
{
 Complex	w;
 w.r		= sqrt(z.r);
 w.phi		= z.phi/2.0;
 w.x		= w.r*cos(w.phi);
 w.y		= w.r*sin(w.phi);
 return (w);
}

Complex	complex_exp	(Complex z)
{
 Complex	w;
 w.x		= exp(z.x)*cos(z.y);
 w.y		= exp(z.x)*sin(z.y);
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex	complex_cube_root	(Complex z)
{
 Complex	w;
 w.r		= pow (z.r, 1.0/3.0);
 w.phi		= z.phi/3.0;
 w.x		= w.r*cos(w.phi);
 w.y		= w.r*sin(w.phi);
 return (w);
}

Complex	complex_log	(Complex z)
{
 Complex	w;
 w.x		= log(z.r);
 w.y		= z.phi;
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex	complex_cos	(Complex z)
{
 Complex	w;
 w.x		=  0.5*cos(z.x)*(exp(z.y) + exp(-z.y));
 w.y		= -0.5*sin(z.x)*(exp(z.y) - exp(-z.y));
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}

Complex	complex_sin	(Complex z)
{
 Complex	w;
 w.x		=  0.5*sin(z.x)*(exp(z.y) + exp(-z.y));
 w.y		=  0.5*cos(z.x)*(exp(z.y) - exp(-z.y));
 w.r		= sqrt (w.x*w.x+w.y*w.y);
 w.phi		= atan2 (w.y, w.x);
 return (w);
}
