//#include <GL/glew.h>

#ifndef TEXTURES_H
#define TEXTURES_H

#include <omp.h>
#include <GL/freeglut.h>
#include <FreeImage.h>  
#include <stdio.h>
#include <math.h>
#include "utils.h" 

#include "tinyfiledialogs.h"

#ifndef max
#define max(x,y) ((x)>(y) ? (x) : (y))
#define min(x,y) ((x)<(y) ? (x) : (y))
#endif

#ifndef _MAX_PATH
#define _MAX_PATH 4096
#endif

typedef unsigned int uint;

class ImageTex
{
public:
	char* name;	
	char path[_MAX_PATH];
    POINT texSize;	
	int scan_width;

	// data
	BYTE** bits;
	int texCount;	
	//texture names for OpenGL
    GLuint* texIds;
	//texture name for magnification
	GLuint texMagId;
	//width and height of mipmaps
	POINT* mipSize;
	//coordinates of upper left corner
	POINT* mipCoord;
	//rows and cols count
	POINT mipDim;
	//mip desired size
	POINT mipDesSize;
	//size of the magnification
	POINT magSize;
    
    //ColorMap
    int NColor;
    unsigned int PalCol[256];
    float ValMin;
    float ValMax;

	//allocated
	int ready;
	ImageTex(int width, int height);
	ImageTex(const ImageTex& src);
	static ImageTex* loadImage(const char *path);

	~ImageTex();
	void clearTexture();
	int saveImageTex();	
	void reloadTextures();
	void deleteMipTexture(int i);
	void createTextureMip(int i, int mipScale);
	void drawMip(int i);
	void createMagnificationTexture(POINT magSize);
	void updateMagnificationTexture(FPOINT pos);
	void drawMagnification(FPOINT pos, float factor, float screenx, float screeny);

	static int checkImagesSizes(char** paths, int c, int* orient);
	static void changeFilterMode(GLuint* textureId, int size, GLint filtering);
	static void pickBitsPart(FIBITMAP *bitmap, POINT size, unsigned startX, unsigned startY, unsigned w, unsigned h, BYTE* bitsOut);
	static void printBitmapDetails(FIBITMAP *bitmap);
private:
	ImageTex();
	BYTE* tmpBits;
	void calculateMipCountAndSizes();
	FPOINT lastMagPos;
};

extern void memoryUsage(); 

#endif