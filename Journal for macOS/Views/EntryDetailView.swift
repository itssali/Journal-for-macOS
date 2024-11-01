import SwiftUI

struct EntryDetailView: View {
    let entry: JournalEntry
    let onUpdate: (JournalEntry) -> Void
    @State private var isEditing = false
    @State private var editingEntry: JournalEntry
    
    init(entry: JournalEntry, onUpdate: @escaping (JournalEntry) -> Void) {
        self.entry = entry
        self.onUpdate = onUpdate
        _editingEntry = State(initialValue: entry)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text(editingEntry.title)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button(action: { isEditing.toggle() }) {
                        Image(systemName: "pencil")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Text(formatDate(editingEntry.date))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                FlowLayout(spacing: 8) {
                    ForEach(editingEntry.emotions, id: \.self) { emotion in
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
                
                Text(editingEntry.content)
                    .font(.body)
                    .lineSpacing(8)
            }
            .padding(32)
            .id(editingEntry.id)
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: editingEntry.id)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $isEditing) {
            EditEntryView(entry: Binding(
                get: { editingEntry },
                set: { newValue in
                    editingEntry = newValue
                    onUpdate(newValue)
                }
            ))
            .sheetTransition(isPresented: isEditing)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM yyyy"
        return formatter.string(from: date)
    }
} 