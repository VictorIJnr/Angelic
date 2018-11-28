enum Roles {
    ANGEL, HUMAN
}

class Player {
    Roles myRole;
    String myName;
    ArrayList<Votes> myVotes;
    boolean isAlive = true;

    //Only here for the listify method
    Player() {}

    Player(String myName) {
        this.myName = myName;
        myVotes = new ArrayList<Votes>();
    }

    void setRole(Roles role) {
        myRole = role;
    }

    void setLiving(boolean isAlive) {
        this.isAlive = isAlive;
    }

    String getName() {
        return myName;
    }

    boolean isAngel() {
        return myRole == Roles.ANGEL;
    }

    /*
    * Builds a player object from their equivalent JSON
    * Omitting the votes as they may not be required
    */
    Player fromJSON(JSONObject source) {
        Player retPlayer = new Player(source.getString("name"));

        retPlayer.setRole((source.getString("role").equals("ANGEL")) 
            ? Roles.ANGEL : Roles.HUMAN);
        retPlayer.setLiving(source.getBoolean("isAlive"));

        return retPlayer;
    }

    Player fromJSON(String source) {
        return fromJSON(parseJSONObject(source));
    }

    JSONObject toJSON() {
        JSONObject retObj = new JSONObject();
        JSONArray retVotes = new JSONArray();

        int i = 0;
        for (Votes votes : myVotes)
            retVotes.setJSONArray(i++, votes.toJSON());

        retObj.setString("name", myName);
        retObj.setBoolean("isAlive", isAlive);
        retObj.setJSONArray("votes", retVotes);
        retObj.setString("role", myRole.name());

        return retObj;
    }

    void kill() {
        isAlive = false;
    }

    /*
    * Puts all of the specified players into a single JSON Array to be stored server-side
    * I want to make this static but Processing won't let me
    */
    JSONObject listify(HashMap<String, Player> allPlayers) {
        JSONObject retObj = new JSONObject();
        JSONArray playerArray = new JSONArray();

        for (Player player : allPlayers.values())
            playerArray.append(player.toJSON());

        retObj.setJSONArray("players", playerArray);
        return retObj;
    }
}
