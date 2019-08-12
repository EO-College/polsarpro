#include <gl/freeglut.h>
#include <list>
#include <vector>
#include "utils.h"

typedef unsigned int uint;

void tesselatePolygon(std::list<FPOINT> polygon, GLuint *id);
void drawPolygon(GLuint id, std::list<FPOINT> polygon, FPOINT world, int drawing);
void savePolygonToFile(std::vector<std::list<FPOINT> > polygon, const char* name);
