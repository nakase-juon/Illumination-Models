Shader "Custom/MyGouraud2"
{
    Properties
    {
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _ReflectionLevel("Reflection Level", Range(0, 10)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION; // 頂点の位置
                float3 normal   : NORMAL; // 法線
            };

            struct v2f
            {
                float4 vertex : SV_POSITION; // 頂点のクリップの最終的な空間位置
                float3 normal   : NORMAL;    // 法線
                float4 worldPos : TEXCOORD0; // テクスチャ座標
            };

            float4 _MainColor;
            half _ReflectionLevel;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);      //頂点をMVP行列変換
                o.worldPos = v.vertex;                          //各頂点のワールド座標を代入
                o.normal = mul(unity_ObjectToWorld, v.normal);  //各頂点が持つ法線（オブジェクト座標系）をワールド座標系に変換(行列乗算)

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //法線を正規化
                float3 normal = normalize(i.normal);
                //シーンのディレクショナルライト方向を取得、正規化
                float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
                //ディレクショナルライトのカラーを取得
                fixed3 lightColor = _LightColor0.xyz; 
                //diffuse=n・l
                //面の法線と光源ベクトルの内積(cosθ)を求め、0-1の値に直す
                float diffuse = saturate(dot(normal, lightDirection));
                
                // //ライト方向と法線方向から反射ベクトルを計算
                // float3 refVec = reflect(-lightDirection, i.normal); 

                //カメラからの視線ベクトルを計算、正規化
                float3 view = normalize(_WorldSpaceCameraPos - i.worldPos);
                //光源ベクトル、視線ベクトルから中間ベクトルを求める
                float3 halfway = normalize(lightDirection + view);
                //鏡面反射率計算
                float specular = pow(max(dot(normal, halfway), 0.0), _ReflectionLevel);

                _MainColor.rgb *= lightColor;
                return (diffuse + specular) * _MainColor;
            }
            ENDCG
        }
    }
}