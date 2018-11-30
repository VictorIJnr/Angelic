class Day {
    int dayNum = 1;
    
    int timer;
    int subTimer = 0;
    int numGuilty = 0, numInno = 0;

    boolean nomFlag = false;
    boolean voteFlag = false;
    boolean resetFlag = false;
    
    //The player who has been convicted of murder
    Player nomPlayer;

    //The player to be executed at the end of a day.
    Player exePlayer;
    
    //The angel to murder another player at night.
    Player killer;

    void draw() {
        switch (myGame.getPlayState()) {
            case NEWS:
                myGame.drawText("Did someone die? IDK.");
                if (!resetFlag) {
                    updateGameDay();
                    nomPlayer = null;
                    if (killer != null) resetKiller();
                    
                    //Ensuring the new killer is set before night, 
                    //and they know who they are before then
                    selectKiller();
                }

                //Give enough time to display the news
                if (millis() - timer > 1e3) 
                // if (millis() - timer > 10e3) 
                    changePlayState(PlayState.NOMINATION);
                break;
            case NOMINATION:
                if (!nomFlag) myGame.drawText("Nominate a player to be executed.");

                //Allowing 120 seconds for a nomination phase
                if (millis() - timer > 1e3) {
                // if (millis() - timer > 120e3) { 
                    closeNominations();
                    nominationResults();
                }
                break;
            case INVEST:
                //TODO add this
                break;
            case VOTING:
                if (!voteFlag) myGame.drawText("Vote to decide on the fate of player to be executed.");

                //Allowing 30 seconds to decide on the player to execute
                if (millis() - timer > 3e3) {
                // if (millis() - timer > 30e3) {
                    //Ensuring that the votes are not retrieved an excess amount of times
                    stopVoting();
                    votingResults();
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
                    resetFlag = false;
                    changePlayState(PlayState.NEWS);
                }
                break;
        }
    }

    /*
    * Helper method to retrieve all of the votes submitted by players
    */
    Votes retrieveVotes() {
        //Retrieve all of the votes from players.
        ArrayList<String> votes = myGame.sendRequest("admin/votes");
        Votes retVotes = new Votes();

        //If the response yielded votes, parse and return them
        if (hasVotes(votes))
            for (String voteJSON : votes)
                retVotes.add(new Vote().fromJSON(voteJSON));

        return retVotes;
    }

    HashMap<Player, Integer> getNominations() {
        Votes allNoms = retrieveVotes();
        HashMap<Player, Integer> nomCount = new HashMap<Player, Integer>();

        //If the response yielded votes, determine the most nominated player
        //If multiple are equally nominated, randomly select one
        if (!allNoms.isEmpty()) {
            //Counting nominations for all players.
            for (Vote nom : allNoms) {
                if (nom.isNomination()) {
                    Player current = nom.getDefendant();
                    int total = (nomCount.containsKey(current)) 
                        ? nomCount.get(current) : 0;

                    nomCount.put(current, ++total);
                }
            }
        }

        return nomCount;
    }

    void closeNominations() {
        if (!nomFlag) {
            HashMap<Player, Integer> nomCount = getNominations();
            
            if (!nomCount.isEmpty()) {
                int mostNoms = -1;
                for (Map.Entry<Player, Integer> entry : nomCount.entrySet())
                    if (entry.getValue() > mostNoms) nomPlayer = entry.getKey();
            }

            subTimer = millis();
            nomFlag = true;
        }
    }

    void nominationResults() {
        boolean nominated = nomPlayer != null;
        HashMap<Player, Integer> allNoms = getNominations();
        if (!nominated)
            myGame.drawText(String.format("No one will be executed today as "
                + "nobody was convicted."));
        else
            myGame.drawText(String.format("%s has been convicted.\nThere were %d "
                + "convictions against them.", nomPlayer.getName(), allNoms.get(nomPlayer)));
        
        //The results will be displayed for 10 seconds before switching
        //to the next state of play
        if (millis() - subTimer > 2e3) {
        // if (millis() - subTimer > 10e3) {
            nomFlag = false;

            if (nominated) 
                changePlayState(PlayState.VOTING);
            else
                changePlayState(PlayState.NIGHT);
        }
    }

    /*
    * Gets all the votes from the server, totals them and determines whether the
    * player will be lynched
    */
    void stopVoting() {
        if (!voteFlag) {
            Votes allVotes = retrieveVotes();

            //If the response yielded votes, determine whether the nominated player is innocent
            if (!allVotes.isEmpty()) {
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
    }

    /*
    * Displaying the results of the voting on the host screen
    */
    void votingResults() {
        // myGame.drawText(String.format("%s will not be executed today as "
        //         + "nobody voted.", exePlayer.getName()));
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
        if (millis() - subTimer > 2e3) {
        // if (millis() - subTimer > 10e3) {
            voteFlag = false;

            if (numGuilty > numInno) 
                changePlayState(PlayState.LYNCHING);
            else
                changePlayState(PlayState.NIGHT);
        }
    }

    /*
    * Selects an Angel at random to be the Angel who decides on which 
    * player to kill that night
    */
    void selectKiller() {
        ArrayList<String> playerJSONs = myGame.sendRequest("players/states");
        ArrayList<Player> allAngels = new ArrayList<Player>();

        JSONArray playerArray = parseJSONArray(playerJSONs.get(0));

        for (int i = 0; i < playerArray.size(); i++) {
            JSONObject json = playerArray.getJSONObject(i);

            Player foo = new Player().fromJSON(json);
            if (foo.isAngel())
                allAngels.add(foo);
        }

        //This is the only line where the selection is done, the rest just filter the players
        killer = allAngels.get((int) random(allAngels.size()));
        killer.setKiller(true);
        myGame.postData("admin/killer", killer.toJSON());
    }

    void resetKiller() {
        killer.setKiller(false);
        myGame.postData("admin/killer", killer.toJSON());
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

    /*
    * Updates the current day number stored on the server and locally
    */
    void updateGameDay() {
        JSONObject reqBody = new JSONObject();
        reqBody.setInt("day", dayNum);
        myGame.postData("admin/state", reqBody);

        dayNum++;
        resetFlag = true;
    }
}
