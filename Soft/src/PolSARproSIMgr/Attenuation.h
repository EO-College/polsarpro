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
 * Module      : Attenuation.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#ifndef __ATTENUATION_H__
#define __ATTENUATION_H__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include	"c33Matrix.h"
#include	"c3Vector.h"
#include	"Complex.h"
#include	"d3Vector.h"
#include	"Jnz.h"
#include	"Leaf.h"
#include	"MonteCarlo.h"
#include	"PolSARproSim_Definitions.h"
#include	"Sinc.h"
#include	"Trig.h"

#define	POLSARPROSIM_DPOL_FACTOR_M	10

void		Leaf_Depolarization_Factors	(Leaf *pLeaf, double *pL1, double *pL2, double *pL3);
c33Matrix	Leaf_Polarisability			(Leaf *pLeaf, double L1, double L2, double L3);
#ifndef RAYLEIGH_LEAF
c33Matrix	Leaf_Scattering_Matrix		(Leaf *pLeaf, double L1, double L2, double L3, d3Vector *p_ki, d3Vector *p_ks);
#else
c33Matrix	Leaf_Scattering_Matrix		(Leaf *pLeaf, double L1, double L2, double L3, d3Vector *p_ki);
#endif

#endif
