import SwiftUI

struct CustomSheet<Content: View>: View {
    @State private var isVisible = false
    let isPresented: Bool
    let content: Content
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            if isPresented || isVisible {
                Color.black
                    .opacity(isVisible ? 0.3 : 0)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }
                
                content
                    .frame(width: 600, height: 600)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .black.opacity(0.2), radius: 20)
                    .opacity(isVisible ? 1 : 0)
                    .scaleEffect(isVisible ? 1 : 0.95)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.9), value: isVisible)
        .onChange(of: isPresented) { _, newValue in
            withAnimation {
                if newValue {
                    isVisible = true
                } else {
                    isVisible = false
                }
            }
        }
    }
    
    private func dismiss() {
        withAnimation {
            isVisible = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }
}