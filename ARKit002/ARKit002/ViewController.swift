//
//  ViewController.swift
//  ARKit002
//
//  Created by Ankit Kumar Bharti on 14/09/18.
//  Copyright © 2018 Exilant. All rights reserved.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {

    var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        addMissile()
        registerGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration, options: .resetTracking)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func setupScene()  {
        
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        
        sceneView.scene = SCNScene()
    }
    
    func addMissile() {
        guard let missileScene = SCNScene(named: "art.scnassets/missile.scn") else { return }
        let missileNode = Missile(scene: missileScene)
        missileNode.name = "Missile"
        missileNode.position = SCNVector3(0, 0, -2)
        sceneView.scene.rootNode.addChildNode(missileNode)
    }
    
    func registerGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapped(_ recognizer: UIGestureRecognizer) {
        guard let missileNode = sceneView.scene.rootNode.childNode(withName: "Missile", recursively: true) else { fatalError("Missile not found") }
        
        guard let smokeNode = missileNode.childNode(withName: "smokeNode", recursively: true) else { fatalError("smoke not found") }
        smokeNode.removeAllParticleSystems()
        
        if let fire = SCNParticleSystem(named: "fire.scnp", inDirectory: nil) {
            smokeNode.addParticleSystem(fire)
        }
        
        missileNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        missileNode.physicsBody?.isAffectedByGravity = false
        missileNode.physicsBody?.damping = 0
        missileNode.physicsBody?.applyForce(SCNVector3(0, 100, 0), asImpulse: false)
    }
}

