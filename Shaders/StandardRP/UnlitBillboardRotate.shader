Shader "Unlit/UnlitBillboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Color ("Color", COLOR) = (1,1,1,1)
        		
		_Scale ("Scale", Float) = 3
		
		_Speed ("Speed", Float) = 1
		_Alpha ("Alpha", Float) = 1
		
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 1 //"One"
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DestBlend", Float) = 0 //"Zero"
    }
    
    SubShader
    {
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
        
        Blend [_SrcBlend] [_DstBlend]
        //ColorMask RGB
        //Cull Off 
        Lighting Off 
        ZWrite Off 
        
CGINCLUDE   
        #pragma vertex vert
        #pragma fragment frag
        // make fog work
        #pragma multi_compile_fog
        #include "UnityCG.cginc"
            
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
        
        float _Scale;
        float _Alpha;
        
        float4 billboard(float3 vertex){
            return mul(UNITY_MATRIX_P, 
              mul(UNITY_MATRIX_MV, float4(0.0, 0.0, 0.0, 1.0))
              + float4(vertex.x, vertex.y, 0.0, 0.0)
              * float4(_Scale, _Scale, 1.0, 1.0));
        }
        
        void Unity_RotateAboutAxis_Radians_float(float3 In, float3 Axis, float Rotation, out float3 Out)
        {
            float s = sin(Rotation);
            float c = cos(Rotation);
            float one_minus_c = 1.0 - c;
        
            Axis = normalize(Axis);
            float3x3 rot_mat = 
            {   one_minus_c * Axis.x * Axis.x + c, one_minus_c * Axis.x * Axis.y - Axis.z * s, one_minus_c * Axis.z * Axis.x + Axis.y * s,
                one_minus_c * Axis.x * Axis.y + Axis.z * s, one_minus_c * Axis.y * Axis.y + c, one_minus_c * Axis.y * Axis.z - Axis.x * s,
                one_minus_c * Axis.z * Axis.x - Axis.y * s, one_minus_c * Axis.y * Axis.z + Axis.x * s, one_minus_c * Axis.z * Axis.z + c
            };
            Out = mul(rot_mat,  In);
        }
        
        sampler2D _MainTex;
        float4 _MainTex_ST;
        float _Speed;

        v2f vert (appdata v)
        {
            v2f o;
            //o.vertex = billboard(RotateAroundYInDegrees(v.vertex, _Speed));
            float3 vert;
            Unity_RotateAboutAxis_Radians_float(v.vertex, float3(0,0,1), _Time.y *  _Speed, vert);
            o.vertex = billboard(vert);
            
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);       
            
            UNITY_TRANSFER_FOG(o,o.vertex);
            return o;
        }        
ENDCG
    
        Pass
        {
            ZTest LEqual 
            
            CGPROGRAM
            
            float4 _Color;
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);                
                col.a = col.r;      
                return col * _Color * _Alpha;
            }

            ENDCG
        }
        
        Pass{
            
            ZTest Greater
        
            CGPROGRAM            
            float4 _Color;

            fixed4 frag (v2f i) : SV_Target
            {      
                fixed4 col = tex2D(_MainTex, i.uv);    
                return _Color * col;
            }
            ENDCG
        }
    }
}
