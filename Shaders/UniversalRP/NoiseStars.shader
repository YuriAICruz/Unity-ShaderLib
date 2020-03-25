Shader "Graphene/URP/NoiseStars"
{
    Properties
    {
        _Color ("Color", COLOR) = (1,1,1,1)
        _BaseColor ("Base Color", COLOR) = (1,1,1,1)
        
        _Noise ("Noise", Float) = 0
        _Rim ("Rim", Float) = 0
        _Power ("Power", Float) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque"}
            
        //Blend SrcAlpha OneMinusSrcAlpha
            
        Cull Front
            
        Pass
        {
            HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
            #include "UnityCG.cginc"
            #include "../StandardRP/Noise.cginc"
			
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            
			float4 _Color;
			float4 _BaseColor;
			float _Rim;
			float _Noise;
			float _Power;
			
			struct appdata {
                float4 pos : POSITION;
                float2 uv : TEXCOORD;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD;
            };

            v2f vert(appdata v){
                v2f o;    
                
                float4 worldPos = mul(unity_ObjectToWorld, float4(v.pos.xyz, 1));
                o.pos = mul(unity_MatrixVP, worldPos);
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            
            float4 frag (v2f i) : SV_TARGET
            {
                float noise = voronoi(i.uv * _Noise);
                noise = smoothstep(0,_Rim,pow(noise, _Power));
                
                //return dust;
                return _BaseColor + (1-noise)*_Color;
            }
            
            ENDHLSL
        }
    }
}
