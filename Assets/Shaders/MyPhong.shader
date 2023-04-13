Shader "Custom/MyPhong"
{
    Properties
    {
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _BlightPower ("Blight Power", Range(0, 10)) = 1
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
                float3 normal : TEXCOORD0; // 法線
                float4 vertex : SV_POSITION; // クリップスペース位置
            };
            
            float4 _MainColor;
            half _BlightPower;

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
                
                //視線ベクトルviewは物体表面上の点の位置ベクトルの逆ベクトルになるので-を付けて正規化
                float3 view = -normalize(i.vertex);
                //halfway=light+view
                //光線ベクトルと視線ベクトルの中間ベクトルを求め正規化
                float3 halfway = normalize(light + view);
                //鏡面反射率specularには，この中間ベクトルhalfwayと法線ベクトルnormalの内積を求め，
                //max() 関数を使って負の値が0になるようにした後，pow()を使って_BlightPowerの値
                //によるべき乗したものを用いる．
                float specular = pow(max(dot(normal, halfway), 0.0), _BlightPower);

                //各ピクセル(面毎)に色の強さと色をかけた値を返す。(0に近づくほど黒い)
                return diffuse * _MainColor + specular * _MainColor;
            }
            ENDCG
        }
    }
}