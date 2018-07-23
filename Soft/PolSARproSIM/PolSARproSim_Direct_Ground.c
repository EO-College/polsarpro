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
 * Module      : PolSARproSim_Direct_Ground.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Direct ground interferometric SAR image calculation for PolSARproSim
 */
#include	"PolSARproSim_Direct_Ground.h"

/**********************************************************************/
/* Direct ground interferometric SAR image calculation implementation */
/**********************************************************************/

int		PolSARproSim_Direct_Ground		(PolSARproSim_Record *pPR)
{
 const double		Pi					= 4.0*atan(1.0);
 const double		TwoPi				= 8.0*atan(1.0);
 const double		beta1				= POLSARPROSIM_DIRECTGROUND_DELTAB_FACTOR*Pi/100.0;
 const double		thetai				= pPR->incidence_angle[pPR->current_track];
 const double		cos_thetai			= cos(thetai);
 const double		sin_thetai			= sin(thetai);
 const double		Lx					= pPR->Lx;
 const double		Ly					= pPR->Ly;
 const int			nx					= POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR*pPR->nx;
 const int			ny					= POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR*pPR->ny;
 const double		sx					= pPR->slope_x;
 const double		sy					= pPR->slope_y;
 const double		deltax				= Lx/(double)nx;
 const double		deltay				= Ly/(double)ny;
 const double		Sincb1				= Sinc (beta1);
 const double		Sinc2b1				= Sinc (2.0*beta1);
 const double		avg_cos2b_0			= 0.5*(1.0+Sinc2b1);
 const double		avg_sin2b_0			= 0.5*(1.0-Sinc2b1);
 const double		avg_cos2bsin2b_0	= 0.25*(0.5*(1.0+Sinc2b1) - cos(beta1)*cos(beta1)*cos(beta1)*Sincb1);
 const double		avg_cos4b_0			= avg_cos2b_0 - avg_cos2bsin2b_0;
 const double		avg_sin4b_0			= avg_sin2b_0 - avg_cos2bsin2b_0;

 double				x,y;
 d3Vector			vertex[5];
 Facet				ground_facet[4];
 int				ix, iy;
 Facet_List			AzimuthList;
 long				n_facets, i_facet;
 double				modf, argf, beta_xbragg;
 Facet				f1;
 d3Vector			antenna;
 double				ndotp;
 double				SigHH, SigVV, fArea;
 double				RootSigHH, RootSigVV;
 Complex			Shhl, Svvl;
 double				cosb, sinb, cosb2, sinb2;
 d3Vector			k, h, v;
 Complex			Shh, Svv, Shv, Svh;
 double				p_srange	= pPR->slant_range[pPR->current_track];
 double				p_thetai	= pPR->incidence_angle[pPR->current_track];
 double				p_height	= p_srange*cos(p_thetai);
 double				p_grange	= p_srange*sin(p_thetai);
 double				facet_x, facet_y, facet_grange, facet_srange, facet_height;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 double				weight_average	= 0.0;
 double				weight_count	= 0.0;
 double				Sigma0HH		= 0.0;
 double				Sigma0HV		= 0.0;
 double				Sigma0VH		= 0.0;
 double				Sigma0VV		= 0.0;
 Complex			AvgShhvv, zhhvv;
 double				Sigma0_count	= 0.0;
 int				dgsf			= POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR;
 double				dgdbf			= POLSARPROSIM_DIRECTGROUND_DELTAB_FACTOR;
 double				thetail, cos_thetail, sin_thetail, beta_facet, argbf;
 d3Vector			surface_normal;
 double				argbs, beta0;
 double				Thavg_cos2b			= 0.0;
 double				Thavg_sin2b			= 0.0;
 double				Thavg_cos2bsin2b	= 0.0;
 double				Thavg_cos4b			= 0.0;
 double				Thavg_sin4b			= 0.0;
 double				Th1, Th2;
 double				Thavg_sigHH, Thavg_sigHV, Thavg_sigVV, Thavg_Shhvv;
 double				mnsqrpxlHH, mnsqrpxlHV, mnsqrpxlVV;
 int				ipix, jpix;
 sim_pixel			spix;
#ifdef SWITCH_ATTENUATION_ON
 int				rtn_lookup;
 double				gH, gV;
#endif

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to PolSARproSim_Direct_Ground ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to PolSARproSim_Direct_Ground ... \n");
 fprintf (pPR->pLogFile, "POLSARPROSIM_DIRECTGROUND_SPECKLE_FACTOR\t\t%d\n", dgsf);
 fprintf (pPR->pLogFile, "POLSARPROSIM_DIRECTGROUND_DELTAB_FACTOR\t\t%lf\n", dgdbf);
 fprintf (pPR->pLogFile, "Small scale height standard deviation\t\t%lf m.\n", pPR->small_scale_height_stdev);
 fprintf (pPR->pLogFile, "Small scale correlation length\t\t\t%lf m.\n", pPR->small_scale_length);
#ifdef FLAT_DEM
 fprintf (pPR->pLogFile, "FLAT_DEM requested at compile time.\n");
#else
 fprintf (pPR->pLogFile, "Large scale height standard deviation\t\t%lf m.\n", pPR->large_scale_height_stdev);
 fprintf (pPR->pLogFile, "Large scale correlation length\t\t\t%lf m.\n", pPR->large_scale_length);
#endif
 fprintf (pPR->pLogFile, "Azimth slope\t\t\t\t\t\t%lf\n", pPR->slope_x);
 fprintf (pPR->pLogFile, "Range  slope\t\t\t\t\t\t%lf\n", pPR->slope_y);
 fprintf (pPR->pLogFile, "XBragg beta1 value\t\t\t\t\t%lf rads.\n", beta1);
 fprintf (pPR->pLogFile, "Ground dielectric value\t\t\t\t\t%lf \t%lf\n", pPR->ground_eps.x, pPR->ground_eps.y);
 fflush  (pPR->pLogFile);
/******************/
/* Initialisation */
/******************/
 Facet_init_list (&AzimuthList);
/**************************************************/
/* Use the far-field model for the look direction */
/**************************************************/
 antenna	= Cartesian_Assign_d3Vector (0.0, -sin_thetai,  cos_thetai);
/********************************/
/* BSA for polarisation vectors */
/********************************/
 k			= Cartesian_Assign_d3Vector (0.0,  sin_thetai, -cos_thetai);
 h			= Cartesian_Assign_d3Vector (-1.0,  0.0, 0.0);
 v			= Cartesian_Assign_d3Vector (0.0, -cos_thetai, -sin_thetai);
/************************************************************************/
/* Anticipated, unattenuated direct-surface backscattering coefficients */
/************************************************************************/
 surface_normal	= Cartesian_Assign_d3Vector (-pPR->slope_x, -pPR->slope_y, 1.0);
 d3Vector_insitu_normalise (&surface_normal);
 ndotp			= d3Vector_scalar_product (surface_normal, antenna);
 thetail		= acos (ndotp);
 cos_thetail	= ndotp;
 sin_thetail	= sqrt(1.0-ndotp*ndotp);
 SigHH			= monostatic_soil_sigma0HH (thetail, pPR->ground_eps, pPR->k0, pPR->small_scale_height_stdev, pPR->small_scale_length);
 SigVV			= monostatic_soil_sigma0VV (thetail, pPR->ground_eps, pPR->k0, pPR->small_scale_height_stdev, pPR->small_scale_length);
 fprintf (pPR->pLogFile, "\nLocal Sigma0HH\t= %lf dB\n", 10.0*log10(SigHH));
 fprintf (pPR->pLogFile, "Local Sigma0VV\t= %lf dB\n", 10.0*log10(SigVV));
 fflush  (pPR->pLogFile);
 RootSigHH		= sqrt (SigHH);
 RootSigVV		= sqrt (SigVV);
 Polar_Assign_Complex (&Shhl, RootSigHH, 0.0);
 Polar_Assign_Complex (&Svvl, RootSigVV, 0.0);
 argbs			= sin_thetai - sy*cos_thetai;
 if (fabs(argbs) > FLT_EPSILON) {
  beta0	= atan (sx/argbs);
 } else {
  beta0	= Pi/2.0;
 }
 Thavg_cos2b		 = avg_cos2b_0*cos(beta0)*cos(beta0) - avg_sin2b_0*sin(beta0)*sin(beta0);
 Thavg_sin2b		 = avg_sin2b_0*cos(beta0)*cos(beta0) + avg_cos2b_0*sin(beta0)*sin(beta0);
 Th1				 = cos(beta0)*cos(beta0)*cos(beta0)*cos(beta0);
 Th1				+= sin(beta0)*sin(beta0)*sin(beta0)*sin(beta0);
 Th1				-= 4.0*cos(beta0)*cos(beta0)*sin(beta0)*sin(beta0);
 Th2				 = cos(beta0)*cos(beta0)*sin(beta0)*sin(beta0);
 Thavg_cos2bsin2b	 = avg_cos2bsin2b_0*Th1 + (avg_cos4b_0+avg_sin4b_0)*Th2;
 Thavg_cos4b		 = Thavg_cos2b - Thavg_cos2bsin2b;
 Thavg_sin4b		 = Thavg_sin2b - Thavg_cos2bsin2b;
 Thavg_sigHH		 = SigHH*Thavg_cos4b + SigVV*Thavg_sin4b + 2.0*sqrt(SigHH*SigVV)*Thavg_cos2bsin2b;
 Thavg_sigHV		 = (SigHH+SigVV-2.0*sqrt(SigHH*SigVV))*Thavg_cos2bsin2b;
 Thavg_sigVV		 = SigHH*Thavg_sin4b + SigVV*Thavg_cos4b + 2.0*sqrt(SigHH*SigVV)*Thavg_cos2bsin2b;
 Thavg_Shhvv		 = (SigHH+SigVV)*Thavg_cos2bsin2b + sqrt(SigHH*SigVV)*(Thavg_cos4b + Thavg_sin4b);
 fprintf (pPR->pLogFile, "\nTheoretical GLOBAL backscattering coefficients ... \n");
 fprintf (pPR->pLogFile, "\n<ShhShh*>\t= %lf dB\n", 10.0*log10(Thavg_sigHH));
 fprintf (pPR->pLogFile, "<ShvShv*>\t= %lf dB\n", 10.0*log10(Thavg_sigHV));
 fprintf (pPR->pLogFile, "<SvvSvv*>\t= %lf dB\n", 10.0*log10(Thavg_sigVV));
 fprintf (pPR->pLogFile, "<ShhSvv*>\t= %lf dB\n\n", 10.0*log10(Thavg_Shhvv));
 fflush  (pPR->pLogFile);
/********************************/
/* Prime random number sequence */
/********************************/
 srand	(pPR->seed);
/*********************/
/* Zero accumulators */
/*********************/
 Sigma0HH		= 0.0;
 Sigma0HV		= 0.0;
 Sigma0VH		= 0.0;
 Sigma0VV		= 0.0;
 Polar_Assign_Complex (&AvgShhvv, 0.0, 0.0);
 Sigma0_count	= 0.0;
/********************/
/* Loop over facets */
/********************/
 for (ix=0; ix<nx; ix++) {
  x	= ix*deltax - Lx/2.0;
  /********************************************/
  /* Build a facet list for this azimuth line */
  /********************************************/
  for (iy=0; iy<ny; iy++) {
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
   /*************************************/
   /* Turn ground grid into four facets */
   /*************************************/
   Assign_Facet	(&(ground_facet[0]), &(vertex[4]), &(vertex[1]), &(vertex[0]));
   Assign_Facet	(&(ground_facet[1]), &(vertex[4]), &(vertex[2]), &(vertex[1]));
   Assign_Facet	(&(ground_facet[2]), &(vertex[4]), &(vertex[3]), &(vertex[2]));
   Assign_Facet	(&(ground_facet[3]), &(vertex[4]), &(vertex[0]), &(vertex[3]));
   /****************************************************/
   /* Add facets to facet list : tail is at near range */
   /****************************************************/
   Facet_tail_add (&AzimuthList, &(ground_facet[2]));
   Facet_tail_add (&AzimuthList, &(ground_facet[3]));
   Facet_tail_add (&AzimuthList, &(ground_facet[1]));
   Facet_tail_add (&AzimuthList, &(ground_facet[0]));
  }
  /*************************************************/
  /* For each facet in the azimuth line facet list */
  /*************************************************/
  n_facets	= Facet_List_length (&AzimuthList);
  for (i_facet = 0L; i_facet < n_facets; i_facet++) {
   /****************************************************/
   /* Sample random factors for scattering calculation */
   /****************************************************/
   modf			= sqrt (erand (1.0));
   argf			= TwoPi*(drand ()-0.5);
   beta_xbragg	= 2.0*(drand()-0.5)*beta1;
   /*****************************/
   /* Take facet from list head */
   /*****************************/
   Facet_head_sub (&AzimuthList, &f1);
   /******************************/
   /* Determine facet visibility */
   /******************************/
   ndotp	= d3Vector_scalar_product (f1.n, antenna);
   /*******************************************************************************************/
   /* NOTE : In the current implementation visibility depends only upon local incidence angle */
   /*******************************************************************************************/
   /*******************************/
   /* If the facet is visible ... */
   /*******************************/
   if (ndotp > 0.0) {
    thetail		= acos (ndotp);
	cos_thetail	= ndotp;
	sin_thetail	= sqrt(1.0-ndotp*ndotp);
	argbf		= f1.n.x[1]*cos_thetai + f1.n.x[2]*sin_thetai;
	if (fabs(argbf) > FLT_EPSILON) {
	 beta_facet	= atan (-f1.n.x[0]/argbf);
	} else {
	 beta_facet	= Pi/2.0;
	}
	/********************************************/
    /* calculate the facet scattering amplitude */
	/********************************************/
	SigHH			= monostatic_soil_sigma0HH (thetail, pPR->ground_eps, pPR->k0, pPR->small_scale_height_stdev, pPR->small_scale_length);
	SigVV			= monostatic_soil_sigma0VV (thetail, pPR->ground_eps, pPR->k0, pPR->small_scale_height_stdev, pPR->small_scale_length);
	fArea			= facet_area (&f1);
	RootSigHH		= sqrt (fArea*SigHH);
	RootSigVV		= sqrt (fArea*SigVV);
    Polar_Assign_Complex (&Shhl, modf*RootSigHH, argf);
    Polar_Assign_Complex (&Svvl, modf*RootSigVV, argf);
	/****************************************************/
	/* In the new algorithm the random X-Bragg angle is */
	/* added to the facet angle for a single rotation.  */
    /****************************************************/
    cosb			= cos(beta_xbragg + beta_facet);
    sinb			= sin(beta_xbragg + beta_facet);
    cosb2			= cosb*cosb;
    sinb2			= sinb*sinb;
    Shh				= complex_add	(complex_rmul (Shhl, cosb2), complex_rmul (Svvl, sinb2));
    Svv				= complex_add	(complex_rmul (Svvl, cosb2), complex_rmul (Shhl, sinb2));
    Shv				= complex_rmul	(complex_sub  (Shhl, Svvl),  cosb*sinb);
	Svh				= Shv;
#ifdef SWITCH_ATTENUATION_ON
	/***********************************/
	/* Incorporate attenuation effects */
	/***********************************/
	rtn_lookup		= Lookup_Direct_Attenuation (f1.r[3], pPR, &gH, &gV);
	Shh				= complex_rmul (Shh, gH*gH);
	Shv				= complex_rmul (Shv, gH*gV);
	Svh				= complex_rmul (Svh, gV*gH);
	Svv				= complex_rmul (Svv, gV*gV);
#endif
	/**************************************/
	/* Monitor backscattering coefficient */
	/**************************************/
	Sigma0HH		+= Shh.r*Shh.r/fArea;
	Sigma0HV		+= Shv.r*Shv.r/fArea;
	Sigma0VH		+= Svh.r*Svh.r/fArea;
	Sigma0VV		+= Svv.r*Svv.r/fArea;
	Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r/fArea, Shh.phi-Svv.phi);
	AvgShhvv		= complex_add (AvgShhvv, zhhvv);
	Sigma0_count	+= 1.0;
	/***************************************/
	/* Calculate the facet centre of focus */
	/***************************************/
	facet_x			= f1.r[3].x[0];
	facet_y			= f1.r[3].x[1];
	facet_height	= f1.r[3].x[2];
    facet_grange	= p_grange + facet_y;
	facet_srange	= sqrt ((p_height-facet_height)*(p_height-facet_height) + facet_grange*facet_grange);
	focus_grange	= sqrt (facet_srange*facet_srange - p_height*p_height);
	focus_x			= facet_x;
	focus_y			= focus_grange - p_grange;
	focus_height	= 0.0;
	focus_srange	= sqrt ((p_height-focus_height)*(p_height-focus_height) + (p_grange+focus_y)*(p_grange+focus_y));
	/***************************************************/
	/* Combine contribution into SAR image accumulator */
	/***************************************************/
	weight_average	+= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
	weight_count	+= 1.0;
	/********************/
    /* end (if visible) */
	/********************/
   }
  }
 }
