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
 * Module      : Allometrics.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"Allometrics.h"

/***********************************/
/* Tree allometric implementations */
/***********************************/

int			Number_of_Secondaries			(int species, double primary_length)
{
 int		Ns;
 double		m, C;
 switch (species) {
  case POLSARPROSIM_HEDGE:			m	= 0.0; 
									C	= 0.0;	break;
  case POLSARPROSIM_PINE001:		m	= POLSARPROSIM_PINE001_MNS;
									C	= POLSARPROSIM_PINE001_CNS; break;
  case POLSARPROSIM_PINE002:		m	= POLSARPROSIM_PINE001_MNS;
									C	= POLSARPROSIM_PINE001_CNS; break;
  case POLSARPROSIM_PINE003:		m	= POLSARPROSIM_PINE001_MNS;
									C	= POLSARPROSIM_PINE001_CNS; break;
  case POLSARPROSIM_DECIDUOUS001:	m	= POLSARPROSIM_DECIDUOUS001_SECONDARY_LAYER_DENSITY*POLSARPROSIM_DECIDUOUS001_SECONDARY_AVG_SECTIONS;
									C	= 0.0;	break;
  default:							m	= 0.0; 
									C	= 0.0;	break;
 }
 Ns			= (int) (m*primary_length + C);
 if (Ns < 0) Ns = 0;
 return		(Ns);
}

double		Primary_Minimum_Polar_Angle	(int species, double height)
{
 double		ThetaMin;
 double		a, b, c, d;
 switch (species) {
  case POLSARPROSIM_HEDGE:			a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  case POLSARPROSIM_PINE001:		a	= POLSARPROSIM_PINE001_FPMN0;
									b	= POLSARPROSIM_PINE001_DFPMN;
									c	= POLSARPROSIM_PINE001_HFPMN;
									d	= POLSARPROSIM_PINE001_DHFPMN; break;
  case POLSARPROSIM_PINE002:		a	= POLSARPROSIM_PINE001_FPMN0;
									b	= POLSARPROSIM_PINE001_DFPMN;
									c	= POLSARPROSIM_PINE001_HFPMN;
									d	= POLSARPROSIM_PINE001_DHFPMN; break;
  case POLSARPROSIM_PINE003:		a	= POLSARPROSIM_PINE001_FPMN0;
									b	= POLSARPROSIM_PINE001_DFPMN;
									c	= POLSARPROSIM_PINE001_HFPMN;
									d	= POLSARPROSIM_PINE001_DHFPMN; break;
  case POLSARPROSIM_DECIDUOUS001:	a	= POLSARPROSIM_DECIDUOUS001_PRIMARY_MAX_POLAR_ANGLE - 2.0*POLSARPROSIM_DECIDUOUS001_PRIMARY_DLT_POLAR_ANGLE;
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  default:							a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
 }
 ThetaMin		 = a + b*(1.0 + tanh((height - c)/d));
 ThetaMin		*= DPI_RAD/DPI_DEG;
 return (ThetaMin);
}

double		Primary_Maximum_Polar_Angle	(int species, double height)
{
 double		ThetaMax;
 double		a, b, c, d;
 switch (species) {
  case POLSARPROSIM_HEDGE:			a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  case POLSARPROSIM_PINE001:		a	= POLSARPROSIM_PINE001_FPMX0;
									b	= POLSARPROSIM_PINE001_DFPMX;
									c	= POLSARPROSIM_PINE001_HFPMX;
									d	= POLSARPROSIM_PINE001_DHFPMX; break;
  case POLSARPROSIM_PINE002:		a	= POLSARPROSIM_PINE001_FPMX0;
									b	= POLSARPROSIM_PINE001_DFPMX;
									c	= POLSARPROSIM_PINE001_HFPMX;
									d	= POLSARPROSIM_PINE001_DHFPMX; break;
  case POLSARPROSIM_PINE003:		a	= POLSARPROSIM_PINE001_FPMX0;
									b	= POLSARPROSIM_PINE001_DFPMX;
									c	= POLSARPROSIM_PINE001_HFPMX;
									d	= POLSARPROSIM_PINE001_DHFPMX; break;
  case POLSARPROSIM_DECIDUOUS001:	a	= POLSARPROSIM_DECIDUOUS001_PRIMARY_MAX_POLAR_ANGLE;
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  default:							a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
 }
 ThetaMax		 = a + b*(1.0 + tanh((height - c)/d));
 ThetaMax		*= DPI_RAD/DPI_DEG;
 return (ThetaMax);
}

/***/

