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

File  : edge_detector_paillou.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER - Philippe PAILLOU
Version  : 1.0
Creation : 02/2017
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
  laurent.ferro-famil@univ-rennes1.fr
*--------------------------------------------------------------------

Adapted from : 

.NAME     detpai.c
.LANGUAGE C
.AUTHOR   Ph. Paillou
.COMMENTS Hyperbolic sinus edge detector
.VERSION  2.0 05-10-1996

*--------------------------------------------------------------------

The program takes as input raw images with 1 byte pixels.

Typical use:
detpai -x 512 -y 512 -i input_image -g gradient_amplitude -d 
gradient_direction -G max_gradient_amplitude -D max_gradient_direction
 -a 1.0 -w 0.1 -t 10

where:
- input_image is a raw byte image
- gradient_amplitude is the "gradient amplitude" raw byte image
- gradient_direction is the "gradient direction" raw byte image
- max_gradient_amplitude is the "gradient amplitude" local maxima 
  raw byte image
- max_gradient_direction is the "gradient direction" local maxima 
  raw byte image
For signification of -a (alpha) -w (omega) and -t (threshold) 
parameters, see reference:
Ph. Paillou, "Dectecting Step Edges in Noisy SAR Images: A New Linear
Operator", IEEE Transactions on Geoscience and Remote Sensing, 35(1),
pp. 191-196, 1997.

For any questions and comments, you can contact Prof. Philippe Paillou
at: paillou@observ.u-bordeaux.fr

*
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

/* GLOBAL VARIABLES */
#define FACT 255.0 / 2.0 / M_PI 
#define BORDER 10

static float *out_x,*out_y,*plus,*minus;
static unsigned char *image,*ampli,*aangle,*max_ampli,*max_aangle;
int xlen,ylen;

void x_filtering(a,b1,b2,a0,a1,a2,a3)
float a;
float b1;
float b2;
float a0;
float a1;
float a2;
float a3;
{
int	i,j;

for (j = 0;j<ylen;j++)
  {
  plus[0] = 0.0;
  plus[1] = (float)(image[j*xlen]);
  minus[xlen] = 0.0;
  minus[xlen-1] = 0.0;
  for (i = 2;i<xlen;i++)
    plus[i] = (float)(image[i-1+j*xlen])-b1*plus[i-1]-b2*plus[i-2];
  for (i = 2;i<(xlen+1);i++)
    minus[xlen-i] = (float)(image[xlen-i+1+j*xlen])-b1*minus[xlen-i+1]-b2*minus[xlen-i+2];
  for (i = 0;i<xlen;i++)
    out_x[i+j*xlen] = a*(plus[i]-minus[i]);
  }
for (i = 0;i<xlen;i++)
  {
  plus[0] = a0*out_x[i];
  plus[1] = a0*out_x[i+xlen]+a1*out_x[i]-b1*plus[0];
  minus[ylen] = 0.0;
  minus[ylen-1] = 0.0;
  minus[ylen-2] = a2*out_x[i+(ylen-1)*xlen];
  for (j = 2;j<ylen;j++)
    {
    plus[j] = a0*out_x[i+j*xlen]+a1*out_x[i+(j-1)*xlen]-b1*plus[j-1]-b2*plus[j-2];
    minus[ylen-j-1] = a2*out_x[i+(ylen-j)*xlen]+a3*out_x[i+(ylen-j+1)*xlen]-b1*minus[ylen-j]-b2*minus[ylen-j+1];
    }
  for (j = 0;j<ylen;j++)
    out_x[i+j*xlen] = plus[j]+minus[j];
  }
} /* x_filtering */


