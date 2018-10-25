Shader "GrapheneAi/Simple" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
         _MainTex ("Base (RGB)", 2D) = "white" {}       
		_Reflection ("Reflection", Cube) = "" {}
		_NoiseScale ("Noise Scale", float) = 10.0
	}
	SubShader {
        CGPROGRAM
            #pragma surface surf Lambert
            
            #include "Noise.cginc"
            
            struct Input{
                float2 uv_MainTex : TEXCOORD0;
                float3 worldPos;
                float3 worldRefl; INTERNAL_DATA
                float3 worldNormal;
                float viewDir;
            };
            
            fixed4 _Color;
            samplerCUBE _Reflection;
            sampler2D _MainTex;
            float _NoiseScale;
            
            
            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo = _Color.rgb;
                float2 noise = genNoise(IN.uv_MainTex * _NoiseScale);
                o.Normal.rg += noise;
                
                o.Emission = texCUBE(_Reflection, IN.worldRefl).rgb;
            }
        
        ENDCG
	}
	Fallback "Diffuse"
}
