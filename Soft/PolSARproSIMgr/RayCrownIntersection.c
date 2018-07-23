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
 * Module      : RayCrownIntersection.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 *
 */
#include	"RayCrownIntersection.h"

/**********************************************/
/* Ray intersection procedure implementations */
/**********************************************/

int			RayPlaneIntersection			(Ray *pR, Plane *pP, d3Vector *pS, double *alpha)
{
 int		rtn_value	= NO_RAYPLANE_ERRORS;
 double		adotnp		= d3Vector_scalar_product (pR->a, pP->np);
 double		p0mpdotnp;

 if (fabs(adotnp) > FLT_EPSILON) {
  /**********************************************/
  /* Ray direction is not parallel to the plane */
  /**********************************************/
  p0mpdotnp		= d3Vector_scalar_product (d3Vector_difference (pP->p0, pR->s0), pP->np);
  *alpha		= p0mpdotnp/adotnp;
  *pS			= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha));
 } else {
  if (fabs(d3Vector_scalar_product (d3Vector_difference (pR->s0, pP->p0), pP->np)) > FLT_EPSILON) {
   /************************************************************************************/
   /* Ray starting point lies outside the plane and ray direction is parallel to plane */
   /************************************************************************************/
   rtn_value	= !NO_RAYPLANE_ERRORS;
   *alpha	= 0.0;
   *pS		= Zero_d3Vector ();
  } else {
   /****************************************************************************/
   /* Ray direction is parallel to plane, but starting point lies in the plane */
   /****************************************************************************/
   rtn_value	= !NO_RAYPLANE_ERRORS;
   *alpha		= 0.0;
   Copy_d3Vector (pS, &(pR->s0));
  }
 }
 return (rtn_value);
}

int			RayCylinderIntersection			(Ray *pR, Cylinder *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2)
{
 int		rtn_value	= NO_RAYCYLINDER_ERRORS;
 double		A			= d3Vector_scalar_product (pC->x, d3Vector_difference (pR->s0, pC->base));
 double		B			= d3Vector_scalar_product (pC->x, pR->a);
 double		C			= d3Vector_scalar_product (pC->y, d3Vector_difference (pR->s0, pC->base));
 double		D			= d3Vector_scalar_product (pC->y, pR->a);
 double		B2D2		= B*B+D*D;
 double		ABCD		= A*B+C*D;
 double		sqrt_arg	= ABCD*ABCD-B2D2*(A*A+C*C-pC->radius*pC->radius);

 if (fabs(B2D2) > FLT_EPSILON) {
  if (sqrt_arg >= 0.0) {
   *alpha1	=  (sqrt(sqrt_arg)-ABCD)/B2D2;
   *alpha2	= -(sqrt(sqrt_arg)+ABCD)/B2D2;
   *pS1		= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha1));
   *pS2		= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha2));
  } else {
   rtn_value	= !NO_RAYCYLINDER_ERRORS;
  }
 } else {
  rtn_value	= !NO_RAYCYLINDER_ERRORS;
 }
 return (rtn_value);
}

int			RayConeIntersection				(Ray *pR, Cone *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2)
{
 int		rtn_value	= NO_RAYCONE_ERRORS;
 double		A			= d3Vector_scalar_product (pC->x, d3Vector_difference (pR->s0, pC->base));
 double		B			= d3Vector_scalar_product (pC->x, pR->a);
 double		C			= d3Vector_scalar_product (pC->y, d3Vector_difference (pR->s0, pC->base));
 double		D			= d3Vector_scalar_product (pC->y, pR->a);
 double		E			= d3Vector_scalar_product (pC->axis, d3Vector_difference (pR->s0, pC->base));
 double		F			= d3Vector_scalar_product (pC->axis, pR->a);
 double		tan_beta	= tan(pC->beta);
 double		tan_beta_2	= tan_beta*tan_beta;
 double		a			= B*B+D*D-F*F*tan_beta_2;
 double		b			= 2.0*(A*B+C*D+F*(pC->height-E)*tan_beta_2);
 double		c			= A*A+C*C-(pC->height-E)*(pC->height-E)*tan_beta_2;
 double		sqrt_arg	= b*b-4.0*a*c;

 if (fabs(a) > FLT_EPSILON) {
  if (sqrt_arg >= 0.0) {
   *alpha1	=  (sqrt(sqrt_arg)-b)/(2.0*a);
   *alpha2	= -(sqrt(sqrt_arg)+b)/(2.0*a);
   *pS1		= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha1));
   *pS2		= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha2));
  } else {
   rtn_value	= !NO_RAYCONE_ERRORS;
  }
 } else {
  rtn_value	= !NO_RAYCONE_ERRORS;
 }
 return (rtn_value);
}

