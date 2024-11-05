import SwiftUI

struct EmotionSelectionView: View {
    @Binding var selectedEmotions: Set<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("How are you feeling?")
                .font(.headline)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(emotionCategories) { category in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(category.name)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            FlowLayout(spacing: 8) {
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
                        }
                    }
                }
            }
        }
        .padding()
    }
}
