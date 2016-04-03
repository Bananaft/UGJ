Scene@ scene_;
Node@ cameraNode;
Node@ botCameraNode;
Viewport@ rttViewport;
float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle
int scanLine = 0;

void Start()
{
    //log.level = 0;
    scene_ = Scene();
	CreateConsoleAndDebugHud();

	SubscribeToEvent("KeyDown", "HandleKeyDown");
    SubscribeToEvent("Update", "HandleUpdate");
    
	scene_.LoadXML(cache.GetFile("Scenes/test_scene.xml"));

	cameraNode = Node();
    Camera@ camera = cameraNode.CreateComponent("Camera");
    camera.orthographic=true;
    
    cameraNode.rotation = Quaternion( 22.5 , 45.0 , 0.0 );
    cameraNode.position = Vector3(-10,5,-10);

    botCameraNode = scene_.CreateChild("botCameraNode");
    botCameraNode.position = Vector3(0,2,0);
    Camera@ botCamera = botCameraNode.CreateComponent("Camera");
    botCamera.fov = 0.375;
    
  
    //renderer.numViewports = 2;
    
  	Viewport@ mainVP = Viewport(scene_, camera);
	renderer.viewports[0] = mainVP;
    
    //Viewport@ miniViewport = Viewport(scene_, botCameraNode.GetComponent("Camera"),
    //    IntRect(graphics.width * 2 / 3, 32, graphics.width - 32, graphics.height / 3));
    //renderer.viewports[1] = miniViewport;
    
    
    


    // Create a renderable texture (1024x768, RGB format), enable bilinear filtering on it
    Texture2D@ renderTexture = Texture2D();
    renderTexture.SetSize(320, 240, GetRGBFormat(), TEXTURE_RENDERTARGET);
    renderTexture.filterMode = FILTER_BILINEAR;
    


    // Get the texture's RenderSurface object (exists when the texture has been created in rendertarget mode)
    // and define the viewport for rendering the second scene, similarly as how backbuffer viewports are defined
    // to the Renderer subsystem. By default the texture viewport will be updated when the texture is visible
    // in the main view
    RenderSurface@ surface = renderTexture.renderSurface;
    rttViewport = Viewport(scene_, botCameraNode.GetComponent("Camera"));
    rttViewport.rect = IntRect(0,200,320,201);
    
    surface.viewports[0] = rttViewport;
    surface.updateMode = SURFACE_UPDATEALWAYS;
    
    Sprite@ screen = Sprite();
	screen.texture = renderTexture;
	screen.size = IntVector2(640,480);
	screen.hotSpot = IntVector2(640, 0);
	screen.verticalAlignment = VA_TOP;
	screen.horizontalAlignment = HA_RIGHT;
	ui.root.AddChild(screen);
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

}


void HandleUpdate(StringHash eventType, VariantMap& eventData)
{
    if (input.keyDown[KEY_UP]) botCameraNode.position += Vector3(0,0,0.01);
    if (input.keyDown[KEY_DOWN]) botCameraNode.position += Vector3(0,0,-0.01);
    if (input.keyDown[KEY_LEFT]) botCameraNode.Rotate( Quaternion(-3,0,0) ); 
    if (input.keyDown[KEY_RIGHT]) botCameraNode.Rotate( Quaternion(3,0,0) );
    
    rttViewport.rect = IntRect(0,scanLine,320,scanLine+1);
    //log.Info(scanLine*(90.0/240.0));
    botCameraNode.rotation = Quaternion(-45 + scanLine*(90.0/240.0),0,0);
    scanLine++;
    if (scanLine>240) scanLine=0;
}