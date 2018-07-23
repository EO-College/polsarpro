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
 * Module      : Jnz.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"Jnz.h"

Complex			Jn		(Complex z, int n)
{
 const double	amax	= 30.0;
 const double	b		= 0.63661977236758;
 const double	pi4		= 0.78539816339745;
 Complex		Jz;
 Complex		w;
 Complex		z2;
 int			i;
 double			f;
 Complex		z2f;
 double			a		= z.r;
 int			imax	= 10*((int) a);
 Complex		cb, scbz, pz, qz, arg;
 Complex		*J		= (Complex*) calloc (n+2, sizeof(Complex));
 Complex		twozinv;

 if (imax < 10) {
  imax = 10;
 }

 z2.r		= z.r*z.r;
 z2.phi		= 2.0*z.phi;
 z2.x		= z.x*z.x - z.y*z.y;
 z2.y		= 2.0*z.x*z.y;

 if (a < amax) {

 Jz.x		= 0.0;
 Jz.y		= 0.0;
 Jz.r		= 0.0;
 Jz.phi		= 0.0;
 w.x		= 1.0;
 w.y		= 0.0;
 w.r		= 1.0;
 w.phi		= 0.0;
 z2f.phi	= z2.phi;
 for (i=0;i<=imax;i++) {
  Jz	= complex_add (Jz, w);
  f		= -0.25/((double)((i+1)*(n+i+1)));
  z2f.x	= z2.x*f;
  z2f.y	= z2.y*f;
  z2f.r	= z2.r*f;
  w		= complex_mul (w, z2f);
 }
 if (n>0) {
  w.x		= 1.0;
  w.y		= 0.0;
  w.r		= 1.0;
  w.phi		= 0.0;
  for (i=1;i<=n;i++) {
	w = complex_mul (w, complex_rmul (z, 1.0/(2.0*i)));
  }
  Jz = complex_mul (Jz, w);
 }

 } else {

  Cartesian_Assign_Complex (&Jz, 0.0, 0.0);
  Cartesian_Assign_Complex (&cb, b, 0.0);
  scbz	= complex_sqrt (complex_div (cb, z));
  /* n = 0 */
  w.x		=  1.0;
  w.y		=  0.0;
  w.r		=  1.0;
  w.phi		=  0.0;
  z2f.x		=  9.0/128.0;
  z2f.y		=  0.0;
  z2f.r		=  9.0/128.0;
  z2f.phi	=  0.0;
  pz		=  complex_sub (w, complex_div (z2f, z2));
  w.x		= -0.125;
  w.y		=  0.0;
  w.r		=  0.125;
  w.phi		=  0.0;
  z2f.x		=  0.0723421875;
  z2f.y		=  0.0;
  z2f.r		=  0.0723421875;
  z2f.phi	=  0.0;
  qz		=  complex_add (complex_div (w, z), complex_div (z2f, complex_mul (z2, z)));
  w.x		=  pi4;
  w.y		=  0.0;
  w.r		=  pi4;
  w.phi		=  0.0;
  arg		=  complex_sub (z, w);
  w			=  complex_mul (pz, complex_cos (arg));
  z2f		=  complex_mul (qz, complex_sin (arg));
  J[0]		=  complex_mul (scbz, complex_sub (w, z2f));
  /* n = 1 */
  w.x		=  1.0;
  w.y		=  0.0;
  w.r		=  1.0;
  w.phi		=  0.0;
  z2f.x		=  15.0/128.0;
  z2f.y		=  0.0;
  z2f.r		=  15.0/128.0;
  z2f.phi	=  0.0;
  pz		=  complex_sub (w, complex_div (z2f, z2));
  w.x		=  0.375;
  w.y		=  0.0;
  w.r		=  0.375;
  w.phi		=  0.0;
  z2f.x		=  -0.1025390625;
  z2f.y		=   0.0;
  z2f.r		=   0.1025390625;
  z2f.phi	=   0.0;
  qz		=  complex_add (complex_div (w, z), complex_div (z2f, complex_mul (z2, z)));
  w.x		=  3.0*pi4;
  w.y		=  0.0;
  w.r		=  3.0*pi4;
  w.phi		=  0.0;
  arg		=  complex_sub (z, w);
  w			=  complex_mul (pz, complex_cos (arg));
  z2f		=  complex_mul (qz, complex_sin (arg));
  J[1]		=  complex_mul (scbz, complex_sub (w, z2f));
  /* n > 1 */
  if (n>1) {
   w.x		=  2.0;
   w.y		=  0.0;
   w.r		=  2.0;
   w.phi		=  0.0;
   twozinv	= complex_div (w, z);
   for (i=2; i<=n; i++) {
    J[i]	= complex_sub (complex_mul (complex_rmul(twozinv, (double)(i-1)), J[i-1]), J[i-2]);
   }
  }
  Jz	= J[n];
 }
 free (J);
 return (Jz);
}

Complex			dJndz	(Complex z, int n)
{
 Complex jnm, jnp;
 Complex Jzp;
 
 if (n==0) {
  Jzp = complex_rmul (Jn (z, 1), -1.0);
 } else {
  jnm = Jn (z, n-1);
  jnp = Jn (z, n+1);
  Jzp = complex_rmul (complex_sub (jnm, jnp), 0.5);
 }
 return (Jzp);
}
