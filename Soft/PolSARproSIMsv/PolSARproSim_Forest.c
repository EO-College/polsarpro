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
 * Module      : PolSARproSim_Forest.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Forest interferometric SAR image calculation for PolSARproSim
 */
#include	"PolSARproSim_Forest.h"

/*************************/
/* SAR geometry routines */
/*************************/

void	Zero_SG_Accumulators			(SarGeometry *pSG)
{
 pSG->Sigma0HH			= 0.0;
 pSG->Sigma0HV			= 0.0;
 pSG->Sigma0VH			= 0.0;
 pSG->Sigma0VV			= 0.0;
 Polar_Assign_Complex (&(pSG->AvgShhvv), 0.0, 0.0);
 pSG->Sigma0_count		= 0.0;
 return;
}

int		Initialise_SAR_Geometry			(SarGeometry *pSG, PolSARproSim_Record *pPR)
{
 int				rtn_value;
 double				std_h;
 double				k0z, k0z2, k02, kro2, kro;
 Complex			k22, k2, k2z2, k2z, koz2, kez2, koz, kez, ke2, ke, kiz, k12, k1;
 Complex			Rhh, Rvv, delta;
 double				gf, Rg;
/************************************/
/* Determine mean surface roughness */
/************************************/
 switch (POLSARPROSIM_RAYLEIGH_ROUGHNESS_MODEL) {
  case 0:	std_h	= pPR->large_scale_height_stdev; break;
  case 1:	std_h	= pPR->small_scale_height_stdev; break;
  case 2:	std_h	= pPR->small_scale_height_stdev + pPR->large_scale_height_stdev; break;
  default:	std_h	= pPR->small_scale_height_stdev + pPR->large_scale_height_stdev; break;
 }
 fprintf (pPR->pLogFile, "std_h\t\t= %lf  \n", std_h);
/*********************************/
/* Direct backscatter quantities */
/*********************************/
 pSG->Pi			= 4.0*atan(1.0);
 pSG->thetai		= pPR->incidence_angle[pPR->current_track];
 pSG->cos_thetai	= cos(pSG->thetai);
 pSG->sin_thetai	= sin(pSG->thetai);
 pSG->p_srange		= pPR->slant_range[pPR->current_track];
 pSG->p_thetai		= pPR->incidence_angle[pPR->current_track];
 pSG->p_height		= pSG->p_srange*cos(pSG->p_thetai);
 pSG->p_grange		= pSG->p_srange*sin(pSG->p_thetai);
 rtn_value			= Initialise_Standard_Jnlookup (&(pSG->Jtable));
 rtn_value			= Initialise_Standard_Ynlookup (&(pSG->Ytable));
 pSG->ki			= Cartesian_Assign_d3Vector (0.0,  pPR->k0*pSG->sin_thetai, -pPR->k0*pSG->cos_thetai);
 pSG->ks			= Cartesian_Assign_d3Vector (0.0,  -pPR->k0*pSG->sin_thetai, pPR->k0*pSG->cos_thetai);
 pSG->ch			= Assign_c3Vector (xy_complex(-1.0, 0.0), xy_complex(0.0, 0.0), xy_complex(0.0, 0.0));
 pSG->cv			= Assign_c3Vector (xy_complex(0.0, 0.0), xy_complex(-pSG->cos_thetai, 0.0), xy_complex(-pSG->sin_thetai, 0.0));
/*********************************/
/* Bounce backscatter quantities */
/*********************************/
 pSG->n				= Cartesian_Assign_d3Vector (-pPR->slope_x, -pPR->slope_y, 1.0);
 d3Vector_insitu_normalise (&(pSG->n));
 pSG->z				= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
/********************/
/* FSA wave vectors */
/********************/
 pSG->kr			= d3Vector_reflect (pSG->ki, pSG->n);
 pSG->krm			= d3Vector_double_multiply (pSG->kr, -1.0);
/****************************/
/* FSA polarisation vectors */
/****************************/
 rtn_value	= Polarisation_Vectors (pSG->ki,  pSG->z, &(pSG->hi),  &(pSG->vi));
 rtn_value	= Polarisation_Vectors (pSG->ks,  pSG->z, &(pSG->hs),  &(pSG->vs));
 rtn_value	= Polarisation_Vectors (pSG->kr,  pSG->z, &(pSG->hr),  &(pSG->vr));
 rtn_value	= Polarisation_Vectors (pSG->krm, pSG->z, &(pSG->hrm), &(pSG->vrm));
 rtn_value	= Polarisation_Vectors (pSG->ki,  pSG->n, &(pSG->hil),  &(pSG->vil));
 rtn_value	= Polarisation_Vectors (pSG->ks,  pSG->n, &(pSG->hsl),  &(pSG->vsl));
 rtn_value	= Polarisation_Vectors (pSG->kr,  pSG->n, &(pSG->hrl),  &(pSG->vrl));
 rtn_value	= Polarisation_Vectors (pSG->krm, pSG->n, &(pSG->hrlm), &(pSG->vrlm));
 pSG->chi	= d3V2c3V (pSG->hi);
 pSG->cvi	= d3V2c3V (pSG->vi);
 pSG->chs	= d3V2c3V (pSG->hs);
 pSG->cvs	= d3V2c3V (pSG->vs);
 pSG->chr	= d3V2c3V (pSG->hr);
 pSG->cvr	= d3V2c3V (pSG->vr);
 pSG->chrm	= d3V2c3V (pSG->hrm);
 pSG->cvrm	= d3V2c3V (pSG->vrm);
 pSG->chil	= d3V2c3V (pSG->hil);
 pSG->cvil	= d3V2c3V (pSG->vil);
 pSG->chsl	= d3V2c3V (pSG->hsl);
 pSG->cvsl	= d3V2c3V (pSG->vsl);
 pSG->chrl	= d3V2c3V (pSG->hrl);
 pSG->cvrl	= d3V2c3V (pSG->vrl);
 pSG->chrlm	= d3V2c3V (pSG->hrlm);
 pSG->cvrlm	= d3V2c3V (pSG->vrlm);
/*********************************/
/* Local reflection coefficients */
/*********************************/
 k0z		= d3Vector_scalar_product (pSG->kr, pSG->n);
 k0z2		= k0z*k0z;
 k02		= pPR->k0*pPR->k0;
 kro2		= k02 - k0z2;
 kro		= sqrt(kro2);
 k22		= complex_rmul (pPR->ground_eps, k02);
 k2			= complex_sqrt (k22);
 k2z2		= complex_sub  (k22, xy_complex (kro2, 0.0));
 k2z		= complex_sqrt (k2z2);
 koz2		= Copy_Complex (&(pPR->koz2_short));
 kez2		= Copy_Complex (&(pPR->kez2_short));
 koz		= Copy_Complex (&(pPR->koz_short));
 kez		= Copy_Complex (&(pPR->kez_short));
 ke2		= complex_add  (kez2, xy_complex (kro2, 0.0));
 ke			= complex_sqrt (ke2);
 kiz		= xy_complex   (k0z, 0.0);
 k12		= complex_rmul (pPR->e11_short, k02);
 k1			= complex_sqrt (k12);
 Rhh		= complex_div (complex_sub (koz, k2z), complex_add (koz, k2z));
 delta		= complex_add (complex_mul (kez, k22), complex_mul (k2z, k12));
 Rvv		= complex_div (complex_sub (complex_mul (kez, k22), complex_mul(k2z, k12)), delta);
 fprintf (pPR->pLogFile, "|Rhh|^2\t= %lf  \n", Rhh.r*Rhh.r);
 fprintf (pPR->pLogFile, "|Rvv|^2\t= %lf  \n", Rvv.r*Rvv.r);
 gf			= 4.0*std_h*std_h*k0z2;
 Rg			= exp(-gf/2.0);
 fprintf (pPR->pLogFile, "gf\t\t= %lf  \n", gf);
 fprintf (pPR->pLogFile, "Rg\t\t= %lf  \n", Rg);
 Rhh		= complex_rmul (Rhh, Rg);
 Rvv		= complex_rmul (Rvv, Rg);
 fprintf (pPR->pLogFile, "|Rhh|^2\t= %lf  \n", Rhh.r*Rhh.r);
 fprintf (pPR->pLogFile, "|Rvv|^2\t= %lf  \n", Rvv.r*Rvv.r);
 pSG->R1	= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chrl, pSG->chil), Rhh);
 pSG->R1	= c33Matrix_sum (pSG->R1, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvrl, pSG->cvil), Rvv));
 pSG->R2	= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chsl, pSG->chrlm), Rhh);
 pSG->R2	= c33Matrix_sum (pSG->R2, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvsl, pSG->cvrlm), Rvv));
