class Day {
    ActionButton voteButton;
    int dayNum = 1;
    
    int timer;
    int subTimer = 0;
    int numGuilty = 0, numInno = 0;

    boolean voteFlag = false;
    
    //The player to be executed at the end of a day.
    Player exePlayer;
    
    //The angel to murder another player at night.
    Player killer;

    Day() {
        voteButton = new ActionButton(Action.END_VOTING, new PVector(width / 2, height / 2));
    }

    // NEWS, ANGELIC, AZREAL, VOTING, LYNCHING, NIGHT
    void draw() {
        switch (myGame.getPlayState()) {
            case NEWS:
                myGame.drawText("Did someone die? IDK.");
                if (killer != null) resetKiller();

                //Give enough time to display the news
                if (millis() - timer > 1e3) 
                // if (millis() - timer > 10e3) 
                    changePlayState(PlayState.NOMINATION);
                break;
            case NOMINATION:
                myGame.drawText("Nominate a player to be executed.");

                //Allowing 120 seconds for a nomination phase
                if (millis() - timer > 1e3) 
                // if (millis() - timer > 120e3) 
                    changePlayState(PlayState.VOTING);
                break;
            case INVEST:
                //TODO add this
                break;
            case VOTING:
                //TODO
                //Enter the player's name 
                //Check whether to transition to the Lynch state or to the night based on votes
                if (!voteFlag) myGame.drawText("Vote to decide on the fate of player to be executed.");

                //Allowing 30 seconds to decide on the player to execute
                if (millis() - timer > 3e3) {
                // if (millis() - timer > 30e3) {
                    //Ensuring that the votes are not retrieved an excess amount of times
                    if (!voteFlag) {

                        //Retrieve all of the votes from players.
                        ArrayList<String> votes = myGame.sendRequest("admin/votes");
                        Votes allVotes = new Votes();

                        if (hasVotes(votes)) {
                            for (String voteJSON : votes)
                            allVotes.add(new Vote().fromJSON(voteJSON));
                        
                            //Counting all of the guilty and innocent votes.
                            for (Vote vote : allVotes) {
                                if (!vote.isNomination()) {
                                    if (vote.isGuilty()) numGuilty++;
                                    else numInno++;
                                }
                            }

                            exePlayer = allVotes.get(0).getDefendant();
                        }
                        else {
                            numGuilty = -1;
                        }
                        
                        subTimer = millis();
                        voteFlag = true;
                    }

                    //Displaying the results of the voting on the host screen
                    if (numGuilty == -1)
                        myGame.drawText(String.format("No one will be executed today as "
                            + "nobody voted."));
                    else if (numGuilty > numInno)
                        myGame.drawText(String.format("%s will be executed.\nThere were %d "
                            + "guilty votes and %d innocent votes.", exePlayer.getName(),
                            numGuilty, numInno));
                    else
                        myGame.drawText(String.format("%s has been pardoned.\nThere were %d "
                            + "innocent votes and %d guilty votes.", exePlayer.getName(),
                            numInno, numGuilty));

                    //The results will be displayed for 10 seconds before switching
                    //to the next state of play
                    if (millis() - subTimer > 10e3) {
                        //This is called here to ensure the murdering Angel is chosen before the nighttime  
                        selectKiller();
                        voteFlag = false;

                        if (numGuilty > numInno) 
                            changePlayState(PlayState.LYNCHING);
                        else
                            changePlayState(PlayState.NIGHT);
                    }
                }
                break;
            case LYNCHING:
                myGame.drawText(String.format("%s has been executed!", exePlayer.getName()));

                //TODO determine the end of the game and move into the RESULTS game state

                if (millis() - timer > 15e3) {
                    // exePlayer.kill();
                    myGame.killPlayer(exePlayer.getName());
                    changePlayState(PlayState.NIGHT);
                }
                break;
            case NIGHT:
                myGame.drawText("It's the night time, everyone goes to sleep, apart from one angel...");

                //Give the angel(s) enough time to decide who to kill
                if (millis() - timer > 25e3) {
                    // update the players for myGame such that the murdered player (if any) dies
                    changePlayState(PlayState.NEWS);
                }
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
            System.out.println(json);
            Player foo = new Player().fromJSON(json);
            if (foo.isAngel())
                allAngels.add(foo);
        }

        //This is the only line where the selection is done, the rest just filter the players
        killer = allAngels.get((int) random(allAngels.size()));
        killer.setKiller(true);

        ArrayList<String> res;
        res = myGame.postData("admin/kek", killer.toJSON());

        for (String line : res) {
            System.out.println(line);
        }
    }

    void resetKiller() {
        killer.setKiller(false);
        myGame.postData("admin/kek", killer.toJSON());
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

    boolean hasVotes(ArrayList<String> voteResponse) {
        //This is only found in the response when there are no votes for the day
        return !voteResponse.get(0).contains("NoSuchKey");
    }

}