#include "algebra.h"
extern char* appPath;

void performMAOperation(OperationInput *op)
{
	if (op->second != NULL)
	{
		if (op->first->texSize.x != op->second->texSize.x || op->first->texSize.y != op->second->texSize.y)
		{
			fprintf(stderr, "Images have different sizes. This operation is not permitted. ");
			return;
		}
	}

	switch (op->pendingOp)
	{
		case MA_SUM:
			ma_sum(*(op->first), *(op->second), op->result);
			break;
		case MA_DIFFERENCE:
			ma_diff(*(op->first), *(op->second), op->result);
			break;
		case MA_MULTIPLICATION:
			ma_mult(*(op->first), *(op->second), op->result);
			break;
		case MA_DIVISION:
			ma_div(*(op->first), *(op->second), op->result);
			break;
		case MA_ADJUST:
			ma_adjusting(*(op->first), op->result);
			break;
		case MA_EQUALIZE:
			ma_histEq(*(op->first), op->result);
			break;
		case MA_NEGATIVE:
			ma_negative(*(op->first), op->result);
			break;
		case MA_TOGRAY:
			ma_toGray(*(op->first), op->result);
			break;
		case MA_FLIPH:
			ma_flipH(op->first);
			break;
		case MA_FLIPV:
			ma_flipV(op->first);
			break;
		case MA_90CW:
			ma_Rotate(op->first, op->result, CW);
			break;
		case MA_90CCW:
			ma_Rotate(op->first, op->result, CCW);
			break;

		case MA_COLOR:
			ma_extractColor(*(op->first), op->result, op->parameters);
			break;
		case MA_COLORMAP:
			ma_ColorMap(*(op->first), op->result, op->parameters);
			break;
		 
		default:
			fprintf(stderr, "Not implemented yet... %d \n", op->pendingOp);
	}
}

