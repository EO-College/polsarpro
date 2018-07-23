/********************************************************************
PolSARpro v5.0 is free software; you can redistribute it and/or 
modify it under the terms of the GNU General Public License as 
published by the Free Software Foundation; either version 2 (1991) of
the License, or any later version. This program is distributed in the
hope that it will be useful, but WITHOUT ANY WARRANTY; without even 
the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
PURPOSE. 

See the GNU General Public License (Version 2, 1991) for more details

*********************************************************************

File   : util_convert.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2010
Update  : 

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
Routines  :

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
#include <time.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#include "PolSARproLib.h"

/********************************************************************
Routine  : S2_to_C3elt
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of one element of the C3 matrix from
        S2 matrix
********************************************************************/
int S2_to_C3elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[hh][lig][2*col];
      k1i = S_in[hh][lig][2*col+1];
      k2r = (S_in[hv][lig][2*col] + S_in[vh][lig][2*col]) / sqrt(2.);
      k2i = (S_in[hv][lig][2*col+1] + S_in[vh][lig][2*col+1]) / sqrt(2.);
      k3r = S_in[vv][lig][2*col];
      k3i = S_in[vv][lig][2*col+1];
      
      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k1r * k3r + k1i * k3i;
          break;
        case 4 :
          M_in[lig][col] = k1i * k3r - k1r * k3i;
          break;
        case 5 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        case 6 :
          M_in[lig][col] = k2r * k3r + k2i * k3i;
          break;
        case 7 :
          M_in[lig][col] = k2i * k3r - k2r * k3i;
          break;
        case 8 :
          M_in[lig][col] = k3r * k3r + k3i * k3i;    
          break;
        }  
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_T3elt
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*-----------------------------------------------------------------------
Description : create an array of one element of the T3 matrix from
        S2 matrix
********************************************************************/
int S2_to_T3elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in[hh][lig][2*col] + S_in[vv][lig][2*col]) / sqrt(2.);
      k1i = (S_in[hh][lig][2*col+1] + S_in[vv][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in[hh][lig][2*col] - S_in[vv][lig][2*col]) / sqrt(2.);
      k2i = (S_in[hh][lig][2*col+1] - S_in[vv][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in[hv][lig][2*col] + S_in[vh][lig][2*col]) / sqrt(2.);
      k3i = (S_in[hv][lig][2*col+1] + S_in[vh][lig][2*col+1]) / sqrt(2.);
      
      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k1r * k3r + k1i * k3i;
          break;
        case 4 :
          M_in[lig][col] = k1i * k3r - k1r * k3i;
          break;
        case 5 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        case 6 :
          M_in[lig][col] = k2r * k3r + k2i * k3i;
          break;
        case 7 :
          M_in[lig][col] = k2i * k3r - k2r * k3i;
          break;
        case 8 :
          M_in[lig][col] = k3r * k3r + k3i * k3i;    
          break;
        }
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_C4elt
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of one element of the C4 matrix from
        S2 matrix
********************************************************************/
int S2_to_C4elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[hh][lig][2*col];
      k1i = S_in[hh][lig][2*col+1];
      k2r = S_in[hv][lig][2*col];
      k2i = S_in[hv][lig][2*col+1];
      k3r = S_in[vh][lig][2*col];
      k3i = S_in[vh][lig][2*col+1];
      k4r = S_in[vv][lig][2*col];
      k4i = S_in[vv][lig][2*col+1];

      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k1r * k3r + k1i * k3i;
          break;
        case 4 :
          M_in[lig][col] = k1i * k3r - k1r * k3i;
          break;
        case 5 :
          M_in[lig][col] = k1r * k4r + k1i * k4i;
          break;
        case 6 :
          M_in[lig][col] = k1i * k4r - k1r * k4i;
          break;
        case 7 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        case 8 :
          M_in[lig][col] = k2r * k3r + k2i * k3i;    
          break;
        case 9 :
          M_in[lig][col] = k2i * k3r - k2r * k3i;
          break;
        case 10 :
          M_in[lig][col] = k2r * k4r + k2i * k4i;
          break;
        case 11 :
          M_in[lig][col] = k2i * k4r - k2r * k4i;
          break;
        case 12 :
          M_in[lig][col] = k3r * k3r + k3i * k3i;
          break;
        case 13 :
          M_in[lig][col] = k3r * k4r + k3i * k4i;
          break;
        case 14 :
          M_in[lig][col] = k3i * k4r - k3r * k4i;
          break;
        case 15 :
          M_in[lig][col] = k4r * k4r + k4i * k4i;
          break;
        }
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_T4elt
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of one element of the T4 matrix from
        S2 matrix
********************************************************************/
int S2_to_T4elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in[hh][lig][2*col] + S_in[vv][lig][2*col]) / sqrt(2.);
      k1i = (S_in[hh][lig][2*col+1] + S_in[vv][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in[hh][lig][2*col] - S_in[vv][lig][2*col]) / sqrt(2.);
      k2i = (S_in[hh][lig][2*col+1] - S_in[vv][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in[hv][lig][2*col] + S_in[vh][lig][2*col]) / sqrt(2.);
      k3i = (S_in[hv][lig][2*col+1] + S_in[vh][lig][2*col+1]) / sqrt(2.);
      k4r = (S_in[vh][lig][2*col+1] - S_in[hv][lig][2*col+1]) / sqrt(2.);
      k4i = (S_in[hv][lig][2*col] - S_in[vh][lig][2*col]) / sqrt(2.);

      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k1r * k3r + k1i * k3i;
          break;
        case 4 :
          M_in[lig][col] = k1i * k3r - k1r * k3i;
          break;
        case 5 :
          M_in[lig][col] = k1r * k4r + k1i * k4i;
          break;
        case 6 :
          M_in[lig][col] = k1i * k4r - k1r * k4i;
          break;
        case 7 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        case 8 :
          M_in[lig][col] = k2r * k3r + k2i * k3i;    
          break;
        case 9 :
          M_in[lig][col] = k2i * k3r - k2r * k3i;
          break;
        case 10 :
          M_in[lig][col] = k2r * k4r + k2i * k4i;
          break;
        case 11 :
          M_in[lig][col] = k2i * k4r - k2r * k4i;
          break;
        case 12 :
          M_in[lig][col] = k3r * k3r + k3i * k3i;
          break;
        case 13 :
          M_in[lig][col] = k3r * k4r + k3i * k4i;
          break;
        case 14 :
          M_in[lig][col] = k3i * k4r - k3r * k4i;
          break;
        case 15 :
          M_in[lig][col] = k4r * k4r + k4i * k4i;
          break;
        }
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_T6elt
Authors  : Eric POTTIER
Creation : 01/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of one element of the T6 matrix from
        S2 matrix
********************************************************************/
int S2_to_T6elt(int Np, float ***S_in1, float ***S_in2, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i, k5r, k5i, k6r, k6i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in1[hh][lig][2*col] + S_in1[vv][lig][2*col]) / sqrt(2.);
      k1i = (S_in1[hh][lig][2*col+1] + S_in1[vv][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in1[hh][lig][2*col] - S_in1[vv][lig][2*col]) / sqrt(2.);
      k2i = (S_in1[hh][lig][2*col+1] - S_in1[vv][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in1[hv][lig][2*col] + S_in1[vh][lig][2*col]) / sqrt(2.);
      k3i = (S_in1[hv][lig][2*col+1] + S_in1[vh][lig][2*col+1]) / sqrt(2.);

      k4r = (S_in2[hh][lig][2*col] + S_in2[vv][lig][2*col]) / sqrt(2.);
      k4i = (S_in2[hh][lig][2*col+1] + S_in2[vv][lig][2*col+1]) / sqrt(2.);
      k5r = (S_in2[hh][lig][2*col] - S_in2[vv][lig][2*col]) / sqrt(2.);
      k5i = (S_in2[hh][lig][2*col+1] - S_in2[vv][lig][2*col+1]) / sqrt(2.);
      k6r = (S_in2[hv][lig][2*col] + S_in2[vh][lig][2*col]) / sqrt(2.);
      k6i = (S_in2[hv][lig][2*col+1] + S_in2[vh][lig][2*col+1]) / sqrt(2.);

      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k1r * k3r + k1i * k3i;
          break;
        case 4 :
          M_in[lig][col] = k1i * k3r - k1r * k3i;
          break;
        case 5 :
          M_in[lig][col] = k1r * k4r + k1i * k4i;
          break;
        case 6 :
          M_in[lig][col] = k1i * k4r - k1r * k4i;
          break;
        case 7 :
          M_in[lig][col] = k1r * k5r + k1i * k5i;
          break;
        case 8 :
          M_in[lig][col] = k1i * k5r - k1r * k5i;
          break;
        case 9 :
          M_in[lig][col] = k1r * k6r + k1i * k6i;
          break;
        case 10 :
          M_in[lig][col] = k1i * k6r - k1r * k6i;
          break;
        case 11 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        case 12 :
          M_in[lig][col] = k2r * k3r + k2i * k3i;    
          break;
        case 13 :
          M_in[lig][col] = k2i * k3r - k2r * k3i;
          break;
        case 14 :
          M_in[lig][col] = k2r * k4r + k2i * k4i;
          break;
        case 15 :
          M_in[lig][col] = k2i * k4r - k2r * k4i;
          break;
        case 16 :
          M_in[lig][col] = k2r * k5r + k2i * k5i;
          break;
        case 17 :
          M_in[lig][col] = k2i * k5r - k2r * k5i;
          break;
        case 18 :
          M_in[lig][col] = k2r * k6r + k2i * k6i;
          break;
        case 19 :
          M_in[lig][col] = k2i * k6r - k2r * k6i;
          break;
        case 20 :
          M_in[lig][col] = k3r * k3r + k3i * k3i;
          break;
        case 21 :
          M_in[lig][col] = k3r * k4r + k3i * k4i;
          break;
        case 22 :
          M_in[lig][col] = k3i * k4r - k3r * k4i;
          break;
        case 23 :
          M_in[lig][col] = k3r * k5r + k3i * k5i;
          break;
        case 24 :
          M_in[lig][col] = k3i * k5r - k3r * k5i;
          break;
        case 25 :
          M_in[lig][col] = k3r * k6r + k3i * k6i;
          break;
        case 26 :
          M_in[lig][col] = k3i * k6r - k3r * k6i;
          break;
        case 27 :
          M_in[lig][col] = k4r * k4r + k4i * k4i;
          break;
        case 28 :
          M_in[lig][col] = k4r * k5r + k4i * k5i;
          break;
        case 29 :
          M_in[lig][col] = k4i * k5r - k4r * k5i;
          break;
        case 30 :
          M_in[lig][col] = k4r * k6r + k4i * k6i;
          break;
        case 31 :
          M_in[lig][col] = k4i * k6r - k4r * k6i;
          break;              
        case 32 :
          M_in[lig][col] = k5r * k5r + k5i * k5i;
          break;
        case 33 :
          M_in[lig][col] = k5r * k6r + k5i * k6i;
          break;
        case 34 :
          M_in[lig][col] = k5i * k6r - k5r * k6i;
          break;
        case 35 :
          M_in[lig][col] = k6r * k6r + k6i * k6i;
          break;
        }
    }
  }
  return 1;
}

