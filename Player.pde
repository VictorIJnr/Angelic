enum Roles {
    ANGEL, HUMAN
}

class Player {
    Role myRole;
    String myName;
    ArrayList<Votes> myVotes;

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

    JSONObject toJSON() {
        JSONObject retObj = new JSONObject();
        JSONArray retVotes = new JSONArray();

        int i = 0;
        for (Votes votes : myVotes) {
            //Each set of votes, indicate one day of voting.
            JSONObject voteDay = new JSONObject();
            for (Vote vote : votes) {
                voteDay.setString()
            }
        }

        retObj.setString("name", myName);
        retObj.setString("role", myRole.name());

        return retObj;
    }
}