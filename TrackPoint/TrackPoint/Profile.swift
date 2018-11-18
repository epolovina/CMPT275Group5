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
    
    //MARK: Variables
    var medicationArray = [String]()
    var med: String! = "ugh"
    //var medicationName: String

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        ageTF.delegate = self
        
        
        //print(med)
        
//        medicationArray.append("Medication 1")
//        medicationArray.append("Medication 2")
//        medicationArray.append("Medication 3")
        
        //load in data from database and set text fields
        
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
    
    func saveProfile(fName: String, lName: String, age: String){
        // Saves text fields to database
        let url = URL(string: "https://trackpointcmpt275.herokuapp.com/sendDatatoDB")!
        
        var request = URLRequest(url: url)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        let postString = "firstName=\(fName)&lastName=\(lName)&age=\(age)"
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
    
    //MARK: Actions
    @IBAction func firstNameChanged(_ sender: Any){
        // get input from text fields and save to database
        let firstName: String = self.firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName: String = self.lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age: String = self.ageTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        saveProfile(fName: firstName, lName: lastName, age: age)
    }

    @IBAction func lastNameChanged(_ sender: Any) {
        let firstName: String = self.firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName: String = self.lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age: String = self.ageTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        saveProfile(fName: firstName, lName: lastName, age: age)
    }
    
    @IBAction func ageChanged(_ sender: Any) {
        let firstName: String = self.firstNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName: String = self.lastNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let age: String = self.ageTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        saveProfile(fName: firstName, lName: lastName, age: age)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
    }
    
}
