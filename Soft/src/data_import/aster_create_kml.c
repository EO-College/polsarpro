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
#include "../lib/util.h"

char *my_strrev(char *buf);

/* CHARACTER STRINGS */
char CS_Texterreur[80];

/* ACCESS FILE */
FILE *filename;

/*******************************************************************************
Routine  : main
Authors  : Eric POTTIER, Laurent FERRO-FAMIL
Creation : 11/2008
Update  :
*-------------------------------------------------------------------------------

Description :  Create a Google Kml File

*-------------------------------------------------------------------------------
Inputs arguments :
argc : nb of input arguments
argv : input arguments array
Returned values  :
void
*******************************************************************************/

int main(int argc, char *argv[])
/*                                      */
{

/* LOCAL VARIABLES */

  char FileName[FilePathLength];

  float Lat00,LatN0,Lat0N,LatNN,LatCenter;
  float Lon00,LonN0,Lon0N,LonNN,LonCenter;
  
  int ii,jj;

  PSP_Threads = omp_get_max_threads();
  if (PSP_Threads <= 2) {
    PSP_Threads = 1;
    } else {
	PSP_Threads = PSP_Threads - 1;
	}
  omp_set_num_threads(PSP_Threads);

/******************************************************************************/
/* WRITE GOOGLE FILE */

  sprintf(FileName, "%s", "C:\\ASTER.kml");
  if ((filename = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fprintf(filename,"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
  fprintf(filename,"<kml xmlns:xsi=\"http://earth.google.com/kml/2.0\">\n");
  fprintf(filename,"<Document>\n");
  fprintf(filename,"<Style id=\"SRTMstyle\"><LineStyle>\n");
  fprintf(filename,"<color>FF00FFFF</color><width>1</width>\n");
  fprintf(filename,"</LineStyle>\n");
  fprintf(filename,"<Icon>IconSRTM.gif</Icon>\n");
  fprintf(filename,"</Style>\n");

  for (ii=-180; ii<180; ii++) {
    for (jj=-90; jj<+90; jj++) {

  Lon00 = (float)ii; LonN0 = Lon00;
  Lon0N = (float)ii + 1.; LonNN = Lon0N;
  Lat00 = (float)jj + 1.; Lat0N = Lat00;
  LatN0 = (float)jj; LatNN = LatN0;
  LonCenter = Lon00 + 0.5;
  LatCenter = Lat00 - 0.5;

  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<styleUrl>#SRTMstyle></styleUrl>\n");
  
  fprintf(filename,"<name>\n");
  fprintf(filename, "ASTGTM_");
  if (jj>0) {
    if (jj>9) fprintf(filename, "N%i",jj);
    else  fprintf(filename, "N0%i",jj);
    }
  if (jj==0) fprintf(filename, "N00");
  if (jj<0) {
    if (-jj>9) fprintf(filename, "S%i",-jj);
    else  fprintf(filename, "S0%i",-jj);
    }
    
  if (ii>0) {
    if (ii>99) fprintf(filename, "E%i\n",ii);
    if ((ii>9)&&(ii<100)) fprintf(filename, "E0%i\n",ii);
    if ((ii>0)&&(ii<10)) fprintf(filename, "E00%i\n",ii);
    }
  if (ii==0) fprintf(filename, "E000\n");
  if (ii<0) {
    if (-ii>99) fprintf(filename, "W%i\n",-ii);
    if ((-ii>9)&&(-ii<100)) fprintf(filename, "W0%i\n",-ii);
    if ((-ii>0)&&(-ii<10)) fprintf(filename, "W00%i\n",-ii);
    }
    fprintf(filename,"</name>\n");
    
  fprintf(filename,"<Point>\n");
  fprintf(filename,"<coordinates>%f,%f,1000.0</coordinates>\n",LonCenter,LatCenter);
  fprintf(filename,"</Point>\n");
  fprintf(filename,"</Placemark>\n");

  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<styleUrl>#SRTMstyle></styleUrl>\n");
  fprintf(filename,"<LineString>\n");
  fprintf(filename,"<coordinates>\n");
  fprintf(filename, "%f,%f,1000.0\n", Lon00,Lat00);
  fprintf(filename, "%f,%f,1000.0\n", LonN0,LatN0);
  fprintf(filename, "%f,%f,1000.0\n", LonNN,LatNN);
  fprintf(filename, "%f,%f,1000.0\n", Lon0N,Lat0N);
  fprintf(filename, "%f,%f,1000.0\n", Lon00,Lat00);
  fprintf(filename,"</coordinates>\n");
  fprintf(filename,"</LineString>\n");
  fprintf(filename,"</Placemark>\n");
  fprintf(filename,"\n");
  }
  }
  
  fprintf(filename,"</Document>\n");
  fprintf(filename,"</kml>\n");

  fclose(filename);

  return 1;
}



