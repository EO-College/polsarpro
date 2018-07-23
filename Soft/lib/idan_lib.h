/*******************************************************************************

File     : idan_lib.h
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
#ifndef IDAN_LIB
#define IDAN_LIB

#ifdef IDAN_MAIN
#include "idan.h"
#endif

#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <stdio.h>
#include <malloc.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <ctype.h>

#define PERMS   0644
#define PI      3.141592654
#define ROUND(X)    ((int)((X)+.5))
#define MAX(X,Y)    (((X)<(Y))?(Y):(X))
#define MIN(X,Y)    (((X)<(Y))?(X):(Y))
#define SQR(X)      ((X)*(X))
#define SWAP(X,Y)   temp = (X);(X) = (Y);(Y) = temp
#define IEEE_MAX_FLOAT   0x7f7fffff
#define tresh_u1 255

/******************************************************************************/
/******************************************************************************/
/******************************************************************************/

int write_imabin_init(write_imabin_t *des){ 
  char nom_ima[1024];
  sprintf(nom_ima, "%s.%s", des->nom, des->ext);
  if(strcmp(des->ext, "bin")== 0 ){
    if( (des->dffi=fopen(nom_ima, "wb")) == NULL ){
      printf("\n>> ERREUR write_imabin_init: creation fichier %s impossible\n",nom_ima);
      exit(1);
    }  
  }
  return(0);  
}


/* image float */
int write_imabin_ferm(write_imabin_t *des, imafl im, int OR, int OC, int NRF, int NCF){   /* .imf       */
  int i,j;   
  for(i = 0; i < NRF; i++) {
	  for(j = 0; j < NCF; j++) im.p[i+OR][j] = im.p[i+OR][j+OC];
	  fwrite(im.p[i+OR], sizeof(float), NCF, des->dffi);
  }
  return(0);
}


/* image float */
int read_imabin_init(read_imabin_t *des, imafl *im, int NC, int NL){   /* .imf       */
  FILE *fima;
  char nom_ima[1024];
  register int  j;

  sprintf(nom_ima, "%s.%s", des->nom, des->ext);

  im->nc = NC;
  im->nr = NL;

  if((fima=fopen(nom_ima, "rb")) != NULL) {
      alloc_imafl(im);
      for(j = 0; j < im->nr; j++)
	fread(im->p[j], sizeof(float), im->nc, fima);
  }
  else{
      printf("\n>> ERREUR read_imabin_init : Fichier %s introuvable\n", nom_ima);
      exit(1);
  }
  strcpy(im->nom, nom_ima);
  return(0);
}

/* Functions BATI */


int free_imafl(imafl *im){
  free(im->p[0]);
  free(im->p);
  return(0);
}

/* allocation d'une image type imafl (reel 4 octets) */
int alloc_imafl(imafl *im){
  int j;
 
  /* tableau d'adresses des debuts de ligne                             */
  if( (im->p = (pixfl **)malloc(im->nr*sizeof(pixfl *))) == NULL )
        {printf ("\n allocation image impossible\n");  exit(1);}
 
  /* tableau 1D donnant l'image en 1 seul bloc, ligne apres ligne       */
  if( (im->p[0] = (pixfl *)malloc(im->nc*im->nr*sizeof(pixfl))) == NULL)
        {printf ("\n allocation image impossible\n");  exit(1); }
 
  /* positionnement des pointeurs de debut de ligne                     */
  for(j = 1; j < im->nr; j++)
        im->p[j] =  im->p[0] + j*(im->nc);

  /* chaine du nom */
  strcpy(im->nom, "");
  return(0);
}

/* fonctions pour la lectrure des parametres */

/* ************************ param_debut *****************************/
/** gestion des parametres en debut de main selon les 3 modes.\\
\\
1. MANUEL : \\
- lancement sans argument,\\
- saisie manuelle des parametres\\
=> param_fin va creer un fichier ctrl avec valeurs rentrees et questions\\
\\
2. FICHIER : \\
- lancement avec 1 seul argument : le nom du fichier de parametre, extension .ctrl\\
- questions avec valeurs par defaut lues dans le fichier\\
=> param_fin va sauvegarder les nouveaux parametres \\
\\
3. AUTOMATIQUE : \\
- lancement avec les parametres passes par argv\\
- pas de question et pas de fichier \\
=> mode utilise par l'interface graphique qui va gerer elle-meme les fichiers .ctrl\\
\\
sortie :\\
- Mode 1 : ptp->qst[0] = ptp->rep[0] = '\0', ptp->next = NULL\\
- Mode 2 : chaine de parametres (questions et reponses) initialisees a partir du fichier\\
- Mode 3 : chaine de parametres (reponses seules) initialisee a partir de argv, qst[0]='\0'
   @param argc nombre de chaines de la ligne de lancement 
   @param argv contenu des chaines de la ligne de lancement 
   @param ptp  pointeur (deja alloue) de structure de parametre : 
   debut de la liste chainee
*/

int param_debut(int argc, char **argv, param *ptp){
  FILE *fp;
  int l;

  ptp->qst[0] = '\0';
  ptp->rep[0] = '\0';
  ptp->next = NULL;
  /*printf("\n\n\t\t >>> programme %s <<< \n\n", argv[0]);*/

  /* lecture manuelle */
  if(argc == 1){
      printf("\n>> param_debut, mode MANUEL\n");
      return(0);
  }

  l = strlen(argv[1]);
  do
      l--;
  while(argv[1][l] != '.'  && l>0);

  /* lecture des valeurs par defaut dans un fichier .ctrl */
  if( (argc == 2) && (strcmp(argv[1]+l, ".ctrl") == 0) ){
      if( (fp=fopen(argv[1], "r")) == NULL ){
          printf("\n>> ERREUR param_debut : fichier %s introuvable\n", argv[1]);
          exit(1);
      }      
      l = 0;
      while( flec_param(fp, ptp) ){
	  ptp = ptp->next;
	  l++;
      }
      printf("\n>> param_debut, mode FICHIER : %d parametres lus dans %s\n", l, argv[1]);
      fclose(fp);
      return(0);
  }  

  /* automatique : parametres transmis par argv */
  for(l=1; l<argc; l++){
      ptp->qst[0] = '\0';
      strcpy(ptp->rep, argv[l]);
      alloc_param(ptp);
      ptp = ptp->next;
  } 
  /*printf("\n>> param_debut, mode AUTO : %d parametres passes en ligne\n", argc-1, argv[1]);*/
  return(0);
}

/* ************************ param_fin *****************************/

int param_fin(int argc, char **argv, param *ptp){
  FILE *fp;
  char nom[1024];
  int l;

  if( argc == 1 )                         /* lecture manuelle */ 
      sprintf(nom, "%s.ctrl", argv[0]);
  else if ( argc == 2 ){
      l = strlen(argv[1]);
      do
	  l--;
      while(argv[1][l] != '.'  && l>0);
      if(strcmp(argv[1]+l, ".ctrl") == 0) /* lecture issue d'un fichier */
	  strcpy(nom, argv[1]);
      else
	  return(0);  
  }
  else 
      return(0);

  lec_nom(nom, ">> param_fin : fichier de sauvegarde des nouveaux parametres");
  l = strlen(nom);
  do
      l--;
  while(nom[l] != '.'  && l>0);
  if( l == 0 )
      strcat(nom, ".ctrl");
  else if (strcmp(nom+l, ".ctrl") != 0){
      strcat(nom, ".ctrl");
      printf("\n>> ATT param_fin : extension erronee, .ctrl ajoutee => %s\n",
	     nom);
  }
 if( (fp=fopen(nom, "w")) == NULL ){
      printf("\n>> ERREUR param_fin : fichier %s inouvable\n", nom);
      exit(1);
  }
  while(ptp->qst[0] != '\0' && ptp->rep[0] != '\0'){
      fprintf(fp, "%s\t\t#%s\n", ptp->rep, ptp->qst);
      ptp = ptp->next;
  }    
  fclose(fp);
  return(0);
} 

