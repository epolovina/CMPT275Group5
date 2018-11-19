//
//  Login.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-11-16.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class Login: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        emailTF.delegate = self
        passwordTF.delegate = self
        self.emailTF.becomeFirstResponder()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Allows keyboard to disappear when touch something else
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // Keyboard disappears
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: Actions
    let DB = Database.DB
    @IBAction func loginButtonPressed(_ sender: Any) {
    let email: String = self.emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
    let password: String = self.passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        DB.verifyLogin(emailstring: email, passwordstring: password)
        DB.loadProfileData()
        // Saves email and password text fields to database
//        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/login")!
//
//        let email: String = self.emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        let password: String = self.passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//
//        var request = URLRequest(url: url)
//        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//        request.httpMethod = "POST"
//        let postString = "email=\(email)&password=\(password)"
//        print(postString)
//        request.httpBody = postString.data(using: .utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let datares = data,
//                error == nil else {                                                 // check for fundamental networking error
//                print("error loading data")
//                return
//            }
//            do{
//                let myjson = try JSONSerialization.jsonObject(with: datares, options: JSONSerialization.ReadingOptions.mutableContainers)
//                print(myjson)
//                print((myjson as AnyObject).value(forKey: "email")!)
//            }catch{
//                print("ERROR reading json")
//            }
//        }
//        task.resume()
    }
    
    }
    