/******************/
/* RCS estimators */
/******************/
 Zero_SG_Accumulators (pSG);
 return (rtn_value);
}

int		Delete_SAR_Geometry			(SarGeometry *pSG)
{
 int		rtn_value;

 rtn_value	= Delete_Jnlookup		(&(pSG->Jtable));
 rtn_value	= Delete_Ynlookup		(&(pSG->Ytable));
 return (rtn_value);
}

/***********************************************************/
/* Forest interferometric SAR image calculation definition */
/***********************************************************/

double		Image_Cylinder_Direct	(Cylinder *pC, SarGeometry *pSG, PolSARproSim_Record *pPR, double Sa_scaling, int flag)
{
 c33Matrix			Scyl;
 c3Vector			Eh, Ev;
 Complex			Shh, Shv, Svh, Svv;
 d3Vector			cyl_centre			= d3Vector_sum (pC->base, d3Vector_double_multiply (pC->axis, 0.5*pC->length));
#ifdef SWITCH_ATTENUATION_ON
 double				gH, gV;
 int				rtn_lookup;
#endif
 double				cyl_x, cyl_y, cyl_grange, cyl_srange, cyl_height;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 double				weight_average;
 d3Vector			tip;
/************************/
/* Mark cylinder centre */
/************************/
 cyl_x				= cyl_centre.x[0];
 cyl_y				= cyl_centre.x[1];
 cyl_height			= cyl_centre.x[2];
/***************************************/
/* Equivalent upward pointing cylinder */
/***************************************/
 if (pC->axis.theta > DPI_RAD/2.0) {
  tip		= d3Vector_sum (pC->base, d3Vector_double_multiply (pC->axis, pC->length));
  pC->axis	= d3Vector_double_multiply (pC->axis, -1.0);
  Assign_Cylinder (pC, pC->length, pC->radius, pC->permittivity, pC->axis, tip);
 }
/************************************************/
/* Calculate the cylinder scattering amplitudes */
/************************************************/
 if (flag == POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES) {
  Scyl				= InfCylSav2	(pC, &(pSG->ks), &(pSG->ki), &(pSG->Ytable), &(pSG->Jtable));
 } else {
  Scyl				= GrgCylSa		(pC, &(pSG->ks), &(pSG->ki));
 }
 Eh					= c33Matrix_c3Vector_product	(Scyl, pSG->ch);
 Ev					= c33Matrix_c3Vector_product	(Scyl, pSG->cv);
 Shh				= c3Vector_scalar_product	(pSG->ch, Eh);
 Shv				= c3Vector_scalar_product	(pSG->ch, Ev);
 Svh				= c3Vector_scalar_product	(pSG->cv, Eh);
 Svv				= c3Vector_scalar_product	(pSG->cv, Ev);
/***********************************/
/* Incorporate attenuation effects */
/***********************************/
#ifdef SWITCH_ATTENUATION_ON
 rtn_lookup			= Lookup_Direct_Attenuation (cyl_centre, pPR, &gH, &gV);
 Shh				= complex_rmul (Shh, gH*gH);
 Shv				= complex_rmul (Shv, gH*gV);
 Svh				= complex_rmul (Svh, gV*gH);
 Svv				= complex_rmul (Svv, gV*gV);
#endif
/*****************************************/
/* Incorporate stochastic scaling factor */
/*****************************************/
 Shh				= complex_rmul (Shh, Sa_scaling);
 Shv				= complex_rmul (Shv, Sa_scaling);
 Svh				= complex_rmul (Svh, Sa_scaling);
 Svv				= complex_rmul (Svv, Sa_scaling);
/**************************************/
/* Monitor backscattering coefficient */
/**************************************/
 pSG->Sigma0HH		+= Shh.r*Shh.r;
 pSG->Sigma0HV		+= Shv.r*Shv.r;
 pSG->Sigma0VH		+= Svh.r*Svh.r;
 pSG->Sigma0VV		+= Svv.r*Svv.r;
 Polar_Assign_Complex (&(pSG->zhhvv), Shh.r*Svv.r, Shh.phi-Svv.phi);
 pSG->AvgShhvv		= complex_add (pSG->AvgShhvv, pSG->zhhvv);
/******************************************/
/* Calculate the cylinder centre of focus */
/******************************************/
 cyl_grange			= pSG->p_grange + cyl_y;
 cyl_srange			= sqrt ((pSG->p_height-cyl_height)*(pSG->p_height-cyl_height) + cyl_grange*cyl_grange);
 focus_grange		= sqrt (cyl_srange*cyl_srange - pSG->p_height*pSG->p_height);
 focus_x			= cyl_x;
 focus_y			= focus_grange - pSG->p_grange;
 focus_height		= 0.0;
 focus_srange		= sqrt ((pSG->p_height-focus_height)*(pSG->p_height-focus_height) + (pSG->p_grange+focus_y)*(pSG->p_grange+focus_y));
/***************************************************/
/* Combine contribution into SAR image accumulator */
/***************************************************/
 weight_average	= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
 return (weight_average);
}