void y_filtering(a,b1,b2,a0,a1,a2,a3)
float a;
float b1;
float b2;
float a0;
float a1;
float a2;
float a3;
{
int	i,j;

for (i = 0;i<xlen;i++)
  {
  plus[0] = 0.0;
  plus[1] = (float)(image[i]);
  minus[ylen] = 0.0;
  minus[ylen-1] = 0.0;
  for (j = 2;j<ylen;j++)
    plus[j] = (float)(image[i+(j-1)*xlen])-b1*plus[j-1]-b2*plus[j-2];
  for (j = 2;j<(ylen+1);j++)
    minus[ylen-j] = (float)(image[i+(ylen-j+1)*xlen])-b1*minus[ylen-j+1]-b2*minus[ylen-j+2];
  for (j = 0;j<ylen;j++)
    out_y[i+j*xlen] = a*(plus[j]-minus[j]);
  }
for (j = 0;j<ylen;j++)
  {
  plus[0] = a0*out_y[j*xlen];
  plus[1] = a0*out_y[1+j*xlen]+a1*out_y[j*xlen]-b1*plus[0];
  minus[xlen] = 0.0;
  minus[xlen-1] = 0.0;
  minus[xlen-2] = a2*out_y[xlen-1+j*xlen];
  for (i = 2;i<xlen;i++)
    {
    plus[i] = a0*out_y[i+j*xlen]+a1*out_y[i-1+j*xlen]-b1*plus[i-1]-b2*plus[i-2];
    minus[xlen-i-1] = a2*out_y[xlen-i+j*xlen]+a3*out_y[xlen-i+1+j*xlen]-b1*minus[xlen-i]-b2*minus[xlen-i+1];
    }
  for (i = 0;i<xlen;i++)
    out_y[i+j*xlen] = plus[i]+minus[i];
  }
} /* y_filtering */


void filter(alpha,omega)
float alpha;
float omega;
{
float k,c1,c2,a,b1,b2,a0,a1,a2,a3;

k = (1.0-2.0*exp(-alpha)*cosh(omega)+exp(-2.0*alpha))*(alpha*alpha-omega*omega)/(2.0*alpha*exp(-alpha)*sinh(omega)+omega*(1.0-exp(-2.0*alpha)));
c1 = k*alpha/(alpha*alpha-omega*omega);
c2 = k*omega/(alpha*alpha-omega*omega);
a = -1.0+2.0*exp(-alpha)*cosh(omega)-exp(-2.0*alpha);
b1 = -2.0*exp(-alpha)*cosh(omega);
b2 = exp(-2.0*alpha);
a0 = c2;
a1 = (-c2*cosh(omega)+c1*sinh(omega))*exp(-alpha);
a2 = a1-c2*b1;
a3 = -c2*b2;
x_filtering(a,b1,b2,a0,a1,a2,a3);
y_filtering(a,b1,b2,a0,a1,a2,a3);
} /* filter */


void gradient()
{
int i,j;
float alpha_cos,alpha_sin,amp,ang;

for (i = 0;i<xlen;i++)
  for (j = 0;j<ylen;j++)
    {
    amp = sqrt(out_x[i+j*xlen]*out_x[i+j*xlen]+out_y[i+j*xlen]*out_y[i+j*xlen]);
    if (amp>=1.0)
      {
      alpha_cos = acos(out_x[i+j*xlen]/amp);
      alpha_sin = asin(out_y[i+j*xlen]/amp);
      if (alpha_sin>=0.0)
        ang = 0.5+FACT*alpha_cos;
      else
        ang = 255.5-FACT*alpha_cos;
      if ((ang>254.0)||(ang<1.0)) ang = 255.0;
      if (amp>254.0) amp = 255.0;
      ampli[i+j*xlen] = (unsigned char)(amp);
      aangle[i+j*xlen] = (unsigned char)(ang);
      }
    else
      {
      ampli[i+j*xlen] = 0;
      aangle[i+j*xlen] = 0;
      }
    }
for(j = 0;j < BORDER;j++)
  for(i = 0;i < xlen;i++)
    {
    ampli[i+j*xlen] = 0;
    ampli[i+(ylen-j-1)*xlen] = 0;
    } /* for */
for(i = 0;i < BORDER;i++)
  for(j = 0;j < ylen;j++)
    {
    ampli[i+j*xlen] = 0;
    ampli[(xlen-i-1)+j*xlen] = 0;
    } /* for */
for(j = 0;j < BORDER;j++)
  for(i = 0;i < xlen;i++)
    {
    aangle[i+j*xlen] = 0;
    aangle[i+(ylen-j-1)*xlen] = 0;
    } /* for */
for(i = 0;i < BORDER;i++)
  for(j = 0;j < ylen;j++)
    {
    aangle[i+j*xlen] = 0;
    aangle[(xlen-i-1)+j*xlen] = 0;
    } /* for */
} /* gradient */


