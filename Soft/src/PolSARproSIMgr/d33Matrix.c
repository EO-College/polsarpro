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
 * Module      : d33Matrix.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "d33Matrix.h"

void		Create_d33Matrix		(d33Matrix *p_d33m)
{
 int i,j;
 for (i=0;i<3; i++) {
  for (j=0;j<3; j++) {
   p_d33m->m[3*i+j] = 0.0;
  }
 }
 return;
}

void		Destroy_d33Matrix		(d33Matrix *p_d33m)
{
 int i,j;
 for (i=0;i<3; i++) {
  for (j=0;j<3; j++) {
   p_d33m->m[3*i+j] = 0.0;
  }
 }
 return;
}

d33Matrix	Zero_d33Matrix			(void)
{
 d33Matrix d33m;
 Create_d33Matrix (&d33m);
 return (d33m);
}

d33Matrix Idem_d33Matrix (void)
{
 d33Matrix d33m;
 int i;

 Create_d33Matrix (&d33m);
 for (i=0; i<3; i++) {
  d33m.m[3*i+i] = 1.0;
 }
 return (d33m);
}

void Print_d33Matrix (d33Matrix d33m)
{
 int i,j;
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   printf ("%12.5e ", d33m.m[3*i+j]);
  }
  printf ("\n");
 }
 return;
}

d33Matrix d33Matrix_double_product (d33Matrix d33m, double x)
{
 d33Matrix d33m2;
 int i,j;

 Create_d33Matrix (&d33m2);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   d33m2.m[3*i+j] = x*d33m.m[3*i+j];
  }
 }
 return (d33m2);
}

d3Vector d33Matrix_d3Vector_product (d33Matrix d33m, d3Vector d3v)
{
 int i,j;
 d3Vector d3v2;

 Create_d3Vector (&d3v2);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   d3v2.x[i] += d33m.m[3*i+j] * d3v.x[j];
  }
 }
 Polar_d3Vector (&d3v2);
 return (d3v2);
}

d33Matrix d3vector_dyadic_product (d3Vector d3v1, d3Vector d3v2)
{
 d33Matrix d33m;
 int i,j;

 Create_d33Matrix (&d33m);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   d33m.m[3*i+j] = d3v1.x[i] * d3v2.x[j];
  }
 }
 return (d33m);
}

d33Matrix d33Matrix_product  (d33Matrix d33m1, d33Matrix d33m2)
{
 int i,j,k;
 d33Matrix d33m3;

 Create_d33Matrix (&d33m3);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   for (k=0; k<3; k++) {
    d33m3.m[3*i+j] += d33m1.m[3*i+k] * d33m2.m[3*k+j];
   }
  }
 }
 return (d33m3);
}

d33Matrix d33Matrix_sum (d33Matrix d33m1, d33Matrix d33m2)
{
 d33Matrix d33m3;
 int i,j;

 Create_d33Matrix (&d33m3);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   d33m3.m[3*i+j] = d33m1.m[3*i+j] + d33m2.m[3*i+j];
  }
 }
 return (d33m3);
}

d33Matrix d33Matrix_difference (d33Matrix d33m1, d33Matrix d33m2)
{
 d33Matrix d33m3;
 int i,j;

 Create_d33Matrix (&d33m3);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   d33m3.m[3*i+j] = d33m1.m[3*i+j] - d33m2.m[3*i+j];
  }
 }
 return (d33m3);
}

/**************************************************/
/* Rotations are anti-clockwise looking down axis */
/**************************************************/

d33Matrix	d33Matrix_xRotation			(double theta)
{
 d33Matrix	d33mRx;
 double		c	= cos(theta);
 double		s	= sin(theta);

 Create_d33Matrix (&d33mRx);
 d33mRx.m[0]	=  1.0;
 d33mRx.m[4]	=  c;
 d33mRx.m[5]	= -s;
 d33mRx.m[7]	=  s;
 d33mRx.m[8]	=  c;
 return (d33mRx);
}

d33Matrix	d33Matrix_yRotation			(double theta)
{
 d33Matrix	d33mRy;
 double		c	= cos(theta);
 double		s	= sin(theta);

 Create_d33Matrix (&d33mRy);
 d33mRy.m[4]	=  1.0;
 d33mRy.m[0]	=  c;
 d33mRy.m[2]	=  s;
 d33mRy.m[6]	= -s;
 d33mRy.m[8]	=  c;
 return (d33mRy);
}

d33Matrix	d33Matrix_zRotation			(double theta)
{
 d33Matrix	d33mRz;
 double		c	= cos(theta);
 double		s	= sin(theta);

 Create_d33Matrix (&d33mRz);
 d33mRz.m[8]	=  1.0;
 d33mRz.m[0]	=  c;
 d33mRz.m[1]	= -s;
 d33mRz.m[3]	=  s;
 d33mRz.m[4]	=  c;
 return (d33mRz);
}


