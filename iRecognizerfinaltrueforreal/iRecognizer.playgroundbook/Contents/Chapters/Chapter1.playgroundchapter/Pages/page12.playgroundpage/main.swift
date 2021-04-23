//#-hidden-code

import PlaygroundSupport
import RealityKit
import UIKit
import ARKit

let arscene = ARView(frame: CGRect(x: 0, y: 0, width: 600, height: 600), cameraMode: .ar, automaticallyConfigureSession: true)


let sphere = MeshResource.generateSphere(radius:0.6)

let sphereMaterial = SimpleMaterial(color: .blue, isMetallic: true)

let sphereEntity = ModelEntity(mesh: sphere, materials: [sphereMaterial])

sphereEntity.generateCollisionShapes(recursive: true)

let anchor = AnchorEntity(plane: .horizontal)

arscene.scene.addAnchor(anchor)

arscene.installGestures(for: sphereEntity)
anchor.addChild(sphereEntity)
PlaygroundPage.current.setLiveView(arscene)

//#-end-hidden-code

/*:
 # ARSphere Demo
 Using the LiDAR scanner to instantly acquire a depth map of your surroundings, a blue metallic sphere using near-real time reflections appears. Try dragging it around to various places, and see the reflection update!
 
 # Run the code :)
 
 Next demo on next page
 */









