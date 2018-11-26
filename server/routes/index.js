let AWS = require("aws-sdk");
let fs = require("fs");
let express = require("express");
let router = express.Router();

let gameState = {};
let gameStateFile = "state.json";
let invalidRoom = "invalidRoom.json";
let demoFile = "demoState.json";
let demoSendFile = "demoSendState.json";

let myDigiBucket = "gid";
let myDigiRegion = "ams3"
let myDigiOceanKey = "WVXMXAZGXWSAPE6PNBTU";
let myDigiSecret = "4HhQJtzuam1k9DWF9RY4h8r+BMCLZ29ug1Ki8IQZUCc";

let digiEndpoint = new AWS.Endpoint(`${myDigiRegion}.digitaloceanspaces.com`);
let s3 = new AWS.S3({
    endpoint: digiEndpoint,
    accessKeyId: myDigiOceanKey,
    secretAccessKey: myDigiSecret
});

/**
 * Client-side endpoint to allow them to connect to a room
 * */
router.get("/:room", function(req, res) {
    res.render("index");
});

router.get("/:room/state", function(req, res) {
    getStateFile(req.params.room)
    .then((data) => res.send(data))
    .catch((err) => res.send("An error occurred querying room state."));
});

router.get("/:room/admin", function(req, res) {
    console.log(`Setting up room ${req.params.room}`);

    roomExists(req.params.room)
    .then(() => {
        getStateFile(req.params.room)
        .then((data) => {
            res.send(data);
        });
    })
    .catch(() => {
        let initState = createState(demoFile);
        uploadJSON(req.params.room, demoFile, initState);
        res.send(initState);
    });
});

/**
 * Endpoint to allow for the updating of connected players.
 */
router.post("/:room/admin/players", function(req, res) {
    roomOutput(req.params.room, "Roles received from host");
    let players = req.body.player_data;

    players.forEach((player) => {
        getFile(req.params.room, player.name)
        .then((data) => {
            let newPlayer = {...data, ...player};
            uploadJSON(req.params.room, player.name, newPlayer);
        })
        .catch((err) => res.send(err));
    });

    res.send("Received players.");
});

/**
 * Endpoint to allow the host to start the game for all players
 */
router.get("/:room/admin/start", function(req, res) {
    roomOutput(req.params.room, "Start signal received from host");

    getStateFile(req.params.room)
    .then((data) => {
        let newState = data;
        newState.state = "ROLES";
        newState.playState = "NEWS";

        updateStateFile(req.params.room, newState);
        console.log(newState);
        res.send(newState);
    })
    .catch((err) => res.send(err));
});

/** 
 * Endpoint to allow for state updates
*/
router.post("/:room/admin/state", function(req, res) {
    roomOutput(req.params.room, `Updating game state to ${req.body.state}`);
    updateStateFile(req.params.room, req.body);

});

/** 
 * Endpoint to retrieve a list of all the connected players
*/
router.get("/:room/players", function(req, res) {
    getPlayerNames(req.params.room)
    .then((playerNames) => {
        let sendObj = (req.cookies.playerName) ? playerNames.split("\n") : playerNames;
        res.send(sendObj);
    })
    .catch((err) => {
        console.error(err); 
        res.send(err);
    });
});

/**
 * Endpoint to get the state of all connected players
 * FINISH THIS OFF LATER
 */
router.get("/:room/players/states", function(req, res) {
    getPlayerNames(req.params.room)
    .then((playerNames) => {
        playerNames = playerNames.split("\n");
        let numPlayers = playerNames.length;
        let allPlayers = [];
        
        playerNames.forEach(name => {
            //This is a nice line of code :D
            //I'll explain it though because 
            //it's kinda daunting if you don't know JS (not trying to assume anything though)
            //Gets the name of a connected player, then gets their respective JSON file
            //And shoves it into the allPlayers array
            getFile(req.params.room, name).then((data) => allPlayers.push(data));
            

            //Need to ensure all the players are added, given that this is async
            if (allPlayers.length == numPlayers) {
                console.log("Sending back all of the connected players.");
                res.send(allPlayers);
            }
        });
    });
    //Getting risky ommitting the catch. I really shouldn't have any issues here though...
});

/**
 * Endpoint for connecting a player to the game room.
 */
