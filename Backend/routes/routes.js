var router = require('express').Router(); 
var url = "mongodb://cmpt275admin:cmpt275admin@ds121464.mlab.com:21464/cmpt275"; 
var MongoClient = require('mongodb').MongoClient;


router.post('/sendDatatoDB', function(req, res) {
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
						email: req.body.email,
						password:req.body.password,
						age: req.body.age,
						// diagnosisDate: req.body.diagnosisDate, 
						// diagnosisStatus: req.body.diagnosisStatus,
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

router.post('/getDatafromDB', function (req, res){
	MongoClient.connect(url, function(err, client) {
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275');
		var collection = db.collection('userdata');
		collection.find({firstName:'joe-rogan'}).toArray(function(err,result){
			res.setHeader('Content-Type', 'application/json');
			console.log(result);
			res.send(JSON.stringify(result));
			// res.send(result);
		});
		// collection.findOne({email:req.body.email}, function (err, result){
		// 	console.log(result);
		// 	res.setHeader('Content-Type', 'application/json');
		// 	res.json(result);
		// });
	});
});

router.post("/login", (req,res)=>{
	MongoClient.connect(url, function(err, client) {
			if(err) {
				console.log('Error');
				throw(err)
			}
			console.log("Connected successfully to server");
			
			const db = client.db('cmpt275');
			var collection = db.collection('userdata');
			collection.findOne({email:req.body.email},function(err,result){

				res.setHeader('Content-Type', 'application/json');
				console.log("RES", result);

				if(result === null){
						if(!req.body.firstName || !req.body.lastName || !req.body.age){
							req.body.firstName = " ";
							req.body.lastName = " ";
							req.body.age = " ";
						}
						var profileSetup = {
							firstName: req.body.firstName,
							lastName: req.body.lastName,
							email: req.body.email,
							password:req.body.password,
							age: req.body.age,
							// diagnosisDate: req.body.diagnosisDate, 
							// diagnosisStatus: req.body.diagnosisStatus,
							medication: [],
							dataArray: []
						};
					console.log("profile setup", profileSetup);
					collection.insert(profileSetup, ()=>{
						console.log("Profile Created");
						res.send(JSON.stringify(profileSetup));
					});
				}else if(result.password != req.body.password){
					var jsonToSend = {response: "Wrong Password"}
					res.send(JSON.stringify(jsonToSend));
				}else{
					res.send(JSON.stringify(result));
				}
				// res.send(result);
			});
		
		});
});


module.exports = router;