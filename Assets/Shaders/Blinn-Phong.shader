Shader "Custom/MyBlinn-Phong"
{
	Properties
	{
		_MainColor ("Color", Color) = (1, 1, 1, 1)
		_AmbientColor ("Ambient Color", Color) = (0, 0, 0, 1)
		_SpecularColor ("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
		_Glossiness("Specular Power", Range(1, 32)) = 12
	}
	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldNormal : NORMAL;
				float2 uv : TEXCOORD0;
				float3 viewDir : TEXCOORD1;
			};

			float4 _MainColor;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Glossiness;


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.uv = v.uv;
				o.viewDir = WorldSpaceViewDir(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 L = normalize(_WorldSpaceLightPos0.xyz); //light vector
				float3 V = normalize(i.viewDir); //view vector
				float3 N = normalize(i.worldNormal); //normalized surface normal
				float3 H = normalize(L+V); //halfway vector
				
				// Diffuse(HalfLambert)
				float NdotL = max(dot(N, L), 0.0);
				float4 diffuse = (NdotL * 0.5 + 0.5) * _LightColor0;

				// Speculer
				float NdotH = dot(N, H);
				float4 specular = pow(max(NdotH, 0.0), _Glossiness) * _SpecularColor; // Half vector

	
				return (_AmbientColor + diffuse + specular) * _MainColor;
			}
			ENDCG
		}
	}
}