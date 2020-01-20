// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Graphene/Sprites/Glow"
{
    Properties
    {
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		NoiseSize ("Noise Size", Float) = 1
		ScrollSpeed ("Scroll Speed", Float) = 0
		ColorSpeed ("Color Speed", Float) = 0
    }
    SubShader
    {
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		    CGPROGRAM		   
		    
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#include "UnityCG.cginc"
            #include "Noise.cginc"
			
			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				float4 worldpos : COLOR1;
			};
			

			sampler2D _MainTex;
			sampler2D _AlphaTex;
			float _AlphaSplitEnabled;
			float NoiseSize;
			float ScrollSpeed;
			float ColorSpeed;
			fixed4 _Color;

			v2f vert(appdata_t IN)
			{
				v2f OUT;
				
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				OUT.worldpos = ComputeScreenPos(OUT.vertex);
				//mul (unity_ObjectToWorld, IN.vertex)
				//ComputeScreenPos(IN.vertex)
				
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv, float4 worldpos)
			{
				fixed4 color = tex2D (_MainTex, uv);
                
                float3 hsv = rgb2hsv(color.rgb);
                float noise = genNoise((worldpos+_Time.y*ScrollSpeed) * NoiseSize);
                hsv.x += _Time.y*ColorSpeed;
                hsv.y = noise*5;
                color.rgb = hsv2rgb(hsv);
                //color.rgb = genNoise((worldpos+Time) * NoiseSize);
                
#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
				if (_AlphaSplitEnabled)
					color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

				return color;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (IN.texcoord, IN.worldpos) * IN.color;
				//c.rgb = IN.noise;
				c.rgb *= c.a;
				//c.rgb *= IN.noise2.x;
				return c;
			}
		ENDCG
		}
	}
}
