//
//  ViewController.swift
//  AR-App001
//
//  Created by ankit bharti on 13/09/18.
//  Copyright © 2018 Ankit Bharti. All rights reserved.
//

import UIKit
import SceneKit
import ARKit


class ARViewController: UIViewController {

    // MARK: - Properties
    private var sceneView: ARSCNView!
    private var overlayPalnes: [OverlayPlane] = []
    
    // MARK: - Controller life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSceneView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

extension ARViewController: ARSCNViewDelegate {
    
    // MARK: - Setup Scene
    private func setupSceneView() {
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // debuging
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        // add scene
        sceneView.scene = SCNScene()
        registerTapGesture()
    }
    
    // MARK: - register sceneView with tap gesture and handle the single and double tap
    private func registerTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapScene(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapScene(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        tapGesture.require(toFail: doubleTapGesture)
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc private func didTapScene(_ recognizer: UIGestureRecognizer) {
        guard let arSceneView = recognizer.view as? ARSCNView else { return }
        let touchLocation = recognizer.location(in: arSceneView)
        guard let hitResult = arSceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent).first else { return }
        addBox(hitResult)
    }
    
    @objc private func didDoubleTapScene(_ recognizer: UIGestureRecognizer) {
        print("double tapped")
    }
    
    private func addBox(_ hitResult: ARHitTestResult) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        box.materials = [material]
        
        let node = SCNNode(geometry: box)
        
        // add physics
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.categoryBitMask = BodyType.Box.rawValue
        
        node.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y + 0.5, hitResult.worldTransform.columns.3.z)
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    // MARK: - ARSCNViewDelegate
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else {
            return
        }
        let overlay = OverlayPlane(anchor: anchor as! ARPlaneAnchor)
        overlayPalnes.append(overlay)
        node.addChildNode(overlay)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let node = overlayPalnes.filter { plane -> Bool in
            return plane.anchor.identifier == anchor.identifier
        }.first
        
        guard let planeNode = node else { return }
        planeNode.update(anchor: anchor as! ARPlaneAnchor)
    }
}
