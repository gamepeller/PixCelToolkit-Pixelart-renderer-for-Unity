#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEditor;
using System.Linq;
using System;



[ExecuteInEditMode]
public class Palette3DCreator : MonoBehaviour
{
    [Range(1,5)] public int ColorDepthPerChannel = 4;
    public Texture2D PaletteTex;
    public bool PaletteFromTexture = false;
    public Gradient ColorGradient;
    public int NumberOfSamples = 1024;
    public bool PaletteFromGradient = false;

    public Color[] Palette;
    public bool CreateFromPalette = false;

    public Gradient RRemap;
    public Gradient GRemap;
    public Gradient BRemap;
    public bool CreateFromRemapRGB = false;
    
    [Tooltip("Color Depth Per Channel and Palette are set by LUT. \nThe only exception is if Lut is 4 bit(heigh == 32), and Color Depth Per Channel is 5, it will upscale. \nIf you want to use lut as palette, just assign it to PaletteTex instead")]
    public Texture2D LUT;
    public bool MirrorLutVertically = false;
    [Tooltip("Color Depth Per Channel and Palette are set by LUT. \nThe only exception is if Lut is 4 bit(heigh == 32), and Color Depth Per Channel is 5, it will upscale. \nIf you want to use lut as palette, just assign it tp PaletteTex instead")]
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
        int BaseMapLength = BaseMap.GetLength(0);
        Color[,,] RemappedArray = new Color[BaseMapLength, BaseMapLength, BaseMapLength];
        
