var express = require('express'); 
var app = express(); 
// var http = require('http') 
var port = process.env.PORT || 5000; 
// var url = "mongodb://cmpt275admin:cmpt275admin@ds121464.mlab.com:21464/cmpt275"; 
// var MongoClient = require('mongodb').MongoClient;
// var bodyParser=require("body-parser");

// app.use(bodyParser.urlencoded({extended: true}));
// app.use(bodyParser.json());

app.use(express.json()) 
app.use(express.urlencoded({extended:true})); 

var options = {
	dotfile: 'ignore', 
	etag:false, 
	extensions: ['htm','html'], 
	index: 'index.html'
}

app.use('/',express.static('./Public',options)); 
app.use(require('./routes/routes'));

app.listen(port);
console.log("Server running on PORT: ", port);
