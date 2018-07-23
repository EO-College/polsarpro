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
 * Module      : Drawing.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"Drawing.h"

/**************************************************************************/
/* Create a graphic image of the forest from the perspective of the radar */
/**************************************************************************/

void	putZbufferPixel	(Graphic_Record *pGR, graphic_pixel p, int i, int j, 
						 SIM_Record *pZb, float znear, float zfar, float z)
{
 sim_pixel	pz;
#ifdef FOREST_GRAPHIC_DEPTH_CUE
 float		fz;
#endif

 if ((i < pZb->nx) && (j < pZb->ny)) {
  if ((z>=znear) && (z<=zfar)) {
   pz	= getSIMpixel (pZb, i, j);
   if (pz.data.f > z) {
    pz.data.f	= z;
    putSIMpixel (pZb, pz, i, j);
#ifdef FOREST_GRAPHIC_DEPTH_CUE
	fz	= (1.0f-FOREST_GRAPHIC_MIN_CUE)*(1.0f-(z-znear)/(zfar-znear))+FOREST_GRAPHIC_MIN_CUE;
	p.red	= (unsigned char) (((float)p.red)*fz);
	p.green	= (unsigned char) (((float)p.green)*fz);
	p.blue	= (unsigned char) (((float)p.blue)*fz);
#endif
    putGraphicpixel (pGR, p, i, j);
   }
  }
 }
 return;
}

void	putZbufferPixel_alphab	(Graphic_Record *pGR, graphic_pixel p, int i, int j, 
								 SIM_Record *pZb, float znear, float zfar, float z, double alphab)
{
 sim_pixel	pz;
#ifdef FOREST_GRAPHIC_DEPTH_CUE
 float		fz;
#endif

 if ((i < pZb->nx) && (j < pZb->ny)) {
  if ((z>=znear) && (z<=zfar)) {
   pz	= getSIMpixel (pZb, i, j);
   if (pz.data.f > z) {
    pz.data.f	= z;
    putSIMpixel (pZb, pz, i, j);
#ifdef FOREST_GRAPHIC_DEPTH_CUE
	fz	= (1.0f-FOREST_GRAPHIC_MIN_CUE)*(1.0f-(z-znear)/(zfar-znear))+FOREST_GRAPHIC_MIN_CUE;
	p.red	= (unsigned char) (((float)p.red)*fz);
	p.green	= (unsigned char) (((float)p.green)*fz);
	p.blue	= (unsigned char) (((float)p.blue)*fz);
#endif
    putGraphicpixel_alphab (pGR, p, i, j, alphab);
   }
  }
 }
 return;
}

void	drawZbufferLine	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
						 int x1, int y1, int x2, int y2,
						 float z1, float z2, float znear, float zfar)
{
 int	y0,x0;
 float	z0;
 int	iy;
 int	ix, xs, xe;
 float	dz;

 if (y2 < y1) {
  x0	= x1;
  y0	= y1;
  z0	= z1;
  x1	= x2;
  y1	= y2;
  z1	= z2;
  x2	= x0;
  y2	= y0;
  z2	= z0;
 }
 dz		= z2-z1;
 if (y2 > y1) {
  dz	/= (y2-y1);
 }
 for (iy=y1; iy<=y2; iy++) {
  if (y1 == y2) {
   xs	= x1;
   xe	= x2;
  } else {
   if (x2 >= x1) {
    xs	= (int) ((float)((iy-y1)*(x2-x1))/(float)(y2-y1)) + x1;
   } else {
    xs	= x1 - (int) ((float)((iy-y1)*(x1-x2))/(float)(y2-y1));
   }
   if (iy == y2) {
    xe	= x2;
   } else {
	if (x2 >= x1) {
     xe	= (int) ((float)((iy+1-y1)*(x2-x1))/(float)(y2-y1)) + x1;
	} else {
	 xe	= x1 - (int) ((float)((iy+1-y1)*(x1-x2))/(float)(y2-y1));
	}
   }
  }
  if (xs > xe) {
   x0	= xs;
   xs	= xe;
   xe	= x0;
  }
  for (ix=xs; ix<=xe; ix++) {
   if (xe != xs) {
    z0	= z1 + (iy-y1)*dz + ((ix-xs)*dz)/((float)(xe-xs));
   } else {
    z0	= z1 + (iy-y1)*dz + dz/2.0f;
   }
   putZbufferPixel (pGR, p, ix, iy, pZb, znear, zfar, z0);
  }
 }
 return;	
}

void	drawZbufferLine_alphab	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
								 int x1, int y1, int x2, int y2,
								 float z1, float z2, float znear, float zfar,
								 double alphab)
{
 int	y0,x0;
 float	z0;
 int	iy;
 int	ix, xs, xe;
 float	dz;

 if (y2 < y1) {
  x0	= x1;
  y0	= y1;
  z0	= z1;
  x1	= x2;
  y1	= y2;
  z1	= z2;
  x2	= x0;
  y2	= y0;
  z2	= z0;
 }
 dz		= z2-z1;
 if (y2 > y1) {
  dz	/= (y2-y1);
 }
 for (iy=y1; iy<=y2; iy++) {
  if (y1 == y2) {
   xs	= x1;
   xe	= x2;
  } else {
   if (x2 >= x1) {
    xs	= (int) ((float)((iy-y1)*(x2-x1))/(float)(y2-y1)) + x1;
   } else {
    xs	= x1 - (int) ((float)((iy-y1)*(x1-x2))/(float)(y2-y1));
   }
   if (iy == y2) {
    xe	= x2;
   } else {
	if (x2 >= x1) {
     xe	= (int) ((float)((iy+1-y1)*(x2-x1))/(float)(y2-y1)) + x1;
	} else {
	 xe	= x1 - (int) ((float)((iy+1-y1)*(x1-x2))/(float)(y2-y1));
	}
   }
  }
  if (xs > xe) {
   x0	= xs;
   xs	= xe;
   xe	= x0;
  }
  for (ix=xs; ix<=xe; ix++) {
   if (xe != xs) {
    z0	= z1 + (iy-y1)*dz + ((ix-xs)*dz)/((float)(xe-xs));
   } else {
    z0	= z1 + (iy-y1)*dz + dz/2.0f;
   }
   putZbufferPixel_alphab (pGR, p, ix, iy, pZb, znear, zfar, z0, alphab);
  }
 }
 return;	
}

void	drawVectorZbufferLine		(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
									 Perspective *pP, d3Vector v1, d3Vector v2)
{
 int	x1,y1,x2,y2;
 float			z1f,z2f;
 float			Lx		= (float) pP->Px;
 float			Ly		= (float) pP->Py;
 float			znear	= (float) pP->Znear;
 float			zfar	= (float) pP->Zfar;
 int	nx		= pP->nx;
 int	ny		= pP->ny;
 float			dx		= Lx/nx;
 float			dy		= Ly/ny;
 float			x1f, y1f, x2f, y2f;

 x1f	= (float) v1.x[0];
 y1f	= (float) v1.x[1];
 z1f	= (float) v1.x[2];
 x1		= (int)( ( x1f+(Lx-dx)/2.0)/dx );
 y1		= (int)( (-y1f+(Ly-dy)/2.0)/dy );
 x2f	= (float) v2.x[0];
 y2f	= (float) v2.x[1];
 z2f	= (float) v2.x[2];
 x2		= (int)( ( x2f+(Lx-dx)/2.0)/dx );
 y2		= (int)( (-y2f+(Ly-dy)/2.0)/dy );
 drawZbufferLine	(pGR, p, pZb, x1, y1, x2, y2, z1f, z2f, znear, zfar);
 return;
}

void	drawVectorZbufferLine_alphab		(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
											 Perspective *pP, d3Vector v1, d3Vector v2, double alphab)
{
 int	x1,y1,x2,y2;
 float			z1f,z2f;
 float			Lx		= (float) pP->Px;
 float			Ly		= (float) pP->Py;
 float			znear	= (float) pP->Znear;
 float			zfar	= (float) pP->Zfar;
 int	nx		= pP->nx;
 int	ny		= pP->ny;
 float			dx		= Lx/nx;
 float			dy		= Ly/ny;
 float			x1f, y1f, x2f, y2f;

 x1f	= (float) v1.x[0];
 y1f	= (float) v1.x[1];
 z1f	= (float) v1.x[2];
 x1		= (int)( ( x1f+(Lx-dx)/2.0)/dx );
 y1		= (int)( (-y1f+(Ly-dy)/2.0)/dy );
 x2f	= (float) v2.x[0];
 y2f	= (float) v2.x[1];
 z2f	= (float) v2.x[2];
 x2		= (int)( ( x2f+(Lx-dx)/2.0)/dx );
 y2		= (int)( (-y2f+(Ly-dy)/2.0)/dy );
 drawZbufferLine_alphab	(pGR, p, pZb, x1, y1, x2, y2, z1f, z2f, znear, zfar, alphab);
 return;
}

