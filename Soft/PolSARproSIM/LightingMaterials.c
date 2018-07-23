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
 * Module      : LightingMaterials.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"LightingMaterials.h"

/***********************************/
/* Lighting and Material Functions */
/***********************************/

 void	Create_Lighting_Record	(Lighting_Record *pLR, double Ia, double Ii, 
								 d3Vector *pl, d3Vector *pv)
 {
  pLR->Ia	= Ia;
  pLR->Ii	= Ii;
  Copy_d3Vector (&(pLR->light), pl);
  Copy_d3Vector (&(pLR->view), pv);
  pLR->Hvec	= CalculateH (pLR->light, pLR->view);
  return;
 }

double	intensity	(Lighting_Record *pLR, Material *pM, d3Vector n)
{
 double		Itotal	= 0.0;
 double		ldotn	= fabs (d3Vector_scalar_product (pLR->light, n));
 double		hdotn	= fabs (d3Vector_scalar_product (pLR->Hvec, n));

 Itotal		= pLR->Ia*pM->mR.ka + pLR->Ii*(pM->mR.kd*ldotn+pM->mR.ks*hdotn);
 Itotal		/= (pLR->Ia*pM->mR.ka + pLR->Ii*(pM->mR.kd+pM->mR.ks));
 return		(Itotal);
}

graphic_pixel	colour		(Lighting_Record *pLR, Material *pM, d3Vector n)
{
 graphic_pixel	gp;
 double			B	= intensity (pLR, pM, n);

 gp.red		= (unsigned char) (255.0*B*pM->mC.Sr);
 gp.green	= (unsigned char) (255.0*B*pM->mC.Sg);
 gp.blue	= (unsigned char) (255.0*B*pM->mC.Sb);
 return(gp);
}

d3Vector		CalculateH	(d3Vector l, d3Vector v)
{
 d3Vector	h;
 
 Create_d3Vector (&h);
 h	= d3Vector_sum (l, v);
 d3Vector_insitu_normalise (&h);
 return (h);
}

 void			Create_Material			(Material *pM, double ka, double kd, double ks,
										 double sr, double sg, double sb)
 {
  double	st	= sqrt(sr*sr+sg*sg+sb*sb);
  double	smax;

  sr	/= st;
  sg	/= st;
  sb	/= st;
  if (sr>sg) {
   smax	= sr;
  } else {
   smax	= sg;
  }
  if (sb > smax) {
   smax	= sb;
  }
  sr	/= smax;
  sg	/= smax;
  sb	/= smax;
  pM->mR.ka	= ka;
  pM->mR.kd	= kd;
  pM->mR.ks	= ks;
  pM->mC.Sr	= sr;
  pM->mC.Sg	= sg;
  pM->mC.Sb	= sb;
  return;
 }
