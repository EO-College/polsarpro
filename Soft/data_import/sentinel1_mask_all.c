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

File     : sentinel1_mask_all.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 09/2014
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

Description :  extract information from Sentinel1 header file
               create mask file in case of all bursts

********************************************************************/

/* C INCLUDES */
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
void reverse(char *str, int len);
int intToStr(int x, char str[], int d);
void ftoa(float n, char *res, int afterpoint);

/********************************************************************
*********************************************************************
*
*            -- Function : Main
*
*********************************************************************
********************************************************************/

int main(int argc, char *argv[])
/*                                                                            */
{

/* LOCAL VARIABLES */
  FILE *ftmp, *fmask;
  char FileTmp[FilePathLength], FileMask[FilePathLength];
  char Buf[65536];
  char Tmp[65536];
  char *p1;

  int ii, jj;
  int FlagSwath, linesPerBurst;
//int samplesPerBurst;
  int numberOfLines, numberOfSamples;
  int burstNum, burstList;
  int OffLig1, OffLig2, OffCol1, OffCol2;
  int Length, NLig1, NLig2;
  int FlagM1;
  char OffColChar[100];
  float **MaskIn;
  float **MaskOut;
  int NligInit, NligFin, NcolInit, NcolFin; 
  
  int SubSampLig, SubSampCol;
  int NLookLig, NLookCol;
  int indlig, indcol;
  int k, l;

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsentinel1_mask_all.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input header file\n");
strcat(UsageHelp," (string)	-of  	output mask file\n");
strcat(UsageHelp," (int)   	-nlr 	Nlook Row (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-nlc 	Nlook Col (1 = no multi-looking)\n");
strcat(UsageHelp," (int)   	-ssr 	Sub-sampling Row (1 = no subsampling)\n");
strcat(UsageHelp," (int)   	-ssc 	Sub-sampling Col (1 = no subsampling)\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 13) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileTmp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileMask,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlr",int_cmd_prm,&NLookLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-nlc",int_cmd_prm,&NLookCol,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssr",int_cmd_prm,&SubSampLig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-ssc",int_cmd_prm,&SubSampCol,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileTmp);
  check_file(FileMask);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);

  if ((fmask = fopen(FileMask, "wb")) == NULL)
    edit_error("Could not open configuration file : ", FileMask);
    
/*******************************************************************/
/*******************************************************************/
  
  rewind(ftmp);
  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 
    if (strstr(Buf,"numberOfSamples") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      numberOfSamples = atoi(Tmp);
      }
    if (strstr(Buf,"numberOfLines") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      numberOfLines = atoi(Tmp);
      }
    if (strstr(Buf,"burstList") != NULL) {
      p1 = strstr(Buf,": ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[2], strlen(p1) - 3);      
      burstList = atoi(Tmp);
      }
    }
  MaskIn = matrix_float(numberOfLines,numberOfSamples);
  for (ii = 0; ii < numberOfLines; ii++)
    for (jj = 0; jj < numberOfSamples; jj++) MaskIn[ii][jj] = 0.;

  FlagSwath = 0;  
  rewind(ftmp);
  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 

    if (FlagSwath == 1) {
      if (strstr(Buf,"linesPerBurst") != NULL) {
        p1 = strstr(Buf,".: ");
        strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
        linesPerBurst = atoi(Tmp);
        }
//      if (strstr(Buf,"samplesPerBurst") != NULL) {
//        p1 = strstr(Buf,".: ");
//        strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
//        samplesPerBurst = atoi(Tmp);
//        }    
      if (strstr(Buf,"burstList") != NULL) {
        for (burstNum = 0; burstNum < burstList; burstNum++) {
          printf("%f\r", 100. * burstNum / (burstList - 1));fflush(stdout);      
          fgets(&Buf[0], 1024, ftmp); //burst
          fgets(&Buf[0], 1024, ftmp); //azimuthTime
          fgets(&Buf[0], 1024, ftmp); //azimuthAnxTime
          fgets(&Buf[0], 1024, ftmp); //sensingTime
          fgets(&Buf[0], 1024, ftmp); //byteOffset
          fgets(&Buf[0], 65536, ftmp); //firstValidSample 
          p1 = strstr(Buf,".: ");
          strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
          OffLig1 = 0;
          FlagM1 = 0;
          while (FlagM1 == 0) {
            strcpy(Buf,""); strncat(Buf, &Tmp[3*OffLig1],3);
            if (strcmp(Buf,"-1 ") == 0) OffLig1++;
            else FlagM1 = 1;
            }
          strcpy(Tmp, ""); strncat(Tmp, &p1[3+3*OffLig1], strlen(p1) - 3 - 3*OffLig1);
          sscanf(Tmp,"%i",&OffCol1);
          NLig1 = 0;
          FlagM1 = 0;
//          itoa(OffCol1,OffColChar,10); strcat(OffColChar," ");
          sprintf(OffColChar,"%d",OffCol1); strcat(OffColChar," ");
          Length = strlen(OffColChar);
          while (FlagM1 == 0) {
            strcpy(Buf,""); strncat(Buf, &Tmp[Length*NLig1],Length);
            if (strcmp(Buf,OffColChar) == 0) NLig1++;
            else FlagM1 = 1;
            }

          fgets(&Buf[0], 16536, ftmp); //lastValidSample 
          p1 = strstr(Buf,".: ");
          strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
          OffLig2 = 0;
          FlagM1 = 0;
          while (FlagM1 == 0) {
            strcpy(Buf,""); strncat(Buf, &Tmp[3*OffLig2],3);
            if (strcmp(Buf,"-1 ") == 0) OffLig2++;
            else FlagM1 = 1;
            }
          strcpy(Tmp, ""); strncat(Tmp, &p1[3+3*OffLig2], strlen(p1) - 3 - 3*OffLig2);
          sscanf(Tmp,"%i",&OffCol2);
          NLig2 = 0;
          FlagM1 = 0;
//          itoa(OffCol2,OffColChar,10); strcat(OffColChar," ");
          sprintf(OffColChar,"%d",OffCol2); strcat(OffColChar," ");
          Length = strlen(OffColChar);
          while (FlagM1 == 0) {
            strcpy(Buf,""); strncat(Buf, &Tmp[Length*NLig2],Length);
            if (strcmp(Buf,OffColChar) == 0) NLig2++;
            else FlagM1 = 1;
            }

          NligInit = burstNum*linesPerBurst + (OffLig1+OffLig2)/2;
          NligFin = burstNum*linesPerBurst + ((OffLig1+OffLig2)/2)+((NLig1+NLig2)/2)-1;
          NcolInit = OffCol1;
          NcolFin = OffCol2;
          for (ii = NligInit; ii < NligFin+1; ii++)
            for (jj = NcolInit; jj < NcolFin+1; jj++)
              MaskIn[ii][jj] = 1.;
          }
        }
      }
    if (strstr(Buf,"swathTiming") != NULL) FlagSwath = 1; 
    }    
    
  fclose(ftmp);
    
