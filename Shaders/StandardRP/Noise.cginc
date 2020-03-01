
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
 
float genNoise(float3 p){
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
    /*
    const float2 C = float2(1.0 / 6.0, 1.0 / 3.0);
    
    float3 p = floor(x + dot(x,C.yyy));
    float3 f = frac(x);
    f = (3.0-2.0*f);
    
    float2 uv = (p.xy + float2(37.0,17.0) * p.z) + f.xy;
    float2 rg = genNoise(uv);
    return lerp( rg.x, rg.y, 0);
    */
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
float3 rgb2hsv(float3 c) {
    float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    float4 p = lerp(float4(c.bg, K.wz), float4(c.gb, K.xy), step(c.b, c.g));
    float4 q = lerp(float4(p.xyw, c.r), float4(c.r, p.yzx), step(p.x, c.r));
    
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return float3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

//float3 hsv2rgb(float3 c) {
//    c = float3(c.x, clamp(c.yz, 0.0, 1.0));
//    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
//   float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
//    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
//}

float3 hsv2rgb (in float3 hsv) {
	hsv.yz = clamp (hsv.yz, 0.0, 1.0);
	return hsv.z * (1.0 + 0.5 * hsv.y * (cos (2.0 * 3.14159 * (hsv.x + float3 (0.0, 2.0 / 3.0, 1.0 / 3.0))) - 1.0));
}

float rand (in float2 seed) {
	return frac (sin (dot (seed, float2 (12.9898, 78.233))) * 137.5453);
}

float fbm(float2 p) 
{
	float v = 0.0;
	v += genNoise2(p*1.)*.5;
	v += genNoise2(p*2.)*.25;
	v += genNoise2(p*4.)*.125;
	return v;
}

            
float voronoi(float2 pos){
    float2 uv = pos;
    float2 iuv = floor(uv); //gets integer values no floating point
    float2 fuv = frac(uv); // gets only the fractional part
    float minDist = 1.0;  // minimun distance
    
    for (int y = -1; y <= 1; y++)
    {
        for (int x = -1; x <= 1; x++)
        {
            // Position of neighbour on the grid
            float2 neighbour = float2(float(x), float(y));
            // Random position from current + neighbour place in the grid
            float2 pointv = hash(iuv + neighbour);
            // Move the point with time
            //pointv = 0.5 + 0.5*sin(_Time.y + 6.2236*pointv);
            pointv = 0.5 + 0.5*sin(1 + 6.2236*pointv);//each point moves in a certain way
                                                            // Vector between the pixel and the point
            float2 diff = neighbour + pointv - fuv;
            // Distance to the point
            float dist = length(diff);
            // Keep the closer distance
            minDist = min(minDist, dist);
        }
    }
    
    // Draw the min distance (distance field)
    return minDist * minDist; // squared it to to make edges look sharper
    
}

