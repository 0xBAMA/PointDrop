#ifndef ENGINE
#define ENGINE

#include "includes.h"

class engine {
public:
	engine()  { init(); }
	~engine() { quit(); }

	bool mainLoop(); // called from main

private:
	// application handles + basic data
	// windowHandler w;
	SDL_Window * window;
	SDL_GLContext GLcontext;
	int totalScreenWidth, totalScreenHeight;
	ImVec4 clearColor;

	// OpenGL data
	GLuint displayTexture;
	GLuint displayShader;
	GLuint displayVAO;


	//points participating in the sim - sizes the dispatch + SSBO
	int numPoints 			= 1000;
	int pointFieldSize 	= 1000;

	// SSBO to hold point locations
	GLuint pointSSBO;
	// image buffer for atomic writes - blur between updates???? FUCK YES
	GLuint pointWriteBuffers[ 2 ]; // ping pong pair - for color we need one per channel

	// shader to handle the point action - vertex or compute, what makes more sense?
	GLuint pointHandlerShader;
	// shader to progressively blur the buffer result
	// -> skip the main loop swap for non-progressive ( single blur pass per invocation )
	GLuint blurShader;


	// initialization
	void init();
	void startMessage();
	void createWindowAndContext();
	void displaySetup();
	void computeShaderCompile();
	void imguiSetup();

	// main loop functions
	void mainDisplay();
	void handleEvents();
	void clear();
	void imguiPass();
	void imguiFrameStart();
	void imguiFrameEnd();
	void drawTextEditor();
	void quitConf( bool *open );

	// shutdown procedures
	void imguiQuit();
	void SDLQuit();
	void quit();

	// program flags
	bool quitConfirm = false;
	bool pQuit = false;

};

#endif
