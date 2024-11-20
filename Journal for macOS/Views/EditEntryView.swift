import SwiftUI
import SwiftUIIntrospect

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
    
    init(entry: Binding<JournalEntry>, selectedEntry: Binding<JournalEntry?>, onDismiss: @escaping () -> Void) {
        self._entry = entry
        self._selectedEntry = selectedEntry
        self._title = State(initialValue: entry.wrappedValue.title)
        self._content = State(initialValue: entry.wrappedValue.content)
        self._selectedEmotions = State(initialValue: Set(entry.wrappedValue.emotions))
        self._pleasantnessValue = State(initialValue: entry.wrappedValue.effectivePleasantness)
        self._selectedDate = State(initialValue: entry.wrappedValue.date)
        self._attachments = State(initialValue: entry.wrappedValue.attachments)
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Edit Entry")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                HStack(spacing: 16) {
                    CustomActionButton("Delete", role: .destructive) {
                        storage.deleteEntry(entry)
                        if selectedEntry?.id == entry.id {
                            selectedEntry = nil
                        }
                        onDismiss()
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
        .keyboardShortcut(.return, modifiers: .shift)
    }
    
    private func saveEntry() {
        if !title.isEmpty && !content.isEmpty {
            var updatedEntry = entry
            updatedEntry.title = title
            updatedEntry.content = content
            updatedEntry.emotions = Array(selectedEmotions)
            updatedEntry.pleasantness = pleasantnessValue
            updatedEntry.attachments = attachments
            updatedEntry.wordCount = content.split(separator: " ").count
            updatedEntry.date = selectedDate
            
            storage.updateEntry(entry, with: updatedEntry)
            entry = updatedEntry
            onDismiss()
        }
    }
}
