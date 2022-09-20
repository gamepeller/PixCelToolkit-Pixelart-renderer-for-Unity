using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class RaycastHelper
{
    //this is a good general use solution that allows you to resize, move, change the aspect ratio and even rotate the quad, while still giving a correct conversion
    //performance is suboptimal, so if a lot of conversions per frame are needed, a faster less flexible apprach might be preferable
    //RenderPoint = new Vector3((DisplayPoint.x/Screen.width) * MainRenderTex.width, (DisplayPoint.y/Screen.height) * MainRenderTex.height);
    //and manually accounting for the offset, size, and aspect ratio if need be
    public static bool DisplayPointToRenderPoint(Camera DisplayCam, RenderTexture MainRenderTex, Vector3 DisplayPoint, out Vector3 RenderPoint)
    {
        Ray _ray = DisplayCam.ScreenPointToRay(DisplayPoint);
        RaycastHit _hit;

        if(Physics.Raycast(_ray, out _hit, 1f, 1<<DisplayCam.gameObject.layer))
        {
            RenderPoint = new Vector3(_hit.textureCoord.x * MainRenderTex.width, _hit.textureCoord.y * MainRenderTex.height);
            return true;
        }
        else
        {
            RenderPoint = Vector3.zero;
            return false;
        }
    }
}