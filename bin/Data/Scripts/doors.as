class door : ScriptObject
{
	Vector3 slide;
	float opentime = 100;
	bool effectOn = false;
	
	Vector3 pos;
	int curtime = 0;
	bool opp;

	
void Open()
{
	opp = true;
	pos = node.position;
	//log.Info("ok");
	
	if (effectOn)
	{
	Node@ effect = node.GetChild("effect");
	effect.enabled = true;
	}
}


void FixedUpdate(float timeStep)
	{
		
		//if (opp) log.Info("sukaopen");
		//if (opp==true) log.Info("aaaaa");

		if ((curtime<opentime) and (opp==true))
		{
			float lerpidx = curtime/opentime;
			
			node.position = Vector3(Lerp( pos.x , pos.x + slide.x, lerpidx),Lerp( pos.y , pos.y + slide.y, lerpidx),Lerp( pos.z , pos.z + slide.z, lerpidx));
			curtime ++;
			//log.Info(lerpidx);
		}
		
		//if (input.keyDown[KEY_SPACE])
		//{
		//	this.Open();
		//	//log.Info("opeen");
		//}
	}
}

class key : ScriptObject
{
	
	
void FixedUpdate(float timeStep)
	{
		node.Rotate(Quaternion(0,0,2));
		RigidBody@ body = node.GetComponent("RigidBody");
		if(body.collidingBodies.length>0)
		{
			
			door@ myDoor = cast<door>(node.parent.scriptObject);
			
			myDoor.Open();
			
			node.enabled = false;
			
			Sound@ sound = cache.GetResource("Sound", "Sounds/start.wav");
			SoundSource3D@ soundSource = node.parent.CreateComponent("SoundSource3D");
			soundSource.Play(sound);
			soundSource.gain = 0.9f;
			soundSource.autoRemove = true;
			
			
		}
	}
}