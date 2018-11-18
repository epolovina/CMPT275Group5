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
    
    
    //MARK: Actions
    @IBAction func savePressed(_ sender: Any) {
        //let profileVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "profileVC") as! Profile
        
//        profileVC.delegate = self
        
        //profileVC.med = "something"
        
        if let presenter = presentingViewController as? Profile {
            presenter.medicationArray.append(self.medicationNameTF.text!)
            presenter.tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
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
    
    @IBAction func medicatonNameChanged(_ sender: Any) {
//        let medicationName: String = self.medicationNameTF.text!.trimmingCharacters(in: .whitespacesAndNewlines)
//        medicationArr.append(medicationName)
        
        
    }
    
}
