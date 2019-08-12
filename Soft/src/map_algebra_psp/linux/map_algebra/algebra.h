#ifndef ALGEBRA_H
#define ALGEBRA_H

#include "textures.h"
#include "utils.h"

typedef struct OperationInput
{
	int pendingOp;
	ImageTex* first;
	ImageTex* second;
	ImageTex** result;
	int parameters;

}OperationInput;

enum MA_Operation
{
	MA_RED = 0x1,
	MA_GREEN = 0x2,
	MA_BLUE = 0x4,
	MA_SUM=0x8,
	MA_DIFFERENCE=0x10,
	MA_MULTIPLICATION=0x20,
	MA_DIVISION=0x40,
	MA_ADJUST=0x80,
	MA_EQUALIZE=0x100,
	MA_NEGATIVE=0x200,
	MA_FLIPH=0x400,
	MA_FLIPV=0x800,	
	MA_TOGRAY=0x1000,
	MA_COLORMAP = 0x2000,
	MA_COLOR = 0x4000,
	MA_90CW = 0x8000,
	MA_90CCW = 0x10000
};
enum MA_Color
{
	MC_RED = 1,
	MC_GREEN = 2,
	MC_BLUE = 4
};
enum MA_ColorMap
{
	CM_JET = 1,
	CM_HOT = 2
};

enum MA_Rotation
{
	CCW = 0,
	CW = 1
};

void performMAOperation(OperationInput* op);

void ma_sum(const ImageTex& first, const  ImageTex& second, ImageTex** result);
void ma_diff(const ImageTex& first, const  ImageTex& second, ImageTex** result);
void ma_mult(const ImageTex& first, const  ImageTex& second, ImageTex** result);
void ma_div(const ImageTex& first, const ImageTex& second, ImageTex** result);
void ma_adjusting(const ImageTex& first, ImageTex** result);
void ma_histEq(const ImageTex& first, ImageTex** result);
void ma_negative(const ImageTex& input, ImageTex** result);
void ma_flipH(ImageTex*img);
void ma_flipV(ImageTex*img);
void ma_extractColor(const ImageTex& input, ImageTex** result, int color);
void ma_toGray(const ImageTex& input, ImageTex** result);
void ma_ColorMap(const ImageTex& input, ImageTex** result, int cm);
void ma_Rotate(ImageTex* input, ImageTex** result, MA_Rotation c);
#endif
