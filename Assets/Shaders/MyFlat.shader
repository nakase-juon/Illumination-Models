Shader "Custom/MyFlat"
{
    Properties
    {
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _RimColor ("Rim Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            // "vert" 関数を頂点シェーダーとして使います
            #pragma vertex vert
            // "frag" 関数をピクセル (フラグメント) シェーダーとして使います
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            // appdata_baseを使いたいのでinclude
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            
            // vertex shader outputs ("vertex to fragment")
            struct v2f
            {
                float4 pos : SV_POSITION; // クリップスペース位置
                nointerpolation float3 normal : NORMAL; // 法線(nointerpolationで頂点シェーダーの出力を補完しないようにする。)
                float3 viewDir : TEXCOORD0;
                SHADOW_COORDS(1)
            };
            
            float4 _MainColor;
            float4 _RimColor;

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;

                //点をオブジェクト空間からビュー空間へ変換
                o.pos = UnityObjectToClipPos(v.vertex);
                //法線をオブジェクト空間からワールド空間法線へ変換
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                TRANSFER_SHADOW(o)
                
                return o;
            }
            
            
            // ピクセルシェーダー; 低精度を返します ("fixed4" 型)
            // color ("SV_Target" セマンティック)
            fixed4 frag (v2f i) : SV_Target
            {
                //法線を正規化
                float3 N = normalize(i.normal);
                //光源方向のベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                //diffuse = N・L
                //面の法線と光源ベクトルの内積(cosθ)を求め、-1-0の値はいらないので0-1の値で返す
                float diffuse = max(0.0, dot(N,L));

                fixed4 shadow = SHADOW_ATTENUATION(i);
                //各ピクセル(面毎)に色の強さと色をかけた値を返す。(0に近づくほど黒い)
                return diffuse * _LightColor0 * _MainColor * shadow;
            }
            ENDCG
        }
        
        Pass
        {
            Tags {"LightMode" = "ShadowCaster"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}