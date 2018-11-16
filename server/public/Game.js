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
            //KEXIA is a much cooler name though like damn...
        }, (err) => console.log(err));
    }

    update() {
        if (this.gameData) {
            switch (this.gameData.state) {
                case "NAMING":
                    this.enteredName();
                    break;
                case "LOBBY":
                    this.enteredName();
                    rectMode(CENTER);
                    fill(51);
                    text(`Your name is ${this.gameData.myName}\n`
                        + `Wait until for other players to join the game or until the host `
                        + `decides to start the game...`,
                        width / 2, height / 2, width * 2/3, height / 2);
                    break;
                case "ROLES": 
                    console.log("Role Distribution.");
                    break;
                    case "PLAYING":
                    console.log("Playing the game.");
                    break;
                default:
                    console.log(`State not handled...\n${this.gameData.state}`);
                    break;
            }
        }

        this.pingState();
    }

    pingState() {
        //Only update/look for a new state if the game's state has already
        //been initialised.
        if (this.gameData) {
            httpGet(`${this.endpoint}/player`, "json", (data) => {
                this.gameData = data;
                console.log(data);
                //PRXIT's a pretty cool room name
                //DYGYD is a thingy, I can't remember the name...
                //KEXIA is a much cooler name though like damn...
            }, (err) => console.log(err));
        }
    }

    enteredName() {
        this.userInput.changed(() => {
            // this.player.setName(this.userInput.value());
            //The following line should be temporary
            this.gameData.myName = this.userInput.value();
            let postData = {
                myName: this.userInput.value()
            }

            httpPost(`${this.endpoint}/player`, "json", postData, 
            (response) => {
                this.gameData.state = response.state;
            });
        });
    }
}
