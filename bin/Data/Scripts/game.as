#include "bot.as";

Scene@ scene_;
Node@ cameraNode;
float camDistance = 120;
Node@ botCameraNode;
Viewport@ rttViewport;
Viewport@ dummyVP;
RenderSurface@ surface;
Texture2D@ renderTexture;
float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle
int scanLine = 0;
int scanSpeed = 1;
float botcamFov = 60;
IntVector2 botcamRes = IntVector2(320,240);

Text@ uiSpeed;
Text@ uiBearing;
Text@ uiTime;

Sprite@ splash;
Window@ bg;

void Start()
{
    //log.level = 0;
    scene_ = Scene();
	CreateConsoleAndDebugHud();

	SubscribeToEvent("KeyDown", "HandleKeyDown");
    SubscribeToEvent("Update", "HandleUpdate");
    
	scene_.LoadXML(cache.GetFile("Scenes/level_1.xml"));
	
	cameraNode = Node();
	Node@ camNode = cameraNode.CreateChild("camNode");
    Camera@ camera = camNode.CreateComponent("Camera");
    //camera.orthographic=true;
	camera.fov = 20;
	camera.farClip = 12000;
	
	
    
    cameraNode.rotation = Quaternion( 22.5 , -45.0 , 0.0 );
    camNode.position = Vector3(0.1 * camDistance,0,-1 * camDistance);
	cameraNode.position = Vector3(-10,0,-10);
    
    //Node@ botNode = scene_.CreateChild("botNode");
    Node@ botNode = scene_.InstantiateXML(cache.GetResource("XMLFile", "Objects/bot.xml"), Vector3(0,0.0,-50),Quaternion(0,0,0));
    //RigidBody@ botBody = botNode.GetComponent("RigidBody");
    //botBody.SetTransform(Vector3(0,10,0),Quaternion(90,30,80));
    bot@ bot = cast<bot>(botNode.CreateScriptObject(scriptFile, "bot"));
    bot.Init();

    botCameraNode = botNode.GetChild("camera").CreateChild("botCameraNode");
    //botCameraNode.position = Vector3(0,2,0);
    Camera@ botCamera = botCameraNode.CreateComponent("Camera");
    botCamera.fov = botcamFov/botcamRes.y;
    audio.listener = botCameraNode.CreateComponent("SoundListener");
	botCamera.farClip = 15000;
    renderer.numViewports = 1;
    
  	Viewport@ mainVP = Viewport(scene_, camera);
	
	
	renderer.viewports[0] = mainVP;
    
    //Viewport@ miniViewport = Viewport(scene_, botCameraNode.GetComponent("Camera"),
    //    IntRect(graphics.width * 2 / 3, 32, graphics.width - 32, graphics.height / 3));
    //renderer.viewports[1] = miniViewport;
    
    
    
    // Create a renderable texture (1024x768, RGB format), enable bilinear filtering on it
    renderTexture = Texture2D();
    renderTexture.SetSize(320, 240, GetRGBFormat(), TEXTURE_RENDERTARGET);
    renderTexture.filterMode = FILTER_NEAREST;
    


    // Get the texture's RenderSurface object (exists when the texture has been created in rendertarget mode)
    // and define the viewport for rendering the second scene, similarly as how backbuffer viewports are defined
    // to the Renderer subsystem. By default the texture viewport will be updated when the texture is visible
    // in the main view
    surface = renderTexture.renderSurface;
    rttViewport = Viewport(scene_, botCameraNode.GetComponent("Camera"));
    //rttViewport.rect = IntRect(0,200,320,201);
    
    surface.numViewports = 2; 
    surface.viewports[0] = rttViewport;
    surface.updateMode = SURFACE_UPDATEALWAYS;
    
    Sprite@ screen = Sprite();
	screen.texture = renderTexture;
	screen.size = botcamRes * 2;
	screen.hotSpot = IntVector2(botcamRes.x * 2, 0);
	screen.verticalAlignment = VA_TOP;
	screen.horizontalAlignment = HA_RIGHT;
	ui.root.AddChild(screen);
	

	Node@ dummyNode = scene_.CreateChild("Camera");
	Camera@ dummyCam = dummyNode.CreateComponent("Camera");
	dummyCam.farClip=0.5;
	dummyNode.position = Vector3(0,-10000,0);
	dummyVP = Viewport(scene_, dummyCam);
	surface.viewports[1] = dummyVP;
	dummyVP.rect = IntRect(0,0,0,0);
	
	renderer.textureFilterMode = FILTER_ANISOTROPIC;
	renderer.textureAnisotropy = 16;
	
	UIElement@ LegendNode = ui.root.CreateChild("UIElement");
	LegendNode.SetPosition(-630 , 490);
	LegendNode.horizontalAlignment = HA_RIGHT;
	LegendNode.verticalAlignment = VA_TOP;
	
	Text@ uiSpeedL = LegendNode.CreateChild("Text");
	uiSpeedL.text = "Speed:";
	uiSpeedL.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 25);
	uiSpeedL.SetPosition(0 , 0);
	uiSpeedL.horizontalAlignment = HA_LEFT;
	uiSpeedL.verticalAlignment = VA_TOP;
	uiSpeedL.color = Color(1,1,0.5);
	
	uiSpeed = uiSpeedL.CreateChild("Text");
	uiSpeed.text = "50";
	uiSpeed.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 25);
	uiSpeed.SetPosition(130 , 0);
	uiSpeed.horizontalAlignment = HA_LEFT;
	uiSpeed.verticalAlignment = VA_TOP;
	
	
	Text@ uiBearingL = LegendNode.CreateChild("Text");
	uiBearingL.text = "Bearing:";
	uiBearingL.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 25);
	uiBearingL.SetPosition(250 , 0);
	uiBearingL.horizontalAlignment = HA_LEFT;
	uiBearingL.verticalAlignment = VA_TOP;
	uiBearingL.color = Color(1,1,0.5);
	
	uiBearing = uiBearingL.CreateChild("Text");
	uiBearing.text = "90";
	uiBearing.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 25);
	uiBearing.SetPosition(150 , 0);
	uiBearing.horizontalAlignment = HA_LEFT;
	uiBearing.verticalAlignment = VA_TOP;
	
	Text@ uiTimeL = LegendNode.CreateChild("Text");
	uiTimeL.text = "Scan mode:";
	uiTimeL.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 25);
	uiTimeL.SetPosition(0 , 50);
	uiTimeL.horizontalAlignment = HA_LEFT;
	uiTimeL.verticalAlignment = VA_TOP;
	uiTimeL.color = Color(1,1,0.5);
	
	uiTime = uiTimeL.CreateChild("Text");
	uiTime.text = "Progressive";
	uiTime.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 25);
	uiTime.SetPosition(190 , 0);
	uiTime.horizontalAlignment = HA_LEFT;
	uiTime.verticalAlignment = VA_TOP;
	
	Text@ helpText = LegendNode.CreateChild("Text");
	helpText.text =
					"[Arrows] or [W],[A],[S],[D] - drive rover around.\n \n"
					"[1],[2],[3],[4] - switch scanning speed.\n\n"
					"[F] - headlight On/Off.\n\n"
					"[ESC] - exit.\n\n"
					"\n"
					"\n"
					"\n"
					"\n"
					"\n"
					"\n"
					"\n"
					"\n"
					"\n"
					"\n";

	helpText.SetFont(cache.GetResource("Font", "Fonts/Anonymous Pro.ttf"), 15);
	helpText.horizontalAlignment = HA_LEFT;
	helpText.verticalAlignment = VA_TOP;
	helpText.SetPosition(0,100);
	helpText.color = Color(1,1,0.5);;
	
	Texture2D@ splashTex = cache.GetResource("Texture2D", "Textures/splash.png");
	
	bg = ui.root.CreateChild("Window");
	bg.color = BLACK;
	bg.SetSize(graphics.width,graphics.height);
	
	splash = Sprite();
	splash.texture = splashTex;
	splash.size = IntVector2(1024,768);
	splash.hotSpot = IntVector2(512, 400);
	splash.verticalAlignment = VA_CENTER;
	splash.horizontalAlignment = HA_CENTER;
	ui.root.AddChild(splash);
	
	Sound@ sound = cache.GetResource("Sound", "Sounds/start.wav");
	SoundSource@ soundSource = scene_.CreateComponent("SoundSource");
	soundSource.Play(sound);
	soundSource.gain = 0.9f;
	soundSource.autoRemove = true;
	
	
}


