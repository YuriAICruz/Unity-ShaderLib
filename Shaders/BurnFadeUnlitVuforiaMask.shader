Shader "Custom/BurnFadeUnlit"
{
	Properties
	{
		_FireColor ("Fire Color", Color) = (1.5,0.5,0,1)
		_NoiseSize ("Noise Size", float) = 1.0
		_NoiseSizeBurn ("Noise Burn Size", float) = 1.0
		_Cutout ("Cutout", float) = 0.5
		_BurnSize ("Burn Size", Range(0,1)) = 0.47
		_BurnedSize ("Burned Size", Range(0,1)) = 0.25
		
		_Direction ("Direction", Vector) = (1,0.5,0,0)
		
		_TimeLapse ("Time Lapse", Range(0,1)) = 0.0
		_Width ("Circle Width", Range(0,2)) = 1.0
		_Ratio ("Image Ratio", Range(0.333,3)) = 1.0
	}
	SubShader
	{
		Tags {"Queue"="Geometry-10" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		LOD 100
		
        Lighting Off
        
        ZTest Always
        ZWrite On
        
        Blend SrcAlpha OneMinusSrcAlpha
        
        ColorMask RGBA
		
		//Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag alpha
			
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
            half _NoiseSizeBurn;
            half _BurnSize;
            half _BurnedSize;
            half _TimeReset;
            half _TimeLapse;
            half _Cutout;
            half _Width;
            float _Ratio;
		    fixed4 _Direction;
            fixed4 _FireColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
			    float2 iuv = i.uv;
			    if ( _Ratio > 1 ){
                    iuv.x *= _Ratio;
                    iuv.x += (1 - _Ratio) * 0.5;
			    } else {
                    iuv.y /= _Ratio;
                    iuv.y -= 0.5/_Ratio - 0.5;
			    }
			    
				fixed4 c = clamp(0, 0, 0);
                
                float2 uv = i.uv * _NoiseSize;
    
                half a = 1;
                float2 b = float2(i.uv.x + _Direction.x - 0.5, i.uv.y + _Direction.y - 0.5);
                float w = (_Width + 0.125) * 5;
                float r = pow(pow(b.x,2) + pow(b.y,2),0.5) * w;
                float d = saturate(r - (_TimeLapse *1.2 * w - 0.5) + 0.5 * fbm(uv * 15.1) + 0.1);
                    
                if (d > _Cutout) {
                    if (d < _BurnSize) {
                        float ns = genNoise2( _NoiseSizeBurn * 20.0 * uv + float2(_TimeLapse, 0.0));
                        float color = (d-_Cutout) * (0.2+ns*0.8); //* (ns);// (d-_BurnSize) * (ns);
                        c.rgb += saturate( float3(color, color, color)*_FireColor * 500.0);
                    } 
                    else if (d < _BurnedSize) {
                        float color = 0;
                        c.rgb += saturate( float3(color, color, color)*_FireColor * 500.0);
                    }
                    else{
                        a = 0;
                    }
                }else{
                    discard;
                }
            
                c.a = a;
				return c;
			}
			ENDCG
		}
	}
}
