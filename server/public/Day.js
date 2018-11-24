class Day {
    constructor() {
        this.guiltyBtn = new Button(width * 0.25, height * 0.875, 200, 65, "Guilty", () => {
            let gamePlayer = myGame.getPlayer();

            //TODO
            //Send a guilty vote to the server
        });
        this.innoBtn = new Button(width * 0.75, height * 0.875, 200, 65, "Innocent", () => {
            let gamePlayer = myGame.getPlayer();

            //TODO
            //Send an innocent vote to the server
        });
    }

    isDay() {
        let gameData = myGame.getGameData();
        let gameState = gameData.state;
        let currState = gameData.playState;
        return gameState == "PLAYING" && currState != "NIGHT";
    }

    draw() {
        this.guiltyBtn.draw();
        this.innoBtn.draw();
    }

    mouseClick() {
        if (this.guiltyBtn.isHovering())
            this.guiltyBtn.execAction();
        else if (this.innoBtn.isHovering())
            this.innoBtn.execAction();
    }
}