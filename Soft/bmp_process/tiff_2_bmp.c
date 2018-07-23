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

File     : bmp_processing.c
Project  : ESA_POLSARPRO
Authors  : Eric POTTIER
Version  : 2.0
Creation : 07/2011
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

Description :  Create a BMP file from a TIFF file

********************************************************************/
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <math.h>

#ifdef _WIN32
#include <dos.h>
#include <conio.h>
#endif

struct tiff_header_struct{
  short lsb;
  long  bits_per_pixel;
  long  image_length;
  long  image_width;
  long  strip_offset;
  long  photometric;
};

union long_char_union {
  long l_num;
  char l_alpha[4];
};

union short_char_union {
  short s_num;
  char s_alpha[2];
};

/* ROUTINES DECLARATION */
#include "../lib/PolSARproLib.h"
void read_tiff_header(FILE *image_file, struct tiff_header_struct *image_header);
void extract_long_from_buffer(char  buffer[], int lsb, int start, long  *number);  
void extract_short_from_buffer(char  buffer[], int lsb, int start, short  *number);

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
  FILE *fileinput, *fileoutput;

  char FileTiff[FilePathLength], FileBmp[FilePathLength], ColorMap[FilePathLength];

  struct tiff_header_struct image_header;

  char buffer[4];

  int i, j, bytes_to_read, MS, LS, is_a_tiff = 0;

  char *bmpimage;
  char *charbuffer;

/******************************************************************************/
/* INPUT PARAMETERS */
/******************************************************************************/

  if (argc == 3) {
  strcpy(FileTiff, argv[1]);
  strcpy(FileBmp, argv[2]);
  } else {
  printf("TYPE: tiff_2_bmp TiffInputFile BmpOutputFile\n");
  exit(1);
  }
/********************************************************************
********************************************************************/
/* USAGE */

strcpy(UsageHelp,"\ntiff_2_bmp.exe\n");
strcat(UsageHelp,"\nParameters:\n");
strcat(UsageHelp," (string)	-if 	input tiff file\n");
strcat(UsageHelp," (string)	-of  	output bmp file\n");
strcat(UsageHelp,"\nOptional Parameters:\n");
strcat(UsageHelp," (noarg) 	-help	displays this message\n");

/********************************************************************
********************************************************************/
/* PROGRAM START */

if(get_commandline_prm(argc,argv,"-help",no_cmd_prm,NULL,0,UsageHelp)) {
  printf("\n Usage:\n%s\n",UsageHelp); exit(1);
  }

if(argc < 5) {
  edit_error("Not enough input arguments\n Usage:\n",UsageHelp);
  } else {
  get_commandline_prm(argc,argv,"-if",str_cmd_prm,FileTiff,1,UsageHelp);
  get_commandline_prm(argc,argv,"-of",str_cmd_prm,FileBmp,1,UsageHelp);
  }

/********************************************************************
********************************************************************/

  check_file(FileTiff);
  check_file(FileBmp);

