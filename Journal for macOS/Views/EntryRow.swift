import SwiftUI

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

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if entry.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            FlowLayout(spacing: 6) {
                ForEach(entry.emotions, id: \.self) { emotion in
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
                
                Text("\(entry.wordCount) words")
                    .font(.caption)
            }
        }
        .padding(12)
        .padding(.vertical, 8)
        .background(
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedEntry?.id == entry.id ? 
                          Color.customAccent.opacity(0.15) : 
                          Color.clear)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        )
        .animation(.easeInOut(duration: 0.2), value: selectedEntry?.id)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                var newEntry = entry
                newEntry.isEditing = false  // Explicitly set isEditing to false
                selectedEntry = newEntry
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                if let index = storage.entries.firstIndex(where: { $0.id == entry.id }) {
                    if !entry.isPinned {
                        if let pinnedIndex = storage.entries.firstIndex(where: { $0.isPinned }) {
                            var pinnedEntry = storage.entries[pinnedIndex]
                            pinnedEntry.isPinned = false
                            storage.entries[pinnedIndex] = pinnedEntry
                        }
                    }
                    
                    var updatedEntry = storage.entries[index]
                    updatedEntry.isPinned.toggle()
                    storage.entries[index] = updatedEntry
                    storage.saveEntries()
                }
            } label: {
                Label(entry.isPinned ? "Unpin" : "Pin", 
                      systemImage: entry.isPinned ? "pin.slash.fill" : "pin.fill")
            }
            .tint(.yellow.opacity(0.7))
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
