#version 430 core
layout( binding = 1, r32ui ) uniform uimage2D current;
layout( binding = 2, r32ui ) uniform uimage2D previous;
layout( binding = 3 ) uniform sampler2D displayTexture;
uniform vec2 resolution;
out vec4 fragmentOutput;
void main() {
	// fragmentOutput = texture( displayTexture, gl_FragCoord.xy / resolution );
	fragmentOutput = vec4( vec3( imageLoad( current, ivec2( ( gl_FragCoord.xy / resolution ) * imageSize( current ) ) ).r ), 1.0 );
	fragmentOutput.xyz /= vec3( 3.0, 7.0, 9.0 ) * 1500;
}
