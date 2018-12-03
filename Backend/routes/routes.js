var router = require('express').Router(); 
var url = "mongodb://cmpt275admin:cmpt275admin@ds115154.mlab.com:15154/cmpt275v3"
var MongoClient = require('mongodb').MongoClient;


router.post('/sendDatatoDB', (req, res)=>{
	// Use connect method to connect to the server
		// console.log("firstname", req.body);
		// console.log("lastname", req.body.lastName);
 
	MongoClient.connect(url, (err, client)=> {
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275v3');
		var collection = db.collection('userdata');
		console.log("firstname", req.body);
		collection.findOne({email:req.body.email}, (err,result)=>{
		if(req.body.firstName){
			result.firstName = req.body.firstName;
		}
		if(req.body.lastName){
			result.lastName = req.body.lastName;
		}
		if(req.body.password){
			result.password = req.body.password;
		}
		if(req.body.age){
			result.age = req.body.age;
		}
		if(req.body.scoreArray){
			result.scoreArray = req.body.scoreArray;
		}
		if(req.body.medicationArr){
			result.medication = req.body.medicationArr
		}
		if(req.body.dateArray){
			result.dateArray = req.body.dateArray;
		}


		collection.update({email:req.body.email}, result, (err,res)=>{
			console.log("updated score");
		});
	});
		res.setHeader('Content-Type', 'application/json');
		res.send(200);

	});
});

router.post('/getDatafromDB', (req, res)=>{
	MongoClient.connect(url, (err, client)=> {
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275v3');
		var collection = db.collection('userdata');
		console.log("getdata email ", req.body.email)
		collection.findOne({email:req.body.email},(err,result)=>{
			res.setHeader('Content-Type', 'application/json');
			console.log("result from getData: ",result);
			res.send(result);
		});
	});
});

router.post("/login", (req,res)=>{
	MongoClient.connect(url, (err, client)=>{
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275v3');
		var collection = db.collection('userdata');
		collection.findOne({email:req.body.email},(err,result)=>{

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
					scoreArray: [],
					medication: [],
					dateArray: []
				};
				console.log("profile setup", profileSetup);
				collection.insert(profileSetup, ()=>{
					console.log("Profile Created");
				});
				res.send((profileSetup));
			}else{
				res.send(result);
			}
		});
	});
});
router.post("/saveScore", (req, res)=>{
	MongoClient.connect(url, (err, client)=>{
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		res.setHeader('Content-Type', 'application/json');
		
		const db = client.db('cmpt275v3');
		var collection = db.collection('userdata');
		collection.findOne({email:req.body.email},(err,result)=>{
			if(result != null){
				result.scoreArray = req.body.scoreArray;
				result.dateArray = req.body.dateArray
				collection.update({email:req.body.email}, {$set:{scoreArray:result.scoreArray, dateArray:result.dateArray}}, (req,res)=>{
					console.log("updated score");
				});
				res.send(200);
			}else{
				res.send(404);
			}
			console.log("RES", result);

		// res.send(result);
		});
	});
});
router.post("/loadScores", (req,res)=>{
	MongoClient.connect(url, (err, client)=>{
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275v3');
		var collection = db.collection('userdata');
		collection.findOne({email:req.body.email},(err,result)=>{
			res.setHeader('Content-Type', 'application/json');
			console.log("RES", result.scoreArray);
			res.send(result.scoreArray)

		});
	});
});

module.exports = router;
