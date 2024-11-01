import SwiftUI
import Lottie

struct LottieView: NSViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let animationSpeed: CGFloat
    
    init(_ animationName: String, 
         loopMode: LottieLoopMode = .playOnce,
         speed: CGFloat = 1) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.animationSpeed = speed
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.animationSpeed = animationSpeed
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        animationView.play()
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
} 