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

// void pR(inout vec2 p, float a) {
// 	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
// }
//
// float de(vec3 p){
// 	p *= 30.0;
// 	const int iterations = 20;
// 	float d = -2.; // vary this parameter, range is like -20 to 20
// 	p=p.yxz;
// 	pR(p.yz, 1.570795);
// 	p.x += 6.5;
// 	p.yz = mod(abs(p.yz)-.0, 20.) - 10.;
// 	float scale = 1.25;
// 	p.xy /= (1.+d*d*0.0005);
//
// 	float l = 0.;
// 	for (int i=0; i < iterations; i++) {
// 		p.xy = abs(p.xy);
// 		p = p*scale + vec3(-3. + d*0.0095,-1.5,-.5);
// 		pR(p.xy,0.35-d*0.015);
// 		pR(p.yz,0.5+d*0.02);
// 		vec3 p6 = p*p*p; p6=p6*p6;
// 		l =pow(p6.x + p6.y + p6.z, 1./6.);
// 	}
// 	return l*pow(scale, -float(iterations))-.15;
// }

// #define ei(a) mat2(cos(a),-sin(a),sin(a),cos(a))
// float ln ( vec3 p, vec3 a, vec3 b ) {
//     float l = clamp( dot( p - a, b - a ) / dot( b - a, b - a ), 0.0, 1.0 );
//     return mix( 0.7, 1.0, l ) * length( p - a - ( b - a ) * l );
// }
// float de( vec3 u ) {
//   u.xz *= ei( 0.9 );
//   u.xy *= ei( 1.5 );
//   float d = 1e9;
//   vec4 c = vec4( 0.0 ); // orbit trap term
//   float sg = 1e9;
//   float l = 0.1;
//   u.y = abs( u.y );
//   u.y += 0.1;
//   mat2 M1 = ei( 2.0 );
//   mat2 M2 = ei( 0.4 );
//   float w = 0.05;
//   for ( float i = 0.0; i < 18.0; i++ ) {
//     sg = ln( u, vec3( 0.0 ), vec3( 0.0, l, 0.0 ) ) / l;
//     d = min( d, sg * l - w );
//     w *= 0.66;
//     u.y -= l;
//     u.xz *= M1;
//     u.xz = abs( u.xz );
//     u.xy *= M2;
//     l *= 0.75;
//     c += exp( -sg * sg ) * ( 0.5 + 0.5 * sin( 3.1 * i / 16.0 + vec4( 1.0, 2.0, 3.0, 4.0 ) ) );
//   }
//   return d;
// }


// mat2 rotate2D ( float r ) {
//   return mat2( cos( r ), sin( r ), -sin( r ), cos( r ) );
// }
// float de ( vec3 p ) {
//   vec3 q=p;
//   float d, t = 0.0; // t is time adjustment
//   q.xy=fract(q.xy)-.5;
//   for( int j=0; j++<9; q+=q )
//     q.xy=abs(q.xy*rotate2D(q.z + t))-.15;
//     d=(length(q.xy)-.2)/1e3;
//   return d;
// }


// float de( vec3 p ) {
// 	p *= 1.618;
// 	 float i, e, s, g, k = 0.01;
// 	 p.xy *= mat2( cos( p.z ), sin( p.z ), -sin( p.z ), cos( p.z ) );
// 	 e = 0.3 - dot( p.xy, p.xy );
// 	 for( s = 2.0; s < 2e2; s /= 0.6 ) {
// 		 p.yz *= mat2( cos( s ), sin( s ), -sin( s ), cos( s ) );
// 		 e += abs( dot( sin( p * s * s * 0.2 ) / s, vec3( 1.0 ) ) );
// 	 }
// 	 return e;
//  }


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

