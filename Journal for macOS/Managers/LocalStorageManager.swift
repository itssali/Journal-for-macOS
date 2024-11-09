import Foundation
import SwiftUI
import UniformTypeIdentifiers

class LocalStorageManager: ObservableObject {
    static let shared = LocalStorageManager()
    
    @Published var entries: [JournalEntry] = []
    private(set) var storageURL: URL
    
    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.storageURL = appSupport.appendingPathComponent("Journal for macOS/Entries")
        
        try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)
        loadEntries()
    }
    
    func loadEntries() {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: storageURL,
                includingPropertiesForKeys: nil
            ).filter { $0.pathExtension == "journal" }
            
            entries = try files.compactMap { url in
                let data = try Data(contentsOf: url)
                return try JSONDecoder().decode(JournalEntry.self, from: data)
            }.sorted { $0.date > $1.date }
        } catch {
            print("❌ Error loading entries: \(error)")
        }
    }
    
    func saveEntry(_ entry: JournalEntry) {
        let fileName = entry.title.replacingOccurrences(of: " ", with: "_") + ".journal"
        let fileURL = storageURL.appendingPathComponent(fileName)
        
        do {
            let data = try JSONEncoder().encode(entry)
            try data.write(to: fileURL, options: .atomic)
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
    
    func exportEntries(to url: URL) throws {
        let data = try JSONEncoder().encode(entries)
        try data.write(to: url)
    }
    
    func importEntries(from folderURL: URL) throws {
        let fileManager = FileManager.default
        let files = try fileManager.contentsOfDirectory(
            at: folderURL,
            includingPropertiesForKeys: nil
        ).filter { $0.pathExtension == "journal" }
        
        print("📁 Found \(files.count) journal files in: \(folderURL.path)")
        
        for file in files {
            do {
                let data = try Data(contentsOf: file)
                if let entry = try? JSONDecoder().decode(JournalEntry.self, from: data) {
                    let destination = storageURL.appendingPathComponent(file.lastPathComponent)
                    if !fileManager.fileExists(atPath: destination.path) {
                        try fileManager.copyItem(at: file, to: destination)
                        entries.append(entry)
                        print("✅ Imported: \(file.lastPathComponent)")
                    } else {
                        print("⚠️ Skipped duplicate: \(file.lastPathComponent)")
                    }
                }
            } catch {
                print("❌ Error importing \(file.lastPathComponent): \(error)")
            }
        }
        
        entries.sort { $0.date > $1.date }
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
    
    func updateEntry(_ oldEntry: JournalEntry, with newEntry: JournalEntry) {
        // First delete the old file
        let oldFileName = oldEntry.title.replacingOccurrences(of: " ", with: "_") + ".journal"
        let oldFileURL = storageURL.appendingPathComponent(oldFileName)
        
        do {
            // Remove old file
            try FileManager.default.removeItem(at: oldFileURL)
            
            // Save new entry
            saveEntry(newEntry)
            
            // Update in-memory array
            if let index = entries.firstIndex(where: { $0.id == oldEntry.id }) {
                entries[index] = newEntry
            }
        } catch {
            print("❌ Error updating entry: \(error)")
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
