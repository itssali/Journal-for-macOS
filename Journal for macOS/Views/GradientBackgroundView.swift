import SwiftUI

struct GradientBackgroundView: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.37, green: 0.36, blue: 0.90),
                Color(red: 0.35, green: 0.35, blue: 0.37)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .opacity(0.3)
    }
} 