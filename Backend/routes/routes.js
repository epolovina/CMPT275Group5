var router = require('express').Router(); 
var url = "mongodb://cmpt275admin:cmpt275admin@ds121464.mlab.com:21464/cmpt275"; 
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
		
		const db = client.db('cmpt275');
		var collection = db.collection('userdata');
		console.log("firstname", req.body);
		var myobj = {
			firstName: req.body.firstName,
			lastName: req.body.lastName,
			email: req.body.email,
			password:req.body.password,
			age: req.body.age,
			score: [],
			// diagnosisDate: req.body.diagnosisDate, 
			// diagnosisStatus: req.body.diagnosisStatus,
			medication: [],
			dateArray: []
		};	// console.log("lastname", req.body.lastName);
		myobj.medication = req.body.medicationArr;
		// collection.insert(myobj, ()=>{
		// 	console.log('Document inserted');
		// 	res.send(200);
		// });
		// collection.find({email:req.body.email}, (err, result)=>{
			// result.medication.push(req.body.medicationArr)
			// for(var i = 0; i< result.medication[0].length;i++){
			// 	for(var  j = 0; j<req.body.medicationArr.length; j++){
			// 		result.medication[0].push(req.body.medicationArr[i])
			// 	}
			// }
			collection.update({email:req.body.email}, myobj, (err,res)=>{
				console.log("updated score");
			});
		// });
		res.setHeader('Content-Type', 'application/json');
		res.send(200);

	});
	// res.send("hi");
});

router.post('/getDatafromDB', (req, res)=>{
	MongoClient.connect(url, (err, client)=> {
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275');
		var collection = db.collection('userdata');
		collection.findOne({email:req.body.email},(err,result)=>{
			res.setHeader('Content-Type', 'application/json');
			console.log(result);
			res.send(result);
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
	MongoClient.connect(url, (err, client)=>{
		if(err) {
			console.log('Error');
			throw(err)
		}
		console.log("Connected successfully to server");
		
		const db = client.db('cmpt275');
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
					// diagnosisDate: req.body.diagnosisDate, 
					// diagnosisStatus: req.body.diagnosisStatus,
					medication: [],
					dateArray: []
				};
				console.log("profile setup", profileSetup);
				collection.insert(profileSetup, ()=>{
					console.log("Profile Created");
					res.send((profileSetup));
				});
			}else if(result.password != req.body.password){
				var jsonToSend = {response: "Wrong Password"}
				res.send((jsonToSend));
			}else{
				res.send((result));
			}
			// res.send(result);
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
		
		const db = client.db('cmpt275');
		var collection = db.collection('userdata');
		collection.findOne({email:req.body.email},(err,result)=>{
			if(result != null){
				result.scoreArray = req.body.score;
				result.dateArray = req.body.dateArray
				collection.update({email:req.body.email}, {$set:{scoreArray:result.score, dateArray:result.dateArray}}, (req,res)=>{
					console.log("updated score");
					res.send(200);
				});
			}else{
				res.send(404);
			}
			res.setHeader('Content-Type', 'application/json');
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
		
		const db = client.db('cmpt275');
		var collection = db.collection('userdata');
		collection.findOne({email:req.body.email},(err,result)=>{
			res.setHeader('Content-Type', 'application/json');
			console.log("RES", result.scoreArray);
			res.send(result.scoreArray)

		});
	});
});

module.exports = router;