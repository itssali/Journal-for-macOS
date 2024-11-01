import SwiftUI

struct StatView: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    init(icon: String, title: String, value: String, iconColor: Color = .blue) {
        self.icon = icon
        self.title = title
        self.value = value
        self.iconColor = iconColor
    }
    
    var body: some View {
        HStack {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(iconColor)
                
                VStack(spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}
