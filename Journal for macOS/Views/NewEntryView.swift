import SwiftUI
import SwiftUIIntrospect

struct NewEntryView: View {
    let onDismiss: () -> Void
    @StateObject private var storage = LocalStorageManager.shared
    @State private var title = ""
    @State private var content = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var showingSaveAnimation = false
    @State private var showingAnimation = false
    
    let emotions = ["Happy", "Sad", "Anxious", "Excited", "Angry", "Peaceful"]
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("New Entry")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 16) {
                    Button("Cancel") { onDismiss() }
                    Button("Save") {
                        let entry = JournalEntry(
                            id: UUID(),
                            title: title,
                            content: content,
                            date: Date(),
                            emotions: Array(selectedEmotions),
                            tags: [],
                            wordCount: content.split(separator: " ").count
                        )
                        storage.saveEntry(entry)
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
