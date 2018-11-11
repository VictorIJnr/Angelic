enum Verdict {
    GUILTY, INNOCENT
}

/*
    Keeps a track of all of the votes made by a player in a given day.
*/
class Votes extends ArrayList<Vote> {

}

class Vote {
    Player voter;
    Player against;
    Verdict decision;

    Vote(Player voter, Player against, Verdict decision) {

    }

    void change(Player against, Verdict decision) {
        this.against = against;
        this.decision = decision;
    }

    JSONObject toJSON() {
        JSONObject retJSON = new JSONObject();
        retJSON.setString("voter", voter.getName());
    }
}