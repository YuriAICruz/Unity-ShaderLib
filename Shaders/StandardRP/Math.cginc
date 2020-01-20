// float PI = 3.1415926535;

float3x3 rot3(float3 axis, float angle)
{
	axis = normalize(axis);
	float s = sin(angle);
	float c = cos(angle);
	float oc = 1.0 - c;
	
	return float3x3(oc * axis.x * axis.x + c, oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s, 
	oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c, oc * axis.y * axis.z - axis.x * s, 
	oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c);
}

float2x2 rotZ(float angle)
{
    float2x2 m;
    m[0][0] = cos(angle); m[0][1] = -sin(angle);
    m[1][0] = sin(angle); m[1][1] = cos(angle);
    return m;
}

float3 getRay(float2 uv, float2 size, float2 pos){
    uv = (uv * 2.0 - 1.0)* float2(size.x / size.y, 1.0);
	float3 proj = normalize(float3(uv.x, uv.y, 1.0) + float3(uv.x, uv.y, -1.0) * pow(length(uv), 2.0) * 0.05);	
    
	float3 ray = 
	mul(
	    rot3(
	        float3(0.0, -1.0, 0.0), 
	        pos.x * 2.0 - 1.0
        ) *
        rot3(
            float3(1.0, 0.0, 0.0), 
            1.5 * (pos.y * 2.0 - 1.0)
        ) 
        , proj
    )
    ;
    return ray;
}

float intersectPlane(float3 origin, float3 direction, float3 pt, float3 normal)
{ 
    return clamp(dot(pt - origin, normal) / dot(direction, normal), -1.0, 9991999.0); 
}