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

File     : sentinel1_header.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 1.0
Creation : 09/2014
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

Description :  extract information from Sentinel1 header file

********************************************************************/
/* C INCLUDES */
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
  FILE *ftmp, *fconfig;
  char FileTmp[FilePathLength], FileConfig[FilePathLength];
  char Buf[65536];
  char Tmp[65536];
  char *p1;

  int ii, FlagSwath, linesPerBurst;
//int samplesPerBurst;
  int numberOfLines, numberOfSamples;
  int BurstNum;
//int BurstNumMax;
  int OffLig1, OffLig2, OffCol1, OffCol2;
  int Length, NLig1, NLig2;
  int FlagM1;
  char OffColChar[100];

/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\nsentinel1_header.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if  	input header file\n");
strcat(UsageHelp," (string)	-of  	output config file\n");
strcat(UsageHelp," (int)   	-bn  	burst number\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 7) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileTmp,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileConfig,1,UsageHelp);
  get_commandline_prm(argc,argv,"-bn",int_cmd_prm,&BurstNum,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileTmp);
  check_file(FileConfig);

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/*******************************************************************/
/*******************************************************************/

  if ((ftmp = fopen(FileTmp, "r")) == NULL)
    edit_error("Could not open input file : ", FileTmp);

  if ((fconfig = fopen(FileConfig, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileConfig);
    
/*******************************************************************/
/*******************************************************************/
  
  rewind(ftmp);
  while( !feof(ftmp) ) {
    fgets(&Buf[0], 1024, ftmp); 
    if (strstr(Buf,"productInformation") != NULL) {
      fgets(&Buf[0], 1024, ftmp); 
      if (strstr(Buf,"pass") != NULL) {
        p1 = strstr(Buf,".: ");
        strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 4); 
        if (strcmp(Tmp,"Ascending") == 0) fprintf(fconfig,"Asc\n");
        else fprintf(fconfig,"Des\n");
        }
      }
    if (strstr(Buf,"rangePixelSpacing") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3); 
      ftoa(atof(Tmp),Tmp,2);      
      fprintf(fconfig,"%s\n",Tmp);
      }
    if (strstr(Buf,"azimuthPixelSpacing") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      ftoa(atof(Tmp),Tmp,2);      
      fprintf(fconfig,"%s\n",Tmp);
      }
    if (strstr(Buf,"numberOfSamples") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      fprintf(fconfig,"%s",Tmp);
      numberOfSamples = atoi(Tmp);
      }
    if (strstr(Buf,"numberOfLines") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      fprintf(fconfig,"%s",Tmp);
      numberOfLines = atoi(Tmp);
      }
    if (strstr(Buf,"incidenceAngleMidSwath") != NULL) {
      p1 = strstr(Buf,".: ");
      strcpy(Tmp, ""); strncat(Tmp, &p1[3], strlen(p1) - 3);      
      ftoa(atof(Tmp),Tmp,2);      
      fprintf(fconfig,"%s\n",Tmp);
      }
    }

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
//        BurstNumMax = numberOfLines / linesPerBurst;
//        }    
      if (strstr(Buf,"burstList") != NULL) {
        if (BurstNum != 0) {
          for (ii = 1; ii < BurstNum; ii++) {
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp);
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 1024, ftmp); 
            fgets(&Buf[0], 1024, ftmp); fgets(&Buf[0], 65536, ftmp);
            fgets(&Buf[0], 65536, ftmp); 
            }
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

          fgets(&Buf[0], 65536, ftmp); //lastValidSample 
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
          fprintf(fconfig,"%i\n",(BurstNum-1)*linesPerBurst + (OffLig1+OffLig2)/2);        
          fprintf(fconfig,"%i\n",(BurstNum-1)*linesPerBurst + ((OffLig1+OffLig2)/2)+((NLig1+NLig2)/2)-1);        
          fprintf(fconfig,"%i\n",((NLig1+NLig2)/2));        
          fprintf(fconfig,"%i\n",OffCol1);        
          fprintf(fconfig,"%i\n",OffCol2);        
          fprintf(fconfig,"%i\n",(OffCol2-OffCol1+1));        
          } else {
          fprintf(fconfig,"%i\n",1);        
          fprintf(fconfig,"%i\n",numberOfLines);        
          fprintf(fconfig,"%i\n",numberOfLines);        
          fprintf(fconfig,"%i\n",1);        
          fprintf(fconfig,"%i\n",numberOfSamples);        
          fprintf(fconfig,"%i\n",numberOfSamples);
          }
        }
      }
    if (strstr(Buf,"swathTiming") != NULL) FlagSwath = 1; 
    }    
    
/*******************************************************************/
/*******************************************************************/

  fclose(ftmp);
  fclose(fconfig);
   
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