void	fillVectorZbufferTriangle	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
									 Perspective *pP, d3Vector r0, d3Vector r1, d3Vector r2)
{
 float			Lx		= (float) pP->Px;
 float			Ly		= (float) pP->Py;
 float			znear	= (float) pP->Znear;
 float			zfar	= (float) pP->Zfar;
 int			nx		= pP->nx;
 int			ny		= pP->ny;
 float			dx		= Lx/nx;
 float			dy		= Ly/ny;
 d3Vector		rmin, rmid, rmax, rint;
 d3Vector		a1, a2, a3;
 int			xmin, xmid, xmax, xint;
 int			ymin, ymid, ymax, yint;
 float			zmin, zmid, zmax, zint;
 int			xs, ys, xe, ye;
 float			zsf, zef;
 double			alpha;
 int			iyl, nyl;
 d3Vector		rs, re;

/*******************************************************/
/* Sort triangle vertices in order (float) y ascending */
/*******************************************************/

 if ((r0.x[1]>r1.x[1]) && (r1.x[1]>r2.x[1])) {
  Copy_d3Vector (&rmax, &r0);
  Copy_d3Vector (&rmid, &r1);
  Copy_d3Vector (&rmin, &r2);
 } else {
  if ((r0.x[1]>r2.x[1]) && (r2.x[1]>r1.x[1])) {
   Copy_d3Vector (&rmax, &r0);
   Copy_d3Vector (&rmid, &r2);
   Copy_d3Vector (&rmin, &r1);
  } else {
   if ((r1.x[1]>r0.x[1]) && (r0.x[1]>r2.x[1])) {
    Copy_d3Vector (&rmax, &r1);
    Copy_d3Vector (&rmid, &r0);
    Copy_d3Vector (&rmin, &r2);
   } else {
    if ((r1.x[1]>r2.x[1]) && (r2.x[1]>r0.x[1])) {
     Copy_d3Vector (&rmax, &r1);
     Copy_d3Vector (&rmid, &r2);
     Copy_d3Vector (&rmin, &r0);
	} else {
	 if ((r2.x[1]>r0.x[1]) && (r0.x[1]>r1.x[1])) {
      Copy_d3Vector (&rmax, &r2);
      Copy_d3Vector (&rmid, &r0);
      Copy_d3Vector (&rmin, &r1);
	 } else {
      Copy_d3Vector (&rmax, &r2);
      Copy_d3Vector (&rmid, &r1);
      Copy_d3Vector (&rmin, &r0);
	 }
	}
   }
  }
 }

/*****************************/
/* Edge displacement vectors */
/*****************************/

 a1		= d3Vector_difference (rmax, rmin);
 a2		= d3Vector_difference (rmid, rmin);
 a3		= d3Vector_difference (rmax, rmid);

/***********************/
/* Integer coordinates */
/***********************/

 xmin	= (int)((((float)rmin.x[0])+(Lx-dx)/2.0f)/dx);
 xmid	= (int)((((float)rmid.x[0])+(Lx-dx)/2.0f)/dx);
 xmax	= (int)((((float)rmax.x[0])+(Lx-dx)/2.0f)/dx);
 ymin	= (int)(((float)(-rmin.x[1])+(Ly-dy)/2.0f)/dy);
 ymid	= (int)(((float)(-rmid.x[1])+(Ly-dy)/2.0f)/dy);
 ymax	= (int)(((float)(-rmax.x[1])+(Ly-dy)/2.0f)/dy);

/**********/
/* Depths */
/**********/

 zmin	= (float) rmin.x[2];
 zmid	= (float) rmid.x[2];
 zmax	= (float) rmax.x[2];

 if (ymin == ymax) {
  /*******************/
  /* Horizontal edge */
  /*******************/
  xs	= xmin;
  ys	= ymin;
  zsf	= zmin;
  xe	= xmid;
  ye	= ymid;
  zef	= zmid;
  drawZbufferLine	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar);
  xs	= xmid;
  ys	= ymid;
  zsf	= zmid;
  xe	= xmax;
  ye	= ymax;
  zef	= zmax;
  drawZbufferLine	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar);
 } else {
  /***************************/
  /* Find intermediate point */
  /***************************/
  alpha	= (rmid.x[1]-rmin.x[1])/a1.x[1];
  rint	= d3Vector_sum (rmin, d3Vector_double_multiply (a1, alpha));
  xint	= (int)((((float)rint.x[0])+(Lx-dx)/2.0f)/dx);
  yint	= (int)(((float)(-rint.x[1])+(Ly-dy)/2.0f)/dy);
  zint	= (float) rint.x[2];
  /**********************/
  /* Fill lower section */
  /**********************/
  nyl	= abs(yint-ymin);
  if (nyl < 1) {
   nyl = 1;
  }
  for (iyl=0; iyl<=nyl; iyl++) {
   rs	= d3Vector_sum (rmin, d3Vector_double_multiply (a1, alpha*((float)iyl/(float)nyl)));
   re	= d3Vector_sum (rmin, d3Vector_double_multiply (a2, (float)iyl/(float)nyl));
   xs	= (int)((((float)rs.x[0])+(Lx-dx)/2.0f)/dx);
   ys	= (int)(((float)(-rs.x[1])+(Ly-dy)/2.0f)/dy);
   zsf	= (float) rs.x[2];
   xe	= (int)((((float)re.x[0])+(Lx-dx)/2.0f)/dx);
   ye	= (int)(((float)(-re.x[1])+(Ly-dy)/2.0f)/dy);
   zef	= (float) re.x[2];
   drawZbufferLine	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar);
  }
  /**********************/
  /* Fill upper section */
  /**********************/
  nyl	= abs(ymax-yint);
  if (nyl < 1) {
   nyl = 1;
  }
  for (iyl=0; iyl<=nyl; iyl++) {
   rs	= d3Vector_sum (rmax, d3Vector_double_multiply (a1, (1.0-alpha)*((float)-iyl/(float)nyl)));
   re	= d3Vector_sum (rmax, d3Vector_double_multiply (a3, (float)-iyl/(float)nyl));
   xs	= (int)((((float)rs.x[0])+(Lx-dx)/2.0f)/dx);
   ys	= (int)(((float)(-rs.x[1])+(Ly-dy)/2.0f)/dy);
   zsf	= (float) rs.x[2];
   xe	= (int)((((float)re.x[0])+(Lx-dx)/2.0f)/dx);
   ye	= (int)(((float)(-re.x[1])+(Ly-dy)/2.0f)/dy);
   zef	= (float) re.x[2];
   drawZbufferLine	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar);
  }
 }
 return;
}

void	fillVectorZbufferTriangle_alphab	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
											 Perspective *pP, d3Vector r0, d3Vector r1, d3Vector r2, double alphab)
{
 float			Lx		= (float) pP->Px;
 float			Ly		= (float) pP->Py;
 float			znear	= (float) pP->Znear;
 float			zfar	= (float) pP->Zfar;
 int			nx		= pP->nx;
 int			ny		= pP->ny;
 float			dx		= Lx/nx;
 float			dy		= Ly/ny;
 d3Vector		rmin, rmid, rmax, rint;
 d3Vector		a1, a2, a3;
 int			xmin, xmid, xmax, xint;
 int			ymin, ymid, ymax, yint;
 float			zmin, zmid, zmax, zint;
 int			xs, ys, xe, ye;
 float			zsf, zef;
 double			alpha;
 int			iyl, nyl;
 d3Vector		rs, re;

/*******************************************************/
/* Sort triangle vertices in order (float) y ascending */
/*******************************************************/

 if ((r0.x[1]>r1.x[1]) && (r1.x[1]>r2.x[1])) {
  Copy_d3Vector (&rmax, &r0);
  Copy_d3Vector (&rmid, &r1);
  Copy_d3Vector (&rmin, &r2);
 } else {
  if ((r0.x[1]>r2.x[1]) && (r2.x[1]>r1.x[1])) {
   Copy_d3Vector (&rmax, &r0);
   Copy_d3Vector (&rmid, &r2);
   Copy_d3Vector (&rmin, &r1);
  } else {
   if ((r1.x[1]>r0.x[1]) && (r0.x[1]>r2.x[1])) {
    Copy_d3Vector (&rmax, &r1);
    Copy_d3Vector (&rmid, &r0);
    Copy_d3Vector (&rmin, &r2);
   } else {
    if ((r1.x[1]>r2.x[1]) && (r2.x[1]>r0.x[1])) {
     Copy_d3Vector (&rmax, &r1);
     Copy_d3Vector (&rmid, &r2);
     Copy_d3Vector (&rmin, &r0);
	} else {
	 if ((r2.x[1]>r0.x[1]) && (r0.x[1]>r1.x[1])) {
      Copy_d3Vector (&rmax, &r2);
      Copy_d3Vector (&rmid, &r0);
      Copy_d3Vector (&rmin, &r1);
	 } else {
      Copy_d3Vector (&rmax, &r2);
      Copy_d3Vector (&rmid, &r1);
      Copy_d3Vector (&rmin, &r0);
	 }
	}
   }
  }
 }

/*****************************/
/* Edge displacement vectors */
/*****************************/

 a1		= d3Vector_difference (rmax, rmin);
 a2		= d3Vector_difference (rmid, rmin);
 a3		= d3Vector_difference (rmax, rmid);

/***********************/
/* Integer coordinates */
/***********************/

 xmin	= (int)((((float)rmin.x[0])+(Lx-dx)/2.0f)/dx);
 xmid	= (int)((((float)rmid.x[0])+(Lx-dx)/2.0f)/dx);
 xmax	= (int)((((float)rmax.x[0])+(Lx-dx)/2.0f)/dx);
 ymin	= (int)(((float)(-rmin.x[1])+(Ly-dy)/2.0f)/dy);
 ymid	= (int)(((float)(-rmid.x[1])+(Ly-dy)/2.0f)/dy);
 ymax	= (int)(((float)(-rmax.x[1])+(Ly-dy)/2.0f)/dy);

/**********/
/* Depths */
/**********/

 zmin	= (float) rmin.x[2];
 zmid	= (float) rmid.x[2];
 zmax	= (float) rmax.x[2];

 if (ymin == ymax) {
  /*******************/
  /* Horizontal edge */
  /*******************/
  xs	= xmin;
  ys	= ymin;
  zsf	= zmin;
  xe	= xmid;
  ye	= ymid;
  zef	= zmid;
  drawZbufferLine_alphab	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar, alphab);
  xs	= xmid;
  ys	= ymid;
  zsf	= zmid;
  xe	= xmax;
  ye	= ymax;
  zef	= zmax;
  drawZbufferLine_alphab	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar, alphab);
 } else {
  /***************************/
  /* Find intermediate point */
  /***************************/
  alpha	= (rmid.x[1]-rmin.x[1])/a1.x[1];
  rint	= d3Vector_sum (rmin, d3Vector_double_multiply (a1, alpha));
  xint	= (int)((((float)rint.x[0])+(Lx-dx)/2.0f)/dx);
  yint	= (int)(((float)(-rint.x[1])+(Ly-dy)/2.0f)/dy);
  zint	= (float) rint.x[2];
  /**********************/
  /* Fill lower section */
  /**********************/
  nyl	= abs(yint-ymin);
  if (nyl < 1) {
   nyl = 1;
  }
  for (iyl=0; iyl<=nyl; iyl++) {
   rs	= d3Vector_sum (rmin, d3Vector_double_multiply (a1, alpha*((float)iyl/(float)nyl)));
   re	= d3Vector_sum (rmin, d3Vector_double_multiply (a2, (float)iyl/(float)nyl));
   xs	= (int)((((float)rs.x[0])+(Lx-dx)/2.0f)/dx);
   ys	= (int)(((float)(-rs.x[1])+(Ly-dy)/2.0f)/dy);
   zsf	= (float) rs.x[2];
   xe	= (int)((((float)re.x[0])+(Lx-dx)/2.0f)/dx);
   ye	= (int)(((float)(-re.x[1])+(Ly-dy)/2.0f)/dy);
   zef	= (float) re.x[2];
   drawZbufferLine_alphab	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar, alphab);
  }
  /**********************/
  /* Fill upper section */
  /**********************/
  nyl	= abs(ymax-yint);
  if (nyl < 1) {
   nyl = 1;
  }
  for (iyl=0; iyl<=nyl; iyl++) {
   rs	= d3Vector_sum (rmax, d3Vector_double_multiply (a1, (1.0-alpha)*((float)-iyl/(float)nyl)));
   re	= d3Vector_sum (rmax, d3Vector_double_multiply (a3, (float)-iyl/(float)nyl));
   xs	= (int)((((float)rs.x[0])+(Lx-dx)/2.0f)/dx);
   ys	= (int)(((float)(-rs.x[1])+(Ly-dy)/2.0f)/dy);
   zsf	= (float) rs.x[2];
   xe	= (int)((((float)re.x[0])+(Lx-dx)/2.0f)/dx);
   ye	= (int)(((float)(-re.x[1])+(Ly-dy)/2.0f)/dy);
   zef	= (float) re.x[2];
   drawZbufferLine_alphab	(pGR, p, pZb, xs, ys, xe, ye, zsf, zef, znear, zfar, alphab);
  }
 }
 return;
}

