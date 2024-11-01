import Foundation
import CloudKit

struct JournalEntry: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var title: String
    var content: String
    var date: Date
    var emotions: [String]
    var tags: [String]
    var wordCount: Int
    
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.emotions == rhs.emotions &&
        lhs.tags == rhs.tags &&
        lhs.wordCount == rhs.wordCount
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
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
}