/***********************/
/* Monitor performance */
/***********************/
 weight_average	/= weight_count;
 Sigma0HH		/= Sigma0_count;
 Sigma0HV		/= Sigma0_count;
 Sigma0VH		/= Sigma0_count;
 Sigma0VV		/= Sigma0_count;
 AvgShhvv		= complex_rmul (AvgShhvv, 1.0/Sigma0_count);
 fprintf (pPR->pLogFile, "Average PSF weight sum\t\t\t= %lf\n\n", weight_average);
 fprintf (pPR->pLogFile, "Direct Ground HH backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0HH));
 fprintf (pPR->pLogFile, "Direct Ground HV backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0HV));
 fprintf (pPR->pLogFile, "Direct Ground VH backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0VH));
 fprintf (pPR->pLogFile, "Direct Ground VV backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0VV));
 fprintf (pPR->pLogFile, "Direct Ground HHVV correlation magnitude   \t= %lf dB\n", 10.0*log10(AvgShhvv.r));
 fprintf (pPR->pLogFile, "Direct Ground HHVV correlation phase       \t= %lf rads.\n", AvgShhvv.phi);
 fflush  (pPR->pLogFile);
/*****************************************/
/* Calculate image normalisation factors */
/*****************************************/
 mnsqrpxlHH	= 0.0;
 mnsqrpxlHV	= 0.0;
 mnsqrpxlVV	= 0.0;
 for (ipix = 0; ipix < pPR->HHimage.nx; ipix++) {
  for (jpix = 0; jpix < pPR->HHimage.ny; jpix++) {
   spix	= getSIMpixel (&(pPR->HHimage), ipix, jpix);
   mnsqrpxlHH	+= spix.data.cf.x*spix.data.cf.x + spix.data.cf.y*spix.data.cf.y;
   spix	= getSIMpixel (&(pPR->HVimage), ipix, jpix);
   mnsqrpxlHV	+= spix.data.cf.x*spix.data.cf.x + spix.data.cf.y*spix.data.cf.y;
   spix	= getSIMpixel (&(pPR->VVimage), ipix, jpix);
   mnsqrpxlVV	+= spix.data.cf.x*spix.data.cf.x + spix.data.cf.y*spix.data.cf.y;
  }
 }
 mnsqrpxlHH	/= (double) pPR->HHimage.np;
 mnsqrpxlHV	/= (double) pPR->HHimage.np;
 mnsqrpxlVV	/= (double) pPR->HHimage.np;
 pPR->HHsf	= sqrt(Sigma0HH/mnsqrpxlHH);
 pPR->HVsf	= sqrt(Sigma0HV/mnsqrpxlHV);
 pPR->VVsf	= sqrt(Sigma0VV/mnsqrpxlVV);
 fprintf (pPR->pLogFile, "\nImage power scale factors ... \n\n");
 fprintf (pPR->pLogFile, "HH power scale factor\t= %lf\n", pPR->HHsf*pPR->HHsf);
 fprintf (pPR->pLogFile, "HV power scale factor\t= %lf\n", pPR->HVsf*pPR->HVsf);
 fprintf (pPR->pLogFile, "VV power scale factor\t= %lf\n", pPR->VVsf*pPR->VVsf);
 fflush  (pPR->pLogFile);
/*******************************************/
/* Set PSF amplitude scaling on first call */
/*******************************************/
 if (pPR->current_track == 0) {
  pPR->PSFamp	= sqrt (0.5*(pPR->HHsf*pPR->HHsf + pPR->VVsf*pPR->VVsf));
  fprintf (pPR->pLogFile, "\nPSF scaling reset to %lf\n\n", pPR->PSFamp);
  fprintf (pPR->pLogFile, "Rescaling direct surface imagery ... \n");
  Rescale_SIM_Record (&(pPR->HHimage), pPR->PSFamp);
  Rescale_SIM_Record (&(pPR->HVimage), pPR->PSFamp);
  Rescale_SIM_Record (&(pPR->VVimage), pPR->PSFamp);
  fprintf (pPR->pLogFile, "Finished rescaling direct surface imagery ... \n");
  fprintf (pPR->pLogFile, "Checking rescaling of direct surface imagery ... \n");
  mnsqrpxlHH	= 0.0;
  mnsqrpxlHV	= 0.0;
  mnsqrpxlVV	= 0.0;
  for (ipix = 0; ipix < pPR->HHimage.nx; ipix++) {
   for (jpix = 0; jpix < pPR->HHimage.ny; jpix++) {
    spix	= getSIMpixel (&(pPR->HHimage), ipix, jpix);
    mnsqrpxlHH	+= spix.data.cf.x*spix.data.cf.x + spix.data.cf.y*spix.data.cf.y;
    spix	= getSIMpixel (&(pPR->HVimage), ipix, jpix);
    mnsqrpxlHV	+= spix.data.cf.x*spix.data.cf.x + spix.data.cf.y*spix.data.cf.y;
    spix	= getSIMpixel (&(pPR->VVimage), ipix, jpix);
    mnsqrpxlVV	+= spix.data.cf.x*spix.data.cf.x + spix.data.cf.y*spix.data.cf.y;
   }
  }
  mnsqrpxlHH	/= (double) pPR->HHimage.np;
  mnsqrpxlHV	/= (double) pPR->HHimage.np;
  mnsqrpxlVV	/= (double) pPR->HHimage.np;
  pPR->HHsf	= sqrt(Sigma0HH/mnsqrpxlHH);
  pPR->HVsf	= sqrt(Sigma0HV/mnsqrpxlHV);
  pPR->VVsf	= sqrt(Sigma0VV/mnsqrpxlVV);
  fprintf (pPR->pLogFile, "\nImage power scale factors after rescaling ... \n\n");
  fprintf (pPR->pLogFile, "HH power scale factor\t= %lf\n", pPR->HHsf*pPR->HHsf);
  fprintf (pPR->pLogFile, "HV power scale factor\t= %lf\n", pPR->HVsf*pPR->HVsf);
  fprintf (pPR->pLogFile, "VV power scale factor\t= %lf\n", pPR->VVsf*pPR->VVsf);
  fflush  (pPR->pLogFile);
 }
/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to PolSARproSim_Direct_Ground\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to PolSARproSim_Direct_Ground\n\n");
 fflush  (pPR->pLogFile);
/***********/
/* Tidy up */
/***********/
 Facet_empty_list (&AzimuthList);
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
/********************/
/* Return to caller */
/********************/
 return (NO_POLSARPROSIM_DIRECTGROUND_ERRORS);
}
