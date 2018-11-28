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

    String getName() {
        return myName;
    }

    void fromJSON() {
        //TODO
        //Do I actually need this?
    }

    JSONObject toJSON() {
        JSONObject retObj = new JSONObject();
        JSONArray retVotes = new JSONArray();

        int i = 0;
        for (Votes votes : myVotes)
            retVotes.setJSONArray(i++, votes.toJSON());

        retObj.setString("name", myName);
        retObj.setString("role", myRole.name());
        retObj.setJSONArray("votes", retVotes);

        return retObj;
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