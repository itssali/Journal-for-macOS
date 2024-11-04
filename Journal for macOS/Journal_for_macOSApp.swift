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
        
        // Print current version and feed info
        if let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            print("Current app version: \(currentVersion)")
        }
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
        .windowStyle(.hiddenTitleBar)
    }
}
