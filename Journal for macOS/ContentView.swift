//
//  ContentView.swift
//  Journal for macOS
//
//  Created by Ali Nasser on 01/11/2024.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @StateObject private var storage = LocalStorageManager.shared
    @StateObject private var onboardingManager = OnboardingManager()
    @State private var searchText = ""
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntry?
    @State private var isDetailViewVisible = false
    
    // Simple computed properties
    var totalWords: Int {
        storage.entries.reduce(0) { $0 + $1.wordCount }
    }
    
    var entriesThisYear: Int {
        // Get the current calendar year (from system clock, not simulation)
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        
        // Filter entries by the current year only
        let filteredEntries = storage.entries.filter { entry in
            let entryYear = calendar.component(.year, from: entry.date)
            return entryYear == currentYear
        }
        
        return filteredEntries.count
    }
    
    var journaledDays: Int {
        let dates = storage.entries.map { Calendar.current.startOfDay(for: $0.date) }
        return Set(dates).count
    }
    
    // Break down the entries grouping
    private func monthString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    private func entriesForMonth(_ month: String) -> [JournalEntry] {
        storage.entries.filter { monthString(for: $0.date) == month }
    }
    
    private var monthGroups: [String] {
        let pinnedEntries = storage.entries.filter { $0.isPinned }
        let unpinnedEntries = storage.entries.filter { !$0.isPinned }
        
        var months = Set<String>()
        
        // Add "Pinned" section if there are any pinned entries
        if !pinnedEntries.isEmpty {
            months.insert("Pinned")
        }
        
        // Add all other months
        unpinnedEntries.forEach { entry in
            months.insert(monthString(for: entry.date))
        }
        
        return Array(months).sorted { month1, month2 in
            if month1 == "Pinned" { return true }
            if month2 == "Pinned" { return false }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            let date1 = formatter.date(from: month1) ?? Date()
            let date2 = formatter.date(from: month2) ?? Date()
            return date1 > date2
        }
    }
    
    var body: some View {
        ZStack {
            HSplitView {
                VStack(spacing: 0) {
                    // Header section with greeting and stats
                    VStack(spacing: 0) {
                        HStack {
                            UserGreetingView()
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        
                        statsHeader
                    }
                    .background(
                        VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                            .ignoresSafeArea()
                    )
                    
                    Divider()
                        .background(Color.white.opacity(0.2))
                    entriesList
                }
                .frame(minWidth: 375, maxWidth: 500)
                
                detailView
                    .frame(minWidth: 400)
                    .background(
                        VisualEffectView(material: .contentBackground, blendingMode: .behindWindow)
                            .ignoresSafeArea()
                    )
            }
            .frame(minHeight: 650)
            
            CustomSheet(
                isPresented: showingNewEntry,
                content: NewEntryView(onDismiss: { showingNewEntry = false }),
                onDismiss: { showingNewEntry = false }
            )
            
            CustomSheet(
                isPresented: selectedEntry?.isEditing ?? false,
                content: EditEntryView(
                    entry: Binding(
                        get: { selectedEntry ?? JournalEntry.empty },
                        set: { updatedEntry in
                            if let index = storage.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                                storage.updateEntry(storage.entries[index], with: updatedEntry)
                                selectedEntry = updatedEntry
                            }
                        }
                    ),
                    selectedEntry: $selectedEntry,
                    onDismiss: {
                        selectedEntry?.isEditing = false
                    }
                ),
                onDismiss: {
                    selectedEntry?.isEditing = false
                }
            )
        }
        .onChange(of: onboardingManager.showOnboarding) { _, showOnboarding in
            if showOnboarding {
                // Replace sheet with fullscreen overlay
                DispatchQueue.main.async {
                    if let window = NSApp.windows.first,
                       let contentView = window.contentView {
                        // Create onboarding view
                        let onboardingView = OnboardingView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .edgesIgnoringSafeArea(.all)
                        
                        // Create hosting view
                        let hostingView = NSHostingView(rootView: onboardingView)
                        hostingView.frame = contentView.bounds
                        hostingView.autoresizingMask = [.width, .height]
                        
                        // Remove any existing view first
                        onboardingManager.onboardingHostingView?.removeFromSuperview()
                        
                        // Add to window and save reference
                        contentView.addSubview(hostingView)
                        onboardingManager.onboardingHostingView = hostingView
                    }
                }
            } else {
                // Remove the view when done
                DispatchQueue.main.async {
                    onboardingManager.onboardingHostingView?.removeFromSuperview()
                    onboardingManager.onboardingHostingView = nil
                }
            }
        }
        .onChange(of: onboardingManager.showVersionOnboarding) { _, showVersionOnboarding in
            if showVersionOnboarding {
                // Replace sheet with fullscreen overlay
                DispatchQueue.main.async {
                    if let window = NSApp.windows.first,
                       let contentView = window.contentView {
                        // Create version onboarding view
                        let versionOnboardingView = OnboardingView(
                            isVersionSpecific: true,
                            versionNumber: onboardingManager.getCurrentVersion(),
                            versionFeatures: onboardingManager.getVersionFeatures()
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .edgesIgnoringSafeArea(.all)
                        
                        // Create hosting view
                        let hostingView = NSHostingView(rootView: versionOnboardingView)
                        hostingView.frame = contentView.bounds
                        hostingView.autoresizingMask = [.width, .height]
                        
                        // Remove any existing view first
                        onboardingManager.versionOnboardingHostingView?.removeFromSuperview()
                        
                        // Add to window and save reference
                        contentView.addSubview(hostingView)
                        onboardingManager.versionOnboardingHostingView = hostingView
                    }
                }
            } else {
                // Remove the view when done
                DispatchQueue.main.async {
                    onboardingManager.versionOnboardingHostingView?.removeFromSuperview()
                    onboardingManager.versionOnboardingHostingView = nil
                }
            }
        }
        .onAppear {
            // Setup notification observer for showing onboarding from Settings
            NotificationCenter.default.addObserver(
                forName: Notification.Name("ShowOnboarding"),
                object: nil,
                queue: .main
            ) { _ in
                onboardingManager.showStandardOnboarding()
            }
        }
    }
    
    // Break down body into smaller views
    private var statsHeader: some View {
        HStack(spacing: 0) {
            StatView(
                icon: "journal",
                title: "Entries This Year",
                value: "\(entriesThisYear)",
                iconColor: Color(red: 0.37, green: 0.36, blue: 0.90)
            )
            .frame(height: 65)
            .padding(.horizontal, 16)
            
            Divider()
                .frame(height: 65)
            
            StatView(
                icon: "quote",
                title: "Total Words",
                value: "\(totalWords)",
                iconColor: Color(hex: "C06E6E")
            )
            .frame(height: 65)
            .padding(.horizontal, 16)
            
            Divider()
                .frame(height: 65)
            
            StatView(
                icon: "calendar",
                title: "Days Journaled",
                value: "\(journaledDays)",
                iconColor: Color(red: 0.37, green: 0.36, blue: 0.90)
            )
            .frame(height: 65)
            .padding(.horizontal, 16)
        }
        .padding(.horizontal)
        .padding(.vertical, 11)
    }
    
    private var entriesList: some View {
        ZStack(alignment: .bottom) {
            List {
                ForEach(monthGroups, id: \.self) { month in
                    Section(header: Text(month).font(.headline)) {
                        let entries = month == "Pinned"
                            ? storage.entries.filter { $0.isPinned }.sorted { $0.date > $1.date }
                            : storage.entries
                                .filter { !$0.isPinned && monthString(for: $0.date) == month }
                                .sorted { $0.date > $1.date }
                        
                        ForEach(entries.indices, id: \.self) { index in
                            let entry = entries[index]
                            EntryRow(entry: entry, selectedEntry: $selectedEntry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEntry = entry
                                }
                                .frame(minHeight: 44)
                                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .listRowBackground(Color.clear)
                            
                            if entry.isPinned && index < entries.count - 1 && !entries[index + 1].isPinned {
                                Divider()
                                    .padding(.horizontal)
                                    .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                                    .listRowBackground(Color.clear)
                            }
                        }
                    }
                }
                
                // Add spacer view at the bottom with increased height
                Color.clear.frame(height: 80) // Increased height for better spacing
                    .listRowBackground(Color.clear)
            }
            .listStyle(.sidebar)
            .background(
                VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                    .ignoresSafeArea()
            )
            
            newEntryButton
                .padding(.bottom, 16) // Add padding to the button itself
        }
    }
    private var newEntryButton: some View {
        ZStack {
            Button(action: { showingNewEntry.toggle() }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(red: 0.37, green: 0.36, blue: 0.90))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom)
    }
    
    
    private var detailView: some View {
        Group {
            if selectedEntry != nil {
                EntryDetailView(entry: $selectedEntry) { updatedEntry in
                    if let index = storage.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        storage.updateEntry(storage.entries[index], with: updatedEntry)
                        self.selectedEntry = updatedEntry
                    }
                }
                .transaction { transaction in
                    transaction.animation = nil
                }
            } else {
                VStack {
                    Text("Select an entry to view")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                        .ignoresSafeArea()
                )
                .transaction { transaction in
                    transaction.animation = nil
                }
            }
        }
    }
    
    // Replace direct array modifications with manager method calls
    private func moveEntry(from source: IndexSet, to destination: Int) {
        storage.moveEntries(from: source, to: destination)
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            storage.deleteEntry(storage.entries[index])
        }
    }
    
    // If you have any other direct modifications to storage.entries, 
    // replace them with appropriate manager method calls
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    static var customAccent: Color {
        if NSApplication.shared.effectiveAppearance.name == .accessibilityHighContrastAqua {
            // Use app's default accent color for multicolor setting
            return Color(red: 0.37, green: 0.36, blue: 0.90)
        }
        return Color.accentColor
    }
}

#Preview {
    ContentView()
        .frame(width: 920, height: 700)
}


