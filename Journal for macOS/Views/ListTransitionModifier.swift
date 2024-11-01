import SwiftUI

struct ListTransitionModifier: ViewModifier {
    let isVisible: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 10)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isVisible)
    }
}

extension View {
    func listTransition(isVisible: Bool) -> some View {
        modifier(ListTransitionModifier(isVisible: isVisible))
    }
} 