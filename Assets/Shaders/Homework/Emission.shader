Shader "Custom/Emission"
{
    Properties
    {
        _DiffuseColor ("Diffuse Color", Color) = (1,1,1,1)
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
        _EmissionPower("Emission Power", Range(0.01, 30.0)) = 3.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert
        #pragma target 3.0

        float4 _DiffuseColor;
        float4 _EmissionColor;
        float _EmissionPower;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _DiffuseColor.rgb;
            o.Emission = _EmissionColor.rgb * _EmissionPower;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
