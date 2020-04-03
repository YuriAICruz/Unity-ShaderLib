Shader "Graphene/SDF/CircularBloom"
{
    Properties
    {
        _Scale ("Scale", Float) = 1
                
        _Color ("Color", Color) = (0,0,0,0)
                
        _Size ("Size", Float) = 1
        _Inner ("Inner", Float) = 1
        _Feather ("Feather", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        
        Blend SrcAlpha OneMinusSrcAlpha
        // Blend One One
        
        Cull Off 
        Lighting Off 
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "SdfLib.cginc"

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

            float4 _Color;
            float _Size;
            float _Scale;
            float _Inner;
            float _Feather;
            
            float4 billboard(float3 vertex){
                //float3 vpos = mul((float3x3)unity_ObjectToWorld, vertex);
                //float4 worldCoord = float4(unity_ObjectToWorld._m03, unity_ObjectToWorld._m13, unity_ObjectToWorld._m23, 1);
                //float4 viewPos = mul(UNITY_MATRIX_V, worldCoord) + float4(vpos, 0);
                //return mul(UNITY_MATRIX_P, viewPos);
                
                return mul(UNITY_MATRIX_P, 
                    mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
                    + float4(vertex.x, vertex.y, 0.0, 0.0)
                    * float4(_Scale, _Scale, 1.0, 1.0));
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = billboard(v.vertex);
                //o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {                
                UNITY_APPLY_FOG(i.fogCoord, col);
                
                float2 uv = i.uv;
                float2 c = float2(0.5f,0.5f);
                float dist = pow(length(uv - c),4);
                
                float2 size = float2(_Size,_Size);
                
                float a = 1-saturate(1-(circle(uv, size, c)));
                
                
                size = size*_Inner;
                
                float b = 1- saturate( 1 - (circle(uv, size, c)));
                
                float outside = (a-b);
                
                float blur =  outside * (1-saturate(dist*_Feather));
                
                return blur * _Color*_Color;
            }
            ENDCG
        }
    }
}
