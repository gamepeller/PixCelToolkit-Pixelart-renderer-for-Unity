using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEditor;
using System.Linq;



[ExecuteInEditMode]
public class Palette3DCreator : MonoBehaviour
{

    public Texture2D PaletteTex;
    public bool PaletteFromTexture = false;
    public Gradient ColorGradient;
    public int NumberOfSamples = 1024;
    public bool PaletteFromGradient = false;

    [Range(1,5)]
    public int ColorDepthPerChannel = 4;
    public Color[] Palette;
    public bool CreateFromPalette = false;
    
    [Tooltip("Color Depth Per Channel and Palette are set by LUT \nIf you want to use lut as palette, just put it in PaletteTex instead")]
    public Texture2D LUT;
    [Tooltip("Color Depth Per Channel and Palette are set by LUT \nIf you want to use lut as palette, just put it in PaletteTex instead")]
    public bool CreateFromLUT = false;




    Texture3D Create3DColorMap(Color[] ColorArray)
    {
        Texture3D tex = new Texture3D(256,256,256, TextureFormat.RGB24, false);
        tex.wrapMode = TextureWrapMode.Clamp;
        tex.filterMode = FilterMode.Point;

        tex.SetPixels(ColorArray);
        tex.Apply(false);

        return tex;
    }

    Color[,,] CreateBaseColorArray(int bitsPerChannel)
    {
        int side = (int) Mathf.Pow(2, bitsPerChannel);
        
        Color[,,] colArray = new Color[side,side,side];
        
        for(int z = 0; z < side; z++)
        {
            for(int y = 0; y < side; y++)
            {
                for(int x = 0; x < side; x++)
                {
                    colArray[x,y,z] = new Color((float)x/side, (float)y/side, (float)z/side);
                }
            }
        }
        return colArray;
    }
    
    Color[] ClosestMatchRemapColors(Color[,,] BaseMap, Color[] _palette)
    {
        Color[,,] RemappedArray = new Color[BaseMap.GetLength(0), BaseMap.GetLength(1), BaseMap.GetLength(2)];
        
        int index = 0;
        for(int z = 0; z < BaseMap.GetLength(2); z++)
        {
            for(int y = 0; y < BaseMap.GetLength(1); y++)
            {
                for(int x = 0; x < BaseMap.GetLength(0); x++)
                {
                    float OldDiff = 5000f;
                    Color BestMatch = Color.black;
                    foreach(Color to in _palette)
                    {
                        float NewDiff = Mathf.Abs(BaseMap[x,y,z].r - to.r) + Mathf.Abs(BaseMap[x,y,z].g - to.g) + Mathf.Abs(BaseMap[x,y,z].b - to.b);
                
                        if(NewDiff < OldDiff) 
                        {
                            BestMatch = to;
                            OldDiff = NewDiff;
                        }
                    }
                    RemappedArray[x,y,z] = BestMatch;
                    index++;
                }
            }
        }

        return Upscale(RemappedArray);
    }

    Color[] Upscale(Color[,,] source)
    {
        Color[] colArray = new Color[16777216];
        int[] sIndex = new int[3] {256/source.GetLength(0), 256/source.GetLength(1), 256/source.GetLength(2)};
        
        int index = 0;
        for(int z = 0; z < 256; z++)
        {
            for(int y = 0; y < 256; y++)
            {
                for(int x = 0; x < 256; x++)
                {
                    colArray[index++] = source[Mathf.RoundToInt(x/sIndex[0]), Mathf.RoundToInt(y/sIndex[1]), Mathf.RoundToInt(z/sIndex[2])];
                }
            }
        }
        
        return colArray;
    }

    Color[] SampleGradient(Gradient g, int NumberOfSamples)
    {
        Color[] output = new Color[NumberOfSamples];
        float stepSize = 1f/NumberOfSamples;
        
        float step = 0f;
        for(int i = 0; i < NumberOfSamples; i++)
        {
            output[i] = g.Evaluate(step);
            step += stepSize;
        }
        return output;
    }
    Color[] ExtractColFromTex2D(Texture2D tex)
    {
        Color[] op = tex.GetPixels(0);
        
        for(int i = 0; i < op.Length; i++)
        {
            op[i].a = 1;
        }

        return op.Distinct().ToArray();

    }
    Color[,,] TurnLUT3D(Texture2D lut)
    {
        Color[,,] output = new Color[lut.height,lut.height,lut.height];
        Color[] lutPixels = lut.GetPixels(0);


        for(int i = 0; i < lutPixels.Length; i++)
        {
            var x = i % lut.height;
            var y = (i / lut.height) % lut.height;
            var z = i / (lut.height * lut.height);

            output[x,z,y] = lutPixels[i];
        }
        
        return output;
    }
    void Update()
    {
        if(PaletteFromGradient)
        {
            Palette = SampleGradient(ColorGradient, NumberOfSamples);
            PaletteFromGradient = false;
        }
        if(PaletteFromTexture)
        {
            Palette = ExtractColFromTex2D(PaletteTex);
            PaletteFromTexture = false;
        }

        if(CreateFromLUT)
        {
            Texture3D ColMap = Create3DColorMap(Upscale(TurnLUT3D(LUT)));

            AssetDatabase.CreateAsset(ColMap, string.Format("Assets/PixCelToolkit/Posterize and Dither/Lut Based/LUTs/Converted-3DLUT-{0:yyyy-MM-dd_hh-mm-ss-tt}.asset",System.DateTime.Now));
            CreateFromLUT = false;
        }
        else if(CreateFromPalette)
        {
            Texture3D ColMap = Create3DColorMap(ClosestMatchRemapColors(CreateBaseColorArray(ColorDepthPerChannel), Palette));

            AssetDatabase.CreateAsset(ColMap, string.Format("Assets/PixCelToolkit/Posterize and Dither/Lut Based/LUTs/" + (ColorDepthPerChannel*3).ToString() + "-Bit-3DLUT-{0:yyyy-MM-dd_hh-mm-ss-tt}.asset",System.DateTime.Now));
            CreateFromPalette = false;
        }
    }
}
