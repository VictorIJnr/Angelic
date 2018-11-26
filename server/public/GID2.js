let myGame;

function setup() {
    fill(0);
    textSize(24);
    createCanvas(screen.width / 2, screen.height / 2);
    textAlign(CENTER);

    myGame = new Game();
}

function draw() {
    background("#f7f1e3");

    rectMode(CORNER);
    myGame.draw();
}

function mouseClicked() {
    myGame.mouseClick();
}