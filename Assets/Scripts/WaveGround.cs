using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveGround : MonoBehaviour
{
    public float waveSpeed = 0.75f; //地面の波の速さ
    public float amplitude = 0.05f; //振幅の大きさ
    // Update is called once per frame
    void Update()
    {
        Vector3 pos = this.transform.position;
        float sin = Mathf.Sin(Time.time * waveSpeed * pos.x) * amplitude;
        float cos = Mathf.Cos(Time.time * waveSpeed * pos.z) * amplitude;
        transform.position = new Vector3(pos.x,sin + cos - 0.15f, pos.z);
    }
}
