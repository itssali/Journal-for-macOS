import SwiftUI
import UniformTypeIdentifiers
import AppKit

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    @Binding var attachments: [ImageAttachment]
    @State private var showingImagePicker = false
    @State var nsTextView: NSTextView?
    @Binding var attributedContent: NSAttributedString?
    @State private var activeFormats: Set<FormatType> = []
    
    // Default font to use
    private let defaultFont = NSFont.systemFont(ofSize: 14)
    private let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 14),
        .foregroundColor: NSColor.textColor
    ]
    
    private enum FormatType {
        case bold, italic, underline, strikethrough
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Formatting toolbar (always visible) - modern and transparent
            HStack {
                HStack(spacing: 8) { // Increased spacing
                    // Text formatting
                    FormatButton(image: "bold", isActive: activeFormats.contains(.bold), action: toggleBold)
                    FormatButton(image: "italic", isActive: activeFormats.contains(.italic), action: toggleItalic)
                    FormatButton(image: "underline", isActive: activeFormats.contains(.underline), action: toggleUnderline)
                    FormatButton(image: "strikethrough", isActive: activeFormats.contains(.strikethrough), action: toggleStrikethrough)
                    
                    Divider().frame(height: 16)
                        .padding(.horizontal, 4)
                    
                    // Lists - using FormatButton style consistent with other buttons
            Menu {
                        Button(action: { applyListFormat(.bullet) }) {
                            Label("Bullet List", systemImage: "list.bullet")
                        }
                        Button(action: { applyListFormat(.dash) }) {
                            Label("Dash List", systemImage: "list.dash")
                        }
                        Button(action: { applyListFormat(.number) }) {
                            Label("Numbered List", systemImage: "list.number")
                }
            } label: {
                Image(systemName: "list.bullet")
                            .font(.system(size: 12))
                            .frame(width: 28, height: 28)
                    }
                    .menuStyle(.borderlessButton)
                    .buttonStyle(.plain)
                    .frame(width: 28, height: 28) // Ensure fixed width same as other buttons
                    
                    // Image insert
                    FormatButton(image: "photo", action: { showingImagePicker = true })
                }
                .padding(.vertical, 6)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
            
            // Text editor - using a modification to avoid view update issue
            MacTextViewWrapper(text: $text, placeholder: placeholder, attributedStringHandler: { attrString in
                self.attributedContent = attrString
                // Ensure text is updated with plain content
                self.text = attrString.string
            }, textViewHandler: { textView in
                DispatchQueue.main.async {
                    self.nsTextView = textView
                    
                    // Set initial formatted content if available
                    if let content = attributedContent {
                        textView.textStorage?.setAttributedString(content)
                    } else {
                        // Apply default formatting to plain text
                        let initialString = NSAttributedString(string: text, attributes: defaultAttributes)
                        textView.textStorage?.setAttributedString(initialString)
                    }
                }
            }, parentEditor: self)
            .background(Color(nsColor: .textBackgroundColor).opacity(0.5))
            .cornerRadius(6)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)
        }
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true
        ) { result in
            handleImageSelection(result)
        }
    }
    
    // Get the current attributed string content
    func getAttributedString() -> NSAttributedString? {
        return attributedContent
    }
    
    // Update format checking
    fileprivate func updateActiveFormats() {
        guard let textView = nsTextView,
              let textStorage = textView.textStorage,
              textStorage.length > 0 else {
            activeFormats = []
            return
        }
        
        let selectedRange = textView.selectedRange()
        let location = min(max(selectedRange.location, 0), textStorage.length - 1)
        
        let fontManager = NSFontManager.shared
        var newFormats: Set<FormatType> = []
        
        // Check font traits
        if let font = textView.font(at: location) {
            let traits = fontManager.traits(of: font)
            if traits.contains(.boldFontMask) { newFormats.insert(.bold) }
            if traits.contains(.italicFontMask) { newFormats.insert(.italic) }
        }
        
        // Check underline and strikethrough
        if let underlineStyle = textStorage.attribute(.underlineStyle, at: location, effectiveRange: nil) as? Int,
           underlineStyle == NSUnderlineStyle.single.rawValue {
            newFormats.insert(.underline)
        }
        
        if let strikeStyle = textStorage.attribute(.strikethroughStyle, at: location, effectiveRange: nil) as? Int,
           strikeStyle == NSUnderlineStyle.single.rawValue {
            newFormats.insert(.strikethrough)
        }
        
        // Also check typing attributes for cursor position
        if selectedRange.length == 0 {
            if let font = textView.typingAttributes[.font] as? NSFont {
                let traits = fontManager.traits(of: font)
                if traits.contains(.boldFontMask) { newFormats.insert(.bold) }
                if traits.contains(.italicFontMask) { newFormats.insert(.italic) }
            }
            if let underlineStyle = textView.typingAttributes[.underlineStyle] as? Int,
               underlineStyle == NSUnderlineStyle.single.rawValue {
                newFormats.insert(.underline)
            }
            if let strikeStyle = textView.typingAttributes[.strikethroughStyle] as? Int,
               strikeStyle == NSUnderlineStyle.single.rawValue {
                newFormats.insert(.strikethrough)
            }
        }
        
        activeFormats = newFormats
    }

    fileprivate func updateTypingAttributes() {
        guard let textView = nsTextView else { return }
        
        // Start with default font
        var currentFont = textView.font ?? NSFont.systemFont(ofSize: 14)
        let fontManager = NSFontManager.shared
        
        // Apply bold and italic if active
        if activeFormats.contains(.bold) {
            currentFont = fontManager.convert(currentFont, toHaveTrait: .boldFontMask)
        } else {
            currentFont = fontManager.convert(currentFont, toNotHaveTrait: .boldFontMask)
        }
        if activeFormats.contains(.italic) {
            currentFont = fontManager.convert(currentFont, toHaveTrait: .italicFontMask)
        } else {
            currentFont = fontManager.convert(currentFont, toNotHaveTrait: .italicFontMask)
        }
        
        // Update typing attributes
        textView.typingAttributes[.font] = currentFont
        
        if activeFormats.contains(.underline) {
            textView.typingAttributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
        } else {
            textView.typingAttributes.removeValue(forKey: .underlineStyle)
        }
        
        if activeFormats.contains(.strikethrough) {
            textView.typingAttributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
        } else {
            textView.typingAttributes.removeValue(forKey: .strikethroughStyle)
        }
    }
    
    // MARK: - Formatting Actions
    
    private func toggleBold() {
        guard let textView = nsTextView else { return }
        
        // Toggle the format state
        if activeFormats.contains(.bold) {
            activeFormats.remove(.bold)
        } else {
            activeFormats.insert(.bold)
        }
        
        // Update typing attributes first
        var typingAttributes = textView.typingAttributes
        let fontManager = NSFontManager.shared
        var currentFont = typingAttributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: 14)
        
        if activeFormats.contains(.bold) {
            currentFont = fontManager.convert(currentFont, toHaveTrait: .boldFontMask)
        } else {
            currentFont = fontManager.convert(currentFont, toNotHaveTrait: .boldFontMask)
        }
        
        // Preserve font but update the bold trait
        typingAttributes[.font] = currentFont
        textView.typingAttributes = typingAttributes
        
        // Apply to selection if there is one
        textView.performFormatting { textView in
            let selectedRange = textView.selectedRange()
            
            if selectedRange.length > 0 {
                textView.setFont(to: nil, traits: .boldFontMask, range: selectedRange)
            }
            
            // Update the attributed content binding
            attributedContent = textView.attributedString()
            text = textView.string
        }
    }
    
    private func toggleItalic() {
        guard let textView = nsTextView else { return }
        
        // Toggle the format state
        if activeFormats.contains(.italic) {
            activeFormats.remove(.italic)
        } else {
            activeFormats.insert(.italic)
        }
        
        // Update typing attributes first
        var typingAttributes = textView.typingAttributes
        let fontManager = NSFontManager.shared
        var currentFont = typingAttributes[.font] as? NSFont ?? NSFont.systemFont(ofSize: 14)
        
        if activeFormats.contains(.italic) {
            currentFont = fontManager.convert(currentFont, toHaveTrait: .italicFontMask)
        } else {
            currentFont = fontManager.convert(currentFont, toNotHaveTrait: .italicFontMask)
        }
        
        // Preserve font but update the italic trait
        typingAttributes[.font] = currentFont
        textView.typingAttributes = typingAttributes
        
        // Apply to selection if there is one
        textView.performFormatting { textView in
            let selectedRange = textView.selectedRange()
            
            if selectedRange.length > 0 {
                textView.setFont(to: nil, traits: .italicFontMask, range: selectedRange)
            }
            
            // Update the attributed content binding
            attributedContent = textView.attributedString()
            text = textView.string
        }
    }
    
    private func toggleUnderline() {
        guard let textView = nsTextView else { return }
        textView.performFormatting { textView in
            let selectedRange = textView.selectedRange()
            let hasUnderline = textView.hasFormat(.underlineStyle, in: selectedRange)
            
            if hasUnderline {
                textView.textStorage?.removeAttribute(.underlineStyle, range: selectedRange)
                activeFormats.remove(.underline)
            } else {
                textView.textStorage?.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: selectedRange)
                activeFormats.insert(.underline)
            }
            
            updateTypingAttributes()
            
            // Update the attributed content binding
            attributedContent = textView.attributedString()
            text = textView.string
        }
    }
    
    private func toggleStrikethrough() {
        guard let textView = nsTextView else { return }
        textView.performFormatting { textView in
            let selectedRange = textView.selectedRange()
            let hasStrikethrough = textView.hasFormat(.strikethroughStyle, in: selectedRange)
            
            if hasStrikethrough {
                textView.textStorage?.removeAttribute(.strikethroughStyle, range: selectedRange)
                activeFormats.remove(.strikethrough)
            } else {
                textView.textStorage?.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: selectedRange)
                activeFormats.insert(.strikethrough)
            }
            
            updateTypingAttributes()
            
            // Update the attributed content binding
            attributedContent = textView.attributedString()
            text = textView.string
        }
    }
    
    private func applyListFormat(_ type: ListType) {
        guard let textView = nsTextView else { return }
        textView.performFormatting { textView in
            let string = textView.string as NSString
            let selectedRange = textView.selectedRange()
            
            // Find the paragraph ranges
            var paragraphRanges: [NSRange] = []
            
            // Find start of first paragraph
            let firstParagraphStart = string.lineRange(for: NSRange(location: selectedRange.location, length: 0)).location
            
            // Find end of last paragraph
            let lastParagraphEnd = NSMaxRange(string.lineRange(for: NSRange(location: NSMaxRange(selectedRange) - 1, length: 0)))
            
            // Get total range of all affected paragraphs
            let totalRange = NSRange(location: firstParagraphStart, length: lastParagraphEnd - firstParagraphStart)
            
            // Split into individual paragraphs
            var location = totalRange.location
            while location < NSMaxRange(totalRange) {
                let paragraphRange = string.lineRange(for: NSRange(location: location, length: 0))
                if paragraphRange.length > 0 {
                    paragraphRanges.append(paragraphRange)
                }
                location = NSMaxRange(paragraphRange)
            }
            
            // Apply formatting to each paragraph with consistent spacing
            let paragraphSeparator = "\n"
            let newText = NSMutableAttributedString()
            
            var listItemNumber = 1 // Counter for numbered lists, only incremented for non-empty lines
            
            for (index, paragraphRange) in paragraphRanges.enumerated() {
                // Get paragraph text without the newline
                var paragraphText = string.substring(with: paragraphRange)
                
                // Copy attributes from the original text
                let attributes = textView.textStorage?.attributes(at: paragraphRange.location, effectiveRange: nil) ?? [:]
                
                if paragraphText.hasSuffix("\n") {
                    paragraphText = String(paragraphText.dropLast())
                }
                
                // Skip empty paragraphs but preserve them in the output
                if paragraphText.trimmingCharacters(in: .whitespaces).isEmpty {
                    newText.append(NSAttributedString(string: paragraphSeparator, attributes: attributes))
                    continue
                }
                
                // Remove any existing list prefixes
                var cleanText = paragraphText
                if cleanText.hasPrefix("• ") {
                    cleanText = String(cleanText.dropFirst(2))
                } else if cleanText.hasPrefix("- ") {
                    cleanText = String(cleanText.dropFirst(2))
                } else if cleanText.matches(pattern: "^\\d+\\.\\s+") {
                    cleanText = cleanText.replacingRegex(pattern: "^\\d+\\.\\s+", with: "")
                }
                
                // Apply new prefix
                let formattedText: String
                switch type {
                case .bullet:
                    formattedText = "• \(cleanText)"
                case .dash:
                    formattedText = "- \(cleanText)"
                case .number:
                    formattedText = "\(listItemNumber). \(cleanText)"
                    listItemNumber += 1 // Only increment for non-empty lines
                }
                
                // Add formatted paragraph with original attributes
                newText.append(NSAttributedString(string: formattedText, attributes: attributes))
                
                // Add paragraph separator except for last paragraph
                if index < paragraphRanges.count - 1 {
                    newText.append(NSAttributedString(string: paragraphSeparator, attributes: attributes))
                } else if paragraphText.hasSuffix("\n") {
                    newText.append(NSAttributedString(string: paragraphSeparator, attributes: attributes))
                }
            }
            
            // Replace the entire selected range with the new text
            textView.textStorage?.replaceCharacters(in: totalRange, with: newText)
            
            // Update the content binding
            attributedContent = textView.attributedString()
            text = textView.string
        }
    }
    
    // MARK: - Image Handling
    
    private func handleImageSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result, let textView = nsTextView else { return }
        
        // Clear existing attachments if needed
        if attachments.isEmpty {
            attachments = []
        }
        
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let imageData = try Data(contentsOf: url)
                guard let image = NSImage(data: imageData) else { continue }
                
                // Scale and constrain the image
                let maxDimension: CGFloat = 300 // Maximum width or height
                let aspectRatio = image.size.width / image.size.height
                
                let newSize: NSSize
                if aspectRatio > 1 {
                    // Wider than tall
                    newSize = NSSize(width: maxDimension, height: maxDimension / aspectRatio)
                } else {
                    // Taller than wide
                    newSize = NSSize(width: maxDimension * aspectRatio, height: maxDimension)
                }
                
                let scaledImage = image.resize(to: newSize)
                
                // Create attachment with rounded corners
                let attachment = NSTextAttachment()
                attachment.image = scaledImage.roundedCorners(radius: 8)
                
                // Create attributed string with attachment
                let attrString = NSAttributedString(attachment: attachment)
                
                // Insert at current position
                    let selectedRange = textView.selectedRange()
                textView.textStorage?.replaceCharacters(in: selectedRange, with: attrString)
                
                // Add to attachments array with unique ID
                if let imageData = scaledImage.tiffRepresentation {
                    let newAttachment = ImageAttachment(id: UUID(), data: imageData)
                    attachments.append(newAttachment)
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}