void maxi(threshold)
int threshold;
{
int i,j,sect,comp,amp,ang;

for (i = 0;i<xlen;i++)
  for (j = 0;j<ylen;j++)
    {
    max_ampli[i+j*xlen] = 0;
    max_aangle[i+j*xlen] = 0;
    }
for (j = 1;j<(ylen-1);j++)
  for (i = 1;i<(xlen-1);i++)
    {
    amp = (int)(ampli[i+j*xlen]);
    ang = (int)(aangle[i+j*xlen]);
    if (amp>=threshold)
      {
      if (((ang>=111)&&(ang<=143))||((ang>=239)&&(ang<=255))||((ang>=0)&&(ang<=15))) sect = 1;
      else
        if (((ang>=175)&&(ang<=207))||((ang>=47)&&(ang<=79))) sect = 2;
        else
          if (((ang>=143)&&(ang<=175))||((ang>=15)&&(ang<=47))) sect = 3;
          else
            if (((ang>=207)&&(ang<=239))||((ang>=79)&&(ang<=111))) sect = 4;
            else
              sect = 0;
      comp = 0;
      switch (sect)
        {
        case 1 : if (((int)(ampli[i-1+j*xlen])<=amp)&&((int)(ampli[i+1+j*xlen])<=amp)) comp = 1;break;
        case 2 : if (((int)(ampli[i+(j-1)*xlen])<=amp)&&((int)(ampli[i+(j+1)*xlen])<=amp)) comp = 1;break;
        case 3 : if (((int)(ampli[i-1+(j-1)*xlen])<=amp)&&((int)(ampli[i+1+(j+1)*xlen])<=amp)) comp = 1;break;
        case 4 : if (((int)(ampli[i+1+(j-1)*xlen])<=amp)&&((int)(ampli[i-1+(j+1)*xlen])<=amp)) comp = 1;break;
        default: break;
        }
      if (!comp)
        {
        if (((ang==143)||(ang==175))||((ang==15)||(ang==47))) sect = 3;
        else
          if (((ang==207)||(ang==239))||((ang==79)||(ang==111))) sect = 4;
          else
            sect = 0;
        switch (sect)
          {
          case 3 : if (((int)(ampli[i-1+(j-1)*xlen])<=amp)&&((int)(ampli[i+1+(j+1)*xlen])<=amp)) comp = 1;break;
          case 4 : if (((int)(ampli[i+1+(j-1)*xlen])<=amp)&&((int)(ampli[i-1+(j+1)*xlen])<=amp)) comp = 1;break;
          default: break;
          }
        }   
      if (comp)
        {
        max_ampli[i+j*xlen] = 255;
        if ((int)(max_ampli[i+j*xlen])==0)
          max_aangle[i+j*xlen] = 0;
        else
          max_aangle[i+j*xlen] = (unsigned char)(ang);
        }
      }
    }
} /* maxi */


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
  FILE *fd_in,*fd_out;
  char name_in[FilePathLength],name_amp[FilePathLength];
  char name_ang[FilePathLength],name_maxamp[FilePathLength];
  char name_maxang[FilePathLength];
  char InputFormat[10], OutputFormat[10];
  
/* Internal variables */
  int ii, lig, col;
  int MinMaxBMP, Npts;
  float Min, Max;
  float xx, xr, xi;

/* Matrix arrays */
  float *bufferdatacmplx;
  float *bufferdatafloat;
  int *bufferdataint;
  float *datatmp;
  float *ValidMask;

