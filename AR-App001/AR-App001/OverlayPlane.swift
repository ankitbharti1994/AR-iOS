//
//  OverlayPlane.swift
//  AR-App001
//
//  Created by ankit bharti on 13/09/18.
//  Copyright © 2018 Ankit Bharti. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

enum BodyType: Int {
    case Box = 1
    case Plane
}

class OverlayPlane: SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeomatry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        planeGeomatry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = #imageLiteral(resourceName: "overlay_grid.png")
        
        planeGeomatry.materials = [material]
        
        let planeNode = SCNNode(geometry: planeGeomatry)
        
        // add physics
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: planeGeomatry, options: nil))
        planeNode.physicsBody?.categoryBitMask = BodyType.Plane.rawValue
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0)
        
        addChildNode(planeNode)
    }
    
    func update(anchor: ARPlaneAnchor) {
        planeGeomatry.width = CGFloat(anchor.extent.x)
        planeGeomatry.height = CGFloat(anchor.extent.z)
        
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
        
        let node = childNodes.first!
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: planeGeomatry, options: nil))
    }
}
