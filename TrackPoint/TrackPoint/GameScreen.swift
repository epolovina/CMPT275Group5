//
//  GameScreen.swift
//  TrackPoint
//
//  Created by Taylor Traviss on 2018-10-24.
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class GameScreen: UIViewController  {
    //MARK: Variables
    let collector = DataRun()

    //MARK: Outlets
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var accelX: UILabel!
    @IBOutlet weak var accelY: UILabel!
    @IBOutlet weak var accelZ: UILabel!
    @IBOutlet weak var rotateX: UILabel!
    @IBOutlet weak var rotateY: UILabel!
    @IBOutlet weak var rotateZ: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: Actions
    @IBAction func StartClicked(_ sender: Any) {
        collector.start()
    }

    @IBAction func StopClicked(_ sender: Any) {
        collector.end()
        performSegue(withIdentifier: "StopSegue", sender: self)
    }
    
    
    func updateLabels(aX: Double, aY: Double, aZ: Double,
                      rX: Double, rY: Double, rZ: Double){
        //Updates the labels
        self.accelX.text = String(format:"%.4f", aX)
        self.accelY.text = String(format:"%.4f", aY)
        self.accelZ.text = String(format:"%.4f", aZ)
        self.rotateX.text = String(format:"%.4f", rX)
        self.rotateY.text = String(format:"%.4f", rY)
        self.rotateZ.text = String(format:"%.4f", rZ)
    }
    
}
