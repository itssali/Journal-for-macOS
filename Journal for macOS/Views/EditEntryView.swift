import SwiftUI
import SwiftUIIntrospect

struct EditEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storage = LocalStorageManager.shared
    @Binding var entry: JournalEntry
    @State private var title: String
    @State private var content: String
    @State private var selectedEmotions: Set<String>
    
    let emotions = ["Happy", "Sad", "Anxious", "Excited", "Angry", "Peaceful"]
    
    init(entry: Binding<JournalEntry>) {
        _entry = entry
        _title = State(initialValue: entry.wrappedValue.title)
        _content = State(initialValue: entry.wrappedValue.content)
        _selectedEmotions = State(initialValue: Set(entry.wrappedValue.emotions))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Edit Entry")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                Button("Cancel") { dismiss() }
            }
            .padding()
            
            CustomTextField(placeholder: "Title", text: $title)
                .padding(.horizontal)
            
            CustomTextEditor(placeholder: "Content", text: $content)
                .frame(height: 200)
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
            
            Button("Save") {
                entry = JournalEntry(
                    id: entry.id,
                    title: title,
                    content: content,
                    date: entry.date,
                    emotions: Array(selectedEmotions),
                    tags: entry.tags,
                    wordCount: content.split(separator: " ").count
                )
                storage.updateEntry(entry)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(title.isEmpty || content.isEmpty)
            .padding()
        }
        .frame(width: 600, height: 600)
    }
} 
