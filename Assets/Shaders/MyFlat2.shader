// This code does not work correctly.
// Reference URL:
// https://github.com/miguel12345/UnityFlatShading/blob/master/Assets/FlatShading/Shaders/FlatShading.shader
Shader "Custom/MyFlat2"
{
    Properties
    {
        _MainColor ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        CGPROGRAM
        #pragma surface surfStandard Standard fullforwardshadows nolightmap vertex:vert
        #pragma target 3.0
        
        struct Input {
            float2 uv_MainTex;
            float3 normal;
            float3 tangent;
            float3 modelPos;
        };  		
                          
        void vert (inout appdata_full v, out Input o) {
            UNITY_INITIALIZE_OUTPUT(Input,o);
            
            o.normal = v.normal;
            o.tangent = v.tangent.xyz;
            o.modelPos = v.vertex;
        }

        float3 calcSurfaceNormalInTangentSpace(Input IN) {
            //Since surface shaders require the normal to be in vertex-interpolated tangent space
            //we need to first, get that tangent space, and convert the surface normal to that space
            
            //1 - get interpolated tanget space basis vectors
            float3 tangent = normalize(IN.tangent);
            float3 normal = normalize(IN.normal);
            float3 binormal = normalize(cross(tangent,normal));
            
            //2 - get local-space surface normal
            float3 surfaceNormal = normalize(cross(ddy(IN.modelPos),ddx(IN.modelPos)));
            
            //3 - convert surface normal calculated in 2) to tangent-space calculated in 1)
            float3x3 tangentSpaceBasisMatrix = float3x3(tangent, binormal, normal);
            float3x3 tangentSpaceInverse = transpose(tangentSpaceBasisMatrix); // since we have an orthonormal matrix, the transpose is equal to its inverse
            float3 surfaceNormalInTangentSpace = mul(tangentSpaceInverse,surfaceNormal);
            
            return surfaceNormalInTangentSpace;
        }
        
        float4 _MainColor;
        sampler2D _MainTex;
        half _Glossiness;
		half _Metallic;

        void surfStandard (Input IN, inout SurfaceOutputStandard o) {
            o.Normal = calcSurfaceNormalInTangentSpace(IN);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainColor;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
        }
        ENDCG
    }
}