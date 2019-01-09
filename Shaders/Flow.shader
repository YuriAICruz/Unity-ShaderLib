Shader "Graphene/FluidFx/Flow"
{
    Properties {
        _FlowMap ("Flow Map", 2D) = "grey" {}
        _MainTex ("Texture", 2D) = "grey" {}
        
        _Speed ("Speed", float) = 0.2
        _FlowSpeed ("Flow Speed", float) = 0.2
        _FlowIntensity ("Flow Intensity", float) = 0.2
        
        _Waterdepth ("Waterdepth", float) = 2.1
        _Angle ("Angle", float) = 8
        _Steps ("Steps", float) = 7
        _ReflectionIntensity ("ReflectionIntensity", float) = 7
    }
 
    SubShader {
        Pass {
            Tags { "RenderType"="Opaque" }
       
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Noise.cginc"
            #include "Math.cginc"
            #include "Water.cginc"
 
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};
			
            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed2 waterUv : TEXCOORD0;
                half3 normal : TEXCOORD1;
            };
 
            fixed4 _Color;
            sampler2D _FlowMap;
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed _Speed;
            fixed _FlowSpeed;
            fixed _FlowIntensity;
            float _NoiseSize;
            float _Waterdepth;
            float _Steps;
            float _Angle;
            float _ReflectionIntensity;
                         
            v2f vert(appdata IN) {
                v2f o;
                
                float wave = getwaves(IN.uv*_NoiseSize, _Time.y* _Speed);
                
                o.pos = UnityObjectToClipPos(IN.vertex);
                //o.pos.y += wave * _Waterdepth;
                
                o.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                //o.uv = IN.uv;
                return o;
            }
            
            float col(float2 coord, float time, float speed, float angle, int steps, float frequency, float intensity)
            {
                float PI = 3.1415926535;
                float delta_theta = 2.0 * PI / angle;
                float color = 0.0;
                float theta = 0.0;
                
                float speed_x = 0.3;
                float speed_y = 0.3;
                
                for (int i = 0; i < steps; i++)
                {
                    float2 adjc = coord;
                    theta = delta_theta*float(i);
                    adjc.x += cos(theta)*time*speed + time * speed_x;
                    adjc.y += sin(theta)*time*speed - time * speed_y;
                    color = color + cos( (adjc.x*cos(theta) - adjc.y*sin(theta)) * frequency ) * intensity;
                }
            
                return cos(color);
            }
            
            fixed4 frag(v2f v) : COLOR {
                
                //Flow Calc
                half3 flowVal = (tex2D(_FlowMap, v.uv) * 2 - 1) * _FlowIntensity;
 
                float dif1 = frac(_Time.y * _FlowSpeed + 0.5);
                float dif2 = frac(_Time.y * _FlowSpeed);
 
                half lerpVal = abs((0.5 - dif1)*2);
                
                // Water
                float time = _Time.y * _Speed;
                
                // refraction
                float emboss = 0.50;
                float intensity = 2.4;
                float frequency = 6.0;
                
                // reflection
                float delta = 60.;
                float intence = 700.;
                
                float reflectionCutOff = 0.012;
                float reflectionIntence = 200000.;

                float2 p = v.uv, c1 = p, c2 = p;
                float cc1 = col(c1, time, _Speed, _Angle, _Steps, frequency, intensity);
                
                float2 d1 = flowVal.xy * dif1;// tex2D(_MainTex, c1 - flowVal.xy * dif1) * (alpha);                
                float2 d2 = flowVal.xy * dif2;// tex2D(_MainTex, c1 - flowVal.xy * dif2) * (alpha);  
                float2 d = lerp(d1, d2, lerpVal);
                d = saturate(1-d);
                //return cc1*d.x + d.x;//float4( d.x, cc1-d.x, cc1*d.x, 1);
                
                c2.x += 1/delta;
                float dx = emboss*(cc1-col(c2,time, _Speed, _Angle, _Steps, frequency, intensity))/delta;
                
                c2.x = p.x;
                c2.y += 1/delta;
                float dy = emboss*(cc1-col(c2,time, _Speed, _Angle, _Steps, frequency, intensity))/delta;
                
                c1.x += dx*2.0;
                c1.y = -(c1.y + dy*2.0);
                
                float alpha = 1.+dot(dx,dy)*intence;
                    
                float ddx = dx*_ReflectionIntensity - reflectionCutOff;
                float ddy = dy*_ReflectionIntensity - reflectionCutOff;
                if (ddx > 0. && ddy > 0.)
                    alpha = pow(alpha, ddx*ddy*reflectionIntence);
                    
                float4 col1 = tex2D(_MainTex, c1 - flowVal.xy * dif1) * (alpha);                
                float4 col2 = tex2D(_MainTex, c1 - flowVal.xy * dif2) * (alpha);  
                float4 c = lerp(col1, col2, lerpVal);
 
                return c;
            }
 
            ENDCG
        }
    }
    FallBack "Diffuse"
}
