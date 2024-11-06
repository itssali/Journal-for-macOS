import SwiftUI
import SwiftUIIntrospect

struct NewEntryView: View {
    let onDismiss: () -> Void
    @StateObject private var storage = LocalStorageManager.shared
    @State private var title = ""
    @State private var content = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var attachments: [ImageAttachment] = []
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("New Entry")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 16) {
                    CustomActionButton("Cancel", role: .cancel) { 
                        onDismiss() 
                    }
                    CustomActionButton("Save", isDisabled: title.isEmpty || content.isEmpty) {
                        let entry = JournalEntry(
                            id: UUID(),
                            title: title,
                            content: content,
                            date: Date(),
                            emotions: Array(selectedEmotions),
                            tags: [],
                            wordCount: content.split(separator: " ").count,
                            attachments: attachments
                        )
                        storage.saveEntry(entry)
                        onDismiss()
                    }
                }
            }
            .padding()
            
            CustomTextField(placeholder: "Title", text: $title)
              
                .padding(.horizontal)
            
            CustomTextEditor(
                placeholder: "Write Something...", 
                text: $content,
                attachments: $attachments
            )
               
            
            EmotionSelectionView(selectedEmotions: $selectedEmotions)
        }
    }
}
