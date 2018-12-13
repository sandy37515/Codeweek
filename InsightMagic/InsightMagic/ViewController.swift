//
//  ViewController.swift
//  InsightMagic
//
//  Created by Sandeep on 12/8/18.
//  Copyright © 2018 Sandeep. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var cardNode: SCNNode?
    var boxNode: SCNNode?
    var imageNodes = [SCNNode]()
    var isjumping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.delegate = self
        sceneView.autoenablesDefaultLighting = true
        let cardScene = SCNScene(named: "art.scnassets/VisitingCard.scn")
        cardNode = cardScene?.rootNode
        
        let boxScene = SCNScene(named: "art.scnassets/DropBox.scn")
        boxNode = boxScene?.rootNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARImageTrackingConfiguration()
        if let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Visiting Cards" , bundle: Bundle.main){
            configuration.trackingImages = trackingImages
            configuration.maximumNumberOfTrackedImages = 2
        }
        let options: ARSession.RunOptions = [.resetTracking, .removeExistingAnchors]
        sceneView.session.run(configuration, options: options)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor{
            switch imageAnchor.referenceImage.name {
            case ImageName.card.rawValue :
                let videoURL = Bundle.main.url(forResource: "apple", withExtension: "mp4")!
                let videoPlayer = AVPlayer(url: videoURL)
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {videoPlayer.play()}
                guard let planenode = self.cardNode?.childNode(withName: "video", recursively: true)! else { return nil}
                planenode.geometry?.firstMaterial?.diffuse.contents = videoPlayer
                node.addChildNode(planenode)
                var graphicsNode : SCNNode?
                graphicsNode = cardNode
                guard let graphics = graphicsNode else { return nil }
                spinJump(node: graphics)
                node.addChildNode(graphics)
            case ImageName.box.rawValue :
                var graphicsNode1 : SCNNode?
                graphicsNode1 = boxNode
                guard let graphics1 = graphicsNode1 else { return nil }
                node.addChildNode(graphics1)
            case ImageName.brain.rawValue :
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let size = imageAnchor.referenceImage.physicalSize
                    let videoURL = Bundle.main.url(forResource: "bankofamerica", withExtension: "mov")!
                    let videoPlayer = AVPlayer(url: videoURL)
                    videoPlayer.play()
                    let plane = SCNPlane(width: size.width, height: size.height)
                    plane.firstMaterial?.diffuse.contents = videoPlayer
                    //plane.cornerRadius = 0.05
                    let planenode = SCNNode(geometry:plane)
                    //planenode.position = SCNVector3(0,0,0)
                    planenode.eulerAngles.x = -.pi/2
                    node.addChildNode(planenode)
                }
            case ImageName.analyst.rawValue :
                let size = imageAnchor.referenceImage.physicalSize
                let videoURL = Bundle.main.url(forResource: "sandeep", withExtension: "mp4")!
                let videoPlayer = AVPlayer(url: videoURL)
                videoPlayer.play()
                let plane = SCNPlane(width: size.width, height: size.height)
                plane.firstMaterial?.diffuse.contents = videoPlayer
                //plane.cornerRadius = 0.05
                let planenode = SCNNode(geometry:plane)
                //planenode.position = SCNVector3(0,0,0)
                planenode.eulerAngles.x = -.pi/2
                node.addChildNode(planenode)
            default:
                break
            }
            imageNodes.append(node)
            return node
        }
        return nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if imageNodes.count == 2 {
            let position1 = SCNVector3ToGLKVector3(imageNodes[0].position)
            let position2 = SCNVector3ToGLKVector3(imageNodes[1].position)
            let distance = GLKVector3Distance(position1,position2)
            print("Postion1: \(position1)")
            print("Postion2: \(position2)")
            print("distance: \(distance)")
            if(distance <= 0.06){
                if (!isjumping){
                    isjumping = true
                    print("I am Close")
                    let alert = UIAlertController(title: "Contact", message: "Contact Saved in Insight",preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    DispatchQueue.main.async {
                        self.present(alert,animated: true, completion: nil)
                    }
                    return
                }
                
                
                //spinJump(node:imageNodes[0])
                
                
                //Call our save contact and save the contact.
            }
            else{
            isjumping = false;
            }
        }
    }
    
    func spinJump(node: SCNNode){
        if isjumping { return}
        //let shapeNode = node.childNodes[0]
        //let shapespin = SCNAction.rotateBy(x: 0, y: 2 * .pi, z: 0, duration: -1)
        //shapespin.timingMode = .easeInEaseOut
        
        let up = SCNAction.moveBy(x: 0, y: 0, z: 0.01, duration: 2)
        //let up = SCNAction.(x: 0, y: 0, z: 0.01, duration: 1)
        up.timingMode = .easeInEaseOut
        let down = up.reversed()
        let upDown = SCNAction.sequence([up, down])
        //SCNAction.repeatForever(SCNAction.sequence([act0, act1]))
        node.runAction(SCNAction.repeat(upDown, count: 1))
    
    }
    
    enum ImageName : String {
        case card = "card"
        case box = "arbox"
        case brain = "google"
        case analyst = "sandeep"
    }
    
    
    /*func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor{
            //let size = imageAnchor.referenceImage.physicalSize
            
            /*let plane = SCNPlane(width: size.width, height: size.height)
            plane.firstMaterial?.diffuse.contents = UIColor.blue
            plane.cornerRadius = 0.05
            let planenode = SCNNode(geometry:plane)
            planenode.position = SCNVector3(0,0,0)
            planenode.eulerAngles.x = -.pi/2
            
            let text = SCNText(string: "15 upcoming \n meetings", extrusionDepth: 1)
            text.firstMaterial?.diffuse.contents = UIColor.blue
            let textNode = SCNNode(geometry: text)
            textNode.position = SCNVector3(0,0,0)
            textNode.scale = SCNVector3(0.001,0.001,0.001)
            textNode.eulerAngles.x = -.pi/2
            
            node.addChildNode(textNode)
            node.addChildNode(planenode)*/
            
            if let shapeNode = chartNode{
                //shapeNode.position.x = 20
                //shapeNode.eulerAngles.y = -.pi/2
                node.addChildNode(shapeNode)
            }
        }
        return node
    }*/
    
    /*func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }
        
        // Container
        guard let container = sceneView.scene.rootNode.childNode(withName: "container", recursively: false) else { return }
        container.removeFromParentNode()
        node.addChildNode(container)
        container.isHidden = false
        
        // Video
        let videoURL = Bundle.main.url(forResource: "apple", withExtension: "mp4")!
        let videoPlayer = AVPlayer(url: videoURL)
        
        let videoScene = SKScene(size: CGSize(width: 20.0, height: 20.0))
        
        let videoNode = SKVideoNode(avPlayer: videoPlayer)
        //videoNode.position = CGPoint(x: videoScene.size.width / 2, y: videoScene.size.height / 2)
        videoNode.size = videoScene.size
        videoNode.yScale = -1
        videoNode.play()
        
        videoScene.addChild(videoNode)
        
        guard let video = container.childNode(withName: "video", recursively: true) else { return }
        video.geometry?.firstMaterial?.diffuse.contents = videoScene
        
        // Animations
        guard let videoContainer = container.childNode(withName: "videoContainer", recursively: false) else { return }
        guard let text = container.childNode(withName: "text", recursively: false) else { return }
        //guard let textTwitter = container.childNode(withName: "textTwitter", recursively: false) else { return }
        
        videoContainer.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.0), SCNAction.scale(to: 1.0, duration: 0.5)]))
        text.runAction(SCNAction.sequence([SCNAction.wait(duration: 1.5), SCNAction.scale(to: 0.01, duration: 0.5)]))
        //textTwitter.runAction(SCNAction.sequence([SCNAction.wait(duration: 2.0), SCNAction.scale(to: 0.006, duration: 0.5)]))
        
        // Particlez!!!
        //let particle = SCNParticleSystem(named: "particle.scnp", inDirectory: nil)!
        //let particleNode = SCNNode()
        
        //container.addChildNode(particleNode)
        //particleNode.addParticleSystem(particle)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }*/
}