double		Image_Foliage_Direct	(Leaf *pL, SarGeometry *pSG, PolSARproSim_Record *pPR, double Sa_scaling)
{
 c33Matrix			Sflg;
 c3Vector			Eh, Ev;
 Complex			Shh, Shv, Svh, Svv;
#ifdef SWITCH_ATTENUATION_ON
 double				gH, gV;
 int				rtn_lookup;
#endif
 double				flg_x, flg_y, flg_grange, flg_srange, flg_height;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 double				weight_average;
/*******************************/
/* Mark foliage element centre */
/*******************************/
 flg_x				= pL->cl.x[0];
 flg_y				= pL->cl.x[1];
 flg_height			= pL->cl.x[2];
/***********************************************/
/* Calculate the foliage scattering amplitudes */
/***********************************************/
#ifndef RAYLEIGH_LEAF
 Sflg				= Leaf_Scattering_Matrix (pL, pPR->Tertiary_leafL1, pPR->Tertiary_leafL2, pPR->Tertiary_leafL3, &(pSG->ki), &(pSG->ks));
#else
 Sflg				= Leaf_Scattering_Matrix (pL, pPR->Tertiary_leafL1, pPR->Tertiary_leafL2, pPR->Tertiary_leafL3, &(pSG->ki));
#endif
 Eh					= c33Matrix_c3Vector_product	(Sflg, pSG->ch);
 Ev					= c33Matrix_c3Vector_product	(Sflg, pSG->cv);
 Shh				= c3Vector_scalar_product	(pSG->ch, Eh);
 Shv				= c3Vector_scalar_product	(pSG->ch, Ev);
 Svh				= c3Vector_scalar_product	(pSG->cv, Eh);
 Svv				= c3Vector_scalar_product	(pSG->cv, Ev);
/***********************************/
/* Incorporate attenuation effects */
/***********************************/
#ifdef SWITCH_ATTENUATION_ON
 rtn_lookup			= Lookup_Direct_Attenuation (pL->cl, pPR, &gH, &gV);
 Shh				= complex_rmul (Shh, gH*gH);
 Shv				= complex_rmul (Shv, gH*gV);
 Svh				= complex_rmul (Svh, gV*gH);
 Svv				= complex_rmul (Svv, gV*gV);
#endif
/*****************************************/
/* Incorporate stochastic scaling factor */
/*****************************************/
 Shh				= complex_rmul (Shh, Sa_scaling);
 Shv				= complex_rmul (Shv, Sa_scaling);
 Svh				= complex_rmul (Svh, Sa_scaling);
 Svv				= complex_rmul (Svv, Sa_scaling);
/**************************************/
/* Monitor backscattering coefficient */
/**************************************/
 pSG->Sigma0HH		+= Shh.r*Shh.r;
 pSG->Sigma0HV		+= Shv.r*Shv.r;
 pSG->Sigma0VH		+= Svh.r*Svh.r;
 pSG->Sigma0VV		+= Svv.r*Svv.r;
 Polar_Assign_Complex (&(pSG->zhhvv), Shh.r*Svv.r, Shh.phi-Svv.phi);
 pSG->AvgShhvv		= complex_add (pSG->AvgShhvv, pSG->zhhvv);
/******************************************/
/* Calculate the cylinder centre of focus */
/******************************************/
 flg_grange			= pSG->p_grange + flg_y;
 flg_srange			= sqrt ((pSG->p_height-flg_height)*(pSG->p_height-flg_height) + flg_grange*flg_grange);
 focus_grange		= sqrt (flg_srange*flg_srange - pSG->p_height*pSG->p_height);
 focus_x			= flg_x;
 focus_y			= focus_grange - pSG->p_grange;
 focus_height		= 0.0;
 focus_srange		= sqrt ((pSG->p_height-focus_height)*(pSG->p_height-focus_height) + (pSG->p_grange+focus_y)*(pSG->p_grange+focus_y));
/***************************************************/
/* Combine contribution into SAR image accumulator */
/***************************************************/
 weight_average	= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
 return (weight_average);
}

