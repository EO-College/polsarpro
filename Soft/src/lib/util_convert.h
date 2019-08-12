/********************************************************************
PolSARpro v4.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

	File	 : util_convert.h
	Project  : ESA_POLSARPRO
	Authors  : Eric POTTIER
	Version  : 1.0
	Creation : 08/2010
	Update	: 

*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Image and Remote Sensing Group
SAPHIR Team 
(SAr Polarimetry Holography Interferometry Radargrammetry)

UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr
		laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

	Description :  UTIL Routines for Polarimetric Data Convert

*--------------------------------------------------------------------
	Routines	:

int S2_to_C3elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C4elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T3elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T4elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T6elt(int Np, float ***S_in1, float ***S_in2, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_C2elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_T2elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int S2_to_SPP(float ***S_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_IPP(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C2(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C3(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C4(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T2(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T3(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T4(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T6(float ***S_in1, float ***S_in2, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int SPP_to_C2(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_T2(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_IPP(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_T4(float ***S_in1, float ***S_in2, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C2_to_IPP(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C2_to_T2(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T2_to_C2(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C4_to_T4(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_C2(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_IPP(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);

int T4_to_C4(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T4_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T4_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C3_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C3_to_C2(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C3_to_IPP(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);

int T3_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T6_to_C3(float ***M_in, int MasterSlave, int Nlig, int Ncol, int NwinLig, int NwinCol);

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef FlagUtilConvert
#define FlagUtilConvert

/*******************************************************************/

int S2_to_C3elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C4elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T3elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T4elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T6elt(int Np, float ***S_in1, float ***S_in2, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_C2elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_T2elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int S2_to_SPP(float ***S_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_IPP(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C2(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C3(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_C4(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T2(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T3(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T4(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int S2_to_T6(float ***S_in1, float ***S_in2, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int SPP_to_C2(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_T2(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_IPP(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int SPP_to_T4(float ***S_in1, float ***S_in2, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C2_to_IPP(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C2_to_T2(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T2_to_C2(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C4_to_T4(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_C2(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C4_to_IPP(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);

int T4_to_C4(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T4_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T4_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);

int C3_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C3_to_C2(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);
int C3_to_IPP(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol);

int T3_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol);
int T6_to_C3(float ***M_in, int MasterSlave, int Nlig, int Ncol, int NwinLig, int NwinCol);

#endif
