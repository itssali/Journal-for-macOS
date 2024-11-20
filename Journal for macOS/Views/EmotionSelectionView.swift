import SwiftUI
import Orb

struct PleasantnessLevel: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let emotions: [String]
    let suggestedEmotions: [String]
}

let pleasantnessLevels = [
    PleasantnessLevel(
        name: "Very Unpleasant",
        color: Color(red: 0.6, green: 0.2, blue: 0.8),
        emotions: [
            "Angry", "Frustrated", "Anxious", "Depressed", "Overwhelmed",
            "Stressed", "Fearful", "Furious", "Enraged", "Hostile",
            "Bitter", "Resentful", "Disgusted", "Hateful", "Aggressive",
            "Irritated", "Outraged", "Violated", "Vengeful", "Desperate",
            "Miserable", "Terrified", "Helpless", "Panic", "Dread"
        ],
        suggestedEmotions: ["Angry", "Frustrated", "Anxious", "Depressed", "Overwhelmed"]
    ),
    PleasantnessLevel(
        name: "Unpleasant",
        color: Color(red: 0.5, green: 0.3, blue: 0.7),
        emotions: [
            "Sad", "Irritated", "Worried", "Disappointed", "Hurt",
            "Upset", "Down", "Lonely", "Insecure", "Guilty",
            "Ashamed", "Regretful", "Ignored", "Abandoned", "Rejected",
            "Inadequate", "Inferior", "Isolated", "Powerless", "Lost",
            "Grief", "Heartbroken", "Betrayed", "Defeated", "Discouraged"
        ],
        suggestedEmotions: ["Sad", "Irritated", "Worried", "Disappointed", "Hurt"]
    ),
    PleasantnessLevel(
        name: "Slightly Unpleasant",
        color: Color(red: 0.4, green: 0.4, blue: 0.6),
        emotions: [
            "Uneasy", "Tense", "Confused", "Tired", "Bored",
            "Distracted", "Uncertain", "Restless", "Uncomfortable", "Doubtful",
            "Hesitant", "Apathetic", "Indifferent", "Disconnected", "Withdrawn",
            "Unmotivated", "Drained", "Pressured", "Concerned", "Unsure",
            "Vulnerable", "Cautious", "Nervous", "Apprehensive", "Wary"
        ],
        suggestedEmotions: ["Uneasy", "Tense", "Confused", "Tired", "Bored"]
    ),
    PleasantnessLevel(
        name: "Neutral",
        color: Color(red: 0.35, green: 0.35, blue: 0.35),
        emotions: [
            "Calm", "Focused", "Neutral", "Reserved", "Steady",
            "Balanced", "Stable", "Composed", "Centered", "Present",
            "Aware", "Observant", "Mindful", "Quiet", "Still",
            "Contemplative", "Reflective", "Meditative", "Grounded", "Patient",
            "Attentive", "Collected", "Poised", "Serene", "Tranquil"
        ],
        suggestedEmotions: ["Calm", "Focused", "Neutral", "Reserved", "Steady"]
    ),
    PleasantnessLevel(
        name: "Slightly Pleasant",
        color: Color(red: 0.3, green: 0.5, blue: 0.7),
        emotions: [
            "Content", "Relaxed", "Peaceful", "Comfortable", "Hopeful",
            "Satisfied", "Pleasant", "Gentle", "Friendly", "Open",
            "Receptive", "Accepting", "Easygoing", "Light", "Bright",
            "Refreshed", "Renewed", "Restored", "Relieved", "Safe",
            "Secure", "Supported", "Welcomed", "Appreciated", "Respected"
        ],
        suggestedEmotions: ["Content", "Relaxed", "Peaceful", "Comfortable", "Hopeful"]
    ),
    PleasantnessLevel(
        name: "Pleasant",
        color: Color(red: 0.2, green: 0.6, blue: 0.8),
        emotions: [
            "Happy", "Excited", "Optimistic", "Grateful", "Confident",
            "Cheerful", "Motivated", "Energetic", "Playful", "Amused",
            "Delighted", "Joyous", "Lively", "Enthusiastic", "Radiant",
            "Vibrant", "Upbeat", "Positive", "Blessed", "Fortunate",
            "Accomplished", "Proud", "Successful", "Capable", "Strong"
        ],
        suggestedEmotions: ["Happy", "Excited", "Optimistic", "Grateful", "Confident"]
    ),
    PleasantnessLevel(
        name: "Very Pleasant",
        color: Color(red: 0.1, green: 0.7, blue: 0.9),
        emotions: [
            "Joyful", "Elated", "Thrilled", "Enthusiastic", "Inspired",
            "Amazed", "Ecstatic", "Overjoyed", "Blissful", "Exhilarated",
            "Passionate", "Loving", "Fulfilled", "Empowered", "Magnificent",
            "Wonderful", "Fantastic", "Spectacular", "Celebrated", "Triumphant",
            "Euphoric", "Enchanted", "Dazzled", "Radiant", "Glowing"
        ],
        suggestedEmotions: ["Joyful", "Elated", "Thrilled", "Enthusiastic", "Inspired"]
    )
]

