
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

File     : cluster_create.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 2.0 - Eric POTTIER (08/2011)
Creation : 11/2007
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

Description :  Perform a Data Clustering Procedure from:
               - A binary data file resulting of a segmentation
                 procedure.
               - A binary data file representing power information

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

#define my_max(a,b) ((a)>(b) ? (a):(b))
#define my_min(a,b) ((a)<(b) ? (a):(b))

struct Cluster *Add_List_Pixel(struct Cluster *C,float **cl_im,float **in_value_im, int Nlig, int Ncol);
struct Cluster *Create_Cluster_List(struct Cluster *C_top, int Nb_cl);
struct Cluster *Create_Cluster(struct Cluster *C);
struct PixX *Create_PixX(struct PixX *P,int li,int co);
struct Ngb *Create_Ngb(struct Ngb *N, float cl);
void Insert_Ngb(struct Cluster *C, float cl);
struct Ngb *Add_Cluster_Ngb(struct Ngb *N,float cl);
struct Ngb *Rem_Cluster_Ngb(struct Ngb *N,float cl);
struct Cluster *Add_List_Ngb(struct Cluster *C,float **cl_im, int Nlig, int Ncol);
void find_cluster(float **im,int Nlig, int Ncol,float *Ncluster, int Neighb);
void locate_cluster(float **im,float val,float Ncluster,int lig, int col,int Nlig, int Ncol, int **ind_list, int Neighb);
struct Cluster *Find_nearest_Ngb(struct Cluster *C_current);
struct Cluster *Merge_clusters(struct Cluster *C_top,struct Cluster *C_from,struct Cluster *C_to,float *Ncluster);
struct Cluster *Update_clusters(struct Cluster *C_top,float **cl_im);

struct Ngb {     
       float   cl;
       struct Ngb *Prev;
       struct Ngb *Next;
       };

struct PixX {     
       int   li;
       int   co;
       struct PixX *Next;
       };

struct Cluster {     
       float Nbr;
       float Npix;           
       float Mean;            
       struct PixX *Coord;
       struct Cluster *Prev;
       struct Cluster *Next;
       struct Ngb *Ngb_cl;
       };
       
