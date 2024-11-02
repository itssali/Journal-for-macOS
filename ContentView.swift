var body: some View {
    ZStack {
        HSplitView {
            // ... existing HSplitView content ...
        }
        
        CustomSheet(
            isPresented: showingNewEntry,
            content: NewEntryView(onDismiss: { showingNewEntry = false }),
            onDismiss: { showingNewEntry = false }
        )
        
        CustomSheet(
            isPresented: selectedEntry?.isEditing ?? false,
            content: EditEntryView(
                entry: Binding(
                    get: { selectedEntry ?? JournalEntry.empty },
                    set: { updatedEntry in
                        if let index = storage.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                            storage.entries[index] = updatedEntry
                            selectedEntry = updatedEntry
                            storage.saveEntries()
                        }
                    }
                ),
                onDismiss: { 
                    selectedEntry?.isEditing = false 
                }
            ),
            onDismiss: { 
                selectedEntry?.isEditing = false 
            }
        )
    }
} 