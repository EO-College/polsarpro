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

File   : Tomo_NP_Spec_est.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 1.1
Creation : 01/2015
Update  : 08/2018 (E Pottier : split initial SW in two SWs : BF and 
                   Capon)
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

Description :  Polarimetry Tomography Specrtum Estimation : BF

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

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* CONSTANTS  */
#define Npolar_in 3   /* nb of input/output files */

typedef struct geo_cfg {
  char row_dim;
  char col_dim; 
  float row_min; 
  float row_max; 
  float col_min; 
  float col_max;
  }  sgeo_cfg;

/* ROUTINE DECLARATION */
void cmplx_chol_dec_L(float ***A,float ***L, int N);
void cmplx_inv_tr_L(float ***L,float ***iL, int N);

void BF_Full_Rank_tomo_profile(float ****R_profile,float ****Tomo_FR,float *z_ax,int Nr, int Nim, int Npol, int Nz,float ***kz_vec, int Nmed);
void B_L_BF(float **Tomo,float **a,float ***L, float *** mvecs,int Nim, int Npol, float ****dum);

float ****read_k_strip(int row_cut,int ind0,int Wr,int Wc,int *Nr, int *Nc,int *W, int Nim, int Npol,int Nr_im, int Nc_im, char **im_dir);
void filter_k_to_r_profile(float ****R_profile,float **** k_strip,int Nr, int Nc, int N, int W);
void read_DEM_ztop(int row_cut,int ind0,int Wr,int Wc,char *file_ztop,char *file_dem,float **DEM, float *DEM_profile, float *ztop_profile, int comp_DEM, int Nr_im,int Nc_im, int Nr, int Nc);
float ***read_kz_strip(int row_cut,int ind0,int Wr,int Wc,int Nr_im, int Nc_im,int Nim, char **im_dir);
char **read_tomo_cfg(char *in_dir, int *Nim);
void read_individual_tomo_cfg(char *im_dir, int *Nr_im, int *Nc_im,sgeo_cfg *sg_cfg);  
float *build_z_ax(float zmin,float zmax,float dz,int *Nz);
void write_tomo_cfg(char *out_dir,int Nz,int Nx,float zmin, float zmax, int row_cut,sgeo_cfg *g_cfg);
void write_tomo_data(char *out_dir,int Nz,int Nx,float ****Tomo_FR, float *DEM_profile, float *ztop_profile);
void compensate_dem(float ****k_strip,float **DEM_strip,float ***kz_strip,int Nr,int Nc,int Nim, int Npol);

