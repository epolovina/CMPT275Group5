// File: MainMenu.swift
// Authors: Taylor Traviss
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class MainMenu: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressButton: UIButton!
    @IBOutlet weak var profileButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoImage.layer.cornerRadius = logoImage.frame.size.width / 2
        logoImage.clipsToBounds = true
        let borderColour = UIColor(red: 125/255, green: 18/255, blue: 81/255, alpha: 1)
        logoImage.layer.borderColor = borderColour.cgColor
        logoImage.layer.borderWidth = 4
        
        profileButton.layer.borderColor = borderColour.cgColor
        profileButton.layer.borderWidth = 2
        
        progressButton.layer.borderColor = borderColour.cgColor
        progressButton.layer.borderWidth = 2
        
        playButton.layer.borderColor = borderColour.cgColor
        playButton.layer.borderWidth = 4
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setBorder(){
        
    }
}
