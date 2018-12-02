// File: GameComplete.swift
// Authors: Taylor Traviss
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class GameComplete: UIViewController {
    
    private let collector:DataRun = DataRun.shared()
    let DB = Database.DB
    

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
        
        let borderColour = UIColor(red: 125/255, green: 18/255, blue: 81/255, alpha: 1)
        SaveButton.layer.borderColor = borderColour.cgColor
        SaveButton.layer.borderWidth = 2
        DeleteButton.layer.borderColor = borderColour.cgColor
        DeleteButton.layer.borderWidth = 2
        PlayAgainButton.layer.borderColor = borderColour.cgColor
        PlayAgainButton.layer.borderWidth = 4
        MenuButton.layer.borderColor = borderColour.cgColor
        MenuButton.layer.borderWidth = 4

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
        
        // print processed data
        print("Accel\nFreq: \(pdata[0].1), Pow: \(pdata[0].2)\n")
        print("Gyro\nFreq: \(pdata[1].1), Pow: \(pdata[1].2)\n")
        
        // send score and date to database
        let timestamp:Date = collector.getDate() ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let strDate = dateFormatter.string(from: timestamp)
        DB.dateArray.append(strDate)
        DB.scoreArray.append(pdata[1].1)
        DB.saveScore()
        
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