float ****matrix4d_float(int n1, int n2, int n3, int n4);
void free_matrix4d_float(float ****m, int n1, int n2,int n3);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{
 char  in_dir[FilePathLength],**im_dir;
 char  out_dir[FilePathLength];
 char  dem_file[FilePathLength], top_height_file[FilePathLength];

 int W,Nz,Nmed,loop;
 int Nim,Npol=Npolar_in,Nc,Nr,Nc_im,Nr_im;
 
 float ****k_strip,****R_profile;
 float ***kz_strip,**DEM_strip;
 float *DEM_profile,*ztop_profile;
 float ****Tomo;
 float *z_ax;

 int   row_cut,ind0,Wr,Wc,comp_dem;
 float zmin,dz,zmax;
 sgeo_cfg g_cfg;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nTomo_NP_Spec_est_BF.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-dem 	input slant-range DEM file\n");
strcat(UsageHelp," (string)	-th  	input slant-range top_height file\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-ind 	row/col index of the tomographic profile\n");
strcat(UsageHelp," (int)   	-rc  	row_cut 0 = analysis along a column-wise (fixed-row) profile, 1 = analysis along a row-wise (fixed-col) profile\n");
strcat(UsageHelp," (int)   	-cd  	comp_dem 0/1 compensates DEM prior to tomographic focusing\n");
strcat(UsageHelp," (float) 	-zmin	minimum z value\n");
strcat(UsageHelp," (float) 	-zmax	maximum z value\n");
strcat(UsageHelp," (float) 	-dz  	delta z value\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 25) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dem",str_cmd_prm,dem_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-th",str_cmd_prm,top_height_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&Wr,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&Wc,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ind",int_cmd_prm,&ind0,1,UsageHelp);
  get_commandline_prm(argc,argv,"-rc",int_cmd_prm,&row_cut,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cd",int_cmd_prm,&comp_dem,1,UsageHelp);
  get_commandline_prm(argc,argv,"-zmin",flt_cmd_prm,&zmin,1,UsageHelp);
  get_commandline_prm(argc,argv,"-zmax",flt_cmd_prm,&zmax,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dz",flt_cmd_prm,&dz,1,UsageHelp);
  }
  
/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  check_file(dem_file);
  check_file(top_height_file);
 
  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/********************************************************************
********************************************************************/

 im_dir=read_tomo_cfg(in_dir,&Nim);
 read_individual_tomo_cfg(im_dir[0],&Nr_im,&Nc_im,&g_cfg);  

/********************************************************************
********************************************************************/
 k_strip=read_k_strip(row_cut,ind0,Wr,Wc,&Nr,&Nc,&W,Nim,Npol,Nr_im,Nc_im,im_dir);
 
 Nmed=(Nc-1)/2;
 kz_strip=read_kz_strip(row_cut,ind0,Wr,Wc,Nr_im,Nc_im,Nim,im_dir);
 read_kz_strip(row_cut,ind0,Wr,Wc,Nr_im,Nc_im,Nim,im_dir);

/********************************************************************
********************************************************************/

 DEM_strip = matrix_float(Nr,Nc);
 DEM_profile = vector_float(Nr);
 ztop_profile = vector_float(Nr);
 read_DEM_ztop(row_cut,ind0,Wr,Wc,top_height_file,dem_file,DEM_strip,DEM_profile,ztop_profile,comp_dem,Nr_im,Nc_im,Nr,Nc);

/********************************************************************
********************************************************************/

 if(comp_dem == 1) compensate_dem(k_strip,DEM_strip,kz_strip,Nr,Nc,Nim,Npol);
 
 R_profile = matrix4d_float(Nr,Nim*Npol,Nim*Npol,2);
 
 filter_k_to_r_profile(R_profile,k_strip,Nr,Nc,Nim*Npol,W);
 
 z_ax=build_z_ax(zmin,zmax,dz,&Nz);
 Tomo= matrix4d_float(Nr,Nz,Npol*(Npol+1)/2,2);
 
 BF_Full_Rank_tomo_profile(R_profile,Tomo,z_ax,Nr,Nim,Npol,Nz,kz_strip,Nmed);
 
/********************************************************************
********************************************************************/

 write_tomo_cfg(out_dir,Nz,Nr,z_ax[0],z_ax[Nz-1],row_cut,&g_cfg);
 write_tomo_data(out_dir,Nz,Nr,Tomo,DEM_profile,ztop_profile);

/********************************************************************
********************************************************************/

 free_matrix4d_float(k_strip,Nr,Nc,Nim*Npol);
 free_matrix3d_float(kz_strip,Nr,Nc);
 free_matrix4d_float(R_profile,Nr,Nim*Npol,Nim*Npol);
 free_vector_float(z_ax);
 free_matrix4d_float(Tomo,Nr,Nz,Npol*(Npol+1)/2); 
 for(loop=Nim-1;loop>=0;loop--) free((char *) im_dir[loop]);
 free((char *) im_dir);
 
 return 1;
}

/********************************************************************
*********************************************************************
*********************************************************************
********************************************************************/
void compensate_dem(float ****k_strip,float **DEM_strip,float ***kz_strip,int Nr,int Nc,int Nim, int Npol)
{
 int row,col,im,pol;
 float dum[2],phi;

 for(row=0;row<Nr;row++) {
  PrintfLine(row,Nr);
  for(col=0;col<Nc;col++) {
   for(im=1;im<Nim;im++) {
    phi=DEM_strip[row][col]*kz_strip[row][col][im];
    for(pol=0;pol<Npol;pol++) {
    dum[0] = k_strip[row][col][im+pol*Nim][0]*cos(phi)-k_strip[row][col][im+pol*Nim][1]*sin(phi);
    dum[1] = k_strip[row][col][im+pol*Nim][1]*cos(phi)+k_strip[row][col][im+pol*Nim][0]*sin(phi);
    k_strip[row][col][im+pol*Nim][0]=dum[0];
    k_strip[row][col][im+pol*Nim][1]=dum[1];
    }
   }
  }
 }
}

/********************************************************************
********************************************************************/
void write_tomo_data(char *out_dir,int Nz,int Nx,float ****Tomo_FR,float *DEM_profile, float *ztop_profile)
{
 FILE *file;
 int r,c,ind_pol,ind_z,ind_x;
 char file_name[FilePathLength];
 float *dum;

 dum=vector_float(Nx);
 ind_pol=0;

  for(r=0;r<3;r++) {
   PrintfLine(r,3);

   sprintf(file_name,"%sT%d%d.bin",out_dir,r+1,r+1);
   if ((file=fopen(file_name,"wb"))==NULL)
    edit_error("Could not open output file : ",file_name);
   for(ind_z=0;ind_z<Nz;ind_z++) {
    for(ind_x=0;ind_x<Nx;ind_x++)
     dum[ind_x]=Tomo_FR[ind_x][Nz-1-ind_z][ind_pol][0];
    fwrite(&dum[0],sizeof(float),Nx,file);
    }
   fclose(file);

   ind_pol++;
   for(c=r+1;c<3;c++) {
    sprintf(file_name,"%sT%d%d_real.bin",out_dir,r+1,c+1);
    if ((file=fopen(file_name,"wb"))==NULL)
     edit_error("Could not open output file : ",file_name);
    for(ind_z=0;ind_z<Nz;ind_z++) {
     for(ind_x=0;ind_x<Nx;ind_x++)
      dum[ind_x]=Tomo_FR[ind_x][Nz-1-ind_z][ind_pol][0];
     fwrite(&dum[0],sizeof(float),Nx,file);
     }
    fclose(file);
    sprintf(file_name,"%sT%d%d_imag.bin",out_dir,r+1,c+1);
    if ((file=fopen(file_name,"wb"))==NULL)
     edit_error("Could not open output file : ",file_name);
    for(ind_z=0;ind_z<Nz;ind_z++) {
     for(ind_x=0;ind_x<Nx;ind_x++)
      dum[ind_x]=Tomo_FR[ind_x][Nz-1-ind_z][ind_pol][1];
     fwrite(&dum[0],sizeof(float),Nx,file);
     }
    fclose(file);
    ind_pol++;
   }
  }
  sprintf(file_name,"%sDEM_profile.bin",out_dir);
  if ((file=fopen(file_name,"wb"))==NULL)
   edit_error("Could not open output file : ",file_name);
  fwrite(&DEM_profile[0],sizeof(float),Nx,file);
  fclose(file);
  sprintf(file_name,"%sz_top_profile.bin",out_dir);
  if ((file=fopen(file_name,"wb"))==NULL)
   edit_error("Could not open output file : ",file_name);
  fwrite(&ztop_profile[0],sizeof(float),Nx,file);
  fclose(file);

  free_vector_float(dum);
}

/********************************************************************
********************************************************************/
void write_tomo_cfg(char *out_dir,int Nz,int Nx,float zmin, float zmax, int row_cut,sgeo_cfg *g_cfg)
{
 char file_name[FilePathLength];
 FILE *cfg_file;

 sprintf(file_name,"%sconfig.txt",out_dir);
 
 if ((cfg_file=fopen(file_name,"w"))==NULL)
  edit_error("Could not open output file : ",file_name);

 fprintf(cfg_file,"Nz\n%d\n---------\nNx\n%d\n---------\nPolarcase\nmonostatic\n---------\nPolartype\nfull\n---------\nzdim [m|cm]\nm\n---------\n",Nz,Nx);
 if(row_cut == 1)
  fprintf(cfg_file,"xdim [m|bin]\n%s\n---------\n",strcmp(&g_cfg->row_dim,"m") ? "m":"bin");
 else
  fprintf(cfg_file,"xdim [m|bin]\n%s\n---------\n",strcmp(&g_cfg->col_dim,"m") ? "m":"bin");

 fprintf(cfg_file,"zmin\n%f\n---------\nzmax\n%f\n---------\n",zmin,zmax);
 if(row_cut == 1)
  fprintf(cfg_file,"xmin\n%f\n---------\nxmax\n%f",g_cfg->row_min,g_cfg->row_max);
 else
  fprintf(cfg_file,"xmin\n%f\n---------\nxmax\n%f",g_cfg->col_min,g_cfg->col_max);
 fclose(cfg_file);
 
}

/********************************************************************
********************************************************************/
float *build_z_ax(float zmin,float zmax,float dz,int *Nz)
{
 int loop;
 float *z_ax;
 
 *Nz=(int)floor((zmax-zmin)/dz+1);
 z_ax=vector_float(*Nz);
 z_ax[0]=zmin;
 for(loop=1;loop<(*Nz);loop++) 
  z_ax[loop] =  z_ax[loop-1]+dz;

 return z_ax;
}

/********************************************************************
********************************************************************/
void read_individual_tomo_cfg(char *im_dir, int *Nr_im, int *Nc_im,sgeo_cfg *g_cfg)  
{
 char file_name[FilePathLength];
 FILE *in_file;
 
 sprintf(file_name,"%sconfig.txt",im_dir);
 if ((in_file=fopen(file_name,"r"))==NULL)
  edit_error("Could not open input file : ",file_name);

 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%d\n",Nr_im);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%d\n",Nc_im);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%s\n",file_name);
  if(!strcmp(file_name,"bin")) sprintf(&g_cfg->row_dim,"m"); else sprintf(&g_cfg->row_dim,"b");
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%s\n",file_name);
  if(!strcmp(file_name,"bin")) sprintf(&g_cfg->col_dim,"m"); else sprintf(&g_cfg->col_dim,"b");
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%f\n",&g_cfg->row_min);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%f\n",&g_cfg->row_max);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%f\n",&g_cfg->col_min);
 fgets(file_name,FilePathLength,in_file);
 fgets(file_name,FilePathLength,in_file);
  fscanf(in_file,"%f\n",&g_cfg->col_max);

 fclose(in_file);
}

