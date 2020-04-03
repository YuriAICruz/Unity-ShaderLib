Shader "Graphene/URP/PostProccess/Bloom"
{
    Properties
    {
        [HideInInspector]
        _MainTex ("Texture", 2D) = "white" {}
        _Intensity ("Intensity", Float) = 1
        _Cap ("Cap", Float) = 1
        _Quality ("Quality", Float) = 1
        _BlurSize ("BlurSize", Float) = 1
        _Noise ("Noise", Float) = 1
        _StandardDeviation  ("_StandardDeviation ", Float) = 1
    }
    SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
                        
            #define PI 3.14159265359
            #define E 2.71828182846

            #include "UnityCG.cginc"
                        
            //TODO refactor cginc folders
            #include "../StandardRP/Noise.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            sampler2D _MainTex;
            float _Quality;
            float _Intensity;
            float _Cap;
            float _BlurSize;
            float _Noise;
            float _StandardDeviation;

            fixed4 frag (v2f input) : SV_Target
            {
                float4 fragColor = tex2D(_MainTex, input.uv);
                
                if(_StandardDeviation == 0)
                    return fragColor;
                    
                float offset = _BlurSize;
                
                float invAspect = _ScreenParams.y / _ScreenParams.x;
    
                float2 dir[4];
                dir[0] = float2(1,1);
                dir[1] = float2(1,-1);
                dir[2] = float2(-1,-1);
                dir[3] = float2(-1,1);
                
                float4 col;
                float sum = 0;
                
                float q = _Quality-1;
                
                float noise = genNoise2(input.uv * 200);
                //return noise;
                noise *= _Noise;
                //noise = 1;
                
                
                for (float i = 0; i < _Quality; i++){
                    float offset = (i/q - 0.5) * _BlurSize+noise;
                    
                    float2 uv = input.uv + float2(0, offset); // + dir[i%4]*offset*(i/4+1));
                                        
                    float stDevSquared = _StandardDeviation*_StandardDeviation;
                    float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
                    sum += gauss;
                    col += tex2D(_MainTex, uv) * gauss;
                }
                for (float i = 0; i < _Quality; i++){
                    float offset = (i/q - 0.5) * _BlurSize * invAspect+noise;
                    
                    float2 uv = input.uv + float2(offset,0);
                                        
                    float stDevSquared = _StandardDeviation*_StandardDeviation;
                    float gauss = (1 / sqrt(2*PI*stDevSquared)) * pow(E, -((offset*offset)/(2*stDevSquared)));
                    sum += gauss;
                    col += tex2D(_MainTex, uv) * gauss;
                }
                
                float4 intensity = saturate(col/sum);
                
                intensity = smoothstep(_Cap, _Intensity, intensity);
                
                intensity = pow(intensity, 0.4);
                
                //return intensity;
                           
                return fragColor + intensity;
            }
            ENDHLSL
        }
    }
}
