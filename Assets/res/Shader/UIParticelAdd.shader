Shader "17zuoye/UI Particle Addtive"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (0.5,0.5,0.5,0.5)

        _SpeedU("横向速度", float) = 0
		_SpeedV("纵向速度", float) = 0

        _ColorAdd("亮度",float) = 2

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
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

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha one
        ColorMask [_ColorMask]              

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc" // 2D Mask 剪裁。

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 uv : TEXCOORD0;
                float4 worldPosition : TEXCOORD1; // 2D Mask 剪裁。
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
			float4 _MainTex_ST;

            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect; // 2D Mask 剪裁。

            float _SpeedU;
			float _SpeedV;
            float _ColorAdd;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;  // 2D Mask 剪裁。
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
 				OUT.uv.xy +=  float2(_SpeedU, _SpeedV ) * _Time.x;

                OUT.color = v.color;
                return OUT;
            }


            fixed4 frag(v2f IN) : SV_Target
            {
				fixed4 albedo = tex2D(_MainTex, IN.uv);
				
				fixed4 color = _ColorAdd * IN.color * _Color * albedo;
                #ifdef UNITY_UI_CLIP_RECT
                	color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect); // 2D Mask 剪裁。
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
                #endif

                return color;
            }

			
        ENDCG
        }
    }
}
