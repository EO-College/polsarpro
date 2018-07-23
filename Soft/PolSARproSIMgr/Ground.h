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
 * Module      : Ground.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Procedure prototype for ground height calculation
 */
#ifndef __GROUND_H__
#define __GROUND_H__

#include	<stdio.h>
#include	<stdlib.h>
#include	<math.h>

#include	"bmpDefinitions.h"
#include	"Complex.h"
#include	"d33Matrix.h"
#include	"d3Vector.h"
#include	"GraphicIMage.h"
#include	"LightingMaterials.h"
#include	"Perspective.h"
#include	"PolSARproSim_Definitions.h"
#include	"PolSARproSim_Structures.h"
#include	"SarIMage.h"

int		periodicity		(int i, int n);
double	ground_height	(PolSARproSim_Record *pPR, double x, double y);

#endif
