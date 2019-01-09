Shader "Graphene/ProportionUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1,1,1,1)
		_Ratio ("Image Ratio", Range(0.333,3)) = 1.0
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

            #include "UnityCG.cginc"

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
            fixed4 _Color;
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
			    float2 iuv = i.uv;
			    if ( _Ratio > 1 ){
                    iuv.x *= _Ratio;
                    iuv.x += (1 - _Ratio) * 0.5;
			    } else {
                    iuv.y /= _Ratio;
                    iuv.y -= 0.5/_Ratio - 0.5;
			    }
			    
                fixed4 col = tex2D(_MainTex, iuv);
                
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                return col * _Color;
            }
            ENDCG
        }
    }
}