/********************************************************************
Routine  : SPP_to_C2elt
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of one element of the C2 matrix from
        SPP matrix
********************************************************************/
int SPP_to_C2elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int Ch1=0;
  int Ch2=1;
  float k1r, k1i, k2r, k2i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[Ch1][lig][2*col];
      k1i = S_in[Ch1][lig][2*col+1];
      k2r = S_in[Ch2][lig][2*col];
      k2i = S_in[Ch2][lig][2*col+1];

      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        }            
    }
  }
  return 1;
}

/********************************************************************
Routine  : SPP_to_T2elt
Authors  : Eric POTTIER
Creation : 08/2011
Update  :
*--------------------------------------------------------------------
Description : create an array of one element of the T2 matrix from
        SPP matrix
********************************************************************/
int SPP_to_T2elt(int Np, float ***S_in, float **M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int Ch1=0;
  int Ch2=1;
  float k1r, k1i, k2r, k2i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in[Ch1][lig][2*col]+S_in[Ch2][lig][2*col])/sqrt(2.);
      k1i = (S_in[Ch1][lig][2*col+1]+S_in[Ch2][lig][2*col+1])/sqrt(2.);
      k2r = (S_in[Ch1][lig][2*col]-S_in[Ch2][lig][2*col])/sqrt(2.);
      k2i = (S_in[Ch1][lig][2*col+1]-S_in[Ch2][lig][2*col+1])/sqrt(2.);

      switch(Np) {
        case 0 :
          M_in[lig][col] = k1r * k1r + k1i * k1i;
          break;
        case 1 :
          M_in[lig][col] = k1r * k2r + k1i * k2i;
          break;
        case 2 :
          M_in[lig][col] = k1i * k2r - k1r * k2i;
          break;
        case 3 :
          M_in[lig][col] = k2r * k2r + k2i * k2i;
          break;
        }            
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_SPP
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the SPP matrix from S2 matrix
********************************************************************/
int S2_to_SPP(float ***S_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i;

  if (pp == 1) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        S_in[0][lig][2*col] = S_in[hh][lig][2*col];
        S_in[0][lig][2*col+1] = S_in[hh][lig][2*col+1];
        S_in[1][lig][2*col] = S_in[vh][lig][2*col];
        S_in[1][lig][2*col+1] = S_in[vh][lig][2*col+1];
        }
      }
    }
  if (pp == 2) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        S_in[0][lig][2*col] = S_in[vv][lig][2*col];
        S_in[0][lig][2*col+1] = S_in[vv][lig][2*col+1];
        S_in[1][lig][2*col] = S_in[hv][lig][2*col];
        S_in[1][lig][2*col+1] = S_in[hv][lig][2*col+1];
        }
      }
    }
  if (pp == 3) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        S_in[0][lig][2*col] = S_in[hh][lig][2*col];
        S_in[0][lig][2*col+1] = S_in[hh][lig][2*col+1];
        S_in[1][lig][2*col] = S_in[vv][lig][2*col];
        S_in[1][lig][2*col+1] = S_in[vv][lig][2*col+1];
        }
      }
    }
  /* LHV */
  if (pp == 4) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]-S_in[hv][lig][2*col+1]) / sqrt(2.);
        k1i = (S_in[hh][lig][2*col+1]+S_in[hv][lig][2*col]) / sqrt(2.);
        k2r = (S_in[vh][lig][2*col]-S_in[vv][lig][2*col+1]) / sqrt(2.);
        k2i = (S_in[vh][lig][2*col+1]+S_in[vv][lig][2*col]) / sqrt(2.);
        S_in[0][lig][2*col] = k1r;
        S_in[0][lig][2*col+1] = k1i;
        S_in[1][lig][2*col] = k2r;
        S_in[1][lig][2*col+1] = k2i;
        }
      }
    }
  /* RHV */
  if (pp == 5) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]+S_in[hv][lig][2*col+1]) / sqrt(2.);
        k1i = (S_in[hh][lig][2*col+1]-S_in[hv][lig][2*col]) / sqrt(2.);
        k2r = (S_in[vh][lig][2*col]+S_in[vv][lig][2*col+1]) / sqrt(2.);
        k2i = (S_in[vh][lig][2*col+1]-S_in[vv][lig][2*col]) / sqrt(2.);
        S_in[0][lig][2*col] = k1r;
        S_in[0][lig][2*col+1] = k1i;
        S_in[1][lig][2*col] = k2r;
        S_in[1][lig][2*col+1] = k2i;
        }
      }
    }
  /* Pi4 */
  if (pp == 6) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]+S_in[hv][lig][2*col]) / sqrt(2.);
        k1i = (S_in[hh][lig][2*col+1]+S_in[hv][lig][2*col+1]) / sqrt(2.);
        k2r = (S_in[vh][lig][2*col]+S_in[vv][lig][2*col]) / sqrt(2.);
        k2i = (S_in[vh][lig][2*col+1]+S_in[vv][lig][2*col+1]) / sqrt(2.);
        S_in[0][lig][2*col] = k1r;
        S_in[0][lig][2*col+1] = k1i;
        S_in[1][lig][2*col] = k2r;
        S_in[1][lig][2*col+1] = k2i;
        }
      }
    }

  return 1;
}

