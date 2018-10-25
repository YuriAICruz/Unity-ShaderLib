Shader "Custom/Ice" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
		_NoiseSize ("Noise Size", float) = 1.0
		_Distance ("_Distance", Range(0,1)) = 1.0
		_Height("_Height", float) = 10
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
		
            float voronoi = Voronoi(IN.worldPos.xz*_NoiseSize);
            float frag = voronoi*0.9+0.1;//round((pow(voronoi,0.2)));
			float nrm = voronoi;
			
			float noise = genNoise3(IN.worldPos);
			noise = noise *0.2 + 0.8;
			
			float3 color = float3(1,1,1);
			float3 normal;
						
			float3 masks;
			
			float h = IN.worldPos.y/_Height;
            h = saturate((h+1)/2);
			
			masks.r = lerp(0, 1, max(0, (h)       %1 -0.50) * 3);
			masks.g = lerp(0, 1, max(0, (h + 0.33)%1 -0.40) * 3);
			masks.b = lerp(0, 1, saturate((h + 0.90)%1 -0.90) * 20);
			
			color =   
			    masks.r * float3(0.7,0.8,0.8) * noise +  
			    masks.g * float3(0.0,0.6,0.1) +
			    masks.b * voronoi * _Color;
			
			o.Albedo = color;//color * _Color;
			
			o.Metallic = voronoi*_Metallic;
			o.Smoothness = voronoi*_Glossiness;
			o.Alpha = 1;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
