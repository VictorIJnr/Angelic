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

router.get("/:room/admin", function(req, res) {
    console.log(`Setting up room ${req.params.room}`);

    fileExists(`${req.params.room}/${demoFile}`)
    .then(() => {
        getFile(`${req.params.room}/${demoFile}`)
        .then((data) => {
            res.send(data);
        });
    })
    .catch(() => {
        let initState = createState(demoFile);
        uploadJSON(`${req.params.room}/${demoFile}`, initState);
        res.send(initState);
    });
});

router.get("/:room", function(req, res) {
    res.render("index");
});

router.get("/:room/player", function(req, res) {
    //Check if the room exists in Digital Ocean
    //If not, send cannot join which will be processed and rendered by the user
    //Else tell them to wait until the host closes joining applications 
    //Only once host closes joining applications are roles distributed
    //eval may be your friend later along the line...

    fileExists(`${req.params.room}/${demoFile}`)
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

router.post("/:room/player", function(req, res) {
    uniquePlayer(req.body.myName, req.params.room)
    .then(() => {
        res.cookie("playerName", req.body.myName);

        //The player file will be updated with information later
        //such as their role and who they've voted against.
        uploadJSON(`${req.params.room}/${req.body.myName}`, {});

        //Changing the state for the player
        let newState = createState(demoSendFile);
        newState.state = "LOBBY";
        console.log(`Moved ${req.body.myName} to the lobby.`);

        res.send(JSON.stringify(newState));
    })
    .catch((err) => {
        console.log(`Error from player post:\n${err}`);
        res.send(JSON.stringify({"err-msg": "That name has already been taken."}));
    });
});

function createState(stateFile) {
    return JSON.parse(fs.readFileSync(stateFile, "utf-8"));
}

function uploadJSON(fileName, data) {
    let digiParams = {
        Bucket: myDigiBucket,
        Key: fileName,
        ACL: "public-read",
        Body: JSON.stringify(data),
        ContentType: "application/json"
    }

    s3.upload(digiParams, (err, data) => {if (err) console.log(err);})
}

function getFile(fileName) {
    let digiParams = {
        Bucket: myDigiBucket,
        Key: fileName
    }

    let filePromise = new Promise((resolve, reject) => {
        s3.getObject(digiParams, (err, data) => {
            if (err) reject(err);
            else (resolve(JSON.stringify(data)))
        });
    });

    return filePromise;
}

/**
 * Checks for the existence of a file on Digital Ocean 
 * */
function fileExists(fileName) {
    let params = {
        Bucket: myDigiBucket
    };

    let myPromise = new Promise((resolve, reject) => {
        s3.listObjectsV2(params, function (err, data) {
            if (!err) {
                let files = [];
                data.Contents.forEach((element) => {
                    files.push(element.Key);
                });

                if (files.includes(fileName)) resolve();
                else reject();
            }
            else reject(err);
        });
    });

    return myPromise;
}

/*
 * Determines whether a JSON object pertaining to a player exists on DigitalOcean 
*/
function uniquePlayer(playerName, room) {
    //I don't need the data returned from getFile, the presence of the file is enough
    let newPlayer = new Promise((resolve, reject) => {
        fileExists(`${room}/${playerName}`)
        .then(() => reject())
        .catch(() => resolve());
    });

    return newPlayer;
}

module.exports = router;