using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class PerObjectOutline : MonoBehaviour
{
    [SerializeField] private LayerMask OutlineLayers;
    private Camera OutlineCamera;
    [SerializeField] private RenderPipelineAsset MainRenderer;
    void Start()
    {
        OutlineCamera = GetComponent<Camera>();
    }



    void Update()
    {
    }
}
