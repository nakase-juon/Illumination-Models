Shader "Custom/FlowImageOld"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TexPower ("Texture Color Strength", Range(0.1, 1.0)) = 0.1
        _Speed("Speed",Range(0,100)) = 10
    }
    SubShader
    {
        //半透明
        Tags { "Queue"="Transparent" "RenderType" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        
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
            };

            struct v2f
            {
                float4 vertex :SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
            sampler2D _MainTex;
            float _TexPower;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
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
