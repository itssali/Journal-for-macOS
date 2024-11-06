import SwiftUI
import SwiftUIIntrospect

struct EditEntryView: View {
    let onDismiss: () -> Void
    @StateObject private var storage = LocalStorageManager.shared
    @Binding var entry: JournalEntry
    @Binding var selectedEntry: JournalEntry?
    @State private var title: String
    @State private var content: String
    @State private var selectedEmotions: Set<String>
    @State private var showingAnimation = false
    @State private var selectedDate: Date
    @State private var attachments: [ImageAttachment] = []
    
    init(entry: Binding<JournalEntry>, selectedEntry: Binding<JournalEntry?>, onDismiss: @escaping () -> Void) {
        self._entry = entry
        self._selectedEntry = selectedEntry
        self.onDismiss = onDismiss
        self._title = State(initialValue: entry.wrappedValue.title)
        self._content = State(initialValue: entry.wrappedValue.content)
        self._selectedDate = State(initialValue: entry.wrappedValue.date)
        self._selectedEmotions = State(initialValue: Set(entry.wrappedValue.emotions))
        self._attachments = State(initialValue: entry.wrappedValue.attachments)
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
                        if let index = storage.entries.firstIndex(where: { $0.id == entry.id }) {
                            var updatedEntry = entry
                            updatedEntry.title = title
                            updatedEntry.content = content
                            updatedEntry.emotions = Array(selectedEmotions)
                            updatedEntry.attachments = attachments
                            updatedEntry.wordCount = content.split(separator: " ").count
                            updatedEntry.date = selectedDate
                            
                            storage.entries[index] = updatedEntry
                            storage.saveEntries()
                            entry = updatedEntry  // Update the binding
                        }
                        onDismiss()
                    }
                }
            }
            .padding(.top, 12)
            .padding(.horizontal)
            .padding(.bottom, 8)
            
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

struct CustomDatePicker: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        HStack {
            DatePicker("Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.field)
                .frame(maxWidth: .infinity)
            
            Button {
                selectedDate = Date()
            } label: {
                Text("Today")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
} 
