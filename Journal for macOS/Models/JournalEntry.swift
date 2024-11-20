import Foundation

struct JournalEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: String
    var date: Date
    var emotions: [String]
    var pleasantness: Double?
    var tags: [String]
    var wordCount: Int
    var isEditing: Bool = false
    var isPinned: Bool = false
    var attachments: [ImageAttachment] = []
    
    var effectivePleasantness: Double {
        pleasantness ?? EmotionSelectionView.getPleasantnessFromEmotions(Set(emotions))
    }
    
    static var empty: JournalEntry {
        JournalEntry(id: UUID(), title: "", content: "", date: Date(), emotions: [], pleasantness: 0.5, tags: [], wordCount: 0)
    }
    
    static func == (lhs: JournalEntry, rhs: JournalEntry) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.content == rhs.content &&
        lhs.date == rhs.date &&
        lhs.emotions == rhs.emotions &&
        lhs.pleasantness == rhs.pleasantness &&
        lhs.tags == rhs.tags &&
        lhs.wordCount == rhs.wordCount &&
        lhs.isEditing == rhs.isEditing &&
        lhs.isPinned == rhs.isPinned
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
