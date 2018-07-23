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

File     : tree_classifier.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 1.0
Creation : 12/2006
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
e-mail : laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Description :  Unsupervised Rule-Based Hierarchical Classification 

********************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

#define _max(a,b) ((a)>(b)) ? (a):(b) 

struct tree_node
{
  float a; 
  float b; 
  float c;
  int prm1; 
  int prm2;
  int Tclass; 
  int Fclass;
  struct tree_node *Tnext_node; 
  struct tree_node *Fnext_node; 
};

/* LOCAL PROCEDURES */
struct tree_node *read_tree_class_rule(FILE *rule_file);
void check_tree(struct tree_node *node,int *max_prm_ind,int *max_class_ind);
void tree_class(struct tree_node *node,float *prm_vec,float *class);
int nearest_class(float *prm_vec,float **mean_prm,int nb_prm,int nb_class,int *class_count);

/********************************************************************
Routine  : main
Authors  : Laurent FERRO-FAMIL
Creation : 12/2006
Update  :
*--------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  : 1
********************************************************************/
int main(int argc, char *argv[])
{
/* Input/Output file pointer arrays */
  FILE *rule_file,*prm_list_file,*class_file,**prm_file;
  char rule_file_name[256], prm_file_name[256], ColorMap[256],out_dir[256];
  char file_name[256];
  
  int nb_prm,nb_class,np,nc;
  int iteration,stop_criterion,nb_it_max;
  int col,row,Ncol,Nrow;
  
  float pct_min,pct_chg;
  int  *class_count;
  float *prm_vec;  
  float **M_in,**class,**mean_prm;
  struct tree_node *tree_head;
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntree_classifier.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-irf 	input rule file\n");
strcat(UsageHelp," (string)	-ipf 	input parameters file\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nit 	number of iterations\n");
strcat(UsageHelp," (int)   	-pct 	minimum purcentage\n");
strcat(UsageHelp," (int)   	-col 	colormap\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-irf",str_cmd_prm,rule_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ipf",str_cmd_prm,prm_file_name,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nrow,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nit",int_cmd_prm,&nb_it_max,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pct",int_cmd_prm,&pct_min,1,UsageHelp);
  get_commandline_prm(argc,argv,"-irf",str_cmd_prm,ColorMap,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

 check_dir(out_dir);
 check_file(rule_file_name);
 check_file(prm_file_name);
 check_file(ColorMap);

/* Tree classification */

 if ((rule_file = fopen(rule_file_name, "r")) == NULL)
  edit_error("Could not open input file : ", rule_file_name);
  
 fgets(file_name,sizeof(file_name)-1,rule_file);
 fgets(file_name,sizeof(file_name)-1,rule_file);
 fgets(file_name,sizeof(file_name)-1,rule_file);

 /* Read tree structure*/
 tree_head = read_tree_class_rule(rule_file);
 
 /* Check*/
 nb_prm=0;
 nb_class=0;
 check_tree(tree_head,&nb_prm,&nb_class);
 
 prm_vec = vector_float(nb_prm);
 class = matrix_float(Nrow,Ncol);
 M_in  = matrix_float(nb_prm,Ncol);

 /*Read parameters*/
 prm_file=(FILE **) malloc(nb_prm*sizeof(FILE *));
 
 if ((prm_list_file = fopen(prm_file_name, "r")) == NULL)
  edit_error("Could not open input file : ", prm_file_name);
  
 for(np=0;np<nb_prm;np++)
 {
  fscanf(prm_list_file,"%s\n",file_name);
  check_file(file_name);
  if ((prm_file[np] = fopen(file_name, "rb")) == NULL)
   edit_error("Could not open input file : ", file_name);
 }  
 
 for(row=0;row<Nrow;row++)
 {
 if (row%(int)(Nrow/20) == 0) {printf("%f\r", 100. * row / (Nrow - 1));fflush(stdout);}
  for(np=0;np<nb_prm;np++) fread(M_in[np],sizeof(float),Ncol,prm_file[np]);
  for(col=0;col<Ncol;col++)
  {
   for(np=0;np<nb_prm;np++) prm_vec[np] = M_in[np][col];
   tree_class(tree_head,prm_vec,&class[row][col]);
  }
 } 

 sprintf(file_name,"%stree_class",out_dir);
 bmp_wishart(class,Nrow,Ncol,file_name,ColorMap);

 sprintf(file_name,"%stree_class.bin",out_dir);
 if ((class_file = fopen(file_name, "wb")) == NULL)
 edit_error("Could not open output file : ", file_name);
 for(row=0;row<Nrow;row++)
  fwrite(class[row],sizeof(float),Ncol,class_file);
 fclose(class_file);


/* K-means */
if (nb_it_max != 0)
{
  nb_class++;
  pct_min /= 100;
  class_count = vector_int(nb_class);
  mean_prm = matrix_float(nb_prm,nb_class);

 for(np=0;np<nb_prm;np++) rewind(prm_file[np]);

 stop_criterion=0;
 iteration = 0;
 pct_chg = 0;
 while(stop_criterion !=1)
 {
  iteration++;
  for(np=0;np<nb_prm;np++) rewind(prm_file[np]);

  for(nc=1;nc<nb_class;nc++)
  {
   class_count[nc]=0;
   for(np=0;np<nb_prm;np++) mean_prm[np][nc]=0;
  }  
  
  pct_chg = 0;
  for(row=0;row<Nrow;row++)
  {
   for(np=0;np<nb_prm;np++) fread(M_in[np],sizeof(float),Ncol,prm_file[np]);
   for(col=0;col<Ncol;col++)
   {
    for(np=0;np<nb_prm;np++) mean_prm[np][(int)class[row][col]] += M_in[np][col];
    class_count[(int)class[row][col]]++;
   }  
  } 
 
  for(nc=0;nc<nb_class;nc++)
  {
   for(np=0;np<nb_prm;np++)
   {     
    if(class_count[nc]>0) mean_prm[np][nc]/= (float) class_count[nc];
    else mean_prm[np][nc]=0;
   } 
  } 

  for(np=0;np<nb_prm;np++) rewind(prm_file[np]);

  for(row=0;row<Nrow;row++)
  {
   if (row%(int)(Nrow/20) == 0) {printf("%f\r", 100. * row / (Nrow - 1));fflush(stdout);}
   for(np=0;np<nb_prm;np++) fread(M_in[np],sizeof(float),Nrow,prm_file[np]);
   for(col=0;col<Ncol;col++)
   {
    for(np=0;np<nb_prm;np++) prm_vec[np] = M_in[np][col];
    nc=nearest_class(prm_vec,mean_prm,nb_prm,nb_class,class_count);
    if(nc != class[row][col]) pct_chg++;
    class[row][col] = (float) nc;
   }
  }
  
  if(iteration >= nb_it_max) stop_criterion = 1;
  
  np=0;
  for(nc=1;nc<nb_class;nc++) np+=class_count[nc];
  
  pct_chg /= (float) np;
  if(pct_chg<pct_min) stop_criterion = 1;
 }
 
 sprintf(file_name,"%skmeans_tree_class",out_dir);
 bmp_wishart(class,Nrow,Ncol,file_name,ColorMap);
 
 sprintf(file_name,"%skmeans_tree_class.bin",out_dir);
 if ((class_file = fopen(file_name, "wb")) == NULL)
 edit_error("Could not open output file : ", file_name);
 for(row=0;row<Nrow;row++)
  fwrite(class[row],sizeof(float),Ncol,class_file);
 fclose(class_file);
}

 return 1;
} 
/********************************************************************
Routine  : tree_node
Authors  : Laurent FERRO-FAMIL
Creation : 12/2006
Update   :
*--------------------------------------------------------------------
Description :  Read Tree Class Rules
*--------------------------------------------------------------------
Inputs arguments :

Returned values  :

********************************************************************/
struct tree_node *read_tree_class_rule(FILE *rule_file)
{
  char Tmp[256];
  char *s;
  struct tree_node *node;
  
  if ((s = fgets(Tmp,sizeof(Tmp)-1,rule_file)) != NULL) 
  {
   node = (struct tree_node *) malloc(sizeof(struct tree_node));
   sscanf(s,"%f %f %f %d %d %d %d",&node->a,&node->b,&node->c,&node->prm1,&node->prm2,&node->Tclass, &node->Fclass);
   node->Tnext_node = NULL;
   if (node->Tclass == 0) 
    node->Tnext_node = read_tree_class_rule(rule_file);
   node->Fnext_node = NULL;
   if (node->Fclass == 0) 
    node->Fnext_node = read_tree_class_rule(rule_file);
  } else
    node = NULL;
  return(node);
}
/********************************************************************
Routine  : tree_node
Authors  : Laurent FERRO-FAMIL
Creation : 12/2006
Update   :
*--------------------------------------------------------------------
Description :  Read Tree Structure
*--------------------------------------------------------------------
Inputs arguments :

Returned values  :

********************************************************************/
void check_tree(struct tree_node *node,int *max_prm_ind,int *max_class_ind)
{
  
   (*max_prm_ind) = _max((*max_prm_ind),node->prm1);   
   (*max_prm_ind) = _max((*max_prm_ind),node->prm2);   
   (*max_class_ind) = _max((*max_class_ind),node->Tclass);   
   (*max_class_ind) = _max((*max_class_ind),node->Fclass);   
   if(node->Tnext_node != NULL) check_tree(node->Tnext_node,max_prm_ind,max_class_ind);
   if(node->Fnext_node != NULL) check_tree(node->Fnext_node,max_prm_ind,max_class_ind);
}
/********************************************************************
Routine  : tree_node
Authors  : Laurent FERRO-FAMIL
Creation : 12/2006
Update   :
*--------------------------------------------------------------------
Description :  Hierarchical Tree Classification
*--------------------------------------------------------------------
Inputs arguments :

Returned values  :

********************************************************************/
void tree_class(struct tree_node *node,float *prm_vec,float *class)
{
   if((node->a*prm_vec[node->prm1-1]+node->b*prm_vec[node->prm2-1])>node->c) /* True */
    if(node->Tclass>0)
     (*class)= (float) node->Tclass;
    else
     tree_class(node->Tnext_node,prm_vec,class);
   else /* False */
    if(node->Fclass>0)
     (*class)= (float) node->Fclass;
    else
     tree_class(node->Fnext_node,prm_vec,class);   
}
/********************************************************************
Routine  : tree_node
Authors  : Laurent FERRO-FAMIL
Creation : 12/2006
Update   :
*--------------------------------------------------------------------
Description :  K-Means Tree Classification
*--------------------------------------------------------------------
Inputs arguments :

Returned values  :

********************************************************************/
int nearest_class(float *prm_vec,float **mean_prm,int nb_prm,int nb_class,int *class_count)
{
 int np,nc,class;
 float dist,dist_min;
 
 dist_min = 1e32;
 
 class = 0;
 for(nc=1;nc<nb_class;nc++)
 {
  if(class_count[nc]>0)
  {
   dist = 0;
   for(np=0;np<nb_prm;np++)
    dist += (prm_vec[np]-mean_prm[np][nc])*(prm_vec[np]-mean_prm[np][nc]);

   if(dist<dist_min)
   {
    dist_min = dist;
    class = nc;
   }
  }
 }   

 return  class;
} 