/* Detector variables */
  int len;
  float alpha,omega;
  int threshold;  
  
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nedge_detector_paillou.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input file\n");
strcat(UsageHelp," (string)	-od  	output dir\n");
strcat(UsageHelp," (string)	-of1 	output amplitude file\n");
strcat(UsageHelp," (string)	-of2 	output angle file\n");
strcat(UsageHelp," (string)	-of3 	output max amplitude file\n");
strcat(UsageHelp," (string)	-of4 	output max angle file\n");
strcat(UsageHelp," (string)	-idf 	input data format (cmplx, float, int)\n");
strcat(UsageHelp," (string)	-odf 	output data format (real, imag, mod, mod2, pha)\n");
strcat(UsageHelp," (int)   	-inc 	Initial Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (float) 	-alp 	alpha parameter\n");
strcat(UsageHelp," (float) 	-omg 	omega parameter\n");
strcat(UsageHelp," (int)   	-thr 	threshold parameter\n");
strcat(UsageHelp," (int)   	-mmb 	MinMaxBmp flag (0,1,2,3)\n");
strcat(UsageHelp," (float) 	-min 	Min value (valid if MinMaxBMP = 0)\n");
strcat(UsageHelp," (float) 	-max 	Max value (valid if MinMaxBMP = 0)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help  displays this message\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 35) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,name_in,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of1",str_cmd_prm,name_amp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of2",str_cmd_prm,name_ang,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of3",str_cmd_prm,name_maxamp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of4",str_cmd_prm,name_maxang,1,UsageHelp);
  get_commandline_prm(argc,argv,"-idf",str_cmd_prm,InputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,OutputFormat,1,UsageHelp);
  get_commandline_prm(argc,argv,"-inc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-alp",flt_cmd_prm,&alpha,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ome",flt_cmd_prm,&omega,1,UsageHelp);
  get_commandline_prm(argc,argv,"-thr",int_cmd_prm,&threshold,1,UsageHelp);
  get_commandline_prm(argc,argv,"-mmb",int_cmd_prm,&MinMaxBMP,1,UsageHelp);
  if (MinMaxBMP == 0) {
    get_commandline_prm(argc,argv,"-min",flt_cmd_prm,&Min,1,UsageHelp);
    get_commandline_prm(argc,argv,"-max",flt_cmd_prm,&Max,1,UsageHelp);
    }

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;
  }

/********************************************************************
********************************************************************/

  check_file(name_in);
  check_file(name_amp);
  check_file(name_ang);
  check_file(name_maxamp);
  check_file(name_maxang);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT FILE OPENING*/
  if ((fd_in = fopen(name_in, "rb")) == NULL)
  edit_error("Could not open input file : ", name_in);

  if (FlagValid == 1) {
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);
    rewind(in_valid);
    }
  
/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */
  ValidMask = vector_float(Ncol);

  datatmp = vector_float(Sub_Nlig*Sub_Ncol);

  if (strcmp(InputFormat, "cmplx") == 0) bufferdatacmplx = vector_float(2 * Ncol);
  if (strcmp(InputFormat, "float") == 0) bufferdatafloat = vector_float(Ncol);
  if (strcmp(InputFormat, "int") == 0) bufferdataint = vector_int(Ncol);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (col = 0; col < Ncol; col++) ValidMask[col] = 1.;

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

rewind(fd_in);
if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    if (strcmp(InputFormat, "cmplx") == 0)
      fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fd_in);
    if (strcmp(InputFormat, "float") == 0)
      fread(&bufferdatafloat[0], sizeof(float), Ncol, fd_in);
    if (strcmp(InputFormat, "int") == 0)
      fread(&bufferdataint[0], sizeof(int), Ncol, fd_in);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */

Npts = -1;

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  if (strcmp(InputFormat, "cmplx") == 0)
    fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fd_in);
  if (strcmp(InputFormat, "float") == 0)
    fread(&bufferdatafloat[0], sizeof(float), Ncol, fd_in);
  if (strcmp(InputFormat, "int") == 0)
    fread(&bufferdataint[0], sizeof(int), Ncol, fd_in);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {

      Npts++;

      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + Off_col)];
        xi = bufferdatacmplx[2 * (col + Off_col) + 1];
        xx = sqrt(xr * xr + xi * xi);
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[Npts] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[Npts] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[Npts] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx > eps) datatmp[Npts] = 10. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx > eps) datatmp[Npts] = 20. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[Npts] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[Npts] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[Npts] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[Npts] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 10. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 20. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[Npts] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[Npts] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[Npts] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[Npts] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 10. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx > eps) datatmp[Npts] = 20. * log10(xx);
          else Npts--;
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[Npts] = 0.;
        }

      } /* valid */
    } /* col */
  } /* lig */

  Npts++;

/*******************************************************************/

/* AUTOMATIC DETERMINATION OF MIN AND MAX */
if ((MinMaxBMP == 1) || (MinMaxBMP == 3)) {
  if (strcmp(OutputFormat, "pha") != 0) { // case of real, imag, mod, db 
    Min = INIT_MINMAX; Max = -Min;
    for (ii = 0; ii < Npts; ii++) {
      if (my_isfinite(datatmp[ii]) != 0) {
        if (datatmp[ii] > Max) Max = datatmp[ii];
        if (datatmp[ii] < Min) Min = datatmp[ii];
        }
      }
    }
  if (strcmp(OutputFormat, "pha") == 0) {
    Max = 180.;
    Min = -180.;
    }
  }

/* ADAPT THE COLOR RANGE TO THE 95% DYNAMIC RANGE OF THE DATA */
  if ((MinMaxBMP == 1) || (MinMaxBMP == 2))
    MinMaxContrastMedian(datatmp, &Min, &Max, Npts);

/********************************************************************
********************************************************************/

