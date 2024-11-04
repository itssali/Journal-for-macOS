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
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
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
