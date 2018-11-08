// File: GameScreen.swift
// Authors: Taylor Traviss, Joey Huang
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import ARKit

class GameScreen: UIViewController  {
    //MARK: Variables
    let collector:DataRun = DataRun()
    let gameComplete = GameComplete()
    let ARconfig = ARWorldTrackingConfiguration()

    //MARK: Outlets
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StopButton.isEnabled = false
        
        //enabling debug options for sceneView for now... nothing but camera view with capabilities of AR framework
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        print("Set debug options!")
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
        sceneView.session.run(ARconfig) //start the AR session
    }

    // stop data recording and label update timer
    @IBAction func StopClicked(_ sender: Any) {
        collector.end()
        sceneView.session.pause() //pauses processing in the session
        //performSegue(withIdentifier: "StopSegue", sender: self)
        //self.present(gameComplete, animated: true, completion: nil)
    }
    
    
}
