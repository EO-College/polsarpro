/*******************************************************************************
PolSARpro v2.0 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 (1991) of the License, or any later version.
This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details.

********************************************************************************

File     : PolSARproSim_FE_Kz.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Version  : 1.0
Creation : 10/2006
Update   :

*-------------------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164
Groupe Image et Teledetection
Equipe SAPHIR (SAr Polarimetrie Holographie Interferometrie Radargrammetrie)
UNIVERSITE DE RENNES I
Pôle Micro-Ondes Radar
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail : eric.pottier@univ-rennes1.fr, laurent.ferro-famil@univ-rennes1.fr
*-------------------------------------------------------------------------------
Description : Calculate the Flat Earth and Kz files

Inputs  : 

Outputs : In out_dir directory
flat_earth.bin
kz.bin

*-------------------------------------------------------------------------------
Routines    :
void edit_error(char *s1,char *s2);
void check_dir(char *dir);
double **matrix_double(int nrh,int nch);
void free_matrix_double(double **m,int nrh);

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif


/* ROUTINES DECLARATION */
#include "../lib/matrix.h"
#include "../lib/util.h"


/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 10/2006
Update   :
*-------------------------------------------------------------------------------
Description : Calculate the Flat Earth and Kz files

Inputs  : 

Outputs : In out_dir directory
flat_earth.bin
kz.bin

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
1
*******************************************************************************/


int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */


/* Input/Output file pointer arrays */
    FILE *out_file_fe, *out_file_kz;

/* Strings */
    char file_name[128], out_dir[128];

/* Input variables */
    int Nlig, Ncol;		/* Initial image nb of lines and rows */

/* Internal variables */
    int lig, col, Mcol;
	double dy, Bh, Bv, f0, lambda, Ymid;
	double H0, H1, G0, G1, teta0, teta1, K;
	double R0, R1, Rp0, Rp1, y, phi, Dteta;
	double SINphi, COSphi, B, alpha, thetaOffNad; //Marco
	double differ; //Marco
/* Matrix arrays */
    float *FE;
	float *KZ;

/* PROGRAM START */

    if (argc == 13) {
	strcpy(out_dir, argv[1]);
	Nlig = atoi(argv[2]);
	Ncol = atoi(argv[3]);
	dy = atof(argv[4]);
	f0 = atof(argv[5]);
	teta0 = atof(argv[6]);
	H0 = atof(argv[7]);
	Bh = atof(argv[8]);
	Bv = atof(argv[9]);
	 R0 = atof(argv[10]);
	 R1 = atof(argv[11]);
	 teta1 = atof(argv[12]);
    } else
	edit_error("PolSARpro_FE_Kz out_dir Nlig Ncol dy (m) f0 (GHz) teta0 (deg) H0 (m) Bh (m) Bv (m) R0 R1 teta1\n","");

    check_dir(out_dir);

/* MATRIX DECLARATION */
    FE = vector_float(Ncol);
    KZ = vector_float(Ncol);

	teta0 = teta0*pi/180.;
	teta1 = teta1*pi/180.;

	Mcol = (int)(Ncol/2);
	//dy   = dy * sin(teta0);
	Ymid = Mcol * dy;
	lambda = M_C / (f0*1.E+9);
	K = 8.*atan(1.) / lambda;
	//R0 = H0 / cos(teta0);
	G0 = R0 * sin(teta0);
	//R1 = sqrt((G0+Bh)*(G0+Bh)+(H0+Bv)*(H0+Bv));
	//teta1 = atan2(G0+Bh,H0+Bv);
	H1 = R1 * cos(teta1);
	G1 = R1 * sin(teta1);
	//printf("%d\t%f\t%f\t%f\t%f\t%f\t%f\t%fn", Mcol, lambda, R0, G0, H0, R1, G1, H1); 
	//printf("%s\t%s\t%s\t%s\t%s\t%s\n", "---col---", "---y---", "---Rp0---", "---Rp1---", "---phi---", "---FE---"); //Marco
	B = sqrt(Bv*Bv+Bh*Bh);
	alpha = atan2(Bv, Bh);
	for (col = 0; col < Ncol; col++)
	{
		//if (col%(int)(Ncol/20) == 0) {printf("%f\r", 100. * col / (Ncol - 1));fflush(stdout);}
		y = col * dy - Ymid;
		Rp0 = sqrt((y+G0)*(y+G0)+H0*H0);
		Rp1 = sqrt((y+G1)*(y+G1)+H1*H1);
		phi = 2.0*K*(Rp0-Rp1); //2* //Marco 1-sol (2* removed)
		differ = (Rp0-Rp1);
		thetaOffNad = atan2(y, H0);
		//phi = 4.0*(4.0*atan(1.))/lambda*B*(cos(alpha)*sqrt(1-(H0*H0)/(Rp0*Rp0)) - sin(alpha)*(H0/Rp0)); //Marco 2-sol
		//phi = 4.0*(4.0*atan(1.))/lambda*B*sin(thetaOffNad-alpha); //Marco 3-sol

		SINphi = sin(phi);
		COSphi = cos(phi);
		FE[col] = (float)atan2(SINphi,COSphi);
		//printf("%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n", col, y, Rp0, Rp1, differ, K, phi, SINphi, COSphi, FE[col]); //Marco

	}

	sprintf(file_name, "%s%s", out_dir, "flat_earth.bin");
	if ((out_file_fe = fopen(file_name, "wb")) == NULL)
	    edit_error("Could not open output file : ", file_name);
	for (lig = 0; lig < Nlig; lig++)
	{
		if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
		fwrite(&FE[0], sizeof(float), Ncol, out_file_fe);
	}
	fclose(out_file_fe);

	Dteta = atan((H0*tan(teta0)+Bh)/(H0+Bv))-teta0;
	KZ[0] = (float)(4.*pi*Dteta/(lambda*sin(teta0)));
	for (col = 0; col < Ncol; col++) KZ[col] = KZ[0];

	sprintf(file_name, "%s%s", out_dir, "kz.bin");
	if ((out_file_kz = fopen(file_name, "wb")) == NULL)
	    edit_error("Could not open output file : ", file_name);
	for (lig = 0; lig < Nlig; lig++)
	{
		if (lig%(int)(Nlig/20) == 0) {printf("%f\r", 100. * lig / (Nlig - 1));fflush(stdout);}
		fwrite(&KZ[0], sizeof(float), Ncol, out_file_kz);
	}
	fclose(out_file_kz);

    return 1;
}