/*******************************************************************/
  if ((fileinput = fopen(FileTiff, "r")) == NULL)
    edit_error("Could not open configuration file : ", FileTiff);

  if ((fileoutput = fopen(FileBmp, "w")) == NULL)
    edit_error("Could not open configuration file : ", FileBmp);

  fread(buffer, 1, 4, fileinput);
  if(buffer[0] == 0x49 && buffer[1] == 0x49 && buffer[2] == 0x2a && buffer[3] == 0x00) is_a_tiff = 1;
  if(buffer[0] == 0x4d && buffer[1] == 0x4d && buffer[2] == 0x00 && buffer[3] == 0x2a) is_a_tiff = 1;

  if (is_a_tiff == 1) {
  //Read_tiff_header
  read_tiff_header(fileinput, &image_header);
  
  rewind(fileinput);
  fseek(fileinput,image_header.strip_offset,SEEK_SET);
  //Read_tiff_image
  bytes_to_read = (image_header.bits_per_pixel) / 8;

/* BMP HEADER */
  strcpy(ColorMap,"gray");
  write_header_bmp_8bit(image_header.image_length, image_header.image_width, 255., 0., ColorMap, fileoutput);

  charbuffer = vector_char(bytes_to_read*image_header.image_width);
  bmpimage = vector_char(image_header.image_width);
  
  for(i=0; i<image_header.image_length; i++) {
    fread(&charbuffer[0], sizeof(char), bytes_to_read*image_header.image_width, fileinput);
    for(j=0; j<image_header.image_width; j++) {
      MS = charbuffer[2*j]; if (MS < 0) MS = MS + 256;
      LS = charbuffer[2*j + 1]; if (LS < 0) LS = LS + 256;
      IntCharBMP = (int) ((256. * MS + LS) / 256.);
      bmpimage[j] = (char) IntCharBMP;
      }
    fwrite(&bmpimage[0], sizeof(char), image_header.image_width, fileoutput);
    }
  fclose(fileinput);
  fclose(fileoutput);

  } else {
  edit_error(FileTiff, " is not a TIFF file");
  }
  return 1;
}  

/*******************************************************************/
/*******************************************************************/

/********************************************************************
*
*  read_tiff_header(...
*
*  This function reads the header of a TIFF 
*  file and places the needed information into
*  the struct tiff_header_struct.
*
********************************************************************/
void read_tiff_header(FILE *image_file, struct tiff_header_struct *image_header)
{
  char buffer[12];

  int  i, lsb, not_finished;

  long bits_per_pixel, image_length, image_width, 
    offset_to_ifd, strip_offset, photometric, subfile;

  short entry_count, field_type, length_of_field, s_bits_per_pixel, s_image_length,
     s_image_width, s_strip_offset, s_photometric, tag_type;

  if(image_file != NULL){
   rewind(image_file);
   //Determine if the file uses MSB first or LSB first
   fread(buffer, 1, 8, image_file);
   if(buffer[0] == 0x49) lsb = 1;
   else lsb = 0;
  
   //Read the offset to the IFD
   extract_long_from_buffer(buffer, lsb, 4, &offset_to_ifd);
   
   not_finished = 1;
   while(not_finished){
    //Seek to the IFD and read the entry_count, i.e. the number of entries in the IFD.
    fseek(image_file, offset_to_ifd, SEEK_SET);
    fread(buffer, 1, 2, image_file);
    extract_short_from_buffer(buffer, lsb, 0, &entry_count);
    
    //Now loop over the directory entries. 
    //Look only for the tags we need. These are: ImageLength, ImageWidth, BitsPerPixel(BitsPerSample), StripOffset
    for(i=0; i<entry_count; i++){
     fread(buffer, 1, 12, image_file);
     extract_short_from_buffer(buffer, lsb, 0, &tag_type);
     
     switch(tag_type){
      case 255: /* Subfile Type */
       extract_short_from_buffer(buffer, lsb, 2, &field_type);
       extract_short_from_buffer(buffer, lsb, 4, &length_of_field);
       extract_long_from_buffer(buffer, lsb, 8, &subfile);
       break;
      case 256: /* ImageWidth */
       extract_short_from_buffer(buffer, lsb, 2, &field_type);
       extract_short_from_buffer(buffer, lsb, 4, &length_of_field);
       if(field_type == 3){
        extract_short_from_buffer(buffer, lsb, 8, &s_image_width);
        image_width = s_image_width;
       } else
        extract_long_from_buffer(buffer, lsb, 8, &image_width);
       break;
      case 257: /* ImageLength */
       extract_short_from_buffer(buffer, lsb, 2, &field_type);
       extract_short_from_buffer(buffer, lsb, 4, &length_of_field);
       if(field_type == 3){
        extract_short_from_buffer(buffer, lsb, 8, &s_image_length);
        image_length = s_image_length;
       } else
        extract_long_from_buffer(buffer, lsb, 8, &image_length);
       break;
      case 258: /* BitsPerSample */
       extract_short_from_buffer(buffer, lsb, 2, &field_type);
       extract_short_from_buffer(buffer, lsb, 4, &length_of_field);
       if(field_type == 3){
        extract_short_from_buffer(buffer, lsb, 8, &s_bits_per_pixel);
        bits_per_pixel = s_bits_per_pixel;
       } else
        extract_long_from_buffer(buffer, lsb, 8, &bits_per_pixel);
       break;
      case 273: /* StripOffset */
       extract_short_from_buffer(buffer, lsb, 2, &field_type);
       extract_short_from_buffer(buffer, lsb, 4, &length_of_field);
       if(field_type == 3){
        extract_short_from_buffer(buffer, lsb, 8, &s_strip_offset);
        strip_offset = s_strip_offset;
       } else
        extract_long_from_buffer(buffer, lsb, 8, &strip_offset);
       break;
      case 262: /* Photometric */
       extract_short_from_buffer(buffer, lsb, 2, &field_type);
       extract_short_from_buffer(buffer, lsb, 4, &length_of_field);
       if(field_type == 3){
        extract_short_from_buffer(buffer, lsb, 8, &s_photometric);
        photometric = s_photometric;
       } else
        extract_long_from_buffer(buffer, lsb, 8, &photometric);
       break;
      default:
       break;
     }  /* ends switch tag_type */
    }  /* ends loop over i directory entries */
    
    fread(buffer, 1, 4, image_file);
    extract_long_from_buffer(buffer, lsb, 0, &offset_to_ifd);
    if(offset_to_ifd == 0) not_finished = 0;
   }  /* ends while not_finished */
   
   image_header->lsb = lsb;
   image_header->bits_per_pixel = bits_per_pixel;
   image_header->image_length = image_length;
   image_header->image_width = image_width;
   image_header->strip_offset = strip_offset;
   image_header->photometric = photometric;
   
  }  /* ends if file opened ok */
}  /* ends read_tiff_header */

