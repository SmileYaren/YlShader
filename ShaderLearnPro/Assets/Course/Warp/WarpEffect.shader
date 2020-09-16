Shader "Home/WarpEffect"
{
    Properties
    {

        [Hearder(RenderingMode)]
        [Enum(UnityEngine.Rendering.BlendMode)] _Src_Blend ("Src_Blend",int) = 0
        [Enum(UnityEngine.Rendering.BlendMode)] _Dst_Blend ("Dst_Blend",int) = 0
        [Hearder(Base)]
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color) =(0,0,0,0)
        _Intensity("Intensity",Range(-5,5)) = 1

        _MainUVSpeedX("MainUVSpeedX",float) = 0
        _MainUVSpeedY("MainUVSpeedY",float) = 0
        [Hearder(Mask)]
        [Toggle]_MaskEnabled("Mask Enable",int) = 0
        _MaskTex("MaskTex",2D) = "white"{}
        _MaskUVSpeedX("_MaskUVSpeedX",float) = 0
        _MaskUVSpeedY("_MaskUVSpeedY",float) = 0
        [Hearder(Distort)]
        [Toggle]DistortEnabled("DistortEnabled",int) = 0
        _DistortTex("DistortTex",2D) = "white"{}
        _Distort("Distort",Range(0,1)) = 0
        _DistortUVSpeedX("_DistortUVSpeedX",float) = 0
        _DistortUVSpeedY("_DistortVSpeedY",float) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Tags { "Queue"="Transparent+3" }

        Blend [_Src_Blend] [_Dst_Blend]

        Cull Off
        // Cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature _MASKENABLED_ON
            #pragma shader_feature _DISTORTENABLED_ON

            // make fog work
            #pragma multi_compile_fog
            //开关需要 加_On
            #include "UnityCG.cginc"
            float4 _Color;
            half  _Intensity;
            float _MainUVSpeedX,_MainUVSpeedY;
            sampler2D _DistortTex,_MaskTex;
            float4 _DistortTex_ST,_MaskTex_ST;
            float _MaskUVSpeedX,_MaskUVSpeedY;

            half _Distort;
            float _DistortUVSpeedX,_DistortUVSpeedY;
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv2:TEXCOORD1;

            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex)+float2(_MainUVSpeedX,_MainUVSpeedY)*_Time.y;
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex)+float2(_MaskUVSpeedX,_MaskUVSpeedY)*_Time.y;
                o.uv2 = TRANSFORM_TEX(v.uv,_DistortTex)+float2(_DistortUVSpeedX,_DistortUVSpeedY)*_Time.y;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col;
                col=_Color*_Intensity;//和颜色混合
                fixed2 distort = i.uv.xy;


                #if _DISTORTENABLED_ON //暂时不知道原因
                    // //采样扭曲纹理
                    fixed4 distortColor = tex2D(_DistortTex,i.uv2);
                    distort = lerp(i.uv,distortColor,_Distort);
                #endif
                // sample the texture
                fixed4 mainTexColor = tex2D(_MainTex,distort);
                col*=mainTexColor;

                //采样 遮罩纹理
                #if _MASKENABLED_ON
                    fixed4 maskColor = tex2D(_MaskTex,i.uv.zw);
                    col*=maskColor;
                #endif
                return col;
            }
            ENDCG
        }
    }
}