/********************************************************************
Routine  : S2_to_IPP
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the IPP matrix from S2 matrix
********************************************************************/
int S2_to_IPP(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;

  /* full */
  if (pp == 0) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = S_in[hh][lig][2*col]*S_in[hh][lig][2*col] + S_in[hh][lig][2*col+1]*S_in[hh][lig][2*col+1];
        M_in[1][lig][col] = S_in[hv][lig][2*col]*S_in[hv][lig][2*col] + S_in[hv][lig][2*col+1]*S_in[hv][lig][2*col+1];
        M_in[2][lig][col] = S_in[vh][lig][2*col]*S_in[vh][lig][2*col] + S_in[vh][lig][2*col+1]*S_in[vh][lig][2*col+1];
        M_in[3][lig][col] = S_in[vv][lig][2*col]*S_in[vv][lig][2*col] + S_in[vv][lig][2*col+1]*S_in[vv][lig][2*col+1];
        }
      }
    }

  if (pp == 4) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = S_in[hh][lig][2*col]*S_in[hh][lig][2*col] + S_in[hh][lig][2*col+1]*S_in[hh][lig][2*col+1];
        M_in[1][lig][col] = S_in[hv][lig][2*col]*S_in[hv][lig][2*col] + S_in[hv][lig][2*col+1]*S_in[hv][lig][2*col+1];
        M_in[2][lig][col] = S_in[vv][lig][2*col]*S_in[vv][lig][2*col] + S_in[vv][lig][2*col+1]*S_in[vv][lig][2*col+1];
        }
      }
    }
  if (pp == 5) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = S_in[hh][lig][2*col]*S_in[hh][lig][2*col] + S_in[hh][lig][2*col+1]*S_in[hh][lig][2*col+1];
        M_in[1][lig][col] = S_in[vh][lig][2*col]*S_in[vh][lig][2*col] + S_in[vh][lig][2*col+1]*S_in[vh][lig][2*col+1];
        }
      }
    }
  if (pp == 6) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = S_in[vv][lig][2*col]*S_in[vv][lig][2*col] + S_in[vv][lig][2*col+1]*S_in[vv][lig][2*col+1];
        M_in[1][lig][col] = S_in[hv][lig][2*col]*S_in[hv][lig][2*col] + S_in[hv][lig][2*col+1]*S_in[hv][lig][2*col+1];
        }
      }
    }
  if (pp == 7) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = S_in[hh][lig][2*col]*S_in[hh][lig][2*col] + S_in[hh][lig][2*col+1]*S_in[hh][lig][2*col+1];
        M_in[1][lig][col] = S_in[vv][lig][2*col]*S_in[vv][lig][2*col] + S_in[vv][lig][2*col+1]*S_in[vv][lig][2*col+1];
        }
      }
    }
  return 1;
}

/********************************************************************
Routine  : S2_to_C2
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the C2 matrix from S2 matrix
********************************************************************/
int S2_to_C2(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)

{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i;

  if (pp == 1) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = S_in[hh][lig][2*col];
        k1i = S_in[hh][lig][2*col+1];
        k2r = S_in[vh][lig][2*col];
        k2i = S_in[vh][lig][2*col+1];
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  if (pp == 2) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = S_in[vv][lig][2*col];
        k1i = S_in[vv][lig][2*col+1];
        k2r = S_in[hv][lig][2*col];
        k2i = S_in[hv][lig][2*col+1];
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  if (pp == 3) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = S_in[hh][lig][2*col];
        k1i = S_in[hh][lig][2*col+1];
        k2r = S_in[vv][lig][2*col];
        k2i = S_in[vv][lig][2*col+1];
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }

  /* LHV */
  if (pp == 4) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]-S_in[hv][lig][2*col+1]) / sqrt(2.);
        k1i = (S_in[hh][lig][2*col+1]+S_in[hv][lig][2*col]) / sqrt(2.);
        k2r = (S_in[vh][lig][2*col]-S_in[vv][lig][2*col+1]) / sqrt(2.);
        k2i = (S_in[vh][lig][2*col+1]+S_in[vv][lig][2*col]) / sqrt(2.);
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  /* RHV */
  if (pp == 5) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]+S_in[hv][lig][2*col+1]) / sqrt(2.);
        k1i = (S_in[hh][lig][2*col+1]-S_in[hv][lig][2*col]) / sqrt(2.);
        k2r = (S_in[vh][lig][2*col]+S_in[vv][lig][2*col+1]) / sqrt(2.);
        k2i = (S_in[vh][lig][2*col+1]-S_in[vv][lig][2*col]) / sqrt(2.);
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  /* PI4 */
  if (pp == 6) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]+S_in[hv][lig][2*col]) / sqrt(2.);
        k1i = (S_in[hh][lig][2*col+1]+S_in[hv][lig][2*col+1]) / sqrt(2.);
        k2r = (S_in[vh][lig][2*col]+S_in[vv][lig][2*col]) / sqrt(2.);
        k2i = (S_in[vh][lig][2*col+1]+S_in[vv][lig][2*col+1]) / sqrt(2.);
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }

  return 1;
}

/********************************************************************
Routine  : S2_to_T2
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the C2 matrix from S2 matrix
********************************************************************/
int S2_to_T2(float ***S_in, float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)

{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i;
  float k1r0, k1i0, k2r0, k2i0;

  if (pp == 1) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]+S_in[vh][lig][2*col])/sqrt(2.);;
        k1i = (S_in[hh][lig][2*col+1]+S_in[vh][lig][2*col+1])/sqrt(2.);;
        k2r = (S_in[hh][lig][2*col]-S_in[vh][lig][2*col])/sqrt(2.);;
        k2i = (S_in[hh][lig][2*col+1]-S_in[vh][lig][2*col+1])/sqrt(2.);;
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  if (pp == 2) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[vv][lig][2*col]+S_in[hv][lig][2*col])/sqrt(2.);;
        k1i = (S_in[vv][lig][2*col+1]+S_in[hv][lig][2*col+1])/sqrt(2.);;
        k2r = (S_in[vv][lig][2*col]-S_in[hv][lig][2*col])/sqrt(2.);;
        k2i = (S_in[vv][lig][2*col+1]-S_in[hv][lig][2*col+1])/sqrt(2.);;
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  if (pp == 3) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r = (S_in[hh][lig][2*col]+S_in[vv][lig][2*col])/sqrt(2.);;
        k1i = (S_in[hh][lig][2*col+1]+S_in[vv][lig][2*col+1])/sqrt(2.);;
        k2r = (S_in[hh][lig][2*col]-S_in[vv][lig][2*col])/sqrt(2.);;
        k2i = (S_in[hh][lig][2*col+1]-S_in[vv][lig][2*col+1])/sqrt(2.);;
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }

  /* LHV */
  if (pp == 4) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r0 = (S_in[hh][lig][2*col]-S_in[hv][lig][2*col+1]) / sqrt(2.);
        k1i0 = (S_in[hh][lig][2*col+1]+S_in[hv][lig][2*col]) / sqrt(2.);
        k2r0 = (S_in[vh][lig][2*col]-S_in[vv][lig][2*col+1]) / sqrt(2.);
        k2i0 = (S_in[vh][lig][2*col+1]+S_in[vv][lig][2*col]) / sqrt(2.);
        k1r = (k1r0 + k2r0)/sqrt(2.);
        k1i = (k1i0 + k2i0)/sqrt(2.);
        k2r = (k1r0 - k2r0)/sqrt(2.);
        k2i = (k1i0 - k2i0)/sqrt(2.);
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  /* RHV */
  if (pp == 5) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r0 = (S_in[hh][lig][2*col]+S_in[hv][lig][2*col+1]) / sqrt(2.);
        k1i0 = (S_in[hh][lig][2*col+1]-S_in[hv][lig][2*col]) / sqrt(2.);
        k2r0 = (S_in[vh][lig][2*col]+S_in[vv][lig][2*col+1]) / sqrt(2.);
        k2i0 = (S_in[vh][lig][2*col+1]-S_in[vv][lig][2*col]) / sqrt(2.);
        k1r = (k1r0 + k2r0)/sqrt(2.);
        k1i = (k1i0 + k2i0)/sqrt(2.);
        k2r = (k1r0 - k2r0)/sqrt(2.);
        k2i = (k1i0 - k2i0)/sqrt(2.);
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }
  /* PI4 */
  if (pp == 6) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        k1r0 = (S_in[hh][lig][2*col]+S_in[hv][lig][2*col]) / sqrt(2.);
        k1i0 = (S_in[hh][lig][2*col+1]+S_in[hv][lig][2*col+1]) / sqrt(2.);
        k2r0 = (S_in[vh][lig][2*col]+S_in[vv][lig][2*col]) / sqrt(2.);
        k2i0 = (S_in[vh][lig][2*col+1]+S_in[vv][lig][2*col+1]) / sqrt(2.);
        k1r = (k1r0 + k2r0)/sqrt(2.);
        k1i = (k1i0 + k2i0)/sqrt(2.);
        k2r = (k1r0 - k2r0)/sqrt(2.);
        k2i = (k1i0 - k2i0)/sqrt(2.);
        M_in[0][lig][col] = k1r * k1r + k1i * k1i;
        M_in[1][lig][col] = k1r * k2r + k1i * k2i;
        M_in[2][lig][col] = k1i * k2r - k1r * k2i;
        M_in[3][lig][col] = k2r * k2r + k2i * k2i;
        }
      }
    }

  return 1;
}

