/************************************************************************/
/*																		*/
/* PolSARProSim Version 1.0a Forest Synthetic Aperture Radar Simulation	*/
/* Copyright (C) 2006 Mark L. Williams									*/
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
/************************************************************************//*
 * Author      : Mark L. Williams
 * Module      : PolSARproSim_ImgSize.c
 * Revision    : Version 1.0a
 * Date        : August 2006
 * Notes       : Coherent Forest SAR Simulation for PolSARPro.
 */

/* C INCLUDES */
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/*******************************************/
/*     PolSARpro ROUTINES DECLARATION      */
/*******************************************/
void edit_error(char *s1, char *s2);
void check_file(char *file);

/*******************************************/
/* Special routine to calculate image size */
/*******************************************/

#define	RESOLUTION_GAP_SIZE							10.0			/* Amount of SAR image border specified in mean resolutions		*/
#define DEFAULT_RESOLUTION_SAMPLING_FACTOR			0.6667			/* Ratio of pixel dimension to resolution						*/
#define	POLSARPROSIM_HEDGE							0				/* The "hedge" (deciduous, homogeneous cylinder)				*/
#define	POLSARPROSIM_PINE001						1				/* Homemade Scots Pine with Spheroidal crown					*/
#define	POLSARPROSIM_PINE002						2				/* Homemade Scots Pine with Conical crown						*/
#define	POLSARPROSIM_PINE003						3				/* Homemade Scots Pine with 50% pY Spheroidal/Conical crown		*/
#define	POLSARPROSIM_DECIDUOUS001					4				/* A Deciduous tree												*/
#define	HEDGE_RADIUS_FACTOR							2.5				/* Default ratio of hedge radius to hedge height				*/
#define	POLSARPROSIM_DECIDUOUS001_CROWN_BETA_AVG	0.785398163
#define	POLSARPROSIM_DECIDUOUS001_CROWN_ALPHA		0.410
#define	DPI_RAD										3.14159265358979
#define	DPI_DEG										180.0

double		Mean_Crown_Edge_Length			(int species, double height)
{
 double		R;
 if (height < 5.0) {
  height	= 5.0;
 } else {
  if (height > 23.0) {
   height	= 23.0;
  }
 }
 switch (species) {
  case POLSARPROSIM_HEDGE:			R	= height*sqrt(HEDGE_RADIUS_FACTOR*HEDGE_RADIUS_FACTOR+1.0); break;
  case POLSARPROSIM_PINE001:		R	= 0.0048*height*height*height - 0.2499*height*height +  3.938*height - 8.7537; break;
  case POLSARPROSIM_PINE002:		R	= 0.0048*height*height*height - 0.2499*height*height +  3.938*height - 8.7537; break;
  case POLSARPROSIM_PINE003:		R	= 0.0048*height*height*height - 0.2499*height*height +  3.938*height - 8.7537; break;
  case POLSARPROSIM_DECIDUOUS001:	R	= POLSARPROSIM_DECIDUOUS001_CROWN_ALPHA*height/cos(POLSARPROSIM_DECIDUOUS001_CROWN_BETA_AVG); break;
  default:							R	= 0.0048*height*height*height - 0.2499*height*height +  3.938*height - 8.7537; break;
 }
 return (R);
}

double		Mean_Crown_Angle_Beta			(int species, double height)
{
 double		beta;
 if (height < 5.0) {
  height	= 5.0;
  } else {
   if (height > 23.0) {
    height	= 23.0;
   }
  }
 switch (species) {
  case POLSARPROSIM_HEDGE:			beta	= atan(HEDGE_RADIUS_FACTOR); break;
  case POLSARPROSIM_PINE001:		beta	= DPI_RAD*(-0.0043*height*height*height + 0.2066*height*height - 2.4983*height + 19.972)/DPI_DEG; break;
  case POLSARPROSIM_PINE002:		beta	= DPI_RAD*(-0.0043*height*height*height + 0.2066*height*height - 2.4983*height + 19.972)/DPI_DEG; break;
  case POLSARPROSIM_PINE003:		beta	= DPI_RAD*(-0.0043*height*height*height + 0.2066*height*height - 2.4983*height + 19.972)/DPI_DEG; break;
  case POLSARPROSIM_DECIDUOUS001:	beta	= POLSARPROSIM_DECIDUOUS001_CROWN_BETA_AVG; break;
  default:							beta	= DPI_RAD*(-0.0043*height*height*height + 0.2066*height*height - 2.4983*height + 19.972)/DPI_DEG; break;
 }
 return (beta);
}

double		Mean_Tree_Crown_Radius				(int species, double height)
{
 double	a	= Mean_Crown_Edge_Length (species, height)*sin(Mean_Crown_Angle_Beta (species, height));
 return (a);
}