struct EmotionButton: View {
    let emotion: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(emotion)
                .font(.system(.body, design: .rounded))
                .lineLimit(1)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? 
                            Color(red: 0.37, green: 0.36, blue: 0.90) : 
                            Color(nsColor: .windowBackgroundColor)
                        )
                )
                .foregroundColor(isSelected ? .white : .primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            isSelected ? 
                                Color.clear : 
                                Color.secondary.opacity(0.3),
                            lineWidth: 1
                        )
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
                .fixedSize()
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct EmotionOrb: View {
    let progress: Double
    
    //Very Unpleasant - Shadow
    let shadowOrb = OrbConfiguration(
        backgroundColors: [.black, .gray],
        glowColor: .gray,
        coreGlowIntensity: 0.7,
        showParticles: false,
        showShadow: true,
        speed: 20
    )

    //Unpleasant - Cosmic
    let cosmicOrb = OrbConfiguration(
        backgroundColors: [.purple, .pink, .blue],
        glowColor: .white,
        coreGlowIntensity: 1.5,
        showShadow: true,
        speed: 20
    )

    //Slightly Unpleasant - Sunset
    let sunsetOrb = OrbConfiguration(
        backgroundColors: [.orange, .red, .pink],
        glowColor: .orange,
        coreGlowIntensity: 0.8,
        showShadow: true,
        speed: 20
    )

    //Neutral - Minimal
    let minimalOrb = OrbConfiguration(
        backgroundColors: [.gray, .white],
        glowColor: .white,
        showWavyBlobs: false,
        showParticles: false,
        speed: 20
    )

    //Slightly Pleasant - Nature
    let natureOrb = OrbConfiguration(
        backgroundColors: [.green, .mint, .teal],
        glowColor: .green,
        showShadow: true,
        speed: 20
    )

    //Pleasant - Ocean
    let oceanOrb = OrbConfiguration(
        backgroundColors: [.blue, .cyan, .teal],
        glowColor: .cyan,
        showShadow: true,
        speed: 20
    )

    //Very Pleasant - Fire
    let fireOrb = OrbConfiguration(
        backgroundColors: [.red, .orange, .yellow],
        glowColor: .orange,
        coreGlowIntensity: 1.3,
        showShadow: true,                        
        speed: 20
    )
    
    var configuration: OrbConfiguration {
        let normalizedValue = progress
        
        switch normalizedValue {
        case ...(-0.715):
            return shadowOrb
        case -0.715...(-0.429):
            return cosmicOrb
        case -0.429...(-0.143):
            return sunsetOrb
        case -0.143...0.143:
            return minimalOrb
        case 0.143...0.429:
            return natureOrb
        case 0.429...0.715:
            return oceanOrb
        default:
            return fireOrb
        }
    }
    
    var body: some View {
        OrbView(configuration: configuration)
            .frame(width: 100, height: 100)
            .animation(.easeInOut(duration: 0.5), value: progress)
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let configuration: OrbConfiguration
    
    private let height: CGFloat = 24
    private let padding: CGFloat = 12
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track background
                RoundedRectangle(cornerRadius: height/2)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: height/2)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: height)
                
                // Colored progress
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: height/2)
                        .fill(
                            LinearGradient(
                                colors: configuration.backgroundColors,
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: max(0, (geometry.size.width - padding * 2) * CGFloat(value) + height))
                    Spacer(minLength: 0)
                }
                .frame(height: height)
                
                // Thumb
                Circle()
                    .fill(
                        configuration.backgroundColors[0]
                            .shadow(.inner(radius: 3))
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 2)
                    )
                    .frame(width: height, height: height)
                    .position(
                        x: padding + (geometry.size.width - padding * 2) * CGFloat(value),
                        y: geometry.size.height / 2
                    )
                    .shadow(color: configuration.glowColor.opacity(0.3), radius: 5)
                    .zIndex(1)
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let adjustedWidth = geometry.size.width - padding * 2
                        let adjustedX = gesture.location.x - padding
                        let newValue = adjustedX / adjustedWidth
                        value = min(max(0, Double(newValue)), 1)
                    }
            )
        }
        .frame(maxWidth: 300)
        .frame(height: height)
        .animation(.easeOut(duration: 0.2), value: value)
    }
}

