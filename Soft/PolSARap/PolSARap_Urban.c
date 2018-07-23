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

File  : PolSARap_Urban.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 06/2014
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

*--------------------------------------------------------------------

Description :  PolSARap Urban Showcase

*--------------------------------------------------------------------

Adapted from c routine "Hysteresis Threshold.c"
written by : Elise Koniguer & Nicolas Trouve
ONERA - DEMR, Palaiseau, France 

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <memory.h>
#include <malloc.h>
#include <unistd.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

typedef struct IMAGE {
    int nbcol, nblig;
    float **valcmplx;
    float **valeur;
    unsigned char **output_sh;
    float **resultat;
    unsigned short **etic;
} IMAGE;

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
unsigned char **alloue_uc2(int nbcol, int nblig, int init);
void free_uc2(unsigned char **entite);
unsigned short **alloue_us2(int nbcol, int nblig, int init);
void free_us2(unsigned short **entite);
float **alloue_f2(int nbcol, int  nblig, int  init);
void free_f2(float **entite);
void lecture_f2(const char *nom, float **image, int nbcol, int nblig);
void ecriture_f2(float **resultat, const char *nom, int nbcol, int nblig);
void ecriture(unsigned char **resultat, const char *nom, int nbcol, int nblig);
int auto_4(struct IMAGE *image);
unsigned char *alloue_uc(int size, int init);

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
  FILE *f;
  char file_in[FilePathLength], file_out[FilePathLength];
  char file_out_bin[FilePathLength], file_out_txt[FilePathLength];
  
/* Internal variables */
  int i, j, nb_zones;
  int nbcol, nblig;;
  float Sh, Sb, param ;
  double moy;
  IMAGE image;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nPolSARap_Urban.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input complex coherence file\n");
