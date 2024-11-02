import CloudKit
import Foundation

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    private let container = CKContainer(identifier: "iCloud.NasserInc.Journal-for-macOS")
    
    @Published var entries: [JournalEntry] = []
    
    func fetchEntries() async throws {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "JournalEntry", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        let result = try await container.privateCloudDatabase.records(matching: query)
        let records = result.matchResults.compactMap { try? $0.1.get() }
        let entries = records.compactMap { JournalEntry(from: $0) }
        
        await MainActor.run {
            self.entries = entries
        }
    }
    
    func saveEntry(_ entry: JournalEntry) async throws {
        let record = entry.cloudKitRecord
        try await container.privateCloudDatabase.save(record)
    }
}
