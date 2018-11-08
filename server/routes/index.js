let AWS = require("aws-sdk");
let fs = require("fs");
let express = require("express");
let router = express.Router();

let room = genRoomCode();
let gameState = {};
let gameStateFile = "state.json";

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
    if (!fileExists(gameStateFile)) {
        fs.writeFileSync(gameStateFile, JSON.stringify({hello: "go away"}));
        let digiParams = {
            Bucket: myDigiBucket,
            Key: `${req.params.room}/${gameStateFile}`,
            ACL: "public-read",
            Body: fs.createReadStream(gameStateFile),
            ContentType: "application/json"
        };

        let options = {
            partSize: 10 * 1024 * 1024, // 10 MB
            queueSize: 10
        };

        s3.upload(digiParams, options, (err, data) => {if (err) console.log(err)});
    }

    res.send("hello wait");
});

router.get("/:room", function(req, res) {
    //Check if the room exists in Digital Ocean
    //If not, send cannot join which will be processed and rendered by the user
    //Else tell them to wait until the host closes joining applications 
    //Only once host closes joining applications are roles distributed
    //eval may be your friend later along the line...
});

function fileExists(fileName) {
    let params = {
        Bucket: myDigiBucket
    };

    s3.listObjectsV2(params, function (err, data) {
        if (!err) {
            var files = []
            data.Contents.forEach(function (element) {
                files.push({
                    filename: element.Key
                });

                console.log(element.Key);
                if (element.key == fileName) return true;
            });
        }
        else console.log(err);
    });
}

function createState(state) {

}

function genRoomCode() {
    return (Math.random() + 1).toString(36).substr(2, 5).toUpperCase();
}

module.exports = router;