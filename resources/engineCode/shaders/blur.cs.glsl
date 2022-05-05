#version 430
layout( local_size_x = 8, local_size_y = 8, local_size_z = 1 ) in;
layout( binding = 1, r32ui ) uniform uimage2D current;
layout( binding = 2, r32ui ) uniform uimage2D previous;

precision highp int;	// g might overflow? not sure if this fixes that
// also 32 bits gives you some significant headroom

uniform float decay_factor; // tbd, maybe constant, as below

void main() {
	ivec2 pos = ivec2( gl_GlobalInvocationID.xy );

	// shitty lil gaussian kernel - just want something to diffuse outwards
	float g = (
		1.0 * imageLoad( previous, pos + ivec2( -1, -1 ) ).r +
		1.0 * imageLoad( previous, pos + ivec2( -1,  1 ) ).r +
		1.0 * imageLoad( previous, pos + ivec2(  1, -1 ) ).r +
		1.0 * imageLoad( previous, pos + ivec2(  1,  1 ) ).r +
		2.0 * imageLoad( previous, pos + ivec2(  0,  1 ) ).r +
		2.0 * imageLoad( previous, pos + ivec2(  0, -1 ) ).r +
		2.0 * imageLoad( previous, pos + ivec2(  1,  0 ) ).r +
		2.0 * imageLoad( previous, pos + ivec2( -1,  0 ) ).r +
		4.0 * imageLoad( previous, pos + ivec2(  0,  0 ) ).r ) / 16.0;

	imageStore( current, pos, uvec4( uint( 0.99 * g ) ) );
}
