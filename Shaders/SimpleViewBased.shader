Shader "Graphene/SimpleViewBase" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_RimColor ("Rim Color", Color) = (1,1,1,1)
		_Power ("Rim Power", Range(0.5,10.0)) = 3.0
		_Step ("Rim Step", Range(0.0,1.0)) = 0.5
		_NoiseIntensity ("Noise Intensity", Range(0.0,1.0)) = 0.5
		_NoiseScale ("Noise Scale", float) = 10.0
	}
	SubShader {
        CGPROGRAM
            #pragma surface surf Lambert
            
            #include "Noise.cginc"
            
            struct Input{
                float2 uv_MainTex : TEXCOORD0;
                float3 viewDir;
                float3 worldPos;
            };
            
            fixed4 _Color;
            fixed4 _RimColor;
            half _Power;
            half _Step;
            float _NoiseScale;
            half _NoiseIntensity;
            sampler2D _MainTex;
                        
            void surf(Input IN, inout SurfaceOutput o){
                half dotp = saturate(dot(normalize(IN.viewDir), o.Normal));
                dotp = pow(1-dotp,_Power);
                dotp = dotp * (1-step(dotp, _Step));
                
                float2 ns = genNoise(IN.worldPos * _NoiseScale);
                
                float3 col = (_Color.rgb + ns.xyx*_NoiseIntensity) * (1-dotp) + _RimColor.rgb * dotp;
                
                o.Albedo = col;
            }
        
        ENDCG
	}
	Fallback "Diffuse"
}
