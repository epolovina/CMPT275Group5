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
    //let objNode = SCNNode()
    private let objNode = SCNNode()
    let collector:DataRun = DataRun()
    fileprivate var sensor_timer: Timer!
    let gameComplete = GameComplete()

    //MARK: Outlets
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        GenerateObject()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