int			RaySpheroidIntersection			(Ray *pR, Spheroid *pS, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2)
{
 int		rtn_value	= NO_RAYSPHEROID_ERRORS;
 double		A			= d3Vector_scalar_product (pS->x, d3Vector_difference (pR->s0, pS->base));
 double		B			= d3Vector_scalar_product (pS->x, pR->a);
 double		C			= d3Vector_scalar_product (pS->y, d3Vector_difference (pR->s0, pS->base));
 double		D			= d3Vector_scalar_product (pS->y, pR->a);
 double		E			= d3Vector_scalar_product (pS->axis, d3Vector_difference (pR->s0, pS->base));
 double		F			= d3Vector_scalar_product (pS->axis, pR->a);
 double		tan_beta	= tan(pS->beta);
 double		tan_beta_2	= tan_beta*tan_beta;
 double		h			= pS->h;
 double		a1			= pS->a1;
 double		a			= B*B+D*D+F*F*tan_beta_2;
 double		b			= 2.0*(A*B+C*D+F*(a1-h+E)*tan_beta_2);
 double		c			= A*A+C*C-tan_beta_2*(a1*a1-(a1-h+E)*(a1-h+E));
 double		sqrt_arg	= b*b-4.0*a*c;

 if (fabs(a) > FLT_EPSILON) {
  if (sqrt_arg >= 0.0) {
   *alpha1	=  (sqrt(sqrt_arg)-b)/(2.0*a);
   *alpha2	= -(sqrt(sqrt_arg)+b)/(2.0*a);
   *pS1		= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha1));
   *pS2		= d3Vector_sum (pR->s0, d3Vector_double_multiply (pR->a, *alpha2));
  } else {
   rtn_value	= !NO_RAYSPHEROID_ERRORS;
  }
 } else {
  rtn_value	= !NO_RAYSPHEROID_ERRORS;
 }
 return (rtn_value);
}

int			RayCrownIntersection			(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2)
{
 int				rtn_value;

 /************************/
 /* Default is failure : */
 /************************/
 *alpha1			= 0;
 *pS1				= Zero_d3Vector ();
 *alpha2			= 0;
 *pS2				= Zero_d3Vector ();
 rtn_value			= !NO_RAYCROWN_ERRORS;
 /********************************/
 /* Act according to crown shape */
 /********************************/
 switch (pC->shape) {
  case CROWN_CYLINDER:	rtn_value	= RayCrownCylinderIntersection	(pR, pC, pS1, alpha1, pS2, alpha2); break;
  case CROWN_CONE:		rtn_value	= RayCrownConeIntersection		(pR, pC, pS1, alpha1, pS2, alpha2); break;
  case CROWN_SPHEROID:	rtn_value	= RayCrownSpheroidIntersection	(pR, pC, pS1, alpha1, pS2, alpha2); break;
 }
 /********************/
 /* Return to caller */
 /********************/
 return (rtn_value);
}

/**********************************************/
/* Correction for pine001 primary calculation */
/**********************************************/

