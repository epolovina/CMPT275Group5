// File: MedicationPopUpViewController.swift
// Authors: Taylor Traviss, Khalil Ammar, Eddie Zheng
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class MedicationPopUp: UIViewController, UITextFieldDelegate {

    //MARK: Outlets
    @IBOutlet weak var medicationNameTF: UITextField!
    @IBOutlet weak var startDateScroller: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    let DB = Database.DB
    
    override func viewDidLoad() {
        super.viewDidLoad()
        medicationNameTF.delegate = self
        
        // Bring up keyboard right away
        self.medicationNameTF.becomeFirstResponder()
        
        //Make white font for scroller
        startDateScroller.setValue(UIColor.white, forKeyPath: "textColor")
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
    @IBAction func savePressed(_ sender: Any) {
        // save medication information and return to profile
        
        if let profileVC = presentingViewController as? Profile {
            // send data back to profile view controller
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let strDate = dateFormatter.string(from: self.startDateScroller.date)
            let strMedName = self.medicationNameTF.text!
            
            //profileVC.medNameAndDateArray.append((strMedName, strDate))
            
            let displayStr = strMedName + ", " + strDate
    
            profileVC.medicationArray.append(displayStr)
            profileVC.tableView.reloadData()
            
            DB.saveProfileData(firstNamestring: DB.firstName, lastNamestring: DB.lastName, agestring: DB.age, medsArr: profileVC.medicationArray as! [String])
        }
        dismiss(animated: true, completion: nil)
    }
    
}
