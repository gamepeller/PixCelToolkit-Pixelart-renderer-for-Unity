// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "EdgeDetect"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_DepthTreshold("DepthTreshold", Range( 0 , 1)) = 0.1
		_NormalsTreshold("NormalsTreshold", Range( 0 , 1)) = 0.1
		_DistanceFalloff("DistanceFalloff", Range( 0.1 , 10)) = 1
		_DepthColor("DepthColor", Color) = (0,0,0,0)
		_NormalColor("NormalColor", Color) = (0,0,0,0)
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
			
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform sampler2D _CameraDepthNormalsTexture;
			float4 _CameraDepthNormalsTexture_TexelSize;
			uniform float _DepthTreshold;
			uniform float4 _DepthColor;
			uniform float _DistanceFalloff;
			uniform float _NormalsTreshold;
			uniform float4 _NormalColor;
			float Sobel( float Center, float4 Diag, float4 Axis )
			{
						float centerDepth = Center;
						float4 depthsDiag = Diag;
						float4 depthsAxis = Axis;
						// make it work nicely with depth based image effects such as depth of field:
						depthsDiag = (depthsDiag > centerDepth.xxxx) ? depthsDiag : centerDepth.xxxx;
						depthsAxis = (depthsAxis > centerDepth.xxxx) ? depthsAxis : centerDepth.xxxx;
						depthsDiag -= centerDepth;
						depthsAxis /= centerDepth;
						const float4 HorizDiagCoeff = float4(1,1,-1,-1);
						const float4 VertDiagCoeff = float4(-1,1,-1,1);
						const float4 HorizAxisCoeff = float4(1,0,0,-1);
						const float4 VertAxisCoeff = float4(0,1,-1,0);
						float4 SobelH = depthsDiag * HorizDiagCoeff + depthsAxis * HorizAxisCoeff;
						float4 SobelV = depthsDiag * VertDiagCoeff + depthsAxis * VertAxisCoeff;
						float SobelX = dot(SobelH, float4(1,1,1,1));
						float SobelY = dot(SobelV, float4(1,1,1,1));
						float Sobel = sqrt(SobelX * SobelX + SobelY * SobelY);
						return Sobel;
			}
			
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
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
				float clampDepth17 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float Depth18 = clampDepth17;
				float Center23 = Depth18;
				float4 ScreenPos34 = screenPos;
				float TexW21 = _CameraDepthNormalsTexture_TexelSize.x;
				float TexH22 = _CameraDepthNormalsTexture_TexelSize.y;
				float2 appendResult37 = (float2(TexW21 , TexH22));
				float2 uvDist36 = appendResult37;
				float clampDepth24 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 + float4( uvDist36, 0.0 , 0.0 ) ).xy ));
				float TR40 = clampDepth24;
				float clampDepth25 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 + float4( ( uvDist36 * float2( -1,1 ) ), 0.0 , 0.0 ) ).xy ));
				float TL48 = clampDepth25;
				float clampDepth26 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 - float4( ( uvDist36 * float2( -1,1 ) ), 0.0 , 0.0 ) ).xy ));
				float BR59 = clampDepth26;
				float clampDepth27 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 - float4( uvDist36, 0.0 , 0.0 ) ).xy ));
				float BL61 = clampDepth27;
				float4 appendResult62 = (float4(TR40 , TL48 , BR59 , BL61));
				float4 DepthDiag63 = appendResult62;
				float4 Diag23 = DepthDiag63;
				float clampDepth70 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 + float4( ( uvDist36 * float2( 0,1 ) ), 0.0 , 0.0 ) ).xy ));
				float T73 = clampDepth70;
				float clampDepth79 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 - float4( ( uvDist36 * float2( 1,0 ) ), 0.0 , 0.0 ) ).xy ));
				float L80 = clampDepth79;
				float clampDepth86 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 + float4( ( uvDist36 * float2( 1,0 ) ), 0.0 , 0.0 ) ).xy ));
				float R87 = clampDepth86;
				float clampDepth93 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ( ScreenPos34 - float4( ( uvDist36 * float2( 0,1 ) ), 0.0 , 0.0 ) ).xy ));
				float B94 = clampDepth93;
				float4 appendResult97 = (float4(T73 , L80 , R87 , B94));
				float4 DepthAxis98 = appendResult97;
				float4 Axis23 = DepthAxis98;
				float localSobel23 = Sobel( Center23 , Diag23 , Axis23 );
				float DepthEdges100 = localSobel23;
				float DTreshold251 = _DepthTreshold;
				float IsDepthEdge248 = ( DepthEdges100 >= DTreshold251 ? 1.0 : 0.0 );
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 ScreenCol280 = tex2D( _MainTex, uv_MainTex );
				float4 DepthColor258 = _DepthColor;
				float DistanceFalloff256 = _DistanceFalloff;
				float4 lerpResult305 = lerp( ScreenCol280 , DepthColor258 , ( DepthColor258.a * pow( ( 1.0 - Depth18 ) , DistanceFalloff256 ) ));
				float4 ColWithDepthApplied297 = ( IsDepthEdge248 == 1.0 ? lerpResult305 : ScreenCol280 );
				float depthDecodedVal165 = 0;
				float3 normalDecodedVal165 = float3(0,0,0);
				DecodeDepthNormal( tex2D( _CameraDepthNormalsTexture, ( ScreenPos34 - float4( ( uvDist36 * float2( 0.5,0 ) ), 0.0 , 0.0 ) ).xy ), depthDecodedVal165, normalDecodedVal165 );
				float3 LNorm174 = normalDecodedVal165;
				float depthDecodedVal14 = 0;
				float3 normalDecodedVal14 = float3(0,0,0);
				DecodeDepthNormal( tex2D( _CameraDepthNormalsTexture, ScreenPos34.xy ), depthDecodedVal14, normalDecodedVal14 );
				float3 CNorm16 = normalDecodedVal14;
				float depthDecodedVal166 = 0;
				float3 normalDecodedVal166 = float3(0,0,0);
				DecodeDepthNormal( tex2D( _CameraDepthNormalsTexture, ( ScreenPos34 + float4( ( uvDist36 * float2( 0.5,0 ) ), 0.0 , 0.0 ) ).xy ), depthDecodedVal166, normalDecodedVal166 );
				float3 RNorm175 = normalDecodedVal166;
				float depthDecodedVal164 = 0;
				float3 normalDecodedVal164 = float3(0,0,0);
				DecodeDepthNormal( tex2D( _CameraDepthNormalsTexture, ( ScreenPos34 + float4( ( uvDist36 * float2( 0,0.5 ) ), 0.0 , 0.0 ) ).xy ), depthDecodedVal164, normalDecodedVal164 );
				float3 TNorm173 = normalDecodedVal164;
				float depthDecodedVal167 = 0;
				float3 normalDecodedVal167 = float3(0,0,0);
				DecodeDepthNormal( tex2D( _CameraDepthNormalsTexture, ( ScreenPos34 - float4( ( uvDist36 * float2( 0,0.5 ) ), 0.0 , 0.0 ) ).xy ), depthDecodedVal167, normalDecodedVal167 );
				float3 BNorm176 = normalDecodedVal167;
				float3 hsvTorgb268 = RGBToHSV( ( abs( ( LNorm174 - CNorm16 ) ) + abs( ( RNorm175 - CNorm16 ) ) + abs( ( TNorm173 - CNorm16 ) ) + abs( ( BNorm176 - CNorm16 ) ) ) );
				float NormEdges171 = hsvTorgb268.z;
				float NTreshold252 = _NormalsTreshold;
				float IsNormEdge288 = ( NormEdges171 > NTreshold252 ? 1.0 : 0.0 );
				float4 NormalColor260 = _NormalColor;
				float4 lerpResult315 = lerp( ScreenCol280 , NormalColor260 , ( NormalColor260.a * pow( ( 1.0 - Depth18 ) , DistanceFalloff256 ) ));
				float4 ColWithNormApplied317 = ( IsNormEdge288 == 1.0 ? lerpResult315 : ScreenCol280 );
				float4 Final333 = ( IsDepthEdge248 == 1.0 ? ColWithDepthApplied297 : ColWithNormApplied317 );
				

				finalColor = Final333;

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
438.6667;235.3333;1297.333;749.6667;2735.879;3108.111;1;True;False
Node;AmplifyShaderEditor.TexturePropertyNode;198;-2905.547,-1773.264;Inherit;True;Global;_CameraDepthNormalsTexture;_CameraDepthNormalsTexture;10;0;Create;True;0;0;0;False;0;False;None;;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-2599.547,-1762.264;Inherit;False;NormalsTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TexelSizeNode;19;-2359.454,-1986.415;Inherit;False;11;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;21;-2025.508,-1985.072;Inherit;False;TexW;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-2024.508,-1906.072;Inherit;False;TexH;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;37;-1785.873,-1960.114;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-1601.873,-1953.114;Inherit;False;uvDist;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;32;-1860.922,-1721.39;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;135;-2568.163,-173.709;Inherit;False;Constant;_Vector11;Vector 11;1;0;Create;True;0;0;0;False;0;False;0.5,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;138;-2596.542,101.1981;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;132;-2568.282,-565.855;Inherit;False;Constant;_Vector9;Vector 9;1;0;Create;True;0;0;0;False;0;False;0,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;123;-2569.875,213.8657;Inherit;False;Constant;_Vector7;Vector 7;1;0;Create;True;0;0;0;False;0;False;0.5,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;120;-2584.586,507.5554;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-2594.949,-678.5222;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-2594.83,-286.3766;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;121;-2567.919,624.2234;Inherit;False;Constant;_Vector6;Vector 6;1;0;Create;True;0;0;0;False;0;False;0,0.5;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;34;-1585.487,-1721.047;Inherit;False;ScreenPos;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;115;-2450.543,19.19811;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;131;-2438.588,425.5555;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-2448.832,-368.3764;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;114;-2393.284,-623.8552;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;111;-2393.165,-231.7093;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;118;-2382.921,562.2235;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;113;-2448.95,-760.5222;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-2394.877,155.8653;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;209;-2226.237,398.7747;Inherit;False;199;NormalsTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-2390.292,-1357.768;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;105;-2208.332,-308.1539;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;117;-2203.332,486.8464;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;208;-2222.237,-0.2252264;Inherit;False;199;NormalsTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-4435.554,1270.104;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-2392.682,-1443.224;Inherit;False;199;NormalsTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-2228.237,-774.2253;Inherit;False;199;NormalsTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-4487.54,-555.0947;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;207;-2230.237,-397.2254;Inherit;False;199;NormalsTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleAddOpNode;103;-2193.674,91.00108;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;47;-4367.741,-818.0471;Inherit;False;Constant;_Vector0;Vector 0;1;0;Create;True;0;0;0;False;0;False;-1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;107;-2192.083,-688.7194;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;55;-4452.873,-434.4273;Inherit;False;Constant;_Vector1;Vector 1;1;0;Create;True;0;0;0;False;0;False;-1,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;83;-4447.51,863.747;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-4445.917,84.02669;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;71;-4419.25,196.6941;Inherit;False;Constant;_Vector2;Vector 2;1;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;43;-4402.408,-938.7141;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;77;-4419.131,588.8399;Inherit;False;Constant;_Vector3;Vector 3;1;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;91;-4408.887,1382.772;Inherit;False;Constant;_Vector5;Vector 5;1;0;Create;True;0;0;0;False;0;False;0,1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;84;-4420.843,976.4144;Inherit;False;Constant;_Vector4;Vector 4;1;0;Create;True;0;0;0;False;0;False;1,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;76;-4445.798,476.1726;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-4293.266,-274.8875;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;144;-2019.362,-344.797;Inherit;True;Global;_TextureSample5;Texture Sample 5;5;0;Create;True;0;0;0;False;0;False;198;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;11;-2151.933,-1437.774;Inherit;True;Global;TexturSample1;TexturSample-1;0;0;Create;True;0;0;0;False;0;False;198;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;52;-4341.54,-637.0947;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-4245.845,918.4141;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;-4301.511,781.7473;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;-4299.8,394.1728;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-4299.918,2.026848;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;-4244.252,138.6938;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-4303.266,-194.8875;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;145;-2029.052,49.28087;Inherit;True;Global;_TextureSample6;Texture Sample 6;6;0;Create;True;0;0;0;False;0;False;198;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-4285.875,-500.4276;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;75;-4244.133,530.8397;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;143;-2032.281,-720.5705;Inherit;True;Global;_TextureSample4;Texture Sample 4;4;0;Create;True;0;0;0;False;0;False;198;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;146;-2031.208,460.5857;Inherit;True;Global;_TextureSample7;Texture Sample 7;7;0;Create;True;0;0;0;False;0;False;198;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;38;-4253.743,-1116.047;Inherit;False;36;uvDist;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;35;-4243.743,-1196.047;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-4289.556,1188.104;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-4233.889,1324.772;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;41;-4256.41,-1020.714;Inherit;False;34;ScreenPos;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-4200.744,-884.0471;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DecodeDepthNormalNode;164;-1718.554,-720.5909;Inherit;False;1;0;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT3;1
Node;AmplifyShaderEditor.SimpleAddOpNode;85;-4044.642,853.5499;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DecodeDepthNormalNode;167;-1740.554,468.4089;Inherit;False;1;0;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT3;1
Node;AmplifyShaderEditor.DecodeDepthNormalNode;165;-1724.554,-327.591;Inherit;False;1;0;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT3;1
Node;AmplifyShaderEditor.SimpleAddOpNode;42;-4035.301,-943.078;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DecodeDepthNormalNode;14;-1790.826,-1422.004;Inherit;False;1;0;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT3;1
Node;AmplifyShaderEditor.SimpleSubtractOpNode;95;-4059.3,454.3951;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;58;-4094.496,-577.8945;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;57;-4062.497,-256.8944;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;96;-4054.3,1249.395;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DecodeDepthNormalNode;166;-1730.554,54.40904;Inherit;False;1;0;FLOAT4;0,0,0,0;False;2;FLOAT;0;FLOAT3;1
Node;AmplifyShaderEditor.SimpleAddOpNode;72;-4043.051,73.82948;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;39;-4051.744,-1163.047;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenDepthNode;25;-3853.225,-938.3947;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;-1412.642,-706.0462;Inherit;False;TNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;79;-3864.156,444.4193;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;27;-3899.899,-262.8479;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;175;-1384.768,73.27692;Inherit;False;RNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;70;-3864.274,52.27341;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;174;-1384.802,-326.2935;Inherit;False;LNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-1431.622,-1423.846;Inherit;False;CNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;26;-3905.899,-586.8481;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;86;-3865.862,831.9936;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;24;-3852.344,-1106.082;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;176;-1381.5,489.2428;Inherit;False;BNorm;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;93;-3853.906,1238.351;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-3612.342,-574.1988;Inherit;False;BR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-3621.68,1238.907;Inherit;False;B;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;177;-1116.996,-985.7323;Inherit;False;175;RNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;179;-1112.996,-892.7323;Inherit;False;173;TNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;-3630.929,444.9754;Inherit;False;L;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-3598.96,-936.5715;Inherit;False;TL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;87;-3626.14,834.1736;Inherit;False;R;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-3617.048,-255.1204;Inherit;False;BL;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;221;-939.9364,-1008.306;Inherit;False;16;CNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-940.9364,-1099.973;Inherit;False;16;CNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;-1119.996,-1069.732;Inherit;False;174;LNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;40;-3589.922,-1082.877;Inherit;False;TR;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;-928.9364,-820.3063;Inherit;False;16;CNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;180;-1114.996,-796.7324;Inherit;False;176;BNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;224;-934.9364,-913.3062;Inherit;False;16;CNorm;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-3631.049,51.8295;Inherit;False;T;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;226;-747.9363,-792.3063;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;62;-3276.502,-684.2951;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;217;-759.9363,-1071.973;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;220;-758.9363,-980.3062;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;97;-3261.814,680.8278;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;223;-753.9363,-885.3062;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.AbsOpNode;230;-581.9893,-1054.74;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;98;-2996.724,703.9084;Inherit;False;DepthAxis;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;232;-576.394,-880.4684;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;-3079.058,-686.8104;Inherit;False;DepthDiag;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.AbsOpNode;231;-581.9265,-969.8511;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenDepthNode;17;-3855.292,-1214.914;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;233;-578.5348,-793.8393;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;229;-397.52,-964.985;Inherit;False;4;4;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-2228.731,-2483.911;Inherit;False;Property;_DepthTreshold;DepthTreshold;0;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;99;-3294.724,-1051.091;Inherit;False;98;DepthAxis;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;259;-2221.838,-2993.838;Inherit;False;Property;_NormalColor;NormalColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;18;-3574.292,-1208.914;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;-3291.058,-1143.81;Inherit;False;63;DepthDiag;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-2218.381,-2618.937;Inherit;False;Property;_DistanceFalloff;DistanceFalloff;2;0;Create;True;0;0;0;False;0;False;1;0;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;257;-2225.338,-2807.338;Inherit;False;Property;_DepthColor;DepthColor;3;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;250;-2235.961,-2396.666;Inherit;False;Property;_NormalsTreshold;NormalsTreshold;1;0;Create;True;0;0;0;False;0;False;0.1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;342;-843.6959,591.6448;Inherit;False;18;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;256;-1967.703,-2618.936;Inherit;False;DistanceFalloff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode;268;-252.3016,-968.1481;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;338;-882.6536,1296.4;Inherit;False;18;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;251;-1933.232,-2493.937;Inherit;False;DTreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;258;-1966.338,-2794.338;Inherit;False;DepthColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;279;-2374.246,-2251.282;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;260;-1976.838,-2975.838;Inherit;False;NormalColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;252;-1938.232,-2388.937;Inherit;False;NTreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CustomExpressionNode;23;-3068.079,-1203.005;Inherit;False;		float centerDepth = Center@$		float4 depthsDiag = Diag@$		float4 depthsAxis = Axis@$$$		// make it work nicely with depth based image effects such as depth of field:$		depthsDiag = (depthsDiag > centerDepth.xxxx) ? depthsDiag : centerDepth.xxxx@$		depthsAxis = (depthsAxis > centerDepth.xxxx) ? depthsAxis : centerDepth.xxxx@$$		depthsDiag -= centerDepth@$		depthsAxis /= centerDepth@$$		const float4 HorizDiagCoeff = float4(1,1,-1,-1)@$		const float4 VertDiagCoeff = float4(-1,1,-1,1)@$		const float4 HorizAxisCoeff = float4(1,0,0,-1)@$		const float4 VertAxisCoeff = float4(0,1,-1,0)@$$		float4 SobelH = depthsDiag * HorizDiagCoeff + depthsAxis * HorizAxisCoeff@$		float4 SobelV = depthsDiag * VertDiagCoeff + depthsAxis * VertAxisCoeff@$$		float SobelX = dot(SobelH, float4(1,1,1,1))@$		float SobelY = dot(SobelV, float4(1,1,1,1))@$		float Sobel = sqrt(SobelX * SobelX + SobelY * SobelY)@$		return Sobel@;1;Create;3;True;Center;FLOAT;0;In;;Inherit;False;True;Diag;FLOAT4;0,0,0,0;In;;Inherit;False;True;Axis;FLOAT4;0,0,0,0;In;;Inherit;False;Sobel;False;False;0;;False;3;0;FLOAT;0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;339;-896.238,1380.712;Inherit;False;256;DistanceFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;274;43.11002,-867.9031;Inherit;False;252;NTreshold;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;171;19.2336,-959.3354;Inherit;False;NormEdges;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;341;-706.9065,1306.927;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;308;-675.0261,1049.013;Inherit;False;260;NormalColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;254;-2864.738,-1064.312;Inherit;False;251;DTreshold;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;343;-857.2802,675.9568;Inherit;False;256;DistanceFalloff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;345;-667.9487,602.1718;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;-2871.563,-1193.023;Inherit;False;DepthEdges;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;281;-2257.751,-2271.313;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;303;-658.9463,387.7106;Inherit;False;258;DepthColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;310;-494.8807,1150.11;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Compare;273;239.1101,-940.9031;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;253;-2661.738,-1075.312;Inherit;False;3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;340;-543.3848,1346.843;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;304;-464.7201,467.2618;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;280;-1973.479,-2243.902;Inherit;False;ScreenCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;344;-504.4271,642.0878;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;286;-371.6564,1237.766;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;288;397.2031,-927.4033;Inherit;False;IsNormEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;309;-501.452,927.7926;Inherit;False;280;ScreenCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;323;-322.6247,553.3688;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;301;-475.2681,257.3638;Inherit;False;280;ScreenCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;248;-2518.369,-1075.295;Inherit;False;IsDepthEdge;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;305;-197.7199,377.2617;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;300;-86.47516,520.7575;Inherit;False;280;ScreenCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;315;-223.9048,1047.692;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;282;-80.42513,287.67;Inherit;False;248;IsDepthEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;-75.36931,1181.005;Inherit;False;280;ScreenCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-69.31924,947.9165;Inherit;False;288;IsNormEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;294;127.6473,354.3768;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;316;138.753,1014.623;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;297;682.3395,391.8996;Inherit;False;ColWithDepthApplied;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;317;620.8427,1017.942;Inherit;False;ColWithNormApplied;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;332;857.7291,756.6912;Inherit;False;317;ColWithNormApplied;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;330;957.5154,593.4861;Inherit;False;248;IsDepthEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;331;875.1579,679.3229;Inherit;False;297;ColWithDepthApplied;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;328;1166.23,630.0305;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;333;1421.729,687.6912;Inherit;False;Final;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;101;1178.793,-17.62365;Inherit;False;333;Final;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;289;-1091.123,-630.4187;Inherit;False;248;IsDepthEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;290;-1092.055,-517.1202;Inherit;False;288;IsNormEdge;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-2215.338,-3284.338;Inherit;False;Property;_NormalMult;NormalMult;5;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;275;-818.8696,-559.4568;Inherit;False;Or;-1;;4;dcfde22f80031984b87bcc46a052ad1f;0;2;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;276;-666.1698,-549.2569;Inherit;False;AllEdges;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;265;-2223.838,-3131.838;Inherit;False;Property;_DepthMult;DepthMult;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;264;-1984.838,-3124.838;Inherit;False;DepthMult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;262;-1976.338,-3277.338;Inherit;False;NormalMult;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;1422.754,-19.32075;Float;False;True;-1;2;ASEMaterialInspector;0;4;EdgeDetect;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;199;0;198;0
WireConnection;19;0;199;0
WireConnection;21;0;19;1
WireConnection;22;0;19;2
WireConnection;37;0;21;0
WireConnection;37;1;22;0
WireConnection;36;0;37;0
WireConnection;34;0;32;0
WireConnection;114;0;122;0
WireConnection;114;1;132;0
WireConnection;111;0;136;0
WireConnection;111;1;135;0
WireConnection;118;0;120;0
WireConnection;118;1;121;0
WireConnection;116;0;138;0
WireConnection;116;1;123;0
WireConnection;105;0;110;0
WireConnection;105;1;111;0
WireConnection;117;0;131;0
WireConnection;117;1;118;0
WireConnection;103;0;115;0
WireConnection;103;1;116;0
WireConnection;107;0;113;0
WireConnection;107;1;114;0
WireConnection;144;0;207;0
WireConnection;144;1;105;0
WireConnection;11;0;201;0
WireConnection;11;1;102;0
WireConnection;82;0;83;0
WireConnection;82;1;84;0
WireConnection;67;0;68;0
WireConnection;67;1;71;0
WireConnection;145;0;208;0
WireConnection;145;1;103;0
WireConnection;54;0;56;0
WireConnection;54;1;55;0
WireConnection;75;0;76;0
WireConnection;75;1;77;0
WireConnection;143;0;206;0
WireConnection;143;1;107;0
WireConnection;146;0;209;0
WireConnection;146;1;117;0
WireConnection;89;0;90;0
WireConnection;89;1;91;0
WireConnection;45;0;43;0
WireConnection;45;1;47;0
WireConnection;164;0;143;0
WireConnection;85;0;81;0
WireConnection;85;1;82;0
WireConnection;167;0;146;0
WireConnection;165;0;144;0
WireConnection;42;0;41;0
WireConnection;42;1;45;0
WireConnection;14;0;11;0
WireConnection;95;0;74;0
WireConnection;95;1;75;0
WireConnection;58;0;52;0
WireConnection;58;1;54;0
WireConnection;57;0;49;0
WireConnection;57;1;51;0
WireConnection;96;0;88;0
WireConnection;96;1;89;0
WireConnection;166;0;145;0
WireConnection;72;0;66;0
WireConnection;72;1;67;0
WireConnection;39;0;35;0
WireConnection;39;1;38;0
WireConnection;25;0;42;0
WireConnection;173;0;164;1
WireConnection;79;0;95;0
WireConnection;27;0;57;0
WireConnection;175;0;166;1
WireConnection;70;0;72;0
WireConnection;174;0;165;1
WireConnection;16;0;14;1
WireConnection;26;0;58;0
WireConnection;86;0;85;0
WireConnection;24;0;39;0
WireConnection;176;0;167;1
WireConnection;93;0;96;0
WireConnection;59;0;26;0
WireConnection;94;0;93;0
WireConnection;80;0;79;0
WireConnection;48;0;25;0
WireConnection;87;0;86;0
WireConnection;61;0;27;0
WireConnection;40;0;24;0
WireConnection;73;0;70;0
WireConnection;226;0;180;0
WireConnection;226;1;227;0
WireConnection;62;0;40;0
WireConnection;62;1;48;0
WireConnection;62;2;59;0
WireConnection;62;3;61;0
WireConnection;217;0;178;0
WireConnection;217;1;218;0
WireConnection;220;0;177;0
WireConnection;220;1;221;0
WireConnection;97;0;73;0
WireConnection;97;1;80;0
WireConnection;97;2;87;0
WireConnection;97;3;94;0
WireConnection;223;0;179;0
WireConnection;223;1;224;0
WireConnection;230;0;217;0
WireConnection;98;0;97;0
WireConnection;232;0;223;0
WireConnection;63;0;62;0
WireConnection;231;0;220;0
WireConnection;233;0;226;0
WireConnection;229;0;230;0
WireConnection;229;1;231;0
WireConnection;229;2;232;0
WireConnection;229;3;233;0
WireConnection;18;0;17;0
WireConnection;256;0;255;0
WireConnection;268;0;229;0
WireConnection;251;0;249;0
WireConnection;258;0;257;0
WireConnection;260;0;259;0
WireConnection;252;0;250;0
WireConnection;23;0;18;0
WireConnection;23;1;64;0
WireConnection;23;2;99;0
WireConnection;171;0;268;3
WireConnection;341;0;338;0
WireConnection;345;0;342;0
WireConnection;100;0;23;0
WireConnection;281;0;279;0
WireConnection;310;0;308;0
WireConnection;273;0;171;0
WireConnection;273;1;274;0
WireConnection;253;0;100;0
WireConnection;253;1;254;0
WireConnection;340;0;341;0
WireConnection;340;1;339;0
WireConnection;304;0;303;0
WireConnection;280;0;281;0
WireConnection;344;0;345;0
WireConnection;344;1;343;0
WireConnection;286;0;310;3
WireConnection;286;1;340;0
WireConnection;288;0;273;0
WireConnection;323;0;304;3
WireConnection;323;1;344;0
WireConnection;248;0;253;0
WireConnection;305;0;301;0
WireConnection;305;1;303;0
WireConnection;305;2;323;0
WireConnection;315;0;309;0
WireConnection;315;1;308;0
WireConnection;315;2;286;0
WireConnection;294;0;282;0
WireConnection;294;2;305;0
WireConnection;294;3;300;0
WireConnection;316;0;319;0
WireConnection;316;2;315;0
WireConnection;316;3;320;0
WireConnection;297;0;294;0
WireConnection;317;0;316;0
WireConnection;328;0;330;0
WireConnection;328;2;331;0
WireConnection;328;3;332;0
WireConnection;333;0;328;0
WireConnection;275;2;289;0
WireConnection;275;3;290;0
WireConnection;276;0;275;0
WireConnection;264;0;265;0
WireConnection;262;0;261;0
WireConnection;0;0;101;0
ASEEND*/
//CHKSM=08A6AFE4B374151EE9EF333247FD1D38956F6FC1