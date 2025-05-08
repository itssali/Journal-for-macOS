import SwiftUI
import AppKit

class OnboardingManager: ObservableObject {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("lastSeenVersionNumber") private var lastSeenVersionNumber = ""
    @Published var showOnboarding = false
    @Published var showVersionOnboarding = false
    
    // Properties to store references to onboarding view hosts
    var onboardingHostingView: NSView?
    var versionOnboardingHostingView: NSView?
    
    private let currentVersionNumber: String
    private var versionFeatures: [VersionFeature] = []
    
    init() {
        // Get current app version
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            self.currentVersionNumber = version
        } else {
            self.currentVersionNumber = "1.0.0"
        }
        
        // Check if we need to show onboarding
        if !hasCompletedOnboarding {
            self.showOnboarding = true
        } else if lastSeenVersionNumber != currentVersionNumber {
            // We have a new version - parse release notes
            loadReleaseNotes()
        }
    }
    
    func showOnboardingIfNeeded() -> Bool {
        return showOnboarding || showVersionOnboarding
    }
    
    func onboardingCompleted() {
        hasCompletedOnboarding = true
        lastSeenVersionNumber = currentVersionNumber
        showOnboarding = false
        showVersionOnboarding = false
        
        // Remove the hosting views if they exist
        DispatchQueue.main.async {
            self.onboardingHostingView?.removeFromSuperview()
            self.onboardingHostingView = nil
            
            self.versionOnboardingHostingView?.removeFromSuperview()
            self.versionOnboardingHostingView = nil
        }
    }
    
    func showStandardOnboarding() {
        showOnboarding = true
    }
    
    func getVersionFeatures() -> [VersionFeature] {
        return versionFeatures
    }
    
    func getCurrentVersion() -> String {
        return currentVersionNumber
    }
    
    private func loadReleaseNotes() {
        guard let appcastURL = Bundle.main.url(forResource: "appcast", withExtension: "xml") else {
            print("Could not find appcast.xml")
            return
        }
        
        do {
            let xmlString = try String(contentsOf: appcastURL, encoding: .utf8)
            let parser = ReleaseNotesParser()
            let features = parser.parseReleaseNotes(from: xmlString)
            
            if !features.isEmpty {
                self.versionFeatures = features
                self.showVersionOnboarding = true
            }
            
        } catch {
            print("Error loading release notes: \(error)")
        }
    }
}

// Extension to make OnboardingManager available as an environment object
extension OnboardingManager {
    static var preview: OnboardingManager {
        let manager = OnboardingManager()
        manager.versionFeatures = [
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
        return manager
    }
} 