/********************************************************************
Routine  : S2_to_C3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C3 matrix from S2 matrix
********************************************************************/
int S2_to_C3(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[hh][lig][2*col];
      k1i = S_in[hh][lig][2*col+1];
      k2r = (S_in[hv][lig][2*col] + S_in[vh][lig][2*col]) / sqrt(2.);
      k2i = (S_in[hv][lig][2*col+1] + S_in[vh][lig][2*col+1]) / sqrt(2.);
      k3r = S_in[vv][lig][2*col];
      k3i = S_in[vv][lig][2*col+1];
      
      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k1r * k3r + k1i * k3i;
      M_in[4][lig][col] = k1i * k3r - k1r * k3i;
      M_in[5][lig][col] = k2r * k2r + k2i * k2i;
      M_in[6][lig][col] = k2r * k3r + k2i * k3i;
      M_in[7][lig][col] = k2i * k3r - k2r * k3i;
      M_in[8][lig][col] = k3r * k3r + k3i * k3i;    
      }
    }
  return 1;
}

/********************************************************************
Routine  : S2_to_T3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T3 matrix from S2 matrix
********************************************************************/
int S2_to_T3(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i;

  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in[hh][lig][2*col] + S_in[vv][lig][2*col]) / sqrt(2.);
      k1i = (S_in[hh][lig][2*col+1] + S_in[vv][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in[hh][lig][2*col] - S_in[vv][lig][2*col]) / sqrt(2.);
      k2i = (S_in[hh][lig][2*col+1] - S_in[vv][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in[hv][lig][2*col] + S_in[vh][lig][2*col]) / sqrt(2.);
      k3i = (S_in[hv][lig][2*col+1] + S_in[vh][lig][2*col+1]) / sqrt(2.);
      
      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k1r * k3r + k1i * k3i;
      M_in[4][lig][col] = k1i * k3r - k1r * k3i;
      M_in[5][lig][col] = k2r * k2r + k2i * k2i;
      M_in[6][lig][col] = k2r * k3r + k2i * k3i;
      M_in[7][lig][col] = k2i * k3r - k2r * k3i;
      M_in[8][lig][col] = k3r * k3r + k3i * k3i;    
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_C4
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C4 matrix from S2 matrix
********************************************************************/
int S2_to_C4(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[hh][lig][2*col];
      k1i = S_in[hh][lig][2*col+1];
      k2r = S_in[hv][lig][2*col];
      k2i = S_in[hv][lig][2*col+1];
      k3r = S_in[vh][lig][2*col];
      k3i = S_in[vh][lig][2*col+1];
      k4r = S_in[vv][lig][2*col];
      k4i = S_in[vv][lig][2*col+1];

      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k1r * k3r + k1i * k3i;
      M_in[4][lig][col] = k1i * k3r - k1r * k3i;
      M_in[5][lig][col] = k1r * k4r + k1i * k4i;
      M_in[6][lig][col] = k1i * k4r - k1r * k4i;
      M_in[7][lig][col] = k2r * k2r + k2i * k2i;
      M_in[8][lig][col] = k2r * k3r + k2i * k3i;    
      M_in[9][lig][col] = k2i * k3r - k2r * k3i;
      M_in[10][lig][col] = k2r * k4r + k2i * k4i;
      M_in[11][lig][col] = k2i * k4r - k2r * k4i;
      M_in[12][lig][col] = k3r * k3r + k3i * k3i;
      M_in[13][lig][col] = k3r * k4r + k3i * k4i;
      M_in[14][lig][col] = k3i * k4r - k3r * k4i;
      M_in[15][lig][col] = k4r * k4r + k4i * k4i;
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_T4
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T4 matrix from S2 matrix
********************************************************************/
int S2_to_T4(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in[hh][lig][2*col] + S_in[vv][lig][2*col]) / sqrt(2.);
      k1i = (S_in[hh][lig][2*col+1] + S_in[vv][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in[hh][lig][2*col] - S_in[vv][lig][2*col]) / sqrt(2.);
      k2i = (S_in[hh][lig][2*col+1] - S_in[vv][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in[hv][lig][2*col] + S_in[vh][lig][2*col]) / sqrt(2.);
      k3i = (S_in[hv][lig][2*col+1] + S_in[vh][lig][2*col+1]) / sqrt(2.);
      k4r = (S_in[vh][lig][2*col+1] - S_in[hv][lig][2*col+1]) / sqrt(2.);
      k4i = (S_in[hv][lig][2*col] - S_in[vh][lig][2*col]) / sqrt(2.);

      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k1r * k3r + k1i * k3i;
      M_in[4][lig][col] = k1i * k3r - k1r * k3i;
      M_in[5][lig][col] = k1r * k4r + k1i * k4i;
      M_in[6][lig][col] = k1i * k4r - k1r * k4i;
      M_in[7][lig][col] = k2r * k2r + k2i * k2i;
      M_in[8][lig][col] = k2r * k3r + k2i * k3i;    
      M_in[9][lig][col] = k2i * k3r - k2r * k3i;
      M_in[10][lig][col] = k2r * k4r + k2i * k4i;
      M_in[11][lig][col] = k2i * k4r - k2r * k4i;
      M_in[12][lig][col] = k3r * k3r + k3i * k3i;
      M_in[13][lig][col] = k3r * k4r + k3i * k4i;
      M_in[14][lig][col] = k3i * k4r - k3r * k4i;
      M_in[15][lig][col] = k4r * k4r + k4i * k4i;
    }
  }
  return 1;
}

/********************************************************************
Routine  : S2_to_T6
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T6 matrix from 2*S2 matrix
********************************************************************/
int S2_to_T6(float ***S_in1, float ***S_in2, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int hh=0;
  int hv=1;
  int vh=2;
  int vv=3;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i, k5r, k5i, k6r, k6i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in1[hh][lig][2*col] + S_in1[vv][lig][2*col]) / sqrt(2.);
      k1i = (S_in1[hh][lig][2*col+1] + S_in1[vv][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in1[hh][lig][2*col] - S_in1[vv][lig][2*col]) / sqrt(2.);
      k2i = (S_in1[hh][lig][2*col+1] - S_in1[vv][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in1[hv][lig][2*col] + S_in1[vh][lig][2*col]) / sqrt(2.);
      k3i = (S_in1[hv][lig][2*col+1] + S_in1[vh][lig][2*col+1]) / sqrt(2.);

      k4r = (S_in2[hh][lig][2*col] + S_in2[vv][lig][2*col]) / sqrt(2.);
      k4i = (S_in2[hh][lig][2*col+1] + S_in2[vv][lig][2*col+1]) / sqrt(2.);
      k5r = (S_in2[hh][lig][2*col] - S_in2[vv][lig][2*col]) / sqrt(2.);
      k5i = (S_in2[hh][lig][2*col+1] - S_in2[vv][lig][2*col+1]) / sqrt(2.);
      k6r = (S_in2[hv][lig][2*col] + S_in2[vh][lig][2*col]) / sqrt(2.);
      k6i = (S_in2[hv][lig][2*col+1] + S_in2[vh][lig][2*col+1]) / sqrt(2.);

      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k1r * k3r + k1i * k3i;
      M_in[4][lig][col] = k1i * k3r - k1r * k3i;
      M_in[5][lig][col] = k1r * k4r + k1i * k4i;
      M_in[6][lig][col] = k1i * k4r - k1r * k4i;
      M_in[7][lig][col] = k1r * k5r + k1i * k5i;
      M_in[8][lig][col] = k1i * k5r - k1r * k5i;
      M_in[9][lig][col] = k1r * k6r + k1i * k6i;
      M_in[10][lig][col] = k1i * k6r - k1r * k6i;
      M_in[11][lig][col] = k2r * k2r + k2i * k2i;
      M_in[12][lig][col] = k2r * k3r + k2i * k3i;
      M_in[13][lig][col] = k2i * k3r - k2r * k3i;
      M_in[14][lig][col] = k2r * k4r + k2i * k4i;
      M_in[15][lig][col] = k2i * k4r - k2r * k4i;
      M_in[16][lig][col] = k2r * k5r + k2i * k5i;
      M_in[17][lig][col] = k2i * k5r - k2r * k5i;
      M_in[18][lig][col] = k2r * k6r + k2i * k6i;
      M_in[19][lig][col] = k2i * k6r - k2r * k6i;
      M_in[20][lig][col] = k3r * k3r + k3i * k3i;
      M_in[21][lig][col] = k3r * k4r + k3i * k4i;
      M_in[22][lig][col] = k3i * k4r - k3r * k4i;
      M_in[23][lig][col] = k3r * k5r + k3i * k5i;
      M_in[24][lig][col] = k3i * k5r - k3r * k5i;
      M_in[25][lig][col] = k3r * k6r + k3i * k6i;
      M_in[26][lig][col] = k3i * k6r - k3r * k6i;
      M_in[27][lig][col] = k4r * k4r + k4i * k4i;
      M_in[28][lig][col] = k4r * k5r + k4i * k5i;
      M_in[29][lig][col] = k4i * k5r - k4r * k5i;
      M_in[30][lig][col] = k4r * k6r + k4i * k6i;
      M_in[31][lig][col] = k4i * k6r - k4r * k6i;
      M_in[32][lig][col] = k5r * k5r + k5i * k5i;
      M_in[33][lig][col] = k5r * k6r + k5i * k6i;
      M_in[34][lig][col] = k5i * k6r - k5r * k6i;
      M_in[35][lig][col] = k6r * k6r + k6i * k6i;
    }
  }
  return 1;
}

/********************************************************************
Routine  : SPP_to_C2
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C2 matrix from SPP matrix
********************************************************************/
int SPP_to_C2(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int Ch1=0;
  int Ch2=1;
  float k1r, k1i, k2r, k2i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[Ch1][lig][2*col];
      k1i = S_in[Ch1][lig][2*col+1];
      k2r = S_in[Ch2][lig][2*col];
      k2i = S_in[Ch2][lig][2*col+1];

      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k2r * k2r + k2i * k2i;
    }
  }
  return 1;
}


