var express = require("express");
var app = express();

//app.get('/',(req, res) => res.status(200).json({ result: 'Success from PI!' }));

app.get('/',function(req,res) {
  res.sendFile('/home/ashaxyn/mqtt-panel/index.html');
});

app.listen(3000, () =>{
    console.log("Server running on port 3000");
})
