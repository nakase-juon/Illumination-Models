using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CreateGround : MonoBehaviour
{
    public GameObject prefab;
    private float xPos;
 
    void Start()
    {
        xPos = 0f;
        while(xPos<5f)
        {
            
            Instantiate(prefab,new Vector3(0, 0, xPos),Quaternion.identity);
            xPos+=0.25f;
        }
    }
}
