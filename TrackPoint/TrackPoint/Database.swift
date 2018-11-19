//
//  Database.swift
//  TrackPoint
//
//  Created by Taylor Traviss and Erlind Polovina on 2018-11-17.
//
//  This class has all the database calls and saves any needed results such as email and password
//  to a glabal variable to be used later by the program.
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//
import UIKit
class Database {
    // This is a singleton class. Use the DB instance to access globally
    
    //private so only 1 instance gets created
    private init(){
    }
    
    //make one single instance
    static let DB = Database()
    
    //MARK: Variables
    var firstName: String!
    var lastName: String!
    var age: String!
    
    var email: String!
    var password: String!
    
    var score = Double() //will send score to db and push into array
    var scoreDate: String!
    
    //var medicationArray: [(String, String)] = [] //Name and date
    var medicationArray = [String?]()
    var scoreArray = [Double?]()
    var dateArray = [String?]()
    //var gameScoreArray: [(Double, String)] = [] //Score and date
    
    //MARK: Functions
    func saveProfileData(firstNamestring: String, lastNamestring: String, agestring: String, medsArr: [String]){

        let sendjson = ["email":self.email, "password":self.password,
                        "firstName":firstNamestring, "lastName":lastNamestring, "age":agestring,
                        "medicationArr":medsArr] as [String : Any]
        self.firstName = firstNamestring
        self.lastName = lastNamestring
        self.age = agestring
        self.medicationArray = medsArr
        print(sendjson)
        // saves first/last names, medications and age to db
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/sendDatatoDB")!
        
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        guard let httpbody = try? JSONSerialization.data(withJSONObject: sendjson, options: [])
            else{
                print("ERROR Problem with json")
                return
        }
        request.httpBody = httpbody
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let datares = data,
                error == nil else {             // check for fundamental networking error
                print("ERROR LOADING DATA")
                return
            }
            do{
                let myjson = try JSONSerialization.jsonObject(with: datares, options: JSONSerialization.ReadingOptions.mutableContainers)

                print(myjson)
            }catch{
                print("ERROR reading json")
            }
        }
        task.resume()
    }
    
    func loadData(){
        let sendjson = ["email":self.email]
        // get first/last names, medications and age from db and put in variables
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/getDatafromDB")!
        
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        guard let httpbody = try? JSONSerialization.data(withJSONObject: sendjson, options: [])
            else{
                print("ERROR Problem with json")
                return
        }
        request.httpBody = httpbody
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let datares = data,
                error == nil else {             // check for fundamental networking error
                    print("ERROR LOADING DATA")
                    return
            }
            do{
                let myjson = try JSONSerialization.jsonObject(with: datares, options: JSONSerialization.ReadingOptions.mutableContainers)
                self.firstName = ((myjson) as AnyObject).value(forKey: "firstName")! as? String
                self.lastName = ((myjson) as AnyObject).value(forKey: "lastName")! as? String
                self.age = ((myjson) as AnyObject).value(forKey: "age")! as? String
                self.medicationArray = (((myjson) as AnyObject).value(forKey: "medication")! as? [String?] ?? [])
                self.scoreArray = (((myjson) as AnyObject).value(forKey: "scoreArray")! as? [Double?] ?? [])
                self.dateArray = (((myjson) as AnyObject).value(forKey: "dateArray")! as? [String?] ?? [])
                
                print(myjson)
                
            }catch{
                print("ERROR reading json")
            }

        }
        task.resume()
    }
    
    func verifyLogin( emailstring: String, passwordstring: String){
        // check email matches password
        // save email and password to database
        
        self.email = emailstring
        self.password = passwordstring

        let sendjson = ["email":emailstring, "password":passwordstring]
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/login")!
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"

        guard let httpbody = try? JSONSerialization.data(withJSONObject: sendjson, options: [])
        else{
            print("ERROR Problem with json")
            return
        }
        request.httpBody = httpbody
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let datares = data,
                error == nil else {             // check for fundamental networking error
                    print("ERROR LOADING DATA")
                    return
            }
            do{
                let myjson = try JSONSerialization.jsonObject(with: datares, options: JSONSerialization.ReadingOptions.mutableContainers)
                print(myjson)
                self.email = ((myjson) as AnyObject).value(forKey: "email")! as? String // idk if this works, should save email so we van use it later
                self.password = ((myjson) as AnyObject).value(forKey: "password")! as? String
            }catch{
                print("ERROR reading json")
            }

        }
        task.resume()
    }
    
    func saveScore(){
        let sendjson = ["email":self.email, "scoreArray":self.scoreArray, "dateArray":self.dateArray] as [String : Any]
        
        // append new score to gameScoreArray and save to database
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/saveScore")!
        
        var request = URLRequest(url: url)

        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"

        guard let httpbody = try? JSONSerialization.data(withJSONObject: sendjson, options: [])
            else{
                print("ERROR Problem with json")
                return
        }
        request.httpBody = httpbody
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let datares = data,
                error == nil else {  // check for fundamental networking error
                    print("ERROR LOADING DATA")
                    return
            }
            do{
                let myjson = try JSONSerialization.jsonObject(with: datares, options: JSONSerialization.ReadingOptions.mutableContainers)
                print(myjson)
            }catch{
                print("ERROR reading json")
            }
        }
        task.resume()
    }
}