double		Crown_Fractional_Living_Depth	(int species, double height)
{
 double		fL;
 double		a, b, c, d;
 switch (species) {
  case POLSARPROSIM_HEDGE:			a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  case POLSARPROSIM_PINE001:		a	= POLSARPROSIM_PINE001_FL0;
									b	= POLSARPROSIM_PINE001_DFL;
									c	= POLSARPROSIM_PINE001_HFL;
									d	= POLSARPROSIM_PINE001_DHFL; break;
  case POLSARPROSIM_PINE002:		a	= POLSARPROSIM_PINE001_FL0;
									b	= POLSARPROSIM_PINE001_DFL;
									c	= POLSARPROSIM_PINE001_HFL;
									d	= POLSARPROSIM_PINE001_DHFL; break;
  case POLSARPROSIM_PINE003:		a	= POLSARPROSIM_PINE001_FL0;
									b	= POLSARPROSIM_PINE001_DFL;
									c	= POLSARPROSIM_PINE001_HFL;
									d	= POLSARPROSIM_PINE001_DHFL; break;
  case POLSARPROSIM_DECIDUOUS001:	a	= POLSARPROSIM_DECIDUOUS001_CROWN_ALPHA;
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  default:							a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
 }
 fL			= a + b*(1.0 + tanh((height - c)/d));
 return (fL);
}

double		Mean_Living_Crown_Depth			(int species, double height)
{
 double		a	= height * Crown_Fractional_Living_Depth (species, height);
 return (a);
}

double		Realise_Living_Crown_Depth		(int species, double height)
{
 double	a_bar	= Mean_Living_Crown_Depth (species, height);
 double	a_std	= TREE_STDDEV_FACTOR*a_bar;
 double	l		= 100.0*height;
 while (l > height) {
  l				= Gaussian_drand (a_bar, a_std, a_bar-a_std, a_bar+a_std);
 }
 return (l);
}

/***/

double		Crown_Fractional_Dry_Depth	(int species, double height)
{
 double		fD;
 double		a, b, c, d;
 switch (species) {
  case POLSARPROSIM_HEDGE:			a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  case POLSARPROSIM_PINE001:		a	= POLSARPROSIM_PINE001_FD0;
									b	= POLSARPROSIM_PINE001_DFD;
									c	= POLSARPROSIM_PINE001_HFD;
									d	= POLSARPROSIM_PINE001_DHFD; break;
  case POLSARPROSIM_PINE002:		a	= POLSARPROSIM_PINE001_FD0;
									b	= POLSARPROSIM_PINE001_DFD;
									c	= POLSARPROSIM_PINE001_HFD;
									d	= POLSARPROSIM_PINE001_DHFD; break;
  case POLSARPROSIM_PINE003:		a	= POLSARPROSIM_PINE001_FD0;
									b	= POLSARPROSIM_PINE001_DFD;
									c	= POLSARPROSIM_PINE001_HFD;
									d	= POLSARPROSIM_PINE001_DHFD; break;
  case POLSARPROSIM_DECIDUOUS001:	a	= 0.0;
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
  default:							a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	break;
 }
 fD			= a + b*(1.0 + tanh((height - c)/d));
 return (fD);
}

double		Mean_Dry_Crown_Depth			(int species, double height)
{
 double		depth	= 0.0;
 if (height > 23.0) {
  height	= 23.0;
 }
 depth		= height*Crown_Fractional_Dry_Depth (species, height)*(1.0-Crown_Fractional_Living_Depth (species, height));
 return		(depth);
}

double		Mean_Crown_Edge_Length			(int species, double height)
{
 double		R, L, E;
 R			= Mean_Tree_Crown_Radius (species, height);
 L			= Mean_Living_Crown_Depth (species, height);
 E			= sqrt (R*R+L*L);
 return (E);
}

double		Mean_Crown_Angle_Beta			(int species, double height)
{
 double		R, L, beta;
 R			= Mean_Tree_Crown_Radius (species, height);
 L			= Mean_Living_Crown_Depth (species, height);
 beta		= atan2 (R, L); 
 return (beta);
}