/* ************************* lec_param  **********************************/

void lec_param(char *chaine, param *ptp){ 
  char replue[1024];

  /* Mode 1 : saisie manuelle */
  if( (ptp->qst[0] == '\0') && (ptp->rep[0] == '\0') ){
      strcpy(ptp->qst, chaine);
      do{
	  printf("\n%s? : ", ptp->qst);
	  //gets(ptp->rep);
	  fgets(ptp->rep, sizeof(ptp->rep), stdin);
      }while( ptp->rep == '\0' );

  }

  /* mode 2 : fichier + confirmation manuelle */
  else if ( (ptp->qst[0] != '\0') && (ptp->rep[0] != '\0') ){
      if( strcmp(ptp->qst, chaine) ){
	  printf("\nATT lec_param : questions differentes : \n\t- fichier .ctrl => %s\n\t- source C => %s\n", ptp->qst, chaine);
	  strcpy(ptp->qst, chaine); 
      }
      printf("\n%s? [%s] : ", ptp->qst, ptp->rep); 
      //gets(replue);
	  fgets(replue, sizeof(replue), stdin);
      if( replue[0] != '\0')
	  strcpy(ptp->rep, replue);
  }
  
  /* mode 3 : automatique, pas de qestion */
  else if ( (ptp->qst[0] == '\0') && (ptp->rep[0] != '\0') ){
    /*printf("\n%s = %s\n", chaine, ptp->rep);*/
  }

  /* erreur */
  else{
      printf("\nERREUR lec_param : qst=%s, rep=%s\n", ptp->qst, ptp->rep);
  }
  if( ptp->next == NULL )
      alloc_param(ptp);
}


/* ************************* flec_param  **********************************/

int flec_param(FILE *fp, param *ptp){ 
  char tmpc;
  int i=-1;
  
  if( fscanf(fp, "%s", ptp->rep) == 0 ) 
      return(0);

  do
      tmpc = (char)fgetc(fp);
  while( tmpc != '#' && tmpc != EOF );
  if(tmpc == EOF)
      return(0);

  do{
      i++;
      ptp->qst[i] = (pixu1)fgetc(fp);
  }while( ptp->qst[i]!='\n' && ptp->qst[i]!=EOF && i<199 );
  if(ptp->qst[i] == EOF)
      return(0);

  if( i == 199 ){
      printf("\n ATT flec_param : question trop longue (>199 caracteres)\n");
      do
	  tmpc = (pixu1)fgetc(fp);
      while( tmpc != '\n' && tmpc != EOF);      
  }
  ptp->qst[i] = '\0';

  if( ptp->next == NULL )
      alloc_param(ptp);
  return(1);
}

/* ************************* alloc_param  **********************************/

void alloc_param(param *ptp){
  /* allocation parametre suivant */
  if( (ptp->next = (param*)malloc(sizeof(param))) == NULL ){
      printf ("\nERREUR alloc_param : allocation  impossible\n");  
      exit(1);      
  }
  ptp->next->qst[0] = '\0';
  ptp->next->rep[0] = '\0';
  ptp->next->next = NULL;
}

void lec_int(int *pt_i, char *chaine){
  char rep[1024];
 
  printf("\n%s? [%d] : ", chaine, *pt_i);
  //gets(rep);
  fgets(rep, sizeof(rep), stdin);
  if (rep[0] != '\0')
        *pt_i = atoi(rep);
}

void lec_float(float *pt_f, char *chaine){
  char rep[1024];
 
  printf("\n%s? [%.3f] : ", chaine, *pt_f);
  //gets(rep);
  fgets(rep, sizeof(rep), stdin);
  if (rep[0] != '\0')
        *pt_f = (float)atof(rep);
}

void lec_double(double *pt_d, char *chaine){
  char rep[1024];
 
  printf("\n%s? [%.3f] : ", chaine, *pt_d);
  //gets(rep);
  fgets(rep, sizeof(rep), stdin);
  if (rep[0] != '\0')
        *pt_d = atof(rep);
}
 

void lec_nom(char *pt_nom, char *chaine){
char rep[1024];
 
printf("\n%s? [%s] : ", chaine, pt_nom);
//gets(rep);
fgets(rep, sizeof(rep), stdin);
if (rep[0] != '\0')
        strcpy(pt_nom, rep);
}


/**************************************** IDAN functions ******************************************************/

/* *************************  LECTURE  *******************************/

param *IDAN_lect(IDAN_t *des, param *ptp, char *debq){
  char question[500];

  sprintf(question, "%s Maximum region size (integer) :", debq); 
  lec_param(question, ptp);
  des->MAX_REGION_SIZE = atoi(ptp->rep);
  ptp = ptp->next;
  
  sprintf(question, "%s Equivalent number of looks L_eq (float) :", debq); 
  lec_param(question, ptp);
  des->speckle_std = sqrt(1/atof(ptp->rep));
  ptp = ptp->next;
  
  sprintf(question, "%s Filtering amount Low = 0 / High = 1 (binary) :", debq); 
  lec_param(question, ptp);
  des->filt_amount = atoi(ptp->rep);
  ptp = ptp->next;
  
  
  return(ptp);
}

/* *************************  INITIALISATION  ***************************/

int IDAN_init(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT33, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT33){ 
  int image_height, image_width, i;

  image_height = rT11.nr;
  image_width  = rT11.nc;

  /* images resultat */ 
  wT11->nc = rT11.nc;
  wT11->nr = rT11.nr;
  alloc_imafl(wT11);

  wT12_re->nc = rT11.nc;
  wT12_re->nr = rT11.nr;
  alloc_imafl(wT12_re);

  wT12_im->nc = rT11.nc;
  wT12_im->nr = rT11.nr;
  alloc_imafl(wT12_im);

  wT13_re->nc = rT11.nc;
  wT13_re->nr = rT11.nr;
  alloc_imafl(wT13_re);

  wT13_im->nc = rT11.nc;
  wT13_im->nr = rT11.nr;
  alloc_imafl(wT13_im);


  wT22->nc = rT11.nc;
  wT22->nr = rT11.nr;
  alloc_imafl(wT22);

  wT23_re->nc = rT11.nc;
  wT23_re->nr = rT11.nr;
  alloc_imafl(wT23_re);

  wT23_im->nc = rT11.nc;
  wT23_im->nr = rT11.nr;
  alloc_imafl(wT23_im);


  wT33->nc = rT11.nc;
  wT33->nr = rT11.nr;
  alloc_imafl(wT33);


  /* buffers for the region growing */
  des->map = (unsigned int *) Calloc(image_width*image_height, sizeof(*(des->map)));
  des->Pmap = (unsigned int **) Calloc(image_height, sizeof(*(des->Pmap)));
  des->region = (COORD *) Calloc(10*des->MAX_REGION_SIZE, sizeof (*(des->region)));
  des->background = (COORD *) Calloc(10*des->MAX_REGION_SIZE, sizeof (*(des->background)));
  des->label = 0;

  for (i=0; i<image_height; i++)
    {
      des->Pmap[i] = des->map + i*image_width;
    }
  return(0);
}


/* *************************  CALCUL  ***************************/

