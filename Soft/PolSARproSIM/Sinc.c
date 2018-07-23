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
 * Module      : Sinc.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Implementation for sin(x)/x
 */
#include "Sinc.h"

double Sinc (double x)
{
 double	s;

 if (fabs(x) < DBL_EPSILON) {
  s	= 1.0-x*x/6.0;
 } else {
  s	= sin(x)/x;
 }
 return (s);
}

double SincJ1 (double x)
{
 Complex	z;
 Complex	J1;
 double		sj1;

 Cartesian_Assign_Complex (&z, x, 0.0);
 J1	= Jn (z, 1);

 if (fabs(x) < DBL_EPSILON) {
  sj1	= 1.0;
 } else {
  sj1	= 2.0*J1.x/x;
 }
 return (sj1);
}

