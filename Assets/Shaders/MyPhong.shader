// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

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


            struct vertexInput {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
            };

            struct fragmentInput {
                float3 normal : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _MainColor;
            half _BlightPower;
            
            fragmentInput vert(appdata_base v) {
                fragmentInput o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = normalize(v.normal);
                return o;
            }

            float4 frag(fragmentInput i) : COLOR {
                float3 light = normalize(_WorldSpaceLightPos0.xyz);
                float3 fnormal = normalize(i.normal);
                float diffuse = saturate(max(dot(fnormal, light), 0.0));

                //視線ベクトルviewは物体表面上の点の位置ベクトルの逆ベクトルになるので-を付けて正規化
                float3 view = -normalize(i.vertex);
                //halfway=light+view
                //光線ベクトルと視線ベクトルの中間ベクトルを求め正規化
                float3 halfway = normalize(light + view);
                //鏡面反射率specularには，この中間ベクトルhalfwayと法線ベクトルnormalの内積を求め，
                //max() 関数を使って負の値が0になるようにした後，pow()を使って_BlightPowerの値
                //によるべき乗したものを用いる．
                float specular = pow(max(dot(fnormal, halfway), 0.0), _BlightPower);

                //各ピクセル(面毎)に色の強さと色をかけた値を返す。(0に近づくほど黒い)
                return diffuse * _MainColor + specular * _MainColor;
            }
            
            ENDCG
        }
    }
}