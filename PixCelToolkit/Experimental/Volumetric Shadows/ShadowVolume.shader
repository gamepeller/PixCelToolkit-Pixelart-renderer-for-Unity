// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "ShadowVolume"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_ShadowPos("ShadowPos", Vector) = (0,0,0,0)
		_SoftEdgesFactor("Soft Edges Factor", Float) = 0
		_Darkness("Darkness", Float) = 0
		_Clamp("Clamp", Vector) = (0,0,0,0)
		_NumberOfShadows("Number Of Shadows", Range( 1 , 128)) = 1
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
			
			uniform float _NumberOfShadows;
			uniform float4 _PosArray[128];
			UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
			uniform float4 _CameraDepthTexture_TexelSize;
			uniform float4 _ShadowPos;
			uniform float _Darkness;
			uniform float _SoftEdgesFactor;
			uniform float2 _Clamp;
			float2 UnStereo( float2 UV )
			{
				#if UNITY_SINGLE_PASS_STEREO
				float4 scaleOffset = unity_StereoScaleOffset[ unity_StereoEyeIndex ];
				UV.xy = (UV.xy - scaleOffset.zw) / scaleOffset.xy;
				#endif
				return UV;
			}
			
			float3 InvertDepthDir72_g1( float3 In )
			{
				float3 result = In;
				#if !defined(ASE_SRP_VERSION) || ASE_SRP_VERSION <= 70301
				result *= float3(1,1,-1);
				#endif
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

			half4 ShadowFunc(float2 _Clamp, float _SoftEdgesFactor, float _Darkness, float4 _ShadowPos, half4 _Color, float4 _WorldPosition, half4 _Lowest)
			{
				
				float4 break2 = _ShadowPos;
				float3 appendResult4 = (float3(break2.x , break2.y , break2.z));
				
				float temp_output_5_0 = distance( mul( unity_CameraToWorld, _WorldPosition ) , float4( appendResult4 , 0.0 ) );

				float4 tex2DNode15 = _Color;
				float lerpResult14 = lerp( _Darkness , ( ( 1.0 - ( temp_output_5_0 / break2.w ) ) * _Darkness ) , _SoftEdgesFactor);
				float2 break12 = _Clamp;
				float clampResult16 = clamp( lerpResult14 , break12.x , break12.y );
				float4 temp_cast_2 = (clampResult16).xxxx;
				float4 ifLocalVar18 = 0;
				
				if( temp_output_5_0 >= break2.w )
				ifLocalVar18 = tex2DNode15;
				else
				ifLocalVar18 = ( tex2DNode15 - temp_cast_2 );
				

				return min(ifLocalVar18, _Lowest);
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
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				half4 finalColor = tex2D( _MainTex, uv_MainTex );

				// ase common template code
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 UV22_g3 = ase_screenPosNorm.xy;
				float2 localUnStereo22_g3 = UnStereo( UV22_g3 );
				float2 break64_g1 = localUnStereo22_g3;
				float clampDepth69_g1 = SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_screenPosNorm.xy );
				#ifdef UNITY_REVERSED_Z
				float staticSwitch38_g1 = ( 1.0 - clampDepth69_g1 );
				#else
				float staticSwitch38_g1 = clampDepth69_g1;
				#endif
				
				float3 appendResult39_g1 = (float3(break64_g1.x , break64_g1.y , staticSwitch38_g1));
				float4 appendResult42_g1 = (float4((appendResult39_g1*2.0 + -1.0) , 1.0));
				
				float4 temp_output_43_0_g1 = mul( unity_CameraInvProjection, appendResult42_g1 );
				float3 temp_output_46_0_g1 = ( (temp_output_43_0_g1).xyz / (temp_output_43_0_g1).w );
				
				float3 In72_g1 = temp_output_46_0_g1;
				float3 localInvertDepthDir72_g1 = InvertDepthDir72_g1( In72_g1 );
				
				float4 appendResult49_g1 = (float4(localInvertDepthDir72_g1 , 1.0));

				half4 _Lowest = finalColor;

				for(int i = 0; i < _NumberOfShadows; i++)
				{
					_Lowest = ShadowFunc(_Clamp, _SoftEdgesFactor, _Darkness, _PosArray[i], finalColor, appendResult49_g1, _Lowest);
				}

				return _Lowest;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
433.3333;158.6667;1280;745;3197.079;1150.843;2.610399;True;False
Node;AmplifyShaderEditor.Vector4Node;1;-2282.391,-246.861;Inherit;False;Property;_ShadowPos;ShadowPos;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;2;-1831.046,-65.48125;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.FunctionNode;3;-1833.625,-229.2941;Inherit;False;Reconstruct World Position From Depth;-1;;1;e7094bcbcc80eb140b2a3dbe6a861de8;0;0;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;4;-1604.56,-59.91626;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DistanceOpNode;5;-1324.084,-179.2728;Inherit;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-1606.577,155.9603;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1292.316,307.6892;Inherit;False;Property;_Darkness;Darkness;2;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;7;-1347.513,176.7808;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1304.696,395.4079;Inherit;False;Property;_SoftEdgesFactor;Soft Edges Factor;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;10;-1067.458,430.4657;Inherit;False;Property;_Clamp;Clamp;3;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1117.022,189.1832;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;12;-835.3017,411.9668;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;13;-1347.919,-376.3055;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;14;-923.7277,184.3957;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;16;-687.8162,207.1052;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;15;-1139.249,-296.9784;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;17;-474.7919,86.2016;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ConditionalIfNode;18;-240.2926,-21.36897;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-2265.386,-32.23367;Inherit;False;Property;_NumberOfShadows;Number Of Shadows;4;0;Create;True;0;0;0;True;0;False;1;0;1;128;0;1;FLOAT;0
Node;AmplifyShaderEditor.GlobalArrayNode;19;-2268.454,63.25159;Inherit;False;_PosArray;0;83;2;True;False;0;1;True;Object;-1;4;0;INT;0;False;2;INT;0;False;1;INT;0;False;3;INT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;4;ShadowVolume;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;2;0;1;0
WireConnection;4;0;2;0
WireConnection;4;1;2;1
WireConnection;4;2;2;2
WireConnection;5;0;3;0
WireConnection;5;1;4;0
WireConnection;6;0;5;0
WireConnection;6;1;2;3
WireConnection;7;0;6;0
WireConnection;9;0;7;0
WireConnection;9;1;8;0
WireConnection;12;0;10;0
WireConnection;14;0;8;0
WireConnection;14;1;9;0
WireConnection;14;2;11;0
WireConnection;16;0;14;0
WireConnection;16;1;12;0
WireConnection;16;2;12;1
WireConnection;15;0;13;0
WireConnection;17;0;15;0
WireConnection;17;1;16;0
WireConnection;18;0;5;0
WireConnection;18;1;2;3
WireConnection;18;2;15;0
WireConnection;18;3;15;0
WireConnection;18;4;17;0
WireConnection;0;0;18;0
ASEEND*/
//CHKSM=149AD025C29787F87A9552F7C91D9CBA4F7D789F