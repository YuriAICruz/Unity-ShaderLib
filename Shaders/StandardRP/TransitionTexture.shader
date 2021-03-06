﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Graphene/TransitionTexture" {
	Properties {
	
        [Enum(UnityEngine.Rendering.CullMode)] _ObjectCullMode("Object Cull Mode", Float) = 2
        
        [Header(A Properties)]
		_Color ("Color", Color) = (1,1,1,1)		
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicTex ("Metallic", 2D) = "black" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		
		[HDR]
		_Emission ("Emission", Color) = (0,0,0,0)
	
        [Header(B Properties)]
		_ColorB ("Color", Color) = (1,1,1,1)		
		_MainTexB ("Albedo (RGB)", 2D) = "white" {}
		_MetallicB ("Metallic", Range(0,1)) = 0.0
		_MetallicTexB ("Metallic", 2D) = "black" {}
		_NormalTexB ("Normal", 2D) = "bump" {}
		_GlossinessB ("Smoothness", Range(0,1)) = 0.5
		
		[HDR]
		_EmissionB ("Emission", Color) = (0,0,0,0)
		
        [Header(Animation)]
		_WaveSize ("Wave Size", float) = 10
		_WaveHeight ("Wave Height", float) = 0.05
		
		_Transition ("Transition", Range(0,1)) = 1.0		
		
        [Header(Outline)]
        [KeywordEnum(OFF, ON)] OUTLINE ("Outline", float) = 0
        
        [Enum(UnityEngine.Rendering.CullMode)] _CullMode("Outline Cull Mode", Float) = 1
        
        [HDR]
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range (0, 1)) = .1
		_OutlineTransition ("Outline Transition", Range(0,1)) = 1.0
	}
	
    CGINCLUDE
        #pragma multi_compile OUTLINE_ON OUTLINE_OFF
	ENDCG
	
	SubShader {
        Tags { "RenderType"="Opaque" }
		LOD 200
        Cull [_ObjectCullMode]
		        
        //Blend SrcAlpha OneMinusSrcAlpha
        
		CGPROGRAM            
        //#pragma surface surf Standard fullforwardshadows
        #pragma surface surf StandardDefaultGI fullforwardshadows vertex:vert
		#pragma target 3.0
		
        
        #include "Noise.cginc"
        #include "UnityPBSLighting.cginc"
        
        half _Transition;
                
//        inline half4 LightingStandard(SurfaceOutputStandard s, half3 lightDir, UnityGI gi)
//        {
//              half NdotL = dot (s.Normal, lightDir);
//              half4 c;
//              c.rgb = s.Albedo * _LightColor0.rgb * (NdotL * 1);
//              c.a = s.Alpha;
//              return c;
//        }
        
        inline half4 LightingStandardDefaultGI(SurfaceOutputStandard s, half3 viewDir, UnityGI gi)
        {
            return LightingStandard(s, viewDir, gi);
        }

        inline void LightingStandardDefaultGI_GI(
            SurfaceOutputStandard s,
            UnityGIInput data,
            inout UnityGI gi)
        {
            LightingStandard_GI(s, data, gi);
            
            float grey = (gi.indirect.diffuse.r + gi.indirect.diffuse.g +gi.indirect.diffuse.b) * 0.33333;
            float transition = _Transition*_Transition * 2;
            
            gi.indirect.diffuse = (1-transition) * grey + transition * gi.indirect.diffuse;
        }

		struct Input {
			float2 uv_MainTex;
			float2 uv_MainTexB;
			float2 uv_MetallicTex;
			float2 uv_MetallicTexB;
			float2 uv_NormalTex;
			float2 uv_NormalTexB;
			float4 screenPos;
            float3 worldPos;
            float3 localPos;
		};


		fixed4 _Color;
		sampler2D _MainTex;
		half _Metallic;
		sampler2D _MetallicTex;
		sampler2D _NormalTex;
		half _Glossiness;
		fixed4 _Emission;
		
		fixed4 _ColorB;
		sampler2D _MainTexB;
		half _MetallicB;
		sampler2D _MetallicTexB;
		sampler2D _NormalTexB;
		half _GlossinessB;
		fixed4 _EmissionB;
		
        half _TimeReset;
		
        half _WaveSize;
        half _WaveHeight;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
		
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            
            //o.localPos = mul (unity_ObjectToWorld, v.vertex);
            //o.localPos = UnityObjectToClipPos(v.vertex);
            o.localPos = v.vertex.xyz;
            //o.localPos = UnityObjectToClipPos(v.vertex);
        }
 
		void surf (Input IN, inout SurfaceOutputStandard o) {
			float transition = _Transition;
						
//			float mask = 1-smoothstep(
//			    pow(transition, 1), 
//			    transition, 
//			    (1- IN.localPos.y+sin((IN.worldPos.x+IN.worldPos.z)*_WaveSize)*(1-transition)*_WaveHeight )*0.9-0.55
//            );
//			    
//			transition = lerp(0, 1, lerp(0, mask, min(transition*5,1)));
			
			fixed3 color = 
			    (transition * tex2D (_MainTex, IN.uv_MainTex) * _Color) + 
			    ((1-transition) * tex2D (_MainTexB, IN.uv_MainTexB) * _ColorB)
			    ; 
			    
			fixed4 m = 
			    (transition * tex2D (_MetallicTex, IN.uv_MainTex) * _Metallic) + 
			    ((1-transition) * tex2D (_MetallicTexB, IN.uv_MetallicTexB) * _MetallicB)
            ;
            
			fixed3 n = 
			    (transition * UnpackNormal(tex2D (_NormalTex, IN.uv_MainTex))) + 
			    ((1-transition) * UnpackNormal(tex2D (_NormalTexB, IN.uv_NormalTexB)))
            ;
            
			float g = 
			    (transition * _Glossiness) + 
			    ((1-transition) * _GlossinessB)
            ;
            
			float e = lerp(_EmissionB, _Emission, transition);
			
			o.Albedo = color.rgb;
			o.Metallic = m;
			o.Normal = n;
			o.Smoothness = g;
			o.Emission = _Emission;
		}
		

		ENDCG
		
		Pass {
            Name "outline_pass"
			//Tags { "LightMode" = "Always" }
			Cull [_CullMode]
			
			ZWrite On
			
			//ColorMask RGB
			
			Blend SrcAlpha OneMinusSrcAlpha
 
			CGPROGRAM            
			#pragma vertex vert
			#pragma fragment frag
				
            float _OutlineTransition;
            uniform float _Outline;
            uniform float4 _OutlineColor;
			
			struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };
             
            struct v2f {
                float4 pos : POSITION;
                float4 color : COLOR;
            };
			
			v2f vert(appdata v) {
                v2f o;
                
                #if OUTLINE_ON
                    v.vertex *= ( ceil(1*_OutlineTransition) + sin(_Time.y*6)*_Outline*0.2*_OutlineTransition + _Outline*_OutlineTransition );
                    o.pos = UnityObjectToClipPos(v.vertex);
                    o.color = _OutlineColor * _OutlineTransition;
                #else
                    o.pos = UnityObjectToClipPos(v.vertex);
                #endif
                
                return o;
            }

			half4 frag(v2f i) :COLOR { return i.color; }
			ENDCG
		}
	}
	//CustomEditor "TransitionTexture"
	FallBack "Diffuse"
}
