Shader "Graphene/Ground" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_NoiseSize ("Noise Size", float) = 1.0
		_Length ("Length", float) = 1.0
		_POW ("_POW", float) = 1.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

        #include "Noise.cginc"

		struct Input {
			float2 uv_MainTex;
			float4 screenPos;
            float3 worldPos;
            float3 localPos;
		};

        half _Distance;
        half _NoiseSize;
		half _Glossiness;
		half _Metallic;
		half _Height;
		half _Length;
		half _POW;
		fixed4 _Color;
		
        const float PI = 3.14159;
		
		float2 hash2(float2 p) {
            float n = sin(dot(p, float2(41, 289)));     
            
            p = frac(float2(262144, 32768)*n); 
            
            return sin( p*6.2831853)*.45 + .5;
        }
		
		float Voronoi(in float2 x){
		
            float2 n = floor(x);
            float2 f = frac(x);
        
            //----------------------------------
            // first pass: regular voronoi
            //----------------------------------
            float2 mg, mr;
        
            float md = 8.0;
            for( int j=-1; j<=1; j++ )
            for( int i=-1; i<=1; i++ )
            {
                float2 g = float2(float(i),float(j));
                float2 o = hash2( n + g );
                float2 r = g + o - f;
                float d = dot(r,r);
        
                if( d<md )
                {
                    md = d;
                    mr = r;
                    mg = g;
                }
            }
        
            //----------------------------------
            // second pass: distance to borders
            //----------------------------------
            md = 8.0;
            int k = 2;
            for( int j=-k; j<=k; j++ )
            for( int i=-k; i<=k; i++ )
            {
                float2 g = mg + float2(float(i),float(j));
                float2 o = hash2( n + g );
                float2 r = g + o - f;
        
                md = min( md, dot( 0.5*(mr+r), normalize(r-mr) ) );
            }
        
            return md > pow(_Distance,2);
        }

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)

		void surf (Input IN, inout SurfaceOutputStandard o) {			
			float noise = genNoise3(IN.worldPos*_NoiseSize);
			noise = noise *0.2 + 0.8;
			
			float3 color = sin(noise*noise)*0.2+0.8;
			float3 normal;
									
            float foward = floor(abs(IN.worldPos.x+3)/6) % 2;
            foward = floor(foward)*0.2+0.8;
            float center = saturate( pow( abs(sin( (IN.worldPos.z) *3.14 / 6)),_POW) );
            								
			o.Albedo = color * (_Color * (center) );//     * foward);
			
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
