//
//  Database.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-11-17.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

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
    
    var medicationArray: [(String, String)] = [] //Name and date
    var gameScoreArray: [(Double, String)] = [] //Score and date
    
    //MARK: Functions
    func saveProfileData(){
        // saves first/last names, medications and age to db
    }
    
    func loadProfileData(){
        // get first/last names, medications and age from db and put in variables
    }
    
    func varifyLogin(){
        // check email matches password
        // save email and password to database
    }
    
    func saveScore(){
        // append new score to gameScoreArray and save to database
    }
    
    func loadScores() {
        // load gameScoreArray from database
    }
    
    
}
