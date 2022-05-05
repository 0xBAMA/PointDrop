#version 430
layout( local_size_x = 64, local_size_y = 1, local_size_z = 1 ) in;
layout( binding = 1, r32ui ) uniform uimage2D current;
layout( binding = 2, r32ui ) uniform uimage2D previous;

// need to pass in number? maybe vertex shader is better... index with gl_VertexID * 2
layout( binding = 0, std430 ) buffer agent_data {
	vec3 data[];	// [position0, velocity0], [position1, velocity1], ...
};

void main() {
	vec3 position = data[ gl_LocalInvocationIndex * 2 ];
	data[ gl_LocalInvocationIndex * 2 ].xy += vec2( 0.01 );

	ivec2 writeLocation = ivec2( ( position.xy + vec2( 1.0 ) ) * ( imageSize( current ) / 2 ) );

	imageAtomicAdd( current, writeLocation, 50000 );
}
