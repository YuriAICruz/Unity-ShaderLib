using System;
using System.Linq;
using System.Xml;
using UnityEngine;

namespace Pepita.Packages.Shaders.Shaders.UniversalRP
{
    [ExecuteInEditMode]
    public class GlobalShaderVariables : MonoBehaviour
    {
        private Transform _light;
        private readonly string MainDirectionalLight = "Main_Directional_Light";

        private void Awake()
        {
            _light = FindObjectsOfType<Light>().First(x => x.type == LightType.Directional).transform;
            Shader.SetGlobalVector(MainDirectionalLight, _light.forward);
        }

        private void Update()
        {
            Shader.SetGlobalVector(MainDirectionalLight, _light.forward);
        }
    }
}