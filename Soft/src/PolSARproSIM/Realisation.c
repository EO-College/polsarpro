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
 * Module      : Realisation.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"Realisation.h"

/***************************************/
/* Plant element polar angle generator */
/***************************************/

double		vegi_polar_angle				(void)
{
 double		theta	= acos (2.0*drand () - 1.0);
 return (theta);
}

/*****************************/
/* Tree realisation routines */
/*****************************/

void		Create_HEDGE_Global_Crown  (Tree *pT, PolSARproSim_Record *pPR)
{
/*****************************************************************/
/* The global HEDGE crown volume is a single, truncated cylinder */
/*****************************************************************/
 Crown		c;
 int		shape	= CROWN_CYLINDER;
 d3Vector	axis	= Zero_d3Vector ();
 double		d1		= pT->height;
 double		d2		= pT->radius;
 double		d3		= pT->height;
 double		beta	= atan2 (d2, d1);

 Create_Crown		(&c);
 axis				= Stem_Direction (pT->species);
 Assign_Crown		(&c, shape, beta, d1, d2, d3, pT->base, axis, pPR->slope_x, pPR->slope_y);
 Crown_head_add		(&(pT->CrownVolume), &c);
 Destroy_Crown		(&c);
 return;
}

void		Create_PINE001_Global_Crown  (Tree *pT, PolSARproSim_Record *pPR)
{
/**************************************************************************************/
/* The global PINE001 crown volume is a truncated cylinder below a truncated spheroid */
/* The convention is that the upper living crown is always at the head of the list.   */
/**************************************************************************************/
 Crown		c;
 int		shape	= CROWN_SPHEROID;
 double		l		= Realise_Living_Crown_Depth (pT->species, pT->height);
 double		e		= sqrt (pT->radius*pT->radius + l*l);
 double		beta	= atan2 (pT->radius, l);
 d3Vector	axis	= Stem_Direction (pT->species);
 double		d1		= e*cos(beta);
 double		d2		= e*sin(beta);
 double		d3		= d1;
 d3Vector	base;

 Create_d3Vector	(&base);
 Create_Crown		(&c);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-d3));
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_head_add		(&(pT->CrownVolume), &c);
 shape				= CROWN_CYLINDER;
 d1					= Crown_Fractional_Dry_Depth (pT->species, pT->height)*(pT->height-l);
 d3					= d1;
 beta				= atan2 (d2, d1);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-c.d1-d1));
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_tail_add		(&(pT->CrownVolume), &c);
 Destroy_Crown		(&c);
 return;
}

void		Create_PINE002_Global_Crown  (Tree *pT, PolSARproSim_Record *pPR)
{
/**************************************************************************************/
/* The global PINE002 crown volume is a truncated cylinder below a truncated cone     */
/* The convention is that the upper living crown is always at the head of the list.   */
/**************************************************************************************/
 Crown		c;
 int		shape	= CROWN_CONE;
 double		l		= Realise_Living_Crown_Depth (pT->species, pT->height);
 double		e		= sqrt (pT->radius*pT->radius + l*l);
 double		beta	= atan2 (pT->radius, l);
 d3Vector	axis	= Stem_Direction (pT->species);
 double		d1		= e*cos(beta);
 double		d2		= e*sin(beta);
 double		d3		= d1;
 d3Vector	base;

 Create_d3Vector	(&base);
 Create_Crown		(&c);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-d3));
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_head_add		(&(pT->CrownVolume), &c);
 shape				= CROWN_CYLINDER;
 d1					= Crown_Fractional_Dry_Depth (pT->species, pT->height)*(pT->height-l);
 d3					= d1;
 beta				= atan2 (d2, d1);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-c.d1-d1));
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_tail_add		(&(pT->CrownVolume), &c);
 Destroy_Crown		(&c);
 return;
}

void		Create_PINE003_Global_Crown  (Tree *pT, PolSARproSim_Record *pPR)
{
/****************************************************************************************************/
/* The global PINE003 crown volume is a truncated cylinder below either a truncated spheroid  or a  */
/* truncated cone. The convention is that the upper living crown is always at the head of the list. */
/****************************************************************************************************/
 Crown		c;
 int		shape;
 double		l		= Realise_Living_Crown_Depth (pT->species, pT->height);
 double		e		= sqrt (pT->radius*pT->radius + l*l);
 double		beta	= atan2 (pT->radius, l);
 d3Vector	axis	= Stem_Direction (pT->species);
 double		d1		= e*cos(beta);
 double		d2		= e*sin(beta);
 double		d3		= d1;
 d3Vector	base;
 double		r;

 Create_d3Vector	(&base);
 Create_Crown		(&c);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-d3));
 r					= drand ();
 if (r > 0.5) {
  shape				= CROWN_CONE;
 } else {
  shape				= CROWN_SPHEROID;
 }
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_head_add		(&(pT->CrownVolume), &c);
 shape				= CROWN_CYLINDER;
 d1					= Crown_Fractional_Dry_Depth (pT->species, pT->height)*(pT->height-l);
 d3					= d1;
 beta				= atan2 (d2, d1);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-c.d1-d1));
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_tail_add		(&(pT->CrownVolume), &c);
 Destroy_Crown		(&c);
 return;
}

void		Create_DECIDUOUS001_Global_Crown  (Tree *pT, PolSARproSim_Record *pPR)
{
/************************************************************************/
/* The global DECIDUOUS001 crown volume is a single, truncated spheroid */
/************************************************************************/
 Crown		c;
 int		shape	= CROWN_SPHEROID;
 double		l		= Realise_Living_Crown_Depth (pT->species, pT->height);
 double		e		= sqrt (pT->radius*pT->radius + l*l);
 double		beta	= atan2 (pT->radius, l);
 d3Vector	axis	= Stem_Direction (pT->species);
 double		d1		= e*cos(beta);
 double		d2		= e*sin(beta);
 double		d3;
 d3Vector	base;

 if (POLSARPROSIM_DECIDUOUS001_CROWN_DEPTH_FACTOR*d1 > pT->height) {
  d3				= pT->height;
 } else {
  d3				= POLSARPROSIM_DECIDUOUS001_CROWN_DEPTH_FACTOR*d1;
 }
 Create_d3Vector	(&base);
 Create_Crown		(&c);
 base				= d3Vector_sum (pT->base, d3Vector_double_multiply (axis, pT->height-d3));
 Assign_Crown		(&c, shape, beta, d1, d2, d3, base, axis, pPR->slope_x, pPR->slope_y);
 Crown_head_add		(&(pT->CrownVolume), &c);
 Destroy_Crown (&c);
 return;
}

