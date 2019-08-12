#include "polygons.h"
///////////////////////////////////////////////////////////////////////////////
// GLU_TESS CALLBACKS
///////////////////////////////////////////////////////////////////////////////
extern char PSPMapAlgebraMode[10];
extern int polygonMode_OPCE_TGT;
extern int polygonMode_OPCE_CLT;
extern int polygonMode_StatHistoROI;
extern int polygonMode_MaskArea;
extern int polygonMode_TrainingArea;
extern int TrainingAreaClass;
extern int TrainingAreaClassArray[20];

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
	
	if (strcmp(PSPMapAlgebraMode, "original") == 0)	glColor4d(0,1,0,0.5);
	if (strcmp(PSPMapAlgebraMode, "OPCE") == 0)
	{
		if (polygonMode_OPCE_TGT) glColor4d(1,0,0,0.5);
		if (polygonMode_OPCE_CLT) glColor4d(0,0,1,0.5);
	}	
	if (strcmp(PSPMapAlgebraMode, "StatHistoROI") == 0)	glColor4d(1,0,0,0.5);
	if (strcmp(PSPMapAlgebraMode, "MaskArea") == 0)	glColor4d(1,0,0,0.5);
	if (strcmp(PSPMapAlgebraMode, "TrainingArea") == 0) 
	{
		if (TrainingAreaClass == 1) glColor4f(1.,0.,0.,0.5);
		if (TrainingAreaClass == 2) glColor4f(0.,1.,0.,0.5);
		if (TrainingAreaClass == 3) glColor4f(0.,0.,1.,0.5);
		if (TrainingAreaClass == 4) glColor4f(1.,1.,0.,0.5);
		if (TrainingAreaClass == 5) glColor4f(1.,0.5,0.,0.5);
		if (TrainingAreaClass == 6) glColor4f(0.,0.5,0.,0.5);
		if (TrainingAreaClass == 7) glColor4f(0.,1.,1.,0.5);
		if (TrainingAreaClass == 8) glColor4f(1.,0.5,1.,0.5);
		if (TrainingAreaClass == 9) glColor4f(0.5,0.25,0.,0.5);
		if (TrainingAreaClass == 10) glColor4f(0.75,0.75,0.75,0.5);
		if (TrainingAreaClass == 11) glColor4f(1.,1.,1.,0.5);
		if (TrainingAreaClass == 12) glColor4f(0.6,0.6,0.5,0.5);
		if (TrainingAreaClass == 13) glColor4f(1.,0.,0.5,0.5);
		if (TrainingAreaClass == 14) glColor4f(1.,0.7,0.5,0.5);
		if (TrainingAreaClass == 15) glColor4f(0.5,0.5,0.5,0.5);
		if (TrainingAreaClass == 16) glColor4f(0.5,0.,1.,0.5);
	}
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
	gluTessCallback(tess, GLU_TESS_COMBINE, (void(__stdcall*)(void))tessCombineCB);

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
		glColor4d(1, 0, 0, 1.0);
		
		glBegin(GL_LINE_LOOP);
		for (std::list<FPOINT>::iterator it = polygon.begin(); it != polygon.end(); ++it)
		{
			glVertex3f(it->x, it->y, 0.1f);
		}
		glVertex3f(world.x, world.y, 0.1f);
		glEnd();
		
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
	
	if (name != NULL && (hFile = fopen(name, "w")) != NULL)
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
void savePolygonToFile_OPCE(std::vector<std::list<FPOINT> > polygons_TGT, std::vector<std::list<FPOINT> > polygons_CLT, const char* name)
{
	FILE* hFile;  
	
	if (name != NULL && (hFile = fopen(name, "w")) != NULL)
	{	
		fprintf(hFile, "NB_TRAINING_TARGET_CLUTTER_CLASSES\n");
		fprintf(hFile, "2\n");
		fprintf(hFile, "--------------\n");
		
		fprintf(hFile, "TRAINING_TARGET_CLASS\n");
		fprintf(hFile, "Nb_Training_Areas\n");
		fprintf(hFile, "1\n");
		fprintf(hFile, "--------------\n");
		for (size_t i = 0; i < polygons_TGT.size(); i++)
		{
		fprintf(hFile, "Nb_Tie_Points\n%d\n", polygons_TGT.at(i).size());
		for (std::list<FPOINT>::iterator it = polygons_TGT.at(i).begin(); it != polygons_TGT.at(i).end(); ++it)
			{
			fprintf(hFile, "Tie_Point\n");
			fprintf(hFile, "Row\n");
			fprintf(hFile, "%d\n", (int)(it->y));
			fprintf(hFile, "Col\n");
			fprintf(hFile, "%d\n", (int)(it->x));
			}
		}
		fprintf(hFile, "--------------\n");
			
		fprintf(hFile, "TRAINING_CLUTTER_CLASS\n");
		fprintf(hFile, "Nb_Training_Areas\n");
		fprintf(hFile, "1\n");
		fprintf(hFile, "--------------\n");
		for (size_t i = 0; i < polygons_CLT.size(); i++)
		{
		fprintf(hFile, "Nb_Tie_Points\n%d\n", polygons_CLT.at(i).size());
		for (std::list<FPOINT>::iterator it = polygons_CLT.at(i).begin(); it != polygons_CLT.at(i).end(); ++it)
			{
			fprintf(hFile, "Tie_Point\n");
			fprintf(hFile, "Row\n");
			fprintf(hFile, "%d\n", (int)(it->y));
			fprintf(hFile, "Col\n");
			fprintf(hFile, "%d\n", (int)(it->x));
			}
		}
		fprintf(hFile, "--------------\n");
		fclose(hFile);
		fprintf(stderr, "Polygon saved.\n");
	}
	else
	{
		fprintf(stderr, "Polygon not saved.\n");
	}
}
void savePolygonToFile_StatHistoROI(std::vector<std::list<FPOINT> > polygons_StatHistoROI, const char* name)
{
	FILE* hFile;  
	
	if (name != NULL && (hFile = fopen(name, "w")) != NULL)
	{	
		//fprintf(hFile, "STAT_HISTO_ROI_AREAS\n");
		for (size_t i = 0; i < polygons_StatHistoROI.size(); i++)
		{
		fprintf(hFile, "Nb_Tie_Points\n%d\n", polygons_StatHistoROI.at(i).size());
		for (std::list<FPOINT>::iterator it = polygons_StatHistoROI.at(i).begin(); it != polygons_StatHistoROI.at(i).end(); ++it)
			{
			fprintf(hFile, "Tie_Point\n");
			fprintf(hFile, "Row\n");
			fprintf(hFile, "%d\n", (int)(it->y));
			fprintf(hFile, "Col\n");
			fprintf(hFile, "%d\n", (int)(it->x));
			}
		}
		fprintf(hFile, "--------------\n");
		fclose(hFile);
		fprintf(stderr, "Polygon saved.\n");
	}
	else
	{
		fprintf(stderr, "Polygon not saved.\n");
	}
}
void savePolygonToFile_MaskArea(std::vector<std::list<FPOINT> > polygons_MaskArea, const char* name)
{
	FILE* hFile;  
	
	if (name != NULL && (hFile = fopen(name, "w")) != NULL)
	{	
		fprintf(hFile, "MASK_AREAS_DEFINITION\n");
		fprintf(hFile, "Nb_Mask_Areas\n%d\n", polygons_MaskArea.size());
		fprintf(hFile, "--------------\n");
		for (size_t i = 0; i < polygons_MaskArea.size(); i++)
		{
			fprintf(hFile, "Nb_Tie_Points\n%d\n", polygons_MaskArea.at(i).size());
			for (std::list<FPOINT>::iterator it = polygons_MaskArea.at(i).begin(); it != polygons_MaskArea.at(i).end(); ++it)
			{
				fprintf(hFile, "Tie_Point\n");
				fprintf(hFile, "Row\n");
				fprintf(hFile, "%d\n", (int)(it->y));
				fprintf(hFile, "Col\n");
				fprintf(hFile, "%d\n", (int)(it->x));
			}
			fprintf(hFile, "--------------\n");
		}
		fclose(hFile);
		fprintf(stderr, "Polygon saved.\n");
	}
	else
	{
		fprintf(stderr, "Polygon not saved.\n");
	}
}
void savePolygonToFile_TrainingArea(std::vector<std::list<FPOINT> > polygons_TrainingArea, const char* name)
{
	FILE* hFile;  
	size_t i = 0;
	int ii, jj;
	
	if (name != NULL && (hFile = fopen(name, "w")) != NULL)
	{	
		fprintf(hFile, "NB_TRAINING_CLASSES\n");
		fprintf(hFile, "%d\n", TrainingAreaClass);
		fprintf(hFile, "--------------\n");
		for (ii = 1; ii <= TrainingAreaClass; ii++)
		{
			fprintf(hFile, "TRAINING_CLASS\n");
			fprintf(hFile, "Nb_Training_Areas\n");
			fprintf(hFile, "%d\n", TrainingAreaClassArray[ii]);
			fprintf(hFile, "--------------\n");
			for (jj = 0; jj < TrainingAreaClassArray[ii]; jj++)
			{
				fprintf(hFile, "Nb_Tie_Points\n%d\n", polygons_TrainingArea.at(i).size());
				for (std::list<FPOINT>::iterator it = polygons_TrainingArea.at(i).begin(); it != polygons_TrainingArea.at(i).end(); ++it)
				{
					fprintf(hFile, "Tie_Point\n");
					fprintf(hFile, "Row\n");
					fprintf(hFile, "%d\n", (int)(it->y));
					fprintf(hFile, "Col\n");
					fprintf(hFile, "%d\n", (int)(it->x));
				}
				fprintf(hFile, "--------------\n");
				i++;
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