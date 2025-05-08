import SwiftUI

struct CustomSheet<Content: View>: View {
    @State private var isVisible = false
    let isPresented: Bool
    let content: Content
    let onDismiss: () -> Void

    private func dismiss() {
        isVisible = false
        onDismiss()
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if isPresented || isVisible {
                    Color.black
                        .opacity(isVisible ? 0.3 : 0)
                        .ignoresSafeArea()
                        .onTapGesture {
                            dismiss()
                        }
                    
                    
                    content
                        .frame(width: 600, height: 670)
                        .background(
                            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                            .ignoresSafeArea()
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: .black.opacity(0.2), radius: 20)
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.95)
                        .position(
                            x: geometry.size.width / 2,
                            y: geometry.size.height / 2
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
}
    
    struct CustomActionButton: View {
    let title: String
    let role: ButtonRole?
    let action: () -> Void
    let isDisabled: Bool
    
    init(
        _ title: String,
        role: ButtonRole? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.role = role
        self.action = action
        self.isDisabled = isDisabled
    }
    
    var backgroundColor: Color {
        if isDisabled { return Color.gray.opacity(0.3) }
        switch role {
        case .destructive:
            return Color.red.opacity(0.8)
        case .cancel:
            return Color(nsColor: .windowBackgroundColor).opacity(0.5)
        default:
            return NSApplication.shared.effectiveAppearance.name == .accessibilityHighContrastAqua 
                ? Color(red: 0.37, green: 0.36, blue: 0.90) 
                : Color.accentColor
        }
    }
    
    var foregroundColor: Color {
        if isDisabled { return .gray }
        switch role {
        case .cancel:
            return .primary
        default:
            return .white
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(backgroundColor)
                .foregroundColor(foregroundColor)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}


