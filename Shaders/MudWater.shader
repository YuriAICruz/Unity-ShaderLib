Shader "Graphene/FluidFx/MudWater"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
		_Height ("Height", float) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

        CGPROGRAM
                    
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0
                    
        #include "UnityCG.cginc"
        #include "Noise.cginc"

        struct Input {
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float4 screenPos;
            float3 worldPos;
            float3 localPos;
        };

        sampler2D _MainTex;
        sampler2D _NormalMap;
        float _Height;
        
        float fluid(float2 p){
            float r = _Height*smoothstep(0.3, 1.0, genNoise2(p));
            float f = _Height*smoothstep(0.0, 1.0, fbm(6.0*p + 3.0*float3(0, _Time.y, 0)));
            
            return f;
        }
        
        void surf (Input i, inout SurfaceOutputStandard o)
        {
			
            float3 lightDir = normalize( _WorldSpaceLightPos0 );
            fixed3 col = tex2D(_MainTex, i.uv_MainTex);
            
            float f = fluid(i.uv_NormalMap);
            half4 normal = half4(f,f,1,1);
           
            half3 pNormal = normal*2-1;//UnpackNormal (tex2D(_NormalMap, i.uv_NormalMap.xy));
           
			o.Albedo = col;
			//o.Normal = pNormal;
			o.Smoothness = f;
        }
        ENDCG
	}
}
