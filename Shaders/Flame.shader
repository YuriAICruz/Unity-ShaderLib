Shader "Unlit/Flame"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _VerticalSpeed ("VerticalSpeed", float) = 0.3
        _FlameSpeed ("FlameSpeed", float) = 0.035
        _Turbulence ("Turbulence", float) = 2
		_Offset ("Offset", Vector) = (0.5,0.5,0,0)
		
        _Thickness ("Thickness", float) = 5.0
        _ColorNoise ("Color Noise", float) = 0.45
        _Instability ("Instability", Range(-2,10)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderType"="Transparent"}
        LOD 100

        ZWrite Off
        
        Cull Off
        
        Blend SrcAlpha OneMinusSrcAlpha 
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Noise.cginc"
            #include "Math.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            fixed4 _Color;
            fixed4 _Offset;
            float _VerticalSpeed;
            float _FlameSpeed;
            float _Thickness;
            float _ColorNoise;
            float _Turbulence;
            float _Instability;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {   
                float2 uv = i.uv - float2(_Offset.x, _Offset.y);
                
                float2 time = float2(_Time.y, _Time.y);
                
                // height variation from fbm
                float vY = fbm(time * _VerticalSpeed) * 1.2;
                                
                // flame "speed"
                float2 offset = float2(0.0, time.x * _FlameSpeed * _Offset.z);
                
                // flame turbulence
                float f = fbm(uv * _Turbulence + offset); // rotation from fbm
                float l = max(_Instability, length(uv)); // rotation amount normalized over distance
                
                uv += mul( rotZ( ( (f) / l ) * smoothstep(-0.2, 0.4, i.uv.y)), uv);
                
                // flame thickness
                float flame = 1.3 - length(uv.x) * _Thickness;
                
                // bottom of flame 
                float blueflame = pow(flame * 0.9, 15.0);
                blueflame *= smoothstep(.2, -1.0, i.uv.y);
                blueflame /= abs(uv.x * 2.0);
                blueflame = clamp(blueflame, 0.0, 1.0);
                
                // flame
                flame *= smoothstep(1.0, vY * 0.5, i.uv.y);
                flame = clamp(flame, 0.0, 1.0);
                flame = pow(flame, 3.0);
                flame /= smoothstep(1.1, -0.1, i.uv.y);   
                
                // colors
                float4 col = lerp(
                    float4(1.0, 1.0, 0.0, 0.0), 
                    float4(1.0, 1.0, 0.6, 0.0), 
                    flame
                );
                
                col = lerp(
                    float4(1.0, 0.0, 0.0, 0.0), 
                    col, 
                    smoothstep(0.0, 1.6, flame)
                );
                
                float4 fragColor = col;
                
                // a bit blueness on the bottom
                float4 bluecolor = lerp(_Color, fragColor, 1-_Color.a);
                fragColor = bluecolor;
                
                // clear bg outside of the flame
                fragColor *= flame;
                fragColor.a = flame;
                
                // just a hint of noise
                fragColor *= lerp(rand(i.uv) + rand(i.uv * _ColorNoise), 1.0, 0.98);
                
                fragColor = clamp(fragColor, 0.0, 1.0);
                                 
                return i.color * fragColor;
            }
            ENDCG
        }
    }
}
