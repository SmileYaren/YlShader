Shader "Home/YL_DissolveEfc"
{
    Properties
    {
        [Header(Base)]
        [NoScaleOffset]_MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)= (0,0,0,0)
        _Clip("Clip",Range(0,1))=0
        _Debug("Debug",float) = 0
        [Header(D)]
        _DissloveTex("Disslove(R)",2D) = "white"{}

        [NoScaleOffset] _RampTex("RampTex",2D) = "white"{}
    }
    SubShader
    {
        // Tags { "RenderType"="Opaque" }
        // LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            float4 _MainTex_ST;
            sampler2D _MainTex;
            sampler2D _DissloveTex;float4 _DissloveTex_ST;
            sampler _RampTex;
            fixed4  _Color;
            fixed _Clip;
            float _Debug;

            struct appdata{
                float4 vertex:POSITION;
                float2 uv:TEXCOORD;

            };

            struct v2f{
                float4 vertex:SV_POSITION;
                float2 uv:TEXCOORD1;
                float2 dissolveUV:TEXCOORD2;
            };
            //顶点着色器
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uv = v.uv;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.dissolveUV.xy = v.uv*_DissloveTex_ST.xy+_DissloveTex_ST.zw;
                o.dissolveUV = TRANSFORM_TEX(v.uv,_DissloveTex);
                return o;
            }

            //片段着色器
            fixed4 frag(v2f i):SV_TARGET
            {
                fixed4 c;
                fixed4 col = tex2D(_MainTex,i.uv);
                c= col;
                c+=_Color;
                //采样溶解贴图  _DissloveTex_ST.xy 等于 tiling 的 xy  ，_DissloveTex_ST.zw等于 offset 的xy
                fixed4 dissloveTex = tex2D(_DissloveTex,i.dissolveUV);
                clip(dissloveTex.r-_Clip);

                //消融效果 从黄黑图RampTex中采样颜色，位置使用无序图 value=1 对应RampTex上的u=1的颜色

                fixed4 rampTex = tex1D(_RampTex,smoothstep(_Clip-0.02f,_Clip+0.08,dissloveTex.r));
                c+=rampTex;
                return c;
            }
            
            ENDCG
        }
    }
}