int IDAN_calc(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT33, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT33){ 
  int i, j, image_width, image_height;
  double maHH1, maVV1, maXX1;
  
  image_height = rT11.nr;
  image_width = rT11.nc;
  
  for(i=0; i<(image_height); i++) {
	if (i%(int)(image_height/20) == 0) {printf("%f\r", 100. * i / (image_height - 1));fflush(stdout);}
    for(j=0; j<(image_width); j++){
      GrowRegion_anf_int(des, i, j, &maHH1, &maVV1, &maXX1, rT11, rT22, rT33);
      ReviseRegion_anf_int(des, maHH1, maVV1, maXX1, rT11, rT22, rT33);	  
      ComputeFilteredMeasures_anf_int(des, i, j, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT22, rT23_re, rT23_im, rT33, wT11, wT12_re, wT12_im, wT13_re, wT13_im, wT22, wT23_re, wT23_im, wT33);
	}
  }     
  return(0);
}

/* fin doc en sous partie */ 


/****************************************************************************************************************************************/

double EstimateLocalMean_anf_int(IDAN_t *des, imafl image, int im, int jm, int iM, int jM){
  int i, j, k;
  double table[9], temp;

   k = 0;
   for (i = im; i <= iM; i++)
      for (j = jm; j<= jM; j++)
	  table[k++] = (double)image.p[i][j];
	 
   for (i = 0; i < k; i++)
      for (j = k-1; j > i; j--)
         if (table[j] < table[j-1])
	    {
	    SWAP(table[j],table[j-1]);
	    }
   
   return table[k/2];
}

/****************************************************************************************************************************************/

void GrowRegion_anf_int(IDAN_t *des, int m, int n, double *PmH1, double *PmV1, double *PmX1, imafl rT11, imafl rT22, imafl rT33){

  int i, j, im, jm, iM, jM, k, image_height, image_width;
  double threshold;
  double mean_aH1, mean_aV1, mean_aX1, dist, dist1, dist2, dist3, idan_2;

   idan_2 = 0.7;
   
   if ((des->filt_amount) == 1)
      idan_2 = 1.0;

   des->region_count = 1;
   des->background_count = 0;
   des->region[0].m = m;
   des->region[0].n = n;

   des->Pmap[m][n] = ++(des->label);

   image_height = rT11.nr;
   image_width = rT11.nc;

   *PmH1 = rT11.p[m][n];
   *PmV1 = rT22.p[m][n];
   *PmX1 = rT33.p[m][n];

   im = MAX(0,m-1);
   jm = MAX(0,n-1);
   iM = MIN(image_height-1,m+1);
   jM = MIN(image_width-1,n+1);
   
   mean_aH1 = EstimateLocalMean_anf_int(des, rT11, im, jm, iM, jM);   
   mean_aV1 = EstimateLocalMean_anf_int(des, rT22, im, jm, iM, jM);   
   mean_aX1 = EstimateLocalMean_anf_int(des, rT33, im, jm, iM, jM);

   threshold = idan_2 * 3 * des->speckle_std;

   for (k=0; k< des->region_count; k++)
      {
      m = des->region[k].m;
      n = des->region[k].n;
      im = MAX(0,m-1);
      jm = MAX(0,n-1);
      iM = MIN(image_height-1,m+1);
      jM = MIN(image_width-1,n+1);
      for (i = im; i <= iM; i++)
	for (j = jm; j <=jM; j++) 
	  {
	    if ((des->region_count) > (des->MAX_REGION_SIZE))
	      break;

	    if (des->Pmap[i][j] != des->label)
	      {
		des->Pmap[i][j] = des->label;
		
		dist1 = sqrt(SQR(rT11.p[i][j] - mean_aH1) / SQR(mean_aH1));
		dist2 = sqrt(SQR(rT22.p[i][j] - mean_aV1) / SQR(mean_aV1));
		dist3 = sqrt(SQR(rT33.p[i][j] - mean_aX1) / SQR(mean_aX1));
		
		dist = (dist1 + dist2 + dist3);
		
		if (dist < threshold)
	          {
		    des->region[des->region_count].m = i;
		    des->region[des->region_count++].n = j;
		    
		    (*PmH1) += (rT11.p[i][j]);
		    (*PmV1) += (rT22.p[i][j]);
		    (*PmX1) += (rT33.p[i][j]);
		  }
	       else
		 {
		   des->background[des->background_count].m = i;
		   des->background[des->background_count++].n = j;
		 }
	      }
	  }
      }
   (*PmH1) /= des->region_count;
   (*PmV1) /= des->region_count;
   (*PmX1) /= des->region_count;
    
}

/****************************************************************************************************************************************/

void ReviseRegion_anf_int(IDAN_t *des, double maH1, double maV1, double maX1, imafl rT11, imafl rT22, imafl rT33){
  int i, temp11, temp22;
//int  image_height, image_width;
  double threshold, dist, dist1, dist2, dist3, idan_4;

  idan_4 = 2;

//  image_height = rT11.nr;
//  image_width = rT11.nc;

  threshold = idan_4 * 3 * des->speckle_std;

  for (i=0; i< des->background_count; i++)
      {
	//if ((des->region_count) > (des->MAX_REGION_SIZE))
	//break;
	
	temp11=(des->background)[i].m;
	temp22=(des->background)[i].n;

	dist1 = sqrt(SQR(rT11.p[temp11][temp22] - maH1) / SQR(maH1));
	dist2 = sqrt(SQR(rT22.p[temp11][temp22] - maV1) / SQR(maV1));
	dist3 = sqrt(SQR(rT33.p[temp11][temp22] - maX1) / SQR(maX1));

	dist = (dist1 + dist2 + dist3);

	if (dist < threshold)
	  {
	   des->region[des->region_count].m = des->background[i].m;
	   des->region[des->region_count++].n = des->background[i].n;
	  }
      }
}

/****************************************************************************************************************************************/
int ComputeFilteredMeasures_anf_int(IDAN_t *des, int ii, int jj, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT33, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT33){
 int i, m, n;
//int image_height, image_width;
 double ReHH_VV, ImHH_VV, ReHH_XX, ImHH_XX, ReVV_XX, ImVV_XX;
 double ampHH, ampVV, ampXX;
 double smampHH1, smampVV1, smampXX1, smreHH_VV1, smimHH_VV1, smreHH_XX1, smimHH_XX1, smreVV_HH1, smimVV_HH1, smreVV_XX1, smimVV_XX1, smreXX_HH1, smimXX_HH1, smreXX_VV1, smimXX_VV1;
 
   smampHH1 = smampVV1 = smampXX1 = smreHH_VV1 = smimHH_VV1 = smreHH_XX1 = smimHH_XX1 = smreVV_HH1 = smimVV_HH1 = smreVV_XX1 = smimVV_XX1 = smreXX_HH1 = smimXX_HH1 = smreXX_VV1 = smimXX_VV1 = 0.0;

//   image_height = rT11.nr;
//   image_width = rT11.nc;

   for (i=0; i< des->region_count; i++)
      {
	m = des->region[i].m;
	n = des->region[i].n;

/* filtering master coherence */ 

	ampHH = (double)rT11.p[m][n];
	ampVV = (double)rT22.p[m][n];
	ampXX = (double)rT33.p[m][n];
	 
	ReHH_VV = (double)rT12_re.p[m][n];
	ImHH_VV = (double)rT12_im.p[m][n];
	ReHH_XX = (double)rT13_re.p[m][n];
	ImHH_XX = (double)rT13_im.p[m][n];

	ReVV_XX = (double)rT23_re.p[m][n];
	ImVV_XX = (double)rT23_re.p[m][n];
	 

	smampHH1 += ampHH;
	smampVV1 += ampVV;
	smampXX1 += ampXX;

	smreHH_VV1 += ReHH_VV;
	smimHH_VV1 += ImHH_VV;
	smreHH_XX1 += ReHH_XX;
	smimHH_XX1 += ImHH_XX;

	smreVV_XX1 += ReVV_XX;
	smimVV_XX1 += ImVV_XX;
      }

/* filtering master coherence */ 

   smreHH_VV1 = smreHH_VV1 / des->region_count;
   smimHH_VV1 = smimHH_VV1 / des->region_count;
   smreHH_XX1 = smreHH_XX1 / des->region_count;
   smimHH_XX1 = smimHH_XX1 / des->region_count;

   smreVV_XX1 = smreVV_XX1 / des->region_count;
   smimVV_XX1 = smimVV_XX1 / des->region_count;

   smampHH1 = smampHH1 / des->region_count;
   smampVV1 = smampVV1 / des->region_count;
   smampXX1 = smampXX1 / des->region_count;


   wT12_re->p[ii][jj] = (float) smreHH_VV1;
   wT12_im->p[ii][jj] = (float) smimHH_VV1;
   wT13_re->p[ii][jj] = (float) smreHH_XX1;
   wT13_im->p[ii][jj] = (float) smimHH_XX1;

   wT23_re->p[ii][jj] = (float) smreVV_XX1;
   wT23_im->p[ii][jj] = (float) smimVV_XX1;

   wT11->p[ii][jj] = (float) smampHH1;
   wT22->p[ii][jj] = (float) smampVV1;
   wT33->p[ii][jj] = (float) smampXX1;

  return(0);
}

