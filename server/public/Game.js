class Game {
    constructor() {
        this.gameData;
        this.allPlayers;

        this.userInput = createInput();
        this.player = new Player();
        this.room = window.location.pathname.substring(1);
        this.endpoint = `http://localhost:20793/${this.room}`;

        this.myDay = new Day();

        httpGet(`${this.endpoint}/player`, "json", (data) => {
            this.gameData = data;

            if (this.gameData["err-msg"]) this.gameData.state = "ERROR";

            console.log(data);
            //PRXIT's a pretty cool room name
            //DYGYD is a thingy, I can't remember the name...
            //KEXIA is a much cooler name though like damn...
            //RUSKI isn't bad, but I doubt anything'll beat Kexia
        }, (err) => console.log(err));
    }

    update() {
        if (this.gameData) {
            if (this.gameData.state == "HOSTING") 
                this.gameData.state = (this.player.getName()) ? "LOBBY" : "NAMING";

            switch (this.gameData.state) {
                case "ERROR":
                    this.errorState();
                    break;
                case "NAMING":
                    this.enteredName();
                    this.drawText(`Enter your desired name in the text box below.`)
                    break;
                case "LOBBY":
                    this.enteredName();
                    this.drawText(`Your name is ${this.gameData.myName}\n`
                        + `Wait until for other players to join the game or until the host `
                        + `decides to start the game...`);
                    break;
                case "ROLES":
                    this.drawText(`You've been assigned to play as ${this.player.displayRole()}\n`);
                    break;
                case "PLAYING":
                    this.drawText(`Look up at the screen`);
                    this.myDay.draw();
                    break;
                default:
                    if (typeof this.gameData.state !=  "undefined")
                        console.log(`State not handled...\n${this.gameData.state}`);
                    break;
            }
        }

        this.pingState();
        this.pingPlayerState();
    }

    draw() {
        this.update();
    }

    errorState() {
        this.drawText(this.gameData["err-msg"]);
    }

    pingState() {
        httpGet(`${this.endpoint}/state`, "json", (data) => {
            if (data.state != "HOSTING") {
                this.gameData = data;
            }
        });
    }

    pingPlayerState() {
        //Only update/look for a new state if the game's state has already
        //been initialised.
        if (this.gameData) {
            httpGet(`${this.endpoint}/player/state`, "json", (data) => {
                if (typeof data.role != "undefined") this.player.setRole(data.role);
            });
        }
    }

    enteredName() {
        this.userInput.changed(() => {
            // this.player.setName(this.userInput.value());
            //The following line should be temporary
            this.gameData.myName = this.userInput.value();
            this.player.setName(this.userInput.value());
            let postData = {
                myName: this.userInput.value()
            }

            httpPost(`${this.endpoint}/player`, "json", postData, 
            (response) => {
                this.gameData.state = response.state;
            });
        });
    }

    /**
     * @param {String} endpoint
     * Sends a get request to the server 
     */
    getRequest(endpoint) {
        let myPromise = new Promise((resolve, reject) => {
            httpGet(`${this.endpoint}/${endpoint}`, "json", 
                (response) => resolve(response),
                (err) => reject(err));
        });

        return myPromise;
    }

    postRequest(endpoint, postData) {
        let myPromise = new Promise((resolve, reject) => {
            httpPost(`${this.endpoint}/${endpoint}`, "json", postData, 
                (response) => resolve(response),
                (err) => reject(err));
        });

        return myPromise;
    }

    drawText(displayText) {
        rectMode(CENTER);
        fill(51);
        text(displayText, width / 2, height / 2, width * 0.75, height / 2); 
    }

    mouseClick() {
        this.myDay.mouseClick();
    }

    getGameData() {
        return this.gameData;
    }

    getPlayer() {
        return this.player;
    }
}
