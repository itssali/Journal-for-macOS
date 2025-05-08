//
//  Journal_for_macOSApp.swift
//  Journal for macOS
//
//  Created by Ali Nasser on 01/11/2024.
//

import SwiftUI
import Sparkle

@main
struct Journal_for_macOSApp: App {
    
    private let updaterController: SPUStandardUpdaterController
    
    init() {
        // Create an updater delegate to log update checks
        class UpdaterDelegate: NSObject, SPUUpdaterDelegate {
            func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
                print("Found valid update: \(item.displayVersionString)")
                // Add more version details
                print("Update version details:")
                print("- Display version: \(item.displayVersionString)")
                print("- Version string: \(item.versionString)")
            }
            
            func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
                print("Loaded appcast with \(appcast.items.count) items")
                for item in appcast.items {
                    print("Appcast item version: \(item.displayVersionString)")
                }
            }
        }
        
        let delegate = UpdaterDelegate()
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: delegate, userDriverDelegate: nil)
        
        // Print all version info
        let bundle = Bundle.main
        print("App version details:")
        print("- CFBundleShortVersionString: \(bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "not set")")
        print("- CFBundleVersion: \(bundle.object(forInfoDictionaryKey: "CFBundleVersion") ?? "not set")")
        print("Feed URL: \(updaterController.updater.feedURL?.absoluteString ?? "No feed URL")")
        
        // Enable system logging for Sparkle
        UserDefaults.standard.set(true, forKey: "SUEnableSystemProfiling")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 1000, height: 720)
        .windowStyle(.hiddenTitleBar)
        
        Settings {
            SettingsView(onShowOnboarding: {
                // Simpler approach to show onboarding
                UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                // Don't close the main window, only the settings window
                NSApp.keyWindow?.close()
                // A slight delay to ensure settings are closed first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NotificationCenter.default.post(name: Notification.Name("ShowOnboarding"), object: nil)
                }
            })
        }
    }
}
