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
    var innerBoundary = SCNNode()
    var pointer = SCNNode()
    var isInside = true
    var isInsideInner = true;
    let debugMode = true
    let sceneURL = "Models.scnassets/test.scn"
    let initialDelay:TimeInterval = 3
    let initialPosition = SCNVector3(0, 0, -10)
    let lightPosition = SCNVector3(1.5, 1.5, 1.5)
    let boundaryRadius:CGFloat = 5
    let innerBoundaryRadius:CGFloat = 2
    let collector:DataRun = DataRun()
    let physicsWorld = SCNPhysicsWorld()
    fileprivate var updatePositionTimer: Timer!
    
    
    //MARK: Structs and Enums
    enum category:Int{
        case box = 1
        case boundary = 2
        case innerBoundary = 4
        case pointer = 8
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
    
    //Test if the contact is between the two specified objects
    func testContactBetween(contact: SCNPhysicsContact, nodeA: category, nodeB:category) -> Bool {
        return (contact.nodeA.physicsBody?.categoryBitMask == nodeA.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == nodeB.rawValue) || (contact.nodeA.physicsBody?.categoryBitMask == nodeB.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == nodeA.rawValue)
    }
    
    //returns the length of the distance between contact point and center of specified node
    func calculateDistanceToContact(contact: SCNPhysicsContact, node: SCNNode) -> CGFloat {
        let distanceVector = SCNVector3(contact.contactPoint.x - node.position.x, contact.contactPoint.y - node.position.y, contact.contactPoint.z - node.position.z)
        let length : CGFloat = CGFloat(sqrtf(distanceVector.x * distanceVector.x + distanceVector.y * distanceVector.y + distanceVector.z * distanceVector.z))
        return length
    }
    
    //Tests for and handles out of bounds condition
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
    
        //calculate distance between contact point and center of boundary sphere
        let length = calculateDistanceToContact(contact: contact, node: boundary);
        
        //calculate distance between contact point and center of inner boundary sphere
        let innerLength = calculateDistanceToContact(contact: contact, node: innerBoundary)

        // Only consider update if contact point is outside innerBoundary and was previously inside
        if (innerLength > innerBoundaryRadius && isInsideInner == true){
            isInsideInner = false
            if (testContactBetween(contact: contact, nodeA: category.innerBoundary, nodeB: category.pointer)){
                print ("inner boundary contact ended")
                print("Out of inner bounds, halt animation!")
                
            }
        }
        
        //Only consider contact update if the contact point is outside boundary and pointer was previously within bounds
        if (length > boundaryRadius && isInside == true){
            isInside = false
            if (testContactBetween(contact: contact, nodeA: category.boundary, nodeB: category.pointer)){
                
                //halt data collection when out of bounds
                collector.suspend()
                print ("outer boundary contact ended")
                print("Out of bounds, data collection stopped!")
                
            }
        }
    }
    
    //Tests for and handles within bounds condition
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        
        //calculate distance between contact point and center of boundary sphere
        let length = calculateDistanceToContact(contact: contact, node: boundary)
        
        //calculate distance between contact point and center of inner boundary sphere
        let innerLength = calculateDistanceToContact(contact: contact, node: innerBoundary)
        
        // Only consider update if contact point is inside innerBoundary and was previously inside
        if (innerLength < innerBoundaryRadius && isInsideInner == false){
            isInsideInner = true
            if (testContactBetween(contact: contact, nodeA: category.innerBoundary, nodeB: category.pointer)){
                
                print ("inner boundary contact began")
                print("Inside of inner bounds, start animation!")
            }
        }
        // (if inside inner boundary, skip check for outer boundary) Only consider contact update if the contact point is inside boundary and object was previously out of bounds
        else if (length < boundaryRadius && isInside == false){
            isInside = true
            if (testContactBetween(contact: contact, nodeA: category.boundary, nodeB: category.pointer)){
                
                //resume data collection once within bounds
                collector.resume()
                print ("contact happened")
                print("Inside playable area, but animation is disabled!")
                
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
        sceneView.scene.rootNode.addChildNode(boundary)
        
        //create inner boundary node and make it hidden if not debugging
        let innerBoundaryGeometry:SCNGeometry = SCNSphere(radius: innerBoundaryRadius)
        innerBoundaryGeometry.firstMaterial?.diffuse.contents = UIColor.blue
        innerBoundary = SCNNode(geometry: innerBoundaryGeometry)
        if (!debugMode){
            innerBoundary.isHidden = true;
        }
        
        //add inner boundary node to scene and define its physics attributes
        innerBoundary.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: innerBoundary, options: nil))
        innerBoundary.physicsBody?.categoryBitMask = category.innerBoundary.rawValue
        innerBoundary.physicsBody?.contactTestBitMask = category.pointer.rawValue
        innerBoundary.position = initialPosition
        sceneView.scene.rootNode.addChildNode(innerBoundary)

        
        
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
        pointer.physicsBody?.contactTestBitMask = category.boundary.rawValue | category.innerBoundary.rawValue
        
        
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