/* CREATE THE CHAR IMAGE */
  ylen = Sub_Nlig; xlen = Sub_Ncol;
  //image = vector_char(rows*cols);
  if((image=(unsigned char *)calloc(Sub_Nlig*Sub_Ncol,sizeof(unsigned char))) == NULL) {
    fprintf(stderr,"Not enough memory: image !\n");
    exit(1);
    }

  rewind(fd_in);
  if (FlagValid == 1) rewind(in_valid);

/* OFFSET READING */
  for (lig = 0; lig < Off_lig; lig++) {
    if (strcmp(InputFormat, "cmplx") == 0)
      fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fd_in);
    if (strcmp(InputFormat, "float") == 0)
      fread(&bufferdatafloat[0], sizeof(float), Ncol, fd_in);
    if (strcmp(InputFormat, "int") == 0)
      fread(&bufferdataint[0], sizeof(int), Ncol, fd_in);
    if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);
    }

/* READ INPUT DATA FILE AND CREATE DATATMP 
   CORRESPONDING TO OUTPUTFORMAT */

for (lig = 0; lig < Sub_Nlig; lig++) {
  PrintfLine(lig,Sub_Nlig);
  if (strcmp(InputFormat, "cmplx") == 0)
    fread(&bufferdatacmplx[0], sizeof(float), 2 * Ncol, fd_in);
  if (strcmp(InputFormat, "float") == 0)
    fread(&bufferdatafloat[0], sizeof(float), Ncol, fd_in);
  if (strcmp(InputFormat, "int") == 0)
    fread(&bufferdataint[0], sizeof(int), Ncol, fd_in);
  if (FlagValid == 1) fread(&ValidMask[0], sizeof(float), Ncol, in_valid);

  for (col = 0; col < Sub_Ncol; col++) {

    if (ValidMask[col+ Off_col] == 1.) {

      if (strcmp(InputFormat, "cmplx") == 0) {
        xr = bufferdatacmplx[2 * (col + Off_col)];
        xi = bufferdatacmplx[2 * (col + Off_col) + 1];
        xx = sqrt(xr * xr + xi * xi);
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[col] =  bufferdatacmplx[2 * (col + Off_col)];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[col] =  bufferdatacmplx[2 * (col + Off_col) + 1];
        if (strcmp(OutputFormat, "mod") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[col] = sqrt(xr * xr + xi * xi);
          }
        if (strcmp(OutputFormat, "db10") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datatmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          xx = sqrt(xr * xr + xi * xi);
          if (xx < eps) xx = eps;
          datatmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) {
          xr = bufferdatacmplx[2 * (col + Off_col)];
          xi = bufferdatacmplx[2 * (col + Off_col) + 1];
          datatmp[col] = atan2(xi, xr + eps) * 180. / pi;
          }
        }
      
      if (strcmp(InputFormat, "float") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[col] = bufferdatafloat[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[col] =  fabs(bufferdatafloat[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs(bufferdatafloat[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[col] = 0.;
        }

      if (strcmp(InputFormat, "int") == 0) {
        if (strcmp(OutputFormat, "real") == 0) 
          datatmp[col] =  (float) bufferdataint[col + Off_col];
        if (strcmp(OutputFormat, "imag") == 0) 
          datatmp[col] = 0.;
        if (strcmp(OutputFormat, "mod") == 0) 
          datatmp[col] =  fabs((float) bufferdataint[col + Off_col]);
        if (strcmp(OutputFormat, "db10") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 10. * log10(xx);
          }
        if (strcmp(OutputFormat, "db20") == 0) {
          xx = fabs((float) bufferdataint[col + Off_col]);
          if (xx < eps) xx = eps;
          datatmp[col] = 20. * log10(xx);
          }
        if (strcmp(OutputFormat, "pha") == 0) 
          datatmp[col] = 0.;
        }
      } else {
      datatmp[col] = 0.;     
      } /* valid */    
    } /* col */
  for (col = 0; col < Sub_Ncol; col++) {
    if (xx <= eps) xx = eps;
    xx = (datatmp[col] - Min) / (Max - Min);
    if (xx < 0.) xx = 0.;
    if (xx > 1.) xx = 1.;
    image[lig*Sub_Ncol+col] = (unsigned char) floor(1. + 254. * xx);    
    }
  } /* lig */

  free_vector_float(datatmp);
  if (strcmp(InputFormat, "cmplx") == 0) free_vector_float(bufferdatacmplx);
  if (strcmp(InputFormat, "float") == 0) free_vector_float(bufferdatafloat);
  if (strcmp(InputFormat, "int") == 0) free_vector_int(bufferdataint);

/********************************************************************
********************************************************************/

/* Perform the edge detection. All of the work takes place here */
  bufferdatafloat = vector_float(Sub_Ncol);

  if (xlen > ylen) len = xlen;
  else len = ylen;
  len += 1;
  
  if ((plus = (float *) calloc(len,sizeof(float))) == NULL) {
    fprintf(stderr,"Not enough memory: plus !\n");
    exit(1);
    } /* if */
  if ((minus = (float *) calloc(len,sizeof(float))) == NULL) {
    fprintf(stderr,"Not enough memory: minus !\n");
    exit(1);
    } /* if */
  if ((out_x = (float *) calloc(xlen * ylen,sizeof(float))) == NULL) {
    fprintf(stderr,"Not enough memory: out_x !\n");
    exit(1);
    } /* if */
  if ((out_y = (float *) calloc(xlen * ylen,sizeof(float))) == NULL) {
    fprintf(stderr,"Not enough memory: out_y !\n");
    exit(1);
    } /* if */
  filter(alpha,omega);
  free(image);

/********************************************************************
********************************************************************/

  if ((ampli = (unsigned char *) calloc(xlen * ylen,sizeof(unsigned char))) == NULL) {
    fprintf(stderr,"Not enough memory: ampli !\n");
    exit(1);
    } /* if */
  if ((aangle = (unsigned char *) calloc(xlen * ylen,sizeof(unsigned char))) == NULL) {
    fprintf(stderr,"Not enough memory: angle !\n");
    exit(1);
    } /* if */
  gradient();
  
/********************************************************************
********************************************************************/

  if ((fd_out = fopen(name_amp,"wb"))==NULL) {
    fprintf(stderr,"Can't access output file %s !\n",name_amp);
    exit(1);
    } /* if */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      bufferdatafloat[col] =  (float)((int) ampli[lig*Sub_Ncol+col]) /255.;
      }
    fwrite(&bufferdatafloat[0], sizeof(float), Sub_Ncol,fd_out);
    }
  fclose(fd_out);

  if ((fd_out = fopen(name_ang,"wb"))==NULL) {
    fprintf(stderr,"Can't access output file %s !\n",name_ang);
    exit(1);
    } /* if */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      bufferdatafloat[col] =  (float)((int) aangle[lig*Sub_Ncol+col]) /255.;
      }
    fwrite(&bufferdatafloat[0], sizeof(float), Sub_Ncol,fd_out);
    }
  fclose(fd_out);
  free(out_x); free(out_y);

/********************************************************************
********************************************************************/

  if ((max_ampli = (unsigned char *) calloc(xlen * ylen,sizeof(unsigned char))) == NULL) {
    fprintf(stderr,"Not enough memory: max_ampli !\n");
    exit(1);
    } /* if */
  if ((max_aangle = (unsigned char *) calloc(xlen * ylen,sizeof(unsigned char))) == NULL) {
    fprintf(stderr,"Not enough memory: max_angle !\n");
    exit(1);
    } /* if */
  maxi(threshold);
  if ((fd_out = fopen(name_maxamp,"wb"))==NULL) {
    fprintf(stderr,"Can't access output file %s !\n",name_maxamp);
    exit(1);
    } /* if */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      bufferdatafloat[col] =  (float)((int) max_ampli[lig*Sub_Ncol+col]) /255.;
      }
    fwrite(&bufferdatafloat[0], sizeof(float), Sub_Ncol,fd_out);
    }
  fclose(fd_out);

/********************************************************************
********************************************************************/

  if ((fd_out = fopen(name_maxang,"wb"))==NULL) {
    fprintf(stderr,"Can't access output file %s !\n",name_maxang);
    exit(1);
    } /* if */
  for (lig = 0; lig < Sub_Nlig; lig++) {
    PrintfLine(lig,Sub_Nlig);
    for (col = 0; col < Sub_Ncol; col++) {
      bufferdatafloat[col] =  (float)((int) max_aangle[lig*Sub_Ncol+col]) /255.;
      }
    fwrite(&bufferdatafloat[0], sizeof(float), Sub_Ncol,fd_out);
    }
  fclose(fd_out);

  free(ampli); free(aangle);
  free(max_ampli); free(max_aangle);
  free(plus); free(minus);

/********************************************************************
********************************************************************/

  return 1;
}
