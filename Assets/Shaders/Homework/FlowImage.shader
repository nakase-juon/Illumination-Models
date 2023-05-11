Shader "Custom/FlowImage"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TexPower ("Texture Color Strength", Range(0.1, 1.0)) = 0.1
        _Speed("Speed",Range(0,100)) = 10
        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Power", Range(0.5, 8.0)) = 3.0
    }
    SubShader
    {
        //半透明
        Tags { "Queue"="Transparent" "RenderType" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        
        Pass
        {
            ZWrite ON
            ColorMask 0 //モデルは描画せずにzバッファのみに書き込み
        }
        
        CGPROGRAM
        #pragma surface surf Lambert alpha:blend

        struct Input
        {
            float3 viewDir;
            float2 uv_MainTex;
        };

        float4 _RimColor;
        float _RimPower;
        sampler2D _MainTex;

        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 color = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = color.rgb;
            half rim = 1.0 - abs(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = color.rgb * pow(rim, _RimPower);
            o.Alpha = 0.5;
        }
        ENDCG
        
        Pass{
            Tags { "Queue"="Transparent" "RenderType" = "Transparent"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            #pragma target 3.0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex :SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float _Speed;
            float _TexPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 時間経過でテクスチャが下にスクロールする
                float t = _Time * _Speed;
                o.uv.x = v.uv.x;
                o.uv.y = sin(t + v.uv.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                color.rgb *= _TexPower;
                color.a = 0.5;
                return color;
            }

            ENDCG
        }
    }
}
