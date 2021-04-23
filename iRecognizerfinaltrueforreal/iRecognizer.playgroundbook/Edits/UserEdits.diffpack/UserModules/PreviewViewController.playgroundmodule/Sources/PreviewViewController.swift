
import ARKit
import PlaygroundSupport
import RealityKit
import UIKit


open class PreviewViewController: UIViewController {
    public lazy var arView: ARView = {
        let view = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        view.session.run(AROrientationTrackingConfiguration())
        return view
        
    }()
    
    
    var usingFrontCamera = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = self.arView
        
        
    }
}




extension PreviewViewController: PlaygroundLiveViewSafeAreaContainer {}