/*******************************************************************/
/*******************************************************************/

  Sub_Nlig = (int) floor((numberOfLines / SubSampLig) / NLookLig);
  Sub_Ncol = (int) floor((numberOfSamples / SubSampCol) / NLookCol);
  
  MaskOut = matrix_float(Sub_Nlig,Sub_Ncol);

  for (ii = 0; ii < Sub_Nlig; ii++) {
    indlig = ii * SubSampLig * NLookLig;
    for (jj = 0; jj < Sub_Ncol; jj++) {
      indcol = jj * SubSampCol * NLookCol;
      MaskOut[ii][jj] = 0.;
      for (k = 0; k < NLookLig; k++)
        for (l = 0; l < NLookCol; l++) 
          MaskOut[ii][jj] += MaskIn[indlig+k][indcol+l];
      MaskOut[ii][jj] /= (NLookLig*NLookCol);
      if (MaskOut[ii][jj] != 0.) MaskOut[ii][jj] = 1.;
      }
    }

  write_block_matrix_float(fmask, MaskOut, Sub_Nlig, Sub_Ncol, 0, 0, Sub_Ncol);

  fclose(fmask);
   
  return 1;
}
 
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
/*******************************************************************/
 // reverses a string 'str' of length 'len'
void reverse(char *str, int len)
{
    int i=0, j=len-1, temp;
    while (i<j)
    {
        temp = str[i];
        str[i] = str[j];
        str[j] = temp;
        i++; j--;
    }
}
 
 // Converts a given integer x to string str[].  d is the number
 // of digits required in output. If d is more than the number
 // of digits in x, then 0s are added at the beginning.
int intToStr(int x, char str[], int d)
{
    int i = 0;
    while (x)
    {
        str[i++] = (x%10) + '0';
        x = x/10;
    }
 
    // If number of digits required is more, then
    // add 0s at the beginning
    while (i < d)
        str[i++] = '0';
 
    reverse(str, i);
    str[i] = '\0';
    return i;
}
 
// Converts a floating point number to string.
void ftoa(float n, char *res, int afterpoint)
{
    // Extract integer part
    int ipart = (int)n;
 
    // Extract floating part
    float fpart = n - (float)ipart;
 
    // convert integer part to string
    int i = intToStr(ipart, res, 0);
 
    // check for display option after point
    if (afterpoint != 0)
    {
        res[i] = '.';  // add dot
 
        // Get the value of fraction part upto given no.
        // of points after dot. The third parameter is needed
        // to handle cases like 233.007
        fpart = fpart * pow(10, afterpoint);
 
        intToStr((int)fpart, res + i + 1, afterpoint);
    }
}