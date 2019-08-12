#include <gl/freeglut.h>
#include <list>
#include <vector>
#include "utils.h"

typedef unsigned int uint;

void tesselatePolygon(std::list<FPOINT> polygon, GLuint *id);
void drawPolygon(GLuint id, std::list<FPOINT> polygon, FPOINT world, int drawing);
void savePolygonToFile(std::vector<std::list<FPOINT> > polygon, const char* name);
void savePolygonToFile_OPCE(std::vector<std::list<FPOINT> > polygon_TGT, std::vector<std::list<FPOINT> > polygon_CLT, const char* name);
void savePolygonToFile_StatHistoROI(std::vector<std::list<FPOINT> > polygon_StatHistoROI, const char* name);
void savePolygonToFile_MaskArea(std::vector<std::list<FPOINT> > polygon_MaskArea, const char* name);
void savePolygonToFile_TrainingArea(std::vector<std::list<FPOINT> > polygon_TrainingArea, const char* name);
