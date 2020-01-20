using System.Collections;
using UnityEngine;

namespace Graphene.Shader.Scripts
{
    [RequireComponent(typeof(Renderer))]
    public class TransitionOutlineMaterialManager : MonoBehaviour
    {
        public float Duration = 1f;

        private Renderer _renderer;

        private void Awake()
        {
            GetRenderer();
        }

        private void GetRenderer()
        {
            if (_renderer == null)
                _renderer = GetComponent<Renderer>();
        }

        public void ShowOutline()
        {
            GetRenderer();
            
            StopAllCoroutines();

            foreach (var material in _renderer.materials)
            {
                StartCoroutine(Animate(material, true));
            }
        }

        public void HideOutline()
        {
            GetRenderer();
            
            StopAllCoroutines();

            foreach (var material in _renderer.materials)
            {
                StartCoroutine(Animate(material, false));
            }
        }

        IEnumerator Animate(Material mat, bool show)
        {
            var t = 0f;

            while (t < Duration)
            {
                if (show)
                    mat.SetFloat("_OutlineTransition", t / Duration);
                else
                    mat.SetFloat("_OutlineTransition", 1 - t / Duration);

                t += Time.deltaTime;

                yield return null;
            }
        }
    }
}