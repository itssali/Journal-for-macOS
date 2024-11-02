import SwiftUI
import SwiftUIIntrospect

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextEditor(text: $text)
            .font(.system(.body))
            .scrollContentBackground(.hidden)
            .padding(12)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
            .cornerRadius(8)
            .frame(height: 200)
            .introspect(.textEditor) { (textView: NSTextView) in
                textView.focusRingType = .none
                textView.backgroundColor = .clear
                textView.drawsBackground = false
                
                if text.isEmpty {
                    let attributes: [NSAttributedString.Key: Any] = [
                        .foregroundColor: NSColor.placeholderTextColor,
                        .font: NSFont.systemFont(ofSize: 14)
                    ]
                    textView.textStorage?.setAttributedString(NSAttributedString(
                        string: placeholder,
                        attributes: attributes
                    ))
                }
            }
    }
}
