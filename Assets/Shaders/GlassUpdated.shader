Shader "Holistic/Glass"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BumpMap ("Normalmap", 2D) = "bump" {}
		_ScaleUV ("Scale", Range(1,50)) = 1
		_Tint("Colour Tint", Color) = (1,1,1,1)
      _Freq("Frequency", Range(0,5)) = 3
      _Speed("Speed",Range(0,100)) = 10
      _Amp("Amplitude",Range(0,1)) = 0.5
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent"}
		GrabPass{}
		
		CGPROGRAM
	      #pragma surface surf Lambert vertex:vert 
	      
	      struct Input {
	          float2 uv_MainTex;
	          float3 vertColor;
	      };
	      
	      float4 _Tint;
	      float _Freq;
	      float _Speed;
	      float _Amp;

	      struct appdata {
	          float4 vertex: POSITION;
	          float3 normal: NORMAL;
	          float4 texcoord: TEXCOORD0;
	          float4 texcoord1: TEXCOORD1;
	          float4 texcoord2: TEXCOORD2;
	      };
	      
	      void vert (inout appdata v, out Input o) {
	          UNITY_INITIALIZE_OUTPUT(Input,o);
	          float t = _Time * _Speed;
	          float waveHeight = sin(t + v.vertex.x * _Freq) * _Amp +
	                        sin(t*2 + v.vertex.x * _Freq*2) * _Amp;
	          v.vertex.y = v.vertex.y + waveHeight;
	          v.normal = normalize(float3(v.normal.x + waveHeight, v.normal.y, v.normal.z));
	          o.vertColor = waveHeight + 2;

	      }

	      sampler2D _MainTex;
	      void surf (Input IN, inout SurfaceOutput o) {
	          float4 c = tex2D(_MainTex, IN.uv_MainTex);
	          o.Albedo = c * IN.vertColor.rgb;
	      }
	      ENDCG
		
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 uvgrab : TEXCOORD1;
				float2 uvbump : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};

			sampler2D _GrabTexture;
			float4 _GrabTexture_TexelSize;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			float _ScaleUV;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                
                //add this to check if the image needs flipping
				# if UNITY_UV_STARTS_AT_TOP
                float scale = -1.0;
                # else
                float scale = 1.0f;
                # endif
                
                //include scale in this formulae as below
                o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y * scale) + o.vertex.w) * 0.5;
                o.uvgrab.zw = o.vertex.zw;
				o.uv = TRANSFORM_TEX( v.uv, _MainTex );
				o.uvbump = TRANSFORM_TEX( v.uv, _BumpMap );
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half2 bump = UnpackNormal(tex2D( _BumpMap, i.uvbump )).rg; 
				float2 offset = bump * _ScaleUV * _GrabTexture_TexelSize.xy;
				i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
				
				fixed4 col = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD(i.uvgrab));
				fixed4 tint = tex2D(_MainTex, i.uv);
				col *= tint;
				return col;
			}
			ENDCG
		}
	}
}

