//
// VariableBlurView.swift
// Journal for macOS
//
// Created by Ali Nasser on 13/01/2025.
//

import SwiftUI
import AppKit
import CoreImage.CIFilterBuiltins
import QuartzCore

public enum VariableBlurDirection {
    case blurredTopClearBottom
    case blurredBottomClearTop
}

public struct VariableBlurView: NSViewRepresentable {
    public var maxBlurRadius: CGFloat = 20
    public var direction: VariableBlurDirection = .blurredTopClearBottom
    public var scrollOffset: CGFloat = 0
    
    public init(maxBlurRadius: CGFloat = 20, direction: VariableBlurDirection = .blurredTopClearBottom, scrollOffset: CGFloat = 0) {
        self.maxBlurRadius = maxBlurRadius
        self.direction = direction
        self.scrollOffset = scrollOffset
    }
    
    public func makeNSView(context: Context) -> VariableBlurNSView {
        VariableBlurNSView(maxBlurRadius: maxBlurRadius, direction: direction, scrollOffset: scrollOffset)
    }
    
    public func updateNSView(_ nsView: VariableBlurNSView, context: Context) {
        nsView.update(maxBlurRadius: maxBlurRadius, scrollOffset: scrollOffset)
    }
}

/// credit https://github.com/jtrivedi/VariableBlurView
open class VariableBlurNSView: NSVisualEffectView {
    private var variableBlur: NSObject?
    private var scrollOffset: CGFloat = 0
    
    public init(maxBlurRadius: CGFloat = 20, direction: VariableBlurDirection = .blurredTopClearBottom, scrollOffset: CGFloat = 0) {
        super.init(frame: .zero)
        self.material = .fullScreenUI
        self.blendingMode = .behindWindow
        self.state = .active
        self.scrollOffset = scrollOffset
        setupBlur(maxBlurRadius: maxBlurRadius, direction: direction)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBlur(maxBlurRadius: CGFloat, direction: VariableBlurDirection) {
        guard let CAFilter = NSClassFromString("CAFilter") as? NSObject.Type else { return }
        guard let blur = CAFilter.perform(NSSelectorFromString("filterWithType:"), with: "variableBlur").takeUnretainedValue() as? NSObject else { return }
        
        let gradientImage = makeGradientImage(startOffset: -scrollOffset/100, direction: direction)
        
        blur.setValue(maxBlurRadius, forKey: "inputRadius")
        blur.setValue(gradientImage, forKey: "inputMaskImage")
        blur.setValue(true, forKey: "inputNormalizeEdges")
        
        let backdropLayer = layer
        backdropLayer?.filters = [blur]
        
        self.variableBlur = blur
    }
    
    public func update(maxBlurRadius: CGFloat, scrollOffset: CGFloat) {
        self.scrollOffset = scrollOffset
        guard let blur = variableBlur else { return }
        
        let gradientImage = makeGradientImage(startOffset: -scrollOffset/100, direction: .blurredTopClearBottom)
        blur.setValue(maxBlurRadius, forKey: "inputRadius")
        blur.setValue(gradientImage, forKey: "inputMaskImage")
    }
    
    open override func viewDidMoveToWindow() {
        guard let window, let backdropLayer = layer else { return }
        backdropLayer.setValue(window.backingScaleFactor, forKey: "scale")
    }
    
    private func makeGradientImage(width: CGFloat = 100, height: CGFloat = 100, startOffset: CGFloat, direction: VariableBlurDirection) -> CGImage {
        let ciGradientFilter = CIFilter.linearGradient()
        ciGradientFilter.color0 = CIColor.black
        ciGradientFilter.color1 = CIColor.clear
        
        // Adjust points based on scroll offset
        let point0Y = direction == .blurredTopClearBottom ? height : 0
        let point1Y = direction == .blurredTopClearBottom ? startOffset * height : height - startOffset * height
        
        ciGradientFilter.point0 = CGPoint(x: 0, y: point0Y)
        ciGradientFilter.point1 = CGPoint(x: 0, y: point1Y)
        
        return CIContext().createCGImage(ciGradientFilter.outputImage!, from: CGRect(x: 0, y: 0, width: width, height: height))!
    }
}
