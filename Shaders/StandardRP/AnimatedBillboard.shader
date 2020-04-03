Shader "Unlit/AnimatedBillboard"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Color ("Color", COLOR) = (1,1,1,1)
        
        _ColorFlame ("Flame Color", COLOR) = (1,1,1,1)
        
		[Header(Spritesheet)]
		_Columns("Columns (int)", int) = 3
		_Rows("Rows (int)", int) = 3
		
		_TotalFrames ("Total Number of Frames (int)", int) = 9
		_AnimationSpeed ("Animation Speed", Float) = 9
		_Intensity ("_Intensity", Float) = 9
		_Scale ("Scale", Float) = 3
		
		
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
        
        int _Columns;
        int _Rows;
        int _FrameNumber;
        int _TotalFrames;
        float _AnimationSpeed;
        float _Intensity;
        float _Scale;
        
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
        
        float2 spriteAnimation(float2 uv){
            _FrameNumber = frac(_Time.y * _AnimationSpeed) * _TotalFrames;

            float frame = clamp(_FrameNumber, 0, _TotalFrames);

            float2 offPerFrame = float2((1 / (float)_Columns), (1 / (float)_Rows));

            float2 spriteSize = uv;
            spriteSize.x = (spriteSize.x / _Columns);
            spriteSize.y = (spriteSize.y / _Rows);

            float2 currentSprite = float2(
                frame % _Columns * offPerFrame.x,
                ((_Rows-1)-floor(frame / _Columns)) * offPerFrame.y
            );
            
            return (spriteSize + currentSprite);
        }
        
        
        sampler2D _MainTex;
        float4 _MainTex_ST;

        v2f vert (appdata v)
        {
            v2f o;
            o.vertex = billboard(v.vertex);
            //o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            
            // billboard mesh towards camera
            
            //Sprite Animation                
            o.uv = spriteAnimation(o.uv);
            
            
            UNITY_TRANSFER_FOG(o,o.vertex);
            return o;
        }        
ENDCG
    
        Pass
        {
            ZTest LEqual 
            
            CGPROGRAM
            
            float4 _ColorFlame;
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);                
                col.a = col.r;      
                return col * _Intensity * _ColorFlame;
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
                return _Color * col * _Intensity;
            }
            ENDCG
        }
    }
}
