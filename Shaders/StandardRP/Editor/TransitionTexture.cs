using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using System.Linq;

public class TransitionTexture : CustomMaterialEditor
{
    protected override void CreateToggleList()
    {
        Toggles.Add(new FeatureToggle("Outline Enabled","outline","OUTLINE_ON","OUTLINE_OFF"));
    }
}