struct EmotionSelectionView: View {
    @Binding var selectedEmotions: Set<String>
    @Binding var isShowingEmotionSelection: Bool
    @Binding var pleasantnessValue: Double
    @State private var showingEmotions: Bool
    let cancelButtonIcon: String
    
    init(selectedEmotions: Binding<Set<String>>, pleasantnessValue: Binding<Double>, isShowingEmotionSelection: Binding<Bool>, cancelButtonIcon: String) {
        self._selectedEmotions = selectedEmotions
        self._pleasantnessValue = pleasantnessValue
        self._isShowingEmotionSelection = isShowingEmotionSelection
        self.cancelButtonIcon = cancelButtonIcon
        
        // Start in emotions view if there are already emotions selected
        self._showingEmotions = State(initialValue: !selectedEmotions.wrappedValue.isEmpty)
    }
    
    static func getPleasantnessFromEmotions(_ emotions: Set<String>) -> Double {
        guard !emotions.isEmpty else { return 0.5 }
        
        // Find which pleasantness level contains these emotions
        for (index, level) in pleasantnessLevels.enumerated() {
            if !emotions.isDisjoint(with: Set(level.emotions)) {
                // Convert index to normalized value (-1 to 1)
                let normalizedValue = -1.0 + (2.0 * Double(index) / Double(pleasantnessLevels.count - 1))
                // Convert to slider value (0 to 1)
                return (normalizedValue + 1) / 2
            }
        }
        
        return 0.5 // Default to neutral if no match found
    }
    
    private var normalizedPleasantnessValue: Double {
        (pleasantnessValue - 0.5) * 2
    }
    