router.get("/:room/player", function(req, res) {
    //Check if the room exists in DigitalOcean
    //If not, send cannot join which will be processed and rendered by the user
    //Else tell them to wait until the host closes joining applications 
    //Only once host closes joining applications are roles distributed
    //eval may be my friend later along the line...

    roomExists(req.params.room)
    .then(() => {
        //Checks the player has previously joined this room
        // if (!req.cookies.playerName && req.cookies.room == req.params.room) {
        if (true) {
            let initState = createState(demoSendFile);
            initState.state = "NAMING";
            initState.msg = `Joined room ${req.params.room}`
                + `\nJSON object telling the player to go to a naming state goes here...`;

            res.send(JSON.stringify(initState));
        }
        //Once their name is entered, players will be moved to the lobby state. 
        //They will then just be waiting for the host to start the game
    })
    .catch(() => {
        let invalid = {
            room: req.params.room,
            "err-msg": "That room does not exist."
        };

        res.send(JSON.stringify(invalid));
    });
});

/**
 * Endpoint to allow users to choose/change their name
 */
router.post("/:room/player", function(req, res) {
    //If the user is changing their name
    if (req.cookies.playerName && req.cookies.room == req.params.room) {
        uniquePlayer(req.body.myName, req.params.room)
        .then(() => {
            getStateFile(req.params.room)
            .then((data) => {
                let newPlayers = data.players;
                let index = newPlayers.indexOf(req.cookies.playerName);

                //This SHOULD always be true, can't be too safe though
                if (index != -1) newPlayers.splice(index, 1);
                updateStateFile(req.params.room, {players: newPlayers})
                .then(() => {
                    console.log(`Room ${req.params.room}:\tRenamed ${req.cookies.playerName} `
                                + `to ${req.body.myName}.`);
                    addPlayer(req.body.myName, req.params.room);

                    //Only update the player name once they've been added
                    res.cookie("playerName", req.body.myName);
                    res.send(JSON.stringify({state: "LOBBY"}));
                })
                .catch((err) => console.error(err));

                let digiParams = {
                    Bucket: myDigiBucket,
                    Key: `${req.params.room}/${req.cookies.playerName}`
                }

                //Deleting the previous player from the "database" (DigitalOcean)
                s3.deleteObject(digiParams, (err, data) => {
                    if (err) console.error(err);
                });
            })
            .catch((err) => console.error(err));
        })
        .catch(() => {
            res.send(JSON.stringify({"err-msg": "That name has already been taken."}));
        });
        
    } else {
        uniquePlayer(req.body.myName, req.params.room)
        .then(() => {
            addPlayer(req.body.myName, req.params.room);
    
            //Changing the state for the player
            let newState = createState(demoSendFile);
            newState.state = "LOBBY";
            console.log(`Room ${req.params.room}:\tMoved ${req.body.myName} to the lobby.`);
    
            //Used to associate each player with their room.
            res.cookie("room", req.params.room);
            res.cookie("playerName", req.body.myName);
            res.send(JSON.stringify(newState));
        })
        .catch(() => {
            res.send(JSON.stringify({"err-msg": "That name has already been taken."}));
        });
    }
});

/**
 * Endpoint for players to query their current state.
 * As maintained in DigitalOcean
 */
router.get("/:room/player/state", function(req, res) {
    getFile(req.params.room, req.cookies.playerName)
    .then((data) => res.send(data))
    .catch((err) => res.send("An error occured when pinging player state."));
});

router.post("/:room/vote", function(req, res) {
    getStateFile(req.params.room)
    .then((data) => {
        roomOutput(req.params.room, `${req.body.playerName} voted ${req.body.vote.toLowerCase()}`)
        let gameState = data;
        fileExists(req.params.room, `Day ${gameState.day} Voting.json`)
        .then(() => {
            let myVote = {};
            myVote[req.body.playerName] = req.body.vote;
            //Append a new vote
        })
        .catch(() => {
            //Create the voting file and append the vote
            let vote = {};
            vote[req.body.playerName] = req.body.vote;
    
            uploadJSON(req.params.room, `Day ${gameState.day} Voting.json`, vote);
        });
    })
    .catch();
});

/**
 * @param {String} room the room for which to retrieve filenames
 * @returns a promise loaded with all the filenames
 */
function getPlayerNames(room) {
    let digiParams = {
        Bucket: myDigiBucket,
        Prefix: `${room}/`
    };

    let myPromise = new Promise((resolve, reject) => {
        s3.listObjectsV2(digiParams, (err, data) => {
            if (err) reject(err);
            else {
                let players = [];
                
                data.Contents.forEach((file) => {
                    //Removing the room name and following "/"
                    let fileName = file.Key.substring(6);
                    if (fileName != `${demoFile}` && !fileName.includes("Voting"))
                        players.push(fileName);
                });
    
                //Sending each player name on a separate line
                resolve(players.join("\n"));
            }
        })
    });

    return myPromise;
}

