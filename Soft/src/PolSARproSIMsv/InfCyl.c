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
 * Module      : InfCyl.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"InfCyl.h"

c33Matrix InfCylSav2	(Cylinder *pCyl, d3Vector *pks, d3Vector *pki, Yn_Lookup *pYtable, Jn_Lookup *pJtable)
{
 c33Matrix		S	= Zero_c33Matrix ();
 d3Vector		kihat, kilhat;
 double			thetai,phii,cti,sti,cpi,spi;
 d3Vector		kshat, kslhat;
 double			thetas,phis,cts,sts,cps,sps;
 double			k, a, h, vi, vs, mu;
 Complex		u, w1, w2;
 Complex		a2, u2, vs2, zs_factor, cvs;
 Complex		Jn_u, Jnp_u;
 Complex		Hn_vi, Hnp_vi;
 Complex		wn1, wn2, wn3, vi_u, u_vi;
 Complex		Gn;
 int			n;
 double			pY		[INFCYL_TERMS+3];
 double			pJ		[INFCYL_TERMS+3];
 Complex		KFAev	[INFCYL_TERMS+1];
 Complex		KFAhv	[INFCYL_TERMS+1];
 Complex		KFAeh	[INFCYL_TERMS+1];
 Complex		KFAhh	[INFCYL_TERMS+1];
 Complex		KFAz	[INFCYL_TERMS+1];
 Complex		k_2lamdai;
 Complex		KFAA	[INFCYL_TERMS+1];
 Complex		KFAB	[INFCYL_TERMS+1];
 Complex		er;
 Complex		z1, z2;
 Complex		fhh, fhv, fvh, fvv;
 Complex		fhhn, fhvn, fvhn, fvvn;
 Complex		s_factor;
 c3Vector		hil, vil, hsl, vsl;
 c3Vector		xl, yl, zl;
 double			mod_fhh, mod_fhv, mod_fvh, mod_fvv, arg_fhh;
 const Complex	jay	= xy_complex (0.0, 1.0);

 kihat		= d3Vector_normalise (*pki);
 kilhat		= Cartesian_Assign_d3Vector (d3Vector_scalar_product (kihat, pCyl->x), d3Vector_scalar_product (kihat, pCyl->y), d3Vector_scalar_product (kihat, pCyl->axis));
 thetai		= acos (-kilhat.x[2]);
 if (fabs(thetai) > FLT_EPSILON) {
  cti		= cos(thetai);
  sti		= sin(thetai);
  phii		= atan2 (kilhat.x[1],kilhat.x[0]);
  cpi		= cos(phii);
  spi		= sin(phii);
  kshat		= d3Vector_normalise (*pks);
  kslhat	= Cartesian_Assign_d3Vector (d3Vector_scalar_product (kshat, pCyl->x), d3Vector_scalar_product (kshat, pCyl->y), d3Vector_scalar_product (kshat, pCyl->axis));
  thetas	= kslhat.theta;
  cts		= cos(thetas);
  sts		= sin(thetas);
  phis		= kslhat.phi;
  cps		= cos(phis);
  sps		= sin(phis);
  k			= pki->r;
  a			= pCyl->radius;
  h			= pCyl->length/2.0;
  vi		= k*a*sti;
  if (fabs(vi)<DBL_EPSILON) {
   if (vi<0.0) {
    vi		= -DBL_EPSILON;
   } else {
    vi		=  DBL_EPSILON;
   }
  }
  vs		= k*a*sts;
  mu		= Sinc (k*h*(cts+cti));
  er		= xy_complex	(fabs(pCyl->permittivity.x), -fabs(pCyl->permittivity.y));
  w1		= xy_complex	(er.x-cti*cti, er.y);
  u			= complex_rmul	(complex_sqrt (w1), k*a);
  a2		= xy_complex	(a*a, 0.0);
  u2		= complex_mul	(u, u);
  vs2		= xy_complex	(vs*vs, 0.0);
  zs_factor	= complex_div	(a2, complex_sub (u2, vs2));
  cvs		= xy_complex	(vs, 0.0);
  Jlookup (vi, INFCYL_TERMS+2, pJ, pJtable);
  Ylookup (vi, INFCYL_TERMS+2, pY, pYtable, pJtable);
  vi_u		= complex_div (xy_complex (vi, 0.0), u);
  u_vi		= complex_div (u, xy_complex (vi, 0.0));
  for (n=0;n<=INFCYL_TERMS; n++) {
   Jn_u		= Jn (u, n);
   w1		= complex_mul	(u, complex_mul (Jn (cvs, n), Jn (u, n+1)));
   w1		= complex_sub	(w1, complex_rmul (complex_mul (Jn_u, Jn (cvs, n+1)), vs));
   KFAz[n]	= complex_mul	(w1, zs_factor);
   Jnp_u	= dJndz (u, n);
   Hn_vi	= xy_complex	(pJ[n], -pY[n]);
   if (n == 0) {
    Hnp_vi	= xy_complex	(pJ[1], -pY[1]);
    Hnp_vi	= complex_rmul	(Hnp_vi, -1.0);
   } else {
    w1		= xy_complex	(pJ[n+1], -pY[n+1]);
    w2		= xy_complex	(pJ[n-1], -pY[n-1]);
	Hnp_vi	= complex_rmul	(complex_sub (w2, w1), 0.5);
   }
   z1		= complex_mul	(u, complex_mul (Jn_u, Hnp_vi));
   z2		= complex_rmul	(complex_mul (Hn_vi, Jnp_u) ,vi);
   wn1		= complex_sub	(z1, z2);
   wn2		= complex_sub	(z1, complex_mul (er, z2));
   wn3		= complex_rmul	(complex_mul (complex_mul (Hn_vi, Jn_u), complex_sub (u_vi, vi_u)), n*cti);
   Gn		= complex_rmul	(complex_mul (vi_u, complex_sub (complex_mul (wn1, wn2), complex_mul (wn3, wn3))), 0.5*DPI_RAD);
   z2		= complex_div	(xy_complex (sti, 0.0), Gn);
   KFAev[n]	= complex_mul	(complex_mul (jay, z2), wn1);
   KFAhh[n]	= complex_mul	(complex_mul (jay, z2), wn2);
   KFAhv[n]	= complex_mul	(z2, wn3);
   KFAeh[n]	= complex_rmul	(KFAhv[n], -1.0);
  }
  k_2lamdai	= complex_div (xy_complex (0.5, 0.0), complex_sqrt (xy_complex(er.x-cti*cti, er.y)));
  Zero_Complex (&(KFAA[0]));
  KFAB[0]	= complex_rmul (complex_mul (KFAz[1], k_2lamdai), 2.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   KFAA[n]	= complex_mul (complex_sub (KFAz[n-1], KFAz[n+1]), k_2lamdai);
   KFAB[n]	= complex_mul (complex_add (KFAz[n-1], KFAz[n+1]), k_2lamdai);
  }
  s_factor	= xy_complex	(er.x-1.0, er.y);
  s_factor	= complex_rmul	(s_factor, 4.0*SQRT_DPI_RAD*k*k*h*mu);
  fhh		= complex_rmul	(complex_mul (KFAB[0], KFAhh[0]),0.5);
  for (n=1;n<INFCYL_TERMS; n++) {
   fhhn		= complex_mul	(KFAB[n], KFAhh[n]);
   fhhn		= complex_add	(fhhn, complex_rmul (complex_mul (jay, complex_mul (KFAA[n], KFAeh[n])), cti));
   fhhn		= complex_rmul	(fhhn, cos(n*(phis-phii)));
   fhh		= complex_add	(fhh, fhhn);
  }
  fhh		= complex_mul	(fhh, s_factor);
  fvv		= complex_rmul	(complex_mul (KFAB[0], KFAev[0]), cti*cts);
  fvv		= complex_sub	(fvv, complex_rmul (complex_mul (KFAz[0], KFAev[0]), sts));
  fvv		= complex_rmul	(fvv, 0.5);
  for (n=1;n<INFCYL_TERMS; n++) {
   fvvn		= complex_rmul	(complex_mul (KFAB[n], KFAev[n]), cti);
   fvvn		= complex_sub	(fvvn, complex_mul (jay, complex_mul (KFAA[n], KFAhv[n])));
   fvvn		= complex_rmul	(fvvn, cts);
   fvvn		= complex_sub	(fvvn, complex_rmul (complex_mul (KFAz[n], KFAev[n]), sts));
   fvvn		= complex_rmul	(fvvn, cos(n*(phis-phii)));
   fvv		= complex_add	(fvv, fvvn);
  }
  fvv		= complex_mul	(fvv, s_factor);
  fvh		= xy_complex (0.0, 0.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   fvhn		= complex_rmul	(complex_mul (KFAB[n], KFAeh[n]), cti);
   fvhn		= complex_sub	(fvhn, complex_mul (jay, complex_mul (KFAA[n], KFAhh[n])));
   fvhn		= complex_rmul	(fvhn, cts);
   fvhn		= complex_sub	(fvhn, complex_rmul (complex_mul (KFAz[n], KFAeh[n]), sts));
   fvhn		= complex_rmul	(fvhn, sin(n*(phis-phii)));
   fvh		= complex_add	(fvh, fvhn);
  }
  fvh		= complex_mul	(fvh, complex_mul (jay, s_factor));
  fhv		= xy_complex	(0.0, 0.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   fhvn		= complex_mul	(KFAB[n], KFAhv[n]);
   fhvn		= complex_add	(fhvn, complex_rmul (complex_mul (jay, complex_mul (KFAA[n], KFAev[n])), cti));
   fhvn		= complex_rmul	(fhvn, sin(n*(phis-phii)));
   fhv		= complex_add	(fhv, fhvn);
  }
  fhv		= complex_mul	(fhv, complex_mul (jay, s_factor));
  xl		= Assign_c3Vector (xy_complex (pCyl->x.x[0], 0.0),    xy_complex (pCyl->x.x[1], 0.0),    xy_complex (pCyl->x.x[2], 0.0));
  yl		= Assign_c3Vector (xy_complex (pCyl->y.x[0], 0.0),    xy_complex (pCyl->y.x[1], 0.0),    xy_complex (pCyl->y.x[2], 0.0));
  zl		= Assign_c3Vector (xy_complex (pCyl->axis.x[0], 0.0), xy_complex (pCyl->axis.x[1], 0.0), xy_complex (pCyl->axis.x[2], 0.0));
  hil		= c3Vector_scalar_multiply (xl, xy_complex (-spi, 0.0));
  hil		= c3Vector_sum (hil, c3Vector_scalar_multiply (yl, xy_complex ( cpi, 0.0)));
  vil		= c3Vector_scalar_multiply (xl, xy_complex (-cti*cpi, 0.0));
  vil		= c3Vector_sum (vil, c3Vector_scalar_multiply (yl, xy_complex (-cti*spi, 0.0)));
  vil		= c3Vector_sum (vil, c3Vector_scalar_multiply (zl, xy_complex (-sti, 0.0)));
  hsl		= c3Vector_scalar_multiply (xl, xy_complex (-sps, 0.0));
  hsl		= c3Vector_sum (hsl, c3Vector_scalar_multiply (yl, xy_complex ( cps, 0.0)));
  vsl		= c3Vector_scalar_multiply (xl, xy_complex (cts*cps, 0.0));
  vsl		= c3Vector_sum (vsl, c3Vector_scalar_multiply (yl, xy_complex (cts*sps, 0.0)));
  vsl		= c3Vector_sum (vsl, c3Vector_scalar_multiply (zl, xy_complex (-sts, 0.0)));
  mod_fvv	= complex_modulus (fvv);
  mod_fhh	= complex_modulus (fhh);
  mod_fhv	= complex_modulus (fhv);
  mod_fvh	= complex_modulus (fvh);
  mod_fhv	= 0.5*(mod_fhv+mod_fvh);
  mod_fvh	= mod_fhv;
#ifdef INF_CYL_HH_PHASE
  arg_fhh	= complex_argument (fhh);
#else
  Cartesian_Assign_Complex (&s_factor, er.x-1.0, er.y);
  arg_fhh	= complex_argument (s_factor);
#endif
#ifdef INF_CYL_POL_CORR
  Polar_Assign_Complex (&fhh, mod_fhh,  arg_fhh);
  Polar_Assign_Complex (&fhv, mod_fhv,  arg_fhh);
  Polar_Assign_Complex (&fvv, mod_fvv,  DPI_RAD+arg_fhh);
  Polar_Assign_Complex (&fvh, mod_fvh,  DPI_RAD+arg_fhh);
#endif
#ifdef INF_CYL_ZERO_LOCAL_XPOL
  fhv		= xy_complex (0.0, 0.0);
  fvh		= xy_complex (0.0, 0.0);
#endif
  S			= c33Matrix_Complex_product (c3Vector_dyadic_product (vsl,vil), fvv);
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (vsl, hil), fvh));
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (hsl, vil), fhv));
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (hsl, hil), fhh));
 } 
 return (S);
}

