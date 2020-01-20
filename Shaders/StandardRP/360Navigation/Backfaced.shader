Shader "Backfaced/Backfaced" {

	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {} 
	}

	SubShader{
		Tags{ "RenderType" = "Opaque" }

		Cull Front

		CGPROGRAM

		#pragma surface surf Lambert vertex:vert

		sampler2D _MainTex;
	fixed4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		void vert(inout appdata_full v)
		{
			v.normal.xyz = v.normal * -1;
		}

		
		void surf(Input IN, inout SurfaceOutput o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		ENDCG
	}
	
	Fallback "Diffuse"
}