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
 * Module      : Attenuation.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 */
#include "Attenuation.h"

c3Vector	d3Vector_2_c3Vector	(d3Vector v)
{
 Complex	cx	= xy_complex (v.x[0], 0.0);
 Complex	cy	= xy_complex (v.x[1], 0.0);
 Complex	cz	= xy_complex (v.x[2], 0.0);
 return (Assign_c3Vector (cx, cy, cz));
}

double	fn	(double x, double k)
{
 double	f	= 1.0/sqrt((1.0-x*x)*(1.0-k*k*x*x));
 return (f);
}

double fnquad (int Nsub, double xmin, double xmax, double k)
{
 const int		Nq		= 5;
 const double	u[5]	= {0.22950371731828398583, 0.63647584009176348145, 0.90150720533183638718, 0.992838312235203529446, 0.9999843442623408409287};
 const double	w[5]	= {0.45011008253896641997, 0.34830268517741692339, 0.17446797661827909007, 0.026962997721603785257, 0.0001562579437337813003};
 double			deltax, a, b;
 int			i,j;
 double			bma2, bpa2;
 double			xp, xm;
 double			sum	= 0.0;

 deltax	= (xmax - xmin)/(double) Nsub;
 bma2	= deltax/2.0;
 for (i=0; i<Nsub; i++) {
  a		= xmin	+ i*deltax;
  b		= a + deltax;
  bpa2	= (b+a)/2.0;
  for (j=0; j<Nq; j++) {
   xp	 = bpa2 + u[j] * bma2;
   xm	 = bpa2 - u[j] * bma2;
   sum	+= w[j] * (fn (xp, k) + fn (xm, k)); 
  }
 }
 return (bma2 * sum);
}

double	en	(double x, double k)
{
 double	e	= sqrt((1.0-k*k*x*x)/(1.0-x*x));
 return (e);
}

double enquad (int Nsub, double xmin, double xmax, double k)
{
 const int		Nq		= 5;
 const double	u[5]	= {0.22950371731828398583, 0.63647584009176348145, 0.90150720533183638718, 0.992838312235203529446, 0.9999843442623408409287};
 const double	w[5]	= {0.45011008253896641997, 0.34830268517741692339, 0.17446797661827909007, 0.026962997721603785257, 0.0001562579437337813003};
 double			deltax, a, b;
 int			i,j;
 double			bma2, bpa2;
 double			xp, xm;
 double			sum	= 0.0;

 deltax	= (xmax - xmin)/(double) Nsub;
 bma2	= deltax/2.0;
 for (i=0; i<Nsub; i++) {
  a		= xmin	+ i*deltax;
  b		= a + deltax;
  bpa2	= (b+a)/2.0;
  for (j=0; j<Nq; j++) {
   xp	 = bpa2 + u[j] * bma2;
   xm	 = bpa2 - u[j] * bma2;
   sum	+= w[j] * (en (xp, k) + en (xm, k)); 
  }
 }
 return (bma2 * sum);
}

void	Leaf_Depolarization_Factors	(Leaf *pLeaf, double *pL1, double *pL2, double *pL3)
{
 const int m	= POLSARPROSIM_DPOL_FACTOR_M;
 double	xmin, xmax;
 double	k;
 double	fk;
 double	ek;
 double	a1, a2, a3;
 /****************************************************/
 /* Dimensions always ordered such that d1 > d2 > d3 */
 /****************************************************/
 if (pLeaf->species == POLSARPROSIM_DECIDUOUS_LEAF) {
  if (fabs(pLeaf->d1-pLeaf->d2) < FLT_EPSILON) {
   /* circular (square) disk */
   *pL1	= 0.0;
   *pL2	= 0.0;
   *pL3	= 1.0;		/* short direction (thickness) */
  } else {
   a1	= pLeaf->d1/2.0;
   a2	= pLeaf->d2/2.0;
   a3	= pLeaf->d3/2.0;
   k	= sqrt ((a1*a1-a2*a2)/(a1*a1-a3*a3));
   xmax	= sin (acos (a3/a1));
   xmin	= 0.0;
   fk	= fnquad (m, xmin, 0.9*xmax, k) + fnquad (10*m, 0.9*xmax, xmax, k);
   ek	= enquad (m, xmin, 0.9*xmax, k) + enquad (10*m, 0.9*xmax, xmax, k);
   *pL1	= a1*a2*a3*(fk-ek)/((a1*a1-a2*a2)*sqrt(a1*a1-a3*a3));
   *pL3	= a2*(a2-(a1*a3*ek/(sqrt(a1*a1-a3*a3))))/(a2*a2-a3*a3);
   *pL2	= 1.0 - *pL1 - *pL3;
  }
 } else {
  /* circular cylinder */
  *pL1	= 0.0;		/* long direction (length) */
  *pL2	= 0.5;
  *pL3	= 0.5;
 }
 return;
}

