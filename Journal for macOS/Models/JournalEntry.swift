import Foundation
import AppKit

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
        pleasantness ?? 0.5
    }
    
    // Helper to get attributed string content
    var attributedContent: NSAttributedString? {
        guard let data = formattedContent else {
            // If no formatted content exists, create one from plain text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 16),
                .foregroundColor: NSColor.white
            ]
            return NSAttributedString(string: content, attributes: attributes)
        }
        
        do {
            // Use RTFD format which preserves all formatting attributes including RichTextKit's
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.rtfd,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            // Create attributed string from stored data
            let attrString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            
            // Return the attributed string directly - no need for extra copying
            return attrString
        } catch {
            // Fallback to plain text if loading fails
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 16),
                .foregroundColor: NSColor.white
            ]
            return NSAttributedString(string: content, attributes: attributes)
        }
    }
    
    // Helper to set attributed string content
    mutating func setAttributedContent(_ attributedString: NSAttributedString) {
        do {
            // Update plain text content
            content = attributedString.string
            
            // Use RTFD format which preserves all formatting attributes including RichTextKit's
            let documentAttributes: [NSAttributedString.DocumentAttributeKey: Any] = [
                .documentType: NSAttributedString.DocumentType.rtfd,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
            
            // Convert to data using RTFD format
            let rtfdData = try attributedString.data(
                from: NSRange(location: 0, length: attributedString.length),
                documentAttributes: documentAttributes
            )
            
            formattedContent = rtfdData
            wordCount = content.split(separator: " ").count
            
            // Process attachments
            let range = NSRange(location: 0, length: attributedString.length)
            var newAttachments: [ImageAttachment] = []
            
            attributedString.enumerateAttribute(.attachment, in: range, options: []) { value, _, _ in
                guard let attachment = value as? NSTextAttachment else { return }
                
                var image: NSImage? = attachment.image
                
                if image == nil, let fileWrapper = attachment.fileWrapper, let data = fileWrapper.regularFileContents {
                    image = NSImage(data: data)
                }
                
                if let image, let imageData = image.tiffRepresentation {
                    let imageAttachment = ImageAttachment(id: UUID(), data: imageData)
                    newAttachments.append(imageAttachment)
                }
            }
            
            attachments = newAttachments
        } catch {
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
    
    mutating func syncAttachmentsIfNeeded() {
        guard let attributed = self.attributedContent else { return }
        
        let range = NSRange(location: 0, length: attributed.length)
        var newAttachments: [ImageAttachment] = []
        
        attributed.enumerateAttribute(.attachment, in: range, options: []) { value, _, _ in
            guard let attachment = value as? NSTextAttachment else { return }
            
            var image: NSImage? = attachment.image
            if image == nil, let fileWrapper = attachment.fileWrapper, let data = fileWrapper.regularFileContents {
                image = NSImage(data: data)
            }
            
            if let image, let imageData = image.tiffRepresentation {
                let imageAttachment = ImageAttachment(id: UUID(), data: imageData)
                newAttachments.append(imageAttachment)
            }
        }
        
        if !newAttachments.isEmpty || !attachments.isEmpty {
            attachments = newAttachments
        }
    }
}
