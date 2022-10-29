// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "CheapOutline"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_OutlineTex("Outline Tex", 2D) = "white" {}
		_FillColor("Fill Color", Color) = (0,0,0,0)
		_OutlineColor("Outline Color", Color) = (0,1,0,1)
		_DepthFadeFillAmount("DepthFadeFillAmount", Range( 0 , 1)) = 0
		_DepthFadeOutlineAmount("DepthFadeOutlineAmount", Range( 0 , 1)) = 0
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
			
			uniform sampler2D _OutlineTex;
			uniform float4 _OutlineTex_ST;
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float4 _OutlineColor;
			uniform float _DepthFadeOutlineAmount;
			uniform float4 _FillColor;
			uniform float _DepthFadeFillAmount;
			float ASEOr( float A, float B )
			{
				float result = A || B;
				return result;
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
				float2 uv_OutlineTex = i.uv.xy * _OutlineTex_ST.xy + _OutlineTex_ST.zw;
				float IsMyAlpha072 = ( tex2D( _OutlineTex, uv_OutlineTex ).r == 1.0 ? 1.0 : 0.0 );
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 ScreenColor184 = tex2D( _MainTex, uv_MainTex );
				float OffsetX22 = _MainTex_TexelSize.x;
				float Zero28 = 0.0;
				float4 appendResult42 = (float4(( -1.0 * OffsetX22 ) , Zero28 , 0.0 , 0.0));
				float2 texCoord41 = i.uv.xy * float2( 1,1 ) + appendResult42.xy;
				float AlphaAtNegX59 = ( tex2D( _OutlineTex, texCoord41 ).r == 1.0 ? 0.0 : 1.0 );
				float A1_g8 = ( AlphaAtNegX59 == 0.0 ? 1.0 : 0.0 );
				float OffsetY23 = _MainTex_TexelSize.y;
				float4 appendResult48 = (float4(Zero28 , ( OffsetY23 * -1.0 ) , 0.0 , 0.0));
				float2 texCoord47 = i.uv.xy * float2( 1,1 ) + appendResult48.xy;
				float AlphaAtNegY60 = ( tex2D( _OutlineTex, texCoord47 ).r == 1.0 ? 0.0 : 1.0 );
				float B1_g8 = ( AlphaAtNegY60 == 0.0 ? 1.0 : 0.0 );
				float localASEOr1_g8 = ASEOr( A1_g8 , B1_g8 );
				float A1_g9 = localASEOr1_g8;
				float4 appendResult26 = (float4(OffsetX22 , Zero28 , 0.0 , 0.0));
				float2 texCoord9 = i.uv.xy * float2( 1,1 ) + appendResult26.xy;
				float AlphaAtX57 = ( tex2D( _OutlineTex, texCoord9 ).r == 1.0 ? 0.0 : 1.0 );
				float A1_g7 = ( AlphaAtX57 == 0.0 ? 1.0 : 0.0 );
				float4 appendResult36 = (float4(Zero28 , OffsetY23 , 0.0 , 0.0));
				float2 texCoord35 = i.uv.xy * float2( 1,1 ) + appendResult36.xy;
				float AlphaAtY58 = ( tex2D( _OutlineTex, texCoord35 ).r == 1.0 ? 0.0 : 1.0 );
				float B1_g7 = ( AlphaAtY58 == 0.0 ? 1.0 : 0.0 );
				float localASEOr1_g7 = ASEOr( A1_g7 , B1_g7 );
				float B1_g9 = localASEOr1_g7;
				float localASEOr1_g9 = ASEOr( A1_g9 , B1_g9 );
				float DoIHaveTransparentNeighbor73 = localASEOr1_g9;
				float OutlineDepth110 = tex2D( _OutlineTex, uv_OutlineTex ).r;
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float clampDepth107 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float4 OutlineColor66 = ( OutlineDepth110 <= clampDepth107 ? _OutlineColor : ( _OutlineColor * _DepthFadeOutlineAmount ) );
				float4 lerpResult188 = lerp( ScreenColor184 , OutlineColor66 , OutlineColor66.a);
				float clampDepth113 = Linear01Depth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy ));
				float4 appendResult281 = (float4(_FillColor.r , _FillColor.g , _FillColor.b , _DepthFadeFillAmount));
				float4 FillColor65 = ( OutlineDepth110 <= clampDepth113 ? _FillColor : appendResult281 );
				float4 lerpResult193 = lerp( ScreenColor184 , FillColor65 , FillColor65.a);
				

				finalColor = ( IsMyAlpha072 == 1.0 ? ScreenColor184 : ( DoIHaveTransparentNeighbor73 == 1.0 ? lerpResult188 : lerpResult193 ) );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
