import SwiftUI

struct EntryRow: View {
    let entry: JournalEntry
    @State private var isVisible = false
    @Binding var selectedEntry: JournalEntry?
    
    var isSelected: Bool {
        selectedEntry?.id == entry.id
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and Date
            HStack {
                Text(entry.title)
                    .font(.headline)
                    .lineLimit(1)
                Spacer()
                Text(formatDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content Preview
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.secondary)
            
            // Emotions Flow
            FlowLayout(spacing: 6) {
                ForEach(entry.emotions, id: \.self) { emotion in
                    Text(emotion)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(red: 0.37, green: 0.36, blue: 0.90).opacity(0.1))
                        )
                }
                
                Spacer()
                
                Text("\(entry.wordCount) words")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .listTransition(isVisible: isVisible)
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, d MMM"
        return formatter.string(from: date)
    }
}
