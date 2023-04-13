using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class FPSDisplay : MonoBehaviour {
 
    private int frameCount;
    private float prevTime;
    private float fps;
 
    void Start()
    {
        // 変数の初期化
        frameCount = 0;
        prevTime = 0.0f;
    }
 
    // 更新処理
    void Update()
    {
        frameCount++;
        float time = Time.realtimeSinceStartup - prevTime;
 
        if (time >= 0.5f) {
            fps = frameCount / time;
            Debug.Log(fps);
 
            frameCount = 0;
            prevTime = Time.realtimeSinceStartup;
        }
    }
 
    // 表示処理
    private void OnGUI()
    {
        GUILayout.Label(fps.ToString());
    }
}