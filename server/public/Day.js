class Day {
    constructor() {
        this.dayNo = 1;

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
            myGame.updatePlayers();
        }
    }

    draw() {
        this.guiltyBtn.draw();
        this.innoBtn.draw();
    }

    mouseClick() {
        if (this.guiltyBtn.isHovering()) this.guiltyBtn.execAction();
        else if (this.innoBtn.isHovering()) this.innoBtn.execAction();
    }

    getPlayerStates() {
        myGame.getRequest("players").then();
    }
}