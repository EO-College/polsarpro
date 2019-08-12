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

File   : radarsat2_convert_dual.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 05/2011
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

Description :  Convert RADARSAT-2  Binary Data Files 
               (GEOTIFF Format)

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

/* CONSTANTS  */

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void read_tiff_strip(char FileInput[FilePathLength]);

/* GLOBAL VARIABLES */
int Rstrip;

/* GLOBAL ARRAYS */
int *Strip_Bytes;
int *Strip_Offset;
float *LutArray;

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/
int main(int argc, char *argv[])
{

#define Npol 2
#define NPolType 3
/* LOCAL VARIABLES */
  FILE *in_file[Npol], *in_lut;
  int Config;
  char *PolTypeConf[NPolType] = {"SPP", "SPPC2", "SPPIPP"};
  char File11[FilePathLength],File12[FilePathLength];
  char LutFile[FilePathLength], PolarPP[20];
  
/* Internal variables */
  int ii, lig, col, k, l;
  int indlig, indcol;
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
 
  int IEEE, Strip;
  int NNb, NNlig;

  char *pc;
  short int fl1, fl2;
  short int *v;
  long int PointerPosition;

  int NligBlockFinal;

/* Matrix arrays */
  short int **Min;
  float ***S_in;
  float ***M_in;
  float ***M_out;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nradarsat2_convert_dual.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if1 	input data file: s11.bin\n");
strcat(UsageHelp," (string)	-if2 	input data file: s12.bin\n");
strcat(UsageHelp," (string)	-od  	output directory\n");
strcat(UsageHelp," (string)	-odf 	output data format\n");
strcat(UsageHelp," (int)   	-nr  	Number of Row\n");
strcat(UsageHelp," (int)   	-nc  	Number of Col\n");
strcat(UsageHelp," (int)   	-ofr 	 Offset Row\n");
strcat(UsageHelp," (int)   	-ofc 	Offset Col\n");
strcat(UsageHelp," (int)   	-fnr 	Final Number of Row\n");
strcat(UsageHelp," (int)   	-fnc 	Final Number of Col\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-iee 	IEEE data convert (no: 0, yes: 1)\n");
strcat(UsageHelp," (string)	-pp  	polar type (pp1, pp2, pp3)\n");
strcat(UsageHelp," (string)	-lut 	Lut file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (string)	-errf	memory error file\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");
strcat(UsageHelp," (noarg) 	-data	displays the help concerning Data Format parameter\n");

/*******************************************************************/

strcpy(UsageHelpDataFormat,"\nPolarimetric Output Data Format\n");
strcat(UsageHelpDataFormat," SPP    	output : dual-pol SPP\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," SPPC2  	output : covariance C2\n");
strcat(UsageHelpDataFormat,"\n");
strcat(UsageHelpDataFormat," SPPIPP 	output : intensities IPP\n");
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

if(argc < 35) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if1",str_cmd_prm,File11,1,UsageHelp);
  get_commandline_prm(argc,argv,"-if2",str_cmd_prm,File12,1,UsageHelp);
  get_commandline_prm(argc,argv,"-od",str_cmd_prm,out_dir,1,UsageHelp);
  get_commandline_prm(argc,argv,"-odf",str_cmd_prm,PolType,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nr",int_cmd_prm,&Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nc",int_cmd_prm,&Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofr",int_cmd_prm,&Off_lig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ofc",int_cmd_prm,&Off_col,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnr",int_cmd_prm,&Sub_Nlig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-fnc",int_cmd_prm,&Sub_Ncol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlr",int_cmd_prm,&NLookLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlc",int_cmd_prm,&NLookCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssr",int_cmd_prm,&SubSampLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssc",int_cmd_prm,&SubSampCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-iee",int_cmd_prm,&IEEE,1,UsageHelp);
  get_commandline_prm(argc,argv,"-pp",str_cmd_prm,PolarPP,1,UsageHelp);
  get_commandline_prm(argc,argv,"-lut",str_cmd_prm,LutFile,1,UsageHelp);

  get_commandline_prm(argc,argv,"-errf",str_cmd_prm,file_memerr,0,UsageHelp);

  MemoryAlloc = -1; MemoryAlloc = CheckFreeMemory();
  MemoryAlloc = my_max(MemoryAlloc,1000);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

  Config = 0;
  for (ii=0; ii<NPolType; ii++) if (strcmp(PolTypeConf[ii],PolType) == 0) Config = 1;
  if (Config == 0) edit_error("\nWrong argument in the Polarimetric Data Format\n",UsageHelpDataFormat);

  if (NLookLig == 0) edit_error("\nWrong argument in the Nlook Row parameter\n",UsageHelp);
  if (NLookCol == 0) edit_error("\nWrong argument in the Nlook Col parameter\n",UsageHelp);
  if (SubSampLig == 0) edit_error("\nWrong argument in the Sub Sampling Row parameter\n",UsageHelp);
  if (SubSampCol == 0) edit_error("\nWrong argument in the Sub Sampling Col parameter\n",UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(File11);
  check_file(File12);
  check_dir(out_dir);
  check_file(LutFile);

  if (strcmp(PolarPP, "PP1") == 0) strcpy(PolarType, "pp1");
  if (strcmp(PolarPP, "pp1") == 0) strcpy(PolarType, "pp1");
  if (strcmp(PolarPP, "PP2") == 0) strcpy(PolarType, "pp2");
  if (strcmp(PolarPP, "pp2") == 0) strcpy(PolarType, "pp2");
  if (strcmp(PolarPP, "PP3") == 0) strcpy(PolarType, "pp3");
  if (strcmp(PolarPP, "pp3") == 0) strcpy(PolarType, "pp3");

  NwinL = 1; NwinC = 1;

/* POLAR TYPE CONFIGURATION */
  PolTypeConfig(PolType, &NpolarIn, PolTypeIn, &NpolarOut, PolTypeOut, PolarType);
  
  file_name_out = matrix_char(NpolarOut,1024); 

/* INPUT/OUTPUT FILE CONFIGURATION */
  init_file_name(PolTypeOut, out_dir, file_name_out);

/* DATA FILES */
  if ((in_file[0] = fopen(File11, "rb")) == NULL)
    edit_error("Could not open input file : ", File11);
  if ((in_file[1] = fopen(File12, "rb")) == NULL)
    edit_error("Could not open input file : ", File12);

  LutArray = vector_float(Ncol);
  if ((in_lut = fopen(LutFile, "rb")) == NULL)
    edit_error("Could not open input file : ", LutFile);
  fread(&LutArray[0], sizeof(float), Ncol, in_lut);
  fclose(in_lut);

/* OUTPUT FILE OPENING*/
  for (Np = 0; Np < NpolarOut; Np++)
    if ((out_datafile[Np] = fopen(file_name_out[Np], "wb")) == NULL)
      edit_error("Could not open input file : ", file_name_out[Np]);
  
/********************************************************************
********************************************************************/
/* MEMORY ALLOCATION */
/*
MemAlloc = NBlockA*Nlig + NBlockB
*/ 

/* Local Variables */
  NBlockA = 0; NBlockB = 0;

  if ((strcmp(PolTypeOut,"SPPpp1")==0) || (strcmp(PolTypeOut,"SPPpp2")==0) ||(strcmp(PolTypeOut,"SPPpp3")==0)){
    /* Mout = NpolarOut*Nlig*2*Sub_Ncol */
    NBlockA += NpolarOut*2*Sub_Ncol; NBlockB += 0;
    } else {
    /* Mout = NpolarOut*Nlig*Sub_Ncol */
    NBlockA += NpolarOut*Sub_Ncol; NBlockB += 0;
    /* Min = NpolarOut*Nlig*Ncol */
    NBlockA += NpolarOut*Ncol; NBlockB += 0;
    }    
  /* Sin = NpolarIn*Nlig*2*Ncol */
  NBlockA += NpolarIn*2*Ncol; NBlockB += 0;
  /* Min = Npol*Ncol */
  NBlockB += Npol*Ncol;
  
/* Reading Data */
  NBlockB += NpolarIn*2*Ncol + NpolarOut*NwinL*(Ncol+NwinC);

  memory_alloc(file_memerr, Sub_Nlig, 0, &NbBlock, NligBlock, NBlockA, NBlockB, MemoryAlloc);

  if (NbBlock != 1) block_alloc(NligBlock, SubSampLig, NLookLig, Sub_Nlig, &NbBlock);

/********************************************************************
********************************************************************/
/* MATRIX ALLOCATION */

  Min = matrix_short_int(Npol, 2*Ncol);
  S_in = matrix3d_float(NpolarIn, NligBlock[0], 2*Ncol);
  if ((strcmp(PolTypeOut,"SPPpp1")==0) || (strcmp(PolTypeOut,"SPPpp2")==0) ||(strcmp(PolTypeOut,"SPPpp3")==0)){
    M_out = matrix3d_float(NpolarOut, NligBlock[0], 2*Sub_Ncol);
    } else {
    M_in = matrix3d_float(NpolarOut, NligBlock[0], Ncol);
    M_out = matrix3d_float(NpolarOut, NligBlock[0], Sub_Ncol);
    }    
  
/********************************************************************
********************************************************************/

/* READ TIFF HEADER */
  
  read_tiff_strip(File11);

/********************************************************************
********************************************************************/
/* DATA PROCESSING */

  Sub_Nlig = (int) floor((Sub_Nlig / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((Sub_Ncol / SubSampCol) / NLookCol);

/* SKIP HEADER */
  for (Np = 0; Np < Npol; Np++) fseek(in_file[Np], Strip_Offset[0], SEEK_SET);
  Strip = 1;

  /* Offset Lines Reading */
  for (lig = 0; lig < Off_lig; lig++) {
    for (Np = 0; Np < Npol; Np++) 
      fread(&Min[Np][0], sizeof(short int), 2 * Ncol, in_file[Np]);
    if (fmod(lig+1,Rstrip) == 0) {
      PointerPosition = Strip_Offset[Strip]; Strip++;
      for (Np = 0; Np < Npol; Np++) my_fseek_position(in_file[Np], PointerPosition);
      }
    }
  
for (Nb = 0; Nb < NbBlock; Nb++) {

  if (NbBlock > 2) {printf("%f\r", 100. * Nb / (NbBlock - 1));fflush(stdout);}

  for (lig = 0; lig < NligBlock[Nb]; lig++) {
    PrintfLine(lig,NligBlock[Nb]);
    for (Np = 0; Np < Npol; Np++) {
      if (IEEE == 0)
        fread(&Min[Np][0], sizeof(short int), 2 * Ncol, in_file[Np]);
      if (IEEE == 1) {
        for (col = 0; col < Ncol; col++) {
          v = &fl1;pc = (char *) v;
          pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
          v = &fl2;pc = (char *) v;
          pc[1] = getc(in_file[Np]);pc[0] = getc(in_file[Np]);
          Min[Np][2*col] = fl1; Min[Np][2*col+1] = fl2;
          }
        }
      }
    for (col = 0; col < Ncol; col++) {
      for (Np = 0; Np < Npol; Np++) {
        S_in[Np][lig][2*col] = (float)Min[Np][2*col] / LutArray[col];
        S_in[Np][lig][2*col+1] = (float)Min[Np][2*col+1] / LutArray[col];
        if (my_isfinite(S_in[Np][lig][2*col]) == 0) S_in[Np][lig][2*col] = eps;
        if (my_isfinite(S_in[Np][lig][2*col + 1]) == 0) S_in[Np][lig][2*col + 1] = eps;
        }
      }

    NNlig = 0;
    for (NNb = 0; NNb < Nb; NNb++) NNlig += NligBlock[NNb];
    NNlig += lig+1+Off_lig;
    if (fmod(NNlig,Rstrip) == 0) {
      PointerPosition = Strip_Offset[Strip]; Strip++;
      for (Np = 0; Np < Npol; Np++) my_fseek_position(in_file[Np], PointerPosition);
      }
    }

  if ((strcmp(PolTypeOut,"SPPpp1")==0) || (strcmp(PolTypeOut,"SPPpp2")==0) ||(strcmp(PolTypeOut,"SPPpp3")==0)){
    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig));
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol;
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][2*col] = S_in[Np][indlig][2*(indcol+Off_col)];
          M_out[Np][lig][2*col+1] = S_in[Np][indlig][2*(indcol+Off_col)+1];
          }
        }
      }

    write_block_matrix3d_cmplx(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);
  
    } else {

    if ((strcmp(PolTypeOut,"C2pp1")==0) || (strcmp(PolTypeOut,"C2pp2")==0) ||(strcmp(PolTypeOut,"C2pp3")==0)) 
      SPP_to_C2(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);
    else SPP_to_IPP(S_in, M_in, NligBlock[Nb], Ncol, 0, 0);

    NligBlockFinal = (int) floor(NligBlock[Nb]/ (SubSampLig*NLookLig));
    for (lig = 0; lig < NligBlockFinal; lig++) {
      if (NbBlock <= 2) PrintfLine(lig,NligBlockFinal);
      indlig = lig * SubSampLig * NLookLig;
      for (col = 0; col < Sub_Ncol; col++) {
        indcol = col * SubSampCol * NLookCol;
        for (Np = 0; Np < NpolarOut; Np++) {
          M_out[Np][lig][col] = 0.;
          for (k = 0; k < NLookLig; k++)
            for (l = 0; l < NLookCol; l++)
              M_out[Np][lig][col] += M_in[Np][indlig+k][indcol+l+Off_col];
          M_out[Np][lig][col] /= (NLookLig*NLookCol);
          }
        }
      }
      
    write_block_matrix3d_float(out_datafile, NpolarOut, M_out, NligBlockFinal, Sub_Ncol, 0, 0, Sub_Ncol);

    }
  
  } // NbBlock

