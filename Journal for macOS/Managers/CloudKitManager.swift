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
        
        _ = try await container.privateCloudDatabase.records(matching: query)
        // Process and update entries
    }
    
    func saveEntry(_ entry: JournalEntry) async throws {
        let record = entry.cloudKitRecord
        try await container.privateCloudDatabase.save(record)
    }
}
