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
 * Module      : Ground.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Procedure prototype for ground height calculation
 */
#include	"Ground.h"

int		periodicity		(int i, int n)
{
 if (i >= n) {
  i = i%n;
 } else {
  if (i < 0) {
   i = (n+(i % n))%n;
  }
 }
 return (i);
}

double	ground_height	(PolSARproSim_Record *pPR, double x, double y)
{
 double		Lx			=  pPR->Lx;
 double		Ly			=  pPR->Ly;
 int		nx			=  pPR->nx;
 int		ny			=  pPR->ny;
 double		sx			=  pPR->slope_x;
 double		sy			=  pPR->slope_y;
 double		deltax		=  Lx/(double)nx;
 double		deltay		=  Ly/(double)ny;
 int		ix			=  (int)(( x+(Lx-deltax)/2.0)/deltax);
 int		iy			=  (int)((-y+(Ly-deltay)/2.0)/deltay);
 double		x0			=  ix*deltax - (Lx - deltax)/2.0;
 double		y0			= -(iy*deltay - (Ly - deltay)/2.0);
 sim_pixel	pz;
 double		z,z0,z1,z2,z3;
 double		a0,a1,a2,a3;
 double		dx,dy;
 int		kx,ky;
 double		xi,yi,xk,yk;

 pz			= getSIMpixel_periodic (&(pPR->Ground_Height), ix, iy);
 z0			= (double) pz.data.f;

 kx			= periodicity (ix, nx);
 ky			= periodicity (iy, ny);
 xi			=  ix*deltax - (Lx - deltax)/2.0;
 yi			= -(iy*deltay - (Ly - deltay)/2.0);
 xk			=  kx*deltax - (Lx - deltax)/2.0;
 yk			= -(ky*deltay - (Ly - deltay)/2.0);
 z0			+= (xi-xk)*sx;
 z0			+= (yi-yk)*sy;

 pz			= getSIMpixel_periodic (&(pPR->Ground_Height), ix+1, iy);
 z1			= (double) pz.data.f;

 kx			= periodicity (ix+1, nx);
 xi			= (ix+1)*deltax - (Lx - deltax)/2.0;
 xk			=  kx*deltax - (Lx - deltax)/2.0;
 z1			+= (xi-xk)*sx;
 z1			+= (yi-yk)*sy;

 pz			= getSIMpixel_periodic (&(pPR->Ground_Height), ix+1, iy+1);
 z2			= (double) pz.data.f;

 ky			= periodicity (iy+1, ny);
 yi			= -((iy+1)*deltay - (Ly - deltay)/2.0);
 yk			= -(ky*deltay - (Ly - deltay)/2.0);
 z2			+= (xi-xk)*sx;
 z2			+= (yi-yk)*sy;

 pz			= getSIMpixel_periodic (&(pPR->Ground_Height), ix, iy+1);
 z3			= (double) pz.data.f;

 kx			= periodicity (ix, nx);
 xi			=  ix*deltax - (Lx - deltax)/2.0;
 xk			=  kx*deltax - (Lx - deltax)/2.0;
 z3			+= (xi-xk)*sx;
 z3			+= (yi-yk)*sy;

 a0			= z0;
 a1			= (z1-z0)/deltax;
 a2			= (z0-z3)/deltay;
 a3			= (z1+z3-z2-z0)/(deltax*deltay);
 dx			= x-x0;
 dy			= y-y0;
 z			= a0+a1*dx+a2*dy+a3*dx*dy;
 return (z);
}
