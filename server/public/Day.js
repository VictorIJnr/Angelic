class Day {
    constructor() {
        this.dayNo = 1;
        this.currPlayer = 0;

        this.guiltyBtn = new Button(width * 0.25, height * 0.875, 200, 65, "Guilty", () => {
            let gamePlayer = myGame.getPlayer();
            let myVote = {
                voter: gamePlayer.getName(),
                against: this.getPlayer(),
                decision: "GUILTY"
            };
            myGame.postRequest("vote/", myVote);
        });

        this.innoBtn = new Button(width * 0.75, height * 0.875, 200, 65, "Innocent", () => {
            let gamePlayer = myGame.getPlayer();
            let myVote = {
                voter: gamePlayer.getName(),
                against: this.getPlayer(),
                decision: "INNOCENT"
            };
            myGame.postRequest("vote/", myVote);
        });

        //Button to navigate to the next player in the game
        this.nextPlayer = new Button(width * 0.85, height / 2, 40, 40, ">", () => {
            let allPlayers = myGame.getAllAlivePlayers();
            let numPlayers = allPlayers.length;
            this.currPlayer = Math.abs((this.currPlayer + 1) % numPlayers);
        });
        
        //Button to navigate to the previous player in the game
        this.prevPlayer = new Button(width * 0.15, height / 2, 40, 40, "<", () => {
            let allPlayers = myGame.getAllAlivePlayers();
            let numPlayers = allPlayers.length;
            this.currPlayer = Math.abs((this.currPlayer - 1) % numPlayers);
        });

        this.nominate = new Button(width * 0.5, height * 0.875, 200, 65, "Nominate", () => {
            let gamePlayer = myGame.getPlayer();
            let nomination = {
                voter: gamePlayer.getName(),
                against: this.getPlayer(),
                decision: "NOMINATION"
            };
            myGame.postRequest("vote/", nomination);
        });

        this.pingedPlayers = false;
    }

    isDay() {
        //Don't need to check for an undefined as Day is only ever used
        //when gameData is defined
        let gameData = myGame.getGameData();
        let gameState = gameData.state;
        let currState = gameData.playState;
        return gameState == "PLAYING" && currState != "NIGHT";
    }
    
    update() {
        let gameData = myGame.getGameData();
        if (gameData.playState == "NEWS" && !this.pingedPlayers) {
            this.getPlayerStates();
            this.pingedPlayers = true;
        }
        else if (gameData.playState == "NIGHT" && this.pingedPlayers)
            this.pingedPlayers = false;
    }

    drawButtons() {
        let playState = myGame.getGameData().playState;

        switch (playState) {
            case "NOMINATION":
                this.nominate.draw();
                this.nextPlayer.draw();
                this.prevPlayer.draw();
                break;
            case "VOTING":
                this.innoBtn.draw();
                this.guiltyBtn.draw();
                this.nextPlayer.draw();
                this.prevPlayer.draw();
                break;
            default:
                break;
        }
    }

    draw() {
        let playState = myGame.getGameData().playState;

        this.update();
        this.drawButtons();

        // NEWS, NOMINATION, INVEST, VOTING, LYNCHING, NIGHT

        switch (playState) {
            case "NEWS":
                myGame.drawText("Look up at the screen to see the events " 
                    + "that unfolded at night.");
                break;
            case "NOMINATION":
            //At this point, the screen will tell everyone to nominate someone to lynch
                myGame.drawText(`${this.getPlayer()}`);
                break;
            case "LYNCHING":
                //TODO
                //Enter the name of the player that was killed
                myGame.drawText("Player Name was executed!");
                break;
            default:
                break;
        }
    }

    mouseClick() {
        let gameState = myGame.getGameData();
        if (gameState.state == "PLAYING") {
            let playState = gameState.playState;

            switch (playState) {
                case "NOMINATION":
                    this.nominate.mouseClick();
                    this.nextPlayer.mouseClick();
                    this.prevPlayer.mouseClick();
                    break;
                case "VOTING":
                    this.innoBtn.mouseClick();
                    this.guiltyBtn.mouseClick();
                    this.nextPlayer.mouseClick();
                    this.prevPlayer.mouseClick();
                    break;
                default:
                    break;
            }
        }
    }

    getPlayerStates() {
        // console.log("Retrieving player states");
        console.log("Retrieving connected player names");
        myGame.getRequest("players").then((players) => myGame.updatePlayers(players))
        .catch((err) => console.log(`Wait, you're just stupid...\n${err}`));
    }

    getPlayer() {
        return myGame.getAllAlivePlayers()[this.currPlayer];
    }
}