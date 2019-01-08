Shader "RenderTexture/StreamReductionBuffer"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _x ("X", float) = 0
        _y ("Y", float) = 0
    }
    SubShader
    {
        Lighting Off
        Blend One Zero

        Pass
        {
            Name "Update"
            CGPROGRAM
            #include "UnityCustomRenderTexture.cginc"
            #include "UnityCG.cginc"
            
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            
            float4 _Color;
            float _x;
            float _y;

            fixed4 frag (v2f_customrendertexture  i) : COLOR
            {
                float2 uv = i.localTexcoord.xy;
                half4 self = tex2D(_SelfTexture2D, uv);
                half4 q = tex2D(_SelfTexture2D, uv - float2(_x,_y));
                
                return self + q * _Color;
            }
            ENDCG
        }
    }
}
