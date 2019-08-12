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

File   : calibrator.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 12/2011
Update  :
*--------------------------------------------------------------------
INSTITUT D'ELECTRONIQUE et de TELECOMMUNICATIONS de RENNES (I.E.T.R)
UMR CNRS 6164

Waves and Signal department
SHINE Team 


UNIVERSITY OF RENNES I
Bât. 11D - Campus de Beaulieu
263 Avenue Général Leclerc
35042 RENNES Cedex
Tel :(+33) 2 23 23 57 63
Fax :(+33) 2 23 23 69 63
e-mail: eric.pottier@univ-rennes1.fr

*--------------------------------------------------------------------

Description :  Characterization of the Extracted Calibrator 
               (resolution, PSLR, SSLR, ISLR) in range and azimut
               directions

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* CONSTANTS  */
#define Npolar  4

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* GLOBAL VARIABLES */
/* Input/Output file pointer arrays */
FILE *in_file, *out_file;
/* Matrix arrays */
float **S;
float *Vector;
float *VectorFFT;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

/* LOCAL VARIABLES */

/* Strings */
  char CalibratorValTxt[FilePathLength], CalibratorValBin[FilePathLength];

/* Internal variables */
  int np, Length;
  int CoeffInterp, Nfft, NfftInterp;
  int ii, Rmax;
  int arret, R3db, R6db, R9db;

  float Amplimax, Amplimaxdb;
  float mu, Resolr, SSLRresolr, Dr, Drbis, DX, DY;
  float Ramplimax2, Rpslr, Ramplimax3, Rsslr;
  float Airer1, Airer2, Rislr;

/* PROGRAM START */

  if (argc < 5) {
  edit_error("calibrator CalibratorValTxt CalibratorValBin DX DY\n","");
  } else {
  strcpy(CalibratorValTxt, argv[1]);
  strcpy(CalibratorValBin, argv[2]);
  DX = atof(argv[3]);
  DY = atof(argv[4]);
  }
  
  check_file(CalibratorValTxt);
  check_file(CalibratorValBin);
  
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* INPUT/OUTPUT FILE OPENING*/
  if ((in_file = fopen(CalibratorValBin, "rb")) == NULL)
  edit_error("Could not open configuration file : ",CalibratorValBin);
  fread(&Length, sizeof(int), 1, in_file);
  S = matrix_float(2*Npolar,2*Length);
  for (np = 0; np < 2*Npolar; np++) fread(&S[np][0], sizeof(float), 2*Length, in_file);
  fclose(in_file);

  if ((out_file = fopen(CalibratorValTxt, "w")) == NULL)
  edit_error("Could not open configuration file : ",CalibratorValTxt);

/******************************************************************************/
/* FFT Configuration */
CoeffInterp = 4;
Nfft = (int)(pow(2,(int)(1.+log(Length)/log(2.))));
if (Nfft < 1024) Nfft = 1024;
NfftInterp = CoeffInterp*Nfft;

/* Vectors initialisation */
Vector = vector_float(NfftInterp);
VectorFFT = vector_float(2*NfftInterp);

