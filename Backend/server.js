var express = require('express'); 
var app = express(); 
var http = require('http') 
var port = process.env.PORT || 5000; 
var url = "mongodb://root:password1@ds153552.mlab.com:53552/personalproject"; 
var MongoClient = require('mongodb').MongoClient; 

app.use(express.json()) 
app.use(express.urlencoded({extended:false})); 

var options = {
    dotfile: 'ignore', 
    etag:false, 
    extensions: ['htm','html'], 
    index: 'login.html'
}

app.use('/',express.static('./Public',options)); 


app.listen(port);
console.log("Server running on PORT: ", port);
