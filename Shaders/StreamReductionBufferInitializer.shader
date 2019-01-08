Shader "Unlit/StreamReductionBufferInitializer"
{
    Properties
    {
        _Seed("Seeding", Range(0, 1)) = 0
        _Size("Size", float) = 0
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Lighting Off
        Blend One Zero

        Pass
        {
            Name "Init"
            CGPROGRAM
            
            #include "UnityCustomRenderTexture.cginc"
            #include "Noise.cginc"
            
            #pragma vertex InitCustomRenderTextureVertexShader
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            half _Seed;
            float _Size;
            float4 _Color;

            fixed4 frag (v2f_init_customrendertexture i) : SV_Target
            {
                //float4 col = tex2D(_MainTex, i.texcoord.xy);
                float noise =  genNoise2(i.texcoord.xy*_Size);
                float4 color = float4(1,1,1,1);
                return color * noise;
            }
            ENDCG
        }
    }
}
