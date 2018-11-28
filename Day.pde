class Day {
    ActionButton voteButton;
    int dayNum = 1;

    Day() {
        voteButton = new ActionButton(Action.END_VOTING, new PVector(width / 2, height / 2));
    }

    // NEWS, ANGELIC, AZREAL, VOTING, LYNCHING, NIGHT
    void draw() {
        switch (myGame.getPlayState()) {
            case NEWS:
                break;
            case NOMINATION:
                break;
            case INVEST:
                break;
            case VOTING:
                break;
            case LYNCHING:
                break;
            case NIGHT:
                break;
        }
        voteButton.draw();
    }

    /*
    * Gets all the votes from the server, totals them and determines whether the
    * player will be lynched
    */
    void stopVoting() {
        ArrayList<String> response = myGame.sendRequest("admin/votes");
        myGame.updatePlayState(PlayState.LYNCHING);
    }

    /*
    * Selects an Angel at random to be the Angel who decides on which 
    * player to kill that night
    */
    void selectKiller() {
        ArrayList<String> playerJSONs = myGame.sendRequest("players/states");
        ArrayList<Player> allAngels;

        for (String json : playerJSONs) {
            Player foo = new Player();
            if (foo.isAngel())
                allAngels.add(foo.fromJSON(json));
        }

        //This is the only line where the selection is done, the rest just filter the players
        Player killer = allAngels.get((int) random(allAngels.size));
        myGame.postData("admin/killer", killer.toJSON());
    }

    void mouseClick() {
        voteButton.mouseClicked();
    }

}