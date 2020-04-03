Shader "Unlit/Pattern"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", COLOR) = (1,1,1,1)
        _ColorBg ("Color Background", COLOR) = (1,1,1,1)
        _Point ("Point", Vector) = (0,0,0,0)
        _Ratio ("Ratio", Float) = 1
        _Count ("Count", Int) = 1
        
        [KeywordEnum(OFF, ON)] _REPEAT ("Repeat Offset", float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            
            #pragma multi_compile _REPEAT_ON _REPEAT_OFF
            
            #include "UnityCG.cginc"
            #include "SdfLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _ColorBg;
            float4 _Point;
            float _Ratio;
            int _Count;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                
#ifdef _REPEAT_ON
                float2 uv = float2(frac(_Point.x + i.uv.x* _Count), frac(_Point.y + i.uv.y*_Count) *_Ratio);
#endif
#ifdef _REPEAT_OFF
                float2 uv = float2(_Point.x + frac(i.uv.x* _Count), _Point.y + frac(i.uv.y*_Count) *_Ratio);
#endif
                
                uv = rotate(uv, _Point.w);
                
                float a = circle(uv, _Point.z);
                float b = circle(uv, _Point.z * 0.6);
                
                return saturate(a-b) * _Color + (1-(a-b)) * _ColorBg;
            }
            ENDCG
        }
    }
}