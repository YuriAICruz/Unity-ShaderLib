Shader "Graphene/UI/ImageReactionShader"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
        
		_HitPoint ("HitPoint", Vector) = (0,0,0,0)
		_Size ("Size", Vector) = (1,1,0,0)
		_Radius ("Radius", Float) = 1
		_TimeStart ("TimeStart", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

		Pass
		{
            Name "Default"
		CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 uv  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                float4 localPosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            
            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            
			float _Radius;
			float _TimeStart;
			float4 _HitPoint;
			float4 _Size;
			
            #include "Noise.cginc"

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                
                OUT.worldPosition = v.vertex;
                
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                
                OUT.localPosition = mul (UNITY_MATRIX_MV, OUT.vertex);

                OUT.uv = TRANSFORM_TEX(v.uv, _MainTex);

                OUT.color = v.color * _Color;
                return OUT;
            }

			fixed4 frag(v2f IN) : SV_Target
			{			 
			    float2 uv =  IN.uv;
			    
			    float2 noise = genNoise2(uv * 100) ;
			    
                float2 dir = uv - _HitPoint.xy;
                
                dir.x *= _Size.x/_Size.y;
                
                float dist = length(dir);
                
                float timeoffset = sin(min(_Time.y - _TimeStart+ 0.3, 3.14) );
                                
                float radius = _Radius * pow(timeoffset,4);
                
                float circle = saturate(dist / (radius));
                
                //circle *= timeoffset;
			                    
                half4 color = (tex2D(_MainTex, IN.uv) + _TextureSampleAdd) * IN.color;

                #ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                color.a = lerp(lerp(0, noise.x, circle*2), color.a, circle);
                return color;
			}
		ENDCG
		}
    }
}
