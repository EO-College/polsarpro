#include <sys/stat.h>
#include <stdio.h>
#include <string.h>
#include <FreeImage.h>

#ifndef _KSUTILS
#define _KSUTILS

#define MAJORVERSION 1
#define MINORVERSION 1

#ifndef MAX_PATH
#define MAX_PATH 4096
#endif

#ifdef WIN32
#ifndef __WIN32
#define __WIN32
#endif
#endif

#ifndef __WIN32
#define PATH_SEPARATOR '/'

typedef struct _POINT {
	int x;
	int y;
} POINT;

typedef struct _COORD {
	short X;
	short Y;
} COORD, *PCOORD;

typedef struct _MOUSE_EVENT_RECORD {
	COORD dwMousePosition;
	int dwButtonState;
	int  dwControlKeyState;
	int  dwEventFlags;
} MOUSE_EVENT_RECORD;

#else 
#define PATH_SEPARATOR '\\' 
#include <unistd.h>
#endif 

#define tmpFile "mapalgebrapaths.tmp"

typedef struct _FPOINT{
	float x;
	float y;
}FPOINT;
typedef struct _FPOINT3{
	float x;
	float y;
	float z;
}FPOINT3;
typedef struct _POINT3{
	int x;
	int y;
	int z;
}POINT3;

int fileExists(char* sciezka);
char spc();
void tempFileRemove();

/*Modif EP - start*/
void PSP_check_file(char *file);
void PSP_check_dir(char *dir);
/*Modif EP - end*/

#endif