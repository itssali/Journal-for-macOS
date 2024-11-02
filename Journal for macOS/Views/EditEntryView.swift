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
    
    let emotions = ["Happy", "Sad", "Anxious", "Excited", "Angry", "Peaceful"]
    
    init(entry: Binding<JournalEntry>, onDismiss: @escaping () -> Void) {
        _entry = entry
        _title = State(initialValue: entry.wrappedValue.title)
        _content = State(initialValue: entry.wrappedValue.content)
        _selectedEmotions = State(initialValue: Set(entry.wrappedValue.emotions))
        self.onDismiss = onDismiss
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
                            date: entry.date,
                            emotions: Array(selectedEmotions),
                            tags: entry.tags,
                            wordCount: content.split(separator: " ").count
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
            
            VStack(alignment: .leading) {
                Text("How are you feeling?")
                    .font(.headline)
                FlowLayout(spacing: 8) {
                    ForEach(emotions, id: \.self) { emotion in
                        EmotionButton(
                            emotion: emotion,
                            isSelected: selectedEmotions.contains(emotion)
                        ) {
                            if selectedEmotions.contains(emotion) {
                                selectedEmotions.remove(emotion)
                            } else {
                                selectedEmotions.insert(emotion)
                            }
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
       
    }
} 