/********************************************************************
Routine  : SPP_to_IPP
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the IPP matrix from SPP matrix
********************************************************************/
int SPP_to_IPP(float ***S_in, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int Ch1=0;
  int Ch2=1;
  float k1r, k1i, k2r, k2i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = S_in[Ch1][lig][2*col];
      k1i = S_in[Ch1][lig][2*col+1];
      k2r = S_in[Ch2][lig][2*col];
      k2i = S_in[Ch2][lig][2*col+1];

      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k2r * k2r + k2i * k2i;
    }
  }
  return 1;
}

/********************************************************************
Routine  : C2_to_IPP
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the IPP matrix from C3 matrix
********************************************************************/
int C2_to_IPP(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;

  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      M_in[0][lig][col] = M_in[C211][lig][col];
      M_in[1][lig][col] = M_in[C222][lig][col];
      }
    }

  return 1;
}

/********************************************************************
Routine  : C4_to_T4
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T4 matrix from C4 matrix
********************************************************************/
int C4_to_T4(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C13_re, C13_im, C14_re, C14_im;
  float C22, C23_re, C23_im, C24_re, C24_im;
  float C33, C34_re, C34_im;
  float C44;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C411][lig][col]; 
      C12_re = M_in[C412_re][lig][col]; C12_im = M_in[C412_im][lig][col];
      C13_re = M_in[C413_re][lig][col]; C13_im = M_in[C413_im][lig][col];
      C14_re = M_in[C414_re][lig][col]; C14_im = M_in[C414_im][lig][col];
      C22 = M_in[C422][lig][col]; 
      C23_re = M_in[C423_re][lig][col]; C23_im = M_in[C423_im][lig][col];
      C24_re = M_in[C424_re][lig][col]; C24_im = M_in[C424_im][lig][col];
      C33 = M_in[C433][lig][col]; 
      C34_re = M_in[C434_re][lig][col]; C34_im = M_in[C434_im][lig][col];
      C44 = M_in[C444][lig][col]; 
      
      M_in[T411][lig][col] = (C11 + 2 * C14_re + C44) / 2.;
      M_in[T412_re][lig][col] = (C11 - C44) / 2.;
      M_in[T412_im][lig][col] = (-2 * C14_im) / 2.;
      M_in[T413_re][lig][col] = (C12_re + C13_re + C24_re + C34_re) / 2.;
      M_in[T413_im][lig][col] = (C12_im + C13_im - C24_im - C34_im) / 2.;
      M_in[T414_re][lig][col] = (C12_im - C13_im - C24_im + C34_im) / 2.;
      M_in[T414_im][lig][col] = (-C12_re + C13_re - C24_re + C34_re) / 2.;
      M_in[T422][lig][col] = (C11 - 2 * C14_re + C44) / 2.;
      M_in[T423_re][lig][col] = (C12_re + C13_re - C24_re - C34_re) / 2.;
      M_in[T423_im][lig][col] = (C12_im + C13_im + C24_im + C34_im) / 2.;
      M_in[T424_re][lig][col] = (C12_im - C13_im + C24_im - C34_im) / 2.;
      M_in[T424_im][lig][col] = (-C12_re + C13_re + C24_re - C34_re) / 2.;
      M_in[T433][lig][col] = (C22 + C33 + 2 * C23_re) / 2.;
      M_in[T434_re][lig][col] = (-2 * C23_im) / 2.;
      M_in[T434_im][lig][col] = (-C22 + C33) / 2.;
      M_in[T444][lig][col] = (C22 + C33 - 2 * C23_re) / 2.;
      }
    }

  return 1;
}

/********************************************************************
Routine  : C4_to_C3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*-------------------------------------------------------------------
Description : create an array of the C3 matrix from C4 matrix
********************************************************************/
int C4_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C13_re, C13_im, C14_re, C14_im;
  float C22, C23_re, C24_re, C24_im;
  float C33, C34_re, C34_im;
  float C44;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C411][lig][col]; 
      C12_re = M_in[C412_re][lig][col]; C12_im = M_in[C412_im][lig][col];
      C13_re = M_in[C413_re][lig][col]; C13_im = M_in[C413_im][lig][col];
      C14_re = M_in[C414_re][lig][col]; C14_im = M_in[C414_im][lig][col];
      C22 = M_in[C422][lig][col]; 
      C23_re = M_in[C423_re][lig][col]; //C23_im = M_in[C423_im][lig][col];
      C24_re = M_in[C424_re][lig][col]; C24_im = M_in[C424_im][lig][col];
      C33 = M_in[C433][lig][col]; 
      C34_re = M_in[C434_re][lig][col]; C34_im = M_in[C434_im][lig][col];
      C44 = M_in[C444][lig][col]; 

      M_in[C311][lig][col] = C11;
      M_in[C312_re][lig][col] = (C12_re + C13_re) / sqrt(2);
      M_in[C312_im][lig][col] = (C12_im + C13_im) / sqrt(2);
      M_in[C313_re][lig][col] = C14_re;
      M_in[C313_im][lig][col] = C14_im;
      M_in[C322][lig][col] = (C22 + C33 + 2 * C23_re) / 2;
      M_in[C323_re][lig][col] = (C24_re + C34_re) / sqrt(2);
      M_in[C323_im][lig][col] = (C24_im + C34_im) / sqrt(2);
      M_in[C333][lig][col] = C44;
      }
    }

  return 1;
}

