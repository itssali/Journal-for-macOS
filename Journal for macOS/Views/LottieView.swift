import SwiftUI
import Lottie

struct LottieView: NSViewRepresentable {
    let animationName: String
    let loopMode: LottieLoopMode
    let completion: (() -> Void)?
    
    init(_ animationName: String, loopMode: LottieLoopMode = .playOnce, completion: (() -> Void)? = nil) {
        self.animationName = animationName
        self.loopMode = loopMode
        self.completion = completion
    }
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let animationView = LottieAnimationView(name: animationName)
        animationView.loopMode = loopMode
        animationView.contentMode = .scaleAspectFit
        animationView.frame = view.bounds
        animationView.autoresizingMask = [.width, .height]
        view.addSubview(animationView)
        animationView.play { finished in
            if finished {
                completion?()
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
} 