Shader "Home/DistortEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            sampler2D _MainTex;
            float4 _MainTex_ST;
            // struct appdata
            // {
                //     float4 vertex : POSITION;
                //     float2 uv : TEXCOORD0;
            // };

            struct v2f
            {
                float2 uv : TEXCOORD0;
            };
            

            v2f vert ( float4 vertex:POSITION,out float4 pos:SV_POSITION)
            {
                v2f o;
                 pos= UnityObjectToClipPos(vertex);
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i,UNITY_VPOS_TYPE screenPos :VPOS) : SV_Target
            {

                fixed2 screenUV = screenPos.xy/_ScreenParams.xy;
                // sample the texture
                // fixed4 col = tex2D(_MainTex, i.uv);
                return fixed4(screenUV.xy,0,1);
            }
            ENDCG
        }
    }
}
