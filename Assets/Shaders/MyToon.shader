Shader "Custom/Toon"
{
    Properties
    {
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _AmbientColor ("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)
        _SpecularColor ("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
        _Glossiness ("Specular Glossiness", Range(1, 32)) = 32
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimAmount("Rim Amount", Range(0, 1)) = 0.5
        
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };
            
            // vertex shader outputs ("vertex to fragment")
            struct v2f
            {
                float4 pos : SV_POSITION; // クリップスペース位置
                float3 worldNormal : NORMAL; // 法線(nointerpolationで頂点シェーダーの出力を補完しないようにする。)
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                SHADOW_COORDS(2)
            };
            
            float4 _MainColor;
            float4 _AmbientColor;
            float4 _SpecularColor;
            float _Glossiness;
            float4 _RimColor;
            float _RimAmount;

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
                o.viewDir = WorldSpaceViewDir(v.vertex);
                TRANSFER_SHADOW(o)
                return o;
            }
            
            
            // ピクセルシェーダー; 低精度を返します ("fixed4" 型)
            // color ("SV_Target" セマンティック)
            fixed4 frag (v2f i) : SV_Target
            {
                //法線、視線ベクトルを正規化
                float3 normal = normalize(i.worldNormal);
                float3 viewDir = normalize(i.viewDir);

                //法線とライトの内積を計算
                float NdotL = dot(_WorldSpaceLightPos0.xyz, normal);

                fixed shadow = SHADOW_ATTENUATION(i);

                // float lightIntensity = NdotL > 0 ? 1 : 0;
                float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);	
                float4 light = lightIntensity * _LightColor0;

                float3 halfVec = normalize(_WorldSpaceLightPos0.xyz + viewDir);
                float NdotH = dot(normal, halfVec);

                //Specular
                float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
                float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
                float4 specular = specularIntensitySmooth * _SpecularColor;

                float rimDot = 1 - dot(viewDir, normal);
                float rimIntensity = rimDot * pow(NdotL, 0.1);
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                float4 rim = rimIntensity * _RimColor;

                return (light + _AmbientColor + specular + rim) * _MainColor;;
            }
            ENDCG
        }
    }
}