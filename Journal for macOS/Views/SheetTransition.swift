import SwiftUI

struct SheetTransition: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPresented ? 1 : 0.93)
            .opacity(isPresented ? 1 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isPresented)
    }
}

extension View {
    func sheetTransition(isPresented: Bool) -> some View {
        modifier(SheetTransition(isPresented: isPresented))
    }
} 