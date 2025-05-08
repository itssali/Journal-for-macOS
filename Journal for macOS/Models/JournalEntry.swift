import Foundation
import AppKit

// Import necessary modules
import SwiftUI

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
    var formattedContent: Data? = nil
    
    var effectivePleasantness: Double {
        // Provide a default calculation if EmotionSelectionView is not available
        pleasantness ?? 0.5
    }
    
    // Helper to get attributed string content
    var attributedContent: NSAttributedString? {
        guard let data = formattedContent else {
            // If no formatted content exists, create one from plain text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 14),
                .foregroundColor: NSColor.textColor
            ]
            return NSAttributedString(string: content, attributes: attributes)
        }
        
        do {
            return try NSAttributedString(data: data, 
                                        options: [.documentType: NSAttributedString.DocumentType.rtfd],
                                        documentAttributes: nil)
        } catch {
            print("Error converting data to NSAttributedString: \(error)")
            return nil
        }
    }
    
    // Helper to set attributed string content
    mutating func setAttributedContent(_ attributedString: NSAttributedString) {
        do {
            // Save both plain text and formatted version
            content = attributedString.string
            formattedContent = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd]
            )
            
            // Update word count
            wordCount = content.split(separator: " ").count
            
            // Clear attachments if there are no images in the content
            let range = NSRange(location: 0, length: attributedString.length)
            var hasAttachments = false
            attributedString.enumerateAttribute(.attachment, in: range, options: []) { value, _, stop in
                if value != nil {
                    hasAttachments = true
                    stop.pointee = true
                }
            }
            
            if !hasAttachments {
                attachments = []
            }
        } catch {
            print("Error converting NSAttributedString to data: \(error)")
            // On error, at least save the plain text
            content = attributedString.string
        }
    }
    
    // Standard initializer
    init(id: UUID, title: String, content: String, date: Date, emotions: [String], pleasantness: Double?, tags: [String], wordCount: Int, isEditing: Bool = false, isPinned: Bool = false, attachments: [ImageAttachment] = [], formattedContent: Data? = nil) {
        self.id = id
        self.title = title
        self.content = content
        self.date = date
        self.emotions = emotions
        self.pleasantness = pleasantness
        self.tags = tags
        self.wordCount = wordCount
        self.isEditing = isEditing
        self.isPinned = isPinned
        self.attachments = attachments
        self.formattedContent = formattedContent
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
    
    // For backward compatibility with older entries
    enum CodingKeys: String, CodingKey {
        case id, title, content, date, emotions, pleasantness, tags, 
             wordCount, isEditing, isPinned, attachments, formattedContent
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(content, forKey: .content)
        try container.encode(date, forKey: .date)
        try container.encode(emotions, forKey: .emotions)
        try container.encode(pleasantness, forKey: .pleasantness)
        try container.encode(tags, forKey: .tags)
        try container.encode(wordCount, forKey: .wordCount)
        try container.encode(isEditing, forKey: .isEditing)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encode(attachments, forKey: .attachments)
        try container.encode(formattedContent, forKey: .formattedContent)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        content = try container.decode(String.self, forKey: .content)
        date = try container.decode(Date.self, forKey: .date)
        emotions = try container.decode([String].self, forKey: .emotions)
        pleasantness = try container.decodeIfPresent(Double.self, forKey: .pleasantness)
        tags = try container.decode([String].self, forKey: .tags)
        wordCount = try container.decode(Int.self, forKey: .wordCount)
        isEditing = try container.decodeIfPresent(Bool.self, forKey: .isEditing) ?? false
        isPinned = try container.decodeIfPresent(Bool.self, forKey: .isPinned) ?? false
        attachments = try container.decodeIfPresent([ImageAttachment].self, forKey: .attachments) ?? []
        formattedContent = try container.decodeIfPresent(Data.self, forKey: .formattedContent)
    }
}
