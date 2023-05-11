// This code is not used.

Shader "Custom/v2fOnly"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TexPower ("Texture Color Strength", Range(0.1, 1.0)) = 0.1
        _Speed("Speed",Range(0,100)) = 10
        _RimPower("Rim Power", Range(0.5, 8.0)) = 3.0
    }
    SubShader
    {
        //半透明
        Tags { "Queue"="Transparent" "RenderType" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
//        Cull Off
        
        
        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #pragma target 3.0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex :SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
            };
            
            sampler2D _MainTex;
            float _Speed;
            float _TexPower;
            half _RimPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 時間経過でテクスチャが下にスクロールする
                float t = _Time * _Speed;
                o.uv.x = v.uv.x;
                o.uv.y = sin(t + v.uv.y);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                float3 V = normalize(i.viewDir); //view vector
                float3 N = normalize(i.worldNormal); //normalized surface normal

                color.rgb *= _TexPower;
                half rim = 1.0 - abs(dot(V, N));
                fixed3 emission = color.rgb * pow(rim, _RimPower);
                color.rgb += emission;
                color.a = 0.5;
                return color;
            }

            ENDCG
        }
    }
}
