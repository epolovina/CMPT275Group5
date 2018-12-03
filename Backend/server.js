var express = require('express'); 
var app = express(); 
var port = process.env.PORT || 5000; 

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
