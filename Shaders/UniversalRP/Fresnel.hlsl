#ifndef MYRP_UNLIT_INCLUDED
#define MYRP_UNLIT_INCLUDED

struct appdata {
	float4 pos : POSITION;
	float2 uv : TEXCOORD;
	float3 normal : NORMAL;
};

struct v2f {
	float4 pos : SV_POSITION;
	float3 normal : NORMAL;
	float3 worldNormal : TEXCOORD3;
	float4 worldPos : TEXCOORD1;
	float fresnel : TEXCOORD2;
	float2 uv : TEXCOORD;
};


#endif // MYRP_UNLIT_INCLUDED

