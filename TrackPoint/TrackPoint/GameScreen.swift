// File: GameScreen.swift
// Authors: Taylor Traviss, Joey Huang, Khalil Ammar
//
//  Copyright © 2018 Pit Bulls. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class GameScreen: UIViewController , ARSCNViewDelegate, SCNPhysicsContactDelegate {
    
    //MARK: Variables
    var box = SCNNode()
    var boundary = SCNNode()
    var pointer = SCNNode()
    var isInside = true
    let debugMode = true
    let sceneURL = "Models.scnassets/test.scn"
    let initialDelay:TimeInterval = 3
    let initialPosition = SCNVector3(0, 0, -10)
    let lightPosition = SCNVector3(1.5, 1.5, 1.5)
    let boundaryRadius:CGFloat = 5
    let collector:DataRun = DataRun()
    fileprivate var updatePositionTimer: Timer!
    
    
    //MARK: Structs and Enums
    enum category:Int{
        case box = 1
        case boundary = 2
        case pointer = 4
    }
    
    enum pointerDimensions:CGFloat{
        case width = 0.1
        case height = 0.11
        case length = 15
    }

    //MARK: Outlets
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        stopButton.isEnabled = false
        
        //show statistics such as fps
        sceneView.showsStatistics = true
        
        //create scene
        let scene = SCNScene(named: sceneURL)!
        
        //assign scene to sceneView
        sceneView.scene = scene
        
        //allow current view to handle contact detection
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //create configuration and run session
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //pause scene view session
        sceneView.session.pause()
    }
    
    //Tests for and handles out of bounds condition
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        
        //calculate distance between contact point and center of boundary sphere
        let distanceVector = SCNVector3(contact.contactPoint.x - boundary.position.x, contact.contactPoint.y - boundary.position.y, contact.contactPoint.z - boundary.position.z)
        let length : CGFloat = CGFloat(sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y + distanceVector.z * distanceVector.z))
        
        //Only consider contact update if the contact point is outside boundary and pointer was previously within bounds
        if (length > boundaryRadius && isInside == true){
            isInside = false
            if ( (contact.nodeA.physicsBody?.categoryBitMask == category.boundary.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.pointer.rawValue) || (contact.nodeA.physicsBody?.categoryBitMask == category.pointer.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.boundary.rawValue) ){
                
                //halt data collection when out of bounds
                collector.suspend()
                print ("contact ended")
                print("Out of bounds, data collection stopped!")
                
            }
        }
    }
    
    //Tests for and handles within bounds condition
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        //calculate distance between contact point and center of boundary sphere
        let distanceVector = SCNVector3(contact.contactPoint.x - boundary.position.x, contact.contactPoint.y - boundary.position.y, contact.contactPoint.z - boundary.position.z)
        let length : CGFloat = CGFloat(sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y + distanceVector.z * distanceVector.z))
        
        //Only consider contact update if the contact point is inside boundary and object was previously out of bounds
        if (length < boundaryRadius && isInside == false){
            isInside = true
            if ( (contact.nodeA.physicsBody?.categoryBitMask == category.boundary.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.pointer.rawValue) || (contact.nodeA.physicsBody?.categoryBitMask == category.pointer.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.boundary.rawValue) ){
                
                //resume data collection once within bounds
                collector.resume()
                print ("contact happened")
                print("Back into playable area, data collection resumed!")
                
            }
        }
    }
    
    // add objects and lights to current scene
    func setupScene(){
        //find box node and define its physics attributes
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
            if (node.name == "Box" ){
                box = node
                box.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: box, options: nil))
                box.physicsBody?.categoryBitMask = category.box.rawValue
                box.position = initialPosition
            }
        }
        
        
        //create boundary node and make it hidden if not debugging
        let boundaryGeometry:SCNGeometry = SCNSphere(radius: boundaryRadius)
        boundaryGeometry.firstMaterial?.diffuse.contents = UIColor.red
        boundary = SCNNode(geometry: boundaryGeometry)
        if (!debugMode){
            boundary.isHidden = true;
        }
        
        //add boundary node to scene and define its physics attributes
        boundary.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: boundary, options: nil))
        boundary.physicsBody?.categoryBitMask = category.boundary.rawValue
        boundary.physicsBody?.contactTestBitMask = category.pointer.rawValue
        boundary.position = initialPosition
        
        
        //create pointer node and make it hidden if not debugging
        let pointerGeometry:SCNGeometry
        pointerGeometry = SCNBox(width: pointerDimensions.width.rawValue, height: pointerDimensions.height.rawValue, length: pointerDimensions.length.rawValue, chamferRadius: 0)
        pointerGeometry.firstMaterial?.diffuse.contents = UIColor.green
        pointer = SCNNode(geometry: pointerGeometry)
        if (!debugMode){
            pointer.isHidden = true;
        }
        //attach pointer node to camera and define its physics attributes
        sceneView.pointOfView?.addChildNode(pointer)
        pointer.position = initialPosition
        pointer.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: pointer, options: nil))
        pointer.physicsBody?.categoryBitMask = category.pointer.rawValue
        pointer.physicsBody?.contactTestBitMask = category.boundary.rawValue
        
        
        //add light to scene
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = lightPosition
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        // start data collection
        collector.start()

    }
    
    //TODO: popup tutorial after pressing start
    
    //handles pressing on START button
    @IBAction func didPressStart(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        
        //create action sequence
        let wait:SCNAction = SCNAction.wait(duration: initialDelay)
        let startGame:SCNAction = SCNAction.run{ _ in
            self.setupScene()
        }
        
        // delay by "initialDelay" seconds and then start game
        let actionSequence:SCNAction = SCNAction.sequence([wait, startGame])
        self.sceneView.scene.rootNode.runAction(actionSequence)
    }
    
    //TODO: replace stop button with countdown
    
    //handles pressing on STOP button
    @IBAction func didPressStop(_ sender: Any) {
        sceneView.stop(Any?.self)
    }
    
}
