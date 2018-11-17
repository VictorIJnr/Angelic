//NAMING and LOBBY are exclusive to the client-side aspect of the game
//LOBBY indicates waiting for more players to join the game
enum GameState {
    MENU, HOSTING, NAMING, LOBBY, ROLES, PLAYING, RESULTS;
}

enum PlayState {
    DAY, NEWS, ANGELIC, AZREAL, VOTING, LYNCHING, NIGHT
}

class Game {
    static final float ROLE_RATIO = 0.4;

    GameState myState = GameState.HOSTING;
    PlayState myPlayState = PlayState.DAY;

    Menu myMenu = new Menu();
    Chat myChat = new Chat();
    Host hostGame = new Host();
    ArrayList<Player> allPlayers = new ArrayList<Player>();
    ArrayList<String> playerNames = new ArrayList<String>();

    Game() {
        // hostGame.startServer();
    }

    void update() {
        pingPlayers();
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
            case CODED:
                switch(keyCode) {
                    case ENTER:  
                    case RETURN:
                        updateGameState(GameState.ROLES);
                        break;
                    default:
                        break;
                }
                break;
            case 'i':    
            case 'I':
                
                break;
            default:
                break;
        }
    }

    void keyRelease() {

    }

    void mouseClick() {
        myMenu.mouseClick();
    }

    /*
        Updates the current state of game.
    */
    void updateGameState(GameState newState) {
        JSONObject reqBody = new JSONObject();
        reqBody.setString("state", newState.name());
        hostGame.postData("admin/state", reqBody);
    }
    
    /*
        Update the current state of play.
        Only utilised while the GameState is PLAYING.
    */
    void updatePlayState() {
        
    }

    /*
        Closes the lobby from any further join requests from players.
        Subsequently allocates roles to each of the connected players.
    */
    void startGame() {
        myState = GameState.ROLES;
        hostGame.sendRequest("admin/start");
    }

    /*
        Assigns roles to all of the connected players.
    */
    void allocateRoles() {
        JSONArray players = new JSONArray();
        JSONObject postData = new JSONObject();

        int numAngels = (int) (allPlayers.size() * ROLE_RATIO);
        ArrayList<Player> roleless = new ArrayList<Player>();
        roleless.addAll(allPlayers);

        //Assigning all the angels
        for (int i = 0; i < numAngels; i++) {
            int randomPlayer = (int) random(roleless.size());
            roleless.get(randomPlayer).setRole(Roles.ANGEL);
            roleless.remove(randomPlayer);
        }

        //Leaving each available player as a human
        for (Player mortal : roleless) mortal.setRole(Roles.HUMAN);

        //Formatting the Player objects into an equivalent JSON array of players
        //which is to be sent to the server
        int i = 0;
        for (Player player : allPlayers) players.setJSONObject(i++, player.toJSON());
        postData.setJSONArray("player_data", players);
        hostGame.postData("admin/players", postData);
    }

    /*
        Pings the server to retrieve all the currently connected players.
    */
    void pingPlayers() {
        ArrayList<String> newPlayers = new ArrayList<String>();
        newPlayers = hostGame.sendRequest("admin/players");
        newPlayers.removeAll(playerNames);

        for (String player : newPlayers) 
            if (!allPlayers) allPlayers.add(new Player(player));
        
        playerNames.addAll(newPlayers);
    }
}
