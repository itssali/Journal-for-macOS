//
//  ContentView.swift
//  Journal for macOS
//
//  Created by Ali Nasser on 01/11/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storage = LocalStorageManager.shared
    @State private var searchText = ""
    @State private var showingNewEntry = false
    @State private var selectedEntry: JournalEntry?
    
    // Simple computed properties
    var totalWords: Int {
        storage.entries.reduce(0) { $0 + $1.wordCount }
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
                    statsHeader
                    Divider()
                    entriesList
                }
                .frame(minWidth: 375, maxWidth: 500)
                
                detailView
                    .frame(minWidth: 400)
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
                            storage.entries[index] = updatedEntry
                            selectedEntry = updatedEntry
                            storage.saveEntries()
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
}
    
    // Break down body into smaller views
    private var statsHeader: some View {
        HStack(spacing: 0) {
            StatView(
                icon: "calendar",
                title: "Entries This Year",
                value: "\(storage.entries.count)",
                iconColor: Color(red: 0.37, green: 0.36, blue: 0.90)
            )
            .padding(.horizontal, 16)
            
            StatView(
                icon: "quote.bubble",
                title: "Total Words",
                value: "\(totalWords)",
                iconColor: Color(hex: "C06E6E")
            )
            .padding(.horizontal, 16)
            
            StatView(
                icon: "calendar.badge.clock",
                title: "Days Journaled",
                value: "\(journaledDays)",
                iconColor: Color(red: 0.37, green: 0.36, blue: 0.90)
            )
            .padding(.horizontal, 16)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
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
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedEntry = entry
                                    }
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
            }
            .listStyle(.sidebar)
            
            newEntryButton
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
                EntryDetailView(entry: $selectedEntry, onUpdate: { updatedEntry in
                    if let index = storage.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        storage.entries[index] = updatedEntry
                        selectedEntry = updatedEntry
                        storage.saveEntries()
                    }
                })
            } else {
                Text("Select an entry to view details")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
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
}
