Shader "Graphene/FireFx/DistortingGrabPass" {
    Properties {
        _Texture ("Texture", 2D) = "white" {}
		_TintColor  ("Color", Color) = (1,1,1,1)
        _Intensity ("Intensity", Range(0, 50)) = 0
        _Speed ("Speed", Range(0, 50)) = 0
    }
    SubShader {
        GrabPass { 
            "_GrabTexture" 
        }
 
        Pass {
            Tags { "Queue"="Transparent" "RenderType"="Transparent"}
            
            ZWrite Off
            //Blend SrcAlpha Zero   
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
 
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
            
            struct v2f {
                half4 pos : SV_POSITION;
                half4 grabPos : TEXCOORD1;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };
 
            sampler2D _GrabTexture;
            sampler2D _Texture;
            float4 _Texture_ST;
            fixed4 _TintColor ;
            half _Intensity;
            half _Speed;
 
            v2f vert(appdata v) {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.grabPos = ComputeGrabScreenPos(o.pos);
                o.uv = TRANSFORM_TEX(v.uv, _Texture);
                o.color = v.color;
                return o;
            }
 
            half4 frag(v2f i) : COLOR {
                i.grabPos.x += sin((_Time.y*_Speed + i.grabPos.y) * _Intensity)/10;
                fixed4 c = tex2D(_Texture, i.uv);
                fixed4 color = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabPos));
                
                //if(c.a <= 0.1) discard;
                
                color.a = c.a;    
                return color;// + c * i.color ;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}