/********************************************************************
*
*  extract_long_from_buffer(...
*
*  This takes a four byte long out of a buffer of characters.
*
*  It is important to know the byte order LSB or MSB.
*
********************************************************************/
void extract_long_from_buffer(char  buffer[], int lsb, int start, long  *number)  
{
  union long_char_union lcu;

  if(lsb == 1){
    lcu.l_alpha[0] = buffer[start+0];
    lcu.l_alpha[1] = buffer[start+1];
    lcu.l_alpha[2] = buffer[start+2];
    lcu.l_alpha[3] = buffer[start+3];
  }  /* ends if lsb = 1 */

  if(lsb == 0){
    lcu.l_alpha[0] = buffer[start+3];
    lcu.l_alpha[1] = buffer[start+2];
    lcu.l_alpha[2] = buffer[start+1];
    lcu.l_alpha[3] = buffer[start+0];
  }  /* ends if lsb = 0    */

  *number = lcu.l_num;

}  /* ends extract_long_from_buffer */

/********************************************************************
*
*  extract_short_from_buffer(...
*
*  This takes a two byte short out of a buffer of characters.
*
*  It is important to know the byte order LSB or MSB.
*
********************************************************************/
void extract_short_from_buffer(char  buffer[], int lsb, int start, short  *number)  
{
  union short_char_union lcu;

  if(lsb == 1){
    lcu.s_alpha[0] = buffer[start+0];
    lcu.s_alpha[1] = buffer[start+1];
  }  /* ends if lsb = 1 */

  if(lsb == 0){
    lcu.s_alpha[0] = buffer[start+1];
    lcu.s_alpha[1] = buffer[start+0];
  }  /* ends if lsb = 0    */

  *number = lcu.s_num;

}  /* ends extract_short_from_buffer */



