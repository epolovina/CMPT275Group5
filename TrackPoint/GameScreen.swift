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
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var instructionScreen: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBAction func readyButton(_ sender: Any) {
        startTimer()
        playBGM() //music
        collector.start() //collect data api
        instructionScreen.isHidden = true;
        readyButton.isHidden = true;
        sceneView.session.run(ARconfig) //start the AR session
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTargetNodes()
        StopButton.isHidden=true //hide stop button..easier to do segue
        
    }

    
    
    //timer
    var timer = Timer()
    var seconds = 15
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(self.updateTime)), userInfo: nil, repeats: true)
    }
    @objc func updateTime() {
        if seconds == 0 {
            timer.invalidate()
            removeAudioPlayer()
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
                let scene = SCNScene(named: "art.scnassets/shark.dae")
                node = (scene?.rootNode.childNode(withName: "shark", recursively: true)!)! //press the obj and scenegraph
                node.scale = SCNVector3(1.0,1.0,1.0)
                node.name = "monster"
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            
            //position
            node.position = SCNVector3(10,0,0)
            
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
    func removeAudioPlayer(){
         sceneView.scene.rootNode.removeAllAudioPlayers()
    }
  
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // start data recording and label update timer


    // stop data recording and label update timer
    @IBAction func StopClicked(_ sender: Any) {
        collector.end()
        sceneView.session.pause() //pauses processing in the session
        //performSegue(withIdentifier: "StopSegue", sender: self)
        //self.present(gameComplete, animated: true, completion: nil)
    }
    
    
}
