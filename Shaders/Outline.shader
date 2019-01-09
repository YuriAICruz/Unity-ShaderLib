// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Graphene/Outline"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		
		[Enum(OFF, 0, ON, 1)] _Outline ("Outline", Float) = 1
		
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		_Border ("Border", Float) = 1
		_Scale ("Scale", Float) = 1
		
        [KeywordEnum(OFF, ON)] _SHADOWS ("Shadows", float) = 0
	}
	
	CGINCLUDE
            
    #include "UnityCG.cginc"    
    #include "Lighting.cginc"
    #include "AutoLight.cginc"
    
    #pragma multi_compile _SHADOWS_ON _SHADOWS_OFF
    	
    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal : NORMAL;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 pos : SV_POSITION;
	    float4 color : COLOR;
	    
        #ifdef _SHADOWS_ON
        SHADOW_COORDS(1)
        #endif
    };
	ENDCG
	
	SubShader
	{
	    Pass
		{
			Tags { "LightMode" = "Always" }
			Cull Front
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
						
			fixed4 _OutlineColor;
			float _Border;
			float _Scale;
			int _Outline;

			v2f vert (appdata v)
			{
				v2f o;
                
				o.pos = UnityObjectToClipPos(v.vertex*_Scale*_Outline);
				
	            float3 norm = mul( (float3x3) UNITY_MATRIX_IT_MV, v.normal);
	            float2 offset = TransformViewToProjection(norm.xy);
	            
                o.pos.xy += offset * o.pos.z * _Border*_Outline;
                
                o.color = _OutlineColor;
				return o;
			}

            half4 frag(v2f i) :COLOR {
                return i.color;
            }
            
			ENDCG	
		}
		Pass
		{	
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
            LOD 100		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
            
            #ifdef _SHADOWS_ON
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #endif
            
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			fixed4 _Color;
			float _Border;

			v2f vert (appdata v)
			{
				v2f o;
                
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
                o.color = _Color;
				
				#ifdef _SHADOWS_ON
                TRANSFER_SHADOW(o)
				#endif
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				
				#ifdef _SHADOWS_ON
                fixed shadow = SHADOW_ATTENUATION(i);
				c.rgb *= shadow;
				#endif
				
				return c*i.color;
            }
            
			ENDCG
		}
		
		
		
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