void		Realise_Global_Crown (Tree *pT, PolSARproSim_Record *pPR)
{
 int		species	= pT->species;
 switch (species) {
  case POLSARPROSIM_HEDGE:			Create_HEDGE_Global_Crown			(pT, pPR);	break;
  case POLSARPROSIM_PINE001:		Create_PINE001_Global_Crown			(pT, pPR);	break;
  case POLSARPROSIM_PINE002:		Create_PINE002_Global_Crown			(pT, pPR);	break;
  case POLSARPROSIM_PINE003:		Create_PINE003_Global_Crown			(pT, pPR);	break;
  case POLSARPROSIM_DECIDUOUS001:	Create_DECIDUOUS001_Global_Crown	(pT, pPR);	break;
  default:							Create_HEDGE_Global_Crown			(pT, pPR);	break;
 }
 return;
}

void		Realise_Stem (Tree *pT, PolSARproSim_Record *pPR)
{
 const double	PI	= DPI_RAD;
 double			sr, er;
 d3Vector		z0;
 d3Vector		b0;
 Ray			r0;
 int			rtn_value;
 d3Vector		s1, s2;
 double			alpha1, alpha2;
 double			dp;
 double			phix, phiy, phicx, phicy;
 double			lamdacx, lamdacy, gamma;
 double			moisture;
 Complex		permittivity;
 Branch			Stem;
 d3Vector		p0;
 d3Vector		c1;
 double			p0dotz0;
 double			fp;
 double			ldenom;
 double			l;
 d3Vector		bt;
 d3Vector		adirn;

 sr				= Stem_Start_Radius			(pT->species, pT->height);
 er				= Stem_End_Radius			(pT->species, pT->height); 
 dp				= Stem_Tropism_Factor		(pT->species);
 fp				= dp/(2.0*sqrt(1.0-dp*dp));
 lamdacx		= Stem_Lamdacx				(pT->species);
 lamdacy		= Stem_Lamdacy				(pT->species);
 gamma			= Stem_Gamma				(pT->species);
 moisture		= Stem_Moisture				(pT->species);
 p0				= Stem_Tropism_Direction	(pT->species);
 permittivity	= vegetation_permittivity	(moisture, pPR->frequency);
 phix			= 2.0*PI*drand ();
 phiy			= 2.0*PI*drand ();
 phicx			= 2.0*PI*drand ();
 phicy			= 2.0*PI*drand ();
 Copy_d3Vector	(&z0, &(pT->CrownVolume.head->axis));
 Copy_d3Vector	(&b0, &(pT->base));
 adirn			= d3Vector_sum (z0, d3Vector_double_multiply (p0, fp));
 d3Vector_insitu_normalise (&adirn);
 Assign_Ray_d3V	(&r0, &b0, &adirn);
 rtn_value		= RayCrownIntersection (&r0, pT->CrownVolume.head, &s1, &alpha1, &s2, &alpha2);
 p0dotz0		= d3Vector_scalar_product (p0, z0);
 ldenom			= 1.0+fp*p0dotz0;
 if (rtn_value == NO_RAYCROWN_ERRORS) {
  if (s1.x[2] > s2.x[2]) {
   l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom; 
  } else {
   l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
  }
 } else {
  l			= pT->height;
 }
 Assign_Branch	(&Stem, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, lamdacx,
				lamdacy, gamma, moisture, l, permittivity, (int) (pT->Stem.n + 1L), 0);
 /*****************/
 /* Test solution */
 /*****************/
 c1		= Branch_Crookedness (&Stem, 1.0);
 bt		= Branch_Centre (&Stem ,1.0);
 /**************************************/
 /* Add the stem to the tree stem list */
 /**************************************/
 Branch_head_add (&(pT->Stem), &Stem);
 return;
}