void ma_sum(const ImageTex& first, const  ImageTex& second, ImageTex **result)
{
	int mipIdx;
	int i;
	char* tmp = (char*)calloc(512, 1);
	 
	*result = new ImageTex(first);

	sprintf(tmp, "Sum of %s and %s", first.name, second.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));
	
	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < first.texCount; mipIdx++)
	{		
		for (i = 0; i < first.mipDesSize.y * first.mipDesSize.x * 3; i++)
		{			
			(*result)->bits[mipIdx][i] = (BYTE)((first.bits[mipIdx][i] + (float)second.bits[mipIdx][i]) / 2.0);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n","Done. ");
	free(tmp);
}
void ma_diff(const ImageTex& first, const ImageTex& second, ImageTex **result)
{
	int mipIdx;
	int i;
	char* tmp = (char*)calloc(512, 1);

	*result = new ImageTex(first);

	sprintf(tmp, "Difference of %s and %s", first.name, second.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp)+1));
	
	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < first.texCount; mipIdx++)
	{
		for (i = 0; i < first.mipDesSize.y * first.mipDesSize.x * 3; i++)
		{
			(*result)->bits[mipIdx][i] = (BYTE)((first.bits[mipIdx][i] / 255.0f - second.bits[mipIdx][i] / 255.0f + 1.0f) / 2.0f * 255);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	free(tmp);
}
void ma_mult(const ImageTex& first, const ImageTex& second, ImageTex **result)
{
	int mipIdx;
	int i;
	char* tmp = (char*)calloc(512, 1);

	*result = new ImageTex(first);
	
	sprintf(tmp, "Product of %s and %s", first.name, second.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));


	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < first.texCount; mipIdx++)
	{
		for (i = 0; i < first.mipDesSize.y * first.mipDesSize.x * 3; i++)
		{
			(*result)->bits[mipIdx][i] = (BYTE)(sqrtf(first.bits[mipIdx][i] / 255.0f * second.bits[mipIdx][i] / 255.0f) * 255);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	free(tmp);

}
void ma_div(const ImageTex& first, const ImageTex& second, ImageTex **result)
{
	int mipIdx;
	int i;
	char* tmp = (char*)calloc(512, 1);

	*result = new ImageTex(first);

	sprintf(tmp, "Division result of %s and %s", first.name, second.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));
	
	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < first.texCount; mipIdx++)
	{
		for (i = 0; i < first.mipDesSize.y * first.mipDesSize.x * 3; i++)
		{
			if (second.bits[mipIdx][i] == 0)
				(*result)->bits[mipIdx][i] = 0;
			else
				(*result)->bits[mipIdx][i] = (BYTE)(first.bits[mipIdx][i] / (float)second.bits[mipIdx][i]);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	free(tmp);

}
void ma_adjusting(const ImageTex& first, ImageTex **result)
{
	int mipIdx;
	int i;
	char* tmp = (char*)calloc(512, 1);
	BYTE mxR=0, mnR=255;
	BYTE mxG = 0, mnG = 255;
	BYTE mxB = 0, mnB = 255;

	*result = new ImageTex(first);

	sprintf(tmp, "Normalized %s", first.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));

	
	for (mipIdx = 0; mipIdx < first.texCount; mipIdx++)
	{
		for (i = 0; i < first.mipDesSize.y * first.mipDesSize.x * 3; i+=3)
		{
			if (i / first.mipSize[mipIdx].x >= first.mipSize[mipIdx].y || i % first.mipSize[mipIdx].x >= first.mipSize[mipIdx].x)
				break;

			mxR = max(mxR, first.bits[mipIdx][i]);
			mnR = min(mnR, first.bits[mipIdx][i]);
			mxG = max(mxG, first.bits[mipIdx][i+1]);
			mnG = min(mnG, first.bits[mipIdx][i+1]);
			mxB = max(mxB, first.bits[mipIdx][i+2]);
			mnB = min(mnB, first.bits[mipIdx][i+2]);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	
	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < first.texCount; mipIdx++)
	{
		for (i = 0; i < first.mipDesSize.y * first.mipDesSize.x * 3; i++)
		{
			if (mxR != mnR)
				(*result)->bits[mipIdx][i] = 255 * (first.bits[mipIdx][i] - mnR) / (mxR - mnR);
			else
				(*result)->bits[mipIdx][i] = 0;

			if (mxG != mnG)
				(*result)->bits[mipIdx][i + 1] = 255 * (first.bits[mipIdx][i + 1] - mnG) / (mxG - mnG);
			else
				(*result)->bits[mipIdx][i + 1] = 0;

			if (mxB != mnB)
				(*result)->bits[mipIdx][i + 2] = 255 * (first.bits[mipIdx][i + 2] - mnB) / (mxB - mnB);
			else
				(*result)->bits[mipIdx][i + 2] = 0;
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	free(tmp);

}
void ma_histEq(const ImageTex& input, ImageTex** result)
{
	int mipIdx;
	int i,x,y;
	long tt = 0;

	char* tmp = (char*)calloc(512, 1);
	long *histR = (long*)calloc(256, sizeof(long));
	long *histG = (long*)calloc(256, sizeof(long));
	long *histB = (long*)calloc(256, sizeof(long));

	int size = input.texSize.y * input.texSize.x;

	
	*result = new ImageTex(input);

	sprintf(tmp, "Equalized %s", input.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));
	//histogram
	for (mipIdx = 0; mipIdx < input.texCount; mipIdx++)
	{
		for (y = 0; y < input.mipDesSize.y; y++)
		{
			for (x = 0; x < input.mipDesSize.x; x++)
			{	
				if (y < input.mipSize[mipIdx].y && x < input.mipSize[mipIdx].x)
				{
					histR[input.bits[mipIdx][y * input.mipDesSize.x * 3 + x * 3 + 0]]++;
					histG[input.bits[mipIdx][y * input.mipDesSize.x * 3 + x * 3 + 1]]++;
					histB[input.bits[mipIdx][y * input.mipDesSize.x * 3 + x * 3 + 2]]++;
					tt++;
				}
			}
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	 
	printf("%-80s\n","Histogram done.");
	//dist.
	for (i = 1; i < 256; i++)
	{
		histR[i] = histR[i] + histR[i - 1];
		histG[i] = histG[i] + histG[i - 1];
		histB[i] = histB[i] + histB[i - 1];		
	}
	//equal
	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < input.texCount; mipIdx++)
	{
		for (i = 0; i < input.mipDesSize.y * input.mipDesSize.x * 3; i+=3)
		{
			(*result)->bits[mipIdx][i + 0] = (BYTE)(255.0f * histR[input.bits[mipIdx][i + 0]] / size);
			(*result)->bits[mipIdx][i + 1] = (BYTE)(255.0f * histG[input.bits[mipIdx][i + 1]] / size);
			(*result)->bits[mipIdx][i + 2] = (BYTE)(255.0f * histB[input.bits[mipIdx][i + 2]] / size);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	free(histR);
	free(histG);
	free(histB);
	free(tmp);

}
void ma_negative(const ImageTex& input, ImageTex** result)
{
	int mipIdx = 0;
	int i = 0;
	char* tmp = (char*)calloc(512, 1);

	*result = new ImageTex(input);

	sprintf(tmp, "Negated %s", input.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));


	#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < input.texCount; mipIdx++)
	{
		for (i = 0; i < input.mipDesSize.y * input.mipDesSize.x * 3; i++)
		{
			(*result)->bits[mipIdx][i] = 255 - input.bits[mipIdx][i];
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");

	free(tmp);
}

BYTE* getPixelAt(ImageTex *img, int x, int y)
{
	int row = y / 512;
	int col = x / 512;
	int mipIdx = row * (int)ceilf(img->texSize.x / 512.0f) + col;
	return &(img->bits[mipIdx][(y % 512) * img->mipDesSize.x * 3 + (x % 512) * 3]);
}
void swapPixels(BYTE* b1, BYTE* b2)
{
	BYTE tmpv[3] = { 0 };

	tmpv[0] = b1[0];
	tmpv[1] = b1[1];
	tmpv[2] = b1[2];

	b1[0] = b2[0];
	b1[1] = b2[1];
	b1[2] = b2[2];

	b2[0] = tmpv[0];
	b2[1] = tmpv[1];
	b2[2] = tmpv[2];
}
void ma_flipH(ImageTex *img)
{
	int i = 0;
	int x, y;//src x and y
	char* tmp = (char*)calloc(512, 1);
	
	sprintf(tmp, "H-flipped %s", img->name);
	strncpy(img->name, tmp, min(511, strlen(tmp) + 1));


#pragma omp parallel for shared(img) private(x)	
	for (y = 0; y < img->texSize.y; y++)
	{
		for (x = 0; x < img->texSize.x / 2 ; x++)
		{
			BYTE* b = getPixelAt(img, x, y);
			BYTE* fb = getPixelAt(img, img->texSize.x - 1 - x, y);

			swapPixels(b, fb);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	img->ready = -1;

	free(tmp);

}
void ma_flipV(ImageTex *img)
{
	int i = 0;
	int x, y;//src x and y
	char* tmp = (char*)calloc(512, 1);

	sprintf(tmp, "V-flipped %s", img->name);
	strncpy(img->name, tmp, min(511, strlen(tmp) + 1));


#pragma omp parallel for shared(img) private(y)	
	for (x = 0; x < img->texSize.x; x++)	
	{
		for (y = 0; y < img->texSize.y / 2; y++)
		{
			BYTE* b = getPixelAt(img, x, y);
			BYTE* fb = getPixelAt(img, x, img->texSize.y - 1 - y);

			swapPixels(b, fb);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");
	img->ready = -1;

	free(tmp);

}
void ma_toGray(const ImageTex& input, ImageTex** result)
{
	int mipIdx = 0;
	int i = 0;
	char* tmp = (char*)calloc(512, 1);
	int c = 0;
	*result = new ImageTex(input);

	sprintf(tmp, "Grayed %s", input.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));


#pragma omp parallel for shared(result) private(i,c)
	for (mipIdx = 0; mipIdx < input.texCount; mipIdx++)
	{
		for (i = 0; i < input.mipDesSize.y * input.mipDesSize.x * 3; i+=3)
		{
			c = (int)(input.bits[mipIdx][i] + input.bits[mipIdx][i + 1] + input.bits[mipIdx][i + 2]) / 3;
			(*result)->bits[mipIdx][i] = (BYTE) (c);
			(*result)->bits[mipIdx][i+1] = (BYTE)(c);
			(*result)->bits[mipIdx][i+2] = (BYTE)(c);
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");

	free(tmp);
}

void ma_extractColor(const ImageTex& input, ImageTex** result, int color)
{
	int mipIdx = 0;
	int i = 0;
	char  ctmp[4] = {'\0'};
	char* tmp = (char*)calloc(512, 1);

	*result = new ImageTex(input);
	
	if ((color & MA_RED) == MA_RED)
		strcat(ctmp, "R");
	if ((color & MA_GREEN) == MA_GREEN)
		strcat(ctmp, "G");
	if ((color & MA_BLUE) == MA_BLUE)
		strcat(ctmp, "B");

	sprintf(tmp, "%s of %s", ctmp, input.name);
	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));


#pragma omp parallel for shared(result) private(i)
	for (mipIdx = 0; mipIdx < input.texCount; mipIdx++)
	{
		for (i = 0; i < input.mipDesSize.y * input.mipDesSize.x * 3-3; i+=3)
		{
			if ((color & MA_RED) == MA_RED)
				(*result)->bits[mipIdx][i+2] = input.bits[mipIdx][i+2];
			if ((color & MA_GREEN)== MA_GREEN)
				(*result)->bits[mipIdx][i+1] = input.bits[mipIdx][i+1];
			if ((color & MA_BLUE) == MA_BLUE)
				(*result)->bits[mipIdx][i+0] =  input.bits[mipIdx][i+0];
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");

	free(tmp);
}
void ma_ColorMap(const ImageTex& input, ImageTex** result, int cm)
{
	int mipIdx = 0;
	int i = 0;
	int c = 0;
	char* tmp = (char*)calloc(512, 1);
	BYTE lu[256][3];
	FILE* f;

	*result = new ImageTex(input);
	if (cm == CM_JET)
		sprintf(tmp, "JET of %s", input.name);
	if (cm == CM_HOT)
		sprintf(tmp, "HEAT of %s", input.name);

	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));

	//load colormap
	switch (cm)
	{
	case CM_JET:
		sprintf(tmp, "%s%c%s", appPath, PATH_SEPARATOR, "colormaps/jet.cm");
		f = fopen(tmp, "r");
		break;
	case CM_HOT:
		sprintf(tmp, "%s%c%s", appPath, PATH_SEPARATOR, "colormaps/hot.cm");
		f = fopen("colormaps/hot.cm", "r");
		break;
	default:
		fprintf(stderr, "%d is wrong color map!", cm);
		return;
	}
	if (!f)
	{
		fprintf(stderr, "File for colormap was not found. Exiting...\n");
		exit(-2);
	}
	fread(lu, 1, 256 * 3, f);
	fclose(f);
	

#pragma omp parallel for shared(result) private(i, c)
	for (mipIdx = 0; mipIdx < input.texCount; mipIdx++)
	{
		for (i = 0; i < input.mipDesSize.y * input.mipDesSize.x * 3 - 3; i += 3)
		{
			c = (int)(input.bits[mipIdx][i + 0] + input.bits[mipIdx][i + 1] + input.bits[mipIdx][i + 2] ) / 3;
			(*result)->bits[mipIdx][i + 0] = lu[c][0];
			(*result)->bits[mipIdx][i + 1] = lu[c][1];
			(*result)->bits[mipIdx][i + 2] = lu[c][2];
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");

	free(tmp);
}

void ma_Rotate(ImageTex* input, ImageTex** result, MA_Rotation r)
{
	int mipIdx = 0;
	int i = 0, j = 0;
	int x = 0, y = 0;
	int c = 0;
	char* tmp = (char*)calloc(512, 1);
	BYTE* b;
	BYTE* fb;

	FILE* f;

	*result = new ImageTex(input->texSize.y, input->texSize.x);
	
	
	if (r == CCW)
		sprintf(tmp, "CCW %s", input->name);
	if (r == CW)
		sprintf(tmp, "CW of %s", input->name);

	strncpy((*result)->name, tmp, min(511, strlen(tmp) + 1));
		

//#pragma omp parallel for shared(result) private(i, c)
	for (y = 0; y < input->texSize.y; y++)
	{
		for (x = 0; x < input->texSize.x; x++)
		{			
			b = getPixelAt(input, x, y);
			if (r == CW)
				fb = getPixelAt(*result, input->texSize.y - 1 - y, x);
			else
				fb = getPixelAt(*result, y, input->texSize.x - 1 - x);
			fb[0] = b[0];
			fb[1] = b[1];
			fb[2] = b[2];
		}
		printf("Processing... %c\r", spc());
		fflush(stdout);
	}
	printf("%-80s\n", "Done.");

	free(tmp);
}



