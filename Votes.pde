enum Verdict {
    GUILTY, INNOCENT, NOMINATION 
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
    String decisionString;

    Vote() {}

    Vote(Player voter, Player against, Verdict decision) {
        this.voter = voter;
        this.against = against;
        this.decision = decision;
    }

    void change(Player against, Verdict decision) {
        this.against = against;
        this.decision = decision;
    }

    boolean isGuilty() {
        return this.decision == Verdict.GUILTY;
    }

    boolean isNomination() {
        return this.decision == Verdict.NOMINATION;
    }

    Player getDefendant() {
        return against;
    }

    JSONObject toJSON() {
        JSONObject retJSON = new JSONObject();
        retJSON.setString("voter", voter.getName());
        retJSON.setString("against", against.getName());
        retJSON.setString("decision", decision.name());
        return retJSON;
    }

    Vote fromJSON(String source) {
        Vote retVote = new Vote();
        JSONObject voteJSON = parseJSONObject(source);

        retVote.voter = myGame.getPlayerMap().get(voteJSON.getString("voter"));
        retVote.against = myGame.getPlayerMap().get(voteJSON.getString("against"));
        retVote.decisionString = voteJSON.getString("decision");
        retVote.decision = Verdict.valueOf(retVote.decisionString);

        return retVote;
    }

}