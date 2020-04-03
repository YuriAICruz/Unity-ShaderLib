#define PI 3.14159265359
#define TWO_PI 6.28318530718


float leaf(float2 st, float size){
    float d = 0.0;
    
    // Remap the space to -1. to 1.
    st = st *2.0 - 1.0 ;
    
    // Number of sides of your shape
    int N = 3;
    
    // Angle and radius from the current pixel
    float a = atan(st)+PI;
    float r = TWO_PI/float(N);
    
    // Shaping function that modulate the distance
    d = cos(floor(.5+a/r)*r-a)*length(st);
    
    return (1.0 - smoothstep(0.4,0.41,d));
}

float polygon(float2 st, float size, int sides, float sa = 0.4, float sb = 0.41){
    float d = 0.0;
    
    // Remap the space to -1. to 1.
    st = st * 2 - 1;
    st  /= size;
        
    // Angle and radius from the current pixel
    float a = atan2(st.x, st.y)+PI;
    float r = TWO_PI/float(sides);
    
    // Shaping function that modulate the distance
    d = cos(floor(0.5+a/r)*r-a)*length(st);
    
    return (1.0 - smoothstep(sa,sb,d));
}


float sdBox( float2 st, float2 size )
{
    float2 d = abs(st)-size;
    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
}



float circle(float2 st, float radius, float2 center = float2( 0.5 , 0.5) ){
    float2 dist = st - center;
	return 1 - smoothstep(
	    radius-(radius * 0.01),
        radius+(radius * 0.01),
        dot(dist,dist) * 4.0
    );
}

float2 rotate(float2 samplePosition, float rotation){
    float angle = rotation * PI * 2 * -1;
    float sine, cosine;
    sincos(angle, sine, cosine);
    return float2(cosine * samplePosition.x + sine * samplePosition.y, cosine * samplePosition.y - sine * samplePosition.x);
}

