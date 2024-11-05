import SwiftUI

struct EmotionCategory: Identifiable {
    let id = UUID()
    let name: String
    let emotions: [String]
}

let emotionCategories = [
    EmotionCategory(name: "Joy", emotions: [
        "Happy", "Excited", "Peaceful", "Content", "Grateful", "Optimistic", "Proud", "Cheerful", "Inspired"
    ]),
    EmotionCategory(name: "Love", emotions: [
        "Loved", "Affectionate", "Romantic", "Caring", "Compassionate", "Tender", "Warm"
    ]),
    EmotionCategory(name: "Sadness", emotions: [
        "Sad", "Lonely", "Disappointed", "Hurt", "Melancholic", "Down", "Gloomy", "Heartbroken"
    ]),
    EmotionCategory(name: "Anger", emotions: [
        "Angry", "Frustrated", "Irritated", "Annoyed", "Furious", "Agitated", "Bitter"
    ]),
    EmotionCategory(name: "Fear", emotions: [
        "Anxious", "Worried", "Scared", "Nervous", "Overwhelmed", "Stressed", "Insecure", "Uneasy"
    ]),
    EmotionCategory(name: "Neutral", emotions: [
        "Calm", "Focused", "Thoughtful", "Curious", "Relaxed", "Balanced", "Contemplative"
    ])
]