double		Crown_Fractional_Radius				(int species, double height)
{
 double		fR;
 double		a, b, c, d;
 double		t;
 switch (species) {
  case POLSARPROSIM_HEDGE:			a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;
									t	= POLSARPROSIM_HEDGE_TCRSCALE;			break;
  case POLSARPROSIM_PINE001:		a	= POLSARPROSIM_PINE001_FR0;
									b	= POLSARPROSIM_PINE001_DFR;
									c	= POLSARPROSIM_PINE001_HFR;
									d	= POLSARPROSIM_PINE001_DHFR;
									t	= POLSARPROSIM_PINE001_TCRSCALE;		break;
  case POLSARPROSIM_PINE002:		a	= POLSARPROSIM_PINE001_FR0;
									b	= POLSARPROSIM_PINE001_DFR;
									c	= POLSARPROSIM_PINE001_HFR;
									d	= POLSARPROSIM_PINE001_DHFR; 
									t	= POLSARPROSIM_PINE001_TCRSCALE;		break;
  case POLSARPROSIM_PINE003:		a	= POLSARPROSIM_PINE001_FR0;
									b	= POLSARPROSIM_PINE001_DFR;
									c	= POLSARPROSIM_PINE001_HFR;
									d	= POLSARPROSIM_PINE001_DHFR; 
									t	= POLSARPROSIM_PINE001_TCRSCALE;		break;
  case POLSARPROSIM_DECIDUOUS001:	a	= POLSARPROSIM_DECIDUOUS001_CROWN_ALPHA;
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	
									t	= POLSARPROSIM_DECIDUOUS001_TCRSCALE;	break;
  default:							a	= 0.0; 
									b	= 0.0;
									c	= 0.0;
									d	= 1.0;	
									t	= 1.0;									break;
 }
 fR			 = a + b*(1.0 + tanh((height - c)/d));
 fR			*= t;
 return (fR);
}

double		Mean_Tree_Crown_Radius				(int species, double height)
{
 double		a	= height * Crown_Fractional_Radius (species, height);
 return (a);
}

double		Realise_Tree_Crown_Radius			(int species, double height)
{
 double	a_bar	= Mean_Tree_Crown_Radius (species, height);
 double	a_std	= TREE_STDDEV_FACTOR*a_bar;
 return (Gaussian_drand (a_bar, a_std, a_bar-a_std, a_bar+a_std));
}

double		Realise_Tree_Height				(double mean_height)
{
 double h_std	= TREE_STDDEV_FACTOR*mean_height;
 double	h_max	= mean_height + h_std;
 double h_min	= mean_height - h_std;
 double	height	= Gaussian_drand (mean_height, h_std, h_min, h_max);
 return (height);
}

/************************************************************/
/************************************************************/

double		Stem_Start_Radius				(int species, double height)
{
 double		sr;
 switch (species) {
  case POLSARPROSIM_HEDGE:			sr			= POLSARPROSIM_HEDGE_STEM_RADIUS_FACTOR*height/100.0; break;
  case POLSARPROSIM_PINE001:		sr			= POLSARPROSIM_PINE001_STEM_RADIUS_FACTOR*height/100.0; break;
  case POLSARPROSIM_PINE002:		sr			= POLSARPROSIM_PINE002_STEM_RADIUS_FACTOR*height/100.0; break;
  case POLSARPROSIM_PINE003:		sr			= POLSARPROSIM_PINE003_STEM_RADIUS_FACTOR*height/100.0; break;
  case POLSARPROSIM_DECIDUOUS001:	sr			= POLSARPROSIM_DECIDUOUS001_STEM_RADIUS_FACTOR*height/100.0; break;
  default:							sr			= 0.5*height/100.0; break;
 }
 return (sr);
}

double		Stem_End_Radius					(int species, double height)
{
 double		er;
 switch (species) {
  case POLSARPROSIM_HEDGE:			er			= POLSARPROSIM_HEDGE_STEM_END_RADIUS_FACTOR*height/1000.0; break;
  case POLSARPROSIM_PINE001:		er			= POLSARPROSIM_PINE001_STEM_END_RADIUS_FACTOR*height/1000.0; break;
  case POLSARPROSIM_PINE002:		er			= POLSARPROSIM_PINE002_STEM_END_RADIUS_FACTOR*height/1000.0; break;
  case POLSARPROSIM_PINE003:		er			= POLSARPROSIM_PINE003_STEM_END_RADIUS_FACTOR*height/1000.0; break;
  case POLSARPROSIM_DECIDUOUS001:	er			= POLSARPROSIM_DECIDUOUS001_STEM_END_RADIUS_FACTOR*height/1000.0; break;
  default:							er			= 0.5*height/1000.0; break;

 }
 return (er);
}

