enum Verdict {
    GUILTY, INNOCENT
}

/*
    Keeps a track of all of the votes made by a player in a given day.
*/
class Votes extends ArrayList<Vote> {
    JSONArray toJSON() {
        JSONArray retVotes = new JSONArray();
        for (int i = 0; i < this.size(); i++)
            retVotes.setJSONObject(i, this.get(i).toJSON());
        return retVotes;
    }
}

class Vote {
    Player voter;
    Player against;
    Verdict decision;

    Vote(Player voter, Player against, Verdict decision) {
        this.voter = voter;
        this.against = against;
        this.decision = decision;
    }

    void change(Player against, Verdict decision) {
        this.against = against;
        this.decision = decision;
    }

    JSONObject toJSON() {
        JSONObject retJSON = new JSONObject();
        retJSON.setString("voter", voter.getName());
        retJSON.setString("against", against.getName());
        retJSON.setString("decision", decision.name());
        return retJSON;
    }
}