let myGame;
let img;

function setup() {
    fill("#FFEAAF");
    textSize(24);
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