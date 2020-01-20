Shader "Graphene/SimpleLight" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
	}
	SubShader {
        CGPROGRAM
            #pragma surface surf CustomLight
            
            half4 LightingCustomLight (SurfaceOutput s, half3 lightDir, half atten){                
                half diff = dot(s.Normal, lightDir);
                
                half h = floor(diff*3*atten)/3;
                //h = max(0, h);
                
                h = h * 0.8 + 0.2;                
                h = max(0, h);
                
                half4 c;
                 c.rgb = s.Albedo * _LightColor0.rgb * h;
                 c.a = s.Alpha;
                return c;
            }
            
            struct Input{
                float2 uv_MainTex : TEXCOORD0;
            };
            
            fixed4 _Color;
            samplerCUBE _Reflection;
            sampler2D _MainTex;
            float _NoiseScale;
            
            
            void surf(Input IN, inout SurfaceOutput o){
                o.Albedo = _Color.rgb;
                o.Alpha = 1;
            }
        
        ENDCG
	}
	Fallback "Diffuse"
}
