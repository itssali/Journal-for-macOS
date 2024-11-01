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
        HSplitView {
            VStack(spacing: 0) {
                statsHeader
                
                Divider()
                
                entriesList
            }
            .frame(width: 425)
            
            detailView
        }
        .sheet(isPresented: $showingNewEntry) {
            NewEntryView()
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
                iconColor: Color(red: 0.345, green: 0.333, blue: 0.573)
            )
            .padding(.horizontal, 16)
            
            StatView(
                icon: "calendar.badge.clock",
                title: "Days Journaled",
                value: "\(journaledDays)",
                iconColor: Color(red: 0.345, green: 0.333, blue: 0.573)
            )
            .padding(.horizontal, 16)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
    
    private var entriesList: some View {
        ZStack(alignment: .bottom) {
            List(selection: $selectedEntry) {
                ForEach(monthGroups, id: \.self) { month in
                    Section(header: Text(month).font(.headline)) {
                        ForEach(entriesForMonth(month)) { entry in
                            EntryRow(entry: entry, selectedEntry: $selectedEntry)
                                .tag(entry)
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
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: selectedEntry?.id)
            
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
            if let entry = selectedEntry {
                EntryDetailView(entry: entry, onUpdate: { updatedEntry in
                    if let index = storage.entries.firstIndex(where: { $0.id == updatedEntry.id }) {
                        selectedEntry = updatedEntry
                        storage.entries[index] = updatedEntry
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

#Preview {
    ContentView()
}
