/************************************************************************/
/*																		*/
/* PolSARproSim Version C1b  Forest Synthetic Aperture Radar Simulation	*/
/* Copyright (C) 2007 Mark L. Williams									*/
/*																		*/
/* This program is free software; you may redistribute it and/or		*/
/* modify it under the terms of the GNU General Public License			*/
/* as published by the Free Software Foundation; either version 2		*/
/* of the License, or (at your option) any later version.				*/
/*																		*/
/* This program is distributed in the hope that it will be useful,		*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of		*/
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.					*/
/* See the GNU General Public License for more details.					*/
/*																		*/
/* You should have received a copy of the GNU General Public License	*/
/* along with this program; if not, write to the Free Software			*/
/* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,			*/
/* MA  02110-1301, USA. (http://www.gnu.org/copyleft/gpl.html)			*/
/*																		*/
/************************************************************************/
/*
 * Author      : Mark L. Williams
 * Module      : bmpDefinitions.h
 * Revision    : Version C1b 
 * Date        : September, 2007
 * Notes       : Definitions for BMP format images
 */
#ifndef __BMPDEFINITIONS_H__
#define __BMPDEFINITIONS_H__

typedef unsigned short int	BMP_WORD;
typedef unsigned int		BMP_DWORD;
typedef signed int			BMP_LONG;
typedef unsigned char		BMP_BYTE;

typedef struct bitmapfileheader {
 BMP_WORD  bfType;
 BMP_DWORD bfSize;
 BMP_WORD  bfReserved1;
 BMP_WORD  bfReserved2;
 BMP_DWORD bfOffBits;
} Bitmapfileheader;

typedef struct bitmapinfoheader {
 BMP_DWORD biSize;
 BMP_LONG  biWidth;
 BMP_LONG  biHeight;
 BMP_WORD  biPlanes;
 BMP_WORD  biBitCount;
 BMP_DWORD biCompression;
 BMP_DWORD biSizeImage;
 BMP_LONG  biXPelsPerMeter;
 BMP_LONG  biYPelsPerMeter;
 BMP_DWORD biClrUsed;
 BMP_DWORD biClrImportant;
} Bitmapinfoheader;

typedef struct rgbquad {
 BMP_BYTE rgbBlue;
 BMP_BYTE rgbGreen;
 BMP_BYTE rgbRed;
 BMP_BYTE rgbReserved;
} Rgbquad;

#endif
