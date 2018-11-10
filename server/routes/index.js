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
    if (!fileExists(`${req.params.room}/${demoFile}`)) {
        let initState = JSON.parse(fs.readFileSync(demoFile, "utf-8"));
        uploadJSON(`${req.params.room}/${demoFile}`, initState);
        res.send(initState);
    } 
    else getFile(`${req.params.room}/${demoFile}`, res);
});

router.get("/:room", function(req, res) {
    res.render("index");
});

router.get("/:room/player", function(req, res) {
    if (!fileExists(`${req.params.room}/${demoFile}`)) {
        let invalid = {
            room: req.params.room,
            "err-msg": "That room does not exist."
        };
        res.send(JSON.stringify(invalid));
    }
    else {
        res.send("JSON object telling the player to go to a naming state goes here...");
        //Once their name is entered, P5.js will keep them in the name entry state 
        //BUT they will just be waiting for the host to signal the start of the game
    }

    //Check if the room exists in Digital Ocean
    //If not, send cannot join which will be processed and rendered by the user
    //Else tell them to wait until the host closes joining applications 
    //Only once host closes joining applications are roles distributed
    //eval may be your friend later along the line...
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

    s3.listObjectsV2(params, function (err, data) {
        if (!err)
            data.Contents.forEach((element) => {
                if (element.key == fileName) return true;
                console.log(`Checked ${element.Key} against ${fileName}.
                Element Type:\t${typeof element.Key}
                Filename Type:\t${typeof fileName}
                Result 1:\t${element.Key == fileName}
                Result 2:\t${element.Key === fileName}`);
            });
        else console.log(err);
    });
}

function createState(state) {

}

module.exports = router;