class door : ScriptObject
{
	Vector3 slide;
	int opentime = 100;
	
	Vector3 pos;
	int curtime = 0;
	bool opp = false;

	
void Open()
{
	bool opp = true;
	pos = node.position;
	log.Info("ok");
}


void FixedUpdate(float timeStep)
	{
		
		if (opp) log.Info("sukaopen");
		if (opp==true) log.Info("aaaaa");

		if ((curtime<opentime) and (opp==true))
		{
			float lerpidx = 1/(opentime-curtime);
			node.position = Vector3(Lerp( pos.x , pos.x + slide.x, lerpidx),Lerp( pos.y , pos.y + slide.y, lerpidx),Lerp( pos.z , pos.z + slide.z, lerpidx));
			curtime ++;
			log.Info(curtime);
		}
		
		if (input.keyDown[KEY_SPACE])
		{
			this.Open();
			log.Info("opeen");
		}
	}
}