int		Image_Tree_Direct		(Tree *pT, SarGeometry *pSG, PolSARproSim_Record *pPR)
{
 const double		bsecl	=	POLSARPROSIM_SAR_BRANCH_FACTOR*(pPR->azimuth_resolution + pPR->slant_range_resolution);
 long				iBranch;
 Branch				*pB;
 int				Nsections;
 int				i_section;
 double				deltat, deltar;
 Cylinder			cyl1;
 double				weight_sum;
 double				weight_count;
 double				weight_avg;
 int				rtn_value;
 double				tb_scaling;
 double				flg_scaling;
 long				iLeaf;
 Leaf				*pL;
 int				Cscatt_Flag;
#ifndef POLSARPROSIM_NO_SAR_TERTIARIES
 Branch				tertiary_branch;
 double				tertiary_branch_length, tertiary_branch_radius;
 long				n_Tertiary;
 double				tertiary_moisture;
 Complex			tertiary_permittivity;
#endif
#ifndef POLSARPROSIM_NO_SAR_FOLIAGE
 long				n_Leaves;
 int				L_species;
 double				leaf_d1, leaf_d2, leaf_d3;
 double				L_moisture;
 Complex			L_permittivity;
 Leaf				tree_leaf;
#endif

/************************/
/* Initialise variables */
/************************/
 Create_Cylinder (&cyl1);
#ifndef FORCE_GRG_CYLINDERS
  Cscatt_Flag	= POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES;
#else
  Cscatt_Flag	= POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES;
#endif
/*******************/
/* Image the stems */
/*******************/
#ifndef POLSARPROSIM_NO_SAR_STEMS
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pB			= pT->Stem.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Stem.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value	= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum	+= Image_Cylinder_Direct (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
#endif
/**************************/
/* Image primary branches */
/**************************/
#ifndef POLSARPROSIM_NO_SAR_PRIMARIES
 if ((pPR->species == POLSARPROSIM_PINE001) || (pPR->species == POLSARPROSIM_PINE002) || (pPR->species == POLSARPROSIM_PINE003)){
  pB			= pT->Dry.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Dry.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value	= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum	+= Image_Cylinder_Direct (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pB			= pT->Primary.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Primary.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value	= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum	+= Image_Cylinder_Direct (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
#endif
/****************************/
/* Image secondary branches */
/****************************/
#ifndef POLSARPROSIM_NO_SAR_SECONDARIES
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pB			= pT->Secondary.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Secondary.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value	= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum	+= Image_Cylinder_Direct (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
#endif
/***************************/
/* Image tertiary branches */
/***************************/
#ifndef POLSARPROSIM_NO_SAR_TERTIARIES
#ifndef FORCE_GRG_CYLINDERS
if (pPR->Grg_Flag == 0) {
 Cscatt_Flag	=    POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES;
} else {
 Cscatt_Flag	=    POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES;
}
#endif
 tb_scaling				= Estimate_SAR_Tertiaries (pT, pPR, &n_Tertiary, &tertiary_branch_length, &tertiary_branch_radius);
 weight_sum				= 0.0;
 weight_count			= 0.0;
 pB						= &tertiary_branch;
 Create_Branch (pB);
 tertiary_moisture		= Tertiary_Branch_Moisture (pT->species);
 tertiary_permittivity	= vegetation_permittivity (tertiary_moisture, pPR->frequency);
 for (iBranch=0L; iBranch < n_Tertiary; iBranch++) {
  if (pT->species != POLSARPROSIM_HEDGE) {
   tertiary_moisture		= Tertiary_Branch_Moisture (pT->species);
   tertiary_permittivity	= vegetation_permittivity (tertiary_moisture, pPR->frequency);
  }
  rtn_value				= Realise_Tertiary_Branch (pT, pPR, pB, tertiary_branch_length, tertiary_branch_radius, tertiary_moisture, tertiary_permittivity);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   Nsections			= (int) (pB->l/bsecl) + 1;
   deltat				= 1.0 / (double) Nsections;
   deltar				= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value			 = Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum			+= Image_Cylinder_Direct (&cyl1, pSG, pPR, tb_scaling, Cscatt_Flag);
    weight_count		+= 1.0;
   }
  }
 }
 weight_avg		= weight_sum/weight_count;
 Destroy_Branch (pB);
#endif
/*****************/
/* Image foliage */
/*****************/
#ifndef POLSARPROSIM_NO_SAR_FOLIAGE
 L_species		= Leaf_Species		(pT->species);
 leaf_d1		= Leaf_Dimension_1	(pT->species);
 leaf_d2		= Leaf_Dimension_2	(pT->species);
 leaf_d3		= Leaf_Dimension_3	(pT->species);
 L_moisture		= Leaf_Moisture		(pT->species);
 L_permittivity	= vegetation_permittivity (L_moisture, pPR->frequency);
 pL				= &tree_leaf;
 Create_Leaf (pL);
 flg_scaling	= Estimate_SAR_Foliage (pT, pPR, &n_Leaves);
 weight_sum		= 0.0;
 weight_count	= 0.0;
 for (iLeaf=0L; iLeaf < n_Leaves; iLeaf++) {
  if (pT->species != POLSARPROSIM_HEDGE) {
   L_moisture		= Leaf_Moisture	(pT->species);
   L_permittivity	= vegetation_permittivity (L_moisture, pPR->frequency);
  }
  rtn_value		= Realise_Foliage_Element (pT, pPR, pL, L_species, leaf_d1, leaf_d2, leaf_d3, L_moisture, L_permittivity);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   weight_sum	+= Image_Foliage_Direct (pL, pSG, pPR, flg_scaling);
   weight_count	+= 1.0;
  }
 }
 Destroy_Leaf (pL);
#endif
/***************/
/* Tidy up ... */
/***************/
 Destroy_Cylinder (&cyl1);
/********************/
/* ... and go home. */
/********************/
 return (NO_POLSARPROSIM_FOREST_ERRORS);
}

int		PolSARproSim_Forest_Direct		(PolSARproSim_Record *pPR)
{
 Tree			tree1;
 int			itree;
 SarGeometry	SG1;
 int			rtn_value;
/**********************/
/* Imaging the forest */
/**********************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to PolSARproSim_Forest_Direct ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to PolSARproSim_Forest_Direct ... \n");
 fflush  (pPR->pLogFile);
/**********************************/
/* Set up the SAR geometry record */
/**********************************/
 rtn_value	= Initialise_SAR_Geometry (&SG1, pPR);
/********************************/
/* Seed random number generator */
/********************************/
 srand (pPR->seed);
/**************************/
/* Main tree imaging loop */
/**************************/
 Create_Tree (&tree1);
 for (itree=0; itree<pPR->Trees; itree++) {
  Realise_Tree		(&tree1, itree, pPR);
  Image_Tree_Direct	(&tree1, &SG1, pPR);
 }
 Destroy_Tree (&tree1);
/***********************/
/* Monitor performance */
/***********************/
 SG1.Sigma0_count	 = pPR->Lx*pPR->Ly;
 SG1.Sigma0HH		/= SG1.Sigma0_count;
 SG1.Sigma0HV		/= SG1.Sigma0_count;
 SG1.Sigma0VH		/= SG1.Sigma0_count;
 SG1.Sigma0VV		/= SG1.Sigma0_count;
 SG1.AvgShhvv		= complex_rmul (SG1.AvgShhvv, 1.0/SG1.Sigma0_count);
 fprintf (pPR->pLogFile, "Direct Forest HH backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0HH));
 fprintf (pPR->pLogFile, "Direct Forest HV backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0HV));
 fprintf (pPR->pLogFile, "Direct Forest VH backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0VH));
 fprintf (pPR->pLogFile, "Direct Forest VV backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0VV));
 fprintf (pPR->pLogFile, "Direct Forest HHVV correlation magnitude   \t= %lf dB\n", 10.0*log10(SG1.AvgShhvv.r));
 fprintf (pPR->pLogFile, "Direct Forest HHVV correlation phase       \t= %lf rads.\n", SG1.AvgShhvv.phi);
 fflush  (pPR->pLogFile);
/***********/
/* Tidy up */
/***********/
 Delete_SAR_Geometry (&SG1);
/**********************************************/
/* Report progress if running in VERBOSE mode */
/**********************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to PolSARproSim_Forest_Direct\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to PolSARproSim_Forest_Direct\n\n");
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
/*****************************/
/* Return to calling routine */
/*****************************/
 return (NO_POLSARPROSIM_FOREST_ERRORS);
}

/*****************************/
/* Ground-volume imaging ... */
/*****************************/

double		Image_Foliage_Bounce	(Leaf *pL, SarGeometry *pSG, PolSARproSim_Record *pPR, double Sa_scaling)
{
 d3Vector			flg_centre;
#ifdef SWITCH_ATTENUATION_ON
 int				rtn_lookup;
 double				gHi, gVi, gHr, gVr, gHs, gVs;
#endif
 c33Matrix			Gi	= Idem_c33Matrix ();
 c33Matrix			Gr	= Idem_c33Matrix ();
 c33Matrix			Gs	= Idem_c33Matrix ();
 c3Vector			Eh, Ev;
 Complex			Shh, Shv, Svh, Svv;
 Complex			zhhvv;
 double				flg_x, flg_y, flg_height;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 double				weight_average	= 0.0;
 Plane				Pg;
 d3Vector			g;
 d3Vector			nm	= d3Vector_double_multiply (pSG->n, -1.0);
 Ray				Rb;
 d3Vector			eff_bounce_centre;
 double				bounce_distance;
 d3Vector			specular_point;
 double				specular_distance;
 double				eff_grange, eff_srange;
 d3Vector			a;
 c33Matrix			Sflg1, Sflg2, SflgT;
 int				rtn_value;
/***********************/
/* Mark foliage centre */
/***********************/
 Copy_d3Vector		(&flg_centre, &(pL->cl));
 flg_x				= flg_centre.x[0];
 flg_y				= flg_centre.x[1];
 flg_height			= flg_centre.x[2];
/*****************************************/
/* Calculate the reflection plane origin */
/*****************************************/
 g					= Cartesian_Assign_d3Vector (flg_x, flg_y, ground_height(pPR, flg_x, flg_y));
 if (flg_height > g.x[2]) {
  Assign_Plane (&Pg, &g, pPR->slope_x, pPR->slope_y);
  Assign_Ray_d3V (&Rb, &flg_centre, &nm);
  rtn_value			= RayPlaneIntersection (&Rb, &Pg, &eff_bounce_centre, &bounce_distance);
  if ((rtn_value == 1) && (bounce_distance >= 0.0)) {
   a					= d3Vector_normalise (pSG->krm);
   Assign_Ray_d3V (&Rb, &flg_centre, &a);
   rtn_value			= RayPlaneIntersection (&Rb, &Pg, &specular_point, &specular_distance);
   if ((rtn_value == 1) && (specular_distance >= 0.0)) {
    /*********************************************/
    /* Calculate the ground-stem centre of focus */
    /*********************************************/
    eff_grange		= pSG->p_grange + eff_bounce_centre.x[1];
    eff_srange		= sqrt ((pSG->p_height-eff_bounce_centre.x[2])*(pSG->p_height-eff_bounce_centre.x[2]) + eff_grange*eff_grange);
    focus_grange	= sqrt (eff_srange*eff_srange - pSG->p_height*pSG->p_height);
    focus_x			= eff_bounce_centre.x[0];
    focus_y			= focus_grange - pSG->p_grange;
    focus_height	= 0.0;
    focus_srange	= sqrt ((pSG->p_height-focus_height)*(pSG->p_height-focus_height) + (pSG->p_grange+focus_y)*(pSG->p_grange+focus_y));
    /******************************************/
    /* Calculate the stem scattering matrices */
    /******************************************/
#ifndef RAYLEIGH_LEAF
	 Sflg1			= Leaf_Scattering_Matrix (pL, pPR->Tertiary_leafL1, pPR->Tertiary_leafL2, pPR->Tertiary_leafL3, &(pSG->kr), &(pSG->ks));
 	 Sflg2			= Leaf_Scattering_Matrix (pL, pPR->Tertiary_leafL1, pPR->Tertiary_leafL2, pPR->Tertiary_leafL3, &(pSG->ki), &(pSG->krm));
#else
	 Sflg1			= Leaf_Scattering_Matrix (pL, pPR->Tertiary_leafL1, pPR->Tertiary_leafL2, pPR->Tertiary_leafL3, &(pSG->kr));
 	 Sflg2			= Leaf_Scattering_Matrix (pL, pPR->Tertiary_leafL1, pPR->Tertiary_leafL2, pPR->Tertiary_leafL3, &(pSG->ki));
#endif
    /**********************************/
    /* Calculate attenuation matrices */
    /**********************************/
#ifdef SWITCH_ATTENUATION_ON
	rtn_lookup		= Lookup_Direct_Attenuation (specular_point, pPR, &gHi, &gVi);
	rtn_lookup		= Lookup_Bounce_Attenuation (flg_centre,     pPR, &gHr, &gVr);
	rtn_lookup		= Lookup_Direct_Attenuation (flg_centre,     pPR, &gHs, &gVs);
	Gi				= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chi, pSG->chi), xy_complex (gHi, 0.0));
	Gi				= c33Matrix_sum (Gi, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvi, pSG->cvi), xy_complex (gVi, 0.0)));
	Gr				= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chr, pSG->chr), xy_complex (gHr, 0.0));
	Gr				= c33Matrix_sum (Gr, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvr, pSG->cvr), xy_complex (gVr, 0.0)));
	Gs				= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chs, pSG->chs), xy_complex (gHs, 0.0));
	Gs				= c33Matrix_sum (Gs, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvs, pSG->cvs), xy_complex (gVs, 0.0)));
