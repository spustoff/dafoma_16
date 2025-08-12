import SwiftUI
import ARKit
import RealityKit

struct ARCameraContainer: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if ARWorldTrackingConfiguration.isSupported {
                ARViewRepresentable()
                    .ignoresSafeArea()
                    .overlay(alignment: .topTrailing) {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.white.opacity(0.9))
                                .padding(12)
                        }
                    }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "camera")
                        .font(.system(size: 48))
                        .foregroundColor(.gray)
                    Text("AR is not supported on this device.")
                        .foregroundColor(.gray)
                    Button("Close") { dismiss() }
                        .buttonStyle(FlavorQuestButtonStyle(style: .secondary))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(FlavorQuestColors.background.ignoresSafeArea())
            }
        }
    }
}

private struct ARViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.environmentTexturing = .automatic
        arView.session.run(configuration)
        
        // Simple focus/anchor to show AR is active
        let anchor = AnchorEntity(world: [0, 0, -0.5])
        let box = ModelEntity(mesh: .generateBox(size: 0.05), materials: [SimpleMaterial(color: .yellow, isMetallic: false)])
        anchor.addChild(box)
        arView.scene.addAnchor(anchor)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    static func dismantleUIView(_ uiView: ARView, coordinator: ()) {
        uiView.session.pause()
    }
}



