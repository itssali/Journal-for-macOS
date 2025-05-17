import SwiftUI
import RichTextKit

struct EditEntryView: View {
    @StateObject private var storage = LocalStorageManager.shared
    let onDismiss: () -> Void
    @Binding var entry: JournalEntry
    @Binding var selectedEntry: JournalEntry?
    @State private var title: String
    @State private var content: String
    @State private var selectedEmotions: Set<String>
    @State private var pleasantnessValue: Double
    @State private var isShowingEmotionSelection = false
    @State private var selectedDate: Date
    @State private var attachments: [ImageAttachment]
    @State private var attributedContent: NSAttributedString?
    
    init(entry: Binding<JournalEntry>, selectedEntry: Binding<JournalEntry?>, onDismiss: @escaping () -> Void) {
        self._entry = entry
        self._selectedEntry = selectedEntry
        self._title = State(initialValue: entry.wrappedValue.title)
        self._content = State(initialValue: entry.wrappedValue.content)
        self._selectedEmotions = State(initialValue: Set(entry.wrappedValue.emotions))
        self._pleasantnessValue = State(initialValue: entry.wrappedValue.effectivePleasantness)
        self._selectedDate = State(initialValue: entry.wrappedValue.date)
        self._attachments = State(initialValue: entry.wrappedValue.attachments)
        self._attributedContent = State(initialValue: entry.wrappedValue.attributedContent)
        
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                HStack {
                    Text("Edit Entry")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                    HStack(spacing: 16) {
                        CustomActionButton("Delete", role: .destructive) {
                            handleDelete()
                        }
                        CustomActionButton("Cancel", role: .cancel) { 
                            onDismiss() 
                        }
                        CustomActionButton("Save", isDisabled: title.isEmpty || content.isEmpty) {
                            saveEntry()
                        }
                    }
                }
                .padding()
                
                // Title field - use CustomTextField instead
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
        .keyboardShortcut(.return, modifiers: .shift)
    }
    
    // Extract delete functionality to a separate method
    private func handleDelete() {
        DispatchQueue.main.async {
            storage.deleteEntry(entry)
            if selectedEntry?.id == entry.id {
                selectedEntry = nil
            }
            onDismiss()
        }
    }
    
    private func saveEntry() {
        if !title.isEmpty && !content.isEmpty {
            var updatedEntry = JournalEntry(
                id: entry.id, 
                title: title,
                content: content,
                date: selectedDate,
                emotions: Array(selectedEmotions),
                pleasantness: pleasantnessValue,
                tags: entry.tags,
                wordCount: content.split(separator: " ").count,
                isEditing: false,
                isPinned: entry.isPinned,
                attachments: attachments
            )
            
            // Update with current formatted content
            if let attrContent = attributedContent {
                // Create an RTFD representation to ensure all formatting is preserved
                let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
                    .documentType: NSAttributedString.DocumentType.rtfd,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ]
                
                do {
                    // Convert to RTFD data and back to ensure all attributes are preserved
                    let rtfdData = try attrContent.data(
                        from: NSRange(location: 0, length: attrContent.length),
                        documentAttributes: documentAttributes
                    )
                    
                    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                        .documentType: NSAttributedString.DocumentType.rtfd,
                        .characterEncoding: String.Encoding.utf8.rawValue
                    ]
                    
                    let verifiedString = try NSAttributedString(data: rtfdData, options: options, documentAttributes: nil)
                
                    // Use the verified string for saving
                    updatedEntry.setAttributedContent(verifiedString)
                } catch {
                    // Fall back to direct setting if RTFD conversion fails
                    updatedEntry.setAttributedContent(attrContent)
                }
            }
            
            // Update storage and references in async context
            DispatchQueue.main.async {
                storage.updateEntry(entry, with: updatedEntry)
                entry = updatedEntry
                
                if selectedEntry?.id == entry.id {
                    selectedEntry = updatedEntry
                }
                
                onDismiss()
            }
        }
    }
}