#endif
    /*******************************************************************/
    /* Incorporate reflection and attenuation into scattering matrices */
    /*******************************************************************/
	Sflg1			= c33Matrix_product (Gs, Sflg1);
	Sflg1			= c33Matrix_product (Sflg1, Gr);
	Sflg1			= c33Matrix_product (Sflg1, pSG->R1);
	Sflg1			= c33Matrix_product (Sflg1, Gi);
	Sflg2			= c33Matrix_product (Sflg2, Gs);
	Sflg2			= c33Matrix_product (Gr, Sflg2);
	Sflg2			= c33Matrix_product (pSG->R2, Sflg2);
	Sflg2			= c33Matrix_product (Gi, Sflg2);
	SflgT			= c33Matrix_sum     (Sflg1, Sflg2);
    /**************************************************/
    /* Calculate the scatterimg amplitudes in the FSA */
    /**************************************************/
    Eh				= c33Matrix_c3Vector_product (SflgT, pSG->chi);
    Ev				= c33Matrix_c3Vector_product (SflgT, pSG->cvi);
	Shh				= c3Vector_scalar_product (pSG->chs, Eh);
	Shv				= c3Vector_scalar_product (pSG->chs, Ev);
	Svh				= c3Vector_scalar_product (pSG->cvs, Eh);
	Svv				= c3Vector_scalar_product (pSG->cvs, Ev);
	/*****************************************/
    /* Incorporate stochastic scaling factor */
    /*****************************************/
	Shh				= complex_rmul (Shh, Sa_scaling);
	Shv				= complex_rmul (Shv, Sa_scaling);
	Svh				= complex_rmul (Svh, Sa_scaling);
	Svv				= complex_rmul (Svv, Sa_scaling);
	/************************************************/
	/* Convert the scattering amplitudes to the BSA */
	/************************************************/
	Shh				= complex_rmul (Shh, -1.0);
	Shv				= complex_rmul (Shv, -1.0);
	/**************************************/
	/* Monitor backscattering coefficient */
	/**************************************/
	pSG->Sigma0HH	+= Shh.r*Shh.r;
	pSG->Sigma0HV	+= Shv.r*Shv.r;
	pSG->Sigma0VH	+= Svh.r*Svh.r;
	pSG->Sigma0VV	+= Svv.r*Svv.r;
	Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r, Shh.phi-Svv.phi);
	pSG->AvgShhvv	= complex_add (pSG->AvgShhvv, zhhvv);
	/***************************************************/
	/* Combine contribution into SAR image accumulator */
	/***************************************************/
	weight_average	= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
   }
  }
 }
