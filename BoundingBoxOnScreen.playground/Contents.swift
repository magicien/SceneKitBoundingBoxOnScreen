import PlaygroundSupport
import AppKit
import SpriteKit
import SceneKit

class BBView: SCNView, SCNSceneRendererDelegate {
    var trackingNode: SCNNode!
    var boundingBox: SKShapeNode!
    let bbSize: CGFloat = 20.0
    var sizeLabel: SKLabelNode!
    
    init() {
        super.init(frame: NSRect(x: 0, y: 0, width: 400, height: 250), options: nil)
        
        self.autoenablesDefaultLighting = true
        self.backgroundColor = SKColor.gray
        self.allowsCameraControl = true
        
        self.showsStatistics = true
        self.debugOptions = .showBoundingBoxes

        self.setupScene()
        self.setupSKScene()
        
        self.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupScene() {
        let scene = SCNScene()
        self.scene = scene
        
        // set camera node
        let cameraNode = SCNNode()
        let camera = SCNCamera()
        cameraNode.camera = camera
        scene.rootNode.addChildNode(cameraNode)
        self.pointOfView = cameraNode
        
        // create a sphere
        let sphere = SCNSphere(radius: 1.0)
        self.trackingNode = SCNNode(geometry: sphere)
        self.trackingNode.position = SCNVector3(0, 0, -10.0)
        scene.rootNode.addChildNode(self.trackingNode)
    }
    
    func setupSKScene() {
        let skScene = SKScene(size: self.bounds.size)
        self.overlaySKScene = skScene
        
        self.boundingBox = SKShapeNode(rect: CGRect(x: 0, y: 0, width: self.bbSize, height: self.bbSize))
        self.boundingBox.strokeColor = SKColor.red
        self.boundingBox.lineWidth = 3
        
        skScene.addChild(self.boundingBox)
        
        self.sizeLabel = SKLabelNode(fontNamed: "Arial")
        self.sizeLabel.fontSize = 24
        self.sizeLabel.fontColor = SKColor.black
        self.sizeLabel.horizontalAlignmentMode = .left
        self.sizeLabel.position.y = 25.0

        skScene.addChild(self.sizeLabel)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let (localMin, localMax) = self.trackingNode.boundingBox
        let min = self.trackingNode.convertPosition(localMin, to: nil)
        let max = self.trackingNode.convertPosition(localMax, to: nil)
        let vertices = [
            SCNVector3(min.x, min.y, min.z),
            SCNVector3(max.x, min.y, min.z),
            SCNVector3(min.x, max.y, min.z),
            SCNVector3(max.x, max.y, min.z),
            SCNVector3(min.x, min.y, max.z),
            SCNVector3(max.x, min.y, max.z),
            SCNVector3(min.x, max.y, max.z),
            SCNVector3(max.x, max.y, max.z)
        ]
        let arr = vertices.map { self.projectPoint($0) }
        
        let minX: CGFloat = arr.reduce(CGFloat.infinity, { $0 > $1.x ? $1.x : $0 })
        let minY: CGFloat = arr.reduce(CGFloat.infinity, { $0 > $1.y ? $1.y : $0 })
        //let minZ: CGFloat = arr.reduce(CGFloat.infinity, { $0 > $1.z ? $1.z : $0 })
        let maxX: CGFloat = arr.reduce(-CGFloat.infinity, { $0 < $1.x ? $1.x : $0 })
        let maxY: CGFloat = arr.reduce(-CGFloat.infinity, { $0 < $1.y ? $1.y : $0 })
        //let maxZ: CGFloat = arr.reduce(-CGFloat.infinity, { $0 < $1.z ? $1.z : $0 })
        
        let width = maxX - minX
        let height = maxY - minY
        //let depth = maxZ - minZ

        self.boundingBox.position.x = minX
        self.boundingBox.position.y = minY
        self.boundingBox.xScale = width / self.bbSize
        self.boundingBox.yScale = height / self.bbSize
        
        self.sizeLabel.text = "W: \(width), H: \(height)"
    }
}

let view = BBView()

PlaygroundSupport.PlaygroundPage.current.liveView = view
PlaygroundSupport.PlaygroundPage.current.needsIndefiniteExecution = true