/* OUPUT CONFIGURATIONS */
  strcpy(PolarCase, "monostatic");
  if (strcmp(PolTypeOut,"IPPpp5")==0) strcpy(PolarCase, "intensities"); 
  if (strcmp(PolTypeOut,"IPPpp6")==0) strcpy(PolarCase, "intensities"); 
  if (strcmp(PolTypeOut,"IPPpp7")==0) strcpy(PolarCase, "intensities"); 
  write_config(out_dir, Sub_Nlig, Sub_Ncol, PolarCase, PolarType);

/********************************************************************
********************************************************************/
/* MATRIX FREE-ALLOCATION */

  free_matrix_short_int(Min, Npol);
  free_matrix3d_float(S_in, NpolarIn, NligBlock[0]);
  if ((strcmp(PolTypeOut,"SPPpp1")!=0) && (strcmp(PolTypeOut,"SPPpp2")!=0) && (strcmp(PolTypeOut,"SPPpp3")!=0)) free_matrix3d_float(M_in, NpolarOut, NligBlock[0]);
  free_matrix3d_float(M_out, NpolarOut, NligBlock[0]);
  
/********************************************************************
********************************************************************/

/* OUTPUT FILE CLOSING*/
  for (Np = 0; Np < NpolarOut; Np++) fclose(out_datafile[Np]);
  for (Np = 0; Np < Npol; Np++) fclose(in_file[Np]);
  
