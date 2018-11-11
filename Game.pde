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
    ArrayList<Player> allPlayers = new ArrayList<Player>();
    ArrayList<String> playerNames = new ArrayList<String>();

    Game() {
        // hostGame.startServer();
    }

    void update() {

    }

    void draw() {
        // myChat.draw();
        myMenu.draw();
        hostGame.ping();

        for (int i = 0; i < playerNames.size(); i++) {
            int yMod = TEXT_SIZE * 2 * i;
            text(playerNames.get(i), width / 4, height * 0.1 + yMod);
        } 
        
    }

    void keyPress() {
        switch (key) {
            case 'p':    
            case 'P':
                playerNames = hostGame.sendRequest("admin/players");
                break;
            case 'o':    
            case 'O':
                ArrayList<String> startMsg = new ArrayList<String>();
                startMsg = hostGame.sendRequest("admin/start");

                System.out.println("");
                for (String line : startMsg) {
                    fill(51);
                    System.out.println(line);
                }
                break;
            default:
                break;
        }
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