// MARK: - List Types

enum ListType {
    case bullet
    case dash
    case number
    
    var prefix: String {
        switch self {
        case .bullet: return "• "
        case .dash: return "- "
        case .number: return "1. "
        }
    }
}

// MARK: - Helper Views

struct FormatButton: View {
    let image: String
    var isActive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: image)
                .font(.system(size: 12))
                .frame(width: 28, height: 28)
                .foregroundColor(isActive ? .accentColor : .primary)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Text View Wrapper

struct MacTextViewWrapper: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var attributedStringHandler: ((NSAttributedString) -> Void)?
    var textViewHandler: (NSTextView) -> Void
    var parentEditor: CustomTextEditor
    
    // Define default text attributes
    private let defaultAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 14),
        .foregroundColor: NSColor.textColor
    ]
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        let textView = scrollView.documentView as! NSTextView
        
        // Configure the text view
        textView.isRichText = true
        textView.allowsUndo = true
        textView.isEditable = true
        textView.isSelectable = true
        textView.usesFontPanel = true
        textView.allowsImageEditing = true
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.font = defaultAttributes[.font] as? NSFont
        textView.textColor = defaultAttributes[.foregroundColor] as? NSColor
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        textView.delegate = context.coordinator
        
        // Add paste handling
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.handlePaste(_:)),
            name: NSText.didChangeNotification,
            object: textView
        )
        
        // Set initial text with default attributes
        let attributedString = NSAttributedString(string: text, attributes: defaultAttributes)
        textView.textStorage?.setAttributedString(attributedString)
        
        // Configure the scroll view
        configureScrollView(scrollView)
        
        // Provide access to the text view
        textViewHandler(textView)
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Only update if text has changed externally and not from editing
        if !context.coordinator.isEditing && textView.string != text {
            textView.string = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, parentEditor: parentEditor)
    }
    
    // Helper to configure the scroll view appearance
    private func configureScrollView(_ scrollView: NSScrollView) {
        // Improved scrollbar configuration
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = false // Always show scrollbar
        scrollView.scrollerStyle = .overlay
        
        // Configure scroller appearance
        if let scroller = scrollView.verticalScroller {
            scroller.scrollerStyle = .overlay
            scroller.knobStyle = .light
            scroller.controlSize = .mini // Smaller scrollbar
        }
        
        scrollView.scrollerKnobStyle = .light
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        
        // Add some padding around the content
        scrollView.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: MacTextViewWrapper
        var parentEditor: CustomTextEditor
        var isEditing = false
        
        init(_ parent: MacTextViewWrapper, parentEditor: CustomTextEditor) {
            self.parent = parent
            self.parentEditor = parentEditor
        }
        
        @objc func handlePaste(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            
            // Apply default attributes to the entire content
            let fullRange = NSRange(location: 0, length: textView.textStorage?.length ?? 0)
            textView.textStorage?.addAttributes(parent.defaultAttributes, range: fullRange)
            
            // Update bindings
            parent.text = textView.string
            if let handler = parent.attributedStringHandler {
                handler(textView.attributedString())
            }
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            isEditing = true
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            parent.text = textView.string
            
            // Pass attributed string to handler if available
            if let handler = parent.attributedStringHandler {
                handler(textView.attributedString())
            }
            
            // Update active formats based on cursor position
            parentEditor.updateActiveFormats()
            
            // Ensure typing attributes are applied to new text
            parentEditor.updateTypingAttributes()
        }
        
        func textDidEndEditing(_ notification: Notification) {
            isEditing = false
        }
    }
}

