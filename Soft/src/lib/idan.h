/*******************************************************************************

File     : idan.h
Project  : ESA_POLSARPRO
Authors  : Gabriel VALISE, Emmanuel TROUVE
Version  : 1.0
Creation : 02/2007
Update   :

*-------------------------------------------------------------------------------
GIPSA-Campus
ENSIEG, Domaine Universitaire
961 rue de Houille Blanche - BP46
38402 SAINT MARTIN D'HERES
Tel :(+33) 4 76 82 71 39
Fax :(+33) 4 76 82 63 84
e-mail : gabriel.vasile@lis.inpg.fr, emmanuel.trouve@lis.inpg.fr
*-------------------------------------------------------------------------------

Description :  IDAN (Intensity Driven Adaptive Neighbourhood) Routines

*******************************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <math.h>


#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

#ifndef IDAN_H
#define IDAN_H

typedef unsigned char pixu1;

typedef struct{
   FILE  *dffi;        /* descripteur fichier image */
   char nom[200];   /* nom du fichier, sans suffix */
   char ext[10];
} write_imabin_t;

typedef struct{
   char nom[200];  /* nom du fichier, sans suffix */
   char ext[10];     
}read_imabin_t;

/* image float	*/
typedef float pixfl;
struct imagefl {				
    pixfl **p;
    int   nc;	/* nbr of columns 	*/
    int	  nr;	/* nbr of rows		*/
    char nom[200];   /* name      */
};
typedef struct imagefl imafl;


/* parametre */
struct parametre{
    char qst[200];  /* question  */
    char rep[200];  /* reponse   */
    struct parametre *next;
};
typedef struct parametre param;

/* structure for the AN coordinates */
typedef struct {int m,n;} COORD;

typedef struct{

  /* parameters for the region growing */
  double speckle_std;
  int MAX_REGION_SIZE, filt_amount;

  /* buffers for the region growing */
  unsigned int *map,**Pmap;
  unsigned int region_count, background_count;
  COORD *region, *background;
  int laba;
  unsigned int label;
} IDAN_t;


/* debut/fin de programme */
int param_debut(int argc, char **argv, param *ptp);
int param_fin(int argc, char **argv, param *ptp);

/* lecture de parametre */
void lec_param(char *chaine, param *ptp);
int flec_param(FILE *fp, param *ptp);
void alloc_param(param *ptp);
void lec_int(int *pt_i, char *chaine);
void lec_float(float *pt_f, char *chaine);
void lec_double(double *pt_d, char *chaine);
void lec_nom(char *pt_nom, char *chaine);
int nom_image_suivante( char *nom0, char *nomres);

int free_imafl(imafl *im);
int alloc_imafl(imafl *im);
int read_imabin_init(read_imabin_t *des, imafl *im, int NC, int NL);
int write_imabin_init(write_imabin_t *de);
int write_imabin_ferm(write_imabin_t *des, imafl im, int OR, int OC, int NRF, int NCF);

/* functions for the IDAN computation */

double EstimateLocalMean_anf_int(IDAN_t *des, imafl image, int im, int jm, int iM, int jM);
void GrowRegion_anf_int(IDAN_t *des, int m, int n, double *PmH1, double *PmV1, double *PmX1, imafl rT11, imafl rT22, imafl rT33);
void ReviseRegion_anf_int(IDAN_t *des, double maH1, double maV1, double maX1, imafl rT11, imafl rT22, imafl rT33);
int ComputeFilteredMeasures_anf_int(IDAN_t *des , int ii, int jj, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT33, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT33);

/* external functions */
double ABS(double a);
char *Calloc(unsigned, unsigned);

/* IDAN functions */
param *IDAN_lect(IDAN_t *des, param *ptp, char *debq);
int IDAN_init(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT33, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT33);
int IDAN_calc(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT33, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT33);

/* NEW ROUTINE ADDED BY POLSARPRO */
int convert_S2_T3(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT33, int NC, int NR);

/* NEW ROUTINE ADDED BY POLSARPRO */
int convert_S2_T4(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT14_re, imafl *rT14_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT24_re, imafl *rT24_im, imafl *rT33, imafl *rT34_re, imafl *rT34_im, imafl *rT44, int NC, int NR);

/* NEW ROUTINE ADDED BY POLSARPRO */
int convert_SPP_C2(imafl rs11, imafl rs12, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT22, int NC, int NR);

/* NEW ROUTINE ADDED BY POLSARPRO */
int convert_S2_C3(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT33, int NC, int NR);

/* NEW ROUTINE ADDED BY POLSARPRO */
int convert_S2_C4(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT14_re, imafl *rT14_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT24_re, imafl *rT24_im, imafl *rT33, imafl *rT34_re, imafl *rT34_im, imafl *rT44, int NC, int NR);

/* NEW IDAN functions ADDED BY POLSARPRO */
int IDAN_init2(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT22, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT22);
int IDAN_calc2(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT22, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT22);
void GrowRegion_anf_int2(IDAN_t *des, int m, int n, double *PmH1, double *PmV1, imafl rT11, imafl rT22);
void ReviseRegion_anf_int2(IDAN_t *des, double maH1, double maV1, imafl rT11, imafl rT22);
int ComputeFilteredMeasures_anf_int2(IDAN_t *des , int ii, int jj, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT22, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT22);

int IDAN_init4(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT14_re, imafl rT14_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT24_re, imafl rT24_im, imafl rT33, imafl rT34_re, imafl rT34_im, imafl rT44, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT14_re, imafl *wT14_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT24_re, imafl *wT24_im, imafl *wT33, imafl *wT34_re, imafl *wT34_im, imafl *wT44);
int IDAN_calc4(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT14_re, imafl rT14_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT24_re, imafl rT24_im, imafl rT33, imafl rT34_re, imafl rT34_im, imafl rT44, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT14_re, imafl *wT14_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT24_re, imafl *wT24_im, imafl *wT33, imafl *wT34_re, imafl *wT34_im, imafl *wT44);
void GrowRegion_anf_int4(IDAN_t *des, int m, int n, double *PmH1, double *PmV1, double *PmX1, double *PmY1, imafl rT11, imafl rT22, imafl rT33, imafl rT44);
void ReviseRegion_anf_int4(IDAN_t *des, double maH1, double maV1, double maX1, double maY1, imafl rT11, imafl rT22, imafl rT33, imafl rT44);
int ComputeFilteredMeasures_anf_int4(IDAN_t *des , int ii, int jj, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT14_re, imafl rT14_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT24_re, imafl rT24_im, imafl rT33, imafl rT34_re, imafl rT34_im, imafl rT44, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT14_re, imafl *wT14_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT24_re, imafl *wT24_im, imafl *wT33, imafl *wT34_re, imafl *wT34_im, imafl *wT44);

#endif



