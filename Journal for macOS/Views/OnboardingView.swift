import SwiftUI
import AppKit

extension AnyTransition {
    static var blurReplace: AnyTransition {
        .asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 1.1))
                .combined(with: .modifier(active: BlurModifier(blur: 20), identity: BlurModifier(blur: 0))),
            removal: .opacity.combined(with: .scale(scale: 0.9))
                .combined(with: .modifier(active: BlurModifier(blur: 20), identity: BlurModifier(blur: 0)))
        )
    }
}

struct BlurModifier: ViewModifier {
    let blur: CGFloat
    
    func body(content: Content) -> some View {
        content.blur(radius: blur)
    }
}

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("userName") private var userName = ""
    @Environment(\.dismiss) private var dismiss
    
    private let isVersionSpecific: Bool
    private let versionNumber: String
    private let versionFeatures: [VersionFeature]
    
    @State private var currentPage = 0
    @State private var opacity = 1.0
    @State private var tempName = ""
    
    init(isVersionSpecific: Bool = false, versionNumber: String = "", versionFeatures: [VersionFeature] = []) {
        self.isVersionSpecific = isVersionSpecific
        self.versionNumber = versionNumber
        self.versionFeatures = versionFeatures
    }
    
    var body: some View {
        ZStack {
            // Replace solid black with translucent blur
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .ignoresSafeArea()
                .overlay(Color.black.opacity(0.6))
            
            VStack(spacing: 40) {
                // Header with progress indicator and close button
                ZStack {
                    // Center the progress dots
                    HStack(spacing: 8) {
                        ForEach(0..<(isVersionSpecific ? 2 : 4), id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Position the close button at the right
                    HStack {
                        Spacer()
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                hasCompletedOnboarding = true
                                dismiss()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(Circle().fill(.ultraThinMaterial.opacity(0.3)))
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing, 20)
                    }
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Content based on currentPage
                if isVersionSpecific {
                    // Version-specific onboarding
                    if currentPage == 0 {
                        // Welcome to the new version
                        versionWelcomePage
                            .transition(.blurReplace)
                    } else {
                        // Features list
                        versionFeaturesPage
                            .transition(.blurReplace)
                    }
                } else {
                    // Standard onboarding
                    if currentPage == 0 {
                        // Welcome Page
                        welcomePage
                            .transition(.blurReplace)
                    } else if currentPage == 1 {
                        // Name Input
                        nameInputPage
                            .transition(.blurReplace)
                    } else if currentPage == 2 {
                        // Features Overview
                        featuresOverviewPage
                            .transition(.blurReplace)
                    } else {
                        // Final Page
                        finalPage
                            .transition(.blurReplace)
                    }
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentPage > 0 {
                        Button {
                            withAnimation(.spring(duration: 0.5)) {
                                currentPage -= 1
                            }
                        } label: {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(.ultraThinMaterial.opacity(0.3))
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    
                    if isVersionSpecific && currentPage == 1 || !isVersionSpecific && currentPage == 3 {
                        Button {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                opacity = 0
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                hasCompletedOnboarding = true
                                dismiss()
                            }
                        } label: {
                            Text("Get Started")
                                .font(.headline.bold())
                                .foregroundColor(.black)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 24)
                                .background(.white)
                                .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    } else {
                        Button {
                            if currentPage == 1 && tempName.isEmpty {
                                // Don't proceed without a name
                                return
                            }
                            
                            if currentPage == 1 {
                                userName = tempName
                            }
                            
                            withAnimation(.spring(duration: 0.5)) {
                                currentPage += 1
                            }
                        } label: {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .font(.headline.bold())
                            .foregroundColor(.black)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(.white)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                        .opacity(currentPage == 1 && tempName.isEmpty ? 0.5 : 1)
                        .disabled(currentPage == 1 && tempName.isEmpty)
                    }
                }
                .padding(.bottom, 20)
                .padding(.horizontal, 40)
            }
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Make sure it fills the entire window
        }
        .opacity(opacity)
        .onAppear {
            if !userName.isEmpty {
                tempName = userName
            }
        }
    }
    
    // MARK: - Standard Onboarding Pages
    
    private var welcomePage: some View {
        VStack(spacing: 24) {
            Image("journal")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(32)
                .background(
                    Circle()
                        .fill(.white.opacity(0.1))
                        .shadow(color: .white.opacity(0.1), radius: 20)
                )
            
            Text("Welcome to Journal")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                Text("Your personal space for reflection and growth.")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("Journal helps you capture your thoughts, track your mood, and preserve important memories — all in one beautifully designed app.")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 8)
                
                Text("⌘ Optimized for macOS")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 40)
    }
    
    private var nameInputPage: some View {
        VStack(spacing: 24) {
            Text("What's your name?")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Text("We'll use this to personalize your experience.")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            TextField("Enter your name", text: $tempName)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .frame(width: 400)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
        }
        .padding(.horizontal, 40)
    }
    
    private var featuresOverviewPage: some View {
        VStack(spacing: 30) {
            Text("Capture What Matters")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            HStack(spacing: 40) {
                featureCard(
                    icon: "textformat.size",
                    title: "Rich Text Editing",
                    description: "Format your entries with bold, italic, lists and more."
                )
                
                featureCard(
                    icon: "face.smiling",
                    title: "Mood Tracking",
                    description: "Record how you feel with our intuitive emotion tracker."
                )
                
                featureCard(
                    icon: "photo",
                    title: "Image Attachments",
                    description: "Add photos to preserve visual memories alongside your entries."
                )
            }
            .padding(.horizontal, 40)
        }
    }
    
    private var finalPage: some View {
        VStack(spacing: 24) {
            Image(systemName: "sparkles")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundStyle(.white)
                .padding(40)
                .background(
                    Circle()
                        .fill(.white.opacity(0.1))
                        .shadow(color: .white.opacity(0.1), radius: 20)
                )
            
            Text("Welcome, \(userName)!")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
            
            Text("Your journal is ready for your thoughts and memories.")
                .font(.title)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Text("Start by creating your first entry and make journaling a part of your daily ritual.")
                .font(.title3)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func featureCard(icon: String, title: String, description: String) -> some View {
        VStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: 200)
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial.opacity(0.2))
        )
    }
    
    // MARK: - Version-Specific Onboarding Pages
    
    private var versionWelcomePage: some View {
        VStack(spacing: 24) {
            Image("journal")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding(32)
                .background(
                    Circle()
                        .fill(.white.opacity(0.1))
                        .shadow(color: .white.opacity(0.1), radius: 20)
                )
            
            Text("Welcome to Journal \(versionNumber)")
                .font(.system(size: 44, weight: .bold))
                .foregroundColor(.white)
            
            if userName.isEmpty {
                nameInputField
            } else {
                Text("Welcome back, \(userName)!")
                    .font(.title)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            
            Text("We've added some exciting new features to enhance your journaling experience.")
                .font(.title2)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 8)
        }
        .padding(.horizontal, 40)
    }
    
    private var nameInputField: some View {
        VStack(spacing: 16) {
            Text("What's your name?")
                .font(.title2)
                .foregroundColor(.white)
            
            TextField("Enter your name", text: $tempName)
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .textFieldStyle(.plain)
                .frame(width: 300)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial.opacity(0.3))
                )
                .onChange(of: tempName) { _, newValue in
                    userName = newValue
                }
        }
    }
    
    private var versionFeaturesPage: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("What's New in \(versionNumber)")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(versionFeatures.indices, id: \.self) { index in
                    let feature = versionFeatures[index]
                    featureSectionView(feature)
                }
            }
            .padding(.horizontal, 60)
        }
    }
    
    private func featureSectionView(_ feature: VersionFeature) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: feature.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                Text(feature.title)
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }
            
            ForEach(feature.details, id: \.self) { detail in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.top, 6)
                    Text(detail)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.leading, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial.opacity(0.2))
        )
    }
}