int			RayCrownSpheroidIntersection		(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
												d3Vector *pS2, double *alpha2)
{
 int			rtn_value	= !NO_RAYCROWN_ERRORS;
 Spheroid		sph;
 Plane			plane;
 d3Vector		s_plane;
 double			alpha_plane;
 d3Vector		s_sph1;
 double			alpha_sph1;
 d3Vector		s_sph2;
 double			alpha_sph2;
 int			plane_value;
 int			spheroid_value;
/***************************/
/* New flags and variables */
/***************************/
 int			plane_flag		= 0;
 int			sphrd1_flag		= 0;
 int			sphrd2_flag		= 0;
 int			final_flag		= 0;
 d3Vector		d;
 double			dx, dy, dz;
 double			r2, R2;
 double			a12, a22, a3;
/************************/
/* Default is failure : */
/************************/
 *alpha1			= 0;
 *pS1				= Zero_d3Vector ();
 *alpha2			= 0;
 *pS2				= Zero_d3Vector ();
/*******************/
/* Initialisations */
/*******************/
 Assign_Spheroid	(&sph, pC->d1, pC->d2, pC->d3, pC->axis, pC->base);
 Assign_Plane		(&plane, &(pC->base), pC->sx, pC->sy);
 plane_value		= RayPlaneIntersection		(pR, &plane, &s_plane, &alpha_plane);
 spheroid_value		= RaySpheroidIntersection	(pR, &sph, &s_sph1, &alpha_sph1, &s_sph2, &alpha_sph2);
/*************************************/
/* Test condition on planar solution */
/*************************************/
 if (plane_value == NO_RAYPLANE_ERRORS) {
  d					= d3Vector_difference (s_plane, pC->base);
  dx				= d3Vector_scalar_product (d, pC->x);
  dy				= d3Vector_scalar_product (d, pC->y);
  dz				= d3Vector_scalar_product (d, pC->axis);
  r2				= dx*dx + dy*dy;
  a12				= pC->d1*pC->d1;
  a22				= pC->d2*pC->d2;
  a3				= pC->d1-pC->d3+dz;
  R2				= (a22/a12)*(a12-a3*a3);
  if (r2 <= R2) {
   plane_flag		= 1;
  }
 }
/****************************************/
/* Test condition on spheroid solutions */
/****************************************/
 if (spheroid_value == NO_RAYSPHEROID_ERRORS) {
  d					= d3Vector_difference (s_sph1, pC->base);
  dz				= d3Vector_scalar_product (d, plane.np);
  if (dz >= -FLT_EPSILON) {
   sphrd1_flag		= 1;
  }
  d					= d3Vector_difference (s_sph2, pC->base);
  dz				= d3Vector_scalar_product (d, plane.np);
  if (dz >= -FLT_EPSILON) {
   sphrd2_flag		= 1;
  }
 }
/******************************/
/* Calculate final flag value */
/******************************/
 final_flag			= plane_flag + 2*sphrd1_flag + 4*sphrd2_flag;
/*************************************************/
/* Only three good values ...                    */
/* 3: return planar and spheroid 1 solutions     */
/* 5: return planar and spheroid 2 solutions     */
/* 6: return spheroid 1 and spheroid 2 solutions */
/*************************************************/
 switch (final_flag) {
  case 3:	Copy_d3Vector (pS1, &s_plane);
			Copy_d3Vector (pS2, &s_sph1);
			*alpha1	= alpha_plane;
			*alpha2	= alpha_sph1;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 5:	Copy_d3Vector (pS1, &s_plane);
			Copy_d3Vector (pS2, &s_sph2);
			*alpha1	= alpha_plane;
			*alpha2	= alpha_sph2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 6:	Copy_d3Vector (pS1, &s_sph1);
			Copy_d3Vector (pS2, &s_sph2);
			*alpha1	= alpha_sph1;
			*alpha2	= alpha_sph2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  default: break;
 }
 return (rtn_value);
}

/************************************************/
/* Correction for pine002/3 primary calculation */
/************************************************/

