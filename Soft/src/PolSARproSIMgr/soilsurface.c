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
 * Module      : soilsurface.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include "soilsurface.h"

Complex	water_permittivity	(double freq)
{
 double			wtau		= 1.0e+09*WATER_TAU;
 double			tpftw		= 2.0*DPI_RAD*freq*wtau;
 double			ewp			= WATER_INF + (WATER_ZERO-WATER_INF)/(1.0+tpftw*tpftw);
 double			ewpp		= tpftw*(WATER_ZERO-WATER_INF)/(1.0+tpftw*tpftw);
 Complex		eps_water	= xy_complex (ewp, ewpp);
 return	(eps_water);
}

Complex ground_permittivity (double ros, double mpf, double sand, double clay, double mv, double freq)
{
 /***************************************************/
 /* Following Paplinski et al. (1995) 0.3GHz-1.3GHz */
 /***************************************************/
 const double	alpha		= 0.65;
 const double	eps_0		= 8.854e-3;
 double			rob			= mpf*(1.0-mv)*ros + mv;
 double			bp			= 1.27480 - 0.519*sand - 0.152*clay;
 double			bpp			= 1.33797 - 0.603*sand - 0.166*clay;
 double			eps_w0		= WATER_ZERO;
 double			eps_winf	= WATER_INF;
 double			wtau		= 1.0e+09*WATER_TAU;
 double			sig_eff		= 0.0467 + 0.2204*rob - 0.4111*sand + 0.6614*clay;
 double			tpftw		= 2.0*DPI_RAD*freq*wtau;
 double			ewp			= eps_winf + (eps_w0-eps_winf)/(1.0+tpftw*tpftw);
 double			ewpp		= tpftw*(eps_w0-eps_winf)/(1.0+tpftw*tpftw) 
							+ sig_eff*(ros-rob)/(ros*mv*2.0*DPI_RAD*freq*eps_0);
 double			eps_s		= (1.01+0.44*ros)*(1.01+0.44*ros)-0.062;
 double			d1			= 1.0 + (rob/ros)*(pow(eps_s, alpha)-1.0) 
							+ pow(mv, bp)*pow(ewp, alpha) - mv;
 double			emp			= pow(d1, 1.0/alpha);
 double			empp		= pow(mv, bpp/alpha)*ewpp;
 Complex		eps_ground	= xy_complex (1.15*emp-0.68, -empp);
 return	(eps_ground);
}

double  monostatic_soil_sigma0HH (double theta, Complex eps, double k, double rmsh, double clen)
{
 double		cth		 = cos(theta);
 double		sth		 = sin(theta);
 Complex	w		 = complex_add	(complex_sqrt (xy_complex (eps.x-sth*sth, eps.y)), xy_complex (cth, 0.0));
 Complex	u		 = xy_complex	(1.0-eps.x, -eps.y);
 Complex	z		 = complex_div	(u, complex_mul (w, w));
 double		x		 = 4.0*cth*cth*cth*cth*exp(-k*k*sth*sth*clen*clen);
 Complex	v		 = complex_rmul	(complex_mul (z, complex_conjugate (z)), x);
 double		s		 = k*k*rmsh*clen;
			s		*= s*v.x;
 return (s);
}

double  monostatic_soil_sigma0VV (double theta, Complex eps, double k, double rmsh, double clen)
{
 double		cth		 = cos(theta);
 double		sth		 = sin(theta);
 Complex	u		 = complex_sqrt	(xy_complex (eps.x-sth*sth, eps.y));
 Complex	v		 = complex_add	(complex_rmul (eps, cth), u);
 Complex	w		 = complex_mul	(xy_complex (eps.x-1.0, eps.y), complex_add (complex_rmul (eps, sth*sth), complex_mul (u, u)));
 Complex	z		 = complex_div	(w, complex_mul (v, v));
 Complex	y		 = complex_rmul	(complex_mul (z, complex_conjugate (z)), 4.0*cth*cth*cth*cth*exp(-k*k*sth*sth*clen*clen));
 double		s		 = k*k*rmsh*clen;
			s		*= s*y.x;
 return (s);
}



