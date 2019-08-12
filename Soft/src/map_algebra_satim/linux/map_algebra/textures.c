#include "textures.h"
  
//----------------
//Constructors
// ---------------
ImageTex::ImageTex(int width, int height) : ImageTex()
{
	int mipIdx;
	int bitsSize;			 

	printf("New texture ImageTex creation...\n");

	this->magSize.x = 128;
	this->magSize.y = 128;
	this->texSize.x = width;
	this->texSize.y = height;
	this->calculateMipCountAndSizes();

	this->texIds = (GLuint*)calloc(this->texCount, sizeof(GLuint));
	this->bits = (BYTE**)malloc(sizeof(BYTE*) * this->texCount);
	this->name = (char*)malloc(512 * sizeof(char));
	this->name[0] = '\0';

	if (this->texCount == 0 || this->texIds == 0 || this->mipCoord == 0 || this->mipSize == 0 || this->bits == 0)
	{		
		fprintf(stderr, "No memory for the image... Exiting...\n");
		char tmp[100];
		sprintf(tmp, "Texture problem: No memory for the image.");
		tinyfd_messageBox("Texture error", tmp, "ok", "error", 1);
		exit(-1);
	}

#pragma omp parallel for
	for (mipIdx = 0; mipIdx < this->texCount; mipIdx++)
	{
		//scan_width = ((((24 * dst->mipSize[mipIdx].x) + 23) / 24) * 3);
		bitsSize = this->mipDesSize.x * this->mipDesSize.y * 3;
		printf("Memory allocation %d threads %c\r", bitsSize, spc());
		this->bits[mipIdx] = (BYTE*)calloc(bitsSize, sizeof(BYTE));
		if (this->bits[mipIdx] == 0)
		{
			fprintf(stderr, "No memory for the image... Exiting...\n");
			char tmp[100];
			sprintf(tmp, "Texture problem: No memory for the image.");
			tinyfd_messageBox("Texture error", tmp, "ok", "error", 1);
			exit(-1);
		}
	}					
	texMagId = NULL;
	this->ready = 1;
}
ImageTex::ImageTex(const ImageTex& src) : ImageTex()
{
	int mipIdx;
	int bitsSize;
	printf("New texture ImageTex creation from src...\n");

	if (this->ready > 0)
	{
		if (this->texSize.x != src.texSize.x || this->texSize.y != src.texSize.y)
		{
			this->clearTexture();
		}
		else
		{
			return;
		}
	}

	this->texCount = src.texCount;
	this->mipDim.x = src.mipDim.x;
	this->mipDim.y = src.mipDim.y;
	this->texSize.x = src.texSize.x;
	this->texSize.y = src.texSize.y;
	this->scan_width = src.scan_width;
	this->mipDesSize.x = src.mipDesSize.x;
	this->mipDesSize.y = src.mipDesSize.y;
	this->magSize.x = src.magSize.x; 
	this->magSize.y = src.magSize.y;	


	this->texIds = (GLuint*)calloc(this->texCount, sizeof(GLuint));
	this->mipCoord = (POINT*)malloc(sizeof(POINT)*this->texCount);
	this->mipSize = (POINT*)malloc(sizeof(POINT)*this->texCount);
	this->bits = (BYTE**)malloc(sizeof(BYTE*) * this->texCount);
	this->name = (char*)malloc(512 * sizeof(char));
	this->name[0] = '\0';
	strcpy(this->path, src.path);

	if (this->texCount == 0 || this->texIds == 0 || this->mipCoord == 0 || this->mipSize == 0 || this->bits == 0)
	{
		fprintf(stderr, "No memory for the copying... Exiting...\n");
		char tmp[100];
		sprintf(tmp, "Texture problem: No memory for the image.");
		tinyfd_messageBox("Texture error", tmp, "ok", "error", 1);
		exit(-1);
	}
	for (mipIdx = 0; mipIdx < this->texCount; mipIdx++)
	{
		this->mipCoord[mipIdx].x = src.mipCoord[mipIdx].x;
		this->mipCoord[mipIdx].y = src.mipCoord[mipIdx].y;
		this->mipSize[mipIdx].x = src.mipSize[mipIdx].x;
		this->mipSize[mipIdx].y = src.mipSize[mipIdx].y;

		//scan_width = ((((24 * this->mipSize[mipIdx].x) + 23) / 24) * 3);
		bitsSize = this->mipDesSize.x * this->mipDesSize.y * 3;
		printf("Memory allocation %d %c                                 \r", bitsSize, spc());
		this->bits[mipIdx] = (BYTE*)calloc(bitsSize, sizeof(BYTE));
		if (this->bits[mipIdx] == 0)
		{
			fprintf(stderr, "No memory for the copying... Exiting...\n");
			char tmp[100];
			sprintf(tmp, "Texture problem: No memory for the image.");
			tinyfd_messageBox("Texture error", tmp, "ok", "error", 1);
			exit(-1);
		}
	}				
	this->texMagId = NULL;
	this->ready = 1;
}
ImageTex* ImageTex::loadImage(const char *path)
{
	ImageTex *imageTex;
	FREE_IMAGE_FORMAT format;
	FIBITMAP *bitmap;
	FIBITMAP *src;
	char* f;
	int i;

	FreeImage_Initialise(1);
	printf("Loading '%s'... ", path);
	

	format = FreeImage_GetFileType(path, 0);

	//TODO: 
	// windows wont load image if path is unicode (wchar_t).
	src = FreeImage_Load(format, path, 0);
	//printf("size: %dx%d. \n",FreeImage_GetWidth(bitmap),FreeImage_GetHeight(bitmap));

	if (src)
	{ 
		/*if (FreeImage_GetColorType(src) == FIC_RGBALPHA)
			bitmap = FreeImage_ConvertTo32Bits(src);
		else*/
			bitmap = FreeImage_ConvertTo24Bits(src);

		//printBitmapDetails(bitmap);

		//bitmap = FreeImage_ConvertTo32Bits(src);
		//FreeImage_Unload(src);

		imageTex = new ImageTex(FreeImage_GetWidth(bitmap), FreeImage_GetHeight(bitmap));
		strcpy(imageTex->path, path);

		f = (char*)strrchr(path, PATH_SEPARATOR);
		if (f == NULL) f = (char*)(path);
		else f = f + 1;

		strcpy(imageTex->name, f);// , min(511, strlen(f)));

#pragma omp parallel for shared(bitmap)
		for (i = 0; i < imageTex->texCount; i++)
		{
			pickBitsPart(bitmap, imageTex->texSize, imageTex->mipCoord[i].x, imageTex->mipCoord[i].y, imageTex->mipDesSize.x, imageTex->mipDesSize.y, imageTex->bits[i]);
		}
		FreeImage_Unload(bitmap);
		printf("%-60s\n","Done!");
	}
	else
	{
		fprintf(stderr, "Failed loading image! Exiting\n");
		char tmp[100];
		sprintf(tmp, "Image problem: Failed loading image! Exiting.");
		tinyfd_messageBox("Image error", tmp, "ok", "error", 1);
		exit(-2);
	}

	FreeImage_DeInitialise();				    
	return imageTex;
}
ImageTex::ImageTex()
{
	this->magSize.x = 128;
	this->magSize.y = 128;
	tmpBits = NULL;
	texMagId = NULL;
	this->ready = -1;	
}
//----------------
//Destructor
// ---------------
ImageTex::~ImageTex()
{
	clearTexture();
}
//----------------
//Methods
// ---------------
void ImageTex::calculateMipCountAndSizes()
{
	int i, j;
	const POINT d = { 512, 512 };
	this->mipDim.y = (long)ceil(this->texSize.y / (float)d.y);
	this->mipDim.x = (long)ceil(this->texSize.x / (float)d.x);
	this->texCount = this->mipDim.y* this->mipDim.x;
	printf("Texture size: %d %d -> titles: %d\n", this->texSize.x, this->texSize.y, this->texCount);

	this->mipCoord = (POINT*)malloc(sizeof(POINT)*this->texCount);
	this->mipSize = (POINT*)malloc(sizeof(POINT)*this->texCount);
	this->mipDesSize.x = d.x;
	this->mipDesSize.y = d.y;

	for (i = 0; i < this->mipDim.y; i++)
	{
		for (j = 0; j < this->mipDim.x; j++)
		{
			this->mipCoord[i*this->mipDim.x + j].x = d.x * j;
			this->mipCoord[i*this->mipDim.x + j].y = d.y * i;

			if (d.y * j + d.x < this->texSize.x)
				this->mipSize[i*this->mipDim.x + j].x = d.x;
			else
				this->mipSize[i*this->mipDim.x + j].x = this->texSize.x - j * d.x;

			if (d.y * i + d.x < this->texSize.y)
				this->mipSize[i*this->mipDim.x + j].y = d.y;
			else
				this->mipSize[i*this->mipDim.x + j].y = this->texSize.y - i * d.y;
		}
	}
}
void ImageTex::clearTexture()
{ 
	glDeleteTextures(this->texCount, this->texIds);
	free(this->mipCoord);
	free(this->mipSize);
	if (this->name != NULL)
		free(this->name);	
	for (int i = 0; i < this->texCount; i++)
		free(this->bits[i]);
	free(this->bits);
	free(this->texIds);
}
int ImageTex::saveImageTex()
{
	int stat = 0;
	FIBITMAP *bitmap;
	int x, y, mipidx;
	const char* destName;
	char * tmpdestName = (char*)malloc(strlen(path) + 160);
	int c = 0;
	BYTE *_bits;
	size_t size;
	char *f;
	char *e;
	char *tmppath = (char*)malloc(strlen(path) + 160);
	char const * aFilterPatterns[1] = { "*.png" };
	char message[128];
	//sciezka do pliku
	f = (char*)strrchr(path, PATH_SEPARATOR);
	if (f == NULL) f = (char*)(path);
	else f = f + 1; 	
	
	strncpy(tmppath, path, f-path);	
	tmppath[f - path] = '\0';
	//sciezka z nowa nazwa
	sprintf(tmpdestName, "%s%s.png", tmppath, name);
	

	while (fileExists(tmpdestName))
	{
		sprintf(tmpdestName, "%s%s_%d.png", tmppath, name, ++c);
	}

	destName = tinyfd_saveFileDialog("Save as...", tmpdestName, 1, aFilterPatterns, "PNG image file");	
	if (destName)
	{

		printf("Saving bitmap as '%s'... \n", path, destName);

		FreeImage_Initialise();
		bitmap = FreeImage_Allocate(texSize.x, texSize.y, 24, FI_RGBA_RED_MASK, FI_RGBA_GREEN_MASK, FI_RGBA_BLUE_MASK);

		if (bitmap)
		{  
			for (mipidx = 0; mipidx < texCount; mipidx++)
			{
				for (y = 0; y < mipSize[mipidx].y; y++)
				{
					size = mipSize[mipidx].x * 3;

					if (mipCoord[mipidx].y + y >= texSize.y)
						continue;
					if (mipCoord[mipidx].x + mipSize[mipidx].x >= texSize.x)
						size = (texSize.x - mipCoord[mipidx].x - 1) * 3;

					_bits = (BYTE*)FreeImage_GetScanLine(bitmap, texSize.y - 1 - (mipCoord[mipidx].y + y));
					_bits += mipCoord[mipidx].x * 3;
					for (int pi = 0; pi < size; pi += 3)
					{
						_bits[pi + FI_RGBA_RED] = bits[mipidx][y *mipDesSize.x * 3 + pi + 0];
						_bits[pi + FI_RGBA_GREEN] = bits[mipidx][y *mipDesSize.x * 3 + pi + 1];
						_bits[pi + FI_RGBA_BLUE] = bits[mipidx][y *mipDesSize.x * 3 + pi + 2];

					}

					//memcpy(_bits, &(bits[mipidx][y *mipDesSize.x * 3]), size);
				}
				printf("Saving... %c\r", spc());
			}

			if (FreeImage_Save(FIF_PNG, bitmap, destName, PNG_DEFAULT))
			{
				sprintf(message, "File saved as:\n %s\n", destName);
				tinyfd_messageBox("Saving file", message, "ok", "info", 1);
				stat = 1;
			}
			FreeImage_Unload(bitmap);

		}
		else
		{
			tinyfd_messageBox("Saving file", "Unable to initialize bitmap.", "ok", "error", 1);
		}
	} 

	FreeImage_DeInitialise();

	return stat;
}
void ImageTex::deleteMipTexture(int i)
{
	glDeleteTextures(1, this->texIds + i);
	this->texIds[i] = NULL;
								  

	free(this->tmpBits);
	this->tmpBits = NULL;
}
void ImageTex::reloadTextures()
{
	int i = 0;
	for (i = 0; i < this->texCount; i++)
	{
		if (this->texIds[i] != 0)
		{
			this->deleteMipTexture(i);
		}
	}

}
void ImageTex::createTextureMip(int i, int mipScale)
{
	int bitsSize;
	int x, y;
	GLenum error;

	glGenTextures(1, this->texIds + i);

	glBindTexture(GL_TEXTURE_2D, this->texIds[i]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	bitsSize = this->mipDesSize.y * this->mipDesSize.x * 3;

	if (this->tmpBits == NULL)
		this->tmpBits = (BYTE*)malloc(bitsSize / mipScale / mipScale);

	this->ready = mipScale;

	if (mipScale == 1)
	{
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, this->mipDesSize.x, this->mipDesSize.y, 0, GL_RGB, GL_UNSIGNED_BYTE, this->bits[i]);
	}
	else
	{
		int ind = 0;
		for (y = 0; y <this->mipDesSize.y; y += mipScale)
		{
			for (x = 0; x <this->mipDesSize.x; x += mipScale)
			{
				this->tmpBits[ind++] = this->bits[i][y * this->mipDesSize.x * 3 + x * 3 + 0];
				this->tmpBits[ind++] = this->bits[i][y * this->mipDesSize.x * 3 + x * 3 + 1];
				this->tmpBits[ind++] = this->bits[i][y * this->mipDesSize.x * 3 + x * 3 + 2];
			}
		}
		//send data to GPU
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, this->mipDesSize.x / mipScale, this->mipDesSize.y / mipScale, 0, GL_RGB, GL_UNSIGNED_BYTE, this->tmpBits);// this->bits[i]);
	}

	error = glGetError();
	if (error != 0)
	{
		printf("OpenGL problem: %s\nExiting...", gluErrorString(error));
		exit(-1);
	}
}
void ImageTex::drawMip(int i)
{
	float tw = this->mipSize[i].x / (float)this->mipDesSize.x - 1;
	float th = this->mipSize[i].y / (float)this->mipDesSize.y - 1;
		
	glBindTexture(GL_TEXTURE_2D, this->texIds[i]);
	glBegin(GL_QUADS);

	glTexCoord2f(tw, -1.0f);
	glVertex2i(this->mipCoord[i].x + this->mipSize[i].x, this->mipCoord[i].y);
	//glVertex2f(p0[0] + w, p0[1] - h);

	glTexCoord2f(-1.0f, -1.0f);
	glVertex2i(this->mipCoord[i].x, this->mipCoord[i].y);
	//glVertex2f(p0[0] + w + w, p0[1] - h);

	glTexCoord2f(-1.0f, th);
	glVertex2i(this->mipCoord[i].x, this->mipCoord[i].y + this->mipSize[i].y);
	//glVertex2f(p0[0] + w + w, p0[1] - h - h);

	glTexCoord2f(tw, th);
	glVertex2i(this->mipCoord[i].x + this->mipSize[i].x, this->mipCoord[i].y + this->mipSize[i].y);
	//glVertex2f(p0[0] + w, p0[1] - h - h);

	glEnd();
}
void ImageTex::createMagnificationTexture(POINT magSize)
{
	int bitsSize;
	int x, y;
	GLenum error;
	this->magSize = magSize;
	printf("\nCreate mag %d\n", texMagId);

	if (this->texMagId != 0)
	{
		glDeleteTextures(1, &(this->texMagId));
	}
	glGenTextures(1, &(this->texMagId));
	 														  
	glBindTexture(GL_TEXTURE_2D, this->texMagId);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, this->magSize.x, this->magSize.y, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);

	error = glGetError();
	if (error != 0)
	{
		printf("OpenGL problem: %s\nExiting...", gluErrorString(error));
		exit(-1);
	}
}
void ImageTex::drawMagnification(FPOINT pos, float factor, float screenx, float screeny)
{				 
	if (pos.x > this->texSize.x || pos.y > this->texSize.y || pos.x < 0 || pos.y < 0)
		return;

	this->updateMagnificationTexture(pos);

	FPOINT v1,v2,v3,v4;
	float offset = -10.0f;
	v1.x = screenx + offset;
	v1.y = screeny - offset;

	v2.x = screenx + magSize.x + offset;
	v2.y = screeny - offset;

	v3.x = screenx + magSize.x  + offset;
	v3.y = screeny - magSize.y  - offset;

	v4.x = screenx + offset;
	v4.y = screeny - magSize.y  - offset;


	glPushAttrib(GL_ENABLE_BIT | GL_CURRENT_BIT | GL_DEPTH_TEST);
		 
	glEnable(GL_TEXTURE_2D);
	glDepthMask(GL_TRUE);
	glColor3f(1.0, 1.0, 1.0);
	glBindTexture(GL_TEXTURE_2D, this->texMagId);  
	glBegin(GL_QUADS);

	glTexCoord2f(0, 0);
	glVertex3i(v1.x, v1.y , 0);

	glTexCoord2f(1.0f, 0.0f);
	glVertex3i(v2.x, v2.y, 0);

	glTexCoord2f(1.0f, 1.0f);
	glVertex3i(v3.x , v3.y, 0);

	glTexCoord2f(0, 1.0f);
	glVertex3i(v4.x, v4.y, 0);
	
	glEnd();
	glDisable(GL_TEXTURE_2D);
	glBegin(GL_LINE_LOOP);

	glVertex3i(v1.x, v1.y, 0);
	glVertex3i(v2.x, v2.y, 0);
	glVertex3i(v3.x, v3.y, 0);
	glVertex3i(v4.x, v4.y, 0);

	glEnd();
	glColor3f(0.0, 0.0, 0.0);
	glBegin(GL_LINE_LOOP);

	glVertex3i(v1.x+1, v1.y-1, 0);
	glVertex3i(v2.x-1, v2.y-1, 0);
	glVertex3i(v3.x-1, v3.y+1, 0);
	glVertex3i(v4.x+1, v4.y+1, 0);

	glEnd();
	glPopAttrib();
}
void ImageTex::updateMagnificationTexture(FPOINT pos)
{				    
	if (this->texMagId <= 0)
	{
		this->createMagnificationTexture(this->magSize);
	}

	if (lastMagPos.x == pos.x && lastMagPos.y == pos.y)
		return;
	lastMagPos = pos;
	
	GLenum error;
	int bitsSize = magSize.x * magSize.y * 3;
													  
	BYTE* tmpBits = (BYTE*)calloc(bitsSize , sizeof(BYTE));

#pragma omp parallel for num_threads(2)
		//for (int y = this->magSize.y - 1; y >= 0; y--)
		for (int y = 0; y<  this->magSize.y ; y++)
		{
			for (int x = 0; x < this->magSize.x; x++)
			{
				int row = (int)(pos.y + y - magSize.y / 2) / 512;
				int col = (int)(pos.x + x - magSize.x / 2) / 512;
				int ny = ((int)pos.y + y - magSize.y / 2) % 512;
				int nx = ((int)pos.x + x - magSize.x / 2) % 512;
				int mipidx = row * (int)ceilf(this->texSize.x / 512.0f) + col;

				if (ny < 0 || nx < 0 || nx >= 512 || ny >= 512)
				{
					continue;
				}
				else
				{
					if (mipidx >= 0 && mipidx < this->mipDim.x *this->mipDim.y)
					{
						int ind = 3*(y*this->magSize.x + x);
						tmpBits[ind + 0] = this->bits[mipidx][ny * this->mipDesSize.x * 3 + nx * 3 + 0];
						tmpBits[ind + 1] = this->bits[mipidx][ny * this->mipDesSize.x * 3 + nx * 3 + 1];
						tmpBits[ind + 2] = this->bits[mipidx][ny * this->mipDesSize.x * 3 + nx * 3 + 2];
					}
				}
			}
		}
	
	//send data to GPU	   	
	glBindTexture(GL_TEXTURE_2D, this->texMagId);
	//glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB8, this->magSize.x, this->magSize.y, 0, GL_RGB, GL_UNSIGNED_BYTE, tmpBits);
	glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, this->magSize.x, this->magSize.y, GL_RGB, GL_UNSIGNED_BYTE, tmpBits); 

	free(tmpBits); 
	error = glGetError();
	if (error != 0)
	{
		printf("OpenGL problem: %s\nExiting...", gluErrorString(error));
		exit(-1);
	}
}
//----------------
//static methods
// ---------------
void ImageTex::printBitmapDetails(FIBITMAP *bitmap)
{
	BITMAPINFO *info = FreeImage_GetInfo(bitmap);

	printf("\n");
	//printf("%s: %s\n",info->bmiColors)
	printf("COLORTYPE: %d\n",FreeImage_GetColorType(bitmap));		
}
void ImageTex::pickBitsPart(FIBITMAP *bitmap, POINT size, unsigned startX, unsigned startY, unsigned w, unsigned h, BYTE* bitsOut)
{
	uint  x, y;
	int ind = 0;
	int indy = 0;
	BYTE *pixel;
	int bytespp;

	if (bitsOut == NULL)
	{
		fprintf(stderr, "bitsOut is NULL. Dying.");
		exit(-2);
	}
	if (bitmap == NULL)
	{
		fprintf(stderr, "bitmap is NULL. Dying.");
		exit(-2);
	}
	bytespp = 3;// FreeImage_GetLine(bitmap) / FreeImage_GetWidth(bitmap);

	//flip Y	
	for (y = (int)startY; y < min((unsigned)size.y, startY + h); y++)
	{
		pixel = FreeImage_GetScanLine(bitmap, size.y - 1 - y);
		pixel += startX * bytespp;
		ind = indy*w*bytespp;
		for (x = 0; x < w && startX + x < (unsigned)size.x; x++)
		{
			bitsOut[ind++] = pixel[FI_RGBA_RED];
			bitsOut[ind++] = pixel[FI_RGBA_GREEN];
			bitsOut[ind++] = pixel[FI_RGBA_BLUE];
			pixel += bytespp;
		}
		indy++;
	}

}
int ImageTex::checkImagesSizes(char** paths, int c, int* orient)
{
	FREE_IMAGE_FORMAT format;
	FIBITMAP *bitmap;
	int i = 0;
	int w, h;
	int differ = 0;
	FreeImage_Initialise(1);


	printf("Images' sizes...");
	for (i = 0; i < c; i++)
	{
		if (!fileExists(paths[i]))
		{
			printf("File not found: %s\n\n", paths[i]);
			exit(-1);
		}

		format = FreeImage_GetFileType(paths[i], 0);
		bitmap = FreeImage_Load(format, paths[i], FIF_LOAD_NOPIXELS);
		if (i == 0)
		{
			w = FreeImage_GetWidth(bitmap);
			h = FreeImage_GetHeight(bitmap);
		}
		else
		{
			if (w != FreeImage_GetWidth(bitmap) || h != FreeImage_GetHeight(bitmap))
			{
				fprintf(stderr, " are different\n");
				differ = 1;
				//exit(-3);
			}
		}
		FreeImage_Unload(bitmap);
	}
	printf(" are equal: %dx%d. Let's go!\n", w, h);

	FreeImage_DeInitialise();
	*orient = w > h;
	return differ;
}
void ImageTex::changeFilterMode(GLuint* textureId, int size, GLint filtering)
{
	int i = 0;
	for (i = 0; i < size; i++)
	{
		glBindTexture(GL_TEXTURE_2D, textureId[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, filtering);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, filtering);
	}
}