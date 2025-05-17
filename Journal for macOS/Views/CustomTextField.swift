import SwiftUI
import SwiftUIIntrospect

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(.plain)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
            .padding(12)
            .background(Color.clear)
            .cornerRadius(8)
            .lineLimit(2)
            .introspect(.textField) { (textField: NSTextField) in
                textField.focusRingType = .none
                textField.backgroundColor = .clear
                textField.drawsBackground = false
                textField.isBezeled = false
                textField.bezelStyle = .roundedBezel
                textField.maximumNumberOfLines = 2
                textField.cell?.wraps = true
                textField.cell?.isScrollable = false
                textField.textColor = .white
                textField.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: NSColor.placeholderTextColor.withAlphaComponent(0.6),
                    .font: NSFont.systemFont(ofSize: 22, weight: .bold)
                ]
                textField.placeholderAttributedString = NSAttributedString(
                    string: placeholder,
                    attributes: attributes
                )
                
                // Enforce line limit by adding a formatter
                class LineFormatter: Formatter {
                    override func string(for obj: Any?) -> String? {
                        guard let string = obj as? String else { return nil }
                        let lines = string.components(separatedBy: .newlines)
                        if lines.count > 2 {
                            return lines.prefix(2).joined(separator: "\n")
                        }
                        return string
                    }
                    
                    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
                        obj?.pointee = string as AnyObject
                        return true
        }
    }
                
                textField.formatter = LineFormatter()
            }
    }
} 
