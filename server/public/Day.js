class Day {
    constructor() {
        this.dayNo = 1;
        this.currPlayer = 0;

        this.guiltyBtn = new Button(width * 0.25, height * 0.875, 200, 65, "Guilty", () => {
            let gamePlayer = myGame.getPlayer();
            let myVote = {
                playerName: gamePlayer.getName(),
                vote: "GUILTY"
            };
            myGame.postRequest("vote/", myVote);
        });

        this.innoBtn = new Button(width * 0.75, height * 0.875, 200, 65, "Innocent", () => {
            let gamePlayer = myGame.getPlayer();
            let myVote = {
                playerName: gamePlayer.getName(),
                vote: "INNOCENT"
            };
            myGame.postRequest("vote/", myVote);
        });

        this.nextPlayer = new Button(width * 0.85, height / 2, 40, 40, ">", () => {
            let allPlayers = myGame.getAllAlivePlayers();
            let numPlayers = allPlayers.length;
            this.currPlayer = Math.abs((this.currPlayer + 1) % numPlayers);
            console.log(this.currPlayer);
        });
        
        this.prevPlayer = new Button(width * 0.15, height / 2, 40, 40, "<", () => {
            let allPlayers = myGame.getAllAlivePlayers();
            let numPlayers = allPlayers.length;
            this.currPlayer = Math.abs((this.currPlayer - 1) % numPlayers);
            console.log(this.currPlayer);
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
        this.innoBtn.draw();
        this.guiltyBtn.draw();
        this.nextPlayer.draw();
        this.prevPlayer.draw();
    }

    draw() {
        this.update();
        this.drawButtons();
        //At this point, the screen will tell everyone to nominate someone to lynch
        myGame.drawText(`${this.getPlayer()}\n`);
    }

    mouseClick() {
        let gameState = myGame.getGameData();
        if (gameState.state == "PLAYING") {
            this.innoBtn.mouseClick();
            this.guiltyBtn.mouseClick();
            this.nextPlayer.mouseClick();
            this.prevPlayer.mouseClick();
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