/********************************************************************
********************************************************************/
char **read_tomo_cfg(char *in_dir, int *Nim)
{
 char file_name[FilePathLength],**im_dir;
 FILE *in_file;
 int loop;
 
 sprintf(file_name,"%sconfig_mult.txt",in_dir);
 if ((in_file=fopen(file_name,"r"))==NULL)
  edit_error("Could not open input file : ",file_name);

 fscanf(in_file,"%d\n",Nim);
 im_dir= (char **) malloc((unsigned) (*Nim) * sizeof(char *));
 fgets(file_name,FilePathLength,in_file);
 for(loop=0;loop<(*Nim);loop++)
   im_dir[loop]= (char *) malloc(FilePathLength * sizeof(char));
 for(loop=0;loop<(*Nim);loop++) {
   fscanf(in_file,"%s\n",im_dir[loop]);
   check_dir(im_dir[loop]);
   }
 return im_dir;
}

/********************************************************************
********************************************************************/
void BF_Full_Rank_tomo_profile(float ****R_profile,float ****Tomo_FR,float *z_ax,int Nr, int Nim, int Npol, int Nz,float ***kz_strip,int Nmed)
{
 float ***L, ***iL,**a,***mvecs;
 float ****dum; 
 int i,indz,row;
 
 dum = matrix4d_float(2,Npol,Npol,2);
 L  = matrix3d_float(Nim*Npol,Nim*Npol,2);
 iL = matrix3d_float(Nim*Npol,Nim*Npol,2);
 mvecs = matrix3d_float(Npol,Nim*Npol,2);
 a = matrix_float(Nim,2);
  
 for(row=0;row<Nr;row++) {
  PrintfLine(row,Nr);
  cmplx_chol_dec_L(R_profile[row],L,Nim*Npol);
  cmplx_inv_tr_L(L,iL,Nim*Npol);

  for(indz=0;indz<Nz;indz++)
  {
   a[0][0]=1; a[0][1]=0;
   for(i=1;i<Nim;i++)
   {
    a[i][0]=cos(kz_strip[row][Nmed][i]*z_ax[indz]);
    a[i][1]=-sin(kz_strip[row][Nmed][i]*z_ax[indz]);
   }
   B_L_BF(Tomo_FR[row][indz],a,L,mvecs,Nim,Npol,NULL);
  }
 }
 free_matrix4d_float(dum,2,Npol,Npol);
 free_matrix3d_float(L,Nim*Npol,Nim*Npol);
 free_matrix3d_float(iL,Nim*Npol,Nim*Npol);
 free_matrix3d_float(mvecs,Npol,Nim*Npol);
 free_matrix_float(a,Nim); 
}

