Shader "Home/YL_DissolveEfc"
{
    Properties
    {
        [Header(Base)]
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",Color)= (0,0,0,0)
        _Clip("Clip",Range(0,1))=0
        [Header(D)]
        _DissloveTex("Disslove(R)",2D) = "white"{}
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
            fixed4  _Color;
            fixed _Clip;

            struct appdata{
                float4 vertex:POSITION;
                float2 uv:TEXCOORD;

            };

            struct v2f{
                float4 vertex:SV_POSITION;
                float2 uv:TEXCOORD1;
                float4 dissolveUV:TEXCOORD2;
            };
            //顶点着色器
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uv = v.uv;
                // o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                // o.dissolveUV.xy = v.uv*_DissloveTex_ST.xy+_DissloveTex_ST.zw;
                o.dissolveUV.xy = TRANSFORM_TEX(v.uv,_DissloveTex);
                return o;
            }

            //片段着色器
            fixed4 frag(v2f i):SV_TARGET
            {
                fixed4 c;
                fixed4 col = tex2D(_MainTex,i.uv);
                c= col;
                c+=_Color;
                //采样溶解贴图
                fixed4 dissloveTex = tex2D(_DissloveTex,i.dissolveUV.xy*_DissloveTex_ST.xy+_DissloveTex_ST.zw);
                clip(dissloveTex.r-_Clip);
                return c;
            }
            
            ENDCG
        }
    }
}
