import SwiftUI
import SwiftUIIntrospect

struct NewEntryView: View {
    let onDismiss: () -> Void
    @StateObject private var storage = LocalStorageManager.shared
    @State private var title = ""
    @State private var content = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var pleasantnessValue: Double = 0.5
    @State private var isShowingEmotionSelection: Bool = false
    @State private var attachments: [ImageAttachment] = []
    @State private var showingCancelAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("New Entry")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 16) {
                    CustomActionButton("Cancel", role: .cancel) { 
                        if !title.isEmpty || !content.isEmpty {
                            showingCancelAlert = true
                        } else {
                            onDismiss()
                        }
                    }
                    CustomActionButton("Save", isDisabled: title.isEmpty || content.isEmpty) {
                        saveEntry()
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
            .padding(.horizontal)
            .padding(.bottom, 16)
            
            VStack {
                EmotionOrbButton(action: {
                    withAnimation(.spring(response: 0.3)) {
                        isShowingEmotionSelection = true
                    }
                }, progress: pleasantnessValue)
                .frame(width: 80, height: 80)
            }
            .frame(height: 100)
            .padding(.vertical, 8)
        }
        .overlay {
            if isShowingEmotionSelection {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                isShowingEmotionSelection = false
                            }
                        }
                        .transition(.opacity)
                    
                    EmotionSelectionView(
                        selectedEmotions: $selectedEmotions,
                        pleasantnessValue: $pleasantnessValue,
                        isShowingEmotionSelection: $isShowingEmotionSelection,
                        cancelButtonIcon: "xmark.circle.fill"
                    )
                    .transition(.move(edge: .bottom))
                }
            }
        }
        .alert("Discard Changes?", isPresented: $showingCancelAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Discard", role: .destructive) {
                onDismiss()
            }
        } message: {
            Text("All your changes will be lost.")
        }
        .keyboardShortcut(.return, modifiers: .shift)
    }
    
    private func saveEntry() {
        if !title.isEmpty && !content.isEmpty {
            let entry = JournalEntry(
                id: UUID(),
                title: title,
                content: content,
                date: Date(),
                emotions: Array(selectedEmotions),
                pleasantness: pleasantnessValue,
                tags: [],
                wordCount: content.split(separator: " ").count,
                attachments: attachments
            )
            storage.saveEntry(entry)
            onDismiss()
        }
    }
}