float **Cl_im;

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

 FILE  *file_in,*file_in_value,*file_out;

 float **in_seg_val_im,**dum_im;
 
 char filename[FilePathLength], in_seg_file[FilePathLength];
 char in_value_file[FilePathLength],out_cluster_file[FilePathLength];

 int Nlig,Ncol,lig,col;
 int cl,Npix_lim,npix,Nc;
 int pgrs_bar, Neighb;

 float Ncluster,min,max;
 
 struct PixX *P_current;

 struct Cluster *C_current,*C_top,*C_dum,*C_dum1, *C_tmp, *C_tmp0;
 
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncluster_create.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-isf 	input segment file\n");
strcat(UsageHelp," (string)	-ivf 	input value file\n");
strcat(UsageHelp," (string)	-of  	output cluster file\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-npix	Npix limit\n");
strcat(UsageHelp," (int)   	-neig	Neighborood (4/8)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help  displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-isf",str_cmd_prm,in_seg_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ivf",str_cmd_prm,in_value_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,out_cluster_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-npix",int_cmd_prm,&Npix_lim,1,UsageHelp);
  get_commandline_prm(argc,argv,"-neig",int_cmd_prm,&Neighb,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

 if ((Neighb != 4) && (Neighb != 8)) Neighb = 4;

 check_file(in_seg_file);
 check_file(in_value_file);
 check_file(out_cluster_file);
 
 Npix_lim = (Npix_lim>1) ? Npix_lim : 1;

/********************************************************************
********************************************************************/
/* INPUT/OUTPUT FILE OPENING*/

 strcpy(filename,in_seg_file);
 if ((file_in=fopen(filename,"rb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",filename);
 strcpy(filename,in_value_file);
 if ((file_in_value=fopen(filename,"rb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",filename);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

 in_seg_val_im    = matrix_float(Nlig,Ncol);
 Cl_im            = matrix_float(Nlig,Ncol);

/********************************************************************
********************************************************************/
 
 for(lig=0;lig<Nlig;lig++) {
  PrintfLine(lig,Nlig);
  fread(&in_seg_val_im[lig][0],sizeof(float),Ncol,file_in);
  for(col=0; col<Ncol; col++) Cl_im[lig][col]=-1;
  }

printf("%f\r", 10.);fflush(stdout);
 
 find_cluster(in_seg_val_im,Nlig,Ncol,&Ncluster,Neighb); 

#ifdef toto
 Nsgl = 0;
 Nsgl_ngb = 0;
 
 for(lig=0; lig<Nlig; lig++)
  for(col=0; col<Ncol; col++)
  {
   is_sgl = 1;
   is_sgl_ngb = -1;
   for(i=-1; i<2; i++)
   {
    if(((lig+i)>=0)*((lig+i)<Nlig)*(is_sgl == 1))
    {
     for(j=-1; j<2; j++)
     {
      if(((col+j)>=0)*((col+j)<Ncol)*(is_sgl == 1))
      {
       if((i!=0)+(j!=0))
       {
        if(Cl_im[lig][col]==Cl_im[lig+i][col+j]) is_sgl = 0;
        if(is_sgl_ngb == -1)
        {
            cl = Cl_im[lig+i][col+j];
            is_sgl_ngb = 1;
        }  
       	is_sgl_ngb *= (Cl_im[lig+i][col+j]==cl);
       }
      }
     }
    }
   }
   if(is_sgl==1)
   {
    Nsgl++;
    if(is_sgl_ngb!=0)
    {
     Nsgl_ngb++;
     Cl_im[lig][col] = cl;
     Ncluster--;
    }
   }  
  }

 for(lig=0;lig<Nlig;lig++)
  for(col=0;col<Ncol;col++)
  {
   in_seg_val_im[lig][col] = Cl_im[lig][col];
   Cl_im[lig][col] = -1;
  } 

  find_cluster(in_seg_val_im,Nlig,Ncol,&Ncluster); 
#endif

/********************************************************************
********************************************************************/
printf("%f\r", 20.);fflush(stdout);

 for(lig=0; lig<Nlig; lig++)
  for(col=0; col<Ncol; col++)
   in_seg_val_im[lig][col]=0.;

 dum_im = matrix_float(Nlig,Ncol);
 
 for(lig=0;lig<Nlig;lig++)
  fread(&in_seg_val_im[lig][0],sizeof(float),Ncol,file_in_value);
  
 C_current = NULL;
 C_current = Create_Cluster_List(C_current,Ncluster);
 C_top = C_current;
 
 C_current = Add_List_Pixel(C_current,Cl_im,in_seg_val_im,Nlig,Ncol);
 
 C_current = C_top;
 while(C_current != NULL)
 {
  P_current = C_current->Coord;
  while(P_current != NULL)
  {
   dum_im[P_current->li][P_current->co] = C_current->Mean;
   P_current = P_current->Next;
  } 
  C_current = C_current->Next;
 } 

/********************************************************************
********************************************************************/
printf("%f\r", 30.);fflush(stdout);
 
 for(lig=0; lig<Nlig; lig++)
  for(col=0; col<Ncol; col++)
   dum_im[lig][col]=-1;

 C_current = C_top;
 while(C_current != NULL)
 {
  if(C_current->Npix<=Npix_lim)
  {
   P_current = C_current->Coord;
   while(P_current != NULL)
   {
    dum_im[P_current->li][P_current->co] = C_current->Npix;
    P_current = P_current->Next;
   }
  }  
  C_current = C_current->Next;
 } 
 
/********************************************************************
********************************************************************/
printf("%f\r", 40.);fflush(stdout);
 
 C_current = C_top;
 C_current = Add_List_Ngb(C_current,Cl_im,Nlig,Ncol);
 
 for(npix=1;npix<Npix_lim;npix++)
 {
  C_current = C_top;
  Nc = 0;
  while(C_current != NULL)
  {
   if(C_current->Npix==npix)
    Nc++;
   C_current = C_current->Next;
  }  
  
/********************************************************************
********************************************************************/
printf("%f\r", 50.);fflush(stdout);
  
  pgrs_bar = 0;
  cl = 0;
  C_current = C_top;  
  while(C_current != NULL)
  {
   if(C_current->Npix==npix)
   {
    cl++;
    if(cl>pgrs_bar)
    {
     pgrs_bar += (int)floor((float)(0.04*Nc));
    } 
    C_dum1 = C_current->Next;
    C_dum = Find_nearest_Ngb(C_current);
    C_top = Merge_clusters(C_top,C_current,C_dum,&Ncluster);
    C_current = C_dum1;
   }
   else
    C_current = C_current->Next;
  }
 }
 
/********************************************************************
********************************************************************/
printf("%f\r", 60.);fflush(stdout);
 
 for(lig=0;lig<Nlig;lig++)
  for(col=0;col<Ncol;col++)
   Cl_im[lig][col] = -1;
    
 C_tmp = Update_clusters(C_top,Cl_im);  
 C_tmp0 = C_tmp; C_tmp = C_tmp0; //To avoid compil warning

/********************************************************************
********************************************************************/
printf("%f\r", 70.);fflush(stdout);
 
 for(lig=0; lig<Nlig; lig++)
  for(col=0; col<Ncol; col++)
   dum_im[lig][col]=-1;

 C_current = C_top;
 while(C_current != NULL)
 {
  P_current = C_current->Coord;
  while(P_current != NULL)
  {
   dum_im[P_current->li][P_current->co] = C_current->Mean;
   P_current = P_current->Next;
  } 
  C_current = C_current->Next;
 } 

/********************************************************************
********************************************************************/
printf("%f\r", 80.);fflush(stdout);

 strcpy(filename,out_cluster_file);
 if ((file_out=fopen(filename,"wb"))==NULL)
  edit_error("\nERROR IN OPENING FILE\n",filename);

 min=Cl_im[0][0]; 
 max=Cl_im[0][0]; 
 for(lig=0;lig<Nlig;lig++)
  for(col=0;col<Ncol;col++)
  {
   min = (Cl_im[lig][col]<min) ? Cl_im[lig][col]:min; 
   max = (Cl_im[lig][col]>max) ? Cl_im[lig][col]:max; 
  }
 
 for(lig=0;lig<Nlig;lig++)
  fwrite(&Cl_im[lig][0],sizeof(float),Ncol,file_out);

/********************************************************************
********************************************************************/
printf("%f\r", 100.);fflush(stdout);
 
 free_matrix_float(in_seg_val_im,Nlig);
 free_matrix_float(dum_im,Nlig);
 free_matrix_float(Cl_im,Nlig);
 
 return 1;
} /*main*/
 

/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/
/*******************************************************************************/

struct PixX *Create_PixX(struct PixX *P, int li,int co)
{
 if(P==NULL)
 {
  P=(struct PixX *) malloc(sizeof(struct PixX));
  P->li  = li;
  P->co  = co;
  P->Next = NULL;
 } 
 else
  edit_error("Error Create PixX","");
 return P;
}  

/*******************************************************************************/

struct Cluster *Create_Cluster(struct Cluster *C)
{
 if(C==NULL)
 {
  C=(struct Cluster *) malloc(sizeof(struct Cluster));
  C->Nbr  = 0;
  C->Npix = 0;
  C->Mean = 0;
  C->Prev = NULL;
  C->Next = NULL;
  C->Coord  = NULL;
  C->Ngb_cl = NULL;
 } 
 else
  edit_error("Error Create Cluster","");
 return C;
}  

/*******************************************************************************/

struct Ngb *Create_Ngb(struct Ngb *N,float cl)
{
 if(N==NULL)
 {
  N=(struct Ngb *) malloc(sizeof(struct Ngb));
  N->cl  = cl;
  N->Next = NULL;
  N->Prev = NULL;
 } 
 else
  edit_error("Error Create Ngb","");
 return N;
}  

/*******************************************************************************/

struct Cluster *Create_Cluster_List(struct Cluster *C_top, int Nb_cl)
{
 int n;
 struct Cluster *C_current;

 if((C_top == NULL)&&(Nb_cl >= 1))
 {
  C_current = NULL;
  C_current = Create_Cluster(C_current);
  C_top = C_current; 
  C_current->Nbr = 0;

  for(n=1;n<Nb_cl;n++)
  { 
   C_current = NULL;
   C_current = Create_Cluster(C_current);
   C_current->Nbr = n;
   C_current->Prev = C_top;
   C_top->Next = C_current;
   C_top = C_current;
  } 
  while(C_top->Prev != NULL)
   C_top = C_top->Prev;
 } 
 else
  edit_error("Error Create Cluster","");
 return C_top;
}  

/*******************************************************************************/

struct Cluster *Add_List_Pixel(struct Cluster *C,float **cl_im,float **in_value_im, int Nlig, int Ncol)
{
 int lig,col; 
 struct PixX *P;

 for(lig=0;lig<Nlig;lig++)
  for(col=0;col<Ncol;col++)
  { 
   while((cl_im[lig][col]>C->Nbr)&&(C->Next != NULL))
    C = C->Next;
   while((cl_im[lig][col]<C->Nbr)&&(C->Prev != NULL))
    C = C->Prev;
   if(C->Nbr != cl_im[lig][col])
   {
    //printf("\n %f, %f \n",cl_im[lig][col],C->Nbr);
    edit_error("Error Add Pixel","");
   } 

   P = NULL;
   P = Create_PixX(P,lig,col);
   P->Next = C->Coord;
   C->Coord = P;
   C->Npix ++;
   C->Mean += in_value_im[lig][col];
  }

  while(C->Prev != NULL) C = C->Prev;
   
  while(C->Next != NULL)
  {
   C->Mean /= (float)(C->Npix);  
   C = C->Next;
  } 
   
  return C;
}  

/*******************************************************************************/

struct  Ngb *Add_Cluster_Ngb(struct Ngb *N,float cl)
{
 struct Ngb *N_current,*N_dum;

 
 if(N==NULL)
 {
  N_current = NULL;
  N_current = Create_Ngb(N_current,cl); 
  N = N_current;
 }
 else
 { 
  while((N->cl < cl)&&(N->Next != NULL))   N = N->Next;
  while((N->cl > cl)&&(N->Prev != NULL))   N = N->Prev;
  N_current = N;
  if(N->cl != cl)
  {
   N_current = NULL;
   N_current = Create_Ngb(N_current,cl); 

   if(N->cl > cl)
   {
    N_current->Next = N;
    N_current->Prev = N->Prev;
    N_dum = N_current->Prev;
    if(N_dum != NULL)
     N_dum->Next = N_current;
    N->Prev = N_current;  
   }
   else
   {
    N_current->Prev = N;
    N_current->Next = N->Next;
    N_dum = N_current->Next;
    if(N_dum != NULL)
     N_dum->Prev = N_current;
    N->Next = N_current;  
   }
  } 
 }
 while(N_current->Prev != NULL)   N_current = N_current->Prev;
 return N_current;
}   
 
/*******************************************************************************/

struct  Ngb *Rem_Cluster_Ngb(struct Ngb *N,float cl)
{
 struct Ngb *N_dum;

 
 while((N->cl < cl)&&(N->Next != NULL))   N = N->Next;
 while((N->cl > cl)&&(N->Prev != NULL))   N = N->Prev;
 if(N->cl != cl)
 {
  //printf("\n N->cl=%f, cl=%d\n",N->cl,(int)cl);
  while(N->Prev != NULL)   N = N->Prev;
  while(N != NULL)
  {
   //printf("\n nbg=%d \n",(int)N->cl);
   N = N->Next;
  } 
  
  edit_error("Error remove neighbour","");
 }
 N_dum = N->Prev;
 N = N->Next;
 
 if(N_dum != NULL)
  N_dum->Next = N; 
 if(N != NULL)
  N->Prev = N_dum;
 
 if(N_dum == NULL)
   N_dum = N;
 
 if(N_dum != NULL)
  while(N_dum->Prev !=NULL)
   N_dum = N_dum->Prev;
 
 return N_dum;  
}   

/*******************************************************************************/

struct Cluster *Add_List_Ngb(struct Cluster *C,float **cl_im, int Nlig, int Ncol)
{
 int lig,col,i,j,ind; 
 struct PixX *P;
 //struct Ngb *N;
 float N_list[9];
 
 N_list[8]=-1;

 while(C != NULL)
 {
   P = C->Coord;
//   N = C->Ngb_cl;
   while(P != NULL)
   {
    lig=P->li;
    col=P->co;
    for(i=0;i<8;i++)
     N_list[i]=-1;
    for(i=-1;i<=+1;i++)
     for(j=-1;j<=+1;j++)
      if(((i+lig)>=0)*((i+lig)<Nlig)*((j+col)>=0)*((j+col)<Ncol))
       if(cl_im[i+lig][j+col] != C->Nbr)
       {
        ind=0;
        while((N_list[ind] != cl_im[i+lig][j+col]) && (N_list[ind] != -1))
         ind++;
        if(N_list[ind] == -1)
         N_list[ind] = cl_im[i+lig][j+col];
       }	
    ind=0;
    while(N_list[ind] != -1)
    {
     C->Ngb_cl = Add_Cluster_Ngb(C->Ngb_cl,N_list[ind]);
     ind++;
    } 
    P=P->Next;  
   }
  C = C->Next;
 }  
 return C;
}  

/*******************************************************************************/

void find_cluster(float **im,int Nlig, int Ncol,float *Ncluster, int Neighb)
{
int lig,col;
int **ind_list;

ind_list=matrix_int(2,Nlig*Ncol);

*Ncluster = 0;
for(lig=0; lig<Nlig; lig++)
  for(col=0; col<Ncol; col++)
  {


  if(Cl_im[lig][col]<0)
  {
    locate_cluster(im,im[lig][col],*Ncluster,lig,col,Nlig,Ncol,ind_list,Neighb);
    (*Ncluster)++;
  }
  }

free_matrix_int(ind_list,2);
}

/*******************************************************************************/

void locate_cluster(float **im,float val,float Ncluster,int lig, int col,int Nlig, int Ncol, int **ind_list, int Neighb)
{
int n,ind,i,j;


Cl_im[lig][col] = Ncluster;
n=0;
ind_list[0][n] = lig;
ind_list[1][n] = col;
ind=0;

while(ind<=n)
{

/*  8-neighborhood */
if (Neighb == 8)
{
	for(i=my_max(ind_list[0][ind]-1,0);i<my_min(ind_list[0][ind]+2,Nlig);i++)
		for(j=my_max(ind_list[1][ind]-1,0);j<my_min(ind_list[1][ind]+2,Ncol);j++)
		{
			if((Cl_im[i][j]<0)&&(im[i][j]==val))
			{
				Cl_im[i][j] = Ncluster;
				n++;
				ind_list[0][n] = i;
				ind_list[1][n] = j;
			}
		}
}

/* 4-neighborhood */
if (Neighb == 4)
{
	j=ind_list[1][ind];
	for(i=my_max(ind_list[0][ind]-1,0);i<my_min(ind_list[0][ind]+2,Nlig);i++)
	{
		if((Cl_im[i][j]<0)&&(im[i][j]==val))
		{
			Cl_im[i][j] = Ncluster;
			n++;
			ind_list[0][n] = i;
			ind_list[1][n] = j;
		}
	}
	i=ind_list[0][ind];
	for(j=my_max(ind_list[1][ind]-1,0);j<my_min(ind_list[1][ind]+2,Ncol);j++)
	{
		if((Cl_im[i][j]<0)&&(im[i][j]==val))
		{
			Cl_im[i][j] = Ncluster;
			n++;
			ind_list[0][n] = i;
			ind_list[1][n] = j;
		}
	}
}
ind++;    

}
} 

/*******************************************************************************/

struct Cluster *Find_nearest_Ngb(struct Cluster *C_current)
{
 float cl,min_dist,dist;
 struct Ngb *N_current;
 struct Cluster *C_dum;
 
 N_current = C_current->Ngb_cl;
 C_dum = C_current;

 /* Locate neighbour cluster */
 while(N_current->cl < C_dum->Nbr) C_dum = C_dum->Prev;
 while(N_current->cl > C_dum->Nbr) C_dum = C_dum->Next;
 if(C_dum->Nbr != N_current->cl)
  edit_error("Cluster error","");
        
  dist = fabs(C_current->Mean-C_dum->Mean);
  min_dist = dist;
  cl = C_dum->Nbr;
    
 /* Look for the minimum distance neighbouring cluster */ 
  while(N_current->Next != NULL)
  {
   N_current = N_current->Next;
   while(N_current->cl<C_dum->Nbr) C_dum = C_dum->Prev;
   while(N_current->cl>C_dum->Nbr) C_dum = C_dum->Next;
   if(N_current->cl != C_dum->Nbr)
    edit_error("Cluster error2","");
   
   dist = fabs(C_current->Mean-C_dum->Mean);
   if(min_dist > dist)
   {
    min_dist = dist;
    cl = C_dum->Nbr;
   }
  }  
  while(cl<C_dum->Nbr) C_dum = C_dum->Prev;
  while(cl>C_dum->Nbr) C_dum = C_dum->Next;
  if(cl != C_dum->Nbr)
   edit_error("Cluster error3","");

  return C_dum;
}

/*******************************************************************************/

struct Cluster *Merge_clusters(struct Cluster *C_top,struct Cluster *C_from,struct Cluster *C_to,float *Ncluster)
{
 //int cl; 
 struct Ngb *N_current,*N_dum1;
 //struct Ngb *N_dum2;
 struct PixX *P_current;
 struct Cluster *C_dum;
 
 /* Update destination cluster number of pixels and mean value */ 
 C_to->Mean  = C_to->Mean*C_to->Npix+C_from->Mean*C_from->Npix;
 C_to->Npix += C_from->Npix;
 C_to->Mean /= C_to->Npix;
 //printf("\n pix number and mean value updated \n");

 /* Transfer pixel list to destination cluster */
 P_current = C_from->Coord;
 while(P_current->Next != NULL)
  P_current = P_current->Next;
 P_current->Next = C_to->Coord;
 C_to->Coord = C_from->Coord;
 //printf("\n Pixel list updated \n");
 
 /* Transfer neighbour list to destination cluster */
 
 /* First, remove origin cluster number from all neighbour list */
 N_current = C_from->Ngb_cl;
 while(N_current != NULL)
 {
  /* Look for the neighbour cluster */
  C_dum = C_from;
  while(N_current->cl<C_dum->Nbr) C_dum = C_dum->Prev;
  while(N_current->cl>C_dum->Nbr) C_dum = C_dum->Next;
  if(N_current->cl != C_dum->Nbr)
	  edit_error("Error merge cluster 1","");
  
  C_dum->Ngb_cl = Rem_Cluster_Ngb(C_dum->Ngb_cl,C_from->Nbr);

  N_current = N_current->Next;
 }  
 
 //printf("\n Original number removed from neignbour lists \n");

 /* Then add each origin cluster neighbour number to destination cluster neigbour list*/
 N_current = C_from->Ngb_cl;
 N_dum1 = C_to->Ngb_cl;
 while(N_current != NULL)
 {
  if(N_current->cl != C_to->Nbr)
   C_to->Ngb_cl = Add_Cluster_Ngb(N_dum1,N_current->cl);
  N_current = N_current->Next;
 }
 /* Add destination cluster to each origin cluster neighbour neighbour list*/
 N_current = C_from->Ngb_cl;
 C_dum = C_from;
 while(N_current != NULL)
 {
  while(N_current->cl<C_dum->Nbr) C_dum = C_dum->Prev;
  while(N_current->cl>C_dum->Nbr) C_dum = C_dum->Next;
  if(N_current->cl != C_dum->Nbr)
	  edit_error("Error merge cluster 2","");
  
  if(N_current->cl != C_to->Nbr)
   C_dum->Ngb_cl = Add_Cluster_Ngb(C_dum->Ngb_cl,C_to->Nbr);
  N_current = N_current->Next;
 }

 //printf("\n Neighbour list updated \n");

 /* Then delete each neigbour from original neigbour list*/
/*
 N_dum1 = C_from->Ngb_cl;
 while(N_dum1 != NULL)
 {
  N_dum2 = N_dum1->Next;
  free(N_dum1);
  N_dum1 = N_dum2;
 }
*/

 /* Remove origin cluster from cluster list*/
// cl = C_from->Nbr;

 if(C_from == C_top)
 {
  C_top = C_top->Next;
  C_top->Prev = NULL;
 }
 else
 {
  C_dum = C_from->Prev;
  C_from = C_from->Next;
  C_dum->Next = C_from;
  if(C_from !=NULL)
   C_from->Prev = C_dum;  
 }

//printf("\n List and cluster image updated  \n");
//printf("\n Out from function \n");
 
 (*Ncluster)--;
 return C_top;
} 

/*******************************************************************************/

struct Cluster *Update_clusters(struct Cluster *C_top,float **cl_im)
{
// int old_cl;
 int cl; 
 //struct Ngb *N_current;
 struct PixX *P_current;
 struct Cluster *C_dum;
 //struct Cluster *C_dum1;
 
 /* Update list and clustered image information */
 
 cl = 0;
 C_dum = C_top;
 while(C_dum != NULL)
 {
  if(C_dum->Nbr>cl)
  {
//   old_cl = C_dum->Nbr;
   C_dum->Nbr = cl;
   P_current = C_dum->Coord;
   while(P_current != NULL)
   {
    cl_im[P_current->li][P_current->co] = C_dum->Nbr;
    P_current = P_current->Next;
   }
/*
   C_dum1 = C_top;
   while(C_dum1 != NULL)
   {
    N_current = C_dum1->Ngb_cl;
    while((N_current->cl <= old_cl)*(N_current != NULL))
    {
     if(N_current->cl==old_cl)
      N_current->cl = cl;
     N_current = N_current->Next;
    }
    C_dum1 = C_dum1->Next;
   }
*/  
  }   
  C_dum = C_dum->Next;
  cl++;
 } 
return C_dum;
}


