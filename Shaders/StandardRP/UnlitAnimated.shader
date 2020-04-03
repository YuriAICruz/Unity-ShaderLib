Shader "Unlit/UnlitAnimated"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Color ("Color", COLOR) = (1,1,1,1)
        
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
                float4 color : COLOR;
        };

        struct v2f
        {
            float2 uv : TEXCOORD0;
            UNITY_FOG_COORDS(1)
            float4 vertex : SV_POSITION;
                float4 color : COLOR;
        };
        
        int _Columns;
        int _Rows;
        int _FrameNumber;
        int _TotalFrames;
        float _AnimationSpeed;
        float _Intensity;
        float _Scale;
        
        
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
            o.vertex = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                        
            //Sprite Animation                
            o.uv = spriteAnimation(float2(o.uv.y, pow(o.uv.x,0.7)));
            
            o.color = v.color;
            
            UNITY_TRANSFER_FOG(o,o.vertex);
            return o;
        }        
ENDCG
    
        Pass
        {
            ZTest LEqual 
            
            CGPROGRAM
            
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                col.a = col.r;      
                return col * _Intensity * i.color;
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