for (np=0; np<2*Npolar; np++) {

if (fmod(np,2) == 0) Dr = DX;
else Dr = DY;

/* FFT */
for (ii=0; ii<NfftInterp; ii++) Vector[ii] = 0.;
for (ii=0; ii<2*NfftInterp; ii++) VectorFFT[ii] = 0.;
for (ii=0; ii<2*Length; ii++) VectorFFT[ii] = S[np][ii];
Fft(&VectorFFT[0],Nfft,+1L);
/* Interpolation */
for (ii= 0; ii< Nfft/2; ii++) {
  VectorFFT[2*(ii+(NfftInterp-Nfft/2))] = VectorFFT[2*(ii+Nfft/2)];
  VectorFFT[2*(ii+(NfftInterp-Nfft/2))+1] = VectorFFT[2*(ii+Nfft/2)+1];
  }
for (ii= Nfft/2; ii< NfftInterp-Nfft/2;ii++) {
  VectorFFT[2*ii]=0; VectorFFT[2*ii+1]=0;
  }
/* FFT inverse*/
Fft(&VectorFFT[0],NfftInterp,-1L);

for (ii=0; ii<2*NfftInterp;ii++) VectorFFT[ii]=VectorFFT[ii]*NfftInterp/Nfft;

/* Calcul du module*/
for (ii=0; ii<NfftInterp;ii++) Vector[ii]=sqrt(VectorFFT[2*ii]*VectorFFT[2*ii]+VectorFFT[2*ii+1]*VectorFFT[2*ii+1]);

/* recherche du maximum*/
Amplimax = -INIT_MINMAX;
for (ii=0;ii<NfftInterp;ii++) {
  if (Vector[ii]>Amplimax) {
    Amplimax=Vector[ii];
    Rmax=ii;
    }
  }
Amplimaxdb=20*log10(Amplimax);

/**********************************************************************/
/* -3 dB Spatial Resolution */
arret=0; mu=Amplimaxdb-3.0; ii=Rmax;
while (arret == 0) {
    ii=ii+1;
    if (20.*log10(Vector[ii]) <= mu) arret=1;
    }
if (20.*log10(Vector[ii-1])- mu <= mu - 20.*log10(Vector[ii])) R3db=ii-1;
else R3db=ii;

Resolr=((abs(Rmax-R3db))*Dr*Nfft/NfftInterp);
arret=0; mu=Amplimaxdb-3.0; ii=Rmax;
while (arret == 0) {
    ii=ii-1;
    if (20.*log10(Vector[ii]) <= mu) arret=1;
    }
if (20.*log10(Vector[ii+1])- mu <= mu - 20.*log10(Vector[ii])) R3db=ii+1;
else R3db=ii;

Resolr=((abs(Rmax-R3db))*Dr*Nfft/NfftInterp)+Resolr;
fprintf(out_file, "%6.3f\n", Resolr);

/* -6 dB Spatial Resolution */
arret=0; mu=Amplimaxdb-6.0; ii=Rmax;
while (arret == 0) {
    ii=ii+1;
    if (20.*log10(Vector[ii]) <= mu) arret=1;
    }
if (20.*log10(Vector[ii-1])- mu <= mu - 20.*log10(Vector[ii])) R6db=ii-1;
else R6db=ii;

Resolr=((abs(Rmax-R6db))*Dr*Nfft/NfftInterp);
arret=0; mu=Amplimaxdb-6.0; ii=Rmax;
while (arret == 0) {
    ii=ii-1;
    if (20.*log10(Vector[ii]) <= mu) arret=1;
    }
if (20.*log10(Vector[ii+1])- mu <= mu - 20.*log10(Vector[ii])) R6db=ii+1;
else R6db=ii;

Resolr=((abs(Rmax-R6db))*Dr*Nfft/NfftInterp)+Resolr;
fprintf(out_file, "%6.3f\n", Resolr);

/* -9 dB Spatial Resolution */
arret=0; mu=Amplimaxdb-9.0; ii=Rmax;
while (arret == 0) {
    ii=ii+1;
    if (20.*log10(Vector[ii]) <= mu) arret=1;
    }
if (20.*log10(Vector[ii-1])- mu <= mu - 20.*log10(Vector[ii])) R9db=ii-1;
else R9db=ii;

Resolr=((abs(Rmax-R9db))*Dr*Nfft/NfftInterp);
arret=0; mu=Amplimaxdb-9.0; ii=Rmax;
while (arret == 0) {
    ii=ii-1;
    if (20.*log10(Vector[ii]) <= mu) arret=1;
    }
if (20.*log10(Vector[ii+1])- mu <= mu - 20.*log10(Vector[ii])) R9db=ii+1;
else R9db=ii;

Resolr=((abs(Rmax-R9db))*Dr*Nfft/NfftInterp)+Resolr;
fprintf(out_file, "%6.3f\n", Resolr);

/**********************************************************************/
/* PSLR*/
  Drbis=Dr*Nfft/NfftInterp;
  Ramplimax2= -INIT_MINMAX;
  /* Calcul sup de l'intervalle de calcul*/
  for (ii=(Rmax+(int)(Resolr/Drbis)); ii<(Rmax+(int)(10*Resolr/Drbis)); ii++) {
    if (Vector[ii]>=Ramplimax2) {
      Ramplimax2=Vector[ii];
      }
    }

  Rpslr=Amplimaxdb-20*log10(Ramplimax2);
  Ramplimax2= -INIT_MINMAX;
  /* Calcul inf de l'intervalle de calcul*/
  for (ii=(Rmax-(int)(Resolr/Drbis)); ii>(Rmax-(int)(10*Resolr/Drbis)); ii--) {
    if (Vector[ii]>=Ramplimax2) {
      Ramplimax2=Vector[ii];
      }
    }

  Rpslr=(Rpslr+(Amplimaxdb-20*log10(Ramplimax2)))/2;
  fprintf(out_file, "%6.3f\n", Rpslr);

/*****************************************************************/
/* SSLR */
Ramplimax3= -INIT_MINMAX;
if (Rmax<(int)(CoeffInterp*Length/2)) {
  /* Borne sup de l'intervalle de calcul*/
  if ((Rmax+(int)(20*Resolr/Drbis))<(CoeffInterp*Length)) {
    SSLRresolr=Rmax+(int)(20*Resolr/Drbis);
    /* Calcul du maximum entre 10 et 20 fois la resolution*/
    for (ii=(Rmax+(int)(10*Resolr/Drbis)); ii<SSLRresolr; ii++) {
      if (Vector[ii]>=Ramplimax3) {
       Ramplimax3=Vector[ii];
       }
      }
    Rsslr=20*(log10(Amplimax)-log10(Ramplimax3));
    fprintf(out_file, "%6.3f\n", Rsslr);
    } else {
    fprintf(out_file, "------\n");
    }
  } else {
  /* Borne inf de l'intervalle de calcul*/
  if ((Rmax-(int)(20*Resolr/Drbis))>0) {
    SSLRresolr=Rmax-(int)(20*Resolr/Drbis);
    /* Calcul du maximum entre 10 et 20 fois la resolution*/
    for (ii=(Rmax-(int)(10*Resolr/Drbis)); ii>SSLRresolr; ii--) {
      if (Vector[ii]>=Ramplimax3) {
       Ramplimax3=Vector[ii];
       }
      }
    Rsslr=20*(log10(Amplimax)-log10(Ramplimax3));
    fprintf(out_file, "%6.3f\n", Rsslr);
    } else {
    fprintf(out_file, "------\n");
    }
  }
/*************************************************************************/
/* ISLR*/
Airer1=eps;
Airer2=eps;
for (ii=Rmax-(int)(Resolr/Drbis); ii<Rmax+(int)(Resolr/Drbis); ii++) Airer1=Airer1+((Vector[ii]+Vector[ii+1])/2);
if (Rmax<(int)(CoeffInterp*Length/2)) {
  if ((Rmax+(int)(20*Resolr/Drbis))<(CoeffInterp*Length)) {
    SSLRresolr=Rmax+(int)(20*Resolr/Drbis);
    /* Calcul de l'aire entre 2 et 20 fois la resolution*/
    for (ii=Rmax+(int)(2*Resolr/Drbis); ii<SSLRresolr; ii++) Airer2=Airer2+((Vector[ii]+Vector[ii+1])/2);
    Rislr=20*log10(Airer1/Airer2);
    fprintf(out_file, "%6.3f\n", Rislr);
    } else {
    fprintf(out_file, "------\n");
    }
  } else {
  if ((Rmax-(int)(20*Resolr/Drbis))>0) {
    SSLRresolr=Rmax-(int)(20*Resolr/Drbis);
    /* Calcul de l'aire entre 2 et 20 fois la resolution*/
    for (ii=Rmax-(int)(2*Resolr/Drbis); ii>SSLRresolr; ii--) Airer2=Airer2+((Vector[ii]+Vector[ii-1])/2);
    Rislr=20*log10(Airer1/Airer2);
    fprintf(out_file, "%6.3f\n", Rislr);
    } else {
    fprintf(out_file, "------\n");
    }
  }

} /* np */


free_matrix_float(S,2*Npolar);
free_vector_float(Vector);
free_vector_float(VectorFFT);

return 1;
}