int			RayCrownConeIntersection		(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2)
{
 int			rtn_value	= !NO_RAYCROWN_ERRORS;
 Cone			con;
 Plane			plane;
 d3Vector		s_plane;
 double			alpha_plane;
 d3Vector		s_con1;
 double			alpha_con1;
 d3Vector		s_con2;
 double			alpha_con2;
 int			plane_value;
 int			cone_value;
/***************************/
/* New flags and variables */
/***************************/
 int			plane_flag		= 0;
 int			cone1_flag		= 0;
 int			cone2_flag		= 0;
 int			final_flag		= 0;
 d3Vector		d;
 double			dx, dy, dz;
 double			r2, R2;
 double			a12, a22, a3;
/************************/
/* Default is failure : */
/************************/
 *alpha1			= 0;
 *pS1				= Zero_d3Vector ();
 *alpha2			= 0;
 *pS2				= Zero_d3Vector ();
/*******************/
/* Initialisations */
/*******************/
 Assign_Cone		(&con, pC->d1, pC->d2, pC->axis, pC->base);
 Assign_Plane		(&plane, &(pC->base), pC->sx, pC->sy);
 plane_value		= RayPlaneIntersection	(pR, &plane, &s_plane, &alpha_plane);
 cone_value			= RayConeIntersection	(pR, &con, &s_con1, &alpha_con1, &s_con2, &alpha_con2);
/*************************************/
/* Test condition on planar solution */
/*************************************/
 if (plane_value == NO_RAYPLANE_ERRORS) {
  d					= d3Vector_difference (s_plane, pC->base);
  dx				= d3Vector_scalar_product (d, pC->x);
  dy				= d3Vector_scalar_product (d, pC->y);
  dz				= d3Vector_scalar_product (d, pC->axis);
  r2				= dx*dx + dy*dy;
  a12				= pC->d1*pC->d1;
  a22				= pC->d2*pC->d2;
  a3				= pC->d1-dz;
  R2				= (a22/a12)*(a3*a3);
  if (r2 <= R2) {
   plane_flag		= 1;
  }
 }
/***************************************/
/* Test condition on conical solutions */
/***************************************/
 if (cone_value == NO_RAYCONE_ERRORS) {
  d					= d3Vector_difference (s_con1, pC->base);
  dz				= d3Vector_scalar_product (d, plane.np);
  dx				= pC->d1 - d3Vector_scalar_product (d, pC->axis);
  if ((dz >= -FLT_EPSILON) && (dx >= -FLT_EPSILON)) {
   cone1_flag		= 1;
  }
  d					= d3Vector_difference (s_con2, pC->base);
  dz				= d3Vector_scalar_product (d, plane.np);
  dx				= pC->d1 - d3Vector_scalar_product (d, pC->axis);
  if ((dz >= -FLT_EPSILON) && (dx >= -FLT_EPSILON)) {
   cone2_flag		= 1;
  }
 }
/******************************/
/* Calculate final flag value */
/******************************/
 final_flag			= plane_flag + 2*cone1_flag + 4*cone2_flag;
/***********************************************/
/* Only three good values ...                  */
/* 3: return planar and conical 1 solutions    */
/* 5: return planar and conical 2 solutions    */
/* 6: return conical 1 and conical 2 solutions */
/***********************************************/
 switch (final_flag) {
  case 3:	Copy_d3Vector (pS1, &s_plane);
			Copy_d3Vector (pS2, &s_con1);
			*alpha1	= alpha_plane;
			*alpha2	= alpha_con1;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 5:	Copy_d3Vector (pS1, &s_plane);
			Copy_d3Vector (pS2, &s_con2);
			*alpha1	= alpha_plane;
			*alpha2	= alpha_con2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 6:	Copy_d3Vector (pS1, &s_con1);
			Copy_d3Vector (pS2, &s_con2);
			*alpha1	= alpha_con1;
			*alpha2	= alpha_con2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  default: break;
 }
 return (rtn_value);
}

/***/