d3Vector	Stem_Direction					(int species)
{
 d3Vector	z0	= Zero_d3Vector ();
 double		min_cospolar;
 double		theta;
 double		phi;
 switch (species) {
  case	POLSARPROSIM_HEDGE:			min_cospolar	= POLSARPROSIM_HEDGE_STEM_MIN_COS_POLAR; break;
  case	POLSARPROSIM_PINE001:		min_cospolar	= POLSARPROSIM_PINE001_STEM_MIN_COS_POLAR; break;
  case	POLSARPROSIM_PINE002:		min_cospolar	= POLSARPROSIM_PINE002_STEM_MIN_COS_POLAR; break;
  case	POLSARPROSIM_PINE003:		min_cospolar	= POLSARPROSIM_PINE003_STEM_MIN_COS_POLAR; break;
  case	POLSARPROSIM_DECIDUOUS001:	min_cospolar	= POLSARPROSIM_DECIDUOUS001_STEM_MIN_COS_POLAR; break;
  default:							min_cospolar	= 1.0 - FLT_EPSILON;
 }
 theta	= acos (min_cospolar + drand()*(1.0-min_cospolar));
 phi	= 2.0*DPI_RAD*drand();
 z0		=  Polar_Assign_d3Vector (1.0, theta, phi);
 return (z0);
}

double		Stem_Tropism_Factor				(int species)
{
 double	dp;
 switch (species) {
  case POLSARPROSIM_HEDGE:			dp	= 0.0; break;
  case POLSARPROSIM_PINE001:		dp	= 0.1; break;
  case POLSARPROSIM_PINE002:		dp	= 0.1; break;
  case POLSARPROSIM_PINE003:		dp	= 0.1; break;
  case POLSARPROSIM_DECIDUOUS001:	dp	= 0.2; break;
  default:							dp	= 0.0; break;
 }
 return (dp);
}

d3Vector	Stem_Tropism_Direction			(int species)
{
 d3Vector	p;
 switch (species) {
  case POLSARPROSIM_HEDGE:			p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE001:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE002:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE003:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_DECIDUOUS001:	p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  default:							p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
 }
 return (p);
}

double		Stem_Lamdacx					(int species)
{
 double		lamdacx;
 switch (species) {
  case POLSARPROSIM_HEDGE:			lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE001:		lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE002:		lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE003:		lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_DECIDUOUS001:	lamdacx	= 0.75 + 0.25*drand (); break;
  default:							lamdacx	= 0.50 + 0.50*drand (); break;
 }
 return (lamdacx);
}

double		Stem_Lamdacy					(int species)
{
 double		lamdacy;
 switch (species) {
  case POLSARPROSIM_HEDGE:			lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE001:		lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE002:		lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE003:		lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_DECIDUOUS001:	lamdacy	= 0.75 + 0.25*drand (); break;
  default:							lamdacy	= 0.50 + 0.50*drand (); break;
 }
 return (lamdacy);
}

double		Stem_Gamma						(int species)
{
 double		gamma;
 switch (species) {
  case POLSARPROSIM_HEDGE:			gamma	= 0.0; break;
  case POLSARPROSIM_PINE001:		gamma	= 0.01*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_PINE002:		gamma	= 0.01*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_PINE003:		gamma	= 0.01*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_DECIDUOUS001:	gamma	= 0.06*(0.75+0.25*drand ()); break;
  default:							gamma	= 0.01*(0.75+0.25*drand ()); break;
 }
 return (gamma);
}

double		Stem_Moisture					(int species)
{
 double		moisture;
 switch (species) {
  case POLSARPROSIM_HEDGE:			moisture	= POLSARPROSIM_HEDGE_STEM_MOISTURE; break;
  case POLSARPROSIM_PINE001:		moisture	= POLSARPROSIM_PINE001_STEM_MOISTURE + POLSARPROSIM_PINE001_STEM_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE002:		moisture	= POLSARPROSIM_PINE001_STEM_MOISTURE + POLSARPROSIM_PINE001_STEM_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE003:		moisture	= POLSARPROSIM_PINE001_STEM_MOISTURE + POLSARPROSIM_PINE001_STEM_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_DECIDUOUS001:	moisture	= POLSARPROSIM_DECIDUOUS001_STEM_MOISTURE + POLSARPROSIM_DECIDUOUS001_STEM_MOISTURE * 0.1* (drand ()-0.5); break;
  default:							moisture	= POLSARPROSIM_HEDGE_STEM_MOISTURE; break;
 }
 return (moisture);
}

