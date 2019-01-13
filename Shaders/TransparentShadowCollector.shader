// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Graphene/TransparentShadowCollector"
{
    Properties
    {
        _ShadowIntensity ("Shadow Intensity", Range (0, 1)) = 0.6
        _Color ("Color", Color) = (1,1,1,1)
    }
    
    SubShader
    {
        Tags { "Queue"="AlphaTest" }
        
            CGPROGRAM
		    #pragma surface surf Standard alpha:fade
            
            struct Input {
                float2 uv_MainTex;
            };
            
            uniform float4 _Color;
            
            void surf (Input v, inout SurfaceOutputStandard o) {
                o.Albedo = _Color.rgb;
                o.Alpha = _Color.a;
            }
            
            ENDCG
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            uniform float _ShadowIntensity;

            struct v2f
            {
                float4 pos : SV_POSITION;
                LIGHTING_COORDS(0,1)
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
               
                return o;
            }
            
            fixed4 frag(v2f i) : COLOR
            {
                float attenuation = LIGHT_ATTENUATION(i);
                float alpha = (1 - attenuation) * _ShadowIntensity;
               
                return fixed4(0,0,0 , alpha);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}