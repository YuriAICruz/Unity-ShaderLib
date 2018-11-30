// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Outline"
{
	Properties
	{
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		
		[Enum(Off, 0, On, 1)] _Outline ("Outline", Float) = 1
		
		_OutlineColor ("Outline Color", Color) = (1,1,1,1)
		_Border ("Border", Float) = 1
		_Scale ("Scale", Float) = 1
	}
	
	CGINCLUDE
    #include "UnityCG.cginc"
    	
    struct appdata
    {
        float4 vertex : POSITION;
        float2 uv : TEXCOORD0;
        float3 normal : NORMAL;
    };

    struct v2f
    {
        float2 uv : TEXCOORD0;
        float4 vertex : SV_POSITION;
	    float4 color : COLOR;
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
                
				o.vertex = UnityObjectToClipPos(v.vertex*_Scale*_Outline);
				
	            float3 norm = mul( (float3x3) UNITY_MATRIX_IT_MV, v.normal);
	            float2 offset = TransformViewToProjection(norm.xy);
	            
                o.vertex.xy += offset * o.vertex.z * _Border*_Outline;
                
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
            Tags { "RenderType"="Opaque" }
            LOD 100		
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			fixed4 _Color;
			float _Border;

			v2f vert (appdata v)
			{
				v2f o;
                
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				return c * _Color;
            }
            
			ENDCG
		}
		
		
		
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
