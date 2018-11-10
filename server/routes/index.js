let AWS = require("aws-sdk");
let fs = require("fs");
let express = require("express");
let router = express.Router();

let gameState = {};
let gameStateFile = "state.json";
let invalidRoom = "invalidRoom.json";
let demoFile = "demoState.json";

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
        getFile(`${req.params.room}/${demoFile}`, res);
    })
    .catch(() => {
        let initState = JSON.parse(fs.readFileSync(demoFile, "utf-8"));
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
        let valid = {
            room: req.params.room,
            msg: `Joined room ${req.params.room}`
                + `\nJSON object telling the player to go to a naming state goes here...`
        };
        res.send(JSON.stringify(valid));
        //Once their name is entered, P5.js will keep them in the name entry state 
        //BUT they will just be waiting for the host to signal the start of the game
    })
    .catch(() => {
        let invalid = {
            room: req.params.room,
            "err-msg": "That room does not exist."
        };
        res.send(JSON.stringify(invalid));
    });
});

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

function getFile(fileName, res) {
    let digiParams = {
        Bucket: myDigiBucket,
        Key: fileName
    }

    s3.getObject(digiParams, (err, data) => {
        console.log("From get file");
        console.log(JSON.stringify(data));
        res.send(JSON.stringify(data));
    });
}

//This may need a promise or make the s3 call sync
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
            else console.log(`Error in fileExists ${err}`);
        });
    });

    return myPromise;
}

function createState(state) {

}

module.exports = router;