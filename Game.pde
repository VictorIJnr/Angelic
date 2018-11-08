enum GameState {
    MENU, HOSTING, ROLES, PLAYING, RESULTS;
}

enum PlayState {
    DAY, NEWS, ANGELIC, AZREAL, VOTING, LYNCHING, NIGHT
}

class Game {

    Menu myMenu = new Menu();
    Chat myChat = new Chat();
    Host hostGame = new Host();

    Game() {
        // hostGame.startServer();
    }

    void update() {

    }

    void draw() {
        // myChat.draw();
        myMenu.draw();
        hostGame.ping();
    }

    void keyPress() {

    }

    void keyRelease() {

    }

}