/*****************************/
/* Return to calling routine */
/*****************************/
 return		(weight_average);
}

double		Image_Cylinder_Bounce	(Cylinder *pC, SarGeometry *pSG, PolSARproSim_Record *pPR, double Sa_scaling, int flag)
{
 d3Vector			cyl_centre			= d3Vector_sum (pC->base, d3Vector_double_multiply (pC->axis, 0.5*pC->length));
#ifdef SWITCH_ATTENUATION_ON
 int				rtn_lookup;
 double				gHi, gVi, gHr, gVr, gHs, gVs;
#endif
 c33Matrix			Gi	= Idem_c33Matrix ();
 c33Matrix			Gr	= Idem_c33Matrix ();
 c33Matrix			Gs	= Idem_c33Matrix ();
 c3Vector			Eh, Ev;
 Complex			Shh, Shv, Svh, Svv;
 Complex			zhhvv;
 double				cyl_x, cyl_y, cyl_height;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 double				weight_average	= 0.0;
 Plane				Pg;
 d3Vector			g;
 d3Vector			nm	= d3Vector_double_multiply (pSG->n, -1.0);
 Ray				Rb;
 d3Vector			eff_bounce_centre;
 double				bounce_distance;
 d3Vector			specular_point;
 double				specular_distance;
 double				eff_grange, eff_srange;
 d3Vector			a;
 c33Matrix			Scyl1, Scyl2, ScylT;
 int				rtn_value;
 d3Vector			tip;
 d3Vector			hil,  vil,  hsl,  vsl;
 d3Vector			hrpl, vrpl, hrml, vrml;
 c3Vector			chil,  cvil,  chsl,  cvsl;
 c3Vector			chrpl, cvrpl, chrml, cvrml;
 Complex			fhhml, fhvml, fvhml, fvvml;
 Complex			fhhpl, fhvpl, fvhpl, fvvpl;
/************************/
/* Mark cylinder centre */
/************************/
 cyl_x				= cyl_centre.x[0];
 cyl_y				= cyl_centre.x[1];
 cyl_height			= cyl_centre.x[2];
/***************************************/
/* Equivalent upward pointing cylinder */
/***************************************/
 if (pC->axis.theta > DPI_RAD/2.0) {
  tip		= d3Vector_sum (pC->base, d3Vector_double_multiply (pC->axis, pC->length));
  pC->axis	= d3Vector_double_multiply (pC->axis, -1.0);
  Assign_Cylinder (pC, pC->length, pC->radius, pC->permittivity, pC->axis, tip);
 }
/*****************************************/
/* Calculate the reflection plane origin */
/*****************************************/
 g					= Cartesian_Assign_d3Vector (cyl_x, cyl_y, ground_height(pPR, cyl_x, cyl_y));
 if (cyl_height > g.x[2]) {
  Assign_Plane (&Pg, &g, pPR->slope_x, pPR->slope_y);
  Assign_Ray_d3V (&Rb, &cyl_centre, &nm);
  rtn_value			= RayPlaneIntersection (&Rb, &Pg, &eff_bounce_centre, &bounce_distance);
  if ((rtn_value == 1) && (bounce_distance >= 0.0)) {
   a					= d3Vector_normalise (pSG->krm);
   Assign_Ray_d3V (&Rb, &cyl_centre, &a);
   rtn_value			= RayPlaneIntersection (&Rb, &Pg, &specular_point, &specular_distance);
   if ((rtn_value == 1) && (specular_distance >= 0.0)) {
    /*********************************************/
    /* Calculate the ground-stem centre of focus */
    /*********************************************/
    eff_grange		= pSG->p_grange + eff_bounce_centre.x[1];
    eff_srange		= sqrt ((pSG->p_height-eff_bounce_centre.x[2])*(pSG->p_height-eff_bounce_centre.x[2]) + eff_grange*eff_grange);
    focus_grange	= sqrt (eff_srange*eff_srange - pSG->p_height*pSG->p_height);
    focus_x			= eff_bounce_centre.x[0];
    focus_y			= focus_grange - pSG->p_grange;
    focus_height	= 0.0;
    focus_srange	= sqrt ((pSG->p_height-focus_height)*(pSG->p_height-focus_height) + (pSG->p_grange+focus_y)*(pSG->p_grange+focus_y));
	/***********************************************************/
	/* Additional wave and cylinder local polarisation vectors */
	/***********************************************************/
	rtn_value		= Polarisation_Vectors (pSG->ki,  pC->axis, &hil,   &vil);
	rtn_value		= Polarisation_Vectors (pSG->ks,  pC->axis, &hsl,   &vsl);
	rtn_value		= Polarisation_Vectors (pSG->kr,  pC->axis, &hrpl,  &vrpl);
	rtn_value		= Polarisation_Vectors (pSG->krm, pC->axis, &hrml,  &vrml);
	chil			= d3V2c3V (hil);
	cvil			= d3V2c3V (vil);
	chsl			= d3V2c3V (hsl);
	cvsl			= d3V2c3V (vsl);
	chrpl			= d3V2c3V (hrpl);
	cvrpl			= d3V2c3V (vrpl);
	chrml			= d3V2c3V (hrml);
	cvrml			= d3V2c3V (vrml);
    /******************************************/
    /* Calculate the stem scattering matrices */
    /******************************************/
    if (flag == POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES) {
     Scyl2			= InfCylSav3	(pC, &(pSG->krm), &(pSG->ki), &(pSG->Ytable), &(pSG->Jtable), &fhhml, &fhvml, &fvhml, &fvvml);
     fhhpl			= Copy_Complex (&fhhml);
     fhvpl			= complex_rmul (fvhml, -1.0);
     fvhpl			= complex_rmul (fhvml, -1.0);
     fvvpl			= Copy_Complex (&fvvml);
     Scyl1			= c33Matrix_Complex_product (c3Vector_dyadic_product (chsl, chrpl), fhhpl);
     Scyl1			= c33Matrix_sum  (Scyl1, c33Matrix_Complex_product (c3Vector_dyadic_product (chsl, cvrpl), fhvpl));
     Scyl1			= c33Matrix_sum  (Scyl1, c33Matrix_Complex_product (c3Vector_dyadic_product (cvsl, chrpl), fvhpl));
     Scyl1			= c33Matrix_sum  (Scyl1, c33Matrix_Complex_product (c3Vector_dyadic_product (cvsl, cvrpl), fvvpl));
    } else {
     Scyl1			= GrgCylSa		(pC, &(pSG->ks),  &(pSG->kr));
     Scyl2			= GrgCylSa		(pC, &(pSG->krm), &(pSG->ki));
    }
    /**********************************/
    /* Calculate attenuation matrices */
    /**********************************/
#ifdef SWITCH_ATTENUATION_ON
	rtn_lookup		= Lookup_Direct_Attenuation (specular_point, pPR, &gHi, &gVi);
	rtn_lookup		= Lookup_Bounce_Attenuation (cyl_centre,     pPR, &gHr, &gVr);
	rtn_lookup		= Lookup_Direct_Attenuation (cyl_centre,     pPR, &gHs, &gVs);
	Gi				= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chi, pSG->chi), xy_complex (gHi, 0.0));
	Gi				= c33Matrix_sum (Gi, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvi, pSG->cvi), xy_complex (gVi, 0.0)));
	Gr				= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chr, pSG->chr), xy_complex (gHr, 0.0));
	Gr				= c33Matrix_sum (Gr, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvr, pSG->cvr), xy_complex (gVr, 0.0)));
	Gs				= c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->chs, pSG->chs), xy_complex (gHs, 0.0));
	Gs				= c33Matrix_sum (Gs, c33Matrix_Complex_product (c3Vector_dyadic_product (pSG->cvs, pSG->cvs), xy_complex (gVs, 0.0)));
