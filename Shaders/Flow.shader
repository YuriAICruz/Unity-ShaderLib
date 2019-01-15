// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Graphene/FluidFx/Flow"
{
    Properties {
        _MainTex ("Texture", 2D) = "grey" {}
        _Color ("Color", Color) = (1,1,1,1)
        _FlowMap ("Flow Map", 2D) = "grey" {}
        _Normal ("Normal", 2D) = "grey" {}
        
        _Smoothness ("Smoothness", Range(0,1)) = 0
        _Metallic ("Metallic", Range(0,1)) = 0
        _Alpha ("Alpha", Range(0,1)) = 1
        _ShadowIntensity ("Shadow Intensity", Range (0, 1)) = 0.6
        
        [Header(Waves)]
        _Speed ("Speed", float) = 0.2
        _Frequency ("Frequency", float) = 2.4
        _Intensity ("Intensity", float) = 6
        _Angle ("Angle", float) = 8
        _Steps ("Turbulence", Range(0,10)) = 7
        
        [Header(Flow)]
        _Size ("Size", float) = 1
        _FlowSpeed ("Flow Speed", float) = 0.2
        _FlowIntensity ("Flow Intensity", float) = 0.2
        
        [Header(Reflection)]
        _ReflectionColor ("Reflection Color", Color) = (0,0,0,0)
        _ReflectionIntensity ("ReflectionIntensity", float) = 7
        _ReflectionCutOff ("ReflectionCutOff", float) = 0.012
        _ReflectionIntence ("ReflectionIntence", float) = 2
    }
 
    SubShader {
        Tags { "Queue"="AlphaTest" }
        
        CGPROGRAM
        #pragma surface surf Standard alpha:fade
		//#pragma target 3.0
		
        #include "UnityCG.cginc"
        #include "Noise.cginc"
        #include "Math.cginc"
        #include "Water.cginc"
        
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_BUFFER_START(Props)
        // put more per-instance properties here
		UNITY_INSTANCING_BUFFER_END(Props)
        
        struct Input {
			float2 uv_MainTex;
        };

        sampler2D _FlowMap;
        sampler2D _MainTex;
        sampler2D _Normal;
        fixed4 _Color;
            
        fixed _Speed;
        fixed _FlowSpeed;
        fixed _FlowIntensity;
        float _NoiseSize;
        float _ReflectionColor;
        float _Size;
        float _Steps;
        float _Angle;
        float _ReflectionIntensity;
        float _ReflectionCutOff;
        float _ReflectionIntence;
        float _Smoothness;
        float _Metallic;
        float _Intensity;
        float _Frequency;
        float _Alpha;
        
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
        
        void surf (Input v, inout SurfaceOutputStandard o) 
        {            
            //Flow Calc
            half3 flowVal = (tex2D(_FlowMap, v.uv_MainTex*_Size) - 0.5) * _FlowIntensity;
    
            float dif1 = frac(_Time.y * _FlowSpeed + 0.5);
            float dif2 = frac(_Time.y * _FlowSpeed);
    
            half lerpVal = abs((0.5 - dif1)*2);
            
            // Water
            float time = _Time.y * _Speed;
            
            // refraction
            float emboss = 0.50;
            float intensity = _Intensity;
            float frequency = _Frequency;
            
            // reflection
            float delta = 60.;
            float intence = 700.;
            _ReflectionIntence *= 100000;
    
            float2 p1 = v.uv_MainTex - flowVal.xy * dif1;                
            float2 p2 = v.uv_MainTex - flowVal.xy * dif2;  
            float2 p = lerp(p1, p2, lerpVal);
            float2 c1 = p, c2 = p;
            float cc1 = col(c1, time, _Speed, _Angle, _Steps, frequency, intensity);
                            
            c2.x += 1/delta;
            float dx = emboss*(cc1-col(c2,time, _Speed, _Angle, _Steps, frequency, intensity))/delta;
            
            c2.x = p.x;
            c2.y += 1/delta;
            float dy = emboss*(cc1-col(c2,time, _Speed, _Angle, _Steps, frequency, intensity))/delta;
            
            c1.x += dx*2.0;
            c1.y += dy*2.0;
            
            float alpha = 1.0 + dot(dx,dy)*intence;
            
            float ddx = dx * _ReflectionIntensity - _ReflectionCutOff;
            float ddy = dy * _ReflectionIntensity - _ReflectionCutOff;
            
            if (ddx > 0. && ddy > 0.)
                alpha = pow(alpha, ddx*ddy*-_ReflectionIntence);
                
            float4 cAlpha = _ReflectionColor*(1-alpha);
                
            float4 col1 = tex2D(_MainTex, c1 - flowVal.xy * dif1) + (cAlpha);                
            float4 col2 = tex2D(_MainTex, c1 - flowVal.xy * dif2) + (cAlpha);  
            float4 c = lerp(col1, col2, lerpVal);
            
            half3 n1 = UnpackNormal(tex2D(_Normal, c1 - flowVal.xy * dif1));
            half3 n2 = UnpackNormal(tex2D(_Normal, c1 - flowVal.xy * dif2));
            half3 tnormal = lerp(n1, n2, lerpVal);
            
            o.Albedo = c * _Color;
            o.Normal = tnormal;
            o.Smoothness = _Smoothness;
			o.Metallic = _Metallic;
            o.Alpha = _Alpha;
        }

        ENDCG
        
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            
            Cull Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
 
            #include "UnityCG.cginc"
            #include "AutoLight.cginc"
            
            uniform float _ShadowIntensity;

            struct v2f
            {
                float4 pos : SV_POSITION;
                LIGHTING_COORDS(0,1)
            };
            
            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                TRANSFER_VERTEX_TO_FRAGMENT(o);
               
                return o;
            }
            
            fixed4 frag(v2f i) : COLOR
            {
                float attenuation = LIGHT_ATTENUATION(i);
                float alpha = (1 - attenuation) * _ShadowIntensity;
               
                return fixed4(0,0,0 , alpha);
            }
            ENDCG
        }
    }
	FallBack "Diffuse"
}
