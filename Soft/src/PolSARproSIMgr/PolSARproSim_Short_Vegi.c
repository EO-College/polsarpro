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
 * Module      : PolSARproSim_Short_Vegi.c
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Short vegetation interferometric SAR image calculation for PolSARproSim
 */
#include	"PolSARproSim_Short_Vegi.h"

/**************************************************************************/
/* Direct short vegi interferometric SAR image calculation implementation */
/**************************************************************************/

int		PolSARproSim_Short_Vegetation_Direct		(PolSARproSim_Record *pPR)
{
 const double		Pi					= 4.0*atan(1.0);
 const double		thetai				= pPR->incidence_angle[pPR->current_track];
 const double		cos_thetai			= cos(thetai);
 const double		sin_thetai			= sin(thetai);
 const double		Lx					= pPR->Lx;
 const double		Ly					= pPR->Ly;
 const double		deltax				= pPR->deltax;
 const double		deltay				= pPR->deltay;
 const int			nx					= pPR->nx;
 const int			ny					= pPR->ny;
 const double		dsv					= pPR->shrt_vegi_depth;
 const double		vc					= dsv*deltax*deltay;
 int				nr					= (int) (POLSARPROSIM_SHORT_VEGI_REALISATIONS*DEFAULT_RESOLUTION_SAMPLING_FACTOR*DEFAULT_RESOLUTION_SAMPLING_FACTOR);

 int				stem_species;
 double				stem_d1, stem_d2, stem_d3;
 double				stem_volume;
 double				stem_moisture;
 Complex			stem_permittivity;
 double				stemL1, stemL2, stemL3;
 d3Vector			stem_centre;
 Leaf				leaf_stem;
 int				nc_stem, nc_leaf;
 int				leaf_species;
 double				leaf_d1, leaf_d2, leaf_d3;
 double				leaf_volume;
 double				leaf_moisture;
 Complex			leaf_permittivity;
 double				leafL1, leafL2, leafL3;
 d3Vector			leaf_centre;
 Leaf				leaf_leaf;
 int				i, j, k;
 double				xp, yp, zp;
 double				Sa_scaling;
 double				theta, phi;
 double				stem_x, stem_y, stem_grange, stem_srange, stem_height;
 double				leaf_x, leaf_y, leaf_grange, leaf_srange, leaf_height;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 c33Matrix			S_stem, S_leaf;
 d3Vector			ki, ks;
 c3Vector			ch, cv;
 c3Vector			Eh, Ev;
 Complex			Shh, Shv, Svh, Svv;
#ifdef SWITCH_ATTENUATION_ON
 double				gH, gV;
 int				rtn_lookup;
#endif
 double				p_srange		= pPR->slant_range[pPR->current_track];
 double				p_thetai		= pPR->incidence_angle[pPR->current_track];
 double				p_height		= p_srange*cos(p_thetai);
 double				p_grange		= p_srange*sin(p_thetai);
 double				weight_average	= 0.0;
 double				weight_count	= 0.0;
 double				Sigma0HH		= 0.0;
 double				Sigma0HV		= 0.0;
 double				Sigma0VH		= 0.0;
 double				Sigma0VV		= 0.0;
 Complex			AvgShhvv, zhhvv;
 double				Sigma0_count	= 0.0;
 Complex			epsm1, epsp1, P11, P33, P33mP11, P11xP33mP11;
 double				mean_Rayleigh_stem_rcs, Rayleigh_stem_sigma0;

/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to PolSARproSim_Short_Vegetation_Direct ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "Call to PolSARproSim_Short_Vegetation_Direct ... \n");
 fflush  (pPR->pLogFile);
/********************/
/* FSA wave vectors */
/********************/
 ki			= Cartesian_Assign_d3Vector (0.0,  pPR->k0*sin_thetai, -pPR->k0*cos_thetai);
 ks			= Cartesian_Assign_d3Vector (0.0,  -pPR->k0*sin_thetai, pPR->k0*cos_thetai);
/********************************/
/* BSA for polarisation vectors */
/********************************/
 ch			= Assign_c3Vector (xy_complex(-1.0, 0.0), xy_complex(0.0, 0.0), xy_complex(0.0, 0.0));
 cv			= Assign_c3Vector (xy_complex(0.0, 0.0), xy_complex(-cos_thetai, 0.0), xy_complex(-sin_thetai, 0.0));
/*********************************/
/* Reset random number generator */
/*********************************/
 srand (pPR->seed);
/*************************/
/* Assign stem variables */
/*************************/
 stem_species		= POLSARPROSIM_PINE_NEEDLE;
 stem_d1			= POLSARPROSIM_SHORTV_STEM_LENGTH;
 stem_d2			= POLSARPROSIM_SHORTV_STEM_RADIUS;
 stem_d3			= POLSARPROSIM_SHORTV_STEM_RADIUS;
 stem_moisture		= Leaf_Moisture	(pPR->species);
 stem_permittivity	= vegetation_permittivity (stem_moisture, pPR->frequency);
 stemL1				= pPR->ShortVegi_stemL1;
 stemL2				= pPR->ShortVegi_stemL2;
 stemL3				= pPR->ShortVegi_stemL3;
 stem_centre		= Zero_d3Vector ();
 theta				= 0.0;
 phi				= 0.0;
 Assign_Leaf		(&leaf_stem, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, 
					stem_moisture, stem_permittivity, stem_centre);
 stem_volume		= Leaf_Volume (&leaf_stem);
