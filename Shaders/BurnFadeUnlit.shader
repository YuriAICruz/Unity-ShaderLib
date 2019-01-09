Shader "Graphene/FireFx/BurnFadeUnlit"
{
	Properties
	{
		_Color ("Color", Color) = (1,1,1,1)
		_FireColor ("Fire Color", Color) = (1.5,0.5,0,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_NormalTex ("Normal", 2D) = "bump" {}
		_MinAlpha ("Min Alpha", Range(0,1)) = 0.0
		_NoiseSize ("Noise Size", float) = 1.0
		_Cutout ("Cutout", float) = 0.5
		_BurnSize ("Burn Size", Range(0,1)) = 0.47
		_BurnedSize ("Burned Size", Range(0,1)) = 0.25
		
		_Direction ("Direction", Vector) = (1,0.5,0,0)
		
		_TimeLapse ("Time Lapse", Range(0,1)) = 0.0
		_Width ("Circle Width", Range(0,2)) = 1.0
	}
	SubShader
	{
		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
            #include "Noise.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};


            half _NoiseSize;
            half _BurnSize;
            half _BurnedSize;
            half _MinAlpha;
            half _TimeReset;
            half _TimeLapse;
            half _Cutout;
            half _Width;
		    fixed4 _Direction;
            fixed4 _Color;
            fixed4 _FireColor;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			
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
				                
                float2 uv = i.uv * _NoiseSize;
    
                half a = 1;
                float2 b = float2(i.uv.x + _Direction.x - 0.5, i.uv.y + _Direction.y - 0.5);
                float w = (_Width + 0.125) * 5;
                float r = pow(pow(b.x,2) + pow(b.y,2),0.5) * w;
                float d = saturate(r - (_TimeLapse *1.2 * w - 0.5) + 0.5 * fbm(uv * 15.1) + 0.1);
                                    
                if (d > _BurnedSize) {
                    c = clamp(c - (d- _BurnedSize) * 10.0, 0.0 , 1.0);
                    //c = 0;
                } else {
                    
                }
                
                if (d > _Cutout) {
                    if (d < _BurnSize) {
                        c.rg += (d-_BurnSize) * 16.0 * (0.0 + genNoise2( _NoiseSize * 20.0 * uv + float2(_TimeLapse, 0.0) ) ) * _FireColor;
                    }
                    else {
                        discard;
                    } 
                }else{
                
                }
            
                c.a = a;
				return c;
			}
			ENDCG
		}
	}
}
