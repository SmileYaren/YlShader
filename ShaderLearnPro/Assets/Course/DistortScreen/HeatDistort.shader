Shader "Home/HeatDistort"
{
    Properties
    {

        _DistortTex ("DistortTex", 2D) = "white" {}

        _Distort("Distort",Range(0,1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }

        GrabPass{
            "_GrabTex"
        }
        
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"


            // struct appdata
            // {
            //     float4 vertex : POSITION;
            //     float2 uv : TEXCOORD0;
            // };

            struct v2f
            {
                float2 uv : TEXCOORD0;
            };


            sampler2D _DistortTex;
            sampler2D _GrabTexture;
            fixed _Distort;

            v2f vert (float4 vertex:POSITION,float2 uv:TEXCOORD,out float4 pos:SV_POSITION)
            {
                v2f o;
                pos = UnityObjectToClipPos(vertex);
                o.uv = uv;
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos:VPOS) : SV_Target
            {

                float2 screenUV = screenPos.xy/_ScreenParams.xy;
                // sample the texture
                
                //扭曲纹理采样
                fixed4 distortTex = tex2D(_DistortTex,i.uv);
                float2 tmpUV = lerp(screenUV,distortTex,_Distort);
                //抓取纹理
                fixed4 grabTex = tex2D(_GrabTexture, tmpUV);

                return grabTex;
            }
            ENDCG
        }
    }
}
