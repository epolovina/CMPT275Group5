var express = require('express'); 
var app = express(); 
var http = require('http') 
var port = process.env.PORT || 5000; 
var url = "mongodb://cmpt275admin:cmpt275admin@ds121464.mlab.com:21464/cmpt275"; 
var MongoClient = require('mongodb').MongoClient;
var bodyParser=require("body-parser");

// app.use(bodyParser.urlencoded({extended: true}));
// app.use(bodyParser.json());

app.use(express.json()) 
app.use(express.urlencoded({extended:true})); 

var options = {
	dotfile: 'ignore', 
	etag:false, 
	extensions: ['htm','html'], 
	index: 'login.html'
}

app.use('/',express.static('./Public',options)); 

app.post('/sendDatatoDB', function(req, res) {
	// Use connect method to connect to the server
		// console.log("firstname", req.body);
		// console.log("lastname", req.body.lastName);
 
	MongoClient.connect(url, function(err, client) {
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275');
		var collection = db.collection('userdata');
		console.log("firstname", req.body);
		// console.log("lastname", req.body.lastName);
		var myobj = {	firstName: req.body.firstName,
						lastName: req.body.lastName,
						age: req.body.age,
						diagnosisDate: req.body.diagnosisDate, 
						diagnosisStatus: req.body.diagnosisStatus,
						medication: [],
						dataArray: []
					};
		myobj.medication.push(req.body.meds);
		collection.insert(myobj, function(){
			console.log('Document inserted');
			res.redirect('/');
		});
	});
	// res.send("hi");
});

app.listen(port);
console.log("Server running on PORT: ", port);