#endif
    /*******************************************************************/
    /* Incorporate reflection and attenuation into scattering matrices */
    /*******************************************************************/
	Scyl1			= c33Matrix_product (Gs, Scyl1);
	Scyl1			= c33Matrix_product (Scyl1, Gr);
	Scyl1			= c33Matrix_product (Scyl1, pSG->R1);
	Scyl1			= c33Matrix_product (Scyl1, Gi);
	Scyl2			= c33Matrix_product (Scyl2, Gs);
	Scyl2			= c33Matrix_product (Gr, Scyl2);
	Scyl2			= c33Matrix_product (pSG->R2, Scyl2);
	Scyl2			= c33Matrix_product (Gi, Scyl2);
	ScylT			= c33Matrix_sum     (Scyl1, Scyl2);
    /**************************************************/
    /* Calculate the scatterimg amplitudes in the FSA */
    /**************************************************/
    Eh				= c33Matrix_c3Vector_product (ScylT, pSG->chi);
    Ev				= c33Matrix_c3Vector_product (ScylT, pSG->cvi);
	Shh				= c3Vector_scalar_product (pSG->chs, Eh);
	Shv				= c3Vector_scalar_product (pSG->chs, Ev);
	Svh				= c3Vector_scalar_product (pSG->cvs, Eh);
	Svv				= c3Vector_scalar_product (pSG->cvs, Ev);
	/*****************************************/
    /* Incorporate stochastic scaling factor */
    /*****************************************/
	Shh				= complex_rmul (Shh, Sa_scaling);
	Shv				= complex_rmul (Shv, Sa_scaling);
	Svh				= complex_rmul (Svh, Sa_scaling);
	Svv				= complex_rmul (Svv, Sa_scaling);
	/************************************************/
	/* Convert the scattering amplitudes to the BSA */
	/************************************************/
	Shh				= complex_rmul (Shh, -1.0);
	Shv				= complex_rmul (Shv, -1.0);
	/**************************************/
	/* Monitor backscattering coefficient */
	/**************************************/
	pSG->Sigma0HH	+= Shh.r*Shh.r;
	pSG->Sigma0HV	+= Shv.r*Shv.r;
	pSG->Sigma0VH	+= Svh.r*Svh.r;
	pSG->Sigma0VV	+= Svv.r*Svv.r;
	Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r, Shh.phi-Svv.phi);
	pSG->AvgShhvv	= complex_add (pSG->AvgShhvv, zhhvv);
	/***************************************************/
	/* Combine contribution into SAR image accumulator */
	/***************************************************/
	weight_average	= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
   }
  }
 }
/*****************************/
/* Return to calling routine */
/*****************************/
 return		(weight_average);
}

