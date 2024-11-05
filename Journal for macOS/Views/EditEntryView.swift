import SwiftUI
import SwiftUIIntrospect

struct EditEntryView: View {
    let onDismiss: () -> Void
    @StateObject private var storage = LocalStorageManager.shared
    @Binding var entry: JournalEntry
    @State private var title: String
    @State private var content: String
    @State private var selectedEmotions: Set<String>
    @State private var showingAnimation = false
    @State private var selectedDate: Date
    
    init(entry: Binding<JournalEntry>, onDismiss: @escaping () -> Void) {
        self._entry = entry
        self.onDismiss = onDismiss
        self._title = State(initialValue: entry.wrappedValue.title)
        self._content = State(initialValue: entry.wrappedValue.content)
        self._selectedDate = State(initialValue: entry.wrappedValue.date)
        self._selectedEmotions = State(initialValue: Set(entry.wrappedValue.emotions))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(role: .destructive) {
                    if let index = storage.entries.firstIndex(where: { $0.id == entry.id }) {
                        storage.entries.remove(at: index)
                        storage.saveEntries()
                        onDismiss()
                    }
                } label: {
                    Label("Delete Entry", systemImage: "trash")
                }
                Spacer()
                HStack(spacing: 16) {
                    Button("Cancel") { onDismiss() }
                    Button("Save") {
                        let updatedEntry = JournalEntry(
                            id: entry.id,
                            title: title,
                            content: content,
                            date: selectedDate,
                            emotions: Array(selectedEmotions),
                            tags: entry.tags,
                            wordCount: content.split(separator: " ").count,
                            isEditing: false,
                            isPinned: entry.isPinned
                        )
                        entry = updatedEntry
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
            .padding()
            
            CustomTextField(placeholder: "Title", text: $title)
                .padding(.horizontal)
            
            CustomTextEditor(placeholder: "Content", text: $content)
                .padding(.horizontal)
            
            EmotionSelectionView(selectedEmotions: $selectedEmotions)
            
            DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                .padding(.horizontal)
                .datePickerStyle(.field)
            
            Spacer()
        }
       
    }
} 
