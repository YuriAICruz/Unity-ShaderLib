Shader "Custom/BurnFade" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		[HDR]
		_FireColor ("Fire Color", Color) = (1.5,0.5,0,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_NormalTex ("Normal", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_MinAlpha ("Min Alpha", Range(0,1)) = 0.0
		_NoiseSize ("Noise Size", float) = 1.0
		_BurnSize ("Burn Size", Range(0,1)) = 0.47
		_BurnedSize ("Burned Size", Range(0,1)) = 0.25
		
		_Direction ("Direction", Vector) = (1,0.5,0,0)
		
		_TimeLapse ("Time Lapse", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "Queue"="AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
		LOD 200
		        
        //Blend SrcAlpha OneMinusSrcAlpha
        
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows alphatest:_Cutoff 

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0
		
        #include "Noise.cginc"

		sampler2D _MainTex;
		sampler2D _NormalTex;

		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
            float3 worldPos;
		};

        half _NoiseSize;
        half _BurnSize;
        half _BurnedSize;
        half _MinAlpha;
        half _TimeReset;
        half _TimeLapse;
		half _Glossiness;
		half _Metallic;
		fixed4 _Direction;
		fixed4 _Color;
		fixed4 _FireColor;
		
		UNITY_INSTANCING_BUFFER_START(Props)
		UNITY_INSTANCING_BUFFER_END(Props)
		        
		half fragmentFade(float3 screenPos, float time){        
            float t = time*2-1;
            
            float3 ns = genNoise(screenPos * _NoiseSize);
            
            half c = lerp(1, 0, smoothstep(t, t, ns));
            
            return c;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			float4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			float m = 0;
			
			float2 uv = IN.uv_MainTex * _NoiseSize;

	        half a = 1;
            float d = uv.x * _Direction.x + uv.y * _Direction.y + 0.5 * fbm(uv * 15.1) + _TimeLapse*2 - (_Direction.x + _Direction.y);
                                
            if (d > _BurnedSize) {
                c = clamp(c - (d- _BurnedSize) * 10.0, 0.0 , 1.0);
                _Glossiness = c;
                m = saturate(pow(d+_Metallic,20.0));
            }
            
            if (d >_BurnSize) {
                if (d < 0.5 ) {
                    c.rg += (d-_BurnSize) * 33.0 * 0.5 * (0.0 + genNoise2( _NoiseSize * 20.0 * uv + float2(_TimeLapse, 0.0) ) ) * _FireColor;
                    _Glossiness = c;
                }
                else {
                    c.rgb += float3(0,0,0);
                    a = 0;
                } 
            }
			
			o.Albedo = c.rgb;
			o.Metallic = m;
			o.Normal = UnpackNormal(tex2D (_NormalTex, IN.uv_MainTex));
			o.Smoothness = _Glossiness;
			o.Alpha = min(a, 1);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
