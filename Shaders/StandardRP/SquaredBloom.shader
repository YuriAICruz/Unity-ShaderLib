Shader "Graphene/SDF/SquaredBloom"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Color ("Color", Color) = (0,0,0,0)
        
        _Size ("Size", Float) = 1
        _Inner ("Inner", Float) = 1
        _Feather ("Feather", Float) = 1
        _Intensity ("Intensity", Float) = 1
        _Ratio ("Ratio", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        
        Blend SrcAlpha OneMinusSrcAlpha
        // Blend One One
        
        Cull Off 
        Lighting Off 
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
            float _Size;
            float _Inner;
            float _Feather;
            float _Intensity;
            float _Ratio;

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
                fixed4 col = tex2D(_MainTex, i.uv);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                float2 uv = i.uv - float2(0.5f,0.5f);
                
                float2 size = float2(_Size,_Size*_Ratio);
                
                float a =  saturate(1-(sdBox(uv, size) * _Feather));
                
                float b = saturate( 1 - (sdBox(uv, size) * 1000));
                
                float outside = (a-b);
                
                b = saturate((sdBox(uv, size) * 1000));
                size = size/_Inner;
                a = saturate((sdBox(uv, size) * _Feather));
                
                float blur = (outside + saturate(a-b));
                
                return  lerp(float4(_Color.rgb,0), _Intensity * _Color, blur);
            }
            ENDCG
        }
    }
}
