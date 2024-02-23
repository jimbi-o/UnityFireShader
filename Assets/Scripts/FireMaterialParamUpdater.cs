using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FireMaterialParamUpdater : MonoBehaviour
{
    private Renderer rendererInstance;
    private Material material;

    void Start()
    {
        rendererInstance = GetComponent<Renderer>();
        if (GetComponent<Renderer>() != null)
        {
            material = rendererInstance.sharedMaterial;
        }
    }

    void Update()
    {
        SetAABBForMaterial();
    }

    void SetAABBForMaterial()
    {
        if (rendererInstance != null && material != null)
        {
            Bounds bounds = rendererInstance.bounds;
            material.SetVector("_BoxMin", bounds.min);
            material.SetVector("_BoxMax", bounds.max);
        }
    }
}
