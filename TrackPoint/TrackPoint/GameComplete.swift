// File: GameComplete.swift
// Authors: Taylor Traviss
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class GameComplete: UIViewController {
    private let collector:DataRun = DataRun.shared()
    

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
    
    // Save session data
    @IBAction func SaveClicked(_ sender: AnyObject) {
        //Enable/disable buttons
        PlayAgainButton.isEnabled = true
        MenuButton.isEnabled = true
        SaveButton.isEnabled = false
        DeleteButton.isEnabled = false
        
        collector.save()
        let pdata = collector.processAll()
        print("Accel\nFreq: \(pdata[0].1), Pow: \(pdata[0].2)\n")
        print("Gyro\nFreq: \(pdata[1].1), Pow: \(pdata[1].2)\n")
        
        //this is how to do stuff before you change screens: "sendIt" is set when segue selected in storyboard
        
        //performSegue(withIdentifier: "sendIt", sender: self)
    }
    
    // Delete session data
    @IBAction func DeleteClicked(_ sender: Any) {
        //Enable/disable buttons
        PlayAgainButton.isEnabled = true
        MenuButton.isEnabled = true
        SaveButton.isEnabled = false
        DeleteButton.isEnabled = false
    }
   
}