/********************************************************************
Routine  : C4_to_T3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T3 matrix from C4 matrix
********************************************************************/
int C4_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C13_re, C13_im;
  float C22, C23_re, C23_im, C33;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C411][lig][col];
      C12_re = (M_in[C412_re][lig][col] + M_in[C413_re][lig][col]) / sqrt(2);
      C12_im = (M_in[C412_im][lig][col] + M_in[C413_im][lig][col]) / sqrt(2);
      C13_re = M_in[C414_re][lig][col];
      C13_im = M_in[C414_im][lig][col];
      C22 = (M_in[C422][lig][col] + M_in[C433][lig][col] + 2 * M_in[C423_re][lig][col]) / 2;
      C23_re = (M_in[C424_re][lig][col] + M_in[C434_re][lig][col]) / sqrt(2);
      C23_im = (M_in[C424_im][lig][col] + M_in[C434_im][lig][col]) / sqrt(2);
      C33 = M_in[C444][lig][col];
      
      M_in[T311][lig][col] = (C11 + 2 * C13_re + C33) / 2;
      M_in[T312_re][lig][col] = (C11 - C33) / 2;
      M_in[T312_im][lig][col] = -C13_im;
      M_in[T313_re][lig][col] = (C12_re + C23_re) / sqrt(2);
      M_in[T313_im][lig][col] = (C12_im - C23_im) / sqrt(2);
      M_in[T322][lig][col] = (C11 - 2 * C13_re + C33) / 2;
      M_in[T323_re][lig][col] = (C12_re - C23_re) / sqrt(2);
      M_in[T323_im][lig][col] = (C12_im + C23_im) / sqrt(2);
      M_in[T333][lig][col] = C22;
      }
    }

  return 1;
}

/********************************************************************
Routine  : C4_to_C2
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the C2 matrix from C4 matrix
********************************************************************/
int C4_to_C2(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C13_re, C13_im, C14_re, C14_im;
  float C22, C23_re, C23_im, C24_re, C24_im;
  float C33, C34_re, C34_im;
  float C44;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C411][lig][col]; 
      C12_re = M_in[C412_re][lig][col]; C12_im = M_in[C412_im][lig][col];
      C13_re = M_in[C413_re][lig][col]; C13_im = M_in[C413_im][lig][col];
      C14_re = M_in[C414_re][lig][col]; C14_im = M_in[C414_im][lig][col];
      C22 = M_in[C422][lig][col]; 
      C23_re = M_in[C423_re][lig][col]; C23_im = M_in[C423_im][lig][col];
      C24_re = M_in[C424_re][lig][col]; C24_im = M_in[C424_im][lig][col];
      C33 = M_in[C433][lig][col]; 
      C34_re = M_in[C434_re][lig][col]; C34_im = M_in[C434_im][lig][col];
      C44 = M_in[C444][lig][col]; 

      if (pp == 1) {
        M_in[C211][lig][col] = C11;
        M_in[C212_re][lig][col] = C13_re;
        M_in[C212_im][lig][col] = C13_im;
        M_in[C222][lig][col] = C33;
        }
      if (pp == 2) {
        M_in[C211][lig][col] = C44;
        M_in[C212_re][lig][col] = C24_re;
        M_in[C212_im][lig][col] = -C24_im;
        M_in[C222][lig][col] = C22;
        }
      if (pp == 3) {
        M_in[C211][lig][col] = C11;
        M_in[C212_re][lig][col] = C14_re;
        M_in[C212_im][lig][col] = C14_im;
        M_in[C222][lig][col] = C44;
        }
      /* LHV */
      if (pp == 4) {
        M_in[C211][lig][col] = C11/2. + C22/2. + C12_im;
        M_in[C212_re][lig][col] = (C13_re + C24_re - C23_im + C14_im)/2.;
        M_in[C212_im][lig][col] = (C13_im + C24_im + C23_re - C14_re)/2.;
        M_in[C222][lig][col] = C33/2. + C44/2. + C34_im;
        }
      /* RHV */
      if (pp == 5) {
        M_in[C211][lig][col] = C11/2. + C22/2. - C12_im;
        M_in[C212_re][lig][col] = (C13_re + C24_re + C23_im - C14_im)/2.;
        M_in[C212_im][lig][col] = (C13_im + C24_im - C23_re + C14_re)/2.;
        M_in[C222][lig][col] = C33/2. + C44/2. - C34_im;
        }
      /* Pi4 */
      if (pp == 6) {
        M_in[C211][lig][col] = C11/2. + C22/2. + C12_re;
        M_in[C212_re][lig][col] = (C13_re + C14_re + C23_re + C24_re)/2.;
        M_in[C212_im][lig][col] = (C13_im + C14_im + C23_im + C24_im)/2.;
        M_in[C222][lig][col] = C33/2. + C44/2. + C34_re;
        }
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : C4_to_IPP
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the IPP matrix from C4 matrix
********************************************************************/
int C4_to_IPP(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;

  /* full */
  if (pp == 0) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C411][lig][col];
        M_in[1][lig][col] = M_in[C422][lig][col];
        M_in[2][lig][col] = M_in[C433][lig][col];
        M_in[3][lig][col] = M_in[C444][lig][col];
        }
      }
    }

  if (pp == 4) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C411][lig][col];
        M_in[1][lig][col] = (M_in[C422][lig][col] + M_in[C433][lig][col]) / 2.;
        M_in[2][lig][col] = M_in[C444][lig][col];
        }
      }
    }
  if (pp == 5) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C411][lig][col];
        M_in[1][lig][col] = M_in[C433][lig][col];
        }
      }
    }
  if (pp == 6) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C444][lig][col];
        M_in[1][lig][col] = M_in[C422][lig][col];
        }
      }
    }
  if (pp == 7) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C411][lig][col];
        M_in[1][lig][col] = M_in[C444][lig][col];
        }
      }
    }
  return 1;
}

/********************************************************************
Routine  : T4_to_C4
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C4 matrix from T4 matrix
********************************************************************/
int T4_to_C4(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float T11, T12_re, T12_im, T13_re, T13_im, T14_re, T14_im;
  float T22, T23_re, T23_im, T24_re, T24_im;
  float T33, T34_re, T34_im;
  float T44;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      T11 = M_in[T411][lig][col]; 
      T12_re = M_in[T412_re][lig][col]; T12_im = M_in[T412_im][lig][col];
      T13_re = M_in[T413_re][lig][col]; T13_im = M_in[T413_im][lig][col];
      T14_re = M_in[T414_re][lig][col]; T14_im = M_in[T414_im][lig][col];
      T22 = M_in[T422][lig][col]; 
      T23_re = M_in[T423_re][lig][col]; T23_im = M_in[T423_im][lig][col];
      T24_re = M_in[T424_re][lig][col]; T24_im = M_in[T424_im][lig][col];
      T33 = M_in[T433][lig][col]; 
      T34_re = M_in[T434_re][lig][col]; T34_im = M_in[T434_im][lig][col];
      T44 = M_in[T444][lig][col]; 
 
      M_in[C411][lig][col] = (T11 + 2 * T12_re + T22) / 2.;
      M_in[C412_re][lig][col] = (T13_re + T23_re - T14_im - T24_im) / 2.;
      M_in[C412_im][lig][col] = (T13_im + T23_im + T14_re + T24_re) / 2.;
      M_in[C413_re][lig][col] = (T13_re + T23_re + T14_im + T24_im) / 2.;
      M_in[C413_im][lig][col] = (T13_im + T23_im - T14_re - T24_re) / 2.;
      M_in[C414_re][lig][col] = (T11 - T22) / 2.;
      M_in[C414_im][lig][col] = (-2 * T12_im) / 2.;
      M_in[C422][lig][col] = (T33 - 2 * T34_im + T44) / 2.;
      M_in[C423_re][lig][col] = (T33 - T44) / 2.;
      M_in[C423_im][lig][col] = (-2 * T34_re) / 2.;
      M_in[C424_re][lig][col] = (T13_re - T23_re - T14_im + T24_im) / 2.;
      M_in[C424_im][lig][col] = (-T13_im + T23_im - T14_re + T24_re) / 2.;
      M_in[C433][lig][col] = (T33 + T44 + 2 * T34_im) / 2.;
      M_in[C434_re][lig][col] = (T13_re - T23_re + T14_im - T24_im) / 2.;
      M_in[C434_im][lig][col] = (-T13_im + T23_im + T14_re - T24_re) / 2.;
      M_in[C444][lig][col] = (T11 - 2 * T12_re + T22) / 2;
      }
    }

  return 1;
}

