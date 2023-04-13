Shader "Custom/MyFlat"
{
    Properties
    {
        _MainColor ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            // "vert" 関数を頂点シェーダーとして使います
            #pragma vertex vert
            // "frag" 関数をピクセル (フラグメント) シェーダーとして使います
            #pragma fragment frag
            // appdata_baseを使いたいのでinclude
            #include "UnityCG.cginc"

            // vertex shader outputs ("vertex to fragment")
            struct v2f
            {
                nointerpolation float3 normal : TEXCOORD0; // 法線(nointerpolationで頂点シェーダーの出力を補完しないようにする。)
                float4 vertex : SV_POSITION; // クリップスペース位置
            };
            
            float4 _MainColor;

            // 頂点シェーダー
            v2f vert (appdata_base v)
            {
                v2f o;

                //点をオブジェクト空間からビュー空間へ変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                //法線をオブジェクト空間からワールド空間法線へ変換
                o.normal = UnityObjectToWorldNormal(v.normal);
                
                return o;
            }
            
            
            // ピクセルシェーダー; 低精度を返します ("fixed4" 型)
            // color ("SV_Target" セマンティック)
            fixed4 frag (v2f i) : SV_Target
            {
                //法線を正規化
                float3 normal = normalize(i.normal);
                //光源方向のベクトルを正規化
                float3 light = normalize(_WorldSpaceLightPos0.xyz);
                //diffuse=n・l
                //面の法線と光源ベクトルの内積(cosθ)を求め、0-1の値に直す
                float diffuse = saturate(dot(normal, light));
                
                //各ピクセル(面毎)に色の強さと色をかけた値を返す。(0に近づくほど黒い)
                return diffuse * _MainColor;
            }
            ENDCG
        }
    }
}