/********************************************************************
********************************************************************/
void B_L_BF(float **Tomo,float **a,float ***L, float *** mvecs,int Nim, int Npol,float ****dum)
{
 int pol1, pol2, i, j, ind_pol, istart;

 for(pol1=0;pol1<Npol;pol1++) {
  for(j=0;j<(pol1+1)*Nim;j++) {
    mvecs[pol1][j][0] = 0;
    mvecs[pol1][j][1] = 0;
    istart=my_max(j,Nim*pol1);
    for(i=istart;i<(pol1+1)*Nim;i++)
    {
     mvecs[pol1][j][0] +=  L[i][j][0]*a[i-pol1*Nim][0]+L[i][j][1]*a[i-pol1*Nim][1];
     mvecs[pol1][j][1] += -L[i][j][0]*a[i-pol1*Nim][1]+L[i][j][1]*a[i-pol1*Nim][0];
    }
   }
  }

  ind_pol=0;
  for(pol1=0;pol1<Npol;pol1++) {
   for(pol2=pol1;pol2<Npol;pol2++) {
    Tomo[ind_pol][0] = 0;
    Tomo[ind_pol][1] = 0;
    for(j=0;j<(pol1+1)*Nim;j++)
    {
     Tomo[ind_pol][0] += mvecs[pol1][j][0]*mvecs[pol2][j][0]
      +mvecs[pol1][j][1]*mvecs[pol2][j][1];
     Tomo[ind_pol][1] += - mvecs[pol1][j][0]*mvecs[pol2][j][1]
      +mvecs[pol1][j][1]*mvecs[pol2][j][0];
    }
    ind_pol++;
    }
   }
  for(pol1=0;pol1<Npol;pol1++)
   for(j=0;j<Npol*Nim;j++)
   {
    mvecs[pol1][j][0]=0;
    mvecs[pol1][j][1]=0;
   }
}
  
