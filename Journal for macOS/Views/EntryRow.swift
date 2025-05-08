import SwiftUI
import AppKit

struct CircularButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 44, height: 44)
            .background(Circle().fill(color))
            .foregroundColor(.white)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
    }
}

struct CustomCircularButton: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}

struct EntryRow: View {
    @StateObject private var storage = LocalStorageManager.shared
    let entry: JournalEntry
    @Binding var selectedEntry: JournalEntry?
    @State private var viewHeight: CGFloat = 0
    
    private var isSelected: Bool {
        selectedEntry?.id == entry.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Content preview
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title.isEmpty ? "Untitled" : entry.title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                if let attributedString = entry.attributedContent {
                    Text(attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(entry.content.trimmingCharacters(in: .whitespacesAndNewlines))
                        .font(.subheadline)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
            }
            
            // Bottom row with metadata and thumbnails
            HStack(alignment: .center) {
                // Date
                Text(entry.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                
                Spacer()
                
                // Image thumbnails
                if !entry.attachments.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(entry.attachments.prefix(4)) { attachment in
                            if let image = attachment.image {
                                Image(nsImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                            }
                        }
                        if entry.attachments.count > 4 {
                            Text("+\(entry.attachments.count - 4)")
                                .font(.caption)
                                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                                .frame(width: 40, height: 40)
                                .background(Color.secondary.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
            
            // Emotions if present
            if !entry.emotions.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(entry.emotions, id: \.self) { emotion in
                        Text(emotion)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.1))
                            )
                            .foregroundColor(isSelected ? .white : .secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                var newEntry = entry
                newEntry.isEditing = false
                selectedEntry = newEntry
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                var updatedEntry = entry
                updatedEntry.isPinned.toggle()
                storage.updateEntry(entry, with: updatedEntry)
                
                if selectedEntry?.id == entry.id {
                    selectedEntry = updatedEntry
                }
            } label: {
                Image(systemName: entry.isPinned ? "pin.fill" : "pin")
                    .foregroundColor(entry.isPinned ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                storage.deleteEntry(entry)
                if selectedEntry?.id == entry.id {
                    selectedEntry = nil
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red.opacity(0.7))

            Button {
                var updatedEntry = entry
                updatedEntry.isEditing = true
                selectedEntry = updatedEntry
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        
    }
    
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }
}

// Component for displaying formatted text preview
struct AttributedTextPreview: NSViewRepresentable {
    let attributedString: NSAttributedString
    
    func makeNSView(context: Context) -> NSTextView {
        let textView = NSTextView()
        textView.isEditable = false
        textView.isSelectable = false
        textView.drawsBackground = false
        textView.backgroundColor = .clear
        textView.textContainer?.widthTracksTextView = true
        textView.isRichText = true
        textView.textColor = NSColor.secondaryLabelColor
        
        // Set the content
        textView.textStorage?.setAttributedString(attributedString)
        
        return textView
    }
    
    func updateNSView(_ textView: NSTextView, context: Context) {
        textView.textStorage?.setAttributedString(attributedString)
    }
}

#Preview {
    let sampleEntry = JournalEntry(
        id: UUID(),
        title: "My First Entry",
        content: "This is a sample journal entry with multiple lines of text to test how the layout works with longer content. It should show exactly three lines before truncating.",
        date: Date(),
        emotions: ["Happy", "Excited", "Peaceful", "Grateful"],
        pleasantness: 0.8,
        tags: [],
        wordCount: 27
    )
    
    List {
        EntryRow(
            entry: sampleEntry,
            selectedEntry: .constant(sampleEntry)  // This one will be highlighted
        )
        
        EntryRow(
            entry: JournalEntry(
                id: UUID(),
                title: "Another Entry",
                content: "A shorter entry to test different lengths.",
                date: Date().addingTimeInterval(-86400),
                emotions: ["Calm", "Focused"],
                pleasantness: 0.6,
                tags: [],
                wordCount: 8
            ),
            selectedEntry: .constant(nil)  // This one won't be highlighted
        )
    }
    .frame(width: 400, height: 300)
}
