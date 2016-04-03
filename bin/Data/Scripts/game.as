Scene@ scene_;
Node@ cameraNode;
float yaw = 0.0f; // Camera yaw angle
float pitch = 0.0f; // Camera pitch angle

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

    Node@ botCameraNode = scene_.CreateChild("botCameraNode");
    botCameraNode.position = Vector3(0,2,0);
    Camera@ botCamera = botCameraNode.CreateComponent("Camera");
    
  
    renderer.numViewports = 2;
    
  	Viewport@ mainVP = Viewport(scene_, camera);
	renderer.viewports[0] = mainVP;
    
    Viewport@ miniViewport = Viewport(scene_, botCameraNode.GetComponent("Camera"),
        IntRect(graphics.width * 2 / 3, 32, graphics.width - 32, graphics.height / 3));
    renderer.viewports[1] = miniViewport;
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
        
}