int		Image_Tree_Bounce		(Tree *pT, SarGeometry *pSG, PolSARproSim_Record *pPR)
{
 const double		bsecl	=	POLSARPROSIM_SAR_BRANCH_FACTOR*(pPR->azimuth_resolution + pPR->slant_range_resolution);
 long				iBranch;
 Branch				*pB;
 int				Nsections;
 int				i_section;
 double				deltat, deltar;
 Cylinder			cyl1;
 double				weight_sum;
 double				weight_count;
 double				weight_avg;
 int				rtn_value;
 int				Cscatt_Flag;
 double				tb_scaling;
 double				flg_scaling;
 long				iLeaf;
 Leaf				*pL;
#ifndef POLSARPROSIM_NO_SAR_TERTIARIES
 Branch				tertiary_branch;
 double				tertiary_branch_length, tertiary_branch_radius;
 long				n_Tertiary;
 double				tertiary_moisture;
 Complex			tertiary_permittivity;
#endif
#ifndef POLSARPROSIM_NO_SAR_FOLIAGE
 long				n_Leaves;
 int				L_species;
 double				leaf_d1, leaf_d2, leaf_d3;
 double				L_moisture;
 Complex			L_permittivity;
 Leaf				tree_leaf;
#endif

/************************/
/* Initialise variables */
/************************/
 Create_Cylinder (&cyl1);
#ifndef FORCE_GRG_CYLINDERS
  Cscatt_Flag	= POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES;
#else
  Cscatt_Flag	= POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES;
#endif
/*******************/
/* Image the stems */
/*******************/
#ifndef POLSARPROSIM_NO_SAR_STEMS
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pB			= pT->Stem.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Stem.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value		= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum		+= Image_Cylinder_Bounce (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
#endif
/**************************/
/* Image primary branches */
/**************************/
#ifndef POLSARPROSIM_NO_SAR_PRIMARIES
 if ((pPR->species == POLSARPROSIM_PINE001) || (pPR->species == POLSARPROSIM_PINE002) || (pPR->species == POLSARPROSIM_PINE003)){
  pB			= pT->Dry.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Dry.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value		= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum		+= Image_Cylinder_Bounce (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pB			= pT->Primary.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Primary.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value		= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum		+= Image_Cylinder_Bounce (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
#endif
/****************************/
/* Image secondary branches */
/****************************/
#ifndef POLSARPROSIM_NO_SAR_SECONDARIES
 if (pPR->species != POLSARPROSIM_HEDGE) {
  pB			= pT->Secondary.head;
  weight_sum	= 0.0;
  weight_count	= 0.0;
  for (iBranch=0L; iBranch < pT->Secondary.n; iBranch++) {
   Nsections	= (int) (pB->l/bsecl) + 1;
   deltat		= 1.0 / (double) Nsections;
   deltar		= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value		= Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum		+= Image_Cylinder_Bounce (&cyl1, pSG, pPR, 1.0, Cscatt_Flag);
    weight_count	+= 1.0;
   }
   pB			= pB->next;
  }
  weight_avg	= weight_sum/weight_count;
 }
#endif
/***************************/
/* Image tertiary branches */
/***************************/
#ifndef POLSARPROSIM_NO_SAR_TERTIARIES
#ifndef FORCE_GRG_CYLINDERS
if (pPR->Grg_Flag == 0) {
 Cscatt_Flag	=    POLSARPROSIM_SAR_GRG_TERTIARY_BRANCHES;
} else {
 Cscatt_Flag	=    POLSARPROSIM_SAR_INF_TERTIARY_BRANCHES;
}
#endif
 tb_scaling				= Estimate_SAR_Tertiaries (pT, pPR, &n_Tertiary, &tertiary_branch_length, &tertiary_branch_radius);
 weight_sum				= 0.0;
 weight_count			= 0.0;
 pB						= &tertiary_branch;
 Create_Branch (pB);
 tertiary_moisture		= Tertiary_Branch_Moisture (pT->species);
 tertiary_permittivity	= vegetation_permittivity (tertiary_moisture, pPR->frequency);
 for (iBranch=0L; iBranch < n_Tertiary; iBranch++) {
  if (pT->species != POLSARPROSIM_HEDGE) {
   tertiary_moisture		= Tertiary_Branch_Moisture (pT->species);
   tertiary_permittivity	= vegetation_permittivity (tertiary_moisture, pPR->frequency);
  }
  rtn_value				= Realise_Tertiary_Branch (pT, pPR, pB, tertiary_branch_length, tertiary_branch_radius, tertiary_moisture, tertiary_permittivity);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   Nsections			= (int) (pB->l/bsecl) + 1;
   deltat				= 1.0 / (double) Nsections;
   deltar				= (pB->start_radius - pB->end_radius) / (double) Nsections;
   for (i_section = 0; i_section < Nsections; i_section++) {
    rtn_value			 = Cylinder_from_Branch (&cyl1, pB, i_section, Nsections);
    weight_sum			+= Image_Cylinder_Bounce (&cyl1, pSG, pPR, tb_scaling, Cscatt_Flag);
    weight_count		+= 1.0;
   }
  }
 }
 weight_avg		= weight_sum/weight_count;
 Destroy_Branch (pB);
#endif
/*****************/
/* Image foliage */
/*****************/
#ifndef POLSARPROSIM_NO_SAR_FOLIAGE
 L_species		= Leaf_Species		(pT->species);
 leaf_d1		= Leaf_Dimension_1	(pT->species);
 leaf_d2		= Leaf_Dimension_2	(pT->species);
 leaf_d3		= Leaf_Dimension_3	(pT->species);
 L_moisture		= Leaf_Moisture		(pT->species);
 L_permittivity	= vegetation_permittivity (L_moisture, pPR->frequency);
 pL				= &tree_leaf;
 Create_Leaf (pL);
 flg_scaling	= Estimate_SAR_Foliage (pT, pPR, &n_Leaves);
 weight_sum		= 0.0;
 weight_count	= 0.0;
 for (iLeaf=0L; iLeaf < n_Leaves; iLeaf++) {
  if (pT->species != POLSARPROSIM_HEDGE) {
   L_moisture		= Leaf_Moisture	(pT->species);
   L_permittivity	= vegetation_permittivity (L_moisture, pPR->frequency);
  }
  rtn_value		= Realise_Foliage_Element (pT, pPR, pL, L_species, leaf_d1, leaf_d2, leaf_d3, L_moisture, L_permittivity);
  if (rtn_value == NO_RAYCROWN_ERRORS) {
   weight_sum	+= Image_Foliage_Bounce (pL, pSG, pPR, flg_scaling);
   weight_count	+= 1.0;
  }
 }
 Destroy_Leaf (pL);
#endif
/***************/
/* Tidy up ... */
/***************/
 Destroy_Cylinder (&cyl1);
/*****************************/
/* Return to calling routine */
/*****************************/
 return (NO_POLSARPROSIM_FOREST_ERRORS);
}

int		PolSARproSim_Forest_Bounce		(PolSARproSim_Record *pPR)
{
 Tree			tree1;
 int			itree;
 SarGeometry	SG1;
 int			rtn_value;
/**********************/
/* Imaging the forest */
/**********************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to PolSARproSim_Forest_Bounce ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to PolSARproSim_Forest_Bounce ...\n");
 fflush  (pPR->pLogFile);
/**********************************/
/* Set up the SAR geometry record */
/**********************************/
 rtn_value	= Initialise_SAR_Geometry (&SG1, pPR);
/********************************/
/* Seed random number generator */
/********************************/
 srand (pPR->seed);
/**************************/
/* Main tree imaging loop */
/**************************/
 Create_Tree (&tree1);
 for (itree=0; itree<pPR->Trees; itree++) {
  Realise_Tree		(&tree1, itree, pPR);
  Image_Tree_Bounce	(&tree1, &SG1, pPR);
 }
 Destroy_Tree (&tree1);
/***********************/
/* Monitor performance */
/***********************/
 SG1.Sigma0_count	 = pPR->Lx*pPR->Ly;
 SG1.Sigma0HH		/= SG1.Sigma0_count;
 SG1.Sigma0HV		/= SG1.Sigma0_count;
 SG1.Sigma0VH		/= SG1.Sigma0_count;
 SG1.Sigma0VV		/= SG1.Sigma0_count;
 SG1.AvgShhvv		= complex_rmul (SG1.AvgShhvv, 1.0/SG1.Sigma0_count);
 fprintf (pPR->pLogFile, "Bounce Forest HH backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0HH));
 fprintf (pPR->pLogFile, "Bounce Forest HV backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0HV));
 fprintf (pPR->pLogFile, "Bounce Forest VH backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0VH));
 fprintf (pPR->pLogFile, "Bounce Forest VV backscattering coefficient\t= %lf dB\n", 10.0*log10(SG1.Sigma0VV));
 fprintf (pPR->pLogFile, "Bounce Forest HHVV correlation magnitude   \t= %lf dB\n", 10.0*log10(SG1.AvgShhvv.r));
 fprintf (pPR->pLogFile, "Bounce Forest HHVV correlation phase       \t= %lf rads.\n", SG1.AvgShhvv.phi);
 fflush  (pPR->pLogFile);
/***********/
/* Tidy up */
/***********/
 Delete_SAR_Geometry (&SG1);
/**********************************************/
/* Report progress if running in VERBOSE mode */
/**********************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to PolSARproSim_Forest_Bounce\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to PolSARproSim_Forest_Bounce\n\n");
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
/*****************************/
/* Return to calling routine */
/*****************************/
 return (NO_POLSARPROSIM_FOREST_ERRORS);
}
