// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Graphene/Buffered/WorldPosPaint"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Pos ("Pos", Vector) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
         
		Pass
		{
            Tags {"LightMode"="ForwardBase"}
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
						
			#include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
			
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            
			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			float4 _Pos;
			
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 worldpos : TEXCOORD2;
                float4 pos : SV_POSITION;
                SHADOW_COORDS(1)
			};

			v2f vert (appdata v)
			{
				v2f o;
				
                
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
                o.worldpos = mul(unity_ObjectToWorld, v.vertex);
                
                TRANSFER_SHADOW(o)
                
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
			    if(length(_Pos.xyz- i.worldpos)<1)
			    {
			        return half4(0,0,0,1);
			    }
			    
                fixed shadow = SHADOW_ATTENUATION(i);
                
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color * shadow;
				return c;
            }
            
			ENDCG
		}
		
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}
