Shader "Holistic/TextureAlbedo" 
{
    Properties {
        _myDiffuse ("Diffuse Texture", 2D) = "white" {}
    }
    SubShader {

      CGPROGRAM
        #pragma surface surf Lambert
        
        sampler2D _myDiffuse;

        struct Input {
            float2 uv_myDiffuse;
        };
        
        void surf (Input IN, inout SurfaceOutput o) {
            o.Albedo = tex2D(_myDiffuse, IN.uv_myDiffuse).rgb;
        }
      ENDCG
    }
  }