/****************************************************************************************************************************************/
/****************************************************************************************************************************************/

char *Calloc(unsigned nelem,unsigned elsize){
	char *ptr;
	if((ptr=calloc(nelem,elsize))==NULL)
		{
		perror("MEMORY ALLOCATION ERROR");
		exit(3);
		}
	return ptr;
}

/****************************************************************************************************************************************/

double ABS(double a){
  double b;
    b = a;
    if (a < (double)0)
	b = -a;
    return b;
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */

int convert_S2_T3(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT33, int NC, int NR){ 
  int i, j;
  float s11r, s11i, s12r, s12i, s21r, s21i, s22r, s22i;
  float k1r, k1i, k2r, k2i, k3r, k3i;

  /* images resultat */ 
  rT11->nc = NC;
  rT11->nr = NR;
  alloc_imafl(rT11);

  rT12_re->nc = NC;
  rT12_re->nr = NR;
  alloc_imafl(rT12_re);

  rT12_im->nc = NC;
  rT12_im->nr = NR;
  alloc_imafl(rT12_im);

  rT13_re->nc = NC;
  rT13_re->nr = NR;
  alloc_imafl(rT13_re);

  rT13_im->nc = NC;
  rT13_im->nr = NR;
  alloc_imafl(rT13_im);

  rT22->nc = NC;
  rT22->nr = NR;
  alloc_imafl(rT22);

  rT23_re->nc = NC;
  rT23_re->nr = NR;
  alloc_imafl(rT23_re);

  rT23_im->nc = NC;
  rT23_im->nr = NR;
  alloc_imafl(rT23_im);

  rT33->nc = NC;
  rT33->nr = NR;
  alloc_imafl(rT33);

  for (i = 0; i < NR; i++) {
	  for (j = 0; j< NC; j++) {
		  s11r = rs11.p[i][2*j]; s11i = rs11.p[i][2*j+1];
		  s12r = rs12.p[i][2*j]; s12i = rs12.p[i][2*j+1];
		  s21r = rs21.p[i][2*j]; s21i = rs21.p[i][2*j+1];
		  s22r = rs22.p[i][2*j]; s22i = rs22.p[i][2*j+1];

		  k1r = (s11r+s22r)/sqrt(2.); k1i = (s11i+s22i)/sqrt(2.);
		  k2r = (s11r-s22r)/sqrt(2.); k2i = (s11i-s22i)/sqrt(2.);
		  k3r = (s12r+s21r)/sqrt(2.); k3i = (s12i+s21i)/sqrt(2.);

		  rT11->p[i][j] =    k1r * k1r + k1i * k1i;
		  rT12_re->p[i][j] = k1r * k2r + k1i * k2i;
		  rT12_im->p[i][j] = k1i * k2r - k1r * k2i;
		  rT13_re->p[i][j] = k1r * k3r + k1i * k3i;
		  rT13_im->p[i][j] = k1i * k3r - k1r * k3i;
		  rT22->p[i][j] =    k2r * k2r + k2i * k2i;
		  rT23_re->p[i][j] = k2r * k3r + k2i * k3i;
		  rT23_im->p[i][j] = k2i * k3r - k2r * k3i;
		  rT33->p[i][j] =    k3r * k3r + k3i * k3i;
	  }
  }
  return(0);
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */

int convert_S2_T4(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT14_re, imafl *rT14_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT24_re, imafl *rT24_im, imafl *rT33, imafl *rT34_re, imafl *rT34_im, imafl *rT44, int NC, int NR){
  int i, j;
  float s11r, s11i, s12r, s12i, s21r, s21i, s22r, s22i;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;

  /* images resultat */ 
  rT11->nc = NC;
  rT11->nr = NR;
  alloc_imafl(rT11);

  rT12_re->nc = NC;
  rT12_re->nr = NR;
  alloc_imafl(rT12_re);

  rT12_im->nc = NC;
  rT12_im->nr = NR;
  alloc_imafl(rT12_im);

  rT13_re->nc = NC;
  rT13_re->nr = NR;
  alloc_imafl(rT13_re);

  rT13_im->nc = NC;
  rT13_im->nr = NR;
  alloc_imafl(rT13_im);

  rT14_re->nc = NC;
  rT14_re->nr = NR;
  alloc_imafl(rT14_re);

  rT14_im->nc = NC;
  rT14_im->nr = NR;
  alloc_imafl(rT14_im);

  rT22->nc = NC;
  rT22->nr = NR;
  alloc_imafl(rT22);

  rT23_re->nc = NC;
  rT23_re->nr = NR;
  alloc_imafl(rT23_re);

  rT23_im->nc = NC;
  rT23_im->nr = NR;
  alloc_imafl(rT23_im);

  rT24_re->nc = NC;
  rT24_re->nr = NR;
  alloc_imafl(rT24_re);

  rT24_im->nc = NC;
  rT24_im->nr = NR;
  alloc_imafl(rT24_im);

  rT33->nc = NC;
  rT33->nr = NR;
  alloc_imafl(rT33);

  rT34_re->nc = NC;
  rT34_re->nr = NR;
  alloc_imafl(rT34_re);

  rT34_im->nc = NC;
  rT34_im->nr = NR;
  alloc_imafl(rT34_im);

  rT44->nc = NC;
  rT44->nr = NR;
  alloc_imafl(rT44);

  for (i = 0; i < NR; i++) {
	  for (j = 0; j< NC; j++) {
		  s11r = rs11.p[i][2*j]; s11i = rs11.p[i][2*j+1];
		  s12r = rs12.p[i][2*j]; s12i = rs12.p[i][2*j+1];
		  s21r = rs21.p[i][2*j]; s21i = rs21.p[i][2*j+1];
		  s22r = rs22.p[i][2*j]; s22i = rs22.p[i][2*j+1];

		  k1r = (s11r+s22r)/sqrt(2.); k1i = (s11i+s22i)/sqrt(2.);
		  k2r = (s11r-s22r)/sqrt(2.); k2i = (s11i-s22i)/sqrt(2.);
		  k3r = (s12r+s21r)/sqrt(2.); k3i = (s12i+s21i)/sqrt(2.);
		  k4r = (s21i-s12r)/sqrt(2.); k4i = (s12r-s21r)/sqrt(2.);

		  rT11->p[i][j] =    k1r * k1r + k1i * k1i;
		  rT12_re->p[i][j] = k1r * k2r + k1i * k2i;
		  rT12_im->p[i][j] = k1i * k2r - k1r * k2i;
		  rT13_re->p[i][j] = k1r * k3r + k1i * k3i;
		  rT13_im->p[i][j] = k1i * k3r - k1r * k3i;
		  rT14_re->p[i][j] = k1r * k4r + k1i * k4i;
		  rT14_im->p[i][j] = k1i * k4r - k1r * k4i;
		  rT22->p[i][j] =    k2r * k2r + k2i * k2i;
		  rT23_re->p[i][j] = k2r * k3r + k2i * k3i;
		  rT23_im->p[i][j] = k2i * k3r - k2r * k3i;
		  rT24_re->p[i][j] = k2r * k4r + k2i * k4i;
		  rT24_im->p[i][j] = k2i * k4r - k2r * k4i;
		  rT33->p[i][j] =    k3r * k3r + k3i * k3i;
		  rT34_re->p[i][j] = k3r * k4r + k3i * k4i;
		  rT34_im->p[i][j] = k3i * k4r - k3r * k4i;
		  rT44->p[i][j] =    k4r * k4r + k4i * k4i;
	  }
  }

  return(0);
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */

int convert_SPP_C2(imafl rs11, imafl rs12, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT22, int NC, int NR){ 
  int i, j;
  float k1r, k1i, k2r, k2i;

  /* images resultat */ 
  rT11->nc = NC;
  rT11->nr = NR;
  alloc_imafl(rT11);

  rT12_re->nc = NC;
  rT12_re->nr = NR;
  alloc_imafl(rT12_re);

  rT12_im->nc = NC;
  rT12_im->nr = NR;
  alloc_imafl(rT12_im);

  rT22->nc = NC;
  rT22->nr = NR;
  alloc_imafl(rT22);

  for (i = 0; i < NR; i++) {
	  for (j = 0; j< NC; j++) {
		  k1r = rs11.p[i][2*j]; k1i = rs11.p[i][2*j+1];
		  k2r = rs12.p[i][2*j]; k2i = rs12.p[i][2*j+1];

		  rT11->p[i][j] =    k1r * k1r + k1i * k1i;
		  rT12_re->p[i][j] = k1r * k2r + k1i * k2i;
		  rT12_im->p[i][j] = k1i * k2r - k1r * k2i;
		  rT22->p[i][j] =    k2r * k2r + k2i * k2i;
	  }
  }
  return(0);
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */

int convert_S2_C3(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT33, int NC, int NR){ 
  int i, j;
  float k1r, k1i, k2r, k2i, k3r, k3i;

  /* images resultat */ 
  rT11->nc = NC;
  rT11->nr = NR;
  alloc_imafl(rT11);

  rT12_re->nc = NC;
  rT12_re->nr = NR;
  alloc_imafl(rT12_re);

  rT12_im->nc = NC;
  rT12_im->nr = NR;
  alloc_imafl(rT12_im);

  rT13_re->nc = NC;
  rT13_re->nr = NR;
  alloc_imafl(rT13_re);

  rT13_im->nc = NC;
  rT13_im->nr = NR;
  alloc_imafl(rT13_im);

  rT22->nc = NC;
  rT22->nr = NR;
  alloc_imafl(rT22);

  rT23_re->nc = NC;
  rT23_re->nr = NR;
  alloc_imafl(rT23_re);

  rT23_im->nc = NC;
  rT23_im->nr = NR;
  alloc_imafl(rT23_im);

  rT33->nc = NC;
  rT33->nr = NR;
  alloc_imafl(rT33);

  for (i = 0; i < NR; i++) {
	  for (j = 0; j< NC; j++) {
		  k1r = rs11.p[i][2*j]; k1i = rs11.p[i][2*j+1];
		  k2r = (rs12.p[i][2*j] + rs21.p[i][2*j]) / sqrt(2.);
		  k2i = (rs12.p[i][2*j+1] + rs21.p[i][2*j+1]) / sqrt(2.);
		  k3r = rs22.p[i][2*j]; k3i = rs22.p[i][2*j+1];

		  rT11->p[i][j] =    k1r * k1r + k1i * k1i;
		  rT12_re->p[i][j] = k1r * k2r + k1i * k2i;
		  rT12_im->p[i][j] = k1i * k2r - k1r * k2i;
		  rT13_re->p[i][j] = k1r * k3r + k1i * k3i;
		  rT13_im->p[i][j] = k1i * k3r - k1r * k3i;
		  rT22->p[i][j] =    k2r * k2r + k2i * k2i;
		  rT23_re->p[i][j] = k2r * k3r + k2i * k3i;
		  rT23_im->p[i][j] = k2i * k3r - k2r * k3i;
		  rT33->p[i][j] =    k3r * k3r + k3i * k3i;
	  }
  }
  return(0);
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */

int convert_S2_C4(imafl rs11, imafl rs12, imafl rs21, imafl rs22, imafl *rT11, imafl *rT12_re, imafl *rT12_im, imafl *rT13_re, imafl *rT13_im, imafl *rT14_re, imafl *rT14_im, imafl *rT22, imafl *rT23_re, imafl *rT23_im, imafl *rT24_re, imafl *rT24_im, imafl *rT33, imafl *rT34_re, imafl *rT34_im, imafl *rT44, int NC, int NR){
  int i, j;
  float k1r, k1i, k2r, k2i, k3r, k3i, k4r, k4i;

  /* images resultat */ 
  rT11->nc = NC;
  rT11->nr = NR;
  alloc_imafl(rT11);

  rT12_re->nc = NC;
  rT12_re->nr = NR;
  alloc_imafl(rT12_re);

  rT12_im->nc = NC;
  rT12_im->nr = NR;
  alloc_imafl(rT12_im);

  rT13_re->nc = NC;
  rT13_re->nr = NR;
  alloc_imafl(rT13_re);

  rT13_im->nc = NC;
  rT13_im->nr = NR;
  alloc_imafl(rT13_im);

  rT14_re->nc = NC;
  rT14_re->nr = NR;
  alloc_imafl(rT14_re);

  rT14_im->nc = NC;
  rT14_im->nr = NR;
  alloc_imafl(rT14_im);

  rT22->nc = NC;
  rT22->nr = NR;
  alloc_imafl(rT22);

  rT23_re->nc = NC;
  rT23_re->nr = NR;
  alloc_imafl(rT23_re);

  rT23_im->nc = NC;
  rT23_im->nr = NR;
  alloc_imafl(rT23_im);

  rT24_re->nc = NC;
  rT24_re->nr = NR;
  alloc_imafl(rT24_re);

  rT24_im->nc = NC;
  rT24_im->nr = NR;
  alloc_imafl(rT24_im);

  rT33->nc = NC;
  rT33->nr = NR;
  alloc_imafl(rT33);

  rT34_re->nc = NC;
  rT34_re->nr = NR;
  alloc_imafl(rT34_re);

  rT34_im->nc = NC;
  rT34_im->nr = NR;
  alloc_imafl(rT34_im);

  rT44->nc = NC;
  rT44->nr = NR;
  alloc_imafl(rT44);

  for (i = 0; i < NR; i++) {
	  for (j = 0; j< NC; j++) {
		  k1r = rs11.p[i][2*j]; k1i = rs11.p[i][2*j+1];
		  k2r = rs12.p[i][2*j]; k2i = rs12.p[i][2*j+1];
		  k3r = rs21.p[i][2*j]; k3i = rs21.p[i][2*j+1];
		  k4r = rs22.p[i][2*j]; k4i = rs22.p[i][2*j+1];

		  rT11->p[i][j] =    k1r * k1r + k1i * k1i;
		  rT12_re->p[i][j] = k1r * k2r + k1i * k2i;
		  rT12_im->p[i][j] = k1i * k2r - k1r * k2i;
		  rT13_re->p[i][j] = k1r * k3r + k1i * k3i;
		  rT13_im->p[i][j] = k1i * k3r - k1r * k3i;
		  rT14_re->p[i][j] = k1r * k4r + k1i * k4i;
		  rT14_im->p[i][j] = k1i * k4r - k1r * k4i;
		  rT22->p[i][j] =    k2r * k2r + k2i * k2i;
		  rT23_re->p[i][j] = k2r * k3r + k2i * k3i;
		  rT23_im->p[i][j] = k2i * k3r - k2r * k3i;
		  rT24_re->p[i][j] = k2r * k4r + k2i * k4i;
		  rT24_im->p[i][j] = k2i * k4r - k2r * k4i;
		  rT33->p[i][j] =    k3r * k3r + k3i * k3i;
		  rT34_re->p[i][j] = k3r * k4r + k3i * k4i;
		  rT34_im->p[i][j] = k3i * k4r - k3r * k4i;
		  rT44->p[i][j] =    k4r * k4r + k4i * k4i;
	  }
  }
  return(0);
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */
/* *************************  INITIALISATION  ***************************/
int IDAN_init2(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT22, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT22){
	
  int image_height, image_width, i;

  image_height = rT11.nr;
  image_width  = rT11.nc;

  /* images resultat */ 
  wT11->nc = rT11.nc;
  wT11->nr = rT11.nr;
  alloc_imafl(wT11);

  wT12_re->nc = rT11.nc;
  wT12_re->nr = rT11.nr;
  alloc_imafl(wT12_re);

  wT12_im->nc = rT11.nc;
  wT12_im->nr = rT11.nr;
  alloc_imafl(wT12_im);

  wT22->nc = rT11.nc;
  wT22->nr = rT11.nr;
  alloc_imafl(wT22);

  /* buffers for the region growing */
  des->map = (unsigned int *) Calloc(image_width*image_height, sizeof(*(des->map)));
  des->Pmap = (unsigned int **) Calloc(image_height, sizeof(*(des->Pmap)));
  des->region = (COORD *) Calloc(10*des->MAX_REGION_SIZE, sizeof (*(des->region)));
  des->background = (COORD *) Calloc(10*des->MAX_REGION_SIZE, sizeof (*(des->background)));
  des->label = 0;

  for (i=0; i<image_height; i++)
    {
      des->Pmap[i] = des->map + i*image_width;
    }
  return(0);
}


/* *************************  CALCUL  ***************************/
int IDAN_calc2(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT22, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT22){ 
  int i, j, image_width, image_height;
  double maHH1, maVV1;
  
  image_height = rT11.nr;
  image_width = rT11.nc;
  
  for(i=0; i<(image_height); i++) {
	if (i%(int)(image_height/20) == 0) {printf("%f\r", 100. * i / (image_height - 1));fflush(stdout);}
    for(j=0; j<(image_width); j++){
      GrowRegion_anf_int2(des, i, j, &maHH1, &maVV1, rT11, rT22);
      ReviseRegion_anf_int2(des, maHH1, maVV1, rT11, rT22);	  
      ComputeFilteredMeasures_anf_int2(des, i, j, rT11, rT12_re, rT12_im, rT22, wT11, wT12_re, wT12_im, wT22);
	}
  }     
  return(0);
}

/* fin doc en sous partie */ 


/****************************************************************************************************************************************/

void GrowRegion_anf_int2(IDAN_t *des, int m, int n, double *PmH1, double *PmV1, imafl rT11, imafl rT22){

  int i, j, im, jm, iM, jM, k, image_height, image_width;
  double threshold;
  double mean_aH1, mean_aV1, dist, dist1, dist2, idan_2;

   idan_2 = 0.7;
   
   if ((des->filt_amount) == 1)
      idan_2 = 1.0;

   des->region_count = 1;
   des->background_count = 0;
   des->region[0].m = m;
   des->region[0].n = n;

   des->Pmap[m][n] = ++(des->label);

   image_height = rT11.nr;
   image_width = rT11.nc;

   *PmH1 = rT11.p[m][n];
   *PmV1 = rT22.p[m][n];

   im = MAX(0,m-1);
   jm = MAX(0,n-1);
   iM = MIN(image_height-1,m+1);
   jM = MIN(image_width-1,n+1);
   
   mean_aH1 = EstimateLocalMean_anf_int(des, rT11, im, jm, iM, jM);   
   mean_aV1 = EstimateLocalMean_anf_int(des, rT22, im, jm, iM, jM);   

   threshold = idan_2 * 2 * des->speckle_std;

   for (k=0; k< des->region_count; k++)
      {
      m = des->region[k].m;
      n = des->region[k].n;
      im = MAX(0,m-1);
      jm = MAX(0,n-1);
      iM = MIN(image_height-1,m+1);
      jM = MIN(image_width-1,n+1);
      for (i = im; i <= iM; i++)
	for (j = jm; j <=jM; j++) 
	  {
	    if ((des->region_count) > (des->MAX_REGION_SIZE))
	      break;

	    if (des->Pmap[i][j] != des->label)
	      {
		des->Pmap[i][j] = des->label;
		
		dist1 = sqrt(SQR(rT11.p[i][j] - mean_aH1) / SQR(mean_aH1));
		dist2 = sqrt(SQR(rT22.p[i][j] - mean_aV1) / SQR(mean_aV1));
		
		dist = (dist1 + dist2);
		
		if (dist < threshold)
	          {
		    des->region[des->region_count].m = i;
		    des->region[des->region_count++].n = j;
		    
		    (*PmH1) += (rT11.p[i][j]);
		    (*PmV1) += (rT22.p[i][j]);
		  }
	       else
		 {
		   des->background[des->background_count].m = i;
		   des->background[des->background_count++].n = j;
		 }
	      }
	  }
      }
   (*PmH1) /= des->region_count;
   (*PmV1) /= des->region_count;
    
}

/****************************************************************************************************************************************/

void ReviseRegion_anf_int2(IDAN_t *des, double maH1, double maV1, imafl rT11, imafl rT22){
  int i, temp11, temp22;
//int  image_height, image_width;
  double threshold, dist, dist1, dist2, idan_4;

  idan_4 = 2;

//  image_height = rT11.nr;
//  image_width = rT11.nc;

  threshold = idan_4 * 2 * des->speckle_std;

  for (i=0; i< des->background_count; i++)
      {
	//if ((des->region_count) > (des->MAX_REGION_SIZE))
	//break;
	
	temp11=(des->background)[i].m;
	temp22=(des->background)[i].n;

	dist1 = sqrt(SQR(rT11.p[temp11][temp22] - maH1) / SQR(maH1));
	dist2 = sqrt(SQR(rT22.p[temp11][temp22] - maV1) / SQR(maV1));

	dist = (dist1 + dist2);

	if (dist < threshold)
	  {
	   des->region[des->region_count].m = des->background[i].m;
	   des->region[des->region_count++].n = des->background[i].n;
	  }
      }
}

/****************************************************************************************************************************************/
int ComputeFilteredMeasures_anf_int2(IDAN_t *des , int ii, int jj, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT22, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT22){
 int i, m, n;
//int image_height, image_width;
 double ReHH_VV, ImHH_VV;
 double ampHH, ampVV;
 double smampHH1, smampVV1; 
 double smreHH_VV1, smimHH_VV1;
 double smreVV_HH1, smimVV_HH1;

 smreHH_VV1 = smimHH_VV1 = smreVV_HH1 = smimVV_HH1 = 0.0;

//   image_height = rT11.nr;
//   image_width = rT11.nc;

   for (i=0; i< des->region_count; i++)
      {
	m = des->region[i].m;
	n = des->region[i].n;

/* filtering master coherence */ 

	ampHH = (double)rT11.p[m][n];
	ampVV = (double)rT22.p[m][n];
	 
	ReHH_VV = (double)rT12_re.p[m][n];
	ImHH_VV = (double)rT12_im.p[m][n];

	smampHH1 += ampHH;
	smampVV1 += ampVV;

	smreHH_VV1 += ReHH_VV;
	smimHH_VV1 += ImHH_VV;
	}

/* filtering master coherence */ 

   smreHH_VV1 = smreHH_VV1 / des->region_count;
   smimHH_VV1 = smimHH_VV1 / des->region_count;
   
   smampHH1 = smampHH1 / des->region_count;
   smampVV1 = smampVV1 / des->region_count;

   wT12_re->p[ii][jj] = (float) smreHH_VV1;
   wT12_im->p[ii][jj] = (float) smimHH_VV1;
   
   wT11->p[ii][jj] = (float) smampHH1;
   wT22->p[ii][jj] = (float) smampVV1;

  return(0);
}

/****************************************************************************************************************************************/
/* NEW ROUTINE ADDED BY POLSARPRO */
/* *************************  INITIALISATION  ***************************/
int IDAN_init4(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT14_re, imafl rT14_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT24_re, imafl rT24_im, imafl rT33, imafl rT34_re, imafl rT34_im, imafl rT44, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT14_re, imafl *wT14_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT24_re, imafl *wT24_im, imafl *wT33, imafl *wT34_re, imafl *wT34_im, imafl *wT44){
	
  int image_height, image_width, i;

  image_height = rT11.nr;
  image_width  = rT11.nc;

  /* images resultat */ 
  wT11->nc = rT11.nc;
  wT11->nr = rT11.nr;
  alloc_imafl(wT11);

  wT12_re->nc = rT11.nc;
  wT12_re->nr = rT11.nr;
  alloc_imafl(wT12_re);

  wT12_im->nc = rT11.nc;
  wT12_im->nr = rT11.nr;
  alloc_imafl(wT12_im);

  wT13_re->nc = rT11.nc;
  wT13_re->nr = rT11.nr;
  alloc_imafl(wT13_re);

  wT13_im->nc = rT11.nc;
  wT13_im->nr = rT11.nr;
  alloc_imafl(wT13_im);

  wT14_re->nc = rT11.nc;
  wT14_re->nr = rT11.nr;
  alloc_imafl(wT14_re);

  wT14_im->nc = rT11.nc;
  wT14_im->nr = rT11.nr;
  alloc_imafl(wT14_im);

  wT22->nc = rT11.nc;
  wT22->nr = rT11.nr;
  alloc_imafl(wT22);

  wT23_re->nc = rT11.nc;
  wT23_re->nr = rT11.nr;
  alloc_imafl(wT23_re);

  wT23_im->nc = rT11.nc;
  wT23_im->nr = rT11.nr;
  alloc_imafl(wT23_im);

  wT24_re->nc = rT11.nc;
  wT24_re->nr = rT11.nr;
  alloc_imafl(wT24_re);

  wT24_im->nc = rT11.nc;
  wT24_im->nr = rT11.nr;
  alloc_imafl(wT24_im);

  wT33->nc = rT11.nc;
  wT33->nr = rT11.nr;
  alloc_imafl(wT33);

  wT34_re->nc = rT11.nc;
  wT34_re->nr = rT11.nr;
  alloc_imafl(wT34_re);

  wT34_im->nc = rT11.nc;
  wT34_im->nr = rT11.nr;
  alloc_imafl(wT34_im);

  wT44->nc = rT11.nc;
  wT44->nr = rT11.nr;
  alloc_imafl(wT44);

  /* buffers for the region growing */
  des->map = (unsigned int *) Calloc(image_width*image_height, sizeof(*(des->map)));
  des->Pmap = (unsigned int **) Calloc(image_height, sizeof(*(des->Pmap)));
  des->region = (COORD *) Calloc(10*des->MAX_REGION_SIZE, sizeof (*(des->region)));
  des->background = (COORD *) Calloc(10*des->MAX_REGION_SIZE, sizeof (*(des->background)));
  des->label = 0;

  for (i=0; i<image_height; i++)
    {
      des->Pmap[i] = des->map + i*image_width;
    }
  return(0);
}


/* *************************  CALCUL  ***************************/
int IDAN_calc4(IDAN_t *des, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT14_re, imafl rT14_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT24_re, imafl rT24_im, imafl rT33, imafl rT34_re, imafl rT34_im, imafl rT44, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT14_re, imafl *wT14_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT24_re, imafl *wT24_im, imafl *wT33, imafl *wT34_re, imafl *wT34_im, imafl *wT44){ 
  int i, j, image_width, image_height;
  double maHH1, maVV1, maXX1, maYY1;
  
  image_height = rT11.nr;
  image_width = rT11.nc;
  
  for(i=0; i<(image_height); i++) {
	if (i%(int)(image_height/20) == 0) {printf("%f\r", 100. * i / (image_height - 1));fflush(stdout);}
    for(j=0; j<(image_width); j++){
      GrowRegion_anf_int4(des, i, j, &maHH1, &maVV1, &maXX1, &maYY1, rT11, rT22, rT33, rT44);
      ReviseRegion_anf_int4(des, maHH1, maVV1, maXX1, maYY1, rT11, rT22, rT33, rT44);	  
      ComputeFilteredMeasures_anf_int4(des, i, j, rT11, rT12_re, rT12_im, rT13_re, rT13_im, rT14_re, rT14_im, rT22, rT23_re, rT23_im, rT24_re, rT24_im, rT33, rT34_re, rT34_im, rT44, wT11, wT12_re, wT12_im, wT13_re, wT13_im, wT14_re, wT14_im, wT22, wT23_re, wT23_im, wT24_re, wT24_im, wT33, wT34_re, wT34_im, wT44);
	}
  }     
  return(0);
}

/* fin doc en sous partie */ 


/****************************************************************************************************************************************/

void GrowRegion_anf_int4(IDAN_t *des, int m, int n, double *PmH1, double *PmV1, double *PmX1, double *PmY1, imafl rT11, imafl rT22, imafl rT33, imafl rT44){

  int i, j, im, jm, iM, jM, k, image_height, image_width;
  double threshold;
  double mean_aH1, mean_aV1, mean_aX1, mean_aY1, dist, dist1, dist2, dist3, dist4, idan_2;

   idan_2 = 0.7;
   
   if ((des->filt_amount) == 1)
      idan_2 = 1.0;

   des->region_count = 1;
   des->background_count = 0;
   des->region[0].m = m;
   des->region[0].n = n;

   des->Pmap[m][n] = ++(des->label);

   image_height = rT11.nr;
   image_width = rT11.nc;

   *PmH1 = rT11.p[m][n];
   *PmV1 = rT22.p[m][n];
   *PmX1 = rT33.p[m][n];
   *PmY1 = rT44.p[m][n];

   im = MAX(0,m-1);
   jm = MAX(0,n-1);
   iM = MIN(image_height-1,m+1);
   jM = MIN(image_width-1,n+1);
   
   mean_aH1 = EstimateLocalMean_anf_int(des, rT11, im, jm, iM, jM);   
   mean_aV1 = EstimateLocalMean_anf_int(des, rT22, im, jm, iM, jM);   
   mean_aX1 = EstimateLocalMean_anf_int(des, rT33, im, jm, iM, jM);
   mean_aY1 = EstimateLocalMean_anf_int(des, rT44, im, jm, iM, jM);

   threshold = idan_2 * 4 * des->speckle_std;

   for (k=0; k< des->region_count; k++)
      {
      m = des->region[k].m;
      n = des->region[k].n;
      im = MAX(0,m-1);
      jm = MAX(0,n-1);
      iM = MIN(image_height-1,m+1);
      jM = MIN(image_width-1,n+1);
      for (i = im; i <= iM; i++)
	for (j = jm; j <=jM; j++) 
	  {
	    if ((des->region_count) > (des->MAX_REGION_SIZE))
	      break;

	    if (des->Pmap[i][j] != des->label)
	      {
		des->Pmap[i][j] = des->label;
		
		dist1 = sqrt(SQR(rT11.p[i][j] - mean_aH1) / SQR(mean_aH1));
		dist2 = sqrt(SQR(rT22.p[i][j] - mean_aV1) / SQR(mean_aV1));
		dist3 = sqrt(SQR(rT33.p[i][j] - mean_aX1) / SQR(mean_aX1));
		dist4 = sqrt(SQR(rT44.p[i][j] - mean_aY1) / SQR(mean_aY1));
		
		dist = (dist1 + dist2 + dist3 + dist4);
		
		if (dist < threshold)
	          {
		    des->region[des->region_count].m = i;
		    des->region[des->region_count++].n = j;
		    
		    (*PmH1) += (rT11.p[i][j]);
		    (*PmV1) += (rT22.p[i][j]);
		    (*PmX1) += (rT33.p[i][j]);
		    (*PmY1) += (rT44.p[i][j]);
		  }
	       else
		 {
		   des->background[des->background_count].m = i;
		   des->background[des->background_count++].n = j;
		 }
	      }
	  }
      }
   (*PmH1) /= des->region_count;
   (*PmV1) /= des->region_count;
   (*PmX1) /= des->region_count;
   (*PmY1) /= des->region_count;
    
}

/****************************************************************************************************************************************/

void ReviseRegion_anf_int4(IDAN_t *des, double maH1, double maV1, double maX1, double maY1, imafl rT11, imafl rT22, imafl rT33, imafl rT44){
  int i, temp11, temp22;
//int  image_height, image_width;
  double threshold, dist, dist1, dist2, dist3, dist4, idan_4;

  idan_4 = 2;

//  image_height = rT11.nr;
//  image_width = rT11.nc;

  threshold = idan_4 * 4 * des->speckle_std;

  for (i=0; i< des->background_count; i++)
      {
	//if ((des->region_count) > (des->MAX_REGION_SIZE))
	//break;
	
	temp11=(des->background)[i].m;
	temp22=(des->background)[i].n;

	dist1 = sqrt(SQR(rT11.p[temp11][temp22] - maH1) / SQR(maH1));
	dist2 = sqrt(SQR(rT22.p[temp11][temp22] - maV1) / SQR(maV1));
	dist3 = sqrt(SQR(rT33.p[temp11][temp22] - maX1) / SQR(maX1));
	dist4 = sqrt(SQR(rT44.p[temp11][temp22] - maY1) / SQR(maY1));

	dist = (dist1 + dist2 + dist3 + dist4);

	if (dist < threshold)
	  {
	   des->region[des->region_count].m = des->background[i].m;
	   des->region[des->region_count++].n = des->background[i].n;
	  }
      }
}

/****************************************************************************************************************************************/
int ComputeFilteredMeasures_anf_int4(IDAN_t *des , int ii, int jj, imafl rT11, imafl rT12_re, imafl rT12_im, imafl rT13_re, imafl rT13_im, imafl rT14_re, imafl rT14_im, imafl rT22, imafl rT23_re, imafl rT23_im, imafl rT24_re, imafl rT24_im, imafl rT33, imafl rT34_re, imafl rT34_im, imafl rT44, imafl *wT11, imafl *wT12_re, imafl *wT12_im, imafl *wT13_re, imafl *wT13_im, imafl *wT14_re, imafl *wT14_im, imafl *wT22, imafl *wT23_re, imafl *wT23_im, imafl *wT24_re, imafl *wT24_im, imafl *wT33, imafl *wT34_re, imafl *wT34_im, imafl *wT44){
 int i, m, n;
//int image_height, image_width;
 double smampHH, smampVV, smampXX, smampYY; 
 double smreHH_VV, smimHH_VV, smreHH_XX, smimHH_XX, smreHH_YY, smimHH_YY;
 double smreVV_XX, smimVV_XX, smreVV_YY, smimVV_YY;
 double smreXX_YY, smimXX_YY;
 
 smreHH_VV = smimHH_VV = smreHH_XX = smimHH_XX = smreHH_YY = smimHH_YY = 0.0;
 smreVV_XX = smimVV_XX = smreVV_YY = smimVV_YY = 0.0;
 smreXX_YY = smimXX_YY = 0.0;

//   image_height = rT11.nr;
//   image_width = rT11.nc;

  for (i=0; i< des->region_count; i++) {
	m = des->region[i].m;
	n = des->region[i].n;

/* filtering master coherence */ 

	smampHH += (double)rT11.p[m][n];
	smampVV += (double)rT22.p[m][n];
	smampXX += (double)rT33.p[m][n];
	smampYY += (double)rT44.p[m][n];
	 
	smreHH_VV += (double)rT12_re.p[m][n];
	smimHH_VV += (double)rT12_im.p[m][n];
	smreHH_XX += (double)rT13_re.p[m][n];
	smimHH_XX += (double)rT13_im.p[m][n];
	smreHH_YY += (double)rT14_re.p[m][n];
	smimHH_YY += (double)rT14_im.p[m][n];

	smreVV_XX += (double)rT23_re.p[m][n];
	smimVV_XX += (double)rT23_re.p[m][n];
	smreVV_YY += (double)rT24_re.p[m][n];
	smimVV_YY += (double)rT24_re.p[m][n];
	 
	smreXX_YY += (double)rT34_re.p[m][n];
	smimXX_YY += (double)rT34_re.p[m][n];
	}

/* filtering master coherence */ 

   smreHH_VV /= des->region_count;
   smimHH_VV /= des->region_count;
   smreHH_XX /= des->region_count;
   smimHH_XX /= des->region_count;
   smreHH_YY /= des->region_count;
   smimHH_YY /= des->region_count;

   smreVV_XX /= des->region_count;
   smimVV_XX /= des->region_count;
   smreVV_YY /= des->region_count;
   smimVV_YY /= des->region_count;

   smreXX_YY /= des->region_count;
   smimXX_YY /= des->region_count;
   
   smampHH /= des->region_count;
   smampVV /= des->region_count;
   smampXX /= des->region_count;
   smampYY /= des->region_count;

   wT12_re->p[ii][jj] = (float) smreHH_VV;
   wT12_im->p[ii][jj] = (float) smimHH_VV;
   wT13_re->p[ii][jj] = (float) smreHH_XX;
   wT13_im->p[ii][jj] = (float) smimHH_XX;
   wT14_re->p[ii][jj] = (float) smreHH_YY;
   wT14_im->p[ii][jj] = (float) smimHH_YY;

   wT23_re->p[ii][jj] = (float) smreVV_XX;
   wT23_im->p[ii][jj] = (float) smimVV_XX;
   wT24_re->p[ii][jj] = (float) smreVV_YY;
   wT24_im->p[ii][jj] = (float) smimVV_YY;

   wT34_re->p[ii][jj] = (float) smreXX_YY;
   wT34_im->p[ii][jj] = (float) smimXX_YY;
   
   wT11->p[ii][jj] = (float) smampHH;
   wT22->p[ii][jj] = (float) smampVV;
   wT33->p[ii][jj] = (float) smampXX;
   wT44->p[ii][jj] = (float) smampYY;

  return(0);
}

#endif