void	drawFacet	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
					 Facet *pF, Perspective *pP)
{
/********************/
/* Draw edges first */
/********************/
 drawVectorZbufferLine (pGR, p, pZb, pP, pF->r[0], pF->r[1]);
 drawVectorZbufferLine (pGR, p, pZb, pP, pF->r[1], pF->r[2]);
 drawVectorZbufferLine (pGR, p, pZb, pP, pF->r[2], pF->r[0]);
/*****************/
/* Fill triangle */
/*****************/
 fillVectorZbufferTriangle (pGR, p, pZb, pP, pF->r[0], pF->r[1], pF->r[2]);
 return;
}

void	drawFacet_alphab	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
							Facet *pF, Perspective *pP, double alphab)
{
/********************/
/* Draw edges first */
/********************/
/*
 drawVectorZbufferLine_alphab (pGR, p, pZb, pP, pF->r[0], pF->r[1], alphab);
 drawVectorZbufferLine_alphab (pGR, p, pZb, pP, pF->r[1], pF->r[2], alphab);
 drawVectorZbufferLine_alphab (pGR, p, pZb, pP, pF->r[2], pF->r[0], alphab);
*/
/*****************/
/* Fill triangle */
/*****************/
 fillVectorZbufferTriangle_alphab (pGR, p, pZb, pP, pF->r[0], pF->r[1], pF->r[2], alphab);
 return;
}

void	drawWireFrameFacet	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, 
							Facet *pF, Perspective *pP)
{
/*******************/
/* Draw edges only */
/*******************/
 drawVectorZbufferLine (pGR, p, pZb, pP, pF->r[0], pF->r[1]);
 drawVectorZbufferLine (pGR, p, pZb, pP, pF->r[1], pF->r[2]);
 drawVectorZbufferLine (pGR, p, pZb, pP, pF->r[2], pF->r[0]);
 return;
}

void	drawFacetList	(Graphic_Record *pGR, graphic_pixel p, SIM_Record *pZb, Facet_List *pFL, Perspective *pP)
{
 long	nf;
 Facet	*pF	= pFL->head;
 for (nf=0L; nf < pFL->n; nf++) {
  drawFacet (pGR, p, pZb, pF, pP);
  pF	= pF->next;
 }
 return;
}

