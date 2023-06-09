Shader "Custom/InsideSphere"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _RimColor("Rim Color", Color) = (0, 0, 0, 1)
        _RimPower("Rim Power", Range(0.01, 30.0)) = 3.0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float3 viewDir;
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        float4 _RimColor;
        float _RimPower;
    
        void surf(Input IN, inout SurfaceOutput o)
        {
            half4 color = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = color.rgb;
            half rim = 1.0 - abs(dot(normalize(IN.viewDir), o.Normal));
            o.Emission = _RimColor.rgb * pow(rim, _RimPower * _RimPower);
        }
        ENDCG
        
        Pass
        {
            Tags {"Queue" = "Geometry"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * 2.5;
                o.uv.x -= _Time;
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color = tex2D(_MainTex, i.uv);
                return fixed4(color.rgb, 1);
            }
            ENDCG
        }
    }
}
