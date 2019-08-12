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
 * Module      : c33Matrix.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "c33Matrix.h"

void		Create_c33Matrix		(c33Matrix *p_c33m)
{
 int i,j;
 for (i=0;i<3; i++) {
  for (j=0;j<3; j++) {
   p_c33m->m[3*i+j] = xy_complex (0.0, 0.0);
  }
 }
 return;
}

void		Destroy_c33Matrix		(c33Matrix *p_c33m)
{
 int i,j;
 for (i=0;i<3; i++) {
  for (j=0;j<3; j++) {
   p_c33m->m[3*i+j] = xy_complex (0.0, 0.0);
  }
 }
 return;
}

c33Matrix	Zero_c33Matrix			(void)
{
 c33Matrix c33m;
 Create_c33Matrix (&c33m);
 return (c33m);
}

c33Matrix Idem_c33Matrix (void)
{
 c33Matrix c33m;
 int i;

 Create_c33Matrix (&c33m);
 for (i=0; i<3; i++) {
  c33m.m[3*i+i] = xy_complex (1.0, 0.0);
 }
 return (c33m);
}

void Print_c33Matrix (c33Matrix c33m)
{
 int i,j;
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   Print_Complex (&(c33m.m[3*i+j]));
  }
  printf ("\n");
 }
 return;
}

c33Matrix c33Matrix_Complex_product (c33Matrix c33m, Complex z)
{
 c33Matrix c33m2;
 int i,j;

 Create_c33Matrix (&c33m2);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   c33m2.m[3*i+j] = complex_mul (z, c33m.m[3*i+j]);
  }
 }
 return (c33m2);
}

c3Vector c33Matrix_c3Vector_product (c33Matrix c33m, c3Vector c3v)
{
 int i,j;
 c3Vector c3v2;

 Create_c3Vector (&c3v2);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   c3v2.z[i] = complex_add (c3v2.z[i], complex_mul (c33m.m[3*i+j],c3v.z[j]));
  }
 }
 return (c3v2);
}

c33Matrix c3Vector_dyadic_product (c3Vector c3v1, c3Vector c3v2)
{
 c33Matrix c33m;
 int i,j;

 Create_c33Matrix (&c33m);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   c33m.m[3*i+j] = complex_mul (c3v1.z[i], c3v2.z[j]);
  }
 }
 return (c33m);
}

c33Matrix c33Matrix_product  (c33Matrix c33m1, c33Matrix c33m2)
{
 int i,j,k;
 c33Matrix c33m3;

 Create_c33Matrix (&c33m3);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   for (k=0; k<3; k++) {
    c33m3.m[3*i+j] = complex_add (c33m3.m[3*i+j], complex_mul (c33m1.m[3*i+k], c33m2.m[3*k+j]));
   }
  }
 }
 return (c33m3);
}

c33Matrix c33Matrix_sum (c33Matrix c33m1, c33Matrix c33m2)
{
 c33Matrix c33m3;
 int i,j;

 Create_c33Matrix (&c33m3);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   c33m3.m[3*i+j] = complex_add (c33m1.m[3*i+j], c33m2.m[3*i+j]);
  }
 }
 return (c33m3);
}

c33Matrix c33Matrix_difference (c33Matrix c33m1, c33Matrix c33m2)
{
 c33Matrix c33m3;
 int i,j;

 Create_c33Matrix (&c33m3);
 for (i=0; i<3; i++) {
  for (j=0; j<3; j++) {
   c33m3.m[3*i+j] = complex_sub (c33m1.m[3*i+j], c33m2.m[3*i+j]);
  }
 }
 return (c33m3);
}


