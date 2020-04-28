Shader "Unlit/UnlitAnimated"
{
    Properties
    {
        [HDR]
        _Color ("Color", COLOR) = (1,1,1,1)
        [HDR]
        _FresnelColor ("Fresnel Color", COLOR) = (1,1,1,1)
		_FresnelBias ("Fresnel Bias", Float) = 0
		_FresnelScale ("Fresnel Scale", Float) = 1
		_FresnelPower ("Fresnel Power", Float) = 1
		_Visibility ("Visibility", Float) = 1
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        //  Blend One One
        //Blend DstColor Zero
        //ColorMask RGB
        //Cull Off 
        //Lighting Off 
        //ZWrite Off 
        
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
						
			#include "UnityCG.cginc"
			
			struct appdata {
                float4 pos : POSITION;
                float2 uv : TEXCOORD;
                float3 normal : NORMAL;
            };
            
            struct v2f {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float3 worldNormal : TEXCOORD3;
                float4 worldPos : TEXCOORD1;
                float fresnel : TEXCOORD2;
                float2 uv : TEXCOORD;
            };
            
            float4 _Color;
            float4 _FresnelColor;
			fixed _Visibility;
			fixed _FresnelBias;
			fixed _FresnelScale;
			fixed _FresnelPower;
			
            v2f vert(appdata v) : POSITION {
                v2f o;
                
				o.pos = UnityObjectToClipPos(v.pos);

				float3 i = normalize(ObjSpaceViewDir(v.pos));
				
				o.fresnel = _FresnelBias + _FresnelScale * pow(1 + dot(i, v.normal), _FresnelPower);
                         
                o.fresnel = saturate(o.fresnel);
                          
                o.uv = v.uv;
                
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET {
                return _Visibility * lerp(_Color, _FresnelColor, 1 - i.fresnel);
                //return _Color * i.fresnel + _FresnelColor * (1-i.fresnel);
            }
            
			ENDCG
		}
    }
}
