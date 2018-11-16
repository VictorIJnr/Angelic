/*
This is the only final variable I declare in standard CamelCase.
All others will be fully capitals.
I just wanted this to remain as an exception.
Plus, it's the most critical for rendering at different screen resolutions. 
*/ 
static final boolean isSpectre = true;

static final int TEXT_SIZE = (isSpectre) ? 64 : 24;

Game myGame;
PFont myFont;

void setup() {
    //Setting up the game screen to be rendered appropriately
    fullScreen(P3D);
    surface.setResizable(true);
    focused = true;
    if (!isSpectre) surface.setSize(1920, 1080);
    
    fill(51);
    //noCursor();
    // myFont = createFont("Aldo.ttf", 64);
    // textFont(myFont);
    textSize(TEXT_SIZE);
    textAlign(CENTER);
    imageMode(CENTER);
    
    myGame = new Game();
}

void draw() {
    background(#f7f1e3);
    // background(#FFEAA7);
    
    beginCamera();
    myGame.draw();
    endCamera();
}


void keyPressed() {
    myGame.keyPress();
}

void keyReleased() {
    myGame.keyRelease();
}

void mouseClicked() {
    myGame.mouseClick();
}