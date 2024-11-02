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
        let months = storage.entries.map { monthString(for: $0.date) }
        return Array(Set(months)).sorted().reversed()
    }
    
    var body: some View {
        ZStack {
            HSplitView {
                VStack(spacing: 0) {
                    statsHeader
                    Divider()
                    entriesList
                }
                .frame(width: 425)
                detailView
            }
            
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
                        ForEach(storage.entries.filter { monthString(for: $0.date) == month }) { entry in
                            EntryRow(entry: entry, selectedEntry: $selectedEntry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedEntry = entry
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12))
                                .listRowBackground(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedEntry?.id == entry.id ? 
                                              Color.accentColor.opacity(0.15) : 
                                                Color.clear)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                )
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            
            newEntryButton
        }
    }
    
    private var newEntryButton: some View {
        Button(action: { showingNewEntry.toggle() }) {
            Image(systemName: "plus")
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color(red: 0.37, green: 0.36, blue: 0.90))
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
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
}

#Preview {
    ContentView()
}
