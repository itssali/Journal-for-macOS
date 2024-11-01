import Foundation

class LocalStorageManager: ObservableObject {
    static let shared = LocalStorageManager()
    @Published var entries: [JournalEntry] = []
    
    private let entriesKey = "journal_entries"
    
    init() {
        loadEntries()
    }
    
    func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey) {
            if let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
                entries = decoded
            }
        }
    }
    
    func saveEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    func updateEntry(_ updatedEntry: JournalEntry) {
        if let index = entries.firstIndex(where: { $0.id == updatedEntry.id }) {
            entries[index] = updatedEntry
            saveEntries()
        }
    }
}