/**************************/
/* Estimate mean stem RCS */
/**************************/
 epsm1						= xy_complex (stem_permittivity.x-1.0, stem_permittivity.y);
 epsp1						= xy_complex (stem_permittivity.x+1.0, stem_permittivity.y);
 P11						= complex_rmul (complex_div (epsm1, epsp1), 2.0*stem_volume);
 P33						= complex_rmul (epsm1, stem_volume);
 P33mP11					= complex_sub (P33, P11);
 P11xP33mP11				= complex_mul (P11, P33mP11);
 mean_Rayleigh_stem_rcs		= P11.r*P11.r + P33mP11.r*P33mP11.r/5.0 + 2.0*P11xP33mP11.x/3.0;
 mean_Rayleigh_stem_rcs		*= (pPR->k0*pPR->k0*pPR->k0*pPR->k0)/(4.0*Pi);
 Rayleigh_stem_sigma0		= mean_Rayleigh_stem_rcs*dsv*pPR->shrt_vegi_stem_vol_frac/stem_volume;
 fprintf (pPR->pLogFile, "Unattenuated Rayleigh stem co-polar backscattering coefficient\t= %lf dB\n", 10.0*log10(Rayleigh_stem_sigma0));
 mean_Rayleigh_stem_rcs		= P33mP11.r*P33mP11.r/15.0;
 mean_Rayleigh_stem_rcs		*= (pPR->k0*pPR->k0*pPR->k0*pPR->k0)/(4.0*Pi);
 Rayleigh_stem_sigma0		= mean_Rayleigh_stem_rcs*dsv*pPR->shrt_vegi_stem_vol_frac/stem_volume;
 fprintf (pPR->pLogFile, "Unattenuated Rayleigh stem  x-polar backscattering coefficient\t= %lf dB\n\n", 10.0*log10(Rayleigh_stem_sigma0));
 fflush  (pPR->pLogFile);
/*************************/
/* Assign leaf variables */
/*************************/
 leaf_species		= POLSARPROSIM_DECIDUOUS_LEAF;
 leaf_d1			= POLSARPROSIM_SHORTV_LEAF_LENGTH;
 leaf_d2			= POLSARPROSIM_SHORTV_LEAF_WIDTH;
 leaf_d3			= POLSARPROSIM_SHORTV_LEAF_THICKNESS;
 leaf_moisture		= Leaf_Moisture	(pPR->species);
 leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
 leafL1				= pPR->ShortVegi_leafL1;
 leafL2				= pPR->ShortVegi_leafL2;
 leafL3				= pPR->ShortVegi_leafL3;
 leaf_centre		= Zero_d3Vector ();
 theta				= 0.0;
 phi				= 0.0;
 Assign_Leaf		(&leaf_leaf, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, 
					leaf_moisture, leaf_permittivity, leaf_centre);
 leaf_volume		= Leaf_Volume (&leaf_leaf);
/*********************/
/* Zero accumulators */
/*********************/
 Sigma0HH			= 0.0;
 Sigma0HV			= 0.0;
 Sigma0VH			= 0.0;
 Sigma0VV			= 0.0;
 Polar_Assign_Complex (&AvgShhvv, 0.0, 0.0);
 Sigma0_count		= 0.0;
 weight_average		= 0.0;
 weight_count		= 0.0;
#ifndef NO_SHORT_STEMS
/****************************************/
/* Stem direct backscatter contribution */
/****************************************/
 nc_stem			= (int) (vc*pPR->shrt_vegi_stem_vol_frac/stem_volume) + 1;
 nr					= (int) (POLSARPROSIM_SHORT_VEGI_REALISATIONS*DEFAULT_RESOLUTION_SAMPLING_FACTOR*DEFAULT_RESOLUTION_SAMPLING_FACTOR);
 if (nr > nc_stem) {
  nr	= nc_stem;
 }
 Sa_scaling			= sqrt ((double)nc_stem/(double)nr);
/*************************/
/* Loop over pixel cells */
/*************************/
 for (i = 0; i < nx; i++) {
  xp	= i*deltax + (deltax - Lx)/2.0;
  for (j = 0; j < ny; j++) {
   yp	= (Ly - deltay)/2.0 - j*deltay;
   zp	= ground_height (pPR, xp, yp);
   for (k = 0; k < nr; k++) {
    /******************/
    /* Realise a stem */
    /******************/
    stem_x				= xp + (drand() - 0.5)*deltax;
	stem_y				= yp + (drand() - 0.5)*deltay;
	stem_height			= zp + drand() * dsv;
    stem_centre			= Cartesian_Assign_d3Vector (stem_x, stem_y, stem_height);
    theta				= vegi_polar_angle ();
    phi					= 2.0*Pi*drand ();
    stem_moisture		= Leaf_Moisture	(pPR->species);
    stem_permittivity	= vegetation_permittivity (stem_moisture, pPR->frequency);
    Assign_Leaf		(&leaf_stem, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, 
					stem_moisture, stem_permittivity, stem_centre);
	/********************************************/
	/* Calculate the stem scattering amplitudes */
	/********************************************/
#ifndef RAYLEIGH_LEAF
    S_stem			= Leaf_Scattering_Matrix (&leaf_stem, stemL1, stemL2, stemL3, &ki, &ks);
#else
    S_stem			= Leaf_Scattering_Matrix (&leaf_stem, stemL1, stemL2, stemL3, &ki);
#endif
    Eh				= c33Matrix_c3Vector_product (S_stem, ch);
    Ev				= c33Matrix_c3Vector_product (S_stem, cv);
	Shh				= c3Vector_scalar_product (ch, Eh);
	Shv				= c3Vector_scalar_product (ch, Ev);
	Svh				= c3Vector_scalar_product (cv, Eh);
	Svv				= c3Vector_scalar_product (cv, Ev);
	/*****************************************/
    /* Incorporate stochastic scaling factor */
    /*****************************************/
	Shh				= complex_rmul (Shh, Sa_scaling);
	Shv				= complex_rmul (Shv, Sa_scaling);
	Svh				= complex_rmul (Svh, Sa_scaling);
	Svv				= complex_rmul (Svv, Sa_scaling);
	/***********************************/
	/* Incorporate attenuation effects */
	/***********************************/
#ifdef SWITCH_ATTENUATION_ON
	rtn_lookup		= Lookup_Direct_Attenuation (stem_centre, pPR, &gH, &gV);
	Shh				= complex_rmul (Shh, gH*gH);
	Shv				= complex_rmul (Shv, gH*gV);
	Svh				= complex_rmul (Svh, gV*gH);
	Svv				= complex_rmul (Svv, gV*gV);
#endif
	/**************************************/
	/* Monitor backscattering coefficient */
	/**************************************/
	Sigma0HH		+= Shh.r*Shh.r;
	Sigma0HV		+= Shv.r*Shv.r;
	Sigma0VH		+= Svh.r*Svh.r;
	Sigma0VV		+= Svv.r*Svv.r;
	Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r, Shh.phi-Svv.phi);
	AvgShhvv		= complex_add (AvgShhvv, zhhvv);
	/**************************************/
	/* Calculate the stem centre of focus */
	/**************************************/
    stem_grange		= p_grange + stem_y;
	stem_srange		= sqrt ((p_height-stem_height)*(p_height-stem_height) + stem_grange*stem_grange);
	focus_grange	= sqrt (stem_srange*stem_srange - p_height*p_height);
	focus_x			= stem_x;
	focus_y			= focus_grange - p_grange;
	focus_height	= 0.0;
	focus_srange	= sqrt ((p_height-focus_height)*(p_height-focus_height) + (p_grange+focus_y)*(p_grange+focus_y));
	/***************************************************/
	/* Combine contribution into SAR image accumulator */
	/***************************************************/
	weight_average	+= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
	weight_count	+= 1.0;
   }
  }
 }
