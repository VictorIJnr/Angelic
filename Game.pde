//LOBBY indicates waiting for more players to join the game
enum GameState {
    MENU, HOSTING, NAMING, LOBBY, ROLES, PLAYING, RESULTS;
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

    /*
        Updates the current state of game.
    */
    void updateGameState() {
        
    }
    
    /*
        Update the current state of play.
        Only utilised while the GameState is PLAYING.
    */
    void updatePlayState() {
        
    }

}