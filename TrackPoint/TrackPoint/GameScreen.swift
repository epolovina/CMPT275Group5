// File: GameScreen.swift
// Authors: Taylor Traviss, Joey Huang
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
    var isInside:Bool = true
    let initialDelay:TimeInterval = 3
    let initialPosition = SCNVector3(0, 0, -10)
    let initialPointerPosition = SCNVector3(0, 0, -10)
    let collector:DataRun = DataRun()
    fileprivate var updatePositionTimer: Timer!
    let gameComplete = GameComplete()
    
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    enum category:Int{
        case box = 1
        case boundary = 2
        case pointer = 4
    }
    
    struct userCameraCoordinates {
        var x = Float()
        var y = Float()
        var z = Float()
    }

    //MARK: Outlets
    
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
        let scene = SCNScene(named: "Models.scnassets/test.scn")!
        
        //assign scene to sceneView
        sceneView.scene = scene
        
        
        sceneView.scene.physicsWorld.contactDelegate = self
        
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        let distance = SCNVector3(contact.contactPoint.x - boundary.position.x, contact.contactPoint.y - boundary.position.y, contact.contactPoint.z - boundary.position.z)
        let length : Float = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
        if (length > 3 && isInside == true){
            isInside = false
            print ("contact ended")
            if ( (contact.nodeA.physicsBody?.categoryBitMask == category.boundary.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.pointer.rawValue) || (contact.nodeA.physicsBody?.categoryBitMask == category.pointer.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.boundary.rawValue) ){
                //halt data collection when out of bounds
                collector.suspend()
                print("Out of bounds, data collection stopped!")
                
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let distance = SCNVector3(contact.contactPoint.x - boundary.position.x, contact.contactPoint.y - boundary.position.y, contact.contactPoint.z - boundary.position.z)
        let length : Float = sqrtf(distance.x * distance.x + distance.y * distance.y + distance.z * distance.z)
        
        if (length < 3 && isInside == false){
            isInside = true
            print ("contact happened")
            if ( (contact.nodeA.physicsBody?.categoryBitMask == category.boundary.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.pointer.rawValue) || (contact.nodeA.physicsBody?.categoryBitMask == category.pointer.rawValue &&  contact.nodeB.physicsBody?.categoryBitMask == category.boundary.rawValue) ){
                collector.resume()
                print("Back into playable area, data collection resumed!")
                
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //create configuration and run session
        let config = ARWorldTrackingConfiguration()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        //ARSCNDebugOptions.showFeaturePoints, SCNDebugOptions.showPhysicsShapes]
        sceneView.session.run(config)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //pause scene view session
        sceneView.session.pause()
    }
    
    // add objects and lights
    func setupScene(){
        //find box node and define its physical attributes
        self.sceneView.scene.rootNode.enumerateChildNodes{ (node,_) in
            if (node.name == "Box" ){
                print("Found box node")
                box = node
                box.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: box, options: nil))
                box.physicsBody?.categoryBitMask = category.box.rawValue
                box.position = initialPosition
            }
            if (node.name == "boundarySphere"){
                print("Found boundary node")
                boundary = node
                boundary.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: boundary, options: nil))
                boundary.physicsBody?.categoryBitMask = category.boundary.rawValue
                boundary.physicsBody?.contactTestBitMask = category.pointer.rawValue
                boundary.position = initialPosition
            }
//            if (node.name == "Pointer"){
//                print("Found pointer node")
//                pointer = node
//                pointer.removeFromParentNode()
//                sceneView.pointOfView?.addChildNode(pointer)
//                pointer.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: pointer, options: nil))
//                pointer.physicsBody?.categoryBitMask = category.pointer.rawValue
//                pointer.physicsBody?.contactTestBitMask = category.boundary.rawValue
//                pointer.position = initialPointerPosition
//                //rotate around z-axis by pi/2
//                //pointer.pivot = SCNMatrix4MakeRotation(Float(CGFloat(Double.pi / 2)), 0, 0, 1)
//                //updatePositionTimer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(self.updatePointerPosition), userInfo: nil, repeats: true)
//            }
            
            
        }
        //add pointer node and attach it to camera
        var pointerGeometry:SCNGeometry
        pointerGeometry = SCNBox(width: 0.1, height: 0.1, length: 15, chamferRadius: 0)
        pointerGeometry.firstMaterial?.diffuse.contents = UIColor.green
        pointer = SCNNode(geometry: pointerGeometry)
        
        //pointer.orientation = (sceneView.pointOfView?.orientation)!
        //sceneView.scene.rootNode.addChildNode(pointer)
        sceneView.pointOfView?.addChildNode(pointer)
        pointer.position = initialPointerPosition
        //pointer.pivot = SCNMatrix4MakeRotation(Float(CGFloat(Double.pi / 4)), 1, 0, 0)
        pointer.physicsBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(node: pointer, options: nil))
        pointer.physicsBody?.categoryBitMask = category.pointer.rawValue
        pointer.physicsBody?.contactTestBitMask = category.boundary.rawValue
        
        // start data collection
        collector.start()
        
        //add light to scene
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(1.5, 1.5, 1.5)
        sceneView.scene.rootNode.addChildNode(lightNode)
    }
    
    @IBAction func didPressStart(_ sender: Any) {
        startButton.isEnabled = false
        stopButton.isEnabled = true
        let wait:SCNAction = SCNAction.wait(duration: initialDelay)
        let startGame:SCNAction = SCNAction.run{ _ in
            self.setupScene()
        }
        // delay by "initialDelay" seconds and then start game
        let actionSequence:SCNAction = SCNAction.sequence([wait, startGame])
        self.sceneView.scene.rootNode.runAction(actionSequence)
    }
    
    @IBAction func didPressStop(_ sender: Any) {
        sceneView.stop(Any?.self)
    }
    
    func getCameraCoordinates(sceneView: ARSCNView) -> userCameraCoordinates {
        let cameraTransform = sceneView.session.currentFrame?.camera.transform
        let cameraCoordinates = MDLTransform(matrix: cameraTransform!)
        
        var cc = userCameraCoordinates()
        cc.x = cameraCoordinates.translation.x
        cc.y = cameraCoordinates.translation.y
        cc.z = cameraCoordinates.translation.z
        
        return cc
    }
    
    @objc func updatePointerPosition(){
        let cc : userCameraCoordinates = getCameraCoordinates(sceneView: sceneView)
        pointer.position = SCNVector3(cc.x, cc.y, cc.z)
    }
    

    
    
    
    
    
    
    
    
    
    func GenerateObject(){
        let objNode = SCNNode()
        objNode.position = SCNVector3(0,0,2)
        guard let virtualObjScene = SCNScene(named: "deathStar.scn", inDirectory: "Models.scnassets/deathStar")
            else{
                return
        }
        
        let wrapperNode = SCNNode()
        
        for child in virtualObjScene.rootNode.childNodes{
            child.geometry?.firstMaterial?.lightingModel = .physicallyBased
            wrapperNode.addChildNode(child)
            
        }
        objNode.addChildNode(wrapperNode)
        sceneView.scene.rootNode.addChildNode(objNode)
        
        
    }
    
  
    
    
}
