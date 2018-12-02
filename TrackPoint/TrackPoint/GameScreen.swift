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
    var boundary = SCNNode()
    var pointer = SCNNode()
    var isInside = true
    let debugMode = false
    let boundaryRadius:CGFloat = 4
    //let ARconfig = AROrientationTrackingConfiguration()
    
    enum BodyType:Int{
        case target = 1
        case rocket = 2
        case pointer = 4
        case boundary = 8
        
    }
    
    enum pointerDimensions:CGFloat{
        case width = 0.1
        case height = 0.11
        case length = 15
    }
    
    //MARK: Outlets
    @IBOutlet weak var StopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var readyButton: UIButton!
    @IBOutlet weak var instructionScreen: UIView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var PopUpView: UIView!
    
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
        PopUpView.isHidden = true
        
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
        }else if (isInside){
            seconds -= 1
            //shootObj()
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
        //print("tapped")
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
        
        //create boundary node and make it hidden if not debugging
        let boundaryGeometry:SCNGeometry = SCNSphere(radius: boundaryRadius)
        boundaryGeometry.firstMaterial?.diffuse.contents = UIColor.red
        boundary = SCNNode(geometry: boundaryGeometry)
        if (!debugMode){
            boundary.opacity = 0
        }
        
        //add boundary node to scene and define its physics attributes
        boundary.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: boundary, options: nil))
        boundary.physicsBody?.categoryBitMask = BodyType.boundary.rawValue
        boundary.physicsBody?.contactTestBitMask = BodyType.pointer.rawValue
        boundary.position = SCNVector3(x:0,y:0,z:-5)
        
        sceneView.scene.rootNode.addChildNode(boundary)
        
        //create pointer node and make it hidden if not debugging
        let pointerGeometry:SCNGeometry
        pointerGeometry = SCNBox(width: pointerDimensions.width.rawValue, height: pointerDimensions.height.rawValue, length: pointerDimensions.length.rawValue, chamferRadius: 0)
        pointerGeometry.firstMaterial?.diffuse.contents = UIColor.green
        pointer = SCNNode(geometry: pointerGeometry)
        if (!debugMode){
            pointer.opacity = 0
        }
        //attach pointer node to camera and define its physics attributes
        pointer.position = SCNVector3(x:0,y:0,z:-5)
        //pointer.rotation = SCNVector4(x: 1, y: 0, z: 0, w: Float(Double.pi / 4))
        pointer.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: pointer, options: nil))
        pointer.physicsBody?.categoryBitMask = BodyType.pointer.rawValue
        pointer.physicsBody?.contactTestBitMask = BodyType.boundary.rawValue
        
        sceneView.pointOfView?.addChildNode(pointer)
    
    }
    
    //Test if the contact is between the two specified objects
    func testContactBetween(contact: SCNPhysicsContact, nodeA: BodyType, nodeB:BodyType) -> Bool {
        return (contact.nodeA.physicsBody?.categoryBitMask == nodeA.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == nodeB.rawValue) || (contact.nodeA.physicsBody?.categoryBitMask == nodeB.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == nodeA.rawValue)
    }
    
    //returns the length of the distance between contact point and center of specified node
    func calculateDistanceToContact(contact: SCNPhysicsContact, node: SCNNode) -> CGFloat {
        let distanceVector = SCNVector3(contact.contactPoint.x - node.position.x, contact.contactPoint.y - node.position.y, contact.contactPoint.z - node.position.z)
        let length : CGFloat = CGFloat(sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y + distanceVector.z * distanceVector.z))
        return length
    }

    //contact detection
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        //handle rocket and target collison
        if (testContactBetween(contact: contact, nodeA: BodyType.target, nodeB: BodyType.rocket)){
            //print("Collision")
            let explodeAnimation = SCNParticleSystem(named:"Explosion", inDirectory:"art.scnassets")
            playExplosion()
            contact.nodeB.addParticleSystem(explodeAnimation!)
            contact.nodeA.removeFromParentNode() //remove rocket
        }
        
        //handle out of bounds condition
        else if (testContactBetween(contact: contact, nodeA: BodyType.pointer, nodeB: BodyType.boundary)){
            //calculate distance between contact point and center of boundary sphere
            let length = calculateDistanceToContact(contact: contact, node: boundary);
            if (length < boundaryRadius && isInside == false){
                isInside = true
                //halt data collection when out of bounds
                collector.resume()
                PopUpView.isHidden = true
                print("Back into playable area, data collection resumed!")
                
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        //handle out of bounds condition
        if (testContactBetween(contact: contact, nodeA: BodyType.pointer, nodeB: BodyType.boundary)){
            //calculate distance between contact point and center of boundary sphere
            let length = calculateDistanceToContact(contact: contact, node: boundary);
            if (length > boundaryRadius && isInside == true){
                isInside = false
                //halt data collection when out of bounds
                collector.suspend()
                PopUpView.isHidden = false
                print("Out of bounds, data collection stopped!")
                    
                
            }
        }
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