// MARK: - Version Feature Model

struct VersionFeature: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let details: [String]
}

// MARK: - XML Parser for Release Notes

class ReleaseNotesParser: NSObject, XMLParserDelegate {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var features: [VersionFeature] = []
    private var isCollectingDescription = false
    private var currentReleaseNotes = ""
    
    func parseReleaseNotes(from xmlString: String) -> [VersionFeature] {
        guard let data = xmlString.data(using: .utf8) else { return [] }
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return processReleaseNotes()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String] = [:]) {
        currentElement = elementName
        
        if elementName == "description" {
            isCollectingDescription = true
            currentDescription = ""
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if isCollectingDescription {
            currentReleaseNotes += string
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "description" {
            isCollectingDescription = false
        }
    }
    
    private func processReleaseNotes() -> [VersionFeature] {
        var features: [VersionFeature] = []
        
        // This is a simple parser for demonstration - a more robust solution would be needed for production
        // Extract sections from the CDATA block (this is a simplified approach)
        let sections = currentReleaseNotes.components(separatedBy: "<h3>")
        
        for section in sections {
            if section.contains("New Features") || section.contains("Improvements") {
                let sectionTitle = extractTitle(from: section)
                let icon = iconForTitle(sectionTitle)
                let details = extractDetails(from: section)
                
                if !details.isEmpty {
                    features.append(VersionFeature(title: sectionTitle, icon: icon, details: details))
                }
            }
        }
        
        return features
    }
    
    private func extractTitle(from section: String) -> String {
        if let range = section.range(of: "</h3>") {
            return String(section[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "New Features"
    }
    
    private func extractDetails(from section: String) -> [String] {
        var details: [String] = []
        
        if let listStart = section.range(of: "<ul>"),
           let listEnd = section.range(of: "</ul>") {
            let listContent = section[listStart.upperBound..<listEnd.lowerBound]
            let items = listContent.components(separatedBy: "<li>")
            
            for item in items {
                if let range = item.range(of: "</li>") {
                    let detail = String(item[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                    if !detail.isEmpty {
                        details.append(detail)
                    }
                }
            }
        }
        
        return details
    }
    
    private func iconForTitle(_ title: String) -> String {
        if title.lowercased().contains("emotion") || title.lowercased().contains("mood") {
            return "face.smiling"
        } else if title.lowercased().contains("performance") {
            return "speedometer"
        } else if title.lowercased().contains("visual") || title.lowercased().contains("ui") {
            return "paintbrush"
        } else if title.lowercased().contains("bug") {
            return "ladybug"
        } else {
            return "star"
        }
    }
}

#Preview {
    // For standard onboarding
    OnboardingView()
    
    // For version-specific onboarding (uncomment to preview)
    /*
    OnboardingView(
        isVersionSpecific: true,
        versionNumber: "1.2.0",
        versionFeatures: [
            VersionFeature(
                title: "Enhanced Emotion Tracking",
                icon: "face.smiling",
                details: [
                    "Introduced the new Emotion Orb interface for more intuitive mood tracking",
                    "Smooth, fluid animations for a more engaging experience",
                    "Better visual feedback when selecting emotions"
                ]
            ),
            VersionFeature(
                title: "Visual Polish",
                icon: "paintbrush",
                details: [
                    "Restored transparent backgrounds for better visual consistency",
                    "Improved field alignments and padding",
                    "Better visual hierarchy in entry views"
                ]
            )
        ]
    )
    */
} 