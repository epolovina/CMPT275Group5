// File: GameScreen.swift
// Authors: Taylor Traviss, Joey Huang
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit

class GameScreen: UIViewController  {
    //MARK: Variables
    private let collector:DataRun = DataRun.shared()
    private var sensor_timer: Timer!
    private let gameComplete = GameComplete()

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
        StopButton.isEnabled = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // start data recording and label update timer
    @IBAction func StartClicked(_ sender: Any) {
        StopButton.isEnabled = true
        StartButton.isEnabled = false
        collector.start()
        sensor_timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.updateLabels), userInfo: nil, repeats: true)
    }

    // stop data recording and label update timer
    @IBAction func StopClicked(_ sender: Any) {
        collector.end()
        sensor_timer.invalidate();
        //performSegue(withIdentifier: "StopSegue", sender: self)
        //self.present(gameComplete, animated: true, completion: nil)
    }
    
    // timerfunc updates labels with current sensor data
    @objc fileprivate  func updateLabels(){
        let curr_data = collector.get_last_entry();
        let aX = curr_data[0].0
        let aY = curr_data[0].1
        let aZ = curr_data[0].2
        let rX = curr_data[1].0
        let rY = curr_data[1].1
        let rZ = curr_data[1].2
        //Updates the labels
        self.accelX.text = String(format:"%6.3lf", aX)
        self.accelY.text = String(format:"%6.3lf", aY)
        self.accelZ.text = String(format:"%6.3lf", aZ)
        self.rotateX.text = String(format:"%6.3lf", rX)
        self.rotateY.text = String(format:"%6.3lf", rY)
        self.rotateZ.text = String(format:"%6.3lf", rZ)
        //print(curr_data[0])
    }
    
}
