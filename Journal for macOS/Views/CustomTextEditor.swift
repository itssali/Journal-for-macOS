import SwiftUI
import UniformTypeIdentifiers
import SwiftUIIntrospect

enum ListType {
    case bullet
    case dash
    
    var prefix: String {
        switch self {
        case .bullet: return "• "
        case .dash: return "- "
        }
    }
}

public class TextAttachment: NSTextAttachment {
    let id: UUID
    
    init(image: NSImage, id: UUID) {
        self.id = id
        super.init(data: nil, ofType: nil)
        self.image = image
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class TextViewCoordinator: NSObject {
    var textView: NSTextView?
    var parent: CustomTextEditor
    
    init(_ parent: CustomTextEditor) {
        self.parent = parent
    }
    
    func configure(_ textView: NSTextView) {
        self.textView = textView
        textView.focusRingType = .none
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.isRichText = true
    }
}

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    @Binding var attachments: [ImageAttachment]
    @State private var showingListOptions = false
    @State private var showingImagePicker = false
    @State private var isDragging = false
    @State private var textView: NSTextView?
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 8) {
            Menu {
                Button("Bullet List (•)") {
                    formatAsList(.bullet)
                }
                Button("Dash List (-)") {
                    formatAsList(.dash)
                }
            } label: {
                Image(systemName: "list.bullet")
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color(nsColor: .windowBackgroundColor))
                    .cornerRadius(6)
            }
            .menuStyle(.borderlessButton)
            .frame(width: 32, height: 32)
            .padding(.trailing, 12)
            
            TextEditor(text: $text)
                .font(.system(.body))
                .lineSpacing(2)
                .scrollContentBackground(.hidden)
                .padding(.top, 16)
                .padding(.horizontal, 12)
                .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
                .cornerRadius(8)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
                .introspect(.textEditor) { (nsTextView: NSTextView) in
                    nsTextView.focusRingType = .none
                    nsTextView.backgroundColor = .clear
                    nsTextView.drawsBackground = false
                    nsTextView.isRichText = true
                    nsTextView.allowsImageEditing = true
                    nsTextView.isEditable = true
                    self.textView = nsTextView
                }
        }
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleImageSelection(result)
        }
    }
    
    private func handleImageSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result else { return }
        
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let imageData = try Data(contentsOf: url)
                guard let image = NSImage(data: imageData) else { continue }
                
                // Create text attachment
                let textAttachment = NSTextAttachment()
                textAttachment.image = image
                
                // Create attributed string with attachment
                let attributedString = NSAttributedString(attachment: textAttachment)
                
                // Get text view and insert image
                if let textView = self.textView {
                    let selectedRange = textView.selectedRange()
                    let mutableAttrString = NSMutableAttributedString(attributedString: textView.attributedString())
                    mutableAttrString.insert(attributedString, at: selectedRange.location)
                    textView.textStorage?.setAttributedString(mutableAttrString)
                    
                    // Update binding
                    text = textView.string
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
    
    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
                guard let imageData = data else { return }
                DispatchQueue.main.async {
                    attachments.append(ImageAttachment(id: UUID(), data: imageData))
                }
            }
        }
    }
    
    private func removeAttachment(_ attachment: ImageAttachment) {
        attachments.removeAll { $0.id == attachment.id }
    }
    
    private func formatAsList(_ type: ListType) {
        // Split text into lines
        let lines = text.components(separatedBy: .newlines)
        
        // Add list prefix to each non-empty line
        let formattedLines = lines.map { line -> String in
            guard !line.trimmingCharacters(in: .whitespaces).isEmpty else { return line }
            // Check if line already has a list prefix
            if line.hasPrefix("• ") || line.hasPrefix("- ") {
                let cleaned = line.replacingOccurrences(of: "^[•-] ", with: "", options: .regularExpression)
                return type.prefix + cleaned
            }
            return type.prefix + line
        }
        
        // Join lines back together
        text = formattedLines.joined(separator: "\n")
    }
}
