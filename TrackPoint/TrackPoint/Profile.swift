// File: Profile.swift
// Authors: Taylor Traviss, Joey Huang
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class Profile: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    //MARK: Create outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var ageTF: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    //MARK: Variables
    var medicationArray = [String?]() // name and start date
    var medNameAndDateArray: [(String, String)] = []
    let DB = Database.DB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        ageTF.delegate = self
        
        let borderColour = UIColor(red: 125/255, green: 18/255, blue: 81/255, alpha: 1)
        progressButton.layer.borderColor = borderColour.cgColor
        progressButton.layer.borderWidth = 4
        addButton.layer.borderColor = borderColour.cgColor
        addButton.layer.borderWidth = 4
        menuButton.layer.borderColor = borderColour.cgColor
        menuButton.layer.borderWidth = 2
        
        //load in data from database and set text fields
        self.lastNameTF.text = DB.lastName
        self.firstNameTF.text = DB.firstName
        self.ageTF.text = DB.age
        self.medicationArray = DB.medicationArray
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of rows in medication table
        return medicationArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // creates cell for each table view row
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = medicationArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // allows user to delete a cell in the table
        if editingStyle == UITableViewCell.EditingStyle.delete{
            
            // create alert to confirm deletion
            let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to delete this medication?", preferredStyle: .alert)
            
            // if yes is pressed, delete from table
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.medicationArray.remove(at: indexPath.row)
                tableView.reloadData()
                self.DB.saveProfileData(firstNamestring: self.DB.firstName, lastNamestring: self.DB.lastName, agestring: self.DB.age, medsArr: self.medicationArray as! [String])
            }))
            
            // if no is pressed, return
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
                return}))
            
            self.present(alert, animated: true)
        }
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
    @IBAction func firstNameChanged(_ sender: Any){
        // get input from text fields and save to database
        let firstName: String = self.firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName: String = self.lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age: String = self.ageTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        DB.saveProfileData(firstNamestring: firstName, lastNamestring: lastName, agestring: age, medsArr: medicationArray as! [String])
    }

    @IBAction func lastNameChanged(_ sender: Any) {
        let firstName: String = self.firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName: String = self.lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age: String = self.ageTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        DB.saveProfileData(firstNamestring: firstName, lastNamestring: lastName, agestring: age, medsArr: medicationArray as! [String])
    }
    
    @IBAction func ageChanged(_ sender: Any) {
        
        let firstName: String = self.firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName: String = self.lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age: String = self.ageTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        DB.saveProfileData(firstNamestring: firstName, lastNamestring: lastName, agestring: age, medsArr: medicationArray as! [String])
    }
}
