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
 * Module      : InfCyl.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : inf. cylinder scattering amplitude
 */
#ifndef		__INFCYL_H__
#define		__INFCYL_H__

#include	"c33Matrix.h"
#include	"c3Vector.h"
#include	"Complex.h"
#include	"Cylinder.h"
#include	"d3Vector.h"
#include	"JLkp.h"
#include	"Jnz.h"
#include	"Sinc.h"
#include	"Trig.h"
#include	"YLkp.h"

  #define		INFCYL_TERMS		5				/* No. of terms to sum for truncated infinite cylinder scattering series	*/
  #define		INF_CYL_HH_PHASE					/* Adopt HH phase (or HH phase + PI) if making a polarimetric correction	*/
  #define		INF_CYL_POL_CORR					/* Make a polarimetric correction if defined								*/
/*#define		INF_CYL_ZERO_LOCAL_XPOL										*/
/* Local model follows GRG approximation									*/

c33Matrix	InfCylP		(Cylinder *pCyl, d3Vector *pki, Yn_Lookup *pYtable, Jn_Lookup *pJtable);
c33Matrix	InfCylSav2	(Cylinder *pCyl, d3Vector *pks, d3Vector *pki, Yn_Lookup *pYtable, Jn_Lookup *pJtable);
c33Matrix	InfCylSav3	(Cylinder *pCyl, d3Vector *pks, d3Vector *pki, Yn_Lookup *pYtable, Jn_Lookup *pJtable,
						 Complex *Shhl, Complex *Shvl, Complex *Svhl, Complex *Svvl);

#endif