/********************************************************************
********************************************************************/
void filter_k_to_r_profile(float ****R_profile,float **** k_strip,int Nr, int Nc, int N, int W)
{
 int i,j,row,col,r;
 float sum; 
 float **hamming_filter;
 
 hamming_filter= matrix_float(2*W+1,Nc);
 sum=0;
 for(row=0;row<(2*W+1);row++) {
  for(col=0;col<Nc;col++) {   
   hamming_filter[row][col] = (0.54-0.46*cos(2*M_PI *(float) row/(2*(float)W)))
    *(0.54-0.46*cos(2*M_PI * (float) col/((float)Nc -1)));
   sum += hamming_filter[row][col];
   }
  }
 for(row=0;row<(2*W+1);row++)
  for(col=0;col<Nc;col++)
   hamming_filter[row][col] /= sum; 

/**************************************************************/
/*  WARNING: ONLY THE LOWER TRIANGULAR PART OF R IS FILLED IN */
/**************************************************************/
 for(row=0;row<Nr;row++) {
  for(i=0;i<N;i++)
   for(j=0;j<i+1;j++) {
    R_profile[row][i][j][0]=0;
    R_profile[row][i][j][1]=0;
    for(r=my_max(row-W,0);r<my_min(row+W+1,Nr);r++)
     for(col=0;col<Nc;col++)
     {
      R_profile[row][i][j][0] += hamming_filter[r-row+W][col]*
       (k_strip[r][col][i][0]*k_strip[r][col][j][0]+k_strip[r][col][i][1]*k_strip[r][col][j][1]);
      R_profile[row][i][j][1] += hamming_filter[r-row+W][col]*
       (-k_strip[r][col][i][0]*k_strip[r][col][j][1]+k_strip[r][col][i][1]*k_strip[r][col][j][0]);
     }
    }
   }
 
 free_matrix_float(hamming_filter,2*W+1);
}

