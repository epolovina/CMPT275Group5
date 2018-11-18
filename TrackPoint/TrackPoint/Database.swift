//
//  Database.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-11-17.
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
    func saveProfileData(){
        // saves first/last names, medications and age to db
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/sendDatatoDB")!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "firstName=\(firstName)&lastName=\(lastName)&age=\(age)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {             // check for fundamental networking error
                            print("error=\(error)")
                            return
                        }
            //
            //            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            //                print("response = \(response)")
            //            }
            //
                        let responseString = String(data: data, encoding: .utf8)
                        print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func loadProfileData(){
        // get first/last names, medications and age from db and put in variables
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/getDatafromDB")!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(email)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {                                                 // check for fundamental networking error
                            print("error=\(error)")
                            return
                        }
            //
            //            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
            //                print("statusCode should be 200, but is \(httpStatus.statusCode)")
            //                print("response = \(response)")
            //            }
            //
                        let responseString = String(data: data, encoding: .utf8)
                        print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func verifyLogin(){
        // check email matches password
        // save email and password to database
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/login")!
        
        let email: String = self.email
        let password: String = self.password
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(email)&password=\(password)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
            
            let responseString = String(data: data, encoding: .utf8)
            
            print("responseString = \(response)")
        }
        task.resume()
    }
    
    func saveScore(){
        // append new score to gameScoreArray and save to database
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/saveScore")!
        
        let email: String = self.email
        let score: Double = self.score
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(email)&score=\(score)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
            
            let responseString = String(data: data, encoding: .utf8)
            print(type(of: responseString))
            print("responseString = \(responseString)")
        }
        task.resume()
    }
    
    func loadScores() {
        // load gameScoreArray from database
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/getDatafromDB")!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "email=\(email)"
        print(postString)
        request.httpBody = postString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
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
