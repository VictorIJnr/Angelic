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

    void mouseClick() {
        voteButton.mouseClicked();
    }

}