void Image_Size_Calculation (int spc, double mth, double thi, double azr, double grr, double fsa, int *pNazimuth, int *pNrange, double *LLx, double *LLy, double *Ddeltax, double *Ddeltay)
{
/*********************************************/
/* spc    = tree species (0-4)               */
/* mth    = mean tree height (metres)        */
/* thi    = incidence angle (degrees)        */
/* azr    = azimuth resolution (metres)      */
/* grr    = ground range resolution (metres) */
/* fsa    = forest stand area (hectares)     */
/*********************************************/
 double		fsr		= sqrt(2500.0*fsa/atan(1.0));
 double		Layover	= mth/tan(atan(1.0)*thi/45.0);
 double		Shadow	= mth*tan(atan(1.0)*thi/45.0);
 double		Gap		= RESOLUTION_GAP_SIZE*(azr+grr)/2.0;
 double		deltax	= azr*DEFAULT_RESOLUTION_SAMPLING_FACTOR;
 double		deltay	= grr*DEFAULT_RESOLUTION_SAMPLING_FACTOR;
 double		mcr;
 double		Lx;
 double		Ly;
 int		nx;
 int		ny;

 if (spc == POLSARPROSIM_HEDGE) {
  mcr		= fsr;
  Lx		= 2.0*(fsr + Gap);
 } else {
  mcr		= Mean_Tree_Crown_Radius (spc, mth);
  Lx		= 2.0*(fsr + Gap + mcr);
 }
 Ly			= Lx + Layover + Shadow;
 nx			= (int) (Lx/deltax) + 1;
 nx			= 2*((int)(nx/2))+1;
 deltax		= Lx/nx;
 ny			= (int) (Ly/deltay) + 1;
 ny			= 2*((int)(ny/2))+1;
 deltay		= Ly/ny; 
 *pNazimuth	= nx;
 *pNrange	= ny;

 *LLx = Lx; *LLy = Ly; *Ddeltax = deltax; *Ddeltay = deltay;
 return;
}

/**************************/
/* End of special routine */
/**************************/

int main(int argc, char *argv[])
{
/**************************************/
/* Miscellaneous variable definitions */
/**************************************/
 FILE *fileoutput;
 char FileOutput[128];
 double	mean_tree_height;
 double incidence;
 double az_resolution;
 double gr_resolution;
 double	forest_stand_area;
 int species, nx, ny;
 double Lx, Ly, deltax,deltay;

/*******************************************/
/* Check command line argument list length */
/*******************************************/
    if (argc == 8) {
	strcpy(FileOutput, argv[1]);
	species = atoi(argv[2]);
	mean_tree_height = atof(argv[3]);
	incidence = atof(argv[4]);
	az_resolution = atof(argv[5]);
	gr_resolution = atof(argv[6]);
	forest_stand_area = atof(argv[7]);
    } else {
	edit_error("PolSARproSim_ImgSize config_file species mean_tree_height (m) incidence_angle (deg) az_resolution (m) rg_resolution (m) forest_stand_area (Ha)\n","");
    }

    check_file(FileOutput);
	gr_resolution = gr_resolution/cos((90.0-incidence)*atan(1.0)/45.0);
	
/********************************/
/* Testing image dimension code */
/********************************/
Image_Size_Calculation (species, mean_tree_height, incidence, az_resolution, gr_resolution, forest_stand_area, &nx, &ny, &Lx, &Ly, &deltax, &deltay);
	
/********************************/
/* Output Temporary Config File */
/********************************/
 if ((fileoutput = fopen(FileOutput, "w")) == NULL)
 edit_error("Could not open temporary configuration file : ",FileOutput);
 fprintf(fileoutput, "Azimuth Pixels\n");
 fprintf(fileoutput, "%d\n",nx);
 fprintf(fileoutput, "Range Pixels\n");
 fprintf(fileoutput, "%d\n",ny);
 fprintf(fileoutput, "Azimuth Image Size\n");
 fprintf(fileoutput, "%f\n",Lx);
 fprintf(fileoutput, "Range Image Size\n");
 fprintf(fileoutput, "%f\n",Ly);
 fprintf(fileoutput, "Azimuth Pixel Size\n");
 fprintf(fileoutput, "%f\n",deltax);
 fprintf(fileoutput, "Range Pixel Size\n");
 fprintf(fileoutput, "%f\n",deltay);
 fclose(fileoutput);
/***************/
/* End of Main */
/***************/
 return (0);
}

/* PolSARpro ROUTINES DECLARATION */
/*******************************************************************************
Routine  : edit_error
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update   :
*-------------------------------------------------------------------------------
Description :  Displays an error message and exits the program
*-------------------------------------------------------------------------------
Inputs arguments :
s1    : message to be displayed
s2    : message to be displayed
Returned values  :
void
*******************************************************************************/
void edit_error(char *s1, char *s2)
{
    printf("\n A processing error occured ! \n %s%s\n", s1, s2);
    exit(1);
}

/*******************************************************************************
Routine  : check_file
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 01/2002
Update   :
*-------------------------------------------------------------------------------
Description :  Checks and corrects slashes in file string
*-------------------------------------------------------------------------------
Inputs arguments :
file    : string to be checked
Returned values  :
void
*******************************************************************************/
void check_file(char *file)
{
#ifdef _WIN32
    int i;
    i = 0;
    while (file[i] != '\0')
   	{
		if (file[i] == '/') file[i] = '\\';
		i++;
    }
#endif
}

