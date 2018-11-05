// File: Main.cpp
// Authors: Taylor Traviss, Khalil Ammar, Eddie Zheng
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class MedicationPopUpViewController: UIViewController {

    //@IBOutlet weak var medicationTextField: UITextField!
   // @IBOutlet weak var startDate: UIDatePicker!
    //@IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    
    //@IBOutlet weak var StartDate: UIDatePicker!
    var medicationArr = [String]()
    
    //@IBOutlet weak var EndDate: UIDatePicker!
    //verify input is correct
    @IBAction func closePopUp(_ sender: Any) {
      //  if medicationTextField.text != ""{
            
            dismiss(animated: true, completion: nil)
            
        //}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
    }
    

}
