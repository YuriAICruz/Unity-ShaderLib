// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Graphene/Skybox/ProceduralGradient" {
Properties {
[HDR]
    _SkyTint ("Sky Tint", Color) = (.5, .5, .5, 1)
[HDR]
    _GroundColor ("Ground", Color) = (.369, .349, .341, 1)
    
    _SkyGroundThreshold("Sky Ground Threshold", Range(0, 5)) = 0.02
    _Density("Density", Range(0, 1)) = 0.05
}

SubShader {
    Tags { "Queue"="Background" "RenderType"="Background" "PreviewType"="Skybox" }
    Cull Off ZWrite Off

    Pass {

        CGPROGRAM
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"
        #include "Lighting.cginc"

        uniform half3 _GroundColor;
        uniform half3 _SkyTint;
        uniform float _SkyGroundThreshold;
        uniform float _Density;

    #if defined(UNITY_COLORSPACE_GAMMA)
        #define GAMMA 2
        #define COLOR_2_GAMMA(color) color
        #define COLOR_2_LINEAR(color) color*color
        #define LINEAR_2_OUTPUT(color) sqrt(color)
    #else
        #define GAMMA 2.2
        // HACK: to get gfx-tests in Gamma mode to agree until UNITY_ACTIVE_COLORSPACE_IS_GAMMA is working properly
        #define COLOR_2_GAMMA(color) ((unity_ColorSpaceDouble.r>2.0) ? pow(color,1.0/GAMMA) : color)
        #define COLOR_2_LINEAR(color) color
        #define LINEAR_2_LINEAR(color) color
    #endif

    #ifndef SKYBOX_COLOR_IN_TARGET_COLOR_SPACE
        #if defined(SHADER_API_MOBILE)
            #define SKYBOX_COLOR_IN_TARGET_COLOR_SPACE 1
        #else
            #define SKYBOX_COLOR_IN_TARGET_COLOR_SPACE 0
        #endif
    #endif

        // Calculates the Rayleigh phase function
        half getRayleighPhase(half eyeCos2)
        {
            return 0.75 + 0.75*eyeCos2;
        }
        half getRayleighPhase(half3 light, half3 ray)
        {
            half eyeCos = dot(light, ray);
            return getRayleighPhase(eyeCos * eyeCos);
        }


        struct appdata_t
        {
            float4 vertex : POSITION;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f
        {
            float4  pos             : SV_POSITION;
            half    skyGroundFactor : TEXCOORD0;

            UNITY_VERTEX_OUTPUT_STEREO
        };

        v2f vert (appdata_t v)
        {
            v2f OUT;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
            OUT.pos = UnityObjectToClipPos(v.vertex);

            float3 eyeRay = normalize(mul((float3x3)unity_ObjectToWorld, v.vertex.xyz));


            OUT.skyGroundFactor = (-eyeRay.y+1) / (_SkyGroundThreshold);

            return OUT;
        }

        half4 frag (v2f IN) : SV_Target
        {
            half3 col = half3(0.0, 0.0, 0.0);

            half y = IN.skyGroundFactor;

            // if we did precalculate color in vprog: just do lerp between them
            //col = lerp(IN.skyColor, IN.groundColor, saturate(y));
            col = lerp(_SkyTint, _GroundColor, saturate(pow(y, _Density)));

        #if defined(UNITY_COLORSPACE_GAMMA) && !SKYBOX_COLOR_IN_TARGET_COLOR_SPACE
            col = LINEAR_2_OUTPUT(col);
        #endif

            return half4(col,1.0);

        }
        ENDCG
    }
}


Fallback Off
}