        int index = 0;
        for(int z = 0; z < BaseMapLength; z++)
        {
            for(int y = 0; y < BaseMapLength; y++)
            {
                for(int x = 0; x < BaseMapLength; x++)
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

    Color[] GradientRemapColors(Color[,,] BaseMap, Gradient R, Gradient G, Gradient B)
    {
        int BaseMapLength = BaseMap.GetLength(0);
        Color[,,] RemappedArray = new Color[BaseMapLength, BaseMapLength, BaseMapLength];
        
        float stepSize = 1f/(float)BaseMapLength;

        for(int x = 0; x < BaseMapLength; x++)
        {
            for(int y = 0; y < BaseMapLength; y++)
            {
                for(int z = 0; z < BaseMapLength; z++)
                {
                    Color RValue = R.Evaluate(x * stepSize);
                    Color GValue = G.Evaluate(y * stepSize);
                    Color BValue = B.Evaluate(z * stepSize);
                    
                    RemappedArray[x,y,z] = (RValue/3) + (GValue/3) + (BValue/3);
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

    Color[,,] MirrorLUT3D(Color[,,] lut, Vector3Int axis)
    {
        Color[,,] output = new Color[lut.GetLength(0),lut.GetLength(1),lut.GetLength(2)];

        Vector3Int dimensions = new Vector3Int(lut.GetLength(0), lut.GetLength(1), lut.GetLength(2));

        // make sure axix x,y,z are 0 or 1
        axis.x = Mathf.Clamp(axis.x, 0, 1);
        axis.y = Mathf.Clamp(axis.y, 0, 1);
        axis.z = Mathf.Clamp(axis.z, 0, 1);

        for(int x = 0; x < dimensions.x; x++)
        {
            for(int y = 0; y < dimensions.y; y++)
            {
                for(int z = 0; z < dimensions.z; z++)
                {
                    int xOut = x;
                    int yOut = y;
                    int zOut = z;

                    if(axis.x == 1) xOut = dimensions.x - x - 1;
                    if(axis.y == 1) yOut = dimensions.y - y - 1;
                    if(axis.z == 1) zOut = dimensions.z - z - 1;

                    output[xOut,yOut,zOut] = lut[x,y,z];
                }
            }
        }
        
        return output;
    
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

    Color[,,] LerpDoubleLUT3D(Color[,,] lut)
    {
        Vector3Int originalDimensions = new Vector3Int(lut.GetLength(0), lut.GetLength(1), lut.GetLength(2));
        Vector3Int dimensions = new Vector3Int(lut.GetLength(0) * 2, lut.GetLength(1) * 2, lut.GetLength(2) * 2);

        Color[,,] Xlerp = new Color[dimensions.x, originalDimensions.y, originalDimensions.z];
        Color[,,] Ylerp = new Color[dimensions.x, dimensions.y, originalDimensions.z];

        Color[,,] output = new Color[dimensions.x, dimensions.y, dimensions.z];

        // double height
        for (int x = 0; x < dimensions.x; x++)
        {
            bool xIsEven = x % 2 == 0;

            for(int y = 0; y < originalDimensions.y; y++)
            {
                for (int z = 0; z < originalDimensions.z; z++)
                {
                    if (xIsEven) // copy the original value
                    {
                        Xlerp[x, y, z] = lut[x / 2, y, z];
                    }
                    else // lerp between the two surrounding values
                    {
                        if(x == dimensions.x - 1) // if we're at the end, just copy the last value to avoid out of bounds
                        {
                            Xlerp[x, y, z] = lut[x / 2, y, z];
                        }
                        else // lerp between the two surrounding values
                        {
                            Xlerp[x, y, z] = Color.Lerp(lut[x / 2, y, z], lut[(x / 2) + 1, y, z], 0.5f);
                        }
                    }
                }
            }
        }

        // double width
        for (int x = 0; x < dimensions.x; x++)
        {
            for (int y = 0; y < dimensions.y; y++)
            {
                bool yIsEven = y % 2 == 0;

                for (int z = 0; z < originalDimensions.z; z++)
                {
                    if (yIsEven) // copy the original value
                    {
                        Ylerp[x, y, z] = Xlerp[x, y / 2, z];
                    }
                    else // lerp between the two surrounding values
                    {
                        if(y == dimensions.y - 1) // if we're at the end, just copy the last value to avoid out of bounds
                        {
                            Ylerp[x, y, z] = Xlerp[x, y / 2, z];
                        }
                        else // lerp between the two surrounding values
                        {
                            Ylerp[x, y, z] = Color.Lerp(Xlerp[x, y / 2, z], Xlerp[x, (y / 2) + 1, z], 0.5f);
                        }
                    }
                }
            }
        }

        // double depth
        for (int x = 0; x < dimensions.x; x++)
        {
            for (int y = 0; y < dimensions.y; y++)
            {
                for (int z = 0; z < dimensions.z; z++)
                {
                    bool zIsEven = z % 2 == 0;

                    if (zIsEven) // copy the original value
                    {
                        output[x, y, z] = Ylerp[x, y, z / 2];
                    }
                    else // lerp between the two surrounding values
                    {
                        if(z == dimensions.z - 1) // if we're at the end, just copy the last value to avoid out of bounds
                        {
                            output[x, y, z] = Ylerp[x, y, z / 2];
                        }
                        else // lerp between the two surrounding values
                        {
                            output[x, y, z] = Color.Lerp(Ylerp[x, y, z / 2], Ylerp[x, y, (z / 2) + 1], 0.5f);
                        }
                    }
                }
            }
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

        // create folder if it doesn't exist
        if(!AssetDatabase.IsValidFolder("Assets/Tools/PixCelToolkit/Posterize and Dither/Lut Based/LUTs"))
        {
            AssetDatabase.CreateFolder("Assets/Tools/PixCelToolkit/Posterize and Dither/Lut Based", "LUTs");
        }

        if(CreateFromLUT)
        {
            Texture3D ColMap;
            if(ColorDepthPerChannel == 5 && LUT.height < 64)
                ColMap = MirrorLutVertically ? 
                    Create3DColorMap(Upscale(MirrorLUT3D(LerpDoubleLUT3D(TurnLUT3D(LUT)), new Vector3Int(0,1,0)))) 
                    : 
                    Create3DColorMap(Upscale(LerpDoubleLUT3D(TurnLUT3D(LUT))));
            else 
                ColMap = MirrorLutVertically ? 
                    Create3DColorMap(Upscale(MirrorLUT3D(TurnLUT3D(LUT), new Vector3Int(0,1,0)))) 
                    : 
                    Create3DColorMap(Upscale(TurnLUT3D(LUT)));

            AssetDatabase.CreateAsset(ColMap, string.Format("Assets/Tools/PixCelToolkit/Posterize and Dither/Lut Based/LUTs/Converted-" + Mathf.Max((ColorDepthPerChannel*3), 12).ToString() + "-Bit-3DLUT-{0:yyyy-MM-dd_hh-mm-ss-tt}.asset",System.DateTime.Now));
            CreateFromLUT = false;
        }
        else if(CreateFromPalette)
        {
            Texture3D ColMap = Create3DColorMap(ClosestMatchRemapColors(CreateBaseColorArray(ColorDepthPerChannel), Palette));

            AssetDatabase.CreateAsset(ColMap, string.Format("Assets/Tools/PixCelToolkit/Posterize and Dither/Lut Based/LUTs/" + (ColorDepthPerChannel*3).ToString() + "-Bit-3DLUT-{0:yyyy-MM-dd_hh-mm-ss-tt}.asset",System.DateTime.Now));
            CreateFromPalette = false;
        }
        else if(CreateFromRemapRGB)
        {
            Texture3D ColMap = Create3DColorMap(GradientRemapColors(CreateBaseColorArray(ColorDepthPerChannel), RRemap, GRemap, BRemap));

            AssetDatabase.CreateAsset(ColMap, string.Format("Assets/Tools/PixCelToolkit/Posterize and Dither/Lut Based/LUTs/" + (ColorDepthPerChannel*3).ToString() + "-Bit-3DLUT-{0:yyyy-MM-dd_hh-mm-ss-tt}.asset",System.DateTime.Now));
            CreateFromRemapRGB = false;
        }
    }
}
#endif