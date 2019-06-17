using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using UnityEngine;

namespace Graphene.Shader.Scripts
{
    public class TransitionMaterialManager : MonoBehaviour
    {
        public float Duration = 1f;
        public float Delay = 0.2f;

        private bool _shown;

        private List<Material> _materials;

        void Start()
        {
            GetAllMaterials();
        }

        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Space))
            {
                if (_shown)
                    HideAll();
                else
                    ShowAll();
            }
        }

        private void HideAll()
        {
            _shown = false;
            for (int i = 0; i < _materials.Count; i++)
            {
                StartCoroutine(Hide(_materials[i], i));
            }
        }

        private void ShowAll()
        {
            _shown = true;
            for (int i = 0; i < _materials.Count; i++)
            {
                StartCoroutine(Show(_materials[i], i));
            }
        }

        void GetAllMaterials()
        {
            _materials = new List<Material>();
            var rdr = FindObjectsOfType<Renderer>().ToList();

            rdr = rdr.OrderBy(x => Vector3.Distance(transform.position, x.transform.position)).ToList();

            foreach (var r in rdr)
            {
                _materials.AddRange(r.materials);
            }
        }

        IEnumerator Show(Material mat, int index)
        {
            var t = 0f;

            yield return new WaitForSeconds(index * Delay);

            while (t < Duration)
            {
                mat.SetFloat("_Transition", t / Duration);

                t += Time.deltaTime;

                yield return null;
            }
        }

        IEnumerator Hide(Material mat, int index)
        {
            var t = 0f;

            yield return new WaitForSeconds(index * Delay);

            while (t < Duration)
            {
                mat.SetFloat("_Transition", 1 - t / Duration);

                t += Time.deltaTime;

                yield return null;
            }
        }
    }
}