import java.util.*;
import java.util.concurrent.*;

//NAMING and LOBBY are exclusive to the client-side aspect of the game
//LOBBY indicates waiting for more players to join the game
enum GameState {
    HOSTING, ROLES, PLAYING, RESULTS;
}

enum PlayState {
    NEWS, NOMINATION, INVEST, VOTING, LYNCHING, NIGHT
}

class Game {
    static final float ROLE_RATIO = 0.5; //Only for debugging
    // static final float ROLE_RATIO = 0.4;

    int timer;
    int pingTimer;

    GameState myState = GameState.HOSTING;
    PlayState myPlayState = PlayState.NIGHT;

    Host hostGame = new Host();
    Day myDay = new Day();
    HashMap<String, Player> allPlayers = new HashMap<String, Player>();
    ArrayList<String> playerNames = new ArrayList<String>();

    Game() {
        pingTimer = millis();
    }

    void update() {
        fill(51);
        textSize(TEXT_SIZE);
        ping();
    }
    
    void ping() {
        //TODO
        //Only ping players when setting up the game
        //Once it's set up, no more players can join

        //Ensuring the server is pinged approximately once a second
        if (millis() - pingTimer > 1000) {
            pingPlayers();
            hostGame.ping();
            pingTimer = millis();
        }
    }

    void draw() {
        //TODO
        //Add a textual description for each of the game states
        //So if it's night time, the screen will tell everyone to
        //be quiet and look at their phone until it says it's day time
        //Angel's perform their murder at this time
        //Hope people don't cheat
        update();
        drawPlayers();

        switch(myState) {
            case HOSTING:
                if (playerNames.isEmpty()) {
                    textSize(TITLE_TEXT_SIZE);
                    drawText(String.format("The game room is set up at \"%s\"\n\nJoin the game " 
                        + "by entering that URL onto your phone. When everyone's ready, press the "
                        + "button.", hostGame.getGameURL()));
                    textSize(TEXT_SIZE);
                }
                else {
                    rectMode(CENTER);
                    text(String.format("Room URL:\n%s", hostGame.getGameURL()), width * 0.75, height * 0.15,
                        width * 0.5, height * 0.25);
                    rectMode(CORNER);
                }

                hostGame.draw();
                break;
            case ROLES:
                //Allow players to see their roles 
                //Stay here for x seconds. Long enough for everyone to see their roles.
                //Then switch the game state once everyone is familiar with their roles
                drawText("Your roles have been assigned, you can find them on your device.");
               
               //Waiting for 5 seconds to pass before updating the states
                if (millis() - timer > 5000) {
                    updateStates(GameState.PLAYING, PlayState.NEWS);
                    myDay.startTimer();
                }
                break;
            case PLAYING:
                myDay.draw();
                break;
            case RESULTS:
                break;
        }
    }

    /*
        Draws the specified text in the center of the screen.
    */
    void drawText(String displayText) {
        rectMode(CENTER);
        fill(51);
        text(displayText, width / 2, height / 2, width * 0.75, height * 0.5); 
        rectMode(CORNER);
    }

    /*
        Writes the names of all the players who have joined the lobby
    */
    void drawPlayers() {
        if (myState == GameState.HOSTING) {
            for (int i = 0; i < playerNames.size(); i++) {
                int yMod = TEXT_SIZE * 2 * i;
                text(playerNames.get(i) + " joined the lobby.", width / 5, height * 0.1 + yMod);
            } 
        }
    }

    void keyPress() {
        switch (key) {
            case CODED: //Doesn't seem to work?
            default:
                switch(keyCode) {
                    case ENTER:  
                    case RETURN:
                        System.out.println("Enter clicked");
                        updateGameState(GameState.ROLES);
                        allocateRoles();
                        break;
                    case TAB:
                        System.out.println("Tab clicked");
                        updateGameState(GameState.ROLES);
                        allocateRoles();
                        break;
                    default:
                        break;
                }
                break;
        }
    }

    void keyRelease() {

    }

    void mouseClick() {
        if (myState == GameState.HOSTING) hostGame.mouseClick();
    }

    void updateStates(GameState newGameState, PlayState newPlayState) {
        myState = (newGameState != null) ? newGameState : myState;
        myPlayState = (newPlayState != null) ? newPlayState : myPlayState;

        JSONObject reqBody = new JSONObject();
        reqBody.setString("state", myState.name());
        reqBody.setString("playState", myPlayState.name());
        hostGame.postData("admin/state", reqBody);
    }

    /*
        Updates the current state of game.
    */
    void updateGameState(GameState newState) {
        updateStates(newState, null);
    }
    
    /*
        Update the current state of play.
        Only utilised while the GameState is PLAYING.
    */
    void updatePlayState(PlayState newState) {
        updateStates(null, newState);
    }

    /*
        Closes the lobby from any further join requests from players.
        Subsequently allocates roles to each of the connected players.
    */
    void startGame() {
        hostGame.sendRequest("admin/start");
        allocateRoles();

        hostGame.postData("admin/players/states", new Player().listify(allPlayers));
        updateGameState(GameState.ROLES);

        timer = millis();
    }

    /*
        Assigns roles to all of the connected players.
    */
    void allocateRoles() {
        JSONArray players = new JSONArray();
        JSONObject postData = new JSONObject();

        int numAngels = (int) (allPlayers.size() * ROLE_RATIO);
        ArrayList<Player> roleless = new ArrayList<Player>();
        roleless.addAll(allPlayers.values());

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
        for (Player player : allPlayers.values()) players.setJSONObject(i++, player.toJSON());
        postData.setJSONArray("player_data", players);
        hostGame.postData("admin/players", postData);
    }

    /*
        Pings the server to retrieve all the currently connected players.
    */
    void pingPlayers() {
        ArrayList<String> newPlayers = new ArrayList<String>();
        newPlayers = hostGame.sendRequest("players");
        
        Iterator<String> playerIter = playerNames.iterator();
        while(playerIter.hasNext()) {
            String removedPlayer = playerIter.next();
            if (!newPlayers.contains(removedPlayer)) {
                allPlayers.remove(removedPlayer);
                playerIter.remove();
            }
        }

        newPlayers.removeAll(playerNames);
        for (String player : newPlayers) allPlayers.put(player, new Player(player));
        
        playerNames.addAll(newPlayers);
    }

    /*
        "Proxy" to send a GET request to the server
        Just eliminating the need to have a getter for hostGame and later 
        perform the request from there
    */
    ArrayList<String> sendRequest(String endpoint) {
        return hostGame.sendRequest(endpoint);
    }

    /*
        Same idea as the sendRequest function, except for POST requests.
    */
    ArrayList<String> postData(String endpoint, JSONObject data) {
        return hostGame.postData(endpoint, data);
    }

    void setExePlayer() {

    }

    PlayState getPlayState() {
        return myPlayState;
    }

    Day getDay() {
        return myDay;
    }

    HashMap<String, Player> getPlayerMap() {
        return allPlayers;
    }

    void killPlayer(String playerName) {
        allPlayers.get(playerName).kill();
    }
}