void CreateConsoleAndDebugHud()
{
    // Get default style
    XMLFile@ xmlFile = cache.GetResource("XMLFile", "UI/DefaultStyle.xml");
    if (xmlFile is null)
        return;

    // Create console
    Console@ console = engine.CreateConsole();
    console.defaultStyle = xmlFile;
    console.background.opacity = 0.8f;

    // Create debug HUD
    DebugHud@ debugHud = engine.CreateDebugHud();
    debugHud.defaultStyle = xmlFile;
}

void HandleKeyDown(StringHash eventType, VariantMap& eventData)
{
    int key = eventData["Key"].GetInt();

    // Close console (if open) or exit when ESC is pressed
    if (key == KEY_ESC)
    {
        if (!console.visible)
            engine.Exit();
        else
            console.visible = false;
    }

    // Toggle console with F1
    else if (key == KEY_F1)
        console.Toggle();

    // Toggle debug HUD with F2
    else if (key == KEY_F2)
        debugHud.ToggleAll();

    // Take screenshot
    else if (key == KEY_F12)
        {
            Image@ screenshot = Image();
            graphics.TakeScreenShot(screenshot);
            // Here we save in the Data folder with date and time appended
            screenshot.SavePNG(fileSystem.programDir + "Data/Screenshot_" +
                time.timeStamp.Replaced(':', '_').Replaced('.', '_').Replaced(' ', '_') + ".png");
           
        }
     else if (key == KEY_1)
     {
         scanSpeed = 1;
		 uiTime.text = "Progressive";
     }
       else if (key == KEY_2)
     {
         scanSpeed = 2;
		 uiTime.text = "1/2";
        
     }
       else if (key == KEY_3)
     {
         scanSpeed = 3;
		 uiTime.text = "1/3";
       
     }
       else if (key == KEY_4)
     {
         scanSpeed = 4;
		 uiTime.text = "1/4";
         
     }

}


