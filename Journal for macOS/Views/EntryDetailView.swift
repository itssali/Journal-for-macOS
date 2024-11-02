import SwiftUI

struct EntryDetailView: View {
    @Binding var entry: JournalEntry?
    let onUpdate: (JournalEntry) -> Void
    @State private var isEditing = false
    @State private var editingEntry: JournalEntry?
    
    init(entry: Binding<JournalEntry?>, onUpdate: @escaping (JournalEntry) -> Void) {
        self._entry = entry
        self.onUpdate = onUpdate
        self._editingEntry = State(initialValue: entry.wrappedValue)
    }
    
    var body: some View {
        if let editingEntry = editingEntry {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text(editingEntry.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Button(action: { 
                                entry?.isEditing = true 
                            }) {
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
                                            .fill(Color(red: 0.37, green: 0.36, blue: 0.90).opacity(1))
                                    )
                            }
                        }
                        
                        Text(editingEntry.content)
                            .font(.body)
                            .lineSpacing(8)
                    }
                    .padding(32)
                }
                
                CustomSheet(
                    isPresented: isEditing,
                    content: EditEntryView(
                        entry: Binding(
                            get: { editingEntry },
                            set: { newValue in
                                self.editingEntry = newValue
                                self.entry = newValue
                                onUpdate(newValue)
                            }
                        ),
                        onDismiss: { isEditing = false }
                    ),
                    onDismiss: { isEditing = false }
                )
            }
            .onAppear {
                self.editingEntry = entry
            }
            .onChange(of: entry) { oldValue, newValue in
                if let newValue {
                    self.editingEntry = newValue
                }
                
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
