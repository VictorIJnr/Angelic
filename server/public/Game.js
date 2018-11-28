class Game {
    constructor() {
        this.gameData;
        this.allPlayers = {};
        this.lastPing = millis();
        this.pingDelta = 1000; //Time between pinging server state

        this.userInput = createInput();
        this.player = new Player();
        this.room = window.location.pathname.substring(1);
        this.endpoint = `http://localhost:20793/${this.room}`;

        this.myDay = new Day();

        httpGet(`${this.endpoint}/player`, "json", (data) => {
            this.gameData = data;

            if (this.gameData["err-msg"]) this.gameData.state = "ERROR";
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
                    console.log(this.gameData.playState);
                    break;
                case "PLAYING":
                    this.myDay.draw();
                    break;
                default:
                    if (typeof this.gameData.state != "undefined")
                        console.log(`State not handled...\n${this.gameData.state}`);
                    break;
            }
        }

        if (millis() > this.lastPing + this.pingDelta) {
            this.pingState();
            this.pingPlayerState();
            
            this.lastPing = millis() + this.pingDelta;
        }
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
        if (this.gameData && this.player) {
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
     * Some reason the promise doesn't want to work for me...
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

    updatePlayers(newPlayers) {
        this.allPlayers = newPlayers;
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

    getAllPlayers() {
        return this.allPlayers;
    }

    //TODO - Fix this
    getAllAlivePlayers() {
        return this.allPlayers;
    }

    getEndpoint() {
        return this.endpoint;
    }
}
