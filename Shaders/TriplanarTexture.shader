// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Graphene/TriplanarTexture" {
	Properties {
	
        [Header(A Properties)]
		_Color ("Color", Color) = (1,1,1,1)		
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_MetallicTex ("Metallic", 2D) = "black" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		
		[HDR]
		_Emission ("Emission", Color) = (0,0,0,0)
		
        _MapScale("Map Scale", Float) = 1
	}
	
    CGINCLUDE
        #pragma multi_compile OUTLINE_ON OUTLINE_OFF
	ENDCG
	
	SubShader {
        Tags { "RenderType"="Opaque" }
		LOD 200
		        
        //Blend SrcAlpha OneMinusSrcAlpha
        
		CGPROGRAM            
        #pragma surface surf Standard vertex:vert fullforwardshadows addshadow
        //#pragma surface surf StandardDefaultGI fullforwardshadows vertex:vert
		#pragma target 3.0
		        
        #include "Noise.cginc"
        
		struct Input {
			float2 uv_MainTex;
			float2 uv_MetallicTex;
			float2 uv_NormalTex;
			float3 localCoord;
            float3 localNormal;
			float3 worldCoord;
			float3 worldNormal;
			INTERNAL_DATA
		};

		fixed4 _Color;
		sampler2D _MainTex;
		half _Metallic;
		sampler2D _MetallicTex;
		sampler2D _NormalTex;
		half _Glossiness;
		fixed4 _Emission;
        half _MapScale;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
		
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            
            o.worldCoord = mul (unity_ObjectToWorld, v.vertex);
            o.localCoord = v.vertex.xyz;
            o.localNormal = v.normal.xyz;
        }
 
		void surf (Input IN, inout SurfaceOutputStandard o) {	
            // Blending factor of triplanar mapping
            float3 nrms = WorldNormalVector (IN, float3(0,0,1));
            float3 bf = normalize(abs(nrms));
            bf /= dot(bf, (float3)1);
            

            // Triplanar mapping
            float2 tx = IN.worldCoord.yz * _MapScale;
            float2 ty = IN.worldCoord.zx * _MapScale;
            float2 tz = IN.worldCoord.xy * _MapScale;
            
            half4 cx = tex2D(_MainTex, tx) * bf.x;
            half4 cy = tex2D(_MainTex, ty) * bf.y;
            half4 cz = tex2D(_MainTex, tz) * bf.z;
            half4 color = (cx + cy + cz) * _Color;
			    
            half4 mx = tex2D(_MetallicTex, tx) * bf.x;
            half4 my = tex2D(_MetallicTex, ty) * bf.y;
            half4 mz = tex2D(_MetallicTex, tz) * bf.z;
            fixed4 m = (mx + my + mz);
            
            half4 nx = tex2D(_NormalTex, tx) * bf.x;
            half4 ny = tex2D(_NormalTex, ty) * bf.y;
            half4 nz = tex2D(_NormalTex, tz) * bf.z;
            fixed3 n = UnpackScaleNormal(nx + ny + nz, 1);
            
			float g = _Glossiness;
            
			float e = _Emission;
			
			o.Albedo = color.rgb;
            o.Alpha = color.a;
			o.Metallic = m;
			o.Normal = n;
			o.Smoothness = g;
			o.Emission = e;
		}
		

		ENDCG
	}
	FallBack "Diffuse"
}