Complex		vegetation_permittivity			(double moisture, double frequency)
{
 /*****************************************************/
 /* Following Ulaby and El-Rayes (1987) 0.3GHz-1.3GHz */
 /*****************************************************/
 double			eps_r		= 1.7 - 0.74*moisture + 6.16*moisture*moisture;
 double			vfw			= moisture*(0.55*moisture-0.076);
 double			vb			= 4.64*moisture*moisture/(1.0+7.36*moisture*moisture);
 double			g			= 0.0012*frequency*frequency+0.0019*frequency;
 Complex		eps_fw;
 Complex		eps_bw;
 Complex		er;
 eps_fw			= complex_div	(xy_complex (E0_FW-EPSINF_FW,0.0), xy_complex (1.0, frequency/F0_FW));
 eps_fw			= complex_add	(eps_fw, xy_complex (EPSINF_FW, -g*TWOPIE0_INV*SIGMA_FW/frequency));
 eps_bw			= complex_sqrt	(xy_complex (0.0, frequency/F0_BW));
 eps_bw			= complex_add	(xy_complex (1.0, 0.0), eps_bw);
 eps_bw			= complex_div	(xy_complex (E0_BW-EPSINF_BW, 0.0), eps_bw);
 eps_bw			= complex_add	(xy_complex (EPSINF_BW, 0.0), eps_bw);
 er				= complex_add	(xy_complex (eps_r, 0.0), complex_rmul(eps_fw, vfw));
 er				= complex_add	(er, complex_rmul (eps_bw, vb));
 return (er);
}

/*****************************/
/* Primary branch generation */
/*****************************/

double		Primary_Radius						(int species, double height, double t)
{
 double		R	= 0.0;
 double		A, B, C;
 double		sr0	= Stem_Start_Radius (species, height);
 switch (species) {
  case POLSARPROSIM_HEDGE:			A	=  -0.51523; break;
  case POLSARPROSIM_PINE001:		A	=  -0.51523; break;
  case POLSARPROSIM_PINE002:		A	=  -0.51523; break;
  case POLSARPROSIM_PINE003:		A	=  -0.51523; break;
  case POLSARPROSIM_DECIDUOUS001:	A	=  -0.51523; break;
  default:							A	=  -0.51523; break;
 }
 switch (species) {
  case POLSARPROSIM_HEDGE:			B	=  0.53288; break;
  case POLSARPROSIM_PINE001:		B	=  0.53288; break;
  case POLSARPROSIM_PINE002:		B	=  0.53288; break;
  case POLSARPROSIM_PINE003:		B	=  0.53288; break;
  case POLSARPROSIM_DECIDUOUS001:	B	=  0.53288; break;
  default:							B	=  0.53288; break;
 }
 switch (species) {
  case POLSARPROSIM_HEDGE:			C	=  0.038638; break;
  case POLSARPROSIM_PINE001:		C	=  0.038638; break;
  case POLSARPROSIM_PINE002:		C	=  0.038638; break;
  case POLSARPROSIM_PINE003:		C	=  0.038638; break;
  case POLSARPROSIM_DECIDUOUS001:	C	=  0.038638; break;
  default:							C	=  0.038638; break;
 }
 if (t<0.0) {
  t	= 0.0;
 } else {
  if (t>1.0) {
   t	= 1.0;
  }
 }
 R		= sr0*(A*t*t+B*t+C);
 return (R);
}

double		Primary_Tropism_Factor				(int species)
{
 double	dp;
 switch (species) {
  case POLSARPROSIM_HEDGE:			dp	=  0.0; break;
  case POLSARPROSIM_PINE001:		dp	=  0.3; break;
  case POLSARPROSIM_PINE002:		dp	=  0.3; break;
  case POLSARPROSIM_PINE003:		dp	=  0.3; break;
  case POLSARPROSIM_DECIDUOUS001:	dp	=  0.3; break;
  default:							dp	=  0.0; break;
 }
 return (dp);
}

d3Vector	Primary_Tropism_Direction			(int species)
{
 d3Vector	p;
 switch (species) {
  case POLSARPROSIM_HEDGE:			p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE001:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE002:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE003:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_DECIDUOUS001:	p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  default:							p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
 }
 return (p);
}

double		Primary_Lamdacx					(int species)
{
 double		lamdacx;
 switch (species) {
  case POLSARPROSIM_HEDGE:			lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE001:		lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE002:		lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE003:		lamdacx	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_DECIDUOUS001:	lamdacx	= 0.75 + 0.25*drand (); break;
  default:							lamdacx	= 0.75 + 0.25*drand (); break;
 }
 return (lamdacx);
}

double		Primary_Lamdacy					(int species)
{
 double		lamdacy;
 switch (species) {
  case POLSARPROSIM_HEDGE:			lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE001:		lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE002:		lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_PINE003:		lamdacy	= 0.75 + 0.25*drand (); break;
  case POLSARPROSIM_DECIDUOUS001:	lamdacy	= 0.75 + 0.25*drand (); break;
  default:							lamdacy	= 0.75 + 0.25*drand (); break;
 }
 return (lamdacy);
}

