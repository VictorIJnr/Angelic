/*
This is the only final variable I declare in standard CamelCase.
All others will be fully capitals.
I just wanted this to remain as an exception.
Plus, it's the most critical for rendering at different screen resolutions. 
*/ 
static final boolean isSpectre = true;

static final int TEXT_SIZE = (isSpectre) ? 42 : 12;
static final int TITLE_TEXT_SIZE = (isSpectre) ? 56 : 20;

Game myGame;
PFont myFont;
PImage myBG;

void setup() {
    //Setting up the game screen to be rendered appropriately
    // surface.setResizable(true);
    focused = true;
    // if (!isSpectre) surface.setSize(1920, 1080);
    size(1920, 1080, P3D);
    
    fill(51);
    //noCursor();
    // myFont = createFont("Aldo.ttf", 64);
    // textFont(myFont);
    textSize(TEXT_SIZE);
    textAlign(CENTER);
    imageMode(CENTER);
    
    myGame = new Game();

    myBG = loadImage("backy.png");
}

void draw() {
    background(myBG);
    // background(#FFEAA7);
    
    beginCamera();
    myGame.draw();
    endCamera();
}

void mouseClicked() {
    myGame.mouseClick();
}
