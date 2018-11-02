//
//  GameComplete.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-10-25.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class GameComplete: UIViewController {

    //MARK: Create outlets
    
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var PlayAgainButton: UIButton!
    @IBOutlet weak var MenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Disable buttons until game saved or deleted
        PlayAgainButton.isEnabled = false
        MenuButton.isEnabled = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: actions
    @IBAction func SaveClicked(_ sender: AnyObject) {
        //Enable/disable buttons
        PlayAgainButton.isEnabled = true
        MenuButton.isEnabled = true
        SaveButton.isEnabled = false
        DeleteButton.isEnabled = false
        
        //this is how to do stuff before you change screens: "sendIt" is set when segue selected in storyboard
        
        //performSegue(withIdentifier: "sendIt", sender: self)
    }
    
    @IBAction func DeleteClicked(_ sender: Any) {
        //Enable/disable buttons
        PlayAgainButton.isEnabled = true
        MenuButton.isEnabled = true
        SaveButton.isEnabled = false
        DeleteButton.isEnabled = false
    }
   
}