double		Primary_Gamma					(int species)
{
 double		gamma;
 switch (species) {
  case POLSARPROSIM_HEDGE:			gamma	= 0.0; break;
  case POLSARPROSIM_PINE001:		gamma	= 0.010*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_PINE002:		gamma	= 0.010*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_PINE003:		gamma	= 0.010*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_DECIDUOUS001:	gamma	= 0.120*(0.75+0.25*drand ()); break;
  default:							gamma	= 0.0; break;
 }
 return (gamma);
}

double		Primary_Moisture				(int species)
{
 double		moisture;
 switch (species) {
  case POLSARPROSIM_HEDGE:			moisture	= POLSARPROSIM_HEDGE_PRIMARY_MOISTURE; break;
  case POLSARPROSIM_PINE001:		moisture	= POLSARPROSIM_PINE001_PRIMARY_MOISTURE + POLSARPROSIM_PINE001_PRIMARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE002:		moisture	= POLSARPROSIM_PINE001_PRIMARY_MOISTURE + POLSARPROSIM_PINE001_PRIMARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE003:		moisture	= POLSARPROSIM_PINE001_PRIMARY_MOISTURE + POLSARPROSIM_PINE001_PRIMARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_DECIDUOUS001:	moisture	= POLSARPROSIM_DECIDUOUS001_PRIMARY_MOISTURE + POLSARPROSIM_DECIDUOUS001_PRIMARY_MOISTURE * 0.1* (drand ()-0.5); break;
  default:							moisture	= POLSARPROSIM_HEDGE_PRIMARY_MOISTURE; break;
 }
 return (moisture);
}

double		Primary_Dry_Moisture			(int species)
{
 double		moisture;
 switch (species) {
  case POLSARPROSIM_HEDGE:			moisture	= POLSARPROSIM_HEDGE_PRIMARY_DRY_MOISTURE; break;
  case POLSARPROSIM_PINE001:		moisture	= POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE + POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE002:		moisture	= POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE + POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE003:		moisture	= POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE + POLSARPROSIM_PINE001_PRIMARY_DRY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_DECIDUOUS001:	moisture	= POLSARPROSIM_DECIDUOUS001_PRIMARY_DRY_MOISTURE + POLSARPROSIM_DECIDUOUS001_PRIMARY_DRY_MOISTURE * 0.1* (drand ()-0.5); break;
  default:							moisture	= POLSARPROSIM_HEDGE_PRIMARY_DRY_MOISTURE; break;
 }
 return (moisture);
}

/*******************************/
/* Secondary branch generation */
/*******************************/

double		Secondary_Tropism_Factor		(int species)
{
 double	dp;
 switch (species) {
  case POLSARPROSIM_HEDGE:			dp	=  0.0; break;
  case POLSARPROSIM_PINE001:		dp	=  0.6; break;
  case POLSARPROSIM_PINE002:		dp	=  0.6; break;
  case POLSARPROSIM_PINE003:		dp	=  0.6; break;
  case POLSARPROSIM_DECIDUOUS001:	dp	=  0.6; break;
  default:							dp	=  0.0; break;
 }
 return (dp);
}

d3Vector	Secondary_Tropism_Direction		(int species)
{
 d3Vector	p;
 switch (species) {
  case POLSARPROSIM_HEDGE:			p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE001:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE002:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_PINE003:		p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  case POLSARPROSIM_DECIDUOUS001:	p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
  default:							p	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0); break;
 }
 return (p);
}

double		Secondary_Lamdacx				(int species)
{
 double		lamdacx;
 switch (species) {
  case POLSARPROSIM_HEDGE:			lamdacx	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_PINE001:		lamdacx	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_PINE002:		lamdacx	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_PINE003:		lamdacx	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_DECIDUOUS001:	lamdacx	= 0.25 + 0.75*drand (); break;
  default:							lamdacx	= 0.25 + 0.75*drand (); break;
 }
 return (lamdacx);
}

double		Secondary_Lamdacy				(int species)
{
 double		lamdacy;
 switch (species) {
  case POLSARPROSIM_HEDGE:			lamdacy	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_PINE001:		lamdacy	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_PINE002:		lamdacy	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_PINE003:		lamdacy	= 0.25 + 0.75*drand (); break;
  case POLSARPROSIM_DECIDUOUS001:	lamdacy	= 0.25 + 0.75*drand (); break;
  default:							lamdacy	= 0.25 + 0.75*drand (); break;
 }
 return (lamdacy);
}

