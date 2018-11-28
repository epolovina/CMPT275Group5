// File: GameScreen.swift
// Authors: Taylor Traviss, Joey Huang
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class GameScreen: UIViewController, SCNPhysicsContactDelegate {
    //MARK: Variables
    let collector:DataRun = DataRun.shared()
    private var sensor_timer: Timer!
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
        
        sceneView.scene.physicsWorld.contactDelegate = self //contact physics
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            shootObj()
            playCannon()
            timeLabel.text = "\(seconds)"
        }
    }
    
    func gameOver(){
        //go back to game complete
        performSegue(withIdentifier:"StopSegue", sender: self)
    }
    
    //shooting laser
    func shootObj() {
        
        let scene = SCNScene(named: "art.scnassets/rocketship.scn")
        let rocketNode = (scene?.rootNode.childNode(withName: "rocketship", recursively: false)!)! //press the obj and scenegraph
        // laserNode.camera.
        print("tapped")
        //shape
        
        
        //let physicsSchape = SCNPhysicsShape(node: rocketNode, options:nil) //not sure if need
        
        //physics
        //   let laserShape = SCNPhysicsShape(geometry: laser, options: nil)
        rocketNode.pivot = SCNMatrix4MakeRotation(.pi/4, 1, 0, 0) //flip rocket 45 deg
        rocketNode.physicsBody = SCNPhysicsBody(type:.dynamic, shape:nil)
        rocketNode.physicsBody?.isAffectedByGravity = false
        
        rocketNode.scale = SCNVector3(0.05,0.05,0.05)
        
        //collision. not really necessary
        rocketNode.physicsBody?.categoryBitMask = BodyType.rocket.rawValue //identifier
        rocketNode.physicsBody?.collisionBitMask = BodyType.target.rawValue //ball collides with this
        rocketNode.physicsBody?.contactTestBitMask = BodyType.target.rawValue
        
        let ignitionAnimation = SCNParticleSystem(named:"reactor", inDirectory:"art.scnassets") //add the shooting effect
        rocketNode.addParticleSystem(ignitionAnimation!)
        
        
        //determining camera location
        guard let sceneFrame = self.sceneView.session.currentFrame else{ return}
        let camTransform = SCNMatrix4(sceneFrame.camera.transform)
        
        let camLocation = SCNVector3(x:camTransform.m41, y:camTransform.m42, z:camTransform.m43) //location
        let camOrientation = SCNVector3(x: -camTransform.m31, y: -camTransform.m32, z: -camTransform.m33)//orientaton numbers refer to location on matrix. camera inversed
        
        let camPosition = SCNVector3Make(camLocation.x+camOrientation.x,camLocation.y+camOrientation.y,camLocation.z+camOrientation.z) //combinig both = middle of screen
        
        //shooting comes from user camera
        rocketNode.position = camPosition
        
        //give laser force
        let force:Float = 3 //how much force
        rocketNode.physicsBody?.applyForce(SCNVector3(x:camPosition.x * force ,y:camPosition.y * force,z:camPosition.z * force), asImpulse: true)
        sceneView.scene.rootNode.addChildNode(rocketNode)
    }
    
    
    //target
    func addTargetNodes(){
        var targetNode = SCNNode()
        let scene = SCNScene(named: "art.scnassets/planet/planet.scn")
        targetNode = (scene?.rootNode.childNode(withName: "Mars_Cube_002", recursively: true)!)! //press the obj and scenegraph
        
        
        //size
        targetNode.scale = SCNVector3(0.25,0.25,0.25)
        
        //physics
        //let physicsSchape = SCNPhysicsShape(node:targetNode, options:nil)
        targetNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil) //don't move when hit
        targetNode.physicsBody?.isAffectedByGravity = false
        
        //contact detection
        targetNode.physicsBody?.categoryBitMask = BodyType.target.rawValue //identifier
        targetNode.physicsBody?.collisionBitMask = BodyType.rocket.rawValue //ball collides with this
        targetNode.physicsBody?.contactTestBitMask = BodyType.rocket.rawValue
        
        //position
        targetNode.position = SCNVector3(x:0,y:0,z:-5) //5 meters away from phone
        
        //add to scene
        sceneView.scene.rootNode.addChildNode(targetNode)
    
    }
    
    //contact detection
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        print("Collision")
        let explodeAnimation = SCNParticleSystem(named:"Explosion", inDirectory:"art.scnassets")
        playExplosion()
        contact.nodeB.addParticleSystem(explodeAnimation!)
        contact.nodeA.removeFromParentNode() //remove rocket
    }
    
    func playBGM(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "Sounds/ukulele.mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        audioNode.addAudioPlayer(audioPlayer)
        let play = SCNAction.playAudio(audioSource, waitForCompletion: false)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
    func playCannon(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "Sounds/Cannon.mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        audioNode.addAudioPlayer(audioPlayer)
        let play = SCNAction.playAudio(audioSource, waitForCompletion: false)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
    func playExplosion(){
        let audioNode = SCNNode()
        let audioSource = SCNAudioSource(fileNamed: "Sounds/Explosion.mp3")!
        let audioPlayer = SCNAudioPlayer(source: audioSource)
        audioNode.addAudioPlayer(audioPlayer)
        let play = SCNAction.playAudio(audioSource, waitForCompletion: false)
        audioNode.runAction(play)
        sceneView.scene.rootNode.addChildNode(audioNode)
    }
    
    func removeAudioPlayer(){
        sceneView.scene.rootNode.removeAllAudioPlayers()
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

enum BodyType:Int{
    case target=1
    case rocket=2
    
}
