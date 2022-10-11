// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "PosterizeAndDither"
{
	Properties
	{
		_MainTex ( "Screen", 2D ) = "black" {}
		_DitherTreshold("DitherTreshold", Range( 0 , 0.5)) = 0
		_PosterizeSteps("Posterize Steps", Int) = 16
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
			
			uniform int _PosterizeSteps;
			uniform float _DitherTreshold;
			float3 RGBToHSV(float3 c)
			{
				float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
				float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
				float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
				float d = q.x - min( q.w, q.y );
				float e = 1.0e-10;
				return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
			}
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
				float2 uv_MainTex = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float4 tex2DNode3 = tex2D( _MainTex, uv_MainTex );
				float4 Ceil8 = ( floor( ( _PosterizeSteps * tex2DNode3 ) ) / _PosterizeSteps );
				float3 hsvTorgb9 = RGBToHSV( Ceil8.rgb );
				float4 Color7 = tex2DNode3;
				float3 hsvTorgb10 = RGBToHSV( Color7.rgb );
				float FloorDiff19 = abs( ( hsvTorgb9.z - hsvTorgb10.z ) );
				float4 Floor22 = ( ceil( ( _PosterizeSteps * tex2DNode3 ) ) / _PosterizeSteps );
				float3 hsvTorgb28 = RGBToHSV( Floor22.rgb );
				float CeilDiff31 = abs( ( hsvTorgb10.z - hsvTorgb28.z ) );
				float MinDiff36 = ( FloorDiff19 <= CeilDiff31 ? FloorDiff19 : CeilDiff31 );
				float DitherTreshold16 = _DitherTreshold;
				float4 screenPos = i.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float2 clipScreen21 = ase_screenPosNorm.xy * _ScreenParams.xy;
				float dither21 = Dither8x8Bayer( fmod(clipScreen21.x, 8), fmod(clipScreen21.y, 8) );
				dither21 = step( dither21, Color7.r );
				float4 lerpResult26 = lerp( Ceil8 , Floor22 , dither21);
				float4 DitheredCol45 = lerpResult26;
				float4 MinDiffCol42 = ( FloorDiff19 <= CeilDiff31 ? Floor22 : Ceil8 );
				

				finalColor = ( MinDiff36 > DitherTreshold16 ? DitheredCol45 : MinDiffCol42 );

				return finalColor;
			} 
			ENDCG 
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18935
441.3333;229.3333;1291.333;749.6667;2937.78;479.3937;1;True;False
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-2386.438,-248.8771;Inherit;False;0;0;_MainTex;Shader;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.IntNode;47;-1881.053,-131.3441;Inherit;False;Property;_PosterizeSteps;Posterize Steps;1;0;Create;True;0;0;0;False;0;False;16;0;False;0;1;INT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2246.438,-242.0589;Inherit;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-1948.829,-386.8743;Inherit;False;2;2;0;INT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-1934.857,71.35921;Inherit;False;2;2;0;INT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FloorOpNode;5;-1803.57,-381.2974;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CeilOpNode;15;-1798.57,83.7027;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;6;-1659.829,-372.8744;Inherit;False;2;0;COLOR;0,0,0,0;False;1;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;18;-1645.856,85.35919;Inherit;False;2;0;COLOR;0,0,0,0;False;1;INT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1532.74,-376.2738;Inherit;False;Ceil;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;22;-1497.935,89.02673;Inherit;False;Floor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;7;-1526.236,-177.3731;Inherit;False;Color;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RGBToHSVNode;9;-1317.553,-379.6234;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;10;-1327.553,-161.6234;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RGBToHSVNode;28;-1300.673,61.47256;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleSubtractOpNode;29;-1052.089,-22.13807;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-1039.552,-244.6234;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;17;-896.0373,-233.8381;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;14;-1728.21,-648.3264;Inherit;False;7;Color;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.AbsOpNode;30;-902.8992,-6.355379;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DitheringNode;21;-1541.834,-651.0399;Inherit;False;1;False;4;0;FLOAT;0;False;1;SAMPLER2D;;False;2;FLOAT4;0,0,0,0;False;3;SAMPLERSTATE;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-729.1675,-6.357593;Inherit;False;CeilDiff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-1523.717,-761.2139;Inherit;False;22;Floor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;19;-728.0562,-239.4455;Inherit;False;FloorDiff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;23;-1523.387,-860.785;Inherit;False;8;Ceil;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-2331.177,-547.5568;Inherit;False;Property;_DitherTreshold;DitherTreshold;0;0;Create;True;0;0;0;False;0;False;0;0.021;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;26;-1278.052,-814.7744;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;43;-710.4031,172.3593;Inherit;False;8;Ceil;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.Compare;35;-456.3719,-233.9946;Inherit;False;5;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;-698.403,80.35928;Inherit;False;22;Floor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;45;-1058.535,-800.7355;Inherit;False;DitheredCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;36;-240.3719,-255.9946;Inherit;False;MinDiff;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;16;-2048.89,-550.3044;Inherit;False;DitherTreshold;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;41;-434.403,-8.640717;Inherit;False;5;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-27.3297,-199.8357;Inherit;False;16;DitherTreshold;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;42;-228.403,-18.64072;Inherit;False;MinDiffCol;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-22.53448,-100.7354;Inherit;False;45;DitheredCol;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;37;9.448425,-298.9297;Inherit;False;36;MinDiff;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.Compare;38;259.594,-152.3575;Inherit;False;2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;487.3337,-124.8778;Float;False;True;-1;2;ASEMaterialInspector;0;4;PosterizeAndDither;c71b220b631b6344493ea3cf87110c93;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;True;0;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;3;0;1;0
WireConnection;4;0;47;0
WireConnection;4;1;3;0
WireConnection;12;0;47;0
WireConnection;12;1;3;0
WireConnection;5;0;4;0
WireConnection;15;0;12;0
WireConnection;6;0;5;0
WireConnection;6;1;47;0
WireConnection;18;0;15;0
WireConnection;18;1;47;0
WireConnection;8;0;6;0
WireConnection;22;0;18;0
WireConnection;7;0;3;0
WireConnection;9;0;8;0
WireConnection;10;0;7;0
WireConnection;28;0;22;0
WireConnection;29;0;10;3
WireConnection;29;1;28;3
WireConnection;11;0;9;3
WireConnection;11;1;10;3
WireConnection;17;0;11;0
WireConnection;30;0;29;0
WireConnection;21;0;14;0
WireConnection;31;0;30;0
WireConnection;19;0;17;0
WireConnection;26;0;23;0
WireConnection;26;1;27;0
WireConnection;26;2;21;0
WireConnection;35;0;19;0
WireConnection;35;1;31;0
WireConnection;35;2;19;0
WireConnection;35;3;31;0
WireConnection;45;0;26;0
WireConnection;36;0;35;0
WireConnection;16;0;13;0
WireConnection;41;0;19;0
WireConnection;41;1;31;0
WireConnection;41;2;44;0
WireConnection;41;3;43;0
WireConnection;42;0;41;0
WireConnection;38;0;37;0
WireConnection;38;1;39;0
WireConnection;38;2;46;0
WireConnection;38;3;42;0
WireConnection;0;0;38;0
ASEEND*/
//CHKSM=95734F10A5520437A495FB35DC19BF468493FB62