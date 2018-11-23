enum Roles {
    ANGEL, HUMAN
}

class Player {
    Roles myRole;
    String myName;
    ArrayList<Votes> myVotes;
    boolean isAlive = true;

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
}