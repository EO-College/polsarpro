#include "polygons.h"
///////////////////////////////////////////////////////////////////////////////
// GLU_TESS CALLBACKS
///////////////////////////////////////////////////////////////////////////////
#ifndef CALLBACK
#define CALLBACK
#endif

void CALLBACK tessBeginCB(GLenum which)
{
	glBegin(which);
}



void CALLBACK tessEndCB()
{
	glEnd();
}

void CALLBACK tessVertexCB(const GLvoid *data)
{
	// cast back to double type
	const GLdouble *ptr = (const GLdouble*)data;
	
	glColor4d(0,1,0,0.5);
	glVertex3dv(ptr);
}
void CALLBACK tessErrorCB(GLenum errorCode)
{
	const GLubyte *errorStr;

	errorStr = gluErrorString(errorCode);
	fprintf(stderr, "\n[ERROR]: %s\n" , errorStr );
}


std::list<GLdouble*> v;

void CALLBACK tessCombineCB(const GLdouble newVertex[3], const GLdouble *neighborVertex[4],
	const GLfloat neighborWeight[4], GLdouble **outData)
{	
	GLdouble* vx = (GLdouble*)calloc(3, sizeof(GLdouble));
	vx[0] = newVertex[0];
	vx[1] = newVertex[1];
	vx[2] = newVertex[2];
	v.push_back(vx); 
	*outData = vx;
}

///////////////////////////////////////////////////////////////////////////////


void tesselatePolygon(std::list<FPOINT> polygon, GLuint *id)
{
	// create tessellator
	GLUtesselator *tess = gluNewTess();
	if (!*id)
		glDeleteLists(*id,1);
		
	*id = glGenLists(1);  // create a display list

	if (!*id) exit(-4);          // failed to create a list, return 0

	GLdouble **tab = (GLdouble**)calloc(polygon.size(), sizeof(GLdouble));
	for (uint i = 0; i < polygon.size(); i++)
		tab[i] = (GLdouble*)calloc(3, sizeof(GLdouble));

	// register callback functions
	gluTessCallback(tess, GLU_TESS_BEGIN, (void (CALLBACK *)())tessBeginCB);
	gluTessCallback(tess, GLU_TESS_END, (void (CALLBACK *)())tessEndCB);
	gluTessCallback(tess, GLU_TESS_ERROR, (void (CALLBACK *)())tessErrorCB);
	gluTessCallback(tess, GLU_TESS_VERTEX, (void (CALLBACK *)())tessVertexCB);
	gluTessCallback(tess, GLU_TESS_COMBINE, (void(CALLBACK *)())tessCombineCB);

	gluTessProperty(tess, GLU_TESS_WINDING_RULE, GLU_TESS_WINDING_POSITIVE);
	glNewList(*id, GL_COMPILE);
	glColor3f(1, 1, 1);
	gluTessBeginPolygon(tess, 0);                   // with NULL data
	gluTessBeginContour(tess);

	int ind = 0;
	for (std::list<FPOINT>::iterator it = polygon.begin(); it != polygon.end(); ++it)
	{
		//glVertex3f(it->x, it->y, 0.1f);
		tab[ind][0] = it->x;
		tab[ind][1] = it->y;
		tab[ind][2] = 0.5;
		gluTessVertex(tess, tab[ind], tab[ind]);
		ind++;
	}


	gluTessEndContour(tess);
	gluTessEndPolygon(tess);
	glEndList();

	gluDeleteTess(tess);        // safe to delete after tessellation
	for (uint i = 0; i < polygon.size(); i++)
		free(tab[i]);
	free(tab);
	v.clear();

}
void drawPolygon(GLuint id, std::list<FPOINT> polygon, FPOINT world, int drawing)
{
	if (id)
	{
		glCallList(id);
	}			  
	if (drawing)
	{
		glLineWidth(2);
		glColor4d(0, 1, 0, 1);
		glBegin(GL_LINE_LOOP);
		for (std::list<FPOINT>::iterator it = polygon.begin(); it != polygon.end(); ++it)
		{
			glVertex3f(it->x, it->y, 0.1f);
		}
		glVertex3f(world.x, world.y, 0.1f);
		glEnd();
		
		glColor4d(1, 0, 0, 1.0);

		glPointSize(5);
		glBegin(GL_POINTS);
		for (std::list<FPOINT>::iterator it = polygon.begin(); it != polygon.end(); ++it)
		{
			glVertex3f(it->x, it->y, 0.1f);
		}		
		glEnd();
		glLineWidth(1);
	}
}
void savePolygonToFile(std::vector<std::list<FPOINT> > polygons, const char* name)
{
	FILE* hFile;  
	
	if (name!=NULL && (hFile = fopen(name, "w")) != NULL)
	{	

		for (size_t i = 0; i < polygons.size(); i++)
		{
			fprintf(hFile, "Polygon %d\n",i);
			fprintf(hFile, "Points: %d\n", polygons.at(i).size());

			for (std::list<FPOINT>::iterator it = polygons.at(i).begin(); it != polygons.at(i).end(); ++it)
			{
				fprintf(hFile, "%.5lf\t%.5lf\n", it->x, it->y);
			}
		}
		fclose(hFile);
		fprintf(stderr, "Polygon saved.\n");
	}
	else
	{
		fprintf(stderr, "Polygon not saved.\n");
	}

}

