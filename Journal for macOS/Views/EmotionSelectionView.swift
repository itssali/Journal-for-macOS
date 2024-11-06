import SwiftUI

struct EmotionSelectionView: View {
    @Binding var selectedEmotions: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How are you feeling?")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(emotionCategories) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            Text(category.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                            
                            LazyVGrid(
                                columns: [
                                    GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 8)
                                ],
                                spacing: 8
                            ) {
                                ForEach(category.emotions, id: \.self) { emotion in
                                    EmotionButton(
                                        emotion: emotion,
                                        isSelected: selectedEmotions.contains(emotion)
                                    ) {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            if selectedEmotions.contains(emotion) {
                                                selectedEmotions.remove(emotion)
                                            } else {
                                                selectedEmotions.insert(emotion)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .frame(height: 200)
            .background(Color(nsColor: .windowBackgroundColor).opacity(0.5))
            .cornerRadius(8)
        }
    }
}
