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
    let collector:DataRun = DataRun()
       fileprivate var sensor_timer: Timer!

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
        //sensor_timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.updateLabels), userInfo: nil, repeats: true)
    }

    @IBAction func StopClicked(_ sender: Any) {
        collector.end()
        //sensor_timer.invalidate();
        performSegue(withIdentifier: "StopSegue", sender: self)
    }
    
    
    @objc fileprivate  func updateLabels(){
        let curr_data = collector.get_last_entry();
        let aX = curr_data[0].0
        let aY = curr_data[0].1
        let aZ = curr_data[0].2
        let rX = curr_data[1].0
        let rY = curr_data[1].1
        let rZ = curr_data[1].2
        //Updates the labels
        self.accelX.text = String(format:"%.4f", aX)
        self.accelY.text = String(format:"%.4f", aY)
        self.accelZ.text = String(format:"%.4f", aZ)
        self.rotateX.text = String(format:"%.4f", rX)
        self.rotateY.text = String(format:"%.4f", rY)
        self.rotateZ.text = String(format:"%.4f", rZ)
        print(curr_data[0])
    }
    
}
