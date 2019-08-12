// Menu items
#ifndef _MENU_H
#define _MENU_H
#include <GL/freeglut.h>

enum MENU_TYPE{
	MENU_RED = 0x1,
	MENU_GREEN = 0x2,
	MENU_BLUE = 0x4,
	MENU_NONE = 0x8,
	MENU_SAVE = 0x10,
	MENU_REMOVE = 0x20,
	MENU_OPEN = 0x21,
	MENU_EQUAL_SIZES = 0x40,
	MENU_ORIENTATION = 0x80,
	MENU_MAGNIFY = 0x100,
	MENU_RESET = 0x200,
	MENU_SUM =  0x400,
	MENU_DIFF = 0x800,
	MENU_MULT = 0x1000,
	MENU_DIV = 0x2000,
	MENU_ADJUST = 0x4000,
	MENU_EQUALIZE = 0x8000,
	MENU_NEGATIVE	= 0x10000,
	MENU_LINKED		= 0x20000 ,
	MENU_FLIPH		= 0x40000,
	MENU_FLIPV		=	0x80000,
	MENU_CREATEPOLYGON = 0x100000,
	MENU_SAVEPOLYGON = 0x100001,
	MENU_DELETEPOLYGON = 0x200000,
	MENU_TOGRAY = 0x400000,
	MENU_TOJET = 0x800000,
	MENU_TOHOT = 0x1000000,
	MENU_90CW = 0x2000000,
	MENU_90CCW = 0x4000000,
};

void initMenu(void (*func)(int));
#endif