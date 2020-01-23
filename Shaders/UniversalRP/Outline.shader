Shader "Graphene/URP/PostProccess/Outline"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Outline", Color) = (1,1,1,0)
        _Width ("Width", Float) = 0.01
        _Offset ("Offset", Float) = 0.1
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float4 _Color;
            float _Width;
            float _Offset;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 offset = tex2D(_MainTex, i.uv + _Width*0.01);
                
                float dist = length(offset-col);
                if(dist > _Offset*0.01)
                    return lerp(col, _Color, dist);
                return col;
            }
            ENDCG
        }
    }
}
