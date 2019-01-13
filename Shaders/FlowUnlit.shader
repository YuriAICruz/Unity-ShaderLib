﻿// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Graphene/FluidFx/FlowUnlit"
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
        
        _ReflectionColor ("Reflection Color", Color) = (0,0,0,0)
        _ReflectionIntensity ("ReflectionIntensity", float) = 7
        _ReflectionCutOff ("ReflectionCutOff", float) = 0.012
        _ReflectionIntence ("ReflectionIntence", float) = 2
        
        _Smoothness ("Smoothness", Range(0,1)) = 0
        _Cube ("Reflection", CUBE) = "" {}
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
                half3 normal : NORMAL;
                float4 tangent : TANGENT;
			};
			
            struct v2f {
                float4 pos : SV_POSITION;
                fixed2 uv : TEXCOORD0;
                fixed2 waterUv : TEXCOORD0;
                
                float3 worldPos : TEXCOORD1;
                half3 worldNormal : TEXCOORD2;
                
                half3 tspace0 : TEXCOORD3; // tangent.x, bitangent.x, normal.x
                half3 tspace1 : TEXCOORD4; // tangent.y, bitangent.y, normal.y
                half3 tspace2 : TEXCOORD5; // tangent.z, bitangent.z, normal.z
            };
 
            sampler2D _FlowMap;
            sampler2D _MainTex;
            
            fixed4 _MainTex_ST;
            fixed4 _ReflectionColor;
            
            fixed _Speed;
            fixed _FlowSpeed;
            fixed _FlowIntensity;
            float _NoiseSize;
            float _Waterdepth;
            float _Steps;
            float _Angle;
            float _ReflectionIntensity;
            float _ReflectionCutOff;
            float _ReflectionIntence;
            float _Smoothness;
            
            samplerCUBE _Cube;
                         
            v2f vert(appdata IN) {
                v2f o;
                
                float wave = getwaves(IN.uv*_NoiseSize, _Time.y* _Speed);
                
                o.pos = UnityObjectToClipPos(IN.vertex);
                //o.pos.y += wave * _Waterdepth;
                
                o.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                
                // compute world space position of the vertex
                o.worldPos = mul(unity_ObjectToWorld, IN.vertex).xyz;
                // world space normal
                o.worldNormal = UnityObjectToWorldNormal(IN.normal);
                
                half3 wTangent = UnityObjectToWorldDir(IN.tangent.xyz);
                // compute bitangent from cross product of normal and tangent
                half tangentSign = IN.tangent.w * unity_WorldTransformParams.w;
                half3 wBitangent = cross(o.worldNormal, wTangent) * tangentSign;
                
                // output the tangent space matrix
                o.tspace0 = half3(wTangent.x, wBitangent.x, o.worldNormal.x);
                o.tspace1 = half3(wTangent.y, wBitangent.y, o.worldNormal.y);
                o.tspace2 = half3(wTangent.z, wBitangent.z, o.worldNormal.z);
                
                // compute world space view direction
                // float3 worldViewDir = normalize(UnityWorldSpaceViewDir(o.worldPos));
                // world space reflection vector
                // o.worldRefl = reflect(-worldViewDir, IN.normal);
                
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
                _ReflectionIntence *= 100000;

                float2 p1 = v.uv - flowVal.xy * dif1;                
                float2 p2 = v.uv - flowVal.xy * dif2;  
                float2 p = lerp(p1, p2, lerpVal);
                float2 c1 = p, c2 = p;
                float cc1 = col(c1, time, _Speed, _Angle, _Steps, frequency, intensity);
                                
                c2.x += 1/delta;
                float dx = emboss*(cc1-col(c2,time, _Speed, _Angle, _Steps, frequency, intensity))/delta;
                
                c2.x = p.x;
                c2.y += 1/delta;
                float dy = emboss*(cc1-col(c2,time, _Speed, _Angle, _Steps, frequency, intensity))/delta;
                
                c1.x += dx*2.0;
                c1.y = -(c1.y + dy*2.0);
                
                float alpha = 1.0 + dot(dx,dy)*intence;
                
                float ddx = dx * _ReflectionIntensity - _ReflectionCutOff;
                float ddy = dy * _ReflectionIntensity - _ReflectionCutOff;
                
                if (ddx > 0. && ddy > 0.)
                    alpha = pow(alpha, ddx*ddy*-_ReflectionIntence);
                    
                float4 cAlpha = _ReflectionColor*(1-alpha);
                    
                float4 col1 = tex2D(_MainTex, c1 - flowVal.xy * dif1) + (cAlpha);                
                float4 col2 = tex2D(_MainTex, c1 - flowVal.xy * dif2) + (cAlpha);  
                float4 c = lerp(col1, col2, lerpVal);
 
                half3 tnormal = (float4(dx*10, dy*10, 1, 1));
                half3 worldNormal;
                worldNormal.x = dot(v.tspace0, tnormal);
                worldNormal.y = dot(v.tspace1, tnormal);
                worldNormal.z = dot(v.tspace2, tnormal);
                
                half3 worldViewDir = normalize(UnityWorldSpaceViewDir(v.worldPos));
                half3 worldRefl = reflect(-worldViewDir, worldNormal);
                
                // Cubemap
                half3 skyColor = texCUBE (_Cube, worldRefl).rgb;
                
                return lerp(c, float4(skyColor, 1), _Smoothness);
            }
 
            ENDCG
        }
    }
    FallBack "Diffuse"
}