/********************************************************************
Routine  : T4_to_C3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C3 matrix from T4 matrix
********************************************************************/
int T4_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float T11, T12_re, T12_im, T13_re, T13_im;
  float T22, T23_re, T23_im;
  float T33;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      T11 = M_in[T411][lig][col]; 
      T12_re = M_in[T412_re][lig][col]; T12_im = M_in[T412_im][lig][col];
      T13_re = M_in[T413_re][lig][col]; T13_im = M_in[T413_im][lig][col];
      T22 = M_in[T422][lig][col]; 
      T23_re = M_in[T423_re][lig][col]; T23_im = M_in[T423_im][lig][col];
      T33 = M_in[T433][lig][col]; 

      M_in[C311][lig][col] = (T11 + 2 * T12_re + T22) / 2;
      M_in[C312_re][lig][col] = (T13_re + T23_re) / sqrt(2);
      M_in[C312_im][lig][col] = (T13_im + T23_im) / sqrt(2);
      M_in[C313_re][lig][col] = (T11 - T22) / 2;
      M_in[C313_im][lig][col] = -T12_im;
      M_in[C322][lig][col] = T33;
      M_in[C323_re][lig][col] = (T13_re - T23_re) / sqrt(2);
      M_in[C323_im][lig][col] = (-T13_im + T23_im) / sqrt(2);
      M_in[C333][lig][col] = (T11 - 2 * T12_re + T22) / 2;
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : T4_to_T3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T3 matrix from T4 matrix
********************************************************************/
int T4_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float T11, T12_re, T12_im, T13_re, T13_im;
  float T22, T23_re, T23_im;
  float T33;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      T11 = M_in[T411][lig][col]; 
      T12_re = M_in[T412_re][lig][col]; T12_im = M_in[T412_im][lig][col];
      T13_re = M_in[T413_re][lig][col]; T13_im = M_in[T413_im][lig][col];
      T22 = M_in[T422][lig][col]; 
      T23_re = M_in[T423_re][lig][col]; T23_im = M_in[T423_im][lig][col];
      T33 = M_in[T433][lig][col]; 

      M_in[T311][lig][col] = T11;
      M_in[T312_re][lig][col] = T12_re;
      M_in[T312_im][lig][col] = T12_im;
      M_in[T313_re][lig][col] = T13_re;
      M_in[T313_im][lig][col] = T13_im;
      M_in[T322][lig][col] = T22;
      M_in[T323_re][lig][col] = T23_re;
      M_in[T323_im][lig][col] = T23_im;
      M_in[T333][lig][col] = T33;
      }
    }

  return 1;
}

/********************************************************************
Routine  : C3_to_C2
Authors  : Eric POTTIER
Creation : 08/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the C2 matrix from C3 matrix
********************************************************************/
int C3_to_C2(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C13_re, C13_im;
  float C22, C23_re, C23_im, C33;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C311][lig][col];
      C12_re = M_in[C312_re][lig][col]; C12_im = M_in[C312_im][lig][col];
      C13_re = M_in[C313_re][lig][col]; C13_im = M_in[C313_im][lig][col];
      C22 = M_in[C322][lig][col];
      C23_re = M_in[C323_re][lig][col]; C23_im = M_in[C323_im][lig][col];
      C33 = M_in[C333][lig][col];

      if (pp == 1) {
        M_in[C211][lig][col] = C11;
        M_in[C212_re][lig][col] = C12_re / sqrt(2.);
        M_in[C212_im][lig][col] = C12_im / sqrt(2.);
        M_in[C222][lig][col] = C22 / 2.;
        }
      if (pp == 2) {
        M_in[C211][lig][col] = C33;
        M_in[C212_re][lig][col] = C23_re / sqrt(2.);
        M_in[C212_im][lig][col] = -C23_im / sqrt(2.);
        M_in[C222][lig][col] = C22 / 2.;
        }
      if (pp == 3) {
        M_in[C211][lig][col] = C11;
        M_in[C212_re][lig][col] = C13_re;
        M_in[C212_im][lig][col] = C13_im;
        M_in[C222][lig][col] = C33;
        }
      /* LHV */
      if (pp == 4) {
        M_in[C211][lig][col] = C11/2. + C22/4. + C12_im/sqrt(2.);
        M_in[C212_re][lig][col] = (C12_re + C23_re)/(2.*sqrt(2.)) + C13_im/2.;
        M_in[C212_im][lig][col] = (C12_im + C23_im)/(2.*sqrt(2.)) + C22/4. - C13_re/2.;
        M_in[C222][lig][col] = C22/4. + C33/2. + C23_im/sqrt(2.);
        }
      /* RHV */
      if (pp == 5) {
        M_in[C211][lig][col] = C11/2. + C22/4. - C12_im/sqrt(2.);
        M_in[C212_re][lig][col] = (C12_re + C23_re)/(2.*sqrt(2.)) - C13_im/2.;
        M_in[C212_im][lig][col] = (C12_im + C23_im)/(2.*sqrt(2.)) - C22/4. + C13_re/2.;
        M_in[C222][lig][col] = C22/4. + C33/2. - C23_im/sqrt(2.);
        }
      /* Pi4 */
      if (pp == 6) {
        M_in[C211][lig][col] = C11/2. + C22/4. + C12_re/sqrt(2.);
        M_in[C212_re][lig][col] = (C12_re + C23_re)/(2.*sqrt(2.)) + C22/4. + C13_re/2.;
        M_in[C212_im][lig][col] = (C12_im + C23_im)/(2.*sqrt(2.)) + C13_im/2.;
        M_in[C222][lig][col] = C22/4. + C33/2. + C23_re/sqrt(2.);
        }
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : C3_to_T3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the T3 matrix from C3 matrix
********************************************************************/
int C3_to_T3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C13_re, C13_im;
  float C22, C23_re, C23_im, C33;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C311][lig][col];
      C12_re = M_in[C312_re][lig][col]; C12_im = M_in[C312_im][lig][col];
      C13_re = M_in[C313_re][lig][col]; C13_im = M_in[C313_im][lig][col];
      C22 = M_in[C322][lig][col];
      C23_re = M_in[C323_re][lig][col]; C23_im = M_in[C323_im][lig][col];
      C33 = M_in[C333][lig][col];

      M_in[T311][lig][col] = (C11 + 2 * C13_re + C33) / 2;
      M_in[T312_re][lig][col] = (C11 - C33) / 2;
      M_in[T312_im][lig][col] = -C13_im;
      M_in[T313_re][lig][col] = (C12_re + C23_re) / sqrt(2);
      M_in[T313_im][lig][col] = (C12_im - C23_im) / sqrt(2);
      M_in[T322][lig][col] = (C11 - 2 * C13_re + C33) / 2;
      M_in[T323_re][lig][col] = (C12_re - C23_re) / sqrt(2);
      M_in[T323_im][lig][col] = (C12_im + C23_im) / sqrt(2);
      M_in[T333][lig][col] = C22;
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : C3_to_IPP
Authors  : Eric POTTIER
Creation : 03/2010
Update  :
*--------------------------------------------------------------------
Description : create an array of the IPP matrix from C3 matrix
********************************************************************/
int C3_to_IPP(float ***M_in, int pp, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;

  if (pp == 4) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C311][lig][col];
        M_in[1][lig][col] = M_in[C322][lig][col] / 2.;
        M_in[2][lig][col] = M_in[C333][lig][col];
        }
      }
    }
  if (pp == 5) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C311][lig][col];
        M_in[1][lig][col] = M_in[C322][lig][col] / 2.;
        }
      }
    }
  if (pp == 6) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C333][lig][col] / 2.;
        M_in[1][lig][col] = M_in[C322][lig][col];
        }
      }
    }
  if (pp == 7) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        M_in[0][lig][col] = M_in[C311][lig][col];
        M_in[1][lig][col] = M_in[C333][lig][col];
        }
      }
    }
  return 1;
}