strcat(UsageHelp," (string)	-of  	output file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 9) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,file_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,file_out,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&nblig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&nbcol,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  }

/********************************************************************
********************************************************************/

  check_file(file_in);
  sprintf(file_out_bin, "%s.bin", file_out);
  check_file(file_out_bin);
  sprintf(file_out_txt, "%s.txt", file_out);
  check_file(file_out_txt);

/********************************************************************
********************************************************************/
    /* image reading */
    /* the .txt contains the numbers of lines and columns */
    //strcpy(tmp, argv[1]);
    //strcat(tmp, ".txt");
    //f = fopen(tmp, "r");
  
    //if ((f=fopen(tmp, "r"))==NULL) {
    //    printf("\n file %s not found ", tmp);
    //    exit(-1);
    //}
    //else {
    //    fscanf(f, "%d\n%d", &image.nbcol, &image.nblig);
    //    fclose(f);
    //}

    image.nbcol = nbcol;
    image.nblig = nblig;
    
    image.valcmplx = alloue_f2(2*nbcol, nblig, 1);  
    
    if ((f=fopen(file_in, "rb"))==NULL) {
        printf("\n file %s not found", file_in);
        exit(-1);
    }
    else {
        lecture_f2(file_in, image.valcmplx, 2*image.nbcol, image.nblig);
        fclose(f);
    }
    
    image.valeur = alloue_f2(nbcol, nblig, 1);  
    for(i=0;i<nbcol;i++) {
        PrintfLine(i,nbcol);
        for (j=0;j<nblig;j++) {
            image.valeur[j][i] = sqrt(image.valcmplx[j][2*i]*image.valcmplx[j][2*i]+image.valcmplx[j][2*i+1]*image.valcmplx[j][2*i+1]);
            }
        }
    free_f2(image.valcmplx);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */
    moy = 0.;
    for(i=0;i<nbcol;i++) {
        PrintfLine(i,nbcol);
        for (j=0;j<nblig;j++) {
            moy+=image.valeur[j][i];
            }
        }
    
    moy/=(nbcol*nblig);
    param =0.2;
    Sb  = moy ;
    Sh  = moy + param ;
    
    /* low treshold */
    image.output_sh = alloue_uc2(nbcol, nblig, 1);
    image.resultat = alloue_f2(nbcol, nblig, 1);
    
    moy = 0;
    for(i=0;i<nbcol;i++) {
        PrintfLine(i,nbcol);
        for (j=0;j<nblig;j++) {
            image.resultat[j][i]=0;
            if (((double)image.valeur[j][i]>Sb)) {
                image.resultat[j][i] = 1;
                if (((double)image.valeur[j][i]>Sh))
                    image.output_sh[j][i]=1;
                }
            }
        }
    
    /* labels of regions */
    nb_zones = auto_4(&image);
    
    /* test of regions in terms of high threshold */
    int *valide;
    
    valide = (int *)malloc(nb_zones*sizeof(int));
    for(i=0;i<nb_zones;i++) valide[i]=0;
    
    for(i=0;i<nbcol;i++) {
        PrintfLine(i,nbcol);
        for (j=0;j<nblig;j++)
            if ((image.output_sh[j][i]==1) & (image.etic[j][i]>=9))
                valide[image.etic[j][i]-9]=1;
        }
    
    for(i=0;i<nbcol;i++) {
        PrintfLine(i,nbcol);
        for (j=0;j<nblig;j++) {
            image.resultat[j][i]=0;
            if (image.etic[j][i]>=9) {
                if(valide[image.etic[j][i]-9]==1)
                    image.resultat[j][i]=1;
                }              
            }
        }

/********************************************************************
********************************************************************/
/* Save results */
    //strcpy(tmp, argv[1]);
    //strcat(tmp, "_thresh.bin");
    if ((f=fopen(file_out_bin, "w"))==NULL) {
        printf("\n Problem for file writting %s", file_out_bin);
        exit(-1);
    }
    else {
        ecriture_f2(image.resultat, file_out_bin, nbcol, nblig);
        fclose(f);
        //strcpy(tmp, argv[1]);
        //strcat(tmp, "_thresh.txt");
        f=fopen(file_out_txt, "wt");
        fprintf(f, "%d\n%d\n1", nbcol, nblig);
        fclose(f);
    }

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

    /* Memory free */
    free_f2(image.valeur);
    free(valide);
    free_f2(image.resultat);
    free_uc2(image.output_sh);
    free_us2(image.etic);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
unsigned short **alloue_us2(int nbcol, int nblig, int init) {
    register int i, j;
    unsigned short **entite;
    if (((entite = (unsigned short **) malloc((unsigned)nblig*sizeof(unsigned short *))) == NULL) || ((entite[0] = (unsigned short *)malloc((unsigned)(nblig*nbcol)*sizeof(unsigned short))) == NULL)) {
        printf("Allocation Failure in alloue_us2\n");
        exit(-1);
    }
    for (i = 1; i < nblig; i++)
        entite[i] = entite[0]+nbcol*i;
    if (init == 1)
        for (i = 0; i < nblig; i++)
            for (j = 0; j < nbcol; j++)
                entite[i][j] = 0;
    return(entite);    
}

/********************************************************************
********************************************************************/
void free_us2(unsigned short **entite) {
    free((unsigned short *)entite[0]);
    free((unsigned short *)entite);
}

/********************************************************************
********************************************************************/
/* Allocation for an float image */
float **alloue_f2(int nbcol, int  nblig, int  init) {
    float **entite;
    register int i, j;
    if (((entite = (float **) malloc((unsigned)nblig*sizeof(float *))) == NULL) || ((entite[0] = (float *)malloc((unsigned)(nblig*nbcol)*sizeof(float))) == NULL)) {
        printf("Allocation failure in alloue_f2\n");
        exit(-1);
    }
    for (i = 1; i < nblig; i++) {
        entite[i] = entite[0]+nbcol*i;
        if (entite[i] == NULL)
            printf("Warning, bug...\n");
    }
    if (init == 1)
        for (i = 0; i < nblig; i++)
            for (j = 0; j < nbcol; j++)
                entite[i][j] = 0;
    return(entite);    
}
 
/********************************************************************
********************************************************************/
/* Free float 2 dimensional table */
void free_f2(float **entite) {
    free((float *)entite[0]);
    free((float *)entite);
}
 
/********************************************************************
********************************************************************/
void lecture_f2(const char *nom, float **image, int nbcol, int nblig) {
    int i;
    FILE *f;
    if ((f=fopen(nom, "rb"))==NULL) {
        perror(nom);
        exit(-1);
    }
    for (i=0;i<nblig;i++) fread(image[i], sizeof(float), nbcol, f);
    fclose(f);
}

/********************************************************************
********************************************************************/
void ecriture_f2(float **resultat, const char *nom, int nbcol, int nblig) {
    register int i;
    FILE *f;
    
    if ((f=fopen(nom, "wb"))==NULL) {
        perror(nom);
        exit(-1);
    } 
    
    for (i=0;i<nblig;i++) fwrite(resultat[i], sizeof(float), nbcol, f);
    
    fclose(f);
}

/********************************************************************
********************************************************************/
/* Image Allocation in uc    */
unsigned char **alloue_uc2(int nbcol, int nblig, int init) {
    register int i, j;
    unsigned char **entite;
    
    /* Image Allocation */
    
    if (((entite = (unsigned char **) malloc((unsigned)nblig*sizeof(unsigned char *))) == NULL) || ((entite[0] = (unsigned char *)malloc((unsigned)(nblig*nbcol)*sizeof(unsigned char))) == NULL)) {
        printf("Allocation failure in alloue_uc2\n");
        exit(-1);
    }
    for (i = 1; i < nblig; i++) {
        entite[i] = entite[0]+nbcol*i;
        if (entite[i] == NULL)
            printf("Warning...\n");
    }
    if (init == 1)
        for (i = 0; i < nblig; i++)
            for (j = 0; j < nbcol; j++)
                entite[i][j] = 0;
    return(entite);    
}

/********************************************************************
********************************************************************/
/* 2 dimensional uc table liberation */
void free_uc2(unsigned char **entite) {
    free((char *)entite[0]);
    free((char *)entite);
}
 
/********************************************************************
********************************************************************/
/* uc coded image saving */
void ecriture(unsigned char **resultat, const char *nom, int nbcol, int nblig) {
    int i;
    FILE *f;
    
    if ((f=fopen(nom, "wb"))==NULL) {
        perror(nom);
        exit(-1);
    }
    for (i=0;i<nblig;i++) fwrite(resultat[i], sizeof(unsigned char), nbcol, f);
    fclose(f);
}
 
/********************************************************************
********************************************************************/
void lecture_uc2(const char *nom, unsigned char **image, int nbcol, int nblig) {
    register int i;
    FILE *f;
    
    if ((f=fopen(nom, "rb"))==NULL) {
        perror(nom);
        exit(-1);
    }
    for (i=0;i<nblig;i++) fread(image[i], sizeof(unsigned char), nbcol, f);
    fclose(f);
}
 
/********************************************************************
********************************************************************/
int test_pixel(struct IMAGE *image, int ligne, int colonne, int val)
/* Test */
{
    
    if (image->resultat[ligne][colonne]==val)
        return(1);
    else
        return(0);
}

/********************************************************************
********************************************************************/
int auto_4(struct IMAGE *image) {
    
    int numero;
    unsigned char *parcours;
    int i, j, i_courant, j_courant, i_acces, j_acces;
    
    image->etic = alloue_us2(image->nbcol, image->nblig, 1);
    parcours = alloue_uc(image->nbcol*image->nblig, 1);
    for (i = 0; i < image->nblig; i++) {
        parcours[i*image->nbcol] = 7;
        parcours[i*image->nbcol+image->nbcol-1] = 7;
    }
    for (j = 0; j < image->nbcol; j++) {
        parcours[j] = 7;
        parcours[(image->nblig-1)*image->nbcol+j] = 7;
    }
    
    /*** labeling ***/
    
    numero = 9;
    
    /* Beginning Point */
    for (i = 0; i < image->nblig; i++)
        for (j = 0; j < image->nbcol; j++) {
        if ((image->resultat[i][j] == 1) && (parcours[i*image->nbcol+j] == 0)) {
            i_acces = i;
            j_acces = j;
            i_courant = i;
            j_courant = j;
            parcours[i_courant*image->nbcol+j_courant] = 5; /* labels the current point with 5 */
            
            
            label_gauche:
                if ((parcours[i_courant*image->nbcol+j_courant-1] == 0) && (image->resultat[i_courant][j_courant-1] == 1)) {
                    j_courant -= 1;
                    parcours[i_courant*image->nbcol+j_courant] = 1;
                    goto label_gauche;
                }
                
                label_bas:
                    if ((parcours[(i_courant+1)*image->nbcol+j_courant] == 0) && (image->resultat[i_courant+1][j_courant] == 1)) {
                        i_courant += 1;
                        parcours[i_courant*image->nbcol+j_courant] = 2;
                        goto label_gauche;
                    }
                    
                    label_droite:
                        if ((parcours[i_courant*image->nbcol+j_courant+1] == 0) && (image->resultat[i_courant][j_courant+1] == 1)) {
                            j_courant += 1;
                            parcours[i_courant*image->nbcol+j_courant]= 3;
                            goto label_gauche;
                        }
                        
                        label_haut:
                            if ((parcours[(i_courant-1)*image->nbcol+j_courant] == 0) &&  (image->resultat[i_courant-1][j_courant] == 1)) {
                                i_courant -= 1;
                                parcours[i_courant*image->nbcol+j_courant] = 4;
                                goto label_gauche;
                            }
                            
                            label_depile:
                                switch(parcours[i_courant*image->nbcol+j_courant]) {
                                    case 1: image->etic[i_courant][j_courant] = numero;
                                    j_courant += 1;
                                    goto label_bas;
                                    
                                    case 2: image->etic[i_courant][j_courant] = numero;
                                    i_courant -= 1;
                                    goto label_droite;
                                    
                                    case 3: image->etic[i_courant][j_courant] = numero;
                                    j_courant -= 1;
                                    goto label_haut;
                                    
                                    case 4: image->etic[i_courant][j_courant] = numero;
                                    i_courant += 1;
                                    
                                    goto label_depile;
                                    
                                    case 5: image->etic[i_courant][j_courant] = numero;
                                    numero++;
                                    break;
                                    
                                    default: printf(" strong Error !\n");
                                    exit(-1);
                                }                             
        }
        }
    free((char *)parcours);
    return(numero-9);  
}
 
/********************************************************************
********************************************************************/
unsigned char *alloue_uc(int size, int init) {
    
    unsigned char *entite;
    int i;
    
    if ((entite = (unsigned char *)malloc((unsigned)size*sizeof(unsigned char))) == NULL) {
        printf("Allocation error in alloue_uc");
        exit(-1);
    }
    if (init == 1)
        for (i = 0; i < size; i++)
            entite[i] = 0;
    return(entite);   
}