/********************************************************************
********************************************************************/
void read_DEM_ztop(int row_cut,int ind0,int Wr,int Wc,char *file_ztop,char *file_dem,float **DEM, float *DEM_profile, float *ztop_profile, int comp_DEM, int Nr_im,int Nc_im, int Nr, int Nc)
{
 FILE *in_file;
 int row,col;
 float *dum;

   dum=vector_float(Nr_im*Nc_im);

 Wr=(int)floor(Wr/2);
 Wc=(int)floor(Wc/2);
 
   if ((in_file=fopen(file_ztop,"rb"))==NULL)
    edit_error("Could not open input file : ",file_ztop);
   fread(dum,sizeof(float),Nr_im*Nc_im,in_file);
   fclose(in_file);
   if(row_cut == 1) {
    for(row=0;row<Nr_im;row++) {
      PrintfLine(row,Nr_im);
      for(col=my_max(ind0-Wc,0);col<my_min(ind0+Wc+1,Nc_im);col++) {
        DEM[row][col-ind0+Wc]=dum[col+row*Nc_im];
        }
      }
    } else {
    for(col=0;col<Nc_im;col++) {
      PrintfLine(col,Nc_im);
      for(row=my_max(ind0-Wr,0);row<my_min(ind0+Wr+1,Nr_im);row++) {
        DEM[col][row-ind0+Wr]=dum[col+row*Nc_im];
        }
      }
    }

   for(row=0;row<Nr;row++)
    ztop_profile[row]=DEM[row][(Nc+1)/2];

   if ((in_file=fopen(file_dem,"rb"))==NULL)
    edit_error("Could not open input file : ",file_dem);
   fread(dum,sizeof(float),Nr_im*Nc_im,in_file);
   fclose(in_file);

   if(row_cut == 1) {
    for(row=0;row<Nr_im;row++) {
      PrintfLine(row,Nr_im);
      for(col=my_max(ind0-Wc,0);col<my_min(ind0+Wc+1,Nc_im);col++) {
        DEM[row][col-ind0+Wc]=dum[col+row*Nc_im];
        }
      }
    } else {
    for(col=0;col<Nc_im;col++) {
      PrintfLine(col,Nc_im);
      for(row=my_max(ind0-Wr,0);row<my_min(ind0+Wr+1,Nr_im);row++) {
        DEM[col][row-ind0+Wr]=dum[col+row*Nc_im];
        }
      }
    }
   if(comp_DEM == 1) {
    for(row=0;row<Nr;row++) {
     PrintfLine(row,Nr);
     ztop_profile[row]-=DEM[row][(Nc+1)/2];
     DEM_profile[row]=0;
     }
    } else {
    for(row=0;row<Nr;row++) {
     PrintfLine(row,Nr);
     DEM_profile[row]=DEM[row][(Nc+1)/2];
     }
    }
   free_vector_float(dum);
}
 
/********************************************************************
********************************************************************/
float  ***read_kz_strip(int row_cut,int ind0,int Wr,int Wc,int Nr_im, int Nc_im,int Nim, char **im_dir)
{
 int row,col,im,Nr,Nc;
 float *dum;
 float ***kz_strip;
 char file_name[FilePathLength];
 FILE *in_file;

 Wr=(int)floor(Wr/2);
 Wc=(int)floor(Wc/2);
 
 dum=vector_float(Nr_im*Nc_im);

 if(row_cut == 1)
 {
  Nr  = Nr_im;  Nc  = 2*Wc+1;  
 }
 else
 {
  Nr  = Nc_im;  Nc  = 2*Wr+1;  
 }

 kz_strip = matrix3d_float(Nr,Nc,Nim);

  for(im=1;im<Nim;im++) {
   sprintf(file_name,"%skz.bin",im_dir[im]);
   if ((in_file=fopen(file_name,"rb"))==NULL)
    edit_error("Could not open input file : ",file_name);
   fread(dum,sizeof(float),Nr_im*Nc_im,in_file);
   fclose(in_file);
   if(row_cut == 1)
   for(row=0;row<Nr_im;row++)
    for(col=my_max(ind0-Wc,0);col<my_min(ind0+Wc+1,Nc_im);col++)
     kz_strip[row][col-ind0+Wc][im]=dum[col+row*Nc_im];
   else
    for(col=0;col<Nc_im;col++)
    for(row=my_max(ind0-Wr,0);row<my_min(ind0+Wr+1,Nr_im);row++)
     kz_strip[col][row-ind0+Wr][im]=dum[col+row*Nc_im];
    
  }  
 free_vector_float(dum);
 return kz_strip;
// return 1;
}

