#ifndef INCLUDES
#define INCLUDES

#include <stdio.h>

// stl includes
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <cstdlib>
#include <ctime>
#include <deque>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <numeric>
#include <random>
#include <sstream>
#include <string>
#include <vector>

// iostream stuff
using std::cerr;
using std::cin;
using std::cout;
using std::endl;
using std::flush;

// pi definition - definitely sufficient precision
constexpr double pi = 3.14159265358979323846;

// MSAA count - effects OpenGL geometry evaluation
constexpr int MSAACount = 1;

// vector math library GLM
#define GLM_FORCE_SWIZZLE
#define GLM_SWIZZLE_XYZW
#include "../GLM/glm.hpp"                  //general vector types
#include "../GLM/gtc/matrix_transform.hpp" // for glm::ortho
#include "../GLM/gtc/type_ptr.hpp"         //to send matricies gpu-side
#include "../GLM/gtx/rotate_vector.hpp"
#include "../GLM/gtx/transform.hpp"

// not sure as to the utility of this
#define GLX_GLEXT_PROTOTYPES

// OpenGL Loader
#include "../ImGUI/gl3w.h"

// GUI library (dear ImGUI)
#include "../ImGUI/TextEditor.h"
#include "../ImGUI/imgui.h"
#include "../ImGUI/imgui_impl_sdl.h"
#include "../ImGUI/imgui_impl_opengl3.h"

// SDL includes - windowing, gl context, system info
#include <SDL2/SDL.h>
#include <SDL2/SDL_opengl.h>

// png loading library - very powerful
#include "../LodePNG/lodepng.h"

// wrapper for TinyOBJLoader
#include "../TinyOBJLoader/objLoader.h"

// shader compilation wrapper
#include "shaders/shader.h"

// coloring of CLI output
#include "../fonts/colors.h"

// diamond square heightmap generation
#include "../noise/diamondSquare/diamond_square.h"

// Brent Werness' Voxel Automata Terrain
#include "../noise/VAT/VAT.h"

// more general noise solution
#include "../noise/FastNoise2/include/FastNoise/FastNoise.h"

// Niels Lohmann - JSON for Modern C++
#include "../JSON/json.hpp"
using json = nlohmann::json;

#define WIDTH 640
#define HEIGHT 480

#endif