void HandleUpdate(StringHash eventType, VariantMap& eventData)
{

	
    rttViewport.rect = IntRect(0,scanLine,320,scanLine+1);
    //log.Info(scanLine*(90.0/240.0));
    botCameraNode.rotation = Quaternion(-1 * botcamFov/2 + scanLine*(botcamFov/botcamRes.y),0,0);
	
	if (scanSpeed>1)
	{
		dummyVP.rect = IntRect(0,scanLine-(scanSpeed-1),320,scanLine);
	} else {
		dummyVP.rect = IntRect(0,0,1,1);
	}
	
	
    scanLine+=scanSpeed;
        
    if (scanSpeed>1)
    {
        //renderTexture.SetData(0,0,scanLine-scanSpeed,320,scanSpeed-1,);
    }
    if (scanLine>botcamRes.y){
		scanLine=0;
		Sound@ sound = cache.GetResource("Sound", "Sounds/screen.wav");
						SoundSource@ soundSource = botCameraNode.CreateComponent("SoundSource");
						soundSource.Play(sound);
						soundSource.gain = 0.3f;
						soundSource.frequency = 44100;
						soundSource.autoRemove = true;
	}
	
	if (time.elapsedTime > 2 and time.elapsedTime< 10)
	{
		bg.opacity -= time.timeStep * 0.3;
		if (time.elapsedTime > 5)
			splash.opacity -= time.timeStep * 0.3;
		if (time.elapsedTime > 9)
		{
			bg.visible = false;
			splash.visible = false;
		}
    } 
}