void		Realise_PINE001_Primaries	(Tree *pT, PolSARproSim_Record *pPR)
{
/***************************************************/
/* Species specific primary branch realisation     */
/* PINE001 trees have a single stem with radiating */
/* primaries in both dry and living crowns         */
/***************************************************/
 Crown		*pC;
 int		Nlayers, i_layer;
 int		Nsections, i_section;
 double		t0, t1;
 double		delta_t, tb;
 d3Vector	b0;
 double		theta;
 double		delta_phi, phi;
 d3Vector	z0;
 double		sr, er;
 double		dp;
 double		lamdacx, lamdacy, gamma;
 double		phix, phiy, phicx, phicy;
 Complex	permittivity;
 d3Vector	p0;
 double		moisture;
 Ray		r0;
 int		rtn_value;
 d3Vector	s1, s2;
 double		alpha1, alpha2;
 Branch		Primary;
 d3Vector	c1;
 double		p0dotz0;
 double		fp;
 double		ldenom;
 double		l;
 d3Vector	bt;
 d3Vector	adirn;
 double		tbar;
 d3Vector	tree_top;
 double		max_height;
 double		pmy_height;
 double		dry_l;
 double		azimuth_offset;
 double		theta_avg, theta_dlt;

/**********************/
/* Populate DRY crown */
/**********************/

 pC			= pT->CrownVolume.tail;
 Nlayers	= (int) (POLSARPROSIM_PINE001_DRY_LAYER_DENSITY*pC->d3);
 if (Nlayers < 1) {
  Nlayers	= 1;
 }
 Nsections	= POLSARPROSIM_PINE001_DRY_AVG_SECTIONS;
 t0			= (pC->base.x[2]-pT->base.x[2])/pT->height;
 t1			= t0 + pC->d3/pT->height;
 delta_t	= (t1-t0)/Nlayers;
 delta_phi	= 2.0*DPI_RAD/Nsections;
 theta		= Primary_Maximum_Polar_Angle (pT->species, pT->height);
 dry_l		= pC->d2/cos(theta-DPI_RAD/2.0);
 for (i_layer=0; i_layer<Nlayers; i_layer++) {
  azimuth_offset	= 2.0*DPI_RAD*drand();
  for (i_section=0; i_section<Nsections; i_section++) {
   tb			= t0 + (i_layer+1)*delta_t - drand()*delta_t;
   b0			= Branch_Centre (pT->Stem.head, tb);
   phi			= i_section*delta_phi + delta_phi/2.0;
   phi			+= POLSARPROSIM_PINE001_PRIMARY_AZIMUTH_FACTOR*delta_phi*(drand()-0.5);
   phi			+= azimuth_offset;
   z0			= Polar_Assign_d3Vector (1.0, theta, phi);
   sr			= Primary_Radius (pT->species, pT->height, tb);
   er			= sr*pT->Stem.head->end_radius/pT->Stem.head->start_radius;
   dp			= Primary_Tropism_Factor (pT->species);
   fp			= dp/(2.0*sqrt(1.0-dp*dp));
   p0			= Primary_Tropism_Direction	(pT->species);
   lamdacx		= Primary_Lamdacx (pT->species);
   lamdacy		= Primary_Lamdacy (pT->species);
   gamma		= Primary_Gamma (pT->species);
   moisture		= Primary_Dry_Moisture (pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   phix			= 2.0*DPI_RAD*drand ();
   phiy			= 2.0*DPI_RAD*drand ();
   phicx		= 2.0*DPI_RAD*drand ();
   phicy		= 2.0*DPI_RAD*drand ();
   adirn		= d3Vector_sum (z0, d3Vector_double_multiply (p0, fp));
   d3Vector_insitu_normalise (&adirn);
   Assign_Ray_d3V	(&r0, &b0, &adirn);
   rtn_value	= RayCrownIntersection (&r0, pC, &s1, &alpha1, &s2, &alpha2);
   p0dotz0		= d3Vector_scalar_product (p0, z0);
   ldenom		= 1.0+fp*p0dotz0;
   if (rtn_value == NO_RAYCROWN_ERRORS) {
    if (alpha1 >= 0.0) {
     l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom;
    } else {
	 if (alpha2 >= 0.0) {
      l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
	 } else {
	  l = dry_l;
	 }
    }
   } else {
    l = dry_l;
   }
   Assign_Branch	(&Primary, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, lamdacx,
					lamdacy, gamma, moisture, l, permittivity, (int) (pT->Stem.n + pT->Dry.n + 1L), 1);
   c1			= Branch_Crookedness (&Primary, 1.0);
   bt			= Branch_Centre (&Primary ,1.0);
   pmy_height	= d3Vector_scalar_product (bt, pT->Stem.head->z0);
   Branch_head_add (&(pT->Dry), &Primary);
  }
 }

/*************************/
/* Populate living crown */
/*************************/

 theta_avg	= 0.5*(Primary_Maximum_Polar_Angle (pT->species, pT->height) + Primary_Minimum_Polar_Angle (pT->species, pT->height));
 theta_dlt	= 0.5*(Primary_Maximum_Polar_Angle (pT->species, pT->height) - Primary_Minimum_Polar_Angle (pT->species, pT->height));
 pC			= pT->CrownVolume.head;
 Nlayers	= (int) (POLSARPROSIM_PINE001_PRIMARY_LAYER_DENSITY*pC->d3);
 if (Nlayers < 1) {
  Nlayers	= 1;
 }
 Nsections	= POLSARPROSIM_PINE001_PRIMARY_AVG_SECTIONS;
 delta_phi	= 2.0*DPI_RAD/Nsections;
 t0			= (pC->base.x[2]-pT->base.x[2])/pT->height;
 t1			= 1.0;
 tbar		= 0.5*(t0+t1);
 delta_t	= (t1-t0)/Nlayers;
 tree_top	= Branch_Centre (pT->Stem.head, 1.0);
 max_height	= d3Vector_scalar_product (tree_top, pT->Stem.head->z0);
 for (i_layer=0; i_layer<Nlayers; i_layer++) {
  azimuth_offset	= 2.0*DPI_RAD*drand();
  for (i_section=0; i_section<Nsections; i_section++) {
   tb			= t0 + (i_layer+1)*delta_t - drand()*delta_t;
   b0			= Branch_Centre (pT->Stem.head, tb);
   theta		= theta_avg;
   theta		+= (tbar-tb)*theta_dlt/(tbar-t0);
   phi			= i_section*delta_phi + delta_phi/2.0;
   phi			+= POLSARPROSIM_PINE001_PRIMARY_AZIMUTH_FACTOR*delta_phi*(drand()-0.5);
   phi			+= azimuth_offset;
   z0			= Polar_Assign_d3Vector (1.0, theta, phi);
   sr			= Primary_Radius (pT->species, pT->height, tb);
   er			= sr*pT->Stem.head->end_radius/pT->Stem.head->start_radius;
   dp			= Primary_Tropism_Factor (pT->species);
   fp			= dp/(2.0*sqrt(1.0-dp*dp));
   p0			= Primary_Tropism_Direction	(pT->species);
   lamdacx		= Primary_Lamdacx (pT->species);
   lamdacy		= Primary_Lamdacy (pT->species);
   gamma		= Primary_Gamma (pT->species);
   moisture		= Primary_Moisture (pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   phix			= 2.0*DPI_RAD*drand ();
   phiy			= 2.0*DPI_RAD*drand ();
   phicx		= 2.0*DPI_RAD*drand ();
   phicy		= 2.0*DPI_RAD*drand ();
   adirn		= d3Vector_sum (z0, d3Vector_double_multiply (p0, fp));
   d3Vector_insitu_normalise (&adirn);
   Assign_Ray_d3V	(&r0, &b0, &adirn);
   rtn_value	= RayCrownIntersection (&r0, pC, &s1, &alpha1, &s2, &alpha2);
   p0dotz0		= d3Vector_scalar_product (p0, z0);
   ldenom		= 1.0+fp*p0dotz0;
   if (rtn_value == NO_RAYCROWN_ERRORS) {
	if (alpha1*alpha2 < 0.0) {
	 if (alpha1 > 0.0) {
 	  l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom;
	 } else {
 	  l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
	 }
     Assign_Branch	(&Primary, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, lamdacx, lamdacy, gamma,
					moisture, l, permittivity, (int) (pT->Stem.n + pT->Dry.n + pT->Primary.n + 1L), 1);
     c1			= Branch_Crookedness (&Primary, 1.0);
     bt			= Branch_Centre (&Primary ,1.0);
     pmy_height	= d3Vector_scalar_product (bt, pT->Stem.head->z0);
	 if (pmy_height < max_height) {
      Branch_head_add (&(pT->Primary), &Primary);
	 }
	}
   }
  }
 }
 return;
}

void		Realise_DECIDUOUS001_Primaries	(Tree *pT, PolSARproSim_Record *pPR)
{
 Crown		*pC;
 int		Nlayers, i_layer;
 int		Nsections, i_section;
 double		t0, t1;
 double		delta_t, tb;
 d3Vector	b0;
 double		theta;
 double		delta_phi, phi;
 d3Vector	z0;
 double		sr, er;
 double		dp;
 double		lamdacx, lamdacy, gamma;
 double		phix, phiy, phicx, phicy;
 Complex	permittivity;
 d3Vector	p0;
 double		moisture;
 Ray		r0;
 int		rtn_value;
 d3Vector	s1, s2;
 double		alpha1, alpha2;
 Branch		Primary;
 d3Vector	c1;
 double		p0dotz0;
 double		fp;
 double		ldenom;
 double		l;
 d3Vector	bt;
 d3Vector	adirn;
 double		tbar;
 d3Vector	tree_top;
 double		max_height;
 double		pmy_height;
 double		azimuth_offset;

/*************************/
/* Populate living crown */
/*************************/

 t0			= POLSARPROSIM_DECIDUOUS001_PRIMARY_TMIN;
 t1			= POLSARPROSIM_DECIDUOUS001_PRIMARY_TMAX;
 pC			= pT->CrownVolume.head;
 Nlayers	= (int) ((t1-t0)*POLSARPROSIM_DECIDUOUS001_PRIMARY_LAYER_DENSITY*pC->d3);
 if (Nlayers < 1) {
  Nlayers	= 1;
 }
 Nsections	= POLSARPROSIM_DECIDUOUS001_PRIMARY_AVG_SECTIONS;
 tbar		= 0.5*(t0+t1);
 delta_t	= (t1-t0)/Nlayers;
 delta_phi	= 2.0*DPI_RAD/Nsections;
 tree_top	= Branch_Centre (pT->Stem.head, 1.0);
 max_height	= d3Vector_scalar_product (tree_top, pT->Stem.head->z0);
 for (i_layer=0; i_layer<Nlayers; i_layer++) {
  azimuth_offset	= 2.0*DPI_RAD*drand();
  for (i_section=0; i_section<Nsections; i_section++) {
   tb			= t0 + i_layer*delta_t + delta_t*drand();
   b0			= Branch_Centre (pT->Stem.head, tb);
   theta		= DPI_RAD*POLSARPROSIM_DECIDUOUS001_PRIMARY_AVG_POLAR_ANGLE/DPI_DEG;
   theta		+= (tbar-tb)*DPI_RAD*POLSARPROSIM_DECIDUOUS001_PRIMARY_DLT_POLAR_ANGLE/(DPI_DEG*(tbar-t0));
   phi			= i_section*delta_phi + delta_phi/2.0;
   phi			+= POLSARPROSIM_DECIDUOUS001_PRIMARY_AZIMUTH_FACTOR*delta_phi*(drand()-0.5);
   phi			+= azimuth_offset;
   z0			= Polar_Assign_d3Vector (1.0, theta, phi);
   sr			= POLSARPROSIM_DECIDUOUS001_PRIMARY_RADIUS_FACTOR*Branch_Radius (pT->Stem.head, tb);
   er			= POLSARPROSIM_DECIDUOUS001_PRIMARY_RADIUS_FACTOR*pT->Stem.head->end_radius;
   dp			= Primary_Tropism_Factor (pT->species);
   fp			= dp/(2.0*sqrt(1.0-dp*dp));
   p0			= Primary_Tropism_Direction	(pT->species);
   lamdacx		= Primary_Lamdacx (pT->species);
   lamdacy		= Primary_Lamdacy (pT->species);
   gamma		= Primary_Gamma (pT->species);
   moisture		= Primary_Moisture (pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   phix			= 2.0*DPI_RAD*drand ();
   phiy			= 2.0*DPI_RAD*drand ();
   phicx		= 2.0*DPI_RAD*drand ();
   phicy		= 2.0*DPI_RAD*drand ();
   adirn		= d3Vector_sum (z0, d3Vector_double_multiply (p0, fp));
   d3Vector_insitu_normalise (&adirn);
   Assign_Ray_d3V	(&r0, &b0, &adirn);
   rtn_value	= RayCrownIntersection (&r0, pC, &s1, &alpha1, &s2, &alpha2);
   p0dotz0		= d3Vector_scalar_product (p0, z0);
   ldenom		= 1.0+fp*p0dotz0;
   if (rtn_value == NO_RAYCROWN_ERRORS) {
	if (alpha1*alpha2 < 0.0) {
	 if (alpha1 > 0.0) {
 	  l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom;
	 } else {
 	  l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
	 }
     Assign_Branch	(&Primary, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, 
					lamdacx, lamdacy, gamma, moisture, l, permittivity, 
					(int) (pT->Stem.n + pT->Dry.n + pT->Primary.n + 1L), 1);
     c1			= Branch_Crookedness (&Primary, 1.0);
     bt			= Branch_Centre (&Primary ,1.0);
     pmy_height	= d3Vector_scalar_product (bt, pT->Stem.head->z0);
	 if (pmy_height < max_height) {
      Branch_head_add (&(pT->Primary), &Primary);
	 }
	}
   }
  }
 }
 return;
}

void		Realise_Primaries (Tree *pT, PolSARproSim_Record *pPR)
{
 switch (pT->species) {
  case POLSARPROSIM_HEDGE:			break;
  case POLSARPROSIM_PINE001:		Realise_PINE001_Primaries		(pT, pPR);	break;
  case POLSARPROSIM_PINE002:		Realise_PINE001_Primaries		(pT, pPR);	break;
  case POLSARPROSIM_PINE003:		Realise_PINE001_Primaries		(pT, pPR);	break;
  case POLSARPROSIM_DECIDUOUS001:	Realise_DECIDUOUS001_Primaries	(pT, pPR);	break;
  default:							break;
 }
 return;
}

void		Realise_DECIDUOUS001_Secondaries	(Tree *pT)
{
 Branch		*pPrimary;
 int		i_primary, Nprimary;
 d3Vector	b0, b1;
 d3Vector	xp, yp, zp;
 double		theta, phi;
 double		xpdotyp, xpdotzp, ypdotzp;
 double		t0, t1;
 double		primary_length;
 int		i_layer, Nlayers;
 int		i_section, Nsections;
 double		tbar, delta_t, delta_phi;
 Branch		secondary;
 double		tb;
 d3Vector	z0;
 double		sr, er;
 double		dp, fp;
 d3Vector	p0;
 double		lamdacx, lamdacy, gamma;
 double		moisture;
 Complex	permittivity;
 double		phix, phiy, phicx, phicy;
 d3Vector	adirn;
 Ray		rb;
 double		alpha1, alpha2;
 d3Vector	s1, s2;
 int		rtn_value;
 double		p0dotz0, ldenom, l;
 d3Vector	c1;
 d3Vector	bt;
 Spheroid	sph1;
 double		a1, a2, a3;
 double		layer_phi0;

 Create_Branch		(&secondary);
 Create_Ray			(&rb);
 Create_Spheroid	(&sph1);

/*************************************************/
/* Populate living crown with secondary branches */
/*************************************************/

 pPrimary	= pT->Primary.head;
 Nprimary	= pT->Primary.n;
 t0			= POLSARPROSIM_DECIDUOUS001_SECONDARY_TMIN;
 t1			= POLSARPROSIM_DECIDUOUS001_SECONDARY_TMAX;
 for (i_primary = 0; i_primary < Nprimary; i_primary++) {
  /********************************/
  /* Start of loop over primaries */
  /********************************/
  Copy_d3Vector (&b0, &(pPrimary->b0));
  b1				= Branch_Centre (pPrimary, 1.0);
  zp				= d3Vector_difference (b1, b0);
  primary_length	= zp.r;
  d3Vector_insitu_normalise (&zp);
  theta				= zp.theta;
  phi				= zp.phi;
  yp				= Cartesian_Assign_d3Vector (-sin(phi), cos(phi), 0.0);
  xp				= Cartesian_Assign_d3Vector (-cos(theta)*cos(phi), -cos(theta)*sin(phi), sin(theta));
  xpdotyp			= d3Vector_scalar_product (xp, yp);
  xpdotzp			= d3Vector_scalar_product (xp, zp);
  ypdotzp			= d3Vector_scalar_product (yp, zp);
  /******************************************/
  /* Create "crown" volume for this primary */
  /******************************************/
  a1				= 0.5*primary_length;
  a2				= POLSARPROSIM_DECIDUOUS001_SECONDARY_SPHEROID_RADIUS_FACTOR*a1;
  a3				= POLSARPROSIM_DECIDUOUS001_SECONDARY_SPHEROID_HEIGHT_FACTOR*a1;
  Assign_Spheroid (&sph1, a1, a2, a3, zp, b0);
  /***********************************/
  /* Finished making bounding volume */
  /***********************************/
  Nlayers	= (int) ((t1-t0)*POLSARPROSIM_DECIDUOUS001_SECONDARY_LAYER_DENSITY*primary_length);
  if (Nlayers < 1) {
   Nlayers	= 1;
  }
  Nsections			= POLSARPROSIM_DECIDUOUS001_SECONDARY_AVG_SECTIONS;
  tbar				= 0.5*(t0+t1);
  delta_t			= (t1-t0)/Nlayers;
  delta_phi			= 2.0*DPI_RAD/Nsections;
  for (i_layer = 0; i_layer < Nlayers; i_layer++) {
   layer_phi0		= 2.0*DPI_RAD*drand();
   for (i_section = 0; i_section < Nsections; i_section++) {
   /*****************************************/
   /* Start of loop over secondary branches */
   /*****************************************/
   tb			= t0 + i_layer*delta_t + delta_t*drand();
   b0			= Branch_Centre (pPrimary, tb);
   theta		= DPI_RAD*POLSARPROSIM_DECIDUOUS001_SECONDARY_AVG_POLAR_ANGLE/DPI_DEG;
   theta		+= (tbar-tb)*DPI_RAD*POLSARPROSIM_DECIDUOUS001_SECONDARY_DLT_POLAR_ANGLE/(DPI_DEG*(tbar-t0));
   phi			= i_section*delta_phi;
   phi			+= POLSARPROSIM_DECIDUOUS001_SECONDARY_AZIMUTH_FACTOR*delta_phi*(drand()-0.5);
   phi			+= layer_phi0;
   z0			= d3Vector_double_multiply (zp, cos(theta));
   z0			= d3Vector_sum (z0, d3Vector_double_multiply (yp, sin(theta)*cos(phi)));
   z0			= d3Vector_sum (z0, d3Vector_double_multiply (xp, sin(theta)*sin(phi)));
   sr			= POLSARPROSIM_DECIDUOUS001_SECONDARY_RADIUS_FACTOR*Branch_Radius (pPrimary, tb);
   er			= POLSARPROSIM_DECIDUOUS001_SECONDARY_RADIUS_FACTOR*pPrimary->end_radius;
   dp			= Secondary_Tropism_Factor (pT->species);
   fp			= dp/(2.0*sqrt(1.0-dp*dp));
   p0			= Secondary_Tropism_Direction	(pT->species);
   lamdacx		= Secondary_Lamdacx (pT->species);
   lamdacy		= Secondary_Lamdacy (pT->species);
   gamma		= Secondary_Gamma (pT->species);
   moisture		= pPrimary->moisture;
   permittivity	= Copy_Complex (&(pPrimary->permittivity));
   phix			= 2.0*DPI_RAD*drand ();
   phiy			= 2.0*DPI_RAD*drand ();
   phicx		= 2.0*DPI_RAD*drand ();
   phicy		= 2.0*DPI_RAD*drand ();
   adirn		= d3Vector_sum (z0, d3Vector_double_multiply (p0, fp));
   d3Vector_insitu_normalise (&adirn);
   Assign_Ray_d3V	(&rb, &b0, &adirn);
   rtn_value	= RaySpheroidIntersection (&rb, &sph1, &s1, &alpha1, &s2, &alpha2);
   p0dotz0		= d3Vector_scalar_product (p0, z0);
   ldenom		= 1.0+fp*p0dotz0;
   if (rtn_value == NO_RAYSPHEROID_ERRORS) {
	if (alpha1*alpha2 < 0.0) {
	 if (alpha1 > 0.0) {
  	  l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom;
	 } else {
  	  l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
	 }
     Assign_Branch	(&secondary, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, 
					lamdacx, lamdacy, gamma, moisture, l, permittivity,
					(int) (pT->Stem.n + pT->Dry.n + pT->Primary.n + pT->Secondary.n + 1L), pPrimary->id);
     c1			= Branch_Crookedness (&secondary, 1.0);
     bt			= Branch_Centre (&secondary ,1.0);
	 Branch_head_add (&(pT->Secondary), &secondary);
	}
   }
   /*****************************************/
   /*  End of loop over secondary branches  */
   /*****************************************/
   }
  }
  /******************************/
  /* End of loop over primaries */
  /******************************/
  pPrimary	= pPrimary->next;
 }

 Destroy_Branch		(&secondary);
 Destroy_Ray		(&rb);
 Destroy_Spheroid	(&sph1);

 return;
}

double		Min_Pine_tStart (double lp)
{
 double		tmin;
 if (lp < POLSARPROSIM_PINE001_PL0) {
  lp	= POLSARPROSIM_PINE001_PL0;
 }
 tmin	 = POLSARPROSIM_PINE001_PGAMMA;
 tmin	+= (POLSARPROSIM_PINE001_PALPHA-POLSARPROSIM_PINE001_PGAMMA)
		*exp(-POLSARPROSIM_PINE001_PBETA*(lp-POLSARPROSIM_PINE001_PL0));
 return (tmin);
}

double		Max_Pine_tStart (double lp)
{
 double		tmax;
 if (lp < POLSARPROSIM_PINE001_PL0) {
  lp	= POLSARPROSIM_PINE001_PL0;
 }
 tmax	 = POLSARPROSIM_PINE001_PALPHA;
 tmax	+= (POLSARPROSIM_PINE001_PT-POLSARPROSIM_PINE001_PALPHA)
		*(1.0-exp(-POLSARPROSIM_PINE001_PBETAP*(lp-POLSARPROSIM_PINE001_PL0)));
 return (tmax);
}

double		Pine_Secondary_Length (double ts, double lp)
{
 double		ls;
 ls			= lp*(POLSARPROSIM_PINE001_CLS - POLSARPROSIM_PINE001_MLS*ts);
/***************************************************************************************/
/* Increase in secondary branch length to restore volume fraction after coding changes */
/***************************************************************************************/
 ls			*= POLSARPROSIM_PINE001_SBLSCALING;
 return (ls);
}

double		Pine_Secondary_Start_Radius_Fraction	(double ts)
{
 double		fsr;
 fsr		= POLSARPROSIM_PINE001_FSRB0 * (POLSARPROSIM_PINE001_FSRA0
										 +  POLSARPROSIM_PINE001_FSRA1*ts 
										 +  POLSARPROSIM_PINE001_FSRA2*ts*ts 
										 +  POLSARPROSIM_PINE001_FSRA3*ts*ts*ts);
 return (fsr);
}

void		Realise_PINE001_Secondaries	(Tree *pT)
{
 Branch		*pPrimary;
 int		i_primary, Nprimary;
 d3Vector	b0, b1;
 d3Vector	xp, yp, zp;
 double		theta, phi;
 double		primary_length;
 double		primary_start_radius;
 double		primary_end_radius;
 int		Ns;
 double		tmin, tmax;
 double		deltat, dt;
 double		l;
 double		subBeta;
 double		Cl			= POLSARPROSIM_PINE001_CLS;
 int		subShape	= CROWN_CONE;
 double		d1, d2, d3;
 Crown		subC;
 int		iSecondary;
 double		ts;
 d3Vector	z0;
 double		sr;
 double		er;
 double		dp, fp;
 d3Vector	p0;
 double		lamdacx, lamdacy;
 double		gamma;
 double		moisture;
 Complex	permittivity;
 double		phix, phiy, phicx, phicy;
 d3Vector	adirn;
 Ray		rb;
 int		rtn_value;
 d3Vector	s1, s2;
 double		alpha1, alpha2;
 double		p0dotz0, ldenom;
 Branch		secondary;
 d3Vector	ct, bt;

/******************/
/* Initialisation */
/******************/

 Create_Crown (&subC);

/*************************************************/
/* Populate living crown with secondary branches */
/*************************************************/

 pPrimary	= pT->Primary.head;
 Nprimary	= pT->Primary.n;
 for (i_primary = 0; i_primary < Nprimary; i_primary++) {
  Copy_d3Vector (&b0, &(pPrimary->b0));
  b1					= Branch_Centre (pPrimary, 1.0);
  zp					= d3Vector_difference (b1, b0);
  primary_length		= zp.r;
  primary_start_radius	= pPrimary->start_radius;
  primary_end_radius	= pPrimary->end_radius;
  d3Vector_insitu_normalise (&zp);
  theta					= zp.theta;
  phi					= zp.phi;
  yp					= Cartesian_Assign_d3Vector (-sin(phi), cos(phi), 0.0);
  xp					= Cartesian_Assign_d3Vector (-cos(theta)*cos(phi), -cos(theta)*sin(phi), sin(theta));
  Ns					= Number_of_Secondaries (pT->species, primary_length);
  if (Ns >= 1) {
   tmin					= Min_Pine_tStart (primary_length);
   tmax					= Max_Pine_tStart (primary_length);
   deltat				= (tmax - tmin)/(double) Ns;
   dt					= 0.5*deltat;
   theta				= Gaussian_drand (POLSARPROSIM_PINE001_THETAS_AVG, POLSARPROSIM_PINE001_THETAS_STD, 
							POLSARPROSIM_PINE001_THETAS_AVG-POLSARPROSIM_PINE001_THETAS_STD, 
							POLSARPROSIM_PINE001_THETAS_AVG+POLSARPROSIM_PINE001_THETAS_STD);
   l					= Pine_Secondary_Length (0, primary_length);
   subBeta				= atan2 (Cl*sin(theta), 1.0-Cl*cos(theta));
   d1					= primary_length;
   d2					= primary_length*sin(subBeta);
   d3					= d1;
   Assign_Crown			(&subC, subShape, subBeta, d1, d2, d3, b0, zp, 0.0, 0.0);   
   for (iSecondary = 0; iSecondary < Ns; iSecondary++) {
    ts					= tmin + iSecondary*deltat + (drand()-0.5)*dt;
    theta				= Gaussian_drand (POLSARPROSIM_PINE001_THETAS_AVG, POLSARPROSIM_PINE001_THETAS_STD, 
							POLSARPROSIM_PINE001_THETAS_AVG-POLSARPROSIM_PINE001_THETAS_STD, 
							POLSARPROSIM_PINE001_THETAS_AVG+POLSARPROSIM_PINE001_THETAS_STD);
	phi					= 2.0*DPI_RAD*drand();
    b0					= Branch_Centre (pPrimary, ts);
    z0					= d3Vector_double_multiply (zp, cos(theta));
    z0					= d3Vector_sum (z0, d3Vector_double_multiply (yp, sin(theta)*cos(phi)));
    z0					= d3Vector_sum (z0, d3Vector_double_multiply (xp, sin(theta)*sin(phi)));
	sr					= primary_start_radius * Pine_Secondary_Start_Radius_Fraction (ts);
    er					= 0.9205 * primary_end_radius;
    dp					= Secondary_Tropism_Factor (pT->species);
    fp					= dp/(2.0*sqrt(1.0-dp*dp));
    p0					= Secondary_Tropism_Direction	(pT->species);
    p0dotz0				= d3Vector_scalar_product (p0, z0);
    ldenom				= 1.0+fp*p0dotz0;
    lamdacx				= Secondary_Lamdacx (pT->species);
    lamdacy				= Secondary_Lamdacy (pT->species);
    gamma				= Secondary_Gamma (pT->species);
    moisture			= pPrimary->moisture;
    permittivity		= Copy_Complex (&(pPrimary->permittivity));
    phix				= 2.0*DPI_RAD*drand ();
    phiy				= 2.0*DPI_RAD*drand ();
    phicx				= 2.0*DPI_RAD*drand ();
    phicy				= 2.0*DPI_RAD*drand ();
    adirn				= d3Vector_sum (z0, d3Vector_double_multiply (p0, fp));
    d3Vector_insitu_normalise (&adirn);
    Assign_Ray_d3V	(&rb, &b0, &adirn);
	rtn_value			= RayCrownIntersection (&rb, &subC, &s1, &alpha1, &s2, &alpha2);
    if (rtn_value == NO_RAYCROWN_ERRORS) {
	 if ((alpha1 > 0.0) && (alpha2 > 0.0)) {
	  if (alpha1 < alpha2) {
	   l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom;
	  } else {
	   l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
	  }
	 } else {
	  if (alpha1 > 0.0) {
	   l		= d3Vector_scalar_product (d3Vector_difference (s1, b0), z0)/ldenom;
	  } else {
	   if (alpha2 > 0.0) {
	    l		= d3Vector_scalar_product (d3Vector_difference (s2, b0), z0)/ldenom;
 	   }
	  }
	 }
	 if (!((alpha1 <= 0.0) && (alpha2 <= 0.0))) {
      Assign_Branch	(&secondary, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy,
					lamdacx, lamdacy, gamma, moisture, l, permittivity, 
					(int) (pT->Stem.n + pT->Dry.n + pT->Primary.n + pT->Secondary.n + 1L), pPrimary->id);
      ct			= Branch_Crookedness (&secondary, 1.0);
      bt			= Branch_Centre (&secondary ,1.0);
	  Branch_head_add (&(pT->Secondary), &secondary);
	 }
    }
   }
  }
  pPrimary	= pPrimary->next;
 }
 Destroy_Crown (&subC);
 return;
}

void		Realise_Secondaries (Tree *pT)
{
 switch (pT->species) {
  case POLSARPROSIM_HEDGE:			break;
  case POLSARPROSIM_PINE001:		Realise_PINE001_Secondaries			(pT);	break;
  case POLSARPROSIM_PINE002:		Realise_PINE001_Secondaries			(pT);	break;
  case POLSARPROSIM_PINE003:		Realise_PINE001_Secondaries			(pT);	break;
  case POLSARPROSIM_DECIDUOUS001:	Realise_DECIDUOUS001_Secondaries	(pT);	break;
  default:							break;
 }
 return;
}

void		Realise_Tertiaries (Tree *pT, PolSARproSim_Record *pPR)
{
 double				primary_branch_length, secondary_branch_length, tertiary_branch_length;
 double				primary_branch_radius, secondary_branch_radius, tertiary_branch_radius;
 double				tertiary_branch_volume;
 double				tertiary_branch_vf;
 long				tertiary_branch_number;
 int				tbn;
 Branch				tertiary_branch;
 double				theta, phi;
 d3Vector			z0;
 double				sr, er;
 double				dp;
 double				lamdacx, lamdacy, gamma;
 double				phix, phiy, phicx, phicy;
 Complex			permittivity;
 d3Vector			p0;
 double				moisture;
 Crown				*pC;
 Branch				*pB;
 long				iBranch;
 int				rtn_value;
 d3Vector			b0;
 double				dtbn;
 double				tbn_factor;

 pC	= pT->CrownVolume.head;
 /*********************************************/
 /* Determine dimensions of tertiary branches */
 /*********************************************/
 if (pT->species == POLSARPROSIM_HEDGE) {
  tertiary_branch_length	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_LENGTH;
  tertiary_branch_radius	= POLSARPROSIM_HEDGE_TERTIARY_BRANCH_RADIUS;
 } else {
  primary_branch_length		= 0.0;
  primary_branch_radius		= 0.0;
  pB	= pT->Primary.head;
  for (iBranch=0L; iBranch < pT->Primary.n; iBranch++) {
   primary_branch_length	+= pB->l;
   primary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
   pB	= pB->next;
  }
  primary_branch_length		/= (double) pT->Primary.n;
  primary_branch_radius		/= (double) pT->Primary.n;
  secondary_branch_length	= 0.0;
  secondary_branch_radius	= 0.0;
  pB	= pT->Secondary.head;
  for (iBranch=0L; iBranch < pT->Secondary.n; iBranch++) {
   secondary_branch_length	+= pB->l;
   secondary_branch_radius	+= 0.5*(pB->start_radius + pB->end_radius);
   pB	= pB->next;
  }
  secondary_branch_length	/= (double) pT->Secondary.n;
  secondary_branch_radius	/= (double) pT->Secondary.n;
  tertiary_branch_length	= secondary_branch_length*secondary_branch_length/primary_branch_length;
  tertiary_branch_radius	= secondary_branch_radius*secondary_branch_radius/primary_branch_radius;
 }
 /**********************************************/
 /* Estimate number to realise (sophisticated) */
 /**********************************************/
 tertiary_branch_volume		= DPI_RAD*tertiary_branch_radius*tertiary_branch_radius*tertiary_branch_length;
 tertiary_branch_vf			= Tertiary_Branch_Volume_Fraction (pT->species);
 tertiary_branch_number		= (long) (tertiary_branch_vf*pC->volume/tertiary_branch_volume);
 dtbn						= 2.0*pC->d2*pC->d3/(tan(pPR->incidence_angle[0])*pPR->azimuth_resolution*pPR->ground_range_resolution[0]);
 switch (pT->species) {
  case	POLSARPROSIM_HEDGE:			tbn_factor	= POLSARPROSIM_HEDGE_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE001:		tbn_factor	= POLSARPROSIM_PINE001_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE002:		tbn_factor	= POLSARPROSIM_PINE002_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_PINE003:		tbn_factor	= POLSARPROSIM_PINE003_TERTIARY_FACTOR;			break;
  case	POLSARPROSIM_DECIDUOUS001:	tbn_factor	= POLSARPROSIM_DECIDUOUS001_TERTIARY_FACTOR;	break;
  default:							tbn_factor	= POLSARPROSIM_PINE001_TERTIARY_FACTOR;
 }
 tbn						= (int) (tbn_factor*dtbn);
 tbn++;
 /*********************************/
 /* Realise a nominal number only */
 /*********************************/
#ifdef POLSARPROSIM_NOMINAL_TERTIARY_NUMBER
 tbn						= POLSARPROSIM_NOMINAL_TERTIARY_NUMBER;
#endif
 /***************************************/
 /* Loop to create tertiary branch list */
 /***************************************/
 Create_Branch (&tertiary_branch);
 for (iBranch=0L; iBranch < tbn; iBranch++) {
  /***********************************/
  /* Create and draw random branches */
  /***********************************/
  rtn_value		= Random_Crown_Location (pC, &b0);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   phi			= 2.0*DPI_RAD*drand();
   theta		= vegi_polar_angle ();
   z0			= Polar_Assign_d3Vector (1.0, theta, phi);
   sr			= tertiary_branch_radius;
   er			= tertiary_branch_radius;
   dp			= 0.0;
   p0			= Polar_Assign_d3Vector (1.0, theta, phi);
   lamdacx		= 1.0;
   lamdacy		= 1.0;
   gamma		= 0.0;
   moisture		= Tertiary_Branch_Moisture (pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   phix			= 0.0;
   phiy			= 0.0;
   phicx		= 0.0;
   phicy		= 0.0;
   b0			= d3Vector_sum (b0, d3Vector_double_multiply (z0, -tertiary_branch_length/2.0));
   Assign_Branch (&tertiary_branch, sr, er, b0, z0, p0, dp, phix, phiy, phicx, phicy, 
				  lamdacx, lamdacy, gamma, moisture, tertiary_branch_length, permittivity, 
				  (int) (pT->Stem.n + pT->Dry.n + pT->Primary.n + pT->Secondary.n +pT->Tertiary.n + 1L), 0);
   Branch_head_add (&(pT->Tertiary), &tertiary_branch);
  }
 }
 Destroy_Branch (&tertiary_branch);
 return;
}

void		Realise_Foliage (Tree *pT, PolSARproSim_Record *pPR)
{
 int			species;
 Crown			*pC;
 double			leaf_d1, leaf_d2, leaf_d3;
 double			theta, phi;
 double			moisture;
 d3Vector		cl;
 Complex		permittivity;
 double			leafvol;
 Leaf			leaf1;
 double			leaf_vf;
 long			leaf_number;
 double			dln,ln_factor;
 int			ln;
 int			iLeaf;
 int			rtn_value;

 pC				= pT->CrownVolume.head;
 species		= Leaf_Species		(pT->species);
 leaf_d1		= Leaf_Dimension_1	(pT->species);
 leaf_d2		= Leaf_Dimension_2	(pT->species);
 leaf_d3		= Leaf_Dimension_3	(pT->species);
 cl				= Cartesian_Assign_d3Vector (0.0, 0.0, 0.0);
 theta			= 0.0;
 phi			= 0.0;
 moisture		= Leaf_Moisture		(pT->species);
 permittivity	= vegetation_permittivity (moisture, pPR->frequency);
 Create_Leaf (&leaf1);
 Assign_Leaf	(&leaf1, species, leaf_d1, leaf_d2, leaf_d3, theta, phi, moisture, permittivity, cl);
 /**********************************************/
 /* Estimate number to realise (sophisticated) */
 /**********************************************/
 leafvol		= Leaf_Volume (&leaf1);
 leaf_vf		= Leaf_Volume_Fraction (pT->species);
 leaf_number	= (long) (leaf_vf*pC->volume/leafvol);
 dln			= 2.0*pC->d2*pC->d3/(tan(pPR->incidence_angle[0])*pPR->azimuth_resolution*pPR->ground_range_resolution[0]);
 switch (pT->species) {
  case	POLSARPROSIM_HEDGE:			ln_factor	= POLSARPROSIM_HEDGE_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE001:		ln_factor	= POLSARPROSIM_PINE001_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE002:		ln_factor	= POLSARPROSIM_PINE002_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_PINE003:		ln_factor	= POLSARPROSIM_PINE003_FOLIAGE_FACTOR;			break;
  case	POLSARPROSIM_DECIDUOUS001:	ln_factor	= POLSARPROSIM_DECIDUOUS001_FOLIAGE_FACTOR;		break;
  default:							ln_factor	= POLSARPROSIM_PINE001_FOLIAGE_FACTOR;
 }
 ln						= (int) (ln_factor*dln);
 ln++;
 /*********************************/
 /* Realise a nominal number only */
 /*********************************/
#ifdef POLSARPROSIM_NOMINAL_FOLIAGE_NUMBER
 ln						= POLSARPROSIM_NOMINAL_FOLIAGE_NUMBER;
#endif
 for (iLeaf=0L; iLeaf < ln; iLeaf++) {
  rtn_value		= Random_Crown_Location (pC, &cl);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   phi			= 2.0*DPI_RAD*drand();
   theta		= vegi_polar_angle ();
   moisture		= Leaf_Moisture		(pT->species);
   permittivity	= vegetation_permittivity (moisture, pPR->frequency);
   Assign_Leaf	(&leaf1, species, leaf_d1, leaf_d2, leaf_d3, theta, phi, moisture, permittivity, cl);
   Leaf_head_add (&(pT->Foliage), &leaf1);
  }
 }
 Destroy_Leaf (&leaf1);
 return;
}

void		Realise_Tree (Tree *pT, int i, PolSARproSim_Record *pPR)
{
 double			z;
/**************************************************************/
/* Resetting random number generator using srand (seed + i)	  */
/* ensures that the ith tree is always realised the same way. */
/**************************************************************/
 srand (pPR->seed + i);
/***********************/
/* Make a new tree ... */
/***********************/
 Destroy_Tree (pT);
/***********************/
/* Initial assignments */
/***********************/
 pT->species	= pPR->species;
 pT->height		= pPR->Tree_Location[i].height;
 pT->radius		= pPR->Tree_Location[i].radius;
 z				= ground_height (pPR, pPR->Tree_Location[i].x, pPR->Tree_Location[i].y);
 pT->base		= Cartesian_Assign_d3Vector (pPR->Tree_Location[i].x, pPR->Tree_Location[i].y, z);
/*************************/
/* Create a global crown */
/*************************/
 Crown_init_list	(&(pT->CrownVolume));
 Realise_Global_Crown (pT, pPR);
/****************************************************************************************/
/* Main stem: use the tree base and global crown definition to construct the main stem  */
/****************************************************************************************/
 if (pT->species != POLSARPROSIM_HEDGE) {
  Realise_Stem (pT, pPR);
 }
/********************************************************************************/
/* Primary branches: use stems and the tree global crown to construct primaries */
/********************************************************************************/
 if (pT->species != POLSARPROSIM_HEDGE) {
  Realise_Primaries (pT, pPR);
 }
/**********************************************************************************/
/* Secondary branches: use stems and the tree global crown to construct primaries */
/**********************************************************************************/
 if (pT->species != POLSARPROSIM_HEDGE) {
  Realise_Secondaries (pT);
 }
/***********************************************************************************/
/* Tertiary branches: populate the tree global crown with random tertiary branches */
/***********************************************************************************/
  Realise_Tertiaries (pT, pPR);
/*************************************************************************/
/* Foliage: populate the tree global crown with random leaves or needles */
/*************************************************************************/
  Realise_Foliage (pT, pPR);
/***********/
/* Return  */
/***********/
 return;
}

void		Realise_Tree_Crown_Only (Tree *pT, int i, PolSARproSim_Record *pPR)
{
 double			z;
/***********************/
/* Make a new tree ... */
/***********************/
 Destroy_Tree (pT);
/***********************/
/* Initial assignments */
/***********************/
 pT->species	= pPR->species;
 pT->height		= pPR->Tree_Location[i].height;
 pT->radius		= pPR->Tree_Location[i].radius;
 z				= ground_height (pPR, pPR->Tree_Location[i].x, pPR->Tree_Location[i].y);
 pT->base		= Cartesian_Assign_d3Vector (pPR->Tree_Location[i].x, pPR->Tree_Location[i].y, z);
/*************************/
/* Create a global crown */
/*************************/
 Crown_init_list	(&(pT->CrownVolume));
 Realise_Global_Crown (pT, pPR);
 return;
}

/************************************/
/* Random crown location generation */
/************************************/

int		Random_Crown_Location			(Crown *p_cwn, d3Vector *s)
{
 Plane		p;
 double		phi;
 d3Vector	d;
 Ray		r;
 d3Vector	s1, s2;
 double		alpha1, alpha2;
 int		rtn_value;
 double		alpha;

 *s			= d3Vector_sum (p_cwn->base, d3Vector_double_multiply (p_cwn->axis, (p_cwn->d3-ROUNDING_ERROR)*drand()+ROUNDING_ERROR/2.0));
 Assign_Plane (&p, s, p_cwn->sx, p_cwn->sy);
 phi		= 2.0*DPI_RAD*drand();
 d			= d3Vector_double_multiply (p.xp, cos(phi));
 d			= d3Vector_sum (d, d3Vector_double_multiply (p.yp, sin(phi)));
 Assign_Ray_d3V (&r, s, &d);
 rtn_value	= RayCrownIntersection (&r, p_cwn, &s1, &alpha1, &s2, &alpha2);
 if (rtn_value == NO_RAYCROWN_ERRORS) {
  if (alpha1*alpha2 < 0.0) {
   if (alpha1 > alpha2) {
    alpha	=	sqrt (alpha1*alpha1*drand());
   } else {
    alpha	=	sqrt (alpha2*alpha2*drand());
   }
   *s		= d3Vector_sum (*s, d3Vector_double_multiply (d, alpha));
  }
 }
 return (rtn_value);
}
