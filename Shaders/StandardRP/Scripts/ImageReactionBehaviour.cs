using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace DefaultNamespace
{
    public class ClickPoint : MonoBehaviour, IPointerDownHandler
    {
        private RectTransform _rect;
        private Material _material;

        private void Awake()
        {
            _rect = GetComponent<RectTransform>();
            _material = GetComponent<Image>().material;
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            Vector2 localCursor;

            if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(_rect, eventData.position,
                eventData.pressEventCamera, out localCursor))
            {
                Debug.Log(eventData);
                return;
            }

            var localPos = new Vector4(
                localCursor.x / _rect.sizeDelta.x + 0.5f,
                localCursor.y / _rect.sizeDelta.y,
                0,
                0
            );

            _material.SetVector("_HitPoint", localPos);
            _material.SetVector("_Size", new Vector4(_rect.sizeDelta.x, _rect.sizeDelta.y, 0, 0));
            
            _material.SetFloat("_TimeStart", Time.time);
        }
    }
}