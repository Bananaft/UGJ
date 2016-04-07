class bot : ScriptObject
{
    Node@ w1;
    Node@ w2;
    Node@ w3;
    Node@ w4;
    
    Array<Vector3> wheelPos(4);
    
    float suspL = 0.6;
    float suspF = 15;
    float suspCf = 10;
    float friction = 5;
    
void Init()
    {
      w1 = node.GetChild("wheel1");
      w2 = node.GetChild("wheel2");
      w3 = node.GetChild("wheel3");
      w4 = node.GetChild("wheel4");
      wheelPos[0] = w1.position;
      wheelPos[1] = w2.position;
      wheelPos[2] = w3.position;
      wheelPos[3] = w4.position;
     
        RigidBody@ body = node.GetComponent("RigidBody");
        //body.linearDamping = 0.9;
        body.angularDamping = 0.9; 
    }
    
void Update(float timeStep)
	{
    
    }

void FixedUpdate(float timeStep)
	{
        RigidBody@ body = node.GetComponent("RigidBody");
        
        Vector3 vecDir = node.rotation * Vector3(0,-1,0);
        PhysicsRaycastResult result1 = scene_.physicsWorld.RaycastSingle(Ray(node.rotation * wheelPos[0] + node.position, vecDir),suspL,1);
        PhysicsRaycastResult result2 = scene_.physicsWorld.RaycastSingle(Ray(node.rotation * wheelPos[1] + node.position, vecDir),suspL,1);
        PhysicsRaycastResult result3 = scene_.physicsWorld.RaycastSingle(Ray(node.rotation * wheelPos[2] + node.position, vecDir),suspL,1);
        PhysicsRaycastResult result4 = scene_.physicsWorld.RaycastSingle(Ray(node.rotation * wheelPos[3] + node.position, vecDir),suspL,1);
        
        uint contacts = 0;
        
		if (result1.body !is null)
        {
          w1.position = wheelPos[0] + Vector3(0,-0.3 + suspL + (-1 * result1.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result1.distance),0), wheelPos[0]);
          contacts++;
        } else {w1.position = wheelPos[0] + Vector3(0,-0.3,0);}
        
        if (result2.body !is null)
        {
          w2.position = wheelPos[1] + Vector3(0,-0.3 + suspL + (-1 * result2.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result2.distance),0), wheelPos[1]);
          contacts++;
        } else {w2.position = wheelPos[1] + Vector3(0,-0.3,0);}
        
        if (result3.body !is null)
        {
          w3.position = wheelPos[2] + Vector3(0,-0.3 + suspL + (-1 * result3.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result3.distance),0), wheelPos[2]);
          contacts++;
        } else {w3.position = wheelPos[2] + Vector3(0,-0.3,0);}
        
        if (result4.body !is null)
        {
          w4.position = wheelPos[3] + Vector3(0,-0.3 + suspL + (-1 * result4.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result4.distance),0), wheelPos[3]);
          contacts++;
        } else {w4.position = wheelPos[3] + Vector3(0,-0.3,0);}
        
        w1.Rotate(Quaternion(0,0,-5));
        w2.Rotate(Quaternion(0,0,-5));
        w3.Rotate(Quaternion(0,0,-5));
        w4.Rotate(Quaternion(0,0,-5));
        
        Vector3 targetVel = Vector3(0,0,0);
        Vector3 speedVec = body.linearVelocity;
        speedVec = body.rotation.Inverse() * speedVec * 5;
        speedVec.y = 0;
		
		
        if (speedVec.length > 1) speedVec.Normalize();
        
        if (contacts > 2)
        {
                if (input.keyDown[KEY_UP]) body.ApplyForce(body.rotation * Vector3(0,0,25));
                if (input.keyDown[KEY_DOWN]) body.ApplyForce(body.rotation * Vector3(0,0,-25));
                if (input.keyDown[KEY_LEFT]) body.ApplyTorque(body.rotation * Vector3(0,-5,0)); 
                if (input.keyDown[KEY_RIGHT])  body.ApplyTorque(body.rotation * Vector3(0,5,0)); 
        }
    }
    
}
