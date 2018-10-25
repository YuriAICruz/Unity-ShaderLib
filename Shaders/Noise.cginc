
float2 hash( float2 p ) {  						// rand in [-1,1]
     p = float2( dot(p,float2(127.1,311.7)),
               dot(p,float2(269.5,183.3)) );
     return -1. + 2.*frac(sin(p+20.)*53758.5453123);
 }
 
 float2 genNoise2(float2 p){
     float2 i = floor(p), f = frac(p);
     float2 u = f*f*(3.-2.*f);
     return lerp( lerp( dot( hash( i + float2(0.,0.) ), f - float2(0.,0.) ), 
                      dot( hash( i + float2(1.,0.) ), f - float2(1.,0.) ), u.x),
                 lerp( dot( hash( i + float2(0.,1.) ), f - float2(0.,1.) ), 
                      dot( hash( i + float2(1.,1.) ), f - float2(1.,1.) ), u.x), u.y);
 }
 
 float3 hash3(float3 p) {
  p = float3( dot( p, float3(127.1, 311.7, 121.1) ),
            dot( p, float3(269.5, 183.3, 234.5) ),
            dot( p, float3(629.5, 43.3, 32.1) ) );

  return -1.0 + 2.0 * frac(sin(p) * 43758.5453123 );
}
 
 float genNoise3(float3 p){
      float3 p0 = floor(p);
      float3 d = frac(p);
    
      float3 w = d * d * (3.0 - 2.0 * d);
    
      float lerp1 = lerp(
                      lerp( dot( hash3( p0 ) , d ) , dot( hash3( p0 + float3(1, 0, 0)  ), d - float3(1, 0, 0) ) , w.x ) ,
                      lerp( dot( hash3( p0 + float3(0, 1, 0) ), d - float3(0, 1, 0) ) , dot( hash3( p0 + float3(1, 1, 0)  ), d - float3(1, 1, 0) ) , w.x ),
                      w.y);
    
      float lerp2 = lerp(
                      lerp( dot( hash3( p0 + float3(0, 0, 1) ), d - float3(0, 0, 1) ) , dot( hash3( p0 + float3(1, 0, 1)  ), d - float3(1, 0, 1) ) , w.x ) ,
                      lerp( dot( hash3( p0 + float3(0, 1, 1) ), d - float3(0, 1, 1) ) , dot( hash3( p0 + float3(1, 1, 1)  ), d - float3(1, 1, 1) ) , w.x ),
                      w.y);
    
      return lerp(lerp1, lerp2, w.z);
 }
 
 float3 hsv2rgb (in float3 hsv) {
	hsv.yz = clamp (hsv.yz, 0.0, 1.0);
	return hsv.z * (1.0 + 0.5 * hsv.y * (cos (2.0 * 3.14159 * (hsv.x + float3 (0.0, 2.0 / 3.0, 1.0 / 3.0))) - 1.0));
}

float rand (in float2 seed) {
	return frac (sin (dot (seed, float2 (12.9898, 78.233))) * 137.5453);
}