c33Matrix	Leaf_Polarisability			(Leaf *pLeaf, double L1, double L2, double L3)
{
 c33Matrix	P	= Zero_c33Matrix ();
 Complex	cL1, cL2, cL3;
 Complex	P11, P22, P33;
 c3Vector	cv1, cv2, cv3;
 Complex	epsm1	= xy_complex (pLeaf->permittivity.x-1.0, pLeaf->permittivity.y);
 Complex	c1		= xy_complex (1.0, 0.0);
 /*******************************************/
 /* For needles z is the axial direction,	*/
 /* for leaves y is the long direction,		*/
 /* x is the short direction,				*/
 /* and z is the surface normal				*/
 /*******************************************/
 cL1	= xy_complex (L1, 0.0);
 cL2	= xy_complex (L2, 0.0);
 cL3	= xy_complex (L3, 0.0);
 P11	= complex_div (c1, complex_add (complex_mul (epsm1, cL1), c1));
 P22	= complex_div (c1, complex_add (complex_mul (epsm1, cL2), c1));
 P33	= complex_div (c1, complex_add (complex_mul (epsm1, cL3), c1));
 switch (pLeaf->species) {
  case POLSARPROSIM_PINE_NEEDLE:	cv1	= d3Vector_2_c3Vector (pLeaf->zl); 
									cv2	= d3Vector_2_c3Vector (pLeaf->xl);
									cv3	= d3Vector_2_c3Vector (pLeaf->yl);	break;
  case POLSARPROSIM_DECIDUOUS_LEAF: cv1	= d3Vector_2_c3Vector (pLeaf->yl);
									cv2	= d3Vector_2_c3Vector (pLeaf->xl);
									cv3	= d3Vector_2_c3Vector (pLeaf->zl);	break;
  default:							cv1	= d3Vector_2_c3Vector (pLeaf->yl);
									cv2	= d3Vector_2_c3Vector (pLeaf->xl);
									cv3	= d3Vector_2_c3Vector (pLeaf->zl);	break;
 }
 P	= c33Matrix_Complex_product (c3Vector_dyadic_product (cv1, cv1), P11);
 P	= c33Matrix_sum (P, c33Matrix_Complex_product (c3Vector_dyadic_product (cv2, cv2), P22));
 P	= c33Matrix_sum (P, c33Matrix_Complex_product (c3Vector_dyadic_product (cv3, cv3), P33));
 return (P);
}

#ifndef RAYLEIGH_LEAF
c33Matrix	Leaf_Scattering_Matrix		(Leaf *pLeaf, double L1, double L2, double L3, d3Vector *p_ki, d3Vector *p_ks)
#else
c33Matrix	Leaf_Scattering_Matrix		(Leaf *pLeaf, double L1, double L2, double L3, d3Vector *p_ki)
#endif
{
 Complex	epsm1	= xy_complex (pLeaf->permittivity.x-1.0, pLeaf->permittivity.y);
 c33Matrix	S		= c33Matrix_Complex_product (Leaf_Polarisability (pLeaf, L1, L2, L3), epsm1);
 double		v		= Leaf_Volume (pLeaf);
 double		k02		= d3Vector_scalar_product (*p_ki, *p_ki);
 double		sfac	= k02/(2.0*SQRT_DPI_RAD);
#ifndef RAYLEIGH_LEAF
 d3Vector	Kappa	= d3Vector_difference (*p_ki, *p_ks);
 double		Kx		= d3Vector_scalar_product (Kappa, pLeaf->xl);
 double		Ky		= d3Vector_scalar_product (Kappa, pLeaf->yl);
 double		Kz		= d3Vector_scalar_product (Kappa, pLeaf->zl);
#endif
 double		shape	= 1.0;

#ifndef RAYLEIGH_LEAF
 switch (pLeaf->species) {
  case POLSARPROSIM_PINE_NEEDLE:	shape	= Sinc(Kz*pLeaf->d1/2.0)*SincJ1(sqrt(Kx*Kx+Ky*Ky)*pLeaf->d3);	break;
  case POLSARPROSIM_DECIDUOUS_LEAF: shape	= Sinc(Kx*pLeaf->d1/2.0)*Sinc(Ky*pLeaf->d2/2.0)*Sinc(Kz*pLeaf->d3/2.0);	break;
  default:							shape	= 0.0; break;
 }
#endif
 S	= c33Matrix_Complex_product (S, xy_complex (v*shape*sfac,0.0));
 return (S);
}


