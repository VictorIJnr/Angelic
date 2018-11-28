class Menu {
    ActionButton startGame;

    Menu() {
        //TODO
        //Make a button to start the game
        startGame = new ActionButton(Action.START_GAME, new PVector(width / 2, height / 2));
    }

    void draw() {
        startGame.draw();
    }

    void mouseClick() {
        startGame.mouseClicked();
    }
}