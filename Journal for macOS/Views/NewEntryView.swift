import SwiftUI
import SwiftUIIntrospect

struct NewEntryView: View {
    let onDismiss: () -> Void
    @StateObject private var storage = LocalStorageManager.shared
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var pleasantnessValue: Double = 0.5
    @State private var isShowingEmotionSelection = false
    @State private var attachments: [ImageAttachment] = []
    @State private var attributedContent: NSAttributedString?
    @State private var showingCancelAlert = false
    
    // Reference to the text editor to access formatted content
    @State private var textEditor: CustomTextEditor?
    
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
            
            // Pass the textEditor reference so we can access it later
            let editor = CustomTextEditor(
                placeholder: "Write Something...", 
                text: $content,
                attachments: $attachments,
                attributedContent: $attributedContent
            )
            editor
                .padding(.horizontal)
                .padding(.bottom, 16)
                .onAppear {
                    self.textEditor = editor
                }
            
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
            // Create the entry
            var entry = JournalEntry(
                id: UUID(),
                title: title,
                content: content,
                date: Date(),
                emotions: Array(selectedEmotions),
                pleasantness: pleasantnessValue,
                tags: [],
                wordCount: content.split(separator: " ").count,
                isEditing: false,
                isPinned: false,
                attachments: attachments
            )
            
            // Save the formatted content if available
            if let attrString = attributedContent {
                entry.setAttributedContent(attrString)
            }
            
            // Add the entry to storage
            DispatchQueue.main.async {
                storage.addEntry(entry)
                onDismiss()
            }
        }
    }
}
