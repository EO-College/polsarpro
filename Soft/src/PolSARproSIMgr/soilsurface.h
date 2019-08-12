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
 * Module      : soilsurface.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __SOILSURFACE_H__
#define __SOILSURFACE_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

#include	"Complex.h"
#include	"Trig.h"

#define		WATER_ZERO			80.1
#define		WATER_INF			4.90
#define		WATER_TAU			9.230986699e-12
#define		TF0					7.5
#define		DTF0				2.5

Complex	water_permittivity		(double freq);
Complex ground_permittivity		(double dd, double mpf, double sand, double clay, double mv, double freq);
double  monostatic_soil_sigma0HH (double theta, Complex eps, double k, double rmsh, double clen);
double  monostatic_soil_sigma0VV (double theta, Complex eps, double k, double rmsh, double clen);

#endif
