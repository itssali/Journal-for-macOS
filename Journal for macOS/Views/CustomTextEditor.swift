import SwiftUI
import RichTextKit

struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    @Binding var attributedContent: NSAttributedString?
    @Binding var attachments: [ImageAttachment]
    
    @State private var richText: NSAttributedString
    @StateObject private var context = RichTextContext()
    @State private var showingImagePicker = false
    @State private var isInspectorPresented = false
    @State private var scrollPosition: CGPoint = .zero
    @State private var nsTextView: NSTextView?
    @State private var lastUpdateTime = Date()
    @State private var isUpdating = false
    
    // Store a reference to the timer so we can invalidate it when needed
    @State private var formatTimer: Timer?
    
    // The system font name to use as default
    private let defaultSystemFont = ".AppleSystemUIFont"
    
    init(placeholder: String, text: Binding<String>, attributedContent: Binding<NSAttributedString?>, attachments: Binding<[ImageAttachment]>) {
        self.placeholder = placeholder
        self._text = text
        self._attributedContent = attributedContent
        self._attachments = attachments
        
        // Initialize rich text with existing content or placeholder
        let initialContent = attributedContent.wrappedValue ?? NSAttributedString(
            string: text.wrappedValue.isEmpty ? "" : text.wrappedValue,
            attributes: [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 16)
            ]
        )
        self._richText = State(initialValue: initialContent)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // Format and attachment buttons on the left
                HStack {
                    Button(action: {
                        // Set the system font before showing the sidebar
                        setupContextProperties()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isInspectorPresented.toggle()
                        }
                    }) {
                        Image(systemName: "textformat")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .help("Toggle Formatting Options")
                    
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        Image(systemName: "photo")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .frame(width: 30, height: 30)
                    }
                    .buttonStyle(.plain)
                    .help("Add image attachment")
                    
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.top, 6)
                .frame(height: 40)
                
                // Editor and sidebar as a horizontal stack
                HStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        RichTextEditor(text: $richText, context: context) { textView in
                            // Set proper insets with explicit top padding
                            textView.textContentInset = CGSize(width: 20, height: 20)
                            
                            #if os(macOS)
                            if let nsTextView = textView as? NSTextView {
                                // Save the textView reference outside of the render function
                                DispatchQueue.main.async {
                                    self.nsTextView = nsTextView
                                    // Configure the text view from an async context
                                    self.configureTextView(nsTextView)
                                }
                            }
                            #endif
                        }
                        .cornerRadius(6)
                        
                        // Use a SwiftUI Text view as placeholder that overlays the editor
                        // This is safer than trying to manipulate the NSTextView's content directly
                        if text.isEmpty {
                            Text(placeholder)
                                .foregroundColor(.gray)
                                .padding(.leading, 24)
                                .padding(.top, 24)
                                .allowsHitTesting(false)
                        }
                    }
                    .frame(width: isInspectorPresented ? geometry.size.width - 200 : geometry.size.width)

                    // Sidebar with formatting options
                    if isInspectorPresented {
                        RichTextFormat.Sidebar(context: context)
                            .frame(width: 200)
                            .background(
                                VisualEffectView(material: .sidebar, blendingMode: .withinWindow)
                                    .cornerRadius(6)
                            )
                            .cornerRadius(6)
                            // Improved animation for the sidebar
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing)
                                    .combined(with: .scale(scale: 0.92, anchor: .trailing))
                                    .combined(with: .opacity),
                                removal: .move(edge: .trailing)
                                    .combined(with: .scale(scale: 0.92, anchor: .trailing))
                                    .combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.35, dampingFraction: 0.75, blendDuration: 0), value: isInspectorPresented)
                            .onAppear {
                                // Apply settings in async context to avoid warnings
                                DispatchQueue.main.async {
                                    setupContextProperties()
                                    
                                    // Apply white text color directly to the NSTextView
                                    if let textView = nsTextView {
                                        configureTextViewColor(textView)
                                    }
                                }
                            }
                    }
                }
                .frame(height: geometry.size.height - 40) // Height minus buttons
            }
            .focusedValue(\.richTextContext, context)
            .richTextFormatSidebarConfig(
                // Re-enable font picker but with validation
                .init(fontPicker: true)
            )
            .fileImporter(
                isPresented: $showingImagePicker,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true
            ) { result in
                handleImageSelection(result)
            }
            .task {
                // Use task for async setup to avoid warnings
                setupInitialContent()
            }
            .onDisappear {
                // Invalidate timer to avoid memory leaks
                formatTimer?.invalidate()
                formatTimer = nil
                
                // Force update the content to ensure latest formatting is saved
                forceContentUpdate()
            }
        }
    }
    
    // Method to configure an NSTextView - called from async context
    private func configureTextView(_ nsTextView: NSTextView) {
        // Set default text color to white
        nsTextView.textColor = .white
        nsTextView.backgroundColor = NSColor.textBackgroundColor.withAlphaComponent(0.5)
        
        // Disable auto-correction and candidates to reduce console spam
        nsTextView.isAutomaticDashSubstitutionEnabled = false
        nsTextView.isAutomaticQuoteSubstitutionEnabled = false
        nsTextView.isAutomaticSpellingCorrectionEnabled = false
        nsTextView.smartInsertDeleteEnabled = false
        nsTextView.isAutomaticTextCompletionEnabled = false
        nsTextView.isAutomaticTextReplacementEnabled = false
        
        // Hide scrollers
        if let scrollView = nsTextView.enclosingScrollView {
            scrollView.hasVerticalScroller = false
            scrollView.hasHorizontalScroller = false
            scrollView.autohidesScrollers = true
            
            // Remember scroll position
            if !scrollPosition.equalTo(.zero) {
                scrollView.contentView.scroll(scrollPosition)
                scrollView.reflectScrolledClipView(scrollView.contentView)
            } else {
                // Initial positioning at the top
                let topPoint = NSPoint(x: 0, y: 0)
                scrollView.contentView.scroll(topPoint)
                scrollView.reflectScrolledClipView(scrollView.contentView)
            }
            
            // Save scroll position when it changes
            NotificationCenter.default.addObserver(
                forName: NSView.boundsDidChangeNotification,
                object: scrollView.contentView,
                queue: .main
            ) { _ in
                scrollPosition = scrollView.contentView.bounds.origin
            }
        }
        
        // Ensure existing images and formatting are visible
        if let attrString = attributedContent, !attrString.string.isEmpty {
            // Use exact string with all original attributes
            nsTextView.textStorage?.setAttributedString(attrString)
        } else {
            // Fix: If we're starting fresh, apply white text color explicitly
            let attrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 16)
            ]
            nsTextView.typingAttributes = attrs
            
            // If empty, create an empty string with white text
            if nsTextView.string.isEmpty {
                let emptyString = NSAttributedString(
                    string: "",
                    attributes: attrs
                )
                nsTextView.textStorage?.setAttributedString(emptyString)
            }
        }
        
        // Add a text change observer to update bindings
        NotificationCenter.default.addObserver(
            forName: NSText.didChangeNotification,
            object: nsTextView,
            queue: .main
        ) { _ in
            if let textStorage = nsTextView.textStorage {
                // Get an exact copy of the current attributed string
                let attributedStr = NSAttributedString(attributedString: textStorage)
                
                // Update bindings
                text = attributedStr.string
                
                // Debounce the updates to avoid multiple updates per frame
                debouncedUpdateContent(attributedStr)
                
                // Fix: Check if text color has changed and restore white if needed
                configureTextViewColor(nsTextView)
            }
        }
    }
    
    // Configure text view color
    private func configureTextViewColor(_ textView: NSTextView) {
        if textView.textColor != .white {
            textView.textColor = .white
            
            // Set white text color for future typing
            var typingAttrs = textView.typingAttributes
            typingAttrs[.foregroundColor] = NSColor.white
            textView.typingAttributes = typingAttrs
        }
    }
    
    // Set up context properties safely
    private func setupContextProperties() {
        DispatchQueue.main.async {
            context.fontName = defaultSystemFont
            context.fontSize = 16
        }
    }
    
    // Initialize content in an async context
    private func setupInitialContent() {
        // Set default font
        context.fontName = defaultSystemFont
        
        if let existingContent = attributedContent, existingContent.length > 0 {
            // Load the exact attributed string with all formatting
            richText = NSAttributedString(attributedString: existingContent)
            
            // Set context properties from existingContent if needed
            if let font = existingContent.attributes(at: 0, effectiveRange: nil)[.font] as? NSFont {
                context.fontSize = font.pointSize
                
                // Only use the font name if it's not Helvetica
                if !font.fontName.contains("Helvetica") {
                    context.fontName = font.fontName
                } else {
                    context.fontName = defaultSystemFont
                }
            }
        } else {
            // If starting fresh, create explicit white text
            let whiteTextAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: NSColor.white,
                .font: NSFont.systemFont(ofSize: 16)
            ]
            richText = NSAttributedString(string: "", attributes: whiteTextAttrs)
        }
        
        // Set up a timer to periodically check for formatting changes - less frequent now
        setupFormattingMonitor()
    }
    
    // Debounce update of attributedContent to avoid multiple updates per frame
    private func debouncedUpdateContent(_ attributedStr: NSAttributedString) {
        // If we're already in an update cycle, or if it's been less than 0.1 seconds since the last update, skip
        let now = Date()
        if isUpdating || now.timeIntervalSince(lastUpdateTime) < 0.1 {
            return
        }
        
        isUpdating = true
        
        // Schedule update after a short delay to debounce multiple rapid changes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.attributedContent = attributedStr
            self.richText = attributedStr
            
            // Update attachments to stay in sync
            self.updateAttachmentsFromRichText(attributedStr)
            
            // Update state
            self.lastUpdateTime = Date()
            self.isUpdating = false
        }
    }
    
    // Set up a timer to monitor formatting changes
    private func setupFormattingMonitor() {
        // Invalidate any existing timer first
        formatTimer?.invalidate()
        
        // Create a timer that checks for formatting changes every 1 second (reduced frequency)
        formatTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.captureFormattedText()
        }
    }
    
    // Capture formatted text directly from the NSTextView when formatting changes
    private func captureFormattedText() {
        // Skip if we're already in an update
        if isUpdating {
            return
        }
        
        // Get formatting directly from NSTextView
        DispatchQueue.main.async {
            forceContentUpdate()
        }
    }
    
    // Extract attachments from rich text to keep arrays in sync
    private func updateAttachmentsFromRichText(_ attributedString: NSAttributedString) {
        let range = NSRange(location: 0, length: attributedString.length)
        var newAttachments: [ImageAttachment] = []
        
        attributedString.enumerateAttribute(.attachment, in: range, options: []) { value, _, _ in
            guard let attachment = value as? NSTextAttachment else { return }
            var image: NSImage? = attachment.image
            if image == nil, let fileWrapper = attachment.fileWrapper, let data = fileWrapper.regularFileContents {
                image = NSImage(data: data)
            }
            if let image, let imageData = image.tiffRepresentation {
                let imageAttachment = ImageAttachment(id: UUID(), data: imageData)
                newAttachments.append(imageAttachment)
            }
        }
        
        // Update attachments directly
        attachments = newAttachments
    }
    
    // MARK: - Image Handling
    private func handleImageSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result else { return }
        
        for url in urls {
            guard url.startAccessingSecurityScopedResource() else { continue }
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let imageData = try Data(contentsOf: url)
                guard let nsImage = NSImage(data: imageData) else { continue }
                
                // Resize image if needed
                let maxDimension: CGFloat = 300
                let aspectRatio = nsImage.size.width / nsImage.size.height
                let newSize: NSSize
                
                if aspectRatio > 1 {
                    // Wider than tall
                    newSize = NSSize(width: maxDimension, height: maxDimension / aspectRatio)
                } else {
                    // Taller than wide
                    newSize = NSSize(width: maxDimension * aspectRatio, height: maxDimension)
                }
                
                // Resize and round corners
                let scaledImage = resizeNSImage(nsImage, to: newSize)
                let roundedImage = roundCorners(image: scaledImage, radius: 8)
                
                // Create attachment with the rounded image
                #if os(macOS)
                let attachment = NSTextAttachment()
                attachment.image = roundedImage
                let attachmentString = NSAttributedString(attachment: attachment)
                
                // Create mutable copy and insert at cursor position or append
                let mutableText = NSMutableAttributedString(attributedString: richText)
                mutableText.append(attachmentString)
                
                // Update using our debounced method
                richText = mutableText
                debouncedUpdateContent(mutableText)
                #endif
            } catch {
                // Handle error silently
            }
        }
    }

    // Helper function to resize NSImage with better quality
    private func resizeNSImage(_ image: NSImage, to newSize: NSSize) -> NSImage {
        let resizedImage = NSImage(size: newSize)
        resizedImage.lockFocus()
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(origin: .zero, size: newSize),
                  from: NSRect(origin: .zero, size: image.size),
                 operation: .copy,
                 fraction: 1.0)
        resizedImage.unlockFocus()
        return resizedImage
    }

    // Add rounded corners to images
    private func roundCorners(image: NSImage, radius: CGFloat) -> NSImage {
        let rect = NSRect(origin: .zero, size: image.size)
        let targetImage = NSImage(size: image.size)
        
        targetImage.lockFocus()
        
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        path.addClip()
        
        image.draw(in: rect)
        
        targetImage.unlockFocus()
        
        return targetImage
    }

    // Update to preserve all attributes by pulling from NSTextView
    func forceContentUpdate() {
        #if os(macOS)
        if let textView = nsTextView, let textStorage = textView.textStorage {
            // Skip if we're already in an update
            if isUpdating {
                return
            }
            
            isUpdating = true
            
            // Create a direct attributed string copy
            let finalCopy = NSAttributedString(attributedString: textStorage)
            
            // Make sure to also create an RTFD representation to test
            let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
                .documentType: NSAttributedString.DocumentType.rtfd,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            do {
                // Attempt to convert to RTFD data and back to verify formatting is preserved
                let rtfdData = try finalCopy.data(
                    from: NSRange(location: 0, length: finalCopy.length),
                    documentAttributes: documentAttributes
                )
                
                let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.rtfd,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
                
                let verifiedString = try NSAttributedString(data: rtfdData, options: options, documentAttributes: nil)
                
                // Update all bindings with verified string
                text = verifiedString.string
                attributedContent = verifiedString
                richText = verifiedString
                
                // Update last update time
                lastUpdateTime = Date()
            } catch {
                // Fallback to direct copy if RTFD conversion fails
                text = finalCopy.string
                attributedContent = finalCopy
                richText = finalCopy
            }
            
            // Reset update flag
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.isUpdating = false
            }
        }
        #endif
    }
}

// Helper to track editor frame
struct EditorBoundsPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
