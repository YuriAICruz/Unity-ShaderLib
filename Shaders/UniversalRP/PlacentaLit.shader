Shader "Graphene/URP/Placenta"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _EmissionMap ("Emission Map", 2D) = "white" {}
        _Rmas ("RMAS Texture", 2D) = "white" {}
        _Roughness ("Roughness", Range(0,1)) = 0
        
        _ScatteringColor ("Scattering Color", COLOR) = (1,1,1,1)
        _Light ("Light Attenuation", Float) = 0
        _FresnelColor ("Fresnel Color (F0)", Color) = (1.0, 1.0, 1.0, 1.0)
        _Anisotropy ("Anisotropy", Range(0,1)) = 0
    }
    
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent"}
        
        Cull Back
        
        Blend SrcAlpha OneMinusSrcAlpha
            
        Pass
        {
            HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            #include "Lighting.cginc"
            #include "PBRLib.cginc"
			
            sampler2D _MainTex;
            sampler2D _EmissionMap;
            sampler2D _NormalMap;
            sampler2D _Rmas;
            
			float4 _ScatteringColor;
			float4 _FresnelColor;
			float4 Main_Directional_Light;
			float _Light;
			float _Roughness;
			float _Anisotropy;
			
			struct appdata {
                float4 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float4 tangent: TANGENT;
            };
            
            struct v2f {

                float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent: TEXCOORD2;
                float3 bitangent: TEXCOORD3;
                float3 worldPos : TEXCOORD4;

                float3 tangentLocal: TEXCOORD5;
                float3 bitangentLocal: TEXCOORD6;
            };
            
            v2f vert(appdata v){
            
                v2f o;           
                o.uv = v.uv;
                o.position = UnityObjectToClipPos(v.position);
                o.worldPos = mul(unity_ObjectToWorld, v.position);

                
                // Normal mapping parameters
                o.tangent = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
                o.normal = normalize(UnityObjectToWorldNormal(v.normal));
                o.bitangent = normalize(cross(o.normal, o.tangent.xyz));

                o.tangentLocal = v.tangent;
                o.bitangentLocal = normalize(cross(v.normal, o.tangentLocal));
                return o;
            }

            float4 pbr (float3 albedo, v2f i)
            {
                if (_WorldSpaceLightPos0.w == 1)
                    return float4(0.0, 0.0, 0.0, 0.0);

                // Just for mapping the 2d texture onto a sphere
                float2 uv = i.uv;
                
                // VECTORS

                // Assuming this pass goes only for directional lights
                // float3 lightVec =  normalize(_WorldSpaceLightPos0.xyz);
                float3 lightVec =  normalize(Main_Directional_Light.xyz);
                
                float3 viewVec = normalize(_WorldSpaceCameraPos.xyz - i.worldPos);
                float3 halfVec = normalize(lightVec + viewVec);

                // Calculate the tangent matrix if normal mapping is applied
                float3x3 tangentMatrix = transpose(float3x3(i.tangent, i.bitangent, i.normal));
                float3 normal = mul(tangentMatrix, tex2D(_NormalMap, uv).xyz * 2 - 1);

                float3 reflectVec = -reflect(viewVec, normal);
                
                float min = 0.4;

                // DOT PRODUCTS
                float NdotL = max(dot(i.normal, lightVec), min);
                float NdotH = max(dot(normal, halfVec), min);
                float HdotV = max(dot(halfVec, viewVec), min);
                float NdotV = max(dot(i.normal, viewVec), min);
                float HdotT = dot(halfVec, i.tangentLocal);
                float HdotB = dot(halfVec, i.bitangentLocal);

                // PBR PARAMETERS
                
                // This assumes that the maximum param is right if both are supplied (range and map)
                float4 rmas = tex2D(_Rmas, uv);
                float roughness = rmas.r * _Roughness;
                float metalness =  rmas.g;
                float occlusion = rmas.b;

                float3 F0 = lerp(float3(0.04, 0.04, 0.04), _FresnelColor * albedo, metalness);

                float D = trowbridgeReitzNDF(NdotH, roughness);
                //D = trowbridgeReitzAnisotropicNDF(NdotH, roughness, _Anisotropy, HdotT, HdotB);
                float3 F = fresnel(F0, NdotV, roughness);
                float G = schlickBeckmannGAF(NdotV, roughness) * schlickBeckmannGAF(NdotL, roughness);
                

                // DIRECT LIGHTING

                // Normals from normal map
                float lambertDirect = max(dot(normal, lightVec), min);
                
                float3 directRadiance = _LightColor0.rgb * occlusion;

                // INDIRECT LIGHTING
                float3 diffuseIrradiance = sRGB2Lin(UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, normal, UNITY_SPECCUBE_LOD_STEPS).rgb) * occlusion;
                float3 specularIrradiance = sRGB2Lin(UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectVec, roughness * UNITY_SPECCUBE_LOD_STEPS).rgb) * occlusion;

                // DIFFUSE COMPONENT
                float3 diffuseDirectTerm = lambertDiffuse(albedo) * (1 - F) * (1 - metalness);// * _AlbedoColor;
                
                // SPECULAR COMPONENT
                float3 specularDirectTerm = G * D * F / (4 * NdotV * NdotL + EPS);
                
                // DIRECT BRDF OUTPUT
                float3 brdfDirectOutput = (diffuseDirectTerm + specularDirectTerm) * lambertDirect * directRadiance;

                // Add constant ambient (to boost the lighting, only temporary)
                float3 ambientDiffuse = diffuseIrradiance * lambertDiffuse(albedo) * (1 - F) * (1 - metalness);

                // For now the ambient specular looks quite okay, but it isn't physically correct
                // TODO: try importance sampling the NDF from the environment map (just for testing & performance measuring)
                // TODO: implement the split-sum approximation (UE4 paper)
                float3 ambientSpecular = specularIrradiance * F;

                return float4(gammaCorrection(brdfDirectOutput + ambientDiffuse + ambientSpecular), 1.0);
            }
            
            float4 frag (v2f i) : SV_TARGET{
                // TEXTURE SAMPLES
                float4 albedo = float4(sRGB2Lin(tex2D(_MainTex, i.uv)), 1);
                float4 emission = float4(sRGB2Lin(tex2D(_EmissionMap, i.uv)), 1);
                
                float4 color = pbr(albedo, i);
                
	            float light = saturate(dot(i.normal, Main_Directional_Light.xyz));                
	            light = saturate(pow(light, _Light));
	            
	            color.rgb = color + emission * light * _ScatteringColor;
	            
	            color.a  = saturate( pow(1-light, 0.1));
	            
	            return color;
            }
            
            ENDHLSL
        }
    }
}

