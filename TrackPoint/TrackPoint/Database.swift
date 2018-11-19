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
    
    var medicationArray: [(String, String)] = [] //Name and date
    var gameScoreArray: [(Double, String)] = [] //Score and date
    
    //MARK: Functions
    func saveProfileData(firstNamestring: String, lastNamestring: String, agestring: String){
//        print("self.email \(String(describing: self.email))")
        let sendjson = ["email":self.email, "password":self.password,
                        "firstName":firstNamestring, "lastName":lastNamestring, "age":agestring]
        print(sendjson)
        // saves first/last names, medications and age to db
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/sendDatatoDB")!
        
        var request = URLRequest(url: url)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
//        let postString = "firstName=\(firstNamestring))&lastName=\(lastNamestring)&age=\(agestring)"
//        print(postString)
//        request.httpBody = postString.data(using: .utf8)
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
            //
            //            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            //                print("response = \(response)")
            //            }
            //
                        //let responseString = String(data: data, encoding: .utf8)
                       // print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func loadProfileData(emailstring: String){
        let sendjson = ["email":emailstring]
        // get first/last names, medications and age from db and put in variables
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/getDatafromDB")!
        
        var request = URLRequest(url: url)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
//        let postString = "email=\(emailstring)"
//        print(postString)
//        request.httpBody = postString.data(using: .utf8)
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
            //
            //            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            //                print("response = \(response)")
            //            }
            //
//                        let responseString = String(data: data, encoding: .utf8)
//                        print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func verifyLogin( emailstring: String, passwordstring: String){
        // check email matches password
        // save email and password to database
        
//        emailstring = self.email
//        passwordstring = self.password
        

//        let postString = "email=\(emailstring)&password=\(passwordstring)"
//        print(postString)
        let sendjson = ["email":emailstring, "password":passwordstring]
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/login")!
        var request = URLRequest(url: url)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
//        request.httpBody = postString.data(using: .utf8)
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
//            let responseString = String(data: data, encoding: .utf8)
//
//            print("responseString = \(String(describing: response))")
        }
        task.resume()
    }
    
    func saveScore(scorestring: String){
        let sendjson = ["score":scorestring]
        // append new score to gameScoreArray and save to database
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/saveScore")!
        
//        let email: String = self.email
//        let score: Double = self.score
        var request = URLRequest(url: url)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
//        let postString = "email=\(email)&score=\(score)"
//        print(postString)
//        request.httpBody = postString.data(using: .utf8)
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
//                (myjson as AnyObject).value(forKey: "email")
            }catch{
                print("ERROR reading json")
            }
            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
            
//            let responseString = String(data: data, encoding: .utf8)
////            print(type(of: responseString))
//            print("responseString = \(String(describing: responseString))")
        }
        task.resume()
    }
    
    func loadScores(emailstring: String) {
        // load gameScoreArray from database
        let sendjson = ["email":emailstring]
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/getDatafromDB")!
        
        var request = URLRequest(url: url)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpbody = try? JSONSerialization.data(withJSONObject: sendjson, options: [])
            else{
                print("ERROR Problem with json")
                return
        }
        request.httpBody = httpbody
//        request.httpMethod = "POST"
//        let postString = "email=\(emailstring)"
//        print(postString)
//        request.httpBody = postString.data(using: .utf8)
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
            //            guard let data = data, error == nil else {                                                 // check for fundamental networking error
            //                print("error=\(error)")
            //                return
            //            }
            //
            //            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            //                print("response = \(response)")
            //            }
            //
            //            let responseString = String(data: data, encoding: .utf8)
            //            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    
}
