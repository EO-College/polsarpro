#include "vmenu.h"

void initMenu(void (*menuCallback)(int))
{

	int rgbmenu = glutCreateMenu(menuCallback);
	glutAddMenuEntry("Gray", MENU_TOGRAY);
	glutAddMenuEntry("Red", MENU_RED);
	glutAddMenuEntry("Green", MENU_GREEN);
	glutAddMenuEntry("Blue", MENU_BLUE);
	glutAddMenuEntry("Red + Green", MENU_RED | MENU_GREEN);
	glutAddMenuEntry("Red + Blue", MENU_RED | MENU_BLUE);
	glutAddMenuEntry("Green + Blue", MENU_GREEN | MENU_BLUE);

	int colormaps = glutCreateMenu(menuCallback);	
	glutAddMenuEntry("Jet", MENU_TOJET);
	glutAddMenuEntry("Hot", MENU_TOHOT);	

	int flips = glutCreateMenu(menuCallback);
	glutAddMenuEntry("Flip Horizontal", MENU_FLIPH);
	glutAddMenuEntry("Flip Vertical", MENU_FLIPV);
	glutAddMenuEntry("Rotate 90 CW", MENU_90CW);
	glutAddMenuEntry("Rotate 90 CCW", MENU_90CCW);

	glutCreateMenu(menuCallback);

	glutAddMenuEntry("[MENU]", 0);//to avoid triggering first option 
	glutAddMenuEntry("Toggle orientation", MENU_ORIENTATION);
	glutAddMenuEntry("Toggle link", MENU_LINKED);
	glutAddMenuEntry("Toggle magnifying glass", MENU_MAGNIFY);
	glutAddMenuEntry("----------------------", 0);
	glutAddSubMenu("Flip or Rotate", flips);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Create new polygon...", MENU_CREATEPOLYGON);
	glutAddMenuEntry("Save polygons...", MENU_SAVEPOLYGON);
	glutAddMenuEntry("Delete last polygon...", MENU_DELETEPOLYGON);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Add this to...",MENU_SUM);
	glutAddMenuEntry("Substract from this...", MENU_DIFF);
	glutAddMenuEntry("Multiply this...",MENU_MULT);
	glutAddMenuEntry("Divide this by...",MENU_DIV);
	glutAddMenuEntry("Adjust this", MENU_ADJUST);
	glutAddMenuEntry("Equalize this", MENU_EQUALIZE);
	glutAddMenuEntry("Negate this", MENU_NEGATIVE);
	glutAddSubMenu("Color/Channel", rgbmenu);
	glutAddSubMenu("Colormaps", colormaps);
    //glutAddMenuEntry("Remove...", MENU_REMOVE);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Open image", MENU_OPEN);
    glutAddMenuEntry("Save this image", MENU_SAVE);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Close this image", MENU_REMOVE);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Reset", MENU_RESET);
	glutAddMenuEntry("Cancel", MENU_NONE);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
}

