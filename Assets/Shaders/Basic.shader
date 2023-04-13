Shader "Holistic/Basic" 
{
    Properties {
        _myColor ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        float4 _myColor;

        struct Input {
            float2 uv_mainTex;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = _myColor.rgb;
        }
      
      ENDCG
    }
    Fallback "Diffuse"
  }