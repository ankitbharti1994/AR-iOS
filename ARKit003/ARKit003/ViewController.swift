//
//  ViewController.swift
//  ARKit003
//
//  Created by Ankit Kumar Bharti on 17/09/18.
//  Copyright © 2018 Exilant. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

enum BoxBodyType: Int {
    case bullet = 1
    case barrier
}

class ViewController: UIViewController {

    private var sceneView: ARSCNView!
    private var lastContactNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        placeBoxes()
        registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: .resetTracking)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    private func setupAR() {
        sceneView = ARSCNView(frame: view.bounds)
        sceneView.debugOptions = [.showFeaturePoints]
        view.addSubview(sceneView)
        
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    private func placeBoxes() {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        
        box.materials = [material]
        
        let node1 = SCNNode(geometry: box)
        let node2 = SCNNode(geometry: box)
        let node3 = SCNNode(geometry: box)
        
        node1.position = SCNVector3(-0.5, 0, -0.5)
        node2.position = SCNVector3(0, 0, -0.5)
        node3.position = SCNVector3(0.5, 0, -0.5)

        node1.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node2.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        node3.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        
        node1.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        node2.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        node3.physicsBody?.categoryBitMask = BoxBodyType.barrier.rawValue
        
        node1.name = "Barrier 1"
        node2.name = "Barrier 2"
        node3.name = "Barrier 3"

        sceneView.scene.rootNode.addChildNode(node1)
        sceneView.scene.rootNode.addChildNode(node2)
        sceneView.scene.rootNode.addChildNode(node3)
    }
    
    private func registerGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.scene.physicsWorld.contactDelegate = self
    }
    
    @objc func tapped(_ recognizer: UIGestureRecognizer) {
        
        guard let currentFrame = sceneView.session.currentFrame else { return }
        
        var transalation = matrix_identity_float4x4
        transalation.columns.3.z = -0.5
        
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        
        box.materials = [material]
        
        let node = SCNNode(geometry: box)
        node.name = "Bullet"
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = BoxBodyType.bullet.rawValue
        node.physicsBody?.contactTestBitMask = BoxBodyType.barrier.rawValue
        
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, transalation)
        
        let forceVector = SCNVector3(node.worldFront.x * 2, node.worldFront.y * 2, node.worldFront.z * 2)
        
        node.physicsBody?.applyForce(forceVector, asImpulse: true)
        
        sceneView.scene.rootNode.addChildNode(node)
        
    }
}


// MARK: - SCNPhysicsContactDelegate to get the notification whenever one object hits another
extension ViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var contactNode: SCNNode?
        contactNode = contact.nodeA.name == "Bullet" ? contact.nodeB : contact.nodeA
        
        if lastContactNode != nil && lastContactNode == contactNode {
            return
        }
        lastContactNode = contactNode
        
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        box.materials = [material]
        lastContactNode?.geometry = box
        lastContactNode?.removeAllParticleSystems()
    }
}
