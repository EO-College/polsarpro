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

File  : cameron_decomposition.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 08/2011
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

Description :  Cameron decomposition

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

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define NPolType 1
/* LOCAL VARIABLES */
  int Config;
  char *PolTypeConf[NPolType] = {"S2"};
  FILE *out_file;
  char file_name[FilePathLength], ColorMapCameron[FilePathLength];

/* Internal variables */
  int ii, lig, col;
  int Nligg, ligg;

  float Shhr, Shhi, Shvr, Shvi, Svvr, Svvi;
  float SMhhr,SMhhi,SMhvr,SMhvi,SMvvr,SMvvi;

  float alphar, betar, gammar, alphai, betai, gammai, alpham2, betam2, gammam2;
  float r2=sqrt(2);
  float reelle,diff_abs, Psimax;
  float Xi,sinXi,cosXi;
  float epsilonr,epsiloni;

  float SsM1r,SsM1i,SsM2r,SsM2i;
  float mod2_SsM1,mod2_SsM2;
  float z_SsMr,z_SsMi;
  float mod2_z_SsM;
  float c_plan,c_diedre,c_quartp,c_dipole;
  float c_cylindre,c_diedre_etroit,c_quartm;
  float c_hel_d,c_hel_g;
  float tau, temp, norm, prod_scal_r, prod_scal_i;

/* Matrix arrays */
  float ***S_in;
  float **M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ncameron_decomposition.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-id  	input directory\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-iodf	input-output data format\n");
strcat(UsageHelp," (int)   	-ofr 	Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (string)	-col 	Colormap Cameron 8 colors\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-mask	mask file (valid pixels)\n");
strcat(UsageHelp," (int)   	-mem 	Allocated memory for blocksize determination (in Mb)\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/********************************************************************
********************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Input-Output Data Format\n\n");
for (ii=0; ii<NPolType; ii++) CreateUsageHelpDataFormatInput(PolTypeConf[ii]); 
strcat(UsageHelpDataFormat,"\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }
if(get_commandline_prm(argc,argv,"-data",no_cmd_prm,NULL,0,UsageHelpDataFormat)) {
  printf("\n Usage:\n%s\n",UsageHelpDataFormat); exit(1);
  }

if(argc < 17) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-id",str_cmd_prm,in_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iodf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-col",str_cmd_prm,ColorMapCameron,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1;
  get_commandline_prm(argc,argv,"-mem",int_cmd_prm,&MemoryAlloc,0,UsageHelp);
  MemoryAlloc = my_max(MemoryAlloc,1000);

  FlagValid = 0;strcpy(file_valid,"");
  get_commandline_prm(argc,argv,"-mask",str_cmd_prm,file_valid,0,UsageHelp);
  if (strcmp(file_valid,"") != 0) FlagValid = 1;

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);
  }

/********************************************************************
********************************************************************/

  check_dir(in_dir);
  check_dir(out_dir);
  if (FlagValid == 1) check_file(file_valid);

  NwinL = 1; NwinC = 1;
  NwinLM1S2 = (NwinL - 1) / 2;
  NwinCM1S2 = (NwinC - 1) / 2;

/* INPUT/OUPUT CONFIGURATIONS */
  read_config(in_dir, &Nlig, &Ncol, PolarCase, PolarType);
  
/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_in = matrix_char(NpolarIn,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeIn, in_dir, file_name_in);

/* INPUT FILE OPENING*/
  for (Np = 0; Np < NpolarIn; Np++)
  if ((in_datafile[Np] = fopen(file_name_in[Np], "rb")) == NULL)
    edit_error("Could not open input file : ", file_name_in[Np]);

  if (FlagValid == 1) 
    if ((in_valid = fopen(file_valid, "rb")) == NULL)
      edit_error("Could not open input file : ", file_valid);

/* OUTPUT FILE OPENING*/
  sprintf(file_name, "%s%s", out_dir, "Cameron.bin");
  if ((out_file = fopen(file_name, "wb")) == NULL)
  edit_error("Could not open output file : ", file_name);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;
  /* Mask */ 
  NBlockA += Sub_Ncol; NBlockB += 0;

  /* Mout = Nlig*Sub_Ncol */
  NBlockA += 0; NBlockB += Sub_Nlig*Sub_Ncol;
  /* Sin = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;

/* Reading Data */
  NBlockB += Ncol + 2*Ncol + NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, NwinL, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  _VC_in = vector_float(2*Ncol);
  _VF_in = vector_float(Ncol);
  _MC_in = matrix_float(4,2*Ncol);
  _MF_in = matrix3d_float(NpolarOut,NwinL, Ncol+NwinC);

/*-----------------------------------------------------------------*/   

  Valid = matrix_float(NligBlock[0], Sub_Ncol);

  S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  M_out = matrix_float(Sub_Nlig, Sub_Ncol);
  
