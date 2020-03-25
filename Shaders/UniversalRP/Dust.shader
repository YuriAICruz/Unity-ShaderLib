Shader "Graphene/URP/Dust"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", COLOR) = (1,1,1,1)
        _Fresnel ("Fresnel", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
            
        Blend One One
            
        Pass
        {
            HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

            #include "UnityCG.cginc"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 worldPos : TEXCOORD1;
                float4 localPos : TEXCOORD2;
                float4 fresnelValue : TEXCOORD3;
            };
            
            sampler2D _MainTex;
            float4 _Color;
            float _Fresnel;
            
            v2f vert(appdata v){
                v2f o;
                
                o.localPos = v.vertex;
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                    
                o.uv = v.uv;
                
                float3 viewDir = ObjSpaceViewDir ( v.vertex );
                o.fresnelValue = 1 - saturate ( dot ( v.normal, viewDir ) );
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                
                return o;
            }
            
            float4 frag (v2f i) : SV_TARGET{
                float f = 1-saturate( 
                    pow(
                        smoothstep(0.1, 1,i.fresnelValue),
                        _Fresnel
                    )
                );
            
                float4 col  = tex2D(_MainTex, i.uv);
                
                return col * f * _Color;
            }
            
            ENDHLSL
        }
    }
}