/********************************************************************
Routine  : T3_to_C3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C3 matrix from T3 matrix
********************************************************************/
int T3_to_C3(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float T11, T12_re, T12_im, T13_re, T13_im;
  float T22, T23_re, T23_im;
  float T33;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      T11 = M_in[T311][lig][col]; 
      T12_re = M_in[T312_re][lig][col]; T12_im = M_in[T312_im][lig][col];
      T13_re = M_in[T313_re][lig][col]; T13_im = M_in[T313_im][lig][col];
      T22 = M_in[T322][lig][col]; 
      T23_re = M_in[T323_re][lig][col]; T23_im = M_in[T323_im][lig][col];
      T33 = M_in[T333][lig][col]; 

      M_in[C311][lig][col] = (T11 + 2 * T12_re + T22) / 2;
      M_in[C312_re][lig][col] = (T13_re + T23_re) / sqrt(2);
      M_in[C312_im][lig][col] = (T13_im + T23_im) / sqrt(2);
      M_in[C313_re][lig][col] = (T11 - T22) / 2;
      M_in[C313_im][lig][col] = -T12_im;
      M_in[C322][lig][col] = T33;
      M_in[C323_re][lig][col] = (T13_re - T23_re) / sqrt(2);
      M_in[C323_im][lig][col] = (-T13_im + T23_im) / sqrt(2);
      M_in[C333][lig][col] = (T11 - 2 * T12_re + T22) / 2;
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : T6_to_C3
Authors  : Eric POTTIER
Creation : 08/2009
Update  :
*--------------------------------------------------------------------
Description : create an array of the C3 matrix from T3 matrix
********************************************************************/
int T6_to_C3(float ***M_in, int MasterSlave, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float T11, T12_re, T12_im, T13_re, T13_im;
  float T22, T23_re, T23_im;
  float T33;
  
  if (MasterSlave == 1) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        T11 = M_in[T611][lig][col]; 
        T12_re = M_in[T612_re][lig][col]; T12_im = M_in[T612_im][lig][col];
        T13_re = M_in[T613_re][lig][col]; T13_im = M_in[T613_im][lig][col];
        T22 = M_in[T622][lig][col]; 
        T23_re = M_in[T623_re][lig][col]; T23_im = M_in[T623_im][lig][col];
        T33 = M_in[T633][lig][col]; 
        M_in[C311][lig][col] = (T11 + 2 * T12_re + T22) / 2;
        M_in[C312_re][lig][col] = (T13_re + T23_re) / sqrt(2);
        M_in[C312_im][lig][col] = (T13_im + T23_im) / sqrt(2);
        M_in[C313_re][lig][col] = (T11 - T22) / 2;
        M_in[C313_im][lig][col] = -T12_im;
        M_in[C322][lig][col] = T33;
        M_in[C323_re][lig][col] = (T13_re - T23_re) / sqrt(2);
        M_in[C323_im][lig][col] = (-T13_im + T23_im) / sqrt(2);
        M_in[C333][lig][col] = (T11 - 2 * T12_re + T22) / 2;
        }
      }
    }
  if (MasterSlave == 2) {
    for (lig = 0; lig < Nlig + NwinLig; lig++) {
      for (col = 0; col < Ncol + NwinCol; col++) {
        T11 = M_in[T644][lig][col]; 
        T12_re = M_in[T645_re][lig][col]; T12_im = M_in[T645_im][lig][col];
        T13_re = M_in[T646_re][lig][col]; T13_im = M_in[T646_im][lig][col];
        T22 = M_in[T655][lig][col]; 
        T23_re = M_in[T656_re][lig][col]; T23_im = M_in[T656_im][lig][col];
        T33 = M_in[T666][lig][col]; 
        M_in[C311][lig][col] = (T11 + 2 * T12_re + T22) / 2;
        M_in[C312_re][lig][col] = (T13_re + T23_re) / sqrt(2);
        M_in[C312_im][lig][col] = (T13_im + T23_im) / sqrt(2);
        M_in[C313_re][lig][col] = (T11 - T22) / 2;
        M_in[C313_im][lig][col] = -T12_im;
        M_in[C322][lig][col] = T33;
        M_in[C323_re][lig][col] = (T13_re - T23_re) / sqrt(2);
        M_in[C323_im][lig][col] = (-T13_im + T23_im) / sqrt(2);
        M_in[C333][lig][col] = (T11 - 2 * T12_re + T22) / 2;
        }
      }
    }

  return 1;
}

/********************************************************************
Routine  : C2_to_T2
Authors  : Eric POTTIER
Creation : 08/2011
Update  :
*--------------------------------------------------------------------
Description : create an array of the T3 matrix from C3 matrix
********************************************************************/
int C2_to_T2(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float C11, C12_re, C12_im, C22;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      C11 = M_in[C211][lig][col];
      C12_re = M_in[C212_re][lig][col]; C12_im = M_in[C212_im][lig][col];
      C22 = M_in[C222][lig][col];

      M_in[T211][lig][col] = (C11 + 2 * C12_re + C22) / 2;
      M_in[T212_re][lig][col] = (C11 - C22) / 2;
      M_in[T212_im][lig][col] = -C12_im;
      M_in[T222][lig][col] = (C11 - 2 * C12_re + C22) / 2;
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : T2_to_C2
Authors  : Eric POTTIER
Creation : 08/2011
Update  :
*--------------------------------------------------------------------
Description : create an array of the C3 matrix from T3 matrix
********************************************************************/
int T2_to_C2(float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  float T11, T12_re, T12_im, T22;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      T11 = M_in[T211][lig][col]; 
      T12_re = M_in[T212_re][lig][col]; T12_im = M_in[T212_im][lig][col];
      T22 = M_in[T222][lig][col]; 

      M_in[C211][lig][col] = (T11 + 2 * T12_re + T22) / 2;
      M_in[C212_re][lig][col] = (T11 - T22) / 2;
      M_in[C212_im][lig][col] = -T12_im;
      M_in[C222][lig][col] = (T11 - 2 * T12_re + T22) / 2;
      }
    }
  
  return 1;
}

/********************************************************************
Routine  : SPP_to_T4
Authors  : Eric POTTIER
Creation : 10/2012
Update  :
*--------------------------------------------------------------------
Description : create an array of the T4 matrix from 2*SPP matrix
********************************************************************/
int SPP_to_T4(float ***S_in1, float ***S_in2, float ***M_in, int Nlig, int Ncol, int NwinLig, int NwinCol)
{
  int lig, col;
  int Ch1=0;
  int Ch2=1;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;
  
  for (lig = 0; lig < Nlig + NwinLig; lig++) {
    for (col = 0; col < Ncol + NwinCol; col++) {
      k1r = (S_in1[Ch1][lig][2*col] + S_in1[Ch2][lig][2*col]) / sqrt(2.);
      k1i = (S_in1[Ch1][lig][2*col+1] + S_in1[Ch2][lig][2*col+1]) / sqrt(2.);
      k2r = (S_in1[Ch1][lig][2*col] - S_in1[Ch2][lig][2*col]) / sqrt(2.);
      k2i = (S_in1[Ch1][lig][2*col+1] - S_in1[Ch2][lig][2*col+1]) / sqrt(2.);
      k3r = (S_in2[Ch1][lig][2*col] + S_in2[Ch2][lig][2*col]) / sqrt(2.);
      k3i = (S_in2[Ch1][lig][2*col+1] + S_in2[Ch2][lig][2*col+1]) / sqrt(2.);
      k4r = (S_in2[Ch1][lig][2*col] - S_in2[Ch2][lig][2*col]) / sqrt(2.);
      k4i = (S_in2[Ch1][lig][2*col+1] - S_in2[Ch2][lig][2*col+1]) / sqrt(2.);

      M_in[0][lig][col] = k1r * k1r + k1i * k1i;
      M_in[1][lig][col] = k1r * k2r + k1i * k2i;
      M_in[2][lig][col] = k1i * k2r - k1r * k2i;
      M_in[3][lig][col] = k1r * k3r + k1i * k3i;
      M_in[4][lig][col] = k1i * k3r - k1r * k3i;
      M_in[5][lig][col] = k1r * k4r + k1i * k4i;
      M_in[6][lig][col] = k1i * k4r - k1r * k4i;
      M_in[7][lig][col] = k2r * k2r + k2i * k2i;
      M_in[8][lig][col] = k2r * k3r + k2i * k3i;    
      M_in[9][lig][col] = k2i * k3r - k2r * k3i;
      M_in[10][lig][col] = k2r * k4r + k2i * k4i;
      M_in[11][lig][col] = k2i * k4r - k2r * k4i;
      M_in[12][lig][col] = k3r * k3r + k3i * k3i;
      M_in[13][lig][col] = k3r * k4r + k3i * k4i;
      M_in[14][lig][col] = k3i * k4r - k3r * k4i;
      M_in[15][lig][col] = k4r * k4r + k4i * k4i;
    }
  }
  return 1;
}
