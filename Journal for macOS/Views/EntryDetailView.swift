import SwiftUI
// Import Orb conditionally to avoid error if not available
#if canImport(Orb)
import Orb
#endif
import AppKit
import Foundation

struct EntryDetailView: View {
    @Binding var entry: JournalEntry?
    let onUpdate: (JournalEntry) -> Void
    @State private var isEditing = false
    @State private var editingEntry: JournalEntry?
    @State private var selectedDate: Date
    
    // Orb configurations
    #if canImport(Orb)
    private let shadowOrb = OrbConfiguration(
        backgroundColors: [.black, .gray],
        glowColor: .gray,
        coreGlowIntensity: 0.7,
        showParticles: false,
        showShadow: true,
        speed: 20
    )

    private let cosmicOrb = OrbConfiguration(
        backgroundColors: [.purple, .pink, .blue],
        glowColor: .white,
        coreGlowIntensity: 1.5,
        showShadow: true,
        speed: 20
    )

    private let sunsetOrb = OrbConfiguration(
        backgroundColors: [.orange, .red, .pink],
        glowColor: .orange,
        coreGlowIntensity: 0.8,
        showShadow: true,
        speed: 20
    )

    private let minimalOrb = OrbConfiguration(
        backgroundColors: [.gray, .white],
        glowColor: .white,
        showWavyBlobs: false,
        showParticles: false,
        speed: 20
    )

    private let natureOrb = OrbConfiguration(
        backgroundColors: [.green, .mint, .teal],
        glowColor: .green,
        showShadow: true,
        speed: 20
    )

    private let oceanOrb = OrbConfiguration(
        backgroundColors: [.blue, .cyan, .teal],
        glowColor: .cyan,
        showShadow: true,
        speed: 20
    )

    private let fireOrb = OrbConfiguration(
        backgroundColors: [.red, .orange, .yellow],
        glowColor: .orange,
        coreGlowIntensity: 1.3,
        showShadow: true,                        
        speed: 20
    )
    #endif
    
    init(entry: Binding<JournalEntry?>, onUpdate: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self.onUpdate = onUpdate
        self._editingEntry = State(initialValue: entry.wrappedValue)
        self._selectedDate = State(initialValue: entry.wrappedValue?.date ?? Date())
        self._isEditing = State(initialValue: entry.wrappedValue?.isEditing ?? false)
    }
    
    var body: some View {
        ZStack {
            if let currentEntry = entry {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(currentEntry.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                #if canImport(Orb)
                                OrbView(configuration: orbConfiguration(for: currentEntry))
                                    .frame(width: 32, height: 32)
                                #else
                                Circle()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.secondary)
                                #endif
                                
                                Button(action: { 
                                    isEditing = true
                                    var updatedEntry = currentEntry
                                    updatedEntry.isEditing = true
                                    onUpdate(updatedEntry)
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.secondary)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        
                        Text(formatDate(currentEntry.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // Handle missing FlowLayout
                        HStack(spacing: 8) {
                            ForEach(currentEntry.emotions, id: \.self) { emotion in
                                Text(emotion)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        RoundedRectangle(cornerRadius: 6)
                                            .fill(Color(red: 0.37, green: 0.36, blue: 0.90).opacity(0.1))
                                    )
                            }
                            Spacer()
                        }
                        .padding(.bottom, 8)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)

                    Divider()
                        .padding(.horizontal, 24)
                    
                    // Scrollable content
                    if let attributedString = currentEntry.attributedContent {
                        FullyScrollableAttributedTextView(attributedString: attributedString)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(.vertical, showsIndicators: false) {
                            Text(currentEntry.content)
                                .font(.body)
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.horizontal, .top], 32)
                                .padding(.bottom, 100)
                        }
                    }
                }
                .id(currentEntry.id)
                .transition(.opacity)
            } else {
                VStack {
                    Text("Select an entry to view")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.18), value: entry)
        .background(
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
        .onChange(of: isEditing) { _, newValue in
            if !newValue, let currentEntry = entry {
                var updatedEntry = currentEntry
                updatedEntry.isEditing = false
                onUpdate(updatedEntry)
            }
        }
        .onChange(of: entry?.isEditing) { _, newValue in
            if let isEditingValue = newValue {
                isEditing = isEditingValue
            }
        }
    }
    
    #if canImport(Orb)
    private func orbConfiguration(for entry: JournalEntry) -> OrbConfiguration {
        let progress = (entry.effectivePleasantness - 0.5) * 2 // Convert 0-1 to -1 to 1
        
        switch progress {
        case ...(-0.715):
            return shadowOrb
        case -0.715...(-0.429):
            return cosmicOrb
        case -0.429...(-0.143):
            return sunsetOrb
        case -0.143...0.143:
            return minimalOrb
        case 0.143...0.429:
            return natureOrb
        case 0.429...0.715:
            return oceanOrb
        default:
            return fireOrb
        }
    }
    #endif
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter.string(from: date)
    }
}

// Completely rewritten AttributedTextView that ensures full scrolling capability
struct FullyScrollableAttributedTextView: NSViewRepresentable {
    let attributedString: NSAttributedString
    
    func makeNSView(context: Context) -> NSScrollView {
        // Create a proper NSScrollView with scrollers
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.backgroundColor = .clear
        scrollView.contentView.backgroundColor = .clear
        
        // Create and configure the text view
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 32, height: 32)
        textView.isRichText = true
        
        // Configure for vertical resizing but fixed width
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        
        // Set up text container for proper text wrapping
        let textContainer = textView.textContainer!
        textContainer.widthTracksTextView = true
        textContainer.containerSize = NSSize(
            width: scrollView.bounds.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        // Create a temporary RTFD representation to ensure all attributes are preserved
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            // Convert to RTFD data and back to ensure all attributes are preserved
            let rtfdData = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: documentAttributes
            )
            
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.rtfd,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let verifiedString = try NSAttributedString(data: rtfdData, options: options, documentAttributes: nil)
            
            // Use the verified string
            textView.textStorage?.setAttributedString(verifiedString)
        } catch {
            // Fall back to direct setting if RTFD conversion fails
            textView.textStorage?.setAttributedString(attributedString)
        }
        
        // Set text view as document view of scroll view
        scrollView.documentView = textView
        
        return scrollView
    }
    
    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        guard let textView = scrollView.documentView as? NSTextView else { return }
        
        // Create a temporary RTFD representation to ensure all attributes are preserved
        let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtfd,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        do {
            // Convert to RTFD data and back to ensure all attributes are preserved
            let rtfdData = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: documentAttributes
            )
            
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.rtfd,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            let verifiedString = try NSAttributedString(data: rtfdData, options: options, documentAttributes: nil)
        
            // Use the verified string
            textView.textStorage?.setAttributedString(verifiedString)
        } catch {
            // Fall back to direct setting if RTFD conversion fails
            textView.textStorage?.setAttributedString(attributedString)
        }
        
        // Update container size
        let textContainer = textView.textContainer!
        textContainer.containerSize = NSSize(
            width: scrollView.contentView.bounds.width,
            height: CGFloat.greatestFiniteMagnitude
        )
        
        // Force layout update
        textView.layoutManager?.ensureLayout(for: textContainer)
    }
}
