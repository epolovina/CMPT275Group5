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
    
    let DB = Database.DB

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
        // Keyboard disappears when return pressed
        
        if textField == emailTF {
            textField.resignFirstResponder()
            passwordTF.becomeFirstResponder()
        }
        
        else {
            textField.resignFirstResponder()
            loginButtonPressed(loginButton)
        }

        return true
    }
    
    //MARK: Actions
    @IBAction func loginButtonPressed(_ sender: Any) {
        let email: String = self.emailTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password: String = self.passwordTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        var isValidLogin: Bool
        
        isValidLogin = DB.verifyLogin(emailstring: email, passwordstring: password)
        
        print("isvalidlogin \(isValidLogin)")
        if (isValidLogin == true){
            // Login is accepted
            
            print("Login is valid...")
            DB.loadData()
            performSegue(withIdentifier: "loginSegue", sender: self)
        }
        
        if (isValidLogin == false){
            // Login rejected
            
            print("Incorrect Login...")
            // create alert for incorrect password
            let alert = UIAlertController(title: "Invalid Login", message: "Incorrect password, please try again", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
    }
}
    

