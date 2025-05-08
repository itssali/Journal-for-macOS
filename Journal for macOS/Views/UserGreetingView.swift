import SwiftUI

struct UserGreetingView: View {
    @AppStorage("userName") private var userName = ""
    @State private var currentTime = Date()
    @State private var timer: Timer?
    
    private var timeOfDay: TimeOfDay {
        let hour = Calendar.current.component(.hour, from: currentTime)
        
        switch hour {
        case 5..<12:
            return .morning
        case 12..<17:
            return .afternoon
        case 17..<21:
            return .evening
        default:
            return .night
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            timeImage
                .font(.system(size: 18))
                .foregroundColor(.secondary)
            
            if userName.isEmpty {
                Text(greeting)
                    .font(.headline)
                    .foregroundColor(.primary)
            } else {
                Text("\(greeting), \(userName)")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var greeting: String {
        switch timeOfDay {
        case .morning:
            return "Good Morning"
        case .afternoon:
            return "Good Afternoon"
        case .evening:
            return "Good Evening"
        case .night:
            return "Good Night"
        }
    }
    
    private var timeImage: some View {
        Image(systemName: timeOfDay.iconName)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in
            self.currentTime = Date()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

enum TimeOfDay {
    case morning
    case afternoon
    case evening
    case night
    
    var iconName: String {
        switch self {
        case .morning:
            return "sun.and.horizon"
        case .afternoon:
            return "sun.max"
        case .evening:
            return "sun.and.horizon"
        case .night:
            return "moon.stars"
        }
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.2)
        UserGreetingView()
    }
    .frame(width: 300, height: 100)
} 