// MARK: - NSTextView Extensions

extension NSTextView {
    func performFormatting(_ action: @escaping (NSTextView) -> Void) {
        // Perform the formatting action on the main thread
        DispatchQueue.main.async {
            // Begin an undoable action
            self.undoManager?.beginUndoGrouping()
            
            // Perform the formatting
            action(self)
            
            // End the undoable action
            self.undoManager?.endUndoGrouping()
        }
    }
    
    func setFont(to font: NSFont?, traits: NSFontTraitMask, range: NSRange) {
        guard let textStorage = self.textStorage,
              textStorage.length > 0 else { return }
        
        let safeRange: NSRange
        if range.length == 0 {
            // For insertion point, apply to a single character or set typing attributes
            if range.location < textStorage.length {
                safeRange = NSRange(location: range.location, length: 1)
            } else {
                // Set typing attributes for future input
                let fontManager = NSFontManager.shared
                let currentFont = self.font ?? NSFont.systemFont(ofSize: 14)
                let newFont = fontManager.convert(currentFont, toHaveTrait: traits)
                self.typingAttributes[.font] = newFont
                return
            }
        } else {
            // For selection, ensure range is within bounds
            let start = min(max(range.location, 0), textStorage.length - 1)
            let maxLength = textStorage.length - start
            let length = min(range.length, maxLength)
            safeRange = NSRange(location: start, length: length)
        }
        
        let fontManager = NSFontManager.shared
        textStorage.enumerateAttribute(.font, in: safeRange, options: []) { value, range, _ in
            guard let currentFont = (value as? NSFont) ?? self.font else { return }
            let currentTraits = fontManager.traits(of: currentFont)
            let newFont: NSFont
            
            if currentTraits.contains(traits) {
                // Remove trait
                newFont = fontManager.convert(currentFont, toNotHaveTrait: traits)
            } else {
                // Add trait
                newFont = fontManager.convert(currentFont, toHaveTrait: traits)
            }
            
            textStorage.addAttribute(.font, value: newFont, range: range)
        }
        
        // Set typing attributes for future input if at insertion point
        if range.length == 0 {
            let currentFont = self.font ?? NSFont.systemFont(ofSize: 14)
            let newFont = fontManager.convert(currentFont, toHaveTrait: traits)
            self.typingAttributes[.font] = newFont
        }
    }
    
