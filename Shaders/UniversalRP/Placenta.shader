Shader "Graphene/URP/Placenta"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        _Color ("Color", COLOR) = (1,1,1,1)
        _BaseColor ("Base Color", COLOR) = (1,1,1,1)
        
        _ScatteringColor ("Scattering Color", COLOR) = (1,1,1,1)
        _VeinColor ("Vein Color", COLOR) = (1,1,1,1)
        _FresnelPower ("Fresnel Power", Float) = 0
        _Rim ("Rim", Float) = 0
        
        _DotsColor ("Dots Color", COLOR) = (1,1,1,1)
        
        _Noise1 ("Noise 1", Float) = 0
        _Noise2 ("Noise 2", Float) = 0
        
        _Light ("Light Attenuation", Float) = 0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
            
        Blend SrcAlpha OneMinusSrcAlpha
            
        Pass
        {
            HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
            #include "UnityCG.cginc"
            #include "../StandardRP/Noise.cginc"
			#include "Fresnel.hlsl"
			
            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            
			float4 _Color;
			float4 _BaseColor;
			float4 _ScatteringColor;
			float4 _DotsColor;
			float4 _VeinColor;
			float4 Main_Directional_Light;
			float _FresnelPower;
			float _Rim;
			float _Noise1;
			float _Noise2;
			float _Light;
			
            #define MAX_VISIBLE_LIGHTS 4
            
            CBUFFER_START(_LightBuffer)
                float4 _VisibleLightColors[MAX_VISIBLE_LIGHTS];
                float4 _VisibleLightDirections[MAX_VISIBLE_LIGHTS];
            CBUFFER_END

            v2f vert(appdata v){
                v2f o;
                    
                o.normal = mul(unity_MatrixVP, v.normal);
                
                float4 worldPos = mul(unity_ObjectToWorld, float4(v.pos.xyz, 1.0));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                
                float dotProduct =  1 - saturate ( dot ( o.normal, ObjSpaceViewDir ( v.pos ) ) );
         
                o.fresnel = smoothstep(1 - _Rim, 1.0, dotProduct) * .5f;
                //o.fresnel = pow(dotProduct, _Rim);
                
                o.worldPos = worldPos;
                o.pos = mul(unity_MatrixVP, worldPos);
                //o.normal = v.normal;
                                
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uv = v.uv;
                return o;
            }

            
            float4 frag (v2f i) : SV_TARGET{
            
                float noise1 = voronoi(i.uv * _Noise1);
                noise1 = pow(noise1, 1);
                noise1 = smoothstep(0.2,0.8, noise1);
                
	            float light =  (saturate(dot(i.worldNormal, Main_Directional_Light.xyz)) * i.fresnel);                
	            light = saturate(pow(light, _Light));
                
                float noise2 = genNoise2(i.uv * _Noise2).x;
                noise2 = smoothstep(-1,0.6,noise2);
                noise2 = sin(noise2 * 3.14)*0.5 + 0.5;
                
                float stars = genNoise2(i.uv * 12).x;
                stars = smoothstep(0,0.16,pow(stars, 4));
                
                float4 col = tex2D(_MainTex, i.uv);
                
                //return lerp(_BaseColor * col, pow(i.fresnel, _FresnelPower) * _Color, i.fresnel);
                //return noise2;
                //return _VeinColor * noise1 * pow(light,0.5);
                return stars * _DotsColor + 
                    lerp(
                        noise2 * _Color + (1-noise2) * _BaseColor,
                        _VeinColor,
                        noise1 * smoothstep(0.0,0.2,light)//noise1 * pow(light,0.8)
                    ) +
                    light * _ScatteringColor
                ;
            }
            
            ENDHLSL
        }
    }
}

