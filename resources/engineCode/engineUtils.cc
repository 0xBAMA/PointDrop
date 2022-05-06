#include "engine.h"

bool engine::mainLoop() {
	// compute passes here
		// invoke any shaders you want to use to do work on the GPU
	computePasses();

	// clear the screen and depth buffer
	clear();

	// fullscreen triangle copying the image
	mainDisplay();

	// do all the gui stuff
	imguiPass();

	// swap the double buffers to present
	SDL_GL_SwapWindow( window );

	// handle all events
	handleEvents();

	// break main loop when pQuit turns true
	return pQuit;
}

void engine::computePasses(){
	static float timer = 0.0;
	timer += 0.001;


	// new point writes
	glUseProgram( pointHandlerShader );
	glUniform2i( glGetUniformLocation( pointHandlerShader, "computeDimensions" ), computeDimensions.x, computeDimensions.y );
	glUniform1f( glGetUniformLocation( pointHandlerShader, "time" ), timer );
	glDispatchCompute( computeDimensions.x / 16, computeDimensions.y / 16, 1 );
	glMemoryBarrier( GL_SHADER_IMAGE_ACCESS_BARRIER_BIT );

	//swap the images
	std::swap( pointWriteBuffers[ 0 ], pointWriteBuffers[ 1 ]);
	glBindImageTexture( 1, pointWriteBuffers[ 0 ], 0, GL_FALSE, 0, GL_READ_WRITE, GL_R32UI );
	glBindImageTexture( 2, pointWriteBuffers[ 1 ], 0, GL_FALSE, 0, GL_READ_WRITE, GL_R32UI );

	// blur the buffer
	glUseProgram( blurShader );
	glDispatchCompute( pointFieldSize / 8, pointFieldSize / 8, 1 );
	glMemoryBarrier( GL_SHADER_IMAGE_ACCESS_BARRIER_BIT );
}

void engine::clear() {
	// clear the screen
	glClearColor( clearColor.x, clearColor.y, clearColor.z, clearColor.w ); // from hsv picker
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void engine::mainDisplay() {
	// texture display
	ImGuiIO &io = ImGui::GetIO();
	glUseProgram( displayShader );
	glBindVertexArray( displayVAO );
	glUniform2f( glGetUniformLocation( displayShader, "resolution" ), io.DisplaySize.x, io.DisplaySize.y );
	glDrawArrays( GL_TRIANGLES, 0, 3 );
}

void engine::imguiPass() {
	// start the imgui frame
	imguiFrameStart();

	// show the demo window
	static bool showDemoWindow = !true;
	if ( showDemoWindow )
		ImGui::ShowDemoWindow( &showDemoWindow );

	// show quit confirm window
	quitConf( &quitConfirm );

	// finish up the imgui stuff and put it in the framebuffer
	imguiFrameEnd();
}


void engine::handleEvents() {
	SDL_Event event;
	while ( SDL_PollEvent( &event ) ) {
		// imgui event handling
		ImGui_ImplSDL2_ProcessEvent( &event );

		if ( event.type == SDL_QUIT )
			pQuit = true;

		if ( event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID( window ) )
			pQuit = true;

		if ( ( event.type == SDL_KEYUP && event.key.keysym.sym == SDLK_ESCAPE) || ( event.type == SDL_MOUSEBUTTONDOWN && event.button.button == SDL_BUTTON_X1 ))
			quitConfirm = !quitConfirm; // x1 is browser back on the mouse

		if ( event.type == SDL_KEYUP && event.key.keysym.sym == SDLK_ESCAPE && SDL_GetModState() & KMOD_SHIFT )
			pQuit = true; // force quit on shift+esc ( bypasses confirm window )

		if ( event.type == SDL_KEYUP && event.key.keysym.sym == SDLK_SPACE )
			sendRandomPointData(); // reinit SSBO
	}
}
