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
            dateFormatter.dateFormat = "MMM dd, YYYY"
            let strDate = dateFormatter.string(from: self.startDateScroller.date)
            profileVC.medNameAndDateArray.append((self.medicationNameTF.text!, strDate))
            profileVC.medicationArray.append(self.medicationNameTF.text!)
            profileVC.tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
    
}
