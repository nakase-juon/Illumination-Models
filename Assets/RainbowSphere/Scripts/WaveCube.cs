using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaveCube : MonoBehaviour
{
	float t=2.5f;
	float xt=0.2f;
	float zt=0.5f;
	float amplitude=0.15f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
    	//できなかった
    	// Vector3 pos = this.transform.position;
     //    float sin = Mathf.Sin(Time.time);
     //    this.transform.position = new Vector3(0,sin,0);
    	transform.position = new Vector3(transform.position.x, 
            //Mathf.Sin (Time.time*t+transform.position.x*xt+transform.position.z*zt)*amplitude
    		Mathf.Sin (Time.time*t+transform.position.x*xt)*amplitude
            +Mathf.Cos (Time.time*t+transform.position.z*zt)*amplitude,
    		transform.position.z);
    }
}