int			RayCrownCylinderIntersection	(Ray *pR, Crown *pC, d3Vector *pS1, double *alpha1, 
											 d3Vector *pS2, double *alpha2)
{
 int			rtn_value	= !NO_RAYCROWN_ERRORS;
 Cylinder		cyl;
 Plane			plane0;
 Plane			plane1;
 d3Vector		s_plane0;
 double			alpha_plane0;
 d3Vector		s_plane1;
 double			alpha_plane1;
 d3Vector		s_cyl1;
 double			alpha_cyl1;
 d3Vector		s_cyl2;
 double			alpha_cyl2;
 Complex		er; 
 d3Vector		base1;
 int			plane0_value;
 int			plane1_value;
 int			cylinder_value;
 d3Vector		d;
 double			dx, dy;
 double			d0, d1;
 double			r2, R2;
 int			plane0_flag	= 0;
 int			plane1_flag	= 0;
 int			cyl1_flag	= 0;
 int			cyl2_flag	= 0;
 int			final_flag	= 0;

 Create_Complex		(&er);
 Create_Cylinder	(&cyl);
 Create_Plane		(&plane0);
 Create_Plane		(&plane1);
 Create_d3Vector	(&s_plane0);
 Create_d3Vector	(&s_plane1);
 Create_d3Vector	(&s_cyl1);
 Create_d3Vector	(&s_cyl2);
 Create_d3Vector	(&base1);
 /************************/
 /* Default is failure : */
 /************************/
 *alpha1			= 0;
 *pS1				= Zero_d3Vector ();
 *alpha2			= 0;
 *pS2				= Zero_d3Vector ();
 /*******************/
 /* Initialisations */
 /*******************/
 Cartesian_Assign_Complex (&er, 1.0, 0.0);
 Assign_Cylinder (&cyl, pC->d1, pC->d2, er, pC->axis, pC->base);
 Assign_Plane (&plane0, &(pC->base), pC->sx, pC->sy);
 base1				= d3Vector_sum (pC->base, d3Vector_double_multiply (pC->axis, pC->d1));
 Assign_Plane (&plane1, &base1, pC->sx, pC->sy);
 plane0_value		= RayPlaneIntersection (pR, &plane0, &s_plane0, &alpha_plane0);
 cylinder_value		= RayCylinderIntersection (pR, &cyl, &s_cyl1, &alpha_cyl1, &s_cyl2, &alpha_cyl2);
 plane1_value		= RayPlaneIntersection (pR, &plane1, &s_plane1, &alpha_plane1);
 R2					= pC->d2*pC->d2;
/**************************************/
/* Test condition on plane 0 solution */
/**************************************/
 if (plane0_value == NO_RAYPLANE_ERRORS) {
  d					= d3Vector_difference (s_plane0, pC->base);
  dx				= d3Vector_scalar_product (d, pC->x);
  dy				= d3Vector_scalar_product (d, pC->y);
  r2				= dx*dx + dy*dy;
  if (r2 <= R2) {
   plane0_flag		= 1;
  }
 }
/****************************************/
/* Test condition on cylinder solutions */
/****************************************/
 if (cylinder_value == NO_RAYCYLINDER_ERRORS) {
  d					= d3Vector_difference (s_cyl1, pC->base);
  d0				= d3Vector_scalar_product (d, plane1.np);
  d					= d3Vector_difference (s_cyl1, base1);
  d1				= d3Vector_scalar_product (d, plane0.np);
  if ((d0 >= -FLT_EPSILON) && (d1 <= +FLT_EPSILON)) {
   cyl1_flag		= 1;
  }
  d					= d3Vector_difference (s_cyl2, pC->base);
  d0				= d3Vector_scalar_product (d, plane1.np);
  d					= d3Vector_difference (s_cyl2, base1);
  d1				= d3Vector_scalar_product (d, plane0.np);
  if ((d0 >= -FLT_EPSILON) && (d1 <= +FLT_EPSILON)) {
   cyl2_flag		= 1;
  }
 }
/**************************************/
/* Test condition on plane 1 solution */
/**************************************/
 if (plane1_value == NO_RAYPLANE_ERRORS) {
  d					= d3Vector_difference (s_plane1, pC->base);
  dx				= d3Vector_scalar_product (d, pC->x);
  dy				= d3Vector_scalar_product (d, pC->y);
  r2				= dx*dx + dy*dy;
  if (r2 <= R2) {
   plane1_flag		= 1;
  }
 }
/******************************/
/* Calculate final flag value */
/******************************/
 final_flag	= plane0_flag + 2*plane1_flag + 4*cyl1_flag + 8*cyl2_flag;
/****************************************************/
/* There are six good values ...					*/
/* 3:	two planar intersections					*/
/* 5:	plane0 and first cylinder intersections		*/
/* 6:	plane1 and first cylinder intersections		*/
/* 9:	plane0 and second cylinder intersections	*/
/* 10:	plane1 and second cylinder intersections	*/
/* 12:	first and second cylinder intersections		*/
/****************************************************/
 switch (final_flag) {
  case 3:	Copy_d3Vector (pS1, &s_plane0);
			Copy_d3Vector (pS2, &s_plane1);
			*alpha1		= alpha_plane0;
			*alpha2		= alpha_plane1;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 5:	Copy_d3Vector (pS1, &s_plane0);
			Copy_d3Vector (pS2, &s_cyl1);
			*alpha1		= alpha_plane0;
			*alpha2		= alpha_cyl1;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 6:	Copy_d3Vector (pS1, &s_plane1);
			Copy_d3Vector (pS2, &s_cyl1);
			*alpha1		= alpha_plane1;
			*alpha2		= alpha_cyl1;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 9:	Copy_d3Vector (pS1, &s_plane0);
			Copy_d3Vector (pS2, &s_cyl2);
			*alpha1		= alpha_plane0;
			*alpha2		= alpha_cyl2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 10:	Copy_d3Vector (pS1, &s_plane1);
			Copy_d3Vector (pS2, &s_cyl2);
			*alpha1		= alpha_plane1;
			*alpha2		= alpha_cyl2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  case 12:	Copy_d3Vector (pS1, &s_cyl1);
			Copy_d3Vector (pS2, &s_cyl2);
			*alpha1		= alpha_cyl1;
			*alpha2		= alpha_cyl2;
			rtn_value	= NO_RAYCROWN_ERRORS;
			break;
  default: break;
 }
/***********/
/* Tidy up */
/***********/
 Destroy_Cylinder	(&cyl);
 Destroy_Plane		(&plane0);
 Destroy_Plane		(&plane1);
 Destroy_d3Vector	(&s_plane0);
 Destroy_d3Vector	(&s_plane1);
 Destroy_d3Vector	(&s_cyl1);
 Destroy_d3Vector	(&s_cyl2);
 /*****************************/
 /* Return to calling routine */
 /*****************************/
 return (rtn_value);
}

/***/

