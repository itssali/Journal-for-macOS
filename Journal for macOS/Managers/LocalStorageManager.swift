import Foundation
import SwiftUI
import UniformTypeIdentifiers

class LocalStorageManager: ObservableObject {
    static let shared = LocalStorageManager()
    
    @Published var entries: [JournalEntry] = []
    @Published private(set) var storageURL: URL
    
    private let defaults = UserDefaults.standard
    private let storagePathKey = "journalStoragePath"
    
    init() {
        // Load custom storage path or use default
        if let storedPath = defaults.string(forKey: storagePathKey),
           let storedURL = URL(string: storedPath) {
            self.storageURL = storedURL
        } else {
            // Default to Documents folder
            let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            self.storageURL = documents.appendingPathComponent("Journal Entries", isDirectory: true)
        }
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        
        loadEntries()
    }
    
    private func loadEntries() {
        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: nil)
            let journalFiles = files.filter { $0.pathExtension == "journal" }
            
            entries = try journalFiles.compactMap { url in
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(JournalEntry.self, from: data)
            }
        } catch {
            print("❌ Error loading entries: \(error)")
        }
    }
    
    func saveEntry(_ entry: JournalEntry) {
        let fileName = entry.title.replacingOccurrences(of: " ", with: "_") + ".journal"
        let fileURL = storageURL.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL)
            loadEntries() // Reload entries after saving
        } catch {
            print("❌ Error saving entry: \(error)")
        }
    }
    
    func saveEntries() {
        for entry in entries {
            saveEntry(entry)
        }
    }
    
    func updateStorageLocation(_ newLocation: URL) {
        storageURL = newLocation
        defaults.set(newLocation.absoluteString, forKey: storagePathKey)
        saveEntries()
    }
    
    func moveEntriesToNewLocation(_ newLocation: URL) throws {
        let fileManager = FileManager.default
        
        // Create new directory if it doesn't exist
        try fileManager.createDirectory(at: newLocation, withIntermediateDirectories: true, attributes: nil)
        
        // Get all journal files from current location
        let files = try fileManager.contentsOfDirectory(at: storageURL, includingPropertiesForKeys: nil)
        let journalFiles = files.filter { $0.pathExtension == "journal" }
        
        // Move each file to new location
        for file in journalFiles {
            let destination = newLocation.appendingPathComponent(file.lastPathComponent)
            // Remove existing file at destination if it exists
            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }
            try fileManager.moveItem(at: file, to: destination)
        }
        
        // Update storage location in UserDefaults and memory
        storageURL = newLocation
        defaults.set(newLocation.path, forKey: storagePathKey)
        defaults.synchronize()
        
        // Reload entries from new location
        loadEntries()
    }
    
    func importEntry(_ entry: JournalEntry) {
        entries.append(entry)
        saveEntries()
    }
    
    func importEntries(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let entry = try JSONDecoder().decode(JournalEntry.self, from: data)
        importEntry(entry)
    }
    
    func exportEntries(to url: URL) throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: url)
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        let fileName = entry.title.replacingOccurrences(of: " ", with: "_") + ".journal"
        let fileURL = storageURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            if let index = entries.firstIndex(where: { $0.id == entry.id }) {
                entries.remove(at: index)
            }
        } catch {
            print("❌ Error deleting entry file: \(error)")
        }
    }
}

extension UTType {
    static var journal: UTType {
        UTType(exportedAs: "NasserInc.Journal-for-macOS.journal")
    }
}

struct EntryDocument: FileDocument {
    let entries: [JournalEntry]
    
    static var readableContentTypes: [UTType] { [.journal] }
    
    init(entries: [JournalEntry]) {
        self.entries = entries
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let entries = try? JSONDecoder().decode([JournalEntry].self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.entries = entries
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(entries)
        return .init(regularFileWithContents: data)
    }
}
