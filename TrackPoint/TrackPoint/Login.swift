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
        
        let borderColour = UIColor(red: 125/255, green: 18/255, blue: 81/255, alpha: 1)
        loginButton.layer.borderColor = borderColour.cgColor
        loginButton.layer.borderWidth = 4

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // check login before moving to the main menu
        return DB.loginValid
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

        
        DB.verifyLogin(emailstring: email, passwordstring: password)
        sleep(1)
        // Loop until login is finished
        while(DB.loginFinished == false){
        }
        
        if (DB.loginValid == true){
            // Login is accepted
            
            print("Login is valid...")
            DB.loadData()
            performSegue(withIdentifier: "loginSegue", sender: nil)
        }
        
        if (DB.loginValid == false){
            // Login rejected
            
            print("Incorrect Login...")
            // create alert for incorrect password
            let alert = UIAlertController(title: "Invalid Login", message: "Incorrect password, please try again", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
