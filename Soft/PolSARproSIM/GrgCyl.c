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
 * Module      : GrgCyl.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"GrgCyl.h"

c33Matrix	GrgCylSa			(Cylinder *pCyl, d3Vector *pks, d3Vector *pki)
{
 Complex		cvol;
 c3Vector		x1, x2, x3;
 Complex		axx, ayy, azz;
 Complex		er1, cfac;
 c33Matrix		S		= Zero_c33Matrix ();
 double			vol		= DPI_RAD*pCyl->radius*pCyl->radius*pCyl->length;
 double			k		= pki->r;
 double			fac		= k*k/(2.0*SQRT_DPI_RAD);
 d3Vector		kappa	= d3Vector_difference (*pki,*pks);
 double			kx		= d3Vector_scalar_product (kappa, pCyl->x);
 double			ky		= d3Vector_scalar_product (kappa, pCyl->y);
 double			kz		= d3Vector_scalar_product (kappa, pCyl->axis);
 double			kro		= sqrt (kx*kx+ky*ky);
 double			shape	= Sinc (kz*pCyl->length/2.0)*SincJ1(kro*pCyl->radius);
 d3Vector		kshat	= d3Vector_normalise (*pks);
 c33Matrix		Iksks;
 c3Vector		ckshat;

 cfac		= xy_complex (fac, 0.0);
 cvol		= xy_complex (vol, 0.0);
 x1			= Assign_c3Vector (xy_complex (pCyl->x.x[0], 0.0), xy_complex (pCyl->x.x[1], 0.0), xy_complex (pCyl->x.x[2], 0.0));
 x2			= Assign_c3Vector (xy_complex (pCyl->y.x[0], 0.0), xy_complex (pCyl->y.x[1], 0.0), xy_complex (pCyl->y.x[2], 0.0));
 x3			= Assign_c3Vector (xy_complex (pCyl->axis.x[0], 0.0), xy_complex (pCyl->axis.x[1], 0.0), xy_complex (pCyl->axis.x[2], 0.0)); 
 er1		= xy_complex (pCyl->permittivity.x-1.0, pCyl->permittivity.y);
 azz		= complex_mul (cvol, er1);
 ayy		= xy_complex (2.0/(pCyl->permittivity.x+1.0), 0.0);
 ayy		= complex_mul (azz, ayy);
 axx		= ayy;
 S			= c33Matrix_Complex_product (c3Vector_dyadic_product (x1, x1), axx);
 S			= c33Matrix_sum (S, c33Matrix_Complex_product (c3Vector_dyadic_product (x2, x2), ayy));
 S			= c33Matrix_sum (S, c33Matrix_Complex_product (c3Vector_dyadic_product (x3, x3), azz));
 cfac		= complex_rmul(cfac, shape);
 S			= c33Matrix_Complex_product (S,cfac);
 ckshat		= Assign_c3Vector (xy_complex (kshat.x[0], 0.0), xy_complex (kshat.x[1], 0.0), xy_complex (kshat.x[2], 0.0));
 Iksks		= c33Matrix_difference (Idem_c33Matrix (), c3Vector_dyadic_product (ckshat, ckshat));
 S			= c33Matrix_product (Iksks, S);
 return (S);
}

c33Matrix	GrgCylP				(Cylinder *pCyl, d3Vector *pki)
{
 c3Vector		x1, x2, x3;
 Complex		P, Pz;
 Complex		erm1, erp1;
 c33Matrix		S		= Zero_c33Matrix ();
 double			vol		= DPI_RAD*pCyl->radius*pCyl->radius*pCyl->length;
 d3Vector		kshat	= d3Vector_normalise (*pki);
 c33Matrix		Iksks;
 c3Vector		ckshat;

 x1			= Assign_c3Vector (xy_complex (pCyl->x.x[0], 0.0), xy_complex (pCyl->x.x[1], 0.0), xy_complex (pCyl->x.x[2], 0.0));
 x2			= Assign_c3Vector (xy_complex (pCyl->y.x[0], 0.0), xy_complex (pCyl->y.x[1], 0.0), xy_complex (pCyl->y.x[2], 0.0));
 x3			= Assign_c3Vector (xy_complex (pCyl->axis.x[0], 0.0), xy_complex (pCyl->axis.x[1], 0.0), xy_complex (pCyl->axis.x[2], 0.0)); 
 erm1		= xy_complex (pCyl->permittivity.x-1.0, pCyl->permittivity.y);
 erp1		= xy_complex (pCyl->permittivity.x+1.0, 0.0);
 Pz			= complex_rmul (erm1, vol);
 P			= complex_rmul (Pz, 2.0/(pCyl->permittivity.x+1.0));
 S			= c33Matrix_Complex_product (c3Vector_dyadic_product (x1, x1), P);
 S			= c33Matrix_sum (S, c33Matrix_Complex_product (c3Vector_dyadic_product (x2, x2), P));
 S			= c33Matrix_sum (S, c33Matrix_Complex_product (c3Vector_dyadic_product (x3, x3), Pz));
 ckshat		= Assign_c3Vector (xy_complex (kshat.x[0], 0.0), xy_complex (kshat.x[1], 0.0), xy_complex (kshat.x[2], 0.0));
 Iksks		= c33Matrix_difference (Idem_c33Matrix (), c3Vector_dyadic_product (ckshat, ckshat));
 S			= c33Matrix_product (Iksks, S);
 return (S);
}
