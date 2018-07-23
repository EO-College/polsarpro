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
/************************************************************************/
/* PolSARproSimGV Version 1.0b Ground and Ground / Vegetation SAR       */
/* Simulation based on the PolSARproSim developped by Mark L. Williams  */
/************************************************************************/
/*
 * Author      : Marco Lavalle & Eric Pottier
 * Module      : PolSARproSimGV_ImgSize.c
 * Revision    : Version 1.0b
 * Date        : December 2008
 * Notes       : Coherent Ground & Ground/vegetation SAR Simulation for PolSARPro.
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

#define	RESOLUTION_GAP_SIZE							0.0				/* Amount of SAR image border specified in mean resolutions		*/
#define DEFAULT_RESOLUTION_SAMPLING_FACTOR			0.6667			/* Ratio of pixel dimension to resolution						*/
#define	POLSARPROSIM_HEDGE							0				/* The "hedge" (deciduous, homogeneous cylinder)				*/

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
  //mcr		= Mean_Tree_Crown_Radius (spc, mth);
  //Lx		= 2.0*(fsr + Gap + mcr);
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
	edit_error("PolSARproSimGV_ImgSize config_file species mean_tree_height (m) incidence_angle (deg) az_resolution (m) rg_resolution (m) forest_stand_area (Ha)\n","");
    }

    check_file(FileOutput);
	gr_resolution = gr_resolution/cos((90.0-incidence)*atan(1.0)/45.0);

	species = 0;
	mean_tree_height = 0.0;
	
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