    func hasFormat(_ key: NSAttributedString.Key, in range: NSRange) -> Bool {
        guard let textStorage = self.textStorage,
              textStorage.length > 0,
              range.location != NSNotFound else { return false }
        
        let safeRange: NSRange
        if range.length == 0 {
            // For insertion point, just check at the location
            let location = min(max(range.location, 0), textStorage.length - 1)
            safeRange = NSRange(location: location, length: 0)
        } else {
            // For selection, ensure range is within bounds
            let start = min(max(range.location, 0), textStorage.length - 1)
            let maxLength = textStorage.length - start
            let length = min(range.length, maxLength)
            safeRange = NSRange(location: start, length: length)
        }
        
        if safeRange.length == 0 {
            // Check at insertion point
            return textStorage.attribute(key, at: safeRange.location, effectiveRange: nil) != nil
        } else {
            // Check in selection
            var hasAttribute = false
            textStorage.enumerateAttribute(key, in: safeRange) { value, _, stop in
                if value != nil {
                    hasAttribute = true
                    stop.pointee = true
                }
            }
            return hasAttribute
        }
    }
    
    func font(at location: Int) -> NSFont? {
        guard let textStorage = self.textStorage,
              textStorage.length > 0,
              location != NSNotFound else { return nil }
        
        let safeLocation = min(max(location, 0), textStorage.length - 1)
        return textStorage.attribute(.font, at: safeLocation, effectiveRange: nil) as? NSFont
    }
}

// MARK: - Image Extensions

extension NSImage {
    func resize(to newSize: NSSize) -> NSImage {
        let img = NSImage(size: newSize)
        img.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        self.draw(in: NSRect(origin: .zero, size: newSize),
                 from: NSRect(origin: .zero, size: self.size),
                 operation: .copy,
                 fraction: 1.0)
        img.unlockFocus()
        return img
    }
    
    func roundedCorners(radius: CGFloat) -> NSImage {
        let rect = NSRect(origin: .zero, size: self.size)
        let targetImage = NSImage(size: self.size)
        
        targetImage.lockFocus()
        
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        path.addClip()
        
        self.draw(in: rect)
        
        targetImage.unlockFocus()
        
        return targetImage
    }
}

// MARK: - String Extensions

extension String {
    func matches(pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
    
    func replacingRegex(pattern: String, with replacement: String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return self }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: replacement)
    }
}

// Extension to get the full attributed string from the text view
extension NSTextView {
    func attributedString() -> NSAttributedString {
        return self.textStorage ?? NSAttributedString()
    }
}
