class bot : ScriptObject
{
    Node@ w1;
    Node@ w2;
    Node@ w3;
    Node@ w4;

    Array<Vector3> wheelPos(4);

    float suspL = 0.6;
    float suspF = 20;
    float suspCf = 11;
    float friction = 15;

	bool headlight = true;
	
	SoundSource@ snd_go;
	SoundSource@ snd_turn;
	bool engend = false;
	bool engturn = false;
	
	bool boom = false;
	
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
        body.linearDamping = 0.4;
        body.angularDamping = 0.96;
		SubscribeToEvent("KeyDown", "HandleKeyDown");
		
		snd_go = node.CreateComponent("SoundSource");
		snd_turn = node.CreateComponent("SoundSource");
		
		snd_go.autoRemove = false;
		snd_turn.autoRemove = false;	
		snd_go.gain = 0.3;
		snd_turn.gain = 0.1;
		snd_go.frequency = 44100;
		snd_turn.frequency = 44100;
		
    }

void Update(float timeStep)
	{

    }

void HandleKeyDown(StringHash eventType, VariantMap& eventData)
	{
		int key = eventData["Key"].GetInt();
		if (key==KEY_F)
		{
				Node@ HLNode = node.GetChild("headlight",true);
				Node@ HLmesh = HLNode.GetChild("headlight_mesh", false);
				Light@ HL = HLNode.GetComponent("Light");
				if (headlight)
				{
					HL.enabled = false;
					HLmesh.enabled = false;
					headlight = false;
				} else {
					HL.enabled = true;
					HLmesh.enabled = true;
					headlight = true;
				}
		}
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
	// and result1.normal.DotProduct(body.rotation * Vector3(0,1,0)) > 0.9
		if (result1.body !is null)
        {
		w1.position = wheelPos[0] + Vector3(0,-0.3 + suspL + (-1 * result1.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result1.distance),0), result1.position -  body.position);
          contacts++;
        } else {w1.position = wheelPos[0] + Vector3(0,-0.3,0);}

        if (result2.body !is null)
        {
          w2.position = wheelPos[1] + Vector3(0,-0.3 + suspL + (-1 * result2.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result2.distance),0), result2.position -  body.position);
          contacts++;
        } else {w2.position = wheelPos[1] + Vector3(0,-0.3,0);}

        if (result3.body !is null)
        {
          w3.position = wheelPos[2] + Vector3(0,-0.3 + suspL + (-1 * result3.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result3.distance),0), result3.position -  body.position);
          contacts++;
        } else {w3.position = wheelPos[2] + Vector3(0,-0.3,0);}

        if (result4.body !is null)
        {
          w4.position = wheelPos[3] + Vector3(0,-0.3 + suspL + (-1 * result4.distance),0);
          body.ApplyForce(body.rotation * Vector3(0,suspCf + suspF * (suspL - result4.distance),0), result4.position -  body.position);
          contacts++;
        } else {w4.position = wheelPos[3] + Vector3(0,-0.3,0);}

        Vector3 targetVel = Vector3(0,0,0);
        Vector3 speedVec = body.linearVelocity;
        speedVec = body.rotation.Inverse() * speedVec;
        speedVec.y = 0;

		if (input.keyDown[KEY_UP] or input.keyDown[KEY_W]) targetVel.z=1.2;
        if (input.keyDown[KEY_DOWN] or input.keyDown[KEY_S]) targetVel.z=-1.2;

		if (speedVec.length > 1) speedVec.Normalize();

		Vector3 deltaVec = targetVel-speedVec;

		w1.Rotate(Quaternion(0,0,targetVel.z * -1 * 0.6 * 3.1416));
        w2.Rotate(Quaternion(0,0,targetVel.z * -1 * 0.6 * 3.1416));
        w3.Rotate(Quaternion(0,0,targetVel.z * -1 * 0.6 * 3.1416));
        w4.Rotate(Quaternion(0,0,targetVel.z * -1 * 0.6 * 3.1416));

		body.ApplyForce(body.rotation * deltaVec * friction * contacts);
        if (contacts > 2)
        {

                if (input.keyDown[KEY_LEFT] or input.keyDown[KEY_A]) body.ApplyTorque(body.rotation * Vector3(0,-12,0));
                if (input.keyDown[KEY_RIGHT] or input.keyDown[KEY_D])  body.ApplyTorque(body.rotation * Vector3(0,12,0));

		}

		
		if (input.keyDown[KEY_DOWN] or input.keyDown[KEY_S] or input.keyDown[KEY_UP] or input.keyDown[KEY_W])
		{
			if (!engend)
			{
			Sound@ go = cache.GetResource("Sound", "Sounds/eng_turn.wav");
			snd_go.Play(go);
			engend = true;
			
			}
		} else if (engend){
			snd_go.Stop();
			//Sound@ end = cache.GetResource("Sound", "Sounds/eng_end.wav");
			//snd_go.Play(end);
			engend = false;
		}
		if (input.keyDown[KEY_LEFT] or input.keyDown[KEY_A] or input.keyDown[KEY_RIGHT] or input.keyDown[KEY_D])
		{
			if (!engturn)
			{
			Sound@ turn = cache.GetResource("Sound", "Sounds/eng_go.wav");
			snd_turn.Play(turn);
			engturn = true;
			}
		} else if (engturn) {
			
			snd_turn.Stop();
			engturn =false;
		}
		
		if(body.collidingBodies.length>0 and (boom == false))
		{
			Sound@ sound = cache.GetResource("Sound", "Sounds/collision.wav");
						SoundSource@ soundSource = node.CreateComponent("SoundSource");
						soundSource.Play(sound);
						soundSource.gain = 0.8f;
						soundSource.autoRemove = true;
			boom = true;
		} 
		
		if(body.collidingBodies.length==0)
		{
			boom = false;
		}

    }

}
