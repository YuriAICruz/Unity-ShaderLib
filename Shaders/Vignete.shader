// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Graphene/Buffered/Vignete"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_Intensity ("Intensity", float) = 1.0
		_Scale ("Scale", float) = 1.0
		_Index ("FFT Count", int) = 1.0
		_Cut ("Cut", Range(0,10)) = 1.0
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" }
		LOD 100

         ZWrite Off
         Blend SrcAlpha OneMinusSrcAlpha 
         
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #pragma target 3.0
						
			#include "UnityCG.cginc"
            #include "Noise.cginc"
			
            float4 vert(appdata_base v) : POSITION {
                return UnityObjectToClipPos (v.vertex);
            }
            
            float _Cut;
            float _Intensity;
            float _Scale;
            float3 _Color;
            int _Index; 
            
            float _FFT[1024];
            
            const float PI = 3.14159;


            fixed4 frag(float4 sp:VPOS) : SV_Target {
                float4 screen = fixed4(sp.xy/_ScreenParams.xy,0.0,1.0);
                
                float4 color = float4(1,1,1,1);
                
                float2 n = genNoise2(screen*_Scale)*0.4+0.6;
                
                float2 center = pow((screen - float2(0.5,0.5))*_Cut,4);
                float r = sqrt(pow(center.x,2) + pow(center.y,2));
                float scr = r * n;
                
                //int index = atan2((center.y), (center.x))*_Index + _Index;
                //int index = atan2((screen.y+1)*0.5, (screen.x+1)*0.5)*_Index+_Index;
                
                //float scr = abs(screen.x-0.5)*n + abs(screen.y-0.5) * n; 
                
                color.rgb = _Color;//hsv2rgb( float3(0.6,1,1) );
                
                
                color.a = scr*_Intensity - 0.2f;
                return color;
            }
            
			ENDCG
		}
	}
}