/********************************************************************
********************************************************************/

  return 1;
}

/********************************************************************
*********************************************************************
*********************************************************************
********************************************************************/

void read_tiff_strip (char FileInput[FilePathLength])
{
  FILE *fileinput;

  unsigned char buffer[4];
  int i, k;
  long unsigned int offset;
  long unsigned int offset_strip;
  long unsigned int offset_strip_byte;
  short unsigned int Ndir, Flag, Type;
  int Nlg, Nstrip, Count, Value, IEEEFormat;

  char *pc;
  int il;
  int *vl;
  short int is;
  short int *v;

  if ((fileinput = fopen(FileInput, "rb")) == NULL)
  edit_error("Could not open input file : ", FileInput);

  rewind(fileinput);
/* Tiff File Header */

  /* Little / Big endian & TIFF identifier */
  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) IEEEFormat = 0;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) IEEEFormat = 1;
  
  if (IEEEFormat == 0) fread(&offset, sizeof(int), 1, fileinput);
  if (IEEEFormat == 1) {
    vl = &il;pc = (char *) vl;
    pc[3] = getc(fileinput);pc[2] = getc(fileinput);
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    offset = il;
  }

  rewind(fileinput);
  fseek(fileinput, offset, SEEK_SET);

  if (IEEEFormat == 0) fread(&Ndir, sizeof(short int), 1, fileinput);
  if (IEEEFormat == 1) {
    v = &is;pc = (char *) v;
    pc[1] = getc(fileinput);pc[0] = getc(fileinput);
    Ndir = is;
  }

  for (i=0; i<Ndir; i++) {
    Flag = 0; Type = 0; Count = 0; Value = 0;
    if (IEEEFormat == 0) {
      fread(&Flag, sizeof(short int), 1, fileinput);
      fread(&Type, sizeof(short int), 1, fileinput);
      fread(&Count, sizeof(int), 1, fileinput);
      if (Type == 3) {
        fread(&Value, sizeof(short int), 1, fileinput);
        fread(&k, sizeof(short int), 1, fileinput);
      }
      if (Type == 4) fread(&Value, sizeof(int), 1, fileinput);
      if ((Type != 3) && (Type != 4)) fread(&Value, sizeof(int), 1, fileinput);
    }
    if (IEEEFormat == 1) {
      v = &is;pc = (char *) v;
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Flag = is;
      v = &is;pc = (char *) v;
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Type = is;
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Count = il;
      if (Type == 3) {
        v = &is;pc = (char *) v;
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        Value = is;
        fread(&k, sizeof(short int), 1, fileinput);
      }
      if (Type == 4) {
        vl = &il;pc = (char *) vl;
        pc[3] = getc(fileinput);pc[2] = getc(fileinput);
        pc[1] = getc(fileinput);pc[0] = getc(fileinput);
        Value = il;
      }
      if ((Type != 3) && (Type != 4)) fread(&Value, sizeof(int), 1, fileinput);
    }
    if (Flag == 257) Nlg = Value;

    if (Flag == 273) Nstrip = Count;
    if (Flag == 278) Rstrip = Value;

    if (Flag == 273) offset_strip = Value;
    if (Flag == 279) offset_strip_byte = Value;
    }

  Strip_Offset = vector_int(Nlg);
  Strip_Bytes = vector_int(Nlg);

  rewind(fileinput);
  fseek(fileinput, offset_strip, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEEFormat == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEEFormat == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Offset[i] = Value;
  }

  rewind(fileinput);
  fseek(fileinput, offset_strip_byte, SEEK_SET);
  for (i=0; i<Nstrip; i++) {
    if (IEEEFormat == 0) fread(&Value, sizeof(int), 1, fileinput);
    if (IEEEFormat == 1) {
      vl = &il;pc = (char *) vl;
      pc[3] = getc(fileinput);pc[2] = getc(fileinput);
      pc[1] = getc(fileinput);pc[0] = getc(fileinput);
      Value = il;
    }
    Strip_Bytes[i] = Value;
  }

  fclose(fileinput);
}



