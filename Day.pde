class Day {
    ActionButton voteButton;
    int dayNum = 1;
    int timer;

    Day() {
        voteButton = new ActionButton(Action.END_VOTING, new PVector(width / 2, height / 2));
    }

    // NEWS, ANGELIC, AZREAL, VOTING, LYNCHING, NIGHT
    void draw() {
        switch (myGame.getPlayState()) {
            case NEWS:
                myGame.drawText("Did someone die? IDK.");

                //Give enough time to display the news
                if (millis() - timer > 10e3) 
                    changePlayState(PlayState.NOMINATION);
                break;
            case NOMINATION:
                myGame.drawText("Nominate a player to be executed.");

                //Allowing 120 seconds for a nomination phase
                if (millis() - timer > 120e3) 
                    changePlayState(PlayState.VOTING);
                break;
            case INVEST:
                break;
            case VOTING:
                //TODO
                //Enter the player's name 
                //Check whether to transition to the Lynch state or to the night based on votes
                myGame.drawText("Vote to decide on the fate of player to be executed.");

                //Allowing 30 seconds to decide on the player to execute
                if (millis() - timer > 30e3)
                    changePlayState(PlayState.LYNCHING);
                break;
            case LYNCHING:
                //TODO
                //Get the name of the player executed
                myGame.drawText("Player Name has been executed!");

                if (millis() - timer > 15e3)
                    changePlayState(PlayState.NIGHT);
                break;
            case NIGHT:
                myGame.drawText("It's the night time, everyone goes to sleep, apart from one angel...");

                //Give the angel(s) enough time to decide who to kill
                if (millis() - timer > 25e3)
                    changePlayState(PlayState.NEWS);
                break;
        }
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
        ArrayList<Player> allAngels = new ArrayList<Player>();

        for (String json : playerJSONs) {
            Player foo = new Player();
            if (foo.isAngel())
                allAngels.add(foo.fromJSON(json));
        }

        //This is the only line where the selection is done, the rest just filter the players
        Player killer = allAngels.get((int) random(allAngels.size()));
        myGame.postData("admin/killer", killer.toJSON());
    }

    void mouseClick() {
        voteButton.mouseClicked();
    }

    void startTimer() {
        timer = millis();
    }

    void changePlayState(PlayState newPlayState) {
        myGame.updatePlayState(newPlayState);
        timer = millis();
    }

}
