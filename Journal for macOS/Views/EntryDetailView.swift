import SwiftUI
import Orb
import AppKit

struct EntryDetailView: View {
    @Binding var entry: JournalEntry?
    let onUpdate: (JournalEntry) -> Void
    @State private var isEditing = false
    @State private var editingEntry: JournalEntry?
    @State private var selectedDate: Date
    
    // Orb configurations
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
    
    init(entry: Binding<JournalEntry?>, onUpdate: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self.onUpdate = onUpdate
        self._editingEntry = State(initialValue: entry.wrappedValue)
        self._selectedDate = State(initialValue: entry.wrappedValue?.date ?? Date())
    }
    
    var body: some View {
        Group {
            if let currentEntry = entry {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text(currentEntry.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            HStack(spacing: 16) {
                                OrbView(configuration: orbConfiguration(for: currentEntry))
                                    .frame(width: 32, height: 32)
                                
                                Button(action: { 
                                    var updatedEntry = currentEntry
                                    updatedEntry.isEditing = true
                                    entry = updatedEntry
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
                        
                        FlowLayout(spacing: 8) {
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
                        }
                        
                        // Use AttributedTextView if formatted content is available
                        if let attributedString = currentEntry.attributedContent {
                            AttributedTextView(attributedString: attributedString)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 300)
                                .background(Color.clear)
                        } else {
                            Text(currentEntry.content)
                                .font(.body)
                                .lineSpacing(8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.vertical, 24)
                }
                .background(
                    VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
                        .ignoresSafeArea()
                )
            } else {
                VStack {
                    Text("Select an entry to view")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter.string(from: date)
    }
}

// Updated AttributedTextView to properly handle inline images
struct AttributedTextView: NSViewRepresentable {
    let attributedString: NSAttributedString
    
    func makeNSView(context: Context) -> NSTextView {
        let scrollView = NSScrollView()
        let textView = NSTextView(frame: scrollView.bounds)
        
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        
        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.isRichText = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: textView.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        
        // Set the content
        textView.textStorage?.setAttributedString(attributedString)
        
        scrollView.documentView = textView
        return textView
    }
    
    func updateNSView(_ textView: NSTextView, context: Context) {
        textView.textStorage?.setAttributedString(attributedString)
        
        // Force layout update
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        textView.sizeToFit()
    }
}
