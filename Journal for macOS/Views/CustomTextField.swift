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
            .background(Color.clear)
            .cornerRadius(8)
            .introspect(.textField) { (textField: NSTextField) in
                textField.focusRingType = .none
                textField.backgroundColor = .clear
                textField.drawsBackground = false
                textField.isBezeled = false
                textField.bezelStyle = .roundedBezel
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.placeholderTextColor.withAlphaComponent(0.6),
                    .font: NSFont.systemFont(ofSize: 18, weight: .bold)
                ]
                textField.placeholderAttributedString = NSAttributedString(
                    string: placeholder,
                    attributes: attributes
                )
            }
    }
} 
