// File: GameScreen.swift
// Authors: Taylor Traviss, Joey Huang
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class GameScreen: UIViewController {
    //MARK: Variables
    let collector:DataRun = DataRun()
    let gameComplete = GameComplete()
    let ARconfig = ARWorldTrackingConfiguration()
    //let ARconfig = AROrientationTrackingConfiguration()

    //MARK: Outlets
    @IBOutlet weak var StartButton: UIButton!
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    @IBAction func readyButton(_ sender: Any) {
        //start tinmer
        startTimer()
    }
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        StopButton.isEnabled = false
        //enabling debug options for sceneView for now... nothing but camera view with capabilities of AR framework
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        print("Set debug options!")
        
        addTargetNodes()
        playBGM()
        
        
    
    }

    
    //timer
    var timer = Timer()
    var seconds = 30
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTime)), userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
        if seconds == 0 {
            timer.invalidate()
            gameOver()
        }else{
            seconds -= 1
            timeLabel.text = "\(seconds)"
        }
    }
    
    func gameOver(){
        //go back to game complete
        performSegue(withIdentifier:"StopSegue", sender: self)
        
    }
    
    
    
    //target
    func addTargetNodes(){
        
            var node = SCNNode()
                let scene = SCNScene(named: "art.scnassets/mouthshark.dae")
                node = (scene?.rootNode.childNode(withName: "shark", recursively: true)!)!
                node.scale = SCNVector3(1.0,1.0,1.0)
                node.name = "shark"
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            //position
            node.position = SCNVector3(5,0,0)
            
            //rotate
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 5)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            
            //add to scene
            sceneView.scene.rootNode.addChildNode(node)
    }
    
    
    
    func playBGM(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "ukulele.mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        
        audioNode.addAudioPlayer(audioPlayer)
        
        let play = SCNAction.playAudio(audioSource, waitForCompletion: false)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
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
