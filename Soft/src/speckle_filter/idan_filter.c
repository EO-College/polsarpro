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

File   : idan_filter.c
Project  : ESA_POLSARPRO
Authors  : Gabriel VALISE, Emmanuel TROUVE
Version  : 2.0
Creation : 02/2007
Update  : 08/2010 (E. POTTIER)
*--------------------------------------------------------------------
GIPSA-Campus
ENSIEG, Domaine Universitaire
961 rue de Houille Blanche - BP46
38402 SAINT MARTIN D'HERES
Tel :(+33) 4 76 82 71 39
Fax :(+33) 4 76 82 63 84
e-mail : gabriel.vasile@lis.inpg.fr, emmanuel.trouve@lis.inpg.fr
*--------------------------------------------------------------------

Description :  IDAN (Intensity Driven Adaptive Neighbourhood) speckle
        filter

********************************************************************/
#define IDAN_MAIN

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#include "omp.h"

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
#include "../lib/idan.h"
#include "../lib/idan_lib.h"

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/

int main(int argc, char *argv[]){

/* DECLARATIONS */

  /* images */
  imafl rs11, rs12, rs21, rs22;
  imafl wT11, wT12_re, wT12_im, wT13_re, wT13_im, wT14_re, wT14_im;
  imafl wT22, wT23_re, wT23_im, wT24_re, wT24_im, wT33, wT34_re, wT34_im, wT44;
  imafl rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT14_re, rT14_im;
  imafl rT22, rT23_re, rT23_im, rT24_re, rT24_im, rT33, rT34_re, rT34_im, rT44;

  /* operateurs */
  read_imabin_t rea_s11, rea_s12, rea_s21, rea_s22;
  read_imabin_t rea_T11, rea_T12_re, rea_T12_im, rea_T13_re, rea_T13_im, rea_T14_re, rea_T14_im;
  read_imabin_t rea_T22, rea_T23_re, rea_T23_im, rea_T24_re, rea_T24_im, rea_T33, rea_T34_re, rea_T34_im, rea_T44;

  write_imabin_t wri_T11, wri_T12_re, wri_T12_im, wri_T13_re, wri_T13_im, wri_T14_re, wri_T14_im;
  write_imabin_t wri_T22, wri_T23_re, wri_T23_im, wri_T24_re, wri_T24_im, wri_T33, wri_T34_re, wri_T34_im, wri_T44;
  
  char  dir_in[FilePathLength];
  char  dir_out[FilePathLength];
  
  int NR, NC;
/* PolSARpro command added */
  int OR, OC, NRF, NCF;
/* PolSARpro command added */
  IDAN_t par;

/* PolSARpro command modified */
#define NPolType 11
  int ii, Config;
  char *PolTypeConf[NPolType] = {"S2C3", "S2C4", "S2T3", "S2T4", "C2", "C3", "C4", "T2", "T3", "T4", "SPP"};

  /* main : variables et parametres propres au main*/
  param par0, *ptp;    /* tete et pointeur pour la chaine de parametres */
  
/* LECTURE PARAMETRES */

  /* debut: OBLIGATOIRE pour compatibilite avec les 3 modes de lecture de param */

  param_debut(argc, argv, &par0); 
  ptp = &par0;    /* regle : ptp pointe sur la structure du parametre suivant */

  /* operateurs: ptp est passe en argument, return fournit la nouvelle position */

/* PolSARpro command modified */
  lec_param(">> Input directory :", ptp);
  strcpy(dir_in, ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Destination directory :", ptp);
  strcpy(dir_out, ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Number of rows :", ptp);
  NR = atoi(ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Number of columns :", ptp);
  NC = atoi(ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Offset rows :", ptp);
  OR = atoi(ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Offset columns :", ptp);
  OC = atoi(ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Number of final rows :", ptp);
  NRF = atoi(ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Number of final columns :", ptp);
  NCF = atoi(ptp->rep);
  ptp = ptp->next; 

  lec_param(">> Input Polarimetric Data Format :", ptp);
  strcpy(PolType, ptp->rep);
  ptp = ptp->next; 

/* PolSARpro command modified */

  ptp = IDAN_lect(&par, ptp, ">> IDAN_lect :");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormat(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/

/* PolSARpro command modified */

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);

  check_dir(dir_in);
  check_dir(dir_out);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(dir_in, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  if (strcmp(PolType,"SPP")==0) strcpy(PolType, "SPPC2");
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);

/********************************************************************
********************************************************************/
/* fin: sauvegarde des parametres utilises en mode MANUEL ou FICHIER */
  param_fin(argc, argv, &par0);

if (strcmp(PolTypeIn,"T2")==0) {
  sprintf(rea_T11.nom, "%sT11", dir_in); sprintf(rea_T11.ext, "bin");
  sprintf(rea_T12_re.nom, "%sT12_real", dir_in); sprintf(rea_T12_re.ext, "bin");
  sprintf(rea_T12_im.nom, "%sT12_imag", dir_in); sprintf(rea_T12_im.ext, "bin");
  sprintf(rea_T22.nom, "%sT22", dir_in); sprintf(rea_T22.ext, "bin");

  sprintf(wri_T11.nom, "%sT11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sT12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sT12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T22.nom, "%sT22", dir_out); sprintf(wri_T22.ext, "bin");

  read_imabin_init(&rea_T11, &rT11, NC, NR);
  read_imabin_init(&rea_T12_re, &rT12_re, NC, NR); read_imabin_init(&rea_T12_im, &rT12_im, NC, NR);
  read_imabin_init(&rea_T22, &rT22, NC, NR);
  } // PolType = T2

if (strcmp(PolTypeIn,"T3")==0) {
  sprintf(rea_T11.nom, "%sT11", dir_in); sprintf(rea_T11.ext, "bin");
  sprintf(rea_T12_re.nom, "%sT12_real", dir_in); sprintf(rea_T12_re.ext, "bin");
  sprintf(rea_T12_im.nom, "%sT12_imag", dir_in); sprintf(rea_T12_im.ext, "bin");
  sprintf(rea_T13_re.nom, "%sT13_real", dir_in); sprintf(rea_T13_re.ext, "bin");
  sprintf(rea_T13_im.nom, "%sT13_imag", dir_in); sprintf(rea_T13_im.ext, "bin");
  sprintf(rea_T22.nom, "%sT22", dir_in); sprintf(rea_T22.ext, "bin");
  sprintf(rea_T23_re.nom, "%sT23_real", dir_in); sprintf(rea_T23_re.ext, "bin");
  sprintf(rea_T23_im.nom, "%sT23_imag", dir_in); sprintf(rea_T23_im.ext, "bin");
  sprintf(rea_T33.nom, "%sT33", dir_in); sprintf(rea_T33.ext, "bin");

  sprintf(wri_T11.nom, "%sT11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sT12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sT12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T13_re.nom, "%sT13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
  sprintf(wri_T13_im.nom, "%sT13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
  sprintf(wri_T22.nom, "%sT22", dir_out); sprintf(wri_T22.ext, "bin");
  sprintf(wri_T23_re.nom, "%sT23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
  sprintf(wri_T23_im.nom, "%sT23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
  sprintf(wri_T33.nom, "%sT33", dir_out); sprintf(wri_T33.ext, "bin");

  read_imabin_init(&rea_T11, &rT11, NC, NR);
  read_imabin_init(&rea_T12_re, &rT12_re, NC, NR);
  read_imabin_init(&rea_T12_im, &rT12_im, NC, NR);
  read_imabin_init(&rea_T13_re, &rT13_re, NC, NR);
  read_imabin_init(&rea_T13_im, &rT13_im, NC, NR);
  read_imabin_init(&rea_T22, &rT22, NC, NR);
  read_imabin_init(&rea_T23_re, &rT23_re, NC, NR);
  read_imabin_init(&rea_T23_im, &rT23_im, NC, NR);
  read_imabin_init(&rea_T33, &rT33, NC, NR);
  } //PolType = T3
  
if (strcmp(PolTypeIn,"T4")==0) {
  sprintf(rea_T11.nom, "%sT11", dir_in); sprintf(rea_T11.ext, "bin");
  sprintf(rea_T12_re.nom, "%sT12_real", dir_in); sprintf(rea_T12_re.ext, "bin");
  sprintf(rea_T12_im.nom, "%sT12_imag", dir_in); sprintf(rea_T12_im.ext, "bin");
  sprintf(rea_T13_re.nom, "%sT13_real", dir_in); sprintf(rea_T13_re.ext, "bin");
  sprintf(rea_T13_im.nom, "%sT13_imag", dir_in); sprintf(rea_T13_im.ext, "bin");
  sprintf(rea_T14_re.nom, "%sT14_real", dir_in); sprintf(rea_T14_re.ext, "bin");
  sprintf(rea_T14_im.nom, "%sT14_imag", dir_in); sprintf(rea_T14_im.ext, "bin");
  sprintf(rea_T22.nom, "%sT22", dir_in); sprintf(rea_T22.ext, "bin");
  sprintf(rea_T23_re.nom, "%sT23_real", dir_in); sprintf(rea_T23_re.ext, "bin");
  sprintf(rea_T23_im.nom, "%sT23_imag", dir_in); sprintf(rea_T23_im.ext, "bin");
  sprintf(rea_T24_re.nom, "%sT24_real", dir_in); sprintf(rea_T24_re.ext, "bin");
  sprintf(rea_T24_im.nom, "%sT24_imag", dir_in); sprintf(rea_T24_im.ext, "bin");
  sprintf(rea_T33.nom, "%sT33", dir_in); sprintf(rea_T33.ext, "bin");
  sprintf(rea_T34_re.nom, "%sT34_real", dir_in); sprintf(rea_T34_re.ext, "bin");
  sprintf(rea_T34_im.nom, "%sT34_imag", dir_in); sprintf(rea_T34_im.ext, "bin");
  sprintf(rea_T44.nom, "%sT44", dir_in); sprintf(rea_T44.ext, "bin");

  sprintf(wri_T11.nom, "%sT11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sT12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sT12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T13_re.nom, "%sT13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
  sprintf(wri_T13_im.nom, "%sT13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
  sprintf(wri_T14_re.nom, "%sT14_real", dir_out); sprintf(wri_T14_re.ext, "bin");
  sprintf(wri_T14_im.nom, "%sT14_imag", dir_out); sprintf(wri_T14_im.ext, "bin");
  sprintf(wri_T22.nom, "%sT22", dir_out); sprintf(wri_T22.ext, "bin");
  sprintf(wri_T23_re.nom, "%sT23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
  sprintf(wri_T23_im.nom, "%sT23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
  sprintf(wri_T24_re.nom, "%sT24_real", dir_out); sprintf(wri_T24_re.ext, "bin");
  sprintf(wri_T24_im.nom, "%sT24_imag", dir_out); sprintf(wri_T24_im.ext, "bin");
  sprintf(wri_T33.nom, "%sT33", dir_out); sprintf(wri_T33.ext, "bin");
  sprintf(wri_T34_re.nom, "%sT34_real", dir_out); sprintf(wri_T34_re.ext, "bin");
  sprintf(wri_T34_im.nom, "%sT34_imag", dir_out); sprintf(wri_T34_im.ext, "bin");
  sprintf(wri_T44.nom, "%sT44", dir_out); sprintf(wri_T44.ext, "bin");

  read_imabin_init(&rea_T11, &rT11, NC, NR);
  read_imabin_init(&rea_T12_re, &rT12_re, NC, NR); read_imabin_init(&rea_T12_im, &rT12_im, NC, NR);
  read_imabin_init(&rea_T13_re, &rT13_re, NC, NR); read_imabin_init(&rea_T13_im, &rT13_im, NC, NR);
  read_imabin_init(&rea_T14_re, &rT14_re, NC, NR); read_imabin_init(&rea_T14_im, &rT14_im, NC, NR);
  read_imabin_init(&rea_T22, &rT22, NC, NR);
  read_imabin_init(&rea_T23_re, &rT23_re, NC, NR); read_imabin_init(&rea_T23_im, &rT23_im, NC, NR);
  read_imabin_init(&rea_T24_re, &rT24_re, NC, NR); read_imabin_init(&rea_T24_im, &rT24_im, NC, NR);
  read_imabin_init(&rea_T33, &rT33, NC, NR);
  read_imabin_init(&rea_T34_re, &rT34_re, NC, NR); read_imabin_init(&rea_T34_im, &rT34_im, NC, NR);
  read_imabin_init(&rea_T44, &rT44, NC, NR);
  } // PolType = T4

if (strcmp(PolTypeIn,"C2")==0) {
  sprintf(rea_T11.nom, "%sC11", dir_in); sprintf(rea_T11.ext, "bin");
  sprintf(rea_T12_re.nom, "%sC12_real", dir_in); sprintf(rea_T12_re.ext, "bin");
  sprintf(rea_T12_im.nom, "%sC12_imag", dir_in); sprintf(rea_T12_im.ext, "bin");
  sprintf(rea_T22.nom, "%sC22", dir_in); sprintf(rea_T22.ext, "bin");

  sprintf(wri_T11.nom, "%sC11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sC12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sC12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T22.nom, "%sC22", dir_out); sprintf(wri_T22.ext, "bin");

  read_imabin_init(&rea_T11, &rT11, NC, NR);
  read_imabin_init(&rea_T12_re, &rT12_re, NC, NR); read_imabin_init(&rea_T12_im, &rT12_im, NC, NR);
  read_imabin_init(&rea_T22, &rT22, NC, NR);
  } // PolType = C2

if (strcmp(PolTypeIn,"C3")==0) {
  sprintf(rea_T11.nom, "%sC11", dir_in); sprintf(rea_T11.ext, "bin");
  sprintf(rea_T12_re.nom, "%sC12_real", dir_in); sprintf(rea_T12_re.ext, "bin");
  sprintf(rea_T12_im.nom, "%sC12_imag", dir_in); sprintf(rea_T12_im.ext, "bin");
  sprintf(rea_T13_re.nom, "%sC13_real", dir_in); sprintf(rea_T13_re.ext, "bin");
  sprintf(rea_T13_im.nom, "%sC13_imag", dir_in); sprintf(rea_T13_im.ext, "bin");
  sprintf(rea_T22.nom, "%sC22", dir_in); sprintf(rea_T22.ext, "bin");
  sprintf(rea_T23_re.nom, "%sC23_real", dir_in); sprintf(rea_T23_re.ext, "bin");
  sprintf(rea_T23_im.nom, "%sC23_imag", dir_in); sprintf(rea_T23_im.ext, "bin");
  sprintf(rea_T33.nom, "%sC33", dir_in); sprintf(rea_T33.ext, "bin");

  sprintf(wri_T11.nom, "%sC11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sC12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sC12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T13_re.nom, "%sC13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
  sprintf(wri_T13_im.nom, "%sC13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
  sprintf(wri_T22.nom, "%sC22", dir_out); sprintf(wri_T22.ext, "bin");
  sprintf(wri_T23_re.nom, "%sC23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
  sprintf(wri_T23_im.nom, "%sC23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
  sprintf(wri_T33.nom, "%sC33", dir_out); sprintf(wri_T33.ext, "bin");

  read_imabin_init(&rea_T11, &rT11, NC, NR);
  read_imabin_init(&rea_T12_re, &rT12_re, NC, NR); read_imabin_init(&rea_T12_im, &rT12_im, NC, NR);
  read_imabin_init(&rea_T13_re, &rT13_re, NC, NR); read_imabin_init(&rea_T13_im, &rT13_im, NC, NR);
  read_imabin_init(&rea_T22, &rT22, NC, NR);
  read_imabin_init(&rea_T23_re, &rT23_re, NC, NR); read_imabin_init(&rea_T23_im, &rT23_im, NC, NR);
  read_imabin_init(&rea_T33, &rT33, NC, NR);
  } // PolType = C3

if (strcmp(PolTypeIn,"C4")==0) {
  sprintf(rea_T11.nom, "%sC11", dir_in); sprintf(rea_T11.ext, "bin");
  sprintf(rea_T12_re.nom, "%sC12_real", dir_in); sprintf(rea_T12_re.ext, "bin");
  sprintf(rea_T12_im.nom, "%sC12_imag", dir_in); sprintf(rea_T12_im.ext, "bin");
  sprintf(rea_T13_re.nom, "%sC13_real", dir_in); sprintf(rea_T13_re.ext, "bin");
  sprintf(rea_T13_im.nom, "%sC13_imag", dir_in); sprintf(rea_T13_im.ext, "bin");
  sprintf(rea_T14_re.nom, "%sC14_real", dir_in); sprintf(rea_T14_re.ext, "bin");
  sprintf(rea_T14_im.nom, "%sC14_imag", dir_in); sprintf(rea_T14_im.ext, "bin");
  sprintf(rea_T22.nom, "%sC22", dir_in); sprintf(rea_T22.ext, "bin");
  sprintf(rea_T23_re.nom, "%sC23_real", dir_in); sprintf(rea_T23_re.ext, "bin");
  sprintf(rea_T23_im.nom, "%sC23_imag", dir_in); sprintf(rea_T23_im.ext, "bin");
  sprintf(rea_T24_re.nom, "%sC24_real", dir_in); sprintf(rea_T24_re.ext, "bin");
  sprintf(rea_T24_im.nom, "%sC24_imag", dir_in); sprintf(rea_T24_im.ext, "bin");
  sprintf(rea_T33.nom, "%sC33", dir_in); sprintf(rea_T33.ext, "bin");
  sprintf(rea_T34_re.nom, "%sC34_real", dir_in); sprintf(rea_T34_re.ext, "bin");
  sprintf(rea_T34_im.nom, "%sC34_imag", dir_in); sprintf(rea_T34_im.ext, "bin");
  sprintf(rea_T44.nom, "%sC44", dir_in); sprintf(rea_T44.ext, "bin");

  sprintf(wri_T11.nom, "%sC11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sC12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sC12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T13_re.nom, "%sC13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
  sprintf(wri_T13_im.nom, "%sC13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
  sprintf(wri_T14_re.nom, "%sC14_real", dir_out); sprintf(wri_T14_re.ext, "bin");
  sprintf(wri_T14_im.nom, "%sC14_imag", dir_out); sprintf(wri_T14_im.ext, "bin");
  sprintf(wri_T22.nom, "%sC22", dir_out); sprintf(wri_T22.ext, "bin");
  sprintf(wri_T23_re.nom, "%sC23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
  sprintf(wri_T23_im.nom, "%sC23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
  sprintf(wri_T24_re.nom, "%sC24_real", dir_out); sprintf(wri_T24_re.ext, "bin");
  sprintf(wri_T24_im.nom, "%sC24_imag", dir_out); sprintf(wri_T24_im.ext, "bin");
  sprintf(wri_T33.nom, "%sC33", dir_out); sprintf(wri_T33.ext, "bin");
  sprintf(wri_T34_re.nom, "%sC34_real", dir_out); sprintf(wri_T34_re.ext, "bin");
  sprintf(wri_T34_im.nom, "%sC34_imag", dir_out); sprintf(wri_T34_im.ext, "bin");
  sprintf(wri_T44.nom, "%sC44", dir_out); sprintf(wri_T44.ext, "bin");

  read_imabin_init(&rea_T11, &rT11, NC, NR);
  read_imabin_init(&rea_T12_re, &rT12_re, NC, NR); read_imabin_init(&rea_T12_im, &rT12_im, NC, NR);
  read_imabin_init(&rea_T13_re, &rT13_re, NC, NR); read_imabin_init(&rea_T13_im, &rT13_im, NC, NR);
  read_imabin_init(&rea_T14_re, &rT14_re, NC, NR); read_imabin_init(&rea_T14_im, &rT14_im, NC, NR);
  read_imabin_init(&rea_T22, &rT22, NC, NR);
  read_imabin_init(&rea_T23_re, &rT23_re, NC, NR); read_imabin_init(&rea_T23_im, &rT23_im, NC, NR);
  read_imabin_init(&rea_T24_re, &rT24_re, NC, NR); read_imabin_init(&rea_T24_im, &rT24_im, NC, NR);
  read_imabin_init(&rea_T33, &rT33, NC, NR);
  read_imabin_init(&rea_T34_re, &rT34_re, NC, NR); read_imabin_init(&rea_T34_im, &rT34_im, NC, NR);
  read_imabin_init(&rea_T44, &rT44, NC, NR);
  } // PolType = C4

if (strcmp(PolTypeIn,"S2")==0) {
  sprintf(rea_s11.nom, "%ss11", dir_in); sprintf(rea_s11.ext, "bin");
  sprintf(rea_s12.nom, "%ss12", dir_in); sprintf(rea_s12.ext, "bin");
  sprintf(rea_s21.nom, "%ss21", dir_in); sprintf(rea_s21.ext, "bin");
  sprintf(rea_s22.nom, "%ss22", dir_in); sprintf(rea_s22.ext, "bin");

  read_imabin_init(&rea_s11, &rs11, 2*NC, NR);
  read_imabin_init(&rea_s12, &rs12, 2*NC, NR);
  read_imabin_init(&rea_s21, &rs21, 2*NC, NR);
  read_imabin_init(&rea_s22, &rs22, 2*NC, NR);

  if (strcmp(PolTypeOut,"C3")==0) {
   sprintf(wri_T11.nom, "%sC11", dir_out); sprintf(wri_T11.ext, "bin");
   sprintf(wri_T12_re.nom, "%sC12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
   sprintf(wri_T12_im.nom, "%sC12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
   sprintf(wri_T13_re.nom, "%sC13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
   sprintf(wri_T13_im.nom, "%sC13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
   sprintf(wri_T22.nom, "%sC22", dir_out); sprintf(wri_T22.ext, "bin");
   sprintf(wri_T23_re.nom, "%sC23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
   sprintf(wri_T23_im.nom, "%sC23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
   sprintf(wri_T33.nom, "%sC33", dir_out); sprintf(wri_T33.ext, "bin");

   convert_S2_C3(rs11, rs12, rs21, rs22, &rT11, &rT12_re, &rT12_im, &rT13_re, &rT13_im, &rT22, &rT23_re, &rT23_im, &rT33, NC, NR);

   free_imafl(&rs11); free_imafl(&rs12); free_imafl(&rs21); free_imafl(&rs22);
   }
  if (strcmp(PolTypeOut,"C4")==0) {
   sprintf(wri_T11.nom, "%sC11", dir_out); sprintf(wri_T11.ext, "bin");
   sprintf(wri_T12_re.nom, "%sC12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
   sprintf(wri_T12_im.nom, "%sC12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
   sprintf(wri_T13_re.nom, "%sC13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
   sprintf(wri_T13_im.nom, "%sC13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
   sprintf(wri_T14_re.nom, "%sC14_real", dir_out); sprintf(wri_T14_re.ext, "bin");
   sprintf(wri_T14_im.nom, "%sC14_imag", dir_out); sprintf(wri_T14_im.ext, "bin");
   sprintf(wri_T22.nom, "%sC22", dir_out); sprintf(wri_T22.ext, "bin");
   sprintf(wri_T23_re.nom, "%sC23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
   sprintf(wri_T23_im.nom, "%sC23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
   sprintf(wri_T24_re.nom, "%sC24_real", dir_out); sprintf(wri_T24_re.ext, "bin");
   sprintf(wri_T24_im.nom, "%sC24_imag", dir_out); sprintf(wri_T24_im.ext, "bin");
   sprintf(wri_T33.nom, "%sC33", dir_out); sprintf(wri_T33.ext, "bin");
   sprintf(wri_T34_re.nom, "%sC34_real", dir_out); sprintf(wri_T34_re.ext, "bin");
   sprintf(wri_T34_im.nom, "%sC34_imag", dir_out); sprintf(wri_T34_im.ext, "bin");
   sprintf(wri_T44.nom, "%sC44", dir_out); sprintf(wri_T44.ext, "bin");

   convert_S2_C4(rs11, rs12, rs21, rs22, &rT11, &rT12_re, &rT12_im, &rT13_re, &rT13_im, &rT14_re, &rT14_im, &rT22, &rT23_re, &rT23_im, &rT24_re, &rT24_im, &rT33, &rT34_re, &rT34_im, &rT44, NC, NR);

   free_imafl(&rs11); free_imafl(&rs12); free_imafl(&rs21); free_imafl(&rs22);
   }
  if (strcmp(PolTypeOut,"T3")==0) {
   sprintf(wri_T11.nom, "%sT11", dir_out); sprintf(wri_T11.ext, "bin");
   sprintf(wri_T12_re.nom, "%sT12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
   sprintf(wri_T12_im.nom, "%sT12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
   sprintf(wri_T13_re.nom, "%sT13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
   sprintf(wri_T13_im.nom, "%sT13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
   sprintf(wri_T22.nom, "%sT22", dir_out); sprintf(wri_T22.ext, "bin");
   sprintf(wri_T23_re.nom, "%sT23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
   sprintf(wri_T23_im.nom, "%sT23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
   sprintf(wri_T33.nom, "%sT33", dir_out); sprintf(wri_T33.ext, "bin");

   convert_S2_T3(rs11, rs12, rs21, rs22, &rT11, &rT12_re, &rT12_im, &rT13_re, &rT13_im, &rT22, &rT23_re, &rT23_im, &rT33, NC, NR);

   free_imafl(&rs11); free_imafl(&rs12); free_imafl(&rs21); free_imafl(&rs22);
   }
  if (strcmp(PolTypeOut,"T4")==0) {
   sprintf(wri_T11.nom, "%sT11", dir_out); sprintf(wri_T11.ext, "bin");
   sprintf(wri_T12_re.nom, "%sT12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
   sprintf(wri_T12_im.nom, "%sT12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
   sprintf(wri_T13_re.nom, "%sT13_real", dir_out); sprintf(wri_T13_re.ext, "bin");
   sprintf(wri_T13_im.nom, "%sT13_imag", dir_out); sprintf(wri_T13_im.ext, "bin");
   sprintf(wri_T14_re.nom, "%sT14_real", dir_out); sprintf(wri_T14_re.ext, "bin");
   sprintf(wri_T14_im.nom, "%sT14_imag", dir_out); sprintf(wri_T14_im.ext, "bin");
   sprintf(wri_T22.nom, "%sT22", dir_out); sprintf(wri_T22.ext, "bin");
   sprintf(wri_T23_re.nom, "%sT23_real", dir_out); sprintf(wri_T23_re.ext, "bin");
   sprintf(wri_T23_im.nom, "%sT23_imag", dir_out); sprintf(wri_T23_im.ext, "bin");
   sprintf(wri_T24_re.nom, "%sT24_real", dir_out); sprintf(wri_T24_re.ext, "bin");
   sprintf(wri_T24_im.nom, "%sT24_imag", dir_out); sprintf(wri_T24_im.ext, "bin");
   sprintf(wri_T33.nom, "%sT33", dir_out); sprintf(wri_T33.ext, "bin");
   sprintf(wri_T34_re.nom, "%sT34_real", dir_out); sprintf(wri_T34_re.ext, "bin");
   sprintf(wri_T34_im.nom, "%sT34_imag", dir_out); sprintf(wri_T34_im.ext, "bin");
   sprintf(wri_T44.nom, "%sT44", dir_out); sprintf(wri_T44.ext, "bin");

   convert_S2_T4(rs11, rs12, rs21, rs22, &rT11, &rT12_re, &rT12_im, &rT13_re, &rT13_im, &rT14_re, &rT14_im, &rT22, &rT23_re, &rT23_im, &rT24_re, &rT24_im, &rT33, &rT34_re, &rT34_im, &rT44, NC, NR);

   free_imafl(&rs11); free_imafl(&rs12); free_imafl(&rs21); free_imafl(&rs22);
   }
  } // PolType = S2

if ((strcmp(PolTypeIn,"SPP") == 0) 
  || (strcmp(PolTypeIn,"SPPpp1") == 0)
  || (strcmp(PolTypeIn,"SPPpp2") == 0)
  || (strcmp(PolTypeIn,"SPPpp3") == 0)) {

  if (strcmp(PolarType, "pp1") == 0) {
  sprintf(rea_s11.nom, "%ss11", dir_in); sprintf(rea_s11.ext, "bin");
  sprintf(rea_s12.nom, "%ss21", dir_in); sprintf(rea_s12.ext, "bin");
  }
  if (strcmp(PolarType, "pp2") == 0) {
  sprintf(rea_s11.nom, "%ss22", dir_in); sprintf(rea_s11.ext, "bin");
  sprintf(rea_s12.nom, "%ss12", dir_in); sprintf(rea_s12.ext, "bin");
  }
  if (strcmp(PolarType, "pp3") == 0) {
  sprintf(rea_s11.nom, "%ss11", dir_in); sprintf(rea_s11.ext, "bin");
  sprintf(rea_s12.nom, "%ss22", dir_in); sprintf(rea_s12.ext, "bin");
  }

  read_imabin_init(&rea_s11, &rs11, 2*NC, NR);
  read_imabin_init(&rea_s12, &rs12, 2*NC, NR);

  sprintf(wri_T11.nom, "%sC11", dir_out); sprintf(wri_T11.ext, "bin");
  sprintf(wri_T12_re.nom, "%sC12_real", dir_out); sprintf(wri_T12_re.ext, "bin");
  sprintf(wri_T12_im.nom, "%sC12_imag", dir_out); sprintf(wri_T12_im.ext, "bin");
  sprintf(wri_T22.nom, "%sC22", dir_out); sprintf(wri_T22.ext, "bin");

  convert_SPP_C2(rs11, rs12, &rT11, &rT12_re, &rT12_im, &rT22, NC, NR);

  free_imafl(&rs11); free_imafl(&rs12);
  } // PolType = SPP

/********************************************************************
CALCUL
********************************************************************/

if ((strcmp(PolTypeOut,"T2")==0)||(strcmp(PolTypeOut,"T2pp1")==0)||(strcmp(PolTypeOut,"T2pp2")==0)||(strcmp(PolTypeOut,"T2pp3")==0)) {
  IDAN_init2(&par, rT11, rT12_re, rT12_im, rT22, &wT11, &wT12_re, &wT12_im, &wT22);
  IDAN_calc2(&par, rT11, rT12_re, rT12_im, rT22, &wT11, &wT12_re, &wT12_im, &wT22);

  free_imafl(&rT11);
  free_imafl(&rT12_re); free_imafl(&rT12_im);
  free_imafl(&rT22);

/* ECRITURE */
  write_imabin_init(&wri_T11);
  write_imabin_init(&wri_T12_re); write_imabin_init(&wri_T12_im);
  write_imabin_init(&wri_T22);

  write_imabin_ferm(&wri_T11, wT11, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_re, wT12_re, OR, OC, NRF, NCF); write_imabin_ferm(&wri_T12_im, wT12_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T22, wT22, OR, OC, NRF, NCF);

  free_imafl(&wT11);
  free_imafl(&wT12_re); free_imafl(&wT12_im);
  free_imafl(&wT22);
  } // PolType = T2

if (strcmp(PolTypeOut,"T3")==0) {
  IDAN_init(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT22, rT23_re, rT23_im, rT33, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT22, &wT23_re, &wT23_im, &wT33);
  IDAN_calc(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT22, rT23_re, rT23_im, rT33, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT22, &wT23_re, &wT23_im, &wT33);

  free_imafl(&rT11);
  free_imafl(&rT12_re); free_imafl(&rT12_im);
  free_imafl(&rT13_re); free_imafl(&rT13_im);
  free_imafl(&rT22);
  free_imafl(&rT23_re); free_imafl(&rT23_im);
  free_imafl(&rT33);

/* ECRITURE */
  write_imabin_init(&wri_T11);
  write_imabin_init(&wri_T12_re); write_imabin_init(&wri_T12_im);
  write_imabin_init(&wri_T13_re); write_imabin_init(&wri_T13_im);
  write_imabin_init(&wri_T22);
  write_imabin_init(&wri_T23_re); write_imabin_init(&wri_T23_im);
  write_imabin_init(&wri_T33);

  write_imabin_ferm(&wri_T11, wT11, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_re, wT12_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_im, wT12_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_re, wT13_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_im, wT13_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T22, wT22, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_re, wT23_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_im, wT23_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T33, wT33, OR, OC, NRF, NCF);

  free_imafl(&wT11);
  free_imafl(&wT12_re); free_imafl(&wT12_im);
  free_imafl(&wT13_re); free_imafl(&wT13_im);
  free_imafl(&wT22);
  free_imafl(&wT23_re); free_imafl(&wT23_im);
  free_imafl(&wT33);
  } //PolType = T3
  
if (strcmp(PolTypeOut,"T4")==0) {
  IDAN_init4(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT14_re, rT14_im, rT22, rT23_re, rT23_im, rT24_re, rT24_im, rT33, rT34_re, rT34_im, rT44, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT14_re, &wT14_im, &wT22, &wT23_re, &wT23_im, &wT24_re, &wT24_im, &wT33, &wT34_re, &wT34_im, &wT44);
  IDAN_calc4(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT14_re, rT14_im, rT22, rT23_re, rT23_im, rT24_re, rT24_im, rT33, rT34_re, rT34_im, rT44, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT14_re, &wT14_im, &wT22, &wT23_re, &wT23_im, &wT24_re, &wT24_im, &wT33, &wT34_re, &wT34_im, &wT44);

  free_imafl(&rT11);
  free_imafl(&rT12_re); free_imafl(&rT12_im);
  free_imafl(&rT13_re); free_imafl(&rT13_im);
  free_imafl(&rT14_re); free_imafl(&rT14_im);
  free_imafl(&rT22);
  free_imafl(&rT23_re); free_imafl(&rT23_im);
  free_imafl(&rT24_re); free_imafl(&rT24_im);
  free_imafl(&rT33);
  free_imafl(&rT34_re); free_imafl(&rT34_im);
  free_imafl(&rT44);

/* ECRITURE */
  write_imabin_init(&wri_T11);
  write_imabin_init(&wri_T12_re); write_imabin_init(&wri_T12_im);
  write_imabin_init(&wri_T13_re); write_imabin_init(&wri_T13_im);
  write_imabin_init(&wri_T14_re); write_imabin_init(&wri_T14_im);
  write_imabin_init(&wri_T22);
  write_imabin_init(&wri_T23_re); write_imabin_init(&wri_T23_im);
  write_imabin_init(&wri_T24_re); write_imabin_init(&wri_T24_im);
  write_imabin_init(&wri_T33);
  write_imabin_init(&wri_T34_re); write_imabin_init(&wri_T34_im);
  write_imabin_init(&wri_T44);

  write_imabin_ferm(&wri_T11, wT11, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_re, wT12_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_im, wT12_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_re, wT13_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_im, wT13_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T14_re, wT14_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T14_im, wT14_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T22, wT22, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_re, wT23_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_im, wT23_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T24_re, wT24_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T24_im, wT24_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T33, wT33, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T34_re, wT34_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T34_im, wT34_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T44, wT44, OR, OC, NRF, NCF);

  free_imafl(&wT11);
  free_imafl(&wT12_re); free_imafl(&wT12_im);
  free_imafl(&wT13_re); free_imafl(&wT13_im);
  free_imafl(&wT14_re); free_imafl(&wT14_im);
  free_imafl(&wT22);
  free_imafl(&wT23_re); free_imafl(&wT23_im);
  free_imafl(&wT24_re); free_imafl(&wT24_im);
  free_imafl(&wT33);
  free_imafl(&wT34_re); free_imafl(&wT34_im);
  free_imafl(&wT44);
  } // PolType = T4

if ((strcmp(PolTypeOut,"C2")==0)||(strcmp(PolTypeOut,"C2pp1")==0)||(strcmp(PolTypeOut,"C2pp2")==0)||(strcmp(PolTypeOut,"C2pp3")==0)) {
  IDAN_init2(&par, rT11, rT12_re, rT12_im, rT22, &wT11, &wT12_re, &wT12_im, &wT22);
  IDAN_calc2(&par, rT11, rT12_re, rT12_im, rT22, &wT11, &wT12_re, &wT12_im, &wT22);

  free_imafl(&rT11);
  free_imafl(&rT12_re); free_imafl(&rT12_im);
  free_imafl(&rT22);

/* ECRITURE */
  write_imabin_init(&wri_T11);
  write_imabin_init(&wri_T12_re); write_imabin_init(&wri_T12_im);
  write_imabin_init(&wri_T22);

  write_imabin_ferm(&wri_T11, wT11, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_re, wT12_re, OR, OC, NRF, NCF); write_imabin_ferm(&wri_T12_im, wT12_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T22, wT22, OR, OC, NRF, NCF);

  free_imafl(&wT11);
  free_imafl(&wT12_re); free_imafl(&wT12_im);
  free_imafl(&wT22);
  } // PolType = C2

if (strcmp(PolTypeOut,"C3")==0) {
  IDAN_init(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT22, rT23_re, rT23_im, rT33, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT22, &wT23_re, &wT23_im, &wT33);
  IDAN_calc(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT22, rT23_re, rT23_im, rT33, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT22, &wT23_re, &wT23_im, &wT33);

  free_imafl(&rT11);
  free_imafl(&rT12_re); free_imafl(&rT12_im);
  free_imafl(&rT13_re); free_imafl(&rT13_im);
  free_imafl(&rT22);
  free_imafl(&rT23_re); free_imafl(&rT23_im);
  free_imafl(&rT33);

/* ECRITURE */
  write_imabin_init(&wri_T11);
  write_imabin_init(&wri_T12_re); write_imabin_init(&wri_T12_im);
  write_imabin_init(&wri_T13_re); write_imabin_init(&wri_T13_im);
  write_imabin_init(&wri_T22);
  write_imabin_init(&wri_T23_re); write_imabin_init(&wri_T23_im);
  write_imabin_init(&wri_T33);

  write_imabin_ferm(&wri_T11, wT11, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_re, wT12_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_im, wT12_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_re, wT13_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_im, wT13_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T22, wT22, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_re, wT23_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_im, wT23_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T33, wT33, OR, OC, NRF, NCF);

  free_imafl(&wT11);
  free_imafl(&wT12_re); free_imafl(&wT12_im);
  free_imafl(&wT13_re); free_imafl(&wT13_im);
  free_imafl(&wT22);
  free_imafl(&wT23_re); free_imafl(&wT23_im);
  free_imafl(&wT33);
  } // PolType = C3

if (strcmp(PolTypeOut,"C4")==0) {
  IDAN_init4(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT14_re, rT14_im, rT22, rT23_re, rT23_im, rT24_re, rT24_im, rT33, rT34_re, rT34_im, rT44, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT14_re, &wT14_im, &wT22, &wT23_re, &wT23_im, &wT24_re, &wT24_im, &wT33, &wT34_re, &wT34_im, &wT44);
  IDAN_calc4(&par, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT14_re, rT14_im, rT22, rT23_re, rT23_im, rT24_re, rT24_im, rT33, rT34_re, rT34_im, rT44, &wT11, &wT12_re, &wT12_im, &wT13_re, &wT13_im, &wT14_re, &wT14_im, &wT22, &wT23_re, &wT23_im, &wT24_re, &wT24_im, &wT33, &wT34_re, &wT34_im, &wT44);

  free_imafl(&rT11);
  free_imafl(&rT12_re); free_imafl(&rT12_im);
  free_imafl(&rT13_re); free_imafl(&rT13_im);
  free_imafl(&rT14_re); free_imafl(&rT14_im);
  free_imafl(&rT22);
  free_imafl(&rT23_re); free_imafl(&rT23_im);
  free_imafl(&rT24_re); free_imafl(&rT24_im);
  free_imafl(&rT33);
  free_imafl(&rT34_re); free_imafl(&rT34_im);
  free_imafl(&rT44);

/* ECRITURE */
  write_imabin_init(&wri_T11);
  write_imabin_init(&wri_T12_re); write_imabin_init(&wri_T12_im);
  write_imabin_init(&wri_T13_re); write_imabin_init(&wri_T13_im);
  write_imabin_init(&wri_T14_re); write_imabin_init(&wri_T14_im);
  write_imabin_init(&wri_T22);
  write_imabin_init(&wri_T23_re); write_imabin_init(&wri_T23_im);
  write_imabin_init(&wri_T24_re); write_imabin_init(&wri_T24_im);
  write_imabin_init(&wri_T33);
  write_imabin_init(&wri_T34_re); write_imabin_init(&wri_T34_im);
  write_imabin_init(&wri_T44);

  write_imabin_ferm(&wri_T11, wT11, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_re, wT12_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T12_im, wT12_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_re, wT13_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T13_im, wT13_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T14_re, wT14_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T14_im, wT14_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T22, wT22, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_re, wT23_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T23_im, wT23_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T24_re, wT24_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T24_im, wT24_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T33, wT33, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T34_re, wT34_re, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T34_im, wT34_im, OR, OC, NRF, NCF);
  write_imabin_ferm(&wri_T44, wT44, OR, OC, NRF, NCF);

  free_imafl(&wT11);
  free_imafl(&wT12_re); free_imafl(&wT12_im);
  free_imafl(&wT13_re); free_imafl(&wT13_im);
  free_imafl(&wT14_re); free_imafl(&wT14_im);
  free_imafl(&wT22);
  free_imafl(&wT23_re); free_imafl(&wT23_im);
  free_imafl(&wT24_re); free_imafl(&wT24_im);
  free_imafl(&wT33);
  free_imafl(&wT34_re); free_imafl(&wT34_im);
  free_imafl(&wT44);
  } // PolType = C4

  return(1);
}


