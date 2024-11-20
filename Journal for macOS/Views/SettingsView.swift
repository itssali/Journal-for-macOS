import SwiftUI
import UniformTypeIdentifiers


struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                .resizable()
                .frame(width: 128, height: 128)
                .padding(.top, 16)
            
            VStack(spacing: 8) {
                Text("Journal for macOS")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                    .foregroundColor(.secondary)
                Text("© 2024 Ali Nasser")
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                Link(destination: URL(string: "https://github.com/itssali/Journal-for-macOS")!) {
                    HStack {
                        Image(systemName: "link")
                        Text("GitHub Repository")
                    }
                }
                
                Link(destination: URL(string: "mailto:ali@alinasser.info")!) {
                    HStack {
                        Image(systemName: "envelope")
                        Text("Suggestions & Feedback")
                    }
                }
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 380)
        .background(
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
    }
}
struct SettingsView: View {
    @StateObject private var storage = LocalStorageManager.shared
    @State private var showingImportPicker = false
    @State private var showingExportPicker = false
    @State private var selectedTab = "General"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // General Tab
            Form {
                Section("Storage Location") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Directory:")
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(storage.storageURL.path)
                                .truncationMode(.middle)
                                .lineLimit(1)
                                .textSelection(.enabled)
                            
                            Spacer()
                            
                            Button(action: {
                                NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: storage.storageURL.path)
                            }) {
                                Label("Open in Finder", systemImage: "folder")
                            }
                        }
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
                
                Section("Data Management") {
                    VStack(alignment: .center, spacing: 12) {
                        Button(action: { showingImportPicker.toggle() }) {
                            Label("Import Entries from Folder", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: { showingExportPicker.toggle() }) {
                            Label("Export All Entries", systemImage: "square.and.arrow.up")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .formStyle(.grouped)
            .background(
                VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
                    .ignoresSafeArea()
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }
            .tag("General")
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag("About")
        }
        .frame(width: 500, height: 400)
        .background(
            VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
                .ignoresSafeArea()
        )
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            if case .success(let urls) = result,
               let url = urls.first {
                guard url.startAccessingSecurityScopedResource() else {
                    print("❌ Cannot access the selected location")
                    return
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                do {
                    try storage.importEntries(from: url)
                    print("✅ Successfully imported entries from: \(url.path)")
                } catch {
                    print("❌ Error importing entries: \(error)")
                }
            }
        }
        .fileExporter(
            isPresented: $showingExportPicker,
            document: EntryDocument(entries: storage.entries),
            contentType: .journal,
            defaultFilename: "Journal Entries"
        ) { _ in }
    }
}
