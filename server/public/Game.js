class Game {
    constructor() {
        this.gameData;
        this.userInput = createInput();
        this.player = new Player();
        this.room = window.location.pathname.substring(1);
        this.endpoint = `http://localhost:20793/${this.room}`;

        httpGet(`${this.endpoint}/player`, "json", (data) => {
            this.gameData = data;
            console.log(data);
            //PRXIT's a pretty cool room name
            //DYGYD is a thingy, I can't remember the name...
        }, (err) => console.log(err));
    }

    update() {
        if (this.gameData) {
            switch (this.gameData.state) {
                case "NAMING":
                    this.userInput.changed(() => {
                        // this.player.setName(this.userInput.value());
                        //This line should be temporary
                        this.gameData.myName = this.userInput.value();
                        let postData = {
                            myName: this.userInput.value()
                        }

                        httpPost(`${this.endpoint}/player`, "json", postData, 
                        (response) => {
                            this.gameData.state = response.state;
                        });
                    });
                    break;
                case "LOBBY":
                    // rectMode(CENTER);
                    console.log("Moved to the lobby");
                    text(`Your name is ${this.gameData.myName}\n`
                        + `Wait until for other players to join the game or until the host `
                        + `decides to start the game...`,
                        width / 3, height / 3, width * 2/3, height / 2);
                    break;
                default:
                    console.log("State not handled...");
                    break;
            }
        }
    }
}