/********************************************************************
********************************************************************/
float ****read_k_strip(int row_cut,int ind0,int Wr,int Wc,int *Nr, int *Nc,int *W, int Nim, int Npol,int Nr_im, int Nc_im, char **im_dir)
{
 int row,col,im,pol,r,c;
 float *dum,dum_k[3][2];
 float ****k_strip;
 char file_name[FilePathLength];
 FILE *in_file;

 Wr=(int)floor(Wr/2);
 Wc=(int)floor(Wc/2);
 
 dum=vector_float(2*Nr_im*Nc_im);

 if(row_cut == 1)
 {
  *Nr  = Nr_im;  *Nc  = 2*Wc+1;  
 }
 else
 {
  *Nr  = Nc_im;  *Nc  = 2*Wr+1;  
 }

 if(row_cut == 1)
  *W= Wr;
 else
  *W= Wc;

 k_strip = matrix4d_float(*Nr,*Nc,Nim*Npol,2);
  
 pol=-1;
 for(r=0;r<2;r++)
  for(c=r;c<2;c++)
  {
   pol++;
  for(im=0;im<Nim;im++) {
   sprintf(file_name,"%ss%d%d.bin",im_dir[im],r+1,c+1);
   if ((in_file=fopen(file_name,"rb"))==NULL)
    edit_error("Could not open input file : ",file_name);

   fread(dum,sizeof(float),2*Nr_im*Nc_im,in_file);
   fclose(in_file);
   
   if(row_cut == 1)
   for(row=0;row<Nr_im;row++)
    for(col=my_max(ind0-Wc,0);col<my_min(ind0+Wc+1,Nc_im);col++)
    {
     k_strip[row][col-ind0+Wc][im+pol*Nim][0]=dum[2*(col+row*Nc_im)];
     k_strip[row][col-ind0+Wc][im+pol*Nim][1]=dum[2*(col+row*Nc_im)+1];				 
    }
   else
    for(col=0;col<Nc_im;col++)
    for(row=my_max(ind0-Wr,0);row<my_min(ind0+Wr+1,Nr_im);row++)
    {
     k_strip[col][row-ind0+Wr][im+pol*Nim][0]=dum[2*(col+row*Nc_im)];
     k_strip[col][row-ind0+Wr][im+pol*Nim][1]=dum[2*(col+row*Nc_im)+1];
    }
    
  }  
 }
 if(Npol==3)
 {
  for(im=0;im<Nim;im++) {
   if(row_cut == 1)
   for(row=0;row<Nr_im;row++)
    for(col=0;col<(2*Wc+1);col++)
    {
     for(pol=0;pol<3;pol++)
     {
      dum_k[pol][0]=k_strip[row][col][im+pol*Nim][0];
      dum_k[pol][1]=k_strip[row][col][im+pol*Nim][1];
     }
     k_strip[row][col][im+0*Nim][0] = (dum_k[0][0]+dum_k[2][0])/sqrt(2);
     k_strip[row][col][im+0*Nim][1] = (dum_k[0][1]+dum_k[2][1])/sqrt(2);
     k_strip[row][col][im+1*Nim][0] = (dum_k[0][0]-dum_k[2][0])/sqrt(2);
     k_strip[row][col][im+1*Nim][1] = (dum_k[0][1]-dum_k[2][1])/sqrt(2);
     k_strip[row][col][im+2*Nim][0] = sqrt(2)*dum_k[1][0];
     k_strip[row][col][im+2*Nim][1] = sqrt(2)*dum_k[1][1];
    }
   else
    for(col=0;col<Nc_im;col++)
     for(row=0;row<(2*Wr+1);row++)
     {
     for(pol=0;pol<3;pol++)
     {
      dum_k[pol][0]=k_strip[col][row][im+pol*Nim][0];
      dum_k[pol][1]=k_strip[col][row][im+pol*Nim][0];
     }
     k_strip[col][row][im+0*Nim][0] = (dum_k[0][0]+dum_k[2][0])/sqrt(2);
     k_strip[col][row][im+0*Nim][1] = (dum_k[0][1]+dum_k[2][1])/sqrt(2);
     k_strip[col][row][im+1*Nim][0] = (dum_k[0][0]-dum_k[2][0])/sqrt(2);
     k_strip[col][row][im+1*Nim][1] = (dum_k[0][1]-dum_k[2][1])/sqrt(2);
     k_strip[col][row][im+2*Nim][0] = sqrt(2)*dum_k[1][0];
     k_strip[col][row][im+2*Nim][1] = sqrt(2)*dum_k[1][1];    
   }    
  }
 }
 
 free_vector_float(dum);
 return k_strip;
// return 1;
}

