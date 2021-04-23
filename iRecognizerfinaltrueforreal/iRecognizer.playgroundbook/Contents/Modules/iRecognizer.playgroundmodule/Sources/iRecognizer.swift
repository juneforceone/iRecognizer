//
//  iRecognizer.swift
//  iRecognizer
//
//  Created by Jun Murakami on 4/19/21.
//
import ARKit
import PlaygroundSupport
import UIKit
import Vision

let config = MLModelConfiguration()
config.allowLowPrecisionAccumulationOnGPU = true
config.computeUnits = .all
let model = try MLModel(contentsOf: try MLModel.compileModel(at: #fileLiteral(resourceName: "MobileNetV2.mlmodel")), configuration: config)
let inputName = "image"
let outputName = "classLabelProbs"
let threshold: Float = 0.5
let imageConstraint = model.modelDescription
    .inputDescriptionsByName[inputName]!
    .imageConstraint!
let imageOptions: [MLFeatureValue.ImageOption: Any] = [
    .cropAndScale: VNImageCropAndScaleOption.scaleFill.rawValue
]

// ViewControllers
final class ViewController: PreviewViewController {
    let classesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = #colorLiteral(red: 0.7254905104637146, green: 0.17647060751914978, blue: 0.3647058606147766, alpha: 1.0)
        label.text = "Nothing is detected."
        return label
    }()
    
    let depthLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.backgroundColor = #colorLiteral(red: 1.1269363540122868e-06, green: 0.3803921341896057, blue: 0.9960786700248718, alpha: 1.0)
        label.text = "No depth detected. Are you sure this device has a LiDAR Scanner?"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.arView.session.delegateQueue = .global(qos: .userInteractive)
        self.arView.session.delegate = self
        
        self.view.addSubview(self.classesLabel)
        self.view.addSubview(self.depthLabel)
        
        NSLayoutConstraint.activate([
            self.classesLabel.bottomAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.bottomAnchor),
            self.classesLabel.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            self.classesLabel.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            self.depthLabel.leftAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leftAnchor),
            self.depthLabel.leadingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.leadingAnchor),
            self.depthLabel.trailingAnchor.constraint(equalTo: self.liveViewSafeAreaGuide.trailingAnchor),
        ])
    }
    func detect(input: MLFeatureProvider) -> MLFeatureProvider {
        let start = Date()
        let result = try! model.prediction(from: input)
        return result
    }
    
    func drawResult(result: MLFeatureProvider) {
        DispatchQueue.main.async {
            self.classesLabel.text = ""
        }
        
        result.featureValue(for: outputName)?
            .dictionaryValue
            .lazy
            .filter { $0.1.floatValue >= threshold }
            .sorted { $0.1.floatValue > $1.1.floatValue }
            .forEach { name in
                DispatchQueue.main.async {
                    self.classesLabel.text?.append("\(name)")
                }
            }
    }
    
    
    func startDepth() {
        
        
        DispatchQueue.main.async {
            self.depthLabel.text = ("\(ARDepthData())")
        }
        
    }
    
}



extension ViewController: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        
        let imageBuffer = frame.capturedImage
        let orientation = CGImagePropertyOrientation(interfaceOrientation: UIScreen.main.orientation)
        let ciImage = CIImage(cvPixelBuffer: imageBuffer).oriented(orientation)
        let context = CIContext(options: [.useSoftwareRenderer: false])
        let cgImage = context.createCGImage(ciImage, from: ciImage.extent)!
        
        let featureValue = try! MLFeatureValue(cgImage: cgImage, constraint: imageConstraint, options: imageOptions)
        let input = try! MLDictionaryFeatureProvider(dictionary: [inputName: featureValue])
        
        let output = self.detect(input: input)
        self.startDepth()
        self.drawResult(result: output)
        
        
    }
}

PlaygroundPage.current.wantsFullScreenLiveView = true
PlaygroundPage.current.liveView = ViewController()


