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

File   : Tomo_coh_disp.c
Project  : ESA_POLSARPRO
Authors  : Laurent FERRO-FAMIL
Version  : 1.0
Creation : 01/2015
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

Description :  Polarimetry Tomography Coherences Map Display

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

/* ALIASES  */
#define my_square_LFF(x) ((x)*(x)) 
#define my_max_LFF(a,b) ((a)>(b) ? (a):(b))
#define my_min_LFF(a,b) ((a)<(b) ? (a):(b))

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"

/* CONSTANTS  */
#define Npolar_in       3   /* nb of input/output files */

/* ROUTINE DECLARATION */
float ****read_k_strip(int row_cut,int ind0,int Wr,int Wc,int *Nr, int *Nc,int *W, int Nim, int Npol,int Nr_im, int Nc_im, char *in_dir, char **im_dir);
char **read_tomo_cfg(char *in_dir, int *Nim);
void read_individual_cfg(char *im_dir, int *Nr_im, int *Nc_im);  
float ****filter_k_to_R(int Wr,int Wc,int Fr,int Fc,int *Nr, int *Nc, int Nim, int Npol,int Nr_im, int Nc_im, char *file_dem, char **im_dir, int comp_dem);
//void **R_to_coh_im(char *in_dir,float ****R,int Nr,int Nc,int Npol,int Nim);
void R_to_coh_im(char *in_dir,float ****R,int Nr,int Nc,int Npol,int Nim, int comp_dem);
void to_T(float ***Cin,float ***Tout,int Nim);
void bmp_jet_gray(int Nr, int Npolr, int Nimr, int Nc, int Npolc, int Nimc, float **DataBmp, char *name);
void jet_gray_colormap(int *red, int *green, int *blue);

