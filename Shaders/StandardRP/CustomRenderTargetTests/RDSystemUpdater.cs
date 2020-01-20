using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RDSystemUpdater : MonoBehaviour
{
    [SerializeField] CustomRenderTexture _texture;
    [SerializeField, Range(1, 16)] int _stepsPerFrame = 4;

    public bool Reset;

    void Start()
    {
        _texture.Initialize();
    }

    void Update()
    {
        if (Reset)
        {
            Reset = false;
            _texture.Initialize();
            return;
        }
        
        _texture.Update(_stepsPerFrame);
    }
}