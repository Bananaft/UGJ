class door : ScriptObject
{
	Vector3 slide;
	float opentime = 100;
	bool effectOn = false;
	bool nopointer = false;
	
	Vector3 pos;
	int curtime = 0;
	bool opp;
	
	Sprite@ door_pointer;
	bool init = false;
	

	
void Open()
{
	
	//log.Info("ok");
	
		if (effectOn)
		{
		Node@ effect = node.GetChild("effect");
		effect.enabled = true;
		}
		
		
		
		opp = true;
		pos = node.position;
	

}


void FixedUpdate(float timeStep)
	{
		if (init == false)
		{
				Texture2D@ ringTex = cache.GetResource("Texture2D", "Textures/ring.png");
				
				door_pointer = Sprite();
				door_pointer.texture = ringTex;
				door_pointer.size = IntVector2(128,128);
				door_pointer.hotSpot = IntVector2(64, 64);
				door_pointer.verticalAlignment = VA_TOP;
				door_pointer.horizontalAlignment = HA_LEFT;
				ui.root.AddChild(door_pointer);
				door_pointer.visible = false;
				init = true;
				log.Info("door_pointer_init");
		}
		//if (opp) log.Info("sukaopen");
		//if (opp==true) log.Info("aaaaa");

		if ((curtime<opentime) and (opp==true))
		{
			float lerpidx = curtime/opentime;
			
			node.position = Vector3(Lerp( pos.x , pos.x + slide.x, lerpidx),Lerp( pos.y , pos.y + slide.y, lerpidx),Lerp( pos.z , pos.z + slide.z, lerpidx));
			curtime ++;
			//log.Info(lerpidx);
			
			if (nopointer == false)
			{
				door_pointer.visible = true;
				Viewport@ vp = renderer.viewports[0];
				door_pointer.position = Vector2(graphics.width , graphics.height) * vp.camera.WorldToScreenPoint( node.worldPosition);
				float size = 64 * (2+ Sin(time.elapsedTime * 500));
				door_pointer.size = IntVector2(size,size);
				door_pointer.hotSpot = IntVector2(size/2,size/2);
			
			}
		}else {
			door_pointer.visible = false;
			
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