Shader "Custom/Hideable" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicTex ("Metallic", 2D) = "black" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_MinAlpha ("Min Alpha", Range(0,1)) = 0.0
		_NoiseSize ("Noise Size", float) = 1.0
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
		sampler2D _MetallicTex;
		sampler2D _NormalTex;

		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
            float3 worldPos;
		};

        half _NoiseSize;
        half _MinAlpha;
        half _TimeReset;
		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
		        
		half fragmentFade(float3 screenPos, float time){        
            float t = time*2-1;
            
            float3 ns = genNoise(screenPos * _NoiseSize);
            
            half c = lerp(1, 0, smoothstep(t, t, ns));
            
            return c;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed4 m = tex2D (_MetallicTex, IN.uv_MainTex) * _Metallic;
												
			half a = fragmentFade(IN.worldPos, abs(min(_Time.y - _TimeReset, 1)));
			
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
