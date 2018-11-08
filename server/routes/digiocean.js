let AWS = require('aws-sdk');

let myDigiRegion = "ams3"
let myDigiOceanKey = "WVXMXAZGXWSAPE6PNBTU";
let myDigiSecret = "4HhQJtzuam1k9DWF9RY4h8r+BMCLZ29ug1Ki8IQZUCc";

let digiEndpoint = new AWS.Endpoint(`${myDigiRegion}.digitaloceanspaces.com`);
let s3 = new AWS.S3({
    endpoint: digiEndpoint,
    accessKeyId: myDigiOceanKey,
    secretAccessKey: myDigiSecret
});

// Full documentation: https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/S3.html#listObjectsV2-property
var params = {
    Bucket: `gid`
};

s3.listObjectsV2(params, function (err, data) {
    if (!err) {
        var files = []
        data.Contents.forEach(function (element) {
            files.push({
                filename: element.Key
            });
            console.log(element.Key);
        });
    }
    else console.log(err);
});