// Shader from github
// credits: smkplus/UnityShaderFFS.md

Shader "MaterialPropertyDrawer"
{
    Properties
    {
        _MainTex_REMOVE("Texture", 2D) = "white" {}
         
        [HideInInspector] _MainTex2("Hide Texture", 2D) = "white" {}
         
        [NoScaleOffset] _MainTex3("No Scale/Offset Texture", 2D) = "white" {}
         
        [PerRendererData] _MainTex4("PerRenderer Texture", 2D) = "white" {}
         
        [Normal] _MainTex5("Normal Texture", 2D) = "white" {}
         
        _Color("Color", Color) = (1,0,0,1)
         
        [HDR] _HDRColor("HDR Color", Color) = (1,0,0,1)
         
        _Vector("Vector", Vector) = (0,0,0,0)
         
        //Can't go below zero
        [Gamma] _GVector("Gamma Vector", Vector) = (0,0,0,0)
         
        // Header creates a header text before the shader property.
        [Header(A group of things)]
         
        // Will set "_INVERT_ON" shader keyword when set
        [Toggle] _Invert("Auto keyword toggle", Float) = 0
         
        // Will set "ENABLE_FANCY" shader keyword when set.
        [Toggle(ENABLE_FANCY)] _Fancy("Keyword toggle", Float) = 0
         
        // Will show when ENABLE_FANCY is true //Feature request
        //[ShowIf(ENABLE_FANCY)] _ShowIf("Show If", Float) = 0
                 
        // Blend mode values
        [Enum(UnityEngine.Rendering.BlendMode)] _Blend("Blend mode Enum", Float) = 1
         
        // A subset of blend mode values, just "One" (value 1) and "SrcAlpha" (value 5).
        [Enum(One,1,SrcAlpha,5)] _Blend2("Blend mode subset", Float) = 1
         
        // Each option will set _OVERLAY_NONE, _OVERLAY_ADD, _OVERLAY_MULTIPLY shader keywords.
        [KeywordEnum(None, Add, Multiply)] _Overlay("Keyword Enum", Float) = 0
        // ...later on in CGPROGRAM code:
        //#pragma multi_compile _OVERLAY_NONE, _OVERLAY_ADD, _OVERLAY_MULTIPLY
        // ...
         
        // A slider with 3.0 response curve
        [PowerSlider(3.0)] _Shininess("Power Slider", Range(0.01, 1)) = 0.08
         
        // An integer slider for specified range (0 to 255)
        [IntRange] _Alpha("Int Range", Range(0, 255)) = 100
         
        // Default small amount of space.
        [Space] _Prop1("Small amount of space", Float) = 0
         
        // Large amount of space.
        [Space(50)] _Prop2("Large amount of space", Float) = 0
        
        // Controlling fixed function states from materials
        [Header(Main Color)]
        [Toggle] _UseColor("Enabled?", Float) = 1
        _Color("Main Color", Color) = (1,1,1,1)
        [Space(5)]

        [Header(Base(RGB))]
        [Toggle] _UseMainTex("Enabled?", Float) = 1
        _MainTex("Base (RGB)", 2D) = "white" {}
		//[NoScaleOffset] _MainTex("Base (RGB)", 2D) = "white" {}
        [Space(5)]

        [Header(Blend State)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("SrcBlend", Float) = 1 //"One"
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("DestBlend", Float) = 0 //"Zero"
        [Space(5)]

        [Header(Other)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("Cull", Float) = 2 //"Back"
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("ZTest", Float) = 4 //"LessEqual"
        [Enum(Off,0,On,1)] _ZWrite("ZWrite", Float) = 1.0 //"On"
        [Enum(UnityEngine.Rendering.ColorWriteMask)] _ColorWriteMask("ColorWriteMask", Float) = 15 //"All"
     
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100
        Blend[_SrcBlend][_DstBlend]
        ZTest[_ZTest]
        ZWrite[_ZWrite]
        Cull[_Cull]
        ColorMask[_ColorWriteMask]
        
        Pass
        {
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"
            
            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f
            {
                half2 texcoord  : TEXCOORD0;
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
            };
            
            sampler2D _MainTex;
            fixed4 _Color;
            float _Speed;
            float _UseColor;
            float _UseMainTex;
            
            
            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color;
                return OUT;
            }
            
            float4 frag (v2f i) : COLOR
            {
                float2 uv = i.texcoord.xy;
                float4 tex = lerp(float4(1,1,1,1),tex2D(_MainTex, uv)*i.color,_UseMainTex);
            
                return lerp(tex,tex*_Color,_UseColor);
            }
            ENDCG
        }
    }
    Fallback "Sprites/Default"
}