    private var currentPleasantnessLevel: PleasantnessLevel {
        let value = normalizedPleasantnessValue
        
        switch value {
        case ...(-0.715):
            return pleasantnessLevels[0] // Very Unpleasant
        case -0.715...(-0.429):
            return pleasantnessLevels[1] // Unpleasant
        case -0.429...(-0.143):
            return pleasantnessLevels[2] // Slightly Unpleasant
        case -0.143...0.143:
            return pleasantnessLevels[3] // Neutral
        case 0.143...0.429:
            return pleasantnessLevels[4] // Slightly Pleasant
        case 0.429...0.715:
            return pleasantnessLevels[5] // Pleasant
        default:
            return pleasantnessLevels[6] // Very Pleasant
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                HStack {
                    if !showingEmotions {
                        Text("Choose how you're feeling right now")
                            .font(.headline)
                        Spacer()
                    } else {
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                showingEmotions = false
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isShowingEmotionSelection = false
                        }
                    }) {
                        Image(systemName: cancelButtonIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                
                EmotionOrb(progress: normalizedPleasantnessValue)
                    .padding(.vertical, 8)
                
                Text(currentPleasantnessLevel.name)
                    .font(.title3)
                    .fontWeight(.medium)
                
                if !showingEmotions {
                    VStack(spacing: 16) {
                        let emotionOrb = EmotionOrb(progress: normalizedPleasantnessValue)
                        CustomSlider(value: $pleasantnessValue, configuration: emotionOrb.configuration)
                        
                        HStack {
                            Text("Very Unpleasant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .opacity(normalizedPleasantnessValue < -0.3 ? 1 : 0.5)
                            Spacer()
                            Text("Very Pleasant")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .opacity(normalizedPleasantnessValue > 0.3 ? 1 : 0.5)
                        }
                        .frame(maxWidth: 300)
                    }
                    .frame(height: 80)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            showingEmotions = true
                        }
                    }) {
                        Text("Choose Emotions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.37, green: 0.36, blue: 0.90))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 8) {
                            ForEach(currentPleasantnessLevel.emotions, id: \.self) { emotion in
                                EmotionButton(
                                    emotion: emotion,
                                    isSelected: selectedEmotions.contains(emotion)
                                ) {
                                    if selectedEmotions.contains(emotion) {
                                        selectedEmotions.remove(emotion)
                                    } else {
                                        selectedEmotions.insert(emotion)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 200)
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            isShowingEmotionSelection = false
                        }
                    }) {
                        Text("Save")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.37, green: 0.36, blue: 0.90))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                }
            }
            .padding()
            .frame(width: 400, height: 500)
            .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.2), radius: 20)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

extension Color {
    static func interpolate(from: Color, to: Color, percentage: Double) -> Color {
        let nsFrom = NSColor(from)
        let nsTo = NSColor(to)
        
        let fromRGB = nsFrom.rgbComponents
        let toRGB = nsTo.rgbComponents
        
        return Color(
            red: fromRGB.red + (toRGB.red - fromRGB.red) * percentage,
            green: fromRGB.green + (toRGB.green - fromRGB.green) * percentage,
            blue: fromRGB.blue + (toRGB.blue - fromRGB.blue) * percentage
        )
    }
}

extension NSColor {
    var rgbComponents: (red: CGFloat, green: CGFloat, blue: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red, green, blue)
    }
}

struct ParentView: View {
    @State private var selectedEmotions: Set<String> = []
    @State private var isShowingEmotionSelection: Bool = false
    @State private var pleasantnessValue: Double = 0.5
    @State private var title: String = ""
    @State private var description: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Title", text: $title)
            TextField("Description", text: $description)
            
            if isShowingEmotionSelection {
                EmotionSelectionView(
                    selectedEmotions: $selectedEmotions,
                    pleasantnessValue: $pleasantnessValue,
                    isShowingEmotionSelection: $isShowingEmotionSelection,
                    cancelButtonIcon: "xmark.circle.fill"  // or your custom asset name
                )
            } else {
                Button("Add Emotions") {
                    withAnimation(.spring(response: 0.3)) {
                        isShowingEmotionSelection = true
                    }
                }
            }
        }
        .padding()
    }
}

struct EmotionOrbButton: View {
    let action: () -> Void
    let progress: Double
    
    private var orbConfig: OrbConfiguration {
        let emotionOrb = EmotionOrb(progress: (progress - 0.5) * 2) // Convert from slider value to normalized value
        return emotionOrb.configuration
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.001))
                    .frame(width: 120, height: 120)
                
                OrbView(configuration: orbConfig)
                    .frame(width: 60, height: 60)
                    .allowsHitTesting(false)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 120, height: 120)
    }
}
