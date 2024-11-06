import Foundation
import AppKit
import SwiftUI

struct ImageAttachment: Codable, Identifiable, Hashable {
    let id: UUID
    let data: Data
    
    var image: NSImage? {
        NSImage(data: data)
    }
}