/********************************************************************
********************************************************************/
void cmplx_inv_tr_L(float ***L,float ***iL, int N)
{
 int i,j,k;
 float s[2];

 for(j=0;j<N;j++)
 {
  iL[j][j][0]=1/L[j][j][0];
  for(i=j+1;i<N;i++)
  {
   s[0]=0;
   s[1]=0;
   for(k=0;k<i;k++)
   {
    s[0] +=  L[i][k][0]*iL[k][j][0]-L[i][k][1]*iL[k][j][1];
    s[1] +=  L[i][k][0]*iL[k][j][1]+L[i][k][1]*iL[k][j][0];
   }
   iL[i][j][0] = -s[0]/L[i][i][0];
   iL[i][j][1] = -s[1]/L[i][i][0];
  }
 }
}

/********************************************************************
********************************************************************/
void  cmplx_chol_dec_L(float ***A,float ***L, int N)
{
 int i,j,k;
 float s[2];
 
 for(i=0;i<N;i++)
  for(j=0;j<(i+1);j++)
  {
   s[0]=0;
   s[1]=0;
   for(k=0;k<j;k++)
   {
    s[0] +=  L[i][k][0]*L[j][k][0]+L[i][k][1]*L[j][k][1];
    s[1] += -L[i][k][0]*L[j][k][1]+L[i][k][1]*L[j][k][0];
   }
   if(i==j)
    L[i][i][0]=sqrt(A[i][i][0]-s[0]);
   else
   {
    L[i][j][0]=(A[i][j][0]-s[0])/L[j][j][0];
    L[i][j][1]=(A[i][j][1]-s[1])/L[j][j][0];
   }
  }   
}

/********************************************************************
********************************************************************/
float ****matrix4d_float(int n1, int n2, int n3, int n4)
{
 int ind1,ind2,ind3,ind4;
 float ****m;


 m = (float ****) malloc((unsigned) (n1) * sizeof(float ***));
 if (m == NULL)
  edit_error("D'ALLOCATION No.1 DANS MATRIX()", "");
 for (ind1 = 0; ind1 < n1; ind1++)
 {
  m[ind1] = (float ***) malloc((unsigned) (n2) * sizeof(float **));
  if (m[ind1] == NULL)
   edit_error("D'ALLOCATION No.2 DANS MATRIX()", "");
  for (ind2 = 0; ind2 < n2; ind2++)
  {
   m[ind1][ind2] = (float **) malloc((unsigned) (n3) * sizeof(float *));
   if (m[ind1][ind2] == NULL)
    edit_error("D'ALLOCATION No.3 DANS MATRIX()", "");
   for (ind3 = 0; ind3 < n3; ind3++)
   {
    m[ind1][ind2][ind3] = (float *) malloc((unsigned) (n4) * sizeof(float));
    if (m[ind1][ind2][ind3] == NULL)
     edit_error("D'ALLOCATION No.4 DANS MATRIX()", "");
   }
  }
 }
 for (ind1 = 0; ind1 < n1; ind1++)
  for (ind2 = 0; ind2 < n2; ind2++)
   for (ind3 = 0; ind3 < n3; ind3++)
    for (ind4 = 0; ind4 < n4; ind4++)
     m[ind1][ind2][ind3][ind4] = (float) (0.);
 return m;
}

/********************************************************************
********************************************************************/
void free_matrix4d_float(float ****m, int n1, int n2,int n3)
{
 int i,j,k;

 for(i=n1-1;i>=0;i--)
   for(j=n2-1;j>=0;j--)
     for(k=n3-1;k>=0;k--)
       free((float *) (m[i][j][k]));
 free((float *) (m));
 m = NULL;
}

