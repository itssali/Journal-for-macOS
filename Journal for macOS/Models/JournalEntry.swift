import Foundation
import CloudKit

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let content: String
    let date: Date
    let emotions: [String]
    let tags: [String]
    let wordCount: Int
    var isEditing: Bool = false
    var isPinned: Bool = false
    
    static var empty: JournalEntry {
        JournalEntry(id: UUID(), title: "", content: "", date: Date(), emotions: [], tags: [], wordCount: 0)
    }
    
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.emotions == rhs.emotions &&
        lhs.tags == rhs.tags &&
        lhs.wordCount == rhs.wordCount &&
        lhs.isEditing == rhs.isEditing &&
        lhs.isPinned == rhs.isPinned
    }
}

extension JournalEntry {
    var cloudKitRecord: CKRecord {
        let record = CKRecord(recordType: "JournalEntry")
        record["id"] = id.uuidString
        record["title"] = title
        record["content"] = content
        record["date"] = date
        record["emotions"] = emotions
        record["tags"] = tags
        record["wordCount"] = wordCount
        return record
    }
    
    init?(from record: CKRecord) {
        guard 
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let title = record["title"] as? String,
            let content = record["content"] as? String,
            let date = record["date"] as? Date,
            let emotions = record["emotions"] as? [String],
            let tags = record["tags"] as? [String],
            let wordCount = record["wordCount"] as? Int
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.emotions = emotions
        self.tags = tags
        self.wordCount = wordCount
        self.isEditing = false
        self.isPinned = false
    }
}