433.3333;158.6667;1280;745;3153.205;748.1445;1;True;False
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;282;-2237.677,-465.0897;Inherit;False;0;0;_MainTex_TexelSize;Shader;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1941.81,-584.6929;Inherit;False;OffsetX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;23;-1947.216,-365.2306;Inherit;False;OffsetY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2213.609,-809.0809;Inherit;False;Constant;_Float2;Float 2;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;54;-3515.1,1298.358;Inherit;False;Constant;_Float3;Float 3;3;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-1941.324,-814.3787;Inherit;False;Zero;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-3566.9,1532.075;Inherit;False;22;OffsetX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;52;-3503.854,2451.286;Inherit;False;23;OffsetY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-3457.868,2647.555;Inherit;False;Constant;_Float4;Float 4;3;0;Create;True;0;0;0;False;0;False;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;8;-2569.257,-1062.973;Inherit;True;Property;_OutlineTex;Outline Tex;0;0;Create;True;0;0;0;False;0;False;None;None;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.GetLocalVarNode;51;-3290.436,2247.301;Inherit;False;28;Zero;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-3220.331,2464.161;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;-3285.791,1088.693;Inherit;False;23;OffsetY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-3289.373,881.7076;Inherit;False;28;Zero;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-3289.257,385.4663;Inherit;False;28;Zero;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-3290.318,1751.06;Inherit;False;28;Zero;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-3292.839,178.4811;Inherit;False;22;OffsetX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;53;-3281.563,1503.964;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-2995.9,1576.075;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;36;-2991.374,913.7078;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;26;-2994.838,210.481;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;48;-2992.435,2279.301;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;32;-1972.812,-1040.349;Inherit;False;OutlineTex;-1;True;1;0;SAMPLER2D;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;9;-2739.057,202.7794;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;45;-2522.997,1416.267;Inherit;False;32;OutlineTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-2518.471,753.8999;Inherit;False;32;OutlineTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;49;-2519.532,2119.493;Inherit;False;32;OutlineTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-2531.035,88.3737;Inherit;False;32;OutlineTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;41;-2740.119,1568.373;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;47;-2736.655,2271.599;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2735.593,906.0062;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;10;-2322.016,312.1791;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;50;-2305.66,2281.037;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;46;-2309.124,1577.811;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;40;-2304.597,915.444;Inherit;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;229;-1988.957,924.5867;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;230;-1933.867,1620.417;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;134;-2302.495,-1293.122;Inherit;True;Property;_TextureSample4;Texture Sample 4;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;231;-1910.322,2292.473;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;228;-1994.76,347.6431;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;-1682.297,889.7147;Inherit;False;AlphaAtY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;110;-1978.899,-1271.514;Inherit;False;OutlineDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;59;-1554.923,1598.109;Inherit;False;AlphaAtNegX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;64;-2837.963,-1698.066;Inherit;False;Property;_FillColor;Fill Color;1;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;91;-3106.202,-2384.499;Inherit;False;Property;_DepthFadeOutlineAmount;DepthFadeOutlineAmount;4;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;67;-2885.469,-2596.927;Inherit;False;Property;_OutlineColor;Outline Color;2;0;Create;True;0;0;0;False;0;False;0,1,0,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;90;-2894.379,-1490.61;Inherit;False;Property;_DepthFadeFillAmount;DepthFadeFillAmount;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;57;-1715.065,388.1933;Inherit;False;AlphaAtX;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;-1486.691,2308.914;Inherit;False;AlphaAtNegY;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;145;-1212.071,2259.724;Inherit;False;58;AlphaAtY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;281;-2544.015,-1659.464;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;111;-2750.005,-2902.54;Inherit;False;110;OutlineDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-1212.07,2064.731;Inherit;False;57;AlphaAtX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;142;-1214.686,1881.519;Inherit;False;60;AlphaAtNegY;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;143;-1215.996,1670.823;Inherit;False;59;AlphaAtNegX;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-2651.771,-1922.575;Inherit;False;110;OutlineDepth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenDepthNode;107;-2739.24,-2697.78;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;109;-2599.868,-2551.977;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ScreenDepthNode;113;-2638.959,-1770.243;Inherit;False;1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;147;-928.0276,1710.959;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;116;-2171.901,-1850.334;Inherit;False;5;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;151;-955.0276,2199.959;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;106;-2275.134,-2767.625;Inherit;False;5;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;196;-2370.139,-239.4306;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Compare;149;-925.0276,1854.959;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;150;-942.0276,2011.958;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;197;-2155.139,-231.4306;Inherit;True;Property;_TextureSample5;Texture Sample 5;6;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1608.08,281.0641;Inherit;False;32;OutlineTex;1;0;OBJECT;;False;1;SAMPLER2D;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;65;-1859.023,-1923.57;Inherit;False;FillColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;153;-740.0276,2129.959;Inherit;False;Or;-1;;7;dcfde22f80031984b87bcc46a052ad1f;0;2;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-1937.664,-2770.724;Inherit;False;OutlineColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;152;-733.0276,1798.959;Inherit;False;Or;-1;;8;dcfde22f80031984b87bcc46a052ad1f;0;2;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;184;-1880.951,-174.1754;Inherit;False;ScreenColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;189;-187.3874,119.889;Inherit;False;66;OutlineColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;154;-490.9996,1956.834;Inherit;False;Or;-1;;9;dcfde22f80031984b87bcc46a052ad1f;0;2;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;190;-227.3874,316.8891;Inherit;False;65;FillColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-1414.357,265.81;Inherit;True;Property;_Outline;Outline;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;194;-45.38727,44.88901;Inherit;False;184;ScreenColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-272.1532,1951.476;Inherit;False;DoIHaveTransparentNeighbor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;192;-4.387268,339.889;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.Compare;227;-1082.733,274.0045;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;195;-61.38727,260.889;Inherit;False;184;ScreenColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;191;15.61273,133.889;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;182;131.4349,-53.01258;Inherit;False;73;DoIHaveTransparentNeighbor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;188;215.6127,151.889;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;193;209.6127,326.889;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;-872.8926,284.8792;Inherit;False;IsMyAlpha0;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;183;446.435,86.98743;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;178;481.399,-195.0563;Inherit;False;72;IsMyAlpha0;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;187;495.6128,-69.11099;Inherit;False;184;ScreenColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;199;-2313.3,-3175.857;Inherit;False;DepthTest;-1;True;1;0;INT;0;False;1;INT;0
Node;AmplifyShaderEditor.IntNode;198;-2549.476,-3177.592;Inherit;False;Property;_DepthTest;Depth Test;5;0;Create;True;0;0;0;False;0;False;0;0;False;0;1;INT;0
Node;AmplifyShaderEditor.Compare;179;730.4908,-104.6484;Inherit;False;0;4;0;FLOAT;0;False;1;FLOAT;1;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;975.4604,-106.8878;Float;False;True;-1;2;ASEMaterialInspector;0;4;CheapOutline;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;22;0;282;1
WireConnection;23;0;282;2
WireConnection;28;0;29;0
WireConnection;56;0;52;0
WireConnection;56;1;55;0
WireConnection;53;0;54;0
WireConnection;53;1;44;0
WireConnection;42;0;53;0
WireConnection;42;1;43;0
WireConnection;36;0;38;0
WireConnection;36;1;37;0
WireConnection;26;0;27;0
WireConnection;26;1;30;0
WireConnection;48;0;51;0
WireConnection;48;1;56;0
WireConnection;32;0;8;0
WireConnection;9;1;26;0
WireConnection;41;1;42;0
WireConnection;47;1;48;0
WireConnection;35;1;36;0
WireConnection;10;0;34;0
WireConnection;10;1;9;0
WireConnection;50;0;49;0
WireConnection;50;1;47;0
WireConnection;46;0;45;0
WireConnection;46;1;41;0
WireConnection;40;0;39;0
WireConnection;40;1;35;0
WireConnection;229;0;40;1
WireConnection;230;0;46;1
WireConnection;134;0;8;0
WireConnection;231;0;50;1
WireConnection;228;0;10;1
WireConnection;58;0;229;0
WireConnection;110;0;134;1
WireConnection;59;0;230;0
WireConnection;57;0;228;0
WireConnection;60;0;231;0
WireConnection;281;0;64;1
WireConnection;281;1;64;2
WireConnection;281;2;64;3
WireConnection;281;3;90;0
WireConnection;109;0;67;0
WireConnection;109;1;91;0
WireConnection;147;0;143;0
WireConnection;116;0;112;0
WireConnection;116;1;113;0
WireConnection;116;2;64;0
WireConnection;116;3;281;0
WireConnection;151;0;145;0
WireConnection;106;0;111;0
WireConnection;106;1;107;0
WireConnection;106;2;67;0
WireConnection;106;3;109;0
WireConnection;149;0;142;0
WireConnection;150;0;144;0
WireConnection;197;0;196;0
WireConnection;65;0;116;0
WireConnection;153;2;150;0
WireConnection;153;3;151;0
WireConnection;66;0;106;0
WireConnection;152;2;147;0
WireConnection;152;3;149;0
WireConnection;184;0;197;0
WireConnection;154;2;152;0
WireConnection;154;3;153;0
WireConnection;1;0;33;0
WireConnection;73;0;154;0
WireConnection;192;0;190;0
WireConnection;227;0;1;1
WireConnection;191;0;189;0
WireConnection;188;0;194;0
WireConnection;188;1;189;0
WireConnection;188;2;191;3
WireConnection;193;0;195;0
WireConnection;193;1;190;0
WireConnection;193;2;192;3
WireConnection;72;0;227;0
WireConnection;183;0;182;0
WireConnection;183;2;188;0
WireConnection;183;3;193;0
WireConnection;199;0;198;0
WireConnection;179;0;178;0
WireConnection;179;2;187;0
WireConnection;179;3;183;0
WireConnection;0;0;179;0
ASEEND*/
//CHKSM=000930A4BE8BA74FB46F2E86A56D2CBA5DD9DEFA