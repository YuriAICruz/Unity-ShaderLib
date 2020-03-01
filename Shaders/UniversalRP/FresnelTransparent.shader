Shader "Graphene/URP/FresnelTransparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", COLOR) = (1,1,1,1)
        _BaseColor ("Base Color", COLOR) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
            
        Blend SrcAlpha OneMinusSrcAlpha
        
        Cull Front
    
        Pass
        {
            HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
            #include "UnityCG.cginc"
			#include "Fresnel.hlsl"
			
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            
			float4 _Color;
			float4 _BaseColor;
			float _FresnelPower;
            
            v2f vert(appdata v){
                v2f o;    
                float4 worldPos = mul(unity_ObjectToWorld, float4(v.pos.xyz, 1));
                
                o.fresnel = 1 - saturate ( dot ( v.normal, ObjSpaceViewDir ( v.pos ) ) );
                
                o.worldPos = worldPos;
                o.pos = mul(unity_MatrixVP, worldPos);
                o.normal = v.normal;
                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_TARGET{
                float4 col = tex2D(_MainTex, i.uv);
                return _BaseColor * col + pow(i.fresnel, _FresnelPower) * _Color ;
            }
            
            ENDHLSL
        }
    }
}
