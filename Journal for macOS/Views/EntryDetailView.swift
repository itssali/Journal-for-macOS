import SwiftUI

struct EntryDetailView: View {
    @Binding var entry: JournalEntry?
    let onUpdate: (JournalEntry) -> Void
    @State private var isEditing = false
    @State private var editingEntry: JournalEntry?
    @State private var selectedDate: Date
    
    init(entry: Binding<JournalEntry?>, onUpdate: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self.onUpdate = onUpdate
        self._editingEntry = State(initialValue: entry.wrappedValue)
        self._selectedDate = State(initialValue: entry.wrappedValue?.date ?? Date())
    }
    
    var body: some View {
        if let currentEntry = entry {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text(currentEntry.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
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
                                        .fill(Color(red: 0.37, green: 0.36, blue: 0.90).opacity(1))
                                )
                        }
                    }
                    
                    if !currentEntry.attachments.isEmpty {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 150))],
                            spacing: 16
                        ) {
                            ForEach(currentEntry.attachments) { attachment in
                                if let image = attachment.image {
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    Text(currentEntry.content)
                        .font(.body)
                        .lineSpacing(8)
                }
                .padding(32)
            }
        } else {
            Text("No entry selected")
                .font(.title2)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter.string(from: date)
    }
} 
