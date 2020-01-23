Shader "Graphene/URP/PostProccess/Distortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Width ("Width", Float) = 0.01
        _Offset ("Offset", Float) = 0.1
        _Intensity ("Intensity", Float) = 1
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
            
            //TODO refactor cginc folders
            #include "../StandardRP/Noise.cginc"

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
            float _Intensity;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                
                uv.x -= 0.5;
                uv.y -= 0.5;
                
                int rngSeed = 1;
                float distortion;
                
                float time = _Offset;
                
                distortion = lerp(0.2,1, genNoise(float3(uv.x+1, uv.y+1, uv.x*sin(time)) * _Width) ); // add 1.0 to coords, since perlin func only seems to work with positive floats
                //return distortion;
                
                distortion *= _Intensity;
                
                float2 uv2;
                float3 col;
                
                uv2.x = 0.5 + uv.x + fmod(2222.0,distortion/5.0);
                uv2.y = 0.5 + uv.y + fmod(2222.0,distortion/5.0);
                
                float4 fragColor = tex2D(_MainTex, uv2);
                
                return fragColor;
            }
            ENDCG
        }
    }
}
