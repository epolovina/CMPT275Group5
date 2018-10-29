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
    @IBOutlet weak var PlayAgainButton: UIButton!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var DeleteButton: UIButton!
    @IBOutlet weak var MenuButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Disable buttons until game saved or deleted
        PlayAgainButton.isEnabled = false
        MenuButton.isEnabled = false

    }
    
    //MARK: actions
    @IBAction func SaveClicked(_ sender: Any) {
        //Enable buttons
        PlayAgainButton.isEnabled = true
        MenuButton.isEnabled = true
    }
    
    @IBAction func DeleteClicked(_ sender: Any) {
        //Enable buttons
        PlayAgainButton.isEnabled = true
        MenuButton.isEnabled = true
    }
   
}