/***/

c33Matrix InfCylP	(Cylinder *pCyl, d3Vector *pki, Yn_Lookup *pYtable, Jn_Lookup *pJtable)
{
 c33Matrix		S	= Zero_c33Matrix ();
 d3Vector		kihat, kilhat;
 double			thetai,phii,cti,sti,cpi,spi;
 d3Vector		kshat, kslhat;
 double			thetas,phis,cts,sts,cps,sps;
 double			k, a, h, vi, vs, mu;
 Complex		u, w1, w2;
 Complex		a2, u2, vs2, zs_factor, cvs;
 Complex		Jn_u, Jnp_u;
 Complex		Hn_vi, Hnp_vi;
 Complex		wn1, wn2, wn3, vi_u, u_vi;
 Complex		Gn;
 int			n;
 double			pY		[INFCYL_TERMS+3];
 double			pJ		[INFCYL_TERMS+3];
 Complex		KFAev	[INFCYL_TERMS+1];
 Complex		KFAhv	[INFCYL_TERMS+1];
 Complex		KFAeh	[INFCYL_TERMS+1];
 Complex		KFAhh	[INFCYL_TERMS+1];
 Complex		KFAz	[INFCYL_TERMS+1];
 Complex		k_2lamdai;
 Complex		KFAA	[INFCYL_TERMS+1];
 Complex		KFAB	[INFCYL_TERMS+1];
 Complex		er;
 Complex		z1, z2;
 Complex		fhh, fhv, fvh, fvv;
 Complex		fhhn, fhvn, fvhn, fvvn;
 Complex		s_factor;
 c3Vector		xl, yl, zl;
 double			mod_fvv, arg_fhh;
 const Complex	jay	= xy_complex (0.0, 1.0);
 Complex		G, P, Pz;
 c3Vector		ckshat;
 c33Matrix		Iksks;

 kihat		= d3Vector_normalise (*pki);
 kilhat		= Cartesian_Assign_d3Vector (d3Vector_scalar_product (kihat, pCyl->x), d3Vector_scalar_product (kihat, pCyl->y), d3Vector_scalar_product (kihat, pCyl->axis));
 thetai		= acos (-kilhat.x[2]);
 if (fabs(thetai) > FLT_EPSILON) {
  cti		= cos(thetai);
  sti		= sin(thetai);
  phii		= atan2 (kilhat.x[1],kilhat.x[0]);
  cpi		= cos(phii);
  spi		= sin(phii);
  kshat		= d3Vector_normalise (*pki);
  kslhat	= Cartesian_Assign_d3Vector (d3Vector_scalar_product (kshat, pCyl->x), d3Vector_scalar_product (kshat, pCyl->y), d3Vector_scalar_product (kshat, pCyl->axis));
  thetas	= kslhat.theta;
  cts		= cos(thetas);
  sts		= sin(thetas);
  phis		= kslhat.phi;
  cps		= cos(phis);
  sps		= sin(phis);
  k			= pki->r;
  a			= pCyl->radius;
  h			= pCyl->length/2.0;
  vi		= k*a*sti;
  if (fabs(vi)<DBL_EPSILON) {
   if (vi<0.0) {
    vi		= -DBL_EPSILON;
   } else {
    vi		=  DBL_EPSILON;
   }
  }
  vs		= k*a*sts;
  mu		= Sinc (k*h*(cts+cti));
  er		= xy_complex	(fabs(pCyl->permittivity.x), -fabs(pCyl->permittivity.y));
  w1		= xy_complex	(er.x-cti*cti, er.y);
  u			= complex_rmul	(complex_sqrt (w1), k*a);
  a2		= xy_complex	(a*a, 0.0);
  u2		= complex_mul	(u, u);
  vs2		= xy_complex	(vs*vs, 0.0);
  zs_factor	= complex_div	(a2, complex_sub (u2, vs2));
  cvs		= xy_complex	(vs, 0.0);
  Jlookup (vi, INFCYL_TERMS+2, pJ, pJtable);
  Ylookup (vi, INFCYL_TERMS+2, pY, pYtable, pJtable);
  vi_u		= complex_div (xy_complex (vi, 0.0), u);
  u_vi		= complex_div (u, xy_complex (vi, 0.0));
  for (n=0;n<=INFCYL_TERMS; n++) {
   Jn_u		= Jn (u, n);
   w1		= complex_mul	(u, complex_mul (Jn (cvs, n), Jn (u, n+1)));
   w1		= complex_sub	(w1, complex_rmul (complex_mul (Jn_u, Jn (cvs, n+1)), vs));
   KFAz[n]	= complex_mul	(w1, zs_factor);
   Jnp_u	= dJndz (u, n);
   Hn_vi	= xy_complex	(pJ[n], -pY[n]);
   if (n == 0) {
    Hnp_vi	= xy_complex	(pJ[1], -pY[1]);
    Hnp_vi	= complex_rmul	(Hnp_vi, -1.0);
   } else {
    w1		= xy_complex	(pJ[n+1], -pY[n+1]);
    w2		= xy_complex	(pJ[n-1], -pY[n-1]);
	Hnp_vi	= complex_rmul	(complex_sub (w2, w1), 0.5);
   }
   z1		= complex_mul	(u, complex_mul (Jn_u, Hnp_vi));
   z2		= complex_rmul	(complex_mul (Hn_vi, Jnp_u) ,vi);
   wn1		= complex_sub	(z1, z2);
   wn2		= complex_sub	(z1, complex_mul (er, z2));
   wn3		= complex_rmul	(complex_mul (complex_mul (Hn_vi, Jn_u), complex_sub (u_vi, vi_u)), n*cti);
   Gn		= complex_rmul	(complex_mul (vi_u, complex_sub (complex_mul (wn1, wn2), complex_mul (wn3, wn3))), 0.5*DPI_RAD);
   z2		= complex_div	(xy_complex (sti, 0.0), Gn);
   KFAev[n]	= complex_mul	(complex_mul (jay, z2), wn1);
   KFAhh[n]	= complex_mul	(complex_mul (jay, z2), wn2);
   KFAhv[n]	= complex_mul	(z2, wn3);
   KFAeh[n]	= complex_rmul	(KFAhv[n], -1.0);
  }
  k_2lamdai	=  complex_div (xy_complex (0.5, 0.0), complex_sqrt (xy_complex(er.x-cti*cti, er.y)));
  Zero_Complex (&(KFAA[0]));
  KFAB[0]	= complex_rmul (complex_mul (KFAz[1], k_2lamdai), 2.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   KFAA[n]	= complex_mul (complex_sub (KFAz[n-1], KFAz[n+1]), k_2lamdai);
   KFAB[n]	= complex_mul (complex_add (KFAz[n-1], KFAz[n+1]), k_2lamdai);
  }
  s_factor	= xy_complex	(er.x-1.0, er.y);
  s_factor	= complex_rmul	(s_factor, 2.0*k*k*h*mu);
  fhh		= complex_rmul	(complex_mul (KFAB[0], KFAhh[0]),0.5);
  for (n=1;n<INFCYL_TERMS; n++) {
   fhhn		= complex_mul	(KFAB[n], KFAhh[n]);
   fhhn		= complex_add	(fhhn, complex_rmul (complex_mul (jay, complex_mul (KFAA[n], KFAeh[n])), cti));
   fhhn		= complex_rmul	(fhhn, cos(n*(phis-phii)));
   fhh		= complex_add	(fhh, fhhn);
  }
  fhh		= complex_mul	(fhh, s_factor);
  fvv		= complex_rmul	(complex_mul (KFAB[0], KFAev[0]), cti*cts);
  fvv		= complex_sub	(fvv, complex_rmul (complex_mul (KFAz[0], KFAev[0]), sts));
  fvv		= complex_rmul	(fvv, 0.5);
  for (n=1;n<INFCYL_TERMS; n++) {
   fvvn		= complex_rmul	(complex_mul (KFAB[n], KFAev[n]), cti);
   fvvn		= complex_sub	(fvvn, complex_mul (jay, complex_mul (KFAA[n], KFAhv[n])));
   fvvn		= complex_rmul	(fvvn, cts);
   fvvn		= complex_sub	(fvvn, complex_rmul (complex_mul (KFAz[n], KFAev[n]), sts));
   fvvn		= complex_rmul	(fvvn, cos(n*(phis-phii)));
   fvv		= complex_add	(fvv, fvvn);
  }
  fvv		= complex_mul	(fvv, s_factor);
  fvh		= xy_complex (0.0, 0.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   fvhn		= complex_rmul	(complex_mul (KFAB[n], KFAeh[n]), cti);
   fvhn		= complex_sub	(fvhn, complex_mul (jay, complex_mul (KFAA[n], KFAhh[n])));
   fvhn		= complex_rmul	(fvhn, cts);
   fvhn		= complex_sub	(fvhn, complex_rmul (complex_mul (KFAz[n], KFAeh[n]), sts));
   fvhn		= complex_rmul	(fvhn, sin(n*(phis-phii)));
   fvh		= complex_add	(fvh, fvhn);
  }
  fvh		= complex_mul	(fvh, complex_mul (jay, s_factor));
  fhv		= xy_complex	(0.0, 0.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   fhvn		= complex_mul	(KFAB[n], KFAhv[n]);
   fhvn		= complex_add	(fhvn, complex_rmul (complex_mul (jay, complex_mul (KFAA[n], KFAev[n])), cti));
   fhvn		= complex_rmul	(fhvn, sin(n*(phis-phii)));
   fhv		= complex_add	(fhv, fhvn);
  }
  fhv		= complex_mul	(fhv, complex_mul (jay, s_factor));
  xl		= Assign_c3Vector (xy_complex (pCyl->x.x[0], 0.0),    xy_complex (pCyl->x.x[1], 0.0),    xy_complex (pCyl->x.x[2], 0.0));
  yl		= Assign_c3Vector (xy_complex (pCyl->y.x[0], 0.0),    xy_complex (pCyl->y.x[1], 0.0),    xy_complex (pCyl->y.x[2], 0.0));
  zl		= Assign_c3Vector (xy_complex (pCyl->axis.x[0], 0.0), xy_complex (pCyl->axis.x[1], 0.0), xy_complex (pCyl->axis.x[2], 0.0));
  mod_fvv	= complex_modulus (fvv);
  arg_fhh	= complex_argument (fhh);
  Polar_Assign_Complex (&fvv, mod_fvv, arg_fhh);
  G			= xy_complex(k*k/(4.0*DPI_RAD), 0.0);
  P			= complex_div (fhh, G);
  Pz		= complex_sub (fvv, complex_rmul (fhh, cti*cti));
  Pz		= complex_div (Pz, complex_rmul (G, sti*sti));
  P			= xy_complex (fabs(P.x),  fabs(P.y));
  Pz		= xy_complex (fabs(Pz.x), fabs(Pz.y));
  S			= c33Matrix_Complex_product (c3Vector_dyadic_product (xl,xl), P);
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (yl, yl), P));
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (zl, zl), Pz));
  ckshat	= Assign_c3Vector (xy_complex (kshat.x[0], 0.0), xy_complex (kshat.x[1], 0.0), xy_complex (kshat.x[2], 0.0));
  Iksks		= c33Matrix_difference (Idem_c33Matrix (), c3Vector_dyadic_product (ckshat, ckshat));
  S			= c33Matrix_product (Iksks, S);
 } 
 return (S);
}

