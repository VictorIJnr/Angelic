let express = require("express");
let bodyParser = require('body-parser');
let cookieParser = require('cookie-parser');

let myRouter = require("./routes/index");

let app = express();

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());

app.use("/", myRouter);

console.log("Running on port");
app.listen(process.env.PORT || 20793, "0.0.0.0");