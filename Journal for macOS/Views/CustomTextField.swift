import SwiftUI
import SwiftUIIntrospect

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 18, weight: .bold))
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .introspect(.textField) { (textField: NSTextField) in
                textField.focusRingType = .none
                textField.backgroundColor = .clear
                textField.drawsBackground = true
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.placeholderTextColor,
                    .font: NSFont.systemFont(ofSize: 18, weight: .bold)
                ]
                textField.placeholderAttributedString = NSAttributedString(
                    string: placeholder,
                    attributes: attributes
                )
            }
    }
} 