/********************************************************************
********************************************************************/
/* MASK VALID PIXELS (if there is no MaskFile */
  if (FlagValid == 0) 
    for (lig = 0; lig < NligBlock[0]; lig++) 
      for (col = 0; col < Sub_Ncol; col++) 
        Valid[lig][col] = 1.;
 
/********************************************************************
********************************************************************/
/* DATA PROCESSING */
Nligg = 0; ligg = 0;

for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  if (FlagValid == 1) read_block_matrix_float(in_valid, Valid, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 1, 1, Off_lig, Off_col, Ncol);

  read_block_S2_noavg(in_datafile, S_in, PolTypeOut, NpolarOut, Nb, NbBlock, NligBlock[Nb], Sub_Ncol, 0, 0, Off_lig, Off_col, Ncol);

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    ligg = lig + Nligg;
    PrintfLine(lig,NligBlock[Nb]);
    for (col = 0; col < Sub_Ncol; col++) {
      if (Valid[lig][col] == 1.) {
        Shhr=S_in[s11][lig][2*col]; Shhi=S_in[s11][lig][2*col+1];
        Shvr=0.5*(S_in[s12][lig][2*col]+S_in[s21][lig][2*col]);
        Shvi=0.5*(S_in[s12][lig][2*col+1]+S_in[s21][lig][2*col+1]);
        Svvr=S_in[s22][lig][2*col]; Svvi=S_in[s22][lig][2*col+1];

        /*Cameron algorithm*/
        alphar=(Shhr+Svvr)/r2;alphai=(Shhi+Svvi)/r2;
        alpham2=alphar*alphar+alphai*alphai;
        betar=(Shhr-Svvr)/r2;betai=(Shhi-Svvi)/r2;
        betam2=betar*betar+betai*betai;
        gammar=r2*Shvr;gammai=r2*Shvi;
        gammam2=gammar*gammar+gammai*gammai;

        reelle=2*(betar*gammar+betai*gammai);
        diff_abs=betar*betar+betai*betai-gammar*gammar-gammai*gammai;

        if ((fabs(reelle) < (alpham2+betam2+gammam2)*eps) && (fabs(diff_abs) < (alpham2+betam2+gammam2)*eps)) {
          Xi=0;
          } else {
          sinXi=reelle/sqrt(reelle*reelle+diff_abs*diff_abs);
          cosXi=diff_abs/sqrt(reelle*reelle+diff_abs*diff_abs);
          if (cosXi>0) Xi=asin(sinXi);
          else Xi=pi-asin(sinXi);
          }
        epsilonr=1/r2*(cos(Xi/2)*(Shhr-Svvr)+sin(Xi/2)*2*Shvr);
        epsiloni=1/r2*(cos(Xi/2)*(Shhi-Svvi)+sin(Xi/2)*2*Shvi);

        SMhhr=1/r2*(alphar+cos(Xi/2)*epsilonr);
        SMhhi=1/r2*(alphai+cos(Xi/2)*epsiloni);
        SMvvr=1/r2*(alphar-cos(Xi/2)*epsilonr);
        SMvvi=1/r2*(alphai-cos(Xi/2)*epsiloni);
        SMhvr=1/r2*sin(Xi/2)*epsilonr;
        SMhvi=1/r2*sin(Xi/2)*epsiloni;
        Psimax=-Xi/4;

        norm = sqrt( (Shhr*Shhr+Shhi*Shhi) + 2*(Shvr*Shvr+Shvi*Shvi) + (Svvr*Svvr+Svvi*Svvi) ); // norm de S
        norm *= sqrt( (SMhhr*SMhhr+SMhhi*SMhhi) + 2*(SMhvr*SMhvr+SMhvi*SMhvi) + (SMvvr*SMvvr+SMvvi*SMvvi) );

        prod_scal_r = (Shhr*SMhhr+Shhi*SMhhi) +  2*(Shvr*SMhvr+Shvi*SMhvi) + (Svvr*SMvvr+Svvi*SMvvi);
        prod_scal_i = (Shhr*SMhhi-Shhi*SMhhr) +  2*(Shvr*SMhvi-Shvi*SMhvr) + (Svvr*SMvvi-Svvi*SMvvr);

        tau = acos( sqrt( prod_scal_r*prod_scal_r + prod_scal_i*prod_scal_i ) / norm );

        if (tau < pi/8)  {
          SsM1r=cos(Psimax)*cos(Psimax)*SMhhr-sin(2*Psimax)*Shvr+sin(Psimax)*sin(Psimax)*SMvvr;
          SsM1i=cos(Psimax)*cos(Psimax)*SMhhi-sin(2*Psimax)*Shvi+sin(Psimax)*sin(Psimax)*SMvvi;
          SsM2r=sin(Psimax)*sin(Psimax)*SMhhr+sin(2*Psimax)*Shvr+cos(Psimax)*cos(Psimax)*SMvvr;
          SsM2i=sin(Psimax)*sin(Psimax)*SMhhi+sin(2*Psimax)*Shvi+cos(Psimax)*cos(Psimax)*SMvvi;

          mod2_SsM1=SsM1r*SsM1r+SsM1i*SsM1i;
          mod2_SsM2=SsM2r*SsM2r+SsM2i*SsM2i;
          if ( mod2_SsM1 >= mod2_SsM2 ) {
            z_SsMr=(SsM2r*SsM1r+SsM2i*SsM1i)/mod2_SsM1;
            z_SsMi=(SsM2i*SsM1r-SsM2r*SsM1i)/mod2_SsM1;
            } else {
            z_SsMr=(SsM1r*SsM2r+SsM1i*SsM2i)/mod2_SsM2;
            z_SsMi=(SsM1i*SsM2r-SsM1r*SsM2i)/mod2_SsM2;
            Psimax+=pi/2;
            }
          Psimax=fmod(Psimax,2*pi);

          mod2_z_SsM=z_SsMr*z_SsMr+z_SsMi*z_SsMi;

          c_plan=sqrt((1.+z_SsMr)*(1.+z_SsMr)+z_SsMi*z_SsMi)/sqrt(2.*(1.+mod2_z_SsM));
          c_diedre=sqrt((1.-z_SsMr)*(1.-z_SsMr)+z_SsMi*z_SsMi)/sqrt(2.*(1.+mod2_z_SsM));
          c_dipole=1/sqrt(1.+mod2_z_SsM);
          c_cylindre=sqrt((1.-z_SsMr/2.)*(1.-z_SsMr/2.)+z_SsMi*z_SsMi/4.)/sqrt(5./4.*(1.+mod2_z_SsM));
          c_diedre_etroit=sqrt((1.+z_SsMr/2.)*(1.+z_SsMr/2.)+z_SsMi*z_SsMi/4.)/sqrt(5./4.*(1.+mod2_z_SsM));
          c_quartp=sqrt((1.+z_SsMi)*(1.+z_SsMi)+z_SsMr*z_SsMr)/sqrt(2.*(1.+mod2_z_SsM));
          c_quartm=sqrt((1.-z_SsMi)*(1.-z_SsMi)+z_SsMr*z_SsMr)/sqrt(2.*(1.+mod2_z_SsM));

          M_out[ligg][col]=1;
          temp=c_plan;
          if (c_diedre>temp) {M_out[ligg][col]=2; temp=c_diedre;}
          if (c_dipole>temp) {M_out[ligg][col]=3; temp=c_dipole;}
          if (c_cylindre>temp) {M_out[ligg][col]=4; temp=c_cylindre;}
          if (c_diedre_etroit>temp) {M_out[ligg][col]=5; temp=c_diedre_etroit;}
          if ( (c_quartp>temp) || (c_quartm>temp) ) M_out[ligg][col]=6;

          } else {

          norm = sqrt( (Shhr*Shhr+Shhi*Shhi) + 2*(Shvr*Shvr+Shvi*Shvi) + (Svvr*Svvr+Svvi*Svvi) );
    
          prod_scal_r = Shhr +  2*Shvi - Svvr;
          prod_scal_i = -Shhi +  2*Shvr -Svvi;
          c_hel_g = sqrt( prod_scal_r*prod_scal_r + prod_scal_i*prod_scal_i ) / (2*norm);
      
          prod_scal_r = Shhr -  2*Shvi - Svvr;
          prod_scal_i = -Shhi -  2*Shvr -Svvi;
          c_hel_d = sqrt( prod_scal_r*prod_scal_r + prod_scal_i*prod_scal_i ) / (2*norm);
  
          if (c_hel_g>c_hel_d) M_out[ligg][col]=7;
          else M_out[ligg][col]=8;
          }
        } else {
        M_out[ligg][col]=0;
        }
      }
    }

  Nligg += NligBlock[Nb];

  } // NbBlock

  write_block_matrix_float(out_file, M_out, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

/********************************************************************
********************************************************************/

  sprintf(file_name, "%s%s", out_dir, "Cameron");
  bmp_training_set(M_out, Sub_Nlig, Sub_Ncol, file_name, ColorMapCameron);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */
/*
  free_matrix_float(Valid, NligBlock[0]);

  free_matrix3d_float(S_in, NpolarOut, NligBlock[0]);
  free_matrix_float(M_out, NligBlock[0]);
*/  
/********************************************************************
********************************************************************/
/* INPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarIn; Np++) fclose(in_datafile[Np]);
  if (FlagValid == 1) fclose(in_valid);

/* OUTPUT FILE CLOSING*/
  fclose(out_file);
  
/********************************************************************
********************************************************************/

  return 1;
}


