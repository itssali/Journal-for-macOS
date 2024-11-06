import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject private var storage = LocalStorageManager.shared
    @State private var showingFolderPicker = false
    @State private var showingExportDialog = false
    @State private var showingImportPicker = false
    @State private var selectedTab = "Storage"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Storage Tab
            Form {
                Section("Storage Location") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Current Location:")
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(storage.storageURL.path)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .textSelection(.enabled)
                            
                            Spacer()
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: storage.storageURL.path)
                            }) {
                                Label("Open in Finder", systemImage: "folder")
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("Storage", systemImage: "folder")
            }
            .tag("Storage")
            
            // About Tab
            Form {
                Section("About") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journal for macOS")
                            .font(.title)
                        Text("Version \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0")")
                        Text("© 2024 Ali Nasser")
                        Link("GitHub Repository", destination: URL(string: "https://github.com/itssali/Journal-for-macOS")!)
                    }
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
            .tag("About")
        }
        .frame(width: 500, height: 400)
        .animation(.easeInOut, value: selectedTab)
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [UTType(filenameExtension: "folder")!],
            allowsMultipleSelection: false
        ) { result in
            handleFolderSelection(result)
        }
        .fileImporter(isPresented: $showingImportPicker, allowedContentTypes: [.journal], allowsMultipleSelection: false) { result in
            handleImportSelection(result)
        }
        .fileExporter(isPresented: $showingExportDialog, document: EntryDocument(entries: storage.entries), contentType: .journal) { result in
            handleExportResult(result)
        }
    }
    
    private func handleFolderSelection(_ result: Result<[URL], Error>) {
        print("📁 Folder selection triggered")
        
        guard case .success(let urls) = result,
              let selectedURL = urls.first else {
            print("❌ No folder selected or error occurred")
            return
        }
        
        print("📂 Selected folder: \(selectedURL.path)")
        
        guard selectedURL.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access the selected directory")
            return
        }
        defer { selectedURL.stopAccessingSecurityScopedResource() }
        
        do {
            try storage.moveEntriesToNewLocation(selectedURL)
            print("✅ Successfully moved entries to new location")
        } catch {
            print("❌ Error changing storage location: \(error)")
        }
    }
    
    private func handleImportSelection(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result,
              let selectedURL = urls.first else { return }
        
        guard selectedURL.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access the selected directory")
            return
        }
        defer { selectedURL.stopAccessingSecurityScopedResource() }
        
        do {
            try storage.importEntries(from: selectedURL)
        } catch {
            print("❌ Error importing entries: \(error)")
        }
    }
    
    private func handleExportResult(_ result: Result<URL, Error>) {
        guard case .success(let selectedURL) = result else { return }
        
        guard selectedURL.startAccessingSecurityScopedResource() else {
            print("❌ Failed to access the selected directory")
            return
        }
        defer { selectedURL.stopAccessingSecurityScopedResource() }
        
        do {
            try storage.exportEntries(to: selectedURL)
        } catch {
            print("❌ Error exporting entries: \(error)")
        }
    }
}
