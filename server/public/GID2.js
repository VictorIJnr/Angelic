let myGame;
let img;
let TEXT_SIZE = 24;

function setup() {
    fill("#FFEAAF");
    textSize(TEXT_SIZE);
    createCanvas(1440, 2860);
    textAlign(CENTER);

    myGame = new Game();
    img = loadImage("assets/backy.png");
}

function draw() {
    background(img);

    rectMode(CORNER);
    myGame.draw();
}

function mouseClicked() {
    myGame.mouseClick();
}