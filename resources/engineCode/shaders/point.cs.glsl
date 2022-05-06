#version 430
layout( local_size_x = 16, local_size_y = 16, local_size_z = 1 ) in;
layout( binding = 1, r32ui ) uniform uimage2D current;
layout( binding = 2, r32ui ) uniform uimage2D previous;

uniform ivec2 computeDimensions;
uniform float time;

// need to pass in number? maybe vertex shader is better... index with gl_VertexID * 2
layout( binding = 0, std430 ) buffer agent_data {
	vec4 data[];	// [position0, velocity0], [position1, velocity1], ...
};

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

float de(vec3 p){
	p *= 30.0;
	const int iterations = 20;
	float d = -2.; // vary this parameter, range is like -20 to 20
	p=p.yxz;
	pR(p.yz, 1.570795);
	p.x += 6.5;
	p.yz = mod(abs(p.yz)-.0, 20.) - 10.;
	float scale = 1.25;
	p.xy /= (1.+d*d*0.0005);

	float l = 0.;
	for (int i=0; i < iterations; i++) {
		p.xy = abs(p.xy);
		p = p*scale + vec3(-3. + d*0.0095,-1.5,-.5);
		pR(p.xy,0.35-d*0.015);
		pR(p.yz,0.5+d*0.02);
		vec3 p6 = p*p*p; p6=p6*p6;
		l =pow(p6.x + p6.y + p6.z, 1./6.);
	}
	return l*pow(scale, -float(iterations))-.15;
}

// float de( vec3 p ){
// 	p = p.xzy * 6;
// 	vec3 cSize = vec3(1., 1., 1.3);
// 	float scale = 1.;
// 	for( int i=0; i < 12; i++ ){
// 		p = 2.0*clamp(p, -cSize, cSize) - p;
// 		float r2 = dot(p,p+sin(p.z*.3));
// 		float k = max((2.)/(r2), .027);
// 		p *= k;  scale *= k;
// 	}
// 	float l = length(p.xy);
// 	float rxy = l - 4.0;
// 	float n = l * p.z;
// 	rxy = max(rxy, -(n) / 4.);
// 	return (rxy) / abs(scale);
// }

// float de(vec3 p){
// 	vec3 Q=abs(mod(p,1.8)-.9);
// 	float a=1.;
// 	float d=1.;
// 	for(int j=0;j++<8;)
// 		Q=2.*clamp(Q,-.9,.9)-Q,
// 		d=dot(Q,Q),
// 		Q/=d,
// 		a/=d;
// 	return max((Q.x+Q.y+Q.z-1.3)/a/3., distance( p, vec3( 0.0 ) ) - 0.96);
// }

// #define sabs1(p)sqrt((p)*(p)+1e-1)
// #define sabs2(p)sqrt((p)*(p)+1e-3)
// float de( vec3 p ){
// 	p *= 0.56;
// 	float s=2.; p=abs(p);
// 	for (int i=0; i<4; i++){
// 		p=1.-sabs2(p-1.);
// 		float r=-9.*clamp(max(.2/pow(min(min(sabs1(p.x),
// 			sabs1(p.y)),sabs1(p.z)),.5), .1), 0., .5);
// 		s*=r; p*=r; p+=1.;
// 	}
// 	s=abs(s); float a=2.;
// 	p-=clamp(p,-a,a);
// 	return length(p)/s-.01;
// }

mat3 rotate3D( float angle, vec3 axis ){
	vec3 a = normalize( axis );
	float s = sin( angle );
	float c = cos( angle );
	float r = 1.0 - c;
	return mat3(
		a.x * a.x * r + c,
		a.y * a.x * r + a.z * s,
		a.z * a.x * r - a.y * s,
		a.x * a.y * r - a.z * s,
		a.y * a.y * r + c,
		a.z * a.y * r + a.x * s,
		a.x * a.z * r + a.y * s,
		a.y * a.z * r - a.x * s,
		a.z * a.z * r + c
	);
}

// float de(vec3 p){
// 	p *= 2.6;
// 	#define V vec2(.7,-.7)
// 	#define G(p)dot(p,V)
// 	float i=0.,g=0.,e=1.;
// 	float t = 0.34; // change to see different behavior
// 	for(int j=0;j++<8;){
// 		p=abs(rotate3D(0.34,vec3(1,-3,5))*p*2.)-1.,
// 		p.xz-=(G(p.xz)-sqrt(G(p.xz)*G(p.xz)+.05))*V;
// 	}
// 	return length(p.xz)/3e2;
// }


// float de ( vec3 p ) {
// 	p*= 2.0;
//   float t = 0.0; // adjustment term
//   float s = 12.0;
//   float e = 0.0;
//   for(int j = 0;j++ < 7; p /= e )
//     p = mod( p - 1.0, 2.0 ) - 1.0,
//     s /= e =dot( p, p );
//   e -= abs( p.y ) + sin( atan( p.x, p.z ) * 6.0 + t * 3.0 ) * 0.2 - 0.3;
//   return e / s;
// }


#define EPSILON 0.001
vec3 sdfGradient( vec3 p ){
	vec2 e = vec2( 1, -1 ) * EPSILON;
	return normalize( e.xyy * de( p + e.xyy )
									+ e.yyx * de( p + e.yyx )
									+ e.yxy * de( p + e.yxy )
									+ e.xxx * de( p + e.xxx ));
}


void updatePositionaAndDirection( inout vec4 wbPosition, inout vec4 wbDirection ){

	// if( de( wbPosition.xyz ) < EPSILON ) return;

	// update velocity with the gradient of the SDF, apply damping
	wbDirection.xyz = clamp( wbDirection.xyz + 0.01 * sign(de( wbPosition.xyz )) * sdfGradient( wbPosition.xyz ), -1.0, 1.0 );
	wbDirection *= 0.9;

	// update position wiht the velocity
	wbPosition.xyz += 0.001 * wbDirection.xyz;

	if( abs( wbPosition.x ) > 1.0 )
		wbPosition.x = 0.0;
	if( abs( wbPosition.y ) > 1.0 )
		wbPosition.y = 0.0;
	if( abs( wbPosition.z ) > 1.0 )
		wbPosition.z = 0.0;
}


void main() {
	uint index = ( gl_GlobalInvocationID.x + computeDimensions.x * gl_GlobalInvocationID.y ) * 2;
	updatePositionaAndDirection( data[ index ], data[ index + 1 ] );

	vec3 drawPosition = rotate3D( time, vec3( sin(time), cos(time), tan(time) ) ) * data[ index ].xyz;
	ivec2 writeLocation = ivec2( ( drawPosition.xy + vec2( 1.0 ) ) * ( imageSize( current ) / 2 ) );

	imageAtomicAdd( current, writeLocation, 100 );
}
