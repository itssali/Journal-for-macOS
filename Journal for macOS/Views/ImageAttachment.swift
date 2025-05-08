import Foundation
import AppKit
import SwiftUI

struct ImageAttachment: Codable, Identifiable, Hashable {
    let id: UUID
    let data: Data
    
    var image: NSImage? {
        NSImage(data: data)
    }
    
    // Required Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ImageAttachment, rhs: ImageAttachment) -> Bool {
        lhs.id == rhs.id
    }
    
    // Explicit Codable implementation for maximum compatibility
    enum CodingKeys: String, CodingKey {
        case id, data
    }
    
    init(id: UUID, data: Data) {
        self.id = id
        self.data = data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        data = try container.decode(Data.self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(data, forKey: .data)
    }
}