double		Secondary_Gamma					(int species)
{
 double		gamma;
 switch (species) {
  case POLSARPROSIM_HEDGE:			gamma	= 0.0; break;
  case POLSARPROSIM_PINE001:		gamma	= 0.10*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_PINE002:		gamma	= 0.10*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_PINE003:		gamma	= 0.10*(0.75+0.25*drand ()); break;
  case POLSARPROSIM_DECIDUOUS001:	gamma	= 0.240*(0.75+0.25*drand ()); break;
  default:							gamma	= 0.0; break;
 }
 return (gamma);
}

double		Secondary_Moisture				(int species)
{
 double		moisture;
 switch (species) {
  case POLSARPROSIM_HEDGE:			moisture	= POLSARPROSIM_HEDGE_SECONDARY_MOISTURE; break;
  case POLSARPROSIM_PINE001:		moisture	= POLSARPROSIM_PINE001_SECONDARY_MOISTURE + POLSARPROSIM_PINE001_SECONDARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE002:		moisture	= POLSARPROSIM_PINE001_SECONDARY_MOISTURE + POLSARPROSIM_PINE001_SECONDARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE003:		moisture	= POLSARPROSIM_PINE001_SECONDARY_MOISTURE + POLSARPROSIM_PINE001_SECONDARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_DECIDUOUS001:	moisture	= POLSARPROSIM_DECIDUOUS001_SECONDARY_MOISTURE + POLSARPROSIM_DECIDUOUS001_SECONDARY_MOISTURE * 0.1* (drand ()-0.5); break;
  default:							moisture	= POLSARPROSIM_HEDGE_SECONDARY_MOISTURE; break;
 }
 return (moisture);
}

/*********************/
/* Tertiary elements */
/*********************/

double		Tertiary_Branch_Volume_Fraction	(int species)
{
 double		vf;
 switch (species) {
  case POLSARPROSIM_HEDGE:			vf	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_VOL_FRAC;			break;
  case POLSARPROSIM_PINE001:		vf	= POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC;		break;
  case POLSARPROSIM_PINE002:		vf	= POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC;		break;
  case POLSARPROSIM_PINE003:		vf	= POLSARPROSIM_PINE001_TERTIARY_BRANCH_VOL_FRAC;		break;
  case POLSARPROSIM_DECIDUOUS001:	vf	= POLSARPROSIM_DECIDUOUS001_TERTIARY_BRANCH_VOL_FRAC;	break;
  default:							vf	= 0.0; break;
 }
 return		(vf);
}

double		Tertiary_Branch_Moisture				(int species)
{
 double		moisture;
 switch (species) {
  case POLSARPROSIM_HEDGE:			moisture	= POLSARPROSIM_HEDGE_TERTIARY_MOISTURE; break;
  case POLSARPROSIM_PINE001:		moisture	= POLSARPROSIM_PINE001_TERTIARY_MOISTURE + POLSARPROSIM_PINE001_TERTIARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE002:		moisture	= POLSARPROSIM_PINE001_TERTIARY_MOISTURE + POLSARPROSIM_PINE001_TERTIARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE003:		moisture	= POLSARPROSIM_PINE001_TERTIARY_MOISTURE + POLSARPROSIM_PINE001_TERTIARY_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_DECIDUOUS001:	moisture	= POLSARPROSIM_DECIDUOUS001_TERTIARY_MOISTURE + POLSARPROSIM_DECIDUOUS001_TERTIARY_MOISTURE * 0.1* (drand ()-0.5); break;
  default:							moisture	= POLSARPROSIM_HEDGE_TERTIARY_MOISTURE; break;
 }
 return (moisture);
}

/***********/
/* Foliage */
/***********/

int			Leaf_Species			(int species)
{
 int Lspecies;
 switch (species) {
  case POLSARPROSIM_HEDGE:			Lspecies	= POLSARPROSIM_DECIDUOUS_LEAF;	break;
  case POLSARPROSIM_PINE001:		Lspecies	= POLSARPROSIM_PINE_NEEDLE;		break;
  case POLSARPROSIM_PINE002:		Lspecies	= POLSARPROSIM_PINE_NEEDLE;		break;
  case POLSARPROSIM_PINE003:		Lspecies	= POLSARPROSIM_PINE_NEEDLE;		break;
  case POLSARPROSIM_DECIDUOUS001:	Lspecies	= POLSARPROSIM_DECIDUOUS_LEAF;	break;
  default:							Lspecies	= POLSARPROSIM_NON_LEAF; break;
 }
 return (Lspecies);
}

