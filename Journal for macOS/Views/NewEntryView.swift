import SwiftUI
import RichTextKit

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
    
    var body: some View {
        ZStack {
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
                
                // Title field - use CustomTextField
                CustomTextField(placeholder: "Entry Title", text: $title)
                    .padding([.leading, .trailing])
                
                // Content editor - use CustomTextEditor
                CustomTextEditor(
                    placeholder: "Write Something...", 
                    text: $content,
                    attributedContent: $attributedContent,
                    attachments: $attachments
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding([.leading, .trailing])
                .padding(.bottom, 8)
                
                VStack {
                    EmotionOrbButton(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isShowingEmotionSelection = true
                        }
                    }, progress: pleasantnessValue)
                    .frame(width: 80, height: 80)
                }
                .frame(height: 90)
                .padding(.vertical, 4)
            }
            if isShowingEmotionSelection {
                Rectangle()
                    .fill(Color.black.opacity(0.3))
                    .allowsHitTesting(true)
                    .ignoresSafeArea()
                    .accessibility(hidden: true)
                
                EmotionSelectionView(
                    selectedEmotions: $selectedEmotions,
                    pleasantnessValue: $pleasantnessValue,
                    isShowingEmotionSelection: $isShowingEmotionSelection,
                    cancelButtonIcon: "xmark.circle.fill"
                )
                .frame(width: 400, height: 500)
                .zIndex(10)
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
        .task {
            // Reset fields on appear using task rather than in view body
            resetFields()
        }
    }
    
    // Extract field reset to separate function that can be called from task
    private func resetFields() {
        title = ""
        content = ""
        selectedEmotions = []
        pleasantnessValue = 0.5
        attachments = []
        attributedContent = nil
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
            
            // Save the attributed content - this will also update attachments
            if let attrContent = attributedContent {
                // Important: Create a new attributed string to preserve all attributes
                // Don't modify the existing one as this can sometimes lose attributes
                let attrCopy = NSAttributedString(attributedString: attrContent)
                entry.setAttributedContent(attrCopy)
            }
            
            // Add the entry to storage
            DispatchQueue.main.async {
                storage.addEntry(entry)
                onDismiss()
            }
        }
    }
}
