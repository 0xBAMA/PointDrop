#version 430
layout( local_size_x = 8, local_size_y = 8, local_size_z = 1 ) in;
layout( binding = 1, r32ui ) uniform uimage2D current;
layout( binding = 2, r32ui ) uniform uimage2D previous;

// need to pass in number? maybe vertex shader is better... index with gl_VertexID * 2
layout( binding = 0, std430 ) buffer agent_data {
	vec3 data[];	// [position0, velocity0], [position1, velocity1], ...
};

void main() {
	ivec2 pos = ivec2( gl_GlobalInvocationID.xy );
}