double		Leaf_Volume_Fraction	(int species)
{
 double		vf;
 switch (species) {
  case POLSARPROSIM_HEDGE:			vf	= POLSARPROSIM_HEDGE_FOLIAGE_VOL_FRAC;			break;
  case POLSARPROSIM_PINE001:		vf	= POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC;		break;
  case POLSARPROSIM_PINE002:		vf	= POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC;		break;
  case POLSARPROSIM_PINE003:		vf	= POLSARPROSIM_PINE001_FOLIAGE_VOL_FRAC;		break;
  case POLSARPROSIM_DECIDUOUS001:	vf	= POLSARPROSIM_DECIDUOUS001_FOLIAGE_VOL_FRAC;	break;
  default:							vf	= 0.0; break;
 }
 return		(vf);
}

double		Leaf_Dimension_1				(int species)
{
 double		d1;
 switch (species) {
  case POLSARPROSIM_HEDGE:			d1	= POLSARPROSIM_HEDGE_FOLIAGE_D1;		break;
  case POLSARPROSIM_PINE001:		d1	= POLSARPROSIM_PINE001_FOLIAGE_D1;		break;
  case POLSARPROSIM_PINE002:		d1	= POLSARPROSIM_PINE001_FOLIAGE_D1;		break;
  case POLSARPROSIM_PINE003:		d1	= POLSARPROSIM_PINE001_FOLIAGE_D1;		break;
  case POLSARPROSIM_DECIDUOUS001:	d1	= POLSARPROSIM_DECIDUOUS001_FOLIAGE_D1;	break;
  default:							d1	= 0.0; break;
 }
 return		(d1);
}

double		Leaf_Dimension_2				(int species)
{
 double		d2;
 switch (species) {
  case POLSARPROSIM_HEDGE:			d2	= POLSARPROSIM_HEDGE_FOLIAGE_D2;		break;
  case POLSARPROSIM_PINE001:		d2	= POLSARPROSIM_PINE001_FOLIAGE_D2;		break;
  case POLSARPROSIM_PINE002:		d2	= POLSARPROSIM_PINE001_FOLIAGE_D2;		break;
  case POLSARPROSIM_PINE003:		d2	= POLSARPROSIM_PINE001_FOLIAGE_D2;		break;
  case POLSARPROSIM_DECIDUOUS001:	d2	= POLSARPROSIM_DECIDUOUS001_FOLIAGE_D2;	break;
  default:							d2	= 0.0; break;
 }
 return		(d2);
}

double		Leaf_Dimension_3				(int species)
{
 double		d3;
 switch (species) {
  case POLSARPROSIM_HEDGE:			d3	= POLSARPROSIM_HEDGE_FOLIAGE_D3;			break;
  case POLSARPROSIM_PINE001:		d3	= POLSARPROSIM_PINE001_FOLIAGE_D3;		break;
  case POLSARPROSIM_PINE002:		d3	= POLSARPROSIM_PINE001_FOLIAGE_D3;		break;
  case POLSARPROSIM_PINE003:		d3	= POLSARPROSIM_PINE001_FOLIAGE_D3;		break;
  case POLSARPROSIM_DECIDUOUS001:	d3	= POLSARPROSIM_DECIDUOUS001_FOLIAGE_D3;	break;
  default:							d3	= 0.0; break;
 }
 return		(d3);
}

double		Leaf_Moisture				(int species)
{
 double		moisture;
 switch (species) {
  case POLSARPROSIM_HEDGE:			moisture	= POLSARPROSIM_HEDGE_LEAF_MOISTURE; break;
  case POLSARPROSIM_PINE001:		moisture	= POLSARPROSIM_PINE001_LEAF_MOISTURE + POLSARPROSIM_PINE001_LEAF_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE002:		moisture	= POLSARPROSIM_PINE001_LEAF_MOISTURE + POLSARPROSIM_PINE001_LEAF_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_PINE003:		moisture	= POLSARPROSIM_PINE001_LEAF_MOISTURE + POLSARPROSIM_PINE001_LEAF_MOISTURE * 0.1* (drand ()-0.5); break;
  case POLSARPROSIM_DECIDUOUS001:	moisture	= POLSARPROSIM_DECIDUOUS001_LEAF_MOISTURE + POLSARPROSIM_DECIDUOUS001_LEAF_MOISTURE * 0.1* (drand ()-0.5); break;
  default:							moisture	= POLSARPROSIM_HEDGE_LEAF_MOISTURE; break;
 }
 return (moisture);
}