#endif
#ifndef NO_SHORT_LEAVES
/****************************************/
/* Leaf direct backscatter contribution */
/****************************************/
 nc_leaf			= (int) (vc*pPR->shrt_vegi_leaf_vol_frac/leaf_volume) + 1;
 nr					= (int) (POLSARPROSIM_SHORT_VEGI_REALISATIONS*DEFAULT_RESOLUTION_SAMPLING_FACTOR*DEFAULT_RESOLUTION_SAMPLING_FACTOR);
 if (nr > nc_leaf) {
  nr	= nc_leaf;
 }
 Sa_scaling			= sqrt ((double)nc_leaf/(double)nr);
/*************************/
/* Loop over pixel cells */
/*************************/
 for (i = 0; i < nx; i++) {
  xp	= i*deltax + (deltax - Lx)/2.0;
  for (j = 0; j < ny; j++) {
   yp	= (Ly - deltay)/2.0 - j*deltay;
   zp	= ground_height (pPR, xp, yp);
   for (k = 0; k < nr; k++) {
    /******************/
    /* Realise a leaf */
    /******************/
    leaf_x				= xp + (drand() - 0.5)*deltax;
	leaf_y				= yp + (drand() - 0.5)*deltay;
	leaf_height			= zp + drand() * dsv;
    leaf_centre			= Cartesian_Assign_d3Vector (leaf_x, leaf_y, leaf_height);
    theta				= vegi_polar_angle ();
    phi					= 2.0*Pi*drand ();
    leaf_moisture		= Leaf_Moisture	(pPR->species);
    leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
    Assign_Leaf		(&leaf_leaf, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, 
					leaf_moisture, leaf_permittivity, leaf_centre);
	/********************************************/
	/* Calculate the leaf scattering amplitudes */
	/********************************************/
#ifndef RAYLEIGH_LEAF
    S_leaf			= Leaf_Scattering_Matrix (&leaf_leaf, leafL1, leafL2, leafL3, &ki, &ks);
#else
    S_leaf			= Leaf_Scattering_Matrix (&leaf_leaf, leafL1, leafL2, leafL3, &ki);
#endif
    Eh				= c33Matrix_c3Vector_product (S_leaf, ch);
    Ev				= c33Matrix_c3Vector_product (S_leaf, cv);
	Shh				= c3Vector_scalar_product (ch, Eh);
	Shv				= c3Vector_scalar_product (ch, Ev);
	Svh				= c3Vector_scalar_product (cv, Eh);
	Svv				= c3Vector_scalar_product (cv, Ev);
	/*****************************************/
    /* Incorporate stochastic scaling factor */
    /*****************************************/
	Shh				= complex_rmul (Shh, Sa_scaling);
	Shv				= complex_rmul (Shv, Sa_scaling);
	Svh				= complex_rmul (Svh, Sa_scaling);
	Svv				= complex_rmul (Svv, Sa_scaling);
	/***********************************/
	/* Incorporate attenuation effects */
	/***********************************/
#ifdef SWITCH_ATTENUATION_ON
	rtn_lookup		= Lookup_Direct_Attenuation (leaf_centre, pPR, &gH, &gV);
	Shh				= complex_rmul (Shh, gH*gH);
	Shv				= complex_rmul (Shv, gH*gV);
	Svh				= complex_rmul (Svh, gV*gH);
	Svv				= complex_rmul (Svv, gV*gV);
#endif
	/**************************************/
	/* Monitor backscattering coefficient */
	/**************************************/
	Sigma0HH		+= Shh.r*Shh.r;
	Sigma0HV		+= Shv.r*Shv.r;
	Sigma0VH		+= Svh.r*Svh.r;
	Sigma0VV		+= Svv.r*Svv.r;
	Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r, Shh.phi-Svv.phi);
	AvgShhvv		= complex_add (AvgShhvv, zhhvv);
	/**************************************/
	/* Calculate the leaf centre of focus */
	/**************************************/
    leaf_grange		= p_grange + leaf_y;
	leaf_srange		= sqrt ((p_height-leaf_height)*(p_height-leaf_height) + leaf_grange*leaf_grange);
	focus_grange	= sqrt (leaf_srange*leaf_srange - p_height*p_height);
	focus_x			= leaf_x;
	focus_y			= focus_grange - p_grange;
	focus_height	= 0.0;
	focus_srange	= sqrt ((p_height-focus_height)*(p_height-focus_height) + (p_grange+focus_y)*(p_grange+focus_y));
	/***************************************************/
	/* Combine contribution into SAR image accumulator */
	/***************************************************/
	weight_average	+= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
	weight_count	+= 1.0;
   }
  }
 }
