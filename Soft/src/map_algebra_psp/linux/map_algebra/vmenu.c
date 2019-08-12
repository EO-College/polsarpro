#include "vmenu.h"

void initMenu_Original(void (*menuCallback)(int))
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

	glutAddMenuEntry("[MENU]", 0);
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
	glutAddMenuEntry("----------------------", 0);
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

void initMenu_Display(void (*menuCallback)(int))
{
	glutCreateMenu(menuCallback);

	glutAddMenuEntry("[MENU]", 0);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Magnifying glass", MENU_MAGNIFY);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Close this image", MENU_REMOVE);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void initMenu_Process(void (*menuCallback)(int))
{
	glutCreateMenu(menuCallback);
	glutAddMenuEntry("No menu avalaible in this mode", 0);
	glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void initMenu_OPCE(void (*menuCallback)(int))
{
	glutCreateMenu(menuCallback);

	glutAddMenuEntry("[MENU]", 0);//to avoid triggering first option 
	glutAddMenuEntry("--- Target -----------", 0);
	glutAddMenuEntry("Select target area...", MENU_OPCE_CREATEPOLYGON_TGT);
	glutAddMenuEntry("Delete target area...", MENU_OPCE_DELETEPOLYGON_TGT);
	glutAddMenuEntry("--- Clutter -----------", 0);
	glutAddMenuEntry("Select clutter area...", MENU_OPCE_CREATEPOLYGON_CLT);
	glutAddMenuEntry("Delete clutter area...", MENU_OPCE_DELETEPOLYGON_CLT);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Save configuration...", MENU_OPCE_SAVEPOLYGON);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void initMenu_StatHistoROI(void (*menuCallback)(int))
{
	glutCreateMenu(menuCallback);

	glutAddMenuEntry("[MENU]", 0);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Select area...", MENU_StatHistoROI_CREATEPOLYGON);
	glutAddMenuEntry("Delete area...", MENU_StatHistoROI_DELETEPOLYGON);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Save configuration...", MENU_StatHistoROI_SAVEPOLYGON);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void initMenu_MaskArea(void (*menuCallback)(int))
{
	glutCreateMenu(menuCallback);

	glutAddMenuEntry("[MENU]", 0); 
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Select new mask area...", MENU_MaskArea_CREATEPOLYGON);
	glutAddMenuEntry("Delete last mask area...", MENU_MaskArea_DELETEPOLYGON);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Save configuration...", MENU_MaskArea_SAVEPOLYGON);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
}

void initMenu_TrainingArea(void (*menuCallback)(int))
{
	glutCreateMenu(menuCallback);

	glutAddMenuEntry("[MENU]", 0); 
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Add a new class...", MENU_TrainingArea_ADDCLASS);
	glutAddMenuEntry("Select area...", MENU_TrainingArea_CREATEPOLYGON);
	glutAddMenuEntry("Delete area...", MENU_TrainingArea_DELETEPOLYGON);
	glutAddMenuEntry("----------------------", 0);
	glutAddMenuEntry("Save configuration...", MENU_TrainingArea_SAVEPOLYGON);

	glutAttachMenu(GLUT_RIGHT_BUTTON);
}
