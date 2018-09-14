//
//  Missile.swift
//  ARKit002
//
//  Created by Ankit Kumar Bharti on 14/09/18.
//  Copyright © 2018 Exilant. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class Missile: SCNNode {
    
    let scene: SCNScene
    
    init(scene: SCNScene) {
        self.scene = scene
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        guard let missileNode = scene.rootNode.childNode(withName: "missileNode", recursively: true), let smokeNode = scene.rootNode.childNode(withName: "smokeNode", recursively: true) else {
            fatalError("Node not found")
        }
        
        guard let smoke = SCNParticleSystem(named: "smoke.scnp", inDirectory: nil) else { return }
        smokeNode.addParticleSystem(smoke)
        
        addChildNode(missileNode)
        addChildNode(smokeNode)
    }
}
