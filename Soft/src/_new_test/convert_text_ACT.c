#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

int main(int argc, char *argv[])
{

/* Input/Output file pointer arrays */
    FILE *in_file, *out_file;

/* Input/Output files */
    char file_in[8192], file_out[8192];
    char buf_in[8192], buf_out[8192];
    char buf_test[10];
	
/* Internal variables */
    int FlagStop, FlagBlock;
	
/* Program Start */
    if (argc == 3) {
      strcpy(file_in, argv[1]);
      strcpy(file_out, argv[2]);
      } else {
      printf("\nconvert_text_ACT input_file.txt output_file.txt\n");
	  exit(1);
	  }

/* Input/Output File Opening */
    in_file = fopen(file_in, "r");
	rewind(in_file);
    out_file = fopen(file_out, "w");

/* Loop over the Input File */

    FlagStop = 0;
    while (FlagStop == 0) {
      if (feof(in_file)) FlagStop = 1;
      else {
        strcpy(buf_out, "");
        fgets(&buf_in[0],4096,in_file);
        fgets(&buf_in[0],4096,in_file); 
		strncat(buf_out, &buf_in[0], 8); strcat(buf_out, " ");
        FlagBlock = 0;
        while (FlagBlock == 0) {
          fgets(&buf_in[0],4096,in_file); 
          if (strcmp(buf_in, "\n") != 0) {
            strcpy(buf_test,""); strncat(buf_test, &buf_in[0], 3);			
            if (strcmp(buf_test, "<i>") == 0) {
//              strncat(buf_test, &buf_in[0], 6);			
//              if (strcmp(buf_test, "<i>ÔÖ¬") != 0) {
//                strncat(buf_out, &buf_in[7], strlen(buf_in) - 15); strcat(buf_out, " ");
//			    } else {
                strncat(buf_out, &buf_in[3], strlen(buf_in) - 8); strcat(buf_out, " ");
//				}
			  } else {
              strncat(buf_out, &buf_in[0], strlen(buf_in) - 1); strcat(buf_out, " ");
			  }
		    } else { 
            FlagBlock = 1;			
            }
		  }
        printf("%s",buf_out);
getchar();
        }
      }

/* Input/Output File Closing */
    fclose(in_file);
    fclose(out_file);

    return 1;
}

/*
****************************************************************
while (c != '\n' && c != EOF)

sprintf(file_name, "%s%s", in_dir, file_name_in_out[np]);


  if ((filename = fopen(FileInput, "r")) == NULL)
    edit_error("Could not open output file : ", FileInput);

  rewind(filename);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneCenterLatitude");
    if (pstr != NULL) Flag = 1;
    if (feof(filename)) Flag = 2;
  }
  
if (Flag != 2) {
  
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  LatCenter = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneCenterLongitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  LonCenter = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneLeftTopLatitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  Lat00 = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneLeftTopLongitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  Lon00 = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneRightTopLatitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  Lat0N = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneRightTopLongitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  Lon0N = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneLeftBottomLatitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  LatN0 = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneLeftBottomLongitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  LonN0 = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneRightBottomLatitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  LatNN = atof(Tmp);

  Flag = 0;
  while (Flag == 0) {
    fgets(&Buf[0], 100, filename);
    pstr = strstr(Buf,"Brs_ImageSceneRightBottomLongitude");
    if (pstr != NULL) Flag = 1;
  }
  Flag = 0;index = 0;
  while (Flag == 0) {
    strcpy(Tmp, ""); strncat(Tmp, &Buf[index], 1);
    if (strcmp(Tmp, "=") != 0) index++; else Flag = 1;
  }
  strcpy(Tmp, ""); strncat(Tmp, &Buf[index+2], strlen(Buf) - 1);
  LonNN = atof(Tmp);

  fclose(filename);


  sprintf(FileName, "%s%s", DirOutput, "GEARTH_POLY.kml");
  if ((filename = fopen(FileName, "w")) == NULL)
    edit_error("Could not open output file : ", FileName);

  fprintf(filename,"<!-- ?xml version=\"1.0\" encoding=\"UTF-8\"? -->\n");
  fprintf(filename,"<kml xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n");
  fprintf(filename,"<Placemark>\n");
  fprintf(filename,"<name>\n");
  fprintf(filename, "Image ALOS PALSAR\n");
  fprintf(filename,"</name>\n");
  fprintf(filename,"<LookAt>\n");
  fprintf(filename,"<longitude>\n");
  fprintf(filename, "%f\n", LonCenter);
  fprintf(filename,"</longitude>\n");
  fprintf(filename,"<latitude>\n");
  fprintf(filename, "%f\n", LatCenter);
  fprintf(filename,"</latitude>\n");
  fprintf(filename,"<range>\n");
  fprintf(filename,"250000.0\n");
  fprintf(filename,"</range>\n");
  fprintf(filename,"<tilt>0</tilt>\n");
  fprintf(filename,"<heading>0</heading>\n");
  fprintf(filename,"</LookAt>\n");
  fprintf(filename,"<Style>\n");
  fprintf(filename,"<LineStyle>\n");
  fprintf(filename,"<color>ff0000ff</color>\n");
  fprintf(filename,"<width>4</width>\n");
  fprintf(filename,"</LineStyle>\n");
  fprintf(filename,"</Style>\n");
  fprintf(filename,"<LineString>\n");
  fprintf(filename,"<coordinates>\n");
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename, "%f,%f,8000.0\n", LonN0,LatN0);
  fprintf(filename, "%f,%f,8000.0\n", LonNN,LatNN);
  fprintf(filename, "%f,%f,8000.0\n", Lon0N,Lat0N);
  fprintf(filename, "%f,%f,8000.0\n", Lon00,Lat00);
  fprintf(filename,"</coordinates>\n");
  fprintf(filename,"</LineString>\n");
  fprintf(filename,"</Placemark>\n");
  fprintf(filename,"</kml>\n");

  fclose(filename);

  if ((filename = fopen(FileGoogle, "w")) == NULL)
    edit_error("Could not open output file : ", FileGoogle);
  fprintf(filename, "%f\n", LatCenter);
  fprintf(filename, "%f\n", LonCenter);
  fprintf(filename, "%f\n", Lat00);
  fprintf(filename, "%f\n", Lon00);
  fprintf(filename, "%f\n", Lat0N);
  fprintf(filename, "%f\n", Lon0N);
  fprintf(filename, "%f\n", LatN0);
  fprintf(filename, "%f\n", LonN0);
  fprintf(filename, "%f\n", LatNN);
  fprintf(filename, "%f\n", LonNN);
  fclose(filename);

  } else {
  
  if ((filename = fopen(FileGoogle, "w")) == NULL)
    edit_error("Could not open output file : ", FileGoogle);
  fprintf(filename, "ERRORGOOGLE\n");
  fclose(filename);
  
  } 
  
  */
  
