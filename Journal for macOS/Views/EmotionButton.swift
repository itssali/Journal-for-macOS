import SwiftUI

struct EmotionButton: View {
    let emotion: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(emotion)
                .font(.system(.body, design: .rounded))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                            Color(red: 0.37, green: 0.36, blue: 0.90) : 
                            Color(nsColor: .windowBackgroundColor)
                        )
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isSelected ? 
                                Color.clear : 
                                Color.secondary.opacity(0.3),
                            lineWidth: 1
                        )
                )
        }
        .buttonStyle(.plain)
    }
} 