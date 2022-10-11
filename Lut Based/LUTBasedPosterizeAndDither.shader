// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "LUTBasedPosterizeAndDither"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_3DLUT("3D LUT", 3D) = "white" {}
		_DitherDistance("Dither Distance", Range( 0 , 1)) = 0.3
		_ColorDepthPerChannel("Color Depth Per Channel", Int) = 4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		
		
		ZTest Always
		Cull Off
		ZWrite Off

		
		Pass
		{ 
			CGPROGRAM 

			

			#pragma vertex vert_img_custom 
			#pragma fragment frag
			#pragma target 3.0
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_img_custom
			{
				float4 vertex : POSITION;
				half2 texcoord : TEXCOORD0;
				
			};

			struct v2f_img_custom
			{
				float4 pos : SV_POSITION;
				half2 uv   : TEXCOORD0;
				half2 stereoUV : TEXCOORD2;
		#if UNITY_UV_STARTS_AT_TOP
				half4 uv2 : TEXCOORD1;
				half4 stereoUV2 : TEXCOORD3;
		#endif
				float4 ase_texcoord4 : TEXCOORD4;
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform sampler3D _3DLUT;
			uniform float _DitherDistance;
			uniform int _ColorDepthPerChannel;
			inline float Dither8x8Bayer( int x, int y )
			{
				const float dither[ 64 ] = {
			 1, 49, 13, 61,  4, 52, 16, 64,
			33, 17, 45, 29, 36, 20, 48, 32,
			 9, 57,  5, 53, 12, 60,  8, 56,
			41, 25, 37, 21, 44, 28, 40, 24,
			 3, 51, 15, 63,  2, 50, 14, 62,
			35, 19, 47, 31, 34, 18, 46, 30,
			11, 59,  7, 55, 10, 58,  6, 54,
			43, 27, 39, 23, 42, 26, 38, 22};
				int r = y * 8 + x;
				return dither[r] / 64; // same # of instructions as pre-dividing due to compiler magic
			}
			


			v2f_img_custom vert_img_custom ( appdata_img_custom v  )
			{
				v2f_img_custom o;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.pos = UnityObjectToClipPos( v.vertex );
				o.uv = float4( v.texcoord.xy, 1, 1 );

				#if UNITY_UV_STARTS_AT_TOP
					o.uv2 = float4( v.texcoord.xy, 1, 1 );
					o.stereoUV2 = UnityStereoScreenSpaceUVAdjust ( o.uv2, _MainTex_ST );

					if ( _MainTex_TexelSize.y < 0.0 )
						o.uv.y = 1.0 - o.uv.y;
				#endif
				o.stereoUV = UnityStereoScreenSpaceUVAdjust ( o.uv, _MainTex_ST );
				return o;
			}

			half4 frag ( v2f_img_custom i ) : SV_Target
			{
				#ifdef UNITY_UV_STARTS_AT_TOP
					half2 uv = i.uv2;
					half2 stereoUV = i.stereoUV2;
				#else
					half2 uv = i.uv;
					half2 stereoUV = i.stereoUV;
				#endif	
				
				half4 finalColor;

				// ase common template code
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen52 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither52 = Dither8x8Bayer( fmod(clipScreen52.x, 8), fmod(clipScreen52.y, 8) );
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode8 = tex2D( _MainTex, uv_MainTex );
				dither52 = step( dither52, tex2DNode8.r );
				float4 break16 = tex2DNode8;
				float4 tex3DNode1 = tex3D( _3DLUT, tex2DNode8.rgb );
				float4 break19 = tex3DNode1;
				float4 appendResult26 = (float4(( break16.r - break19.r ) , ( break16.g - break19.g ) , ( break16.b - break19.b ) , 0.0));
				float4 temp_cast_2 = ( 1 / pow( 2 , _ColorDepthPerChannel ) );
				

				finalColor = ( dither52 == 1.0 ? tex3D( _3DLUT, ( tex2DNode8 + min( ( appendResult26 * _DitherDistance ) , temp_cast_2 ) ).rgb ) : tex3DNode1 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
441.3333;229.3333;1291.333;749.6667;1679.661;470.1162;1;True;False
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;7;-1344.424,-19.95511;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;2;-1168,-281.5;Inherit;True;Property;_3DLUT;3D LUT;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;LockedToTexture3D;Texture3D;-1;0;2;SAMPLER3D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.SamplerNode;8;-1220.687,-16.5113;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-902,-143.5;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;16;-894.3106,156.914;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;19;-609.3106,-107.086;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-425.3107,181.414;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;57;-254.0022,476.0396;Inherit;False;Property;_ColorDepthPerChannel;Color Depth Per Channel;3;0;Create;True;0;0;0;False;0;False;4;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;24;-425.3106,299.414;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;14;-432.3107,57.91397;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-237.5366,345.325;Inherit;False;Property;_DitherDistance;Dither Distance;1;0;Create;True;0;0;0;False;0;False;0.3;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-104.8919,141.9371;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.PowerNode;55;12.99786,433.0396;Inherit;False;False;2;0;INT;2;False;1;INT;1;False;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;29;37.74841,143.1654;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;56;159.9979,380.0396;Inherit;False;2;0;INT;1;False;1;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;35;199.6285,142.6415;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;27;271.108,-0.06289673;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;25;410.6017,-97.63986;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DitheringNode;52;-313.4243,559.9994;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;33;601.72,385.6772;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;896.6685,373.0816;Float;False;True;-1;2;ASEMaterialInspector;0;4;LUTBasedPosterizeAndDither;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;8;0;7;0
WireConnection;1;0;2;0
WireConnection;1;1;8;0
WireConnection;16;0;8;0
WireConnection;19;0;1;0
WireConnection;21;0;16;1
WireConnection;21;1;19;1
WireConnection;24;0;16;2
WireConnection;24;1;19;2
WireConnection;14;0;16;0
WireConnection;14;1;19;0
WireConnection;26;0;14;0
WireConnection;26;1;21;0
WireConnection;26;2;24;0
WireConnection;55;1;57;0
WireConnection;29;0;26;0
WireConnection;29;1;28;0
WireConnection;56;1;55;0
WireConnection;35;0;29;0
WireConnection;35;1;56;0
WireConnection;27;0;8;0
WireConnection;27;1;35;0
WireConnection;25;0;2;0
WireConnection;25;1;27;0
WireConnection;52;0;8;0
WireConnection;33;0;52;0
WireConnection;33;2;25;0
WireConnection;33;3;1;0
WireConnection;0;0;33;0
ASEEND*/
//CHKSM=DFC30D8408A2EBF93228B7B697E29B281500A426