#endif
/***********************/
/* Monitor performance */
/***********************/
 weight_average	/= weight_count;
 Sigma0_count	 = Lx*Ly;
 Sigma0HH		/= Sigma0_count;
 Sigma0HV		/= Sigma0_count;
 Sigma0VH		/= Sigma0_count;
 Sigma0VV		/= Sigma0_count;
 AvgShhvv		= complex_rmul (AvgShhvv, 1.0/Sigma0_count);
 fprintf (pPR->pLogFile, "Average PSF weight sum\t\t\t= %lf\n\n", weight_average);
 fprintf (pPR->pLogFile, "Direct Short HH backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0HH));
 fprintf (pPR->pLogFile, "Direct Short HV backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0HV));
 fprintf (pPR->pLogFile, "Direct Short VH backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0VH));
 fprintf (pPR->pLogFile, "Direct Short VV backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0VV));
 fprintf (pPR->pLogFile, "Direct Short HHVV correlation magnitude   \t= %lf dB\n", 10.0*log10(AvgShhvv.r));
 fprintf (pPR->pLogFile, "Direct Short HHVV correlation phase       \t= %lf rads.\n", AvgShhvv.phi);
 fflush  (pPR->pLogFile);
/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to PolSARproSim_Short_Vegetation_Direct\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to PolSARproSim_Short_Vegetation_Direct\n\n");
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
/********************/
/* Return to caller */
/********************/
 return (NO_POLSARPROSIM_SHORT_VEGI_ERRORS);
}

/**************************************************************************/
/* Bounce short vegi interferometric SAR image calculation implementation */
/**************************************************************************/

int		PolSARproSim_Short_Vegetation_Bounce		(PolSARproSim_Record *pPR)
{
 const double		Pi					= 4.0*atan(1.0);
 const double		thetai				= pPR->incidence_angle[pPR->current_track];
 const double		cos_thetai			= cos(thetai);
 const double		sin_thetai			= sin(thetai);
 const double		Lx					= pPR->Lx;
 const double		Ly					= pPR->Ly;
 const double		deltax				= pPR->deltax;
 const double		deltay				= pPR->deltay;
 const int			nx					= pPR->nx;
 const int			ny					= pPR->ny;
 const double		dsv					= pPR->shrt_vegi_depth;
 const double		vc					= dsv*deltax*deltay;
 int				nr					= (int) (POLSARPROSIM_SHORT_VEGI_REALISATIONS*DEFAULT_RESOLUTION_SAMPLING_FACTOR*DEFAULT_RESOLUTION_SAMPLING_FACTOR);
 Leaf				leaf_stem;
 int				stem_species;
 double				stem_d1, stem_d2, stem_d3;
 double				stem_volume;
 double				stem_moisture;
 Complex			stem_permittivity;
 double				stemL1, stemL2, stemL3;
 d3Vector			stem_centre;
 double				stem_x, stem_y, stem_height;
 Leaf				leaf_leaf;
 int				nc_stem, nc_leaf;
 int				leaf_species;
 double				leaf_d1, leaf_d2, leaf_d3;
 double				leaf_volume;
 double				leaf_moisture;
 Complex			leaf_permittivity;
 double				leafL1, leafL2, leafL3;
 d3Vector			leaf_centre;
 double				leaf_x, leaf_y, leaf_height;
 int				i, j, k;
 double				xp, yp, zp;
 double				Sa_scaling;
 double				theta, phi;
 double				focus_x, focus_y, focus_grange, focus_srange, focus_height;
 double				p_srange		= pPR->slant_range[pPR->current_track];
 double				p_thetai		= pPR->incidence_angle[pPR->current_track];
 double				p_height		= p_srange*cos(p_thetai);
 double				p_grange		= p_srange*sin(p_thetai);
 double				weight_average	= 0.0;
 double				weight_count	= 0.0;
 double				Sigma0HH		= 0.0;
 double				Sigma0HV		= 0.0;
 double				Sigma0VH		= 0.0;
 double				Sigma0VV		= 0.0;
 Complex			AvgShhvv		= xy_complex (0.0, 0.0);
 double				Sigma0_count	= 0.0;
 d3Vector			n				= Cartesian_Assign_d3Vector (-pPR->slope_x, -pPR->slope_y, 1.0);
 d3Vector			z				= Cartesian_Assign_d3Vector (0.0, 0.0, 1.0);
 d3Vector			ki, ks, kr, krm;
 d3Vector			hi,  vi,  hs,  vs,  hr,  vr,  hrm,  vrm;
 d3Vector			hil, vil, hsl, vsl, hrl, vrl, hrlm, vrlm;
 int				rtn_value;
 Plane				Pg;
 d3Vector			g;
 d3Vector			nm;
 Ray				Rb;
 d3Vector			eff_bounce_centre;
 double				bounce_distance;
 d3Vector			specular_point;
 double				specular_distance;
 double				eff_grange, eff_srange;
 d3Vector			a;
 c33Matrix			Sstem1, Sstem2, SstemT;
 c33Matrix			Sleaf1, Sleaf2, SleafT;
 double				std_h;
 double				k0z, k0z2, k02, kro2, kro;
 Complex			k22, k2, k2z2, k2z, koz2, kez2, koz, kez, ke2, ke, kiz, k12, k1;
 Complex			Rhh, Rvv, delta;
 double				gf, Rg;
 c33Matrix			R1, R2;
 c3Vector			chi,  cvi,  chs,  cvs,  chr,  cvr,  chrm,  cvrm;
 c3Vector			chil, cvil, chsl, cvsl, chrl, cvrl, chrlm, cvrlm;
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
/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("Call to PolSARproSim_Short_Vegetation_Bounce ... \n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "\nCall to PolSARproSim_Short_Vegetation_Bounce ... \n\n");
 fflush  (pPR->pLogFile);
/***********************************/
/* Normalise ground surface normal */
/***********************************/
 d3Vector_insitu_normalise (&n);
 nm			= d3Vector_double_multiply (n, -1.0);
/*******************************/
/* Initialise bounce variables */
/*******************************/
 Create_Plane (&Pg);
 Create_Ray (&Rb);
 switch (POLSARPROSIM_RAYLEIGH_ROUGHNESS_MODEL) {
  case 0:	std_h	= pPR->large_scale_height_stdev; break;
  case 1:	std_h	= pPR->small_scale_height_stdev; break;
  case 2:	std_h	= pPR->small_scale_height_stdev + pPR->large_scale_height_stdev; break;
  default:	std_h	= pPR->small_scale_height_stdev + pPR->large_scale_height_stdev; break;
 }
 fprintf (pPR->pLogFile, "std_h\t\t= %lf  \n", std_h);
 fflush  (pPR->pLogFile);
/********************/
/* FSA wave vectors */
/********************/
 ki			= Cartesian_Assign_d3Vector (0.0,  pPR->k0*sin_thetai, -pPR->k0*cos_thetai);
 ks			= Cartesian_Assign_d3Vector (0.0,  -pPR->k0*sin_thetai, pPR->k0*cos_thetai);
 kr			= d3Vector_reflect (ki, n);
 krm		= d3Vector_double_multiply (kr, -1.0);
/****************************/
/* FSA polarisation vectors */
/****************************/
 rtn_value	= Polarisation_Vectors (ki,  z, &hi,  &vi);
 rtn_value	= Polarisation_Vectors (ks,  z, &hs,  &vs);
 rtn_value	= Polarisation_Vectors (kr,  z, &hr,  &vr);
 rtn_value	= Polarisation_Vectors (krm, z, &hrm, &vrm);
 rtn_value	= Polarisation_Vectors (ki,  n, &hil,  &vil);
 rtn_value	= Polarisation_Vectors (ks,  n, &hsl,  &vsl);
 rtn_value	= Polarisation_Vectors (kr,  n, &hrl,  &vrl);
 rtn_value	= Polarisation_Vectors (krm, n, &hrlm, &vrlm);
 chi		= d3V2c3V (hi);
 cvi		= d3V2c3V (vi);
 chs		= d3V2c3V (hs);
 cvs		= d3V2c3V (vs);
 chr		= d3V2c3V (hr);
 cvr		= d3V2c3V (vr);
 chrm		= d3V2c3V (hrm);
 cvrm		= d3V2c3V (vrm);
 chil		= d3V2c3V (hil);
 cvil		= d3V2c3V (vil);
 chsl		= d3V2c3V (hsl);
 cvsl		= d3V2c3V (vsl);
 chrl		= d3V2c3V (hrl);
 cvrl		= d3V2c3V (vrl);
 chrlm		= d3V2c3V (hrlm);
 cvrlm		= d3V2c3V (vrlm);
/*********************************/
/* Local reflection coefficients */
/*********************************/
 k0z		= d3Vector_scalar_product (kr, n);
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
 fflush  (pPR->pLogFile);
 gf			= 4.0*std_h*std_h*k0z2;
 Rg			= exp(-gf/2.0);
 fprintf (pPR->pLogFile, "gf\t\t= %lf  \n", gf);
 fprintf (pPR->pLogFile, "Rg\t\t= %lf  \n", Rg);
 fflush  (pPR->pLogFile);
 Rhh		= complex_rmul (Rhh, Rg);
 Rvv		= complex_rmul (Rvv, Rg);
 fprintf (pPR->pLogFile, "|Rhh|^2\t= %lf  \n", Rhh.r*Rhh.r);
 fprintf (pPR->pLogFile, "|Rvv|^2\t= %lf  \n", Rvv.r*Rvv.r);
 fflush  (pPR->pLogFile);
 R1			= c33Matrix_Complex_product (c3Vector_dyadic_product (chrl, chil), Rhh);
 R1			= c33Matrix_sum (R1, c33Matrix_Complex_product (c3Vector_dyadic_product (cvrl, cvil), Rvv));
 R2			= c33Matrix_Complex_product (c3Vector_dyadic_product (chsl, chrlm), Rhh);
 R2			= c33Matrix_sum (R2, c33Matrix_Complex_product (c3Vector_dyadic_product (cvsl, cvrlm), Rvv));
/*********************************/
/* Reset random number generator */
/*********************************/
 srand (pPR->seed);
/*************************/
/* Assign stem variables */
/*************************/
 stem_species		= POLSARPROSIM_PINE_NEEDLE;
 stem_d1			= POLSARPROSIM_SHORTV_STEM_LENGTH;
 stem_d2			= POLSARPROSIM_SHORTV_STEM_RADIUS;
 stem_d3			= POLSARPROSIM_SHORTV_STEM_RADIUS;
 stem_moisture		= Leaf_Moisture	(pPR->species);			/* Note some calls to allometric equations involve random number generation */
 stem_permittivity	= vegetation_permittivity (stem_moisture, pPR->frequency);
 stemL1				= pPR->ShortVegi_stemL1;
 stemL2				= pPR->ShortVegi_stemL2;
 stemL3				= pPR->ShortVegi_stemL3;
 stem_centre		= Zero_d3Vector ();
 theta				= 0.0;
 phi				= 0.0;
 Assign_Leaf		(&leaf_stem, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, 
					stem_moisture, stem_permittivity, stem_centre);
 stem_volume		= Leaf_Volume (&leaf_stem);
/*************************/
/* Assign leaf variables */
/*************************/
 leaf_species		= POLSARPROSIM_DECIDUOUS_LEAF;
 leaf_d1			= POLSARPROSIM_SHORTV_LEAF_LENGTH;
 leaf_d2			= POLSARPROSIM_SHORTV_LEAF_WIDTH;
 leaf_d3			= POLSARPROSIM_SHORTV_LEAF_THICKNESS;
 leaf_moisture		= Leaf_Moisture	(pPR->species);
 leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
 leafL1				= pPR->ShortVegi_leafL1;
 leafL2				= pPR->ShortVegi_leafL2;
 leafL3				= pPR->ShortVegi_leafL3;
 leaf_centre		= Zero_d3Vector ();
 theta				= 0.0;
 phi				= 0.0;
 Assign_Leaf		(&leaf_leaf, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, 
					leaf_moisture, leaf_permittivity, leaf_centre);
 leaf_volume		= Leaf_Volume (&leaf_leaf);
/*********************/
/* Zero accumulators */
/*********************/
 Sigma0HH			= 0.0;
 Sigma0HV			= 0.0;
 Sigma0VH			= 0.0;
 Sigma0VV			= 0.0;
 Polar_Assign_Complex (&AvgShhvv, 0.0, 0.0);
 Sigma0_count		= 0.0;
 weight_average		= 0.0;
 weight_count		= 0.0;
#ifndef NO_SHORT_STEMS
/****************************************/
/* Stem direct backscatter contribution */
/****************************************/
 nc_stem			= (int) (vc*pPR->shrt_vegi_stem_vol_frac/stem_volume) + 1;
 nr					= (int) (POLSARPROSIM_SHORT_VEGI_REALISATIONS*DEFAULT_RESOLUTION_SAMPLING_FACTOR*DEFAULT_RESOLUTION_SAMPLING_FACTOR);
 if (nr > nc_stem) {
  nr	= nc_stem;
 }
 Sa_scaling			= sqrt ((double)nc_stem/(double)nr);
/*************************/
/* Loop over pixel cells */
/*************************/
 for (i = 0; i < nx; i++) {
  xp	= i*deltax + (deltax - Lx)/2.0;
  for (j = 0; j < ny; j++) {
   yp	= (Ly - deltay)/2.0 - j*deltay;
   zp	= ground_height (pPR, xp, yp);
   for (k = 0; k < nr; k++) {
    /******************/
    /* Realise a stem */
    /******************/
    stem_x				= xp + (drand() - 0.5)*deltax;
	stem_y				= yp + (drand() - 0.5)*deltay;
	stem_height			= zp + drand() * dsv;
    stem_centre			= Cartesian_Assign_d3Vector (stem_x, stem_y, stem_height);
    theta				= vegi_polar_angle ();
    phi					= 2.0*Pi*drand ();
    stem_moisture		= Leaf_Moisture	(pPR->species);
    stem_permittivity	= vegetation_permittivity (stem_moisture, pPR->frequency);
    Assign_Leaf		(&leaf_stem, stem_species, stem_d1, stem_d2, stem_d3, theta, phi, 
					stem_moisture, stem_permittivity, stem_centre);
	/*****************************************/
	/* Calculate the reflection plane origin */
	/*****************************************/
    g					= Cartesian_Assign_d3Vector (stem_x, stem_y, ground_height(pPR, stem_x, stem_y));
	if (stem_height > g.x[2]) {
	 Assign_Plane (&Pg, &g, pPR->slope_x, pPR->slope_y);
	 Assign_Ray_d3V (&Rb, &stem_centre, &nm);
	 rtn_value			= RayPlaneIntersection (&Rb, &Pg, &eff_bounce_centre, &bounce_distance);
	 if ((rtn_value == 1) && (bounce_distance >= 0.0)) {
	  a					= d3Vector_normalise (krm);
 	  Assign_Ray_d3V (&Rb, &stem_centre, &a);
	  rtn_value			= RayPlaneIntersection (&Rb, &Pg, &specular_point, &specular_distance);
	  if ((rtn_value == 1) && (specular_distance >= 0.0)) {
	   /*********************************************/
	   /* Calculate the ground-stem centre of focus */
	   /*********************************************/
       eff_grange		= p_grange + eff_bounce_centre.x[1];
	   eff_srange		= sqrt ((p_height-eff_bounce_centre.x[2])*(p_height-eff_bounce_centre.x[2]) + eff_grange*eff_grange);
	   focus_grange		= sqrt (eff_srange*eff_srange - p_height*p_height);
	   focus_x			= eff_bounce_centre.x[0];
	   focus_y			= focus_grange - p_grange;
	   focus_height		= 0.0;
	   focus_srange		= sqrt ((p_height-focus_height)*(p_height-focus_height) + (p_grange+focus_y)*(p_grange+focus_y));
	   /******************************************/
	   /* Calculate the stem scattering matrices */
	   /******************************************/
#ifndef RAYLEIGH_LEAF
	   Sstem1			= Leaf_Scattering_Matrix (&leaf_stem, stemL1, stemL2, stemL3, &kr, &ks);
	   Sstem2			= Leaf_Scattering_Matrix (&leaf_stem, stemL1, stemL2, stemL3, &ki, &krm);
#else
	   Sstem1			= Leaf_Scattering_Matrix (&leaf_stem, stemL1, stemL2, stemL3, &kr);
	   Sstem2			= Leaf_Scattering_Matrix (&leaf_stem, stemL1, stemL2, stemL3, &ki);
#endif
	   /**********************************/
	   /* Calculate attenuation matrices */
	   /**********************************/
#ifdef SWITCH_ATTENUATION_ON
	   rtn_lookup		= Lookup_Direct_Attenuation (specular_point, pPR, &gHi, &gVi);
	   rtn_lookup		= Lookup_Bounce_Attenuation (stem_centre,    pPR, &gHr, &gVr);
	   rtn_lookup		= Lookup_Direct_Attenuation (stem_centre,    pPR, &gHs, &gVs);
	   Gi				= c33Matrix_Complex_product (c3Vector_dyadic_product (chi, chi), xy_complex (gHi, 0.0));
	   Gi				= c33Matrix_sum (Gi, c33Matrix_Complex_product (c3Vector_dyadic_product (cvi, cvi), xy_complex (gVi, 0.0)));
	   Gr				= c33Matrix_Complex_product (c3Vector_dyadic_product (chr, chr), xy_complex (gHr, 0.0));
	   Gr				= c33Matrix_sum (Gr, c33Matrix_Complex_product (c3Vector_dyadic_product (cvr, cvr), xy_complex (gVr, 0.0)));
	   Gs				= c33Matrix_Complex_product (c3Vector_dyadic_product (chs, chs), xy_complex (gHs, 0.0));
	   Gs				= c33Matrix_sum (Gs, c33Matrix_Complex_product (c3Vector_dyadic_product (cvs, cvs), xy_complex (gVs, 0.0)));
#endif
	   /*******************************************************************/
	   /* Incorporate reflection and attenuation into scattering matrices */
	   /*******************************************************************/
	   Sstem1			= c33Matrix_product (Gs, Sstem1);
	   Sstem1			= c33Matrix_product (Sstem1, Gr);
	   Sstem1			= c33Matrix_product (Sstem1, R1);
	   Sstem1			= c33Matrix_product (Sstem1, Gi);
	   Sstem2			= c33Matrix_product (Sstem2, Gs);
	   Sstem2			= c33Matrix_product (Gr, Sstem2);
	   Sstem2			= c33Matrix_product (R2, Sstem2);
	   Sstem2			= c33Matrix_product (Gi, Sstem2);
	   SstemT			= c33Matrix_sum     (Sstem1, Sstem2);
	   /**************************************************/
	   /* Calculate the scatterimg amplitudes in the FSA */
	   /**************************************************/
       Eh				= c33Matrix_c3Vector_product (SstemT, chi);
       Ev				= c33Matrix_c3Vector_product (SstemT, cvi);
	   Shh				= c3Vector_scalar_product (chs, Eh);
	   Shv				= c3Vector_scalar_product (chs, Ev);
	   Svh				= c3Vector_scalar_product (cvs, Eh);
	   Svv				= c3Vector_scalar_product (cvs, Ev);
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
	   Sigma0HH			+= Shh.r*Shh.r;
	   Sigma0HV			+= Shv.r*Shv.r;
	   Sigma0VH			+= Svh.r*Svh.r;
	   Sigma0VV			+= Svv.r*Svv.r;
	   Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r, Shh.phi-Svv.phi);
	   AvgShhvv			= complex_add (AvgShhvv, zhhvv);
	   /***************************************************/
	   /* Combine contribution into SAR image accumulator */
	   /***************************************************/
	   weight_average	+= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
	   weight_count		+= 1.0;
	  }
	 }
	}
   }
  }
 }
#endif
#ifndef NO_SHORT_LEAVES
/****************************************/
/* Leaf direct backscatter contribution */
/****************************************/
 nc_leaf			= (int) (vc*pPR->shrt_vegi_leaf_vol_frac/leaf_volume) + 1;
 nr					= (int) (POLSARPROSIM_SHORT_VEGI_REALISATIONS*DEFAULT_RESOLUTION_SAMPLING_FACTOR*DEFAULT_RESOLUTION_SAMPLING_FACTOR);
 if (nr > nc_leaf) {
  nr	= nc_leaf;
 }
 Sa_scaling			= sqrt ((double)nc_leaf/(double)nr);
/*************************/
/* Loop over pixel cells */
/*************************/
 for (i = 0; i < nx; i++) {
  xp	= i*deltax + (deltax - Lx)/2.0;
  for (j = 0; j < ny; j++) {
   yp	= (Ly - deltay)/2.0 - j*deltay;
   zp	= ground_height (pPR, xp, yp);
   for (k = 0; k < nr; k++) {
    /******************/
    /* Realise a leaf */
    /******************/
    leaf_x				= xp + (drand() - 0.5)*deltax;
	leaf_y				= yp + (drand() - 0.5)*deltay;
	leaf_height			= zp + drand() * dsv;
    leaf_centre			= Cartesian_Assign_d3Vector (leaf_x, leaf_y, leaf_height);
    theta				= vegi_polar_angle ();
    phi					= 2.0*Pi*drand ();
    leaf_moisture		= Leaf_Moisture	(pPR->species);
    leaf_permittivity	= vegetation_permittivity (leaf_moisture, pPR->frequency);
    Assign_Leaf		(&leaf_leaf, leaf_species, leaf_d1, leaf_d2, leaf_d3, theta, phi, 
					leaf_moisture, leaf_permittivity, leaf_centre);
	/*****************************************/
	/* Calculate the reflection plane origin */
	/*****************************************/
    g					= Cartesian_Assign_d3Vector (leaf_x, leaf_y, ground_height(pPR, leaf_x, leaf_y));
	if (leaf_height > g.x[2]) {
	 Assign_Plane (&Pg, &g, pPR->slope_x, pPR->slope_y);
	 Assign_Ray_d3V (&Rb, &leaf_centre, &nm);
	 rtn_value			= RayPlaneIntersection (&Rb, &Pg, &eff_bounce_centre, &bounce_distance);
	 if ((rtn_value == 1) && (bounce_distance >= 0.0)) {
	  a					= d3Vector_normalise (krm);
 	  Assign_Ray_d3V (&Rb, &leaf_centre, &a);
	  rtn_value			= RayPlaneIntersection (&Rb, &Pg, &specular_point, &specular_distance);
	  if ((rtn_value == 1) && (specular_distance >= 0.0)) {
	   /*********************************************/
	   /* Calculate the ground-leaf centre of focus */
	   /*********************************************/
       eff_grange		= p_grange + eff_bounce_centre.x[1];
	   eff_srange		= sqrt ((p_height-eff_bounce_centre.x[2])*(p_height-eff_bounce_centre.x[2]) + eff_grange*eff_grange);
	   focus_grange		= sqrt (eff_srange*eff_srange - p_height*p_height);
	   focus_x			= eff_bounce_centre.x[0];
	   focus_y			= focus_grange - p_grange;
	   focus_height		= 0.0;
	   focus_srange		= sqrt ((p_height-focus_height)*(p_height-focus_height) + (p_grange+focus_y)*(p_grange+focus_y));
	   /******************************************/
	   /* Calculate the leaf scattering matrices */
	   /******************************************/
#ifndef RAYLEIGH_LEAF
	   Sleaf1			= Leaf_Scattering_Matrix (&leaf_leaf, leafL1, leafL2, leafL3, &kr, &ks);
	   Sleaf2			= Leaf_Scattering_Matrix (&leaf_leaf, leafL1, leafL2, leafL3, &ki, &krm);
#else
	   Sleaf1			= Leaf_Scattering_Matrix (&leaf_leaf, leafL1, leafL2, leafL3, &kr);
	   Sleaf2			= Leaf_Scattering_Matrix (&leaf_leaf, leafL1, leafL2, leafL3, &ki);
#endif
	   /**********************************/
	   /* Calculate attenuation matrices */
	   /**********************************/
#ifdef SWITCH_ATTENUATION_ON
	   rtn_lookup		= Lookup_Direct_Attenuation (specular_point, pPR, &gHi, &gVi);
	   rtn_lookup		= Lookup_Bounce_Attenuation (leaf_centre,    pPR, &gHr, &gVr);
	   rtn_lookup		= Lookup_Direct_Attenuation (leaf_centre,    pPR, &gHs, &gVs);
	   Gi				= c33Matrix_Complex_product (c3Vector_dyadic_product (chi, chi), xy_complex (gHi, 0.0));
	   Gi				= c33Matrix_sum (Gi, c33Matrix_Complex_product (c3Vector_dyadic_product (cvi, cvi), xy_complex (gVi, 0.0)));
	   Gr				= c33Matrix_Complex_product (c3Vector_dyadic_product (chr, chr), xy_complex (gHr, 0.0));
	   Gr				= c33Matrix_sum (Gr, c33Matrix_Complex_product (c3Vector_dyadic_product (cvr, cvr), xy_complex (gVr, 0.0)));
	   Gs				= c33Matrix_Complex_product (c3Vector_dyadic_product (chs, chs), xy_complex (gHs, 0.0));
	   Gs				= c33Matrix_sum (Gs, c33Matrix_Complex_product (c3Vector_dyadic_product (cvs, cvs), xy_complex (gVs, 0.0)));
#endif
	   /*******************************************************************/
	   /* Incorporate reflection and attenuation into scattering matrices */
	   /*******************************************************************/
	   Sleaf1			= c33Matrix_product (Gs, Sleaf1);
	   Sleaf1			= c33Matrix_product (Sleaf1, Gr);
	   Sleaf1			= c33Matrix_product (Sleaf1, R1);
	   Sleaf1			= c33Matrix_product (Sleaf1, Gi);
	   Sleaf2			= c33Matrix_product (Sleaf2, Gs);
	   Sleaf2			= c33Matrix_product (Gr, Sleaf2);
	   Sleaf2			= c33Matrix_product (R2, Sleaf2);
	   Sleaf2			= c33Matrix_product (Gi, Sleaf2);
	   SleafT			= c33Matrix_sum     (Sleaf1, Sleaf2);
	   /**************************************************/
	   /* Calculate the scatterimg amplitudes in the FSA */
	   /**************************************************/
       Eh				= c33Matrix_c3Vector_product (SleafT, chi);
       Ev				= c33Matrix_c3Vector_product (SleafT, cvi);
	   Shh				= c3Vector_scalar_product (chs, Eh);
	   Shv				= c3Vector_scalar_product (chs, Ev);
	   Svh				= c3Vector_scalar_product (cvs, Eh);
	   Svv				= c3Vector_scalar_product (cvs, Ev);
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
	   Sigma0HH			+= Shh.r*Shh.r;
	   Sigma0HV			+= Shv.r*Shv.r;
	   Sigma0VH			+= Svh.r*Svh.r;
	   Sigma0VV			+= Svv.r*Svv.r;
	   Polar_Assign_Complex (&zhhvv, Shh.r*Svv.r, Shh.phi-Svv.phi);
	   AvgShhvv			= complex_add (AvgShhvv, zhhvv);
	   /***************************************************/
	   /* Combine contribution into SAR image accumulator */
	   /***************************************************/
	   weight_average	+= Accumulate_SAR_Contribution (focus_x, focus_y, focus_srange, Shh, Shv, Svv, pPR);
	   weight_count		+= 1.0;
	  }
	 }
	}
   }
  }
 }
#endif
/***********************/
/* Monitor performance */
/***********************/
 weight_average	/= weight_count;
 Sigma0_count	 = Lx*Ly;
 Sigma0HH		/= Sigma0_count;
 Sigma0HV		/= Sigma0_count;
 Sigma0VH		/= Sigma0_count;
 Sigma0VV		/= Sigma0_count;
 AvgShhvv		= complex_rmul (AvgShhvv, 1.0/Sigma0_count);
 fprintf (pPR->pLogFile, "Average PSF weight sum\t\t\t= %lf\n\n", weight_average);
 fprintf (pPR->pLogFile, "Short Bounce HH backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0HH));
 fprintf (pPR->pLogFile, "Short Bounce HV backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0HV));
 fprintf (pPR->pLogFile, "Short Bounce VH backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0VH));
 fprintf (pPR->pLogFile, "Short Bounce VV backscattering coefficient\t= %lf dB\n", 10.0*log10(Sigma0VV));
 fprintf (pPR->pLogFile, "Short Bounce HHVV correlation magnitude   \t= %lf dB\n", 10.0*log10(AvgShhvv.r));
 fprintf (pPR->pLogFile, "Short Bounce HHVV correlation phase       \t= %lf rads.\n", AvgShhvv.phi);
 fflush  (pPR->pLogFile);
/******************************************/
/* Report call if running in VERBOSE mode */
/******************************************/
#ifdef VERBOSE_POLSARPROSIM
 printf ("\n");
 printf ("... Returning from call to PolSARproSim_Short_Vegetation_Bounce\n");
 printf ("\n");
#endif
 fprintf (pPR->pLogFile, "... Returning from call to PolSARproSim_Short_Vegetation_Bounce\n\n");
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
/********************/
/* Return to caller */
/********************/
 return (NO_POLSARPROSIM_SHORT_VEGI_ERRORS);
}