void	drawTree	(Tree *pT, Graphic_Record *pGR, SIM_Record *pZb, Drawing_Record *pD)
{
 long				iBranch;
 Branch				*pB;
 double				dres	= 0.5*(pD->pP->dx+pD->pP->dy);
 int				Nsections;
 int				i_section;
 int				Nazimuth;
 int				i_azimuth;
 double				t0, t1, deltat;
 d3Vector			b0, b1;
 d3Vector			x, y, z;
 double				theta0, theta1, dtheta;
 d3Vector			zg	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
 double				branch_section_length;
 double				costheta0, costheta1, sintheta0, sintheta1;
 d3Vector			vertex[5];
 int				i_vertex;
 Facet				branch_facet[4];
 graphic_pixel		branch_gp;
 double				r0, r1, deltar, rn;
 Ray				ray0, ray1, ray2, ray3;
 double				npdotz;
 d3Vector			a0, a1;
 d3Vector			np, xp, yp;
 d3Vector			s0, s1;
 d3Vector			sa1, sa2;
 double				alpha1, alpha2;
 Crown				*pC;
 long				iCrown;
 double				deltah;
 int				rtn_value;
 double				radius;
 int				i_facet;
 Facet				crown_facet[4];
 graphic_pixel		crown_gp;
 Material			branch_material;
 Material			living_crown_material;
 Material			dry_crown_material;
#ifdef FOREST_GRAPHIC_DRAW_TERTIARY
 long				Ntertiary;
 long				Ntmax;
#endif
#ifdef FOREST_GRAPHIC_DRAW_FOLIAGE
 long				Nleaves;
 long				Nlmax;
 long				iLeaf;
 Leaf				*pL;
 Material			leaf_material;
 Facet				leaf_facet[4];
 graphic_pixel		leaf_gp;
 const double		leaf_scaling	= 10.0*pT->height/25.0;
#endif

 /******************/
 /* Initialisation */
 /******************/

  Create_Material	(&branch_material, FOREST_GRAPHIC_BRANCH_KA, FOREST_GRAPHIC_BRANCH_KD, 
					 FOREST_GRAPHIC_BRANCH_KS, FOREST_GRAPHIC_BRANCH_SR, FOREST_GRAPHIC_BRANCH_SG,
					 FOREST_GRAPHIC_BRANCH_SB);

  Create_Material	(&living_crown_material, FOREST_GRAPHIC_LCROWN_KA, FOREST_GRAPHIC_LCROWN_KD, 
					 FOREST_GRAPHIC_LCROWN_KS, FOREST_GRAPHIC_LCROWN_SR, FOREST_GRAPHIC_LCROWN_SG,
					 FOREST_GRAPHIC_LCROWN_SB);

  Create_Material	(&dry_crown_material, FOREST_GRAPHIC_DCROWN_KA, FOREST_GRAPHIC_DCROWN_KD, 
					 FOREST_GRAPHIC_DCROWN_KS, FOREST_GRAPHIC_DCROWN_SR, FOREST_GRAPHIC_DCROWN_SG,
					 FOREST_GRAPHIC_DCROWN_SB);

#ifdef FOREST_GRAPHIC_DRAW_FOLIAGE
  Create_Material	(&leaf_material, FOREST_GRAPHIC_LEAF_KA, FOREST_GRAPHIC_LEAF_KD, 
					 FOREST_GRAPHIC_LEAF_KS, FOREST_GRAPHIC_LEAF_SR, FOREST_GRAPHIC_LEAF_SG,
					 FOREST_GRAPHIC_LEAF_SB);
#endif

 /******************/
 /* Draw the stems */
 /******************/

 pB	= pT->Stem.head;
 for (iBranch=0L; iBranch < pT->Stem.n; iBranch++) {
  Nsections	= (int) (pB->l/dres) + 1;
  if (Nsections < FOREST_GRAPHIC_MIN_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MIN_BRANCH_SECTIONS;
  }
  if (Nsections > FOREST_GRAPHIC_MAX_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MAX_BRANCH_SECTIONS;
  }
  Nazimuth	= (int) (2.0*DPI_RAD*pB->start_radius / dres);
  if (Nazimuth < FOREST_GRAPHIC_MIN_BRANCH_SIDES) {
   Nazimuth	= FOREST_GRAPHIC_MIN_BRANCH_SIDES;
  }
  if (Nazimuth > FOREST_GRAPHIC_MAX_BRANCH_SIDES) {
   Nazimuth = FOREST_GRAPHIC_MAX_BRANCH_SIDES;
  }
  deltat	= 1.0 / (double) Nsections;
  dtheta	= 2.0*DPI_RAD / (double) Nazimuth;
  deltar	= (pB->start_radius - pB->end_radius) / (double) Nsections;
  for (i_section = 0; i_section < Nsections; i_section++) {
   r0	= pB->start_radius - i_section * deltar;
   r1	= r0 - deltar;
   rn	= 0.5*(r0+r1);
   t0	= i_section * deltat;
   t1	= t0+deltat;
   b0	= Branch_Centre (pB, t0);
   b1	= Branch_Centre (pB, t1);
   z	= d3Vector_difference (b1, b0);
   branch_section_length	= z.r;
   d3Vector_insitu_normalise (&z);
   if (fabs(1.0-fabs(d3Vector_scalar_product (z, zg))) < FLT_EPSILON) {
    x	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
    y	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
   } else {
    x	= d3Vector_cross_product (zg, z);
    d3Vector_insitu_normalise (&x);
    y	= d3Vector_cross_product (x, z);
   }
   for (i_azimuth = 0; i_azimuth < Nazimuth; i_azimuth++) {
    theta0		= i_azimuth * dtheta;
	theta1		= theta0 + dtheta;
	costheta0	= rn*cos(theta0);
	sintheta0	= rn*sin(theta0);
	costheta1	= rn*cos(theta1);
	sintheta1	= rn*sin(theta1);
	vertex[0]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta0));
    vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (y, sintheta0));
	vertex[1]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta0));
    vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (y, sintheta0));
	vertex[2]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta1));
    vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (y, sintheta1));
	vertex[3]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta1));
    vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (y, sintheta1));
	vertex[4]	= d3Vector_sum (d3Vector_sum (vertex[0], vertex[1]), d3Vector_sum (vertex[2], vertex[3]));
	vertex[4]	= d3Vector_double_multiply (vertex[4], 0.25);
    /************************************************************/
    /* Transform the vertex coordinates into the viewing volume */
    /************************************************************/
    for (i_vertex=0;i_vertex<5;i_vertex++) {
     vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
     vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
    }
    /*************************************************/
    /* Convert the coordinates into the screen frame */
    /*************************************************/
    for (i_vertex=0; i_vertex<5; i_vertex++) {
     vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
    }
    /************************************/
    /* Turn stem panel into four facets */
    /************************************/
    Assign_Facet	(&(branch_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
    Assign_Facet	(&(branch_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
    Assign_Facet	(&(branch_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
    Assign_Facet	(&(branch_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
    /**************************/
    /* Calculate facet colour */
    /**************************/
	branch_gp		= colour (pD->pL, &branch_material, branch_facet[0].n);
    /********************************/
    /* Draw facets in graphic image */
    /********************************/
    for (i_vertex=0; i_vertex<4; i_vertex++) {
#ifdef FOREST_GRAPHIC_DRAW_STEM
     drawFacet (pGR, branch_gp, pZb, &(branch_facet[i_vertex]), pD->pP);
#endif
    }
   }
  }
  pB	= pB->next;
 }

/*****************************/
/* Draw the living primaries */
/*****************************/

#ifdef FOREST_GRAPHIC_DRAW_PRIMARY
 pB	= pT->Primary.head;
 for (iBranch=0L; iBranch < pT->Primary.n; iBranch++) {
  Nsections	= (int) (pB->l/dres) + 1;
  if (Nsections < FOREST_GRAPHIC_MIN_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MIN_BRANCH_SECTIONS;
  }
  if (Nsections > FOREST_GRAPHIC_MAX_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MAX_BRANCH_SECTIONS;
  }
  Nazimuth	= (int) (2.0*DPI_RAD*pB->start_radius / dres);
  if (Nazimuth < FOREST_GRAPHIC_MIN_BRANCH_SIDES) {
   Nazimuth	= FOREST_GRAPHIC_MIN_BRANCH_SIDES;
  }
  if (Nazimuth > FOREST_GRAPHIC_MAX_BRANCH_SIDES) {
   Nazimuth = FOREST_GRAPHIC_MAX_BRANCH_SIDES;
  }
  deltat	= 1.0 / (double) Nsections;
  dtheta	= 2.0*DPI_RAD / (double) Nazimuth;
  deltar	= (pB->start_radius - pB->end_radius) / (double) Nsections;
  for (i_section = 0; i_section < Nsections; i_section++) {
   r0	= pB->start_radius - i_section * deltar;
   r1	= r0 - deltar;
   rn	= 0.5*(r0+r1);
   t0	= i_section * deltat;
   t1	= t0+deltat;
   b0	= Branch_Centre (pB, t0);
   b1	= Branch_Centre (pB, t1);
   z	= d3Vector_difference (b1, b0);
   branch_section_length	= z.r;
   d3Vector_insitu_normalise (&z);
   if (fabs(1.0-fabs(d3Vector_scalar_product (z, zg))) < FLT_EPSILON) {
    x	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
    y	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
   } else {
    x	= d3Vector_cross_product (zg, z);
    d3Vector_insitu_normalise (&x);
    y	= d3Vector_cross_product (x, z);
   }
   for (i_azimuth = 0; i_azimuth < Nazimuth; i_azimuth++) {
    theta0		= i_azimuth * dtheta;
	theta1		= theta0 + dtheta;
	costheta0	= rn*cos(theta0);
	sintheta0	= rn*sin(theta0);
	costheta1	= rn*cos(theta1);
	sintheta1	= rn*sin(theta1);
	vertex[0]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta0));
    vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (y, sintheta0));
	vertex[1]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta0));
    vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (y, sintheta0));
	vertex[2]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta1));
    vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (y, sintheta1));
	vertex[3]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta1));
    vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (y, sintheta1));
	vertex[4]	= d3Vector_sum (d3Vector_sum (vertex[0], vertex[1]), d3Vector_sum (vertex[2], vertex[3]));
	vertex[4]	= d3Vector_double_multiply (vertex[4], 0.25);
    /************************************************************/
    /* Transform the vertex coordinates into the viewing volume */
    /************************************************************/
    for (i_vertex=0;i_vertex<5;i_vertex++) {
     vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
     vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
    }
    /*************************************************/
    /* Convert the coordinates into the screen frame */
    /*************************************************/
    for (i_vertex=0; i_vertex<5; i_vertex++) {
     vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
    }
    /************************************/
    /* Turn stem panel into four facets */
    /************************************/
    Assign_Facet	(&(branch_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
    Assign_Facet	(&(branch_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
    Assign_Facet	(&(branch_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
    Assign_Facet	(&(branch_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
    for (i_vertex=0; i_vertex<4; i_vertex++) {
     /**************************/
     /* Calculate facet colour */
     /**************************/
	 if (i_vertex == 0) {
	  branch_gp	= colour (pD->pL, &branch_material, branch_facet[i_vertex].n);
	 }
     /*******************************/
     /* Draw facet in graphic image */
     /*******************************/
     drawFacet (pGR, branch_gp, pZb, &(branch_facet[i_vertex]), pD->pP);
    }
   }
  }
  pB	= pB->next;
 }
#endif

/**************************/
/* Draw the dry primaries */
/**************************/

#ifdef FOREST_GRAPHIC_DRAW_PRIMARY
 pB	= pT->Dry.head;
 for (iBranch=0L; iBranch < pT->Dry.n; iBranch++) {
  Nsections	= (int) (pB->l/dres) + 1;
  if (Nsections < FOREST_GRAPHIC_MIN_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MIN_BRANCH_SECTIONS;
  }
  if (Nsections > FOREST_GRAPHIC_MAX_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MAX_BRANCH_SECTIONS;
  }
  Nazimuth	= (int) (2.0*DPI_RAD*pB->start_radius / dres);
  if (Nazimuth < FOREST_GRAPHIC_MIN_BRANCH_SIDES) {
   Nazimuth	= FOREST_GRAPHIC_MIN_BRANCH_SIDES;
  }
  if (Nazimuth > FOREST_GRAPHIC_MAX_BRANCH_SIDES) {
   Nazimuth = FOREST_GRAPHIC_MAX_BRANCH_SIDES;
  }
  deltat	= 1.0 / (double) Nsections;
  dtheta	= 2.0*DPI_RAD / (double) Nazimuth;
  deltar	= (pB->start_radius - pB->end_radius) / (double) Nsections;
  for (i_section = 0; i_section < Nsections; i_section++) {
   r0	= pB->start_radius - i_section * deltar;
   r1	= r0 - deltar;
   rn	= 0.5*(r0+r1);
   t0	= i_section * deltat;
   t1	= t0+deltat;
   b0	= Branch_Centre (pB, t0);
   b1	= Branch_Centre (pB, t1);
   z	= d3Vector_difference (b1, b0);
   branch_section_length	= z.r;
   d3Vector_insitu_normalise (&z);
   if (fabs(1.0-fabs(d3Vector_scalar_product (z, zg))) < FLT_EPSILON) {
    x	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
    y	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
   } else {
    x	= d3Vector_cross_product (zg, z);
    d3Vector_insitu_normalise (&x);
    y	= d3Vector_cross_product (x, z);
   }
   for (i_azimuth = 0; i_azimuth < Nazimuth; i_azimuth++) {
    theta0		= i_azimuth * dtheta;
	theta1		= theta0 + dtheta;
	costheta0	= rn*cos(theta0);
	sintheta0	= rn*sin(theta0);
	costheta1	= rn*cos(theta1);
	sintheta1	= rn*sin(theta1);
	vertex[0]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta0));
    vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (y, sintheta0));
	vertex[1]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta0));
    vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (y, sintheta0));
	vertex[2]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta1));
    vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (y, sintheta1));
	vertex[3]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta1));
    vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (y, sintheta1));
	vertex[4]	= d3Vector_sum (d3Vector_sum (vertex[0], vertex[1]), d3Vector_sum (vertex[2], vertex[3]));
	vertex[4]	= d3Vector_double_multiply (vertex[4], 0.25);
    /************************************************************/
    /* Transform the vertex coordinates into the viewing volume */
    /************************************************************/
    for (i_vertex=0;i_vertex<5;i_vertex++) {
     vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
     vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
    }
    /*************************************************/
    /* Convert the coordinates into the screen frame */
    /*************************************************/
    for (i_vertex=0; i_vertex<5; i_vertex++) {
     vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
    }
    /************************************/
    /* Turn stem panel into four facets */
    /************************************/
    Assign_Facet	(&(branch_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
    Assign_Facet	(&(branch_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
    Assign_Facet	(&(branch_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
    Assign_Facet	(&(branch_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
    for (i_vertex=0; i_vertex<4; i_vertex++) {
     /**************************/
     /* Calculate facet colour */
     /**************************/
	 if (i_vertex == 0) {
	  branch_gp	= colour (pD->pL, &branch_material, branch_facet[i_vertex].n);
	 }
     /*******************************/
     /* Draw facet in graphic image */
     /*******************************/
     drawFacet (pGR, branch_gp, pZb, &(branch_facet[i_vertex]), pD->pP);
    }
   }
  }
  pB	= pB->next;
 }
#endif

/************************/
/* Draw the secondaries */
/************************/

#ifdef FOREST_GRAPHIC_DRAW_SECONDARY
 pB	= pT->Secondary.head;
 for (iBranch=0L; iBranch < pT->Secondary.n; iBranch++) {
  Nsections	= (int) (pB->l/dres) + 1;
  if (Nsections < FOREST_GRAPHIC_MIN_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MIN_BRANCH_SECTIONS;
  }
  if (Nsections > FOREST_GRAPHIC_MAX_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MAX_BRANCH_SECTIONS;
  }
  Nazimuth	= (int) (2.0*DPI_RAD*pB->start_radius / dres);
  if (Nazimuth < FOREST_GRAPHIC_MIN_BRANCH_SIDES) {
   Nazimuth	= FOREST_GRAPHIC_MIN_BRANCH_SIDES;
  }
  if (Nazimuth > FOREST_GRAPHIC_MAX_BRANCH_SIDES) {
   Nazimuth = FOREST_GRAPHIC_MAX_BRANCH_SIDES;
  }
  deltat	= 1.0 / (double) Nsections;
  dtheta	= 2.0*DPI_RAD / (double) Nazimuth;
  deltar	= (pB->start_radius - pB->end_radius) / (double) Nsections;
  for (i_section = 0; i_section < Nsections; i_section++) {
   r0	= pB->start_radius - i_section * deltar;
   r1	= r0 - deltar;
   rn	= 0.5*(r0+r1);
   t0	= i_section * deltat;
   t1	= t0+deltat;
   b0	= Branch_Centre (pB, t0);
   b1	= Branch_Centre (pB, t1);
   z	= d3Vector_difference (b1, b0);
   branch_section_length	= z.r;
   d3Vector_insitu_normalise (&z);
   if (fabs(1.0-fabs(d3Vector_scalar_product (z, zg))) < FLT_EPSILON) {
    x	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
    y	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
   } else {
    x	= d3Vector_cross_product (zg, z);
    d3Vector_insitu_normalise (&x);
    y	= d3Vector_cross_product (x, z);
   }
   for (i_azimuth = 0; i_azimuth < Nazimuth; i_azimuth++) {
    theta0		= i_azimuth * dtheta;
	theta1		= theta0 + dtheta;
	costheta0	= rn*cos(theta0);
	sintheta0	= rn*sin(theta0);
	costheta1	= rn*cos(theta1);
	sintheta1	= rn*sin(theta1);
	vertex[0]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta0));
    vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (y, sintheta0));
	vertex[1]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta0));
    vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (y, sintheta0));
	vertex[2]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta1));
    vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (y, sintheta1));
	vertex[3]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta1));
    vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (y, sintheta1));
	vertex[4]	= d3Vector_sum (d3Vector_sum (vertex[0], vertex[1]), d3Vector_sum (vertex[2], vertex[3]));
	vertex[4]	= d3Vector_double_multiply (vertex[4], 0.25);
    for (i_vertex=0;i_vertex<5;i_vertex++) {
     vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
     vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
    }
    for (i_vertex=0; i_vertex<5; i_vertex++) {
     vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
    }
    Assign_Facet	(&(branch_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
    Assign_Facet	(&(branch_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
    Assign_Facet	(&(branch_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
    Assign_Facet	(&(branch_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
    for (i_vertex=0; i_vertex<4; i_vertex++) {
	 if (i_vertex == 0) {
	  branch_gp	= colour (pD->pL, &branch_material, branch_facet[i_vertex].n);
	 }
     drawFacet (pGR, branch_gp, pZb, &(branch_facet[i_vertex]), pD->pP);
    }
   }
  }
  pB	= pB->next;
 }
#endif

/******************************/
/* Draw the tertiary branches */
/******************************/

#ifdef FOREST_GRAPHIC_DRAW_TERTIARY
 pB	= pT->Tertiary.head;
 Ntertiary	= pT->Tertiary.n;
 Ntmax		= (long) FOREST_GRAPHIC_TERTIARY_NUMBER;
 if (pT->species == POLSARPROSIM_HEDGE) {
  Ntmax	= (long) (Ntmax * FOREST_GRAPHIC_HEDGE_TERTIARY_SCALING);
 }
 if (Ntertiary > Ntmax) {
  Ntertiary = Ntmax;
 }
 for (iBranch=0L; iBranch < Ntertiary; iBranch++) {
  Nsections	= (int) (pB->l/dres) + 1;
  if (Nsections < FOREST_GRAPHIC_MIN_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MIN_BRANCH_SECTIONS;
  }
  if (Nsections > FOREST_GRAPHIC_MAX_BRANCH_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MAX_BRANCH_SECTIONS;
  }
  Nazimuth	= (int) (2.0*DPI_RAD*pB->start_radius / dres);
  if (Nazimuth < FOREST_GRAPHIC_MIN_BRANCH_SIDES) {
   Nazimuth	= FOREST_GRAPHIC_MIN_BRANCH_SIDES;
  }
  if (Nazimuth > FOREST_GRAPHIC_MAX_BRANCH_SIDES) {
   Nazimuth = FOREST_GRAPHIC_MAX_BRANCH_SIDES;
  }
  deltat	= 1.0 / (double) Nsections;
  dtheta	= 2.0*DPI_RAD / (double) Nazimuth;
  deltar	= (pB->start_radius - pB->end_radius) / (double) Nsections;
  for (i_section = 0; i_section < Nsections; i_section++) {
   r0	= pB->start_radius - i_section * deltar;
   r1	= r0 - deltar;
   rn	= 0.5*(r0+r1);
   t0	= i_section * deltat;
   t1	= t0+deltat;
   b0	= Branch_Centre (pB, t0);
   b1	= Branch_Centre (pB, t1);
   z	= d3Vector_difference (b1, b0);
   branch_section_length	= z.r;
   d3Vector_insitu_normalise (&z);
   if (fabs(1.0-fabs(d3Vector_scalar_product (z, zg))) < FLT_EPSILON) {
    x	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
    y	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
   } else {
    x	= d3Vector_cross_product (zg, z);
    d3Vector_insitu_normalise (&x);
    y	= d3Vector_cross_product (x, z);
   }
   for (i_azimuth = 0; i_azimuth < Nazimuth; i_azimuth++) {
    theta0		= i_azimuth * dtheta;
	theta1		= theta0 + dtheta;
	costheta0	= rn*cos(theta0);
	sintheta0	= rn*sin(theta0);
	costheta1	= rn*cos(theta1);
	sintheta1	= rn*sin(theta1);
	vertex[0]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta0));
    vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (y, sintheta0));
	vertex[1]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta0));
    vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (y, sintheta0));
	vertex[2]	= d3Vector_sum (b1, d3Vector_double_multiply (x, costheta1));
    vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (y, sintheta1));
	vertex[3]	= d3Vector_sum (b0, d3Vector_double_multiply (x, costheta1));
    vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (y, sintheta1));
	vertex[4]	= d3Vector_sum (d3Vector_sum (vertex[0], vertex[1]), d3Vector_sum (vertex[2], vertex[3]));
	vertex[4]	= d3Vector_double_multiply (vertex[4], 0.25);
    for (i_vertex=0;i_vertex<5;i_vertex++) {
     vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
     vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
    }
    for (i_vertex=0; i_vertex<5; i_vertex++) {
     vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
    }
    Assign_Facet	(&(branch_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
    Assign_Facet	(&(branch_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
    Assign_Facet	(&(branch_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
    Assign_Facet	(&(branch_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
    for (i_vertex=0; i_vertex<4; i_vertex++) {
	 if (i_vertex == 0) {
	  branch_gp	= colour (pD->pL, &branch_material, branch_facet[i_vertex].n);
	 }
     drawFacet (pGR, branch_gp, pZb, &(branch_facet[i_vertex]), pD->pP);
    }
   }
  }
  pB	= pB->next;
 }
#endif

/*******************/
/* Draw the leaves */
/*******************/

#ifdef FOREST_GRAPHIC_DRAW_FOLIAGE
 pL	= pT->Foliage.head;
 Nleaves	= pT->Foliage.n;
 Nlmax		= (long) FOREST_GRAPHIC_TERTIARY_NUMBER;
 if (pT->species == POLSARPROSIM_HEDGE) {
  Nlmax	= (long) (Nlmax * FOREST_GRAPHIC_HEDGE_TERTIARY_SCALING);
 }
 if (Nleaves > Nlmax) {
  Nleaves = Nlmax;
 }
 for (iLeaf=0L; iLeaf < Nleaves; iLeaf++) {
  Copy_d3Vector (&(vertex[4]), &(pL->cl));
  if (pL->species == POLSARPROSIM_DECIDUOUS_LEAF) {
   vertex[0]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (pL->xl, -leaf_scaling*pL->d2/2.0));
   vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (pL->yl, -leaf_scaling*pL->d1/2.0));
   vertex[1]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (pL->xl, -leaf_scaling*pL->d2/2.0));
   vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (pL->yl,  leaf_scaling*pL->d1/2.0));
   vertex[2]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (pL->xl,  leaf_scaling*pL->d2/2.0));
   vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (pL->yl,  leaf_scaling*pL->d1/2.0));
   vertex[3]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (pL->xl,  leaf_scaling*pL->d2/2.0));
   vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (pL->yl, -leaf_scaling*pL->d1/2.0));
   for (i_vertex=0;i_vertex<5;i_vertex++) {
    vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
    vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
   }
   for (i_vertex=0; i_vertex<5; i_vertex++) {
    vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
   }
   Assign_Facet	(&(leaf_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
   Assign_Facet	(&(leaf_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
   Assign_Facet	(&(leaf_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
   Assign_Facet	(&(leaf_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
   for (i_vertex=0; i_vertex<4; i_vertex++) {
    if (i_vertex == 0) {
     leaf_gp	= colour (pD->pL, &leaf_material, leaf_facet[i_vertex].n);
    }
    drawFacet (pGR, leaf_gp, pZb, &(leaf_facet[i_vertex]), pD->pP);
   }
  } else {
   vertex[0]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (pL->zl, -leaf_scaling*pL->d1/2.0));
   vertex[1]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (pL->zl,  leaf_scaling*pL->d1/2.0));
   for (i_vertex=0;i_vertex<2;i_vertex++) {
    vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
    vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
   }
   for (i_vertex=0; i_vertex<2; i_vertex++) {
    vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
   }
   leaf_gp	= colour (pD->pL, &leaf_material, pL->xl);
   drawVectorZbufferLine (pGR, leaf_gp, pZb, pD->pP, vertex[0], vertex[1]);
  }
  pL	= pL->next;
 }
#endif

/*******************/
/* Draw the crowns */
/*******************/

 pC	= pT->CrownVolume.head;
 x	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
 y	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
 z	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
 np	= Cartesian_Assign_d3Vector (-pC->sx, -pC->sy, 1.0);
 d3Vector_insitu_normalise (&np);
 npdotz	= d3Vector_scalar_product (np, z);
 if (fabs(1.0 - fabs(npdotz)) < FLT_EPSILON) {
  xp	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
  yp	= Cartesian_Assign_d3Vector (0.0, 1.0, 0.0);
 } else {
  yp	= d3Vector_cross_product (np,z);
  d3Vector_insitu_normalise (&yp);
  xp	= d3Vector_cross_product (yp, np);
  d3Vector_insitu_normalise (&xp);
 }

 for (iCrown=0L; iCrown < pT->CrownVolume.n; iCrown++) {
  Nazimuth	= (int) (2.0*DPI_RAD*pC->d2 / dres);
  if (Nazimuth < FOREST_GRAPHIC_MIN_CROWN_SIDES) {
   Nazimuth	= FOREST_GRAPHIC_MIN_CROWN_SIDES;
  }
  if (Nazimuth > FOREST_GRAPHIC_MAX_CROWN_SIDES) {
   Nazimuth = FOREST_GRAPHIC_MAX_CROWN_SIDES;
  }
  Nsections	= (int) (pC->d3/dres) + 1;
  if (Nsections < FOREST_GRAPHIC_MIN_CROWN_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MIN_CROWN_SECTIONS;
  }
  if (Nsections > FOREST_GRAPHIC_MAX_CROWN_SECTIONS) {
   Nsections = FOREST_GRAPHIC_MAX_CROWN_SECTIONS;
  }
  deltah	= pC->d3 / (double) Nsections;
  dtheta	= 2.0*DPI_RAD / (double) Nazimuth;
  Copy_d3Vector (&b0, &(pC->base));
  Copy_d3Vector (&z,  &(pC->axis));

  for (i_section = 0; i_section < Nsections; i_section++) {
   s0	= d3Vector_sum (b0, d3Vector_double_multiply (z, i_section*deltah));
   s1	= d3Vector_sum (s0, d3Vector_double_multiply (z, deltah - ROUNDING_ERROR));
   for (i_azimuth = 0; i_azimuth < Nazimuth; i_azimuth++) {
    theta0		= i_azimuth * dtheta;
	theta1		= theta0 + dtheta;
	costheta0	= cos(theta0);
	sintheta0	= sin(theta0);
	costheta1	= cos(theta1);
	sintheta1	= sin(theta1);
	a0			= d3Vector_double_multiply (xp, costheta0);
	a0			= d3Vector_sum (a0, d3Vector_double_multiply (yp, sintheta0));
	a1			= d3Vector_double_multiply (xp, costheta1);
	a1			= d3Vector_sum (a1, d3Vector_double_multiply (yp, sintheta1));
	Assign_Ray_d3V (&ray0, &s0, &a0);
	Assign_Ray_d3V (&ray1, &s1, &a0);
	Assign_Ray_d3V (&ray2, &s1, &a1);
	Assign_Ray_d3V (&ray3, &s0, &a1);
	/****************************************************************/
	/* Calculate panel vertices using ray intersection:             */
	/* remember bounding planes are parallel to mean terrain slope. */
	/****************************************************************/
	rtn_value	= RayCrownIntersection (&ray0, pC, &sa1, &alpha1, &sa2, &alpha2);
	if (rtn_value == NO_RAYCROWN_ERRORS) {
	 if (alpha1 > 0.0) {
	  Copy_d3Vector (&(vertex[0]), &sa1);
	 } else {
 	  Copy_d3Vector (&(vertex[0]), &sa2);
	 }
	} else {
#ifndef DRAWING_SUPPRESS_ERROR_MESSAGES
	 printf ("ERROR: drawTree failed to find crown intersection (1).\n");
#endif
	 switch (pC->shape) {
      case CROWN_CYLINDER:	radius	= pC->d2; break;
	  case CROWN_CONE:		radius	= pC->d2*(pC->d3-i_section*deltah)/pC->d3; break;
	  case CROWN_SPHEROID:	radius	= pC->d2*sqrt(1.0-((pC->d1-pC->d3+i_section*deltah)*(pC->d1-pC->d3+i_section*deltah)/(pC->d1*pC->d1))); break;
	  default:				radius	= pC->d2; break;
	 }
	 vertex[0]	= d3Vector_sum (s0, d3Vector_double_multiply (a0, radius));
	}
	rtn_value	= RayCrownIntersection (&ray3, pC, &sa1, &alpha1, &sa2, &alpha2);
	if (rtn_value == NO_RAYCROWN_ERRORS) {
	 if (alpha1 > 0.0) {
	  Copy_d3Vector (&(vertex[3]), &sa1);
	 } else {
 	  Copy_d3Vector (&(vertex[3]), &sa2);
	 }
	} else {
#ifndef DRAWING_SUPPRESS_ERROR_MESSAGES
	 printf ("ERROR: drawTree failed to find crown intersection (4).\n");
#endif
	 switch (pC->shape) {
      case CROWN_CYLINDER:	radius	= pC->d2; break;
	  case CROWN_CONE:		radius	= pC->d2*(pC->d3-i_section*deltah)/pC->d3; break;
	  case CROWN_SPHEROID:	radius	= pC->d2*sqrt(1.0-((pC->d1-pC->d3+i_section*deltah)*(pC->d1-pC->d3+i_section*deltah)/(pC->d1*pC->d1))); break;
	  default:				radius	= pC->d2; break;
	 }
	 vertex[3]	= d3Vector_sum (s0, d3Vector_double_multiply (a1, radius));
	}

    if ((i_section != Nsections-1) || (pC->shape == CROWN_CYLINDER)) {
	 rtn_value	= RayCrownIntersection (&ray1, pC, &sa1, &alpha1, &sa2, &alpha2);
	 if (rtn_value == NO_RAYCROWN_ERRORS) {
	  if (alpha1 > 0.0) {
	   Copy_d3Vector (&(vertex[1]), &sa1);
	  } else {
 	   Copy_d3Vector (&(vertex[1]), &sa2);
	  }
	 } else {
#ifndef DRAWING_SUPPRESS_ERROR_MESSAGES
	  printf ("ERROR: drawTree failed to find crown intersection (2).\n");
#endif
	  switch (pC->shape) {
       case CROWN_CYLINDER:	radius	= pC->d2; break;
	   case CROWN_CONE:		radius	= pC->d2*(pC->d3-i_section*deltah)/pC->d3; break;
	   case CROWN_SPHEROID:	radius	= pC->d2*sqrt(1.0-((pC->d1-pC->d3+(i_section+1)*deltah)*(pC->d1-pC->d3+(i_section+1)*deltah)/(pC->d1*pC->d1))); break;
	   default:				radius	= pC->d2; break;
	  }
	  vertex[1]	= d3Vector_sum (s1, d3Vector_double_multiply (a0, radius));
	 }
	 rtn_value	= RayCrownIntersection (&ray2, pC, &sa1, &alpha1, &sa2, &alpha2);
	 if (rtn_value == NO_RAYCROWN_ERRORS) {
	  if (alpha1 > 0.0) {
	   Copy_d3Vector (&(vertex[2]), &sa1);
	  } else {
 	   Copy_d3Vector (&(vertex[2]), &sa2);
	  }
	 } else {
#ifndef DRAWING_SUPPRESS_ERROR_MESSAGES
	  printf ("ERROR: drawTree failed to find crown intersection (3).\n");
#endif
	  switch (pC->shape) {
       case CROWN_CYLINDER:	radius	= pC->d2; break;
	   case CROWN_CONE:		radius	= pC->d2*(pC->d3-i_section*deltah)/pC->d3; break;
	   case CROWN_SPHEROID:	radius	= pC->d2*sqrt(1.0-((pC->d1-pC->d3+(i_section+1)*deltah)*(pC->d1-pC->d3+(i_section+1)*deltah)/(pC->d1*pC->d1))); break;
	   default:				radius	= pC->d2; break;
	  }
	  vertex[2]	= d3Vector_sum (s1, d3Vector_double_multiply (a1, radius));
	 }
	 vertex[4]	= d3Vector_sum (d3Vector_sum (vertex[0], vertex[1]), d3Vector_sum (vertex[2], vertex[3]));
	 vertex[4]	= d3Vector_double_multiply (vertex[4], 0.25);
	} else {
	 Copy_d3Vector (&(vertex[1]), &s1);  
	 Copy_d3Vector (&(vertex[2]), &s1);
	 Copy_d3Vector (&(vertex[4]), &s1);
	}
    /************************************************************/
    /* Transform the vertex coordinates into the viewing volume */
    /************************************************************/
    for (i_vertex=0;i_vertex<5;i_vertex++) {
     vertex[i_vertex]		 = d33Matrix_d3Vector_product (*(pD->pRx), vertex[i_vertex]);
     vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], *(pD->pTzy));
    }
    /*************************************************/
    /* Convert the coordinates into the screen frame */
    /*************************************************/
    for (i_vertex=0; i_vertex<5; i_vertex++) {
     vertex[i_vertex]	= Perspective_Global2Screen (pD->pP, vertex[i_vertex]);
    }
    /*************************************/
    /* Turn crown panel into four facets */
    /*************************************/
	if ((i_section != Nsections-1) || (pC->shape == CROWN_CYLINDER)) {
     Assign_Facet	(&(crown_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
     Assign_Facet	(&(crown_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
     Assign_Facet	(&(crown_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
     Assign_Facet	(&(crown_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
	} else {
	 Assign_Facet	(&(crown_facet[0]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
	}
	if ((i_section != Nsections-1) || (pC->shape == CROWN_CYLINDER)) {
     /**************************/
     /* Calculate facet colour */
     /**************************/
	 if (iCrown == 0) {
	  crown_gp	= colour (pD->pL, &living_crown_material, crown_facet[0].n);
	 } else {
	  crown_gp	= colour (pD->pL, &dry_crown_material, crown_facet[0].n);
	 }
     /********************************/
     /* Draw facets in graphic image */
     /********************************/
     for (i_facet=0; i_facet<4; i_facet++) {
#ifdef FOREST_GRAPHIC_DRAW_CROWN
      drawFacet_alphab (pGR, crown_gp, pZb, &(crown_facet[i_facet]), pD->pP, FOREST_GRAPHIC_CROWN_ALPHA_BLEND);
#endif
     }
	} else {
	 if (iCrown == 0) {
	   crown_gp	= colour (pD->pL, &living_crown_material, crown_facet[0].n);
	 } else {
	   crown_gp	= colour (pD->pL, &dry_crown_material, crown_facet[0].n);
	 }
     /*******************************/
     /* Draw facet in graphic image */
     /*******************************/
#ifdef FOREST_GRAPHIC_DRAW_CROWN
	 drawFacet_alphab (pGR, crown_gp, pZb, &(crown_facet[0]), pD->pP, FOREST_GRAPHIC_CROWN_ALPHA_BLEND);
#endif
	}
   }
  }
  pC	= pC->next;
 }

 return;
}

void		Forest_Graphic					(PolSARproSim_Record *pPR)
{
/*****************************************************************/
/* Should create a perspective tree graphic image in .sim format */
/* All objects are rotated about xg into the viewing ref. frame. */
/*****************************************************************/
 const double		deg2rad		= DPI_RAD/180.0;
 Graphic_Record		Forest_Image;
 char				*forest_image_filename;
 SIM_Record			Zbuffer;
 char				*zbuffer_filename;
 double				image_height;
 double				image_width;
 double				image_depth;
 double				near_plane_distance;
 double				far_plane_distance;
 double				range_shift;
 double				height_shift;
 double				min_range, max_range;
 double				min_height, max_height;
 d33Matrix			Rx;
 d3Vector			Tzy;
 int				ix, iy;
 sim_pixel			pz;
/********************************/
/* For ground surface rendering */
/********************************/
 double				Lx			= pPR->Lx;
 double				Ly			= pPR->Ly;
 int				nx			= pPR->nx;
 int				ny			= pPR->ny;
 double				deltax		= Lx/(double)nx;
 double				deltay		= Ly/(double)ny;
 double				x,y;
 d3Vector			vertex[5];
 Facet				ground_facet[4];
 int				i;
 graphic_pixel		ground_gp;
/****************************/
/* Global coordinate system */
/****************************/
 d3Vector			xg, yg, zg;
/*********************************/
/* Perspective projection record */
/*********************************/
 Perspective		Precord;
/******************/
/* Lighting model */
/******************/
 Lighting_Record	Lrec;
 d3Vector			view;
 d3Vector			light;
/*************/
/* Materials */
/*************/
 Material			ground_material;
/****************/
/* Tree drawing */
/****************/
 Tree				tree1;
 int				itree;
 Drawing_Record		dRec;
/****************************/
/* Drawing short vegetation */
/****************************/
#ifdef FOREST_GRAPHIC_DRAW_SHORTV_SURFACE
 Material			shortv_material;
 Facet				shortv_facet[4];
 graphic_pixel		shortv_gp;
#endif
#ifdef FOREST_GRAPHIC_DRAW_SHORTV_ELEMENTS
 Material			shrtve_material;
 Facet				shrtve_facet[4];
 graphic_pixel		shrtve_gp;
 int				iElement, Nelements;
 double				z;
 d3Vector			sv_centre;
 double				sv_d1, sv_d2, sv_d3;
 double				theta, phi;
 double				moisture;
 Complex			permittivity;
 Leaf				leaf1;
 int				sv_species;
 const double		leaf_scaling	= 10.0*pPR->mean_tree_height/25.0;
 int				i_vertex;
#endif
/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to Forest_Graphic ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to Forest_Graphic ... \n");
 fflush  (pPR->pLogFile);

/******************/
/* Initialisation */
/******************/

 Create_d3Vector (&xg);
 Create_d3Vector (&yg);
 Create_d3Vector (&zg);
 xg	= Cartesian_Assign_d3Vector (1.0, 0.0, 0.0);
 yg	= Cartesian_Assign_d3Vector	(0.0, 1.0, 0.0);
 zg	= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
 image_height			 = pPR->Ly*cos(pPR->incidence_angle[0]) + pPR->mean_tree_height*sin(pPR->incidence_angle[0]);
 image_width			 = pPR->Lx;
 image_depth			 = pPR->Ly*sin(pPR->incidence_angle[0])+pPR->mean_tree_height*cos(pPR->incidence_angle[0]);
 image_height			*= FOREST_GRAPHIC_IMAGE_SIZE_FACTOR;
 image_width			*= FOREST_GRAPHIC_IMAGE_SIZE_FACTOR;
 image_depth			*= FOREST_GRAPHIC_IMAGE_SIZE_FACTOR;
 pPR->gny				= FOREST_GRAPHIC_NY;
 pPR->gnx				= (int) (FOREST_GRAPHIC_NY*image_width/image_height);
 near_plane_distance	= FOREST_NEAR_PLANE_FACTOR*image_depth;
 far_plane_distance		= near_plane_distance + image_depth;
 range_shift			= near_plane_distance + (pPR->Ly/2.0)*sin(pPR->incidence_angle[0])+pPR->mean_tree_height*cos(pPR->incidence_angle[0]);
 height_shift			= -fabs((image_height/2.0/FOREST_GRAPHIC_IMAGE_SIZE_FACTOR) - (pPR->Ly/2.0)*cos(pPR->incidence_angle[0]));
 Create_d33Matrix (&Rx);
 Rx						= d33Matrix_xRotation (2.0*atan(1.0)-pPR->incidence_angle[0]);
 Create_d3Vector (&Tzy);
 Tzy					= d3Vector_double_multiply (yg, range_shift);
 Tzy					= d3Vector_sum (Tzy, d3Vector_double_multiply (zg, height_shift));
 forest_image_filename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("vegetation_image.gri")+1, sizeof(char));
 strcpy  (forest_image_filename, pPR->pMasterDirectory);
 strcat  (forest_image_filename, "vegetation_image.gri");
 Create_Graphic_Record		(&Forest_Image);
 Initialise_Graphic_Record	(&Forest_Image, forest_image_filename, pPR->gnx, pPR->gny, "PolSARproSim forest graphic");
 free (forest_image_filename);
 Background_Graphic_Record	(&Forest_Image, FOREST_GRAPHIC_BACKGROUND_RED, FOREST_GRAPHIC_BACKGROUND_GREEN, FOREST_GRAPHIC_BACKGROUND_BLUE);
 zbuffer_filename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("zbuffer.sim")+1, sizeof(char));
 strcpy  (zbuffer_filename, pPR->pMasterDirectory);
 strcat  (zbuffer_filename, "zbuffer.sim");
 Create_SIM_Record			(&Zbuffer);
 Initialise_SIM_Record		(&Zbuffer, zbuffer_filename, pPR->gnx, pPR->gny, SIM_FLOAT_TYPE,pPR->Lx, pPR->Ly, "Forest_Graphic z-buffer"); 
 free (zbuffer_filename);
 pz.simpixeltype		= SIM_FLOAT_TYPE;
 pz.data.f				= (float) far_plane_distance;
 for (ix=0; ix<pPR->gnx; ix++) {
  for (iy=0; iy<pPR->gny; iy++) {
   putSIMpixel (&Zbuffer, pz, ix, iy);
  }
 }
 Precord.Px		= image_width;
 Precord.Py		= image_height;
 Precord.Pz		= image_depth;
 Precord.nx		= pPR->gnx;
 Precord.ny		= pPR->gny;
 Precord.dx		= Precord.Px/Precord.nx;
 Precord.dy		= Precord.Py/Precord.ny;
 Precord.Znear	= near_plane_distance;
 Precord.Zfar	= far_plane_distance;
 light			= Polar_Assign_d3Vector (1.0, deg2rad*FOREST_LIGHT_POLAR_ANGLE, deg2rad*FOREST_LIGHT_AZIMUTH_ANGLE);
 view			= d3Vector_normalise (d3Vector_double_multiply (yg,-1.0));
 Create_Lighting_Record (&Lrec, FOREST_GRAPHIC_AMBIENT_INTENSITY, FOREST_GRAPHIC_INCIDENT_INTENSITY, 
						 &light, &view);
 Create_Material	(&ground_material, FOREST_GRAPHIC_GROUND_KA, FOREST_GRAPHIC_GROUND_KD, 
					 FOREST_GRAPHIC_GROUND_KS, FOREST_GRAPHIC_GROUND_SR, FOREST_GRAPHIC_GROUND_SG,
					 FOREST_GRAPHIC_GROUND_SB);
#ifdef FOREST_GRAPHIC_DRAW_SHORTV_SURFACE
 Create_Material	(&shortv_material, FOREST_GRAPHIC_SHORTV_KA, FOREST_GRAPHIC_SHORTV_KD, 
					 FOREST_GRAPHIC_SHORTV_KS, FOREST_GRAPHIC_SHORTV_SR, FOREST_GRAPHIC_SHORTV_SG,
					 FOREST_GRAPHIC_SHORTV_SB);
#endif
#ifdef FOREST_GRAPHIC_DRAW_SHORTV_ELEMENTS
 Create_Material	(&shrtve_material, FOREST_GRAPHIC_SHORTV_KA, FOREST_GRAPHIC_SHORTV_KD, 
					 FOREST_GRAPHIC_SHORTV_KS, FOREST_GRAPHIC_SHORTV_SR, FOREST_GRAPHIC_SHORTV_SG,
					 FOREST_GRAPHIC_SHORTV_SB);
#endif

/*********************************************************************************/
/* Rendering the ground: note that the ground heights are stored at grid centres */
/*********************************************************************************/
 
 min_range	=  1.0e+30;
 max_range	= -1.0e+30;
 min_height	=  1.0e+30;
 max_height	= -1.0e+30;
 for (i=0; i<5; i++) {
  Create_d3Vector (&(vertex[i]));
 }
 for (i=0; i<4; i++) {
  Create_Facet (&(ground_facet[i]));
 }

#ifdef VERBOSE_POLSARPROSIM
 printf ("\nDrawing the ground ...\n");
#endif
 fprintf (pPR->pLogFile, "Drawing the ground ...\n");
 fflush  (pPR->pLogFile);

 for (ix=0; ix<pPR->Ground_Height.nx; ix++) {
  x	= ix*deltax - Lx/2.0;
  for (iy=0; iy<pPR->Ground_Height.ny; iy++) {
   y	= iy*deltay - Ly/2.0;
   y	= -y;
   /***************************************/
   /* Find ground grid corners and centre */
   /***************************************/
   vertex[0]	= Cartesian_Assign_d3Vector (x, y, ground_height (pPR, x, y));
   vertex[1]	= Cartesian_Assign_d3Vector (x+deltax, y, ground_height (pPR, x+deltax, y));
   vertex[2]	= Cartesian_Assign_d3Vector (x+deltax, y-deltay, ground_height (pPR, x+deltax, y-deltay));
   vertex[3]	= Cartesian_Assign_d3Vector (x, y-deltay, ground_height (pPR, x, y-deltay));
   vertex[4]	= Cartesian_Assign_d3Vector (x+(deltax/2.0), y-(deltay/2.0), ground_height (pPR, x+(deltax/2.0), y-(deltay/2.0)));
   /**********************************************************/
   /* Transform the grid coordinates into the viewing volume */
   /**********************************************************/
   for (i=0;i<5;i++) {
    vertex[i]		 = d33Matrix_d3Vector_product (Rx, vertex[i]);
	vertex[i]		 = d3Vector_sum (vertex[i], Tzy);
	if (vertex[i].x[1] < min_range) {
	 min_range	= vertex[i].x[1];
	} else {
	 if (vertex[i].x[1] > max_range) {
	  max_range	= vertex[i].x[1];
	 }
	}
	if (vertex[i].x[2] < min_height) {
	 min_height	= vertex[i].x[2];
	} else {
	 if (vertex[i].x[2] > max_height) {
	  max_height	= vertex[i].x[2];
	 }
	}
   }
   /*************************************************/
   /* Convert the coordinates into the screen frame */
   /*************************************************/
   for (i=0; i<5; i++) {
    vertex[i]	= Perspective_Global2Screen (&Precord, vertex[i]);
   }
   /*************************************/
   /* Turn ground grid into four facets */
   /*************************************/
   Assign_Facet	(&(ground_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
   Assign_Facet	(&(ground_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
   Assign_Facet	(&(ground_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
   Assign_Facet	(&(ground_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
   /**************************/
   /* Calculate facet colour */
   /**************************/
   ground_gp	= colour (&Lrec, &ground_material, ground_facet[0].n);
   /*******************************/
   /* Draw facets in graphic image */
   /*******************************/
   for (i=0; i<4; i++) {
    drawFacet (&Forest_Image, ground_gp, &Zbuffer, &(ground_facet[i]), &Precord);
   }
  }
 }

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n... finished drawing the ground.\n");
#endif
 fprintf (pPR->pLogFile, "... finished drawing the ground.\n");
 fflush  (pPR->pLogFile);

/**********************************/
/* Rendering understorey elements */
/**********************************/

#ifdef FOREST_GRAPHIC_DRAW_SHORTV_ELEMENTS
#ifdef VERBOSE_POLSARPROSIM
 printf ("\nDrawing short vegetation elements ...\n");
#endif
 fprintf (pPR->pLogFile, "Drawing short vegetation elements ...\n");
 fflush  (pPR->pLogFile);

 Create_Leaf (&leaf1);
 Nelements	= FOREST_GRAPHIC_SHORTV_FACTOR;
 for (ix=0; ix<pPR->nx; ix++) {
  x	= ix*deltax - Lx/2.0;
  for (iy=0; iy<pPR->ny; iy++) {
   y	= iy*deltay - Ly/2.0;
   y	= -y;
   z	= ground_height (pPR, x+deltax/2.0, y-deltay/2.0);
   for (iElement=0; iElement<Nelements; iElement++) {
	sv_centre	= Cartesian_Assign_d3Vector (x+deltax*drand(), y-deltay*drand(), z+pPR->shrt_vegi_depth*drand());
	if (drand() < FOREST_GRAPHIC_SHORTV_STEM_FRACTION) {
	 /***************************/
	 /* Realise a stem (needle) */
	 /***************************/
	 sv_species	= POLSARPROSIM_PINE_NEEDLE;
	 sv_d1		= POLSARPROSIM_SHORTV_STEM_LENGTH;
 	 sv_d2		= POLSARPROSIM_SHORTV_STEM_RADIUS;
 	 sv_d3		= POLSARPROSIM_SHORTV_STEM_RADIUS;
	} else {
	 /******************/
	 /* Realise a leaf */
	 /******************/
	 sv_species	= POLSARPROSIM_DECIDUOUS_LEAF;
 	 sv_d1		= POLSARPROSIM_SHORTV_LEAF_LENGTH;
 	 sv_d2		= POLSARPROSIM_SHORTV_LEAF_WIDTH;
 	 sv_d3		= POLSARPROSIM_SHORTV_LEAF_THICKNESS;
	}
    phi				= 2.0*DPI_RAD*drand();
	theta			= vegi_polar_angle ();
	moisture		= Leaf_Moisture	(pPR->species, pPR->mean_tree_height);
    permittivity	= vegetation_permittivity (moisture, pPR->frequency);
    Assign_Leaf	(&leaf1, sv_species, sv_d1, sv_d2, sv_d3, theta, phi, moisture, permittivity, sv_centre);
	/***************************/
	/* Draw the foliage object */
	/***************************/
    Copy_d3Vector (&(vertex[4]), &(leaf1.cl));
    if (leaf1.species == POLSARPROSIM_DECIDUOUS_LEAF) {
     vertex[0]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (leaf1.xl, -leaf_scaling*leaf1.d2/2.0));
     vertex[0]	= d3Vector_sum (vertex[0], d3Vector_double_multiply (leaf1.yl, -leaf_scaling*leaf1.d1/2.0));
     vertex[1]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (leaf1.xl, -leaf_scaling*leaf1.d2/2.0));
     vertex[1]	= d3Vector_sum (vertex[1], d3Vector_double_multiply (leaf1.yl,  leaf_scaling*leaf1.d1/2.0));
     vertex[2]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (leaf1.xl,  leaf_scaling*leaf1.d2/2.0));
     vertex[2]	= d3Vector_sum (vertex[2], d3Vector_double_multiply (leaf1.yl,  leaf_scaling*leaf1.d1/2.0));
     vertex[3]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (leaf1.xl,  leaf_scaling*leaf1.d2/2.0));
     vertex[3]	= d3Vector_sum (vertex[3], d3Vector_double_multiply (leaf1.yl, -leaf_scaling*leaf1.d1/2.0));
     for (i_vertex=0;i_vertex<5;i_vertex++) {
      vertex[i_vertex]		 = d33Matrix_d3Vector_product (Rx, vertex[i_vertex]);
	  vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], Tzy);
     }
     for (i_vertex=0; i_vertex<5; i_vertex++) {
      vertex[i_vertex]	= Perspective_Global2Screen (&Precord, vertex[i_vertex]);
     }
     Assign_Facet	(&(shrtve_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
     Assign_Facet	(&(shrtve_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
     Assign_Facet	(&(shrtve_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
     Assign_Facet	(&(shrtve_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
     for (i_vertex=0; i_vertex<4; i_vertex++) {
      if (i_vertex == 0) {
       shrtve_gp	= colour (&Lrec, &shrtve_material, shrtve_facet[i_vertex].n);
      }
      drawFacet (&Forest_Image, shrtve_gp, &Zbuffer, &(shrtve_facet[i_vertex]), &Precord);
     }
    } else {
     vertex[0]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (leaf1.zl, -leaf_scaling*leaf1.d1/2.0));
     vertex[1]	= d3Vector_sum (vertex[4], d3Vector_double_multiply (leaf1.zl,  leaf_scaling*leaf1.d1/2.0));
     for (i_vertex=0;i_vertex<2;i_vertex++) {
      vertex[i_vertex]		 = d33Matrix_d3Vector_product (Rx, vertex[i_vertex]);
	  vertex[i_vertex]		 = d3Vector_sum (vertex[i_vertex], Tzy);
     }
     for (i_vertex=0; i_vertex<2; i_vertex++) {
      vertex[i_vertex]	= Perspective_Global2Screen (&Precord, vertex[i_vertex]);
     }
     shrtve_gp	= colour (&Lrec, &shrtve_material, leaf1.xl);
     drawVectorZbufferLine (&Forest_Image, shrtve_gp, &Zbuffer, &Precord, vertex[0], vertex[1]);
    }
   }
  }
 }
#ifdef VERBOSE_POLSARPROSIM
 printf ("\nFinished drawing short vegetation elements ...\n");
#endif
 fprintf (pPR->pLogFile, "Finished drawing short vegetation elements ...\n");
 fflush  (pPR->pLogFile);
#endif

/************************/
/* Rendering the forest */
/************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\nDrawing the forest ...\n");
#endif
 fprintf (pPR->pLogFile, "Drawing the forest ...\n");
 fflush  (pPR->pLogFile);

 dRec.pL	= &Lrec;
 dRec.pP	= &Precord;
 dRec.pRx	= &Rx;
 dRec.pTzy	= &Tzy;
 Create_Tree (&tree1);
 for (itree=0; itree<pPR->Trees; itree++) {
  Realise_Tree	(&tree1, itree, pPR);
  drawTree		(&tree1, &Forest_Image, &Zbuffer, &dRec);
 }
 Destroy_Tree (&tree1);

/**********************************************/
/* Report progress if running in VERBOSE mode */
/**********************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n... finished drawing the forest.\n");
#endif
 fprintf (pPR->pLogFile, "... finished drawing the forest.\n");
 fflush  (pPR->pLogFile);

/**********************************/
/* Rendering the short vegetation */
/**********************************/

#ifdef FOREST_GRAPHIC_DRAW_SHORTV_SURFACE
#ifdef VERBOSE_POLSARPROSIM
 printf ("\nDrawing the short vegetation surface ...\n");
#endif
 fprintf (pPR->pLogFile, "Drawing the short vegetation surface ...\n");
 fflush  (pPR->pLogFile);

 for (ix=0; ix<pPR->Ground_Height.nx; ix++) {
  x	= ix*deltax - Lx/2.0;
  for (iy=0; iy<pPR->Ground_Height.ny; iy++) {
   y	= iy*deltay - Ly/2.0;
   y	= -y;
   /***************************************/
   /* Find ground grid corners and centre */
   /***************************************/
   vertex[0]	= Cartesian_Assign_d3Vector (x, y, pPR->shrt_vegi_depth+ground_height (pPR, x, y));
   vertex[1]	= Cartesian_Assign_d3Vector (x+deltax, y, pPR->shrt_vegi_depth+ground_height (pPR, x+deltax, y));
   vertex[2]	= Cartesian_Assign_d3Vector (x+deltax, y-deltay, pPR->shrt_vegi_depth+ground_height (pPR, x+deltax, y-deltay));
   vertex[3]	= Cartesian_Assign_d3Vector (x, y-deltay, pPR->shrt_vegi_depth+ground_height (pPR, x, y-deltay));
   vertex[4]	= Cartesian_Assign_d3Vector (x+(deltax/2.0), y-(deltay/2.0), pPR->shrt_vegi_depth+ground_height (pPR, x+(deltax/2.0), y-(deltay/2.0)));
   /**********************************************************/
   /* Transform the grid coordinates into the viewing volume */
   /**********************************************************/
   for (i=0;i<5;i++) {
    vertex[i]		 = d33Matrix_d3Vector_product (Rx, vertex[i]);
	vertex[i]		 = d3Vector_sum (vertex[i], Tzy);
	if (vertex[i].x[1] < min_range) {
	 min_range	= vertex[i].x[1];
	} else {
	 if (vertex[i].x[1] > max_range) {
	  max_range	= vertex[i].x[1];
	 }
	}
	if (vertex[i].x[2] < min_height) {
	 min_height	= vertex[i].x[2];
	} else {
	 if (vertex[i].x[2] > max_height) {
	  max_height	= vertex[i].x[2];
	 }
	}
   }
   /*************************************************/
   /* Convert the coordinates into the screen frame */
   /*************************************************/
   for (i=0; i<5; i++) {
    vertex[i]	= Perspective_Global2Screen (&Precord, vertex[i]);
   }
   /*************************************/
   /* Turn ground grid into four facets */
   /*************************************/
   Assign_Facet	(&(shortv_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
   Assign_Facet	(&(shortv_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
   Assign_Facet	(&(shortv_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
   Assign_Facet	(&(shortv_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
   for (i=0; i<4; i++) {
    /**************************/
    /* Calculate facet colour */
    /**************************/
	if (i==0) {
	 shortv_gp	= colour (&Lrec, &shortv_material, shortv_facet[i].n);
	}
    /*******************************/
    /* Draw facet in graphic image */
    /*******************************/
    drawFacet_alphab (&Forest_Image, shortv_gp, &Zbuffer, &(shortv_facet[i]), &Precord, FOREST_GRAPHIC_SHORTV_ALPHA_BLEND);
   }
  }
 }

#ifdef VERBOSE_POLSARPROSIM
 printf ("\nFinished drawing the short vegetation surface ...\n");
#endif
 fprintf (pPR->pLogFile, "Finished drawing the short vegetation surface ...\n");
 fflush  (pPR->pLogFile);
#endif

/****************************/
/* Write to a GRI file type */
/****************************/

#ifndef POLSARPROSIM_NOGRIOUTPUT
 Write_Graphic_Record	(&Forest_Image);
#endif

/****************************/
/* Write to a BMP file type */
/****************************/

 forest_image_filename	= (char*) calloc (strlen(pPR->pMasterDirectory)+strlen("vegetation_image.bmp")+1, sizeof(char));
 strcpy  (forest_image_filename, pPR->pMasterDirectory);
 strcat  (forest_image_filename, "vegetation_image.bmp");
 Write_GRIasRGBbmp		(forest_image_filename, &Forest_Image);
 free (forest_image_filename);

/***********/
/* Tidy up */
/***********/

 Destroy_SIM_Record		(&Zbuffer);
 Destroy_Graphic_Record (&Forest_Image);

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/

#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to Forest_Graphic\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to Forest_Graphic\n\n");
 fflush  (pPR->pLogFile);

/********************************/
/* Increment progress indicator */
/********************************/

 pPR->progress++;

/********************************/
/* Report progress if requested */
/********************************/

#ifdef POLSARPROSIM_MAX_PROGRESS
 PolSARproSim_indicate_progress (pPR);
#endif

 return;
}