mat2 rotate2D(float r){
	return mat2(cos(r), sin(r), -sin(r), cos(r));
}
float de(vec3 p){
	p *= 20.0;
	p.y += 10.0;
	float d, a;
	d=a=1.;
	for(int j=0;j++<27;)
		p.xz=abs(p.xz)*rotate2D(3.141592/4.),
		d=min(d,max(length(p.zx)-.3,p.y-.4)/a),
		p.yx*=rotate2D(0.2),
		p.y-=3.,
		p*=1.2,
		a*=1.2;
	return d;
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


// float de( vec3 p ){
// 	// p *= 10.0;
// 	p.z += 7.0;
// 	vec3 P=p, Q, b=vec3( 4, 2.8, 15 );
// 	float i, d=1., a;
// 	Q = mod( P, b ) - b * 0.5;
// 	d = P.z - 6.0;
// 	a = 1.3;
// 	for( int j = 0; j++ < 11; )
// 		d = min( d, length( max( abs( Q ) - b.zyy / 13.0, 0.0 ) ) / a ),
// 		Q = vec3( Q.y, abs( Q.x ) - 1.0, Q.z + 0.3 ) * 1.4,
// 		a *= 1.4;
// 	return d;
// }


// #define D d=min(d,length(vec2(length(Q.zx)-.3,Q.y))-.02)
// float de(vec3 p){
// 	vec3 Q;
// 	float i,d=1.;
// 	Q=abs(fract(p)-.5),
// 	Q=Q.x>Q.z?Q.zyx:Q,
// 	d=9.,    D,
// 	Q-=.5,   D,

// 	Q.x+=.5,
// 	Q=Q.xzy, D,
// 	Q.z+=.5,
// 	Q=Q.zxy, D;
// 	return d;
// }




// mat2 rotate2D(float r){
// 	return mat2(cos(r), sin(r), -sin(r), cos(r));
// }
// float de(vec3 p){
// 	p *= 5.0;
// 	vec3 Q;
// 	float d=1.,a;
// 	Q=mod(p,8.)-4.;
// 	Q.y+=1.5;
// 	d=a=2.;
// 	for(int j=0;j++<15;)
// 		Q.x=abs(Q.x),
// 		d=min(d,length(max(abs(Q)-.5,0.))/a),
// 		Q.xy=(Q.xy-vec2(.5,1))*rotate2D(-.785),
// 		Q*=1.41,
// 		a*=1.41;
// 	return d;
// }

// European 4 in 1 Chain Maille Pattern
// #define R(th) mat2(cos(th),sin(th),-sin(th),cos(th))
// float dTorus( vec3 p, float r_large, float r_small ) {
//   float h = length( p.xy ) - r_large;
//   float d = sqrt( h * h + p.z * p.z ) - r_small;
//   return d;
// }
//
// float torusGrid( vec3 p, float r_small, float r_large, float angle, vec2 sep ) {
//   // Create a grid of tori through domain repetition
//   vec3 q = p - vec3( round( p.xy / sep ) * sep, 0 ) - vec3( 0, sep.y / 2., 0 );
//   q.yz *= R( angle );
//   float d = dTorus( q, r_large, r_small );
//   q = p - vec3( round( p.xy / sep ) * sep, 0 ) - vec3( 0, -sep.y / 2., 0 );
//   q.yz *= R( angle );
//   d = min( d, dTorus( q, r_large, r_small ) );
//   return d;
// }
//
// float material = 0.;
// float de( vec3 p ) {
// 	p *= 3.3;
// 	p *= rotate3D( time, vec3(1.0));
//   float angle = 0.3;
//   vec2 sep = vec2(1,0.8);
//   float d = torusGrid(p, 0.07, 0.4, angle, sep);
//   d = min(d, torusGrid(p-vec3(sep/2.,0), 0.07, 0.4, -angle, sep));
//   // vec3 p2 = 12.3*p // displaced plane background;
//   // p2.yz *= R(0.7);
//   // p2.xz *= R(-0.7);
//   // vec2 q = p2.xy-round(p2.xy);
//   // float bump = dot(q,q) * 0.005;
//   // float d2 = p.z+0.15+bump;
//   // d = min(d, d2);
//   return d;
// }



// random utilites
uint seed = 0;
uint wangHash() {
	seed = uint( seed ^ uint( 61 ) ) ^ uint( seed >> uint( 16 ) );
	seed *= uint( 9 );
	seed = seed ^ ( seed >> 4 );
	seed *= uint( 0x27d4eb2d );
	seed = seed ^ ( seed >> 15 );
	return seed;
}
float randomFloat() {
	return float( wangHash() ) / 4294967296.0;
}



#define EPSILON 0.001
vec3 sdfGradient( vec3 p ){
	vec2 e = vec2( 1, -1 ) * EPSILON;
	return normalize( e.xyy * de( p + e.xyy )
									+ e.yyx * de( p + e.yyx )
									+ e.yxy * de( p + e.yxy )
									+ e.xxx * de( p + e.xxx ));
}


void updatePositionaAndDirection( inout vec4 wbPosition, inout vec4 wbDirection ){

	if( de( wbPosition.xyz ) < EPSILON ) return;


	// update with the gradient
	wbDirection.xyz = clamp( wbDirection.xyz - 0.01 * sdfGradient( wbPosition.xyz ), -1.0, 1.0 );


	// update velocity with the gradient of the SDF, apply damping
	// wbDirection.xyz = clamp( wbDirection.xyz + 0.01 * sign(de( wbPosition.xyz )) * sdfGradient( wbPosition.xyz ), -1.0, 1.0 );
	// wbDirection *= 0.9;

	// update with the cross product of the motion and the gradient - sort of like magnetic fields
	// wbDirection.xyz = clamp( wbDirection.xyz + 0.01 * cross( sdfGradient( wbPosition.xyz ), wbDirection.xyz ), -1.0, 1.0 );


	// update position wiht the velocity
	wbPosition.xyz += 0.001 * wbDirection.xyz;

	// if( abs( wbPosition.x ) > 1.0 )
	// 	wbPosition.x = 0.0;
	// if( abs( wbPosition.y ) > 1.0 )
	// 	wbPosition.y = 0.0;
	// if( abs( wbPosition.z ) > 1.0 )
	// 	wbPosition.z = 0.0;

	if( any( greaterThan( abs( wbPosition.xyz ), vec3( 1.0 ) ) ) ) {
		seed = gl_GlobalInvocationID.x + 69420 * gl_GlobalInvocationID.y;
		wbPosition.x = randomFloat() * 2.0 - 1.0;
		wbPosition.y = randomFloat() * 2.0 - 1.0;
		wbPosition.z = randomFloat() * 2.0 - 1.0;

		wbPosition.x = randomFloat() * 2.0 - 1.0;
		wbPosition.y = randomFloat() * 2.0 - 1.0;
		wbPosition.z = randomFloat() * 2.0 - 1.0;
	}
}


void main() {
	uint index = ( gl_GlobalInvocationID.x + computeDimensions.x * gl_GlobalInvocationID.y ) * 2;
	updatePositionaAndDirection( data[ index ], data[ index + 1 ] );

	vec3 drawPosition = rotate3D( time, vec3( sin(time), cos(time), tan(time) ) ) * data[ index ].xyz;
	ivec2 writeLocation = ivec2( ( drawPosition.xy + vec2( 1.0 ) ) * ( imageSize( current ) / 2 ) );

	imageAtomicAdd( current, writeLocation, 100 );
}
