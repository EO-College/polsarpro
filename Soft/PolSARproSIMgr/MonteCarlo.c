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
 * Module      : MonteCarlo.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"MonteCarlo.h"

double		drand			(void)
{
 double	r = (double) rand();
 return (r/ (double) RAND_MAX);
}

double		Gaussian_drand			(double a_bar, double a_std, double a_min, double a_max)
{
 double	x		= Normal_Distribution ();
 double	xmin	= (a_min-a_bar)/a_std;
 double	xmax	= (a_max-a_bar)/a_std;
 while ((x>xmax) || (x<xmin)) {
  x		= Normal_Distribution ();
 }
 return ((x*a_std) + a_bar);
}

double Normal_Distribution   (void)
{
 double g = 0.0;
 int i;
 for (i=0;i<12;i++) {
  g += drand();
 }
 return (g-6.0);
}

double erand (double x)
{
 double r	= 0.0;
 double y;
 while (r < FLT_EPSILON) {
  r = drand();
 }
 y = -x*log(r);
 return (y);
}