/**
 * Initialises a variable to the local state file specified.
 * @param {String} stateFile 
 */
function createState(stateFile) {
    return JSON.parse(fs.readFileSync(stateFile, "utf-8"));
}

/** 
 * Uploads JSON to a new file in DigitalOcean.
 * @param {String} fileName file to store the data
 * @param {Object} data the data to store
*/
function uploadJSON(room, fileName, data) {
    let digiParams = {
        Bucket: myDigiBucket,
        Key: `${room}/${fileName}`,
        ACL: "public-read",
        Body: JSON.stringify(data),
        ContentType: "application/json"
    }

    let upPromise = new Promise((resolve, reject) => {
        s3.upload(digiParams, (err, data) => {
            if (err) {
                console.error(`Error uploading file.\n${err}`);
                reject(err);
            }
            else resolve(data);
        });
    });

    return upPromise;
}

/** 
 * Gets the specified file from DigitalOcean.
 * @param {String} room the room code for the file
 * @param {String} fileName the file to be retrieved.
*/
function getFile(room, fileName) {
    let digiParams = {
        Bucket: myDigiBucket,
        Key: `${room}/${fileName}`,
        ResponseContentType: "application/json"
    }

    let filePromise = new Promise((resolve, reject) => {
        s3.getObject(digiParams, (err, data) => {
            if (err) reject(err);
            else resolve(JSON.parse(data.Body))
        });
    });

    return filePromise;
}

/**
 * Gets the state file for a specified room.
 * @param {String} room the room which the state is to be retrieved from 
 */
function getStateFile(room) {
    return getFile(room, demoFile);
}

/**
 * Updates the state of the provided room.
 * @param {String} room the room to have its state updated
 * @param {Object} newFields the fields to update/add 
 */
function updateStateFile(room, newFields) {
    return new Promise((resolve, reject) => {
        getStateFile(room)
        .then((data) => {
            let newState = {...data, ...newFields};
    
            uploadJSON(room, demoFile, newState)
            .then(resolve).catch(reject);
        })
        .catch((err) => {
            console.log(`Error updating room state.\n${err}`);
            reject(err);
        });
    });
}

/**
 * Checks for the existence of a file on DigitalOcean 
 * @param {String} fileName the file to check for its existence
 * */
function fileExists(room, fileName) {
    let params = {
        Bucket: myDigiBucket,
        StartAfter: room 
    };

    let myPromise = new Promise((resolve, reject) => {
        s3.listObjectsV2(params, function (err, data) {
            if (!err) {
                let files = [];
                data.Contents.forEach((element) => {
                    files.push(element.Key);
                });

                //using a subsequent .then() to act as a "truthy" branch
                if (files.includes(fileName)) resolve();
                else reject();
            }
            else reject(err);
        });
    });

    return myPromise;
}

/**
 * Helper function to determine the existence of a room
 *  */
function roomExists(room) {
    let params = {
        Bucket: myDigiBucket,
        Key: `${room}/${demoFile}`
    };

    let myPromise = new Promise((resolve, reject) => {
        s3.getObject(params, (err) => {
            if (err) reject();
            else resolve();
        })
    });

    return myPromise;
}

/**
 * Determines whether a player name has already been taken on DigitalOcean
 * @param playerName the name to check
 * @param room the room to check for the player
 */
function uniquePlayer(playerName, room) {
    //I don't need the data from the file, its presence is enough
    let newPlayer = new Promise((resolve, reject) => {
        fileExists(room, playerName)
        .then((err) => reject(err))
        .catch(() => resolve());
    });

    return newPlayer;
}

/**
 * Adds a new player to the game
 * @param {String} playerName the new player added to the game 
 * @param {String} room the room which the player is joining 
 */
function addPlayer(playerName, room) {
    //The player file will be updated with information later
    //such as their role and who they've voted against.
    uploadJSON(room, playerName, {});

    getStateFile(room)
    .then((data) => {
        data.players.push(playerName);
        data.numPlayers = data.players.length;

        updateStateFile(room, data);
    })
    .catch((err) => console.error(`Error in getting state file from add player.\n${err}`));
}

function roomOutput(room, text) {
    console.log(`Room ${room}:\t${text}`);
}

module.exports = router;