/***/

c33Matrix InfCylSav3	(Cylinder *pCyl, d3Vector *pks, d3Vector *pki, Yn_Lookup *pYtable, Jn_Lookup *pJtable,
						Complex *Shhl, Complex *Shvl, Complex *Svhl, Complex *Svvl)
{
 c33Matrix		S	= Zero_c33Matrix ();
 d3Vector		kihat, kilhat;
 double			thetai,phii,cti,sti,cpi,spi;
 d3Vector		kshat, kslhat;
 double			thetas,phis,cts,sts,cps,sps;
 double			k, a, h, vi, vs, mu;
 Complex		u, w1, w2;
 Complex		a2, u2, vs2, zs_factor, cvs;
 Complex		Jn_u, Jnp_u;
 Complex		Hn_vi, Hnp_vi;
 Complex		wn1, wn2, wn3, vi_u, u_vi;
 Complex		Gn;
 int			n;
 double			pY		[INFCYL_TERMS+3];
 double			pJ		[INFCYL_TERMS+3];
 Complex		KFAev	[INFCYL_TERMS+1];
 Complex		KFAhv	[INFCYL_TERMS+1];
 Complex		KFAeh	[INFCYL_TERMS+1];
 Complex		KFAhh	[INFCYL_TERMS+1];
 Complex		KFAz	[INFCYL_TERMS+1];
 Complex		k_2lamdai;
 Complex		KFAA	[INFCYL_TERMS+1];
 Complex		KFAB	[INFCYL_TERMS+1];
 Complex		er;
 Complex		z1, z2;
 Complex		fhh, fhv, fvh, fvv;
 Complex		fhhn, fhvn, fvhn, fvvn;
 Complex		s_factor;
 c3Vector		hil, vil, hsl, vsl;
 c3Vector		xl, yl, zl;
 double			mod_fhh, mod_fhv, mod_fvh, mod_fvv, arg_fhh;
 const Complex	jay	= xy_complex (0.0, 1.0);

 kihat		= d3Vector_normalise (*pki);
 kilhat		= Cartesian_Assign_d3Vector (d3Vector_scalar_product (kihat, pCyl->x), d3Vector_scalar_product (kihat, pCyl->y), d3Vector_scalar_product (kihat, pCyl->axis));
 thetai		= acos (-kilhat.x[2]);
 if (fabs(thetai) > FLT_EPSILON) {
  cti		= cos(thetai);
  sti		= sin(thetai);
  phii		= atan2 (kilhat.x[1],kilhat.x[0]);
  cpi		= cos(phii);
  spi		= sin(phii);
  kshat		= d3Vector_normalise (*pks);
  kslhat	= Cartesian_Assign_d3Vector (d3Vector_scalar_product (kshat, pCyl->x), d3Vector_scalar_product (kshat, pCyl->y), d3Vector_scalar_product (kshat, pCyl->axis));
  thetas	= kslhat.theta;
  cts		= cos(thetas);
  sts		= sin(thetas);
  phis		= kslhat.phi;
  cps		= cos(phis);
  sps		= sin(phis);
  k			= pki->r;
  a			= pCyl->radius;
  h			= pCyl->length/2.0;
  vi		= k*a*sti;
  if (fabs(vi)<DBL_EPSILON) {
   if (vi<0.0) {
    vi		= -DBL_EPSILON;
   } else {
    vi		=  DBL_EPSILON;
   }
  }
  vs		= k*a*sts;
  mu		= Sinc (k*h*(cts+cti));
  er		= xy_complex	(fabs(pCyl->permittivity.x), -fabs(pCyl->permittivity.y));
  w1		= xy_complex	(er.x-cti*cti, er.y);
  u			= complex_rmul	(complex_sqrt (w1), k*a);
  a2		= xy_complex	(a*a, 0.0);
  u2		= complex_mul	(u, u);
  vs2		= xy_complex	(vs*vs, 0.0);
  zs_factor	= complex_div	(a2, complex_sub (u2, vs2));
  cvs		= xy_complex	(vs, 0.0);
  Jlookup (vi, INFCYL_TERMS+2, pJ, pJtable);
  Ylookup (vi, INFCYL_TERMS+2, pY, pYtable, pJtable);
  vi_u		= complex_div (xy_complex (vi, 0.0), u);
  u_vi		= complex_div (u, xy_complex (vi, 0.0));
  for (n=0;n<=INFCYL_TERMS; n++) {
   Jn_u		= Jn (u, n);
   w1		= complex_mul	(u, complex_mul (Jn (cvs, n), Jn (u, n+1)));
   w1		= complex_sub	(w1, complex_rmul (complex_mul (Jn_u, Jn (cvs, n+1)), vs));
   KFAz[n]	= complex_mul	(w1, zs_factor);
   Jnp_u	= dJndz (u, n);
   Hn_vi	= xy_complex	(pJ[n], -pY[n]);
   if (n == 0) {
    Hnp_vi	= xy_complex	(pJ[1], -pY[1]);
    Hnp_vi	= complex_rmul	(Hnp_vi, -1.0);
   } else {
    w1		= xy_complex	(pJ[n+1], -pY[n+1]);
    w2		= xy_complex	(pJ[n-1], -pY[n-1]);
	Hnp_vi	= complex_rmul	(complex_sub (w2, w1), 0.5);
   }
   z1		= complex_mul	(u, complex_mul (Jn_u, Hnp_vi));
   z2		= complex_rmul	(complex_mul (Hn_vi, Jnp_u) ,vi);
   wn1		= complex_sub	(z1, z2);
   wn2		= complex_sub	(z1, complex_mul (er, z2));
   wn3		= complex_rmul	(complex_mul (complex_mul (Hn_vi, Jn_u), complex_sub (u_vi, vi_u)), n*cti);
   Gn		= complex_rmul	(complex_mul (vi_u, complex_sub (complex_mul (wn1, wn2), complex_mul (wn3, wn3))), 0.5*DPI_RAD);
   z2		= complex_div	(xy_complex (sti, 0.0), Gn);
   KFAev[n]	= complex_mul	(complex_mul (jay, z2), wn1);
   KFAhh[n]	= complex_mul	(complex_mul (jay, z2), wn2);
   KFAhv[n]	= complex_mul	(z2, wn3);
   KFAeh[n]	= complex_rmul	(KFAhv[n], -1.0);
  }
  k_2lamdai	=  complex_div (xy_complex (0.5, 0.0), complex_sqrt (xy_complex(er.x-cti*cti, er.y)));
  Zero_Complex (&(KFAA[0]));
  KFAB[0]	= complex_rmul (complex_mul (KFAz[1], k_2lamdai), 2.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   KFAA[n]	= complex_mul (complex_sub (KFAz[n-1], KFAz[n+1]), k_2lamdai);
   KFAB[n]	= complex_mul (complex_add (KFAz[n-1], KFAz[n+1]), k_2lamdai);
  }
  s_factor	= xy_complex	(er.x-1.0, er.y);
  s_factor	= complex_rmul	(s_factor, 4.0*SQRT_DPI_RAD*k*k*h*mu);
  fhh		= complex_rmul	(complex_mul (KFAB[0], KFAhh[0]),0.5);
  for (n=1;n<INFCYL_TERMS; n++) {
   fhhn		= complex_mul	(KFAB[n], KFAhh[n]);
   fhhn		= complex_add	(fhhn, complex_rmul (complex_mul (jay, complex_mul (KFAA[n], KFAeh[n])), cti));
   fhhn		= complex_rmul	(fhhn, cos(n*(phis-phii)));
   fhh		= complex_add	(fhh, fhhn);
  }
  fhh		= complex_mul	(fhh, s_factor);
  fvv		= complex_rmul	(complex_mul (KFAB[0], KFAev[0]), cti*cts);
  fvv		= complex_sub	(fvv, complex_rmul (complex_mul (KFAz[0], KFAev[0]), sts));
  fvv		= complex_rmul	(fvv, 0.5);
  for (n=1;n<INFCYL_TERMS; n++) {
   fvvn		= complex_rmul	(complex_mul (KFAB[n], KFAev[n]), cti);
   fvvn		= complex_sub	(fvvn, complex_mul (jay, complex_mul (KFAA[n], KFAhv[n])));
   fvvn		= complex_rmul	(fvvn, cts);
   fvvn		= complex_sub	(fvvn, complex_rmul (complex_mul (KFAz[n], KFAev[n]), sts));
   fvvn		= complex_rmul	(fvvn, cos(n*(phis-phii)));
   fvv		= complex_add	(fvv, fvvn);
  }
  fvv		= complex_mul	(fvv, s_factor);
  fvh		= xy_complex (0.0, 0.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   fvhn		= complex_rmul	(complex_mul (KFAB[n], KFAeh[n]), cti);
   fvhn		= complex_sub	(fvhn, complex_mul (jay, complex_mul (KFAA[n], KFAhh[n])));
   fvhn		= complex_rmul	(fvhn, cts);
   fvhn		= complex_sub	(fvhn, complex_rmul (complex_mul (KFAz[n], KFAeh[n]), sts));
   fvhn		= complex_rmul	(fvhn, sin(n*(phis-phii)));
   fvh		= complex_add	(fvh, fvhn);
  }
  fvh		= complex_mul	(fvh, complex_mul (jay, s_factor));
  fhv		= xy_complex	(0.0, 0.0);
  for (n=1;n<INFCYL_TERMS; n++) {
   fhvn		= complex_mul	(KFAB[n], KFAhv[n]);
   fhvn		= complex_add	(fhvn, complex_rmul (complex_mul (jay, complex_mul (KFAA[n], KFAev[n])), cti));
   fhvn		= complex_rmul	(fhvn, sin(n*(phis-phii)));
   fhv		= complex_add	(fhv, fhvn);
  }
  fhv		= complex_mul	(fhv, complex_mul (jay, s_factor));
  xl		= Assign_c3Vector (xy_complex (pCyl->x.x[0], 0.0),    xy_complex (pCyl->x.x[1], 0.0),    xy_complex (pCyl->x.x[2], 0.0));
  yl		= Assign_c3Vector (xy_complex (pCyl->y.x[0], 0.0),    xy_complex (pCyl->y.x[1], 0.0),    xy_complex (pCyl->y.x[2], 0.0));
  zl		= Assign_c3Vector (xy_complex (pCyl->axis.x[0], 0.0), xy_complex (pCyl->axis.x[1], 0.0), xy_complex (pCyl->axis.x[2], 0.0));
  hil		= c3Vector_scalar_multiply (xl, xy_complex (-spi, 0.0));
  hil		= c3Vector_sum (hil, c3Vector_scalar_multiply (yl, xy_complex ( cpi, 0.0)));
  vil		= c3Vector_scalar_multiply (xl, xy_complex (-cti*cpi, 0.0));
  vil		= c3Vector_sum (vil, c3Vector_scalar_multiply (yl, xy_complex (-cti*spi, 0.0)));
  vil		= c3Vector_sum (vil, c3Vector_scalar_multiply (zl, xy_complex (-sti, 0.0)));
  hsl		= c3Vector_scalar_multiply (xl, xy_complex (-sps, 0.0));
  hsl		= c3Vector_sum (hsl, c3Vector_scalar_multiply (yl, xy_complex ( cps, 0.0)));
  vsl		= c3Vector_scalar_multiply (xl, xy_complex (cts*cps, 0.0));
  vsl		= c3Vector_sum (vsl, c3Vector_scalar_multiply (yl, xy_complex (cts*sps, 0.0)));
  vsl		= c3Vector_sum (vsl, c3Vector_scalar_multiply (zl, xy_complex (-sts, 0.0)));
  mod_fvv	= complex_modulus (fvv);
  mod_fhh	= complex_modulus (fhh);
  mod_fhv	= complex_modulus (fhv);
  mod_fvh	= complex_modulus (fvh);
  mod_fhv	= 0.5*(mod_fhv+mod_fvh);
  mod_fvh	= mod_fhv;
#ifdef INF_CYL_HH_PHASE
  arg_fhh	= complex_argument (fhh);
#else
  Cartesian_Assign_Complex (&s_factor, er.x-1.0, er.y);
  arg_fhh	= complex_argument (s_factor);
#endif
#ifdef INF_CYL_POL_CORR
  Polar_Assign_Complex (&fhh, mod_fhh,  arg_fhh);
  Polar_Assign_Complex (&fhv, mod_fhv,  arg_fhh);
  Polar_Assign_Complex (&fvv, mod_fvv,  DPI_RAD+arg_fhh);
  Polar_Assign_Complex (&fvh, mod_fvh,  DPI_RAD+arg_fhh);
#endif
#ifdef INF_CYL_ZERO_LOCAL_XPOL
  fhv		= xy_complex (0.0, 0.0);
  fvh		= xy_complex (0.0, 0.0);
#endif
  S			= c33Matrix_Complex_product (c3Vector_dyadic_product (vsl,vil), fvv);
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (vsl, hil), fvh));
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (hsl, vil), fhv));
  S			= c33Matrix_sum  (S, c33Matrix_Complex_product (c3Vector_dyadic_product (hsl, hil), fhh));
  *Shhl		= Copy_Complex (&fhh);
  *Shvl		= Copy_Complex (&fhv);
  *Svhl		= Copy_Complex (&fvh);
  *Svvl		= Copy_Complex (&fvv);
 } 
 return (S);
}

/***/