float ****matrix4d_float(int n1, int n2, int n3, int n4);
void free_matrix4d_float(float ****m, int n1, int n2,int n3);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main (int argc,char *argv[])
{

 //FILE   *file;
 char  dem_file[FilePathLength];
 //char  file_name[FilePathLength];
 char  in_dir[FilePathLength],**im_dir;
 //char  usage[FilePathLength];

 int Nim,Npol=Npolar_in,Nc,Nr,Nc_im,Nr_im;
 //int row,col,pol,im;
 int loop;
 
 float ****R;
 
 int   Wr,Wc,Fr,Fc,comp_dem;

 /********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nTomo_coh_disp.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-dem 	input slant-range DEM file\n");
strcat(UsageHelp," (int)   	-nwr 	Nwin Row\n");
strcat(UsageHelp," (int)   	-nwc 	Nwin Col\n");
strcat(UsageHelp," (int)   	-fr  	Undersampling factor in cells in Row direction\n");
strcat(UsageHelp," (int)   	-fc  	Undersampling factor in cells in Col direction\n");
strcat(UsageHelp," (int)   	-cd  	comp_dem 0/1 compensates DEM prior to tomographic focusing\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 15) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-dem",str_cmd_prm,dem_file,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwr",int_cmd_prm,&Wr,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nwc",int_cmd_prm,&Wc,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fr",int_cmd_prm,&Fr,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fc",int_cmd_prm,&Fc,1,UsageHelp);
  get_commandline_prm(argc,argv,"-cd",int_cmd_prm,&comp_dem,1,UsageHelp);
  }
  
/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_file(dem_file);

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
 read_individual_cfg(im_dir[0],&Nr_im,&Nc_im);  

/********************************************************************
********************************************************************/

 R=filter_k_to_R(Wr,Wc,Fr,Fc,&Nr,&Nc,Nim,Npol,Nr_im,Nc_im,dem_file,im_dir,comp_dem);

 R_to_coh_im(in_dir,R,Nr,Nc,Npol,Nim,comp_dem);
 
/********************************************************************
********************************************************************/
 
 free_matrix4d_float(R,Nr,Nc,(Nim*Npol*(Nim*Npol+1)/2));
 for(loop=Nim-1;loop>=0;loop--) free((char *) im_dir[loop]);
 free((char *) im_dir);
  
 
 return 1;
}
/********************************************************************
********************************************************************/
/********************************************************************
********************************************************************/
//void **R_to_coh_im(char *in_dir,float ****R,int Nr,int Nc,int Npol,int Nim)
void R_to_coh_im(char *in_dir,float ****R,int Nr,int Nc,int Npol,int Nim, int comp_dem)
{
 int row,col,im1,im2,pol1,pol2,ind;
 int r,c;
 float **Rps_coh,**Rsp_coh,**Rps_coh_P,**Rsp_coh_P,***Rps,***Rsp,***Rps_P,***Rsp_P;
 float M[4];
 char file_name[FilePathLength];
 //FILE *file;

 Rps=matrix3d_float(Nim*Npol,Nim*Npol,2);
 Rsp=matrix3d_float(Nim*Npol,Nim*Npol,2);
 Rps_coh=matrix_float(Nr*Npol*Nim,Nc*Npol*Nim);
 Rsp_coh=matrix_float(Nr*Npol*Nim,Nc*Npol*Nim);
 Rps_P=matrix3d_float(Nim*Npol,Nim*Npol,2);
 Rsp_P=matrix3d_float(Nim*Npol,Nim*Npol,2);
 Rps_coh_P=matrix_float(Nr*Npol*Nim,Nc*Npol*Nim);
 Rsp_coh_P=matrix_float(Nr*Npol*Nim,Nc*Npol*Nim);

 for(row=0;row<Nr;row++)
 {
  PrintfLine(row,Nr);
  for(col=0;col<Nc;col++)
  {
   ind=0;
   for(pol1=0;pol1<Npol;pol1++)
    for(im1=0;im1<Nim;im1++)
     for(pol2=pol1;pol2<Npol;pol2++)
      for(im2=im1*(pol1==pol2);im2<Nim;im2++)
       {
       Rps[im1+pol1*Nim][im2+pol2*Nim][0]= R[row][col][ind][0];
       Rps[im1+pol1*Nim][im2+pol2*Nim][1]= R[row][col][ind][1];
       Rps[im2+pol2*Nim][im1+pol1*Nim][0]= R[row][col][ind][0];
       Rps[im2+pol2*Nim][im1+pol1*Nim][1]=-R[row][col][ind][1];
       ind++;
       }
      
   for(im1=0;im1<Nim;im1++)
    for(pol1=0;pol1<Npol;pol1++)
     for(im2=im1;im2<Nim;im2++)
      for(pol2=pol1*(im1==im2);pol2<Npol;pol2++)
       {
       Rsp[pol1+im1*Npol][pol2+im2*Npol][0]=  Rps[im1+pol1*Nim][im2+pol2*Nim][0];
       Rsp[pol1+im1*Npol][pol2+im2*Npol][1]=  Rps[im1+pol1*Nim][im2+pol2*Nim][1];
       Rsp[pol2+im2*Npol][pol1+im1*Npol][0]=  Rps[im1+pol1*Nim][im2+pol2*Nim][0];
       Rsp[pol2+im2*Npol][pol1+im1*Npol][1]= -Rps[im1+pol1*Nim][im2+pol2*Nim][1];
       }
      
    for(r=0;r<Nim*Npol;r++)
     {
     Rps_coh[r*Nr+row][r*Nc+col]=Rps[r][r][0];
     Rsp_coh[r*Nr+row][r*Nc+col]=Rsp[r][r][0];
     for(c=r+1;c<Nim*Npol;c++)
      {
      Rps_coh[c*Nr+row][r*Nc+col]= atan2(Rps[r][c][1],Rps[r][c][0]);
      Rps_coh[r*Nr+row][c*Nc+col]= sqrt((my_square_LFF(Rps[r][c][1])+my_square_LFF(Rps[r][c][0]))/(Rps[r][r][0]*Rps[c][c][0]));
      Rsp_coh[c*Nr+row][r*Nc+col]= atan2(Rsp[r][c][1],Rsp[r][c][0]);
      Rsp_coh[r*Nr+row][c*Nc+col]= sqrt((my_square_LFF(Rsp[r][c][1])+my_square_LFF(Rsp[r][c][0]))/(Rsp[r][r][0]*Rsp[c][c][0]));
      }
    }

   to_T(Rsp,Rsp_P,Nim);
   
   for(pol1=0;pol1<Npol;pol1++)
    for(im1=0;im1<Nim;im1++)
     for(pol2=pol1;pol2<Npol;pol2++)
      for(im2=im1*(pol1==pol2);im2<Nim;im2++)
       {
       Rps_P[im1+pol1*Nim][im2+pol2*Nim][0] = Rsp_P[pol1+im1*Npol][pol2+im2*Npol][0];
       Rps_P[im1+pol1*Nim][im2+pol2*Nim][1] = Rsp_P[pol1+im1*Npol][pol2+im2*Npol][1];
       Rps_P[im2+pol2*Nim][im1+pol1*Nim][0] = Rsp_P[pol1+im1*Npol][pol2+im2*Npol][0];
       Rps_P[im2+pol2*Nim][im1+pol1*Nim][1] =-Rsp_P[pol1+im1*Npol][pol2+im2*Npol][1];
       }
       
   for(r=0;r<Nim*Npol;r++)
    {
    Rps_coh_P[r*Nr+row][r*Nc+col]=Rps_P[r][r][0];
    Rsp_coh_P[r*Nr+row][r*Nc+col]=Rsp_P[r][r][0];
    for(c=r+1;c<Nim*Npol;c++)
     {
     Rps_coh_P[c*Nr+row][r*Nc+col]= atan2(Rps_P[r][c][1],Rps_P[r][c][0]);
     Rps_coh_P[r*Nr+row][c*Nc+col]= sqrt((my_square_LFF(Rps_P[r][c][1])+my_square_LFF(Rps_P[r][c][0]))/(Rps_P[r][r][0]*Rps_P[c][c][0]));
     Rsp_coh_P[c*Nr+row][r*Nc+col]= atan2(Rsp_P[r][c][1],Rsp_P[r][c][0]);
     Rsp_coh_P[r*Nr+row][c*Nc+col]= sqrt((my_square_LFF(Rsp_P[r][c][1])+my_square_LFF(Rsp_P[r][c][0]))/(Rsp_P[r][r][0]*Rsp_P[c][c][0]));
     }
   }
   
  }
 }

 for(row=0;row<4;row++) M[row]=0;

 for(row=0;row<Nr;row++)
  for(col=0;col<Nc;col++)
   {
   M[0]+=Rps_coh[row][col];
   M[1]+=Rsp_coh[row][col];
   M[2]+=Rps_coh_P[row][col];
   M[3]+=Rsp_coh_P[row][col];
   }
  for(row=0;row<4;row++) M[row]/=(Nr*Nc/2);

  for(im1=0;im1<Nim*Npol;im1++)
   for(row=0;row<Nr;row++)
    for(col=0;col<Nc;col++)
    {
     Rps_coh[im1*Nr+row][im1*Nc+col]   = my_min_LFF(Rps_coh[im1*Nr+row][im1*Nc+col],M[0])/M[0]*127+128;
     Rsp_coh[im1*Nr+row][im1*Nc+col]   = my_min_LFF(Rsp_coh[im1*Nr+row][im1*Nc+col],M[1])/M[1]*127+128;
     Rps_coh_P[im1*Nr+row][im1*Nc+col] = my_min_LFF(Rps_coh_P[im1*Nr+row][im1*Nc+col],M[2])/M[2]*127+128;
     Rsp_coh_P[im1*Nr+row][im1*Nc+col] = my_min_LFF(Rsp_coh_P[im1*Nr+row][im1*Nc+col],M[3])/M[3]*127+128;
    }
  
 for(im1=0;im1<Nim*Npol;im1++)
  for(im2=im1+1;im2<Nim*Npol;im2++)
   for(row=0;row<Nr;row++)
    for(col=0;col<Nc;col++)
   {
    Rps_coh[im1*Nr+row][im2*Nc+col]   = my_max_LFF(my_min_LFF(Rps_coh[im1*Nr+row][im2*Nc+col],1),0)*127+128;
    Rsp_coh[im1*Nr+row][im2*Nc+col]   = my_max_LFF(my_min_LFF(Rsp_coh[im1*Nr+row][im2*Nc+col],1),0)*127+128;
    Rps_coh_P[im1*Nr+row][im2*Nc+col] = my_max_LFF(my_min_LFF(Rps_coh_P[im1*Nr+row][im2*Nc+col],1),0)*127+128;
    Rsp_coh_P[im1*Nr+row][im2*Nc+col] = my_max_LFF(my_min_LFF(Rsp_coh_P[im1*Nr+row][im2*Nc+col],1),0)*127+128;
   }

 for(im1=0;im1<Nim*Npol;im1++)
  for(im2=0;im2<im1;im2++)
   for(row=0;row<Nr;row++)
    for(col=0;col<Nc;col++)
   {
    Rps_coh[im1*Nr+row][im2*Nc+col]   = (Rps_coh[im1*Nr+row][im2*Nc+col]/M_PI+1)*127/2; 
    Rsp_coh[im1*Nr+row][im2*Nc+col]   = (Rsp_coh[im1*Nr+row][im2*Nc+col]/M_PI+1)*127/2;
    Rps_coh_P[im1*Nr+row][im2*Nc+col] = (Rps_coh_P[im1*Nr+row][im2*Nc+col]/M_PI+1)*127/2;
    Rsp_coh_P[im1*Nr+row][im2*Nc+col] = (Rsp_coh_P[im1*Nr+row][im2*Nc+col]/M_PI+1)*127/2;
   } 

 if ( comp_dem == 1) {
   sprintf(file_name,"%s/Pol_Space_lexico_tomographic_coherences_DEMcomp.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rps_coh, file_name);
   sprintf(file_name,"%s/Space_pol_lexico_tomographic_coherences_DEMcomp.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rsp_coh, file_name);
   sprintf(file_name,"%s/Pol_Space_Pauli_tomographic_coherences_DEMcomp.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rps_coh_P, file_name);
   sprintf(file_name,"%s/Space_pol_Pauli_tomographic_coherences_DEMcomp.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rsp_coh_P, file_name);
   } else {
   sprintf(file_name,"%s/Pol_Space_lexico_tomographic_coherences.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rps_coh, file_name);
   sprintf(file_name,"%s/Space_pol_lexico_tomographic_coherences.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rsp_coh, file_name);
   sprintf(file_name,"%s/Pol_Space_Pauli_tomographic_coherences.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rps_coh_P, file_name);
   sprintf(file_name,"%s/Space_pol_Pauli_tomographic_coherences.bmp",in_dir);
   bmp_jet_gray(Nr,Npol,Nim,Nc,Npol,Nim,Rsp_coh_P, file_name);
   }

 free_matrix_float(Rps_coh,Nr*Npol*Nim);
 free_matrix3d_float(Rps,Npol*Nim,Npol*Nim);
 free_matrix_float(Rsp_coh,Nr*Npol*Nim);
 free_matrix3d_float(Rsp,Npol*Nim,Npol*Nim);
 free_matrix_float(Rps_coh_P,Nr*Npol*Nim);
 free_matrix3d_float(Rps_P,Npol*Nim,Npol*Nim);
 free_matrix_float(Rsp_coh_P,Nr*Npol*Nim);
 free_matrix3d_float(Rsp_P,Npol*Nim,Npol*Nim);
}

/********************************************************************
********************************************************************/
void to_T(float ***Cin,float ***Tout,int Nim)
{
 int r,c,im1,im2;
 float dum[3][3][2];

 for(im1=0;im1<Nim;im1++)
  for(im2=0;im2<Nim;im2++)
  {
 for(r=0;r<3;r++)
  for(c=0;c<2;c++)
 {
  dum[r][0][c]=Cin[im1*3+r][im2*3+0][c]+Cin[im1*3+r][im2*3+2][c];
  dum[r][1][c]=Cin[im1*3+r][im2*3+0][c]-Cin[im1*3+r][im2*3+2][c];  
  dum[r][2][c]=2*Cin[im1*3+r][im2*3+1][c];
 }
 for(r=0;r<3;r++)
  for(c=0;c<2;c++)
 {
  Tout[im1*3+0][im2*3+r][c]=(dum[0][r][c]+dum[2][r][c])/4;
  Tout[im1*3+1][im2*3+r][c]=(dum[0][r][c]-dum[2][r][c])/4;  
  Tout[im1*3+2][im2*3+r][c]=dum[1][r][c]*sqrt(2)/2;
 }

  }
}

/********************************************************************
********************************************************************/
void bmp_jet_gray(int Nr, int Npolr, int Nimr, int Nc, int Npolc, int Nimc, float **DataBmp, char *name)
{
    FILE *fbmp;
    //FILE *fcolormap;

    char *bufimg;
    char *bufcolor;
    //char Tmp[1024];

    int lig, col, l;
	int iir, iic, jjr, jjc, kkr, kkc;
    int bmpnlig, bmpncol, ncolbmp, extracol, Ncolor;
    int red[256], green[256], blue[256];
    int offligpol, offcolpol, offligim, offcolim; 
    int ligpolpix, ligimpix, colpolpix, colimpix;

    ligpolpix = 7; ligimpix = 3;
    colpolpix = 7; colimpix = 3;
    bmpnlig = Nr*Npolr*Nimr + ligpolpix*(Npolr-1) + ligimpix*Npolr*(Nimr-1);
    bmpncol = Nc*Npolc*Nimc + colpolpix*(Npolc-1) + colimpix*Npolc*(Nimc-1);

    extracol = (int) fmod(4 - (int) fmod(bmpncol, 4), 4);
    ncolbmp = bmpncol + extracol;

    bufimg = vector_char(bmpnlig * ncolbmp);
    bufcolor = vector_char(1024);

    if ((fbmp = fopen(name, "wb")) == NULL)
      edit_error("ERREUR DANS L'OUVERTURE DU FICHIER", name);
/*****************************************************************************/
/* Definition of the Header */

    header(bmpnlig, bmpncol, 1, 0, fbmp);
    write_bmp_hdr(bmpnlig, bmpncol, 1., 0., 8, name);

/*****************************************************************************/
/* Definition of the Colormap */
    Ncolor=256;
    jet_gray_colormap(red,green,blue);

/* Bitmap colormap and BMP writing */
    for (col = 0; col < 1024; col++) bufcolor[col] = (char) (0);

    for (col = 0; col < Ncolor; col++) {
      bufcolor[4 * col] = (char) (blue[col]);
      bufcolor[4 * col + 1] = (char) (green[col]);
      bufcolor[4 * col + 2] = (char) (red[col]);
      bufcolor[4 * col + 3] = (char) (0);
      }

    fwrite(&bufcolor[0], sizeof(char), 1024, fbmp);

    l = 255;
    for (lig = 0; lig < bmpnlig; lig++) for (col = 0; col < ncolbmp; col++) bufimg[lig * ncolbmp + col] = (char) l;

    for (iir = 0; iir < Npolr; iir++) {
      offligpol = iir*(ligpolpix + ligimpix*(Nimr-1));
      for (jjr = 0; jjr < Nimr; jjr++) {
        offligim = jjr*ligimpix;
        for (kkr = 0; kkr < Nr; kkr++) {
          lig = kkr + jjr*Nr + iir*Nr*Nimr;
          for (iic = 0; iic < Npolc; iic++) {
            offcolpol = iic*(colpolpix + colimpix*(Nimc-1));            
            for (jjc = 0; jjc < Nimc; jjc++) {
              offcolim = jjc*colimpix;
              for (kkc = 0; kkc < Nc; kkc++) {
                col = kkc + jjc*Nc + iic*Nc*Nimc;
                l = (int) DataBmp[Nr*Npolr*Nimr - lig - 1][col];
                bufimg[(lig + offligpol + offligim)* ncolbmp + (col + offcolpol + offcolim)] = (char) l;          
                }
              }
            }
          }
        }
      }

    fwrite(&bufimg[0], sizeof(char), bmpnlig * ncolbmp, fbmp);

    free_vector_char(bufcolor);
    free_vector_char(bufimg);
    fclose(fbmp);
}

/********************************************************************
********************************************************************/
void jet_gray_colormap(int *red, int *green, int *blue)
{
  int k;

  for (k = 0; k < 128; k++)
  {
  red[k+128] = 2*k; green[k+128] = 2*k; blue[k+128] = 2*k;
  }

  for (k = 0; k < 32; k+=2) {
    red[k/2] = 128 + 4 * k;
    green[k/2] = 0.;
    blue[k/2] = 0.;
    }
  for (k = 0; k < 64; k+=2) {
    red[(32 + k)/2] = 255;
    green[(32 + k)/2] = 4 * k;
    blue[(32 + k)/2] = 0.;
    }
  for (k = 0; k < 64; k+=2) {
    red[(96 + k)/2] = 252 - 4 * k;
    green[(96 + k)/2] = 255;
    blue[(96 + k)/2] = 4 * k;
    }
  for (k = 0; k < 64; k+=2) {
    red[(160 + k)/2] = 0;
    green[(160 + k)/2] = 252 - 4 * k;
    blue[(160 + k)/2] = 255;
    }
  for (k = 0; k < 32; k+=2) {
    red[(224 + k)/2] = 0;
    green[(224 + k)/2] = 0.;
    blue[(224 + k)/2] = 252 - 4 * k;
    }
}

/********************************************************************
********************************************************************/
float ****filter_k_to_R(int Wr,int Wc,int Fr,int Fc,int *Nr, int *Nc, int Nim, int Npol,int Nr_im, int Nc_im, char *file_dem, char **im_dir,int comp_dem)
{
 int row,col,im,loop,r,c,ind_pol,Rr,Rc;
 int N;
 int *rind,*cind;
 float phi,dum[2];
 float **k,****Rps,*dem,*kz;
 char file_name[FilePathLength];
 FILE **in_file;
 FILE **kz_file;
 FILE *DEM_file;

 Wr=(int)floor(Wr/2);
 Wc=(int)floor(Wc/2);

 N=Nim*Npol;
 
 *Nr=0; for(loop=(int)round(Fr/2);loop<Nr_im;loop+=Fr) (*Nr)++;
 *Nc=0; for(loop=(int)round(Fc/2);loop<Nc_im;loop+=Fc) (*Nc)++;

 Rps=matrix4d_float(*Nr,*Nc,N*(N+1)/2,2);
 rind=vector_int(*Nr);
 rind[0]=(int)round(Fr/2); for(loop=1;loop<(*Nr);loop++) rind[loop]=rind[loop-1]+Fr;
 cind=vector_int(*Nc);
 cind[0]=(int)round(Fc/2); for(loop=1;loop<(*Nc);loop++) cind[loop]=cind[loop-1]+Fc;
 
 
 in_file = (FILE **) malloc((unsigned) (N) * sizeof(FILE *));
 kz_file = (FILE **) malloc((unsigned) (Nim-1) * sizeof(FILE *));
 
 dem=vector_float(Nc_im);
 kz=vector_float(Nc_im);

 loop=0;
 for(r=0;r<2;r++)
  for(c=r;c<2;c++)
   for(im=0;im<Nim;im++)
   {
    sprintf(file_name,"%ss%d%d.bin",im_dir[im],r+1,c+1);
    if ((in_file[loop]=fopen(file_name,"rb"))==NULL)
     edit_error("Could not open input file : ",file_name);
    loop++;
   }

 if(comp_dem == 1)
 {
 if ((DEM_file=fopen(file_dem,"rb"))==NULL)
     edit_error("Could not open input file : ",file_dem);

  for(im=1;im<Nim;im++)
   {
    sprintf(file_name,"%skz.bin",im_dir[im]);
    if ((kz_file[im-1]=fopen(file_name,"rb"))==NULL)
     edit_error("Could not open input file : ",file_name);
   }

 }
 
 k=matrix_float(N,Nc_im*2);

 for(row=0;row<Nr_im;row++)
 {
  PrintfLine(row,Nr_im);
  for(loop=0;loop<N;loop++)
   fread(k[loop],sizeof(float),Nc_im*2,in_file[loop]);

  for(loop=0;loop<Nim;loop++)
   for(c=0;c<Nc_im*2;c++)
    k[Nim+loop][c]*=sqrt(2);

  if(comp_dem == 1)
  {
    fread(dem,sizeof(float),Nc_im,DEM_file);
   for(im=1;im<Nim;im++)
   {
    fread(kz,sizeof(float),Nc_im,kz_file[im-1]);
    for(ind_pol=0;ind_pol<Npol;ind_pol++)
     for(col=0;col<Nc_im;col++)
    {
    phi=dem[col]*kz[col];
    
    for(ind_pol=0;ind_pol<Npol;ind_pol++)
    {
     dum[0] = k[im+ind_pol*Nim][2*col]*cos(phi)-  k[im+ind_pol*Nim][2*col+1]*sin(phi);
     dum[1] = k[im+ind_pol*Nim][2*col+1]*cos(phi)+k[im+ind_pol*Nim][2*col]*sin(phi);
     k[im+ind_pol*Nim][2*col]=dum[0];
     k[im+ind_pol*Nim][2*col+1]=dum[1];
    }
    }

   }
  }
  
  for(r=0;r<*Nr;r++)
   for(c=0;(c<*Nc)*(abs(rind[r]-row)<=Wr);c++)
   {
    for(col=my_max_LFF(0,cind[c]-Wc);col<my_min_LFF(cind[c]+Wc+1,Nc_im);col++)
    {
     ind_pol=0;
     for(Rr=0;Rr<N;Rr++)
     {
      Rps[r][c][ind_pol][0] += my_square_LFF(k[Rr][2*col])+my_square_LFF(k[Rr][2*col+1]);
      ind_pol++;
      for(Rc=Rr+1;Rc<N;Rc++)
      {
       Rps[r][c][ind_pol][0] +=k[Rr][2*col]*k[Rc][2*col]+k[Rr][2*col+1]*k[Rc][2*col+1];
       Rps[r][c][ind_pol][1] +=-k[Rr][2*col]*k[Rc][2*col+1]+k[Rr][2*col+1]*k[Rc][2*col];
      ind_pol++;
      }
     }
    }
   }  
 }
 
 
 free((FILE **) (in_file));
 free((FILE **) (kz_file));
 free_vector_float(dem);
 free_vector_float(kz);
 free_matrix_float(k,N);
 return Rps;
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
void read_individual_cfg(char *im_dir, int *Nr_im, int *Nc_im)  
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
 fclose(in_file);
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
 for(row=0;row<(2*W+1);row++)
  for(col=0;col<Nc;col++)
  {   
   hamming_filter[row][col] = (0.54-0.46*cos(2*M_PI *(float) row/(2*(float)W)))
    *(0.54-0.46*cos(2*M_PI * (float) col/((float)Nc -1)));
   sum += hamming_filter[row][col];
  }
 for(row=0;row<(2*W+1);row++)
  for(col=0;col<Nc;col++)
   hamming_filter[row][col] /= sum; 

/**************************************************************/
/*  WARNING: ONLY THE LOWER TRIANGULAR PART OF R IS FILLED IN */
/**************************************************************/
 for(row=0;row<Nr;row++)
  for(i=0;i<N;i++)
   for(j=0;j<i+1;j++)
   {
    R_profile[row][i][j][0]=0;
    R_profile[row][i][j][1]=0;
    for(r=my_max_LFF(row-W,0);r<my_min_LFF(row+W+1,Nr);r++)
     for(col=0;col<Nc;col++)
     {
      R_profile[row][i][j][0] += hamming_filter[r-row+W][col]*
       (k_strip[r][col][i][0]*k_strip[r][col][j][0]+k_strip[r][col][i][1]*k_strip[r][col][j][1]);
      R_profile[row][i][j][1] += hamming_filter[r-row+W][col]*
       (-k_strip[r][col][i][0]*k_strip[r][col][j][1]+k_strip[r][col][i][1]*k_strip[r][col][j][0]);
     }
   }
 
 free_matrix_float(hamming_filter,2*W+1);
 
}
